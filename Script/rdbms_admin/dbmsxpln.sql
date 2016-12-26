Rem
Rem $Header: rdbms/admin/dbmsxpln.sql /main/13 2009/04/20 10:28:26 mzait Exp $
Rem
Rem dbmsxpln.sql
Rem
Rem Copyright (c) 2003, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxpln.sql - DBMS eXPLaiN Package
Rem
Rem    DESCRIPTION
Rem      This package provides table functions for users to display 
Rem      the execution plan of a SQL statement
Rem
Rem    NOTES
Rem      This package used to be declared in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bdagevil    04/14/09 - add support for active reports
Rem    rdongmin    03/24/08 - plan diff: add get_plandiff_report_xml()
Rem    rdongmin    01/15/08 - add plan diff APIs
Rem    shjoshi     12/24/07 - add prepare_plan_xml_query
Rem    kyagoub     01/15/07 - add function display_plan
Rem    kyagoub     08/27/06 - add function build_plan_xml
Rem    mziauddi    11/29/06 - display_sql_plan_baseline: change plan_id to
Rem                           plan_name
Rem    ddas        10/27/06 - rename display_plan_baseline to
Rem                           display_sql_plan_baseline
Rem    ddas        10/05/06 - display_sql_plan_baseline():
Rem                           plan_hash_value=>plan_id
Rem    bwadding    09/21/06 - externalize number/size formatting functions
Rem    mziauddi    09/16/06 - add display_sql_plan_baseline()
Rem    bdagevil    02/23/05 - allow to customize format
Rem    kyagoub     02/20/05 - replace dba_sqlset_xxx/all_sqlset_xxx views in 
Rem                           display_sqlset 
Rem    bdagevil    02/03/05 - add allow_dynamic_sql parameter to display() 
Rem    kyagoub     07/27/04 - export validate_format and change prepare_records
Rem    kyagoub     06/29/04 - remove tabs 
Rem    kyagoub     05/31/04 - fix comments for display_sqlset 
Rem    kyagoub     05/13/04 - add display_sqlset 
Rem    pbelknap    03/17/04 - query plan comparison 
Rem    mzait       11/05/03 - mzait_improve_10053_1 
Rem    bdagevil    11/03/03 - remove hard tabs 
Rem    bdagevil    11/01/03 - Created
Rem


--
--   DBMS_XPLAN
-- 
  
--
-- Library where 3GL callouts will reside
--
CREATE OR REPLACE LIBRARY dbms_xplan_lib trusted as static
/
show errors;
/
  
