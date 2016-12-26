Rem
Rem $Header: dbmsadv.sql 13-mar-2008.14:50:50 amitsha Exp $
Rem
Rem dbmsadv.sql
Rem
Rem Copyright (c) 2002, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsadv.sql - Advisor package definitions
Rem
Rem    DESCRIPTION
Rem      This is the public package for the Advisor API.
Rem
Rem    NOTES
Rem      None
Rem
Rem MODIFIED (MM/DD/YY)
Rem amitsha   03/12/08 - add Compression advisor
Rem kyagoub   04/18/07 - change name of sql replay advisor
Rem gssmith   02/07/07 - Remove obsolete SAA procedure
Rem ushaft    01/23/07 - added constants for advisor names and ids
Rem akoeller  10/09/06 - Bug 5570399 - Use STS from other users
Rem kyagoub   06/22/06 - rename paramList to argList 
Rem ushaft    05/09/06 - added param to format_message_group
Rem gssmith   06/04/06 - A
Rem akoeller  05/31/06 - Partition advisor support 
Rem gssmith   05/03/06 - 11g Directives 
Rem kyagoub   04/10/06 - add support for multi-executions 
Rem gssmith   07/27/04 - Add overloaded AA function 
Rem mjaeger   07/14/04 - bug 3592731: get_task_report: TYPE is only TEXT,
Rem                      not XML+HTML
Rem gssmith   04/20/04 - Bug 3501493
Rem gssmith   02/03/04 - Adding new formatter for param descriptions
Rem gssmith   10/28/03 - Bug 3206172
Rem gssmith   10/14/03 - Remove obsolete AA call
Rem gssmith   10/23/03 - Bug 3207351
Rem kdias     10/06/03 - extend task read APIs to take in user name
Rem gssmith   10/09/03 - Add Access Advisor routine
Rem slawande  09/03/03 - Remove search prm from import_sqlwkld_schema
Rem gssmith   04/30/03 - AA workload adjustments
Rem ushaft    03/07/03 - added procedure set_default_task_param
Rem gssmith   03/26/03 - Bug 2869857
Rem gssmith   03/18/03 - Adjust Access Advisor column names
Rem gssmith   01/09/03 - Bug 2741448 - script buffer
Rem gssmith   10/29/02 - Bug 2647661
Rem kyagoub   11/05/02 - export the check_privs procedure
Rem twtong    10/21/02 - switch argument order in tune_mview
Rem gssmith   10/18/02 - Fix for bug 2632875
Rem kdias     10/09/02 -
Rem kdias     10/04/02 -  add create/update object APIs
Rem mxiao     10/13/02 - change tune_mview interface
Rem tfyu      09/26/02 - add tune_mview
Rem gssmith   09/13/02 - Adding template support
Rem gssmith   09/10/02 - Correct constants
Rem gssmith   07/12/02 - Created
Rem

Rem
Rem   Advisor package declaration
Rem

CREATE OR REPLACE PACKAGE dbms_advisor
  authid current_user
IS

-------------------------------------------------------------------------------
-- Advisor names and ids
--
--  NOTE:  DO NOT CHANGE THE ADVISOR ID NUMBERS!!!!!!
--         External code may rely on advisor names as well. 
--         Do not change names or numbers between releases.
--
-------------------------------------------------------------------------------

ADV_NAME_DEFAULT         constant varchar2(30) := 'Default Advisor';
ADV_NAME_ADDM            constant varchar2(30) := 'ADDM';
ADV_NAME_SQLACCESS       constant varchar2(30) := 'SQL Access Advisor';
ADV_NAME_UNDO            constant varchar2(30) := 'Undo Advisor';
ADV_NAME_SQLTUNE         constant varchar2(30) := 'SQL Tuning Advisor';
ADV_NAME_SEGMENT         constant varchar2(30) := 'Segment Advisor';
ADV_NAME_SQLWM           constant varchar2(30) := 'SQL Workload Manager';
ADV_NAME_TUNEMV          constant varchar2(30) := 'Tune MView';
ADV_NAME_SQLPA           constant varchar2(30) := 'SQL Performance Analyzer';
ADV_NAME_SQLREPAIR       constant varchar2(30) := 'SQL Repair Advisor';
ADV_NAME_COMPRESS        constant varchar2(30) := 'Compression Advisor';

ADV_ID_DEFAULT           constant number := 0;
ADV_ID_ADDM              constant number := 1;
ADV_ID_SQLACCESS         constant number := 2;
ADV_ID_UNDO              constant number := 3;
ADV_ID_SQLTUNE           constant number := 4;
ADV_ID_SEGMENT           constant number := 5;
ADV_ID_SQLWM             constant number := 6;
ADV_ID_TUNEMV            constant number := 7;
ADV_ID_SQLPA             constant number := 8;
ADV_ID_SQLREPAIR         constant number := 9;
ADV_ID_COMPRESS          constant number := 10;

-------------------------------------------------------------------------------
-- Common constants
-------------------------------------------------------------------------------

ADVISOR_ALL           constant number       := -995;
ADVISOR_CURRENT       constant number       := -996;
ADVISOR_DEFAULT       constant number       := -997;
ADVISOR_UNLIMITED     constant number       := -998;
ADVISOR_UNUSED        constant number       := -999;

-------------------------------------------------------------------------------
-- SQL Access Advisor constants
-------------------------------------------------------------------------------

