Rem
Rem $Header: rdbms/admin/dbmsrmad.sql /st_rdbms_11.2.0/1 2011/03/07 10:10:50 jomcdon Exp $
Rem
Rem dbmsrmad.sql
Rem
Rem Copyright (c) 1998, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrmad.sql - DBMS Resource Manager package for administrators.
Rem
Rem    DESCRIPTION
Rem      Specification for the resource manager package.
Rem
Rem    NOTES
Rem    
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jomcdon     03/03/11 - Backport jomcdon_bug-10627301 from main
Rem    jomcdon     02/12/10 - bug 9368895: add parallel_queue_timeout
Rem    jooskim     01/11/10 - bug 8505440: implement SQL grouping
Rem    jomcdon     12/10/09 - bug 9195461: correct order of arguments
Rem    jomcdon     12/03/09 - project 24605: add parallel_target_percentage
Rem    jomcdon     02/03/09 - add max_utilization_limit
Rem    aksshah     03/03/08 - Define ORACLE_FUNCTION mapping attribute
Rem    vkolla      01/19/07 - num_disks => num_physical_disks
Rem    suelee      12/14/06 - Add consumer group category
Rem    suelee      12/31/06 - Disable IORM, part 2
Rem    vkolla      08/07/06 - remove calibrate_mode from calibrate_io
Rem    jaskwon     06/30/06 - Expose sub_plan attribute 
Rem    fsymonds    05/25/06 - Proj 19542: WLM PC consumer group mapping 
Rem    suelee      06/11/06 - Add IO calibration routines 
Rem    jaskwon     05/15/06 - Remove max_concurrent_ios 
Rem    suelee      03/14/06 - Add procedures for IORM 
Rem    sridsubr    05/21/04 - Add param to switch_plan 
Rem    asundqui    10/07/02 - new parameters
Rem    asundqui    05/15/02 - consumer group mapping interface
Rem    avaliani    10/11/01 - add sid param to switch_plan procedure
Rem    rherwadk    11/09/01 - #1817695: unlimit default resmgr parameter values
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rherwadk    06/19/00 - change switch_group parameters
Rem    wixu        04/04/00 - wixu_resman_chg
Rem    wixu        02/21/00 - wixu_bug_1177932_MAIN
Rem    wixu        01/20/00 - change_for_RES_MANGR_extensions
Rem    arhee       09/03/99 - add create_simple_plan
Rem    akalra      04/07/99 - Add switch_plan
Rem    akalra      06/01/98 - Insert comment about max_active_sess_target_p1   
Rem    akalra      05/18/98 - Change interface
Rem    akalra      01/19/98 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_resource_manager AUTHID CURRENT_USER AS

  --
  -- create a new resource plan
  --
  -- Input arguments:
  --   plan                       - name of resource plan
  --   comment                    - user's comment
  --   cpu_mth                    - allocation method for CPU resources
  --                                (deprecated)
  --   active_sess_pool_mth       - allocation method for max. active sessions
  --   parallel_degree_limit_mth  - allocation method for degree of parallelism
  --   queueing_mth               - type of queueing policy to use
  --   mgmt_mth                   - allocation method for CPU and I/O resources
  --   sub_plan                   - whether plan is sub_plan
  --   max_iops                   - maximum I/O requests per second
  --   max_mbps                   - maximum megabytes of I/O per second
  --

  PROCEDURE create_plan(plan IN VARCHAR2,
                        comment IN VARCHAR2,
                        cpu_mth IN VARCHAR2 DEFAULT NULL,
                        active_sess_pool_mth IN VARCHAR2 
                        DEFAULT 'ACTIVE_SESS_POOL_ABSOLUTE',
                        parallel_degree_limit_mth IN VARCHAR2 DEFAULT 
                        'PARALLEL_DEGREE_LIMIT_ABSOLUTE',
                        queueing_mth IN VARCHAR2 DEFAULT 'FIFO_TIMEOUT',
                        mgmt_mth IN VARCHAR2 DEFAULT 'EMPHASIS',
                        sub_plan IN BOOLEAN DEFAULT FALSE,
                        max_iops IN NUMBER DEFAULT NULL,
                        max_mbps IN NUMBER DEFAULT NULL
                        );
 
  --
  -- update an existing resource plan. NULL arguments leave the resource plan
  -- unchanged in the dictionary.
  --
  -- Input arguments:
  --   plan                           - name of resource plan
  --   new_comment                    - new user's comment
  --   new_cpu_mth                    - name of new allocation method for CPU 
  --                                    resources (deprecated)
  --   new_active_sess_pool_mth       - name of new method for max. active 
  --                                    sessions
  --   new_parallel_degree_limit_mth  - name of new method for degree of 
  --                                    parallelism
  --   new_queueing_mth               - new type of queueing policy to use
  --   new_mgmt_mth                   - name of new allocation method for CPU 
  --                                    and I/O resources
  --   new_sub_plan                   - whether plan is sub_plan
  --   new_max_iops                   - new maximum I/O requests per second
  --   new_max_mbps                   - new maximum megabytes of I/O per second
  --
  PROCEDURE update_plan(plan IN VARCHAR2,
                        new_comment IN VARCHAR2 DEFAULT NULL,
                        new_cpu_mth IN VARCHAR2 DEFAULT NULL,
                        new_active_sess_pool_mth IN VARCHAR2 
                        DEFAULT NULL,
                        new_parallel_degree_limit_mth IN VARCHAR2
                        DEFAULT NULL,
                        new_queueing_mth IN VARCHAR2 DEFAULT NULL,
                        new_mgmt_mth IN VARCHAR2 DEFAULT NULL,
                        new_sub_plan IN BOOLEAN DEFAULT FALSE,
                        new_max_iops IN NUMBER DEFAULT NULL,
                        new_max_mbps IN NUMBER DEFAULT NULL
                        );

  --
  -- delete an existing resource plan
  --
  -- Input arguments:
  --   plan        - name of resource plan to delete
  --
  PROCEDURE delete_plan(plan IN VARCHAR2);


  --
  -- delete an existing resource plan cascade
  --
  -- Input arguments:
  --   plan        - name of plan
  --
  PROCEDURE delete_plan_cascade(plan IN VARCHAR2);


  --
  -- create a new resource consumer group
  --
  -- Input arguments:
  --   consumer_group - name of consumer group
  --   comment        - user's comment
  --   cpu_mth        - name of CPU resource allocation method (deprecated)
  --   mgmt_mth       - name of CPU and I/O resource allocation method
  --   category       - consumer group category
  --
  PROCEDURE create_consumer_group(consumer_group IN VARCHAR2,
                                  comment IN VARCHAR2,
                                  cpu_mth IN VARCHAR2 DEFAULT NULL,
                                  mgmt_mth IN VARCHAR2 DEFAULT 'ROUND-ROBIN',
	                          category IN VARCHAR2 DEFAULT 'OTHER');
               
  --
  -- update an existing resource consumer group
  --
  -- Input arguments:
  --   consumer_group - name of consumer group
  --   new_comment    - new user's comment
  --   new_cpu_mth    - name of new method for CPU resource allocation 
  --                    (deprecated)
  --   new_mgmt_mth   - name of new method for CPU and I/O resource allocation 
  --   new_category   - new consumer group category
  --
  PROCEDURE update_consumer_group(consumer_group IN VARCHAR2,
                                  new_comment IN VARCHAR2 DEFAULT NULL,
                                  new_cpu_mth IN VARCHAR2 DEFAULT NULL,
                                  new_mgmt_mth IN VARCHAR2 DEFAULT NULL,
				  new_category IN VARCHAR2 DEFAULT NULL);
 
  --
  -- delete an existing resource consumer group
  --
  -- Input arguments:
  --   consumer_group - name of consumer group to be deleted
  --
  PROCEDURE delete_consumer_group(consumer_group IN VARCHAR2);

  --
  -- create a new resource consumer group category
  --
  -- Input arguments:
  --   category       - name of consumer group category
  --   comment        - user's comment
  --
  PROCEDURE create_category(category IN VARCHAR2,
                            comment IN VARCHAR2);
               
  --
  -- update an existing resource consumer group category
  --
  -- Input arguments:
  --   category       - name of consumer group category
  --   new_comment    - new user's comment
  --
  PROCEDURE update_category(category IN VARCHAR2,
                            new_comment IN VARCHAR2 DEFAULT NULL);
 
  --
  -- delete an existing resource consumer group category
  --
  -- Input arguments:
  --   category - name of consumer group category to be deleted
  --
  PROCEDURE delete_category(category IN VARCHAR2);

 --
 -- create a new resource plan directive
 --
 -- Input arguments:
 --   plan                      - name of resource plan
 --   group_or_subplan          - name of consumer group or subplan
 --   comment                   - comment for the plan directive
 --   cpu_p1                    - first parameter for the CPU resource 
 --                               allocation method (deprecated)
 --   cpu_p2                    - second parameter for the CPU resource
 --                               allocation method (deprecated)
 --   cpu_p3                    - third parameter for the CPU resource 
 --                               allocation method (deprecated)
 --   cpu_p4                    - fourth parameter for the CPU resource
 --                               allocation method (deprecated)
 --   cpu_p5                    - fifth parameter for the CPU resource
 --                               allocation method (deprecated)
 --   cpu_p6                    - sixth parameter for the CPU resource
 --                               allocation method (deprecated)
 --   cpu_p7                    - seventh parameter for the CPU resource
 --                               allocation method (deprecated)
 --   cpu_p8                    - eighth parameter for the CPU resource  
 --                               allocation method (deprecated)
 --   active_sess_pool_p1       - first parameter for the max. active sessions
 --                               allocation method
 --   queueing_p1               - queue timeout in seconds
 --   parallel_degree_limit_p1  - first parameter for the degree of parallelism
 --                               allocation method
 --   switch_group              - group to switch to, once a switch condition
 --                               is met
 --   switch_time               - max execution time within a group
 --   switch_estimate           - use execution time estimate to assign group?
 --   max_est_exec_time         - max. estimated execution time in seconds
 --   undo_pool                 - max. cumulative undo allocated for 
 --                               consumer groups
 --   max_idle_time             - max. idle time
 --   max_idle_blocker_time     - max. idle time when blocking other sessions
 --   switch_time_in_call       - max execution time within a top call -
 --                               will switch back to home group after call
 --                               (deprecated)
 --   mgmt_p1                   - first parameter for the resource management
 --                               method (replaces cpu_p1)
 --   mgmt_p2                   - second parameter for the resource management
 --                               method (replaces cpu_p2)
 --   mgmt_p3                   - third parameter for the resource management 
 --                               method (replaces cpu_p3)
 --   mgmt_p4                   - fourth parameter for the resource management
 --                               method (replaces cpu_p4)
 --   mgmt_p5                   - fifth parameter for the resource management
 --                               method (replaces cpu_p5)
 --   mgmt_p6                   - sixth parameter for the resource management
 --                               method (replaces cpu_p6)
 --   mgmt_p7                   - seventh parameter for the resource management
 --                               method (replaces cpu_p7)
 --   mgmt_p8                   - eighth parameter for the resource management
 --                               method (replaces cpu_p8)
 --   switch_io_megabytes       - max MBs of IO issued within a group
 --   switch_io_reqs            - max IO requests issued within a group
 --   switch_for_call           - if group switch occurs, switch back to home
 --                               group after call
 --   max_utilization_limit      - maximum resource allocation set as
 --                                percentage cap
 --   parallel_target_percentage - maximum percentage of parallel target
 --                                before queuing
 --   parallel_queue_timeout     - queue timeout for parallel query queuing
 --

 PROCEDURE create_plan_directive(plan IN VARCHAR2,
                                 group_or_subplan IN VARCHAR2,
                                 comment IN VARCHAR2,
                                 cpu_p1 IN NUMBER DEFAULT NULL,
                                 cpu_p2 IN NUMBER DEFAULT NULL,
                                 cpu_p3 IN NUMBER DEFAULT NULL,
                                 cpu_p4 IN NUMBER DEFAULT NULL,
                                 cpu_p5 IN NUMBER DEFAULT NULL,
                                 cpu_p6 IN NUMBER DEFAULT NULL,
                                 cpu_p7 IN NUMBER DEFAULT NULL,
                                 cpu_p8 IN NUMBER DEFAULT NULL,
                                 active_sess_pool_p1 IN NUMBER DEFAULT NULL,
                                 queueing_p1 IN NUMBER DEFAULT NULL,
                                 parallel_degree_limit_p1 IN NUMBER 
                                 DEFAULT NULL,
                                 switch_group IN VARCHAR2 DEFAULT NULL,
                                 switch_time IN NUMBER DEFAULT NULL,
                                 switch_estimate IN BOOLEAN DEFAULT FALSE,
                                 max_est_exec_time IN NUMBER DEFAULT NULL,
                                 undo_pool IN NUMBER DEFAULT NULL,
                                 max_idle_time IN NUMBER DEFAULT NULL,
                                 max_idle_blocker_time IN NUMBER DEFAULT NULL,
                                 switch_time_in_call IN NUMBER DEFAULT NULL,
                                 mgmt_p1 IN NUMBER DEFAULT NULL,
                                 mgmt_p2 IN NUMBER DEFAULT NULL,
                                 mgmt_p3 IN NUMBER DEFAULT NULL,
                                 mgmt_p4 IN NUMBER DEFAULT NULL,
                                 mgmt_p5 IN NUMBER DEFAULT NULL,
                                 mgmt_p6 IN NUMBER DEFAULT NULL,
                                 mgmt_p7 IN NUMBER DEFAULT NULL,
                                 mgmt_p8 IN NUMBER DEFAULT NULL,
                                 switch_io_megabytes IN NUMBER DEFAULT NULL,
                                 switch_io_reqs IN NUMBER DEFAULT NULL,
                                 switch_for_call IN BOOLEAN DEFAULT NULL,
                                 max_utilization_limit IN NUMBER DEFAULT NULL,
                                 parallel_target_percentage IN NUMBER
                                 DEFAULT NULL,
                                 parallel_queue_timeout IN NUMBER DEFAULT NULL
                                 );

 --
 -- update a plan directive. A plan directive is specified by the plan
 -- and group_or_subplan.
 --
 -- Input arguments:
 --   plan                          -  name of resource plan
 --   group_or_subplan              -  name of group or subplan 
 --   new_comment                   -  comment for the plan directive
 --   new_cpu_p1                    -  first parameter for the CPU management
 --                                    method (deprecated)
 --   new_cpu_p2                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p3                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p4                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p5                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p6                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p7                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_cpu_p8                    -  parameter for the CPU allocation
 --                                    method (deprecated)
 --   new_active_sess_pool_p1       -  first parameter for the max. active 
 --                                    sessions allocation method
 --   new_queueing_p1               -  queue timeout in seconds
 --   new_parallel_degree_limit_p1  -  first parameter for the degree of 
 --                                    parallelism allocation method
 --   new_switch_group              -  group to switch to, once a switch 
 --                                    condition is met
 --   new_switch_time               -  max execution time within a group
 --   new_switch_estimate           -  use execution time estimate?
 --   new_max_est_exec_time         -  max. estimated execution time in seconds
 --   new_undo_pool                 -  max. cumulative undo allocated for 
 --                                    consumer groups
 --   new_max_idle_time             -  max. idle time
 --   new_max_idle_blocker_time     -  max. idle time when blocking other 
 --                                    sessions
 --   new_switch_time_in_call       - max execution time within a top call -
 --                                   will switch back to home group after call
 --                                   (deprecated)
 --   new_mgmt_p1                   - first parameter for the resource 
 --                                   management method (replaces new_cpu_p1)
 --   new_mgmt_p2                   - second parameter for the resource 
 --                                   management method (replaces new_cpu_p2)
 --   new_mgmt_p3                   - third parameter for the resource
 --                                   management method (replaces new_cpu_p3)
 --   new_mgmt_p4                   - fourth parameter for the resourc
 --                                   management method (replaces new_cpu_p4)
 --   new_mgmt_p5                   - fifth parameter for the resourc
 --                                   management method (replaces new_cpu_p5)
 --   new_mgmt_p6                   - sixth parameter for the resourc
 --                                   management method (replaces new_cpu_p6)
 --   new_mgmt_p7                   - seventh parameter for the resourc
 --                                   management method (replaces new_cpu_p7)
 --   new_mgmt_p8                   - eighth parameter for the resourc
 --                                   management method (replaces new_cpu_p8)
 --   new_switch_io_megabytes       - max MBs of IO issued within a group
 --   new_switch_io_reqs            - max IO requests issued within a group
 --   new_switch_for_call           - if group switch occurs, switch back to 
 --                                   home group after call
 --   new_max_utilization_limit       - maximum resource allocation set
 --                                   as percentage cap
 --   new_parallel_target_percentage - maximum percentage of parallel
 --                                   server pool before queuing
 --   new_parallel_queue_timeout     - queue timeout for parallel query queuing
 --

 PROCEDURE update_plan_directive(plan IN VARCHAR2,
                                 group_or_subplan IN VARCHAR2,
                                 new_comment IN VARCHAR2 DEFAULT NULL,
                                 new_cpu_p1 IN NUMBER DEFAULT NULL,
                                 new_cpu_p2 IN NUMBER DEFAULT NULL,
                                 new_cpu_p3 IN NUMBER DEFAULT NULL,
                                 new_cpu_p4 IN NUMBER DEFAULT NULL,
                                 new_cpu_p5 IN NUMBER DEFAULT NULL,
                                 new_cpu_p6 IN NUMBER DEFAULT NULL,
                                 new_cpu_p7 IN NUMBER DEFAULT NULL,
                                 new_cpu_p8 IN NUMBER DEFAULT NULL,
                                 new_active_sess_pool_p1 IN NUMBER 
                                 DEFAULT NULL,
                                 new_queueing_p1 IN NUMBER DEFAULT NULL,
                                 new_parallel_degree_limit_p1 IN NUMBER 
                                 DEFAULT NULL,
                                 new_switch_group IN VARCHAR2 DEFAULT NULL,
                                 new_switch_time IN NUMBER DEFAULT NULL,
                                 new_switch_estimate IN BOOLEAN DEFAULT NULL,
                                 new_max_est_exec_time IN NUMBER DEFAULT NULL,
                                 new_undo_pool IN NUMBER DEFAULT NULL,
                                 new_max_idle_time IN NUMBER DEFAULT NULL,
                                 new_max_idle_blocker_time IN NUMBER 
                                 DEFAULT NULL,
                                 new_switch_time_in_call IN NUMBER 
                                 DEFAULT NULL,
                                 new_mgmt_p1 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p2 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p3 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p4 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p5 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p6 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p7 IN NUMBER DEFAULT NULL,
                                 new_mgmt_p8 IN NUMBER DEFAULT NULL,
                                 new_switch_io_megabytes IN NUMBER 
                                 DEFAULT NULL,
                                 new_switch_io_reqs IN NUMBER DEFAULT NULL,
                                 new_switch_for_call IN BOOLEAN DEFAULT NULL,
                                 new_max_utilization_limit IN NUMBER
                                 DEFAULT NULL,
                                 new_parallel_target_percentage IN NUMBER
                                 DEFAULT NULL,
                                 new_parallel_queue_timeout IN NUMBER
                                 DEFAULT NULL
                                );

 --
 -- delete a plan directive. A plan directive is uniquely specified by the plan
 -- and group_or_subplan
 --
 -- Input arguments:
 --   plan                  -  name of resource plan
 --   group_or_subplan      -  name of group or subplan 
 -- 
 PROCEDURE delete_plan_directive(plan IN VARCHAR2,
                                 group_or_subplan IN VARCHAR2);

 --
 -- Add or modify a consumer group mapping.
 -- If consumer_group is NULL then the mapping is deleted.
 --
 -- Input arguments:
 --   attribute             -  mapping attribute to add/modify, can be:
 --                            ORACLE_USER, SERVICE_NAME, 
 --                            CLIENT_OS_USER, CLIENT_PROGRAM, CLIENT_MACHINE,
 --                            MODULE_NAME, MODULE_NAME_ACTION,
 --                            SERVICE_MODULE, SERVICE_MODULE_ACTION
 --                            (string constants defined in 
 --                             dbms_resource_manager)
 --   value                 -  attribute value to match
 --   consumer_group        -  name of the mapped consumer group
 --
 PROCEDURE set_consumer_group_mapping(attribute in VARCHAR2,
                                      value in VARCHAR2,
                                      consumer_group in VARCHAR2 DEFAULT NULL);

