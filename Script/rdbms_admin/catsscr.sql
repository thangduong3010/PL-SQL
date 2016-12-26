Rem
Rem $Header: rdbms/admin/catsscr.sql /st_rdbms_11.2.0/1 2012/01/13 23:08:59 yberezin Exp $
Rem
Rem catsscr.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsscr.sql - Session Capture and Restore calog objects
Rem
Rem    DESCRIPTION
Rem      This script defines the catalog views to support
Rem      session capture and restore
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/08/12 - Backport yberezin_bug-12926385 from main
Rem    chliang     05/03/06 - add sscr objects
Rem    chliang     05/03/06 - Created
Rem


/* create sscr capture and restore tables */
create table sscr_cap$
(
  /* capturing session information */
  db_name                   varchar2(4000),                /* source db name */
  inst_name                 varchar2(4000),                 /* instance name */
  inst_id                   number,                           /* instance id */
  sid                       number,                            /* session id */
  serial#                   number,                       /* session serial# */
  user_id                   number,                               /* user id */
  schema_id                 number,                             /* schema id */
  /* capture information */
  seq#                      number,               /* capture sequence number */
  cmode                     number,                          /* capture mode */
  scope                     number,                         /* capture scope */
  format                    number,                        /* capture format */
  directory                 varchar2(30),               /* capture directory */
  locator                   raw(64),                /* session state locator */
  capture_time              timestamp                        /* capture time */
)
tablespace SYSAUX
/

create index i_sscr_cap$ on sscr_cap$(seq#)
tablespace SYSAUX
/

create table sscr_res$
(
  /* restoring session information */
  db_name                   varchar2(4000),                /* source db name */
  inst_name                 varchar2(4000),                 /* instance name */
  inst_id                   number,                           /* instance id */
  sid                       number,                            /* session id */
  serial#                   number,                       /* session serial# */
  user_id                   number,                               /* user id */
  schema_id                 number,                             /* schema id */
  /* restore information */
  seq#                      number,               /* capture sequence number */
  rmode                     number,                          /* restore mode */
  scope                     number,                         /* restore scope */
  format                    number,                        /* restore format */
  directory                 varchar2(30),               /* capture directory */
  locator                   raw(64),                /* session state locator */
  restore_time              timestamp                        /* restore time */
)
tablespace SYSAUX
/

create index i_sscr_res$ on sscr_res$(seq#)
tablespace SYSAUX
/

create sequence sscr_cap_seq$
  increment by 1
  start with 1
  minvalue 0
  nomaxvalue
  cache 10
  order
  nocycle
/


-- Create migration history view for source sessions
CREATE OR REPLACE VIEW dba_sscr_capture
(
  db_name, 
  inst_name, 
  inst_id, 
  session_id,
  session_serial#,
  user_name,
  schema_name,
  sequence#,
  capture_mode,
  capture_scope,
  capture_format,
  capture_dir,
  capture_locator,
  capture_time
)
AS SELECT
  c.db_name, 
  c.inst_name,
  c.inst_id, 
  c.sid,
  c.serial#,
  u.name,
  s.name,
  c.seq#,
  decode(c.cmode,
         0, 'SESSION', 
         1, 'GLOBAL',
         'UNKNOWN'),
  decode(c.scope,
         0, 'NONE',
         1, 'MINIMAL',
         2, 'TYPICAL',
         3, 'FULL', 
         'UNKNOWN'),
  decode(c.format,
         0, 'NATIVE', 
         1, 'UNIVERSAL'),
  c.directory,
  c.locator,
  c.capture_time
FROM sscr_cap$ c, user$ u, user$ s
WHERE 
  (c.user_id = u.user# AND c.schema_id = s.user#)
/
COMMENT ON TABLE DBA_SSCR_CAPTURE IS
'Session state capture statistics'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.DB_NAME IS
'Database name of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.INST_NAME IS
'Instance name of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.INST_ID IS
'Instance id of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.SESSION_ID IS
'Session ID of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.SESSION_SERIAL# IS
'Session serial# of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.USER_NAME IS
'User name of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.SCHEMA_NAME IS
'Schema name of captured session'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.SEQUENCE# IS
'Sequence# of capture operation'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_MODE IS
'Mode of capture operation'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_SCOPE IS
'Scope of capture operation'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_FORMAT IS
'Format of capture files'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_DIR IS
'Directory object of capture files'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_LOCATOR IS
'Locator of master capture file'
/
COMMENT ON COLUMN DBA_SSCR_CAPTURE.CAPTURE_TIME IS
'Timestamp of capture operation'
/

create or replace public synonym dba_sscr_capture for dba_sscr_capture
/
grant select on dba_sscr_capture to select_catalog_role
/

CREATE OR REPLACE VIEW dba_sscr_restore
(
  db_name, 
  inst_name, 
  inst_id, 
  session_id,
  session_serial#,
  user_name,
  schema_name,
  sequence#,
  restore_mode,
  restore_scope,
  restore_format,
  restore_dir,
  restore_locator,
  restore_time
)
AS SELECT
  r.db_name, 
  r.inst_name,
  r.inst_id, 
  r.sid,
  r.serial#,
  u.name,
  s.name,
  r.seq#,
  decode(r.rmode,
         0, 'SESSION', 
         1, 'GLOBAL',
         'UNKNOWN'),
  decode(r.scope,
         0, 'NONE',
         1, 'MINIMAL',
         2, 'TYPICAL',
         3, 'FULL', 
         'UNKNOWN'),
  decode(r.format,
         0, 'NATIVE', 
         1, 'UNIVERSAL'),
  r.directory,
  r.locator,
  r.restore_time
FROM sscr_res$ r, user$ u, user$ s
WHERE 
  (r.user_id = u.user# AND r.schema_id = s.user#)
/
COMMENT ON TABLE DBA_SSCR_RESTORE IS
'Session state restore statistics'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.DB_NAME IS
'Database name of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.INST_NAME IS
'Instance name of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.INST_ID IS
'Instance id of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.SESSION_ID IS
'Session ID of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.SESSION_SERIAL# IS
'Session serial# of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.USER_NAME IS
'User name of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.SCHEMA_NAME IS
'Schema name of restored session'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.SEQUENCE# IS
'Sequence# of restore operation'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_MODE IS
'Mode of restore operation'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_SCOPE IS
'Scope of restore operation'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_FORMAT IS
'Format of restore files'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_DIR IS
'Directory object of restore files'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_LOCATOR IS
'Locator of master restore file'
/
COMMENT ON COLUMN DBA_SSCR_RESTORE.RESTORE_TIME IS
'Timestamp of restore operation'
/

create or replace public synonym dba_sscr_restore for dba_sscr_restore
/
grant select on dba_sscr_restore to select_catalog_role
/
