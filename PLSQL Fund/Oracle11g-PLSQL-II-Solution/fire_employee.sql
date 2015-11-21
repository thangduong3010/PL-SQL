/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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