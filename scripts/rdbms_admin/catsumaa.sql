Rem
Rem $Header: rdbms/admin/catsumaa.sql /main/21 2009/12/08 18:04:23 arbalakr Exp $
Rem
Rem catsumaa.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsumaa.sql - catalog definitions for SQL Access Advisor
Rem
Rem    DESCRIPTION
Rem      Contains types, syononyms and views for the 
Rem      private portion of the Advisor framework repository.
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    11/23/09 - truncate module/action to the maximum lengths
Rem                           in X$MODACT_LENGTH
Rem    gssmith     03/23/06 - STS conversion 
Rem    gssmith     05/27/04 - Bug 3647046 
Rem    gssmith     02/05/04 - Change journal keywords 
Rem    gssmith     02/04/04 - Adding new column to parameters view 
Rem    gssmith     11/05/03 - Templates bug 
Rem    mxiao       10/27/03 - change the script type in tune_mview views 
Rem    gssmith     10/23/03 - Bug 3207351 
Rem    gssmith     09/04/03 - Bug 3019884 
Rem    gssmith     07/22/03 - Lrg fix
Rem    twtong      06/11/03 - bug-2999427
Rem    gssmith     04/30/03 - AA workload adjustments
Rem    gssmith     03/26/03 - Bug 2869857
Rem    gssmith     03/18/03 - Access Advisor column name changes
Rem    gssmith     01/30/03 - Fix user view privs
Rem    twtong      12/22/02 - modify dba_tune_mview
Rem    gssmith     12/04/02 - Add VALID flag to workload table
Rem    twtong      10/22/02 - modify dba_tune_mview
Rem    mxiao       10/14/02 - add USER/DBA_TUNE_MVIEW
Rem    gssmith     10/22/02 - Adding name to views
Rem    gssmith     10/22/02 - Bugs
Rem    btao        10/03/02 - add select_catalog_role statement
Rem    gssmith     09/20/02 - Fixing sqlw_stmts view
Rem    gssmith     09/20/02 - remove task type
Rem    gssmith     09/13/02 - Adding template support
Rem    gssmith     09/10/02 - wip
Rem    gssmith     09/03/02 - wip
Rem    gssmith     07/29/02 - Created
Rem

REM
REM   SQL Access Advisor tables
REM


Rem
Rem   Workload mapping table
Rem

create or replace view dba_advisor_sqla_wk_map
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.workload_id as workload_id,
             a.name as workload_name,
             a.is_sts as is_sts
      from wri$_adv_sqla_map a, wri$_adv_tasks b
      where a.task_id = b.id;

create or replace public synonym dba_advisor_sqla_wk_map
   for dba_advisor_sqla_wk_map;
grant select on dba_advisor_sqla_wk_map to select_catalog_role;


create or replace view user_advisor_sqla_wk_map
   as select a.task_id as task_id,
             b.name as task_name,
             a.workload_id as workload_id,
             a.name as workload_name,
             a.is_sts as is_sts
      from wri$_adv_sqla_map a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_sqla_wk_map
   for user_advisor_sqla_wk_map;
grant select on user_advisor_sqla_wk_map to public;


Rem
Rem   Workload summary for task analysis
Rem
Rem

create or replace view dba_advisor_sqla_wk_sum
   as select b.owner_name as owner,
             b.name as task_name,
             b.id as task_id,
             a.num_select as num_select_stmt,
             a.num_update as num_update_stmt,
             a.num_delete as num_delete_stmt,
             a.num_insert as num_insert_stmt,
             a.num_merge as num_merge_stmt
      from wri$_adv_sqla_sum a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.advisor_id = 2;

create or replace public synonym dba_advisor_sqla_wk_sum
   for dba_advisor_sqla_wk_sum;
grant select on dba_advisor_sqla_wk_sum to select_catalog_role;

create or replace view user_advisor_sqla_wk_sum
   as select b.name as task_name,
             b.id as task_id,
             a.num_select as num_select_stmt,
             a.num_update as num_update_stmt,
             a.num_delete as num_delete_stmt,
             a.num_insert as num_insert_stmt,
             a.num_merge as num_merge_stmt
      from wri$_adv_sqla_sum a, wri$_adv_tasks b
      where b.owner# = userenv('SCHEMAID')
        and a.task_id = b.id
        and b.advisor_id = 2;

