REM $Id: reporteqbool.pro,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 102

REM Version of reporteqbool that reuses reporteq procedure rather than
REM duplicating its functionality.  Compare reporteqbool.p101.pro.

CREATE OR REPLACE PROCEDURE reporteqbool (description IN VARCHAR2,
      expected_value IN BOOLEAN, actual_value IN BOOLEAN)
AS
BEGIN
   reporteq(description, booleantochar(expected_value),
      booleantochar(actual_value));
END reporteqbool;
/

SHOW ERRORS

