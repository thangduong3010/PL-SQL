REM $Id: message_for_the_world.fun,v 1.1 2001/11/30 23:08:30 bill Exp $
REM From "Learning Oracle PL/SQL" page 30

REM Create a simple PL/SQL function to return a string

CREATE OR REPLACE FUNCTION message_for_the_world
RETURN VARCHAR2
AS
BEGIN
   RETURN 'hello, world';
END;
/

SHOW ERRORS

