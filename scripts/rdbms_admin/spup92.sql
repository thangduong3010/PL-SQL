Rem
Rem $Header: rdbms/admin/spup92.sql /st_rdbms_11.2.0/1 2010/08/13 11:23:18 kchou Exp $
Rem
Rem spup92.sql
Rem
Rem Copyright (c) 2002, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spup92.sql - StatsPack UPgrade 92
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 10.1 schema
Rem
Rem    NOTES
Rem      Export the Statspack schema before running this upgrade,
Rem      as this is the only way to restore the existing data.
Rem      A downgrade script is not provided.
Rem
Rem      Disable any scripts which use Statspack while the upgrade script
Rem      is running.
Rem
Rem      Ensure there is plenty of free space in the tablespace
Rem      where the schema resides.
Rem
Rem      This script should be run when connected as SYSDBA
Rem
Rem      This upgrade script should only be run once.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       08/12/10 - Bug#10009909 - Backport of Statspack Security Fix
Rem                           Bug# 9950811
Rem    kchou       08/12/10 - Backport kchou_bug-9950811 from main
Rem    cdialeri    03/02/04 - 3513994: 3473979, 3483451, 3483461
Rem    cdialeri    11/05/03 - 3202706 
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3 
Rem    cdialeri    02/27/03 - 10i F2: baseline, purge
Rem    vbarrier    02/25/03 - 10i RAC
Rem    vbarrier    01/17/03 - stats$segstat_obj: new RAC stats
Rem    cdialeri    12/09/02 - 10i F1
Rem    cdialeri    11/15/02 - Created
Rem

set verify off
/* ------------------------------------------------------------------------- */

prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 10.1 format may result in
prompt irregularities when reporting on pre-10.1 snapshot data.
prompt This script is provided for convenience, and is not guaranteed to 
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  Please see spdoc.txt for more details.
prompt
prompt
prompt Usage Recommendations
prompt ~~~~~~~~~~~~~~~~~~~~~
prompt Disable any programs which run Statspack (including any dbms_jobs),
prompt or this upgrade will fail.
prompt
prompt You will be prompted for the PERFSTAT password, and for the 
prompt tablespace to create any new PERFSTAT tables/indexes.
prompt
prompt You must be connected as a user with SYSDBA privilege to successfully
prompt run this script.
prompt
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup92a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt


/* ------------------------------------------------------------------------- */
--
-- Create SYS views, public synonyms, issue grants

