Rem
Rem $Header: rdbms/admin/catschv.sql /st_rdbms_11.2.0.4.0dbpsu/2 2015/05/12 23:28:52 ratakuma Exp $
Rem
Rem catschv.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catschv.sql - SCHeduler Views
Rem
Rem    DESCRIPTION
Rem      Views dependent on dbms_scheduler and ODCI 
Rem 
Rem    NOTES
Rem      Must be run AFTER dbmssch.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/13/15 - Backport ratakuma_bug-20331945 from
Rem                           st_rdbms_11.2.0
Rem    rramkiss    05/17/11 - support arg export from 11.2.0.3
Rem    evoss       04/01/11 - Backport evoss_bug-9069362 from main
Rem    ratakuma    02/10/15 - Bug 20331945: use CURRENT_USER in 
Rem                           scheduler_job_log and scheduler_job_run_details
Rem    evoss       02/17/11 - add namespace check to all_scheduler log views
Rem    rramkiss    05/27/10 - add pause_before for chain steps
Rem    rramkiss    05/13/10 - update views for log_id metadata arg
Rem    rgmani      06/30/09 - Fix view issue
Rem    evoss       05/13/09 - scheduler_job_dest fix for disabled dests
Rem    rramkiss    05/06/09 - tweak privs on groups
Rem    rgmani      05/06/09 - Fix job_dests views
Rem    rramkiss    04/17/09 - tweak db_dests to show even if agent is null
Rem    rramkiss    04/14/09 - fix running_jobs views
Rem    evoss       04/02/09 - add local destination support
Rem    rgmani      03/31/09 - Fix view bug
Rem    evoss       03/17/09 - revisite scheduler_job_dests views
Rem    rramkiss    02/17/09 - tweaks for external dests
Rem    rgmani      02/04/09 - Add lw fields
Rem    rramkiss    08/18/08 - 
Rem    evoss       02/27/08 - add chainid special arg
Rem    rramkiss    06/04/08 - export scheduler attributes
Rem    rramkiss    03/05/08 - add views for e-mail notifications
Rem    rgmani      02/15/08 - File watching
Rem    rramkiss    11/03/08 - bug #7477978 - retry for chain steps
Rem    rramkiss    10/31/08 - restart_on_failure flag for chain steps #7477978
Rem    rramkiss    02/20/08 - bug #5916142, key job args using program name
Rem    evoss       02/06/08 - add ALLOW_RUNS_IN_RESTRICTED_MODE to job views
Rem    rgmani      01/16/08 - Change attribute name for JOB type
Rem    rramkiss    01/10/08 - allow CREATE ANY JOB to see all credentials
Rem    rgmani      06/10/07 - Fix flag definition
Rem    jhan        04/24/07 - Update view definition
Rem    rgmani      03/05/07 - Update view definition
Rem    rgmani      02/21/07 - export bugfix
Rem    rgmani      10/18/06 - 
Rem    evoss       01/31/07 - add DETACHED column in running_jobs views
Rem    rramkiss    10/16/06 - update for remote chain steps
Rem    rramkiss    09/06/06 - hide hidden scheduler global attributes
Rem    rburns      07/29/06 - views dependent on dbms_scheduler 
Rem    rburns      07/29/06 - Created
Rem

-- from catsch.sql
create or replace type sys.SCHEDULER$_BATCHERR_VIEW_T as object
(
  currow     number,
  done       number,

  static function ODCITablePrepare
                    (sctx OUT sys.SCHEDULER$_BATCHERR_VIEW_T, 
                     tf IN SYS.ODCITabFuncInfo)
    return number,

  static function ODCITableStart
                    (sctx IN OUT sys.SCHEDULER$_BATCHERR_VIEW_T)
    return number,

  member function ODCITableFetch
                    (self IN OUT sys.SCHEDULER$_BATCHERR_VIEW_T, 
                     nrows IN number,
                     objset OUT sys.SCHEDULER$_BATCHERR_ARRAY)
    return number,

  member function ODCITableClose
                    (self IN sys.SCHEDULER$_BATCHERR_VIEW_T)
    return number
);
/

CREATE OR REPLACE FUNCTION sys.SCHEDULER$_BATCHERR_PIPE 
  RETURN sys.SCHEDULER$_BATCHERR_ARRAY PIPELINED USING 
    sys.SCHEDULER$_BATCHERR_VIEW_T;
/

CREATE OR REPLACE VIEW sys.SCHEDULER_BATCH_ERRORS
 AS SELECT array_index, object_type, object_name, attr_name, 
           error_code, error_message, additional_info
    FROM TABLE(SYS.SCHEDULER$_BATCHERR_PIPE)
/

grant execute on JOBARG to PUBLIC;
grant execute on JOBARG_ARRAY to PUBLIC;
grant execute on JOB_DEFINITION to PUBLIC;
grant execute on JOB_DEFINITION_ARRAY to PUBLIC;
grant execute on JOB to PUBLIC;
grant execute on JOB_ARRAY to PUBLIC;
grant execute on JOBATTR to PUBLIC;
grant execute on JOBATTR_ARRAY to PUBLIC;
grant execute on SCHEDULER$_BATCHERR to PUBLIC;
grant execute on SCHEDULER$_BATCHERR_ARRAY to PUBLIC;
grant select on sys.SCHEDULER_BATCH_ERRORS TO PUBLIC;

CREATE OR REPLACE PUBLIC SYNONYM JOBARG FOR SYS.JOBARG;
CREATE OR REPLACE PUBLIC SYNONYM JOBARG_ARRAY FOR SYS.JOBARG_ARRAY;
CREATE OR REPLACE PUBLIC SYNONYM JOB_DEFINITION FOR SYS.JOB_DEFINITION;
CREATE OR REPLACE PUBLIC SYNONYM JOB_DEFINITION_ARRAY 
  FOR SYS.JOB_DEFINITION_ARRAY;
CREATE OR REPLACE PUBLIC SYNONYM JOBATTR FOR SYS.JOBATTR;
CREATE OR REPLACE PUBLIC SYNONYM JOBATTR_ARRAY FOR SYS.JOBATTR_ARRAY;

/*****************************************************************************
 **       TYPES JOB AND JOB_ARRAY HAVE BEEN DEPRECATED - DO NOT USE         **
 *****************************************************************************/
CREATE OR REPLACE PUBLIC SYNONYM JOB FOR SYS.JOB;
CREATE OR REPLACE PUBLIC SYNONYM JOB_ARRAY FOR SYS.JOB_ARRAY;

-- CREATE OR REPLACE PUBLIC SYNONYM SCHEDULER$_BATCHERR 
--  FOR SYS.SCHEDULER$_BATCHERR;
-- CREATE OR REPLACE PUBLIC SYNONYM SCHEDULER$_BATCHERR_ARRAY 
--  FOR SYS.SCHEDULER$_BATCHERR_ARRAY;
CREATE OR REPLACE PUBLIC SYNONYM SCHEDULER_BATCH_ERRORS 
  FOR SYS.SCHEDULER_BATCH_ERRORS;

-- from catsch.sql

/* Create Dictionary Views for Scheduler */

CREATE OR REPLACE VIEW dba_scheduler_programs
  (OWNER, PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, SCHEDULE_LIMIT, PRIORITY, WEIGHT, MAX_RUNS, 
   MAX_FAILURES, MAX_RUN_DURATION, NLS_ENV, COMMENTS) AS
  SELECT u.name, o.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.schedule_limit, p.priority, p.job_weight, p.max_runs, 
  p.max_failures, p.max_run_duration, p.nls_env, p.comments
  FROM obj$ o, user$ u, sys.scheduler$_program p
  WHERE p.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_programs IS
'All scheduler programs in the database'
/
COMMENT ON COLUMN dba_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN dba_scheduler_programs.owner IS
'Owner of the scheduler program'
/
COMMENT ON COLUMN dba_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN dba_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN dba_scheduler_programs.schedule_limit IS
'Maximum delay in running program after scheduled start'
/
COMMENT ON COLUMN dba_scheduler_programs.priority IS
'Priority of program'
/
COMMENT ON COLUMN dba_scheduler_programs.weight IS
'Weight of program'
/
COMMENT ON COLUMN dba_scheduler_programs.max_runs IS
'Maximum number of runs of program'
/
COMMENT ON COLUMN dba_scheduler_programs.max_failures IS
'Maximum number of failures of program'
/
COMMENT ON COLUMN dba_scheduler_programs.max_run_duration IS
'Maximum run duration of program'
/
COMMENT ON COLUMN dba_scheduler_programs.nls_env IS
'NLS Environment in which program was created'
/
COMMENT ON COLUMN dba_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN dba_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN dba_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN dba_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_programs
  FOR dba_scheduler_programs
/
GRANT SELECT ON dba_scheduler_programs TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_programs
  (PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, SCHEDULE_LIMIT, PRIORITY, WEIGHT, MAX_RUNS, 
   MAX_FAILURES, MAX_RUN_DURATION, NLS_ENV, COMMENTS) AS
  SELECT po.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.schedule_limit, p.priority, p.job_weight, p.max_runs, 
  p.max_failures, p.max_run_duration, p.nls_env, p.comments
  FROM obj$ po, sys.scheduler$_program p
  WHERE po.owner# = USERENV('SCHEMAID') AND p.obj# = po.obj#
/
COMMENT ON TABLE user_scheduler_programs IS
'Scheduler programs owned by the current user'
/
COMMENT ON COLUMN user_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN user_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN user_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN user_scheduler_programs.schedule_limit IS
'Maximum delay in running program after scheduled start'
/
COMMENT ON COLUMN user_scheduler_programs.priority IS
'Priority of program'
/
COMMENT ON COLUMN user_scheduler_programs.weight IS
'Weight of program'
/
COMMENT ON COLUMN user_scheduler_programs.max_runs IS
'Maximum number of runs of program'
/
COMMENT ON COLUMN user_scheduler_programs.max_failures IS
'Maximum number of failures of program'
/
COMMENT ON COLUMN user_scheduler_programs.max_run_duration IS
'Maximum run duration of program'
/
COMMENT ON COLUMN user_scheduler_programs.nls_env IS
'NLS Environment in which program was created'
/
COMMENT ON COLUMN user_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN user_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN user_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN user_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_programs
  FOR user_scheduler_programs
/
GRANT SELECT ON user_scheduler_programs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_programs
  (OWNER, PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, SCHEDULE_LIMIT, PRIORITY, WEIGHT, MAX_RUNS, 
   MAX_FAILURES, MAX_RUN_DURATION, NLS_ENV, COMMENTS) AS
  SELECT u.name, o.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.schedule_limit, p.priority, p.job_weight, p.max_runs, 
  p.max_failures, p.max_run_duration, p.nls_env, p.comments
  FROM obj$ o, user$ u, sys.scheduler$_program p
  WHERE p.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -255 /* EXPORT FULL DATABASE */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_programs IS
'All scheduler programs visible to the user'
/
COMMENT ON COLUMN all_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN all_scheduler_programs.owner IS
'Owner of the scheduler program'
/
COMMENT ON COLUMN all_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN all_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN all_scheduler_programs.schedule_limit IS
'Maximum delay in running program after scheduled start'
/
COMMENT ON COLUMN all_scheduler_programs.priority IS
'Priority of program'
/
COMMENT ON COLUMN all_scheduler_programs.weight IS
'Weight of program'
/
COMMENT ON COLUMN all_scheduler_programs.max_runs IS
'Maximum number of runs of program'
/
COMMENT ON COLUMN all_scheduler_programs.max_failures IS
'Maximum number of failures of program'
/
COMMENT ON COLUMN all_scheduler_programs.max_run_duration IS
'Maximum run duration of program'
/
COMMENT ON COLUMN all_scheduler_programs.nls_env IS
'NLS Environment in which program was created'
/
COMMENT ON COLUMN all_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN all_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN all_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN all_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_programs
  FOR all_scheduler_programs
/
GRANT SELECT ON all_scheduler_programs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_dests
  (OWNER, DESTINATION_NAME, DESTINATION_TYPE, ENABLED, COMMENTS) AS
SELECT u.name, o.name, 
  decode(bitand(d.flags, 2+4), 2, 'EXTERNAL', 4, 'DATABASE'),
  decode(bitand(d.flags, 1), 1, 'TRUE', 'FALSE'), d.comments
FROM scheduler$_destinations d, user$ u, obj$ o
WHERE u.user# = o.owner# AND o.obj# = d.obj#
      and bitand(d.flags, 8) = 0
/
COMMENT ON TABLE dba_scheduler_dests IS
'All possible destination objects for jobs in the database'
/
COMMENT ON COLUMN dba_scheduler_dests.owner IS
'Owner of this destination object'
/
COMMENT ON COLUMN dba_scheduler_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN dba_scheduler_dests.destination_type IS
'Type of this destination object'
/
COMMENT ON COLUMN dba_scheduler_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN dba_scheduler_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_dests
  FOR dba_scheduler_dests
/
GRANT SELECT ON dba_scheduler_dests TO select_catalog_role
/
CREATE OR REPLACE VIEW user_scheduler_dests
  (DESTINATION_NAME, DESTINATION_TYPE, ENABLED, COMMENTS) AS
SELECT o.name,
  decode(bitand(d.flags, 2+4), 2, 'EXTERNAL', 4, 'DATABASE'),
  decode(bitand(d.flags, 1), 1, 'TRUE', 'FALSE'), d.comments
FROM scheduler$_destinations d, obj$ o
WHERE o.owner# = userenv('SCHEMAID') AND o.obj# = d.obj#
      and bitand(d.flags, 8) = 0
/
COMMENT ON TABLE user_scheduler_dests IS
'Destination objects for jobs in the database owned by current user'
/
COMMENT ON COLUMN user_scheduler_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN user_scheduler_dests.destination_type IS
'Type of this destination object'
/
COMMENT ON COLUMN user_scheduler_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN user_scheduler_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_dests
  FOR user_scheduler_dests
/
GRANT SELECT ON user_scheduler_dests TO public with grant option
/
CREATE OR REPLACE VIEW all_scheduler_dests AS
SELECT * from dba_scheduler_dests
/
COMMENT ON TABLE all_scheduler_dests IS
'All destination objects for jobs in the database visible to current user'
/
COMMENT ON COLUMN all_scheduler_dests.owner IS
'Owner of this destination object'
/
COMMENT ON COLUMN all_scheduler_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN all_scheduler_dests.destination_type IS
'Type of this destination object'
/
COMMENT ON COLUMN all_scheduler_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN all_scheduler_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_dests
  FOR all_scheduler_dests
/
GRANT SELECT ON all_scheduler_dests TO public with grant option
/
CREATE OR REPLACE VIEW dba_scheduler_external_dests
  (DESTINATION_NAME, HOSTNAME, PORT, IP_ADDRESS, ENABLED, COMMENTS) AS
SELECT o.name, d.hostname, d.port, d.ip_address,
  decode(bitand(d.flags, 1), 1, 'TRUE', 'FALSE'), d.comments
FROM obj$ o, scheduler$_destinations d
WHERE d.obj# = o.obj# AND bitand(d.flags, 2+8) = 2
/
COMMENT ON TABLE dba_scheduler_external_dests IS
'All destination objects in the database pointing to remote agents'
/
COMMENT ON COLUMN dba_scheduler_external_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN dba_scheduler_external_dests.hostname IS
'Name or IP address of host on which agent is located'
/
COMMENT ON COLUMN dba_scheduler_external_dests.port IS
'Port that the agent is listening on'
/
COMMENT ON COLUMN dba_scheduler_external_dests.ip_address IS
'IP address of host on which agent is located'
/
COMMENT ON COLUMN dba_scheduler_external_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN dba_scheduler_external_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_external_dests
  FOR dba_scheduler_external_dests
/
GRANT SELECT ON dba_scheduler_external_dests TO select_catalog_role
/
CREATE OR REPLACE VIEW all_scheduler_external_dests AS
SELECT * from dba_scheduler_external_dests
/
COMMENT ON TABLE all_scheduler_external_dests IS
'User-visible destination objects in the database pointing to remote agents'
/
COMMENT ON COLUMN all_scheduler_external_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN all_scheduler_external_dests.hostname IS
'Name or IP address of host on which agent is located'
/
COMMENT ON COLUMN all_scheduler_external_dests.port IS
'Port that the agent is listening on'
/
COMMENT ON COLUMN all_scheduler_external_dests.ip_address IS
'IP address of host on which agent is located'
/
COMMENT ON COLUMN all_scheduler_external_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN all_scheduler_external_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_external_dests
  FOR all_scheduler_external_dests
/
GRANT SELECT ON all_scheduler_external_dests TO public with grant option
/
CREATE OR REPLACE VIEW dba_scheduler_db_dests
  (OWNER, DESTINATION_NAME, CONNECT_INFO, AGENT, ENABLED, REFS_ENABLED, 
     COMMENTS) AS
SELECT u.name, o.name, d.connect_info, ao.name,  
  decode(bitand(d.flags, 1), 1, 'TRUE', 'FALSE'), 
  decode(bitand(ad.flags, 1), 1, 'TRUE', 'FALSE'), 
  d.comments
FROM user$ u, obj$ o, scheduler$_destinations d, obj$ ao, 
     scheduler$_destinations ad
WHERE u.user# = o.owner# AND o.obj# = d.obj# AND
  d.agtdestoid = ao.obj#(+) AND bitand(d.flags, 4+8) = 4
  AND d.agtdestoid = ad.obj#(+)
/
COMMENT ON TABLE dba_scheduler_db_dests IS
'All destination objects in the database pointing to remote databases'
/
COMMENT ON COLUMN dba_scheduler_db_dests.owner IS
'Owner of this destination object'
/
COMMENT ON COLUMN dba_scheduler_db_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN dba_scheduler_db_dests.connect_info IS
'Connect string to connect to remote database'
/
COMMENT ON COLUMN dba_scheduler_db_dests.agent IS
'Name of agent through which connection to remote database is being made'
/
COMMENT ON COLUMN dba_scheduler_db_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN dba_scheduler_db_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_db_dests
  FOR dba_scheduler_db_dests
/
GRANT SELECT ON dba_scheduler_db_dests TO select_catalog_role
/
CREATE OR REPLACE VIEW user_scheduler_db_dests
  (DESTINATION_NAME, CONNECT_INFO, AGENT, ENABLED, 
       REFS_ENABLED, COMMENTS) AS
SELECT o.name, d.connect_info, ao.name, 
  decode(bitand(d.flags, 1), 1, 'TRUE', 'FALSE'),
  decode(bitand(ad.flags, 1), 1, 'TRUE', 'FALSE'),  d.comments
FROM obj$ o, scheduler$_destinations d, obj$ ao,
       scheduler$_destinations ad
WHERE o.owner# = userenv('SCHEMAID') AND o.obj# = d.obj# AND
  d.agtdestoid = ao.obj#(+)  AND bitand(d.flags, 4+8) = 4
  AND d.agtdestoid = ad.obj#(+)
/
COMMENT ON TABLE user_scheduler_db_dests IS
'User-owned destination objects in the database pointing to remote databases'
/
COMMENT ON COLUMN user_scheduler_db_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN user_scheduler_db_dests.connect_info IS
'Connect string to connect to remote database'
/
COMMENT ON COLUMN user_scheduler_db_dests.agent IS
'Name of agent through which connection to remote database is being made'
/
COMMENT ON COLUMN user_scheduler_db_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN user_scheduler_db_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_db_dests
  FOR user_scheduler_db_dests
/
GRANT SELECT ON user_scheduler_db_dests TO public with grant option
/
CREATE OR REPLACE VIEW all_scheduler_db_dests AS
  SELECT * FROM dba_scheduler_db_dests
/
COMMENT ON TABLE all_scheduler_db_dests IS
'User-visible destination objects in the database pointing to remote databases'
/
COMMENT ON COLUMN all_scheduler_db_dests.owner IS
'Owner of this destination object'
/
COMMENT ON COLUMN all_scheduler_db_dests.destination_name IS
'Name of this destination object'
/
COMMENT ON COLUMN all_scheduler_db_dests.connect_info IS
'Connect string to connect to remote database'
/
COMMENT ON COLUMN all_scheduler_db_dests.agent IS
'Name of agent through which connection to remote database is being made'
/
COMMENT ON COLUMN all_scheduler_db_dests.enabled IS
'Whether this destination object is enabled'
/
COMMENT ON COLUMN all_scheduler_db_dests.comments IS
'Optional comment'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_db_dests
  FOR all_scheduler_db_dests
/
GRANT SELECT ON all_scheduler_db_dests TO public with grant option
/

CREATE OR REPLACE VIEW dba_scheduler_job_dests
  ( OWNER, JOB_NAME, JOB_SUBNAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, 
    DESTINATION_OWNER, DESTINATION, JOB_DEST_ID, ENABLED, 
    REFS_ENABLED, STATE, 
    NEXT_START_DATE, RUN_COUNT, RETRY_COUNT, FAILURE_COUNT, 
    LAST_START_DATE, LAST_END_DATE)
