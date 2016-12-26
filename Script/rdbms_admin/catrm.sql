Rem
Rem
Rem catrm.sql
Rem
Rem Copyright (c) 1998, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catrm.sql - Catalog script for dbms Resource Manager package
Rem
Rem    DESCRIPTION
Rem      Installs packages for the DBMS Resource Manager.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jomcdon     03/03/11 - Backport jomcdon_bug-10627301 from main
Rem    asarin      01/05/11 - Backport asarin_bug-10180307 from main
Rem    jomcdon     02/12/10 - bug 9368895: add parallel_queue_timeout
Rem    suelee      01/06/10 - Add comments about import/export
Rem    jomcdon     12/03/09 - project 24605: use max_active_sess_target_p1
Rem                           for parallel_target_percentage
Rem    jomcdon     02/03/09 - add max_utilization_limit
Rem    vkolla      01/23/07 - use DBA_RSRC_IO_CALIBRATE
Rem    suelee      12/14/06 - Add consumer group category
Rem    suelee      02/16/07 - Hide max_iops and max_mbps in dba_rsrc_plans
Rem    vkolla      11/13/06 - remove DBA_RSRC_IO_CALIBRATE
Rem    suelee      10/12/06 - Change display for dba_rsrc_plans's max_iops and
Rem                           max_mbps
Rem    rburns      07/27/06 - re-organize for parallel 
Rem    suelee      07/25/06 - Expose ids of resource plans and consumer groups 
Rem    suelee      06/30/06 - Fix DBA_RSRC_PLAN_DIRECTIVE for switch_time et 
Rem                           al parameters 
Rem    suelee      06/11/06 - Add IO calibration tables 
Rem    jaskwon     05/27/06 - Add sub_plan to DBA_RSRC_PLANS 
Rem    jaskwon     05/24/06 - Remove max_concurrent_ios 
Rem    suelee      03/28/06 - Modifications for IO Resource Management 
Rem    avaliani    08/24/04 - bug 3688272: change ACTIVE to NULL
Rem    sridsubr    07/08/04 - Fix Status in DBA_RSRC_PLANS -- Bug 3688272 
Rem    rburns      05/01/03 - recompile synonym
Rem    asundqui    10/09/02 - new parameters
Rem    asundqui    05/07/02 - consumer group mapping interface
Rem    rherwadk    11/09/01 - #1817695: unlimit default resmgr parameter values
Rem    ykunitom    08/28/01 - Bug 1928353: change switch_estimate
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rherwadk    06/19/00 - change switch_group parameters
Rem    rmurthy     06/20/00 - change objauth.option column to hold flag bits
Rem    wixu        03/16/00 - wixu_resman_chg
Rem    wixu        01/20/00 - change_for_RES_MANGR_extensions
Rem    akalra      06/24/99 - rename some files
Rem    akalra      11/20/98 - grant sys. privilege to export and import roles
Rem                         - set up more built-ins and their privileges
Rem    klcheung    11/17/98 - move rmexptab$ creation
Rem    akalra      08/17/98 - support for import export
Rem    akalra      06/17/98 - Allow object grant
Rem    akalra      06/12/98 - inicongroup -> defschclass
Rem    akalra      06/10/98 - Change -1 to UWORDMAXVAL
Rem    akalra      06/09/98 - Change file names
Rem    akalra      06/03/98 - Change views                                     
Rem    akalra      05/26/98 - Change and add views                             
Rem    akalra      05/22/98 - Use new interface                                
Rem    akalra      01/19/98 - Created
Rem

-- Create the library where 3GL callouts, such as the callouts for
-- the dbms_resource_manager package, will reside
CREATE OR REPLACE LIBRARY dbms_rmgr_lib TRUSTED as STATIC
/

-- Setup the actions to export resource manager objects via data pump.  
-- Note that if any new resource manager objects are added, a corresponding
-- PL/SQL procedure for exporting this object should be created and 
-- registered below.  Also, if any fields are added or removed from
-- a resource manager object, the corresponding PL/SQL procedure should be
-- modified.
--
-- Note that we are missing support for exporting categories.
-- The resource_category$ table needs to be altered to incorporate object ids.

