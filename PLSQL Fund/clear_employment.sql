/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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