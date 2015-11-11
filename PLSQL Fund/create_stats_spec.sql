/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PACKAGE Stats AS
   StartTriggerCount   PLS_INTEGER := 0;
   StartProcCount      PLS_INTEGER := 0;
   StartPackageCount   PLS_INTEGER := 0;

   EndTriggerCount   PLS_INTEGER := 0;
   EndProcCount      PLS_INTEGER := 0;
   EndPackageCount   PLS_INTEGER := 0;

PROCEDURE TallyStats (NumberTriggers OUT PLS_INTEGER,
                      NumberProcs    OUT PLS_INTEGER,
                      NumberPackages OUT PLS_INTEGER);

FUNCTION MessagesTableExists RETURN BOOLEAN;

END Stats;
/