SQLACCESS_GENERAL       constant varchar2(20) := 'SQLACCESS_GENERAL';
SQLACCESS_OLTP          constant varchar2(20) := 'SQLACCESS_OLTP';
SQLACCESS_WAREHOUSE     constant varchar2(20) := 'SQLACCESS_WAREHOUSE';

SQLACCESS_ADVISOR       constant varchar2(30) := ADV_NAME_SQLACCESS;
TUNE_MVIEW_ADVISOR      constant varchar2(30) := ADV_NAME_TUNEMV;
SQLWORKLOAD_MANAGER     constant varchar2(30) := ADV_NAME_SQLWM;

-------------------------------------------------------------------------------
-- Common types
-------------------------------------------------------------------------------
-- this type is used to pass a list of task prameters to the execute_task
-- function. This is used only for advisor that support multi-execution.
TYPE argList IS TABLE OF sys.wri$_adv_parameters.value%TYPE; 

-- this type is identical to VARCHAR2S from the DBMS_SQL package and 
-- is redefined here due to bootstrapping problems
TYPE varchar2adv IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
--    The following procedures are common to all advisors
-------------------------------------------------------------------------------

--    PROCEDURE DBMS_ADVISOR.CANCEL_TASK
--    PURPOSE: Cancels a currently executing task operation.  All intermediate
--             and result data will be removed from the task.
--    ADVISOR SUPPORT:     SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Valid task name

