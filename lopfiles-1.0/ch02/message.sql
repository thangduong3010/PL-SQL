REM $Id: message.sql,v 1.1 2001/11/30 23:08:30 bill Exp $
REM From "Learning Oracle PL/SQL" page 30

REM Demonstrate the calling of a PL/SQL function

SET SERVEROUTPUT ON SIZE 1000000

DECLARE
   msg VARCHAR2(30);
BEGIN
   msg := message_for_the_world;
   DBMS_OUTPUT.PUT_LINE(msg);
END;
/

