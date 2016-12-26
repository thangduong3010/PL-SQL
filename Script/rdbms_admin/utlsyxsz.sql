set echo off
Rem
Rem $Header: rdbms/admin/utlsyxsz.sql /main/4 2009/10/26 11:31:29 mfallen Exp $
Rem
Rem utlsyxsz.sql
Rem
Rem Copyright (c) 2003, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlsyxsz.sql - Utility script for SYSAUX Size
Rem
Rem    DESCRIPTION
Rem      This script will estimate the amount of space required for the 
Rem      SYSAUX tablespace.  We will estimate based on the number
Rem      of active sessions, files, tables, indexes, etc.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      02/03/04 - add underscore dbid 
Rem    mlfeng      01/16/04 - create/drop package
Rem    mlfeng      12/19/03 - mlfeng_space_estimate 
Rem    schakkap    12/17/03 - tweak coefficients of optimizer stats estimate
Rem    mziauddi    12/11/03 - Revise queries to get correct tab/ind/col counts
Rem    mlfeng      12/07/03 - estimate AWR, Optimizer Stats
Rem    mlfeng      12/04/03 - Created
Rem

set echo off verify off termout on heading off
set linesize 80 trimspool on tab off pagesize 100

set feedback off

-- initialize dbms_output 
set serveroutput on;
exec dbms_output.enable(1000000);

alter session set nls_date_format = 'HH24:MI:SS (MM/DD)';
alter session set nls_timestamp_format = 'HH24:MI:SS (MM/DD)';

-- variables for estimated size ---
variable total_space_est    NUMBER;
variable awr_space_est      NUMBER;
variable optstats_space_est NUMBER;
variable other_space_est    NUMBER;
-----------------------------------

variable awr_size     number;
variable opt_size     number;
variable oth_occ_size number;
variable oth_size     number;

-- alignment variables
variable align           number;
variable mb_format       varchar2(20);
variable kb_format       varchar2(20);
variable perc_format     varchar2(20);
variable banner          number;

variable estimated_others varchar2(2000);

variable dbid  number;

begin
  select dbid into :dbid from v$database;
  :align     := 37;
  :banner    := 51;
  :mb_format := '99,999,990.0';
  :kb_format := '999,999,990';
  :perc_format := '990.0';
end;
/
  
---------------------------------------------------------------
-- Prompt the User for the report file name (specify default),
-- then begin spooling
---------------------------------------------------------------
set termout off;
column dflt_name new_value dflt_name noprint;
select 'utlsyxsz.txt' dflt_name from dual;
set termout on;

prompt
prompt
prompt This script estimates the space required for the SYSAUX tablespace.  
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Specify the Report File Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name,
prompt press <return> to continue, otherwise enter an alternative.
prompt

column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , nvl('&&report_name','&dflt_name') report_name
  from sys.dual;


/**********************************************************
 * Create the package for the routines used in this script 
 **********************************************************/
create or replace package UTLSYXSZ_UTIL as

  ---------------------------------------------------
  -- show_default
  --   This routine will display the default value
  --   for a variable.
  ---------------------------------------------------
  procedure show_default
   (name  IN VARCHAR2, 
    value IN NUMBER, 
    unit  IN VARCHAR2 DEFAULT NULL,
    list  IN VARCHAR2 DEFAULT NULL);  

  ---------------------------------------------------
  -- show_default2
  --   Second routine for displaying the default value
  --   for a variable.
  ---------------------------------------------------
  procedure show_default2
     (name  IN VARCHAR2, 
      value IN varchar2,
      list  IN VARCHAR2 DEFAULT NULL);

  ---------------------------------------------------
  -- awr_set_variables 
  --   This routine will return the number of active
  --   sessions, files, interval, retention, and
  --   number of instances currently in the system.
  ---------------------------------------------------
  procedure awr_set_variables
    (active_sessions OUT NUMBER,
     files           OUT NUMBER,
     interval        OUT NUMBER,
     retention       OUT NUMBER,
     num_inst        OUT NUMBER);

  -----------------------------------------------------
  -- awr_space_estimate -
  --   This routine will return in the estimated usage 
  --   for the AWR in megabytes (MB).
  -----------------------------------------------------
  function awr_space_estimate 
    (active_sessions IN NUMBER,
     files           IN NUMBER,
     interval        IN NUMBER,
     retention       IN NUMBER,
     num_inst        IN NUMBER,
     cur_awr_size    IN NUMBER)
   return NUMBER;

  ---------------------------------------------------
  -- awr_display_variables 
  --   This routine will display the number of active
  --   sessions, files, interval, retention, and
  --   number of instances used for estimation
  ---------------------------------------------------
  procedure awr_display_variables
    (active_sessions IN NUMBER,
     files           IN NUMBER,
     interval        IN NUMBER,
     retention       IN NUMBER,
     num_inst        IN NUMBER,
     awr_est         IN NUMBER);

  ----------------------------------------------------------
  -- optstats_get_vars 
  --   This routine will return the number of system and user
  --   tables, indexes, and column currently in the system.
  --   It also returns the statistics retention peroid.
  -----------------------------------------------------------
  PROCEDURE optstats_get_vars
   (num_sys_tabs       OUT NUMBER,
    num_user_tabs      OUT NUMBER,
    num_sys_parts      OUT NUMBER,
    num_user_parts     OUT NUMBER,
    num_sys_inds       OUT NUMBER,
    num_user_inds      OUT NUMBER,
    num_sys_part_inds  OUT NUMBER,
    num_user_part_inds OUT NUMBER,
    num_sys_cols       OUT NUMBER,
    num_user_cols      OUT NUMBER,
    num_sys_part_cols  OUT NUMBER,
    num_user_part_cols OUT NUMBER,
    stats_retention    OUT NUMBER);

  -----------------------------------------------------
  -- optstats_space_est -
  --   This routine will return the estimated usage 
  --   for Optimizer Stats versions in megabytes (MB).
  -----------------------------------------------------
  function optstats_space_est
   (num_sys_tabs        IN NUMBER,
    num_user_tabs       IN NUMBER,
    num_sys_parts       IN NUMBER,
    num_user_parts      IN NUMBER,
    num_sys_inds        IN NUMBER,
    num_user_inds       IN NUMBER,
    num_sys_part_inds   IN NUMBER,
    num_user_part_inds  IN NUMBER,
    num_sys_cols        IN NUMBER,
    num_user_cols       IN NUMBER,
    num_sys_part_cols   IN NUMBER,
    num_user_part_cols  IN NUMBER,
    pct_volatile        IN NUMBER,
    pct_skewed_cols     IN NUMBER,
    pct_cand_parts      IN NUMBER,
    days_to_stale       IN NUMBER,
    days_to_stale_low   IN NUMBER,
    stats_retention     IN NUMBER)
   return NUMBER;

  -----------------------------------------------------
  -- optstats_display_vars 
  --   This routine will display the optstats variables
  -----------------------------------------------------
  procedure optstats_display_vars
    (num_user_tabs       IN NUMBER,
     num_user_parts      IN NUMBER,
     num_user_inds       IN NUMBER,
     num_user_part_inds  IN NUMBER,
     num_user_cols       IN NUMBER,
     num_user_part_cols  IN NUMBER,
     stats_retention     IN NUMBER,
     dml_activity        IN NUMBER,
     optstats_est        IN NUMBER);


