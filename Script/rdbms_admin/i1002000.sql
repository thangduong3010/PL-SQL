Rem $Header: rdbms/admin/i1002000.sql /main/41 2010/02/15 09:59:45 cdilling Exp $
Rem
Rem i1002000.sql
Rem
Rem Copyright (c) 1999, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      i1002000.sql - load 10.2 specific tables that are need to
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
Rem        STAGE 1: upgrade from 10.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    02/11/10 - bug 9361114 - set spare1 to 0 if spare1 is null
Rem                           in user$
Rem    rdecker     04/03/09 - bug 7361575: move assembly$ from c1002000.sql
Rem    sagrawal    10/29/08 - bug 7449757
Rem    rburns      09/28/07 - move triggerdep creation
Rem    rburns      08/22/07 - add 11g scripts
Rem    sfeinste    06/11/07 - Extend length of olap_descriptions$.language and
Rem                           olap_impl_options$.option_value
Rem    sfeinste    02/28/07 - Cleanup olap dict tables
Rem    achoi       12/15/06 - fix updates of props$
Rem    wechen      02/17/07 - rename olap_primary_dimensions$ and
Rem                           olap_interactions$ olap_cube_dimensions$
Rem                           and olap_build_processes$
Rem    jingliu     01/09/07 - move triggerdep$ from c* script
Rem    rdecker     12/07/06 - bug 5701143: trigger action column offset
Rem    sfeinste    12/06/06 - Add owner_type to i_olap_syntax$ index
Rem    rburns      12/01/06 - move OLAP creates to i1002000.sql
Rem    rdecker     10/20/06 - declare plscope indexes in SYSAUX
Rem    rdecker     10/20/06 - plscope tables are now in SYSAUX
Rem    slynn       10/12/06 - smartfile->securefile
Rem    achoi       10/26/06 - clear 0x00200000 in trigflag during upgrade
Rem    rdecker     07/20/06 - Changes for PL/Scope
Rem    gviswana    10/02/06 - Edition renaming
Rem    akruglik    09/01/06 - CMVs became EVs and app_edition# became
Rem                           edition_obj#
Rem    ciyer       08/07/06 - audit support for edition objects
Rem    jaeblee     08/10/06 - set spare1 field for PUBLIC in user$
Rem    rdecker     08/08/10 - Add obj# index to plscope_identifiers
Rem    rdecker     06/30/06 - Change to PL/Scope tables
Rem    ifitzger    06/14/06 - Add TDE_MASTER_KEY_ID in props$ 
Rem    ramekuma    07/07/06 - add indrebuild$
Rem    achoi       03/29/06 - add CODE to edition$ 
Rem    rdecker     05/30/06 - Add PL/Scope tables
Rem    ciyer       05/17/06 - edition syntax changes 
Rem    smuthuli    05/19/06 - project 18567: nglob 
Rem    smuthuli    04/19/06 - project 18567: nglob 
Rem    smuthuli    04/18/06 - project 18567: nglob 
Rem    gviswana    05/20/06 - Add diana_version 
Rem    akruglik    05/09/06 - replace PK and Unique constraints on EV$ and 
Rem                           EVCOL$ with unique indexes 
Rem    akruglik    04/29/06 - replace ev$.base_tbl_obj# with base_tbl_owner# 
Rem                           and base_tbl_name to make life simple for online 
Rem                           redef 
Rem    akruglik    04/07/06 - add EV$ and EVCOL$ 
Rem    achoi       05/17/06 - set ORA$BASE as current edition
Rem    shshanka    04/02/06 - Add columns to partobj$
Rem    shsong      04/27/06 - Bug 5014810: remove X$KCFTIOHIST, etc 
Rem    sbodagal    05/02/06 - add a new column to sumdetail$
Rem    mxyang      03/10/06 - Add edition
Rem    shshanka    03/12/06 - Add ecol$ in upgrade 
Rem    yuli        01/31/06 - remove dependency on x$kckce , etc.
Rem    gkulkarn    10/28/05 - Remove X$LCR and X$LOGMNR_DICT$ from dependency$ 
Rem    cdilling    06/15/05 - cdilling_add_upgrade_scripts
Rem    cdilling    06/08/05 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 10.2 to the current release
Rem =========================================================================

