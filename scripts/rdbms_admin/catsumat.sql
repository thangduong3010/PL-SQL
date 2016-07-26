Rem
Rem $Header: catsumat.sql 09-nov-2006.09:22:54 ilistvin Exp $
Rem
Rem cataat.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catsumat.sql - SQL Access Advisor table definitions
Rem
Rem    DESCRIPTION
Rem      Contains all catalog definitions for the SQL Access Advisor component
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    11/09/06 - move execution of catsumaa.sql to depssvrm.sql
Rem    gssmith     04/28/06 - Created
Rem

REM
REM   SQL Access Advisor tables
REM

Rem
Rem   Sequence for query id numbers
Rem

create sequence wri$_adv_seq_sqlw_query      /* Generates unique task number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem SQL workload rollup table
Rem

create table wri$_adv_sqlw_sum
  (
    workload_id             number,                    /* Workload id number */
    data_source             varchar2(2000),          /* Workload data source */
    num_select              number,         /* Number of selects in workload */
    num_insert              number,        /* Number of insertss in workload */
    num_delete              number,         /* Number of deletes in workload */
    num_update              number,         /* Number of updates in workload */
    num_merge               number,          /* Number of merges in workload */
    sqlset_id               number,                /* Link to SQL Tuning Set */
    sqlset_ref_id           number,                  /* Reference ID for STS */
    constraint wri$_adv_sqlw_sum_pk primary key(workload_id)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem Access Advisor workload statements
Rem
Rem         Valid values for valid column:
Rem
Rem             0 - unused
Rem             1 - Valid after workload filtering
Rem             2 - Valid after applying importance filtering

create table wri$_adv_sqlw_stmts
   (
      workload_id             number,                 /* Workload identifier */
      sql_id                  number,                    /* SQL statement id */
      hash_value              number,                   /* Statement hash id */
      optimizer_cost          number,             /* Declared optimizer cost */
      username                varchar2(30),   /* User who executed statement */
      module                  varchar2(64),       /* Application module name */
      action                  varchar2(64),       /* Application action name */
      elapsed_time            number,                  /* Total Elapsed time */
      cpu_time                number,                      /* Total CPU time */
      buffer_gets             number,                   /* Total buffer gets */
      disk_reads              number,                    /* Total disk reads */
      rows_processed          number,                /* Total rows processed */
      executions              number,                    /* Total executions */
      priority                number,         /* Statement business priority */
      last_execution_date     date,              /* Last execution date/time */
      command_type            number,                        /* Command type */
      stat_period             number,                    /* Execution window */
      sql_text                clob,                        /* Statement text */
      valid                   number,                  /* Statement is valid */
      constraint wri$_adv_sqlw_stmts_pk primary key(workload_id,sql_id)
        using index tablespace SYSAUX
   )
tablespace sysaux
/


Rem
Rem   sql Workload table references
Rem
Rem         Contains a list of tables referenced by each workload statement
Rem

create table wri$_adv_sqlw_tables
   (
      workload_id             number,                 /* Workload identifier */
      sql_id                  number,                    /* SQL statement id */
      table_owner#            number,         /* Owner id of table reference */
      table#                  number,         /* Table id of table reference */
      table_owner             varchar2(30),              /* Table owner name */
      table_name              varchar2(30),                    /* Table name */
      inst_id                 number,                         /* Instance id */
      hash_value              number,                /* Statement hash value */
      addr                    raw(16),                  /* Statement address */
      obj_type                number                          /* Object type */
   )
tablespace sysaux
/

create index wri$_adv_sqlw_tables_idx_01
   on wri$_adv_sqlw_tables (workload_id,sql_id)
  tablespace SYSAUX
/

Rem
Rem SQL workload table volatility rollup
Rem

