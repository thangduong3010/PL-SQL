Rem
Rem $Header: rdbms/admin/catsqlt.sql /st_rdbms_11.2.0/1 2012/08/01 16:35:42 shjoshi Exp $
Rem
Rem catsqlt.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsqlt.sql - CATalog script for SQL Tune types and tables
Rem
Rem    DESCRIPTION
Rem      Catalog script for sqltune. This script contains type and table 
Rem      definitions for sqltune advisor, sql tuning set and sql profile.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    arbalakr    11/13/09 - increase length of module and action columns
Rem    pbelknap    06/23/09 - #8618452: db feature usg for sql monitor
Rem    pbelknap    12/09/08 - add pack/unpack sqlset id temp table
Rem    pbelknap    04/06/07 - bug# 5917151 - pass profile as xml
Rem    kyagoub     09/10/06 - bug#5518178: extend optimizer_env size to 2000
Rem    kyagoub     06/11/06 - move plan related tables to catadvtb.sql 
Rem    kyagoub     06/10/06 - add sql_id to wri$_adv_sqlt_plan_hash 
Rem    kyagoub     05/16/06 - add wri$_adv_sqlt_plan_hash 
Rem    kyagoub     04/25/06 - add exec_name to advisor plan table 
Rem    kyagoub     01/30/06 - add plan table for sqlset workspace 
Rem    kyagoub     01/12/06 - add new_plan_hash to wri$_sqlset_workspace table 
Rem    pbelknap    04/25/05 - add plan temp table
Rem    pbelknap    04/22/05 - change name of wri$_adv_sqlt_rtn_plan const.
Rem    kyagoub     10/25/04 - sqlset_row: set sql_text default to null 
Rem    kyagoub     09/30/04 - replace sql_binds_ntab_row/sql_bind and 
Rem                           sql_binds_ntab/sql_bind_set 
Rem    kyagoub     09/26/04 - add sql_bind_set collection 
Rem    kyagoub     09/26/04 - revert to bind_list 
Rem    kyagoub     09/10/04 - replace bind_list by bind_data in sqlset_row,
Rem                           also drop log and object xxx_sqlset_xxx views
Rem    kyagoub     09/01/04 - change options for WRI$_SQLSET_STMT_ID_SEQ 
Rem    pbelknap    08/24/04 - fix sqlset_row order 
Rem    mlfeng      08/19/04 - move sqltune private packages 
Rem    pbelknap    08/06/04 - sts changes for force_matching_signature 
Rem    mlfeng      08/03/04 - add dba_hist_sqlbind view
Rem    bdagevil    07/26/04 - add sqlbind object type 
Rem    kyagoub     07/28/04 - define a construtor for sqlset_row 
Rem    pbelknap    07/23/04 - type oid for stat_row_type 
Rem    kyagoub     07/13/04 - create all_sqlset_xxx views 
Rem    pbelknap    06/30/04 - change oids 
Rem    kyagoub     06/23/04 - add sqlset_plan_statistics table 
Rem    pbelknap    06/25/04 - reserve toids 
Rem    kyagoub     06/20/04 - add plan_timestamp to the plan table 
Rem    kyagoub     06/09/04 - replace plan/sql_plan in sqlset_row 
Rem    pbelknap    06/11/04 - add deltas for capture 
Rem    kyagoub     06/01/04 - add parsing_schema_id to 
Rem                           dba/user_sqlset_statements views 
Rem    kyagoub     05/10/04 - add wri$_sqlset_plan_lines 
Rem    pbelknap    05/07/04 - add bind nested table 
Rem    kyagoub     04/26/04 - reorganize sts schema 
Rem    mramache    05/10/04 - add FORCE_MATCHING to DBA_SQL_PROFILES 
Rem    pbelknap    03/01/04 - autocommit, new ownership model 
Rem    bdagevil    05/21/04 - remove hard tab 
Rem    bdagevil    05/13/04 - add other_xml column 
Rem    pbelknap    02/12/04 - add duc$ calls 
Rem    kyagoub     07/08/03 - remove sqltune report objects
Rem    kyagoub     06/22/03 - SQL Profile: fix sqltune report
Rem    mramache    06/20/03 - SQL profiles
Rem    bdagevil    06/19/03 - fix plan table
Rem    bdagevil    06/18/03 - rename hint alias to object_alias
Rem    bdagevil    06/06/03 - hint alias increased in size
Rem    kyagoub     05/14/03 - add dba_sqlset public synonym
Rem    kyagoub     05/09/03 - ADD statement_count to WRI$_SQLSET_DEFINITIONS
Rem    bdagevil    05/07/03 - fix profile view comment
Rem    kyagoub     05/05/03 - add wri$_sqlt_statistics
Rem    kyagoub     05/03/03 - rename wrmxxx tables to wrixxx
Rem    bdagevil    04/25/03 - replace signature/sql_id
Rem    kyagoub     04/10/03 - rename veiws xxx_sqlset_definition to xxx_sqlset
Rem    kyagoub     04/03/03 - add FETCHES, END_OF_FETCH_COUNT stats to sqlset
Rem    bdagevil    04/28/03 - merge new file
Rem    aime        04/25/03 - aime_going_to_main
Rem    bdagevil    03/12/03 - increase ce size
Rem    kyagoub     03/12/03 - add OPTIMIZER_ENV column to sqlset_statements
Rem    kyagoub     03/09/03 - add plan_hash_value to wri$_adv_sqlt_plans
Rem    bdagevil    03/08/03 - add new explain plan columns
Rem    kyagoub     02/24/03 - add sqlset/sqltune indices
Rem    kyagoub     02/18/03 - add hash_value, and child_number to sqlset tables
Rem    mramache    02/11/03 - change name of profile ADT type
Rem    bdagevil    02/07/03 - add profiles catalog objects
Rem    kyagoub     12/13/02 - kyagoub_merge_swo
Rem    kyagoub     12/13/02 - kyagoub_merge_swo
Rem    kyagoub     11/29/02 - rename type wri$_sql_binds to sql_binds
Rem    kyagoub     11/05/02 - add task_id column to wri$_adv_sqlt_plans
Rem    kyagoub     11/02/02 - move wri$_adv_sqltune to catadvtb
Rem    kyagoub     09/27/02 - Created
Rem




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                         --------------------------                         --
--                         SQL TUNE SCHEMA DEFINITION                         --
--                         --------------------------                         --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

