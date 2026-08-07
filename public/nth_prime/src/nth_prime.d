module nth_prime;

import core.stdc.stdio : printf, fgets, stdin;
import core.stdc.stdlib : malloc, free;
import std.math : log, sqrt, cbrt;
import std.conv : to;
import std.string : strip;
import std.parallelism : parallel;

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

    size_t idx = 0;
    while (idx <= limit) {
        *(sieve + idx) = 1;
        idx = idx + 1;
    }

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

    ulong[] primes;
    primes.reserve(1000000);
    i = 2;
    while (i <= limit) {
        size_t iIdx = cast(size_t) i;
        ubyte isPrime = *(sieve + iIdx);
        if (isPrime == 1) {
            primes ~= i;
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
    if (a == 0) {
        result = x;
    } else if (x == 0) {
        result = 0;
    } else if (a == 1) {
        ulong temp = x + 1;
        result = temp / 2;
    } else {
        ulong pa = primes[a - 1];
        if (x < pa) {
            result = 1;
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

        foreach (idx, ref termRef; parallel(partialTerms)) {
            ulong i = cast(ulong) (a + 1 + idx);
            size_t pIdx = cast(size_t) (i - 1);
            ulong pi = primes[pIdx];
            ulong w = x / pi;
            ulong piW = piSmall(w, primes);
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

ulong primeCountMeissel(ulong x, const(ulong)[] primes) {
    ulong count = 0;
    if (x < 2) {
        count = 0;
    } else {
        double fx = cast(double) x;
        double cubeRoot = cbrt(fx);
        ulong y = cast(ulong) cubeRoot;

        double squareRoot = sqrt(fx);
        ulong z = cast(ulong) squareRoot;

        ulong a = piSmall(y, primes);
        ulong b = piSmall(z, primes);

        ulong[ulong] memo;
        ulong phiVal = phiRec(x, a, primes, memo);
        ulong p2Val = computeP2(x, a, b, primes);

        ulong sum1 = phiVal + a;
        sum1 = sum1 - 1;
        count = sum1 - p2Val;
    }
    return count;
}

ulong primeCountSublinear(ulong x, const(ulong)[] primes) {
    ulong count = 0;
    if (x <= 1000) {
        count = piSmall(x, primes);
    } else {
        count = primeCountMeissel(x, primes);
    }
    return count;
}

ulong sieveSegmentFindNthPrime(ulong lowVal, ulong highVal,
                               const(ulong)[] primes,
                               ulong targetN, ulong piLow) {
    ulong result = 0;
    ulong diff = highVal - lowVal;
    diff = diff + 1;
    size_t rangeLen = cast(size_t) diff;

    ubyte* sieve = cast(ubyte*) malloc(rangeLen);
    size_t idx = 0;
    while (idx < rangeLen) {
        *(sieve + idx) = 1;
        idx = idx + 1;
    }

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

ulong getNthPrime(ulong n) {
    ulong pn = 0;
    if (n == 1) {
        pn = 2;
    } else if (n == 2) {
        pn = 3;
    } else if (n == 3) {
        pn = 5;
    } else if (n == 4) {
        pn = 7;
    } else if (n == 5) {
        pn = 11;
    } else {
        ulong x0 = estimateInitialX(n);

        double fx0 = cast(double) x0;
        double cbrtX0 = cbrt(fx0);
        double x23 = fx0 / cbrtX0;
        ulong baseLimit = cast(ulong) x23;
        baseLimit = baseLimit + 50000;

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

        ulong pi1 = primeCountSublinear(x1, basePrimes);
        long deltaN1 = cast(long) n;
        long longPi1 = cast(long) pi1;
        deltaN1 = deltaN1 - longPi1;

        double fx1 = cast(double) x1;
        double logX1 = log(fx1);
        double adj1 = cast(double) deltaN1;
        adj1 = adj1 * logX1;
        long lAdj1 = cast(long) adj1;
        long x2Long = cast(long) x1;
        x2Long = x2Long + lAdj1;
        ulong x2 = cast(ulong) x2Long;

        ulong lowBound = x2 - 10000;
        if (x2 < 10000) {
            lowBound = 2;
        }
        ulong highBound = x2 + 10000;
        ulong rangeLow = lowBound - 1;
        ulong piLow = primeCountSublinear(rangeLow, basePrimes);

        if (n <= piLow) {
            lowBound = x2 - 50000;
            if (x2 < 50000) {
                lowBound = 2;
            }
            rangeLow = lowBound - 1;
            piLow = primeCountSublinear(rangeLow, basePrimes);
        }

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
            piLow = primeCountSublinear(rangeLow, basePrimes);
            pn = sieveSegmentFindNthPrime(lowBound, highBound,
                                         basePrimes, n, piLow);
        }
    }
    return pn;
}

ulong parseInputString(string inputStr) {
    string s = strip(inputStr);
    string cleanStr = "";
    size_t i = 0;
    size_t len = s.length;
    while (i < len) {
        char c = s[i];
        if (c != '_' && c != ',') {
            cleanStr ~= c;
        }
        i = i + 1;
    }

    ulong n = 0;
    if (cleanStr == "1e6" || cleanStr == "10^6" ||
        cleanStr == "10**6") {
        n = 1000000UL;
    } else if (cleanStr == "1e9" || cleanStr == "10^9" ||
               cleanStr == "10**9") {
        n = 1000000000UL;
    } else if (cleanStr == "1e10" || cleanStr == "10^10" ||
               cleanStr == "10**10") {
        n = 10000000000UL;
    } else if (cleanStr == "1e11" || cleanStr == "10^11" ||
               cleanStr == "10**11") {
        n = 100000000000UL;
    } else if (cleanStr == "1e12" || cleanStr == "10^12" ||
               cleanStr == "10**12") {
        n = 1000000000000UL;
    } else {
        n = to!ulong(cleanStr);
    }
    return n;
}

int main(string[] args) {
    string inputArg = "1000000000";
    if (args.length > 1) {
        inputArg = args[1];
    } else {
        char[256] buf;
        char* res = fgets(buf.ptr, cast(int) buf.length, stdin);
        if (res !is null) {
            string line = to!string(buf.ptr);
            line = strip(line);
            if (line.length > 0) {
                inputArg = line;
            }
        }
    }

    ulong n = parseInputString(inputArg);
    ulong pn = getNthPrime(n);

    printf("The calculated nth prime number value is: %llu\n", pn);
    return 0;
}