procedure cancel_task (task_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.CREATE_TASK
--    PURPOSE: Creates a new advisor task in the repository
--    ADVISOR SUPPORT:     All advisors
--    PARAMETERS:
--         ADVISOR_NAME
--            Name of the advisor that will use the task for its operations.
--            Advisors are defined in the DBA_ADVISOR_DEFINITIONS table.
--         TASK_ID
--            Returns a system-generated task identifier number.
--         TASK_NAME
--            An optional task name.  Task names must be unique to the user.
--            If not specified, a name will be generated by the system.
--         TASK_DESC
--            An optional value that provides a meaningful description of the
--            intended use of the task.
--         TEMPLATE
--            Optional task that will be used to set default values for the
--            new task.
--         IS_TEMPLATE
--            Optional boolean to set the new task as template
--         HOW_CREATED
--            Optional how identifier

procedure create_task (advisor_name          in varchar2,
                       task_id               out number,
                       task_name             in out varchar2,
                       task_desc             in varchar2 := null,
                       template              in varchar2 := null,
                       is_template           in varchar2 := 'FALSE',
                       how_created           in varchar2 := null);

--    PROCEDURE DBMS_ADVISOR.CREATE_TASK
--    PURPOSE: Creates a new advisor task in the repository
--    ADVISOR SUPPORT:     All advisors
--    PARAMETERS:
--         ADVISOR_NAME
--            Name of the advisor that will use the task for its operations.
--            Advisors are defined in the DBA_ADVISOR_DEFINITIONS table.
--         TASK_NAME
--            Task names must be unique to the user.
--         TASK_DESC
--            An optional value that provides a meaningful description of the
--            intended use of the task.
--         TEMPLATE
--            Optional task that will be used to set default values for the
--            new task.
--         IS_TEMPLATE
--            Optional boolean to set the new task as template
--         HOW_CREATED
--            Optional source identifier

procedure create_task (advisor_name          in varchar2,
                       task_name             in varchar2,
                       task_desc             in varchar2 := null,
                       template              in varchar2 := null,
                       is_template           in varchar2 := 'FALSE',
                       how_created           in varchar2 := null);

--    PROCEDURE DBMS_ADVISOR.CREATE_TASK
--    PURPOSE: Creates a new advisor task as a child task of an existing task.
--             This version of CREATE_TASK is for use by controlling advisors
--             such as HDM.
--    ADVISOR SUPPORT:     All advisors
--    PARAMETERS:
--         PARENT_TASK_NAME
--            Name of the parent task that is starting the sub-advisor 
--            operation.
--         REC_ID
--            The recommendation idenfier to which the new task will be
--            associated.
--         TASK_ID
--            Returns a system-generated task identifier number.
--         TASK_NAME
--            An optional task name.  Task names must be unique to the user.
--            If not specified, a name will be generated by the system.
--         TASK_DESC
--            An optional value that provides a meaningful description of the
--            intended use of the task.
--         TEMPLATE
--            Optional task that will be used to set default values for the
--            new task.

procedure create_task (parent_task_name      in varchar2,
                       rec_id                in number,
                       task_id               out number,
                       task_name             in out varchar2,
                       task_desc             in varchar2,
                       template              in varchar2);

--    PROCEDURE DBMS_ADVISOR.DELETE_TASK
--    PURPOSE: Deletes the specified task from the repository
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--
procedure delete_task (task_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.EXECUTE_TASK
--    PURPOSE: Executes the specified task. This procedure has two flavors.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--    NOTICE:
--         This procedure is kept for backward compatibility 
--         and for advisor that do not support multiple executions 
--         tasks or simply because they do not want to be exposed to
--         the concept of execution
--
procedure execute_task(task_name IN VARCHAR2);

--    FUNCTION EXECUTE_TASK
--    PURPOSE: Executes the specified task. There two flavors of this procedure.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         EXECUTION_TYPE 
--            Type of the action to perform by the function. 
--            If NULL it will default to the value of the DEFAULT_EXECUTION_TYPE
--            parameter. 
--         EXECUTION_NAME 
--           A name to qualify and identify an execution. If not specified, it 
--           be generated by the advisor and returned by function. 
--         EXECUTION_DESC
--           A 256-length string describing the execution. 
--         EXECUTION_PARAMS
--           List of parameters (name, value) for the specified execution. 
--           Notice that execution parameters are real task parameters that are 
--           have effect only on the execution they sepecified for. 
--           Example: arglist('time_limit', 12, 'username', 'foo')
--   RETURN:
--        Name of the execution
FUNCTION execute_task(
  task_name        IN VARCHAR2,
  execution_type   IN VARCHAR2 := NULL,
  execution_name   IN VARCHAR2 := NULL,
  execution_desc   IN VARCHAR2 := NULL, 
  execution_params IN argList  := NULL) 
RETURN VARCHAR2;

--    PROCEDURE DBMS_ADVISOR.INTERRUPT_TASK
--    PURPOSE: Stops a currently executing task.  The task will end its
--             operations as it would at a normal exit.  The user will be able
--             to access any recommendations that exist to this point.
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--
procedure interrupt_task (task_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.MARK_RECOMMENDATION
--    PURPOSE: Sets the annotation_status for a particulare recommendation
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         ID
--            Recommendation identifier number
--         ACTION
--            Status of the recommendation

procedure mark_recommendation (task_name       in varchar2,
                               id              in number,
                               action          in varchar2);

--    PROCEDURE DBMS_ADVISOR.RESET_TASK
--    PURPOSE: Resets a task to its initial state.  All intermediate and
--             recommendation data will be deleted.
--    ADVISOR SUPPORT:        All Advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--
procedure reset_task(task_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.RESUME_TASK
--    PURPOSE: Resumes a previously interrupted task.
--    ADVISOR SUPPORT:        None
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--
procedure resume_task(task_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.SET_TASK_PARAMETER
--    PURPOSE: Sets the specified task parameter value.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         PARAMETER
--            Name of the task parameter
--         VALUE
--            Value to be set

procedure set_task_parameter (task_name      in varchar2,
                              parameter      in varchar2,
                              value          in varchar2);

procedure set_task_parameter (task_name      in varchar2,
                              parameter      in varchar2,
                              value          in number);

--    PROCEDURE DBMS_ADVISOR.SET_DEFAULT_TASK_PARAM
--    PURPOSE: Sets the specified task parameter value as default for
--             all new tasks of a specific type
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         ADVISOR_NAME
--            Name of the advisor type
--         PARAMETER
--            Name of the task parameter
--         VALUE
--            Value to be set

procedure set_default_task_parameter (advisor_name   in varchar2,
                                      parameter      in varchar2,
                                      value          in varchar2);

procedure set_default_task_parameter (advisor_name   in varchar2,
                                      parameter      in varchar2,
                                      value          in number);

--    PROCEDURE DBMS_ADVISOR.CREATE_OBJECT
--    PURPOSE: Creates a new task object
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         OBJECT_TYPE
--            Type of Advisor Object being created.
--            See dba_advisor_object_types
--         ATTR1
--            Attribute of the object
--         ATTR2
--            Attribute of the object
--         ATTR3
--            Attribute of the object
--         ATTR4
--            Attribute of the object
--         ATTR5
--            Attribute of the object
--         OBJECT_ID
--            OUT Param: Generated ID for the object

PROCEDURE create_object(task_name     IN VARCHAR2 ,
                        object_type   IN VARCHAR2 ,
                        attr1         IN VARCHAR2 := null,
                        attr2         IN VARCHAR2 := null,
                        attr3         IN VARCHAR2 := null,
                        attr4         IN clob := NULL,
                        object_id    OUT NUMBER);


PROCEDURE create_object(task_name     IN VARCHAR2 ,
                        object_type   IN VARCHAR2 ,
                        attr1         IN VARCHAR2 := null,
                        attr2         IN VARCHAR2 := null,
                        attr3         IN VARCHAR2 := null,
                        attr4         IN clob := NULL,
                        attr5         IN VARCHAR2 := null,
                        object_id    OUT NUMBER);

--    PROCEDURE DBMS_ADVISOR.UPDATE_OBJECT
--    PURPOSE: Updates an existing task object
--             Parameters that are NULL will have no effect on the
--             existing value of the column
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         OBJECT_ID
--            Id of the object
--         ATTR1
--            Attribute of the object
--         ATTR2
--            Attribute of the object
--         ATTR3
--            Attribute of the object
--         ATTR4
--            Attribute of the object
--         ATTR5
--            Attribute of the object

PROCEDURE update_object(task_name     IN VARCHAR2 ,
                        object_id     IN NUMBER ,
                        attr1         IN VARCHAR2 := null,
                        attr2         IN VARCHAR2 := null,
                        attr3         IN VARCHAR2 := null,
                        attr4         IN clob := NULL,
                        attr5         IN VARCHAR2 := null);


--    PROCEDURE DBMS_ADVISOR.CREATE_FILE
--    PURPOSE: Creates an output file and writes the buffer to the
--             file.
--    ADVISOR SUPPORT:        All Advisors
--    PARAMETERS:
--         BUFFER
--            Buffer to write to the file
--         LOCATION
--            Valid directory object where the file will be placed.  A
--            directory object must be defined using the SQL CREATE
--            DIRECTORY command.
--         FILENAME
--            Name of the output file to receive the report information.

procedure create_file (buffer         in clob,
                       location       in varchar2,
                       filename       in varchar2);

--    FUNCTION DBMS_ADVISOR.GET_TASK_REPORT
--    PURPOSE: Creates and returns a report for the specified task.
--    ADVISOR SUPPORT:        All Advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task from which the report will be created.
--         TYPE
--            Possible values are: TEXT.
--            Note that in the future, HTML and XML will be supported.
--         LEVEL
--            Possible values are BASIC, TYPICAL, and ALL
--         SECTION
--            Advisor-specific report sections
--         OWNER_NAME
--            Owner of the task. If specified the system will check to see
--            if the current user has read privileges to the task data.
--         EXECUTION_NAME
--            Identifier of a specific exectuion of the task. 
--            This is needed by only advisors that allows their tasks 
--            to be executed mutilple times.
--         OBJECT_ID
--            Identifier of an advisor object (from dba/user_advisor_objects)
--            that can be targeted by the report. 
--    Returns:
--         Return buffer receiving the report
function get_task_report (task_name      in varchar2,
                          type           in varchar2 := 'TEXT',
                          level          in varchar2 := 'TYPICAL',
                          section        in varchar2 := 'ALL',
                          owner_name     in varchar2 := NULL,
                          execution_name in varchar2 := NULL,
                          object_id      in number   := NULL)
  return clob;

--    FUNCTION DBMS_ADVISOR.GET_TASK_SCRIPT
--    PURPOSE: Creates and returns executable script for the specified task.
--    ADVISOR SUPPORT:        All Advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task from which the script will be created.
--         TYPE
--            Script type.  A set recommendation actions can exist that
--            either implement a change or undo a change.  Valid values are:
--                IMPLEMENTATION
--                UNDO
--         REC_ID
--            Optional recommendation id to extract a single recommendation
--         ACT_ID
--            Optional action id to extract a single action as a script
--         OWNER_NAME
--            Optional task owner
--         EXECUTION_NAME
--            Identifier of a specific exectuion of the task. 
--            This is needed by only advisors that allows their tasks 
--            to be executed mutilple times.
--         OBJECT_ID
--            Identifier of an advisor object (from dba/user_advisor_objects)
--            that can be targeted by the script. 
--    Returns:
--         Return buffer receiving the script
function get_task_script (task_name      in varchar2,
                          type           in varchar2 := 'IMPLEMENTATION',
                          rec_id         in number   := NULL,
                          act_id         in number   := NULL,
                          owner_name     in varchar2 := NULL,
                          execution_name in varchar2 := NULL,
                          object_id      in number   := NULL)
  return clob;

--    PROCEDURE DBMS_ADVISOR.IMPLEMENT_TASK
--    PURPOSE: Implements the recommendations of the specified task.
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         REC_ID
--            Optional recommendation id
--         EXIT_ON_ERROR
--            Optional boolean to exit on first error

procedure implement_task (task_name       in varchar2,
                          rec_id          in number := NULL,
                          exit_on_error   in boolean := NULL);

--    PROCEDURE DBMS_ADVISOR.QUICK_TUNE
--    PURPOSE: Performs an analysis given 1 to 3 simple attributes
--    ADVISOR SUPPORT:        All Advisors
--    PARAMETERS:
--         ADVISOR_NAME
--            Name of the advisor that will perform the analysis
--         TASK_NAME
--            Task names must be unique to the user.
--         ATTR1
--            Attribute 1 - advisor-specific data
--         ATTR2
--            Attribute 2 - advisor-specific data
--         ATTR3
--            Attribute 3 - advisor-specific data
--         TEMPLATE
--            Name of a task or template from which initial settings will
--            copied.
--         IMPLEMENT
--            Boolean to signal implementation
--         DESCRIPTION
--            Optional description of the task

procedure quick_tune (advisor_name           in varchar2,
                      task_name              in varchar2,
                      attr1                  in clob := null,
                      attr2                  in varchar2 := null,
                      attr3                  in number := null,
                      template               in varchar2 := null,
                      implement              in boolean := FALSE,
                      description            in varchar2 := null);

--    PROCEDURE DBMS_ADVISOR.TUNE_MVIEW
--    PURPOSE: Tune a Create Materialized View statement to
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            The user can pass in a user-defined task name or
--            get a returned system-generated task name.
--         MV_CREATE_STMT
--            CREATE MATERIALIZED VIEW SQL statement to tune

procedure tune_mview (task_name      in out varchar2,
                      mv_create_stmt in     clob);

--    PROCEDURE DBMS_ADVISOR.RESET_TASK
--    PURPOSE: Resets the specified task to its initial state.  All
--             intermediate and recommendation data will be removed.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task

--    PROCEDURE DBMS_ADVISOR.UPDATE_REC_ATTRIBUTES
--    PURPOSE: Updates an existing recommendation for the specified task
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         REC_ID
--            Recommendation identifier number
--         ACTION_ID
--            Action identifier number
--         ATTRIBUTE_NAME
--            Keyword name for the attribute
--         VALUE
--            Attribute value

procedure update_rec_attributes (task_name            in varchar2,
                                 rec_id               in number,
                                 action_id            in number,
                                 attribute_name       in varchar2,
                                 value                in varchar2);

--    PROCEDURE DBMS_ADVISOR.GET_REC_ATTRIBUTES
--    PURPOSE: Retrievs an existing recommendation attribute for 
--             the specified task
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         REC_ID
--            Recommendation identifier number
--         ACTION_ID
--            Action identifier number
--         ATTRIBUTE_NAME
--            Keyword name for the attribute
--         VALUE
--            Attribute value
--         OWNER_NAME
--            Optional task owner

procedure get_rec_attributes (task_name            in varchar2,
                              rec_id               in number,
                              action_id            in number,
                              attribute_name       in varchar2,
                              value                out varchar2,
                              owner_name           in varchar2 := NULL);

--    PROCEDURE DBMS_ADVISOR.UPDATE_TASK_ATTRIBUTES
--    PURPOSE: Updates a task's attributes
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         NEW_NAME
--            New task name (optional)
--         DESCRIPTION
--            New task description (optional)
--         READ_ONLY
--            TRUE if task is to be marked read-only (optional)
--         IS_TEMPLATE
--            TRUE if task is to be used as a template
--         HOW_CREATED
--            Sets the source attribute for a task

procedure update_task_attributes (task_name       in varchar2,
                                  new_name        in varchar2 := null,
                                  description     in varchar2 := null,
                                  read_only       in varchar2 := null,
                                  is_template     in varchar2 := null,
                                  how_created     in varchar2 := null);

-------------------------------------------------------------------------------
-- Utility procedures
-------------------------------------------------------------------------------


--    FUNCTION DBMS_ADVISOR.FORMAT_MESSAGE_GROUP
--    PURPOSE: Retrieves and formats a set of messages from the advisor
--             message table.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         GROUP_ID
--            Message-set identifier number
--    RETURNS:
--         Formatted messages as varchar2

function format_message_group(group_id IN number, msg_type IN number := 0)
   return varchar2;


--    FUNCTION DBMS_ADVISOR.FORMAT_MESSAGE
--    PURPOSE: Retrieves test from an Oracle Message file
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         MSG_ID
--            Message identifier number (fac-nnnnn)
--    RETURNS:
--         Formatted messages as varchar2

function format_message(msg_id IN varchar2)
   return varchar2;


--    PROCEDURE DBMS_ADVISOR.CHECK_PRIVS
--    PURPOSE: Checks for required advisor privileges
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         none
--
procedure check_privs;

--    PROCEDURE DBMS_ADVISOR.CHECK_READ_PRIVS
--    PURPOSE: Checks whether the current user has read privileges for another
--             user's tasks. This is typically used only by DBAs to
--             access other users's data, hence we query the dba_* views for
--             now. General support can be added later on once we define
--             all_* views.
--    ADVISOR SUPPORT:        All advisors
--    PARAMETERS:
--         OWNER_NAME : user name of the user whose tasks the current user
--                      wishes to access.
--

procedure check_read_privs(owner_name IN VARCHAR2);

--    PROCEDURE DBMS_ADVISOR.SETUP_REPOSITORY
--    PURPOSE: Sets up advisor framework repository for use.  Re-execution
--             of this procedure has no ill-effects.
--    PARAMETERS:
--         None

procedure setup_repository;

--    PROCEDURE DBMS_ADVISOR.ADD_SQLWKLD_STATEMENT
--    PURPOSE: Adds a single statement to a workload.
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload
--         MODULE
--            Application module name for the statement
--         ACTION
--            Application action for the statement
--         CPU_TIME
--            Total CPU time for the statement
--         ELAPSED_TIME
--            Total elapsed time for the statement
--         DISK_READS
--            Total disk-read count for the statement
--         BUFFER_GETS
--            Total buffer-get count for the statement
--         ROWS_PROCESSED
--            Total rows-processed count for the statement
--         OPTIMIZER_COST
--            Optimizer cost value
--         EXECUTIONS
--            Number of times statement would be executed
--         PRIORITY
--            User-specified priority
--         LAST_EXECUTION_DATE
--            Last time the statement was executed
--         STAT_PERIOD
--            Time interval in seconds from which statement stats were
--            calculated.
--         USERNAME
--            Oracle username under which the statement was executed
--         SQL_TEXT
--            SQL statement
--         ROWID_VALUE
--            RowId of the SQL statement to retrieve
--         OWNER
--            Owner name of the target table containing the SQL statement
--         TABLENAME
--            Table name of the target table containing the SQL statement
--         HASH_VALUE
--            Oracle hash value of the target SQL statement
--         ADDRESS
--            Oracle address of the target SQL statement

procedure add_sqlwkld_statement (workload_name        in varchar2,
                                 module               in varchar2 := '',
                                 action               in varchar2 := '',
                                 cpu_time             in number := 0,
                                 elapsed_time         in number := 0,
                                 disk_reads           in number := 0,
                                 buffer_gets          in number := 0,
                                 rows_processed       in number := 0,
                                 optimizer_cost       in number := 0,
                                 executions           in number := 1,
                                 priority             in number := 2,
                                 last_execution_date  in date := SYSDATE,
                                 stat_period          in number := 0,
                                 username             in varchar2,
                                 sql_text             in clob);

--    PROCEDURE DBMS_ADVISOR.ADD_SQLWKLD_REF
--    PURPOSE: Adds a workload reference to an advisor task.  A workload object
--             can either be an Access Advisor workload object or a SQL tuning set
--
--    ADVISOR SUPPORT:     SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Valid task name
--         WORKLOAD_NAME
--            Valid SQL Workload name
--         IS_STS
--            1 = specified workload object is a SQL tuning set
--            0 - specified workload object is an AA workload object

procedure add_sqlwkld_ref (task_name      in varchar2,
                           workload_name  in varchar2,
                           is_sts         in number := 0);

--    PROCEDURE DBMS_ADVISOR.ADD_STS_REF
--    PURPOSE: Adds an STS reference to an advisor task.  An STS object must
--             have an owner. The owner can be NULL, in which case the owner 
--             is assumed to be the SESSION_USER. Note that the following
--             two calls are equivalent:
--                  add_sqlwkld_ref(task_name, workload_name, 1);
--                  add_sts_ref(task_name, NULL, workload_name);
--
--    ADVISOR SUPPORT:     SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Valid task name
--         STS_OWNER
--            Owner of STS. May be NULL, defaults to SESSION_USER
--         STS_NAME
--            Valid STS name

procedure add_sts_ref (task_name      in varchar2,
                       sts_owner      in varchar2,
                       workload_name  in varchar2);

--    PROCEDURE DBMS_ADVISOR.CREATE_SQLWKLD
--    PURPOSE: Creates a new workload object
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.  If not specified, a unique name will
--            generated by the system.
--         DESCRIPTION
--            Description of the workload
--         TEMPLATE
--            Optional name of an existing workload from which default settings
--            will be copied.
--         IS_TEMPLATE
--            Optional boolean to set the new task as template

procedure create_sqlwkld (workload_name            in out varchar2,
                          description              in varchar2 := null,
                          template                 in varchar2 := null,
                          is_template              in varchar2 := 'FALSE');

--    PROCEDURE DBMS_ADVISOR.DELETE_SQLWKLD
--    PURPOSE: Deletes an entire workload object
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.

procedure delete_sqlwkld (workload_name            in varchar2);

--    PROCEDURE DBMS_ADVISOR.DELETE_SQLWKLD_REF
--    PURPOSE: Removes a workload reference from the specified task.
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         WORKLOAD_NAME
--            Name of the workload to derefernce
--         IS_STS
--            0 - SQL Workload object, 1 - SQL Tuning Set, 2 - Match any 

procedure delete_sqlwkld_ref (task_name       in varchar2,
                              workload_name   in varchar2,
                              is_sts          in number := 2);

--    PROCEDURE DBMS_ADVISOR.DELETE_STS_REF
--    PURPOSE: Removes an STS reference from an advisor task.  An STS object 
--             must have an owner. The owner can be NULL, in which case the 
--             owner is assumed to be the SESSION_USER. Note that the following
--             two calls are equivalent:
--                  delete_sqlwkld_ref(task_name, workload_name, 1);
--                  delete_sts_ref(task_name, NULL, workload_name);
--    PURPOSE: Removes a workload reference from the specified task.
--    ADVISOR SUPPORT:        SQL Access Advisor
--    PARAMETERS:
--         TASK_NAME
--            Name of the task
--         STS_OWNER
--            Owner of STS. May be NULL, defaults to SESSION_USER
--         WORKLOAD_NAME
--            Name of the workload to derefernce

procedure delete_sts_ref (task_name       in varchar2,
                          sts_owner       in varchar2,
                          workload_name   in varchar2);

--    PROCEDURE DBMS_ADVISOR.DELETE_SQLWKLD_STATEMENT
--    PURPOSE: Deletes one or more statements from a workload
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         SQL_ID
--            Unique identifier for a statement
--         SEARCH
--            Optional search condition used to refine the set of statements
--            to be deleted.
--         DELETED
--            Returns the number of statements removed by a searched delete.

procedure delete_sqlwkld_statement (workload_name     in varchar2,
                                    sql_id            in number);

procedure delete_sqlwkld_statement (workload_name     in varchar2,
                                    search            in varchar2,
                                    deleted           out number);

--    PROCEDURE DBMS_ADVISOR.IMPORT_SQLWKLD_STS
--    PURPOSE: Imports data into a workload from a SQL Tuning Set
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         STS_OWNER
--            Optional SQL Tuning Set owner
--         STS_NAME
--            Name of existing SQL Tuning Set object
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)
--         PRIORITY
--            Specifies default priority for each statement (1,2,3)
--         SAVE_ROWS
--            Returns number of rows actually saved in the workload object
--         FAILED_ROWS
--            Returns number of statements that couldn't be saved due to
--            parsing and validation errors.

procedure import_sqlwkld_sts (workload_name         in varchar2,
                              sts_owner             in varchar2,
                              sts_name              in varchar2,
                              import_mode           in varchar2 := 'NEW',
                              priority              in number := 2,
                              saved_rows            out number,
                              failed_rows           out number);

procedure import_sqlwkld_sts (workload_name         in varchar2,
                              sts_name              in varchar2,
                              import_mode           in varchar2 := 'NEW',
                              priority              in number := 2,
                              saved_rows            out number,
                              failed_rows           out number);

--    PROCEDURE DBMS_ADVISOR.IMPORT_SQLWKLD_SCHEMA
--    PURPOSE: Imports data into a workload from schema evidence
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)
--         PRIORITY
--            Specifies default priority for each statement (1,2,3)
--         SAVE_ROWS
--            Returns number of rows actually saved in the workload object
--         FAILED_ROWS
--            Returns number of statements that couldn't be saved due to
--            parsing and validation errors.

procedure import_sqlwkld_schema (workload_name         in varchar2,
                                 import_mode           in varchar2 := 'NEW',
                                 priority              in number := 2,
                                 saved_rows            out number,
                                 failed_rows           out number);


--    PROCEDURE DBMS_ADVISOR.IMPORT_SQLWKLD_SQLCACHE
--    PURPOSE: Imports data into a workload from the current SQL cache
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)
--         PRIORITY
--            Specifies default priority for each statement (1,2,3)
--         SAVE_ROWS
--            Returns number of rows actually saved in the workload object
--         FAILED_ROWS
--            Returns number of statements that couldn't be saved due to
--            parsing and validation errors.

procedure import_sqlwkld_sqlcache (workload_name         in varchar2,
                                   import_mode           in varchar2 := 'NEW',
                                   priority              in number := 2,
                                   saved_rows            out number,
                                   failed_rows           out number);


--    PROCEDURE DBMS_ADVISOR.IMPORT_SQLWKLD_SUMADV
--    PURPOSE: Imports data into a workload from a 9i Summary Advisor workload
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)
--         PRIORITY
--            Specifies default priority for each statement (1,2,3)
--         SUMADV_ID
--            Summary Advisor workload identifier number
--         SAVE_ROWS
--            Returns number of rows actually saved in the workload object
--         FAILED_ROWS
--            Returns number of statements that couldn't be saved due to
--            parsing and validation errors.

procedure import_sqlwkld_sumadv (workload_name         in varchar2,
                                 import_mode           in varchar2 := 'NEW',
                                 priority              in number := 2,
                                 sumadv_id             in number,
                                 saved_rows            out number,
                                 failed_rows           out number);

--    PROCEDURE DBMS_ADVISOR.IMPORT_SQLWKLD_USER
--    PURPOSE: Imports data into a workload from a specified user table
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)
--         OWNER_NAME
--            Specifies the owner name of the user table.
--         TABLE_NAME
--            Specifies the name of the user table
--         SAVE_ROWS
--            Returns number of rows actually saved in the workload object
--         FAILED_ROWS
--            Returns number of statements that couldn't be saved due to
--            parsing and validation errors.

