rem 
rem $Header: utlbstat.sql 02-jan-2001.19:39:51 cdialeri Exp $ bstat.sql 
rem 
Rem Copyright (c) 1988, 1996, 2000 by Oracle Corporation
Rem NAME
REM    UTLBSTAT.SQL
Rem  FUNCTION
Rem  NOTES
Rem  MODIFIED
Rem     cdialeri   01/02/01  - 1566460: connect /
Rem     mchien     03/22/00 -  desupport connect internal
Rem     khailey    03/15/99 -  add current user fields to stats$date, bug 594266
Rem     jloaiza    10/14/95 -  add tablespace size
Rem     jloaiza    09/19/95 -  add waitstat
Rem     jloaiza    09/04/95 -  add per second and background waits
Rem     drady      09/09/93 -  merge changes from branch 1.1.312.2
Rem     drady      03/22/93 -  merge changes from branch 1.1.312.1 
Rem     drady      08/24/93 -  bug 173918
Rem     drady      03/04/93 -  fix bug 152986 
Rem     glumpkin   11/16/92 -  Renamed from UTLSTATB.SQL 
Rem     glumpkin   10/19/92 -  Renamed from BSTAT.SQL 
Rem     jloaiza    01/07/92 -  rework for version 7
Rem     mroberts   08/16/91 -         fix view for v7 
Rem     rlim       04/29/91 -         change char to varchar2 
Rem   Laursen    01/01/91 - V6 to V7 merge
Rem   Loaiza     04/04/89 - fix run dates to minutes instead of months
Rem   Martin     02/22/89 - Creation
Rem   Jloaiza    02/23/89 - changed table names, added dates, added param dump
Rem
set echo on;
connect / as sysdba;

Rem ********************************************************************
Rem                 First create all the tables
Rem ********************************************************************

drop table stats$begin_stats;
create table stats$begin_stats as select * from v$sysstat where 0 = 1;
drop table stats$end_stats;
create table stats$end_stats as select * from stats$begin_stats;

drop table stats$begin_latch;
create table stats$begin_latch as select * from v$latch where 0 = 1;
drop table stats$end_latch;
create table stats$end_latch as select * from stats$begin_latch;

drop table stats$begin_roll;
create table stats$begin_roll as select * from v$rollstat where 0 = 1;
drop table stats$end_roll;
create table stats$end_roll as select * from stats$begin_roll;

drop table stats$begin_lib;
create table stats$begin_lib as select * from v$librarycache where 0 = 1;
drop table stats$end_lib;
create table stats$end_lib as select * from stats$begin_lib;

drop table stats$begin_dc;
create table stats$begin_dc as select * from v$rowcache where 0 = 1;
drop table stats$end_dc;
create table stats$end_dc as select * from stats$begin_dc;

drop table stats$begin_event;
create table stats$begin_event as select * from v$system_event where 0 = 1;
drop table stats$end_event;
create table stats$end_event as select * from stats$begin_event;

drop table stats$begin_bck_event;
create table stats$begin_bck_event 
  (event varchar2(200), total_waits number, time_waited number);
drop table stats$end_bck_event;
create table stats$end_bck_event as select * from stats$begin_bck_event;

drop table stats$dates;
create table stats$dates (
	start_time date, 
	end_time date,
	start_users number,
	end_users number
	);

drop view stats$file_view;
create view stats$file_view as
  select ts.name    ts,
         i.name     name,
         x.phyrds pyr,
         x.phywrts pyw,
         x.readtim prt,
         x.writetim pwt,
         x.phyblkrd pbr,
         x.phyblkwrt pbw,
         round(i.bytes/1000000) megabytes_size
  from v$filestat x, ts$ ts, v$datafile i,file$ f
 where i.file#=f.file#
   and ts.ts#=f.ts#
   and x.file#=f.file#;

drop table stats$begin_file;
create table stats$begin_file as select * from stats$file_view where 0 = 1;
drop table stats$end_file;
create table stats$end_file as select * from stats$begin_file;

drop table stats$begin_waitstat;
create table stats$begin_waitstat as select * from v$waitstat where 1=0;
drop table stats$end_waitstat;
create table stats$end_waitstat as select * from stats$begin_waitstat;


Rem ********************************************************************
Rem                    Gather start statistics
Rem ********************************************************************

insert into stats$dates(start_time) select sysdate from dual;

insert into stats$begin_waitstat select * from v$waitstat;

insert into stats$begin_bck_event 
  select event, sum(total_waits), sum(time_waited)
    from v$session s, v$session_event e
    where type = 'BACKGROUND' and s.sid = e.sid
    group by event;

insert into stats$begin_event select * from v$system_event;

insert into stats$begin_roll select * from v$rollstat;

insert into stats$begin_file select * from stats$file_view;

insert into stats$begin_dc select * from v$rowcache;

insert into stats$begin_stats select * from v$sysstat;

insert into stats$begin_lib select * from v$librarycache;

insert into stats$begin_latch select * from v$latch;

commit;
