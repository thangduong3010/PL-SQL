SET SERVEROUTPUT ON

DECLARE
   v_deptno               NUMBER := 500;
   v_name                 VARCHAR2 (20) := 'Testing';
   e_invalid_department   EXCEPTION;
BEGIN
   UPDATE hr.departments
      SET department_name = v_name
    WHERE department_id = v_deptno;

   IF SQL%NOTFOUND
   THEN
      RAISE e_invalid_department;
   END IF;
EXCEPTION
   WHEN e_invalid_department
   THEN
      DBMS_OUTPUT.put_line ('No such department');
END;