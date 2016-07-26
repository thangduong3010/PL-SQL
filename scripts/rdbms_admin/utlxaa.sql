Rem
Rem $Header: utlxaa.sql 27-jul-2004.04:33:29 gssmith Exp $
Rem
Rem utlxaa.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlxaa.sql - Table layout for SQL Access Advisor
Rem
Rem    DESCRIPTION
Rem      Defines a user-defined workload table for SQL Access Advisor
Rem
Rem    NOTES
Rem      The table is used as workload source for SQL Access Advisor.  The
Rem      user will insert desirable SQL statements into the table and then
Rem      specify the table as a workload source within SQL Access Advisor.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gssmith     07/27/04 - gssmith_bug-3765588
Rem    gssmith     07/20/04 - Created
Rem

Rem
Rem     Create the table
Rem

SET ECHO ON

CREATE TABLE user_workload
  (
    username              varchar2(30),       /* User who executes statement */
    module                varchar2(64),           /* Application module name */
    action                varchar2(64),           /* Application action name */
    elapsed_time          number,                  /* Elapsed time for query */
    cpu_time              number,                      /* CPU time for query */
    buffer_gets           number,           /* Buffer gets consumed by query */
    disk_reads            number,            /* Disk reads consumed by query */
    rows_processed        number,       /* Number of rows processed by query */
    executions            number,          /* Number of times query executed */
    optimizer_cost        number,                /* Optimizer cost for query */
    priority              number,                /* User-priority (1,2 or 3) */
    last_execution_date   date,                  /* Last time query executed */
    stat_period           number,        /* Window execution time in seconds */
    sql_text              clob                              /* Full SQL Text */
  );
