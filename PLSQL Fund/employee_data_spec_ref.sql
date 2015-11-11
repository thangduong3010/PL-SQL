/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PACKAGE employee_data AS
-- No type declaration

  PROCEDURE open_employee_data (
          employee_cv   IN OUT SYS_REFCURSOR,
          x_dno         IN     employee.dno%TYPE); 

  PROCEDURE fetch_employee_data (
          employee_cv      IN    SYS_REFCURSOR,
          employee_output  OUT   VARCHAR2);
END employee_data;
/

