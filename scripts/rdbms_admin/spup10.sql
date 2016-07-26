Rem
Rem $Header: spup10.sql 31-may-2005.13:59:22 cdgreen Exp $
Rem
Rem spup10.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      spup10.sql - StatsPack UPgrade 10
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 10.2 schema
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
Rem    MODIFIED   (MM/DD/YY)
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     04/18/05 - 4228432
Rem    cdgreen     03/08/05 - 10gR2 misc 
Rem    vbarrier    02/18/05 - 4081984
Rem    cdgreen     10/29/04 - 10gR2_sqlstats
Rem    cdgreen     08/25/04 - 10g R2
Rem    cdialeri    03/25/04 - 3516921
Rem    vbarrier    03/12/04 - 3412853 
Rem    vbarrier    02/12/04 - Created
Rem
prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 10.2 format may result in
prompt irregularities when reporting on pre-10.2 snapshot data.
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

spool spup10a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt


/* ------------------------------------------------------------------------- */
--
-- Create SYS views, public synonyms, issue grants

-- Matching signature & last_active_time
create or replace view STATS$V_$SQLXS as
select max(sql_text)        sql_text
     , max(sql_id)          sql_id
     , sum(sharable_mem)    sharable_mem
     , sum(sorts)           sorts
     , min(module)          module
     , sum(loaded_versions) loaded_versions
     , sum(fetches)         fetches
     , sum(executions)      executions
     , sum(px_servers_executions) px_servers_executions
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
     , max(exact_matching_signature) exact_matching_signature
     , max(force_matching_signature) force_matching_signature
     , max(last_active_time)         last_active_time
  from v$sql
 group by old_hash_value, address;


create or replace view STATS$V_$SQLSTATS_SUMMARY as
select sql_id
     , sum(parse_calls)           parse_calls
     , sum(disk_reads)            disk_reads
     , sum(buffer_gets)           buffer_gets
     , sum(executions)            executions
     , sum(version_count)         version_count
     , sum(cpu_time)              cpu_time
     , sum(elapsed_time)          elapsed_time
     , sum(sharable_mem)          sharable_mem
  from v$sqlstats
 group by sql_id;
create or replace public synonym STATS$V$SQLSTATS_SUMMARY for STATS$V_$SQLSTATS_SUMMARY;
grant select on STATS$V_$SQLSTATS_SUMMARY    to PERFSTAT;


--
-- Workaround for Remaster Stats bug 4029107
create or replace view STATS$V_$DYNAMIC_REM_STATS as
select drms                  remaster_ops
     , avg_drm_time*drms     remaster_time
     , objects_per_drm*drms  remastered_objects
     , quisce_t*drms         quiesce_time
     , frz_t*drms            freeze_time
     , cleanup_t*drms        cleanup_time
     , replay_t*drms         replay_time
     , fixwrite_t*drms       fixwrite_time
     , sync_t*drms           sync_time
     , res_cleaned*drms      resources_cleaned
     , replay_s*drms         replayed_locks_sent
     , replay_r*drms         replayed_locks_received
     , my_objects            current_objects
  from x$kjdrmafnstats;
grant select on STATS$V_$DYNAMIC_REM_STATS to PERFSTAT;
create synonym PERFSTAT.V$DYNAMIC_REMASTER_STATS for STATS$V_$DYNAMIC_REM_STATS;


grant  select on V_$PROCESS                   to PERFSTAT;
grant  select on V_$PROCESS_MEMORY            to PERFSTAT;
grant  select on V_$STREAMS_POOL_ADVICE       to PERFSTAT;
grant  select on V_$SGA_TARGET_ADVICE         to PERFSTAT;
grant  select on V_$INSTANCE_CACHE_TRANSFER   to PERFSTAT;
grant  select on V_$SQLSTATS                  to PERFSTAT;
grant  select on V_$MUTEX_SLEEP               to PERFSTAT;

revoke select on DBA_QUEUE_SCHEDULES        from PERFSTAT;


/* ------------------------------------------------------------------------- */

-- 
-- Remove Streams 10gR1 workarounds

drop view      STATS$V_$PROPAGATION_SENDER;
drop synonym PERFSTAT.V$PROPAGATION_SENDER;
drop view      STATS$V_$PROPAGATION_RECEIVER;
drop synonym PERFSTAT.V$PROPAGATION_RECEIVER;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup10b.lis

spool off
connect perfstat/&&perfstat_password

spool spup10b.lis

show user

set verify off
set serveroutput on size 4000


/* ------------------------------------------------------------------------- */

-- 
-- Remove deprecated class_cache_transfer ...

drop table          STATS$CLASS_CACHE_TRANSFER;
drop public synonym STATS$CLASS_CACHE_TRANSFER;

-- 
-- ... and Add instance_cache_transfer