--------------------------------------------------------------------------------
--                       sql_binds object type definition                     --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- NAME: 
--     sql_binds  
--
-- DESCRIPTION: 
--     This is an object type that defines a collection of bind values
--     associated to a given SQL statement. 
--------------------------------------------------------------------------------
CREATE OR REPLACE TYPE sql_binds AS VARRAY(2000) OF ANYDATA
/
-- Public synonym for the type
CREATE OR REPLACE PUBLIC SYNONYM sql_binds FOR sql_binds
/
-- Granting the execution privilege to the public role
GRANT EXECUTE ON sql_binds TO public
/

--------------------------------------------------------------------------------
--                       sql_bind object type definition                      --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- NAME: 
--     sql_bind
--
-- DESCRIPTION: 
--     This is an object type to define a bind variable in a SQL statement. This
--     object is returned, given the value of column bind_data in v$sql, 
--     by function dbms_sqltune.extract_bind()
--------------------------------------------------------------------------------
CREATE OR REPLACE TYPE sql_bind 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020213'
AS object (
  name                VARCHAR2(30),                     /* bind variable name */
  position            NUMBER,            /* position of bind in sql statement */
  dup_position        NUMBER,    /* if any, position of primary bind variable */
  datatype            NUMBER,                    /* datatype id for this bind */
  datatype_string     VARCHAR2(15),/* string representation of above datatype */
  character_sid       NUMBER,              /* character set id if bind is NLS */
  precision           NUMBER,                               /* bind precision */
  scale               NUMBER,                                   /* bind scale */
  max_length          NUMBER,                          /* maximum bind length */
  last_captured       DATE,      /* DATE when this bind variable was captured */
  value_string        VARCHAR2(4000),     /* bind value (text representation) */
  value_anydata       ANYDATA)         /* bind value (anydata representation) */
/
-- Public synonym for the type
CREATE OR REPLACE PUBLIC SYNONYM sql_bind FOR sql_bind
/
-- Granting the execution privilege to the public role
GRANT EXECUTE ON sql_bind TO public
/

--------------------------------------------------------------------------------
-- NAME: 
--     sql_bind_set
--
-- DESCRIPTION: 
--     This is a collection (nested table) of type sql_bind. 
--     This collection is used to: 
--       - convert a list of (automatically captured in v$sql) bind value 
--         from RAW to a collection of sql_bind
--       - store the binds (expressed in sql_binds type) in the
--         staging table (during export/import sql tuning set) 
--         since Oracle does not support storing a VARRAY of ANYDATA
--
--------------------------------------------------------------------------------
CREATE TYPE sql_bind_set 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020214'
AS TABLE OF sql_bind
/
-- Public synonym for the type
CREATE OR REPLACE PUBLIC SYNONYM sql_bind_set FOR sql_bind_set
/
-- Granting the execution privilege to the public role
GRANT EXECUTE ON sql_bind_set TO public
/

--------------------------------------------------------------------------------
--                              table definitions                             --
--------------------------------------------------------------------------------
-----------------------------  wri$_adv_sqlt_binds -----------------------------
-- NAME:
--     wri$_adv_sqlt_binds
--
-- DESCRIPTION: 
--     This table stores bind values for a SQL statement.
--
-- PRIMARY KEY:
--     task_id, object_id, position
--
-- FOREIGN KEY:
--     (task_id, object_id) references wri$_adv_objects(task_id, id) 
--------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_binds 
(
  task_id    NUMBER(38) NOT NULL,   
  object_id  NUMBER(38) NOT NULL,      
  position   NUMBER(38) NOT NULL,      
  value      anydata,
  constraint  wri$_adv_sqlt_binds_pk primary key(task_id, object_id, position)
  using index tablespace SYSAUX
)
tablespace SYSAUX  
/

