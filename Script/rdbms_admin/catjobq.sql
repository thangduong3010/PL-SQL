rem 
rem $Header: catjobq.sql 01-jul-2006.23:37:14 samepate Exp $ 
rem 
Rem Copyright (c) 1992, 2006, Oracle. All rights reserved.  
Rem    NAME
Rem      catjobq.sql - Catalog views for the job queue
Rem    DESCRIPTION
Rem 
Rem    NOTES
Rem     This script must be run while connected as SYS or INTERNAL.
Rem    MODIFIED   (MM/DD/YY)
Rem     samepate   06/07/06  - update jobs view
Rem     desinha    04/29/02  - #2303866: change user => userenv('SCHEMAID')
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     htseng     04/12/01  - eliminate execute twice.
Rem     nlewis     01/15/98 -  remove labels from DBA_JOBS and USER_JOBS
Rem     jingliu    10/21/97 -  Instance affinity for job
Rem     mmonajje   05/21/96 -  Replace interval col name with interval#
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     wmaimone   05/06/94 -  #184921 run as sys/internal
Rem     rjenkins   01/19/94 -  merge changes from branch 1.1.710.1
Rem     rjenkins   12/20/93 -  Branch_for_patch
Rem     rjenkins   12/17/93 -  Creation

remark
remark  FAMILY JOB QUEUE
remark

create or replace view DBA_JOBS_RUNNING as
  select v.SID, v.id2 JOB, j.FAILURES,
    LAST_DATE, substr(to_char(last_date,'HH24:MI:SS'),1,8) LAST_SEC, 
    THIS_DATE, substr(to_char(this_date,'HH24:MI:SS'),1,8) THIS_SEC,
    j.field1 INSTANCE 
  from sys.job$ j, v$lock v 
  where v.type = 'JQ' and j.job (+)= v.id2
/
comment on table DBA_JOBS_RUNNING is
'All jobs in the database which are currently running, join v$lock and job$'
/
comment on column DBA_JOBS_RUNNING.SID is
'Identifier of process which is executing the job.  See v$lock.'
/
comment on column DBA_JOBS_RUNNING.JOB is
'Identifier of job.  This job is currently executing.'
/
comment on column DBA_JOBS_RUNNING.LAST_DATE is
'Date that this job last successfully executed'
/
comment on column DBA_JOBS_RUNNING.LAST_SEC is
'Same as LAST_DATE.  This is when the last successful execution started.'
/
comment on column DBA_JOBS_RUNNING.THIS_DATE is
'Date that this job started executing (usually null if not executing)'
/
comment on column DBA_JOBS_RUNNING.THIS_SEC is
'Same as THIS_DATE.  This is when the last successful execution started.'
/
comment on column DBA_JOBS_RUNNING.FAILURES is
'How many times has this job started and failed since its last success?'
/
comment on column DBA_JOBS_RUNNING.INSTANCE is
'The instance number restricted to run the job'
/
create or replace public synonym DBA_JOBS_RUNNING for DBA_JOBS_RUNNING
/
grant select on DBA_JOBS_RUNNING to select_catalog_role
/

remark  Remember to add comments for all_jobs and user_jobs too
create or replace view DBA_JOBS as
  select JOB, lowner LOG_USER, powner PRIV_USER, cowner SCHEMA_USER,
    LAST_DATE, substr(to_char(last_date,'HH24:MI:SS'),1,8) LAST_SEC, 
    THIS_DATE, substr(to_char(this_date,'HH24:MI:SS'),1,8) THIS_SEC, 
    NEXT_DATE, substr(to_char(next_date,'HH24:MI:SS'),1,8) NEXT_SEC, 
    (total+(sysdate-nvl(this_date,sysdate)))*86400 TOTAL_TIME,
    decode(mod(FLAG,2),1,'Y',0,'N','?') BROKEN,
    INTERVAL# interval, FAILURES, WHAT, 
    nlsenv NLS_ENV, env MISC_ENV, j.field1 INSTANCE
  from sys.job$ j
  where BITAND(j.scheduler_flags, 2) IS NULL OR  
        BITAND(j.scheduler_flags, 2) = 0 /* don't show jobs with drop flag */