create or replace public synonym user_advisor_sqla_wk_sum
   for user_advisor_sqla_wk_sum;
grant select on user_advisor_sqla_wk_sum to public;


Rem
Rem sql workload statements (private to Access Advisor tasks)
Rem

create or replace view dba_advisor_sqla_wk_stmts
   as select aa1.owner_name as owner,
             aa1.name as task_name,
             aa1.id as task_id,
             aa3.workload_id as sqlset_id,
             aa3.name as sqlset_name,
             aa3.name as workload_name,
             s.sql_id as sql_id,
             s.sql_seq as sql_seq,
             s.plan_hash_value as plan_hash_value,
             s.parsing_schema_name as parsing_schema_name,
             s.parsing_schema_name as username,
             s.module as module,
             s.action as action,
             s.cpu_time as cpu_time,
             s.buffer_gets as buffer_gets,
             s.disk_reads as disk_reads,
             s.elapsed_time as elapsed_time,
             s.rows_processed as rows_processed,
             s.executions as executions,
             to_date(s.first_load_time,'yyyy-mm-dd/hh24:mi:ss') as first_load_time,
             to_date(s.first_load_time,'yyyy-mm-dd/hh24:mi:ss') as last_execution_date,
             s.priority as priority,
             s.command_type as command_type,
             s.stat_period as stat_period,
             s.active_stat_period as active_stat_period,
             s.sql_text as sql_text,
             aa2.pre_cost as precost,
             aa2.post_cost as postcost,
             aa2.imp as importance,
             aa2.rec_id as rec_id,
             aa2.validated as validated
      from sys.wri$_adv_tasks aa1, sys.wri$_adv_sqla_stmts aa2, 
           sys.wri$_adv_sqla_map aa3, dba_sqlset_statements s
      where aa1.id = aa2.task_id
        and aa1.advisor_id = 2
        and aa1.id = aa3.task_id
        and aa2.workload_id = aa3.workload_id
        and s.sqlset_id = aa3.workload_id
        and s.sql_seq = aa2.stmt_id
        and aa3.is_sts = 1;

create or replace public synonym dba_advisor_sqla_wk_stmts
   for dba_advisor_sqla_wk_stmts;
grant select on dba_advisor_sqla_wk_stmts to select_catalog_role;

create or replace view user_advisor_sqla_wk_stmts
   as select aa1.name as task_name,
             aa1.id as task_id,
             aa3.workload_id as sqlset_id,
             aa3.name as sqlset_name,
             aa3.name as workload_name,
             s.sql_id as sql_id,
             s.sql_seq as sql_seq,
             s.plan_hash_value as plan_hash_value,
             s.parsing_schema_name as parsing_schema_name,
             s.parsing_schema_name as username,
             s.module as module,
             s.action as action,
             s.cpu_time as cpu_time,
             s.buffer_gets as buffer_gets,
             s.disk_reads as disk_reads,
             s.elapsed_time as elapsed_time,
             s.rows_processed as rows_processed,
             s.executions as executions,
             to_date(s.first_load_time,'yyyy-mm-dd/hh24:mi:ss') as first_load_time,
             to_date(s.first_load_time,'yyyy-mm-dd/hh24:mi:ss') as last_execution_date,
             s.priority as priority,
             s.command_type as command_type,
             s.stat_period as stat_period,
             s.active_stat_period as active_stat_period,
             s.sql_text as sql_text,
             aa2.pre_cost as precost,
             aa2.post_cost as postcost,
             aa2.imp as importance,
             aa2.rec_id as rec_id,
             aa2.validated as validated
      from sys.wri$_adv_tasks aa1, sys.wri$_adv_sqla_stmts aa2, 
           sys.wri$_adv_sqla_map aa3,dba_sqlset_statements s
      where aa1.id = aa2.task_id
        and aa1.id = aa3.task_id
        and aa2.workload_id = aa3.workload_id
        and s.sqlset_id = aa3.workload_id
        and s.sql_seq = aa2.stmt_id
        and aa3.is_sts = 1
        and aa1.owner# = userenv('SCHEMAID')
        and aa1.advisor_id = 2;

