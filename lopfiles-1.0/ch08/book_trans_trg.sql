REM $Id$
REM From "Learning Oracle PL/SQL" page 274

REM Trigger to send mail to library patron when a copy of a book they have
REM reserved has been returned to the library

CREATE OR REPLACE TRIGGER book_trans_trg
   AFTER INSERT
   ON user_book_copy_events
   FOR EACH ROW
DECLARE
   CURSOR ucur
   IS
      SELECT ubr.borrower_id, ubr.date_queued,
             b.title, lu.email_address, lu.username
        FROM book_copies bc,
             books b,
             user_book_reservations ubr,
             lib_users lu
       WHERE bc.isbn = ubr.isbn
         AND bc.barcode_id = :NEW.barcode_id
         AND ubr.date_notified IS NULL         
         AND lu.id = ubr.borrower_id
         AND b.isbn = bc.isbn
       ORDER BY date_queued
         FOR UPDATE OF ubr.date_notified;

   urec ucur%ROWTYPE;

BEGIN
   IF :NEW.event_name = 'checkin'
   THEN
      OPEN ucur;
      FETCH ucur INTO urec;
      IF ucur%FOUND
      THEN
         lopu.send_mail(sender_email => 'oracle@mydomain.com',
                  recipient_email => urec.email_address,
                  subject => 'Your reserved book is available',
                  message => 'The library is holding a copy of '
                              || urec.title || ' for you.',
                  recipient_name => urec.username);
         UPDATE user_book_reservations
            SET date_notified = SYSDATE
          WHERE CURRENT OF ucur;
      END IF;
      CLOSE ucur;
   END IF;
END;
/

SHOW ERRORS

