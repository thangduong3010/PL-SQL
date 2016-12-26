Rem
Rem $Header: rdbms/admin/spawrrac.sql /main/8 2008/10/13 14:42:23 cgervasi Exp $
Rem
Rem spawrrac.sql
Rem
Rem Copyright (c) 2007, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      spawrrac.sql - Server Performance AWR RAC report
Rem
Rem    DESCRIPTION
Rem      This scripts generates a global AWR report to report
Rem      performance statistics on all nodes of a cluster.
Rem
Rem    NOTES
Rem      Usually run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cgervasi    10/09/08 - fix formatting
Rem    cgervasi    06/05/08 - add sql ordered by user io
Rem    cgervasi    05/28/08 - add remaster stats, iostat
Rem    cgervasi    04/21/08 - fix divide-by-zero errors
Rem    cgervasi    01/17/08 - fix SQL captured pct
Rem    cgervasi    01/03/08 - fix divide-by-zero for current blocks
Rem    cgervasi    11/07/07 - change headings for Wait Events
Rem    cgervasi    09/19/07 - add %Total for more segment statistics
Rem    cgervasi    08/21/07 - add wait event summary; avg/stddev/min/max
Rem    cgervasi    06/29/07 - general cleanup
Rem    cgervasi    05/16/07 - use fg statistics for wait events and classes
Rem    cgervasi    04/03/07 - add new columns inst_cache_transfer
Rem    cgervasi    04/02/07 - add interconnect stats
Rem    cgervasi    03/15/07 - use 11g pivot syntax
Rem    cgervasi    02/28/07 - check in; additional sections
Rem    cdgreen     08/23/06 - Created with cgervasi
Rem

set longchunksize 5000

-- 
-- Get the report settings


Rem     -------------           Beginning of                -----------
Rem     ------------- Customer Configurable Report Settings -----------

--
-- Snapshot related report settings

-- The default number of days of snapshots to list when displaying the
-- list of snapshots to choose the begin and end snapshot Ids from.
--
--   List all snapshots
--define num_days = '';
--
--   List last 31 days
define num_days = 31;
--
--   List no (i.e. 0) snapshots
-- define num_days = 0;


-- ----------------------------------------

-- Number of events to display in Top Timed Events
define top_n_events = 10;

--
-- SQL related report settings

-- Number of Rows of SQL to display in each SQL section of the report
define top_n_sql = 20;

--
-- Segment Statistics

-- Number of segments to display for each segstat category
define top_n_segstat = 10;


Rem     -------------                End  of                -----------
Rem     ------------- Customer Configurable Report Settings -----------
-- -------------------------------------------------------------------------

--
--

clear break compute;
repfooter off;
ttitle off;
btitle off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 185 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
--
--  Must not be modified
--  Bytes to megabytes
define btomb = 1048576;
--  Bytes to kilobytes
define btokb = 1024;

--  Microseconds to milli-seconds
define ustoms = 1000;
--  Microseconds to seconds
define ustos = 1000000;
-- Centiseconds to seconds
define cstos = 100;
-- Centiseconds to milli-seconds
define cstoms = 10;

--
-- Request the DB Id

column instt_num  heading "Inst Num"        format 99999;
column instt_name heading "Instance"        format a12;
column dbb_name   heading "DB Name"         format a12;
column dbbid      heading "DB Id"           format 9999999999 just c;
column host       heading "Host"            format a12;
column instt_tot  heading "Instance|Count"  format 999

prompt
prompt
prompt Instances in this AWR schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select dbid            dbbid
     , db_name         dbb_name
     , count(distinct instance_number) instt_tot
  from dba_hist_database_instance
 group by dbid, db_name
 order by dbid;


prompt
prompt Using &&dbid for database Id


--
--  Set up the binds for dbid

variable dbid       number;
begin
  :dbid      :=  &dbid;
end;
/

--
-- Gather max snap time
column max_snap_time new_value max_snap_time noprint
select to_char(max(end_interval_time),'yyyy/mm/dd') max_snap_time
  from dba_hist_snapshot
 where dbid = :dbid;

--
--  Ask how many days of snapshots to display

set termout on;
column instart_fmt noprint;
column inst_name   format      a12 heading 'Instance';
column db_name     format      a12 heading 'DB Name';
column snap_id     format 99999990 heading 'Snap Id';
column snapdat     format      a17 heading 'End Interval Time'
column lvl         format       99 heading 'Snap|Level';

prompt
prompt
prompt Specify the number of days of snapshots to choose from
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Entering the number of days (n) will result in the most recent
prompt (n) days of snapshots being listed.  Pressing <return> without
prompt specifying a number lists all completed snapshots.
prompt
prompt

set heading off;
column num_days new_value num_days noprint;
select    'Listing '
       || decode( nvl('&&num_days', to_number('3.14','9D99','nls_numeric_characters=''.,'''))
                , to_number('3.14','9D99','nls_numeric_characters=''.,'''), 'all Completed Snapshots'
                , 0                                                       , 'no snapshots'
                , 1                                                       , 'the last day''s Completed Snapshots'
                , 'the last &num_days days of Completed Snapshots')
     , nvl('&&num_days', to_number('3.14','9D99','nls_numeric_characters=''.,'''))  num_days
  from sys.dual;
set heading on;


--
-- List available snapshots

break on inst_name on db_name on host on instart_fmt skip 1;
ttitle off;
column instances_up format 9999 heading 'Instance|Count'
column db_name      new_value db_name
select min(s.startup_time)                            instart_fmt
       -- di.instance_name                                   inst_name
     , di.db_name                                         db_name
     , s.snap_id                                          snap_id
     , to_char(s.end_interval_time,'dd Mon YYYY HH24:mi') snapdat
     , s.snap_level                                           lvl
     , count(1)                                      instances_up
  from dba_hist_snapshot s
     , dba_hist_database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and di.dbid             = s.dbid
   and di.instance_number  = s.instance_number
   and di.startup_time     = s.startup_time
   and s.end_interval_time >= decode(to_number('&num_days')
                                   , to_number('3.14','9D99','nls_numeric_characters=''.,'''), s.end_interval_time
                                   , 0              , to_date('31-JAN-9999','DD-MON-YYYY')
                                   , to_date('&&max_snap_time','yyyy/mm/dd') - (to_number('&num_days') - 1))
 group by di.db_name
        , s.snap_id
        , to_char(s.end_interval_time,'dd Mon YYYY HH24:mi')
        , s.snap_level
 order by db_name, snap_id;

clear break compute;
ttitle off;


--
--  Ask for the snapshots Id's which are to be compared

prompt
prompt
prompt Specify the Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Begin Snapshot Id specified: &&begin_snap
prompt
prompt End   Snapshot Id specified: &&end_snap
prompt


--
--  Set up the snapshot-related binds

variable bid        number;
variable eid        number;
begin
  :bid       :=  &begin_snap;
  :eid       :=  &end_snap;
end;
/

prompt

-- in case there were no snapshot lists displayed, at least get end snap
set termout off
column db_name new_value db_name noprint
select nvl('&&db_name',db_name) db_name
  from dba_hist_snapshot s
     , dba_hist_database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and di.dbid             = s.dbid
   and di.instance_number  = s.instance_number
   and di.startup_time     = s.startup_time
   and s.snap_id = :eid;


-- Use report name if specified, otherwise prompt user for output file 
-- name (specify default), then begin spooling

set termout off;
column dflt_name new_value dflt_name noprint;
select 'spawrrac_'|| :bid||'_'||:eid dflt_name from dual;
set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name, 
prompt press <return> to continue, otherwise enter an alternative.
prompt

set heading off;
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , decode( instr(nvl('&&report_name','&dflt_name'),'.'), 0, nvl('&&report_name','&dflt_name')||'.lst'
             , nvl('&&report_name','&dflt_name')) report_name
  from sys.dual;
prompt

-- 
-- Standard formatting

column chr4n      format a4      newline
column ch5        format a5
column ch5        format a5
column ch6        format a6
column ch6n       format a6      newline
column ch7        format a7
column ch7n       format a7      newline
column ch9        format a9
column ch14n      format a14     newline
column ch16t      format a16              trunc
column ch17       format a17
column ch17n      format a17     newline
column ch18n      format a18     newline
column ch19       format a19
column ch19n      format a19     newline
column ch21       format a21
column ch21n      format a21     newline
column ch22       format a22
column ch22n      format a22     newline
column ch23       format a23
column ch23n      format a23     newline
column ch24       format a24
column ch24n      format a24     newline
column ch25       format a25
column ch25n      format a25     newline
column ch20       format a20
column ch20n      format a20     newline
column ch32n      format a32     newline
column ch40n      format a40     newline
column ch42n      format a42     newline
column ch43n      format a43     newline
column ch52n      format a52     newline  just r
column ch53n      format a53     newline
column ch59n      format a59     newline  just r
column ch78n      format a78     newline
column ch80n      format a80     newline

column num3       format             999                 just left
column num3_2     format             999.99
column num3_2n    format             999.99     newline
column num4c      format           9,999
column num4c_2    format           9,999.99
column num4c_2n   format           9,999.99     newline
column num5c      format          99,999
column num6c      format         999,999
column num6c_2    format         999,999.99
column num6c_2n   format         999,999.99     newline
column num6cn     format         999,999        newline
column num7c      format       9,999,999
column num7c_2    format       9,999,999.99
column num8c      format      99,999,999
column num8cn     format      99,999,999        newline
column num8c_2    format      99,999,999.99
column num8cn     format      99,999,999        newline
column num9c      format     999,999,999
column num9cn     format     999,999,999        newline
column num10c     format   9,999,999,999


-- ------------------------------------------------------------------
-- Gather information for use in later sections

/* calculate system totals for use in SQL section  */

set heading off termout off feedback off
ttitle off
repfooter off

col bnuminst new_value bnuminst noprint
col enuminst new_value enuminst noprint
select sum(case when snap_id = :bid then 1 else 0 end) bnuminst
     , sum(case when snap_id = :eid then 1 else 0 end) enuminst
  from dba_hist_snapshot
 where snap_id in (:bid, :eid)
   and dbid    = :dbid;


col tdbtim new_value tdbtim  noprint
col tdbcpu new_value tdbcpu  noprint
col tbgtim new_value tbgtim  noprint
col tbgcpu new_value tbgcpu  noprint
col tgets  new_value tgets   noprint
col trds   new_value trds    noprint
col trdds  new_value trdds   noprint
col twrs   new_value twrs    noprint
col twrds  new_value twrds   noprint
col tdbch  new_value tdbch   noprint
col ttslt  new_value ttslt   noprint
col tiffs  new_value tiffs   noprint
col texecs new_value texecs  noprint
col tclutm new_value tclutm  noprint
col tiowtm new_value tiowtm  noprint
col tgccrr new_value tgccrr  noprint
col tgccur new_value tgccur  noprint
col tgccrs new_value tgccrs  noprint
col tgccus new_value tgccus  noprint
col tucm   new_value tucm    noprint
col tur    new_value tur     noprint

select *
  from ((select e.stat_name
             , (e.value - nvl(b.value,0))  value
          from dba_hist_sys_time_model b
             , dba_hist_sys_time_model e
         where e.dbid            = :dbid
           and e.dbid            = b.dbid            (+)
           and e.instance_number = b.instance_number (+)
           and e.snap_id         = :eid
           and b.snap_id   (+)   = :bid
           and b.stat_id   (+)   = e.stat_id
           and e.stat_name in ('DB time','DB CPU'
              ,'background elapsed time','background cpu time'))
       pivot (sum(value) for stat_name in 
               ('DB time'                 tdbtim
               ,'DB CPU'                  tdbcpu
               ,'background elapsed time' tbgtim
               ,'background cpu time'     tbgcpu)));


select *
  from ((select e.stat_name
             , (e.value - nvl(b.value,0))  value
          from dba_hist_sysstat b
             , dba_hist_sysstat e
         where e.dbid            = :dbid
           and e.dbid            = b.dbid            (+)
           and e.instance_number = b.instance_number (+)
           and e.snap_id         = :eid
           and b.snap_id   (+)   = :bid
           and b.stat_id   (+)   = e.stat_id
           and e.stat_name in ('session logical reads', 'db block changes'
               ,'physical reads', 'physical reads direct'
               ,'physical writes', 'physical writes direct'
               ,'execute count'
               , 'index fast full scans (full)', 'table scans (long tables)'
               , 'gc cr blocks received', 'gc current blocks received'
               , 'gc cr blocks served', 'gc current blocks served'
               , 'user commits', 'user rollbacks'))
        pivot (sum(value) for stat_name in
              ('session logical reads'         tgets
              ,'db block changes'              tdbch
              ,'physical reads'                trds
              ,'physical reads direct'         trdds
              ,'physical writes'               twrs
              ,'physical writes direct'        twrds
              ,'execute count'                 texecs
              ,'index fast full scans (full)'  tiffs
              ,'table scans (long tables)'     ttslt
              ,'gc cr blocks received'         tgccrr
              ,'gc current blocks received'    tgccur
              ,'gc cr blocks served'           tgccrs
              ,'gc current blocks served'      tgccus
              ,'user commits'                  tucm
              ,'user rollbacks'                tur)));
    
select *
  from ((select e.wait_class
              , sum(e.time_waited_micro - nvl(b.time_waited_micro,0))  twttm
           from dba_hist_system_event b
              , dba_hist_system_event e
          where e.dbid            = :dbid
            and e.dbid            = b.dbid             (+)
            and e.instance_number = b.instance_number  (+)
            and e.snap_id         = :eid
            and b.snap_id   (+)   = :bid
            and e.event_id        = b.event_id         (+)
            and e.wait_class in ('Cluster', 'User I/O')
          group by e.wait_class))
    pivot (sum(twttm) for wait_class in 
                ('Cluster'   tclutm
                ,'User I/O'  tiowtm));

variable numinst number;
variable tdbtim number;
variable tdbcpu number;
variable tbgtim number;
variable tbgcpu number;
variable tgets  number;
variable tdbch  number;
variable trds   number;
variable trdds  number;
variable twrs   number;
variable twrds  number;
variable texecs number;
variable ttslt  number;
variable tiffs  number;
variable tts    number;
variable tclutm number;
variable tiowtm number;
variable tgccrr number
variable tgccur number
variable tgccrs number
variable tgccus number
variable tucm   number
variable tur    number


begin
   :numinst := &enuminst;
   :tdbtim := &tdbtim;
   :tdbcpu := &tdbcpu;
   :tbgtim := &tbgtim;
   :tbgcpu := &tbgcpu;
   :tgets  := &tgets;
   :tdbch  := &tdbch;
   :trds   := &trds;
   :trdds  := &trdds;
   :twrs   := &twrs;
   :twrds  := &twrds;
   :texecs := &texecs;
   :ttslt  := &ttslt;
   :tiffs  := &tiffs;
   :tclutm := to_number(trim('&tclutm')); -- to allow it to work in a non-RAC environment
   :tiowtm := &tiowtm;
   :tgccrr := &tgccrr;
   :tgccur := &tgccur;
   :tgccrs := &tgccrs;
   :tgccus := &tgccus;
   :tucm   := &tucm;
   :tur    := &tur;
end;
/

-- ------------------------------------------------------------------

spool &report_name;
set newpage 1 heading on

prompt
prompt  Server Performance RAC report for Database &&db_name: Snaps &&begin_snap to &&end_snap
prompt

--
--  Summary Statistics
--

--
--  Print database, instance, parallel, release, host and snapshot
--  information

set heading on

column dbid            format 9999999999       heading 'DB Id'
column instance_number format        999       heading 'Inst #'
column instance_name   format         a9       heading 'Instance'
column host_name       format        a10 trunc heading 'Host'
column startup_time    format        a15 trunc heading 'Startup'
column begin_snap_time format        a15 trunc heading 'Begin Snap Time'
column end_snap_time   format        a15 trunc heading 'End Snap Time'
column ela             format 999,990.99 trunc heading 'Elapsed|Time (min)' just l;
column dbtim           format 999,990.99 trunc heading 'DB time (min)' just l;
column up_time         format 999,990.99 trunc heading 'Instance|Up Time(hrs)' just l;
column version         format        a15       heading 'Release'
column asess           format  99,990.99       heading 'Avg Active|Sessions'
select di.dbid, e.instance_number, di.instance_name, di.host_name
     , to_char(e.startup_time,'DD-Mon-YY HH24:MI') startup_time
     , to_char(b.end_interval_time,'DD-Mon-YY HH24:MI') begin_snap_time
     , to_char(e.end_interval_time,'DD-Mon-YY HH24:MI') end_snap_time
     , di.version
     ,(cast(e.end_interval_time as date)-cast(e.startup_time as date))*24 up_time
     ,(cast(e.end_interval_time as date)-cast(b.end_interval_time as date))*24*60 ela
     , st.value/&ustos/60                                                       dbtim
     , (st.value/&ustos)/
      ((cast(e.end_interval_time as date)-cast(b.end_interval_time as date))*24*3600) asess
  from dba_hist_database_instance di
     , dba_hist_snapshot b
     , dba_hist_snapshot e
     , (select se.dbid
             , se.instance_number
             , ((se.value - nvl(sb.value,0)))  value
          from dba_hist_sys_time_model sb
             , dba_hist_sys_time_model se
         where se.dbid            = :dbid
           and sb.snap_id         = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid
           and se.instance_number = sb.instance_number
           and se.stat_id         = sb.stat_id
           and se.stat_name       = sb.stat_name
           and se.stat_name       = 'DB time')  st
 where di.dbid            = b.dbid
   and di.instance_number = b.instance_number
   and di.startup_time    = b.startup_time
   and b.snap_id          = :bid
   and b.dbid             = e.dbid
   and b.instance_number  = e.instance_number
   and e.snap_id          = :eid
   and e.dbid             = st.dbid
   and e.instance_number  = st.instance_number
   and di.dbid            = :dbid
 order by di.dbid, e.instance_number;

--
--  Error reporting

col warning format a80 heading 'WARNING'

select 'WARNING: An instance was restarted during this interval - Data in the report is invalid' warning
  from dba_hist_snapshot b
     , dba_hist_snapshot e
 where b.snap_id          = :bid
   and b.dbid             = e.dbid
   and b.instance_number  = e.instance_number
   and e.snap_id          = :eid
   and b.dbid             = :dbid
   and e.startup_time    != b.startup_time;

select 'WARNING: number of instances is not equal at begin and end snap' warning
  from dual
 where &bnuminst != &enuminst;



-- ------------------------------------------------------------
-- 
-- Cache Sizes

col instance_number heading 'I#'           format 999
col mt format a21 heading 'Memory Target' just r
col st format a21 heading 'SGA Target'    just r
col bc format a21 heading 'DB Cache'      just r
col sp format a21 heading 'Shared Pool'   just r
col lb format a21 heading 'Log Buffer'    just r
col pt format a21 heading 'PGA Target'    just r

-- memory_target and log_buffer values taken from v$parameter
-- note, checks for mem_target changes, but this should not happen
-- sga_target: use mem_dyn_comp if available, else use parameter
-- default buffer cache and sp: 
--      use mem_dyn_comp if available, 
--      else use larger of parameter and double-underscore
-- pga_aggregate_target
--      use mem_dyn_comp if available
--      else use pgastat if available, else use parameter
-- NOTE: this displays set pat, not actual allocated
select instance_number
     , lpad(case when mt_b > 0 and mt_e > 0
                 then case when mt_b = mt_e
                      then to_char(mt_e/&&btomb,'999,999') || 'M'
                      else ltrim(to_char(mt_b/&&btomb,'999,999')) || 'M/' 
                        || ltrim(to_char(mt_e/&&btomb,'999,999')) || 'M'
                 end
                 else null
            end,21)                     mt
     , lpad(case when sga_b > 0 and sga_b > 0
                 then case when sga_b = sga_e
                      then to_char(sga_e/&&btomb,'999,999') || 'M'
                      else ltrim(to_char(sga_b/&&btomb,'999,999')) || 'M/' 
                        || ltrim(to_char(sga_e/&&btomb,'999,999')) || 'M'
                 end
                 else null
            end,21)                     st
     , lpad(case when bc_b > 0 and bc_e > 0
                 then case when bc_b = bc_e
                      then to_char(bc_e/&&btomb,'999,999') || 'M'
                      else ltrim(to_char(bc_b/&&btomb,'999,999')) || 'M/' 
                        || ltrim(to_char(bc_e/&&btomb,'999,999')) || 'M'
                      end
                  else null
            end,21)                     bc
     , lpad(case when sp_b > 0 and sp_e > 0
                 then case when sp_b = sp_e
                      then to_char(sp_e/&&btomb,'999,999') || 'M'
                      else ltrim(to_char(sp_b/&&btomb,'999,999')) || 'M/' 
                        || ltrim(to_char(sp_e/&&btomb,'999,999')) || 'M'
                      end
                 else null
            end,21)                     sp
     , lpad(to_char(lb_e/&&btomb,'999,999') || 'M',21)     lb
     , lpad(case when pt_b > 0 and pt_e > 0
                 then case when pt_b = pt_e
                      then to_char(pt_e/&&btomb,'999,999') || 'M'
                      else ltrim(to_char(pt_b/&&btomb,'999,999')) || 'M/' 
                        || ltrim(to_char(pt_e/&&btomb,'999,999')) || 'M'
                      end
                 else null
            end,21)                     pt
from ( /* use mem_dyn_comp if available, otherwise get greater of
          parameter setting or double underscore */
  select p.instance_number
       , mt_b
       , mt_e
       , lb_b
       , lb_e
       , case when mdc.sga_b is not null  
              then mdc.sga_b               -- get mem_dyn_comp if avail
              else p.sga_b                 -- else get param setting
         end                                          sga_b 
       , case when mdc.sga_e is not null 
              then mdc.sga_e
              else p.sga_e
         end                                          sga_e 
       , case when mdc.bc_b is not null 
              then mdc.bc_b                -- get mem_dyn_comp if avail
              else greatest(p.bc_b, p.bcu_b) -- else get param or __
         end                                           bc_b
       , case when mdc.bc_e is not null 
              then mdc.bc_e
              else greatest(p.bc_e, p.bcu_e)
         end                                           bc_e
       , case when mdc.sp_b is not null 
              then mdc.sp_b
              else greatest(p.sp_b, p.spu_b)
         end                                           sp_b
       , case when mdc.sp_e is not null 
              then mdc.sp_e
              else greatest(p.sp_e, p.spu_e)
         end                                           sp_e
       , case when mdc.pt_b is not null
              then mdc.pt_b               -- get mem_dyn_comp, if avail
              else nvl(pga.pt_b,p.pt_b)   -- value from pgastat, if available
         end                                           pt_b
       , case when mdc.pt_e is not null
              then mdc.pt_e               -- get mem_dyn_comp, if avail
              else nvl(pga.pt_e,p.pt_e)   -- value from pgastat, if available
         end                                           pt_e
    from ((
     select se.instance_number
          , se.component
          , sb.current_size    bval
          , se.current_size    eval
       from dba_hist_mem_dynamic_comp sb
          , dba_hist_mem_dynamic_comp se
      where se.dbid     = :dbid
        and sb.snap_id  = :bid
        and se.snap_id  = :eid
        and se.dbid     = sb.dbid
        and se.instance_number = sb.instance_number
        and se.component       = sb.component)
      pivot (max(bval) b, max(eval) e
             for component in ( 'SGA Target'   sga
                              , 'DEFAULT buffer cache' bc
                              , 'shared pool'          sp
                              , 'PGA Target'           pt ))) mdc
     , (( select se.instance_number
               , se.parameter_name
               , to_number(sb.value)     bval
               , to_number(se.value)    eval
       from dba_hist_parameter sb
          , dba_hist_parameter se
      where se.dbid     = :dbid
        and sb.snap_id  = :bid
        and se.snap_id  = :eid
        and se.dbid     = sb.dbid
        and se.instance_number = sb.instance_number
        and se.parameter_name  = sb.parameter_name
        and se.parameter_hash  = sb.parameter_hash
        and se.parameter_name in ('memory_target', 'log_buffer'
           , 'sga_target'
           , 'db_cache_size', '__db_cache_size'
           , 'shared_pool_size', '__shared_pool_size'
           , 'pga_aggregate_target'))
      pivot (max(bval) b, max(eval) e
             for parameter_name in ( 'memory_target'   mt
                              , 'log_buffer'           lb
                              , 'sga_target'          sga
                              , 'db_cache_size'        bc
                              , '__db_cache_size'      bcu
                              , 'shared_pool_size'     sp
                              , '__shared_pool_size'   spu
                              , 'pga_aggregate_target' pt))) p
     , ( select se.instance_number
               , sb.value                   pt_b
               , se.value                   pt_e
            from dba_hist_pgastat sb
               , dba_hist_pgastat se
           where se.dbid      = :dbid
             and sb.snap_id   = :bid
             and se.snap_id   = :eid
             and se.dbid      = sb.dbid
             and se.instance_number = sb.instance_number
             and se.name            = sb.name
             and se.name='aggregate PGA target parameter') pga
  where mdc.instance_number (+)= p.instance_number 
    and pga.instance_number (+)= p.instance_number
  )
