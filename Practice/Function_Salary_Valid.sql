CREATE OR REPLACE FUNCTION salary_valid (input_ssn      IN CHAR,
                                         input_salary   IN NUMBER)
   RETURN VARCHAR2
IS
   count_management   NUMBER;
   count_projects     NUMBER;
   count_dependents   NUMBER;
   salary_limit       NUMBER;
BEGIN
   salary_limit := 50000;

   SELECT COUNT (*)
     INTO count_management
     FROM department
    WHERE department.mgrssn = input_ssn;

   IF count_management > 0
   THEN
      salary_limit := salary_limit + 1000;
   END IF;

   SELECT COUNT (*)
     INTO count_projects
     FROM works_on
    WHERE WORKS_ON.ESSN = input_ssn;

   salary_limit := salary_limit + (count_projects * 2000);

   SELECT COUNT (*)
     INTO count_dependents
     FROM dependent
    WHERE dependent.essn = input_ssn;

   salary_limit := salary_limit + (count_dependents * 3000);

   IF input_salary > salary_limit
   THEN
      RETURN ('TRUE');
   ELSE
      RETURN ('FALSE');
   END IF;
END salary_valid;
