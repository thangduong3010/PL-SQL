Rem
Rem $Header: catnoalr.sql 26-jan-2004.17:26:11 jxchen Exp $
Rem $Header: catnoalr.sql 26-jan-2004.17:26:11 jxchen Exp $
Rem
Rem catnoalr.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catnoalr.sql - Remove server ALeRt schema
Rem
Rem    DESCRIPTION
Rem      Catalog script for server alert.  Used to drop server alert schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jxchen      01/26/04 - Fix bug 339578: use "FORCE" option to drop 
Rem    aime        04/25/03 - aime_going_to_main
Rem    jxchen      04/02/03 - Move threshold table to sysaux
Rem    jxchen      01/21/03 - Drop synonym for v$ views
Rem    jxchen      11/14/02 - jxchen_alrt1
Rem    jxchen      11/13/02 - Add dbms_server_alert package
Rem    jxchen      11/11/02 - Add alert views
Rem    jxchen      10/24/02 - Add alert threshold table
Rem    jxchen      10/16/02 - Created
Rem

DROP TABLE sys.wri$_alert_outstanding;
DROP TABLE sys.wri$_alert_history;
DROP SEQUENCE sys.wri$_alert_sequence;

BEGIN
dbms_aqadm.stop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue_table('SYS.ALERT_QT');
commit;
END;
/

DECLARE
  agent SYS.AQ$_AGENT;
BEGIN
  agent := SYS.AQ$_AGENT('server_alert', NULL, NULL);
  dbms_aqadm.drop_aq_agent('server_alert');
END;
/

DROP TYPE sys.alert_type FORCE;

DROP TABLE sys.wri$_alert_threshold;

DROP TYPE sys.threshold_type force;

DROP TYPE sys.threshold_type_set force;

DROP TABLE sys.wri$_alert_threshold_log;

DROP SEQUENCE sys.wri$_alert_thrslog_sequence;

DROP PUBLIC SYNONYM dba_outstanding_alerts;

DROP VIEW sys.dba_outstanding_alerts;

DROP PUBLIC SYNONYM dba_alert_history;

DROP VIEW sys.dba_alert_history;

DROP PACKAGE sys.dbms_server_alert;

DROP VIEW sys.dba_thresholds;

DROP PUBLIC SYNONYM dba_thresholds;

DROP VIEW v_$alert_types;

DROP VIEW v_$threshold_types;

DROP PUBLIC SYNONYM v$alert_types;

DROP PUBLIC SYNONYM v$threshold_types;
