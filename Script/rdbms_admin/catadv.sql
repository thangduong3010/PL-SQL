Rem
Rem $Header: rdbms/admin/catadv.sql /main/51 2009/07/01 19:21:05 pbelknap Exp $
Rem
Rem catadv.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catadv.sql - Advisor Framework definitions
Rem
Rem    DESCRIPTION
Rem      This file creates the following components for the advisor framework
Rem        - types
Rem        - tables, indexes
Rem        - views
Rem        - loads the pl/sql packages
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    hayu        03/19/09 - add plan hash 2
Rem    pbelknap    03/05/09 - #7916459: materialize io read requests / io write
Rem                           requests
Rem    hayu        10/21/08 - add fix regression plans
Rem    hayu        06/25/08 - add parallel plans to dba_advisor_sqlplans
Rem    ushaft      08/18/08 - add column to dba_addm_findings
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    kyagoub     05/11/08 - add new columns to support sage
Rem    hayu        04/09/08 - add a column to dba_advisor_sqlstats
Rem    akini       01/02/08 - modified views on wri$_adv_objects to get
Rem                           sql text (attr4) from wrh$_sqltext for addm
Rem    kyagoub     06/05/07 - rename spa advisor: change stat column names
Rem    pbelknap    06/02/07 - add user i/o time to qksctxExeSt
Rem    pbelknap    05/24/07 - resource consumption tracking - hide plans from
Rem                           views
Rem    kyagoub     04/13/07 - bug#5981178: add sql_id column to
Rem                           dba_advisor_sqlplans
Rem    pbelknap    02/20/07 - add execution id
Rem    pbelknap    12/01/06 - add flags to findings
Rem    kyagoub     12/28/06 - add advisor_name to dba_advisor_usage
Rem    ushaft      11/29/06 - fundction describe_directive changed packages
Rem    ushaft      08/31/06 - add DBA_ADDM_DIRECTIVES views
Rem    pbelknap    10/09/06 - add status# to dba/user_advisor_executions
Rem    kyagoub     06/22/06 - add a raw type attribute to the object table 
Rem    kyagoub     06/09/06 - move dba/user_sqltune_views to advisor frmwrk 
Rem    ushaft      04/28/06 - change to dba_advisor_findings message
Rem                           new dba_advisor_inst_fdg views
Rem                           new dba_addm* views
Rem    gssmith     05/03/06 - 11g directives 
Rem    pbelknap    04/05/06 - system task only parameters 
Rem    kyagoub     04/10/06 - add support for multi-executions 
Rem    bkuchibh    03/28/06 - modify view name 
Rem    ushaft      03/23/06 - add ID column to dba_adv_finding_names
Rem    bkuchibh    03/14/05 - Fix Bug 4113632 
Rem    kyagoub     10/10/04 - add other column to advisor objects view 
Rem    gssmith     02/05/04 - Change journal keywords 
Rem    gssmith     01/29/04 - Adding flags to wri$_adv_recommendations 
Rem    kdias       01/08/04 - 'add new finding type' 
Rem    ushaft      11/25/03 - Finish bug 3207351 -  
Rem                           add column advisor_id to view dba_advisor_tasks 
Rem    gssmith     11/05/03 - 
Rem    gssmith     10/23/03 - Bug 3207351 
Rem    kdias       10/09/03 - use user$ instead of all_users 
Rem    gssmith     09/23/03 - Expose flags in DEF_PARAMETERS view 
Rem    gssmith     10/06/03 - Add Access Advisor hidden actions 
Rem    kyagoub     05/03/03 - remove message from recommendation and 
Rem                           add type to rationale
Rem    kyagoub     03/27/03 - extend finding type, add news attributes to the 
Rem                           rationale table and grant user_xxx to public
Rem    kyagoub     03/17/03 - add recommendation type
Rem    bdagevil    04/28/03 - merge new file
Rem    gssmith     05/01/03 - AA workload adjustments
Rem    gssmith     04/15/03 - 
Rem    gssmith     04/15/03 - Change Mode
Rem    gssmith     04/10/03 - Move static data inserts from catadvtb
Rem    gssmith     03/26/03 - Bug 2869857
Rem    gssmith     02/21/03 - Bug 2815817
Rem    kdias       03/12/03 - modify advisor_usage view
Rem    ushaft      03/07/03 - changed definitions of views over parameters to
Rem                           support new flags
Rem    gssmith     01/30/03 - Fix user view privs
Rem    gssmith     01/29/03 - Typo in USER_ADVISOR_LOG view
Rem    gssmith     01/09/03 - Bug 2657007
Rem    gssmith     11/27/02 - Add new column to actions table
Rem    gssmith     11/12/02 - Fix log table
Rem    kdias       10/31/02 - modify findings, rec view
Rem    gssmith     10/23/02 - Bugs
Rem    gssmith     10/22/02 - Add task_name to views
Rem    gssmith     10/18/02 - Bug 2631064
Rem    btao        10/03/02 - add select_catalog_role
Rem    kdias       10/03/02 - modify adv_commands defn
Rem    kdias       09/30/02 - modify view defns to reflect new cols
Rem    kdias       09/24/02 - remove type from advisor definition
Rem    gssmith     09/20/02 - remove task type
Rem    gssmith     09/13/02 - Adding templates
Rem    gssmith     09/05/02 - gssmith_adv0806
Rem    gssmith     09/04/02 - wip
Rem    gssmith     08/30/02 - 
Rem    gssmith     08/29/02 - wip
Rem    gssmith     08/23/02 - wip
Rem    gssmith     08/19/02 - clean up views
Rem    kdias       07/26/02 - add views
Rem    kdias       07/19/02 - more schema changes.
Rem    kdias       06/11/02 - Created
Rem

Rem
Rem The initial part of this file is for Framework definitions only.
Rem Individual advisors can add their type declarations at the end just
Rem before the tabels are populated.
Rem
 

create or replace view dba_advisor_definitions
   as select id as advisor_id,
             name as advisor_name,
             property as property
      from wri$_adv_definitions
      where id > 0;

create or replace public synonym dba_advisor_definitions
   for sys.dba_advisor_definitions;
grant select on dba_advisor_definitions to select_catalog_role;

create or replace view dba_advisor_commands
   as select a.indx as command_id,
             a.command_name as command_name
      from x$keacmdn a;

create or replace public synonym dba_advisor_commands
   for sys.dba_advisor_commands;
grant select on dba_advisor_commands to select_catalog_role;

create or replace view dba_advisor_object_types
   as select a.indx as object_type_id,
             a.object_type as object_type
      from x$keaobjt a;

create or replace public synonym dba_advisor_object_types
   for sys.dba_advisor_object_types;

create or replace view dba_advisor_usage
  as select a.advisor_id,
            d.name as advisor_name,
            a.last_exec_time,
            a.num_execs,
            a.num_db_reports,
            a.first_report_time,
            a.last_report_time
     from sys.wri$_adv_usage a, sys.wri$_adv_definitions d 
     where a.advisor_id = d.id and a.advisor_id > 0;

