Rem
Rem $Header: rdbms/admin/dbmsapp.sql /st_rdbms_11.2.0/2 2011/04/08 10:46:51 elu Exp $
Rem
Rem dbmsapp.sql
Rem
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsapp.sql - streams APPly 
Rem
Rem    DESCRIPTION
Rem      This package contains APIs for Streams apply administration
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huntran     01/06/11 - incompatible_params error
Rem    rihuang     01/22/10 - remove set_dml_conflict_handler
Rem    haxu        10/26/09 - add set_dml_conflict_handler
Rem    elu         10/12/09 - add export error
Rem    jinwu       12/29/08 - add add/remove_stmt_handler
Rem    legao       07/11/08 - change assemble_lobs = TRUE as default
Rem    praghuna    12/07/07 - set_parameter prototype change
Rem    dcassine    05/05/04 - added set_value_dependency
Rem    dcassine    05/05/04 - added create/drop object_dependency
Rem    liwong      06/10/04 - Add user_procedure 
Rem    lkaplan     02/24/04 - generic lob assembly 
Rem    sbalaram    08/15/03 - add comments for compare_old_values
Rem    alakshmi    07/11/03 - facilitate apply name generation
Rem    sbalaram    05/23/03 - add compare_old_values
Rem    htran       11/04/02 - change drop_unused_rule_set param to
Rem                           drop_unused_rule_sets
Rem    htran       10/21/02 - name locking failure error
Rem    htran       11/18/02 - procedure name length error for downgrade
Rem    htran       10/07/02 - create get_error_message with new out parameters
Rem    apadmana    10/02/02 - Add recursive to set_schema_instantiation_scn()
Rem    htran       09/17/02 - add drop_unused_rule_set parameter to drop_apply
Rem                           name drop_unused_rule_set_error exception
Rem    elu         08/20/02 - add negative rule sets
Rem    htran       08/20/02 - dbms_apply_adm: set_enqueue_destination(),
Rem                           set_execute(), and invalidparamformat
Rem    dcassine    07/02/02 - Added precommit handler
Rem    apadmana    02/01/02 - Change apply_dblink to apply_database_link
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    rgmani      01/19/02 - Code review comments
Rem    rgmani      01/08/02 - Modify package description for dbms_apply_adm
Rem    jingliu     11/27/01 - set_{table, schema, global}_instantiation_scn
Rem    wesmith     11/15/01 - make dbms_apply_adm invoker's rights pkg
Rem    sbalaram    11/21/01 - Add pragmas for exceptions
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    jingliu     11/06/01 - remove add{alter}_object_error_notifier
Rem    sbalaram    11/04/01 - Removed error_* - error handler constants
Rem    sbalaram    11/01/01 - Change parameter name for create_apply
Rem    lkaplan     10/29/01 -  API - dml hdlr, lcr.execute, set key options
Rem    wesmith     10/25/01 - new parameters for create_apply, alter_apply
Rem    wesmith     10/23/01 - Created
Rem