-- Delete existing export data actions.
DELETE FROM exppkgobj$ where package like 'DBMS_RMGR_%'
/
DELETE FROM exppkgact$ where package like 'DBMS_RMGR_%'
/

-- Configure package to export resource plans via data pump.
-- This package is declared in dbmsrmpe.sql and implemented in prvtrmpe.sql.
-- This package also exports resource manager privileges.
--
INSERT INTO exppkgobj$ (package,schema,class,type#,prepost,level#)
values('DBMS_RMGR_PLAN_EXPORT', 'SYS', 1, 47, 1, 1000)
/

-- Configure package to export consumer groups via data pump.
-- This package is declared in dbmsrmge.sql and implemented in prvtrmge.sql.
--
INSERT INTO exppkgobj$ (package,schema,class,type#,prepost,level#)
values('DBMS_RMGR_GROUP_EXPORT', 'SYS', 1, 48, 1, 1000)
/

-- Configure package to export plan directives via data pump.  
-- This package also exports consumer group mappings, consumer group
-- mapping priorities, and consumer group privileges.
-- This package is declared in dbmsrmpa.sql and implemented in prvtrmpa.sql.
--
INSERT INTO exppkgact$ (package,schema,class,level#)
values('DBMS_RMGR_PACT_EXPORT', 'SYS', 1, 1000)
/

---------------------------------------------------------------------------------
--                              VIEWS                                          --
---------------------------------------------------------------------------------

--
-- Create the view DBA_RSRC_PLANS
--
create or replace view DBA_RSRC_PLANS
   (PLAN_ID,PLAN,NUM_PLAN_DIRECTIVES,CPU_METHOD,MGMT_METHOD,
    ACTIVE_SESS_POOL_MTH,PARALLEL_DEGREE_LIMIT_MTH,QUEUEING_MTH,
    SUB_PLAN,COMMENTS,STATUS,MANDATORY)
as
select obj#,name,num_plan_directives,mgmt_method,mgmt_method,mast_method,
       pdl_method,que_method,
       decode(sub_plan,1,'YES','NO'),
       description,
       decode(status,'PENDING',status, NULL),
       decode(mandatory,1,'YES','NO')
from resource_plan$
order by status
/
comment on table DBA_RSRC_PLANS is
'All the resource plans'
/
comment on column DBA_RSRC_PLANS.PLAN_ID is
'Plan ID'
/
comment on column DBA_RSRC_PLANS.PLAN is
'Plan name'
/
comment on column DBA_RSRC_PLANS.NUM_PLAN_DIRECTIVES is
'Number of plan directives for the plan'
/
comment on column DBA_RSRC_PLANS.CPU_METHOD is
'deprecated - use MGMT_METHOD'
/
comment on column DBA_RSRC_PLANS.MGMT_METHOD is
'resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.ACTIVE_SESS_POOL_MTH is
'maximum active sessions target resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.PARALLEL_DEGREE_LIMIT_MTH is
'parallel degree limit resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.QUEUEING_MTH is
'queueing method for groups'
/
comment on column DBA_RSRC_PLANS.SUB_PLAN is
'Whether the plan is a sub-plan'
/
comment on column DBA_RSRC_PLANS.COMMENTS is
'Text comment on the plan'
/
comment on column DBA_RSRC_PLANS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_PLANS.MANDATORY is
'Whether the plan is mandatory'
/
create or replace public synonym DBA_RSRC_PLANS for DBA_RSRC_PLANS
/
grant select on DBA_RSRC_PLANS to SELECT_CATALOG_ROLE
/

--
-- Create the view DBA_RSRC_CONSUMER_GROUPS
--
create or replace view DBA_RSRC_CONSUMER_GROUPS
   (CONSUMER_GROUP_ID,CONSUMER_GROUP,CPU_METHOD,MGMT_METHOD,INTERNAL_USE,
    COMMENTS,CATEGORY,STATUS,MANDATORY)
as
select obj#,name,mgmt_method,mgmt_method,
       decode(internal_use,1,'YES','NO'),
       description,
       category,
       decode(status,'PENDING',status, NULL),
       decode(mandatory,1,'YES','NO')
from resource_consumer_group$
/
comment on table DBA_RSRC_CONSUMER_GROUPS is
'all the resource consumer groups'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CONSUMER_GROUP_ID is
'consumer group id'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CONSUMER_GROUP is
'consumer group name'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CPU_METHOD is
'deprecated - use MGMT_METHOD'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.MGMT_METHOD is
'resource allocation method for the consumer group'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.INTERNAL_USE is
'Whether the consumer group is for internal use-only'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.COMMENTS is
'Text comment on the consumer group'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CATEGORY is
'Category of the consumer group'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.MANDATORY is
'Whether the consumer group is mandatory'
/
create or replace public synonym DBA_RSRC_CONSUMER_GROUPS
   for DBA_RSRC_CONSUMER_GROUPS
/
grant select on DBA_RSRC_CONSUMER_GROUPS to SELECT_CATALOG_ROLE
/

--
-- Create the view DBA_RSRC_CATEGORIES
--
create or replace view DBA_RSRC_CATEGORIES
   (NAME,COMMENTS,STATUS,MANDATORY)
as
select name,
       description,
       decode(status,'PENDING',status, NULL),
       decode(mandatory,1,'YES','NO')
from resource_category$
/
comment on table DBA_RSRC_CATEGORIES is
'All resource consumer group categories'
/
comment on column DBA_RSRC_CATEGORIES.NAME is
'Consumer group category name'
/
comment on column DBA_RSRC_CATEGORIES.COMMENTS is
'Text comment on the consumer group category'
/
comment on column DBA_RSRC_CATEGORIES.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_CATEGORIES.MANDATORY is
'Whether the consumer group category is mandatory'
/
create or replace public synonym DBA_RSRC_CATEGORIES
   for DBA_RSRC_CATEGORIES
/
grant select on DBA_RSRC_CATEGORIES to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_PLAN_DIRECTIVES
--
create or replace view DBA_RSRC_PLAN_DIRECTIVES
   (PLAN, GROUP_OR_SUBPLAN, TYPE, 
    CPU_P1, CPU_P2, CPU_P3, CPU_P4, CPU_P5, CPU_P6, CPU_P7, CPU_P8, 
    MGMT_P1, MGMT_P2, MGMT_P3, MGMT_P4, MGMT_P5, MGMT_P6, MGMT_P7, MGMT_P8, 
    ACTIVE_SESS_POOL_P1, QUEUEING_P1,
    PARALLEL_TARGET_PERCENTAGE, PARALLEL_DEGREE_LIMIT_P1,
    SWITCH_GROUP, SWITCH_FOR_CALL, SWITCH_TIME, SWITCH_IO_MEGABYTES,
    SWITCH_IO_REQS, SWITCH_ESTIMATE, MAX_EST_EXEC_TIME, UNDO_POOL,
    MAX_IDLE_TIME, MAX_IDLE_BLOCKER_TIME, MAX_UTILIZATION_LIMIT,
    PARALLEL_QUEUE_TIMEOUT, SWITCH_TIME_IN_CALL, COMMENTS, STATUS, MANDATORY)
as
select plan, group_or_subplan, decode(is_subplan, 1, 'PLAN', 'CONSUMER_GROUP'),
decode(mgmt_p1, 4294967295, 0, mgmt_p1),
decode(mgmt_p2, 4294967295, 0, mgmt_p2), 
decode(mgmt_p3, 4294967295, 0, mgmt_p3),
decode(mgmt_p4, 4294967295, 0, mgmt_p4),
decode(mgmt_p5, 4294967295, 0, mgmt_p5),
decode(mgmt_p6, 4294967295, 0, mgmt_p6),
decode(mgmt_p7, 4294967295, 0, mgmt_p7),
decode(mgmt_p8, 4294967295, 0, mgmt_p8),
decode(mgmt_p1, 4294967295, 0, mgmt_p1),
decode(mgmt_p2, 4294967295, 0, mgmt_p2), 
decode(mgmt_p3, 4294967295, 0, mgmt_p3),
decode(mgmt_p4, 4294967295, 0, mgmt_p4),
decode(mgmt_p5, 4294967295, 0, mgmt_p5),
decode(mgmt_p6, 4294967295, 0, mgmt_p6),
decode(mgmt_p7, 4294967295, 0, mgmt_p7),
decode(mgmt_p8, 4294967295, 0, mgmt_p8),
decode(active_sess_pool_p1, 4294967295, to_number(null), active_sess_pool_p1),
decode(queueing_p1, 4294967295, to_number(null), queueing_p1),
decode(max_active_sess_target_p1,
       4294967295, to_number(null), 
       max_active_sess_target_p1),
decode(parallel_degree_limit_p1,
       4294967295, to_number(null),
       parallel_degree_limit_p1), 
switch_group,
decode(switch_for_call, 4294967295, 'FALSE', 0, 'FALSE', 1, 'TRUE'),
decode(switch_time, 4294967295, to_number(null), switch_time),
decode(switch_io_megabytes, 4294967295, to_number(null), switch_io_megabytes),
decode(switch_io_reqs, 4294967295, to_number(null), switch_io_reqs),
decode(switch_estimate, 4294967295, 'FALSE', 0, 'FALSE', 1, 'TRUE'),
decode(max_est_exec_time, 4294967295, to_number(null), max_est_exec_time),
decode(undo_pool, 4294967295, to_number(null), undo_pool),
decode(max_idle_time, 4294967295, to_number(null), max_idle_time),
decode(max_idle_blocker_time, 4294967295, to_number(null), 
       max_idle_blocker_time),
decode(max_utilization_limit, 4294967295, to_number(null),
       max_utilization_limit),
decode(parallel_queue_timeout, 4294967295, to_number(null),
       parallel_queue_timeout),
case when (switch_time = 4294967295) then to_number(null)
     when (switch_for_call = 1) then switch_time
     else to_number(null) end,
description, decode(status,'PENDING',status, NULL), 
decode(mandatory, 1, 'YES', 'NO')
from resource_plan_directive$
/
comment on table DBA_RSRC_PLAN_DIRECTIVES is
'all the resource plan directives'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.PLAN is
'Name of the plan to which this directive belongs'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.GROUP_OR_SUBPLAN is
'Name of the consumer group/sub-plan referred to'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.TYPE is
'Whether GROUP_OR_SUBPLAN refers to a consumer group or a plan'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P1 is
'deprecated - use MGMT_P1'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P2 is
'deprecated - use MGMT_P2'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P3 is
'deprecated - use MGMT_P3'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P4 is
'deprecated - use MGMT_P4'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P5 is
'deprecated - use MGMT_P5'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P6 is
'deprecated - use MGMT_P6'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P7 is
'deprecated - use MGMT_P7'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P8 is
'deprecated - use MGMT_P8'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P1 is
'first parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P2 is
'second parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P3 is
'third parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P4 is
'fourth parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P5 is
'fifth parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P6 is
'sixth parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P7 is
'seventh parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MGMT_P8 is
'eight parameter for the resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.active_sess_pool_p1 is
'first parameter for the maximum active sessions target resource allocation 
method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.queueing_p1 is
'first parameter for the queueing method'
/

comment on column DBA_RSRC_PLAN_DIRECTIVES.parallel_target_percentage is
'maximum percentage of the parallel target used before queueing subsequent
parallel queries'/

comment on column DBA_RSRC_PLAN_DIRECTIVES.parallel_degree_limit_p1 is
'first parameter for the parallel degree limit resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_group is
'group to switch to once switch time is reached'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_for_call is
'switch back to initial consumer group once top call has completed'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_time is
'switch time limit for execution within a group'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_io_megabytes is
'maximum megabytes of I/O within a group'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_io_reqs is
'maximum I/O requests within a group'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_estimate is
'use execution estimate to determine group?'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_est_exec_time is
'use of maximum estimated execution time'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.undo_pool is
'maximum undo allocation for consumer groups'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_idle_time is
'maximum idle time'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_idle_blocker_time is
'maximum idle time when blocking other sessions'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_utilization_limit is
'maximum resource utilization allowed, expressed in percentage'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.parallel_queue_timeout is
'time that a query can spend on the parallel query queue before timing out'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_time_in_call is
'deprecated - use SWITCH_FOR_CALL and SWITCH_TIME'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.COMMENTS is
'Text comment on the plan directive'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MANDATORY is
'Whether the plan directive is mandatory'
/
create or replace public synonym DBA_RSRC_PLAN_DIRECTIVES
   for DBA_RSRC_PLAN_DIRECTIVES
/
grant select on DBA_RSRC_PLAN_DIRECTIVES to SELECT_CATALOG_ROLE
/

--
-- create view DBA_RSRC_CONSUMER_GROUP_PRIVS
--
create or replace view DBA_RSRC_CONSUMER_GROUP_PRIVS
   (GRANTEE,GRANTED_GROUP,GRANT_OPTION,INITIAL_GROUP)
as
select ue.name, g.name, 
       decode(min(mod(o.option$,2)), 1, 'YES', 'NO'),
       decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
              g.name, 'YES', 'NO')
from sys.user$ ue left outer join sys.resource_group_mapping$ cgm on
     (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
      cgm.value = ue.name),
     sys.resource_consumer_group$ g, sys.objauth$ o
where o.obj# = g.obj# and o.grantee# = ue.user#
group by ue.name, g.name, 
      decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
             g.name, 'YES', 'NO')
/
comment on table DBA_RSRC_CONSUMER_GROUP_PRIVS is
'Switch privileges for consumer groups'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANTEE is
'Grantee name'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANTED_GROUP is
'consumer group granted to the grantee'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANT_OPTION is
'whether the grantee can grant the privilege to others' 
/
create or replace public synonym DBA_RSRC_CONSUMER_GROUP_PRIVS
   for DBA_RSRC_CONSUMER_GROUP_PRIVS
/
grant select on DBA_RSRC_CONSUMER_GROUP_PRIVS to SELECT_CATALOG_ROLE
/

--
-- create view USER_RSRC_CONSUMER_GROUP_PRIVS
--
create or replace view USER_RSRC_CONSUMER_GROUP_PRIVS
   (GRANTED_GROUP,GRANT_OPTION,INITIAL_GROUP)
as
select g.name, decode(mod(o.option$,2),1,'YES','NO'),
       decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
              g.name, 'YES', 'NO')
