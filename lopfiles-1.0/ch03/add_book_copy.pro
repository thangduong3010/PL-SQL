rEM $Id: add_book_copy.pro,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3

REM Support utility used by the test_book_copy_qty script; adds record to
REM book_copies table

CREATE OR REPLACE PROCEDURE add_book_copy(isbn_in IN VARCHAR2,
   barcode_id_in IN VARCHAR2)
IS
BEGIN
   IF isbn_in IS NOT NULL AND barcode_id_in IS NOT NULL
   THEN
      INSERT INTO book_copies (isbn, barcode_id)
      VALUES (isbn_in, barcode_id_in);
   END IF;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX
   THEN
      NULL;
END;
/

SHOW ERRORS

