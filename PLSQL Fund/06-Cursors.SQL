/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM CURSOR-1
DECLARE
  CURSOR Employees IS 
    SELECT *
    FROM employee;

  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
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
  
OPEN Employees;

LOOP
  FETCH Employees INTO EmpRecord;
  EXIT WHEN Employees%NOTFOUND;
  
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

--  UPDATE employee
--  SET salary = salary - PayCut
--  WHERE ssn = EmpRecord.ssn;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

  ReductionTotal := ReductionTotal + PayCut;
  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

  CLOSE Employees;
  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

EXCEPTION
WHEN TooLateInMonth THEN
  dbms_output.put_line ('No salary changes permitted after the 25th, program ending');

WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);						

END;
/

REM CURSOR-3
DECLARE
  CURSOR Employees IS 
    SELECT *
    FROM employee;

  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
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
  
IF NOT (Employees%ISOPEN) THEN
  OPEN Employees;
END IF;

LOOP
  FETCH Employees INTO EmpRecord;
  EXIT WHEN Employees%NOTFOUND;
  
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

--  UPDATE employee
--  SET salary = salary - PayCut
--  WHERE ssn = EmpRecord.ssn;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

  ReductionTotal := ReductionTotal + PayCut;
  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

IF Employees%ISOPEN THEN
  CLOSE Employees;
END IF;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

EXCEPTION
WHEN TooLateInMonth THEN
  dbms_output.put_line ('No salary changes permitted after the 25th, program ending');

WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);
  CASE Employees%ISOPEN
    WHEN TRUE THEN dbms_output.put_line('Cursor is currently open');
    WHEN FALSE THEN dbms_output.put_line('Cursor is currently closed');
  END CASE;					

END;
/

REM CURSOR-5
DECLARE
  CURSOR Employees IS 
    SELECT *
    FROM employee
  FOR UPDATE OF salary;

  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
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
  
IF NOT (Employees%ISOPEN) THEN
  OPEN Employees;
END IF;

LOOP
  FETCH Employees INTO EmpRecord;
  EXIT WHEN Employees%NOTFOUND;
  
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
  WHERE CURRENT OF Employees;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

  ReductionTotal := ReductionTotal + PayCut;
  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

COMMIT;

IF Employees%ISOPEN THEN
  CLOSE Employees;
END IF;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

EXCEPTION
WHEN TooLateInMonth THEN
  dbms_output.put_line ('No salary changes permitted after the 25th, program ending');

WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);
  CASE Employees%ISOPEN
    WHEN TRUE THEN dbms_output.put_line('Cursor is currently open');
    WHEN FALSE THEN dbms_output.put_line('Cursor is currently closed');
  END CASE;					

END;
/

REM CURSOR-7
DECLARE
  CURSOR Employees (SelectDepartment department.dnumber%TYPE) IS 
    SELECT *
    FROM employee
    WHERE dno = SelectDepartment
  FOR UPDATE OF salary;

  SelectDepartment  department.dnumber%TYPE;
  
  EmpRecord         employee%ROWTYPE;

  PayCut            employee.salary%TYPE := 0;
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
  
IF NOT (Employees%ISOPEN) THEN
  SELECT d.dnumber
  INTO SelectDepartment
  FROM department d, dept_locations dl
  WHERE d.dnumber = dl.dnumber
  AND dl.dlocation = 'Stafford'
  AND ROWNUM <= 1;

  OPEN Employees (SelectDepartment);
END IF;

LOOP
  FETCH Employees INTO EmpRecord;
  EXIT WHEN Employees%NOTFOUND;
  
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
  WHERE CURRENT OF Employees;

  dbms_output.put_line ('Salary for ' || EmpRecord.LName || ' ' ||
                        'reduced by $' || PayCut);

  ReductionTotal := ReductionTotal + PayCut;
  HasDependents := FALSE;
  WorksHard := FALSE;
END LOOP;

COMMIT;

IF Employees%ISOPEN THEN
  CLOSE Employees;
END IF;

  dbms_output.put_line ('Total salary reduction: ' || ReductionTotal);

EXCEPTION
WHEN TooLateInMonth THEN
  dbms_output.put_line ('No salary changes permitted after the 25th, program ending');

WHEN OTHERS THEN
  dbms_output.put_line('Unknown error, details below');
  dbms_output.put_line('Error code: ' || sqlcode);
  dbms_output.put_line('Error message: ' || sqlerrm);
  CASE Employees%ISOPEN
    WHEN TRUE THEN dbms_output.put_line('Cursor is currently open');
    WHEN FALSE THEN dbms_output.put_line('Cursor is currently closed');
  END CASE;					

END;
/




