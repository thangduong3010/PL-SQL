Rem
Rem NAME
Rem    CATSNMP.SQL
Rem  FUNCTION
Rem    Creates an SNMPAgent role to access the v$ tables
Rem  NOTES
Rem  MODIFIED
Rem     mappusam   01/24/13 - Backport rkunnamp_bug-9346110 from
Rem     ychan      06/17/09 - Fix bug 8607966
Rem     dsemler    01/14/08 - Add QOS user creation
Rem     amahalin   06/21/07 - to grant SELECT_CATALOG_ROLE to OEM_MONITOR
Rem     jsoule     05/07/07 - grant dbms_management_packs access to dbsnmp
Rem     ychan      02/13/07 - Add db_feature table and procedure
Rem     jsoule     07/20/06 - restore bsln schema creation 
Rem     jsoule     07/13/06 - remove bsln dependency on EMDW
Rem     lburgess   03/27/06 - user lowercase for DBSNMP password 
Rem     nachen     02/02/05 - add OEM_ADVISOR role 
Rem     ychan      11/11/04 - Fix bug 3926476 
Rem     zsyed      10/29/04 - Removing addition of dbsnmp to SYS_USER group 
Rem     jsoule     08/06/04 - add dbsnmp baseline schema objects 
Rem     shigupta   07/16/04 - add dbsnmp to sys_group consumer group 
Rem     hxlin      06/28/04 - Put SQL Response back 
Rem     hxlin      06/18/04 - Temporarily remove response.plb 
Rem     shigupta   06/07/03 - cleanup
Rem     ychan      11/05/03 - Fix bug 3234502 
Rem     jochen     10/02/03 - Add ANALYZE ANY DICTIONARY to OEM_MONITOR 
Rem     vchao      07/09/03 - Fix bug 3027355. Modify alert_que privileges
Rem     ychan      06/27/03 - Add aq priv
Rem     ychan      06/26/03 - Add aq priv
Rem     lhan       06/27/03 - change key of gtt
Rem     lhan       06/13/03 - remove hard tab
Rem     lhan       06/06/03 - Add GTTs definition
Rem     ychan      05/14/03 - Remove reuse
Rem     ychan      05/11/03 - Grant dbms_lock
Rem     ychan      04/28/03 - Add response sql
Rem     ychan      03/26/03 - Fix connect dbsnmp
Rem     ychan      03/24/03 - Fix bug 2657279
Rem     jaysmith   08/21/02 - remove create user error-handling
Rem     jaysmith   08/18/02 - suppress error from create user
Rem     jaysmith   08/16/02 - do not recreate DBSNMP user each time run
Rem     xxu        02/01/02 - add function OemGetNextExtend
Rem     glavash    01/03/02 - remove superfluos privs
Rem     rburns     10/28/01 - wrap drop role statement
Rem     gviswana   05/24/01 - CREATE OR REPLACE SYNONYM
Rem	jaysmith   04/11/01 - restore views, oemagent roles
Rem	jaysmith   03/08/01 - pull back grants for dbsnmp user
Rem	glavash    02/16/01 - add select access to sys.obj$ user and ts
Rem	glavash    10/23/00 - add statspack views
Rem     dholail    04/12/99 - Adding Events role OEM_MONITOR
Rem     cluo       07/15/96 -
Rem     dnakos     removed creation of backup script tables
Rem     dnakos     removed creation of obsolete history tables
Rem     dnakos     removed references to obsolete DBA_LOCKS
Rem
Rem  OWNER
Rem    ebosco
Rem

BEGIN
  EXECUTE IMMEDIATE 'drop role SNMPAGENT';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1919 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

REM
REM -- OEM_ADVISOR role is needed so that users with this
REM -- role could manage advisor tasks.
REM
create role OEM_ADVISOR;
    REM -- Privileges to run Advisor Tasks as Scheduler Jobs
    grant ADVISOR to OEM_ADVISOR;
    grant CREATE JOB to OEM_ADVISOR;
    REM -- Privileges to run SQL Tuning Advisor Tasks
    grant ADMINISTER SQL TUNING SET to OEM_ADVISOR;

REM
REM -- OEM_MONTOR role is needed so that users of EM Diagnostics Pack can grant this
REM -- role to another user who they want to use to monitor database using EM Agent.
REM -- DBSNMP is the out-of-box default user used by EM Agent to monitor the database.
REM
create role OEM_MONITOR;

    REM -- Ability to create a session and read dictionary views
    grant CREATE SESSION to OEM_MONITOR;
    grant SELECT ANY DICTIONARY to OEM_MONITOR;

    REM -- Privileges to enable/disable SQL Tracing and Statistics Aggregation
    grant execute on SYS.DBMS_SYSTEM to OEM_MONITOR;
    grant execute on SYS.DBMS_MONITOR to OEM_MONITOR;

    REM -- Privileges to run AWR report 
    grant execute on dbms_workload_repository to OEM_MONITOR;

    REM -- Privileges to run Advisor Tasks as Scheduler Jobs
    grant ADVISOR to OEM_MONITOR;
    grant CREATE JOB to OEM_MONITOR;

    REM -- HA related package
    grant execute on SYS.DBMS_DRS to OEM_MONITOR;

    REM -- Privileges needed to use DBMS_SPACE package. This package
    REM -- is used by Space metrics
    REM
    grant analyze any to OEM_MONITOR;
    grant analyze any dictionary to OEM_MONITOR;

    REM -- Privileges for alerts queue
    grant EXECUTE on DBMS_AQADM to OEM_MONITOR;
    grant EXECUTE on DBMS_AQ to OEM_MONITOR;
    grant EXECUTE on DBMS_SERVER_ALERT to OEM_MONITOR;
    
    REM -- Privileges for OLS Data Dictionary Views
    grant SELECT_CATALOG_ROLE to OEM_MONITOR;	
	
    begin
      dbms_aqadm.grant_system_privilege('manage_any', 'OEM_MONITOR', false);
      dbms_aqadm.grant_queue_privilege('dequeue', 'alert_que', 'OEM_MONITOR', false);
    end;
    /

