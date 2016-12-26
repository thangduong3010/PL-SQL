Rem
Rem $Header: rdbms/admin/dbmsread.sql /main/21 2010/02/11 00:27:32 gagarg Exp $
Rem
Rem dbmsread.sql
Rem
Rem Copyright (c) 1998, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsread.sql - dbms Rules Engine ADmin
Rem
Rem    DESCRIPTION
Rem      creates the package specs for rules admin and rule
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY) 
Rem    rramkiss    02/04/10 - move sched type to SYS
Rem    gagarg      02/04/10 - Bug9145181: Add package DBMS_RULE_INTERNAL
Rem    sjanardh    03/19/09 - add i_evaluation_context_add_var
Rem    rburns      05/20/06 - more ruleadm_internal 
Rem    weiwang     02/03/04 - add alter_evaluation_context 
Rem    weiwang     05/12/03 - optionally create rule set IOT
Rem    weiwang     04/25/03 - move dbms_rules_lib creation to catrule
Rem    htran       09/04/02 - name some exceptions
Rem    skaluska    08/27/02 - iterative evaluate interface
Rem    weiwang     04/15/02 - add storage clause for ruleset IOTs
Rem    weiwang     12/19/01 - allow null condition in alter rule
Rem    weiwang     01/08/02 - remove user-defined table parameters
Rem    skaluska    10/30/01 - add EVALUATION_* codes.
Rem    weiwang     10/08/01 - add grant/revoke privilege functions
Rem    celsbern    10/21/01 - merging in 1018 changes.
Rem    celsbern    10/19/01 - merge LOG to MAIN
Rem    skaluska    10/11/01 - add event context.
Rem    weiwang     09/27/01 - change type of action context
Rem    weiwang     09/21/01 - add evaluation context to add rule
Rem    skaluska    09/10/01 - interface for evaluate.
Rem    weiwang     09/05/01 - maintain dbms_rule_eximp for backward 
Rem                           compatibility
Rem    skaluska    08/08/01 - generalize evaluate for multiple tables & vars.
Rem    weiwang     08/03/01 - change to 9iR2 API
Rem    weiwang     07/12/01 - enhance dbms_rule_adm API
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    weiwang     09/14/00 - add delete_data flag to drop_rule_set
Rem    nbhatt      06/23/98 - the representation in which hit rules are returne
Rem    ryaseen     06/22/98 - add rule export/import functions
Rem    esoyleme    05/26/98 - public synonym for dbms_rule
Rem    esoyleme    04/28/98 - fix security                                     
Rem    esoyleme    04/15/98 - move library creation
Rem    esoyleme    04/13/98 - add rules runtime package
Rem    nbhatt      04/03/98 - Rules Engine ADmin package
Rem    nbhatt      04/03/98 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_rule_adm AUTHID CURRENT_USER AS

  --------------------
  --  PUBLIC CONSTANT
  --
  -- privilege code for rule engine objects

  -- system privileges
  CREATE_EVALUATION_CONTEXT_OBJ     CONSTANT BINARY_INTEGER := 1;
  CREATE_ANY_EVALUATION_CONTEXT     CONSTANT BINARY_INTEGER := 2;
  ALTER_ANY_EVALUATION_CONTEXT      CONSTANT BINARY_INTEGER := 3;
  DROP_ANY_EVALUATION_CONTEXT       CONSTANT BINARY_INTEGER := 4;
  EXECUTE_ANY_EVALUATION_CONTEXT    CONSTANT BINARY_INTEGER := 5;

  CREATE_RULE_SET_OBJ               CONSTANT BINARY_INTEGER := 6;
  CREATE_ANY_RULE_SET               CONSTANT BINARY_INTEGER := 7;
  ALTER_ANY_RULE_SET                CONSTANT BINARY_INTEGER := 8;
  DROP_ANY_RULE_SET                 CONSTANT BINARY_INTEGER := 9;
  EXECUTE_ANY_RULE_SET              CONSTANT BINARY_INTEGER := 10;

  CREATE_RULE_OBJ                   CONSTANT BINARY_INTEGER := 11;
  CREATE_ANY_RULE                   CONSTANT BINARY_INTEGER := 12;
  ALTER_ANY_RULE                    CONSTANT BINARY_INTEGER := 13;
  DROP_ANY_RULE                     CONSTANT BINARY_INTEGER := 14;
  EXECUTE_ANY_RULE                  CONSTANT BINARY_INTEGER := 15;

  -- object privileges
  EXECUTE_ON_EVALUATION_CONTEXT     CONSTANT BINARY_INTEGER := 16;
  ALTER_ON_EVALUATION_CONTEXT       CONSTANT BINARY_INTEGER := 17;
  ALL_ON_EVALUATION_CONTEXT         CONSTANT BINARY_INTEGER := 18;

  EXECUTE_ON_RULE_SET               CONSTANT BINARY_INTEGER := 19;
  ALTER_ON_RULE_SET                 CONSTANT BINARY_INTEGER := 20;
  ALL_ON_RULE_SET                   CONSTANT BINARY_INTEGER := 21;

  EXECUTE_ON_RULE                   CONSTANT BINARY_INTEGER := 22;
  ALTER_ON_RULE                     CONSTANT BINARY_INTEGER := 23;
  ALL_ON_RULE                       CONSTANT BINARY_INTEGER := 24;

  -- return codes for evaluation_function associated with an evaluation
  -- context
  -- These codes are interpreted as follows:
  -- EVALUATION_SUCCESS: evaluation completed successfully
  -- EVALUATION_FAILURE: evaluation failed due to errors
  -- EVALUATION_CONTINUE: continue default evaluation of the rule set

  EVALUATION_SUCCESS                CONSTANT BINARY_INTEGER := 0;
  EVALUATION_FAILURE                CONSTANT BINARY_INTEGER := 1;
  EVALUATION_CONTINUE               CONSTANT BINARY_INTEGER := 2;

  -- named exceptions
  INVALID_NV_NAME EXCEPTION;
    PRAGMA exception_init(INVALID_NV_NAME, -24161);

  PROCEDURE create_evaluation_context(
                evaluation_context_name IN varchar2,
                table_aliases           IN sys.re$table_alias_list := NULL,
                variable_types          IN sys.re$variable_type_list := NULL,
                evaluation_function     IN varchar2 := NULL,
                evaluation_context_comment IN varchar2 := NULL);

  PROCEDURE alter_evaluation_context(
                evaluation_context_name IN varchar2,
                table_aliases           IN sys.re$table_alias_list := NULL,
                remove_table_aliases    IN boolean := FALSE,
                variable_types          IN sys.re$variable_type_list := NULL,
                remove_variable_types   IN boolean := FALSE,
                evaluation_function     IN varchar2 := NULL,
                remove_evaluation_function  IN boolean := FALSE,
                evaluation_context_comment  IN varchar2 := NULL,
                remove_eval_context_comment IN boolean := FALSE);
  
  PROCEDURE drop_evaluation_context(
                evaluation_context_name IN varchar2,
                force                   IN boolean := FALSE);

  PROCEDURE create_rule_set(
                rule_set_name           IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                rule_set_comment        IN varchar2 := NULL);

  PROCEDURE drop_rule_set(
                rule_set_name           IN varchar2,
                delete_rules            IN boolean := FALSE);

  PROCEDURE create_rule(
                rule_name               IN varchar2,
                condition               IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                action_context          IN sys.re$nv_list := NULL,
                rule_comment            IN varchar2 := NULL);

  PROCEDURE alter_rule(
                rule_name                 IN varchar2,
                condition                 IN varchar2 := NULL,
                evaluation_context        IN varchar2 := NULL,
                remove_evaluation_context IN boolean := FALSE,
                action_context            IN sys.re$nv_list := NULL,
                remove_action_context     IN boolean := FALSE,
                rule_comment              IN varchar2 := NULL,
                remove_rule_comment       IN boolean := FALSE);

  PROCEDURE drop_rule(
                rule_name               IN varchar2,
                force                   IN boolean := FALSE);

  PROCEDURE add_rule(
                rule_name               IN varchar2,
                rule_set_name           IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                rule_comment            IN varchar2 := NULL);

  PROCEDURE remove_rule(
                rule_name               IN varchar2, 
                rule_set_name           IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                all_evaluation_contexts IN boolean  := FALSE);

  PROCEDURE grant_system_privilege(
                privilege               IN binary_integer,
                grantee                 IN varchar2,
                grant_option            IN boolean := FALSE);

  PROCEDURE revoke_system_privilege(
                privilege               IN binary_integer,
                revokee                 IN varchar2);

  PROCEDURE grant_object_privilege(
                privilege               IN binary_integer,
                object_name             IN varchar2,
                grantee                 IN varchar2,
                grant_option            IN boolean := FALSE);

  PROCEDURE revoke_object_privilege(
                privilege               IN binary_integer,
                object_name             IN varchar2,
                revokee                 IN varchar2);

