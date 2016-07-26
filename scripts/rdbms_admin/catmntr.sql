Rem
Rem $Header: rdbms/admin/catmntr.sql /st_rdbms_11.2.0/1 2012/08/30 13:57:16 shiyadav Exp $
Rem
Rem catmntr.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmntr.sql - DBMS_MONITOR table creation
Rem
Rem    DESCRIPTION
Rem      Catalog script to create DBMS_MONITOR package and the tables
Rem      used by the package
Rem
Rem    NOTES
Rem      This script creates tables required by the DBMS_MONITOR package
Rem      and sources in the package definion
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      08/20/12 - Backport shiyadav_bug-14320459 from
Rem    rcolle      04/07/07 - add plan_stats column in dba_enabled_traces
Rem    ilistvin    11/08/06 - catproc restructuring changes
Rem    rburns      09/16/06 - split for new catproc
Rem    atsukerm    04/23/04 - add database-level trace 
Rem    aime        04/25/03 - aime_going_to_main
Rem    mramache    03/03/03 - v$service_stats and v$sess_time_model
Rem    mramache    01/23/03 - add v_$sys_time_model view
Rem    atsukerm    01/17/03 - continue after refresh
Rem    atsukerm    01/13/03 - on-demand aggregation
Rem    atsukerm    12/05/02 - atsukerm_e2etr
Rem    atsukerm    10/25/02 - continue work after refresh
Rem    atsukerm    10/03/02 - continuing work after refresh
Rem    atsukerm    10/01/02 - Created
Rem

Rem create the table of trace enablings
create table          WRI$_TRACING_ENABLED
(trace_type           number not null,         
 primary_id           varchar2(64),
 qualifier_id1        varchar2(64),
 qualifier_id2        varchar2(64),
 instance_name        varchar2(16),
 flags                number
) tablespace SYSAUX;

create unique index WRI$_TRACING_IND1 on WRI$_TRACING_ENABLED
 (trace_type, primary_id, qualifier_id1, qualifier_id2, instance_name)
   tablespace SYSAUX;

Rem create the table of aggregation enablings
create table          WRI$_AGGREGATION_ENABLED
(trace_type           number not null,
 primary_id           varchar2(64),
 qualifier_id1        varchar2(48),
 qualifier_id2        varchar2(32),
 instance_name        varchar2(16)
) tablespace SYSAUX;

create unique index WRI$_AGGREGATION_IND1 on WRI$_AGGREGATION_ENABLED
 (trace_type, primary_id, qualifier_id1, qualifier_id2, instance_name)
   tablespace SYSAUX;

Rem Define the DBA views

Rem View on enabled traces
create or replace view DBA_ENABLED_TRACES
  (TRACE_TYPE, PRIMARY_ID, QUALIFIER_ID1, QUALIFIER_ID2, WAITS, BINDS,
   PLAN_STATS, INSTANCE_NAME)
as select decode(trace_type, 1, 'CLIENT_ID', 3, 'SERVICE', 
                 4, 'SERVICE_MODULE', 5, 'SERVICE_MODULE_ACTION', 
                 6, 'DATABASE', 'UNDEFINED'),
                 primary_id, qualifier_id1, qualifier_id2, 
                 decode(bitand(flags,8), 8, 'TRUE', 'FALSE'),
                 decode(bitand(flags,4), 4, 'TRUE', 'FALSE'),
                 decode(bitand(flags,16) + bitand(flags,32),
                        16,'ALL_EXEC',32,'NEVER',0,'FIRST_EXEC'),
                 instance_name
  from WRI$_TRACING_ENABLED;

create or replace public synonym DBA_ENABLED_TRACES for DBA_ENABLED_TRACES;

grant select on DBA_ENABLED_TRACES to select_catalog_role;

comment on table DBA_ENABLED_TRACES is
'Information about enabled SQL traces';

comment on column DBA_ENABLED_TRACES.trace_type is
'Type of the trace (CLIENT_ID, SERVICE, etc.)';

comment on column DBA_ENABLED_TRACES.primary_id is
'Primary qualifier (specific Client Identifier or Service name)';

