MODULE MainM2;

(* MainM2.mod - Standalone CLI runner for Modula-2 nth-prime engine.
 * ISO Modula-2 standard (gm2 / GCC 16.1).
 *)

FROM NthPrime64 IMPORT GetNthPrimeStr;
FROM ProgramArgs IMPORT IsArgPresent, NextArg, ArgChan;
FROM IOChan IMPORT ChanId;
FROM TextIO IMPORT ReadToken;
FROM STextIO IMPORT WriteString, WriteLn, ReadString;

VAR
  argStr : ARRAY [0..255] OF CHAR;
  outStr : ARRAY [0..255] OF CHAR;
  hasArg : BOOLEAN;
  cid    : ChanId;

BEGIN
  hasArg := IsArgPresent();
  IF hasArg THEN
    cid := ArgChan();
    ReadToken(cid, argStr);
  ELSE
    ReadString(argStr);
  END;

  GetNthPrimeStr(outStr, argStr);
  WriteString(outStr);
  WriteLn;
END MainM2.