create or replace public synonym user_advisor_sqla_wk_stmts
   for user_advisor_sqla_wk_stmts;
grant select on user_advisor_sqla_wk_stmts to public;

Rem
Rem   sql Workload table references
Rem
Rem         Contains a list of tables referenced by each workload statement
Rem         Temporary until SWO is implemented.
Rem

create or replace view dba_advisor_sqla_tables
   as select d.owner_name as owner,
             b.task_id as task_id,
             d.name as task_name,
             b.sql_id as sql_id,
             b.stmt_id as stmt_id,
             b.table_owner  as table_owner,
             b.table_name as table_name
      from wri$_adv_sqla_tables b, wri$_adv_tasks d
      where d.id = b.task_id
        and d.advisor_id = 2;

create or replace public synonym dba_advisor_sqla_tables
   for dba_advisor_sqla_tables;
grant select on dba_advisor_sqla_tables to select_catalog_role;

create or replace view user_advisor_sqla_tables
   as select b.task_id as task_id,
             d.name as task_name,
             b.sql_id as sql_id,
             b.stmt_id as stmt_id,
             b.table_owner  as table_owner,
             b.table_name as table_name
      from wri$_adv_sqla_tables b, wri$_adv_tasks d
      where d.id = b.task_id
        and d.owner# = userenv('SCHEMAID')
        and d.advisor_id = 2;

create or replace public synonym user_advisor_sqla_tables
   for user_advisor_sqla_tables;
grant select on user_advisor_sqla_tables to public;


Rem
Rem Table volatility data
Rem

create or replace view dba_advisor_sqla_tabvol
   as select a.owner_name as owner,
             a.name as task_name,
             a.id as task_id,
             b.owner_name as table_owner,
             b.table_name as table_name,
             b.upd_freq as update_freq,
             b.ins_freq as insert_freq,
             b.del_freq as delete_freq,
             b.dir_freq as direct_load_freq,
             b.upd_rows as updated_rows,
             b.ins_rows as inserted_rows,
             b.del_rows as deleted_rows,
             b.dir_rows as direct_load_rows
      from wri$_adv_tasks a, wri$_adv_sqla_tabvol b
      where a.id = b.task_id
        and a.advisor_id = 2;

create or replace public synonym dba_advisor_sqla_tabvol
   for dba_advisor_sqla_tabvol;
grant select on dba_advisor_sqla_tabvol to select_catalog_role;

create or replace view user_advisor_sqla_tabvol
   as select a.name as task_name,
             a.id as task_id,
             b.owner_name as table_owner,
             b.table_name as table_name,
             b.upd_freq as update_freq,
             b.ins_freq as insert_freq,
             b.del_freq as delete_freq,
             b.dir_freq as direct_load_freq,
             b.upd_rows as updated_rows,
             b.ins_rows as inserted_rows,
             b.del_rows as deleted_rows,
             b.dir_rows as direct_load_rows
      from wri$_adv_tasks a, wri$_adv_sqla_tabvol b
      where a.id = b.task_id 
        and a.owner# = userenv('SCHEMAID')
        and a.advisor_id = 2;

create or replace public synonym user_advisor_sqla_tabvol
   for user_advisor_sqla_tabvol;
grant select on user_advisor_sqla_tabvol to public;


Rem
Rem Column volatility data
Rem

create or replace view dba_advisor_sqla_colvol
   as select a.owner_name as owner,
             a.name as task_name,
             a.id as task_id,
             e.owner_name as table_owner,
             e.table_name as table_name,
             d.name as column_name,
             b.upd_freq as update_freq,
             b.upd_rows as updated_rows
      from wri$_adv_tasks a, wri$_adv_sqla_colvol b,
           sys.col$ d,wri$_adv_sqla_tabvol e
      where a.id = b.task_id
        and a.id = e.task_id
        and d.col# = b.col#
        and e.table# = b.table#
        and a.advisor_id = 2;

create or replace public synonym dba_advisor_sqla_colvol
   for dba_advisor_sqla_colvol;
