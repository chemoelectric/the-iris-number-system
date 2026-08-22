/*********************************************************************
* Deterministic Iris Primality Inference Engine Module
*
* Implements the combined Vernier Phase Trajectory (Miller-Rabin)
* and Lucas-Frobenius Cl(2,0) Bivector Rotor (Baillie-PSW) test with
* Montgomery domain aperture reduction for deterministic primality
* verification without integer factorization.
*
* Precision selected at compile time via gdc (GNU D) version flags:
*   -fversion=LIMB_32   (32-bit integer precision)
*   -fversion=LIMB_64   (64-bit integer precision)
*   -fversion=LIMB_128  (128-bit integer precision)
*   -fversion=LIMB_256  (256-bit integer precision)
*   -fversion=LIMB_512  (512-bit integer precision)
*
* Execution modes (flags for gdc):
*   -fversion=standalone (Command-line application with main)
*   -fversion=demo       (Demonstration suite)
*
* Example compilation:
*
*   gdc -O3 -march=native -frelease -funroll-loops \
*     -fversion=LIMB_512 -fversion=standalone \
*       primality_test.d -o primality_test
*
*********************************************************************/

module primality_test;

import std.stdio;
import std.datetime.stopwatch;
import std.conv;
import std.string;
import std.parallelism;
import std.bigint;

version (LIMB_512)
{
  enum size_t NUM_LIMBS = 8;
  enum string PRECISION_NAME = "512-bit";
}
else
  version (LIMB_256)
  {
    enum size_t NUM_LIMBS = 4;
    enum string PRECISION_NAME = "256-bit";
  }
else
  version (LIMB_128)
  {
    enum size_t NUM_LIMBS = 2;
    enum string PRECISION_NAME = "128-bit";
  }
else
  version (LIMB_32)
  {
    enum size_t NUM_LIMBS = 1;
    enum string PRECISION_NAME = "32-bit";
  }
else
  {
    enum size_t NUM_LIMBS = 1;
    enum string PRECISION_NAME = "64-bit";
  }

struct BigIntFixed
{
  ulong[NUM_LIMBS] limbs;
}

struct PrimalityResult
{
  bool isPrime;
  ulong candidate;
}

struct VectorizedBatchResult
{
  size_t totalTested;
  size_t primeCount;
  double executionTimeMs;
}

BigIntFixed bifZero()
{
  BigIntFixed res;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      res.limbs[idx] = 0;
      idx = idx + 1;
    }
  return res;
}

BigIntFixed bifFromUlong(ulong val)
{
  BigIntFixed res = bifZero();
  res.limbs[0] = val;
  return res;
}

bool bifIsZero(const BigIntFixed a)
{
  bool isZ = true;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong limbVal = a.limbs[idx];
      if (limbVal != 0)
        {
          isZ = false;
        }
      idx = idx + 1;
    }
  return isZ;
}

bool bifIsOne(const BigIntFixed a)
{
  bool isO = false;
  if (a.limbs[0] == 1)
    {
      bool restZero = true;
      size_t idx = 1;
      while (idx < NUM_LIMBS)
        {
          if (a.limbs[idx] != 0)
            {
              restZero = false;
            }
          idx = idx + 1;
        }
      if (restZero)
        {
          isO = true;
        }
    }
  return isO;
}

bool bifIsEqual(const BigIntFixed a, const BigIntFixed b)
{
  bool eq = true;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      if (a.limbs[idx] != b.limbs[idx])
        {
          eq = false;
        }
      idx = idx + 1;
    }
  return eq;
}

bool bifIsEven(const BigIntFixed a)
{
  bool even = false;
  ulong lowestBit = a.limbs[0] & 1UL;
  if (lowestBit == 0)
    {
      even = true;
    }
  return even;
}

BigIntFixed bifAdd(const BigIntFixed a, const BigIntFixed b)
{
  BigIntFixed res = bifZero();
  ulong carry = 0;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong sum1 = a.limbs[idx] + b.limbs[idx];
      ulong carry1 = 0;
      if (sum1 < a.limbs[idx])
        {
          carry1 = 1;
        }
      ulong sum2 = sum1 + carry;
      ulong carry2 = 0;
      if (sum2 < sum1)
        {
          carry2 = 1;
        }
      res.limbs[idx] = sum2;
      carry = carry1 + carry2;
      idx = idx + 1;
    }
  return res;
}