comment on column DBA_ENABLED_TRACES.qualifier_id1 is
'Secondary qualifier (specific MODULE name)';

comment on column DBA_ENABLED_TRACES.qualifier_id2 is
'Additional qualifier (specific ACTION name)';

comment on column DBA_ENABLED_TRACES.waits is
'TRUE of waits are traced';

comment on column DBA_ENABLED_TRACES.binds is
'TRUE of binds are traced';

comment on column DBA_ENABLED_TRACES.instance_name is
'Instance name for tracing restricted to named instances';

Rem View on enabled aggregations
create or replace view DBA_ENABLED_AGGREGATIONS
  (AGGREGATION_TYPE, PRIMARY_ID, QUALIFIER_ID1, QUALIFIER_ID2)
as select decode(trace_type, 1, 'CLIENT_ID', 3, 'SERVICE', 
                 4, 'SERVICE_MODULE', 5, 'SERVICE_MODULE_ACTION', 'UNDEFINED'),
                 primary_id, qualifier_id1, qualifier_id2 
  from WRI$_AGGREGATION_ENABLED;

create or replace public synonym DBA_ENABLED_AGGREGATIONS for 
  DBA_ENABLED_AGGREGATIONS;

grant select on DBA_ENABLED_AGGREGATIONS to select_catalog_role;

comment on table DBA_ENABLED_AGGREGATIONS is
'Information about enabled on-demand statistic aggregation';

comment on column DBA_ENABLED_AGGREGATIONS.aggregation_type is
'Type of the aggregation (CLIENT_ID, SERVICE, etc.)';

comment on column DBA_ENABLED_AGGREGATIONS.primary_id is
'Primary qualifier (specific Client Identifier or Service name)';

comment on column DBA_ENABLED_AGGREGATIONS.qualifier_id1 is
'Secondary qualifier (specific MODULE name)';

comment on column DBA_ENABLED_AGGREGATIONS.qualifier_id2 is
'Additional qualifier (specific ACTION name)';

Rem Statistics-related v$ views

create or replace view v_$client_stats as select * from v$client_stats;
create or replace public synonym v$client_stats for v_$client_stats;
grant select on v_$client_stats to select_catalog_role;

create or replace view gv_$client_stats as select * from gv$client_stats;
create or replace public synonym gv$client_stats for gv_$client_stats;
grant select on gv_$client_stats to select_catalog_role;

create or replace view v_$serv_mod_act_stats as select * from 
   v$serv_mod_act_stats;
create or replace public synonym v$serv_mod_act_stats for 
  v_$serv_mod_act_stats;
grant select on v_$serv_mod_act_stats to select_catalog_role;

create or replace view gv_$serv_mod_act_stats as select * from 
   gv$serv_mod_act_stats;
create or replace public synonym gv$serv_mod_act_stats for 
  gv_$serv_mod_act_stats;
grant select on gv_$serv_mod_act_stats to select_catalog_role;

create or replace view v_$service_stats as select * from 
   v$service_stats;
create or replace public synonym v$service_stats for 
  v_$service_stats;
grant select on v_$service_stats to select_catalog_role;

create or replace view gv_$service_stats as select * from 
   gv$service_stats;
create or replace public synonym gv$service_stats for 
  gv_$service_stats;
grant select on gv_$service_stats to select_catalog_role;

create or replace view v_$sys_time_model as select * from v$sys_time_model;
create or replace public synonym v$sys_time_model for v_$sys_time_model;
grant select on v_$sys_time_model to select_catalog_role;

create or replace view gv_$sys_time_model as select * from gv$sys_time_model;
create or replace public synonym gv$sys_time_model for gv_$sys_time_model;
grant select on gv_$sys_time_model to select_catalog_role;

create or replace view v_$sess_time_model as select * from v$sess_time_model;
create or replace public synonym v$sess_time_model for v_$sess_time_model;
grant select on v_$sess_time_model to select_catalog_role;

create or replace view gv_$sess_time_model as select * from gv$sess_time_model;
create or replace public synonym gv$sess_time_model for gv_$sess_time_model;
grant select on gv_$sess_time_model to select_catalog_role;



