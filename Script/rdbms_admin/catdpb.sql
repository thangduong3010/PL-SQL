Rem
Rem $Header: rdbms/admin/catdpb.sql /st_rdbms_11.2.0/4 2013/02/01 10:11:05 cchiappa Exp $
Rem
Rem catdpb.sql
Rem
Rem Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catdpb.sql - Main install script for all DataPump package body
Rem                   components
Rem
Rem    DESCRIPTION
Rem     The DataPump is all the infrastructure required for new server-based
Rem     data movement utilities. This script installs the package body portion
Rem     its components including the Metadata API which was previously
Rem     installed separately (and still can be for testing purposes).
Rem     catproc.sql will now just invoke this script.
Rem
Rem    NOTES
Rem     1. Ordering of operations within this file:
Rem        a. Public view definitions
Rem        b. Package and type bodies.
Rem        c. Misc. stuff (like install XSL stylesheets)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cchiappa    12/10/12 - Backport
Rem                           cchiappa_bug-10332890_olap_full_transport
Rem                           (10332890 - OLAP / AW SUPPORT FOR FULL DATABASE
Rem                           TRANSPORTABLE EXPORT / IMPORT)
Rem    verangan    06/22/12 - XbranchMerge verangan_bug-14147811 from main
Rem    sdipirro    01/04/12 - Backport sdipirro_bug-9619018 from main
Rem    jstenois    03/01/11 - lrg 5136776: do not export DMSYS
Rem    ebatbout    09/10/09 - bug 8523879: Add MGDSYS user to ku_noexp_tab
Rem    dvoss       03/19/09 - bug 8350972, logstdby_administrator, ku_noexp_tab
Rem    dgagne      02/02/09 - put ku_list_filter_temp back and create a version
Rem                           2 table
Rem    rlong       09/25/08 - 
Rem    dsemler     08/07/08 - 
Rem    dgagne      07/01/08 - add columns to ku$_list_filter_temp
Rem    dgagne      05/19/08 - add TSMSYS to the noexp table
Rem    pknaggs     05/12/08 - bug 6938028: Database Vault protected schema.
Rem    msakayed    04/17/08 - compression/encryption feature tracking for 11.2
Rem    dsemler     02/28/08 - Add APPQOSSYS user to noexp table
Rem    bmccarth    02/19/08 - add view for getting directory objects - legacy
Rem                           mode
Rem    sdipirro    04/18/07 - Support multiple queue tables
Rem    wfisher     05/18/07 - granting AUDIT ANY and CREATE PROFILE to
Rem                           IMP_FULL_DATABASE
Rem    htseng      05/03/07 - bug 5567364: DEFAULT profile
Rem    wfisher     02/02/07 - Adding ku$_list_filter_temp
Rem    dgagne      12/26/06 - add alter database to datapump_imp_full_database
Rem    dgagne      11/01/06 - add idr_dir to noexp
Rem    msakayed    10/09/06 - add sys.ku_utluse for feature tracking
Rem    mhho        09/08/06 - add XS$NULL to ku_noexp_tab
Rem    rburns      08/13/06 - add drop_queue
Rem    ataracha    07/13/06 - add user anonymous to ku_noexp_tab
Rem    dkapoor     06/19/06 - don't export ORACLE_OCM 
Rem    xbarr       06/06/06 - remove DMSYS entries  
Rem    dgagne      03/23/06 - add global temporary master tables
Rem    wfisher     09/01/05 - Lrg 1908671: Factoring for Standard Edition 
Rem    wfisher     08/18/05 - Adding new Data Pump roles 
Rem    lbarton     05/03/05 - Bug 4338735: don't export WMSYS 
Rem    emagrath    02/07/05 - Remove unused oper. from DATAPUMP_JOBS view 
Rem    lbarton     01/07/05 - Bug 4109444: exclude schemas 
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem

-------------------------------------------------------------------------
Rem Set up application roles to to be enabled for privileged users
-------------------------------------------------------------------------

CREATE ROLE datapump_exp_full_database;
CREATE ROLE datapump_imp_full_database;

