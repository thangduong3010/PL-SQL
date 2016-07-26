rem 
rem $Header: utlestat.sql 02-jan-2001.19:40:14 cdialeri Exp $ estat.sql 
rem 
Rem Copyright (c) 1988, 1996, 1998, 2000 by Oracle Corporation
Rem NAME
REM    UTLESTAT.SQL
Rem  FUNCTION
Rem    This script will generate a report (in "report.txt") which will contain
Rem    usefull information for performance monitoring.  In particular
Rem    information from v$sysstat, v$latch, and v$rollstat.
Rem  NOTES
Rem    Don't worry about errors during "drop table"s, they are normal.
Rem  MODIFIED
Rem     cdialeri   01/02/01  - 891059: SQL*Plus compat, 1566460: connect /
Rem     mchien     03/22/00 -  desupport connect internal
Rem     kquinn     04/16/00  - 1133880: Remove Avg Write Queue Length
Rem     khailey    03/15/99 -  594266: Correct per logon stats, add fstat fields 
Rem     kquinn     01/12/98 -  607968: Correct nowait latch hit ratio calc
Rem     jklein     08/23/96 -  bug 316570 - fix typo
Rem     akolk      08/09/96 -  #387757: fix latch hitratios
Rem     akolk      07/19/96 -  #298462: correcting latch miss rate (Fixing)
Rem     akolk      07/19/96 -  #298462: correcting latch miss rate
Rem     akolk      07/12/96 -  #270507: remove db_block_write_batch
Rem     jloaiza    10/14/95 -  add vtcsh 5.18 (BBN) 2/20/90 Patch level 0
Rem     jloaiza    09/19/95 -  add waitstat
Rem     jloaiza    09/04/95 -  per second stats, split background waits
Rem     drady      09/09/93 -  merge changes from branch 1.1.312.2
Rem     drady      04/26/93 -  Stat name changes for 7.1 
Rem     drady      03/22/93 -  merge changes from branch 1.1.312.1 
Rem     drady      08/24/93 -  bug 173918
Rem     drady      03/04/93 -  fix bug 152986 
Rem     glumpkin   11/23/92 -  Creation 
Rem     glumpkin   11/23/92 -  Renamed from UTLSTATE.SQL 
Rem     glumpkin   10/20/92 -  Renamed from ESTAT.SQL 
Rem     jloaiza    03/26/92 -  add write queue query 
Rem     jloaiza    02/24/92 -  fix latch stats 
Rem     jloaiza    01/17/92 -  improve output 
Rem     jloaiza    01/07/92 -  rework for version 7
Rem   Laursen    01/01/91 - V6 to V7 merge
Rem   Trabosh    09/27/89 - added order by and group by to stats$files
Rem   Loaiza     04/04/89 - fix run dates to do minutes instead of months
Rem   Loaiza     03/31/89 - add kqrst usage column
Rem   Jloaiza    03/16/89 - improve names and formats
Rem   Jloaiza    03/09/89 - make kqrst columns intelligible
Rem   Jloaiza    02/23/89 - changed table names, added dates
Rem   Martin     02/22/89 - Creation
set echo on;
connect / as sysdba;

set pages 999;
set lines 79;

Rem ********************************************************************
Rem                Gather Ending Statistics
Rem ********************************************************************


insert into stats$end_latch select * from v$latch;
insert into stats$end_stats select * from v$sysstat;
insert into stats$end_lib select * from v$librarycache;
update stats$dates set end_time = sysdate;
insert into stats$end_event select * from v$system_event;
insert into stats$end_bck_event 
  select event, sum(total_waits), sum(time_waited)
    from v$session s, v$session_event e
    where type = 'BACKGROUND' and s.sid = e.sid
    group by event;
insert into stats$end_waitstat select * from v$waitstat;
insert into stats$end_roll select * from v$rollstat;
insert into stats$end_file select * from stats$file_view;
insert into stats$end_dc select * from v$rowcache;

Rem ********************************************************************
Rem                Create Summary Tables
Rem ********************************************************************

