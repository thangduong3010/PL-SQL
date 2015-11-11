/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE TRIGGER EmployeeIntegrityRow
	AFTER DELETE OR UPDATE OF ssn ON employee
 	FOR EACH ROW
BEGIN
    supervisor.DeleteIndex := supervisor.DeleteIndex + 1;
    supervisor.DeleteList (supervisor.DeleteIndex) := :old.ssn;
END EmployeeIntegrity;
/