create table STATS$INSTANCE_CACHE_TRANSFER
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,instance                 number          not null
,class                    varchar2(18)    not null
,cr_block                 number
,cr_busy                  number
,cr_congested             number
,current_block            number
,current_busy             number
,current_congested        number
,constraint STATS$INST_CACHE_TRANSFER_PK primary key
    (snap_id, dbid, instance_number, instance, class)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INST_CACHE_TRANSFER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INSTANCE_CACHE_TRANSFER  for STATS$INSTANCE_CACHE_TRANSFER;

/* ------------------------------------------------------------------------- */

-- Process Memory support

--
-- Process - Rollup

create table STATS$PROCESS_ROLLUP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,pid                            number       not null
,serial#                        number       not null
,spid                           varchar2(12)
,program                        varchar2(48)
,background                     varchar2(1)
,pga_used_mem                   number
,pga_alloc_mem                  number
,pga_freeable_mem               number
,max_pga_alloc_mem              number
,max_pga_max_mem                number
,avg_pga_alloc_mem              number
,stddev_pga_alloc_mem           number
,num_processes                  number
,constraint STATS$$PROCESS_ROLLUP_PK primary key
  (snap_id, dbid, instance_number, pid, serial#)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$$PROCESS_ROLLUP_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROCESS_ROLLUP for STATS$PROCESS_ROLLUP;


--
-- Process Memory

create table STATS$PROCESS_MEMORY_ROLLUP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,pid                            number       not null
,serial#                        number       not null
,category                       varchar2(15) not null
,allocated                      number
,used                           number
,max_allocated                  number
,max_max_allocated              number
,avg_allocated                  number
,stddev_allocated               number
,non_zero_allocations           number
,constraint STATS$PROCESS_MEMORY_ROLLUP_PK primary key
  (snap_id, dbid, instance_number, pid, serial#, category)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROCESS_MEMORY_ROLLUP_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROCESS_MEMORY_ROLLUP for STATS$PROCESS_MEMORY_ROLLUP;

/* ------------------------------------------------------------------------- */

-- New columns in db_cache_advice

alter table stats$db_cache_advice add
(estd_cluster_reads            number
,estd_cluster_read_time        number
);

/* ------------------------------------------------------------------------- */

-- SQL matching signature

alter table stats$sql_summary add
(px_servers_executions    number
,exact_matching_signature number
,force_matching_signature number
,last_active_time         date
);

/* ------------------------------------------------------------------------- */

-- Modify SQL Plan

alter table stats$sql_plan modify
(object_owner         varchar2(31));


/* ------------------------------------------------------------------------- */

-- Modify SQL Plan Usage

alter table stats$sql_plan_usage add
(last_active_time     date
);


/* ------------------------------------------------------------------------- */

-- Add average cursor size

alter table stats$sql_statistics add
(total_cursors        number
);

/* ------------------------------------------------------------------------- */

-- New SGA Advisory

create table STATS$SGA_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,sga_size                       number     not null
,sga_size_factor                number
,estd_db_time                   number
,estd_db_time_factor            number
,estd_physical_reads            number
,constraint STATS$SGA_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, sga_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SGA_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SGA_TARGET_ADVICE  for STATS$SGA_TARGET_ADVICE;

/* ------------------------------------------------------------------------- */

create table STATS$STREAMS_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,streams_pool_size_for_estimate number     not null
,streams_pool_size_factor       number
,estd_spill_count               number
,estd_spill_time                number
,estd_unspill_count             number
,estd_unspill_time              number
,constraint STATS$STREAMS_POOL_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, streams_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$STREAMS_POOL_ADVICE  for STATS$STREAMS_POOL_ADVICE;

/* ------------------------------------------------------------------------- */

-- Statspack params

alter table stats$statspack_parameter add (old_sql_capture_mth varchar2(10));
update stats$statspack_parameter set old_sql_capture_mth = 'FALSE';
alter table stats$statspack_parameter modify (old_sql_capture_mth not null);
alter table stats$statspack_parameter add constraint
 STATS$STATSPACK_SQL_MTH_CK
    check (old_sql_capture_mth in ('TRUE','FALSE'));


/* ------------------------------------------------------------------------- */

-- Statspack capture time

alter table stats$snapshot add (snapshot_exec_time_s number);


/* ------------------------------------------------------------------------- */

-- Normalize!! OS Stat

create table STATS$OSSTATNAME
(osstat_id              number       not null
,stat_name              varchar2(64) not null
,constraint STATS$OSSSTATNAME_PK primary key
     (osstat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$OSSTATNAME  for STATS$OSSTATNAME;

-- Remove redundant name from OSStat
alter table stats$osstat drop column stat_name;

/* ------------------------------------------------------------------------- */

-- 
-- Modify primary key for segment statistics tables ...

declare

  l_dummy          integer;
  update_not_reqd  exception;

begin

  -- check STATS$SEG_STAT
  begin

    -- check if PK index exists
    select count(1)
      into l_dummy
      from user_ind_columns
     where table_name = 'STATS$SEG_STAT'
       and index_name = 'STATS$SEG_STAT_PK'
       and column_name in ('SNAP_ID','DBID','INSTANCE_NUMBER'
                          ,'DATAOBJ#','OBJ#','TS#');

    if l_dummy = 6 then

      -- PK is ok
      raise update_not_reqd;

    elsif l_dummy > 0 then

      -- old PK index still here - drop
      execute immediate 'alter table STATS$SEG_STAT drop primary key drop index';

    elsif l_dummy = 0 then

      -- check if PK constraint still here (may have been disabled)
      select count(1) 
        into l_dummy
        from user_constraints
       where table_name      = 'STATS$SEG_STAT'
         and constraint_type = 'P';

      if l_dummy = 1 then

        -- PK constraint still here - drop
        execute immediate 'alter table STATS$SEG_STAT drop primary key';

      end if;

    end if;

    -- Create new PK
    execute immediate 'alter table STATS$SEG_STAT
                           add constraint STATS$SEG_STAT_PK
                             primary key (snap_id, dbid, instance_number, dataobj#, obj#, ts#)
                               using index tablespace &&tablespace_name
                                 storage (initial 1m next 1m pctincrease 0)';
    
  exception

    when update_not_reqd then
      dbms_output.put_line('Upgrade of STATS$SEG_STAT not required - skipping');

  end;

  -- check STATS$SEG_STAT_OBJ
  begin

    -- check to see if the PK index exist
    select count(1)
      into l_dummy
      from user_ind_columns
     where table_name = 'STATS$SEG_STAT_OBJ'
       and index_name = 'STATS$SEG_STAT_OBJ_PK'
       and column_name in ('DBID','DATAOBJ#','OBJ#','TS#');

    if l_dummy = 4 then

      -- PK is ok
      raise update_not_reqd;

    elsif l_dummy > 0 then

      -- old PK index still here - drop
      execute immediate 'alter table STATS$SEG_STAT_OBJ drop primary key drop index';

    elsif l_dummy = 0 then

      -- check if PK constraint still here (may have been disabled)
      select count(1) 
        into l_dummy
        from user_constraints
       where table_name      = 'STATS$SEG_STAT_OBJ'
         and constraint_type = 'P';

      if l_dummy = 1 then

        -- PK constraint still here - drop
        execute immediate 'alter table STATS$SEG_STAT_OBJ drop primary key';

      end if;

    end if;

    -- Create new PK
    execute immediate 'alter table STATS$SEG_STAT_OBJ
                           add constraint STATS$SEG_STAT_OBJ_PK
                             primary key (dataobj#, obj#, ts#, dbid)
                               using index tablespace &&tablespace_name
                                 storage (initial 1m next 1m pctincrease 0)';
    
  exception

    when update_not_reqd then
      dbms_output.put_line('Upgrade of STATS$SEG_STAT_OBJ not required - skipping');

  end;

end;
/

/* ------------------------------------------------------------------------- */

create table STATS$DYNAMIC_REMASTER_STATS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,remaster_ops                   number
,remaster_time                  number
,remastered_objects             number
,quiesce_time                   number
,freeze_time                    number
,cleanup_time                   number
,replay_time                    number
,fixwrite_time                  number
,sync_time                      number
,resources_cleaned              number
,replayed_locks_sent            number
,replayed_locks_received        number
,current_objects                number
,constraint STATS$DYNAMIC_REM_STATS_PK primary key 
     (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DYNAMIC_REM_STATS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$DYNAMIC_REMASTER_STATS  for STATS$DYNAMIC_REMASTER_STATS;


/* ------------------------------------------------------------------------- */

create table STATS$MUTEX_SLEEP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,mutex_type                     varchar2(32) not null
,location                       varchar2(40) not null
,sleeps                         number
,wait_time                      number
,constraint STATS$MUTEX_SLEEP_PK primary key 
     (snap_id, dbid, instance_number, mutex_type, location)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MUTEX_SLEEP_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$MUTEX_SLEEP  for STATS$MUTEX_SLEEP;

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels
insert into STATS$IDLE_EVENT (event) values ('ASM background timer');
commit;
insert into STATS$IDLE_EVENT (event) values ('KSV master wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('class slave wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('master wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('DIAG idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: qmn coordinator idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: waiting for time management or cleanup tasks');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: qmn slave idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: RAC qmn coordinator idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams fetch slave: waiting for txns');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: waiting for messages in the queue');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: deallocate messages from Streams Pool');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: delete acknowledged messages');
commit;
insert into STATS$IDLE_EVENT (event) values ('EMON idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC archive log');
commit;
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC dest activation');
commit;
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC end of log');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: client waiting for transaction');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: slave waiting for activate message');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for builder');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for preparer');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for reader');
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