procedure import_sqlwkld_user (workload_name         in varchar2,
                               import_mode           in varchar2 := 'NEW',
                               owner_name            in varchar2,
                               table_name            in varchar2,
                               saved_rows            out number,
                               failed_rows           out number);

--    PROCEDURE DBMS_ADVISOR.COPY_SQLWKLD_TO_STS
--    PURPOSE: Copies workload object data into a user-specified STS.  No filters
--             are supported.
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         STS_NAME
--            Name of the target STS.
--         IMPORT_MODE
--            Specifies the replacement mode (APPEND,NEW,REPLACE)

procedure copy_sqlwkld_to_sts (workload_name         in varchar2,
                               sts_name              in varchar2,
                               import_mode           in varchar2 := 'NEW');

--    PROCEDURE DBMS_ADVISOR.RESET_SQLWKLD
--    PURPOSE: Resets a workload to its initial state.  All journal and
--             log messages are cleared.  Workload statements will be
--             validated.
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload

procedure reset_sqlwkld (workload_name       in varchar2);

--    PROCEDURE DBMS_ADVISOR.SET_SQLWKLD_PARAMETER
--    PURPOSE: Sets the value of a workload parameter
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         PARAMETER
--            Workload parameter name
--         VALUE
--            Workload parameter value

procedure set_sqlwkld_parameter (workload_name        in varchar2,
                                 parameter            in varchar2,
                                 value                in varchar2);