order by instance_number;

-- ------------------------------------------------------------------

set newpage 3 termout on heading on; 

--
-- OS Statistics


ttitle lef 'OS Stat  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~' -
       skip 1 -
'      Num   CPU   CPU   Load   Load                                                                                            ---- End (if different) ---';

break on report

compute sum of busy_time  on report;
compute sum of idle_time  on report;
compute sum of total_time on report;


col num_cpus    format            999 heading 'CPUs'
col num_cores   format            999 heading 'Cores'
col num_socks   format            999 heading 'Sckts'
col begin_load  format          990.0 heading 'Begin'
col end_load    format          990.0 heading 'End'
col busy_time   format  999,999,990.0 heading 'Busy Time (s)'
col idle_time   format  999,999,990.0 heading 'Idle Time (s)'
col total_time  format  999,999,990.0 heading 'Total time (s)'
col pct_busy    format          990.0 heading '% Busy'
col pct_user    format          990.0 heading '% Usr'
col pct_sys     format          990.0 heading '% Sys'
col pct_wio     format          990.0 heading '% WIO'
col pct_idl     format          990.0 heading '% Idl'
col mem_b       format       99,990.0 heading 'Memory (M)'  just r

col num_cpus_e  format            999 heading 'CPUs'
col num_cores_e format            999 heading 'Cores'
col num_socks_e format            999 heading 'Sckts'
col mem_e       format       99,990.0 heading 'Memory (M)' just l

select instance_number
     , num_cpus_b          num_cpus
     , num_cores_b         num_cores
     , num_socks_b         num_socks
     , load_b              begin_load
     , load_e              end_load
     , 100 * busy_time_v/decode(busy_time_v + idle_time_v,0,null,busy_time_v+idle_time_v)  pct_busy
     , 100 * user_time_v/decode(busy_time_v + idle_time_v,0,null,busy_time_v+idle_time_v)  pct_user
     , 100 * sys_time_v/decode(busy_time_v + idle_time_v,0,null,busy_time_v+idle_time_v)   pct_sys
     , 100 * wio_time_v/decode(busy_time_v + idle_time_v,0,null,busy_time_v+idle_time_v)   pct_wio
     , 100 * idle_time_v/decode(busy_time_v + idle_time_v,0,null,busy_time_v+idle_time_v)  pct_idl
     , busy_time_v/&&cstos                            busy_time
     , idle_time_v/&&cstos                            idle_time
     , (busy_time_v + idle_time_v)/&&cstos            total_time
     , mem_b/&btomb                                   mem_b
     , case when num_cpus_b != num_cpus_e
            then num_cpus_e
            else null
       end                                            num_cpus_e
     , case when num_cores_b != num_cores_e
            then num_cores_e
            else null
       end                                            num_cores_e
     , case when num_socks_b != num_socks_e
            then num_socks_e
            else null
       end                                            num_socks_e
     , case when mem_b != mem_e
            then mem_e/&btomb
            else null
       end                                            mem_e
  from ((select se.instance_number
             , se.stat_name
             , sb.value bval
             , se.value eval
             , (se.value - nvl(sb.value,0))  value
        from dba_hist_osstat sb
           , dba_hist_osstat se
         where se.dbid            = :dbid
           and sb.snap_id    (+)  = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.stat_id         = sb.stat_id         (+))
        pivot (sum(value) v, max(bval) b, max(eval) e 
               for stat_name in (
               'NUM_CPUS'   num_cpus
              ,'NUM_CPU_CORES'   num_cores
              ,'NUM_CPU_SOCKETS' num_socks
              ,'LOAD'       load
              ,'BUSY_TIME'  busy_time
              ,'IDLE_TIME'  idle_time
              ,'USER_TIME'  user_time
              ,'SYS_TIME'   sys_time
              ,'IOWAIT_TIME' wio_time
              ,'PHYSICAL_MEMORY_BYTES'  mem)))
order by instance_number;

clear breaks computes

-- ------------------------------------------------------------
--
--  Wait Classes
--

col usr_io     format  99,999,990.0 heading 'User I/O(s)'
col usr_io_pct format  99,999,990.0 heading 'User I/O'
col sys_io     format  99,999,990.0 heading 'Sys I/O(s)'
col sys_io_pct format  99,999,990.0 heading 'Sys I/O'
col other      format  99,999,990.0 heading 'Other(s)'
col other_pct  format  99,999,990.0 heading 'Other'
col appl       format  99,999,990.0 heading 'Applic (s)'
col appl_pct   format  99,999,990.0 heading 'Applic'
col comm       format  99,999,990.0 heading 'Commit (s)'
col comm_pct   format  99,999,990.0 heading 'Commit'
col netw       format  99,999,990.0 heading 'Network (s)'
col netw_pct   format  99,999,990.0 heading 'Network'
col conc       format  99,999,990.0 heading 'Concurcy (s)'
col conc_pct   format  99,999,990.0 heading 'Concurcy'
col conf       format  99,999,990.0 heading 'Config (s)'
col conf_pct   format  99,999,990.0 heading 'Config'

col clu        format  99,999,990.0 heading 'Cluster (s)'
col clu_pct    format  99,999,990.0 heading 'Cluster'
col db_time    format 999,999,990.0 heading 'DB time'
col dbc        format  99,999,990.0 heading 'DB CPU (s)'
col dbc_pct    format  99,999,990.0 heading 'DB CPU'

--
-- Wait Classes as % of Total Db time

ttitle skip 1 -
       lef 'Foreground Wait Classes -  % of Total DB time ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> Cluster-wide totals of wait class foreground wait times' -
           ' as a percentage of the cluster-wide DB time' -
       skip 2;



col b4 format a4 heading '    '

select '    '   b4
     , sum(usr_io)/decode(:tdbtim,0,null,:tdbtim)*100   usr_io_pct
     , sum(sys_io)/decode(:tdbtim,0,null,:tdbtim)*100   sys_io_pct
     , sum(other) /decode(:tdbtim,0,null,:tdbtim)*100    other_pct
     , sum(appl)  /decode(:tdbtim,0,null,:tdbtim)*100     appl_pct
     , sum(comm)  /decode(:tdbtim,0,null,:tdbtim)*100     comm_pct
     , sum(conc)  /decode(:tdbtim,0,null,:tdbtim)*100     conc_pct
     , sum(conf)  /decode(:tdbtim,0,null,:tdbtim)*100     conf_pct
     , sum(netw)  /decode(:tdbtim,0,null,:tdbtim)*100     netw_pct
     , sum(clu)   /decode(:tdbtim,0,null,:tdbtim)*100      clu_pct
     , sum(dbc)   /decode(:tdbtim,0,null,:tdbtim)*100      dbc_pct
from  (
    select * from (
      select e.instance_number
           , e.wait_class                                 wait_class
           , sum(case when e.time_waited_micro_fg is not null
                  then e.time_waited_micro_fg - nvl(b.time_waited_micro_fg,0)
                  else (e.time_waited_micro - nvl(b.time_waited_micro,0))
                        - greatest(0,(nvl(ebg.time_waited_micro,0) - nvl(bbg.time_waited_micro,0)))
             end)                                             twm
        from dba_hist_system_event b
           , dba_hist_system_event e
           , dba_hist_bg_event_summary bbg
           , dba_hist_bg_event_summary ebg
       where b.snap_id  (+) = :bid
         and e.snap_id      = :eid
         and bbg.snap_id (+) = :bid
         and ebg.snap_id (+) = :eid
         and e.dbid          = :dbid
         and e.dbid            = b.dbid (+)
         and e.instance_number = b.instance_number (+)
         and e.event_id        = b.event_id (+)
         and e.dbid            = ebg.dbid (+)
         and e.instance_number = ebg.instance_number (+)
         and e.event_id        = ebg.event_id (+)
         and e.dbid            = bbg.dbid (+)
         and e.instance_number = bbg.instance_number (+)
         and e.event_id        = bbg.event_id (+)
         and e.total_waits     > nvl(b.total_waits,0)
         and e.wait_class     != 'Idle'
       group by e.wait_class, e.instance_number)
       pivot (sum(twm) for wait_class in (
        'User I/O'             usr_io
      , 'System I/O'           sys_io
      , 'Other'                 other
      , 'Application'            appl
      , 'Commit'                 comm
      , 'Concurrency'            conc
      , 'Configuration'          conf
      , 'Network'                netw
      , 'Cluster'                 clu)) ) s
  , ((select e.instance_number
          , e.stat_name
          , (e.value - nvl(b.value,0))     value
      from dba_hist_sys_time_model e
         , dba_hist_sys_time_model b
     where e.dbid            = :dbid
       and e.dbid            = b.dbid             (+)
       and e.instance_number = b.instance_number  (+)
       and e.snap_id         = :eid
       and b.snap_id    (+)  = :bid               
       and e.stat_id         = b.stat_id          (+)
       and e.stat_name in ('DB time','DB CPU'))
     pivot (sum(value) for stat_name in (
            'DB time'         dbt
          , 'DB CPU'          dbc)) ) st
where s.instance_number = st.instance_number;



ttitle skip 1 -
       lef 'Foreground Wait Classes  '-
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;

-- col dbt noprint
break on report
compute sum avg std of usr_io on report;
compute sum avg std of sys_io on report;
compute sum avg std of other  on report;
compute sum avg std of appl   on report;
compute sum avg std of comm   on report;
compute sum avg std of netw   on report;
compute sum avg std of conc   on report;
compute sum avg std of conf   on report;
compute sum avg std of clu    on report;
compute sum avg std of dbc    on report;
compute sum avg std of db_time on report;


select s.instance_number
     , usr_io/&ustos          usr_io
     , sys_io/&ustos          sys_io
     , other/&ustos            other
     , appl/&ustos              appl
     , comm/&ustos              comm
     , conc/&ustos              conc
     , conf/&ustos              conf
     , netw/&ustos              netw
     , clu/&ustos                clu
     , dbc/&ustos                dbc
     , dbt/&ustos            db_time
  from (
    select * from (
      select e.instance_number
           , e.wait_class                                 wait_class
           , sum(case when e.time_waited_micro_fg is not null
                  then e.time_waited_micro_fg - nvl(b.time_waited_micro_fg,0)
                  else (e.time_waited_micro - nvl(b.time_waited_micro,0))
                        - greatest(0,(nvl(ebg.time_waited_micro,0) - nvl(bbg.time_waited_micro,0)))
             end)                                             twm
        from dba_hist_system_event b
           , dba_hist_system_event e
           , dba_hist_bg_event_summary bbg
           , dba_hist_bg_event_summary ebg
       where b.snap_id  (+) = :bid
         and e.snap_id      = :eid
         and bbg.snap_id (+) = :bid
         and ebg.snap_id (+) = :eid
         and e.dbid          = :dbid
         and e.dbid            = b.dbid (+)
         and e.instance_number = b.instance_number (+)
         and e.event_id        = b.event_id (+)
         and e.dbid            = ebg.dbid (+)
         and e.instance_number = ebg.instance_number (+)
         and e.event_id        = ebg.event_id (+)
         and e.dbid            = bbg.dbid (+)
         and e.instance_number = bbg.instance_number (+)
         and e.event_id        = bbg.event_id (+)
         and e.total_waits     > nvl(b.total_waits,0)
         and e.wait_class     != 'Idle'
       group by e.wait_class, e.instance_number)
       pivot (sum(twm) for wait_class in (
        'User I/O'             usr_io
      , 'System I/O'           sys_io
      , 'Other'                 other
      , 'Application'            appl
      , 'Commit'                 comm
      , 'Concurrency'            conc
      , 'Configuration'          conf
      , 'Network'                netw
      , 'Cluster'                 clu)) ) s
  , ((select e.instance_number
          , e.stat_name
          , (e.value - nvl(b.value,0))     value
      from dba_hist_sys_time_model e
         , dba_hist_sys_time_model b
     where e.dbid            = :dbid
       and e.dbid            = b.dbid             (+)
       and e.instance_number = b.instance_number  (+)
       and e.snap_id         = :eid
       and b.snap_id    (+)  = :bid               
       and e.stat_id         = b.stat_id          (+)
       and e.stat_name in ('DB time','DB CPU'))
     pivot (sum(value) for stat_name in (
            'DB time'         dbt
          , 'DB CPU'          dbc)) ) st
where s.instance_number = st.instance_number
 order by s.instance_number;

clear computes

set newpage 1

ttitle skip 1 -
       lef 'Foreground Wait Classes -  % of DB time ' -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> % of Total DB time - instance DB time as a percentage' -
           ' of the cluster-wide total DB time' -
       skip 2;

compute avg of usr_io_pct  on report;
compute avg of sys_io_pct on report;
compute avg of other_pct  on report;
compute avg of appl_pct   on report;
compute avg of comm_pct   on report;
compute avg of netw_pct   on report;
compute avg of conc_pct   on report;
compute avg of conf_pct   on report;
compute avg of clu_pct    on report;
compute avg of dbc_pct    on report;
col db_time format 99,999,990.0 heading '% Total|DB time'

select s.instance_number
     , usr_io/decode(dbt,0,null,dbt)*100      usr_io_pct
     , sys_io/decode(dbt,0,null,dbt)*100      sys_io_pct
     , other /decode(dbt,0,null,dbt)*100       other_pct
     , appl  /decode(dbt,0,null,dbt)*100        appl_pct
     , comm  /decode(dbt,0,null,dbt)*100        comm_pct
     , conc  /decode(dbt,0,null,dbt)*100        conc_pct
     , conf  /decode(dbt,0,null,dbt)*100        conf_pct
     , netw  /decode(dbt,0,null,dbt)*100        netw_pct
     , clu   /decode(dbt,0,null,dbt)*100         clu_pct
     , dbc   /decode(dbt,0,null,dbt)*100         dbc_pct
     , dbt   /decode(:tdbtim,0,null,:tdbtim)*100 db_time
  from (
    select * from (
      select e.instance_number
           , e.wait_class                                 wait_class
           , sum(case when e.time_waited_micro_fg is not null
                  then e.time_waited_micro_fg - nvl(b.time_waited_micro_fg,0)
                  else (e.time_waited_micro - nvl(b.time_waited_micro,0))
                        - greatest(0,(nvl(ebg.time_waited_micro,0) - nvl(bbg.time_waited_micro,0)))
             end)                                             twm
        from dba_hist_system_event b
           , dba_hist_system_event e
           , dba_hist_bg_event_summary bbg
           , dba_hist_bg_event_summary ebg
       where b.snap_id  (+) = :bid
         and e.snap_id      = :eid
         and bbg.snap_id (+) = :bid
         and ebg.snap_id (+) = :eid
         and e.dbid          = :dbid
         and e.dbid            = b.dbid (+)
         and e.instance_number = b.instance_number (+)
         and e.event_id        = b.event_id (+)
         and e.dbid            = ebg.dbid (+)
         and e.instance_number = ebg.instance_number (+)
         and e.event_id        = ebg.event_id (+)
         and e.dbid            = bbg.dbid (+)
         and e.instance_number = bbg.instance_number (+)
         and e.event_id        = bbg.event_id (+)
         and e.total_waits     > nvl(b.total_waits,0)
         and e.wait_class     != 'Idle'
       group by e.wait_class, e.instance_number)
       pivot (sum(twm) for wait_class in (
        'User I/O'             usr_io
      , 'System I/O'           sys_io
      , 'Other'                 other
      , 'Application'            appl
      , 'Commit'                 comm
      , 'Concurrency'            conc
      , 'Configuration'          conf
      , 'Network'                netw
      , 'Cluster'                 clu)) ) s
  , ((select e.instance_number
          , e.stat_name
          , (e.value - nvl(b.value,0))     value
      from dba_hist_sys_time_model e
         , dba_hist_sys_time_model b
     where e.dbid            = :dbid
       and e.dbid            = b.dbid             (+)
       and e.instance_number = b.instance_number  (+)
       and e.snap_id         = :eid
       and b.snap_id    (+)  = :bid               
       and e.stat_id         = b.stat_id          (+)
       and e.stat_name in ('DB time','DB CPU'))
     pivot (sum(value) for stat_name in (
            'DB time'         dbt
          , 'DB CPU'          dbc)) ) st
where s.instance_number = st.instance_number
 order by s.instance_number;

clear breaks computes

-- ------------------------------------------------------------
set newpage 0
--
-- Time Model Stats
--

ttitle lef 'Time Model ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~' -
       skip 1;

break on report

compute sum avg std of db_cpu  on report;
compute sum avg std of db_time on report;
compute sum avg std of bg_cpu  on report;
compute sum avg std of bg_time on report;
compute sum avg std of sqlexec_time on report;
compute sum avg std of parse_time on report;
compute sum avg std of hparse_time on report;
compute sum avg std of plsql_time on report;
compute sum avg std of java_time on report;

col db_cpu         format 999,999,990.0 heading 'DB CPU (s)'
col db_time        format 999,999,990.0 heading 'DB time (s)'
col bg_cpu         format 999,999,990.0 heading 'bg CPU (s)'
col bg_time        format 999,999,990.0 heading 'bg time (s)'

col sqlexec_time   format 999,999,990.0 heading 'SQL Exec|Ela (s)'
col parse_time     format 999,999,990.0 heading 'Parse Ela (s)'
col hparse_time    format 999,999,990.0 heading 'Hard Parse|Ela (s)'
col plsql_time     format 999,999,990.0 heading 'PL/SQL Ela (s)'
col java_time      format 999,999,990.0 heading 'Java Ela (s)'



select instance_number
     , db_time/&&ustos                            db_time
     , db_cpu/&&ustos                              db_cpu
     , sqlexec_time/&&ustos                  sqlexec_time
     , parse_time/&&ustos                      parse_time
     , hparse_time/&&ustos                    hparse_time
     , (nvl(plsql_time,0) + nvl(plsql_comp,0) + nvl(plsql_inb,0))/&&ustos 
                                               plsql_time
     , java_time/&&ustos                        java_time
     , bg_time/&&ustos                            bg_time
     , bg_cpu/&&ustos                              bg_cpu
  from ((select se.instance_number
             , se.stat_name
             , ((se.value - nvl(sb.value,0)))  value
          from dba_hist_sys_time_model sb
             , dba_hist_sys_time_model se
         where se.dbid            = :dbid
           and sb.snap_id     (+) = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.stat_id         = sb.stat_id         (+))
         pivot (sum(value) for stat_name in (
           'DB time'                               db_time
          ,'DB CPU'                                 db_cpu
          ,'sql execute elapsed time'         sqlexec_time
          ,'parse time elapsed'                 parse_time
          ,'hard parse elapsed time'           hparse_time
          ,'PL/SQL execution elapsed time'      plsql_time
          ,'PL/SQL compilation elapsed time'    plsql_comp
          ,'inbound PL/SQL rpc elapsed time'     plsql_inb
          ,'Java execution elapsed time'         java_time
          ,'background elapsed time'               bg_time
          ,'background cpu time'                    bg_cpu)))
order by instance_number;

set newpage 1

ttitle lef 'Time Model - % of DB time' -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> % Total [DB time|bg time] - instance [DB time|bg time]' -
           ' as a percentage of the cluster-wide total [DB time|bg time]' -
       skip 2;

compute avg of cpu_pct_dbt    on report
compute avg of bg_cpu_pct_dbt on report
compute avg of sql_pct_dbt    on report
compute avg of parse_pct_dbt  on report
compute avg of hparse_pct_dbt on report
compute avg of plsql_pct_dbt  on report
compute avg of java_pct_dbt   on report
compute avg of dbt_pct_tdbt   on report
compute avg of bgt_pct_tbgt   on report

col cpu_pct_dbt    format 999,999,990.0 heading 'DB CPU |%DB time'
col bg_cpu_pct_dbt format 999,999,990.0 heading 'bg CPU |%bg time'
col sql_pct_dbt    format 999,999,990.0 heading 'SQL Exec Ela|%DB time'
col parse_pct_dbt  format 999,999,990.0 heading 'Parse Ela|%DB time'
col hparse_pct_dbt format 999,999,990.0 heading 'Hard Parse|%DB time'
col plsql_pct_dbt  format 999,999,990.0 heading 'PL/SQL Ela|%DB time'
col java_pct_dbt   format 999,999,990.0 heading 'Java Ela|%DB time'
col dbt_pct_tdbt   format 999,999,990.0 heading '% Total|DB time'
col bgt_pct_tbgt   format 999,999,990.0 heading '% Total|bg time'


select instance_number
     , db_time/decode(:tdbtim,0,null,:tdbtim)*100         dbt_pct_tdbt
     , db_cpu/decode(db_time,0,null,db_time)*100          cpu_pct_dbt
     , sqlexec_time/decode(db_time,0,null,db_time)*100    sql_pct_dbt
     , parse_time/decode(db_time,0,null,db_time)*100      parse_pct_dbt
     , hparse_time/decode(db_time,0,null,db_time)*100     hparse_pct_dbt
     , (nvl(plsql_time,0) + nvl(plsql_comp,0) + nvl(plsql_inb,0))/
        (decode(db_time,0,null,db_time)*100)              plsql_pct_dbt
     , java_time/decode(db_time,0,null,db_time)*100       java_pct_dbt
     , bg_time/decode(:tbgtim,0,null,:tbgtim)*100         bgt_pct_tbgt
     , bg_cpu/decode(bg_time,0,null,bg_time)*100          bg_cpu_pct_dbt
  from ((select se.instance_number
             , se.stat_name
             , (se.value - nvl(sb.value,0))  value
          from dba_hist_sys_time_model sb
             , dba_hist_sys_time_model se
         where se.dbid            = :dbid
           and sb.snap_id   (+)   = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.stat_id         = sb.stat_id         (+))
         pivot (sum(value) for stat_name in (
           'DB time'                               db_time
          ,'DB CPU'                                 db_cpu
          ,'sql execute elapsed time'         sqlexec_time
          ,'parse time elapsed'                 parse_time
          ,'hard parse elapsed time'           hparse_time
          ,'PL/SQL execution elapsed time'      plsql_time
          ,'PL/SQL compilation elapsed time'    plsql_comp
          ,'inbound PL/SQL rpc elapsed time'     plsql_inb
          ,'Java execution elapsed time'         java_time
          ,'background elapsed time'               bg_time
          ,'background cpu time'                    bg_cpu)))
order by instance_number;

clear breaks computes


-- ------------------------------------------------------------------

--
-- SysStats
--

set newpage 0

ttitle skip 1 -
       lef 'SysStat  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~'-
       skip 2;

break on report
compute sum avg std of slr      on report
compute sum avg std of slr_ps   on report
compute sum avg std of phyr     on report
compute sum avg std of phyr_ps  on report
compute sum avg std of phyw     on report
compute sum avg std of phyw_ps  on report
compute sum avg std of rdos     on report
compute sum avg std of rdos_ps  on report
compute sum avg std of blkc     on report
compute sum avg std of blkc_ps  on report
compute sum avg std of uc       on report
compute sum avg std of uc_ps    on report
compute sum avg std of ec       on report
compute sum avg std of ec_ps    on report
compute sum avg std of pc       on report
compute sum avg std of pc_ps    on report
compute sum avg std of lc       on report
compute sum avg std of lc_ps    on report
compute avg of slr_pt   on report
compute avg of phyr_pt  on report
compute avg of phyw_pt  on report
compute avg of rdos_pt  on report
compute avg of blkc_pt  on report
compute avg of uc_pt    on report
compute avg of ec_pt    on report
compute avg of pc_pt    on report
compute avg of lc_pt    on report

compute sum avg std of tx       on report
compute sum avg std of tps      on report

