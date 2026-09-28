/*********************************************************************
* Fast Parallel Factorization Inference Engine Module
*
* Implements parallel factor search using m-resolution modular
* arithmetic, wheel-30 range decomposition, and fast radix modular
* reduction to extract all prime factors of an integer.
*
* Precision is selected at compile time via version flags:
*   -fversion=LIMB_64   (64-bit integer precision)
*   -fversion=LIMB_128  (128-bit integer precision)
*   -fversion=LIMB_256  (256-bit integer precision)
*   -fversion=LIMB_512  (512-bit integer precision)
*
* Program execution mode selected via version flags:
*   -fversion=standalone  (Command-line standalone application)
*   -fversion=demo        (Demonstration and benchmarking suite)
*********************************************************************/

module fast_factorization;

import std.stdio;
import std.parallelism;
import std.concurrency;
import std.datetime.stopwatch;
import core.atomic;
import std.conv;
import std.string;

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
  {
    enum size_t NUM_LIMBS = 1;
    enum string PRECISION_NAME = "64-bit";
  }

struct BigIntFixed
{
  ulong[NUM_LIMBS] limbs;
}

struct FactorSearchResult
{
  bool found;
  ulong factor;
}

struct PrimeFactorizationResult
{
  BigIntFixed[] factors;
  bool complete;
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
  ulong l0 = a.limbs[0];
  if (l0 == 1)
    {
      bool restZero = true;
      size_t idx = 1;
      while (idx < NUM_LIMBS)
        {
          ulong limbVal = a.limbs[idx];
          if (limbVal != 0)
            {
              restZero = false;
            }
          idx = idx + 1;
        }
      if (restZero == true)
        {
          isO = true;
        }
    }
  return isO;
}

bool bifIsEven(const BigIntFixed a)
{
  ulong l0 = a.limbs[0];
  ulong rem = l0 % 2;
  bool res = false;
  if (rem == 0)
    {
      res = true;
    }
  return res;
}

int bifCompare(const BigIntFixed a, const BigIntFixed b)
{
  int cmpRes = 0;
  bool found = false;
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      if (found == false)
        {
          size_t cIdx = idx - 1;
          ulong valA = a.limbs[cIdx];
          ulong valB = b.limbs[cIdx];
          if (valA > valB)
            {
              cmpRes = 1;
              found = true;
            }
          else
            {
              if (valA < valB)
                {
                  cmpRes = -1;
                  found = true;
                }
            }
        }
      idx = idx - 1;
    }
  return cmpRes;
}

ulong bifAdd(const BigIntFixed a,
             const BigIntFixed b,
             ref BigIntFixed res)
{
  ulong carry = 0;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong valA = a.limbs[idx];
      ulong valB = b.limbs[idx];
      ulong sum1 = valA + valB;
      ulong c1 = 0;
      if (sum1 < valA)
        {
          c1 = 1;
        }
      ulong sum2 = sum1 + carry;
      ulong c2 = 0;
      if (sum2 < sum1)
        {
          c2 = 1;
        }
      res.limbs[idx] = sum2;
      carry = c1 + c2;
      idx = idx + 1;
    }
  return carry;
}

ulong bifSub(const BigIntFixed a,
             const BigIntFixed b,
             ref BigIntFixed res)
{
  ulong borrow = 0;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong valA = a.limbs[idx];
      ulong valB = b.limbs[idx];
      ulong diff1 = valA - valB;
      ulong b1 = 0;
      if (valA < valB)
        {
          b1 = 1;
        }
      ulong diff2 = diff1 - borrow;
      ulong b2 = 0;
      if (diff1 < borrow)
        {
          b2 = 1;
        }
      res.limbs[idx] = diff2;
      borrow = b1 + b2;
      idx = idx + 1;
    }
  return borrow;
}

ulong bifShiftLeft1(const BigIntFixed a, ref BigIntFixed res)
{
  ulong carry = 0;
  size_t idx = 0;
  while (idx < NUM_LIMBS)
    {
      ulong val = a.limbs[idx];
      ulong newCarry = val >> 63;
      res.limbs[idx] = (val << 1) | carry;
      carry = newCarry;
      idx = idx + 1;
    }
  return carry;
}

