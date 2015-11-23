/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM SUBPROGRAMS-1
DECLARE
  EmpRecord         employee%ROWTYPE;
  ExceptionOccured  BOOLEAN := FALSE;

  PROCEDURE Display (MessageText VARCHAR2) IS

    TempMessageText    VARCHAR2(80);
  BEGIN
      IF LENGTH(MessageText) > 40 THEN
         TempMessageText := SUBSTR(MessageText, 1, 40);
      ELSE
         TempMessageText := 'Message generated on ' ||
                             TO_CHAR(SYSDATE, 'fmDAY') || ' ' ||
                             UPPER(MessageText);
      END IF;
      dbms_output.put_line (TempMessageText);
  END Display;


  FUNCTION SpouseName (EmpSSN  employee.ssn%TYPE)
  RETURN VARCHAR2 IS
    Spouse  dependent.dependent_name%TYPE;
  BEGIN
    SELECT dependent_name
    INTO Spouse
    FROM dependent
    WHERE essn = EmpSSN
    AND relationship = 'SPOUSE';

    RETURN (Spouse);
  EXCEPTION
    WHEN OTHERS THEN
      Spouse := NULL;        
      RETURN (Spouse);
  END SpouseName;
  
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
      Display ('No employee with that last name, try again');

    WHEN too_many_rows THEN
       ExceptionOccured := TRUE;
       Display ('Multiple employees with last name, try again');
  END SelectEmp;

  IF NOT ExceptionOccured THEN
    Display ('Salary for ' || EmpRecord.LName ||
                          ' is ' || EmpRecord.Salary);

    IF SpouseName (EmpRecord.SSN) IS NOT NULL THEN
      Display ('Spouse for this employee is ' || SpouseName(EmpRecord.SSN));
    END IF;      

  END IF;

EXCEPTION
	WHEN OTHERS THEN
		Display('Exception trapped by universal handler');
		Display('Error code: ' || sqlcode);
		Display('Error message: ' || sqlerrm);						

END;
/


