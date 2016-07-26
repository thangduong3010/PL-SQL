Rem
Rem $Header: rdbms/admin/catadvtb.sql /main/58 2009/07/01 19:21:04 pbelknap Exp $
Rem
Rem catadvtb.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catadvtb.sql - Manageability Advisor tables and types
Rem
Rem    DESCRIPTION
Rem      Creates base tables and types for the Advisor framework and 
Rem      advisor components
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    pbelknap    03/05/09 - #7916459: materialize io read requests / io write
Rem                           requests
Rem    pbelknap    10/29/08 - add note about adding new metrics to spa
Rem    skabraha    09/16/08 - ignore 4043s when recompiling advisor types
Rem    ushaft      08/06/08 - add ASH query for ADDM findings
Rem    skabraha    09/04/08 - recompile wri$_adv types for upgrade
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    hayu        04/09/08 - add columns to wri$_adv_sqlt_plan_stats
Rem    amitsha     05/04/08 - modify compression advisor subtype to include
Rem                           get_report procedure
Rem    kyagoub     03/14/08 - add new columns for sage
Rem    amitsha     03/03/08 - declare subtype for Compression Advisor
Rem    pbelknap    06/02/07 - add user i/o time to qksctxExeSt
Rem    gssmith     03/05/07 - Bug 5908357 - wrong tablespace for new WRI
Rem                           objects
Rem    sburanaw    02/26/07 - addm_seq in wri$_addv_addm_fdg nullable
Rem    pbelknap    02/20/07 - add execution id
Rem    pbelknap    12/01/06 - add flags to findings
Rem    ushaft      01/16/07 - fix datatype in table wri$_adv_addm_inst
Rem    kyagoub     06/22/06 - add a raw type attribute to the object table 
Rem    kyagoub     06/11/06 - move plan related tables from catsqlt.sql 
Rem    kyagoub     06/07/06 - create wri$_adv_spi under sqltune sub type 
Rem    ushaft      07/10/06 - add indexes on ADDM tables
Rem    pbelknap    06/06/06 - add sub_param_validate for sqltune 
Rem    ushaft      04/21/06 - add procedures to wri$_hdm_adv_t
Rem                           new wri$_adv_inst_fdg table 
Rem                           new wri$_adv_addm* tables
Rem    gssmith     04/28/06 - Move SQL AA components to catsumat.sql
Rem    gssmith     03/22/06 - Adding new AA table 
Rem    gssmith     05/03/06 - Add 11g directives metadata 
Rem    pbelknap    05/22/06 - add sub_delete_execution 
Rem    kyagoub     04/24/06 - add argument to sub_resume 
Rem    kyagoub     04/10/06 - add support for multi-executions 
Rem    bkuchibh    02/20/06 - add new column to wri$_adv_findings 
Rem    kyagoub     10/10/04 - add other column to objects table 
Rem    gssmith     04/20/04 - Bug 3501493 
Rem    pbelknap    01/15/04 - add call to drop task when user dies 
Rem    gssmith     02/05/04 - Change journal flags 
Rem    gssmith     01/29/04 - Adding flags to wri$_adv_recommendations 
Rem    gssmith     11/10/03 - 
Rem    gssmith     10/23/03 - Bug 3207351 
Rem    gssmith     08/26/03 - Extend AA workload column 
Rem    ushaft      07/09/03 - added sub_get_report to type wri$_adv_hdm_t
Rem    kyagoub     07/08/03 - implement sub_get_report for sqltune
Rem    smuthuli    07/15/03 - remove create table/index advisors
Rem    kdias       06/27/03 - clean up dependencies for upgrade/downgrade
Rem    slawande    03/27/03 - change default value of prm
Rem    slawande    03/13/03 - add prm for access advisor
Rem    wyang       05/04/03 - fix undo advisor default parameter
Rem    kyagoub     05/03/03 - remove message from recommendation and 
Rem                           add type to rationale
Rem    bdagevil    04/28/03 - merge new file
Rem    gssmith     05/01/03 - AA workload adjustments
Rem    gssmith     04/15/03 - Change MODE
Rem    gssmith     03/26/03 - Bug 2869857
Rem    sramakri    03/11/03 - CREATION_COST parameter
Rem    sramakri    01/28/03 - volatility weight factors
Rem    slawande    01/24/03 - Add more internal prms for acc advisor
Rem    kyagoub     03/27/03 - add news attributes to the rationale table and 
Rem                           object reference in finding table
Rem    kyagoub     03/17/03 - add type to recommendation table
Rem    kdias       03/12/03 - fix obj adv id
Rem    ushaft      03/07/03 - modifed comments about flags field for params
Rem    kdias       03/04/03 - replace time window w/ start/end time/snapshot
Rem    kyagoub     03/08/03 - add _INDEX_ANALYZE_CONTROL/_SQLTUNE_CONTROL/
Rem                           _PLAN_ANALYZE_CONTROL parameters for sqltune
Rem    kyagoub     02/19/03 - correct default parameter values for sqltune adv
Rem    gssmith     03/18/03 - Access Advisor column name changes
Rem    mxiao       12/23/02 - add attr6 to adv_actions
Rem    gssmith     01/09/03 - Bug 2657007
Rem    gssmith     01/06/03 - Add task parameter for Access Advisor
Rem    wyang       01/14/03 - Undo Advisor Parameters
Rem    nwhyte      12/03/02 - Add object space advisors
Rem    gssmith     12/11/02 - Adding version to task record
Rem    gssmith     11/27/02 - Access Advisor parameter change
Rem    gssmith     11/22/02 - Adjust Access Advisor task parameters
Rem    gssmith     11/19/02 - Bad bit settings
Rem    kdias       12/05/02 - add hdm parameters
Rem    wyang       11/21/02 - undo advisor
Rem    kdias       11/16/02 - add hdm type and data
Rem    kdias       10/31/02 - modify findings table
Rem    gssmith     10/30/02 - Bug 2647626
Rem    kdias       10/12/02 - add err# out param to sub_execute
Rem    kdias       10/08/02 - modify pk constraint for message_groups
Rem    gssmith     10/18/02 - Fix for bug 2632538
Rem    btao        10/21/02 - add parameter _BUCKET_QRYMAX
Rem    gssmith     10/10/02 - Fix Access Advisor parameter
Rem    kdias       10/08/02 - modify pk constraint for message_groups
Rem    btao        10/08/02 - add column flags to wri$_adv_actions
Rem    sramakri    09/30/02 - add commands 16 thru 21
Rem    kdias       09/26/02 - add constraint to the objects table
Rem    kdias       09/24/02 - remove type from advisor definition
Rem    gssmith     09/27/02 - wip
Rem    gssmith     09/26/02 - Add usage table entry
Rem    gssmith     09/25/02 - grabtrans 'gssmith_adv0920'
Rem    btao        09/24/02 - add additional parameters for idx and mv
Rem    gssmith     09/13/02 - Adding templates
Rem    gssmith     09/10/02 - wip
Rem    gssmith     09/04/02 - wip
Rem    gssmith     08/27/02 - Add tablespace clauses
Rem    gssmith     08/21/02 - Adding new sequence for sqlw
Rem    gssmith     08/21/02 - Created
Rem

