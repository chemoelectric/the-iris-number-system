MODULE MainM2;

(* MainM2.mod - Standalone CLI runner for Modula-2 nth-prime engine.
 * ISO Modula-2 standard (gm2 / GCC 16.1).
 *)

FROM SYSTEM IMPORT CARDINAL64;
FROM NthPrime64 IMPORT GetNthPrimeU64, GetNthPrimeStr;
FROM ProgramArgs IMPORT IsArgPresent, NextArg, ReadArg;
FROM STextIO IMPORT WriteString, WriteLn, ReadString, SkipLine;
FROM SWholeIO IMPORT WriteCard;

VAR
  argStr : ARRAY [0..255] OF CHAR;
  outStr : ARRAY [0..255] OF CHAR;
  hasArg : BOOLEAN;

BEGIN
  hasArg := IsArgPresent();
  IF hasArg THEN
    NextArg(argStr);
  ELSE
    ReadString(argStr);
  END;

  GetNthPrimeStr(outStr, argStr);
  WriteString(outStr);
  WriteLn;
END MainM2.
