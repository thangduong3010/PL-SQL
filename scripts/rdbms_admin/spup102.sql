Rem
Rem $Header: spup102.sql 22-jun-2007.13:52:09 cdgreen Exp $
Rem
Rem spup102.sql
Rem
Rem Copyright (c) 2005, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      spup102.sql - StatsPack UPgrade 10.2
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 11 schema
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
Rem    shsong      06/14/07 - Add idle events
Rem    cdgreen     03/14/07 - 11 F2
Rem    cdgreen     03/02/07 - use _FG for v$system_event
Rem    cdgreen     02/28/07 - 5908354
Rem    cdgreen     04/26/06 - 11 F1 
Rem    cdgreen     06/26/06 - Increase column length 
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     08/23/05 - cdgreen_bug-4562627
Rem    cdgreen     08/22/05 - Created
Rem
prompt
prompt Statspack Upgrade script
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 11 format may result in
prompt irregularities when reporting on pre-11 snapshot data.
prompt
prompt This script is provided for convenience, and is not guaranteed to 
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  Please see spdoc.txt for more details.
prompt
accept confirmation prompt "Press return before continuing ";
prompt
prompt Usage
prompt ~~~~~
prompt -> Disable any programs which run Statspack (including any dbms_jobs),
prompt    before continuing, or this upgrade will fail.
prompt
prompt -> You MUST be connected as a user with SYSDBA privilege to successfully
prompt    run this script.
prompt
prompt -> You will be prompted for the PERFSTAT password, and for the 
prompt    tablespace to create any new PERFSTAT tables/indexes.
prompt
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup102a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt


/* ------------------------------------------------------------------------- */
--
-- Create SYS views, public synonyms, issue grants

-- Remove Remaster Stats 10gR2 workaround
drop view      STATS$V_$DYNAMIC_REM_STATS;
drop synonym PERFSTAT.V$DYNAMIC_REMASTER_STATS;

--
-- Interconnect pings
create or replace view STATS$X_$KSXPPING as select * from X$KSXPPING;
create or replace public synonym STATS$X$KSXPPING for STATS$X_$KSXPPING;

-- 
-- Recreate sqlxs
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
     , null                 avg_hard_parse_time
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

-- grants
grant create view to PERFSTAT;
grant select on V_$DYNAMIC_REMASTER_STATS    to PERFSTAT;
grant select on V_$IOSTAT_FUNCTION           to PERFSTAT;
grant select on V_$IOSTAT_FILE               to PERFSTAT;
grant select on V_$MEMORY_TARGET_ADVICE      to PERFSTAT;
grant select on V_$MEMORY_RESIZE_OPS         to PERFSTAT;
grant select on V_$MEMORY_DYNAMIC_COMPONENTS to PERFSTAT;
grant select on STATS$X_$KSXPPING            to PERFSTAT;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup102b.lis

spool off
connect perfstat/&&perfstat_password

spool spup102b.lis

show user

set verify off
set serveroutput on size 4000

/* ------------------------------------------------------------------------- */

-- 
-- Increase column length for value in stats$sql_plan
alter table stats$sql_plan  modify ( partition_start varchar2(64)
                                   , partition_stop  varchar2(64));

/* ------------------------------------------------------------------------- */

-- 
-- Increase column length for value in stats$sql_plan
alter table stats$database_instance  add (platform_name   varchar2(101));


/* ------------------------------------------------------------------------- */

--
-- PGA target advice
alter table stats$pga_target_advice add
(estd_time number
);


/* ------------------------------------------------------------------------- */

-- 
-- Increase column length for value in stats$parameter

alter table stats$parameter modify (value varchar2(4000));

/* ------------------------------------------------------------------------- */

-- Hard parse time

alter table stats$sql_summary add
(AVG_HARD_PARSE_TIME NUMBER
);


/* ------------------------------------------------------------------------- */

-- 
-- Lose bg_event_summary

alter table stats$system_event add
(total_waits_fg       number
,total_timeouts_fg    number
,time_waited_micro_fg number
);

declare
  l_sql             varchar2(2000);
  l_cursor          integer;
  l_rowcount_1      number := 0;
  l_rowcount_2      number := 0;