-----------------------------  wri$_adv_sqlt_statistics ------------------------
-- NAME:
--     wri$_adv_sqlt_statistics
--
-- DESCRIPTION: 
--     This table stores sqltune statistics for a SQL statement.
--
-- PRIMARY KEY:
--     task_id, object_id
--
-- FOREIGN KEY:
--     (task_id, object_id) references wri$_adv_objects(task_id, id) 
--------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_statistics 
(
  task_id            NUMBER(38) NOT NULL,   
  object_id          NUMBER(38) NOT NULL,      
  parsing_schema_id  NUMBER,
  module             VARCHAR2(64),
  action             VARCHAR2(64),
  elapsed_time       NUMBER,
  cpu_time           NUMBER,
  buffer_gets        NUMBER,
  disk_reads         NUMBER,
  direct_writes      NUMBER,
  rows_processed     NUMBER,
  fetches            NUMBER,
  executions         NUMBER,
  end_of_fetch_count NUMBER,
  optimizer_cost     NUMBER,
  optimizer_env      RAW(2000),
  command_type       NUMBER,
  constraint  wri$_adv_sqlt_statistics_pk primary key(task_id, object_id)
  using index tablespace SYSAUX
)
tablespace SYSAUX  
/

------------------------- wri$_adv_sqlt_rtn_plan -------------------------------
-- NAME:
--     wri$_adv_sqlt_rtn_plan
--
-- DESCRIPTION:
--    This table stores associations between a rationale and an operation
--    in the execution plan of a SQL statement. 
--
-- PRIMARY KEY:
--    task_id, rtn_id, object_id, plan_attr, operation_id
--
-- FOREIGN KEY:
--     - (task_id, exec_name, object_id, plan_attr) 
--       references wri$_adv_sqlt_plan_hash 
--                    (task_id, exec_name, object_id, attribute) 
--     - (rtn_id, task_id) 
--       references wri$_adv_rationale(id, task_id) 
--------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_rtn_plan 
(
  task_id      NUMBER(38)   NOT NULL,
  exec_name    VARCHAR2(30) NOT NULL,
  rtn_id       NUMBER(38)   NOT NULL,
  object_id    NUMBER(38)   NOT NULL,
  plan_attr    NUMBER(1)    NOT NULL,
  operation_id NUMBER(38)   NOT NULL,
  constraint   wri$_adv_sqlt_rtn_plan_pk 
               primary key(task_id, exec_name, rtn_id, object_id, 
                           plan_attr, operation_id)
  using index tablespace SYSAUX
)
tablespace SYSAUX
/



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                     --------------------------------                       --
--                     SQL TUNING SET SCHEMA DEFINITION                       --
--                     --------------------------------                       --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

--------------------------------------------------------------------------------
--                              type definitionss                             --
--------------------------------------------------------------------------------
----------------------------------- sql_objects --------------------------------
-- NAME: 
--     sql_objects 
--
-- DESCRIPTION: 
--     define a collection type for a SQL statement referenced objects.
--------------------------------------------------------------------------------
CREATE TYPE sql_objects AS VARRAY(2000) OF NUMBER
/    
-- Public synonym for the type
CREATE OR REPLACE PUBLIC SYNONYM sql_objects FOR sql_objects
/
-- Granting the execution privilege to the public role
GRANT EXECUTE ON sql_objects TO public
/