col instance_number heading 'I#'           format 999
col slr       heading 'Logical|Reads'      format 99,999,999,999
col slr_ps    heading 'Logical|Reads/s'    format 999,999,990.90
col slr_pt    heading 'Logical|Reads/tx'   format 999,999,990.90
col phyr      heading 'Physical|Reads'     format    999,999,999
col phyr_ps   heading 'Physical|Reads/s'   format    9,999,990.0
col phyr_pt   heading 'Physical|Reads/tx'  format    9,999,990.0
col phyw      heading 'Physical|Writes'    format    999,999,999
col phyw_ps   heading 'Physical|Writes/s'  format    9,999,990.0
col phyw_pt   heading 'Physical|Writes/tx' format    9,999,990.0
col rdow      heading 'Redo Writes'        format    999,999,999
col rdow_ps   heading 'Redo |Wrtes/s'      format    9,999,990.0
col rdow_pt   heading 'Redo |Writes/tx'    format    9,999,990.0
col rdos      heading 'Redo|Size (k)'      format    999,999,999
col rdos_ps   heading 'Redo|Size (k)/s'    format    9,999,990.0
col rdos_pt   heading 'Redo|Size (k)/tx'   format    9,999,990.0
col blkc      heading 'Block|Changes'      format    999,999,999
col blkc_ps   heading 'Block|Changes/s'    format    9,999,990.0
col blkc_pt   heading 'Block|Changes/tx'   format    9,999,990.0
col uc        heading 'User|Calls'         format    999,999,999
col uc_ps     heading 'User|Calls/s'       format    9,999,990.0
col uc_pt     heading 'User|Calls/tx'      format    9,999,990.0
col ec        heading 'Execs'              format    999,999,999
col ec_ps     heading 'Execs/s'            format    9,999,990.0
col ec_pt     heading 'Execs/tx'           format    9,999,990.0
col pc        heading 'Parses'             format    999,999,999
col pc_ps     heading 'Parses/s'           format    9,999,990.0
col pc_pt     heading 'Parses/tx'          format    9,999,990.0
col lc        heading 'Logons'             format      9,999,999
col lc_ps     heading 'Logons/s'           format      99,990.90
col lc_pt     heading 'Logons/tx'          format      99,990.90
col s_et      heading 'Elapsed (s)'        noprint
-- col s_et      heading 'Elapsed (s)'     
col tx        heading 'Txns'               format    999,999,999
col tps       heading 'Txns/s'             format    9,999,990.0

select instance_number
     , slr
     , phyr
     , phyw
     , rdos/&btokb   rdos
     , blkc
     , uc
     , ec
     , pc
     , lc
     , ucom+urol tx
  from ((select se.instance_number
             , se.stat_name
             , (se.value - nvl(sb.value,0)) value
          from dba_hist_sysstat sb
             , dba_hist_sysstat se
         where se.dbid            = :dbid
           and sb.snap_id     (+) = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.stat_id         = sb.stat_id         (+)
           and se.stat_name in
                 ( 'session logical reads', 'physical reads'
                 , 'physical writes'
                 , 'db block changes'
                 , 'user calls', 'execute count'
                 , 'redo size', 'parse count (total)'
                 , 'logons cumulative'
                 , 'user commits','user rollbacks'
                 ))
         pivot (sum(value) for stat_name in (
                'session logical reads'     slr
               ,'physical reads'           phyr
               ,'physical writes'          phyw
               ,'redo size'                rdos
               ,'db block changes'         blkc
               ,'user calls'                 uc
               ,'execute count'              ec
               ,'parse count (total)'        pc
               ,'logons cumulative'          lc
               ,'user commits'             ucom
               ,'user rollbacks'           urol)))
 order by instance_number;

set newpage 1

ttitle lef 'SysStat per Sec '-
       skip 1 -
           '~~~~~~~~~~~~~~~' -
       skip 2;

select st.instance_number
     , slr/s_et  slr_ps
     , phyr/s_et phyr_ps
     , phyw/s_et phyw_ps
     , rdos/&btokb/s_et rdos_ps
     , blkc/s_et blkc_ps
     , uc/s_et   uc_ps
     , ec/s_et   ec_ps
     , pc/s_et   pc_ps
     , lc/s_et   lc_ps
     , (ucom+urol)/s_et  tps
     , s_et
  from ((select se.instance_number
             , se.stat_name
             , (se.value - nvl(sb.value,0)) value
          from dba_hist_sysstat sb
             , dba_hist_sysstat se
         where se.dbid            = :dbid
           and sb.snap_id    (+)  = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.stat_id         = sb.stat_id         (+)
           and se.stat_name in
                 ( 'session logical reads', 'physical reads'
                 , 'physical writes'
                 , 'db block changes'
                 , 'user calls', 'execute count'
                 , 'redo size', 'parse count (total)'
                 , 'logons cumulative'
                 , 'user commits','user rollbacks'
                 ))
         pivot (sum(value) for stat_name in (
                'session logical reads'     slr
               ,'physical reads'           phyr
               ,'physical writes'          phyw
               ,'redo size'                rdos
               ,'db block changes'         blkc
               ,'user calls'                 uc
               ,'execute count'              ec
               ,'parse count (total)'        pc
               ,'logons cumulative'          lc
               ,'user commits'             ucom
               ,'user rollbacks'           urol))) st
     , (select e.instance_number 
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)                      s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where st.instance_number = s.instance_number
 order by st.instance_number;

-- 
-- Per Tx

ttitle lef 'SysStat per Tx '-
       skip 1 -
           '~~~~~~~~~~~~~~' -
       skip 2;

select instance_number
     , slr/decode((ucom+urol),0,1,(ucom+urol))  slr_pt
     , phyr/decode((ucom+urol),0,1,(ucom+urol)) phyr_pt
     , phyw/decode((ucom+urol),0,1,(ucom+urol)) phyw_pt
     , rdos/&btokb/decode((ucom+urol),0,1,(ucom+urol)) rdos_pt
     , blkc/decode((ucom+urol),0,1,(ucom+urol)) blkc_pt
     , uc/decode((ucom+urol),0,1,(ucom+urol))   uc_pt
     , ec/decode((ucom+urol),0,1,(ucom+urol))   ec_pt
     , pc/decode((ucom+urol),0,1,(ucom+urol))   pc_pt
     , lc/decode((ucom+urol),0,1,(ucom+urol))   lc_pt
  from ((select se.instance_number
             , se.stat_name
             , (se.value - nvl(sb.value,0)) value
          from dba_hist_sysstat sb
             , dba_hist_sysstat se
         where se.dbid            = :dbid
           and sb.snap_id     (+) = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid             (+)
           and se.instance_number = sb.instance_number  (+)
           and se.stat_id         = sb.stat_id          (+)
           and se.stat_name in
                 ( 'session logical reads', 'physical reads'
                 , 'physical writes'
                 , 'db block changes'
                 , 'user calls', 'execute count'
                 , 'redo size', 'parse count (total)'
                 , 'logons cumulative'
                 , 'user commits','user rollbacks'
                 ))
         pivot (sum(value) for stat_name in (
                'session logical reads'     slr
               ,'physical reads'           phyr
               ,'physical writes'          phyw
               ,'redo size'                rdos
               ,'db block changes'         blkc
               ,'user calls'                 uc
               ,'execute count'              ec
               ,'parse count (total)'        pc
               ,'logons cumulative'          lc
               ,'user commits'             ucom
               ,'user rollbacks'           urol)))
 order by instance_number;

clear breaks computes

-- ------------------------------------------------------------------
-- 
-- GC Summaries
--

set newpage 0;

ttitle skip 1 -
       'Global Cache Efficiency Percentages  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2 -
'     ------ Buffer Access --------' -
       skip 1;

col lc  format 999,990.90 heading 'Local %'
col rc  format 9990.90 heading 'Remote %'
col dsk format 9990.90 heading 'Disk %'

select st.instance_number
     , (100*(1-(phyrc + gccrrv + gccurv)/(cgfc+dbfc)))   lc
     , (100*(gccurv+gccrrv)/(cgfc+dbfc))                 rc
     , (100*phyrc/(cgfc+dbfc))                           dsk
  from ((select se.instance_number
              , se.stat_name
              , (se.value - nvl(sb.value,0))          value
           from dba_hist_sysstat sb
              , dba_hist_sysstat se
          where se.dbid            = :dbid
            and sb.snap_id    (+)  = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid            (+)
            and se.instance_number = sb.instance_number (+)
            and se.stat_id         = sb.stat_id         (+)
            and se.stat_name in
                ( 'gc cr blocks received', 'gc current blocks received'
                , 'physical reads cache'
                , 'consistent gets from cache', 'db block gets from cache'
                ))
           pivot (sum(value) for stat_name in (
                 'gc cr blocks received'          gccrrv
               , 'gc current blocks received'     gccurv
               , 'physical reads cache'            phyrc
               , 'consistent gets from cache'       cgfc
               , 'db block gets from cache'         dbfc))) st
  order by instance_number;


set newpage 1

ttitle 'Global Cache and Enqueue Workload Characteristics'-
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'-
       skip 2 -
'             ---------------- CR Blocks ------------------- ------------- Current Blocks ----------------' -
       skip 1 -
'      GE Get |---------- Time (ms) -------------| Log Flush |---------- Time (ms) ------------| Log Flush' -
       skip 1;

col gegt    format 99990.0 heading 'Tm(ms)'
col gccrrt  format 99990.0 heading 'Receive'
col gccurt  format 99990.0 heading 'Receive'
col gccrbt  format 99990.0 heading 'Build'
col gccrst  format 99990.0 heading 'Send'
col gccrft  format 99990.0 heading 'Flush'
col gccrflp format 99990.0 heading 'CR Srvd %'
col gccupt  format 99990.0 heading 'Pin'
col gccust  format 99990.0 heading 'Send'
col gccuft  format 99990.0 heading 'Flush'
col gccuflp format 999990.0 heading 'CU Srvd%'

select st.instance_number
     , glgt*&cstoms/decode((glag+glsg),0,null,(glag+glsg))   gegt
     , gccrrt*&cstoms/decode(gccrrv,0,null,gccrrv)         gccrrt
     , gccrbt*&cstoms/decode(gccrsv,0,null,gccrsv)         gccrbt
     , gccrst*&cstoms/decode(gccrsv,0,null,gccrsv)         gccrst
     , gccrft*&cstoms/decode(gccrfl,0,null,gccrfl)         gccrft
     , gccrfl        /decode(gccrsv,0,null,gccrsv)*100    gccrflp
     , gccurt*&cstoms/decode(gccurv,0,null,gccurv)         gccurt
     , gccupt*&cstoms/decode(gccusv,0,null,gccusv)         gccupt
     , gccust*&cstoms/decode(gccusv,0,null,gccusv)         gccust
     , gccuft*&cstoms/decode(gccufl,0,null,gccufl)         gccuft
     , gccufl        /decode(gccusv,0,null,gccusv)*100    gccuflp
  from ((select se.instance_number
              , se.stat_name
              , (se.value - nvl(sb.value,0)) value
           from dba_hist_sysstat sb
              , dba_hist_sysstat se
          where se.dbid            = :dbid
            and sb.snap_id     (+) = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid            (+)
            and se.instance_number = sb.instance_number (+)
            and se.stat_id         = sb.stat_id         (+)
            and se.stat_name in
                ( 'gc cr blocks received', 'gc cr block receive time'
                , 'gc current blocks received', 'gc current block receive time'
                , 'gc cr blocks served', 'gc cr block build time'
                , 'gc cr block flush time', 'gc cr block send time'
                , 'gc current block pin time', 'gc current blocks served' 
                , 'gc current block send time', 'gc current block flush time'
                , 'global enqueue get time'
                , 'global enqueue gets sync', 'global enqueue gets async'
                ))
           pivot (sum(value) for stat_name in (
                 'gc cr blocks received'               gccrrv
               , 'gc cr block receive time'            gccrrt
               , 'gc current blocks received'          gccurv
               , 'gc current block receive time'       gccurt
               , 'gc cr blocks served'                 gccrsv
               , 'gc cr block build time'              gccrbt
               , 'gc cr block send time'               gccrst
               , 'gc cr block flush time'              gccrft
               , 'gc current blocks served'            gccusv
               , 'gc current block pin time'           gccupt
               , 'gc current block send time'          gccust
               , 'gc current block flush time'         gccuft
               , 'global enqueue get time'               glgt
               , 'global enqueue gets sync'              glsg
               , 'global enqueue gets async'             glag)) ) st
     , ( select e.instance_number
              , sum(e.flushes - b.flushes)    gccrfl
           from dba_hist_cr_block_server b
              , dba_hist_cr_block_server e
          where b.snap_id          = :bid
            and e.snap_id          = :eid
            and e.dbid             = :dbid
            and e.dbid             = b.dbid
            and b.instance_number  = e.instance_number
          group by e.instance_number) crfl
     , ( select e.instance_number
              , sum((e.flush1+e.flush10+e.flush100+e.flush1000+e.flush10000) 
                             - (b.flush1+b.flush10+b.flush100+b.flush1000+b.flush10000)) gccufl
           from dba_hist_current_block_server b
              , dba_hist_current_block_server e
           where b.snap_id          = :bid
            and e.snap_id          = :eid
            and e.dbid             = :dbid
            and e.dbid             = b.dbid
            and b.instance_number  = e.instance_number
          group by e.instance_number)     cufl
 where st.instance_number = crfl.instance_number
   and st.instance_number = cufl.instance_number
 order by instance_number;


ttitle 'Global Cache and Enqueue Messaging Statistics' -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2 -
'     ----- Queue Time (ms)----- -- Process Time-- ----- % Messages Sent ------'

col msgsqt  format 99990.0   heading 'Sent'
col msgsqtk format 99990.0   heading 'on ksxp'
col msgrqt  format 99990.0   heading 'Received'
col pmpt    format 99990.0   heading 'GCS msgs'
col npmpt   format 99990.0   heading 'GES msgs'
col dmsdp   format 9990.90  heading 'Direct'
col dmsip   format 9990.90  heading 'Indirect'
col dmfcp   format 9990.90  heading 'Flow Ctrl '

select st.instance_number
     , msgsqt /decode(msgsq,0,null,msgsq)                          msgsqt
     , msgsqtk/decode(msgsqk,0,null,msgsqk)                       msgsqtk
     , msgrqt /decode(msgrq,0,null,msgrq)                          msgrqt
     , pmpt   /decode(pmrv,0,null,pmrv)                              pmpt
     , npmpt  /decode(npmrv,0,null,npmrv)                           npmpt
     , 100*dmsd/decode((dmsd+dmsi+dmfc),0,null,(dmsd+dmsi+dmfc))    dmsdp
     , 100*dmsi/decode((dmsd+dmsi+dmfc),0,null,(dmsd+dmsi+dmfc))    dmsip
     , 100*dmfc/decode((dmsd+dmsi+dmfc),0,null,(dmsd+dmsi+dmfc))    dmfcp
  from ((select se.instance_number
              , se.name
              , (se.value - nvl(sb.value,0))    value
           from dba_hist_dlm_misc sb
              , dba_hist_dlm_misc se
          where se.dbid            = :dbid
            and sb.snap_id    (+)  = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid             (+)
            and se.instance_number = sb.instance_number  (+)
            and se.statistic#      = sb.statistic#       (+)
            and se.name            = sb.name             (+)
            and se.name in ( 'msgs sent queued', 'msgs sent queue time (ms)'
                , 'msgs sent queue time on ksxp (ms)', 'msgs sent queued on ksxp'
                , 'msgs received queue time (ms)', 'msgs received queued' 
                , 'gcs msgs received', 'gcs msgs process time(ms)'
                , 'ges msgs received', 'ges msgs process time(ms)'
                , 'messages sent directly', 'messages sent indirectly'
                , 'messages flow controlled'
                ))
           pivot (sum(value) for name in (
                 'msgs sent queued'                        msgsq
               , 'msgs sent queue time (ms)'              msgsqt
               , 'msgs sent queue time on ksxp (ms)'     msgsqtk
               , 'msgs sent queued on ksxp'               msgsqk
               , 'msgs received queue time (ms)'          msgrqt
               , 'msgs received queued'                    msgrq
               , 'gcs msgs received'                        pmrv
               , 'gcs msgs process time(ms)'                pmpt
               , 'ges msgs received'                       npmrv
               , 'ges msgs process time(ms)'               npmpt
               , 'messages sent directly'                   dmsd
               , 'messages sent indirectly'                 dmsi
               , 'messages flow controlled'                 dmfc))) st
 order by instance_number;

-- ------------------------------------------------------------------

set newpage 0
--
-- RAC
--

ttitle skip 1 -
       lef 'SysStat and GE Misc - RAC '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;

break on report
compute sum avg std of gccrr     on report
compute sum avg std of gccrr_ps  on report
compute sum avg std of gccrs     on report
compute sum avg std of gccrs_ps  on report
compute sum avg std of gccur     on report
compute sum avg std of gccur_ps  on report
compute sum avg std of gccus     on report
compute sum avg std of gccus_ps  on report
compute sum avg std of gccpu     on report
compute sum avg std of ipccpu_ps on report
compute sum avg std of ipccpu    on report
compute sum avg std of gccpu_ps  on report
compute sum avg std of gcms      on report
compute sum avg std of gcms_ps   on report
compute sum avg std of gems      on report
compute sum avg std of gems_ps   on report
compute sum avg std of mra      on report
compute sum avg std of mra_ps   on report
compute sum avg std of msd      on report
compute sum avg std of msd_ps   on report
compute sum avg std of msi      on report
compute sum avg std of msi_ps   on report
compute sum avg std of gcl      on report
compute sum avg std of gcl_ps   on report
compute sum avg std of gcf      on report
compute sum avg std of gcf_ps   on report

compute avg of gccrr_pt  on report
compute avg of gccrs_pt  on report
compute avg of gccur_pt  on report
compute avg of gccus_pt  on report
compute avg of ipccpu_pt on report
compute avg of gccpu_pt  on report
compute avg of gcms_pt   on report
compute avg of gems_pt   on report
compute avg of mra_pt   on report
compute avg of msd_pt   on report
compute avg of msi_pt   on report
compute avg of gcl_pt   on report
compute avg of gcf_pt   on report

col gccrr     heading 'GC CR|Blocks|Received'            format     99,999,990
col gccrr_ps  heading 'GC CR|Blocks|Received/s'          format     999,990.90
col gccrs     heading 'GC CR|Blocks|Served'              format     99,999,990
col gccrs_ps  heading 'GC CR|Blocks|Served/s'            format     999,990.90
col gccur     heading 'GC Current|Blocks|Received'       format     99,999,990
col gccur_ps  heading 'GC Current|Blocks|Received/s'     format     999,990.90
col gccus     heading 'GC Current|Blocks|Served'         format     99,999,990
col gccus_ps  heading 'GC Current|Blocks|Served/s'       format     999,990.90
col gccpu     heading 'GC CPU (s)'                       format      9,999,990
col gccpu_ps  heading 'GC|CPU(s) /s'                     format      99,990.90
col ipccpu    heading 'IPC|CPU (s)'                      format      9,999,990
col ipccpu_ps heading 'IPC|CPU (s)/s'                    format      99,990.90
col gcms      heading 'GC Messages|Sent'                 format  9,999,999,990
col gcms_ps   heading 'GC Messages|Sent/s'               format  99,999,990.90
col gems      heading 'GE Messages|Sent'                 format     99,999,990
col gems_ps   heading 'GE Messages|Sent/s'               format     999,990.90
col mra       heading 'Msgs Rcvd|Actual'                 format    999,999,990
col mra_ps    heading 'Msgs Rcvd|Actual/s'               format    9,999,990.0
col msd       heading 'Msgs Sent|Direct'                 format    999,999,990
col msd_ps    heading 'Msgs Sent|Direct/s'               format    9,999,990.0
col msi       heading 'Msgs Sent|Indirect'               format     99,999,990
col msi_ps    heading 'Msgs Sent|Indirect/s'             format     999,990.90

col gcl       heading 'GC Blks|Lost'                     format       99,990
col gcl_ps    heading 'GC Blks|Lost/s'                   format        990.0
col gcf       heading 'GC CR|Failure'                    format      999,990
col gcf_ps    heading 'GC CR|Fail/s'                     format      9,990.0

col gccrr_pt  heading 'GC CR|Blocks|Received/tx'         format     999,990.90
col gccrs_pt  heading 'GC CR|Blocks|Served/tx'           format     999,990.90
col gccur_pt  heading 'GC Current|Blocks|Received/tx'    format     999,990.90
col gccus_pt  heading 'GC Current|Blocks|Served/tx'      format     999,990.90
col gccpu_pt  heading 'GC|CPU (s)/tx'                    format      99,990.90
col ipccpu_pt heading 'IPC|CPU (s)/tx'                   format      99,990.90
col gcms_pt   heading 'GC Messages|Sent/tx'              format  99,999,990.90
col gems_pt   heading 'GE Messages|Sent/tx'              format     999,990.90
col mra_pt    heading 'Msgs Rcvd|Actual/tx'              format    9,999,990.0
col msd_pt    heading 'Msgs Sent|Direct/tx'              format    9,999,990.0
col msi_pt    heading 'Msgs Sent|Indirect/tx'            format     999,990.90
col gcl_pt    heading 'GC Blks|Lost/tx'                  format          990.0
col gcf_pt    heading 'GC CR|Fail|/tx'                   format        9,990.0

/* check stat for gc current cr failure */
select ss.instance_number
     , gccur
     , gccrr
     , gccus
     , gccrs
     , gccpu/&&cstos          gccpu
     , ipccpu/&&cstos         ipccpu
     , gcms
     , gems
     , nvl(mra,0)            mra
     , nvl(msd,0)            msd
     , nvl(msi,0)            msi
     , nvl(gcl,0)            gcl
     , nvl(gcf,0)            gcf
  from (( select se.instance_number
              , se.stat_name
              , (se.value - nvl(sb.value,0))   value
           from dba_hist_sysstat sb
              , dba_hist_sysstat se
          where se.dbid            = :dbid
            and sb.snap_id     (+) = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid            (+)
            and se.instance_number = sb.instance_number (+)
            and se.stat_id         = sb.stat_id         (+)
            and se.stat_name in
                ( 'gc cr blocks received','gc current blocks received'
                , 'gc cr blocks served','gc current blocks served'
                , 'gc CPU used by this session', 'IPC CPU used by this session'
                , 'gcs messages sent', 'ges messages sent'
                , 'gc blocks lost'
                ))
         pivot (sum(value) for stat_name in (
               'gc current blocks received'            gccur
              , 'gc cr blocks received'                gccrr
              , 'gc current blocks served'             gccus
              , 'gc cr blocks served'                  gccrs
              , 'gc CPU used by this session'          gccpu
              , 'IPC CPU used by this session'         ipccpu
              , 'gcs messages sent'                    gcms
              , 'ges messages sent'                    gems
              , 'gc blocks lost'                       gcl))) ss
     , ((select se.instance_number
              , se.name
              , (se.value - nvl(sb.value,0)) value
          from dba_hist_dlm_misc sb 
             , dba_hist_dlm_misc se
         where se.dbid            = :dbid
           and sb.snap_id    (+)  = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.statistic#      = sb.statistic#      (+)
           and se.name in ('messages received actual', 'messages sent directly', 'messages sent indirectly'))
         pivot (sum(value) for name in (
               'messages received actual'    mra
             , 'messages sent directly'      msd
             , 'messages sent indirectly'    msi))) dlm
     , ( select se.instance_number
              , sum(se.total_waits - nvl(sb.total_waits,0))    gcf
           from dba_hist_system_event se
              , dba_hist_system_event sb
          where se.dbid            = :dbid
            and sb.snap_id     (+) = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid            (+)
            and se.instance_number = sb.instance_number (+)
            and se.event_id        = sb.event_id        (+)
            and se.event_name      = 'gc cr failure'
          group by se.instance_number
        ) sw
  where dlm.instance_number (+) = ss.instance_number
    and sw.instance_number  (+) = ss.instance_number
  order by ss.instance_number;



set newpage 1
ttitle skip 1 -
       lef 'SysStat and GE Misc (per Sec) - RAC '-
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;

