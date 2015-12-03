SET SERVEROUTPUT ON

DECLARE
   TYPE EmpRecord IS RECORD
   (
      ssn     EMPLOYEE.SSN%TYPE,
      lname   EMPLOYEE.LNAME%TYPE,
      dname   DEPARTMENT.DNAME%TYPE
   );

   myEmp   EmpRecord;
BEGIN
   SELECT e.ssn, e.lname, d.dname
     INTO myEmp
     FROM employee e
          INNER JOIN department d ON (e.dno = d.dnumber)
          INNER JOIN works_on w ON (e.ssn = w.essn)
    WHERE hours = (SELECT MIN (hours) FROM works_on) AND ROWNUM <= 1;

   DBMS_OUTPUT.put_line (
      'Least active employee to be transferred: ' || myEmp.lname);

   UPDATE department
      SET mgrssn = NULL
    WHERE mgrssn = myEmp.ssn;

   IF SQL%FOUND
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Department removed as manager: ' || SQL%ROWCOUNT);
   ELSE
      DBMS_OUTPUT.put_line ('He''s not manager of any department');
   END IF;

   UPDATE employee
      SET superssn = NULL
    WHERE superssn = myEmp.ssn;

   IF SQL%FOUND
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Employee removed as supervisor: ' || SQL%ROWCOUNT);
   ELSE
      DBMS_OUTPUT.put_line ('He''s not a supervisor');
   END IF;

   DELETE FROM dependent
         WHERE essn = myEmp.ssn;

   IF SQL%FOUND
   THEN
      DBMS_OUTPUT.PUT_LINE ('Dependent record deleted: ' || SQL%ROWCOUNT);
   ELSE
      DBMS_OUTPUT.put_line ('He has noone depends on');
   END IF;

   DELETE FROM works_on
         WHERE essn = myEmp.ssn;

   IF SQL%FOUND
   THEN
      DBMS_OUTPUT.PUT_LINE ('Works_on record deleted: ' || SQL%ROWCOUNT);
   ELSE
      DBMS_OUTPUT.put_line ('No delete on works_on');
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('No need to transfer anybody');
END;