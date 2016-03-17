REM $Id: test_add_book.sql,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 84ff

REM Anonymous block version of a program to test the add_book procedure

REM Note: If you want line numbers to match up with the line numbers in the
REM book, you can delete all these lines above the DECLARE.

DECLARE
   l_isbn VARCHAR2(13) := '1-56592-335-9';
   l_title VARCHAR2(200) := 'Oracle PL/SQL Programming';
   l_summary VARCHAR2(2000) := 'Reference for PL/SQL developers, ' ||
       'including examples and best practice recommendations.';
   l_author varchar2(200) := 'Feuerstein, Steven, and Bill Pribyl';
   l_date_published DATE := TO_DATE('01-SEP-1997', 'DD-MON-YYYY');
   l_page_count NUMBER := 987;
   l_barcode_id VARCHAR2(100) := '100000001';

   CURSOR bookCountCur IS
      SELECT COUNT(*) FROM books;

   CURSOR copiesCountCur IS
      SELECT COUNT(*) FROM book_copies;

   CURSOR bookMatchCur IS
      SELECT COUNT(*) FROM books
       WHERE isbn = l_isbn AND title = l_title AND summary = l_summary
         AND author = l_author AND date_published = l_date_published
         AND page_count = l_page_count;

   CURSOR copiesMatchCur IS
      SELECT COUNT(*) FROM book_copies
       WHERE isbn = l_isbn AND barcode_id = l_barcode_id;

   how_many NUMBER;
   l_sqlcode NUMBER;
BEGIN
   DELETE book_copies;
   DELETE books;

   add_book(isbn_in => l_isbn, barcode_id_in => l_barcode_id, 
      title_in => l_title, summary_in => l_summary, author_in => l_author,
      date_published_in => l_date_published, page_count_in => l_page_count);

   OPEN bookMatchCur;
   FETCH bookMatchCur INTO how_many;
   reporteqbool('add procedure, book fetch matches insert', 
      expected_value => TRUE, actual_value => bookMatchCur%FOUND);
   CLOSE bookMatchCur;

   BEGIN
      add_book(isbn_in => NULL, barcode_id_in => 'foo', title_in => 'foo',
         summary_in => 'foo', author_in => 'foo',
         date_published_in => SYSDATE, page_count_in => 0);
      l_sqlcode := SQLCODE;
   EXCEPTION
   WHEN OTHERS THEN
      l_sqlcode := SQLCODE;
   END;

   reporteq('add procedure, detection of NULL input',
      expected_value => '-6502', actual_value => TO_CHAR(l_sqlcode));

   OPEN bookCountCur;
   FETCH bookCountCur INTO how_many;
   reporteq('add procedure, book_record count', expected_value => '1',
      actual_value => how_many);
   CLOSE bookCountCur;

   OPEN copiesCountCur;
   FETCH copiesCountCur INTO how_many;
   reporteq('add procedure, book_copy record count', expected_value => '1',
      actual_value => how_many);
   CLOSE copiesCountCur;

   OPEN copiesMatchCur;
   FETCH copiesMatchCur INTO how_many;
   reporteqbool('add procedure, book copy fetch matches insert', 
      expected_value => TRUE, actual_value => copiesMatchCur%FOUND);
   CLOSE copiesMatchCur;

   BEGIN
      add_book(isbn_in => l_isbn, barcode_id_in => l_barcode_id, 
         title_in => l_title, summary_in => l_summary, author_in => l_author,
         date_published_in => l_date_published,
         page_count_in => l_page_count);
      l_sqlcode := SQLCODE;
   EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
   END;
   reporteq('add procedure, detection of duplicate isbn',
      expected_value => '-1', actual_value => l_sqlcode);
END;
/