procedure set_sqlwkld_parameter (workload_name        in varchar2,
                                 parameter            in varchar2,
                                 value                in number);

--    PROCEDURE DBMS_ADVISOR.SET_DEFAULT_SQLWKLD_PARAMETER
--    PURPOSE: Sets the specified parameter value as default for
--             all new Sql workload objects.
--    PARAMETERS:
--         PARAMETER
--            Name of the task parameter
--         VALUE
--            Value to be set

procedure set_default_sqlwkld_parameter (parameter      in varchar2,
                                         value          in varchar2);

procedure set_default_sqlwkld_parameter (parameter      in varchar2,
                                         value          in number);

--    PROCEDURE DBMS_ADVISOR.UPDATE_WORKOAD_ATTRIBUTES
--    PURPOSE: Updates a workload object
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         NEW_NAME
--            New workload name
--         DESCRIPTION
--            New workload description
--         READ_ONLY
--            TRUE if workload is to be used as a template
--         IS_TEMPLATE
--            TRUE if workload is to be used as a template
--         HOW_CREATED
--            Sets the source attribute for a workload

procedure update_sqlwkld_attributes (workload_name    in varchar2,
                                     new_name         in varchar2 := null,
                                     description      in varchar2 := null,
                                     read_only        in varchar2 := null,
                                     is_template      in varchar2 := null,
                                     how_created      in varchar2 := null);

