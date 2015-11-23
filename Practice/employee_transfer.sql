SET SERVEROUTPUT ON

DECLARE
   -- declare record
   TYPE EmpRecord IS RECORD
   (
      ssn            employee.ssn%TYPE,
      lname          employee.lname%TYPE,
      dname          department.dname%TYPE,
      BonusPayment   NUMBER (6)
   );

   -- define variable
   InactiveEmp   EmpRecord;
BEGIN
   -- retrieve employee who is the least active
   SELECT essn,
          lname,
          dname,
          0
     INTO InactiveEmp
     FROM employee e
          INNER JOIN department d ON E.DNO = d.dnumber
          INNER JOIN works_on w ON e.ssn = w.essn
    WHERE hours = (SELECT MIN (hours) FROM works_on) AND ROWNUM <= 1;


   -- remove this employee as manager of any department
   UPDATE department
      SET mgrssn = NULL
    WHERE mgrssn = InactiveEmp.ssn;

   -- remove this employee as supervisor of other employees
   UPDATE employee
      SET superssn = NULL
    WHERE superssn = InactiveEmp.ssn;

   /* delete this employee
   delete from employee
   where ssn = InactiveEmp.ssn;*/
   

   DBMS_OUTPUT.put_line ('Employee who is removed: ' || InactiveEmp.lname);
   
END;
