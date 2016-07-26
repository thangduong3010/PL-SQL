Rem
Rem $Header: catdbfus.sql 24-may-2005.11:28:09 mlfeng Exp $
Rem
Rem catdbfus.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catdbfus.sql - Catalog creation file for DB Feature Usage 
Rem
Rem    DESCRIPTION
Rem      This file creates the schema objects and PL/SQL packages for 
Rem      DB Feature Usage.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/04/05 - add cpu tracking tables 
Rem    mlfeng      12/01/03 - NULL for initial time 
Rem    mlfeng      10/13/03 - add DATE to time for first sample
Rem    mlfeng      06/05/03 - add comments for columns in dba views
Rem    mlfeng      06/24/03 - make insert idempotent, sample_interval
Rem    mlfeng      05/05/03 - add interval column for EM
Rem    mlfeng      04/01/03 - add last sample date number column
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      01/31/03 - update disable flags
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/13/03 - Disable the DBA_HOST_CONFIGURATION view
Rem    mlfeng      01/09/03 - Filter out disabled/test features in DBA view
Rem    mlfeng      12/12/02 - Adding a clob to the feature usage table to
Rem                           allow clients to track extra info
Rem    mlfeng      11/12/02 - Added table, package definitions.
Rem    mlfeng      10/30/02 - Created
Rem

Rem ************************************************************************* 
Rem ---------------- DB Feature Usage Statistics Table ----------------------
Rem ************************************************************************* 

