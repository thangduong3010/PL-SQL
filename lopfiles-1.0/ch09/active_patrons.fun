REM $Id: active_patrons.fun,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 357

REM Illustration of a "pipelined table function" that returns "piped rows"
REM from which you can SELECT (see companion file, pipeline_demo.sql)

CREATE OR REPLACE FUNCTION active_patrons (begin_date DATE DEFAULT SYSDATE - 14)
   RETURN active_patrons_t
   PIPELINED
AS
BEGIN
   FOR pat IN 
       (SELECT id FROM lib_users u, user_book_copy_events e
         WHERE u.id = e.borrower_id
           AND timestamp > begin_date)
   LOOP
      PIPE ROW (pat.id);
   END LOOP;
   RETURN;
END;
/

SHOW ERRORS

