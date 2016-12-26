Rem
Rem $Header: emll/admin/scripts/ocmjb10.sql /st_emll_10.3.8.1/1 2013/04/19 01:50:56 imunusam Exp $
Rem
Rem ocmjb10.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ocmjb10.sql - OCM db config collection Job package Body for 10g onwards.
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    imunusam    04/17/13 - To fix 16575976
Rem    davili      10/18/12 - Bug 13440604, change MAINTENANCE_WINDOW_GROUP
Rem    jsutton     03/21/12 - fix dir obj inconsistency
Rem    jsutton     01/24/12 - fix problem with no_opp function
Rem    jsutton     10/17/11 - fix syntax problem
Rem    jsutton     09/16/11 - create both dir objects
Rem    ckalivar    11/22/10 - Bug 10198634: submit_job_for_inst will now can
Rem                           take NULL as second job
Rem    fmorshed    10/28/10 - Add create/replace for ebs and gc directory
Rem                           objects.
Rem    jsutton     04/23/10 - RAC instance discovery and collection
Rem    pparida     01/29/10 - 8599172: Use DBMS_ASSERT for 10.2 and above only,
Rem                           otherwise use local implementation of ENQUOTE_LITERAL.
Rem    glavash     08/20/08 - remove assert
Rem    glavash     06/03/08 - XbranchMerge glavash_bug-7011400 from
Rem                           st_emll_10.3.0
Rem    glavash     06/02/08 - wrap l_ocm_dir_path bug 7011400
Rem    dkapoor     01/23/07 - create once a month job to coll stats
Rem    dkapoor     07/26/06 - do not use define 
Rem    dkapoor     07/21/06 - create package to re-create dir object 
Rem    dkapoor     06/13/06 - debug job already present error 
Rem    dkapoor     06/07/06 - run the job once 
Rem    dkapoor     06/02/06 - change ccr_user to ocm 
Rem    dkapoor     05/22/06 - Created
Rem


CREATE OR REPLACE PACKAGE body ORACLE_OCM.MGMT_CONFIG AS

JOB_NAME CONSTANT VARCHAR(40) := 'MGMT_CONFIG_JOB';
STATS_JOB_NAME CONSTANT VARCHAR(40) := 'MGMT_STATS_CONFIG_JOB';

/*
 Checks to see if the job already exists
*/
FUNCTION job_exists (job_name_in VARCHAR) RETURN BOOLEAN IS
  l_job_cnt NUMBER;
BEGIN
   select count(*) into l_job_cnt from 
	dba_scheduler_jobs WHERE job_name = job_name_in and owner ='ORACLE_OCM';
  if l_job_cnt = 0
  THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;
END job_exists;

