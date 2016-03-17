REM $Id: test_book.pks,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 98

REM Package specification of unit tester for the "book" package

CREATE OR REPLACE PACKAGE test_book AS
   PROCEDURE run (verbose IN BOOLEAN DEFAULT TRUE);
   PROCEDURE add;
   PROCEDURE add_copy;
   PROCEDURE book_copy_qty;
   PROCEDURE change;
   PROCEDURE remove_copy;
   PROCEDURE weed;
END test_book;
/

SHOW ERRORS