create or replace public synonym dba_advisor_usage
   for sys.dba_advisor_usage;
grant select on dba_advisor_usage to select_catalog_role;

create or replace view dba_advisor_execution_types
  as select d.name advisor_name, e.name execution_type, 
            dbms_advisor.format_message(e.description) execution_description
  from wri$_adv_definitions d, wri$_adv_def_exec_types e
  where d.id = e.advisor_id; 

create or replace public synonym dba_advisor_execution_types
   for sys.dba_advisor_execution_types;
grant select on dba_advisor_execution_types to select_catalog_role;

create or replace view dba_advisor_tasks
   as select a.owner_name as owner,
             a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.parent_id as parent_task_id,
             a.parent_rec_id as parent_rxec_id,
             a.last_exec_name as last_execution,
             e.exec_type as execution_type,
             e.exec_type_id as execution_type#,
             e.description as execution_description,
             nvl(e.exec_start, a.exec_start) as execution_start,
             nvl(e.exec_end, a.exec_end) as execution_end,
             decode(nvl(e.status, a.status), 
                    1, 'INITIAL',
                    2, 'EXECUTING',
                    3, 'COMPLETED',
                    4, 'INTERRUPTED',
                    5, 'CANCELLED',
                    6, 'FATAL ERROR') as status,
             dbms_advisor.format_message_group(
               nvl(e.status_msg_id, a.status_msg_id)) as status_message,
             a.pct_completion_time as pct_completion_time,
             a.progress_metric as progress_metric,
             a.metric_units as metric_units,
             a.activity_counter as activity_counter,
             a.rec_count as recommendation_count,
             dbms_advisor.format_message_group(
               nvl(e.error_msg_id, a.error_msg#)) as error_message,
             a.source as source,
             a.how_created as how_created,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only,
             decode(bitand(a.property,32), 32, 'TRUE', 'FALSE') as system_task,
             a.advisor_id as advisor_id,
             nvl(e.status, a.status) as status#
      from wri$_adv_tasks a, wri$_adv_executions e
      where a.id = e.task_id(+) 
        and a.advisor_id = e.advisor_id(+)
        and a.last_exec_name = e.name(+)
        and bitand(a.property, 6) = 4;

create or replace public synonym dba_advisor_tasks
   for dba_advisor_tasks;
grant select on dba_advisor_tasks to select_catalog_role;

create or replace view user_advisor_tasks
   as select a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.parent_id as parent_task_id,
             a.parent_rec_id as parent_rec_id,
             a.last_exec_name as last_execution,
             e.exec_type as execution_type,
             nvl(e.exec_start, a.exec_start) as execution_start,
             nvl(e.exec_end, a.exec_end) as execution_end,
             decode(nvl(e.status, a.status), 
                    1, 'INITIAL',
                    2, 'EXECUTING',
                    3, 'COMPLETED',
                    4, 'INTERRUPTED',
                    5, 'CANCELLED',
                    6, 'FATAL ERROR') as status,
             dbms_advisor.format_message_group(
               nvl(e.status_msg_id, a.status_msg_id)) as status_message,
             a.pct_completion_time as pct_completion_time,
             a.progress_metric as progress_metric,
             a.metric_units as metric_units,
             a.activity_counter as activity_counter,
             a.rec_count as recommendation_count,
             dbms_advisor.format_message_group(
               nvl(e.error_msg_id, a.error_msg#)) as error_message,
             a.source as source,
             a.how_created as how_created,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only,
             decode(bitand(a.property,32), 32, 'TRUE', 'FALSE') as system_task,
             a.advisor_id as advisor_id,
             nvl(e.status, a.status) as status#
      from wri$_adv_tasks a, wri$_adv_executions e
      where a.id = e.task_id(+) 
        and a.last_exec_name = e.name(+)
        and a.advisor_id = e.advisor_id(+)
        and a.owner# = userenv('SCHEMAID')
        and bitand(a.property, 6) = 4;

create or replace public synonym user_advisor_tasks
   for user_advisor_tasks;
grant select on user_advisor_tasks to public;


create or replace view dba_advisor_templates
   as select a.owner_name as owner,
             a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.source as source,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only
      from wri$_adv_tasks a
      where bitand(a.property,6) = 6;

create or replace public synonym dba_advisor_templates
   for dba_advisor_templates;
grant select on dba_advisor_templates to select_catalog_role;

create or replace view user_advisor_templates
   as select a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.source as source,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only
      from wri$_adv_tasks a
      where a.owner# = userenv('SCHEMAID')
        and bitand(a.property,6) = 6;

create or replace public synonym user_advisor_templates
   for user_advisor_templates;
grant select on user_advisor_templates to public;

create or replace view dba_advisor_log as 
  select a.owner_name as owner,
         a.id as task_id,
         a.name as task_name,
         nvl(e.exec_start, a.exec_start) as execution_start,
         nvl(e.exec_end, a.exec_end) as execution_end,
         decode(nvl(e.status, a.status), 
                1, 'INITIAL',
                2, 'EXECUTING',
                3, 'COMPLETED',
                4, 'INTERRUPTED',
                5, 'CANCELLED',
                6, 'FATAL ERROR') as status,
         dbms_advisor.format_message_group(
           nvl(e.status_msg_id, a.status_msg_id)) as status_message,
         a.pct_completion_time as pct_completion_time,
         a.progress_metric as progress_metric,
         a.metric_units as metric_units,
         a.activity_counter as activity_counter,
         a.rec_count as recommendation_count,
         dbms_advisor.format_message_group(
           nvl(e.error_msg_id, a.error_msg#)) as error_message
  from wri$_adv_tasks a, wri$_adv_executions e
      where a.id = e.task_id(+) 
        and a.advisor_id = e.advisor_id(+)
        and a.last_exec_name = e.name(+)
        and bitand(a.property,6) = 4;

create or replace public synonym dba_advisor_log
   for dba_advisor_log;
grant select on dba_advisor_log to select_catalog_role;
      
create or replace view user_advisor_log as 
  select a.id as task_id,
         a.name as task_name,
         nvl(e.exec_start, a.exec_start) as execution_start,
         nvl(e.exec_end, a.exec_end) as execution_end,
         decode(nvl(e.status, a.status), 
                1, 'INITIAL',
                2, 'EXECUTING',
                3, 'COMPLETED',
                4, 'INTERRUPTED',
                5, 'CANCELLED',
                6, 'FATAL ERROR') as status,
         dbms_advisor.format_message_group(
           nvl(e.status_msg_id, a.status_msg_id)) as status_message,
         a.pct_completion_time as pct_completion_time,
         a.progress_metric as progress_metric,
         a.metric_units as metric_units,
         a.activity_counter as activity_counter,
         a.rec_count as recommendation_count,
         dbms_advisor.format_message_group(
           nvl(e.error_msg_id, a.error_msg#)) as error_message
  from wri$_adv_tasks a, wri$_adv_executions e
      where a.id = e.task_id(+) 
        and a.last_exec_name = e.name(+)
        and a.advisor_id = e.advisor_id(+)
        and a.owner# = userenv('SCHEMAID')
        and bitand(a.property, 6) = 4;

create or replace public synonym user_advisor_log
   for user_advisor_log;
grant select on user_advisor_log to public;

create or replace view dba_advisor_def_parameters
   as select b.name as advisor_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             decode(bitand(a.flags,16), 0, 'N', 'Y') as is_system_task_only,
             dbms_advisor.format_message(a.description) as description,
             a.exec_type execution_type 
      from wri$_adv_def_parameters a, wri$_adv_definitions b
      where a.advisor_id = b.id
        and bitand(a.flags,1) = 0;

create or replace public synonym dba_advisor_def_parameters
   for dba_advisor_def_parameters;
grant select on dba_advisor_def_parameters to select_catalog_role;

create or replace view dba_advisor_parameters
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description,
             c.exec_type execution_type 
      from wri$_adv_parameters a, wri$_adv_tasks b, wri$_adv_def_parameters c
      where a.task_id = b.id
        and a.name = c.name
        and (b.advisor_id = c.advisor_id or c.advisor_id = 0)
        and bitand(b.property,4) = 4        /* task property */
        and bitand(a.flags,1) = 0           /* invisible parameter */
        and (bitand(b.property, 32) = 32 or /* system task only parameter */ 
             bitand(c.flags, 16)    = 0);

create or replace public synonym dba_advisor_parameters
   for dba_advisor_parameters;
grant select on dba_advisor_parameters to select_catalog_role;

create or replace view user_advisor_parameters
   as select a.task_id as task_id,
             b.name as task_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description,
             d.exec_type execution_type 
      from wri$_adv_parameters a, wri$_adv_tasks b, wri$_adv_def_parameters d
      where a.task_id = b.id
        and a.name = d.name
        and b.owner# = userenv('SCHEMAID')
        and (b.advisor_id = d.advisor_id or d.advisor_id = 0)
        and bitand(b.property,4) = 4        /* task property */
        and bitand(a.flags,1) = 0           /* invisible parameter */
        and (bitand(b.property, 32) = 32 or /* system task only parameter */ 
             bitand(d.flags, 16)    = 0);

create or replace public synonym user_advisor_parameters
   for user_advisor_parameters;
grant select on user_advisor_parameters to public;

create or replace view dba_advisor_parameters_proj
   as select a.task_id as task_id,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             decode(bitand(a.flags,16), 0, 'N', 'Y') as is_system_task_only,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a;

create or replace public synonym dba_advisor_parameters_proj
   for dba_advisor_parameters_proj;
grant select on dba_advisor_parameters_proj to select_catalog_role;

create or replace view dba_advisor_executions
  as select t.owner_name   as owner,
            t.id           as task_id,
            t.name         as task_name,
            e.name         as execution_name,
            e.id           as execution_id,
            e.description  as description,
            e.exec_type    as execution_type,
            e.exec_type_id as execution_type#, 
            e.exec_start   as execution_start,
            e.exec_mtime   as execution_last_modified,
            e.exec_end     as execution_end,
            t.advisor_name as advisor_name, 
            e.advisor_id   as advisor_id,
            decode(e.status, 2, 'EXECUTING',
                             3, 'COMPLETED',
                             4, 'INTERRUPTED',
                             5, 'CANCELLED',
                             6, 'FATAL ERROR') as status,
            e.status       as status#,
            nvl2(e.status_msg_id, 
                 dbms_advisor.format_message_group(e.status_msg_id),
                 NULL) as status_message,
            nvl2(e.error_msg_id,
                 dbms_advisor.format_message_group(e.error_msg_id),
                 NULL) as error_message
     from wri$_adv_executions e, wri$_adv_tasks t
     where e.task_id = t.id and e.advisor_id = t.advisor_id;

create or replace public synonym dba_advisor_executions
   for dba_advisor_executions;
grant select on dba_advisor_executions to select_catalog_role;

create or replace view user_advisor_executions
  as select t.id           as task_id,
            t.name         as task_name,
            e.name         as execution_name,
            e.id           as execution_id,
            e.description  as description,
            e.exec_type    as execution_type, 
            e.exec_start   as execution_start,
            e.exec_mtime   as execution_last_modified,
            e.exec_end     as execution_end,
            t.advisor_name as advisor_name, 
            e.advisor_id   as advisor_id,
            decode(e.status, 2, 'EXECUTING',
                             3, 'COMPLETED',
                             4, 'INTERRUPTED',
                             5, 'CANCELLED',
                             6, 'FATAL ERROR') as status,
            e.status       as status#,
            nvl2(e.status_msg_id, 
                 dbms_advisor.format_message_group(e.status_msg_id),
                 NULL) as status_message,
            nvl2(e.error_msg_id,
                 dbms_advisor.format_message_group(e.error_msg_id),
                 NULL) as error_message
     from wri$_adv_executions e, wri$_adv_tasks t
     where e.task_id = t.id and e.advisor_id = t.advisor_id and 
           t.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_executions
  for user_advisor_executions;
grant select on user_advisor_executions to public;

create or replace view dba_advisor_exec_parameters
   as select owner, tp.task_id, task_name, execution_name, execution_type, 
             parameter_name,  nvl(ep.value, tp.value) as parameter_value,
             parameter_type, is_default, is_output, is_modifiable_anytime,
             tp.description, parameter_flags, parameter_type#
      from   (select t.owner_name as owner, t.id as task_id,
               t.name as task_name, e.name as execution_name, 
               p.name as parameter_name, p.value,
               decode(d.datatype, 1, 'NUMBER',
                                  2, 'STRING',
                                  3, 'STRINGLIST',
                                  4, 'TABLE',
                                  5, 'TABLELIST',
                                  'UNKNOWN') as parameter_type,
               d.datatype as parameter_type#,
               decode(bitand(d.flags, 2), 0, 'Y', 'N') as is_default,
               decode(bitand(d.flags, 4), 0, 'N', 'Y') as is_output,
               decode(bitand(d.flags, 8), 0, 'N', 'Y') as is_modifiable_anytime,
               dbms_advisor.format_message(d.description) as description,
               d.exec_type as execution_type,
               d.flags as parameter_flags  
             from wri$_adv_parameters p, 
                  wri$_adv_tasks t, 
                  wri$_adv_def_parameters d,
                  wri$_adv_executions e
             where p.task_id = t.id
               and bitand(t.property, 4) = 4       /* task property */
               and bitand(d.flags, 1) = 0          /* invisible parameter */
               and (bitand(t.property, 32) = 32 or /* system task only prm */
                    bitand(d.flags, 16) = 0)
               and p.name = d.name
               and (t.advisor_id = d.advisor_id or d.advisor_id = 0)
               and e.task_id = p.task_id) tp,
              wri$_adv_exec_parameters ep
      where tp.task_id = ep.task_id (+)
        and tp.parameter_name = ep.name (+)
        and tp.execution_name = ep.exec_name (+);

create or replace public synonym dba_advisor_exec_parameters
   for dba_advisor_exec_parameters;
grant select on dba_advisor_exec_parameters to select_catalog_role;


create or replace view user_advisor_exec_parameters
   as select tp.task_id, task_name, execution_name, execution_type, 
             parameter_name,  nvl(ep.value, tp.value) as parameter_value,
             parameter_type, is_default, is_output, is_modifiable_anytime,
             tp.description, parameter_flags, parameter_type#
      from   (select t.owner_name as owner, t.id as task_id,
               t.name as task_name, e.name as execution_name, 
               p.name as parameter_name, p.value,
               decode(d.datatype, 1, 'NUMBER',
                                  2, 'STRING',
                                  3, 'STRINGLIST',
                                  4, 'TABLE',
                                  5, 'TABLELIST',
                                  'UNKNOWN') as parameter_type,
               d.datatype as parameter_type#,
               decode(bitand(d.flags, 2), 0, 'Y', 'N') as is_default,
               decode(bitand(d.flags, 4), 0, 'N', 'Y') as is_output,
               decode(bitand(d.flags, 8), 0, 'N', 'Y') as is_modifiable_anytime,
               dbms_advisor.format_message(d.description) as description,
               d.exec_type as execution_type,
               d.flags as parameter_flags  
             from wri$_adv_parameters p, 
                  wri$_adv_tasks t, 
                  wri$_adv_def_parameters d,
                  wri$_adv_executions e
             where p.task_id = t.id
               and bitand(t.property, 4) = 4       /* task property */
               and bitand(d.flags, 1) = 0          /* invisible parameter */
               and (bitand(t.property, 32) = 32 or /* system task only prm */
                    bitand(d.flags, 16) = 0)
               and p.name = d.name
               and (t.advisor_id = d.advisor_id or d.advisor_id = 0)
               and e.task_id = p.task_id
               and t.owner# = userenv('SCHEMAID')) tp,
              wri$_adv_exec_parameters ep
      where tp.task_id = ep.task_id (+)
        and tp.parameter_name = ep.name (+)
        and tp.execution_name = ep.exec_name (+);

create or replace public synonym user_advisor_exec_parameters
  for user_advisor_exec_parameters;
grant select on user_advisor_exec_parameters to public;


-- addm advisor uses sqltext from wrh$_sqltext while analyzing local databases
-- so view definition uses case stmt for attr4 to fetch the right copy of sqltext
create or replace view dba_advisor_objects
  as select b.owner_name as owner,
            a.id as object_id,
            d.object_type as type,
            a.type as type_id,
            a.task_id as task_id,
            b.name as task_name,
            a.exec_name as execution_name,
            a.attr1 as attr1,
            a.attr2 as attr2,
            a.attr3 as attr3,
            (case                                  
               when b.advisor_id = 1 and  
                    a.type = 7 and 
                    length(attr4) = 1 and       /* attr4 has ' ' as default val */
                    a.attr1 is not null
               then (select nvl(sql_text, ' ')  /* backwards compat w/ tests */
                     from wrh$_sqltext s, wri$_adv_addm_tasks t
                         where t.task_id = a.task_id       
                           and s.dbid(+) = t.dbid 
                           and s.sql_id(+) = a.attr1)
               else a.attr4
             end) as attr4,
            a.attr5 as attr5,
            a.attr6 as attr6,
            a.attr7 as attr7,
            a.attr8 as attr8,
            a.attr9 as attr9,
            a.attr10 as attr10,
            a.other as other
      from wri$_adv_objects a, wri$_adv_tasks b,x$keaobjt d
      where a.task_id = b.id
        and d.indx = a.type;

create or replace public synonym dba_advisor_objects
  for dba_advisor_objects;
grant select on dba_advisor_objects to select_catalog_role;
 
-- addm advisor uses sqltext from wrh$_sqltext while analyzing local databases
-- so view definition uses case stmt for attr4 to fetch the right copy of sqltext
create or replace view user_advisor_objects
  as select a.id as object_id,
            c.object_type as type,
            a.type as type_id,
            a.task_id as task_id,
            b.name as task_name,
            a.exec_name as execution_name,
            a.attr1 as attr1,
            a.attr2 as attr2,
            a.attr3 as attr3,
            (case            
               when b.advisor_id = 1 and  
                    a.type = 7 and 
                    length(attr4) = 1 and       /* attr4 has ' ' as default val */
                    a.attr1 is not null
               then (select nvl(sql_text, ' ')  /* backwards compat w/ tests */
                     from wrh$_sqltext s, wri$_adv_addm_tasks t
                         where t.task_id = a.task_id       
                           and s.dbid(+) = t.dbid 
                           and s.sql_id(+) = a.attr1)
               else a.attr4
             end) as attr4,
            a.attr5 as attr5,
            a.attr6 as attr6,
            a.attr7 as attr7,
            a.attr8 as attr8,
            a.attr9 as attr9,
            a.attr10 as attr10,
            a.other as other
      from wri$_adv_objects a, wri$_adv_tasks b, x$keaobjt c
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and c.indx = a.type;

create or replace public synonym user_advisor_objects
  for user_advisor_objects;
grant select on user_advisor_objects to public;


create or replace view dba_advisor_findings
  as select b.owner_name as owner,
            a.task_id as task_id,    
            b.name as task_name,
            a.exec_name as execution_name,
            a.id as finding_id,
            dbms_advisor.format_message(a.name_msg_code) as finding_name,
            decode (a.type, 1, 'PROBLEM', 
                            2, 'SYMPTOM', 
                            3, 'ERROR',
                            4, 'INFORMATION',
                            5, 'WARNING')  as type,
            a.type as type_id,
            a.parent as parent,
            a.obj_id as object_id,
            dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
            a.impact_val as impact,
            dbms_advisor.format_message_group(a.msg_id, a.type) as message,
            dbms_advisor.format_message_group(a.more_info_id) as more_info,
            nvl(a.filtered, 'N') as filtered,
            a.flags as flags
    from wri$_adv_findings a, wri$_adv_tasks b
    where a.task_id = b.id
        and bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_findings
  for dba_advisor_findings;
grant select on dba_advisor_findings to select_catalog_role;
 
create or replace view user_advisor_findings
  as select a.task_id as task_id,
            b.name as task_name,
            a.exec_name as execution_name,
            a.id as finding_id,
            dbms_advisor.format_message(a.name_msg_code) as finding_name,
            decode (a.type,
                    1, 'PROBLEM',
                    2, 'SYMPTOM',
                    3, 'ERROR',
                    4, 'INFORMATION',
                    5, 'WARNING')  as type,
            a.type as type_id,
            a.parent as parent,    
            a.obj_id as object_id,
            dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
            a.impact_val as impact,
            dbms_advisor.format_message_group(a.msg_id, a.type) as message,
            dbms_advisor.format_message_group(a.more_info_id) as more_info,
            nvl(a.filtered, 'N') as filtered,
            a.flags as flags
    from wri$_adv_findings a, wri$_adv_tasks b
    where a.task_id = b.id
      and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4;

create or replace public synonym user_advisor_findings
  for user_advisor_findings;
grant select on user_advisor_findings to public;

create or replace view dba_advisor_fdg_breakdown
   as select a.task_id as task_id,
             a.finding_id as finding_id,
             a.instance_number as instance_number,
             f.impact as impact,
             a.perc_impact as perc_impact,
             a.exec_name as execution_name
      from  wri$_adv_inst_fdg a, dba_advisor_findings f
      where a.task_id = f.task_id
        and a.finding_id = f.finding_id;

create or replace public synonym dba_advisor_fdg_breakdown
   for dba_advisor_fdg_breakdown;
grant select on dba_advisor_fdg_breakdown to select_catalog_role;

create or replace view user_advisor_fdg_breakdown
   as select a.task_id as task_id,
             a.finding_id as finding_id,
             a.instance_number as instance_number,
             f.impact as impact,
             a.perc_impact as perc_impact,
             a.exec_name as execution_name
      from  wri$_adv_inst_fdg a, user_advisor_findings f
      where a.task_id = f.task_id
        and a.finding_id = f.finding_id;

create or replace public synonym user_advisor_fdg_breakdown
   for user_advisor_fdg_breakdown;
grant select on user_advisor_fdg_breakdown to public;


create or replace view dba_advisor_recommendations
  as select b.owner_name as owner,
            a.id as rec_id,
            a.task_id as task_id,
            b.name as task_name,
            a.exec_name as execution_name,
            a.finding_id as finding_id,
            a.type,
            a.rank as rank,
            a.parent_recs as parent_rec_ids,
            dbms_advisor.format_message_group(a.benefit_msg_id) as benefit_type,
            a.benefit_val as benefit,
            decode(annotation, 1, 'ACCEPT',
                               2, 'REJECT',
                               3, 'IGNORE',
                               4, 'IMPLEMENTED') as annotation_status,
            a.flags as flags,
            nvl(a.filtered, 'N') as filtered
     from wri$_adv_recommendations a, wri$_adv_tasks b
     where a.task_id = b.id and 
          bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_recommendations
   for dba_advisor_recommendations;
grant select on dba_advisor_recommendations to select_catalog_role;
             
create or replace view user_advisor_recommendations
  as select a.id as rec_id,
            a.task_id as task_id,
            b.name as task_name,
            a.exec_name as execution_name,
            a.finding_id as finding_id,
            a.type,
            a.rank as rank,
            a.parent_recs as parent_rec_ids,
            dbms_advisor.format_message_group(a.benefit_msg_id) as benefit_type,
            a.benefit_val as benefit,
            decode(annotation, 1, 'ACCEPT',
                               2, 'REJECT',
                               3, 'IGNORE',
                               4, 'IMPLEMENTED') as annotation_status,
            a.flags as flags,
            nvl(a.filtered, 'N') as filtered
     from wri$_adv_recommendations a, wri$_adv_tasks b
     where a.task_id = b.id and 
           b.owner# = userenv('SCHEMAID') and 
           bitand(b.property,6) = 4;

create or replace public synonym user_advisor_recommendations
   for user_advisor_recommendations;
grant select on user_advisor_recommendations to public;

create or replace view dba_advisor_actions
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
             d.rec_id as rec_id,
             a.id as action_id,
             a.obj_id as object_id,
             c.command_name as command,
             a.command as command_id,
             a.flags as flags,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5,
             a.attr6 as attr6,
             a.num_attr1 as num_attr1,
             a.num_attr2 as num_attr2,
             a.num_attr3 as num_attr3,
             a.num_attr4 as num_attr4,
             a.num_attr5 as num_attr5,
             dbms_advisor.format_message_group(a.msg_id) as message,
             nvl(a.filtered, 'N') as filtered
      from wri$_adv_actions a, wri$_adv_tasks b, x$keacmdn c,
           wri$_adv_rec_actions d
      where a.task_id = b.id
        and a.command = c.indx
        and d.task_id = a.task_id 
        and d.act_id = a.id
        and bitand(b.property,6) = 4
        and ((b.advisor_id = 2 and bitand(a.flags,2048) = 0) or
             (b.advisor_id <> 2));

create or replace public synonym dba_advisor_actions
   for dba_advisor_actions;
grant select on dba_advisor_actions to select_catalog_role;

create or replace view user_advisor_actions
   as select a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
             d.rec_id as rec_id,
             a.id as action_id,
             a.obj_id as object_id,
             c.command_name as command,
             a.command as command_id,
             a.flags as flags,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5,
             a.attr6 as attr6,
             a.num_attr1 as num_attr1,
             a.num_attr2 as num_attr2,
             a.num_attr3 as num_attr3,
             a.num_attr4 as num_attr4,
             a.num_attr5 as num_attr5,
             dbms_advisor.format_message_group(a.msg_id) as message,
             nvl(a.filtered, 'N') as filtered
      from wri$_adv_actions a, wri$_adv_tasks b, x$keacmdn c,
           wri$_adv_rec_actions d
      where a.task_id = b.id
        and a.command = c.indx
        and d.task_id = a.task_id 
        and d.act_id = a.id
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4
        and ((b.advisor_id = 2 and bitand(a.flags,2048) = 0) or
             (b.advisor_id <> 2));

create or replace public synonym user_advisor_actions
   for user_advisor_actions;
grant select on user_advisor_actions to public;

create or replace view dba_advisor_rationale
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
             a.rec_id as rec_id,
             a.id as rationale_id,
             dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
             a.impact_val as impact,
             dbms_advisor.format_message_group(a.msg_id) as message,
             a.obj_id as object_id,
             a.type,        
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_rationale a, wri$_adv_tasks b
      where a.task_id = b.id
        and bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_rationale
   for dba_advisor_rationale;
grant select on dba_advisor_rationale to select_catalog_role;
             
create or replace view user_advisor_rationale
   as select a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
             a.rec_id as rec_id,
             a.id as rationale_id,
             dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
             a.impact_val as impact,
             dbms_advisor.format_message_group(a.msg_id) as message,
             a.obj_id as object_id,
             a.type,             
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_rationale a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4;

create or replace public synonym user_advisor_rationale
   for user_advisor_rationale;
grant select on user_advisor_rationale to public;

create or replace view dba_advisor_dir_definitions
   as select a.id as id,
             a.advisor_id as advisor_id,
             b.name as advisor_name,
             a.name as directive_name,
             a.domain as domain_name,
             a.description as description, 
             a.type# as type,
             decode(a.type#,1,'Filter',2,'Single value',3,'Multiple Values',
                            4,'Conditional',5,'Constraint','Unknown') as type_name,
             decode(bitand(a.flags,1),1,'MUTABLE','IMMUTABLE') as task_status,
             decode(bitand(a.flags,2),2,'MULTIPLE','SINGLE') as instances,
             c.data as metadata
      from wri$_adv_directive_defs a, wri$_adv_definitions b, 
           wri$_adv_directive_meta c
      where a.advisor_id = b.id
        and a.metadata_id = c.id;
              
create or replace public synonym dba_advisor_dir_definitions
   for dba_advisor_dir_definitions;
grant select on dba_advisor_dir_definitions to select_catalog_role;

create or replace view dba_advisor_dir_instances
   as select a.dir_id as directive_id,
             a.inst_id as instance_id,
             a.name as instance_name,
             a.data as data
      from wri$_adv_directive_instances a
      where a.task_id = 0;

create or replace public synonym dba_advisor_dir_instances
   for dba_advisor_dir_instances;
grant select on dba_advisor_dir_instances to select_catalog_role;

create or replace view dba_advisor_dir_task_inst
   as select a.dir_id as directive_id,
             a.inst_id as seq_id,
             a.name as instance_name,
             d.name as username,
             a.task_id as task_id,
             b.name as task_name,
             a.data as data
      from wri$_adv_directive_instances a,wri$_adv_tasks b, user$ d
      where a.task_id = b.id 
        and d.user# = b.owner#;

create or replace public synonym dba_advisor_dir_task_inst
   for dba_advisor_dir_task_inst;
grant select on dba_advisor_dir_task_inst to select_catalog_role;

create or replace view user_advisor_dir_task_inst
   as select a.dir_id as directive_id,
             a.inst_id as instance_id,
             a.name as instance_name,
             a.task_id as task_id,
             b.name as task_name,
             a.data as data
      from wri$_adv_directive_instances a,wri$_adv_tasks b
      where a.task_id = b.id 
        and b.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_dir_task_inst
   for user_advisor_dir_task_inst;
grant select on user_advisor_dir_task_inst to select_catalog_role;

create or replace view dba_advisor_journal
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
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
        and bitand(b.property,4) = 4;

create or replace public synonym dba_advisor_journal
   for dba_advisor_journal;
grant select on dba_advisor_journal to select_catalog_role;
 
create or replace view user_advisor_journal
   as select a.task_id as task_id,
             b.name as task_name,
             a.exec_name as execution_name,
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
        and bitand(b.property,4) = 4
        and b.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_journal
   for user_advisor_journal;
grant select on user_advisor_journal to public;

create or replace view dba_advisor_finding_names
   as select a.id as id,
             d.name as advisor_name,
             dbms_advisor.format_message(a.finding_name) as finding_name
      from   (select rownum-1 as id, advisor_id, finding_name 
              from   x$keafdgn) a, 
             WRI$_ADV_DEFINITIONS d
      where  a.advisor_id = d.id; 

create or replace public synonym dba_advisor_finding_names
   for dba_advisor_finding_names;
grant select on dba_advisor_finding_names to select_catalog_role;

Rem The following views contain SQL related information. 
Rem These views become part of the advisor framework as there is
Rem more than one advisor client which is using them now, such as sqltune, 
Rem sqlpi, and sqldiag. 
Rem Initially, these views belonged to sqltune advisor and they
Rem used to be created in catsqltv.sql.
Rem all sql plans are new in 11g except the plan table which exists since
Rem 10gR1. The old sqltune view for plans is kept in catsqltv.sql for 
Rem backward compatibility. It should be deprecated in the future. 
Rem Here we duplicate its definition but we give it a more general name.

Rem The new columns AVERAGE_OVER_COUNT and FIRST_EXEC_IGNORED are introduced
Rem for multiple executions. It means that one SQL can be test executed
Rem multiple times for the purpose of accuracy and reducing the impact of 
Rem buffer cache. However these two columns will not have impact of other
Rem columns in the view. For example, the stats are still the ones over
Rem the number of "EXECUTIONS". AVERAGE_OVER_COUNT means the total number
Rem of executions have been done. FIRST_EXEC_IGNORED means that if the first
Rem execution of the statement has been ignored for warming the buffer cache.
-------------------------- view dba_advisor_sqlstats --------------------------
CREATE OR REPLACE view dba_advisor_sqlstats AS
  SELECT t.name task_name, p.TASK_ID, 
         exec_name EXECUTION_NAME, exec_type EXECUTION_TYPE, 
         OBJECT_ID, p.plan_id, p.sql_id, P.PLAN_HASH as plan_hash_value,
         p.spare_n1 as attr1,
         -- the time stats in the old version are in milliseconds. In the
         -- new code, we used a bit in "flags" to indicate that if the
         -- time stats are in microseconds in the new code. So if
         -- the flags are not set or NULL, we will need to convert them
         -- into microseconds.  
         decode(bitand(nvl(s.flags, 0),2), 2, parse_time, parse_time*1000) 
                as PARSE_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, exec_time, exec_time*1000) 
                as ELAPSED_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, cpu_time, cpu_time*1000) 
                as CPU_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, user_io_time, user_io_time*1000) 
                as USER_IO_TIME, 
         BUFFER_GETS, DISK_READS, DIRECT_WRITES, 
         s.spare_n1 PHYSICAL_READ_REQUESTS, s.spare_n2 PHYSICAL_WRITE_REQUESTS, 
         s.spare_n3 PHYSICAL_READ_BYTES, s.spare_n4 PHYSICAL_WRITE_BYTES,
         ROWS_PROCESSED, FETCHES, EXECUTIONS, 
         END_OF_FETCH_COUNT, OPTIMIZER_COST, OTHER, TESTEXEC_TOTAL_EXECS,
         io_interconnect_bytes,
         decode(bitand(s.flags,1), 1, 'Y', 'N') as TESTEXEC_FIRST_EXEC_IGNORED
  FROM   wri$_adv_sqlt_plan_hash p, 
         wri$_adv_sqlt_plan_stats s, 
         wri$_adv_executions e,
         wri$_adv_tasks t
  WHERE  p.plan_id = s.plan_id AND 
         p.exec_name = e.name AND 
         p.task_id = e.task_id AND
         p.task_id = t.id AND
         (p.attribute < power (2,16) OR
          p.attribute >= 3*power(2, 16)) /* hide special plans */;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_advisor_sqlstats
  FOR SYS.dba_advisor_sqlstats;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON dba_advisor_sqlstats to SELECT_CATALOG_ROLE;


---------------------------- view user_advisor_sqlstats -----------------------
CREATE OR REPLACE view user_advisor_sqlstats AS
  SELECT t.name task_name, p.TASK_ID, 
         exec_name EXECUTION_NAME, exec_type EXECUTION_TYPE, 
         OBJECT_ID, p.plan_id, p.sql_id, 
         p.PLAN_HASH as plan_hash_value,
         p.spare_n1 as attr1,
         -- the time stats in the old version are in milliseconds. In the
         -- new code, we used a bit in "flags" to indicate that if the
         -- time stats are in microseconds in the new code. So if
         -- the flags are not set or NULL, we will need to convert them
         -- into microseconds.  
         decode(bitand(nvl(s.flags, 0),2), 2, parse_time, parse_time*1000) 
                as PARSE_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, exec_time, exec_time*1000) 
                as ELAPSED_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, cpu_time, cpu_time*1000) 
                as CPU_TIME, 
         decode(bitand(nvl(s.flags, 0),2), 2, user_io_time, user_io_time*1000) 
                as USER_IO_TIME, 
         BUFFER_GETS, DISK_READS, DIRECT_WRITES, 
         s.spare_n1 PHYSICAL_READ_REQUESTS, s.spare_n2 PHYSICAL_WRITE_REQUESTS, 
         s.spare_n3 PHYSICAL_READ_BYTES, s.spare_n4 PHYSICAL_WRITE_BYTES,
         ROWS_PROCESSED, FETCHES, EXECUTIONS, 
         END_OF_FETCH_COUNT, OPTIMIZER_COST, OTHER, TESTEXEC_TOTAL_EXECS,
         io_interconnect_bytes,
         decode(bitand(s.flags,1), 1, 'Y', 'N') as TESTEXEC_FIRST_EXEC_IGNORED
  FROM   wri$_adv_sqlt_plan_hash p, 
         wri$_adv_sqlt_plan_stats s, 
         wri$_adv_executions e,
         wri$_adv_tasks t     
  WHERE  p.plan_id = s.plan_id AND 
         p.exec_name = e.name AND 
         p.task_id = e.task_id AND
         p.task_id = t.id AND
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID') AND
         (p.attribute < power (2,16) OR
          p.attribute >= 3*power (2, 16)) /* hide special plans */;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_advisor_sqlstats
  FOR SYS.user_advisor_sqlstats;

-- grant a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_advisor_sqlstats to PUBLIC;

----------------------------- view dba_advisor_sqlplans ------------------------
CREATE OR REPLACE view dba_advisor_sqlplans AS
  SELECT t.name task_name, h.task_id,
         h.exec_name as execution_name,
         h.sql_id,
         h.object_id, 
         (case when h.attribute < power(2, 16) then
                    decode(h.attribute, 
                           0, 'Original', 
                           1, 'Original with adjusted cost', 
                           2, 'Using SQL profile',
                           3, 'Using new indices',
                           7, 'Using parallel execution')
               when h.attribute > 3*power(2, 16) and
                    h.attribute < 4*power(2, 16) then
                    'Plan from workload repository'
               when h.attribute > 4*power(2, 16) and
                    h.attribute < 5*power(2, 16) then
                    'Plan from cursor cache'
               when h.attribute > 5*power(2, 16) and
                    h.attribute < 6*power(2, 16) then
                    'Plan from SQL tuning set'
               when h.attribute > 6*power(2, 16) then
                    'Plan from SQL performance analyzer' end) AS attribute,
         statement_id,
         h.plan_hash as plan_hash_value,
         h.plan_id,
         p.timestamp,
         p.remarks,
         p.operation,
         p.options,
         p.object_node,
         p.object_owner,
         p.object_name,
         p.object_alias,
         p.object_instance,
         p.object_type,
         p.optimizer,
         p.search_columns,
         p.id,
         p.parent_id,
         p.depth,
         p.position,
         p.cost,
         p.cardinality,
         p.bytes,
         p.other_tag,
         p.partition_start,
         p.partition_stop,
         p.partition_id,
         p.other,
         p.distribution,
         p.cpu_cost,
         p.io_cost,
         p.temp_space,
         p.access_predicates,
         p.filter_predicates,
         p.projection,
         p.time,
         p.qblock_name,
         p.other_xml
  FROM wri$_adv_sqlt_plan_hash h, wri$_adv_sqlt_plans p, wri$_adv_tasks t
  where h.plan_id = p.plan_id and h.task_id = t.id;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_advisor_sqlplans
  FOR SYS.dba_advisor_sqlplans;

-- GRANT a SELECT privilege on the view to the SELECT_CATALOG_ROLE role
GRANT SELECT ON dba_advisor_sqlplans to SELECT_CATALOG_ROLE;

--------------------------- view user_advisor_sqlplans -------------------------
CREATE OR REPLACE view user_advisor_sqlplans AS
  SELECT t.name task_name, h.task_id,
         h.exec_name as execution_name,
         h.sql_id,
         h.object_id,
         (case when h.attribute < power(2, 16) then
                    decode(h.attribute, 
                           0, 'Original', 
                           1, 'Original with adjusted cost', 
                           2, 'Using SQL profile',
                           3, 'Using new indices',
                           7, 'Using parallel execution')
               when h.attribute > 3*power(2, 16) and
                    h.attribute < 4*power(2, 16) then
                    'Plan from workload repository'
               when h.attribute > 4*power(2, 16) and
                    h.attribute < 5*power(2, 16) then
                    'Plan from cursor cache'
               when h.attribute > 5*power(2, 16) and
                    h.attribute < 6*power(2, 16) then
                    'Plan from SQL tuning set'
               when h.attribute > 6*power(2, 16) then
                    'Plan from SQL performance analyzer' end) AS attribute,
         p.statement_id,
         h.plan_hash as PLAN_HASH_VALUE,
         h.plan_id,
         p.timestamp,
         p.remarks,
         p.operation,
         p.options,
         p.object_node,
         p.object_owner,
         p.object_name,
         p.object_alias,
         p.object_instance,
         p.object_type,
         p.optimizer,
         p.search_columns,
         p.id,
         p.parent_id,
         p.depth,
         p.position,
         p.cost,
         p.cardinality,
         p.bytes,
         p.other_tag,
         p.partition_start,
         p.partition_stop,
         p.partition_id,
         p.other,
         p.distribution,
         p.cpu_cost,
         p.io_cost,
         p.temp_space,
         p.access_predicates,
         p.filter_predicates,
         p.projection,
         p.time,
         p.qblock_name,
         p.other_xml
  FROM   wri$_adv_sqlt_plan_hash h, wri$_adv_sqlt_plans p, wri$_adv_tasks t
  WHERE  h.task_id = t.id and h.plan_id = p.plan_id and 
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID');

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_advisor_sqlplans
  FOR SYS.user_advisor_sqlplans;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_advisor_sqlplans to PUBLIC;


Rem
Rem Views specific to ADDM 
Rem 
create or replace view dba_addm_tasks
   as select at.*,
             a.dbid as dbid,
             a.dbname as dbname,
             a.dbversion as dbversion,
             a.analysis_version as analysis_version,
             a.begin_snap_id as begin_snap_id,
             a.begin_time as begin_time,
             a.end_snap_id as end_snap_id,
             a.end_time as end_time,
             a.requested_analysis as requested_analysis,
             a.actual_analysis as actual_analysis,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.meter_level as meter_level
      from  wri$_adv_addm_tasks a, dba_advisor_tasks at
      where at.task_id = a.task_id
        and at.status = 'COMPLETED';

create or replace public synonym dba_addm_tasks
   for dba_addm_tasks;
grant select on dba_addm_tasks to select_catalog_role;

create or replace view user_addm_tasks
   as select at.*,
             a.dbid as dbid,
             a.dbname as dbname,
             a.dbversion as dbversion,
             a.analysis_version as analysis_version,
             a.begin_snap_id as begin_snap_id,
             a.begin_time as begin_time,
             a.end_snap_id as end_snap_id,
             a.end_time as end_time,
             a.requested_analysis as requested_analysis,
             a.actual_analysis as actual_analysis,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.meter_level as meter_level
      from  wri$_adv_addm_tasks a, user_advisor_tasks at
      where at.task_id = a.task_id
        and at.status = 'COMPLETED';

create or replace public synonym user_addm_tasks
   for user_addm_tasks;
grant select on user_addm_tasks to public;


create or replace view dba_addm_instances
   as select a.task_id as task_id,
             a.instance_number as instance_number,
             a.instance_name as instance_name,
             a.host_name as host_name,
             a.status as status,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.perc_active_sess as perc_active_sess,
             a.meter_level as meter_level,
             a.local_task_id as local_task_id
      from  wri$_adv_addm_inst a;

create or replace public synonym dba_addm_instances
   for dba_addm_instances;
grant select on dba_addm_instances to select_catalog_role;

create or replace view user_addm_instances
   as select a.task_id as task_id,
             a.instance_number as instance_number,
             a.instance_name as instance_name,
             a.host_name as host_name,
             a.status as status,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.perc_active_sess as perc_active_sess,
             a.meter_level as meter_level,
             a.local_task_id as local_task_id
      from  wri$_adv_addm_inst a, wri$_adv_tasks tn
      where a.task_id = tn.id 
        and tn.owner# = userenv('SCHEMAID');

create or replace public synonym user_addm_instances
   for user_addm_instances;
grant select on user_addm_instances to public;


create or replace view dba_addm_findings
   as select f.*,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.perc_active_sess as perc_active_sess,
             a.is_aggregate as is_aggregate,
             a.meter_level as meter_level,
             a.query_is_approx as query_is_approx
      from  wri$_adv_addm_fdg a, dba_advisor_findings f
      where f.task_id = a.task_id
       and  f.finding_id = a.finding_id;

create or replace public synonym dba_addm_findings
   for dba_addm_findings;
grant select on dba_addm_findings to select_catalog_role;

create or replace view user_addm_findings
   as select f.*,
             a.database_time as database_time,
             a.active_sessions as active_sessions,
             a.perc_active_sess as perc_active_sess,
             a.is_aggregate as is_aggregate,
             a.meter_level as meter_level,
             a.query_is_approx as query_is_approx
      from  wri$_adv_addm_fdg a, user_advisor_findings f
      where f.task_id = a.task_id
       and  f.finding_id = a.finding_id;

create or replace public synonym user_addm_findings
   for user_addm_findings;
grant select on user_addm_findings to public;


create or replace view dba_addm_fdg_breakdown
   as select a.task_id as task_id,
             a.finding_id as finding_id,
             a.instance_number as instance_number,
             a.impact as database_time,
             a.impact / 
               greatest(1, 
                        (cast(t.end_time as date) - cast(t.begin_time as date)) 
                         * 86400000000 
                        ) as active_sessions,
             a.perc_impact as perc_active_sessions
      from  dba_advisor_fdg_breakdown a, wri$_adv_addm_tasks t
      where a.task_id = t.task_id;

create or replace public synonym dba_addm_fdg_breakdown
   for dba_addm_fdg_breakdown;
grant select on dba_addm_fdg_breakdown to select_catalog_role;

create or replace view user_addm_fdg_breakdown
   as select a.task_id as task_id,
             a.finding_id as finding_id,
             a.instance_number as instance_number,
             a.impact as database_time,
             a.impact /
               greatest(1,
                        (cast(t.end_time as date) - cast(t.begin_time as date))
                         * 86400000000
                        ) as active_sessions,
             a.perc_impact as perc_active_sessions
      from  user_advisor_fdg_breakdown a, wri$_adv_addm_tasks t
      where a.task_id = t.task_id;

create or replace public synonym user_addm_fdg_breakdown
   for user_addm_fdg_breakdown;
grant select on user_addm_fdg_breakdown to public;

create or replace view dba_addm_system_directives
   as SELECT i.INSTANCE_ID as INSTANCE_ID,
             i.INSTANCE_NAME as INSTANCE_NAME,
             d.DIRECTIVE_NAME as DIRECTIVE_NAME,
             prvt_hdm.describe_directive(d.DIRECTIVE_NAME, i.data) 
                   as DESCRIPTION
      FROM   dba_advisor_dir_instances i,
             dba_advisor_dir_definitions d
      WHERE  i.DIRECTIVE_ID = d.ID 
        AND  d.ADVISOR_ID = 1;
 
create or replace public synonym dba_addm_system_directives
   for dba_addm_system_directives;
grant select on dba_addm_system_directives to select_catalog_role;

create or replace view dba_addm_task_directives
   as SELECT i.TASK_ID as TASK_ID,
             i.TASK_NAME as TASK_NAME,
             i.USERNAME as USERNAME,
             i.SEQ_ID as SEQ_ID,
             i.INSTANCE_NAME as INSTANCE_NAME,
             d.DIRECTIVE_NAME as DIRECTIVE_NAME,
             prvt_hdm.describe_directive(d.DIRECTIVE_NAME, i.data) 
                 as DESCRIPTION
      FROM   dba_advisor_dir_task_inst i,
             dba_advisor_dir_definitions d
      WHERE  i.DIRECTIVE_ID = d.ID
        AND  d.ADVISOR_ID = 1;

create or replace public synonym dba_addm_task_directives
   for dba_addm_task_directives;
grant select on dba_addm_task_directives to select_catalog_role;

create or replace view user_addm_task_directives
   as SELECT i.TASK_ID as TASK_ID,
             i.TASK_NAME as TASK_NAME,
             i.INSTANCE_NAME as INSTANCE_NAME,
             d.DIRECTIVE_NAME as DIRECTIVE_NAME,
             prvt_hdm.describe_directive(d.DIRECTIVE_NAME, i.data) 
                  as DESCRIPTION
      FROM   user_advisor_dir_task_inst i,
             dba_advisor_dir_definitions d
      WHERE  i.DIRECTIVE_ID = d.ID
        AND  d.ADVISOR_ID = 1;

create or replace public synonym user_addm_task_directives
   for user_addm_task_directives;
grant select on user_addm_task_directives to public;
