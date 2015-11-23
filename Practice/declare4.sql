set serveroutput on;

DECLARE
  TYPE EmpRecord
  IS RECORD (ssn EMPLOYEE.SSN%TYPE,
            lname EMPLOYEE.LNAME%TYPE,
            dname DEPARTMENT.DNAME%TYPE,
            bonus number(6));

  ActiveEmp EmpRecord;
  InactiveEmp EmpRecord;

BEGIN
  SELECT ssn, lname, dname, 5000
  INTO ActiveEmp
  FROM employee e, department d, works_on w
  WHERE E.DNO = D.DNUMBER
  AND E.SSN = W.ESSN
  AND hours = (SELECT MAX(hours) FROM works_on)
  AND ROWNUM <= 1;
    
  SELECT ssn, lname, dname, 0
  INTO InactiveEmp
  FROM employee e, department d, works_on w
  WHERE E.DNO = D.DNUMBER
  AND E.SSN = W.ESSN
  AND hours = (SELECT MIN(hours) FROM works_on)
  AND ROWNUM <= 1;
    
  -- display output
  DBMS_OUTPUT.PUT_LINE('-----------Active Employee------------');
  DBMS_OUTPUT.PUT_LINE('Name: ' || ActiveEmp.lname);
  DBMS_OUTPUT.PUT_LINE('SSN: ' || ActiveEmp.ssn);
  DBMS_OUTPUT.PUT_LINE('Department: ' || ActiveEmp.dname);
  DBMS_OUTPUT.PUT_LINE('Bonus: ' || ActiveEmp.bonus);    
    
  DBMS_OUTPUT.PUT_LINE('-----------Inactive Employee------------');
  DBMS_OUTPUT.PUT_LINE('Name: ' || InactiveEmp.lname);
  DBMS_OUTPUT.PUT_LINE('SSN: ' || InactiveEmp.ssn);
  DBMS_OUTPUT.PUT_LINE('Department: ' || InactiveEmp.dname);
  DBMS_OUTPUT.PUT_LINE('Bonus: ' || InactiveEmp.bonus); 
    
END;
