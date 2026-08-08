module nth_prime_64;

import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memset;
import core.bitop : popcnt;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;
import std.parallelism : parallel, TaskPool;

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
        uint baseCount = popCntBlock[wordIdx];
        u64 wVal = isSubprimeBit[wordIdx];
        u64 mask = (1UL << bitIdx) | ((1UL << bitIdx) - 1UL);
        u64 masked = wVal & mask;
        int inWord = cast(int) popcnt(masked);
        count = cast(u64) (baseCount + inWord);
    } else {
        u64 c = 0;
        size_t idx = 0;
        while (idx < primes.length) {
            if (cast(u64) primes[idx] <= w) {
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
    bool found = false;
    while (val <= highVal) {
        if (!found) {
            size_t vIdx = cast(size_t) (val - lowVal);
            ubyte isP = *(sieve + vIdx);
            if (isP == 1) {
                currentCount = currentCount + 1;
                if (currentCount == targetN) {
                    result = val;
                    found = true;
                }
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

u64 getNthPrime(u64 n) {
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

u64 parseDigits(string str) {
    u64 val = 0;
    size_t i = 0;
    while (i < str.length) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            val = val * 10 + (cast(u64) (c - '0'));
        }
        i = i + 1;
    }
    return val;
}

u64 parsePowersSmall(string str) {
    u64 res = 0;
    if (str == "1e6" || str == "10^6" || str == "10**6") {
        res = 1000000;
    } else if (str == "1e9" || str == "10^9" || str == "10**9") {
        res = 1000000000;
    }
    return res;
}

u64 parsePowersLarge(string str) {
    u64 res = 0;
    if (str == "1e10" || str == "10^10" || str == "10**10") {
        res = 10000000000UL;
    } else if (str == "1e11" || str == "10^11" || str == "10**11") {
        res = 100000000000UL;
    } else if (str == "1e12" || str == "10^12" || str == "10**12") {
        res = 1000000000000UL;
    } else if (str == "1e13" || str == "10^13" || str == "10**13") {
        res = 10000000000000UL;
    } else if (str == "1e14" || str == "10^14" || str == "10**14") {
        res = 100000000000000UL;
    } else if (str == "1e15" || str == "10^15" || str == "10**15") {
        res = 1000000000000000UL;
    }
    return res;
}

u64 parseSpecialInput(string str) {
    u64 val = parsePowersSmall(str);
    if (val == 0) {
        val = parsePowersLarge(str);
    }
    if (val == 0) {
        val = parseDigits(str);
    }
    return val;
}

u64 parseInputString(string inputStr) {
    string cleanStr = strip(inputStr);
    u64 val = 0;
    if (cleanStr.length > 0) {
        val = parseSpecialInput(cleanStr);
    }
    return val;
}

void printResult(u64 val) {
    printf("The calculated nth prime number value is: %llu\n", val);
}

int main(string[] args) {
    u64 targetN = 0;
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
        u64 nthPrimeVal = getNthPrime(targetN);
        printResult(nthPrimeVal);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
