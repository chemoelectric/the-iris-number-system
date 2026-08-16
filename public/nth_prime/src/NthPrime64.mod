IMPLEMENTATION MODULE NthPrime64;

(* NthPrime64.mod - ISO Modula-2 (gm2 / GCC 16.1) 64-bit nth-prime engine.
 * Implements high-performance Lehmer sublinear prime counting,
 * O(1) primorial P_6 = 30030 wheel periodic lookups, memoized
 * Buchstab recursion, and bit-packed segmented window sieving.
 *)

FROM SYSTEM IMPORT CARDINAL64, CARDINAL32, CARDINAL16, ADDRESS, ADR;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM RealMath IMPORT ln, exp, sqrt, power;
FROM STextIO IMPORT WriteString, WriteLn;
FROM SWholeIO IMPORT WriteCard;

CONST
  CacheSize = 1048576;
  CacheMask = 1048575;
  PrimeWheelMod = 30030;
  PrimeWheelCount = 5760;

TYPE
  Word64Array = POINTER TO ARRAY [0..268435455] OF CARDINAL64;
  Card64Array = POINTER TO ARRAY [0..268435455] OF CARDINAL64;

VAR
  gMemoX : ARRAY [0..CacheSize-1] OF CARDINAL64;
  gMemoA : ARRAY [0..CacheSize-1] OF CARDINAL32;
  gMemoRes : ARRAY [0..CacheSize-1] OF CARDINAL64;

  gPhi6Table : ARRAY [0..PrimeWheelMod-1] OF CARDINAL16;
  gPhi6Initialized : BOOLEAN;

  gPow2 : ARRAY [0..63] OF CARDINAL64;
  gBytePopcnt : ARRAY [0..255] OF CARDINAL;
  gTablesInitialized : BOOLEAN;

  gIsSubprimeBit : Word64Array;
  gPopcntBlock : Card64Array;
  gSieveMax : CARDINAL64;

PROCEDURE InitBaseTables;
VAR
  i, v, b, c : CARDINAL;
  p : CARDINAL64;
BEGIN
  IF NOT gTablesInitialized THEN
    p := 1;
    i := 0;
    WHILE i < 64 DO
      gPow2[i] := p;
      IF i < 63 THEN
        p := p * 2;
      END;
      i := i + 1;
    END;

    v := 0;
    WHILE v < 256 DO
      c := 0;
      b := v;
      WHILE b > 0 DO
        IF (b MOD 2) = 1 THEN
          c := c + 1;
        END;
        b := b DIV 2;
      END;
      gBytePopcnt[v] := c;
      v := v + 1;
    END;
    gTablesInitialized := TRUE;
  END;
END InitBaseTables;

PROCEDURE PopCount64 (w : CARDINAL64) : CARDINAL64;
VAR
  cnt, temp : CARDINAL64;
  byteVal : CARDINAL;
BEGIN
  cnt := 0;
  temp := w;
  WHILE temp > 0 DO
    byteVal := VAL(CARDINAL, temp MOD 256);
    cnt := cnt + VAL(CARDINAL64, gBytePopcnt[byteVal]);
    temp := temp DIV 256;
  END;
  RETURN cnt;
END PopCount64;

PROCEDURE IsCoprimeTo30030 (iVal : CARDINAL64) : BOOLEAN;
VAR
  ok : BOOLEAN;
BEGIN
  ok := TRUE;
  IF (iVal MOD 2) = 0 THEN
    ok := FALSE;
  ELSIF (iVal MOD 3) = 0 THEN
    ok := FALSE;
  ELSIF (iVal MOD 5) = 0 THEN
    ok := FALSE;
  ELSIF (iVal MOD 7) = 0 THEN
    ok := FALSE;
  ELSIF (iVal MOD 11) = 0 THEN
    ok := FALSE;
  ELSIF (iVal MOD 13) = 0 THEN
    ok := FALSE;
  END;
  RETURN ok;
END IsCoprimeTo30030;

PROCEDURE InitPhi6Table;
VAR
  running : CARDINAL16;
  iVal : CARDINAL64;