--    PROCEDURE DBMS_ADVISOR.UPDATE_SQLWKLD_STATEMENT
--    PURPOSE: Updates one or more SQL statements in a workload
--    PARAMETERS:
--         WORKLOAD_NAME
--            Name of the workload.
--         SQL_ID
--            Workload statement identifier
--         UPDATED
--            Returns the number of statements changed by a searched update.
--         APPLICATION
--            Optional application name
--         ACTION
--            Optional application action
--         PRIORITY
--            Optional priority value
--         USERNAME
--            Optional username value
--         SEARCH
--            Optional search condition to refine the set of updated
--            statements.

procedure update_sqlwkld_statement (workload_name     in varchar2,
                                    sql_id            in number,
                                    application       in varchar2 := null,
                                    action            in varchar2 := null,
                                    priority          in number := null,
                                    username          in varchar2 := null);

procedure update_sqlwkld_statement (workload_name     in varchar2,
                                    search            in varchar2,
                                    updated           out number,
                                    application       in varchar2 := null,
                                    action            in varchar2 := null,
                                    priority          in number := null,
                                    username          in varchar2 := null);

--    PROCEDURE DBMS_ADVISOR.SETUP_USER_ENVIRONMENT
--    PURPOSE: Setups up user environment for Enterprise Manager.
--             Typically, it is not necessary to call this routine as
--             user setup is automatically done when a user creates
--             a task.  However, EM needs the environment set up prior
--             to creating a task.
--    PARAMETERS:
--         ADVISOR_NAME
--              - Name of advisor environment to setup