GRANT exp_full_database          TO datapump_exp_full_database;
Rem Following grant needed for fgac test in dpx3f2
GRANT create table               TO datapump_exp_full_database;
GRANT create session             TO datapump_exp_full_database;

GRANT alter resource cost        TO datapump_imp_full_database;
GRANT alter user                 TO datapump_imp_full_database;
GRANT audit any                  TO datapump_imp_full_database;
GRANT audit system               TO datapump_imp_full_database;
GRANT create session             TO datapump_imp_full_database;
GRANT alter profile              TO datapump_imp_full_database;
GRANT create profile             TO datapump_imp_full_database;
GRANT delete any table           TO datapump_imp_full_database;
GRANT execute any operator       TO datapump_imp_full_database;
GRANT grant any privilege        TO datapump_imp_full_database;
GRANT grant any object privilege TO datapump_imp_full_database;
GRANT grant any role             TO datapump_imp_full_database;
GRANT imp_full_database          TO datapump_imp_full_database;
GRANT select any table           TO datapump_imp_full_database;
GRANT alter database             TO datapump_imp_full_database;

Rem The following grant is needed to make loopback network jobs work right
Rem Since the application role makes it disappear otherwise.

GRANT exp_full_database          TO datapump_imp_full_database;

GRANT export full database TO dba;
GRANT import full database TO dba;
GRANT datapump_exp_full_database TO dba;
GRANT datapump_imp_full_database TO dba;

Rem DataPump roles are not documented so also grant them to old exp/imp roles

Rem Following grant needed for fgac test in dpx3f2
GRANT create table               TO exp_full_database;
GRANT create session             TO exp_full_database;

GRANT alter resource cost        TO imp_full_database;
GRANT alter user                 TO imp_full_database;
GRANT audit any                  TO imp_full_database;
GRANT audit system               TO imp_full_database;
GRANT create session             TO imp_full_database;
GRANT alter profile              TO imp_full_database;
GRANT create profile             TO imp_full_database;
GRANT delete any table           TO imp_full_database;
GRANT execute any operator       TO imp_full_database;
GRANT grant any privilege        TO imp_full_database;
GRANT grant any object privilege TO imp_full_database;
GRANT grant any role             TO imp_full_database;
GRANT select any table           TO imp_full_database;
GRANT alter database             TO imp_full_database;



-------------------------------------------------------------------------
--     Public view defs (DBA_/USER_*) go here.
-------------------------------------------------------------------------

--  Fixed (virtual) View Declarations, Synonyms, and Grants
CREATE OR REPLACE VIEW SYS.V_$DATAPUMP_JOB AS
  SELECT * FROM SYS.V$DATAPUMP_JOB;
CREATE OR REPLACE PUBLIC SYNONYM V$DATAPUMP_JOB FOR SYS.V_$DATAPUMP_JOB;
GRANT SELECT ON SYS.V_$DATAPUMP_JOB TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.V_$DATAPUMP_SESSION AS
  SELECT * FROM SYS.V$DATAPUMP_SESSION;
CREATE OR REPLACE PUBLIC SYNONYM V$DATAPUMP_SESSION FOR
  SYS.V_$DATAPUMP_SESSION;
GRANT SELECT ON SYS.V_$DATAPUMP_SESSION TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.GV_$DATAPUMP_JOB AS
  SELECT * FROM SYS.GV$DATAPUMP_JOB;
CREATE OR REPLACE PUBLIC SYNONYM GV$DATAPUMP_JOB FOR SYS.GV_$DATAPUMP_JOB;
GRANT SELECT ON SYS.GV_$DATAPUMP_JOB TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.GV_$DATAPUMP_SESSION AS
  SELECT * FROM SYS.GV$DATAPUMP_SESSION;
CREATE OR REPLACE PUBLIC SYNONYM GV$DATAPUMP_SESSION FOR
  SYS.GV_$DATAPUMP_SESSION;
GRANT SELECT ON SYS.GV_$DATAPUMP_SESSION TO SELECT_CATALOG_ROLE;

