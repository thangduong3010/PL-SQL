Rem
Rem $Header: rdbms/admin/catamgt.sql /st_rdbms_11.2.0/4 2013/01/31 22:39:35 nkgopal Exp $
Rem
Rem cataudmgmt.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catamgt.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This will install the DBMS_AUDIT_MGMT package
Rem      and the views exposed by the package.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nkgopal     01/28/13 - Bug 16182855: AUD$ in SYS or SYSTEM schema
Rem    nkgopal     06/28/12 - Bug 12853348: Network import failure for FGA_LOG$
Rem    gclaborn    02/17/11 - Fix impcalloutreg$ registrations
Rem    nkgopal     01/28/11 - Bug 10349909: Register DAM_CONFIG_PARAM$,
Rem                           DAM_CLEANUP_JOBS$ and DAM_CLEANUP_EVENTS$ with
Rem                           Datapump for export
Rem    sarchak     04/03/09 - Bug 8406799,retaining existing configuration in
Rem                           DAM_CONFIG_PARAM$
Rem    nkgopal     03/31/09 - Bug 8392745: Add FILE DELETE BATCH SIZE
Rem    nkgopal     10/22/08 - Bug 7427306: Add default Max limits to Files
Rem    nkgopal     04/08/08 - Bug 6954407: DBMS_* views to DBA_* views
Rem                           Create public synonyms to all views
Rem    nkgopal     03/13/08 - Bug 6810355: Add DB DELETE Batch size
Rem    nkgopal     01/11/08 - 
Rem    rahanum     11/02/07 - Merge dbms_audit_mgmt
Rem    nkgopal     06/27/07 - Add comments to views
Rem    ssonawan    06/26/07 - update DBMS_AUDIT_MGMT_CONFIG_PARAMS view def
Rem    nkgopal     06/20/07 - Load DBMS_AUDIT_MGMT package
Rem    nkgopal     06/20/07 - Created
Rem

