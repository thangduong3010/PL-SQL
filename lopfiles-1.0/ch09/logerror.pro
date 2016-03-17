REM $Id: logerror.pro,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 326

REM Illustration of error-logging program that uses autonomous transaction
REM feature

CREATE OR REPLACE PROCEDURE logerror(msg IN VARCHAR2,
   called_from IN VARCHAR2 DEFAULT who_am_i())
AS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO messages (username, from_where, timestamp, text)
   VALUES (USER, called_from, SYSDATE, msg);
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
END;
/

SHOW ERRORS

