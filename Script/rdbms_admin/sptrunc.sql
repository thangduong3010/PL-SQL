Rem
Rem $Header: sptrunc.sql 22-jun-2007.13:51:11 cdgreen Exp $
Rem
Rem sptrunc.sql
Rem
Rem Copyright (c) 2000, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sptrunc.sql - STATSPACK - Truncate tables
Rem
Rem    DESCRIPTION
Rem      Truncates data in Statspack tables
Rem
Rem    NOTES
Rem      Should be run as STATSPACK user, PERFSTAT.
Rem
Rem      The following tables should NOT be truncated
Rem        STATS$LEVEL_DESCRIPTION
Rem        STATS$IDLE_EVENT
Rem        STATS$STATSPACK_PARAMETER
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdgreen     03/19/07 - 11 F2
Rem    cdgreen     03/02/07 - use _FG for v$system_event
Rem    cdgreen     05/16/06 - 5224971
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     07/16/04 - 10gR2
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3 
Rem    vbarrier    02/25/03 - 10g RAC
Rem    cdialeri    11/15/02 - 10g F1
Rem    cdialeri    11/04/02 - 2648471
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    cdialeri    04/13/01 - 9.0
Rem    cdialeri    09/12/00 - sp_1404195
Rem    cdialeri    04/11/00 - 1261813
Rem    cdialeri    03/15/00 - Created
Rem

set showmode off echo off;
whenever sqlerror exit;
undefine begin_or_exit;

spool sptrunc.lis

/* ------------------------------------------------------------------------- */

prompt
prompt Warning
prompt ~~~~~~~
prompt Running sptrunc.sql removes ALL data from Statspack tables.  You may
prompt wish to export the data before continuing.
prompt
prompt
prompt About to Truncate Statspack Tables
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt If would like to exit WITHOUT truncating the tables, enter any text at the
prompt begin_or_exit prompt (e.g. 'exit'), otherwise if you would like to begin
prompt the truncate operation, press <return>
prompt
prompt
prompt &&begin_or_exit Entered at the 'begin_or_exit' prompt

set verify off feedback off;
begin
  if '&&begin_or_exit' is not null then
    raise_application_error(-20101, 'Truncate terminated at user''s request - no tables truncated');
  end if;
end;
/
set verify on feedback on;


prompt
prompt ... Starting truncate operation

truncate table STATS$BUFFERED_QUEUES;
truncate table STATS$BUFFERED_SUBSCRIBERS;
truncate table STATS$BUFFER_POOL_STATISTICS;
truncate table STATS$CR_BLOCK_SERVER;
truncate table STATS$CURRENT_BLOCK_SERVER;
truncate table STATS$DB_CACHE_ADVICE;
truncate table STATS$DLM_MISC;
truncate table STATS$DYNAMIC_REMASTER_STATS;
truncate table STATS$ENQUEUE_STATISTICS;
truncate table STATS$EVENT_HISTOGRAM;
truncate table STATS$FILESTATXS;
truncate table STATS$FILE_HISTOGRAM;
truncate table STATS$INSTANCE_CACHE_TRANSFER;
truncate table STATS$INSTANCE_RECOVERY;
truncate table STATS$JAVA_POOL_ADVICE;
truncate table STATS$LATCH;
truncate table STATS$LATCH_CHILDREN;
truncate table STATS$LATCH_MISSES_SUMMARY;
truncate table STATS$LATCH_PARENT;
truncate table STATS$LIBRARYCACHE;
truncate table STATS$MUTEX_SLEEP;
truncate table STATS$OSSTAT;
truncate table STATS$OSSTATNAME;
truncate table STATS$PARAMETER;
truncate table STATS$PGASTAT;
truncate table STATS$PGA_TARGET_ADVICE;
truncate table STATS$PROCESS_MEMORY_ROLLUP;
truncate table STATS$PROCESS_ROLLUP;
truncate table STATS$PROPAGATION_RECEIVER;
truncate table STATS$PROPAGATION_SENDER;
truncate table STATS$RESOURCE_LIMIT;
truncate table STATS$ROLLSTAT;
truncate table STATS$ROWCACHE_SUMMARY;
truncate table STATS$RULE_SET;
truncate table STATS$SEG_STAT;
truncate table STATS$SEG_STAT_OBJ;
truncate table STATS$SESSION_EVENT;
truncate table STATS$SESSTAT;
truncate table STATS$SESS_TIME_MODEL;
truncate table STATS$SGA;
truncate table STATS$SGASTAT;
truncate table STATS$SGA_TARGET_ADVICE;
truncate table STATS$SHARED_POOL_ADVICE;
truncate table STATS$SQLTEXT;
truncate table STATS$SQL_PLAN;
truncate table STATS$SQL_PLAN_USAGE;
truncate table STATS$SQL_STATISTICS;
truncate table STATS$SQL_SUMMARY;
truncate table STATS$SQL_WORKAREA_HISTOGRAM;
truncate table STATS$STREAMS_APPLY_SUM;
truncate table STATS$STREAMS_CAPTURE;
truncate table STATS$STREAMS_POOL_ADVICE;
truncate table STATS$SYSSTAT;
truncate table STATS$SYSTEM_EVENT;
truncate table STATS$SYS_TIME_MODEL;
truncate table STATS$TEMPSTATXS;
truncate table STATS$THREAD;
truncate table STATS$TIME_MODEL_STATNAME;
truncate table STATS$UNDOSTAT;
truncate table STATS$WAITSTAT;
truncate table STATS$IOSTAT_FUNCTION;
truncate table STATS$IOSTAT_FUNCTION_NAME;
truncate table STATS$MEMORY_TARGET_ADVICE;
truncate table STATS$MEMORY_RESIZE_OPS;
truncate table STATS$MEMORY_DYNAMIC_COMPS;
truncate table STATS$INTERCONNECT_PINGS;

delete from STATS$SNAPSHOT;
delete from STATS$DATABASE_INSTANCE;

commit;

Rem This is required to allow further snapshots to work without 
Rem recreating package or restarting the instance
alter package statspack compile;

prompt
prompt ... Truncate operation complete
prompt


/* ------------------------------------------------------------------------- */

spool off;

whenever sqlerror continue;
set echo on;
