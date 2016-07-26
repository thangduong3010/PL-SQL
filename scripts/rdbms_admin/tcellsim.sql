Rem
Rem $Header: rdbms/admin/tcellsim.sql /main/1 2008/12/18 15:27:03 kyagoub Exp $
Rem
Rem tcellsim.sql
Rem
Rem Copyright (c) 2008, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      tcellsim.sql - test cell in simulation mode
Rem
Rem    DESCRIPTION
Rem      This script uses SQL Peformance Analyzer (SPA) to test cell
Rem      storage in simulation mode.
Rem      Given a SQL tuning set storing a SQL workload, SPA test executes 
Rem      SQL statements stored in the SQL tuning set twice. 
Rem      A first time before enabling cell storage simulation, and a second
Rem      time after simulating cell storage. After that, SPA uses 
Rem      io_interconnect_bytes to compare SQL performance changes and 
Rem      then generates a report summary. 
Rem
Rem    NOTES
Rem      NONE
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kyagoub     12/11/08 - set heading off
Rem    kyagoub     08/25/08 - Created
Rem

set long 1000000 longchunksize 1000;
set feedback off;
set veri off;

prompt
prompt 10 Most active SQL tuning sets
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select * from 
  (select name, owner, statement_count sql_count, 
          substr(description, 1, 20) descp
   from dba_sqlset
  order by last_modified desc)
where rownum <= 10; 


prompt
prompt Specify the name and owner of SQL tuning set to use
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
column sts_name new_value sts_name;
column sts_owner new_value sts_owner;
set heading off;
select ' >> SQL tuning set specified: &&sts_name owned by &&sts_owner' 
from dual;
set heading on;


prompt
prompt Run Cell simulation 
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable aname VARCHAR2(64);
variable err   NUMBER;

prompt 
prompt   >> 1. create a spa analysis task to test cell simulation 
prompt   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exec :err := 0; 
BEGIN 
  :aname := dbms_sqlpa.create_analysis_task(sqlset_name => '&&sts_name',
            sqlset_owner => '&&sts_owner');

  -- handle exception 
  EXCEPTION 
   WHEN OTHERS THEN
     :err := 1; 
     RAISE; 
END; 
/

set heading off;
select ' >> Name of SPA analysis task: ' || :aname 
from dual where :err = 0;
set heading on;

prompt
prompt   >> 2. Test execute statements with cell simulatin DISABLED
prompt   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN 
  IF (:err = 0) THEN 
    dbms_sqlpa.execute_analysis_task(
       task_name => :aname, 
       execution_type => 'execute',
       execution_name => 'cell_simulation_DISABLED',
       execution_params => dbms_advisor.arglist('cell_simulation_enabled',
       'FALSE')); 
  END IF; 

  -- handle exception 
  EXCEPTION 
   WHEN OTHERS THEN
     :err := 1; 
     RAISE; 
END; 
/

prompt
prompt  >> 3. Test execute statements with cell simulation ENABLED
prompt  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN 
  IF (:err = 0) THEN 
    dbms_sqlpa.execute_analysis_task(
     task_name => :aname, 
     execution_type => 'execute',
     execution_name => 'cell_simulation_ENABLED',
     execution_params => dbms_advisor.arglist('cell_simulation_enabled',
     'TRUE')); 
  END IF; 

  -- handle exception 
  EXCEPTION 
   WHEN OTHERS THEN
     :err := 1; 
     RAISE; 
END; 
/

prompt
prompt   >> 4. Compare peformance and generate analysis report 
prompt  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BEGIN 
  IF (:err = 0) THEN 
    dbms_sqlpa.execute_analysis_task(:aname, 'compare',
       execution_params => dbms_advisor.arglist('comparison_metric',
       'io_interconnect_bytes')); 

  END IF; 

  -- handle exception 
  EXCEPTION 
   WHEN OTHERS THEN
     :err := 1; 
     RAISE; 
END; 
/

-- display report
set heading off; 
select dbms_sqlpa.report_analysis_task(:aname, 'text', top_sql => 10) spa_summary
from dual
where :err = 0;
set heading on;

undefine sts_name;
undefine sts_owner;
set feedback on;
set veri on;



