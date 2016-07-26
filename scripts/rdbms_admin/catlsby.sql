Rem
Rem $Header: rdbms/admin/catlsby.sql /st_rdbms_11.2.0.4.0dbpsu/1 2015/01/19 15:24:57 apfwkr Exp $
Rem
Rem catlsby.sql
Rem
Rem Copyright (c) 2000, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catlsby.sql - Logical Standby tables and views
Rem
Rem    DESCRIPTION
Rem      This file implements the following:
Rem      Tables:
Rem         logstdby$parameters
Rem         logstdby$events
Rem         logstdby$apply_progress
Rem         logstdby$apply_milestone
Rem         logstdby$event_options
Rem         logstdby$scn
Rem         logstdby$skip_transaction
Rem         logstdby$skip
Rem         logstdby$skip_support
Rem         logstdby$eds_tables
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/05/15 - Backport apfwkr_blr_backport_18783224_11.2.0.4.0
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      06/05/14 - Backport arjusing_bug-18783224 from main
Rem    gkulkarn    02/22/11 - Backport bug-10155004: Allow xml-OR 
Rem                           typed tables withgkulkarn_bug-10155004 from main
Rem    abrown      01/05/11 - Remove XMLOR and XMLCSX support from event
Rem                           control
Rem    abrown      12/28/10 - Backport bug-10243237: enable csx in 11.2.0.2b
Rem    arjusing    05/27/14 - Bug 18783224: Changes to LOGSTDBY_SUPPORT_TAB_10_1
Rem                           and LOGSTDBY_SUPPORT_TAB_10_2
Rem    abrown      04/29/10 - bug-9479009: correct supported view for xmlor
Rem    abrown      03/23/10 - bug-9501098: XMLOR support
Rem    svivian     10/20/09 - EDS object and varray support
Rem    dvoss       01/29/10 - bug 9271131 - xml on securefile clob unsupported
Rem    svivian     08/31/09 - bug 8846666: dba_logstdby_eds_supported expanded 
Rem                           to include XMLTYPE and more scalars.
Rem    svivian     04/22/09 - refine dba_logstdby_eds_supported
Rem    dvoss       04/16/09 - skip indexes belong in sysaux
Rem    dvoss       04/08/09 - bug 8235260 - skip indexes
Rem    svivian     03/26/09 - add EDS infrastructure
Rem    jkundu      02/17/09 - logstdby$events.spare1 records start_scn of the
Rem                           txn (bug 8260837)
Rem    dvoss       02/05/09 - logstdby$events.event_time should be not null
Rem    dvoss       02/04/09 - add indexes to logstdby$events
Rem    preilly     11/14/08 - Bug 7630082: Check for SecureFiles with Dedup option
Rem    bpwang      09/19/08 - 11.2 supports SecureFiles
Rem    rlong       09/25/08 - 
Rem    nkgopal     08/11/08 - Bug 6830207: Add Alter Database Link changes
Rem    rlong       08/07/08 - 
Rem    myalavar    07/07/08 - 
Rem    svivian     06/10/08 - bug 6487578: add JAVA to logstdby$skip_support
Rem    jkundu      04/23/08 - dba_logstdby_log update for APPLIED column
Rem    myalavar    04/08/08 - add orddata(bug 6759944) to logstdby skip
Rem    rmacnico    03/25/08 - Bug 2931832: support ODCI
Rem    svivian     03/19/08 - add blocks, block_size to dba_logstdby_log
Rem    rmacnico    02/25/08 - Add 11.2 redo compat to supported view
Rem    tchorma     02/08/08 - Remove compression from unsupported views
Rem    dsemler     02/06/08 - Add APPQOSSYS user to exclusion list
Rem    rmacnico    11/26/07 - bug 6528315: support edition in 11.2
Rem    rmacnico    09/14/07 - bug 6406689: unsupported DMLs
Rem    ineall      07/23/07 - Bug 5889516: Disqualify function based index in
Rem                           dba_logstdby_not_unique
Rem    rmacnico    06/14/07 - lrg 3015662: add logstdby$ tabs to noexp$
Rem    rmacnico    05/24/07 - bug 5666482: map primary scn
Rem    rmacnico    05/01/07 - bug 6019939: flashback archive support
Rem    sslim       03/27/07 - Bug 5947235: SBP and Processed SCNs in history
Rem                           table
Rem    rmacnico    03/26/07 - bug 5496852: validate skip on user ddls
Rem    rmacnico    04/11/07 - lrg 2916540: iot overflow tables
Rem    rmacnico    04/04/07 - bug 5971328: increase col width for plsql skip
Rem    rmacnico    03/12/07 - bug 5906232: virtual column primary key
Rem    rmacnico    02/05/07 - bug 5726264: xml store as OR marked sys maint
Rem    rmacnico    01/24/07 - bug 5790970: xml store as csx (binary xml)
Rem    jmzhang     12/20/06 - 5700499: skip table with securefile column
Rem    abrown      10/02/06 - Hierarchically enabled XML tables unsupported in
Rem                           V11
Rem    dvoss       10/12/06 - skip XS$NULL
Rem    rmacnico    09/11/06 - bug 5472731: system, reference partitioned tables
Rem    rmacnico    09/01/06 - lrg 2531243: required synonym
Rem    rmacnico    08/17/06 - 5172550: include AQ in unsupported view
Rem    dvoss       08/01/06 - add xml typed table support
Rem    mtao        07/07/06 - proj 17789: dba_logstdby_log dont show dummy log
Rem    dkapoor     06/16/06 - add ORACLE_OCM in LOGSTDBY30498SKIP_SUPPORT 
Rem    rmacnico    04/20/06 - Add kernal PL/SQL support
Rem    preilly     05/23/06 - Fix UNSUPPORTED view for schema based XML CLOB 
Rem    smangala    05/22/06 - project17789: extend parameters table 
Rem    ineall      03/21/06 - 4601343: Modify view logstdby_support to 
Rem                           avoid ORA-01425 
Rem    rmacnico    03/02/06 - 3584308: handle change in redo compat in lsby
Rem    rmacnico    03/03/06 - 5074345: fix cdef$ flags check
Rem    rmacnico    11/08/05 - cleanup skipped schemas (dglsms)
Rem    sslim       05/26/05 - Reveal corruption state in dba_logstdby_log 
Rem    rmacnico    05/19/05 - Update skip_support categories
Rem    jmzhang     03/23/05 - change default ts for parameter table
Rem    jmzhang     03/29/05 - update dba_logstdby_unsupported
Rem    jmzhang     08/26/04 - remove logstdby_status
Rem                         - remove logstdby_thread
Rem    jmzhang     08/17/04 - add logstdby_status
Rem                           add logstdby_thread
Rem    clei        06/10/04 - disallow encrypted columns
Rem    ajadams     06/15/04 - add index to logstdby events table 
Rem    rgupta      04/23/04 - create tables in SYSAUX tablespace
Rem    ajadams     05/13/04 - add logstdby_transaction 
Rem    jmzhang     05/05/04 - add timestamp to apply_milestone
Rem    jnesheiw    03/11/04 - fix LOGSTDBY_PROGRESS view to show correct 
Rem                           thread# for RAC 
Rem    mcusson     01/15/04 - LogMiner 10g IOT support 
Rem    jnesheiw    12/18/03 - Re-enable partition check 
Rem    raguzman    11/12/03 - use dba_server_registry not dba_registry 
Rem    raguzman    10/29/03 - add list of schema names to skip 
Rem    raguzman    09/24/03 - fix bit check for table_compression
Rem    jmzhang     09/11/03 - fix newest_scn in dba_logstdby_progress
Rem    raguzman    08/28/03 - add column to logstdby_support to support new
Rem                           view logstdby_unsupported_tables for GUI
Rem    jnesheiw    08/28/03 - DBA_LOGSTDBY_PARAMETERS only displays type < 2 
Rem    jmzhang     07/28/03 - fix logstdby_support by adding s.ts#
Rem    gkulkarn    07/09/03 - IOT with mapping table is supported
Rem    jnesheiw    05/19/03 - increase objname size in logstdby$scn
Rem    raguzman    05/27/03 - support view are missing object tables
Rem    raguzman    05/31/03 - real time apply and views
Rem    smangala    05/05/03 - fix bug#2691312: ignore gaps for newest_scn
Rem    narora      03/19/03 - bug 2842797: default value of fetchlwm_scn
Rem    narora      01/13/03 - add fetchlwm_scn to apply_milestone
Rem    raguzman    12/19/02 - add logstdby_support internal use view
Rem    sslim       12/02/02 - lrg 1112873: should not drop tables
Rem    raguzman    11/18/02 - Simply supported queries
Rem    rguzman     07/19/02 - update views for data type support
Rem    rguzman     07/19/02 - do not drop tables, needed for upgrades
Rem    rguzman     10/25/02 - Fix PARAMETERS view and UNSUPPORTED attributes
Rem    jmzhang     10/10/02 - modify the comments of logstdby$parameters 
Rem    rguzman     10/11/02 - Attributes column for DBA_LOGSTDBY_UNSUPPORTED
Rem    jmzhang     09/23/02 - Update system.logstdby$scn
Rem    rguzman     07/07/02 - DBA_LOGSTDBY_PROGRESS must work on RAC
Rem    rguzman     10/01/02 - skip using like feature
Rem    sslim       09/26/02 - Log Stream History Table
Rem    jmzhang     08/12/02 - UPdate DBA_LOGSTDBY_PROGRESS
Rem    jmzhang     08/12/02 - Update DBA_LOGSTDBY_LOG
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    narora      01/17/02 - milestone.spare1 = oldest scn,
Rem                         - spare2=primary syncpoint scn
Rem    rguzman     01/24/02 - Modify UNSUPPORTED view, no ADTs
Rem    cfreiwal    11/14/01 - move logstby views to catlsby.sql
Rem    rguzman     10/12/01 - New columns for logstdby$paramters.
Rem    narora      09/21/01 - remove logstdby_coordinator/slave
Rem    dcassine    08/27/01 - 
Rem    rguzman     09/12/01 - PROGRESS view to report better progress
Rem    dcassine    08/27/01 - LOGSTDBY$APPLY_MILESTONE.PROCESSED_SCN
Rem    jnesheiw    08/02/01 - skip_transaction spare1 name change.
Rem    rguzman     05/18/01 - Fix skip default.
Rem    rguzman     05/17/01 - No Long/Lob support for Alpha kit.
Rem    sslim       05/11/01 - Drop tables before creating them
Rem    jdavison    10/12/00 - Change varchar sizes to 2000.
Rem    narora      08/01/00 - make apply progress a partitioned table
Rem    rguzman     08/11/00 - Views: synonyms, snapshot logs & functional index
Rem    narora      06/20/00 - grant select on v$logstdby_coordinator, 
Rem                         - v$logstdby_apply
Rem    rguzman     05/26/00 - Add views
Rem    rguzman     04/11/00 - Created
Rem

-- This is needed so that SYS can later grant select_catalog to the views.
grant select any table to sys with admin option
/

