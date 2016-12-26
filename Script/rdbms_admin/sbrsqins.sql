Rem
Rem $Header: rdbms/admin/sbrsqins.sql /main/2 2010/01/28 10:40:10 shsong Exp $
Rem
Rem sbrsqins.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbrsqins.sql - Standby StatsPack Report SQl Instance
Rem
Rem    DESCRIPTION
Rem      Standby Statspack SQL report to show resource usage, SQL Text
Rem      and any SQL Plans
Rem
Rem    NOTES
Rem      Usually run as the STDBYPERF user
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      09/15/09 - Created
Rem

-- 
-- Get the report settings
@@sbrepcon.sql

clear break compute;
repfooter off;
ttitle off;
btitle off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on;

--
-- Request the DB Id and Instance Number, if they are not specified

column dbb_unique_name heading "DB Unique Name" format a30;
column instt_name      heading "Instance Name"  format a16;

prompt
prompt 
prompt Instances in this Statspack schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct db_unique_name  dbb_unique_name
     , inst_name                instt_name
  from stats$standby_config;

prompt 
prompt Enter the DATABASE UNIQUE NAME of the standby database to report
prompt You entered: &&db_unique_name

prompt 
prompt Enter the INSTANCE NAME of the standby database instance to report
prompt You entered: &&inst_name


--
--  Set up the binds for db_unique_name and instance_name

variable db_unique_name varchar2(30);
variable inst_name      varchar2(16);
begin
  :db_unique_name := trim('&db_unique_name');
  :inst_name      := trim('&inst_name');
end;
/

--
--  Error reporting

whenever sqlerror exit;
variable max_snap_time char(10);
declare

  cursor cidnum is
     select 'X'
       from stats$database_instance
      where instance_name    = :inst_name
        and db_unique_name   = :db_unique_name;

  cursor csnapid is
     select to_char(max(snap_time),'dd/mm/yyyy')
       from stats$snapshot
      where instance_name    = :inst_name
        and db_unique_name   = :db_unique_name;

  vx     char(1);

begin

  -- Check Database Unique Name/Instance Name is a valid pair
  open cidnum;
  fetch cidnum into vx;
  if cidnum%notfound then
    raise_application_error(-20200,
      'Database/Instance '||:db_unique_name||'/'||:inst_name||' does not exist in STATS$DATABASE_INSTANCE');
  end if;
  close cidnum;

  -- Check Snapshots exist for Database Unique Name/Instance Name 
  open csnapid;
  fetch csnapid into :max_snap_time;
  if csnapid%notfound then
    raise_application_error(-20200,
      'No snapshots exist for Database/Instance '||:db_unique_name||'/'||:inst_name);
  end if;
  close csnapid;

end;
/
whenever sqlerror continue;


--
--  Ask how many days of snapshots to display

set termout on;
column instart_fmt noprint;
column db_unique_name  format a30  heading 'Database';
column inst_name       format a12  heading 'Instance';
column snap_id         format 99999990 heading 'Snap|Id';
column snapdat         format a17  heading 'Snap Started' just c;
column lvl             format 99   heading 'Snap|Level';
column commnt          format a20  heading 'Comment';

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
--  List available snapshots

break on db_unique_name on inst_name on instart_fmt skip 1;

ttitle off;

select to_char(s.startup_time,' dd Mon "at" HH24:mi:ss') instart_fmt
     , di.instance_name                                  inst_name
     , s.snap_id                                         snap_id
     , to_char(s.snap_time,'dd Mon YYYY HH24:mi')        snapdat
     , s.snap_level                                      lvl
     , substr(s.ucomment, 1,60)                          commnt
  from stats$snapshot s
     , stats$database_instance di
 where s.db_unique_name    = :db_unique_name
   and di.db_unique_name   = :db_unique_name
   and s.instance_name     = :inst_name
   and di.instance_name    = :inst_name
   and di.db_unique_name   = s.db_unique_name
   and di.instance_name    = s.instance_name
   and di.startup_time     = s.startup_time
   and s.snap_time        >= decode( to_number('&num_days')
                                   , to_number('3.14','9D99','nls_numeric_characters=''.,'''), s.snap_time
                                   , 0                                                       , to_date('31-JAN-9999','DD-MON-YYYY')
                                   , to_date(:max_snap_time,'dd/mm/yyyy') - (to_number('&num_days') - 1))
 order by di.db_unique_name, di.instance_name, snap_id;