select ss.instance_number
     , gccur/s_et  gccur_ps
     , gccrr/s_et  gccrr_ps
     , gccus/s_et  gccus_ps
     , gccrs/s_et  gccrs_ps
     , gccpu/&cstos/s_et  gccpu_ps
     , ipccpu/&cstos/s_et ipccpu_ps
     , gcms/s_et   gcms_ps
     , gems/s_et   gems_ps
     , nvl(mra,0)/s_et    mra_ps
     , nvl(msd,0)/s_et    msd_ps
     , nvl(msi,0)/s_et    msi_ps
     , nvl(gcl,0)/s_et    gcl_ps
     , nvl(gcf,0)/s_et    gcf_ps
  from ((select se.instance_number
              , se.stat_name
              , (se.value - nvl(sb.value,0))   value
           from dba_hist_sysstat sb
              , dba_hist_sysstat se
          where se.dbid            = :dbid
            and sb.snap_id   (+)   = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid             (+)
            and se.instance_number = sb.instance_number  (+)
            and se.stat_id         = sb.stat_id          (+)
            and se.stat_name in
                ( 'gc cr blocks received','gc current blocks received'
                , 'gc cr blocks served','gc current blocks served'
                , 'gc CPU used by this session', 'IPC CPU used by this session'
                , 'gcs messages sent', 'ges messages sent'
                , 'gc blocks lost'
                ))
         pivot (sum(value) for stat_name in (
               'gc current blocks received'            gccur
              , 'gc cr blocks received'                gccrr
              , 'gc current blocks served'             gccus
              , 'gc cr blocks served'                  gccrs
              , 'gc CPU used by this session'          gccpu
              , 'IPC CPU used by this session'         ipccpu
              , 'gcs messages sent'                    gcms
              , 'ges messages sent'                    gems
              , 'gc blocks lost'                       gcl))) ss
     , ((select se.instance_number
              , se.name
              , (se.value - nvl(sb.value,0)) value
          from dba_hist_dlm_misc sb
             , dba_hist_dlm_misc se
         where se.dbid            = :dbid
           and sb.snap_id   (+)   = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid            (+)
           and se.instance_number = sb.instance_number (+)
           and se.statistic#      = sb.statistic#      (+)
           and se.name in ('messages received actual', 'messages sent directly', 'messages sent indirectly'))
         pivot (sum(value) for name in (
               'messages received actual'    mra
             , 'messages sent directly'      msd
             , 'messages sent indirectly'    msi))) dlm
     , ( select se.instance_number
              , sum(se.total_waits - nvl(sb.total_waits,0))    gcf
           from dba_hist_system_event se
              , dba_hist_system_event sb
          where se.dbid            = :dbid
            and sb.snap_id    (+)  = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid              (+)
            and se.instance_number = sb.instance_number   (+)
            and se.event_id        = sb.event_id          (+)
            and se.event_name = 'gc cr failure'
          group by se.instance_number
        ) sw
     , (select e.instance_number 
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)          s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where ss.instance_number = s.instance_number (+)
   and dlm.instance_number (+)= ss.instance_number
   and sw.instance_number  (+)= ss.instance_number
 order by ss.instance_number;

ttitle skip 1 -
       lef 'SysStat and GE Misc (per Tx) - RAC '-
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;

select ss.instance_number
     , gccur/decode((ucm+ur),0,1,(ucm+ur))  gccur_pt
     , gccrr/decode((ucm+ur),0,1,(ucm+ur))  gccrr_pt
     , gccus/decode((ucm+ur),0,1,(ucm+ur))  gccus_pt
     , gccrs/decode((ucm+ur),0,1,(ucm+ur))  gccrs_pt
     , gccpu/&cstos/decode((ucm+ur),0,1,(ucm+ur))  gccpu_pt
     , ipccpu/&cstos/decode((ucm+ur),0,1,(ucm+ur)) ipccpu_pt
     , gcms/decode((ucm+ur),0,1,(ucm+ur))   gcms_pt
     , gems/decode((ucm+ur),0,1,(ucm+ur))   gems_pt
     , nvl(mra,0)/decode((ucm+ur),0,1,(ucm+ur))    mra_pt
     , nvl(msd,0)/decode((ucm+ur),0,1,(ucm+ur))    msd_pt
     , nvl(msi,0)/decode((ucm+ur),0,1,(ucm+ur))    msi_pt
     , nvl(gcl,0)/decode((ucm+ur),0,1,(ucm+ur))    gcl_pt
     , nvl(gcf,0)/decode((ucm+ur),0,1,(ucm+ur))    gcf_pt
  from ((select se.instance_number
              , se.stat_name
              , (se.value - nvl(sb.value,0))   value
           from dba_hist_sysstat sb
              , dba_hist_sysstat se
          where se.dbid            = :dbid
            and sb.snap_id    (+)  = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid            (+)
            and se.instance_number = sb.instance_number (+)
            and se.stat_id         = sb.stat_id         (+)
            and se.stat_name in
                ( 'gc cr blocks received','gc current blocks received'
                , 'gc cr blocks served','gc current blocks served'
                , 'gc CPU used by this session', 'IPC CPU used by this session'
                , 'gcs messages sent', 'ges messages sent'
                , 'gc blocks lost'
                , 'user commits', 'user rollbacks'
                ))
         pivot (sum(value) for stat_name in (
                'gc current blocks received'           gccur
              , 'gc cr blocks received'                gccrr
              , 'gc current blocks served'             gccus
              , 'gc cr blocks served'                  gccrs
              , 'gc CPU used by this session'          gccpu
              , 'IPC CPU used by this session'         ipccpu
              , 'gcs messages sent'                    gcms
              , 'ges messages sent'                    gems
              , 'gc blocks lost'                       gcl
              , 'user commits'                         ucm
              , 'user rollbacks'                       ur))) ss
     , ((select se.instance_number
              , se.name
              , (se.value - nvl(sb.value,0)) value
          from dba_hist_dlm_misc sb
             , dba_hist_dlm_misc se
         where se.dbid            = :dbid
           and sb.snap_id    (+)  = :bid
           and se.snap_id         = :eid
           and se.dbid            = sb.dbid             (+)
           and se.instance_number = sb.instance_number  (+)
           and se.statistic#      = sb.statistic#       (+)
           and se.name in ('messages received actual', 'messages sent directly', 'messages sent indirectly'))
         pivot (sum(value) for name in (
               'messages received actual'    mra
             , 'messages sent directly'      msd
             , 'messages sent indirectly'    msi))) dlm
     , ( select se.instance_number
              , sum(se.total_waits - nvl(sb.total_waits,0))    gcf
           from dba_hist_system_event se
              , dba_hist_system_event sb
          where se.dbid            = :dbid
            and sb.snap_id   (+)   = :bid
            and se.snap_id         = :eid
            and se.dbid            = sb.dbid              (+)
            and se.instance_number = sb.instance_number   (+)
            and se.event_id        = sb.event_id          (+)
            and se.event_name      = 'gc cr failure'
          group by se.instance_number
        ) sw
 where ss.instance_number = dlm.instance_number (+)
   and ss.instance_number = sw.instance_number  (+)
 order by ss.instance_number;

clear breaks computes
-- ------------------------------------------------------------

set newpage 0;
--
-- CR Server

repfooter off

ttitle skip 1 -
       'CR Blocks Served Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;

break on report

compute sum avg std of gccr on report
compute sum avg std of gccu on report
compute sum avg std of dr   on report
compute sum avg std of ur   on report
compute sum avg std of tr   on report
compute sum avg std of cr   on report
compute sum avg std of pr   on report
compute sum avg std of zr   on report
compute sum avg std of drr  on report
compute sum avg std of fr   on report
compute sum avg std of fdc  on report
compute sum avg std of fc   on report
compute sum avg std of fge  on report
compute sum avg std of fls  on report
compute sum avg std of fq   on report
compute sum avg std of fqf  on report
compute sum avg std of fmt  on report
compute sum avg std of lw   on report
compute sum avg std of er   on report

col gccr format 99,999,990 heading 'CR Block|Requests'
col gccu format 99,999,990 heading 'CU Block|Requests'
col dr   format 99,999,990 heading 'Data Block|Requests'
col ur   format    999,990 heading 'Undo|Requests'
col tr   format 99,999,990 heading 'TX Block|Requests'
col cr   format 99,999,990 heading 'Current|Results'
col pr   format     99,990 heading 'Priv|Res'
col zr   format  9,999,990 heading 'Zero|Results'
col drr  format     99,990 heading 'Dsk Rd|Res'
col fr   format     99,990 heading 'Fail|Res'
col fdc  format  9,999,990 heading 'Fairness|Down Conv'
col fc   format    999,990 heading 'Fairness|Clears'
col fge  format    999,990 heading 'FreeGC|Elems'
col fls  format  9,999,990 heading 'Flushes'
col fq   format     99,990 heading 'Flush|Queued'
col fqf  format      9,990 heading 'Flush|QFull'
col fmt  format      9,990 heading 'Flush|MaxTm'  
col lw   format    999,990 heading 'Light|Works'
col er   format        990 heading 'Errs'

select e.instance_number
     , sum(e.cr_requests - b.cr_requests)            gccr
     , sum(e.current_requests - b.current_requests)  gccu
     , sum(e.data_requests - b.data_requests)          dr
     , sum(e.undo_requests - b.undo_requests)          ur
     , sum(e.tx_requests   - b.tx_requests)            tr
     , sum(e.current_results - b.current_results)      cr
     , sum(e.private_results - b.private_results)      pr
     , sum(e.zero_results    - b.zero_results)         zr
     , sum(e.disk_read_results - b.disk_read_results) drr
     , sum(e.fail_results    - b.fail_results)         fr
     , sum(e.fairness_down_converts - b.fairness_down_converts) fdc
     , sum(e.fairness_clears - b.fairness_clears)      fc
     , sum(e.free_gc_elements - b.free_gc_elements)   fge
     , sum(e.flushes - b.flushes)                     fls
     , sum(e.flushes_queued - b.flushes_queued)        fq
     , sum(e.flush_queue_full - b.flush_queue_full)   fqf
     , sum(e.flush_max_time   - b.flush_max_time)     fmt
     , sum(e.light_works      - b.light_works)         lw
     , sum(e.errors           - b.errors)              er
  from dba_hist_cr_block_server b
     , dba_hist_cr_block_server e
 where b.snap_id          = :bid
   and e.snap_id          = :eid
   and e.dbid             = :dbid
   and e.dbid             = b.dbid
   and b.instance_number  = e.instance_number
 group by e.instance_number
 order by e.instance_number; 


-- 
-- Current Block Server

set newpage 1

ttitle skip 1 -
       'Current Blocks Served Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2;


break on report
compute  sum avg std of pins    on report
compute  sum avg std of flushes on report
compute  sum avg std of writes  on report

col pins       heading Pins       format 99,999,990
col flushes    heading Flushes    format 99,999,990
col writes     heading Writes     format 99,999,990
col pin1       heading '% <1ms'   format 990.90
col pin10      heading '% <10ms'  format 990.90
col pin100     heading '% <100ms' format 990.90
col pin1000    heading '% <1s'    format 990.90
col pin10000   heading '% <10s'   format 990.90
col flush1     heading '% <1ms'   format 990.90
col flush10    heading '% <10ms'  format 990.90
col flush100   heading '% <100ms' format 990.90
col flush1000  heading '% <1s'    format 990.90
col flush10000 heading '% <10s'   format 990.90
col write1     heading '% <1ms'   format 990.90
col write10    heading '% <10ms'  format 990.90
col write100   heading '% <100ms' format 990.90
col write1000  heading '% <1s'    format 990.90
col write10000 heading '% <10s'   format 990.90
select instance_number
     , pins
     , pin1/decode(pins,0,null,pins)*100         pin1
     , pin10/decode(pins,0,null,pins)*100        pin10
     , pin100/decode(pins,0,null,pins)*100       pin100
     , pin1000/decode(pins,0,null,pins)*100      pin1000
     , pin10000/decode(pins,0,null,pins)*100     pin10000
     , flushes
     , flush1/decode(flushes,0,null,flushes)*100     flush1
     , flush10/decode(flushes,0,null,flushes)*100    flush10
     , flush100/decode(flushes,0,null,flushes)*100   flush100
     , flush1000/decode(flushes,0,null,flushes)*100  flush1000
     , flush10000/decode(flushes,0,null,flushes)*100 flush10000
     , writes
     , write1/decode(writes,0,null,writes)*100      write1
     , write10/decode(writes,0,null,writes)*100     write10
     , write100/decode(writes,0,null,writes)*100    write100
     , write1000/decode(writes,0,null,writes)*100   write1000
     , write10000/decode(writes,0,null,writes)*100  write10000
  from (
   select e.instance_number
        , sum((e.pin1 + e.pin10 + e.pin100 + e.pin1000 + e.pin10000) -
              (b.pin1 + b.pin10 + b.pin100 + b.pin1000 + b.pin10000))   pins
        , sum(e.pin1     - b.pin1)                                  pin1
        , sum(e.pin10    - b.pin10)                                 pin10
        , sum(e.pin100   - b.pin100)                                pin100
        , sum(e.pin1000  - b.pin1000)                               pin1000
        , sum(e.pin10000 - b.pin10000)                              pin10000
        , sum((e.flush1 + e.flush10 + e.flush100 + e.flush1000 + e.flush10000) -
              (b.flush1 + b.flush10 + b.flush100 + b.flush1000 + b.flush10000))   flushes
        , sum(e.flush1     - b.flush1)                              flush1
        , sum(e.flush10    - b.flush10)                             flush10
        , sum(e.flush100   - b.flush100)                            flush100
        , sum(e.flush1000  - b.flush1000)                           flush1000
        , sum(e.flush10000 - b.flush10000)                          flush10000
        , sum((e.write1 + e.write10 + e.write100 + e.write1000 + e.write10000) -
              (b.write1 + b.write10 + b.write100 + b.write1000 + b.write10000))   writes
        , sum(e.write1     - b.write1)                              write1
        , sum(e.write10    - b.write10)                             write10
        , sum(e.write100   - b.write100)                            write100
        , sum(e.write1000  - b.write1000)                           write1000
        , sum(e.write10000 - b.write10000)                          write10000
     from dba_hist_current_block_server b
        , dba_hist_current_block_server e
    where b.snap_id = :bid
      and e.snap_id = :eid
      and e.dbid             = :dbid
      and e.dbid             = b.dbid
      and b.instance_number  = e.instance_number
    group by e.instance_number)
order by instance_number;

clear breaks computes

-- ------------------------------------------------------------------

set newpage 0;
--
-- Cache Transfer Statistics (RAC)


ttitle 'Global Cache Transfer Stats  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> Immediate  (Immed) - Block Transfer NOT impacted by Remote Processing Delays' -
       skip 1 -
       '   Busy        (Busy) - Block Transfer impacted by Remote Contention' -
       skip 1 -
       '   Congested (Congst) - Block Transfer impacted by Remote System Load' -
       skip 1 -
           '-> All - average time of All blocks (Immed,Busy,Congst) in ms' -
       skip 1 -
           '-> ordered by instance_number, CR + Current Blocks Received desc' -
       skip 2 -
           '                        -------------- CR -------------  ----------- Current ------------ -------- CR Avg Time (ms) -------- ----- Current Avg Time (ms) ------';
break on instance_number

column inst     format 990         heading 'Src|Inst#'
column class    format a12         heading 'Block|Class' trunc
column totcr    format 99,999,990  heading 'Blocks|Received'
column totcu    format 99,999,990  heading 'Blocks|Received'
column blkimm   format      990.0  heading '%|Immed'
column blkbus   format      990.0  heading '%|Busy'
column blkcgt   format      990.0  heading '%|Congst'

column totcr_t  format  999,990.0  heading 'All'
column totcu_t  format  999,990.0  heading 'All'
column blkimm_t format     9990.0  heading 'Immed'
column blkbus_t format     9990.0  heading 'Busy'
column blkcgt_t format     9990.0  heading 'Congst'


--
-- Transfer Cache Statistics detailed per instance
-- Report only if define variable cache_xfer_per_instance = 'Y'
-- optimize, remoe the with which gets materialized
select instance_number 
     , instance       inst
     , class          class
     , totcr
     , cr_block/decode(totcr,0, to_number(NULL),totcr)*100          blkimm
     , cr_busy/decode(totcr,0, to_number(NULL),totcr)*100           blkbus
     , cr_congested/decode(totcr,0, to_number(NULL),totcr)*100      blkcgt
     , totcu
     , current_block/decode(totcu,0, to_number(NULL),totcu)*100     blkimm
     , current_busy/decode(totcu,0, to_number(NULL),totcu)*100      blkbus
     , current_congested/decode(totcu,0, to_number(NULL),totcu)*100 blkcgt
     , totcr_t/decode(totcr, 0, null, totcr)/&ustoms                totcr_t
     , cr_block_t/decode(cr_block, 0, null, cr_block)/&ustoms       blkimm_t
     , cr_busy_t /decode(cr_busy , 0, null, cr_busy )/&ustoms       blkbus_t
     , cr_congested_t/decode(cr_congested, 0, null, cr_congested)/&ustoms  blkcgt_t
     , totcu_t/decode(totcu, 0, null, totcu)/&ustoms                totcu_t
     , current_block_t/
       decode(current_block, 0, null, current_block)/&ustoms       blkimm_t
     , current_busy_t /
       decode(current_busy , 0, null, current_busy )/&ustoms       blkbus_t
     , current_congested_t/
       decode(current_congested, 0, null, current_congested)/&ustoms  blkcgt_t
   from (select e.instance_number
              , e.instance
        , case when e.class in ('data block','undo header','undo block')
               then e.class
               else 'others'
           end       class
        , sum(e.cr_block - b.cr_block)                cr_block
        , sum(e.cr_busy - b.cr_busy)                  cr_busy
        , sum(e.cr_congested - b.cr_congested)        cr_congested
        , sum(e.current_block - b.current_block)      current_block
        , sum(e.current_busy - b.current_busy)        current_busy
        , sum(e.current_congested - b.current_congested) current_congested
        , sum(e.cr_block - b.cr_block) 
            + sum(e.cr_busy - b.cr_busy) 
            + sum(e.cr_congested - b.cr_congested)           totcr
        , sum(e.current_block - b.current_block) 
            + sum(e.current_busy - b.current_busy) 
            + sum(e.current_congested - b.current_congested) totcu
        , sum(e.cr_block_time - b.cr_block_time)                cr_block_t
        , sum(e.cr_busy_time - b.cr_busy_time)                  cr_busy_t
        , sum(e.cr_congested_time - b.cr_congested_time)        cr_congested_t
        , sum(e.current_block_time - b.current_block_time)      current_block_t
        , sum(e.current_busy_time - b.current_busy_time)        current_busy_t
        , sum(e.current_congested_time - b.current_congested_time) current_congested_t
        , sum(e.cr_block_time - b.cr_block_time) 
            + sum(e.cr_busy_time - b.cr_busy_time) 
            + sum(e.cr_congested_time - b.cr_congested_time)           totcr_t
        , sum(e.current_block_time - b.current_block_time) 
            + sum(e.current_busy_time - b.current_busy_time) 
            + sum(e.current_congested_time - b.current_congested_time) totcu_t
     from dba_hist_inst_cache_transfer e
        , dba_hist_inst_cache_transfer b
    where e.snap_id    = :eid
      and b.snap_id    = :bid
      and e.dbid            = :dbid
      and e.instance_number = b.instance_number
      and e.dbid            = b.dbid
      and e.class            = b.class
      and e.instance         = b.instance
   group by e.instance_number, e.instance
          , case when e.class in ('data block','undo header','undo block')
               then e.class
               else 'others'
           end)  
where totcr + totcu > 0
order by instance_number,totcr + totcu desc; 


set newpage 1
ttitle lef 'Global Cache Transfer (Immediate)  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '-> ordered by instance_number, CR + Current Blocks Received desc' -
       skip 2 -
'                                -------------- CR ---------- ---------- Current ---------         ----- CR Avg Time (ms) ----- --- Current Avg Time (ms) --';

column instance  format 990         heading 'Src|Inst#'
column lost      heading 'Blocks|Lost'   format     99,999
column cr_block  heading 'Immed Blks|Received' format 99,999,990
column cu_block  heading 'Immed Blks|Received' format 99,999,990
column cr_2hop   heading '%|2-hop'        format    9990.0
column cr_3hop   heading '%|3-hop'        format    99990.0
column cu_2hop   heading '%|2-hop'        format    9990.0
column cu_3hop   heading '%|3-hop'        format    99990.0

column lost_t      heading 'Lost|Time'   format     9990.0
column cr_block_t  heading 'Immed' format  999,990.0
column cu_block_t  heading 'Immed' format  999,990.0
column cr_2hop_t   heading '2-hop'        format    99990.0
column cr_3hop_t   heading '3-hop'        format    99990.0
column cu_2hop_t   heading '2-hop'        format    99990.0
column cu_3hop_t   heading '3-hop'        format    99990.0

-- is time in micro-seconds?
select e.instance_number
     , e.instance
     , case when e.class in ('data block','undo header','undo block')
            then e.class
            else 'others'
        end       class
     , sum(e.lost     - b.lost)                   lost
     , sum(e.cr_block - b.cr_block)           cr_block
     , sum(e.cr_2hop  - b.cr_2hop)/
          decode(sum(e.cr_block - b.cr_block), 0, null
                ,sum(e.cr_block - b.cr_block))*100             cr_2hop
     , sum(e.cr_3hop  - b.cr_3hop)/
          decode(sum(e.cr_block - b.cr_block), 0, null
                ,sum(e.cr_block - b.cr_block))*100             cr_3hop
     , sum(e.current_block - b.current_block)                  cu_block
     , sum(e.current_2hop  - b.current_2hop)/
          decode(sum(e.current_block - b.current_block), 0, null
                ,sum(e.current_block - b.current_block))*100   cu_2hop
     , sum(e.current_3hop  - b.current_3hop)/
          decode(sum(e.current_block - b.current_block), 0, null
                ,sum(e.current_block - b.current_block))*100   cu_3hop
     , sum( (e.lost_time-b.lost_time)) /
           decode(sum(e.lost - b.lost),0,null,sum(e.lost-b.lost))/&ustoms lost_t
     , sum( (e.cr_block_time - b.cr_block_time)) /
           decode(sum(e.cr_block- b.cr_block),0,null
                 ,sum(e.cr_block- b.cr_block))/&ustoms   cr_block_t
     , sum( (e.cr_2hop_time - b.cr_2hop_time)) /
           decode(sum(e.cr_2hop- b.cr_2hop),0,null
                 ,sum(e.cr_2hop -b.cr_2hop))/&ustoms              cr_2hop_t
     , sum( (e.cr_3hop_time - b.cr_3hop_time)) /
           decode(sum(e.cr_3hop- b.cr_3hop),0,null
                 ,sum(e.cr_3hop -b.cr_3hop))/&ustoms              cr_3hop_t
     , sum( (e.current_block_time - b.current_block_time)) /
           decode(sum(e.current_block- b.current_block),0,null
                 ,sum(e.current_block- b.current_block))/&ustoms  cu_block_t
     , sum( (e.current_2hop_time - b.current_2hop_time)) /
           decode(sum(e.current_2hop- b.current_2hop),0,null
                 ,sum(e.current_2hop -b.current_2hop))/&ustoms    cu_2hop_t
     , sum( (e.current_3hop_time - b.current_3hop_time)) /
           decode(sum(e.current_3hop- b.current_3hop),0,null
                 ,sum(e.current_3hop -b.current_3hop))/&ustoms    cu_3hop_t
  from dba_hist_inst_cache_transfer b
     , dba_hist_inst_cache_transfer e
 where  e.snap_id    = :eid
   and b.snap_id    = :bid
   and e.dbid            = :dbid
   and e.instance_number = b.instance_number
   and e.dbid            = b.dbid
   and e.class            = b.class
   and e.instance         = b.instance
 group by e.instance_number, e.instance
        , case when e.class in ('data block','undo header','undo block')
               then e.class
               else 'others'
           end
order by e.instance_number
       , sum(e.cr_block - b.cr_block) 
       + sum(e.current_block - b.current_block) desc;


clear breaks computes
-- ------------------------------------------------------------------
set newpage 0;

--
-- IP Configuration

ttitle lef 'Cluster Interconnect  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
      skip 1 - 
           '~~~~~~~~~~~~~~~~~~~~' -
      skip 2;

break on instance_number
col name     format a10 heading 'NAME'
col b_ip     format a15 heading 'IP Address'
col b_ipub   format a3  heading 'Pub'
col b_source format a30 trunc    heading 'Source'  
col e_ip     format a15 heading 'End (if diff)|IP Address'
col e_ipub   format a3  heading 'End|Pub'
col e_source format a30 heading 'End (if diff)|Source'
select e.instance_number
     , e.name
     , b.ip_address                             b_ip
     , substr(b.is_public,1,1)                  b_ipub
     , b.source                                 b_source
     , case when (b.ip_address != e.ip_address)
            then e.ip_address
       end                                      e_ip
     , case when (b.is_public != e.is_public)
            then substr(e.is_public,1,1)
       end                                      e_ipub
     , case when (b.source != e.source)
            then e.source
       end                                      e_source
  from dba_hist_cluster_intercon b
     , dba_hist_cluster_intercon e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and e.dbid            = :dbid
   and b.instance_number = e.instance_number
   and b.dbid            = e.dbid
   and b.name            = e.name
order by e.instance_number, e.name;

clear breaks computes

-- ------------------------------------------------------------------
set newpage 1;

