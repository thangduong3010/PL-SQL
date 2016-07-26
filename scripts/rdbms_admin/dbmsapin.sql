rem 
rem $Header: rdbms/admin/dbmsapin.sql /main/3 2009/12/08 18:04:23 arbalakr Exp $
rem
rem dbmsapin.pls
rem 
rem Copyright (c) 1996, 2009, Oracle and/or its affiliates. 
rem All rights reserved. 
rem
rem   NAME
rem     dbmsapin.pls - dbms_application_info package spec
rem
rem   DESCRIPTION
rem     procedures for instrumenting database applications.
rem
rem   RETURNS
rem
rem   NOTES
rem
rem   MODIFIED   (MM/DD/YY)
rem   arbalakr    11/23/09 - update comment on set_module/set_action
rem   skray       03/12/98 - modify definition of set_session_longops
rem   dalpern     04/16/97 - make fixed packages a distinct "world"
rem   swerthei    03/14/97 - add set_session_longops
rem   gpongrac    04/20/96 - timestamp changes
rem   gpongrac    04/17/96 - fix for sed script
rem   gpongrac    04/16/96 - fix
rem   gpongrac    01/31/96 - dbms_application_info package spec
rem   gpongrac    01/31/96 - Creation
rem

create or replace package dbms_application_info is

