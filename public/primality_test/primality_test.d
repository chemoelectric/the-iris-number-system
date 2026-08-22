/*********************************************************************
* Deterministic Iris Primality Inference Engine Module
*
* Implements the combined Vernier Phase Trajectory (Miller-Rabin)
* and Lucas-Frobenius Cl(2,0) Bivector Rotor (Baillie-PSW) test with
* arbitrary multiple-precision integer support using std.bigint.
*
* Execution modes (flags for gdc):
*   -fversion=standalone (Command-line application with main)
*   -fversion=demo       (Demonstration suite)
*********************************************************************/

module primality_test;

import std.stdio;
import std.datetime.stopwatch;
import std.conv;
import std.string;
import std.parallelism;
import std.bigint;

struct PrimalityResult
{
  bool isPrime;
  BigInt candidate;
}

struct VectorizedBatchResult
{
  size_t totalTested;
  size_t primeCount;
  double executionTimeMs;
}

BigInt powMod(BigInt baseVal, BigInt expVal, BigInt modVal)
{
  BigInt res = BigInt(1);
  BigInt b = baseVal % modVal;
  BigInt e = expVal;
  while (e > 0)
    {
      if ((e & 1) != 0)
        {
          res = (res * b) % modVal;
        }
      b = (b * b) % modVal;
      e = e >> 1;
    }
  return res;
}

int jacobiSymbol(BigInt a, BigInt n)
{
  int result = 1;
  BigInt aVal = a % n;
  if (aVal < 0)
    {
      aVal = aVal + n;
    }
  BigInt nVal = n;

  while (aVal != 0)
    {
      while ((aVal & 1) == 0)
        {
          aVal = aVal >> 1;
          BigInt nMod8 = nVal & 7;
          if (nMod8 == 3 || nMod8 == 5)
            {
              result = -result;
            }
        }
      BigInt temp = aVal;
      aVal = nVal;
      nVal = temp;

      if ((aVal & 3) == 3 && (nVal & 3) == 3)
        {
          result = -result;
        }
      aVal = aVal % nVal;
    }

  if (nVal != 1)
    {
      result = 0;
    }

  return result;
}

bool millerRabinVernierTest(BigInt n, BigInt baseVal)
{
  bool isP = false;
  if (n < 2)
    {
      isP = false;
    }
  else if (n == 2 || n == 3)
    {
      isP = true;
    }
  else if ((n & 1) == 0)
    {
      isP = false;
    }
  else
    {
      BigInt d = n - 1;
      size_t s = 0;
      while ((d & 1) == 0)
        {
          d = d >> 1;
          s = s + 1;
        }

      BigInt x = powMod(baseVal, d, n);
      if (x == 1 || x == (n - 1))
        {
          isP = true;
        }
      else
        {
          bool foundMinusOne = false;
          size_t r = 1;
          while (r < s && !foundMinusOne)
            {
              x = (x * x) % n;
              if (x == (n - 1))
                {
                  foundMinusOne = true;
                }
              r = r + 1;
            }
          isP = foundMinusOne;
        }
    }
  return isP;
}

BigInt findSelfridgeDiscriminant(BigInt n, out bool sharesFactor)
{
  sharesFactor = false;
  BigInt d = BigInt(5);
  BigInt sign = BigInt(1);
  BigInt D = BigInt(5);
  bool found = false;

  while (!found && !sharesFactor)
    {
      int j = jacobiSymbol(D, n);
      if (j == -1)
        {
          found = true;
        }
      else if (j == 0)
        {
          BigInt absD = D < 0 ? -D : D;
          if (absD < n)
            {
              sharesFactor = true;
            }
        }

      if (!found && !sharesFactor)
        {
          d = d + 2;
          sign = -sign;
          D = d * sign;
        }
    }
  return D;
}

size_t countBigIntBits(BigInt val)
{
  size_t count = 0;
  BigInt v = val;
  while (v > 0)
    {
      v = v >> 1;
      count = count + 1;
    }
  return count;
}

