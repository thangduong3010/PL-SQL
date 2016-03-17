REM $Id: test_book.pkb,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3.  Spec on page 98.

REM Package body of unit tester for the "book" package

CREATE OR REPLACE PACKAGE BODY test_book AS

   overall_success BOOLEAN := TRUE;
   l_verbose BOOLEAN := TRUE;
   dup_val_sqlcode CONSTANT VARCHAR2(12) := '-1';
   val_err_sqlcode CONSTANT VARCHAR2(12) := '-6502';
   okay_sqlcode CONSTANT VARCHAR2(12) := '0';
   bad_fk_sqlcode CONSTANT VARCHAR2(12) := '-2291';
   no_data_found_sqlcode CONSTANT VARCHAR2(12) := '100';


   /* convenient set of column values to use in various tests */

   l_isbn books.isbn%TYPE := '1-56592-335-9';
   l_title books.title%TYPE := 'Oracle PL/SQL Programming';
   l_summary books.summary%TYPE := 'Reference for PL/SQL developers, ' ||
       'including examples and best practice recommendations.';
   l_author books.author%TYPE := 'Feuerstein, Steven, and Bill Pribyl';
   l_date_published books.date_published%TYPE :=
      TO_DATE('01-SEP-1997', 'DD-MON-YYYY');
   l_page_count books.page_count%TYPE := 987;
   l_barcode_id book_copies.barcode_id%TYPE := '100000001';


   /* ======================================================================
   || Utility routines.  First some generic stuff that could
   || actually be moved elsewhere.
   */

   PROCEDURE pl(msg IN VARCHAR2, newline IN BOOLEAN DEFAULT TRUE) IS
   BEGIN
      IF l_verbose
      THEN
         IF newline THEN
            DBMS_OUTPUT.PUT_LINE(msg);
         ELSE
            DBMS_OUTPUT.PUT(msg);
         END IF;
      END IF;
   END pl;

   PROCEDURE reporteq (description IN VARCHAR2, expected_value IN VARCHAR2,
      actual_value IN VARCHAR2) IS
   BEGIN
      pl('...' || description || ': ', newline => FALSE);
      IF expected_value = actual_value
         OR (expected_value IS NULL AND actual_value IS NULL)
      THEN
         pl('PASSED');
      ELSE
         overall_success := FALSE;
         pl('FAILED.  Expected ' || expected_value || '; got ' || actual_value);
      END IF;
   END;


   FUNCTION my_to_char (is_true IN BOOLEAN) RETURN VARCHAR2 IS
   BEGIN
      IF is_true
      THEN
         RETURN 'TRUE';
      ELSIF NOT is_true
      THEN
         RETURN 'FALSE';
      ELSE
         RETURN TO_CHAR(NULL);
      END IF;
   END;
      
   
   PROCEDURE reporteq (description IN VARCHAR2, expected_value IN BOOLEAN,
      actual_value IN BOOLEAN) IS
   BEGIN
      reporteq(description, my_to_char(expected_value),
         my_to_char(actual_value));
   END reporteq;


   /* ======================================================================
   || Now some more private routines that are unique to books.
   */

   FUNCTION book_count RETURN NUMBER IS
      how_many NUMBER;
   BEGIN
      SELECT COUNT(*) INTO how_many FROM books;
      RETURN how_many;
   END;

   FUNCTION book_copy_count RETURN NUMBER IS
      how_many NUMBER;
   BEGIN
      SELECT COUNT(*) INTO how_many FROM book_copies;
      RETURN how_many;
   END;
   
   PROCEDURE add_one_book IS
   BEGIN
      book.add(isbn_in => l_isbn, barcode_id_in => l_barcode_id, 
         title_in => l_title, summary_in => l_summary, author_in => l_author,
         date_published_in => l_date_published, page_count_in => l_page_count);
   END;


   /* ======================================================================
   || A "driver" that calls all the other tests
   */

   PROCEDURE run(verbose IN BOOLEAN) IS
   BEGIN
      l_verbose := verbose;
      IF l_verbose
      THEN
         DBMS_OUTPUT.PUT_LINE('Testing book package...');
      END IF;
      add;
      add_copy;
      book_copy_qty;
      change;
      remove_copy;
      weed;
      IF overall_success
      THEN
         DBMS_OUTPUT.PUT_LINE('book package: PASSED');
      ELSE
         DBMS_OUTPUT.PUT_LINE('book package: FAILED');
      END IF;
         
   END run;

   
   /* ======================================================================
   || Unit tests for each routine in the package we're testing
   */

   PROCEDURE add IS

      CURSOR bookcur IS
         SELECT COUNT(*) FROM books
          WHERE isbn = l_isbn
            AND title = l_title
            AND summary = l_summary
            AND author = l_author
            AND date_published = l_date_published
            AND page_count = l_page_count;

      CURSOR copiescur IS
         SELECT COUNT(*) FROM book_copies
          WHERE isbn = l_isbn
            AND barcode_id = l_barcode_id;

      how_many NUMBER;
      l_sqlcode NUMBER;

   BEGIN

      DELETE book_copies;
      DELETE books;

      /* run the "add" routine, supplying all inputs */
      add_one_book;
      
      /* Now lets do a test with a NULL isbn to see if input detection works.
      || if it works, we trap the exception; if it doesn't, the failure message
      || will print.  Strictly speaking, we should repeat this test using a NULL
      || barcode_id.
       */

      /* check whether null isbn correctly raises exception */

      BEGIN
         book.add(isbn_in => NULL, barcode_id_in => 'foo',
            title_in => 'foo', summary_in => 'foo', author_in => 'foo',
            date_published_in => SYSDATE, page_count_in => 0);
         l_sqlcode := SQLCODE;
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;

      reporteq('add procedure, detection of NULL input', val_err_sqlcode,
                TO_CHAR(l_sqlcode));

      /* is there one and only one new book, and one and only one 
      || new book copy?
      */
      reporteq('add procedure, book_record count', '1', TO_CHAR(book_count()));
      reporteq('add procedure, book_copy record count',
               '1', TO_CHAR(book_copy_count()));

      /* do the inserted records match what is expected? */

      OPEN bookcur; FETCH bookcur INTO how_many;
      reporteq('add procedure, book fetch matches insert',
               TRUE, bookcur%FOUND);
      CLOSE bookcur;

      OPEN copiescur; FETCH copiescur INTO how_many;
      reporteq('add procedure, book copy fetch matches insert', TRUE,
                 copiescur%FOUND);
      CLOSE copiescur;

      /* Confirm that attempting to add same isbn a second time will raise an
      || exception.  Yes I know this is really a test of the database design
      || but we might as well test it somewhere.
      */

      BEGIN
         add_one_book;
         l_sqlcode := SQLCODE;
      EXCEPTION
         WHEN OTHERS THEN
            l_sqlcode := SQLCODE;
      END;
      reporteq('add procedure, detection of duplicate isbn', dup_val_sqlcode,
               l_sqlcode);

   END add;

   /* ------------------------------------------------------------------- */
   PROCEDURE add_copy IS
      l_sqlcode NUMBER := 0;
   BEGIN
      DELETE book_copies;
      DELETE books;
      add_one_book;
      DELETE book_copies;
      book.add_copy(isbn_in => l_isbn, barcode_id_in => l_barcode_id);
      reporteq('add_copy procedure, nominal case, first book',
               '1', TO_CHAR(book_copy_count()));

      book.add_copy(isbn_in => l_isbn, barcode_id_in => '0101010101');
      reporteq('add_copy procedure, nominal case, second book',
               '2', TO_CHAR(book_copy_count()));

      BEGIN
         book.add_copy(isbn_in => l_isbn, barcode_id_in => l_barcode_id);
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;
      reporteq('add_copy procedure, ignore duplicates',
               okay_sqlcode, TO_CHAR(l_sqlcode));

      BEGIN
         book.add_copy(isbn_in => '1234567890', barcode_id_in => '0202020202');
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;
      reporteq('add_copy procedure, bad isbn detection',
               bad_fk_sqlcode, TO_CHAR(l_sqlcode));
      

      BEGIN
         book.add_copy(isbn_in => NULL, barcode_id_in => '0303030303');
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;
      reporteq('add_copy procedure, NULL isbn detection',
               val_err_sqlcode, TO_CHAR(l_sqlcode));

      BEGIN
         book.add_copy(isbn_in => 'anything', barcode_id_in => NULL);
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;
      reporteq('add_copy procedure, NULL barcode_id detection',
               val_err_sqlcode, TO_CHAR(l_sqlcode));
   END add_copy;

   /* ------------------------------------------------------------------- */
   PROCEDURE book_copy_qty IS
   BEGIN
      DELETE book_copies;
      DELETE books;
      add_one_book;
      DELETE book_copies;
      reporteq('book_copy_qty function, zero count', '0', 
         TO_CHAR(book.book_copy_qty(l_isbn)));
      book.add_copy(isbn_in => l_isbn, barcode_id_in => l_barcode_id);
      book.add_copy(isbn_in => l_isbn, barcode_id_in => '0101010101');
      reporteq('book_copy_qty function, non-zero count', '2', 
         TO_CHAR(book.book_copy_qty(l_isbn)));
   END;

   /* ------------------------------------------------------------------- */
   PROCEDURE change IS
      l_new_summary books.summary%TYPE := 'A long and boring book about PL/SQL';
      CURSOR chgcur IS
         SELECT COUNT(*) FROM books
          WHERE isbn = l_isbn
            AND title = l_title
            AND summary = l_new_summary
            AND author = l_author
            AND date_published = l_date_published
            AND page_count = l_page_count;

      how_many NUMBER;
      l_sqlcode NUMBER;
   BEGIN
      DELETE book_copies;
      DELETE books;
      add_one_book;

      /* Now change only the summary */
      book.change(isbn_in => l_isbn, 
         new_summary => l_new_summary, new_title => l_title, 
         new_author => l_author, new_date_published => l_date_published, 
         new_page_count => l_page_count);
      OPEN chgcur; FETCH chgcur INTO how_many; CLOSE chgcur;
      reporteq('change procedure, single field test', '1', TO_CHAR(how_many));

      /* NULL isbn test */
      BEGIN
         book.change(isbn_in => NULL,
         new_title => l_title, new_summary => l_summary, new_author => l_author,
         new_date_published => l_date_published,
            new_page_count => l_page_count);
         l_sqlcode := SQLCODE;
      EXCEPTION
      WHEN OTHERS THEN
         l_sqlcode := SQLCODE;
      END;
      reporteq('change procedure, NULL barcode_id detection',
         val_err_sqlcode, TO_CHAR(l_sqlcode));

   END change;

   /* ------------------------------------------------------------------- */
   PROCEDURE remove_copy IS
      l_sqlcode NUMBER;
   BEGIN
      DELETE book_copies;
      DELETE books;
      add_one_book;
      book.remove_copy(barcode_id_in => l_barcode_id);
      reporteq('remove_copy procedure, book count normal',
               '1', TO_CHAR(book_count()));
      reporteq('remove_copy procedure, book copy count normal',
               '0', TO_CHAR(book_copy_count()));

      /* If we delete it again, there should be no error. */
      BEGIN
         book.remove_copy(barcode_id_in => l_barcode_id);
         l_sqlcode := SQLCODE;
      EXCEPTION
         WHEN OTHERS THEN
            l_sqlcode := SQLCODE;
      END;
      reporteq('remove_copy procedure, superfluous invocation', okay_sqlcode,
         TO_CHAR(l_sqlcode));

   END remove_copy;

   /* ------------------------------------------------------------------- */
   PROCEDURE weed IS
      l_sqlcode NUMBER;
   BEGIN
      DELETE book_copies;
      DELETE books;
      add_one_book;
      book.weed(l_isbn);
      reporteq('weed procedure, book count normal', '0', TO_CHAR(book_count()));
      reporteq('weed procedure, book copy count normal',
               '0', TO_CHAR(book_copy_count()));

      /* If we weed it again, there should a NO_DATA_FOUND error. */
      BEGIN
         book.weed(l_isbn);
         l_sqlcode := SQLCODE;
      EXCEPTION
         WHEN OTHERS THEN
            l_sqlcode := SQLCODE;
      END;
      reporteq('weed procedure, superfluous invocation',
               no_data_found_sqlcode, TO_CHAR(l_sqlcode));

   END weed;

END test_book;
/

SHOW ERRORS

