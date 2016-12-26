Rem
Rem $Header: rdbms/admin/catstrt.sql /st_rdbms_11.2.0/2 2011/05/13 11:32:36 yurxu Exp $
Rem
Rem catstrt.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catstrt.sql - STReams Transformation catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    yurxu       01/28/10 - Bug 9216488: duplicate dba_xstream_administrator
Rem                           to dba_streams_administrator
Rem    yurxu       12/28/09 - Bug-9216453: duplicate dba_stream_administrator
Rem                           to dba_xstream_administrator
Rem    thoang      10/13/09 - add dba_xstream_administrator
Rem    rihuang     09/19/08 - Add view DBA_STREAMS_KEEP_COLUMNS
Rem    jinwu       11/09/06 - add Streams Transformation catalog views
Rem    jinwu       11/09/06 - Created
Rem


-- This cannot be placed in sql.bsq because of a sys.anydata column
rem streams$_internal_transform is populated by APIs in dbms_streams_adm
create table streams$_internal_transform
(
  rule_owner           varchar2(30) not null,                  /* rule owner */
  rule_name            varchar2(30) not null,                   /* rule name */
  declarative_type     number,                  /* The type of the transform */
  from_schema_name     varchar2(30),                      /* old schema name */
  to_schema_name       varchar2(30),                      /* new schema name */
  from_table_name      varchar2(30),                       /* old table name */
  to_table_name        varchar2(30),                       /* new table name */
  schema_name          varchar2(30),                          /* schema name */
  table_name           varchar2(30),                           /* table name */
  from_column_name     varchar2(4000),                    /* old column name */
  to_column_name       varchar2(4000),                    /* new column name */
  column_name          varchar2(4000),                        /* column name */
  column_value         sys.anydata,                  /* default column value */
  column_type          number,                                /* column type */
  column_function      varchar2(30),                 /* column function name */
  value_type           number,     /* to transform old, new, or both columns */
  step_number          number,                               /* order to run */
  precedence           number,          /* order to run for same step number */
  spare1               number,
  spare2               number,
  spare3               varchar2(4000)
)
/
create index i_streams_internal_transform1 on
  streams$_internal_transform(rule_owner, rule_name)
/


----------------------------------------------------------------------------
-- Views on transform functions
----------------------------------------------------------------------------

create or replace view "_DBA_STREAMS_TRANSFM_FUNCTION"
  (RULE_OWNER, RULE_NAME, VALUE_TYPE, TRANSFORM_FUNCTION_NAME, CUSTOM_TYPE)
as
select r.rule_owner, r.rule_name, SYS.ANYDATA.GetTypeName(ctx.nvn_value),
       DECODE(SYS.ANYDATA.GetTypeName(ctx.nvn_value), 
              'SYS.VARCHAR2', SYS.ANYDATA.AccessVarchar2(ctx.nvn_value), 
              NULL),
       DECODE(ctx.nvn_name, 'STREAMS$_TRANSFORM_FUNCTION', 'ONE TO ONE',
                            'STREAMS$_ARRAY_TRANS_FUNCTION', 'ONE TO MANY')
from   DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where  ctx.nvn_name = 'STREAMS$_TRANSFORM_FUNCTION'
   OR  ctx.nvn_name = 'STREAMS$_ARRAY_TRANS_FUNCTION'
/

-- dba_streams_transform_function view
create or replace view DBA_STREAMS_TRANSFORM_FUNCTION
  (RULE_OWNER, RULE_NAME, VALUE_TYPE, TRANSFORM_FUNCTION_NAME, CUSTOM_TYPE) 
as
select rule_owner, rule_name, value_type, transform_function_name, custom_type
from   "_DBA_STREAMS_TRANSFM_FUNCTION"
/
comment on table DBA_STREAMS_TRANSFORM_FUNCTION is
'Rules-based transform functions used by Streams'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.RULE_OWNER is
'The owner of the rule associated with the transform function'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.RULE_NAME is
'The name of the rule associated with the transform function'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.VALUE_TYPE is
'The type of the transform function name.  This type must be VARCHAR2 for a rule-based transformation to work properly'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.TRANSFORM_FUNCTION_NAME is
'The name of the transform function, or NULL if the VALUE_TYPE is not VARCHAR2'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.CUSTOM_TYPE is
'The type of the transform function'
/
create or replace public synonym DBA_STREAMS_TRANSFORM_FUNCTION
  for DBA_STREAMS_TRANSFORM_FUNCTION