procedure setup_user_environment (advisor_name    in varchar2);

--    PROCEDURE DBMS_ADVISOR.GET_ACCESS_ADVISOR_DEFAULTS
--    PURPOSE: Returns default task and workload id numbers for
--             the Access Advisor.  This routine is typically only
--             called by the Enterprise Manager SQL Access Advisor Wizard.
--    PARAMETERS:
--         TASK_NAME
--              - returned task or template name
--         TASK_ID_NUM
--              - returned task or template id
--         WORKLOAD_NAME
--              - returned workload or template name
--         WORK_ID_NUM
--              - returned workload or template id

procedure get_access_advisor_defaults (task_name      out varchar2,
                                       task_id_num    out number,
                                       workload_name  out varchar2,
                                       work_id_num    out number);

--    PROCEDURE DBMS_ADVISOR.DELETE_DIRECTIVE
--    PURPOSE: Deletes an instance of a directive.  For task-based
--             instances, the task may be required to be in an initial
--             state to permit the delete operation.
--    PARAMETERS:
--        DIRECTIVE_ID
--            Valid directive definition identifier number
--        INSTANCE_NAME
--            Valid instance name
--        TASK_NAME
--            Task to which the instance is associated. If null,
--            default instance will be deleted.

procedure delete_directive (directive_id    in number,
                            instance_name   in varchar2,
                            task_name       in varchar2 := NULL);

