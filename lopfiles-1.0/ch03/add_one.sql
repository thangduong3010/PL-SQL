REM $Id: add_one.sql,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" page 74

REM Call add_book procedure with literal values

REM Note: First delete this book so this script won't result in an error

SET FEEDBACK OFF
DELETE book_copies WHERE isbn = '1-56592-335-9';
DELETE books WHERE isbn = '1-56592-335-9';
SET FEEDBACK ON

BEGIN
   add_book('1-56592-335-9',
      '100000001',
      'Oracle PL/SQL Programming',
     'Feuerstein, Steven, with Bill Pribyl',
      987,
      'Reference for PL/SQL developers, '
         || 'including examples and best practice recommendations.',
      TO_DATE('01-SEP-1997','DD-MON-YYYY'));
END;
/

