Rem
Rem $Header: rdbms/admin/spup816.sql /main/7 2010/04/20 10:50:41 kchou Exp $
Rem
Rem spup816.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spup816.sql - 8.1.6 to 8.1.7 upgrade script
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 8.1.7 schema format
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
Rem    cdialeri    04/21/01 - Split log files
Rem    cdialeri    04/06/00 - 1261813
Rem    cdialeri    03/30/00 - Created
Rem

set verify off

/* ------------------------------------------------------------------------- */

prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 8.1.7 format may result in
prompt irregularities when reporting on pre-8.1.7 snapshot data.
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

spool spup816a.lis

prompt
prompt Specify the tablespace to create any new PERFSTAT tables and indexes
prompt Tablespace specified &&tablespace_name
prompt
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
--  Add support for tempfiles - create view

create view V_$TEMPSTATXS as
select ts.name      tsname
     , tf.name	    filename
     , tm.phyrds
     , tm.phywrts
     , tm.readtim
     , tm.writetim
     , tm.phyblkrd
     , tm.phyblkwrt
     , fw.count     wait_count
     , fw.time      time
  from x$kcbfwait   fw
     , v$tempstat   tm
     , v$tablespace ts
     , v$tempfile   tf
 where ts.ts#     = tf.ts#
   and tm.file#   = tf.file#
   and fw.indx+1  = (tf.file# + (select value from v$parameter where name='db_files'));

create public synonym  V$TEMPSTATXS for V_$TEMPSTATXS;
grant select        on V$TEMPSTATXS      to PERFSTAT;


/* ------------------------------------------------------------------------- */

--
-- Create V_$SQLXS

create view V_$SQLXS as 
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
     , address              address
     , hash_value           hash_value
     , count(1)             version_count
  from v$sql
 group by hash_value, address;

create public synonym V$SQLXS for V_$SQLXS; 
grant select on       V$SQLXS      to PERFSTAT;


/* ------------------------------------------------------------------------- */

--  Grant PERFSTAT select on V$ views

grant select on V_$SQLTEXT        to PERFSTAT;
grant select on V_$PARAMETER      to PERFSTAT;
grant select on V_$SYSTEM_PARAMETER to PERFSTAT;
grant select on V_$LATCH_PARENT   to PERFSTAT;


/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup816b.lis

spool off
connect perfstat/&&perfstat_password

spool spup816b.lis

show user

alter session set sort_area_size = &&sort_area_size;


/* ------------------------------------------------------------------------- */

--
--  Add check constraints - stats$statspack_parameter

update STATS$STATSPACK_PARAMETER set snap_level = 0
 where snap_level  < 5
   and snap_level != 0;
update STATS$STATSPACK_PARAMETER set snap_level = 5 
 where snap_level <  10
   and snap_level != 5;
update STATS$STATSPACK_PARAMETER set snap_level = 10 
 where snap_level >  10;

alter table STATS$STATSPACK_PARAMETER add 
  constraint STATS$STATSPACK_LVL_CK
    check (snap_level in (0, 5, 10));

--
--  Add check constraints - stats$snapshot

update STATS$SNAPSHOT set snap_level = 0
 where snap_level  < 5
   and snap_level != 0;
update STATS$SNAPSHOT set snap_level = 5 
 where snap_level <  10
   and snap_level not in (0, 5);
update STATS$SNAPSHOT set snap_level = 10 
 where snap_level >  10;

alter table STATS$SNAPSHOT add 
  constraint STATS$SNAPSHOT_LVL_CK
    check (snap_level in (0, 5, 10));



/* ------------------------------------------------------------------------- */

--
--  Add a new idle event

insert into STATS$IDLE_EVENT (event) values ('wakeup time manager');


/* ------------------------------------------------------------------------- */

--
--  Create latch parent

create table          STATS$LATCH_PARENT
(snap_id              number(6)       not null
,dbid                 number          not null
,instance_number      number          not null
,latch#               number          not null
,level#               number          not null
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,constraint STATS$LATCH_PARENT_PK primary key 
     (snap_id, dbid, instance_number, latch#) 
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LATCH_PARENT_FK foreign key 
    (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$LATCH_PARENT  for STATS$LATCH_PARENT;


/* ------------------------------------------------------------------------- */

--
--  Create the TEMPSTATXS table for Statspack - continuation of tempfile
--  support

create table STATS$TEMPSTATXS
(snap_id             number(6)     not null
,dbid                number        not null
,instance_number     number        not null
,tsname              varchar2(30)  not null
,filename            varchar2(513) not null
,phyrds              number
,phywrts             number
,readtim             number
,writetim            number
,phyblkrd            number
,phyblkwrt           number
,wait_count          number
,time                number
,constraint STATS$TEMPSTATXS_PK primary key
     (snap_id, dbid, instance_number, tsname, filename)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$TEMPSTATXS_FK foreign key (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$TEMPSTATXS  for STATS$TEMPSTATXS;


/* ------------------------------------------------------------------------- */

--
-- Increase field size

alter table STATS$FILESTATXS modify
(filename             varchar2 (513)
);


/* ------------------------------------------------------------------------- */

--
--  Add wtr_slp_count to latch_misses

alter table STATS$LATCH_MISSES_SUMMARY add
(wtr_slp_count        number
);


/* ------------------------------------------------------------------------- */

--
--  Add max wait time to session_event

alter table STATS$SESSION_EVENT add
(max_wait             number
);


/* ------------------------------------------------------------------------- */

--
--  Add sharable_mem and version_count threshold to stats$snapshot

alter table STATS$SNAPSHOT add
(sharable_mem_th     number
,version_count_th    number
);

set transaction use rollback segment &&large_rollback_segment;

update stats$snapshot
   set sharable_mem_th  = 0
     , version_count_th = 0
 where sharable_mem_th  is null
   and version_count_th is null;


/* ------------------------------------------------------------------------- */

--
--  Add sharable_mem and version_count threshold to stats$statspack_parameter

alter table STATS$STATSPACK_PARAMETER add
(sharable_mem_th     number
,version_count_th    number
);

update stats$statspack_parameter
   set sharable_mem_th  = 1048576
     , version_count_th = 20
 where sharable_mem_th  is null
   and version_count_th is null;

alter table STATS$STATSPACK_PARAMETER modify
(sharable_mem_th     not null
,version_count_th    not null
);


/* ------------------------------------------------------------------------- */

-- 
-- SGASTAT - rename, and add pool

rename STATS$SGASTAT_SUMMARY to STATS$SGASTAT;

drop   public synonym STATS$SGASTAT_SUMMARY;
create public synonym STATS$SGASTAT for STATS$SGASTAT;

alter table STATS$SGASTAT drop primary key drop index;

alter table STATS$SGASTAT drop constraint STATS$SGASTAT_SUMMARY_FK;

alter table STATS$SGASTAT add
(pool    varchar2(11)
);

update stats$sgastat
   set pool = 'all pools'
 where pool is null
   and not exists (select 1
                     from dba_constraints
                    where constraint_name = 'STATS$SGASTAT_U'
                      and owner='PERFSTAT');

alter table STATS$SGASTAT add constraint STATS$SGASTAT_U unique
    (snap_id, dbid, instance_number, name, pool)
  using index tablespace &&tablespace_name
    storage (initial 1m next 1m pctincrease 0);

alter table STATS$SGASTAT add  constraint STATS$SGASTAT_FK foreign key 
    (snap_id, dbid, instance_number) 
        references STATS$SNAPSHOT on delete cascade;


/* ------------------------------------------------------------------------- */

--
--  SQL Statistics

create table STATS$SQL_STATISTICS
(snap_id             number(6)     not null
,dbid                number        not null
,instance_number     number        not null
,total_sql           number        not null
,total_sql_mem       number        not null
,single_use_sql      number        not null
,single_use_sql_mem  number        not null
,constraint STATS$SQL_STATISTICS_PK primary key
     (snap_id, dbid, instance_number)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_STATISTICS_FK foreign key
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_STATISTICS  for STATS$SQL_STATISTICS;


/* ------------------------------------------------------------------------- */

--
--  Provide support for snapping all or just non-default parameters
--  stats$statspack_parameter table

alter table STATS$STATSPACK_PARAMETER add
(all_init    varchar2(5)
,constraint STATS$STATSPACK_ALL_INIT_CK
    check (all_init in ('true','false','TRUE','FALSE'))
);

update stats$statspack_parameter
   set all_init = 'FALSE'
 where all_init is null;

alter table STATS$STATSPACK_PARAMETER modify
(all_init     not null
);


/* ------------------------------------------------------------------------- */

--
--  Add support for snapping all parameters or visible parameters
--  to stats$snapshot table

alter table STATS$SNAPSHOT  add
(all_init    varchar2(5)
);

update stats$snapshot
   set all_init = 'TRUE'
 where all_init is null;


/* ------------------------------------------------------------------------- */

--
--  Normalize the SQLTEXT

--  Create the SQL Text table.  The PK will be created during the upgrade,
--  after the table is populated

create table STATS$SQLTEXT
(hash_value      number       not null
,text_subset     varchar2(31) not null
,piece           number       not null
,sql_text        varchar2(64)
,address         raw(8)
,command_type    number
,last_snap_id    number
) tablespace &&tablespace_name
  storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQLTEXT  for STATS$SQLTEXT;


--  Add the new column to the SQL Summary table

alter table STATS$SQL_SUMMARY add (text_subset     varchar2(31));


--  Count & Convert existing data

column num_dist_sql  heading 'Num Distinct|SQL statements' format 999,999,999
column num_dist_hash heading 'Num Distinct|Hash Values'    format 999,999,999
column tot_sql       heading 'Total Num SQL statements'    format 999,999,999,999

select count(distinct(hash_value))                        num_dist_hash
     , count(distinct(hash_value||substr(sql_text,1,31))) num_dist_sql
     , count(1)                                           tot_sql
  from stats$sql_summary;

prompt
prompt  Normalizing SQL data - this may take a while
prompt

/*  We use ROWId's for the first part of the convert - lock the table  */
lock table stats$sql_summary in exclusive mode;

set transaction use rollback segment &&large_rollback_segment;

declare

  l_snap_id         number(6);
  l_address         raw(8);
  l_hash_value      number;
  l_text_length     number;
  l_text_subset     varchar2(31);
  l_dbid            number;
  l_instance_number number;
  l_rowid           rowid;
  l_sql             varchar2(1000);
  l_cursor          integer;

  l_text_piece_0    varchar2(64);
  l_text_piece_1    varchar2(64);
  l_text_piece_2    varchar2(64);
  l_text_piece_3    varchar2(64);
  l_text_piece_4    varchar2(64);
  l_text_piece_5    varchar2(64);
  l_text_piece_6    varchar2(64);
  l_text_piece_7    varchar2(64);
  l_text_piece_8    varchar2(64);
  l_text_piece_9    varchar2(64);
  l_text_piece_10   varchar2(64);
  l_text_piece_11   varchar2(64);
  l_text_piece_12   varchar2(64);
  l_text_piece_13   varchar2(64);
  l_text_piece_14   varchar2(64);
  l_text_piece_15   varchar2(64);


  cursor distinct_hash_values is
    select hash_value
         , substr(sql_text,1,31)
         , min(rowid)
      from stats$sql_summary ss
     group by hash_value, substr(sql_text,1,31);


begin

  open distinct_hash_values;

  loop

    /*  Get a hash value  */

    fetch distinct_hash_values into
          l_hash_value, l_text_subset, l_rowid;
    exit when distinct_hash_values%notfound;


    /*  Lookup the SQL  */

    select snap_id, address, length(sql_text)
         , substr(sql_text, 1,   64)
         , substr(sql_text, 65,  64)
         , substr(sql_text, 129, 64)
         , substr(sql_text, 193, 64)
         , substr(sql_text, 257, 64)
         , substr(sql_text, 321, 64)
         , substr(sql_text, 385, 64)
         , substr(sql_text, 449, 64)
         , substr(sql_text, 513, 64)
         , substr(sql_text, 577, 64)
         , substr(sql_text, 641, 64)
         , substr(sql_text, 705, 64)
         , substr(sql_text, 769, 64)
         , substr(sql_text, 833, 64)
         , substr(sql_text, 897, 64)
         , substr(sql_text, 961, 39)
      into l_snap_id, l_address, l_text_length
         , l_text_piece_0,  l_text_piece_1,  l_text_piece_2,  l_text_piece_3 
         , l_text_piece_4,  l_text_piece_5,  l_text_piece_6,  l_text_piece_7 
         , l_text_piece_8,  l_text_piece_9,  l_text_piece_10, l_text_piece_11 
         , l_text_piece_12, l_text_piece_13, l_text_piece_14, l_text_piece_15
      from stats$sql_summary ss
     where rowid = l_rowid;


    /*  Insert the SQL text rows into stats$sqltext  */

    insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
    values
      ( l_hash_value, l_text_subset, 0, l_text_piece_0, l_address, null, l_snap_id );

    if l_text_length >= 65 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 1, l_text_piece_1, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 129 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 2, l_text_piece_2, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 193 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 3, l_text_piece_3, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 257 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 4, l_text_piece_4, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 321 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 5, l_text_piece_5, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 385 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 6, l_text_piece_6, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 449 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 7, l_text_piece_7, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 513 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 8, l_text_piece_8, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 577 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 9, l_text_piece_9, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 641 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 10, l_text_piece_10, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 705 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 11, l_text_piece_11, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 769 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 12, l_text_piece_12, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 833 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 13, l_text_piece_13, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 897 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 14, l_text_piece_14, l_address, null, l_snap_id );
    end if;

    if l_text_length >= 961 then
      insert into stats$sqltext
      ( hash_value, text_subset, piece, sql_text, address, command_type, last_snap_id )
      values
      ( l_hash_value, l_text_subset, 15, l_text_piece_15, l_address, null, l_snap_id );
    end if;

  end loop;

  close distinct_hash_values;


  /*  Build the PK index on the newly populated stats$sqltext  */

  l_cursor := dbms_sql.open_cursor;
  l_sql := 'alter table stats$sqltext add constraint stats$sqltext_pk primary key
              (hash_value, text_subset, piece)
            using index tablespace &&tablespace_name
            storage (initial 1m next 1m pctincrease 0)';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Reformat old SQL text in stats$sql_summary
      It is faster to CTAS than to just update the text_subset and nullify
      the sql_text; CTAS also generates less redo and rollback, and
      reclaims a lot of disk space
  */

  l_sql := 'create table stats$sql_summary_conv
               ( snap_id, dbid, instance_number
               , text_subset
               , sharable_mem, sorts, module, loaded_versions, executions
               , loads, invalidations, parse_calls, disk_reads, buffer_gets    
               , rows_processed, address, hash_value, version_count
               )
              tablespace &&tablespace_name
              pctfree 5 pctused 40
              storage (initial 5m next 5m pctincrease 0)
              as select
                 snap_id, dbid, instance_number
               , substr(sql_text,1,31)
               , sharable_mem, sorts, module, loaded_versions, executions
               , loads, invalidations, parse_calls, disk_reads, buffer_gets    
               , rows_processed, address, hash_value, version_count
              from stats$sql_summary';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Make the new text_subset column not null  */

  l_sql := 'alter table stats$sql_summary_conv modify
              (text_subset     not null)';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Re-add the SQL Text column for tidyness  */

  l_sql := 'alter table stats$sql_summary_conv add
              (sql_text     varchar2(2000))';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Drop the old SQL Summary table  */

  l_sql := 'drop table stats$sql_summary';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Rename the new/converted table to SQL Summary  */

  l_sql := 'rename stats$sql_summary_conv to stats$sql_summary';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  /*  Add the primary and foreign keys to the new SQL Summary   */

  l_sql := 'alter table stats$sql_summary add constraint stats$sql_summary_pk
              primary key
              (snap_id, dbid, instance_number, hash_value, address)
              using index tablespace &&tablespace_name
              storage (initial 1m next 1m pctincrease 0)';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);

  l_sql := 'alter table stats$sql_summary add constraint stats$sql_summary_fk
              foreign key (snap_id, dbid, instance_number)
              references stats$snapshot on delete cascade';
  dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);


  dbms_sql.close_cursor(l_cursor);

  commit;

exception
  when others then
     rollback;
     raise;
end;
/

select count(distinct(hash_value))                        num_dist_hash
     , count(distinct(hash_value||text_subset))           num_dist_sql
     , count(1)                                           tot_sql
  from stats$sqltext
 where piece = 0;


/* ------------------------------------------------------------------------- */

--
--  Create rows in stats$database_instance for each instance startup

--
--  Drop existing constraints

alter table STATS$SNAPSHOT
  drop constraint STATS$SNAPSHOT_FK;

alter table STATS$STATSPACK_PARAMETER
  drop constraint STATS$STATSPACK_PARAMETER_FK;

alter table STATS$DATABASE_INSTANCE 
  drop constraint STATS$DATABASE_INSTANCE_PK;


--
--  Modify stats$database_instance to add new columns

alter table STATS$DATABASE_INSTANCE add
(snap_id              number(6)
,startup_time         date
,parallel             varchar2(3)
,version              varchar2(17)
);


--
--  Update new columns in stats$database_instance and delete pre-existing rows

set transaction use rollback segment &&large_rollback_segment;

update stats$database_instance set
       version = 'OLD RECORD'
 where version is null;

insert into stats$database_instance
     ( snap_id
     , dbid
     , instance_number
     , startup_time
     , parallel
     , version
     , db_name
     , instance_name
     , host_name
     )
select sga.snap_id
     , sga.dbid
     , sga.instance_number
     , sga.startup_time
     , sga.parallel
     , sga.version
     , di.db_name
     , di.instance_name
     , di.host_name
  from stats$sgaxs              sga
     , stats$database_instance  di
 where sga.name           = 'Fixed Size'
   and di.instance_number = sga.instance_number
   and di.dbid            = sga.dbid
   and di.version         = 'OLD RECORD'
   and not exists (select 1
                     from stats$database_instance di2
                    where di2.dbid            = sga.dbid
                      and di2.instance_number = sga.instance_number
                      and nvl(di2.startup_time,
                                to_date('01-Jan-1960', 'DD-Mon-YYYY'))
                                             = sga.startup_time);

--  Delete old rows from stats$database_instance if they have been
--  converted successfully

delete from stats$database_instance di1
 where di1.version = 'OLD RECORD'
   and not exists (select dbid, instance_number, startup_time
                     from stats$sgaxs sga
                    where sga.dbid            = di1.dbid
                      and sga.instance_number = di1.instance_number
                      and sga.name            = 'Fixed Size'
                  minus
                   select dbid, instance_number, startup_time
                     from stats$database_instance di2
                    where di2.dbid            = di1.dbid
                      and di2.instance_number = di1.instance_number
                      and di2.version <> 'OLD RECORD'
              );

  commit;

--
--  Make the new columns not null

alter table STATS$DATABASE_INSTANCE modify
(snap_id       not null
,startup_time  not null
,parallel      not null
,version       not null
);


--
--  Create the new primary key, and a related foreign key

alter table STATS$DATABASE_INSTANCE add constraint STATS$DATABASE_INSTANCE_PK
  primary key (dbid, instance_number, startup_time);

alter table STATS$SNAPSHOT add constraint STATS$SNAPSHOT_FK 
  foreign key (dbid, instance_number, startup_time)
  references STATS$DATABASE_INSTANCE on delete cascade;

--  Foreign key for STATS$STATSPACK_PARAMETER is no longer required


/* ------------------------------------------------------------------------- */

--
--  Insert new rows in stats$sga - one set of rows per snapshot

--
--  Rename STATS$SGAXS to STATS$SGA, and change column characteristics

rename STATS$SGAXS to STATS$SGA;

alter table STATS$SGA drop primary key drop index;

alter table STATS$SGA drop constraint STATS$SGAXS_FK;

drop   public synonym  STATS$SGAXS;
create public synonym  STATS$SGA    for STATS$SGA;

alter table STATS$SGA modify
(startup_time         null
,parallel             null
);

set transaction use rollback segment &&large_rollback_segment;

insert into stats$sga
     ( snap_id
     , dbid
     , instance_number
     , name
     , value
     )
select s.snap_id
     , s.dbid
     , s.instance_number
     , name
     , value
  from stats$sga      sga
     , stats$snapshot s
 where sga.dbid            = s.dbid
   and sga.instance_number = s.instance_number
   and sga.startup_time    = s.startup_time
   and sga.snap_id        != s.snap_id
   and not exists (select 1
                     from stats$sga sga
                    where s.dbid            = sga.dbid
                      and s.instance_number = sga.instance_number
                      and s.snap_id         = sga.snap_id
                  );

commit;

alter table STATS$SGA add  constraint STATS$SGA_PK primary key
  (snap_id, dbid, instance_number, name);

alter table STATS$SGA add  constraint STATS$SGA_FK foreign key
    (snap_id, dbid, instance_number)
        references STATS$SNAPSHOT on delete cascade;


alter table STATS$SGA modify 
(value                not null
);



/* ------------------------------------------------------------------------- */

--
--  Buffer pool table no longer needed

truncate table        STATS$BUFFER_POOL;
drop table            STATS$BUFFER_POOL;
drop public synonym   STATS$BUFFER_POOL;

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
