Rem
Rem $Header: rdbms/admin/spup817.sql /main/7 2010/04/20 10:50:41 kchou Exp $
Rem
Rem spup817.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spup817.sql -  8.1.7 to 9.0 upgrade script
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 9.0 schema format
Rem
Rem    USAGE
Rem      Export the Statspack schema before running this upgrade,
Rem      as this is the only way to restore the existing data.
Rem      A downgrade script is not provided.
Rem
Rem      Disable any scripts which use Statspack while the upgrade script
Rem      is running.
Rem
Rem      If you have significant amount of data in the PERFSTAT schema,
Rem      consider altering the session to use a large rollback segment.
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
Rem    kchou       04/20/10 - BUG# 9559470 Possible SQL Injection
Rem    kchou       04/08/10 - Security Fix: 2nd Order SQL Injections: Bug#
Rem                           9559470
Rem    cdialeri    03/02/04 - 3513994: 3473979, 3483751
Rem    cdialeri    04/26/01 - 9.0
Rem    cdialeri    04/21/01 - Split log files
Rem    cdialeri    04/05/01 - Created
Rem

set verify off

/* ------------------------------------------------------------------------- */

prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 9.0 format may result in
prompt irregularities when reporting on pre-9.0 snapshot data.
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
prompt If you have a significant amount of data in the PERFSTAT schema, 
prompt consider using a large rollback segment, and specifying a large
prompt sort_area_size - you will be prompted for both below.
prompt
prompt You will also be prompted for the PERFSTAT password, and for the 
prompt tablespace to create any new PERFSTAT tables/indexes.
prompt
prompt You must be connected as a user with SYSDBA privilege to successfully
prompt run this script.
prompt
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup817a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt
prompt If you would like to use a large sort_area_size, specify the size in BYTES
prompt (e.g. 1048576), or press return to use the default sort_area_size.
prompt sort_area_size of &&sort_area_size specified
prompt
prompt If you would like to use a large rollback segment, ensure this rollback 
prompt segment is online.  Specify the segment name, or press return to use any
prompt rollback segment.  
prompt Rollback segment &&large_rollback_segment specified
prompt


/* ------------------------------------------------------------------------- */

--
--  Rename statspack views to STATS$V$ from V$

-- Do not drop X_$ views for KCBFWAIT, KSPPSV, KSPPI or KSQST
-- as these may overlap with those in catsnmp.sql. 

-- drop view           X_$KCBFWAIT;
-- drop public synonym  X$KCBFWAIT;
-- drop view           X_$KSPPSV;
-- drop public synonym  X$KSPPSV;
-- drop view           X_$KSPPI;
-- drop public synonym  X$KSPPI;
-- drop view           X_$KSQST;
-- drop public synonym  X$KSQST;

-- Create views, grants, public synonyms
-- Do not recreate ksqst (replaced by enqueue_stat)

drop view             STATS$X_$KCBFWAIT;
create view           STATS$X_$KCBFWAIT as select * from        X$KCBFWAIT;
grant select on       STATS$X_$KCBFWAIT to PERFSTAT;
drop public synonym    STATS$X$KCBFWAIT;
create public synonym  STATS$X$KCBFWAIT for              STATS$X_$KCBFWAIT;
drop view             STATS$X_$KSPPSV ;
create view           STATS$X_$KSPPSV   as select * from        X$KSPPSV;
grant select on       STATS$X_$KSPPSV   to PERFSTAT;
drop public synonym    STATS$X$KSPPSV;
create public synonym  STATS$X$KSPPSV   for              STATS$X_$KSPPSV;
drop view             STATS$X_$KSPPI;
create view           STATS$X_$KSPPI    as select * from        X$KSPPI;
grant select on       STATS$X_$KSPPI    to PERFSTAT;
drop public synonym    STATS$X$KSPPI;
create public synonym  STATS$X$KSPPI    for              STATS$X_$KSPPI;


