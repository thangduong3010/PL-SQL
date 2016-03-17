REM $Id: simple_fetch_loop.sql,v 1.1 2001/11/30 23:19:51 bill Exp $
REM From "Learning Oracle PL/SQL" page 160

REM Illustrate simple fetch loop

REM In the first printing of the book, two question marks appear in the
REM declaration of a variable, that is, VARCHAR2(??).  The correct code
REM appears below.

DECLARE
   favorite_play_title VARCHAR2(200);
   publication_date DATE;

   CURSOR bcur
       IS SELECT title, date_published
     FROM books
    WHERE UPPER(author) LIKE 'SHAKESPEARE%';

BEGIN
   OPEN bcur;
   LOOP
      FETCH bcur INTO favorite_play_title,
         publication_date;
      EXIT WHEN bcur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(bcur%ROWCOUNT
         || ') ' || favorite_play_title
         || ', published in '
         || TO_CHAR(publication_date, 'YYYY'));
   END LOOP;
   CLOSE bcur;
END;
/