grant select on dba_advisor_sqla_colvol to select_catalog_role;

create or replace view user_advisor_sqla_colvol
   as select a.name as task_name,
             a.id as task_id,
             e.owner_name as table_owner,
             e.table_name as table_name,
             d.name as column_name,
             b.upd_freq as update_freq,
             b.upd_rows as updated_rows
      from wri$_adv_tasks a, wri$_adv_sqla_colvol b,
           sys.col$ d,wri$_adv_sqla_tabvol e
      where a.id = b.task_id
        and a.id = e.task_id
        and d.col# = b.col#
        and e.table# = b.table#
        and a.owner# = userenv('SCHEMAID')
        and a.advisor_id = 2;

create or replace public synonym user_advisor_sqla_colvol
   for user_advisor_sqla_colvol;
grant select on user_advisor_sqla_colvol to public;


Rem
Rem   Recommendation summary
Rem

create or replace view dba_advisor_sqla_rec_sum
   as select max(b.owner_name) as owner,
             max(a.task_id) as task_id,
             max(b.name) as task_name,
             max(a.rec_id) as rec_id,
             count(*) as total_stmts,
             sum(a.pre_cost) as total_precost,
             sum(a.post_cost) as total_postcost
      from wri$_adv_sqla_stmts a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.advisor_id = 2
      group by a.task_id, a.rec_id;
            
create or replace public synonym dba_advisor_sqla_rec_sum
  for dba_advisor_sqla_rec_sum;
grant select on dba_advisor_sqla_rec_sum to select_catalog_role;

create or replace view user_advisor_sqla_rec_sum
   as select max(a.task_id) as task_id,
             max(b.name) as task_name,
             max(a.rec_id) as rec_id,
             count(*) as total_stmts,
             sum(a.pre_cost) as total_precost,
             sum(a.post_cost) as total_postcost
      from wri$_adv_sqla_stmts a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and b.advisor_id = 2
      group by a.task_id, a.rec_id;
            
create or replace public synonym user_advisor_sqla_rec_sum
  for user_advisor_sqla_rec_sum;
grant select on user_advisor_sqla_rec_sum to public;


Rem
Rem   Workload tables
Rem

Rem
Rem   Workload table
Rem
Rem

create or replace view dba_advisor_sqlw_sum
   as select b.owner_name as owner,
             b.id as workload_id,
             b.name as workload_name,
             b.description as description,
             b.ctime as create_date,
             b.mtime as modify_date,
             a.num_select as num_select_stmt,
             a.num_update as num_update_stmt,
             a.num_delete as num_delete_stmt,
             a.num_insert as num_insert_stmt,
             a.num_merge as num_merge_stmt,
             b.source as source,
             b.how_created as how_created,
             a.data_source as data_source,
             decode(bitand(b.property,1),1,'TRUE','FALSE') as read_only
      from wri$_adv_sqlw_sum a, wri$_adv_tasks b
      where a.workload_id = b.id
        and bitand(b.property,2) = 0
        and b.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_sum
   for dba_advisor_sqlw_sum;
grant select on dba_advisor_sqlw_sum to select_catalog_role;

create or replace view user_advisor_sqlw_sum
   as select b.id as workload_id,
             b.name as workload_name,
             b.description as description,
             b.ctime as create_date,
             b.mtime as modify_date,
             a.num_select as num_select_stmt,
             a.num_update as num_update_stmt,
             a.num_delete as num_delete_stmt,
             a.num_insert as num_insert_stmt,
             a.num_merge as num_merge_stmt,
             b.source as source,
             b.how_created as how_created,
             a.data_source as data_source,
             decode(bitand(b.property,1),1,'TRUE','FALSE') as read_only
      from wri$_adv_sqlw_sum a, wri$_adv_tasks b
      where b.owner# = userenv('SCHEMAID')
        and a.workload_id = b.id
        and bitand(b.property,2) = 0
        and b.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_sum
   for user_advisor_sqlw_sum;
grant select on user_advisor_sqlw_sum to public;


Rem
Rem   Workload templates table
Rem
Rem      Temporary until SWO is implemented
Rem

