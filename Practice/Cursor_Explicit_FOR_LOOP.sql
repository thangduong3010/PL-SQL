SET SERVEROUTPUT ON

DECLARE
BEGIN
   FOR Employees IN (SELECT * FROM employee)
   LOOP
      DBMS_OUTPUT.put_line (
         'Employee ' || Employees.lname || ' earns $' || Employees.salary);
   END LOOP;
END;