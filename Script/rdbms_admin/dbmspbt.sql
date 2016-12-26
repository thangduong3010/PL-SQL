Rem
Rem $Header: plsql/admin/dbmspbt.sql /main/7 2009/01/15 13:45:55 traney Exp $
Rem
Rem dbmspbt.sql
Rem
Rem Copyright (c) 1998, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmspbt.sql - package specification for PL/SQL tracing
Rem
Rem    DESCRIPTION
Rem      This package provides routines for setting/clearing PL/SQL tracing
Rem      for the session.
Rem
Rem    NOTES
Rem      The collected trace data is dumped to the tables in the system
Rem      schema. This package must be created under SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      01/08/09 - add authid definer
Rem    jmuller     03/14/06 - Fix bug 5066528: several tracing enhancements 
Rem    jmuller     04/09/04 - Fix bug 708690: TAB -> blank 
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    astocks     09/08/99 - Add more constants
Rem    ciyer       03/28/98 - API to set/clear PL/SQL tracing
Rem    ciyer       03/28/98 - Created
Rem

REM ********************************************************************
REM THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
REM ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
REM CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST BE CREATED UNDER SYS.
REM ********************************************************************

REM ********************************************************************
REM THE TABLES USED BY THIS PACKAGE ARE DEFINED IN 
REM     $ORACLE_HOME/rdbms/admin/tracetab.sql
REM ********************************************************************

create or replace package sys.dbms_trace authid definer is
  ------------
  --  OVERVIEW
  --
  --  This package provides routines to start and stop PL/SQL tracing
  --
  
  -------------
  --  CONSTANTS
  --

  -- Define constants to control which PL/SQL features are traced. For each
  -- feature, there are two constants:
  --    one to trace all occurences of the feature
  --    one to trace only those occurences in modules compiled debug
  -- To trace multiple features, simply add the constants.
  --
  trace_all_calls          constant integer := 1;  -- Trace calls/returns
  trace_enabled_calls      constant integer := 2;

  trace_all_exceptions     constant integer := 4;  -- trace exceptions
  trace_enabled_exceptions constant integer := 8;  -- (and handlers)

  trace_all_sql            constant integer := 32; -- trace SQL statements
  trace_enabled_sql        constant integer := 64; -- at PL/SQL level (does
                                                   -- not invoke SQL trace)

  trace_all_lines          constant integer := 128; -- trace each line
  trace_enabled_lines      constant integer := 256;

  -- There are also some constants to allow control of the trace package
  --
  trace_stop               constant integer := 16384;

  -- Pause/resume allow tracing to be paused and later resumed. 
  --
  trace_pause              constant integer := 4096; 
  trace_resume             constant integer := 8192;

  -- Save only the last few records. This allows tracing up to a problem
  -- area, without filling the database up with masses of irrelevant crud.
  -- If event 10940 is set, the limit is 1023*(the value of event 10940).
  -- This can be overridden by the routine limit_plsql_trace
  --
  trace_limit              constant integer := 16;
  
  -- [5066528] Don't trace such 'administrative' events as 'PL/SQL Trace Tool
  -- started', 'Trace flags changed', 'PL/SQL Virtual Machine started' and
  -- 'PL/SQL Virtual Machine stopped'. 
  --
  no_trace_administrative  constant integer := 32768;

  -- [5066528] Don't trace handled exceptions, only unhandled ones.
  no_trace_handled_exceptions constant integer := 65536;

  --
  -- version history:
  --   1.0 - creation
  --
  trace_major_version constant binary_integer := 1;
  trace_minor_version constant binary_integer := 0;
  
  -- CONSTANTS
  --
  -- The following constants are used in the "event_kind" column, to identify 
  -- the various records in the database. All references to them should use
  -- the symbolic names
  --
  plsql_trace_start        constant integer := 38; -- Start tracing
  plsql_trace_stop         constant integer := 39; -- Finish tracing
  plsql_trace_set_flags    constant integer := 40; -- Change trace options
  plsql_trace_pause        constant integer := 41; -- Tracing paused
  plsql_trace_resume       constant integer := 42; -- Tracing resumed
  plsql_trace_enter_vm     constant integer := 43; -- New PL/SQL VM entered                                           /* Entering the VM */
  plsql_trace_exit_vm      constant integer := 44; -- PL/SQL VM  exited*
  plsql_trace_begin_call   constant integer := 45; -- Calling normal routine
  plsql_trace_elab_spec    constant integer := 46; -- Calling package spec                                     /* Calling package spec*/
  plsql_trace_elab_body    constant integer := 47; -- Calling package body
  plsql_trace_icd          constant integer := 48; -- Call to internal PL/SQL routine
  plsql_trace_rpc          constant integer := 49; -- Remote procedure call
  plsql_trace_end_call     constant integer := 50; -- Returning from a call               
  plsql_trace_new_line     constant integer := 51; -- Line number changed
  plsql_trace_excp_raised  constant integer := 52; -- Exception raised
  plsql_trace_excp_handled constant integer := 53; -- Exception handler
  plsql_trace_sql          constant integer := 54; -- SQL statement
  plsql_trace_bind         constant integer := 55; -- Bind parameters
  plsql_trace_user         constant integer := 56; -- User requested record
  plsql_trace_nodebug      constant integer := 57; -- Some events skipped 
                                                   -- because module compiled 
                                                   -- NODEBUG
  plsql_trace_excp_unhandled constant integer := 58; -- Exception unhandled at
                                                   -- top level

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  -- start trace data dumping in session
  -- the parameter is the sum of the above constants representing which
  -- events to trace
  procedure set_plsql_trace(trace_level in binary_integer);

  -- get the current trace level (again, a sum of the above constants).
  function get_plsql_trace_level return binary_integer;

  -- Return the run-number
  function get_plsql_trace_runnumber return binary_integer;
  
  -- stop trace data dumping in session
  procedure clear_plsql_trace;
  
  -- pause trace data dumping in session
  procedure pause_plsql_trace;

  -- pause trace data dumping in session
  procedure resume_plsql_trace;

  -- limit amount of trace data dumped
  -- the parameter is the approximate number of records to keep.
  -- (the most recent records are retained)
  procedure limit_plsql_trace(limit in binary_integer := 8192);

  -- Add user comment to trace table
  procedure comment_plsql_trace(comment in varchar2);

  -- This function verifies that this version of the dbms_trace package
  -- can work with the implementation in the database.
  --
  function internal_version_check return binary_integer;

  -- get version number of trace package
  procedure plsql_trace_version(major out binary_integer,
                                minor out binary_integer);
  
end dbms_trace;
/
show errors

grant execute on sys.dbms_trace to public;
create or replace public synonym dbms_trace for sys.dbms_trace;

