Rem
Rem $Header: rdbms/admin/depssvrm.sql /st_rdbms_11.2.0/1 2012/09/13 03:49:46 apfwkr Exp $
Rem
Rem depssvrm.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      depssvrm.sql - DEPendent SeRVeR Management objects
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      09/11/12 - Backport marccaba_customerbug_12629687 from main
Rem    ilistvin    11/07/08 - add DBA_TABLESPACE_THRESHOLDS view
Rem    ilistvin    06/15/07 - tune autotask views
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    ilistvin    05/15/07 - fix synonym for DBA_AUTOTASK_JOB_HISTORY
Rem    pbelknap    01/12/07 - check for autotask client status overrides
Rem    rdongmin    01/04/07 - move dbmssqlt to catpdbms.sql
Rem    ilistvin    01/04/07 - merge fix for bug 5690818
Rem    ilistvin    11/13/06 - add prvtspis.plb
Rem    ilistvin    11/09/06 - 
Rem    mlfeng      10/31/06 - 
Rem    rburns      09/17/06 - dependent views
Rem    rburns      09/17/06 - Created
Rem


Rem Create dbms_auto_task packages (depends on dbms_scheduler)
@@dbmsatsk

Rem prvt_sqlpai for SQL Performance Analyzer (SQLPA)
@@prvsspai.plb

Rem dbms_sqltune_internal (depends on dbmssqlt)
@@prvssqli.plb

-- Create dba_outstanding_alerts view
CREATE OR REPLACE VIEW dba_outstanding_alerts
  AS SELECT sequence_id, 
            reason_id,
            owner, 
            object_name, 
            subobject_name, 
            typnam_keltosd AS object_type, 
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             mid_keltsd, 
                                             reason_argument_1, 
                                             reason_argument_2, 
                                             reason_argument_3, 
                                             reason_argument_4,
                                             reason_argument_5) AS reason, 
            time_suggested, 
            creation_time,
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             amid_keltsd,
                                             action_argument_1, 
                                             action_argument_2, 
                                             action_argument_3, 
                                             action_argument_4,
                                             action_argument_5) 
              AS suggested_action, 
            advisor_name, 
            metric_value,
            decode(message_level, 32, 'Notification', 'Warning') 
              AS message_type, 
            nam_keltgsd AS message_group, 
            message_level, 
            hosting_client_id, 
            mdid_keltsd AS module_id, 
            process_id, 
            host_id, 
            host_nw_addr, 
            instance_name, 
            instance_number, 
            user_id,  
            execution_context_id, 
            error_instance_id 
  FROM wri$_alert_outstanding, X$KELTSD, X$KELTOSD, X$KELTGSD, 
       dba_advisor_definitions
  WHERE reason_id = rid_keltsd 
    AND otyp_keltsd = typid_keltosd 
    AND grp_keltsd = id_keltgsd 
    AND aid_keltsd = advisor_id(+); 

CREATE OR REPLACE PUBLIC SYNONYM dba_outstanding_alerts
   FOR sys.dba_outstanding_alerts;
GRANT select on dba_outstanding_alerts TO select_catalog_role;

comment on table DBA_OUTSTANDING_ALERTS is
'Description of all outstanding alerts';

comment on column DBA_OUTSTANDING_ALERTS.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_OUTSTANDING_ALERTS.REASON_ID is
'Alert reason id';

comment on column DBA_OUTSTANDING_ALERTS.OWNER is
'Owner of object on which alert is issued';

comment on column DBA_OUTSTANDING_ALERTS.OBJECT_NAME is
'Name of the object';

comment on column DBA_OUTSTANDING_ALERTS.SUBOBJECT_NAME is
'Name of the subobject (partition)';

comment on column DBA_OUTSTANDING_ALERTS.OBJECT_TYPE is
'Type of the object (table, tablespace, etc)';

comment on column DBA_OUTSTANDING_ALERTS.REASON is
'Reason for the alert';

comment on column DBA_OUTSTANDING_ALERTS.TIME_SUGGESTED is
'Time when the alert was last updated';

comment on column DBA_OUTSTANDING_ALERTS.CREATION_TIME is
'Time when the alert was first created';

comment on column DBA_OUTSTANDING_ALERTS.SUGGESTED_ACTION is 
'Advice of recommended action';

comment on column DBA_OUTSTANDING_ALERTS.ADVISOR_NAME is
'Name of advisor to be invoked for more information';

comment on column DBA_OUTSTANDING_ALERTS.METRIC_VALUE is
'Value of the related metrics';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_TYPE is
'Message type - warning or notification';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_GROUP is
'Name of the group that the alert belongs to';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_LEVEL is
'Severity level (1-32)';

comment on column DBA_OUTSTANDING_ALERTS.HOSTING_CLIENT_ID is
'ID of the client or security group etc. that the alert relates to';

comment on column DBA_OUTSTANDING_ALERTS.MODULE_ID is
'ID of the module that originated the alert';

comment on column DBA_OUTSTANDING_ALERTS.PROCESS_ID is
'Process id';

comment on column DBA_OUTSTANDING_ALERTS.HOST_ID is
'DNS hostname of originating host';

comment on column DBA_OUTSTANDING_ALERTS.HOST_NW_ADDR is
'IP or other network address of originating host';

comment on column DBA_OUTSTANDING_ALERTS.INSTANCE_NAME is
'Originating instance name';

comment on column DBA_OUTSTANDING_ALERTS.INSTANCE_NUMBER is
'Originating instance number';

comment on column DBA_OUTSTANDING_ALERTS.USER_ID is
'User id';

comment on column DBA_OUTSTANDING_ALERTS.EXECUTION_CONTEXT_ID is
'ID of the threshold of execution';

comment on column DBA_OUTSTANDING_ALERTS.ERROR_INSTANCE_ID is
'ID of an error instance plus a sequence number';

CREATE OR REPLACE VIEW dba_alert_history
  AS select sequence_id, 
            reason_id, 
            owner, 
            object_name, 
            subobject_name, 
            typnam_keltosd AS object_type, 
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             mid_keltsd, 
                                             reason_argument_1, 
                                             reason_argument_2, 
                                             reason_argument_3, 
                                             reason_argument_4,
                                             reason_argument_5) AS reason, 
            time_suggested, 
            creation_time,
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             amid_keltsd,
                                             action_argument_1, 
                                             action_argument_2, 
                                             action_argument_3, 
                                             action_argument_4,
                                             action_argument_5) 
              AS suggested_action, 
            advisor_name, 
            metric_value,
            decode(message_level, 32, 'Notification', 'Warning') 
              AS message_type, 
            nam_keltgsd AS message_group, 
            message_level, 
            hosting_client_id, 
            mdid_keltsd AS module_id, 
            process_id, 
            host_id, 
            host_nw_addr, 
            instance_name, 
            instance_number, 
            user_id,  
            execution_context_id, 
            error_instance_id, 
            decode(resolution, 1, 'cleared', 'N/A') AS resolution
  FROM wri$_alert_history, X$KELTSD, X$KELTOSD, X$KELTGSD, 
       dba_advisor_definitions
  WHERE reason_id = rid_keltsd 
    AND otyp_keltsd = typid_keltosd 
    AND grp_keltsd = id_keltgsd 
    AND aid_keltsd = advisor_id(+); 

CREATE OR REPLACE PUBLIC SYNONYM dba_alert_history
   FOR sys.dba_alert_history;
GRANT select on dba_alert_history TO select_catalog_role;

comment on table DBA_ALERT_HISTORY is
'Description on alert history';

comment on column DBA_ALERT_HISTORY.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_ALERT_HISTORY.REASON_ID is
'Alert reason id';

comment on column DBA_ALERT_HISTORY.OWNER is
'Owner of the object on which alert is issued';

comment on column DBA_ALERT_HISTORY.OBJECT_NAME is
'Name of the object';

comment on column DBA_ALERT_HISTORY.SUBOBJECT_NAME is
'Name of the subobject (partition)';

comment on column DBA_ALERT_HISTORY.OBJECT_TYPE is
'Type of the object (table, tablespace, etc)';

comment on column DBA_ALERT_HISTORY.REASON is
'Reason for the alert';

comment on column DBA_ALERT_HISTORY.TIME_SUGGESTED is
'Time when the alert was last updated';

comment on column DBA_ALERT_HISTORY.CREATION_TIME is
'Time when the alert was first produced';

comment on column DBA_ALERT_HISTORY.SUGGESTED_ACTION is
'Advice of recommended action';

comment on column DBA_ALERT_HISTORY.ADVISOR_NAME is
'Name of advisor to be invoked for more information';

comment on column DBA_ALERT_HISTORY.METRIC_VALUE is
'Value of the related metrics';

