-- This thing is like structure in C. Woops
SET SERVEROUTPUT ON

DECLARE
   TYPE t_rec IS RECORD
   (
      v_sal         NUMBER (8),
      v_minsal      NUMBER (8):= 1000,
      v_hire_date   hr.employees.hire_date%TYPE,
      v_recl        hr.employees%ROWTYPE
   );

   v_myrec   t_rec;
BEGIN
   v_myrec.v_sal := v_myrec.v_minsal + 500;
   v_myrec.v_hire_date := SYSDATE;

   SELECT *
     INTO v_myrec.v_recl
     FROM hr.employees
    WHERE employee_id = 100;

   DBMS_OUTPUT.put_line (
         v_myrec.v_recl.last_name
      || ' '
      || TO_CHAR (v_myrec.v_hire_date)
      || ' '
      || TO_CHAR (v_myrec.v_sal));
END;