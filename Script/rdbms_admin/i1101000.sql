Rem $Header: rdbms/admin/i1101000.sql /st_rdbms_11.2.0/1 2012/08/25 00:06:31 pknaggs Exp $
Rem
Rem i1101000.sql
Rem
Rem Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      i1101000.sql - load 11.1 specific tables that are need to
Rem                     process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      top-level upgrade script.
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic sql commands.  For example, in order to 
Rem      drop a package, the server code may depend on new tables.
Rem      If these tables do not exist, a recursive sql error will occur,
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 11.1 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    pknaggs     02/01/12 - add 11.2 scripts
Rem    hongyang    01/12/09 - remove obsolete dependencie
Rem    rsamuels    12/16/08 - OLAP API new columns & renamed columns
Rem    rsamuels    11/21/08 - Add olap_multi_options$
Rem    nmacnaug    10/06/08 - remove hash locking
Rem    huagli      04/15/08 - lrg 3369670: move MV related upgrade script
Rem                           from c1101000.sql to this script
Rem    achoi       03/14/08 - remove versionable bit from public in user
Rem    geadon      03/04/08 - bug 5373923: TRANSIENT_IOT$
Rem    rburns      08/20/07 - created for 11.1 upgrade
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 11.1 to the current release
Rem =========================================================================
update user$ set spare1=spare1-16 
   where bitand(spare1, 16) = 16 and name='PUBLIC'
/
commit
/

Rem transient_iot$ is used to track transient IOTs created during partition
Rem maintenance operations (PMOs) on IOTs (bug #5373923)
create table transient_iot$
( obj#            number not null,              /* obj# of the transient IOT */
  parent_obj#     number,                  /* IOT object targeted by the PMO */
  parent_ptn_obj# number             /* partition object targeted by the PMO */
)
tablespace system
/

Rem remove obsolete dependencies before dropping any fixed views
delete from dependency$ where d_obj# in (select obj# from obj$ where name in
  ('V_$STANDBY_APPLY_SNAPSHOT', 'GV_$STANDBY_APPLY_SNAPSHOT')); 

delete from dependency$ where p_obj# in (4294951141,4294951142);

Rem =================================
Rem  Begin Materialized View changes
Rem =================================

-- add new columns to MV log DD
alter table sys.mlog$ add (
  purge_start       date,                                /* purge start date */
  purge_next        varchar2(200),             /* purge next date expression */
  purge_job         varchar2(30),                          /* purge job name */
  last_purge_date   date,                                 /* last purge date */
  last_purge_status number,    /* last purge status: error# or 0 for success */
  rows_purged       number,                     /* last purge: # rows purged */
  oscn_pk           number,                    /* oldest SCN of primary key  */
  oscn_seq          number,                     /* oldest SCN of sequence no */
  oscn_oid          number,                       /* oldest SCN of object ID */
  oscn_new          number                       /* oldest SCN of new values */
);

-- add new column to MV DD
alter table sys.snap$ add (flag3 number);

-- add new column to MV direct loader log
alter table sys.sumdelta$ add (xid number);

-- add new clumn to MV PMOP log
alter table sys.sumpartlog$ add (xid number, cscn number);

-- add new column to MV direct loader log DD
alter table sys.snap_logdep$ add (rscn number);

-- create a new dictionary table snap_xcmt$
create table snap_xcmt$ /* xid and commit_scn mapping table */
( xid          number not null, /* transaction id */
  commit_scn   number not null  /* commit SCn */
);

-- add new column to MV log filter column DD
alter table sys.mlog_refcol$ add (oldest_scn number);

-- add new column to MV direct loader log DD
alter table sys.snap_loadertime$ add (oldest_scn number);

Rem ===============================
Rem  End Materialized View changes
Rem ===============================


Rem ========================
Rem  Begin OLAP API changes
Rem ========================

alter table olap_aw_deployment_controls$ modify (
  physical_name varchar2(64)            /* name of physical aw object */
) add (
  spare5 varchar2(1000)
)
/

alter table olap_impl_options$ modify (
  option_value varchar2(200)
) add (
  spare5 varchar2(1000)
)
/

create table olap_multi_options$
(
 owning_objectid number not null,       /* owning object ID */
 object_type number not null,           /* object type */
 option_type number not null,           /* option type enum */
 option_order number(20,0) not null,    /* order of this value in the option */
 option_value varchar2(80),             /* option value */
 option_num_value number,               /* option num value */
 option_ref_obj_type number,   /* if option_num_value represents an object, 
                                  the type of object */
 spare1 number,
 spare2 number,
 spare3 varchar2(1000),
 spare4 varchar2(1000)
)
/

create unique index i_olap_multi_options on olap_multi_options$ 
  (owning_objectid, object_type, option_type, option_order)
/

Rem ======================
Rem  End OLAP API changes
Rem ======================


Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@i1102000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1101000.sql
Rem *************************************************************************