from sys.user$ u left outer join sys.resource_group_mapping$ cgm on
     (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
      cgm.value = u.name), sys.resource_consumer_group$ g, sys.objauth$ o
where o.obj# = g.obj# and o.grantee# = u.user#
and o.grantee# = userenv('SCHEMAID')
/
comment on table USER_RSRC_CONSUMER_GROUP_PRIVS is
'Switch privileges for consumer groups for the user'
/
comment on column USER_RSRC_CONSUMER_GROUP_PRIVS.GRANTED_GROUP is
'consumer groups to which the user can switch'
/
comment on column USER_RSRC_CONSUMER_GROUP_PRIVS.GRANT_OPTION is
'whether the user can grant the privilege to others'
/
create or replace public synonym USER_RSRC_CONSUMER_GROUP_PRIVS
   for USER_RSRC_CONSUMER_GROUP_PRIVS
/
grant select on USER_RSRC_CONSUMER_GROUP_PRIVS to PUBLIC with grant option
/

--
-- create view DBA_RSRC_MANAGER_SYSTEM_PRIVS
--
create or replace view DBA_RSRC_MANAGER_SYSTEM_PRIVS
   (GRANTEE,PRIVILEGE,ADMIN_OPTION)
as
select u.name,spm.name,decode(min(sa.option$),1,'YES','NO')
from sys.user$ u, system_privilege_map spm, sys.sysauth$ sa
where sa.grantee# = u.user# and sa.privilege# = spm.privilege
and sa.privilege# = -227 group by u.name, spm.name
/
comment on table DBA_RSRC_MANAGER_SYSTEM_PRIVS is
'system privileges for the resource manager'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.GRANTEE is
'Grantee name'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.PRIVILEGE is
'name of the system privilege'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.ADMIN_OPTION is
'whether the grantee can grant the privilege to others'
/
create or replace public synonym DBA_RSRC_MANAGER_SYSTEM_PRIVS
   for DBA_RSRC_MANAGER_SYSTEM_PRIVS
