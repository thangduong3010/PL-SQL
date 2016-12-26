Rem
Rem $Header: rdbms/admin/spadvrpt.sql /st_rdbms_11.2.0/1 2010/08/03 16:22:21 vchandar Exp $
Rem
Rem spadvrpt.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spadvrpt.sql - Streams Performance ADVisor RePorT
Rem
Rem    DESCRIPTION
Rem      Generate a Html report of the Streams performance using the 
Rem      utlspadv package. 
Rem    
Rem    NOTES
Rem      utlspadv.collect_stats should have been called before attempting
Rem      to run the script. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vchandar    07/01/10 - change output to utl_file
Rem    vchandar    12/10/09 - fix syntax
Rem    vchandar    09/08/09 - Created
Rem

-- Set up the environment
set define '`';
set linesize 1000;
set echo off;
set serveroutput on feedback off;
set veri off;

prompt
prompt SPADV HTML REPORTING UTILITY
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Prior to running this tool. Please create a directory object
prompt to store the report & make sure the current user has write access.
prompt This is typically done as follows :
prompt 1. conn sys/~~~~ as sysdba
prompt 2. create or replace directory SPADVDIR as '<PATH/IN/FILESYSTEM>';
prompt 3. grant read, write on directory SPADVDIR to <CURRENT_USER>;

-- get user input 
prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

prompt
prompt Specify the Performance Advisor Table name
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter the name of the performance advisor table used to 
prompt collect statistics.
prompt  Defaults to 'STREAMS$_ADVISOR_COMP_STAT'
set heading off;

select 'Table specified ' , 
       lower(nvl('``table_name','STREAMS$_ADVISOR_COMP_STAT')) table_name 
  from dual;
set heading on;

column tab_name new_value tab_name;
set heading off;
set termout off;
select 'STREAMS$_ADVISOR_COMP_STAT' tab_name 
  from dual 
  where lower('`table_name') is null;

select '`table_name' tab_name 
  from dual 
  where lower('`table_name') is not null;

set termout on;
set heading on;

-- print all the paths 
prompt 
prompt The following paths are available 
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

var rc REFCURSOR;
begin
  open :rc for 'select distinct path_id from ' || lower('`tab_name') ; 
end;
/
print :rc;

-- obtain the path_id
prompt
prompt Specify the path id
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter the id of the path for which you want to view statistics
prompt  Defaults to all existing paths
prompt Path specified : ``path_id

-- print all available run_ids for the user. 
prompt
prompt The following runs are available
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt 
var rcp REFCURSOR;
BEGIN
  open :rcp for  'select distinct path_id, advisor_run_id, ' ||
                   'to_char( advisor_run_time,''DD-MON-YYYY HH24:MI:SS'') ' || 
                   'as run_time' || 
                   ' from ' || lower('`tab_name') || 
                   case when lower('`path_id') is null
                     then ' '
                     else ' where path_id = ' || lower('`path_id')
                   end ||
                   ' order by path_id,advisor_run_id';
END;
/
print :rcp;


-- obtain the start and end run ids
prompt 
prompt Choose a begin and end run id
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Defaults to last 10 runs
prompt Begin run_id specified : ``bgn_run_id
prompt End   run_id specified : ``end_run_id

-- obtain the directory object name
prompt 
prompt Enter the name of the directory object to store report
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Directory Object Name : ``dir_name

-- obtain the report name
prompt 
prompt How do you want to call the report? 
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt defaults to spadvreport.html
prompt Report will be stored in : ``report_name

column rpt_name new_value rpt_name;
set heading off;
set termout off;
select 'spadvreport.html' rpt_name 
  from dual 
  where lower('`report_name') is null;

select '`report_name' rpt_name 
  from dual 
  where lower('`report_name') is not null;

set termout on;
set heading on;

exec dbms_output.put_line(lower('`rpt_name'));


-- generate the stats

begin
  if lower('`bgn_run_id') is null or lower('`end_run_id') is null  then
    UTL_SPADV.show_stats_html(upper('`dir_name'), lower('`rpt_name'), 
                              lower('`tab_name'), 
                              to_number(lower('`path_id')));
  else
    UTL_SPADV.show_stats_html(upper('`dir_name'), lower('`rpt_name'), 
                              lower('`tab_name'), to_number(lower('`path_id')), 
                              to_number(lower('`bgn_run_id')),
                              to_number(lower('`end_run_id')));
  end if;
end;
/


--
-- End of file
