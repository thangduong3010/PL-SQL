Rem
Rem $Header: sppurge.sql 10-apr-2006.12:55:21 cdgreen Exp $
Rem
Rem sppurge.sql
Rem
Rem Copyright (c) 2000, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sppurge.sql - STATSPACK Purge
Rem
Rem    DESCRIPTION
Rem      Purge a range of Snapshot Id's between the specified
Rem      begin and end Snap Id's
Rem
Rem    NOTES
Rem      Should be run as STATSPACK user, PERFSTAT.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdgreen     04/10/06 - 1798853
Rem    cdialeri    02/25/03 - 10i F2 - moved purge to STATSPACK package
Rem    vbarrier    03/20/02 - Optional stats$seg_stat_obj purge
Rem    cdialeri    04/12/01 - 9.0
Rem    cdialeri    04/11/00 - 1261813
Rem    cdialeri    03/15/00 - Conform to new structure
Rem    densor.uk   05/00/94 - Allow purge of range of snaps
Rem    gwood.uk    10/12/92 - Use RI for deletes to most tables
Rem    cellis.uk   11/15/89 - Created
Rem

set feedback off verify off pages 999
whenever sqlerror exit rollback

spool sppurge.lis


/* ------------------------------------------------------------------------- */

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

prompt
prompt
prompt Database Instance currently connected to
prompt ========================================

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance|Name"  new_value inst_name format a10;
column db_name   heading "DB Name"   new_value db_name   format a10;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;
select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

variable dbid       number;
variable inst_num   number;
variable inst_name  varchar2(20);
variable db_name    varchar2(20);
begin 
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num; 
  :inst_name := '&inst_name';
  :db_name   := '&db_name';
end;
/


--
--  List Snapshots

column snap_id       format 9999990 heading 'Snap Id'
column snap_date     format a21	  heading 'Snapshot Started' just c
column host_name     format a15   heading 'Host' trunc
column parallel      format a3    heading 'OPS' trunc
column level         format 99    heading 'Snap|Level'
column versn         format a7    heading 'Release'
column ucomment          heading 'Comment' format a20;
column baseline      format a5    heading 'Base-|line?'

prompt
prompt
prompt Snapshots for this database instance
prompt ====================================

select s.snap_id
     , to_char(s.snap_time,' dd Mon YYYY HH24:mi:ss')    snap_date
     , s.baseline
     , s.snap_level                                      "level"
     , di.host_name                                      host_name
     , s.ucomment
  from stats$snapshot s
     , stats$database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and s.instance_number   = :inst_num
   and di.instance_number  = :inst_num
   and di.startup_time     = s.startup_time
 order by db_name, instance_name, snap_id;


--
--  Post warning

prompt
prompt
prompt Warning
prompt ~~~~~~~
prompt sppurge.sql deletes all snapshots ranging between the lower and
prompt upper bound Snapshot Id's specified, for the database instance
prompt you are connected to.  Snapshots identified as Baseline snapshots
prompt which lie within the snapshot range will not be purged.
prompt
prompt It is NOT possible to rollback changes once the purge begins.
prompt
prompt You may wish to export this data before continuing.
prompt


--
--  Obtain snapshot ranges

prompt
prompt Specify the Lo Snap Id and Hi Snap Id range to purge
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Using &&LoSnapId for lower bound.
prompt
prompt Using &&HiSnapId for upper bound.


--
--  Delete all data for the specified ranges

prompt
prompt Deleting snapshots &&losnapid - &&hisnapid..

variable lo_snap   number;
variable hi_snap   number;
variable snapshots_purged number;
begin
  :lo_snap :=  &&losnapid;
  :hi_snap :=  &&hisnapid; 
  :snapshots_purged := statspack.purge( i_begin_snap      => :lo_snap
                                      , i_end_snap        => :hi_snap
                                      , i_snap_range      => true
                                      , i_extended_purge  => false
                                      , i_dbid            => :dbid
                                      , i_instance_number => :inst_num);

end;
/


--
--

set heading off
select 'Number of Snapshots purged: ' || :snapshots_purged 
     , '~~~~~~~~~~~~~~~~~~~~~~~~~~~' newline
  from sys.dual;
set heading on

prompt Purge of specified Snapshot range complete.
prompt
prompt

--
--

spool off
undefine dbid inst_num losnapid hisnapid
set feedback on termout on
whenever sqlerror continue