--
-- IC Client Statistics

ttitle lef 'Interconnect Client Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
     skip 1 -
             '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'-
     skip 2 -
'     ----------------------------- Sent (MB) ------------------------- -------------------------- Received (MB) ------------------------'


break on report
compute sum avg std of   tot_bs on report
compute sum avg std of cache_bs on report
compute sum avg std of   ipq_bs on report
compute sum avg std of   dlm_bs on report
compute sum avg std of  ping_bs on report
compute sum avg std of  misc_bs on report
compute sum avg std of cache_br on report
compute sum avg std of   tot_br on report
compute sum avg std of   ipq_br on report
compute sum avg std of   dlm_br on report
compute sum avg std of  ping_br on report
compute sum avg std of  misc_br on report
compute sum avg std of   tot_bs_s on report
compute sum avg std of cache_bs_s on report
compute sum avg std of   ipq_bs_s on report
compute sum avg std of   dlm_bs_s on report
compute sum avg std of  ping_bs_s on report
compute sum avg std of  misc_bs_s on report
compute sum avg std of   tot_br_s on report
compute sum avg std of cache_br_s on report
compute sum avg std of   ipq_br_s on report
compute sum avg std of   dlm_br_s on report
compute sum avg std of  ping_br_s on report
compute sum avg std of  misc_br_s on report

col name      format       a10 heading 'Name'
col  tot_bs   format 999,990.0  heading 'Total'
col  dlm_bs   format 999,990.0  heading 'DLM'
col  cache_bs format 999,990.0  heading 'Cache'
col  ipq_bs   format 999,990.0  heading 'IPQ'
col  ping_bs  format 999,990.0  heading 'PNG'
col  misc_bs  format 999,990.0  heading 'Misc'
col  dlm_br   format 999,990.0  heading 'DLM'
col  cache_br format 999,990.0  heading 'Cache'
col  ipq_br   format 999,990.0  heading 'IPQ'
col  ping_br  format 999,990.0  heading 'PNG'
col  misc_br  format 999,990.0  heading 'Misc'
col  tot_br   format 999,990.0  heading 'Total'
col  tot_bs_s   format 999,990.0  heading 'Total'
col  dlm_bs_s   format 999,990.0  heading 'DLM'
col  cache_bs_s format 999,990.0  heading 'Cache'
col  ipq_bs_s   format 999,990.0  heading 'IPQ'
col  ping_bs_s  format 999,990.0  heading 'PNG'
col  misc_bs_s  format 999,990.0  heading 'Misc'
col  tot_br_s   format 999,990.0  heading 'Total'
col  dlm_br_s   format 999,990.0  heading 'DLM'
col  cache_br_s format 999,990.0  heading 'Cache'
col  ipq_br_s   format 999,990.0  heading 'IPQ'
col  ping_br_s  format 999,990.0  heading 'PNG'
col  misc_br_s  format 999,990.0  heading 'Misc'

-- should we do percentage of traffic for sent/received here?
select instance_number
     , (cache_bs + ipq_bs + dlm_bs + ping_bs 
       + diag_bs + cgs_bs + osm_bs + str_bs + int_bs + ksv_bs + ksxr_bs)/&&btomb tot_bs
     , cache_bs/&&btomb                   cache_bs
     , ipq_bs/&&btomb                       ipq_bs
     , dlm_bs/&&btomb                       dlm_bs
     , ping_bs/&&btomb                     ping_bs
     , (diag_bs + cgs_bs + osm_bs + str_bs + int_bs + ksv_bs + ksxr_bs)/&&btomb misc_bs
     , (cache_br + ipq_br + dlm_br + ping_br 
       + diag_br + cgs_br + osm_br + str_br + int_br + ksv_br + ksxr_br)/&&btomb tot_br
     , cache_br/&&btomb                   cache_br
     , ipq_br/&&btomb                       ipq_br
     , dlm_br/&&btomb                       dlm_br      
     , ping_br/&&btomb                     ping_br
     , (diag_br + cgs_br + osm_br + str_br + int_br + ksv_br + ksxr_br)/&&btomb misc_br
  from
   ((select e.instance_number
        , e.name
        , (e.bytes_sent     - b.bytes_sent)              bs
        , (e.bytes_received - b.bytes_received)          br
     from dba_hist_ic_client_stats b
        , dba_hist_ic_client_stats e
    where b.snap_id         = :bid
      and e.snap_id         = :eid
      and e.dbid            = :dbid
      and b.instance_number = e.instance_number
      and b.dbid            = e.dbid
      and b.name            = e.name)
    pivot (sum(bs) bs,sum(br)br for name in ('dlm' dlm
                                       ,'cache'    cache
                                       ,'ping'     ping
                                       ,'diag'     diag
                                       ,'cgs'      cgs
                                       ,'ksxr'     ksxr
                                       ,'ipq'      ipq
                                       ,'osmcache' osm
                                       ,'streams'  str
                                       ,'internal' int
                                       ,'ksv'      ksv)))
 order by instance_number;


ttitle lef 'Interconnect Client Statistics (per Second)  ' -
     skip 1 -
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'-
     skip 2 -
'     ----------------------------- Sent (MB/s) ----------------------- -------------------------- Received (MB/s) ----------------------'

select ic.instance_number
     , (cache_bs + ipq_bs + dlm_bs + ping_bs 
       + diag_bs + cgs_bs + osm_bs + str_bs + int_bs + ksv_bs + ksxr_bs)/s_et/&&btomb tot_bs_s
     , cache_bs/s_et/&&btomb                   cache_bs_s
     , ipq_bs/s_et/&&btomb                       ipq_bs_s
     , dlm_bs/s_et/&&btomb                       dlm_bs_s
     , ping_bs/s_et/&&btomb                     ping_bs_s
     , (diag_bs + cgs_bs + osm_bs + str_bs + int_bs + ksv_bs + ksxr_bs)/s_et/&&btomb misc_bs_s
     , (cache_br + ipq_br + dlm_br + ping_br 
       + diag_br + cgs_br + osm_br + str_br + int_br + ksv_br + ksxr_br)/s_et/&&btomb tot_br_s
     , cache_br/s_et/&&btomb                   cache_br_s
     , ipq_br/s_et/&&btomb                       ipq_br_s
     , dlm_br/s_et/&&btomb                       dlm_br_s
     , ping_br/s_et/&&btomb                     ping_br_s
     , (diag_br + cgs_br + osm_br + str_br + int_br + ksv_br + ksxr_br)/s_et/&&btomb misc_br_s
  from
   ((select e.instance_number
        , e.name
        , (e.bytes_sent     - b.bytes_sent)              bs
        , (e.bytes_received - b.bytes_received)          br
     from dba_hist_ic_client_stats b
        , dba_hist_ic_client_stats e
    where b.snap_id         = :bid
      and e.snap_id         = :eid
      and e.dbid            = :dbid
      and b.instance_number = e.instance_number
      and b.dbid            = e.dbid
      and b.name            = e.name)
    pivot (sum(bs) bs,sum(br)br for name in ('dlm' dlm
                                       ,'cache'    cache
                                       ,'ping'     ping
                                       ,'diag'     diag
                                       ,'cgs'      cgs
                                       ,'ksxr'     ksxr
                                       ,'ipq'      ipq
                                       ,'osmcache' osm
                                       ,'streams'  str
                                       ,'internal' int
                                       ,'ksv'      ksv)))   ic
    , (select e.instance_number
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)                      s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where ic.instance_number = s.instance_number
 order by ic.instance_number;

clear breaks computes

-- ------------------------------------------------------------------

--
-- IC Device Statistics

ttitle lef 'Interconnect Device Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
     skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
     skip 1 -
       '-> Data is retrieved from underlying Operating system and may overflow on some 32-bit OSs' -
     skip 1 -
       '-> null means begin value > end value' -
     skip 2 -
'                                              --------------------------- Sent ------------------------- -------------------- Received ----------------------------' ; 

break on report on instance_number
compute sum avg std of r_mbytes on report
compute sum avg std of r_packs  on report
compute sum avg std of r_errs   on report
compute sum avg std of r_drops  on report
compute sum avg std of r_bufor  on report
compute sum avg std of r_frme   on report
compute sum avg std of s_mbytes on report
compute sum avg std of s_packs  on report
compute sum avg std of s_errs   on report
compute sum avg std of s_drops  on report
compute sum avg std of s_bufor  on report
compute sum avg std of s_lost   on report
compute sum avg std of r_mbytes_ps on report
compute sum avg std of r_packs_ps  on report
compute sum avg std of r_errs_ps   on report
compute sum avg std of r_drops_ps  on report
compute sum avg std of r_bufor_ps  on report
compute sum avg std of r_frme_ps   on report
compute sum avg std of s_mbytes_ps on report
compute sum avg std of s_packs_ps  on report
compute sum avg std of s_errs_ps   on report
compute sum avg std of s_drops_ps  on report
compute sum avg std of s_bufor_ps  on report
compute sum avg std of s_lost_ps   on report
col ifn       format          a40   heading 'Interface|Name/IP/Netmask'
col r_mbytes  format 99,999,990.0   heading 'MBytes'
col r_packs   format  999,999,990   heading 'Packets' 
col r_errs    format       99,990   heading 'Errors'
col r_drops   format       99,990   heading 'Packets|Dropped'
col r_bufor   format       99,990   heading 'Buffer|Ovrrun'
col r_frme    format       99,990   heading 'Frame|Errors'
col s_mbytes  format 99,999,990.0   heading 'MBytes'
col s_packs   format  999,999,990   heading 'Packets'
col s_errs    format       99,990   heading 'Errors'
col s_drops   format       99,990   heading 'Packets|Dropped'
col s_bufor   format       99,990   heading 'Buffer|Ovrrun'
col s_lost    format       99,990   heading 'Carrier|Lost'
col r_mbytes_ps  format 99,999,990.0   heading 'MBytes'
col r_packs_ps   format  9,999,990.0   heading 'Packets'
col r_errs_ps    format       9990.0   heading 'Errors'
col r_drops_ps   format       9990.0   heading 'Packets|Dropped'
col r_bufor_ps   format       9990.0   heading 'Buffer|Ovrrun'
col r_frme_ps    format       9990.0   heading 'Frame|Errors'
col s_mbytes_ps  format 99,999,990.0   heading 'MBytes'
col s_packs_ps   format  9,999,990.0   heading 'Packets'
col s_errs_ps    format       9990.0   heading 'Errors'
col s_drops_ps   format       9990.0   heading 'Packets|Dropped'
col s_bufor_ps   format       9990.0   heading 'Buffer|Ovrrun'
col s_lost_ps    format       9990.0   heading 'Carrier|Lost'

select e.instance_number
     , e.if_name || '/' || b.ip_addr || '/' || b.net_mask   ifn      
     , case when e.bytes_sent >= b.bytes_sent
            then (e.bytes_sent - b.bytes_sent)/&btomb
            else null
       end           s_mbytes      
     , case when e.packets_sent >= b.packets_sent
            then(e.packets_sent - b.packets_sent)
            else null
       end              s_packs
     , case when e.send_errors >= b.send_errors
            then(e.send_errors - b.send_errors)
            else null
       end                s_errs
     , case when e.sends_dropped >= b.sends_dropped
            then(e.sends_dropped - b.sends_dropped)
            else null
       end            s_drops
     , case when e.send_buf_or >= b.send_buf_or
            then(e.send_buf_or - b.send_buf_or)
            else null
       end                s_bufor
     , case when e.send_carrier_lost >= b.send_carrier_lost
            then(e.send_carrier_lost - b.send_carrier_lost)
            else null
       end    s_lost
     , case when e.bytes_received >= b.bytes_received
            then(e.bytes_received - b.bytes_received)/&btomb
            else null
       end   r_mbytes
     , case when e.packets_received >= b.packets_received
            then(e.packets_received - b.packets_received)
            else null
       end      r_packs
     , case when e.receive_errors >= b.receive_errors
            then(e.receive_errors - b.receive_errors)
            else null
       end          r_errs
     , case when e.receive_dropped >= b.receive_dropped
            then(e.receive_dropped - b.receive_dropped)
            else null
       end        r_drops
     , case when e.receive_buf_or >= b.receive_buf_or
            then(e.receive_buf_or - b.receive_buf_or)
            else null
       end          r_bufor
     , case when e.receive_frame_err >= b.receive_frame_err
            then(e.receive_frame_err - b.receive_frame_err)
            else null
       end    r_frme
  from dba_hist_ic_device_stats b
     , dba_hist_ic_device_stats e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and e.dbid            = :dbid
   and b.instance_number = e.instance_number
   and b.dbid            = e.dbid
   and b.if_name         = e.if_name
 order by e.instance_number,e.if_name;


ttitle lef 'Interconnect Device Statistics (per Second)' -
     skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
     skip 1 -
       '-> Data is retrieved from underlying Operating system and may overflow on some 32-bit OSs' -
     skip 1 -
       '-> null means begin value > end value' -
     skip 2 -
'                                              --------------------- Sent (per Sec) --------------------- ---------------- Received (per Second) -------------------' ;
select ic.instance_number
     , ic.ifn
     , ic.s_mbytes_ps/s_et            s_mbytes_ps
     , ic.s_packs_ps/s_et              s_packs_ps
     , ic.s_errs_ps/s_et                s_errs_ps
     , ic.s_drops_ps/s_et              s_drops_ps
     , ic.s_bufor_ps/s_et              s_bufor_ps
     , ic.s_lost_ps/s_et                s_lost_ps
     , ic.r_mbytes_ps/s_et            r_mbytes_ps
     , ic.r_packs_ps/s_et              r_packs_ps
     , ic.r_errs_ps/s_et                r_errs_ps
     , ic.r_drops_ps/s_et              r_drops_ps
     , ic.r_bufor_ps/s_et              r_bufor_ps
     , ic.r_frme_ps/s_et                r_frme_ps
  from (
   select e.instance_number
        , e.if_name || '/' || b.ip_addr || '/' || b.net_mask   ifn
        , case when e.bytes_sent >= b.bytes_sent
               then (e.bytes_sent - b.bytes_sent)/&btomb
               else null
          end                                             s_mbytes_ps
        , case when e.packets_sent >= b.packets_sent
               then(e.packets_sent - b.packets_sent)
               else null
          end                                              s_packs_ps
        , case when e.send_errors >= b.send_errors
               then(e.send_errors - b.send_errors)
               else null
          end                                               s_errs_ps
        , case when e.sends_dropped >= b.sends_dropped
               then(e.sends_dropped - b.sends_dropped)
               else null
          end                                              s_drops_ps
        , case when e.send_buf_or >= b.send_buf_or
               then(e.send_buf_or - b.send_buf_or)
               else null
          end                                              s_bufor_ps
        , case when e.send_carrier_lost >= b.send_carrier_lost
               then(e.send_carrier_lost - b.send_carrier_lost)
               else null
          end                                               s_lost_ps
        , case when e.bytes_received >= b.bytes_received
               then(e.bytes_received - b.bytes_received)/&btomb
               else null
          end                                             r_mbytes_ps
        , case when e.packets_received >= b.packets_received
               then(e.packets_received - b.packets_received)
               else null
          end                                              r_packs_ps
        , case when e.receive_errors >= b.receive_errors
               then(e.receive_errors - b.receive_errors)
               else null
          end                                               r_errs_ps
        , case when e.receive_dropped >= b.receive_dropped
               then(e.receive_dropped - b.receive_dropped)
               else null
          end                                              r_drops_ps
        , case when e.receive_buf_or >= b.receive_buf_or
               then(e.receive_buf_or - b.receive_buf_or)
               else null
          end                                              r_bufor_ps
        , case when e.receive_frame_err >= b.receive_frame_err
               then(e.receive_frame_err - b.receive_frame_err)
               else null
          end                                               r_frme_ps
     from dba_hist_ic_device_stats b
        , dba_hist_ic_device_stats e
    where b.snap_id         = :bid
      and e.snap_id         = :eid
      and e.dbid            = :dbid
      and b.instance_number = e.instance_number
      and b.dbid            = e.dbid
      and b.if_name         = e.if_name) ic
    , (select e.instance_number
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)                      s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where ic.instance_number = s.instance_number
 order by instance_number,ifn;
ttitle off

clear breaks computes

-- ------------------------------------------------------------------

--
-- Ping Statistics

col target_instance format 999 heading 'Target|Inst#'
col cnt500b         format  9,999,999 heading 'Ping Count'
col wait500b        format  999,990.0 heading 'Time (s)'
col av500b          format     9990.0 heading 'Avg  |Time(ms)'
col sd500b          format      990.0 heading 'Std|Dev'
col cnt8k           format 9,999,990 heading 'Ping Count'
col wait8k          format  999,990.0 heading 'Time (s)'
col av8k            format     9990.0 heading 'Avg  |Time(ms)' 
col sd8k            format      990.0 heading 'Std|Dev'

break on instance_number
ttitle lef 'Ping Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
      skip 1 -
           '~~~~~~~~~~~~~~~' -
      skip 1 -
           '-> Latency of the roundtrip of a message from Instance to the Target instances' -
      skip 2 -
'            ----------  500 bytes --------------- ------------- 8 Kbytes --------------';

select e.instance_number
     , e.target_instance
     , e.cnt_500b-b.cnt_500b                cnt500b
     , (e.wait_500b-b.wait_500b)/&ustos    wait500b
     , case when e.cnt_500b = b.cnt_500b then null
            else
              (e.wait_500b-b.wait_500b)/(e.cnt_500b-b.cnt_500b)/&ustoms
       end                                   av500b
     , case when e.cnt_500b = b.cnt_500b then null
            else
             SQRT( ((1000*(e.waitsq_500b-b.waitsq_500b))/
                     greatest(e.cnt_500b-b.cnt_500b,1))
             - ( (e.wait_500b-b.wait_500b)/(e.cnt_500b-b.cnt_500b)
             * (e.wait_500b-b.wait_500b)/(e.cnt_500b-b.cnt_500b)))/1000
       end                                   sd500b
     , e.cnt_8k-b.cnt_8k                      cnt8k
     , (e.wait_8k-b.wait_8k)/&ustos          wait8k
     , case when e.cnt_8k = b.cnt_8k then null
            else
             (e.wait_8k-b.wait_8k)/(e.cnt_8k-b.cnt_8k)/&ustoms
       end                                     av8k
     , case when e.cnt_8k = b.cnt_8k then null
            else
              SQRT( ((1000*(e.waitsq_8k-b.waitsq_8k))/
                    greatest(e.cnt_8k-b.cnt_8k,1))
             - ( (e.wait_8k-b.wait_8k)/(e.cnt_8k-b.cnt_8k)
                * (e.wait_8k-b.wait_8k)/(e.cnt_8k-b.cnt_8k)))/1000
       end                                     sd8k
  from dba_hist_interconnect_pings b
     , dba_hist_interconnect_pings e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and e.dbid            = :dbid
   and b.instance_number = e.instance_number
   and b.dbid            = e.dbid
   and b.target_instance = e.target_instance
 order by instance_number, target_instance;

clear breaks computes


-- ------------------------------------------------------------------

--
-- Remaster Statistics
-- do no need totals
-- ttitle lef 'Dynamic Remastering Statistics ' -
--        center 'DB: ' db_name ' ' -
--        'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
--       skip 1 -
--            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
--       skip 1 -
--            '-> Affinity Obj - objects remastered due to affinity at begin/end snap' -
--       skip 2;
-- break on report
--         
-- compute  avg               of r_ops on report
-- compute  avg               of r_obj on report
-- compute  avg max label max of rls   on report
-- compute  avg max label max of rlr   on report
-- compute  avg max label max of rc    on report
-- compute  avg max label max of r_tm  on report
-- compute  avg max label max of qt    on report
-- compute  avg max label max of ft    on report
-- compute  avg max label max of ct    on report
-- compute  avg max label max of rt    on report
-- compute  avg max label max of fxt   on report
-- compute  avg max label max of st    on report        
-- compute  avg max label max of bco   on report
-- compute  avg max label max of eco   on report
-- 
-- 
-- col r_ops  format     999,990  heading 'Remaster|Ops'               just c
-- col r_tm   format    99,990.0  heading 'Remaster|Time(s)'           just c
-- col r_obj  format 999,999,990  heading 'Remastered|Objects'         just c
-- col qt     format    99,990.0  heading 'Quiesce|Time(s)'            just c
-- col ft     format    99,990.0  heading 'Freeze|Time(s)'             just c
-- col ct     format    99,990.0  heading 'Cleanup|Time(s)'            just c
-- col rt     format    99,990.0  heading 'Replay|Time(s)'             just c
-- col fxt    format    99,990.0  heading 'Fixwrite|Time(s)'           just c
-- col st     format    99,990.0  heading 'Sync|Time(s)'               just c
-- col rc     format 999,999,990  heading 'Resources|Cleaned'          just c
-- col rls    format 999,999,990  heading 'Replay Locks|Sent'          just c
-- col rlr    format 999,999,990  heading 'Replay Locks|Received'      just c
-- col bco    format  99,999,990  heading 'Affinity|Obj (Beg)'         just c
-- col eco    format  99,999,990  heading 'Affinity|Obj (End)'         just c
-- 
-- select e.instance_number
--      , e.remaster_ops            - b.remaster_ops            r_ops
--      , e.remastered_objects      - b.remastered_objects      r_obj
--      , e.replayed_locks_sent     - b.replayed_locks_sent     rls
--      , e.replayed_locks_received - b.replayed_locks_received rlr
--      , e.resources_cleaned       - b.resources_cleaned       rc
--      , (e.remaster_time          - b.remaster_time)/&cstos   r_tm
--      , (e.quiesce_time           - b.quiesce_time)/&cstos    qt
--      , (e.freeze_time            - b.freeze_time)/&cstos     ft
--      , (e.cleanup_time           - b.cleanup_time)/&cstos    ct
--      , (e.replay_time            - b.replay_time)/&cstos     rt
--      , (e.fixwrite_time          - b.fixwrite_time)/&cstos   fxt
--      , (e.sync_time              - b.sync_time)/&cstos       st
--      , b.current_objects                                     bco
--      , e.current_objects                                     eco
--   from dba_hist_dyn_remaster_stats b
--      , dba_hist_dyn_remaster_stats e
--  where e.dbid    = :dbid
--    and b.snap_id = :bid
--    and e.snap_id = :eid
--    and e.dbid    = b.dbid
--    and e.instance_number = b.instance_number
--  order by e.instance_number;
-- 
-- clear breaks computes



ttitle lef 'Dynamic Remastering Statistics - per Remaster Ops' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
      skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
      skip 1 -
           '-> Affinity Obj - objects remastered due to affinity at begin/end snap' -
      skip 2;
break on report

compute  avg               of r_ops on report
compute  avg               of r_obj on report
compute  avg max label max of rls on report
compute  avg max label max of rlr on report
compute  avg max label max of rc on report
compute  avg max label max of r_tm on report
compute  avg max label max of qt on report
compute  avg max label max of ft on report
compute  avg max label max of ct on report
compute  avg max label max of rt on report
compute  avg max label max of fxt on report
compute  avg max label max of st on report        
compute  avg max label max of bco on report
compute  avg max label max of eco on report


col r_ops  format     999,990  heading 'Remaster|Ops'                       just c
col r_tm   format    9,990.90  heading 'Remaster|Time(s)|per Ops'           just c
col r_obj  format 9,999,990.0  heading 'Remastered|Objects|per Ops'         just c
col qt     format    9,990.90  heading 'Quiesce|Time(s)|per Ops'            just c
col ft     format    9,990.90  heading 'Freeze|Time(s)|per Ops'             just c
col ct     format    9,990.90  heading 'Cleanup|Time(s)|per Ops'            just c
col rt     format    9,990.90  heading 'Replay|Time(s)|per Ops'             just c
col fxt    format    9,990.90  heading 'Fixwrite|Time(s)|per Ops'           just c
col st     format    9,990.90  heading 'Sync|Time(s)|per Ops'               just c
col rc     format 9,999,990.0  heading 'Resources|Cleaned|per Ops'          just c
col rls    format 9,999,990.0  heading 'Replay Locks|Sent|per Ops'          just c
col rlr    format 9,999,990.0  heading 'Replay Locks|Received|per Ops'      just c
col bco    format  99,999,990  heading 'Affinity|Obj (Beg)'         just c
col eco    format  99,999,990  heading 'Affinity|Obj (End)'         just c

