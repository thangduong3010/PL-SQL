Rem
Rem $Header: catalrt.sql 10-nov-2006.08:58:28 ilistvin Exp $
Rem
Rem catalrt.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catalrt.sql - Catalog script for server ALeRT 
Rem
Rem    DESCRIPTION
Rem      Creates tables for server alert 
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      09/16/06 - split for new catproc
Rem    ilistvin    08/29/06 - extend execution_context_id to 128
Rem    kneel       06/03/06 - moving execution of prvthdbu.sql to catpdbms.sql 
Rem    bpwang      10/05/05 - move alert_type and threshold_type to dbmsslrt,
Rem                           move loading of dbmsslrt to catproc.sql
Rem    ysarig      12/02/04 - bug 3930796 - comment for ALERT_QUE 
Rem    ilistvin    08/13/04 - add METRIC_VALUE_TYPE column to 
Rem                           V$THRESHOLD_TYPES 
Rem    ilistvin    07/19/04 - move start_queue outide of exception block 
Rem    aahluwal    05/25/04 - [OCI Events]: load prvtbdbu/prvthdbu before 
Rem                           prvtslrt 
Rem    jxchen      12/04/03 - Increase size of instance name 
Rem    jxchen      11/17/03 - Bug 3262541 - Increase length of hosting client 
Rem    jxchen      11/05/03 - Add view to expose message arguments for 
Rem                           outstanding alerts 
Rem    jxchen      10/29/03 - Use x$keltosd for dba_thresholds view 
Rem    jxchen      09/22/03 - Add exception handler for set_threshold call 
Rem    jxchen      10/02/03 - Add serial# in alert tables 
Rem    jxchen      09/03/03 - Increase column width for some metadata columns 
Rem    jxchen      07/21/03 - Bug 3050295 - add initial time in alert history
Rem    jxchen      06/10/03 - More verbose comments for views/columns
Rem    jxchen      06/20/03 - Catch object exist error
Rem    jxchen      05/14/03 - Execute dbmsslxp threshold export package
Rem    aime        04/25/03 - aime_going_to_main
Rem    jxchen      04/30/03 - Add alert scope to alert payload
Rem    jxchen      04/02/03 - Move threshold table to SYSAUX
Rem    jxchen      03/14/03 - Use X$KEWMDSM for tablespace metric name
Rem    jxchen      03/05/03 - Add metric value in alert payload
Rem    jxchen      02/20/03 - Add comment for DBA_THRESHOLDS.STATUS
Rem    jxchen      02/17/03 - Expose flags in dba_thresholds.
Rem    jxchen      01/21/03 - Add synonym for V$ALERT_TYPES, V$THRESHOLD_TYPES
Rem    jxchen      01/14/03 - Add comments for views
Rem    jxchen      01/11/03 - Use union for dba_thresholds.
Rem    jxchen      01/09/03 - Add operators
Rem    jxchen      01/07/03 - Change column names of threshold alert table
Rem    smuthuli    01/07/03 - insert db default for tablespace alerts
Rem    jxchen      12/11/02 - Add dba_thresholds view
Rem    jxchen      11/14/02 - jxchen_alrt1
Rem    jxchen      11/13/02 - Add dbms_server_alert package
Rem    jxchen      11/11/02 - Add alert views
Rem    jxchen      10/24/02 - Add alert threshold table
Rem    jxchen      09/01/02 - Created
Rem

