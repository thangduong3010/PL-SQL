/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM PROCEDURE MAINTENANCE-1
ALTER PROCEDURE raise_salary COMPILE;

ALTER FUNCTION salary_valid COMPILE;

REM PROCEDURE MAINTENANCE-2
SELECT object_name, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION');

SELECT DISTINCT name, type
FROM user_source;

REM PROCEDURE MAINTENANCE-3
DROP PROCEDURE raise_salary;

DROP FUNCTION salary_valid_result;

CREATE SEQUENCE department_sequence
    START WITH 10
    MAXVALUE 99;

REM PROCEDURE MAINTENANCE-4
CREATE OR REPLACE FUNCTION is_manager (input_ssn IN employee.ssn%TYPE)
RETURN BOOLEAN IS
    manager_count  NUMBER;
/*
Use the input parameter to see if this employee is currently the manager of any departments, as indicated by the MGRSSN column of the DEPARTMENT table. Return an appropriate function result based upon the finding.
*/
BEGIN
    SELECT  COUNT(mgrssn)
    INTO    manager_count
    FROM    department
    WHERE   mgrssn = input_ssn;

    IF manager_count > 0 THEN
         RETURN (TRUE);
    ELSE
         RETURN (FALSE);
    END IF;
END is_manager;
/

REM PROCEDURE MAINTENANCE-5
CREATE OR REPLACE FUNCTION is_supervisor (input_ssn IN employee.ssn%TYPE)
RETURN BOOLEAN IS
    supervisor_count  NUMBER;
BEGIN
    SELECT  COUNT(superssn)
    INTO    supervisor_count
    FROM    employee
    WHERE   superssn = input_ssn;

    IF supervisor_count > 0 THEN
         RETURN (TRUE);
    ELSE
         RETURN (FALSE);
    END IF;
END is_supervisor;
/

CREATE OR REPLACE PROCEDURE clear_dependents (input_ssn IN employee.ssn%TYPE)
IS
BEGIN
    DELETE FROM dependent
    WHERE essn = input_ssn;  
END clear_dependents;
/

CREATE OR REPLACE PROCEDURE clear_employment (input_ssn IN employee.ssn%TYPE)
IS
BEGIN
  DELETE FROM works_on
  WHERE essn = input_ssn;

  DELETE FROM employee
  WHERE ssn = input_ssn;

  IF is_supervisor (input_ssn) THEN
     UPDATE employee
     SET superssn = NULL
     WHERE superssn = input_ssn;
  END IF;

  IF is_manager (input_ssn) THEN
     UPDATE department
     SET mgrssn = NULL
     WHERE mgrssn = input_ssn;
  END IF;
END clear_employment;
/

REM PROCEDURE MAINTENANCE-6
CREATE OR REPLACE PROCEDURE hire_employee 
(  input_ssn       IN employee.ssn%TYPE,
   first_name      IN employee.fname%TYPE,
   last_name       IN employee.lname%TYPE,
   department_name IN department.dname%TYPE,
   input_salary    IN employee.salary%TYPE) IS

  new_department_number   department.dnumber%TYPE;
BEGIN
/*
We use a nested block technique to search the DEPARTMENT table for a department row which has the same name as the input parameter. If so, the corresponding department number will be used as the foreign key DNO value for the new employee.

IF the department is not found, within the EXCEPTION handler of the nested block we will create a new DEPARTMENT row, using the sequence to generate the primary key.
*/
   BEGIN
      SELECT dnumber
      INTO   new_department_number
      FROM   department
      WHERE  lower(department.dname) = lower(department_name);

   EXCEPTION
      WHEN no_data_found THEN
           SELECT department_sequence.NEXTVAL
           INTO new_department_number
           FROM dual;

           INSERT INTO department (dnumber, dname, mgrssn, mgrstartdate)
           VALUES (new_department_number, 
                   INITCAP(department_name), 
                   input_ssn,
                   SYSDATE);
    END;
/*
Within the outer program block add the new employee to the database
*/
   INSERT INTO employee (ssn, fname, lname, dno, salary)
   VALUES (input_ssn, first_name, last_name, 
           new_department_number, input_salary);
END hire_employee;
/

REM PROCEDURE MAINTENANCE-7
CREATE OR REPLACE PROCEDURE fire_employee (input_ssn IN employee.ssn%TYPE) IS
BEGIN
  IF is_manager (input_ssn)
  OR is_supervisor (input_ssn) THEN
     dbms_output.put_line ('Cannot fire a manager or supervisor');
  ELSE
     DELETE FROM employee WHERE ssn = input_ssn;
     CLEAR_DEPENDENTS (input_ssn);
     CLEAR_EMPLOYMENT (input_ssn);
  END IF;
END fire_employee;
/

REM PROCEDURE MAINTENANCE-8
CREATE OR REPLACE PROCEDURE transfer_employee 
(input_ssn             IN employee.ssn%TYPE,
 new_department_number IN department.dnumber%TYPE) IS
BEGIN
  IF is_supervisor(input_ssn) THEN
     dbms_output.put_line ('Cannot transfer a supervisor with subordinates');
  ELSIF is_manager(input_ssn) THEN
     UPDATE employee
     SET dno = new_department_number
     WHERE employee.ssn = input_ssn;

     UPDATE department
     SET mgrssn = input_ssn
     WHERE department.dnumber = new_department_number;
  ELSE
     UPDATE employee
     SET dno = new_department_number
     WHERE employee.ssn = input_ssn;
  END IF;
END transfer_employee;
/

REM PROCEDURE MAINTENANCE-10
EXECUTE deptree_fill ('table', 'student1', 'employee');

SELECT * FROM ideptree;

REM PROCEDURE MAINTENANCE-11
SELECT object_name, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_name;

REM PROCEDURE MAINTENANCE-12
DROP TABLE employee;

SELECT object_name, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_name;

@ CompanyDefine.SQL;

@ CompanyInsert.SQL;

CONNECT sys/***** AS SYSDBA;

BEGIN
        utl_recomp.recomp_parallel(schema =>'STUDENT1');
     END;
    /

SELECT object_name, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_name;

REM PROCEDURE MAINTENANCE-13
SELECT *
FROM user_object_size      
WHERE type IN ('PROCEDURE', 'FUNCTION')
ORDER BY name;


