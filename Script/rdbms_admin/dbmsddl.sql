Rem Copyright (c) 2004, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsddl.sql - Access to DDL statements from PL/SQL.
Rem
Rem    DESCRIPTION
Rem      This package provides access to some SQL DDL statements from
Rem      stored procedures.
Rem      It also provides some special administration operations that are
Rem      not available as DDLs.
Rem
Rem    NOTES
Rem      Procedure 'dbms_ddl.alter_table_referenceable',
Rem      'dbms_ddl.alter_table_not_referenceable',
Rem      'dbms_ddl.alter_compile' and 'dbms_ddl.analyze_object'
Rem      commit the current transaction, perform the operation, and 
Rem      then commit again.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ajadams     11/11/08 - add _with_commit to supplemental_log_data pragma
Rem    ajadams     10/08/08 - rename fire_once_only to fire_once
Rem    rmacnico    10/03/07 - bug 6470986: added is_apply_server
Rem    lvbcheng    03/11/05 - Add reuse settings comment 
Rem    jmuller     08/06/04 - Fix bug 3741707: add reuse_settings parm to 
Rem                           alter_compile 
Rem    kquinn      07/12/04 - 3733108: Tidy up comments 
Rem    gviswana    06/04/04 - Update comments for wrap 
Rem    gviswana    05/28/04 - gviswana_dbms_ddl_wrap
Rem    gviswana    05/06/04 - Forked from dbmsutil.sql
Rem

