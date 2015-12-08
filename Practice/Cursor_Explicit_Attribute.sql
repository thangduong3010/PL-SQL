SET SERVEROUTPUT ON

DECLARE
   CURSOR Employees
   IS
        SELECT *
          FROM employee
      ORDER BY salary DESC;

   empRec   employee%ROWTYPE;
BEGIN
   IF NOT (Employees%ISOPEN)
   THEN
      OPEN Employees;
   END IF;

   LOOP
      FETCH Employees INTO empRec;

      EXIT WHEN Employees%NOTFOUND;
      CONTINUE WHEN empRec.superssn IS NULL;

      DBMS_OUTPUT.put_line (
            'Employee('
         || Employees%ROWCOUNT
         || ') - '
         || empRec.lname
         || ': $'
         || empRec.salary
         || ' SuperSSN: '
         || empRec.superssn);
   END LOOP;

   IF (Employees%ISOPEN)
   THEN
      CLOSE Employees;
   END IF;
END;