Rem Manageability Advisor repository tables

Rem super type definition (abstract class) that defines the methods that 
Rem each advisor has to implement
Rem

/*
 Recompile the wri$_adv types here. This is being done for upgrade.
 The problem is that this type hierarchy is invalid when catupgrd is
 run. This leads to deadlock issues when the new subtype, compression_t,
 is created.

 Just to expand on what's happening here, we have an implicit mutual dependency
 between supertype and subtype in an inheritance heirarchy. The could lead to
 deadlock, if the hierarchy is invalid and the types get recompiled 
 recursively. To avoid that, make sure that you recompile the supertypes,
 inorder, before creating a new subtype in the hierarchy, if there is a chance
 that they could be invalid.
*/
/* NOTE: Ignore the error if the type does not exist */
DECLARE
  err_code EXCEPTION;
  PRAGMA EXCEPTION_INIT(err_code, -4043);
BEGIN
  execute immediate 'alter type wri$_adv_abstract_t compile specification reuse settings';
  execute immediate 'alter type wri$_adv_hdm_t compile specification reuse settings';  
  execute immediate 'alter type wri$_adv_sqlaccess_adv compile specification reuse settings';
  execute immediate 'alter type wri$_adv_tunemview_adv compile specification reuse settings';
  execute immediate 'alter type wri$_adv_workload compile specification reuse settings';
  execute immediate 'alter type wri$_adv_undo_adv compile specification reuse settings';
  execute immediate 'alter type wri$_adv_sqltune  compile specification reuse settings';
  execute immediate 'alter type wri$_adv_sqlpi  compile specification reuse settings';
  execute immediate 'alter type wri$_adv_objspace_trend_t compile specification reuse settings';
  EXCEPTION
    WHEN err_code THEN NULL;
END;
/

-- flush SGA
alter system flush shared_pool;


CREATE OR REPLACE TYPE wri$_adv_abstract_t AS OBJECT 
(
  advisor_id      number,                        
  member procedure sub_create (task_id IN NUMBER,
                               from_task_id IN number),
  member procedure sub_execute (task_id IN NUMBER,
                                err_num OUT NUMBER),
  member procedure sub_reset (task_id IN NUMBER),
  member procedure sub_resume (task_id IN NUMBER, 
                               err_num OUT NUMBER),
  member procedure sub_delete (task_id IN NUMBER),
  member procedure sub_delete_execution(task_id IN NUMBER,
                                        execution_name IN VARCHAR2), 
  member procedure sub_param_validate (task_id IN NUMBER,
                                       name IN VARCHAR2,
                                       value IN OUT VARCHAR2),
  member procedure sub_get_script (task_id IN NUMBER,
                                   type IN VARCHAR2,
                                   buffer IN OUT NOCOPY CLOB,
                                   rec_id IN NUMBER,
                                   act_id IN NUMBER),
  member procedure sub_get_script(task_id IN NUMBER,
                                  type IN VARCHAR2,
                                  buffer IN OUT NOCOPY CLOB,
                                  rec_id IN NUMBER,
                                  act_id IN NUMBER,
                                  execution_name IN VARCHAR2,
                                  object_id IN NUMBER),
  member procedure sub_get_report (task_id IN NUMBER,
                                   type IN VARCHAR2,
                                   level IN VARCHAR2,
                                   section IN VARCHAR2,
                                   buffer IN OUT NOCOPY CLOB),
  member procedure sub_get_report(task_id IN NUMBER,
                                  type IN VARCHAR2,
                                  level IN VARCHAR2,
                                  section IN VARCHAR2,
                                  buffer IN OUT NOCOPY CLOB, 
                                  execution_name IN VARCHAR2,
                                  object_id IN NUMBER),
  member procedure sub_validate_directive(task_id IN NUMBER,
                                          command_id IN NUMBER,
                                          attr1 IN OUT VARCHAR2,
                                          attr2 IN OUT VARCHAR2,
                                          attr3 IN OUT VARCHAR2,
                                          attr4 IN OUT VARCHAR2,
                                          attr5 IN OUT VARCHAR2),
  member procedure sub_update_rec_attr (task_id IN NUMBER,
                                        rec_id IN NUMBER,
                                        act_id IN NUMBER,
                                        name IN VARCHAR2,
                                        value IN VARCHAR2),
  member procedure sub_get_rec_attr (task_id IN NUMBER,
                                     rec_id IN NUMBER,
                                     act_id IN NUMBER,
                                     name IN VARCHAR2,
                                     value OUT VARCHAR2),
  member procedure sub_cleanup(task_id IN NUMBER),
  member procedure sub_implement(task_id IN NUMBER),
  member procedure sub_implement(task_id in number, 
                                 rec_id in number,
                                 exit_on_error in number),
  member procedure sub_user_setup(adv_id IN NUMBER),
  member procedure sub_import_directives (task_id in number,
                                          from_id in number,
                                          import_mode in varchar2,
                                          accepted out number,
                                          rejected out number),
  member procedure sub_quick_tune (task_name in varchar2,
                                   attr_clob in clob,
                                   attr_vc in varchar2,
                                   attr_num in number,
                                   template in varchar2,
                                   implement in boolean)
) not final;
/
 
