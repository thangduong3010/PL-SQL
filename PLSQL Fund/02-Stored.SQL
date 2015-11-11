/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM PROCEDURE-1
CREATE OR REPLACE PROCEDURE raise_salary
	(
	employee_ssn	IN	CHAR,
 	employee_pct	IN	NUMBER	DEFAULT 5,
	result_message	OUT CHAR
	)
AS

	old_salary		employee.salary%TYPE;
	increase_amount	NUMBER;
   pct_too_high      EXCEPTION;
	update_error		EXCEPTION;

BEGIN
   IF employee_pct > 50 THEN
      RAISE pct_too_high;
   END IF;

	SELECT salary
	INTO old_salary
	FROM employee
	WHERE ssn = employee_ssn;

	IF old_salary IS NOT NULL
	AND old_salary > 0 THEN

      increase_amount := employee_pct / 100;

		UPDATE employee
		SET salary = salary + (salary * increase_amount)
		WHERE ssn = employee_ssn;

		IF SQL%ROWCOUNT <> 1 THEN
 			RAISE update_error;
		END IF;

	ELSE
		result_message := 'Current salary is either NULL or 0';
	END IF;


EXCEPTION
   WHEN pct_too_high THEN
      result_message := 'Raise percentage may not exceed 50%';
      
	WHEN NO_DATA_FOUND THEN
		result_message := 'Employee ' || employee_ssn
			|| ' not found';

	WHEN update_error THEN
		result_message := 'Database error';
		ROLLBACK;

	WHEN OTHERS THEN
		result_message := 'Unknown error';

END raise_salary;
/

REM PROCEDURE-3
CREATE OR REPLACE FUNCTION salary_valid
 (
 input_ssn IN CHAR,
 input_salary IN NUMBER
 ) 
RETURN boolean 

IS
     count_management NUMBER;
     count_projects NUMBER;
     count_dependents NUMBER;
     salary_limit NUMBER;

BEGIN
     salary_limit := 50000;

     SELECT count(*)
     INTO count_management
     FROM department
     WHERE department.mgrssn = input_ssn;

     IF count_management > 0 THEN
          salary_limit := salary_limit + 1000;
     END IF;

     SELECT count(*)
     INTO count_projects
     FROM works_on
     WHERE works_on.essn = input_ssn;

     salary_limit := salary_limit + (count_projects * 2000);

     SELECT count(*)
     INTO count_dependents
     FROM dependent
     WHERE dependent.essn = input_ssn;

     salary_limit := salary_limit + (count_dependents * 3000);

     IF input_salary > salary_limit THEN
        RETURN (FALSE);
     ELSE
        RETURN (TRUE);
     END IF;
  
END salary_valid;
/

REM PROCEDURE-4
The following solution is appropriate for either the SQL*Plus or SQL Developer interface.

BEGIN
     IF salary_valid ('123456789', 80000) THEN
             dbms_output.put_line ('Salary is valid');
     ELSE
             dbms_output.put_line ('Salary is not valid');
     END IF;
END;
/


REM PROCEDURE-5
CREATE OR REPLACE FUNCTION salary_valid_result
 (input_ssn IN CHAR,
  input_salary IN NUMBER) 
RETURN VARCHAR2 
IS
     count_management NUMBER;
     count_projects NUMBER;
     count_dependents NUMBER;
     salary_limit NUMBER;
BEGIN
     salary_limit := 50000;

     SELECT count(*)
     INTO count_management
     FROM department
     WHERE department.mgrssn = input_ssn;

     IF count_management > 0 THEN
          salary_limit := salary_limit + 1000;
     END IF;

     SELECT count(*)
     INTO count_projects
     FROM works_on
     WHERE works_on.essn = input_ssn;

     salary_limit := salary_limit + (count_projects * 2000);

     SELECT count(*)
     INTO count_dependents
     FROM dependent
     WHERE dependent.essn = input_ssn;

     salary_limit := salary_limit + (count_dependents * 3000);

     IF input_salary > salary_limit THEN
        RETURN ('FALSE');
     ELSE
        RETURN ('TRUE');
     END IF;
END salary_valid_result;
/

REM PROCEDURE-6
SELECT UPPER(LName) AS "Last Name",
       ROUND(Salary * 1.50) AS "Proposed Salary",
       SALARY_VALID_RESULT (ssn, Salary*1.50) AS "Valid"
FROM employee;

REM PROCEDURE-7
CREATE OR REPLACE PROCEDURE raise_salary_valid
	(employee_ssn	IN	CHAR,
 	 employee_pct	IN	NUMBER	DEFAULT 5,
	 result_message	OUT CHAR)
AS
	old_salary		employee.salary%TYPE;
	increase_amount	NUMBER;
	update_error		EXCEPTION;

BEGIN
	SELECT salary
	INTO old_salary
	FROM employee
	WHERE ssn = employee_ssn;

	IF old_salary IS NOT NULL
	AND old_salary > 0 THEN

        increase_amount := employee_pct / 100;

  IF salary_valid (employee_ssn, old_salary+(old_salary*increase_amount)) THEN
		UPDATE employee
		SET salary = salary + (salary * increase_amount)
		WHERE ssn = employee_ssn;

		IF SQL%ROWCOUNT <> 1 THEN
 			RAISE update_error;
		END IF;
  ELSE
      result_message := 'Proposed salary invalid, no update issued';
            END IF;

	ELSE
		result_message := 'Current salary is either NULL or 0';
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		result_message := 'Employee ' || employee_ssn
			|| ' not found';

	WHEN update_error THEN
		result_message := 'Database error';
		ROLLBACK;

	WHEN OTHERS THEN
		result_message := 'Unknown error';

END raise_salary_valid;
/

REM PROCEDURE-8
EXECUTE raise_salary_valid ('123456789', 51, :output_text);

PRINT output_text;

DECLARE
   output_text CHAR(100);

BEGIN
   raise_salary_valid ('123456789', 51, output_text);
   dbms_output.put_line (output_text);
END;

SELECT salary
FROM employee
WHERE ssn = 123456789;

