Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corp.  All Rights Reserved.
Rem
Rem   NAME
Rem     owaload7.sql - PL/SQL Gateway package installation (For 7.x DB)
Rem   PURPOSE
Rem     Install the PL/SQL packages needed to run the PL/SQL
Rem     gateway.
Rem   NOTES
Rem     This driver script installs the PL/SQL gateway toolkit 
Rem     packages (such as HTP/HTP/OWA_UTIL, WPG_DOCLOAD etc.)
Rem     as well as other internal packages needed by the 
Rem     PL/SQL gateway.
Rem   HISTORY
Rem     pkapasi    10/12/00 -  owaload.sql modified to work with 7.x databases
Rem

whenever oserror exit 32767
set define on
spool &&1

Rem
Rem Create the wpiutl describe package in SYS.
Rem
DECLARE
  -- procedure executes a DDL and ignores errors if any.
  PROCEDURE execute_ddl(ddl_statement VARCHAR2) IS
    ddl_cursor INTEGER;
  BEGIN
    -- try to execute DDL
    ddl_cursor := dbms_sql.open_cursor;

    -- issue the DDL statement
    dbms_sql.parse (ddl_cursor, ddl_statement, dbms_sql.native);
    dbms_sql.close_cursor (ddl_cursor);
  EXCEPTION
    -- ignore exceptions
    when others then
      if (dbms_sql.is_open(ddl_cursor)) then
        dbms_sql.close_cursor(ddl_cursor);
      end if;
  END;

BEGIN
  execute_ddl ('drop package sys.wpiutl');
END;
/


@@wpiutl7.sql

set define off
  
Rem call owacomm.sql TO load ALL OF the common owa/gateway packages  
@@owacomm7.sql
  
spool off

exit

