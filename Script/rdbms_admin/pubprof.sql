Rem
Rem $Header: pubprof.sql 05-oct-2001.10:52:25 rdecker Exp $
Rem
Rem pubprof.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      pubprof.sql - OWA Debug Profiler
Rem
Rem    DESCRIPTION
Rem      This is the default and sample implementation of the 
REM      PACKAGE which IS used TO START AND stop the plsql profiler.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     11/20/01 - Use dynamic SQL
Rem    pkapasi     11/13/01 - Remove tabs
Rem    rdecker     10/05/01 - Merged rdecker_owa_debug_jdwp
Rem    rdecker     09/13/01 - Created
Rem

CREATE OR REPLACE PACKAGE owa_debug_profiler AUTHID CURRENT_USER IS

   PROCEDURE attach(run_comment IN VARCHAR2);
   PROCEDURE detach(run_comment IN VARCHAR2);

END owa_debug_profiler;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY owa_debug_profiler
IS
   PROCEDURE attach(run_comment IN VARCHAR2)
   IS
      stmt_cursor INTEGER;
      rc          number;
   BEGIN
      stmt_cursor := dbms_sql.open_cursor;
      dbms_sql.parse (stmt_cursor, 
            'begin
              sys.dbms_profiler.start_profiler(run_comment1=>:run_comment);
             end;',
            dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':run_comment',run_comment);
      rc := dbms_sql.execute (stmt_cursor);
      dbms_sql.close_cursor (stmt_cursor);
   EXCEPTION
      when others then
          if dbms_sql.is_open(stmt_cursor) then
              dbms_sql.close_cursor(stmt_cursor);
          end if;
          raise;
   END;
   
   PROCEDURE detach(run_comment IN VARCHAR2)
   IS
      stmt_cursor INTEGER;
      rc          number;
   BEGIN
      stmt_cursor := dbms_sql.open_cursor;
      dbms_sql.parse (stmt_cursor, 
            'begin
              sys.dbms_profiler.stop_profiler;
             end;',
            dbms_sql.v7);
      rc := dbms_sql.execute (stmt_cursor);
      dbms_sql.close_cursor (stmt_cursor);
   EXCEPTION
      when others then
          if dbms_sql.is_open(stmt_cursor) then
              dbms_sql.close_cursor(stmt_cursor);
          end if;
          raise;
   END;

END owa_debug_profiler;
/
SHOW ERRORS PACKAGE BODY owa_debug_profiler;

GRANT EXECUTE ON owa_debug_profiler TO PUBLIC;

CREATE PUBLIC SYNONYM owa_debug_profiler FOR owa_debug_profiler;

