REM $Id: test_book.sql,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 98

REM Call the book-testing package with default verbosity

BEGIN
   test_book.run;
   ROLLBACK;
END;
/