Rem
Rem table containing the list of advisors in the system along with their
Rem method definitions (advisor specific type which is a sub-type of
Rem sys.wri$_adv_abstract_t
Rem
Rem       pk : id
Rem 
create table wri$_adv_definitions
(
 id              number         not null,                       /* unique id */
 name            varchar2(30)   not null,                            /* name */
 property        number         not null,            /* bitvec of properties */
                                       /* supports comprehensive mode = 0x01 */
                                             /* supports limited mode = 0x02 */
                                              /* advisor is resumable = 0x04 */
                                                 /* accepts directive = 0x08 */
                                          /* can generate undo script = 0x16 */
                             /* supports multiple executions of tasks = 0x32 */
 type            wri$_adv_abstract_t not null,        /* adv specific object */
 constraint wri$_adv_definitions_pk primary key(id)
    using index tablespace SYSAUX
)
tablespace sysaux
/
Rem
Rem   Default parameter table
Rem
Rem      Valid values for the datatype column are:
Rem
Rem         1  - number
Rem         2  - string
Rem         3  - comma-separated list of strings
Rem         4  - table specification (schema.table)
Rem         5  - comma-separated list of table specifications
Rem  Values for flags:
Rem         Flags consists of three bits:
Rem           1 - Invisible. If bitand(flags,1)=1 then the views 
Rem               dba_advisor_parameters and user_advisor_parameters do not
Rem               return the row.
Rem           2 - Internal use only
Rem           4 - Output: If bitand(flags,4)=1 then the value was set during
Rem               task execution. We do not allow output values to be invisible
Rem           8 - Modifiable after execution
Rem          16 - System task parameter only.  If this bit is set, this 
Rem               parameter only applies to tasks with the system task bit 
Rem               set.
Rem 
create table wri$_adv_def_parameters
   (
      advisor_id  number         not null,             /* Advisor id number */
      name        varchar2(30)   not null,                /* Parameter name */
      datatype    number         not null,        /* Data type - see header */
      flags       number         not null,     /* 0 = visible, 1 = internal */
      value       varchar2(4000) not null,               /* Parameter value */
      description varchar2(9),                          /* Description code */
      exec_type   varchar2(30),/* exec. action the parameter can be set for */
      constraint wri$_adv_def_parameters_pk primary key(advisor_id,name)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem   Advisor possible execution types. 
Rem   This table contains meta data about execution actions a given 
Rem   advisor can perform. This is important particularly, for advisors
Rem   that support multi-executions of their tasks. This table is mainly
Rem   used to control the execution actions of an advisor. For example, 
Rem   an error will be raised if a given advisor is called to execute
Rem   an action that is not defined for it. 
Rem 
create table wri$_adv_def_exec_types
   (
      advisor_id  number       not null,               /* advisor id number */
      name        varchar2(30) not null,           /* execution action name */
      id          number       not null,      /* internal id for exec. type */
      description varchar2(9),                          /* description code */
      flags       number,         /* execution type flags: not used for now */
      constraint wri$_adv_def_action_pk primary key(advisor_id, name)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem table storing metadata for tasks in the system
Rem
Rem       pk : id
Rem       fk : advisor_id -> wri$_adv_definitions.id
Rem
Rem Valid values for status column (keep in sync with kea.h)
Rem         1  - initial            
Rem         2  - executing          
Rem         3  - completed
Rem         4  - interrupted     
Rem         5  - cancelled
Rem         6  - fatal error
Rem
create table wri$_adv_tasks
( 
 id                   number          not null,    /* unique id for the task */
 owner#               number          not null,         /* owner user number */
 owner_name           varchar2(30),                            /* Owner name */
 name                 varchar2(30),                             /* task name */
 description          varchar2(256),                     /* task description */
 advisor_id           number          not null,        /* associated advisor */
 advisor_name         varchar2(30),                          /* Advisor name */
 ctime                date            not null,             /* creation time */
 mtime                date            not null,    /* last modification time */
 parent_id            number,          /* set if this task is created due to */
                                       /* the recommendation of another task */
 parent_rec_id        number,                  /* the recommendation id that */
                                                    /* recommended this task */
 property             number          not null,      /* bitvec of properties */
                                                        /* 0x01 -> Read only */
                                                        /* 0x02 ->  Template */
                                                             /* 0x04 -> Task */
                                                         /* 0x08 -> Workload */
                                                    /* 0x10 -> Reserved Name */
                                                      /* 0x20 -> System Task */
 version              number,            /* Data version number for the task */
 last_exec_name       varchar2(30),       /* last exec. id as an optimizaton */
 exec_start           date,                          /* execution start time */
 exec_end             date,                            /* execution end time */
 status               number          not null,               /* task status */
 status_msg_id        number,           /* id of msg group in messages table */
 pct_completion_time  number,                   /* progress in terms of time */
 progress_metric      number,            /* advisor specific progress metric */
 metric_units         varchar2(64),                          /* metric units */
 activity_counter     number,                /* counter denoting active work */
                                                       /* is being performed */
 rec_count            number,                             /* Quality counter */
 error_msg#           number,                                 /* error msg # */
 cleanup              number,            /* boolean denoting if cleanup reqd */
 how_created          varchar2(30),   /* optional source used to create task */
 source               varchar2(30),            /* optional name of base task */
 constraint wri$_adv_tasks_pk primary key (id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create UNIQUE index wri$_adv_tasks_idx_01
  on wri$_adv_tasks (name, owner#)
  tablespace SYSAUX;

create UNIQUE index wri$_adv_tasks_idx_02
  on wri$_adv_tasks (owner#, id)
  tablespace SYSAUX;

create index wri$_adv_tasks_idx_03
  on wri$_adv_tasks (advisor_id, exec_start)
  tablespace SYSAUX;

create index wri$_adv_tasks_idx_04
  on wri$_adv_tasks (parent_id, parent_rec_id)
  tablespace SYSAUX;

create sequence wri$_adv_seq_task            /* Generates unique task number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem table storing task parameters for all the tasks
Rem
Rem       pk : (task_id, name)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem
Rem  Values for datatypes: see description above for wri$_adv_def_parameters
Rem
Rem  Values for flags:
Rem         Flags consists of four bits:
Rem           1 - Invisible. If bitand(flags,1)=1 then the views 
Rem               dba_advisor_parameters and user_advisor_parameters do not
Rem               return the row.
Rem           2 - Not-default. If bitand(flags,2)=0 then the value of the 
Rem               parameter was copied from wri$_adv_def_parameters when the
Rem               task was created and not modified since then.
Rem           4 - Output: If bitand(flags,4)=1 then the value was set during
Rem               task execution. We do not allow output values to be invisible
Rem           8 - Modifiable after execution
Rem          16 - System task only.  Parameter is only valid for system tasks.
Rem
Rem         Valid values for flags:
Rem            0  - visible   / default value / not output
Rem            1  - invisible / default value / not output
Rem            2  - visible   / not default   / not output
Rem            3  - invisible / not default   / not output
Rem            6  - visible   / not default   / output value
Rem
Rem          (All values can be combined with system task only)

create table wri$_adv_parameters
(
 task_id        number          not null,  
 name           varchar2(30)    not null,
 value          varchar2(4000)  not null,                 /* parameter value */
 datatype       number          not null,           /* datatype of parameter */
 flags          number          not null,       
 description    varchar2(9),                             /* Description code */
 constraint wri$_adv_parameters_pk primary key(task_id, name)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table storing metadata for task executions
Rem
Rem       pk : (task_id, name)
Rem            execution names are unique within a task.  execution IDs are
Rem            included just for convenience with xml reports
Rem       fk : task_id -> wri$_adv_tasks(id)
Rem
Rem Valid values for status column (keep in sync status in the task table 
Rem and with kea.h):
Rem         2 - EXECUTING          
Rem         3 - COMPLETED
Rem         4 - INTERRUPTED     
Rem         5 - CANCELLED
Rem         6 - FATAL ERROR
Rem
Rem Notice that INITIAL (value=1) is the status of the task when it is created 
Rem and not of the execution. The status of the task is the status of the 
Rem current (i.e., last) execution. 
Rem
create table wri$_adv_executions
( 
 id                 number          not null,                /* execution id */
 task_id            number          not null,          /* associated task id */
 name               varchar2(30)    not null,   /* unique name for execution */
 description        varchar2(256),         /* optional execution description */
 exec_type          varchar2(30), /* type of the execution action to perform */
 exec_type_id       number,                      /* id of the execution type */
 advisor_id         number          not null,          /* associated advisor */
 exec_start         date,                            /* execution start time */
 exec_mtime         date            not null,      /* last modification time */
 exec_end           date,                              /* execution end time */
 status             number          not null,                 /* task status */
 status_msg_id      number,             /* id of msg group in messages table */
 error_msg_id       number,                                   /* error msg # */
 flags              number,                       /* flags: not used for now */
 constraint wri$_adv_execs_pk primary key (task_id, name)
    using index tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_adv_execs_idx_01
  on wri$_adv_executions (id)
  tablespace SYSAUX
/

create index wri$_adv_execs_idx_02
  on wri$_adv_executions (advisor_id, exec_start)
  tablespace SYSAUX
/

create index wri$_adv_execs_idx_03
  on wri$_adv_executions (task_id, exec_start)
  tablespace SYSAUX
/

create sequence wri$_adv_seq_exec            /* Generates unique exec number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem table storing task parameters for task executions. Parameters stored 
Rem in this table are specific to particular executions they were set 
Rem for when calling the dbms_advisor.execute_task() procedure. 
Rem This table is always empty for advisors that are single-execution tasks.
Rem
Rem       pk : (task_id, exec_name, name)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem
Rem  Values for datatypes and flags for parameters, see description above 
Rem  for wri$_adv_def_parameters and wri$_adv_parameters.
Rem
create table wri$_adv_exec_parameters
(
 task_id        number          not null,       /* id of the associated task */
 exec_name      varchar2(30)    not null,                 /* executuion name */
 name           varchar2(30)    not null,                  /* parameter name */
 value          varchar2(4000)  not null,                 /* parameter value */
 constraint wri$_adv_exec_parameters_pk primary key(task_id, exec_name, name)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table containing all the object instances that the advisor tasks refer too.
Rem These objects could be used for input as well as described in the
Rem output (recommendations). Objects are private to a task. Each object
Rem instance has a unique id.
Rem
Rem       pk : task_id, id
Rem       fk : task_id -> wri$_adv_tasks.id
Rem

create table wri$_adv_objects
(
 id             number          not null,      /* unique id for obj instance */
 type           number          not null,      /* type of object (namespace) */
                                               /* see kea.h for entire list. */
                                    /* 1=TABLE, 2=INDEX, 3=MVIEW 4=MVIEW LOG
                 5=UNDO RETENTION 6=UNDO TABLESPACE 5=SQL STATEMENT 6=SQLSET */
                                          /* 5= SQLWORKLOAD, 6=DATAFILE, ... */
 task_id        number          not null,         /* task assoc. w/ this obj */
 exec_name      varchar2(30),                      /* optional execution id. */
 attr1          varchar2(4000),                        /* attr of the object */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          clob,
 attr5          varchar2(4000),
 attr6          raw(2000),
 attr7          number,
 attr8          number,
 attr9          number,
 attr10         number,
 other          clob,                /* additional info associated to object */
 spare_n1       number,
 spare_n2       number,
 spare_n3       number,
 spare_n4       number,
 spare_c1       varchar2(4000),
 spare_c2       varchar2(4000),
 spare_c3       varchar2(4000),
 spare_c4       varchar2(4000),
 constraint wri$_adv_objects_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create unique index wri$_adv_objects_idx_01
  on wri$_adv_objects(task_id, exec_name, id)
  tablespace SYSAUX
/

Rem
Rem table storing the findings for each task
Rem       pk : (id, task_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem          : more_info_id -> wri$_adv_message_groups.id
Rem          : object_id -> wri$_adv_objects.id
Rem 

create table wri$_adv_findings
(
 id              number          not null,                    /* findings id */
 task_id         number          not null,                /* associated task */
 exec_name       varchar2(30),                     /* optional execution id. */
 type            number          not null,                /* type of finding */
 parent          number          not null,              /* parent finding id */
 obj_id          number,               /* id of the associated object if any */
 Impact_msg_id   number,                       /* impact due to this finding */
 impact_val      number,                                     /* impact value */
 msg_id          number,                   /* findings msg : id of msg group */
 more_info_id    number,                      /* id of msg grp for addn info */
 name_msg_code   varchar2(9),                              /* like SMG-00071 */
 filtered        char(1),                 /* is it filtered by a directive ? */
 flags           number,                           /* advisor-specific flags */
 constraint wri$_adv_findings_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create unique index wri$_adv_findings_idx_01 
  on wri$_adv_findings(task_id, exec_name, id) 
  tablespace SYSAUX
/

create unique index wri$_adv_findings_idx_02
  on wri$_adv_findings(task_id, exec_name, obj_id, id)
  tablespace SYSAUX
/

Rem
Rem Storing a breakdown of a finding impact to contributing instances.
Rem perc_impact is the percentage of the finding impact experiences in 
Rem the specific instance.
Rem
create table wri$_adv_inst_fdg
(
  task_id             number not null,
  finding_id          number not null,
  instance_number     number not null,
  exec_name           varchar2(30),                /* optional execution id. */
  perc_impact         number,
  primary key (task_id, finding_id, instance_number)
)
tablespace SYSAUX
/

Rem
Rem table storing the recommendations for each task
Rem       pk : (id, task_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem            findind_id -> wri$_adv_findings.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem 

create table wri$_adv_recommendations
(
 id              number          not null,                         /* rec id */
 task_id         number          not null,                /* associated task */
 type            varchar2(30),        /* rec. type. specific to each advisor */
 exec_name       varchar2(30),                      /* optional execution id */
 finding_id      number,                       /* related finding (optional) */
 rank            number,                           /* rank of recommendation */
 parent_recs     varchar2(4000),                          /* dependency list */
 benefit_msg_id  number,            /* benefit assoc w/ carrying out the rec */
 benefit_val     number,                                    /* benefit value */
 annotation      number,                              /* annotation status : */
                                                               /* ACCEPT = 1 */
                                                               /* REJECT = 2 */
                                                               /* IGNORE = 3 */
                                                          /* IMPLEMENTED = 4 */
 flags           number,                           /* Advisor-Specific flags */
 filtered        char(1),          /* is it filtered by a directive ? */
 constraint wri$_adv_rec_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_adv_recs_idx_01 
  on wri$_adv_recommendations(task_id, exec_name, id) 
  tablespace SYSAUX
/

create unique index wri$_adv_recs_idx_02 
  on wri$_adv_recommendations(task_id, exec_name, finding_id, id) 
  tablespace SYSAUX
/

Rem
Rem table storing the set of actions for the task. The association of
Rem actions to recommendations is provided in wri$_adv_rec_actions
Rem
Rem       pk : (task_id, id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : obj_id -> wri$_adv_objects.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem

create table wri$_adv_actions
(
 id             number          not null,                       /* action id */
 task_id        number          not null,                  /* associate task */
 exec_name      varchar2(30),                       /* optional execution id */
 obj_id         number,           /* object assoc with the action (optional) */
 command        number          not null,        /* command type (see kea.h) */
                          /* 1='CREATE INDEX', 2='CREATE MATERIALIZED VIEW', */
                                /* 3='ALTER TABLE', 4='CALL ADVISOR' etc ... */
 flags          number,                            /* Advisor-specific flags */
 attr1          varchar2(4000),            /* attributes defining the action */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          varchar2(4000),
 attr5          clob,
 attr6          clob,
 num_attr1      number,                         /* General numeric attribute */
 num_attr2      number,                         /* General numeric attribute */
 num_attr3      number,                         /* General numeric attribute */
 num_attr4      number,                         /* General numeric attribute */
 num_attr5      number,                         /* General numeric attribute */
 msg_id         number,                       /* action msg: id of msg group */
 filtered       char(1),          /* is it filtered by a directive ? */
 constraint wri$_adv_actions_pk primary key(task_id,id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table storing the rationale for each recommendation.
Rem
Rem       pk : (task_id, id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : find_id -> wri$_adv_findings.id
Rem          : rec_id -> wri$_adv_recommendations.id
Rem          : obj_id -> wri$_adv_objects.id
Rem          : msg_id -> wri$_adv_message_groups.id
REM          : impact_msg_id -> wri$_adv_message_groups.id
Rem
create table wri$_adv_rationale
(
 id             number          not null,                    /* rationale id */
 task_id        number          not null,                  /* associate task */
 exec_name      varchar2(30),           /* accociated execution id: optional */
 type           varchar2(30),    /* rationale type. specific to each advisor */
 rec_id         number,                         /* associated recommendation */
 impact_msg_id  number,               /* impact due to the finding described */
 impact_val     number,                                      /* impact value */
 obj_id         number,             /* object associated with this rationale */
 msg_id         number,                   /* rationale msg : id of msg group */
 attr1          varchar2(4000),         /* attributes defining the rationale */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          varchar2(4000),
 attr5          clob,
 constraint wri$_adv_rationale_pk primary key (task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/


Rem
Rem table storing the association of actions to recommendations. The relation
Rem is many-to-many within a task.
Rem
Rem       pk : (task_id, rec_id, act_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : act_id -> wri$_adv_actions.id
Rem          : rec_id -> wri$_adv_recommendations.id
Rem

create table wri$_adv_rec_actions
(
 task_id        number          not null,                 /* associated task */
 rec_id         number          not null,                 /* rec within task */
 act_id         number          not null,              /* action within task */
 constraint wri$_adv_rec_actions_pk primary key(task_id,rec_id,act_id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem   Directives table sequence
Rem

create sequence wri$_adv_seq_dir        /* Generates unique directive number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem Table defining directive metadata.
Rem

create table wri$_adv_directive_defs
(
  id              number not null,                /* Unique id for directive */
  advisor_id      number not null,                             /* Advisor id */
  domain          varchar2(30) not null,         /* Domain or namespace name */
  name            varchar2(30) not null,                   /* Secondary name */
  description     varchar2(256) not null,           /* Directive description */
  type#           number not null,                       /* 1 - Filter       */
                                                         /* 2 - Single value */
                                                         /* 3 - Multi value  */
                                                         /* 4 - Conditional  */
                                                         /* 5 - Constraint   */
  flags           number not null,                             /* Bit values */
                                        /* 1 - task must initial for updates */
                                          /* 2 - Supports multiple instances */
  metadata_id     number not null    /* Link to XML schema or DTD definition */
                                        /* Stored in wri$_adv_directive_meta */
)
tablespace sysaux
/

create index wri$_adv_dir_idx_01
  on wri$_adv_directive_defs (id)
tablespace sysaux;

create index wri$_adv_dir_idx_02
  on wri$_adv_directive_defs (domain,name,advisor_id)
tablespace sysaux;

create table wri$_adv_directive_meta
(
  id              number not null,    /* Unique id for schema element */
  data            clob not null   /* Schema or DTD */
)
tablespace sysaux
/

create index wri$_adv_dirm_idx_01
  on wri$_adv_directive_meta (id)
tablespace sysaux;

create sequence wri$_adv_seq_dir_inst
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem   Instances of directives
Rem

create table wri$_adv_directive_instances
(
  dir_id          number not null,                      /* Base directive id */
  inst_id         number not null,               /* Instance id of directive */
  name            varchar2(30) not null,        /* User supplied name.  Must */
                                               /* be unique among directives */
  task_id         number,                        /* Parent task id.  If zero */
                                                   /* the instance is global */
  data            clob not null                    /* XML data for directive */
)
tablespace sysaux
/

create index wri$_adv_dirinst_idx_01
  on wri$_adv_directive_instances (inst_id)
tablespace sysaux;

create index wri$_adv_dirinst_idx_02
  on wri$_adv_directive_instances (task_id,name,dir_id)
tablespace sysaux;

Rem
Rem Journal table
Rem
Rem   Valid values for the type column are:
Rem
Rem      1  - Fatal
Rem      2  - Error
Rem      3  - Warning
Rem      4  - Information
Rem      5  - Debug level 1
Rem      6  - Debug level 2
Rem      7  - Debug level 3
Rem      8  - Debug level 4
Rem      9  - Debug level 5

create sequence wri$_adv_seq_journal
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

create table wri$_adv_journal
   (
      task_id              number not null,               /* Current task id */
      exec_name            varchar2(30),         /* id of the task execution */
      seq_id               number not null,           /* Unique for the task */
      type                 number not null,   /* See comment for valid value */
      msg_id               number not null,         /* Message set id number */
      constraint wri$_adv_journal primary key(task_id,seq_id)
        using index tablespace SYSAUX
   )
tablespace sysaux
/


Rem
Rem This table stores the set of message ids along with its parameters
Rem for the message fields of all the other tables. 
Rem In general an advisor message is composed of a set of Oracle messages
Rem (each row in the table below is an Oracle message). Each set or group is
Rem given a unique id which is referenced by the message columns in the other
Rem tables.
Rem
Rem Each row is an Oracle message belonging to a facility (eg: ORA, ADV).
Rem The message definition captures formatting information too, since the
Rem advisor will be writing out user readable sentences. The three formatting
Rem fields include
Rem     hdr : a number used as a boolean that denotes if the msg hdr
Rem           (eg: ADV-2300: ) needs to be present in the output.
Rem     lm  : is the number of spaces inserted before the message.
Rem     nl  : is the number of new-lines to appear before the message. 
Rem 
Rem     pk  : id
Rem

create table wri$_adv_message_groups
(
 task_id        number          not null,               /* Task or object id */
 exec_name      varchar2(30),             /* if of the asscociated execution */
 id             number          not null,         /* unique id for msg group */
 seq            number          not null,    /* seq# of msg in message group */
 message#       number          not null,                 /* oracle message# */
 fac            varchar2(3),                         /* msg facility. eg ORA */
 hdr            number,                                /* 1 : include header */
                                                             /* 0: no header */
 lm             number,              /* left margin : #spaces to be inserted */
                                                               /* before msg */
 nl             number,                 /* number of newlines before message */
 p1             varchar2(4000),                          /* parameter values */
 p2             varchar2(4000),
 p3             varchar2(4000),
 p4             varchar2(4000),
 p5             varchar2(4000),
 constraint wri$_adv_message_groups_pk primary key(id, seq)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create index wri$_adv_msg_grps_idx_01
  on sys.wri$_adv_message_groups (task_id, id)
  tablespace SYSAUX
/

create sequence wri$_adv_seq_msggroup                      /* Message-set id */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem The following tables contain SQL related information. 
Rem These tables become part of the advisor framework as there is
Rem more than one advisor client which is using them now, such sqltune, 
Rem sqlpi, and sqldiag. 
Rem Initially, these tables belonged to sqltune advisor and they
Rem used to be created in catsqlt.sql.
Rem all sql plans are new in 11g except the plan table which exists since
Rem 10gR1.
Rem
---------------------------- wri$_adv_sqlt_plan_hash ---------------------------
-- NAME:
--     wri$_adv_sqlt_plan_hash
--
-- DESCRIPTION: 
--     This table stores information about query plans generated during a SQL
--     tuning or execution session.
--
-- PRIMARY KEY:
--     (task_id, exec_name, object_id, attribute)
--
-- FOREIGN KEY:
--     (task_id)   references wri$_adv_tasks(id) 
--     (object_id) references wri$_adv_objects(id) 
--     (exec_name) references wri$_adv_executions(name) 
-- FIXME: need to add sql_id to this table and its corresponding view. 
--------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_plan_hash
(
  task_id           NUMBER(38)    NOT NULL,     
  exec_name         VARCHAR2(30)  NOT NULL,
  object_id         NUMBER(38)    NOT NULL,   
  sql_id            VARCHAR2(13)  NOT NULL,
  attribute         NUMBER        NOT NULL,
  plan_hash         NUMBER        NOT NULL, 
  plan_id           NUMBER        NOT NULL,
  spare_n1          NUMBER,
  spare_n2          NUMBER,
  spare_n3          NUMBER,
  spare_n4          NUMBER,
  spare_n5          NUMBER,
  spare_c1          VARCHAR2(4000),
  spare_c2          VARCHAR2(4000),
  constraint  wri$_adv_sqlt_plan_hash_pk 
              primary key(task_id, exec_name, object_id, attribute)
              using index tablespace SYSAUX
)
tablespace SYSAUX
/
create unique index wri$_adv_sqlt_plan_hash_01 
on wri$_adv_sqlt_plan_hash(task_id, exec_name, sql_id, plan_id) 
tablespace sysaux
/

-----------------------------  wri$_adv_sqlt_plan_stats -----------------------
-- NAME:
--     wri$_adv_sqlt_plan_stats
--
-- DESCRIPTION: 
--     This table stores sqltune statistics for a SQL statement.
--
-- PRIMARY KEY:
--     plan_id
--
-- FOREIGN KEY:
--     (plan_id) references wri$_adv_plan_hash(plan_id) 
--
-- NOTES:
--     If you are adding new columns to this table with the intent of
--     supporting additional metrics in SPA, see the note 'ADDING NEW METRICS
--     TO SPA' at the top of prvtspai.sql
-------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_plan_stats
(
  plan_id            NUMBER NOT NULL,  
  parse_time         NUMBER, 
  exec_time          NUMBER,
  cpu_time           NUMBER,
  user_io_time       NUMBER,
  buffer_gets        NUMBER,
  disk_reads         NUMBER,
  direct_writes      NUMBER,
  rows_processed     NUMBER,
  fetches            NUMBER,
  executions         NUMBER,
  end_of_fetch_count NUMBER,
  optimizer_cost     NUMBER,
  other              CLOB,
  io_interconnect_bytes          NUMBER,
  spare_n1                       NUMBER, /* physical read requests */
  spare_n2                       NUMBER, /* physical write requests */
  spare_n3                       NUMBER, /* physical read bytes */
  spare_n4                       NUMBER, /* physical write bytes */
  spare_n5                       NUMBER,
  spare_c1                       VARCHAR2(4000),
  spare_c2                       VARCHAR2(4000),
  spare_c3                       CLOB,
  testexec_total_execs NUMBER,
  flags              NUMBER,
  spare_n6                       NUMBER,
  spare_n7                       NUMBER,
  spare_n8                       NUMBER,
  spare_n9                       NUMBER,
  spare_n10                      NUMBER,
  constraint  wri$_adv_sqlt_plan_stats_pk primary key(plan_id)
  using index tablespace SYSAUX
)
tablespace SYSAUX  
/

------------------------------ wri$_adv_sqlt_plans ----------------------------
-- NAME:
--     wri$_adv_sqlt_plans
--
-- DESCRIPTION: 
--     This table stores the query plans generated during a SQL
--     tuning session.
--
-- PRIMARY KEY:
--     (plan_id, id)
--
-- FOREIGN KEY:
--     (plan_id)   references wri$_adv_plan_hash(plan_id) 
-------------------------------------------------------------------------------
CREATE TABLE wri$_adv_sqlt_plans 
(
  task_id           NUMBER(38),     
  object_id         NUMBER(38) ,   
  attribute         NUMBER,
  plan_hash_value   NUMBER, 
  plan_id           NUMBER          NOT NULL,
  statement_id      VARCHAR2(30),
  timestamp         DATE,
  remarks           VARCHAR2(4000),
  operation         VARCHAR2(30),
  options           VARCHAR2(255),
  object_node       VARCHAR2(128),
  object_owner      VARCHAR2(30),
  object_name       VARCHAR2(30),
  object_alias      VARCHAR2(65),
  object_instance   NUMBER(38),
  object_type       VARCHAR2(30),
  optimizer         VARCHAR2(255),
  search_columns    NUMBER,
  id                NUMBER(38),
  parent_id         NUMBER(38),
  depth             NUMBER(38),
  position          NUMBER(38),
  cost              NUMBER(38),
  cardinality       NUMBER(38),
  bytes             NUMBER(38),
  other_tag         VARCHAR2(255),
  partition_start   VARCHAR2(255),
  partition_stop    VARCHAR2(255),
  partition_id      NUMBER(38),
  other             LONG,
  distribution      VARCHAR2(30),
  cpu_cost          NUMBER(38),
  io_cost           NUMBER(38),
  temp_space        NUMBER(38),
  access_predicates VARCHAR2(4000),
  filter_predicates VARCHAR2(4000),
  projection        VARCHAR2(4000),
  time              NUMBER(38),
  qblock_name       VARCHAR2(30),
  other_xml         CLOB,
  constraint  wri$_adv_sqlt_plans_pk 
              primary key(plan_id, id)
              using index tablespace SYSAUX
)
tablespace SYSAUX
/

----------------------------- WRI$_ADV_SQLT_PLAN_SEQ ---------------------------
-- NAME:
--     WRI$_ADV_SQLT_PLAN_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for SQL statement plans in 
--     WRI$_ADV_SQLT_PLAN_HASH.
--     The sequence max vlaue = UB8MAXVAL
--------------------------------------------------------------------------------
CREATE SEQUENCE WRI$_ADV_SQLT_PLAN_SEQ
  INCREMENT BY 1
  START WITH 1
  MAXVALUE 18446744073709551615
  CACHE 100
  NOCYCLE
/


Rem
Rem this table is used for tracking advisor usage.
Rem
Rem      pk: advisor_id
Rem      fk: wri$_adv_definitions.id
Rem

create table wri$_adv_usage
(
  advisor_id        number      not null,                      /* advisor id */
  last_exec_time    date        not null,    /* date that some task for this */
                                                     /* advisor was executed */
  num_execs         number      not null,   /* number of non-AUTO executions */
  /* NOTE: the default value is needed when downgrading to 11.1/10.2 to keep
   * prvt_advisor from breaking */
  num_db_reports    number      default 0 not null,     /* # of reports from
                                              command line (not counting EM) */ 
  first_report_time date,                   /* first tracked get_report date */
  last_report_time  date,                      /* latest tracked report date */
  constraint  wri$_adv_usage_pk 
              primary key(advisor_id)
              using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem subtype definition for the HDM
Rem

CREATE OR REPLACE TYPE wri$_adv_hdm_t UNDER wri$_adv_abstract_t
(
  OVERRIDING MEMBER procedure sub_execute (task_id IN NUMBER,
                                           err_num OUT NUMBER),
  overriding member procedure sub_get_report (task_id IN NUMBER,
                                              type IN VARCHAR2,
                                              level IN VARCHAR2,
                                              section IN VARCHAR2,
                                              buffer IN OUT NOCOPY CLOB),
  overriding member procedure sub_reset(task_id in number),
  overriding member procedure sub_delete(task_id in number),
  overriding MEMBER PROCEDURE sub_param_validate(
              task_id in number,
              name in varchar2, 
              value in out varchar2)
);
/


create table wri$_adv_addm_tasks
(
  task_id             number not null,
  dbid                number,
  dbname              varchar2(9),
  dbversion           varchar2(17),
  analysis_version    varchar2(17),
  begin_snap_id       number,
  begin_time          timestamp(3),
  end_snap_id         number,
  end_time            timestamp(3),
  requested_analysis  varchar2(8),
  actual_analysis     varchar2(8),
  database_time       number,
  active_sessions     number,
  perc_flush_time     number,
  perc_mw_time        number,
  meter_level         varchar2(6),
  primary key (task_id)
)
tablespace sysaux
/

create index wri$_adv_addm_tasks_idx_01
  on wri$_adv_addm_tasks (dbid, begin_snap_id, end_snap_id)
  tablespace SYSAUX;

create table wri$_adv_addm_inst
(
  task_id             number not null,
  instance_number     number not null,
  instance_name       varchar2(16),
  host_name           varchar2(64),
  status              varchar2(10),
  database_time       number,
  active_sessions     number,
  perc_active_sess    number,
  perc_flush_time     number,
  meter_level         varchar2(6),
  local_task_id       number,    
  primary key (task_id, instance_number)
)
tablespace sysaux
/

create table wri$_adv_addm_fdg
(
  task_id             number not null,
  finding_id          number not null,
  rule_id             number,
  addm_fdg_id         number,
  addm_seq            number,
  database_time       number,
  active_sessions     number,
  perc_active_sess    number,
  is_aggregate        char(1),
  meter_level         varchar2(6),
  query_type          number,
  query_is_approx     char(1),
  query_args          varchar2(4000),
  primary key (task_id, finding_id)
)
tablespace sysaux
/

Rem
Rem  Set up Access Advisor definition
Rem

CREATE OR REPLACE TYPE wri$_adv_sqlaccess_adv under wri$_adv_abstract_t
  (
    overriding member procedure sub_create(task_id in number,
                                           from_task_id in number),
    overriding member procedure sub_execute(task_id in NUMBER,
                                            err_num out number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_resume(task_id in number, 
                                           err_num out number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_script (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB,
                                                rec_id IN NUMBER,
                                                act_id IN NUMBER),
    overriding member procedure sub_get_report (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                level IN VARCHAR2,
                                                section IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB),
    overriding member procedure sub_validate_directive(task_id IN NUMBER,
                                          command_id IN NUMBER,
                                          attr1 IN OUT VARCHAR2,
                                          attr2 IN OUT VARCHAR2,
                                          attr3 IN OUT VARCHAR2,
                                          attr4 IN OUT VARCHAR2,
                                          attr5 IN OUT VARCHAR2),
    overriding member procedure sub_update_rec_attr (task_id IN NUMBER,
                                                     rec_id IN NUMBER,
                                                     act_id IN NUMBER,
                                                     name IN VARCHAR2,
                                                     value IN VARCHAR2),
    overriding member procedure sub_get_rec_attr (task_id IN NUMBER,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER,
                                                  name IN VARCHAR2,
                                                  value OUT VARCHAR2),
    overriding member procedure sub_cleanup(task_id in number),
    overriding member procedure sub_implement(task_id IN NUMBER),
    overriding member procedure sub_implement(task_id in number, 
                                              rec_id in number,
                                              exit_on_error in number),
    overriding member procedure sub_user_setup(adv_id in number),
    overriding member procedure sub_import_directives (task_id in number,
                                          from_id in number,
                                          import_mode in varchar2,
                                          accepted out number,
                                          rejected out number),
    overriding member procedure sub_quick_tune (task_name in varchar2,
                                                attr_clob in clob,
                                                attr_vc in varchar2,
                                                attr_num in number,
                                                template in varchar2,
                                                implement in boolean)
  );
/

Rem
Rem Access Advisor Tune MView
Rem

CREATE OR REPLACE TYPE wri$_adv_tunemview_adv under wri$_adv_abstract_t
  (
    overriding member procedure sub_execute(task_id in NUMBER,
                                            err_num out number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_resume(task_id in number, 
                                           err_num out number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_script (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB,
                                                rec_id IN NUMBER,
                                                act_id IN NUMBER),
    overriding member procedure sub_validate_directive(task_id IN NUMBER,
                                          command_id IN NUMBER,
                                          attr1 IN OUT VARCHAR2,
                                          attr2 IN OUT VARCHAR2,
                                          attr3 IN OUT VARCHAR2,
                                          attr4 IN OUT VARCHAR2,
                                          attr5 IN OUT VARCHAR2),
    overriding member procedure sub_update_rec_attr (task_id IN NUMBER,
                                                     rec_id IN NUMBER,
                                                     act_id IN NUMBER,
                                                     name IN VARCHAR2,
                                                     value IN VARCHAR2),
    overriding member procedure sub_get_rec_attr (task_id IN NUMBER,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER,
                                                  name IN VARCHAR2,
                                                  value OUT VARCHAR2),
    overriding member procedure sub_cleanup(task_id in number),
    overriding member procedure sub_implement(task_id IN NUMBER),
    overriding member procedure sub_implement(task_id in number, 
                                              rec_id in number,
                                              exit_on_error in number),
    overriding member procedure sub_user_setup(adv_id in number),
    overriding member procedure sub_import_directives (task_id in number,
                                          from_id in number,
                                          import_mode in varchar2,
                                          accepted out number,
                                          rejected out number),
    overriding member procedure sub_quick_tune (task_name in varchar2,
                                                attr_clob in clob,
                                                attr_vc in varchar2,
                                                attr_num in number,
                                                template in varchar2,
                                                implement in boolean)
  );
/

Rem
Rem  Access Advisor workload manager
Rem

create OR REPLACE type wri$_adv_workload under wri$_adv_abstract_t
  (
    overriding member procedure sub_create(task_id in number,
                                           from_task_id in number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_report (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                level IN VARCHAR2,
                                                section IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB),
    overriding member procedure sub_user_setup(adv_id in number)
  );
/


Rem
Rem subtype definition for Undo Advisor
Rem

create OR replace type wri$_adv_undo_adv UNDER wri$_adv_abstract_t
  (
    OVERRIDING MEMBER PROCEDURE sub_execute(task_id IN NUMBER,
                                            err_num OUT NUMBER)
  );
/

--------------------------------------------------------------------------------
--                     wri$_adv_sqltune sub type definition                   --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- NAME: 
--     wri$_adv_sqltune  
--
-- DESCRIPTION: 
--     This is a sub-type object type that implements the SQL Tuning Advisor.
--     It is mainly used to integrate the advisor within the Advisor Framework. 
--     The implementation of this type resides in .../sqltune/prvtsqlt.sql
--------------------------------------------------------------------------------
create OR replace type wri$_adv_sqltune under wri$_adv_abstract_t 
(    
  overriding MEMBER PROCEDURE sub_execute(task_id IN NUMBER, 
                                          err_num OUT NUMBER),
  overriding MEMBER PROCEDURE sub_reset(task_id IN NUMBER),
  overriding MEMBER PROCEDURE sub_resume(task_id IN NUMBER, 
                                         err_num OUT NUMBER),
  overriding MEMBER PROCEDURE sub_delete(task_id IN NUMBER),
  overriding MEMBER PROCEDURE sub_delete_execution(task_id IN NUMBER,
                                                   execution_name IN VARCHAR2), 
  overriding MEMBER PROCEDURE sub_get_script(task_id        IN NUMBER,
                                             type           IN VARCHAR2,
                                             buffer         IN OUT NOCOPY CLOB,
                                             rec_id         IN NUMBER,
                                             act_id         IN NUMBER,
                                             execution_name IN VARCHAR2,
                                             object_id      IN NUMBER),
  overriding MEMBER PROCEDURE sub_get_report(task_id        IN NUMBER,
                                             type           IN VARCHAR2,
                                             level          IN VARCHAR2,
                                             section        IN VARCHAR2,
                                             buffer         IN OUT NOCOPY CLOB,
                                             execution_name IN VARCHAR2,
                                             object_id      IN NUMBER),
 overriding member procedure sub_param_validate(task_id IN NUMBER,
                                                name    IN VARCHAR2, 
                                                value   IN OUT VARCHAR2)
) NOT FINAL
/  

--------------------------------------------------------------------------------
--                      wri$_adv_spi sub type definition                      --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- NAME: 
--     wri$_adv_sqlpi: SQL Performance Impact analyzer
--
-- DESCRIPTION: 
--     This is a sub-type object type that implements the SQL performance change
--     impact analysis advisor. 
--     This type is created under the sqltune object type so that it can inherit
--     all sqltune methods.
--------------------------------------------------------------------------------
create OR replace type wri$_adv_sqlpi under wri$_adv_sqltune 
(    
) FINAL
/  
--------------------------------------------------------------------------------

Rem
Rem  Subtype for Object Space Growth Trend Advisor
Rem

create OR replace type wri$_adv_objspace_trend_t under wri$_adv_abstract_t
(
  overriding member procedure sub_execute (task_id IN  NUMBER,
                                           err_num OUT NUMBER)
);
/

Rem
Rem  Subtype for Compression Advisor
Rem
  
create OR replace type wri$_adv_compression_t under wri$_adv_abstract_t
(
  overriding member procedure sub_execute (task_id IN  NUMBER,
                                           err_num OUT NUMBER),
  overriding member procedure sub_get_report (task_id IN NUMBER,
                                              type IN VARCHAR2,
                                              level IN VARCHAR2,
                                              section IN VARCHAR2,
                                              buffer IN OUT NOCOPY CLOB)
);
/

Rem
Rem  Drop tuning tasks when a user is dropped
Rem
  
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='PRVT_ADVISOR' and
  proc='DELETE_USER_TASKS' and operation#=1
/
INSERT INTO sys.duc$ (owner,pack,proc,operation#,seq,com)
  VALUES ('SYS','PRVT_ADVISOR','DELETE_USER_TASKS',1,1,
  'During drop cascade, drop advisor tasks belonging to user')
/
commit
/
  
Rem
Rem NOTE: all advisor and parameter definitions are now placed in
Rem prvtdadv.sql in procedure SETUP_REPOSITORY.
Rem