create table system.logstdby$parameters (
  name            varchar2(30),                 /* The name of the parameter */
  value           varchar2(2000),              /* The value of the parameter */
  type            number,  /* null = internal, 1 = persistent, 2 = sessional */
  scn             number,                          /* null or meaningful scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSTEM
/

create table system.logstdby$events (
  event_time      timestamp not null,  /* The timetamp the event took effect */
  current_scn     number,            /* The change vector SCN for the change */
  commit_scn      number,     /* SCN of commit record for failed transaction */
  xidusn          number,      /* Trans id component of a failed transaction */
  xidslt          number,      /* Trans id component of a failed transaction */
  xidsqn          number,      /* Trans id component of a failed transaction */
  errval          number,                                    /* Error number */
  event           varchar2(2000),      /* first 2000 characters of statement */
  full_event      clob,                            /* The complete statement */
  error           varchar2(2000),      /* error text associated with failure */
  spare1          number,              /* 11.2 (start_scn of the failed txn) */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) LOB (full_event) STORE AS (TABLESPACE SYSAUX CACHE PCTVERSION 0
                             CHUNK 16k STORAGE (INITIAL 16K NEXT 16K))
TABLESPACE SYSAUX LOGGING 
/

create index system.logstdby$events_ind
      on system.logstdby$events (event_time asc) tablespace SYSAUX LOGGING;

create index system.logstdby$events_ind_scn
      on system.logstdby$events (commit_scn asc) tablespace SYSAUX LOGGING;

create index system.logstdby$events_ind_xid
      on system.logstdby$events (xidusn, xidslt, xidsqn asc)
      tablespace SYSAUX LOGGING;

-- Turns off partition check --
alter session set events  '14524 trace name context forever, level 1';

