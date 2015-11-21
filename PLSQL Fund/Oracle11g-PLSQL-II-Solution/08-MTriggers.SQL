/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM MAINTAIN TRIGGER-1
CREATE OR REPLACE PACKAGE Supervisor AS
   TYPE SSNarray IS TABLE OF employee.ssn%TYPE
   INDEX BY SIMPLE_INTEGER;

   DeleteList   SSNarray;
   EmptyArray   SSNarray;
   DeleteIndex  SIMPLE_INTEGER DEFAULT 0;
   PROCEDURE ReplaceSupervisor;
END Supervisor;
/

REM MAINTAIN TRIGGER-2
CREATE OR REPLACE PACKAGE BODY Supervisor AS

PROCEDURE ReplaceSupervisor IS
BEGIN
  FOR i IN supervisor.DeleteList.FIRST .. supervisor.DeleteList.LAST LOOP
    UPDATE employee
      SET superssn = (SELECT ssn
                      FROM employee
                      WHERE superssn IS NULL)
      WHERE superssn = supervisor.DeleteList (i);
  END LOOP;
END ReplaceSupervisor;

END Supervisor;
/

REM MAINTAIN TRIGGER-3
CREATE OR REPLACE TRIGGER EmployeeIntegrityRow
	AFTER DELETE OR UPDATE OF ssn ON employee
 	FOR EACH ROW
BEGIN
    supervisor.DeleteIndex := supervisor.DeleteIndex + 1;
    supervisor.DeleteList (supervisor.DeleteIndex) := :old.ssn;
END EmployeeIntegrity;
/

REM MAINTAIN TRIGGER-4
CREATE OR REPLACE TRIGGER EmployeeIntegrityStatement
	AFTER DELETE OR UPDATE OF ssn ON employee

BEGIN
    supervisor.ReplaceSupervisor;

    supervisor.DeleteList := supervisor.EmptyArray;
    supervisor.DeleteIndex := 0;

END EmployeeIntegrityStatement;
/

REM MAINTAIN TRIGGER-5
DELETE FROM employee
WHERE LName = 'Wong';

SELECT supervisor.LName AS SuperLName, supervisor.ssn AS SuperSSN,
       subordinate.LName AS SubLName, subordinate.ssn AS SubSSN
FROM employee supervisor
INNER JOIN employee subordinate ON subordinate.superssn = supervisor.ssn
ORDER BY supervisor.LName, subordinate.LName;

ROLLBACK;

DELETE FROM employee
WHERE LName IN ('Wallace', 'Wong');

SELECT supervisor.LName AS SuperLName, supervisor.ssn AS SuperSSN,
       subordinate.LName AS SubLName, subordinate.ssn AS SubSSN
FROM employee supervisor
INNER JOIN employee subordinate ON subordinate.superssn = supervisor.ssn
ORDER BY supervisor.LName, subordinate.LName;

REM MAINTAIN TRIGGER-6
ROLLBACK;

ALTER TRIGGER EmployeeIntegrityRow DISABLE;

ALTER TRIGGER EmployeeIntegrityStatement DISABLE;

REM MAINTAIN TRIGGER-7
CREATE OR REPLACE TRIGGER EmployeeIntegrity
FOR DELETE OR UPDATE OF ssn ON employee
COMPOUND TRIGGER

   TYPE SSNarray IS TABLE OF employee.ssn%TYPE
   INDEX BY SIMPLE_INTEGER;

   DeleteList   SSNarray;
   DeleteIndex  SIMPLE_INTEGER DEFAULT 0;

AFTER EACH ROW
IS
BEGIN
    DeleteIndex := DeleteIndex + 1;
    DeleteList (DeleteIndex) := :old.ssn;
END AFTER EACH ROW;

AFTER STATEMENT
IS
BEGIN
  FOR i IN DeleteList.FIRST .. DeleteList.LAST LOOP

    UPDATE employee
      SET superssn = (SELECT ssn
                      FROM employee
                      WHERE superssn IS NULL)
      WHERE superssn = DeleteList (i);

  END LOOP;
END AFTER STATEMENT;

END EmployeeIntegrity;
/

REM MAINTAIN TRIGGER-8
DELETE FROM employee
WHERE LName = 'Wong';

SELECT supervisor.LName AS SuperLName, supervisor.ssn AS SuperSSN,
       subordinate.LName AS SubLName, subordinate.ssn AS SubSSN
FROM employee supervisor
INNER JOIN employee subordinate ON subordinate.superssn = supervisor.ssn
ORDER BY supervisor.LName, subordinate.LName;

ROLLBACK;

DELETE FROM employee
WHERE LName IN ('Wallace', 'Wong');

SELECT supervisor.LName AS SuperLName, supervisor.ssn AS SuperSSN,
       subordinate.LName AS SubLName, subordinate.ssn AS SubSSN
FROM employee supervisor
INNER JOIN employee subordinate ON subordinate.superssn = supervisor.ssn
ORDER BY supervisor.LName, subordinate.LName;



