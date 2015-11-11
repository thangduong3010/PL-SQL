/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

REM SYSTEM TRIGGER-1
CREATE TABLE messages (MessageText VARCHAR2(100));

REM SYSTEM TRIGGER-3
CREATE OR REPLACE TRIGGER StartTally
   AFTER LOGON
   ON SCHEMA

BEGIN
   IF stats.MessagesTableExists THEN
      Stats.TallyStats (stats.StartTriggerCount,
                        stats.StartProcCount, 
                        stats.StartPackageCount);

      INSERT INTO Messages
        VALUES ('IP address for ' || ora_login_user || ' is ' || ora_client_ip_address);
   END IF;
END;
/

REM SYSTEM TRIGGER-4
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
         VALUES ('Stored Procedures count went from ' ||
                 stats.StartProcCount ||
                 ' to ' || stats.EndProcCount);
      INSERT INTO Messages
         VALUES  ('Package count went from ' || stats.StartPackageCount ||
                  ' to ' || stats.EndPackageCount);
   END IF;
END;
/
