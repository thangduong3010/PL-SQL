Rem
Rem $Header: rdbms/admin/catcap.sql /st_rdbms_11.2.0/2 2012/07/04 15:29:15 thoang Exp $
Rem
Rem catcap.sql
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catcap.sql - streams capture views
Rem
Rem    DESCRIPTION
Rem      This file contains all the views for streams capture
Rem
Rem    NOTES
Rem
Rem    The order of the from clause listed from left to right
Rem    should be from highest cardinality to lowest cardinality for better
Rem    performance.  The optimizer choses driving tables from right to left
Rem    and using smaller tables first will eliminate more rows early on.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lzheng      06/21/12 - extend DBA_CAPTURE for OGG lightweight Capture
Rem    lzheng      06/15/12 - add (g)v$goldengate_capture
Rem    yurxu       05/26/11 - lrg-5519739
Rem    rmao        05/17/10 - bug 9716742: change dba_capture.purpose
Rem    rmao        04/27/10 - add "XStream Streams" to dba_capture.purpose
Rem    thoang      03/10/10 - modify dba_capture.purpose to set GG first
Rem    juyuan      01/25/10 - add dba_capture.purpose
Rem    yurxu       11/10/09 - add start_time in DBA_CAPTURE view
Rem    rihuang     08/19/09 - filter out recyclebin obj from prepared tables
Rem    rmao        03/23/09 - drop columns job_status, job_next_run_date from
Rem                           dba_streams_split_merge_hist
Rem    rmao        11/19/08 - define dbms_streams_split_merge_hist
Rem    rmao        11/11/08 - add script_status, job_next_run_date to
Rem                           dba_streams_split_merge view
Rem    rmao        02/15/08 - add dba_streams_split_merge view
Rem    legao       02/01/07 - modify DBA_CAPTURE view implementation
Rem    cschmidt    08/08/06 - get_req_ckpt_scn() has changed - update
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    thoang      05/06/05 - add synchronous capture 
Rem    htran       10/27/04 - add supplemental logging info to prepared views
Rem    nshodhan    07/29/04 - add resetlogs_change#, reset_timestamp
Rem    nshodhan    07/07/04 - add bitand for purgeable
Rem    nshodhan    06/11/04 - add last_enqueued_scn, checkpoint_retention_time
Rem    mtao        04/06/04 - bug 3376610: advance_session
Rem    sbalaram    10/28/03 - Bug 3219753: select correct checkpoint_scn
Rem    wesmith     07/29/03 - view DBA_CAPTURE: remove join to AQ tables
Rem    htran       06/26/03 - optimized dba/all_capture_prepared_tables
Rem    elu         04/23/03 - modify all_capture
Rem    nshodhan    04/21/03 - expose downstream capture to users
Rem    alakshmi    03/07/03 - add capture_user
Rem    htran       11/07/02 - a.include changed to substr(a.include, 1, 3)
Rem    alakshmi    11/11/02 - add version in dba_capture
Rem    liwong      11/04/02 - Add logfile_assignment
Rem    liwong      10/23/02 - Add status_change_time
Rem    htran       10/16/02 - unify some names with logminer
Rem    dcassine    10/01/02 - added start and end date to _DBA_CAPTURE
Rem    nshodhan    10/02/02 - add max_checkpoint_scn
Rem    nshodhan    09/15/02 - use_dblink -> use_database_link
Rem    elu         09/10/02 - add negative rule sets
Rem    rrawat      09/25/02 - Bug-2293353
Rem    liwong      08/19/02 - Modify DBA_CAPTURE_EXTRA_ATTRIBUTES
Rem    nshodhan    07/26/02 - fix all_capture
Rem    liwong      07/22/02 - Extend LCR support
Rem    liwong      07/07/02 - Downstream capture
Rem    nshodhan    07/02/02 - Downstream capture
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    nshodhan    03/22/02 - bug#2265077: missing cols in ALL_CAPTURE
Rem    nshodhan    03/19/02 - fix dba_capture.start_scn
Rem    narora      01/11/02 - add captured_scn, applied_scn
Rem    wesmith     01/09/02 - Streams export/import support
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    masubram    11/01/01 - modify views accessing  streams$_capture_object
Rem    sbalaram    10/29/01 - add views
Rem    apadmana    10/26/01 - Created
Rem

----------------------------------------------------------------------------
-- view to get capture process details
----------------------------------------------------------------------------
-- Private view select to all columns from streams$_capture_process
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_CAPTURE"
as select 
  queue_oid, queue_owner, queue_name, capture#, capture_name,
  status, ruleset_owner, ruleset_name, logmnr_sid, predumpscn,
  dumpseqbeg, dumpseqend, postdumpscn, flags, start_scn, capture_userid,
  spare1, spare2, spare3, use_dblink, first_scn, source_dbname,
  spare4, spare5, spare6, spare7, negative_ruleset_owner, 
  negative_ruleset_name, start_date, end_date, status_change_time,
  error_number, error_message, version, start_scn_time
from sys.streams$_capture_process
/
grant select on "_DBA_CAPTURE" to exp_full_database
/

create or replace view "_SXGG_DBA_CAPTURE"
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME,
   RULE_SET_OWNER, CAPTURE_USER, START_SCN, STATUS, CAPTURED_SCN, APPLIED_SCN,
   USE_DATABASE_LINK, FIRST_SCN, SOURCE_DATABASE, SOURCE_DBID,
   SOURCE_RESETLOGS_SCN, SOURCE_RESETLOGS_TIME, LOGMINER_ID,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, MAX_CHECKPOINT_SCN,
   REQUIRED_CHECKPOINT_SCN, LOGFILE_ASSIGNMENT, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE, VERSION, CAPTURE_TYPE, LAST_ENQUEUED_SCN,
   CHECKPOINT_RETENTION_TIME, START_TIME, PURPOSE, OLDEST_SCN)