--
-- External package for apply administration
--
CREATE OR REPLACE PACKAGE dbms_apply_adm AUTHID CURRENT_USER AS

  invalidparam EXCEPTION;
    PRAGMA exception_init(invalidparam, -23605);
    invalidparam_num NUMBER := -23605;

  invalidobj EXCEPTION;
    PRAGMA exception_init(invalidobj, -23606);
    invalidobj_num NUMBER := -23606;

  invalidcol EXCEPTION;
    PRAGMA exception_init(invalidcol, -23607);
    invalidcol_num NUMBER := -23607;

  invalidrescol EXCEPTION;
    PRAGMA exception_init(invalidrescol, -23608);
    invalidrescol_num NUMBER := -23608;
  
  export_errq_error EXCEPTION;
    PRAGMA exception_init(export_errq_error, -25343);
    export_errq_num NUMBER := -25343;
  
  invalidparamformat EXCEPTION;
    PRAGMA exception_init(invalidparamformat, -26692);
    invalidparamformat_num NUMBER := -26692;

  drop_unused_rule_set_error EXCEPTION;
    PRAGMA exception_init(drop_unused_rule_set_error, -26693);
    drop_unused_rule_set_error_num NUMBER := -26693;

  lock_error EXCEPTION;
    PRAGMA exception_init(lock_error, -26695);
    lock_error_num NUMBER := -26695;
 
  incompatible_params EXCEPTION;
    PRAGMA exception_init(incompatible_params, -26669);
    incompatible_params_num NUMBER := -26669;

  conflict_handler_not_found EXCEPTION;
    PRAGMA exception_init(conflict_handler_not_found, -23665);
    conflict_handler_not_found_num NUMBER := -23665;

  default_col_group_exists EXCEPTION;
    PRAGMA exception_init(default_col_group_exists, -23666);
    default_col_group_exists_num NUMBER := -23666;

  col_used_by_conf_handler EXCEPTION;
    PRAGMA exception_init(col_used_by_conf_handler, -23667);
    col_used_by_conf_handler_num NUMBER := -23667;

  delta_col_non_numeric EXCEPTION;
    PRAGMA exception_init(delta_col_non_numeric, -23668);
    delta_col_non_numeric_num NUMBER := -23668;

  conflict_handler_found EXCEPTION;
    PRAGMA exception_init(conflict_handler_found, -23669);
    conflict_handler_found_num NUMBER := -23669;

  duplicates_in_column_list EXCEPTION;
    PRAGMA exception_init(duplicates_in_column_list, -23670);
    duplicates_in_column_list_num NUMBER := -23670;

  def_col_group_required EXCEPTION;
    PRAGMA exception_init(def_col_group_required, -23671);
    def_col_group_required_num NUMBER := -23671;

  incompat_dml_conf_params EXCEPTION;
    PRAGMA exception_init(incompat_dml_conf_params, -23675);
    incompat_dml_conf_params_num NUMBER := -23675;

  -- prototype procedure for starting an apply process
  PROCEDURE start_apply(apply_name IN VARCHAR2);

  -- prototype procedure for stopping an apply process
  PROCEDURE stop_apply(apply_name IN VARCHAR2,
                       force      IN BOOLEAN DEFAULT FALSE);

  -- procedure for setting apply process parameters
  -- value=NULL will set the parameter to its default value.
  PROCEDURE set_parameter(apply_name IN VARCHAR2,
                          parameter  IN VARCHAR2,
                          value      IN VARCHAR2 DEFAULT NULL);

  -- records the set of columns to be used as the "primary key"
  -- for an apply engine.
  -- If apply_name is NULL, this key will be used for all the
  -- apply engines, which are interested in LCRs for object_name.
  -- This includes apply engines for applying LCRs to non-Oracle
  -- store.
  -- The existence of object_name can not be verified since
  -- an apply engine for a non Oracle store may not have object_name
  -- locally.
  PROCEDURE set_key_columns(object_name           IN VARCHAR2, 
                            column_list           IN VARCHAR2,
                            apply_database_link   IN VARCHAR2 := NULL);
  -- column_list is a comma-separated list of columns, with no space
  -- between columns.

  PROCEDURE set_key_columns(object_name           IN VARCHAR2, 
                            column_table          IN dbms_utility.name_array,
                            apply_database_link   IN VARCHAR2 := NULL);
  -- Index for column_table is is 1-based, increasing, dense, and
  -- terminated by a NULL.

  -- sets the dml handler for a specified object
  PROCEDURE set_dml_handler(object_name IN VARCHAR2,
                            object_type IN VARCHAR2,
                            operation_name     IN VARCHAR2,
                            error_handler      IN BOOLEAN:= FALSE,
                            user_procedure     IN VARCHAR2,
                            apply_database_link   IN VARCHAR2 DEFAULT NULL,
                            apply_name            IN VARCHAR2 DEFAULT NULL,
                            assemble_lobs      IN BOOLEAN:= TRUE);

  FUNCTION get_error_message(
    message_number          IN NUMBER,
    local_transaction_id    IN VARCHAR2) RETURN sys.anydata;
  -- Returns the logical change record from the error queue for the
  -- specified message number and deferred transaction id.
  -- message_id is the position of the message (logical change record)
  -- within the transaction.
  -- local_transaction_id is the id number of the error transaction.

  FUNCTION get_error_message(
    message_number          IN NUMBER,
    local_transaction_id    IN VARCHAR2,
    destination_queue_name  OUT VARCHAR2,
    execute                 OUT BOOLEAN) RETURN sys.anydata;
  -- Returns the logical change record from the error queue for the
  -- specified message number and deferred transaction id.
  -- If the logical change record has an enqueue destination then
  -- that value is returned in destination_queue_name.
  -- The out variable execute indicates whether the logical change record
  -- should be executed.
  -- message_id is the position of the message (logical change record)
  -- within the transaction.
  -- local_transaction_id is the id number of the error transaction.

  PROCEDURE delete_error(local_transaction_id IN VARCHAR2);
  -- Deletes the specified transaction from the error queue.
  -- local_transaction_id is the id number of the deferred transaction to
  -- delete. 

  PROCEDURE delete_all_errors(apply_name  IN VARCHAR2 DEFAULT NULL);
  -- Deletes all the error transactions for the given apply engine from the
  -- error queue.
  -- apply_name is the apply engine which raised the error. 
  -- If apply_name is NULL, the all error transactions, for all apply engines,
  -- will be deleted.

  PROCEDURE execute_error(
    local_transaction_id     IN VARCHAR2, 
    execute_as_user          IN BOOLEAN DEFAULT FALSE,
    user_procedure           IN VARCHAR2 DEFAULT NULL);
  -- Re-executes the specified transaction in the error queue.
  -- local_transaction_id is the id number of the deferred transaction to
  -- re-execute. 
  -- If execute_as_user is TRUE, then the transaction is re-executed in
  -- the security context of the connected user.

  PROCEDURE execute_all_errors(
    apply_name      IN VARCHAR2 DEFAULT NULL,
    execute_as_user IN BOOLEAN DEFAULT FALSE);
  -- Re-executes the error queue transactions for the specified apply
  -- engine.
  -- apply_name is the apply engine which raised the error.
  -- If apply_name is NULL, then then all error transactions, for all apply
  -- engines, will be re-executed.
  -- If execute_as_user is TRUE, then the transactions are re-executed in
  -- the security context of the connected user.

  PROCEDURE set_update_conflict_handler(
    object_name       IN VARCHAR2,
    method_name       IN VARCHAR2,
    resolution_column IN VARCHAR2,
    column_list       IN dbms_utility.name_array,
    apply_database_link      IN VARCHAR2 DEFAULT NULL);
  -- Adds a conflict handler to resolve update conflicts
  -- object_name - the schema and name of the table, specified as
  --   schema_name.object_name, for which the update conflict handler is being
  --   added. The schema will default to the current user if one isn't
  --   specified.
  -- method_name - type of update conflict handler to create/invoke. Users can
  --   specify one of the built-in methouds (MINIMUM, MAXIMUM, OVERWRITE,
  --   DISCARD), or USER FUNCTION for a user-defined method.
  -- resolution_column - name of the column used to resolve the conflict
  -- column_list - list of columns whose values will be updated in case
  --   of a conflict.

  PROCEDURE create_apply(
    queue_name             IN VARCHAR2,
    apply_name             IN VARCHAR2,
    rule_set_name          IN VARCHAR2 DEFAULT NULL,
    message_handler        IN VARCHAR2 DEFAULT NULL,
    ddl_handler            IN VARCHAR2 DEFAULT NULL,
    apply_user             IN VARCHAR2 DEFAULT NULL,
    apply_database_link    IN VARCHAR2 DEFAULT NULL,
    apply_tag              IN RAW      DEFAULT '00',
    apply_captured         IN BOOLEAN  DEFAULT FALSE,
    precommit_handler      IN VARCHAR2 DEFAULT NULL,
    negative_rule_set_name IN VARCHAR2 DEFAULT NULL,
    source_database        IN VARCHAR2 DEFAULT NULL);

  PROCEDURE alter_apply(
    apply_name               IN VARCHAR2,
    rule_set_name            IN VARCHAR2 DEFAULT NULL,
    remove_rule_set          IN BOOLEAN  DEFAULT FALSE,
    message_handler          IN VARCHAR2 DEFAULT NULL,
    remove_message_handler   IN BOOLEAN  DEFAULT FALSE,
    ddl_handler              IN VARCHAR2 DEFAULT NULL,
    remove_ddl_handler       IN BOOLEAN  DEFAULT FALSE,
    apply_user               IN VARCHAR2 DEFAULT NULL,
    apply_tag                IN RAW      DEFAULT NULL,
    remove_apply_tag         IN BOOLEAN  DEFAULT FALSE,
    precommit_handler        IN VARCHAR2 DEFAULT NULL,
    remove_precommit_handler IN BOOLEAN  DEFAULT FALSE,
    negative_rule_set_name   IN VARCHAR2 DEFAULT NULL,
    remove_negative_rule_set IN BOOLEAN  DEFAULT FALSE);

  PROCEDURE drop_apply(apply_name IN VARCHAR2,
                       drop_unused_rule_sets IN BOOLEAN DEFAULT FALSE);

  -- Records the specified instantiation SCN for the table given by the 
  -- source_object_name parameter from the source_database_name database
  -- if instantiation_scn is not NULL. Remove the instantiation SCN
  -- if instantiation_scn is NULL.

  PROCEDURE set_table_instantiation_scn(source_object_name   IN VARCHAR2, 
                                        source_database_name IN VARCHAR2, 
                                        instantiation_scn    IN NUMBER,
                                        apply_database_link IN VARCHAR2 DEFAULT NULL);

  -- Records the specified instantiation SCN for the schema 
  -- from the source_database_name database if instantiation_scn is not NULL.
  -- Remove the instantiation SCN if instantiation_scn is NULL.
  -- If recursive = true then for all tables in this schema at the source db
  -- set the scn.
  PROCEDURE set_schema_instantiation_scn(source_schema_name   IN VARCHAR2,
                                         source_database_name IN VARCHAR2,
                                         instantiation_scn    IN NUMBER,
                                         apply_database_link IN VARCHAR2 DEFAULT NULL,
                                         recursive IN BOOLEAN DEFAULT FALSE);

  -- Records the specified instantiation SCN for the source_database_name
  -- database if instantiation_scn is not NULL
  -- Remove the instantiation SCN if instantiation_scn is NULL
  -- If recursive = true then for all tables and schemas at the source db
  -- set the scn.
  PROCEDURE set_global_instantiation_scn(source_database_name IN VARCHAR2,
                                         instantiation_scn    IN NUMBER,
                                         apply_database_link IN VARCHAR2 DEFAULT NULL,
                                         recursive IN BOOLEAN DEFAULT FALSE);

  -- Sets destination_queue_name as the queue where events satisfying the 
  -- rule specified by rule_name will be enqueued.  If destination_queue_name
  -- is NULL then any existing queue name for the rule will be removed from
  -- the rule's action context.
  PROCEDURE set_enqueue_destination(rule_name IN VARCHAR2,
                                    destination_queue_name IN VARCHAR2);

  -- Sets APPLY$_EXECUTE in the rule's action context to 'NO' when 
  -- execute = false.  Remove the variable if execute = true.
  PROCEDURE set_execute(rule_name IN VARCHAR2, execute IN BOOLEAN);

  PROCEDURE compare_old_values (
    object_name         IN VARCHAR2,
    column_list         IN VARCHAR2,
    operation           IN VARCHAR2 DEFAULT 'UPDATE',
    compare             IN BOOLEAN  DEFAULT TRUE,
    apply_database_link IN VARCHAR2 DEFAULT NULL);
  -- Indicates whether or not to compare old column with the current column
  -- values for deletes or updates when they are sent.
  -- object_name - the schema and name of the table, specified as
  --   schema_name.object_name, for which the columns are being specified.
  --   The schema will default to the current user if one isn't specified.
  -- column_list - comma seperated list of columns. If '*' is specified, then
  --   it includes all non-key columns.
  -- operation - 'DELETE' or 'UPDATE'. '*' implies both 'DELETE' and 'UPDATE'
  -- compare - TRUE -> old values are compared
  --           FALSE -> old values are not compared
  -- apply_database_link - if remote apply, then name of database link
  --   pointing to the remote database

  PROCEDURE compare_old_values (
    object_name         IN VARCHAR2,
    column_table        IN DBMS_UTILITY.LNAME_ARRAY,
    operation           IN VARCHAR2 DEFAULT 'UPDATE',
    compare             IN BOOLEAN  DEFAULT TRUE,
    apply_database_link IN VARCHAR2 DEFAULT NULL);
  -- Indicates whether or not to compare old column with the current column
  -- values for deletes or updates when they are sent.
  -- object_name - the schema and name of the table, specified as
  --   schema_name.object_name, for which the columns are being specified.
  --   The schema will default to the current user if one isn't specified.
  -- column_table - PL/SQL table of columns. The table must be dense and
  --   need not be null terminatd.
  -- operation - 'DELETE' or 'UPDATE'. '*' implies both 'DELETE' and 'UPDATE'
  -- compare - TRUE -> old values are compared
  --           FALSE -> old values are not compared
  -- apply_database_link - if remote apply, then name of database link
  --   pointing to the remote database

  PROCEDURE set_value_dependency (
    dependency_name     IN VARCHAR2,
    object_name         IN VARCHAR2,
    attribute_table     IN dbms_utility.name_array);

  --  Adds a set of columns to a virtual constraint.
  --  If the constraint_name is null, an error is raised.
  --  If the constraint_name is unknown, a new virtual constraint is created.
  --  If the constraint_name already contains columns for object_name,
  --  the existing column list will be replaced. If the new column list is
  --  empty, the constraint_name for this object will be deleted.
  --  If object_name is null, all the information about this constraint
  --  will be removed. The column_table parameter is ignored.
  --
  --  Default_values allows the user to define a default value for each
  --  column of the column list. The default value is used for dependency
  --  computation if the column value is not available in the LCR.
  --  
  --  Ignore_values allows the user to define a column ignore value. When
  --  the ignore values are set, and they match the value of the key in
  --  a given LCR, dependencies for the column of the current LCR are
  --  not computed.
  --  
  --  All PL/SQL table is 1-based
  --  An error will be raised if the count of the values (default/ignore)
  --  do not match with the column list.

  PROCEDURE set_value_dependency (
    dependency_name     IN VARCHAR2,
    object_name         IN VARCHAR2,
    attribute_list      IN VARCHAR2);
  --  Same as above except the attribute list is coma separated

  PROCEDURE create_object_dependency (
    object_name         IN VARCHAR2,
    parent_object_name  IN VARCHAR2);
  --   Allows users to define object level dependencies. All transactions
  --   that operate on the (child) object depend on the last transaction that
  --   operated on the parent object.
  --   This procedure does not check if the user defined, Object Ladder is 
  --   circular.

  PROCEDURE drop_object_dependency (
    object_name         IN VARCHAR2,
    parent_object_name  IN VARCHAR2);
  --  This procedure allows the Stream application developer to drop defined 
  --  parent child relationships between destination objects.

  
  PROCEDURE add_stmt_handler(
    object_name         IN VARCHAR2,
    operation_name      IN VARCHAR2,
    handler_name        IN VARCHAR2,
    statement           IN CLOB,
    apply_name          IN VARCHAR2 DEFAULT NULL,
    comment             IN VARCHAR2 DEFAULT NULL);
  -- Create a stmt handler with a user-specified statement and add it to apply.

  PROCEDURE add_stmt_handler(
    object_name         IN VARCHAR2,
    operation_name      IN VARCHAR2,
    handler_name        IN VARCHAR2,
    apply_name          IN VARCHAR2 DEFAULT NULL);
  -- Adds a lcr-processing stmt handler to apply.
  
  PROCEDURE remove_stmt_handler(
    object_name         IN VARCHAR2,
    operation_name      IN VARCHAR2,
    handler_name        IN VARCHAR2,
    apply_name          IN VARCHAR2 DEFAULT NULL);
  -- Removes a lcr-processing stmt handler from apply.
    
  --
  -- This procedure sets a change handler for the specified apply and operation
  --
  -- Parameters:
  --
  -- change_table_name   : Name of change table
  -- source_table_name   : Name of source table
  -- capture_values      : 'OLD', 'NEW', or '*'(BOTH)
  -- apply_name          : Name of apply
  -- operation_name      : Name of DML operation
  -- change_handler_name : Nmae of change handler to set to the apply process.
  --                       If NULL, remove all change handlers from the
  --                       specified apply and operation.
  --
  PROCEDURE set_change_handler(
    change_table_name      VARCHAR2,
    source_table_name      VARCHAR2,
    capture_values         VARCHAR2,
    apply_name             VARCHAR2,
    operation_name         VARCHAR2,
    change_handler_name    VARCHAR2 DEFAULT NULL);

END dbms_apply_adm;
/
GRANT EXECUTE ON dbms_apply_adm TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_apply_adm FOR dbms_apply_adm
/
