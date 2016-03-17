REM $Id: simple_select.sql,v 1.1 2001/11/30 23:19:51 bill Exp $
REM From "Learning Oracle PL/SQL" page 152

REM Show use of SELECT INTO to retrieve one row

REM In the first printing of the book, two question marks appear in the
REM declaration of a variable, that is, VARCHAR2(??).  The correct code
REM appears below.

DECLARE
   favorite_play_title VARCHAR2(200);
   publication_date DATE;
BEGIN
   SELECT title, date_published
     INTO favorite_play_title, publication_date
     FROM books
    WHERE UPPER(author) LIKE 'SHAKESPEARE%';
END;
/