comment on column DBA_ALERT_HISTORY.MESSAGE_TYPE is
'Message type - warning or notification';

comment on column DBA_ALERT_HISTORY.MESSAGE_GROUP is
'Name of the group that the alert belongs to';

comment on column DBA_ALERT_HISTORY.MESSAGE_LEVEL is
'Severity level (1-32)';

comment on column DBA_ALERT_HISTORY.HOSTING_CLIENT_ID is
'ID of the client or security group etc. that the alert relates to';

comment on column DBA_ALERT_HISTORY.MODULE_ID is
'ID of the module that originated the alert';

comment on column DBA_ALERT_HISTORY.PROCESS_ID is
'Process id';

comment on column DBA_ALERT_HISTORY.HOST_ID is
'DNS hostname of originating host';

comment on column DBA_ALERT_HISTORY.HOST_NW_ADDR is
'IP or other network address of originating host';

comment on column DBA_ALERT_HISTORY.INSTANCE_NAME is
'Originating instance name';

comment on column DBA_ALERT_HISTORY.INSTANCE_NUMBER is
'Originating instance number';

comment on column DBA_ALERT_HISTORY.USER_ID is
'User id';

comment on column DBA_ALERT_HISTORY.EXECUTION_CONTEXT_ID is
'ID of the thread of execution';

comment on column DBA_ALERT_HISTORY.ERROR_INSTANCE_ID is
'ID of an error instance plus a sequence number';

comment on column DBA_ALERT_HISTORY.RESOLUTION is
'Cleared or not';

-- Create dba_thresholds view
CREATE OR REPLACE VIEW dba_thresholds 
  AS select m.name AS metrics_name,
            decode(a.warning_operator, 0, 'GT',
                                       1, 'EQ',
                                       2, 'LT',
                                       3, 'LE',
                                       4, 'GE',
                                       5, 'CONTAINS',
                                       6, 'NE',
                                       7, 'DO NOT CHECK',
                                          'NONE') AS warning_operator,
            a.warning_value AS warning_value,
            decode(a.critical_operator, 0, 'GT',
                                        1, 'EQ',
                                        2, 'LT',
                                        3, 'LE',
                                        4, 'GE',
                                        5, 'CONTAINS',
                                        6, 'NE',
                                        7, 'DO_NOT_CHECK',
                                           'NONE') AS critical_operator,
            a.critical_value AS critical_value,
            a.observation_period AS observation_period,
            a.consecutive_occurrences AS consecutive_occurrences,
            decode(a.instance_name, ' ', null, 
                                       instance_name) AS instance_name,
            o.typnam_keltosd AS object_type,
            a.object_name AS object_name,
            decode(a.flags, 1, 'VALID',
                            0, 'INVALID') AS status
  FROM table(dbms_server_alert.view_thresholds) a,
       X$KEWMDSM m, 
       X$KELTOSD o 
  WHERE a.object_type != 2 
    AND m.metricid(+) = a.metrics_id
    AND a.object_type = o.typid_keltosd
  UNION
     select m.name AS metrics_name,
            decode(a.warning_operator, 0, 'GT',
                                       1, 'EQ',
                                       2, 'LT',
                                       3, 'LE',
                                       4, 'GE',
                                       5, 'CONTAINS',
                                       6, 'NE',
                                       7, 'DO_NOT_CHECK',
                                          'NONE') AS warning_operator,
            a.warning_value AS warning_value,
            decode(a.critical_operator, 0, 'GT',
                                        1, 'EQ',
                                        2, 'LT',
                                        3, 'LE',
                                        4, 'GE',
                                        5, 'CONTAINS',
                                        6, 'NE',
                                        7, 'DO NOT CHECK',
                                           'NONE') AS critical_operator,
            a.critical_value AS critical_value,
            a.observation_period AS observation_period,
            a.consecutive_occurrences AS consecutive_occurrences,
            decode(a.instance_name, ' ', null,
                                       instance_name) AS instance_name,
            o.typnam_keltosd AS object_type,
            f.name AS object_name,
            decode(a.flags, 1, 'VALID',
                            0, 'INVALID') AS status
  FROM table(dbms_server_alert.view_thresholds) a,
       X$KEWMDSM m, sys.v$dbfile f, X$KELTOSD o
  WHERE a.object_type = 2
    AND m.metricid = a.metrics_id
    AND a.object_id = f.file#
    AND a.object_type = o.typid_keltosd;

CREATE OR REPLACE PUBLIC SYNONYM dba_thresholds
   FOR sys.dba_thresholds;
GRANT select on dba_thresholds TO select_catalog_role;

comment on table DBA_THRESHOLDS is
'Desription of all thresholds';

comment on column DBA_THRESHOLDS.METRICS_NAME is
'Metrics name';

comment on column DBA_THRESHOLDS.WARNING_OPERATOR is
'Relational operator for warning thresholds';

comment on column DBA_THRESHOLDS.WARNING_VALUE is
'Warning threshold value';

comment on column DBA_THRESHOLDS.CRITICAL_OPERATOR is
'Relational operator for critical thresholds';

comment on column DBA_THRESHOLDS.CRITICAL_VALUE is
'Critical threshold value';

comment on column DBA_THRESHOLDS.OBSERVATION_PERIOD is
'Observation period length (in minutes)';

comment on column DBA_THRESHOLDS.CONSECUTIVE_OCCURRENCES is
'Has to occur so many times before an alert is issued';

comment on column DBA_THRESHOLDS.INSTANCE_NAME is
'Instance name - NULL for database-wide alerts';

comment on column DBA_THRESHOLDS.OBJECT_TYPE is
'Object type: SYSTEM, TABLESPACE, SERVICE, FILE, etc';

comment on column DBA_THRESHOLDS.OBJECT_NAME is
'Name of the object for which the threshold is set';

comment on column DBA_THRESHOLDS.STATUS is
'Whether threshold is applicable on a valid object';
--
-- View to display current threshold settings for all tablespaces
--
  CREATE OR REPLACE VIEW DBA_TABLESPACE_THRESHOLDS 
  AS
  SELECT tablespace_name,
         contents,
         extent_management,
         decode(threshold_type, 1, 'EXPLICIT',
                                2, 'DEFAULT',
                                'NONE') as threshold_type,
         metrics_name,
         decode(warning_operator, 0, 'GT',
                                  1, 'EQ',
                                  2, 'LT',
                                  3, 'LE',
                                  4, 'GE',
                                  5, 'CONTAINS',
                                  6, 'NE',
                                  7, 'DO NOT CHECK',
                                  'NONE') AS warning_operator,
         warning_value,
         decode(critical_operator, 0, 'GT',
                                   1, 'EQ',
                                   2, 'LT',
                                   3, 'LE',
                                   4, 'GE',
                                   5, 'CONTAINS',
                                   6, 'NE',
                                   7, 'DO NOT CHECK',
                                   'NONE') AS critical_operator,
         critical_value
    FROM
    (SELECT tbs.tablespace_name,
            tbs.contents,
            tbs.extent_management,
            decode(m.metrics_name, NULL, 0, 1) as threshold_type,
            m.metrics_name,
            m.warning_operator,
            m.warning_value,
            m.critical_operator,
            m.critical_value
      FROM
         ((SELECT tablespace_name,
                 contents,
                 extent_management
             FROM DBA_TABLESPACES
            WHERE tablespace_name IN
                  (SELECT object_name
                     FROM table(dbms_server_alert.view_thresholds)
                    WHERE object_type = 5
                      AND object_name IS NOT NULL
                      AND metrics_id IN (9000, 9001))
          ) tbs
       LEFT OUTER JOIN 
         (SELECT a.object_name,
                m.name AS metrics_name,
                a.warning_operator AS warning_operator,
                a.warning_value AS warning_value,
                a.critical_operator AS critical_operator,
                a.critical_value AS critical_value,
                c.contents
            FROM table(dbms_server_alert.view_thresholds) a,
                 X$KEWMDSM m,
                 (SELECT 'PERMANENT' AS contents FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                    AND display_value='TRUE')
                  UNION ALL
                  SELECT 'TEMPORARY' FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                    AND display_value = 'TRUE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                 WHERE name = '_disable_temp_tablespace_alerts'
                                    AND display_value = 'FALSE')
                  UNION ALL
                  SELECT 'UNDO' FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                          AND display_value='TRUE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                 WHERE name = '_disable_undo_tablespace_alerts'
                                    AND display_value = 'FALSE')) c
           WHERE a.object_type = 5
             AND a.flags = 1
             AND a.object_name IS NOT NULL 
             AND a.metrics_id IN (9000, 9001)
             AND m.metricid = a.metrics_id) m
        ON (tbs.tablespace_name = m.object_name
            and tbs.contents = m.contents))
   UNION ALL 
    SELECT tbs.tablespace_name,
            tbs.contents,
            tbs.extent_management,
            decode(m.metrics_name, NULL, 0, 2) as threshold_type,
            m.metrics_name,
            m.warning_operator,
            m.warning_value,
            m.critical_operator,
            m.critical_value
      FROM
        ((SELECT tablespace_name,
                 contents,
                 extent_management
            FROM DBA_TABLESPACES
           WHERE tablespace_name NOT IN
                  (SELECT object_name
                     FROM table(dbms_server_alert.view_thresholds)
                    WHERE object_type = 5
                      AND object_name IS NOT NULL
                      AND metrics_id IN (9000, 9001))
         ) tbs
         LEFT OUTER JOIN
         (SELECT 'LOCAL' as extent_management,
                  m.name AS metrics_name,
                  a.warning_operator AS warning_operator,
                  a.warning_value AS warning_value,
                  a.critical_operator AS critical_operator,
                  a.critical_value AS critical_value,
                  c.contents
            FROM table(dbms_server_alert.view_thresholds) a,
                 X$KEWMDSM m,
                 (SELECT 'PERMANENT' AS contents FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                    AND display_value='TRUE')
                  UNION ALL
                  SELECT 'TEMPORARY' FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                    AND display_value = 'TRUE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                 WHERE name = '_disable_temp_tablespace_alerts'
                                   AND display_value = 'FALSE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_default_temp_threshold'
                                    AND display_value = 'TRUE')
                  UNION ALL
                  SELECT 'UNDO' FROM DUAL
                   WHERE EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_tablespace_alerts'
                                          AND display_value='TRUE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                 WHERE name = '_disable_undo_tablespace_alerts'
                                   AND display_value = 'FALSE')
                     AND EXISTS (SELECT * FROM GV$SYSTEM_PARAMETER3
                                  WHERE name = '_enable_default_undo_threshold'
                                    AND display_value = 'TRUE')) c
           WHERE a.object_type = 5
             AND a.object_name IS NULL
             AND a.metrics_id IN (9000, 9001)
             AND m.metricid = a.metrics_id) m
        ON (tbs.extent_management =  m.extent_management
            and tbs.contents = m.contents)));