create or replace package dbms_xplan AUTHID CURRENT_USER as

  --- ------------------------------------------------------------------------
  --- DBMS_XPLAN CONSTANTS SECTION
  --- ------------------------------------------------------------------------

  --- The following constants designate the flags returned in the bit vector
  --- from the COMPARE_QUERY_PLANS function.

  UNKNOWN_DIFF_CLASS         CONSTANT NUMBER := POWER(2,31);

  --- ------------------------------------------------------------------------
  --- DBMS_XPLAN PUBLIC FUNCTIONS SECTION
  --- ------------------------------------------------------------------------
  ---
  --- OVERVIEW
  ---
  ---   This package defines several table functions which can be used to
  ---   display execution plans.
  ---
  ---   - DISPLAY is generally used to display the execution plan produced
  ---             by an EXPLAIN PLAN command; you can either display the most
  ---             recent explained statement, or the statement for a specific
  ---             statement id.
  ---
  ---             In addition, this table function can also be used to display 
  ---             any plan (with or without statistics) stored in a table as
  ---             long as the columns of this table are named the same as 
  ---             columns of the plan_table (or v$sql_plan_statistics_all if 
  ---             statistics are included). 
  ---             A predicate on the specified table can be used to select rows 
  ---             of the plan to display.
  ---
  ---   - DISPLAY_CURSOR displays the execution plans for one or several
  ---             cursors in the shared SQL area, depending on a filter
  ---             criteria. It can display the plan for the last executed
  ---             statement, the current (if session is active) or last
  ---             executed statement (if session is inactive) of a specific
  ---             session, or all cursors matching an arbitrary criteria 
  ---             defined via SQL. In addition to the explain plan, various
  ---             plan statistics (e.g. io, memory and timing) can be
  ---             reported (based on the v$sql_plan_statistics_all views).
  ---
  ---             Specific cursors are identified by SQL_ID and optionally a
  ---             SQL_CHILD_NUMBER.
  ---
  ---             The DEFAULT without any parameters shows the last executed 
  ---             statement of the session.
  ---
  ---             NOTE: To use the DISPLAY_CURSOR functionality, the calling
  ---             user must have SELECT privilege on V$SQL_PLAN_STATISTICS_ALL,
  ---             V$SQL, and V$SQL_PLAN. By default, only the select_catalog
  ---             role has the SELECT privilege on these views.
  ---
  ---   - DISPLAY_AWR displays the execution plans for SQL statements stored in 
  ---             the Automatic Workload Repository (AWR).
  ---             NOTE: To use the DISPLAY_AWR functionality, the calling user
  ---             must have SELECT prvilege on DBA_HIST_SQL_PLAN and
  ---             DBA_HIST_SQLTEXT. By default, select privilige for these
  ---             views is granted to the select_catalog role.
  ---
  ---   - DISPLAY_SQLSET displays the execution plans for SQL statements stored
  ---             in a SQL tuning set. 
  ---             NOTE: To use the DISPLAY_SQLSET functionality, the calling 
  ---             user must have SELECT prvilege on ALL_SQLSET_PLANS and
  ---             ALL_SQLSET_STATEMENTS. By default, select privilige for these
  ---             views is granted to the public role.
  ---
  ---   - DISPLAY_SQL_PLAN_BASELINE displays one or more execution plans for
  ---             the specified sql_handle of a SQL statement. If plan_name is
  ---             specified denoting a single plan then that plan is displayed.
  ---             The plan information stored in the SQL management base is
  ---             used to generate and display the plan. It is possible that
  ---             the stored plan id may not match up with the plan id of the
  --              generated plan. A plan id mismatch means that the stored plan
  ---             is not reproducible. Such a plan is deemed invalid by the
  ---             optimizer and ignored when the corresponding SQL statement is
  --              compiled and a cursor is built. When plan id mismatch occurs
  ---             a note saying 'the plan is invalid' is shown in the notes
  ---             section of the plan.
  ---             NOTE: To use DISPLAY_SQL_PLAN_BASELINE function, the calling
  ---             user must have SELECT prvilege on DBA_SQL_PLAN_BASELINES
  ---             view.  By default, SELECT privilege on this view is granted
  ---             to the SELECT_CATALOG_ROLE.
  ---
  ---
  ---   For example:
  ---     To show the last explained statement
  ---        explain plan for select ename, deptno
  ---                         from emp e, dept d
  ---                         where e.deptno = d.deptno;
  ---        select * from table(dbms_xplan.display);
  ---
  ---     To show the last executed statement of your session  
  ---        select * from table(dbms_xplan.display_cursor);
  ---
  ---     See more detailed examples below
  ---
  --- SECURITY
  ---
  ---   The execution privilege on this package is granted to PUBLIC.
  ---   The display procedures of this package are run under the caller
  ---   security. 
  ---
  ---
  --- PROCEDURES AND FUNCTIONS
  ---
  ---   function display(table_name   varchar2 default 'PLAN_TABLE',
  ---                    statement_id varchar2 default null,
  ---                    format       varchar2 default 'TYPICAL',
  ---                    filter_preds varchar2 default null)
  ---
  ---   - table_name:
  ---        specifies the table name where the plan is stored. This
  ---        parameter defaults to "PLAN_TABLE" which is the default
  ---        plan table for the explain plan. If NULL is specified,
  ---        the default of 'PLAN_TABLE' will be taken into account.
  ---        The parameter is case insensitive.
  ---
  ---   - statement_id:
  ---        specifies the statement id of the plan to display. This
  ---        parameter defaults to NULL. If no statement_id is defined,
  ---        the most recent explained statement in <table_name> will
  ---        be displayed, assuming that the "filter_preds" parameter is
  ---        NULL (its default).
  ---
  ---   - format:
  ---        Determines what information stored in the plan will be
  ---        shown. The format string can use the following predefined
  ---        three formats, each representing a common use case:
  ---
  ---        'BASIC':   Display only the minimum set of information, i.e. the
  ---                   operation id, the operation name and its option
  ---
  ---        'TYPICAL': This is the default. Display most information
  ---                   of the explain plan (operation id, name and option,
  ---                   #rows, #bytes and optimizer cost). Pruning,
  ---                   parallel and predicate information are only
  ---                   displayed when applicable. Excludes only PROJECTION,
  ---                   ALIAS and REMOTE SQL information (see below).
  ---
  ---        'ALL':     Maximum user level, like typical with additional
  ---                   informations (PROJECTION, ALIAS and information about
  ---                   REMOTE SQL if the operation is distributed).
  ---
  ---        For finer control on the display output, the following keywords
  ---        can be added to the above three standard format to customize their
  ---        default behavior. Each keyword either represents a logical group
  ---        of plan table columns (e.g. PARTITION) or logical additions to the
  ---        base plan table output (e.g. PREDICATE). Format keywords must
  ---        be separated by either a comma or a space:
  ---
  ---        ROWS: if relevant, shows number of rows estimated by the optimizer
  ---
  ---        BYTES: if relevant, shows number of bytes estimated by the
  ---               optimizer
  ---
  ---        COST: if relevant, shows optimizer cost information
  ---
  ---        PARTITION: If relevant, shows partition pruning information
  ---
  ---        PARALLEL: If relevant, shows PX information (distribution method
  ---                  and table queue information)
  ---
  ---        PREDICATE: If relevant, shows the predicate section
  ---
  ---        PROJECTION: If relevant, shows the projection section
  ---
  ---        ALIAS: If relevant, shows the "Query Block Name / Object Alias"
  ---               section
  ---
  ---        REMOTE: If relevant, shows the information for distributed query
  ---                (e.g. remote from serial distribution and remote SQL)
  ---
  ---        NOTE: If relevant, shows the note section of the explain plan.
  ---
  ---      Format keywords can be prefixed by the sign '-' to exclude the
  ---      specified information. For example, '-PROJECTION' exclude
  ---      projection information.
  ---
  ---      Finally, if the target plan table (see "table_name" parameter) also
  ---      stores plan statistics columns (e.g. it is a table used to capture
  ---      the content of the fixed view v$sql_plan_statistics_all), then
  ---      additional format keywords can be used to specify which class of
  ---      statistics to display. These additionnal format keywords are IOSTATS,
  ---      MEMSTATS, ALLSTATS and LAST described along with the display_cursor()
  ---      table function (see below).
  ---
  ---      Example:
  ---        - use 'ALL -PROJECTION -NOTE' to display everything except the
  ---          projection and note sections.
  ---
  ---        - use 'TYPICAL PROJECTION' to display using the typical format
  ---          with the additional projection section (which is normally excluded
  ---          under the typical format). Since typical is default, using
  ---          simply 'PROJECTION' is equivalent.
  ---
  ---        - use '-BYTES -COST -PREDICATE' to display using the typical
  ---         format but excluding optimizer cost and byte estimates
  ---         as well as the predicate section.
  ---
  ---        - use 'BASIC ROWS' to display basic information with the
  ---          additional number of rows estimated by the optimizer.
  ---
  ---
  ---   - filter_preds: SQL filter predicate(s) to restrict the set of rows
  ---                   selected from the table where the plan is stored. When
  ---                   value is NULL (the default), the plan displayed
  ---                   corresponds to the last executed explain plan.
  ---
  ---                   For example:
  ---
  ---                     filter_preds=>'plan_id = 10'
  ---
  ---                   "filter_preds" can reference any column of the table
  ---                   where the plan is stored and can contain any SQL
  ---                   construct (e.g. sub-query, function calls...).
  ---
  ---                   WARNING: Application developers should expose this
  ---                   parameter to end-users only after careful
  ---                   consideration since it could expose the application
  ---                   to SQL injection. Indeed, "filter_preds" can
  ---                   potentially reference any table or execute any server
  ---                   function for which the database user invoking the
  ---                   table function has privileges.
  ---
  ---   ------------------------------------------------------------------------
  ---   function display_cursor(sql_id           varchar2 default null,
  ---                           cursor_child_no  integer default 0,
  ---                           format           varchar2 default 'TYPICAL')
  ---
  ---   - sql_id:
  ---        specifies the sql_id value for a specific SQL statement, as
  ---        shown in V$SQL.SQL_ID, V$SESSION.SQL_ID, or
  ---        V$SESSION.PREV_SQL_ID. If no sql_id is specified, the last
  ---        executed statement of the current session is shown.
  ---
  ---   - cursor_child_no:
  ---        specifies the child number for a specific sql cursor, as shown in
  ---        V$SQL.CHILD_NUMBER or in V$SESSION.SQL_CHILD_NUMBER,
  ---        V$SESSION.PREV_CHILD_NUMBER. This input parameter is only
  ---        considered when sql_id is set.
  ---
  ---        If not specified, all child cursors for the specified sql_id are 
  ---        displayed.
  ---
  ---   - format:
  ---        The format string has the same meaning as that for the regular
  ---        display() table function (see format description above). In
  ---        addition, the following four format keywords are introduced
  ---        to support the various plan statistics columns available
  ---        in v$sql_plan_statistics_all.
  ---
  ---        These keywords can also be used by the display() table function
  ---        assuming that the specified table has the same statistics columns
  ---        available in v$sql_plan_statistics_all.
  ---
  ---        IOSTATS: Assuming that basic plan statistics are
  ---                 collected when SQL statements are executed (either by
  ---                 using the gather_plan_statistics hint or by setting the
  ---                 parameter statistics_level to ALL), this format will show
  ---                 IO statistics for all (or only for the last as shown below)
  ---                 executions of the cursor.
  ---
  ---        MEMSTATS: Assuming that PGA memory management is enabled (i.e
  ---                  pga_aggregate_target parameter is set to a non 0 value),
  ---                  this format allows to display memory management
  ---                  statistics (e.g. execution mode of the operator, how
  ---                  much memory was used, number of bytes spilled to
  ---                  disk, ...). These statistics only apply to memory
  ---                  intensive operations like hash-joins, sort or some bitmap
  ---                  operators.
  ---
  ---        ALLSTATS: A shortcut for 'IOSTATS MEMSTATS'
  ---
  ---        LAST: By default, plan statistics are shown for all executions of
  ---              the cursor. The keyword LAST can be specified to see only
  ---              the statistics for the last execution.
  ---
  ---
  ---        Also, the following two formats are still supported for backward
  ---        compatibility:
  ---
  ---        'RUNSTATS_TOT':  Same as 'IOSTATS', i.e. displays IO statistics
  ---                         for all executions of the specified cursor.
  ---        'RUNSTATS_LAST': Same as 'IOSTATS LAST', i.e. displays the runtime
  ---                         statistics for the last execution of the cursor.
  ---
  ---
  ---   PRIVILEGES: 
  ---   -    To use the DISPLAY_CURSOR functionality, the calling
  ---        user must have SELECT privilege on V$SQL_PLAN_STATISTICS_ALL,
  ---        V$SQL, and V$SQL_PLAN, otherwise it will show an appropriate
  ---        error message.
  ---
  ---   -    Unless used in DEFAULT mode to display the last executed
  ---        statement, all internal SQL statements of this package and
  ---        the calling SQL statement using this table function will be
  ---        suppressed.       
  ---
  ---   ------------------------------------------------------------------------
  ---   function display_awr(sql_id          varchar2,
  ---                        plan_hash_value integer  default null,
  ---                        db_id           integer  default null,
  ---                        format          varchar2 default 'TYPICAL')
  ---
  ---   - sql_id:
  ---        specifies the sql_id value for a SQL statement having its plan(s)
  ---        stored in the AWR. You can find all stored SQL statements by 
  ---        querying DBA_HIST_SQL_PLAN.
  ---
  ---   - plan_hash_value:
  ---        identifies a specific stored execution plan for a SQL statement.
  ---        Optional parameter. If suppressed, all stored execution plans are 
  ---        shown.
  ---
  ---   - db_id:
  ---        identifies the plans for a specific dabatase. If this parameter is
  ---        omitted, it will be defaulted to the local database identifier.
  ---
  ---   - format:
  ---        The format string has the same meaning as that for the regular
  ---        display() table function (see format description above).
  ---
  ---   ------------------------------------------------------------------------
  ---   function display_sqlset(sqlset_name     varchar2,
  ---                           sql_id          varchar2,
  ---                           plan_hash_value integer  default null,
  ---                           format          varchar2 default 'TYPICAL',
  ---                           sqlset_owner    varchar2 default null)
  ---    
  ---   - sqlset_name:
  ---        specified the name of the SQL tuning set.
  ---
  ---   - sql_id:
  ---        specifies the sql_id value for a SQL statement having its plan(s)
  ---        stored in the SQL tuning set. You can find all stored SQL 
  ---        statements by querying USER/DBA/ALL_SQLSET_PLANS or table function 
  ---        SELECT_SQLSET from package dbms_sqltune.
  ---
  ---   - plan_hash_value:
  ---        identifies a specific stored execution plan for a SQL statement.
  ---        Optional parameter. If suppressed, all stored execution plans are 
  ---        shown.
  ---
  ---   - format:
  ---        The format string has the same meaning as that for the regular
  ---        display() table function (see format description above).
  ---
  ---   - sqlset_owner:
  ---        Specifies the owner of the SQL tuning set. The default is the
  ---        name of the current user.
  ---
  ---   ------------------------------------------------------------------------
  ---   function display_sql_plan_baseline(
  ---                          sql_handle       varchar2  default  NULL,
  ---                          plan_name        varchar2  default  NULL,
  ---                          format           varchar2  default  'TYPICAL')
  ---
  ---   - sql_handle:
  ---        SQL statement handle. It identifies the SQL statement whose plans
  ---        are to be explained and displayed. If NULL then PLAN_NAME must be
  ---        specified.
  ---        You can find SQL plan baselines created for various SQL statements
  ---        by querying DBA_SQL_PLAN_BASELINES catalog view.
  ---
  ---   - plan_name:
  ---        Plan name. It identifies a specific plan to be explained and
  ---        displayed. Default NULL means all plans associated with identified
  ---        SQL statement to be explained and displayed. If NULL then
  ---        sql_handle must be specified.
  ---
  ---   - format:
  ---        The format string has the same meaning as that for the regular
  ---        display() table function (see format description above).
  ---
  ---   ------------------------------------------------------------------------
  ---   Examples DBMS_XPLAN.DISPLAY():
  ---
  ---   1/ display the last explain plan stored in the plan table:
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display);
  ---
  ---
  ---   2/ display from the plan table "my_plan_table":
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display('my_plan_table'));
  ---
  ---
  ---   3/ display minimum plan table:
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display(null, null,'basic'));
  ---
  ---
  ---   4/ display all information in plan table, excluding projection:
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display(null, null,
  ---                                             'all -projection'));
  ---
  ---
  ---   5/ display the plan whose statement_id is 'foo':
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display('plan_table', 'foo'));
  ---
  ---
  ---   6/ display statpack plan for hash_value=76725 and snap_id=245
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display('stats$sql_plan', null,
  ---                          'all', 'hash_value=76725 and snap_id=245'));
  ---
  ---   ------------------------------------------------------------------------
  ---   Examples DBMS_XPLAN.DISPLAY_CURSOR():
  ---
  ---   1/ display the currently or last executed statement
  ---      (this will also show the usage of this package) 
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * from table(dbms_xplan.display_cursor);
  ---
  ---
  ---   2/ display the currently or last executed statement of session id 9
  ---      (it will return 'no rows selected' for any SQL statement using 
  ---       this package) 
  ---
  ---    - Identify the sql_id and the child_number in 
  ---      a separate SQL statement and use them as parameters for 
  ---      DISPLAY_CUSRSOR()  
  ---
  ---      SQL> select prev_sql_id, prev_child_number 
  ---           from v$session where sid=9;
  ---
  ---      PREV_SQL_ID   PREV_CHILD_NUMBER
  ---      ------------- -----------------
  ---      f98t6zufy04g5                 0
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * 
  ---      from table(dbms_xplan.display_cursor('f98t6zufy04g5', 0));
  ---
  ---    - Alternatively, you can combine the two statements into one
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from v$session s, 
  ---           table(dbms_xplan.display_cursor(s.prev_sql_id, 
  ---                                           s.prev_child_number)) t 
  ---      where s.sid=9;
  ---
  ---      NOTE: the table deriving the input parameters for 
  ---            DBMS_XPLAN.DISPLAY_CURSOR() must be the FIRST (left-side) 
  ---            table(s) in the select statement relative to the table function
  --- 
  ---  
  ---   3/ display all cursors containing the case sensisitve string 'FoOoO', 
  ---      excluding SQL parsed by SYS
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from v$sql s, 
  ---           table(dbms_xplan.display_cursor(s.sql_id, 
  ---                                           s.child_number)) t 
  ---      where s.sql_text like '%FoOoO%' and s.parsing_user_id <> 0;
  ---
  ---
  ---   4/ display all information about all cursors containing the case 
  ---      insensitive string 'FOO', including SQL parsed by SYS
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from v$sql s, 
  ---           table(dbms_xplan.display_cursor(s.sql_id, 
  ---                                           s.child_number, 'ALL')) t 
  ---      where upper(s.sql_text) like '%FOO%';
  ---
  ---
  ---   5/ display the last executed runtime statistics for all cursors
  ---      containing the case insensitive string 'sales', including SQL
  ---      parsed by SYS
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from v$sql s, 
  ---           table(dbms_xplan.display_cursor(s.sql_id, s.child_number, 
  ---                                           'ALLSTATS LAST')) t 
  ---      where lower(s.sql_text) like '%sales%';
  ---
  ---
  ---   6/ display the aggregated runtime statistics for all cursors containing 
  ---      the case sensitive string 'sAleS' and were parsed by user SH
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from v$sql s, dba_users u, 
  ---           table(dbms_xplan.display_cursor(s.sql_id, s.child_number, 
  ---                                           'RUNSTATS_TOT')) t 
  ---      where s.sql_text like '%sAleS%' 
  ---      and u.user_id=s.parsing_user_id 
  ---      and u.username='SH';
  ---
  ---   ------------------------------------------------------------------------
  ---   Examples DBMS_XPLAN.DISPLAY_AWR():
  ---
  ---   1/ display all stored plans in the AWR containing 
  ---      the case sensitive string 'sAleS'. Don't display predicate
  ---      information but add the query block name / alias section.
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from dba_hist_sqltext ht, 
  ---           table(dbms_xplan.display_awr(ht.sql_id, null, null, 
  ---                                        '-PREDICATE +ALIAS')) t 
  ---      where ht.sql_text like '%sAleS%'; 
  ---
  ---      NOTE: the table deriving the input parameters for 
  ---            DBMS_XPLAN.DISPLAY_AWR() must be the FIRST (left-side) 
  ---            table(s) in the select statement relative to the table 
  ---            function.
  ---
  ---   ------------------------------------------------------------------------
  ---   Examples DBMS_XPLAN.DISPLAY_SQLSET():
  ---
  ---   1/ display all stored plans for a given statement in the SQL tuning set 
  ---       named 'my_sts' owner by the current user (the caller).
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select * 
  ---      from table(dbms_xplan.display_sqlset('my_sts', 
  ---                                           'gcfysssf6hykh', 
  ---                                            null, 
  ---                                           'ALL -NOTE -PROJECTION')) t 
  ---
  ---   ------------------------------------------------------------------------
  ---   Examples DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE():
  ---
  ---   1/ display all plans of a SQL statement identified by the sql handle
  ---     'SYS_SQL_b1d49f6074ab95af' using TYPICAL format.
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.*
  ---      from table(dbms_xplan.display_sql_plan_baseline(
  ---                                           'SYS_SQL_b1d49f6074ab95af')) t;
  ---
  ---   2/ display all plans of one or more SQL statements containing the
  ---      string 'HR2' using BASIC format.
  ---
  ---      set linesize 150
  ---      set pagesize 2000
  ---      select t.* 
  ---      from (select distinct sql_handle from dba_sql_plan_baselines
  ---            where sql_text like '%HR2%') pb,
  ---           table(dbms_xplan.display_sql_plan_baseline(pb.sql_handle, null,
  ---                                                      'basic')) t;
  ---
  ---      NOTE: the table deriving the input parameters for
  ---            DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE() must be the first
  ---            (left-side) table in the select statement relative to the
  ---            table function.
  ---
  --- -------------------------------------------------------------------------

  -- display from PLAN_TABLE
  function display(table_name   varchar2      default 'PLAN_TABLE',
                   statement_id varchar2      default null,
                   format       varchar2      default 'TYPICAL',
                   filter_preds varchar2      default null)
  return dbms_xplan_type_table 
  pipelined;

  -- display from V$SQL_PLAN (or V$SQL_PLAN_STATISTICS_ALL)
  function display_cursor(sql_id           varchar2 default  null,
                          cursor_child_no  integer  default  0,
                          format           varchar2 default  'TYPICAL')
  return dbms_xplan_type_table 
  pipelined;

  -- display from AWR
  function display_awr(sql_id          varchar2,
                       plan_hash_value integer  default null,
                       db_id           integer  default null,
                       format          varchar2 default 'TYPICAL')
  return dbms_xplan_type_table 
  pipelined;

  -- display from SQL tuning set
  function display_sqlset(sqlset_name     varchar2,
                          sql_id          varchar2,
                          plan_hash_value integer  default null,
                          format          varchar2 default 'TYPICAL',
                          sqlset_owner    varchar2 default null)
  return dbms_xplan_type_table 
  pipelined;
    
  -- display from SQL plan baseline
  function display_sql_plan_baseline(sql_handle    varchar2 default null,
                                     plan_name     varchar2 default null,
                                     format        varchar2 default 'TYPICAL')
  return dbms_xplan_type_table
  pipelined;

  ----------------------------------------------------------------------------
  -- ---------------------------------------------------------------------- --
  --                                                                        --
  -- The folloing section of this package contains functions and procedures --
  -- which are for INTERNAL use ONLY. PLEASE DO NO DOCUMENT THEM.           --
  --                                                                        --
  -- ---------------------------------------------------------------------- --
  ----------------------------------------------------------------------------
  -- private procedure, used internally
  function  prepare_records(plan_cur        IN sys_refcursor,
                            i_format_flags  IN binary_integer)
  return dbms_xplan_type_table 
  pipelined;
   
  -- private function to validate the user format (used internally)
  function validate_format(hasPlanStats  IN  boolean,
                           format        IN  VARCHAR2,
                           format_flags  OUT BINARY_INTEGER)
  return boolean;
  
  FUNCTION format_size(num number) 
  RETURN varchar2;

  FUNCTION format_number(num number) 
  RETURN varchar2;

  FUNCTION format_size2(num number) 
  RETURN varchar2;

  FUNCTION format_number2(num number) 
  RETURN varchar2;

  --
  -- formats a number representing time in seconds using the format HH:MM:SS.
  -- This function is internal to this package
  --
  function format_time_s(num number)
  return varchar2;

  --  
  -- This is a helper function to build the XML version of the text of the 
  -- select query that is run before the display display function to retrieve 
  -- and display the execution plan of a SQL.
  -- All this function does it to wrap a given query, used to fetch a plan, by
  -- XML construct. The goal is to maintain ONE and SINGLE version of the XML
  -- format we use for the plan table. 
  --
  -- This function is also called by prvtspai.sql in sqltune directory. 
  -- table_query : query to fetch plan from a plan table
  --
  FUNCTION prepare_plan_xml_query(
    plan_query IN VARCHAR2)                     -- query to fetch plan table 
  RETURN VARCHAR2;

  --  
  -- This function builds the xml version of an explain plan. 
  -- The function queries the caller specified plan table and format the 
  -- resulting plan lines into XML before returning them to the caller. 
  --
  -- table_name  : name of the table or view that stores the plan
  -- statement_id: identifier of the sql statement in the plan table
  -- plan_id     : identifier of the sql plan in the plan table. Currently 
  --               used by sql replay only. SQL replay is used to produce plans
  --               for SQL stored in sql tuning set using plan_ids and so 
  --               we need to be able to share the query we use to get the plans.
  -- format      : format of the plan output. See description in 
  --               function display 
  -- filter_preds: predicate to filter the content of the plan table
  -- plan_tag    : caller specified name of the root element in the plan xml 
  --               tree. by default it is set to 'xplan'
  -- report_ref  : optional report reference. Needed only to generate 
  --               xml of the servelet. 
  --
  function build_plan_xml(
    table_name    in  varchar2  default 'PLAN_TABLE',
    statement_id  in  varchar2  default NULL,
    plan_id       in  number    default NULL,
    format        in  varchar2  default 'TYPICAL',
    filter_preds  in  varchar2  default NULL,
    plan_tag      in  varchar2  default 'plan',
    report_ref    in  varchar2  default NULL)
  return xmltype;

  --  
  -- This function returns an explain plan in a CLOB format. 
  -- The function queries the caller specified plan table, generate the 
  -- resulting plan lines into XML and then calls the XML reporting framework
  -- the produce and return the plan as a CLOB. 
  --
  -- table_name  : name of the table or view that stores the plan
  -- statement_id: identifier of the sql statement in the plan table
  -- format      : format of the plan output. See description in 
  --               function display 
  -- filter_preds: predicate to filter the content of the plan table
  -- type        : type of output. Possible values are:
  --               TEXT (default), HTML, ACTIVE, or XML.
  --
  function display_plan(
    table_name    in  varchar2  default 'PLAN_TABLE',
    statement_id  in  varchar2  default NULL,
    format        in  varchar2  default 'TYPICAL',
    filter_preds  in  varchar2  default NULL,
    type          in  varchar2  default 'TEXT')
  return clob;

  ----------------------------- diff_plan_outline ------------------------------
  --  
  -- This function compares two sql plans generated by the given outlines
  -- The job is done via a SQLDiag task and the function returns the task_id
  --
  -- PARAMETERS:
  --     sql_text              (IN)  -  text of the SQL statement
  --     outline1              (IN)  -  outline - for base plan
  --     outline2              (IN)  -  outline - for target plan
  --     user_name             (IN)  -  the parsing schema name
  --                                    default to current user
  --
  -- RETURN:
  --     task_id: can be used to retrieve the report of findings later
  ------------------------------------------------------------------------------
  function diff_plan_outline(
    sql_text      in  clob,
    outline1      in  clob,
    outline2      in  clob,
    user_name     in  varchar2 := NULL)
  return varchar2;

  ----------------------------- diff_plan  -------------------------------------
  --  
  -- This function compares two sql plans 
  --   reference plan: implicitly defined
  --   target plan:    a plan generated by the given outline
  --
  -- The job is done via a SQLDiag task and the function returns the task_id
  --
  -- PARAMETERS:
  --     sql_text          (IN)  -  text of the SQL statement
  --     outline           (IN)  -  used to generate the target plan
  --     user_name         (IN)  -  the parsing schema name
  --                                default to current user
  --
  -- RETURN:
  --     task_id: can be used to retrieve the report of findings later
  ------------------------------------------------------------------------------
  function diff_plan(
    sql_text      in  clob,
    outline       in  clob,
    user_name     in  varchar2 := NULL)
  return varchar2;

  ----------------------------- diff_plan_sql_baseline -------------------------
  --  
  -- This function compares two given sql plans (specified via plan_names)
  -- The job is done via a SQLDiag task and the function returns the task_id
  --
  -- PARAMETERS:
  --     baseline_plan_name1   (IN)  -  plan name - base
  --     baseline_plan_name2   (IN)  -  plan name - target
  --
  -- RETURN:
  --     task_id: can be used to retrieve the report of findings later
  ------------------------------------------------------------------------------
  function diff_plan_sql_baseline(
    baseline_plan_name1    in  varchar2,
    baseline_plan_name2    in  varchar2)
  return varchar2;

  ----------------------------- diff_plan_cursor -------------------------------
  --  
  -- This function compares two sql plans derived from the given cursor child #
  -- The job is done via a SQLDiag task and the function returns the task_id
  --
  -- PARAMETERS:
  --     sql_id                (IN)  -  sql id to specify a SQL statement
  --     cursor_child_num1     (IN)  -  child number - for base plan
  --     cursor_child_num2     (IN)  -  child number - for target plan
  --
  -- RETURN:
  --     task_id: can be used to retrieve the report of findings later
  ------------------------------------------------------------------------------
  function diff_plan_cursor(
    sql_id             IN   VARCHAR2,
    cursor_child_num1  IN   NUMBER,
    cursor_child_num2  IN   NUMBER)
  return varchar2;

  ----------------------------- diff_plan_awr ----------------------------------
  --  
  -- This function compares two sql plans specified by the given plan hash ids
  -- The job is done via a SQLDiag task and the function returns the task_id
  --
  -- PARAMETERS:
  --     sql_id                (IN)  -  sql id to specify a SQL statement
  --     plan_hash_value1      (IN)  -  base plan
  --     plan_hash_value1      (IN)  -  target plan
  --
  -- RETURN:
  --     task_id: can be used to retrieve the report of findings later
  ------------------------------------------------------------------------------
  function diff_plan_awr(
    sql_id             IN   VARCHAR2,
    plan_hash_value1   IN   NUMBER,
    plan_hash_value2   IN   NUMBER)
  return varchar2;

  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --               ------------------------------------------                 --
  --                        PLAN DIFF SUPPORT FUNCTIONS                       --
  --               ------------------------------------------                 --
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  ------------------------------ get_report_xml --------------------------------
  -- NAME: 
  --     get_report_xml
  --
  -- DESCRIPTION:
  --     This function builds the entire report in XML. 
  --
  -- PARAMETERS:
  --     report_ref        (IN)    - the report reference string that
  --                                 identifies this report
  --     tid               (IN)    - task ID
  --     method            (IN)    - method of comparing, eg, 'outline'
  -- RETURN:
  --     the report in XML
  ------------------------------------------------------------------------------
  FUNCTION get_plandiff_report_xml(
    report_ref   IN VARCHAR2 := NULL,
    tid          IN NUMBER,
    method       IN VARCHAR2)
  RETURN XMLTYPE;

end dbms_xplan;
/

create or replace public synonym dbms_xplan for sys.dbms_xplan
/
grant execute on dbms_xplan to public
/


