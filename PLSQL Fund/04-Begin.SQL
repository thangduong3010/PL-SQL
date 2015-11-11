/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM BEGIN-1
DECLARE
/*
Declare a full record for the EMPLOYEE table.
*/
  EmpRecord         employee%ROWTYPE;

/*
Declare local variables needed for the program logic.
*/
  PayCut            employee.salary%TYPE := 0;
  ReductionTarget   employee.salary%TYPE := 15000;
  ReductionTotal    employee.salary%TYPE := 0;
  

BEGIN
<<GetRichestEmployee>>
/*
Fetch the highest paid employee, ensuring that only one row is retrieved.
*/
  SELECT *
  INTO EmpRecord
  FROM employee
  WHERE salary = (SELECT MAX(salary) FROM employee)
  AND ROWNUM <=1;

/*
Calculate the pay cut and update the database.
*/
  PayCut := EmpRecord.salary * .10;
  
  UPDATE employee
  SET salary = salary - PayCut
  WHERE ssn = EmpRecord.ssn;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

/*
Keep a running total of the payroll reduction amount. Also, decrement the target pay cut total to account for what has just been cut for the last employee.
*/
  ReductionTotal := ReductionTotal + PayCut;
  ReductionTarget := ReductionTarget - PayCut;

/*
If we have not cut the target amount, continue the process from the beginning.
*/
  IF ReductionTarget > 0 THEN
     GOTO GetRichestEmployee;
  END IF;

/*
To wrap up the program, output the total amount payroll was reduced.
*/
  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

/*
Since the final update likely exceeded the target amount, report how much was in fact cut. As this is a negative number, use the ABS() function.
*/
  IF ReductionTarget < 0 THEN
    dbms_output.put_line ('Total reductions exceeded target by: ' ||
                          ABS(ReductionTarget));
  END IF;
    
END;
/

REM BEGIN-3
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
<<GetRichestEmployee>>
  SELECT *
  INTO EmpRecord
  FROM employee
  WHERE salary = (SELECT MAX(salary) FROM employee)
  AND ROWNUM <=1;

  PayCut := EmpRecord.salary * .10;

/*
Determine if the required special circumstances exist.
*/
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
 
/*
If this employee has special circumstances, make appropriate changes to their pay cut.
*/
  CASE
    WHEN HasDependents THEN PayCut := PayCut - 100;
    WHEN WorksHard THEN PayCut := PayCut - 50;
    ELSE NULL;
  END CASE;

  UPDATE employee
  SET salary = salary - PayCut
  WHERE ssn = EmpRecord.ssn;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

  ReductionTotal := ReductionTotal + PayCut;
  ReductionTarget := ReductionTarget - PayCut;

/*
Reset the Boolean variables for the next employee to be processed.
*/
  IF ReductionTarget > 0 THEN
     HasDependents := FALSE;
     WorksHard := FALSE;
     GOTO GetRichestEmployee;
  END IF;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

  IF ReductionTarget < 0 THEN
    dbms_output.put_line ('Total reductions exceeded target by: ' ||
                          ABS(ReductionTarget));
  END IF;
    
END;
/

REM BEGIN-4
ROLLBACK;

REM BEGIN-6
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
  WHERE salary = (SELECT MAX(salary) FROM employee)
  AND ROWNUM <=1;

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

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

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

END;
/



