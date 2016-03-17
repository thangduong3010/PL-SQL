REM $Id: call_book_copy_qty.sql,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 81

REM Example of calling book_copy_qty function

SET SERVEROUTPUT ON
BEGIN
   DBMS_OUTPUT.PUT_LINE('Number of copies of 1-56592-335-9: '
      || book_copy_qty('1-56592-335-9'));
END;
/

