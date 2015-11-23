SET SERVEROUTPUT ON

DECLARE
   birth_month   CHAR (3);
   birth_date    NUMBER;
   v_message     VARCHAR2 (40);
   v_ssn         EMPLOYEE.SSN%TYPE := &enter_ssn;
BEGIN
   SELECT TO_CHAR (bdate, 'Mon')
     INTO birth_month
     FROM employee
    WHERE ssn = v_ssn AND ROWNUM <= 1;

   SELECT TO_CHAR (bdate, 'DD')
     INTO birth_date
     FROM employee
    WHERE ssn = v_ssn AND ROWNUM <= 1;

   IF UPPER (birth_month) = 'JAN'
   THEN
      v_message := 'Start of the year';

      IF birth_date = 01
      THEN
         DBMS_OUTPUT.put_line ('Start of the month');
      ELSIF birth_date = 30 OR birth_date = 31
      THEN
         DBMS_OUTPUT.put_line ('End of the month');
      ELSE
         DBMS_OUTPUT.put_line ('The date is ' || birth_date);
      END IF;
   ELSIF UPPER (birth_month) = 'DEC'
   THEN
      v_message := 'End of the year';

      IF birth_date = 01
      THEN
         DBMS_OUTPUT.put_line ('Start of the month');
      ELSIF birth_date = 30 OR birth_date = 31
      THEN
         DBMS_OUTPUT.put_line ('End of the month');
      ELSE
         DBMS_OUTPUT.put_line ('The date is ' || birth_date);
      END IF;
   ELSE
      v_message := 'No Comment';

      IF birth_date = 01
      THEN
         DBMS_OUTPUT.put_line ('Start of the month');
      ELSIF birth_date = 30 OR birth_date = 31
      THEN
         DBMS_OUTPUT.put_line ('End of the month');
      ELSE
         DBMS_OUTPUT.put_line ('The date is ' || birth_date);
      END IF;
   END IF;

   DBMS_OUTPUT.put_line (v_message);
END;