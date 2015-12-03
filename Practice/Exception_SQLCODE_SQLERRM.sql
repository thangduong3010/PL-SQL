SET SERVEROUTPUT ON

DECLARE
BEGIN
   UPDATE employee
      SET lname = NULL;

   DBMS_OUTPUT.put_line ('Failure: Missed the exception');
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error code: ' || SQLCODE);
      DBMS_OUTPUT.put_line ('Error message: ' || SQLERRM);
END;