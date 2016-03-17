REM $Id: lp.fun,v 1.1 2001/11/30 23:26:32 bill Exp $
REM From "Learning Oracle PL/SQL" page 300

REM Creating PL/SQL cover function "lp" that will call the "lp" function in
REM the lplib library

CREATE OR REPLACE FUNCTION lp (text IN VARCHAR2)
RETURN PLS_INTEGER
AS 
   LANGUAGE C
   LIBRARY lplib
   NAME "lp"
   PARAMETERS (text STRING, RETURN INT);
/

SHOW ERRORS