-- Create the internal tables required
CREATE TABLE DAM_PARAM_TAB$
(
  PARAMETER#           NUMBER            PRIMARY KEY,
  PARAMETER_NAME       VARCHAR2(1024)    NOT NULL
)
/
comment on table DAM_PARAM_TAB$ is
'Audit Trail Properties ID to Name mapping'
/
comment on column DAM_PARAM_TAB$.PARAMETER# is
'Numerical ID of the Audit Trail Property that can be configured'
/
comment on column DAM_PARAM_TAB$.PARAMETER_NAME is
'Name of the Audit Trail Property that can be configured'
/
Rem Audit Trail Type will be identified using numerical code as given below
Rem 1  - 'STANDARD DB AUDIT TRAIL'
Rem 2  - 'FGA DB AUDIT TRAIL'
Rem 3  - 'STANDARD AND FGA DB AUDIT TRAILS'
Rem 4  - 'OS AUDIT TRAIL'
Rem 8  - 'XML AUDIT TRAIL'
Rem 12 - 'OS AND XML AUDIT TRAILS'
Rem 15 - 'ALL AUDIT TRAILS'
Rem
Rem Audit Trail Property units
Rem OS_FILE_MAX_SIZE is measured in KB units
Rem OS_FILE_MAX_AGE is measured in Days
Rem CLEAN_UP_INTERVAL is measured in Hours
CREATE TABLE DAM_CONFIG_PARAM$
(
  PARAM_ID             NUMBER NOT NULL,
  AUDIT_TRAIL_TYPE#    NUMBER NOT NULL,
  NUMBER_VALUE         NUMBER,
  STRING_VALUE         VARCHAR2(4000),
  CONSTRAINT DAM_CONFIG_PARAM_FK1 
    FOREIGN KEY (PARAM_ID) REFERENCES DAM_PARAM_TAB$(PARAMETER#),
  CONSTRAINT DAM_CONFIG_PARAM_UK1 UNIQUE
  (
    PARAM_ID,
    AUDIT_TRAIL_TYPE#
  )
)
/
comment on table DAM_CONFIG_PARAM$ is
'Audit Trail Properties configured for a given Audit Trail Type'
/
comment on column DAM_CONFIG_PARAM$.PARAM_ID is
'Numerical ID of the Audit Trail Property that can be configured'
/
comment on column DAM_CONFIG_PARAM$.AUDIT_TRAIL_TYPE# is
'The Audit Trail Type for which property is configured'
/
comment on column DAM_CONFIG_PARAM$.NUMBER_VALUE is
'The number value for the Audit Trail Property'
/
comment on column DAM_CONFIG_PARAM$.STRING_VALUE is
'The string value for the Audit Trail Property'
/
Rem Last Archive Timestamp: External archival systems are provided a facility 
Rem to indicate which audit records are securely archived. This can be set via 
Rem DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP. This timestamp would typically 
Rem be the timestamp of the last audit record archived.
Rem
Rem Last Archive Timestamp is given in UTC for DB audit trail types
Rem and is given in Local Timezone for OS/XML audit trail types
CREATE TABLE DAM_LAST_ARCH_TS$
(
  AUDIT_TRAIL_TYPE#       NUMBER     NOT NULL,
  RAC_INSTANCE#           NUMBER     NOT NULL,
  LAST_ARCHIVE_TIMESTAMP  TIMESTAMP  NOT NULL,
  CONSTRAINT DAM_LAST_ARCH_TS_UK1 UNIQUE
  (
    AUDIT_TRAIL_TYPE#,
    RAC_INSTANCE#
  )
)
/
comment on table DAM_LAST_ARCH_TS$ is
'Last Archive Timestamps set for the Audit Trail Types'
/
comment on column DAM_LAST_ARCH_TS$.AUDIT_TRAIL_TYPE# is
'The Audit Trail Type for which Last Archive Timestamp is set'
/
comment on column DAM_LAST_ARCH_TS$.RAC_INSTANCE# is
'The RAC instance number for which Last Archive Timestamp is set'
/
comment on column DAM_LAST_ARCH_TS$.LAST_ARCHIVE_TIMESTAMP is
'The Last Archive Timestamp for the Audit Trail Type'
/
CREATE TABLE DAM_CLEANUP_JOBS$
(
  JOB_NAME             VARCHAR2(100)     PRIMARY KEY,
  JOB_STATUS           NUMBER,
  AUDIT_TRAIL_TYPE#    NUMBER            NOT NULL,
  JOB_INTERVAL         NUMBER            NOT NULL,
  JOB_FREQUENCY        VARCHAR2(100)
)
/
comment on table DAM_CLEANUP_JOBS$ is
'Purge Jobs configured for the Audit Trail Types'
/
comment on column DAM_CLEANUP_JOBS$.JOB_NAME is
'Name to identify the Purge Job'
/
comment on column DAM_CLEANUP_JOBS$.JOB_STATUS is
'Status of the Purge Job'
/
comment on column DAM_CLEANUP_JOBS$.AUDIT_TRAIL_TYPE# is
'The Audit Trail Type for which Last Archive Timestamp is set'
/
comment on column DAM_CLEANUP_JOBS$.JOB_INTERVAL is
'Time between the Purge Job runs'
/
comment on column DAM_CLEANUP_JOBS$.JOB_FREQUENCY is
'The repeat interval of the Purge Job'
/
CREATE TABLE DAM_CLEANUP_EVENTS$
(
  SERIAL#              NUMBER            PRIMARY KEY,
  AUDIT_TRAIL_TYPE#    NUMBER            NOT NULL,
  RAC_INSTANCE#        NUMBER            NOT NULL,
  CLEANUP_TIME         TIMESTAMP         NOT NULL, 
  DELETE_COUNT         NUMBER,
  WAS_FORCED           NUMBER
)
/
comment on table DAM_CLEANUP_EVENTS$ is
'The history of Audit Trail cleanup events'
/
comment on column DAM_CLEANUP_EVENTS$.SERIAL# is
'A serial number associated with the cleanup event'
/
comment on column DAM_CLEANUP_EVENTS$.AUDIT_TRAIL_TYPE# is
'The Audit Trail Type which was cleaned during the event'
/
comment on column DAM_CLEANUP_EVENTS$.RAC_INSTANCE# is
'The RAC instance number which was cleaned during the event'
/
comment on column DAM_CLEANUP_EVENTS$.CLEANUP_TIME is
'The timestamp when the cleanup event completed'
/
comment on column DAM_CLEANUP_EVENTS$.DELETE_COUNT is
'The number of audit records/files that was cleaned up during the event'
/
comment on column DAM_CLEANUP_EVENTS$.WAS_FORCED is
'Was the cleanup done without considering Last Archive Timestamp'
/
CREATE SEQUENCE DAM_CLEANUP_SEQ$
START WITH    1
INCREMENT BY  1
NOCYCLE
/
COMMIT
/

Rem The views for external use

Rem Configuration parameters
CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CONFIG_PARAMS
(
   PARAMETER_NAME,
   PARAMETER_VALUE,
   AUDIT_TRAIL
)
AS 
SELECT PARAMETER_NAME,
       (CASE 
            WHEN cfg.PARAM_ID = 22 THEN STRING_VALUE
            ELSE
                CASE
                    WHEN NUMBER_VALUE = 0 THEN 'NOT SET'
                    ELSE TO_CHAR(NUMBER_VALUE)
                END
        END),
       decode(cfg.AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
                 'UNKNOWN AUDIT TRAIL')
FROM DAM_CONFIG_PARAM$ cfg, DAM_PARAM_TAB$ prm
WHERE prm.PARAMETER# = cfg.PARAM_ID
/
comment on table DBA_AUDIT_MGMT_CONFIG_PARAMS is
'The view displays the currently configured audit trail properties that are defined by the DBMS_AUDIT_MGMT PL/SQL package'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.PARAMETER_NAME is
'Name of the Property'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.PARAMETER_VALUE is
'Value of the Property'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.AUDIT_TRAIL is
'Audit Trail(s) for which the property is configured'
/
create or replace public synonym DBA_AUDIT_MGMT_CONFIG_PARAMS for 
DBA_AUDIT_MGMT_CONFIG_PARAMS
/

CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_LAST_ARCH_TS
(
   AUDIT_TRAIL,
   RAC_INSTANCE,
   LAST_ARCHIVE_TS
)
AS
SELECT decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
                 'UNKNOWN AUDIT TRAIL'),
       RAC_INSTANCE#,
       decode(AUDIT_TRAIL_TYPE#,
              1, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, '0:00'),
              2, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, '0:00'),
              4, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, TZ_OFFSET(sessiontimezone)),
              8, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, TZ_OFFSET(sessiontimezone)),
                 LAST_ARCHIVE_TIMESTAMP)