Rem This needs to be first to avoid ORA-00942 errors on create index
Rem statements (bug 6452252).
Rem Support trigger with FOLLOWS clause (dsqlddl.bsq)
create table triggerdep$       /* trigger dependency. i.e., follows,precedes */
(
  obj#        number,                                        /* trigger obj# */
  p_trgowner  varchar2(30),                          /* parent trigger owner */
  p_trgname   varchar2(30),                           /* parent trigger name */
  flag        number not null,                    /* 0x01 FOLLOWS dependency */
                                                 /* 0x02 PRECEDES dependency */
  spare1      number,
  spare2      number
)
/
create index triggerdepind$ on triggerdep$(obj#)
/

Rem clear 0x00200000 (read-only table flag) in trigflag during upgrade
update tab$ set trigflag = trigflag - 2097152
  where bitand(trigflag, 2097152) <> 0;
commit;

Rem need explicit delete for 10.2 fixed objects not in 11g.
Rem X$LOGMNR_DICT$ 	- 4294951755
Rem X$LCR          	- 4294951637
Rem X$KCKCE        	- 4294951122
Rem X$KCKTY        	- 4294951123
Rem X$KCKFM        	- 4294951124
Rem V_$TEMP_HISTOGRAM   - 4294952120
Rem X$KCFTIOHIST	- 4294952121
Rem GV_$TEMP_HISTOGRAM 	- 4294952122

Rem Add columns to partition dictionary.
alter table partlob$ add (
  defmaxsize  number,
  defretention  number,
  defmintime number);

alter table tabcompart$ add (
  defmaxsize  number);

alter table partobj$ add (
  defmaxsize  number);

alter table lobcomppart$ add (
  defmaxsize  number,
  defretention  number,
  defmintime number);

alter table indcompart$ add (
  defmaxsize  number);

delete from dependency$ where p_obj# in (4294951755,  
                                         4294951637,
                                         4294951122,
                                         4294951123,
                                         4294951124,
					 4294952120,
					 4294952121,
					 4294952122);