begin
   dbms_output.put_line('...Beginning modification of stats$system_event');

   -- Set up the empty columns
   update stats$system_event
         set total_waits_fg       = total_waits
           , total_timeouts_fg    = total_timeouts
           , time_waited_micro_fg = time_waited_micro;

   select count(1)
     into l_rowcount_1
     from stats$bg_event_summary
    where total_waits != 0;

   if l_rowcount_1 > 0 then

      merge into stats$system_event se
      using (select snap_id, dbid, instance_number, event
                  , total_waits, total_timeouts, time_waited_micro
               from stats$bg_event_summary
            ) bg
      on (    se.snap_id         = bg.snap_id
          and se.dbid            = bg.dbid
          and se.instance_number = bg.instance_number
          and se.event           = bg.event
         )
      when matched then
        update
           set total_waits_fg       = decode(sign(se.total_waits       - bg.total_waits)      , 1, se.total_waits       - bg.total_waits, 0)
             , total_timeouts_fg    = decode(sign(se.total_timeouts    - bg.total_timeouts)   , 1, se.total_timeouts    - bg.total_timeouts, 0)
             , time_waited_micro_fg = decode(sign(se.time_waited_micro - bg.time_waited_micro), 1, se.time_waited_micro - bg.time_waited_micro, 0)
      when not matched then
         insert ( snap_id, dbid, instance_number, event
                , total_waits   , total_timeouts,    time_waited_micro
                , total_waits_fg, total_timeouts_fg, time_waited_micro_fg)
         values (bg.snap_id, bg.dbid, bg.instance_number, bg.event
               , bg.total_waits, bg.total_timeouts, bg.time_waited_micro
               , 0             , 0                , 0);

      -- Fix null event id's and rows which were in system event but not in bg event
      update stats$system_event se
          set se.event_id = (select event_id from v$event_name en 
                              where en.name = se.event) 
       where se.event_id is null;

      commit;

    end if;

   select count(1)
     into l_rowcount_2
     from stats$system_event
    where total_waits != total_waits_fg;


    -- If all the data has been converted, drop the old table
    if  l_rowcount_2 > 0 then
       l_cursor := dbms_sql.open_cursor;
       l_sql := 'drop table stats$bg_event_summary';
       dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
       l_sql := 'drop public synonym stats$bg_event_summary';
       dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
       dbms_output.put_line('...Dropped stats$bg_event_summary');
    else
       dbms_output.put_line(l_rowcount_1);
       dbms_output.put_line(l_rowcount_2);
    end if;

   dbms_output.put_line('...Completed modification of stats$system_event');

end;
/

-- To make reporting less problematic
create or replace view PERFSTAT.STATS$BG_EVENT_SUMMARY as
select snap_id
     , dbid
     , instance_number
     , event
     , total_waits       - total_waits_fg       total_waits
     , total_timeouts    - total_timeouts_fg    total_timeouts
     , time_waited_micro - time_waited_micro_fg time_waited_micro
  from stats$system_event;
create or replace public synonym  STATS$BG_EVENT_SUMMARY for 
                                  STATS$BG_EVENT_SUMMARY;


/* ------------------------------------------------------------------------- */

-- 
-- Drop temp_histogram

drop public synonym  STATS$TEMP_HISTOGRAM;
drop table  PERFSTAT.STATS$TEMP_HISTOGRAM;

/* ------------------------------------------------------------------------- */

-- GTT
create global temporary table STATS$TEMP_SQLSTATS
( old_hash_value           number
, text_subset              varchar2(31) 
, module                   varchar2(64)
, delta_buffer_gets        number
, delta_executions         number
, delta_cpu_time           number
, delta_elapsed_time       number
, avg_elapsed_time         number
, avg_hard_parse_time      number
, delta_disk_reads         number
, delta_parse_calls        number
, max_sharable_mem         number
, last_sharable_mem        number
, delta_version_count      number 
, max_version_count        number 
, last_version_count       number 
, delta_cluster_wait_time  number
, delta_rows_processed     number
)
on commit preserve rows;

create public synonym  STATS$TEMP_SQLSTATS for STATS$TEMP_SQLSTATS;

/* ------------------------------------------------------------------------- */

--
-- IOStat support