FROM DAM_LAST_ARCH_TS$
/
comment on table DBA_AUDIT_MGMT_LAST_ARCH_TS is
'The Last Archive Timestamps set for the Audit Trail Clean up'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.AUDIT_TRAIL is
'The Audit Trail for which the Last Archive Timestamp applies'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.RAC_INSTANCE is
'The RAC Instance Number for which the Last Archive Timestamp applies. Zero implies ''Not Applicable'''
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.LAST_ARCHIVE_TS is
'The Timestamp of the last audit record or audit file that has been archived'
/
create or replace public synonym DBA_AUDIT_MGMT_LAST_ARCH_TS for 
DBA_AUDIT_MGMT_LAST_ARCH_TS
/

CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CLEANUP_JOBS
(
   JOB_NAME,
   JOB_STATUS,
   AUDIT_TRAIL,
   JOB_FREQUENCY
)
AS
SELECT JOB_NAME,
       decode(JOB_STATUS,
              0, 'DISABLED',
              1, 'ENABLED',
                 'UNKNOWN'),
       decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
                 'UNKNOWN AUDIT TRAIL'),
       JOB_FREQUENCY
FROM DAM_CLEANUP_JOBS$
/
comment on table DBA_AUDIT_MGMT_CLEANUP_JOBS is
'The view displays the currently configured audit trail purge jobs'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_NAME is
'The name of the Audit Trail Purge Job'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_STATUS is
'The current status of the Audit Trail Purge Job'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.AUDIT_TRAIL is
'The Audit Trail for which the Audit Trail Purge Job is configured'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_FREQUENCY is
'The frequency at which the Audit Trail Purge Job runs'
/
create or replace public synonym DBA_AUDIT_MGMT_CLEANUP_JOBS for 
DBA_AUDIT_MGMT_CLEANUP_JOBS
/

CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CLEAN_EVENTS
(
   AUDIT_TRAIL,
   RAC_INSTANCE,
   CLEANUP_TIME,
   DELETE_COUNT,
   WAS_FORCED
)
AS
SELECT decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
                 'UNKNOWN AUDIT TRAIL'),
        RAC_INSTANCE#,
        FROM_TZ(CLEANUP_TIME, '0:00'),
        DELETE_COUNT,
        decode(WAS_FORCED,
               0, 'NO',
               1, 'YES',
               null)
