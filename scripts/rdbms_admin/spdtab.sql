Rem
Rem $Header: rdbms/admin/spdtab.sql /st_rdbms_11.2.0/2 2012/03/06 15:07:48 shsong Exp $
Rem
Rem spdtab.sql
Rem
Rem Copyright (c) 1999, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spdtab.sql
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file to drop statspack "snapshot" tables
Rem
Rem    NOTES
Rem      Must be run as STATSPACK table owner, PERFSTAT
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdgreen     03/19/07 - 11g F2
Rem    cdgreen     03/02/07 - use _FG for v$system_event
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     07/16/04 - 10gR2
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3 
Rem    vbarrier    02/25/03 - 10g RAC
Rem    cdialeri    11/15/02 - 10g F1
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    cdialeri    11/30/01 - 9.2 - features 1
Rem    cdialeri    04/13/01 - 9.0
Rem    cdialeri    09/12/00 - sp_1404195
Rem    cdialeri    04/07/00 - 1261813
Rem    cdialeri    03/28/00 - sp_purge
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    11/04/99 - 1059172
Rem    cdialeri    08/13/99 - Created
Rem

set echo off;

spool spdtab.lis

/* ------------------------------------------------------------------------- */

prompt Dropping old versions (if any)

whenever sqlerror continue;

/* - sequence - */
drop public synonym    STATS$SNAPSHOT_ID;
drop sequence PERFSTAT.STATS$SNAPSHOT_ID;

