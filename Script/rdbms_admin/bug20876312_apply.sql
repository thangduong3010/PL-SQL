Rem
Rem $Header: rdbms/admin/bug20876312_apply.sql /st_rdbms_11.2.0.4.0dbpsu/2 2015/05/12 23:28:52 ratakuma Exp $
Rem
Rem bug20876312_apply.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      bug20876312_apply.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/bug20876312_apply.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE:
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ratakuma    04/17/15 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

create or replace view USER_AUDIT_POLICIES (OBJECT_NAME, 
                        POLICY_NAME, POLICY_TEXT, POLICY_COLUMN, PF_SCHEMA, 
                        PF_PACKAGE, PF_FUNCTION, ENABLED, 
                        SEL, INS, UPD, DEL, AUDIT_TRAIL,
                        POLICY_COLUMN_OPTIONS)
as
SELECT OBJECT_NAME, POLICY_NAME, POLICY_TEXT,  POLICY_COLUMN,
       PF_SCHEMA, PF_PACKAGE, PF_FUNCTION, ENABLED,
       SEL, INS, UPD, DEL, AUDIT_TRAIL, POLICY_COLUMN_OPTIONS
FROM DBA_AUDIT_POLICIES
WHERE OBJECT_SCHEMA = SYS_CONTEXT('USERENV','CURRENT_USER')
/

create or replace view USER_AUDIT_POLICY_COLUMNS(OBJECT_SCHEMA, OBJECT_NAME,
                        POLICY_NAME, POLICY_COLUMN)
as
select OBJECT_SCHEMA, OBJECT_NAME,
       POLICY_NAME, POLICY_COLUMN
from DBA_AUDIT_POLICY_COLUMNS
WHERE OBJECT_SCHEMA = SYS_CONTEXT('USERENV','CURRENT_USER')
/

CREATE OR REPLACE VIEW user_scheduler_job_log
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, JOB_CLASS, OPERATION, STATUS, 
    USER_NAME, CLIENT_ID, GLOBAL_UID, CREDENTIAL_OWNER, CREDENTIAL_NAME,
    DESTINATION_OWNER, DESTINATION, ADDITIONAL_INFO)
  AS 
  (SELECT 
     LOG_ID, LOG_DATE, OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     co.NAME, OPERATION,e.STATUS, USER_NAME, CLIENT_ID, GUID, 
     decode(e.credential, NULL, NULL, 
        substr(e.credential, 1, instr(e.credential, '"')-1)),
     decode(e.credential, NULL, NULL,
        substr(e.credential, instr(e.credential, '"')+1,
           length(e.credential) - instr(e.credential, '"'))),
     decode(bitand(e.flags, 1), 0, NULL, 
        substr(e.destination, 1, instr(e.destination, '"')-1)),
     decode(bitand(e.flags, 1), 0, e.destination, 
        substr(e.destination, instr(e.destination, '"')+1,
           length(e.destination) - instr(e.destination, '"'))),
     ADDITIONAL_INFO
  FROM scheduler$_event_log e, obj$ co 
  WHERE e.type# = 66 and e.dbid is null and e.class_id = co.obj#(+)
  AND owner = SYS_CONTEXT('USERENV','CURRENT_USER'))
/

CREATE OR REPLACE VIEW user_scheduler_job_run_details
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, STATUS, ERROR#, REQ_START_DATE,
    ACTUAL_START_DATE, RUN_DURATION, INSTANCE_ID, SESSION_ID, SLAVE_PID,
    CPU_USED, CREDENTIAL_OWNER, CREDENTIAL_NAME, DESTINATION_OWNER,
    DESTINATION, ADDITIONAL_INFO)
  AS
  (SELECT
     j.LOG_ID, j.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     e.STATUS, j.ERROR#, j.REQ_START_DATE, j.START_DATE, j.RUN_DURATION,
     j.INSTANCE_ID, j.SESSION_ID, j.SLAVE_PID, j.CPU_USED,
     decode(e.credential, NULL, NULL,
        substr(e.credential, 1, instr(e.credential, '"')-1)),
     decode(e.credential, NULL, NULL,
        substr(e.credential, instr(e.credential, '"')+1,
           length(e.credential) - instr(e.credential, '"'))),
     decode(bitand(e.flags, 1), 0, NULL,
        substr(e.destination, 1, instr(e.destination, '"')-1)),
     decode(bitand(e.flags, 1), 0, e.destination,
        substr(e.destination, instr(e.destination, '"')+1,
           length(e.destination) - instr(e.destination, '"'))),
     j.ADDITIONAL_INFO
   FROM scheduler$_job_run_details j, scheduler$_event_log e
   WHERE j.log_id = e.log_id
   AND e.dbid is null
   AND e.type# = 66
   AND e.owner = SYS_CONTEXT('USERENV','CURRENT_USER'))