create or replace view dba_advisor_sqlw_templates
   as select b.owner_name as owner,
             b.id as workload_id,
             b.name as workload_name,
             b.description as description,
             b.ctime as create_date,
             b.mtime as modify_date,
             b.source as source,
             decode(bitand(b.property,1),1,'TRUE','FALSE') as read_only
      from wri$_adv_sqlw_sum a, wri$_adv_tasks b
      where a.workload_id = b.id
        and bitand(b.property,2) = 2
        and b.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_templates
   for dba_advisor_sqlw_templates;
grant select on dba_advisor_sqlw_templates to select_catalog_role;

create or replace view user_advisor_sqlw_templates
   as select b.id as workload_id,
             b.name as workload_name,
             b.description as description,
             b.ctime as create_date,
             b.mtime as modify_date,
             b.source as source,
             decode(bitand(b.property,1),1,'TRUE','FALSE') as read_only
      from wri$_adv_sqlw_sum a, wri$_adv_tasks b
      where b.owner# = userenv('SCHEMAID')
        and a.workload_id = b.id
        and bitand(b.property,2) = 2
        and b.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_templates
   for user_advisor_sqlw_templates;
grant select on user_advisor_sqlw_templates to public;


Rem
Rem sql workload statements
Rem
Rem      Temporary workload table until SWO is implemented.
Rem
Rem         Valid values for validated column:
Rem
Rem             0 - unused
Rem             1 - Valid after workload filtering
Rem             2 - Valid after applying importance filtering

create or replace view dba_advisor_sqlw_stmts
   as select c.owner_name as owner,
             b.workload_id as workload_id,
             c.name as workload_name,
             b.sql_id as sql_id,
             b.hash_value as hash_value,
             b.username as username,
             substrb(b.module,1,(select ksumodlen from x$modact_length))
             as module,
             substrb(b.action,1,(select ksuactlen from x$modact_length))
             as action,
             b.cpu_time as cpu_time,
             b.buffer_gets as buffer_gets,
             b.disk_reads as disk_reads,
             b.elapsed_time as elapsed_time,
             b.rows_processed as rows_processed,
             b.executions as executions,
             b.optimizer_cost as optimizer_cost,
             b.last_execution_date as last_execution_date,
             b.priority as priority,
             b.command_type as command_type,
             b.stat_period as stat_period,
             b.sql_text as sql_text,
             b.valid as valid
      from wri$_adv_sqlw_stmts b,wri$_adv_tasks c
      where b.workload_id = c.id
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_stmts
   for dba_advisor_sqlw_stmts;
grant select on dba_advisor_sqlw_stmts to select_catalog_role;

create or replace view user_advisor_sqlw_stmts
   as select b.workload_id as workload_id,
             c.name as workload_name,
             b.sql_id as sql_id,
             b.hash_value as hash_value,
             b.username as username,
             substrb(b.module,1,(select ksumodlen from x$modact_length))
             as module,
             substrb(b.action,1,(select ksuactlen from x$modact_length))
             as action,
             b.cpu_time as cpu_time,
             b.buffer_gets as buffer_gets,
             b.disk_reads as disk_reads,
             b.elapsed_time as elapsed_time,
             b.rows_processed as rows_processed,
             b.executions as executions,
             b.optimizer_cost as optimizer_cost,
             b.last_execution_date as last_execution_date,
             b.priority as priority,
             b.command_type as command_type,
             b.stat_period as stat_period,
             b.sql_text as sql_text,
             b.valid as valid
      from wri$_adv_sqlw_stmts b, wri$_adv_tasks c
      where c.id = b.workload_id 
        and c.owner# = userenv('SCHEMAID')
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_stmts
   for user_advisor_sqlw_stmts;
grant select on user_advisor_sqlw_stmts to public;


Rem
Rem   sql Workload table references
Rem
Rem         Contains a list of tables referenced by each workload statement
Rem         Temporary until SWO is implemented.
Rem

create or replace view dba_advisor_sqlw_tables
   as select d.owner_name as owner,
             b.workload_id as workload_id,
             d.name as workload_name,
             b.sql_id as sql_id,
             b.table_owner  as table_owner,
             b.table_name as table_name
      from wri$_adv_sqlw_tables b, wri$_adv_tasks d
      where d.id = b.workload_id
        and bitand(d.property,2) = 0
        and d.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_tables
   for dba_advisor_sqlw_tables;
