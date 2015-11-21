/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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
