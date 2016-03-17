REM $Id: named_cursor_for_loop.sql,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 164

REM Illustrate "named cursor FOR loop"

REM First printing of book erroneously uses "bkcur" rather than "bcur".
REM Correct code appears below.

DECLARE
   CURSOR bcur
       IS SELECT title, date_published
     FROM books
    WHERE UPPER(author) LIKE 'SHAKESPEARE%';
BEGIN
   FOR brec IN bcur
   LOOP
      DBMS_OUTPUT.PUT_LINE(bcur%ROWCOUNT
         || ') ' || brec.title
         || ', published in '
         || TO_CHAR(brec.date_published, 'YYYY'));
   END LOOP;
END;
/