create table wri$_adv_sqlw_tabvol
  (
    workload_id             number,                    /* Workload id number */
    owner_name              varchar2(30),                      /* Owner name */
    table_owner#            number,           /* Owner id of table reference */
    table_name              varchar2(30),                      /* Table name */
    table#                  number,           /* Table id of table reference */
    upd_freq                number,                      /* # of update hits */
    ins_freq                number,                      /* # of insert hits */
    del_freq                number,                      /* # of delete hits */
    dir_freq                number,                 /* # of direct load hits */
    upd_rows                number,                     /* # of updated rows */
    ins_rows                number,                    /* # of inserted rows */
    del_rows                number,                     /* # of deleted rows */
    dir_rows                number,                 /* # of direct load rows */
    constraint wri$_adv_sqlw_tv_pk primary key(workload_id,table#)
       using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem SQL workload column volatility rollup
Rem
Rem     Columns changed by an update statement
Rem

create table wri$_adv_sqlw_colvol
  (
    workload_id             number,                    /* Workload id number */
    table_owner#            number,           /* Owner id of table reference */
    table#                  number,           /* Table id of table reference */
    col#                    number,          /* Column id of table reference */
    upd_freq                number,                             /* # of hits */
    upd_rows                number,         /* Total rows effected by update */
    constraint wri$_adv_sqlw_cv_pk primary key(workload_id,table#,col#)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem   Workload mapping table
Rem

create table wri$_adv_sqla_map
   (
      task_id                 number,                             /* Task id */
      workload_id             number,                  /* Workload or STS id */
      name                    varchar2(30),                  /* Workload name*/
      is_sts                  number,                /* 0 - SQLWKLD, 1 - STS */
      ref_id                  number,                /* SQL set reference ID */
      child_id                number                     /* Child STS object */
   )
tablespace sysaux
/

create index wri$_adv_sqla_map_01
   on wri$_adv_sqla_map (task_id)
  tablespace SYSAUX
/

Rem
Rem SQL workload rollup table for a task
Rem

create table wri$_adv_sqla_sum
  (
    task_id                 number,                        /* Task id number */
    num_select              number,         /* Number of selects in workload */
    num_insert              number,        /* Number of insertss in workload */
    num_delete              number,         /* Number of deletes in workload */
    num_update              number,         /* Number of updates in workload */
    num_merge               number,          /* Number of merges in workload */
    constraint wri$_adv_sqla_sum_pk primary key(task_id)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem sql workload statements (private to Access Advisor tasks)
Rem

create table wri$_adv_sqla_stmts
   (
      task_id                 number not null,             /* Task id number */
      workload_id             number,                 /* Workload identifier */
      stmt_id                 number,                         /* Sequence ID */
      sql_id                  varchar2(13),              /* SQL statement id */
      pre_cost                number,                  /* Optimizer pre-cost */
      post_cost               number,                 /* Optimizer post-cost */
      imp                     number,               /* Calculated importance */
      rec_id                  number,                   /* Recommendation id */
      validated               number                     /* Filtering marker */
   )
tablespace sysaux
/

create index wri$_adv_sqla_stmts_idx_01
   on wri$_adv_sqla_stmts (task_id,workload_id,sql_id)
  tablespace SYSAUX
/

create index wri$_adv_sqla_stmts_idx_02
   on wri$_adv_sqla_stmts (task_id,validated)
  tablespace SYSAUX
/

Rem
Rem   sql Workload table references
Rem
Rem         Contains a list of tables referenced by each workload statement
Rem

create table wri$_adv_sqla_tables
   (
      task_id                 number,                     /* Task identifier */
      sql_id                  varchar2(13),              /* SQL statement id */
      stmt_id                 number,              /* SQL statement sequence */
      table_owner#            number,         /* Owner id of table reference */
      table#                  number,         /* Table id of table reference */
      table_owner             varchar2(30),              /* Table owner name */
      table_name              varchar2(30),                    /* Table name */
      obj_type                number                          /* Object type */
   )
tablespace sysaux
/

create index wri$_adv_sqla_tables_idx_01
   on wri$_adv_sqla_tables (task_id,sql_id)
  tablespace SYSAUX
/

Rem
Rem AA workload table volatility rollup
Rem

create table wri$_adv_sqla_tabvol
  (
    task_id                 number,                        /* task id number */
    owner_name              varchar2(30),                      /* Owner name */
    table_owner#            number,           /* Owner id of table reference */
    table_name              varchar2(30),                      /* Table name */
    table#                  number,           /* Table id of table reference */
    upd_freq                number,                      /* # of update hits */
    ins_freq                number,                      /* # of insert hits */
    del_freq                number,                      /* # of delete hits */
    dir_freq                number,                 /* # of direct load hits */
    upd_rows                number,                     /* # of updated rows */
    ins_rows                number,                    /* # of inserted rows */
    del_rows                number,                     /* # of deleted rows */
    dir_rows                number,                 /* # of direct load rows */
    constraint wri$_adv_sqla_tv_pk primary key(task_id,table#)
       using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem Access Advisor column volatility rollup
Rem
Rem     Columns changed by an update statement
Rem

create table wri$_adv_sqla_colvol
  (
    task_id                 number,                        /* Task id number */
    table_owner#            number,           /* Owner id of table reference */
    table#                  number,           /* Table id of table reference */
    col#                    number,          /* Column id of table reference */
    upd_freq                number,                             /* # of hits */
    upd_rows                number,         /* Total rows effected by update */
    constraint wri$_adv_sqla_cv_pk primary key(task_id,table#,col#)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem   Access Advisor temporary table
Rem

create table wri$_adv_sqla_tmp
   (
      owner#                  number,
      constraint wri$_adv_sqla_tmp_pk primary key(owner#)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem   Access Advisor fake-mv, fake-index registration table
Rem

create table wri$_adv_sqla_fake_reg
   (
      task_id                 number,                    /* Task id of owner */
      owner                   varchar2(30),          /* Owner name of object */
      name                    varchar2(30),                /* Name of object */
      fake_type               number                    /* 1 = Index, 2 = MV */
   )
tablespace sysaux
/

create index wri$_adv_sqla_freg_idx_01
  on wri$_adv_sqla_fake_reg (task_id)
  tablespace SYSAUX;

