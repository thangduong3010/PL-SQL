/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

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

