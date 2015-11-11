/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

CREATE OR REPLACE PACKAGE BODY Stats AS

PROCEDURE TallyStats (NumberTriggers OUT PLS_INTEGER,
                      NumberProcs    OUT PLS_INTEGER,
                      NumberPackages OUT PLS_INTEGER) IS
BEGIN
   SELECT COUNT(*)
   INTO NumberTriggers
   FROM user_objects
   WHERE object_type = 'TRIGGER';

   SELECT COUNT(*)
   INTO NumberProcs
   FROM user_objects
   WHERE object_type IN ('PROCEDURE', 'FUNCTION');

   SELECT COUNT(*)
   INTO NumberPackages
   FROM user_objects
   WHERE object_type = 'PACKAGE';

END TallyStats;

FUNCTION MessagesTableExists
RETURN BOOLEAN IS
      x  BINARY_INTEGER;
BEGIN
     SELECT COUNT(*)
     INTO x
     FROM user_objects
     WHERE object_name = 'MESSAGES';

   IF x = 1 THEN
      RETURN (TRUE);
   ELSE
      RETURN (FALSE);
   END IF;
END MessagesTableExists;

END Stats;
/
