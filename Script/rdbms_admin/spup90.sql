Rem
Rem $Header: rdbms/admin/spup90.sql /main/9 2010/04/20 10:50:41 kchou Exp $
Rem
Rem spup90.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spup90.sql - StatsPack UPgrade 90
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 9.2 schema format
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
Rem    kchou       04/20/10 - BUG# 9559470 Possible SQL Injection
Rem    kchou       04/08/10 - Security Fix: 2nd Order SQL Injections: Bug#
Rem                           9559470
Rem    cdialeri    03/02/04 - 3513994: 3473979, 3483751
Rem    vbarrier    04/01/02 - 2290728
Rem    vbarrier    03/20/02 - 2143634
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    cdialeri    02/07/02 - 2218573
Rem    cdialeri    01/30/02 - 2184717
Rem    cdialeri    01/11/02 - 9.2 - features 2
Rem    cdialeri    11/30/01 - Created - 9.2 - features 1
Rem

set verify off
set serveroutput on

/* ------------------------------------------------------------------------- */

prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 9.2 format may result in
prompt irregularities when reporting on pre-9.2 snapshot data.
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

spool spup90a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt


/* ------------------------------------------------------------------------- */

--
-- Create SYS views, public synonyms, issue grants


-- Recreate stats$v$sqlxs with new child_latch and fetches columns

create or replace view STATS$V_$SQLXS as 
select max(sql_text)        sql_text
     , sum(sharable_mem)    sharable_mem
     , sum(sorts)           sorts
     , min(module)          module
     , sum(loaded_versions) loaded_versions
     , sum(fetches)         fetches
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
     , max(child_latch)     child_latch
  from v$sql
 group by hash_value, address;