create table system.logstdby$apply_progress (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  commit_scn      number,    /* SCN of commit record for applied transaction */
  commit_time     date,     /* The timestamp corresponding to the commit scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX 
partition by range (commit_scn) (partition P0 values less than (0))
/

-- Turns on partition check --
alter session set events  '14524 trace name context off';

create table system.logstdby$apply_milestone (
  session_id      number not null,                   /* Log miner session id */
  commit_scn      number not null,                         /* low-water mark */
  commit_time     date,                                /* low-water mark time*/
  synch_scn       number not null,                       /* Synch-point SCN. */
  epoch           number not null,    /* Incarnation number for apply engine */
  processed_scn   number not null, /* all comp txn<processed_scn are applied */
  processed_time  date,             /*timestamp corresponding to process_scn */
  fetchlwm_scn    number default(0) not null,    /* maximum SCN ever fetched */
  spare1          number,                                /* oldest_scn       */
  spare2          number,                           /* primary syncpoint scn */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

Rem   Logical Instantiation, beginning scn for each table.
create table system.logstdby$scn (
  obj#      number,
  objname   varchar2(4000),
  schema    varchar2(30),
  type      varchar2(20),
  scn       number,
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

Rem   Logical flashback scn for equivalent primary scn 
create table system.logstdby$flashback_scn (
primary_scn     number not null primary key,
primary_time    date,
standby_scn     number,
standby_time    date,
spare1          number,
spare2          number,
spare3          date
) tablespace SYSAUX
/

Rem TODO remove obsolete table
create table system.logstdby$plsql (
  session_id      number,               /* Id of session issuing the command */
  start_finish    number,        /* Boolean, 0 = 1st record, 1 = last record */
  call_text       clob,                   /* Text of call to pl/sql routine. */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$skip_transaction (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  active          number,           /* Boolean to indicate current or active */
  commit_scn      number,                    /* SCN at which tx commited at  */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$skip (
  error           number,            /* Should statement or error be skipped */
  statement_opt   varchar2(30),                /* name from audit_actions or */
                                               /*      logstdby$skip_support */
  schema          varchar2(30),      /* schema name for object being skipped */
  name            varchar2(65),       /* name of object or pack.proc skipped */
  use_like        number, /* 0 = exact match, 1 = like, 2 = like with escape */
  esc             varchar2(1),             /* Escape character if using like */
  proc            varchar2(98),      /* schema.package.proc to call for skip */
  active          number,                                        /* not used */
  spare1          number,         /* 1 if internally generated, null if user */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create index system.logstdby$skip_idx1 on
          system.logstdby$skip (use_like, schema, name)
       tablespace SYSAUX LOGGING;

create index system.logstdby$skip_idx2 on
          system.logstdby$skip (statement_opt)
       tablespace SYSAUX LOGGING;

Rem   Statement auditting options for objects encoded here for skip support
create table system.logstdby$skip_support (
  action          number not null,    /* number as seen in sys.audit_actions */
                   /* reserving actions 0 & -1 for internal skip schema list */
  name            varchar2(30) not null,         /* action to skip or schema */
  reg             smallint,                            /* from dbms_registry */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

/* previously we dropped and recreated to control contents */
delete from system.logstdby$skip_support;

insert into system.logstdby$skip_support                           /* INSERT */
             (action, name, reg) values (2, 'DML', 0);
insert into system.logstdby$skip_support                           /* UPDATE */
             (action, name, reg) values (6, 'DML', 0);
insert into system.logstdby$skip_support                           /* DELETE */
             (action, name, reg) values (7, 'DML', 0);

/* SCHEMA_DDL & NONSCHEMA_DDL determined by null/non-null owner and name */

insert into system.logstdby$skip_support                   /* CREATE CLUSTER */
             (action, name, reg) values (4, 'CLUSTER', 0);
insert into system.logstdby$skip_support                    /* ALTER CLUSTER */
             (action, name, reg) values (5, 'CLUSTER', 0);
insert into system.logstdby$skip_support                     /* DROP CLUSTER */
             (action, name, reg) values (8, 'CLUSTER', 0);
insert into system.logstdby$skip_support                 /* TRUNCATE CLUSTER */
             (action, name, reg) values (86, 'CLUSTER', 0);

insert into system.logstdby$skip_support                   /* CREATE CONTEXT */
             (action, name, reg) values (177, 'CONTEXT', 0);
insert into system.logstdby$skip_support                     /* DROP CONTEXT */
             (action, name, reg) values (178, 'CONTEXT', 0);

insert into system.logstdby$skip_support             /* CREATE DATABASE LINK */
             (action, name, reg) values (32, 'DATABASE LINK', 0);
insert into system.logstdby$skip_support               /* DROP DATABASE LINK */
             (action, name, reg) values (33, 'DATABASE LINK', 0);
insert into system.logstdby$skip_support              /* ALTER DATABASE LINK */
             (action, name, reg) values (225, 'DATABASE LINK', 0);

insert into system.logstdby$skip_support                 /* CREATE DIMENSION */
             (action, name, reg) values (174, 'DIMENSION', 0);
insert into system.logstdby$skip_support                  /* ALTER DIMENSION */
             (action, name, reg) values (175, 'DIMENSION', 0);
insert into system.logstdby$skip_support                   /* DROP DIMENSION */
             (action, name, reg) values (176, 'DIMENSION', 0);

insert into system.logstdby$skip_support                 /* CREATE DIRECTORY */
             (action, name, reg) values (157, 'DIRECTORY', 0);
insert into system.logstdby$skip_support                   /* DROP DIRECTORY */
             (action, name, reg) values (158, 'DIRECTORY', 0);

insert into system.logstdby$skip_support                     /* CREATE INDEX */
             (action, name, reg) values (9, 'INDEX', 0);
insert into system.logstdby$skip_support                      /* ALTER INDEX */
             (action, name, reg) values (11, 'INDEX', 0);
insert into system.logstdby$skip_support                       /* DROP INDEX */
             (action, name, reg) values (10, 'INDEX', 0);

insert into system.logstdby$skip_support                 /* CREATE PROCEDURE */
             (action, name, reg) values (24, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                  /* ALTER PROCEDURE */
             (action, name, reg) values (25, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* DROP PROCEDURE */
             (action, name, reg) values (68, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                  /* CREATE FUNCTION */
             (action, name, reg) values (91, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* ALTER FUNCTION */
             (action, name, reg) values (92, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* DROP FUNCTION */
             (action, name, reg) values (93, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* CREATE PACKAGE */
             (action, name, reg) values (94, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* ALTER PACKAGE */
             (action, name, reg) values (95, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                     /* DROP PACKAGE */
             (action, name, reg) values (96, 'PROCEDURE', 0);
insert into system.logstdby$skip_support              /* CREATE PACKAGE BODY */
             (action, name, reg) values (97, 'PROCEDURE', 0);
insert into system.logstdby$skip_support               /* ALTER PACKAGE BODY */
             (action, name, reg) values (98, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                /* DROP PACKAGE BODY */
             (action, name, reg) values (99, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                   /* CREATE LIBRARY */
             (action, name, reg) values (159, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                    /* ALTER LIBRARY */
             (action, name, reg) values (196, 'PROCEDURE', 0);
insert into system.logstdby$skip_support                     /* DROP LIBRARY */
             (action, name, reg) values (84, 'PROCEDURE', 0);

insert into system.logstdby$skip_support                   /* CREATE PROFILE */
             (action, name, reg) values (65, 'PROFILE', 0);
insert into system.logstdby$skip_support                    /* ALTER PROFILE */
             (action, name, reg) values (67, 'PROFILE', 0);
insert into system.logstdby$skip_support                     /* DROP PROFILE */
             (action, name, reg) values (66, 'PROFILE', 0);

insert into system.logstdby$skip_support                      /* CREATE ROLE */
             (action, name, reg) values (52, 'ROLE', 0);
insert into system.logstdby$skip_support                       /* ALTER ROLE */
             (action, name, reg) values (79, 'ROLE', 0);
insert into system.logstdby$skip_support                        /* DROP ROLE */
             (action, name, reg) values (54, 'ROLE', 0);
insert into system.logstdby$skip_support                         /* SET ROLE */
             (action, name, reg) values (55, 'ROLE', 0);

insert into system.logstdby$skip_support          /* CREATE ROLLBACK SEGMENT */
             (action, name, reg) values (36, 'ROLLBACK STATEMENT', 0);
insert into system.logstdby$skip_support           /* ALTER ROLLBACK SEGMENT */
             (action, name, reg) values (37, 'ROLLBACK STATEMENT', 0);
insert into system.logstdby$skip_support            /* DROP ROLLBACK SEGMENT */
             (action, name, reg) values (38, 'ROLLBACK STATEMENT', 0);

insert into system.logstdby$skip_support                  /* CREATE SEQUENCE */
             (action, name, reg) values (13, 'SEQUENCE', 0);
insert into system.logstdby$skip_support                   /* ALTER SEQUENCE */
             (action, name, reg) values (14, 'SEQUENCE', 0);
insert into system.logstdby$skip_support                    /* DROP SEQUENCE */
             (action, name, reg) values (16, 'SEQUENCE', 0);

insert into system.logstdby$skip_support                   /* CREATE SYNONYM */
             (action, name, reg) values (19, 'SYNONYM', 0);
insert into system.logstdby$skip_support                     /* DROP SYNONYM */
             (action, name, reg) values (20, 'SYNONYM', 0);
insert into system.logstdby$skip_support            /* CREATE PUBLIC SYNONYM */
             (action, name, reg) values (110, 'SYNONYM', 0);
insert into system.logstdby$skip_support              /* DROP PUBLIC SYNONYM */
             (action, name, reg) values (111, 'SYNONYM', 0);

insert into system.logstdby$skip_support                     /* CREATE TABLE */
             (action, name, reg) values (1, 'TABLE', 0);
insert into system.logstdby$skip_support                      /* ALTER TABLE */
             (action, name, reg) values (15, 'TABLE', 0);
insert into system.logstdby$skip_support                       /* DROP TABLE */
             (action, name, reg) values (12, 'TABLE', 0);
insert into system.logstdby$skip_support                   /* TRUNCATE TABLE */
             (action, name, reg) values (85, 'TABLE', 0);
                                                /* COMMENT ON TABLE included */

insert into system.logstdby$skip_support                /* CREATE TABLESPACE */
             (action, name, reg) values (39, 'TABLESPACE', 0);
insert into system.logstdby$skip_support                 /* ALTER TABLESPACE */
             (action, name, reg) values (40, 'TABLESPACE', 0);
insert into system.logstdby$skip_support                  /* DROP TABLESPACE */
             (action, name, reg) values (41, 'TABLESPACE', 0);

insert into system.logstdby$skip_support                   /* CREATE TRIGGER */
             (action, name, reg) values (59, 'TRIGGER', 0);
insert into system.logstdby$skip_support                    /* ALTER TRIGGER */
             (action, name, reg) values (60, 'TRIGGER', 0);
insert into system.logstdby$skip_support                     /* DROP TRIGGER */
             (action, name, reg) values (61, 'TRIGGER', 0);
insert into system.logstdby$skip_support                   /* ENABLE TRIGGER */
             (action, name, reg) values (118, 'TRIGGER', 0);
insert into system.logstdby$skip_support                  /* DISABLE TRIGGER */
             (action, name, reg) values (119, 'TRIGGER', 0);
insert into system.logstdby$skip_support              /* ENABLE ALL TRIGGERS */
             (action, name, reg) values (120, 'TRIGGER', 0);
insert into system.logstdby$skip_support             /* DISABLE ALL TRIGGERS */
             (action, name, reg) values (121, 'TRIGGER', 0);

insert into system.logstdby$skip_support                      /* CREATE TYPE */
             (action, name, reg) values (77, 'TYPE', 0);
insert into system.logstdby$skip_support                        /* DROP TYPE */
             (action, name, reg) values (78, 'TYPE', 0);
insert into system.logstdby$skip_support                       /* ALTER TYPE */
             (action, name, reg) values (80, 'TYPE', 0);
insert into system.logstdby$skip_support                 /* CREATE TYPE BODY */
             (action, name, reg) values (81, 'TYPE', 0);
insert into system.logstdby$skip_support                  /* ALTER TYPE BODY */
             (action, name, reg) values (82, 'TYPE', 0);
insert into system.logstdby$skip_support                   /* DROP TYPE BODY */
             (action, name, reg) values (83, 'TYPE', 0);

insert into system.logstdby$skip_support                      /* CREATE USER */
             (action, name, reg) values (51, 'USER', 0);
insert into system.logstdby$skip_support                       /* ALTER USER */
             (action, name, reg) values (43, 'USER', 0);
insert into system.logstdby$skip_support                        /* DROP USER */
             (action, name, reg) values (53, 'USER', 0);

insert into system.logstdby$skip_support                      /* CREATE VIEW */
             (action, name, reg) values (21, 'VIEW', 0);
insert into system.logstdby$skip_support                        /* DROP VIEW */
             (action, name, reg) values (22, 'VIEW', 0);

insert into system.logstdby$skip_support                            /* GRANT */
             (action, name, reg) values (17, 'GRANT', 0);
insert into system.logstdby$skip_support                           /* REVOKE */
             (action, name, reg) values (18, 'REVOKE', 0);

insert into system.logstdby$skip_support                            /* AUDIT */
             (action, name, reg) values (30, 'AUDIT', 0);
insert into system.logstdby$skip_support                          /* NOAUDIT */
             (action, name, reg) values (31, 'AUDIT', 0);

insert into system.logstdby$skip_support                   /* CREATE EDITION */
             (action, name, reg) values (212, 'EDITION', 0);
insert into system.logstdby$skip_support                    /* ALTER EDITION */
             (action, name, reg) values (213, 'EDITION', 0);
insert into system.logstdby$skip_support                     /* DROP EDITION */
             (action, name, reg) values (214, 'EDITION', 0);

insert into system.logstdby$skip_support                      /* CREATE JAVA */
             (action, name, reg) values (160, 'JAVA', 0);
insert into system.logstdby$skip_support                       /* ALTER JAVA */
             (action, name, reg) values (161, 'JAVA', 0);
insert into system.logstdby$skip_support                        /* DROP JAVA */
             (action, name, reg) values (162, 'JAVA', 0);

-- These placeholders do not correspond to valid octdef's
insert into system.logstdby$skip_support                /* EXECUTE PROCEDURE */
             (action, name, reg) values (1000000, 'PL/SQL', 0);
insert into system.logstdby$skip_support         /* DDL in EXECUTE PROCEDURE */
             (action, name, reg) values (1000001, 'PL/SQL_DDL', 0);

commit;


Rem
Rem   List of schemas that ship with database
Rem   This list should match select username from dba_users on a shiphome.
Rem   action = 0  means we will skip acitivity in that schema
Rem   action = -1 means we will not skip acitivity in that schema
Rem   reg = 0 means we already know about this internal schema
Rem   reg = 1 means schema was registered by dbms_registry.loading
Rem

insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'ADAMS', 0);
insert into system.logstdby$skip_support               /* HTTP access to XDB */
                  (action, name, reg) values (0, 'ANONYMOUS', 0);
insert into system.logstdby$skip_support                  /* QOS system user */
                  (action, name, reg) values (0, 'APPQOSSYS', 0);
insert into system.logstdby$skip_support            /* Business Intelligence */
                  (action, name, reg) values (0, 'BI', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'BLAKE', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'CLARK', 0);
insert into system.logstdby$skip_support                             /* Text */
                  (action, name, reg) values (0, 'CTXSYS', 0);
insert into system.logstdby$skip_support   /* Directory Integration Platform */
                  (action, name, reg) values (0, 'DIP', 0);
insert into system.logstdby$skip_support               /* SNMP agent for OEM */
                  (action, name, reg) values (0, 'DBSNMP', 0);
insert into system.logstdby$skip_support                      /* Data Mining */
                  (action, name, reg) values (0, 'DMSYS', 0);
insert into system.logstdby$skip_support        /* External ODCI System User */
                  (action, name, reg) values (0, 'EXDSYS', 0);
insert into system.logstdby$skip_support                /* Expression Filter */
                  (action, name, reg) values (0, 'EXFSYS', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'HR', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'IX', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'JONES', 0);
insert into system.logstdby$skip_support                   /* Label Security */
                  (action, name, reg) values (0, 'LBACSYS', 0);
insert into system.logstdby$skip_support                /* Spatial user data */
                  (action, name, reg) values (-1, 'MDDATA', 0);
insert into system.logstdby$skip_support                          /* Spatial */
                  (action, name, reg) values (0, 'MDSYS', 0);
insert into system.logstdby$skip_support             /* OEM Database Control */
                  (action, name, reg) values (0, 'MGMT_VIEW', 0);
insert into system.logstdby$skip_support            /* MS Transaction Server */
                  (action, name, reg) values (0, 'MTSSYS', 0);
insert into system.logstdby$skip_support                      /* Data Mining */
                  (action, name, reg) values (0, 'ODM', 0);
insert into system.logstdby$skip_support           /* Data Mining Repository */
                  (action, name, reg) values (0, 'ODM_MTR', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'OE', 0);
insert into system.logstdby$skip_support                    /* OLAP catalogs */
                  (action, name, reg) values (0, 'OLAPSYS', 0);
insert into system.logstdby$skip_support  /* Oracle Configuration Manager User*/
                  (action, name, reg) values (0, 'ORACLE_OCM', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDDATA', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDPLUGINS', 0);
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name, reg) values (0, 'ORDSYS', 0);
insert into system.logstdby$skip_support        /* Outlines (Plan Stability) */
                  (action, name, reg) values (0, 'OUTLN', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'PM', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'SCOTT', 0);
insert into system.logstdby$skip_support               /* SQL/MM Still Image */
                  (action, name, reg) values (0, 'SI_INFORMTN_SCHEMA', 0);
insert into system.logstdby$skip_support                    /* Sample Schema */
                  (action, name, reg) values (-1, 'SH', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYS', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'SYSTEM', 0);
insert into system.logstdby$skip_support                /* Adminstrator OEM */
                  (action, name, reg) values (0, 'SYSMAN', 0);
insert into system.logstdby$skip_support    /* Transparent Session Migration */
                  (action, name, reg) values (0, 'TSMSYS', 0);
insert into system.logstdby$skip_support                      /* Ultrasearch */
                  (action, name, reg) values (0, 'WKPROXY', 0);
insert into system.logstdby$skip_support                      /* Ultrasearch */
                  (action, name, reg) values (0, 'WKSYS', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'WK_TEST', 0);
insert into system.logstdby$skip_support                /* Workspace Manager */
                  (action, name, reg) values (0, 'WMSYS', 0);
insert into system.logstdby$skip_support                           /* XML DB */
                  (action, name, reg) values (0, 'XDB', 0);
insert into system.logstdby$skip_support
                  (action, name, reg) values (0, 'XS$NULL', 0);
insert into system.logstdby$skip_support                       /* Time Index */
                  (action, name, reg) values (0, 'XTISYS', 0);
commit;

create unique index system.logstdby$skip_ind
      on system.logstdby$skip_support (name, action) tablespace SYSAUX;

insert into system.logstdby$skip_support (action, name, reg)
  select distinct 0, d.schema, 1 from dba_server_registry d
  where not exists (select name from system.logstdby$skip_support s
                    where d.schema = s.name and s.action in (-1,0));
commit;


Rem   Maintains history of log streams processed.
create table system.logstdby$history (
  stream_sequence#  number,                             /* Stream identifier */
  lmnr_sid          number,                           /* LogMiner session id */
  dbid              number,                                          /* DBID */
  first_change#     number,                  /* Starting scn for this stream */
  last_change#      number,                      /* Last scn for this stream */
  source            number,                            /* Stream info source */
  status            number,                             /* Processing status */
  first_time        date,             /* Time corresponding to first_change# */
  last_time         date,              /* Time corresponding to last_change# */
  dgname            varchar2(255),                  /* Dataguard name string */
  spare1            number,                    /* standby became primary scn */
  spare2            number,                                 /* processed scn */
  spare3            varchar2(2000)                       /* Future expansion */
) tablespace SYSAUX
/

	
Rem
Rem EDS support
Rem
create table system.logstdby$eds_tables (
  owner                 varchar2(30),                         /* table owner */
  table_name            varchar2(30),                     /* base table name */
  shadow_table_name     varchar2(30),                   /* shadow table name */
  base_trigger_name     varchar2(30),             /* base table trigger name */
  shadow_trigger_name   varchar2(30),           /* shadow table trigger name */
  dblink                varchar2(255),                        /* dblink name */
  flags                 number,                                     /* flags */
  state                 varchar2(255),                    /* BEGUN, COMPLETE */
  objv                  number,        /* local object version of base table */
  obj#                  number,               /* local object# of base table */
  sobj#                 number,             /* local object# of shadow table */
  ctime                 timestamp,     /* timestamp when table support added */
  spare1                number,                        /* spare number field */
  spare2                varchar2(255),                /* spare varchar field */
  spare3                number,                        /* spare number field */
  constraint logstdby$eds_tables_pkey primary key (owner, table_name)
) tablespace SYSAUX
/

Rem
Rem  Create views over the metadata tables.
Rem

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT View for internal use only
-- This view makes up the basis for a number of queries made by logical
-- standby to make decisions about what tables to support.  This view along
-- with the dba_logstdby_unsupported view must be modified when ever the
-- collection of data types or table support changes.  If you make a change
-- here, you'll almost certainly need a change there.  All the tables and 
-- sequences are displayed here, but only those with generated_sby == 1
-- will be maintained by logical standby.
--
-- this view is a union of two views:
--  logstdby_support_stab - supported tables
--  logstdby_support_seq  - supported sequences

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_10_1
-- This view encapsulates 10.1 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_10_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 262208) = 262208   /* 0x40+0x40000 IOT + user LOB */
    or bitand(t.property, 2112) = 2112     /* 0x40+0x800 IOT + internal LOB */
    or                                           /* IOT with "Row Movement" */
      (bitand(t.property, 64) = 64 and bitand(t.flags, 131072) = 131072)
    or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
    or bitand(t.property,
                  1        /* 0x00000001                        typed table */
                + 2        /* 0x00000002                    has ADT columns */
                + 4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
              + 128        /* 0x00000080              IOT with row overflow */
              + 256        /* 0x00000100            IOT with row clustering */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               and bitand(c.property, 32) != 32                /* Not hidden */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
               and (c.type# != 23                         /* RAW not RAW OID */
               or  (c.type# = 23 and bitand(c.property, 2) = 2))) 
             -----------------------------------------
             or (c.type# in (8,24,112,113)
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                          )))))
             -----------------------------------------
   then 0 else 1 end) gensby
   from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
   where o.owner# = u.user#
   and o.obj# = t.obj#
   and t.file# = s.file# (+)
   and t.block# = s.block# (+)
   and t.ts# = s.ts# (+)
   and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_10_2
-- This view encapsulates 10.2 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_10_2
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
    or bitand(t.property,
             /* The following column properties are not checked in the
              * common section because they are reflected in the column
              * definitions and we want to see just those columns */
                  1        /* 0x00000001                        typed table */
                + 2        /* 0x00000002                    has ADT columns */
                + 4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
               and bitand(c.property, 32) != 32                /* Not hidden */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))) 
             -----------------------------------------
             or (c.type# in (8,24,112,113)
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                          )))))
             -----------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

-----------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_11LOB
-- This is a help view for logstdby_support_11_1. Eventually, we want to
-- move all the logic here to logstdby_support_11_1 inline.
-- NOTE:
-- THis view indicates whether a lob is a securefile or has at least one
-- securefile partition. The dedupsecurefile indicates that the securefile
-- has the deduplicte option enabled.
------------------------------------------------------------------------
create or replace view logstdby_support_11lob
as
 select lb.obj#, lb.lobj#, lb.col#, 
    (case 
     when (bitand(lb.property, 4) = 4) /* the lob colum is partitioned */
     then 
       case
       when (exists       /* composite partitioned lob */
                   (select 1 
                    from sys.lobfrag$ lf1, sys.lobcomppart$ cm  
                    where lb.lobj# = cm.lobj#
                    and cm.partobj# = lf1.parentobj#
                    and bitand(lf1.fragpro, 2048) = 2048)
            or
             exists       /* regular partitioned lob */
                  (select 1
                   from sys.lobfrag$ lf2
                   where lb.lobj# = lf2.parentobj#
                   and bitand(lf2.fragpro, 2048) = 2048))
       then 1 else 0 end
     else                               /* non-partitioned lob */
       case
       when bitand(lb.property, 2048) = 2048 /* this is a securefile column */
       then 1 else 0 end   
     end) securefile,
    (case 
     when (bitand(lb.property, 4) = 4) /* the lob colum is partitioned */
     then 
       case
       when (exists       /* composite partitioned lob */
                   (select 1 
                    from sys.lobfrag$ lf1, sys.lobcomppart$ cm  
                    where lb.lobj# = cm.lobj#
                    and cm.partobj# = lf1.parentobj#
                    and bitand(lf1.fragflags, 
                                 65536    /* 0x10000 = Sharing: LOB level */
                               + 131072   /* 0x20000 = Sharing: Object level */
                               + 262144   /* 0x40000 = Sharing: Validate */
                               ) != 0)    /* this is a dedup securefile */
            or
             exists       /* regular partitioned lob */
                  (select 1
                   from sys.lobfrag$ lf2
                   where lb.lobj# = lf2.parentobj#
                   and bitand(lf2.fragflags, 
                                 65536    /* 0x10000 = Sharing: LOB level */
                              + 131072    /* 0x20000 = Sharing: Object level */
                              + 262144    /* 0x40000 = Sharing: Validate */
                              ) != 0))     /* this is a dedup securefile */
       then 1 else 0 end
     else                               /* non-partitioned lob */
       case
       when bitand(lb.property, 2048) = 2048
            and bitand(lb.flags, 
                         65536    /* 0x10000 = Sharing: LOB level */
                       + 131072   /* 0x20000 = Sharing: Object level */
                       + 262144   /* 0x40000 = Sharing: Validate */
                       ) != 0     /* this is a dedup securefile */
       then 1 else 0 end   
     end) dedupsecurefile       
from sys.lob$ lb
/


---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_2
-- This view encapsulates 11.2 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_2
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND not exists                /* Only XML Typed Tables Are Supported */
          (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0))     /* not hierarch enab */
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below */
                  4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                  or (c.type# = 58                        /* XMLTYPE as CLOB */
                      and not exists (select 1 from opqtype$ opq
                                       where opq.type=1 
                                         and bitand(opq.flags, 4) = 4
                                         and bitand(opq.flags,64) = 0
                                         and bitand(opq.flags,512) = 0
                                         and opq.obj#=c.obj# 
                                         and opq.intcol#=c.intcol#))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and bitand(t.property, 1) = 0         /* typed table has an OID */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                )))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                          where lb.obj# = o.obj# 
                            and lb.col# = c.col#
                            and lb.dedupsecurefile = 1))
             -----------------------------------------
             /* table has a virtual column candidate key */
             or (bitand(c.property, 65544) != 0            /* Virtual Column */
             and bitand(c.property, 256) = 0                /* Sys Generated */
             and c.obj# = t.obj#
             and exists (select 1 from icol$ ic, ind$ i
                          where ic.bo# = t.obj# and ic.col# = c.col#
                            and i.bo# = t.obj# and i.obj# = ic.obj#
                            and bitand(i.property, 1) = 1))) /* Unique Index */
             ) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_1
-- This view encapsulates 11.1 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_1
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND not exists                /* Only XML Typed Tables Are Supported */
          (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0       /* not hierarch enab */
                   and not exists (select 1 from logstdby_support_11lob lb
                                    where lb.obj# = o.obj# 
                                      and lb.securefile = 1)))
    or (bitand(nvl(s.spare1,0), 2048) = 2048                 /* Compression */
        and bitand(t.property, 32) != 32) 
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below */
                  4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and ((c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                  or (c.type# = 58                        /* XMLTYPE as CLOB */
                      and not exists
                              (select 1 from opqtype$ opq
                                where opq.type=1 
                                  and bitand(opq.flags, 4) = 4
                                  and bitand(opq.flags,64) = 0
                                  and bitand(opq.flags,512) = 0
                                  and opq.obj#=c.obj# 
                                  and opq.intcol#=c.intcol#
                                  and not exists 
                                          (select 1
                                             from logstdby_support_11lob lb
                                            where lb.obj# = c.obj# 
                                              and lb.col# = c.col#
                                              and lb.securefile = 1)))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and bitand(t.property, 1) = 0         /* typed table has an OID */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                   )))
             -----------------------------------------
             /* table has a securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                          where lb.obj# = o.obj# 
                            and lb.col# = c.col#
                            and lb.securefile = 1))
             -----------------------------------------
             /* table has a virtual column candidate key */
             or (bitand(c.property, 65544) != 0            /* Virtual Column */
             and bitand(c.property, 256) = 0                /* Sys Generated */
             and c.obj# = t.obj#
             and exists (select 1 from icol$ ic, ind$ i
                          where ic.bo# = t.obj# and ic.col# = c.col#
                            and i.bo# = t.obj# and i.obj# = ic.obj#
                            and bitand(i.property, 1) = 1))) /* Unique Index */
             ) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_TAB_11_2b
