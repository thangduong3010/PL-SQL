Rem
Rem $Header: dbmspbp.sql 25-may-2001.11:09:05 gviswana Exp $
Rem
Rem dbmspbp.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmspbp.sql - PL/SQL Profiler API
Rem
Rem    DESCRIPTION
Rem      This package specifies the PL/SQL API that can be used to gather
Rem      performance (profiler) and code coverage data for PL/SQL applications.
Rem
Rem    NOTES
Rem      This package must be installed as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    astocks     09/27/99 - Add rollup routines for general use
Rem    jmuller     10/07/99 - Fix bug 708690: TAB -> blank
Rem    astocks     04/19/99 - Get runnumber early, add pause/resume
Rem    astocks     10/21/98 - Force owner into package name
Rem    ciyer       09/06/98 - PL/SQL Profiler package spec
Rem    ciyer       09/06/98 - Created
Rem

create or replace package sys.dbms_profiler
  authid current_user is

  ------------
  --  OVERVIEW
  --
  --  This package provides an API for gathering and persistently storing
  --  execution performance (profiler) and code coverage data for PL/SQL
  --  applications.
  --
  --  Improving application performance is an iterative process. Each
  --  iteration involves:
  --    1. Exercising the application with one or more benchmark tests with
  --       profiler data collection enabled.
  --    2. Analyzing the profiler data and identifying performance problems.
  --    3. Fixing the problems.
  --
  --  To support this process, the PL/SQL profiler supports the notion of
  --  a run. A run involves running the application through some benchmark
  --  test with profiler data collection enabled. The profiler user controls
  --  the beginning and end of the run by calling the API functions
  --  start_profiler, stop_profiler respectively.
  --
  --  A typical sequence of calls in a session may be:
  --    start profiler data collection in session
  --    execute PL/SQL code for which profiler/code coverage data is required
  --    stop profiler data collection
  --
  --  Note that stopping data collection flushes out the collected data
  --  as a side effect.
  --
  --  Profiler data is collected in data structures which last for the
  --  duration of the session. Users may call the flush_data function at
  --  intermediate points during the session to get incremental data and
  --  to free memory for allocated profiler data structures.
  --
  --  Note that some PL/SQL operations, such as the very first execution
  --  of a PL/SQL unit may involve I/O to catalog tables to load the byte
  --  code for the PL/SQL unit to be executed. Also some time may be spent
  --  executing package initialization code, the first time a package
  --  procedure/function is called. To avoid timing this overhead, it is
  --  recommended that the database be "warmed up" before collecting profile
  --  data. Warming up involves running the application once, without
  --  gathering profiler data.
  --
  --  The headers on the interface functions/procedures describe the
  --  meanings of arguments in greater detail.
  
  --  All facilites are available either as functions (which return a
  --  status, and will never raise an exception), or as procedures, (which
  --  will always raise an exception if they fail).
  --
  --------------
  -- ERROR CODES
  --   a 0 return value from any function denotes successful completion
  --   postive error returns are raised from the C implementation
  --   negative errors are reserved for errors from the PL/SQL package
  --   implementation (for example, ICD version mismatch).
  --

  success     constant binary_integer := 0;
  -- interface function/procedure called with an incorrect parameter
  error_param constant binary_integer := 1;
  -- data flush operation failed. check to see if the profiler tables have
  -- been created and there is adequate space.
  error_io    constant binary_integer := 2;

  -- mismatch between package and C implementation
  error_version constant binary_integer := -1;

  -- version history:
  --   1.0 - creation
  --
  major_version constant binary_integer := 2;
  minor_version constant binary_integer := 0;

  version_mismatch exception;
  pragma exception_init(version_mismatch, -6529);
  profiler_error exception ;
  pragma exception_init(profiler_error, -6528);


  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  --
  -- Start profiler data collection in session.
  --
  -- PARAMETERS:
  --   comment - each profiler run can be associated with a comment. For
  --             example, the comment could denote the name and version
  --             of the benchmark test that was used to collect data.
  --   comment1 - an additional comment
  --   run_number - each profiler run is uniquely identified by a generated
  --                run number. This allows the caller to determine what the
  --                generated run-number is, so that other tools may use it
  --                as a foreign key. On a successful return, a skeletal 
  --                record in the run_table exists. 

  function start_profiler(run_comment IN varchar2 := sysdate,
                          run_comment1 IN varchar2 := '',
                          run_number  OUT binary_integer)
    return binary_integer;

  procedure  start_profiler(run_comment IN varchar2 := sysdate,
                            run_comment1 IN varchar2 := '',
                            run_number  OUT binary_integer);
  function start_profiler(run_comment IN varchar2 := sysdate,
                          run_comment1 IN varchar2 := '')
    return binary_integer;
  procedure  start_profiler(run_comment IN varchar2 := sysdate,
                            run_comment1 IN varchar2 := '');

  --
  -- Stop profiler data collection in session. This function has the side
  -- effect of flushing data collected so far in the session and denotes
  -- the end of a run.
  --
  function stop_profiler return binary_integer;
  procedure stop_profiler;

  -- Pause profiler data collection, without terminating the run, or flushing
  -- data
  function pause_profiler return binary_integer;
  procedure pause_profiler;

  -- Resume a paused profiler run
  function resume_profiler return binary_integer;
  procedure resume_profiler;

  --
  -- Flushes profiler data collected in session. The data is flushed to
  -- database tables, which are expected to pre-exist. Use proftab.sql
  -- script to create the tables and other data structures required for
  -- persistently storing the profiler data.
  --
  function flush_data return binary_integer; 
  procedure flush_data;

  --
  -- get the version of this API
  --
  procedure get_version(major out binary_integer,
                        minor out binary_integer);

  --
  -- This function verifies that this version of the dbms_profiler package
  -- can work with the implementation in the database.
  --
  function internal_version_check return binary_integer;

  -- General purpose routines
  --
  -- compute the total time spent executing this unit - the sum of the
  -- time spent executing lines in this unit (for this run)
  --
  procedure rollup_unit(run_number IN number, unit IN number);

  -- rollup all units for the given run
  --
  procedure rollup_run(run_number IN number);
end dbms_profiler;
/

grant execute on sys.dbms_profiler to public;
create or replace public synonym dbms_profiler for sys.dbms_profiler;