clear break;
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
--  Ask for the Hash Value of the SQL statement to be reviewed

prompt
prompt
prompt Specify the old (i.e. pre-10g) Hash Value
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Hash Value specified is: &&hash_value
prompt


--
--  Set up the snapshot-related binds, and old_hash_value

variable bid        number;
variable eid        number;
variable old_hash_value number;
begin
  :bid        := &begin_snap;
  :eid        := &end_snap;
  :old_hash_value := &hash_value;
end;
/

prompt


--
--  Error reporting

whenever sqlerror exit;
declare

  cursor cspid(vspid stats$snapshot.snap_id%type) is
     select snap_time
          , startup_time
          , session_id
          , serial#
       from stats$snapshot
      where snap_id         = vspid
        and instance_name   = :inst_name
        and db_unique_name  = :db_unique_name;

  bsnapt  stats$snapshot.startup_time%type;
  bstart  stats$snapshot.startup_time%type;
  bsesid  stats$snapshot.session_id%type;
  bseria  stats$snapshot.serial#%type;
  esnapt  stats$snapshot.startup_time%type;
  estart  stats$snapshot.startup_time%type;
  esesid  stats$snapshot.session_id%type;
  eseria  stats$snapshot.serial#%type;

  cursor sqlhash is
     select old_hash_value
       from stats$sql_summary ss1
      where ss1.snap_id         = :eid
        and ss1.db_unique_name   = :db_unique_name
        and ss1.instance_name    = :inst_name
        and ss1.old_hash_value  = :old_hash_value;

  hv      stats$sql_summary.old_hash_value%type;

begin

  -- Check Begin Snapshot id is valid, get corresponding instance startup time
  open cspid(:bid);
  fetch cspid into bsnapt, bstart, bsesid, bseria;
  if cspid%notfound then
    raise_application_error(-20200,
      'Begin Snapshot Id '||:bid||' does not exist for this database/instance');
  end if;
  close cspid;

  -- Check End Snapshot id is valid and get corresponding instance startup time
  open cspid(:eid);
  fetch cspid into esnapt, estart, esesid, eseria;
  if cspid%notfound then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid||' does not exist for this database/instance');
  end if;
  if esnapt <= bsnapt then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid||' must be greater than Begin Snapshot Id '||:bid);
  end if;
  close cspid;

  -- Check startup time is same for begin and end snapshot ids
  if ( bstart != estart) then
    raise_application_error(-20200,
      'The instance was shutdown between snapshots '||:bid||' and '||:eid);
  end if;

  -- Check Hash Value specified exists in end snapshot
  open sqlhash;
  fetch sqlhash into hv;
   if sqlhash%notfound then
    raise_application_error(-20200,
      'Hash value ' || :old_hash_value || ' does not exist in end snapshot');
  end if;
  close sqlhash;

end;
/
whenever sqlerror continue;


--
--  Get the database info to display in the report

set termout off;
column para       new_value para;
column versn      new_value versn;
column host_name  new_value host_name;

select parallel       para
     , version        versn
     , host_name      host_name
  from stats$database_instance di
     , stats$snapshot          s
 where s.snap_id          = :bid
   and s.db_unique_name   = :db_unique_name
   and s.instance_name    = :inst_name
   and di.db_unique_name  = s.db_unique_name
   and di.instance_name   = s.instance_name
   and di.startup_time    = s.startup_time;

variable para       varchar2(9);
variable versn      varchar2(10);
variable host_name  varchar2(64);
begin
  :para      := '&para';
  :versn     := '&versn';
  :host_name := '&host_name';
end;
/
set termout on;


-- 
-- Get Text subset and module