REM Additional info pertaining to Editioning Views (EVs)
CREATE TABLE ev$ 
(
  ev_obj# NUMBER NOT NULL, /* id of an EV */
      /* id of schema to which EV's base table belongs */
  base_tbl_owner# NUMBER NOT NULL, 
  base_tbl_name VARCHAR2(30) NOT NULL, /* EV's base table name */
  edition_obj# NUMBER NOT NULL)
tablespace system
/

CREATE UNIQUE INDEX i_ev1 ON ev$(ev_obj#)
/

CREATE UNIQUE INDEX i_ev2 
    ON ev$(base_tbl_owner#, base_tbl_name, edition_obj#)
/

REM Additional info for EV columns
CREATE TABLE evcol$ 
(
  ev_obj# NUMBER NOT NULL, /* id of an EV */
  ev_col_id NUMBER NOT NULL, /* column id of an EV column */
  /* name of a corresponding base table column */
  base_tbl_col_name VARCHAR2(30) NOT NULL)
tablespace system
/

CREATE UNIQUE INDEX i_evcol1 ON evcol$(ev_obj#, ev_col_id)
/

REM Add tables used to handle new add column
create table ecol$
(
  tabobj#      number,
  colnum       number, 
  binaryDefVal blob)
tablespace system
/

REM index on ecol$
create index ecol_ix1 on ecol$(tabobj#, colnum);

REM add a new column to sumdetail$ (a summary management metadata table)
alter table sumdetail$ add (tabscnctr number default 0);

Rem Older-version Diana information
create table diana_version$ (
  obj#          number not null,
  stime         date not null,
  flags         number);


merge into diana_version$ d
  using  (select obj#, stime, 0 from obj$
    where type# in (7, 8, 9) and 
          obj# in (select obj# from idl_ub1$
  where part = 0 and version < 184549376)) o
  on (d.obj# = o.obj#)
   when matched THEN
  update set stime = sysdate where 1=0 /* do nothing */
   when not matched THEN
  insert values(o.obj#, o.stime, 0);


create unique index i_diana_version on diana_version$(obj#);

Rem add column to partobj$ to allow interval
alter table partobj$ add (
  interval_str varchar2(1000),                   /* string of interval value */
  interval_bival raw(200))              /* binary representation of interval */
/

Rem add table used in online index rebuild without S DML lock
create table indrebuild$                   /* indexes getting rebuilt online */
( obj#          number not null,                            /* object number */
  dataobj#      number,                          /* data layer object number */
  ts#           number not null,                        /* tablespace number */
  file#         number not null,               /* segment header file number */
  block#        number not null,              /* segment header block number */
  pctfree$      number not null, /* minimum free space percentage in a block */
  initrans      number not null,            /* initial number of transaction */
  maxtrans      number not null,            /* maximum number of transaction */
  compcols      number, /* number of compressed cols, NULL if not compressed */
  flags         number)                                        /* misc flags */
tablespace system
/

create unique index i_indrebuild1 on indrebuild$(obj#)
/

Rem Add PL/Scope tables
create table plscope_identifier$ (
  signature  varchar2(32),                           /* identifier signature */
  symrep     varchar2(30),                          /* symbol representation */
  obj#       number,
  type#      number)
  tablespace sysaux
/
create unique index i_plscope_sig_identifier$ on plscope_identifier$(signature)
tablespace sysaux
/
create index i_plscope_obj_identifier$ on plscope_identifier$(obj#)
tablespace sysaux
/

create table plscope_action$ (
  obj#       number,                                        /* object number */
  action#    number,                                        /* action number */
  signature  varchar2(32),                           /* identifier signature */
  action     number,                                       /* type of action */
  line       number,  
  col        number,
  context#   number)                        /* context number of this action */
  tablespace sysaux
/
create index i_plscope_sig_action$ on plscope_action$(signature)
tablespace sysaux
/
create index i_plscope_obj_action$ on plscope_action$(obj#)
tablespace sysaux
/

Rem add columns to trigger$ to store trigger name line/col information
alter table trigger$ add (
  trignameline  number,             /* trigger name line relative to source$ */
  trignamecol   number,              /* trigger name col relative to source$ */
  trignamecolofs number,                /* trigger name column number offset */
  actioncolno   number                        /* action column number offset */
);

Rem =========================================================================
Rem END STAGE 1: upgrade from 10.2 to the current release
Rem =========================================================================

Rem Edition
create table edition$
(
  obj#      number not null,                                 /* edition obj# */
  p_obj#    number,                                   /* parent edition obj# */
  flags     number,
  code      raw(2000),
  audit$    varchar2(38) not null,                       /* auditing options */
  spare1    number,
  spare2    varchar2(30)
)
/
create edition ora$base
/
insert into props$
    (select 'DEFAULT_EDITION', 'ORA$BASE',
             'Name of the database default edition' from dual
     where 'DEFAULT_EDITION' NOT IN (select name from props$))
/
commit
/
alter session set edition = ORA$BASE
/
insert into props$
    (select 'TDE_MASTER_KEY_ID', NULL, NULL from dual
     where 'TDE_MASTER_KEY_ID' NOT IN (select name from props$))
/

grant use on edition ora$base to public
/
update user$ set spare1=0
   where spare1 IS NULL
/
commit
/
update user$ set spare1=spare1+16 
   where bitand(spare1, 16) != 16 and name='PUBLIC'
/
commit
/

Rem OLAP Analytic Workspace table: add resync compatibility counter
alter table aw$ add (rsygen number default null)
/

Rem OLAP Analytic Workspace access tracking table

create table aw_track$ /* Analytic Workspace Access Tracking table */
(awseq# number,                          /* aw sequence number */
 oid    number(20),                      /* object number, up to UB8MAXVAL */
 key0   number(10),                      /* dimension key #1 */
 key1   number(10),                      /* dimension key #2 */
 key2   number(10),                      /* dimension key #3 */
 key3   number(10),                      /* dimension key #4 */
 key4   number(10),                      /* dimension key #5 */
 key5   number(10),                      /* dimension key #6 */
 key6   number(10),                      /* dimension key #7 */
 key7   number(10),                      /* dimension key #8 */
 key8   number(10),                      /* dimension key #9 */
 key9   number(10),                      /* dimension key #10 */
 key10  number(10),                      /* dimension key #11 */
 key11  number(10),                      /* dimension key #12 */
 key12  number(10),                      /* dimension key #13 */
 key13  number(10),                      /* dimension key #14 */
 key14  number(10),                      /* dimension key #15 */
 key15  number(10),                      /* dimension key #16 */
 key16  number(10),                      /* dimension key #17 */
 key17  number(10),                      /* dimension key #18 */
 key18  number(10),                      /* dimension key #19 */
 key19  number(10),                      /* dimension key #20 */
 key20  number(10),                      /* dimension key #21 */
 key21  number(10),                      /* dimension key #22 */
 key22  number(10),                      /* dimension key #23 */
 key23  number(10),                      /* dimension key #24 */
 key24  number(10),                      /* dimension key #25 */
 key25  number(10),                      /* dimension key #26 */
 key26  number(10),                      /* dimension key #27 */
 key27  number(10),                      /* dimension key #28 */
 key28  number(10),                      /* dimension key #29 */
 key29  number(10),                      /* dimension key #30 */
 acount number(16),                      /* access count */
 atime  number(16))                      /* total access time */
 tablespace sysaux
/

create unique index i_aw_track$
 on aw_track$ (awseq#, oid,
               key0,  key1,  key2,  key3,  key4,  key5,  key6,  key7,  key8,
               key9,  key10, key11, key12, key13, key14, key15, key16, key17,
               key18, key19, key20, key21, key22, key23, key24, key25, key26,
               key27, key28, key29)
 tablespace sysaux
/

create table aw_prg$  /* Analytical Workspace Program table */
( awseq# number,                     /* aw sequence number */
  oid number(20),                    /* object number, up to UB8MAXVAL */
  gen# number(10),                   /* generation number */
  stm# number,                       /* statement number */
  stmtext blob,                      /* statement text */
  compcode blob,                     /* compiled code body */
  flags number,                      /* flags */
  spare blob)                        /* reserved */
lob(stmtext) store as (enable storage in row)
lob(compcode) store as (enable storage in row)
lob (spare) store as (enable storage in row)
tablespace sysaux
/

create unique index i_aw_prg$ on aw_prg$ (awseq#, oid, gen#, stm#) 
tablespace sysaux
/

/************MAPPINGS**************/

create table olap_mappings$
(
  map_name varchar2(30) not null,        /* map name */  
  map_id number not null,                /* map ID */  
  map_type number(2,0) not null,         /* type of map e.g. solve hier */  
  mapping_owner_id number not null,      /* mapping owner ID */
  mapping_owner_type number not null,    /* mapping owner type */
  mapped_object_id number,               /* Id of mapped object */
  mapped_dim_type number,                /* type of mapped dim */
  mapped_dim_id number,                  /* Id of mapped dim */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_mappings$ on olap_mappings$ (map_id)
/

/************MODELS*************/

create table olap_models$
( 
  owning_obj_type number not null,        /* owning obj number type */
  owning_obj_id number not null,          /* owning obj number ID */
  model_role number not null,             /* role DEFAULT_STRING,...,USER */
  model_id number not null,               /* model ID */
  default_precedence number not null,     /* default precedence */
  model_name varchar2(30) not null,       /* model name */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_models$ on olap_models$ 
  (owning_obj_id, owning_obj_type, model_id)
/

create table olap_model_parents$
( 
  model_id number not null,        /* model id */
  parent_model_id number not null, /* id of parent model */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_model_parents$ on olap_model_parents$
  (model_id, parent_model_id)
/

create table olap_model_assignments$
( 
  model_id number not null,              /* model ID */
  assignment_id number not null,         /* assignment ID */
  precedence number,                     /* precedence */
  order_num number not null,             /* order num */
  calculated_member_id number, /* if null use syntax else use calc member exp */
  member_name varchar2(30),              /* member name */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_model_assignment$ on olap_model_assignments$ 
  (model_id, order_num)
/

create table olap_calculated_members$
(
  dim_obj# number not null,                  /* primary dimension number */
  member_name varchar2(30) not null,         /* member name */
  member_id number not null,                 /* member ID */
  container_dim_id number not null,          /* id of container - e.g. level */
  container_dim_type number not null,        /* type of container */
  parent_member_name varchar2(100),          /* parent member */
  parent_container_id number,                /* parent level id */
  is_customaggregate number(1, 0),           /* is custom aggregate */
  storage_type number(2,0) not null,         /* DYNAMIC or PRECOMPUTE */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_calculated_members$
 on olap_calculated_members$ (dim_obj# asc, member_id asc)
/

/************GENERAL OLAP SUPPORT ***********/

create table olap_syntax$
( 
  ref_role number not null,              /* the role this syntax plays */
  owner_id number not null,              /* ID of owning object */
  owner_type number not null,            /* Type of owning object */
  order_num number not null,             /* the order within a list  */
  syntax_clob clob not null,             /* syntax text stored in clob */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_syntax$
 on olap_syntax$ (ref_role, owner_id, owner_type, order_num)
/

create table olap_descriptions$
( 
  obj# number not null,                   /* id of top level object for query */
  owning_object_type number not null,     /* owning object type */
  owning_object_id number not null,       /* owning object reference ID */
  language varchar2(80) not null,         /* description language */
  description_type varchar2(30) not null, /* description type */
  description_value nvarchar2(300),       /* description value */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_description$ 
 on olap_descriptions$ (owning_object_type, owning_object_id, 
                        language, description_type)
/


/*************INTERACTIONS****************/

create table olap_cube_build_processes$
(
  obj# number not null,                  /* object number */  
  audit$ varchar2(38) not null,          /* auditing options */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_cube_build_processes$ on olap_cube_build_processes$ (obj#)
/

/***************AW VIEWS****************/

create table olap_aw_views$
(
  view_obj# number not null,             /* view obj# */  
  view_type number not null,             /* ET, STAR, REFRESH, REWRITE*/
  olap_object_type number not null,      /* owner type */
  olap_object_id number not null,        /* owner id */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_aw_views$
 on olap_aw_views$ (view_obj#)
/

create table olap_aw_view_columns$
(
  view_obj# number not null,           /* view obj# */  
  column_obj# number not null,         /* column obj# */  
  referenced_object_type number,       /* referenced object type */
  referenced_object_id number,         /* referenced object number */
  level_id number,                     /* hier level number for star views */
  column_type NUMBER not null,         /* OBJECT, KEY, PARENT ...*/
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_aw_view_columns$
 on olap_aw_view_columns$ (view_obj#, column_obj#)
/

/******MEASURE FOLDERS********/

create table olap_measure_folders$
(
  obj# number not null,                 /* Object number */
  audit$ varchar2(38) not null,         /* auditing options */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_measure_folders$ on olap_measure_folders$ (obj#)
/

create table olap_meas_folder_contents$
( 
  measure_folder_obj# number not null,   /* measure folder object number */
  object_type number not null,           /* Type of contained object */
  object_id number not null,             /* ID of contained object */
  order_num number not null,             /* Order of measure within folder */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_meas_folder_contents$ 
 on olap_meas_folder_contents$ (measure_folder_obj#, order_num)
/

/**************DEPLOYMENTS*************/

create table olap_aw_deployment_controls$
( 
  object_role NUMBER not null,         /* role played by physical obj */
  physical_name varchar2(30),          /* name of physical aw object */
  parent_id NUMBER not null,           /* number of owner logical obj */
  parent_type NUMBER not null,         /* type code of owning object */
  awowner# number,                     /* aw owner number */
  awseq# number,                       /* aw sequence number */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create table olap_impl_options$
(
  owning_objectid number not null,       /* owning object ID */
  object_type number not null,           /* object type */ 
  option_type number not null,           /* option type enum */
  option_value varchar2(80),             /* option value */
  option_num_value number,               /* option num value */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_impl_options$ 
    on olap_impl_options$ (owning_objectid, object_type, option_type)
/

/*************DIMENSIONS**************/

create table olap_cube_dimensions$
( 
  awseq# number,                              /* aw sequence number */
  obj# number not null,                       /* object number */
  dimension_type number not null,             /* dimension type */
  audit$ varchar2(38) not null,               /* auditing options */
  is_stale number(1,0) not null,              /* is the dimension stale? */
  default_hierarchy_id number,                /* default hierarchy */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_cube_dimensions$
 on olap_cube_dimensions$ (obj#)
/

create table olap_dim_levels$
(
  dim_obj# number not null,                    /* dimension object nmumber */  
  level_name varchar2(30) not null,            /* level name */
  level_id number not null,                    /* level ID */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_dim_levels$ on olap_dim_levels$ (level_id)
/

create table olap_attributes$
(
  dim_obj# number not null,                      /* prim. dimension number */ 
  attribute_name varchar2(30) not null,          /* attribute name */
  attribute_id number not null,                  /* attribute number */
  target_dim# number,                            /* target dim obj number */
  attribute_role_mask number,                    /* role mask of attribute */
  type# number not null,
  length number not null,
  charsetform number,
  precision# number,
  scale number,
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_attributes$ 
	on olap_attributes$ (dim_obj#, attribute_id asc)
/


create table olap_attribute_visibility$
( 
  attribute_id number not null,        /* attribute number */
  owning_dim_id number not null,       /* ID of dim that sees this attr */
  owning_dim_type number not null,     /* Type of dim that sees this attr */
  order_num number,                    /* Allows vis attrs to be ordered */
  is_unique_key number(1,0),           /* 1 if unique key, 0/null otherwise */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_attribute_visibility$ on olap_attribute_visibility$ 
   (attribute_id, owning_dim_id, owning_dim_type asc)
/

create table olap_hierarchies$
(
  dim_obj# number not null,                    /* dimension object number */
  hierarchy_name varchar2(30) not null,        /* hierarchy name */
  hierarchy_type number not null,              /* hierarchy type */
  hierarchy_id number not null,                /* hierarchy ID */  
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_hierarchies$ on olap_hierarchies$ 
  (dim_obj#, hierarchy_id)
/

create table olap_hier_levels$
( 
  hierarchy_id number not null,           /* ID of owning hierarchy */
  order_num number not null,              /* level order number */
  hierarchy_level_id number not null,     /* hierarchy level ID */
  dim_level_id number not null,           /* ID of dimension level */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_hier_levels$ 
 on olap_hier_levels$ (hierarchy_id, order_num)
/

/**********CUBES***************/

create table olap_cubes$
( 
  awseq# number,                         /* aw sequence */
  obj# number not null,                  /* object number */
  audit$ varchar2(38) not null,          /* auditing options */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_cubes$ on olap_cubes$ (obj#)
/

create table olap_measures$
( 
  cube_obj# number not null,                  /* cube object number */
  measure_name varchar2(30) not null,         /* meausre name */
  measure_id number not null,                 /* measure ID */
  measure_type number(2, 0)  not null,        /* derived vs. base */
  type# number not null,
  length number not null,
  charsetform number,
  precision# number,
  scale number,
  is_stale number(1,0) not null,              /* is the measure stale? */
  is_hidden number(1,0),                      /* is the measure hidden? */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_measures_index$
 on olap_measures$ (cube_obj#, measure_id)
/

create table olap_dimensionality$
( 
  dimensioned_object_id number not null,    /* cube, solve_spec_region, or attribute */
  dimensioned_object_type number not null,  /* type code of dimensioned obj */
  dimensionality_id number not null,        /* dimensionality ID */
  order_num number not null,                /* order within owner */
  dimension_id number not null,             /* ID of dimension  */
  dimension_type number not null,           /* dimension type (hier or level) */
  spare1 number, 
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
)
/

create unique index i_olap_dimensionality$ on olap_dimensionality$ 
  (dimensioned_object_id, dimensioned_object_type, order_num)
/


/* One row in olap_tab$ for every tab$ entry created as ORGANIZATION OLAP */
create table olap_tab$
(obj#   number not null,                           /* Parent table object # */
 awseq# number not null,                                 /* Underlying AW # */
 flags  number not null)                                  /* Physical flags */
                                                   /* 0x01 - On prebuilt AW */
/

create unique index i_olap_tab$
 on olap_tab$(obj#)
/

/* One row in olap_tab_object$ for every column of every entry in olap_tab$ */
create table olap_tab_col$
(obj#    number not null,                          /* Parent table object # */
 col#    number not null,                                  /* Column number */
 pcol#   number,                                    /* Parent column number */
 coltype number not null,                          /* Object type of column */
                                                                /* 1 - Fact */
                                                           /* 2 - Dimension */
                                                               /* 3 - Level */
                                                           /* 4 - Attribute */
                                                         /* 5 - Grouping id */
                                                  /* 6 - Parent grouping id */
                                                            /* 7 - Relation */
 oid     number not null,                            /* Mapped AW object id */
 qdroid  number,                              /* QDRing dimension object id */
 qdrval  varchar2(100),                                      /* QDRed value */
 hier#   number,                          /* Corresponding hierarchy number */
 flags   number not null)                                          /* Flags */
/

create index i_olap_tab_col$
 on olap_tab_col$(obj#)
/

/* One row per level of hierarchy */
create table olap_tab_hier$
(obj#    number not null,                          /* Parent table object # */
 hier#   number not null,          /* Hierarchy number (currently always 1) */
 col#    number not null,                         /* Column number of level */
 ord     number not null,                /* Ordinal of level, starting at 1 */
 flags   number not null)                                          /* Flags */
/
create index i_olap_tab_hier$
 on olap_tab_hier$(obj#)
/

Rem Create the assembly table
Rem the audit$ field length should be the same as S_OPFL defined in gendef.
Rem the filespec and identity fields are the same as M_VCSIZ in gendef.
create table assembly$
( obj#          number not null,            /* object number of the assembly */
  filespec      varchar2(4000),                  /* filename of the assembly */
  security_level number,                          /* assembly security level */
  identity      varchar2(4000),                         /* assembly identity */
  property      number,                                  /* Currently unused */
  audit$        varchar2(38) not null                    /* auditing options */
)
cluster c_obj#(obj#)
/

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@i1101000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1002000.sql
Rem *************************************************************************