create or replace public synonym DBA_TABLESPACE_THRESHOLDS
       for DBA_TABLESPACE_THRESHOLDS;

grant select on DBA_TABLESPACE_THRESHOLDS to select_catalog_role;

comment on table DBA_TABLESPACE_THRESHOLDS is
  'Space Utilization Threshold settings for all tablespaces';

comment on column DBA_TABLESPACE_THRESHOLDS.TABLESPACE_NAME is
  'Tablespace name';

comment on column DBA_TABLESPACE_THRESHOLDS.CONTENTS is
  'Tablespace contents: "PERMANENT", "TEMPORARY", or "UNDO"';

comment on column DBA_TABLESPACE_THRESHOLDS.EXTENT_MANAGEMENT is
  'Extent management tracking: "DICTIONARY" or "LOCAL"';

comment on column DBA_TABLESPACE_THRESHOLDS.THRESHOLD_TYPE is
  'Source of threshold: "EXPLICIT", "DEFAULT", or "NONE"';

comment on column DBA_TABLESPACE_THRESHOLDS.METRICS_NAME is
  'Name of the metric being monitored';

comment on column DBA_TABLESPACE_THRESHOLDS.WARNING_OPERATOR is
  'Relational operator for warning thresholds';

comment on column DBA_TABLESPACE_THRESHOLDS.WARNING_VALUE is
  'Warning threshold value';

comment on column DBA_TABLESPACE_THRESHOLDS.CRITICAL_OPERATOR is
  'Relational operator for critical thresholds';

comment on column DBA_TABLESPACE_THRESHOLDS.CRITICAL_VALUE is
  'Critical threshold value';


CREATE OR REPLACE VIEW DBA_AUTOTASK_OPERATION (
      CLIENT_NAME,
      OPERATION_NAME,
      OPERATION_TAG,
      PRIORITY_OVERRIDE,
      ATTRIBUTES,
      USE_RESOURCE_ESTIMATES,
      STATUS) AS
SELECT C.CNAME_KETCL,
      O.OPNAME_KETOP,
      O.OTAG_KETOP,
      NVL(DECODE(COALESCE(RC.PRIORITY_OVERRIDE, RO.PRIORITY_OVERRIDE),
                  NULL, NULL,
                     1, 'MEDIUM', 
                     2, 'HIGH', 
                     3, 'URGENT','INVALID'), '  ')
          AS PRIORITY_OVERRIDE,
      dbms_auto_task.decode_attributes(
         dbms_auto_task.reconcile_attributes(C.ATTR_KETCL,
                                             RC.ATTRIBUTES,
                                              O.ATTR_KETOP,
                                              NVL(RO.ATTRIBUTES, 0),
                                              0,0)
       ) AS ATTRIBUTES,
       CASE BITAND(21,
                   dbms_auto_task.reconcile_attributes(C.ATTR_KETCL,
                   RC.ATTRIBUTES, O.ATTR_KETOP, NVL(RO.ATTRIBUTES, 0), 0,0))
       WHEN 0 THEN 'TRUE'
       ELSE 'FALSE' 
       END AS USE_RESOURCE_ESTIMATES,
       CASE RC.STATUS 
       WHEN 2 THEN DECODE(RO.STATUS, NULL, 'ENABLED',
                          2, 'ENABLED', 1, 'DISABLED', 'INVALID')
       WHEN 1 THEN 'DISABLED'
       ELSE 'INVALID'
       END  AS STATUS
 FROM X$KETCL C, X$KETOP O, KET$_CLIENT_CONFIG RC, KET$_CLIENT_CONFIG RO
WHERE C.CID_KETCL = O.CID_KETOP
  AND C.CID_KETCL > 0
  AND C.CID_KETCL = RC.CLIENT_ID 
  AND (BITAND(C.ATTR_KETCL,2048) = 0
          OR 999999 < (SELECT TO_NUMBER(VALUE)
                         FROM V$SYSTEM_PARAMETER
                        WHERE NAME = '_automatic_maintenance_test'))
  AND RC.OPERATION_ID = 0
  AND O.CID_KETOP = RO.CLIENT_ID(+)
  AND O.OPID_KETOP = RO.OPERATION_ID(+);


CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_OPERATION
   FOR sys.DBA_AUTOTASK_OPERATION;
GRANT select on DBA_AUTOTASK_OPERATION TO select_catalog_role;

comment on table DBA_AUTOTASK_OPERATION is
 'Automated Maintenance Task Operation Configuration';

comment on column DBA_AUTOTASK_OPERATION.CLIENT_NAME is
 'Name of Autotask Client';

comment on column DBA_AUTOTASK_OPERATION.OPERATION_NAME is
 'Name of Autotask Client Operation';

comment on column DBA_AUTOTASK_OPERATION.OPERATION_TAG is
 'Tag of Autotask Client Operation';

comment on column DBA_AUTOTASK_OPERATION.PRIORITY_OVERRIDE is
 'Priority that will be used for all jobs performing the operation';

comment on column DBA_AUTOTASK_OPERATION.ATTRIBUTES is
 'Operation attributes';

comment on column DBA_AUTOTASK_OPERATION.USE_RESOURCE_ESTIMATES is
 'Specifies if resource usage estimates are used for the operation';

comment on column DBA_AUTOTASK_OPERATION.STATUS is
 'Status of the operation';