/
comment on table DBA_JOBS is
'All jobs in the database'
/
comment on column DBA_JOBS.JOB is
'Identifier of job.  Neither import/export nor repeated executions change it.'
/
comment on column DBA_JOBS.LOG_USER is
'USER who was logged in when the job was submitted'
/
comment on column DBA_JOBS.PRIV_USER is
'USER whose default privileges apply to this job'
/
comment on column DBA_JOBS.SCHEMA_USER is
'select * from bar  means  select * from schema_user.bar ' 
/
comment on column DBA_JOBS.LAST_DATE is
'Date that this job last successfully executed'
/
comment on column DBA_JOBS.LAST_SEC is
'Same as LAST_DATE.  This is when the last successful execution started.'
/
comment on column DBA_JOBS.THIS_DATE is
'Date that this job started executing (usually null if not executing)'
/
comment on column DBA_JOBS.THIS_SEC is
'Same as THIS_DATE.  This is when the last successful execution started.'
/
comment on column DBA_JOBS.TOTAL_TIME is
'Total wallclock time spent by the system on this job, in seconds'
/
comment on column DBA_JOBS.NEXT_DATE is
'Date that this job will next be executed'
/
comment on column DBA_JOBS.NEXT_SEC is
'Same as NEXT_DATE.  The job becomes due for execution at this time.'
/
comment on column DBA_JOBS.BROKEN is
'If Y, no attempt is being made to run this job.  See dbms_jobq.broken(job).'
/
comment on column DBA_JOBS.INTERVAL is
'A date function, evaluated at the start of execution, becomes next NEXT_DATE'
/
comment on column DBA_JOBS.FAILURES is
'How many times has this job started and failed since its last success?'
/
comment on column DBA_JOBS.WHAT is
'Body of the anonymous PL/SQL block that this job executes'
/
comment on column DBA_JOBS.NLS_ENV is
'alter session parameters describing the NLS environment of the job'
/
comment on column DBA_JOBS.MISC_ENV is
'a versioned raw maintained by the kernel, for other session parameters'
/
comment on column DBA_JOBS.INSTANCE is
'Instance number restricted to run the job'
/
create or replace public synonym DBA_JOBS for DBA_JOBS
/
grant select on DBA_JOBS to select_catalog_role
/

create or replace view USER_JOBS
as select j.* from dba_jobs j, sys.user$ u where 
j.priv_user = u.name
and u.user# = USERENV('SCHEMAID')
/
comment on table USER_JOBS is
'All jobs owned by this user'
/
comment on column USER_JOBS.JOB is
'Identifier of job.  Neither import/export nor repeated executions change it.'
/
comment on column USER_JOBS.LOG_USER is
'USER who was logged in when the job was submitted'
/
comment on column USER_JOBS.PRIV_USER is
'USER whose default privileges apply to this job'
/
comment on column USER_JOBS.SCHEMA_USER is
'select * from bar  means  select * from schema_user.bar ' 
/
comment on column USER_JOBS.LAST_DATE is
'Date that this job last successfully executed'
/
comment on column USER_JOBS.LAST_SEC is
'Same as LAST_DATE.  This is when the last successful execution started.'
/
comment on column USER_JOBS.THIS_DATE is
'Date that this job started executing (usually null if not executing)'
/
comment on column USER_JOBS.THIS_SEC is
'Same as THIS_DATE.  This is when the last successful execution started.'
/
comment on column USER_JOBS.TOTAL_TIME is
'Total wallclock time spent by the system on this job, in seconds'
/
comment on column USER_JOBS.NEXT_DATE is
'Date that this job will next be executed'
/
comment on column USER_JOBS.NEXT_SEC is
'Same as NEXT_DATE.  The job becomes due for execution at this time.'
/
comment on column USER_JOBS.BROKEN is
'If Y, no attempt is being made to run this job.  See dbms_jobq.broken(job).'
/
comment on column USER_JOBS.INTERVAL is
'A date function, evaluated at the start of execution, becomes next NEXT_DATE'
/
comment on column USER_JOBS.FAILURES is
'How many times has this job started and failed since its last success?'
/
comment on column USER_JOBS.WHAT is
'Body of the anonymous PL/SQL block that this job executes'
/
comment on column USER_JOBS.NLS_ENV is
'alter session parameters describing the NLS environment of the job'
/
comment on column USER_JOBS.MISC_ENV is
'a versioned raw maintained by the kernel, for other session parameters'
/
comment on column USER_JOBS.INSTANCE is
'Instance number restricted to run the job'
/
create or replace public synonym USER_JOBS for USER_JOBS
/
grant select on USER_JOBS to public with grant option
/
create or replace public synonym ALL_JOBS for USER_JOBS
/
grant select on ALL_JOBS to public with grant option
/
