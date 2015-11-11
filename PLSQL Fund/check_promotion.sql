/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PROCEDURE check_promotion (
    ManagerSSN IN department.mgrssn%TYPE,
    DeptNumber IN department.dnumber%TYPE) AS

 	x_dno	employee.dno%TYPE;
BEGIN
	SELECT dno
	INTO x_dno
	FROM employee
	WHERE employee.ssn = ManagerSSN;

	IF x_dno <> DeptNumber THEN
      RAISE_APPLICATION_ERROR(-20000, 'Manager must be promoted from within the department');
 	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20001, 'Manager is not a current employee');
END;
/