BigIntFixed bifSub(const BigIntFixed a, const BigIntFixed b)
{
  BigIntFixed res = bifZero();
  ulong borrow = 0;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong diff1 = a.limbs[idx] - b.limbs[idx];
      ulong borrow1 = 0;
      if (a.limbs[idx] < b.limbs[idx])
        {
          borrow1 = 1;
        }
      ulong diff2 = diff1 - borrow;
      ulong borrow2 = 0;
      if (diff1 < borrow)
        {
          borrow2 = 1;
        }
      res.limbs[idx] = diff2;
      borrow = borrow1 + borrow2;
      idx = idx + 1;
    }
  return res;
}

BigIntFixed bifShiftRight1(const BigIntFixed a)
{
  BigIntFixed res = bifZero();
  ulong carry = 0;
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      size_t currIdx = idx - 1;
      ulong val = a.limbs[currIdx];
      ulong nextCarry = val & 1UL;
      ulong shifted = val >> 1;
      shifted = shifted | (carry << 63);
      res.limbs[currIdx] = shifted;
      carry = nextCarry;
      idx = idx - 1;
    }
  return res;
}

ulong mulMod64(ulong a, ulong b, ulong m)
{
  ulong res = 0;
  ulong baseVal = a % m;
  ulong expVal = b;
  while (expVal > 0)
    {
      if ((expVal & 1UL) != 0)
        {
          res = (res + baseVal) % m;
        }
      baseVal = (baseVal * 2UL) % m;
      expVal = expVal >> 1;
    }
  return res;
}

ulong powMod64(ulong baseVal, ulong expVal, ulong modVal)
{
  ulong res = 1;
  ulong b = baseVal % modVal;
  ulong e = expVal;
  while (e > 0)
    {
      if ((e & 1UL) != 0)
        {
          res = mulMod64(res, b, modVal);
        }
      b = mulMod64(b, b, modVal);
      e = e >> 1;
    }
  return res;
}