oracle_user            CONSTANT VARCHAR2(30) := 'ORACLE_USER';
oracle_function        CONSTANT VARCHAR2(30) := 'ORACLE_FUNCTION';
service_name           CONSTANT VARCHAR2(30) := 'SERVICE_NAME';
client_os_user         CONSTANT VARCHAR2(30) := 'CLIENT_OS_USER';
client_program         CONSTANT VARCHAR2(30) := 'CLIENT_PROGRAM';
client_machine         CONSTANT VARCHAR2(30) := 'CLIENT_MACHINE';
client_id              CONSTANT VARCHAR2(30) := 'CLIENT_ID';
module_name            CONSTANT VARCHAR2(30) := 'MODULE_NAME';
module_name_action     CONSTANT VARCHAR2(30) := 'MODULE_NAME_ACTION';
service_module         CONSTANT VARCHAR2(30) := 'SERVICE_MODULE';
service_module_action  CONSTANT VARCHAR2(30) := 'SERVICE_MODULE_ACTION';
performance_class      CONSTANT VARCHAR2(30) := 'PERFORMANCE_CLASS';

 --
 -- Set the mapping priorities (1 = highest). 
 -- Each parameter must be a distinct integer from 1 to 8.
 --
 -- Input arguments:
 --   explicit              -  priority of the explicit group setting
 --   oracle_user           -  priority of the "ORACLE user" mapping
 --   service_name          -  priority of the "service name" mapping
 --   client_os_user        -  priority of the "client OS user" mapping
 --   client_program        -  priority of the "client program" mapping
 --   client_machine        -  priority of the "client machine" mapping
 --   module_name           -  priority of the "module name" mapping
 --   module_name_action    -  priority of the 
 --                            "module name.module action" mapping
 --   service_module        -  priority of the
 --                            "service name.module name" mapping
 --   service_module_action -  priority of the 
 --                            "service name.module name.module action" mapping
 --   client_id             -  priority of the "client id" mapping
 --
 PROCEDURE set_consumer_group_mapping_pri(explicit IN NUMBER,
                                          oracle_user IN NUMBER,
                                          service_name IN NUMBER,
                                          client_os_user IN NUMBER,
                                          client_program IN NUMBER,
                                          client_machine IN NUMBER,
                                          module_name IN NUMBER,
                                          module_name_action IN NUMBER,
                                          service_module IN NUMBER,
                                          service_module_action IN NUMBER,
                                          client_id IN NUMBER DEFAULT 11);

 --
 -- create a pending area. Creates a temporary workspace to make changes.
 --
 -- Input arguments: None
 --
 PROCEDURE create_pending_area;


 --
 -- clear the pending area. Discards all the changes in the pending area
 -- and renders it inactive.
 --
 -- Input arguments: None
 --
 PROCEDURE clear_pending_area;

 --
 -- validate the pending area. Validates all the changes made in the pending
 -- area.
 --
 -- Input arguments: None
 --
 PROCEDURE validate_pending_area;


 --
 -- submit the  pending area. Commits all the changes if they are valid and
 -- renders the pending area inactive.  If not, leaves the pending area 
 -- unchanged.
 --
 -- Input arguments: None
 --
 PROCEDURE submit_pending_area;

 --
 -- OBSOLETE: set the initial consumer group of a user.
 --
 PROCEDURE set_initial_consumer_group(user IN VARCHAR2,
                                      consumer_group IN VARCHAR2);
 
 --
 -- switch the consumer group for all currently logged on users with the
 -- given name
 --
 -- Input arguments:
 --   user           - name of the user
 --   consumer_group - name of the consumer group to switch to
 --
 PROCEDURE switch_consumer_group_for_user(user IN VARCHAR2,
                                          consumer_group IN VARCHAR2);
 
 --
 -- switch the consumer group for a session.
 --
 -- Input arguments:
 --   session_id     - SID column from the view V$SESSION
 --   serial         - SERIAL# column from the view V$SESSION
 --   consumer_group - name of the consumer group to switch to
 --
 PROCEDURE switch_consumer_group_for_sess(session_id IN NUMBER,
                                          session_serial IN NUMBER,
                                          consumer_group IN VARCHAR2);

 --
 -- switch to the specified plan. This makes the specified plan active.
 --
 -- Input arguments:
 --   plan_name                     - name of plan to switch to
 --   allow_scheduler_plan_switches - allow scheduler to switch this plan
 --                                   at a later time 
 --
 PROCEDURE switch_plan(plan_name IN VARCHAR2, 
                       sid IN VARCHAR2 DEFAULT '*',
                       allow_scheduler_plan_switches IN BOOLEAN DEFAULT TRUE);

 --
 -- create a simple plan that implicitly has SYS_GROUP at 100% at level 1
 -- and OTHER_GROUPS at 100% at level 3, while the specified input groups 
 -- are all at level 2.
 --
 -- Input arguments:
 --   simple_plan     - name of plan to be created
 --   consumer_group1 - name of consumer group
 --   group1_cpu      - percentage for group (deprecated)
 --   consumer_group2 - name of consumer group
 --   group2_cpu      - percentage for group (deprecated)
 --   consumer_group3 - name of consumer group
 --   group3_cpu      - percentage for group (deprecated)
 --   consumer_group4 - name of consumer group
 --   group4_cpu      - percentage for group (deprecated)
 --   consumer_group5 - name of consumer group
 --   group5_cpu      - percentage for group (deprecated)
 --   consumer_group6 - name of consumer group
 --   group6_cpu      - percentage for group (deprecated)
 --   consumer_group7 - name of consumer group
 --   group7_cpu      - percentage for group (deprecated)
 --   consumer_group8 - name of consumer group
 --   group8_cpu      - percentage for group (deprecated)
 --   group1_percent  - percentage for group
 --   group2_percent  - percentage for group
 --   group3_percent  - percentage for group
 --   group4_percent  - percentage for group
 --   group5_percent  - percentage for group
 --   group6_percent  - percentage for group
 --   group7_percent  - percentage for group
 --   group8_percent  - percentage for group

 PROCEDURE create_simple_plan (simple_plan IN VARCHAR2 DEFAULT NULL,
                               consumer_group1 IN VARCHAR2 DEFAULT NULL, 
                               group1_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group2 IN VARCHAR2 DEFAULT NULL, 
                               group2_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group3 IN VARCHAR2 DEFAULT NULL, 
                               group3_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group4 IN VARCHAR2 DEFAULT NULL, 
                               group4_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group5 IN VARCHAR2 DEFAULT NULL, 
                               group5_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group6 IN VARCHAR2 DEFAULT NULL, 
                               group6_cpu IN NUMBER DEFAULT NULL, 
                               consumer_group7 IN VARCHAR2 DEFAULT NULL, 
                               group7_cpu IN NUMBER DEFAULT NULL,  
                               consumer_group8 IN VARCHAR2 DEFAULT NULL, 
                               group8_cpu IN NUMBER DEFAULT NULL,
                               group1_percent IN NUMBER DEFAULT NULL,
                               group2_percent IN NUMBER DEFAULT NULL,
                               group3_percent IN NUMBER DEFAULT NULL,
                               group4_percent IN NUMBER DEFAULT NULL,
                               group5_percent IN NUMBER DEFAULT NULL,
                               group6_percent IN NUMBER DEFAULT NULL,
                               group7_percent IN NUMBER DEFAULT NULL,
                               group8_percent IN NUMBER DEFAULT NULL);

 --
 -- Set database-wide capabilities.
 --
 -- Input arguments:
 --   cpu_capable - TRUE, if CPU resource management can be enabled
 --   io_capable  - type of IO resource management (i.e. shared or dedicated)
 --                 that can be enabled
 --                 
 -- PROCEDURE set_capability(cpu_capable IN BOOLEAN DEFAULT TRUE,
 --                          io_capable IN VARCHAR2 DEFAULT NULL);

 shared_storage     CONSTANT VARCHAR2(30) := 'SHARED_STORAGE';
 dedicated_storage  CONSTANT VARCHAR2(30) := 'DEDICATED_STORAGE';

 --
 -- Set per-instance capabilities.
 --
 -- Input arguments:
 --   instance_number           - instance number
 --   io_shares                 - number of IO shares for this instance 
 --
 -- PROCEDURE set_instance_capability(instance_number IN NUMBER,
 --                                   io_shares IN NUMBER DEFAULT NULL);

 --
 -- Update a storage pool mapping.
 --
 -- Input arguments:
 --   attribute - mapping attribute (see string constants below)
 --   value     - attribute value
 --   pool_name - name of storage pool (see string constants below)
 --
 -- PROCEDURE update_storage_pool_mapping (attribute IN VARCHAR2,
 --                                        value IN VARCHAR2 DEFAULT NULL, 
 --                                        pool_name IN VARCHAR2);

 log_files          CONSTANT VARCHAR2(30) := 'LOG_FILES';
 temp_files         CONSTANT VARCHAR2(30) := 'TEMP_FILES';
 recovery_area      CONSTANT VARCHAR2(30) := 'RECOVERY_AREA';
 asm_disk_group     CONSTANT VARCHAR2(30) := 'ASM_DISK_GROUP';
 
 managed_files      CONSTANT VARCHAR2(30) := 'MANAGED_FILES';
 unmanaged_files    CONSTANT VARCHAR2(30) := 'UNMANAGED_FILES';


 --
 -- Initiate an I/O calibration
 --
 -- Input arguments:
 --  num_physical_disks   - Approximate number of physical disks in 
 --                         the database storage
 --  max_latency          - Maximum tolerable latency in milliseconds for 
 --                         database-block-sized IO requests
 --
 -- Output arguments:
 --  max_iops       - Maximum number of I/O requests per second that can be 
 --                   sustained.  The I/O requests are randomly-distributed, 
 --                   database-block-sized reads.
 --  max_mbps       - Maximum throughput of I/O that can be sustained,
 --                   expressed in megabytes per second. The I/O requests
 --                   are randomly-distributed, 1 megabyte reads.
 --  actual_latency - Average latency of database-block-sized I/O 
 --                   requests at "max_iops" rate, expressed in milliseconds.
 --
  PROCEDURE calibrate_io (
   num_physical_disks  IN  PLS_INTEGER DEFAULT 1,
   max_latency         IN  PLS_INTEGER DEFAULT 20,
   max_iops            OUT PLS_INTEGER,
   max_mbps            OUT PLS_INTEGER,
   actual_latency      OUT PLS_INTEGER
   );

 -- 
 -- Begin a sql block. The parallel queries in this sql block will have a
 -- logical queue start time same to the queue start time of the first parallel
 -- query in this sql block. 
 --
 -- Input arguments: None
 --
  PROCEDURE begin_sql_block;

 -- 
 -- End a sql block
 --
 -- Input arguments: None
 --   
  PROCEDURE end_sql_block;

END dbms_resource_manager;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_resource_manager
   FOR sys.dbms_resource_manager
/
GRANT EXECUTE ON dbms_resource_manager TO public
/
