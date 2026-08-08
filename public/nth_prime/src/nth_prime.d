module nth_prime;

import std.bigint : BigInt;
import core.int128 : Cent;
import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memset;
import core.bitop : popcnt;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;
import std.parallelism : parallel;

version (LIMBS_128) {
    enum size_t NUM_LIMBS = 2;
} else version (LIMBS_256) {
    enum size_t NUM_LIMBS = 4;
} else version (LIMBS_512) {
    enum size_t NUM_LIMBS = 8;
} else version (LIMBS_1024) {
    enum size_t NUM_LIMBS = 16;
} else version (LIMBS_2048) {
    enum size_t NUM_LIMBS = 32;
} else version (LIMBS_4096) {
    enum size_t NUM_LIMBS = 64;
} else version (LIMBS_8192) {
    enum size_t NUM_LIMBS = 128;
} else {
    enum size_t NUM_LIMBS = 128;
}

struct LimbNumber {
    ulong[NUM_LIMBS] limbs;
}

alias u64 = ulong;

struct MemoEntry {
    u64 x;
    uint a;
    u64 res;
}

enum CACHE_SIZE = 1048576;
enum CACHE_MASK = CACHE_SIZE - 1;

__gshared MemoEntry[CACHE_SIZE] memoTable;

__gshared ushort[30030] phi6Table;
__gshared bool phi6Initialized = false;

__gshared u64[] isSubprimeBit;
__gshared uint[] popCntBlock;
__gshared u64 sieveMax = 0;

void initPhi6Table() {
    if (!phi6Initialized) {
        ushort count = 0;
        size_t i = 0;
        while (i < 30030) {
            if (i > 0) {
                if (i % 2 != 0 && i % 3 != 0 &&
                    i % 5 != 0 && i % 7 != 0 &&
                    i % 11 != 0 && i % 13 != 0) {
                    count = cast(ushort) (count + 1);
                }
            }
            phi6Table[i] = count;
            i = i + 1;
        }
        phi6Initialized = true;
    }
}

u64 phi6(u64 x) {
    initPhi6Table();
    u64 q = x / 30030;
    u64 r = x % 30030;
    u64 ans = q * 5760;
    ans = ans + phi6Table[cast(size_t) r];
    return ans;
}

void buildBitSieve(u64 limit) {
    sieveMax = limit;
    u64 numOdds = limit / 2;
    size_t numWords = cast(size_t) (numOdds / 64 + 1);

    isSubprimeBit = new u64[](numWords);
    size_t wIdx = 0;
    while (wIdx < numWords) {
        isSubprimeBit[wIdx] = 0xFFFFFFFFFFFFFFFFUL;
        wIdx = wIdx + 1;
    }
    isSubprimeBit[0] = isSubprimeBit[0] & ~1UL;

    double fLim = cast(double) limit;
    u64 sqrtLim = cast(u64) sqrt(fLim);
    u64 p = 3;
    while (p <= sqrtLim) {
        u64 k = (p - 1) / 2;
        size_t wI = cast(size_t) (k / 64);
        size_t rI = cast(size_t) (k % 64);
        u64 mask = 1UL << rI;
        if ((isSubprimeBit[wI] & mask) != 0) {
            u64 mult = p * p;
            while (mult <= limit) {
                u64 mK = (mult - 1) / 2;
                size_t mW = cast(size_t) (mK / 64);
                size_t mR = cast(size_t) (mK % 64);
                u64 clearMask = ~(1UL << mR);
                isSubprimeBit[mW] = isSubprimeBit[mW] & clearMask;
                mult = mult + p + p;
            }
        }
        p = p + 2;
    }

    popCntBlock = new uint[](numWords);
    popCntBlock[0] = 1;
    size_t b = 0;
    while (b + 1 < numWords) {
        u64 wordVal = isSubprimeBit[b];
        int bitCnt = cast(int) popcnt(wordVal);
        uint prev = popCntBlock[b];
        popCntBlock[b + 1] = cast(uint) (prev + bitCnt);
        b = b + 1;
    }
}

bool isPrimeBit(u64 val) {
    bool res = false;
    if (val >= 2 && val <= sieveMax) {
        if (val == 2) {
            res = true;
        } else if (val % 2 != 0) {
            u64 k = (val - 1) / 2;
            size_t wordIdx = cast(size_t) (k / 64);
            size_t bitIdx = cast(size_t) (k % 64);
            u64 mask = 1UL << bitIdx;
            res = (isSubprimeBit[wordIdx] & mask) != 0;
        }
    }
    return res;
}

