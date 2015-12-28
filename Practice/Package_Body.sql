CREATE OR REPLACE PACKAGE BODY personnel
AS
   FUNCTION is_manager (input_ssn IN employee.ssn%TYPE)
      RETURN BOOLEAN
   IS
      manager_count   NUMBER;
   BEGIN
      -- Retrieve count of ssn
      SELECT COUNT (mgrssn)
        INTO manager_count
        FROM department
       WHERE mgrssn = input_ssn;

      IF manager_count > 0
      THEN
         RETURN (TRUE);
      ELSE
         RETURN (FALSE);
      END IF;
   END is_manager;

   FUNCTION is_supervisor (input_ssn IN employee.ssn%TYPE)
      RETURN BOOLEAN
   IS
      supervisor_count   NUMBER;
   BEGIN
      -- Retrieve count of superssn
      SELECT COUNT (superssn)
        INTO supervisor_count
        FROM employee
       WHERE superssn = input_ssn;

      IF supervisor_count > 0
      THEN
         RETURN (TRUE);
      ELSE
         RETURN (FALSE);
      END IF;
   END is_supervisor;

   FUNCTION salary_valid (input_ssn      IN employee.ssn%TYPE,
                          input_salary   IN employee.salary%TYPE)
      RETURN BOOLEAN
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
       WHERE works_on.essn = input_ssn;

      salary_limit := salary_limit + (count_projects * 2000);

      SELECT COUNT (*)
        INTO count_dependents
        FROM dependent
       WHERE dependent.essn = input_ssn;

      salary_limit := salary_limit + (count_dependents * 3000);

      IF input_salary > salary_limit
      THEN
         RETURN (FALSE);
      ELSE
         RETURN (TRUE);
      END IF;
   END salary_valid;

   PROCEDURE clear_dependents (input_ssn IN employee.ssn%TYPE)
   IS
   BEGIN
      DELETE FROM dependent
            WHERE essn = input_ssn;
   END clear_dependents;

   PROCEDURE clear_employment (input_ssn IN employee.ssn%TYPE)
   IS
   BEGIN
      DELETE FROM works_on
            WHERE essn = input_ssn;

      DELETE FROM employee
            WHERE ssn = input_ssn;

      IF is_supervisor (input_ssn)
      THEN
         UPDATE employee
            SET superssn = NULL
          WHERE superssn = input_ssn;
      END IF;

      IF is_manager (input_ssn)
      THEN
         UPDATE department
            SET mgrssn = NULL
          WHERE mgrssn = input_ssn;
      END IF;
   END clear_employment;

   PROCEDURE raise_salary_valid (employee_ssn     IN     CHAR,
                                 employee_pct     IN     NUMBER := 5,
                                 result_message      OUT CHAR)
   AS
      old_salary        employee.salary%TYPE;
      increase_amount   NUMBER;
      update_error      EXCEPTION;
   BEGIN
      SELECT salary
        INTO old_salary
        FROM employee
       WHERE ssn = employee_ssn;

      IF old_salary IS NOT NULL AND old_salary > 0
      THEN
         increase_amount := employee_pct / 100;

         IF salary_valid (employee_ssn,
                          old_salary + (old_salary * increase_amount))
         THEN
            UPDATE employee
               SET salary = salary + (salary * increase_amount)
             WHERE ssn = employee_ssn;

            IF SQL%ROWCOUNT != 1
            THEN
               RAISE update_error;
            END IF;
         ELSE
            result_message := 'Proposed salary invalid, no update issued';
         END IF;
      ELSE
         result_message := 'Current salary is either NULL or 0';
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         result_message := 'Employee ' || employee_ssn || ' not found';
      WHEN update_error
      THEN
         result_message := 'Database error';
         ROLLBACK;
      WHEN OTHERS
      THEN
         result_message := 'Unknown error';
   END raise_salary_valid;

   PROCEDURE hire_employee (input_ssn         IN employee.ssn%TYPE,
                            first_name        IN employee.fname%TYPE,
                            last_name         IN employee.lname%TYPE,
                            department_name   IN department.dname%TYPE,
                            input_salary      IN employee.salary%TYPE)
   IS
      new_department_number   department.dnumber%TYPE;
   BEGIN
      BEGIN
         SELECT dnumber
           INTO new_department_number
           FROM department
          WHERE LOWER (department.dname) = LOWER (department_name);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT department_sequence.NEXTVAL
              INTO new_department_number
              FROM DUAL;

            INSERT INTO department (dnumber,
                                    dname,
                                    mgrssn,
                                    mgrstartdate)
                 VALUES (new_department_number,
                         INITCAP (department_name),
                         input_ssn,
                         SYSDATE);
      END;

      INSERT INTO employee (ssn,
                            fname,
                            lname,
                            dno,
                            salary)
           VALUES (input_ssn,
                   first_name,
                   last_name,
                   new_department_number,
                   input_salary);
   END hire_employee;

   PROCEDURE fire_employee (input_ssn IN employee.ssn%TYPE)
   IS
   BEGIN
      IF is_manager (input_ssn) OR is_supervisor (input_ssn)
      THEN
         DBMS_OUTPUT.put_line ('Cannot fire a manager or supervisor');
      ELSE
         DELETE FROM employee
               WHERE ssn = input_ssn;

         CLEAR_DEPENDENTS (input_ssn);
         CLEAR_EMPLOYMENT (input_ssn);
      END IF;
   END fire_employee;

   PROCEDURE transfer_employee (
      input_ssn               IN employee.ssn%TYPE,
      new_department_number   IN department.dnumber%TYPE)
   IS
   BEGIN
      IF is_supervisor (input_ssn)
      THEN
         DBMS_OUTPUT.put_line (
            'Cannot transfer a supervisor with subordinates');
      ELSIF is_manager (input_ssn)
      THEN
         UPDATE employee
            SET dno = new_department_number
          WHERE employee.ssn = input_ssn;

         UPDATE department
            SET mgrssn = input_ssn
          WHERE department.dnumber = new_department_number;
      ELSE
         UPDATE employee
            SET dno = new_department_number
          WHERE employee.ssn = input_ssn;
      END IF;
   END transfer_employee;
END personnel;