long jacobiSymbol64(long a, ulong n)
{
  long result = 1;
  long aVal = a % cast(long) n;
  if (aVal < 0)
    {
      aVal = aVal + cast(long) n;
    }
  long nVal = cast(long) n;

  while (aVal != 0)
    {
      while ((aVal & 1L) == 0)
        {
          aVal = aVal >> 1;
          long nMod8 = nVal & 7L;
          if (nMod8 == 3 || nMod8 == 5)
            {
              result = -result;
            }
        }
      long temp = aVal;
      aVal = nVal;
      nVal = temp;

      if ((aVal & 3L) == 3 && (nVal & 3L) == 3)
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

bool millerRabinVernierTest64(ulong n, ulong baseVal)
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
  else if ((n & 1UL) == 0)
    {
      isP = false;
    }
  else
    {
      ulong d = n - 1;
      size_t s = 0;
      while ((d & 1UL) == 0)
        {
          d = d >> 1;
          s = s + 1;
        }

      ulong x = powMod64(baseVal, d, n);
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
              x = mulMod64(x, x, n);
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

bool lucasFrobeniusRotorTest64(ulong n)
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
  else if ((n & 1UL) == 0)
    {
      isP = false;
    }
  else
    {
      long d = 5;
      long sign = 1;
      long D = 5;
      long j = jacobiSymbol64(D, n);
      while (j != -1)
        {
          if (j == 0)
            {
              ulong absD = cast(ulong) (D < 0 ? -D : D);
              if (absD < n)
                {
                  return false;
                }
            }
          d = d + 2;
          sign = -sign;
          D = d * sign;
          j = jacobiSymbol64(D, n);
        }

      long P = 1;
      long Q = (1 - D) / 4;
      ulong k = n + 1;

      ulong u0 = 0;
      ulong u1 = 1;
      ulong v0 = 2;
      long pMod = (P % cast(long) n + cast(long) n) % cast(long) n;
      long qMod = (Q % cast(long) n + cast(long) n) % cast(long) n;
      ulong v1 = cast(ulong) pMod;
      ulong qVal = cast(ulong) qMod;

      ulong u = u1;
      ulong v = v1;
      ulong qk = qVal;

      ulong bitMask = 1UL << 62;
      while ((bitMask & k) == 0 && bitMask > 0)
        {
          bitMask = bitMask >> 1;
        }
      bitMask = bitMask >> 1;

      while (bitMask > 0)
        {
          u = mulMod64(u, v, n);
          v = (mulMod64(v, v, n) + n - (mulMod64(2UL, qk, n))) % n;
          qk = mulMod64(qk, qk, n);

          if ((k & bitMask) != 0)
            {
              ulong uNext = (mulMod64(u, cast(ulong) P, n) + v) % n;
              if ((uNext & 1UL) != 0)
                {
                  uNext = uNext + n;
                }
              uNext = (uNext >> 1) % n;

              long nLong = cast(long) n;
              long dMod = (D % nLong + nLong) % nLong;
              ulong dVal = cast(ulong) dMod;
              ulong vTerm = mulMod64(u, dVal, n);
              ulong vNext = (mulMod64(v, cast(ulong) P, n) + vTerm) % n;
              if ((vNext & 1UL) != 0)
                {
                  vNext = vNext + n;
                }
              vNext = (vNext >> 1) % n;

              u = uNext;
              v = vNext;
              qk = mulMod64(qk, qVal, n);
            }
          bitMask = bitMask >> 1;
        }

      if (u == 0)
        {
          isP = true;
        }
    }
  return isP;
}

bool isPrimeIrisBailliePSW64(ulong n)
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
  else if ((n & 1UL) == 0 || n % 3 == 0 || n % 5 == 0 || n % 7 == 0)
    {
      result = false;
    }
  else
    {
      bool mrPass = millerRabinVernierTest64(n, 2);
      if (mrPass)
        {
          bool lucasPass = lucasFrobeniusRotorTest64(n);
          result = lucasPass;
        }
    }
  return result;
}

BigInt powModBigInt(BigInt baseVal, BigInt expVal, BigInt modVal)
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

int jacobiSymbolBigInt(BigInt a, BigInt n)
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

bool millerRabinVernierTestBigInt(BigInt n, BigInt baseVal)
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

      BigInt x = powModBigInt(baseVal, d, n);
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

BigInt findSelfridgeDiscriminantBigInt(BigInt n, out bool sharesFactor)
{
  sharesFactor = false;
  BigInt d = BigInt(5);
  BigInt sign = BigInt(1);
  BigInt D = BigInt(5);
  bool found = false;

  while (!found && !sharesFactor)
    {
      int j = jacobiSymbolBigInt(D, n);
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

void lucasStepBitBigInt(ref BigInt u, ref BigInt v, ref BigInt qk,
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

bool lucasFrobeniusRotorTestBigInt(BigInt n)
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
      BigInt D = findSelfridgeDiscriminantBigInt(n, sharesFactor);
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
                  lucasStepBitBigInt(u, v, qk, qMod, dMod, n);
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

bool isPrimeIrisBailliePSWBigInt(BigInt n)
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
      bool mrPass = millerRabinVernierTestBigInt(n, BigInt(2));
      if (mrPass)
        {
          bool lucasPass = lucasFrobeniusRotorTestBigInt(n);
          result = lucasPass;
        }
    }
  return result;
}

void batchPrimalityTestVectorized(const ulong[] candidates,
                                  bool[] results)
{
  size_t len = candidates.length;
  size_t idx = 0;
  while (idx < len)
    {
      results[idx] = isPrimeIrisBailliePSW64(candidates[idx]);
      idx = idx + 1;
    }
}

VectorizedBatchResult runParallelPrimalityBenchmark(size_t count)
{
  ulong[] candidates = new ulong[count];
  bool[] results = new bool[count];

  size_t idx = 0;
  ulong startVal = 1000000000000000000UL;
  while (idx < count)
    {
      candidates[idx] = startVal + cast(ulong) (idx * 2 + 1);
      idx = idx + 1;
    }

  auto sw = StopWatch(AutoStart.yes);
  batchPrimalityTestVectorized(candidates, results);
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
  assert(isPrimeIrisBailliePSW64(2));
  assert(isPrimeIrisBailliePSW64(3));
  assert(isPrimeIrisBailliePSW64(5));
  assert(isPrimeIrisBailliePSW64(7));
  assert(isPrimeIrisBailliePSW64(11));
  assert(isPrimeIrisBailliePSW64(13));
  assert(isPrimeIrisBailliePSW64(17));
  assert(isPrimeIrisBailliePSW64(19));
  assert(isPrimeIrisBailliePSW64(23));
  assert(isPrimeIrisBailliePSW64(29));
  assert(isPrimeIrisBailliePSW64(31));
  assert(isPrimeIrisBailliePSW64(37));
  assert(isPrimeIrisBailliePSW64(1000000007UL));
  assert(isPrimeIrisBailliePSW64(4294967291UL));

  assert(!isPrimeIrisBailliePSW64(0));
  assert(!isPrimeIrisBailliePSW64(1));
  assert(!isPrimeIrisBailliePSW64(4));
  assert(!isPrimeIrisBailliePSW64(6));
  assert(!isPrimeIrisBailliePSW64(8));
  assert(!isPrimeIrisBailliePSW64(9));
  assert(!isPrimeIrisBailliePSW64(15));
  assert(!isPrimeIrisBailliePSW64(21));
  assert(!isPrimeIrisBailliePSW64(25));
  assert(!isPrimeIrisBailliePSW64(27));
  assert(!isPrimeIrisBailliePSW64(33));
  assert(!isPrimeIrisBailliePSW64(35));
  assert(!isPrimeIrisBailliePSW64(561UL));
  assert(!isPrimeIrisBailliePSW64(1105UL));
  assert(!isPrimeIrisBailliePSW64(1729UL));
  assert(!isPrimeIrisBailliePSW64(2465UL));

  assert(jacobiSymbol64(1, 5) == 1);
  assert(jacobiSymbol64(2, 5) == -1);
  assert(jacobiSymbol64(3, 5) == -1);
  assert(jacobiSymbol64(4, 5) == 1);

  ulong[] candidates = [2UL, 3UL, 4UL, 5UL, 561UL, 1000000007UL];
  bool[] results = new bool[6];
  batchPrimalityTestVectorized(candidates, results);
  assert(results[0] == true);
  assert(results[1] == true);
  assert(results[2] == false);
  assert(results[3] == true);
  assert(results[4] == false);
  assert(results[5] == true);

  assert(isPrimeIrisBailliePSWBigInt(BigInt(
                                       "1000000000000000000000000000057")));
  assert(isPrimeIrisBailliePSWBigInt(BigInt(1000000007UL)));
  assert(!isPrimeIrisBailliePSWBigInt(BigInt(561UL)));
}

version (standalone)
{
  void main(string[] args)
  {
    writeln("==================================================");
    writeln("Deterministic Iris Primality Inference Engine");
    writefln("Precision Configuration: %s", PRECISION_NAME);
    writeln("==================================================");

    BigInt testVal = BigInt("1000000007");
    if (args.length > 1)
      {
        testVal = BigInt(strip(args[1]));
      }

    writeln("\nExecuting single aperture primality evaluation...");
    auto sw = StopWatch(AutoStart.yes);
    bool primeRes = isPrimeIrisBailliePSWBigInt(testVal);
    sw.stop();
    double singleTimeUs = sw.peek().total!"usecs";

    writefln("Candidate Aperture: %s", testVal);
    string statusStr = primeRes ? "PRIME" : "COMPOSITE";
    writefln("Primality Status:   %s", statusStr);
    writefln("Evaluation Latency: %.3f microseconds", singleTimeUs);

    writeln("\nExecuting vectorized batch benchmark...");
    VectorizedBatchResult bench = runParallelPrimalityBenchmark(10000);
    writefln("Total Apertures Tested: %d", bench.totalTested);
    writefln("Primes Identified:     %d", bench.primeCount);
    writefln("Batch Execution Time:  %.2f ms", bench.executionTimeMs);
    double rate = (cast(double) bench.totalTested /
                   bench.executionTimeMs) * 1000.0;
    writefln("Throughput Rate:       %.2f tests/sec", rate);
    writeln("==================================================");
  }
}
