REM $Id: available_copies.fun,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 306

REM Create function to return a PL/SQL collection of barcodes

CREATE OR REPLACE FUNCTION available_copies (isbn_in IN books.isbn%TYPE)
RETURN book_barcodes_t
IS
   copies book_barcodes_t;
BEGIN
   SELECT barcode_id
     BULK COLLECT INTO copies
     FROM book_copies
    WHERE isbn = isbn_in
      AND bookstatus(barcode_id) = 'SHELVED';

   RETURN copies;
END;
/

SHOW ERRORS

