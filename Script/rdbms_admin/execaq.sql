Rem
Rem $Header: rdbms/admin/execaq.sql /main/11 2009/05/14 00:42:53 shbose Exp $
Rem
Rem execaq.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      execaq.sql - Execute AQ packages to create required queues
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shbose      05/05/09 - Bug 7530052: Delete entries for 
Rem                           AQ$_<queue table>_F from ku_noexp_tab table
Rem    gagarg      08/28/08 - Create AQ_SRVNTFN_TABLE dynamically in emon
Rem                           coordinator
Rem    jhan        05/21/07 - add trace_level and dequeue_timeout parameters
Rem    jawilson    04/03/07 - add propagation job class
Rem    jawilson    11/10/06 - event-based job changes to propagation program
Rem    jawilson    09/28/06 - remove instance-bound job classes
Rem    jhan        08/09/06 - Add exception handle for Queue Creation
Rem    jawilson    06/02/06 - propagation using new dbms scheduler
Rem    absaxena    06/02/06 - grant select on DBA_SUBSCR_REGISTRATIONS 
Rem    rburns      05/19/06 - execute queue packages 
Rem    rburns      05/19/06 - Created
Rem

-- This synonym becomes invalid for some reason, so recreate here
CREATE OR REPLACE PUBLIC SYNONYM dbms_aqjms_internal 
FOR sys.dbms_aqjms_internal;

--
-- Create and grant privileges to all the AQ system-defined roles
-- Notes:  The upgrade script should have revoked all privileges from
--         the role and have the privileges granted here.
--

BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'MANAGE_ANY', grantee => 'AQ_ADMINISTRATOR_ROLE', admin_option => TRUE);
END;
/
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'ENQUEUE_ANY', grantee => 'AQ_ADMINISTRATOR_ROLE', admin_option => TRUE);
END;
/
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'DEQUEUE_ANY',grantee => 'AQ_ADMINISTRATOR_ROLE', admin_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_EVALUATION_CONTEXT_OBJ, grantee => 'AQ_ADMINISTRATOR_ROLE', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_RULE_SET_OBJ, grantee => 'AQ_ADMINISTRATOR_ROLE', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_RULE_OBJ, grantee => 'AQ_ADMINISTRATOR_ROLE', grant_option => TRUE);
END;
/
GRANT SELECT ON DBA_QUEUE_TABLES TO aq_administrator_role
/
GRANT SELECT ON DBA_QUEUES TO aq_administrator_role
/
GRANT SELECT ON DBA_QUEUE_SCHEDULES TO aq_administrator_role
/
GRANT SELECT ON sys.v_$aq TO aq_administrator_role
/
GRANT SELECT ON sys.gv_$aq TO aq_administrator_role
/
GRANT SELECT ON sys.aq$_propagation_status TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aqadm TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aq TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aq_import_internal TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_rule_eximp TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aqin TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aqjms_internal TO aq_administrator_role
/
GRANT SELECT ON SYS.AQ$Internet_Users TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_transform TO aq_administrator_role
/
GRANT EXECUTE ON sys.dbms_aqelm TO aq_administrator_role
/
GRANT select ON DBA_AQ_AGENTS to aq_administrator_role
/
GRANT select ON DBA_AQ_AGENT_PRIVS to aq_administrator_role
/
GRANT select ON DBA_QUEUE_SUBSCRIBERS TO aq_administrator_role
/
GRANT select ON DBA_SUBSCR_REGISTRATIONS TO aq_administrator_role
/

GRANT EXECUTE ON sys.dbms_aq TO aq_user_role
/
GRANT EXECUTE ON sys.dbms_aqin TO aq_user_role
/
GRANT EXECUTE ON sys.dbms_aqjms_internal TO aq_user_role
/
GRANT EXECUTE ON sys.dbms_transform TO aq_user_role
/

--
-- Create the global AQ user role 
--
DECLARE
ent_sec_enabled VARCHAR2(64);
BEGIN
  SELECT value INTO ent_sec_enabled FROM v$option
         WHERE lower(parameter) LIKE '%enterprise user security%';
  IF (instr(lower(ent_sec_enabled), 'true') > 0) THEN 
    execute immediate 'CREATE ROLE global_aq_user_role identified globally';
  END IF;
END;
/

GRANT EXECUTE ON sys.dbms_aqadm TO system WITH GRANT OPTION
/
GRANT EXECUTE ON sys.dbms_aq TO system WITH GRANT OPTION
/
GRANT EXECUTE ON sys.dbms_aqelm TO system WITH GRANT OPTION
/

