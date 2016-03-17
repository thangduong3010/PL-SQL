REM $Id: droptable.sql,v 1.1 2001/11/30 23:10:54 bill Exp $
REM From "Learning Oracle PL/SQL" page 213

REM Generate and execute a script that will drop a table supplied as a
REM command-line argument (see also droptable_enhanced.sql)

REM This version adds SET VERIFY OFF so that SQL*Plus won't do its
REM usual echo of the replacement of the ampersand variables

SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SELECT 'DROP TABLE ' || table_name || ';'
  FROM user_tables
 WHERE table_name LIKE UPPER ('&1%');

SPOOL drop.cmd
/
SPOOL OFF
@drop.cmd

REM let's go ahead and restore things the way we think they were before...
SET FEEDBACK 5
SET VERIFY ON
SET PAGESIZE 60