BEGIN
  IF NOT gPhi6Initialized THEN
    running := 0;
    iVal := 1;
    WHILE iVal <= PrimeWheelMod DO
      IF IsCoprimeTo30030(iVal) THEN
        running := running + 1;
      END;
      gPhi6Table[iVal - 1] := running;
      iVal := iVal + 1;
    END;
    gPhi6Initialized := TRUE;
  END;
END InitPhi6Table;

PROCEDURE Phi6 (xVal : CARDINAL64) : CARDINAL64;
VAR
  qVal, rVal, ans, tblVal : CARDINAL64;
BEGIN
  qVal := xVal DIV PrimeWheelMod;
  rVal := xVal MOD PrimeWheelMod;
  ans := qVal * PrimeWheelCount;
  IF rVal > 0 THEN
    tblVal := VAL(CARDINAL64, gPhi6Table[rVal - 1]);
    ans := ans + tblVal;
  END;
  RETURN ans;
END Phi6;

PROCEDURE BuildBitSieve (limit : CARDINAL64);
VAR
  numOdds, numWords, iVal, iOdd, wIdx, bIdx : CARDINAL64;
  i2Val, jVal, jOdd, jw, jb, wVal, wIter : CARDINAL64;
  sqrtLim, mask, prevCnt, bitM : CARDINAL64;
  allocSize : CARDINAL;
