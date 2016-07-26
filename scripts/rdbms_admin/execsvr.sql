Rem
Rem $Header: execsvr.sql 23-oct-2006.12:31:56 arogers Exp $
Rem
Rem execsvr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execsvr.sql - run PL/sql and sql in order to define
Rem                    and activate the Kernel Service Workgroup 
Rem                    Services.   
Rem
Rem    DESCRIPTION
Rem      Defines and starts the AQ queues required to support
Rem      the Kernel Service Workgroup Services.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arogers     10/23/06 - 5572026 - issue sql instead of kswssetupaq
Rem    arogers     10/23/06 - Created
Rem

Rem Clean up any previous definitions.
BEGIN
 dbms_aqadm.remove_subscriber(queue_name=>'SYS$SERVICE_METRICS',
        subscriber=>sys.aq$_agent('SYS$RLB_GEN_SUB',null,null));
EXCEPTION
WHEN others THEN
  IF sqlcode = -24035  or sqlcode = -24010 THEN NULL;
       -- suppress error for non-existent subscriber/queue
  ELSE raise;
  END IF;
END;
/

BEGIN
 dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_GEN_TS');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24185 THEN NULL;
       -- suppress error for non-existent transformation
  ELSE raise;
  END IF;
END;
/

BEGIN
 dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_TS');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24185 THEN NULL;
       -- suppress error for non-existent transformation
  ELSE raise;
   END IF;
END;
/

BEGIN
 dbms_aqadm.stop_queue('SYS$SERVICE_METRICS');
EXCEPTION
  WHEN others THEN
  IF sqlcode = -24010 THEN NULL;
       -- suppress error for non-existent queue
  ELSE raise;
  END IF;
END;
/ 

BEGIN
 dbms_aqadm.drop_queue('SYS$SERVICE_METRICS');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24010 THEN NULL;
       -- suppress error for non-existent queue
  ELSE raise;
  END IF;
END;
/

BEGIN
 dbms_aqadm.drop_queue_table('SYS$SERVICE_METRICS_TAB');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24002 THEN NULL;
       -- suppress error for non-existent queue table
  ELSE raise;
  END IF;
END;
/

Rem Define queues, types and start.
CREATE OR REPLACE TYPE SYS$RLBTYP as object (srv VARCHAR2(1024),
  payload VARCHAR2(4000));
/

BEGIN
  DBMS_AQADM.CREATE_QUEUE_TABLE('SYS$SERVICE_METRICS_TAB', 'SYS$RLBTYP',
    'tablespace sysaux, storage (INITIAL 1M next 1M pctincrease 0)',
    NULL, TRUE);
END;
/

BEGIN
  DBMS_AQADM.CREATE_QUEUE('SYS$SERVICE_METRICS',
    'SYS$SERVICE_METRICS_TAB', retention_time => 3600);
END;
/

BEGIN
  DBMS_AQADM.START_QUEUE('SYS$SERVICE_METRICS', TRUE, TRUE);
END;
/

BEGIN
  DBMS_TRANSFORM.CREATE_TRANSFORMATION('SYS','SYS$SERVICE_METRICS_TS',
    'SYS','SYS$RLBTYP','SYS', 'VARCHAR2','source.user_data.payload');
END;
/

BEGIN
  DBMS_TRANSFORM.CREATE_TRANSFORMATION('SYS',
    'SYS$SERVICE_METRICS_GEN_TS','SYS','SYS$RLBTYP','SYS','SYS$RLBTYP',
    'source.user_data');
END;
/

DECLARE subscriber sys.aq$_agent;
BEGIN
  subscriber := sys.aq$_agent('SYS$RLB_GEN_SUB', NULL, NULL);
  dbms_aqadm_sys.add_subscriber(queue_name => 'SYS.SYS$SERVICE_METRICS',
  subscriber => subscriber,
  transformation => 'SYS.SYS$SERVICE_METRICS_GEN_TS');
END;
/