grant select on STATS$V_$SQLXS              to PERFSTAT;

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
  from x$kcbfwait   fw
     , v$tempstat   tm
     , v$tablespace ts
     , v$tempfile   tf
 where ts.ts#     = tf.ts#
   and tm.file#   = tf.file#
   and fw.indx+1  = (tf.file# + (select value from v$parameter where name='db_files'));

grant select on STATS$V_$TEMPSTATXS to PERFSTAT;

-- Issue grants for new views captured

grant select on V_$SHARED_POOL_ADVICE       to PERFSTAT;
grant select on V_$SQL_WORKAREA_HISTOGRAM   to PERFSTAT;
grant select on V_$PGA_TARGET_ADVICE        to PERFSTAT;
grant select on V_$SEGSTAT                  to PERFSTAT;
grant select on V_$SEGMENT_STATISTICS       to PERFSTAT;
grant select on V_$SEGSTAT_NAME             to PERFSTAT;


/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup90b.lis

spool off
connect perfstat/&&perfstat_password

spool spup90b.lis

show user

set verify off
set serveroutput on

/* ------------------------------------------------------------------------- */

--
-- Add new columns to sql_plan

alter table STATS$SQL_PLAN add
(search_columns       number
,access_predicates    varchar2(4000)
,filter_predicates    varchar2(4000)
);


/* ------------------------------------------------------------------------- */

--
-- Add new columns to sql_summary

alter table STATS$SQL_SUMMARY add
(fetches              number
,child_latch          number
);

/* ------------------------------------------------------------------------- */

--
-- Add new column to buffer cache advisory

alter table STATS$DB_CACHE_ADVICE add
(size_factor          number
);

/* ------------------------------------------------------------------------- */

-- 
-- Add support for shared pool advisory

create table STATS$SHARED_POOL_ADVICE
(snap_id                        number(6)  not null
,dbid                           number     not null
,instance_number                number     not null
,shared_pool_size_for_estimate  number     not null
,shared_pool_size_factor        number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_memory_object_hits     number
,constraint STATS$SHARED_POOL_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, shared_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SHARED_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SHARED_POOL_ADVICE  for STATS$SHARED_POOL_ADVICE;

/* ------------------------------------------------------------------------- */

--
--  Add support for new PGA memory management views

-- Histogram

create table STATS$SQL_WORKAREA_HISTOGRAM
(snap_id                        number(6)  not null
,dbid                           number     not null
,instance_number                number     not null
,low_optimal_size               number     not null
,high_optimal_size              number     not null
,optimal_executions             number
,onepass_executions             number
,multipasses_executions         number
,total_executions               number
,constraint STATS$SQL_WORKAREA_HIST_PK primary key 
     (snap_id, dbid, instance_number, low_optimal_size, high_optimal_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_WORKAREA_HIST_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_WORKAREA_HISTOGRAM  for STATS$SQL_WORKAREA_HISTOGRAM;


-- Advisory

create table STATS$PGA_TARGET_ADVICE
(snap_id                        number(6)  not null
,dbid                           number     not null
,instance_number                number     not null
,pga_target_for_estimate        number     not null
,pga_target_factor              number
,advice_status                  varchar2(3)
,bytes_processed                number
,estd_extra_bytes_rw            number
,estd_pga_cache_hit_percentage  number
,estd_overalloc_count           number
,constraint STATS$PGA_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, pga_target_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PGA_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$PGA_TARGET_ADVICE  for STATS$PGA_TARGET_ADVICE;

/* ------------------------------------------------------------------------- */
--
-- Use foreign key constraints instead of check constraints when possible

alter table STATS$STATSPACK_PARAMETER drop
constraint STATS$STATSPACK_LVL_CK;
alter table STATS$STATSPACK_PARAMETER add
constraint STATS$STATSPACK_LVL_FK
foreign key (snap_level) references STATS$LEVEL_DESCRIPTION;

alter table STATS$SNAPSHOT drop
constraint STATS$SNAPSHOT_LVL_CK;
alter table STATS$SNAPSHOT  add
constraint STATS$SNAPSHOT_LVL_FK
foreign key (snap_level) references STATS$LEVEL_DESCRIPTION;

/* ------------------------------------------------------------------------- */
--
--  Add support for new segment statistics views

-- Add new threshold columns

alter table STATS$STATSPACK_PARAMETER add
(seg_phy_reads_th     number
,seg_log_reads_th     number
,seg_buff_busy_th     number
,seg_rowlock_w_th     number
,seg_itl_waits_th     number
,seg_cr_bks_sd_th     number
,seg_cu_bks_sd_th     number
);

alter table STATS$SNAPSHOT  add
(seg_phy_reads_th     number
,seg_log_reads_th     number
,seg_buff_busy_th     number
,seg_rowlock_w_th     number
,seg_itl_waits_th     number
,seg_cr_bks_sd_th     number
,seg_cu_bks_sd_th     number
);

-- Set default threshold values

update stats$statspack_parameter set
seg_phy_reads_th	=	1000,
seg_log_reads_th	=	10000,
seg_buff_busy_th	=	100,
seg_rowlock_w_th	=	100,
seg_itl_waits_th        =       100,
seg_cr_bks_sd_th	=	1000,
seg_cu_bks_sd_th	=	1000;

alter table STATS$STATSPACK_PARAMETER modify
(seg_phy_reads_th	not null
,seg_log_reads_th	not null
,seg_buff_busy_th       not null
,seg_rowlock_w_th	not null
,seg_itl_waits_th       not null
,seg_cr_bks_sd_th 	not null 
,seg_cu_bks_sd_th 	not null 
);

-- New level 7 for segment statistics
-- Segment statistics without object names

create table STATS$SEG_STAT
(snap_id                         number(6)   not null
,dbid                            number      not null
,instance_number                 number      not null
,dataobj#                        number      not null
,obj#                            number      not null
,ts#                             number      not null
,logical_reads                   number
,buffer_busy_waits                number
,db_block_changes                number
,physical_reads                  number
,physical_writes                 number
,direct_physical_reads           number
,direct_physical_writes          number
,global_cache_cr_blocks_served   number
,global_cache_cu_blocks_served   number
,itl_waits                       number
,row_lock_waits                  number
, constraint STATS$SEG_STAT_PK primary key
   (snap_id, dbid, instance_number, dataobj#, obj#)
  using index tablespace &&tablespace_name
    storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SEG_STAT_FK foreign key
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
    storage (initial 3m next 3m pctincrease 0);

create public synonym STATS$SEG_STAT for STATS$SEG_STAT;

-- Segment names having statistics

create table STATS$SEG_STAT_OBJ
(dataobj#             number      not null
,obj#                 number      not null
,ts#                  number      not null
,dbid                 number      not null
,owner                varchar(30) not null
,object_name          varchar(30) not null
,subobject_name       varchar(30)
,object_type          varchar2(18)
,tablespace_name      varchar(30) not null
,constraint STATS$SEG_STAT_OBJ_PK primary key
  (dataobj#, obj#, dbid)
  using index tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0);

create public synonym STATS$SEG_STAT_OBJ for STATS$SEG_STAT_OBJ;

/* ------------------------------------------------------------------------- */

--
--  Support modified SQL Plan Usage capture

declare

  l_dbid            number;
  l_instance_number number;
  l_db_count        number := 0;
  l_instance_count  number := 0;
  l_dummy           varchar2(1);
  l_cursor          integer;
  l_sql             varchar2(2000);
  update_not_reqd   exception;

begin

  -- check to see if the PK and HV indexes exist

  select count(1)
    into l_dummy
    from dba_ind_columns
   where table_owner = 'PERFSTAT'
     and table_name  = 'STATS$SQL_PLAN_USAGE'
     and index_name  in ('STATS$SQL_PLAN_USAGE_PK','STATS$SQL_PLAN_USAGE_HV')
     and column_name in ('SNAP_ID','DBID','INSTANCE_NUMBER'
                        ,'HASH_VALUE','TEXT_SUBSET','PLAN_HASH_VALUE','COST');

   if l_dummy = 8 then
      -- The upgrade has been run successfully before - exit
      raise update_not_reqd;
   end if;

   dbms_output.put_line('Beginning upgrade of STATS$SQL_PLAN_USAGE');

   -- Check to see if old I1 index exists, if so, drop it
   select count(1)
     into l_dummy
     from dba_ind_columns
    where table_owner = 'PERFSTAT'
      and table_name  = 'STATS$SQL_PLAN_USAGE'
      and index_name  = 'STATS$SQL_PLAN_USAGE_I1'
      and column_name = 'SNAP_ID';

   l_cursor := dbms_sql.open_cursor;

   if l_dummy = 1 then

     -- old I1 index exists, drop it
     l_sql := 'drop index STATS$SQL_PLAN_USAGE_I1';
     dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
     dbms_output.put_line('.. Dropped I1 index');
 
   end if;

   -- Check to see if old PK index exists, if so, drop it

   select count(1)
     into l_dummy
     from dba_ind_columns
    where table_owner = 'PERFSTAT'
      and table_name  = 'STATS$SQL_PLAN_USAGE'
      and index_name  = 'STATS$SQL_PLAN_USAGE_PK'
      and column_name in ('SNAP_ID','DBID','INSTANCE_NUMBER'
                         ,'HASH_VALUE','TEXT_SUBSET','PLAN_HASH_VALUE','COST');

   if l_dummy = 4 then

     -- old PK index still here - drop
     l_sql := 'alter table STATS$SQL_PLAN_USAGE drop primary key drop index';
     dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
     dbms_output.put_line('.. Dropped PK');

   end if;

   -- Archive off the old table, if it doesn't already exist

   select count(1)
     into l_dummy
     from dba_tables
    where owner       = 'PERFSTAT'
      and table_name  = 'STATS$SQL_PLAN_USAGE_90';

   if l_dummy = 0 then

     -- table not archived previously
     l_sql := 'rename STATS$SQL_PLAN_USAGE to STATS$SQL_PLAN_USAGE_90';
     dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
     dbms_output.put_line('.. Archived original STATS$SQL_PLAN_USAGE table to  STATS$SQL_PLAN_USAGE_90');

   end if;


   -- Create new table, PK, FK

   l_sql := 'create table STATS$SQL_PLAN_USAGE
             (snap_id              number(6)        not null
             ,dbid                 number           not null
             ,instance_number      number           not null
             ,hash_value           number           not null
             ,text_subset          varchar2(31)     not null
             ,plan_hash_value      number           not null
             ,cost                 number
             ,address              raw(8)
             ,optimizer            varchar2(20)
             ,constraint STATS$SQL_PLAN_USAGE_PK primary key
              (snap_id, dbid, instance_number
              ,hash_value, text_subset, plan_hash_value, cost)
              using index tablespace &&tablespace_name
              storage (initial 1m next 1m pctincrease 0)
             ,constraint STATS$SQL_PLAN_USAGE_FK foreign key
              (snap_id, dbid, instance_number)
              references STATS$SNAPSHOT on delete cascade
             ) tablespace &&tablespace_name
             storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40';
   dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
   dbms_output.put_line('.. Created new STATS$SQL_PLAN_USAGE table');

   -- create HV index
   l_sql := 'create index STATS$SQL_PLAN_USAGE_HV ON STATS$SQL_PLAN_USAGE (hash_value)
             tablespace &&tablespace_name
             storage (initial 1m next 1m pctincrease 0)';
   dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
   dbms_output.put_line('.. Created new HV index');

   dbms_output.put_line('Upgrade of STATS$SQL_PLAN_USAGE complete');

exception
  when update_not_reqd then
    dbms_output.put_line('Upgrade of STATS$SQL_PLAN_USAGE not required - skipping');
  when others then
    rollback;
    raise;
end;
/


/* ------------------------------------------------------------------------- */

--
-- Add new level for segment statistics
insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (7,  'This level captures segment level statistics, including logical and physical reads, row lock, itl and buffer busy waits, along with all data captured by lower levels');
commit;

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels
insert into STATS$IDLE_EVENT (event) values ('gcs remote message');
commit;
insert into STATS$IDLE_EVENT (event) values ('gcs for action');
commit;
insert into STATS$IDLE_EVENT (event) values ('ges remote message');
commit;
insert into STATS$IDLE_EVENT (event) values ('queue messages');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Execution Msg');
commit;
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Table Q Normal');
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