drop table stats$stats;
drop table stats$latches;
drop table stats$roll;
drop table stats$files;
drop table stats$dc;
drop table stats$lib;
drop table stats$event;
drop table stats$bck_event;
drop table stats$waitstat;

update stats$dates set start_users = (select value 
    from  v$statname n , stats$begin_stats b
       where n.statistic# = b.statistic# and n.name='logons current');
update stats$dates set end_users = (select value 
    from  v$statname n , stats$end_stats b
       where n.statistic# = b.statistic# and n.name='logons current');


create table stats$stats as
select  e.value-b.value change , n.name
   from v$statname n ,  stats$begin_stats b , stats$end_stats e
	where n.statistic# = b.statistic# and n.statistic# = e.statistic#;

create table stats$latches as
select 	e.gets-b.gets gets, 
	e.misses-b.misses misses,
	e.sleeps-b.sleeps sleeps,
	e.immediate_gets-b.immediate_gets immed_gets,
	e.immediate_misses-b.immediate_misses immed_miss,
	n.name
   from v$latchname n ,  stats$begin_latch b , stats$end_latch e
	where n.latch# = b.latch# and n.latch# = e.latch#;

create table stats$event as
  select  e.total_waits-b.total_waits event_count,
          e.time_waited-b.time_waited time_waited,
          e.event
    from  stats$begin_event b , stats$end_event e
    where b.event = e.event
  union all
  select  e.total_waits event_count,
          e.time_waited time_waited,
          e.event	
    from  stats$end_event e
    where e.event not in (select b.event from stats$begin_event b);

Rem background waits
create table stats$bck_event as
  select  e.total_waits-b.total_waits event_count,
          e.time_waited-b.time_waited time_waited,
          e.event
    from  stats$begin_bck_event b , stats$end_bck_event e
    where b.event = e.event
  union all
  select  e.total_waits event_count,
          e.time_waited time_waited,
          e.event	
    from  stats$end_bck_event e
    where e.event not in (select b.event from stats$begin_bck_event b);

Rem subtrace background events out of regular events
update stats$event e 
  set (event_count, time_waited) = 
	(select e.event_count - b.event_count,
	        e.time_waited - b.time_waited
	  from stats$bck_event b
         where e.event = b.event)
   where e.event in (select b.event from stats$bck_event b);

create table stats$waitstat as
select  e.class, 
        e.count - b.count count, 
        e.time - b.time time
  from stats$begin_waitstat b, stats$end_waitstat e
   where e.class = b.class;

create table stats$roll as
select  e.usn undo_segment,
        e.gets-b.gets trans_tbl_gets, 
	e.waits-b.waits trans_tbl_waits, 
	e.writes-b.writes undo_bytes_written,
	e.rssize segment_size_bytes,
        e.xacts-b.xacts xacts,
	e.shrinks-b.shrinks shrinks,
        e.wraps-b.wraps wraps
   from stats$begin_roll b, stats$end_roll e
        where e.usn = b.usn;

create table stats$files as
select b.ts table_space,
       b.name file_name,
       e.pyr-b.pyr phys_reads,
       e.pbr-b.pbr phys_blks_rd,
       e.prt-b.prt phys_rd_time,
       e.pyw-b.pyw phys_writes,
       e.pbw-b.pbw phys_blks_wr,
       e.pwt-b.pwt phys_wrt_tim,
       e.megabytes_size
  from stats$begin_file b, stats$end_file e
       where b.name=e.name;

create table stats$dc as
select b.parameter name,
       e.gets-b.gets get_reqs,
       e.getmisses-b.getmisses get_miss,
       e.scans-b.scans scan_reqs,
       e.scanmisses-b.scanmisses scan_miss,
       e.modifications-b.modifications mod_reqs,
       e.count count,
       e.usage cur_usage
  from stats$begin_dc b, stats$end_dc e
       where b.cache#=e.cache# 
        and  nvl(b.subordinate#,-1) = nvl(e.subordinate#,-1);

create table stats$lib as
select e.namespace,
       e.gets-b.gets gets,
       e.gethits-b.gethits gethits,
       e.pins-b.pins pins,
       e.pinhits-b.pinhits pinhits,
       e.reloads - b.reloads reloads,
       e.invalidations - b.invalidations invalidations
  from stats$begin_lib b, stats$end_lib e
       where b.namespace = e.namespace;


Rem *******************************************************************
Rem              Output statistics
Rem *******************************************************************

spool report.txt;

column library       format a12 trunc;
column pinhitratio   heading 'PINHITRATI';
column gethitratio   heading 'GETHITRATI';
column invalidations heading 'INVALIDATI';
set numwidth 10;
Rem Select Library cache statistics.  The pin hit rate should be high.
select namespace library,
       gets, 
       round(decode(gethits,0,1,gethits)/decode(gets,0,1,gets),3) 
          gethitratio,
       pins, 
       round(decode(pinhits,0,1,pinhits)/decode(pins,0,1,pins),3) 
          pinhitratio,
       reloads, invalidations
  from stats$lib;

column "Statistic"       format a27 trunc;
column "Per Transaction" heading "Per Transact";
column ((start_users+end_users)/2) heading "((START_USER"
set numwidth 12;
Rem The total is the total value of the statistic between the time
Rem bstat was run and the time estat was run.  Note that the estat
Rem script logs on to the instance so the per_logon statistics will
Rem always be based on at least one logon.
select 'Users connected at ',to_char(start_time, 'dd-mon-yy hh24:mi:ss'),':',start_users from stats$dates;
select 'Users connected at ',to_char(end_time, 'dd-mon-yy hh24:mi:ss'),':',end_users from stats$dates;
select 'avg # of connections: ',((start_users+end_users)/2) from stats$dates;

select n1.name "Statistic", 
       n1.change "Total", 
       round(n1.change/trans.change,2) "Per Transaction",
       round(n1.change/((start_users + end_users)/2),2)  "Per Logon",
       round(n1.change/(to_number(to_char(end_time,   'J'))*60*60*24 -
                        to_number(to_char(start_time, 'J'))*60*60*24 +
			to_number(to_char(end_time,   'SSSSS')) -
			to_number(to_char(start_time, 'SSSSS')))
             , 2) "Per Second"
   from 
		stats$stats n1, 
		stats$stats trans, 
		stats$dates
   where 
	 trans.name='user commits'
    and  n1.change != 0
   order by n1.name;

column "Event Name" format a32 trunc;
set numwidth 13;
Rem System wide wait events for non-background processes (PMON, 
Rem SMON, etc).  Times are in hundreths of seconds.  Each one of 
Rem these is a context switch which costs CPU time.  By looking at
Rem the Total Time you can often determine what is the bottleneck 
Rem that processes are waiting for.  This shows the total time spent
Rem waiting for a specific event and the average time per wait on 
Rem that event.
select 	n1.event "Event Name", 
       	n1.event_count "Count",
	n1.time_waited "Total Time",
	round(n1.time_waited/n1.event_count, 2) "Avg Time"
   from stats$event n1
   where n1.event_count > 0
   order by n1.time_waited desc;


Rem System wide wait events for background processes (PMON, SMON, etc)
select 	n1.event "Event Name", 
       	n1.event_count "Count",
	n1.time_waited "Total Time",
	round(n1.time_waited/n1.event_count, 2) "Avg Time"
   from stats$bck_event n1
   where n1.event_count > 0
   order by n1.time_waited desc;


column latch_name format a18 trunc;
set numwidth 11;
Rem Latch statistics. Latch contention will show up as a large value for
Rem the 'latch free' event in the wait events above.
Rem Sleeps should be low.  The hit_ratio should be high.
select name latch_name, gets, misses,
    round((gets-misses)/decode(gets,0,1,gets),3) 
      hit_ratio,
    sleeps,
    round(sleeps/decode(misses,0,1,misses),3) "SLEEPS/MISS"
   from stats$latches 
    where gets != 0
    order by name;

set numwidth 16
Rem Statistics on no_wait gets of latches.  A no_wait get does not 
Rem wait for the latch to become free, it immediately times out.
select name latch_name,
    immed_gets nowait_gets,
    immed_miss nowait_misses,
    round((immed_gets/(immed_gets+immed_miss)), 3)
      nowait_hit_ratio 
   from stats$latches 
    where immed_gets + immed_miss != 0
    order by name;

Rem Buffer busy wait statistics.  If the value for 'buffer busy wait' in 
Rem the wait event statistics is high, then this table will identify
Rem which class of blocks is having high contention.  If there are high
Rem 'undo header' waits then add more rollback segments.  If there are
Rem high 'segment header' waits then adding freelists might help.  Check
Rem v$session_wait to get the addresses of the actual blocks having
Rem contention.
select * from stats$waitstat 
  where count != 0 
  order by count desc;


set lines 159;
set numwidth 19;
Rem Waits_for_trans_tbl high implies you should add rollback segments.
select * from stats$roll;
set lines 79;

column name  format a39 trunc;
column value format a39 trunc;
Rem The init.ora parameters currently in effect:
select name, value from v$parameter where isdefault = 'FALSE' 
  order by name;

column name format a15 trunc;
column scan_reqs heading 'SCAN_REQ';
column scan_miss heading 'SCAN_MIS';
column cur_usage heading 'CUR_USAG';
set numwidth 8;
Rem get_miss and scan_miss should be very low compared to the requests.
Rem cur_usage is the number of entries in the cache that are being used.
select * from stats$dc
 where get_reqs != 0 or scan_reqs != 0 or mod_reqs != 0;


set lines 157;
column table_space format a80 trunc;
set numwidth 10;
Rem Sum IO operations over tablespaces.
select
  table_space||'                                                 ' 
     table_space,
  sum(phys_reads) reads,  sum(phys_blks_rd) blks_read,
  sum(phys_rd_time) read_time,  sum(phys_writes) writes,
  sum(phys_blks_wr) blks_wrt,  sum(phys_wrt_tim) write_time,
  sum(megabytes_size) megabytes
 from stats$files
 group by table_space
 order by table_space;


set lines 196;
column table_space format a48 trunc;
column file_name   format a48 trunc;
set numwidth 10;
Rem I/O should be spread evenly accross drives. A big difference between
Rem phys_reads and phys_blks_rd implies table scans are going on.
select table_space, file_name,
       phys_reads reads, phys_blks_rd blks_read, phys_rd_time read_time,
       phys_writes writes, phys_blks_wr blks_wrt, phys_wrt_tim write_time, 
       megabytes_size megabytes,
       round(decode(phys_blks_rd,0,0,phys_rd_time/phys_blks_rd),2) avg_rt,
       round(decode(phys_reads,0,0,phys_blks_rd/phys_reads),2) "blocks/rd"
 from stats$files order by table_space, file_name;
set lines 79;

column start_time format a25;
column end_time   format a25;
Rem The times that bstat and estat were run.
select to_char(start_time, 'dd-mon-yy hh24:mi:ss') start_time,
       to_char(end_time,   'dd-mon-yy hh24:mi:ss') end_time
  from stats$dates;

column banner format a75 trunc;
Rem Versions
select * from v$version;


spool off;

Rem ********************************************************************
Rem                 Drop Temporary Tables
Rem ********************************************************************

drop table stats$dates;

drop table stats$begin_stats;
drop table stats$end_stats;
drop table stats$stats;

drop table stats$begin_latch;
drop table stats$end_latch;
drop table stats$latches;

drop table stats$begin_roll;
drop table stats$end_roll;
drop table stats$roll;

drop table stats$begin_file;
drop table stats$end_file;
drop table stats$files;
drop view stats$file_view;

drop table stats$begin_dc;
drop table stats$end_dc;
drop table stats$dc;

drop table stats$begin_lib;
drop table stats$end_lib;
drop table stats$lib;

drop table stats$begin_event;
drop table stats$end_event;
drop table stats$event;

drop table stats$begin_bck_event;
drop table stats$end_bck_event;
drop table stats$bck_event;

drop table stats$begin_waitstat;
drop table stats$end_waitstat;
drop table stats$waitstat;