create or replace package dbms_ddl AUTHID CURRENT_USER is

  -- used by set_trigger_firing_property
  FIRE_ONCE         CONSTANT  NUMBER := 1;
  APPLY_SERVER_ONLY CONSTANT  NUMBER := 2;

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure alter_compile(type varchar2, schema varchar2, name varchar2, 
                          reuse_settings boolean := FALSE);
  --  Equivalent to SQL "ALTER PROCEDURE|FUNCTION|PACKAGE [<schema>.]
  --    <name> COMPILE [BODY] ?REUSE SETTINGS?".  If the named object is this
  --    package, or any packages upon which it depends (currently "standard" or 
  --    "dbms_standard") then the procedure simply returns (since these
  --    packages are clearly successfully compiled).
  --  Input arguments:
  --    type
  --      Must be one of "PROCEDURE", "FUNCTION", "PACKAGE", "PACKAGE
  --      BODY" or "TRIGGER".
  --    schema
  --      The schema name.  If NULL then use current schema.  
  --      This is uppercased unless enclosed in double quotes (").
  --    name
  --      The name of the object.  
  --      This is uppercased unless enclosed in double quotes (").
  --    reuse_settings
  --      This is a boolean flag that indicates whether the session settings in
  --      the objects should be reused, or whether the current session settings
  --      should be picked up instead.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges or object does not exist.
  --    ORA-20001: Remote object, cannot compile.
  --    ORA-20002: Bad value for object type.  Should be one of PACKAGE,
  --      PACKAGE BODY, PROCEDURE, FUNCTION, or TRIGGER.
  procedure analyze_object
    (type varchar2, schema varchar2, name varchar2, method varchar2,
     estimate_rows number default null, 
     estimate_percent number default null, method_opt varchar2 default null,
     partname varchar2 default null);
  --  Equivalent to SQL "ANALYZE TABLE|CLUSTER|INDEX [<schema>.]<name>
  --    [<method>] STATISTICS [SAMPLE <n> [ROWS|PERCENT]]"
  --  Input arguments:
  --    type
  --      One of 'TABLE', 'CLUSTER' or 'INDEX'.  If none of these, the
  --      procedure just returns.
  --    schema
  --      schema of object to analyze.  NULL means current schema.  
  --      This is uppercased unless enclosed in double quotes (").
  --    name
  --      name of object to analyze.  
  --      This is uppercased unless enclosed in double quotes (").
  --    method
  --      One of 'ESTIMATE', 'COMPUTE' or 'DELETE'. If 'ESTIMATE' then either 
  --      estimate_rows or estimate_percent must be non-zero.
  --    estimate_rows
  --      Number of rows to estimate
  --    estimate_percent
  --      Percentage of rows to estimate.  If estimate_rows is specified
  --      than ignore this parameter.
  --    method_opt
  --      method options of the following format
  --      [ FOR TABLE ]
  --      [ FOR ALL [INDEXED] COLUMNS] [SIZE n]
  --      [ FOR ALL INDEXES ]
  --    partname
  --      specific partition to be analyzed.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges or object does not exist.
  --    ORA-20001: Bad value for object type.  Should be one of TABLE, INDEX
  --      or CLUSTER.
  --    ORA-20002: METHOD must be one of COMPUTE,ESTIMATE or DELETE
  procedure alter_table_referenceable
    (table_name varchar2, table_schema varchar2 default null,
     affected_schema varchar2 default null);
  --  Alter the given object table table_schema.table_name so it becomes the
  --  referenceable table for the given schema affected_schema.
  --  This is equivalent to SQL "ALTER TABLE [<table_schema>.]<table_name>
  --  REFERENCEABLE FOR <affected_schema>" which is currently not supported or
  --  available as a DDL statement.
  --
  --  When you create an object table, it automatically becomes referenceable,
  --  unless you use the OID AS clause when creating the table.
  --  The OID AS clause allows you to create an object table and to assign
  --  to the new table the same EOID as another object table of the same type.
  --  After you create a new table using the OID AS clause, you end up with
  --  two object table with the same EOID; the new table is not referenceable,
  --  the original one is.  All references that used to point to the objects
  --  in the original table still reference the same objects in the same
  --  original table.
  --
  --  If you execute this procedure on the new table, it will make the new
  --  table the referenceable table replacing the original one; thus, those
  --  references now point to the objects in the new table instead of the
  --  original table.
  --
  --  For example, the following steps recreate an object table that needs
  --  to be reorganized for some reasons:
  --    CREATE TABLE EMP_NEW OF EMPLOYEE OID AS EMP;
  --    INSERT INTO EMP_NEW (SYS_NC_OID$, EMP_NEW)
  --      SELECT SYS_NC_OID$, EMP FROM EMP;
  --    EXECUTE DBMS_DDL.ALTER_TABLE_REFERENCEABLE('EMP_NEW');
  --      -- table_schema defaults to NULL, thus use the current schema, and
  --      -- affected_schema defaults to NULL, thus use PUBLIC, which means
  --      -- all schemas will be affected
  --    RENAME EMP TO EMP_OLD;
  --    RENAME EMP_NEW TO EMP;
  --
  --  The affected schema can be PUBLIC or a particular schema.  If it is
  --  PUBLIC, all schemas are affected.  If it is a particular schema, only
  --  that schema is affected.
  --
  --  The user that executes this procedure must own the new table (i.e.,
  --  the schema is the same as the user), and the affected schema must be the
  --  same as the user or PUBLIC. If the affected schema is PUBLIC, then the
  --  user must own the old mapping table for PUBLIC as well.
  --
  --  If the user executing this procedure has ALTER ANY TABLE and SELECT ANY
  --  TABLE and DROP ANY TABLE privileges, the user doesn't have to own the
  --  tables, and the affected schema can be any valid schema or PUBLIC.
  --
  --  Input arguments:
  --    table_name
  --      The name of the table to be altered.  Cannot be a synonym.
  --      Must not be NULL.  Case sensitive.
  --    table_schema
  --      The name of the schema owning the table to be altered.
  --      If NULL then the current schema is used.  Case sensitive.
  --    affected_schema
  --      The name of the schema affected by this alteration.
  --      If NULL then PUBLIC is used.  Case sensitive.
  --  Exceptions:
  --    ORA-20000: insufficient privileges, invalid schema name
  --               or table does not exist,
  procedure alter_table_not_referenceable
    (table_name varchar2, table_schema varchar2 default null,
     affected_schema varchar2 default null);
  --  Alter the given object table table_schema.table_name so it becomes not
  --  the default referenceable table for the schema affected_schema.
  --  This is equivalent to SQL "ALTER TABLE [<table_schema>.]<table_name>
  --  NOT REFERENCEABLE FOR <affected_schema>"
  --  which is currently not supported or available as a DDL statement.
  --  This procedure simply reverts for the affected schema to the default
  --  table referenceable for PUBLIC; i.e., it simply undoes the previous
  --  alter_table_referenceable call for this specific schema.
  --
  --  The affected schema must a particular schema (cannot be PUBLIC).
  --
  --  The user that executes this procedure must own the table (i.e.,
  --  the schema is the same as the user), and the affected schema must be
  --  the same as the user.
  --
  --  If the user executing this procedure has ALTER ANY TABLE and SELECT ANY
  --  TABLE and DROP ANY TABLE privileges, the user doesn't have to own the
  --  table and the affected schema can be any valid schema.
  --
  --  Input arguments:
  --    table_name
  --      The name of the table to be altered.  Cannot be a synonym.
  --      Must not be NULL.  Case sensitive.
  --    table_schema
  --      The name of the schema owning the table to be altered.
  --      If NULL then the current schema is used.  Case sensitive.
  --    affected_schema
  --      The name of the schema affected by this alteration.
  --      If NULL then the current schema is used.  Case sensitive.
  --  Exceptions:
  --    ORA-20000: insufficient privileges, invalid schema name or
  --               table does not exist,

  PROCEDURE set_trigger_firing_property(trig_owner    IN VARCHAR2,
                                        trig_name     IN VARCHAR2,
                                        fire_once     IN BOOLEAN);

  PRAGMA SUPPLEMENTAL_LOG_DATA(set_trigger_firing_property, AUTO_WITH_COMMIT);

  PROCEDURE set_trigger_firing_property(trig_owner    IN VARCHAR2,
                                        trig_name     IN VARCHAR2,
                                        property      IN BINARY_INTEGER,
                                        setting       IN BOOLEAN);

  PRAGMA SUPPLEMENTAL_LOG_DATA(set_trigger_firing_property, AUTO_WITH_COMMIT);

  --- ------------------------------------------------------------------------
  --- Any changes to the data dictionary will be committed without
  --- interfering user's transaction flow.
  --- 
  ---  Overloaded since original implementation hardcoded only one property
  ---  with generic named procedure and is already in use. 
  ---  The old prototype should be deprecated
  ---
  ---   Input arguments:
  ---     trig_owner
  ---       owner of the trigger.
  ---       This is uppercased unless enclosed in double quotes (").
  ---     trig_name
  ---       name of the trigger.
  ---       This is uppercased unless enclosed in double quotes (").
  --- OLD:
  ---     fire_once
  ---       If TRUE, set a bit to indicate that this trigger will only be
  ---       fired once (in one place) and won't be fired due to
  ---       data synchronization done by Oracle.
  ---       Otherwise, set the bit to FALSE and the trigger will always
  ---       be fired, subject to its enable/disable property, regardless
  ---       of whether it's in data synchronization done by Oracle.
  --- NEW:
  ---     property
  ---       Package define of valid trigger properties that can be set
  ---       see top of package definition for valid values
  ---     setting
  ---       If TRUE set the requested property to true otherwise clear bit
  ---  Exceptions:
  ---     ORA-04072: invalid type.
  ---     ORA-23308: object %s.%s does not exist or is invalid.
  ---     ORA-01031: insufficient privilege.

  FUNCTION is_trigger_fire_once(trig_owner    IN VARCHAR2,
                                trig_name     IN VARCHAR2) RETURN BOOLEAN;

  --- ------------------------------------------------------------------------
  --- return TRUE iff the given trigger should be fired once (one place) only.
  --- 
  ---   Input arguments:
  ---     trig_owner
  ---       owner of the trigger.
  ---       This is uppercased unless enclosed in double quotes (").
  ---     trig_name
  ---       name of the trigger.
  ---       This is uppercased unless enclosed in double quotes (").
  ---  Exceptions:
  ---     ORA-04072: invalid type.
  ---     ORA-23308: object %s.%s does not exist or is invalid.

  FUNCTION is_trigger_fire_once_internal(trig_owner    IN VARCHAR2,
                                         trig_name     IN VARCHAR2)
    RETURN BINARY_INTEGER;
  --- ------------------------------------------------------------------------
  --- For internal use only.

  
  /*
   * NAME:
   *   wrap
   *
   * PARAMETERS:
   *   ddl    (IN) - CREATE OR REPLACE statement specifying a 
   *                 package specification, package body, type specification,
   *                 type body, procedure or function.
   *
   * DESCRIPTION:
   *   This API takes the input DDL statement specifying creation of a
   *   PL/SQL unit and returns a DDL statement with the PL/SQL source
   *   obfuscated. Obfuscation is done in the same manner as the standalone
   *   "wrap" tool. If the input does not specify a PL/SQL unit that can
   *   be wrapped or if the input has simple syntax errors, exception
   *   MALFORMED_WRAP_INPUT will be raised.
   *
   * NOTES:
   *   This API has three overload candidates. The first candidate accepts
   *   VARCHAR2 input. The second and third candidates accept collection-
   *   of-VARCHAR2 input allowing larger DDL statements. 
   *
   *   If you call dbms_sql.parse() on the result of dbms_ddl.wrap(), please
   *   note that you must set the LFFLG parameter to FALSE. If you set LFFLG
   *   to TRUE, the additional newlines in the middle of the obfuscated unit
   *   will confuse the PL/SQL compiler and cause the unit to be created with
   *   errors.
   */
  FUNCTION wrap(ddl VARCHAR2) RETURN VARCHAR2;
  FUNCTION wrap(ddl dbms_sql.varchar2s, lb PLS_INTEGER, ub PLS_INTEGER)
    RETURN dbms_sql.varchar2s;
  FUNCTION wrap(ddl dbms_sql.varchar2a, lb PLS_INTEGER, ub PLS_INTEGER)
    RETURN dbms_sql.varchar2a;

  /*
   * NAME:
   *   create_wrapped
   *
   * PARAMETERS:
   *   ddl    (IN) - CREATE OR REPLACE statement specifying a 
   *                 package specification, package body, type specification,
   *                 type body, procedure or function.
   *
   * DESCRIPTION:
   *   DBMS_DDL.CREATE_WRAPPED(ddl) is equivalent to 
   *   - DBMS_SQL.PARSE(<cursor>, DBMS_DDL.WRAP(ddl))
   *   In other words, it obfuscates the text of the input CREATE OR
   *   REPLACE statement and executes it. This API will provide better
   *   performance than executing the individual operations.
   *
   * NOTES:
   *   This API has three overload candidates. The first candidate accepts
   *   VARCHAR2 input. The second and third candidates accept collection-
   *   of-VARCHAR2 input allowing larger DDL statements. 
   */
  PROCEDURE create_wrapped(ddl VARCHAR2);
  PROCEDURE create_wrapped(ddl dbms_sql.varchar2s, lb PLS_INTEGER,
                           ub PLS_INTEGER);
  PROCEDURE create_wrapped(ddl dbms_sql.varchar2a, lb PLS_INTEGER,
                           ub PLS_INTEGER);

  malformed_wrap_input EXCEPTION;
  pragma exception_init(malformed_wrap_input, -24230);
end;
/

create or replace public synonym dbms_ddl for sys.dbms_ddl;
grant execute on dbms_ddl to public;

