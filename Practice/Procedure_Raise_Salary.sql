CREATE OR REPLACE PROCEDURE raise_salary (employee_ssn     IN     CHAR,
                                          employee_pct     IN     NUMBER := 5,
                                          result_message      OUT CHAR)
AS
   old_salary        EMPLOYEE.SALARY%TYPE;
   increase_amount   NUMBER;

   pct_too_high      EXCEPTION;
   update_error      EXCEPTION;
BEGIN
   IF employee_pct > 50
   THEN
      RAISE pct_too_high;
   END IF;

   SELECT salary
     INTO old_salary
     FROM employee
    WHERE ssn = employee_ssn;

   IF (old_salary IS NOT NULL) AND (old_salary > 0)
   THEN
      increase_amount := employee_pct / 100;

      UPDATE employee
         SET salary = salary + (salary * increase_amount)
       WHERE ssn = employee_ssn;

      IF SQL%ROWCOUNT <> 1
      THEN
         RAISE update_error;
      END IF;
   ELSE
      result_message := 'Current salary is either NULL or 0';
   END IF;
EXCEPTION
   WHEN pct_too_high
   THEN
      DBMS_OUTPUT.put_line ('Raise percentage may not exceed 50%');
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('Employee: ' || employee_ssn || ' not found');
   WHEN update_error
   THEN
      result_message := 'Database error';
      ROLLBACK;
   WHEN OTHERS
   THEN
      result_message := 'Unknown error';
END raise_salary;
