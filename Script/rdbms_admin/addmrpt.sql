Rem
Rem $Header: addmrpt.sql 13-oct-2003.14:01:18 pbelknap Exp $
Rem
Rem addmrpt.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      addmrpt.sql - SQL*Plus script to run ADDM analysis on a pair on AWR
Rem                    snapshots and to display the textual ADDM report
Rem                    of the analysis.
Rem
Rem    DESCRIPTION
Rem      This SQL*Plus script can be used only to run ADDM on snapshots
Rem      taken by the current instance. If you want to run ADDM on snapshots from
Rem      other instances in a RAC environment or snapshots imported from
Rem      other databases, please use the addmrpti.sql script.
Rem
Rem    NOTES
Rem      Assumes the current database's dbid and instance_number,
Rem      Assumes num_days to be 3
Rem      Displays the snapshots taken in the past &num_days,
Rem      Prompts for a pair of AWR snapshots,
Rem      Runs ADDM across those snapshots and
Rem      Displays and spools the textual ADDM report of the analysis.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      do something similar to the following:
Rem
Rem      define  dbid         = 1234567890;
Rem      define  inst_num     = 1;
Rem      define  num_days     = 3;
Rem      define  report_name  = /tmp/addm_report_10_11.txt
Rem      define  begin_snap   = 10;
Rem      define  end_snap     = 11;
Rem      @@?/rdbms/admin/addmrpti
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    10/13/03 - remove hard tabs
Rem    veeve       10/13/03 - more cleanup
Rem    pbelknap    10/09/03 - moving parameters to addmrpt, set default vals 
Rem    veeve       10/02/03 - created addmrpti.sql and moved contents to it.
Rem    veeve       10/01/03 - use swrfinput.sql
Rem    veeve       09/06/03 - veeve_addm_production_1
Rem    veeve       09/04/03 - created addmrpt.sql
Rem

--
-- Customer configurable variables

--
-- Specify the number of days of snapshots to choose from:
define num_days = 3;

-- 
-- Optionally specify a report_name
-- define report_name = /tmp/addm_report.txt

--
-- End of customer configurable variables


--
-- Get the current database/instance information - this will be used
-- later in the report along with bid, eid to lookup snapshots

set heading on echo off feedback off verify off underline on timing off;

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

@@addmrpti

--
-- Reset SQL*Plus settings to defaults
set heading on echo off feedback 6 verify on underline on timing off;

--
-- Undefine SQL*Plus variables defined in this file
undefine   num_days
undefine   report_name
undefine   inst_num
undefine   inst_name
undefine   db_name
undefine   dbid

--
-- End of file

