REM $Id: lpdemo.sql,v 1.1 2001/11/30 23:26:33 bill Exp $
REM From "Learning Oracle PL/SQL" page 300

REM Show how to call the external procedure from PL/SQL

DECLARE
   result PLS_INTEGER;
BEGIN
   result := lp('The rain is in Spain.
   So far this month, 23.4 centimeters!');
   IF result = 1
   THEN
      DBMS_OUTPUT.PUT_LINE('Houston, we have a problem.');
   END IF;
END;
/

