Rem
Rem $Header: rdbms/admin/sbup11201.sql /st_rdbms_11.2.0/1 2010/08/13 10:06:01 kchou Exp $
Rem
Rem sbup11201.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      sbup11201.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 11.2.0.2 schema
Rem
Rem    NOTES
Rem      Please upgrade the primary statspack to 11.2.0.1 schema 
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
Rem       kchou    08/11/10 - Bug#9800868 - Add Missing Idle Events for
Rem                           11.2.0.2for Statspack & Standby Statspack
Rem       kchou    08/11/10 - Bug#9800868 - Add missing idle events to 11.2.0.2
Rem       kchou    08/11/10 - 11.2.0.2 Upgrade Script Creation
Rem       shsong   02/05/09 - 11.1 upgrade script
Rem       shsong   02/05/09 - Created
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
spool sbup11201.lis

show user

set verify off
set serveroutput on size 4000

/* ------------------------------------------------------------------------- */

--
-- Add any new idle events, and Statspack Levels  
-- 8/10/2010  KCHOU  11.2.0.2 MISSING IDLE EVENTS
--
/*------------------------------------------------------------*/
/* 8/11/2010 Bug#9800868 Add Missing Idle Events for 11.2.0.2 */
/*------------------------------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('GCR sleep');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: branch');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: idle');
insert into STATS$IDLE_EVENT (event) values ('LogMiner client: transaction');
insert into STATS$IDLE_EVENT (event) values ('LogMiner preparer: idle');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery control message reply');

commit;

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