/
grant select on DBA_RSRC_MANAGER_SYSTEM_PRIVS to SELECT_CATALOG_ROLE
/

--
-- create view USER_RSRC_MANAGER_SYSTEM_PRIVS
--
create or replace view USER_RSRC_MANAGER_SYSTEM_PRIVS
   (PRIVILEGE,ADMIN_OPTION)
as
select spm.name,decode(min(sa.option$),1,'YES','NO')
from sys.user$ u, system_privilege_map spm, sys.sysauth$ sa
where sa.grantee# = u.user# and sa.privilege# = spm.privilege
and sa.privilege# = -227 and sa.grantee# = userenv('SCHEMAID')
group by spm.name
/
comment on table USER_RSRC_MANAGER_SYSTEM_PRIVS is
'system privileges for the resource manager for the user'
/
comment on column USER_RSRC_MANAGER_SYSTEM_PRIVS.PRIVILEGE is
'name of the system privilege'
/
comment on column USER_RSRC_MANAGER_SYSTEM_PRIVS.ADMIN_OPTION is
'whether the user can grant the privilege to others'
/
create or replace public synonym USER_RSRC_MANAGER_SYSTEM_PRIVS
   for USER_RSRC_MANAGER_SYSTEM_PRIVS
/
grant select on USER_RSRC_MANAGER_SYSTEM_PRIVS to PUBLIC with grant option
/

