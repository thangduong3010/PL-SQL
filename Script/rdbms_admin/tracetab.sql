Rem
Rem $Header: tracetab.sql 31-mar-2006.16:45:38 jmuller Exp $
Rem
Rem tracetab.sql
Rem
Rem Copyright (c) 1999, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      tracetab.sql
Rem
Rem    DESCRIPTION
Rem      Create tables for the PL/SQL tracer
Rem
Rem    NOTES
Rem      This script must be run under SYS
Rem
Rem      The following tables are required to collect data
Rem        plsql_trace_runs - information on trace runs
Rem        plsql_trace_event - detailed trace data
Rem
Rem      For security reasons, these tables are created under SYS, and are
Rem      unique system-wide. The DBA should explicitly grant access to these
Rem      tables to those users who require it.
Rem
Rem      The plsql_trace_runnumber sequence is used for generating unique
Rem      run numbers.
Rem
Rem      THIS SCRIPT DELETES ALL EXISTING DATA!
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jmuller     03/14/06 - Fix bug 5066528: several tracing enhancements 
Rem    dalpern     05/18/05 - 4180912: improved info in PLSQL_TRACE_EVENTS 
Rem    jmuller     10/16/02 - Fix bug 2610154: widen *dblink columns
Rem    astocks     09/16/99 - Make use of sys consistent
Rem    jmuller     10/07/99 - Fix bug 708690: TAB -> blank
Rem    astocks     06/07/99 - Tables for PL/SQL tracer
Rem    astocks     06/07/99 - Created
Rem
Rem

drop table sys.plsql_trace_events cascade constraints;
drop table sys.plsql_trace_runs cascade constraints;

drop sequence sys.plsql_trace_runnumber;

create table sys.plsql_trace_runs
(
  runid           number primary key,  -- unique run identifier,
                                       -- from plsql_trace_runnumber
  run_date        date,                -- start time of run
  run_owner       varchar2(31),        -- account under which run was made
  run_comment     varchar2(2047),      -- user provided comment for this run
  run_comment1    varchar2(2047),      -- additional user-supplied comment
  run_end         date,                -- termination time for this run
  run_flags       varchar2(2047),      -- flags for this run
  related_run     number,              -- for correlating client/server   
  run_system_info varchar2(2047),      -- currently unused
  spare1          varchar2(256)        -- unused
);

comment on table sys.plsql_trace_runs is
        'Run-specific information for the PL/SQL trace';

create table sys.plsql_trace_events
(
  runid           number references sys.plsql_trace_runs,--  run identifier
  event_seq       number,           -- unique sequence number within run
  event_time      date,             -- timestamp
  related_event   number,
  event_kind      number,
  event_unit_dblink varchar2(4000),
  event_unit_owner varchar2(31),
  event_unit      varchar2(31),     -- unit where the event happened
  event_unit_kind varchar2(31),
  event_line      number,           -- line in the unit where event happened
  event_proc_name varchar2(31),     -- if not empty, procedure where event 
                                    -- happened
  stack_depth     number,
--
-- Fields that apply to procedure calls
  proc_name       varchar2(31),     -- if not empty, name of procedure called
  proc_dblink     varchar2(4000),
  proc_owner      varchar2(31),
  proc_unit       varchar2(31),
  proc_unit_kind  varchar2(31),
  proc_line       number,
  proc_params     varchar2(2047),
--
-- Fields that apply to ICDs (Calls to PL/SQL internal routines)
  icd_index       number,         
--
-- Fields that apply to exceptions
  user_excp       number,
  excp            number,
--
-- Field for comments
--     User defined event - text supplied by user
--     SQL event          - actual SQL string
--     Others             - Description of event 
  event_comment   varchar2(2047),
----
-- Fields for bulk binds
-- ?
--
-- Fields from dbms_application_info, dbms_session, and ECID
  module          varchar2(4000),
  action          varchar2(4000),
  client_info     varchar2(4000),
  client_id       varchar2(4000),
  ecid_id         varchar2(4000),
  ecid_seq        number,
--
--
-- Fields for extended callstack and errorstack info
--  (currently set only for "Exception raised", "Exception handled" and "Trace
--  flags changed" ([5066528]) events)
--
  callstack       clob,
  errorstack      clob,
--
  primary key(runid, event_seq)
);

comment on table sys.plsql_trace_events is 
        'Accumulated data from all trace runs';

create sequence sys.plsql_trace_runnumber start with 1 nocache;

