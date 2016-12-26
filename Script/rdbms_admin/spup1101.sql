Rem
Rem $Header: rdbms/admin/spup1101.sql /main/2 2009/05/14 13:56:01 cgervasi Exp $
Rem
Rem spup1101.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      spup1101.sql - StatsPack UPgrade 11.1
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 11.2 schema
Rem
Rem    NOTES
Rem      Export the Statspack schema before running this upgrade,
Rem      as this is the only way to restore the existing data.
Rem      A downgrade script is not provided.
Rem
Rem      Disable any scripts which use Statspack while the upgrade script
Rem      is running.
Rem
Rem      Ensure there is plenty of free space in the tablespace
Rem      where the schema resides.
Rem
Rem      This script should be run when connected as SYSDBA
Rem
Rem      This upgrade script should only be run once.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cgervasi    05/13/09 - add idle event: cell worker idle
Rem    cgervasi    04/02/09 - bug8395154: missing idle events
Rem    shsong      02/05/09 - 11.1 upgrade script
Rem    shsong      02/05/09 - Created
Rem


prompt
prompt Statspack Upgrade script
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Warning
prompt ~~~~~~~
prompt Converting existing Statspack data to 11.2 format may result in
prompt irregularities when reporting on pre-11.2 snapshot data.
prompt
prompt This script is provided for convenience, and is not guaranteed to
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  Please see spdoc.txt for more details.
prompt
accept confirmation prompt "Press return before continuing ";
prompt
prompt Usage
prompt ~~~~~
prompt -> Disable any programs which run Statspack (including any dbms_jobs),
prompt    before continuing, or this upgrade will fail.
prompt
prompt -> You MUST be connected as a user with SYSDBA privilege to successfully
prompt    run this script.
prompt
prompt -> You will be prompted for the PERFSTAT password, and for the
prompt    tablespace to create any new PERFSTAT tables/indexes.
prompt
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the PERFSTAT password
prompt &&perfstat_password

spool spup1101a.lis

/* ------------------------------------------------------------------------- */
--
-- Create SYS views, public synonyms, issue grants 

create or replace view STATS$V_$FILESTATXS as
select ts.tsnam                    tsname
     , fn.fnnam                    filename
     , fio.kcfiopyr                phyrds
     , fio.kcfiopyw                phywrts
     , round(fio.kcfioprt/10000)   readtim
     , round(fio.kcfiopwt/10000)   writetim
     , fio.kcfiosbr                singleblkrds
     , fio.kcfiopbr                phyblkrd
     , fio.kcfiopbw                phyblkwrt
     , round(fio.kcfiosbt/10000)   singleblkrdtim
     , fw.count                    wait_count
     , fw.time                     time
     , fn.fnfno                    file#
  from x$kcbfwait   fw
     , x$kcfio      fio
     , x$kccfe      fe
     , x$kccts      ts
     , x$kccfn      fn
 where ts.tstsn      = fe.fetsn
   and fio.kcfiofno  = fn.fnfno
   and fw.indx+1     = fn.fnfno
   and fe.fenum      = fn.fnfno
   and fe.fefnh      = fn.fnnum
   and fe.fedup      <> 0
   and fn.fntyp      = 4
   and fn.fnnam is not null
   and bitand(fn.fnflg, 4) != 4;

create or replace view STATS$V_$TEMPSTATXS as
select ts.tsnam                      tsname
     , fn.fnnam                      filename
     , ftio.kcftiopyr                phyrds
     , ftio.kcftiopyw                phywrts
     , round(ftio.kcftioprt/10000)   readtim
     , round(ftio.kcftiopwt/10000)   writetim
     , ftio.kcftiosbr                singleblkrds
     , ftio.kcftiopbr                phyblkrd
     , ftio.kcftiopbw                phyblkwrt
     , round(ftio.kcftiosbt/10000)   singleblkrdtim
     , fw.count                      wait_count
     , fw.time                       time
     , fn.fnfno                      file#
  from x$kcbfwait   fw
     , x$kcftio     ftio
     , x$kccts      ts
     , x$kcctf      tf
     , x$kccfn      fn
 where ts.tstsn       = tf.tftsn
   and ftio.kcftiofno = fn.fnfno
   and tf.tfnum       = fn.fnfno
   and tf.tffnh       = fn.fnnum
   and tf.tfdup       <> 0
   and fn.fntyp       = 7
   and fn.fnnam is not null
   and bitand(tf.tfsta, 32) <> 32
   and fw.indx+1  = (fn.fnfno + (select value from v$parameter where name='db_files'));


/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup1101b.lis

spool off
connect perfstat/&&perfstat_password

spool spup1101b.lis

show user
set verify off
set serveroutput on size 4000

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels

insert into STATS$IDLE_EVENT (event) values ('JOX Jit Process Sleep');
insert into STATS$IDLE_EVENT (event) values ('HS message to agent');
insert into STATS$IDLE_EVENT (event) values ('JS external job');
insert into STATS$IDLE_EVENT (event) values ('LGWR real time apply sync');
insert into STATS$IDLE_EVENT (event) values ('LogMiner reader: log (idle)');
insert into STATS$IDLE_EVENT (event) values ('LogMiner reader: redo (idle)');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: activate');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: find session');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: internal');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: other');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: reset');
insert into STATS$IDLE_EVENT (event) values ('Logical Standby Apply Delay');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Close');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Execute');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Join ACK');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Metadata Update');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Msg Fragment');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Parse Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Txn Recovery Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Txn Recovery Start');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: kdcph_mai');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: kdcphc_ack');
insert into STATS$IDLE_EVENT (event) values ('SGA: MMAN sleep for component shrink');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net vector message from client');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net vector message from dblink');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: emn coordinator idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams: waiting for messages');
insert into STATS$IDLE_EVENT (event) values ('VKRM Idle');
insert into STATS$IDLE_EVENT (event) values ('VKTM Init Wait for GSGA');
insert into STATS$IDLE_EVENT (event) values ('VKTM Logical Idle Wait');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay client notify');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay clock');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay paused');
insert into STATS$IDLE_EVENT (event) values ('auto-sqltune: wait graph update');
insert into STATS$IDLE_EVENT (event) values ('heartbeat monitor sleep');
insert into STATS$IDLE_EVENT (event) values ('shared server idle wait');
insert into STATS$IDLE_EVENT (event) values ('simulated log write delay');
insert into STATS$IDLE_EVENT (event) values ('single-task message');
insert into STATS$IDLE_EVENT (event) values ('wait for unread message on multiple broadcast channels');
insert into STATS$IDLE_EVENT (event) values ('cell worker idle');


commit;

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check the log file of the package recreation, which is
prompt in the file spcpkg.lis

spool off

/* ------------------------------------------------------------------------- */

--
-- Upgrade the package
@@spcpkg

--  End of Upgrade script