AS
SELECT  dd.OWNER, dd.JOB_NAME, 
        dd.JOB_SUBNAME, 
        decode(dd.local, 'X', null, CREDENTIAL_OWNER),
        decode(dd.local, 'X', null,dd.CREDENTIAL_NAME),
        decode(dd.local, 'N', dd.DESTINATION_OWNER, null), 
        decode(dd.local, 'N', dd.DESTINATION_NAME, 'LOCAL'),
        lj.JOB_DEST_ID, 
        decode(dd.pj_enbl, 1, 'TRUE', 'FALSE'),
        dd.ENABLED,
        (CASE WHEN (bitand(dd.pj_status,4+8+16+32+8192+524288) > 0 OR
                    (lj.STATE <> 'RUNNING' AND bitand(dd.pj_status, 1) = 0))
                 THEN  'DISABLED'
                 ELSE  coalesce(lj.STATE, 'SCHEDULED') END), 
        dd.next_run_date NEXT_START_DATE, 
        coalesce(lj.RUN_COUNT,0), 
        coalesce(lj.RETRY_COUNT,0), 
        coalesce(lj.FAILURE_COUNT,0), 
        lj.LAST_START_DATE, lj.LAST_END_DATE
FROM 
(SELECT 
  d.job_dest_id JOB_DEST_ID, 
  DECODE(BITAND(d.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(d.job_status,1+4+8+16+32+128+8192),0,'SCHEDULED',1,
      (CASE WHEN d.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(d.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)) STATE,
    d.run_count, d.retry_count, d.failure_count, 
    d.last_start_date, d.last_end_date, d.program_oid parent_job_id, d.dest_oid
  FROM  scheduler$_lightweight_job d) lj,
(SELECT 
     j0.OWNER, j0.JOB_NAME, 
     'SCHED$_MD_' 
     || TO_CHAR(coalesce(d0.dest_oid,j0.dest_oid), 'FMXXXXXXXXX') || '_' 
     || TO_CHAR(decode(d0.local, 'X', 0, 
                  coalesce(d0.cred_oid,j0.cred_oid)), 'FMXXXXXXXXX') JOB_SUBNAME,
     coalesce(d0.credential_owner,j0.credential_owner) credential_owner,
     coalesce(d0.credential_name,j0.credential_name) credential_name,
     d0.destination_owner,
     d0.destination_name,
     decode(d0.en_flag+j0.en_flag,2, 'TRUE', 'FALSE') enabled,
     j0.en_flag pj_enbl, 
     j0.pj_status, 
     j0.next_run_date, j0.parent_job_id, d0.dest_oid, d0.local  
FROM 
( SELECT cmu.name credential_owner,  cmo.name credential_name, 
      wmu.name destination_owner, wmo.name destination_name, 
      bitand(d.flags, bitand(w.flags,bitand(coalesce(ad.flags,1),1))) en_flag, 
      w.obj# dest_grp_id, 
      wg.member_oid2 cred_oid,
      wg.member_oid dest_oid, 
      decode(bitand(d.flags, 12),12, 'X',8, 'Y','N') local
  FROM  scheduler$_window_group w, scheduler$_wingrp_member wg,
        scheduler$_destinations d, scheduler$_destinations ad,
         user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
  WHERE w.obj# = wg.oid  
       AND wg.member_oid = wmo.obj# 
       AND wmo.owner# = wmu.user# 
       AND wg.member_oid = d.obj# 
       AND cmo.obj#(+) = wg.member_oid2 
       AND d.agtdestoid = ad.obj#(+)
       AND cmo.owner# = cmu.user#(+)) d0, 
(SELECT  j1.credential_owner, j1.credential_name, 
    substr(j1.destination, 1, instr(j1.destination, '"')-1) destination_owner,
    substr(j1.destination, instr(j1.destination, '"')+1, 
        length(j1.destination) - instr(j1.destination, '"')) destination_name,
    bitand(j1.job_status, 1) en_flag,
    j1.dest_oid,
    j1.next_run_date,
    u.name OWNER, o.name JOB_NAME, o.subname JOB_SUBNAME,
    j1.obj# parent_job_id,
    j1.job_status pj_status,
    j1.credential_oid cred_oid
    FROM scheduler$_job j1, user$ u, obj$ o 
              WHERE j1.obj# = o.obj# AND o.owner# = u.user# ) j0
  WHERE j0.dest_oid = d0.dest_grp_id 
    and (j0.cred_oid is null or j0.cred_oid != coalesce(d0.cred_oid, 0)
        or not exists (select 1 from scheduler$_wingrp_member wm
                where  wm.oid = d0.dest_grp_id
                and wm.member_oid2 is null 
                and wm.member_oid = d0.dest_oid))) dd 
WHERE 
   lj.parent_job_id (+) = dd.parent_job_id  and
   lj.dest_oid (+) = dd.dest_oid and
   (dd.pj_enbl = 1 or lj.dest_oid is not null) 
UNION ALL 
 SELECT u1.name, o1.name, o1.subname, j1.credential_owner, j1.credential_name,
    j1.destination_owner, j1.destination,
    j1.job_dest_id, DECODE(BITAND(j1.job_status,1),0,'FALSE','TRUE'),
    decode(jd1.enabled, 'TRUE', 'TRUE', 
           decode(bitand(j1.flags, 274877906944), 0, 'TRUE', 'FALSE')),
    DECODE(BITAND(j1.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
       DECODE(BITAND(j1.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
        (CASE WHEN j1.retry_count>0 AND bitand(j1.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j1.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j1.next_run_date, j1.run_count, 
    decode(bitand(j1.flags, 549755813888), 0, j1.retry_count, 0),
    j1.failure_count, j1.last_start_date,
    (CASE WHEN j1.last_end_date>j1.last_start_date THEN j1.last_end_date 
     ELSE NULL END)
  FROM 
   (select rj1.obj# obj#, rj1.credential_owner credential_owner, 
           rj1.credential_name credential_name, 
           decode(bitand(rj1.flags, 274877906944), 0, NULL, 
             substr(rj1.destination, 1, instr(rj1.destination, '"')-1))
               destination_owner,
           decode(bitand(rj1.flags, 274877906944), 0, 
              decode(rj1.destination, NULL, 'LOCAL', rj1.destination), 
                 substr(rj1.destination, instr(rj1.destination, '"')+1,
                    length(rj1.destination) - instr(rj1.destination, '"')))
                destination,
           rj1.job_status job_status, rj1.flags flags, 
           rj1.next_run_date next_run_date, rj1.run_count run_count, 
           rj1.retry_count retry_count, rj1.failure_count failure_count,
           rj1.last_start_date last_start_date, rj1.last_end_date last_end_date,
           rj1.job_dest_id job_dest_id
      from scheduler$_job rj1
    union all
    select lj1.obj#, lj1.credential_owner, lj1.credential_name, 
           decode(bitand(lj1.flags, 274877906944), 0, NULL, 
             substr(lj1.destination, 1, instr(lj1.destination, '"')-1)),
           decode(bitand(lj1.flags, 274877906944), 0, 
              decode(lj1.destination, NULL, 'LOCAL', lj1.destination), 
                 substr(lj1.destination, instr(lj1.destination, '"')+1,
                    length(lj1.destination) - instr(lj1.destination, '"'))),
           lj1.job_status, lj1.flags, 
           lj1.next_run_date, lj1.run_count, lj1.retry_count, 
           lj1.failure_count, lj1.last_start_date, lj1.last_end_date,
           lj1.job_dest_id
      from scheduler$_lightweight_job lj1) j1,
    (select ro1.obj# obj#, ro1.owner# owner#, ro1.name name, ro1.subname subname
       from obj$ ro1
     union all
     select lo1.obj#, lo1.userid, lo1.name, lo1.subname
       from scheduler$_lwjob_obj lo1) o1,
    user$ u1,
    (select dd.owner owner, dd.destination_name dest_name, 
            decode(dd.enabled, 'FALSE', 'FALSE', dd.refs_enabled) enabled
     from dba_scheduler_db_dests dd
     union all
     select 'SYS', ed.destination_name, ed.enabled
     from dba_scheduler_external_dests ed) jd1
  WHERE j1.obj# = o1.obj# AND o1.owner# = u1.user# 
    AND bitand(j1.flags, 137438953472) = 0
    AND bitand(j1.flags, 549755813888) = 0
    AND (jd1.owner(+) = j1.destination_owner) 
    AND (jd1.dest_name(+) = j1.destination)
UNION ALL
  SELECT du.name, do.name, do.subname, 
    d.credential_owner, d.credential_name, 
    substr(d.destination, 1, instr(d.destination, '"')-1),
    substr(d.destination, instr(d.destination, '"')+1, 
        length(d.destination) - instr(d.destination, '"')),
    d.job_dest_id, 'FALSE', 'FALSE', 'RUNNING', NULL, d.run_count,
    d.retry_count, d.failure_count, d.last_start_date, d.last_end_date
  FROM  scheduler$_lightweight_job d, user$ du, scheduler$_lwjob_obj do,
        scheduler$_job pj
  WHERE d.obj# = do.obj# and do.userid = du.user# and d.program_oid = pj.obj#
    and bitand(d.flags, 8589934592) <> 0
    and bitand(d.job_status, 2) = 2
    and (d.dest_oid is null or 
         d.dest_oid not in 
           (select so.obj# from obj$ so where so.owner# = 0 and so.namespace = 1
            and so.name = 'SCHED$_LOCAL_PSEUDO_DB'))
    and (nvl(d.dest_oid,0), nvl(d.credential_oid,0)) not in 
          (select nvl(wg.member_oid,0), 
             nvl(decode(wg.member_oid2, null, pj.credential_oid, wg.member_oid2), 0) 
           from scheduler$_wingrp_member wg
           where wg.oid = pj.dest_oid)
/
COMMENT ON TABLE dba_scheduler_job_dests IS
'State of all jobs at each of their destinations'
/
COMMENT ON COLUMN dba_scheduler_job_dests.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_dests.job_name IS
'Name of scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_dests.job_subname IS
'Subname of scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_dests.credential_owner IS
'Owner of credential used for remote destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.credential_name IS
'Name of credential used for remote destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.destination_owner IS
'Owner of destination object that points to destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.destination IS
'Name of destination object or name of destination itself'
/
COMMENT ON COLUMN dba_scheduler_job_dests.job_dest_id IS 
'Numerical ID assigned to job at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.enabled IS
'Is this job enabled at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.state IS
'State of this job at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.next_start_date IS
'Next start time of this job at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.run_count IS
'Number of times this job has run at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.retry_count IS
'Number of times this job has been retried at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.failure_count IS
'Number of times this job has failed at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.last_start_date IS
'Last time this job started at this destination'
/
COMMENT ON COLUMN dba_scheduler_job_dests.last_end_date IS
'Last time this job ended at this destination'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_dests
   FOR dba_scheduler_job_dests
/
GRANT SELECT ON dba_scheduler_job_dests TO select_catalog_role
/
CREATE OR REPLACE VIEW user_scheduler_job_dests
  ( JOB_NAME, JOB_SUBNAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, 
    DESTINATION_OWNER, DESTINATION, JOB_DEST_ID, ENABLED, 
    REFS_ENABLED, STATE, 
    NEXT_START_DATE, RUN_COUNT, RETRY_COUNT, FAILURE_COUNT, 
    LAST_START_DATE, LAST_END_DATE )
AS
SELECT  dd.JOB_NAME, dd.JOB_SUBNAME, 
        decode(dd.local, 'X', null, CREDENTIAL_OWNER),
        decode(dd.local, 'X', null,dd.CREDENTIAL_NAME),
        decode(dd.local, 'N', dd.DESTINATION_OWNER, null), 
        decode(dd.local, 'N', dd.DESTINATION_NAME, 'LOCAL'),
        lj.JOB_DEST_ID, 
        decode(dd.pj_enbl, 1, 'TRUE', 'FALSE'),
        dd.ENABLED, 
        (CASE WHEN (bitand(dd.pj_status,4+8+16+32+8192+524288) > 0 OR
                    (lj.STATE <> 'RUNNING' AND bitand(dd.pj_status, 1) = 0))
                 THEN  'DISABLED'
                 ELSE  coalesce(lj.STATE, 'SCHEDULED') END), 
        dd.next_run_date NEXT_START_DATE, 
        coalesce(lj.RUN_COUNT,0), 
        coalesce(lj.RETRY_COUNT,0), 
        coalesce(lj.FAILURE_COUNT,0), 
        lj.LAST_START_DATE, lj.LAST_END_DATE 
FROM 
(SELECT 
  d.job_dest_id JOB_DEST_ID, 
  DECODE(BITAND(d.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(d.job_status,1+4+8+16+32+128+8192),0,'SCHEDULED',1,
      (CASE WHEN d.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(d.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)) STATE,
    d.run_count, d.retry_count, d.failure_count, 
    d.last_start_date, d.last_end_date, d.program_oid parent_job_id,d.dest_oid
  FROM  scheduler$_lightweight_job d) lj,
(SELECT 
     j0.JOB_NAME, 
     'SCHED$_MD_' 
     || TO_CHAR(coalesce(d0.dest_oid,j0.dest_oid), 'FMXXXXXXXXX') || '_' 
     || TO_CHAR(decode(d0.local, 'X', 0,
                   coalesce(d0.cred_oid,j0.cred_oid)), 'FMXXXXXXXXX') JOB_SUBNAME,
     coalesce(d0.credential_owner,j0.credential_owner) credential_owner,
     coalesce(d0.credential_name,j0.credential_name) credential_name,
     d0.destination_owner,
     d0.destination_name,
     decode(d0.en_flag+j0.en_flag, 2, 'TRUE', 'FALSE') enabled,
     j0.en_flag pj_enbl, 
     j0.pj_status,
     j0.next_run_date, j0.parent_job_id, d0.dest_oid, d0.local
FROM 
  (SELECT cmu.name credential_owner,  cmo.name credential_name, 
     wmu.name destination_owner, wmo.name destination_name, 
     bitand(d.flags, bitand(w.flags,bitand(coalesce(ad.flags,1),1))) en_flag,
     w.obj# dest_grp_id, 
     wg.member_oid2 cred_oid,  
     wg.member_oid dest_oid, 
     decode(bitand(d.flags, 12),12, 'X',8, 'Y','N') local
   FROM  scheduler$_window_group w, scheduler$_wingrp_member wg,
      scheduler$_destinations d, scheduler$_destinations ad,
      user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
   WHERE w.obj# = wg.oid  
       AND wg.member_oid = wmo.obj# 
       AND wmo.owner# = wmu.user# 
       AND wg.member_oid = d.obj# 
       AND cmo.obj#(+) = wg.member_oid2 
       AND d.agtdestoid = ad.obj#(+)
       AND cmo.owner# = cmu.user#(+)) d0, 
  (SELECT  j1.credential_owner, j1.credential_name, 
    substr(j1.destination, 1, instr(j1.destination, '"')-1) destination_owner,
    substr(j1.destination, instr(j1.destination, '"')+1, 
        length(j1.destination) - instr(j1.destination, '"')) destination_name,
    bitand(j1.job_status, 1) en_flag,
    j1.dest_oid,
    j1.next_run_date,
    u.name OWNER, o.name JOB_NAME, o.subname JOB_SUBNAME,
    j1.obj# parent_job_id,
    j1.job_status pj_status,
    j1.credential_oid cred_oid
    FROM scheduler$_job j1, user$ u, obj$ o 
      WHERE j1.obj# = o.obj# AND o.owner# = u.user# 
                    AND o.owner# = USERENV('SCHEMAID')) j0
   WHERE j0.dest_oid = d0.dest_grp_id
    and (j0.cred_oid is null or j0.cred_oid != coalesce(d0.cred_oid, 0)
        or not exists (select 1 from scheduler$_wingrp_member wm
               where  wm.oid = d0.dest_grp_id
               and wm.member_oid2 is null
               and wm.member_oid = d0.dest_oid))) dd 
WHERE 
   lj.parent_job_id (+) = dd.parent_job_id and
   lj.dest_oid (+) = dd.dest_oid
   and (dd.pj_enbl = 1 or lj.dest_oid is not null) 
UNION ALL
  SELECT o1.name, o1.subname, j1.credential_owner, j1.credential_name,
    j1.destination_owner, j1.destination,
    j1.job_dest_id, DECODE(BITAND(j1.job_status,1),0,'FALSE','TRUE'),
    decode(jd1.enabled, 'TRUE', 'TRUE', 
           decode(bitand(j1.flags, 274877906944), 0, 'TRUE', 'FALSE')),
    DECODE(BITAND(j1.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
       DECODE(BITAND(j1.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
        (CASE WHEN j1.retry_count>0 AND bitand(j1.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j1.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j1.next_run_date, j1.run_count, 
    decode(bitand(j1.flags, 549755813888), 0, j1.retry_count, 0), 
    j1.failure_count, j1.last_start_date,
    (CASE WHEN j1.last_end_date>j1.last_start_date THEN j1.last_end_date 
     ELSE NULL END)
  FROM 
   (select rj1.obj# obj#, rj1.credential_owner credential_owner, 
           rj1.credential_name credential_name, 
           decode(bitand(rj1.flags, 274877906944), 0, NULL, 
             substr(rj1.destination, 1, instr(rj1.destination, '"')-1))
               destination_owner,
           decode(bitand(rj1.flags, 274877906944), 0, 
              decode(rj1.destination, NULL, 'LOCAL', rj1.destination), 
                 substr(rj1.destination, instr(rj1.destination, '"')+1,
                    length(rj1.destination) - instr(rj1.destination, '"')))
                destination,
           rj1.job_status job_status, rj1.flags flags, 
           rj1.next_run_date next_run_date, rj1.run_count run_count, 
           rj1.retry_count retry_count, rj1.failure_count failure_count,
           rj1.last_start_date last_start_date, rj1.last_end_date last_end_date,
           rj1.job_dest_id job_dest_id
      from scheduler$_job rj1
    union all
    select lj1.obj#, lj1.credential_owner, lj1.credential_name, 
           decode(bitand(lj1.flags, 274877906944), 0, NULL, 
             substr(lj1.destination, 1, instr(lj1.destination, '"')-1)),
           decode(bitand(lj1.flags, 274877906944), 0, 
              decode(lj1.destination, NULL, 'LOCAL', lj1.destination), 
                 substr(lj1.destination, instr(lj1.destination, '"')+1,
                    length(lj1.destination) - instr(lj1.destination, '"'))),
           lj1.job_status, lj1.flags, 
           lj1.next_run_date, lj1.run_count, lj1.retry_count, 
           lj1.failure_count, lj1.last_start_date, lj1.last_end_date,
           lj1.job_dest_id
      from scheduler$_lightweight_job lj1) j1,
    (select ro1.obj# obj#, ro1.owner# owner#, ro1.name name, ro1.subname subname
       from obj$ ro1
     union all
     select lo1.obj#, lo1.userid, lo1.name, lo1.subname
       from scheduler$_lwjob_obj lo1) o1,
    (select dd.owner owner, dd.destination_name dest_name, 
            decode(dd.enabled, 'FALSE', 'FALSE', dd.refs_enabled) enabled
     from all_scheduler_db_dests dd
     union all
     select 'SYS', ed.destination_name, ed.enabled
     from all_scheduler_external_dests ed) jd1
  WHERE j1.obj# = o1.obj# AND o1.owner# = USERENV('SCHEMAID')
    AND bitand(j1.flags, 137438953472) = 0
    AND bitand(j1.flags, 549755813888) = 0
    AND (jd1.owner(+) = j1.destination_owner) 
    AND (jd1.dest_name(+) = j1.destination)
UNION ALL
  SELECT do.name, do.subname, 
    d.credential_owner, d.credential_name, 
    substr(d.destination, 1, instr(d.destination, '"')-1),
    substr(d.destination, instr(d.destination, '"')+1, 
        length(d.destination) - instr(d.destination, '"')),
    d.job_dest_id, 'FALSE', 'FALSE', 'RUNNING', NULL, d.run_count,
    d.retry_count, d.failure_count, d.last_start_date, d.last_end_date
  FROM  scheduler$_lightweight_job d, scheduler$_lwjob_obj do,
        scheduler$_job pj
  WHERE d.obj# = do.obj# and do.userid = USERENV('SCHEMAID')
    and d.program_oid = pj.obj#
    and bitand(d.flags, 8589934592) <> 0
    and bitand(d.job_status, 2) = 2
    and (d.dest_oid is null or 
         d.dest_oid not in 
           (select so.obj# from obj$ so where so.owner# = 0 and so.namespace = 1
            and so.name = 'SCHED$_LOCAL_PSEUDO_DB'))
    and (nvl(d.dest_oid,0), nvl(d.credential_oid,0)) not in 
          (select nvl(wg.member_oid,0), 
             nvl(decode(wg.member_oid2, null, pj.credential_oid, wg.member_oid2), 0) 
           from scheduler$_wingrp_member wg
           where wg.oid = pj.dest_oid)
/
COMMENT ON TABLE user_scheduler_job_dests IS
'State of all jobs owned by current user at each of their destinations'
/
COMMENT ON COLUMN user_scheduler_job_dests.job_name IS
'Name of scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_dests.job_subname IS
'Subname of scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_dests.credential_owner IS
'Owner of credential used for remote destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.credential_name IS
'Name of credential used for remote destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.destination_owner IS
'Owner of destination object that points to destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.destination IS
'Name of destination object or name of destination itself'
/
COMMENT ON COLUMN user_scheduler_job_dests.job_dest_id IS 
'Numerical ID assigned to job at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.enabled IS
'Is this job enabled at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.state IS
'State of this job at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.next_start_date IS
'Next start time of this job at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.run_count IS
'Number of times this job has run at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.retry_count IS
'Number of times this job has been retried at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.failure_count IS
'Number of times this job has failed at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.last_start_date IS
'Last time this job started at this destination'
/
COMMENT ON COLUMN user_scheduler_job_dests.last_end_date IS
'Last time this job ended at this destination'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_dests
   FOR user_scheduler_job_dests
/
GRANT SELECT ON user_scheduler_job_dests TO public with grant option
/
CREATE OR REPLACE VIEW all_scheduler_job_dests
  ( OWNER, JOB_NAME, JOB_SUBNAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, 
    DESTINATION_OWNER, DESTINATION, JOB_DEST_ID, ENABLED, 
    REFS_ENABLED, STATE, 
    NEXT_START_DATE, RUN_COUNT, RETRY_COUNT, FAILURE_COUNT, 
    LAST_START_DATE, LAST_END_DATE )
AS
SELECT  dd.OWNER, dd.JOB_NAME, dd.JOB_SUBNAME, 
        decode(dd.local, 'X', null, CREDENTIAL_OWNER),
        decode(dd.local, 'X', null,dd.CREDENTIAL_NAME),
        decode(dd.local, 'N', dd.DESTINATION_OWNER, null), 
        decode(dd.local, 'N', dd.DESTINATION_NAME, 'LOCAL'),
        lj.JOB_DEST_ID, 
        decode(dd.pj_enbl, 1, 'TRUE', 'FALSE'),
        dd.ENABLED,
        (CASE WHEN (bitand(dd.pj_status,4+8+16+32+8192+524288) > 0 OR
                    (lj.STATE <> 'RUNNING' AND bitand(dd.pj_status, 1) = 0))
                 THEN  'DISABLED'
                 ELSE  coalesce(lj.STATE, 'SCHEDULED') END), 
        dd.next_run_date NEXT_START_DATE, 
        coalesce(lj.RUN_COUNT,0), 
        coalesce(lj.RETRY_COUNT,0), 
        coalesce(lj.FAILURE_COUNT,0), 
        lj.LAST_START_DATE, lj.LAST_END_DATE 
FROM 
(SELECT 
  d.job_dest_id JOB_DEST_ID, 
  DECODE(BITAND(d.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(d.job_status,1+4+8+16+32+128+8192),0,'SCHEDULED',1,
      (CASE WHEN d.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(d.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)) STATE,
    d.run_count, d.retry_count, d.failure_count, 
    d.last_start_date, d.last_end_date, d.program_oid parent_job_id,d.dest_oid
  FROM  scheduler$_lightweight_job d) lj,
(SELECT 
     j0.OWNER, j0.JOB_NAME, 
     'SCHED$_MD_' 
     || TO_CHAR(coalesce(d0.dest_oid,j0.dest_oid), 'FMXXXXXXXXX') || '_' 
     || TO_CHAR(decode(d0.local, 'X', 0,
                   coalesce(d0.cred_oid,j0.cred_oid)), 'FMXXXXXXXXX') JOB_SUBNAME,
     coalesce(d0.credential_owner,j0.credential_owner) credential_owner,
     coalesce(d0.credential_name,j0.credential_name) credential_name,
     d0.destination_owner,
     d0.destination_name,
     decode(d0.en_flag+j0.en_flag, 2, 'TRUE', 'FALSE') enabled,
     j0.en_flag pj_enbl,  j0.pj_status,
     j0.next_run_date, j0.parent_job_id, d0.dest_oid, d0.local 
FROM 
( SELECT cmu.name credential_owner,  cmo.name credential_name, 
      wmu.name destination_owner, wmo.name destination_name, 
      bitand(d.flags, bitand(w.flags,bitand(coalesce(ad.flags,1),1))) en_flag,
      w.obj# dest_grp_id, 
      wg.member_oid2 cred_oid,
      wg.member_oid dest_oid,
      decode(bitand(d.flags, 12),12, 'X',8, 'Y','N') local
  FROM  scheduler$_window_group w, scheduler$_wingrp_member wg,
      scheduler$_destinations d, scheduler$_destinations ad, 
      user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
  WHERE w.obj# = wg.oid  
       AND wg.member_oid = wmo.obj# 
       AND wmo.owner# = wmu.user# 
       AND wg.member_oid = d.obj# 
       AND cmo.obj#(+) = wg.member_oid2 
       AND d.agtdestoid = ad.obj#(+)
       AND cmo.owner# = cmu.user#(+)) d0, 
(SELECT  j1.credential_owner, j1.credential_name, 
    substr(j1.destination, 1, instr(j1.destination, '"')-1) destination_owner,
    substr(j1.destination, instr(j1.destination, '"')+1, 
       length(j1.destination) - instr(j1.destination, '"')) destination_name,
    bitand(j1.job_status, 1) en_flag,
    j1.job_status pj_status,
    j1.dest_oid,
    j1.next_run_date,
    u.name OWNER, o.name JOB_NAME, o.subname JOB_SUBNAME,
    j1.obj# parent_job_id,
    j1.credential_oid cred_oid
    FROM scheduler$_job j1, user$ u, obj$ o 
              WHERE j1.obj# = o.obj# AND o.owner# = u.user# 
                AND (o.owner# = userenv('SCHEMAID')
                      or o.obj# in
                           (select oa.obj#
                            from sys.objauth$ oa
                            where grantee# in ( select kzsrorol
                                                from x$kzsro
                                              )
                           )
                      or /* user has system privileges */
                        (exists (select null from v$enabledprivs
                                where priv_number = -265
                                )
                         and o.owner#!=0)
                     )
            ) j0
       WHERE j0.dest_oid = d0.dest_grp_id
    and (j0.cred_oid is null or j0.cred_oid != coalesce(d0.cred_oid, 0) 
        or not exists (select 1 from scheduler$_wingrp_member wm
                    where  wm.oid = d0.dest_grp_id
                      and wm.member_oid2 is null
                      and wm.member_oid = d0.dest_oid))) dd 
WHERE 
   lj.parent_job_id (+) = dd.parent_job_id and
   lj.dest_oid (+) = dd.dest_oid
   and (dd.pj_enbl = 1 or lj.dest_oid is not null) 
UNION ALL
  SELECT u1.name, o1.name, o1.subname, j1.credential_owner, j1.credential_name,
    j1.destination_owner, j1.destination,
    j1.job_dest_id, DECODE(BITAND(j1.job_status,1),0,'FALSE','TRUE'),
    decode(jd1.enabled, 'TRUE', 'TRUE',
           decode(bitand(j1.flags, 274877906944), 0, 'TRUE', 'FALSE')),
    DECODE(BITAND(j1.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
       DECODE(BITAND(j1.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
        (CASE WHEN j1.retry_count>0 AND bitand(j1.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j1.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j1.next_run_date, j1.run_count, 
    decode(bitand(j1.flags, 549755813888), 0, j1.retry_count, 0),
    j1.failure_count, j1.last_start_date,
    (CASE WHEN j1.last_end_date>j1.last_start_date THEN j1.last_end_date 
     ELSE NULL END)
  FROM
   (select rj1.obj# obj#, rj1.credential_owner credential_owner, 
           rj1.credential_name credential_name, 
           decode(bitand(rj1.flags, 274877906944), 0, NULL, 
             substr(rj1.destination, 1, instr(rj1.destination, '"')-1))
               destination_owner,
           decode(bitand(rj1.flags, 274877906944), 0, 
              decode(rj1.destination, NULL, 'LOCAL', rj1.destination), 
                 substr(rj1.destination, instr(rj1.destination, '"')+1,
                    length(rj1.destination) - instr(rj1.destination, '"')))
                destination,
           rj1.job_status job_status, rj1.flags flags, 
           rj1.next_run_date next_run_date, rj1.run_count run_count, 
           rj1.retry_count retry_count, rj1.failure_count failure_count,
           rj1.last_start_date last_start_date, rj1.last_end_date last_end_date,
           rj1.job_dest_id job_dest_id
      from scheduler$_job rj1
    union all
    select lj1.obj#, lj1.credential_owner, lj1.credential_name, 
           decode(bitand(lj1.flags, 274877906944), 0, NULL, 
             substr(lj1.destination, 1, instr(lj1.destination, '"')-1)),
           decode(bitand(lj1.flags, 274877906944), 0, 
              decode(lj1.destination, NULL, 'LOCAL', lj1.destination), 
                 substr(lj1.destination, instr(lj1.destination, '"')+1,
                    length(lj1.destination) - instr(lj1.destination, '"'))),
           lj1.job_status, lj1.flags, 
           lj1.next_run_date, lj1.run_count, lj1.retry_count, 
           lj1.failure_count, lj1.last_start_date, lj1.last_end_date,
           lj1.job_dest_id
      from scheduler$_lightweight_job lj1) j1,
    (select ro1.obj# obj#, ro1.owner# owner#, ro1.name name, ro1.subname subname
       from obj$ ro1
     union all
     select lo1.obj#, lo1.userid, lo1.name, lo1.subname
       from scheduler$_lwjob_obj lo1) o1,
    user$ u1,
    (select dd.owner owner, dd.destination_name dest_name, 
            decode(dd.enabled, 'FALSE', 'FALSE', dd.refs_enabled) enabled
     from all_scheduler_db_dests dd
     union all
     select 'SYS', ed.destination_name, ed.enabled
     from all_scheduler_external_dests ed) jd1
  WHERE j1.obj# = o1.obj# AND o1.owner# = u1.user# 
    AND bitand(j1.flags, 137438953472) = 0
    AND bitand(j1.flags, 549755813888) = 0
    AND (jd1.owner(+) = j1.destination_owner) 
    AND (jd1.dest_name(+) = j1.destination)
    AND (o1.owner# = userenv('SCHEMAID')
                      or o1.obj# in
                           (select oa.obj#
                            from sys.objauth$ oa
                            where grantee# in ( select kzsrorol
                                                from x$kzsro
                                              )
                           )
                      or /* user has system privileges */
                        (exists (select null from v$enabledprivs
                                where priv_number = -265
                                )
                         and o1.owner#!=0)
                     )
UNION ALL
  SELECT du.name, do.name, do.subname, 
    d.credential_owner, d.credential_name, 
    substr(d.destination, 1, instr(d.destination, '"')-1),
    substr(d.destination, instr(d.destination, '"')+1, 
        length(d.destination) - instr(d.destination, '"')),
    d.job_dest_id, 'FALSE', 'FALSE', 'RUNNING', NULL, d.run_count,
    d.retry_count, d.failure_count, d.last_start_date, d.last_end_date
  FROM  scheduler$_lightweight_job d, user$ du, scheduler$_lwjob_obj do,
        scheduler$_job pj
  WHERE d.obj# = do.obj# and do.userid = du.user# and d.program_oid = pj.obj#
    and bitand(d.flags, 8589934592) <> 0
    and bitand(d.job_status, 2) = 2
    and (d.dest_oid is null or 
         d.dest_oid not in 
           (select so.obj# from obj$ so where so.owner# = 0 and so.namespace = 1
            and so.name = 'SCHED$_LOCAL_PSEUDO_DB'))
    and (nvl(d.dest_oid,0), nvl(d.credential_oid,0)) not in 
          (select nvl(wg.member_oid,0), 
             nvl(decode(wg.member_oid2, null, pj.credential_oid, wg.member_oid2), 0) 
           from scheduler$_wingrp_member wg
           where wg.oid = pj.dest_oid)
    and (do.userid =   userenv('SCHEMAID') or
       d.program_oid IN 
       (SELECT oa.obj#
        from sys.objauth$ oa
        where grantee# in (select kzsrorol from x$kzsro)) OR
     (EXISTS (select null from v$enabledprivs
                           where priv_number in (-265 /* CREATE ANY JOB */,
                                          -255 /* EXPORT FULL DATABASE */ )
                 )
          and do.userid!=0)) 
/

COMMENT ON TABLE all_scheduler_job_dests IS
'State of all jobs visible to current user at each of their destinations'
/
COMMENT ON COLUMN all_scheduler_job_dests.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_dests.job_name IS
'Name of scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_dests.job_subname IS
'Subname of scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_dests.credential_owner IS
'Owner of credential used for remote destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.credential_name IS
'Name of credential used for remote destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.destination_owner IS
'Owner of destination object that points to destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.destination IS
'Name of destination object or name of destination itself'
/
COMMENT ON COLUMN all_scheduler_job_dests.job_dest_id IS 
'Numerical ID assigned to job at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.enabled IS
'Is this job enabled at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.state IS
'State of this job at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.next_start_date IS
'Next start time of this job at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.run_count IS
'Number of times this job has run at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.retry_count IS
'Number of times this job has been retried at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.failure_count IS
'Number of times this job has failed at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.last_start_date IS
'Last time this job started at this destination'
/
COMMENT ON COLUMN all_scheduler_job_dests.last_end_date IS
'Last time this job ended at this destination'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_dests
   FOR all_scheduler_job_dests
/
GRANT SELECT ON all_scheduler_job_dests TO public with grant option
/

CREATE OR REPLACE VIEW dba_scheduler_jobs
  ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_STYLE, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, 
    FILE_WATCHER_OWNER, FILE_WATCHER_NAME, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, NUMBER_OF_DESTINATIONS,
    DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER,
    CREDENTIAL_NAME, INSTANCE_ID, DEFERRED_DROP, ALLOW_RUNS_IN_RESTRICTED_MODE,
    COMMENTS, FLAGS )
  AS SELECT ju.name, jo.name, jo.subname, 'REGULAR',
    j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER', 
      134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,1,instr(j.fw_name,'"')-1)),
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,instr(j.fw_name,'"') + 1,
        length(j.fw_name)-instr(j.fw_name,'"'))),
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    (CASE WHEN j.job_dest_id <> 0 AND 
     bitand(j.flags, 549755813888) <> 0 THEN 'RUNNING'
     ELSE
     DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
       DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192+524288),0,'DISABLED',1,
        (CASE WHEN j.retry_count>0 AND bitand(j.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', 
        524288, 'SOME FAILED', NULL))END),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    decode(bitand(j.flags, 549755813888), 0, j.retry_count, 0),
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'),
    /* BITAND(j.job_status, 16711680)/65536, */
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, 
    decode(bitand(j.flags, 274877906944), 0, 1,
    decode(bitand(j.flags, 549755813888), 0, 1,
    (select count(*) from dba_scheduler_job_dests djd
     where djd.owner = ju.name and djd.job_name = jo.name))),
    decode(bitand(j.flags, 274877906944), 0, NULL, 
       substr(j.destination, 1, instr(j.destination, '"')-1)),
    decode(bitand(j.flags, 274877906944), 0, j.destination,
    substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
    j.credential_owner, j.credential_name,
    j.instance_id, 
    DECODE(BITAND(j.job_status,131072),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,17179869184),0,'FALSE','TRUE'),
    j.comments, j.flags
  FROM obj$ jo, user$ ju, obj$ co, sys.scheduler$_job j, v$database v
  WHERE j.obj# = jo.obj# AND jo.owner# = ju.user# AND j.class_oid = co.obj#(+)
  AND (j.database_role = v.database_role OR 
      (j.database_role is null AND v.database_role = 'PRIMARY'))
 UNION ALL 
  SELECT lu.name, lo.name, lo.subname, 'LIGHTWEIGHT', l.creator, l.client_id, l.guid,
    lu.name, po.name, NULL, NULL, NULL, 
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,1,instr(l.schedule_expr,'"')-1)),
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,instr(l.schedule_expr,'"') + 1,
        length(l.schedule_expr)-instr(l.schedule_expr,'"'))),
    DECODE(BITAND(l.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER', 
      134217728,'EVENT',NULL),
    l.start_date,
    DECODE(BITAND(l.flags,1024+4096+134217728), 0, l.schedule_expr, NULL),
    l.queue_owner, l.queue_name, l.queue_agent, 
    DECODE(BITAND(l.flags,134217728), 0, NULL, 
      DECODE(BITAND(l.flags,1024+4096), 0, l.schedule_expr, NULL)),
    l.event_rule, 
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,1,instr(l.fw_name,'"')-1)),
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,instr(l.fw_name,'"') + 1,
        length(l.fw_name)-instr(l.fw_name,'"'))),
    l.end_date, lco.name,
    DECODE(BITAND(l.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(l.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(l.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(l.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN l.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(l.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    NULL, l.run_count, NULL, l.failure_count, NULL,
    l.retry_count, l.last_start_date,
    (CASE WHEN l.last_end_date>l.last_start_date THEN l.last_end_date-l.last_start_date
       ELSE NULL END), l.next_run_date,
    NULL, NULL, 
    DECODE(BITAND(l.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(l.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,16),0,'FALSE','TRUE'),
    /* BITAND(j.job_status, 16711680)/65536, */
    sys.dbms_scheduler.generate_event_list(l.job_status),
    DECODE(BITAND(l.flags,16777216),0,'FALSE','TRUE'),
    NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, l.instance_id, 
    DECODE(BITAND(l.job_status,131072),0,'FALSE','TRUE'), 
    DECODE(BITAND(l.flags,17179869184),0,'FALSE','TRUE'),
    NULL, l.flags
  FROM scheduler$_lwjob_obj lo, user$ lu, obj$ lco, 
    scheduler$_lightweight_job l, obj$ po
  WHERE ((bitand(l.flags, 8589934592) = 0 AND po.type# = 67) OR
         (bitand(l.flags, 8589934592) <> 0 AND po.type# = 66))
    AND bitand(l.flags, 137438953472) = 0 
    AND l.obj# = lo.obj# AND l.program_oid = po.obj#
    AND lo.userid = lu.user# AND l.class_oid = lco.obj#(+)
/
COMMENT ON TABLE dba_scheduler_jobs IS
'All scheduler jobs in the database'
/
COMMENT ON COLUMN dba_scheduler_jobs.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN dba_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN dba_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN dba_scheduler_jobs.file_watcher_owner IS
'Owner of file watcher on which this job is based'
/
COMMENT ON COLUMN dba_scheduler_jobs.file_watcher_name IS
'Name of file watcher on which this job is based'
/
COMMENT ON COLUMN dba_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN dba_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN dba_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN dba_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN dba_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN dba_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN dba_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN dba_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN dba_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN dba_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN dba_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.client_id IS
'Client id of user creating job'
/
COMMENT ON COLUMN dba_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN dba_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN dba_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN dba_scheduler_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN dba_scheduler_jobs.destination IS
'Destination that this job will run on'
/
COMMENT ON COLUMN dba_scheduler_jobs.credential_owner IS
'Owner of login credential'
/
COMMENT ON COLUMN dba_scheduler_jobs.credential_name IS
'Name of login credential'
/
COMMENT ON COLUMN dba_scheduler_jobs.flags IS
'This column is for internal use.'
/
COMMENT ON COLUMN dba_scheduler_jobs.instance_id IS
'Instance user requests job to run on.'
/
COMMENT ON COLUMN dba_scheduler_jobs.deferred_drop IS
'Whether this job will be dropped when completed due to user request.'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_jobs
  FOR dba_scheduler_jobs
/
GRANT SELECT ON dba_scheduler_jobs TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_jobs
  ( JOB_NAME, JOB_SUBNAME, JOB_STYLE, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, 
    FILE_WATCHER_OWNER, FILE_WATCHER_NAME, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, NUMBER_OF_DESTINATIONS,
    DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER,
    CREDENTIAL_NAME, INSTANCE_ID, DEFERRED_DROP, ALLOW_RUNS_IN_RESTRICTED_MODE,
    COMMENTS, FLAGS )
  AS SELECT jo.name, jo.subname, 'REGULAR', j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER',
      134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,1,instr(j.fw_name,'"')-1)),
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,instr(j.fw_name,'"') + 1,
        length(j.fw_name)-instr(j.fw_name,'"'))),
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    (CASE WHEN j.job_dest_id <> 0 AND 
     bitand(j.flags, 549755813888) <> 0 THEN 'RUNNING'
     ELSE
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192+524288),0,'DISABLED',1,
      (CASE WHEN j.retry_count>0 AND bitand(j.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', 
      524288, 'SOME FAILED', NULL)) END),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    decode(bitand(j.flags, 549755813888), 0, j.retry_count, 0),
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'), 
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, 
    decode(bitand(j.flags, 274877906944), 0, 1,
    decode(bitand(j.flags, 549755813888), 0, 1,
    (select count(*) from user_scheduler_job_dests ujd 
     where ujd.job_name = jo.name))),
    decode(bitand(j.flags, 274877906944), 0, NULL, 
       substr(j.destination, 1, instr(j.destination, '"')-1)),
    decode(bitand(j.flags, 274877906944), 0, j.destination,
    substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
    j.credential_owner, j.credential_name,
    j.instance_id, 
    DECODE(BITAND(j.job_status,131072),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,17179869184),0,'FALSE','TRUE'),
    j.comments, j.flags
  FROM sys.scheduler$_job j, obj$ jo, obj$ co, v$database v
  WHERE j.obj# = jo.obj# AND
    j.class_oid = co.obj#(+) AND jo.owner# = USERENV('SCHEMAID')
  AND (j.database_role = v.database_role OR 
      (j.database_role is null AND v.database_role = 'PRIMARY'))
 UNION ALL
  SELECT lo.name, lo.subname, 'LIGHTWEIGHT', l.creator, l.client_id, l.guid,
    lu.name, po.name, NULL, NULL, NULL, 
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,1,instr(l.schedule_expr,'"')-1)),
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,instr(l.schedule_expr,'"') + 1,
        length(l.schedule_expr)-instr(l.schedule_expr,'"'))),
    DECODE(BITAND(l.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER', 
      134217728,'EVENT',NULL),
    l.start_date,
    DECODE(BITAND(l.flags,1024+4096+134217728), 0, l.schedule_expr, NULL),
    l.queue_owner, l.queue_name, l.queue_agent, 
    DECODE(BITAND(l.flags,134217728), 0, NULL, 
      DECODE(BITAND(l.flags,1024+4096), 0, l.schedule_expr, NULL)),
    l.event_rule, 
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,1,instr(l.fw_name,'"')-1)),
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,instr(l.fw_name,'"') + 1,
        length(l.fw_name)-instr(l.fw_name,'"'))),
    l.end_date, lco.name,
    DECODE(BITAND(l.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(l.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(l.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(l.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN l.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(l.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    NULL, l.run_count, NULL, l.failure_count, NULL,
    l.retry_count, l.last_start_date,
    (CASE WHEN l.last_end_date>l.last_start_date THEN l.last_end_date-l.last_start_date
       ELSE NULL END), l.next_run_date,
    NULL, NULL, 
    DECODE(BITAND(l.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(l.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,16),0,'FALSE','TRUE'),
    /* BITAND(j.job_status, 16711680)/65536, */
    sys.dbms_scheduler.generate_event_list(l.job_status),
    DECODE(BITAND(l.flags,16777216),0,'FALSE','TRUE'),
    NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, l.instance_id, 
    DECODE(BITAND(l.job_status,131072),0,'FALSE','TRUE'), 
    DECODE(BITAND(l.flags,17179869184),0,'FALSE','TRUE'),
    NULL, l.flags
  FROM scheduler$_lwjob_obj lo, user$ lu, obj$ lco, 
    scheduler$_lightweight_job l, obj$ po
  WHERE ((bitand(l.flags, 8589934592) = 0 AND po.type# = 67) OR
         (bitand(l.flags, 8589934592) <> 0 AND po.type# = 66))
    AND bitand(l.flags, 137438953472) = 0
    AND l.obj# = lo.obj# AND l.program_oid = po.obj# 
    AND lo.userid = lu.user# AND 
    l.class_oid = lco.obj#(+) AND lu.user# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_jobs IS
'All scheduler jobs in the database'
/
COMMENT ON COLUMN user_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN user_scheduler_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN user_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN user_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN user_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN user_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN user_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN user_scheduler_jobs.file_watcher_owner IS
'Owner of file watcher on which this job is based'
/
COMMENT ON COLUMN user_scheduler_jobs.file_watcher_name IS
'Name of file watcher on which this job is based'
/
COMMENT ON COLUMN user_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN user_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN user_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN user_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN user_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN user_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN user_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN user_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN user_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN user_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN user_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN user_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN user_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN user_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN user_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN user_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN user_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN user_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.client_id IS
'Client id of user creating this job'
/
COMMENT ON COLUMN user_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN user_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN user_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN user_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN user_scheduler_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN user_scheduler_jobs.destination IS
'Destination that this job will run on'
/
COMMENT ON COLUMN user_scheduler_jobs.credential_owner IS
'Owner of login credential'
/
COMMENT ON COLUMN user_scheduler_jobs.credential_name IS
'Name of login credential'
/
COMMENT ON COLUMN user_scheduler_jobs.flags IS
'This column is for internal use.'
/
COMMENT ON COLUMN user_scheduler_jobs.instance_id IS
'Instance user requests job to run on.'
/
COMMENT ON COLUMN user_scheduler_jobs.deferred_drop IS
'Whether this job will be dropped when completed due to user request.'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_jobs
  FOR user_scheduler_jobs
/
GRANT SELECT ON user_scheduler_jobs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_jobs
  ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_STYLE, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, 
    FILE_WATCHER_OWNER, FILE_WATCHER_NAME, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, NUMBER_OF_DESTINATIONS,
    DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER,
    CREDENTIAL_NAME, INSTANCE_ID, DEFERRED_DROP, ALLOW_RUNS_IN_RESTRICTED_MODE,
    COMMENTS, FLAGS )
  AS SELECT ju.name, jo.name, jo.subname, 'REGULAR', j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER',
      134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,1,instr(j.fw_name,'"')-1)),
    DECODE(BITAND(j.flags, 34359738368), 0, NULL, 
      substr(j.fw_name,instr(j.fw_name,'"') + 1,
        length(j.fw_name)-instr(j.fw_name,'"'))),
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    (CASE WHEN j.job_dest_id <> 0 AND
     bitand(j.flags, 549755813888) <> 0 THEN 'RUNNING'
     ELSE
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192+524288),0,'DISABLED',1,
      (CASE WHEN j.retry_count>0 AND bitand(j.flags, 549755813888) = 0
            THEN 'RETRY SCHEDULED' 
            WHEN (bitand(j.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', 
      524288, 'SOME FAILED', NULL)) END),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    decode(bitand(j.flags, 549755813888), 0, j.retry_count, 0),
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'), 
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, 
    decode(bitand(j.flags, 274877906944), 0, 1,
    decode(bitand(j.flags, 549755813888), 0, 1,
    (select count(*) from all_scheduler_job_dests ajd
     where ajd.owner = ju.name and ajd.job_name = jo.name))),
    decode(bitand(j.flags, 274877906944), 0, NULL, 
       substr(j.destination, 1, instr(j.destination, '"')-1)),
    decode(bitand(j.flags, 274877906944), 0, j.destination,
    substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
    j.credential_owner, j.credential_name,
    j.instance_id,
    DECODE(BITAND(j.job_status,131072),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,17179869184),0,'FALSE','TRUE'),
    j.comments, j.flags
  FROM obj$ jo, user$ ju, sys.scheduler$_job j, obj$ co, v$database v
  WHERE j.obj# = jo.obj# AND jo.owner# = ju.user# AND
    j.class_oid = co.obj#(+) AND
   (j.database_role = v.database_role OR 
      (j.database_role is null AND v.database_role = 'PRIMARY')) AND
    (jo.owner# = userenv('SCHEMAID')
       or jo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                    where priv_number in (-265 /* CREATE ANY JOB */,
                                          -255 /* EXPORT FULL DATABASE */ )
                 )
          and jo.owner#!=0)
       )
 UNION ALL
  SELECT lu.name, lo.name, lo.subname, 'LIGHTWEIGHT', l.creator, l.client_id, l.guid,
    lu.name, po.name, NULL, NULL, NULL, 
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,1,instr(l.schedule_expr,'"')-1)),
    DECODE(bitand(l.flags,1024+4096),0,NULL,
      substr(l.schedule_expr,instr(l.schedule_expr,'"') + 1,
        length(l.schedule_expr)-instr(l.schedule_expr,'"'))),
    DECODE(BITAND(l.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER', 
      134217728,'EVENT',NULL),
    l.start_date,
    DECODE(BITAND(l.flags,1024+4096+134217728), 0, l.schedule_expr, NULL),
    l.queue_owner, l.queue_name, l.queue_agent, 
    DECODE(BITAND(l.flags,134217728), 0, NULL, 
      DECODE(BITAND(l.flags,1024+4096), 0, l.schedule_expr, NULL)),
    l.event_rule, 
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,1,instr(l.fw_name,'"')-1)),
    DECODE(BITAND(l.flags, 34359738368), 0, NULL, 
      substr(l.fw_name,instr(l.fw_name,'"') + 1,
        length(l.fw_name)-instr(l.fw_name,'"'))),
    l.end_date, lco.name,
    DECODE(BITAND(l.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(l.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(l.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(l.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN l.retry_count>0 THEN 'RETRY SCHEDULED' 
            WHEN (bitand(l.job_status, 1024) <> 0) THEN 'READY TO RUN'
            ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    NULL, l.run_count, NULL, l.failure_count, NULL,
    l.retry_count, l.last_start_date,
    (CASE WHEN l.last_end_date>l.last_start_date THEN l.last_end_date-l.last_start_date
       ELSE NULL END), l.next_run_date,
    NULL, NULL, 
    DECODE(BITAND(l.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL),
    DECODE(BITAND(l.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(l.flags,16),0,'FALSE','TRUE'),
    /* BITAND(j.job_status, 16711680)/65536, */
    sys.dbms_scheduler.generate_event_list(l.job_status),
    DECODE(BITAND(l.flags,16777216),0,'FALSE','TRUE'),
    NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, l.instance_id, 
    DECODE(BITAND(l.job_status,131072),0,'FALSE','TRUE'), 
    DECODE(BITAND(l.flags,17179869184),0,'FALSE','TRUE'),
    NULL, l.flags
  FROM scheduler$_lwjob_obj lo, user$ lu, obj$ lco, 
    scheduler$_lightweight_job l, obj$ po
  WHERE ((bitand(l.flags, 8589934592) = 0 AND po.type# = 67) OR
         (bitand(l.flags, 8589934592) <> 0 AND po.type# = 66))
    AND bitand(l.flags, 137438953472) = 0 
    AND l.obj# = lo.obj# AND l.program_oid = po.obj#
    AND lo.userid = lu.user# AND l.class_oid = lco.obj#(+) AND
    (lo.userid = userenv('SCHEMAID') OR
     po.obj# IN 
       (SELECT oa.obj#
        from sys.objauth$ oa
        where grantee# in (select kzsrorol from x$kzsro)) OR
     (EXISTS (select null from v$enabledprivs
                           where priv_number in (-265 /* CREATE ANY JOB */,
                                          -255 /* EXPORT FULL DATABASE */ )
                 )
          and lo.userid!=0))
/
COMMENT ON TABLE all_scheduler_jobs IS
'All scheduler jobs visible to the user'
/
COMMENT ON COLUMN all_scheduler_jobs.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN all_scheduler_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN all_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN all_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN all_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN all_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN all_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN all_scheduler_jobs.file_watcher_owner IS
'Owner of file watcher on which this job is based'
/
COMMENT ON COLUMN all_scheduler_jobs.file_watcher_name IS
'Name of file watcher on which this job is based'
/
COMMENT ON COLUMN all_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN all_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN all_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN all_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN all_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN all_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN all_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN all_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN all_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN all_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN all_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN all_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN all_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN all_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN all_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN all_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN all_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.client_id IS
'Client id of user creating this job'
/
COMMENT ON COLUMN all_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN all_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN all_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN all_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN all_scheduler_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN all_scheduler_jobs.destination IS
'Destination that this job will run on'
/
COMMENT ON COLUMN all_scheduler_jobs.credential_owner IS
'Owner of the login credential'
/
COMMENT ON COLUMN all_scheduler_jobs.credential_name IS
'Name of the login credential'
/
COMMENT ON COLUMN all_scheduler_jobs.flags IS
'This column is for internal use.'
/
COMMENT ON COLUMN all_scheduler_jobs.instance_id IS
'Instance user requests job to run on.'
/
COMMENT ON COLUMN all_scheduler_jobs.deferred_drop IS
'Whether this job will be dropped when completed due to user request.'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_jobs
  FOR all_scheduler_jobs
/
GRANT SELECT ON all_scheduler_jobs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_job_roles
  ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_CREATOR, DATABASE_ROLE, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, JOB_ACTION, JOB_CLASS,
    SCHEDULE_OWNER, SCHEDULE_NAME, SCHEDULE_TYPE, 
    START_DATE, REPEAT_INTERVAL, END_DATE, LAST_START_DATE,
    ENABLED, STATE, COMMENTS )
  AS SELECT ju.name, jo.name, jo.subname, j.creator, 
    COALESCE(j.database_role, 'PRIMARY'),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL),
    co.name,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728+34359738368), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',34493956096, 'FILE_WATCHER', 
      134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.end_date,
    j.last_start_date,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
      DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
        (CASE WHEN j.retry_count>0 AND bitand(j.flags, 549755813888) = 0
         THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
         4,'COMPLETED',8,'BROKEN',16,'FAILED',
         32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j.comments
  FROM obj$ jo, user$ ju, obj$ co, sys.scheduler$_job j
  WHERE j.obj# = jo.obj# AND jo.owner# = ju.user# AND j.class_oid = co.obj#(+)
/
COMMENT ON TABLE dba_scheduler_job_roles IS
'All scheduler jobs in the database by database role'
/
COMMENT ON COLUMN dba_scheduler_job_roles.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN dba_scheduler_job_roles.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN dba_scheduler_job_roles.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN dba_scheduler_job_roles.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_job_roles.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN dba_scheduler_job_roles.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_job_roles.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN dba_scheduler_job_roles.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_job_roles.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_job_roles.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.comments IS
'Comments on the job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.state IS
'Current state of the job'
/
COMMENT ON COLUMN dba_scheduler_job_roles.enabled IS
'Whether the job is enabled'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_roles
  FOR dba_scheduler_job_roles
/
GRANT SELECT ON dba_scheduler_job_roles TO select_catalog_role
/

CREATE OR REPLACE VIEW dba_scheduler_job_classes
  ( JOB_CLASS_NAME, RESOURCE_CONSUMER_GROUP,
    SERVICE, LOGGING_LEVEL, LOG_HISTORY, COMMENTS) AS
  SELECT co.name, c.res_grp_name,
    c.affinity ,
    DECODE(BITAND(c.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL), 
    c.log_history, c.comments
  FROM obj$ co, sys.scheduler$_class c
  WHERE c.obj# = co.obj#
/
COMMENT ON TABLE dba_scheduler_job_classes IS
'All scheduler classes in the database'
/
COMMENT ON COLUMN dba_scheduler_job_classes.job_class_name IS
'Name of the scheduler class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.resource_consumer_group IS
'Resource consumer group associated with the class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.service IS
'Name of the service this class is affined with'
/
COMMENT ON COLUMN dba_scheduler_job_classes.logging_level IS
'Amount of logging that will be done pertaining to this class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.log_history IS
'The history to maintain in the job log (in days) for this class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.comments IS
'Comments on this class'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_classes
  FOR dba_scheduler_job_classes
/
GRANT SELECT ON dba_scheduler_job_classes TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_job_classes
  ( JOB_CLASS_NAME, RESOURCE_CONSUMER_GROUP,
    SERVICE, LOGGING_LEVEL, LOG_HISTORY, COMMENTS) AS
  SELECT co.name, c.res_grp_name,
    c.affinity , 
    DECODE(BITAND(c.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'FAILED RUNS',
      256,'FULL',NULL), 
    c.log_history, c.comments
  FROM obj$ co, sys.scheduler$_class c
  WHERE c.obj# = co.obj# AND
    (co.obj# in
         (select oa.obj#
          from sys.objauth$ oa
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
         )
     or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-267, /* EXECUTE ANY CLASS */
                                       -268  /* MANAGE SCHEDULER */ )
                 )
      )
/
COMMENT ON TABLE all_scheduler_job_classes IS
'All scheduler classes visible to the user'
/
COMMENT ON COLUMN all_scheduler_job_classes.job_class_name IS
'Name of the scheduler class'
/
COMMENT ON COLUMN all_scheduler_job_classes.resource_consumer_group IS
'Resource consumer group associated with the class'
/
COMMENT ON COLUMN all_scheduler_job_classes.service IS
'Name of the service this class is affined with'
/
COMMENT ON COLUMN all_scheduler_job_classes.logging_level IS
'Amount of logging that will be done pertaining to this class'
/
COMMENT ON COLUMN all_scheduler_job_classes.log_history IS
'The history to maintain in the job log (in days) for this class'
/
COMMENT ON COLUMN all_scheduler_job_classes.comments IS
'Comments on this class'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_classes
  FOR all_scheduler_job_classes
/
GRANT SELECT ON all_scheduler_job_classes TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_windows
  ( WINDOW_NAME, RESOURCE_PLAN, SCHEDULE_OWNER, SCHEDULE_NAME, SCHEDULE_TYPE,
    START_DATE, REPEAT_INTERVAL, END_DATE, DURATION, WINDOW_PRIORITY,
    NEXT_START_DATE, LAST_START_DATE, ENABLED, ACTIVE, 
    MANUAL_OPEN_TIME, MANUAL_DURATION, COMMENTS) AS
  SELECT wo.name, w.res_plan, 
    DECODE(bitand(w.flags,16),16,
      substr(w.schedule_expr,1,instr(w.schedule_expr,'"')-1),NULL),
    DECODE(bitand(w.flags,16),16,
      substr(w.schedule_expr,instr(w.schedule_expr,'"')+1,
        length(w.schedule_expr)-instr(w.schedule_expr,'"')) ,NULL),
    (CASE WHEN w.schedule_expr is null THEN 'ONCE'
       ELSE DECODE(bitand(w.flags,16+32),16,'NAMED',32,'CALENDAR',NULL) END),
    w.start_date,
    DECODE(bitand(w.flags,16),0,w.schedule_expr,NULL), w.end_date, w.duration,
    DECODE(w.priority,1,'HIGH',2,'LOW',NULL), w.next_start_date,
    w.actual_start_date,
    DECODE(bitand(w.flags, 1),0,'FALSE',1,'TRUE'),
    DECODE(bitand(w.flags,1+2),2,'TRUE',3,'TRUE','FALSE'), 
    w.manual_open_time, w.manual_duration, w.comments
  FROM obj$ wo, sys.scheduler$_window w
  WHERE w.obj# = wo.obj#
/
COMMENT ON TABLE dba_scheduler_windows IS
'All scheduler windows in the database'
/
COMMENT ON COLUMN dba_scheduler_windows.window_name IS
'Name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_windows.resource_plan IS
'Resource plan associated with the window'
/
COMMENT ON COLUMN dba_scheduler_windows.next_start_date IS
'Next date on which this window is scheduled to start'
/
COMMENT ON COLUMN dba_scheduler_windows.duration IS
'Duration of the window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_name IS
'Name of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_type IS
'Type of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_owner IS
'Owner of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.repeat_interval IS
'Calendar string for this window (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.start_date IS
'Start date of the window (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.end_date IS
'Date after which the window will no longer open (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.last_start_date IS
'The last date on which this window opened'
/
COMMENT ON COLUMN dba_scheduler_windows.window_priority IS
'Priority of this job relative to other windows'
/
COMMENT ON COLUMN dba_scheduler_windows.enabled IS
'True if the window is enabled'
/
COMMENT ON COLUMN dba_scheduler_windows.active IS
'True if the window is open'
/
COMMENT ON COLUMN dba_scheduler_windows.manual_open_time IS
'Open time of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN dba_scheduler_windows.manual_duration IS
'Duration of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN dba_scheduler_windows.comments IS
'Comments on the window'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_windows
  FOR dba_scheduler_windows
/
GRANT SELECT ON dba_scheduler_windows TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_windows AS
  SELECT * FROM dba_scheduler_windows;
/
COMMENT ON TABLE all_scheduler_windows IS
'All scheduler windows in the database'
/
COMMENT ON COLUMN all_scheduler_windows.window_name IS
'Name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_windows.resource_plan IS
'Resource plan associated with the window'
/
COMMENT ON COLUMN all_scheduler_windows.next_start_date IS
'Next date on which this window is scheduled to start'
/
COMMENT ON COLUMN all_scheduler_windows.duration IS
'Duration of the window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_name IS
'Name of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_type IS
'Type of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_owner IS
'Owner of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.repeat_interval IS
'Calendar string for this window (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.start_date IS
'Start date of the window (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.end_date IS
'Date after which the window will no longer open (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.last_start_date IS
'The last date on which this window opened'
/
COMMENT ON COLUMN all_scheduler_windows.window_priority IS
'Priority of this job relative to other windows'
/
COMMENT ON COLUMN all_scheduler_windows.enabled IS
'True if the window is enabled'
/
COMMENT ON COLUMN all_scheduler_windows.active IS
'True if the window is open'
/
COMMENT ON COLUMN all_scheduler_windows.manual_open_time IS
'Open time of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN all_scheduler_windows.manual_duration IS
'Duration of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN all_scheduler_windows.comments IS
'Comments on the window'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_windows
  FOR all_scheduler_windows
/
GRANT SELECT ON all_scheduler_windows TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_program_args
  (OWNER, PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT u.name, o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags, 2+4+64+128+256+1024+2048+8192+16384+32768
         +65536+131072+262144+524288+1048576),
         2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', 
         2048, 'EVENT_MESSAGE', 8192, 'JOB_SCHEDULED_START', 
         16384, 'CHAIN_ID', 32768, 'CREDENTIAL_OWNER',
         65536, 'CREDENTIAL_NAME', 131072, 'DESTINATION_OWNER',
         262144, 'DESTINATION_NAME', 524288, 'JOB_DEST_ID',
         1048576, 'LOG_ID', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_program_argument a, obj$ t_o, user$ t_u
  WHERE a.oid = o.obj# AND u.user# = o.owner#
    AND a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
/
COMMENT ON TABLE dba_scheduler_program_args IS
'All arguments of all scheduler programs in the database'
/
COMMENT ON COLUMN dba_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_program_args.owner IS
'Owner of the program this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN dba_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN dba_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN dba_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN dba_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_program_args
  FOR dba_scheduler_program_args
/
GRANT SELECT ON dba_scheduler_program_args TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_program_args
  (PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags, 2+4+64+128+256+1024+2048+8192+16384+32768
         +65536+131072+262144+524288+1048576),
         2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', 
         2048, 'EVENT_MESSAGE', 8192, 'JOB_SCHEDULED_START', 
         16384, 'CHAIN_ID', 32768, 'CREDENTIAL_OWNER',
         65536, 'CREDENTIAL_NAME', 131072, 'DESTINATION_OWNER',
         262144, 'DESTINATION_NAME', 524288, 'JOB_DEST_ID',
         1048576, 'LOG_ID', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM sys.scheduler$_program_argument a, obj$ t_o, user$ t_u, obj$ o
  WHERE a.oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
    AND a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
/
COMMENT ON TABLE user_scheduler_program_args IS
'All arguments of all scheduler programs in the database'
/
COMMENT ON COLUMN user_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN user_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN user_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN user_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN user_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_program_args
  FOR user_scheduler_program_args
/
GRANT SELECT ON user_scheduler_program_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_program_args
  (OWNER, PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT u.name, o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags, 2+4+64+128+256+1024+2048+8192+16384+32768
         +65536+131072+262144+524288+1048576),
         2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', 
         2048, 'EVENT_MESSAGE', 8192, 'JOB_SCHEDULED_START', 
         16384, 'CHAIN_ID', 32768, 'CREDENTIAL_OWNER',
         65536, 'CREDENTIAL_NAME', 131072, 'DESTINATION_OWNER',
         262144, 'DESTINATION_NAME', 524288, 'JOB_DEST_ID',
         1048576, 'LOG_ID', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_program_argument a, obj$ t_o, user$ t_u
  WHERE a.oid = o.obj# AND u.user# = o.owner# AND
    a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+) AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -255 /* EXPORT FULL DATABASE */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_program_args IS
'All arguments of all scheduler programs visible to the user'
/
COMMENT ON COLUMN all_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_program_args.owner IS
'Owner of the program this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN all_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN all_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN all_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN all_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_program_args
  FOR all_scheduler_program_args
/
GRANT SELECT ON all_scheduler_program_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_job_args
  (OWNER, JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT u.name, o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, (
  SELECT a.oid job_oid, a.position position,
      po.obj# program_oid, a.value value
   FROM  sys.scheduler$_job_argument a
      JOIN sys.scheduler$_job j ON a.oid = j.obj#
      LEFT OUTER JOIN sys.user$ pu ON
       pu.name =  DECODE(bitand(j.flags,4194304),4194304,
          substr(j.program_action,1,instr(j.program_action,'"')-1),'1')
      LEFT OUTER JOIN sys.obj$ po ON
          pu.user#=po.owner# and
          po.name =
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,'1')
    ) t,
    obj$ t_o, user$ t_u,
    sys.scheduler$_program_argument b
  WHERE t.job_oid = o.obj# AND u.user# = o.owner#
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+)
UNION ALL
 SELECT lu.name, lo.name, lb.name, lt.position,
  CASE WHEN (lb.user_type_num IS NULL) THEN
    DECODE(lb.type_number,
0, null,
1, decode(lb.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(lb.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(lb.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(lb.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(lb.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE lt_u.name ||'.'|| lt_o.name END,
  dbms_scheduler.get_varchar2_value(lt.value), lt.value,
  DECODE(BITAND(lb.flags,1),0,'FALSE',1,'TRUE')
  FROM scheduler$_lwjob_obj lo, user$ lu, 
    (SELECT la.oid job_oid, la.position position,
      decode(bitand(lj.flags, 8589934592), 0, lj.program_oid,
             ljp.program_oid) program_oid, 
      la.value value
    FROM sys.scheduler$_lightweight_job lj, sys.scheduler$_job_argument la,
         sys.scheduler$_job ljp
    WHERE lj.program_oid = ljp.obj#(+) and
       bitand(lj.flags, 137438953472) = 0 and
       la.oid = lj.obj#) lt, obj$ lt_o, user$ lt_u,
    sys.scheduler$_program_argument lb
  WHERE lt.job_oid = lo.obj# AND lu.user# = lo.userid
    AND lb.user_type_num = lt_o.obj#(+) AND lt_o.owner# = lt_u.user#(+)
    AND lt.program_oid=lb.oid(+) AND lt.position=lb.position(+)
/
COMMENT ON TABLE dba_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN dba_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_job_args.owner IS
'Owner of the job this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN dba_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN dba_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN dba_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_args
  FOR dba_scheduler_job_args
/
GRANT SELECT ON dba_scheduler_job_args TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_job_args
  (JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM  sys.scheduler$_program_argument b, obj$ t_o, user$ t_u, (
  SELECT a.oid job_oid, a.position position,
      po.obj# program_oid, a.value value
   FROM  sys.scheduler$_job_argument a
      JOIN sys.scheduler$_job j ON a.oid = j.obj#
      LEFT OUTER JOIN sys.user$ pu ON
       pu.name =  DECODE(bitand(j.flags,4194304),4194304,
          substr(j.program_action,1,instr(j.program_action,'"')-1),'1')
      LEFT OUTER JOIN sys.obj$ po ON
          pu.user#=po.owner# and
          po.name =
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,'1')
    ) t,
   obj$ o
  WHERE t.job_oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+)
UNION ALL
SELECT lo.name, lb.name, lt.position,
  CASE WHEN (lb.user_type_num IS NULL) THEN
    DECODE(lb.type_number,
0, null,
1, decode(lb.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(lb.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(lb.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(lb.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(lb.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE lt_u.name ||'.'|| lt_o.name END,
  dbms_scheduler.get_varchar2_value(lt.value), lt.value,
  DECODE(BITAND(lb.flags,1),0,'FALSE',1,'TRUE')
  FROM  sys.scheduler$_program_argument lb, obj$ lt_o, user$ lt_u,
    (SELECT la.oid job_oid, la.position position,
      decode(bitand(lj.flags, 8589934592), 0, lj.program_oid,
             ljp.program_oid) program_oid,
      la.value value
    FROM sys.scheduler$_job_argument la,  sys.scheduler$_lightweight_job lj,
         sys.scheduler$_job ljp
    WHERE lj.program_oid = ljp.obj#(+) and
       bitand(lj.flags, 137438953472) = 0 and
       la.oid = lj.obj#) lt,
   scheduler$_lwjob_obj lo
  WHERE lt.job_oid = lo.obj# AND lo.userid = USERENV('SCHEMAID')
    AND lb.user_type_num = lt_o.obj#(+) AND lt_o.owner# = lt_u.user#(+)
    AND lt.program_oid=lb.oid(+) AND lt.position=lb.position(+)
/
COMMENT ON TABLE user_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN user_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN user_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN user_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN user_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_args
  FOR user_scheduler_job_args
/
GRANT SELECT ON user_scheduler_job_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_job_args
  (OWNER, JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT u.name, o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ t_o, user$ t_u,
    sys.scheduler$_program_argument b, obj$ o, user$ u, (
  SELECT a.oid job_oid, a.position position,
      po.obj# program_oid, a.value value
   FROM  sys.scheduler$_job_argument a
      JOIN sys.scheduler$_job j ON a.oid = j.obj#
      LEFT OUTER JOIN sys.user$ pu ON
       pu.name =  DECODE(bitand(j.flags,4194304),4194304,
          substr(j.program_action,1,instr(j.program_action,'"')-1),'1')
      LEFT OUTER JOIN sys.obj$ po ON
          pu.user#=po.owner# and
          po.name =
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,'1')
    ) t
  WHERE t.job_oid = o.obj# AND u.user# = o.owner#
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+) AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                    where priv_number in (-265 /* CREATE ANY JOB */,
                                          -255 /* EXPORT FULL DATABASE */ )
                 )
          and o.owner#!=0)
      )
UNION ALL
SELECT lu.name, lo.name, lb.name, lt.position,
  CASE WHEN (lb.user_type_num IS NULL) THEN
    DECODE(lb.type_number,
0, null,
1, decode(lb.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(lb.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(lb.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(lb.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(lb.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE lt_u.name ||'.'|| lt_o.name END,
  dbms_scheduler.get_varchar2_value(lt.value), lt.value,
  DECODE(BITAND(lb.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ lt_o, user$ lt_u, sys.obj$ lpo,
    sys.scheduler$_program_argument lb, 
    sys.scheduler$_lwjob_obj lo, user$ lu,
    (SELECT la.oid job_oid, la.position position,
      decode(bitand(lj.flags, 8589934592), 0, lj.program_oid,
             ljp.program_oid) program_oid, lj.program_oid job_prog,
      lj.flags flags, la.value value
    FROM sys.scheduler$_lightweight_job lj, sys.scheduler$_job_argument la,
         sys.scheduler$_job ljp
    WHERE lj.program_oid = ljp.obj#(+) and
       bitand(lj.flags, 137438953472) = 0 and
       la.oid = lj.obj#) lt
  WHERE lt.job_oid = lo.obj# AND lu.user# = lo.userid
    AND lb.user_type_num = lt_o.obj#(+) AND lt_o.owner# = lt_u.user#(+)
    AND lt.program_oid=lb.oid(+) AND lt.position=lb.position(+) AND
        lt.job_prog = lpo.obj# AND
        ((bitand(lt.flags, 8589934592) = 0 and lpo.type# = 67) or
         (bitand(lt.flags, 8589934592) <> 0 and lpo.type# = 66)) AND
    (lo.userid = userenv('SCHEMAID')
       or lt.job_prog in
            (select loa.obj#
             from sys.objauth$ loa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                    where priv_number in (-265 /* CREATE ANY JOB */,
                                          -255 /* EXPORT FULL DATABASE */ )
                 )
          and lo.userid!=0)
      )
/
COMMENT ON TABLE all_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN all_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_job_args.owner IS
'Owner of the job this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN all_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN all_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN all_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_args
  FOR all_scheduler_job_args
/
GRANT SELECT ON all_scheduler_job_args TO public WITH GRANT OPTION
/


/* Job and Window Log views */

CREATE OR REPLACE VIEW dba_scheduler_job_log
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
  WHERE e.type# = 66 and e.dbid is null and e.class_id = co.obj#(+))
/
COMMENT ON TABLE dba_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN dba_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN dba_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN dba_scheduler_job_log.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN dba_scheduler_job_log.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN dba_scheduler_job_log.destination IS
'The destination for a remote job operation'
/
COMMENT ON COLUMN dba_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW dba_scheduler_job_run_details
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
   WHERE j.log_id = e.log_id and e.dbid is null
   AND e.type# = 66)
/
COMMENT ON TABLE dba_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.destination IS
'The destination for a remote job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_log
  FOR dba_scheduler_job_log
/
GRANT SELECT ON dba_scheduler_job_log TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_run_details
  FOR dba_scheduler_job_run_details
/
GRANT SELECT ON dba_scheduler_job_run_details TO select_catalog_role
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
COMMENT ON TABLE user_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN user_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN user_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN user_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN user_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN user_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN user_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN user_scheduler_job_log.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN user_scheduler_job_log.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN user_scheduler_job_log.destination IS
'The destination for a remote job operation'
/
COMMENT ON COLUMN user_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
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
COMMENT ON TABLE user_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN user_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN user_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN user_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN user_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN user_scheduler_job_run_details.destination IS
'The destination for a remote job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_log
  FOR user_scheduler_job_log
/
GRANT SELECT ON user_scheduler_job_log TO public with GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_run_details
  FOR user_scheduler_job_run_details
/
GRANT SELECT ON user_scheduler_job_run_details TO public with GRANT OPTION
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
COMMENT ON TABLE all_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN all_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN all_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN all_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN all_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN all_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN all_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN all_scheduler_job_log.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN all_scheduler_job_log.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN all_scheduler_job_log.destination IS
'The destination for a remote job operation'
/
COMMENT ON COLUMN all_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
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
COMMENT ON TABLE all_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN all_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN all_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN all_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN all_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.credential_owner IS
'Owner of the credential used for this remote job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.credential_name IS
'Name of the credential used for this remote job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.destination_owner IS
'Owner of destination object used in remote run or NULL if no object used'
/
COMMENT ON COLUMN all_scheduler_job_run_details.destination IS
'The destination for a remote job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/


CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_log
  FOR all_scheduler_job_log
/
GRANT SELECT ON all_scheduler_job_log TO public WITH GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_run_details
  FOR all_scheduler_job_run_details
/
GRANT SELECT ON all_scheduler_job_run_details TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_window_log
  ( LOG_ID, LOG_DATE, WINDOW_NAME, OPERATION, STATUS, USER_NAME, CLIENT_ID, 
    GLOBAL_UID, ADDITIONAL_INFO)
  AS 
  (SELECT
        LOG_ID, LOG_DATE, NAME, OPERATION, STATUS, USER_NAME, CLIENT_ID, 
        GUID, ADDITIONAL_INFO
  FROM scheduler$_event_log 
  WHERE type# = 69)
/
COMMENT ON TABLE dba_scheduler_window_log IS
'Logged information for all scheduler windows'
/
COMMENT ON COLUMN dba_scheduler_window_log.log_id IS
'The unique id of the log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW dba_scheduler_window_details
  ( LOG_ID, LOG_DATE, WINDOW_NAME, REQ_START_DATE, 
    ACTUAL_START_DATE, WINDOW_DURATION, ACTUAL_DURATION, INSTANCE_ID, 
    ADDITIONAL_INFO)
  AS
  (SELECT
        w.LOG_ID, w.LOG_DATE, e.NAME, w.REQ_START_DATE, w.START_DATE,
        w.DURATION, w.ACTUAL_DURATION, w.INSTANCE_ID, w.ADDITIONAL_INFO
  FROM scheduler$_window_details w, scheduler$_event_log e
  WHERE e.log_id = w.log_id
  AND e.type# = 69) 
/
COMMENT ON TABLE dba_scheduler_window_details IS
'The details of a window'
/
COMMENT ON COLUMN dba_scheduler_window_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_window_log'
/
COMMENT ON COLUMN dba_scheduler_window_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN dba_scheduler_window_details.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.req_start_date IS
'The requested start date for the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.actual_start_date IS
'The date the scheduler window actually started'
/
COMMENT ON COLUMN dba_scheduler_window_details.window_duration IS
'The original duration of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.actual_duration IS
'The actual duration for which the scheduler window lasted'
/
COMMENT ON COLUMN dba_scheduler_window_details.instance_id IS
'The id of the instance on which this window ran'
/
COMMENT ON COLUMN dba_scheduler_window_details.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_log
  FOR dba_scheduler_window_log
/
GRANT SELECT ON dba_scheduler_window_log TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_details
  FOR dba_scheduler_window_details
/
GRANT SELECT ON dba_scheduler_window_details TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_window_log AS
  SELECT * FROM dba_scheduler_window_log
/
COMMENT ON TABLE all_scheduler_window_log IS
'Logged information for all scheduler windows'
/
COMMENT ON COLUMN all_scheduler_window_log.log_id IS
'The unique id of the log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW all_scheduler_window_details AS
  SELECT * FROM dba_scheduler_window_details
/
COMMENT ON TABLE all_scheduler_window_details IS
'The details of a window'
/
COMMENT ON COLUMN all_scheduler_window_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_window_log'
/
COMMENT ON COLUMN all_scheduler_window_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN all_scheduler_window_details.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.req_start_date IS
'The requested start date for the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.actual_start_date IS
'The date the scheduler window actually started'
/
COMMENT ON COLUMN all_scheduler_window_details.window_duration IS
'The original duration of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.actual_duration IS
'The actual duration for which the scheduler window lasted'
/
COMMENT ON COLUMN all_scheduler_window_details.instance_id IS
'The id of the instance on which this window ran'
/
COMMENT ON COLUMN all_scheduler_window_details.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_log
  FOR all_scheduler_window_log
/
GRANT SELECT ON all_scheduler_window_log TO public WITH GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_details
  FOR all_scheduler_window_details
/
GRANT SELECT ON all_scheduler_window_details TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_window_groups
  ( WINDOW_GROUP_NAME, ENABLED, NUMBER_OF_WINDOWS, NEXT_START_DATE, COMMENTS )
  AS SELECT o.name, DECODE(BITAND(w.flags,1),0,'FALSE',1,'TRUE'),
    (SELECT COUNT(*) FROM scheduler$_wingrp_member wg WHERE wg.oid = w.obj#),
    DECODE(BITAND(w.flags,1),0,'NULL',1,
     (SELECT min(next_start_date) FROM scheduler$_window win WHERE win.obj# IN
      (SELECT wgm.member_oid FROM scheduler$_wingrp_member wgm 
        WHERE wgm.oid = w.obj#) AND bitand(win.flags, 1) = 1)),
    w.comments 
  FROM obj$ o, scheduler$_window_group w WHERE o.obj# = w.obj#
   AND bitand(w.flags, 8+16) = 0
/
COMMENT ON TABLE dba_scheduler_window_groups IS
'All scheduler window groups in the database'
/
COMMENT ON COLUMN dba_scheduler_window_groups.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.enabled IS
'Whether the window group is enabled'
/
COMMENT ON COLUMN dba_scheduler_window_groups.number_of_windows IS
'Number of members in this window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.next_start_date IS
'Next start date of this window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.comments IS
'An optional comment about this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_groups
  FOR dba_scheduler_window_groups
/
GRANT SELECT ON dba_scheduler_window_groups TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_window_groups as
  SELECT * FROM dba_scheduler_window_groups
/
COMMENT ON TABLE all_scheduler_window_groups IS
'All scheduler window groups in the database'
/
COMMENT ON COLUMN all_scheduler_window_groups.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.enabled IS
'Whether the window group is enabled'
/
COMMENT ON COLUMN all_scheduler_window_groups.number_of_windows IS
'Number of members in this window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.next_start_date IS
'Next start date of this window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.comments IS
'An optional comment about this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_groups
  FOR all_scheduler_window_groups
/
GRANT SELECT ON all_scheduler_window_groups TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_wingroup_members
  ( WINDOW_GROUP_NAME, WINDOW_NAME)
  AS SELECT o.name, wmo.name 
  FROM obj$ o, obj$ wmo, scheduler$_wingrp_member wg, 
    scheduler$_window_group w
  WHERE o.type# = 72 AND o.obj# = wg.oid AND wg.member_oid = wmo.obj#
    AND w.obj# = wg.oid AND bitand(w.flags, 8+16) = 0
/
COMMENT ON TABLE dba_scheduler_wingroup_members IS
'Members of all scheduler window groups in the database'
/
COMMENT ON COLUMN dba_scheduler_wingroup_members.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN dba_scheduler_wingroup_members.window_name IS
'Name of the window member of this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_wingroup_members
  FOR dba_scheduler_wingroup_members
/
GRANT SELECT ON dba_scheduler_wingroup_members TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_wingroup_members AS
  SELECT * FROM dba_scheduler_wingroup_members
/
COMMENT ON TABLE all_scheduler_wingroup_members IS
'Members of all scheduler window groups in the database'
/
COMMENT ON COLUMN all_scheduler_wingroup_members.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN all_scheduler_wingroup_members.window_name IS
'Name of the window member of this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_wingroup_members
  FOR all_scheduler_wingroup_members
/
GRANT SELECT ON all_scheduler_wingroup_members TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_group_members 
  ( OWNER, GROUP_NAME, MEMBER_NAME ) AS
SELECT wgm.owner, wgm.group_name,wgm.cred || wgm.mem_name
FROM 
(SELECT u.name owner, o.name group_name, wg.member_oid2 member_oid2,
        decode(member_oid2, null,null,'"' || cmu.name || '"."' || cmo.name || '"@') cred,
        decode(wmu.name || '"' || substr(wmo.name,1,12), 'SYS"SCHED$_LOCAL', 'LOCAL',
          '"'  || wmu.name || '"."' || wmo.name || '"' )mem_name
FROM user$ u, obj$ o, scheduler$_window_group w, scheduler$_wingrp_member wg,
     user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
WHERE w.obj# = wg.oid AND w.obj# = o.obj# AND o.owner# = u.user# AND
  wg.member_oid = wmo.obj# AND wmo.owner# = wmu.user# AND
  cmo.obj#(+) = wg.member_oid2 AND cmo.owner# = cmu.user#(+) )wgm
/

COMMENT ON TABLE dba_scheduler_group_members IS
'Members of all scheduler object groups in the database'
/
COMMENT ON COLUMN dba_scheduler_group_members.owner IS
'Owner of the group'
/
COMMENT ON COLUMN dba_scheduler_group_members.group_name IS
'Name of the group'
/
COMMENT ON COLUMN dba_scheduler_group_members.member_name IS
'Name of the member of this group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_group_members
   FOR dba_scheduler_group_members
/
GRANT SELECT ON dba_scheduler_group_members TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_group_members 
  ( GROUP_NAME, MEMBER_NAME ) AS
SELECT wgm.group_name,wgm.cred || wgm.mem_name
FROM 
(SELECT o.name group_name, wg.member_oid2 member_oid2,
        decode(member_oid2, null,null,'"' || cmu.name || '"."' || cmo.name || '"@') cred,
        decode(wmu.name || '"' || substr(wmo.name,1,12), 'SYS"SCHED$_LOCAL', 'LOCAL',
          '"'  || wmu.name || '"."' || wmo.name || '"' )mem_name
FROM obj$ o, scheduler$_window_group w, scheduler$_wingrp_member wg,
     user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
WHERE w.obj# = wg.oid AND w.obj# = o.obj# AND o.owner# = USERENV('SCHEMAID') AND
  wg.member_oid = wmo.obj# AND wmo.owner# = wmu.user# AND
  cmo.obj#(+) = wg.member_oid2 AND cmo.owner# = cmu.user#(+) ) wgm
/
COMMENT ON TABLE user_scheduler_group_members IS
'Members of all scheduler object groups owned by current user'
/
COMMENT ON COLUMN user_scheduler_group_members.group_name IS
'Name of the group'
/
COMMENT ON COLUMN user_scheduler_group_members.member_name IS
'Name of the member of this group'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_group_members
   FOR user_scheduler_group_members
/
GRANT SELECT ON user_scheduler_group_members TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_group_members 
  ( OWNER, GROUP_NAME, MEMBER_NAME ) AS
SELECT wgm.owner, wgm.group_name,wgm.cred || wgm.mem_name
FROM 
(SELECT u.name owner, o.name group_name, wg.member_oid2 member_oid2,
        decode(member_oid2, null,null,'"' || cmu.name || '"."' || cmo.name || '"@') cred,
        decode(wmu.name || '"' || substr(wmo.name,1,12), 'SYS"SCHED$_LOCAL', 'LOCAL',
          '"'  || wmu.name || '"."' || wmo.name || '"' )mem_name
FROM user$ u, obj$ o, scheduler$_window_group w, scheduler$_wingrp_member wg,
     user$ wmu, obj$ wmo, user$ cmu, obj$ cmo
WHERE w.obj# = wg.oid AND w.obj# = o.obj# AND o.owner# = u.user# AND
  wg.member_oid = wmo.obj# AND wmo.owner# = wmu.user# AND
  cmo.obj#(+) = wg.member_oid2 AND cmo.owner# = cmu.user#(+) AND
  (bitand(w.flags, 8+16) = 0 OR -- this is not a job or dest group
   (bitand(w.flags, 8+16) != 0 AND  -- this is a job or destination group
    (o.owner# = USERENV('SCHEMAID') OR -- user owns this group
     wg.oid IN (select oa1.obj# from sys.objauth$ oa1  -- has obj privs on group
                       where grantee# in (select kzsrorol from x$kzsro)) OR
     (EXISTS (select null from v$enabledprivs  -- has CREATE ANY JOB
                 where priv_number = -265) AND o.owner# <> 0))) ) ) wgm
/
COMMENT ON TABLE all_scheduler_group_members IS
'Members of all scheduler object groups visible to current user'
/
COMMENT ON COLUMN all_scheduler_group_members.owner IS
'Owner of the group'
/
COMMENT ON COLUMN all_scheduler_group_members.group_name IS
'Name of the group'
/
COMMENT ON COLUMN all_scheduler_group_members.member_name IS
'Name of the member of this group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_group_members
   FOR all_scheduler_group_members
/
GRANT SELECT ON all_scheduler_group_members TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_groups
 ( OWNER, GROUP_NAME, GROUP_TYPE, ENABLED, NUMBER_OF_MEMBERS, COMMENTS ) AS
SELECT u.name, o.name, 
  decode(bitand(w.flags, 8+16), 0, 'WINDOW', 8, 'JOB', 16,
decode(bitand(w.flags, 4096+8192), 4096,'DB_DEST', 8192, 'EXTERNAL_DEST', 'UNKOWN_DEST')),
  DECODE(BITAND(w.flags,1),0,'FALSE',1,'TRUE'),
  (SELECT COUNT(*) FROM scheduler$_wingrp_member wg WHERE wg.oid = w.obj#),
  w.comments
FROM obj$ o, user$ u, scheduler$_window_group w
WHERE o.owner# = u.user# AND o.obj# = w.obj#
/
COMMENT ON TABLE dba_scheduler_groups IS
'All scheduler object groups in the database'
/
COMMENT ON COLUMN dba_scheduler_groups.owner IS
'Owner of the group'
/
COMMENT ON COLUMN dba_scheduler_groups.group_name IS
'Name of the group'
/
COMMENT ON COLUMN dba_scheduler_groups.group_type IS
'Type of object contained in the group'
/
COMMENT ON COLUMN dba_scheduler_groups.enabled IS
'Whether the group is enabled'
/
COMMENT ON COLUMN dba_scheduler_groups.number_of_members IS
'Number of members in this group'
/
COMMENT ON COLUMN dba_scheduler_groups.comments IS
'An optional comment about this group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_groups 
   FOR dba_scheduler_groups
/
GRANT SELECT ON dba_scheduler_groups TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_groups
  ( GROUP_NAME, GROUP_TYPE, ENABLED, NUMBER_OF_MEMBERS, COMMENTS ) AS
SELECT o.name, 
  decode(bitand(w.flags, 8+16), 0, 'WINDOW', 8, 'JOB', 16, 
decode(bitand(w.flags, 4096+8192), 4096,'DB_DEST', 8192, 'EXTERNAL_DEST', 'UNKOWN_DEST')),
  DECODE(BITAND(w.flags,1),0,'FALSE',1,'TRUE'),
  (SELECT COUNT(*) FROM user_scheduler_group_members ugm WHERE
   ugm.group_name=o.name),
  w.comments
FROM obj$ o, scheduler$_window_group w
WHERE o.obj# = w.obj# AND o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_groups IS
'All scheduler object groups owned by current user'
/
COMMENT ON COLUMN user_scheduler_groups.group_name IS
'Name of the group'
/
COMMENT ON COLUMN user_scheduler_groups.group_type IS
'Type of object contained in the group'
/
COMMENT ON COLUMN user_scheduler_groups.enabled IS
'Whether the group is enabled'
/
COMMENT ON COLUMN user_scheduler_groups.number_of_members IS
'Number of members in this group'
/
COMMENT ON COLUMN user_scheduler_groups.comments IS
'An optional comment about this group'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_groups 
   FOR user_scheduler_groups
/
GRANT SELECT ON user_scheduler_groups TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_groups
 ( OWNER, GROUP_NAME, GROUP_TYPE, ENABLED, NUMBER_OF_MEMBERS, COMMENTS ) AS
SELECT u.name, o.name, 
  decode(bitand(w.flags, 8+16), 0, 'WINDOW', 8, 'JOB', 16, 
decode(bitand(w.flags, 4096+8192), 4096,'DB_DEST', 8192, 'EXTERNAL_DEST', 'UNKOWN_DEST')),
  DECODE(BITAND(w.flags,1),0,'FALSE',1,'TRUE'),
  (SELECT COUNT(*) FROM all_scheduler_group_members agm
   WHERE agm.group_name = o.name and agm.owner = u.name),
  w.comments
FROM obj$ o, user$ u, scheduler$_window_group w
WHERE o.owner# = u.user# AND o.obj# = w.obj# AND
  ( bitand(w.flags, 8+16)=0            -- window group
    or o.owner# = userenv('SCHEMAID')  -- user is owner
    or o.obj# in                       -- user has obj privs on group
         (select oa.obj#
          from sys.objauth$ oa
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
         )
    or /* user has create any job, except for SYS group */
      (exists (select null from v$enabledprivs
              where priv_number in (-265 /* CREATE ANY JOB */)
              )
       and o.owner#!=0)
  )
/
COMMENT ON TABLE all_scheduler_groups IS
'All scheduler object groups visible to current user'
/
COMMENT ON COLUMN all_scheduler_groups.owner IS
'Owner of the group'
/
COMMENT ON COLUMN all_scheduler_groups.group_name IS
'Name of the group'
/
COMMENT ON COLUMN all_scheduler_groups.group_type IS
'Type of object contained in the group'
/
COMMENT ON COLUMN all_scheduler_groups.enabled IS
'Whether the group is enabled'
/
COMMENT ON COLUMN all_scheduler_groups.number_of_members IS
'Number of members in this group'
/
COMMENT ON COLUMN all_scheduler_groups.comments IS
'An optional comment about this group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_groups 
   FOR all_scheduler_groups
/
GRANT SELECT ON all_scheduler_groups TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_schedules
  (OWNER,SCHEDULE_NAME,SCHEDULE_TYPE,START_DATE,REPEAT_INTERVAL,
   EVENT_QUEUE_OWNER,EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, 
   EVENT_CONDITION, FILE_WATCHER_OWNER, FILE_WATCHER_NAME, END_DATE, COMMENTS)
  AS SELECT su.name, so.name, 
    (CASE WHEN s.recurrence_expr is null THEN 'ONCE'
       ELSE DECODE(BITAND(s.flags,20),0,'CALENDAR',20, 'FILE_WATCHER', 
       4,'EVENT',NULL) END),
    s.reference_date, 
    decode(bitand(s.flags,4+8), 0, recurrence_expr,null), 
    s.queue_owner, s.queue_name, s.queue_agent, 
    DECODE(BITAND(s.flags, 4+8), 4, s.recurrence_expr,null),
    DECODE(BITAND(s.flags, 16), 0, NULL, 
      substr(s.fw_name,1,instr(s.fw_name,'"')-1)),
    DECODE(BITAND(s.flags, 16), 0, NULL, 
      substr(s.fw_name,instr(s.fw_name,'"') + 1,
        length(s.fw_name)-instr(s.fw_name,'"'))),
    s.end_date, s.comments
  FROM obj$ so, user$ su, sys.scheduler$_schedule s
  WHERE s.obj# = so.obj# AND so.owner# = su.user#
/
COMMENT ON TABLE dba_scheduler_schedules IS
'All schedules in the database'
/
COMMENT ON COLUMN dba_scheduler_schedules.owner IS
'Owner of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_schedules.file_watcher_owner IS
'Owner of file watcher on which this schedule is based'
/
COMMENT ON COLUMN dba_scheduler_schedules.file_watcher_name IS
'Name of file watcher on which this schedule is based'
/
COMMENT ON COLUMN dba_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN dba_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_schedules
  FOR dba_scheduler_schedules
/
GRANT SELECT ON dba_scheduler_schedules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_schedules
  (SCHEDULE_NAME,SCHEDULE_TYPE,START_DATE,REPEAT_INTERVAL,
   EVENT_QUEUE_OWNER, EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, 
   FILE_WATCHER_OWNER, FILE_WATCHER_NAME, END_DATE, COMMENTS)
  AS SELECT so.name, 
    (CASE WHEN s.recurrence_expr is null THEN 'ONCE'
       ELSE DECODE(BITAND(s.flags,20),0,'CALENDAR',20, 'FILE_WATCHER',
       4,'EVENT',NULL) END),
    s.reference_date, 
    decode(bitand(s.flags,4+8), 0, recurrence_expr,null), 
    s.queue_owner, s.queue_name, s.queue_agent, 
    DECODE(BITAND(s.flags, 4+8), 4, s.recurrence_expr,null),
    DECODE(BITAND(s.flags, 16), 0, NULL, 
      substr(s.fw_name,1,instr(s.fw_name,'"')-1)),
    DECODE(BITAND(s.flags, 16), 0, NULL, 
      substr(s.fw_name,instr(s.fw_name,'"') + 1,
        length(s.fw_name)-instr(s.fw_name,'"'))),
    s.end_date, s.comments
  FROM sys.scheduler$_schedule s, obj$ so
  WHERE s.obj# = so.obj#  AND so.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_schedules IS
'Schedules belonging to the current user'
/
COMMENT ON COLUMN user_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN user_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_schedules.file_watcher_owner IS
'Owner of file watcher on which this schedule is based'
/
COMMENT ON COLUMN user_scheduler_schedules.file_watcher_name IS
'Name of file watcher on which this schedule is based'
/
COMMENT ON COLUMN user_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN user_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_schedules
  FOR user_scheduler_schedules
/
GRANT SELECT ON user_scheduler_schedules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_schedules AS
  SELECT * FROM dba_scheduler_schedules
/
COMMENT ON TABLE all_scheduler_schedules IS
'All schedules in the database'
/
COMMENT ON COLUMN all_scheduler_schedules.owner IS
'Owner of the schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
/
COMMENT ON COLUMN all_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN all_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_schedules.file_watcher_owner IS
'Owner of file watcher on which this schedule is based'
/
COMMENT ON COLUMN all_scheduler_schedules.file_watcher_name IS
'Name of file watcher on which this schedule is based'
/
COMMENT ON COLUMN all_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN all_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_schedules
  FOR all_scheduler_schedules
/
GRANT SELECT ON all_scheduler_schedules TO public WITH GRANT OPTION
/

/* scheduler running jobs views */
CREATE OR REPLACE VIEW dba_scheduler_running_jobs
   ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_STYLE, DETACHED, SESSION_ID, 
     SLAVE_PROCESS_ID, SLAVE_OS_PROCESS_ID, 
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED,
     DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER, CREDENTIAL_NAME, LOG_ID)
  AS 
  SELECT ju.name, jo.name, jo.subname, 'REGULAR', 
       (CASE WHEN p.obj# IS NULL OR BITAND(p.flags,256) = 0 
                                 OR rj.job_id IS NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
      rj.session_id, vp.pid, 
      rj.os_process_id, rj.inst_id, vse.resource_consumer_group, 
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu,
      decode(bitand(j.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(j.destination, 1, instr(j.destination, '"')-1)),
      decode(bitand(j.flags, 2473901162496), 0, j.destination,
        2473901162496, 'LOCAL',
        substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
      j.credential_owner, j.credential_name,
      bitand(j.running_slave,18446744069414584320)/4294967295
  FROM
      scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
      JOIN user$ ju ON (jo.owner# = ju.user#)
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#
         AND vse.inst_id = rj.inst_id)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
      LEFT OUTER JOIN scheduler$_program p ON (j.program_oid = p.obj#) 
  WHERE BITAND(j.job_status,2) = 2 OR
        (BITAND(j.flags, 274877906944) <> 0 AND j.job_dest_id <> 0)
  UNION ALL
  SELECT lju.name, ljo.name, NULL, 'LIGHTWEIGHT', 
       (CASE WHEN BITAND(lp.flags,256) = 0 
                    OR lrj.job_id is NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
      lrj.session_id, lvp.pid, 
      lrj.os_process_id, lrj.inst_id, lvse.resource_consumer_group, 
      CAST (systimestamp-lj.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      lrj.session_stat_cpu,
      decode(bitand(lj.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(lj.destination, 1, instr(lj.destination, '"')-1)),
      decode(bitand(lj.flags, 2473901162496), 0, lj.destination,
        2473901162496, 'LOCAL',
        substr(lj.destination, instr(lj.destination, '"')+1,
           length(lj.destination) - instr(lj.destination, '"'))),
      lj.credential_owner, lj.credential_name,
      bitand(lj.running_slave,18446744069414584320)/4294967295
  FROM
      scheduler$_lightweight_job lj JOIN scheduler$_lwjob_obj ljo 
        ON (lj.obj# = ljo.obj#)
      JOIN user$ lju ON (ljo.userid = lju.user#)
      LEFT OUTER JOIN scheduler$_program lp ON (lj.program_oid = lp.obj#)
      LEFT OUTER JOIN gv$scheduler_running_jobs lrj ON (lrj.job_id = lj.obj#)
      LEFT OUTER JOIN gv$session lvse ON
        (lrj.session_id = lvse.sid AND lrj.session_serial_num = lvse.serial#
         AND lvse.inst_id = lrj.inst_id)
      LEFT OUTER JOIN gv$process lvp ON 
        (lrj.paddr = lvp.addr AND lrj.inst_id = lvp.inst_id)
  WHERE BITAND(lj.job_status,2) = 2 
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_running_jobs
  FOR dba_scheduler_running_jobs
/
GRANT SELECT ON dba_scheduler_running_jobs TO select_catalog_role
/
COMMENT ON COLUMN dba_scheduler_running_jobs.owner IS
'Owner of the running scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.destination IS
'Destination that this job is running on'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.credential_owner IS
'Owner of login credential used for this running job, if any'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.credential_name IS
'Name of login credential used for this running job, if any'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.log_id IS
'Log id that will be used for this job run'
/

CREATE OR REPLACE VIEW all_scheduler_running_jobs
   ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_STYLE, DETACHED, SESSION_ID, 
     SLAVE_PROCESS_ID, SLAVE_OS_PROCESS_ID,
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED,
     DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER, CREDENTIAL_NAME, LOG_ID)
  AS SELECT ju.name, jo.name, jo.subname, 'REGULAR', 
       (CASE WHEN p.obj# IS NULL OR BITAND(p.flags,256) = 0 
                       OR rj.job_id  IS NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
      rj.session_id, vp.pid, 
      rj.os_process_id, rj.inst_id, vse.resource_consumer_group,
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu,
      decode(bitand(j.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(j.destination, 1, instr(j.destination, '"')-1)),
      decode(bitand(j.flags, 2473901162496), 0, j.destination,
        2473901162496, 'LOCAL',
        substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
      j.credential_owner, j.credential_name,
      bitand(j.running_slave,18446744069414584320)/4294967295
  FROM
      scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
      JOIN user$ ju ON (jo.owner# = ju.user# AND
        (jo.owner# = userenv('SCHEMAID')
         or jo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                 where priv_number  = -265 /* CREATE ANY JOB */
                )
            and jo.owner#!=0)
        )
      )
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#
         AND vse.inst_id = rj.inst_id)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
      LEFT OUTER JOIN scheduler$_program p ON (j.program_oid = p.obj#) 
  WHERE BITAND(j.job_status,2) = 2 OR
        (BITAND(j.flags, 274877906944) <> 0 AND j.job_dest_id <> 0)
UNION ALL
  SELECT lju.name, ljo.name, NULL, 'LIGHTWEIGHT', 
       (CASE WHEN BITAND(lp.flags,256) = 0 
                OR lrj.job_id is NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
       lrj.session_id, lvp.pid, 
      lrj.os_process_id, lrj.inst_id, lvse.resource_consumer_group,
      CAST (systimestamp-lj.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      lrj.session_stat_cpu,
      decode(bitand(lj.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(lj.destination, 1, instr(lj.destination, '"')-1)),
      decode(bitand(lj.flags, 2473901162496), 0, lj.destination,
        2473901162496, 'LOCAL',
        substr(lj.destination, instr(lj.destination, '"')+1,
           length(lj.destination) - instr(lj.destination, '"'))),
      lj.credential_owner, lj.credential_name,
      bitand(lj.running_slave,18446744069414584320)/4294967295
  FROM scheduler$_lightweight_job lj
      JOIN scheduler$_lwjob_obj ljo ON (lj.obj# = ljo.obj#)
      JOIN user$ lju ON (ljo.userid = lju.user# AND
        (ljo.userid = userenv('SCHEMAID')
         or (lj.program_oid is not null and
              lj.program_oid in
              (select loa.obj#
               from sys.objauth$ loa
               where grantee# in ( select kzsrorol
                                   from x$kzsro
                                 )
              )
            )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                 where priv_number  = -265 /* CREATE ANY JOB */
                )
            and ljo.userid !=0)
        )
      )
      LEFT OUTER JOIN scheduler$_program lp ON (lj.program_oid = lp.obj#)
      LEFT OUTER JOIN gv$scheduler_running_jobs lrj ON (lrj.job_id = lj.obj#)
      LEFT OUTER JOIN gv$session lvse ON
        (lrj.session_id = lvse.sid AND lrj.session_serial_num = lvse.serial#
         AND lvse.inst_id = lrj.inst_id)
      LEFT OUTER JOIN gv$process lvp ON 
        (lrj.paddr = lvp.addr AND lrj.inst_id = lvp.inst_id)
  WHERE BITAND(lj.job_status,2) = 2 
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_running_jobs
  FOR all_scheduler_running_jobs
/
GRANT SELECT ON all_scheduler_running_jobs TO public
/
COMMENT ON COLUMN all_scheduler_running_jobs.owner IS
'Owner of the running scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN all_scheduler_running_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN all_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN all_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN all_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/
COMMENT ON COLUMN all_scheduler_running_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN all_scheduler_running_jobs.destination IS
'Destination that this job is running on'
/
COMMENT ON COLUMN all_scheduler_running_jobs.credential_owner IS
'Owner of login credential used for this running job, if any'
/
COMMENT ON COLUMN all_scheduler_running_jobs.credential_name IS
'Name of login credential used for this running job, if any'
/
COMMENT ON COLUMN all_scheduler_running_jobs.log_id IS
'Log id that will be used for this job run'
/

/* scheduler running jobs views */
CREATE OR REPLACE VIEW user_scheduler_running_jobs
   ( JOB_NAME, JOB_SUBNAME, JOB_STYLE, DETACHED, SESSION_ID, 
     SLAVE_PROCESS_ID, SLAVE_OS_PROCESS_ID,
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED,
     DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER, CREDENTIAL_NAME, LOG_ID)
  AS SELECT jo.name, jo.subname, 'REGULAR', 
       (CASE WHEN p.obj# IS NULL OR BITAND(p.flags,256) = 0 
                    OR rj.job_id IS NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
      rj.session_id, vp.pid, 
      rj.os_process_id, 
      rj.inst_id, vse.resource_consumer_group, 
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu,
      decode(bitand(j.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(j.destination, 1, instr(j.destination, '"')-1)),
      decode(bitand(j.flags, 2473901162496), 0, j.destination,
        2473901162496, 'LOCAL',
        substr(j.destination, instr(j.destination, '"')+1,
           length(j.destination) - instr(j.destination, '"'))),
      j.credential_owner, j.credential_name,
      bitand(j.running_slave,18446744069414584320)/4294967295
  FROM
      scheduler$_job j JOIN obj$ jo ON
        (j.obj# = jo.obj# AND jo.owner# = USERENV('SCHEMAID'))
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#
         AND vse.inst_id = rj.inst_id)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
      LEFT OUTER JOIN scheduler$_program p ON (j.program_oid = p.obj#) 
  WHERE BITAND(j.job_status,2) = 2 OR
        (BITAND(j.flags, 274877906944) <> 0 AND j.job_dest_id <> 0)
UNION ALL
  SELECT ljo.name, NULL, 'LIGHTWEIGHT', 
       (CASE WHEN BITAND(lp.flags,256) = 0 
            OR lrj.job_id is NOT NULL THEN 'FALSE'
             ELSE 'TRUE'
       END),
      lrj.session_id, lvp.pid, 
      lrj.os_process_id, 
      lrj.inst_id, lvse.resource_consumer_group, 
      CAST (systimestamp-lj.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      lrj.session_stat_cpu,
      decode(bitand(lj.flags, 2473901162496), 0, NULL, 2473901162496, NULL,
       substr(lj.destination, 1, instr(lj.destination, '"')-1)),
      decode(bitand(lj.flags, 2473901162496), 0, lj.destination,
        2473901162496, 'LOCAL',
        substr(lj.destination, instr(lj.destination, '"')+1,
           length(lj.destination) - instr(lj.destination, '"'))),
      lj.credential_owner, lj.credential_name,
      bitand(lj.running_slave,18446744069414584320)/4294967295
  FROM
      scheduler$_lightweight_job lj JOIN scheduler$_lwjob_obj ljo ON
        (lj.obj# = ljo.obj# AND ljo.userid = USERENV('SCHEMAID'))
      LEFT OUTER JOIN scheduler$_program lp ON (lj.program_oid = lp.obj#)
      LEFT OUTER JOIN gv$scheduler_running_jobs lrj ON (lrj.job_id = lj.obj#)
      LEFT OUTER JOIN gv$session lvse ON
        (lrj.session_id = lvse.sid AND lrj.session_serial_num = lvse.serial#
         AND lvse.inst_id = lrj.inst_id)
      LEFT OUTER JOIN gv$process lvp ON 
        (lrj.paddr = lvp.addr AND lrj.inst_id = lvp.inst_id)
  WHERE BITAND(lj.job_status,2) = 2 
/

CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_running_jobs
  FOR user_scheduler_running_jobs
/
GRANT SELECT ON user_scheduler_running_jobs TO public
/
COMMENT ON COLUMN user_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN user_scheduler_running_jobs.job_style IS
'Job style - regular, lightweight or volatile'
/
COMMENT ON COLUMN user_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN user_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN user_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/
COMMENT ON COLUMN user_scheduler_running_jobs.destination_owner IS
'Owner of destination object (if used) else NULL'
/
COMMENT ON COLUMN user_scheduler_running_jobs.destination IS
'Destination that this job is running on'
/
COMMENT ON COLUMN user_scheduler_running_jobs.credential_owner IS
'Owner of login credential used for this running job, if any'
/
COMMENT ON COLUMN user_scheduler_running_jobs.credential_name IS
'Name of login credential used for this running job, if any'
/
COMMENT ON COLUMN user_scheduler_running_jobs.log_id IS
'Log id that will be used for this job run'
/

CREATE OR REPLACE VIEW dba_scheduler_remote_databases
 (DATABASE_NAME, REGISTERED_AS, DATABASE_LINK) AS
 SELECT database_name, decode(reg_status, 0, 'SOURCE', 'DESTINATION'),
        database_link
 FROM scheduler$_remote_dbs
/
COMMENT ON TABLE dba_scheduler_remote_databases IS
'List of registered remote databases for jobs'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.database_name IS
'Name of remote database'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.registered_as IS
'Whether database registered as source or destination'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.database_link IS
'Database link to the remote database'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_remote_databases
  FOR dba_scheduler_remote_databases
/
GRANT SELECT ON dba_scheduler_remote_databases TO public
/

CREATE OR REPLACE VIEW all_scheduler_remote_databases
 (DATABASE_NAME, REGISTERED_AS, DATABASE_LINK) AS
 SELECT database_name, decode(reg_status, 0, 'SOURCE', 'DESTINATION'),
        database_link
 FROM scheduler$_remote_dbs
/
COMMENT ON TABLE dba_scheduler_remote_databases IS
'List of registered remote databases for jobs'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.database_name IS
'Name of remote database'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.registered_as IS
'Whether database registered as source or destination'
/
COMMENT ON COLUMN dba_scheduler_remote_databases.database_link IS
'Database link to the remote database'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_remote_databases
  FOR all_scheduler_remote_databases
/
GRANT SELECT ON all_scheduler_remote_databases TO public
/

CREATE OR REPLACE VIEW dba_scheduler_remote_jobstate
 (OWNER, JOB_NAME, DESTINATION, STATE, NEXT_START_DATE, RUN_COUNT, FAILURE_COUNT,
  RETRY_COUNT, LAST_START_DATE, LAST_END_DATE) AS
 SELECT u.name, o.name, j.destination, 
        DECODE(BITAND(j.job_status,1+2+4+8+16+32+8192),0,'DISABLED',1,
        (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
        2, 'RUNNING',
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,8192, 'STOPPED', NULL),
        j.next_start_date, j.run_count,
        j.failure_count, j.retry_count, j.last_start_date, j.last_end_date
 FROM user$ u, obj$ o, scheduler$_remote_job_state j
 WHERE j.joboid = o.obj# and o.owner# = u.user#
/

COMMENT ON TABLE dba_scheduler_remote_jobstate IS
'Remote state of all jobs originating from this database'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.destination IS
'Name of job destination'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.state IS
'State of job at remote system'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.next_start_date IS
'Next start date of job on remote system'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.run_count IS
'Run count of job on remote system'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.failure_count IS
'Failure count of job on remote system'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.last_start_date IS
'Last start time of job on remote system'
/
COMMENT ON COLUMN dba_scheduler_remote_jobstate.last_end_date IS
'Last end date of job on remote system'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_remote_jobstate
  FOR dba_scheduler_remote_jobstate
/
GRANT SELECT ON dba_scheduler_remote_jobstate TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_remote_jobstate
 (OWNER, JOB_NAME, DESTINATION, STATE, NEXT_START_DATE, RUN_COUNT, FAILURE_COUNT,
  RETRY_COUNT, LAST_START_DATE, LAST_END_DATE) AS
 SELECT u.name, o.name, j.destination, 
        DECODE(BITAND(j.job_status,1+2+4+8+16+32+8192),0,'DISABLED',1,
        (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
        2, 'RUNNING',
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,8192, 'STOPPED', NULL),
	j.next_start_date, j.run_count,
        j.failure_count, j.retry_count, j.last_start_date, j.last_end_date
 FROM user$ u, obj$ o, scheduler$_remote_job_state j
 WHERE j.joboid = o.obj# and o.owner# = u.user# and
    (o.owner# = USERENV('SCHEMAID') or
     o.obj# in
        (select oa.obj#
             from sys.objauth$ oa
              where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number = -265 /* CREATE ANY JOB */
                 )
          and o.owner#!=0)
       )
/

COMMENT ON TABLE all_scheduler_remote_jobstate IS
'Remote state of all jobs originating from this database visible to current user'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.destination IS
'Name of job destination'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.state IS
'State of job at remote system'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.next_start_date IS
'Next start date of job on remote system'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.run_count IS
'Run count of job on remote system'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.failure_count IS
'Failure count of job on remote system'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.last_start_date IS
'Last start time of job on remote system'
/
COMMENT ON COLUMN all_scheduler_remote_jobstate.last_end_date IS
'Last end date of job on remote system'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_remote_jobstate
  FOR all_scheduler_remote_jobstate
/
GRANT SELECT ON all_scheduler_remote_jobstate TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW user_scheduler_remote_jobstate
 (JOB_NAME, DESTINATION, STATE, NEXT_START_DATE, RUN_COUNT, FAILURE_COUNT,
  RETRY_COUNT, LAST_START_DATE, LAST_END_DATE) AS
 SELECT o.name, j.destination, 
        DECODE(BITAND(j.job_status,1+2+4+8+16+32+8192),0,'DISABLED',1,
        (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
        2, 'RUNNING',
        4,'COMPLETED',8,'BROKEN',16,'FAILED',
        32,'SUCCEEDED' ,8192, 'STOPPED', NULL),
	j.next_start_date, j.run_count,
        j.failure_count, j.retry_count, j.last_start_date, j.last_end_date
 FROM obj$ o, scheduler$_remote_job_state j
 WHERE j.joboid = o.obj# and o.owner# = USERENV('SCHEMAID')
/

COMMENT ON TABLE user_scheduler_remote_jobstate IS
'Remote state of all jobs originating from this database owned by current user'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.destination IS
'Name of job destination'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.state IS
'State of job at remote system'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.next_start_date IS
'Next start date of job on remote system'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.run_count IS
'Run count of job on remote system'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.failure_count IS
'Failure count of job on remote system'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.last_start_date IS
'Last start time of job on remote system'
/
COMMENT ON COLUMN user_scheduler_remote_jobstate.last_end_date IS
'Last end date of job on remote system'
/

CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_remote_jobstate
  FOR user_scheduler_remote_jobstate
/
GRANT SELECT ON user_scheduler_remote_jobstate TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_global_attribute
 (ATTRIBUTE_NAME, VALUE) AS
 SELECT o.name, a.value
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND BITAND(a.flags,1) != 1
/

COMMENT ON TABLE dba_scheduler_global_attribute IS
'All scheduler global attributes'
/

COMMENT ON COLUMN dba_scheduler_global_attribute.attribute_name IS
'Name of the scheduler global attribute'
/

COMMENT ON COLUMN dba_scheduler_global_attribute.value IS
'Value of the scheduler global attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_global_attribute
  FOR dba_scheduler_global_attribute
/
GRANT SELECT ON dba_scheduler_global_attribute TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_global_attribute
 (ATTRIBUTE_NAME, VALUE) AS
 SELECT o.name, a.value
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND BITAND(a.flags,1) != 1
/

COMMENT ON TABLE all_scheduler_global_attribute IS
'All scheduler global attributes'
/

COMMENT ON COLUMN all_scheduler_global_attribute.attribute_name IS
'Name of the scheduler global attribute'
/

COMMENT ON COLUMN all_scheduler_global_attribute.value IS
'Value of the scheduler global attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_global_attribute
  FOR all_scheduler_global_attribute
/
GRANT SELECT ON all_scheduler_global_attribute TO public WITH GRANT OPTION
/

-- chain views
CREATE OR REPLACE VIEW dba_scheduler_chains
  (OWNER, CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT u.name, o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, user$ u, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_chains IS
'All scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN dba_scheduler_chains.owner IS
'Owner of the scheduler chain'
/
COMMENT ON COLUMN dba_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN dba_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chains
  FOR dba_scheduler_chains
/
GRANT SELECT ON dba_scheduler_chains TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chains
  (CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_chains IS
'All scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN user_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN user_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN user_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN user_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN user_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN user_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN user_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN user_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chains
  FOR user_scheduler_chains
/
GRANT SELECT ON user_scheduler_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chains
  (OWNER, CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT u.name, o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, user$ u, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chains IS
'All scheduler chains in the database visible to current user'
/
COMMENT ON COLUMN all_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN all_scheduler_chains.owner IS
'Owner of the scheduler chain'
/
COMMENT ON COLUMN all_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN all_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN all_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN all_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN all_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN all_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN all_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN all_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chains
  FOR all_scheduler_chains
/
GRANT SELECT ON all_scheduler_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_chain_rules
  (OWNER, CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT cu.name, co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, user$ cu, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = cu.user#
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user#
/
COMMENT ON TABLE dba_scheduler_chain_rules IS
'All rules from scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.owner IS
'Owner of the scheduler chain the rule is in'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chain_rules
  FOR dba_scheduler_chain_rules
/
GRANT SELECT ON dba_scheduler_chain_rules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chain_rules
  (CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = USERENV('SCHEMAID')
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user#
/
COMMENT ON TABLE user_scheduler_chain_rules IS
'All rules from scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN user_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN user_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN user_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN user_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chain_rules
  FOR user_scheduler_chain_rules
/
GRANT SELECT ON user_scheduler_chain_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chain_rules
  (OWNER, CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT cu.name, co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, user$ cu, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = cu.user#
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user# AND
    (co.owner# = userenv('SCHEMAID')
       or co.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and co.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chain_rules IS
'All rules from scheduler chains visible to the current user'
/
COMMENT ON COLUMN all_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN all_scheduler_chain_rules.owner IS
'Owner of the scheduler chain the rule is in'
/
COMMENT ON COLUMN all_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN all_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN all_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN all_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chain_rules
  FOR all_scheduler_chain_rules
/
GRANT SELECT ON all_scheduler_chain_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_chain_steps
  (OWNER, CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION,
   CREDENTIAL_OWNER, CREDENTIAL_NAME, DESTINATION, SKIP, PAUSE, PAUSE_BEFORE,
   RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_TYPE, TIMEOUT)
  AS SELECT u.name, o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  cs.credential_owner, cs.credential_name, cs.destination,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,512),0,'FALSE',512,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,128),0,'FALSE',128,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, user$ u, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_chain_steps IS
'All steps of scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.owner IS
'Owner of the scheduler chain the step is in'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.credential_owner IS
'Owner of the credential to be used for an external step job'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.credential_name IS
'Name of the credential to be used for an external step job'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.destination IS
'Destination host on which a remote step job will run'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.pause_before IS
'Whether this step should be paused before running or not'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chain_steps
  FOR dba_scheduler_chain_steps
/
GRANT SELECT ON dba_scheduler_chain_steps TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chain_steps
  (CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION,
   CREDENTIAL_OWNER, CREDENTIAL_NAME, DESTINATION, SKIP, PAUSE, PAUSE_BEFORE,
   RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_TYPE, TIMEOUT)
  AS SELECT o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  cs.credential_owner, cs.credential_name, cs.destination,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,512),0,'FALSE',512,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,128),0,'FALSE',128,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_chain_steps IS
'All steps of scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN user_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_chain_steps.credential_owner IS
'Owner of the credential to be used for an external step job'
/
COMMENT ON COLUMN user_scheduler_chain_steps.credential_name IS
'Name of the credential to be used for an external step job'
/
COMMENT ON COLUMN user_scheduler_chain_steps.destination IS
'Destination host on which a remote step job will run'
/
COMMENT ON COLUMN user_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN user_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN user_scheduler_chain_steps.pause_before IS
'Whether this step should be paused before running or not'
/
COMMENT ON COLUMN user_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN user_scheduler_chain_steps.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN user_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chain_steps
  FOR user_scheduler_chain_steps
/
GRANT SELECT ON user_scheduler_chain_steps TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chain_steps
  (OWNER, CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION,
   CREDENTIAL_OWNER, CREDENTIAL_NAME, DESTINATION, SKIP, PAUSE, PAUSE_BEFORE,
   RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_TYPE, TIMEOUT)
  AS SELECT u.name, o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  cs.credential_owner, cs.credential_name, cs.destination,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,512),0,'FALSE',512,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,128),0,'FALSE',128,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, user$ u, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chain_steps IS
'All steps of scheduler chains visible to the current user'
/
COMMENT ON COLUMN all_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN all_scheduler_chain_steps.owner IS
'Owner of the scheduler chain the step is in'
/
COMMENT ON COLUMN all_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_chain_steps.credential_owner IS
'Owner of the credential to be used for an external step job'
/
COMMENT ON COLUMN all_scheduler_chain_steps.credential_name IS
'Name of the credential to be used for an external step job'
/
COMMENT ON COLUMN all_scheduler_chain_steps.destination IS
'Destination host on which a remote step job will run'
/
COMMENT ON COLUMN all_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN all_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN all_scheduler_chain_steps.pause_before IS
'Whether this step should be paused before running or not'
/
COMMENT ON COLUMN all_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN all_scheduler_chain_steps.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN all_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chain_steps
  FOR all_scheduler_chain_steps
/
GRANT SELECT ON all_scheduler_chain_steps TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_running_chains
  ( OWNER, JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE, PAUSE_BEFORE,
    RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_JOB_SUBNAME,
    STEP_JOB_LOG_ID) AS
  SELECT ju.name, jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'E', 'RETRY SCHEDULED', 'T', 'STALLED', 'P','PAUSED',
        'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'E',
        'RETRY SCHEDULED', 'T', 'STALLED', 'P', 'PAUSED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,512),0,'FALSE',512,'TRUE',
      DECODE(BITAND(cv.flags,512),0,'FALSE',512,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    DECODE(BITAND(jss.flags,128),0,'FALSE',128,'TRUE',
      DECODE(BITAND(cv.flags,128),0,'FALSE',128,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
     JOIN user$ ju ON (jo.owner# = ju.user#)
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE dba_scheduler_running_chains IS
'All steps of all running chains in the database'
/
COMMENT ON COLUMN dba_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN dba_scheduler_running_chains.owner IS
'Owner of the job which is running the chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN dba_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN dba_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN dba_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN dba_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN dba_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN dba_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN dba_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN dba_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN dba_scheduler_running_chains.pause_before IS
'Whether this step will be paused before running or not'
/
COMMENT ON COLUMN dba_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN dba_scheduler_running_chains.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_running_chains
  FOR dba_scheduler_running_chains
/
GRANT SELECT ON dba_scheduler_running_chains TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_running_chains
  ( JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE, PAUSE_BEFORE,
    RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_JOB_SUBNAME,
    STEP_JOB_LOG_ID) AS
  SELECT jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'E', 'RETRY SCHEDULED', 'T', 'STALLED', 'P','PAUSED',
        'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'E',
        'RETRY SCHEDULED', 'T', 'STALLED', 'P', 'PAUSED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,512),0,'FALSE',512,'TRUE',
      DECODE(BITAND(cv.flags,512),0,'FALSE',512,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    DECODE(BITAND(jss.flags,128),0,'FALSE',128,'TRUE',
      DECODE(BITAND(cv.flags,128),0,'FALSE',128,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j
     JOIN obj$ jo ON (j.obj# = jo.obj# AND jo.owner# = USERENV('SCHEMAID'))
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE user_scheduler_running_chains IS
'All steps of chains being run by jobs owned by the current user'
/
COMMENT ON COLUMN user_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN user_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN user_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN user_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN user_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN user_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN user_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN user_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN user_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN user_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN user_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN user_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN user_scheduler_running_chains.pause_before IS
'Whether this step will be paused before running or not'
/
COMMENT ON COLUMN user_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN user_scheduler_running_chains.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_running_chains
  FOR user_scheduler_running_chains
/
GRANT SELECT ON user_scheduler_running_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_running_chains
  ( OWNER, JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE, PAUSE_BEFORE,
    RESTART_ON_RECOVERY, RESTART_ON_FAILURE, STEP_JOB_SUBNAME,
    STEP_JOB_LOG_ID) AS
  SELECT ju.name, jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'E', 'RETRY SCHEDULED', 'T', 'STALLED', 'P','PAUSED',
        'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'E',
        'RETRY SCHEDULED', 'T', 'STALLED', 'P', 'PAUSED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,512),0,'FALSE',512,'TRUE',
      DECODE(BITAND(cv.flags,512),0,'FALSE',512,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    DECODE(BITAND(jss.flags,128),0,'FALSE',128,'TRUE',
      DECODE(BITAND(cv.flags,128),0,'FALSE',128,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
     JOIN user$ ju ON 
     (jo.owner# = ju.user# AND
       (jo.owner# = userenv('SCHEMAID')
         or jo.obj# in
              (select oa.obj#
               from sys.objauth$ oa
               where grantee# in ( select kzsrorol
                                   from x$kzsro
                                 )
              )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                   where priv_number in (-265 /* CREATE ANY JOB */)
                   )
            and jo.owner#!=0
           )
       )
     )
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE all_scheduler_running_chains IS
'All job steps of running job chains visible to the user'
/
COMMENT ON COLUMN all_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN all_scheduler_running_chains.owner IS
'Owner of the job which is running the chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN all_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN all_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN all_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN all_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN all_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN all_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN all_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN all_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN all_scheduler_running_chains.pause_before IS
'Whether this step will be paused before running or not'
/
COMMENT ON COLUMN all_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN all_scheduler_running_chains.restart_on_failure IS
'Whether this step should be retried on application failure'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_running_chains
  FOR all_scheduler_running_chains
/
GRANT SELECT ON all_scheduler_running_chains TO public WITH GRANT OPTION
/

/* Register procedural objects for export */
DELETE FROM sys.exppkgobj$ WHERE package LIKE 'DBMS_SCHED_%'
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_PROGRAM_EXPORT','SYS',2,67,1, 1515)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_WINDOW_EXPORT','SYS',1,69,1, 1510)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_WINGRP_EXPORT','SYS',1,72,1, 1520)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_CLASS_EXPORT','SYS',1,68,1, 1520)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_JOB_EXPORT','SYS',2,66,1, 1530)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_SCHEDULE_EXPORT','SYS',2,74,1, 1510)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_CHAIN_EXPORT','SYS',2,79,1, 1525)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_CREDENTIAL_EXPORT','SYS',2,90,1, 1505)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_FILE_WATCHER_EXPORT', 'SYS', 2, 98, 1, 1520)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_ATTRIBUTE_EXPORT','SYS',1,77,1, 1500)
/
DELETE FROM sys.exppkgact$ WHERE package LIKE 'DBMS_SCHED_%'
/
INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SCHED_EXPORT_CALLOUTS','SYS',6,1000)
/
INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SCHED_EXPORT_CALLOUTS','SYS',2,1000)
/

-- these views are exported as tables so we can import arguments
-- without using export callouts on 12c and up
CREATE OR REPLACE VIEW system.scheduler_program_args
  AS SELECT * FROM sys.all_scheduler_program_args
/
GRANT SELECT ON system.scheduler_program_args TO select_catalog_role
/
CREATE OR REPLACE VIEW system.scheduler_job_args
  AS SELECT * FROM sys.all_scheduler_job_args
/
GRANT SELECT ON system.scheduler_job_args TO select_catalog_role
/

-- these tables are necessary for expdp to export the above views
-- these tables should never have any rows, so it is ok to drop them
DROP TABLE system.scheduler_program_args_tbl
/
CREATE TABLE system.scheduler_program_args_tbl AS
  SELECT * FROM system.scheduler_program_args WHERE 0=1
/
GRANT SELECT ON system.scheduler_program_args_tbl TO select_catalog_role
/
DROP TABLE system.scheduler_job_args_tbl
/
CREATE TABLE system.scheduler_job_args_tbl AS
  SELECT * FROM system.scheduler_job_args WHERE 0=1
/
GRANT SELECT ON system.scheduler_job_args_tbl TO select_catalog_role
/

-- tables/views for argument export in the SYSTEM schema should not be exported
DELETE FROM sys.noexp$ WHERE OWNER='SYSTEM' AND NAME IN
  ('SCHEDULER_JOB_ARGS_TBL', 'SCHEDULER_PROGRAM_ARGS_TBL',
   'SCHEDULER_JOB_ARGS', 'SCHEDULER_PROGRAM_ARGS')
/
INSERT INTO sys.noexp$ VALUES ('SYSTEM','SCHEDULER_JOB_ARGS_TBL',2)
/
INSERT INTO sys.noexp$ VALUES ('SYSTEM','SCHEDULER_PROGRAM_ARGS_TBL',2)
/

DELETE FROM sys.impcalloutreg$ WHERE tag='SCHEDULER'
/
INSERT INTO sys.impcalloutreg$
     ( package, schema, tag, class, level#, flags,
       tgt_schema, tgt_object, tgt_type, cmnt) values
     ( 'DBMS_SCHED_ARGUMENT_IMPORT','SYS', 'SCHEDULER',  3, 1001, 0,
       'SYSTEM', 'SCHEDULER_PROGRAM_ARGS', 4 /*view*/, 'Oracle Scheduler')
/
INSERT INTO sys.impcalloutreg$
     ( package, schema, tag, class, level#, flags,
       tgt_schema, tgt_object, tgt_type, cmnt) values
     ( 'DBMS_SCHED_ARGUMENT_IMPORT','SYS', 'SCHEDULER',  3, 1100, 0,
       'SYSTEM', 'SCHEDULER_JOB_ARGS', 4 /*view*/, 'Oracle Scheduler')
/
INSERT INTO sys.impcalloutreg$
     ( package, schema, tag, class, level#, flags,
       tgt_schema, tgt_object, tgt_type, cmnt) values
     ( 'DBMS_SCHED_ARGUMENT_IMPORT','SYS', 'SCHEDULER',  1, 500, 0,
       NULL, NULL, NULL, 'Oracle Scheduler')
/

CREATE OR REPLACE VIEW dba_scheduler_credentials
  (OWNER, CREDENTIAL_NAME, USERNAME, DATABASE_ROLE, WINDOWS_DOMAIN,
   COMMENTS) AS
  SELECT u.name, o.name, c.username,
  DECODE(bitand(c.flags,1+2), 1,'SYSDBA', 2, 'SYSOPER', NULL),
  c.domain, c.comments
  FROM obj$ o, user$ u, sys.scheduler$_credential c
  WHERE c.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_credentials IS
'All scheduler credentials in the database'
/
COMMENT ON COLUMN dba_scheduler_credentials.credential_name IS
'Name of the scheduler credential'
/
COMMENT ON COLUMN dba_scheduler_credentials.owner IS
'Owner of the scheduler credential'
/
COMMENT ON COLUMN dba_scheduler_credentials.username IS
'User to execute the job as'
/
COMMENT ON COLUMN dba_scheduler_credentials.database_role IS
'Database role to use when logging in (either SYSDBA or SYSOPER or NULL)'
/
COMMENT ON COLUMN dba_scheduler_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN dba_scheduler_credentials.comments IS
'Comments on the credential'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_credentials
  FOR dba_scheduler_credentials
/
GRANT SELECT ON dba_scheduler_credentials TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_credentials
  (CREDENTIAL_NAME, USERNAME, DATABASE_ROLE, WINDOWS_DOMAIN,
   COMMENTS) AS
  SELECT o.name, c.username,
  DECODE(bitand(c.flags,1+2), 1,'SYSDBA', 2, 'SYSOPER', NULL),
  c.domain, c.comments
  FROM obj$ o, sys.scheduler$_credential c
  WHERE o.owner# = USERENV('SCHEMAID') AND c.obj# = o.obj#
/
COMMENT ON TABLE user_scheduler_credentials IS
'Scheduler credentials owned by the current user'
/
COMMENT ON COLUMN user_scheduler_credentials.credential_name IS
'Name of the scheduler credential'
/
COMMENT ON COLUMN user_scheduler_credentials.username IS
'User to execute the job as'
/
COMMENT ON COLUMN user_scheduler_credentials.database_role IS
'Database role to use when logging in (either SYSDBA or SYSOPER or NULL)'
/
COMMENT ON COLUMN user_scheduler_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN user_scheduler_credentials.comments IS
'Comments on the credential'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_credentials
  FOR user_scheduler_credentials
/
GRANT SELECT ON user_scheduler_credentials TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_credentials
  (OWNER, CREDENTIAL_NAME, USERNAME, DATABASE_ROLE, WINDOWS_DOMAIN,
   COMMENTS) AS
  SELECT u.name, o.name, c.username,
  DECODE(bitand(c.flags,1+2), 1,'SYSDBA', 2, 'SYSOPER', NULL),
  c.domain, c.comments
  FROM obj$ o, user$ u, sys.scheduler$_credential c
  WHERE c.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */)
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_credentials IS
'All scheduler credentials visible to the user'
/
COMMENT ON COLUMN all_scheduler_credentials.credential_name IS
'Name of the scheduler credential'
/
COMMENT ON COLUMN all_scheduler_credentials.owner IS
'Owner of the scheduler credential'
/
COMMENT ON COLUMN all_scheduler_credentials.username IS
'User to execute the job as'
/
COMMENT ON COLUMN all_scheduler_credentials.database_role IS
'Database role to use when logging in (either SYSDBA or SYSOPER or NULL)'
/
COMMENT ON COLUMN all_scheduler_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN all_scheduler_credentials.comments IS
'Comments on the credential'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_credentials
  FOR all_scheduler_credentials
/
GRANT SELECT ON all_scheduler_credentials TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_file_watchers
  (OWNER, FILE_WATCHER_NAME, ENABLED, DESTINATION_OWNER, DESTINATION, 
   DIRECTORY_PATH, FILE_NAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, 
   MIN_FILE_SIZE, STEADY_STATE_DURATION, LAST_MODIFIED_TIME, COMMENTS) AS
 SELECT u.name, o.name, decode(bitand(f.flags, 1), 1, 'TRUE', 'FALSE'),
        decode(bitand(f.flags, 8), 0, NULL, 
           substr(f.destination, 1, instr(f.destination, '"')-1)),
        decode(bitand(f.flags, 8), 0, f.destination, 
           substr(f.destination, instr(f.destination, '"')+1,
           length(f.destination) - instr(f.destination, '"'))),
        f.directory_path, f.file_name,
        cu.name, co.name, f.min_file_size, f.steady_state_duration, 
        f.last_modified_time, f.comments
 FROM sys.user$ u, sys.obj$ o, sys.scheduler$_file_watcher f,
      sys.user$ cu, sys.obj$ co
 WHERE f.obj# = o.obj# AND u.user# = o.owner# AND
       f.credoid = co.obj#(+) AND cu.user#(+) = co.owner#
/

COMMENT ON TABLE dba_scheduler_file_watchers IS
'All scheduler file watch requests in the database'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.owner IS
'Owner of file watch request'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.file_watcher_name IS
'Name of file watch request'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.enabled IS
'Is this file watch request enabled'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.destination_owner IS
'Owner of named destination object'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.destination IS
'Name of destination object'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.directory_path IS
'Pathname of directory where file will arrive'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.file_name IS
'Name or pattern specifying the files that need to be monitored'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.credential_owner IS
'Owner of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.credential_name IS
'Name of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.min_file_size IS
'Minimum size of file being monitored'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.steady_state_duration IS
'Time to wait before concluding that the file has stopped growing'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.last_modified_time IS
'Time at which this file watcher was last modified'
/
COMMENT ON COLUMN dba_scheduler_file_watchers.comments IS
'Comments on the file watch request'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_file_watchers
  FOR dba_scheduler_file_watchers
/
GRANT SELECT ON dba_scheduler_file_watchers TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_file_watchers
  (FILE_WATCHER_NAME, ENABLED, DESTINATION_OWNER, DESTINATION, DIRECTORY_PATH, 
   FILE_NAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, MIN_FILE_SIZE, 
   STEADY_STATE_DURATION, LAST_MODIFIED_TIME, COMMENTS) AS
 SELECT o.name, decode(bitand(f.flags, 1), 1, 'TRUE', 'FALSE'), 
        decode(bitand(f.flags, 8), 0, NULL, 
           substr(f.destination, 1, instr(f.destination, '"')-1)),
        decode(bitand(f.flags, 8), 0, f.destination, 
           substr(f.destination, instr(f.destination, '"')+1,
           length(f.destination) - instr(f.destination, '"'))),
        f.directory_path, f.file_name,
        cu.name, co.name, f.min_file_size, f.steady_state_duration, 
        f.last_modified_time, f.comments
 FROM sys.obj$ o, sys.scheduler$_file_watcher f,
      sys.user$ cu, sys.obj$ co
 WHERE f.obj# = o.obj# AND o.owner# = USERENV('SCHEMAID') AND
       f.credoid = co.obj#(+) AND cu.user#(+) = co.owner#
/

COMMENT ON TABLE user_scheduler_file_watchers IS
'Scheduler file watch requests owned by the current user'
/
COMMENT ON COLUMN user_scheduler_file_watchers.file_watcher_name IS
'Name of file watch request'
/
COMMENT ON COLUMN user_scheduler_file_watchers.enabled IS
'Is this file watch request enabled'
/
COMMENT ON COLUMN user_scheduler_file_watchers.destination_owner IS
'Owner of named destination object'
/
COMMENT ON COLUMN user_scheduler_file_watchers.destination IS
'Name of destination object'
/
COMMENT ON COLUMN user_scheduler_file_watchers.directory_path IS
'Pathname of directory where file will arrive'
/
COMMENT ON COLUMN user_scheduler_file_watchers.file_name IS
'Name or pattern specifying the files that need to be monitored'
/
COMMENT ON COLUMN user_scheduler_file_watchers.credential_owner IS
'Owner of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN user_scheduler_file_watchers.credential_name IS
'Name of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN user_scheduler_file_watchers.min_file_size IS
'Minimum size of file being monitored'
/
COMMENT ON COLUMN user_scheduler_file_watchers.steady_state_duration IS
'Time to wait before concluding that the file has stopped growing'
/
COMMENT ON COLUMN user_scheduler_file_watchers.last_modified_time IS
'Time at which this file watcher was last modified'
/
COMMENT ON COLUMN user_scheduler_file_watchers.comments IS
'Comments on the file watch request'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_file_watchers
  FOR user_scheduler_file_watchers
/
GRANT SELECT ON user_scheduler_file_watchers TO PUBLIC WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_file_watchers
  (OWNER, FILE_WATCHER_NAME, ENABLED, DESTINATION_OWNER, DESTINATION, 
   DIRECTORY_PATH, FILE_NAME, CREDENTIAL_OWNER, CREDENTIAL_NAME, MIN_FILE_SIZE, 
   STEADY_STATE_DURATION, LAST_MODIFIED_TIME, COMMENTS) AS
 SELECT u.name, o.name, decode(bitand(f.flags, 1), 1, 'TRUE', 'FALSE'),
        decode(bitand(f.flags, 8), 0, NULL, 
           substr(f.destination, 1, instr(f.destination, '"')-1)),
        decode(bitand(f.flags, 8), 0, f.destination, 
           substr(f.destination, instr(f.destination, '"')+1,
           length(f.destination) - instr(f.destination, '"'))),
        f.directory_path, f.file_name,
        cu.name, co.name, f.min_file_size, f.steady_state_duration, 
        f.last_modified_time, f.comments
 FROM sys.user$ u, sys.obj$ o, sys.scheduler$_file_watcher f,
      sys.user$ cu, sys.obj$ co
 WHERE f.obj# = o.obj# AND u.user# = o.owner# AND
       f.credoid = co.obj#(+) AND cu.user#(+) = co.owner# AND
       (o.owner# = userenv('SCHEMAID')
          or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */)
                 )
          and o.owner#!=0)
      )
/

COMMENT ON TABLE all_scheduler_file_watchers IS
'Scheduler file watch requests visible to the current user'
/
COMMENT ON COLUMN all_scheduler_file_watchers.owner IS
'Owner of file watch request'
/
COMMENT ON COLUMN all_scheduler_file_watchers.file_watcher_name IS
'Name of file watch request'
/
COMMENT ON COLUMN all_scheduler_file_watchers.enabled IS
'Is this file watch request enabled'
/
COMMENT ON COLUMN all_scheduler_file_watchers.destination_owner IS
'Owner of named destination object'
/
COMMENT ON COLUMN all_scheduler_file_watchers.destination IS
'Name of destination object'
/
COMMENT ON COLUMN all_scheduler_file_watchers.directory_path IS
'Pathname of directory where file will arrive'
/
COMMENT ON COLUMN all_scheduler_file_watchers.file_name IS
'Name or pattern specifying the files that need to be monitored'
/
COMMENT ON COLUMN all_scheduler_file_watchers.credential_owner IS
'Owner of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN all_scheduler_file_watchers.credential_name IS
'Name of credential that should be used to authorize file watch'
/
COMMENT ON COLUMN all_scheduler_file_watchers.min_file_size IS
'Minimum size of file being monitored'
/
COMMENT ON COLUMN all_scheduler_file_watchers.steady_state_duration IS
'Time to wait before concluding that the file has stopped growing'
/
COMMENT ON COLUMN all_scheduler_file_watchers.last_modified_time IS
'Time at which this file watcher was last modified'
/
COMMENT ON COLUMN all_scheduler_file_watchers.comments IS
'Comments on the file watch request'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_file_watchers
  FOR all_scheduler_file_watchers
/
GRANT SELECT ON all_scheduler_file_watchers TO PUBLIC WITH GRANT OPTION
/

-- Job e-mail notification views
CREATE OR REPLACE VIEW dba_scheduler_notifications
  (OWNER,JOB_NAME,JOB_SUBNAME,RECIPIENT,SENDER,SUBJECT,BODY,
   FILTER_CONDITION,EVENT,EVENT_FLAG)
  AS SELECT sr.owner, sr.job_name , sr.job_subname, sr.recipient,
    sr.sender , sr.subject , sr.body , sr.filter_condition ,
    DECODE(BITAND(sr.event_flag,1024-1),1,'JOB_STARTED',2,'JOB_SUCCEEDED',
      4,'JOB_FAILED',8,'JOB_BROKEN',16,'JOB_COMPLETED',32,'JOB_STOPPED',
      64,'JOB_SCH_LIM_REACHED',128,'JOB_DISABLED',256,'JOB_CHAIN_STALLED',
      512,'JOB_OVER_MAX_DUR', NULL), sr.event_flag
  FROM scheduler$_notification sr
  WHERE BITAND(flags,1)=0
/
COMMENT ON TABLE dba_scheduler_notifications IS
'All job e-mail notifications in the database'
/
COMMENT ON COLUMN dba_scheduler_notifications.owner IS
'Owner of the job this notification is for'
/
COMMENT ON COLUMN dba_scheduler_notifications.job_name IS
'Name of the job this notification is for'
/
COMMENT ON COLUMN dba_scheduler_notifications.job_subname IS
'Subname of the job this notification is for'
/
COMMENT ON COLUMN dba_scheduler_notifications.recipient IS
'E-mail address to send this e-mail notification to'
/
COMMENT ON COLUMN dba_scheduler_notifications.sender IS
'E-mail address to send this e-mail notification from'
/
COMMENT ON COLUMN dba_scheduler_notifications.subject IS
'Subject of the notification e-mail'
/
COMMENT ON COLUMN dba_scheduler_notifications.body IS
'Body of the notification e-mail'
/
COMMENT ON COLUMN dba_scheduler_notifications.filter_condition IS
'Filter specifying which job events to send notifications for'
/
COMMENT ON COLUMN dba_scheduler_notifications.event IS
'Job event to send notifications for'
/
COMMENT ON COLUMN dba_scheduler_notifications.event_flag IS
'Event number of job event to send notifications for'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_notifications
  FOR dba_scheduler_notifications
/
GRANT SELECT ON dba_scheduler_notifications TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_notifications
  (JOB_NAME,JOB_SUBNAME,RECIPIENT,SENDER,SUBJECT,BODY,
   FILTER_CONDITION,EVENT,EVENT_FLAG)
  AS SELECT sr.job_name , sr.job_subname, sr.recipient,
    sr.sender , sr.subject , sr.body , sr.filter_condition ,
    DECODE(BITAND(sr.event_flag,1024-1),1,'JOB_STARTED',2,'JOB_SUCCEEDED',
      4,'JOB_FAILED',8,'JOB_BROKEN',16,'JOB_COMPLETED',32,'JOB_STOPPED',
      64,'JOB_SCH_LIM_REACHED',128,'JOB_DISABLED',256,'JOB_CHAIN_STALLED',
      512,'JOB_OVER_MAX_DUR', NULL), sr.event_flag
  FROM scheduler$_notification sr
  WHERE sr.owner = sys_context('USERENV', 'CURRENT_USER')
    AND BITAND(flags,1)=0
/
COMMENT ON TABLE user_scheduler_notifications IS
'All e-mail notifications for jobs owned by the current user'
/
COMMENT ON COLUMN user_scheduler_notifications.job_name IS
'Name of the job this notification is for'
/
COMMENT ON COLUMN user_scheduler_notifications.job_subname IS
'Subname of the job this notification is for'
/
COMMENT ON COLUMN user_scheduler_notifications.recipient IS
'E-mail address to send this e-mail notification to'
/
COMMENT ON COLUMN user_scheduler_notifications.sender IS
'E-mail address to send this e-mail notification from'
/
COMMENT ON COLUMN user_scheduler_notifications.subject IS
'Subject of the notification e-mail'
/
COMMENT ON COLUMN user_scheduler_notifications.body IS
'Body of the notification e-mail'
/
COMMENT ON COLUMN user_scheduler_notifications.filter_condition IS
'Filter specifying which job events to send notifications for'
/
COMMENT ON COLUMN user_scheduler_notifications.event IS
'Job event to send notifications for'
/
COMMENT ON COLUMN user_scheduler_notifications.event_flag IS
'Event number of job event to send notifications for'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_notifications
  FOR user_scheduler_notifications
/
GRANT SELECT ON user_scheduler_notifications TO public
/

CREATE OR REPLACE VIEW all_scheduler_notifications
  (OWNER,JOB_NAME,JOB_SUBNAME,RECIPIENT,SENDER,SUBJECT,BODY,
   FILTER_CONDITION,EVENT,EVENT_FLAG)
  AS SELECT sr.owner, sr.job_name , sr.job_subname, sr.recipient,
    sr.sender , sr.subject , sr.body , sr.filter_condition ,
    DECODE(BITAND(sr.event_flag,1024-1),1,'JOB_STARTED',2,'JOB_SUCCEEDED',
      4,'JOB_FAILED',8,'JOB_BROKEN',16,'JOB_COMPLETED',32,'JOB_STOPPED',
      64,'JOB_SCH_LIM_REACHED',128,'JOB_DISABLED',256,'JOB_CHAIN_STALLED',
      512,'JOB_OVER_MAX_DUR', NULL), sr.event_flag
  FROM scheduler$_notification sr
  WHERE
    BITAND(flags,1)=0 AND
    (sr.owner = sys_context('USERENV', 'CURRENT_USER')
       or exists
            (select null
             from sys.objauth$ oa, sys.obj$ o, sys.user$ u
             where oa.grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
               and oa.obj#=o.obj# and o.owner#=u.user#
               and o.name=sr.job_name and u.name=sr.owner
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number = -265 /* CREATE ANY JOB */
                 )
          and sr.owner!='SYS'
         )
    )
/
COMMENT ON TABLE all_scheduler_notifications IS
'All job e-mail notifications visible to the current user'
/
COMMENT ON COLUMN all_scheduler_notifications.owner IS
'Owner of the job this notification is for'
/
COMMENT ON COLUMN all_scheduler_notifications.job_name IS
'Name of the job this notification is for'
/
COMMENT ON COLUMN all_scheduler_notifications.job_subname IS
'Subname of the job this notification is for'
/
COMMENT ON COLUMN all_scheduler_notifications.recipient IS
'E-mail address to send this e-mail notification to'
/
COMMENT ON COLUMN all_scheduler_notifications.sender IS
'E-mail address to send this e-mail notification from'
/
COMMENT ON COLUMN all_scheduler_notifications.subject IS
'Subject of the notification e-mail'
/
COMMENT ON COLUMN all_scheduler_notifications.body IS
'Body of the notification e-mail'
/
COMMENT ON COLUMN all_scheduler_notifications.filter_condition IS
'Filter specifying which job events to send notifications for'
/
COMMENT ON COLUMN all_scheduler_notifications.event IS
'Job event to send notifications for'
/
COMMENT ON COLUMN all_scheduler_notifications.event_flag IS
'Event number of job event to send notifications for'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_notifications
  FOR all_scheduler_notifications
/
GRANT SELECT ON all_scheduler_notifications TO public
/