void bifDivMod(const BigIntFixed a,
               const BigIntFixed b,
               ref BigIntFixed quo,
               ref BigIntFixed rem)
{
  quo = bifZero();
  rem = bifZero();
  size_t lIdx = NUM_LIMBS;
  while (lIdx > 0)
    {
      size_t cIdx = lIdx - 1;
      ulong limbVal = a.limbs[cIdx];
      size_t bitIdx = 64;
      while (bitIdx > 0)
        {
          size_t bShift = bitIdx - 1;
          ulong bitVal = limbVal >> bShift;
          bitVal = bitVal & 1UL;

          ulong c = bifShiftLeft1(rem, rem);
          rem.limbs[0] = rem.limbs[0] | bitVal;

          bifShiftLeft1(quo, quo);

          int cmp = bifCompare(rem, b);
          if (c > 0)
            {
              bifSub(rem, b, rem);
              quo.limbs[0] = quo.limbs[0] | 1UL;
            }
          else
            {
              if (cmp >= 0)
                {
                  bifSub(rem, b, rem);
                  quo.limbs[0] = quo.limbs[0] | 1UL;
                }
            }
          bitIdx = bitIdx - 1;
        }
      lIdx = lIdx - 1;
    }
}

ulong bifModUlong32(const BigIntFixed a, ulong m)
{
  ulong rem = 0;
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      size_t cIdx = idx - 1;
      ulong limbVal = a.limbs[cIdx];
      ulong hiWord = limbVal >> 32;
      ulong loWord = limbVal & 0xFFFFFFFF_UL;

      ulong val1 = (rem << 32) | hiWord;
      rem = val1 % m;

      ulong val2 = (rem << 32) | loWord;
      rem = val2 % m;

      idx = idx - 1;
    }
  return rem;
}

ulong bifModUlong16(const BigIntFixed a, ulong m)
{
  ulong rem = 0;
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      size_t cIdx = idx - 1;
      ulong limbVal = a.limbs[cIdx];
      size_t shiftCount = 64;
      while (shiftCount > 0)
        {
          size_t currentShift = shiftCount - 16;
          ulong w16 = (limbVal >> currentShift) & 0xFFFF_UL;
          ulong val = (rem << 16) | w16;
          rem = val % m;
          shiftCount = shiftCount - 16;
        }
      idx = idx - 1;
    }
  return rem;
}

ulong bifModUlongBit(const BigIntFixed a, ulong m)
{
  ulong rem = 0;
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      size_t cIdx = idx - 1;
      ulong limbVal = a.limbs[cIdx];
      size_t bitIdx = 64;
      while (bitIdx > 0)
        {
          size_t bShift = bitIdx - 1;
          ulong bitVal = limbVal >> bShift;
          bitVal = bitVal & 1UL;
          rem = rem * 2;
          rem = rem + bitVal;
          if (rem >= m)
            {
              rem = rem - m;
            }
          bitIdx = bitIdx - 1;
        }
      idx = idx - 1;
    }
  return rem;
}

ulong bifModUlong(const BigIntFixed a, ulong m)
{
  ulong rem = 0;
  static if (NUM_LIMBS == 1)
    {
      rem = a.limbs[0] % m;
    }
  else
    {
      if (m <= 0xFFFFFFFF_UL)
        {
          rem = bifModUlong32(a, m);
        }
      else if (m <= 0xFFFFFFFFFFFF_UL)
        {
          rem = bifModUlong16(a, m);
        }
      else
        {
          rem = bifModUlongBit(a, m);
        }
    }
  return rem;
}

ulong ulongSqrt(ulong val)
{
  ulong res = 0;
  if (val > 0)
    {
      ulong x0 = val / 2;
      if (x0 == 0)
        {
          x0 = 1;
        }
      bool done = false;
      while (done == false)
        {
          ulong x1 = (x0 + val / x0) / 2;
          if (x1 >= x0)
            {
              res = x0;
              done = true;
            }
          else
            {
              x0 = x1;
            }
        }
    }
  return res;
}