uint[] collectPrimesUpTo(u64 maxVal) {
    size_t count = 0;
    u64 p = 2;
    while (p <= maxVal) {
        if (p == 2 || (p % 2 != 0 && isPrimeBit(p))) {
            count = count + 1;
        }
        p = p + 1;
    }
    uint[] res = new uint[](count);
    size_t idx = 0;
    p = 2;
    while (p <= maxVal) {
        if (p == 2 || (p % 2 != 0 && isPrimeBit(p))) {
            res[idx] = cast(uint) p;
            idx = idx + 1;
        }
        p = p + 1;
    }
    return res;
}

u64 piFast(u64 w, const(uint)[] primes) {
    u64 count = 0;
    if (w < 2) {
        count = 0;
    } else if (w == 2) {
        count = 1;
    } else if (w <= sieveMax) {
        u64 k = (w - 1) / 2;
        size_t wordIdx = cast(size_t) (k / 64);
        size_t bitIdx = cast(size_t) (k % 64);

        uint baseCnt = popCntBlock[wordIdx];
        u64 curWord = isSubprimeBit[wordIdx];
        u64 mask = (1UL << bitIdx) | ((1UL << bitIdx) - 1UL);
        u64 maskedWord = curWord & mask;
        int subCnt = cast(int) popcnt(maskedWord);

        count = cast(u64) (baseCnt + subCnt);
    } else {
        size_t low = 0;
        size_t high = primes.length;
        while (low < high) {
            size_t mid = (low + high) / 2;
            if (cast(u64) primes[mid] <= w) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        count = cast(u64) low;
    }
    return count;
}

u64 phiRec(u64 x, size_t a, const(uint)[] primes) {
    u64 result = 0;
    if (a == 0) {
        result = x;
    } else if (a == 6) {
        result = phi6(x);
    } else if (x == 0) {
        result = 0;
    } else {
        u64 key = (x ^ (cast(u64) a * 0x9e3779b97f4a7c15UL));
        size_t slot = cast(size_t) (key & CACHE_MASK);
        if (memoTable[slot].x == x && memoTable[slot].a == a) {
            result = memoTable[slot].res;
        } else {
            u64 p = cast(u64) primes[a - 1];
            if (x < p) {
                result = 1;
            } else if (x <= sieveMax) {
                u64 p6 = cast(u64) primes[5];
                if (x <= p6 * p) {
                    u64 piX = piFast(x, primes);
                    u64 castA = cast(u64) a;
                    result = piX - castA + 1;
                } else {
                    u64 term1 = phiRec(x, a - 1, primes);
                    u64 term2 = phiRec(x / p, a - 1, primes);
                    result = term1 - term2;
                }
            } else {
                u64 term1 = phiRec(x, a - 1, primes);
                u64 term2 = phiRec(x / p, a - 1, primes);
                result = term1 - term2;
            }
            memoTable[slot].x = x;
            memoTable[slot].a = cast(uint) a;
            memoTable[slot].res = result;
        }
    }
    return result;
}

u64 primeCountLehmer(u64 x, const(uint)[] primes) {
    u64 count = 0;
    if (x < 2) {
        count = 0;
    } else if (x <= sieveMax) {
        count = piFast(x, primes);
    } else {
        double fx = cast(double) x;
        u64 aVal = piFast(cast(u64) sqrt(sqrt(fx)), primes);
        u64 bVal = piFast(cast(u64) sqrt(fx), primes);
        u64 cVal = piFast(cast(u64) cbrt(fx), primes);

        u64 phiVal = phiRec(x, cast(size_t) aVal, primes);
        u64 term1 = (bVal + aVal - 2) * (bVal - aVal + 1);
        u64 sum1 = phiVal + term1 / 2;

        u64 sum2 = 0;
        size_t i = cast(size_t) (aVal + 1);
        size_t bLimit = cast(size_t) bVal;
        while (i <= bLimit) {
            u64 p = cast(u64) primes[i - 1];
            u64 w = x / p;
            u64 piW = piFast(w, primes);
            sum2 = sum2 + piW;

            if (i <= cast(size_t) cVal) {
                u64 sqrtW = cast(u64) sqrt(cast(double) w);
                u64 bi = piFast(sqrtW, primes);
                size_t j = i;
                size_t biLimit = cast(size_t) bi;
                while (j <= biLimit) {
                    u64 pj = cast(u64) primes[j - 1];
                    u64 piW2 = piFast(w / pj, primes);
                    u64 castJ = cast(u64) j;
                    sum2 = sum2 - (piW2 - castJ + 1);
                    j = j + 1;
                }
            }
            i = i + 1;
        }
        count = sum1 - sum2;
    }
    return count;
}

u64 countPrimesInSegment(u64 lowVal, u64 highVal,
                         const(uint)[] basePrimes) {
    u64 rangeLen = highVal - lowVal + 1;
    ubyte* sieve = cast(ubyte*) malloc(cast(size_t) rangeLen);
    memset(sieve, 1, cast(size_t) rangeLen);

    size_t idx = 0;
    while (idx < basePrimes.length) {
        u64 p = cast(u64) basePrimes[idx];
        u64 start = ((lowVal + p - 1) / p) * p;
        if (start < p * p) {
            start = p * p;
        }
        while (start <= highVal) {
            size_t sIdx = cast(size_t) (start - lowVal);
            *(sieve + sIdx) = 0;
            start = start + p;
        }
        idx = idx + 1;
    }

    u64 cnt = 0;
    u64 val = lowVal;
    while (val <= highVal) {
        size_t vIdx = cast(size_t) (val - lowVal);
        ubyte isP = *(sieve + vIdx);
        if (isP == 1) {
            cnt = cnt + 1;
        }
        val = val + 1;
    }
    free(sieve);
    return cnt;
}

u64 sieveSegmentFindNthPrime(u64 lowVal, u64 highVal,
                             const(uint)[] basePrimes,
                             u64 targetN, u64 startPi) {
    u64 rangeLen = highVal - lowVal + 1;
    ubyte* sieve = cast(ubyte*) malloc(cast(size_t) rangeLen);
    memset(sieve, 1, cast(size_t) rangeLen);

    size_t idx = 0;
    while (idx < basePrimes.length) {
        u64 p = cast(u64) basePrimes[idx];
        u64 start = ((lowVal + p - 1) / p) * p;
        if (start < p * p) {
            start = p * p;
        }
        while (start <= highVal) {
            size_t sIdx = cast(size_t) (start - lowVal);
            *(sieve + sIdx) = 0;
            start = start + p;
        }
        idx = idx + 1;
    }

    u64 currentCount = startPi;
    u64 result = 0;
    u64 val = lowVal;
    while (val <= highVal) {
        size_t vIdx = cast(size_t) (val - lowVal);
        ubyte isP = *(sieve + vIdx);
        if (isP == 1) {
            currentCount = currentCount + 1;
            if (currentCount == targetN) {
                result = val;
                val = highVal;
            }
        }
        val = val + 1;
    }
    free(sieve);
    return result;
}

u64 estimateInitialX(u64 n) {
    double fn = cast(double) n;
    double logn = log(fn);
    double log2n = log(logn);
    double est = fn * (logn + log2n - 1.0 + (log2n - 2.0) / logn);
    return cast(u64) est;
}

u64 getSmallNthPrime(u64 n) {
    u64 val = 0;
    if (n == 1) {
        val = 2;
    } else if (n == 2) {
        val = 3;
    } else if (n == 3) {
        val = 5;
    } else if (n == 4) {
        val = 7;
    } else {
        val = 11;
    }
    return val;
}

u64 getNthPrimeCore(u64 n) {
    u64 pn = 0;
    if (n <= 5) {
        pn = getSmallNthPrime(n);
    } else {
        u64 currX = estimateInitialX(n);

        double fx = cast(double) currX;
        double sqX = sqrt(fx);
        u64 zVal = cast(u64) sqX;

        u64 sieveLimit = zVal * 12;
        if (sieveLimit < 200000000UL) {
            sieveLimit = 200000000UL;
        }

        buildBitSieve(sieveLimit);

        uint[] basePrimes = collectPrimesUpTo(zVal + 1000);

        u64 currPi = primeCountLehmer(currX, basePrimes);
        long diffN = cast(long) n - cast(long) currPi;

        while (diffN > 2000 || diffN < -2000) {
            double fVal = cast(double) currX;
            double logVal = log(fVal);
            double adj = cast(double) diffN * logVal;
            long step = cast(long) adj;
            long xNew = cast(long) currX + step;
            currX = cast(u64) xNew;

            currPi = primeCountLehmer(currX, basePrimes);
            diffN = cast(long) n - cast(long) currPi;
        }

        u64 absDiff = 0;
        if (diffN < 0) {
            absDiff = cast(u64) (-diffN);
        } else {
            absDiff = cast(u64) diffN;
        }

        double fCurr = cast(double) currX;
        double logC = log(fCurr);
        double estW = cast(double) absDiff * logC * 2.5;
        u64 window = cast(u64) estW + 50000;
        if (window < 200000) {
            window = 200000;
        }

        if (diffN >= 0) {
            u64 lowVal = currX + 1;
            u64 highVal = currX + window;
            pn = sieveSegmentFindNthPrime(lowVal, highVal,
                                         basePrimes, n, currPi);
        } else {
            u64 lowVal = currX - window;
            u64 segCnt = countPrimesInSegment(lowVal, currX,
                                                basePrimes);
            u64 piLow = currPi - segCnt;
            pn = sieveSegmentFindNthPrime(lowVal, currX,
                                         basePrimes, n, piLow);
        }
    }
    return pn;
}

LimbNumber bigIntToLimbs(BigInt b) {
    LimbNumber ln;
    BigInt cur = b;
    size_t idx = 0;
    BigInt mask = (BigInt(1) << 64) - BigInt(1);
    while (cur > 0 && idx < NUM_LIMBS) {
        BigInt limbVal = cur & mask;
        ln.limbs[idx] = cast(ulong) limbVal;
        cur = cur >> 64;
        idx = idx + 1;
    }
    return ln;
}

BigInt limbsToBigInt(LimbNumber ln) {
    BigInt res = BigInt(0);
    size_t idx = NUM_LIMBS;
    while (idx > 0) {
        idx = idx - 1;
        BigInt bLimb = BigInt(ln.limbs[idx]);
        res = (res << 64) + bLimb;
    }
    return res;
}

LimbNumber ulongToLimbs(ulong val) {
    LimbNumber ln;
    ln.limbs[0] = val;
    return ln;
}

ulong limbsToUlong(LimbNumber ln) {
    return ln.limbs[0];
}

LimbNumber centToLimbs(Cent val) {
    LimbNumber ln;
    ln.limbs[0] = val.lo;
    if (NUM_LIMBS > 1) {
        ln.limbs[1] = cast(ulong) val.hi;
    }
    return ln;
}

Cent limbsToCent(LimbNumber ln) {
    Cent c;
    c.lo = ln.limbs[0];
    if (NUM_LIMBS > 1) {
        c.hi = ln.limbs[1];
    } else {
        c.hi = 0;
    }
    return c;
}

LimbNumber getNthPrime(LimbNumber n) {
    ulong uVal = limbsToUlong(n);
    ulong p = getNthPrimeCore(uVal);
    LimbNumber res = ulongToLimbs(p);
    return res;
}

BigInt getNthPrime(BigInt n) {
    BigInt res = BigInt(0);
    if (n > 0) {
        LimbNumber lnIn = bigIntToLimbs(n);
        LimbNumber lnOut = getNthPrime(lnIn);
        res = limbsToBigInt(lnOut);
    }
    return res;
}

Cent getNthPrime(Cent n) {
    Cent res;
    res.lo = 0;
    res.hi = 0;
    if (n.lo != 0 || n.hi != 0) {
        LimbNumber lnIn = centToLimbs(n);
        LimbNumber lnOut = getNthPrime(lnIn);
        res = limbsToCent(lnOut);
    }
    return res;
}

ulong getNthPrime(ulong n) {
    ulong res = 0;
    if (n > 0) {
        LimbNumber lnIn = ulongToLimbs(n);
        LimbNumber lnOut = getNthPrime(lnIn);
        res = limbsToUlong(lnOut);
    }
    return res;
}

void printResultBigInt(BigInt val) {
    string s = to!string(val);
    printf("The calculated nth prime number value is: %.*s\n",
           cast(int) s.length, s.ptr);
}

version (standalone) {
    enum HAS_MAIN = true;
} else version (demo) {
    enum HAS_MAIN = true;
} else {
    enum HAS_MAIN = false;
}

static if (HAS_MAIN) {
    int main(string[] args) {
        BigInt targetN = BigInt(0);
        if (args.length > 1) {
            string rawStr = strip(to!string(args[1]));
            targetN = BigInt(rawStr);
        } else {
            char[256] buffer;
            char* inputLine = fgets(buffer.ptr,
                                    cast(int) buffer.length,
                                    stdin);
            if (inputLine !is null) {
                string rawStr = strip(to!string(buffer.ptr));
                if (rawStr.length > 0) {
                    targetN = BigInt(rawStr);
                }
            }
        }

        if (targetN > BigInt(0)) {
            BigInt nthPrimeVal = getNthPrime(targetN);
            printResultBigInt(nthPrimeVal);
        } else {
            printf("Invalid input or N must be positive.\n");
        }

        return 0;
    }
}
