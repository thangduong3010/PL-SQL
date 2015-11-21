/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM TRIGGER-1
SELECT TO_CHAR(SYSDATE, 'DY') FROM dual;

CREATE OR REPLACE TRIGGER security_time_check
     BEFORE DELETE OR UPDATE ON employee
DECLARE
     dy_of_week   CHAR(3);
     hh_of_day    NUMBER(2);
BEGIN
     dy_of_week := TO_CHAR(SYSDATE,'DY');
     hh_of_day := TO_CHAR(SYSDATE,'HH24');
   
/*
If you wish to test this logic, change the next statement to refer to the present day of the week. Then replace the trigger and attempt an UPDATE or DELETE operation.
*/
     IF dy_of_week IN ('TUE', 'SUN')
     OR hh_of_day NOT BETWEEN 8 AND 17 THEN
          RAISE_APPLICATION_ERROR(-20600,
                      'Transaction rejected for security reasons');
     END IF;
END;
/

DELETE FROM employee;

REM TRIGGER-2
CREATE OR REPLACE TRIGGER DepartmentIntegrity
	BEFORE UPDATE OF mgrssn ON DEPARTMENT
   FOR EACH ROW
DECLARE
 	x_dno	employee.dno%TYPE;
BEGIN
	SELECT dno
	INTO x_dno
	FROM employee
	WHERE employee.ssn = :new.mgrssn;

	IF x_dno <> :new.dnumber THEN
      RAISE_APPLICATION_ERROR(-20000, 'Manager must be promoted from within the department');
 	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20001, 'Manager is not a current employee');
END;
/

SELECT lname, ssn, dname, dno
FROM employee
INNER JOIN department ON (dno = dnumber);

UPDATE department
  SET MgrSSN = 123456789
  WHERE Dname = 'Research';

UPDATE department
  SET MgrSSN = 987987987
  WHERE DName = 'Research';

UPDATE department
  SET MgrSSN = 111111111
  WHERE DName = 'Research';

REM TRIGGER-3
CREATE OR REPLACE VIEW employee_department_info
      (employee_name, department_name, employee_ssn) AS
   SELECT lname, dname, ssn
   FROM employee
   INNER JOIN department ON (employee.dno = department.dnumber)
   ORDER BY lname;

SELECT *
FROM employee_department_info;

DELETE FROM employee_department_info
WHERE employee_ssn = 123456789;

CREATE OR REPLACE TRIGGER manage_delete
INSTEAD OF DELETE ON employee_department_info
   DECLARE
   BEGIN
      DELETE FROM employee
      WHERE ssn = :old.employee_ssn;
   END;
/

DELETE FROM employee_department_info
WHERE employee_ssn = 123456789;

SELECT *
FROM employee_department_info;

SELECT ssn, lname
FROM employee;











