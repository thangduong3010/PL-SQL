REM $Id: build.sql,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Build, in dependency order, any database objects used in this chapter

ACCEPT username -
   CHAR PROMPT 'Your regular Oracle username (for loadpsp command): '
ACCEPT password CHAR PROMPT 'Your Oracle password: ' HIDE

PROMPT Creating books and book_copies tables (from ch03)...
@@../ch03/books.tab
@@../ch03/book_copies.tab

PROMPT Creating book_barcodes_t collection type...
@@book_barcodes_t.typ

PROMPT Creating bookstatus function...
@@bookstatus.fun

PROMPT Creating available_copies function..
@@available_copies.fun

PROMPT Creating demo package containing an index-by collection type...
@@loptypes.pkg

PROMPT Creating exc package (from ch05) and new lopu package...
@@../ch05/exc.pks
@@lopu.pks
@@../ch05/exc.pkb
@@lopu.pkb

PROMPT Creating messages table...
@@messages.tab

PROMPT Creating Tom Kyte's who_called_me and who_am_i programs...
@@tkyte_who.sql

PROMPT Creating logerror procedure...
@@logerror.pro

PROMPT Creating lib_users table (from ch07)...
@@../ch07/lib_users.tab

PROMPT Creating lib_privileges table...
@@lib_privileges.tab

PROMPT Populating lib_priveleges table with reference data...
@@populate_lib_privileges.sql

PROMPT Creating lib_user_privileges table...
@@lib_user_privileges.tab

PROMPT Creating demouser/swordfish library account, granting all privileges...
@@create_demouser_account.sql

PROMPT Creating priv package...
@@priv.pks
@@priv.pkb

PROMPT Creating libuser_seq sequences...
@@libuser_seq.seq

PROMPT Creating libuser package...
@@libuser.pks
@@libuser.pkb

PROMPT Creating web_sessions table...
@@web_sessions.tab

PROMPT Creating privweb package...
@@privweb.pks
@@privweb.pkb

PROMPT Creating webu package...
@@webu.pks
@@webu.pkb

PROMPT Creating book package...
@@book.pks
@@book.pkb

PROMPT Running loadpsp to convert booksearch.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password booksearch.psp

PROMPT Creating loginweb package...
@@loginweb.pks
@@loginweb.pkb

PROMPT Running loadpsp to convert login.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password login.psp

PROMPT Creating bookweb package...
@@bookweb.pks
@@bookweb.pkb

PROMPT Running loadpsp to convert bookform.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password bookform.psp

PROMPT Creating lib_patron_t object type...
@@lib_patron_t.tys
@@lib_patron_t.tyb

PROMPT Creating lib_borrower_t object type (subtype of lib_patron_t)
@@lib_borrower_t.tys
@@lib_borrower_t.tyb

PROMPT Creating active_patrons_t collection...
@@active_patrons_t.typ

PROMPT Creating user_book_copy_events table (from ch08)...
@@../ch08/user_book_copy_events.tab

PROMPT Creating active_patrons pipelined table function...
@@active_patrons.fun

