/*********************************************************************
 * Fast Parallel Semiprime Factorization Engine Module
 *
 * Implements parallel semiprime factorization N = p * q using
 * multi-limb modular arithmetic algorithms including:
 *   - Primorial product and small prime pre-screening
 *   - Pollard's p - 1 smoothness exponent search
 *   - Parallel Pollard's rho with multiple polynomial seeds
 *   - Parallel Fermat quadratic difference search
 *   - Wheel-30 factor testing fallback
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

module semiprime_factorization;

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
else version (LIMB_256)
{
    enum size_t NUM_LIMBS = 4;
    enum string PRECISION_NAME = "256-bit";
}
else version (LIMB_128)
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

struct SemiprimeFactorResult
{
    bool found;
    ulong factor1;
    ulong factor2;
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
        ulong nextCarry = val >> 63;
        ulong shifted = val << 1;
        shifted = shifted | carry;
        res.limbs[idx] = shifted;
        carry = nextCarry;
        idx = idx + 1;
    }
    return carry;
}

void bifShiftRight1(const BigIntFixed a, ref BigIntFixed res)
{
    ulong carry = 0;
    size_t idx = NUM_LIMBS;
    while (idx > 0)
    {
        size_t cIdx = idx - 1;
        ulong val = a.limbs[cIdx];
        ulong nextCarry = val & 1UL;
        nextCarry = nextCarry << 63;
        ulong shifted = val >> 1;
        shifted = shifted | carry;
        res.limbs[cIdx] = shifted;
        carry = nextCarry;
        idx = idx - 1;
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

void bifMod(const BigIntFixed a,
            const BigIntFixed b,
            ref BigIntFixed rem)
{
    BigIntFixed dummyQuo = bifZero();
    bifDivMod(a, b, dummyQuo, rem);
}

void bifGcd(const BigIntFixed a,
            const BigIntFixed b,
            ref BigIntFixed gcdRes)
{
    BigIntFixed x = a;
    BigIntFixed y = b;
    BigIntFixed tempRem = bifZero();
    bool done = false;
    while (done == false)
    {
        bool isZ = bifIsZero(y);
        if (isZ == true)
        {
            gcdRes = x;
            done = true;
        }
        else
        {
            bifMod(x, y, tempRem);
            x = y;
            y = tempRem;
        }
    }
}

void bifMulMod(const BigIntFixed a,
               const BigIntFixed b,
               const BigIntFixed m,
               ref BigIntFixed res)
{
    res = bifZero();
    BigIntFixed x = bifZero();
    bifMod(a, m, x);
    BigIntFixed y = b;

    bool done = false;
    while (done == false)
    {
        bool isZ = bifIsZero(y);
        if (isZ == true)
        {
            done = true;
        }
        else
        {
            bool isEv = bifIsEven(y);
            if (isEv == false)
            {
                BigIntFixed sumVal = bifZero();
                ulong c = bifAdd(res, x, sumVal);
                int cmp = bifCompare(sumVal, m);
                if (c > 0)
                {
                    bifSub(sumVal, m, sumVal);
                }
                else
                {
                    if (cmp >= 0)
                    {
                        bifSub(sumVal, m, sumVal);
                    }
                }
                res = sumVal;
            }

            BigIntFixed doubleX = bifZero();
            ulong cX = bifAdd(x, x, doubleX);
            int cmpX = bifCompare(doubleX, m);
            if (cX > 0)
            {
                bifSub(doubleX, m, doubleX);
            }
            else
            {
                if (cmpX >= 0)
                {
                    bifSub(doubleX, m, doubleX);
                }
            }
            x = doubleX;
            bifShiftRight1(y, y);
        }
    }
}

void bifModPow(const BigIntFixed baseVal,
               const BigIntFixed expVal,
               const BigIntFixed modVal,
               ref BigIntFixed res)
{
    res = bifFromUlong(1);
    BigIntFixed b = bifZero();
    bifMod(baseVal, modVal, b);
    BigIntFixed e = expVal;

    bool done = false;
    while (done == false)
    {
        bool isZ = bifIsZero(e);
        if (isZ == true)
        {
            done = true;
        }
        else
        {
            bool isEv = bifIsEven(e);
            if (isEv == false)
            {
                bifMulMod(res, b, modVal, res);
            }
            bifMulMod(b, b, modVal, b);
            bifShiftRight1(e, e);
        }
    }
}

void bifSqrt(const BigIntFixed a, ref BigIntFixed res)
{
    bool isZ = bifIsZero(a);
    if (isZ == true)
    {
        res = bifZero();
    }
    else
    {
        BigIntFixed low = bifFromUlong(1);
        BigIntFixed high = a;
        BigIntFixed ans = bifFromUlong(1);

        bool done = false;
        while (done == false)
        {
            int cmp = bifCompare(low, high);
            if (cmp > 0)
            {
                done = true;
            }
            else
            {
                BigIntFixed mid = bifZero();
                BigIntFixed sumLH = bifZero();
                bifAdd(low, high, sumLH);
                bifShiftRight1(sumLH, mid);

                BigIntFixed quo = bifZero();
                BigIntFixed rem = bifZero();
                bifDivMod(a, mid, quo, rem);

                int cmpMQ = bifCompare(mid, quo);
                if (cmpMQ <= 0)
                {
                    ans = mid;
                    bifAdd(mid, bifFromUlong(1), low);
                }
                else
                {
                    bifSub(mid, bifFromUlong(1), high);
                }
            }
        }
        res = ans;
    }
}

ulong ulongGcd(ulong a, ulong b)
{
    ulong x = a;
    ulong y = b;
    while (y > 0)
    {
        ulong t = x % y;
        x = y;
        y = t;
    }
    return x;
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

ulong mulModUlong(ulong a, ulong b, ulong m)
{
    ulong res = 0;
    ulong x = a % m;
    ulong y = b;
    while (y > 0)
    {
        ulong rem = y % 2;
        if (rem == 1)
        {
            res = (res + x) % m;
        }
        x = (x * 2) % m;
        y = y / 2;
    }
    return res;
}

ulong modPow(ulong baseVal, ulong expVal, ulong modVal)
{
    ulong res = 1;
    ulong b = baseVal % modVal;
    ulong e = expVal;
    while (e > 0)
    {
        ulong rem = e % 2;
        if (rem == 1)
        {
            res = mulModUlong(res, b, modVal);
        }
        b = mulModUlong(b, b, modVal);
        e = e / 2;
    }
    return res;
}

bool isQuadResidue64(ulong val)
{
    ulong r = val % 64;
    static immutable ulong MASK_LO =
        (1UL << 0)  | (1UL << 1)  | (1UL << 4)  | (1UL << 9)  |
        (1UL << 16) | (1UL << 17) | (1UL << 25);
    static immutable ulong MASK_HI =
        (1UL << (33 - 32)) | (1UL << (36 - 32)) |
        (1UL << (41 - 32)) | (1UL << (49 - 32)) |
        (1UL << (57 - 32));

    bool isRes = false;
    if (r < 32)
    {
        ulong bit = (MASK_LO >> r) & 1UL;
        if (bit != 0)
        {
            isRes = true;
        }
    }
    else
    {
        ulong shiftR = r - 32;
        ulong bit = (MASK_HI >> shiftR) & 1UL;
        if (bit != 0)
        {
            isRes = true;
        }
    }
    return isRes;
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

void pollardP1Worker(ulong n64,
                      ulong boundB,
                      ulong baseA,
                      shared bool* pStop,
                      shared ulong* pFactor)
{
    static immutable ulong[25] PRIMES_P1 = [
        2UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL, 23UL, 29UL,
        31UL, 37UL, 41UL, 43UL, 47UL, 53UL, 59UL, 61UL, 67UL, 71UL,
        73UL, 79UL, 83UL, 89UL, 97UL
    ];

    ulong a = baseA;
    size_t idx = 0;
    bool done = false;

    while (idx < 25)
    {
        if (done == false)
        {
            bool isStopped = atomicLoad(*pStop);
            if (isStopped == true)
            {
                done = true;
            }
            else
            {
                ulong q = PRIMES_P1[idx];
                ulong qk = q;
                while (qk * q <= boundB)
                {
                    qk = qk * q;
                }
                a = modPow(a, qk, n64);
                ulong diff = 0;
                if (a >= 1)
                {
                    diff = a - 1;
                }
                else
                {
                    diff = n64 - 1;
                }
                ulong g = ulongGcd(diff, n64);
                if (g > 1)
                {
                    if (g < n64)
                    {
                        atomicStore(*pFactor, g);
                        atomicStore(*pStop, true);
                        done = true;
                    }
                }
                idx = idx + 1;
            }
        }
        else
        {
            idx = 25;
        }
    }
}

void pollardRhoWorker(ulong n64,
                      ulong seedC,
                      ulong startX,
                      ulong maxSteps,
                      shared bool* pStop,
                      shared ulong* pFactor)
{
    ulong x = startX;
    ulong y = startX;
    ulong d = 1;
    ulong step = 0;

    while (step < maxSteps)
    {
        bool isStopped = atomicLoad(*pStop);
        if (isStopped == true)
        {
            step = maxSteps;
        }
        else
        {
            ulong x2 = mulModUlong(x, x, n64);
            x = (x2 + seedC) % n64;

            ulong y2a = mulModUlong(y, y, n64);
            ulong y1 = (y2a + seedC) % n64;
            ulong y2b = mulModUlong(y1, y1, n64);
            y = (y2b + seedC) % n64;

            ulong diff = 0;
            if (x >= y)
            {
                diff = x - y;
            }
            else
            {
                diff = y - x;
            }

            d = ulongGcd(diff, n64);
            if (d > 1)
            {
                if (d < n64)
                {
                    atomicStore(*pFactor, d);
                    atomicStore(*pStop, true);
                    step = maxSteps;
                }
            }
            step = step + 1;
        }
    }
}

void fermatWorker(ulong n64,
                  ulong startA,
                  ulong stride,
                  ulong maxSteps,
                  shared bool* pStop,
                  shared ulong* pFactor)
{
    ulong a = startA;
    ulong step = 0;

    while (step < maxSteps)
    {
        bool isStopped = atomicLoad(*pStop);
        if (isStopped == true)
        {
            step = maxSteps;
        }
        else
        {
            ulong a2 = a * a;
            if (a2 >= n64)
            {
                ulong b2 = a2 - n64;
                bool isQR = isQuadResidue64(b2);
                if (isQR == true)
                {
                    ulong b = ulongSqrt(b2);
                    if (b * b == b2)
                    {
                        ulong p = a - b;
                        if (p > 1)
                        {
                            if (p < n64)
                            {
                                atomicStore(*pFactor, p);
                                atomicStore(*pStop, true);
                                step = maxSteps;
                            }
                        }
                    }
                }
            }
            a = a + stride;
            step = step + 1;
        }
    }
}

void pollardP1WorkerBif(const BigIntFixed nBif,
                        ulong boundB,
                        ulong baseA,
                        shared bool* pStop,
                        shared ulong* pSharedLimbs)
{
    static immutable ulong[25] PRIMES_P1 = [
        2UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL, 23UL, 29UL,
        31UL, 37UL, 41UL, 43UL, 47UL, 53UL, 59UL, 61UL, 67UL, 71UL,
        73UL, 79UL, 83UL, 89UL, 97UL
    ];

    BigIntFixed a = bifFromUlong(baseA);
    size_t idx = 0;
    bool done = false;

    while (idx < 25)
    {
        if (done == false)
        {
            bool isStopped = atomicLoad(*pStop);
            if (isStopped == true)
            {
                done = true;
            }
            else
            {
                ulong q = PRIMES_P1[idx];
                ulong qk = q;
                while (qk * q <= boundB)
                {
                    qk = qk * q;
                }
                BigIntFixed qkBif = bifFromUlong(qk);
                bifModPow(a, qkBif, nBif, a);

                BigIntFixed diff = bifZero();
                int cmpA1 = bifCompare(a, bifFromUlong(1));
                if (cmpA1 >= 0)
                {
                    bifSub(a, bifFromUlong(1), diff);
                }
                else
                {
                    bifSub(nBif, bifFromUlong(1), diff);
                }

                BigIntFixed g = bifZero();
                bifGcd(diff, nBif, g);

                bool isGOne = bifIsOne(g);
                bool isGEqualN = (bifCompare(g, nBif) == 0);

                if (isGOne == false)
                {
                    if (isGEqualN == false)
                    {
                        size_t lIdx = 0;
                        while (lIdx < NUM_LIMBS)
                        {
                            pSharedLimbs[lIdx] = g.limbs[lIdx];
                            lIdx = lIdx + 1;
                        }
                        atomicStore(*pStop, true);
                        done = true;
                    }
                }
                idx = idx + 1;
            }
        }
        else
        {
            idx = 25;
        }
    }
}

void pollardRhoWorkerBif(const BigIntFixed nBif,
                         ulong seedC,
                         ulong startX,
                         ulong maxSteps,
                         shared bool* pStop,
                         shared ulong* pSharedLimbs)
{
    BigIntFixed x = bifFromUlong(startX);
    BigIntFixed y = bifFromUlong(startX);
    BigIntFixed cBif = bifFromUlong(seedC);
    BigIntFixed d = bifFromUlong(1);
    ulong step = 0;

    while (step < maxSteps)
    {
        bool isStopped = atomicLoad(*pStop);
        if (isStopped == true)
        {
            step = maxSteps;
        }
        else
        {
            BigIntFixed x2 = bifZero();
            bifMulMod(x, x, nBif, x2);
            BigIntFixed sumX = bifZero();
            bifAdd(x2, cBif, sumX);
            bifMod(sumX, nBif, x);

            BigIntFixed y2a = bifZero();
            bifMulMod(y, y, nBif, y2a);
            BigIntFixed sumY1 = bifZero();
            bifAdd(y2a, cBif, sumY1);
            BigIntFixed y1 = bifZero();
            bifMod(sumY1, nBif, y1);

            BigIntFixed y2b = bifZero();
            bifMulMod(y1, y1, nBif, y2b);
            BigIntFixed sumY2 = bifZero();
            bifAdd(y2b, cBif, sumY2);
            bifMod(sumY2, nBif, y);

            BigIntFixed diff = bifZero();
            int cmpXY = bifCompare(x, y);
            if (cmpXY >= 0)
            {
                bifSub(x, y, diff);
            }
            else
            {
                bifSub(y, x, diff);
            }

            bifGcd(diff, nBif, d);
            bool isDOne = bifIsOne(d);
            bool isDEqualN = (bifCompare(d, nBif) == 0);

            if (isDOne == false)
            {
                if (isDEqualN == false)
                {
                    size_t lIdx = 0;
                    while (lIdx < NUM_LIMBS)
                    {
                        pSharedLimbs[lIdx] = d.limbs[lIdx];
                        lIdx = lIdx + 1;
                    }
                    atomicStore(*pStop, true);
                    step = maxSteps;
                }
            }
            step = step + 1;
        }
    }
}

void fermatWorkerBif(const BigIntFixed nBif,
                     const BigIntFixed startA,
                     ulong stride,
                     ulong maxSteps,
                     shared bool* pStop,
                     shared ulong* pSharedLimbs)
{
    BigIntFixed a = startA;
    BigIntFixed strideBif = bifFromUlong(stride);
    ulong step = 0;

    while (step < maxSteps)
    {
        bool isStopped = atomicLoad(*pStop);
        if (isStopped == true)
        {
            step = maxSteps;
        }
        else
        {
            BigIntFixed a2 = bifZero();
            bifMulMod(a, a, nBif, a2);
            BigIntFixed b2 = a2;

            BigIntFixed b = bifZero();
            bifSqrt(b2, b);

            BigIntFixed bSq = bifZero();
            bifMulMod(b, b, nBif, bSq);

            int cmpBSq = bifCompare(bSq, b2);
            if (cmpBSq == 0)
            {
                BigIntFixed pFactor = bifZero();
                bifSub(a, b, pFactor);

                bool isP1 = bifIsOne(pFactor);
                bool isPEqualN = (bifCompare(pFactor, nBif) == 0);
                if (isP1 == false)
                {
                    if (isPEqualN == false)
                    {
                        size_t lIdx = 0;
                        while (lIdx < NUM_LIMBS)
                        {
                            pSharedLimbs[lIdx] = pFactor.limbs[lIdx];
                            lIdx = lIdx + 1;
                        }
                        atomicStore(*pStop, true);
                        step = maxSteps;
                    }
                }
            }

            bifAdd(a, strideBif, a);
            step = step + 1;
        }
    }
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

SemiprimeFactorResult parallelSemiprimeFactorization(
    const BigIntFixed n,
    ulong maxSteps)
{
    SemiprimeFactorResult result;
    result.found = false;
    result.factor1 = 0;
    result.factor2 = 0;

    ulong smallFactor = 0;
    bool hasSmall = testSmallPrimes(n, smallFactor);
    if (hasSmall == true)
    {
        result.found = true;
        result.factor1 = smallFactor;
        ulong remFactor = bifModUlong(n, smallFactor);
        result.factor2 = remFactor;
    }
    else
    {
        shared bool stopFlag = false;
        ulong n64 = 0;
        bool fits64 = bifFitsUlong(n, n64);

        if (fits64 == true)
        {
            shared ulong sharedFactor = 0;
            size_t nCPUs = totalCPUs;
            if (nCPUs == 0)
            {
                nCPUs = 1;
            }

            TaskPool pool = new TaskPool(nCPUs);
            ulong sqrtN = ulongSqrt(n64);
            ulong a0 = sqrtN;
            if (a0 * a0 < n64)
            {
                a0 = a0 + 1;
            }

            static immutable ulong[8] SEEDS_C = [
                1UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL
            ];

            size_t tIdx = 0;
            while (tIdx < nCPUs)
            {
                if (tIdx == 0)
                {
                    auto tP1 = task!pollardP1Worker(
                        n64, 10000UL, 2UL,
                        &stopFlag, &sharedFactor);
                    pool.put(tP1);
                }
                else if (tIdx < 4)
                {
                    ulong seedC = SEEDS_C[tIdx];
                    ulong startX = 2 + tIdx;
                    auto tRho = task!pollardRhoWorker(
                        n64, seedC, startX, maxSteps,
                        &stopFlag, &sharedFactor);
                    pool.put(tRho);
                }
                else
                {
                    ulong offsetA = tIdx - 4;
                    ulong startA = a0 + offsetA;
                    ulong strideA = nCPUs - 4;
                    if (strideA == 0)
                    {
                        strideA = 1;
                    }
                    auto tFerm = task!fermatWorker(
                        n64, startA, strideA, maxSteps,
                        &stopFlag, &sharedFactor);
                    pool.put(tFerm);
                }
                tIdx = tIdx + 1;
            }
            pool.finish(true);

            ulong fVal = atomicLoad(sharedFactor);
            if (fVal > 1)
            {
                if (fVal < n64)
                {
                    result.found = true;
                    result.factor1 = fVal;
                    result.factor2 = n64 / fVal;
                }
            }
        }
        else
        {
            shared ulong[NUM_LIMBS] sharedLimbs;
            size_t lIdx = 0;
            while (lIdx < NUM_LIMBS)
            {
                sharedLimbs[lIdx] = 0;
                lIdx = lIdx + 1;
            }

            size_t nCPUs = totalCPUs;
            if (nCPUs == 0)
            {
                nCPUs = 1;
            }

            TaskPool pool = new TaskPool(nCPUs);
            BigIntFixed sqrtN = bifZero();
            bifSqrt(n, sqrtN);

            BigIntFixed a0 = sqrtN;
            BigIntFixed sqTest = bifZero();
            bifMulMod(sqrtN, sqrtN, n, sqTest);
            if (bifIsZero(sqTest) == false)
            {
                bifAdd(a0, bifFromUlong(1), a0);
            }

            static immutable ulong[8] SEEDS_C = [
                1UL, 3UL, 5UL, 7UL, 11UL, 13UL, 17UL, 19UL
            ];

            size_t tIdx = 0;
            while (tIdx < nCPUs)
            {
                if (tIdx == 0)
                {
                    auto tP1 = task!pollardP1WorkerBif(
                        n, 10000UL, 2UL,
                        &stopFlag, sharedLimbs.ptr);
                    pool.put(tP1);
                }
                else if (tIdx < 4)
                {
                    ulong seedC = SEEDS_C[tIdx];
                    ulong startX = 2 + tIdx;
                    auto tRho = task!pollardRhoWorkerBif(
                        n, seedC, startX, maxSteps,
                        &stopFlag, sharedLimbs.ptr);
                    pool.put(tRho);
                }
                else
                {
                    ulong offsetA = tIdx - 4;
                    BigIntFixed startA = bifZero();
                    bifAdd(a0, bifFromUlong(offsetA), startA);
                    ulong strideA = nCPUs - 4;
                    if (strideA == 0)
                    {
                        strideA = 1;
                    }
                    auto tFerm = task!fermatWorkerBif(
                        n, startA, strideA, maxSteps,
                        &stopFlag, sharedLimbs.ptr);
                    pool.put(tFerm);
                }
                tIdx = tIdx + 1;
            }
            pool.finish(true);

            BigIntFixed fVal = bifZero();
            size_t idx = 0;
            while (idx < NUM_LIMBS)
            {
                fVal.limbs[idx] = sharedLimbs[idx];
                idx = idx + 1;
            }

            bool isFZero = bifIsZero(fVal);
            bool isFOne = bifIsOne(fVal);
            if (isFZero == false)
            {
                if (isFOne == false)
                {
                    result.found = true;
                    ulong outU = 0;
                    bool fFits = bifFitsUlong(fVal, outU);
                    if (fFits == true)
                    {
                        result.factor1 = outU;
                    }
                    else
                    {
                        result.factor1 = fVal.limbs[0];
                    }

                    BigIntFixed qVal = bifZero();
                    BigIntFixed remVal = bifZero();
                    bifDivMod(n, fVal, qVal, remVal);

                    ulong qOut = 0;
                    bool qFits = bifFitsUlong(qVal, qOut);
                    if (qFits == true)
                    {
                        result.factor2 = qOut;
                    }
                    else
                    {
                        result.factor2 = qVal.limbs[0];
                    }
                }
            }
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
        writeln("  Parallel Semiprime Factorization Engine");
        writeln("  Precision Mode : ", PRECISION_NAME);
        writeln("==================================================");

        size_t argLen = args.length;
        if (argLen < 2)
        {
            writeln("Usage: ", args[0], " <semiprime_in_hex>");
            writeln("Example: ", args[0], " 0x000000E8D50A1FA3");
            exitCode = 1;
        }
        else
        {
            string inputStr = args[1];
            BigIntFixed val = bifFromHexString(inputStr);
            writeln("Input Semiprime (Hex) : ", bifToHexString(val));

            ulong maxSteps = 10000000UL;
            StopWatch sw;
            sw.start();
            SemiprimeFactorResult res =
                parallelSemiprimeFactorization(val, maxSteps);
            sw.stop();

            double elapsedMs = sw.peek().total!"msecs"();
            if (res.found == true)
            {
                writeln("Factor p            : ", res.factor1);
                if (res.factor2 > 0)
                {
                    writeln("Factor q            : ", res.factor2);
                }
                writeln("Factorization Time  : ", elapsedMs, " ms");
            }
            else
            {
                writeln("No factorization found up to max steps.");
                writeln("Search Time (ms)    : ", elapsedMs);
            }
        }
        return exitCode;
    }
}
else version (demo)
{
    void runSemiprimeDemo()
    {
        writeln("==================================================");
        writeln("  Parallel Semiprime Factorization Demonstration");
        writeln("  Precision Mode : ", PRECISION_NAME);
        writeln("==================================================");

        string testHex = "0x000000E8D50A1FA3";
        BigIntFixed val = bifFromHexString(testHex);
        string valHex = bifToHexString(val);
        writeln("Target Semiprime (Hex) : ", valHex);

        ulong maxSteps = 10000000UL;
        StopWatch sw;
        sw.start();
        SemiprimeFactorResult res =
            parallelSemiprimeFactorization(val, maxSteps);
        sw.stop();

        double elapsedMs = sw.peek().total!"msecs"();
        if (res.found == true)
        {
            writeln("Factor p               : ", res.factor1);
            if (res.factor2 > 0)
            {
                writeln("Factor q               : ", res.factor2);
            }
            writeln("Factorization Time     : ", elapsedMs, " ms");
        }
        else
        {
            writeln("No factorization found up to max steps.");
            writeln("Search Time (ms)       : ", elapsedMs);
        }
    }

    int main(string[] args)
    {
        runSemiprimeDemo();
        return 0;
    }
}
