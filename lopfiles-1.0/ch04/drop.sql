REM $Id: drop.sql,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping eat_add_book_form PSP procedure...
DROP PROCEDURE eat_add_book_form;

PROMPT Dropping bookform PSP procedure...
DROP PROCEDURE bookform;

PROMPT Dropping package bookweb...
DROP PACKAGE bookweb;

PROMPT Dropping package book...
DROP PACKAGE book;

PROMPT Dropping table book_copies...
DROP TABLE book_copies;

PROMPT Dropping table books...
DROP TABLE books;

PROMPT Dropping package weub...
DROP PACKAGE webu;

PROMPT Dropping lopu package...
DROP PACKAGE lopu;

PROMPT Dropping various procedures created via PL/SQL Server Pages
PROMPT ...friendly_errorage
DROP PROCEDURE friendly_errorpage;
PROMPT ...add_book_form
DROP PROCEDURE add_book_form;
PROMPT ...show_time
DROP PROCEDURE show_time;

