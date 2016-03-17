REM $Id: reporteqbool.p101.pro,v 1.1 2001/11/30 23:10:08 bill Exp $
REM From "Learning Oracle PL/SQL" page 101

REM Version of reporteq results-checking utility that accepts Boolean
REM parameters.  For another way to implement this, see the file
REM reporteqbool.p102.pro.

REM Note: In the first printing of this book, this procedure was incorrectly
REM listed as reporteqnum.  The correct code is below.

CREATE OR REPLACE PROCEDURE reporteqbool (description IN VARCHAR2,
      expected_value IN BOOLEAN, actual_value IN BOOLEAN) AS
BEGIN
   DBMS_OUTPUT.PUT(description || ': ');
   IF (expected_value AND actual_value)
      OR (expected_value IS NULL AND actual_value IS NULL)
   THEN
      DBMS_OUTPUT.PUT_LINE('PASSED');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAILED.');
   END IF;
END;
/

SHOW ERRORS

