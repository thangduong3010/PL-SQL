REM $Id$
REM From "Learning Oracle PL/SQL" Chapter 8

REM Build, in dependency order, any database objects used in this chapter

PROMPT Creating lib_users table (from ch07)...
@@../ch07/lib_users.tab

PROMPT Creating books and book_copies tables (from ch03)...
@@../ch03/books.tab
@@../ch03/book_copies.tab

PROMPT Creating user_book_copy_events table...
@@user_book_copy_events.tab

PROMPT Creating user_book_reservations table...
@@user_book_reservations.tab

PROMPT Creating exc (from ch05) and lopu packages...
@@lopu.pks
@@../ch05/exc.pks
@@lopu.pkb
@@../ch05/exc.pkb

PROMPT Creating standalone version of send_mail procedure...
@@send_mail.pro

PROMPT Creating trigger to send email to patron who has reserved book...
@@book_trans_trg.sql

PROMPT Utility program used when reading file with UTL_FILE...
@@get_nextline.pro

PROMPT Creating table that will hold file contents...
@@file_holder.tab

PROMPT Creating procedure to load contents of file into file_holder table...
@@load_file_to_holder.pro

PROMPT Creating package to fetch data from the Library of Congress web site...
@@webcatman.pks
@@webcatman.pkb