--    FUNCTION DBMS_ADVISOR.EVALUATE_DIRECTIVE
--    PURPOSE: Evaluates a directive instance and returns the results
--    PARAMETERS:
--        DIRECTIVE_ID
--            Valid base directive identifier number
--        INSTANCE_NAME
--            Valid instance name
--        TASK_NAME
--            Task to which the instance is associated. If null,
--            a global instance will be retrieved.
--        P1
--            key (Optional).
--            Type: filter          - document to filter
--                  single-valued   - Parameter name
--                  multi-valued    - Parameter name
--                  conditional     - Conditional name
--        P2  
--            key (Optional). 
--            Type: filter          - Unused
--                  single-valued   - Unused
--                  multi-valued    - Offset (1 based.  A zero will 
--                                    return the number of values)
--                  conditional     - Key name
--
--    RETURNS:
--        Value of directive.  

function evaluate_directive (directive_id      in number,
                             instance_name     in varchar2,
                             task_name         in varchar2 := NULL,
                             p1                in clob := NULL,
                             p2                in clob := NULL)
  return clob;

--    PROCEDURE DBMS_ADVISOR.INSERT_DIRECTIVE
--    PURPOSE: Creates an instance of a known directive.  
--
--             For task-based instances, the task may be required to be 
--             in an initial state to permit this operation.
--
--    PARAMETERS:
--        DIRECTIVE_ID
--            Valid base directive identifier number
--        INSTANCE_NAME
--            Valid instance name.  Must be unique to the directive.
--        TASK_NAME
--            Task to which the instance is associated. If null,
--            default instance will be created.
--        DOCUMENT
--            The XML-document representing the directive instance.

procedure insert_directive (directive_id    in number,
                            instance_name   in varchar2,
                            task_name       in varchar2,
                            document        in clob);

--    PROCEDURE DBMS_ADVISOR.UPDATE_DIRECTIVE
--    PURPOSE: Updates an instance of a known directive.  
--
--             For task-based instances, the task may be required to be 
--             in an initial state to permit an update operation.
--
--    PARAMETERS:
--        DIRECTIVE_ID
--            Valid base directive identifier number
--        INSTANCE_NAME
--            Valid instance name
--        TASK_NAME
--            Task to which the instance is associated. If null,
--            default instance will be updated.
--        DOCUMENT
--            The XML-document representing the directive instance.

procedure update_directive (directive_id    in number,
                            instance_name   in varchar2,
                            task_name       in varchar2,
                            document        in clob);


END dbms_advisor;
/
show errors;

GRANT EXECUTE ON dbms_advisor TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dbms_advisor FOR dbms_advisor;