--
-- create the view DBA_RSRC_GROUP_MAPPINGS
--
create or replace view DBA_RSRC_GROUP_MAPPINGS
   (ATTRIBUTE, VALUE, CONSUMER_GROUP, STATUS)
as
select m.attribute, m.value, m.consumer_group, 
       decode(m.status,'PENDING',m.status, NULL)
from sys.resource_group_mapping$ m
order by m.status,
         (select p.priority from sys.resource_mapping_priority$ p
          where m.status = p.status and m.attribute = p.attribute),
         m.consumer_group, m.value
/
comment on table DBA_RSRC_GROUP_MAPPINGS is
'all the consumer group mappings'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.ATTRIBUTE is
'which session attribute to match'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.VALUE is
'attribute value'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.CONSUMER_GROUP is
'target consumer group name'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_GROUP_MAPPINGS
   for DBA_RSRC_GROUP_MAPPINGS
/
grant select on DBA_RSRC_GROUP_MAPPINGS to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_MAPPING_PRIORITY
--
create or replace view DBA_RSRC_MAPPING_PRIORITY
   (ATTRIBUTE, PRIORITY, STATUS)
as
select attribute, priority, decode(status,'PENDING',status, NULL)
from sys.resource_mapping_priority$
order by status, priority
/
comment on table DBA_RSRC_MAPPING_PRIORITY is
'the consumer group mapping attribute priorities'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.ATTRIBUTE is
'session attribute'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.PRIORITY is
'priority (1 = highest)'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_MAPPING_PRIORITY
   for DBA_RSRC_MAPPING_PRIORITY
