/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE TRIGGER EmployeeIntegrityStatement
	AFTER DELETE OR UPDATE OF ssn ON employee

BEGIN
    supervisor.replaceSupervisor;
    supervisor.DeleteList := supervisor.EmptyArray;
    supervisor.DeleteIndex := 0;

END EmployeeIntegrityStatement;
/