CREATE OR REPLACE VIEW DBA_AUTOTASK_TASK (
      CLIENT_NAME,
      TASK_NAME,
      TASK_TARGET_TYPE,
      TASK_TARGET_NAME,
      OPERATION_NAME,
      ATTRIBUTES,
      TASK_PRIORITY,
      PRIORITY_OVERRIDE,
      STATUS,
      DEFERRED_WINDOW_NAME,
      CURRENT_JOB_NAME,
      JOB_SCHEDULER_STATUS, 
      ESTIMATE_TYPE,
      ESTIMATED_WEIGHT,
      ESTIMATED_DURATION,
      ESTIMATED_CPU_TIME,
      ESTIMATED_TEMP,
      ESTIMATED_DOP,
      ESTIMATED_IO_RATE,
      ESTIMATED_UNDO_RATE,
      RETRY_COUNT,
      LAST_GOOD_DATE,
      LAST_GOOD_PRIORITY,
      LAST_GOOD_DURATION,
      LAST_GOOD_CPU_TIME,
      LAST_GOOD_TEMP,
      LAST_GOOD_DOP,
      LAST_GOOD_IO_RATE,
      LAST_GOOD_UNDO_RATE,
      LAST_GOOD_CPU_WAIT,
      LAST_GOOD_IO_WAIT,
      LAST_GOOD_UNDO_WAIT,
      LAST_GOOD_TEMP_WAIT,
      LAST_GOOD_CONCURRENCY,
      LAST_GOOD_CONTENTION,
      NEXT_TRY_DATE,
      LAST_TRY_DATE,
      LAST_TRY_PRIORITY,
      LAST_TRY_RESULT,
      LAST_TRY_DURATION,
      LAST_TRY_CPU_TIME,
      LAST_TRY_TEMP,
      LAST_TRY_DOP,
      LAST_TRY_IO_RATE,
      LAST_TRY_UNDO_RATE,
      LAST_TRY_CPU_WAIT,
      LAST_TRY_IO_WAIT,
      LAST_TRY_UNDO_WAIT,
      LAST_TRY_TEMP_WAIT,
      LAST_TRY_CONCURRENCY,
      LAST_TRY_CONTENTION,
      MEAN_GOOD_DURATION,
      MEAN_GOOD_CPU_TIME,
      MEAN_GOOD_TEMP,
      MEAN_GOOD_DOP,
      MEAN_GOOD_IO,
      MEAN_GOOD_UNDO,
      MEAN_GOOD_CPU_WAIT,
      MEAN_GOOD_IO_WAIT,
      MEAN_GOOD_UNDO_WAIT,
      MEAN_GOOD_TEMP_WAIT,
      MEAN_GOOD_CONCURRENCY,
      MEAN_GOOD_CONTENTION,
      INFO_FIELD_1,
      INFO_FIELD_2,
      INFO_FIELD_3,
      INFO_FIELD_4 
) AS
   SELECT 
      C.CNAME_KETCL, 
      O.PRG_KETOP, 
      TG.TNAME_KETTG, 
      T.TARGET_NAME,
      O.OPNAME_KETOP,
      dbms_auto_task.decode_attributes(T.ATTRIBUTES),
      T.TASK_PRIORITY,
      T.PRIORITY_OVERRIDE,
      DECODE(T.STATUS,1, 'DISABLED',2,'ENABLED',13,'DEFERRED','INVALID'),
      T.WINDOW_NAME,
      T.CURR_JOB_NAME,
      SJ.STATE,
      DECODE(T.EST_TYPE, 1, 'DERIVED', 2, 'FORCED', 3, 'LOCKED', 'N/A'),
      T.EST_WEIGHT,
      T.EST_DURATION,
      T.EST_CPU_TIME,
      T.EST_TEMP,
      T.EST_DOP,
      T.EST_IO_RATE,
      T.EST_UNDO_RATE,
      T.RETRY_COUNT,
      T.LG_DATE,
      T.LG_PRIORITY,
      T.LG_DURATION,
      T.LG_CPU_TIME,
      T.LG_TEMP,
      T.LG_DOP,
      T.LG_IO_RATE,
      T.LG_UNDO_RATE,
      T.LG_CPU_WAIT,
      T.LG_IO_WAIT,
      T.LG_UNDO_WAIT,
      T.LG_TEMP_WAIT,
      T.LG_CONCURRENCY,
      T.LG_CONTENTION,
      W.NEXT_START_DATE,
      T.LT_DATE,
      T.LT_PRIORITY,
      CASE T.LT_TERM_CODE
        WHEN NULL THEN 'N/A'
        WHEN 10 THEN 'SUCCEEDED'
        WHEN 11 THEN 'FAILED'
        WHEN 12 THEN 'STOPPED BY USER ACTION'
        WHEN 13 THEN 'STOPPED AT END OF MAINTENANCE WINDOW'
        WHEN 14 THEN 'STOPPED AT INSTANCE SHUTDOWN'
        WHEN 15 THEN 'STOPPED'
        ELSE 'UNKNOWN'
      END,
      T.LT_DURATION,
      T.LT_CPU_TIME,
      T.LT_TEMP,
      T.LT_DOP,
      T.LT_IO_RATE,
      T.LT_UNDO_RATE, 
      T.LT_CPU_WAIT,
      T.LT_IO_WAIT,
      T.LT_UNDO_WAIT,
      T.LT_TEMP_WAIT,
      T.LT_CONCURRENCY,
      T.LT_CONTENTION,
      T.MG_DURATION,
      T.MG_CPU_TIME,
      T.MG_TEMP,
      T.MG_DOP,
      T.MG_IO_RATE,
      T.MG_UNDO_RATE,
      T.MG_CPU_WAIT,
      T.MG_IO_WAIT,
      T.MG_UNDO_WAIT,
      T.MG_TEMP_WAIT,
      T.MG_CONCURRENCY,
      T.MG_CONTENTION,
      T.INFO_FIELD_1,
      T.INFO_FIELD_2,
      T.INFO_FIELD_3,
      T.INFO_FIELD_4
    FROM  KET$_CLIENT_TASKS T, X$KETCL C, X$KETOP O, X$KETTG TG,
          DBA_SCHEDULER_WINDOWS W, DBA_SCHEDULER_JOBS SJ
   WHERE T.CLIENT_ID = C.CID_KETCL
     AND (BITAND(C.ATTR_KETCL,2048) = 0
            OR 999999 < (SELECT TO_NUMBER(VALUE)
                           FROM V$SYSTEM_PARAMETER
                          WHERE NAME = '_automatic_maintenance_test'))
     AND C.CID_KETCL > 0
     AND T.CLIENT_ID = O.CID_KETOP
     AND T.OPERATION_ID = O.OPID_KETOP
     AND T.TARGET_TYPE = TG.TID_KETTG
     AND T.WINDOW_NAME = W.WINDOW_NAME(+)
     AND T.CURR_JOB_NAME = SJ.JOB_NAME(+);

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_TASK
   FOR sys.DBA_AUTOTASK_TASK;
GRANT select on DBA_AUTOTASK_TASK TO select_catalog_role;

comment on table DBA_AUTOTASK_TASK is 
 'Information about current and past autmated maintenance tasks';

comment on column DBA_AUTOTASK_TASK.CLIENT_NAME is 
 'Name of the Automated Maintenance client';

comment on column DBA_AUTOTASK_TASK.TASK_NAME is 
 'Name of the maintenance task';

comment on column DBA_AUTOTASK_TASK.TASK_TARGET_TYPE is 
 'Type of target of the maintenance task';

comment on column DBA_AUTOTASK_TASK.TASK_TARGET_NAME is 
 'Name of the maintenance task target';

comment on column DBA_AUTOTASK_TASK.OPERATION_NAME is 
 'Operation being performed by the task';

comment on column DBA_AUTOTASK_TASK.ATTRIBUTES is 
 'Task attributes';

comment on column DBA_AUTOTASK_TASK.TASK_PRIORITY is 
 'Task priority, relative to other tasks for this Client';

comment on column DBA_AUTOTASK_TASK.PRIORITY_OVERRIDE is 
 'Task priority as overridden by the user';

comment on column DBA_AUTOTASK_TASK.STATUS is 
 'Current status of the task';

comment on column DBA_AUTOTASK_TASK.DEFERRED_WINDOW_NAME is 
 'Name of the window to which execution of this task is deferred';

comment on column DBA_AUTOTASK_TASK.CURRENT_JOB_NAME is 
 'Job name associated with the task';

comment on column DBA_AUTOTASK_TASK.JOB_SCHEDULER_STATUS is 
 'Job status';
 
comment on column DBA_AUTOTASK_TASK.ESTIMATE_TYPE is 
 'Type of resource estimates applied';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_WEIGHT is 
 'Weight of the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_DURATION is 
 'Estimated elapsed time for the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_CPU_TIME is 
 'Estimated CPU utilization for the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_TEMP is 
 'Estimated temp space usage for the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_DOP is 
 'Estimated Degree of Parallelism for the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_IO_RATE is 
 'Estimated I/O Rate for the task';

comment on column DBA_AUTOTASK_TASK.ESTIMATED_UNDO_RATE is 
 'Estimated UNDO generation rate  for the task';

comment on column DBA_AUTOTASK_TASK.RETRY_COUNT is 
 'Numbe rof failed attempts to execute the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_DATE is 
 'Date/time of the last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_PRIORITY is 
 'Task priority during the last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_DURATION is 
 'Elapsed time of the last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_CPU_TIME is 
 'CPU time used during the last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_TEMP is 
 'Peak temp space used during last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_DOP is 
 'Parallelsism during last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_IO_RATE is 
 'Mean I/O rate during last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_UNDO_RATE is 
 'Mean UNDO rate during last successful execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_CPU_WAIT is 
 'Total time spent waiting for CPU during last good run' ;

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_IO_WAIT is 
 'Total time spent waiting for I/O during last good run';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_UNDO_WAIT is 
 'Total time spent waiting for UNDO during last good run';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_TEMP_WAIT is 
 'Total time spent waiting for Temp Space during last good run';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_CONCURRENCY is 
 'Total time in concurrency wait during last good run';

