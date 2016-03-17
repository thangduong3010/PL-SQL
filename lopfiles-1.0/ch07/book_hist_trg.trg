REM $Id: book_hist_trg.trg,v 1.1 2001/11/30 23:22:18 bill Exp $
REM From "Learning Oracle PL/SQL" page 254

REM Create trigger to keep audit trail of changes to books table

CREATE OR REPLACE TRIGGER book_hist_trg
   AFTER INSERT OR UPDATE OR DELETE
   ON books
   FOR EACH ROW
DECLARE
   l_action CHAR(1);
BEGIN

   IF :NEW.isbn != :OLD.isbn
   THEN
      exc.myraise(exc.cannot_change_unique_id_cd);
   END IF;

   IF INSERTING
   THEN
      l_action := 'I';
   ELSIF UPDATING
   THEN
      l_action := 'U';
   ELSIF DELETING
   THEN
      l_action := 'D';
   END IF;

   INSERT INTO books_hist
      (isbn, action, datestamp, oracle_user, real_user,
       old_title, old_summary, old_author,
       old_date_published, old_page_count,
       new_title, new_summary, new_author,
       new_date_published, new_page_count)
   VALUES 
      (:NEW.isbn, l_action, SYSDATE, USER, NULL,
       :OLD.title, :OLD.summary, :OLD.author,
       :OLD.date_published, :OLD.page_count,
       :NEW.title, :NEW.summary, :NEW.author,
       :NEW.date_published, :NEW.page_count);
END;
/

SHOW ERRORS

