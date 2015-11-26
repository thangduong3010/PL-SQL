SET SERVEROUTPUT ON

BEGIN
  <<manager>>
   DECLARE
      v_employee   HR.EMPLOYEES%ROWTYPE;
      v_id         HR.EMPLOYEES.EMPLOYEE_ID%TYPE;
   BEGIN
      DECLARE
         v_employee   hr.employees%ROWTYPE;
         v_id         HR.EMPLOYEES.EMPLOYEE_ID%TYPE;
      BEGIN
         SELECT *
           INTO v_employee
           FROM HR.EMPLOYEES
          WHERE last_name = 'Ernst';

         SELECT *
           INTO manager.v_employee
           FROM HR.EMPLOYEES
          WHERE last_name = 'Hunold';

         SELECT manager_id
           INTO v_id
           FROM hr.employees
          WHERE last_name = 'Ernst';

         SELECT employee_id
           INTO manager.v_id
           FROM hr.employees
          WHERE last_name = 'Hunold';

         IF v_id = manager.v_id
         THEN
            GOTO inner;
         ELSE
            DBMS_OUTPUT.put_line ('No match');
         END IF;

        <<inner>>
         DBMS_OUTPUT.put_line (
               'Oh, Mr. '
            || manager.v_employee.last_name
            || ' is manager of Mr. '
            || v_employee.last_name);
      END;
   END;
END manager;