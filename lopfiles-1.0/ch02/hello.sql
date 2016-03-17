REM $Id: hello.sql,v 1.1 2001/11/30 23:08:30 bill Exp $
REM From Learning Oracle PL/SQL page 22

REM PL/SQL anonymous block to display the archetypal programmer's greeting

REM Make sure SQL*Plus SERVEROUTPUT setting is on
SET SERVEROUTPUT ON SIZE 1000000

BEGIN
   DBMS_OUTPUT.PUT_LINE('hello, world');
END;
/

