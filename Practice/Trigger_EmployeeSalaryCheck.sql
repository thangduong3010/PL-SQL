CREATE OR REPLACE TRIGGER employee_salary_check
   BEFORE INSERT OR UPDATE OF salary
   ON employee
   FOR EACH ROW
   WHEN (new.salary > 70000)
DECLARE
   x_mgrssn       department.mgrssn%TYPE;
   MESSAGE_TEXT   VARCHAR2 (100);
BEGIN
   SELECT mgrssn
     INTO x_mgrssn
     FROM department
    WHERE mgrssn = :new.ssn;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      MESSAGE_TEXT :=
         'Must be manager for salary of ' || TO_CHAR (:new.salary);
      raise_application_error (-20001, MESSAGE_TEXT);
END;