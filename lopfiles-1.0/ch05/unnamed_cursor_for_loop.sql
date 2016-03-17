REM $Id: unnamed_cursor_for_loop.sql,v 1.1 2001/11/30 23:19:51 bill Exp $
REM From "Learning Oracle PL/SQL" page 165

REM Illustrate unnamed cursor for loop

REM First printing of this book erroneously refers to bcur%ROWCOUNT in
REM the PUT_LINE statement.  Corrected code is below.

BEGIN
   FOR brec IN 
      (SELECT title, date_published
         FROM books
        WHERE UPPER(author) LIKE 'SHAKESPEARE%')
   LOOP
      DBMS_OUTPUT.PUT_LINE(brec.title
         || ', published in '
         || TO_CHAR(brec.date_published, 'YYYY'));
   END LOOP;
END;
/

