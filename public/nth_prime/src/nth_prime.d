module nth_prime;

import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memset;
import core.bitop : bsr, popcnt;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;
import std.parallelism : parallel;

__gshared ushort[30030] phi6Table;
__gshared bool phi6Initialized = false;

__gshared ulong[] isSubprimeBit;
__gshared uint[] popCntBlock;
__gshared ulong sieveMax = 0;

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

ulong phi6(ulong x) {
    initPhi6Table();
    ulong q = x / 30030;
    ulong r = x % 30030;
    ulong ans = q * 5760;
    ans = ans + phi6Table[cast(size_t) r];
    return ans;
}

void buildBitSieve(ulong limit) {
    sieveMax = limit;
    ulong numOdds = limit / 2;
    size_t numWords = cast(size_t) (numOdds / 64 + 1);

    isSubprimeBit = new ulong[](numWords);
    size_t wIdx = 0;
    while (wIdx < numWords) {
        isSubprimeBit[wIdx] = 0xFFFFFFFFFFFFFFFFUL;
        wIdx = wIdx + 1;
    }
    isSubprimeBit[0] = isSubprimeBit[0] & ~1UL;

    double fLim = cast(double) limit;
    ulong sqrtLim = cast(ulong) sqrt(fLim);
    ulong p = 3;
    while (p <= sqrtLim) {
        ulong k = (p - 1) / 2;
        size_t wI = cast(size_t) (k / 64);
        size_t rI = cast(size_t) (k % 64);
        ulong mask = 1UL << rI;
        if ((isSubprimeBit[wI] & mask) != 0) {
            ulong mult = p * p;
            while (mult <= limit) {
                ulong mK = (mult - 1) / 2;
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

ulong piFast(ulong w) {
    ulong count = 0;
    if (w < 2) {
        count = 0;
    } else if (w == 2) {
        count = 1;
    } else {
        ulong effW = w;
        if (effW > sieveMax) {
            effW = sieveMax;
        }
        ulong wOdd = effW;
        if (effW % 2 == 0) {
            wOdd = effW - 1;
        }
        ulong k = (wOdd - 1) / 2;
        size_t b = cast(size_t) (k / 64);
        size_t r = cast(size_t) (k % 64);

        ulong baseCnt = cast(ulong) popCntBlock[b];
        ulong mask = 0;
        if (r == 63) {
            mask = 0xFFFFFFFFFFFFFFFFUL;
        } else {
            mask = (1UL << (r + 1)) - 1UL;
        }
        ulong wBits = isSubprimeBit[b] & mask;
        ulong remCnt = cast(ulong) popcnt(wBits);
        count = baseCnt + remCnt;
    }
    return count;
}

uint[] collectPrimesUpTo(ulong limit) {
    ulong numPrimes = piFast(limit);
    uint[] primes = new uint[](cast(size_t) numPrimes);
    if (numPrimes > 0) {
        primes[0] = 2;
        size_t pIdx = 1;
        ulong p = 3;
        while (p <= limit) {
            ulong k = (p - 1) / 2;
            size_t wI = cast(size_t) (k / 64);
            size_t rI = cast(size_t) (k % 64);
            ulong mask = 1UL << rI;
            if ((isSubprimeBit[wI] & mask) != 0) {
                primes[pIdx] = cast(uint) p;
                pIdx = pIdx + 1;
            }
            p = p + 2;
        }
    }
    return primes;
}

ulong phiSmallA(ulong x, ulong a, const(uint)[] primes) {
    ulong res = 0;
    if (a == 0) {
        res = x;
    } else if (a == 1) {
        ulong temp = x + 1;
        res = temp / 2;
    } else if (a <= 6) {
        if (a == 6) {
            res = phi6(x);
        } else {
            ulong pa = cast(ulong) primes[cast(size_t) (a - 1)];
            ulong t1 = phiSmallA(x, a - 1, primes);
            ulong t2 = phiSmallA(x / pa, a - 1, primes);
            res = t1 - t2;
        }
    } else {
        ulong pa = cast(ulong) primes[cast(size_t) (a - 1)];
        ulong t1 = phiSmallA(x, a - 1, primes);
        ulong t2 = phiSmallA(x / pa, a - 1, primes);
        res = t1 - t2;
    }
    return res;
}

ulong estimateInitialX(ulong n) {
    double fn = cast(double) n;
    double ln1 = log(fn);
    double ln2 = log(ln1);

    double t1 = ln1 + ln2;
    t1 = t1 - 1.0;

    double t2 = ln2 - 2.0;
    t2 = t2 / ln1;

    double approx = t1 + t2;
    approx = fn * approx;
    ulong x0 = cast(ulong) approx;
    return x0;
}

ulong phiRec(ulong x, ulong a, const(uint)[] primes,
             ref ulong[ulong] memo) {
    ulong result = 0;
    if (x == 0) {
        result = 0;
    } else if (a <= 6) {
        result = phiSmallA(x, a, primes);
    } else {
        ulong pa = cast(ulong) primes[cast(size_t) (a - 1)];
        if (x < pa) {
            result = 1;
        } else if (x < pa * pa) {
            ulong piX = piFast(x);
            result = piX + 1;
            result = result - a;
        } else {
            ulong key = x;
            key = key << 16;
            key = key | a;
            ulong* cachedPtr = key in memo;
            if (cachedPtr !is null) {
                result = *cachedPtr;
            } else {
                ulong a1 = a - 1;
                ulong term1 = phiRec(x, a1, primes, memo);
                ulong xDivP = x / pa;
                ulong term2 = phiRec(xDivP, a1, primes, memo);
                result = term1 - term2;
                memo[key] = result;
            }
        }
    }
    return result;
}

ulong computeP2(ulong x, ulong a, ulong b,
                const(uint)[] primes) {
    ulong sum = 0;
    if (a < b) {
        size_t count = cast(size_t) (b - a);
        ulong[] partialTerms = new ulong[](count);

        foreach (idx, ref termRef; parallel(partialTerms)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdx = cast(size_t) (i - 1);
            ulong pi = cast(ulong) primes[pIdx];
            ulong w = x / pi;
            ulong piW = piFast(w);
            ulong term = piW + 1;
            term = term - i;
            termRef = term;
        }

        size_t k = 0;
        while (k < count) {
            ulong tVal = partialTerms[k];
            sum = sum + tVal;
            k = k + 1;
        }
    }
    return sum;
}

ulong primeCountMeissel(ulong x, const(uint)[] primes) {
    ulong count = 0;
    if (x < 2) {
        count = 0;
    } else {
        double fx = cast(double) x;
        double cubeRoot = cbrt(fx);
        ulong y = cast(ulong) cubeRoot;

        double squareRoot = sqrt(fx);
        ulong z = cast(ulong) squareRoot;

        ulong a = piFast(y);
        ulong b = piFast(z);

        ulong[ulong] memo;
        ulong phiVal = phiRec(x, a, primes, memo);
        ulong p2Val = computeP2(x, a, b, primes);

        ulong sum1 = phiVal + a;
        sum1 = sum1 - 1;
        count = sum1 - p2Val;
    }
    return count;
}

ulong primeCountSublinear(ulong x, const(uint)[] primes) {
    ulong count = 0;
    if (x <= 1000) {
        count = piFast(x);
    } else {
        count = primeCountMeissel(x, primes);
    }
    return count;
}

ulong countPrimesInSegment(ulong lowVal, ulong highVal,
                           const(uint)[] primes) {
    if (lowVal > highVal) {
        return 0;
    }
    ulong diff = highVal - lowVal;
    diff = diff + 1;
    size_t rangeLen = cast(size_t) diff;
    ubyte* sieve = cast(ubyte*) malloc(rangeLen);
    memset(sieve, 1, rangeLen);

    double rHigh = cast(double) highVal;
    double sqHigh = sqrt(rHigh);
    ulong maxP = cast(ulong) sqHigh;
    ulong numSmall = piFast(maxP);

    size_t pIdx = 0;
    while (pIdx < numSmall) {
        ulong p = cast(ulong) primes[pIdx];
        ulong rem = lowVal % p;
        ulong startVal = 0;
        if (rem != 0) {
            startVal = p - rem;
        }
        ulong firstMult = lowVal + startVal;
        if (firstMult == p) {
            firstMult = firstMult + p;
        }
        ulong curr = firstMult;
        while (curr <= highVal) {
            size_t sIdx = cast(size_t) (curr - lowVal);
            *(sieve + sIdx) = 0;
            curr = curr + p;
        }
        pIdx = pIdx + 1;
    }

    ulong cnt = 0;
    size_t idx = 0;
    while (idx < rangeLen) {
        if (*(sieve + idx) == 1) {
            cnt = cnt + 1;
        }
        idx = idx + 1;
    }
    free(sieve);
    return cnt;
}

ulong sieveSegmentFindNthPrime(ulong lowVal, ulong highVal,
                               const(uint)[] primes,
                               ulong targetN, ulong piLow) {
    ulong result = 0;
    ulong diff = highVal - lowVal;
    diff = diff + 1;
    size_t rangeLen = cast(size_t) diff;

    ubyte* sieve = cast(ubyte*) malloc(rangeLen);
    memset(sieve, 1, rangeLen);

    double rHigh = cast(double) highVal;
    double sqHigh = sqrt(rHigh);
    ulong maxP = cast(ulong) sqHigh;
    ulong numSmall = piFast(maxP);

    size_t pIdx = 0;
    while (pIdx < numSmall) {
        ulong p = cast(ulong) primes[pIdx];
        ulong rem = lowVal % p;
        ulong startVal = 0;
        if (rem != 0) {
            startVal = p - rem;
        }
        ulong firstMult = lowVal + startVal;
        if (firstMult == p) {
            firstMult = firstMult + p;
        }
        ulong curr = firstMult;
        while (curr <= highVal) {
            size_t sIdx = cast(size_t) (curr - lowVal);
            *(sieve + sIdx) = 0;
            curr = curr + p;
        }
        pIdx = pIdx + 1;
    }

    ulong currentCount = piLow;
    ulong val = lowVal;
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

ulong computePiLow(ulong x0, ulong pi0, ulong rangeLow,
                   const(uint)[] primes) {
    ulong piLow = 0;
    if (rangeLow >= x0) {
        ulong segCnt = countPrimesInSegment(x0 + 1, rangeLow, primes);
        piLow = pi0 + segCnt;
    } else {
        ulong segCnt = countPrimesInSegment(rangeLow + 1, x0, primes);
        piLow = pi0 - segCnt;
    }
    return piLow;
}

ulong getSmallNthPrime(ulong n) {
    ulong val = 0;
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

ulong getNthPrime(ulong n) {
    ulong pn = 0;
    if (n <= 5) {
        pn = getSmallNthPrime(n);
    } else {
        ulong currX = estimateInitialX(n);

        double fx = cast(double) currX;
        double cbt = cbrt(fx);
        double tVal = cbt * cbt;
        ulong sieveLimit = cast(ulong) tVal;
        sieveLimit = sieveLimit + 200000;
        if (sieveLimit < 200000UL) {
            sieveLimit = 200000UL;
        }

        buildBitSieve(sieveLimit);

        double sqX = sqrt(fx);
        ulong zVal = cast(ulong) sqX;
        uint[] basePrimes = collectPrimesUpTo(zVal + 1000);

        ulong currPi = primeCountMeissel(currX, basePrimes);
        long diffN = cast(long) n - cast(long) currPi;

        while (diffN > 20000 || diffN < -20000) {
            double fVal = cast(double) currX;
            double logVal = log(fVal);
            double adj = cast(double) diffN * logVal;
            long step = cast(long) adj;
            long xNew = cast(long) currX + step;
            currX = cast(ulong) xNew;

            currPi = primeCountMeissel(currX, basePrimes);
            diffN = cast(long) n - cast(long) currPi;
        }

        ulong window = 200000;
        if (diffN >= 0) {
            ulong lowVal = currX + 1;
            ulong highVal = currX + window;
            pn = sieveSegmentFindNthPrime(lowVal, highVal,
                                         basePrimes, n, currPi);
        } else {
            ulong lowVal = currX - window;
            ulong segCnt = countPrimesInSegment(lowVal, currX,
                                                basePrimes);
            ulong piLow = currPi - segCnt;
            pn = sieveSegmentFindNthPrime(lowVal, currX,
                                         basePrimes, n, piLow);
        }
    }
    return pn;
}

ulong parsePowersSmall(string str) {
    if (str == "1e6" || str == "10^6" || str == "10**6") {
        return 1000000UL;
    }
    if (str == "1e9" || str == "10^9" || str == "10**9") {
        return 1000000000UL;
    }
    return 0;
}

ulong parsePowersLarge(string str) {
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

ulong parseSpecialInput(string str) {
    ulong val = parsePowersSmall(str);
    if (val > 0) {
        return val;
    }
    val = parsePowersLarge(str);
    if (val > 0) {
        return val;
    }
    return to!ulong(str);
}

ulong parseInputString(string inputStr) {
    string cleanStr = strip(inputStr);
    if (cleanStr.length == 0) {
        return 0;
    }
    return parseSpecialInput(cleanStr);
}

int main(string[] args) {
    ulong targetN = 0;
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
        ulong nthPrimeVal = getNthPrime(targetN);
        printf("The calculated nth prime number value is: %llu\n",
               nthPrimeVal);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
