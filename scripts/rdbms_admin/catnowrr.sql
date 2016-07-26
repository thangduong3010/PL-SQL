Rem
Rem $Header: catnowrr.sql 13-jul-2006.18:35:20 veeve Exp $
Rem
Rem catnowrr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnowrr.sql - Catalog script to delete the 
Rem                     Workload Capture and Replay schema
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    veeve       07/13/06 - stop capture/replay first
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - added catnowrrp.sql
Rem    veeve       01/25/06 - Created
Rem

Rem =========================================================
Rem Stop any Capture that is in progress
Rem =========================================================
begin
  dbms_workload_capture.finish_capture;
end;
/

Rem =========================================================
Rem Stop any REPLAY that is in progress
Rem =========================================================
begin
  dbms_workload_replay.cancel_replay;
end;
/

Rem
Rem Drop the common (shared by Capture and Replay) schema 
Rem and the Capture infrastructure tables 
@@catnowrrc.sql

Rem
Rem Drop the Replay infrastructure tables 
@@catnowrrp.sql

Rem =========================================================
Rem Dropping the common infra-structure tables
Rem =========================================================
Rem

drop table WRR$_FILTERS
/
