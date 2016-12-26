Rem
Rem $Header: rdbms/admin/spawrio.sql /st_rdbms_11.2.0.4.0dbpsu/1 2014/01/13 14:20:04 apfwkr Exp $
Rem
Rem spawrio.sql
Rem
Rem Copyright (c) 2010, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spawrio.sql - AWR IO Intensity Report
Rem
Rem    DESCRIPTION
Rem      This is a text-based report for I/O intensity.  This report
Rem      shows I/O intensity by segment, file and tablespace.  In addition,
Rem      this also reports I/O Wait intensity by segment, file and tablespace.
Rem
Rem    NOTES
Rem      Run as sys as this requires access to sys objects.
Rem
Rem      This report does not run on export AWR data, as it requires
Rem      access to dictionary objects in the current database
Rem 
Rem      This uses the average IOPs / IO wait over the past n days
Rem      and divides by the current segment size (from seg$) to compute
Rem      intensity.  If the I/O patterns vary widely over the selected time
Rem      the report does not consider the peak, but just the average
Rem      over the interval
Rem
Rem      The report uses statistics introduced in 11.2.0, and will not run
Rem      on prior releases of the database.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/05/14 - Backport
Rem                           apfwkr_blr_backport_14852021_11.2.0.4.1dbpsu from
Rem                           st_rdbms_11.2.0.4.0dbpsu
Rem    apfwkr      12/22/13 - Backport apfwkr_blr_backport_14852021_11.2.0.4.0
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      09/17/13 - Backport cgervasi_bug-14852021 from main
Rem    cgervasi    09/10/13 - remove sys qualifier for test
Rem    cgervasi    01/17/13 - bug14852021: fix divisor
Rem    cgervasi    02/15/10 - add aggregation by file
Rem    cgervasi    02/11/10 - Created based on previous prototypes
Rem


--  bytes to gigabytes
define btogb=1073741824

define btomb=1048576

--  days to seconds
define dtos=86400 
--  days to minutes
define dtom=1440

define ustos=1000000

-- pct threshold for display
define pct_thresh=0.25

-- Get database information 
set echo off heading off feedback off termout off

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;


variable dbid number
variable db_name varchar2(32);
begin
:dbid := &dbid;
:db_name := '&db_name';
end;
/

set termout on
column begin_snap new_value begin_snap format 999999
column end_snap   new_value end_snap format 999999

select min(snap_id) begin_snap
     , max(snap_id) end_snap
  from dba_hist_snapshot
 where dbid = :dbid
   and end_interval_time >= sysdate-&&num_days
;


 
set termout off
variable bsnap number
variable esnap number
variable btime varchar2(32);
variable etime varchar2(32);
begin
:bsnap := &&begin_snap;
:esnap := &&end_snap;
select to_char(min(end_interval_time),'YYYY/MM/DD HH24:MI') into :btime
  from dba_hist_snapshot
 where snap_id = :bsnap;
select to_char(max(end_interval_time),'YYYY/MM/DD HH24:MI') into :etime  
  from dba_hist_snapshot
 where snap_id = :esnap;
-- :bsnap := 35425; -- hardcode for testing
-- :esnap := 35472;
end;
/

-- define bsnap = 35425
-- define esnap = 35472

set termout off 
column dflt_name new_value dflt_name noprint;
select 'spawrio_'|| :db_name || '_' ||:bsnap|| '_' || :esnap dflt_name 
  from dual;

set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name, 
prompt press <return> to continue, otherwise enter an alternative.
prompt

set heading off feedback off veri off
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , decode( instr(nvl('&&report_name','&dflt_name'),'.'), 0, nvl('&&report_name','&dflt_name')||'.lst'
             , nvl('&&report_name','&dflt_name')) report_name
  from sys.dual;
prompt

set heading on termout on linesize 260 pagesize 80 verify off
set trim on trimspool on

spool &report_name

prompt I/O Intensity report for &db_name (&begin_snap to &end_snap)
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

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


select di.dbid, e.instance_number, di.instance_name, di.host_name
     , to_char(e.startup_time,'DD-Mon-YY HH24:MI') startup_time
     , to_char(b.end_interval_time,'DD-Mon-YY HH24:MI') begin_snap_time
     , to_char(e.end_interval_time,'DD-Mon-YY HH24:MI') end_snap_time
     , di.version
     ,(cast(e.end_interval_time as date)-cast(e.startup_time as date))*24 up_time
     ,(cast(e.end_interval_time as date)-cast(b.end_interval_time as date))*24*60 ela
  from dba_hist_database_instance di
     , dba_hist_snapshot b
     , dba_hist_snapshot e
 where di.dbid            = b.dbid
   and di.instance_number = b.instance_number
   and di.startup_time    = b.startup_time
   and b.snap_id          = :bsnap
   and b.dbid             = e.dbid
   and b.instance_number  = e.instance_number
   and e.snap_id          = :esnap
   and di.dbid            = :dbid
 order by di.dbid, e.instance_number;


-- ------------------------------------------------------------
-- 
-- Cache Sizes


-- ------------------------------------------------------------------


column buffers format 999999999999 heading 'db_block_buffers'
column bs      format        99999 heading 'db_block_size'
column db_cache format 999,999,999.0 heading 'DB Cache Size (M)'

ttitle 'Memory Settings ' -
       skip 2;

-- for those still using pre-8i settings, or because of VLM -
--    we don't check db_block_buffers
-- WITH db$params as
--    ( select snap_id
--      , instance_number
--      , parameter_name
--      , value
--   from dba_hist_parameter 
--  where parameter_name in ('db_block_buffers','db_block_size')
--    and dbid = :dbid
--    and snap_id = :esnap )
-- select instance_number
--         , buffers
--         , bs
--         , buffers*bs/&&btomb  db_cache
--      from (select instance_number
--                  , max(case when parameter_name = 'db_block_buffers' then to_number(value) end) buffers
--                  , max(case when parameter_name = 'db_block_size' then to_number(value) end)    bs
--               from db$params
--              group by instance_number)
--     where buffers != 0
--  order by instance_number;
--


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
        and sb.snap_id  = :bsnap
        and se.snap_id  = :esnap
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
        and sb.snap_id  = :bsnap
        and se.snap_id  = :esnap
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
             and sb.snap_id   = :bsnap
             and se.snap_id   = :esnap
             and se.dbid      = sb.dbid
             and se.instance_number = sb.instance_number
             and se.name            = sb.name
             and se.name='aggregate PGA target parameter') pga
  where mdc.instance_number (+)= p.instance_number 
    and pga.instance_number (+)= p.instance_number
  )
order by instance_number;

--
--
-- set up variables for totals and headings
--
-- setup variables used in headings

set termout off 
ttitle off

col pr_sys_t new_value pr_sys_t noprint
col pw_sys_t new_value pw_sys_t noprint
col or_sys_t new_value or_sys_t noprint

col pr_sys_ps new_value pr_sys_ps     noprint
col pw_sys_ps new_value pw_sys_ps     noprint
col or_sys_ps new_value or_sys_ps     noprint

