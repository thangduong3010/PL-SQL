REM $Id: fetch_one.sql,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 156

REM Show use of a cursor to retrieve one row

REM In the first printing of the book, two question marks appear in the
REM declaration of a variable, that is, VARCHAR2(??).  The correct code
REM appears below.

DECLARE
   favorite_play_title VARCHAR2(200);
   publication_date DATE;

   CURSOR bcur                              /* 1. declare */
       IS SELECT title, date_published
     FROM books
    WHERE UPPER(author) LIKE 'SHAKESPEARE%';

BEGIN
   OPEN bcur;                               /* 2. open    */

   FETCH bcur INTO favorite_play_title,     /* 3. fetch   */
      publication_date;

   CLOSE bcur;                              /* 4. close   */
END;
/

