SET SERVEROUTPUT ON

DECLARE
   TYPE EmpRecord IS RECORD
   (
      ssn            employee.ssn%TYPE,
      lname          employee.lname%TYPE,
      dname          department.dname%TYPE,
      BonusPayment   NUMBER (6)
   );

   ActiveEmp     EmpRecord;
   InactiveEmp   EmpRecord;
BEGIN
  <<LocateActive>>
   SELECT essn,
          lname,
          dname,
          5000
     INTO ActiveEmp
     FROM employee e
          INNER JOIN department d ON e.dno = D.DNUMBER
          INNER JOIN works_on w ON E.SSN = w.essn
    WHERE hours = (SELECT MAX (hours) FROM works_on) AND ROWNUM <= 1;

  <<OutputActive>>
   DBMS_OUTPUT.put_line ('Active employee name: ' || ActiveEmp.lname);
   DBMS_OUTPUT.put_line ('Active employee department: ' || ActiveEmp.dname);
   DBMS_OUTPUT.put_line ('Active emloyee bonus: ' || ActiveEmp.BonusPayment);

  <<LocateInactive>>
   SELECT essn,
          lname,
          dname,
          0
     INTO InactiveEmp
     FROM employee e
          INNER JOIN department d ON e.dno = D.DNUMBER
          INNER JOIN works_on w ON E.SSN = w.essn
    WHERE hours = (SELECT MIN (hours) FROM works_on) AND ROWNUM <= 1;

   -- Test whether active and inactive are the same
   IF ActiveEmp.ssn = InactiveEmp.ssn
   THEN
      GOTO Conclusion;
   END IF;

  <<OutputInactive>>
   DBMS_OUTPUT.put_line (' ');
   DBMS_OUTPUT.put_line ('Inactive employee name: ' || InactiveEmp.lname);
   DBMS_OUTPUT.put_line (
      'Inactive employee department: ' || InactiveEmp.dname);
   DBMS_OUTPUT.put_line (
      'Inactive employee bonus: ' || InactiveEmp.BonusPayment);

  <<Conclusion>>
   NULL;
END;