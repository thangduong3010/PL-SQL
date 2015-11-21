/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PACKAGE Supervisor AS
   TYPE SSNarray IS TABLE OF employee.ssn%TYPE
   INDEX BY PLS_INTEGER;

   DeleteList   SSNarray;
   EmptyArray   SSNarray;

   DeleteIndex  PLS_INTEGER DEFAULT 0;

PROCEDURE ReplaceSupervisor;

END Supervisor;
/
