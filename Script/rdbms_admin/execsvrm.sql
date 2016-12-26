Rem
Rem $Header: rdbms/admin/execsvrm.sql /main/3 2008/12/11 08:34:08 ilistvin Exp $
Rem
Rem execsvrm.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      execsvrm.sql - EXECute SerVeR Manageablity PL/SQL blocks
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    11/10/08 - set default thresholds for temp and undo
Rem                           tablespaces
Rem    ilistvin    01/05/07 - move procedure invocations from prvtawr.sql
Rem    ilistvin    11/15/06 - register feature usage here
Rem    ilistvin    11/08/06 - merge in catmwin.sql
Rem    ilistvin    11/08/06 - merge in AUTOTASK init code
Rem    mlfeng      10/31/06 - merge in Alert initialization
Rem    rburns      09/16/06 - execute SVRM packages
Rem    rburns      09/16/06 - Created
Rem

-- Set the default database thresholds
BEGIN
dbms_server_alert.set_threshold(9000,null,null,null,null,1,1,'',5,'');
EXCEPTION
  when others then
    if sqlcode = -00001 then NULL;         -- unique constraint error
    else raise;
    end if;
END;
/
Rem 
Rem For all UNDO and TEMPORARY tablespaces for which there is no
Rem explicit threshold set, create an explicit "Do Not Check" threshold
Rem
DECLARE
  tbsname VARCHAR2(30);
  CURSOR tbs IS
    SELECT tablespace_name 
      FROM dba_tablespaces
     WHERE extent_management = 'LOCAL'
       AND contents IN ('TEMPORARY','UNDO')
       AND tablespace_name NOT IN 
                  (SELECT object_name
                     FROM table(dbms_server_alert.view_thresholds)
                    WHERE object_type = 5
                      AND object_name IS NOT NULL
                      AND metrics_id IN (9000, 9001));
BEGIN
  OPEN tbs;
  LOOP
    FETCH tbs INTO tbsname;
    EXIT WHEN tbs%NOTFOUND;
    BEGIN
      dbms_server_alert.set_threshold(dbms_server_alert.TABLESPACE_PCT_FULL
                                    , dbms_server_alert.OPERATOR_DO_NOT_CHECK
                                    , '<SYSTEM-GENERATED THRESHOLD>'  
                                    , dbms_server_alert.OPERATOR_DO_NOT_CHECK
                                    , '0'  -- critical value
                                    , 0    -- observation period 
                                    , 0    -- consecutive occurrences 
                                    , NULL -- instance name
                                    , dbms_server_alert.OBJECT_TYPE_TABLESPACE
                                    , tbsname);
    EXCEPTION WHEN OTHERS THEN 
      RAISE;
    END;
  END LOOP;
  CLOSE tbs;
EXCEPTION WHEN OTHERS THEN RAISE;
END;
/  
  
-- Register export package as a sysstem export action
DELETE FROM exppkgact$ WHERE package = 'DBMS_SERVER_ALERT_EXPORT'
/
INSERT INTO exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SERVER_ALERT_EXPORT', 'SYS', 1, 1000)
/
commit
/


DECLARE
  DUPLICATE_KEY exception;
  pragma EXCEPTION_INIT(DUPLICATE_KEY, -1);
BEGIN
--
-- Initialize AUTOTASK status
-- (dummy_key prevents > 1 row from being inserted)
--
 INSERT INTO KET$_AUTOTASK_STATUS(DUMMY_KEY, AUTOTASK_STATUS,ABA_STATE)
 VALUES (99999, 2, 99);
EXCEPTION
  WHEN DUPLICATE_KEY THEN NULL;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  DUPLICATE_KEY exception;
  pragma EXCEPTION_INIT(DUPLICATE_KEY, -1);
BEGIN
--
-- Insert a row for AUTOTASK itself (always enabled)
--
INSERT INTO KET$_CLIENT_CONFIG (CLIENT_ID, OPERATION_ID, STATUS)
 VALUES (0,0,2);
--
-- All other clients are enabled if ONBYDEFAULT (256) is set
--
INSERT INTO KET$_CLIENT_CONFIG (CLIENT_ID, OPERATION_ID, STATUS, ATTRIBUTES)
 SELECT CID_KETCL, 0,
        CASE BITAND(ATTR_KETCL,256) WHEN 0 THEN 1 ELSE 2 END, BITAND(ATTR_KETCL,63)
   FROM  X$KETCL
  WHERE CID_KETCL > 0;
EXCEPTION
  WHEN DUPLICATE_KEY THEN NULL;
  WHEN OTHERS THEN RAISE;
END;
/

Rem
Rem Setup the advisor repository
Rem

execute dbms_advisor.setup_repository;


Rem SQL Tuning Advisor initialization of Automatic Task
@@execsqlt.sql

/* register all the features and high water marks */
begin
  DBMS_FEATURE_REGISTER_ALLFEAT;
  DBMS_FEATURE_REGISTER_ALLHWM;
end;
/
--
-- Execute call to register the local DBID in AWR
--
BEGIN
  /* register the local database into AWR */
  dbms_swrf_internal.register_local_dbid;
END;
/

--
-- Execute the call to insert the baseline details
-- We call this because we introduce the new WRM$_BASELINE_DETAILS table
-- in 11g, and rows need to be inserted during upgrade (catproc.sql)
--
BEGIN
  /* insert the baseline details */
  dbms_swrf_internal.insert_baseline_details;
END;
/
