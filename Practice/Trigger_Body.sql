CREATE OR REPLACE PROCEDURE check_promotion (
   ManagerSSN   IN department.mgrssn%TYPE,
   DeptNumb     IN department.dnumber%TYPE)
IS
   x_dno   employee.dno%TYPE;
BEGIN
   SELECT dno
     INTO x_dno
     FROM employee
    WHERE ssn = ManagerSSN;

   IF x_dno != DeptNumb
   THEN
      raise_application_error (
         -20000,
         'Manager must be promoted from within the department');
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      raise_application_error (-20001, 'Manager is not a current employee');
END;