/
grant select on DBA_STREAMS_TRANSFORM_FUNCTION to select_catalog_role
/

-- all_streams_transform_function view
create or replace view ALL_STREAMS_TRANSFORM_FUNCTION as
select tf.*
from   DBA_STREAMS_TRANSFORM_FUNCTION tf, ALL_RULES r 
where  tf.rule_owner = r.rule_owner
and    tf.rule_name = r.rule_name
/
comment on table ALL_STREAMS_TRANSFORM_FUNCTION is
'Rules-based transform functions used by Streams'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.RULE_OWNER is
'The owner of the rule associated with the transform function'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.RULE_NAME is
'The name of the rule associated with the transform function'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.VALUE_TYPE is
'The type of the transform function name.  This type must be VARCHAR2 for a rule-based transformation to work properly'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.TRANSFORM_FUNCTION_NAME is
'The name of the transform function, or NULL if the VALUE_TYPE is not VARCHAR2'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.CUSTOM_TYPE is
'The type of the transform function'
/
create or replace public synonym ALL_STREAMS_TRANSFORM_FUNCTION
  for ALL_STREAMS_TRANSFORM_FUNCTION
/
grant select on ALL_STREAMS_TRANSFORM_FUNCTION to public with grant option
/

----------------------------------------------------------------------------
-- Views on streams$_privileged_user table
----------------------------------------------------------------------------

-- Private view to select all columns from sys.streams$_privileged_user.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_PRIVILEGED_USER"
as select * from sys.streams$_privileged_user
/
grant select on "_DBA_STREAMS_PRIVILEGED_USER" to exp_full_database
/

create or replace view DBA_STREAMS_ADMINISTRATOR (USERNAME, LOCAL_PRIVILEGES,
                                                  ACCESS_FROM_REMOTE)
as
select u.name, decode(bitand(pu.privs, 1), 0, 'NO', 'YES'),
       decode(bitand(pu.privs, 2), 0, 'NO', 'YES')
  from user$ u, "_DBA_STREAMS_PRIVILEGED_USER" pu
 where u.user# = pu.user# AND pu.privs != 0 and
       (pu.flags IS NULL or pu.flags = 0 or (bitand(pu.flags, 1) = 1))
/

comment on table DBA_STREAMS_ADMINISTRATOR is
'Users granted the privileges to be a streams administrator'
/
comment on column DBA_STREAMS_ADMINISTRATOR.USERNAME is
'Name of the user who has been granted privileges to be streams administrator'
/
comment on column DBA_STREAMS_ADMINISTRATOR.LOCAL_PRIVILEGES is
'YES, if user has been granted local Streams admininstrator privileges.  NO, if the user does not have local Streams administrator privileges.'
/
comment on column DBA_STREAMS_ADMINISTRATOR.ACCESS_FROM_REMOTE is
'YES, if user can be used for remote Streams administration through a database link.  NO, if the user cannot be used for remote Streams administration'
/
create or replace public synonym DBA_STREAMS_ADMINISTRATOR
  for DBA_STREAMS_ADMINISTRATOR
/
grant select on DBA_STREAMS_ADMINISTRATOR to select_catalog_role
/

-- XStream admin is not considered as Streams admin.
create or replace view DBA_XSTREAM_ADMINISTRATOR (USERNAME, PRIVILEGE_TYPE,
  GRANT_SELECT_PRIVILEGES, CREATE_TIME)
as
select xp.username,
       decode(xp.privilege_type, 1, 'CAPTURE',
                              2, 'APPLY',
                              3, '*'),
       decode(xp.privilege_level, 0, 'NO',
                               1, 'YES'),
       xp.create_time
  from sys.xstream$_privileges xp
/

