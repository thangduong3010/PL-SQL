REM $Id: build.sql,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Build, in dependency order, any database objects used in this chapter

ACCEPT username -
   CHAR PROMPT 'Your regular Oracle username (for loadpsp command): '
ACCEPT password CHAR PROMPT 'Your Oracle password: ' HIDE

PROMPT Running loadpsp to convert show_time.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password show_time.psp

PROMPT Creating books and book_copies tables (from ch03)...
@@books.tab
@@book_copies.tab

PROMPT Creating book package (from ch03)...
@@book.pks
@@book.pkb

PROMPT Running loadpsp to convert eat_add_book_form.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password eat_add_book_form.psp

PROMPT Running loadpsp to convert add_book_form.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password add_book_form.psp

PROMPT Running loadpsp to convert friendly_errorpage.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password friendly_errorpage.psp

PROMPT Creating lopu package...
@@lopu.pks
@@lopu.pkb

PROMPT Creating webu package...
@@webu.pks
@@webu.pkb

PROMPT Creating bookweb package...
@@bookweb.pks
@@bookweb.pkb

PROMPT Running loadpsp to convert bookform.psp to PL/SQL procedure...
HOST loadpsp -replace -user &&username/&&password bookform.psp

