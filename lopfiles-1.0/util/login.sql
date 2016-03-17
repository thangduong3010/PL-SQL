REM $Id: login.sql,v 1.1 2001/11/30 23:42:03 bill Exp $
REM From "Learning Oracle PL/SQL" page 25

REM login.sql is a "special" file that sqlplus will executes automatically when 
REM you start Oracle sqlplus in the same directory.

REM The idea is to set some common variables and initialize things so they are
REM more "sensible" than Oracle's out-of-the-box defaults.  The DBA can also
REM edit the glogin.sql file in the $ORACLE_HOME/sqlplus/admin directory for
REM system-wide settings.

REM To eliminate the prompts on startup, delete or comment-out the PROMPT lines.

SET ECHO OFF
PROMPT +---------------- Custom settings ------------------+
PROMPT | PAGESIZE 60 (max num. of lines per page)
SET PAGESIZE 60

PROMPT | LINESIZE 80 (max num. of characters per line)
SET LINESIZE 80

PROMPT | SERVEROUTPUT ON SIZE 1000000
SET SERVEROUTPUT ON SIZE 1000000

PROMPT | _EDITOR = vi (default used with "edit" command)
DEFINE _EDITOR = vi

PROMPT | (Edit the file "login.sql" to modify settings.)
PROMPT +---------------------------------------------------+

-----------------------------------------------------------------
REM misc columns commonly retrieved from data dictionary
COLUMN name FORMAT A30 WORD_WRAP
COLUMN segment_name FORMAT A30 WORD_WRAP
COLUMN object_name FORMAT A30 WORD_WRAP

-----------------------------------------------------------------
REM Workaround for initial OWA call failure bug (as provided by 
REM Oracle Corp. developers).  I set FEEDBACK OFF to suppress the
REM "PL/SQL procedure successfully complete" message.

SET FEEDBACK OFF
DECLARE
   name_arr OWA.VC_ARR;
   value_arr OWA.VC_ARR;
BEGIN
   OWA.INIT_CGI_ENV(0, NAME_ARR, VALUE_ARR);
END;
/

REM Restore the default FEEDBACK setting
SET FEEDBACK 5