------------------------------------ sqlset_row --------------------------------
-- NAME: 
--     sqlset_row 
--
-- DESCRIPTION: 
--     An object of this type represents a SQL statement and its related 
--     statistic information. 
-- NOTE
--    Please note that if you change this type, you need to make sure you 
--    change schema of the staging table used to export/import sql tuning set 
--    as well as the sql tuning set underlying schema)
--------------------------------------------------------------------------------
CREATE TYPE sqlset_row AS object (
  -- 
  -- sql tuning set basic attributes
  --
  sql_id                   VARCHAR(13),                      /* unique SQL ID */
  force_matching_signature NUMBER,          /* literals, case, spaces removed */
  sql_text                 CLOB,                    /* unique SQL hache value */
  object_list              sql_objects,    /* objects referenced by this stmt */
  bind_data                RAW(2000),   /* bind data as captured for this SQL */
  parsing_schema_name      VARCHAR2(30),    /* schema where the SQL is parsed */
  module                   VARCHAR2(64),      /* last app. module for the SQL */
  action                   VARCHAR2(64),      /* last app. action for the SQL */
  elapsed_time             NUMBER,     /* elapsed time for this SQL statement */
  cpu_time                 NUMBER,                   /* CPU time for this SQL */
  buffer_gets              NUMBER,                   /* number of buffer gets */
  disk_reads               NUMBER,                   /* number of disk reads  */
  direct_writes            NUMBER,                 /* number of direct writes */
  rows_processed           NUMBER,    /* number of rows processed by this SQL */
  fetches                  NUMBER,                       /* number of fetches */
  executions               NUMBER,            /* total executions of this SQL */
  end_of_fetch_count       NUMBER,    /* exec. count fully up to end of fetch */
  optimizer_cost           NUMBER,             /* Optimizer cost for this SQL */
  optimizer_env            RAW(2000),                /* optimizer environment */
  priority                 NUMBER,           /* user-defined priority (1,2,3) */
  command_type             NUMBER,      /* statement type - like INSERT, etc. */
  first_load_time          VARCHAR2(19),        /* load time of parent cursor */
  stat_period              NUMBER,       /* period of time (seconds) when the */
                           /* statistics of this SQL statement were collected */
  active_stat_period       NUMBER,    /* effecive period of time (in seconds) */
                                 /* during which the SQL statement was active */
  other                    CLOB,  /* other column for user defined attributes */
  plan_hash_value          NUMBER,             /* plan hash value of the plan */
  sql_plan                 sql_plan_table_type,               /* explain plan */
  bind_list                sql_binds, /* list of user specified binds for Sql */
                             /* NOTICE: bind_list and bind_data are exclisive */

  --
  -- define a constructor that has default values for sqlset attributes.
  --
  CONSTRUCTOR FUNCTION sqlset_row(  
    sql_id                   VARCHAR2            := NULL,
    force_matching_signature NUMBER              := NULL,
    sql_text                 CLOB                := NULL, 
    object_list              sql_objects         := NULL, 
    bind_data                RAW                 := NULL,   
    parsing_schema_name      VARCHAR2            := NULL,
    module                   VARCHAR2            := NULL,
    action                   VARCHAR2            := NULL,
    elapsed_time             NUMBER              := NULL,
    cpu_time                 NUMBER              := NULL,
    buffer_gets              NUMBER              := NULL,
    disk_reads               NUMBER              := NULL,
    direct_writes            NUMBER              := NULL, 
    rows_processed           NUMBER              := NULL, 
    fetches                  NUMBER              := NULL,
    executions               NUMBER              := NULL,
    end_of_fetch_count       NUMBER              := NULL,
    optimizer_cost           NUMBER              := NULL,      
    optimizer_env            RAW                 := NULL,   
    priority                 NUMBER              := NULL,      
    command_type             NUMBER              := NULL,      
    first_load_time          VARCHAR2            := NULL,
    stat_period              NUMBER              := NULL, 
    active_stat_period       NUMBER              := NULL, 
    other                    CLOB                := NULL, 
    plan_hash_value          NUMBER              := NULL,
    sql_plan                 sql_plan_table_type := NULL,
    bind_list                sql_binds           := NULL)
    RETURN SELF AS RESULT
)
/
CREATE OR REPLACE PUBLIC SYNONYM sqlset_row FOR sqlset_row
/
GRANT EXECUTE ON sqlset_row TO PUBLIC      
/  
  
-------------------------------------- sqlset ----------------------------------
-- NAME: 
--      sqlset
--
-- DESCRIPTION: 
--      define a collection type for SQL statements with their related data.
--------------------------------------------------------------------------------
CREATE TYPE sqlset AS TABLE OF sqlset_row
/
-- Public synonym for the type
CREATE OR REPLACE PUBLIC SYNONYM sqlset FOR sqlset
/
-- Granting the execution privilege to the public role
GRANT EXECUTE ON sqlset TO public      
/  
  
--------------------------------------------------------------------------------
--                             sequence definitions                           --
--------------------------------------------------------------------------------
-------------------------------- WRI$_SQLSET_ID_SEQ ----------------------------
-- NAME:
--     WRI$_SQLSET_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_SQLSET_DEFINITIONS.
--------------------------------------------------------------------------------
CREATE SEQUENCE WRI$_SQLSET_ID_SEQ
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCACHE
  NOCYCLE
/

------------------------------ WRI$_SQLSET_REF_ID_SEQ --------------------------
-- NAME:
--     WRI$_SQLSET_REF_ID_SEQ  
--
-- DESCRIPTION: 
--     This is a sequence to generate ID values for WRI$_SQLSET_REFERENCES.
--------------------------------------------------------------------------------
CREATE SEQUENCE WRI$_SQLSET_REF_ID_SEQ
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCACHE
  NOCYCLE
/

------------------------------ WRI$_SQLSET_STMT_ID_SEQ -------------------------
-- NAME:
--     WRI$_SQLSET_STMT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for SQL statements in 
--     WRI$_SQLSET_STATEMENTS.
--------------------------------------------------------------------------------
CREATE SEQUENCE WRI$_SQLSET_STMT_ID_SEQ
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

------------------------- WRI$_SQLSET_WORKSPACE_PLAN_SEQ -----------------------
-- NAME:
--     WRI$_SQLSET_WORKSPACE_PLAN_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for SQL statement plans in 
--     WRI$_SQLSET_WORKSPACE AND WRI$_SQLSET_WORKSPACE_PLANS.
--     The sequence max vlaue = UB8MAXVAL
--------------------------------------------------------------------------------
CREATE SEQUENCE WRI$_SQLSET_WORKSPACE_PLAN_SEQ
  INCREMENT BY 1
  START WITH 1
  MAXVALUE 18446744073709551615
  CACHE 100
  NOCYCLE
/


--------------------------------------------------------------------------------
--                               table definitions                            --
--------------------------------------------------------------------------------