comment on column DBA_AUTOTASK_TASK.LAST_GOOD_CONTENTION is 
 'Total time in contention  wait during last good run';

comment on column DBA_AUTOTASK_TASK.NEXT_TRY_DATE is 
 'Next projected start date/time for the deferred maintenance window';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_DATE is 
 'Date/Time of the last executon of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_PRIORITY is 
 'Priority of the task at the time of the last execution';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_RESULT is 
 'Result code of the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_DURATION is 
 'Elapsed time of the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_CPU_TIME is 
 'CPU time consumed during last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_TEMP is 
 'Peak Temp space usage during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_DOP is 
 'Degree of parallelism of the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_IO_RATE is 
 'I/O rate during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_UNDO_RATE is 
 'UNDO generation rate during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_CPU_WAIT is 
 'Time spent waiting for CPU during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_IO_WAIT is 
 'Time spent waiting for I/O during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_UNDO_WAIT is 
 'Time spent waiting for UNDO during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_TEMP_WAIT is 
 'Time spent waiting for Temp Space during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_CONCURRENCY is 
 'Time spent in concurrency wait during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.LAST_TRY_CONTENTION is 
 'Time spent in contention wait during the last execution of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_DURATION is 
 'Average elapsed time for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_CPU_TIME is 
 'Average CPU usage for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_TEMP is 
 'Average peak temp space usage for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_DOP is 
 'Average degree or parallelism for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_IO is 
 'Average I/O rate for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_UNDO is 
 'Average Undo generation rate for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_CPU_WAIT is 
 'Average CPU wait time for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_IO_WAIT is 
 'Average I/O wait time for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_UNDO_WAIT is 
 'Average Undo wait time for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_TEMP_WAIT is 
 'Average wait time for Temp space for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_CONCURRENCY is 
 'Average time in concurrency wait for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.MEAN_GOOD_CONTENTION is 
 'Average time in contention wait for successful executions of the task';

comment on column DBA_AUTOTASK_TASK.INFO_FIELD_1 is 
 'Additional information field';

comment on column DBA_AUTOTASK_TASK.INFO_FIELD_2 is 
 'Additional information field';

comment on column DBA_AUTOTASK_TASK.INFO_FIELD_3 is 
 'Additional Client information field';

comment on column DBA_AUTOTASK_TASK.INFO_FIELD_4 is 
 'Additional Client information field';


CREATE OR REPLACE VIEW DBA_AUTOTASK_SCHEDULE (window_name, start_time, duration)
AS
  SELECT *
    FROM TABLE (dbms_auto_task.window_calendar(
                CURSOR(SELECT wgr.window_name,
                              case when w.start_date > current_timestamp
                                   then w.start_date
                                   else current_timestamp
                              end,
                              case when w.end_date <
                                       (current_timestamp + INTERVAL '32' DAY)
                                   then w.end_date
                                   else current_timestamp + INTERVAL '32' DAY
                              end
                         FROM dba_scheduler_windows w,
                              dba_scheduler_wingroup_members wgr
                        WHERE w.window_name = wgr.window_name
                          AND w.enabled = 'TRUE'
                          AND (w.start_date IS NULL
                               OR w.start_date < current_timestamp + INTERVAL '32' DAY)
                          AND wgr.window_group_name = 'MAINTENANCE_WINDOW_GROUP')));

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_SCHEDULE
   FOR sys.DBA_AUTOTASK_SCHEDULE;
GRANT select on DBA_AUTOTASK_SCHEDULE TO select_catalog_role;

comment on table DBA_AUTOTASK_SCHEDULE is 
 'Schedule of Maintenance Windows for the next 32 days';

comment on column DBA_AUTOTASK_SCHEDULE.WINDOW_NAME is
 'Name of the Maintenance Window';

comment on column DBA_AUTOTASK_SCHEDULE.START_TIME is
 'Projected start time of the window';

comment on column DBA_AUTOTASK_SCHEDULE.DURATION is
 'Currently defined duration of the window';

-- This view provides information about current jobs for all clients. 

CREATE OR REPLACE VIEW DBA_AUTOTASK_CLIENT_JOB (
      CLIENT_NAME,      
      JOB_NAME, 
      JOB_SCHEDULER_STATUS, 
      TASK_NAME ,
      TASK_TARGET_TYPE, 
      TASK_TARGET_NAME, 
      TASK_PRIORITY, 
      TASK_OPERATION)
AS
      SELECT C.CNAME_KETCL AS CLIENT_NAME,
             TR.CURR_JOB_NAME AS JOB_NAME,
             SJ.STATE AS JOBS_SCHEDULER_STATUS,
             OP.PRG_KETOP AS TASK_NAME,
             TG.TNAME_KETTG AS TASK_TARGET_TYPE,
             TR.TARGET_NAME AS TASK_TARGET_NAME,
             DECODE(TR.TASK_PRIORITY,
                     1,'MEDIUM',
                     2,'HIGH',
                     3,'URGENT','INVALID') AS TASK_PRIORITY,
             OP.OPNAME_KETOP AS TASK_OPERATION
        FROM X$KETCL C, X$KETTG TG, X$KETOP OP, KET$_CLIENT_TASKS TR, 
             DBA_SCHEDULER_JOBS SJ
       WHERE C.CID_KETCL = TR.CLIENT_ID
         AND C.CID_KETCL > 0
         AND OP.OPID_KETOP > 0
         AND (BITAND(C.ATTR_KETCL,2048) = 0
            OR 999999 < (SELECT TO_NUMBER(VALUE)
                           FROM V$SYSTEM_PARAMETER
                          WHERE NAME = '_automatic_maintenance_test'))
         AND C.CID_KETCL = OP.CID_KETOP
         AND TR.OPERATION_ID = OP.OPID_KETOP
         AND TR.CURR_JOB_NAME = SJ.JOB_NAME
         AND TR.TARGET_TYPE = TG.TID_KETTG;


CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_CLIENT_JOB
   FOR sys.DBA_AUTOTASK_CLIENT_JOB;
GRANT select on DBA_AUTOTASK_CLIENT_JOB TO select_catalog_role;

comment on table DBA_AUTOTASK_CLIENT_JOB is
 'Current automated maintenance jobs';

comment on column DBA_AUTOTASK_CLIENT_JOB.CLIENT_NAME is
 'Client name';

comment on column DBA_AUTOTASK_CLIENT_JOB.JOB_NAME is
 'Job name';

comment on column DBA_AUTOTASK_CLIENT_JOB.JOB_SCHEDULER_STATUS is 
 'Jobs Scheduling Status';

comment on column DBA_AUTOTASK_CLIENT_JOB.TASK_NAME is
 'Program associated with the job'; 

comment on column DBA_AUTOTASK_CLIENT_JOB.TASK_TARGET_TYPE is 
 'Kind of target being processed';

comment on column DBA_AUTOTASK_CLIENT_JOB.TASK_TARGET_NAME is 
 'Name of target';

comment on column DBA_AUTOTASK_CLIENT_JOB.TASK_PRIORITY is 
 'Task level prority';

comment on column DBA_AUTOTASK_CLIENT_JOB.TASK_OPERATION is
 'Operation name';

--
-- This view is mainly designed for use by EM. For each Enabled 
-- Maintenance Window we want to provide 'Enabled' or 'Disabled' indicator 
-- for each AUTOTASK client. 
--
CREATE OR REPLACE VIEW DBA_AUTOTASK_WINDOW_CLIENTS 
     (WINDOW_NAME,      
      WINDOW_NEXT_TIME,  -- next scheduled window open time
      WINDOW_ACTIVE,
      AUTOTASK_STATUS,
      OPTIMIZER_STATS,      
      SEGMENT_ADVISOR,      
--      SEGMENT_SHRINK,
      SQL_TUNE_ADVISOR,
      HEALTH_MONITOR
--   , ONLINE_BACKUP
    )
