SET SERVEROUTPUT ON

DECLARE
   -- declare table of scalar
   TYPE ename_table_type IS TABLE OF hr.employees.last_name%TYPE
      INDEX BY PLS_INTEGER;

   TYPE hiredate_table_type IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

   -- declare table of record
   TYPE emp_table_type IS TABLE OF hr.employees%ROWTYPE
      INDEX BY PLS_INTEGER;

   ename_table      ename_table_type;
   hiredate_table   hiredate_table_type;
   my_emp_table     emp_table_type;
   max_count        NUMBER (3) := 104;
BEGIN
   ename_table (1) := 'Cameron';
   ename_table (3) := 'John';
   hiredate_table (8) := SYSDATE + 7;
   hiredate_table (1) := SYSDATE - 7;

   DBMS_OUTPUT.put_line ('Count: ' || hiredate_table.COUNT);
   DBMS_OUTPUT.put_line ('First element: ' || hiredate_table.FIRST);
   DBMS_OUTPUT.put_line ('Last element: ' || hiredate_table.LAST);

   FOR i IN 100 .. max_count
   LOOP
      SELECT *
        INTO my_emp_table (i)
        FROM hr.employees
       WHERE employee_id = i;
   END LOOP;

   FOR i IN my_emp_table.FIRST .. my_emp_table.LAST
   LOOP
      DBMS_OUTPUT.put_line (my_emp_table (i).last_name);
   END LOOP;
END;