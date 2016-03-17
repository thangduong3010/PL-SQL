REM $Id: book.pkb,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 92

REM Body of book package

CREATE OR REPLACE PACKAGE BODY book
AS
   /* "private" procedure for use only in this package body */
   PROCEDURE assert_notnull (tested_variable IN VARCHAR2)
   IS
   BEGIN
      IF tested_variable IS NULL
      THEN
         RAISE VALUE_ERROR;
      END IF;
   END assert_notnull;
   
   FUNCTION book_copy_qty(isbn_in IN VARCHAR2)
   RETURN NUMBER
   AS
      number_o_copies NUMBER := 0;  /* should this be PLS_INTEGER ? */
      CURSOR bc_cur IS
         SELECT COUNT(*)
           FROM book_copies
          WHERE isbn = isbn_in;
   BEGIN
      IF isbn_in IS NOT NULL
      THEN
         OPEN bc_cur;
         FETCH bc_cur INTO number_o_copies;
         CLOSE bc_cur;
      END IF;
      RETURN number_o_copies;
   END;

   PROCEDURE add(isbn_in IN VARCHAR2, title_in IN VARCHAR2,
      author_in IN VARCHAR2, page_count_in IN NUMBER, 
      summary_in IN VARCHAR2, date_published_in IN DATE,
      barcode_id_in IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(isbn_in);

      INSERT INTO books (isbn, title, summary, author, date_published,
         page_count)
      VALUES (isbn_in, title_in, summary_in, author_in, date_published_in,
         page_count_in);

      IF barcode_id_in IS NOT NULL
      THEN
         add_copy(isbn_in, barcode_id_in);
      END IF;

   END add;

   PROCEDURE add_copy(isbn_in IN VARCHAR2, barcode_id_in IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(isbn_in);
      assert_notnull(barcode_id_in);
      INSERT INTO book_copies (isbn, barcode_id)
      VALUES (isbn_in, barcode_id_in);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;
   END;

   PROCEDURE change(isbn_in IN VARCHAR2, new_title IN VARCHAR2,
      new_author IN VARCHAR2, new_page_count IN NUMBER,
      new_summary IN VARCHAR2 DEFAULT NULL,
      new_date_published IN DATE DEFAULT NULL)
   IS
   BEGIN
      assert_notnull(isbn_in);
      UPDATE books
         SET title = new_title, author = new_author, page_count = new_page_count,
             summary = new_summary, date_published = new_date_published
       WHERE isbn = isbn_in;
      IF SQL%ROWCOUNT = 0
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END change;

   PROCEDURE remove_copy(barcode_id_in IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(barcode_id_in);
      DELETE book_copies
       WHERE barcode_id = barcode_id_in;
   END remove_copy;

   PROCEDURE weed(isbn_in IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(isbn_in);
      DELETE book_copies WHERE isbn = isbn_in;
      DELETE books WHERE isbn = isbn_in;
      IF SQL%ROWCOUNT = 0
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END weed;

END book;
/

SHOW ERRORS

