/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM NESTED-1
DECLARE
  EmpRecord         employee%ROWTYPE;
  ExceptionOccured  BOOLEAN := FALSE;
  
BEGIN

<<SelectEmp>>

  BEGIN
    SELECT *
    INTO EmpRecord
    FROM employee
    WHERE LName = '&EnterLastName';
  EXCEPTION
    WHEN no_data_found THEN
      ExceptionOccured := TRUE;
      dbms_output.put_line ('No employee with that last name, try again');

    WHEN too_many_rows THEN
       ExceptionOccured := TRUE;
       dbms_output.put_line ('Multiple employees with last name, try again');

  END SelectEmp;


  IF NOT ExceptionOccured THEN
    dbms_output.put_line ('Salary for ' || EmpRecord.LName ||
                          ' is ' || EmpRecord.Salary);
  END IF;

EXCEPTION
	WHEN OTHERS THEN
		dbms_output.put_line('Exception trapped by universal handler');
		dbms_output.put_line('Error code: ' || sqlcode);
		dbms_output.put_line('Error message: ' || sqlerrm);						

END;
/

REM NESTED-2
INSERT INTO employee (LName) VALUES ('Smith');