select e.instance_number
     , e.remaster_ops            - b.remaster_ops            r_ops
     , (e.remastered_objects     - b.remastered_objects)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)      r_obj
     , (e.replayed_locks_received - b.replayed_locks_received)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)      rlr
     , (e.replayed_locks_sent     - b.replayed_locks_sent)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)      rls
     , (e.resources_cleaned      - b.resources_cleaned)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)      rc
     , (e.remaster_time          - b.remaster_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      r_tm
     , (e.quiesce_time           - b.quiesce_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      qt
     , (e.freeze_time            - b.freeze_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      ft
     , (e.cleanup_time           - b.cleanup_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      ct
     , (e.replay_time            - b.replay_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      rt
     , (e.fixwrite_time          - b.fixwrite_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      fxt
     , (e.sync_time              - b.sync_time)/
          (case when e.remaster_ops - b.remaster_ops = 0 then null else e.remaster_ops - b.remaster_ops end)/&cstos      st
     , b.current_objects                                     bco
     , e.current_objects                                     eco
  from dba_hist_dyn_remaster_stats b
     , dba_hist_dyn_remaster_stats e
 where e.dbid    = :dbid
   and b.snap_id = :bid
   and e.snap_id = :eid
   and e.dbid    = b.dbid
   and e.instance_number = b.instance_number
 order by e.instance_number;

clear breaks computes

-- ------------------------------------------------------------------

set newpage 0

ttitle skip 1 -
       lef 'Top Timed Events  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> Instance ''*''  - cluster wide summary' -
       skip 1 -
           '   Waits, Timeouts, Total Wait Time          : Cluster-wide total for the wait event' -
       skip 1 -
           '   ''Avg Wait Time (ms)''                      : Cluster-wide average computed as (Total Wait Time / Waits) in ms' -
       skip 1 -
           '   ''Avg Wait Time (ms)'' Summary of Instances : Per-instance ''Avg Wait Time (ms)'' used to compute the statistics: ' -
       skip 1 -
           '         [Avg|Min|Max|Std Dev]  - average|minimum|maximum|standard deviation of'  -
           ' per-instance ''Avg Wait (ms)''' -
       skip 1 -
           '   Cnt - number of instances with the wait event ' -
       skip 2 -
'                                                                                                 -------- Avg Wait Time (ms) --------' -
       skip 1 -
'                                                                                             Avg         Summary of Instances        ' -
       skip 1;


break on inststr skip 1
col inststr format  a4          heading 'I#'     just r
col nm      format a40 trunc    heading 'Event'
col wc      format  a8 trunc    heading 'Wait|Class'
col twt     format  999,999,990 heading 'Waits'
col pctto   format        990.0 heading '%Time|-outs'
col tto     format    9,999,990    
col ttm     format 9,999,990.90 heading 'Total Wait|Time(s)'
col rnk     format          990 noprint
col avtm    format       9990.0 heading 'Wait|(ms)'
col avavtm  format       9990.0 heading 'Avg'
col stdtm   format       9990.0 heading 'Std|Dev'
col mintm   format       9990.0 heading 'Min'
col maxtm   format       9990.0 heading 'Max'
col cnt     format          990 heading 'Cnt'
col pctdbt  format       990.90 heading '% of|DB time'
col pctbgt  format       990.90 heading '% of|bg time'


select * 
  from ( /* apply rank to get top 10 per instance, rollup cluster-wide totals */
      select lpad(case when s.instance_number is null
                  then  '*'
                  else to_char(s.instance_number,'999')
             end,4)                   inststr
           , wc
           , nm
           , sum(twt)                  twt
           , case when sum(twt) = 0 
                  then null 
                  else sum(tto)/sum(twt)*100 
             end                     pctto
           , sum(ttm)/&ustos           ttm
           , case when sum(twt) = 0 
                  then null 
                  else sum(ttm)/sum(twt)/&ustoms 
             end                      avtm
           , case when s.instance_number is null then avg(avtm) end  avavtm
           , case when s.instance_number is null then min(avtm) end   mintm
           , case when s.instance_number is null then max(avtm) end   maxtm
           , case when s.instance_number is null then stddev_samp(avtm) end stdtm
           , case when s.instance_number is null then count(*) end      cnt
           , case when sum(dbt) = 0 
                  then null 
                  else sum(ttm)/sum(dbt)*100 
             end                    pctdbt
           , rank() over (partition by s.instance_number
                       order by sum(ttm) desc, sum(twt) desc)  rnk
  from (  /* wait events, avg wait time and db cpu per instance */
          ( /* select events per instance */
              select e.event_name                                        nm
                   , e.wait_class                                        wc
                   , e.instance_number
                   , e.total_waits - nvl(b.total_waits,0)               twt
                   , e.total_timeouts - nvl(b.total_timeouts,0)         tto
                   , (e.time_waited_micro - nvl(b.time_waited_micro,0)) ttm
                   , case when (e.total_waits - nvl(b.total_waits,0) = 0) 
                          then null
                          else (e.time_waited_micro - nvl(b.time_waited_micro,0))/
                               (e.total_waits - nvl(b.total_waits,0))/&ustoms  
                     end                                                avtm
             from dba_hist_system_event e
                , dba_hist_system_event b
             where e.snap_id         = :eid
               and b.snap_id (+)     = :bid
               and e.dbid            = :dbid
               and e.dbid            = b.dbid             (+)
               and e.instance_number = b.instance_number  (+)
               and e.event_id        = b.event_id         (+)
               and e.event_name      = b.event_name       (+)
               and e.wait_class     != 'Idle'
            )
            union all
            ( /* select time for DB CPU */
               select se.stat_name                                    nm
                   , null                                             wc
                   , se.instance_number
                   , null                                            twt
                   , null                                            tto
                   , (se.value - nvl(sb.value,0))                    ttm
                   , null                                           avtm
                from dba_hist_sys_time_model se
                   , dba_hist_sys_time_model sb
               where se.snap_id         = :eid
                 and sb.snap_id  (+)    = :bid
                 and se.dbid            = :dbid
                 and se.dbid            = sb.dbid            (+)
                 and se.instance_number = sb.instance_number (+)
                 and se.stat_name       = 'DB CPU'
                 and se.stat_name       = sb.stat_name       (+)
                 and se.stat_id         = sb.stat_id         (+)
            )
      )  s
    , (select e.instance_number
            , sum((e.value - nvl(b.value,0)))  dbt
         from dba_hist_sys_time_model b
            , dba_hist_sys_time_model e
        where e.dbid            = :dbid
          and e.dbid            = b.dbid            (+)
          and e.instance_number = b.instance_number (+)
          and e.snap_id         = :eid
          and b.snap_id   (+)   = :bid
          and b.stat_id   (+)   = e.stat_id
          and e.stat_name = 'DB time'
        group by e.instance_number
      ) tm
   where s.instance_number = tm.instance_number
   group by wc, nm, rollup(s.instance_number)
   )
where rnk <= &&top_n_events
order by inststr, ttm desc, twt desc;

clear breaks computes

repfooter center -
   '-------------------------------------------------------------';



ttitle skip 1 -
       lef 'Top Timed Foreground Events  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> Foreground Activity is captured in release 11g and above; ' -
       skip 1 -
           '   if *_FG statistics (waits, timeouts, time waited) are null then  the *_FG statistics are computed as (total - background)' -
       skip 1 -
           '-> Instance ''*''  - cluster wide summary' -
       skip 1 -
           '   Waits, Timeouts, Total Wait Time          : Cluster-wide total for the wait event' -
       skip 1 -
           '   ''Avg Wait Time (ms)''                      : Cluster-wide average computed as (Total Wait Time / Waits) in ms' -
       skip 1 -
           '   ''Avg Wait Time (ms)'' Summary of Instances : Per-instance ''Avg Wait Time (ms)'' used to compute the statistics: ' -
       skip 1 -
           '         [Avg|Min|Max|Std Dev]  - average|minimum|maximum|standard deviation of'  -
           ' per-instance ''Avg Wait (ms)''' -
       skip 1 -
           '        Cnt - number of instances with the wait event ' -
       skip 2 -
'                                                                                                 -------- Avg Wait Time (ms) --------' -
       skip 1 -
'                                                                                             Avg         Summary of Instances        ' -
       skip 1;

break on inststr skip 1


select * 
  from ( /* apply rank to get top 10 per instance, rollup cluster-wide totals */
      select lpad(case when s.instance_number is null
                  then  '*'
                  else to_char(s.instance_number,'999')
             end,4)                   inststr
           , wc
           , nm
           , sum(twt)                  twt
           , case when sum(twt) = 0 
                  then null 
                  else sum(tto)/sum(twt)*100 
             end                     pctto
           , sum(ttm)/&ustos           ttm
           , case when sum(twt) = 0 
                  then null 
                  else sum(ttm)/sum(twt)/&ustoms 
             end                      avtm
           , case when s.instance_number is null then avg(avtm) end  avavtm
           , case when s.instance_number is null then min(avtm) end   mintm
           , case when s.instance_number is null then max(avtm) end   maxtm
           , case when s.instance_number is null then stddev_samp(avtm) end stdtm
           , case when s.instance_number is null then count(*) end      cnt
           , case when sum(dbt) = 0 
                  then null 
                  else sum(ttm)/sum(dbt)*100 
             end                    pctdbt
           , rank() over (partition by s.instance_number
                       order by sum(ttm) desc, sum(twt) desc)  rnk
  from (  /* average wait time per instance */
          select instance_number
               , nm
               , wc
               , twt
               , tto
               , ttm
               , case when twt = 0 then null
                      else ttm/twt/&ustoms
                 end                           avtm
            from 
          ( /* select events per instance */
            ( select e.instance_number
                 , e.event_name                                      nm
                 , e.wait_class                                      wc
                 , case when e.total_waits_fg is not null
                        then e.total_waits_fg - nvl(b.total_waits_fg,0)
                        else (e.total_waits - nvl(b.total_waits,0))
                              - greatest(0,(nvl(ebg.total_waits,0) - nvl(bbg.total_waits,0)))
                   end                                               twt
                 , case when e.total_timeouts_fg is not null
                        then e.total_timeouts_fg - nvl(b.total_timeouts_fg,0)
                        else (e.total_timeouts - nvl(b.total_timeouts,0))
                              - greatest(0,(nvl(ebg.total_timeouts,0) - nvl(bbg.total_timeouts,0)))
                   end                                              tto
                 , case when e.time_waited_micro_fg is not null
                        then e.time_waited_micro_fg - nvl(b.time_waited_micro_fg,0)
                        else (e.time_waited_micro - nvl(b.time_waited_micro,0))
                              - greatest(0,(nvl(ebg.time_waited_micro,0) - nvl(bbg.time_waited_micro,0)))
                   end                                              ttm
              from dba_hist_system_event b
                 , dba_hist_system_event e
                 , dba_hist_bg_event_summary bbg
                 , dba_hist_bg_event_summary ebg
             where b.snap_id  (+) = :bid
               and e.snap_id      = :eid
               and bbg.snap_id (+) = :bid
               and ebg.snap_id (+) = :eid
               and e.dbid          = :dbid
               and e.dbid            = b.dbid (+)
               and e.instance_number = b.instance_number (+)
               and e.event_id        = b.event_id (+)
               and e.dbid            = ebg.dbid (+)
               and e.instance_number = ebg.instance_number (+)
               and e.event_id        = ebg.event_id (+)
               and e.dbid            = bbg.dbid (+)
               and e.instance_number = bbg.instance_number (+)
               and e.event_id        = bbg.event_id (+)
               and e.total_waits     > b.total_waits (+)
               and e.wait_class     != 'Idle'
            )
            union all
            ( /* select time for DB CPU */
               select se.instance_number
                   , se.stat_name                                    nm
                   , null                                            wc
                   , null                                            twt
                   , null                                            tto
                   , (se.value - nvl(sb.value,0))                    ttm
                from dba_hist_sys_time_model se
                   , dba_hist_sys_time_model sb
               where se.snap_id         = :eid
                 and sb.snap_id  (+)    = :bid
                 and se.dbid            = :dbid
                 and se.dbid            = sb.dbid            (+)
                 and se.instance_number = sb.instance_number (+)
                 and se.stat_name       = 'DB CPU'
                 and se.stat_name       = sb.stat_name       (+)
                 and se.stat_id         = sb.stat_id         (+)
            )
         )
      )  s
    , (select e.instance_number
            , sum((e.value - nvl(b.value,0)))  dbt
         from dba_hist_sys_time_model b
            , dba_hist_sys_time_model e
        where e.dbid            = :dbid
          and e.dbid            = b.dbid            (+)
          and e.instance_number = b.instance_number (+)
          and e.snap_id         = :eid
          and b.snap_id   (+)   = :bid
          and b.stat_id   (+)   = e.stat_id
          and e.stat_name = 'DB time'
        group by e.instance_number
      ) tm
   where s.instance_number = tm.instance_number
   group by wc, nm, rollup(s.instance_number)
   )
where rnk <= &&top_n_events
order by inststr, ttm desc, twt desc;

clear breaks computes


repfooter center -
   '-------------------------------------------------------------';


ttitle skip 1 -
       lef 'Top Timed Background Events  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
           '-> % of bg time: % of background elapsed time' -
       skip 1 -
           '-> Instance ''*''  - cluster wide summary' -
       skip 1 -
           '   Waits, Timeouts, Total Wait Time          : Cluster-wide total for the wait event' -
       skip 1 -
           '   ''Avg Wait Time (ms)''                      : Cluster-wide average computed as (Total Wait Time / Waits) in ms' -
       skip 1 -
           '   ''Avg Wait Time (ms)'' Summary of Instances : Per-instance ''Avg Wait Time (ms)'' used to compute the statistics: ' -
       skip 1 -
           '         [Avg|Min|Max|Std Dev]  - average|minimum|maximum|standard deviation of'  -
           ' per-instance ''Avg Wait (ms)''' -
       skip 1 -
           '   Cnt - number of instances with the wait event ' -
       skip 2 -
'                                                                                                 -------- Avg Wait Time (ms) --------' -
       skip 1 -
'                                                                                             Avg         Summary of Instances        ' -
       skip 1;


break on inststr skip 1

select * 
  from ( /* apply rank to get top 10 per instance, rollup cluster-wide totals */
      select lpad(case when s.instance_number is null
                  then  '*'
                  else to_char(s.instance_number,'999')
             end,4)                   inststr
           , wc
           , nm
           , sum(twt)                  twt
           , case when sum(twt) = 0 
                  then null 
                  else sum(tto)/sum(twt)*100 
             end                     pctto
           , sum(ttm)/&ustos           ttm
           , case when sum(twt) = 0 
                  then null 
                  else sum(ttm)/sum(twt)/&ustoms 
             end                      avtm
           , case when s.instance_number is null then avg(avtm) end  avavtm
           , case when s.instance_number is null then min(avtm) end   mintm
           , case when s.instance_number is null then max(avtm) end   maxtm
           , case when s.instance_number is null then stddev_samp(avtm) end stdtm
           , case when s.instance_number is null then count(*) end      cnt
           , case when sum(dbt) = 0 
                  then null 
                  else sum(ttm)/sum(dbt)*100 
             end                    pctbgt
           , rank() over (partition by s.instance_number
                       order by sum(ttm) desc, sum(twt) desc)  rnk
  from (  /* wait events, avg wait time and db cpu per instance */
          ( /* select events per instance */
              select e.event_name                                        nm
                   , e.wait_class                                        wc
                   , e.instance_number
                   , e.total_waits - nvl(b.total_waits,0)               twt
                   , e.total_timeouts - nvl(b.total_timeouts,0)         tto
                   , (e.time_waited_micro - nvl(b.time_waited_micro,0)) ttm
                   , case when (e.total_waits - nvl(b.total_waits,0) = 0) 
                          then null
                          else (e.time_waited_micro - nvl(b.time_waited_micro,0))/
                               (e.total_waits - nvl(b.total_waits,0))/&ustoms  
                     end                                                avtm
             from dba_hist_bg_event_summary e
                , dba_hist_bg_event_summary b
             where e.snap_id         = :eid
               and b.snap_id (+)     = :bid
               and e.dbid            = :dbid
               and e.dbid            = b.dbid             (+)
               and e.instance_number = b.instance_number  (+)
               and e.event_id        = b.event_id         (+)
               and e.event_name      = b.event_name       (+)
               and e.wait_class     != 'Idle'
            )
            union all
            ( /* select time for background CPU */
               select se.stat_name                                    nm
                   , null                                             wc
                   , se.instance_number
                   , null                                            twt
                   , null                                            tto
                   , (se.value - nvl(sb.value,0))                    ttm
                   , null                                           avtm
                from dba_hist_sys_time_model se
                   , dba_hist_sys_time_model sb
               where se.snap_id         = :eid
                 and sb.snap_id  (+)    = :bid
                 and se.dbid            = :dbid
                 and se.dbid            = sb.dbid            (+)
                 and se.instance_number = sb.instance_number (+)
                 and se.stat_name       = 'background cpu time'
                 and se.stat_name       = sb.stat_name       (+)
                 and se.stat_id         = sb.stat_id         (+)
            )
      )  s
    , (select e.instance_number
            , sum((e.value - nvl(b.value,0)))  dbt
         from dba_hist_sys_time_model b
            , dba_hist_sys_time_model e
        where e.dbid            = :dbid
          and e.dbid            = b.dbid            (+)
          and e.instance_number = b.instance_number (+)
          and e.snap_id         = :eid
          and b.snap_id   (+)   = :bid
          and b.stat_id   (+)   = e.stat_id
          and e.stat_name = 'background elapsed time'
        group by e.instance_number
      ) tm
   where s.instance_number = tm.instance_number
   group by wc, nm, rollup(s.instance_number)
   )
where rnk <= &&top_n_events
order by inststr, ttm desc, twt desc;



clear breaks computes


repfooter center -
   '-------------------------------------------------------------';

-- ------------------------------------------------------------------
-- 
-- SQL Reporting

-- Get the captured vs. total workload ratios

set newpage none
set heading off
set termout off
ttitle off
repfooter off

col bufcappct new_value bufcappct noprint
col getsa     new_value getsa     noprint
col phycappct new_value phycappct noprint
col phyra     new_value phyra     noprint
col execappct new_value execappct noprint
col exea      new_value exea      noprint
col prscappct new_value prscappct noprint
col prsea     new_value prsea     noprint
col cpucappct new_value cpucappct noprint
col elacappct new_value elacappct noprint
col dbcpua    new_value dbcpua    noprint
col dbcpu_s   new_value dbcpu_s   noprint
col dbtima    new_value dbtima    noprint
col dbtim_s   new_value dbtim_s   noprint
col clucappct new_value clucappct noprint
col clutm_s   new_value clutm_s   noprint
col iowcappct new_value iowcappct noprint
col iowtm_s   new_value iowtm_s   noprint

col plcpucappct new_value plcpucappct noprint
col plelacappct new_value plelacappct noprint

select case when :tgets = 0 then to_number(null)
            else 100*buffer_gets_delta/:tgets
       end                                            bufcappct
     , :tgets                                         getsa
     , case when :trds = 0 then to_number(null)
            else 100*disk_reads_delta/:trds           
       end                                            phycappct
     , :trds                                          phyra
     , case when :texecs = 0 then to_number(null)
             else 100*executions_delta/:texecs
       end                                            execappct
     , :texecs                                        exea
     , case when :tdbcpu = 0 then to_number(null)
            else 100*cpu_time_delta/:tdbcpu 
       end                                            cpucappct
     , case when :tdbcpu = 0 then to_number(null)
            else 100*plcpu_time_delta/:tdbcpu 
       end                                            plcpucappct
     , :tdbcpu                                        dbcpua
     , :tdbcpu/&&ustos                                dbcpu_s
     , case when :tdbtim = 0 then to_number(null)
            else 100*elapsed_time_delta/:tdbtim
       end                                            elacappct
     , case when :tdbtim = 0 then to_number(null)
            else 100*plelapsed_time_delta/:tdbtim
       end                                            plelacappct
     , :tdbtim                                        dbtima
     , :tdbtim/&&ustos                                dbtim_s
     , case when :tclutm = 0 then to_number(null)
            else 100*clwait_delta/:tclutm
       end                                            clucappct
     , :tclutm/&&ustos                                clutm_s
     , case when :tiowtm = 0 then to_number(null)
            else 100*iowait_delta/:tiowtm
       end                                            iowcappct
     , :tiowtm/&&ustos                                iowtm_s
from (
   select sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
               else e.buffer_gets_delta
              end)                                    buffer_gets_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
               else e.disk_reads_delta
              end)                                    disk_reads_delta
        , sum(e.executions_delta)                     executions_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
                   else e.cpu_time_delta
              end)                                    cpu_time_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then e.cpu_time_delta
                   else 0
              end)                                    plcpu_time_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
                   else e.elapsed_time_delta
              end)                                    elapsed_time_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then e.elapsed_time_delta
                   else 0
              end)                                    plelapsed_time_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
                   else e.clwait_delta
              end)                                    clwait_delta
        , sum(case when st.command_type = 47 
                     or st.command_type = 170 then 0
                   else e.iowait_delta
              end)                                    iowait_delta
     from dba_hist_sqlstat e
        , dba_hist_sqltext st
    where e.snap_id            > :bid
      and e.snap_id           <= :eid
      and e.dbid               = :dbid
      and e.sql_id             = st.sql_id
      and e.dbid               = st.dbid);


-- ------------------------------------------------------------

set newpage 0
set termout on;
set heading on;
repfooter center -
   '-------------------------------------------------------------';

--
-- SQL ordered by Elapsed

ttitle skip 1 -
       lef 'SQL ordered by Elapsed Time (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total DB time (s): ' format 99,999,999,999 dbtim_s -
       skip 1 -
       '-> Captured SQL    accounts for ' format 990.9 elacappct '% of Total DB time' -
       skip 1 -
       '-> Captured PL/SQL accounts for ' format 990.9 plelacappct '% of Total DB time' -
       skip 2;

break on sql_id skip 1
col sql_id       format a13           heading 'SQL Id'
col sqt          format a50  trunc    heading 'SQL Text'
col execs        format    999,999,990  heading 'Execs'
col gets         format  9,999,999,990  heading 'Gets'
col bpe          format  999,999,990.0  heading 'per Exec'
col reads        format    999,999,990  heading 'Reads'
col rpe          format    9,999,990.0  heading 'per Exec'
col rws          format    999,999,990  heading 'Rows'
col rwpe         format    9,999,990.0  heading 'per Exec'
col cpu_time     format     999,990.90  heading 'CPU (s)'
col cppe         format     999,990.90   heading 'per Exec(s)'
col elapsed_time format   9,999,990.90  heading 'Ela (s)'
col elpe         format   9,999,990.90   heading 'per Exec(s)' 
col clwait_time  format     999,990.90  heading 'Clu (s)'
col clpe         format     999,990.90  heading 'per Exe(s)' 
col iowait_time  format     999,990.90  heading 'IOWait (s)'
col iope         format     999,990.90  heading 'per Exe(s)' 

col nl           format  a13 newline  heading ''
col bp           heading ''
col ela_pct_dbt  format  9,999,990.90  heading '% of DB time'
col cpu_pct      format    999,990.90  heading '% of DB CPU'
col gets_pct     format 99,999,990.90 heading '% of Gets'
col rds_pct      format   9999,990.90  heading '% of Reads'
col execs_pct    format   9999,990.90  heading '% of Execs'
col clwait_pct   format    999,990.90  heading '% of CluTm'
col iowait_pct   format    999,990.90  heading '% of IO Tm'

col ep           format a12       heading ''
col sqtn         format a50 trunc heading ''

