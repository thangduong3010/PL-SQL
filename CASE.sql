-- CASE Search
SET SERVEROUTPUT ON

DECLARE
   x_date      EMPLOYEE.BDATE%TYPE;
   x_salary    EMPLOYEE.SALARY%TYPE;
   age         NUMBER;
   x_ssn       EMPLOYEE.SSN%TYPE;
   x_message   VARCHAR2 (50);
BEGIN
   x_ssn := &enter_ssn;

   SELECT bdate, salary
     INTO x_date, x_salary
     FROM employee
    WHERE ssn = x_ssn AND ROWNUM <= 1;

   age := TRUNC (MONTHS_BETWEEN (SYSDATE, x_date) / 12, 0);

   CASE
      WHEN age < 30
      THEN
         x_message := 'Young and wild employee';
      WHEN x_salary > 50000
      THEN
         x_message := 'Very expensive employee';
      WHEN age BETWEEN 45 AND 60 AND x_salary BETWEEN 30000 AND 40000
      THEN
         x_message := 'Middle age, middle salary';
      ELSE
         x_message := 'No match found';
   END CASE;

   DBMS_OUTPUT.put_line (x_message);
END;