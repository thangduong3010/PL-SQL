/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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