REM $Id$
REM From "Learning Oracle PL/SQL" Chapter 8

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping webcatman...
DROP PACKAGE webcatman;

PROMPT Dropping book_trans_trg trigger...
DROP TRIGGER book_trans_trg;

PROMPT Dropping user_book_copy_events table...
DROP TABLE user_book_copy_events;

PROMPT Dropping user_book_reservations table...
DROP TABLE user_book_reservations;

PROMPT Dropping standalone version of send_mail procedure...
DROP PROCEDURE send_mail;

PROMPT Dropping load_file_to_holder procedure...
DROP PROCEDURE load_file_to_holder;

PROMPT Dropping file_holder table...
DROP TABLE file_holder;

PROMPT Dropping get_nextline utility procedure...
DROP PROCEDURE get_nextline;

PROMPT Dropping lopu and exc packages...
DROP PACKAGE lopu;
DROP PACKAGE exc;

DROP TABLE book_copies;
DROP TABLE books;

PROMPT Dropping lib_users table...
DROP TABLE lib_users;

