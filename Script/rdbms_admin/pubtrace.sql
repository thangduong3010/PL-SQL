Rem
Rem $Header: owajdcu.sql 05-oct-2001.10:52:25 rdecker Exp $
Rem
Rem pubtrace.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      pubtrace.sql - OWA Debug Trace
Rem
Rem    DESCRIPTION
Rem      This is the default and sample implementation of the 
Rem      owa debug PACKAGE used TO START AND stop sql tracing.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     11/13/01 - Remove tabs
Rem    rdecker     10/05/01 - Merged rdecker_owa_debug_jdwp
Rem    rdecker     09/13/01 - Created
Rem

CREATE OR REPLACE PACKAGE owa_debug_trace AUTHID CURRENT_USER IS

   procedure attach;
   procedure detach;

END owa_debug_trace;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY owa_debug_trace
IS
   PROCEDURE attach
   IS
      l_tmp varchar2(32000);
   BEGIN
      execute immediate 'alter session set timed_statistics=true';
      execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
      execute immediate 'select ''Procedure='
         || replace(owa_util.get_cgi_env('SCRIPT_NAME') ||
                    owa_util.get_cgi_env('PATH_INFO'), '''', '''''')
         || ''' from dual'
      into l_tmp;
   END;
   
   PROCEDURE detach
   IS
   BEGIN
      dbms_session.set_sql_trace(false);
   END;

END owa_debug_trace;
/
SHOW ERRORS PACKAGE BODY owa_debug_trace;

GRANT EXECUTE ON owa_debug_trace TO PUBLIC;

CREATE PUBLIC SYNONYM owa_debug_trace FOR owa_debug_trace;

