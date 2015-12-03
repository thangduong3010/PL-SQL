SET SERVEROUTPUT ON

DECLARE
   not_null_constraint   EXCEPTION;

   PRAGMA EXCEPTION_INIT (not_null_constraint, -1407);
BEGIN
   UPDATE employee
      SET lname = NULL;

   DBMS_OUTPUT.put_line ('Failure: Missed the exception');
EXCEPTION
   WHEN not_null_constraint
   THEN
      DBMS_OUTPUT.put_line ('Success: exception trapped');
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Failure: exception missed');
END;