select s.sql_id
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , iowait_time/&ustos    iowait_time
     , gets
     , reads
     , rws
     , clwait_time/&ustos    clwait_time
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , elapsed_time/&ustos/decode(execs,0,null,execs)          elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)              cppe
     , iowait_time/&ustos/decode(execs,0,null,execs)           iope
     , gets/decode(execs,0,null,execs)                         bpe
     , reads/decode(execs,0,null,execs)                        rpe
     , rws/decode(execs,0,null,execs)                          rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)           clpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn
     , '            ' nl
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100         ela_pct_dbt
     -- , '                                                                ' bp
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100             cpu_pct
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100        iowait_pct
     , gets/decode(:tgets,0,null,:tgets)*100                   gets_pct
     , reads/decode(:trds,0,null,:trds)*100                    rds_pct
     , '            '                                          bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100          clwait_pct
     , execs/decode(:texecs,0,null,:texecs)*100                execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(clwait_delta)         clwait_time
           , sum(iowait_delta)         iowait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(elapsed_time_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by elapsed_time desc, sql_id;



--
-- SQL ordered by CPU

ttitle skip 1 -
       lef 'SQL ordered by CPU Time (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total DB CPU (s): ' format 99,999,999,999 dbcpu_s -
       skip 1 -
       '-> Captured SQL    accounts for ' format 990.9 cpucappct '% of Total DB CPU' -
       skip 1 -
       '-> Captured PL/SQL accounts for ' format 990.9 plcpucappct '% of Total DB CPU' -
       skip 2;

select s.sql_id
     , cpu_time/&ustos       cpu_time
     , elapsed_time/&ustos   elapsed_time
     , iowait_time/&ustos    iowait_time
     , gets
     , reads
     , rws
     , clwait_time/&ustos    clwait_time
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , iowait_time/&ustos/decode(execs,0,null,execs)        iope
     , gets/decode(execs,0,null,execs)                      bpe
     , reads/decode(execs,0,null,execs)                     rpe
     , rws/decode(execs,0,null,execs)                       rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)        clpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100 cpu_pct
     -- , '                                                                  ' bp
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100       ela_pct_dbt
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100        iowait_pct
     , gets/decode(:tgets,0,null,:tgets)*100                 gets_pct
     , reads/decode(:trds,0,null,:trds)*100                  rds_pct
     , '            '                                        bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100        clwait_pct
     , execs/decode(:texecs,0,null,:texecs)*100              execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(cpu_time_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by cpu_time desc, sql_id;

--
-- SQL ordered by User I/O Time

ttitle skip 1 -
       lef 'SQL ordered by User I/O Time (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total User I/O Wait Time (s): ' format 99,999,999,999 iowtm_s -
       skip 1 -
       '-> Captured SQL accounts for ' format 990.9  iowcappct '% of Total User I/O Wait Time' -
       skip 2;

select s.sql_id
     , iowait_time/&ustos    iowait_time
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , gets
     , reads
     , rws
     , clwait_time/&ustos    clwait_time
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , iowait_time/&ustos/decode(execs,0,null,execs)        iope
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , gets/decode(execs,0,null,execs)                      bpe
     , reads/decode(execs,0,null,execs)                     rpe
     , rws/decode(execs,0,null,execs)                       rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)        clpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100    iowait_pct    
     -- , '                                                                  ' bp
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100  ela_pct_dbt
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100          cpu_pct
     , gets/decode(:tgets,0,null,:tgets)*100               gets_pct
     , reads/decode(:trds,0,null,:trds)*100                 rds_pct
     , '            '                                            bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100    clwait_pct
     , execs/decode(:texecs,0,null,:texecs)*100           execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(iowait_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by iowait_time desc, reads desc, sql_id;



--
-- SQL ordered by Gets

ttitle skip 1 -
       lef 'SQL ordered by Gets (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total Buffer Gets: ' format 99,999,999,999 getsa -
       skip 1 -
       '-> Captured SQL accounts for   ' format 990.9 bufcappct '% of Total Buffer Gets' -
       skip 2;

select s.sql_id
     , gets
     , reads
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , iowait_time/&ustos    iowait_time
     , rws
     , clwait_time/&ustos    clwait_time
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , gets/decode(execs,0,null,execs)                      bpe
     , reads/decode(execs,0,null,execs)                     rpe
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , iowait_time/&ustos/decode(execs,0,null,execs)        iope
     , rws/decode(execs,0,null,execs)                       rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)        clpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , gets/decode(:tgets,0,null,:tgets)*100                gets_pct
     -- , '                                                               ' bp
     , reads/decode(:trds,0,null,:trds)*100                 rds_pct
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100  ela_pct_dbt
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100          cpu_pct
     , iowait_time/decode(:tclutm,0,null,:tclutm)*100     iowait_pct
     , '            '                                            bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100     clwait_pct
     , execs/decode(:texecs,0,null,:texecs)*100            execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(buffer_gets_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by gets desc, cpu_time desc, sql_id;

--
-- SQL ordered by Reads

ttitle skip 1 -
       lef 'SQL ordered by Reads (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total Disk Reads: ' format 99,999,999,999 phyra -
       skip 1 -
       '-> Captured SQL accounts for  ' format 990.9 phycappct '% of Total Disk Reads' -
       skip 2;

select s.sql_id
     , reads
     , gets
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , iowait_time/&ustos    iowait_time
     , rws
     , clwait_time/&ustos    clwait_time
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , reads/decode(execs,0,null,execs)                     rpe
     , gets/decode(execs,0,null,execs)                      bpe
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , iowait_time/&ustos/decode(execs,0,null,execs)        iope
     , rws/decode(execs,0,null,execs)                       rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)        clpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , reads/decode(:trds,0,null,:trds)*100              rds_pct
     -- , '                                                                 ' bp
     , gets/decode(:tgets,0,null,:tgets)*100            gets_pct
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100  ela_pct_dbt
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100       cpu_pct
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100  iowait_pct
     , '            '                                         bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100  clwait_pct
     , execs/decode(:texecs,0,null,:texecs)*100         execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)   sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(disk_reads_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by reads desc, iowait_time desc, sql_id;


--
-- SQL ordered by Cluster Time

ttitle skip 1 -
       lef 'SQL ordered by Cluster Time (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total Cluster Wait Time (s): ' format 99,999,999,999 clutm_s -
       skip 1 -
       '-> Captured SQL accounts for ' format 990.9 clucappct '% of Total Cluster Wait Time' -
       skip 2;

select s.sql_id
     , clwait_time/&ustos    clwait_time
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , iowait_time/&ustos    iowait_time
     , gets
     , reads
     , rws
     , execs
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , clwait_time/&ustos/decode(execs,0,null,execs)        clpe
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , iowait_time/&ustos/decode(execs,0,null,execs)        iope
     , gets/decode(execs,0,null,execs)                      bpe
     , reads/decode(execs,0,null,execs)                     rpe
     , rws/decode(execs,0,null,execs)                       rwpe
     , '          '    ep
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100    clwait_pct
     -- , '                                                                  ' bp
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100  ela_pct_dbt
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100          cpu_pct
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100     iowait_pct
     , gets/decode(:tgets,0,null,:tgets)*100               gets_pct
     , reads/decode(:trds,0,null,:trds)*100                 rds_pct
     , '            '                                            bp
     , execs/decode(:texecs,0,null,:texecs)*100           execs_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(clwait_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by clwait_time desc, sql_id;

--
-- SQL ordered by Executions

ttitle skip 1 -
       lef 'SQL ordered by Executions (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '-> Total Executions: ' format 99,999,999,999 exea -
       skip 1 -
       '-> Captured SQL accounts for   ' format 990.9 execappct '% of Total Executions' -
       skip 2;

select s.sql_id
     , execs
     , elapsed_time/&ustos   elapsed_time
     , cpu_time/&ustos       cpu_time
     , iowait_time/&ustos    iowait_time
     , gets
     , reads
     , rws
     , clwait_time/&ustos    clwait_time
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),1,50) sqt
     , '             ' nl
     , '            '    ep
     , elapsed_time/&ustos/decode(execs,0,null,execs)       elpe
     , cpu_time/&ustos/decode(execs,0,null,execs)           cppe
     , iowait_time/&ustos/decode(execs,0,null,execs)  iope
     , gets/decode(execs,0,null,execs)                      bpe
     , reads/decode(execs,0,null,execs)                     rpe
     , rws/decode(execs,0,null,execs)                       rwpe
     , clwait_time/&ustos/decode(execs,0,null,execs)  clpe
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),51,50)   sqtn           
     , '            ' nl
     , execs/decode(:texecs,0,null,:texecs)*100        execs_pct
     -- , '                                                                              ' bp
     , elapsed_time/decode(:tdbtim,0,null,:tdbtim)*100  ela_pct_dbt
     , cpu_time/decode(:tdbcpu,0,null,:tdbcpu)*100          cpu_pct
     , iowait_time/decode(:tiowtm,0,null,:tiowtm)*100    iowait_pct
     , gets/decode(:tgets,0,null,:tgets)*100               gets_pct
     , reads/decode(:trds,0,null,:trds)*100                 rds_pct
     , '            '                                            bp
     , clwait_time/decode(:tclutm,0,null,:tclutm)*100    clwait_pct
     , substr(regexp_replace(st.sql_text,'(\s)+',' '),101,50)  sqtn
  from   
   (select * from
      ( select sql_id
           , sum(executions_delta)      execs
           , sum(buffer_gets_delta)     gets
           , sum(disk_reads_delta)      reads
           , sum(rows_processed_delta)  rws
           , sum(cpu_time_delta)        cpu_time
           , sum(elapsed_time_delta)         elapsed_time
           , sum(iowait_delta)         iowait_time
           , sum(clwait_delta)         clwait_time
        from dba_hist_sqlstat
       where snap_id  > :bid
         and snap_id <= :eid
         and dbid     = :dbid
       group by sql_id
       order by sum(executions_delta) desc)
    where rownum <= &&top_n_sql ) s
  , dba_hist_sqltext st
 where st.dbid = :dbid
   and st.sql_id = s.sql_id
 order by execs desc, sql_id;


clear breaks computes

--
-- Segment Statistics
--

ttitle skip 1 -
       lef 'Segment Statistics (Global)   '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       lef '-> % Total shows % of statistic for each segment compared to the global cluster-wide total ' -
       skip 1 - 
       lef '   % Total is not calculated for  buffer busy waits, ITL waits, row lock waits, gc buffer busy ' -
       skip 1 -
       lef '-> % Capture shows % of statistic for each segment compared to the total captured ' -
       skip 1 -
       lef '   by AWR for all segments during the snapshot interval' -
       skip 2 ;

break on statistic_name skip 1

column owner           heading 'Owner'           format a10 trunc
column statistic_name  heading 'Statistic'       format a22
column tablespace_name heading 'Tablespace|Name' format a10 trunc
column object_type     heading 'Obj.|Type'       format a5 trunc
column object_name     heading 'Object|Name'     format a20 trunc
column subobject_name  heading 'Subobject|Name'  format a10 trunc
column value           heading 'Value'           format 999,999,999
column ratio           heading '%Capture' format 990.0
column pct             heading '%Total'   format 990.0
column rnk             format 999 noprint


-- using this for now until bug5905759 is fixed
-- 
select ss.stat_name                                            statistic_name
     , n.owner
     , n.tablespace_name
     , n.object_name
     , case when length(n.subobject_name) < 11 
            then n.subobject_name
            else substr(n.subobject_name,length(n.subobject_name)-9)
       end                                                     subobject_name
     , n.object_type
     , value
     , case when stat_name = 'logical reads'         then value/:tgets*100
            when stat_name = 'db block changes'      then value/:tdbch*100
            when stat_name = 'physical reads'        then value/:trds*100
            when stat_name = 'physical reads direct' then value/:trdds*100
            when stat_name = 'physical writes'       then value/:twrs*100
            when stat_name = 'physical writes direct' then value/:twrds*100
            when stat_name = 'table scans'           then value/(:ttslt + :tiffs)*100
            when stat_name = 'gc cr blocks received' then value/:tgccrr*100
            when stat_name = 'gc cu blocks received' then value/:tgccur*100
            when stat_name = 'gc cr blocks served'   then value/:tgccrs*100
            when stat_name = 'gc cu blocks served'   then value/:tgccus*100
            else null
       end                                                                pct
     , (ratio_to_report(value) over (partition by stat_name))*100       ratio
     , rnk
  from ( /* now unpivot the result set for display purposes */
      select dataobj#
           , obj#
           , dbid
           , stat_name
           , case when stat_name = 'logical reads'          then lr
                  when stat_name = 'buffer busy waits'      then bbw
                  when stat_name = 'db block changes'       then dbc
                  when stat_name = 'physical reads'         then pr
                  when stat_name = 'physical writes'        then pw
                  when stat_name = 'physical reads direct'  then prd
                  when stat_name = 'physical writes direct' then pwd
                  when stat_name = 'ITL waits'              then iw
                  when stat_name = 'row lock waits'         then rlw
                  when stat_name = 'gc cr blocks served'    then gcrs
                  when stat_name = 'gc cu blocks served'    then gcus
                  when stat_name = 'gc buffer busy'         then gbb
                  when stat_name = 'gc cr blocks received'  then gcrr
                  when stat_name = 'gc cu blocks received'  then gcur
                  when stat_name = 'table scans'            then ts
                  else 0
             end  value
           , case when stat_name = 'logical reads'          then rnk_lr
                  when stat_name = 'buffer busy waits'      then rnk_bbw
                  when stat_name = 'db block changes'       then rnk_dbc
                  when stat_name = 'physical reads'         then rnk_pr
                  when stat_name = 'physical writes'        then rnk_pw
                  when stat_name = 'physical reads direct'  then rnk_prd
                  when stat_name = 'physical writes direct' then rnk_pwd
                  when stat_name = 'ITL waits'              then rnk_iw
                  when stat_name = 'row lock waits'         then rnk_rlw
                  when stat_name = 'gc cr blocks served'    then rnk_gcrs
                  when stat_name = 'gc cu blocks served'    then rnk_gcus
                  when stat_name = 'gc buffer busy'         then rnk_gbb
                  when stat_name = 'gc cr blocks received'  then rnk_gcrr
                  when stat_name = 'gc cu blocks received'  then rnk_gcur
                  when stat_name = 'table scans'            then rnk_ts
                  else 0
             end  rnk
        from ( /* select top n for each statistic */
             select * from 
                (/* select objects and rank per statistic*/
                select e.dataobj#
                     , e.obj#
                     , e.dbid
                     , sum(logical_reads_delta)          lr
                     , sum(buffer_busy_waits_delta)      bbw
                     , sum(db_block_changes_delta)       dbc
                     , sum(physical_reads_delta)         pr
                     , sum(physical_writes_delta)        pw
                     , sum(physical_reads_direct_delta)  prd
                     , sum(physical_writes_direct_delta) pwd
                     , sum(itl_waits_delta)              iw
                     , sum(row_lock_waits_delta)         rlw
                     , sum(gc_cr_blocks_served_delta)    gcrs
                     , sum(gc_cu_blocks_served_delta)    gcus
                     , sum(gc_buffer_busy_delta)         gbb
                     , sum(gc_cr_blocks_received_delta)  gcrr
                     , sum(gc_cu_blocks_received_delta)  gcur
                     , sum(table_scans_delta)            ts
                     , rank () over (order by 
                          sum(logical_reads_delta)     desc)         rnk_lr
                     , rank () over (order by 
                          sum(buffer_busy_waits_delta) desc)        rnk_bbw
                     , rank () over (order by 
                          sum(db_block_changes_delta)  desc)        rnk_dbc
                     , rank () over (order by 
                          sum(physical_reads_delta)    desc)         rnk_pr
                     , rank () over (order by 
                          sum(physical_writes_delta)   desc)         rnk_pw
                     , rank () over (order by 
                          sum(physical_reads_direct_delta)  desc)   rnk_prd
                     , rank () over (order by 
                          sum(physical_writes_direct_delta) desc)   rnk_pwd
                     , rank () over (order by 
                          sum(itl_waits_delta)         desc)         rnk_iw
                     , rank () over (order by 
                          sum(row_lock_waits_delta)    desc)        rnk_rlw
                     , rank () over (order by 
                          sum(gc_cr_blocks_served_delta) desc)     rnk_gcrs
                     , rank () over (order by 
                          sum(gc_cu_blocks_served_delta) desc)     rnk_gcus
                     , rank () over (order by 
                          sum(gc_buffer_busy_delta)      desc)      rnk_gbb
                     , rank () over (order by 
                          sum(gc_cr_blocks_received_delta) desc)   rnk_gcrr
                     , rank () over (order by 
                          sum(gc_cu_blocks_received_delta) desc)   rnk_gcur
                     , rank () over (order by 
                          sum(table_scans_delta)         desc)       rnk_ts
                 from dba_hist_seg_stat  e
                where e.dbid    = :dbid
                  and snap_id   > :bid
                  and snap_id   <= :eid
                group by e.dataobj#, e.obj#, e.dbid
               )
             where rnk_lr   <= &top_n_segstat 
                or rnk_bbw  <= &top_n_segstat
                or rnk_dbc  <= &top_n_segstat
                or rnk_pr   <= &top_n_segstat
                or rnk_pw   <= &top_n_segstat
                or rnk_prd  <= &top_n_segstat
                or rnk_pwd  <= &top_n_segstat
                or rnk_iw   <= &top_n_segstat
                or rnk_rlw  <= &top_n_segstat
                or rnk_gcrs <= &top_n_segstat
                or rnk_gcus <= &top_n_segstat
                or rnk_gbb  <= &top_n_segstat
                or rnk_gcrr <= &top_n_segstat
                or rnk_gcur <= &top_n_segstat
                or rnk_ts   <= &top_n_segstat
             )  r
           , ( /* used to generate cartesian join for unpivot */
              select 'logical reads'          stat_name from dual union all
              select 'buffer busy waits'      stat_name from dual union all
              select 'db block changes'       stat_name from dual union all
              select 'physical reads'         stat_name from dual union all
              select 'physical writes'        stat_name from dual union all
              select 'physical reads direct'  stat_name from dual union all
              select 'physical writes direct' stat_name from dual union all
              select 'ITL waits'              stat_name from dual union all
              select 'row lock waits'         stat_name from dual union all
              select 'gc cr blocks served'    stat_name from dual union all
              select 'gc cu blocks served'    stat_name from dual union all
              select 'gc buffer busy'         stat_name from dual union all
              select 'gc cr blocks received'  stat_name from dual union all
              select 'gc cu blocks received'  stat_name from dual union all
              select 'table scans'            stat_name from dual
            ) d
      ) ss
   , dba_hist_seg_stat_obj n
 where ss.dataobj# = n.dataobj#
   and ss.obj#     = n.obj#
   and ss.dbid     = n.dbid
   and ss.rnk     <= &top_n_segstat
   and value       > 0
order by stat_name, value desc, object_name;