grant select on dba_advisor_sqlw_tables to select_catalog_role;

create or replace view user_advisor_sqlw_tables
   as select b.workload_id as workload_id,
             c.name as workload_name,
             b.sql_id as sql_id,
             b.table_owner  as table_owner,
             b.table_name as table_name
      from wri$_adv_sqlw_tables b, wri$_adv_tasks c
      where c.id = b.workload_id
        and c.owner# = userenv('SCHEMAID')
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_tables
   for user_advisor_sqlw_tables;
grant select on user_advisor_sqlw_tables to public;


Rem
Rem Table volatility data
Rem

create or replace view dba_advisor_sqlw_tabvol
   as select c.owner_name as owner,
             b.workload_id as workload_id,
             c.name as workload_name,
             b.owner_name as table_owner,
             b.table_name as table_name,
             b.upd_freq as update_freq,
             b.ins_freq as insert_freq,
             b.del_freq as delete_freq,
             b.dir_freq as direct_load_freq,
             b.upd_rows as updated_rows,
             b.ins_rows as inserted_rows,
             b.del_rows as deleted_rows,
             b.dir_rows as direct_load_rows
      from wri$_adv_sqlw_tabvol b, wri$_adv_tasks c
      where c.id = b.workload_id
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_tabvol
   for dba_advisor_sqlw_tabvol;
grant select on dba_advisor_sqlw_tabvol to select_catalog_role;

create or replace view user_advisor_sqlw_tabvol
   as select b.workload_id as workload_id,
             c.name as workload_name,
             b.owner_name as table_owner,
             b.table_name as table_name,
             b.upd_freq as update_freq,
             b.ins_freq as insert_freq,
             b.del_freq as delete_freq,
             b.dir_freq as direct_load_freq,
             b.upd_rows as updated_rows,
             b.ins_rows as inserted_rows,
             b.del_rows as deleted_rows,
             b.dir_rows as direct_load_rows
      from wri$_adv_sqlw_tabvol b, wri$_adv_tasks c
      where c.id = b.workload_id
        and c.owner# = userenv('SCHEMAID')
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_tabvol
   for user_advisor_sqlw_tabvol;
grant select on user_advisor_sqlw_tabvol to public;


Rem
Rem Column volatility data
Rem

create or replace view dba_advisor_sqlw_colvol
   as select c.owner_name as owner,
             b.workload_id as workload_id,
             c.name as workload_name,
             e.owner_name as table_owner,
             e.table_name as table_name,
             d.name as column_name,
             b.upd_freq as update_freq,
             b.upd_rows as updated_rows
      from wri$_adv_sqlw_colvol b, wri$_adv_tasks c, sys.col$ d,
           wri$_adv_sqlw_tabvol e
      where c.id = b.workload_id
        and d.col# = b.col#
        and e.table# = b.table#
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_colvol
   for dba_advisor_sqlw_colvol;
grant select on dba_advisor_sqlw_colvol to select_catalog_role;

create or replace view user_advisor_sqlw_colvol
   as select b.workload_id as workload_id,
             c.name as workload_name,
             e.owner_name as table_owner,
             e.table_name as table_name,
             d.name as column_name,
             b.upd_freq as update_freq,
             b.upd_rows as updated_rows
      from wri$_adv_sqlw_colvol b, wri$_adv_tasks c, sys.col$ d,
           wri$_adv_sqlw_tabvol e
      where c.id = b.workload_id
        and c.owner# = userenv('SCHEMAID')
        and d.col# = b.col#
        and e.table# = b.table#
        and bitand(c.property,2) = 0
        and c.advisor_id = 6;

create or replace public synonym user_advisor_sqlw_colvol
   for user_advisor_sqlw_colvol;
grant select on user_advisor_sqlw_colvol to public;

Rem
Rem Workload parameters
Rem

create or replace view dba_advisor_sqlw_parameters
   as select b.owner_name as owner,
             a.task_id as workload_id,
             b.name as workload_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype,1,'NUMBER',2,'STRING',3,'STRINGLIST',
                               4,'TABLE',5,'TABLELIST','UNKNOWN')
                 as parameter_type,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.advisor_id = 6
        and bitand(a.flags,1) = 0;