ulong bifSqrt64(const BigIntFixed a)
{
  ulong res = ulong.max;
  bool fits64 = true;
  size_t idx = 1;
  while (idx < NUM_LIMBS)
    {
      if (a.limbs[idx] != 0)
        {
          fits64 = false;
        }
      idx = idx + 1;
    }
  if (fits64 == true)
    {
      res = ulongSqrt(a.limbs[0]);
    }
  return res;
}

bool bifFitsUlong(const BigIntFixed a, ref ulong outVal)
{
  bool fits = true;
  size_t idx = 1;
  while (idx < NUM_LIMBS)
    {
      if (a.limbs[idx] != 0)
        {
          fits = false;
        }
      idx = idx + 1;
    }
  if (fits == true)
    {
      outVal = a.limbs[0];
    }
  return fits;
}

string bifToHexString(const BigIntFixed a)
{
  string res = "0x";
  size_t idx = NUM_LIMBS;
  while (idx > 0)
    {
      size_t cIdx = idx - 1;
      ulong val = a.limbs[cIdx];
      string limbHex = format("%016X", val);
      res = res ~ limbHex;
      idx = idx - 1;
    }
  return res;
}

ubyte parseHexChar(char c)
{
  ubyte val = 0;
  if (c >= '0')
    {
      if (c <= '9')
        {
          val = cast(ubyte)(c - '0');
        }
    }
  if (c >= 'A')
    {
      if (c <= 'F')
        {
          val = cast(ubyte)(10 + c - 'A');
        }
    }
  if (c >= 'a')
    {
      if (c <= 'f')
        {
          val = cast(ubyte)(10 + c - 'a');
        }
    }
  return val;
}

BigIntFixed bifFromHexString(string hexStr)
{
  BigIntFixed res = bifZero();
  string cleanStr = hexStr;
  size_t sLen = cleanStr.length;
  if (sLen >= 2)
    {
      string prefix = cleanStr[0 .. 2];
      if (prefix == "0x")
        {
          cleanStr = cleanStr[2 .. $];
        }
    }
  size_t cLen = cleanStr.length;
  size_t charIdx = cLen;
  size_t limbIdx = 0;
  size_t nibbleIdx = 0;
  while (charIdx > 0)
    {
      if (limbIdx < NUM_LIMBS)
        {
          size_t srcIdx = charIdx - 1;
          char ch = cleanStr[srcIdx];
          ubyte hVal = parseHexChar(ch);
          ulong shiftBits = nibbleIdx * 4;
          ulong shiftedVal = cast(ulong)hVal << shiftBits;
          res.limbs[limbIdx] = res.limbs[limbIdx] | shiftedVal;
          nibbleIdx = nibbleIdx + 1;
          if (nibbleIdx == 16)
            {
              nibbleIdx = 0;
              limbIdx = limbIdx + 1;
            }
        }
      charIdx = charIdx - 1;
    }
  return res;
}

bool testSmallPrimes(const BigIntFixed nVal,
                     ref ulong foundFactor)
{
  static immutable ulong[48] SMALL_PRIMES = [
    2UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL, 23UL, 29UL,
    31UL, 37UL, 41UL, 43UL, 47UL, 53UL, 59UL, 61UL, 67UL, 71UL,
    73UL, 79UL, 83UL, 89UL, 97UL, 101UL, 103UL, 107UL, 109UL, 113UL,
    127UL, 131UL, 137UL, 139UL, 149UL, 151UL, 157UL,
    163UL, 167UL, 173UL,
    179UL, 181UL, 191UL, 193UL, 197UL, 199UL, 211UL, 223UL
  ];

  bool isDivisible = false;
  foundFactor = 0;
  size_t idx = 0;
  while (idx < 48)
    {
      if (isDivisible == false)
        {
          ulong p = SMALL_PRIMES[idx];
          ulong rem = bifModUlong(nVal, p);
          if (rem == 0)
            {
              foundFactor = p;
              isDivisible = true;
            }
        }
      idx = idx + 1;
    }
  return isDivisible;
}

