SET SERVEROUTPUT ON

DECLARE
   CURSOR c_emp_cursor
   IS
      SELECT employee_id, last_name
        FROM hr.employees
       WHERE department_id = 30;

   TYPE emp_type_record IS RECORD
   (
      emp_id    hr.employees.employee_id%TYPE,
      v_lname   HR.EMPLOYEES.LAST_NAME%TYPE
   );

   emp_record   emp_type_record;
BEGIN
   OPEN c_emp_cursor;

   LOOP
      FETCH c_emp_cursor INTO emp_record;

      EXIT WHEN c_emp_cursor%NOTFOUND;
      DBMS_OUTPUT.put_line (
            'Empno: '
         || emp_record.emp_id
         || ' '
         || 'Last name: '
         || emp_record.v_lname);
   END LOOP;

   CLOSE c_emp_cursor;
END;