create or replace public synonym dba_advisor_sqlw_parameters
   for dba_advisor_sqlw_parameters;
grant select on dba_advisor_sqlw_parameters to select_catalog_role;

create or replace view user_advisor_sqlw_parameters
   as select a.task_id as workload_id,
             b.name as workload_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype,1,'NUMBER',2,'STRING',3,'STRINGLIST',
                               4,'TABLE',5,'TABLELIST','UNKNOWN')
                 as parameter_type,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and b.advisor_id = 6
        and bitand(a.flags,1) = 0;

create or replace public synonym user_advisor_sqlw_parameters
   for user_advisor_sqlw_parameters;
grant select on user_advisor_sqlw_parameters to public;

Rem
Rem workload journal
Rem

create or replace view dba_advisor_sqlw_journal
   as select b.owner_name as owner,
             a.task_id as workload_id,
             b.name as workload_name,
             a.seq_id as journal_entry_seq,
             decode(a.type, 1, 'FATAL', 
                            2, 'ERROR',
                            3, 'WARNING',
                            4, 'INFORMATION',
                            5, 'INFORMATION2',
                            6, 'INFORMATION3',
                            7, 'INFORMATION4',
                            8, 'INFORMATION5',
                            9, 'INFORMATION6') as journal_entry_type,
             dbms_advisor.format_message_group(a.msg_id) as journal_entry
      from wri$_adv_journal a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.advisor_id = 6;

create or replace public synonym dba_advisor_sqlw_journal
   for dba_advisor_sqlw_journal;
grant select on dba_advisor_sqlw_journal to select_catalog_role;
 
create or replace view user_advisor_sqlw_journal
   as select a.task_id as workload_id,
             b.name as workload_name,
             a.seq_id as journal_entry_seq,
             decode(a.type, 1, 'FATAL', 
                            2, 'ERROR',
                            3, 'WARNING',
                            4, 'INFORMATION',
                            5, 'INFORMATION2',
                            6, 'INFORMATION3',
                            7, 'INFORMATION4',
                            8, 'INFORMATION5',
                            9, 'INFORMATION6') as journal_entry_type,
             dbms_advisor.format_message_group(a.msg_id) as journal_entry
      from wri$_adv_journal a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.advisor_id = 6
        and b.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_sqlw_journal
   for user_advisor_sqlw_journal;
grant select on user_advisor_sqlw_journal to public;