/* - tables - */
drop public synonym  STATS$FILESTATXS;
drop table  PERFSTAT.STATS$FILESTATXS;
drop public synonym  STATS$TEMPSTATXS;
drop table  PERFSTAT.STATS$TEMPSTATXS;
drop public synonym  STATS$LATCH;
drop table  PERFSTAT.STATS$LATCH;
drop public synonym  STATS$LATCH_MISSES_SUMMARY;
drop table  PERFSTAT.STATS$LATCH_MISSES_SUMMARY;
drop public synonym  STATS$LATCH_CHILDREN;
drop table  PERFSTAT.STATS$LATCH_CHILDREN;
drop public synonym  STATS$LATCH_PARENT;
drop table  PERFSTAT.STATS$LATCH_PARENT;
drop public synonym  STATS$LIBRARYCACHE;
drop table  PERFSTAT.STATS$LIBRARYCACHE;
drop public synonym  STATS$BUFFER_POOL_STATISTICS;
drop table  PERFSTAT.STATS$BUFFER_POOL_STATISTICS;
drop public synonym  STATS$ROLLSTAT;
drop table  PERFSTAT.STATS$ROLLSTAT;
drop public synonym  STATS$ROWCACHE_SUMMARY;
drop table  PERFSTAT.STATS$ROWCACHE_SUMMARY;
drop public synonym  STATS$SGA;
drop table  PERFSTAT.STATS$SGA;
drop public synonym  STATS$SGASTAT;
drop table  PERFSTAT.STATS$SGASTAT;
drop public synonym  STATS$SYSSTAT;
drop table  PERFSTAT.STATS$SYSSTAT;
drop public synonym  STATS$SESSTAT;
drop table  PERFSTAT.STATS$SESSTAT;
drop public synonym  STATS$SYSTEM_EVENT;
drop table  PERFSTAT.STATS$SYSTEM_EVENT;
drop public synonym  STATS$SESSION_EVENT;
drop table  PERFSTAT.STATS$SESSION_EVENT;
drop public synonym  STATS$WAITSTAT;
drop table  PERFSTAT.STATS$WAITSTAT;
drop public synonym  STATS$ENQUEUE_STATISTICS;
drop table  PERFSTAT.STATS$ENQUEUE_STATISTICS;
drop public synonym  STATS$SQL_SUMMARY;
drop table  PERFSTAT.STATS$SQL_SUMMARY;
drop public synonym  STATS$SQL_STATISTICS;
drop table  PERFSTAT.STATS$SQL_STATISTICS;
drop public synonym  STATS$SQLTEXT;
drop table  PERFSTAT.STATS$SQLTEXT;
drop public synonym  STATS$PARAMETER;
drop table  PERFSTAT.STATS$PARAMETER;
drop public synonym  STATS$STATSPACK_PARAMETER;
drop table  PERFSTAT.STATS$STATSPACK_PARAMETER;
drop public synonym  STATS$IDLE_EVENT;
drop table  PERFSTAT.STATS$IDLE_EVENT;
drop public synonym  STATS$RESOURCE_LIMIT;
drop table  PERFSTAT.STATS$RESOURCE_LIMIT;
drop public synonym  STATS$DLM_MISC;
drop table  PERFSTAT.STATS$DLM_MISC;
drop public synonym  STATS$UNDOSTAT;
drop table  PERFSTAT.STATS$UNDOSTAT;
drop public synonym  STATS$SQL_PLAN;
drop table  PERFSTAT.STATS$SQL_PLAN;
drop public synonym  STATS$SQL_PLAN_USAGE;
drop table  PERFSTAT.STATS$SQL_PLAN_USAGE;
drop public synonym  STATS$SEG_STAT_OBJ;
drop table  PERFSTAT.STATS$SEG_STAT_OBJ;
drop public synonym  STATS$SEG_STAT;
drop table  PERFSTAT.STATS$SEG_STAT;
drop public synonym  STATS$DB_CACHE_ADVICE;
drop table  PERFSTAT.STATS$DB_CACHE_ADVICE;
drop public synonym  STATS$PGASTAT;
drop table  PERFSTAT.STATS$PGASTAT;
drop public synonym  STATS$INSTANCE_RECOVERY;
drop table  PERFSTAT.STATS$INSTANCE_RECOVERY;
drop public synonym  STATS$SHARED_POOL_ADVICE;
drop table  PERFSTAT.STATS$SHARED_POOL_ADVICE;
drop public synonym  STATS$SQL_WORKAREA_HISTOGRAM;
drop table  PERFSTAT.STATS$SQL_WORKAREA_HISTOGRAM;
drop public synonym  STATS$PGA_TARGET_ADVICE;
drop table  PERFSTAT.STATS$PGA_TARGET_ADVICE;
drop public synonym  STATS$JAVA_POOL_ADVICE;
drop table  PERFSTAT.STATS$JAVA_POOL_ADVICE;
drop public synonym  STATS$THREAD;
drop table  PERFSTAT.STATS$THREAD;
drop public synonym  STATS$CR_BLOCK_SERVER;
drop table  PERFSTAT.STATS$CR_BLOCK_SERVER;
drop public synonym  STATS$CURRENT_BLOCK_SERVER;
drop table  PERFSTAT.STATS$CURRENT_BLOCK_SERVER;
drop public synonym  STATS$INSTANCE_CACHE_TRANSFER;
drop table  PERFSTAT.STATS$INSTANCE_CACHE_TRANSFER;
drop public synonym  STATS$FILE_HISTOGRAM;
drop table  PERFSTAT.STATS$FILE_HISTOGRAM;
drop public synonym  STATS$EVENT_HISTOGRAM;
drop table  PERFSTAT.STATS$EVENT_HISTOGRAM;
drop public synonym  STATS$TIME_MODEL_STATNAME;
drop table  PERFSTAT.STATS$TIME_MODEL_STATNAME;
drop public synonym  STATS$SYS_TIME_MODEL;
drop table  PERFSTAT.STATS$SYS_TIME_MODEL;
drop public synonym  STATS$SESS_TIME_MODEL;
drop table  PERFSTAT.STATS$SESS_TIME_MODEL;
drop public synonym  STATS$STREAMS_CAPTURE;
drop table  PERFSTAT.STATS$STREAMS_CAPTURE;
drop public synonym  STATS$STREAMS_APPLY_SUM;
drop table  PERFSTAT.STATS$STREAMS_APPLY_SUM;
drop public synonym  STATS$PROPAGATION_SENDER;
drop table  PERFSTAT.STATS$PROPAGATION_SENDER;
drop public synonym  STATS$PROPAGATION_RECEIVER;
drop table  PERFSTAT.STATS$PROPAGATION_RECEIVER;
drop public synonym  STATS$BUFFERED_QUEUES;
drop table  PERFSTAT.STATS$BUFFERED_QUEUES;
drop public synonym  STATS$BUFFERED_SUBSCRIBERS;
drop table  PERFSTAT.STATS$BUFFERED_SUBSCRIBERS;
drop public synonym  STATS$RULE_SET;
drop table  PERFSTAT.STATS$RULE_SET;
drop public synonym  STATS$OSSTAT;
drop table  PERFSTAT.STATS$OSSTAT;
drop public synonym  STATS$OSSTATNAME;
drop table  PERFSTAT.STATS$OSSTATNAME;
drop public synonym  STATS$PROCESS_ROLLUP;
drop table  PERFSTAT.STATS$PROCESS_ROLLUP;
drop public synonym  STATS$PROCESS_MEMORY_ROLLUP;
drop table  PERFSTAT.STATS$PROCESS_MEMORY_ROLLUP;
drop public synonym  STATS$STREAMS_POOL_ADVICE;
drop table  PERFSTAT.STATS$STREAMS_POOL_ADVICE;
drop public synonym  STATS$SGA_TARGET_ADVICE;
drop table  PERFSTAT.STATS$SGA_TARGET_ADVICE;
drop public synonym  STATS$MUTEX_SLEEP;
drop table  PERFSTAT.STATS$MUTEX_SLEEP;
drop public synonym  STATS$DYNAMIC_REMASTER_STATS;
drop table  PERFSTAT.STATS$DYNAMIC_REMASTER_STATS;
drop public synonym  STATS$TEMP_SQLSTATS;
drop table  PERFSTAT.STATS$TEMP_SQLSTATS;
drop public synonym  STATS$BG_EVENT_SUMMARY;
drop view   PERFSTAT.STATS$BG_EVENT_SUMMARY;
drop public synonym  STATS$IOSTAT_FUNCTION;
drop table  PERFSTAT.STATS$IOSTAT_FUNCTION;
drop public synonym  STATS$IOSTAT_FUNCTION_NAME;
drop table  PERFSTAT.STATS$IOSTAT_FUNCTION_NAME;
drop public synonym  STATS$MEMORY_TARGET_ADVICE;
drop table  PERFSTAT.STATS$MEMORY_TARGET_ADVICE;
drop public synonym  STATS$MEMORY_RESIZE_OPS;
drop table  PERFSTAT.STATS$MEMORY_RESIZE_OPS;
drop public synonym  STATS$MEMORY_DYNAMIC_COMPS;
drop table  PERFSTAT.STATS$MEMORY_DYNAMIC_COMPS;
drop public synonym STATS$INTERCONNECT_PINGS;
drop table  PERFSTAT.STATS$INTERCONNECT_PINGS;

--  NB. STATS$DATABASE_INSTANCE must be dropped last, since it is referenced 
--  by foreign keys.  STATS$SNAPSHOT must be dropped before the remaining
--  tables

drop public synonym  STATS$SNAPSHOT;
drop table  PERFSTAT.STATS$SNAPSHOT;
drop public synonym  STATS$LEVEL_DESCRIPTION;
drop table  PERFSTAT.STATS$LEVEL_DESCRIPTION;
drop public synonym  STATS$DATABASE_INSTANCE;
drop table  PERFSTAT.STATS$DATABASE_INSTANCE;



/* - packages - */
drop public  synonym  STATSPACK;
drop package PERFSTAT.STATSPACK;

/* ------------------------------------------------------------------------- */

prompt
prompt NOTE:
prompt   SPDTAB complete. Please check spdtab.lis for any errors.
prompt

spool off;
set echo on;