Rem ------------------------------------------------------------------------- 
Rem Create the DBFUS tables
Rem ------------------------------------------------------------------------- 

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_FEATURE_USAGE 
(name                  varchar2(64)  not null,
 dbid                  number        not null,
 version               varchar2(17)  not null,
 first_usage_date      date,
 last_usage_date       date,
 detected_usages       number        not null,
 aux_count             number,
 feature_info          clob,
 error_count           number,
 constraint WRI$_DBU_FEATURE_USAGE_PK primary key
    (name, dbid, version)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_FEATURE_METADATA
(name                  varchar2(64)  not null,
 inst_chk_method       integer,
 inst_chk_logic        clob,
 usg_det_method        integer,
 usg_det_logic         clob,
 description           varchar2(128),
 constraint WRI$_DBU_FEATURE_METADATA_PK primary key (name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_HIGH_WATER_MARK
(name                 varchar2(64)  not null,
 dbid                 number        not null,
 version              varchar2(17)  not null,
 highwater            number,
 last_value           number,
 error_count          number,
 constraint WRI$_DBU_HIGH_WATER_MARK_PK primary key
    (name, dbid, version)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_HWM_METADATA
(name                  varchar2(64)  not null,
 method                integer,
 logic                 clob,
 description           varchar2(128),
 constraint WRI$_DBU_HWM_METADATA_PK primary key (name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_USAGE_SAMPLE
(dbid                   number        not null,
 version                varchar2(17)  not null,
 last_sample_date       date, 
 last_sample_date_num   number,
 last_sample_period     number,
 total_samples          number        not null,
 sample_interval        number,
 constraint WRI$_DBU_USAGE_SAMPLE_PK primary key
    (dbid, version)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 
Rem Insert the row into the WRI$_DBU_USAGE_SAMPLE table for the current
Rem dbid and version of the database.
Rem ------------------------------------------------------------------------- 

insert into WRI$_DBU_USAGE_SAMPLE 
 (dbid, version, last_sample_date, last_sample_date_num, 
  last_sample_period, total_samples, sample_interval) 
select 
  dbid, version, NULL, NULL, 0, 0, 604800 
from v$database, v$instance 
where not exists 
     (select 1 from WRI$_DBU_USAGE_SAMPLE us, v$database d, v$instance i
       where us.dbid    = d.dbid and
             us.version = i.version)
/

commit;

Rem ------------------------------------------------------------------------- 
Rem Create the CPU Usage Views
Rem ------------------------------------------------------------------------- 

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_CPU_USAGE
(dbid                 number        not null,
 version              varchar2(17)  not null,
 timestamp            date          not null,
 cpu_count            number,
 cpu_core_count       number,
 cpu_socket_count     number,
 constraint WRI$_DBU_CPU_USAGE_PK primary key
    (dbid, version, timestamp)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 

create table WRI$_DBU_CPU_USAGE_SAMPLE
(dbid                   number        not null,
 version                varchar2(17)  not null,
 last_sample_date       date, 
 last_sample_date_num   number,
 last_sample_period     number,
 total_samples          number        not null,
 sample_interval        number,
 constraint WRI$_DBU_CPU_USAGE_SAMPLE_PK primary key
    (dbid, version)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ------------------------------------------------------------------------- 
Rem Insert the row into the WRI$_DBU_USAGE_SAMPLE table for the current
Rem dbid and version of the database.
Rem ------------------------------------------------------------------------- 

insert into WRI$_DBU_CPU_USAGE_SAMPLE 
 (dbid, version, last_sample_date, last_sample_date_num, 
  last_sample_period, total_samples, sample_interval) 
select 
  dbid, version, NULL, NULL, 0, 0, 43200
from v$database, v$instance 
where not exists 
     (select 1 from WRI$_DBU_CPU_USAGE_SAMPLE us, v$database d, v$instance i
       where us.dbid    = d.dbid and
             us.version = i.version)
/

commit;


Rem ------------------------------------------------------------------------- 
Rem Create the DBFUS views
Rem ------------------------------------------------------------------------- 

create or replace view DBA_FEATURE_USAGE_STATISTICS
 (DBID, NAME, VERSION, DETECTED_USAGES, TOTAL_SAMPLES, CURRENTLY_USED,
  FIRST_USAGE_DATE, LAST_USAGE_DATE, AUX_COUNT, FEATURE_INFO, 
  LAST_SAMPLE_DATE, LAST_SAMPLE_PERIOD, SAMPLE_INTERVAL, DESCRIPTION)
as 
 select samp.dbid, fu.name, samp.version, detected_usages, total_samples, 
  decode(to_char(last_usage_date, 'MM/DD/YYYY, HH:MI:SS'), 
         NULL, 'FALSE',
         to_char(last_sample_date, 'MM/DD/YYYY, HH:MI:SS'), 'TRUE', 
         'FALSE')
  currently_used, first_usage_date, last_usage_date, aux_count,
  feature_info, last_sample_date, last_sample_period, 
  sample_interval, mt.description
 from wri$_dbu_usage_sample samp, wri$_dbu_feature_usage fu,
      wri$_dbu_feature_metadata mt 
 where
  samp.dbid    = fu.dbid and
  samp.version = fu.version and
  fu.name      = mt.name and
  fu.name not like '_DBFUS_TEST%' and   /* filter out test features */
  bitand(mt.usg_det_method, 4) != 4     /* filter out disabled features */
/
create or replace public synonym DBA_FEATURE_USAGE_STATISTICS for
  DBA_FEATURE_USAGE_STATISTICS
/
grant select on DBA_FEATURE_USAGE_STATISTICS to select_catalog_role
/
comment on table DBA_FEATURE_USAGE_STATISTICS is
'Database Feature Usage Statistics'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.DBID is
'database ID of database being tracked'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.NAME is
'name of feature'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.VERSION is
'the database version the feature was tracked in'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.DETECTED_USAGES is
'number of times the system has detected usage for the feature'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.TOTAL_SAMPLES is
'number of times the system has woken up and checked for usage'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.CURRENTLY_USED is
'if usage was detected the last time the system checked'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.FIRST_USAGE_DATE is
'the first sample time the system detected usage for the feature'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.LAST_USAGE_DATE is
'the last sample time the system detected usage for the feature'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.AUX_COUNT is
'extra column to store feature specific usage data'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.FEATURE_INFO is
'extra column to store feature specific usage data'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.LAST_SAMPLE_DATE is
'last time the system checked for usage'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.LAST_SAMPLE_PERIOD is
'amount of time between the last two usage sample times, in number of seconds'
/
comment on column DBA_FEATURE_USAGE_STATISTICS.DESCRIPTION is
'describes feature and usage detection logic'
/


Rem ------------------------------------------------------------------------- 

create or replace view DBA_HIGH_WATER_MARK_STATISTICS
 (DBID, NAME, VERSION, HIGHWATER, LAST_VALUE, DESCRIPTION)
as
 select dbid, hwm.name, version, highwater, last_value, description
 from wri$_dbu_high_water_mark hwm, wri$_dbu_hwm_metadata mt
 where hwm.name = mt.name and 
       hwm.name not like '_HWM_TEST%' and             /* filter out test hwm */
       bitand(mt.method, 4) != 4                  /* filter out disabled hwm */
/
create or replace public synonym DBA_HIGH_WATER_MARK_STATISTICS for
  DBA_HIGH_WATER_MARK_STATISTICS
/
grant select on DBA_HIGH_WATER_MARK_STATISTICS to select_catalog_role
/
comment on table DBA_HIGH_WATER_MARK_STATISTICS is
'Database High Water Mark Statistics'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.DBID is
'database ID'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.NAME is
'name of high water mark statistics'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.VERSION is
'the database version the highwater marks are tracked in'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.HIGHWATER is
'highest value for statistic seen at sampling time'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.LAST_VALUE is
'value of statistic at last sample time'
/
comment on column DBA_HIGH_WATER_MARK_STATISTICS.DESCRIPTION is
'description of high water mark'
/

Rem ------------------------------------------------------------------------- 

create or replace view DBA_CPU_USAGE_STATISTICS
 (DBID, VERSION, TIMESTAMP, 
  CPU_COUNT, CPU_CORE_COUNT, CPU_SOCKET_COUNT)
as 
 select cu.dbid, cu.version, timestamp, 
        cpu_count, cpu_core_count, cpu_socket_count
 from wri$_dbu_cpu_usage cu, wri$_dbu_cpu_usage_sample cus
 where cu.dbid    = cus.dbid
   and cu.version = cus.version
/
create or replace public synonym DBA_CPU_USAGE_STATISTICS for
  DBA_CPU_USAGE_STATISTICS
/
grant select on DBA_CPU_USAGE_STATISTICS to select_catalog_role
/
comment on table DBA_CPU_USAGE_STATISTICS is
'Database CPU Usage Statistics'
/
comment on column DBA_CPU_USAGE_STATISTICS.DBID is
'database ID'
/
comment on column DBA_CPU_USAGE_STATISTICS.VERSION is
'the database version'
/
comment on column DBA_CPU_USAGE_STATISTICS.TIMESTAMP is
'time the CPU usage changed'
/
comment on column DBA_CPU_USAGE_STATISTICS.CPU_COUNT is
'CPU count of database'
/
comment on column DBA_CPU_USAGE_STATISTICS.CPU_CORE_COUNT is
'CPU Core count of database'
/
comment on column DBA_CPU_USAGE_STATISTICS.CPU_SOCKET_COUNT is
'CPU Socket count of database'
/
