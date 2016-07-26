Rem
Rem $Header: dbfusrpi.sql 25-may-2005.17:05:32 mlfeng Exp $
Rem
Rem dbfusrpi.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbfusrpi.sql - DB Feature Usage report internal
Rem
Rem    DESCRIPTION
Rem      Generates a DB Feature Usage report for (dbid, version)
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem      Generally this script should be invoked by dbfusrpt, unless
Rem      you want to pick a database version other than the default.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      without executing the script through dbfusrpt, then
Rem      do something similar to the following:
Rem
Rem      define  dbid         = 4;
Rem      define  version      = '10.2.0.0.0';
Rem      define  report_type  = 'text';
Rem      define  report_name  = /tmp/dbfus_report_10_11.txt
Rem      @@?/rdbms/admin/dbfusrpi.sql
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/25/05 - mlfeng_track_cpu
Rem    mlfeng      05/10/05 - Created
Rem

set echo off;

-- ***************************************************
--   Customer-customizable report settings
--   Change these variables to run a report on different statistics
-- ***************************************************
-- Hardcode the Database ID you want to run the report on.
--   define dbid = 4000;
--
-- Hardcode the Database ID you want to run the report on.
--   define version = '10.2.0.0.0';
--
-- Reports can be printed in text or html, and you must set the report_type
-- in addition to the report_name
--
-- Issue Report in Text Format
--   define report_type='text';
--
-- Issue Report in HTML Format
--   define report_type='html';

-- Optionally, set the name for the report itself
--   define report_name = 'dbfus_4.html'

-- ***************************************************
--   End customer-customizable settings
-- ***************************************************

set veri off;
set feedback off;

/* no options for this report */
variable rpt_options number;
begin
  :rpt_options := 0;
end;
/

--
-- Find out if we are going to print report to html or to text
prompt
prompt Specify the Report Type
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt Would you like an HTML report, or a plain text report?
prompt Enter 'html' for an HTML report, or 'text' for plain text
prompt  Defaults to 'html'

column report_type new_value report_type;
set heading off;
select 'Type Specified: ',lower(nvl('&&report_type','html')) report_type from dual;
set heading on;

set termout off;
-- Set the extension based on the report_type
column ext new_value ext;
select '.html' ext from dual where lower('&&report_type') <> 'text';
select '.txt' ext from dual where lower('&&report_type') = 'text';
set termout on;

-- Get the common input!
clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

--
-- Request the DB Id and Version, if they are not specified
column dbbid      heading "DB Id"     format a12 just c;
column dbb_name   heading "DB Name"   format a12;
column vversion   heading "Version"   format a13;

prompt
prompt
prompt Data in this DB Feature Usage schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct
       (case when cd.dbid    = fu.dbid    and 
                  ci.version = fu.version and
                  cd.name    = fu.db_name
             then '* '
             else '  '
        end) || fu.dbid   dbbid
     , fu.version         vversion
     , fu.db_name         dbb_name
  from (select distinct f.dbid, di.db_name, f.version 
          from dba_feature_usage_statistics f, 
               dba_hist_database_instance di
         where f.dbid = di.dbid 
           and f.version = di.version
       ) fu, v$database cd, v$instance ci;

prompt
prompt Using &&dbid for database Id
prompt Using &&version for version


--
--  Set up the binds for dbid and instance_number

variable dbid       number;
variable version    varchar2(17);
begin
  :dbid      :=  &dbid;
  :version   :=  '&version';
end;
/

--
--  Error reporting

whenever sqlerror exit;
variable max_snap_time char(10);
declare

  CURSOR is_valid_dbfus IS
     select 'x' 
      from dba_feature_usage_statistics
      where dbid    = :dbid
        and version = :version;

  vx     char(1);

begin

  /* confirm that the (dbid, version) exists in the DBFUS view */
  OPEN is_valid_dbfus;
  FETCH is_valid_dbfus INTO vx;
  IF (is_valid_dbfus%NOTFOUND) THEN
    raise_application_error(-20600, 
                            'Database/Version ' || :dbid || '/' ||
                            :version ||  ' does not exist in ' ||
                            'DBA_FEATURE_USAGE_STATISTICS');
  END IF;
  CLOSE is_valid_dbfus;

end;
/
whenever sqlerror continue;

-- Undefine substitution variables
undefine dbid
undefine version
undefine dbname

clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

--
-- Use report name if specified, otherwise prompt user for output file
-- name (specify default), then begin spooling
--
set termout off;
column dflt_name new_value dflt_name noprint;
select 'dbfus_'||:dbid||'&&ext' dflt_name from dual;
set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name..  To use this name,
prompt press <return> to continue, otherwise enter an alternative.
prompt

set heading off;
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , nvl('&&report_name','&dflt_name') report_name
  from sys.dual;

set heading off;
set pagesize 50000;
set echo off;
set feedback off;

undefine dflt_name

set termout off;
-- set report function name and line size
column fn_name new_value fn_name noprint;
select 'display_text' fn_name from dual where lower('&report_type') = 'text';
select 'display_html' fn_name from dual where lower('&report_type') <> 'text';

column lnsz new_value lnsz noprint;
select '80' lnsz from dual where lower('&report_type') = 'text';
select '1500' lnsz from dual where lower('&report_type') <> 'text';

set linesize &lnsz;
set termout on;
spool &report_name;

-- call the table function to generate the report
select output from table(dbms_feature_usage_report.&fn_name( :dbid,
                                                             :version
                                                             :rpt_options ));

spool off;

prompt Report written to &report_name.

set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;

-- Undefine report 
undefine report_name
undefine report_type
undefine ext
undefine fn_name
undefine lnsz

whenever sqlerror continue;
--
--  End of script file;

