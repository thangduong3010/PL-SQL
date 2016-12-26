Rem  Copyright (c) 1995, 2004, Oracle.  All Rights Reserved.
Rem
Rem   NAME
Rem     owadsyn.sql - OWA Drop public SYNonyms
Rem   PURPOSE
Rem     Drop the public OWA synonyms used by the PL/SQL
Rem     gateway.
Rem   NOTES
Rem     This script should be run as sys.
Rem   history
Rem     pkapasi    09/07/00 -  Ignore drop errors for SQL*Plus and svrmgrl
Rem     rdecker    07/21/00 -  split off from owacomm.sql
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
  execute_ddl ('drop public synonym OWA_CUSTOM');
  execute_ddl ('drop public synonym OWA_GLOBAL');
  execute_ddl ('drop public synonym OWA');
  execute_ddl ('drop public synonym HTF');
  execute_ddl ('drop public synonym HTP');
  execute_ddl ('drop public synonym OWA_COOKIE');
  execute_ddl ('drop public synonym OWA_IMAGE');
  execute_ddl ('drop public synonym OWA_OPT_LOCK');
  execute_ddl ('drop public synonym OWA_PATTERN');
  execute_ddl ('drop public synonym OWA_SEC');
  execute_ddl ('drop public synonym OWA_TEXT');
  execute_ddl ('drop public synonym OWA_UTIL');
  execute_ddl ('drop public synonym OWA_INIT');
  execute_ddl ('drop public synonym OWA_CACHE');
  execute_ddl ('drop public synonym OWA_MATCH');
  execute_ddl ('drop public synonym WPG_DOCLOAD');
END;
/


