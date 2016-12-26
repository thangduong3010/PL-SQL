Rem
Rem $Header: sqltrpt.sql 11-apr-2005.11:01:39 pbelknap Exp $
Rem
Rem sqltrpt.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sqltrpt.sql - SQL Tune RePorT
Rem
Rem    DESCRIPTION
Rem      Script that gets a single statement as input from the user (via SQLID),
Rem      tunes that statement, and then displays the text report.
Rem
Rem      To tune multiple statements, create a sql tuning set and create a
Rem      tuning task with it as input (see dbmssqlt.sql).
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    04/11/05 - remove linesize 
Rem    kyagoub     07/05/04 - kyagoub_proj_13448-2
Rem    pbelknap    06/29/04 - feedback from rae burns 
Rem    pbelknap    06/17/04 - Created
Rem

SET NUMWIDTH 10
SET TAB OFF


set long 1000000;
set longchunksize 1000;
set feedback off;
set veri off;

-- Get the sql statement to tune

prompt
prompt 15 Most expensive SQL in the cursor cache
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

column elapsed format 99,990.90;
variable newl varchar2(64);

begin
  :newl := '
';
end;
/

select * from (
 select sql_id, elapsed_time / 1000000 as elapsed, SUBSTRB(REPLACE(sql_text,:newl,' '),1,55) as sql_text_fragment
 from   V$SQLSTATS
 order by elapsed_time desc
) where ROWNUM <= 15;

prompt
prompt 15 Most expensive SQL in the workload repository
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select * from (
 select stat.sql_id as sql_id, sum(elapsed_time_delta) / 1000000 as elapsed, 
     (select to_char(substr(replace(st.sql_text,:newl,' '),1,55)) 
     from dba_hist_sqltext st
     where st.dbid = stat.dbid and st.sql_id = stat.sql_id) as sql_text_fragment
 from dba_hist_sqlstat stat, dba_hist_sqltext text
 where stat.sql_id = text.sql_id and
       stat.dbid   = text.dbid
 group by stat.dbid, stat.sql_id
 order by elapsed desc
) where ROWNUM <= 15;

prompt
prompt Specify the Sql id
prompt ~~~~~~~~~~~~~~~~~~
column sqlid new_value sqlid;
set heading off;
select 'Sql Id specified: &&sqlid' from dual;
set heading on;

prompt
prompt Tune the sql
prompt ~~~~~~~~~~~~
variable task_name varchar2(64);
variable err       number;

-- By default, no error
execute :err := 0;

set serveroutput on;

DECLARE
  cnt      NUMBER;
  bid      NUMBER;
  eid      NUMBER;
BEGIN
  -- If it's not in V$SQL we will have to query the workload repository
  select count(*) into cnt from V$SQLSTATS where sql_id = '&&sqlid';

  IF (cnt > 0) THEN
    :task_name := dbms_sqltune.create_tuning_task(sql_id => '&&sqlid');
  ELSE
    select min(snap_id) into bid
    from   dba_hist_sqlstat
    where  sql_id = '&&sqlid';

    select max(snap_id) into eid
    from   dba_hist_sqlstat
    where  sql_id = '&&sqlid';

    :task_name := dbms_sqltune.create_tuning_task(begin_snap => bid,
                                                  end_snap => eid,
                                                  sql_id => '&&sqlid');
  END IF;

  dbms_sqltune.execute_tuning_task(:task_name);

EXCEPTION
  WHEN OTHERS THEN
    :err := 1;

    IF (SQLCODE = -13780) THEN
      dbms_output.put_line ('ERROR: statement is not in the cursor cache ' ||
                            'or the workload repository.');
      dbms_output.put_line('Execute the statement and try again');
    ELSE
      RAISE;
    END IF;   
 
END;
/

set heading off;
select dbms_sqltune.report_tuning_task(:task_name) from dual where :err <> 1;
select '   ' from dual where :err = 1;
set heading on;

undefine sqlid;
set feedback on;
set veri on;