end UTLSYXSZ_UTIL;
/

-- Create package body
create or replace package body UTLSYXSZ_UTIL as

---------------------------------------------------
-- show_default
--   This routine will display the default value
--   for a variable.
---------------------------------------------------
procedure show_default
   (name  IN VARCHAR2, 
    value IN NUMBER, 
    unit  IN VARCHAR2 DEFAULT NULL,
    list  IN VARCHAR2 DEFAULT NULL)
as
  format VARCHAR2(20); 
  format1 VARCHAR2(20) := '90.99';
  format2 VARCHAR2(20) := '9,999.9';
  format3 VARCHAR2(20) := '999,999,990';
begin
  if (value < 10) then
    format := format1;
  elsif (value < 10000) then
    format := format2;
  else
    format := format3;
  end if;

  dbms_output.put_line('| ');
  dbms_output.put_line('| For ''' || name || ''', ');
  dbms_output.put_line('|   Press <return> to use the current value: ' ||
                       to_char(value, format) || ' ' || unit);
  dbms_output.put_line('|   otherwise enter an alternative ' || list);
  dbms_output.put_line('| ');
end show_default;


---------------------------------------------------
-- show_default2
--   Second routine for displaying the default value
--   for a variable.
---------------------------------------------------
procedure show_default2
   (name  IN VARCHAR2, 
    value IN varchar2,
    list  IN VARCHAR2 DEFAULT NULL)
as
  format VARCHAR2(20) := '999,990';
  pval   VARCHAR2(6);
begin
   IF (VALUE = 1) THEN pval := 'low';
   ELSE IF (VALUE = 2) THEN pval := 'medium';
   ELSE pval := 'high';
   END IF;
   END IF;
   
  dbms_output.put_line('| ');
  dbms_output.put_line('| For ''' || name || ''',');
  dbms_output.put_line('|   Press <return> to use the current value: ' ||
                       to_char(value, format) || ' <' || pval || '>');
  dbms_output.put_line('|   otherwise enter an alternative ' || list);
  dbms_output.put_line('| ');
end show_default2;



---------------------------------------------------
-- awr_set_variables 
--   This routine will return the number of active
--   sessions, files, interval, retention, and
--   number of instances currently in the system.
---------------------------------------------------
procedure awr_set_variables
   (active_sessions OUT NUMBER,
    files           OUT NUMBER,
    interval        OUT NUMBER,
    retention       OUT NUMBER,
    num_inst        OUT NUMBER)
as
  cpu_count     number;
  num_sess_cpu  number;
  num_cpus      number;
  cur_cpus      number;
  cpu_quota     number;
  step_size     number;
  step_decr     number;

  ash_hist      number;      /* amount of ash history (days) to look in past */
  ash_hist_snap number;                           /* snap_id for ash history */
  hist_size     number;           /* Actual num days of ASH history obtained */
  avg_active    number;       /* Avg active sess across all instances in RAC */
  weighted_avg  number;                                  /* weighted average */

  l_dbid        number;
  debug_on      boolean := FALSE;                      /* display debug info */

  zero_interval  number := 3468960000;                      /* zero interval */
  zero_retention number := 3468960000;                     /* zero retention */
  df_ratio       number := 10;         /* ASH disk filter ratio - default 10 */

begin
  /* database id */
  l_dbid := dbms_swrf_internal.get_awr_dbid;

  /* number of files */
  select count(*) into files 
    from sys.file$ 
    where status$ = 2;

  /* retention and interval setting */
  select snapint_num, retention_num 
     into interval, retention 
     from sys.wrm$_wr_control
     where dbid = l_dbid;

  /* special case for interval = 0 and retention = 0 */
  if (interval = zero_interval) then
    interval := 0;
  end if;

  if (retention = zero_retention) then
    retention := 0;
  end if;

  /* number of instances */
  select count(*) 
    into num_inst
    from gv$instance;

  /*--------------------------------------------*
   * Compute average number of active sessions.
   *--------------------------------------------*/
  -- Define how much of ASH data you want to look at in the past (in days)
  ash_hist := 2 + (interval / 86400);

  -- Find the closest snap_id - to perform indexed access on WRH$_ASH
  -- Can't just look at end_interval_time, but should rather go 
  -- as far as possible until sum(end_interval_time - begin_interval_time)
  -- is close to 'ash_hist' number of days.

  select nvl(min(snap_id), 4294967296), nvl(max(past_in_days), 0)
  into   ash_hist_snap, hist_size
  from   (select snap_id, 
                 sum( cast(min(end_interval_time) as date) 
                      - cast(min(begin_interval_time) as date) ) 
                   over (order by snap_id desc rows unbounded preceding)
                 as past_in_days
          from   sys.wrm$_snapshot s
          where  dbid = l_dbid
          group  by snap_id)
  where  past_in_days <= ash_hist;

  -- Query the average number of active session history 
  -- Multiply numberator by 10 - as we flush only one out of 10 samples.
  select nvl(decode(hist_size, 0, 0,
                    sum(cnt)*df_ratio/(hist_size * 86400)), 0)
  into   avg_active
  from   (select sample_id, count(*) as cnt
          from   sys.wrh$_active_session_history
          where  dbid = l_dbid
            and  snap_id >= ash_hist_snap
          group  by instance_number, sample_id);

  -- get NUM_CPUS from V$OSSTAT, guaranteed to be supported on all platforms
  select value into num_cpus 
  from   v$osstat
  where  stat_name = 'NUM_CPUS';

  /* store the cpu count */
  cpu_count := num_cpus;
  
  /* calculate active sessions using cpu count */
  cpu_quota := 6;
  step_size := 8;
  step_decr := 1;

  if (num_cpus >= (cpu_quota*step_size)) then
    -- Just an sum of an non-trivial arithmetic progression
    num_sess_cpu := (step_size*cpu_quota*(cpu_quota+step_decr)/2/step_decr);
  
  else
    num_sess_cpu  := 0;

    -- Use a step function that gives less and less weightage 
    -- as num_cpus goes higher and higher.
    -- Give 'cpu_quota' sessions/CPU for first 'step_size' CPUs, 
    --      'cpu_quota-1' sessions/CPU for next 'step_size', and so on ...
    while (num_cpus > 0) loop
      cur_cpus := least( num_cpus, step_size );
      num_sess_cpu := num_sess_cpu + cur_cpus * cpu_quota;

      cpu_quota := cpu_quota - step_decr;
      num_cpus  := num_cpus - cur_cpus;
    end loop;
  end if;                                             /* else (num_cpus ...) */

  -------------------------
  -- Debugging Information
  if (debug_on) then
    dbms_output.put_line('Debug Info:');
    dbms_output.put_line('Hist Snap: ' || ash_hist_snap );
    dbms_output.put_line('Hist Size: ' || round(hist_size, 6));
    dbms_output.put_line('Avg Active: ' || round(avg_active, 6));
    dbms_output.put_line('Num CPUs: ' || round(cpu_count, 2));
    dbms_output.put_line('Num Sess CPU: ' || round(num_sess_cpu, 2));
  end if;
  -------------------------

  -- check how much data we have from the WRH$_ASH table.
  -- Depending on the amount of data we have, we will use a mixture
  -- of the observed value and the estimate based on number of cpus.

  if (hist_size >= 1.9) then
    -- we have about 2 days of data, use the observed value 
    active_sessions := avg_active;
    
  elsif (hist_size >= 1.0) then
    -- we have 1-2 days of data, use the observed value with 20% 
    -- factor on the cpu estimate
    active_sessions := (0.80 * avg_active) + (0.20 * num_sess_cpu);

  elsif (hist_size >= 0.5) then
    -- we have 0.5-1 day of data, use the observed value with 50%
    -- factor the cpu estimate
    active_sessions := (0.50 * avg_active) + (0.50 * num_sess_cpu);

  else
    -- if we do not have enough history, simply use the average 
    -- number of active sessions derived from cpu count 
    active_sessions := num_sess_cpu; 

  end if;                                         /* else if (hist_size ...) */

  if (debug_on) then
    dbms_output.put_line('Active Sessions: ' || round(active_sessions, 2));
  end if;

end awr_set_variables;


-----------------------------------------------------
-- awr_space_estimate -
--   This routine will return in the estimated usage 
--   for the AWR in megabytes (MB).
-----------------------------------------------------
function awr_space_estimate 
   (active_sessions IN NUMBER,
    files           IN NUMBER,
    interval        IN NUMBER,
    retention       IN NUMBER,
    num_inst        IN NUMBER,
    cur_awr_size    IN NUMBER)
 return NUMBER
as
  default_interval  CONSTANT NUMBER := 3600;
  default_retention CONSTANT NUMBER := 604800;

  space_estimate    NUMBER; 

begin

  /* handle the special case of interval = 0 or retention = 0 */
  if (interval = 0) then
    /* in this case, no snapshots are taken, return the current size */
    return cur_awr_size;

  elsif (retention = 0) then 
    /* in this case, snapshots are retained forever, need infinite 
     * amount of space */
    return -1;
  end if;
  
  /* verify that we have valid inputs */
  if (active_sessions < 0) then
    raise_application_error(-20500, 'Invalid value for active sessions: ' || 
                                    active_sessions);
  elsif (files < 0) then
    raise_application_error(-20501, 'Invalid value for datafiles: ' || files);

  elsif (num_inst <= 0) then
    raise_application_error(-20502, 'Invalid value for number of instances: ' 
                            || num_inst);

  elsif (interval < 0) then
    raise_application_error(-20503, 'Invalid value for interval: ' ||
                            interval || ' seconds');

  elsif (retention < 0) then
    raise_application_error(-20504, 'Invalid value for retention: ' ||
                            retention || ' seconds');
  end if;

  /* the formula for AWR usage for the default interval and
   * retention setting for one instance is the following:
   *   est_space = 80 MB + 
   *               (33 KB * number of files) +
   *               (15 MB * number of active sessions)
   * 
   * The 80 MB includes the following components of AWR: FIXED, 
   * EVENTS, SPACE, SQLBIND, SQL, SQLPLAN, SQLTEXT.
   * Since number of events, number of segments, and number of
   * SQL should be relatively constant across all databases,
   * we lump all of these components into one number.
   *
   * For each file, we take up about 33KB per week given the
   * default 1 hour interval.
   *
   * The amount of space for the fixed and file components will
   * be inversely proportional to the interval size.
   *
   * The active session component is independent of interval
   * since we always capture the same amount of ASH data
   * for a given period of time.
   *
   * The amount of space is directly proportional to the retention 
   * and number of instances.
   */
  space_estimate := (((80 + (33 / 1024 * files)) * 
                      (default_interval / interval)) + 
                     (15 * active_sessions)) *
                    (retention / default_retention) * num_inst;

  return space_estimate;

end awr_space_estimate;


---------------------------------------------------
-- awr_display_variables 
--   This routine will display the number of active
--   sessions, files, interval, retention, and
--   number of instances used for estimation
---------------------------------------------------
procedure awr_display_variables
   (active_sessions IN NUMBER,
    files           IN NUMBER,
    interval        IN NUMBER,
    retention       IN NUMBER,
    num_inst        IN NUMBER,
    awr_est         IN NUMBER)
as 
  align           number       := 37;
  salign          number       := 19;
  banner          number       := 51;
  mb_format       varchar2(20) := '99,999,990.0';
  num_format      varchar2(20) := '9,999,990';
  frac_format     varchar2(20) := '99,990.99';
begin

  /* check if the estimate is infinity */
  if (awr_est = -1) then
    dbms_output.put_line('| ' || rpad('#', banner, '#'));
    dbms_output.put_line('| Estimated size of AWR is Infinity!');
    dbms_output.put_line('| ' || rpad('#', banner, '#'));

  else
    /* display estimated size of AWR */
    dbms_output.put_line(rpad('| Estimated size of AWR: ', align)
                         || to_char(awr_est, mb_format) || ' MB ');

    if (num_inst > 1) then
      dbms_output.put_line(rpad('| Estimated size of AWR per instance: ',align)
                           || to_char(awr_est / num_inst, mb_format) 
                           || ' MB ');
    end if;

  end if;

  dbms_output.put_line('| ');
  dbms_output.put_line('|   The AWR estimate was computed using ');
  dbms_output.put_line('|   the following values: ');
  dbms_output.put_line('|   ');
  dbms_output.put_line('|   ' 
                       || lpad('Interval -', salign) 
                       || to_char(interval / 60, num_format) 
                       || ' minutes');
  dbms_output.put_line('|   ' 
                       || lpad('Retention -', salign) 
                       || to_char((retention / 86400), frac_format) 
                       || ' days');
  dbms_output.put_line('|   ' 
                       || lpad('Num Instances -', salign) 
                       || to_char(num_inst, num_format)); 
  dbms_output.put_line('|   ' 
                       || lpad('Active Sessions -', salign) 
                       || to_char(active_sessions, frac_format)); 
  dbms_output.put_line('|   ' 
                       || lpad('Datafiles -', salign) 
                       || to_char(files, num_format));
end awr_display_variables;


----------------------------------------------------------
-- optstats_get_vars 
--   This routine will return the number of system and user
--   tables, indexes, and column currently in the system.
--   It also returns the statistics retention peroid.
-----------------------------------------------------------
PROCEDURE optstats_get_vars
  (num_sys_tabs       OUT NUMBER,
   num_user_tabs      OUT NUMBER,
   num_sys_parts      OUT NUMBER,
   num_user_parts     OUT NUMBER,
   num_sys_inds       OUT NUMBER,
   num_user_inds      OUT NUMBER,
   num_sys_part_inds  OUT NUMBER,
   num_user_part_inds OUT NUMBER,
   num_sys_cols       OUT NUMBER,
   num_user_cols      OUT NUMBER,
   num_sys_part_cols  OUT NUMBER,
   num_user_part_cols OUT NUMBER,
   stats_retention    OUT NUMBER)
AS
  num_tabs         NUMBER;
  num_rsys_tabs    NUMBER;
  num_nsys_tabs    NUMBER;
  num_parts        NUMBER;
  num_rsys_parts   NUMBER;
  num_nsys_parts   NUMBER;
  num_hsub_parts   NUMBER;
  num_inds         NUMBER;
  num_rsys_inds    NUMBER;
  num_nsys_inds    NUMBER;
  num_part_inds    NUMBER;
  num_hsp_inds     NUMBER;
  num_cols         NUMBER;
  num_rsys_cols    NUMBER;
  num_nsys_cols    NUMBER;
  num_part_cols    NUMBER;
  num_subp_cols    NUMBER;
  num_hsp_cols     NUMBER;
BEGIN

   -- count all base tables in the database.
   SELECT count(*) INTO num_tabs
   FROM sys.obj$ o
     WHERE o.type# = 2 AND                           -- base tables
           bitand(o.flags, 128) != 128 AND           -- not in recycle bin
           not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
                (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count all base tables registered as system-owned.
   SELECT count(*) INTO num_rsys_tabs
   FROM sys.obj$ o
   WHERE o.type# = 2 AND                           -- base tables
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select r.schema#             -- registered as
                      from registry$ r             -- system-owned
                      where r.status in (1,3,5) and r.namespace='SERVER');
   
   -- count all base tables not registered as system-owned.
   SELECT count(*) INTO num_nsys_tabs
   FROM sys.obj$ o
   WHERE o.type# = 2 AND                           -- base tables
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select u.user#               -- not registered as
                      from user$ u                 -- system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   -- number of system-owned base tables as candidates.
   num_sys_tabs := num_rsys_tabs + num_nsys_tabs;
   
   -- number of user base tables as candidates.
   num_user_tabs := greatest(0, num_tabs - num_sys_tabs);

   -- count all partitions, subpartitions in the database.
   SELECT count(*) INTO num_parts
   FROM sys.obj$ o
     WHERE o.type# IN (19, 34) AND                   -- parts, subparts
           bitand(o.flags, 128) != 128 AND           -- not in recycle bin
           not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
                (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count all partitions registered as system-owned.
   SELECT count(*) INTO num_rsys_parts
   FROM sys.obj$ o
   WHERE o.type# IN (19, 34) AND                   -- parts, subparts
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select r.schema#             -- registered as
                      from registry$ r             -- system-owned
                      where r.status in (1,3,5) and r.namespace='SERVER');
   
   -- count all partitions not registered as system-owned.
   SELECT count(*) INTO num_nsys_parts
   FROM sys.obj$ o
   WHERE o.type# IN (19, 34) AND                   -- parts, subparts
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select u.user#               -- not registered as
                      from user$ u                 -- system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   -- we assume there are no system-owned subpartitions!
   num_sys_parts := num_rsys_parts + num_nsys_parts;
   
   -- count all hash subpartitions in the database.
   SELECT count(*) INTO num_hsub_parts
   FROM  sys.obj$ o, sys.partobj$ po
     WHERE o.obj# = po.obj# AND o.type# = 34 AND     -- subparts
           mod(po.spare2, 256) = 2 AND               -- type hash
           bitand(o.flags, 128) != 128 AND           -- not in recycle bin
           not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
                (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- number of user partitions as candidates.
   num_user_parts := greatest(0, num_parts - num_sys_parts - num_hsub_parts);

   -- count indexes on all base tables.
   SELECT count(*) INTO num_inds
   FROM sys.obj$ o
   WHERE o.type# = 1 AND                           -- table indexes
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count indexes on all registered system-owned base tables.
   SELECT count(*) INTO num_rsys_inds
   FROM sys.obj$ o
   WHERE o.type# = 1 AND                           -- table indexes
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select r.schema#             -- registered as
                      from registry$ r             -- system-owned
                      where r.status in (1,3,5) and r.namespace='SERVER');
   
   -- count indexes on all non-registered system-owned base tables.
   SELECT count(*) INTO num_nsys_inds
   FROM sys.obj$ o
   WHERE o.type# = 1 AND                           -- table indexes
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select u.user#               -- not registered as
                      from user$ u                 -- system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   -- number of indexes on system-owned tables as candidates.
   num_sys_inds := num_rsys_inds + num_nsys_inds;
   
   -- number of indexes on user tables as candidates.
   num_user_inds := greatest(0, num_inds - num_sys_inds);
   
   -- count indexes on all partitions, subpartitions.
   SELECT count(*) INTO num_part_inds
   FROM sys.obj$ o
   WHERE o.type# IN (20, 35) AND                  -- part, subpart indexes
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND        -- no CTX objects
             (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count all indexes on partitions registered as system-owned.
   SELECT count(*) INTO num_rsys_inds
   FROM sys.obj$ o
   WHERE o.type# IN (20, 35) AND                   -- part, subpart indexes
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select r.schema#             -- registered as
                      from registry$ r             -- system-owned
                      where r.status in (1,3,5) and r.namespace='SERVER');
   
   -- count all indexes on partitions not registered as system-owned.
   SELECT count(*) INTO num_nsys_inds
   FROM sys.obj$ o
   WHERE o.type# IN (20, 35) AND                   -- part, subpart indexes
         bitand(o.flags, 128) != 128 AND           -- not in recycle bin
         not (bitand(o.flags, 16) = 16 AND         -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select u.user#               -- not registered as
                      from user$ u                 -- system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   num_sys_part_inds := num_rsys_inds + num_nsys_inds;
   
   -- count indexes on all hash subpartitions.
   SELECT count(*) INTO num_hsp_inds
   FROM sys.obj$ o, sys.partobj$ po
     WHERE o.obj# = po.obj# AND o.type# = 35 AND   -- subpart indexes
           MOD(po.spare2, 256) = 2 AND             -- hash subparts
           bitand(o.flags, 128) != 128 AND         -- not in recycle bin
           NOT (bitand(o.flags, 16) = 16 AND       -- no CTX objects
                (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- number of local indexes on partitions, subpartitions as candidates.
   num_user_part_inds :=
               greatest(0, num_part_inds - num_sys_part_inds - num_hsp_inds);
   
   -- count columns in all base tables.
   SELECT count(*) INTO num_cols
   FROM sys.col$ c, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.type# = 2 AND
         bitand(o.flags, 128) != 128 AND
         NOT (bitand(o.flags, 16) = 16 AND
              (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count columns in all registered system-owned tables.
   SELECT count(*) INTO num_rsys_cols
   FROM sys.col$ c, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.type# = 2 AND      -- columns on base tables
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         NOT (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) AND
         o.owner# IN (select r.schema#
                      from registry$ r            -- registered as system-owned
                      where r.status in (1,3,5) and
                            r.namespace='SERVER');
   
   -- count columns in all non-registered system-owned tables.
   SELECT count(*) INTO num_nsys_cols
   FROM sys.col$ c, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.type# = 2 AND      -- columns on base tables
         bitand(o.flags, 128) != 128 AND          -- not in recyc bin
         not (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) and
         o.owner# in (select u.user#
                      from user$ u                -- other system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   -- number of columns in system-owned tables as candidates.
   num_sys_cols := num_rsys_cols + num_nsys_cols;

   -- number of columns in user tables as candidates.
   num_user_cols := greatest(0, num_cols - num_sys_cols);
   
   -- count columns in all partitions.
   SELECT count(*) INTO num_part_cols
   FROM sys.col$ c, sys.tabpart$ tp, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.obj# = tp.bo# AND
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         NOT (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count columns in all subpartitions.
   SELECT count(*) INTO num_subp_cols
   FROM sys.col$ c, sys.tabsubpart$ tsp, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.obj# = tsp.pobj# AND
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         NOT (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- count columns in all partitions registered as system-owned.
   SELECT count(*) INTO num_rsys_cols
   FROM sys.col$ c, sys.tabpart$ tp, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.obj# = tp.bo# AND
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         NOT (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) AND
         o.owner# IN (select r.schema#
                      from registry$ r            -- registered as system-owned
                      where r.status in (1,3,5) and
                            r.namespace='SERVER');
   
   -- count columns in all partitions not registered as system-owned.
   SELECT count(*) INTO num_nsys_cols
   FROM sys.col$ c, sys.tabpart$ tp, sys.obj$ o
   WHERE c.obj# = o.obj# AND o.obj# = tp.bo# AND
         bitand(o.flags, 128) != 128 AND          -- not in recycle bin
         NOT (bitand(o.flags, 16) = 16 AND        -- no CTX objects
              (o.name like 'DR$%' or o.name like 'DR#%')) AND
         o.owner# in (select u.user#
                      from user$ u                -- other system-owned
                      where u.name in ('SYSTEM','OUTLN','DBSNMP','MDDATA',
                                       'WKPROXY','WK_TEST','ODM','ORDPLUGINS',
                                       'SI_INFORMTN_SCHEMA'));
   
   num_sys_part_cols := num_rsys_cols + num_nsys_cols;
   
   -- count columns in all hash subpartitions.
   SELECT count(*) INTO num_hsp_cols
   FROM sys.col$ c, sys.tabsubpart$ tsp, sys.obj$ o, sys.partobj$ po
   WHERE c.obj# = o.obj# AND o.obj# = tsp.pobj# AND
         o.obj# = po.obj# AND MOD(po.spare2, 256) != 128 AND  -- hash subparts
         bitand(o.flags, 128) != 128 AND
         NOT (bitand(o.flags, 16) = 16 AND
              (o.name like 'DR$%' or o.name like 'DR#%'));
   
   -- number of columns in partitions as candidates
   num_user_part_cols := greatest(0,
           num_part_cols + num_subp_cols - num_sys_part_cols - num_hsp_cols);
   
   SELECT dbms_stats.get_stats_history_retention INTO stats_retention
   FROM sys.dual;
END optstats_get_vars;


-----------------------------------------------------
-- optstats_space_est -
--   This routine will return the estimated usage 
--   for Optimizer Stats versions in megabytes (MB).
-----------------------------------------------------
function optstats_space_est
  (num_sys_tabs        IN NUMBER,
   num_user_tabs       IN NUMBER,
   num_sys_parts       IN NUMBER,
   num_user_parts      IN NUMBER,
   num_sys_inds        IN NUMBER,
   num_user_inds       IN NUMBER,
   num_sys_part_inds   IN NUMBER,
   num_user_part_inds  IN NUMBER,
   num_sys_cols        IN NUMBER,
   num_user_cols       IN NUMBER,
   num_sys_part_cols   IN NUMBER,
   num_user_part_cols  IN NUMBER,
   pct_volatile        IN NUMBER,
   pct_skewed_cols     IN NUMBER,
   pct_cand_parts      IN NUMBER,
   days_to_stale       IN NUMBER,
   days_to_stale_low   IN NUMBER,
   stats_retention     IN NUMBER)
 return NUMBER
AS
   sys_ver_size       NUMBER;
   user_ver_size      NUMBER;
   num_sys_vers       NUMBER;
   num_user_vers      NUMBER;
   size_estimate      NUMBER;

BEGIN
   /*
   ** The formula for SYSAUX usage to store optimizer statistics versions
   ** assumes that the automatic statistics collection job runs daily and
   ** that no manual statistics collection is performed.
   ** The retention period is assumed to be >= 1 day.
   */
   sys_ver_size  :=
          (num_sys_tabs + num_sys_parts)     * 100 + 
          (num_sys_inds + num_sys_part_inds) * 125 +
          (num_sys_cols + num_sys_part_cols) *
                                         (150 + 30 * 175 * pct_skewed_cols);
                 -- assume 30 buckets and 175 bytes/row for histogram entries

   
    user_ver_size :=
          (num_user_tabs + num_user_parts     * pct_cand_parts) * 100 +
          (num_user_inds + num_user_part_inds * pct_cand_parts) * 125 +
          (num_user_cols + num_user_part_cols * pct_cand_parts) *
                                          (150 + 30 * 175 * pct_skewed_cols);
   
   num_sys_vers  := greatest(1, stats_retention / 
                                greatest (1, least(days_to_stale_low,
                                                   stats_retention)));
   
   num_user_vers := greatest(1, stats_retention /
                                greatest(1, least(days_to_stale,
                                                  stats_retention)));

   if (false) then   -- change to true to see the intermediate values.
                     -- (in case if we want to debug stats estimation )
     dbms_output.put_line('DEBUG BEGIN');
     dbms_output.put_line('num_sys_tabs :' || num_sys_tabs);
     dbms_output.put_line('num_sys_parts :' || num_sys_parts);
     dbms_output.put_line('num_sys_inds :' || num_sys_inds);
     dbms_output.put_line('num_sys_part_inds :' || num_sys_part_inds);
     dbms_output.put_line('num_sys_cols :' || num_sys_cols);
     dbms_output.put_line('num_sys_part_cols :' || num_sys_part_cols);
     dbms_output.put_line('sys_ver_size :' || sys_ver_size); 
     dbms_output.put_line('num_sys_vers :' || num_sys_vers); 
     dbms_output.put_line('num_user_tabs :' || num_user_tabs);
     dbms_output.put_line('num_user_parts :' || num_user_parts);
     dbms_output.put_line('num_user_inds :' || num_user_inds);
     dbms_output.put_line('num_user_part_inds :' || num_user_part_inds);
     dbms_output.put_line('num_user_cols :' || num_user_cols);
     dbms_output.put_line('num_user_part_cols :' || num_user_part_cols);
     dbms_output.put_line( 'user_ver_size :' || user_ver_size); 
     dbms_output.put_line('num_user_vers :' || num_user_vers); 
     dbms_output.put_line('DEBUG END');
   end if;
   

   size_estimate := 
       sys_ver_size  * (pct_volatile * num_sys_vers  + (1 - pct_volatile)) +
       user_ver_size * (pct_volatile * num_user_vers + (1 - pct_volatile)) +
       stats_retention * 150;

   -- On the average, it is using only 94 % of the space for storing
   -- data, account for the rest ...
   size_estimate := size_estimate * 1.06;

   
   -- convert the size estimate in Megabytes
   size_estimate := size_estimate / 1048576;

   RETURN size_estimate;
END optstats_space_est;

-----------------------------------------------------
-- optstats_display_vars 
--   This routine will display the optstats variables
-----------------------------------------------------
procedure optstats_display_vars
   (num_user_tabs       IN NUMBER,
    num_user_parts      IN NUMBER,
    num_user_inds       IN NUMBER,
    num_user_part_inds  IN NUMBER,
    num_user_cols       IN NUMBER,
    num_user_part_cols  IN NUMBER,
    stats_retention     IN NUMBER,
    dml_activity        IN NUMBER,
    optstats_est        IN NUMBER)
as 

  align           number       := 37;
  salign          number       := 30;
  banner          number       := 51;
  mb_format       varchar2(20) := '99,999,990.0';
  num_format      varchar2(20) := '999,990';
  frac_format     varchar2(20) := '9,990.9';
  disp_activity   VARCHAR2(6);
begin

  dbms_output.put_line( rpad('| Estimated size of Stats history', align)
                        || to_char(optstats_est, mb_format) || ' MB');

  dbms_output.put_line('| ');

  dbms_output.put_line('|   The space for Optimizer Statistics history was ');
  dbms_output.put_line('|   estimated using the following values: ');
  dbms_output.put_line('|   ');
  dbms_output.put_line('|   ' 
                       || lpad('Tables -', salign) 
                       || to_char(num_user_tabs, num_format));
  dbms_output.put_line('|   ' 
                       || lpad('Indexes -', salign) 
                       || to_char(num_user_inds, num_format));
  dbms_output.put_line('|   ' 
                       || lpad('Columns -', salign) 
                       || to_char(num_user_cols, num_format)); 
  dbms_output.put_line('|   ' 
                       || lpad('Partitions -', salign) 
                       || to_char(num_user_parts, num_format));
  dbms_output.put_line('|   ' 
                       || lpad('Indexes on Partitions -', salign) 
                       || to_char(num_user_part_inds, num_format)); 
  dbms_output.put_line('|   ' 
                       || lpad('Columns in Partitions -', salign) 
                       || to_char(num_user_part_cols, num_format)); 
  dbms_output.put_line('|   ' 
                       || lpad('Stats Retention in Days -', salign) 
                       || to_char(stats_retention, num_format)); 
  
  IF (dml_activity = 1) THEN
     disp_activity := '   Low';
  ELSE IF (dml_activity = 2) THEN
     disp_activity := 'Medium';
  ELSE
     disp_activity := '  High';
  END IF;
  END IF;
  dbms_output.put_line('|   '
                       || lpad('Level of DML Activity -', salign) 
                       || '  ' || disp_activity);
end optstats_display_vars;


end UTLSYXSZ_UTIL;
/

set termout on;
spool &report_name


/******************************************************
 * (0) Display Header info: time, database name, etc. 
 ******************************************************/

column db_id         format a12 just r;
column name          format a20
column platform_name format a30
column host_platform format a40 wrap
column startup_time  format a17
column inst          format 9999

prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt SYSAUX Size Estimation Report
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select 'Estimated at', to_char(systimestamp, 'HH24:MI:SS "on" Mon DD, YYYY ( ')
                       || trim(to_char(systimestamp, 'Day'))
                       || to_char(systimestamp, ' ) "in Timezone" TZR')
 from dual;

set heading on;

select (a.cur || a.db_name) as db_name, a.host_platform,
       a.inst, a.startup_time, a.parallel
from   (select (case when awr.dbid = max(d.dbid) and
                     awr.instance_number = max(i.instance_number) then '* '
                else '  ' end ) as Cur,
                awr.dbid, max(awr.db_name) as db_name,
                max(awr.host_name) || ' - ' ||
                (case when awr.dbid = max(d.dbid) then max(d.platform_name)
                      else '' end ) as host_platform,
                awr.instance_number inst,
                max(awr.startup_time) as startup_time, 
                max(awr.parallel) as parallel
        from    sys.wrm$_database_instance awr, v$database d, v$instance i
        group   by awr.dbid, awr.instance_number) a,
       sys.wrm$_database_instance wdi
where  wdi.dbid = a.dbid
  and  wdi.instance_number = a.inst
  and  wdi.startup_time = a.startup_time;

set heading off;


/**********************************************************
 * (1) read current SYSAUX space usage into three buckets:
 *     AWR, AutoStat_History, Others.
 **********************************************************/
prompt 
prompt ~~~~~~~~~~~~~~~~~~~~
prompt Current SYSAUX usage
prompt ~~~~~~~~~~~~~~~~~~~~

declare
  occ_name    varchar2(64);
  occ_size    number;

  total_size  number;

  /* cursor to select sysaux occupants */
  cursor occ_cursor is
    select occupant_name, space_usage_mb from
      (select occupant_name, space_usage_kbytes/1024 as space_usage_mb,
              (case when occupant_name = 'SM/AWR'     then 1
                    when occupant_name = 'SM/OPTSTAT' then 2
                    else 3 end) as occ_order
        from v$sysaux_occupants) occ
     where space_usage_mb > 0
     order by occ_order, space_usage_mb desc;

  newline_char varchar2(1) := '
';

begin
  select (sum(bytes)/1024/1024) into total_size 
   from  dba_segments
   where tablespace_name = 'SYSAUX';

  dbms_output.put_line( rpad('| Total SYSAUX size: ', :align )
                        || to_char(total_size, :mb_format) || ' MB' );
  dbms_output.put_line( '|   ');

  /* initialize other occupant size */
  :oth_occ_size     := 0;
  :estimated_others := NULL;

  /* open cursor to fetch occupants */
  open occ_cursor;

  loop
    fetch occ_cursor into occ_name, occ_size;
    exit when occ_cursor%NOTFOUND;

    dbms_output.put_line(rpad('| Total size of ' || occ_name, :align)
                         || to_char(occ_size, :mb_format) || ' MB ('
                         || to_char(occ_size * 100/ total_size, :perc_format)
                         || '% of SYSAUX )' );

    /* compute different sizes */
    case occ_name
      when 'SM/AWR' then 
        :awr_size := occ_size;
      when 'SM/OPTSTAT' then
        :opt_size := occ_size;
      else
        :oth_occ_size := :oth_occ_size + occ_size;

        :estimated_others := :estimated_others ||
                             rpad('| Est size of ' || occ_name, :align) ||
                             to_char(occ_size, :mb_format) || ' MB' ||
                             newline_char;
    end case;

  end loop;

  :oth_size := total_size - (:awr_size + :opt_size + :oth_occ_size);

  dbms_output.put_line( rpad('| Total size of Others ', :align )
                        || to_char(:oth_size, :mb_format) || ' MB ('
                        || to_char(:oth_size * 100/ total_size, :perc_format)
                        || '% of SYSAUX )' );

  :estimated_others := :estimated_others ||
                       rpad('| Est size of Others ', :align ) ||
                            to_char(:oth_size, :mb_format) || ' MB';

  dbms_output.put_line( '|   ');
end;
/


/******************************************************
 * (2) AWR Space estimate
 *     a. read average number of active sessions from v$ash or
 *        wrh$_active_session_history into :actses
 *     b. prompt users for average number of active sessions with
 *        recommended value of :actses
 *     c. compute AWR size estimates into :awr_space_est
 ******************************************************/
-- variables for AWR space estimate
variable active_sessions number;
variable files           number;
variable interval        number;
variable retention       number;
variable num_inst        number;


/*---------------------------------------------*
 * (2.1) retrieve current values for variables 
 *---------------------------------------------*/
begin
  utlsyxsz_util.awr_set_variables(:active_sessions, :files, :interval, 
                                  :retention, :num_inst);
end;
/

/*------------------------------------------*
 * (2.2) prompt users if they would like to 
 *       change recommended values 
 *------------------------------------------*/
prompt
prompt ~~~~~~~~~~~~~~~~~~~~
prompt AWR Space Estimation
prompt ~~~~~~~~~~~~~~~~~~~~
prompt 
prompt | To estimate the size of the Automatic Workload Repository (AWR)
prompt | in SYSAUX, we need the following values:
prompt |
prompt |     - Interval Setting (minutes)
prompt |     - Retention Setting (days)
prompt |     - Number of Instances
prompt |     - Average Number of Active Sessions
prompt |     - Number of Datafiles

/* set the columns */
column active_sessions new_value active_sessions noprint;
column interval_val    new_value interval        noprint;
column retention_val   new_value retention       noprint;
column num_instances   new_value num_instances   noprint;

/*------------------*
 * Interval Setting 
 *------------------*/
prompt 
exec utlsyxsz_util.show_default('Interval Setting', (:interval / 60), 'minutes');

select '**   Value for ''Interval Setting'': ' ||
       nvl('&&interval', (:interval / 60)),
       nvl('&&interval', (:interval / 60)) interval_val
  from sys.dual;

/*------------------*
 * Retention Setting 
 *------------------*/
prompt
exec utlsyxsz_util.show_default('Retention Setting', (:retention / 86400), 'days');

select '**   Value for ''Retention Setting'': ' ||
       round(nvl('&&retention', (:retention / 86400)), 2),
       nvl('&&retention', (:retention / 86400)) retention_val
  from sys.dual;

/*---------------------*
 * Number of Instances
 *---------------------*/
prompt
exec utlsyxsz_util.show_default('Number of Instances', :num_inst);

select '**   Value for ''Number of Instances'': ' ||
       nvl('&&num_instances', :num_inst),
       nvl('&&num_instances', :num_inst) num_instances
  from sys.dual;

/*-------------------------------*
 * Avg Number of Active Sessions
 *-------------------------------*/
prompt
exec utlsyxsz_util.show_default('Average Number of Active Sessions', :active_sessions);

select '**   Value for ''Average Number of Active Sessions'': ' ||
       round(nvl('&&active_sessions', :active_sessions), 2),
       nvl('&&active_sessions', :active_sessions) active_sessions
  from sys.dual;

/*---------------------------------*
 * (2.3) Output Estimated AWR size 
 *---------------------------------*/
whenever sqlerror exit;
prompt
declare 

begin
  /* set the final values. convert the interval
   * and retention to seconds.  the select is
   * done to avoid number overflow.
   */
  select (&interval * 60), (&retention * 86400)
    into :interval, :retention
    from dual;
  
  :active_sessions := &active_sessions;
  :num_inst        := &num_instances;

  :awr_space_est := utlsyxsz_util.awr_space_estimate(:active_sessions, 
                                                     :files, :interval, 
                                                     :retention, :num_inst, 
                                                     :awr_size);

  dbms_output.put_line('| ' || rpad('*', :banner, '*'));

  /* the size is infinite */
  if (:awr_space_est = -1) then
    utlsyxsz_util.awr_display_variables(:active_sessions, :files, :interval, 
                                        :retention, :num_inst, :awr_space_est);

    dbms_output.put_line('| ');
    dbms_output.put_line('| ' || rpad('#', :banner, '#'));
    dbms_output.put_line('| We will re-estimate the AWR size using the ');
    dbms_output.put_line('| default retention!');
    dbms_output.put_line('| ' || rpad('#', :banner, '#'));
    dbms_output.put_line('| ' || rpad('~' , :banner, '~'));
    dbms_output.put_line('| ');

    /* set the retention to the default 7 days */
    :retention := 604800;

    /* re-estimating based on the default retention */
    :awr_space_est := utlsyxsz_util.awr_space_estimate(:active_sessions, 
                                                       :files, :interval, 
                                                       :retention, :num_inst, 
                                                       :awr_size);
  end if;
  
  utlsyxsz_util.awr_display_variables(:active_sessions, :files, :interval, 
                                      :retention, :num_inst, :awr_space_est);

  dbms_output.put_line('| ' || rpad('*', :banner, '*')); 
end;
/

whenever sqlerror continue;

/**************************************************************************
 * (3) AutoStat_History estimate:
 *     a. read total number of user/system tables, indexes, columns
 *     b. compute estimates for AutoStat_History into :optstats_space_est
 **************************************************************************/

-- variables for Optimizer Stat space estimate
variable num_sys_tabs       NUMBER;
variable num_user_tabs      NUMBER;
variable num_sys_parts      NUMBER;
variable num_user_parts     NUMBER;
variable num_sys_inds       NUMBER;
variable num_user_inds      NUMBER;
variable num_sys_part_inds  NUMBER;
variable num_user_part_inds NUMBER;
variable num_sys_cols       NUMBER;
variable num_user_cols      NUMBER;
variable num_sys_part_cols  NUMBER;
variable num_user_part_cols NUMBER;
variable pct_volatile       NUMBER;
variable pct_skewed_cols    NUMBER;
variable pct_cand_parts     NUMBER;
variable stats_retention    NUMBER;
variable dml_activity       NUMBER;
variable days_to_stale      NUMBER;
variable days_to_stale_low  NUMBER;
variable days_to_stale_med  NUMBER;
variable days_to_stale_high NUMBER;
variable number_of_tables     NUMBER;
variable number_of_partitions NUMBER;

-- set system default values
BEGIN
  :pct_skewed_cols := 0.11;
  :pct_cand_parts := 0.2;
  :pct_volatile := 0.5;
  :dml_activity := 2;
  :days_to_stale_low := 15;
  :days_to_stale_med := 6;
  :days_to_stale_high := 2;
END;
/


/*---------------------------------------------*
 * (3.1) retrieve current values for variables 
 *---------------------------------------------*/
begin
   utlsyxsz_util.optstats_get_vars(
     :num_sys_tabs, :num_user_tabs, :num_sys_parts, :num_user_parts,
     :num_sys_inds, :num_user_inds, :num_sys_part_inds, :num_user_part_inds,
     :num_sys_cols, :num_user_cols, :num_sys_part_cols, :num_user_part_cols,
     :stats_retention);
end;
/

/*------------------------------------------*
 * (3.2) prompt users if they would like to 
 *       change recommended values 
 *------------------------------------------*/
prompt
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Optimizer Stat History Space Estimation
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt 
prompt | To estimate the size of the Optimizer Statistics History
prompt | we need the following values:
prompt |
prompt |     - Number of Tables in the Database
prompt |     - Number of Partitions in the Database
prompt |     - Statistics Retention Period (days)
prompt |     - DML Activity in the Database (level)
  
column number_of_tables     new_value  number_of_tables     noprint;
column number_of_partitions new_value  number_of_partitions noprint;
column dml_activity         new_value  dml_activity         noprint;
column stats_retention      new_value  stats_retention      noprint;

/*---------------------*
 * Number of Tables
 *---------------------*/
prompt 
exec utlsyxsz_util.show_default('Number of Tables', :num_user_tabs, '', '<a positive integer>');

BEGIN
   :number_of_tables := :num_user_tabs;
END;
/
select '**   Value for ''Number of Tables'': ' ||
       nvl('&&number_of_tables', :number_of_tables),
       nvl('&&number_of_tables', :number_of_tables) number_of_tables
from sys.dual;


/*---------------------*
 * Number of Partitions
 *---------------------*/
prompt 
exec utlsyxsz_util.show_default('Number of Partitions', :num_user_parts, '', '<a positive integer>');

BEGIN
   :number_of_partitions := :num_user_parts;
END;
/
select '**   Value for ''Number of Partitions'': ' ||
     nvl('&&number_of_partitions', :number_of_partitions),
     nvl('&&number_of_partitions', :number_of_partitions) number_of_partitions
from sys.dual;

/*---------------------*
 * Statistics Retention
 *---------------------*/
prompt 
exec utlsyxsz_util.show_default('Statistics Retention', :stats_retention, 'days', '<a positive integer>');

select '**   Value for ''Statistics Retention'': ' ||
       nvl('&&stats_retention', :stats_retention),
       nvl('&&stats_retention', :stats_retention) stats_retention
  from sys.dual;
  
/*---------------------*
 * DML Activity Level
 *---------------------*/
prompt 
exec utlsyxsz_util.show_default2('DML Activity', :dml_activity, '<1=low, 2=medium, 3=high>');

select '**   Value for ''DML Activity'': ' ||
       nvl('&&dml_activity', :dml_activity),
       nvl('&&dml_activity', :dml_activity) dml_activity
  from sys.dual;


/*-------------------------------------*
 * (3.3) Output Estimated OptStat size
 *-------------------------------------*/
prompt 
BEGIN
  
  :number_of_tables := &number_of_tables;
  IF (:number_of_tables != :num_user_tabs)
  THEN
     IF (:num_user_tabs > 0)
     THEN
        :num_user_inds :=
          ceil(:num_user_inds * :number_of_tables / :num_user_tabs);
        :num_user_cols :=
          ceil(:num_user_cols * :number_of_tables / :num_user_tabs);
     END IF;
     :num_user_tabs := :number_of_tables;
  END IF;
  
  :number_of_partitions := &number_of_partitions;
  IF (:number_of_partitions != :num_user_parts)
  THEN
     IF (:num_user_parts > 0)
     THEN
        :num_user_part_inds :=
          ceil(:num_user_part_inds * :number_of_partitions / :num_user_parts);
        :num_user_part_cols :=
          ceil(:num_user_part_cols * :number_of_partitions / :num_user_parts);
     END IF;
     :num_user_parts := :number_of_partitions;
  END IF;

  IF (&stats_retention > 0) THEN
    :stats_retention := &stats_retention;
  ELSIF (&stats_retention = 0) THEN -- 0 is a special value for retention.
                                    -- assume 1 version
    :stats_retention := 1;
  ELSIF (&stats_retention < 0) THEN
    :stats_retention := 31;
  END IF;
     
  :dml_activity := &dml_activity;
  IF (:dml_activity != 1 AND :dml_activity != 2 AND :dml_activity != 3) THEN
     :dml_activity := 2;
  END IF;
  
  IF (:dml_activity = 1) THEN
     :days_to_stale := :days_to_stale_low;
  ELSIF (:dml_activity = 3) THEN 
     :days_to_stale := :days_to_stale_high;
  ELSE
     :days_to_stale := :days_to_stale_med;
  END IF;
     
  :optstats_space_est := utlsyxsz_util.optstats_space_est(
     :num_sys_tabs, :num_user_tabs, :num_sys_parts, :num_user_parts,
     :num_sys_inds, :num_user_inds, :num_sys_part_inds, :num_user_part_inds,
     :num_sys_cols, :num_user_cols, :num_sys_part_cols, :num_user_part_cols,
     :pct_volatile, :pct_skewed_cols, :pct_cand_parts,
     :days_to_stale, :days_to_stale_low, :stats_retention);

  dbms_output.put_line( '| ' || rpad('*', :banner, '*'));

  utlsyxsz_util.optstats_display_vars(:num_user_tabs, :num_user_parts,
                                      :num_user_inds, :num_user_part_inds,
                                      :num_user_cols, :num_user_part_cols,
                                      :stats_retention, :dml_activity,
                                      :optstats_space_est);
  
  dbms_output.put_line( '| ' || rpad('*', :banner, '*'));
end;
/


/******************************************************
 * (4) compute total SYSAUX space estimate:
 *       :total_space_est = :oth_size + :awr_space_est + 
 *                          :optstats_space_est
 ******************************************************/
prompt 
prompt ~~~~~~~~~~~~~~~~~~~~~~
prompt Estimated SYSAUX usage
prompt ~~~~~~~~~~~~~~~~~~~~~~
prompt

begin
  dbms_output.put_line( '| ' || rpad('~' , :banner, '~'));

  utlsyxsz_util.awr_display_variables(:active_sessions, :files, :interval, 
                                      :retention, :num_inst, :awr_space_est);

  dbms_output.put_line( '| ' || rpad('~' , :banner, '~'));

  utlsyxsz_util.optstats_display_vars(:num_user_tabs, :num_user_parts,
                                      :num_user_inds, :num_user_part_inds,
                                      :num_user_cols, :num_user_part_cols,
                                      :stats_retention, :dml_activity,
                                      :optstats_space_est);
    
  dbms_output.put_line( '| ' || rpad('~' , :banner, '~'));

  dbms_output.put_line( '|   For all the other components, the estimate');
  dbms_output.put_line( '|   is equal to the current space usage of');
  dbms_output.put_line( '|   the component.');

  dbms_output.put_line( '| ' || rpad('~' , :banner, '~'));
  dbms_output.put_line( '| ');
  dbms_output.put_line( '| ');

  dbms_output.put_line( '| ' || rpad('*' , :banner, '*'));

  dbms_output.put_line( '| Summary of SYSAUX Space Estimation ');
  dbms_output.put_line( '| ' || rpad('*' , :banner, '*'));
end;
/

select :estimated_others from dual;

begin
  /* the estimate for others is equal to the current size */
  :other_space_est := :oth_occ_size + :oth_size;

  /* compute the total estimated space */ 
  :total_space_est := :awr_space_est + :optstats_space_est + :other_space_est;

  dbms_output.put_line( rpad('| Est size of SM/AWR ', :align)
                        || to_char(:awr_space_est, :mb_format) || ' MB');

  dbms_output.put_line( rpad('| Est size of SM/OPTSTAT ', :align )
                        || to_char(:optstats_space_est, :mb_format) || ' MB');

  dbms_output.put_line( '|   ');

  dbms_output.put_line( '| ' || rpad('~', :banner, '~'));

  dbms_output.put_line( rpad('| Total Estimated SYSAUX size: ', :align )
                        || to_char(:total_space_est, :mb_format) || ' MB' );

  dbms_output.put_line( '| ' || rpad('~', :banner, '~'));
  dbms_output.put_line( '| ' || rpad('*', :banner, '*'));

end;
/

prompt 
prompt End of Report
spool off;

-- drop the package that was created as part of this script
drop package utlsyxsz_util;

undefine dflt_name;
undefine report_name;

undefine active_sessions;
undefine interval;
undefine retention;
undefine num_instances;

undefine number_of_tables;
undefine number_of_partitions;
undefine dml_activity;
undefine stats_retention;

-- End of File
