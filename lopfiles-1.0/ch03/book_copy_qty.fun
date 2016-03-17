REM $Id: book_copy_qty.fun,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 80

REM Create function to count number of copies of a particular book

CREATE OR REPLACE FUNCTION book_copy_qty(isbn_in IN VARCHAR2)
RETURN NUMBER
AS
   number_o_copies NUMBER := 0;
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
/

SHOW ERRORS

