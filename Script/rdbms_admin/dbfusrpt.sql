Rem
Rem $Header: dbfusrpt.sql 25-may-2005.17:05:32 mlfeng Exp $
Rem
Rem dbfusrpt.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbfusrpt.sql - DB Feature Usage Report
Rem
Rem    DESCRIPTION
Rem      This script generates a DB Feature Usage report
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem      This script defaults the dbid and version to the local database.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/25/05 - mlfeng_track_cpu
Rem    mlfeng      05/10/05 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on;
column version   heading "Version"   new_value version   format a13;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Database
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.version         version
  from v$database d,
       v$instance i;

@@dbfusrpi

undefine report_type;
undefine report_name;
--
-- End of file


