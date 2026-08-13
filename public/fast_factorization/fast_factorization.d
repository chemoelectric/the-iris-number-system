/*********************************************************************
 * Fast Parallel Factorization Inference Engine Module
 *
 * Implements parallel factor search using m-resolution modular
 * arithmetic and parallel range decomposition.
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

struct FactorSearchResult
{
    bool found;
    ulong factor;
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

bool bifIsZero(const ref BigIntFixed a)
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

bool bifIsOne(const ref BigIntFixed a)
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

bool bifIsEven(const ref BigIntFixed a)
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

int bifCompare(const ref BigIntFixed a, const ref BigIntFixed b)
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

ulong bifAdd(const ref BigIntFixed a,
             const ref BigIntFixed b,
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

ulong bifSub(const ref BigIntFixed a,
             const ref BigIntFixed b,
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

ulong bifModUlong(const ref BigIntFixed a, ulong m)
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

string bifToHexString(const ref BigIntFixed a)
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

void searchWorker(const BigIntFixed nVal,
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

FactorSearchResult parallelFactorSearch(const ref BigIntFixed n,
                                         ulong maxTrial)
{
    FactorSearchResult result;
    result.found = false;
    result.factor = 0;

    bool isEv = bifIsEven(n);
    if (isEv == true)
    {
        result.found = true;
        result.factor = 2;
    }
    else
    {
        shared bool stopFlag = false;
        shared ulong sharedFactor = 0;
        size_t nCPUs = totalCPUs;
        if (nCPUs == 0)
        {
            nCPUs = 1;
        }

        TaskPool pool = new TaskPool(nCPUs);
        size_t tIdx = 0;
        while (tIdx < nCPUs)
        {
            ulong startD = 3 + 2 * tIdx;
            ulong strideD = 2 * nCPUs;
            auto t = task!searchWorker(n,
                                       startD,
                                       strideD,
                                       maxTrial,
                                       &stopFlag,
                                       &sharedFactor);
            pool.put(t);
            tIdx = tIdx + 1;
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

version (standalone)
{
    int main(string[] args)
    {
        int exitCode = 0;
        writeln("==================================================");
        writeln("  Parallel Fast Factorization Engine");
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

            //ulong maxTrial = 10000000UL;
            ulong maxTrial = ulong.max;
            StopWatch sw;
            sw.start();
            FactorSearchResult res =
                parallelFactorSearch(val, maxTrial);
            sw.stop();

            double elapsedMs = sw.peek().total!"msecs"();
            if (res.found == true)
            {
                writeln("Factor Found       : ", res.factor);
                writeln("Search Time (ms)   : ", elapsedMs);
            }
            else
            {
                writeln("No factor found up to limit ", maxTrial);
                writeln("Search Time (ms)   : ", elapsedMs);
            }
        }
        return exitCode;
    }
}
else version (demo)
{
    void runFactorizationDemo()
    {
        writeln("==================================================");
        writeln("  Parallel Factorization Engine Demonstration");
        writeln("  Precision Mode : ", PRECISION_NAME);
        writeln("==================================================");

        string testHex = "0x000000E8D50A1FA3";
        BigIntFixed val = bifFromHexString(testHex);
        string valHex = bifToHexString(val);
        writeln("Target Number (Hex) : ", valHex);

        ulong maxTrial = 5000000UL;
        StopWatch sw;
        sw.start();
        FactorSearchResult res =
            parallelFactorSearch(val, maxTrial);
        sw.stop();

        double elapsedMs = sw.peek().total!"msecs"();
        if (res.found == true)
        {
            writeln("Factor Found        : ", res.factor);
            writeln("Search Time (ms)    : ", elapsedMs);
        }
        else
        {
            writeln("No factor found up to limit ", maxTrial);
            writeln("Search Time (ms)    : ", elapsedMs);
        }
    }

    int main(string[] args)
    {
        runFactorizationDemo();
        return 0;
    }
}
