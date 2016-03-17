REM $Id: build.sql,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 5

REM Build, in dependency order, any database objects used in this chapter

ACCEPT username -
   CHAR PROMPT 'Your regular Oracle username (for loadpsp command): '
ACCEPT password CHAR PROMPT 'Your Oracle password: ' HIDE

PROMPT Creating books and book_copies tables (from ch03)...
@@../ch03/books.tab
@@../ch03/book_copies.tab

PROMPT Adding sample data to books and book_copies tables...
@@insert_books.sql

PROMPT Running loadpsp to convert q.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password q.psp

PROMPT Running loadpsp to convert qtab.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password qtab.psp

PROMPT Creating "exc" package header only...
@@exc.pks

PROMPT Creating lopu package header only...
@@lopu.pks

PROMPT Creating "exc" package body...
@@exc.pkb

PROMPT Creating lopu package body...
@@lopu.pkb

PROMPT Creating procedure bookquerydemo...
@@bookquerydemo.pro

PROMPT Creating book package...
@@book.pks
@@book.pkb

PROMPT Creating webu package (from ch04)...
@@../ch04/webu.pks
@@../ch04/webu.pkb

PROMPT Running loadpsp to convert booksearch.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password booksearch.psp

