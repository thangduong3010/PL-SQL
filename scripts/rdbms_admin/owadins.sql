Rem  Copyright (c) 1995, 2004, Oracle.  All Rights Reserved.
Rem
Rem   NAME
Rem     owadins.sql - Oracle Web Agent De-INStall
Rem   PURPOSE
Rem     Drop PL/SQL packages installed with the PL/SQL Gateway.
Rem
Rem   NOTES
Rem
Rem     This script should be run by the owner of the OWA packages.
Rem   history
Rem     pkapasi    06/17/01 -  Add support for EBCDIC databases(bug#1778693)
Rem     pkapasi    09/07/00 -  Ignore drop errors for SQL*Plus and svrmgrl
Rem     rdecker    07/21/00 -  UPDATE PACKAGE list  
Rem     kmuthukk   04/19/00 -  Added drop of wpg_docload.
Rem     rpang      07/09/96 -  Add drop of sec
Rem 	mpal	   06/28/96 -  Add drop of owa_opt_lock package
Rem     mbookman   03/04/96 -  Add drop of init, text, pattern, cookie
Rem     mbookman   08/01/95 -  Creation
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
  execute_ddl ('drop package owa_cookie');
  execute_ddl ('drop package owa_image');
  execute_ddl ('drop package owa_pattern');
  execute_ddl ('drop package owa_text');
  execute_ddl ('drop package owa_util');
  execute_ddl ('drop package owa');
  execute_ddl ('drop package htp');
  execute_ddl ('drop package htf');
  execute_ddl ('drop package owa_custom');
  execute_ddl ('drop package owa_sec');
  execute_ddl ('drop package owa_opt_lock');
  execute_ddl ('drop package owa_cache');
  execute_ddl ('drop package owa_cx');
  execute_ddl ('drop package owa_match');
  execute_ddl ('drop package wpg_docload');
END;
/


Rem Drop the owa public synonyms
@@owadsyn
