REM $Id: book.pks,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 91

REM Specification of PL/SQL package that manages book data

CREATE OR REPLACE PACKAGE book
AS
   PROCEDURE add(isbn_in IN VARCHAR2, title_in IN VARCHAR2,
      author_in IN VARCHAR2, page_count_in IN NUMBER, 
      summary_in IN VARCHAR2 DEFAULT NULL,
      date_published_in IN DATE DEFAULT NULL,
      barcode_id_in IN VARCHAR2 DEFAULT NULL);

   PROCEDURE add_copy(isbn_in IN VARCHAR2, barcode_id_in IN VARCHAR2);

   FUNCTION book_copy_qty(isbn_in IN VARCHAR2)
   RETURN NUMBER;

   PROCEDURE change(isbn_in IN VARCHAR2, new_title IN VARCHAR2, 
      new_author IN VARCHAR2, new_page_count IN NUMBER,
      new_summary IN VARCHAR2 DEFAULT NULL, 
      new_date_published IN DATE DEFAULT NULL);

   PROCEDURE remove_copy(barcode_id_in IN VARCHAR2);

   PROCEDURE weed(isbn_in IN VARCHAR2);
END book;
/

SHOW ERRORS