/
grant select on DBA_RSRC_MAPPING_PRIORITY to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_STORAGE_POOL_MAPPING
--
create or replace view DBA_RSRC_STORAGE_POOL_MAPPING
   (ATTRIBUTE, VALUE, POOL_NAME, STATUS)
as
  select attribute, value, pool_name, decode(status,'PENDING',status, NULL)
  from sys.resource_storage_pool_mapping$
  order by status, attribute
/
comment on table DBA_RSRC_STORAGE_POOL_MAPPING is
'resource manager rules for mapping files to storage pools'
/
comment on column DBA_RSRC_STORAGE_POOL_MAPPING.ATTRIBUTE is
'mapping attribute'
/
comment on column DBA_RSRC_STORAGE_POOL_MAPPING.VALUE is
'mapping value'
/
comment on column DBA_RSRC_STORAGE_POOL_MAPPING.POOL_NAME is
'storage pool name'
/
comment on column DBA_RSRC_STORAGE_POOL_MAPPING.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_STORAGE_POOL_MAPPING
   for DBA_RSRC_STORAGE_POOL_MAPPING
/
grant select on DBA_RSRC_STORAGE_POOL_MAPPING to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_CAPABILITY
--
create or replace view DBA_RSRC_CAPABILITY
   (CPU_CAPABLE, IO_CAPABLE, STATUS)
