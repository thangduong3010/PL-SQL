REM $Id: bookquerydemo.pro,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 177

REM Demo of how to use lopu.makewhere in order to construct a where clause for
REM a dynamic SQL statement

CREATE OR REPLACE PROCEDURE bookquerydemo (isbn_in IN VARCHAR2,
   author_in IN VARCHAR2, title_in IN VARCHAR2, date_in IN VARCHAR2)
AS
   TYPE bcur_t IS REF CURSOR;
   bcur bcur_t;
   brec books%ROWTYPE;
   where_clause VARCHAR2(2048);
BEGIN
   lopu.makewhere(where_clause, 'isbn', isbn_in);
   lopu.makewhere(where_clause, 'author', author_in);
   lopu.makewhere(where_clause, 'title', title_in);
   lopu.makewhere(where_clause, 'date_published', date_in, datatype => 'DATE',
      dataformat => 'DD-MON-YYYY');
   OPEN bcur FOR 'SELECT * FROM books ' || where_clause;
   LOOP
      FETCH bcur INTO brec;
      EXIT WHEN bcur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(brec.isbn || ' by ' || brec.author 
         || ': ' || brec.title);
   END LOOP;
   CLOSE bcur;
END;
/

SHOW ERRORS