-- DE-HEAD       <- tell SED where to cut

  ------------
  --  OVERVIEW
  --
  --  The dbms_application_info package provides a mechanism for registering 
  --  the name of the application module that is currently running with the 
  --  rdbms. Registering the name of the module allows DBAs to monitor how the 
  --  system is being used, and do performance analysis, and resource 
  --  accounting by module.  The name that is registered through this 
  --  package will appear in the 'module' and 'action' column of 
  --  the v$session virtual table. It will also appear in the 'module' and 
  --  'action' columns in v$sqlarea.
  --
  --  The MODULE name is normally set to a user recognizable name for the 
  --  program that is currently executing.  For example, this could be the name
  --  of the form that is executing, or it could be the name of the script that
  --  is being executed by sql*plus.  The idea is to be able to identify the
  --  high level function that is being performed.  For instance, you can tell
  --  that a user is in the 'order entry' form instead of just telling that he
  --  is running sql*forms.  We encourage application tool vendors to 
  --  automatically set this value whenever an application is executed.
  --
  --  The ACTION name is normally set to a specific action that a user is
  --  performing within a module.  For instance a user could be 'reading
  --  mail' or 'entering a new customer'.  This is meant to more specifically 
  --  identify what a user is currently doing.  The action should normally be
  --  set by the designer of a specific application.  It should not 
  --  automatically be set by the application tool.
  --
  --  If the local DBA would like to gather his own statistics based on
  --  module, then the DBA can implement a wrapper around this package 
  --  by writing a version of this package in another schema that first 
  --  gathers statistics and then calls the sys version of the package.  The 
  --  public synonym for dbms_application_info can then be changed to point 
  --  to the DBA's version of the package.
  --

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure set_module(module_name varchar2, action_name varchar2);
  --  Sets the name of the module that is currently running to a new
  --    module.  When the current module terminates, this should
  --    be called with the name of the new module if there is one, or
  --    null if there is not a new module.  Passing null for either of these
  --    values is equivalent to passing a zero length string.
  --  Input arguments:
  --    module_name
  --      The name of the module that will now be running. The maximum
  --      length of the module name is 64 bytes. Longer names will be  
  --      truncated.
  --    action_name
  --      The name of the action that will now be running. The maximum
  --      length of the action_name is 64 bytes. Longer names will be
  --      truncated. If the action name is not being specified, then null 
  --      should be passed for this value.
  --
  procedure set_action(action_name varchar2);
  --  Sets the name of the current action within the current module.
  --    When the current action terminates, this should be called with the 
  --    name of the new action if there is one, or null if there is not a 
  --    new action.  Passing null for this value is equivalent to passing
  --    a zero length string.
  --  Input arguments:
  --    action_name
  --      The name of the action that will now be running. The maximum
  --      length of the action_name is 64 bytes. Longer names will be
  --      truncated.
  --
  procedure read_module(module_name out varchar2, action_name out varchar2);
  --  Reads the values of the module and action fields of the current 
  --    session.
  --  Output arguments:
  --    module_name 
  --      The last value that the module name was set to using the set_module
  --      procedure.
  --    action_name
  --      The last value that the action name was set to using the set_module
  --      or set_action procedures.
  --
  procedure set_client_info(client_info varchar2);
  --  Sets the client info field of the session.  The client info field is
  --    provided for the use of individual applications.  The Oracle system 
  --    does not use this field for any purpose.  After being set, the 
  --    client info field can be queried from v$session.
  --  Input arguments:
  --    client_info 
  --      Any character data that the client wishes to store up to a maximum of
  --      64 bytes.  Longer values will be truncated.  Passing a null is
  --      equivalent to passing a zero length string.

  procedure read_client_info(client_info out varchar2);
  --  Reads the value of the client_info field of the current session.
  --  Output arguments:
  --    client_info
  --      The last value that the client_info field was set to using the
  --      set_client_info procedure.

  procedure set_session_longops(rindex      in out pls_integer,
                                slno        in out pls_integer,
                                op_name     in varchar2 default null,
                                target      in pls_integer default 0,
                                context     in pls_integer default 0,
                                sofar       in number default 0,
                                totalwork   in number default 0,
                                target_desc in varchar2
                                               default 'unknown target',
                                units       in varchar2 default null);

  set_session_longops_nohint constant pls_integer := -1;

  --  Sets a row in the V$SESSION_LONGOP table.  This is a table which is
  --  customarily used to indicate the on-going progress of a long running
  --  operation.  Some Oracle functions, such as Parallel Query and
  --  Server Managed Recovery, use rows in this table to indicate the status
  --  of, for example, a database backup.  Applications may use this function
  --  to advertise information about application-specific long running tasks.
  --  Input Arguments:
  --    rindex
  --      This is a token which represents the v$session_longops row to update.
  --      Set this to set_session_longops_nohint to start a new row.  Use the
  --      returned value from the prior call to reuse a row.
  --    slno
  --      This parameter is used to save information across calls to
  --      set_session_longops.  It is for internal use and should not be
  --      modified by the caller.
  --    op_name
  --      This parameter specifies the name of the long running task. It
  --      will appear as the OPNAME column of v$session_longops.  The
  --      maximum length of op_name is 64 bytes.
  --    target
  --      This parameter specifies the object that is being worked upon
  --      during the long running operation.  For example, it could be a
  --      table id that is being sorted.  It will appear as the TARGET
  --      column of v$session_longops.
  --    context
  --      Any number the client wishes to store.  It will appear in the
  --      CONTEXT column of v$session_longops.
  --    sofar
  --      Any number the client wishes to store.  It will appear in the
  --      SOFAR column of v$session_longops.  This is typically the amount
  --      of work which has been done so far.
  --    totalwork
  --      Any number the client wishes to store.  It will appear in the
  --      TOTALWORK column of v$session_longops.  This is typically the total
  --      amount of work needed to be done in this long running operation.
  --    target_desc
  --      This parameter specifies the description of the object being
  --      manipulated in this long operation.  Basically, this provides a
  --      caption for the 'target' parameter above.  This value will appear
  --      in the TARGET_DESC field of v$session_longops.  The maximum length
  --      of target_desc is 32 bytes.
  --    units
  --      This parameter specifies the units in which 'sofar' and 'totalwork'
  --      are being represented.  It will appear as the UNITS field of
  --      v$session_longops.  The maximum length of units is 32 bytes.

  pragma TIMESTAMP('1998-03-12:12:00:00');

end;

-- CUT_HERE    <- tell sed where to chop off the rest

/

-- Note that the public synonym for dbms_application_info is not dropped before
-- creation in order to allow users to redirect the public synonym to point
-- to their own package.  If we dropped it, then everytime they ran this 
-- script, their package would be overriden by the default oracle package.



create public synonym dbms_application_info for sys.dbms_application_info;

grant execute on sys.dbms_application_info to public;
