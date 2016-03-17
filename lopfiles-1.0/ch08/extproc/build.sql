REM $Id: build.sql,v 1.1 2001/11/30 23:26:32 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 8

REM Solaris-specific build script for demonstration external procedure

PROMPT This should work on Solaris.  If you're on some other OS, you will need
PROMPT to verify the C program, compile it into a shared object file (or DLL),
PROMPT and possibly copy it to the proper location.  To quit now, press Ctrl-C.

ACCEPT path -
   PROMPT 'Full path to pllp.so file (for example, /usr/local/lib/pllp.so): '
CREATE LIBRARY lplib AS '&&path';
/

PROMPT If that failed, it is probably because you lack CREATE LIBRARY
PROMPT privilege, and you need to execute grant_privs.sql as SYSTEM or other
PROMPT DBA and re-run the CREATE LIBRARY statement.

PROMPT Attempting to create the shared object file...
HOST make 
HOST cp pllp.so &&path

PROMPT Creating PL/SQL cover function "lp" that will call the external
PROMPT procedure...
@@lp.fun