/* ------------------------------------------------------------------------- */

--
-- Recreate FILESTAT TEMPSTATXS views to include new columns


-- FILESTAT

-- drop public synonym  V$FILESTATXS;
-- drop view           V_$FILESTATXS;

drop view   STATS$V_$FILESTATXS;
create view STATS$V_$FILESTATXS as
select ts.name      tsname
     , df.name	    filename
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
  from x$kcbfwait   fw
     , v$filestat   fs
     , v$tablespace ts
     , v$datafile   df
 where ts.ts#    = df.ts#
   and fs.file#  = df.file#
   and fw.indx+1 = df.file#;

drop public synonym    STATS$V$FILESTATXS;
create public synonym  STATS$V$FILESTATXS for STATS$V_$FILESTATXS;
grant select on       STATS$V_$FILESTATXS to PERFSTAT;


-- TEMPSTAT

-- drop public synonym  V$TEMPSTATXS;
-- drop view           V_$TEMPSTATXS;

drop view   STATS$V_$TEMPSTATXS;
create view STATS$V_$TEMPSTATXS as
select ts.name      tsname
     , tf.name	    filename
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
  from x$kcbfwait   fw
     , v$tempstat   tm
     , v$tablespace ts
     , v$tempfile   tf
 where ts.ts#     = tf.ts#
   and tm.file#   = tf.file#
   and fw.indx+1  = (tf.file# + (select value from v$parameter where name='db_files'));

drop public synonym    STATS$V$TEMPSTATXS;
create public synonym  STATS$V$TEMPSTATXS for STATS$V_$TEMPSTATXS;
grant select on       STATS$V_$TEMPSTATXS to PERFSTAT;


/* ------------------------------------------------------------------------- */

--
-- Add new columns to SQLXS

-- drop public synonym  V$SQLXS;
-- drop view           V_$SQLXS;

drop view   STATS$V_$SQLXS;
create view STATS$V_$SQLXS as 
select max(sql_text)        sql_text
     , sum(sharable_mem)    sharable_mem
     , sum(sorts)           sorts
     , min(module)          module
     , sum(loaded_versions) loaded_versions
     , sum(executions)      executions
     , sum(loads)           loads
     , sum(invalidations)   invalidations
     , sum(parse_calls)     parse_calls
     , sum(disk_reads)      disk_reads
     , sum(buffer_gets)     buffer_gets
     , sum(rows_processed)  rows_processed
     , max(command_type)    command_type
     , address              address
     , hash_value           hash_value
     , count(1)             version_count
     , sum(cpu_time)        cpu_time
     , sum(elapsed_time)    elapsed_time
     , max(outline_sid)     outline_sid
     , max(outline_category) outline_category
     , max(is_obsolete)     is_obsolete
  from v$sql
 group by hash_value, address;

drop public synonym   STATS$V$SQLXS;
create public synonym STATS$V$SQLXS for STATS$V_$SQLXS; 
grant select on      STATS$V_$SQLXS to PERFSTAT;


/* ------------------------------------------------------------------------- */

--
--  Grant PERFSTAT select on new V$ views

grant select on V_$ENQUEUE_STAT   to PERFSTAT;
grant select on V_$RESOURCE_LIMIT to PERFSTAT;
grant select on V_$DLM_MISC       to PERFSTAT;
grant select on V_$UNDOSTAT       to PERFSTAT;
grant select on V_$SQL_PLAN       to PERFSTAT;
grant select on V_$DB_CACHE_ADVICE   to PERFSTAT;
grant select on V_$PGASTAT           to PERFSTAT;
grant select on V_$INSTANCE_RECOVERY to PERFSTAT;


/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup817b.lis

spool off
connect perfstat/&&perfstat_password

spool spup817b.lis

show user

alter session set sort_area_size = &&sort_area_size;


/* ------------------------------------------------------------------------- */

--
-- Add support for buffer cache advisory

create table          STATS$DB_CACHE_ADVICE
(snap_id              number(6)       not null
,dbid                 number          not null
,instance_number      number          not null
,id                   number          not null
,name                 varchar2(20)    not null
,block_size           number          not null
,buffers_for_estimate number          not null
,advice_status        varchar2(3)
,size_for_estimate    number
,estd_physical_read_factor number
,estd_physical_reads  number
,constraint STATS$DB_CACHE_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, id, buffers_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DB_CACHE_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$DB_CACHE_ADVICE  for STATS$DB_CACHE_ADVICE;


/* ------------------------------------------------------------------------- */

--
-- Add support for instance recovery stats

create table          STATS$INSTANCE_RECOVERY
(snap_id                          number(6)        not null
,dbid                             number           not null
,instance_number                  number           not null
,recovery_estimated_ios           number
,actual_redo_blks                 number
,target_redo_blks                 number
,log_file_size_redo_blks          number
,log_chkpt_timeout_redo_blks      number
,log_chkpt_interval_redo_blks     number
,fast_start_io_target_redo_blks   number
,target_mttr                      number
,estimated_mttr                   number
,ckpt_block_writes                number
,constraint STATS$INSTANCE_RECOVERY_PK primary key 
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INSTANCE_RECOVERY_FK foreign key 
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INSTANCE_RECOVERY  for STATS$INSTANCE_RECOVERY;


/* ------------------------------------------------------------------------- */

--
-- Add corresponding columns to stats$ filestat and tempstat tables

alter table STATS$FILESTATXS add 
(singleblkrds         number
,singleblkrdtim       number
);

alter table STATS$TEMPSTATXS add 
(singleblkrds         number
,singleblkrdtim       number
);

/* ------------------------------------------------------------------------- */

--
-- Add wait_time to latch tables

alter table STATS$LATCH add 
(wait_time            number
);

alter table STATS$LATCH_CHILDREN add 
(wait_time            number
);

alter table STATS$LATCH_PARENT add 
(wait_time            number
);


/* ------------------------------------------------------------------------- */

--
-- Add support for multiple sized buffer pools

alter table STATS$BUFFER_POOL_STATISTICS add
(block_size              number
);

-- Update the existing rows

set transaction use rollback segment &&large_rollback_segment;

update stats$buffer_pool_statistics bps set
  block_size = (select value
                  from stats$parameter p
                 where p.name            = 'db_block_size'
                   and p.dbid            = bps.dbid
                   and p.instance_number = bps.instance_number
                   and rownum < 2
               )
 where block_size is null;

commit;


/* ------------------------------------------------------------------------- */

--
-- Create new Enqueue statistics table

create table          STATS$ENQUEUE_STAT
(snap_id              number(6)        not null
,dbid                 number           not null
,instance_number      number           not null
,eq_type              varchar2(2)      not null
,total_req#           number
,total_wait#          number
,succ_req#            number
,failed_req#          number
,cum_wait_time        number 
,constraint STATS$ENQUEUE_STAT_PK primary key 
    (snap_id, dbid, instance_number, eq_type)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$ENQUEUE_STAT_FK foreign key (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$ENQUEUE_STAT  for STATS$ENQUEUE_STAT;


-- Copy over the existing data into the new structure
-- The data does not correspond exactly 1-1, but it is close enough
-- for the conversion.

set transaction use rollback segment &&large_rollback_segment;

insert into stats$enqueue_stat
     ( snap_id
     , dbid
     , instance_number
     , eq_type
     , total_req#
     , total_wait#
     )
select snap_id
     , dbid
     , instance_number
     , name
     , gets
     , waits
  from stats$enqueuestat;

commit;

drop public synonym STATS$ENQUEUESTAT;
drop table          STATS$ENQUEUESTAT;


/* ------------------------------------------------------------------------- */

--
-- Recreate primary key for stats$sql_summary

alter table STATS$SQL_SUMMARY drop primary key drop index;

alter table STATS$SQL_SUMMARY add constraint STATS$SQL_SUMMARY_PK primary key
 (snap_id, dbid, instance_number, hash_value, text_subset)
 using index
   tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0);

--
-- Add new columns

alter table STATS$SQL_SUMMARY add
(command_type         number
,cpu_time             number
,elapsed_time         number
,outline_sid          number
,outline_category     varchar2(64) 
);


/* ------------------------------------------------------------------------- */

--
-- Add support for resource limits

create table          STATS$RESOURCE_LIMIT
(snap_id              number(6)        not null
,dbid                 number           not null
,instance_number      number           not null
,resource_name        varchar2(30)     not null
,current_utilization  number
,max_utilization      number
,initial_allocation   varchar2(10)
,limit_value          varchar2(10)
,constraint STATS$RESOURCE_LIMIT_PK primary key
    (snap_id, dbid, instance_number, resource_name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$RESOURCE_LIMIT_FK foreign key
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$RESOURCE_LIMIT  for STATS$RESOURCE_LIMIT;


/* ------------------------------------------------------------------------- */

--
-- Add support for OPS specific statistics

create table STATS$DLM_MISC
(snap_id              number(6)       not null
,dbid                 number          not null
,instance_number      number          not null
,statistic#           number          not null
,name                 varchar2(38)
,value                number
,constraint STATS$DLM_MISC_PK primary key
    (snap_id, dbid, instance_number, statistic#)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DLM_MISC_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$DLM_MISC  for STATS$DLM_MISC;


/* ------------------------------------------------------------------------- */

--
-- Add support for automatic undo management

create table STATS$UNDOSTAT
(begin_time           date            not null
,end_time             date            not null
,dbid                 number          not null
,instance_number      number          not null
,snap_id              number(6)       not null
,undotsn              number          not null
,undoblks             number
,txncount             number
,maxquerylen          number
,maxconcurrency       number
,unxpstealcnt         number
,unxpblkrelcnt        number
,unxpblkreucnt        number
,expstealcnt          number
,expblkrelcnt         number
,expblkreucnt         number
,ssolderrcnt          number
,nospaceerrcnt        number
,constraint STATS$UNDOSTAT_PK primary key
    (begin_time, end_time, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$UNDOSTAT  for STATS$UNDOSTAT;


/* ------------------------------------------------------------------------- */

--
--  Add support for capturing SQL Plans (sql_plan and sql_plan_usage)


-- SQL_PLAN_USAGE

create table STATS$SQL_PLAN_USAGE
(hash_value           number          not null
,text_subset          varchar2(31)    not null
,plan_hash_value      number          not null
,snap_id              number          not null
,cost                 number
,address              raw(8)
,optimizer            varchar2(20)
,constraint STATS$SQL_PLAN_USAGE_PK primary key
    (hash_value, text_subset, plan_hash_value, cost)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create index STATS$SQL_PLAN_USAGE_I1 on STATS$SQL_PLAN_USAGE (snap_id)
  tablespace &&tablespace_name storage (initial 1m next 1m pctincrease 0);

create public synonym  STATS$SQL_PLAN_USAGE  for STATS$SQL_PLAN_USAGE;


-- SQL_PLAN

create table STATS$SQL_PLAN
(plan_hash_value      number          not null
,id                   number          not null
,operation            varchar2(30)
,options              varchar2(30)
,object_node          varchar2(10)
,object#              number
,object_owner         varchar2(30)
,object_name          varchar2(30)
,optimizer            varchar2(20)
,parent_id            number
,depth                number
,position             number
,cost                 number
,cardinality          number
,bytes                number
,other_tag            varchar2(35)
,partition_start      varchar2(5)
,partition_stop       varchar2(5)
,partition_id         number
,other                varchar2(4000)
,distribution         varchar2(20)
,cpu_cost             number
,io_cost              number
,temp_space           number
,snap_id              number
,constraint STATS$SQL_PLAN_PK primary key
    (plan_hash_value, id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_PLAN  for STATS$SQL_PLAN;


/* ------------------------------------------------------------------------- */

--
--  Support for automatic PGA memory management

create table STATS$PGASTAT
(snap_id              number(6)       not null
,dbid                 number          not null
,instance_number      number          not null
,name                 varchar2(64)    not null
,value                number
,constraint STATS$SQL_PGASTAT_PK primary key
    (snap_id, dbid, instance_number, name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_PGASTAT_FK foreign key
     (snap_id, dbid, instance_number)
     references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$PGASTAT  for STATS$PGASTAT;


/* ------------------------------------------------------------------------- */

--
-- Add support for the new snap level

alter table STATS$STATSPACK_PARAMETER drop constraint
  STATS$STATSPACK_LVL_CK;
alter table STATS$STATSPACK_PARAMETER add  constraint 
  STATS$STATSPACK_LVL_CK check (snap_level in (0, 5, 6, 10));

alter table STATS$SNAPSHOT drop constraint
  STATS$SNAPSHOT_LVL_CK;
alter table STATS$SNAPSHOT add  constraint 
  STATS$SNAPSHOT_LVL_CK check (snap_level in (0, 5, 6, 10));


/* ------------------------------------------------------------------------- */

--
-- Add support for microsecond Event timing

alter table STATS$SYSTEM_EVENT add
 (time_waited_micro    number);

alter table STATS$SESSION_EVENT add
 (time_waited_micro    number);

alter table STATS$BG_EVENT_SUMMARY add
 (time_waited_micro    number);

set transaction use rollback segment &&large_rollback_segment;

update STATS$SYSTEM_EVENT set
       time_waited_micro = time_waited * 10000
     , time_waited       = null
 where time_waited_micro is null;

update STATS$SESSION_EVENT set
       time_waited_micro = time_waited * 10000
     , time_waited       = null
 where time_waited_micro is null;

update STATS$BG_EVENT_SUMMARY set
       time_waited_micro = time_waited * 10000
     , time_waited       = null
 where time_waited_micro is null;

commit;

alter table STATS$SYSTEM_EVENT     drop column time_waited;
alter table STATS$SESSION_EVENT    drop column time_waited;
alter table STATS$BG_EVENT_SUMMARY drop column time_waited;


/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels

insert into STATS$IDLE_EVENT (event) values ('slave wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('i/o slave wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('jobq slave wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('null event');
commit;

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (6,  'This level includes capturing SQL plan and SQL plan usage information for high resource usage SQL Statements, along with all data captured by lower levels');

commit;


/* ------------------------------------------------------------------------- */

--
--  Revoke select privileges on statspack objects granted to PUBLIC

declare
sqlstr varchar2(128);
begin
  for tbnam in (select atp.table_name
                  from all_tab_privs atp
                     , all_tables    at
                 where atp.privilege    = 'SELECT' 
                   and atp.table_schema = 'PERFSTAT'
                   and atp.grantee      = 'PUBLIC'
                   and at.table_name    = atp.table_name
                   and at.owner         = atp.table_schema
                   and at.dropped       = 'NO')
  loop
    -- XXX kchou 4/20/2010 BUG# 9559470 POSSIBLE SQL INJECTION
    -- sqlstr := 'revoke select on perfstat.'||tbnam.table_name||' from public';
    sqlstr := 
      'revoke select on perfstat.' || dbms_assert.enquote_name(tbnam.table_name, FALSE) || ' FROM PUBLIC';
    execute immediate sqlstr;
  end loop;
end;
/

prompt Note:
prompt Please check the log file of the package recreation, which is 
prompt in the file spcpkg.lis

spool off


/* ------------------------------------------------------------------------- */

--
-- Upgrade the package
@@spcpkg


--  End of Upgrade script
