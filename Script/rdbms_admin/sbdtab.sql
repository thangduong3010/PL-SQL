Rem
Rem $Header: rdbms/admin/sbdtab.sql /st_rdbms_11.2.0/2 2012/03/06 15:07:48 shsong Exp $
Rem
Rem sbdtab.sql
Rem
Rem Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbdtab.sql StandBy statspack Drop TABle
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file to drop standby statspack snapshot tables
Rem
Rem    NOTES
Rem      Should be run as standby statspack user, stdbyperf
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      01/28/10 - add stats$lock_type
Rem    shsong      02/02/09 - remove drop stats$kccfn etc
Rem    shsong      07/10/08 - drop stats$kccfn etc
Rem    shsong      04/14/07 - Created
Rem

set echo off;

spool sbdtab.lis

/* ------------------------------------------------------------------------- */

prompt Dropping old versions (if any)

whenever sqlerror continue;

/* - sequence - */
drop sequence STDBYPERF.STATS$SNAPSHOT_ID;

/* - tables - */
drop table  STDBYPERF.STATS$FILESTATXS;
drop table  STDBYPERF.STATS$TEMPSTATXS;
drop table  STDBYPERF.STATS$LATCH;
drop table  STDBYPERF.STATS$LATCH_MISSES_SUMMARY;
drop table  STDBYPERF.STATS$LATCH_CHILDREN;
drop table  STDBYPERF.STATS$LATCH_PARENT;
drop table  STDBYPERF.STATS$LIBRARYCACHE;
drop table  STDBYPERF.STATS$BUFFER_POOL_STATISTICS;
drop table  STDBYPERF.STATS$ROLLSTAT;
drop table  STDBYPERF.STATS$ROWCACHE_SUMMARY;
drop table  STDBYPERF.STATS$SGA;
drop table  STDBYPERF.STATS$SGASTAT;
drop table  STDBYPERF.STATS$SYSSTAT;
drop table  STDBYPERF.STATS$SESSTAT;
drop table  STDBYPERF.STATS$SYSTEM_EVENT;
drop table  STDBYPERF.STATS$SESSION_EVENT;
drop table  STDBYPERF.STATS$WAITSTAT;
drop table  STDBYPERF.STATS$ENQUEUE_STATISTICS;
drop table  STDBYPERF.STATS$LOCK_TYPE;
drop table  STDBYPERF.STATS$SQL_SUMMARY;
drop table  STDBYPERF.STATS$SQL_STATISTICS;
drop table  STDBYPERF.STATS$SQLTEXT;
drop table  STDBYPERF.STATS$PARAMETER;
drop table  STDBYPERF.STATS$STATSPACK_PARAMETER;
drop table  STDBYPERF.STATS$IDLE_EVENT;
drop table  STDBYPERF.STATS$RESOURCE_LIMIT;
drop table  STDBYPERF.STATS$DLM_MISC;
drop table  STDBYPERF.STATS$UNDOSTAT;
drop table  STDBYPERF.STATS$SQL_PLAN;
drop table  STDBYPERF.STATS$SQL_PLAN_USAGE;
drop table  STDBYPERF.STATS$SEG_STAT_OBJ;
drop table  STDBYPERF.STATS$SEG_STAT;
drop table  STDBYPERF.STATS$DB_CACHE_ADVICE;
drop table  STDBYPERF.STATS$PGASTAT;
drop table  STDBYPERF.STATS$INSTANCE_RECOVERY;
drop table  STDBYPERF.STATS$SHARED_POOL_ADVICE;
drop table  STDBYPERF.STATS$SQL_WORKAREA_HISTOGRAM;
drop table  STDBYPERF.STATS$PGA_TARGET_ADVICE;
drop table  STDBYPERF.STATS$JAVA_POOL_ADVICE;
drop table  STDBYPERF.STATS$THREAD;
drop table  STDBYPERF.STATS$CR_BLOCK_SERVER;
drop table  STDBYPERF.STATS$CURRENT_BLOCK_SERVER;
drop table  STDBYPERF.STATS$INSTANCE_CACHE_TRANSFER;
drop table  STDBYPERF.STATS$FILE_HISTOGRAM;
drop table  STDBYPERF.STATS$EVENT_HISTOGRAM;
drop table  STDBYPERF.STATS$TIME_MODEL_STATNAME;
drop table  STDBYPERF.STATS$SYS_TIME_MODEL;
drop table  STDBYPERF.STATS$SESS_TIME_MODEL;
drop table  STDBYPERF.STATS$STREAMS_CAPTURE;
drop table  STDBYPERF.STATS$STREAMS_APPLY_SUM;
drop table  STDBYPERF.STATS$PROPAGATION_SENDER;
drop table  STDBYPERF.STATS$PROPAGATION_RECEIVER;
drop table  STDBYPERF.STATS$BUFFERED_QUEUES;
drop table  STDBYPERF.STATS$BUFFERED_SUBSCRIBERS;
drop table  STDBYPERF.STATS$RULE_SET;
drop table  STDBYPERF.STATS$OSSTAT;
drop table  STDBYPERF.STATS$OSSTATNAME;
drop table  STDBYPERF.STATS$PROCESS_ROLLUP;
drop table  STDBYPERF.STATS$PROCESS_MEMORY_ROLLUP;
drop table  STDBYPERF.STATS$STREAMS_POOL_ADVICE;
drop table  STDBYPERF.STATS$SGA_TARGET_ADVICE;
drop table  STDBYPERF.STATS$MUTEX_SLEEP;
drop table  STDBYPERF.STATS$DYNAMIC_REMASTER_STATS;
drop table  STDBYPERF.STATS$TEMP_SQLSTATS;
drop view   STDBYPERF.STATS$BG_EVENT_SUMMARY;
drop table  STDBYPERF.STATS$MANAGED_STANDBY;
drop table  STDBYPERF.STATS$RECOVERY_PROGRESS;
drop public synonym  STATS$MANAGED_STANDBY;
drop public synonym  STATS$RECOVERY_PROGRESS;
 
--  NB. STATS$DATABASE_INSTANCE must be dropped last, since it is referenced 
--  by foreign keys.  STATS$SNAPSHOT must be dropped before the remaining
--  tables

drop table  STDBYPERF.STATS$SNAPSHOT;
drop table  STDBYPERF.STATS$LEVEL_DESCRIPTION;
drop table  STDBYPERF.STATS$DATABASE_INSTANCE;

drop table  STDBYPERF.STATS$STANDBY_CONFIG;

/* ------------------------------------------------------------------------- */

prompt
prompt NOTE:
prompt   SBDTAB complete. Please check sbdtab.lis for any errors.
prompt

spool off;
set echo on;
