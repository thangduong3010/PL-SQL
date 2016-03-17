REM $Id: tut.pkb,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3

REM Testing utilities package body (does not appear in book; REM left "as
REM an exercise to the reader")

CREATE OR REPLACE PACKAGE BODY tut
AS
   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN VARCHAR2, actual_value IN VARCHAR2)
   IS
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

   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN NUMBER, actual_value IN NUMBER)
   IS
   BEGIN
      reporteq(description, TO_CHAR(expected_value), TO_CHAR(actual_value));
   END;

   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN BOOLEAN, actual_value IN BOOLEAN)
   IS
   BEGIN
      reporteq(description, booleantochar(expected_value),
               booleantochar(actual_value));
   END;

   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN DATE, actual_value IN DATE)
   IS
   BEGIN
      reporteq(description, TO_CHAR(expected_value, 'YYYY-MON-DD HH24:MI:SS'),
               TO_CHAR(actual_value, 'YYYY-MON-DD HH24:MI:SS'));
   END;

END;
/

SHOW ERRORS

