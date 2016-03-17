REM $Id: drop.sql,v 1.1 2001/11/30 23:22:18 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 7

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping lib_users table...
DROP TABLE lib_users;

PROMPT Dropping book_hist_trg trigger...
DROP TRIGGER book_hist_trg;

PROMPT Dropping exc and lopu packages...
DROP PACKAGE exc;
DROP PACKAGE lopu;

PROMPT Dropping books_hist table...
DROP TABLE books_hist;

PROMPT Dropping book_copies table...
DROP TABLE book_copies;

PROMPT Dropping books table...
DROP TABLE books;

