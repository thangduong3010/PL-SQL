REM $Id: build.sql,v 1.1 2001/11/30 23:22:18 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 7

REM Build, in dependency order, any database objects used in this chapter

PROMPT Creating books and book_copies tables (from ch03)...
@@../ch03/books.tab
@@../ch03/book_copies.tab

PROMPT Creating books_hist table...
@@books_hist.tab

PROMPT Creating lopu and exc support packages from Chapter 5...
@@../ch05/lopu.pks
@@../ch05/exc.pks
@@../ch05/lopu.pkb
@@../ch05/exc.pkb

PROMPT Creating book_hist_trg trigger...
@@book_hist_trg.trg

PROMPT Creating lib_uses table...
@@lib_users.tab

