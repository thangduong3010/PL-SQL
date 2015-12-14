SET SERVEROUTPUT ON

DECLARE
   EmpLname   employee.lname%TYPE;
   EmpSSN     employee.ssn%TYPE := '&enter_ssn';

   PROCEDURE Display (MessageText VARCHAR2)
   IS
      TempMessageText   VARCHAR2 (80);
   BEGIN
      IF LENGTH (MessageText) > 40
      THEN
         TempMessageText := SUBSTR (MessageText, 1, 40);
      ELSE
         TempMessageText :=
               'Message generated on '
            || TO_CHAR (SYSDATE, 'fmDay')
            || ': '
            || UPPER (MessageText);
      END IF;

      DBMS_OUTPUT.put_line (TempMessageText);
   END Display;
BEGIN
   SELECT lname
     INTO EmpLname
     FROM employee
    WHERE ssn = EmpSSN;

   Display ('Employee ' || EmpSSN || ' is ' || EmpLname);
EXCEPTION
   WHEN NO_DATA_FOUND OR TOO_MANY_ROWS
   THEN
      Display ('Database error');
   WHEN OTHERS
   THEN
      Display ('Unknown error');
END;