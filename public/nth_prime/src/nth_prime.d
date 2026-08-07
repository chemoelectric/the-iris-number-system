module nth_prime;

import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memset;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;
import std.parallelism : parallel;

__gshared ushort[30030] phi6Table;
__gshared bool phi6Initialized = false;

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

ulong phiSmallA(ulong x, ulong a, const(ulong)[] primes) {
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
            ulong pa = primes[a - 1];
            ulong t1 = phiSmallA(x, a - 1, primes);
            ulong t2 = phiSmallA(x / pa, a - 1, primes);
            res = t1 - t2;
        }
    } else {
        ulong pa = primes[a - 1];
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

ulong[] generateBasePrimes(ulong limit) {
    size_t memSize = cast(size_t) limit;
    memSize = memSize + 1;
    ubyte* sieve = cast(ubyte*) malloc(memSize);
    memset(sieve, 1, memSize);

    *(sieve + 0) = 0;
    *(sieve + 1) = 0;

    ulong i = 2;
    while (i * i <= limit) {
        size_t iIdx = cast(size_t) i;
        ubyte isPrime = *(sieve + iIdx);
        if (isPrime == 1) {
            ulong j = i * i;
            while (j <= limit) {
                size_t jIdx = cast(size_t) j;
                *(sieve + jIdx) = 0;
                j = j + i;
            }
        }
        i = i + 1;
    }

    size_t count = 0;
    i = 2;
    while (i <= limit) {
        size_t iIdx = cast(size_t) i;
        ubyte isPrime = *(sieve + iIdx);
        if (isPrime == 1) {
            count = count + 1;
        }
        i = i + 1;
    }

    ulong[] primes = new ulong[](count);
    size_t pIdx = 0;
    i = 2;
    while (i <= limit) {
        size_t iIdx = cast(size_t) i;
        ubyte isPrime = *(sieve + iIdx);
        if (isPrime == 1) {
            primes[pIdx] = i;
            pIdx = pIdx + 1;
        }
        i = i + 1;
    }

    free(sieve);
    return primes;
}

ulong piSmall(ulong w, const(ulong)[] primes) {
    ulong count = 0;
    size_t len = primes.length;
    if (len > 0) {
        ulong maxP = primes[len - 1];
        if (w >= maxP) {
            count = cast(ulong) len;
        } else {
            size_t low = 0;
            size_t high = len;
            while (low < high) {
                size_t mid = low + high;
                mid = mid / 2;
                ulong pMid = primes[mid];
                if (pMid <= w) {
                    low = mid + 1;
                } else {
                    high = mid;
                }
            }
            count = cast(ulong) low;
        }
    }
    return count;
}

ulong phiRec(ulong x, ulong a, const(ulong)[] primes,
             ref ulong[ulong] memo) {
    ulong result = 0;
    if (x == 0) {
        result = 0;
    } else if (a <= 12) {
        result = phiSmallA(x, a, primes);
    } else {
        ulong pa = primes[a - 1];
        if (x < pa) {
            result = 1;
        } else if (x < pa * pa) {
            ulong piX = piSmall(x, primes);
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
                const(ulong)[] primes) {
    ulong sum = 0;
    if (a < b) {
        size_t count = cast(size_t) (b - a);
        ulong[] partialTerms = new ulong[](count);
        ulong maxBase = primes[primes.length - 1];

        foreach (idx, ref termRef; parallel(partialTerms)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdx = cast(size_t) (i - 1);
            ulong pi = primes[pIdx];
            ulong w = x / pi;
            ulong piW = 0;
            if (w <= maxBase) {
                piW = piSmall(w, primes);
            } else {
                piW = primeCountSublinear(w, primes);
            }
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

ulong computeP3(ulong x, ulong a, ulong c,
                const(ulong)[] primes) {
    ulong sum = 0;
    if (a < c) {
        size_t count = cast(size_t) (c - a);
        ulong[] partialTerms = new ulong[](count);

        foreach (idx, ref termRef; parallel(partialTerms)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdx = cast(size_t) (i - 1);
            ulong pi = primes[pIdx];
            ulong wi = x / pi;

            double fWi = cast(double) wi;
            double sqWi = sqrt(fWi);
            ulong limit = cast(ulong) sqWi;

            ulong bi = piSmall(limit, primes);
            ulong subSum = 0;

            ulong j = i;
            while (j <= bi) {
                size_t jIdx = cast(size_t) (j - 1);
                ulong pj = primes[jIdx];
                ulong v = wi / pj;
                ulong piV = piSmall(v, primes);
                ulong term = piV + 1;
                term = term - j;
                subSum = subSum + term;
                j = j + 1;
            }
            termRef = subSum;
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

ulong primeCountLehmer(ulong x, const(ulong)[] primes) {
    ulong count = 0;
    if (x < 2) {
        count = 0;
    } else {
        double fx = cast(double) x;
        double fourthRoot = sqrt(sqrt(fx));
        ulong u = cast(ulong) fourthRoot;

        double cubeRoot = cbrt(fx);
        ulong y = cast(ulong) cubeRoot;

        double squareRoot = sqrt(fx);
        ulong z = cast(ulong) squareRoot;

        ulong a = piSmall(u, primes);
        ulong c = piSmall(y, primes);
        ulong b = piSmall(z, primes);

        ulong[ulong] memo;
        ulong phiVal = phiRec(x, a, primes, memo);
        ulong p2Val = computeP2(x, a, b, primes);
        ulong p3Val = computeP3(x, a, c, primes);

        ulong sum1 = phiVal + a;
        sum1 = sum1 - 1;
        ulong diff1 = sum1 - p2Val;
        count = diff1 - p3Val;
    }
    return count;
}

ulong primeCountSublinear(ulong x, const(ulong)[] primes) {
    ulong count = 0;
    if (x <= 1000) {
        count = piSmall(x, primes);
    } else {
        count = primeCountLehmer(x, primes);
    }
    return count;
}

ulong countPrimesInSegment(ulong lowVal, ulong highVal,
                           const(ulong)[] primes) {
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
    ulong numSmall = piSmall(maxP, primes);

    size_t pIdx = 0;
    while (pIdx < numSmall) {
        ulong p = primes[pIdx];
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
                               const(ulong)[] primes,
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
    ulong numSmall = piSmall(maxP, primes);

    size_t pIdx = 0;
    while (pIdx < numSmall) {
        ulong p = primes[pIdx];
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
                   const(ulong)[] primes) {
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
        ulong x0 = estimateInitialX(n);

        double fx0 = cast(double) x0;
        double sqrtX0 = sqrt(fx0);
        ulong baseLimit = cast(ulong) sqrtX0;
        baseLimit = baseLimit + 50000;
        if (baseLimit < 30000000UL) {
            baseLimit = 30000000UL;
        }

        ulong[] basePrimes = generateBasePrimes(baseLimit);

        ulong pi0 = primeCountSublinear(x0, basePrimes);

        long deltaN = cast(long) n;
        long longPi0 = cast(long) pi0;
        deltaN = deltaN - longPi0;

        double logX0 = log(fx0);
        double adj = cast(double) deltaN;
        adj = adj * logX0;
        long lAdj = cast(long) adj;
        long x1Long = cast(long) x0;
        x1Long = x1Long + lAdj;
        ulong x1 = cast(ulong) x1Long;

        ulong lowBound = x1 - 50000;
        if (x1 < 50000) {
            lowBound = 2;
        }
        ulong highBound = x1 + 50000;
        ulong rangeLow = lowBound - 1;

        ulong piLow = computePiLow(x0, pi0, rangeLow, basePrimes);

        pn = sieveSegmentFindNthPrime(lowBound, highBound,
                                     basePrimes, n, piLow);
        while (pn == 0) {
            if (lowBound > 50000) {
                lowBound = lowBound - 50000;
            } else {
                lowBound = 2;
            }
            highBound = highBound + 100000;
            rangeLow = lowBound - 1;
            piLow = computePiLow(x0, pi0, rangeLow, basePrimes);
            pn = sieveSegmentFindNthPrime(lowBound, highBound,
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
