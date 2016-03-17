REM $Id: book.pkb,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 5

REM Body of "book" package implied by Chapter 5

CREATE OR REPLACE PACKAGE BODY book
AS
   PROCEDURE add(isbn_in IN VARCHAR2, title_in IN VARCHAR2,
      author_in IN VARCHAR2, page_count_in IN NUMBER, 
      summary_in IN VARCHAR2, date_published_in IN DATE,
      barcode_id_in IN VARCHAR2)
   IS
   BEGIN
      lopu.assert_notnull(isbn_in);

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
      lopu.assert_notnull(isbn_in);
      lopu.assert_notnull(barcode_id_in);
      INSERT INTO book_copies (isbn, barcode_id)
      VALUES (isbn_in, barcode_id_in);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;
   END;

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

   PROCEDURE change(isbn_in IN VARCHAR2, new_title IN VARCHAR2,
      new_author IN VARCHAR2, new_page_count IN NUMBER,
      new_summary IN VARCHAR2 DEFAULT NULL,
      new_date_published IN DATE DEFAULT NULL)
   IS
   BEGIN
      lopu.assert_notnull(isbn_in);
      UPDATE books
         SET title = new_title, author = new_author, page_count = new_page_count,
             summary = new_summary, date_published = new_date_published
       WHERE isbn = isbn_in;
      IF SQL%ROWCOUNT = 0
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END change;

   PROCEDURE remove_copy(isbn_in IN VARCHAR2, barcode_id_in IN VARCHAR2)
   IS
   BEGIN
      lopu.assert_notnull(barcode_id_in);
      lopu.assert_notnull(isbn_in);
      DELETE book_copies
       WHERE barcode_id = barcode_id_in
             AND isbn = isbn_in;
   END remove_copy;

   PROCEDURE weed(isbn_in IN VARCHAR2)
   IS
   BEGIN
      lopu.assert_notnull(isbn_in);
      DELETE book_copies WHERE isbn = isbn_in;
      DELETE books WHERE isbn = isbn_in;
      IF SQL%ROWCOUNT = 0
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END weed;

   FUNCTION book_cur (isbn_in IN VARCHAR2,
      title_in IN VARCHAR2,
      author_in IN VARCHAR2,
      date_published_in IN VARCHAR2,
      startrec IN VARCHAR2,
      rows_to_fetch IN VARCHAR2,
      orderby IN VARCHAR2)
      RETURN refcur_t
   IS
      refcur refcur_t;
      whereclause VARCHAR2(2048);
      startrec_num PLS_INTEGER;
      rows_to_fetch_num PLS_INTEGER;
   BEGIN
      lopu.makewhere(whereclause, 'isbn', isbn_in);
      lopu.makewhere(whereclause, 'title', title_in);
      lopu.makewhere(whereclause, 'author', author_in);
      lopu.makewhere(whereclause, 'date_published', date_published_in,
         'DATE');
      IF startrec IS NOT NULL AND lopu.is_number(startrec)
      THEN
         startrec_num := TO_NUMBER(startrec);
      ELSE
         startrec_num := 1;
      END IF;

      IF rows_to_fetch IS NOT NULL AND lopu.is_number(rows_to_fetch)
      THEN
         rows_to_fetch_num := TO_NUMBER(rows_to_fetch);
      ELSE
         rows_to_fetch_num := 1;
      END IF;

      OPEN refcur FOR
         'SELECT isbn, title, summary, author, date_published, page_count
            FROM (SELECT a.*, ROWNUM rnum
                    FROM (SELECT * 
                            FROM books '
                         || whereclause || '
                           ORDER BY ' || NVL(orderby,1) || ') a
                   WHERE ROWNUM < :ub) 
           WHERE rnum >= :lb'
         USING startrec_num + rows_to_fetch_num, startrec_num;

      RETURN refcur;
   END;


   FUNCTION book_copies_cur (isbn_in VARCHAR2)
      RETURN refcur_t
   IS
      refcur refcur_t;
   BEGIN
      OPEN refcur FOR
        'SELECT barcode_id, isbn FROM book_copies WHERE isbn = :ibn'
         USING isbn_in;
      RETURN refcur;
   END;

END book;
/

SHOW ERRORS