void wheelSearchWorker(const BigIntFixed nVal,
                       ulong startDiv,
                       ulong stride,
                       ulong limitDiv,
                       shared bool* pStop,
                       shared ulong* pFactor)
{
  ulong d = startDiv;
  while (d <= limitDiv)
    {
      bool isStopped = atomicLoad(*pStop);
      if (isStopped == true)
        {
          d = limitDiv + 1;
        }
      else
        {
          ulong rem = bifModUlong(nVal, d);
          if (rem == 0)
            {
              atomicStore(*pFactor, d);
              atomicStore(*pStop, true);
              d = limitDiv + 1;
            }
          else
            {
              d = d + stride;
            }
        }
    }
}

FactorSearchResult parallelFactorSearch(const BigIntFixed n,
                                        ulong maxTrial)
{
  FactorSearchResult result;
  result.found = false;
  result.factor = 0;

  ulong primeFactor = 0;
  bool hasSmallFactor = testSmallPrimes(n, primeFactor);
  if (hasSmallFactor == true)
    {
      result.found = true;
      result.factor = primeFactor;
    }
  else
    {
      ulong sqrtLimit = bifSqrt64(n);
      ulong limitDiv = maxTrial;
      if (sqrtLimit < limitDiv)
        {
          limitDiv = sqrtLimit;
        }

      shared bool stopFlag = false;
      shared ulong sharedFactor = 0;

      static immutable ulong[8] WHEEL_SPOKES = [
        1UL, 7UL, 11UL, 13UL, 17UL, 19UL, 23UL, 29UL
      ];

      size_t nCPUs = totalCPUs;
      if (nCPUs == 0)
        {
          nCPUs = 1;
        }

      TaskPool pool = new TaskPool(nCPUs);
      size_t sIdx = 0;
      while (sIdx < 8)
        {
          ulong spoke = WHEEL_SPOKES[sIdx];
          ulong startD = spoke;
          if (spoke == 1)
            {
              startD = 31;
            }
          ulong strideD = 30;
          auto t = task!wheelSearchWorker(n,
                                          startD,
                                          strideD,
                                          limitDiv,
                                          &stopFlag,
                                          &sharedFactor);
          pool.put(t);
          sIdx = sIdx + 1;
        }
      pool.finish(true);

      ulong fVal = atomicLoad(sharedFactor);
      if (fVal > 0)
        {
          result.found = true;
          result.factor = fVal;
        }
    }
  return result;
}

void extractSmallPrimeFactors(ref BigIntFixed currentN,
                              ref BigIntFixed[] factors)
{
  static immutable ulong[48] SMALL_PRIMES = [
    2UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL, 23UL, 29UL,
    31UL, 37UL, 41UL, 43UL, 47UL, 53UL, 59UL, 61UL, 67UL, 71UL,
    73UL, 79UL, 83UL, 89UL, 97UL, 101UL, 103UL, 107UL, 109UL,
    113UL, 127UL, 131UL, 137UL, 139UL, 149UL, 151UL, 157UL,
    163UL, 167UL, 173UL, 179UL, 181UL, 191UL, 193UL, 197UL,
    199UL, 211UL, 223UL
  ];

  size_t spIdx = 0;
  while (spIdx < 48)
    {
      ulong p = SMALL_PRIMES[spIdx];
      bool keepDividing = true;
      while (keepDividing == true)
        {
          ulong remP = bifModUlong(currentN, p);
          if (remP == 0)
            {
              factors ~= bifFromUlong(p);
              BigIntFixed pBif = bifFromUlong(p);
              BigIntFixed quoBif = bifZero();
              BigIntFixed remBif = bifZero();
              bifDivMod(currentN, pBif, quoBif, remBif);
              currentN = quoBif;
            }
          else
            {
              keepDividing = false;
            }
        }
      spIdx = spIdx + 1;
    }
}

