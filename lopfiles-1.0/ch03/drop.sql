REM $Id: drop.sql,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping tut package...
DROP PACKAGE tut;

PROMPT Dropping booleantochar function...
DROP FUNCTION booleantochar;

PROMPT Dropping test_book package...
DROP PACKAGE test_book;

PROMPT Dropping book package...
DROP PACKAGE book;

PROMPT Dropping add_book_copy procedure...
DROP PROCEDURE add_book_copy;

PROMPT Dropping reporteqbool procedure...
DROP PROCEDURE reporteqbool;

PROMPT Dropping reporteq procedure...
DROP PROCEDURE reporteq;

PROMPT Dropping book_copy_qty function...
DROP FUNCTION book_copy_qty;

PROMPT Dropping add_book procedure...
DROP PROCEDURE add_book;

PROMPT Dropping book_copies table...
DROP TABLE book_copies;

PROMPT Dropping books table...
DROP TABLE books;

