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

ulong piFast(ulong w, const(uint)[] primes) {
    ulong count = 0;
    if (w < 2) {
        count = 0;
    } else if (w == 2) {
        count = 1;
    } else if (w <= sieveMax) {
        ulong wOdd = w;
        if (w % 2 == 0) {
            wOdd = w - 1;
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
    } else if (primes !is null && primes.length > 0) {
        size_t len = primes.length;
        ulong maxP = cast(ulong) primes[len - 1];
        if (w <= maxP) {
            size_t msb = cast(size_t) bsr(len);
            size_t mask = cast(size_t) 1 << msb;
            size_t idx = 0;
            while (mask > 0) {
                size_t candidate = idx | mask;
                if (candidate < len) {
                    ulong pCand = cast(ulong) primes[candidate];
                    if (pCand <= w) {
                        idx = candidate;
                    }
                }
                mask = mask >> 1;
            }
            count = cast(ulong) (idx + 1);
        } else {
            count = primeCountLehmer(w, primes);
        }
    }
    return count;
}

uint[] collectPrimesUpTo(ulong limit) {
    ulong numPrimes = piFast(limit, null);
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

ulong phiEval(ulong x, ulong a, const(uint)[] primes) {
    ulong res = 0;
    if (x == 0) {
        res = 0;
    } else if (a == 0) {
        res = x;
    } else if (a == 1) {
        ulong temp = x + 1;
        res = temp / 2;
    } else if (a <= 6) {
        res = phiSmallA(x, a, primes);
    } else {
        ulong pa = cast(ulong) primes[cast(size_t) (a - 1)];
        if (x < pa) {
            res = 1;
        } else if (x < pa * pa) {
            ulong piX = piFast(x, primes);
            res = piX + 1;
            res = res - a;
        } else {
            ulong sumVal = phi6(x);
            ulong i = 7;
            while (i <= a) {
                ulong pi = cast(ulong) primes[cast(size_t) (i - 1)];
                ulong w = x / pi;
                ulong k = i - 1;
                ulong pk1 = cast(ulong) primes[cast(size_t) (k - 1)];

                if (w < pk1) {
                    sumVal = sumVal - 1;
                } else if (w < pk1 * pk1) {
                    ulong piW = piFast(w, primes);
                    ulong term = piW + 1;
                    term = term - k;
                    sumVal = sumVal - term;
                } else {
                    ulong term = phiEval(w, k, primes);
                    sumVal = sumVal - term;
                }
                i = i + 1;
            }
            res = sumVal;
        }
    }
    return res;
}

ulong computeP2(ulong x, ulong a, ulong c,
                const(uint)[] primes) {
    ulong sum = 0;
    if (a < c) {
        size_t count = cast(size_t) (c - a);
        ulong[] partialTerms = new ulong[](count);

        foreach (idx, ref termRef; parallel(partialTerms)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdx = cast(size_t) (i - 1);
            ulong pi = cast(ulong) primes[pIdx];
            ulong w = x / pi;
            ulong piW = piFast(w, primes);
            if (piW >= i) {
                ulong term = piW + 1;
                term = term - i;
                termRef = term;
            } else {
                termRef = 0;
            }
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

ulong computeP3(ulong x, ulong a, ulong b,
                const(uint)[] primes) {
    ulong sum3 = 0;
    if (a < b) {
        size_t countI = cast(size_t) (b - a);
        ulong[] partialP3 = new ulong[](countI);

        foreach (idx, ref termRef; parallel(partialP3)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdxI = cast(size_t) (i - 1);
            ulong pi = cast(ulong) primes[pIdxI];

            double fVal = cast(double) (x / pi);
            ulong sqVal = cast(ulong) sqrt(fVal);
            ulong limitJ = piFast(sqVal, primes);

            ulong sumI = 0;
            ulong j = i;
            while (j <= limitJ) {
                size_t pIdxJ = cast(size_t) (j - 1);
                ulong pj = cast(ulong) primes[pIdxJ];
                ulong w = x / (pi * pj);
                ulong piW = piFast(w, primes);
                if (piW >= j) {
                    ulong term = piW + 1;
                    term = term - j;
                    sumI = sumI + term;
                }
                j = j + 1;
            }
            termRef = sumI;
        }

        size_t k = 0;
        while (k < countI) {
            ulong tVal = partialP3[k];
            sum3 = sum3 + tVal;
            k = k + 1;
        }
    }
    return sum3;
}

ulong primeCountLehmer(ulong x, const(uint)[] primes) {
    ulong count = 0;
    if (x < 2) {
        count = 0;
    } else if (x <= sieveMax) {
        count = piFast(x, primes);
    } else {
        double fx = cast(double) x;
        double fourthRoot = sqrt(sqrt(fx));
        ulong pA = cast(ulong) fourthRoot;

        double cubeRoot = cbrt(fx);
        ulong pB = cast(ulong) cubeRoot;

        double squareRoot = sqrt(fx);
        ulong pC = cast(ulong) squareRoot;

        ulong a = piFast(pA, primes);
        ulong b = piFast(pB, primes);
        ulong c = piFast(pC, primes);

        ulong phiVal = phiEval(x, a, primes);
        ulong p2Val = computeP2(x, a, c, primes);
        ulong p3Val = computeP3(x, a, b, primes);

        ulong sum1 = phiVal + a;
        sum1 = sum1 - 1;
        sum1 = sum1 - p2Val;
        count = sum1 - p3Val;
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
    ulong numSmall = piFast(maxP, primes);

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
    ulong numSmall = piFast(maxP, primes);

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
        double sqX = sqrt(fx);
        ulong zVal = cast(ulong) sqX;

        ulong sieveLimit = zVal * 4;
        if (sieveLimit < 50000000UL) {
            sieveLimit = 50000000UL;
        }

        buildBitSieve(sieveLimit);

        uint[] basePrimes = collectPrimesUpTo(zVal + 1000);

        ulong currPi = primeCountLehmer(currX, basePrimes);
        long diffN = cast(long) n - cast(long) currPi;

        while (diffN > 20000 || diffN < -20000) {
            double fVal = cast(double) currX;
            double logVal = log(fVal);
            double adj = cast(double) diffN * logVal;
            long step = cast(long) adj;
            long xNew = cast(long) currX + step;
            currX = cast(ulong) xNew;

            currPi = primeCountLehmer(currX, basePrimes);
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