create or replace view STATS$V_$SQLXS as
select max(sql_text)        sql_text
     , max(sql_id)          sql_id
     , sum(sharable_mem)    sharable_mem
     , sum(sorts)           sorts
     , min(module)          module
     , sum(loaded_versions) loaded_versions
     , sum(fetches)         fetches
     , sum(executions)      executions
     , sum(end_of_fetch_count) end_of_fetch_count
     , sum(loads)           loads
     , sum(invalidations)   invalidations
     , sum(parse_calls)     parse_calls
     , sum(disk_reads)      disk_reads
     , sum(direct_writes)   direct_writes
     , sum(buffer_gets)     buffer_gets
     , sum(application_wait_time)  application_wait_time
     , sum(concurrency_wait_time)  concurrency_wait_time
     , sum(cluster_wait_time)      cluster_wait_time
     , sum(user_io_wait_time)      user_io_wait_time
     , sum(plsql_exec_time)        plsql_exec_time
     , sum(java_exec_time)         java_exec_time
     , sum(rows_processed)  rows_processed
     , max(command_type)    command_type
     , address              address
     , old_hash_value       old_hash_value
     , max(hash_value)      hash_value
     , count(1)             version_count
     , sum(cpu_time)        cpu_time
     , sum(elapsed_time)    elapsed_time
     , max(outline_sid)     outline_sid
     , max(outline_category) outline_category
     , max(is_obsolete)     is_obsolete
     , max(child_latch)     child_latch
     , max(sql_profile)     sql_profile
     , max(program_id)      program_id
     , max(program_line#)   program_line#
  from v$sql
 group by old_hash_value, address;
create or replace public synonym STATS$V$SQLXS for STATS$V_$SQLXS; 

create or replace view STATS$V_$FILESTATXS as
select ts.name      tsname
     , df.name      filename
     , fs.phyrds
     , fs.phywrts
     , fs.readtim
     , fs.writetim
     , fs.singleblkrds
     , fs.phyblkrd
     , fs.phyblkwrt
     , fs.singleblkrdtim
     , fw.count     wait_count
     , fw.time      time
     , df.file#
  from x$kcbfwait   fw
     , v$filestat   fs
     , v$tablespace ts
     , v$datafile   df
 where ts.ts#    = df.ts#
   and fs.file#  = df.file#
   and fw.indx+1 = df.file#;

create or replace view STATS$V_$TEMPSTATXS as
select ts.name      tsname
     , tf.name      filename
     , tm.phyrds
     , tm.phywrts
     , tm.readtim
     , tm.writetim
     , tm.singleblkrds
     , tm.phyblkrd
     , tm.phyblkwrt
     , tm.singleblkrdtim
     , fw.count     wait_count
     , fw.time      time
     , tf.file#
  from x$kcbfwait   fw
     , v$tempstat   tm
     , v$tablespace ts
     , v$tempfile   tf
 where ts.ts#     = tf.ts#
   and tm.file#   = tf.file#
   and fw.indx+1  = (tf.file# + (select value from v$parameter where name='db_files'));

--
-- Workaround for Streams views

create or replace view STATS$V_$PROPAGATION_SENDER as
select queue_schema
     , queue_name
     , dblink
     , '-' dst_queue_schema
     , '-' dst_queue_name
     , total_msgs
     , total_bytes
     , elapsed_dequeue_time
     , elapsed_pickle_time
     , elapsed_propagation_time
  from v$propagation_sender;
grant select on STATS$V_$PROPAGATION_SENDER to PERFSTAT;
create synonym PERFSTAT.V$PROPAGATION_SENDER for STATS$V_$PROPAGATION_SENDER;

create or replace view STATS$V_$PROPAGATION_RECEIVER as
select replace(substrb(src_queue_name, 1, instr(src_queue_name, '"', 2)), '"')  src_queue_schema
     , replace(substrb(src_queue_name, instr(src_queue_name, '"', 2) + 2), '"') src_queue_name
     , src_dbname
     , '-' dst_queue_schema
     , '-' dst_queue_name
     , startup_time
     , elapsed_unpickle_time
     , elapsed_rule_time
     , elapsed_enqueue_time
  from v$propagation_receiver;
grant select on STATS$V_$PROPAGATION_RECEIVER to PERFSTAT;
create synonym PERFSTAT.V$PROPAGATION_RECEIVER for STATS$V_$PROPAGATION_RECEIVER;


grant select on V_$ENQUEUE_STATISTICS        to PERFSTAT;
grant select on V_$JAVA_POOL_ADVICE          to PERFSTAT;
grant select on V_$THREAD                    to PERFSTAT;
grant select on V_$CR_BLOCK_SERVER           to PERFSTAT;
grant select on V_$CURRENT_BLOCK_SERVER      to PERFSTAT;
grant select on V_$CLASS_CACHE_TRANSFER      to PERFSTAT;
grant select on V_$FILE_HISTOGRAM            to PERFSTAT;
grant select on V_$TEMP_HISTOGRAM            to PERFSTAT;
grant select on V_$EVENT_HISTOGRAM           to PERFSTAT;
grant select on V_$EVENT_NAME                to PERFSTAT;
grant select on V_$SYS_TIME_MODEL            to PERFSTAT;
grant select on V_$SESS_TIME_MODEL           to PERFSTAT;
grant select on V_$STREAMS_CAPTURE           to PERFSTAT;
grant select on V_$STREAMS_APPLY_COORDINATOR to PERFSTAT;
grant select on V_$STREAMS_APPLY_READER      to PERFSTAT;
grant select on V_$STREAMS_APPLY_SERVER      to PERFSTAT;
grant select on V_$PROPAGATION_SENDER        to PERFSTAT;
grant select on V_$PROPAGATION_RECEIVER      to PERFSTAT;
grant select on DBA_QUEUE_SCHEDULES          to PERFSTAT;
grant select on V_$BUFFERED_QUEUES           to PERFSTAT;
grant select on V_$BUFFERED_SUBSCRIBERS      to PERFSTAT;
grant select on V_$RULE_SET                  to PERFSTAT;
grant select on V_$OSSTAT                    to PERFSTAT;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup92b.lis

spool off
connect perfstat/&&perfstat_password

spool spup92b.lis

show user

set verify off
set serveroutput on size 4000


/* ------------------------------------------------------------------------- */

-- 
-- SGASTAT column increase

-- Modify column
alter table STATS$SGASTAT modify
(pool              varchar2(12)
);

/* ------------------------------------------------------------------------- */

-- 
-- WAITSTAT column increase

-- Modify column
alter table STATS$WAITSTAT modify
(class              varchar2(22)
);

/* ------------------------------------------------------------------------- */

--
--  Rename hash_value to old_hash_value, and add (new) hash_value

alter table STATS$SQL_SUMMARY    rename column hash_value to old_hash_value;
alter table STATS$SQL_PLAN_USAGE rename column hash_value to old_hash_value;
alter table STATS$SQLTEXT        rename column hash_value to old_hash_value;
alter table STATS$SQL_SUMMARY    modify (old_hash_value not null);

alter table STATS$SQL_SUMMARY    add (hash_value number);
alter table STATS$SQL_PLAN_USAGE add (hash_value number);


/* ------------------------------------------------------------------------- */

-- 
-- SQL_SUMMARY new columns

-- Modify column
alter table STATS$SQL_SUMMARY add
(sql_id               varchar2(13)
,end_of_fetch_count   number
,direct_writes         number
,application_wait_time number
,concurrency_wait_time number
,cluster_wait_time     number
,user_io_wait_time     number
,plsql_exec_time       number
,java_exec_time        number
,sql_profile           varchar2(64)
,program_id            number
,program_line#         number
);

/* ------------------------------------------------------------------------- */

--
-- SQLTEXT new column

alter table STATS$SQLTEXT add
(sql_id               varchar2(13)
);

/* ------------------------------------------------------------------------- */

-- 
-- SQL_PLAN new columns & modifications

-- Modify
alter table STATS$SQL_PLAN modify
(object_name varchar2(31)
,object_node varchar2(40)
);

-- Add columns
alter table STATS$SQL_PLAN add
(object_alias         varchar2(65)
,object_type          varchar2(20)
,projection           varchar2(4000)
,time                 number
,qblock_name          varchar2(31)
,remarks              varchar2(4000)
);
 
/* ------------------------------------------------------------------------- */

--
-- SQL_PLAN_USAGE column addition

alter table STATS$SQL_PLAN_USAGE add
(sql_id               varchar2(13)
);

/* ------------------------------------------------------------------------- */

-- 
-- SNAPSHOT new baseline column

-- Add column
alter table STATS$SNAPSHOT add
(baseline             varchar2(1)
,constraint STATS$SNAPSHOT_BASE_CK
    check (baseline in ('Y'))
);

/* ------------------------------------------------------------------------- */

-- 
-- UNDOSTAT PK modification and FK addition (purge support)

-- Modify the PK for undostat to include snap_id
alter table STATS$UNDOSTAT drop primary key drop index;

-- Create the new PK
alter table STATS$UNDOSTAT add constraint STATS$UNDOSTAT_PK
  primary key
  (begin_time, end_time, snap_id, dbid, instance_number)
  using index
   tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0);

-- Delete orphaned rows
delete from stats$undostat u
  where (snap_id, dbid, instance_number) not in
        (select /*+ index_ffs (s) */
                snap_id, dbid, instance_number
           from stats$snapshot s);
commit;

-- Create a Foreign Key to the stats$snapshot table
alter table STATS$UNDOSTAT add constraint 
  STATS$UNDOSTAT_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade;

/* ------------------------------------------------------------------------- */

--
-- Undostat addition of new columns

alter table STATS$UNDOSTAT add
(maxqueryid           varchar2(13)
,activeblks           number
,unexpiredblks        number
,expiredblks          number
,tuned_undoretention  number
);

/* ------------------------------------------------------------------------- */

-- 
-- ENQUEUE_STATISTICS support

-- Rename the table
rename STATS$ENQUEUE_STAT to STATS$ENQUEUE_STATISTICS;

-- Public Synonyms
drop   public synonym  STATS$ENQUEUE_STAT;
create public synonym  STATS$ENQUEUE_STATISTICS  for STATS$ENQUEUE_STATISTICS;

-- Add new columns
alter table STATS$ENQUEUE_STATISTICS add
(req_reason        varchar2(64)
,event#            number
);

-- Update req_reason in pre-existing rows, so that the column can be made not 
-- null, and so be part of the concat PK
update STATS$ENQUEUE_STATISTICS set req_reason = '-' where req_reason is null;
commit;

-- Make the column not null
alter table STATS$ENQUEUE_STATISTICS modify (req_reason not null);

-- Drop the old PK
alter table STATS$ENQUEUE_STATISTICS drop primary key drop index;

-- Create the new PK
alter table STATS$ENQUEUE_STATISTICS add constraint STATS$ENQUEUE_STATISTICS_PK
  primary key
  (snap_id, dbid, instance_number, eq_type, req_reason)
  using index
   tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0);