--
-- Grant dbms_aq_import_internal
--  
GRANT EXECUTE ON sys.dbms_aq_import_internal TO SYSTEM WITH GRANT OPTION
/
GRANT EXECUTE ON sys.dbms_aq_import_internal TO imp_full_database
/
GRANT EXECUTE ON sys.dbms_aq_import_internal TO exp_full_database
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_aqadm TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_aq_import_internal TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_aq TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_rule_eximp TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_aqin TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_aqjms_internal TO execute_catalog_role
/
GRANT EXECUTE ON sys.dbms_aqelm TO execute_catalog_role
/

-- permissions for types created for pl/sql notification
GRANT EXECUTE ON msg_prop_t TO PUBLIC
/

GRANT EXECUTE ON aq$_descriptor TO PUBLIC
/

GRANT EXECUTE ON aq$_ntfn_descriptor TO PUBLIC
/

GRANT EXECUTE ON aq$_reg_info TO PUBLIC
/

GRANT EXECUTE ON aq$_reg_info_list TO PUBLIC
/

GRANT EXECUTE ON aq$_post_info TO PUBLIC
/

GRANT EXECUTE ON aq$_post_info_list TO PUBLIC
/

GRANT EXECUTE ON aq$_ntfn_msgid_array TO PUBLIC
/

GRANT EXECUTE ON dbms_aq_inv TO PUBLIC
/
--
-- Grant 'MANAGE_ANY' to imp_full_database
-- Note: 'select any table' privilege is needed for full database export
--       'manage any queue' privilege is needed for full database import
--
GRANT EXECUTE ON sys.dbms_aqadm TO imp_full_database
/
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'MANAGE_ANY', grantee => 'IMP_FULL_DATABASE', admin_option => FALSE);
END;
/

-- Grant Enqueue, Dequeue and Manage ANY privilege to SYS
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'MANAGE_ANY', grantee => 'SYS', admin_option => TRUE);
END;
/
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'ENQUEUE_ANY', grantee => 'SYS', admin_option => TRUE);
END;
/
BEGIN
dbms_aqadm.grant_system_privilege(privilege => 'DEQUEUE_ANY',grantee => 'SYS', admin_option => TRUE);
END;
/

-- Grant rule privileges to SYS
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_ANY_EVALUATION_CONTEXT, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.ALTER_ANY_EVALUATION_CONTEXT, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.DROP_ANY_EVALUATION_CONTEXT, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.EXECUTE_ANY_EVALUATION_CONTEXT, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_ANY_RULE_SET, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.ALTER_ANY_RULE_SET, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.DROP_ANY_RULE_SET, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.EXECUTE_ANY_RULE_SET, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_ANY_RULE, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.ALTER_ANY_RULE, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.DROP_ANY_RULE, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.EXECUTE_ANY_RULE, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_EVALUATION_CONTEXT_OBJ, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_RULE_SET_OBJ, grantee => 'SYS', grant_option => TRUE);
END;
/
BEGIN
  dbms_rule_adm.grant_system_privilege(privilege => dbms_rule_adm.CREATE_RULE_OBJ, grantee => 'SYS', grant_option => TRUE);
END;
/

-- queue table for storing events incase ksr channel memory consumption
-- above high watermark
-- (Design Specification for Publish/Subscribe notification framework
-- enhancement, RDBMS, Version 8.2)

-- create aq_event_table queue table
BEGIN
dbms_aqadm.create_queue_table(queue_table => 'SYS.AQ_EVENT_TABLE', queue_payload_type =>'SYS.AQ$_EVENT_MESSAGE', sort_list =>'ENQ_TIME', comment => 'CREATING AQ_EVENT_TABLE QUEUE TABLE', compatible=>'8.0.0');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-- create the aq_event_table_q queue
BEGIN
dbms_aqadm.create_queue(queue_name => 'AQ_EVENT_TABLE_Q', queue_table => 'SYS.AQ_EVENT_TABLE', comment => 'CREATING AQ_EVENT_TABLE_Q QUEUE');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24006 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-- start the queue aq_event_table_q
BEGIN
dbms_aqadm.start_queue(queue_name => 'SYS.AQ_EVENT_TABLE_Q');
END;
/

-- Create aq$_<QT>_P and aq$_<QT>_D for buffered queue tables
BEGIN
   DBMS_AQADM_SYS.create_spilled_tables_iots;
END;
/

