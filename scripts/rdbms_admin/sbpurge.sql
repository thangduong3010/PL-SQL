Rem
Rem sbpurge.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbpurge.sql - StandBy statspack PURGE
Rem
Rem    DESCRIPTION
Rem      Purge a range of Snapshot Id's between the specified
Rem      begin and end Snap Id's
Rem
Rem    NOTES
Rem      Should be run as standby statspack user, stdbyperf
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      01/20/10 - use db_unique_name as primary key
Rem    shsong      04/24/07 - fix bug
Rem    wlohwass    12/13/06 - Created
Rem

set feedback off verify off pages 999
whenever sqlerror exit rollback

spool sbpurge.lis


/* ------------------------------------------------------------------------- */


--
-- Request the DB Unique Name and Instance Name, if they are not specified

column dbb_unique_name heading "DB Unique Name" format a30;
column instt_name      heading "Instance Name"  format a16;
column host            heading "Host"           format a12;

prompt
prompt 
prompt Instances in this Statspack schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct dins.db_unique_name  dbb_unique_name
     , dins.instance_name            instt_name
     , host_name                     host
  from stats$database_instance dins
 where exists (select * from stats$standby_config scon
                where dins.instance_name  = scon.inst_name
                  and dins.db_unique_name = scon.db_unique_name);

prompt 
prompt Using &&db_unique_name for database unique name
prompt Using &&inst_name for instance name

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
--  Get the package name  
set termout off;
column pkg_name new_value pkg_name noprint;
select 'STATSPACK_'||:db_unique_name||'_'||:inst_name pkg_name from dual;
set termout on;



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
 where s.db_unique_name    = :db_unique_name
   and di.db_unique_name   = :db_unique_name
   and s.instance_name     = :inst_name
   and di.instance_name    = :inst_name
   and di.startup_time     = s.startup_time
 order by s.db_unique_name, s.instance_name, snap_id;


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
  :snapshots_purged := &&pkg_name..purge( 
                                        i_begin_snap      => :lo_snap
                                      , i_end_snap        => :hi_snap
                                      , i_snap_range      => true
                                      , i_extended_purge  => false
                                      , i_db_unique_name  => :db_unique_name
                                      , i_instance_name   => :inst_name);
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
undefine db_unique_name inst_name losnapid hisnapid pkg_name
set feedback on termout on
whenever sqlerror continue