FROM DAM_CLEANUP_EVENTS$
ORDER BY SERIAL#
/
comment on table DBA_AUDIT_MGMT_CLEAN_EVENTS is
'The history of cleanup events'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.AUDIT_TRAIL is
'The Audit Trail that was cleaned at the time of the event'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.RAC_INSTANCE is
'The Instance Number indiccating the RAC Instance that was cleaned up at the time of the event. Zero implies ''Not Applicable'''
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.CLEANUP_TIME is
'The Timestamp in GMT when the cleanup event completed'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.DELETE_COUNT is
'The number of audit records or audit files that were deleted at the time of the event'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.WAS_FORCED is
'Indicates whether or not a Forced Cleanup occured. Forced Cleanup bypasses the Last Archive Timestamp set'
/
create or replace public synonym DBA_AUDIT_MGMT_CLEAN_EVENTS for 
DBA_AUDIT_MGMT_CLEAN_EVENTS
/

-- INSERT Properties supported
-- These IDs map to the constants defined in DBMS_AUDIT_MGMT package
-- Truncate the tables before INSERT

CREATE OR REPLACE PROCEDURE INSERT_INTO_DAMPARAMTAB$ 
           (t_parameter                IN  PLS_INTEGER,
            t_parameter_name           IN  VARCHAR2
           )
IS
    m_sql_stmt       VARCHAR2(2000);
