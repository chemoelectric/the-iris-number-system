module nth_prime_128;

import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memset;
import core.bitop : popcnt;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;

static if (is(ucent)) {
    alias u128 = ucent;
} else {
    alias u128 = ulong;
}

struct MemoEntry {
    u128 x;
    uint a;
    u128 res;
}

enum CACHE_SIZE = 1048576;
enum CACHE_MASK = CACHE_SIZE - 1;

__gshared MemoEntry[CACHE_SIZE] memoTable;

__gshared ushort[30030] phi6Table;
__gshared bool phi6Initialized = false;

__gshared ulong[] isSubprimeBit;
__gshared uint[] popCntBlock;
__gshared u128 sieveMax = 0;

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

u128 phi6(u128 x) {
    initPhi6Table();
    u128 q = x / 30030;
    u128 r = x % 30030;
    u128 ans = q * 5760;
    ans = ans + phi6Table[cast(size_t) r];
    return ans;
}

void buildBitSieve(u128 limit) {
    sieveMax = limit;
    u128 numOdds = limit / 2;
    size_t numWords = cast(size_t) (numOdds / 64 + 1);

    isSubprimeBit = new ulong[](numWords);
    size_t wIdx = 0;
    while (wIdx < numWords) {
        isSubprimeBit[wIdx] = 0xFFFFFFFFFFFFFFFFUL;
        wIdx = wIdx + 1;
    }
    isSubprimeBit[0] = isSubprimeBit[0] & ~1UL;

    double fLim = cast(double) limit;
    u128 sqrtLim = cast(u128) sqrt(fLim);
    u128 p = 3;
    while (p <= sqrtLim) {
        u128 k = (p - 1) / 2;
        size_t wI = cast(size_t) (k / 64);
        size_t rI = cast(size_t) (k % 64);
        ulong mask = 1UL << rI;
        if ((isSubprimeBit[wI] & mask) != 0) {
            u128 mult = p * p;
            while (mult <= limit) {
                u128 mK = (mult - 1) / 2;
                size_t mW = cast(size_t) (mK / 64);
                size_t mR = cast(size_t) (mK % 64);
                ulong clearMask = ~(1UL << mR);
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
        ulong wordVal = isSubprimeBit[b];
        int bitCnt = cast(int) popcnt(wordVal);
        uint prev = popCntBlock[b];
        popCntBlock[b + 1] = cast(uint) (prev + bitCnt);
        b = b + 1;
    }
}

bool isPrimeBit(u128 val) {
    if (val < 2) {
        return false;
    }
    if (val == 2) {
        return true;
    }
    if (val % 2 == 0) {
        return false;
    }
    if (val > sieveMax) {
        return false;
    }
    u128 k = (val - 1) / 2;
    size_t wordIdx = cast(size_t) (k / 64);
    size_t bitIdx = cast(size_t) (k % 64);
    ulong mask = 1UL << bitIdx;
    return (isSubprimeBit[wordIdx] & mask) != 0;
}

uint[] collectPrimesUpTo(u128 maxVal) {
    size_t count = 0;
    u128 p = 2;
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

u128 piFast(u128 w, const(uint)[] primes) {
    u128 count = 0;
    if (w < 2) {
        count = 0;
    } else if (w == 2) {
        count = 1;
    } else if (w <= sieveMax) {
        u128 k = (w - 1) / 2;
        size_t wordIdx = cast(size_t) (k / 64);
        size_t bitIdx = cast(size_t) (k % 64);
        uint baseCount = popCntBlock[wordIdx];
        ulong wVal = isSubprimeBit[wordIdx];
        ulong mask = (1UL << bitIdx) | ((1UL << bitIdx) - 1UL);
        ulong masked = wVal & mask;
        int inWord = cast(int) popcnt(masked);
        count = cast(u128) (baseCount + inWord);
    } else {
        u128 c = 0;
        size_t idx = 0;
        while (idx < primes.length) {
            if (cast(u128) primes[idx] <= w) {
                c = c + 1;
                idx = idx + 1;
            } else {
                idx = primes.length;
            }
        }
        count = c;
    }
    return count;
}

u128 phiRec(u128 x, size_t a, const(uint)[] primes) {
    u128 result = 0;
    if (a == 0) {
        result = x;
    } else if (a == 6) {
        result = phi6(x);
    } else if (x == 0) {
        result = 0;
    } else {
        u128 key = (x ^ (cast(u128) a * 0x9e3779b97f4a7c15UL));
        size_t slot = cast(size_t) (key & CACHE_MASK);
        if (memoTable[slot].x == x && memoTable[slot].a == a) {
            result = memoTable[slot].res;
        } else {
            u128 p = cast(u128) primes[a - 1];
            if (x < p) {
                result = 1;
            } else if (x <= sieveMax) {
                u128 p6 = cast(u128) primes[5];
                if (x <= p6 * p) {
                    u128 piX = piFast(x, primes);
                    u128 castA = cast(u128) a;
                    result = piX - castA + 1;
                } else {
                    u128 term1 = phiRec(x, a - 1, primes);
                    u128 term2 = phiRec(x / p, a - 1, primes);
                    result = term1 - term2;
                }
            } else {
                u128 term1 = phiRec(x, a - 1, primes);
                u128 term2 = phiRec(x / p, a - 1, primes);
                result = term1 - term2;
            }
            memoTable[slot].x = x;
            memoTable[slot].a = cast(uint) a;
            memoTable[slot].res = result;
        }
    }
    return result;
}

u128 primeCountLehmer(u128 x, const(uint)[] primes) {
    u128 count = 0;
    if (x < 2) {
        count = 0;
    } else if (x <= sieveMax) {
        count = piFast(x, primes);
    } else {
        double fx = cast(double) x;
        u128 aVal = cast(u128) piFast(cast(u128) sqrt(sqrt(fx)),
                                      primes);
        u128 bVal = cast(u128) piFast(cast(u128) sqrt(fx), primes);
        u128 cVal = cast(u128) piFast(cast(u128) cbrt(fx), primes);

        u128 phiVal = phiRec(x, cast(size_t) aVal, primes);
        u128 term1 = (bVal + aVal - 2) * (bVal - aVal + 1);
        u128 sum1 = phiVal + term1 / 2;

        u128 sum2 = 0;
        size_t i = cast(size_t) (aVal + 1);
        size_t bLimit = cast(size_t) bVal;
        while (i <= bLimit) {
            u128 p = cast(u128) primes[i - 1];
            u128 w = x / p;
            u128 piW = piFast(w, primes);
            sum2 = sum2 + piW;

            if (i <= cast(size_t) cVal) {
                u128 sqrtW = cast(u128) sqrt(cast(double) w);
                u128 bi = cast(u128) piFast(sqrtW, primes);
                size_t j = i;
                size_t biLimit = cast(size_t) bi;
                while (j <= biLimit) {
                    u128 pj = cast(u128) primes[j - 1];
                    u128 piW2 = piFast(w / pj, primes);
                    u128 castJ = cast(u128) j;
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

u128 countPrimesInSegment(u128 lowVal, u128 highVal,
                          const(uint)[] basePrimes) {
    u128 rangeLen = highVal - lowVal + 1;
    ubyte* sieve = cast(ubyte*) malloc(cast(size_t) rangeLen);
    memset(sieve, 1, cast(size_t) rangeLen);

    size_t idx = 0;
    while (idx < basePrimes.length) {
        u128 p = cast(u128) basePrimes[idx];
        u128 start = ((lowVal + p - 1) / p) * p;
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

    u128 cnt = 0;
    u128 val = lowVal;
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

u128 sieveSegmentFindNthPrime(u128 lowVal, u128 highVal,
                              const(uint)[] basePrimes,
                              u128 targetN, u128 startPi) {
    u128 rangeLen = highVal - lowVal + 1;
    ubyte* sieve = cast(ubyte*) malloc(cast(size_t) rangeLen);
    memset(sieve, 1, cast(size_t) rangeLen);

    size_t idx = 0;
    while (idx < basePrimes.length) {
        u128 p = cast(u128) basePrimes[idx];
        u128 start = ((lowVal + p - 1) / p) * p;
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

    u128 currentCount = startPi;
    u128 result = 0;
    u128 val = lowVal;
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

u128 estimateInitialX(u128 n) {
    double fn = cast(double) n;
    double logn = log(fn);
    double log2n = log(logn);
    double est = fn * (logn + log2n - 1.0 + (log2n - 2.0) / logn);
    return cast(u128) est;
}

u128 getSmallNthPrime(u128 n) {
    u128 val = 0;
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

u128 getNthPrime(u128 n) {
    u128 pn = 0;
    if (n <= 5) {
        pn = getSmallNthPrime(n);
    } else {
        u128 currX = estimateInitialX(n);

        double fx = cast(double) currX;
        double sqX = sqrt(fx);
        u128 zVal = cast(u128) sqX;

        u128 sieveLimit = zVal * 12;
        if (sieveLimit < 200000000UL) {
            sieveLimit = 200000000UL;
        }

        buildBitSieve(sieveLimit);

        uint[] basePrimes = collectPrimesUpTo(zVal + 1000);

        u128 currPi = primeCountLehmer(currX, basePrimes);
        long diffN = cast(long) n - cast(long) currPi;

        while (diffN > 2000 || diffN < -2000) {
            double fVal = cast(double) currX;
            double logVal = log(fVal);
            double adj = cast(double) diffN * logVal;
            long step = cast(long) adj;
            long xNew = cast(long) currX + step;
            currX = cast(u128) xNew;

            currPi = primeCountLehmer(currX, basePrimes);
            diffN = cast(long) n - cast(long) currPi;
        }

        u128 absDiff = 0;
        if (diffN < 0) {
            absDiff = cast(u128) (-diffN);
        } else {
            absDiff = cast(u128) diffN;
        }

        double fCurr = cast(double) currX;
        double logC = log(fCurr);
        double estW = cast(double) absDiff * logC * 2.5;
        u128 window = cast(u128) estW + 50000;
        if (window < 200000) {
            window = 200000;
        }

        if (diffN >= 0) {
            u128 lowVal = currX + 1;
            u128 highVal = currX + window;
            pn = sieveSegmentFindNthPrime(lowVal, highVal,
                                         basePrimes, n, currPi);
        } else {
            u128 lowVal = currX - window;
            u128 segCnt = countPrimesInSegment(lowVal, currX,
                                                basePrimes);
            u128 piLow = currPi - segCnt;
            pn = sieveSegmentFindNthPrime(lowVal, currX,
                                         basePrimes, n, piLow);
        }
    }
    return pn;
}

u128 parseDigits(string str) {
    u128 val = 0;
    size_t i = 0;
    while (i < str.length) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            val = val * 10 + (cast(u128) (c - '0'));
        }
        i = i + 1;
    }
    return val;
}

u128 parsePowersSmall(string str) {
    if (str == "1e6" || str == "10^6" || str == "10**6") {
        return 1000000;
    }
    if (str == "1e9" || str == "10^9" || str == "10**9") {
        return 1000000000;
    }
    return 0;
}

u128 parsePowersLarge(string str) {
    if (str == "1e10" || str == "10^10" || str == "10**10") {
        return 10000000000UL;
    }
    if (str == "1e11" || str == "10^11" || str == "10**11") {
        return 100000000000UL;
    }
    if (str == "1e12" || str == "10^12" || str == "10**12") {
        return 1000000000000UL;
    }
    if (str == "1e13" || str == "10^13" || str == "10**13") {
        return 10000000000000UL;
    }
    if (str == "1e14" || str == "10^14" || str == "10**14") {
        return 100000000000000UL;
    }
    if (str == "1e15" || str == "10^15" || str == "10**15") {
        return 1000000000000000UL;
    }
    return 0;
}

u128 parseSpecialInput(string str) {
    u128 val = parsePowersSmall(str);
    if (val > 0) {
        return val;
    }
    val = parsePowersLarge(str);
    if (val > 0) {
        return val;
    }
    return parseDigits(str);
}

u128 parseInputString(string inputStr) {
    string cleanStr = strip(inputStr);
    if (cleanStr.length == 0) {
        return 0;
    }
    return parseSpecialInput(cleanStr);
}

void printResult(u128 val) {
    static if (u128.sizeof > ulong.sizeof) {
        ulong lowPart = cast(ulong) val;
        ulong highPart = cast(ulong) (val >> 64);
        if (highPart > 0) {
            printf("The calculated nth prime " ~
                   "number value is: %llu%019llu\n",
                   highPart, lowPart);
        } else {
            printf("The calculated nth prime number value is: %llu\n",
                   lowPart);
        }
    } else {
        ulong lowPart = cast(ulong) val;
        printf("The calculated nth prime number value is: %llu\n",
               lowPart);
    }
}

int main(string[] args) {
    u128 targetN = 0;
    if (args.length > 1) {
        targetN = parseInputString(args[1]);
    } else {
        char[256] buffer;
        char* inputLine = fgets(buffer.ptr, cast(int) buffer.length,
                                stdin);
        if (inputLine !is null) {
            string rawStr = to!string(buffer.ptr);
            targetN = parseInputString(rawStr);
        }
    }

    if (targetN > 0) {
        u128 nthPrimeVal = getNthPrime(targetN);
        printResult(nthPrimeVal);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