PrimeFactorizationResult parallelPrimeFactorization(
  const BigIntFixed nInput,
  ulong maxTrial)
{
  PrimeFactorizationResult result;
  result.complete = false;

  BigIntFixed currentN = nInput;
  BigIntFixed zeroVal = bifZero();
  int cmpZero = bifCompare(currentN, zeroVal);

  if (cmpZero > 0)
    {
      bool isOne = bifIsOne(currentN);
      if (isOne == true)
        {
          result.complete = true;
        }
      else
        {
          extractSmallPrimeFactors(currentN, result.factors);

          bool done = bifIsOne(currentN);
          while (done == false)
            {
              FactorSearchResult searchRes =
                parallelFactorSearch(currentN, maxTrial);

              if (searchRes.found == true)
                {
                  ulong fVal = searchRes.factor;
                  result.factors ~= bifFromUlong(fVal);
                  BigIntFixed fBif = bifFromUlong(fVal);
                  BigIntFixed quoBif = bifZero();
                  BigIntFixed remBif = bifZero();
                  bifDivMod(currentN, fBif, quoBif, remBif);
                  currentN = quoBif;
                  done = bifIsOne(currentN);
                }
              else
                {
                  result.factors ~= currentN;
                  done = true;
                }
            }
          result.complete = true;
        }
    }
  return result;
}

version (standalone)
{
  int main(string[] args)
  {
    int exitCode = 0;
    writeln("==================================================");
    writeln("  Parallel Fast Prime Factorization Engine");
    writeln("  Precision Mode : ", PRECISION_NAME);
    writeln("==================================================");

    size_t argLen = args.length;
    if (argLen < 2)
      {
        writeln("Usage: ", args[0], " <number_in_hex>");
        writeln("Example: ", args[0], " 0x000000003B9ADAD1");
        exitCode = 1;
      }
    else
      {
        string inputStr = args[1];
        BigIntFixed val = bifFromHexString(inputStr);
        writeln("Input Number (Hex) : ", bifToHexString(val));

        ulong maxTrial = ulong.max;
        StopWatch sw;
        sw.start();
        PrimeFactorizationResult res =
          parallelPrimeFactorization(val, maxTrial);
        sw.stop();

        double elapsedMs = sw.peek().total!"msecs" ();
        writeln("----------------------------------------");
        writeln("Prime Factors Found (",
                res.factors.length, " total):");
        size_t fIdx = 0;
        while (fIdx < res.factors.length)
          {
            BigIntFixed fVal = res.factors[fIdx];
            ulong decVal = 0;
            bool fits64 = bifFitsUlong(fVal, decVal);
            if (fits64 == true)
              {
                writeln("  Factor [", fIdx + 1, "] : ",
                        bifToHexString(fVal),
                        " (Dec: ", decVal, ")");
              }
            else
              {
                writeln("  Factor [", fIdx + 1, "] : ",
                        bifToHexString(fVal));
              }
            fIdx = fIdx + 1;
          }
        writeln("----------------------------------------");
        writeln("Factorization Time (ms) : ", elapsedMs);
      }
    return exitCode;
  }
}
else
  version (demo)
  {
    void runFactorizationDemo()
    {
      writeln("==================================================");
      writeln("  Parallel Prime Factorization Engine Demo");
      writeln("  Precision Mode : ", PRECISION_NAME);
      writeln("==================================================");

      string testHex = "0x000000E8D50A1FA3";
      BigIntFixed val = bifFromHexString(testHex);
      string valHex = bifToHexString(val);
      writeln("Target Number (Hex) : ", valHex);

      ulong maxTrial = ulong.max;
      StopWatch sw;
      sw.start();
      PrimeFactorizationResult res =
        parallelPrimeFactorization(val, maxTrial);
      sw.stop();

      double elapsedMs = sw.peek().total!"msecs" ();
      writeln("----------------------------------------");
      writeln("Prime Factors Found (",
              res.factors.length, " total):");
      size_t fIdx = 0;
      while (fIdx < res.factors.length)
        {
          BigIntFixed fVal = res.factors[fIdx];
          ulong decVal = 0;
          bool fits64 = bifFitsUlong(fVal, decVal);
          if (fits64 == true)
            {
              writeln("  Factor [", fIdx + 1, "] : ",
                      bifToHexString(fVal),
                      " (Dec: ", decVal, ")");
            }
          else
            {
              writeln("  Factor [", fIdx + 1, "] : ",
                      bifToHexString(fVal));
            }
          fIdx = fIdx + 1;
        }
      writeln("----------------------------------------");
      writeln("Factorization Time (ms) : ", elapsedMs);
    }

    int main(string[] args)
    {
      runFactorizationDemo();
      return 0;
    }
  }
