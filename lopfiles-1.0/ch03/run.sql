REM $Id: run.sql,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3

REM Call all of the scripts in this chapter that don't actually build things.
REM This is not a terribly useful thing to do, and this script is mostly here
REM just to help me make sure everything will execute without error.

REM Note: Execute "build.sql" before callling this script.

@@add_one.sql
@@call_book_copy_qty.sql
@@insert_one.sql
@@reporteqbool.p101.pro
@@test_add_book.sql
@@test_book.sql
@@test_book_copy_qty.sql

