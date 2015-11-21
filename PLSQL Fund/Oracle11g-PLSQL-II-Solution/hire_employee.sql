/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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
