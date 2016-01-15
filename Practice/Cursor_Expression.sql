SET SERVEROUTPUT ON

DECLARE
   TYPE WorkCursorType IS REF CURSOR;

   WorkCursor   WorkCursorType;

   empLname     employee.lname%TYPE;
   empSalary    employee.salary%TYPE;
   empPname     project.pname%TYPE;
   empHour      works_on.hours%TYPE;

   CURSOR EmpWork
   IS
        SELECT lname,
               salary,
               CURSOR (
                  SELECT pname, hours
                    FROM works_on w INNER JOIN project p ON P.PNUMBER = W.PNO
                   WHERE w.essn = e.ssn)
                  Work
          FROM employee e
      ORDER BY lname;
BEGIN
   OPEN EmpWork;

   LOOP
      FETCH EmpWork INTO empLname, empSalary, WorkCursor;

      EXIT WHEN EmpWork%NOTFOUND;

      DBMS_OUTPUT.put_line ('Processing here: ' || empLname);

      LOOP
         FETCH WorkCursor INTO empPname, empHour;

         EXIT WHEN WorkCursor%NOTFOUND;

         DBMS_OUTPUT.put_line (
               'Processing here: '
            || empLname
            || ' and for '
            || empPname
            || ' in '
            || empHour
            || ' hours.');
      END LOOP;
   END LOOP;

   CLOSE EmpWork;
END;