--  Client Views defined on Fixed Views
--
--  FAMILY "DATAPUMP_JOBS"
--  Datapump Jobs.
--  This family has no ALL member.
--
CREATE OR REPLACE VIEW SYS.user_datapump_jobs (
                job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.job_name, j.operation, j.job_mode, j.state, j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
        WHERE   j.msg_ctrl_queue IS NOT NULL AND 
                j.owner_name = SYS_CONTEXT('USERENV', 'CURRENT_USER')
      UNION ALL                               /* Not Running - Master Tables */
        SELECT o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','IMPORT','SQL_FILE') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              BITAND(o.flags, 128) <> 128 AND
              u.user# = o.owner# AND
              u.name = SYS_CONTEXT('USERENV', 'CURRENT_USER') AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.user_datapump_jobs IS
'Datapump jobs for current user'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.degree IS
'Number of worker processes performing the operation'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM user_datapump_jobs FOR
  SYS.user_datapump_jobs
/
GRANT SELECT ON SYS.user_datapump_jobs TO PUBLIC WITH GRANT OPTION
/
CREATE OR REPLACE VIEW SYS.dba_datapump_jobs (
                owner_name, job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.owner_name, j.job_name, j.operation, j.job_mode, j.state,
                j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
        WHERE   j.msg_ctrl_queue IS NOT NULL
      UNION ALL                               /* Not Running - Master Tables */
        SELECT u.name, o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','ESTIMATE','IMPORT','SQL_FILE','NETWORK') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              BITAND(o.flags, 128) <> 128 AND
              u.user# = o.owner# AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.dba_datapump_jobs IS
'Datapump jobs'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.degree IS
'Number of worker proceses performing the operation'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_datapump_jobs FOR
  SYS.dba_datapump_jobs
/
GRANT SELECT ON SYS.dba_datapump_jobs TO SELECT_CATALOG_ROLE
/

--  FAMILY "DATAPUMP_SESSIONS"
--  Datapump Sessions.
--  This family has no ALL or USER member.
--
CREATE OR REPLACE VIEW SYS.dba_datapump_sessions (
                owner_name, job_name, inst_id, saddr, session_type) AS
        SELECT  j.owner_name, j.job_name, s.inst_id, s.saddr, s.type
        FROM    SYS.GV$DATAPUMP_JOB j, SYS.GV$DATAPUMP_SESSION s
        WHERE   j.job_id = s.job_id
/
COMMENT ON TABLE SYS.dba_datapump_sessions IS
'Datapump sessions attached to a job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.inst_id IS
'Instance ID'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.saddr IS
'Address of session attached to job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.session_type IS
'Datapump session type'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_datapump_sessions FOR
  SYS.dba_datapump_sessions
/
GRANT SELECT ON SYS.dba_datapump_sessions TO SELECT_CATALOG_ROLE
/

--  FAMILY "DATAPUMP_DIRECTORY_OBJECTS"
--  expdp and impdp directory object views.
--  This family has no ALL or USER member.
--

--
-- Note:  This view is a duplicate (at the time) of loader_dir_objs
--        in catldr.sql
-- The view returns READ/WRITE permission on an Oracle directory
-- object for the querying user.
--  NOTE:
--  First case:
--    SYS owns all directory objects, hence has read/write privilege
--    on all directory objects.  Users with CREATE/DROP ANY DIRECTORY
--    privilege (-177, -178, respectively) have read/write privilege
--    on all directory objects.
--  Second case:
--    Usage of "group by" to group all directory objects
--    for which the requesting user has a read(17)/write(18) privilege
--    grant.  The sum(decode) results in either non-zero, or zero if
--    the requesting user has a corresponding grant.
--
--  Note also that (select kzsrorol from x$kzsro) returns all roles
--  for which the requesting user has grants for (including their
--  own UID.
--
CREATE OR REPLACE VIEW SYS.DATAPUMP_DIR_OBJS (name, path, read, write) as
   SELECT o.name, d.os_path, 'TRUE', 'TRUE'
   FROM SYS.OBJ$ o, SYS.DIR$ d
     WHERE o.obj#=d.obj#
       AND (o.owner#=UID
        OR EXISTS (SELECT NULL FROM v$enabledprivs WHERE priv_number IN (-177,-178)))
    UNION ALL
      SELECT o.name, d.os_path, 
         DECODE(SUM(DECODE(privilege#,17,1,0)),0, 'FALSE','TRUE'),
         DECODE(SUM(DECODE(privilege#,18,1,0)),0, 'FALSE','TRUE')
      FROM SYS.OBJ$ o, SYS.DIR$ d, SYS.OBJAUTH$ oa
        WHERE o.obj#=d.obj#
        AND oa.obj#=o.obj#
        AND oa.privilege# IN (17,18)
        AND oa.grantee# IN (SELECT kzsrorol FROM x$kzsro)
        AND NOT (o.owner#=UID
           OR EXISTS (SELECT NULL FROM v$enabledprivs WHERE priv_number IN (-177,-178)))
   GROUP BY o.name, d.os_path
/


COMMENT ON TABLE SYS.datapump_dir_objs IS
'State of Schema Directory Objects'
/


COMMENT ON COLUMN SYS.datapump_dir_objs.name IS
'Directory Object Name'
/
COMMENT ON COLUMN SYS.datapump_dir_objs.path IS
'Directory object path specification'
/
COMMENT ON COLUMN SYS.datapump_dir_objs.read IS
'Read Access enabled'
/
COMMENT ON COLUMN SYS.datapump_dir_objs.write IS
'Write access enabled'
/
CREATE OR REPLACE PUBLIC SYNONYM datapump_dir_objs FOR
  SYS.datapump_dir_objs
/
GRANT SELECT ON SYS.datapump_dir_objs TO PUBLIC
/

-- A table to hold objects that are not to be exported in a full export.
-- This and rows from sys.noexp$ form the complete exclusion set (which is
-- built at Data Pump run time into the global temp. table below). We have
-- to leave noexp$ as-is since external products use it.
-- IMPORTANT: Some views in catmeta.sql do not use this table but instead
-- have their own hard-coded list of schemas to exclude.  When a new
-- schema is added to the exclude list, catmeta.sql must also be updated.
-- Also datapump/ddl/prvtmetd.sql may need to be updated for similar reasons.

-- Tables to support EXCLUDE_NOEXP filter... view is dropped in catnodp.sql
DROP TABLE sys.ku_noexp_tab;
DROP TABLE sys.ku$noexp_tab;

CREATE TABLE sys.ku_noexp_tab (
        obj_type        VARCHAR2(30),
        schema          VARCHAR2(30),
        name            VARCHAR2(30)
)
/

INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE', NULL, 'SYSTEM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'OLAPSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'CONNECT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'RESOURCE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'PUBLIC')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, '_NEXT_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'DATAPUMP_EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'DATAPUMP_IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'LOGSTDBY_ADMINISTRATOR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'OLAP_DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'OLAP_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'OLAP_XS_ADMIN')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DATAPUMP_EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DATAPUMP_IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'LOGSTDBY_ADMINISTRATOR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'CONNECT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'RESOURCE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, '_NEXT_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DATAPUMP_EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DATAPUMP_IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'LOGSTDBY_ADMINISTRATOR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'SYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'ORDSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'EXFSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'MDSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DMSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'CTXSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'ORDPLUGINS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'LBACSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'XDB', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'SI_INFORMTN_SCHEMA', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DIP', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DBSNMP', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DVSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DVF', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'WMSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'ORACLE_OCM', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'XS$NULL', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'TSMSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'APPQOSSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'MGDSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ANONYMOUS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DVSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DVF')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ORACLE_OCM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'XS$NULL')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'TSMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'APPQOSSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'MGDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLLBACK_SEGMENT', NULL, 'SYSTEM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'IDR_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'ORACLE_OCM_CONFIG_DIR')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DIRECTORY', NULL, 'ORACLE_OCM_CONFIG_DIR2')
/
--
-- Create a view that incorporates everything in the ku$_noexp_tab above and
-- the original catexp sys.noexp$ table. This view is used to populate the
-- global temporary table defined below at runtime. The view *usually* isn't
-- used directly because the union below slows metadata extraction by 10%.
-- It will be used in network mode because the metadata API running on the
-- remote instance can't see our table.
--
CREATE OR REPLACE VIEW sys.ku_noexp_view (
                obj_type, schema, name) AS
        SELECT  decode(n.obj_type, 2, 'TABLE', 6, 'SEQUENCE', 'ERROR'),
                n.owner, n.name
        FROM    sys.noexp$ n
      UNION
        SELECT  k.obj_type, k.schema, k.name
        FROM    sys.ku_noexp_tab k
/

GRANT SELECT ON sys.ku_noexp_view TO PUBLIC
/
--
-- The global temp. table used for all local export operations. Each
-- worker doing metadata loads their own private copy which doesn't have to be
-- cleaned up at session end. prvtbpw has a dependency on this.
--
CREATE GLOBAL TEMPORARY TABLE sys.ku$noexp_tab ON COMMIT PRESERVE ROWS
  AS SELECT * FROM sys.ku_noexp_view
/
GRANT SELECT ON sys.ku$noexp_tab TO PUBLIC
/
GRANT INSERT ON sys.ku$noexp_tab TO PUBLIC
/

-- Table used for database utility feature tracking (SQL*Loader, impdp, expdp,
-- metadata API).
DROP TABLE sys.ku_utluse
/
CREATE TABLE sys.ku_utluse 
(UTLNAME     VARCHAR2(50),
 USECNT      NUMBER,
 ENCRYPTCNT  NUMBER,
 COMPRESSCNT NUMBER,
 LAST_USED TIMESTAMP)
/

INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Datapump (Export)', 0, 0, 0, NULL)
/
COMMIT;
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Datapump (Import)', 0, 0, 0, NULL)
/
COMMIT;
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility SQL Loader (Direct Path Load)', 0, 0, 0, NULL)
/
COMMIT;
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility Metadata API', 0, 0, 0, NULL)
/
COMMIT;
INSERT INTO sys.ku_utluse VALUES
('Oracle Utility External Table', 0, 0, 0, NULL)
/
COMMIT;

-- Table to contain filter list elements (e.g., TABLE list) on source
-- database during a network job.
--
-- NOTE:  This is used for 11.1 only.  If adding columns, add them to
--        ku$_list_filter_temp_2 below.
--
DROP TABLE sys.ku$_list_filter_temp;

CREATE GLOBAL TEMPORARY TABLE sys.ku$_list_filter_temp (
        process_order           NUMBER,
        duplicate               NUMBER,
        object_name             VARCHAR2(500),
        base_process_order      NUMBER,
        parent_process_order    NUMBER )
ON COMMIT PRESERVE ROWS
/
GRANT SELECT ON sys.ku$_list_filter_temp TO PUBLIC
/
GRANT INSERT ON sys.ku$_list_filter_temp TO PUBLIC
/
GRANT DELETE ON sys.ku$_list_filter_temp TO PUBLIC
/

-- Table to contain filter list elements (e.g., TABLE list) on source
-- database during a network job.
--
-- NOTE:  This is used for 11.2 and later.  If adding columns, add them to
--        this table.
--
DROP TABLE sys.ku$_list_filter_temp_2;

CREATE GLOBAL TEMPORARY TABLE sys.ku$_list_filter_temp_2 (
        process_order           NUMBER,
        duplicate               NUMBER,
        object_schema           VARCHAR2(60),
        object_name             VARCHAR2(500),
        base_process_order      NUMBER,
        parent_process_order    NUMBER )
ON COMMIT PRESERVE ROWS
/
GRANT SELECT ON sys.ku$_list_filter_temp_2 TO PUBLIC
/
GRANT INSERT ON sys.ku$_list_filter_temp_2 TO PUBLIC
/
GRANT DELETE ON sys.ku$_list_filter_temp_2 TO PUBLIC
/

-------------------------------------------------------------------------
---     Public and private package and type bodies go here towards the
---     bottom as they have the most dependencies
-------------------------------------------------------------------------


