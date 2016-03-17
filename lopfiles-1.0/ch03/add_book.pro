REM $Id: add_book.pro,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 71

REM Procedure that adds record(s) to books and book_copies tables

CREATE OR REPLACE PROCEDURE add_book (isbn_in IN VARCHAR2,
   barcode_id_in IN VARCHAR2, title_in IN VARCHAR2, author_in IN VARCHAR2,
   page_count_in IN NUMBER, summary_in IN VARCHAR2 DEFAULT NULL,
   date_published_in IN DATE DEFAULT NULL)
AS
BEGIN
   /* check for reasonable inputs */

   IF isbn_in IS NULL
   THEN
      RAISE VALUE_ERROR;
   END IF;

   /* put a record in the "books" table */

   INSERT INTO books (isbn, title, summary, author, date_published, page_count)
   VALUES (isbn_in, title_in, summary_in, author_in, date_published_in,
      page_count_in);

   /* put a record in the "book_copies" table */

   IF barcode_id_in IS NOT NULL
   THEN
      INSERT INTO book_copies (isbn, barcode_id)
      VALUES (isbn_in, barcode_id_in);
   END IF;

END add_book;
/

SHOW ERRORS