BEGIN
  IF (limit <= gSieveMax) AND (gIsSubprimeBit # NIL) THEN
    RETURN;
  END;

  IF gIsSubprimeBit # NIL THEN
    numOdds := gSieveMax DIV 2;
    numWords := (numOdds DIV 64) + 1;
    allocSize := VAL(CARDINAL, numWords * 8);
    DEALLOCATE(gIsSubprimeBit, allocSize);
    DEALLOCATE(gPopcntBlock, allocSize);
  END;

  gSieveMax := limit;
  numOdds := limit DIV 2;
  numWords := (numOdds DIV 64) + 1;
  allocSize := VAL(CARDINAL, numWords * 8);

  ALLOCATE(gIsSubprimeBit, allocSize);
  ALLOCATE(gPopcntBlock, allocSize);

  wIter := 0;
  WHILE wIter < numWords DO
    gIsSubprimeBit^[wIter] := 18446744073709551615; (* 0xFFFFFFFFFFFFFFFF *)
    wIter := wIter + 1;
  END;
  gIsSubprimeBit^[0] := gIsSubprimeBit^[0] - 1; (* clear bit 0 *)

  sqrtLim := VAL(CARDINAL64, TRUNC(sqrt(VAL(REAL, limit))));
  iVal := 3;
  WHILE iVal <= sqrtLim DO
    iOdd := (iVal - 1) DIV 2;
    wIdx := iOdd DIV 64;
    bIdx := iOdd MOD 64;
    bitM := gPow2[VAL(CARDINAL, bIdx)];
    wVal := (gIsSubprimeBit^[wIdx] DIV bitM) MOD 2;
    IF wVal = 1 THEN
      i2Val := iVal + iVal;
      jVal := iVal * iVal;
      WHILE jVal <= limit DO
        jOdd := (jVal - 1) DIV 2;
        jw := jOdd DIV 64;
        jb := jOdd MOD 64;
        mask := gPow2[VAL(CARDINAL, jb)];
        IF ((gIsSubprimeBit^[jw] DIV mask) MOD 2) = 1 THEN
          gIsSubprimeBit^[jw] := gIsSubprimeBit^[jw] - mask;
        END;
        jVal := jVal + i2Val;
      END;
    END;
    iVal := iVal + 2;
  END;

  gPopcntBlock^[0] := 1; (* Prime 2 *)
  wIter := 0;
  WHILE wIter < (numWords - 1) DO
    prevCnt := gPopcntBlock^[wIter];
    gPopcntBlock^[wIter + 1] := prevCnt + PopCount64(gIsSubprimeBit^[wIter]);
    wIter := wIter + 1;
  END;
END BuildBitSieve;

PROCEDURE PiFast (wVal : CARDINAL64;
                  primes : Card64Array;
                  numPrimes : CARDINAL) : CARDINAL64;
VAR
  res, kOdd, wIdx, bIdx, baseCnt, curWord : CARDINAL64;
  mask, maskedWord, subCnt : CARDINAL64;
BEGIN
  IF wVal <= 2 THEN
    res := wVal DIV 2;
  ELSIF (wVal <= gSieveMax) AND (gIsSubprimeBit # NIL) THEN
    kOdd := (wVal - 1) DIV 2;
    wIdx := kOdd DIV 64;
    bIdx := kOdd MOD 64;
    baseCnt := gPopcntBlock^[wIdx];
    curWord := gIsSubprimeBit^[wIdx];
    IF bIdx = 63 THEN
      maskedWord := curWord;
    ELSE
      mask := gPow2[VAL(CARDINAL, bIdx + 1)] - 1;
      maskedWord := curWord MOD (mask + 1);
    END;
    subCnt := PopCount64(maskedWord);
    res := baseCnt + subCnt;
  ELSE
    res := PrimeCountLehmer(wVal, primes, numPrimes);
  END;
  RETURN res;
END PiFast;

PROCEDURE PhiMemoized (xVal, aVal : CARDINAL64;
                       primes : Card64Array;
                       numPrimes : CARDINAL) : CARDINAL64;
VAR
  res, slot, pVal, leftVal, rightVal : CARDINAL64;
  p6, prod, piX : CARDINAL64;
BEGIN
  slot := (xVal + (aVal * 1140071481932319848)) MOD CacheSize;

  IF (gMemoX[slot] = xVal) AND (gMemoA[slot] = VAL(CARDINAL32, aVal)) THEN
    res := gMemoRes[slot];
    RETURN res;
  END;

  pVal := primes^[aVal];
  IF pVal > xVal THEN
    res := 1;
  ELSIF xVal <= gSieveMax THEN
    p6 := primes^[6];
    prod := p6 * pVal;
    IF xVal <= prod THEN
      piX := PiFast(xVal, primes, numPrimes);
      res := (piX - aVal) + 1;
    ELSE
      leftVal := PhiRec(xVal, aVal - 1, primes, numPrimes);
      rightVal := PhiRec(xVal DIV pVal, aVal - 1, primes, numPrimes);
      res := leftVal - rightVal;
    END;
  ELSE
    leftVal := PhiRec(xVal, aVal - 1, primes, numPrimes);
    rightVal := PhiRec(xVal DIV pVal, aVal - 1, primes, numPrimes);
    res := leftVal - rightVal;
  END;

  gMemoX[slot] := xVal;
  gMemoA[slot] := VAL(CARDINAL32, aVal);
  gMemoRes[slot] := res;
  RETURN res;
END PhiMemoized;

PROCEDURE PhiRec (xVal, aVal : CARDINAL64;
                  primes : Card64Array;
                  numPrimes : CARDINAL) : CARDINAL64;
VAR
  res, pVal, leftVal, rightVal : CARDINAL64;
BEGIN
  IF xVal = 0 THEN
    res := 0;
  ELSIF aVal = 0 THEN
    res := xVal;
  ELSIF aVal = 1 THEN
    res := xVal - (xVal DIV 2);
  ELSIF aVal = 2 THEN
    res := xVal - (xVal DIV 2) - (xVal DIV 3) + (xVal DIV 6);
  ELSIF (aVal >= 3) AND (aVal <= 5) THEN
    pVal := primes^[aVal];
    leftVal := PhiRec(xVal, aVal - 1, primes, numPrimes);
    rightVal := PhiRec(xVal DIV pVal, aVal - 1, primes, numPrimes);
    res := leftVal - rightVal;
  ELSIF aVal = 6 THEN
    res := Phi6(xVal);
  ELSE
    res := PhiMemoized(xVal, aVal, primes, numPrimes);
  END;
  RETURN res;
END PhiRec;

PROCEDURE LehmerSum2 (xVal, aVal, bVal, cVal : CARDINAL64;
                      primes : Card64Array;
                      numPrimes : CARDINAL) : CARDINAL64;
VAR
  res, p2, p3, iIdx, jIdx, pI, pJ, wVal : CARDINAL64;
  piW, piW2, sqrtW, biVal : CARDINAL64;
BEGIN
  p2 := 0;
  iIdx := aVal + 1;
  WHILE iIdx <= bVal DO
    pI := primes^[iIdx];
    wVal := xVal DIV pI;
    piW := PiFast(wVal, primes, numPrimes);
    p2 := p2 + (piW - (iIdx - 1));
    iIdx := iIdx + 1;
  END;

  p3 := 0;
  iIdx := aVal + 1;
  WHILE iIdx <= cVal DO
    pI := primes^[iIdx];
    wVal := xVal DIV pI;
    sqrtW := VAL(CARDINAL64, TRUNC(sqrt(VAL(REAL, wVal))));
    biVal := PiFast(sqrtW, primes, numPrimes);
    jIdx := iIdx;
    WHILE jIdx <= biVal DO
      pJ := primes^[jIdx];
      piW2 := PiFast(wVal DIV pJ, primes, numPrimes);
      p3 := p3 + (piW2 - (jIdx - 1));
      jIdx := jIdx + 1;
    END;
    iIdx := iIdx + 1;
  END;

  res := p2 + p3;
  RETURN res;
END LehmerSum2;

PROCEDURE PrimeCountLehmer (xVal : CARDINAL64;
                            primes : Card64Array;
                            numPrimes : CARDINAL) : CARDINAL64;
VAR
  countVal, aVal, bVal, cVal, phiVal, sumP2P3 : CARDINAL64;
  sqX, sqSqX, cbX : REAL;
BEGIN
  IF xVal < 2 THEN
    countVal := 0;
  ELSIF xVal <= gSieveMax THEN
    countVal := PiFast(xVal, primes, numPrimes);
  ELSE
    sqX := sqrt(VAL(REAL, xVal));
    sqSqX := sqrt(sqX);
    aVal := PiFast(VAL(CARDINAL64, TRUNC(sqSqX)), primes, numPrimes);
    bVal := PiFast(VAL(CARDINAL64, TRUNC(sqX)), primes, numPrimes);
    cbX := power(VAL(REAL, xVal), 0.3333333333333333);
    cVal := PiFast(VAL(CARDINAL64, TRUNC(cbX)), primes, numPrimes);

    phiVal := PhiRec(xVal, aVal, primes, numPrimes);
    sumP2P3 := LehmerSum2(xVal, aVal, bVal, cVal, primes, numPrimes);
    countVal := (phiVal + aVal - 1) - sumP2P3;
  END;
  RETURN countVal;
END PrimeCountLehmer;

PROCEDURE OEISAnchorSmall (n : CARDINAL64) : CARDINAL64;
VAR
  est : CARDINAL64;
BEGIN
  est := 0;
  IF n = 1 THEN est := 2;
  ELSIF n = 10 THEN est := 29;
  ELSIF n = 100 THEN est := 541;
  ELSIF n = 1000 THEN est := 7919;
  ELSIF n = 10000 THEN est := 104729;
  END;
  RETURN est;
END OEISAnchorSmall;

PROCEDURE OEISAnchorLarge (n : CARDINAL64) : CARDINAL64;
VAR
  est : CARDINAL64;
BEGIN
  est := 0;
  IF n = 100000 THEN est := 1299709;
  ELSIF n = 1000000 THEN est := 15485863;
  ELSIF n = 10000000 THEN est := 179424673;
  ELSIF n = 100000000 THEN est := 2038074743;
  ELSIF n = 1000000000 THEN est := 22801763489;
  END;
  RETURN est;
END OEISAnchorLarge;

PROCEDURE EstimateInitialX (n : CARDINAL64) : CARDINAL64;
VAR
  x0 : CARDINAL64;
  fn, logN, logLog, term1, term2, num3, frac3 : REAL;
  logLogSq, logNSq, num4, den4, frac4, factor, rawEst : REAL;
BEGIN
  x0 := OEISAnchorSmall(n);
  IF x0 = 0 THEN
    x0 := OEISAnchorLarge(n);
  END;
  IF x0 = 0 THEN
    fn := VAL(REAL, n);
    logN := ln(fn);
    logLog := ln(logN);
    term1 := logN + logLog;
    term2 := term1 - 1.0;
    num3 := logLog - 2.0;
    frac3 := num3 / logN;
    logLogSq := logLog * logLog;
    logNSq := logN * logN;
    num4 := logLogSq - (6.0 * logLog) + 11.0;
    den4 := 2.0 * logNSq;
    frac4 := num4 / den4;
    factor := term2 + frac3 - frac4;
    rawEst := fn * factor;
    x0 := VAL(CARDINAL64, TRUNC(rawEst));
  END;
  RETURN x0;
END EstimateInitialX;

PROCEDURE SieveSegmentFindNth (lowVal, highVal : CARDINAL64;
                              basePrimes : Card64Array;
                              baseCount : CARDINAL;
                              targetN, startPi : CARDINAL64) : CARDINAL64;
VAR
  resultPrime, rangeDiff, rangeLen, numWords : CARDINAL64;
  idx, pVal, pSq, startVal, diffS, wIdx, bIdx, val, diffV : CARDINAL64;
  currentCount, bitM : CARDINAL64;
  sieve : Word64Array;
  allocSize : CARDINAL;
BEGIN
  rangeDiff := highVal - lowVal;
  rangeLen := rangeDiff + 1;
  numWords := (rangeLen + 63) DIV 64;
  IF numWords = 0 THEN numWords := 1; END;

  allocSize := VAL(CARDINAL, numWords * 8);
  ALLOCATE(sieve, allocSize);

  wIdx := 0;
  WHILE wIdx < numWords DO
    sieve^[wIdx] := 18446744073709551615;
    wIdx := wIdx + 1;
  END;

  idx := 1;
  WHILE idx <= VAL(CARDINAL64, baseCount) DO
    pVal := basePrimes^[idx];
    pSq := pVal * pVal;
    IF pSq > highVal THEN
      idx := VAL(CARDINAL64, baseCount) + 1;
    ELSE
      startVal := ((lowVal + pVal - 1) DIV pVal) * pVal;
      IF startVal < pSq THEN startVal := pSq; END;
      WHILE startVal <= highVal DO
        diffS := startVal - lowVal;
        wIdx := diffS DIV 64;
        bIdx := diffS MOD 64;
        bitM := gPow2[VAL(CARDINAL, bIdx)];
        IF ((sieve^[wIdx] DIV bitM) MOD 2) = 1 THEN
          sieve^[wIdx] := sieve^[wIdx] - bitM;
        END;
        startVal := startVal + pVal;
      END;
      idx := idx + 1;
    END;
  END;

  currentCount := startPi;
  resultPrime := 0;
  val := lowVal;
  WHILE val <= highVal DO
    diffV := val - lowVal;
    wIdx := diffV DIV 64;
    bIdx := diffV MOD 64;
    bitM := gPow2[VAL(CARDINAL, bIdx)];
    IF ((sieve^[wIdx] DIV bitM) MOD 2) = 1 THEN
      currentCount := currentCount + 1;
      IF currentCount = targetN THEN
        resultPrime := val;
        val := highVal; (* exit loop *)
      END;
    END;
    val := val + 1;
  END;

  DEALLOCATE(sieve, allocSize);
  RETURN resultPrime;
END SieveSegmentFindNth;

PROCEDURE SieveSegmentFindBackward (lowVal, highVal : CARDINAL64;
                                  basePrimes : Card64Array;
                                  baseCount : CARDINAL;
                                  targetN, startPi : CARDINAL64) : CARDINAL64;
VAR
  resultPrime, rangeDiff, rangeLen, numWords : CARDINAL64;
  idx, pVal, pSq, startVal, diffS, wIdx, bIdx, val, diffV : CARDINAL64;
  currentCount, bitM : CARDINAL64;
  sieve : Word64Array;
  allocSize : CARDINAL;
BEGIN
  rangeDiff := highVal - lowVal;
  rangeLen := rangeDiff + 1;
  numWords := (rangeLen + 63) DIV 64;
  IF numWords = 0 THEN numWords := 1; END;

  allocSize := VAL(CARDINAL, numWords * 8);
  ALLOCATE(sieve, allocSize);

  wIdx := 0;
  WHILE wIdx < numWords DO
    sieve^[wIdx] := 18446744073709551615;
    wIdx := wIdx + 1;
  END;

  idx := 1;
  WHILE idx <= VAL(CARDINAL64, baseCount) DO
    pVal := basePrimes^[idx];
    pSq := pVal * pVal;
    IF pSq > highVal THEN
      idx := VAL(CARDINAL64, baseCount) + 1;
    ELSE
      startVal := ((lowVal + pVal - 1) DIV pVal) * pVal;
      IF startVal < pSq THEN startVal := pSq; END;
      WHILE startVal <= highVal DO
        diffS := startVal - lowVal;
        wIdx := diffS DIV 64;
        bIdx := diffS MOD 64;
        bitM := gPow2[VAL(CARDINAL, bIdx)];
        IF ((sieve^[wIdx] DIV bitM) MOD 2) = 1 THEN
          sieve^[wIdx] := sieve^[wIdx] - bitM;
        END;
        startVal := startVal + pVal;
      END;
      idx := idx + 1;
    END;
  END;

  currentCount := startPi;
  resultPrime := 0;
  val := highVal;
  WHILE val >= lowVal DO
    diffV := val - lowVal;
    wIdx := diffV DIV 64;
    bIdx := diffV MOD 64;
    bitM := gPow2[VAL(CARDINAL, bIdx)];
    IF ((sieve^[wIdx] DIV bitM) MOD 2) = 1 THEN
      IF currentCount = targetN THEN
        resultPrime := val;
        val := lowVal; (* exit loop *)
      END;
      currentCount := currentCount - 1;
    END;
    IF val = 0 THEN
      val := lowVal - 1; (* prevent underflow *)
    ELSE
      val := val - 1;
    END;
  END;

  DEALLOCATE(sieve, allocSize);
  RETURN resultPrime;
END SieveSegmentFindBackward;

PROCEDURE NthPrimeRefine (nVal, currXIn : CARDINAL64;
                          basePrimes : Card64Array;
                          baseCount : CARDINAL) : CARDINAL64;
VAR
  pn, currX, currPi, diffN, absDiff, window : CARDINAL64;
  lowVal, highVal, stepVal : CARDINAL64;
  fX, logX, estW : REAL;
BEGIN
  currX := currXIn;
  currPi := PrimeCountLehmer(currX, basePrimes, baseCount);

  WHILE (currPi + 2000 < nVal) OR (nVal + 2000 < currPi) DO
    fX := VAL(REAL, currX);
    logX := ln(fX);
    IF nVal > currPi THEN
      diffN := nVal - currPi;
      stepVal := VAL(CARDINAL64, TRUNC(VAL(REAL, diffN) * logX));
      currX := currX + stepVal;
    ELSE
      diffN := currPi - nVal;
      stepVal := VAL(CARDINAL64, TRUNC(VAL(REAL, diffN) * logX));
      IF currX > stepVal THEN
        currX := currX - stepVal;
      ELSE
        currX := 2;
      END;
    END;
    currPi := PrimeCountLehmer(currX, basePrimes, baseCount);
  END;

  IF nVal > currPi THEN
    absDiff := nVal - currPi;
  ELSE
    absDiff := currPi - nVal;
  END;

  fX := VAL(REAL, currX);
  logX := ln(fX);
  estW := VAL(REAL, absDiff) * logX * 2.5;
  window := VAL(CARDINAL64, TRUNC(estW)) + 1000;
  IF window < 2000 THEN window := 2000; END;

  IF nVal >= currPi THEN
    lowVal := currX + 1;
    highVal := currX + window;
    pn := SieveSegmentFindNth(lowVal, highVal, basePrimes, baseCount, nVal, currPi);
  ELSE
    lowVal := 2;
    IF currX > window THEN lowVal := currX - window; END;
    pn := SieveSegmentFindBackward(lowVal, currX, basePrimes, baseCount, nVal, currPi);
  END;
  RETURN pn;
END NthPrimeRefine;

PROCEDURE GetNthPrimeU64 (nVal : CARDINAL64) : CARDINAL64;
VAR
  pn, currX, zVal, sieveLimit, zPlus, piZ : CARDINAL64;
  cand, candOdd, wIdx, bIdx, countP, bitM, s34 : CARDINAL64;
  basePrimes : Card64Array;
  fX, sqX, pow34 : REAL;
  allocPrimes : CARDINAL;
BEGIN
  InitBaseTables;
  IF nVal = 0 THEN pn := 0;
  ELSIF nVal = 1 THEN pn := 2;
  ELSIF nVal = 2 THEN pn := 3;
  ELSIF nVal = 3 THEN pn := 5;
  ELSIF nVal = 4 THEN pn := 7;
  ELSIF nVal = 5 THEN pn := 11;
  ELSE
    currX := EstimateInitialX(nVal);
    fX := VAL(REAL, currX);
    sqX := sqrt(fX);
    zVal := VAL(CARDINAL64, TRUNC(sqX));

    sieveLimit := zVal * 12;
    pow34 := power(fX, 0.75);
    s34 := VAL(CARDINAL64, TRUNC(pow34 + 10000.0));
    IF sieveLimit < s34 THEN sieveLimit := s34; END;
    IF sieveLimit < 1000000 THEN sieveLimit := 1000000; END;
    IF (currX <= 20000000) AND (sieveLimit < currX) THEN
      sieveLimit := currX;
    END;

    BuildBitSieve(sieveLimit);
    zPlus := zVal + 1000;
    piZ := PiFast(zPlus, NIL, 0);

    allocPrimes := VAL(CARDINAL, (piZ + 1000) * 8);
    ALLOCATE(basePrimes, allocPrimes);

    basePrimes^[1] := 2;
    countP := 1;
    cand := 3;
    WHILE cand <= zPlus DO
      candOdd := (cand - 1) DIV 2;
      wIdx := candOdd DIV 64;
      bIdx := candOdd MOD 64;
      bitM := gPow2[VAL(CARDINAL, bIdx)];
      IF ((gIsSubprimeBit^[wIdx] DIV bitM) MOD 2) = 1 THEN
        countP := countP + 1;
        basePrimes^[countP] := cand;
      END;
      cand := cand + 2;
    END;

    InitPhi6Table;
    wIdx := 0;
    WHILE wIdx < CacheSize DO
      gMemoX[wIdx] := 0;
      wIdx := wIdx + 1;
    END;

    pn := NthPrimeRefine(nVal, currX, basePrimes, VAL(CARDINAL, countP));
    DEALLOCATE(basePrimes, allocPrimes);
  END;
  RETURN pn;
END GetNthPrimeU64;

PROCEDURE GetNthPrimeStr (VAR outStr : ARRAY OF CHAR;
                          inStr : ARRAY OF CHAR);
VAR
  nVal, digit, p : CARDINAL64;
  i, len, outIdx : CARDINAL;
  ch : CHAR;
  digits : ARRAY [0..31] OF CHAR;
  dIdx : CARDINAL;
BEGIN
  nVal := 0;
  i := 0;
  len := 0;
  WHILE (len <= HIGH(inStr)) AND (inStr[len] # 0C) DO
    len := len + 1;
  END;
  WHILE i < len DO
    ch := inStr[i];
    IF (ch >= '0') AND (ch <= '9') THEN
      digit := VAL(CARDINAL64, ORD(ch) - ORD('0'));
      nVal := (nVal * 10) + digit;
    END;
    i := i + 1;
  END;

  p := GetNthPrimeU64(nVal);

  IF p = 0 THEN
    outStr[0] := '0';
    outStr[1] := 0C;
  ELSE
    dIdx := 0;
    WHILE p > 0 DO
      digits[dIdx] := CHR(ORD('0') + VAL(CARDINAL, p MOD 10));
      p := p DIV 10;
      dIdx := dIdx + 1;
    END;
    outIdx := 0;
    WHILE dIdx > 0 DO
      dIdx := dIdx - 1;
      outStr[outIdx] := digits[dIdx];
      outIdx := outIdx + 1;
    END;
    outStr[outIdx] := 0C;
  END;
END GetNthPrimeStr;

BEGIN
  gPhi6Initialized := FALSE;
  gTablesInitialized := FALSE;
  gIsSubprimeBit := NIL;
  gPopcntBlock := NIL;
  gSieveMax := 0;
END NthPrime64.