BEGIN
    m_sql_stmt       := 'insert into sys.dam_param_tab$ '||
                        'values(:1,:2)';
    EXECUTE IMMEDIATE m_sql_stmt using t_parameter,t_parameter_name;
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00001) THEN  --ignore unique constraint violation
    -- Parameter name changed from CLEANUP TRACE LEVEL to 
    -- AUDIT MANAGEMENT TRACE LEVEL from 11.1.0.7 to 11.2
    IF ( t_parameter = 24 ) THEN
      m_sql_stmt    := 'update dam_param_tab$ set '||
                       'parameter_name=:1 where '||
                       'parameter#=24';
      EXECUTE IMMEDIATE m_sql_stmt using t_parameter_name;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Configuration already exists for '||t_parameter_name);
  ELSE RAISE;
  END IF;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (16, 'AUDIT FILE MAX SIZE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (17, 'AUDIT FILE MAX AGE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (21, 'DEFAULT CLEAN UP INTERVAL') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (22, 'DB AUDIT TABLESPACE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (23, 'DB AUDIT CLEAN BATCH SIZE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (24, 'AUDIT MANAGEMENT TRACE LEVEL') ;
END;
/

-- Parameter 25 is reserved for audit table movement flag. 
-- And must not be inserted in DAM_PARAM_TAB$

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (26, 'OS FILE CLEAN BATCH SIZE') ;
END;
/

CREATE OR REPLACE PROCEDURE INSERT_INTO_DAMCONFIGPARAMS$
           (t_param_id                IN  PLS_INTEGER,
            t_audit_trail_type        IN  PLS_INTEGER,
            t_number_value            IN  PLS_INTEGER ,
            t_string_value            IN  VARCHAR2
           )
IS
    m_sql_stmt         VARCHAR2(2000);
BEGIN
    IF ( t_number_value is  NULL ) THEN
      m_sql_stmt    := 'insert into sys.dam_config_param$ ' || 
                       'values(:1,:2,NULL,:3)';
      EXECUTE IMMEDIATE m_sql_stmt using t_param_id,t_audit_trail_type,
                        t_string_value;
    ELSE
      m_sql_stmt    := 'insert into sys.dam_config_param$ ' ||
                       'values(:1,:2,:3,:4)';
      EXECUTE IMMEDIATE m_sql_stmt using t_param_id,t_audit_trail_type,
                        t_number_value,t_string_value;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00001) THEN  --ignore unique constraint violation
      DBMS_OUTPUT.PUT_LINE('Configuration already exists for param_id : ' ||
                            t_param_id);
  ELSE RAISE;
  END IF;
END;
/

--(DB AUDIT TABLESPACE , AUD$, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(22, 1, NULL, 'SYSAUX') ;
END;
/

--(DB AUDIT TABLESPACE , FGA_LOG$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(22 , 2, NULL, 'SYSAUX') ;
END;
/

-- Default OS/XML File Max Size and Age
--( AUDIT FILE MAX SIZE, OS Audit Trail, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(16 , 4 , 10000 , NULL) ;
END;
/

--( AUDIT FILE MAX SIZE, XML Audit Trail, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(16 , 8 , 10000 , NULL) ;
END;
/

--( AUDIT FILE MAX AGE, OS Audit Trail , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(17 , 4 , 5 , NULL) ;
END;
/

--( AUDIT FILE MAX AGE, XML Audit Trail , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(17 , 8 , 5 , NULL) ;
END;
/

-- Default Delete Batch Size
--( DB AUDIT CLEAN BATCH SIZE, AUD$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(23 , 1 , 10000 , NULL) ;
END;
/

--( DB AUDIT CLEAN BATCH SIZE, FGA_LOG$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(23 , 2 , 10000 , NULL) ;
END;
/

-- Parameter 25 is reserved for audit table movement flag. 
-- And must not be inserted in DAM_PARAM_TAB$

--(OS FILE CLEAN BATCH SIZE,OS AUDIT TRAIL,<NUMBER_VALUE>,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$( 26 , 4 , 1000 , NULL );
END;
/

--(OS FILE CLEAN BATCH SIZE,XML AUDIT TRAIL,<NUMBER_VALUE>,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$( 26 , 8 , 1000 , NULL );
END;
/

DROP PROCEDURE INSERT_INTO_DAMPARAMTAB$
/
DROP PROCEDURE INSERT_INTO_DAMCONFIGPARAMS$
/

COMMIT
/

Rem Regsiter the following tables for Export with Datapump (sys.impcalloutreg$)
Rem
Rem First make sure SYSTEM.AUD$ is not exported (when OLS installed)
Rem Make an entry to SYS.NOEXP$
delete from sys.noexp$ where name = 'AUD$' and owner = 'SYSTEM';
insert into sys.noexp$ (owner, name, obj_type) values
('SYSTEM', 'AUD$', 2);
commit;

Rem
Rem Bug 14029047: 
Rem FGA_LOG$ will not be imported via Network Import because of its LONG column
Rem So, register a view without Long column
Rem 
create or replace view fga_log$for_export (
     sessionid, timestamp#, dbuid, osuid, oshst, clientid, extid, 
     obj$schema, obj$name, policyname, scn, sqltext, lsqltext, sqlbind,
     comment$text, 
     stmt_type, ntimestamp#, proxy$sid, user$guid, instance#, process#,
     xid, auditid, statement, entryid, dbid, lsqlbind, obj$edition)
as
select
     sessionid, timestamp#, dbuid, osuid, oshst, clientid, extid, 
     obj$schema, obj$name, policyname, scn, sqltext, lsqltext, sqlbind,
     comment$text, /* No PLHOL column */
     stmt_type, ntimestamp#, proxy$sid, user$guid, instance#, process#,
     xid, auditid, statement, entryid, dbid, lsqlbind, obj$edition
from sys.fga_log$
/
grant select on fga_log$for_export to select_catalog_role
/
create table fga_log$for_export_tbl as select * from fga_log$for_export
where 0 = 1 /* just a table with no rows, required only for meta-data */
/
grant select on fga_log$for_export_tbl to select_catalog_role
/
Rem
Rem Also create a view to store current audit table tablespaces to help
Rem movement on the target database
Rem
create or replace view audtab$tbs$for_export (owner, name, ts_name)
as
select owner, table_name, tablespace_name from dba_tables
where table_name = 'AUD$' and owner in ('SYS', 'SYSTEM') or
      table_name = 'FGA_LOG$' and owner = 'SYS'
/
grant select on audtab$tbs$for_export to select_catalog_role
/
create table audtab$tbs$for_export_tbl as select * from audtab$tbs$for_export
where 0 = 1
/
grant select on audtab$tbs$for_export_tbl to select_catalog_role
/

Rem Next Delete existing entries, if any
delete from sys.impcalloutreg$ where tag = 'AUDIT_TRAILS';

Rem
Rem Need to know Audit Trail Configuration first 
Rem
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 1, 0, 'SYS', 'DAM_CONFIG_PARAM$', 
  2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Also, send tablespace names
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 2, 0, 'SYS', 
 'AUDTAB$TBS$FOR_EXPORT', 4 /*view*/,
 'Database Audit Trails and their configuration');

Rem Now, Register both possible locations for AUD$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 3, 0, 'SYS', 'AUD$', 2 /*table*/,
 'Database Audit Trails and their configuration');
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 3, 0, 'SYSTEM', 'AUD$', 
  2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register FGA_LOG$ for 11.2.0.3 support
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 4, 8, 'SYS', 'FGA_LOG$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register FGA_LOG$FOR_EXPORT
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 5, 1, 'SYS', 'FGA_LOG$FOR_EXPORT', 
 4 /*view*/,
 'Database Audit Trails and their configuration');

Rem Next, register DAM_CLEANUP_JOBS$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 6, 0, 'SYS', 'DAM_CLEANUP_JOBS$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register DAM_CLEANUP_EVENTS$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 7, 0, 'SYS', 'DAM_CLEANUP_EVENTS$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

commit;

Rem *************************************************************************