--   Adds support for XML OR
--
-- This view encapsulates 11.2.0.3 compatibility support
--   gensby:       1 supported, 
--                 -1 internal so not supported   
--                 0 user data not supported because of features     
--   current_sby:  1 if lsby bit set in tab$ else 0
--
create or replace view logstdby_support_tab_11_2b
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(t.flags, 1073741824), 1073741824, 1, 0) current_sby,
 (case 
    /* The following are tables that are system maintained */
  when ( exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists (select 1 from sys.mlog$ ml                    /* MVLOG table */
               where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when (bitand(t.property, 1 ) = 1    /* 0x00000001             typed table */
        AND ((bitand(t.property, 4096) = 4096)                     /* pk oid */
             OR not exists            /* Only XML Typed Tables Are Supported */
                (select 1
                 from  sys.col$ cc, sys.opqtype$ opq
                 where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and (bitand(opq.flags,1) = 1 or      /* stored as object */
                        bitand(opq.flags,68) = 4 or      /* stored as lob */
                        bitand(opq.flags,68) = 68)      /*  stored as binary */
                   and bitand(opq.flags,512) = 0 )))   /* not hierarch enab */
    or (bitand(t.property, 32) = 32)                         /* Partitioned */
      and exists (select 1 from partobj$ po
                  where po.obj#=o.obj#
                  and  (po.parttype in (3,             /* System partitioned */
                                        5)))        /* Reference partitioned */
    or bitand(t.property,
             /* This clause is only for performance; they could be
                excluded by the column datatype checks below. */
              32768        /* 0x00008000                   has FILE columns */
           + 131072        /* 0x00020000 table is used as an AQ queue table */
             ) != 0
             -----------------------------------------
             /* unsupp view joins col$, here we subquery it */
    or exists (select 1 from sys.col$ c 
               where t.obj# = c.obj#
             -----------------------------------------
             /*  ignore any hidden columns in this subquery */
               and bitand(c.property, 32) != 32                /* Not hidden */
             -----------------------------------------
             /* table has an unsupported datatype */
               and (c.type# not in ( 
                                  1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  8,                                 /* LONG */
                                  12,                                /* DATE */
                                  24,                            /* LONG RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  112,                     /* CLOB and NCLOB */
                                  113,                               /* BLOB */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                  and (c.type# != 23                      /* RAW not RAW OID */
                  or (c.type# = 23 and bitand(c.property, 2) = 2))
                  and (c.type# != 58                               /* OPAQUE */
                    or (c.type# = 58                   /* XMLTYPE as CLOB */
                        and 
                         (not exists
                          (select 1 from opqtype$ opq
                            where opq.type=1 
                            and (bitand(opq.flags,1) = 1 or /* stored as obj */
                                 bitand(opq.flags,68) = 4 or /* stored a lob */
                                 bitand(opq.flags,68) = 68) /* store binary */
                            and bitand(opq.flags,512) = 0    /* not hierarch */
                            and opq.obj#=c.obj# 
                            and opq.intcol#=c.intcol#)))))
             -----------------------------------------
             /* table doesn't have at least one scalar column */
             or (c.type# in (8,24,58,112,113)
             and (bitand(t.property, 1) = 0          /* not a typed table or */
             and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and bitand(c2.property, 8) != 8                /* Not virtual */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                ))))
             -----------------------------------------
             /* table has a dedup securefile column */
             or  (c.type# in (112, 113)
             and exists (select 1 from logstdby_support_11lob lb
                      where lb.obj# = o.obj# 
                      and lb.col# = c.col#
                      and dedupsecurefile = 1))) /* end col$ exists subquery */
----------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = o.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY$TABF
-- This table function implements the redo compatibility check 
-- for logstdby support dependant on database role
--
-- must drop dependant table before create or replace
drop type logstdby$srecs;
create or replace type logstdby$srec 
is object (
  OWNER       VARCHAR2(30),
  NAME        VARCHAR2(30),
  TYPE#       NUMBER,
  OBJ#        NUMBER,
  CURRENT_SBY NUMBER,
  GENSBY      NUMBER)
/

create or replace type logstdby$srecs 
is table of logstdby$srec
/

create or replace function logstdby$tabf (request in varchar2 default null)
return logstdby$srecs pipelined parallel_enable
is
  lsby_object_row logstdby$srec := logstdby$srec('','',0,0,0,0);
  type lsby_tcur is ref cursor return logstdby_support_tab_10_1%ROWTYPE;
  dataset lsby_tcur;
  lsby_query_row dataset%ROWTYPE;
  cmpat varchar2(6);
  patchno varchar2(6);
  fullcmpat varchar2(12);
  role  varchar2(16);
begin
  if request is null then
    select database_role into role from sys.v$database;
  else
    role := request;
  end if;

  if role = 'PRIMARY' then
    select substr(value,1,8) into fullcmpat
    from sys.v$parameter where name = 'compatible';
  else
    select nvl(
      (select substr(s.redo_compat,1,8) 
       from system.logstdby$parameters p, system.logmnr_session$ s
       where p.name = 'LMNR_SID' and p.value = s.session#),
      (select substr(value,1,8) from sys.v$parameter
       where name = 'compatible')) into fullcmpat from dual;
  end if;
  cmpat := substr(fullcmpat, 1, 4);
  patchno := substr(fullcmpat, 8, 1);
 
  if '11.2' = cmpat then
    if patchno >= '3' then
      cmpat := '11.2b';    
    end if;
  end if;

  case cmpat
  when '10.0' then
    open dataset for select * from logstdby_support_tab_10_1;
  when '10.1' then
    open dataset for select * from logstdby_support_tab_10_1;
  when '10.2' then
    open dataset for select * from logstdby_support_tab_10_2;
  when '11.0' then
    open dataset for select * from logstdby_support_tab_11_1;
  when '11.1' then
    open dataset for select * from logstdby_support_tab_11_1;
  when '11.2' then
    open dataset for select * from logstdby_support_tab_11_2;
  when '11.2b' then
    open dataset for select * from logstdby_support_tab_11_2b;
  else
    open dataset for select * from logstdby_support_tab_10_1;
  end case;

  loop
    fetch dataset into lsby_query_row;
    exit when dataset%NOTFOUND;
    lsby_object_row.owner  := lsby_query_row.owner;
    lsby_object_row.name   := lsby_query_row.name ;
    lsby_object_row.type#  := lsby_query_row.type#;
    lsby_object_row.obj#   := lsby_query_row.obj# ;
    lsby_object_row.current_sby := lsby_query_row.current_sby;
    lsby_object_row.gensby := lsby_query_row.gensby;
    pipe row (lsby_object_row);
  end loop;
  close dataset;

  exception when others then
    if dataset%ISOPEN then
      close dataset;
    end if;
end;
/
show errors
grant execute on logstdby$tabf to select_catalog_role
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT_SEQ
-- set of sequences with indicator for lsby support            
--   full_sby:       not used for sequences use bogus constant
--   current_sby:    true if lsby bit set in seq$             
--   generated_sby:  if internal schema then 0 else 1        
--
create or replace view logstdby_support_seq 
as
  select u.name owner, o.name name, o.type#, o.obj#,
         decode(bitand(s.flags, 8), 8, 1, 0) current_sby,
         nvl((select 0 from system.logstdby$skip_support ss
              where ss.name = u.name and action = 0), 1) gensby
  from obj$ o, user$ u, seq$ s
  where o.owner# = u.user# 
  and o.obj# = s.obj#
/

---------------------------------------------------------------------
-- LOGSTDBY_SUPPORT
-- filter tables with DML skip rules from logstdby_support_tab 
--   full_sby:       1 supported, -1 internal not supported   
--                   0 not supported because of features     
--   current_sby:    true if lsby bit set in tab$           
--   generated_sby:  true if supported and no DML skip rule
--                     sequence nextval is treated as DML for skip
--
create or replace view logstdby_support
as
  select owner, name, type#, obj#, gensby full_sby, current_sby,
   (case when decode(gensby, 1, 1, 0) = 1  
       and not exists  
      (select 1 from system.logstdby$skip s
       where statement_opt = 'DML' 
       and error is null 
       and 1 = case use_like
         when 0 then 
	   case when l.owner = s.schema and l.name = s.name then
	     1 else 0 
	   end
	 when 1 then 
	   case when l.owner like s.schema and l.name like s.name then
	     1 else 0
	   end
	 when 2 then
	   case when l.owner like s.schema escape esc and 
                     l.name like s.name escape esc then
             1 else 0
	   end
	 else 0
       end)
    then 1 else 0 end) generated_sby
  from  
    (select * from logstdby_support_seq
     union all 
     select * from table(logstdby$tabf)) l
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORTED_TABLES
-- This undocumented view is created for the Data Guard GUI so that it
-- can get a list of tables that are not supported.  They could use
-- the dba_logstdby_unsupported view, but the query is expensive, mostly
-- because it's column based not table based.
--
create or replace view dba_logstdby_unsupported_table
as
  select owner, name table_name 
  from table(sys.logstdby$tabf)
  where gensby = 0
/
grant select on dba_logstdby_unsupported_table to select_catalog_role
/
create or replace public synonym logstdby_unsupported_tables
   for sys.dba_logstdby_unsupported_table
/
create or replace public synonym dba_logstdby_unsupported_table
   for sys.dba_logstdby_unsupported_table
/
comment on table dba_logstdby_unsupported_table is 
'List of all the data tables that are not supported by Logical Standby'
/
comment on column dba_logstdby_unsupported_table.owner is 
'Schema name of unsupported table'
/
comment on column dba_logstdby_unsupported_table.table_name is 
'Table name of unsupported table'
/

---------------------------------------------------------------------
-- DBA_LOGSTDBY_UNSUPPORTED
-- This documented view displays all the unsupported columns.
-- The view is used by OEM if the users wishes to drill down on
-- the list of table returned by the faster logstdby_unsupported_tables.
-- This view is slower becuase of the join to col$ and filtering
-- by column rather than by table
--
-- The top level view simply queries the redo compatibility table 
-- function and decodes the datatype to text form (which is common
-- for all compatibilities)

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_2b
-- This view encapsulates the rules for support of 11.2.0.3 redo
--    Support for XML OR is enabled (to the extent xml clob is enabled).
create or replace view logstdby_unsupport_tab_11_2b
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
    or exists (select 1 from sys.opqtype$ opq       /* XML OR storage table */
               where o.obj# = opq.obj# 
                 and bitand(opq.flags, 32) = 32) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
        AND((bitand(t.property, 4096) = 4096) /* PK OID */
            or not exists            /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and (bitand(opq.flags,1) = 1 or      /* stored as object */
                        bitand(opq.flags,68) = 4 or     /* stored as lob */
                        bitand(opq.flags,68) = 68)      /* stored as binary */
                   and bitand(opq.flags,512) = 0 )))   /* not hierarch enab */
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and (not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and (bitand(opq.flags,1) = 1 or      /* stored as object */
                       bitand(opq.flags,68) = 4 or     /* stored as lob */
                       bitand(opq.flags,68) = 68)      /* stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#)))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0       /* not a typed table or */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and bitand(c2.property, 8)  != 8               /* Not virtual */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support dedup securefile */
  or  (c.type# in (112, 113)
      and exists (select 1 from logstdby_support_11lob lb
                  where lb.obj# = o.obj#
                  and lb.col# = c.col#
                  and dedupsecurefile = 1))
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_2
-- This view encapsulates the rules for support of 11.2 redo
--
create or replace view logstdby_unsupport_tab_11_2
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML Storage'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
           AND not exists             /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0))     /* not hierarch enab */
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and bitand(opq.flags, 4) = 4             /* stored as lob */
                  and bitand(opq.flags,64) = 0      /* not stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0         /* typed table has an OID */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support dedup securefile */
  or  (c.type# in (112, 113)
      and exists (select 1 from logstdby_support_11lob lb
                   where lb.obj# = o.obj#
                     and lb.col# = c.col#
                     and lb.dedupsecurefile = 1)) 
  ----------------------------------------------------------
  /* we don't support virtual column candidate key */
  or (bitand(c.property, 65544) != 0                      /* Virtual Column */
     and bitand(c.property, 32) != 32                         /* Not hidden */
     and exists (select 1 from icol$ ic, ind$ i
                  where ic.bo# = t.obj# and ic.col# = c.col#
                    and i.bo# = t.obj# and i.obj# = ic.obj#
                    and bitand(i.property, 1) = 1))         /* Unique Index */
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_11_1
-- This view encapsulates the rules for support of 11.1 redo
--
create or replace view logstdby_unsupport_tab_11_1
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(nvl(s.spare1, 0), 2048) = 2048 
         then 'Table Compression'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         when c.type# = 58
         then 'Unsupported XML Storage'
         when bitand(t.property, 1 ) = 1     /* 0x00000001      typed table */
         then 'Object Table'
         when bitand(c.property, 65544) != 0
         then  'Unsupported Virtual Column'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
              + 4294967296 /* 0x100000000                              Cube */
              + 8589934592 /* 0x200000000                      FBA Internal */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to       *
     * skip because of some unsupported attribute of the table or column    */
  when (bitand(t.property, 1) = 1       /* 0x00000001            typed table */
           AND not exists             /* Only XML Typed Tables Are Supported */
            (select 1
             from  sys.col$ cc, sys.opqtype$ opq
             where cc.name = 'SYS_NC_ROWINFO$' and cc.type# = 58 and
                   opq.obj# = cc.obj# and opq.intcol# = cc.intcol# and
                   opq.type = 1 and cc.obj# = t.obj# 
                   and bitand(opq.flags,4) = 4             /* stored as lob */
                   and bitand(opq.flags,64) = 0     /* not stored as binary */
                   and bitand(opq.flags,512) = 0       /* not hierarch enab */
                   and not exists (select 1 from logstdby_support_11lob lb
                                    where lb.obj# = o.obj# 
                                      and lb.securefile = 1)))
  or bitand(t.property,
                131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(nvl(s.spare1,0), 2048) = 2048    /* Compression */
      and bitand(t.property, 32) != 32) 
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
  or  (c.type# = 23 and bitand(c.property, 2) = 2))
  and (c.type# != 58                               /* OPAQUE */
  or  (c.type# = 58                       /* XMLTYPE as CLOB */
      and not exists (select 1 from opqtype$ opq
                  where opq.type=1 
                  and bitand(opq.flags, 4) = 4             /* stored as lob */
                  and bitand(opq.flags,64) = 0      /* not stored as binary */
                  and bitand(opq.flags,512) = 0        /* not hierarch enab */
                  and opq.obj#=c.obj# 
                  and opq.intcol#=c.intcol#
                  and not exists ( select 1 from logstdby_support_11lob lb
                                    where lb.obj# = c.obj# 
                                      and lb.col# = c.col#
                                      and lb.securefile = 1)
))))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,58,112,113)
      and bitand(t.property, 1) = 0                /* typed table has an OID */
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
      )))
  ----------------------------------------------------------
  /* we don't support securefile */
  or  (c.type# in (112, 113)
      and exists (select 1 from logstdby_support_11lob lb
                   where lb.obj# = o.obj#
                     and lb.col# = c.col#
                     and lb.securefile = 1)) 
  ----------------------------------------------------------
  /* we don't support virtual column candidate key */
  or (bitand(c.property, 65544) != 0                      /* Virtual Column */
     and bitand(c.property, 32) != 32                         /* Not hidden */
     and exists (select 1 from icol$ ic, ind$ i
                  where ic.bo# = t.obj# and ic.col# = c.col#
                    and i.bo# = t.obj# and i.obj# = ic.obj#
                    and bitand(i.property, 1) = 1))         /* Unique Index */
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

-- LOGSTDBY_UNSUPPORT_TAB_10_2
-- This view encapsulates the rules for support of 10.2 redo
--
create or replace view logstdby_unsupport_tab_10_2
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
   (case when bitand(t.flags, 536870912) = 536870912
         then 'Mapping table for physical rowid of IOT'
         when bitand(nvl(s.spare1, 0), 2048) = 2048 
         then 'Table Compression'
         when bitand(t.property, 1) = 1
         then 'Object Table'
         when bitand(c.property, 67108864) = 67108864  /* 0X4000000 */
         then 'Encrypted Column'
         when bitand(t.property, 131072) = 131072
         then 'AQ queue table'
         else null end) attributes,
    (case 
    /* The following are tables that are system maintained */
    when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
                + 131072   /* 0x00020000 table is used as an AQ queue table */
             ) != 0
  or (bitand(t.property, 32) = 32) 
    and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
  or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
  or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
  or o.oid$ is not null
  or (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
    or  (c.type# = 23 and bitand(c.property, 2) = 2)))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,112,113)
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                                  )))
  ----------------------------------------------------------
  then 0 else 1 end) gensby
  from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
  where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

