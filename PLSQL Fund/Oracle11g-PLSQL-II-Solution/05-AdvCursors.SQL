/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM ADVANCED CURSOR-1
CREATE OR REPLACE PACKAGE employee_data AS
  TYPE employee_cv_type IS REF CURSOR RETURN employee%ROWTYPE;
  PROCEDURE open_employee_data (
          employee_cv   IN OUT employee_cv_type,
          x_dno         IN     employee.dno%TYPE); 

  PROCEDURE fetch_employee_data (
          employee_cv      IN    employee_cv_type,
          employee_output  OUT   VARCHAR2);
END employee_data;
/

CREATE OR REPLACE PACKAGE BODY employee_data AS

  PROCEDURE open_employee_data (
          employee_cv   IN OUT employee_cv_type,
          x_dno         IN     employee.dno%TYPE) IS
  BEGIN
    OPEN employee_cv FOR
         SELECT *
         FROM employee
         WHERE employee.dno = x_dno;
  END open_employee_data;
  
  PROCEDURE fetch_employee_data (
          employee_cv      IN    employee_cv_type,
          employee_output  OUT   VARCHAR2) IS
          
          employee_row  employee%ROWTYPE;
          
  BEGIN
    FETCH employee_cv INTO employee_row;
    employee_output := employee_row.lname || ' ' || employee_row.salary;
  END fetch_employee_data;
  
END employee_data;
/

DECLARE
     department_number  employee.dno%TYPE := 5;
     employee_cv        employee_data.employee_cv_type;
     employee_output    VARCHAR2(1000);
BEGIN
     employee_data.open_employee_data (employee_cv, department_number);
     LOOP
          employee_data.fetch_employee_data (employee_cv, employee_output);
          EXIT WHEN employee_cv%NOTFOUND;
          dbms_output.put_line (employee_output);
     END LOOP;
END;
/

REM ADVANCED CURSOR-2
CREATE OR REPLACE PACKAGE employee_data AS
  TYPE employee_cv_type IS REF CURSOR;
  PROCEDURE open_employee_data (
          employee_cv   IN OUT employee_cv_type,
          x_dno         IN     employee.dno%TYPE); 

  PROCEDURE fetch_employee_data (
          employee_cv      IN    employee_cv_type,
          employee_output  OUT   VARCHAR2);
END employee_data;
/

CREATE OR REPLACE PACKAGE BODY employee_data AS
  PROCEDURE open_employee_data (
          employee_cv   IN OUT employee_cv_type,
          x_dno         IN     employee.dno%TYPE) IS
          dependent_count INTEGER;
  BEGIN
    SELECT COUNT(*)
    INTO dependent_count
    FROM employee, dependent
    WHERE employee.ssn = dependent.essn
    AND employee.dno = x_dno;
    
    IF dependent_count < 2 THEN
        OPEN employee_cv FOR
            SELECT *
            FROM employee
            WHERE employee.dno = x_dno;
    ELSE
        OPEN employee_cv FOR
            SELECT dependent.*
            FROM dependent, employee
            WHERE employee.dno = x_dno
            AND employee.ssn = dependent.essn;
    END IF;
  END open_employee_data;
  
  PROCEDURE fetch_employee_data (
          employee_cv      IN    employee_cv_type,
          employee_output  OUT   VARCHAR2) IS
          
          employee_row  employee%ROWTYPE;
          dependent_row dependent%ROWTYPE;
  BEGIN
    FETCH employee_cv INTO employee_row;
    employee_output := employee_row.lname || ' ' || employee_row.salary;
  EXCEPTION
    WHEN ROWTYPE_MISMATCH THEN
        FETCH employee_cv INTO dependent_row;
        employee_output := dependent_row.dependent_name || ' ' ||
                           dependent_row.bdate;
  END fetch_employee_data;
END employee_data;
/

DECLARE
     department_number  employee.dno%TYPE := 5;
     employee_cv        employee_data.employee_cv_type;
     employee_output    VARCHAR2(1000);
BEGIN
     employee_data.open_employee_data (employee_cv, department_number);
     LOOP
          employee_data.fetch_employee_data (employee_cv, employee_output);
          EXIT WHEN employee_cv%NOTFOUND;
          dbms_output.put_line (employee_output);
     END LOOP;
END;
/



