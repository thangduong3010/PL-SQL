Rem
Rem $Header: rdbms/admin/catpexe.sql /st_rdbms_11.2.0/2 2013/01/19 01:27:54 anighosh Exp $
Rem
Rem catpexe.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catpexe.sql - CATalog script for DBMS_PARALLEL_EXECUTE
Rem
Rem    DESCRIPTION
Rem      It creates a role, tables and views for DBMS_PARALLEL_EXECUTE
Rem      package.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    anighosh    01/15/13 - Backport anighosh_bug-14296972 from MAIN
Rem    jmuller     12/10/12 - Backport apfwkr_blr_backport_14698700_11.2.0.3.0
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      10/25/12 - Backport jmuller_bug-14698700 from main
Rem    jmuller     10/16/12 - Fix bug 14698700: add index to
Rem                           DBMS_PARALLEL_EXECUTE_CHUNKS$
Rem    achoi       11/01/07 - Created
Rem

-- Administrator Role for DBMS_PARALLEL_EXECUTE.ADM_ subprograms
create role ADM_PARALLEL_EXECUTE_TASK;

Rem EDITION - the edition name. If the edition name was quoted, the quotes are
Rem stored as well.
Rem
Rem APPLY_CROSSEDITION_TRIGGER - the name of the cross edition trigger to apply.
Rem If the trigger name was quoted, the quotes are stored as well.
Rem
Rem Since identifier columns in Oracle are now 128 bytes in length, the edition
Rem column needs to be 130.

-- Create the DBMS_PARALLEL_EXECUTE_TASK$ table
CREATE TABLE DBMS_PARALLEL_EXECUTE_TASK$ 
                 (TASK_OWNER#                NUMBER        NOT NULL,
                  TASK_NAME                  VARCHAR2(128) NOT NULL, 
                  CHUNK_TYPE                 NUMBER        NOT NULL,
                  STATUS                     NUMBER        NOT NULL,
                  TABLE_OWNER                VARCHAR2(30),
                  TABLE_NAME                 VARCHAR2(30),
                  NUMBER_COLUMN              VARCHAR2(30),
                  CMT                        VARCHAR2(4000),
                  JOB_PREFIX                 VARCHAR2(30),
                  STOP_FLAG                  NUMBER,
                  SQL_STMT                   CLOB,
                  LANGUAGE_FLAG              NUMBER,
                  EDITION                    VARCHAR2(32),
                  APPLY_CROSSEDITION_TRIGGER VARCHAR2(32),
                  FIRE_APPLY_TRIGGER         VARCHAR2(10),
                  PARALLEL_LEVEL             NUMBER,
                  JOB_CLASS                  VARCHAR2(30),
                    CONSTRAINT PK_DBMS_PARALLEL_EXECUTE_1
                      PRIMARY KEY (TASK_OWNER#, TASK_NAME)
                 );

-- Create DBMS_PARALLEL_EXECUTE_CHUNKS$ table
CREATE TABLE DBMS_PARALLEL_EXECUTE_CHUNKS$
                 (CHUNK_ID       NUMBER        NOT NULL PRIMARY KEY,
                  TASK_OWNER#    NUMBER        NOT NULL,
                  TASK_NAME      VARCHAR2(128) NOT NULL,
                  STATUS         NUMBER        NOT NULL,
                  START_ROWID    ROWID,
                  END_ROWID      ROWID,
                  START_ID       NUMBER,
                  END_ID         NUMBER,
                  JOB_NAME       VARCHAR2(30),
                  START_TS       TIMESTAMP,
                  END_TS         TIMESTAMP,
                  ERROR_CODE     NUMBER,
                  ERROR_MESSAGE  VARCHAR2(4000),
                    CONSTRAINT FK_DBMS_PARALLEL_EXECUTE_1
                      FOREIGN KEY (TASK_OWNER#, TASK_NAME)
                      REFERENCES DBMS_PARALLEL_EXECUTE_TASK$
                                   (TASK_OWNER#, TASK_NAME)
                      ON DELETE CASCADE
                 );

-- [14698700] Create index on DBMS_PARALLEL_EXECUTE_CHUNKS$.  [Note that the
-- trailing '$' must be dropped to keep the index name within bounds.]
create index i_dbms_parallel_execute_chunks on dbms_parallel_execute_chunks$ 
  (task_owner#, task_name, status);

-- Create DBMS_PARALLEL_EXECUTE_SEQ$ sequence
create sequence dbms_parallel_execute_seq$;