Rem
Rem The dba/user_tune_mview family is to display the results after
Rem running the dbms_advisor.tune_mview API.
Rem
CREATE OR replace VIEW dba_tune_mview
  (owner, task_name, action_id, script_type, statement)
  AS
  SELECT t.owner_name, t.name, a.id, 
         decode(a.command, 3, 'IMPLEMENTATION', 4, 'IMPLEMENTATION',
                           18, 'UNDO', 23, 'IMPLEMENTATION',
                           24, 'UNDO', 25, 'IMPLEMENTATION',
                           26, 'UNDO', 27, 'IMPLEMENTATION',
                           'UNKNOWN'), 
         decode(a.command,
                3,  'CREATE MATERIALIZED VIEW ' || a.attr1 ||
                    ' ' || a.attr6 || ' ' || a.attr3 || ' ' ||
                    a.attr4 || ' AS ' || a.attr5,
                4,  'CREATE MATERIALIZED VIEW LOG ON ' || a.attr1 ||
                    ' WITH ' || a.attr3 || ' ' || a.attr5 || ' ' ||
                    a.attr4,
                18, 'DROP MATERIALIZED VIEW ' || a.attr1 || ' ' || a.attr5,
                23, 'CREATE MATERIALIZED VIEW ' || a.attr1 ||
                    ' ' || a.attr6 || ' ' || a.attr3 || ' ' ||
                    a.attr4 || ' AS ' || a.attr5,
                24, 'DROP MATERIALIZED VIEW ' || a.attr1 || ' ' || a.attr5,
                25, 'DBMS_ADVANCED_REWRITE.BUILD_SAFE_REWRITE_EQUIVALENCE (''' ||
                    a.attr1 || ''',''' || a.attr5 || ''',''' || a.attr6 ||
                    ''',' || a.attr2 || ')',
                26, 'DBMS_ADVANCED_REWRITE.DROP_REWRITE_EQUIVALENCE(''' ||
                    a.attr1 || ''')' || a.attr5,
                27, 'ALTER MATERIALIZED VIEW LOG FORCE ON ' || a.attr1 ||
                    ' ADD ' || a.attr3 || ' ' || a.attr5 || ' ' ||
                    a.attr4,
                    a.attr5)
    FROM sys.wri$_adv_actions a, sys.wri$_adv_tasks t
    WHERE a.task_id = t.id;

CREATE OR replace PUBLIC synonym dba_tune_mview FOR sys.dba_tune_mview;
GRANT SELECT ON dba_tune_mview TO select_catalog_role;

comment ON TABLE dba_tune_mview IS
  'Catalog View to show the result after executing TUNE_MVIEW() API';
comment ON column dba_tune_mview.owner IS 'Owner of the task';
comment ON column dba_tune_mview.task_name IS 'Name of the task';
comment ON column dba_tune_mview.script_type IS 'Type of the script';
comment ON column dba_tune_mview.task_name IS 'ID of the action';
comment ON column dba_tune_mview.statement IS 'Action statement';

CREATE OR replace VIEW user_tune_mview
  (task_name, action_id, script_type, statement)
  AS
  SELECT t.name, a.id,
         decode(a.command, 3, 'IMPLEMENTATION', 4, 'IMPLEMENTATION', 
                           18, 'UNDO', 23, 'IMPLEMENTATION',
                           24, 'UNDO', 25, 'IMPLEMENTATION',
                           26, 'UNDO', 27, 'IMPLEMENTATION',
                           'UNKNOWN'),
         decode(a.command, 
                3,  'CREATE MATERIALIZED VIEW ' || a.attr1 ||
                    ' ' || a.attr6 || ' ' || a.attr3 || ' ' ||
                    a.attr4 || ' AS ' || a.attr5,
                4,  'CREATE MATERIALIZED VIEW LOG ON ' || a.attr1 ||
                    ' WITH ' || a.attr3 || ' ' || a.attr5 || ' ' ||
                    a.attr4,
                18, 'DROP MATERIALIZED VIEW ' || a.attr1 || ' ' || a.attr5,
                23, 'CREATE MATERIALIZED VIEW ' || a.attr1 ||
                    ' ' || a.attr6 || ' ' || a.attr3 || ' ' ||
                    a.attr4 || ' AS ' || a.attr5,
                24, 'DROP MATERIALIZED VIEW ' || a.attr1 || ' ' || a.attr5,
                25, 'DBMS_ADVANCED_REWRITE.BUILD_SAFE_REWRITE_EQUIVALENCE (''' ||
                    a.attr1 || ''',''' || a.attr5 || ''',''' || a.attr6 || 
                    ''',' || a.attr2 || ')',
                26, 'DBMS_ADVANCED_REWRITE.DROP_REWRITE_EQUIVALENCE(''' ||
                    a.attr1 || ''')' || a.attr5,
                27, 'ALTER MATERIALIZED VIEW LOG FORCE ON ' || a.attr1 ||
                    ' ADD ' || a.attr3 || ' ' || a.attr5 || ' ' ||
                    a.attr4,
                    a.attr5)
    FROM sys.wri$_adv_actions a, sys.wri$_adv_tasks t
    WHERE a.task_id = t.id
    AND t.owner# = userenv('SCHEMAID');

CREATE OR replace PUBLIC synonym user_tune_mview FOR sys.user_tune_mview;
GRANT SELECT ON user_tune_mview TO public;

comment ON TABLE user_tune_mview IS
  'tune_mview catalog view owned by the user';
comment ON column user_tune_mview.task_name IS 'Name of the task';
comment ON column user_tune_mview.task_name IS 'ID of the action';
comment ON column dba_tune_mview.script_type IS 'Type of the script';
comment ON column user_tune_mview.statement IS 'Action statement';