-- Create the propagation notification table and queue
BEGIN
  BEGIN
  dbms_aqadm.create_queue_table(
    QUEUE_TABLE => 'SYS.AQ_PROP_TABLE',
    QUEUE_PAYLOAD_TYPE => 'SYS.AQ$_NOTIFY_MSG',
    MULTIPLE_CONSUMERS => TRUE,
    COMMENT => 'Queue Table for Notification in AQ Prop. Scheduling');
  dbms_aqadm_sys.create_queue(
    QUEUE_NAME => 'SYS.AQ_PROP_NOTIFY',
    QUEUE_TABLE => 'SYS.AQ_PROP_TABLE',
    COMMENT => 'Queue for Notifying events in AQ Prop. Scheduling');
  dbms_aqadm.start_queue(
    QUEUE_NAME => 'SYS.AQ_PROP_NOTIFY',
    ENQUEUE => TRUE, DEQUEUE => TRUE);
  EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;
  END;
	
END;
/

-- Create AQ Propagation program
BEGIN
  BEGIN
  DBMS_SCHEDULER.CREATE_PROGRAM(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    program_type => 'STORED_PROCEDURE',
    program_action => 'SYS.DBMS_AQADM_SYS.aq$_propagation_procedure',
    number_of_arguments => 10,
    enabled => FALSE,
    comments => 'AQ propagation program');
  EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -27477 THEN NULL;
      ELSE RAISE;
      END IF;
  END;

  DBMS_SCHEDULER.DEFINE_METADATA_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    metadata_attribute => 'job_owner',
    argument_position => 1);
  DBMS_SCHEDULER.DEFINE_METADATA_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    metadata_attribute => 'job_name',
    argument_position => 2);
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 3,
    argument_name => 'source_queue',
    argument_type => 'VARCHAR2');
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 4,
    argument_name => 'destination',
    argument_type => 'VARCHAR2');
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 5,
    argument_name => 'duration',
    argument_type => 'NUMBER');
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 6,
    argument_name => 'latency',
    argument_type => 'NUMBER');
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 7,
    argument_name => 'http_batch_size',
    argument_type => 'NUMBER');
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 8,
    argument_name => 'idle_timeout',
    argument_type => 'NUMBER',
    default_value => dbms_prvtaqip.DEFAULT_IDLE_TIMEOUT);
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 9,
    argument_name => 'dequeue_timeout',
    argument_type => 'NUMBER',
    default_value => dbms_prvtaqip.DEFAULT_DEQUEUE_TIMEOUT);
  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    argument_position => 10,
    argument_name => 'trace_level',
    argument_type => 'NUMBER',
    default_value => dbms_prvtaqip.DEFAULT_TRACE_LEVEL);
  DBMS_SCHEDULER.ENABLE('AQ$_PROPAGATION_PROGRAM');
END;
/

-- Create job class for propagation jobs
BEGIN
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB_CLASS(
      job_class_name => 'AQ$_PROPAGATION_JOB_CLASS',
      comments => 'Default job class for AQ propagation jobs');
  EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -27477 THEN NULL;
      ELSE RAISE;
      END IF;
  END;
END;
/
INSERT INTO noexp$(owner, name, obj_type) 
VALUES ('SYS', 'AQ$_PROPAGATION_JOB_CLASS', 68)
/

-- Bug 7530052: Insert entries for AQ$_<queue table>_F from
-- ku_noexp_tab table. This is valid only during downgrade to this release
-- from a release  greated than 11.2
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name
  FROM system.aq$_queue_tables qt;
  ins_stmt    VARCHAR2(500);
  BASE_TABLE_DOES_NOT_EXIST exception;
  PRAGMA EXCEPTION_INIT(BASE_TABLE_DOES_NOT_EXIST, -942);
BEGIN
  FOR qt_rec IN qt_cur LOOP

    BEGIN
      -- Add _F view into ku_noexp_tab table only if entry not already there
      ins_stmt := 'INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name )' ||
                   ' SELECT ''VIEW'', :1, :2 FROM dual ' ||
                ' WHERE NOT EXISTS ' ||
                '   (SELECT 1 FROM sys.ku_noexp_tab ' ||
                ' WHERE schema = :3 AND name = :4 AND obj_type = ''VIEW'')';

      EXECUTE IMMEDIATE ins_stmt USING
       qt_rec.schema, 'AQ$_'||qt_rec.name||'_F', qt_rec.schema, 
       'AQ$_'||qt_rec.name||'_F';

    EXCEPTION
      WHEN BASE_TABLE_DOES_NOT_EXIST THEN
        NULL;
      WHEN OTHERS THEN 
       RAISE;
    END;
  END LOOP;

END;
/

COMMIT
/