as
  select cpu_capable, io_capable, decode(status,'PENDING',status, NULL)
  from sys.resource_capability$
  order by status
/
comment on table DBA_RSRC_CAPABILITY is
'settings for database resources that are capable of being managed by the 
Resource Manager'
/
comment on column DBA_RSRC_CAPABILITY.CPU_CAPABLE is
'TRUE if the CPU can be managed, FALSE otherwise'
/
comment on column DBA_RSRC_CAPABILITY.IO_CAPABLE is
'type of I/O resource management that can be enabled'
/
comment on column DBA_RSRC_CAPABILITY.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_CAPABILITY
   for DBA_RSRC_CAPABILITY
/
grant select on DBA_RSRC_CAPABILITY to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_INSTANCE_CAPABILITY
--
create or replace view DBA_RSRC_INSTANCE_CAPABILITY
   (INSTANCE_NUMBER, IO_SHARES, STATUS)
as
  select instance_number, io_shares, decode(status,'PENDING',status, NULL)
  from sys.resource_instance_capability$
/
comment on table DBA_RSRC_INSTANCE_CAPABILITY is
'per-instance settings for database resources that are capable of being 
managed by the Resource Manager'
/
comment on column DBA_RSRC_INSTANCE_CAPABILITY.INSTANCE_NUMBER is
'instance number'
/
comment on column DBA_RSRC_INSTANCE_CAPABILITY.IO_SHARES is
'number of I/O shares for this instance'
/
comment on column DBA_RSRC_INSTANCE_CAPABILITY.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_INSTANCE_CAPABILITY
   for DBA_RSRC_INSTANCE_CAPABILITY
/
grant select on DBA_RSRC_INSTANCE_CAPABILITY to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_IO_CALIBRATE
--
create or replace view DBA_RSRC_IO_CALIBRATE
   (START_TIME, END_TIME, MAX_IOPS, MAX_MBPS, MAX_PMBPS, 
    LATENCY, NUM_PHYSICAL_DISKS)
as
  select start_time, end_time, max_iops, max_mbps, max_pmbps, latency, num_disks
  from sys.resource_io_calibrate$
/
comment on table DBA_RSRC_IO_CALIBRATE is
'Results of the most recent I/O calibration'
/
comment on column DBA_RSRC_IO_CALIBRATE.START_TIME is
'start time of the most recent I/O calibration'
/
comment on column DBA_RSRC_IO_CALIBRATE.END_TIME is
'end time of the most recent I/O calibration'
/
comment on column DBA_RSRC_IO_CALIBRATE.MAX_IOPS is
'maximum number of data-block read requests that can be sustained per second'
/
comment on column DBA_RSRC_IO_CALIBRATE.MAX_MBPS is
'maximum megabytes per second of large I/O requests that can be 
sustained'
/
comment on column DBA_RSRC_IO_CALIBRATE.MAX_PMBPS is
'maximum megabytes per second of large I/O requests that 
can be sustained by a single process'
/
comment on column DBA_RSRC_IO_CALIBRATE.LATENCY is
'latency for data-block read requests'
/
comment on column DBA_RSRC_IO_CALIBRATE.NUM_PHYSICAL_DISKS is
'number of physical disks in the storage subsystem (as specified by user)'
/
create or replace public synonym DBA_RSRC_IO_CALIBRATE
   for DBA_RSRC_IO_CALIBRATE
/
grant select on DBA_RSRC_IO_CALIBRATE to SELECT_CATALOG_ROLE
/