void lucasStepBit(ref BigInt u, ref BigInt v, ref BigInt qk,
                  BigInt qMod, BigInt dMod, BigInt n)
{
  BigInt uNext = (u + v);
  uNext = ((uNext % n) + n) % n;
  if ((uNext & 1) != 0)
    {
      uNext = uNext + n;
    }
  uNext = (uNext >> 1) % n;

  BigInt vNext = (dMod * u + v);
  vNext = ((vNext % n) + n) % n;
  if ((vNext & 1) != 0)
    {
      vNext = vNext + n;
    }
  vNext = (vNext >> 1) % n;

  BigInt qkNext = (qk * qMod) % n;
  qkNext = ((qkNext % n) + n) % n;

  u = uNext;
  v = vNext;
  qk = qkNext;
}

bool lucasFrobeniusRotorTest(BigInt n)
{
  bool isP = false;
  if (n < 2)
    {
      isP = false;
    }
  else if (n == 2)
    {
      isP = true;
    }
  else if ((n & 1) == 0)
    {
      isP = false;
    }
  else
    {
      bool sharesFactor = false;
      BigInt D = findSelfridgeDiscriminant(n, sharesFactor);
      if (sharesFactor)
        {
          isP = false;
        }
      else
        {
          BigInt P = BigInt(1);
          BigInt Q = (BigInt(1) - D) / 4;
          BigInt k = n + 1;
          size_t bitCount = countBigIntBits(k);

          BigInt u = BigInt(1);
          BigInt pMod = ((P % n) + n) % n;
          BigInt qMod = ((Q % n) + n) % n;
          BigInt dMod = ((D % n) + n) % n;
          BigInt v = pMod;
          BigInt qk = qMod;

          size_t bitIdx = bitCount - 1;
          while (bitIdx > 0)
            {
              size_t currBit = bitIdx - 1;
              BigInt uDouble = (u * v) % n;
              BigInt vDouble = ((v * v) - BigInt(2) * qk) % n;
              vDouble = ((vDouble % n) + n) % n;
              BigInt qkDouble = (qk * qk) % n;
              qkDouble = ((qkDouble % n) + n) % n;

              u = uDouble;
              v = vDouble;
              qk = qkDouble;

              if (((k >> currBit) & 1) != 0)
                {
                  lucasStepBit(u, v, qk, qMod, dMod, n);
                }
              bitIdx = bitIdx - 1;
            }

          if (u == 0)
            {
              isP = true;
            }
        }
    }
  return isP;
}

bool isPrimeIrisBailliePSW(BigInt n)
{
  bool result = false;
  if (n < 2)
    {
      result = false;
    }
  else if (n == 2 || n == 3 || n == 5 || n == 7)
    {
      result = true;
    }
  else if ((n & 1) == 0 || n % 3 == 0 || n % 5 == 0 || n % 7 == 0)
    {
      result = false;
    }
  else
    {
      bool mrPass = millerRabinVernierTest(n, BigInt(2));
      if (mrPass)
        {
          bool lucasPass = lucasFrobeniusRotorTest(n);
          result = lucasPass;
        }
    }
  return result;
}

bool isPrimeIrisBailliePSW64(ulong n)
{
  bool res = isPrimeIrisBailliePSW(BigInt(n));
  return res;
}

void batchPrimalityTest(const BigInt[] candidates, bool[] results)
{
  size_t len = candidates.length;
  size_t idx = 0;
  while (idx < len)
    {
      results[idx] = isPrimeIrisBailliePSW(candidates[idx]);
      idx = idx + 1;
    }
}

VectorizedBatchResult runParallelPrimalityBenchmark(size_t count)
{
  BigInt[] candidates = new BigInt[count];
  bool[] results = new bool[count];

  size_t idx = 0;
  BigInt startVal = BigInt("1000000000000000000");
  while (idx < count)
    {
      candidates[idx] = startVal + BigInt(idx * 2 + 1);
      idx = idx + 1;
    }

  auto sw = StopWatch(AutoStart.yes);
  batchPrimalityTest(candidates, results);
  sw.stop();

  size_t primeCount = 0;
  idx = 0;
  while (idx < count)
    {
      if (results[idx])
        {
          primeCount = primeCount + 1;
        }
      idx = idx + 1;
    }

  double timeMs = sw.peek().total!"usecs" / 1000.0;
  VectorizedBatchResult benchRes;
  benchRes.totalTested = count;
  benchRes.primeCount = primeCount;
  benchRes.executionTimeMs = timeMs;
  return benchRes;
}

