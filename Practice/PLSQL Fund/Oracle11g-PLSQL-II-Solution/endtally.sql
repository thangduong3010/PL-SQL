/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE TRIGGER EndTally
   BEFORE LOGOFF
   ON SCHEMA
BEGIN
   IF stats.MessagesTableExists THEN
      Stats.TallyStats (stats.EndTriggerCount,
                        stats.EndProcCount, 
                        stats.EndPackageCount);

      INSERT INTO Messages
         VALUES ('Trigger count went from ' || stats.StartTriggerCount ||
                 ' to ' || stats.EndTriggerCount);
      INSERT INTO Messages
         VALUES ('Stored Procedures count went from ' || stats.StartProcCount ||
                 ' to ' || stats.EndProcCount);
      INSERT INTO Messages
         VALUES  ('Package count went from ' || stats.StartPackageCount ||
                  ' to ' || stats.EndPackageCount);
   END IF;
END;
/