AS
  SELECT * FROM ( 
     WITH L AS (SELECT X.CID_KETCL AS CLIENT_ID, 
                       G.WINDOW_NAME 
                  FROM DBA_SCHEDULER_WINGROUP_MEMBERS G, 
                       X$KETCL X,
                       KET$_CLIENT_CONFIG CC
                  WHERE G.WINDOW_GROUP_NAME = X.WGRP_KETCL
                    AND X.CID_KETCL = CC.CLIENT_ID
                    AND CC.OPERATION_ID = 0
                    AND BITAND(X.ATTR_KETCL, 2048) = 0
                    AND CC.STATUS = 2
                    AND dbms_auto_task.get_client_status_override(
                          CC.CLIENT_ID) = 0) ,
          M AS (SELECT W.WINDOW_NAME, 
                       W.NEXT_START_DATE,
                       W.ACTIVE
                  FROM DBA_SCHEDULER_WINDOWS W,
                       DBA_SCHEDULER_WINGROUP_MEMBERS G
                 WHERE W.ENABLED = 'TRUE'
                   AND W.WINDOW_NAME = G.WINDOW_NAME 
                   AND G.WINDOW_GROUP_NAME = 'MAINTENANCE_WINDOW_GROUP')
SELECT M.WINDOW_NAME WINDOW_NAME, 
       M.NEXT_START_DATE WINDOW_NEXT_TIME, 
       M.ACTIVE WINDOW_ACTIVE,
       DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 0 
                  AND L.WINDOW_NAME = M.WINDOW_NAME), 
              0, 'DISABLED', 'ENABLED') AS AUTOTASK_STATUS,
       DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 4 
                  AND L.WINDOW_NAME = M.WINDOW_NAME), 
              0, 'DISABLED', 'ENABLED') AS OPTIMIZER_STATS,
       DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 5 
                  AND L.WINDOW_NAME = M.WINDOW_NAME), 
              0, 'DISABLED', 'ENABLED') AS SEGMENT_ADVISOR,
--     DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 3
--                AND L.WINDOW_NAME = M.WINDOW_NAME),
--            0, 'DISABLED', 'ENABLED') AS SEGMENT_SHRINK,
       DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 6
                  AND L.WINDOW_NAME = M.WINDOW_NAME), 
              0, 'DISABLED', 'ENABLED') AS SQL_TUNE_ADVISOR,
       DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 7 
                  AND L.WINDOW_NAME = M.WINDOW_NAME), 
              0, 'DISABLED', 'ENABLED') AS HEALTH_MONITOR
--    , DECODE((SELECT COUNT(*) FROM L WHERE CLIENT_ID = 6 
--                AND L.WINDOW_NAME = M.WINDOW_NAME), 
--            0, 'DISABLED', 'ENABLED') AS ONLINE_BACKUP
  FROM M);

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_WINDOW_CLIENTS
   FOR sys.DBA_AUTOTASK_WINDOW_CLIENTS;

GRANT select on DBA_AUTOTASK_WINDOW_CLIENTS TO select_catalog_role;

comment on table DBA_AUTOTASK_WINDOW_CLIENTS is
 'Description of per-mainteance window activity';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.WINDOW_NAME is
 'Maintenance window name';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.WINDOW_NEXT_TIME is
 'Next scheduled time for the maintenance window';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.WINDOW_ACTIVE is
 'Window currently active (open)';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.AUTOTASK_STATUS is
 'Status of AUTOTASK Subsystem';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.OPTIMIZER_STATS is
 'Status of Optimizer Statistics Gathering';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.SEGMENT_ADVISOR is
 'Status of Space Advisor';

-- comment on column DBA_AUTOTASK_WINDOW_CLIENTS.SEGMENT_SHRINK is
--  'Status of Automatic Segment Shrink';

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.SQL_TUNE_ADVISOR is
 'Status of Automatic SQL Tuning Advisor'

comment on column DBA_AUTOTASK_WINDOW_CLIENTS.HEALTH_MONITOR is
 'Status of Automatic Health Monitor';

-- comment on column DBA_AUTOTASK_WINDOW_CLIENTS.ONLINE_BACKUP is
--  'Status of Automatic On-Line Backup';


CREATE OR REPLACE VIEW DBA_AUTOTASK_WINDOW_HISTORY(
      WINDOW_NAME,
      WINDOW_START_TIME,
      WINDOW_END_TIME)
AS 
   SELECT WINDOW_NAME,
          LOG_DATE AS WINDOW_START_TIME,
          COALESCE(GREATEST((SELECT MIN(WCLOSE.LOG_DATE)
                            FROM DBA_SCHEDULER_WINDOW_LOG WCLOSE
                           WHERE WCLOSE.OPERATION='CLOSE'
                             AND WCLOSE.WINDOW_NAME = WOPEN.WINDOW_NAME
                             AND WCLOSE.LOG_DATE > WOPEN.LOG_DATE
                         ),
                         (SELECT MIN(WNEXT.LOG_DATE)
                            FROM DBA_SCHEDULER_WINDOW_LOG WNEXT
                           WHERE WNEXT.OPERATION='OPEN'
                             AND WNEXT.LOG_DATE >= WOPEN.LOG_DATE
                         )),
                   (SELECT SYSTIMESTAMP 
                      FROM DBA_SCHEDULER_WINDOWS W 
                     WHERE W.WINDOW_NAME =  WOPEN.WINDOW_NAME 
                       AND W.ACTIVE = 'TRUE'),
                   (SELECT MIN(STARTUP_TIME)
                      FROM GV$INSTANCE I
                     WHERE I.STARTUP_TIME > WOPEN.LOG_DATE
                       AND I.STATUS = 'OPEN'),
                   SYSTIMESTAMP) AS WINDOW_END_TIME
        FROM DBA_SCHEDULER_WINDOW_LOG WOPEN
        WHERE WOPEN.OPERATION='OPEN';

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_WINDOW_HISTORY
   FOR sys.DBA_AUTOTASK_WINDOW_HISTORY;
GRANT select on DBA_AUTOTASK_WINDOW_HISTORY TO select_catalog_role;

comment on table DBA_AUTOTASK_WINDOW_HISTORY is
  'Automated Maintenance view of window history';

comment on column DBA_AUTOTASK_WINDOW_HISTORY.WINDOW_NAME is
  'Name of the window';

comment on column DBA_AUTOTASK_WINDOW_HISTORY.WINDOW_START_TIME is
  'Start time of the window';

comment on column DBA_AUTOTASK_WINDOW_HISTORY.WINDOW_END_TIME is
  'End time of the window';

--
-- This view provides client job history, mainly for EM.
--
CREATE OR REPLACE VIEW DBA_AUTOTASK_CLIENT_HISTORY
     (CLIENT_NAME,
      WINDOW_NAME,
      WINDOW_START_TIME,
      WINDOW_DURATION,
      JOBS_CREATED,
      JOBS_STARTED,
      JOBS_COMPLETED,
      WINDOW_END_TIME)
AS
     SELECT X.CNAME_KETCL,
            WLOG.WINDOW_NAME,
            WLOG.WINDOW_START_TIME,
            WLOG.WINDOW_END_TIME - WLOG.WINDOW_START_TIME
                AS WINDOW_DURATION,
            SUM(CASE WHEN OPERATION = 'ENABLE' 
                THEN 1 ELSE 0 END) AS JOBS_CREATED, 
            SUM(CASE WHEN OPERATION = 'RUN'
                THEN 1 ELSE 0 END) AS JOBS_STARTED,
            SUM(CASE WHEN OPERATION = 'RUN' AND STATUS = 'SUCCEEDED'
                THEN 1 ELSE 0 END) AS JOBS_COMPLETED,
            WLOG.WINDOW_END_TIME
       FROM X$KETCL X,
            DBA_SCHEDULER_JOB_LOG JL,
            DBA_AUTOTASK_WINDOW_HISTORY WLOG
      WHERE (BITAND(X.ATTR_KETCL,2048) = 0
          OR 999999 < (SELECT TO_NUMBER(VALUE)
                         FROM V$SYSTEM_PARAMETER
                        WHERE NAME = '_automatic_maintenance_test'))
        AND X.CID_KETCL > 0
        AND JL.JOB_CLASS IN (X.HJC_KETCL,X.UJC_KETCL,X.MJC_KETCL)
        AND JL.LOG_DATE BETWEEN WLOG.WINDOW_START_TIME
                            AND WLOG.WINDOW_END_TIME
      GROUP BY X.CNAME_KETCL, WLOG.WINDOW_NAME, WLOG.WINDOW_START_TIME,
               WLOG.WINDOW_END_TIME - WLOG.WINDOW_START_TIME,
                WLOG.WINDOW_END_TIME
        ;

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_CLIENT_HISTORY
   FOR sys.DBA_AUTOTASK_CLIENT_HISTORY;
GRANT select on DBA_AUTOTASK_CLIENT_HISTORY TO select_catalog_role;

comment on table DBA_AUTOTASK_CLIENT_HISTORY is
  'Automated Maintenance Jobs history';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.CLIENT_NAME is
  'Name of the Automated Maintenance Client';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.WINDOW_NAME is
  'Name of the Maintenance Window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.WINDOW_START_TIME is
  'Start time of the Maintenance Window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.WINDOW_DURATION is
  'Duration of the Maintenance Window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.JOBS_CREATED is
  'Number of Maintenance Jobs created during the window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.JOBS_STARTED is
  'Number of Maintenance Jobs that were run during the window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.JOBS_COMPLETED is
  'Number of Maintenance Jobs that were completed during the window';