create user DBSNMP identified by dbsnmp DEFAULT TABLESPACE SYSAUX PASSWORD EXPIRE ACCOUNT LOCK;

grant select any dictionary to DBSNMP;
grant OEM_MONITOR to DBSNMP;

REM - These privileges are needed for SQL Response metric. These need to be
REM - granted only to DBSNMP since DBSNMP schema owns these objects.
REM - The response.plb file (see below) creates the tables and procedures
REM - under DBSNMP. Such creation will fail without these privileges.
REM
grant create table to DBSNMP;
grant create procedure to DBSNMP;
grant unlimited tablespace to DBSNMP;

REM - DBSNMP user should get preferential resource allocation on a system 
REM - experiencing contention. This is to ensure that DBA is able to use 
REM - EM to diagnose the problem. If resource manager is enabled then sys_group
REM - gets a high allocation since this is what sys and system belong to.
REM - Therefore, add dbsnmp to sys_group.
  
REM Grant these directly to the owner of mgmt_bsln_internal.
GRANT EXECUTE ON DBMS_SERVER_ALERT TO DBSNMP;
GRANT EXECUTE ON DBMS_MANAGEMENT_PACKS TO DBSNMP;

ALTER SESSION SET CURRENT_SCHEMA = DBSNMP;

REM Load the SQL Response Metric
@@response.plb

    REM -- Privilege to execute MGMT_RESPONSE package (for SQL Response Metric)
    grant EXECUTE on dbsnmp.mgmt_response to OEM_MONITOR;

REM -- Privileges to query SQL Response tables
grant select on dbsnmp.mgmt_baseline to OEM_MONITOR; 
grant select on dbsnmp.mgmt_baseline_sql to OEM_MONITOR;
grant select on dbsnmp.mgmt_latest to OEM_MONITOR;
grant select on dbsnmp.mgmt_latest_sql to OEM_MONITOR;
grant select on dbsnmp.mgmt_history to OEM_MONITOR;
grant select on dbsnmp.mgmt_history_sql to OEM_MONITOR;

REM Create the BSLN schema objects
@@catbsln

REM Create GTTs for Tablespaces Full metric under DBSNMP schema
create global temporary table mgmt_db_file_gtt (
        tablespace_name varchar2(30),
        meg number,
        max_meg number,
        file_name varchar2(513),
        file_id number,
        ts# number,
        blocksize number,
        flag number,
        constraint mgmt_db_file_gtt_pk primary key (tablespace_name,file_id)
)
on commit delete rows;

create global temporary table mgmt_db_size_gtt (
        tablespace_name varchar2(30),
        sz number,
        constraint mgmt_db_size_gtt_pk primary key (tablespace_name)
)
on commit delete rows;

REM ******************************
REM Start: Tracking em db feature
REM ******************************
CREATE TABLE mgmt_db_feature_log (
   source varchar2(30) NOT NULL CONSTRAINT mgmt_db_feature_log_pk PRIMARY KEY,
   last_update_date timestamp with time zone);

CREATE OR REPLACE PROCEDURE mgmt_update_db_feature_log(src IN VARCHAR2)
AS 
    l_last_update_date mgmt_db_feature_log.last_update_date%TYPE;
    current_date mgmt_db_feature_log.last_update_date%TYPE;
    diff interval day(9) to second(9);
    diff_min NUMBER;
  BEGIN
    current_date := SYSTIMESTAMP;
    SELECT last_update_date
      INTO l_last_update_date
        FROM mgmt_db_feature_log
        WHERE source = src;
    diff := current_date - l_last_update_date;
    diff_min := EXTRACT(DAY FROM diff)*24*60+EXTRACT(HOUR FROM diff)*60+EXTRACT(MINUTE FROM diff);
    -- 2 hours 2x60=120
    IF (diff_min > 120) THEN 
    	UPDATE mgmt_db_feature_log set last_update_date = current_date WHERE source = src;   
	commit;
    END IF;    
  EXCEPTION
    when NO_DATA_FOUND then     
      BEGIN
        INSERT INTO mgmt_db_feature_log VALUES (src, systimestamp);
	commit;
      END;        
  END;
/

GRANT EXECUTE ON  dbsnmp.mgmt_update_db_feature_log TO OEM_MONITOR;

REM ******************************
REM END: Tracking em db feature
REM ******************************


ALTER SESSION SET CURRENT_SCHEMA = SYS;

REM This must be called after the DBSNMP user is known to be created as
REM   it grants permissions to DBSNMP
@@catqos
