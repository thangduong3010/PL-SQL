REM $Id: bookweb.pkb,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Final version of body of bookweb package implied by Chapter 4; contains the
REM support logic behind the user interface

CREATE OR REPLACE PACKAGE BODY bookweb
AS
   FUNCTION verify (isbn IN VARCHAR2,
      title IN VARCHAR2 DEFAULT NULL,
      author IN VARCHAR2 DEFAULT NULL,
      page_count_str IN VARCHAR2 DEFAULT NULL,
      summary IN VARCHAR2 DEFAULT NULL,
      yyyy_published IN VARCHAR2 DEFAULT NULL,
      mon_published IN VARCHAR2 DEFAULT NULL,
      dd_published IN VARCHAR2 DEFAULT NULL,
      barcode_id IN VARCHAR2 DEFAULT NULL)
   RETURN bookrec_t
   IS
      fb bookrec_t;
   BEGIN

      fb.isbn := SUBSTR(isbn, 1, 13);
      fb.author := SUBSTR(author, 1, 200);
      fb.title := SUBSTR(title, 1, 200);
      fb.summary := SUBSTR(summary, 1, 2000);
      fb.page_count_str := SUBSTR(page_count_str, 1, 40);
      fb.yyyy_published := SUBSTR(yyyy_published, 1, 4);
      fb.mon_published := SUBSTR(mon_published, 1, 3);
      fb.dd_published := SUBSTR(dd_published, 1, 2);
      fb.barcode_id := SUBSTR(barcode_id, 1, 40);

      fb.passes := lopu.sqltrue;

      IF NOT lopu.str_fits(isbn,10,13)
      THEN
         fb.isbn_msg := 'Must be between 10 and 13 characters';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF NOT lopu.str_fits(author,0,200)
      THEN
         fb.author := 'Must be fewer than 200 characters';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF NOT lopu.str_fits(title, 0, 200)
      THEN
         fb.title_msg := 'Must be fewer than 200 characters';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF NOT lopu.str_fits(summary, 0, 2000)
      THEN
         fb.summary_msg := 'Must be less than 2000 characters';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF lopu.is_number(page_count_str)
      THEN
         fb.page_count := TO_NUMBER(page_count_str);
         fb.page_count_str := TO_CHAR(fb.page_count);
      ELSE
         fb.page_count_msg := 'Must be a number';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF lopu.is_date(yyyy_published || mon_published || dd_published)
      THEN
         fb.date_published := TO_DATE(
            yyyy_published || mon_published || dd_published,
            lopu.dflt_date_format);
         fb.yyyy_published := TO_CHAR(fb.date_published, 'YYYY');
         fb.mon_published := TO_CHAR(fb.date_published, 'MON');
         fb.dd_published := TO_CHAR(fb.date_published, 'DD');
      ELSE
         fb.date_published_msg := 'Must be a valid date';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF NOT lopu.str_fits(barcode_id, 0, 10)
      THEN
         fb.barcode_id_msg := 'Must be shorter than 11 characters';
      END IF;

      RETURN fb;

   END verify;


   FUNCTION process_edits (
      submit IN VARCHAR2,
      isbn IN VARCHAR2,
      title IN VARCHAR2,
      author IN VARCHAR2,
      page_count IN VARCHAR2,
      summary IN VARCHAR2,
      yyyy_published IN VARCHAR2,
      mon_published IN VARCHAR2,
      dd_published IN VARCHAR2,
      barcode_id IN VARCHAR2
      )
   RETURN bookrec_t
   IS
      fb bookrec_t;
   BEGIN
      lopu.set_dflt_date_format('YYYYMONDD');

      IF submit IS NOT NULL
      THEN
         fb := verify(isbn, title, author, page_count, summary,
                      yyyy_published, mon_published, dd_published,
                      barcode_id);

         IF fb.passes = lopu.sqltrue
         THEN
            BEGIN
               book.add(isbn_in => fb.isbn, barcode_id_in => barcode_id,
                    title_in => fb.title, author_in => fb.author,
                    page_count_in => fb.page_count, summary_in => fb.summary,
                    date_published_in => fb.date_published);

               fb.action_msg := 'Added ' || fb.isbn || ' to database.';

            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  fb.passes := lopu.sqlfalse;
                  fb.action_msg := 'Error: Book ' || fb.isbn
                     || ' already exists.';

               WHEN OTHERS
               THEN
                  fb.passes := lopu.sqlfalse;
                  fb.action_msg := 'Attempt to add ' || fb.isbn
                     || ' to database' || ' failed with ' || SQLERRM;
            END;
         ELSE
            fb.action_msg := 'Did not save changes.';
         END IF;

      END IF;

      RETURN fb;

    END process_edits;

END bookweb;
/
SHOW ERRORS

