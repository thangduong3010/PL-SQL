REM $Id: drop.sql,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 5

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping procedure booksearch;...
DROP PROCEDURE booksearch;

PROMPT Dropping package webu...
DROP PACKAGE webu;

PROMPT Dropping package book...
DROP PACKAGE book;

PROMPT Dropping package exc...
DROP PACKAGE exc;

PROMPT Dropping procedure bookquerydemo...
DROP PROCEDURE bookquerydemo;

PROMPT Dropping package lopu...
DROP PACKAGE lopu;

PROMPT Dropping procedure qtab...
DROP PROCEDURE qtab;

PROMPT Dropping procedure q...
DROP PROCEDURE q;

PROMPT Dropping table book_copies...
DROP TABLE book_copies;

PROMPT Dropping table books...
DROP TABLE books;

