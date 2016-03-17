REM $Id: reporteq.pro,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 84

REM Results-checking utility useful when testing stored programs

CREATE OR REPLACE PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN VARCHAR2, actual_value IN VARCHAR2)
AS
BEGIN
   DBMS_OUTPUT.PUT(description || ': ');

   IF expected_value = actual_value
      OR (expected_value IS NULL AND actual_value IS NULL)
   THEN
      DBMS_OUTPUT.PUT_LINE('PASSED');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAILED.  Expected ' || expected_value
         || '; got ' || actual_value);
   END IF;
END;
/

SHOW ERRORS