comment on table DBA_XSTREAM_ADMINISTRATOR is
'Users granted the privileges to be a XStream administrator'
/
comment on column DBA_XSTREAM_ADMINISTRATOR.USERNAME is
'Name of the user who has been granted privileges to be XStream administrator'
/
comment on column DBA_XSTREAM_ADMINISTRATOR.PRIVILEGE_TYPE is
'Type of privilege granted'
/
comment on column DBA_XSTREAM_ADMINISTRATOR.GRANT_SELECT_PRIVILEGES is
'Whether to grant select privileges'
/
comment on column DBA_XSTREAM_ADMINISTRATOR.CREATE_TIME is
'Timestamp for the granted privilege'
/
create or replace public synonym DBA_XSTREAM_ADMINISTRATOR
  for DBA_XSTREAM_ADMINISTRATOR
/
grant select on DBA_XSTREAM_ADMINISTRATOR to select_catalog_role
/

-- XStream admin is not considered as Streams admin.
create or replace view ALL_XSTREAM_ADMINISTRATOR (USERNAME, PRIVILEGE_TYPE,
  GRANT_SELECT_PRIVILEGES, CREATE_TIME)
as
(select xp.username,
       decode(xp.privilege_type, 1, 'CAPTURE',
                              2, 'APPLY',
                              3, '*'),
       decode(xp.privilege_level, 0, 'NO',
                               1, 'YES'),
       xp.create_time
  from sys.xstream$_privileges xp, sys.user$ u, dba_role_privs rp
  where ((xp.username = u.name) and  (u.user# = userenv('SCHEMAID')))
union
select xp.username,
       decode(xp.privilege_type, 1, 'CAPTURE',
                              2, 'APPLY',
                              3, '*'),
       decode(xp.privilege_level, 0, 'NO',
                               1, 'YES'),
       xp.create_time
  from sys.xstream$_privileges xp, sys.user$ u, dba_role_privs rp
  where (u.name = rp.grantee
        and rp.granted_role = 'SELECT_CATALOG_ROLE'
        and (u.user# = userenv('SCHEMAID'))))
/

comment on table ALL_XSTREAM_ADMINISTRATOR is
'Users granted the privileges to be a XStream administrator for the user'
/
comment on column ALL_XSTREAM_ADMINISTRATOR.USERNAME is
'Name of the user who has been granted privileges to be XStream administrator'
/
comment on column ALL_XSTREAM_ADMINISTRATOR.PRIVILEGE_TYPE is
'Type of privilege granted'
/
comment on column ALL_XSTREAM_ADMINISTRATOR.GRANT_SELECT_PRIVILEGES is
'Whether to grant select privileges'
/
comment on column ALL_XSTREAM_ADMINISTRATOR.CREATE_TIME is
'Timestamp for the granted privilege'
/
create or replace public synonym ALL_XSTREAM_ADMINISTRATOR
  for ALL_XSTREAM_ADMINISTRATOR
/
grant select on ALL_XSTREAM_ADMINISTRATOR to select_catalog_role
/


----------------------------------------------------------------------------
-- Views on streams$_internal_transform table
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_internal_transform
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_TRANSFORMATIONS"
as select * from sys.streams$_internal_transform
/
grant select on "_DBA_STREAMS_TRANSFORMATIONS" to exp_full_database
/

create or replace view DBA_STREAMS_TRANSFORMATIONS
  (RULE_OWNER, RULE_NAME, TRANSFORM_TYPE, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   FROM_TABLE_NAME, TO_TABLE_NAME, SCHEMA_NAME, TABLE_NAME,
   FROM_COLUMN_NAME, TO_COLUMN_NAME, COLUMN_NAME, COLUMN_VALUE,
   COLUMN_TYPE, COLUMN_FUNCTION, VALUE_TYPE, USER_FUNCTION_NAME,
   SUBSETTING_OPERATION, DML_CONDITION, DECLARATIVE_TYPE, PRECEDENCE,
   STEP_NUMBER)
as
select rule_owner, rule_name, 'DECLARATIVE TRANSFORMATION',
  from_schema_name, to_schema_name, from_table_name, to_table_name,
  schema_name, table_name, from_column_name, to_column_name,
  column_name, column_value, sys.anydata.gettypename(column_value), 
  column_function, 
  decode(value_type, 1, 'OLD',
                     2, 'NEW',
                     3, '*'), 
  NULL, NULL, NULL,  decode(declarative_type, 0, 'KEEP COLUMNS',
                                              1, 'DELETE COLUMN',
                                              2, 'RENAME COLUMN',
                                              3, 'ADD COLUMN',
                                              4, 'RENAME TABLE',
                                              5, 'RENAME SCHEMA'), 
  precedence, step_number
  from "_DBA_STREAMS_TRANSFORMATIONS" t
union all
select rule_owner, rule_name, 'SUBSET RULE', NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  decode(subsetting_operation, 1, 'INSERT',
                               2, 'UPDATE',
                               3, 'DELETE'),
  dml_condition, NULL, NULL, NULL
  from sys.streams$_rules where subsetting_operation is not NULL
union all
select rule_owner, rule_name, 'CUSTOM TRANSFORMATION', NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  transform_function_name, NULL, NULL, NULL, NULL, NULL
  from "_DBA_STREAMS_TRANSFM_FUNCTION"
/

comment on table DBA_STREAMS_TRANSFORMATIONS is
'Transformations defined on rules'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TRANSFORM_TYPE is
'The type of transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_TABLE_NAME is
'The table to be renamed'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_TABLE_NAME is
'The new table name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_COLUMN_NAME is
'The column to rename'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_COLUMN_NAME is
'The new column name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_NAME is
'The column to add or delete'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_VALUE is
'The value of the column to add'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_TYPE is
'The type of the new column'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_FUNCTION is
'The name of the default function used to add a column'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.USER_FUNCTION_NAME is
'The name of the user-defined transformation function to run '
/
comment on column DBA_STREAMS_TRANSFORMATIONS.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.DML_CONDITION is
'Row subsetting condition'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.DECLARATIVE_TYPE is
'The type of declarative transformation to run'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_TRANSFORMATIONS
  for DBA_STREAMS_TRANSFORMATIONS
/
grant select on DBA_STREAMS_TRANSFORMATIONS to select_catalog_role
/

----------------------------------------------------------------------------
-- ALL_STREAMS_TRANSFORMATIONS
----------------------------------------------------------------------------
create or replace view ALL_STREAMS_TRANSFORMATIONS as
select st.*
from  DBA_STREAMS_TRANSFORMATIONS st, ALL_APPLY aa, ALL_CAPTURE ca
  where (aa.apply_user = st.rule_owner) or (ca.capture_user = st.rule_owner)
/

comment on table ALL_STREAMS_TRANSFORMATIONS is
'Transformations defined on rules for the user'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.TRANSFORM_TYPE is
'The type of transformation'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.FROM_TABLE_NAME is
'The table to be renamed'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.TO_TABLE_NAME is
'The new table name'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.TABLE_NAME is
'The table of the column to be modified'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.FROM_COLUMN_NAME is
'The column to rename'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.TO_COLUMN_NAME is
'The new column name'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.COLUMN_NAME is
'The column to add or delete'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.COLUMN_VALUE is
'The value of the column to add'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.COLUMN_TYPE is
'The type of the new column'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.COLUMN_FUNCTION is
'The name of the default function used to add a column'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.USER_FUNCTION_NAME is
'The name of the user-defined transformation function to run '
/
comment on column ALL_STREAMS_TRANSFORMATIONS.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.DML_CONDITION is
'Row subsetting condition'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.DECLARATIVE_TYPE is
'The type of declarative transformation to run'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column ALL_STREAMS_TRANSFORMATIONS.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym ALL_STREAMS_TRANSFORMATIONS
  for ALL_STREAMS_TRANSFORMATIONS
/
grant select on ALL_STREAMS_TRANSFORMATIONS to select_catalog_role
/

-- Rename Schema
create or replace view DBA_STREAMS_RENAME_SCHEMA
  (RULE_OWNER, RULE_NAME, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, from_schema_name, to_schema_name,
  precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME SCHEMA';
/

comment on table DBA_STREAMS_RENAME_SCHEMA is
'Rename schema transformations'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_SCHEMA
  for DBA_STREAMS_RENAME_SCHEMA
/
grant select on DBA_STREAMS_RENAME_SCHEMA to select_catalog_role
/

-- Rename table
create or replace view DBA_STREAMS_RENAME_TABLE
  (RULE_OWNER, RULE_NAME, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   FROM_TABLE_NAME, TO_TABLE_NAME, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, from_schema_name, to_schema_name,
       from_table_name, to_table_name, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME TABLE';
/

comment on table DBA_STREAMS_RENAME_TABLE is
'Rename table transformations'
/
comment on column DBA_STREAMS_RENAME_TABLE.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_TABLE.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_TABLE.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_RENAME_TABLE.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_RENAME_TABLE.FROM_TABLE_NAME is
'The table to be renamed'
/
comment on column DBA_STREAMS_RENAME_TABLE.TO_TABLE_NAME is
'The new table name'
/
comment on column DBA_STREAMS_RENAME_TABLE.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_TABLE.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_TABLE
  for DBA_STREAMS_RENAME_TABLE
/
grant select on DBA_STREAMS_RENAME_TABLE to select_catalog_role
/


-- Delete column
create or replace view DBA_STREAMS_DELETE_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME,
   VALUE_TYPE, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, schema_name, table_name, column_name,
       value_type, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'DELETE COLUMN';
/

comment on table DBA_STREAMS_DELETE_COLUMN is
'Delete column transformations'
/
comment on column DBA_STREAMS_DELETE_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_DELETE_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_DELETE_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_DELETE_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_DELETE_COLUMN.COLUMN_NAME is
'The column to delete'
/
comment on column DBA_STREAMS_DELETE_COLUMN.VALUE_TYPE is
'Whether to delete the old column value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_DELETE_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_DELETE_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_DELETE_COLUMN
  for DBA_STREAMS_DELETE_COLUMN
/
grant select on DBA_STREAMS_DELETE_COLUMN to select_catalog_role
/

-- Keep columns
create or replace view DBA_STREAMS_KEEP_COLUMNS
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME,
   VALUE_TYPE, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, schema_name, table_name, column_name,
       value_type, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'KEEP COLUMNS'
/

comment on table DBA_STREAMS_KEEP_COLUMNS is
'Keep columns transformations'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.SCHEMA_NAME is
'The schema of the column to be kept'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.TABLE_NAME is
'The table of the column to be kept'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.COLUMN_NAME is
'The column to keep'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.VALUE_TYPE is
'Whether to keep the old column value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_KEEP_COLUMNS.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_KEEP_COLUMNS
  for DBA_STREAMS_KEEP_COLUMNS
/
grant select on DBA_STREAMS_KEEP_COLUMNS to select_catalog_role
/

-- Keep columns for the user
create or replace view ALL_STREAMS_KEEP_COLUMNS as
select skc.* 
  from DBA_STREAMS_KEEP_COLUMNS skc, ALL_APPLY aa, ALL_CAPTURE ca
  where (aa.apply_user = skc.rule_owner) or (ca.capture_user = skc.rule_owner)
/

comment on table ALL_STREAMS_KEEP_COLUMNS is
'Keep columns transformations for the user'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.SCHEMA_NAME is
'The schema of the column to be kept'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.TABLE_NAME is
'The table of the column to be kept'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.COLUMN_NAME is
'The column to keep'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.VALUE_TYPE is
'Whether to keep the old column value of the lcr, the new value, or both'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column ALL_STREAMS_KEEP_COLUMNS.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym ALL_STREAMS_KEEP_COLUMNS
  for ALL_STREAMS_KEEP_COLUMNS
/
grant select on ALL_STREAMS_KEEP_COLUMNS to select_catalog_role
/

-- Rename column
create or replace view DBA_STREAMS_RENAME_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, FROM_COLUMN_NAME,
   TO_COLUMN_NAME, VALUE_TYPE, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, schema_name, table_name, from_column_name,
       to_column_name, value_type, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME COLUMN';
/

comment on table DBA_STREAMS_RENAME_COLUMN is
'Rename column transformations'
/
comment on column DBA_STREAMS_RENAME_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_RENAME_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_RENAME_COLUMN.FROM_COLUMN_NAME is
'The column to rename'
/
comment on column DBA_STREAMS_RENAME_COLUMN.TO_COLUMN_NAME is
'The new column name'
/
comment on column DBA_STREAMS_RENAME_COLUMN.VALUE_TYPE is
'Whether to rename to the old column value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_RENAME_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_COLUMN
  for DBA_STREAMS_RENAME_COLUMN
/
grant select on DBA_STREAMS_RENAME_COLUMN to select_catalog_role
/

-- Add column
create or replace view DBA_STREAMS_ADD_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME,
   COLUMN_VALUE, COLUMN_TYPE, COLUMN_FUNCTION, VALUE_TYPE, PRECEDENCE,
   STEP_NUMBER) 
as
select rule_owner, rule_name, schema_name, table_name, column_name,
       column_value, sys.anydata.gettypename(column_value), column_function, 
       value_type, precedence, step_number 
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'ADD COLUMN';
/

comment on table DBA_STREAMS_ADD_COLUMN is
'Add column transformations'
/
comment on column DBA_STREAMS_ADD_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_ADD_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_ADD_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_ADD_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_NAME is
'The column to add'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_VALUE is
'The value of the column to add'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_TYPE is
'The type of the new column'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_FUNCTION is
'The name of the default function used to add a column'
/
comment on column DBA_STREAMS_ADD_COLUMN.VALUE_TYPE is
'Whether to add to the old value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_ADD_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_ADD_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_ADD_COLUMN
  for DBA_STREAMS_ADD_COLUMN
/
grant select on DBA_STREAMS_ADD_COLUMN to select_catalog_role
/
----------------------------------------------------------------------------

/* support drop user cascade */
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_STREAMS_ADM_UTL' 
  AND proc='PROCESS_DROP_USER_CASCADE' AND operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS', 'DBMS_STREAMS_ADM_UTL', 'PROCESS_DROP_USER_CASCADE', 1, 1,
          'Drop any capture or apply processes for this user')
/
commit;
                            
/* name-value types to be stored in an anydata object in the user properties
 * column of the queue table.  We would have stored the value as type AnyData, 
 * but wrapping a AnyData inside of a AnyData is prohibited. */
CREATE OR REPLACE TYPE sys.streams$nv_node 
TIMESTAMP '1997-04-12:12:59:00' OID 'BE329A8842822386E0340003BA0FD53F'
AS OBJECT
( nvn_name       varchar2(32),
  nvn_value_vc2  varchar2(4000),
  nvn_value_raw  raw(32),
  nvn_value_num  number,
  nvn_value_date date)
/

CREATE OR REPLACE TYPE sys.streams$nv_array 
TIMESTAMP '1997-04-12:12:59:00' OID 'BE329A88428A2386E0340003BA0FD53F'
AS VARRAY(1024) of sys.streams$nv_node
/

/* Types used in internal lcr transformation */
CREATE OR REPLACE TYPE sys.streams$transformation_info
TIMESTAMP '1997-04-12:12:59:00' OID 'D307723624873404E0340003BA0FD53F'
AS OBJECT
( transform_type     number, 
  operation          number,
  from_schema_name   varchar2(30),  
  to_schema_name     varchar2(30),
  from_table_name    varchar2(30),
  to_table_name      varchar2(30),
  schema_name        varchar2(30),  
  table_name         varchar2(30),
  value_type         number,
  from_column_name   varchar2(4000),
  to_column_name     varchar2(4000),
  column_name        varchar2(4000),
  column_value_vc2   varchar2(4000),
  column_value_raw   raw(4000),
  column_value_num   number,
  column_value_date  date,
  column_value_nvc2  nvarchar2(2000),
  column_value_bflt  binary_float,
  column_value_bdbl  binary_double,
  column_value_ts    timestamp,
  column_value_tz    timestamp with time zone,
  column_value_ltz   timestamp with local time zone, 
  column_value_iym   interval year to month,
  column_value_ids   interval day to second,
  column_value_char  char(2000),
  column_value_nchar nchar(1000),
  column_value_urid  varchar2(4000),
  column_type        number,
  column_function    varchar2(4000),
  step_number        number)
/

CREATE OR REPLACE TYPE sys.streams$_anydata_array
 AS VARRAY(2147483647) of sys.anydata
/

grant execute on sys.streams$_anydata_array to PUBLIC
/