/*
Submit a job to collect the configuration.
Basically, a job with what->collect_config
*/
procedure submit_job IS
BEGIN
  IF not job_exists(JOB_NAME) THEN  
      sys.dbms_scheduler.create_job(
        job_name => JOB_NAME,
        job_type => 'STORED_PROCEDURE',
        job_action => 'ORACLE_OCM.MGMT_CONFIG.collect_config',
    start_date=> SYSTIMESTAMP,
        repeat_interval => 'freq=daily;byhour=01;byminute=01;bysecond=01',
        end_date => NULL,
        enabled => TRUE,
        auto_drop => FALSE,
        comments => 'Configuration collection job.');
     COMMIT;
  ELSE
      RAISE_APPLICATION_ERROR(-20000,'Cannot resubmit. A job '''|| JOB_NAME 
                       || '''already exists.');
  END IF;
  IF not job_exists(STATS_JOB_NAME) THEN  
      sys.dbms_scheduler.create_job(
        job_name => STATS_JOB_NAME,
        job_type => 'STORED_PROCEDURE',
        job_action => 'ORACLE_OCM.MGMT_CONFIG.collect_stats',
 	start_date=> SYSTIMESTAMP,
        repeat_interval => 'freq=monthly;interval=1;bymonthday=1;byhour=01;byminute=01;bysecond=01',
        end_date => NULL,
        enabled => TRUE,
        auto_drop => FALSE,
        comments => 'OCM Statistics collection job.');
     COMMIT;
  ELSE
      RAISE_APPLICATION_ERROR(-20001,'Cannot resubmit. A job '''|| STATS_JOB_NAME 
                       || '''already exists.');
  END IF;
END submit_job;

/*
Submit a job to collect the configuration.
Basically, a job with what->collect_config_metrics(<collection directory>
*/
procedure submit_job_for_inst(inst_id IN BINARY_INTEGER, p_inst_num IN BINARY_INTEGER,
                              p_job_name IN VARCHAR2,
                              p_job_action IN VARCHAR2, p_job_action2 in VARCHAR2) IS
  l_job NUMBER;
  l_par v$instance.PARALLEL%TYPE;
  l_instNum v$instance.INSTANCE_NUMBER%TYPE;
BEGIN
  BEGIN
    IF not job_exists(p_job_name || '_' || inst_id) THEN  
      sys.dbms_scheduler.create_job(
        job_name => p_job_name || '_' || inst_id,
        job_type => 'PLSQL_BLOCK',
        job_action => p_job_action ,
        start_date => NULL,
        repeat_interval => NULL,
        enabled => FALSE,
        auto_drop => TRUE,
        comments => 'OCM collection job run for an instance.');
      BEGIN
        -- Use the instance_id attribute.
        -- This may throw exception if not implemented in the version of
        -- the database. We would be ignoring the exception it that case.
        DBMS_SCHEDULER.SET_ATTRIBUTE (p_job_name || '_' || inst_id,'instance_id',inst_id);
        EXCEPTION
          WHEN OTHERS THEN NULL;
      END;
      DBMS_SCHEDULER.ENABLE (p_job_name || '_' || inst_id);
      -- Run the job synchronously
      -- DBMS_SCHEDULER.RUN_JOB(p_job_name || '_' || inst_id,FALSE);
      COMMIT;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
      -- Don't raise an exception otherwise it fills the alert/trace
      DBMS_OUTPUT.put_line('Do not raise an exception');
       -- RAISE_APPLICATION_ERROR(-20000,'SQLERRM: ' || SQLERRM || ' SQLCODE: '|| SQLCODE);
  END;

  -- create 2nd job if specified
  IF p_job_action2 is NOT NULL THEN
    select PARALLEL into l_par  from v$instance;
    IF l_par = 'YES' THEN
      select instance_number into l_instNum from v$instance;
      IF l_instNum <> p_inst_num THEN
      BEGIN
        IF not job_exists(p_job_name || '_2_' || inst_id) THEN  
          sys.dbms_scheduler.create_job(
            job_name => p_job_name || '_2_' || inst_id,
            job_type => 'PLSQL_BLOCK',
            job_action => p_job_action2 ,
            start_date => NULL,
            repeat_interval => NULL,
            enabled => FALSE,
            auto_drop => TRUE,
            comments => 'OCM 2nd job run for RAC instance.');
          BEGIN
            -- Use the instance_id attribute.
            -- This may throw exception if not implemented in the version of
            -- the database. We would be ignoring the exception it that case.
            DBMS_SCHEDULER.SET_ATTRIBUTE (p_job_name || '_2_' || inst_id,'instance_id',inst_id);
            EXCEPTION
              WHEN OTHERS THEN NULL;
          END;
          DBMS_SCHEDULER.ENABLE (p_job_name || '_2_' || inst_id);
          COMMIT;
        END IF;
        EXCEPTION
          WHEN OTHERS THEN
          -- Don't raise an exception otherwise it fills the alert/trace
          DBMS_OUTPUT.put_line('Do not raise an exception');
      END;
      END IF;
    END IF;
  END IF;
END submit_job_for_inst ;

/*
Runs the configuration collection job now.
*/
procedure run_now IS
BEGIN
   	DBMS_SCHEDULER.RUN_JOB(JOB_NAME);
   	DBMS_SCHEDULER.RUN_JOB(STATS_JOB_NAME);
  	COMMIT;
END run_now;

/*
Print the job details.
*/
procedure print_job_details IS
BEGIN
        dbms_output.put_line('Configuration collection job name: ' || JOB_NAME);
        dbms_output.put_line('Statistics collection job name: ' || STATS_JOB_NAME);
        dbms_output.put_line('Job Schedule: DAILY');
END print_job_details;

/*
Stop the job.
*/
procedure stop_job IS
BEGIN
    DBMS_SCHEDULER.DROP_JOB (JOB_NAME);
    DBMS_SCHEDULER.DROP_JOB (STATS_JOB_NAME);
    COMMIT;
END stop_job;

/*
Config collection job
*/
procedure collect_config IS
  CURSOR l_res_cur IS select inst_id,instance_number from gv$instance;
BEGIN
	FOR inst_id_row in l_res_cur LOOP
		submit_job_for_inst(inst_id_row.inst_id, inst_id_row.instance_number, JOB_NAME,
                 'BEGIN ORACLE_OCM.MGMT_DB_LL_METRICS.COLLECT_CONFIG_METRICS(''ORACLE_OCM_CONFIG_DIR''); END;',
                 'BEGIN ORACLE_OCM.MGMT_DB_LL_METRICS.WRITE_DB_CCR_FILE(''ORACLE_OCM_CONFIG_DIR2'', TRUE); END;');
	END LOOP;
END collect_config;

/*
Statistics collection job
*/
procedure collect_stats IS
  CURSOR l_res_cur IS select inst_id, instance_number from gv$instance;
BEGIN
	FOR inst_id_row in l_res_cur LOOP
		submit_job_for_inst(inst_id_row.inst_id, inst_id_row.instance_number, STATS_JOB_NAME,
                'BEGIN ORACLE_OCM.MGMT_DB_LL_METRICS.collect_stats_metrics(''ORACLE_OCM_CONFIG_DIR''); END;',
                 NULL);
	END LOOP;
END collect_stats;

END MGMT_CONFIG;
/
show errors;
 
/*
     This package is executed with invoker's rights. This is needed so that
     ORACLE_OCM user does not need to be granted "execute" permission on "dbms_system" package.
*/
CREATE OR REPLACE PACKAGE body ORACLE_OCM.MGMT_CONFIG_UTL AS

PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;
PLATFORM_OPENVMS      CONSTANT BINARY_INTEGER := 15;


-- ###############################################
-- The two local functions ENQUOTE_INTERNAL and
-- ENQUOTE_LITERAL below are copied from 
-- rdbms/src/server/dict/sqlddl/prvtasrt.sql
-- label RDBMS_10.2.0.5.0_LINUX_100201
-- as a local implementation.
-- ###############################################

  --
  -- Enquote a string using a given quote character
  --
  function ENQUOTE_INTERNAL(Str varchar2, Quote varchar2)
           return varchar2 is
    already_quoted boolean := substr(Str, 1, 1) = Quote;
    len            binary_integer := length(Str);
    pos            binary_integer;
  begin
    -- debug
    -- dbms_output.put_line('Str: ' || Str);
    -- dbms_output.put_line('Quote: ' || Quote);

    if (already_quoted) then
      pos := 2;
      -- if the last character of this string which is supposedly already
      -- quoted is NOT the quote character, the string is clearly not
      -- quoted. Raise value error 
      if (substr(Str, len, 1) <> Quote) then
        raise value_error;
      end if;
      -- we change the number of characters we need to examine to one
      -- less since we should not need to examine the last character.
      -- See the comment on raising an error when 
      -- pos = len and already_quoted 
      len := len - 1;
    else
      pos := 1;
    end if;
    while (pos <= len) loop
      -- debug 
      --  dbms_output.put_line('pos: ' || pos || ' len: ' || len || 
      --                       ' Char: ' || substr(Str, pos, 1));
      if (substr(Str, pos, 1) = Quote) then
        -- if the current character is a quote then we have
        --   to check a couple of things 

        if ((pos < len) AND (substr(Str, pos + 1, 1) = Quote)) then
          pos := pos + 1;
        else
          raise value_error;
        end if;
      end if;
      pos := pos + 1;
    end loop;
    if (already_quoted) then
      return Str;
    else
      return Quote || Str || Quote;
    end if;
  end ENQUOTE_INTERNAL;


  --
  -- ENQUOTE_LITERAL
  --
  -- Enquote a string literal.  Add leading and trailing single quotes
  -- to a string literal.  Verify that all single quotes except leading
  -- and trailing characters are paired with adjacent single quotes.
  --
  function ENQUOTE_LITERAL(Str varchar2)
           return varchar2 is
  begin
    return ENQUOTE_INTERNAL(Str, '''');
  end ENQUOTE_LITERAL;

/*
   Dummy funtion for fix Bug 12380852
*/
FUNCTION no_opp(l_ocm_dir_path IN  VARCHAR) RETURN VARCHAR IS
BEGIN
   return l_ocm_dir_path;
END no_opp;

/*
Create or replace the directory object to recreate the path based on 
new ORACLE_HOME.
Note: 
  1. This procedure is executed with invoker's rights. This is needed so that
     ORACLE_OCM user does not need to be granted "execute" permission on "dbms_system" package.
     Only SYS would be able to run this procedure without error as it has the privilege to execute "dbms_system" and re-create
     the directory object ORACLE_OCM_CONFIG_DIR owned by it.
  2. This procedure is only supported on release 10g onwards.
     DBMS_SYSTEM.GET_ENV is supported 10g onwards.
     DBMS_ASSERT.ENQUOTE_LITERAL is used if the DB version is 10gR2 onwards.
*/
procedure create_replace_dir_obj IS
    -- local variables
  pfid            NUMBER;
  root            VARCHAR2(2000);
  hname           VARCHAR2(2000);
  l_ocm_dir_path  VARCHAR2(4000);
  l_ocm_dir_path2 VARCHAR2(4000);
  l_dirsep        VARCHAR2(2);
  l_vers          v$instance.version%TYPE;
BEGIN
    -- get the platform id
    SELECT platform_id INTO pfid FROM v$database;

    IF pfid = PLATFORM_OPENVMS THEN
      -- ORA_ROOT is a VMS logical name
      l_ocm_dir_path  := 'ORA_ROOT:[ccr.state]';
      l_ocm_dir_path2 := 'ORA_ROOT:[ccr.state]';
    ELSE
      -- Get ORACLE_HOME
      execute immediate 'BEGIN DBMS_SYSTEM.GET_ENV(''ORACLE_HOME'', :1); END;' using out root;
      -- Get HOSTNAME
      execute immediate 'BEGIN DBMS_SYSTEM.GET_ENV(''HOSTNAME'', :1); END;' using out hname;
      -- Return platform-specific string
      IF pfid = PLATFORM_WINDOWS32 OR pfid = PLATFORM_WINDOWS64
      THEN
        l_dirsep := '\'; --'
      ELSE
        l_dirsep := '/';
      END IF;

      IF HNAME IS NULL THEN
         l_ocm_dir_path := root || l_dirsep|| 'ccr' || l_dirsep || 'state';
      ELSE
         l_ocm_dir_path := root || l_dirsep|| 'ccr' || l_dirsep || 'hosts' || l_dirsep || hname || l_dirsep || 'state';
      END IF;
      l_ocm_dir_path2:= root || l_dirsep|| 'ccr' || l_dirsep || 'state';

    END IF;
    select LPAD(version,10,'0') into l_vers from v$instance;
    IF l_vers < '10.2.0.0.0' THEN
        l_ocm_dir_path := ENQUOTE_LITERAL(l_ocm_dir_path);
        l_ocm_dir_path2 := ENQUOTE_LITERAL(l_ocm_dir_path2);
    ELSE
        execute immediate 'SELECT DBMS_ASSERT.ENQUOTE_LITERAL(:1) FROM DUAL' into l_ocm_dir_path using l_ocm_dir_path;
        execute immediate 'SELECT DBMS_ASSERT.ENQUOTE_LITERAL(:1) FROM DUAL' into l_ocm_dir_path2 using l_ocm_dir_path2;
    END IF;
    execute immediate 'CREATE OR REPLACE DIRECTORY ORACLE_OCM_CONFIG_DIR AS ' || no_opp(l_ocm_dir_path); 
    execute immediate 'CREATE OR REPLACE DIRECTORY ORACLE_OCM_CONFIG_DIR2 AS ' || no_opp(l_ocm_dir_path2); 
    COMMIT;
END create_replace_dir_obj;

END MGMT_CONFIG_UTL;
/
show errors;
 
