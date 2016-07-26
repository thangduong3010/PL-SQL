rem 
rem $Header: dbmsjob.sql 24-jun-2008.20:05:34 rramkiss Exp $ 
rem 
Rem  Copyright (c) 1992, 2000 by Oracle Corporation 
Rem    NAME
Rem      dbmsjob.sql - DBMS JOB queue interface
Rem    DESCRIPTION
Rem      Interface for the job queue
Rem    RETURNS
Rem 
Rem    NOTES
Rem      The job queue
Rem      (1) Runs user-defined routines from background processes
Rem          (or directly in the user's process)
Rem      (2) Runs the jobs at user defined times 
Rem          (or reasonably soon afterwards)
Rem      (3) Runs a given job repeatedly at user defined intervals
Rem          (or just once, then the job deletes itself)
Rem      (4) Runs the jobs in the same environment they were submitted in
Rem          (except with the user's default roles and privileges)
Rem      (5) Reports errors, and does exponential backoff.
Rem      (6) Allows the user to identify and administer these jobs. 
Rem
Rem      DBMS_JOB and DBMS_IJOB are the only interface for manipulating jobs.
Rem      Queries against the catalog should be used for examining jobs.
Rem      The catalog view dba_jobs and dba_jobs_running are in catjobq.sql.
Rem      Out of all these routines, only dbms_job.run and dbms_ijob.run have
Rem        implicit commits.
Rem
Rem      There are no kernel priveleges associated with jobs.  The right
Rem        to execute dbms_job or dbms_ijob takes their place.  dbms_job
Rem        does not allow a user to touch any jobs but their own.
Rem
Rem      (1) See the parameter WHAT in the specification for dbms_job for a
Rem          description of legal jobs.
Rem          The background processes are specified by init.ora parameters,
Rem          job_queue_processes=2   #two background processes
Rem          job_queue_interval=60   #the processes wake up every 60 seconds
Rem          job_queue_keep_connections=TRUE  #sleep, don't disconnect
Rem      (2) See NEXT_DATE in the specification for dbms_job
Rem      (3) See INTERVAL in the specification for dbms_job
Rem      (4) All the parameters that can be set with ALTER SESSION are stored
Rem          when a job is created (or when WHAT is changed), and they are
Rem          restored when the job is run.  See the view dba_jobs.
Rem      (5) When dbms_job.run() or dbms_ijob.run() encounters an error, the
Rem          complete errorstack is dumped to a trace file and an alert file.
Rem          If dbms_ijob.run() was used, the number of jobs that ran with
Rem          errors is reported to the user.
Rem      (6) Jobs are identified by job number.  Jobs can be exported and
Rem          imported again, and the job number will remain the same.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     rramkiss   06/24/08  - bug #7197965 - remove with_grant_option
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     alakshmi   07/31/00  - #1346620: remove reference to pkg var in submit
Rem     rthammai   06/06/00  - add interface is_jobq
Rem     jingliu    06/25/99  - change dbms_job.check_privs to private procedure
Rem     jingliu    06/24/99  - add dbms_job.background_process
Rem     ncramesh   08/04/98 -  change for sqlplus
Rem     nireland   11/11/97 -  Change parameter type in isubmit()
Rem     jingliu    10/21/97 -  Instance affinity for jobs
Rem     jnath      08/16/96 -  bug 380978: dbms_job.submit example needs a ;
Rem     rjenkins   02/17/94 -  adding defaults
Rem     rjenkins   02/07/94 -  many fixes
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     rjenkins   01/26/94 -  fix arguments to BROKEN
Rem     rjenkins   01/13/94 -  adding dbms_ijob.bis
Rem     rjenkins   12/20/93 -  support import/export
Rem     rjenkins   12/20/93 -  Branch_for_patch
Rem     rjenkins   12/17/93 -  Creation

REM  =====================================================
REM  dbms_job: job queue functions for public consumption
REM  =====================================================

CREATE OR REPLACE PACKAGE dbms_job IS

  -- for backward compatibility. Not used anymore.
  any_instance CONSTANT BINARY_INTEGER := 0;

  -- Parameters are:
  --
  -- JOB is the number of the job being executed.
  -- WHAT is the PL/SQL procedure to execute.
  --   The job must always be a single call to a procedure.  The
  --     routine may take any number of hardcoded parameters.  
  --     Special parameter values recognized are:
  --       job:       an in parameter, the number of the current job
  --       next_date: in/out, the date of the next refresh
  --       broken:    in/out, is the job broken.  The IN values is FALSE.
  --   Always remember the trailing semicolon.
  --   Some legal values of WHAT (assuming the routines exist) are
  --     'myproc( ''10-JAN-82'', next_date, broken);'
  --     'scott.emppackage.give_raise( ''JENKINS'', 30000.00);'
  --     'dbms_job.remove( job);'
  -- NEXT_DATE is the date at which the job will next be automatically run,
  --   assuming there are background processes attempting to run it.
  -- INTERVAL is a date function, evaluated immediately before the job starts
  --   executing.  If the job completes successfully, this new date is placed
  --   in NEXT_DATE.  INTERVAL is evaluated by plugging it into the statement
  --     select INTERVAL into next_date from dual;
  --   INTERVAL must evaluate to a time in the future.  Legal intervals include
  --     'sysdate + 7'                    -- execute once a week
  --     'NEXT_DAY(sysdate,''TUESDAY'')'  -- execute once every tuesday
  --     'null'                           -- only execute once
  --   If INTERVAL evaluates to null and a job completes successfully, then
  --   the job is automatically deleted from the queue.

  PROCEDURE isubmit    ( job       IN  BINARY_INTEGER,
                         what      IN  VARCHAR2,
                         next_date IN  DATE,
                         interval  IN  VARCHAR2 DEFAULT 'null',
                         no_parse  IN  BOOLEAN DEFAULT FALSE);
  -- Submit a new job with a given job number.

  PROCEDURE submit    ( job       OUT BINARY_INTEGER,
                        what      IN  VARCHAR2,
                        next_date IN  DATE DEFAULT sysdate,
                        interval  IN  VARCHAR2 DEFAULT 'null',
                        no_parse  IN  BOOLEAN DEFAULT FALSE,

                        -- Bug 1346620: replace pkg vars with constants. 
                        -- Default for instance = dbms_job.any_instance.
			instance  IN  BINARY_INTEGER DEFAULT 0,
			force     IN  BOOLEAN DEFAULT FALSE );
  -- Submit a new job.  Chooses JOB from the sequence sys.jobseq.
  -- instance and force are added for jobq queue affinity
  -- If FORCE is TRUE, then any positive  integer is acceptable as the job 
  -- instance. If FORCE is FALSE, then the specified instance must be running;
  -- otherwise the routine raises an exception.
  -- For example,
  --   variable x number;
  --   execute dbms_job.submit(:x,'pack.proc(''arg1'');',sysdate,'sysdate+1');

  PROCEDURE remove    ( job       IN  BINARY_INTEGER );
  -- Remove an existing job from the job queue.
  -- This currently does not stop a running job.
  --   execute dbms_job.remove(14144);

  PROCEDURE change    ( job       IN  BINARY_INTEGER,
                        what      IN  VARCHAR2,
                        next_date IN  DATE,
                        interval  IN  VARCHAR2,
			instance  IN  BINARY_INTEGER DEFAULT NULL,
			force     IN  BOOLEAN DEFAULT FALSE);
  -- Change any of the the user-settable fields in a job
  -- Parameter instance and force are added for job queue affinity
  -- If what, next_date,or interval is null, leave that value as-is.
  -- instance defaults to NULL indicates instance affinity is not changed.
  -- If FORCE is FALSE, the specified instance (to which the instance number
  -- change) must be running. Otherwise the routine raises an exception.
  -- If FORCE is TRUE, any positive  integer is acceptable as the job instance.
  --   execute dbms_job.change( 14144, null, null, 'sysdate+3');

  PROCEDURE what      ( job       IN  BINARY_INTEGER,
                        what      IN  VARCHAR2 );
  -- Change what an existing job does, and replace its environment

  PROCEDURE next_date ( job       IN  BINARY_INTEGER,
                        next_date IN  DATE     );
  -- Change when an existing job will next execute

  PROCEDURE instance ( job        IN BINARY_INTEGER,
                       instance   IN BINARY_INTEGER,
		       force      IN BOOLEAN DEFAULT FALSE);
  -- Change job instance affinity. FORCE parameter works same as in SUBMIT

  PROCEDURE interval  ( job       IN  BINARY_INTEGER,
                        interval  IN  VARCHAR2 );
  -- Change how often a job executes

  PROCEDURE broken    ( job       IN  BINARY_INTEGER,
                        broken    IN  BOOLEAN,
                        next_date IN  DATE DEFAULT SYSDATE );
  --  Set the broken flag.  Broken jobs are never run.

  PROCEDURE run       ( job       IN  BINARY_INTEGER,
			force     IN  BOOLEAN DEFAULT FALSE);
  --  Run job JOB now.  Run it even if it is broken.
  --  Running the job will recompute next_date, see view user_jobs.
  --    execute dbms_job.run(14144);
  --  Warning: this will reinitialize the current session's packages
  --  FORCE is added for job queue affinity
  --  If FORCE is TRUE, instance affinity is irrelevant for running jobs in
  --  the foreground process. If FORCE is FALSE, the job can be run in the 
  --  foreground only in the specified instance. dbms_job.run will raise an 
  --  exception if FORCE is FALSE and the connected instance is the wrong one.

  PROCEDURE user_export ( job    IN     BINARY_INTEGER,
                          mycall IN OUT VARCHAR2);
  --  Produce the text of a call to recreate the given job

  PROCEDURE user_export ( job     IN     BINARY_INTEGER,
                         mycall   IN OUT VARCHAR2,
			 myinst   IN OUT VARCHAR2);
  -- Procedure is added for altering instance affinity (8.1+) and perserve the 
  -- compatibility
  
  --------------------------------------------------------------
  -- Return boolean value indicating whether execution is in background
  -- process or foreground process
  -- jobq processes are no longer background processes, background_processes
  -- will be removed in 8.3 or later
  -------------------------------------------------------------
  FUNCTION background_process RETURN BOOLEAN;
  FUNCTION is_jobq RETURN BOOLEAN;


END;
/

 
CREATE OR REPLACE PUBLIC SYNONYM dbms_job FOR dbms_job
/
GRANT EXECUTE ON dbms_job TO PUBLIC
/
