REM $Id: build.sql,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 2

REM Builds, in dependency order, any database objects used in this chapter

PROMPT Creating books table...
@@books.tab

PROMPT Creating book_copies table...
@@book_copies.tab

PROMPT Creating add_book procedure...
@@add_book.pro

PROMPT Creating book_copy_qty function...
@@book_copy_qty.fun

PROMPT Creating reporteq procedure...
@@reporteq.pro

PROMPT Creating booleantochar function...
@@booleantochar.fun

PROMPT Creating reporteqbool procedure...
@@reporteqbool.p102.pro

PROMPT Creating add_book_copy procedure...
@@add_book_copy.pro

PROMPT Creating book package...
@@book.pks
@@book.pkb

PROMPT Creating test_book package...
@@test_book.pks
@@test_book.pkb

PROMPT Creating tut package...
@@tut.pks
@@tut.pkb

