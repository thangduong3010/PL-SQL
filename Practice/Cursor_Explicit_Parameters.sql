SET SERVEROUTPUT ON

DECLARE
   CURSOR Employees (deptno EMPLOYEE.DNO%TYPE)
   IS
          SELECT *
            FROM employee
           WHERE dno = deptno
      FOR UPDATE OF salary;

   SelectDept       employee.dno%TYPE;

   EmpRec           employee%ROWTYPE;

   PayCut           employee.salary%TYPE := 0;
   ReductionTotal   PayCut%TYPE := 0;

   DependentCount   INTEGER;
   HasDependents    BOOLEAN := FALSE;

   HoursSum         works_on.hours%TYPE;
   WorksHard        BOOLEAN := FALSE;

   DayofMonth       INTEGER;
   TooLateInMonth   EXCEPTION;
BEGIN
   SELECT TO_CHAR (SYSDATE, 'DD') INTO DayofMonth FROM DUAL;

   IF DayofMonth > 25
   THEN
      RAISE TooLateInMonth;
   END IF;

   IF NOT (Employees%ISOPEN)
   THEN
      SELECT d.dnumber
        INTO SelectDept
        FROM dept_locations dl
             INNER JOIN department d
                ON dl.dnumber = d.dnumber AND dl.dlocation = 'Stafford';

      OPEN Employees (SelectDept);
   END IF;

   LOOP
      FETCH Employees INTO EmpRec;

      EXIT WHEN Employees%NOTFOUND;

      PayCut := EmpRec.salary * .10;

      SELECT COUNT (*)
        INTO DependentCount
        FROM dependent
       WHERE essn = EmpRec.ssn;

      HasDependents := (DependentCount > 0);

      SELECT SUM (hours)
        INTO HoursSum
        FROM works_on
       WHERE essn = EmpRec.ssn;

      WorksHard := (HoursSum > 40);

      CASE
         WHEN HasDependents
         THEN
            PayCut := PayCut - 100;
         WHEN WorksHard
         THEN
            PayCut := PayCut - 50;
         ELSE
            NULL;
      END CASE;

      UPDATE employee
         SET salary = salary - PayCut
       WHERE CURRENT OF Employees;

      DBMS_OUTPUT.put_line (
         'Salary for: ' || EmpRec.lname || ' reduced by $' || PayCut);

      ReductionTotal := ReductionTotal + PayCut;
      HasDependents := FALSE;
      WorksHard := FALSE;
   END LOOP;

   IF Employees%ISOPEN
   THEN
      CLOSE Employees;
   END IF;

   DBMS_OUTPUT.put_line ('Total reduction: $' || ReductionTotal);
EXCEPTION
   WHEN TooLateInMonth
   THEN
      DBMS_OUTPUT.put_line ('No salary changes after 25th.');
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Generic following error: ');
      DBMS_OUTPUT.put_line ('Code: ' || SQLCODE);
      DBMS_OUTPUT.put_line ('Message: ' || SQLERRM);
END;