unittest
{
  assert(isPrimeIrisBailliePSW(BigInt(2)));
  assert(isPrimeIrisBailliePSW(BigInt(3)));
  assert(isPrimeIrisBailliePSW(BigInt(5)));
  assert(isPrimeIrisBailliePSW(BigInt(7)));
  assert(isPrimeIrisBailliePSW(BigInt(11)));
  assert(isPrimeIrisBailliePSW(BigInt(13)));
  assert(isPrimeIrisBailliePSW(BigInt(17)));
  assert(isPrimeIrisBailliePSW(BigInt(19)));
  assert(isPrimeIrisBailliePSW(BigInt(23)));
  assert(isPrimeIrisBailliePSW(BigInt(29)));
  assert(isPrimeIrisBailliePSW(BigInt(31)));
  assert(isPrimeIrisBailliePSW(BigInt(37)));
  assert(isPrimeIrisBailliePSW(BigInt(1000000007UL)));
  assert(isPrimeIrisBailliePSW(BigInt(4294967291UL)));
  assert(isPrimeIrisBailliePSW(BigInt(
    "1000000000000000000000000000057")));

  assert(!isPrimeIrisBailliePSW(BigInt(0)));
  assert(!isPrimeIrisBailliePSW(BigInt(1)));
  assert(!isPrimeIrisBailliePSW(BigInt(4)));
  assert(!isPrimeIrisBailliePSW(BigInt(6)));
  assert(!isPrimeIrisBailliePSW(BigInt(8)));
  assert(!isPrimeIrisBailliePSW(BigInt(9)));
  assert(!isPrimeIrisBailliePSW(BigInt(15)));
  assert(!isPrimeIrisBailliePSW(BigInt(21)));
  assert(!isPrimeIrisBailliePSW(BigInt(25)));
  assert(!isPrimeIrisBailliePSW(BigInt(27)));
  assert(!isPrimeIrisBailliePSW(BigInt(33)));
  assert(!isPrimeIrisBailliePSW(BigInt(35)));
  assert(!isPrimeIrisBailliePSW(BigInt(561UL)));
  assert(!isPrimeIrisBailliePSW(BigInt(1105UL)));
  assert(!isPrimeIrisBailliePSW(BigInt(1729UL)));
  assert(!isPrimeIrisBailliePSW(BigInt(2465UL)));

  assert(jacobiSymbol(BigInt(1), BigInt(5)) == 1);
  assert(jacobiSymbol(BigInt(2), BigInt(5)) == -1);
  assert(jacobiSymbol(BigInt(3), BigInt(5)) == -1);
  assert(jacobiSymbol(BigInt(4), BigInt(5)) == 1);

  BigInt[] candidates = [BigInt(2), BigInt(3), BigInt(4),
                         BigInt(5), BigInt(561), BigInt(1000000007)];
  bool[] results = new bool[6];
  batchPrimalityTest(candidates, results);
  assert(results[0] == true);
  assert(results[1] == true);
  assert(results[2] == false);
  assert(results[3] == true);
  assert(results[4] == false);
  assert(results[5] == true);
}

version (standalone)
{
  void main(string[] args)
  {
    writeln("==================================================");
    writeln("Deterministic Iris Primality Inference Engine");
    writeln("Precision Configuration: std.bigint (Arbitrary)");
    writeln("==================================================");

    BigInt testVal = BigInt("1000000007");
    if (args.length > 1)
      {
        testVal = BigInt(strip(args[1]));
      }

    writeln("\nExecuting single aperture primality evaluation...");
    auto sw = StopWatch(AutoStart.yes);
    bool primeRes = isPrimeIrisBailliePSW(testVal);
    sw.stop();
    double singleTimeUs = sw.peek().total!"usecs";

    writefln("Candidate Aperture: %s", testVal);
    string statusStr = primeRes ? "PRIME" : "COMPOSITE";
    writefln("Primality Status:   %s", statusStr);
    writefln("Evaluation Latency: %.3f microseconds", singleTimeUs);

    writeln("\nExecuting batch benchmark...");
    VectorizedBatchResult bench = runParallelPrimalityBenchmark(1000);
    writefln("Total Apertures Tested: %d", bench.totalTested);
    writefln("Primes Identified:     %d", bench.primeCount);
    writefln("Batch Execution Time:  %.2f ms", bench.executionTimeMs);
    double rate = (cast(double) bench.totalTested /
                   bench.executionTimeMs) * 1000.0;
    writefln("Throughput Rate:       %.2f tests/sec", rate);
    writeln("==================================================");
  }
}