/

CREATE OR REPLACE VIEW all_scheduler_job_log
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, JOB_CLASS, OPERATION, STATUS, 
    USER_NAME, CLIENT_ID, GLOBAL_UID, CREDENTIAL_OWNER, CREDENTIAL_NAME, 
    DESTINATION_OWNER, DESTINATION, ADDITIONAL_INFO)
  AS 
  (SELECT 
     e.LOG_ID, e.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     co.NAME, OPERATION, e.STATUS, e.USER_NAME, e.CLIENT_ID, e.GUID,
     decode(e.credential, NULL, NULL, 
        substr(e.credential, 1, instr(e.credential, '"')-1)),
     decode(e.credential, NULL, NULL,
        substr(e.credential, instr(e.credential, '"')+1,
           length(e.credential) - instr(e.credential, '"'))),
     decode(bitand(e.flags, 1), 0, NULL, 
        substr(e.destination, 1, instr(e.destination, '"')-1)),
     decode(bitand(e.flags, 1), 0, e.destination, 
        substr(e.destination, instr(e.destination, '"')+1,
           length(e.destination) - instr(e.destination, '"'))),
     e.ADDITIONAL_INFO
   FROM scheduler$_event_log e, obj$ co
   WHERE e.type# = 66 and e.dbid is null and e.class_id = co.obj#(+)
   AND ( e.owner = SYS_CONTEXT('USERENV','CURRENT_USER')
         or  /* user has object privileges */
            ( select jo.obj# from obj$ jo, user$ ju where
              DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)) = jo.name
                and e.owner = ju.name and jo.owner# = ju.user# 
                and jo.subname is null and jo.type# = 66
            ) in
            ( select oa.obj#
                from sys.objauth$ oa
                where grantee# in ( select kzsrorol from x$kzsro )
            )
         or /* user has system privileges */
            (exists ( select null from v$enabledprivs
                       where priv_number = -265 /* CREATE ANY JOB */
                   )
             and e.owner!='SYS')
        )
  )
/

CREATE OR REPLACE VIEW all_scheduler_job_run_details
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, STATUS, ERROR#, REQ_START_DATE,
    ACTUAL_START_DATE, RUN_DURATION, INSTANCE_ID, SESSION_ID, SLAVE_PID,
    CPU_USED, CREDENTIAL_OWNER, CREDENTIAL_NAME, DESTINATION_OWNER,
    DESTINATION, ADDITIONAL_INFO)
  AS
  (SELECT
     j.LOG_ID, j.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     e.STATUS, j.ERROR#, j.REQ_START_DATE, j.START_DATE, j.RUN_DURATION,
     j.INSTANCE_ID, j.SESSION_ID, j.SLAVE_PID, j.CPU_USED,
     decode(e.credential, NULL, NULL,
        substr(e.credential, 1, instr(e.credential, '"')-1)),
     decode(e.credential, NULL, NULL,
        substr(e.credential, instr(e.credential, '"')+1,
           length(e.credential) - instr(e.credential, '"'))),
     decode(bitand(e.flags, 1), 0, NULL,
        substr(e.destination, 1, instr(e.destination, '"')-1)),
     decode(bitand(e.flags, 1), 0, e.destination,
        substr(e.destination, instr(e.destination, '"')+1,
           length(e.destination) - instr(e.destination, '"'))),
     j.ADDITIONAL_INFO
   FROM scheduler$_job_run_details j, scheduler$_event_log e
   WHERE j.log_id = e.log_id
   AND e.type# = 66 and e.dbid is null
   AND ( e.owner = SYS_CONTEXT('USERENV','CURRENT_USER')
         or  /* user has object privileges */
            ( select jo.obj# from obj$ jo, user$ ju where
                DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)) = jo.name
                and e.owner = ju.name and jo.owner# = ju.user#
                and jo.subname is null and jo.type# = 66
            ) in
            ( select oa.obj#
                from sys.objauth$ oa
                where grantee# in ( select kzsrorol from x$kzsro )
            )
         or /* user has system privileges */
            (exists ( select null from v$enabledprivs
                       where priv_number = -265 /* CREATE ANY JOB */
                   )
             and e.owner!='SYS')
        )
  )
/


alter view USER_AUDIT_POLICIES compile;
alter view USER_AUDIT_POLICY_COLUMNS compile;
alter view user_scheduler_job_log compile;
alter view user_scheduler_job_run_details compile;
alter view all_scheduler_job_log compile;
alter view all_scheduler_job_run_details compile;

