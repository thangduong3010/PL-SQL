REM $Id: rowtype.sql,v 1.1 2001/11/30 23:19:51 bill Exp $
REM From "Learning Oracle PL/SQL" page 163

REM Illustrate fetch into record-typed variable declared using %ROWTYPE

REM First printing of book erroneously uses "bkcur" rather than "bcur".
REM Correct code appears below.

DECLARE
   CURSOR bcur
       IS SELECT title, date_published
     FROM books
    WHERE UPPER(author) LIKE 'SHAKESPEARE%';

   brec bcur%ROWTYPE;

BEGIN
   OPEN bcur;
   LOOP
      FETCH bcur INTO brec;
      EXIT WHEN bcur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(bcur%ROWCOUNT
         || ') ' || brec.title
         || ', published in '
         || TO_CHAR(brec.date_published, 'YYYY'));
   END LOOP;
   CLOSE bcur;
END;
/