-- commenting out until bug5905759 is fixed
-- select lower(replace(replace(ss.stat_name,'_DELTA',''),'_',' '))  statistic_name
--      , n.owner
--      , n.tablespace_name
--      , n.object_name
--      , case when length(n.subobject_name) < 11 
--             then n.subobject_name
--             else substr(n.subobject_name,length(n.subobject_name)-9)
--        end                                                     subobject_name
--      , n.object_type
--      , value
--      , case when stat_name = 'LOGICAL_READS_DELTA'       then value/:tgets*100
--             when stat_name = 'PHYSICAL_READS_DELTA'      then value/:trds*100
--             when stat_name = 'GC_CR_BLOCKS_SERVED_DELTA' then value/:tgccrs*100
--             when stat_name = 'GC_CU_BLOCKS_SERVED_DELTA' then value/:tgccus*100
--             when stat_name = 'GC_CR_BLOCKS_RECEIVED_DELTA' then value/:tgccrr*100
--             when stat_name = 'GC_CU_BLOCKS_RECEIVED_DELTA' then value/:tgccur*100
--             else null
--        end                                                                pct
--      , (ratio_to_report(value) over (partition by stat_name))*100       ratio
--      , rnk
--    from (select /* top n segments */
--           dbid, ts#, obj#, dataobj#, stat_name, value, rnk
--      from (
--       select /* value and rank, unpivoted */ 
--              dbid
--            , ts#
--            , obj#
--            , dataobj#
--            , stat_name
--            , sum(value) value
--           , rank () over (partition by stat_name
--                           order by (sum(value))     desc)         rnk
--         from
--          ((select *
--               from dba_hist_seg_stat
--             where dbid = :dbid
--               and snap_id > :bid
--               and snap_id <= :eid)
--           unpivot (value for stat_name in (logical_reads_delta
--                                          ,buffer_busy_waits_delta
--                                          ,db_block_changes_delta
--                                          ,physical_reads_delta
--                                          ,physical_writes_delta
--                                          ,physical_reads_direct_delta
--                                          ,physical_writes_direct_delta
--                                          ,itl_waits_delta
--                                          ,row_lock_waits_delta
--                                          ,gc_cr_blocks_served_delta
--                                          ,gc_cu_blocks_served_delta
--                                          ,gc_cr_blocks_received_delta
--                                          ,gc_cu_blocks_received_delta
--                                          ,gc_buffer_busy_delta
--                                          ,table_scans_delta )))
--        group by  dbid, ts#, obj#,dataobj#,stat_name)
--     where rnk <= &top_n_segstat) ss
--    , dba_hist_seg_stat_obj n
--  where ss.dataobj# = n.dataobj#
--    and ss.obj#     = n.obj#
--    and ss.dbid     = n.dbid  -- dumping core when pushing pred to unpivot
--    -- and n.dbid     = :dbid
--    and ss.rnk     <= &top_n_segstat
--    and value       > 0
-- order by stat_name, value desc;



clear breaks computes

--
-- SysStat Section

ttitle skip 1 -
       lef 'SysStat (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> per Second Average - average of per-instance per Second rates' -
       skip 1 -
       '   per Second Std Dev - standard deviation of per-instance per Second rates' -
       skip 1 -
       '   per Second Min     - minium of per-instance per Second rates' -
       skip 1 -
       '   per Second Max     - maximum of per-instance per Second rates' -
       skip 2;

column st  format a60                  heading 'Statistic' trunc just l;
column dif format 9,999,999,999,990    heading 'Total';
column ps  format       999,999,990.0  heading 'per Second';
column pt  format         9,999,990.0  heading 'per Trans';
column ps_avg format     99,999,990.0  heading 'per Second|Average'
column ps_std format     99,999,990.0  heading 'per Second|Std Dev'
column ps_min format     99,999,990.0  heading 'per Second|Min'
column ps_max format     99,999,990.0  heading 'per Second|Max'

select ss.stat_name              st
     , sum(ss.dif)               dif
     , sum(ss.dif/s_et)          ps
     , sum(ss.dif)/decode((:tucm+:tur),0,1,(:tucm+:tur))  pt
     , avg(ss.dif/s_et)          ps_avg
     , stddev_samp(ss.dif/s_et)  ps_std
     , min(ss.dif/s_et)          ps_min
     , max(ss.dif/s_et)          ps_max
  from
   ( select se.stat_name                           
        , se.instance_number
        , sum(se.value - nvl(sb.value,0))          dif
     from dba_hist_sysstat se
        , dba_hist_sysstat sb
    where se.dbid            = :dbid
      and sb.snap_id (+)     = :bid
      and se.snap_id         = :eid
      and se.dbid            = sb.dbid            (+)
      and se.instance_number = sb.instance_number (+)
      and se.stat_id         = sb.stat_id         (+)
      and se.value           > nvl(sb.value,0)
      and se.stat_name  not in ('logons current'
                              , 'opened cursors current'
                              , 'workarea memory allocated'
                              , 'session cursor cache count'
                              , 'session pga memory'
                              , 'session pga memory max'
                              , 'session uga memory'
                              , 'session uga memory max'
                             )
    group by se.stat_name, se.instance_number) ss
  , (select e.instance_number
        , extract(DAY    from e.end_interval_time - b.end_interval_time) * 86400
        + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
        + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
        + extract(SECOND from e.end_interval_time - b.end_interval_time)  s_et
       from dba_hist_snapshot e
          , dba_hist_snapshot b
      where e.dbid            = :dbid
        and b.snap_id         = :bid
        and e.snap_id         = :eid
        and e.dbid            = b.dbid
        and e.instance_number = b.instance_number
    ) s
 where ss.instance_number = s.instance_number
 group by ss.stat_name
 order by ss.stat_name;



--
-- Misc GES RAC Statistics

ttitle skip 1 -
       lef 'Global Enqueue Statistics (Global)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> per Second Average - average of per-instance per Second rates' -
       skip 1 -
       '   per Second Std Dev - standard deviation of per-instance per Second rates' -
       skip 1 -
       '   per Second Min     - minium of per-instance per Second rates' -
       skip 1 -
       '   per Second Max     - maximum of per-instance per Second rates' -
       skip 2;

column st  format a60                  heading 'Statistic' trunc just l;
column dif format 9,999,999,999,990    heading 'Total';
column ps  format       999,999,990.0  heading 'per Second';
column pt  format         9,999,990.0  heading 'per Trans';
column ps_avg format     99,999,990.0  heading 'per Second|Average'
column ps_std format     99,999,990.0  heading 'per Second|Std Dev'
column ps_min format     99,999,990.0  heading 'per Second|Min'
column ps_max format     99,999,990.0  heading 'per Second|Max'

select ss.name                   st
     , sum(ss.dif)               dif
     , sum(ss.dif/s_et)          ps
     , sum(ss.dif)/decode((:tucm+:tur),0,1,(:tucm+:tur))  pt
     , avg(ss.dif/s_et)          ps_avg
     , stddev_samp(ss.dif/s_et)  ps_std
     , min(ss.dif/s_et)          ps_min
     , max(ss.dif/s_et)          ps_max
  from
   ( select se.name                           
        , se.instance_number
        , sum(se.value - nvl(sb.value,0))          dif
     from dba_hist_dlm_misc se
        , dba_hist_dlm_misc sb
    where se.dbid            = :dbid
      and sb.snap_id (+)     = :bid
      and se.snap_id         = :eid
      and se.dbid            = sb.dbid            (+)
      and se.instance_number = sb.instance_number (+)
      and se.statistic#      = sb.statistic#      (+)
      and se.value           > nvl(sb.value,0)
    group by se.name, se.instance_number) ss
  , (select e.instance_number
        , extract(DAY    from e.end_interval_time - b.end_interval_time) * 86400
        + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
        + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
        + extract(SECOND from e.end_interval_time - b.end_interval_time)  s_et
       from dba_hist_snapshot e
          , dba_hist_snapshot b
      where e.dbid            = :dbid
        and b.snap_id         = :bid
        and e.snap_id         = :eid
        and e.dbid            = b.dbid
        and e.instance_number = b.instance_number
    ) s
 where ss.instance_number = s.instance_number
 group by ss.name
 order by ss.name;
 
clear breaks computes

-- ------------------------------------------------------------------

set newpage 0;

ttitle skip 1 -
       lef 'SysStat (Absolute Values)  '-
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 2 -
       '     ---- Sessions --- ------- Open Cursors ------ -- Session Cached Cursors --'

break on report;
compute sum avg std of lc_b  on report
compute sum avg std of lc_e  on report
compute sum avg std of occ_b on report
compute sum avg std of occ_e on report
compute sum avg std of sccc_b on report
compute sum avg std of sccc_e on report

col lc_b   format       999,990 heading 'Begin'
col lc_e   format       999,990 heading 'End'
col occ_b  format 9,999,999,990 heading 'Begin'
col occ_e  format   999,999,990 heading 'End'
col sccc_b format 9,999,999,990 heading 'Begin'
col sccc_e format   999,999,990 heading 'End'

select instance_number
     , lc_b
     , lc_e
     , occ_b
     , occ_e
     , sccc_b
     , sccc_e
  from 
((select se.instance_number
     , se.stat_name
     , sb.value    bval
     , se.value    eval
  from dba_hist_sysstat sb
     , dba_hist_sysstat se
 where se.dbid          = :dbid
 and sb.snap_id (+)     = :bid
 and se.snap_id         = :eid
 and se.dbid            = sb.dbid            (+)
 and se.instance_number = sb.instance_number (+)
 and se.stat_id         = sb.stat_id         (+)
 and se.stat_name  in ('logons current'
                     , 'opened cursors current'
                     , 'session cursor cache count'))
pivot (max(bval) b, max(eval) e for stat_name in (
                           'logons current'            lc
                         , 'opened cursors current'     occ
                         , 'session cursor cache count' sccc)))
order by instance_number;

clear breaks computes

-- ------------------------------------------------------------------
set newpage 2

ttitle skip 1 -
       lef 'IOStat by Function (per Second) ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> Total Reads  includes all Functions: Buffer Cache, Direct Reads, ARCH, Data Pump, Others, RMAN, Recovry, Streams/AQ and XDB' -
       skip 1 -
       '-> Total Writes includes all Functions: DBWR, Direct Writes,  LGWR, ARCH, Data Pump, Others, RMAN, Recovry, Streams/AQ and XDB' -
       skip 2 -
'     ------------------------------ Megabytes/sec ----------------------------------- ------------------------------- Requests/sec -----------------------------------' -
       skip 1 -
'     --------------- Reads ------------ ------------------ Writes ------------------- --------------- Reads ------------ ----------------- Writes --------------------';

col instance_number format 999 heading 'I#'
col total_rds       format 9,999,990.0 heading 'Total'           just c
col bc_rds          format   999,990.0 heading 'Buffer|Cache'    just c
col dr_rds          format   999,990.0 heading 'Direct|Reads'    just c
col total_wrs       format 9,999,990.0 heading 'Total'           just c
col dbwr_wrs        format   999,990.0 heading 'DBWR'            just c
col dw_wrs          format   999,990.0 heading 'Direct|Writes'   just c
col lgwr_wrs        format   999,990.0 heading 'LGWR'            just c
col total_rrq       format 9,999,990.0 heading 'Total'           just c
col bc_rrq          format   999,990.0 heading 'Buffer|Cache'    just c
col dr_rrq          format   999,990.0 heading 'Direct|Reads'    just c
col total_wrq       format 9,999,990.0 heading 'Total'           just c
col dbwr_wrq        format   999,990.0 heading 'DBWR'            just c
col dw_wrq          format   999,990.0 heading 'Direct|Writes'   just c
col lgwr_wrq        format   999,990.0 heading 'LGWR'            just c


break on report
compute sum avg of total_rds on report
compute sum avg of bc_rds    on report
compute sum avg of dr_rds    on report
compute sum avg of total_wrs on report
compute sum avg of dbwr_wrs  on report
compute sum avg of dw_wrs    on report
compute sum avg of lgwr_wrs  on report
compute sum avg of total_rrq on report
compute sum avg of bc_rrq    on report
compute sum avg of dr_rrq    on report
compute sum avg of total_wrq on report
compute sum avg of dbwr_wrq  on report
compute sum avg of dw_wrq    on report
compute sum avg of lgwr_wrq  on report



select s.instance_number
     , io.total_rds/s_et     total_rds
     , io.bc_rds/s_et           bc_rds
     , io.dr_rds/s_et           dr_rds
     , io.total_wrs/s_et     total_wrs
     , io.dbwr_wrs/s_et       dbwr_wrs
     , io.dw_wrs/s_et           dw_wrs
     , io.lgwr_wrs/s_et       lgwr_wrs
     , io.total_rrq/s_et     total_rrq
     , io.bc_rrq/s_et           bc_rrq
     , io.dr_rrq/s_et           dr_rrq
     , io.total_wrq/s_et     total_wrq
     , io.dbwr_wrq/s_et       dbwr_wrq
     , io.dw_wrq/s_et           dw_wrq
     , io.lgwr_wrq/s_et       lgwr_wrq     
   from (select instance_number
        , bc_rds + dr_rds
          + arch_rds + dbwr_rds + dp_rds + dw_rds + lgwr_rds 
          + oth_rds + rman_rds + reco_rds + saq_rds + xdb_rds  total_rds
        , bc_rds      bc_rds
        , dr_rds      dr_rds
        , dbwr_wrs + dw_wrs + lgwr_wrs 
          + arch_wrs + bc_wrs + dp_wrs + dr_wrs + oth_wrs
          + rman_wrs + reco_wrs + saq_wrs + xdb_wrs            total_wrs
        , dbwr_wrs   dbwr_wrs
        , dw_wrs       dw_wrs
        , lgwr_wrs   lgwr_wrs
        , bc_rrq + dr_rrq
          + arch_rrq + dbwr_rrq  + dp_rrq + dw_rrq + lgwr_rrq
          + oth_rrq + rman_rrq + reco_rrq + saq_rrq + xdb_rrq  total_rrq
        , bc_rrq       bc_rrq
        , dr_rrq       dr_rrq
        , dbwr_wrq + dw_wrq+ lgwr_wrq
          + arch_wrq + bc_wrq + dp_wrq + dr_wrq + oth_wrq 
          + rman_wrq + reco_wrq + saq_wrq + xdb_wrq            total_wrq
        , dbwr_wrq   dbwr_wrq
        , dw_wrq       dw_wrq
        , lgwr_wrq   lgwr_wrq
     from 
     (select e.instance_number
           , e.function_name
           , sum((e.small_read_megabytes - b.small_read_megabytes)
             + (e.large_read_megabytes - b.large_read_megabytes))   rds
           , sum((e.small_read_reqs - b.small_read_reqs)
             + (e.large_read_reqs - b.large_read_reqs))             rrq
           , sum((e.small_write_megabytes - b.small_write_megabytes)
             + (e.large_write_megabytes - b.large_write_megabytes)) wrs
           , sum((e.small_write_reqs - b.small_write_reqs)
             + (e.large_write_reqs - b.large_write_reqs))           wrq
           , sum((e.number_of_waits - b.number_of_waits))               wts
           , sum((e.wait_time       - b.wait_time))                     wttm
        from dba_hist_iostat_function b
           , dba_hist_iostat_function e
       where b.snap_id = :bid
         and e.snap_id = :eid
         and e.dbid    = :dbid
         and e.dbid    = b.dbid
         and e.instance_number = b.instance_number
         and e.function_id     = b.function_id
         and e.function_name   = b.function_name
       group by e.instance_number,e.function_name)
    pivot (sum(rds) rds, sum(rrq) rrq, sum(wrs) wrs, sum(wrq) wrq, sum(wts) wts, sum(wttm) wttm
           for function_name in ('ARCH'                 arch
                                ,'Buffer Cache Reads'   bc
                                ,'DBWR'                 dbwr
                                ,'Data Pump'            dp
                                ,'Direct Reads'         dr
                                ,'Direct Writes'        dw
                                ,'LGWR'                 lgwr
                                ,'Others'               oth
                                ,'RMAN'                 rman
                                ,'Recovery'             reco
                                ,'Streams AQ'           saq
                                ,'XDB'                  xdb
                                )))  io
   , (select e.instance_number
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)                      s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where s.instance_number = io.instance_number
 order by s.instance_number;

         
   

clear breaks computes



ttitle skip 1 -
       lef 'IOStat by Filetype (per Second) ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
           '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> Total Reads  includes all Filetypes: Data File, Temp File, Archive Log, Backups, Control File, Data Pump Dump File, Flashback Log, Log File, Other, etc' -
       skip 1 -
       '-> Total Writes includes all Filetypes: Data File, Temp File, Log File, Archive Log, Backup, Control File, Data Pump Dump File, Flasbachk Log, Log File, Other, etc' -
       skip 2 -
'     ------------------------------ Megabytes/sec ----------------------------------- ------------------------------- Requests/sec -----------------------------------' -
       skip 1 -
'     --------------- Reads ------------ ------------------ Writes ------------------- --------------- Reads ------------ ----------------- Writes --------------------';

col instance_number format 999 heading 'I#'
col total_rds       format 9,999,990.0 heading 'Total'        just c
col df_rds          format   999,990.0 heading 'Data File'    just c
col tf_rds          format   999,990.0 heading 'Temp File'    just c
col total_wrs       format 9,999,990.0 heading 'Total'        just c
col df_wrs          format   999,990.0 heading 'Data File'    just c
col tf_wrs          format   999,990.0 heading 'Temp File'    just c
col lf_wrs          format   999,990.0 heading 'Log File'     just c
col total_rrq       format 9,999,990.0 heading 'Total'        just c
col df_rrq          format   999,990.0 heading 'Data File'    just c
col tf_rrq          format   999,990.0 heading 'Temp File'    just c
col total_wrq       format 9,999,990.0 heading 'Total'        just c
col df_wrq          format   999,990.0 heading 'Data File'    just c
col tf_wrq          format   999,990.0 heading 'Temp File'    just c
col lf_wrq          format   999,990.0 heading 'Log File'     just c


break on report
compute sum avg of total_rds on report
compute sum avg of df_rds    on report
compute sum avg of tf_rds    on report
compute sum avg of total_wrs on report
compute sum avg of df_wrs    on report
compute sum avg of tf_wrs    on report
compute sum avg of lf_wrs    on report
compute sum avg of total_rrq on report
compute sum avg of df_rrq    on report
compute sum avg of tf_rrq    on report
compute sum avg of total_wrq on report
compute sum avg of df_wrq    on report
compute sum avg of tf_wrq    on report
compute sum avg of lf_wrq    on report



select s.instance_number
     , io.total_rds/s_et     total_rds
     , io.df_rds/s_et           df_rds
     , io.tf_rds/s_et           tf_rds
     , io.total_wrs/s_et     total_wrs
     , io.df_wrs/s_et           df_wrs
     , io.tf_wrs/s_et           tf_wrs
     , io.lf_wrs/s_et           lf_wrs
     , io.total_rrq/s_et     total_rrq
     , io.df_rrq/s_et           df_rrq
     , io.tf_rrq/s_et           tf_rrq
     , io.total_wrq/s_et     total_wrq
     , io.df_wrq/s_et           df_wrq
     , io.tf_wrq/s_et           tf_wrq
     , io.lf_wrq/s_et           lf_wrq
   from (select instance_number
        , df_rds + tf_rds        
          + ar_rds + arbk_rds + cf_rds + dfc_rds
          + dfbk_rds + dfibk_rds + dp_rds + fl_rds
          + lf_rds + oth_rds                         total_rds
        , df_rds                                     df_rds
        , tf_rds                                     tf_rds
        , df_wrs + tf_wrs + lf_wrs 
          + ar_wrs + arbk_wrs + cf_wrs + dfc_wrs
          + dfbk_wrs + dfibk_wrs + dp_wrs + fl_wrs
          + oth_wrs                                  total_wrs
        , df_wrs                                     df_wrs
        , tf_wrs                                     tf_wrs
        , lf_wrs                                     lf_wrs
        , df_rrq + tf_rrq        
          + ar_rrq + arbk_rrq + cf_rrq + dfc_rrq
          + dfbk_rrq + dfibk_rrq + dp_rrq + fl_rrq
          + lf_rrq + oth_rrq                         total_rrq
        , df_rrq                                     df_rrq
        , tf_rrq                                     tf_rrq
        , df_wrq + tf_wrq + lf_wrq 
          + ar_wrq + arbk_wrq + cf_wrq + dfc_wrq
          + dfbk_wrq + dfibk_wrq + dp_wrq + fl_wrq
          + oth_wrq                                  total_wrq
        , df_wrq                                     df_wrq
        , tf_wrq                                     tf_wrq
        , lf_wrq                                     lf_wrq
     from 
     (select e.instance_number
           , e.filetype_name
           , sum((e.small_read_megabytes - b.small_read_megabytes)
             + (e.large_read_megabytes - b.large_read_megabytes))   rds
           , sum((e.small_read_reqs - b.small_read_reqs)
             + (e.large_read_reqs - b.large_read_reqs))             rrq
           , sum((e.small_write_megabytes - b.small_write_megabytes)
             + (e.large_write_megabytes - b.large_write_megabytes)) wrs
           , sum((e.small_write_reqs - b.small_write_reqs)
             + (e.large_write_reqs - b.large_write_reqs))           wrq
        from dba_hist_iostat_filetype b
           , dba_hist_iostat_filetype e
       where b.snap_id = :bid
         and e.snap_id = :eid
         and e.dbid    = :dbid
         and e.dbid    = b.dbid
         and e.instance_number = b.instance_number
         and e.filetype_id     = b.filetype_id
         and e.filetype_name   = b.filetype_name
       group by e.instance_number,e.filetype_name)
    pivot (sum(rds) rds, sum(rrq) rrq, sum(wrs) wrs, sum(wrq) wrq
           for filetype_name in (
                                 'Archive Log'                     ar
                                ,'Archive Log Backup'            arbk
                                ,'Control File'                    cf
                                ,'Data File'                       df
                                ,'Data File Copy'                 dfc
                                ,'Data File Backup'              dfbk
                                ,'Data File Incremental Backup' dfibk
                                ,'Data Pump Dump File'             dp
                                ,'Flashback Log'                   fl
                                ,'Log File'                        lf
                                ,'Other'                          oth
                                ,'Temp File'                       tf
                                )))  io
   , (select e.instance_number
              , extract(DAY     from e.end_interval_time - b.end_interval_time) * 86400
                + extract(HOUR   from e.end_interval_time - b.end_interval_time) * 3600
                + extract(MINUTE from e.end_interval_time - b.end_interval_time) * 60
                + extract(SECOND from e.end_interval_time - b.end_interval_time)                      s_et
          from dba_hist_snapshot e
             , dba_hist_snapshot b
          where e.dbid            = :dbid
            and b.snap_id         = :bid
            and e.snap_id         = :eid
            and e.dbid            = b.dbid
            and e.instance_number = b.instance_number
       ) s
 where s.instance_number = io.instance_number
 order by s.instance_number;

         
   

clear breaks computes



-- ------------------------------------------------------------
set newpage 2;
--
-- PGA

ttitle 'PGA Aggregate Target Statistics  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> all stats are reported in MegaBytes' -
       skip 2 -
       '     -- PGA Aggr Target -- --- Auto PGA Target --- ---- PGA Mem Alloc ---- ---- Auto Workareas --- --- Manual Workarea --- --- Global Mem Bound ---'
      
col aptp_b format   999,990.0 heading 'Begin'
col aptp_e format   999,990.0 heading 'End'
col apat_b format 9,999,990.0 heading 'Begin'
col apat_e format   999,990.0 heading 'End'
col tpa_b  format 9,999,990.0 heading 'Begin'
col tpa_e  format   999,990.0 heading 'End'
col tpuaw_b format 9,999,990.0 heading 'Begin'
col tpuaw_e format   999,990.0 heading 'End'
col tpumw_b format 9,999,990.0 heading 'Begin'
col tpumw_e format   999,990.0 heading 'End'
col gmb_b  format 9,999,990.0 heading 'Begin'
col gmb_e  format   999,990.0 heading 'End'

select instance_number
     , aptp_b/&&btomb                            aptp_b
     , aptp_e/&&btomb                            aptp_e
     , apat_b/&&btomb                            apat_b
     , apat_e/&&btomb                            apat_e
     , tpa_b/&&btomb                              tpa_b
     , tpa_e/&&btomb                              tpa_e
     , decode(tpuaw_b,null,0,tpuaw_b/&&btomb)   tpuaw_b
     , decode(tpuaw_e,null,0,tpuaw_e/&&btomb)   tpuaw_e 
     , decode(tpumw_b,null,0,tpumw_b/&&btomb)   tpumw_b 
     , decode(tpumw_e,null,0,tpumw_e/&&btomb)   tpumw_e 
     , gmb_b/&&btomb                              gmb_b
     , gmb_e/&&btomb                              gmb_e
  from ((select se.instance_number
        , se.name
        , sb.value  bval
        , se.value  eval
     from dba_hist_pgastat sb
        , dba_hist_pgastat se
    where sb.snap_id     (+) = :bid
      and se.snap_id         = :eid
      and se.dbid            = :dbid
      and se.dbid            = sb.dbid            (+)
      and se.instance_number = sb.instance_number (+)
      and se.name            = sb.name            (+))
   pivot (max(bval) b, max(eval) e for name in (
                   'aggregate PGA target parameter'       aptp
                 , 'aggregate PGA auto target'            apat
                 , 'total PGA allocated'                   tpa
                 , 'total PGA used for auto workareas'   tpuaw
                 , 'total PGA used for manual workareas' tpumw
                 , 'global memory bound'                   gmb)))
 order by instance_number;

 
clear breaks computes

-- ------------------------------------------------------------------

ttitle 'Process Memory Summary  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       '-> Max Alloc is Maximum PGA allocation size at snapshot time' -
       skip 1 -
       '-> Hist Alloc is the Historical Maximum Allocation for still-connected processes' -
       skip 1 -
       '-> Num Procs or Allocs: For Begin/End snapshot lines, it is the number of processes ' -
       skip 1 -
       '   For Category lines, it is the number of allocations' -
       skip 1 -
       '-> Allocation sizes are displayed in MegaBytes' -
       skip 1 -
       '-> ordered by instance, Allocated Total (End) desc' -
       skip 2 -
'                ----- Allocated --- ------ Used ------- ---- Avg Alloc ---- ---- Std Dev ---- ---- Max Alloc ---- ----- Hist Max ---- -- Num Procs -- -- Num Allocs -'

break on instance_number
col category format         a10 heading 'Category'
col bat      format    99,990.9 heading 'Begin'
col eat      format    99,990.9 heading 'End'
col but      format    99,990.9 heading 'Begin'
col eut      format    99,990.9 heading 'End'
col baa      format    99,990.9 heading 'Begin'
col eaa      format    99,990.9 heading 'End'
col bas      format     9,990.9 heading 'Begin'
col eas      format     9,990.9 heading 'End'
col bam      format    99,990.9 heading 'Begin'
col eam      format    99,990.9 heading 'End'
col bmam     format    99,990.9 heading 'Begin'
col emam     format    99,990.9 heading 'End'
col bnp      format      99,999 heading 'Begin'
col enp      format      99,999 heading 'End'
col bnza     format      99,999 heading 'Begin'
col enza     format      99,999 heading 'End'

select se.instance_number
     , se.category
     , sum(sb.allocated_total)/&&btomb      bat
     , sum(se.allocated_total)/&&btomb      eat
     , sum(sb.used_total)/&&btomb           but
     , sum(se.used_total)/&&btomb           eut
     , sum(sb.allocated_avg)/&&btomb        baa
     , sum(se.allocated_avg)/&&btomb        eaa
     , sum(sb.allocated_stddev)/&&btomb     bas
     , sum(se.allocated_stddev)/&&btomb     eas
     , sum(sb.allocated_max)/&&btomb        bam
     , sum(se.allocated_max)/&&btomb        eam
     , sum(sb.max_allocated_max)/&&btomb   bmam
     , sum(se.max_allocated_max)/&&btomb   emam
     , sum(sb.num_processes)                bnp
     , sum(se.num_processes)                enp
     , sum(sb.non_zero_allocs)             bnza
     , sum(se.non_zero_allocs)             enza
  from dba_hist_process_mem_summary sb
     , dba_hist_process_mem_summary se
 where sb.snap_id     (+) = :bid
   and se.snap_id         = :eid
   and se.dbid            = :dbid
   and se.dbid            = sb.dbid            (+)
   and se.instance_number = sb.instance_number (+)
   and se.category        = sb.category        (+)
group by se.instance_number,se.category
order by se.instance_number,sum(se.allocated_total)/&&btomb desc; 

clear breaks computes

-- ------------------------------------------------------------------

--
-- Parameters
set newpage 0;

ttitle 'init.ora Parameters  ' -
       center 'DB: ' db_name ' ' -
       'Snaps: ' format 99999999 begin_snap '-' format 99999999 end_snap -
       skip 1 -
       '~~~~~~~~~~~~~~~~~~~ ' - 
       skip 1 -
       '-> ''*'' indicates same value across all instances' -
       skip 2;

break on parameter_name
column parameter_name  format a29      heading 'Parameter Name'         trunc;
column bval            format a53      heading 'Begin value'            
column eval            format a14      heading 'End value|(if different)' trunc just c;
column inst_id         format a3       heading 'I#'

with pval as (
     select e.parameter_name
          , e.instance_number 
          , b.value                                bval
          , decode(b.value, e.value, ' ', e.value) eval
          , count(*)                               instcnt
       from dba_hist_parameter b
          , dba_hist_parameter e
      where b.snap_id(+)         = :bid
        and e.snap_id            = :eid
        and e.dbid               = :dbid
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.parameter_name(+)            = e.parameter_name
        and b.parameter_hash(+)            = e.parameter_hash
        and translate(e.parameter_name, '_', '#') not like '##%'
        and (   nvl(b.isdefault, 'X')   = 'FALSE'
             or nvl(b.ismodified,'X')  != 'FALSE'
             or     e.ismodified       != 'FALSE'
             or nvl(e.value,0)         != nvl(b.value,0)
            )
  group by e.parameter_name
         , b.value
         , decode(b.value, e.value, ' ', e.value) 
         , rollup(e.instance_number)
  )  
select /* get identical parameters */ 
       parameter_name
     , '  *'             inst_id
     , bval
     , eval
  from pval 
 where instance_number is null and instcnt = :numinst
union all
select /* get parameters that are not the same for all instances */
       parameter_name
     , lpad(to_char(instance_number),3)  inst_id
     , bval
     , eval
  from pval
 where instance_number is not null and instcnt < :numinst
   and parameter_name not in (select /*first part of query */
                                     parameter_name 
                                from pval
                               where instance_number is null 
                                 and instcnt = :numinst)
order by parameter_name, inst_id;

clear breaks computes

repfooter center -
   '-------------------------------------------------------------';

-- ------------------------------------------------------------------


prompt
prompt End of Report ( &report_name )
prompt  . This script will be deprecated.  The official release of the Global AWR report is awrgrpt.sql
prompt
spool off;
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6;
undefine begin_snap
undefine end_snap
undefine db_name
undefine dbid
undefine inst_num
undefine num_days
undefine report_name
undefine top_n_sql
undefine top_pct_sql
undefine top_n_events
undefine top_n_segstat
undefine btime
undefine etime
undefine num_rows_per_hash
whenever sqlerror continue;

--
--  End of script file;