END dbms_rule_adm;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_rule_adm FOR sys.dbms_rule_adm
/
--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_rule_adm TO public
/

CREATE OR REPLACE PACKAGE dbms_rule_eximp AS

  PROCEDURE import_rule_set(  
                rs_schema          IN    varchar2,    
                rs_name            IN    varchar2,  
                basetab_schema     IN    varchar2,    
                basetab_name       IN    varchar2,
                rulestab_schema    IN    varchar2,
                rulestab_name      IN    varchar2);

  PROCEDURE import_rule(
                rs_schema          IN    varchar2,
                rs_name            IN    varchar2,    
                rule_name          IN    varchar2,    
                cond               IN    varchar2);
 
END dbms_rule_eximp;
/
--
-- Grants for dbms_rule_eximp
--
GRANT EXECUTE ON sys.dbms_rule_eximp TO SYSTEM WITH GRANT OPTION
/
GRANT EXECUTE ON sys.dbms_rule_eximp TO imp_full_database
/
GRANT EXECUTE ON sys.dbms_rule_eximp TO exp_full_database
/
GRANT EXECUTE ON sys.dbms_rule_eximp TO execute_catalog_role
/


CREATE OR REPLACE PACKAGE dbms_rule AUTHID CURRENT_USER AS

  PROCEDURE evaluate(
        rule_set_name           IN      varchar2,
        evaluation_context      IN      varchar2,
        event_context           IN      sys.re$nv_list := NULL,
        table_values            IN      sys.re$table_value_list := NULL,
        column_values           IN      sys.re$column_value_list := NULL,
        variable_values         IN      sys.re$variable_value_list := NULL,
        attribute_values        IN      sys.re$attribute_value_list := NULL,
        stop_on_first_hit       IN      boolean := FALSE,
        simple_rules_only       IN      boolean := FALSE,
        true_rules              OUT     sys.re$rule_hit_list,
        maybe_rules             OUT     sys.re$rule_hit_list);

  PROCEDURE evaluate(
        rule_set_name           IN      varchar2,
        evaluation_context      IN      varchar2,
        event_context           IN      sys.re$nv_list := NULL,
        table_values            IN      sys.re$table_value_list := NULL,
        column_values           IN      sys.re$column_value_list := NULL,
        variable_values         IN      sys.re$variable_value_list := NULL,
        attribute_values        IN      sys.re$attribute_value_list := NULL,
        simple_rules_only       IN      boolean := FALSE,
        true_rules_iterator     OUT     binary_integer,
        maybe_rules_iterator    OUT     binary_integer);

  FUNCTION get_next_hit(
        iterator                IN      binary_integer)
  RETURN sys.re$rule_hit;

  PROCEDURE close_iterator(
        iterator                IN      binary_integer);

