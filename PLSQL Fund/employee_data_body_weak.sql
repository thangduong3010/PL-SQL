/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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

