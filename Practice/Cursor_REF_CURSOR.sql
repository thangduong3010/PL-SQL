SET SERVEROUTPUT ON

DECLARE
   TYPE EmpCurTyp IS REF CURSOR;

   emp_cv     EmpCurTyp;
   emp_rec    HR.EMPLOYEES%ROWTYPE;
   sql_stmt   VARCHAR2 (200);
   my_job     VARCHAR2 (10) := 'ST_CLERK';
BEGIN
   sql_stmt := 'SELECT * FROM hr.employees WHERE job_id = :j';

   OPEN emp_cv FOR sql_stmt USING my_job;

   LOOP
      FETCH emp_cv INTO emp_rec;

      EXIT WHEN emp_cv%NOTFOUND;
      DBMS_OUTPUT.put_line ('Record no. ' || emp_cv%ROWCOUNT);
      DBMS_OUTPUT.put_line ('Employee name: ' || emp_rec.last_name);
      DBMS_OUTPUT.put_line ('Job title: ' || emp_rec.job_id);
      DBMS_OUTPUT.put_line ('Salary: ' || emp_rec.salary);
      DBMS_OUTPUT.put_line (' ');
   END LOOP;

   CLOSE emp_cv;
END;