set termout off;
column text_subset new_value text_subset noprint;
column module      new_value module      noprint;
select replace(text_subset, '''', '''''') text_subset
     , decode(module, null, ' '
                    , 'Module: ' || module) module
  from stats$sql_summary
 where snap_id          = :eid
   and db_unique_name   = :db_unique_name
   and instance_name    = :inst_name
   and old_hash_value   = :old_hash_value;
set termout on;


--
-- Use report name if specified, otherwise prompt user for output file 
-- name (specify default), then begin spooling

set termout off;
column dflt_name new_value dflt_name noprint;
select 'sb_'||:db_unique_name||'_'||:inst_name||'_'||:bid||'_'||:eid||'_'||:old_hash_value dflt_name from dual;
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
     , nvl('&&report_name','&dflt_name') report_name
  from sys.dual;
spool &report_name;
set heading on;
prompt


set heading off;
select 'WARNING: timed_statitics setting changed between begin/end snaps: TIMINGS ARE INVALID'
  from dual
 where not exists
      (select null
         from stats$parameter b
            , stats$parameter e
        where b.snap_id         = :bid
          and e.snap_id         = :eid
          and b.db_unique_name  = :db_unique_name
          and e.db_unique_name  = :db_unique_name
          and b.instance_name   = :inst_name
          and e.instance_name   = :inst_name
          and b.name            = e.name
          and b.name            = 'timed_statistics'
          and b.value           = e.value);

set heading on;


--
--  Get the package name  
set termout off;
column pkg_name new_value pkg_name noprint;
select 'STATSPACK_'||:db_unique_name||'_'||:inst_name pkg_name from dual;
set termout on;



--
--

set newpage 1 heading on;


--
--  Call statspack to calculate certain statistics
--

-- sprsqin.sql specific variables

variable text_subset varchar2(31);
variable module      varchar2(64);

set termout off heading off verify off;
variable lhtr   number;
variable bfwt   number;
variable tran   number;
variable chng   number;
variable ucal   number;
variable urol   number;
variable ucom   number;
variable rsiz   number;
variable phyr   number;
variable phyrd  number;
variable phyrdl number;
variable phyrc  number;
variable phyw   number;
variable prse   number;
variable hprs   number;
variable recr   number;
variable gets   number;
variable slr    number;
variable rlsr   number;
variable rent   number;
variable srtm   number;
variable srtd   number;
variable srtr   number;
variable strn   number;
variable call   number;
variable lhr    number;
variable bsp    varchar2(512);
variable esp    varchar2(512);
variable bbc    varchar2(512);
variable ebc    varchar2(512);
variable blb    varchar2(512);
variable elb    varchar2(512);
variable bs     varchar2(512);
variable twt    number;
variable logc   number;
variable prscpu number;
variable prsela number;
variable tcpu   number;
variable exe    number;
variable bspm   number;
variable espm   number;
variable bfrm   number;
variable efrm   number;
variable blog   number;
variable elog   number;
variable bocur  number;
variable eocur  number;
variable bpgaalloc number;
variable epgaalloc number;
variable bsgaalloc number;
variable esgaalloc number;
variable bnprocs   number;
variable enprocs   number;
variable timstat   varchar2(20);
variable statlvl   varchar2(40);
-- OS Stat
variable bncpu  number;
variable encpu  number;
variable bpmem  number;
variable epmem  number;
variable blod   number;
variable elod   number;
variable itic   number;
variable btic   number;
variable iotic  number;
variable rwtic  number;
variable utic   number;
variable stic   number;
variable vmib   number;
variable vmob   number;
variable oscpuw number;
-- OS Stat derived
variable ttic   number;
variable ttics  number;
variable cpubrat number;
variable cpuirat number;
-- Time Model
variable dbtim   number;
variable dbcpu   number;
variable bgela   number;
variable bgcpu   number;
variable prstela number;
variable sqleela number;
variable conmela number;
variable bncpu   number;
-- RAC variables
variable dmsd   number;
variable dmfc   number;
variable dmsi   number;
variable pmrv   number;
variable pmpt   number;
variable npmrv   number;
variable npmpt   number;
variable dbfr   number;
variable dpms   number;
variable dnpms   number;
variable glsg   number;
variable glag   number;
variable glgt   number;
variable gccrrv   number;
variable gccrrt   number;
variable gccrfl   number;
variable gccurv   number;
variable gccurt   number;
variable gccufl   number;
variable gccrsv   number;
variable gccrbt   number;
variable gccrft   number;
variable gccrst   number;
variable gccusv   number;
variable gccupt   number;
variable gccuft   number;
variable gccust   number;
variable msgsq    number;
variable msgsqt   number;
variable msgsqk   number;
variable msgsqtk  number;
variable msgrq    number;
variable msgrqt   number;

begin
  &&pkg_name..STAT_CHANGES
   ( :bid,    :eid
   , :db_unique_name,   :inst_name
   , :para                     -- End of IN arguments
   , :lhtr,   :bfwt
   , :tran,   :chng
   , :ucal,   :urol
   , :rsiz
   , :phyr,   :phyrd
   , :phyrdl, :phyrc
   , :phyw,   :ucom
   , :prse,   :hprs
   , :recr,   :gets
   , :slr
   , :rlsr,   :rent
   , :srtm,   :srtd
   , :srtr,   :strn
   , :lhr
   , :bbc,    :ebc
   , :bsp,    :esp
   , :blb
   , :bs,     :twt
   , :logc,   :prscpu
   , :tcpu,   :exe
   , :prsela
   , :bspm,   :espm
   , :bfrm,   :efrm
   , :blog,   :elog
   , :bocur,  :eocur
   , :bpgaalloc,   :epgaalloc
   , :bsgaalloc,   :esgaalloc
   , :bnprocs,     :enprocs
   , :timstat,     :statlvl
   , :bncpu,  :encpu           -- OS Stat
   , :bpmem,  :epmem
   , :blod,   :elod
   , :itic,   :btic
   , :iotic,  :rwtic
   , :utic,   :stic
   , :vmib,   :vmob
   , :oscpuw
   , :dbtim,  :dbcpu           -- Time Model
   , :bgela,  :bgcpu
   , :prstela,:sqleela
   , :conmela
   , :dmsd,   :dmfc            -- begin RAC
   , :dmsi
   , :pmrv,   :pmpt 
   , :npmrv,  :npmpt 
   , :dbfr
   , :dpms,   :dnpms 
   , :glsg,   :glag 
   , :glgt
   , :gccrrv, :gccrrt, :gccrfl 
   , :gccurv, :gccurt, :gccufl 
   , :gccrsv
   , :gccrbt, :gccrft 
   , :gccrst, :gccusv 
   , :gccupt, :gccuft 
   , :gccust
   , :msgsq,  :msgsqt
   , :msgsqk, :msgsqtk
   , :msgrq,  :msgrqt          -- end RAC
   );
   :call    := :ucal + :recr;
   -- total ticks (cs)
   :ttic    := :btic + :itic;
    -- total ticks (s)
   :ttics   := :ttic/100;
   -- Busy to total CPU  ratio
   :cpubrat := :btic / :ttic;
   :cpuirat := :itic / :ttic;

   -- SQL specific variables
   :module      := '&module';
   :text_subset := '&text_subset';

end;
/
set termout on


--
--  Summary Statistics
--

--
--  Print database, instance, parallel, release, host and snapshot
--  information
prompt  STANDBY STATSPACK SQL report for Old Hash Value: &&hash_value  &&module

column para           heading "RAC"      format a3  print;
column versn          heading "Release"  format a11  print;
column host_name      heading "Host"     format a16 print;
column nl newline;

set heading on 
select :db_unique_name db_unique_name
     , :inst_name      inst_name
     , :versn          versn
     , :para           para
     , :host_name      host_name
  from sys.dual;


--  Print snapshot information

column instart_fmt new_value INSTART_FMT noprint;
column instart    new_value instart noprint;
column session_id new_value SESSION noprint;
column ela        new_value ELA     noprint;
column btim       new_value btim    heading 'Start Time' format a19 just c;
column etim       new_value etim    heading 'End Time'   format a19 just c;
column bid                          heading 'Start Id'         format 99999990;
column eid                          heading '  End Id'         format 99999990;
column dur        heading 'Duration(mins)' format 999,990.00 just r;
column sess_id    new_value sess_id noprint;
column serial     new_value serial  noprint;
column bbgt       new_value bbgt noprint;
column ebgt       new_value ebgt noprint;
column bdrt       new_value bdrt noprint;
column edrt       new_value edrt noprint;
column bet        new_value bet  noprint;
column eet        new_value eet  noprint;
column bsmt       new_value bsmt noprint;
column esmt       new_value esmt noprint;
column bvc        new_value bvc  noprint;
column evc        new_value evc  noprint;
column blog       format 99,999;
column elog       format 99,999;
column ocs        format 99,999.0;
column nl         newline;

select b.snap_id                            bid
     , to_char(b.snap_time, 'dd-Mon-yy hh24:mi:ss')             btim
     , e.snap_id                                                eid
     , to_char(e.snap_time, 'dd-Mon-yy hh24:mi:ss')             etim
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)/60   dur  -- mins
     , to_char(b.startup_time, 'dd-Mon-yy hh24:mi:ss')          instart_fmt
     , b.session_id
     , round(((e.snap_time - b.snap_time) * 1440 * 60), 0)      ela  -- secs
     , to_char(b.startup_time,'YYYYMMDD HH24:MI:SS')            instart
     , e.session_id                                             sess_id
     , e.serial#                                                serial
     , b.buffer_gets_th                                         bbgt
     , e.buffer_gets_th                                         ebgt
     , b.disk_reads_th                                          bdrt
     , e.disk_reads_th                                          edrt
     , b.executions_th                                          bet
     , e.executions_th                                          eet
     , b.sharable_mem_th                                        bsmt
     , e.sharable_mem_th                                        esmt
     , b.version_count_th                                       bvc
     , e.version_count_th                                       evc
  from stats$snapshot b
     , stats$snapshot e
 where b.snap_id         = :bid
   and e.snap_id         = :eid
   and b.db_unique_name  = :db_unique_name
   and e.db_unique_name  = :db_unique_name
   and b.instance_name   = :inst_name
   and e.instance_name   = :inst_name
   and b.startup_time    = e.startup_time
   and b.snap_time       < e.snap_time;


variable btim    varchar2 (20);
variable etim    varchar2 (20);
variable ela     number;
variable instart varchar2 (18);
variable bbgt    number;
variable ebgt    number;
variable bdrt    number;
variable edrt    number;
variable bet     number;
variable eet     number;
variable bsmt    number;
variable esmt    number;
variable bvc     number;
variable evc     number;
begin
   :btim    := '&btim'; 
   :etim    := '&etim'; 
   :ela     := to_number('&ela');
   :instart := '&instart';
   :bbgt    := to_number('&bbgt');
   :ebgt    := to_number('&ebgt');
   :bdrt    := to_number('&bdrt');
   :edrt    := to_number('&edrt');
   :bet     := to_number('&bet');
   :eet     := to_number('&eet');
   :bsmt    := to_number('&bsmt');
   :esmt    := to_number('&esmt');
   :bvc     := to_number('&bvc');
   :evc     := to_number('&evc');
end;
/

--
--

--
--  SQL Reporting

col Gets      format 9,999,999,990  heading 'Buffer Gets';
col Reads     format 9,999,999,990  heading 'Physical|Reads';
col Rw        format 9,999,999,990  heading 'Rows | Processed';
col pc        format 9,999,999,999  heading 'Parse|Calls'
col cput      format 9,999,999,999  heading 'CPU Time'
col elat      format 9,999,999,999  heading 'Ela Time'
col Execs     format 9,999,999,990  heading 'Executes';
col shm       format 9,999,999,999  heading 'Sharable   |Memory (bytes)';
col vcount    format 9,999,999,999  heading 'Version|Count';
col sorts     format 9,999,999,999  heading 'Sorts'
col inv       format 9,999,999,999  heading 'Invali-|dations';

col GPX       format 9,999,999,990.0  heading 'Gets|per Exec'  just c;
col RPX       format 9,999,999,990.0  heading 'Reads|per Exec' just c;
col RWPX      format 9,999,999,990.0  heading 'Rows|per Exec'  just c;
col PPX       format 9,999,999,999.0  heading 'Parses|per Exec' just c;
col cpupx     format 9,999,999,999.0  heading 'CPU|per Exec'   just c;
col elapx     format 9,999,999,999.0  heading 'Ela|per Exec'   just c;
col spx       format 9,999,999,999.0  heading 'Sorts|per Exec' just c;

col ptg       format 999.99           heading '%Total|Gets';
col ptr       format 999.99           heading '%Total|Reads';

col hashval   format 99999999999    heading 'Hash Value';
col sql_text  format a500           heading 'SQL statement:'  wrap;
col rel_pct   format 999.9          heading '% of|Total';

--
-- Show SQL statistics

set heading off;

select 'SQL Statistics'                                     nl
     , '~~~~~~~~~~~~~~'                                     nl
     , '-> CPU and Elapsed Time are in seconds (s) for Statement Total and in' nl
     , '   milliseconds (ms) for Per Execute'       nl
     , '                                                       % Snap'  nl
     , '                     Statement Total      Per Execute   Total'  nl
     , '                     ---------------  ---------------  ------'  nl
     , '        Buffer Gets: '                              nl
     , e.buffer_gets - nvl(b.buffer_gets,0)                 gets
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.buffer_gets - nvl(b.buffer_gets,0))
              / (e.executions - nvl(b.executions,0)))       gpx
     , decode(:slr
             , 0, to_number(null)
             , 100*(e.buffer_gets - nvl(b.buffer_gets,0))
              /:slr)                                        ptg
     , '         Disk Reads: '                              nl
     , e.disk_reads - nvl(b.disk_reads,0)                   reads
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.disk_reads - nvl(b.disk_reads,0))
              / (e.executions - nvl(b.executions,0)))       rpx
     , decode(:phyr
             , 0, to_number(null)
             , 100*(e.disk_reads - nvl(b.disk_reads,0))
              /:phyr)                                       ptr
     , '     Rows processed: '                              nl
     , e.rows_processed - nvl(b.rows_processed,0)           rw
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.rows_processed - nvl(b.rows_processed,0))
              / (e.executions - nvl(b.executions,0)))       rwpx
     , '     CPU Time(s/ms): '                              nl 
     , (e.cpu_time - nvl(b.cpu_time,0))/1000000             cput
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  ((e.cpu_time - nvl(b.cpu_time,0))/1000)
              /  (e.executions - nvl(b.executions,0)))      cpupx
     , ' Elapsed Time(s/ms): '                              nl
     , (e.elapsed_time - nvl(b.elapsed_time,0))/1000000     elat
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  ((e.elapsed_time - nvl(b.elapsed_time,0))/1000)
              /  (e.executions - nvl(b.executions,0)))      elapx
     , '              Sorts: '                              nl
     , e.sorts - nvl(b.sorts,0)                             sorts
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.sorts - nvl(b.sorts,0))
              / (e.executions - nvl(b.executions,0)))       spx
     , '        Parse Calls: '                              nl
     , e.parse_calls - nvl(b.parse_calls,0)                 pc
     , decode(e.executions - nvl(b.executions,0)
             ,0, to_number(null)
             ,  (e.parse_calls - nvl(b.parse_calls,0))
              / (e.executions - nvl(b.executions,0)))       ppx
     , '      Invalidations: '                              nl
     , e.invalidations - nvl(b.invalidations,0)             inv
     , '      Version count: '                              nl
     , e.version_count                                      vcount
     , '    Sharable Mem(K): '                              nl
     , e.sharable_mem/1024                                  shm
     , '         Executions: '                              nl
     , e.executions - nvl(b.executions,0)                   execs
  from stats$sql_summary e
     , stats$sql_summary b
 where b.snap_id(+)         = :bid
   and b.db_unique_name(+)  = e.db_unique_name
   and b.instance_name(+)   = e.instance_name
   and b.old_hash_value(+)  = e.old_hash_value
   and b.address(+)         = e.address
   and b.text_subset(+)     = e.text_subset
   and e.snap_id            = :eid
   and e.db_unique_name     = :db_unique_name
   and e.instance_name      = :inst_name
   and e.old_hash_value     = :old_hash_value;



--
--  Show complete SQL Text

ttitle lef 'SQL Text' -
       skip 1 -
       lef '~~~~~~~~' -
       skip 1;

select st.sql_text
  from stats$sql_summary e
     , stats$sqltext    st
 where e.snap_id            = :eid
   and e.db_unique_name     = :db_unique_name
   and e.instance_name      = :inst_name
   and e.old_hash_value     = :old_hash_value
   and st.text_subset       = e.text_subset
   and st.old_hash_value    = e.old_hash_value
order by st.piece;

set heading on;



--
-- Show Plan Hash Values for all known Plans

ttitle lef 'Known Optimizer Plan(s) for this Old Hash Value' -
       skip 1 -
       lef '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       lef 'Shows all known Optimizer Plans for this database instance, and the Snap Id''s' -
       skip 1 -
       lef 'they were first found in the shared pool.  A Plan Hash Value will appear' -
       skip 1 -
       lef 'multiple times if the cost has changed' -
       skip 1 -
       lef '-> ordered by Snap Id' -
       skip 2;

column plan_hash_value format 99999999999 heading 'Plan|Hash Value' just c;
column snap_id         format 99999990    heading 'First|Snap Id' just c;
column cost            format a10         heading 'Cost' just r;
column optimizer                          heading 'Optimizer';
column snap_time       format a15         heading 'First|Snap Time' just c;
column last_act_time   format a15         heading 'Last|Active Time' just c;

select fsp.snap_id
     , to_char(s.snap_time, 'DD-Mon-YY HH24:MI') snap_time
     , to_char(fsp.last_active_time, 'DD-Mon-YY HH24:MI') last_act_time
     , fsp.plan_hash_value
     , lpad(decode(fsp.cost
                  , null, ' '
                  , -9,   ' '
                  , decode(  sign(cost-10000000)
                           , -1, cost||' '
                           , decode(  sign(cost-1000000000), -1, trunc(cost/1000000)||'M'
                                    , trunc(cost/1000000000)||'G'
                                   )
                          )
                  ), 10) cost
  from (select min(snap_id) snap_id
             , db_unique_name
             , instance_name
             , plan_hash_value
             , cost
             , max(last_active_time) last_active_time
          from stats$sql_plan_usage spu
         where old_hash_value  = :old_hash_value
           and text_subset     = :text_subset
           and db_unique_name  = :db_unique_name
           and instance_name   = :inst_name
         group by plan_hash_value, cost, db_unique_name, instance_name
       ) fsp
       , stats$snapshot s
 where s.snap_id(+)             = fsp.snap_id
   and s.db_unique_name(+)      = fsp.db_unique_name
   and s.instance_name(+)       = fsp.instance_name
 order by fsp.snap_id, fsp.plan_hash_value;


--
--  Show all known Plans used between Snap Ids specified

ttitle lef 'Plans in shared pool between Begin and End Snap Ids' -
       skip 1 -
       lef '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' -
       skip 1 -
       lef 'Shows the Execution Plans found in the shared pool between the begin and end' -
       skip 1 -
       lef 'snapshots specified.  The values for Rows, Bytes and Cost shown below are those' -
       skip 1 -
       lef 'which existed at the time the first-ever snapshot captured this plan - these' -
       skip 1 -
       lef 'values often change over time, and so may not be indicative of current values' -
       skip 1 -
       lef '-> Rows indicates Cardinality, PHV is Plan Hash Value' -
       skip 1 -
       lef '-> ordered by Plan Hash Value' -
       skip 2;

set heading off;

select '--------------------------------------------------------------------------------' from dual
union all
select '| Operation                      | PHV/Object Name     |  Rows | Bytes|   Cost |'  as "Optimizer Plan:" from dual
union all
select '--------------------------------------------------------------------------------' from dual
union all
select *
  from (select
       rpad('|'||substr(lpad(' ',1*(depth-1))||operation||
            decode(options, null,'',' '||options), 1, 32), 33, ' ')||'|'||
       rpad(decode(id, 0, '----- '||to_char(plan_hash_value)||' -----'
                     , substr(decode(substr(object_name, 1, 7), 'SYS_LE_', null, object_name)
                       ||' ',1, 20)), 21, ' ')||'|'||
       lpad(decode(cardinality,null,'  ',
                decode(sign(cardinality-1000), -1, cardinality||' ', 
                decode(sign(cardinality-1000000), -1, trunc(cardinality/1000)||'K', 
                decode(sign(cardinality-1000000000), -1, trunc(cardinality/1000000)||'M', 
                       trunc(cardinality/1000000000)||'G')))), 7, ' ') || '|' ||
       lpad(decode(bytes,null,' ',
                decode(sign(bytes-1024), -1, bytes||' ', 
                decode(sign(bytes-1048576), -1, trunc(bytes/1024)||'K', 
                decode(sign(bytes-1073741824), -1, trunc(bytes/1048576)||'M', 
                       trunc(bytes/1073741824)||'G')))), 6, ' ') || '|' ||
       lpad(decode(cost,null,' ',
                decode(sign(cost-10000000), -1, cost||' ', 
                decode(sign(cost-1000000000), -1, trunc(cost/1000000)||'M', 
                       trunc(cost/1000000000)||'G'))), 8, ' ') || '|' as "Explain plan"
          from stats$sql_plan
         where plan_hash_value in (select plan_hash_value
                                     from stats$sql_plan_usage spu
                                    where spu.snap_id   between :bid and :eid
                                      and spu.db_unique_name   = :db_unique_name
                                      and spu.instance_name    = :inst_name
                                      and spu.old_hash_value  = :old_hash_value
                                      and text_subset         = :text_subset
                                      and spu.plan_hash_value > 0
                                  )
          order by plan_hash_value, id
)
union all
select '--------------------------------------------------------------------------------' from dual;

set heading on;


--
--

prompt
prompt                                 End of Report 
prompt
spool off;
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;
undefine begin_snap
undefine end_snap
undefine db_unique_name
undefine inst_name
undefine num_days
undefine report_name
undefine hash_value
whenever sqlerror continue;

--
--  End of script file;