comment on column DBA_AUTOTASK_CLIENT_HISTORY.WINDOW_END_TIME is
  'End time of the Maintenance Window';

/* detailed history of autotask jobs */
CREATE OR REPLACE VIEW DBA_AUTOTASK_JOB_HISTORY
  (CLIENT_NAME, WINDOW_NAME, WINDOW_START_TIME, WINDOW_DURATION,
   JOB_NAME, JOB_STATUS, JOB_START_TIME, JOB_DURATION, JOB_ERROR, JOB_INFO) 
  AS
     SELECT X.CNAME_KETCL,
            WLOG.WINDOW_NAME,
            WLOG.WINDOW_START_TIME,
            WLOG.WINDOW_END_TIME - WLOG.WINDOW_START_TIME
                AS WINDOW_DURATION,
            JD.JOB_NAME,
            JD.STATUS,
            JD.ACTUAL_START_DATE,
            JD.RUN_DURATION,
            JD.ERROR#,
            JD.ADDITIONAL_INFO
     FROM DBA_SCHEDULER_JOB_RUN_DETAILS JD,
          X$KETCL X,
          DBA_AUTOTASK_WINDOW_HISTORY WLOG
     WHERE JD.JOB_NAME LIKE 'ORA$AT_'|| X.CTAG_KETCL||'%'
       AND JD.OWNER = 'SYS'
       AND JD.ACTUAL_START_DATE BETWEEN WLOG.WINDOW_START_TIME AND WLOG.WINDOW_END_TIME
       AND (BITAND(X.ATTR_KETCL,2048) = 0
            OR 999999 < (SELECT TO_NUMBER(VALUE)
                           FROM V$SYSTEM_PARAMETER
                          WHERE NAME = '_automatic_maintenance_test'))
       AND X.CID_KETCL > 0;


CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_JOB_HISTORY 
   FOR SYS.DBA_AUTOTASK_JOB_HISTORY;

GRANT select on DBA_AUTOTASK_JOB_HISTORY TO select_catalog_role;

comment on table DBA_AUTOTASK_JOB_HISTORY is
  'Automated Maintenance Jobs history';

comment on column DBA_AUTOTASK_JOB_HISTORY.CLIENT_NAME is
  'Name of the Automated Maintenance Client';

comment on column DBA_AUTOTASK_JOB_HISTORY.WINDOW_NAME is
  'Name of the Maintenance Window';

comment on column DBA_AUTOTASK_JOB_HISTORY.WINDOW_START_TIME is
  'Start time of the Maintenance Window';

comment on column DBA_AUTOTASK_JOB_HISTORY.WINDOW_DURATION is
  'Duration of the Maintenance Window';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_NAME is
  'Name of the maintenance job';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_STATUS is
  'Status of the maintenance job';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_START_TIME is
  'Start time of the Maintenance Job';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_DURATION is
  'Duration of the Maintenance Job';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_ERROR is
  'Error code (if any) for the job';

comment on column DBA_AUTOTASK_JOB_HISTORY.JOB_INFO is
  'Additional information about the job';

CREATE OR REPLACE VIEW DBA_AUTOTASK_CLIENT (
      CLIENT_NAME,
      STATUS,
      CONSUMER_GROUP, 
      CLIENT_TAG,
      PRIORITY_OVERRIDE,
      ATTRIBUTES,
      WINDOW_GROUP,
      SERVICE_NAME,
      RESOURCE_PERCENTAGE,
      USE_RESOURCE_ESTIMATES,
      MEAN_JOB_DURATION,
      MEAN_JOB_CPU,
      MEAN_JOB_ATTEMPTS,
      MEAN_INCOMING_TASKS_7_DAYS,
      MEAN_INCOMING_TASKS_30_DAYS,
      TOTAL_CPU_LAST_7_DAYS,
      TOTAL_CPU_LAST_30_DAYS,
      MAX_DURATION_LAST_7_DAYS,
      MAX_DURATION_LAST_30_DAYS,
      WINDOW_DURATION_LAST_7_DAYS,
      WINDOW_DURATION_LAST_30_DAYS)
