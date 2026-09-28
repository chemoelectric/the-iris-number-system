MODULE MainM2;

(* MainM2.mod - Standalone CLI runner for Modula-2 nth-prime engine.
 * ISO / GNU Modula-2 standard.
 *)

FROM NthPrime64 IMPORT GetNthPrimeStr;
FROM Args IMPORT Narg, GetArg;
FROM STextIO IMPORT WriteString, WriteLn, ReadString;

VAR
  argStr : ARRAY [0..255] OF CHAR;
  outStr : ARRAY [0..255] OF CHAR;
  numArgs: CARDINAL;
  ok     : BOOLEAN;

BEGIN
  numArgs := Narg();
  IF numArgs > 1 THEN
    ok := GetArg(argStr, 1);
  ELSE
    ReadString(argStr);
  END;

  GetNthPrimeStr(outStr, argStr);
  WriteString(outStr);
  WriteLn;
END MainM2.