END dbms_rule;
/
GRANT EXECUTE ON sys.dbms_rule TO public
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_rule FOR sys.dbms_rule
/

CREATE OR REPLACE PACKAGE dbms_ruleadm_internal AUTHID CURRENT_USER AS
  
  -----------------
  -- constants
 
  KGLNRULS  CONSTANT BINARY_INTEGER := 23;
  KGLNRULE  CONSTANT BINARY_INTEGER := 36;
  KGLNREVC  CONSTANT BINARY_INTEGER := 38;

  PROCEDURE i_create_eval_ctx(
                evaluation_context_name IN varchar2,
                table_aliases           IN sys.re$table_alias_list := NULL,
                variable_types          IN sys.re$variable_type_list := NULL,
                evaluation_function     IN varchar2 := NULL,
                evaluation_context_comment IN varchar2 := NULL,
                eval_ctx_properties     IN number := NULL);

  PROCEDURE i_create_rule_set(
		rule_set_name		IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                rule_set_comment        IN varchar2 := NULL,
                rule_set_properties     IN number := NULL);

  PROCEDURE i_create_rule(
		rule_name		IN varchar2,
		condition		IN varchar2,
                evaluation_context      IN varchar2 := NULL,
                action_context          IN sys.re$nv_list := NULL,
                rule_comment            IN varchar2 := NULL,
                rule_properties         IN number := NULL,
                internal_actx_client    IN varchar2 := NULL,
                internal_action_context IN sys.re$nv_list := NULL);

  PROCEDURE i_alter_rule(
                rule_name                 IN varchar2,
                condition                 IN varchar2 := NULL,
                evaluation_context        IN varchar2 := NULL,
                remove_evaluation_context IN boolean := FALSE,
                action_context            IN sys.re$nv_list := NULL,
                remove_action_context     IN boolean := FALSE,
                rule_comment              IN varchar2 := NULL,
                remove_rule_comment       IN boolean := FALSE,
                internal_actx_client      IN varchar2 := NULL,
                internal_action_context   IN sys.re$nv_list := NULL,
                remove_int_actx           IN boolean := FALSE);

  PROCEDURE patch_rule_priv(
                btab_schema             IN varchar2,
                btab_name               IN varchar2,
                condition               IN varchar2);

  PROCEDURE validate_re_object(
                object_name             IN varchar2,
                object_namespace        IN binary_integer);
 