-- Create table of outstanding alerts
CREATE TABLE wri$_alert_outstanding(
      reason_id                NUMBER,                    
      object_id                NUMBER,                   
      subobject_id             NUMBER,
      internal_instance_number NUMBER,                  
      owner                    VARCHAR2(30),           
      object_name              VARCHAR2(513),         
      subobject_name           VARCHAR2(30),         
      sequence_id              NUMBER,              
      reason_argument_1        VARCHAR2(581),     
      reason_argument_2        VARCHAR2(581),    
      reason_argument_3        VARCHAR2(581),   
      reason_argument_4        VARCHAR2(581),            
      reason_argument_5        VARCHAR2(581),           
      time_suggested           TIMESTAMP WITH TIME ZONE,
      creation_time            TIMESTAMP WITH TIME ZONE,
      action_argument_1        VARCHAR2(30),           
      action_argument_2        VARCHAR2(30),          
      action_argument_3        VARCHAR2(30),         
      action_argument_4        VARCHAR2(30),        
      action_argument_5        VARCHAR2(30),       
      message_level            NUMBER,            
      hosting_client_id        VARCHAR2(64),     
      process_id               VARCHAR2(128),   
      host_id                  VARCHAR2(256),  
      host_nw_addr             VARCHAR2(256),  
      instance_name            VARCHAR2(16), 
      instance_number          NUMBER,      
      user_id                  VARCHAR2(30),
      execution_context_id     VARCHAR2(128),
      error_instance_id        VARCHAR2(142), 
      context                  RAW(128),    
      metric_value             NUMBER,
      CONSTRAINT wri$_alerts_outstanding_pk PRIMARY KEY (
           reason_id, 
           object_id,
           subobject_id,
           internal_instance_NUMBER)
        USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create table of alert history 
CREATE TABLE wri$_alert_history(
      sequence_id              NUMBER,       
      reason_id                NUMBER,       
      owner                    VARCHAR2(30),
      object_name              VARCHAR2(513), 
      subobject_name           VARCHAR2(30), 
      reason_argument_1        VARCHAR2(581), 
      reason_argument_2        VARCHAR2(581),
      reason_argument_3        VARCHAR2(581), 
      reason_argument_4        VARCHAR2(581),
      reason_argument_5        VARCHAR2(581),  
      time_suggested           TIMESTAMP WITH TIME ZONE,  
      creation_time            TIMESTAMP WITH TIME ZONE,
      action_argument_1        VARCHAR2(30),             
      action_argument_2        VARCHAR2(30),            
      action_argument_3        VARCHAR2(30),           
      action_argument_4        VARCHAR2(30),          
      action_argument_5        VARCHAR2(30),         
      message_level            NUMBER,              
      hosting_client_id        VARCHAR2(64),       
      process_id               VARCHAR2(128),     
      host_id                  VARCHAR2(256),    
      host_nw_addr             VARCHAR2(256),    
      instance_name            VARCHAR2(16),   
      instance_number          NUMBER,        
      user_id                  VARCHAR2(30), 
      execution_context_id     VARCHAR2(128),
      error_instance_id        VARCHAR2(142),
      resolution               NUMBER,     
      metric_value             NUMBER,
      CONSTRAINT wri$_alert_history_pk PRIMARY KEY (sequence_id)
        USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create sequence of alerts
CREATE SEQUENCE sys.wri$_alert_sequence;

-- Create table storing threshold settings
CREATE TABLE wri$_alert_threshold(
      t_object_type             NUMBER,        
      t_object_name             VARCHAR2(513), 
      t_metrics_id              NUMBER,       
      t_instance_name           VARCHAR2(16),
      t_flags                   NUMBER,     
      t_warning_operator        NUMBER,    
      t_warning_value           VARCHAR2(256), 
      t_critical_operator       NUMBER,       
      t_critical_value          VARCHAR2(256), 
      t_observation_period      NUMBER,       
      t_consecutive_occurrences NUMBER,      
      t_object_id               NUMBER,     
      CONSTRAINT wri$_alert_threshold_pk UNIQUE (
             t_object_type,
             t_object_name,
             t_metrics_id,
             t_instance_name)
      USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create the threshold log table
CREATE TABLE wri$_alert_threshold_log(
      sequence_id               NUMBER,
      object_type               NUMBER,
      object_name               VARCHAR2(513),
      object_id                 NUMBER,
      opcode                    NUMBER,
      CONSTRAINT wri$_alert_threshold_log_pk PRIMARY KEY (sequence_id)
        USING INDEX TABLESPACE system)
      TABLESPACE system;

-- Create sequence of threshold log
CREATE SEQUENCE sys.wri$_alert_thrslog_sequence;
-- v_$alert_types
CREATE OR REPLACE VIEW v_$alert_types 
  AS SELECT * FROM v$alert_types;

comment on table V_$ALERT_TYPES is
'Description of server alert types';

comment on column V_$ALERT_TYPES.REASON_ID is
'Alert reason id';

comment on column V_$ALERT_TYPES.OBJECT_TYPE is
'Object type';

comment on column V_$ALERT_TYPES.TYPE is
'Alert type (stateful vs. stateless)';

comment on column V_$ALERT_TYPES.GROUP_NAME is
'Group name (space, performance etc.)';

comment on column V_$ALERT_TYPES.SCOPE is
'Scope (database vs. instance)';

comment on column V_$ALERT_TYPES.INTERNAL_METRIC_CATEGORY is
'Internal metric category';

comment on column V_$ALERT_TYPES.INTERNAL_METRIC_NAME is
'Internal metric name'; 

CREATE OR REPLACE PUBLIC SYNONYM v$alert_types FOR v_$alert_types;
GRANT select on v_$alert_types TO select_catalog_role;

-- gv_$alert_types
CREATE OR REPLACE VIEW gv_$alert_types
  AS SELECT * FROM gv$alert_types;

comment on table GV_$ALERT_TYPES is
'Description of server alert types';

comment on column GV_$ALERT_TYPES.REASON_ID is
'Alert reason id';

comment on column GV_$ALERT_TYPES.OBJECT_TYPE is
'Object type';

comment on column GV_$ALERT_TYPES.TYPE is
'Alert type (stateful vs. stateless)';

comment on column GV_$ALERT_TYPES.GROUP_NAME is
'Group name (space, performance etc.)';

comment on column GV_$ALERT_TYPES.SCOPE is
'Scope (database vs. instance)';

comment on column GV_$ALERT_TYPES.INTERNAL_METRIC_CATEGORY is
'Internal metric category';

comment on column GV_$ALERT_TYPES.INTERNAL_METRIC_NAME is
'Internal metric name';
 
CREATE OR REPLACE PUBLIC SYNONYM gv$alert_types FOR gv_$alert_types;
GRANT select on gv_$alert_types TO select_catalog_role;

-- v_$threshold_types
CREATE OR REPLACE VIEW v_$threshold_types
  AS SELECT * FROM v$threshold_types;

comment on table V_$THRESHOLD_TYPES is
'Description of threshold types';

comment on column V_$THRESHOLD_TYPES.METRICS_ID is
'Metrics id';

comment on column V_$THRESHOLD_TYPES.METRICS_GROUP_ID is
'Metrics group id';

comment on column V_$THRESHOLD_TYPES.OPERATOR_MASK is
'Operator mask';

comment on column V_$THRESHOLD_TYPES.OBJECT_TYPE is
'Object type';

comment on column V_$THRESHOLD_TYPES.ALERT_REASON_ID is
'Alert reason id';

comment on column V_$THRESHOLD_TYPES.METRIC_VALUE_TYPE is
'Metric value type';

CREATE OR REPLACE PUBLIC SYNONYM v$threshold_types FOR v_$threshold_types;
GRANT select on v_$threshold_types TO select_catalog_role;

-- gv_$threshold_types
CREATE OR REPLACE VIEW gv_$threshold_types
  AS SELECT * FROM gv$threshold_types;

comment on table GV_$THRESHOLD_TYPES is
'Description on threshold types';

comment on column GV_$THRESHOLD_TYPES.INST_ID is
'Instance id';

comment on column GV_$THRESHOLD_TYPES.METRICS_ID is
'Metrics id';

comment on column GV_$THRESHOLD_TYPES.METRICS_GROUP_ID is
'Metrics group id';

comment on column GV_$THRESHOLD_TYPES.OPERATOR_MASK is
'Operator mask';

comment on column GV_$THRESHOLD_TYPES.OBJECT_TYPE is
'Object type';

comment on column GV_$THRESHOLD_TYPES.ALERT_REASON_ID is
'Alert reason id';

comment on column GV_$THRESHOLD_TYPES.METRIC_VALUE_TYPE is
'Metric value type';

CREATE OR REPLACE PUBLIC SYNONYM gv$threshold_types FOR gv_$threshold_types;
GRANT select on gv_$threshold_types TO select_catalog_role;

-- Create dba_alert_arguments view
CREATE OR REPLACE VIEW dba_alert_arguments
  AS SELECT sequence_id,
            mid_keltsd AS reason_message_id,
            npm_keltsd AS reason_argument_count,
            reason_argument_1,
            reason_argument_2,
            reason_argument_3,
            reason_argument_4,
            reason_argument_5,
            amid_keltsd AS action_message_id,
            anpm_keltsd AS action_argument_count,
            action_argument_1,
            action_argument_2,
            action_argument_3,
            action_argument_4,
            action_argument_5
    FROM wri$_alert_outstanding, X$KELTSD
    WHERE reason_id = rid_keltsd; 

CREATE OR REPLACE PUBLIC SYNONYM dba_alert_arguments
  FOR sys.dba_alert_arguments;
GRANT select on dba_alert_arguments TO select_catalog_role;

comment on table DBA_ALERT_ARGUMENTS is
'Message Id and arguments of outstanding alerts';

comment on column DBA_ALERT_ARGUMENTS.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_ALERT_ARGUMENTS.REASON_MESSAGE_ID is
'Id of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_COUNT is
'Number of alert reason message arguments';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_1 is
'First argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_2 is
'Second argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_3 is
'Third argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_4 is
'Fourth argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_5 is
'Fifth argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_MESSAGE_ID is
'Id of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_COUNT is
'Number of alert action message arguments';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_1 is
'First argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_2 is
'Second argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_3 is
'Third argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_4 is
'Fourth argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_5 is
'Fifth argument of alert action message';


