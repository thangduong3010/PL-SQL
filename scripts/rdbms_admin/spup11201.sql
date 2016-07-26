Rem
Rem $Header: rdbms/admin/spup11201.sql /st_rdbms_11.2.0/1 2010/08/13 10:06:01 kchou Exp $
Rem
Rem spup11201.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      spup11201.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Upgrades the Statspack schema to the 11.2.0.2 schema
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
Rem      kchou       08/11/10 - Bug#9800868 - Add Missing Idle Events for
Rem                             11.2.0.2for Statspack & Standby Statspack
Rem      kchou       08/11/10 - Bug#9800868 - Add missing idle events to
Rem                             11.2.0.2
Rem      kchou       08/11/10 - 11.2.0.2 Upgrade Script Creation
Rem      cgervasi    05/13/09 - add idle event: cell worker idle
Rem      cgervasi    04/02/09 - bug8395154: missing idle events
Rem      shsong      02/05/09 - 11.1 upgrade script
Rem      shsong      02/05/09 - Created
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

spool spup11201a.lis

/* ------------------------------------------------------------------------- */

prompt Note:
prompt Please check remainder of upgrade log file, which is continued in
prompt the file spup11201b.lis

spool off
connect perfstat/&&perfstat_password

spool spup11201b.lis

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