create table STATS$IOSTAT_FUNCTION_NAME
(function_id                   number        not null
,function_name                 varchar2(18)  not null
,constraint STATS$IOSTAT_FUNCTION_NAME_PK primary key 
     (function_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
create public synonym  STATS$IOSTAT_FUNCTION_NAME for STATS$IOSTAT_FUNCTION_NAME;

create table STATS$IOSTAT_FUNCTION
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,function_id                    number     not null
,small_read_megabytes           number
,small_write_megabytes          number
,large_read_megabytes           number
,large_write_megabytes          number
,small_read_reqs                number
,small_write_reqs               number
,large_read_reqs                number
,large_write_reqs               number
,number_of_waits                number
,wait_time                      number
,constraint STATS$IOSTAT_FUNCTION_PK primary key 
     (snap_id, dbid, instance_number, function_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$IOSTAT_FUNCTION_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$IOSTAT_FUNCTION  for STATS$IOSTAT_FUNCTION;

/* ------------------------------------------------------------------------- */

-- 
-- Auto-Memory support

create table STATS$MEMORY_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,memory_size                    number     not null
,memory_size_factor             number
,estd_db_time                   number
,estd_db_time_factor            number
,version                        number
,constraint STATS$MEMORY_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, memory_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_TARGET_ADVICE  for STATS$MEMORY_TARGET_ADVICE;

create table STATS$MEMORY_DYNAMIC_COMPS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,component                      varchar2(64) not null
,current_size                   number
,min_size                       number
,max_size                       number
,user_specified_size            number
,oper_count                     number
,last_oper_type                 varchar2(13)
,last_oper_mode                 varchar2(9)
,last_oper_time                 date
,granule_size                   number
,constraint STATS$MEMORY_DYNAMIC_COMPS_PK primary key 
     (snap_id, dbid, instance_number, component)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_DYNAMIC_COMPS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_DYNAMIC_COMPS  for STATS$MEMORY_DYNAMIC_COMPS;

create table STATS$MEMORY_RESIZE_OPS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,component                      varchar2(64) not null
,oper_type                      varchar2(13) not null
,oper_mode                      varchar2(9) not null
,start_time                     date        not null
,initial_size                   number      not null
,target_size                    number      not null
,final_size                     number      not null
,status                         varchar2(9) not null
,end_time                       date        not null
,parameter                      varchar2(80)
,num_ops                        number
,constraint STATS$MEMORY_RESIZE_OPS_PK primary key 
     ( snap_id, dbid, instance_number
     , component, oper_type, start_time, oper_mode
     , initial_size, target_size, final_size,status, end_time )
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_RESIZE_OPS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_RESIZE_OPS  for STATS$MEMORY_RESIZE_OPS;

/* ------------------------------------------------------------------------- */

-- RAC
create table STATS$INTERCONNECT_PINGS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,target_instance                number     not null
,iter_500b                      number
,wait_500b                      number
,waitsq_500b                    number
,iter_8k                        number
,wait_8k                        number
,waitsq_8k                      number
,constraint STATS$INTERCONNECT_PINGS_PK primary key 
     (snap_id, dbid, instance_number, target_instance)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INTERCONNECT_PINGS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INTERCONNECT_PINGS  for 
                       STATS$INTERCONNECT_PINGS;

/* ------------------------------------------------------------------------- */

--
-- Add diffable column
alter table stats$osstatname add
(cumulative             varchar2(3));

update stats$osstatname osn
set osn.cumulative = (select vo.cumulative
                        from v$osstat vo
                       where vo.osstat_id = osn.osstat_id)
where osn.cumulative is null;

commit;

update stats$osstatname osn
   set osn.cumulative = 'NO'
 where osn.cumulative is null
   and osn.stat_name like 'AVG%';

commit;

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels

insert into STATS$IDLE_EVENT (event) values ('LogMiner: generic process sleep');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: reader waiting for more redo');
commit;
insert into STATS$IDLE_EVENT (event) values ('LogMiner: waiting for processes to soft detach');
commit;
insert into STATS$IDLE_EVENT (event) values ('Space Manager: slave idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('Streams capture: waiting for archive log');
commit;
insert into STATS$IDLE_EVENT (event) values ('parallel recovery coordinator waits for slave cleanup');
commit;
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('watchdog main loop');
commit;
insert into STATS$IDLE_EVENT (event) values ('DBRM Logical Idle Wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('EMON slave idle wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('IORM Scheduler Slave Idle Wait');
commit;
insert into STATS$IDLE_EVENT (event) values ('pool server timer');
commit;
insert into STATS$IDLE_EVENT (event) values ('cmon timer');
commit;
insert into STATS$IDLE_EVENT (event) values ('fbar timer');
commit;
insert into STATS$IDLE_EVENT (event) values ('PING');
commit;
insert into STATS$IDLE_EVENT (event) values ('MRP redo arrival');
commit;
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave next change');
commit;
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave wait for change');
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
