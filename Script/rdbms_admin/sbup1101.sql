Rem
Rem $Header: rdbms/admin/sbup1101.sql /st_rdbms_11.2.0/1 2011/11/10 09:32:11 kchou Exp $
Rem
Rem sbup1101.sql
Rem
Rem Copyright (c) 2009, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbup1101.sql - Standby StatsPack UPgrade 11.1
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 11.2 schema
Rem
Rem    NOTES
Rem      Please upgrade the primary statspack to 11.2 schema 
Rem      before running this script. 
Rem
Rem      Export the Standby Statspack schema before running this upgrade,
Rem      as this is the only way to restore the existing data.
Rem      A downgrade script is not provided.
Rem
Rem      Disable any scripts which use Standby Statspack while the upgrade 
Rem      script is running.
Rem
Rem      Ensure there is plenty of free space in the tablespace
Rem      where the schema resides.
Rem
Rem      This script should be run when connected as SYSDBA.
Rem
Rem      This upgrade script should only be run once.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       11/09/11 - Backport Bug#9695145 Missing Idle Events to
Rem                           Standby Statspack - RFI 10431923 Release 11.2.0.4
Rem    kchou       11/09/11 - Backport kchou_bug-9695145 from main
Rem    shsong      02/05/09 - 11.1 upgrade script
Rem    shsong      02/05/09 - Created
Rem
prompt
prompt Standby Statspack Upgrade script
prompt ~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt Warning
prompt ~~~~~~~
prompt You MUST upgrade Primany Statspack to 11.2 schema before upgrading 
prompt the Standby Statspack. 
prompt
prompt Converting existing Standby Statspack data to 11.2 format may result in
prompt irregularities when reporting on pre-11.2 snapshot data.
prompt
prompt This script is provided for convenience, and is not guaranteed to
prompt work on all installations.  To ensure you will not lose any existing
prompt Statspack data, export the schema before upgrading.  A downgrade
prompt script is not provided.  
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
prompt -> You will be prompted for the STDBYPERF password, and for the
prompt    tablespace to create any new STDBYPERF tables/indexes.
prompt
accept confirmation prompt "Press return before continuing ";

prompt
prompt Please specify the STDBYPERF password
prompt &&stdbyuser_password  

prompt
prompt Specify the tablespace to create any new SDTBYPERF tables and indexes
prompt Tablespace specified &&tablespace_name
prompt

connect stdbyperf/&&stdbyuser_password
spool sbup1101.lis

show user

set verify off
set serveroutput on size 4000

prompt
prompt
prompt Enter the TNS ALIAS that connects to the standby database instance
prompt ------------------------------------------------------------------

prompt Make sure the alias connects to only one instance (without load balancing).
prompt You entered: &&tns_alias

column inst_name heading "Instance"  new_value inst_name format a12;

prompt
prompt ... Selecting instance name 

select i.instance_name   inst_name
from v$instance@stdby_link_&&tns_alias i;

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
prompt in the file sbcpkg.lis

spool off

/* ------------------------------------------------------------------------- */

--
-- Upgrade the package
@@sbcpkg

undefine tns_alias inst_name stdbyuser_password
--  End of Upgrade script