AS 
 SELECT * FROM (
   WITH ZH AS (SELECT * FROM DBA_AUTOTASK_CLIENT_HISTORY
                        WHERE WINDOW_END_TIME > (SYSDATE - INTERVAL ' 720' HOUR))
   SELECT C.CNAME_KETCL,
          DECODE(dbms_auto_task.get_client_status_override(CR.CLIENT_ID),
                 1, 'DISABLED', 
                 decode(CR.STATUS, 2, 'ENABLED',  1, 'DISABLED', 'INVALID')) 
            AS STATUS,
          (SELECT SJC.RESOURCE_CONSUMER_GROUP 
             FROM DBA_SCHEDULER_JOB_CLASSES SJC
            WHERE C.HJC_KETCL = SJC.JOB_CLASS_NAME) AS RESOURCE_CONSUMER_GROUP,
          C.CTAG_KETCL AS CLIENT_TAG,
          DECODE(CR.PRIORITY_OVERRIDE,
                     NULL, NULL,
                     1, 'MEDIUM',
                     2, 'HIGH',
                     3, 'URGENT','INVALID') AS PRIORITY_OVERRIDE,
          DBMS_AUTO_TASK.DECODE_ATTRIBUTES(
            DBMS_AUTO_TASK.RECONCILE_ATTRIBUTES(C.ATTR_KETCL, 
                        CR.ATTRIBUTES, 0, 0, 0, 0)) AS ATTRIBUTES,
          C.WGRP_KETCL AS WINDOW_GROUP,
          CR.SERVICE_NAME,
          (SELECT CPU_P1+CPU_P2+CPU_P3+CPU_P4+CPU_P5+CPU_P6+CPU_P7+CPU_P8
             FROM DBA_RSRC_PLAN_DIRECTIVES RPD, 
                  DBA_SCHEDULER_JOB_CLASSES SJC
            WHERE RPD.PLAN = 'ORA$AUTOTASK_HIGH_SUB_PLAN'
              AND RPD.GROUP_OR_SUBPLAN = SJC.RESOURCE_CONSUMER_GROUP
              AND SJC.JOB_CLASS_NAME = C.HJC_KETCL) AS RESOURCE_PERCENTAGE,
          CASE BITAND(21,
                         DBMS_AUTO_TASK.RECONCILE_ATTRIBUTES(C.ATTR_KETCL, 
                                    CR.ATTRIBUTES, 0, 0, 0, 0))
          WHEN 0 THEN 'TRUE' 
          ELSE 'FALSE' END AS USE_RESOURCE_ESTIMATES,
          (SELECT NUMTODSINTERVAL(AVG((EXTRACT(DAY 
                                         FROM JRD.RUN_DURATION)*24*60*60)
                       + (EXTRACT(HOUR FROM JRD.RUN_DURATION)*60*60)
                       + (EXTRACT(MINUTE FROM JRD.RUN_DURATION)*60)
                       + EXTRACT(SECOND FROM JRD.RUN_DURATION)),'SECOND')
             FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                  DBA_SCHEDULER_JOB_LOG JL 
            WHERE JL.JOB_CLASS IN
                     (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
              AND JL.LOG_ID = JRD.LOG_ID) AS MEAN_JOB_DURATION,
          (SELECT NUMTODSINTERVAL(AVG((EXTRACT(DAY FROM JRD.CPU_USED)*24*60*60)
                       + (EXTRACT(HOUR FROM JRD.CPU_USED)*60*60)
                       + (EXTRACT(MINUTE FROM JRD.CPU_USED)*60)
                       + EXTRACT(SECOND FROM JRD.CPU_USED)),'SECOND')
             FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                  DBA_SCHEDULER_JOB_LOG JL 
            WHERE JL.JOB_CLASS IN 
                       (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
              AND JL.LOG_ID = JRD.LOG_ID) AS MEAN_JOB_CPU,
           (SELECT AVG(TR.RETRY_COUNT) 
              FROM KET$_CLIENT_TASKS TR
             WHERE C.CID_KETCL = TR.CLIENT_ID)
              AS MEAN_JOB_ATTEMPTS,
           (SELECT SUM(JOBS_CREATED)/CASE COUNT(CH.WINDOW_NAME) WHEN 0 THEN 1 
                                   ELSE COUNT(CH.WINDOW_NAME) END
              FROM ZH CH
             WHERE CH.CLIENT_NAME = C.CNAME_KETCL
               AND CH.JOBS_CREATED <> 0
               AND CH.WINDOW_START_TIME > (SYSDATE -INTERVAL '168' HOUR))
                  AS MEAN_INCOMING_TASKS_7_DAY, 
           (SELECT SUM(JOBS_CREATED)/CASE COUNT(CH.WINDOW_NAME) WHEN 0 THEN 1 
                                   ELSE COUNT(CH.WINDOW_NAME) END
              FROM ZH CH
             WHERE CH.CLIENT_NAME = C.CNAME_KETCL
               AND CH.JOBS_CREATED <> 0
               AND CH.WINDOW_START_TIME > (SYSDATE -INTERVAL '720' HOUR))
                 AS MEAN_INCOMING_TASKS_30_DAY,  
          (SELECT NUMTODSINTERVAL(SUM((EXTRACT(DAY FROM JRD.CPU_USED)*24*60*60)
                       + (EXTRACT(HOUR FROM JRD.CPU_USED)*60*60)
                       + (EXTRACT(MINUTE FROM JRD.CPU_USED)*60)
                       + EXTRACT(SECOND FROM JRD.CPU_USED)),'SECOND')
              FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                   DBA_SCHEDULER_JOB_LOG JL
             WHERE JL.JOB_CLASS IN 
                       (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
               AND JL.LOG_ID = JRD.LOG_ID 
               AND JRD.LOG_DATE > (SYSDATE - INTERVAL '168' HOUR))
                               AS TOTAL_CPU_LAST_7_DAYS,
          (SELECT NUMTODSINTERVAL(SUM((EXTRACT(DAY FROM JRD.CPU_USED)*24*60*60)
                       + (EXTRACT(HOUR FROM JRD.CPU_USED)*60*60)
                       + (EXTRACT(MINUTE FROM JRD.CPU_USED)*60)
                       + EXTRACT(SECOND FROM JRD.CPU_USED)),'SECOND')
              FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                   DBA_SCHEDULER_JOB_LOG JL
             WHERE JL.JOB_CLASS IN
                       (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
               AND JL.LOG_ID = JRD.LOG_ID 
               AND JRD.LOG_DATE > (SYSDATE - INTERVAL '720' HOUR))  
                               AS TOTAL_CPU_LAST_30_DAYS,
           (SELECT MAX(JRD.RUN_DURATION)
              FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                   DBA_SCHEDULER_JOB_LOG JL 
             WHERE JL.JOB_CLASS IN 
                       (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
               AND JL.LOG_ID = JRD.LOG_ID 
               AND JRD.LOG_DATE > (SYSDATE - INTERVAL '168' HOUR))  
                                AS MAX_DURATION_LAST_7_DAYS,
           (SELECT MAX(JRD.RUN_DURATION)
              FROM DBA_SCHEDULER_JOB_RUN_DETAILS JRD, 
                    DBA_SCHEDULER_JOB_LOG JL 
             WHERE JL.JOB_CLASS IN 
                       (C.UJC_KETCL, C.HJC_KETCL, C.MJC_KETCL) 
               AND JL.LOG_ID = JRD.LOG_ID 
               AND JRD.LOG_DATE > (SYSDATE - INTERVAL '720' HOUR))  
                                AS MAX_DURATION_LAST_30_DAYS,
          (SELECT NUMTODSINTERVAL(SUM(
                     (EXTRACT(DAY FROM CH.WINDOW_DURATION)*24*60*60)
                     + (EXTRACT(HOUR FROM CH.WINDOW_DURATION)*60*60)
                     + (EXTRACT(MINUTE FROM CH.WINDOW_DURATION)*60)
                     + EXTRACT(SECOND FROM CH.WINDOW_DURATION)),
                   'SECOND')
              FROM ZH CH
             WHERE CH.CLIENT_NAME = C.CNAME_KETCL
               AND CH.JOBS_CREATED > 0
               AND CH.WINDOW_END_TIME > (SYSDATE - INTERVAL '168' HOUR)) 
                  AS WINDOW_DURATION_LAST_7_DAYS,
          (SELECT NUMTODSINTERVAL(SUM(
                     (EXTRACT(DAY FROM CH.WINDOW_DURATION)*24*60*60)
                     + (EXTRACT(HOUR FROM CH.WINDOW_DURATION)*60*60)
                     + (EXTRACT(MINUTE FROM CH.WINDOW_DURATION)*60)
                     + EXTRACT(SECOND FROM CH.WINDOW_DURATION)),
                   'SECOND')
              FROM ZH CH
             WHERE CH.CLIENT_NAME = C.CNAME_KETCL
               AND CH.JOBS_CREATED > 0
               AND CH.WINDOW_END_TIME > (SYSDATE - INTERVAL ' 720' HOUR)) 
                  AS WINDOW_DURATION_LAST_30_DAYS
     FROM X$KETCL C, KET$_CLIENT_CONFIG CR
    WHERE C.CID_KETCL = CR.CLIENT_ID
      AND CR.OPERATION_ID = 0
      AND C.CID_KETCL > 0
      AND (BITAND(C.ATTR_KETCL,2048) = 0
          OR 999999 < (SELECT TO_NUMBER(VALUE)
                         FROM V$SYSTEM_PARAMETER
                        WHERE NAME = '_automatic_maintenance_test')));

CREATE OR REPLACE PUBLIC SYNONYM DBA_AUTOTASK_CLIENT
   FOR sys.DBA_AUTOTASK_CLIENT;
GRANT select on DBA_AUTOTASK_CLIENT TO select_catalog_role;


comment on table DBA_AUTOTASK_CLIENT is
 'Autotask Client Summary Information';

comment on column DBA_AUTOTASK_CLIENT.CLIENT_NAME is
 'Name of Automated Maintenance Tasks Client';

comment on column DBA_AUTOTASK_CLIENT.STATUS is
 'Current status of the Client';

comment on column DBA_AUTOTASK_CLIENT.CONSUMER_GROUP is 
 'Resource Consumer Group normaly used to execute jobs';

comment on column DBA_AUTOTASK_CLIENT.CLIENT_TAG is
 'Tag used in forming job names';

comment on column DBA_AUTOTASK_CLIENT.PRIORITY_OVERRIDE is
 'Priority override for jobs';

comment on column DBA_AUTOTASK_CLIENT.ATTRIBUTES is
 'Client Attributes'; 

comment on column DBA_AUTOTASK_CLIENT.WINDOW_GROUP is
 'Window group used to schedule jobs';

comment on column DBA_AUTOTASK_CLIENT.SERVICE_NAME is
 'Service on which jobs will execute';

comment on column DBA_AUTOTASK_CLIENT.RESOURCE_PERCENTAGE is
 'Percentage of maintenance resources for the client';

comment on column DBA_AUTOTASK_CLIENT.USE_RESOURCE_ESTIMATES is
 'Indicates if resource estimates are uesd for this client';

comment on column DBA_AUTOTASK_CLIENT.MEAN_JOB_DURATION is
 'Average job duration for this client';

comment on column DBA_AUTOTASK_CLIENT.MEAN_JOB_CPU is
 'Average CPU time consumed by jobs';

comment on column DBA_AUTOTASK_CLIENT.MEAN_JOB_ATTEMPTS is
 'Average number of attempts to execute the job successfully';

comment on column DBA_AUTOTASK_CLIENT.MEAN_INCOMING_TASKS_7_DAYS is
 'Average number of tasks over last 7 days';

comment on column DBA_AUTOTASK_CLIENT.MEAN_INCOMING_TASKS_30_DAYS is
 'Average number of tasks over last 30 days';

comment on column DBA_AUTOTASK_CLIENT.TOTAL_CPU_LAST_7_DAYS is
 'Cumulative CPU usage over last 7 days';

comment on column DBA_AUTOTASK_CLIENT.TOTAL_CPU_LAST_30_DAYS is
 'Cumulative CPU usage over last 30 days';

comment on column DBA_AUTOTASK_CLIENT.MAX_DURATION_LAST_7_DAYS is
 'Longest running job over last 7 days';

comment on column DBA_AUTOTASK_CLIENT.MAX_DURATION_LAST_30_DAYS is
 'Longest running job over last 30 days';

comment on column DBA_AUTOTASK_CLIENT.WINDOW_DURATION_LAST_7_DAYS is
 'Cumulative maintenance window duration over last 7 days';

comment on column DBA_AUTOTASK_CLIENT.WINDOW_DURATION_LAST_30_DAYS is  
 'Cumulative maintenance window duration over last 30 days';


Rem 
Rem AWR views that use packages
@@catawrpd.sql

Rem sqltune views: sqlprofile/sqlset/sqltune advisor
@@catsqltv.sql

Rem
Rem Load the SQL Access Advisor views
Rem
@@catsumaa

Rem Create dbms_auto_Task_export export package body
@@prvtatxp.plb