select sum(case when stat_name = 'physical read IO requests' 
                then v_delta 
                else 0 
            end)  pr_sys_t,
       sum(case when stat_name = 'physical write IO requests' 
                then v_delta 
                else 0 
            end)  pw_sys_t,
       sum(case when stat_name = 'physical read requests optimized'
                then v_delta 
                else 0 
            end)  or_sys_t,
       avg(case when stat_name = 'physical read IO requests' 
                then v_ps 
                else null 
            end)  pr_sys_ps,
       avg(case when stat_name = 'physical write IO requests'
                then v_ps
                else null
            end)  pw_sys_ps,
       avg(case when stat_name = 'physical read requests optimized'
                then v_ps
                else null
            end)  or_sys_ps
     from ( /* compute cluster totals */
         select snap_id, stat_name,
                sum(value - pv)      v_delta,
                sum((value-pv)/ela_s)   v_ps
          from ( /* get value per snapshot and prev value-bounces can occur */
            select sy.instance_number,
                   sy.snap_id,
                   sy.stat_name,
                   sy.value,
                   lag(sy.value,1) 
                     over (partition by sy.stat_name,
                                   sy.dbid, sy.instance_number, s.startup_time
                               order by sy.snap_id )   pv,
                  (cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos   ela_s
             from dba_hist_snapshot s
                , dba_hist_sysstat sy
            where s.dbid            = sy.dbid
              and s.instance_number = sy.instance_number
              and s.snap_id         = sy.snap_id
              and s.dbid            = :dbid
              and sy.dbid           = :dbid
              and s.snap_id  between :bsnap and :esnap
              and sy.snap_id between :bsnap and :esnap
              and sy.stat_name in ('physical read IO requests',
                                   'physical write IO requests',
                                   'physical read requests optimized'))
        group by snap_id, stat_name);

variable pr_sys_ps number;
variable pw_sys_ps number;
variable io_sys_ps number;
variable or_sys_ps number;

begin
:pr_sys_ps := &&pr_sys_ps;
:pw_sys_ps := &&pw_sys_ps;
:io_sys_ps := &&pr_sys_ps + &&pw_sys_ps;
:or_sys_ps := &&or_sys_ps;
end;
/

col io_sys_ps       new_value  io_sys_ps  noprint

select :io_sys_ps                      io_sys_ps
  from dual;

set termout on 

clear breaks compute;

column owner           heading "Owner"           format a10 trunc
column tablespace_name heading "Tablespace Name" format a10 trunc
column object_type     heading "Obj.|Type"       format a10 trunc
column segment_type    heading "Seg.|Type"       format a10 trunc
column object_name     heading "Object Name"     format a15 trunc
column subobject_name  heading "Subobject|Name"  format a15 trunc
column owner_objname   heading "Owner.ObjName"   format a20 trunc
column owner_objname_subobj heading "Owner.Object(SubObject)" format a34 trunc

column parent          heading "Parent"          format a10 trunc
column parent_name     heading "Parent|Obj"      format a15 trunc

column file#           heading "File ID"         format 99999 
column filename        heading "File Name"       format a55 trunc

col io_t         format  999,990.0      heading 'Total|IO Blks|(thousands)'  just c
col io_t_str     format  a7             heading 'Total|IO Blks'
col io_intensity format   999,990.0     heading 'IO|Intensity'               just c
col io_ps        format   999,990.0     heading 'IOs|per Sec'                just c
col iorq_ps      format  999,990.0      heading 'IO Req|per Sec'             just c

col mb_t         format   999,999,990.0 heading 'Total|IO MB'                just c
col mb_ps        format   999,990.0     heading 'Total|MB/s'                       just c
col fs_t         format     999,990     heading 'Total|Segment|Scans'
col fs_t_str     format  a7             heading 'Total|Segment|Scans'        just c

col pr_t         format  999,999,990.0  heading 'Blks|Reads|(thousands)'     just c
col pr_intensity format  999,990.0      heading 'Read|Intensity'             just c
col pr_ps        format  999,990.0      heading 'Rd Blks|per Sec'            just c
col prrq_ps      format  999,990.0      heading 'Rd Req|per Sec'             just c

col pr_pct       format  990.0          heading '%Reads'
col prmb_ps      format  999,990.0      heading 'Read MB|per Sec'            just c

col pw_t         format  999,999,990.0  heading 'Total|Writes|(thousands)'   just c
col pw_intensity format  999,990.0      heading 'Write|Intensity'            just c
col pw_ps        format  999,990.0      heading 'Wr Blks|per Sec'            just c
col pwrq_ps      format  999,990.0      heading 'Wr Req|per Sec'             just c
col pw_pct       format  990.0          heading '%Writes'
col pwmb_ps      format  999,990.0      heading 'Write MB|per Sec'           just c

col or_intensity format  999,990.0      heading 'OptRead|Intensity'          just c
col or_pct       format  990.0          heading '%Opt'

col space_gb     format      999,990.0  heading 'Space|GB'                   just c
col ratio        format  990.0          heading '%Cap'                      just c
col pct_total    format  990.0          heading '%Tot'                      just c

col num_objs     format      99999      heading '#Segs'                   just c
col num_objs_io  format      99999      heading '#Segs|IO'                just c

col cum_io       format  990.0          heading '%IOPs'            just c
col cum_sp       format  990.0          heading '%Spc'            just c


-- compute I/O intensity by segment
-- in 11.2, this should use the stat 'physical read requests' and 'physical write requests'
-- how should 'optimzed physical reads' be used here?
-- I/O intensity = requests/size(GB)

-- aggregation by tablespace (use space allocated, not space used,
--  since entire tablespace needs to be relocated
--
-- ISSUES:
--   dba_hist_tbspc_space_usage: possible duplicates
--   dba_hist_tbspc_space_usage: space information only available for LMTS
--                              (not dictionary ts) - space and io_intensity
--                               will be null for dictionary ts
--   dba_hist_filestatxs       : no optimized_read stat





ttitle 'IO Intensity - by Tablespace ' -
       skip 1 -
       '-> I/O Intensity calculated as IO Reqs per sec/GB allocated' -
       skip 1 -
       '-> tablespaces with >= ' &&pct_thresh  ' % of Captured IOs displayed' -
       skip 1 -
       '-> %IOPs - Running Total of % of Captured IOPs' -
       skip 1 -
       '   %Cap  - IOs as a percentage of Captured  IOPs' - 
       skip 1 -  
       '   %Tot  - IOs as a percentage of Total sysstat IOPs ' -
       skip 1 -
       '           Sysstat IOs per Sec: ' format 999,990.0 io_sys_ps -
       skip 1 -
       '-> ordered by Total IOPs desc, IO Intensity desc' -   
        skip 2;

WITH ts$iostats as (
   select /* totals and rates over entire interval */
          ts#, tsname,
          sum(prrq)                prrq_t,
          sum(pwrq)                pwrq_t,
          sum(srq)                  srq_t,
          sum(prbk+pwbk)             io_t,
          sum(prbk)                prbk_t,
          sum(pwbk)                pwbk_t,
          avg(prrq_ps)            prrq_ps,
          avg(pwrq_ps)            pwrq_ps,
          avg(srq_ps)              srq_ps,
          avg(prbk_ps)            prbk_ps,
          avg(pwbk_ps)            pwbk_ps,
          (ratio_to_report(avg(prrq_ps+pwrq_ps)) over())*100  ratio
     from (    
      select /* cluster-wide ts totals per interval */
             snap_id,
             ts#,  tsname,
             sum(prrq)             prrq,
             sum(pwrq)             pwrq,
             sum(srq)              srq,
             sum(prbk)             prbk,
             sum(pwbk)             pwbk,
             sum(prrq_ps)          prrq_ps,
             sum(pwrq_ps)          pwrq_ps,
             sum(srq_ps)           srq_ps,
             Sum(prbk_ps)          prbk_ps,
             sum(pwbk_ps)          pwbk_ps
        from (
         select /* get file deltas and rates */
                f.instance_number,
                f.snap_id,
                ts#,
                tsname,
                file#,
                phyrds - lag(phyrds,1)
                   over(partition by f.ts#, f.file#, 
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) prrq,
                phywrts - lag(phywrts,1)
                   over(partition by f.ts#, f.file#,
                                      f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) pwrq,
                singleblkrds - lag(singleblkrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) srq,
                phyblkrd - lag(phyblkrd,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) prbk,
                phyblkwrt - lag(phyblkwrt,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) pwbk,
                (phyrds - lag(phyrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prrq_ps,
                (phywrts - lag(phywrts,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwrq_ps,
                (singleblkrds - lag(singleblkrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             srq_ps,
                (phyblkrd - lag(phyblkrd,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prbk_ps,
                (phyblkwrt - lag(phyblkwrt,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwbk_ps
               from dba_hist_filestatxs  f
              , dba_hist_snapshot s
          where phyrds + phywrts > 0
            and f.dbid = :dbid
            and f.snap_id between :bsnap and :esnap
            And f.dbid = s.dbid
            and f.instance_number = s.instance_number
            and f.snap_id = s.snap_id
            and s.dbid = :dbid
            and s.snap_id between :bsnap and :esnap
         union all
         select /* get file deltas and rates */
                tf.instance_number,
                tf.snap_id,
                ts#,
                tsname,
                file#,
                phyrds - lag(phyrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                            order by tf.snap_id) prrq,
                phywrts - lag(phywrts,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) pwrq,
                singleblkrds - lag(singleblkrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) srq,
                phyblkrd - lag(phyblkrd,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) prbk,
                phyblkwrt - lag(phyblkwrt,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) pwbk,
                (phyrds - lag(phyrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prrq_ps,
                (phywrts - lag(phywrts,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwrq_ps,
                (singleblkrds - lag(singleblkrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             srq_ps,
                (phyblkrd - lag(phyblkrd,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prbk_ps,
                (phyblkwrt - lag(phyblkwrt,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwbk_ps
           from dba_hist_tempstatxs  tf
              , dba_hist_snapshot s
          where phyrds + phywrts > 0
            and tf.dbid = :dbid
            and tf.snap_id between :bsnap and :esnap
            And tf.dbid = s.dbid
            and tf.instance_number = s.instance_number
            and tf.snap_id = s.snap_id
            and s.dbid = :dbid
            and s.snap_id between :bsnap and :esnap
          )
       group by snap_id, ts#, tsname)
    group by ts#,tsname)
, ts$blks as (
   select tablespace_id ts#,
            max(tablespace_size)   blks -- this view has possible dups
       from dba_hist_tbspc_space_usage
      where dbid = :dbid
        and snap_id = :esnap
      group by tablespace_id)
, ts$size as (
    select f.ts#, f.tsname, 
           max(f.block_size) block_size,
           sum(ts.blks*f.block_size)  bytes
      from dba_hist_datafile f,
           ts$blks           ts 
     where f.dbid = :dbid
       and f.ts#  = ts.ts# (+)
     group by f.ts#, f.tsname
     union all
    select t.ts#, t.tsname,
           max(t.block_size) block_size,
           sum(ts.blks*t.block_size)  bytes
      from dba_hist_tempfile t,
           ts$blks           ts
     where t.dbid = :dbid
       and t.ts#  = ts.ts# (+)
     group by t.ts#, t.tsname)
select ts.tsname    tablespace_name,
       prrq_ps + pwrq_ps    iorq_ps,
       prrq_ps,
       pwrq_ps,
       ts.bytes/&&btogb     space_gb,
       (prrq_ps+pwrq_ps)/(ts.bytes/&&btogb)  io_intensity,
       prrq_ps/(ts.bytes/&&btogb)            pr_intensity,
       pwrq_ps/(ts.bytes/&&btogb)            pw_intensity,
       sum(ratio) over (order by prrq_ps + pwrq_ps desc)    cum_io,
       (prbk_t+pwbk_t)*ts.block_size/&&btomb                mb_t,
       lpad(case when io_t <= 9999
                 then to_char(io_t)
                 when trunc(io_t/1000)         <= 9999
                 then to_char(round(io_t/1000,1))       || 'K'
                 when trunc(io_t/1000000)      <= 9999
                 then to_char(round(io_t/1000000,1))    || 'M'
                 when trunc(io_t/1000000000)   <= 9999
                 then to_char(round(io_t/1000000000,1)) || 'G'
                 when trunc(io_t/1000000000000) <= 9999
                 then to_char(round(io_t/1000000000000,1)) || 'T'
                 else to_char(round(io_t/1000000000000000,1)) || 'P'
             end,7)  io_t_str,
       prbk_t/io_t*100   pr_pct,
       pwbk_t/io_t*100   pw_pct,
       (prbk_ps+pwbk_ps)*ts.block_size/&btomb     mb_ps,
       (prbk_ps*ts.block_size)/&btomb             prmb_ps,
       (pwbk_ps*ts.block_size)/&btomb             pwmb_ps,
       ratio,
       (prrq_ps+pwrq_ps)/:io_sys_ps*100           pct_total
  from ts$size    ts,
       ts$iostats io
 where io.ts# = ts.ts# 
   and ratio >= &pct_thresh
 order by (prrq_ps + pwrq_ps) desc, io_intensity desc;

ttitle 'IO Intensity - by File ' -
       skip 1 -
       '-> I/O Intensity calculated as IO Reqs per sec/GB per segment ' -
       skip 1 -
       '-> files with >= ' &&pct_thresh  ' % of Captured IOs displayed' -
       skip 1 -
       '-> %IOPs - Running Total of % of Captured IOPs' -
       skip 1 -
       '   %Cap  - IOs as a percentage of Captured  IOPs' - 
       skip 1 -  
       '   %Tot  - IOs as a percentage of Total sysstat IOPs ' -
       skip 1 -
       '           Sysstat IOs per Sec: ' format 999,990.0 io_sys_ps -
       skip 1 -
       '-> ordered by Total IOPs desc, IO Intensity desc' -   
        skip 2;

WITH df$iostats as (
   select /* totals and rates over entire interval */
          ts#, tsname, file#, filename,
          sum(prrq)                prrq_t,
          sum(pwrq)                pwrq_t,
          sum(srq)                  srq_t,
          sum(prbk+pwbk)             io_t,
          sum(prbk)                prbk_t,
          sum(pwbk)                pwbk_t,
          avg(prrq_ps)            prrq_ps,
          avg(pwrq_ps)            pwrq_ps,
          avg(srq_ps)              srq_ps,
          avg(prbk_ps)            prbk_ps,
          avg(pwbk_ps)            pwbk_ps,
          (ratio_to_report(avg(prrq_ps+pwrq_ps)) over())*100  ratio
     from (    
      select /* cluster-wide ts totals per interval */
             snap_id,
             ts#,  tsname, file#, filename,
             sum(prrq)             prrq,
             sum(pwrq)             pwrq,
             sum(srq)              srq,
             sum(prbk)             prbk,
             sum(pwbk)             pwbk,
             sum(prrq_ps)          prrq_ps,
             sum(pwrq_ps)          pwrq_ps,
             sum(srq_ps)           srq_ps,
             Sum(prbk_ps)          prbk_ps,
             sum(pwbk_ps)          pwbk_ps
        from (
         select /* get file deltas and rates */
                f.instance_number,
                f.snap_id,
                ts#, tsname,
                file#,
                filename,
                phyrds - lag(phyrds,1)
                   over(partition by f.ts#, f.file#, 
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) prrq,
                phywrts - lag(phywrts,1)
                   over(partition by f.ts#, f.file#,
                                      f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) pwrq,
                singleblkrds - lag(singleblkrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) srq,
                phyblkrd - lag(phyblkrd,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) prbk,
                phyblkwrt - lag(phyblkwrt,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id) pwbk,
                (phyrds - lag(phyrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prrq_ps,
                (phywrts - lag(phywrts,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwrq_ps,
                (singleblkrds - lag(singleblkrds,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             srq_ps,
                (phyblkrd - lag(phyblkrd,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prbk_ps,
                (phyblkwrt - lag(phyblkwrt,1)
                   over(partition by f.ts#, f.file#,
                                     f.instance_number, f.dbid, s.startup_time
                            order by f.snap_id))
                      /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwbk_ps
               from dba_hist_filestatxs  f
              , dba_hist_snapshot s
          where phyrds + phywrts > 0
            and f.dbid = :dbid
            and f.snap_id between :bsnap and :esnap
            And f.dbid = s.dbid
            and f.instance_number = s.instance_number
            and f.snap_id = s.snap_id
            and s.dbid = :dbid
            and s.snap_id between :bsnap and :esnap
         union all
         select /* get file deltas and rates */
                tf.instance_number,
                tf.snap_id,
                ts#, tsname,
                file#,
                filename,
                phyrds - lag(phyrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                            order by tf.snap_id) prrq,
                phywrts - lag(phywrts,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) pwrq,
                singleblkrds - lag(singleblkrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) srq,
                phyblkrd - lag(phyblkrd,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) prbk,
                phyblkwrt - lag(phyblkwrt,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id) pwbk,
                (phyrds - lag(phyrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prrq_ps,
                (phywrts - lag(phywrts,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwrq_ps,
                (singleblkrds - lag(singleblkrds,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             srq_ps,
                (phyblkrd - lag(phyblkrd,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             prbk_ps,
                (phyblkwrt - lag(phyblkwrt,1)
                  over(partition by tf.ts#, tf.file#,
                                    tf.instance_number, tf.dbid, s.startup_time
                           order by tf.snap_id))
                /((cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos)             pwbk_ps
           from dba_hist_tempstatxs  tf
              , dba_hist_snapshot s
          where phyrds + phywrts > 0
            and tf.dbid = :dbid
            and tf.snap_id between :bsnap and :esnap
            And tf.dbid = s.dbid
            and tf.instance_number = s.instance_number
            and tf.snap_id = s.snap_id
            and s.dbid = :dbid
            and s.snap_id between :bsnap and :esnap
          )
       group by snap_id, ts#, tsname, file#,filename)
    group by ts#,tsname, file#,filename)
, df$size as (
  select f.file#, f.ts#, f.blocks*ts.blocksize bytes, ts.blocksize,
         ts.name tsname
    from file$ f,
         ts$   ts
  where f.ts# = ts.ts#
  union all
  select f.file_id, ts.ts#, f.bytes, ts.blocksize, ts.name tsname
    from dba_temp_files f,
         ts$   ts
   where f.tablespace_name = ts.name
    )
select io.file#, io.filename,
       io.tsname    tablespace_name,
       prrq_ps + pwrq_ps    iorq_ps,
       prrq_ps,
       pwrq_ps,
       df.bytes/&&btogb     space_gb,
       (prrq_ps+pwrq_ps)/(df.bytes/&&btogb)  io_intensity,
       prrq_ps/(df.bytes/&&btogb)            pr_intensity,
       pwrq_ps/(df.bytes/&&btogb)            pw_intensity,
       sum(ratio) over (order by prrq_ps + pwrq_ps desc)    cum_io,
       (prbk_t+pwbk_t)*df.blocksize/&&btomb                mb_t,
       lpad(case when io_t <= 9999
                 then to_char(io_t)
                 when trunc(io_t/1000)         <= 9999
                 then to_char(round(io_t/1000,1))       || 'K'
                 when trunc(io_t/1000000)      <= 9999
                 then to_char(round(io_t/1000000,1))    || 'M'
                 when trunc(io_t/1000000000)   <= 9999
                 then to_char(round(io_t/1000000000,1)) || 'G'
                 when trunc(io_t/1000000000000) <= 9999
                 then to_char(round(io_t/1000000000000,1)) || 'T'
                 else to_char(round(io_t/1000000000000000,1)) || 'P'
             end,7)  io_t_str,
       prbk_t/io_t*100   pr_pct,
       pwbk_t/io_t*100   pw_pct,
       (prbk_ps+pwbk_ps)*df.blocksize/&btomb     mb_ps,
       (prbk_ps*df.blocksize)/&btomb             prmb_ps,
       (pwbk_ps*df.blocksize)/&btomb             pwmb_ps,
       ratio,
       (prrq_ps+pwrq_ps)/:io_sys_ps*100           pct_total
  from df$size    df,
       df$iostats io
 where io.ts# = df.ts#
   and io.file# = df.file#
   and ratio >= &pct_thresh
 order by (prrq_ps + pwrq_ps) desc, io_intensity desc;

  
       

ttitle 'IO Intensity - by Segments ' -
       skip 1 -
       '-> I/O Intensity calculated as IO Reqs per sec/GB per segment ' -
       skip 1 -
       '-> segments with >= ' &&pct_thresh  ' % of Captured IOs displayed' -
       skip 1 -
       '-> %IOPs - Running Total of % of Captured IOPs' -
       skip 1 -
       '   %Cap  - IOs as a percentage of Captured  IOPs' - 
       skip 1 -
       '   %Spc  - Running Total of % of Space for Captured Segments' -
       skip 1 -
       '   %Opt  - Optimized Read Requests as a percentage of read requests' -
       skip 1 -  
       '   %Tot  - IOs as a percentage of Total sysstat IOPs ' -
       skip 1 -
       '           Sysstat IOs per Sec: ' format 999,990.0 io_sys_ps -
       skip 1 -
       '-> ordered by Total IOPs desc, IO Intensity desc' -   
       skip 2;

WITH seg$int_iostats as
  ( select /* get IOs per segment, perinterval */
           o.snap_id,
           owner,
           object_name,
           subobject_name,
           tablespace_name,
           object_type,
           n.ts#, n.obj#, n.dataobj#,
           sum(physical_reads_delta)   pr,
           sum(physical_writes_delta)  pw,
           sum(physical_read_requests_delta) prrq,
           sum(physical_write_requests_delta) pwrq,
           sum(optimized_physical_reads_delta) orrq,
           sum(table_scans_delta)      fs,
           sum(physical_reads_delta/
               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pr_ps,
           sum(physical_writes_delta/
               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pw_ps,
           sum(physical_read_requests_delta/
               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       prrq_ps,
           sum(physical_write_requests_delta/
               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pwrq_ps,
           sum(optimized_physical_reads_delta/
               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       orrq_ps
        from dba_hist_seg_stat      o
         , dba_hist_seg_stat_obj  n
         , dba_hist_snapshot      s
     where o.dbid            = n.dbid
       and o.ts#             = n.ts#
       and o.obj#            = n.obj#
       and o.dataobj#        = n.dataobj#
       and o.dbid            = s.dbid
       and o.instance_number = s.instance_number
       and o.snap_id         = s.snap_id
       and o.dbid            = :dbid
       and n.dbid            = :dbid
       and s.dbid            = :dbid
       and o.snap_id > :bsnap and o.snap_id <= :esnap
       and s.snap_id > :bsnap and s.snap_id <= :esnap
     group by o.snap_id
            , owner, object_name, subobject_name, tablespace_name,object_type
            , n.ts#, n.obj#, n.dataobj#)
, seg$iostats as /* total and average rates across all interval */
  ( select owner,
           object_name,
           subobject_name,
           tablespace_name,
           object_type,
           ts#, obj#, dataobj#,
           sum(pr+pw)                io_t,
           sum(prrq + pwrq)          iorq_t,
           avg(pr_ps + pw_ps)        io_ps,  
           avg(prrq_ps + pwrq_ps)    iorq_ps,
           max(pr_ps + pw_ps)        mxio_ps,
           max(prrq_ps + pwrq_ps)    mxiorq_ps,
           sum(pr)                   pr_t,
           sum(pw)                   pw_t,
           sum(prrq)                 prrq_t,
           sum(pwrq)                 pwrq_t,
           sum(orrq)                 orrq_t,
           sum(fs)                   fs_t,
           avg(pr_ps)                pr_ps,
           avg(pw_ps)                pw_ps,
           avg(prrq_ps)              prrq_ps,
           avg(pwrq_ps)              pwrq_ps,
           avg(orrq_ps)              orrq_ps,
           max(pr_ps)                mxpr_ps,
           max(pw_ps)                mxpw_ps,
           max(prrq_ps)              mxprrq_ps,
           max(pwrq_ps)              mxpwrq_ps,
           max(orrq_ps)              mxorrq_ps,
           (ratio_to_report(avg(prrq_ps+pwrq_ps)) over())*100   ratio,
           (ratio_to_report(max(prrq_ps+pwrq_ps)) over())*100   mxratio
       from seg$int_iostats
      group by  owner, object_name, subobject_name,
                tablespace_name, object_type,
                ts#, obj#, dataobj#)
select owner_objname_subobj,
       tablespace_name,
       object_type,
       iorq_ps,
       prrq_ps,
       pwrq_ps,
       space_gb,
       io_intensity,
       pr_intensity,
       or_intensity,
       pw_intensity,
       sum(ratio) over (order by iorq_ps desc)  cum_io,
       sum(sratio) over (order by iorq_ps desc) cum_sp,
       mb_t,
       io_t_str,
       fs_t_str,
       pr_pct,
       or_pct,
       pw_pct,
       mb_ps,
       prmb_ps,
       pwmb_ps,
       ratio,
       pct_total
  from (
  select  io.owner || '.' ||
              case when io.subobject_name is null 
                   then substr(io.object_name,1,25)
                   else case when length(io.object_name) <= 14
                             then io.object_name || '('
                             else substr(io.object_name,1,14) || '*(' 
                         end ||
                        case when length(io.subobject_name) < 10
                             then io.subobject_name 
                             else '*' ||
                                  substr(io.subobject_name,length(io.subobject_name)-9)
                         end  || ')'
               end owner_objname_subobj,
          io.tablespace_name,
          so.object_type,
          iorq_ps                            iorq_ps,
          prrq_ps,
          pwrq_ps,
          mxiorq_ps,
          mxprrq_ps,
          mxpwrq_ps,
          (s.blocks*ts.blocksize)/&&btogb       space_gb,
          iorq_ps/((s.blocks*ts.blocksize)/&btogb)   io_intensity,
          prrq_ps/((s.blocks*ts.blocksize)/&btogb)  pr_intensity,
          orrq_ps/((s.blocks*ts.blocksize)/&btogb)  or_intensity,
          pwrq_ps/((s.blocks*ts.blocksize)/&btogb)  pw_intensity,
          io_t*ts.blocksize/&&btomb         mb_t,
          lpad(case when io_t <= 9999
                   then to_char(io_t)
                   when trunc(io_t/1000)         <= 9999
                   then to_char(round(io_t/1000,1))       || 'K'
                   when trunc(io_t/1000000)      <= 9999
                   then to_char(round(io_t/1000000,1))    || 'M'
                   when trunc(io_t/1000000000)   <= 9999
                   then to_char(round(io_t/1000000000,1)) || 'G'
                   when trunc(io_t/1000000000000) <= 9999
                   then to_char(round(io_t/1000000000000,1)) || 'T'
                   else to_char(round(io_t/1000000000000000,1)) || 'P'
               end,7)  io_t_str,
          lpad(case when fs_t <= 9999
                   then to_char(fs_t)
                   when trunc(fs_t/1000)         <= 9999
                   then to_char(round(fs_t/1000,1))       || 'K'
                   when trunc(fs_t/1000000)      <= 9999
                   then to_char(round(fs_t/1000000,1))    || 'M'
                   when trunc(fs_t/1000000000)   <= 9999
                   then to_char(round(fs_t/1000000000,1)) || 'G'
                   when trunc(fs_t/1000000000000) <= 9999
                   then to_char(round(fs_t/1000000000000,1)) || 'T'
                   else to_char(round(fs_t/1000000000000000,1)) || 'P'
               end,7)  fs_t_str,
          prrq_t/decode(iorq_t,0,null,iorq_t)*100       pr_pct,
          pwrq_t/decode(iorq_t,0,null,iorq_t)*100       pw_pct,
          orrq_t/decode(prrq_t,0,null,prrq_t)*100       or_pct,
          (io_ps*ts.blocksize)/&&btomb       mb_ps,
          (pr_ps*ts.blocksize)/&&btomb   prmb_ps,
          (pw_ps*ts.blocksize)/&&btomb   pwmb_ps,
          ratio,
          iorq_ps/:io_sys_ps*100                          pct_total,
          (ratio_to_report((s.blocks*ts.blocksize)) over())*100 sratio
         from seg$iostats io
            , seg$     s
            , sys_objects so
            , ts$         ts
        where io.obj#  = so.object_id
          and so.header_file = s.file#
          and so.header_block = s.block#
          and so.ts_number          = s.ts#
          and so.segment_type_id = s.type#
          and s.ts#           = ts.ts#)
 where ratio        > &pct_thresh
 order by iorq_ps desc, io_intensity desc;

-- skip this for now - takes too long
--
-- ttitle 'IO Intensity - by Segments - use object growth trend' -
--        skip 1 -
--        '-> I/O Intensity calculated as IO Reqs per sec/GB per segment ' -
--        skip 1 -
--        '-> segments with >= ' &&pct_thresh  ' % of Captured IOs displayed' -
--        skip 1 -
--        '-> %IOPs - Running Total of % of Captured IOPs' -
--        skip 1 -
--        '   %Cap  - IOs as a percentage of Captured  IOPs' - 
--        skip 1 -
--        '   %Spc  - Running Total of % of Space for Captured Segments' -
--        skip 1 -
--        '   %Opt  - Optimized Read Requests as a percentage of read requests' -
--        skip 1 -  
--        '   %Tot  - IOs as a percentage of Total sysstat IOPs ' -
--        skip 1 -
--        '           Sysstat IOs per Sec: ' format 999,990.0 io_sys_ps -
--        skip 1 -
--        '-> ordered by Total IOPs desc, IO Intensity desc' -   
--        skip 2;
-- 
-- WITH seg$int_iostats as
--   ( select /* get IOs per segment, perinterval */
--            o.snap_id,
--            owner,
--            object_name,
--            subobject_name,
--            tablespace_name,
--            object_type,
--            n.ts#, n.obj#, n.dataobj#,
--            sum(physical_reads_delta)   pr,
--            sum(physical_writes_delta)  pw,
--            sum(physical_read_requests_delta) prrq,
--            sum(physical_write_requests_delta) pwrq,
--            sum(optimized_physical_reads_delta) orrq,
--            sum(table_scans_delta)      fs,
--            sum(physical_reads_delta/
--                ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pr_ps,
--            sum(physical_writes_delta/
--                ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pw_ps,
--            sum(physical_read_requests_delta/
--                ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       prrq_ps,
--            sum(physical_write_requests_delta/
--               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       pwrq_ps,
--            sum(optimized_physical_reads_delta/
--               ((cast(end_interval_time as date) - cast(begin_interval_time as date))*&&dtos))       orrq_ps
--         from dba_hist_seg_stat      o
--          , dba_hist_seg_stat_obj  n
--          , dba_hist_snapshot      s
--      where o.dbid            = n.dbid
--        and o.ts#             = n.ts#
--        and o.obj#            = n.obj#
--        and o.dataobj#        = n.dataobj#
--        and o.dbid            = s.dbid
--        and o.instance_number = s.instance_number
--        and o.snap_id         = s.snap_id
--        and o.dbid            = :dbid
--        and n.dbid            = :dbid
--        and s.dbid            = :dbid
--        and o.snap_id > :bsnap and o.snap_id <= :esnap
--        and s.snap_id > :bsnap and s.snap_id <= :esnap
--      group by o.snap_id
--             , owner, object_name, subobject_name, tablespace_name,object_type
--             , n.ts#, n.obj#, n.dataobj#)
-- , seg$iostats as /* total and average rates across all interval */
--   ( select owner,
--            object_name,
--            subobject_name,
--            tablespace_name,
--            object_type,
--            ts#, obj#, dataobj#,
--            sum(pr+pw)                io_t,
--            sum(prrq + pwrq)          iorq_t,
--            avg(pr_ps + pw_ps)        io_ps,  
--            avg(prrq_ps + pwrq_ps)    iorq_ps,
--            max(pr_ps + pw_ps)        mxio_ps,
--            max(prrq_ps + pwrq_ps)    mxiorq_ps,
--            sum(pr)                   pr_t,
--            sum(pw)                   pw_t,
--            sum(prrq)                 prrq_t,
--            sum(pwrq)                 pwrq_t,
--            sum(orrq)                 orrq_t,
--            sum(fs)                   fs_t,
--            avg(pr_ps)                pr_ps,
--            avg(pw_ps)                pw_ps,
--            avg(prrq_ps)              prrq_ps,
--            avg(pwrq_ps)              pwrq_ps,
--            avg(orrq_ps)              orrq_ps,
--            max(pr_ps)                mxpr_ps,
--            max(pw_ps)                mxpw_ps,
--            max(prrq_ps)              mxprrq_ps,
--            max(pwrq_ps)              mxpwrq_ps,
--            max(orrq_ps)              mxorrq_ps,
--            (ratio_to_report(avg(prrq_ps+pwrq_ps)) over())*100   ratio,
--            (ratio_to_report(max(prrq_ps+pwrq_ps)) over())*100   mxratio
--        from seg$int_iostats
--       group by  owner, object_name, subobject_name,
--                 tablespace_name, object_type,
--                 ts#, obj#, dataobj#)
-- , seg$sizes as ( /* projected size based on dbms_space */
--     select s.obj#, max(space_usage) su, max(space_alloc) sa
--       from  seg$iostats s,
--             table(dbms_space.object_growth_trend(object_owner=>s.owner,object_name=>s.object_name,object_type=>s.object_type,partition_name=>s.subobject_name,start_time=>to_timestamp(:btime,'YYYY/MM/DD HH24:MI'),end_time=>to_timestamp(:etime,'YYYY/MM/DD HH24:MI'))) t
--      where s.ratio  > &&pct_thresh
--      group by s.obj#)
-- select owner_objname_subobj,
--        tablespace_name,
--        object_type,
--        iorq_ps,
--        prrq_ps,
--        pwrq_ps,
--        space_gb,
--        io_intensity,
--        pr_intensity,
--        or_intensity,
--        pw_intensity,
--        sum(ratio) over (order by iorq_ps desc)  cum_io,
--        sum(sratio) over (order by iorq_ps desc) cum_sp,
--        mb_t,
--        io_t_str,
--        fs_t_str,
--        pr_pct,
--        or_pct,
--        pw_pct,
--        mb_ps,
--        prmb_ps,
--        pwmb_ps,
--        ratio,
--        pct_total
--   from (
--   select  io.owner || '.' ||
--               case when io.subobject_name is null 
--                    then substr(io.object_name,1,25)
--                    else substr(io.object_name,1,14) || '..(' || 
--                       case when length(io.subobject_name) < 10
--                            then io.subobject_name 
--                            else substr(io.subobject_name,length(io.subobject_name)-9)
--                        end  || ')'
--                    end owner_objname_subobj,
--           io.tablespace_name,
--           io.object_type,
--           iorq_ps                            iorq_ps,
--           prrq_ps,
--           pwrq_ps,
--           mxiorq_ps,
--           mxprrq_ps,
--           mxpwrq_ps,
--           (s.sa)/&&btogb                     space_gb,
--           iorq_ps/(s.sa/&&btogb)           io_intensity,
--           prrq_ps/(s.sa/&&btogb)           pr_intensity,
--           orrq_ps/(s.sa/&&btogb)           or_intensity,
--           pwrq_ps/(s.sa/&&btogb)           pw_intensity,
--           io_t*ts.blocksize/&&btomb         mb_t,
--           lpad(case when io_t <= 9999
--                    then to_char(io_t)
--                    when trunc(io_t/1000)         <= 9999
--                    then to_char(round(io_t/1000,1))       || 'K'
--                    when trunc(io_t/1000000)      <= 9999
--                    then to_char(round(io_t/1000000,1))    || 'M'
--                    when trunc(io_t/1000000000)   <= 9999
--                    then to_char(round(io_t/1000000000,1)) || 'G'
--                    when trunc(io_t/1000000000000) <= 9999
--                    then to_char(round(io_t/1000000000000,1)) || 'T'
--                    else to_char(round(io_t/1000000000000000,1)) || 'P'
--                end,7)  io_t_str,
--           lpad(case when fs_t <= 9999
--                    then to_char(fs_t)
--                    when trunc(fs_t/1000)         <= 9999
--                    then to_char(round(fs_t/1000,1))       || 'K'
--                    when trunc(fs_t/1000000)      <= 9999
--                    then to_char(round(fs_t/1000000,1))    || 'M'
--                    when trunc(fs_t/1000000000)   <= 9999
--                    then to_char(round(fs_t/1000000000,1)) || 'G'
--                    when trunc(fs_t/1000000000000) <= 9999
--                    then to_char(round(fs_t/1000000000000,1)) || 'T'
--                    else to_char(round(fs_t/1000000000000000,1)) || 'P'
--                end,7)  fs_t_str,
--           prrq_t/decode(iorq_t,0,null,iorq_t)*100       pr_pct,
--           pwrq_t/decode(iorq_t,0,null,iorq_t)*100       pw_pct,
--           orrq_t/decode(prrq_t,0,null,prrq_t)*100       or_pct,
--           (io_ps*ts.blocksize)/&&btomb       mb_ps,
--           (pr_ps*ts.blocksize)/&&btomb   prmb_ps,
--           (pw_ps*ts.blocksize)/&&btomb   pwmb_ps,
--           ratio,
--           iorq_ps/:io_sys_ps*100                          pct_total,
--           (ratio_to_report((s.su)) over())*100 sratio
--          from seg$iostats io
--             , seg$sizes   s
--             , sys.ts$     ts
--         where io.obj#  = s.obj#
--           and io.ts#   = ts.ts#
--            and io.ratio >= &&pct_thresh)
--  order by iorq_ps desc, io_intensity desc;
-- 
ttitle 'ASH Activity - Estimate of I/O wait times ' -
   skip 1 -
       '-> # Samples: # of samples in ASH - approximation of DB time ' -
   skip 1 -
       '-> % Activity: approximation of % Time based on ASH samples' -
   skip 1 -
       '-> ID values are based on aggregation type: ' -
   skip 1 -
       '   by Wait Class: Wait Class name '-
   skip 1 -
       '   by Segments  : Owner.Object(SubObject) ' -
   skip 1 -
       '                  * wildcard is used if object or subobject name is too long' -
   skip 1 -
       '   by File      : FileID-FileName ' -
   skip 2;

column objkey          heading "Id"              format a40 trunc
column tablespace_name heading "Tablespace Name" format a10 trunc
#column object_type    heading "Obj.|Type"       format a10 trunc
#column object_name    heading "Object Name"     format a20 trunc
column subobject_name  heading "Subobject|Name"  format a15 trunc

col aggtype heading 'Aggregation'
col ordno  noprint

break on aggtype skip 1
col nsamp format 999,999,999,999 heading '# Samples'
col pct   format 990.0 heading '% Activity'

with max_db_files as ( -- file# for temp = db_files+file#
  select to_number(value) value
    from v$parameter
   where name='db_files') 
, ash$summary as (
   select /*+ full(ash) */ ash.dbid,
          case when wait_time=0 then wait_class else 'on cpu' end wait_class,
          case when wait_time=0 and wait_class = 'User I/O'
               then current_obj#
               else null
          end  obj#,
          case when wait_time=0 and wait_class = 'User I/O'
               then current_file#
               else null
          end  file#,
          count(*)                                nsamp,
          (ratio_to_report(count(*)) over ())*100   pct
     from sys.wrh$_active_session_history ash, sys.wrh$_event_name e
    where ash.dbid = :dbid
      and snap_id > :bsnap
      and snap_id <= :esnap
      and ash.dbid = e.dbid
      and ash.event_id = e.event_id
    group by ash.dbid,
          case when wait_time=0 then wait_class else 'on cpu' end,
          case when wait_time=0 and wait_class = 'User I/O' 
               then current_obj#
               else null
          end,
          case when wait_time=0 and wait_class = 'User I/O'
               then current_file#
               else null
          end)
, segstatobj$summary as ( 
   select dbid,
          obj#,
          owner,
          object_name,
          subobject_name,
          object_type,
          tablespace_name,
          ts#
    from dba_hist_seg_stat_obj
   where dbid = :dbid
   group by dbid, obj#, owner, object_name, subobject_name, object_type, 
            tablespace_name, ts#)
, seg$summary as (
   select ash.obj#,
          nvl(n.owner,'Unavailable')   owner,
          nvl(n.object_name,'Unavailable')   object_name,
          n.subobject_name,
          n.object_type,
          n.tablespace_name,
          n.ts#,
          sum(ash.nsamp)  nsamp,
          sum(ash.pct)    pct
     from ash$summary ash,
          segstatobj$summary n
   where ash.dbid = n.dbid (+)
     and ash.obj# = n.obj# (+)
     and ash.wait_class = 'User I/O' 
   group by ash.obj#,
          nvl(n.owner,'Unavailable'),
          nvl(n.object_name,'Unavailable'),
          n.subobject_name,
          n.object_type,
          n.tablespace_name,
          n.ts#)
, fil$summary as ( -- map files to ts
  select ash.file#,
         f.ts#,
         sum(nsamp)   nsamp,
         sum(pct)     pct
    from ash$summary ash,
         dba_hist_datafile f
   where ash.dbid = f.dbid
     and ash.wait_class = 'User I/O'
     and ash.file# = f.file#
     and ash.file# <= (select value from max_db_files)
   group by ash.file#, f.ts# 
   union all
  select f.file#,
         f.ts#,
         sum(nsamp)   nsamp,
         sum(pct)     pct
    from ash$summary ash,
         dba_hist_tempfile f,
         (select value from max_db_files) v
   where ash.dbid = f.dbid
     and ash.wait_class = 'User I/O'
     and ash.file# - v.value = f.file#
     and ash.file# > v.value
   group by f.file#, f.ts# )
, obj$summary as (
  select obj.obj#,
         obj.owner,
         obj.object_name,
         obj.subobject_name,
         obj.object_type,
         obj.tablespace_name,
         obj.ts#,
         obj.nsamp,
         obj.pct,
         s.blocks*ts.blocksize   bytes
    from seg$summary obj,
         seg$      s,
         sys_objects so,
         ts$         ts
   where obj.obj# = so.object_id
     and so.header_file = s.file#
     and so.header_block = s.block#
     and so.ts_number          = s.ts#
     and so.segment_type_id = s.type#
     and s.ts#           = ts.ts#) 
, df$size as ( -- use file$ to get size, dba_data_files is expensive
  select f.file#, nvl(df.filename,'Unknown') filename,
         f.ts#, nvl(df.tsname,'Unknown') tsname,
         f.blocks*nvl(df.block_size,8192) bytes, 
         nvl(df.block_size,8192) block_size
    from file$ f,
         dba_hist_datafile df
   where f.ts# = df.ts# (+)
     and f.file# = df.file# (+)
     and df.dbid = :dbid
   union all -- tempfile does not join to file$
  select t.file_id, t.file_name filename,
         ts.ts#, ts.name tsname,
         t.bytes,
         ts.blocksize block_size
    from ts$ ts,
         dba_temp_files t
   where t.tablespace_name = ts.name)
, ts$size as (
    select ts#, tsname,
           max(block_size) block_size,
           sum(bytes) bytes
      from df$size
     group by ts#, tsname)
select 0 ordno,
       'by Wait Class'  aggtype,
       wait_class       objkey,
       null             object_type,
       null             tablespace_name,
       sum(nsamp)       nsamp,
       null             space_gb,
       null             io_intensity,
       sum(pct)         pct
  from ash$summary
 group by wait_class having sum(pct) > &&pct_thresh
union all 
select 2 ordno,
       'by Segment'     aggtype,
       owner || '.' ||
         case when subobject_name is null 
              then substr(object_name,1,25)
              else case when length(object_name) <= 14
                        then object_name || '('
                        else substr(object_name,1,13) || '*(' 
                   end ||
                   case when least(15,length(object_name)) +
                             length(subobject_name) < 25
                        then subobject_name 
                        else '*' ||
                             substr(subobject_name,length(subobject_name)-9)
                   end  || ')'
          end objkey,
       object_type,
       tablespace_name,
       nsamp,
       bytes/&&btogb    space_gb,
       nsamp/(bytes/&&btogb)   io_intensity,
       pct
  from obj$summary
 where pct > &&pct_thresh
union all
select 3 ordno,
       'by Tablespace'      aggtype,
       null                 objkey,
       null                 object_type,
       tsname               tablespace_name,
       nsamp,
       ts.bytes/&&btogb     space_gb,
       nsamp/(decode(ts.bytes,0,null,ts.bytes)/&&btogb) io_intensity,
       pct
    from (select ts#,
                 sum(nsamp)   nsamp,
                 sum(pct)     pct
            from fil$summary
           group by ts#) obj,
         ts$size ts
 where obj.ts# = ts.ts# (+)
   and pct > &&pct_thresh
union all
select 4 ordno,
       'by File'      aggtype,
       df.file# || '-' || df.filename          objkey,
       null                 object_type,
       df.tsname    tablespace_name,
       nsamp,
       df.bytes/&&btogb     space_gb,
       f.nsamp/(decode(df.bytes,0,null,df.bytes)/&&btogb) io_intensity,
       pct
    from fil$summary f,
         df$size    df
 where f.ts# = df.ts#
   and f.ts# = df.ts#
   and pct > &&pct_thresh
order by ordno, pct desc, aggtype, objkey;

--
-- I/O profiles
--

ttitle 'I/O Activity ' -
   skip 2;

column stat_name format a40 trunc        heading 'Statistic Name'
column v_delta   format 999,999,999,999,990      heading 'Value'
column v_ps      format 999,999,999,999,990.0    heading 'Value|per Sec'


select stat_name
     , sum(v_delta)   v_delta
     , avg(v_ps)      v_ps    -- rates are per-snapshot interval, so use avg
  from ( /* compute cluster totals */
      select snap_id
           , stat_name
           , sum(value)               value
           , sum(value - pv)          v_delta
           , sum((value - pv)/ela_s)  v_ps
       from ( /* get value per snapshot and previous value - bounces can occur */
         select sy.instance_number
             , sy.snap_id
             , sy.stat_name
             , sy.value
             , lag(sy.value,1) over (partition by sy.stat_name, sy.dbid, sy.instance_number, s.startup_time
                                         order by sy.snap_id )   pv
             , (cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&&dtos   ela_s
          from dba_hist_snapshot s
             , dba_hist_sysstat sy
         where s.dbid            = sy.dbid
           and s.instance_number = sy.instance_number
           and s.snap_id         = sy.snap_id
           and s.dbid            = :dbid
           and sy.dbid           = :dbid
           and s.snap_id  between :bsnap and :esnap
           and sy.snap_id between :bsnap and :esnap
           and ( sy.stat_name like 'physical%'
               or sy.stat_name like '%scan%'
               or sy.stat_name like 'redo%'))
     group by stat_name, snap_id)
 group by stat_name
 order by stat_name;

--
-- Captured I/O in segment statistics
--

ttitle 'I/O Statistics Comparison ' -
   skip 2;

column name  format a40 heading 'Statistic Name'
column ssval format 999,999,999,999,990.0 heading 'Segment Stats|(thousands)'
column syval format 999,999,999,999,990.0 heading 'System  Stats|(thousands)'
column pct_cap format             9,990.0 heading '% Captured'


break on report
compute sum of syval on report
compute sum of ssval on report


select sy.stat_name
     , sy.v/1000         syval
     , (case when sy.stat_name = 'physical read IO requests'  then prrq
            when sy.stat_name = 'physical write IO requests' then pwrq
            when sy.stat_name = 'physical read requests optimized' then orrq
            when sy.stat_name = 'full scans'       then fs
            else 0
        end)/1000  ssval
     , (case when sy.stat_name = 'physical read IO requests'  then prrq
             when sy.stat_name = 'physical write IO requests' then pwrq
             when sy.stat_name = 'physical read requests optimized' then orrq
             when sy.stat_name = 'full scans'      then fs
             else 0
        end)/decode(sy.v,0,null,sy.v)*100    pct_cap
  from
       (select s.dbid,
               sum(physical_read_requests_delta) prrq,
               sum(physical_write_requests_delta) pwrq,
               sum(optimized_physical_reads_delta) orrq,
               sum(table_scans_delta)              fs
          from dba_hist_seg_stat s
         where s.dbid = :dbid
           and s.snap_id > :bsnap and s.snap_id <= :esnap
         group by s.dbid) ss
     , (select dbid,
               case when stat_name = 'physical read IO requests' 
                      or stat_name = 'physical write IO requests' 
                      or stat_name = 'physical read requests optimized'
                    then stat_name
                    else 'full scans'
                end stat_name
             , sum(v)          v
         from ( /* get value per snapshot and prev value - bounces can occur */
            select sy.dbid, sy.instance_number,
                  sy.snap_id,
                  sy.stat_name,
                  sy.value -
                    lag(sy.value,1) 
                      over (partition by sy.stat_name, 
                                   sy.dbid, sy.instance_number, s.startup_time
                                order by sy.snap_id )  v
             from dba_hist_snapshot s,
                  dba_hist_sysstat sy
            where s.dbid = sy.dbid
              and s.instance_number = sy.instance_number
              and s.snap_id         = sy.snap_id
              and s.dbid            = :dbid
              and sy.dbid           = :dbid
              and s.snap_id  between :bsnap and :esnap
              and sy.snap_id between :bsnap and :esnap
              and sy.stat_name in ('physical read IO requests', 
                                   'physical write IO requests',
                                   'physical read requests optimized',
                                   'table scans (long tables)',
                                   'index fast full scans (full)' ))
        group by dbid
                ,case when stat_name='physical read IO requests'
                        or stat_name='physical write IO requests'
                        or stat_name='physical read requests optimized'
                      then stat_name
                      else 'full scans'
                  end) sy
 where sy.dbid = ss.dbid
order by sy.stat_name;

--
-- I/O Statistics by File
--

ttitle 'I/O Statistics by File type ' -
  skip 2;

column filetype_name format a15 trunc heading 'Filetype'
column rq_t          format 9,999,999,999,990 heading 'Total|Requests'
column mb_t          format 9,999,999,999,990 heading 'Total|MB'
column srrq_ps       format 99,999,990.0 heading 'Small|Read|Reqs/s'
column ssrrq_ps      format 99,999,990.0 heading 'Small|Sync|Read|Reqs/s'
column lrrq_ps       format 99,999,990.0 heading 'Large|Read|Reqs/s'
column swrq_ps       format 99,999,990.0 heading 'Small|Write|Reqs/s'
column lwrq_ps       format 99,999,990.0 heading 'Large|Write|Reqs/s'
column srmb_ps       format 99,990.0 heading 'Small|Read|MB/s'
column lrmb_ps       format 99,990.0 heading 'Large|Read|MB/s'
column swmb_ps       format 99,990.0 heading 'Small|Write|MB/s'
column lwmb_ps       format 99,990.0 heading 'Large|Write|MB/s'

break on report
compute sum of srrq_ps  on report
compute sum of ssrrq_ps on report
compute sum of lrrq_ps  on report
compute sum of swrq_ps  on report
compute sum of lwrq_ps  on report
compute sum of srmb_ps  on report
compute sum of ssrmb_ps on report
compute sum of lrmb_ps  on report
compute sum of swmb_ps  on report
compute sum of lwmb_ps  on report
compute sum of rq_t     on report
compute sum of mb_t     on report


select filetype_name   /* compute avg per second rates across all intervals */
     , sum(srrq)+sum(ssrrq)+sum(lrrq)+sum(swrq)+sum(lwrq)   rq_t
     , avg(srrq_ps)     srrq_ps
     , avg(ssrrq_ps)   ssrrq_ps
     , avg(lrrq_ps)     lrrq_ps
     , avg(swrq_ps)     swrq_ps
     , avg(lwrq_ps)     lwrq_ps
     , sum(srmb)+sum(lrmb)+sum(swmb)+sum(lwmb)              mb_t
     , avg(srmb_ps)     srmb_ps
     , avg(lrmb_ps)     lrmb_ps
     , avg(swmb_ps)     swmb_ps
     , avg(lwmb_ps)     lwmb_ps
  from ( /* compute cluster-wide totals */
      select snap_id
           , filetype_name
           , sum(srrq_delta)            srrq
           , sum(ssrrq_delta)          ssrrq
           , sum(srmb_delta)            srmb
           , sum(lrrq_delta)            lrrq
           , sum(lrmb_delta)            lrmb
           , sum(swrq_delta)            swrq
           , sum(swmb_delta)            swmb
           , sum(lwrq_delta)            lwrq
           , sum(lwmb_delta)            lwmb
           , sum(srrq_delta/ela_s)    srrq_ps
           , sum(ssrrq_delta/ela_s)  ssrrq_ps
           , sum(srmb_delta/ela_s)    srmb_ps
           , sum(lrrq_delta/ela_s)    lrrq_ps
           , sum(lrmb_delta/ela_s)    lrmb_ps
           , sum(swrq_delta/ela_s)    swrq_ps
           , sum(swmb_delta/ela_s)    swmb_ps
           , sum(lwrq_delta/ela_s)    lwrq_ps
           , sum(lwmb_delta/ela_s)    lwmb_ps
        from ( /* get per instance deltas */
         select f.instance_number
              , f.snap_id
              , filetype_name
              , small_read_reqs       
              , small_sync_read_reqs
              , large_read_reqs
              , large_read_megabytes
              , small_read_megabytes
              , small_write_reqs
              , small_write_megabytes
              , large_write_reqs
              , large_write_megabytes
              , small_read_reqs      - lag(small_read_reqs       ,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             srrq_delta
              , small_sync_read_reqs - lag(small_sync_read_reqs,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                            ssrrq_delta
              , large_read_reqs      - lag(large_read_reqs,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lrrq_delta
              , large_read_megabytes - lag(large_read_megabytes,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lrmb_delta
              , small_read_megabytes - lag(small_read_megabytes,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             srmb_delta
              , small_write_reqs     - lag(small_write_reqs,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             swrq_delta
              , small_write_megabytes - lag(small_write_megabytes,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             swmb_delta
              , large_write_reqs      - lag(large_write_reqs,1)             
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lwrq_delta
              , large_write_megabytes - lag(large_write_megabytes,1) 
                  over (partition by f.filetype_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lwmb_delta
              , (cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&dtos              ela_s
           from dba_hist_iostat_filetype f
              , dba_hist_snapshot    s
          where f.dbid             = s.dbid
            and f.instance_number  = s.instance_number
            and f.snap_id          = s.snap_id
            and f.dbid             = :dbid
            and s.dbid             = :dbid
            and f.snap_id between :bsnap and :esnap
            and s.snap_id between :bsnap and :esnap)
  group by snap_id, filetype_name)
 where srrq + ssrrq + lrrq + swrq + lwrq + srmb + lrmb + swmb + lwmb > 0
 group by filetype_name
 order by mb_t desc;
       
-- I/O Statistics by Function
--

ttitle 'I/O Statistics by Function ' -
  skip 2;

column function_name format a15 trunc heading 'Function'
column srrq_ps       format 99,999,990.0 heading 'Small|Read|Reqs/s'
column ssrrq_ps      format 99,999,990.0 heading 'Small|Sync|Read|Reqs/s'
column lrrq_ps       format 99,999,990.0 heading 'Large|Read|Reqs/s'
column swrq_ps       format 99,999,990.0 heading 'Small|Write|Reqs/s'
column lwrq_ps       format 99,999,990.0 heading 'Large|Write|Reqs/s'
column srmb_ps       format 99,990.0 heading 'Small|Read|MB/s'
column lrmb_ps       format 99,990.0 heading 'Large|Read|MB/s'
column swmb_ps       format 99,990.0 heading 'Small|Write|MB/s'
column lwmb_ps       format 99,990.0 heading 'Large|Write|MB/s'


select function_name   /* compute avg per second rates across all intervals */
     , sum(srrq)+sum(lrrq)+sum(swrq)+sum(lwrq)   rq_t
     , avg(srrq_ps)     srrq_ps
     , avg(lrrq_ps)     lrrq_ps
     , avg(swrq_ps)     swrq_ps
     , avg(lwrq_ps)     lwrq_ps
     , sum(srmb)+sum(lrmb)+sum(swmb)+sum(lwmb)              mb_t
     , avg(srmb_ps)     srmb_ps
     , avg(lrmb_ps)     lrmb_ps
     , avg(swmb_ps)     swmb_ps
     , avg(lwmb_ps)     lwmb_ps
  from ( /* compute cluster-wide totals and rates */
      select snap_id
           , function_name
           , sum(srrq_delta)             srrq
           , sum(srmb_delta)             srmb
           , sum(lrrq_delta)             lrrq
           , sum(lrmb_delta)             lrmb
           , sum(swrq_delta)             swrq
           , sum(swmb_delta)             swmb
           , sum(lwrq_delta)             lwrq
           , sum(lwmb_delta)             lwmb
           , sum(srrq_delta/ela_s)    srrq_ps
           , sum(srmb_delta/ela_s)    srmb_ps
           , sum(lrrq_delta/ela_s)    lrrq_ps
           , sum(lrmb_delta/ela_s)    lrmb_ps
           , sum(swrq_delta/ela_s)    swrq_ps
           , sum(swmb_delta/ela_s)    swmb_ps
           , sum(lwrq_delta/ela_s)    lwrq_ps
           , sum(lwmb_delta/ela_s)    lwmb_ps
        from ( /* get per instance deltas */
         select f.instance_number
              , f.snap_id
              , function_name
              , small_read_reqs       
              , large_read_reqs
              , large_read_megabytes
              , small_read_megabytes
              , small_write_reqs
              , small_write_megabytes
              , large_write_reqs
              , large_write_megabytes
              , small_read_reqs      - lag(small_read_reqs       ,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             srrq_delta
              , large_read_reqs      - lag(large_read_reqs,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lrrq_delta
              , large_read_megabytes - lag(large_read_megabytes,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lrmb_delta
              , small_read_megabytes - lag(small_read_megabytes,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             srmb_delta
              , small_write_reqs     - lag(small_write_reqs,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             swrq_delta
              , small_write_megabytes - lag(small_write_megabytes,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             swmb_delta
              , large_write_reqs      - lag(large_write_reqs,1)             
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lwrq_delta
              , large_write_megabytes - lag(large_write_megabytes,1) 
                  over (partition by f.function_name, f.instance_number, f.dbid, s.startup_time order by f.snap_id)                             lwmb_delta
              , (cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*&dtos              ela_s
           from dba_hist_iostat_function f
              , dba_hist_snapshot    s
          where f.dbid            = s.dbid
            and f.instance_number = s.instance_number
            and f.snap_id         = s.snap_id
            and f.snap_id between :bsnap and :esnap
            and s.snap_id between :bsnap and :esnap)
  group by snap_id, function_name)
 where srrq + lrrq + swrq + lwrq + srmb + lrmb + swmb + lwmb > 0
 group by function_name
 order by mb_t desc;

clear breaks compute

prompt
prompt End of Report ( &report_name )
prompt

set linesize 80
spool off
undef inst_num
undef inst_name
undef db_name
undef dbid
undef begin_snap
undef end_snap
undef dflt_name
undef report_name
undef num_days
undef pr_sys_t
undef pw_sys_t
undef or_sys_t
undef pr_sys_ps
undef pw_sys_ps
undef or_sys_ps
undef io_sys_ps

clear columns sql;
ttitle off;
btitle off;
repfooter off;





