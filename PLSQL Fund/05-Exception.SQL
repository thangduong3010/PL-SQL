/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM EXCEPTION-1
DECLARE
     EmpSalary     NUMBER(8);

BEGIN
	SELECT  salary
	INTO    EmpSalary
	FROM    employee
	WHERE   ssn = &prompt_for_ssn;

  DBMS_OUTPUT.PUT_LINE ('Salary is ' || EmpSalary);

EXCEPTION
WHEN no_data_found THEN
  dbms_output.put_line ('No employee found, program ending');

WHEN too_many_rows THEN
  dbms_output.put_line ('Multiple employees found, program ending');
    
WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);						

END;
/

REM EXCEPTION-3
DECLARE
  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
  ReductionTarget   employee.salary%TYPE := 15000;
  ReductionTotal    employee.salary%TYPE := 0;
  
  DependentCount    INTEGER;
  HasDependents     BOOLEAN := FALSE;

  HoursSum          works_on.hours%TYPE;
  WorksHard         BOOLEAN := FALSE;

BEGIN

WHILE ReductionTotal < 15000 LOOP
  SELECT *
  INTO EmpRecord
  FROM employee
  WHERE salary = (SELECT MAX(salary) FROM employee);
  
  PayCut := EmpRecord.salary * .10;

  SELECT COUNT(*)
  INTO DependentCount
  FROM dependent
  WHERE essn = EmpRecord.ssn;
  
  HasDependents := (DependentCount > 0);

  SELECT SUM(hours)
  INTO HoursSum
  FROM works_on
  WHERE essn = EmpRecord.ssn;

  WorksHard := (HoursSum > 40);
 
  CASE
    WHEN HasDependents THEN PayCut := PayCut - 100;
    WHEN WorksHard THEN PayCut := PayCut - 50;
    ELSE NULL;
  END CASE;

  UPDATE employee
  SET salary = salary - PayCut
  WHERE ssn = EmpRecord.ssn;


/*
It should be superfluous, but just to be safe, ensure that only one row was in fact updated by the last statement.
*/
  IF SQL%ROWCOUNT = 1 THEN
    dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                          'reduced by $' || PayCut);
  ELSE
    dbms_output.put_line ('Error reducing salary. Rows updated: ' ||
                          SQL%ROWCOUNT);
  END IF;

  ReductionTotal := ReductionTotal + PayCut;
  ReductionTarget := ReductionTarget - PayCut;

  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

  IF ReductionTarget < 0 THEN
    dbms_output.put_line ('Total reductions exceeded target by: ' ||
                          ABS(ReductionTarget));
  END IF;

EXCEPTION
WHEN no_data_found THEN
  dbms_output.put_line ('No employee found, program ending');

WHEN too_many_rows THEN
  dbms_output.put_line ('Multiple employees with same top pay. Unable to decide, program ending');
    
WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);						

END;
/

REM EXCEPTION-4
DECLARE
  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
  ReductionTarget   employee.salary%TYPE := 15000;
  ReductionTotal    employee.salary%TYPE := 0;
  
  DependentCount    INTEGER;
  HasDependents     BOOLEAN := FALSE;

  HoursSum          works_on.hours%TYPE;
  WorksHard         BOOLEAN := FALSE;

  DayOfMonth        INTEGER;
  TooLateInMonth    EXCEPTION;

BEGIN
  SELECT TO_CHAR(SYSDATE, 'DD')
  INTO DayOfMonth
  FROM dual;

  IF DayOfMonth > 25 THEN
     Raise TooLateInMonth;
  END IF;  
  
WHILE ReductionTotal < 15000 LOOP
  SELECT *
  INTO EmpRecord
  FROM employee
  WHERE salary = (SELECT MAX(salary) FROM employee);
  
  PayCut := EmpRecord.salary * .10;

  SELECT COUNT(*)
  INTO DependentCount
  FROM dependent
  WHERE essn = EmpRecord.ssn;
  
  HasDependents := (DependentCount > 0);

  SELECT SUM(hours)
  INTO HoursSum
  FROM works_on
  WHERE essn = EmpRecord.ssn;

  WorksHard := (HoursSum > 40);
 
  CASE
    WHEN HasDependents THEN PayCut := PayCut - 100;
    WHEN WorksHard THEN PayCut := PayCut - 50;
    ELSE NULL;
  END CASE;

  UPDATE employee
  SET salary = salary - PayCut
  WHERE ssn = EmpRecord.ssn;

  IF SQL%ROWCOUNT = 1 THEN
    dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                          'reduced by $' || PayCut);
  ELSE
    dbms_output.put_line ('Error reducing salary. Rows updated: ' ||
                          SQL%ROWCOUNT);
  END IF;

  ReductionTotal := ReductionTotal + PayCut;
  ReductionTarget := ReductionTarget - PayCut;

  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

  IF ReductionTarget < 0 THEN
    dbms_output.put_line ('Total reductions exceeded target by: ' ||
                          ABS(ReductionTarget));
  END IF;

EXCEPTION
WHEN TooLateInMonth THEN
  dbms_output.put_line ('No salary changes permitted after the 25th, program ending');

WHEN no_data_found THEN
  dbms_output.put_line ('No employee found, program ending');

WHEN too_many_rows THEN
  dbms_output.put_line ('Multiple employees with same top pay. Unable to decide, program ending');
    
WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);						

END;
/