as
select cp.capture_name,
       cp.queue_name, cp.queue_owner, cp.ruleset_name,
       cp.ruleset_owner, u.name, cp.start_scn,
       decode(cp.status, 1, 'DISABLED',
                         2, 'ENABLED',
                         4, 'ABORTED', 'UNKNOWN'),
       cp.spare1, cp.spare2,
       decode(cp.use_dblink, 1, 'YES', 'NO'),
       cp.first_scn, cp.source_dbname, dl.source_dbid, dl.source_resetlogs_scn,
       dl.source_resetlogs_time, cp.logmnr_sid, cp.negative_ruleset_name,
       cp.negative_ruleset_owner,
       nvl(dl.checkpoint_scn, 0),
       dbms_logrep_util.get_req_ckpt_scn(dl.id, nvl(cp.spare2,0)),
       decode(bitand(cp.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'),
       cp.status_change_time, cp.error_number,
       cp.error_message, cp.version,
       decode(bitand(cp.flags, 64), 64, 'DOWNSTREAM', 'LOCAL'),
       dbms_logrep_util.get_last_enq_scn(cp.capture_name), cp.spare3,
       cp.start_scn_time,
       -- When GG and XOUT are set concurrently, GG purpose takes precedence.  
       (case
         when bitand(cp.flags, 524288) = 524288    -- 0x80000
           then 'GoldenGate Capture'
         when bitand(cp.flags, 1048576) = 1048576  -- 0x100000
           then 'XStream Out'
         when bitand(cp.flags, 2048)= 2048  -- 0x800
           then 'AUDIT VAULT'
         when bitand(cp.flags, 2) = 2
           then 'CHANGE DATA CAPTURE'
        else
          ( select 'XStream Streams' from  dual where exists
              (select 1 from sys.props$
                where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T')
            union
            select 'Streams' from  dual where NOT exists
              (select 1 from sys.props$
             where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T'))
       end), cp.spare5
  from "_DBA_CAPTURE" cp, dba_logmnr_session dl,
       sys.user$ u
 where dl.id (+) = cp.logmnr_sid
   and cp.capture_userid = u.user# (+)
   and (bitand(cp.flags,512) != 512) -- skip sync capture
/

create or replace view DBA_CAPTURE
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME,
   RULE_SET_OWNER, CAPTURE_USER, START_SCN, STATUS, CAPTURED_SCN, APPLIED_SCN,
   USE_DATABASE_LINK, FIRST_SCN, SOURCE_DATABASE, SOURCE_DBID,
   SOURCE_RESETLOGS_SCN, SOURCE_RESETLOGS_TIME, LOGMINER_ID,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, MAX_CHECKPOINT_SCN,
   REQUIRED_CHECKPOINT_SCN, LOGFILE_ASSIGNMENT, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE, VERSION, CAPTURE_TYPE, LAST_ENQUEUED_SCN,
   CHECKPOINT_RETENTION_TIME, START_TIME, PURPOSE,
   CLIENT_NAME, CLIENT_STATUS, OLDEST_SCN, FILTERED_SCN)
as
select capture_name, queue_name, queue_owner, rule_set_name,
   rule_set_owner, capture_user, start_scn, status, captured_scn, applied_scn,
   use_database_link, first_scn, source_database, source_dbid,
   source_resetlogs_scn, source_resetlogs_time, logminer_id,
   negative_rule_set_name, negative_rule_set_owner, max_checkpoint_scn,
   required_checkpoint_scn, logfile_assignment, status_change_time,
   error_number, error_message, version, capture_type, last_enqueued_scn,
   checkpoint_retention_time, start_time, purpose, 
   case when 
      cp.purpose = 'GoldenGate Capture' or cp.purpose = 'XStream Out'
   then
      decode((select count(*) from xstream$_server x
           where x.capture_name = cp.capture_name),
           1,
           decode(cp.purpose, 'GoldenGate Capture',
                     (select substr(x.user_comment,
                             1,instr(x.user_comment,' ') - 1)   -- Extract Name
                      from xstream$_server x
                      where x.capture_name = cp.capture_name),
                     (select x.server_name              -- Outbound Server Name
                      from xstream$_server x
                      where x.capture_name = cp.capture_name)
                     ),
           NULL)
   else null
   end,
   case when 
      cp.purpose = 'GoldenGate Capture' or cp.purpose = 'XStream Out'
   then
      decode((select count(*) from xstream$_server x
           where x.capture_name = cp.capture_name),
           1,
           (decode(cp.status,
                   'ENABLED',
                   decode(cp.purpose,
                         'GoldenGate Capture',
                          decode((select count(gc.server_sid)
                                  from gv$goldengate_capture gc
                                  where gc.capture_name = cp.capture_name),
                                  0,
                                  'DETACHED', 'ATTACHED'),
                          decode((select count(*)
                                  from gv$xstream_outbound_server g,
                                       xstream$_server x
                                  where g.server_name = x.server_name),
                                  0,
                                  'DETACHED', 'ATTACHED')),
                   cp.status)),
            NULL)
   else null
   end,
   case when cp.purpose = 'GoldenGate Capture' or cp.purpose = 'XStream Out'
        then cp.oldest_scn
        else null
   end,
   case when 
      cp.purpose = 'GoldenGate Capture' or cp.purpose = 'XStream Out'
   then
      decode((select count(*)
           from sys.xstream$_server x, sys.streams$_apply_process ap,
                sys.streams$_apply_milestone am
           where cp.capture_name = x.capture_name
                 and x.server_name = ap.apply_name
                 and cp.queue_owner = ap.queue_owner
                 and cp.queue_name = ap.queue_name
                 and ap.apply# = am.apply#),
           1,
           (select am.start_scn
            from sys.xstream$_server x, sys.streams$_apply_process ap,
                 sys.streams$_apply_milestone am
            where cp.capture_name = x.capture_name
                  and x.server_name = ap.apply_name
                  and cp.queue_owner = ap.queue_owner
                  and cp.queue_name = ap.queue_name
                  and ap.apply# = am.apply#),
           NULL)
   else null
   end
from "_SXGG_DBA_CAPTURE" cp
/

comment on table DBA_CAPTURE is
'Details about the capture process'
/
comment on column DBA_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column DBA_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column DBA_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column DBA_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
comment on column DBA_CAPTURE.START_SCN is
'The SCN from which capturing will be resumed'
/
comment on column DBA_CAPTURE.STATUS is
'Status of the capture process: DISABLED, ENABLED, ABORTED'
/
comment on column DBA_CAPTURE.STATUS_CHANGE_TIME is
'The time that STATUS of the capture process was changed'
/
comment on column DBA_CAPTURE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_CAPTURE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
comment on column DBA_CAPTURE.CAPTURED_SCN is
'Everything up to this SCN has been captured'
/
comment on column DBA_CAPTURE.APPLIED_SCN is
'Everything up to this SCN has been applied'
/
comment on column DBA_CAPTURE.USE_DATABASE_LINK is
'Can use database_link from downstream to source database'
/
comment on column DBA_CAPTURE.FIRST_SCN is
'SCN from which the capture process can be restarted'
/
comment on column DBA_CAPTURE.SOURCE_DATABASE is
'Global name of the source database'
/
comment on column DBA_CAPTURE.SOURCE_DBID is
'DBID of the source database'
/
comment on column DBA_CAPTURE.SOURCE_RESETLOGS_SCN is
'Resetlogs_SCN of the source database'
/
comment on column DBA_CAPTURE.SOURCE_RESETLOGS_TIME is
'Resetlogs time of the source database'
/
comment on column DBA_CAPTURE.LOGMINER_ID is
'Session ID of LogMiner session associated with the capture process'
/
comment on column DBA_CAPTURE.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by capture process for filtering'
/
comment on column DBA_CAPTURE.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_CAPTURE.MAX_CHECKPOINT_SCN is
'SCN at which the last check point was taken by the capture process'
/
comment on column DBA_CAPTURE.REQUIRED_CHECKPOINT_SCN is
'the safe SCN at which the meta-data for the capture process can be purged'
/
comment on column DBA_CAPTURE.LOGFILE_ASSIGNMENT is
'The logfile assignment type for the capture process'
/
comment on column DBA_CAPTURE.VERSION is
'Version number of the capture process'
/
comment on column DBA_CAPTURE.CAPTURE_TYPE is
'Type of the capture process'
/
comment on column DBA_CAPTURE.LAST_ENQUEUED_SCN is
'SCN of the last message enqueued by the capture process'
/
comment on column DBA_CAPTURE.CHECKPOINT_RETENTION_TIME is
'Number of days checkpoints will be retained by the capture process'
/
comment on column DBA_CAPTURE.START_TIME is
'The time when the capture process was started'
/
comment on column DBA_CAPTURE.PURPOSE is
'Purpose of the capture process'
/
comment on column DBA_CAPTURE.CLIENT_NAME is
'Name of the client process of the capture'
/
comment on column DBA_CAPTURE.CLIENT_STATUS is
'Status of the client process of the capture'
/
comment on column DBA_CAPTURE.OLDEST_SCN is
'Oldest SCN of the transaction currently being applied'
/
comment on column DBA_CAPTURE.FILTERED_SCN is
'SCN of the low watermark transaction processed'
/


create or replace public synonym DBA_CAPTURE for DBA_CAPTURE
/
grant select on DBA_CAPTURE to select_catalog_role
/



-- view of details of automatic split/merge jobs that are not complete yet.
-- Note that 
-- (1)the decoding of streams_type should be consistent with the
--    definitions of streams_type in dbms_streams_adm_utl (logrep/prvthstr.sql)
--    Other decodings should be consistent with constants definitions in
--    dbms_streams_sm (logrep/prvthssm.sql)
-- (2)the decoding of r.status should be consistent with
--    dba_recoverable_script view
create or replace view DBA_STREAMS_SPLIT_MERGE
  (original_capture_name,    cloned_capture_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name,    cloned_streams_name,
   streams_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   job_state,                job_next_run_date,
   error_number,             error_message)
as
select s.original_capture_name,   s.cloned_capture_name,
       decode(s.original_capture_name, NULL, NULL,
                                       NVL(c1.status, 'DROPPED')),
       decode(s.cloned_capture_name, NULL, NULL,
                                       NVL(c2.status, 'DROPPED')),
       s.original_streams_name,   s.cloned_streams_name,
       decode(s.streams_type, 2, 'PROPAGATION',
                              3, 'APPLY'),
       s.recoverable_script_id,   NVL(decode(r.status, 1, 'GENERATING',
                                                       2, 'NOT EXECUTED',
                                                       3, 'EXECUTING',
                                                       4, 'EXECUTED',
                                                       5, 'ERROR'),
                                      decode(s.recoverable_script_id,
                                                       NULL, NULL,
                                                       'DROPPED')),
       decode(s.action_type, 1, 'SPLIT',
                             2, 'MERGE',
                             3, 'MONITOR'),
       decode(s.action_threshold, 2147483647, 'INFINITE',
                                  s.action_threshold),
       decode(s.status, 1, 'NOTHING TO SPLIT',
                        2, 'ABOUT TO SPLIT',
                        3, 'SPLITTING',
                        4, 'SPLIT DONE',
                        5, 'NOTHING TO MERGE',
                        6, 'ABOUT TO MERGE',
                        7, 'MERGING',
                        8, 'MERGE DONE',
                        9, 'ERROR',
                       10, 'NONSPLITTABLE'),
       s.status_update_time,
       s.creation_time,
       s.lag,
       s.job_owner,               s.job_name,
       decode(s.job_name, NULL, NULL,
                          NVL(j.state, 'DROPPED')),
       decode(s.job_name, NULL, NULL,
                          j.next_run_date),
       s.error_number,            s.error_message
  from sys.streams$_split_merge s, dba_capture c1, dba_capture c2,
       dba_scheduler_jobs j, sys.reco_script$ r
 where s.original_capture_name = c1.capture_name (+)
   and s.cloned_capture_name   = c2.capture_name (+)
   and s.job_name              =  j.job_name     (+)
   and s.job_owner             =  j.owner        (+)
   and s.recoverable_script_id =  r.oid          (+)
   and s.active               != 1
/

comment on table DBA_STREAMS_SPLIT_MERGE is
'view of details of split/merge jobs/status about streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ORIGINAL_STREAMS_NAME is
'name of original streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CLONED_STREAMS_NAME is
'name of cloned streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STREAMS_TYPE is
'type of streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.SCRIPT_STATUS is
'status of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ACTION_TYPE is
'type of action performed on this streams (either split or merge)'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STATUS is
'status of streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_STREAMS_SPLIT_MERGE.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_NAME is
'name of the job to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_STATE is
'state of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE.JOB_NEXT_RUN_DATE is
'when will the job run next time'
/
comment on column DBA_STREAMS_SPLIT_MERGE.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_STREAMS_SPLIT_MERGE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_STREAMS_SPLIT_MERGE
  for DBA_STREAMS_SPLIT_MERGE
/
grant select on DBA_STREAMS_SPLIT_MERGE to select_catalog_role
/

-- view of details of completed automatic split/merge jobs
-- Note that 
-- (1)the decoding of streams_type should be consistent with the
--    definitions of streams_type in dbms_streams_adm_utl (logrep/prvthstr.sql)
--    Other decodings should be consistent with constants definitions in
--    dbms_streams_sm (logrep/prvthssm.sql)
-- (2)the decoding of r.status should be consistent with
--    dba_recoverable_script view
create or replace view DBA_STREAMS_SPLIT_MERGE_HIST
  (original_capture_name,    cloned_capture_name,
   original_queue_owner,     original_queue_name,
   cloned_queue_owner,       cloned_queue_name,
   original_capture_status,  cloned_capture_status,
   original_streams_name,    cloned_streams_name,
   streams_type,
   recoverable_script_id,    script_status,
   action_type,              action_threshold,
   status,                   status_update_time,
   creation_time,
   lag,
   job_owner,                job_name,
   error_number,             error_message)
as
select s.original_capture_name,   s.cloned_capture_name,
       s.original_queue_owner,    s.original_queue_name,
       s.cloned_queue_owner,      s.cloned_queue_name,
       decode(s.original_capture_name, NULL, NULL,
                                       NVL(c1.status, 'DROPPED')),
       decode(s.cloned_capture_name, NULL, NULL,
                                       NVL(c2.status, 'DROPPED')),
       s.original_streams_name,   s.cloned_streams_name,
       decode(s.streams_type, 2, 'PROPAGATION',
                              3, 'APPLY'),
       s.recoverable_script_id,   NVL(decode(r.status, 1, 'GENERATING',
                                                       2, 'NOT EXECUTED',
                                                       3, 'EXECUTING',
                                                       4, 'EXECUTED',
                                                       5, 'ERROR'),
                                      decode(s.recoverable_script_id,
                                                       NULL, NULL,
                                                       'DROPPED')),
       decode(s.action_type, 1, 'SPLIT',
                             2, 'MERGE',
                             3, 'MONITOR'),
       decode(s.action_threshold, 2147483647, 'INFINITE',
                                  s.action_threshold),
       decode(s.status, 1, 'NOTHING TO SPLIT',
                        2, 'ABOUT TO SPLIT',
                        3, 'SPLITTING',
                        4, 'SPLIT DONE',
                        5, 'NOTHING TO MERGE',
                        6, 'ABOUT TO MERGE',
                        7, 'MERGING',
                        8, 'MERGE DONE',
                        9, 'ERROR',
                       10, 'NONSPLITTABLE'),
       s.status_update_time,
       s.creation_time,
       s.lag,
       s.job_owner,               s.job_name,
       s.error_number,            s.error_message
  from sys.streams$_split_merge s, dba_capture c1, dba_capture c2,
       sys.reco_script$ r
 where s.original_capture_name = c1.capture_name (+)
   and s.cloned_capture_name   = c2.capture_name (+)
   and s.recoverable_script_id =  r.oid          (+)
   and s.active               != 2
/

comment on table DBA_STREAMS_SPLIT_MERGE_HIST is
'history view of details of split/merge jobs/status about streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_NAME is
'name of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_CAPTURE_NAME is
'name of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_OWNER is
'name of original queue owner'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_QUEUE_NAME is
'name of original queue'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_QUEUE_OWNER is
'name of cloned queue owner'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_QUEUE_NAME is
'name of cloned queue'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_CAPTURE_STATUS is
'status of the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_CAPTURE_STATUS is
'status of the cloned capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ORIGINAL_STREAMS_NAME is
'name of original streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CLONED_STREAMS_NAME is
'name of cloned streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STREAMS_TYPE is
'type of streams (propagation or local apply)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.RECOVERABLE_SCRIPT_ID is
'unique oid of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.SCRIPT_STATUS is
'status of the script to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ACTION_TYPE is
'type of action performed on this streams (either split or merge)'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ACTION_THRESHOLD is
'value of split_threshold or merge_threshold'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STATUS is
'status of streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.STATUS_UPDATE_TIME is
'time when status was last updated'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.CREATION_TIME is
'time when this row was created'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.JOB_NAME is
'name of the job to split or merge streams'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.JOB_OWNER is
'name of the owner of the job'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.LAG is
'the time in seconds that the cloned capture lags behind the original capture'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column DBA_STREAMS_SPLIT_MERGE_HIST.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
create or replace public synonym DBA_STREAMS_SPLIT_MERGE_HIST
  for DBA_STREAMS_SPLIT_MERGE_HIST
/
grant select on DBA_STREAMS_SPLIT_MERGE_HIST to select_catalog_role
/

----------------------------------------------------------------------------

-- View of capture processes
create or replace view ALL_CAPTURE
as
select c.*
  from dba_capture c
 where c.capture_user in
         (select u.name
            from sys.user$ u, dba_role_privs rp
           where u.user# = userenv('SCHEMAID'))
    or userenv('SCHEMAID') in
         (select u.user#
            from sys.user$ u, dba_role_privs rp 
           where (u.name = rp.grantee)
             and (rp.granted_role = 'SELECT_CATALOG_ROLE' or
                  rp.granted_role = 'DBA'))
/
comment on table ALL_CAPTURE is
'Details about each capture process that stores the captured changes in a queue visible to the current user'
/
comment on column ALL_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column ALL_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column ALL_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column ALL_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_CAPTURE.START_SCN is
'The SCN from which capturing will be resumed'
/
comment on column ALL_CAPTURE.STATUS is
'Status of the capture process: DISABLED, ENABLED, ABORTED'
/
comment on column ALL_CAPTURE.STATUS_CHANGE_TIME is
'The time that STATUS of the capture process was changed'
/
comment on column ALL_CAPTURE.ERROR_NUMBER is
'Error number if the capture process was aborted'
/
comment on column ALL_CAPTURE.ERROR_MESSAGE is
'Error message if the capture process was aborted'
/
comment on column ALL_CAPTURE.CAPTURED_SCN is
'Everything up to this SCN has been captured'
/
comment on column ALL_CAPTURE.APPLIED_SCN is
'Everything up to this SCN has been applied'
/
comment on column ALL_CAPTURE.USE_DATABASE_LINK is
'Can use database_link from downstream to source database'
/
comment on column ALL_CAPTURE.FIRST_SCN is
'SCN from which the capture process can be restarted'
/
comment on column ALL_CAPTURE.SOURCE_DATABASE is
'Global name of the source database'
/
comment on column ALL_CAPTURE.SOURCE_DBID is
'DBID of the source database'
/
comment on column ALL_CAPTURE.SOURCE_RESETLOGS_SCN is
'Resetlogs_SCN of the source database'
/
comment on column ALL_CAPTURE.SOURCE_RESETLOGS_TIME is
'Resetlogs time of the source database'
/
comment on column ALL_CAPTURE.LOGMINER_ID is
'Session ID of LogMiner session associated with the capture process'
/
comment on column ALL_CAPTURE.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by capture process for filtering'
/
comment on column ALL_CAPTURE.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column ALL_CAPTURE.MAX_CHECKPOINT_SCN is
'SCN at which the last check point was taken by the capture process'
/
comment on column ALL_CAPTURE.REQUIRED_CHECKPOINT_SCN is
'the safe SCN at which the meta-data for the capture process can be purged'
/
comment on column ALL_CAPTURE.LOGFILE_ASSIGNMENT is
'The logfile assignment type for the capture process'
/
comment on column ALL_CAPTURE.VERSION is
'Version number of the capture process'
/
comment on column ALL_CAPTURE.CAPTURE_TYPE is
'Type of the capture process'
/
comment on column ALL_CAPTURE.LAST_ENQUEUED_SCN is
'SCN of the last message enqueued by the capture process'
/
comment on column ALL_CAPTURE.CHECKPOINT_RETENTION_TIME is
'Number of days checkpoints will be retained by the capture process'
/
create or replace public synonym ALL_CAPTURE for ALL_CAPTURE
/
grant select on ALL_CAPTURE to public with grant option
/

----------------------------------------------------------------------------
-- view to get capture process parameters
--
--  Note: process_type = 2 corresponds to the package variable
--        dbms_streams_adm_utl.streams_type_capture (prvtbsdm.sql)
--        and the macro KNLU_CAPTURE_PROC (knlu.h). This *must* be
--        kept in sync with both of these.
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PARAMETERS
  (CAPTURE_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select q.capture_name, p.name, p.value,
       decode(p.user_changed_flag, 1, 'YES', 'NO')
  from sys.streams$_process_params p, sys.streams$_capture_process q
 where p.process_type = 2
   and p.process# = q.capture#
   and /* display internal parameters if the user changed them */
       (p.internal_flag = 0
        or
        (p.internal_flag = 1 and p.user_changed_flag = 1)
       )
/
comment on table DBA_CAPTURE_PARAMETERS is
'All parameters for capture process'
/
comment on column DBA_CAPTURE_PARAMETERS.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_CAPTURE_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_CAPTURE_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column DBA_CAPTURE_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym DBA_CAPTURE_PARAMETERS
  for DBA_CAPTURE_PARAMETERS
/
grant select on DBA_CAPTURE_PARAMETERS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PARAMETERS
  (CAPTURE_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select cp.capture_name, cp.parameter, cp.value, cp.set_by_user
  from dba_capture_parameters cp, all_capture ac
 where cp.capture_name = ac.capture_name
/

comment on table ALL_CAPTURE_PARAMETERS is
'Details about parameters for each capture process that stores the captured changes in a queue visible to the current user'
/
/
comment on column ALL_CAPTURE_PARAMETERS.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_CAPTURE_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column ALL_CAPTURE_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column ALL_CAPTURE_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym ALL_CAPTURE_PARAMETERS
  for ALL_CAPTURE_PARAMETERS
/
grant select on ALL_CAPTURE_PARAMETERS to public with grant option
/

----------------------------------------------------------------------------
-- view to check if a database is prepared for instantiation
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PREPARED_DATABASE
  (TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select s.timestamp,
       decode(v.supplemental_log_data_pk, 'YES',
              decode(bitand(s.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_ui, 'YES',
              decode(bitand(s.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_fk, 'YES',
              decode(bitand(s.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(v.supplemental_log_data_all, 'YES',
              decode(bitand(s.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
 from streams$_prepare_ddl s, v$database v
 where usrid is NULL
   and global_flag = 1
/
comment on table DBA_CAPTURE_PREPARED_DATABASE is
'Is the local database prepared for instantiation?'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.TIMESTAMP is
'Time at which the database was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_PK is
'Status of database-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_UI is
'Status of database-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_FK is
'Status of database-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of database-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_DATABASE
  for DBA_CAPTURE_PREPARED_DATABASE
/
grant select on DBA_CAPTURE_PREPARED_DATABASE to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_DATABASE
  (TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select * from DBA_CAPTURE_PREPARED_DATABASE
/
comment on table ALL_CAPTURE_PREPARED_DATABASE is
'Is the local database prepared for instantiation?'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.TIMESTAMP is
'Time at which the database was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_PK is
'Status of database-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_UI is
'Status of database-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_FK is
'Status of database-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_DATABASE.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of database-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_DATABASE
  for ALL_CAPTURE_PREPARED_DATABASE
/
grant select on ALL_CAPTURE_PREPARED_DATABASE to public with grant option
/

----------------------------------------------------------------------------
-- view to get the schemas prepared for instantiation
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_PREPARED_SCHEMAS
  (SCHEMA_NAME, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select u.name, pd.timestamp,
       decode(bitand(u.spare1, 1), 1,
              decode(bitand(pd.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 2), 2,
              decode(bitand(pd.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 4), 4,
              decode(bitand(pd.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(u.spare1, 8), 8,
              decode(bitand(pd.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
  from streams$_prepare_ddl pd, user$ u
 where u.user# = pd.usrid and global_flag = 0
/
comment on table DBA_CAPTURE_PREPARED_SCHEMAS is
'All schemas at the local database that are prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SCHEMA_NAME is
'Name of schema prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.TIMESTAMP is
'Time at which the schema was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_PK is
'Status of schema-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_UI is
'Status of schema-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_FK is
'Status of schema-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of schema-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_SCHEMAS
  for DBA_CAPTURE_PREPARED_SCHEMAS
/
grant select on DBA_CAPTURE_PREPARED_SCHEMAS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_SCHEMAS
  (SCHEMA_NAME, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI,
   SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL)
as
select s.schema_name, s.timestamp, s.supplemental_log_data_pk,
       s.supplemental_log_data_ui, s.supplemental_log_data_fk,
       s.supplemental_log_data_all
  from dba_capture_prepared_schemas s, all_users u
 where s.schema_name = u.username
/

comment on table ALL_CAPTURE_PREPARED_SCHEMAS is
'All user schemas at the local database that are prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SCHEMA_NAME is
'Name of schema prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.TIMESTAMP is
'Time at which the schema was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_PK is
'Status of schema-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_UI is
'Status of schema-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_FK is
'Status of schema-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_SCHEMAS.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of schema-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_SCHEMAS
  for ALL_CAPTURE_PREPARED_SCHEMAS
/
grant select on ALL_CAPTURE_PREPARED_SCHEMAS to public with grant option
/

----------------------------------------------------------------------------
-- view to get the tables prepared for instantiation
----------------------------------------------------------------------------
-- using obj$ and user$ instead of dba_objects for better performance.
create or replace view DBA_CAPTURE_PREPARED_TABLES
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK,
   SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK,
   SUPPLEMENTAL_LOG_DATA_ALL)
as
select u.name, o.name, co.ignore_scn, co.timestamp,
       decode(bitand(cd.flags, 1), 1,
              decode(bitand(co.flags, 1), 1, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 2), 2,
              decode(bitand(co.flags, 2), 2, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 4), 4,
              decode(bitand(co.flags, 4), 4, 'IMPLICIT', 'EXPLICIT'), 'NO'),
       decode(bitand(cd.flags, 8), 8,
              decode(bitand(co.flags, 8), 8, 'IMPLICIT', 'EXPLICIT'), 'NO')
  from obj$ o, user$ u, streams$_prepare_object co,
       (select obj#, sum(DECODE(type#, 14, 1, 15, 2, 16, 4, 17, 8, 0)) flags
          from sys.cdef$ group by obj#) cd
  where o.obj# = co.obj# and o.owner# = u.user# and co.obj# = cd.obj#(+)
    and co.cap_type = 0 and bitand(o.flags,128) = 0 -- skip recyclebin obj
/
comment on table DBA_CAPTURE_PREPARED_TABLES is
'All tables prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TABLE_OWNER is
'Owner of the table prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TABLE_NAME is
'Name of the table prepared for instantiation'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SCN is
'SCN from which changes can be captured'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_PK is
'Status of table-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_UI is
'Status of table-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_FK is
'Status of table-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column DBA_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of table-level ALL COLUMNS supplemental logging'
/
create or replace public synonym DBA_CAPTURE_PREPARED_TABLES
  for DBA_CAPTURE_PREPARED_TABLES
/
grant select on DBA_CAPTURE_PREPARED_TABLES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_CAPTURE_PREPARED_TABLES
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP, SUPPLEMENTAL_LOG_DATA_PK,
   SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK,
   SUPPLEMENTAL_LOG_DATA_ALL)
as
select pt.table_owner, pt.table_name, pt.scn, pt.timestamp,
       pt.supplemental_log_data_pk, pt.supplemental_log_data_ui,
       pt.supplemental_log_data_fk, pt.supplemental_log_data_all
  from all_tables at, dba_capture_prepared_tables pt
  where pt.table_name = at.table_name
    and pt.table_owner = at.owner
/

comment on table ALL_CAPTURE_PREPARED_TABLES is
'All tables visible to the current user that are prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TABLE_OWNER is
'Owner of the table prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TABLE_NAME is
'Name of the table prepared for instantiation'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SCN is
'SCN from which changes can be captured'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_PK is
'Status of table-level PRIMARY KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_UI is
'Status of table-level UNIQUE INDEX COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_FK is
'Status of table-level FOREIGN KEY COLUMNS supplemental logging'
/
comment on column ALL_CAPTURE_PREPARED_TABLES.SUPPLEMENTAL_LOG_DATA_ALL is
'Status of table-level ALL COLUMNS supplemental logging'
/
create or replace public synonym ALL_CAPTURE_PREPARED_TABLES
  for ALL_CAPTURE_PREPARED_TABLES
/
grant select on ALL_CAPTURE_PREPARED_TABLES to public with grant option
/

----------------------------------------------------------------------------
-- view to get the tables prepared for sync capture instantiation
----------------------------------------------------------------------------
-- using obj$ and user$ instead of dba_objects for better performance.
create or replace view DBA_SYNC_CAPTURE_PREPARED_TABS
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP)
as
select u.name, o.name, co.ignore_scn, co.timestamp
  from obj$ o, user$ u, streams$_prepare_object co
  where o.obj# = co.obj# and o.owner# = u.user#
    and co.cap_type = 1
/
comment on table DBA_SYNC_CAPTURE_PREPARED_TABS is
'All tables prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TABLE_OWNER is
'Owner of the table prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TABLE_NAME is
'Name of the table prepared for synchronous capture instantiation'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.SCN is
'SCN from which changes can be captured'
/
comment on column DBA_SYNC_CAPTURE_PREPARED_TABS.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
create or replace public synonym DBA_SYNC_CAPTURE_PREPARED_TABS
  for DBA_SYNC_CAPTURE_PREPARED_TABS
/
grant select on DBA_SYNC_CAPTURE_PREPARED_TABS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_SYNC_CAPTURE_PREPARED_TABS
  (TABLE_OWNER, TABLE_NAME, SCN, TIMESTAMP)
as
select pt.table_owner, pt.table_name, pt.scn, pt.timestamp
  from all_tables at, dba_sync_capture_prepared_tabs pt
  where pt.table_name = at.table_name
    and pt.table_owner = at.owner
/

comment on table ALL_SYNC_CAPTURE_PREPARED_TABS is
'All tables prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TABLE_OWNER is
'Owner of the table prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TABLE_NAME is
'Name of the table prepared for synchronous capture instantiation'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.SCN is
'SCN from which changes can be captured'
/
comment on column ALL_SYNC_CAPTURE_PREPARED_TABS.TIMESTAMP is
'Time at which the table was ready to be instantiated'
/
create or replace public synonym ALL_SYNC_CAPTURE_PREPARED_TABS
  for ALL_SYNC_CAPTURE_PREPARED_TABS
/
grant select on ALL_SYNC_CAPTURE_PREPARED_TABS to public with grant option
/


----------------------------------------------------------------------------
-- view to get capture process extra attributes
----------------------------------------------------------------------------
create or replace view DBA_CAPTURE_EXTRA_ATTRIBUTES
  (CAPTURE_NAME, ATTRIBUTE_NAME, INCLUDE, ROW_ATTRIBUTE, DDL_ATTRIBUTE)
as
select q.capture_name, a.name, substr(a.include, 1, 3),
       decode(bitand(a.flag, 1), 1, 'YES', 0, 'NO'),
       decode(bitand(a.flag, 2), 2, 'YES', 0, 'NO')
  from sys.streams$_extra_attrs a, sys.streams$_capture_process q
 where a.process# = q.capture#
/
comment on table DBA_CAPTURE_EXTRA_ATTRIBUTES is
'Extra attributes for a capture process'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.capture_name is
'Name of the capture process'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.attribute_name is
'Name of the extra attribute'
/
comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.include is
'YES if the extra attribute is included'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.row_attribute is
'YES if the extra attribute is a row LCR attribute'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.ddl_attribute is
'YES if the extra attribute is a DDL LCR attribute'
/

create or replace public synonym DBA_CAPTURE_EXTRA_ATTRIBUTES
  for DBA_CAPTURE_EXTRA_ATTRIBUTES
/
grant select on DBA_CAPTURE_EXTRA_ATTRIBUTES to select_catalog_role
/

create or replace view ALL_CAPTURE_EXTRA_ATTRIBUTES
as
select e.*
  from dba_capture_extra_attributes e, all_capture c
 where e.capture_name = c.capture_name
/
comment on table ALL_CAPTURE_EXTRA_ATTRIBUTES is
'Extra attributes for a capture process that is visible to the current user'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.capture_name is
'Name of the capture process'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.attribute_name is
'Name of the extra attribute'
/
comment on column ALL_CAPTURE_EXTRA_ATTRIBUTES.include is
'YES if the extra attribute is included'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.row_attribute is
'YES if the extra attribute is a row LCR attribute'
/

comment on column DBA_CAPTURE_EXTRA_ATTRIBUTES.ddl_attribute is
'YES if the extra attribute is a DDL LCR attribute'
/

create or replace public synonym ALL_CAPTURE_EXTRA_ATTRIBUTES
  for ALL_CAPTURE_EXTRA_ATTRIBUTES
/
grant select on ALL_CAPTURE_EXTRA_ATTRIBUTES to public with grant option
/

create or replace view dba_registered_archived_log
  (consumer_name, source_database, thread#,
   sequence#, first_scn, next_scn, first_time, next_time,
   name, modified_time, dictionary_begin,
   dictionary_end, purgeable, resetlogs_change#, reset_timestamp)
as
select cp.capture_name, cp.source_dbname,
       l.thread#, l.sequence#, l.first_change#,
       l.next_change#, l.first_time, l.next_time,
       l.file_name, l.timestamp,
       l.dict_begin, l.dict_end, 
       decode(bitand(l.status, 2), 2, 'YES', 'NO'),
       l.resetlogs_change#, l.reset_timestamp
  from system.logmnr_log$ l, sys.streams$_capture_process cp
  where l.session# = cp.logmnr_sid
/

comment on table DBA_REGISTERED_ARCHIVED_LOG is
'Details about the registered log files'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.CONSUMER_NAME is
'consumer name of the archived logs'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.SOURCE_DATABASE is
'the name of the database which generated the redo logs'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.THREAD# is
'Thread ID of the archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.SEQUENCE# is
'Sequence number of the archived redo log file'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.FIRST_SCN is
'SCN of the current archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NEXT_SCN is
'SCN of the next archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.FIRST_TIME is
'Date of the current archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NEXT_TIME is
'Date of the next archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.NAME is
'Name of the archived redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.MODIFIED_TIME is
'Time when the archived redo log was registered'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.DICTIONARY_BEGIN is
'Indicates whether the beginning of the dictionary build is in this redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.DICTIONARY_END is
'Indicates whether the end of the dictionary build is in this redo log'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.PURGEABLE is
'Indicates whether this redo log can be permanently removed'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.RESETLOGS_CHANGE# is
'Resetlogs change# of the database when the log was written'
/
comment on column DBA_REGISTERED_ARCHIVED_LOG.RESET_TIMESTAMP is
'Resetlogs time of the database when the log was written'
/
create or replace public synonym DBA_REGISTERED_ARCHIVED_LOG for
  DBA_REGISTERED_ARCHIVED_LOG
/
grant select on DBA_REGISTERED_ARCHIVED_LOG to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_CAPTURE
as
select * from gv$streams_capture;
create or replace public synonym GV$STREAMS_CAPTURE for GV_$STREAMS_CAPTURE;
grant select on GV_$STREAMS_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_CAPTURE
as
select * from v$streams_capture;
create or replace public synonym V$STREAMS_CAPTURE for V_$STREAMS_CAPTURE;
grant select on V_$STREAMS_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GOLDENGATE_CAPTURE
as
select * from gv$goldengate_capture;
create or replace public synonym GV$GOLDENGATE_CAPTURE for GV_$GOLDENGATE_CAPTURE;
grant select on GV_$GOLDENGATE_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GOLDENGATE_CAPTURE
as
select * from v$goldengate_capture;
create or replace public synonym V$GOLDENGATE_CAPTURE for V_$GOLDENGATE_CAPTURE;
grant select on V_$GOLDENGATE_CAPTURE to select_catalog_role;

----------------------------------------------------------------------------

create or replace view DBA_SYNC_CAPTURE
  (CAPTURE_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER, 
   CAPTURE_USER)
as
select cp.capture_name, cp.queue_name, cp.queue_owner, cp.ruleset_name,
       cp.ruleset_owner, u.name
 from "_DBA_CAPTURE" cp, sys.user$ u
 where cp.capture_userid = u.user# (+)
   and bitand(cp.flags,512) = 512
/
comment on table DBA_SYNC_CAPTURE is
'Details about the sync capture process'
/
comment on column DBA_SYNC_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column DBA_SYNC_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column DBA_SYNC_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column DBA_SYNC_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column DBA_SYNC_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_SYNC_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
create or replace public synonym DBA_SYNC_CAPTURE for 
    DBA_SYNC_CAPTURE
/
grant select on DBA_SYNC_CAPTURE to select_catalog_role
/

-- View of all sync capture processes
create or replace view ALL_SYNC_CAPTURE
as
select c.*
  from dba_sync_capture c, all_queues q
 where c.queue_name = q.name
   and c.queue_owner = q.owner
   and ((c.rule_set_owner is null and c.rule_set_name is null) or
        ((c.rule_set_owner, c.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
/
comment on table ALL_SYNC_CAPTURE is
'Details about each sync capture process that stores the captured changes in a queue visible to the current user'
/
comment on column ALL_SYNC_CAPTURE.CAPTURE_NAME is
'Name of the capture process'
/
comment on column ALL_SYNC_CAPTURE.QUEUE_NAME is
'Name of queue used for holding captured changes'
/
comment on column ALL_SYNC_CAPTURE.QUEUE_OWNER is
'Owner of the queue used for holding captured changes'
/
comment on column ALL_SYNC_CAPTURE.RULE_SET_NAME is
'Rule set used by capture process for filtering'
/
comment on column ALL_SYNC_CAPTURE.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_SYNC_CAPTURE.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
create or replace public synonym ALL_SYNC_CAPTURE for
    ALL_SYNC_CAPTURE
/   
grant select on ALL_SYNC_CAPTURE to select_catalog_role
/

