REM $Id: drop.sql,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping everything...

DROP FUNCTION active_patrons;
DROP TYPE active_patrons_t;
DROP TABLE user_book_copy_events;
DROP TYPE lib_borrower_t;
DROP TYPE lib_patron_t;
DROP PROCEDURE bookform;
DROP PACKAGE bookweb;
DROP PROCEDURE login;
DROP PACKAGE loginweb;
DROP PROCEDURE booksearch;
DROP PACKAGE book;
DROP PACKAGE webu;
DROP PACKAGE privweb;
DROP TABLE web_sessions;
DROP PACKAGE libuser;
DROP SEQUENCE libuser_seq;
DROP PACKAGE priv;
DROP TABLE lib_user_privileges;
DROP TABLE lib_privileges;
DROP TABLE lib_users;
DROP PROCEDURE logerror;
DROP FUNCTION who_am_i;
DROP PROCEDURE who_called_me;
DROP TABLE messages;
DROP PACKAGE lopu;
DROP PACKAGE exc;
DROP PACKAGE loptypes;
DROP FUNCTION available_copies;
DROP FUNCTION bookstatus;
DROP TYPE book_barcodes_t;
DROP TABLE book_copies;
DROP TABLE books;