---------------------------------------------------------------------
-- LOGSTDBY_UNSUPPORT_TAB_10_1
-- This view encapsulates the rules for support of 10.1 redo
--
create or replace view logstdby_unsupport_tab_10_1
as
  select u.name owner, o.name table_name, c.name column_name, 
         c.scale, c.precision#, c.charsetform, c.type#,
    (case when bitand(t.property, 128) = 128 
          then 'IOT with Overflow'
          when bitand(t.property, 262208) = 262208
          then 'IOT with LOB' /* user lob */
          when bitand(t.flags, 536870912) = 536870912
          then 'Mapping table for physical rowid of IOT'
          when bitand(t.property, 2112) = 2112
          then 'IOT with LOB' /* internal lob */
          when (bitand(t.property, 64) = 64 
           and bitand(t.flags, 131072) = 131072)
          then 'IOT with row movement'
          when bitand(nvl(s.spare1,0), 2048) = 2048 
          then 'Table Compression'
          when bitand(t.property, 1) = 1
          then 'Object Table' /* typed table/object table */
          when bitand(t.property, 131072) = 131072
          then 'AQ queue table'
          else null end) attributes,
 (case 
    /* The following are tables that are system maintained */
  when bitand(o.flags,
                2                                       /* temporary object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
              + 536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.property,
                512        /* 0x00000200               iot OVeRflow segment */
              + 8192       /* 0x00002000                       nested table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or bitand(t.trigflag,
                536870912  /* 0x20000000                  DDLs autofiltered */
               ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
    or exists (select 1 from sys.secobj$ so           /* ODCI storage table */
               where o.obj# = so.secobj#) 
  then -1
    /* The following tables are data tables in internal schemata *
     * that are not secondary objects                            */
  when (exists (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = 0))
  then -2
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
              + 128        /* 0x00000080              IOT2 with row overflow */
              + 256        /* 0x00000100            IOT with row clustering */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
             ) != 0
    or bitand(t.property, 262208) = 262208   /* 0x40+0x40000 IOT + user LOB */
    or bitand(t.property, 2112) = 2112     /* 0x40+0x800 IOT + internal LOB */
    or                                           /* IOT with "Row Movement" */
       (bitand(t.property, 64) = 64 and bitand(t.flags, 131072) = 131072)
    or (bitand(t.property, 32) = 32) 
      and exists (select 1 from partobj$ po
                where po.obj#=o.obj#
                and  (po.parttype in (3,             /* System partitioned */
                                      5)))        /* Reference partitioned */
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
   or 
 (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
       or (c.type# = 23 and bitand(c.property, 2) = 2)))
  ----------------------------------------------------------
  /* longs must have a scalar column to use as the id key */
  or (c.type# in (8,24,112,113)
      and 0 = (select count(*) from sys.col$ c2
               where t.obj# = c2.obj#
               and bitand(c2.property, 32) != 32               /* Not hidden */
               and (c2.type# in ( 1,                             /* VARCHAR2 */
                                  2,                               /* NUMBER */
                                  12,                                /* DATE */
                                  23,                                 /* RAW */
                                  96,                                /* CHAR */
                                  100,                       /* BINARY FLOAT */
                                  101,                      /* BINARY DOUBLE */
                                  180,                     /* TIMESTAMP (..) */
                                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                                  182,         /* INTERVAL YEAR(..) TO MONTH */
                                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
                                  )))
  ----------------------------------------------------------
   then 0 else 1 end) gensby
 from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
/

-- must drop dependant table before create or replace
drop type logstdby$urecs;
create or replace type logstdby$urec 
is object (
  OWNER        VARCHAR2(30),
  TABLE_NAME   VARCHAR2(30),
  COLUMN_NAME  VARCHAR2(30),
  ATTRIBUTES   VARCHAR2(39),
  TYPE#        NUMBER,
  SCALE        NUMBER,
  PRECISION#   NUMBER,
  CHARSETFORM  NUMBER,
  GENSBY       NUMBER)
/

create or replace type logstdby$urecs 
is table of logstdby$urec
/

create or replace function logstdby$utabf (request in varchar2 default null)
return logstdby$urecs pipelined parallel_enable
is
  lsby_object_row logstdby$urec := logstdby$urec('','','','',0,0,0,0,0);
  type lsby_tcur is ref cursor return logstdby_unsupport_tab_10_2%ROWTYPE;
  dataset lsby_tcur;
  lsby_query_row dataset%ROWTYPE;
  cmpat varchar2(6);
  patchno varchar2(6);
  fullcmpat varchar2(12);
  role  varchar2(16);
begin
  if request is null then
    select database_role into role from sys.v$database;
  else
    role := request;
  end if;

  if role = 'PRIMARY' then
    select substr(value,1,8) into fullcmpat
    from sys.v$parameter where name = 'compatible';
  else
    select nvl(
      (select substr(s.redo_compat,1,8) 
       from system.logstdby$parameters p, system.logmnr_session$ s
       where p.name = 'LMNR_SID' and p.value = s.session#),
      (select substr(value,1,8) from sys.v$parameter
       where name = 'compatible')) into fullcmpat from dual;
  end if;
  cmpat := substr(fullcmpat, 1, 4);
  patchno := substr(fullcmpat, 8, 1);
 
  if '11.2' = cmpat then
    if patchno >= '3' then
      cmpat := '11.2b';    
    end if;
  end if;

  case cmpat
  when '10.0' then
    open dataset for select * from logstdby_unsupport_tab_10_1;
  when '10.1' then
    open dataset for select * from logstdby_unsupport_tab_10_1;
  when '10.2' then
    open dataset for select * from logstdby_unsupport_tab_10_2;
  when '11.0' then
    open dataset for select * from logstdby_unsupport_tab_11_1;
  when '11.1' then
    open dataset for select * from logstdby_unsupport_tab_11_1;
  when '11.2' then
    open dataset for select * from logstdby_unsupport_tab_11_2;
  when '11.2b' then
    open dataset for select * from logstdby_unsupport_tab_11_2b;
  else
    open dataset for select * from logstdby_unsupport_tab_10_1;
  end case;

  loop
    fetch dataset into lsby_query_row;
    exit when dataset%NOTFOUND;
    if lsby_query_row.gensby = 0  or
       lsby_query_row.gensby = -2
    then
      lsby_object_row.owner       := lsby_query_row.owner;
      lsby_object_row.table_name  := lsby_query_row.table_name;
      lsby_object_row.column_name := lsby_query_row.column_name;
      lsby_object_row.attributes  := lsby_query_row.attributes;
      lsby_object_row.type#       := lsby_query_row.type#;
      lsby_object_row.scale       := lsby_query_row.scale;
      lsby_object_row.precision#  := lsby_query_row.precision#;
      lsby_object_row.charsetform := lsby_query_row.charsetform; 
      lsby_object_row.gensby      := lsby_query_row.gensby;
      pipe row (lsby_object_row);
    end if;
  end loop;
  close dataset;

  exception when others then
    if dataset%ISOPEN then
      close dataset;
    end if;
end;
/

grant execute on logstdby$utabf to select_catalog_role
/

create or replace view dba_logstdby_unsupported
as
  select owner, table_name, column_name, attributes,
  substr(decode(type#, 1, decode(charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                2, decode(scale, null, decode(precision#, null, 
                          'NUMBER', 'FLOAT'), 'NUMBER'),
                8, 'LONG',
                9, decode(charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                12, 'DATE',
                23, 'RAW', 
                24, 'LONG RAW',
                58, 'OPAQUE',
                69, 'ROWID', 
                96, decode(charsetform, 2, 'NCHAR', 'CHAR'),
                100, 'BINARY_FLOAT',
                101, 'BINARY_DOUBLE',
                105, 'MLSLABEL',
                106, 'MLSLABEL',
                110, 'REF',
                111, 'REF',
                112, decode(charsetform, 2, 'NCLOB', 'CLOB'),
                113, 'BLOB', 
                114, 'BFILE', 
                115, 'CFILE',
                121, 'OBJECT',
                122, 'NESTED TABLE',
                123, 'VARRAY',
                178, 'TIME(' ||scale|| ')',
                179, 'TIME(' ||scale|| ')' || ' WITH TIME ZONE',
                180, 'TIMESTAMP(' ||scale|| ')',
                181, 'TIMESTAMP(' ||scale|| ')' || ' WITH TIME ZONE',
                231, 'TIMESTAMP(' ||scale|| ')' || ' WITH LOCAL TIME ZONE',
                182, 'INTERVAL YEAR(' ||precision#||') TO MONTH',
                183, 'INTERVAL DAY(' ||precision#||') TO SECOND(' 
                                     || scale || ')',
                208, 'UROWID',
                'UNDEFINED'),1,32) data_type
  from table (logstdby$utabf)
  where gensby = 0
/

create or replace public synonym dba_logstdby_unsupported
   for dba_logstdby_unsupported
/
grant select on dba_logstdby_unsupported to select_catalog_role
/
comment on table dba_logstdby_unsupported is 
'List of all the columns that are not supported by Logical Standby'
/
comment on column dba_logstdby_unsupported.owner is 
'Schema name of unsupported column'
/
comment on column dba_logstdby_unsupported.table_name is 
'Table name of unsupported column'
/
comment on column dba_logstdby_unsupported.column_name is 
'Column name of unsupported column'
/
comment on column dba_logstdby_unsupported.data_type is
'Datatype of unsupported column'
/
comment on column dba_logstdby_unsupported.attributes is
'If not a data type issue, gives the reason why the table is unsupported'
/

---------------------------------------------------------------------
-- DBA_LOGSTDBY_NOT_UNIQUE 
-- We do not supplementally log longs and virtual columns.
-- This view identifies tables that have no usable candidate key
-- and which also have columns which are not supp logged.
-- There is a chance that we could update the wrong row on the standby
-- The bad_column attribute shows for each table:
--   'Y' - the table has a candidate key or it has no non-supplogged cols
--   'N' - one or more columns cannot be predicated from the redo data
--         and it has no candidate key; DBA should add rely constraint!
--  note #1: 
--        cdef$ defer bits:
--          0x1: deferrable => if this bit set, the PK does not count.
--          0x4: sys validated 
--          0x20: rely         
--          bitand(defer, 37) in (4, 32, 36) => 
--           (0x25 & defer) = (0x4 | 0x20| 0x24)
--        col$ property bits:
--          0x20 = 32 = hidden column 
--          0x8  = 08 = virtual column)
--          0x2  = 02 = OID column     
--
--  note #2: The two "not exists" clauses (conditions #1 and #2) are 
--  verifying that there is no replication friendly "logical identification" 
--  key for the table in question. In other words, the rows in the table
--  are deemed not unique by the replication framework (possibly, 
--  even in the presence of a well defined primary key or a unique index
--  with at least one not-nullable column). Note that XML typed tables
--  with non-virtual OID columns are deemed supportable as the OID 
--  column could be used as logical row identifier, regardless of the 
--  nature of other unique indexes or primary key, if any, on those 
--  tables. For non-typed tables, the following conditions apply.
-- 
--   condition #1: A unique index that meets any of the following conditions
--   cannot be used as an identification key for logical replication.
--      
--      1. It does not have a not-nullable column.
--      2. It is a not a btree index.
--      3. It has dependencies on either virtual column(s) or 
--         hidden columns (this is verified in the second not-exists
--         subquery block).
-- 
--   condition #2: A primary key that meets any of the following conditions
--   cannot be used as an identification key for logical replication.
--  
--      1. It is marked deferrable OR is not marked as rely or sys-validated.
--      2. It has dependencies on either virtual column(s) or 
--         hidden columns (this is verified in the second not-exists
--         subquery block).
--    
---------------------------------------------------------------------
create or replace view dba_logstdby_not_unique
as
  select owner, name table_name, 
         decode((select count(c.obj#)
                 from sys.col$ c
                 where c.obj# = l.obj#
                 and (c.type# in (8,                             /* LONG */
                                  24,                        /* LONG RAW */
                                  58,                             /* XML */
                                  112,                           /* CLOB */
                                  113))),                        /* BLOB */
                 0, 'N', 'Y') bad_column
  from table(logstdby$tabf) l, tab$ t
  where gensby = 1
    and l.type# = 2
    and l.obj# = t.obj# and
        bitand(t.property, 1) = 0                    /* rule out typed table */
    and not exists                    /* not null unique key -- condition #1 */
       (select null -- (tagA)
        from ind$ i, icol$ ic, col$ c
        where i.bo# = l.obj#
          and ic.obj# = i.obj#
          and c.col# = ic.col#
          and c.obj# = i.bo#
          and c.null$ > 0                                       /* not null */
          and i.type# = 1                                          /* Btree */
          and bitand(i.property, 1) = 1                           /* Unique */
          and i.intcols = i.cols                      /* no virtual columns */
          and not exists (select null 
                          from icol$ icol2, col$ col2
                          where  icol2.obj# = i.obj# and 
                                 icol2.bo#  = i.bo#  and -- redundant
                                 icol2.bo#  = col2.obj# and
                                 icol2.intcol# = col2.intcol# and
                                 bitand(col2.property, 40) != 0)) -- (tagA)
    and not exists               /* primary key constraint --  condition #2 */
       (select null                         /* defer bit 0x1: deferrable    */
        from cdef$ cd                       /*       bit 0x4: sys validated */
        where cd.obj# = l.obj#              /*       bit 0x20: rely         */
          and cd.type# = 2 
          and bitand(cd.defer, 37) in (4, 32, 36) 
          and not exists (select null 
                          from ccol$ ccol3, col$ col3
                          where ccol3.con# = cd.con# and 
                                ccol3.obj# = cd.obj# and 
                                ccol3.obj# = col3.obj# and 
                                ccol3.intcol# = col3.intcol# and 
                                bitand(col3.property, 40) != 0)
        )
/
create or replace public synonym dba_logstdby_not_unique
   for dba_logstdby_not_unique
/
grant select on dba_logstdby_not_unique to select_catalog_role
/
comment on table dba_logstdby_not_unique is 
'List of all the tables with out primary or unique key not null constraints'
/
comment on column dba_logstdby_not_unique.owner is 
'Schema name of the non-unique table'
/
comment on column dba_logstdby_not_unique.table_name is 
'Table name of the non-unique table'
/
comment on column dba_logstdby_not_unique.bad_column is 
'Indicates that the table has a column not useful in the where clause'
/

create or replace view dba_logstdby_parameters
as
  select name, value, unit, setting, dynamic
  from x$dglparam where visible=1
/
create or replace public synonym dba_logstdby_parameters
   for dba_logstdby_parameters
/
grant select on dba_logstdby_parameters to select_catalog_role
/
comment on table dba_logstdby_parameters is 
'Miscellaneous options and settings for Logical Standby'
/
comment on column dba_logstdby_parameters.name is 
'Name of the parameter'
/
comment on column dba_logstdby_parameters.value is 
'Optional value of the parameter'
/


-- DBA_LOGSTDBY_PROGRESS view
-- Just break things down to understand them.
-- First, the logstdby_log view is just an aid so we can include v$standby_log
-- information in our views.  So it combines logs in logmnr_log$ with
-- v$standby_log logs.
-- Second, the dba_logstdby_progress view is just a collection of subqueries.
-- There are three important columns that are computed in the base in-line
-- view X.  These are APPLIED_SCN, READ_SCN (past tense), and NEWEST_SCN.
-- Once these are computed, they are used as the source to compute all the
-- other columns in the view.
create or replace view logstdby_log
as
  select first_change#, next_change#, sequence#, thread#, 
         first_time, next_time
  from system.logmnr_log$ where session# = 
     (select value from system.logstdby$parameters where name = 'LMNR_SID')
    /* comment */
 union
  select first_change#, (last_change# + 1) next_change#, sequence#, thread#,
         first_time, last_time next_time
  from v$standby_log where status = 'ACTIVE'
/

create or replace view dba_logstdby_progress
as
  select
    applied_scn,
    /* thread# derived from applied_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where applied_scn >= first_change# and applied_scn <= next_change#)
    and applied_scn >= first_change# 
    and applied_scn <= next_change#)
       applied_thread#,
    /* sequence# derived from applied_scn */
    (select max(sequence#) from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_sequence#,
    /* estimated time derived from applied_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (applied_scn - first_change#)))
     from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_time,
    read_scn,
    /* thread# derived from read_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where read_scn >= first_change# and read_scn <= next_change#)
     and read_scn >= first_change#
     and read_scn <= next_change#)
       read_thread#,
    /* sequence# derived from read_scn */
    (select max(sequence#) from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_sequence#,
    /* estimated time derived from read_scn */
    (select min(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (read_scn - first_change#)))
     from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_time,
    newest_scn,
    /* thread# derived from newest_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where newest_scn >= first_change# and newest_scn <= next_change#)
     and newest_scn >= first_change#
     and newest_scn <= next_change#)
       newest_thread#,
    /* sequence# derived from newest_scn */
    (select max(sequence#) from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_sequence#,
    /* estimated time derived from newest_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (newest_scn - first_change#)))
     from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_time
  from
    /* in-line view to calculate relavent scn values */
    (select /* APPLIED_SCN */
            greatest(nvl((select max(a.processed_scn) - 1
                          from system.logstdby$apply_milestone a),0),
                     nvl((select max(a.commit_scn)
                          from system.logstdby$apply_milestone a),0),
                     sx.start_scn) applied_scn,
            /* READ_SCN */
            greatest(nvl(sx.spill_scn,1), sx.start_scn) read_scn,
            /* NEWEST_SCN */
            nvl((select max(next_change#)-1 from logstdby_log),
                sx.start_scn) newest_scn
    from system.logmnr_session$ sx
    where sx.session# =
      (select value from system.logstdby$parameters where name = 'LMNR_SID')) x
/

create or replace public synonym dba_logstdby_progress
   for dba_logstdby_progress
/
-- This must be done in catproc, since that's where logmnr tables are created
-- grant select on dba_logstdby_progress to select_catalog_role
-- /
comment on table dba_logstdby_progress is 
'List the SCN values describing read and apply progress'
/
comment on column dba_logstdby_progress.applied_scn is 
'All transactions with a commit SCN <= this value have been applied'
/
comment on column dba_logstdby_progress.applied_thread# is 
'Thread number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_sequence# is 
'Sequence number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_time is 
'Estimate of the time the applied_scn was generated'
/
comment on column dba_logstdby_progress.read_scn is 
'All log data less than this SCN has been preserved in the database'
/
comment on column dba_logstdby_progress.read_thread# is 
'Thread number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_sequence# is 
'Sequence number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_time is 
'Estimate of the time the read_scn was generated'
/
comment on column dba_logstdby_progress.newest_scn is 
'The highest SCN that could be applied given the existing logs'
/
comment on column dba_logstdby_progress.newest_thread# is 
'Thread number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.applied_sequence# is 
'Sequence number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.newest_time is 
'Estimate of the time the newest_scn was generated'
/


-- Logmnr tables aren't created yet so FORCE was necessary --
-- (don't list dummy entries)
create or replace force view dba_logstdby_log
as
  select thread#, resetlogs_change#, reset_timestamp resetlogs_id, sequence#, 
         first_change#, next_change#, first_time, next_time, file_name,
          timestamp, dict_begin, dict_end,
    (case when l.next_change# <= p.read_scn then 'YES'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 0)) then 'FETCHING'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 4)) then 'CORRUPT'
          when l.first_change# < p.applied_scn then 'CURRENT'
          else 'NO' end) applied, blocks, block_size
  from system.logmnr_log$ l, dba_logstdby_progress p
  where session# =
    (select value from system.logstdby$parameters where name = 'LMNR_SID') and
    (flags is NULL or bitand(l.flags,16) = 0)
/
create or replace public synonym dba_logstdby_log for dba_logstdby_log
/
-- This must be done in catproc, since that's where logmnr tables are created
-- grant select on dba_logstdby_log to select_catalog_role
-- /
comment on table dba_logstdby_log is
'List the information about received logs from the primary'
/
comment on column dba_logstdby_log.thread# is 
'Redo thread number'
/
comment on column dba_logstdby_log.sequence# is 
'Redo log sequence number'
/
comment on column dba_logstdby_log.first_change# is 
'First change# in the archived log'
/
comment on column dba_logstdby_log.next_change# is 
'First change in the next log'
/
comment on column dba_logstdby_log.first_time is 
'Timestamp of the first change'
/
comment on column dba_logstdby_log.next_time is 
'Timestamp of the next change'
/
comment on column dba_logstdby_log.file_name is 
'Archived log file name'
/
comment on column dba_logstdby_log.timestamp is 
'Time when the archiving completed'
/
comment on column dba_logstdby_log.dict_begin is 
'Contains beginning of Log Miner Dictionary'
/
comment on column dba_logstdby_log.dict_end is 
'Contains end of Log Miner Dictionary'
/
comment on column dba_logstdby_log.applied is 
'Indicates apply progress through log stream'
/
comment on column dba_logstdby_log.blocks is 
'Indicates the number of blocks in the log'
/
comment on column dba_logstdby_log.block_size is 
'Indicates the size of each block in the log'
/

create or replace view dba_logstdby_skip_transaction
as
  select xidusn, xidslt, xidsqn
  from system.logstdby$skip_transaction
/
create or replace public synonym dba_logstdby_skip_transaction 
   for dba_logstdby_skip_transaction
/
grant select on dba_logstdby_skip_transaction to select_catalog_role
/
comment on table dba_logstdby_skip_transaction is 
'List the transactions to be skipped'
/
comment on column dba_logstdby_skip_transaction.xidusn is 
'Transaction id, component 1 of 3'
/
comment on column dba_logstdby_skip_transaction.xidslt is 
'Transaction id, component 2 of 3'
/
comment on column dba_logstdby_skip_transaction.xidsqn is 
'Transaction id, component 3 of 3'
/

create or replace view dba_logstdby_skip
as
  select decode(error, 1, 'Y', 'N') error,
         statement_opt, schema owner, name,
         decode(use_like, 0, 'N', 'Y') use_like, esc, proc
  from system.logstdby$skip
  union all
  select 'N' error,
         'INTERNAL SCHEMA' statement_opt, u.username owner, '%' name,
         'N' use_like, null esc, null proc
  from dba_users u, system.logstdby$skip_support s
  where u.username = s.name
  and   s.action = 0
/
create or replace public synonym dba_logstdby_skip for dba_logstdby_skip
/
grant select on dba_logstdby_skip to select_catalog_role
/
comment on table dba_logstdby_skip is 
'List the skip settings choosen'
/
comment on column dba_logstdby_skip.error is 
'Does this skip setting only apply to failed attempts'
/
comment on column dba_logstdby_skip.statement_opt is 
'The statement option choosen to skip'
/
comment on column dba_logstdby_skip.owner is 
'Schema name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.name is 
'Object name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.use_like is 
'Use SQL wildcard search when matching names'
/
comment on column dba_logstdby_skip.esc is 
'The escape character used when performing wildcard matches.'
/
comment on column dba_logstdby_skip.proc is 
'The stored procedure to call for this skip setting.  DDL only'
/


create or replace view dba_logstdby_events
as
  select cast(event_time as date) event_time, event_time event_timestamp, 
         spare1 as start_scn, current_scn, commit_scn, xidusn, xidslt, xidsqn,
	 full_event event, errval status_code, error status
  from system.logstdby$events
/
create or replace public synonym dba_logstdby_events for dba_logstdby_events
/
grant select on dba_logstdby_events to select_catalog_role
/
comment on table dba_logstdby_events is 
'Information on why logical standby events'
/
comment on column dba_logstdby_events.event_time is
'Time the event took place'
/
comment on column dba_logstdby_events.start_scn is
'SCN at which the transaction started'
/
comment on column dba_logstdby_events.current_scn is
'Change vector SCN for the change'
/
comment on column dba_logstdby_events.commit_scn is
'SCN for the commit record of the transaction'
/
comment on column dba_logstdby_events.xidusn is
'Transaction id, part 1 of 3'
/
comment on column dba_logstdby_events.xidslt is
'Transaction id, part 2 of 3'
/
comment on column dba_logstdby_events.xidsqn is
'Transaction id, part 3 of 3'
/
comment on column dba_logstdby_events.event is
'A SQL statement or other text describing the event'
/
comment on column dba_logstdby_events.status is
'A text string describing the event'
/
comment on column dba_logstdby_events.status_code is
'A number describing the event'
/

create or replace view dba_logstdby_history
as
  select stream_sequence#, decode(status, 1, 'Past', 2, 'Immediate Past', 3, 
         'Current', 4, 'Immediate Future', 5, 'Future', 6, 'Canceled', 7,
         'Invalid') status, decode(source, 1, 'Rfs', 2, 'User', 3, 'Synch', 4,
         'Redo') source, dbid, first_change#, last_change#, first_time, 
         last_time, dgname, spare1 merge_change#, spare2 processed_change# 
  from system.logstdby$history
/
create or replace public synonym dba_logstdby_history for dba_logstdby_history
/
grant select on dba_logstdby_history to select_catalog_role
/
comment on table dba_logstdby_history is 
'Information on processed, active, and pending log streams'
/
comment on column dba_logstdby_history.stream_sequence# is
'Log Stream Identifier'
/
comment on column dba_logstdby_history.status is
'The processing status of this log stream'
/
comment on column dba_logstdby_history.dbid is
'The dbid of the logfile provider'
/
comment on column dba_logstdby_history.first_change# is
'The starting scn for this log stream'
/
comment on column dba_logstdby_history.last_change# is
'The scn of the last committed transaction'
/
comment on column dba_logstdby_history.first_time is
'The time associated with first_change#'
/
comment on column dba_logstdby_history.last_time is
'The time associated with last_change#'
/
comment on column dba_logstdby_history.dgname is
'The Dataguard name'
/
comment on column dba_logstdby_history.merge_change# is
'The scn up to and including which was consistent during terminal apply'
/
comment on column dba_logstdby_history.processed_change# is
'The scn up to which all transactions have been processed'
/

create or replace view dba_logstdby_eds_tables as
  select owner, table_name, ctime from system.logstdby$eds_tables
/

grant select on dba_logstdby_eds_tables to select_catalog_role
/
create or replace public synonym dba_logstdby_eds_tables
   for sys.dba_logstdby_eds_tables
/
comment on table dba_logstdby_eds_tables is 
'List of all tables that have EDS-based replication for Logical Standby'
/
comment on column dba_logstdby_eds_tables.owner is 
'Schema name of supported table'
/
comment on column dba_logstdby_eds_tables.table_name is 
'Table name of supported table'
/
comment on column dba_logstdby_eds_tables.ctime is 
'Time that table had EDS added'
/

Rem View showing all tables that could be supported by EDS interface
Rem
Rem For a table to be a candidate for EDS-based replication it must 
Rem meet 2 criteria:
Rem     1) Must be unsupported by native replication
Rem        (e.g. has SDO_GEOMETRY, XMLTYPE, VARRAY, user type)
Rem     2) contain only a restricted set of datatypes
Rem
create or replace view dba_logstdby_eds_supported as
  select distinct owner, table_name from 
        dba_logstdby_unsupported_table un,
        tab$ t,
        obj$ o,
        user$ u,
        cdef$ c
  where
        /* get a handle on tab$ row to eliminate uninteresting tables */
        o.name = un.table_name and
        o.type# = 2 and 
        u.user# = o.owner# and 
        un.owner = u.name and
        o.obj# = t.obj# and 
        (bitand(t.property, 7) = 2 or   /* not an object table but has an
                                         * object column and no nested-table
                                         * columns:
                                         * 1  -- typed table 
                                         * 2  -- has ADT columns
                                         * 4  -- has nested-table columns
                                         */
        bitand(t.property, 21) = 16)    /* has varray columns
                                         * 1  -- typed table 
                                         * 4  -- has nested-table columns
                                         * 16 -- has a varray column
                                         */
        and c.obj# = o.obj# and c.type# = 2     /* has a primary key */
        and 
        /* 
         * evaluate all columns, hidden or not, to determine whether any that
         * are not system generated, including object attributes, fall outside 
         * of the supported set
         */
        (un.owner, un.table_name) NOT IN
        (select distinct owner,table_name from dba_tab_cols d where
                d.owner=un.owner and d.table_name=un.table_name
                and 
                ((d.data_type_owner IS NULL or 
                 d.data_type_owner = 'SYS' or
                 d.data_type_owner = 'MDSYS')
                and d.qualified_col_name not like 'SYS_NC%'
                and d.qualified_col_name not like '"SYS_NC%'
                and d.data_type != 'NUMBER' 
                and d.data_type != 'VARCHAR2'
                and d.data_type != 'RAW' 
                and d.data_type != 'DATE' 
                and d.data_type != 'FLOAT' 
                and d.data_type != 'INTEGER'
                and d.data_type != 'CHAR' 
                and d.data_type != 'NCHAR'
                and d.data_type != 'NVARCHAR2'
                and d.data_type != 'BINARY_FLOAT'
                and d.data_type != 'BINARY_DOUBLE'
                and not d.data_type LIKE 'TIMESTAMP(%'
                and not d.data_type LIKE 'INTERVAL %'
                and d.data_type != 'SDO_GEOMETRY'
                and d.data_type != 'SDO_ELEM_INFO_ARRAY'
                and d.data_type != 'SDO_ORDINATE_ARRAY'
                and d.data_type != 'XMLTYPE') or
                (d.data_type = 'XMLTYPE'        -- disallow XMLTYPE attribute
                and (d.data_type_owner = 'PUBLIC' or d.data_type_owner = 'SYS')
                and d.qualified_col_name != d.column_name)
                )
/
grant select on dba_logstdby_eds_supported to select_catalog_role
/
create or replace public synonym dba_logstdby_eds_supported
   for sys.dba_logstdby_eds_supported
/
comment on table dba_logstdby_eds_supported is 
'List of all tables that could have EDS-based replication for Logical Standby'
/
comment on column dba_logstdby_eds_tables.owner is 
'Schema name of supportable table'
/
comment on column dba_logstdby_eds_tables.table_name is 
'Table name of supportable table'
/


Rem Fix (Virtual) Views

create or replace view v_$logstdby as
  select * from v$logstdby;
create or replace public synonym v$logstdby for v_$logstdby;
grant select on v_$logstdby to select_catalog_role;

create or replace view v_$logstdby_stats as
  select * from v$logstdby_stats;
create or replace public synonym v$logstdby_stats for v_$logstdby_stats;
grant select on v_$logstdby_stats to select_catalog_role;

create or replace view v_$logstdby_transaction as
  select * from v$logstdby_transaction;
create or replace public synonym v$logstdby_transaction for
  v_$logstdby_transaction;
grant select on v_$logstdby_transaction to select_catalog_role;

create or replace view v_$logstdby_progress as
  select * from v$logstdby_progress;
create or replace public synonym v$logstdby_progress for v_$logstdby_progress;
grant select on v_$logstdby_progress to select_catalog_role;

create or replace view v_$logstdby_process as
  select * from v$logstdby_process;
create or replace public synonym v$logstdby_process for v_$logstdby_process;
grant select on v_$logstdby_process to select_catalog_role;

create or replace view v_$logstdby_state as
  select * from v$logstdby_state;
create or replace public synonym v$logstdby_state for v_$logstdby_state;
grant select on v_$logstdby_state to select_catalog_role;

Rem Create synonyms for the global fixed views

create or replace view gv_$logstdby as
  select * from gv$logstdby;
create or replace public synonym gv$logstdby for gv_$logstdby;
grant select on gv_$logstdby to select_catalog_role;

create or replace view gv_$logstdby_stats as
  select * from gv$logstdby_stats;
create or replace public synonym gv$logstdby_stats for gv_$logstdby_stats;
grant select on gv_$logstdby_stats to select_catalog_role;

create or replace view gv_$logstdby_transaction as
  select * from gv$logstdby_transaction;
create or replace public synonym gv$logstdby_transaction for
  gv_$logstdby_transaction;
grant select on gv_$logstdby_transaction to select_catalog_role;

create or replace view gv_$logstdby_progress as
  select * from gv$logstdby_progress;
create or replace public synonym gv$logstdby_progress for
  gv_$logstdby_progress;
grant select on gv_$logstdby_progress to select_catalog_role;

create or replace view gv_$logstdby_process as
  select * from gv$logstdby_process;
create or replace public synonym gv$logstdby_process for gv_$logstdby_process;
grant select on gv_$logstdby_process to select_catalog_role;

create or replace view gv_$logstdby_state as
  select * from gv$logstdby_state;
create or replace public synonym gv$logstdby_state for gv_$logstdby_state;
grant select on gv_$logstdby_state to select_catalog_role;

Rem Populate NOEXP$ to ensure logical standby metadata is not exported
delete from sys.noexp$ where name like 'LOGSTDBY$%';
insert into sys.noexp$
  select u.name, o.name, o.type#
  from sys.obj$ o, sys.user$ u
  where o.type# = 2
  and o.owner# = u.user# 
  and u.name = 'SYSTEM' 
  and o.name like 'LOGSTDBY$%';
commit;
