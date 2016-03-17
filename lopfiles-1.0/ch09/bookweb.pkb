REM $Id: bookweb.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Body of ch09's version bookweb package which adds security features
REM to the version in ch04

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
      substr_only IN BOOLEAN DEFAULT FALSE,
      id_only BOOLEAN DEFAULT FALSE)
      RETURN flatbook_t
   IS
      fb flatbook_t;
   BEGIN

      fb.isbn := SUBSTR(isbn, 1, 13);

      IF NOT id_only
      THEN
         fb.author := SUBSTR(author, 1, 200);
         fb.title := SUBSTR(title, 1, 200); 
         fb.summary := SUBSTR(summary, 1, 2000); 
         fb.page_count_str := SUBSTR(page_count_str, 1, 40);
         fb.yyyy_published := SUBSTR(yyyy_published, 1, 4);
         fb.mon_published := SUBSTR(mon_published, 1, 3);
         fb.dd_published := SUBSTR(dd_published, 1, 2);
      END IF;

      IF substr_only
      THEN
         RETURN fb;
      END IF;

      fb.passes := lopu.sqltrue;

      IF NOT lopu.str_fits(isbn,10,13)
      THEN
         fb.isbn_msg := 'Must be between 10 and 13 characters';
         fb.passes := lopu.sqlfalse;
      END IF;

      IF id_only
      THEN
         RETURN fb;
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

      RETURN fb;

   END verify;


   FUNCTION one_flatbook(isbn_in IN VARCHAR2)
      RETURN flatbook_t
   IS
      fb flatbook_t;
      fb_holder flatbook_t;
      CURSOR bc IS
         SELECT isbn, title, author, page_count, TO_CHAR(page_count),
                summary, date_published,
                TO_CHAR(date_published, 'YYYY'),
                TO_CHAR(date_published, 'MON'),
                TO_CHAR(date_published, 'DD'),
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, lopu.sqltrue
           FROM books
          WHERE isbn = isbn_in;
   BEGIN
      fb_holder := verify(isbn_in, id_only => TRUE);
      IF fb_holder.passes = lopu.sqltrue
      THEN
         OPEN bc;
         FETCH bc INTO fb;
         IF bc%NOTFOUND
         THEN
            fb := fb_holder;
            fb.action_msg := 'New book.';
         END IF;
         CLOSE bc;
      ELSE
         fb := fb_holder;
      END IF;
      RETURN fb;
   END one_flatbook;

   FUNCTION process_edits (
      session_id IN VARCHAR2,
      skip IN VARCHAR2,
      submit IN VARCHAR2,
      isbn IN VARCHAR2, 
      title IN VARCHAR2,
      author IN VARCHAR2,
      page_count IN VARCHAR2,
      summary IN VARCHAR2,
      yyyy_published IN VARCHAR2,
      mon_published IN VARCHAR2,
      dd_published IN VARCHAR2,
      new_barcodes_arr IN OWA_UTIL.IDENT_ARR,
      delete_copies_arr IN OWA_UTIL.IDENT_ARR
      )
      RETURN flatbook_t
   IS
      fb flatbook_t;
   BEGIN
      lopu.set_dflt_date_format('YYYYMONDD');

      IF skip IS NOT NULL
      THEN
         fb := verify(isbn, title, author, page_count, summary,
                      yyyy_published, mon_published, dd_published,
                      substr_only => TRUE);

      ELSIF (submit IS NULL OR submit = webu.edit_c)
      THEN
         IF isbn IS NOT NULL
         THEN
            fb := one_flatbook(isbn_in => isbn);
         END IF;

      ELSIF submit = webu.save_c
      THEN
         -- privweb.assert_allowed(session_id, priv.edit_book_c);
         
         fb := verify(isbn, title, author, page_count, summary,
                      yyyy_published, mon_published, dd_published);

         IF fb.passes = lopu.sqltrue
         THEN
            BEGIN
               book.change(isbn_in => fb.isbn, new_title => fb.title,
                 new_author => fb.author, new_page_count => fb.page_count,
                 new_summary => fb.summary,
                 new_date_published => fb.date_published,
                 requestor_id => privweb.user_id(session_id));
                 fb.action_msg := 'Saved changes to ' || fb.isbn || '.';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  book.add(isbn_in => fb.isbn, title_in => fb.title,
                    author_in => fb.author, page_count_in => fb.page_count,
                    summary_in => fb.summary,
                    date_published_in => fb.date_published,
                    requestor_id => privweb.user_id(session_id));
                    fb.action_msg := 'Added ' || fb.isbn || ' to database.';
            END;

            BEGIN
               IF new_barcodes_arr.FIRST IS NOT NULL
               THEN
                  -- privweb.assert_allowed(session_id, priv.edit_book_copy_c);
                  FOR i IN new_barcodes_arr.FIRST .. new_barcodes_arr.LAST
                  LOOP
                     IF new_barcodes_arr(i) IS NOT NULL
                     THEN
                        book.add_copy(isbn, new_barcodes_arr(i),
                           requestor_id => privweb.user_id(session_id));
                     END IF;
                  END LOOP;
               END IF;

               IF delete_copies_arr.FIRST IS NOT NULL
               THEN
                  -- privweb.assert_allowed(session_id, priv.delete_book_copy_c);
                  FOR i IN delete_copies_arr.FIRST .. delete_copies_arr.LAST
                  LOOP
                     IF delete_copies_arr(i) IS NOT NULL
                     THEN
                        book.remove_copy(isbn, delete_copies_arr(i),
                           requestor_id => privweb.user_id(session_id));
                     END IF;
                  END LOOP;
               END IF;
            EXCEPTION
            WHEN OTHERS
               THEN 
                  fb.passes := lopu.sqlfalse;
                  fb.action_msg := 'Did not save changes.';
            END;

         ELSE
            fb.action_msg := 'Did not save changes.';
         END IF;

      ELSIF submit = webu.delete_c
      THEN
         -- privweb.assert_allowed(session_id, priv.weed_book_c);
         fb := verify(isbn, id_only => TRUE);

         IF fb.passes = lopu.sqltrue
         THEN
            BEGIN
               book.weed(isbn_in => isbn,
                  requestor_id => privweb.user_id(session_id));
               fb := NULL;
               fb.action_msg := 'Deleted ' || isbn || '.';
               fb.passes := lopu.sqltrue;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  fb.action_msg := isbn || ' not found.';
                  fb.passes := lopu.sqlfalse;
            END;
         ELSE
            fb.action_msg := 'Did not delete ' || isbn;
         END IF;

      ELSIF submit = webu.new_search_c
      THEN
         HTP.INIT;
         OWA_UTIL.REDIRECT_URL('booksearch?session_id_=' || session_id);

      ELSE
         fb := NULL;
         fb.action_msg := 'Unknown action requested: ' || submit;
      END IF;

      RETURN fb;

    END process_edits;

END bookweb;
/

SHOW ERRORS