-- Rename foreign key constraint to keep it consistent with new table name
alter table STATS$ENQUEUE_STATISTICS rename constraint 
  STATS$ENQUEUE_STAT_FK to STATS$ENQUEUE_STATISTICS_FK;


/* ------------------------------------------------------------------------- */

-- 
-- Additions to SHARED_POOL_ADVICE

-- Add new columns
alter table STATS$SHARED_POOL_ADVICE add
(estd_lc_load_time        number
,estd_lc_load_time_factor number
);

/* ------------------------------------------------------------------------- */

--
--  Add THREAD support

create table STATS$THREAD
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,thread#                        number     not null
,thread_instance_number         number
,status                         varchar2(6)
,open_time                      date
,current_group#                 number
,sequence#                      number
,constraint STATS$THREAD_PK primary key
     (snap_id, dbid, instance_number, thread#)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$THREAD_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$THREAD  for STATS$THREAD;


/* ------------------------------------------------------------------------- */

-- 
-- Add JAVA_POOL_ADVICE

create table STATS$JAVA_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,java_pool_size_for_estimate    number     not null
,java_pool_size_factor          number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_load_time              number
,estd_lc_load_time_factor       number
,estd_lc_memory_object_hits     number
,constraint STATS$JAVA_POOL_ADVICE_PK primary key
     (snap_id, dbid, instance_number, java_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$JAVA_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$JAVA_POOL_ADVICE  for STATS$JAVA_POOL_ADVICE;


/* ------------------------------------------------------------------------- */

-- 
-- Add cr_block_server

create table STATS$CR_BLOCK_SERVER
(snap_id                   number          not null
,dbid                      number          not null
,instance_number           number          not null
,cr_requests               number
,current_requests          number
,data_requests             number
,undo_requests             number
,tx_requests               number
,current_results           number
,private_results           number
,zero_results              number
,disk_read_results         number
,fail_results              number
,fairness_down_converts    number
,fairness_clears           number
,free_gc_elements          number
,flushes                   number
,flushes_queued            number
,flush_queue_full          number
,flush_max_time            number
,light_works               number
,errors                    number
,constraint STATS$CR_BLOCK_SERVER_PK primary key
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$CR_BLOCK_SERVER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$CR_BLOCK_SERVER  for STATS$CR_BLOCK_SERVER;

/* ------------------------------------------------------------------------- */

-- 
-- Add current_block_server

create table STATS$CURRENT_BLOCK_SERVER
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,pin1                 number
,pin10                number
,pin100               number
,pin1000              number
,pin10000             number
,flush1               number
,flush10              number
,flush100             number
,flush1000            number
,flush10000           number
,write1               number
,write10              number
,write100             number
,write1000            number
,write10000           number
,constraint STATS$CURRENT_BLOCK_SERVER_PK primary key
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$CURRENT_BLOCK_SERVER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$CURRENT_BLOCK_SERVER  for STATS$CURRENT_BLOCK_SERVER;


/* ------------------------------------------------------------------------- */

-- 
-- Add class_cache_transfer

create table STATS$CLASS_CACHE_TRANSFER
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,class                    varchar2(18)    not null
,cr_transfer              number
,current_transfer         number
,x_2_null                 number
,x_2_null_forced_write    number
,x_2_null_forced_stale    number
,x_2_s                    number
,x_2_s_forced_write       number
,s_2_null                 number
,s_2_null_forced_stale    number
,null_2_x                 number
,s_2_x                    number
,null_2_s                 number
,constraint STATS$CLASS_CACHE_TRANSFER_PK primary key
    (snap_id, dbid, instance_number,class)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$CLASS_CACHE_TRANSFER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$CLASS_CACHE_TRANSFER  for STATS$CLASS_CACHE_TRANSFER;


/* ------------------------------------------------------------------------- */

--
-- Add any new segment statistics, and rename statspack_parameter threshold
-- columns

-- Add new segment statistics columns to seg_stat table
alter table STATS$SEG_STAT add
(gc_cr_blocks_received             number
,gc_current_blocks_received        number
,gc_buffer_busy                    number
);

-- Rename old threshold parameters which are no longer in use, to the new 
-- threshold parameters in the statspack parameter table
alter table STATS$STATSPACK_PARAMETER rename column seg_cr_bks_sd_th to
                                                    seg_cr_bks_rc_th;
alter table STATS$STATSPACK_PARAMETER rename column seg_cu_bks_sd_th to
                                                    seg_cu_bks_rc_th;

-- Modify the snapshot table to allow NULLable values in these old
-- columns - new snapshots will not set the obsolete thresholds

declare

  l_sql             varchar2(2000);
  l_cursor          integer;
  l_column          varchar2(30);

  cursor null_column is
   select column_name
     from dba_tab_columns
    where owner          = 'PERFSTAT'
      and column_name   in ('SEG_CR_BKS_SD_TH', 'SEG_CU_BKS_SD_TH')
      and table_name     = 'STATS$SNAPSHOT'
      and nullable       = 'N';

begin

   dbms_output.put_line('Beginning modification of obsolete stats$snapshot threshold columns');

   open null_column;

   l_cursor := dbms_sql.open_cursor;

   loop

    fetch null_column into l_column;
    exit when null_column%notfound;

     l_sql := 'alter table STATS$SNAPSHOT modify (' || l_column ||' null)';
     dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
     dbms_output.put_line('.. Modified '|| l_column || ' to nullable');

   end loop;

   dbms_output.put_line('Modification of stats$snapshot threshold columns complete');

end;
/

-- Add the new threshold columns to the snapshot table
alter table STATS$SNAPSHOT add
(seg_cr_bks_rc_th     number
,seg_cu_bks_rc_th     number
);


/* ------------------------------------------------------------------------- */

-- 
-- Support for file_histogram, temp_histogram and event_histogram

create table STATS$FILE_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,file#                          number     not null
,singleblkrdtim_milli           number     not null
,singleblkrds                   number
,constraint STATS$FILE_HISTOGRAM_PK primary key
     (snap_id, dbid, instance_number, file#, singleblkrdtim_milli)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$FILE_HISTOGRAM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$FILE_HISTOGRAM  for STATS$FILE_HISTOGRAM;


create table STATS$TEMP_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,file#                          number     not null
,singleblkrdtim_milli           number     not null
,singleblkrds                   number
,constraint STATS$TEMP_HISTOGRAM_PK primary key
     (snap_id, dbid, instance_number, file#, singleblkrdtim_milli)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$TEMP_HISTOGRAM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$TEMP_HISTOGRAM  for STATS$TEMP_HISTOGRAM;


create table STATS$EVENT_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,event_id                       number     not null
,wait_time_milli                number     not null
,wait_count                     number
,constraint STATS$EVENT_HISTOGRAM_PK primary key
     (snap_id, dbid, instance_number, event_id, wait_time_milli)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$EVENT_HISTOGRAM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$EVENT_HISTOGRAM  for STATS$EVENT_HISTOGRAM;


-- Modify existing table to add lookup columns
alter table STATS$FILESTATXS add
(file#      number);

alter table STATS$TEMPSTATXS add
(file#      number);

alter table STATS$SYSTEM_EVENT add
(event_id   number);

/* ------------------------------------------------------------------------- */

-- Additional columns to db_cache_advice

alter table STATS$DB_CACHE_ADVICE add
(estd_physical_read_time       number
,estd_pct_of_db_time_for_reads number
);

/* ------------------------------------------------------------------------- */

-- 
-- Change snap_id column to number from number(6)

declare

  l_dbid            number;
  l_instance_number number;
  l_cursor          integer;
  l_sql             varchar2(2000);
  l_tname           varchar2(30);

  cursor tabs_with_snapid is
   select tc.table_name
     from dba_tab_columns tc
        , dba_tables      t
    where tc.owner          = 'PERFSTAT'
      and tc.column_name    = 'SNAP_ID'
      and tc.data_type      = 'NUMBER'
      and tc.data_precision is not null
      and t.table_name     = tc.table_name
      and t.owner          = tc.owner
      and t.dropped        = 'NO';

begin

   dbms_output.put_line('Beginning modification of snap_id number(6) to number');

   open tabs_with_snapid;

   l_cursor := dbms_sql.open_cursor;

   loop

    fetch tabs_with_snapid into l_tname;
    exit when tabs_with_snapid%notfound;

     -- 7/29/2010 kchou: bug# 9950811 security bug sql injection fix
     l_sql := 'alter table ' || dbms_assert.enquote_name(l_tname, FALSE) || ' modify (snap_id number)';
     dbms_output.put_line('.. Modifying '|| l_tname);
     dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);

   end loop;

   dbms_output.put_line('Modification of snap_id number(6) to number complete');

end;
/

/* ------------------------------------------------------------------------- */

--
-- Time model support

create table STATS$TIME_MODEL_STATNAME
(stat_id                number       not null
,stat_name              varchar2(64) not null
,constraint STATS$TIME_MODEL_STATNAME_PK primary key
     (stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$TIME_MODEL_STATNAME  for STATS$TIME_MODEL_STATNAME;


--
-- System wide time model

create table STATS$SYS_TIME_MODEL
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,stat_id                        number     not null
,value                          number     not null
,constraint STATS$SYS_TIME_MODEL_PK primary key
     (snap_id, dbid, instance_number, stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SYS_TIME_MODEL_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SYS_TIME_MODEL  for STATS$SYS_TIME_MODEL;


--
-- Session specific time model

create table STATS$SESS_TIME_MODEL
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,stat_id                        number     not null
,value                          number     not null
,constraint STATS$SESS_TIME_MODEL_PK primary key
     (snap_id, dbid, instance_number, stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SESS_TIME_MODEL_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SESS_TIME_MODEL  for STATS$SESS_TIME_MODEL;

/* ------------------------------------------------------------------------- */

--
-- Streams support

--
-- Streams Capture

create table STATS$STREAMS_CAPTURE
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,capture_name                   varchar2(30) not null
,startup_time                   date         not null
,total_messages_captured        number
,total_messages_enqueued        number
,elapsed_capture_time           number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,elapsed_lcr_time               number
,elapsed_redo_wait_time         number
,elapsed_pause_time             number
,constraint STATS$STREAMS_CAPTURE_PK primary key
  (snap_id, dbid, instance_number, capture_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_CAPTURE_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$STREAMS_CAPTURE  for STATS$STREAMS_CAPTURE;

/* ------------------------------------------------------------------------- */

--
-- Streams Apply
-- Summary of data from v$apply_coordinator, v$apply_reader and v$apply_server

create table STATS$STREAMS_APPLY_SUM
(snap_id                              number       not null
,dbid                                 number       not null
,instance_number                      number       not null
,apply_name                           varchar2(30) not null
,startup_time                         date         not null
,reader_total_messages_dequeued       number
,reader_elapsed_dequeue_time          number
,reader_elapsed_schedule_time         number
,coord_total_received                 number
,coord_total_applied                  number
,coord_total_wait_deps                number
,coord_total_wait_commits             number
,coord_elapsed_schedule_time          number
,server_total_messages_applied        number
,server_elapsed_dequeue_time          number
,server_elapsed_apply_time            number
,constraint STATS$STREAMS_APPLY_SUM_PK primary key
  (snap_id, dbid, instance_number, apply_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_APPLY_SUM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$STREAMS_APPLY_SUM for STATS$STREAMS_APPLY_SUM;

/* ------------------------------------------------------------------------- */

--
-- Propagation Sender
-- Joins to dba_queue_schedules

create table STATS$PROPAGATION_SENDER
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,queue_schema                   varchar2(30)  not null
,queue_name                     varchar2(30)  not null
,dblink                         varchar2(128) not null
,dst_queue_schema               varchar2(30)  not null
,dst_queue_name                 varchar2(30)  not null
,startup_time                   date
,total_msgs                     number
,total_bytes                    number
,elapsed_dequeue_time           number
,elapsed_pickle_time            number
,elapsed_propagation_time       number
,constraint STATS$PROPAGATION_SENDER_PK primary key
  (snap_id, dbid, instance_number
  ,queue_schema, queue_name, dblink, dst_queue_schema, dst_queue_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROPAGATION_SENDER_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROPAGATION_SENDER for STATS$PROPAGATION_SENDER;

/* ------------------------------------------------------------------------- */

--
-- Propagation Receiver

create table STATS$PROPAGATION_RECEIVER
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,src_queue_schema               varchar2(30)  not null
,src_queue_name                 varchar2(30)  not null
,src_dbname                     varchar2(128) not null
,dst_queue_schema               varchar2(30)  not null
,dst_queue_name                 varchar2(30)  not null
,startup_time                   date          not null
,elapsed_unpickle_time          number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,constraint STATS$PROPAGATION_RECEIVER_PK primary key
  (snap_id, dbid, instance_number
  ,src_queue_schema, src_queue_name, src_dbname
  ,dst_queue_schema, dst_queue_name )
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROPAGATION_RECEIVER_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;


/*
create table STATS$PROPAGATION_RECEIVER
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,startup_time                   date          not null
,src_queue_name                 varchar2(66)  not null
,src_dbname                     varchar2(128) not null
,elapsed_unpickle_time          number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,constraint STATS$PROPAGATION_RECEIVER_PK primary key
  (snap_id, dbid, instance_number, src_queue_name, src_dbname)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROPAGATION_RECEIVER_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
*/

create public synonym STATS$PROPAGATION_RECEIVER for STATS$PROPAGATION_RECEIVER;


/* ------------------------------------------------------------------------- */

--
-- Buffered Queues

create table STATS$BUFFERED_QUEUES
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,startup_time                   date         not null
,num_msgs                       number
,cnum_msgs                      number
,cspill_msgs                    number
,constraint STATS$BUFFERED_QUEUES_PK primary key
  (snap_id, dbid, instance_number, queue_schema, queue_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$BUFFERED_QUEUES_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$BUFFERED_QUEUES for STATS$BUFFERED_QUEUES;

/* ------------------------------------------------------------------------- */

--
-- Buffered Subscribers
-- Joins to v$instance, dba_queues

create table STATS$BUFFERED_SUBSCRIBERS
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,subscriber_id                  number       not null 
,subscriber_name                varchar2(30) 
,subscriber_address             varchar2(1024)
,subscriber_type                varchar2(30)
,startup_time                   date         not null
,num_msgs                       number
,cnum_msgs                      number
,total_spilled_msg              number
,constraint STATS$BUFFERED_SUBSCRIBERS_PK primary key
  (snap_id, dbid, instance_number, queue_schema, queue_name, subscriber_id)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$BUFFERED_SUBSCRIBERS_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$BUFFERED_SUBSCRIBERS for STATS$BUFFERED_SUBSCRIBERS;

/* ------------------------------------------------------------------------- */

--
-- Rule Set

create table STATS$RULE_SET
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,owner                          varchar2(30) not null
,name                           varchar2(30) not null
,startup_time                   date         not null
,cpu_time                       number
,elapsed_time                   number
,evaluations                    number
,sql_free_evaluations           number
,sql_executions                 number
,reloads                        number
,constraint STATS$RULE_SET_PK primary key
  (snap_id, dbid, instance_number, owner, name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$RULE_SET_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$RULE_SET for STATS$RULE_SET;

/* ------------------------------------------------------------------------- */

--
-- OS Stat

create table STATS$OSSTAT
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,osstat_id                      number       not null
,stat_name                      varchar2(64)
,value                          number
,constraint STATS$OSSTAT_PK primary key
  (snap_id, dbid, instance_number, osstat_id)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$OSSTAT_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$OSSTAT for STATS$OSSTAT;

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels

insert into STATS$IDLE_EVENT (event) values ('wait for unread message on broadcast channel');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq Credit: send blkd');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Execute Reply');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Signal ACK');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deque wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq Credit: need buffer');
commit;
insert into stats$idle_event (event) values ('STREAMS apply coord waiting for slave message');
commit;
insert into stats$idle_event (event) values ('STREAMS apply slave waiting for coord message');
commit;
insert into stats$idle_event (event) values ('Queue Monitor Wait'); 
commit;
insert into stats$idle_event (event) values ('Queue Monitor Slave Wait'); 
commit;
insert into stats$idle_event (event) values ('wakeup event for builder'); 
commit;
insert into stats$idle_event (event) values ('wakeup event for preparer'); 
commit;
insert into stats$idle_event (event) values ('wakeup event for reader'); 
commit;
insert into stats$idle_event (event) values ('PX Deq: Par Recov Execute');
commit;
insert into stats$idle_event (event) values ('PX Deq: Table Q Sample');
commit;
insert into STATS$IDLE_EVENT (event) values ('STREAMS apply slave idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('STREAMS capture process filter callback wait for ruleset');
commit;
insert into STATS$IDLE_EVENT (event) values ('STREAMS fetch slave waiting for txns');
commit;
insert into STATS$IDLE_EVENT (event) values ('STREAMS waiting for subscribers to catch up');
commit;
insert into STATS$IDLE_EVENT (event) values ('Queue Monitor Shutdown Wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('AQ Proxy Cleanup Wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('knlqdeq');
commit;
insert into STATS$IDLE_EVENT (event) values ('wait for activate message');
commit;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check the log file of the package recreation, which is 
prompt in the file spcpkg.lis

spool off

/* ------------------------------------------------------------------------- */

--
-- Upgrade the package
@@spcpkg


--  End of Upgrade script
