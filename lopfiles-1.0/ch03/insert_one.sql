reM $Id: insert_one.sql,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 64

REM Illustrates a hard-coded INSERT statement, with extra discussion
REM of line breaks inside strings

COLUMN AUTHOR FORMAT A70

REM Let's delete the book to prevent any errors from attempting to insert
REM a duplicate.  Turn FEEDBACK OFF to avoid confusing error messages if
REM the book is not there.
SET FEEDBACK OFF
DELETE books WHERE isbn = '0-596-00180-0';
SET FEEDBACK 5
SET ECHO ON

/* Note: The first printing of this book was written with the following
formatting of this INSERT statement:
*/

INSERT INTO books (isbn, title, author)
VALUES ('0-596-00180-0', 'Learning Oracle PL/SQL', 'Bill Pribyl with
Steven Feuerstein');

/* Notice the line break between "with" and "Steven".  It is legal
within SQL*Plus to split a string across lines, but let's see what
got stored in the author column.
*/

SELECT author FROM books WHERE isbn = '0-596-00180-0';

/* Notice that the line break is actually stored in the database.  This
is not what I intended.  To correct this, let's first remove this
record with a DELETE statement:
*/

DELETE books WHERE isbn = '0-596-00180-0';

/* ...and re-execute the statement as follows: */

INSERT INTO books (isbn, title, author)
VALUES ('0-596-00180-0', 'Learning Oracle PL/SQL',
   'Bill Pribyl with Steven Feuerstein');

/* Now examine the data: */

SELECT author FROM books WHERE isbn = '0-596-00180-0';

/* That's better! */

SET ECHO OFF