-- The export function signature should be
-- FUNCTION  <export_function> (
--           rschema                   IN  varchar2,
--           rname                     IN  varchar2,
--           new_block                 OUT PLS_INTEGER) RETURN VARCHAR2;

  PROCEDURE register_internal_actx(
                client_name             IN varchar2,
                export_function         IN varchar2 default NULL,
                client_comment          IN varchar2 default NULL);

  PROCEDURE unregister_internal_actx(
                client_name             IN varchar2);

  PROCEDURE i_evaluation_context_add_var(
                evaluation_context_name IN varchar2,
                variable_types          IN sys.re$variable_type_list default NULL
            );

END dbms_ruleadm_internal;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_ruleadm_internal for sys.dbms_ruleadm_internal
/
GRANT EXECUTE ON sys.dbms_ruleadm_internal to PUBLIC
/

CREATE OR REPLACE PACKAGE dbms_rule_internal AUTHID CURRENT_USER AS

  -- Internal constants used across packages should be defined here.
  -- Bug 8656192: Add macro KWRX_CHN_ANYDTA. 
  --              This should be in sync with C layer macro defined in kwrx.h

  KWRX_CHN_ANYDTA                CONSTANT PLS_INTEGER := 1;


  PROCEDURE i_evaluate(
        rule_set_name           IN      varchar2,
        evaluation_context      IN      varchar2,
        event_context           IN      sys.re$nv_list := NULL,
        table_values            IN      sys.re$table_value_list := NULL,
        column_values           IN      sys.re$column_value_list := NULL,
        variable_values         IN      sys.re$variable_value_list := NULL,
        attribute_values        IN      sys.re$attribute_value_list := NULL,
        stop_on_first_hit       IN      boolean := FALSE,
        simple_rules_only       IN      boolean := FALSE,
        variable_flag           IN      pls_integer,
        true_rules              OUT     sys.re$rule_hit_list,
        maybe_rules             OUT     sys.re$rule_hit_list);


      procedure i_evaluate(
        rule_set_name           IN      varchar2,
        evaluation_context      IN      varchar2,
        event_context           IN      sys.re$nv_list := NULL,
        table_values            IN      sys.re$table_value_list := NULL,
        column_values           IN      sys.re$column_value_list := NULL,
        variable_values         IN
                sys.scheduler$_var_value_list := NULL,
        attribute_values        IN      sys.re$attribute_value_list := NULL,
        stop_on_first_hit       IN      boolean := FALSE,
        simple_rules_only       IN      boolean := FALSE,
        variable_flag           IN      pls_integer,
        true_rules              OUT     sys.re$rule_hit_list,
        maybe_rules             OUT     sys.re$rule_hit_list);

END dbms_rule_internal;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_rule_internal for sys.dbms_rule_internal;


