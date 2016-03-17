REM $Id: test_book_copy_qty.sql,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 88

REM Anonymous block version of a program to test the book_copy_qty function

DECLARE
   l_isbn VARCHAR2(13) := '1-56592-335-9';
   l_isbn2 VARCHAR2(13) := '2-56592-335-9';
   l_title VARCHAR2(200) := 'Oracle PL/SQL Programming';
   l_summary VARCHAR2(2000) := 'Reference for PL/SQL developers, ' ||
       'including examples and best practice recommendations.';
   l_author varchar2(200) := 'Feuerstein, Steven, and Bill Pribyl';
   l_date_published DATE := TO_DATE('01-SEP-1997', 'DD-MON-YYYY');
   l_page_count NUMBER := 987;
   l_barcode_id VARCHAR2(100) := '100000001';
   l_barcode_id2 VARCHAR2(100) := '100000002';
   l_barcode_id3 VARCHAR2(100) := '100000003';

   how_many NUMBER;
BEGIN
   DELETE book_copies;
   DELETE books;

   reporteq('book_copy_qty function, zero count', '0',
      TO_CHAR(book_copy_qty(l_isbn)));

   /* Lets assume that add_book is working properly */
   add_book(isbn_in => l_isbn, barcode_id_in => l_barcode_id,
      title_in => l_title, summary_in => l_summary, author_in => l_author,
      date_published_in => l_date_published, page_count_in => l_page_count);

   reporteq('book_copy_qty function, unit count', '1',
      TO_CHAR(book_copy_qty(l_isbn)));

   add_book_copy(isbn_in => l_isbn, barcode_id_in => l_barcode_id2);
   add_book_copy(isbn_in => l_isbn, barcode_id_in => l_barcode_id3);

   reporteq('book_copy_qty function, multi count', '3',
      TO_CHAR(book_copy_qty(l_isbn)));

   reporteq('book_copy_qty function, null ISBN', '0',
      TO_CHAR(book_copy_qty(NULL)));
END;
/