------------------------------ WRI$_SQLSET_DEFINITIONS -------------------------
-- NAME:
--     WRI$_SQLSET_DEFINITIONS
--
-- DESCRIPTION: 
--     This table stores metadata for a SqlSet
--
-- PRIMARY KEY:
--     The primary is ID.
--------------------------------------------------------------------------------
create table wri$_sqlset_definitions  
(
  id              NUMBER        NOT NULL,
  name            VARCHAR(30)   NOT NULL,
  owner           VARCHAR(30),     
  description     VARCHAR2(256),
  created         DATE,
  last_modified   DATE,
  statement_count NUMBER,
  constraint wri$_sqlset_definitions_pk primary key (id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

-- create a unique index on the sqlset name and owner
create unique index wri$_sqlset_definitions_idx_01 
on wri$_sqlset_definitions(name, owner) 
tablespace sysaux
/


-------------------------------- WRI$_SQLSET_REFERENCES -----------------------
-- NAME:
--     WRI$_SQLSET_REFERENCES  
-- DESCRIPTION:  
--     This table indicates whether a SQLSET is active or not. An SQLSET cannot
--     be dropped if it is referenced. 
--  
-- PRIMARY KEY:
--     The primary key is the reference identifier ID, sqlset_id
--
-- FOREIGN KEY:
--     SQLSET_ID references WRI$_SQLSET_DEFINITIONS(ID)
--------------------------------------------------------------------------------
create table wri$_sqlset_references(
  id          NUMBER        NOT NULL,   
  sqlset_id   NUMBER        NOT NULL,   
  owner       VARCHAR(30),     
  created     DATE,              
  description VARCHAR2(256),
  constraint  wri$_sqlset_references_pk primary key (id, sqlset_id)
  using INDEX tablespace SYSAUX     
) 
tablespace SYSAUX
/  
  
------------------------------- WRI$_SQLSET_STATEMENTS -------------------------
-- NAME:
--     WRI$_SQLSET_STATEMENTS  
--
--  DESCRIPTION:
--     This table describes all the SQL statements that form a SQL tuning set. 
--     This is the main entry in SQL tuning Set. It reprensents the statements
--     with thier parsing related attributes, e.g., parsing_schema_name, module,
--     action, etc.
--
-- PRIMARY KEY:
--     The primary key is (stmt_id). The statement id,m or for short stmt_id, 
--     is an internal key generated using the wri$_sqlset_stmt_id_seq sequence.
--     A new stmt_id is created for every new 
--     (sqlset_id, sql_id, objects_hash_value).
--
-- FOREIGN KEYS:
--      SQLSET_ID references WRI$_SQLSET_DEFINITIONS(ID)
--------------------------------------------------------------------------------
create table wri$_sqlset_statements 
(
  id                       NUMBER        NOT NULL,
  sqlset_id                NUMBER        NOT NULL, 
  sql_id                   VARCHAR(13)   NOT NULL,
  force_matching_signature NUMBER        NOT NULL,
  parsing_schema_name      VARCHAR2(30),  
  module                   VARCHAR2(64),
  action                   VARCHAR2(64),
  command_type             NUMBER,
  constraint wri$_sqlset_statements_pk primary key (id)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

-- create a unique index on the sqlset name
create unique index wri$_sqlset_statements_idx_01 
on wri$_sqlset_statements(sqlset_id, sql_id) 
tablespace sysaux
/

-- create an index for the force_matching_signature
create index wri$_sqlset_statements_idx_02 
on wri$_sqlset_statements(sqlset_id, force_matching_signature) 
tablespace sysaux
/

--------------------------------- WRI$_SQLSET_PLANS ----------------------------
-- NAME:
--     WRI$_SQLSET_PLANS
--
--  DESCRIPTION:
--     This table contains the execution plans for the statements in the SQL 
--     tuning set. 
--       flags               - flags for misc. info about plans
--       masked_binds_flags  - bit per bind to indicate if it is masked
--     The plan lines (details) are stored in table wri$_sqlset_plan_lines 
--     below.
--
-- PRIMARY KEY:
--     The primary key is (STMT_ID, PLAN_HASH_VALUE).
--
-- FOREIGN KEYS:
--     (STMT_ID) references WRI$_SQLSET_STATEMENTS(ID)
--------------------------------------------------------------------------------
create table wri$_sqlset_plans
(
  stmt_id             NUMBER       NOT NULL, 
  plan_hash_value     NUMBER       NOT NULL,
  parsing_schema_name VARCHAR2(30),
  bind_data           RAW(2000),  
  optimizer_env       RAW(2000),
  plan_timestamp      DATE,
  binds_captured      CHAR(1),
  flags               NUMBER,
  masked_binds_flag  RAW(1000),
  constraint wri$_sqlset_plans_pk primary key (stmt_id, plan_hash_value)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

----------------------------- WRI$_SQLSET_PLANS_TOCAP --------------------------
-- NAME:
--     WRI$_SQLSET_PLANS_TOCAP
--
--  DESCRIPTION:
--     This is a temporary table we use for the capture sqlset facility.  We
--     insert the keys to the set of plans that we need to capture.
--
--  PRIMARY KEY:
--     (STMT_ID, PLAN_HASH_VALUE)
--------------------------------------------------------------------------------
create global temporary table wri$_sqlset_plans_tocap
(
  stmt_id         NUMBER,
  sql_id          VARCHAR2(13),
  plan_hash_value NUMBER,
  last_load_time  DATE,                                     /* no longer used */
  constraint wri$_sqlset_plans_tocap_pk primary key (stmt_id, plan_hash_value)
)
/

----------------------------- WRI$_SQLSET_STS_TOPACK ---------------------------
-- NAME:
--     WRI$_SQLSET_STS_TOPACK 
--
--  DESCRIPTION:
--     This is a temporary table we use for packing and unpacking sql tuning
--     sets.  It tracks the IDs, name, owners of the sqlsets that the current 
--     session is going to touch for a pack or unpack operation, according to 
--     the filters passed down to the API.  Note that we make it session-specific
--     because unpack is required to issue commits as part of the operation since
--     it uses INSERT APPEND.
--
--  PRIMARY KEY:
--     (sqlset_id)
--------------------------------------------------------------------------------
create global temporary table wri$_sqlset_sts_topack
(
  sqlset_id NUMBER,
  name      VARCHAR2(30),
  owner     VARCHAR2(30)
)
on commit preserve rows
/


------------------------------- WRI$_SQLSET_STATISTICS -------------------------
-- NAME:
--     WRI$_SQLSET_STATISTICS  
--
--  DESCRIPTION:
--     This table describes the execution statistics for SQL tuning set's
--     statement plans. 
--
--     The _DELTA columns are only used during full capture mode which
--     needs to store one set of deltas that it uses to increment the standard
--     values when a cursor ages out.  Without them it would be impossible to
--     avoid double-counting information when the cursor we see is the same as
--     the one that was previously seen in the cache.  The _DELTA columns will
--     always be zero unless we are in the process of capturing an STS
--
-- PRIMARY KEY:
--     The primary key is (stmt_id, plan_hash_value).
--
-- FOREIGN KEYS:
--     STMT_ID references WRI$_SQLSET_STATEMENTS(ID)
--     plan_hash_value references WRI$_SQLSET_PLANS
--------------------------------------------------------------------------------
create table wri$_sqlset_statistics 
(
  stmt_id               NUMBER       NOT NULL, 
  plan_hash_value       NUMBER       NOT NULL,
  elapsed_time          NUMBER,
  elapsed_time_delta    NUMBER,
  cpu_time              NUMBER,
  cpu_time_delta        NUMBER, 
  buffer_gets           NUMBER,
  buffer_gets_delta     NUMBER, 
  disk_reads            NUMBER,
  disk_reads_delta      NUMBER,  
  direct_writes         NUMBER,
  direct_writes_delta   NUMBER,
  rows_processed        NUMBER,
  rows_processed_delta  NUMBER, 
  fetches               NUMBER,
  fetches_delta         NUMBER,
  executions            NUMBER,
  executions_delta      NUMBER, 
  end_of_fetch_count    NUMBER,
  optimizer_cost        NUMBER,
  first_load_time       VARCHAR2(19),
  first_load_time_delta VARCHAR2(19),
  stat_period           NUMBER, 
  active_stat_period    NUMBER,
  constraint wri$_sqlset_statistics_pk primary key (stmt_id, plan_hash_value)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

--------------------------------- WRI$_SQLSET_MASK -----------------------------
-- NAME:
--     WRI$_SQLSET_MASK 
--
--  DESCRIPTION:
--     This table describes the user defined attributes for SQL tuning set' 
--     statements. 
--
-- PRIMARY KEY:
--     The primary key is (stmt_id, plan_hash_value).
--
-- FOREIGN KEYS:
--     plan_hash_value references WRI$_SQLSET_PLANS(stmt_id, plan_hash_value)
--------------------------------------------------------------------------------
create table wri$_sqlset_mask
(
  stmt_id              NUMBER       NOT NULL, 
  plan_hash_value      NUMBER       NOT NULL,
  priority             NUMBER,
  other                CLOB,
  constraint wri$_sqlset_mask_pk primary key (stmt_id, plan_hash_value)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

----------------------------- WRI$_SQLSET_PLAN_LINES ---------------------------
-- NAME:
--     WRI$_SQLSET_PLAN_LINES
--
--  DESCRIPTION:
--     This table contains the execution plans lines for the statements 
--     in the SQL tuning set.
--
-- PRIMARY KEY:
--     The primary key is (STMT_ID, PLAN_HASH_VALUE, ID).
--
-- FOREIGN KEYS:
--     (STMT_ID, PLAN_HASH_VALUE) references WRI$_SQLSET_PLANS(STMT_ID, 
--      PLAN_HASH_VALUE)
--------------------------------------------------------------------------------
create table wri$_sqlset_plan_lines
(
  stmt_id                NUMBER         NOT NULL, 
  plan_hash_value        NUMBER         NOT NULL,
  statement_id           VARCHAR2(30),
  plan_id                NUMBER,
  timestamp              DATE,
  remarks                VARCHAR2(4000),
  operation              VARCHAR2(30),
  options                VARCHAR2(255),
  object_node            VARCHAR2(128),
  object_owner           VARCHAR2(30),
  object_name            VARCHAR2(30),
  object_alias           VARCHAR2(65),
  object_instance        NUMBER(38),
  object_type            VARCHAR2(30),
  optimizer              VARCHAR2(255),
  search_columns         NUMBER,
  id                     NUMBER(38)     NOT NULL,
  parent_id              NUMBER(38),
  depth                  NUMBER(38),
  position               NUMBER(38),
  cost                   NUMBER(38),
  cardinality            NUMBER(38),
  bytes                  NUMBER(38),
  other_tag              VARCHAR2(255),
  partition_start        VARCHAR2(255),
  partition_stop         VARCHAR2(255),
  partition_id           NUMBER(38),
  other                  LONG,
  distribution           VARCHAR2(30),
  cpu_cost               NUMBER(38),
  io_cost                NUMBER(38),
  temp_space             NUMBER(38),
  access_predicates      VARCHAR2(4000),
  filter_predicates      VARCHAR2(4000),
  projection             VARCHAR2(4000),
  time                   NUMBER(38),
  qblock_name            VARCHAR2(30),  
  other_xml              CLOB,
  executions             NUMBER,
  starts                 NUMBER,
  output_rows            NUMBER,
  cr_buffer_gets         NUMBER,
  cu_buffer_gets         NUMBER,
  disk_reads             NUMBER,
  disk_writes            NUMBER,
  elapsed_time           NUMBER,
  /* begin new columns for 11g */
  last_starts            NUMBER,
  last_output_rows       NUMBER,
  last_cr_buffer_gets    NUMBER,
  last_cu_buffer_gets    NUMBER,
  last_disk_reads        NUMBER,
  last_disk_writes       NUMBER,
  last_elapsed_time      NUMBER,
  policy                 VARCHAR2(10),
  estimated_optimal_size NUMBER,
  estimated_onepass_size NUMBER,
  last_memory_used       NUMBER,
  last_execution         VARCHAR2(10),
  last_degree            NUMBER,
  total_executions       NUMBER,
  optimal_executions     NUMBER,
  onepass_executions     NUMBER,
  multipasses_executions NUMBER,
  active_time            NUMBER,
  max_tempseg_size       NUMBER,
  last_tempseg_size      NUMBER,
  constraint wri$_sqlset_plan_lines_pk primary key (stmt_id,plan_hash_value, id)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

----------------------------------- WRI$_SQLSET_BINDS --------------------------
-- NAME:
--     WRI$_SQLSET_BINDS
--
-- DESCRIPTION:
--     This table stores bind values for a SQL statement plan.
-- 
-- PRIMARY KEY:
--     STMT_ID, PLAN_HASH_VALUE, POSITION
--
-- FOREIGN KEY:
--     The foreign key is (STMT_ID) references 
--     WRI$_SQLSET_PLANS(STMT_ID, PLAN_HASH_VALUE).
--------------------------------------------------------------------------------
create table wri$_sqlset_binds 
(
  stmt_id         NUMBER      NOT NULL, 
  plan_hash_value NUMBER      NOT NULL,
  position        NUMBER      NOT NULL, 
  VALUE           ANYDATA,
  constraint wri$_sqlset_binds_pk primary key (stmt_id,plan_hash_value,position)
  using INDEX tablespace SYSAUX          
) 
tablespace SYSAUX
/

------------------------------ WRI$_SQLSET_WORKSPACE ---------------------------
-- NAME:
--     WRI$_SQLSET_WORKSPACE
--
-- DESCRIPTION: 
--     Contains input and output information for processing a given sql tuning
--     set. 
--
-- PRIMARY KEY:
--     The primary key is workspace_name, sqlset_name, sql_id, plan_hash_value
--
-- NOTE:
--     DO NOT DOCUMENT THIS TABLE. IT IS FOR INTERNAL USE ONLY!!!!!!
--     
--------------------------------------------------------------------------------
create table wri$_sqlset_workspace 
(
  workspace_name  VARCHAR2(30)  NOT NULL, 
  sqlset_name     VARCHAR2(30)  NOT NULL, 
  sql_id          VARCHAR2(13)  NOT NULL, 
  plan_hash_value NUMBER        NOT NULL, 
  control_options CLOB, 
  new_plan_hash   NUMBER,
  plan_id         NUMBER,
  extra_result    CLOB, 
  error_code      NUMBER, 
  error_message   CLOB,
  constraint wri$_sqlset_workspace_pk 
             primary key (workspace_name, sqlset_name, sql_id, plan_hash_value)
  using INDEX tablespace SYSAUX
) 
/

---------------------------- WRI$_SQLSET_WORKSPACE_PLANS -----------------------
-- NAME:
--     WRI$_SQLSET_WORKSPACE_PLANS
--
--  DESCRIPTION:
--     This table contains the execution plans lines for the statements 
--     in the SQL tuning set workspace.
--
-- PRIMARY KEY:
--     The primary key is: 
--       (PLAN_ID, ID).
--
-- FOREIGN KEYS:
--    The foreign key is:
--       (PLAN_ID) 
--    references 
--       WRI$_SQLSET_WORKSPACE
--         (PLAN_ID)
-- NOTE:
--   This table is used for internal testing only.
--------------------------------------------------------------------------------
create table wri$_sqlset_workspace_plans
(
  statement_id           VARCHAR2(30),
  plan_id                NUMBER       NOT NULL,
  timestamp              DATE,
  remarks                VARCHAR2(4000),
  operation              VARCHAR2(30),
  options                VARCHAR2(255),
  object_node            VARCHAR2(128),
  object_owner           VARCHAR2(30),
  object_name            VARCHAR2(30),
  object_alias           VARCHAR2(65),
  object_instance        NUMBER(38),
  object_type            VARCHAR2(30),
  optimizer              VARCHAR2(255),
  search_columns         NUMBER,
  id                     NUMBER(38)     NOT NULL,
  parent_id              NUMBER(38),
  depth                  NUMBER(38),
  position               NUMBER(38),
  cost                   NUMBER(38),
  cardinality            NUMBER(38),
  bytes                  NUMBER(38),
  other_tag              VARCHAR2(255),
  partition_start        VARCHAR2(255),
  partition_stop         VARCHAR2(255),
  partition_id           NUMBER(38),
  other                  LONG,
  distribution           VARCHAR2(30),
  cpu_cost               NUMBER(38),
  io_cost                NUMBER(38),
  temp_space             NUMBER(38),
  access_predicates      VARCHAR2(4000),
  filter_predicates      VARCHAR2(4000),
  projection             VARCHAR2(4000),
  time                   NUMBER(38),
  qblock_name            VARCHAR2(30),  
  other_xml              CLOB,
  executions             NUMBER,
  starts                 NUMBER,
  output_rows            NUMBER,
  cr_buffer_gets         NUMBER,
  cu_buffer_gets         NUMBER,
  disk_reads             NUMBER,
  disk_writes            NUMBER,
  elapsed_time           NUMBER,
  /* begin new columns for 11g */
  last_starts            NUMBER,
  last_output_rows       NUMBER,
  last_cr_buffer_gets    NUMBER,
  last_cu_buffer_gets    NUMBER,
  last_disk_reads        NUMBER,
  last_disk_writes       NUMBER,
  last_elapsed_time      NUMBER,
  policy                 VARCHAR2(10),
  estimated_optimal_size NUMBER,
  estimated_onepass_size NUMBER,
  last_memory_used       NUMBER,
  last_execution         VARCHAR2(10),
  last_degree            NUMBER,
  total_executions       NUMBER,
  optimal_executions     NUMBER,
  onepass_executions     NUMBER,
  multipasses_executions NUMBER,
  active_time            NUMBER,
  max_tempseg_size       NUMBER,
  last_tempseg_size      NUMBER,
  constraint wri$_sqlset_workspace_plans_pk 
  primary key (plan_id, id)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/



--------------------------------------------------------------------------------
--      Register drop sqlset routine to be called after user is dropped       --
--------------------------------------------------------------------------------
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='DBMS_SQLTUNE_INTERNAL' and
  proc='I_DROP_USER_SQLSETS' and operation#=1
/
INSERT INTO sys.duc$ (owner,pack,proc,operation#,seq,com)
  VALUES ('SYS','DBMS_SQLTUNE_INTERNAL','I_DROP_USER_SQLSETS',1,1,
  'During drop cascade, drop sql tuning sets belonging to user')
/
commit
/



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                       -----------------------------                        --
--                       SQL PROFILE SCHEMA DEFINITION                        --
--                       -----------------------------                        --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

--------------------------------------------------------------------------------
--                              type definitions                              --
--------------------------------------------------------------------------------

--
-- NOTE that the sqlprof_attr type limits hints to 500 characters, which was
-- the previous limit used in 10g.  Starting with 11g hints can be bigger, so
-- the type should not be used any longer.  Profiles are now represented as
-- xml in the code.
--
CREATE OR REPLACE TYPE sys.sqlprof_attr
TIMESTAMP '1997-04-12:12:59:00' OID 'AE1A3645A6BD1155E0340800209420B8'
AS VARRAY(2000) of VARCHAR2(500)
/

CREATE OR REPLACE PUBLIC SYNONYM sqlprof_attr FOR sqlprof_attr
/
GRANT EXECUTE ON sqlprof_attr TO public
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                     --------------------------------                       --
--                     SQL MONITORING SCHEMA DEFINITION                       --
--                     --------------------------------                       --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

------------------------------- WRI$_SQLMON_USAGE ------------------------------
-- NAME:
--     WRI$_SQLMON_USAGE
--
--  DESCRIPTION:
--     This table tracks feature usage data for real-time sql monitoring
--
--  PRIMARY KEY:
--     None.  Table has just one row.
--
--------------------------------------------------------------------------------
create table wri$_sqlmon_usage
(
  num_db_reports       NUMBER NOT NULL,
  num_em_reports       NUMBER NOT NULL,
  first_db_report_time DATE,
  last_db_report_time  DATE,
  first_em_report_time DATE,
  last_em_report_time  DATE,
  spare1               NUMBER,
  spare2               NUMBER,
  spare3               NUMBER,
  spare4               NUMBER,
  spare5               DATE,
  spare6               DATE,
  spare7               DATE,
  spare8               DATE
)
/

insert into wri$_sqlmon_usage(
  num_db_reports,
  num_em_reports,
  first_db_report_time, 
  last_db_report_time,
  first_em_report_time,
  last_em_report_time) 
values (0, 0, NULL, NULL, NULL, NULL);

commit;
