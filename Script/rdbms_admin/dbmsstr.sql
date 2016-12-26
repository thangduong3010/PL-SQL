Rem
Rem $Header: rdbms/admin/dbmsstr.sql /main/63 2010/06/13 22:20:56 juyuan Exp $
Rem
Rem dbmsstr.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsstr.sql - DBMS STReams
Rem
Rem    DESCRIPTION
Rem      This package contains the higher level APIs for defining,
Rem      maintaining and deploying STREAMS
Rem
Rem    NOTES
Rem      Requires AQ packages to have been previously installed.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juyuan      06/01/10 - bug-9766238: revoke grant option for dbms_streams
Rem    juyuan      03/20/09 - add prvthsmc.plb
Rem    jinwu       02/25/09 - add prvthsha.plb
Rem    jinwu       02/25/09 - add prvthhdlr.plb
Rem    jinwu       02/25/09 - refactor stmt handler
Rem    juyuan      01/20/09 - change keep_columns to keep_change_columns_only
Rem    juyuan      12/22/08 - bug-7197975: revoke grant options for
Rem                           dbms_streams package
Rem    yurxu       12/22/08 - Bug 7631447: add compatible_11_2
Rem    juyuan      12/29/08 - matain_change_table
Rem    rihuang     08/18/08 - Add keep_columns to dbms_streams_adm package
Rem    jinwu       08/11/08 - add retention_time to dbms_streams_advisor_adm
Rem    rihuang     05/02/08 - Changed max_compatible from constant to function
Rem    rmao        04/07/08 - add prvthsai.plb
Rem    thoang      03/28/08 - Change max_compatible constant to 2147483647 
Rem    thoang      03/18/08 - define max_compatible constant 
Rem    juyuan      03/09/08 - change merge_streams_job API
Rem    jinwu       05/25/07 - add bottleneck_flowctrl_threshold
Rem    jinwu       05/25/07 - add bottleneck_idle_threshold
Rem    cschmidt    03/20/07 - add package header prvthscp 
Rem    juyuan      12/20/06 - change merge_streams_job api
Rem    thoang      11/20/06 - bug#5111881: remove prvthlua.plb 
Rem    jinwu       11/14/06 - move prvthsts prvthfgr prvthcmp to catpdeps.sql
Rem    jinwu       11/11/06 - ade package headers prvth% from catpstr
Rem    jinwu       11/10/06 - add dbmslcr
Rem    jinwu       11/03/06 - add dbmssts
Rem    jinwu       11/02/06 - add dbmsfgr and dbmscmp
Rem    jinwu       11/02/06 - add dbmsapp, dbmscap and dbmsprp
Rem    juyuan      10/18/06 - add parameters schedule_name, merge_job_name to
Rem                           split_streams
Rem    juyuan      10/18/06 - add compatible_11_1
Rem    jinwu       06/09/06 - rename component_wait_cursor
Rem    liwong      05/10/06 - sync capture cleanup
Rem    juyuan      03/29/06 - performance advisor API 
Rem    juyuan      12/15/05 - split/merge api support for streams 
Rem    elu         03/09/05 - add mult_trans_specified exception
Rem    alakshmi    03/07/05 - recover_operation
Rem    bpwang      03/08/05 - Multiple queues for bi-directional maintain_ 
Rem                           apis 
Rem    bpwang      10/21/04 - Bug 3949601: Pre/post instantiation setup 
Rem                           changes 
Rem    rvenkate    05/05/04 - add param to streams propagation apis 
Rem    nshodhan    06/01/04 - add compatible_10_2 
Rem    bpwang      04/06/04 - Generalize DB upgrade code 
Rem    alakshmi    02/13/04 - Add include_ddl to maintain_tablespaces 
Rem    alakshmi    09/11/03 - Database upgrade 
Rem    alakshmi    09/10/03 - maintain_global 
Rem    liwong      09/04/03 - Add maintain_tables and maintain_schemas 
Rem    bpwang      02/25/04 - Adding internal lcr transformation APIs 
Rem    sbalaram    04/06/04 - Move xml<->lcr conversion funcs to dbms_streams
Rem    bpwang      08/11/03 - Bug 3062214:  Add new exceptions
Rem    alakshmi    07/14/03 - change parameter defaults in maintain_tablespaces
Rem    htran       07/11/03 - change include_tagged_lcr default to FALSE
Rem    alakshmi    07/02/03 - remove parameter destination_platform in 
Rem                           maintain_tablespaces
Rem    alakshmi    04/18/03 - Rename dbms_streams_tablespaces to 
Rem                           dbms_streams_tablespace_adm
Rem    alakshmi    04/07/03 - add maintain_simple_tablespace
Rem    alakshmi    04/02/03 - add maintain_tablespaces
Rem    elu         05/19/03 - add get_scn_mapping
Rem    liwong      04/07/03 - Bug 2892010
Rem    bpwang      03/20/03 - bug 2870086:  add cascade parameter to 
Rem                           dbms_streams_adm.remove_queue
Rem    elu         02/18/03 - add process_exists exception
Rem    liwong      02/04/03 - Compatible support
Rem    htran       01/22/03 - name client_ruleset_not_exist exception
Rem    htran       01/15/03 - add grant/revoke_remote_admin_access
Rem    htran       01/13/03 - add dequeue_exists exception
Rem    sbalaram    01/09/03 - Bug 2741719 : Add messaging exceptions
Rem    liwong      12/20/02 - Fix enqueue, dequeue
Rem    apadmana    10/23/02 - remove_streams_configuration: remove parameters
Rem    liwong      10/17/02 - Enqueue and dequeue support
Rem    liwong      10/17/02 - set_notification
Rem    sbalaram    10/10/02 - streams aq integration
Rem    elu         10/02/02 - add row migration for propagation
Rem    bpwang      10/01/02 - Adding remove_queue procedure
Rem    apadmana    09/30/02 - Add package dbms_streams_auth
Rem    elu         09/28/02 - add negative rule sets for apply and propagation
Rem    apadmana    09/05/02 - code review comments
Rem    elu         08/20/02 - add negative rule sets
Rem    apadmana    08/07/02 - Add remove_streams_configuration()
Rem    liwong      07/12/02 - Add exceptions
Rem    elu         06/28/02 - add get_streams_name
Rem    elu         05/16/02 - add set_rule_transform_function
Rem    sbalaram    01/30/02 - add get_information
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    jingliu     01/16/02 - remove transactional_queue parameter 
Rem                           in set_up_queue
Rem    wesmith     11/19/01 - make dbms_streams_adm invoker's rights pkg
Rem    bnainani    11/20/01 - add anydata->lcr transformation functions
Rem    jingliu     11/09/01 - add comments
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    jingliu     11/06/01 - change global_name to source_database
Rem    jingliu     11/01/01 - add transactional_queue to set_up_queue
Rem    jingliu     10/25/01 - 
Rem    elu         10/25/01 - modify add_subset_rules
Rem    liwong      10/23/01 - Combine dbms_streams and dbms_streams_adm
Rem    elu         10/17/01 - add add_subset_rules
Rem    jingliu     10/16/01 - modify APIs
Rem    apadmana    10/16/01 - modify purge_source_catalog()
Rem    jingliu     10/15/01 - fix API parameter
Rem    celsbern    10/03/01 - added grants and synonyms.
Rem    celsbern    09/30/01 - Merged celsbern_sugar_2
Rem    celsbern    09/18/01 - Created
Rem

Rem Logical Change Record
@@dbmslcr.sql

Rem Streams TableSpaces
@@dbmssts.sql

CREATE OR REPLACE PACKAGE dbms_streams AUTHID CURRENT_USER AS

  -------------
  -- CONSTANTS

  -- sets the binary tag for all LCRs subsequently generated by the
  -- current session. Each LCR created by DML or DDL statement
  -- in the current session will have this tag.
  -- this procedure is not transactional and not affected by rollback
  -- Note: the invoker of set_tag should have execute privilege on
  --       dbms_streams_adm or execute_catalog_role
  PROCEDURE set_tag(tag IN RAW DEFAULT NULL);

  -- get the binary tag for all LCRs generated by the current session.
  -- Note: the invoker of get_tag should have execute privilege on
  --       dbms_streams_adm or execute_catalog_role
  FUNCTION get_tag RETURN RAW;

  -- get the Streams name. Returns NULL if not in Streams environment.
  FUNCTION get_streams_name RETURN VARCHAR2;

  -- get the Streams type: APPLY, CAPTURE, PROPAGATION or ERROR_EXECUTION.
  -- Returns NULL if not in Streams environment.
  FUNCTION get_streams_type RETURN VARCHAR2;

  -- transformation function to convert from Sys.Anydata to SYS.LCR$_ROW_RECORD
  FUNCTION convert_anydata_to_lcr_row(source SYS.ANYDATA) return SYS.LCR$_ROW_RECORD;

  -- transformation function to convert from Sys.Anydata to SYS.LCR$_DDL_RECORD
  FUNCTION convert_anydata_to_lcr_ddl(source SYS.ANYDATA)
    return SYS.LCR$_DDL_RECORD;

  -- generic function to get values of some of the properties
  FUNCTION get_information(name IN VARCHAR2) RETURN SYS.ANYDATA;
  
  -- internal compatible representation for 9.2
  FUNCTION compatible_9_2 RETURN INTEGER;

  -- internal compatible representation for 10.1
  FUNCTION compatible_10_1 RETURN INTEGER;

  -- internal compatible representation for 10.2
  FUNCTION compatible_10_2 RETURN INTEGER;

  -- internal compatible representation for 11.1
  FUNCTION compatible_11_1 RETURN INTEGER;

  -- internal compatible representation for 11.2
  FUNCTION compatible_11_2 RETURN INTEGER;

  -- internal compatible representation for max_compatible
  FUNCTION max_compatible RETURN INTEGER;

  -- Convert an XMLLCR object into a DML or DDL LCR encapsulated in AnyData.
  FUNCTION convert_xml_to_lcr(xmldat sys.xmltype) RETURN SYS.ANYDATA;

  -- Convert a DML or DDL LCR encapsulated in an anydata into an
  -- XMLLCR object.
  FUNCTION convert_lcr_to_xml(anylcr sys.anydata) RETURN SYS.XMLTYPE;

END dbms_streams;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams FOR dbms_streams
/

/* drop dbms_streams explicitly to revoke grant options in case the 
 * db was upgraded from pre-11 release
 */
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_STREAMS FROM PUBLIC'; 
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

GRANT EXECUTE ON dbms_streams TO PUBLIC
/

CREATE OR REPLACE PACKAGE dbms_streams_adm AUTHID CURRENT_USER AS 

  -------------
  -- CONSTANTS
  instantiation_none              CONSTANT BINARY_INTEGER := 0;
  instantiation_table             CONSTANT BINARY_INTEGER := 1;
  instantiation_table_network     CONSTANT BINARY_INTEGER := 2;
  instantiation_schema            CONSTANT BINARY_INTEGER := 3;
  instantiation_schema_network    CONSTANT BINARY_INTEGER := 4;
  instantiation_full              CONSTANT BINARY_INTEGER := 5;
  instantiation_full_network      CONSTANT BINARY_INTEGER := 6;
  -- transportable tablespace
  instantiation_tts               CONSTANT BINARY_INTEGER := 7;
  instantiation_tts_network       CONSTANT BINARY_INTEGER := 8;

  -- The following constants are used by the prepare_upgrade API
  exclude_flags_full              CONSTANT BINARY_INTEGER := 1;
  exclude_flags_unsupported       CONSTANT BINARY_INTEGER := 2;
  exclude_flags_dml               CONSTANT BINARY_INTEGER := 4;
  exclude_flags_ddl               CONSTANT BINARY_INTEGER := 8;

  -- The following constants are used by set_message_tracing
  action_trace                    CONSTANT BINARY_INTEGER := 1;
  action_memory                   CONSTANT BINARY_INTEGER := 2;


  -------------
  -- EXCEPTIONS
  client_ruleset_not_exist EXCEPTION;
    PRAGMA exception_init(client_ruleset_not_exist, -26698);
    client_ruleset_not_exist_num NUMBER := -26698;

  dequeue_exists EXCEPTION;
    PRAGMA exception_init(dequeue_exists, -26699);
    dequeue_exists_num NUMBER := -26699;

  cannot_create_process EXCEPTION;
    PRAGMA exception_init(cannot_create_process, -26664);
    cannot_create_process_num NUMBER := -26664;

  process_exists EXCEPTION;
    PRAGMA exception_init(process_exists, -26665);
    process_exists_num NUMBER := -26665;

  invalid_parameter EXCEPTION;
    PRAGMA exception_init(invalid_parameter, -26667);
    invalid_parameter_num NUMBER := -26667;

  process_not_exist EXCEPTION;
    PRAGMA exception_init(process_not_exist, -26701);
    process_not_exist_num NUMBER := -26701;

  role_required EXCEPTION;
    PRAGMA exception_init(role_required, -26723);
    role_required_num NUMBER := -26723;

  set_user_to_sys EXCEPTION;
    PRAGMA exception_init(set_user_to_sys, -26724);
    set_user_to_sys_num NUMBER := -26724;

  mult_trans_specified EXCEPTION;
    PRAGMA exception_init(mult_trans_specified, -26754);
    mult_trans_specified_num NUMBER := -26754;

/*split off a propagation. If any of cloned_propagation_name, 
  cloned_capture_namei, cloned_queue_name are null, we will 
  generate a name for it*/
PROCEDURE split_streams (
  propagation_name         IN     VARCHAR2,
  cloned_propagation_name  IN     VARCHAR2 DEFAULT NULL,
  cloned_queue_name        IN     VARCHAR2 DEFAULT NULL,
  cloned_capture_name      IN     VARCHAR2 DEFAULT NULL,
  perform_actions          IN     BOOLEAN  DEFAULT TRUE,
  script_name              IN     VARCHAR2 DEFAULT NULL,
  script_directory_object  IN     VARCHAR2 DEFAULT NULL,
  auto_merge_threshold     IN     NUMBER   DEFAULT NULL,
  schedule_name            IN OUT VARCHAR2,
  merge_job_name           IN OUT VARCHAR2);

/* merge the propagation */
PROCEDURE merge_streams (
  cloned_propagation_name IN VARCHAR2,
  propagation_name        IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT NULL,
  perform_actions         IN BOOLEAN  DEFAULT TRUE,
  script_name             IN VARCHAR2 DEFAULT NULL,
  script_directory_object IN VARCHAR2 DEFAULT NULL);

/* This function is called by a merge streams job to merge two streams */
PROCEDURE merge_streams_job (
  cloned_propagation_name        IN VARCHAR2,
  propagation_name               IN VARCHAR2 DEFAULT NULL,
  queue_name                     IN VARCHAR2 DEFAULT NULL,
  merge_threshold                IN NUMBER,
  schedule_name                  IN VARCHAR2 DEFAULT NULL,
  merge_job_name                 IN VARCHAR2 DEFAULT NULL);

/* Add message rule */
PROCEDURE add_message_rule (
  message_type            IN VARCHAR2,
  rule_condition          IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  inclusion_rule          IN BOOLEAN  DEFAULT TRUE);

/* Add message rule */
PROCEDURE add_message_rule (
  message_type            IN VARCHAR2,
  rule_condition          IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  rule_name               OUT VARCHAR2);

/* Add propagation rule */
PROCEDURE add_message_propagation_rule (
  message_type            IN VARCHAR2,
  rule_condition          IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

/* Add propagation rule */
PROCEDURE add_message_propagation_rule (
  message_type            IN  VARCHAR2,
  rule_condition          IN  VARCHAR2,
  streams_name            IN  VARCHAR2 DEFAULT NULL,
  source_queue_name       IN  VARCHAR2,
  destination_queue_name  IN  VARCHAR2,
  inclusion_rule          IN  BOOLEAN DEFAULT TRUE,
  rule_name               OUT VARCHAR2,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

/* Adds capture or apply rules for a table. */
PROCEDURE add_table_rules(
  table_name              IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

/* Adds capture or apply rules for a table. */
PROCEDURE add_table_rules(
  table_name              IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

/* Adds capture or apply rules for a schema. */
PROCEDURE add_schema_rules(
  schema_name             IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

/* Adds capture or apply rules for a schema. */
PROCEDURE add_schema_rules(
  schema_name             IN VARCHAR2,
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

-- Adds a capture rule for an entire database or an apply rule
-- for an entire queue.
-- INPUT:
--  streams_type - The type of process: capture, apply or dequeue
--  streams_name - The name of the capture or apply process.
--  queue_name   - The name of the queue. For capture rules, the queue
--                 into which the changes will be enqueued. For apply rules,
--                 the queue from which changes will be dequeued.
--  include_dml - If TRUE, then creates a rule for DML changes. If FALSE,
--                then does not create a DML rule. NULL is not permitted.
--  include_ddl - If TRUE, then creates a rule for DDL changes. If FALSE,
--                then does not create a DDL rule. NULL is not permitted.
--  include_tagged_lcr - If TRUE, then a logical change record is always
--                        considered for capture or apply, regardless of 
--                        whether it has a non-NULL tag. This setting is 
--                        appropriate for a full (for example, standby) copy
--                        of a database. If FALSE, then a logical change
--                        record is considered for capture or apply only when
--                        it was produced in a session in which its tag is
--                        NULL. FALSE is often specified in update-anywhere 
--                        configurations to avoid sending a change back to
--                        its source database.
--  source_database - The global name of the source database. 
--                    If NULL, then the global name of the current database
--                    is used.
--  inclusion_rule  - If TRUE, then the rule(s) are added to the positive
--                    rule set for the streams process; if FALSE, then
--                    the rule(s) are added to the negative rule set.
--  and_condition   - additional condition to be appended to the generated rule
--                    with an 'AND'.  The variable name for the lcr in the
--                    condition should be :lcr.
PROCEDURE add_global_rules(
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT null,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

/* Adds a capture rule for an entire database or an apply rule
 * for an entire queue.
 */
PROCEDURE add_global_rules(
  streams_type            IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  queue_name              IN VARCHAR2 DEFAULT 'streams_queue',
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL);

-- Removes the specified rule or removes all rules from the rule set
-- associated with the specified capture process, apply process,
-- propagation or message consumer rule set.
-- If the associate streams name no longer exists and rule_name is not null,
-- the entry in dba_streams_%_rules for rule_name will be removed and
-- ORA-23605 is raised.
--
-- INPUT:
--  rule_name - The name of the rule to remove. If NULL, then removes
--              all rules for the specified capture process, apply process,
--              or propagation stream rule set.
--  streams_type - The type of Streams rule, either capture, apply,
--                 or propagate
--  streams_name - The name of the capture process, apply process, 
--                 or propagation stream
--  drop_unused_rule - If FALSE, then the rule is not dropped from
--                     the database. If TRUE and the rule is not in any
--                     rule set, then the rule is dropped from the database.
--                     If TRUE and the rule exists in any rule set,
--                     then the rule is not dropped from the database.
--  inclusion_rule - If TRUE, then the rule is dropped from the positive
--                   rule set. If FALSE, then the rule is dropped from
--                   the negative rule set.

PROCEDURE remove_rule(
  rule_name          IN VARCHAR2,
  streams_type       IN VARCHAR2,
  streams_name       IN VARCHAR2,
  drop_unused_rule   IN BOOLEAN DEFAULT TRUE,
  inclusion_rule     IN BOOLEAN DEFAULT TRUE);

-- Sets up a queue table and a queue for use with the capture,
-- propagate, and apply functionality of Streams. 
-- The queue functions as a Streams queue.
-- INPUT:
--  queue_table    - The name of the queue table
--  storage_clause - The storage clause for queue creation
--  queue_name     - The name of the queue that will function as
--                   the Streams queue
--  queue_user     - The name of the user who requires enqueue and
--                   dequeue privileges for the queue. If NULL, then no
--                   privileges are granted. You can grant queue privileges 
--                   to the appropriate users using the DBMS_AQADM package.
--  transactional_queue - 
--  comment        -

PROCEDURE set_up_queue(
  queue_table         IN VARCHAR2 DEFAULT 'streams_queue_table',
  storage_clause      IN VARCHAR2 DEFAULT NULL,
  queue_name          IN VARCHAR2 DEFAULT 'streams_queue',
  queue_user          IN VARCHAR2 DEFAULT NULL,
  comment             IN VARCHAR2 DEFAULT NULL);


-- Adds the destination queue as a subscriber of the source queue, 
-- if the destination queue is not already subscribed to the source queue.
-- This procedure also configures propagation, if necessary, using
-- the currently connected user. This procedure also enables propagation
-- of messages for the specified table, subject to filtering conditions,
-- to the destination queue.  
-- INPUT:
--  table_name         - The name of the table specified as 
--                       schema_name.object_name. For example, hr.employees.
--                       If the schema is not specified, then the current user
--                       is the default.
--  schema_name        - The name of the schema. For example, hr.
--  streams_name       - The name of the propagation stream.
--  source_queue_name  - The name of the source queue.
--                       The current database must contain the source queue.
--  destination_queue_name - The name of the destination queue,
--                           including any database link, such as
--                           STREAMS_QUEUE@DBS2. If the database link
--                           is omitted, then the global name of the current
--                           database is used.
--  include_dml - If TRUE, then create a rule for DML changes. If FALSE, 
--                then do not create a DML rule. NULL is not permitted.
--  include_ddl - If TRUE, then create a rule for DDL changes.  If FALSE, 
--                then do not create a DDL rule. NULL is not permitted.
--
--  include_tagged_lcr - If TRUE, then a logical change record is 
--                       always considered for propagation, regardless 
--                       of whether it has  a non-NULL tag.
--                       If FALSE, then a logical change record is considered
--                       for propagation only when it is produced in a session
--                       in which its tag is NULL.
--  source_database - The global name of the source database.
--                    If NULL, then the global name of the current
--                     database is used.
-- OUTPUT:
--  dml_rule_name - If include_dml is TRUE, then dml_rule_name contains
--                  the DML rule name. If include_dml is FALSE,
--                  then dml_rule_name contains a NULL.
--
--  ddl_rule_name - If include_ddl is TRUE, then ddl_rule_name contains
--                  the DDL rule name. If include_ddl is FALSE, 
--                  then ddl_rule_name contains a NULL.
--  inclusion_rule  - If TRUE, then the rule(s) are added to the positive
--                    rule set for the streams process; if FALSE, then
--                    the rule(s) are added to the negative rule set.
--  and_condition   - additional condition to be appended to the generated rule
--                    with an 'AND'.  The variable name for the lcr in the
--                    condition should be :lcr.
PROCEDURE add_table_propagation_rules(
  table_name              IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_table_propagation_rules(
  table_name              IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_schema_propagation_rules(
  schema_name             IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_schema_propagation_rules(
  schema_name             IN VARCHAR2,
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_global_propagation_rules(
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE add_global_propagation_rules(
  streams_name            IN VARCHAR2 DEFAULT NULL,
  source_queue_name       IN VARCHAR2,
  destination_queue_name  IN VARCHAR2,
  include_dml             IN BOOLEAN DEFAULT TRUE,
  include_ddl             IN BOOLEAN DEFAULT FALSE,
  include_tagged_lcr      IN BOOLEAN DEFAULT FALSE,
  source_database         IN VARCHAR2 DEFAULT NULL,
  dml_rule_name           OUT VARCHAR2,
  ddl_rule_name           OUT VARCHAR2,
  inclusion_rule          IN BOOLEAN DEFAULT TRUE,
  and_condition           IN VARCHAR2 DEFAULT NULL,
  queue_to_queue          IN BOOLEAN DEFAULT NULL);

PROCEDURE purge_source_catalog(
  source_database    IN VARCHAR2,
  source_object_name IN VARCHAR2,
  source_object_type IN VARCHAR2);

-- Adds subset rules for the given dml condition on the specified table.
-- Subset rules are used for row migration.
-- INPUT:
--  table_name   - The name of the table the subset rule is specified for.
--  dml_condition - The dml condition used for subsetting.
--  streams_type - The type of process: capture, apply or dequeue
--  streams_name - The name of the capture or apply process.
--  queue_name   - The name of the queue. For capture rules, the queue
--                 into which the changes will be enqueued. For apply rules,
--                 the queue from which changes will be dequeued.
--  include_tagged_lcr - If TRUE, then a logical change record is always
--                        considered for capture or apply, regardless of 
--                        whether it has a non-NULL tag. This setting is 
--                        appropriate for a full (for example, standby) copy
--                        of a database. If FALSE, then a logical change
--                        record is considered for capture or apply only when
--                        it was produced in a session in which its tag is
--                        NULL. FALSE is often specified in update-anywhere 
--                        configurations to avoid sending a change back to
--                        its source database.
--  source_database - The global name of the source database. 
--                    If NULL, then the global name of the current database
--                    is used.
-- OUTPUT:
--  insert_rule_name - The name of the subset rule generated for insert DMLs
--                     satisfying the specified dml condition.
--  update_rule_name - The name of the subset rule generated for update DMLs
--                     satisfying the specified dml condition.
--  delete_rule_name - The name of the subset rule generated for delete DMLs
--                     satisfying the specified dml condition.

PROCEDURE add_subset_rules(
  table_name                 IN VARCHAR2,
  dml_condition              IN VARCHAR2,
  streams_type               IN VARCHAR2 DEFAULT 'APPLY',
  streams_name               IN VARCHAR2 DEFAULT NULL,
  queue_name                 IN VARCHAR2 DEFAULT 'streams_queue',
  include_tagged_lcr         IN BOOLEAN DEFAULT FALSE,
  source_database            IN VARCHAR2 DEFAULT NULL);

PROCEDURE add_subset_rules(
  table_name                 IN     VARCHAR2,
  dml_condition              IN     VARCHAR2,
  streams_type               IN     VARCHAR2 DEFAULT 'APPLY',
  streams_name               IN     VARCHAR2 DEFAULT NULL,
  queue_name                 IN     VARCHAR2 DEFAULT 'streams_queue',
  include_tagged_lcr         IN     BOOLEAN DEFAULT FALSE,
  source_database            IN VARCHAR2 DEFAULT NULL,
  insert_rule_name              OUT VARCHAR2,
  update_rule_name              OUT VARCHAR2,
  delete_rule_name              OUT VARCHAR2);

-- Adds propagation subset rules for the given dml condition on the 
-- specified table. Subset rules are used for row migration.
-- INPUT:
--  table_name   - The name of the table the subset rule is specified for.
--  dml_condition - The dml condition used for subsetting.
--  streams_name - The name of the capture or apply process.
--  source_queue_name - The name of the source queue. 
--  destination_queue_name - The name of the destination queue. 
--  include_tagged_lcr - If TRUE, then a logical change record is always
--                        considered for propagation, regardless of 
--                        whether it has a non-NULL tag. This setting is 
--                        appropriate for a full (for example, standby) copy
--                        of a database. If FALSE, then a logical change
--                        record is considered for propagation only when
--                        it was produced in a session in which its tag is
--                        NULL. FALSE is often specified in update-anywhere 
--                        configurations to avoid sending a change back to
--                        its source database.
--  source_database - The global name of the source database. 
--                    If NULL, then the global name of the current database
--                    is used.
-- OUTPUT:
--  insert_rule_name - The name of the subset rule generated for insert DMLs
--                     satisfying the specified dml condition.
--  update_rule_name - The name of the subset rule generated for update DMLs
--                     satisfying the specified dml condition.
--  delete_rule_name - The name of the subset rule generated for delete DMLs
--                     satisfying the specified dml condition.
 
PROCEDURE add_subset_propagation_rules(
  table_name                 IN VARCHAR2,
  dml_condition              IN VARCHAR2,
  streams_name               IN VARCHAR2 DEFAULT NULL,
  source_queue_name          IN VARCHAR2,
  destination_queue_name     IN VARCHAR2,
  include_tagged_lcr         IN BOOLEAN DEFAULT FALSE,
  source_database            IN VARCHAR2 DEFAULT NULL,
  queue_to_queue             IN BOOLEAN DEFAULT NULL);

PROCEDURE add_subset_propagation_rules(
  table_name                 IN     VARCHAR2,
  dml_condition              IN     VARCHAR2,
  streams_name               IN     VARCHAR2 DEFAULT NULL,
  source_queue_name          IN     VARCHAR2,
  destination_queue_name     IN     VARCHAR2,
  include_tagged_lcr         IN     BOOLEAN DEFAULT FALSE,
  source_database            IN     VARCHAR2 DEFAULT NULL,
  insert_rule_name              OUT VARCHAR2,
  update_rule_name              OUT VARCHAR2,
  delete_rule_name              OUT VARCHAR2,
  queue_to_queue             IN BOOLEAN DEFAULT NULL);

-- Sets the Streams user-defined transformation for the given rule.
-- rule_name: the name of the rule to set the transformation for.
-- transform_function: the name of the user-defined transformation.
--   This should be the fully qualifed name: <schema>.<package>.<procedure>. 
--   If this parameter is NULL, then any existing tranformation is deleted.
PROCEDURE set_rule_transform_function(
  rule_name          IN VARCHAR2,
  transform_function IN VARCHAR2);

-- Removes any existing streams configuration.  This means that:
--     Any capture/propagation/apply processes will be dropped, and
--     Any apply errors will be deleted, and
--     Any streams rules (rules created implicitly by the API's in package 
--       dbms_streams_adm) will be removed and dropped, and
--     Any instantiation scn's for tables/schemas/database will be removed, and
--     If instantiation was prepared on any tables/schemas/database, then it
--       will be aborted, and
--     No queues will be dropped.
-- INPUT:
--   Nothing.
-- OUTPUT:
--   Nothing.
PROCEDURE remove_streams_configuration;

PROCEDURE set_message_notification(
  streams_name           IN VARCHAR2,
  notification_action    IN VARCHAR2,
  notification_type      IN VARCHAR2 DEFAULT 'PROCEDURE',
  notification_context   IN SYS.ANYDATA DEFAULT NULL,
  include_notification   IN BOOLEAN DEFAULT TRUE,
  queue_name             IN VARCHAR2 DEFAULT 'streams_queue');

-- streams_name : The name specified in add_message_rule for DEQUEUE
-- queue_name : The name of the queue
-- notification_action : the action of the notification, e.g., URL without
--                       'HTTP://', email address, PL/SQL procedure.
-- notificaiton_type : one of 'PROCEDURE', 'HTTP', 'MAIL'
-- notification_context : the context of the notification.
-- include_notification : If TRUE, this notification is added for the given
--   streams_name and queue_name. If FALSE, this notification is removed for
--   the given streams_name and queue_name.

-- Removes a queue from use in Streams.  Specifically, the queue will be 
-- stopped, and no further enqueue or dequeues will be allowed on the queue.
-- INPUT:
--   queue_name              - The name of the queue to be removed.
--   cascade                 - If TRUE, will remove the all associated streams 
--                               components in addition to the queue
--                             If FALSE, will raise an error if any associated
--                               streams components are found
--   drop_unused_queue_table - If TRUE, the queue table that stores 
--                               information about this queue is dropped if 
--                               it is empty.  
--                             If FALSE, the queue table is unchanged.  
-- OUTPUT:
--   Nothing.
PROCEDURE remove_queue(
  queue_name               IN VARCHAR2,
  cascade                  IN BOOLEAN DEFAULT FALSE,
  drop_unused_queue_table  IN BOOLEAN DEFAULT TRUE);


-- The maintain_tablespaces API does automatic tablespace transport and
-- incrementally maintains the transported tablespaces using Streams.
-- It optionally generates a script to do this which can be edited and 
-- executed by the user.
-- Note this API has been deprecated, please use maintain_tts instead.
-- The incremental maintenace is performed as follows:
-- At the source database:
--   - Mark all the tablespaces in the supplied list of  tablespaces as read
--     only.
--   - Clone the tablespaces using 
--     dbms_streams_tablespace_adm.clone_tablespaces and place the tablespace 
--     set in the source directory.
--   - Add supplemental log groups for the tables in the tablespaces  if
--     necessary.
--   - Setup a Streams queue at the source.
--   - Create a capture process and add all supported tables in the
--     tablespaces to the capture rules.
--   - Create propagation, add all supported tables to the propagation rules
--     and disable propagation.
--   - Save the value of current scn as the instantiation scn for the
--     destination database apply setup.
--   - Startup capture process.
--   - Restore read-write status of tablespaces. DML operations can now
--     resume in the tablespaces.
--   - Move the tablespace set to the destination directory using
--     dbms_file_transfer.
-- At the destination database:
--   - Attach the tablespaces using
--     dbms_streams_tablespace_adm.attach_tablespaces.
--   - Set key columns for all the tables in the tablespaces if necessary.
--   - Setup Streams queue.
--   - Create an apply process and add all supported tables to the apply
--     rules.
--   - Set instantiation scn obtained from the source database for the each
--     table.
--   - Startup apply process.
--   - Mark tablespaces as read-write.
-- At the source database:
--   - Enable propagation schedule to the destination database.
-- INPUT:
--  tablespace_names             : list of self-contained tablespaces
--  source_directory_object      : location where cloned tablespace set
--                                 will be placed at the source
--  destination_directory_object : directory at destination database where the
--                                 cloned tablespace set will be moved
--  destination_database         : destination database
--  setup_streams                : If FALSE, only generate a script
--  script_name                  : name of the generated script
--  script_directory_object      : generated script is placed here
--  dump_file_name               : name of the file produced by datapump
--                                 export of the tablespace metadata
--  source_queue_table           : queue table at source
--  source_queue_name            : queue at source
--  source_queue_user            : source queue user
--  destination_queue_table      : queue table at destination
--  destination_queue_name       : queue at destination
--  destination_queue_user       : destination queue user
--  capture_name                 : name of the capture process
--  propagation_name             : propagation name 
--  apply_name                   : apply process name
--  log_file                     : name of the log file generated during
--                                 datapump export/import
--  bi_directional               : If TRUE setup bi-directional information
--                                 sharing. Else, only uni-directional 
--                                 sharing is setup.

  PROCEDURE maintain_tablespaces(
    tablespace_names             IN dbms_streams_tablespace_adm.tablespace_set,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    destination_database         IN VARCHAR2,
    setup_streams                IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    source_queue_table           IN VARCHAR2 DEFAULT 'streams_queue_table',
    source_queue_name            IN VARCHAR2 DEFAULT 'streams_queue',
    source_queue_user            IN VARCHAR2 DEFAULT NULL,
    destination_queue_table      IN VARCHAR2 DEFAULT 'streams_queue_table',
    destination_queue_name       IN VARCHAR2 DEFAULT 'streams_queue',
    destination_queue_user       IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT 'capture',
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE);

-- The maintain_tts API is similar to maintain_tablespaces except for
-- the following parameters: 
--  source_database              : the source database name.  
--                                 If NULL, will default to the current 
--                                 database name.
--                                 If non-NULL, and different from the actual
--                                 source database name, will setup
--                                 downstream capture on the specified 
--                                 database.
--  perform_actions              : If FALSE, only generate a script
--  capture_queue_table          : queue table name for capture processes
--                                 if NULL, name will be generated
--  capture_queue_name           : queue name for capture processes
--                                 if NULL, name will be generated
--  capture_queue_user           : queue user for capture processes
--                                 if NULL, name will be generated
--  apply_queue_table            : queue table for apply processes
--                                 if NULL, name will be generated
--  apply_queue_name             : queue name for apply processes
--                                 if NULL, name will be generated
--  apply_queue_user             : queue user for apply processes
--                                 if NULL, name will be generated
--  capture_name                 : name of the capture process
--                                 if NULL, name will be generated
-- For a bi-directional setup, two queues will be created on each database.  

  PROCEDURE maintain_tts(
    tablespace_names             IN dbms_streams_tablespace_adm.tablespace_set,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE);

-- The maintain_simple_tablespace API does automatic tablespace transport and
-- incrementally maintains a single self contained tablespace.
-- It optionally generates a script which can be edited and executed by 
-- the user.
-- Note this API has been deprecated, please use maintain_simple_tts instead.
-- Functionality is similar to maintain_tablespaces except that this
-- can be used only for a single self-contained tablespace. All the Streams
-- processes and objects will have the same names as the corresponding 
-- defaults in the maintain_tablespaces API.
  PROCEDURE maintain_simple_tablespace(
    tablespace_name                IN VARCHAR2,
    source_directory_object        IN VARCHAR2,
    destination_directory_object   IN VARCHAR2,
    destination_database           IN VARCHAR2,
    setup_streams                  IN BOOLEAN  DEFAULT TRUE,
    script_name                    IN VARCHAR2 DEFAULT NULL,
    script_directory_object        IN VARCHAR2 DEFAULT NULL,
    bi_directional                 IN BOOLEAN  DEFAULT FALSE);

-- The maintain_simple_tts API is similar to maintain_simple_tablespace
-- except for the following parameters: 
--  source_database              : the source database name
--                                 If NULL, will default to the current 
--                                 database name.
--                                 If non-NULL, and different from the actual
--                                 source database name, will setup
--                                 downstream capture on the specified 
--                                 database.
--  perform_actions              : If FALSE, only generate a script
-- For a bi-directional setup, two queues will be created on each database.  
  PROCEDURE maintain_simple_tts(
    tablespace_name                IN VARCHAR2,
    source_directory_object        IN VARCHAR2,
    destination_directory_object   IN VARCHAR2,
    source_database                IN VARCHAR2,    
    destination_database           IN VARCHAR2,
    perform_actions                IN BOOLEAN  DEFAULT TRUE,
    script_name                    IN VARCHAR2 DEFAULT NULL,
    script_directory_object        IN VARCHAR2 DEFAULT NULL,
    bi_directional                 IN BOOLEAN  DEFAULT FALSE);

-- Parameters with same name as maintain_tts have the same meaning.
-- Other parameters:
--   table_names: names of tables with optional schema name. If schema name is
--                not specified, the invoker is used.
--                One version is a PL/SQL table and another one accepts a
--                comma-separated list.
  PROCEDURE maintain_tables(
    table_names                  IN dbms_utility.uncl_array,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    instantiation                IN BINARY_INTEGER DEFAULT
                                     dbms_streams_adm.instantiation_table);

  PROCEDURE maintain_tables(
    table_names                  IN VARCHAR2,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    instantiation                IN BINARY_INTEGER DEFAULT
                                     dbms_streams_adm.instantiation_table);

-- Parameters with same name as maintain_tts have the same meaning.
-- Other parameters:
--   schema_names: names of schemas.
--                One version is a PL/SQL table and another one accepts a
--                comma-separated list.
  PROCEDURE maintain_schemas(
    schema_names                 IN dbms_utility.uncl_array,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    instantiation                IN BINARY_INTEGER DEFAULT
                                     dbms_streams_adm.instantiation_schema);

  PROCEDURE maintain_schemas(
    schema_names                 IN VARCHAR2,
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    instantiation                IN BINARY_INTEGER DEFAULT
                                     dbms_streams_adm.instantiation_schema);

  PROCEDURE maintain_global(
    source_directory_object      IN VARCHAR2,
    destination_directory_object IN VARCHAR2,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    dump_file_name               IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    log_file                     IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    instantiation                IN BINARY_INTEGER DEFAULT
                                     dbms_streams_adm.instantiation_full);
  PROCEDURE pre_instantiation_setup(
    maintain_mode                IN VARCHAR2,
    tablespace_names             IN dbms_streams_tablespace_adm.tablespace_set,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    start_processes              IN BOOLEAN  DEFAULT FALSE,
    exclude_schemas              IN VARCHAR2 DEFAULT NULL,
    exclude_flags                IN BINARY_INTEGER DEFAULT NULL);

  PROCEDURE post_instantiation_setup(
    maintain_mode                IN VARCHAR2,
    tablespace_names             IN dbms_streams_tablespace_adm.tablespace_set,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    include_ddl                  IN BOOLEAN  DEFAULT FALSE,
    start_processes              IN BOOLEAN  DEFAULT FALSE,
    instantiation_scn            IN NUMBER   DEFAULT NULL, 
    exclude_schemas              IN VARCHAR2 DEFAULT NULL,
    exclude_flags                IN BINARY_INTEGER DEFAULT NULL);

  PROCEDURE cleanup_instantiation_setup(
    maintain_mode                IN VARCHAR2,
    tablespace_names             IN dbms_streams_tablespace_adm.tablespace_set,
    source_database              IN VARCHAR2,
    destination_database         IN VARCHAR2,
    perform_actions              IN BOOLEAN  DEFAULT TRUE,
    script_name                  IN VARCHAR2 DEFAULT NULL,
    script_directory_object      IN VARCHAR2 DEFAULT NULL,
    capture_name                 IN VARCHAR2 DEFAULT NULL,
    capture_queue_table          IN VARCHAR2 DEFAULT NULL,
    capture_queue_name           IN VARCHAR2 DEFAULT NULL,
    capture_queue_user           IN VARCHAR2 DEFAULT NULL,
    propagation_name             IN VARCHAR2 DEFAULT NULL,
    apply_name                   IN VARCHAR2 DEFAULT NULL,
    apply_queue_table            IN VARCHAR2 DEFAULT NULL,
    apply_queue_name             IN VARCHAR2 DEFAULT NULL,
    apply_queue_user             IN VARCHAR2 DEFAULT NULL,
    bi_directional               IN BOOLEAN  DEFAULT FALSE,
    change_global_name           IN BOOLEAN  DEFAULT FALSE);

  -- This procedure provides the user the option to either roll FORWARD
  -- the operation, ROLLBACK the operation or PURGE the metadata for the
  -- operation.
  -- Input parameters:
  --   script_id : operation id of the API invocation.
  --               can be obtained from dba_recoverable_script_* views
  --   operation_mode : this can have the following values:
  --     'FORWARD' : roll forward (default mode)
  --     'ROLLBACK' : rollback all the operations performed so far.
  --     'PURGE' : purge all metadata without rolling back.
  PROCEDURE recover_operation(
    script_id IN RAW,
    operation_mode IN VARCHAR2 DEFAULT 'FORWARD');


  -- For point in time recovery, given the SCN at the source, returns
  -- the instantiation SCN and start SCN from the destination. These 
  -- SCNs can be used to configure the capture and apply processes 
  -- used for recovery. 
  -- The procedure will also return a list of transactions to skip 
  -- (transactions applied at the source earlier than src_pit_scn, 
  -- but which were applied out of order, after 
  -- dest_instantiation_scn, at the destination).
  -- The caller of this procedure must have EXECUTE privileges for 
  -- DBMS_FLASHBACK. The log files containing the applied changes
  -- lost at the source  must exist.
  -- 
  -- Parameters:
  --   apply_name:             name of the apply process which applies LCRs 
  --                           from the source database being recovered.
  --   src_pit_scn:            the point in time recovery SCN at the source 
  --                           database.
  --   dest_instantiation_scn: SCN to set the instantiation SCNs to at the
  --                           source during recovery.
  --   dest_start_scn:         SCN to use for the start_scn parameter for
  --                           recovery capture process. 
  --   dest_skip_txn_ids:      transactions ids which should be ignored by
  --                           the recovery apply process. These transactions
  --                           were applied out of order. 
  PROCEDURE get_scn_mapping(
    apply_name               IN  VARCHAR2,
    src_pit_scn              IN  NUMBER,
    dest_instantiation_scn   OUT NUMBER,
    dest_start_scn           OUT NUMBER,
    dest_skip_txn_ids        OUT DBMS_UTILITY.NAME_ARRAY);

  -- Specifies for the given rule that all lcrs with the specified
  -- schema will have their schema name renamed. 
  -- 
  -- Parameters:
  --   rule_name:              The name of the rule to add this
  --                           functionality to. 
  --   from_schema_name:       The schema to rename.
  --   to_schema_name:         The new schema name. 
  --   step_number:            The order relative to other transformations.
  --   operation:              Specify 'ADD' to add this
  --                           transformation, or 'REMOVE' to remove it.  
  PROCEDURE rename_schema(
    rule_name                 IN VARCHAR2,
    from_schema_name          IN VARCHAR2,
    to_schema_name            IN VARCHAR2,
    step_number               IN NUMBER DEFAULT 0,
    operation                 IN VARCHAR2 DEFAULT 'ADD'); 


  -- Specifies for the given rule that all lcrs with the specified
  -- schema will have their table name renamed. 
  -- 
  -- Parameters:
  --   rule_name:              The name of the rule to add this
  --                           functionality to. 
  --   from_table_name:        The fully specified (SCHEMA.TABLE)
  --                           table to be renamed.  If the schema is
  --                           not specified, the invoker of the api
  --                           will be used.  
  --   to_table_name:          The fully specified (SCHEMA.TABLE) new
  --                           table name.  If the schema is not
  --                           specified, the invoker of the api will
  --                           be used.   
  --   step_number:            The order relative to other transformations.
  --   operation:              Specify 'ADD' to add this
  --                           transformation, or 'REMOVE' to remove it.  
  PROCEDURE rename_table(
    rule_name          IN VARCHAR2,
    from_table_name    IN VARCHAR2,
    to_table_name      IN VARCHAR2,
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD');

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a column deleted. 
  -- 
  -- Parameters:
  --   rule name:      The name of the rule to add this functionality to.
  --   table_name:     The fully-qualified table name whose columns are to be
  --                   dropped.  If the schema is not specified, the
  --                   invoker of the api will be used.   
  --   column_name:    The column to drop delete.  
  --   value_type:     Whether to drop the old, new, or both columns
  --                   in the lcr.  Specify 'old', 'new', or '*'.
  --   step_number:    The order relative to other transformations.
  --   operation:      Specify 'ADD' to add this transformation, or
  --                   'REMOVE' to remove it.   
  PROCEDURE delete_column(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_name        IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a list of columns kept. 
  -- 
  -- Parameters:
  --   rule name:      The name of the rule to add this functionality to.
  --   table_name:     The fully-qualified table name whose columns are to be
  --                   kept.  If the schema is not specified, the
  --                   invoker of the api will be used.   
  --   column_table:   The list of columns to keep.  
  --   value_type:     Whether to keep the old, new, or both columns
  --                   in the lcr.  Specify 'old', 'new', or '*'.
  --   step_number:    The order relative to other transformations.
  --   operation:      Specify 'ADD' to add this transformation, or
  --                   'REMOVE' to remove it.   
  PROCEDURE keep_columns(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_table       IN DBMS_UTILITY.LNAME_ARRAY,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a list of columns kept. 
  -- 
  -- Parameters:
  --   rule name:      The name of the rule to add this functionality to.
  --   table_name:     The fully-qualified table name whose columns are to be
  --                   kept.  If the schema is not specified, the
  --                   invoker of the api will be used.   
  --   column_list:    The comma separated list of columns to keep.  
  --   value_type:     Whether to keep the old, new, or both columns
  --                   in the lcr.  Specify 'old', 'new', or '*'.
  --   step_number:    The order relative to other transformations.
  --   operation:      Specify 'ADD' to add this transformation, or
  --                   'REMOVE' to remove it.   
  PROCEDURE keep_columns(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    column_list        IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD'); 

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a column renamed. 
  -- 
  -- Parameters:
  --   rule name:        The name of the rule to add this functionality to.
  --   table_name:       The fully-qualified table name whose columns are to be
  --                     renamed.  If the schema is not specified, the
  --                     invoker of the api will be used.   
  --   from_column_name: The column to be renamed. 
  --   to_column_name:   The new column name.  
  --   value_type:       Whether to rename the old, new, or both
  --                     columns in the lcr.  Specify 'old', 'new', or '*'.
  --   step_number:      The order relative to other transformations.
  --   operation:        Specify 'ADD' to add this
  --                     transformation, or 'REMOVE' to remove it.  
  PROCEDURE rename_column(
    rule_name          IN VARCHAR2,
    table_name         IN VARCHAR2,
    from_column_name   IN VARCHAR2,
    to_column_name     IN VARCHAR2,
    value_type         IN VARCHAR2 DEFAULT '*',
    step_number        IN NUMBER DEFAULT 0,
    operation          IN VARCHAR2 DEFAULT 'ADD');   

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a column added.
  -- 
  -- Parameters:
  --   rule name:        The name of the rule to add this functionality to.
  --   table_name:       The fully-qualified table name whose columns are to be
  --                     renamed.  If the schema is not specified, the
  --                     invoker of the api will be used.   
  --   column_name:      The new name of the column. 
  --   column_value:     The value to place in this new column.  The
  --                     type of the column will be determined by the
  --                     type held within the AnyData.  For now, this
  --                     is limited to scalar values.   
  --   value_type:       Whether to add the old or new columns in the lcr.
  --                     Specify 'old' or 'new'.
  --   step_number:      The order relative to other transformations.
  --   operation:        Specify 'ADD' to add this
  --                     transformation, or 'REMOVE' to remove it.  
  PROCEDURE add_column(
    rule_name       IN VARCHAR2,
    table_name      IN VARCHAR2,
    column_name     IN VARCHAR2,
    column_value    IN SYS.ANYDATA,
    value_type      IN VARCHAR2 DEFAULT 'NEW',
    step_number     IN NUMBER DEFAULT 0,
    operation       IN VARCHAR2 DEFAULT 'ADD');  

  -- Specifies for the given rule that all lcrs with the specified
  -- schema and table will have a column added. 
  -- 
  -- Parameters:
  --   rule name:        The name of the rule to add this functionality to.
  --   table_name:       The fully-qualified table name whose columns are to
  --                     be renamed.  If the schema is not specified, the
  --                     invoker of the api will be used.   
  --   column_name:      The new name of the column.  
  --   column_function:  The name of a system built-in function whose
  --                     value we want to place in a new column
  --                     specified by column_name. For example, if we
  --                     specified 'SYSDATE' as the function name, we
  --                     would create a new column of type DATE
  --                     (determined by the function return value),
  --                     and place the result of SYSDATE into this
  --                     column. 
  --   value_type:       Whether to add the old or new columns in the lcr.
  --                     Specify 'old' or 'new'.
  --   step_number:      The order relative to other transformations.
  --   operation:        Specify 'ADD' to add this
  --                     transformation, or 'REMOVE' to remove it.  
  PROCEDURE add_column(
    rule_name       IN VARCHAR2,
    table_name      IN VARCHAR2,
    column_name     IN VARCHAR2,
    column_function IN VARCHAR2,
    value_type      IN VARCHAR2 DEFAULT 'NEW',
    step_number     IN NUMBER DEFAULT 0,
    operation       IN VARCHAR2 DEFAULT 'ADD');  

  PROCEDURE set_message_tracking(
    tracking_label  IN VARCHAR2 DEFAULT 'Streams_tracking',
    actions         IN NUMBER   DEFAULT action_memory);

  FUNCTION get_message_tracking RETURN VARCHAR2;

    --
  -- One step API to set up Streams replication environment, including source
  -- queue, capture process, destinaiton queue, apply process, and optionally,
  -- propagation for change data capture (CDC). The one-step API constructs a
  -- DDL string to create a change table at the destination database, creates a
  -- capture process to capture changes to source table at the source database
  -- and creates an apply process to apply
  -- changes to the change table at the destination database.
  --
  -- Parameters
  --
  -- change_table_name      : Name of change table
  -- source_table_name      : Name of source table
  -- column_type_list       : A comma-separated list of columns and datatypes
  --                          for the change table
  -- extra_column_list      : A comma-separated list LCR attributes to include
  --                          in the change table
  -- capture_values         : 'OLD', 'NEW', or '*'(BOTH)
  -- options_string         : The syntactically correct options to be passed
  --                          to a CREATE TABLE DDL statement. The string is
  --                          appended to the generated CREATE TABLE DDL
  --                          statement after the closing parenthesis that
  --                          defines the columns of the table.
  -- script_name            : Name of the script file to be generated
  -- script_directory_object: The directory object for the directory on the
  --                          local computer system into which the generated
  --                          script is placed.
  -- perform_actions        : Whether to execute generate script?
  -- capture_name           : Name of capture process
  -- propagation_name       : Name of propagation
  -- apply_name             : Name of apply process
  -- source_database        : Name of source database
  -- destination_database   : Name of destination database
  -- keep_columns           : Whether the LCR only keeps the specified columns,
  --                          including column from column_type_list and
  --                          extra_column_list
  --
  PROCEDURE maintain_change_table(
    change_table_name        VARCHAR2,
    source_table_name        VARCHAR2,
    column_type_list         VARCHAR2,
    extra_column_list        VARCHAR2 DEFAULT 'COMMAND_TYPE, VALUE_TYPE',
    capture_values           VARCHAR2,
    options_string           VARCHAR2 DEFAULT NULL,
    script_name              VARCHAR2 DEFAULT NULL,
    script_directory_object  VARCHAR2 DEFAULT NULL,
    perform_actions          BOOLEAN  DEFAULT TRUE,
    capture_name             VARCHAR2 DEFAULT NULL,
    propagation_name         VARCHAR2 DEFAULT NULL,
    apply_name               VARCHAR2 DEFAULT NULL,
    source_database          VARCHAR2 DEFAULT NULL,
    destination_database     VARCHAR2 DEFAULT NULL,
    keep_change_columns_only BOOLEAN  DEFAULT TRUE,
    execute_lcr              BOOLEAN  DEFAULT FALSE);

  -- sets the binary tag for all LCRs subsequently generated by the
  -- current session. Each LCR created by DML or DDL statement
  -- in the current session will have this tag.
  -- this procedure is not transactional and not affected by rollback
  -- Note: the invoker of set_tag should have execute privilege on
  --       dbms_streams_adm or execute_catalog_role
  PROCEDURE set_tag(tag IN RAW DEFAULT NULL);

  -- get the binary tag for all LCRs generated by the current session.
  -- Note: the invoker of get_tag should have execute privilege on
  --       dbms_streams_adm or execute_catalog_role
  FUNCTION get_tag RETURN RAW;

END dbms_streams_adm;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_adm FOR sys.dbms_streams_adm
/
GRANT EXECUTE ON sys.dbms_streams_adm TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_streams_messaging AUTHID CURRENT_USER AS 

  -------------
  -- CONSTANTS

  -- constats for wait parameter in dequque
  forever          CONSTANT BINARY_INTEGER := -1;
  no_wait          CONSTANT BINARY_INTEGER :=  0;

  -------------
  -- EXCEPTIONS
  endofcurtrans EXCEPTION;
  PRAGMA exception_init(endofcurtrans,  -25235);

  nomoremsgs    EXCEPTION;
  PRAGMA exception_init(nomoremsgs, -25228);


PROCEDURE enqueue(
  queue_name        IN  VARCHAR2,
  payload           IN  SYS.ANYDATA);

PROCEDURE enqueue(
  queue_name        IN  VARCHAR2,
  payload           IN  SYS.ANYDATA,
  msgid             OUT RAW);

-- queue_name: name of the queue. The queue must be a secure queue.
-- payload: the payload to be enqueued.
-- msgid: message ID returned. An overloaded procedure does not have this OUT
--   parameter.

PROCEDURE dequeue(
  queue_name     IN  VARCHAR2,
  streams_name   IN  VARCHAR2,
  payload        OUT SYS.ANYDATA,
  dequeue_mode   IN  VARCHAR2 DEFAULT 'REMOVE',
  navigation     IN  VARCHAR2 DEFAULT 'NEXT MESSAGE',
  wait           IN  BINARY_INTEGER DEFAULT FOREVER);

PROCEDURE dequeue(
  queue_name     IN  VARCHAR2,
  streams_name   IN  VARCHAR2,
  payload        OUT SYS.ANYDATA,
  dequeue_mode   IN  VARCHAR2 DEFAULT 'REMOVE',
  navigation     IN  VARCHAR2 DEFAULT 'NEXT MESSAGE',
  wait           IN  BINARY_INTEGER DEFAULT FOREVER,
  msgid          OUT RAW);

--  queue_name: name of the queue. The queue must be a secure queue.
--  streams_name: name of the stream
--  dequeue_mode: one of 'REMOVE', 'LOCKED', 'BROWSE'.
--  navigation: one of 'FIRST MESSAGE', 'NEXT MESSAGE', 'NEXT TRANSACTION'
--  payload: the payload to be dequeued.
--  msgid: message ID returned. An overloaded procedure does not have this
--    OUT parameter.
 
END dbms_streams_messaging;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_messaging
  FOR dbms_streams_messaging
/
GRANT EXECUTE ON sys.dbms_streams_messaging TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_streams_auth AUTHID CURRENT_USER AS 

-- Grants the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee          - the user to whom privileges are granted
--   grant_privileges - should the privileges be granted ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
-- OUTPUT:
--   If grant_privileges is true, then grantee is added to 
--     DBA_STREAMS_ADMINISTRATOR with LOCAL_PRIVILEGES set to YES.
--   If grant_privileges is false, the grant statements are not executed.
--   If file_name is not null, then the script is written to it.
-- NOTES:
--   An error is raised if grant_privileges is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If grant_privileges is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE grant_admin_privilege(
  grantee          IN VARCHAR2,
  grant_privileges IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL);

-- Revokes the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee           - the user from whom the privileges are revoked
--   revoke_privileges - should the privileges be revoked ?
--   file_name         - name of the file to which the script will be written
--   directory_name    - the directory where the file will be written
-- OUTPUT:
--   If revoke_privileges is true, then set LOCAL_PRIVILEGES to NO for user in
--   DBA_STREAMS_ADMINISTRATOR.  If user also does not allow ACCESS_FROM_REMOTE
--   then remove entry for user from DBA_STREAMS_ADMINISTRATOR.
--     DBA_STREAMS_ADMINISTRATOR.
--   If revoke_privileges is false, the revoke statements are not executed.
--   If file_name is not null, then the script is written to it.
-- NOTES:
--   An error is raised if revoke_privileges is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If revoke_privileges is true, each statement is appended to the script 
--     only if it executed successfully.
PROCEDURE revoke_admin_privilege(
  grantee           IN VARCHAR2,
  revoke_privileges IN BOOLEAN DEFAULT TRUE,
  file_name         IN VARCHAR2 DEFAULT NULL,
  directory_name    IN VARCHAR2 DEFAULT NULL);

-- Grantss the privileges that allow a Streams administrator at another
-- database to perform remote Streams administration at this database
-- using the grantee through a database link.
-- INPUT:
--   grantee          - the user to whom privileges are granted
-- OUTPUT:
--   grantee is added to DBA_STREAMS_ADMINISTRATOR with ACCESS_FROM_REMOTE
--   set to YES.
PROCEDURE grant_remote_admin_access(grantee    IN VARCHAR2);

-- Revokes the privileges that allow a Streams administrator at another
-- database to perform remote Streams administration at this database
-- using the grantee through a database link.
-- INPUT:
--   grantee          - the user from whom the privileges are revoked
-- OUTPUT:
--   set ACCESS_FROM_REMOTE to NO for user in DBA_STREAMS_ADMINISTRATOR.
--   if user also does not have LOCAL_PRIVILEGES then remove entry for
--   user from DBA_STREAMS_ADMINISTRATOR.
PROCEDURE revoke_remote_admin_access(grantee    IN VARCHAR2);

END dbms_streams_auth;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_auth FOR sys.dbms_streams_auth
/
GRANT EXECUTE ON sys.dbms_streams_auth TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_streams_advisor_adm AUTHID CURRENT_USER AS 

  -- Retention time for keeping statistics collected. Default 24 hours.
  retention_time NUMBER := 24;

  -------------------------------------------------------------
  -- PACKAGE VARIABLES
  -------------------------------------------------------------
  -- A streams component is eligible for bottleneck analysis only if its
  -- busiest session has statistic IDLE (in percentage) not greater than
  -- the specified "bottleneck_idle_threshold" and statistic FLOW CONTROL 
  -- (in percentage) not greater than "bottleneck_flowctrl_threshold".
  --
  -- By default, a component cannot be bottleneck if its busiest session
  -- is idle or in flow control for more than 50 percent of the measured
  -- time period.
  bottleneck_idle_threshold NUMBER := 50;
  bottleneck_flowctrl_threshold NUMBER := 50;

  -------------------------------------------------------------
  -- CONSTANTS
  -------------------------------------------------------------
  -- component type constant, should be consistent with constants defined
  -- for  _DBA_STREAMS_COMPONENT in drep.bsq
  capture_type              CONSTANT NUMBER := 1;
  propagation_sender_type   CONSTANT NUMBER := 2;
  propagation_receiver_type CONSTANT NUMBER := 3;
  apply_type                CONSTANT NUMBER := 4;
  queue_type                CONSTANT NUMBER := 5;
  
  -- Analyzes performance on a given system, including calculating the
  -- bottleneck components of each streams, the rate of each component on that
  -- streams, and, if specified, recommendations on how to improve performance
  -- Parameters
  --   component_name: analyze streams containing the component with this name
  --   component_db  : analyze streams containing the component with this
  --                   database name
  --   component_type: analyze streams containing the component of this type
  -- NOTE: component_name, component_type, and component_db MUST all be 
  --       specified or NULL
  --
  PROCEDURE analyze_current_performance(
    component_name  IN  VARCHAR2 DEFAULT NULL,
    component_db    IN  VARCHAR2 DEFAULT NULL,
    component_type  IN  NUMBER   DEFAULT NULL);

END dbms_streams_advisor_adm;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_advisor_adm FOR 
  sys.dbms_streams_advisor_adm
/
GRANT EXECUTE ON sys.dbms_streams_advisor_adm TO execute_catalog_role
/

-- Package dbms_streams_handler_adm
CREATE OR REPLACE PACKAGE dbms_streams_handler_adm AUTHID CURRENT_USER AS
  
  -- Create a stmt handler
  PROCEDURE create_stmt_handler(
    handler_name       IN VARCHAR2,
    comment            IN VARCHAR2 DEFAULT NULL);
  
  -- Drop a stmt handler
  PROCEDURE drop_stmt_handler(
    handler_name       IN VARCHAR2);
  
  -- Add a stmt to handler
  PROCEDURE add_stmt_to_handler(
    handler_name       IN VARCHAR2,
    statement          IN CLOB,
    execution_sequence IN NUMBER DEFAULT NULL);
  
  -- Remove a stmt from handler
  PROCEDURE remove_stmt_from_handler(
    handler_name       IN VARCHAR2,
    execution_sequence IN NUMBER DEFAULT NULL);

END dbms_streams_handler_adm;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_handler_adm FOR 
  sys.dbms_streams_handler_adm
/
GRANT EXECUTE ON sys.dbms_streams_handler_adm TO execute_catalog_role
/

Rem Streams Apply package spec
@@dbmsapp.sql

Rem Streams Capture package spec
@@dbmscap.sql

Rem Streams Propagation package spec
@@dbmsprp.sql

Rem DBMS File Group
@@dbmsfgr.sql

Rem DBMS Data Comparison
@@dbmscmp.sql

Rem DBMS XStream package
@@dbmsxstr.sql

----------------------------------------------------------------------
-- Add Private Package Headers
----------------------------------------------------------------------

Rem package specifications
@@prvthlcr.plb

Rem Recoverable Script Execution headers
@@prvthrse.plb

Rem Streams MainTain headers
@@prvthsmt.plb

Rem Streams Split and Merge headers
@@prvthssm.plb

Rem Streams automatic internal headers
@@prvthsai.plb

Rem Streams stmt handler adm header
@@prvthsha.plb

Rem Apply DML Handler header
@@prvthhdlr.plb

Rem Streams, Apply, Capture and Propagation headers
@@prvthstr.plb
@@prvthapp.plb
@@prvthcap.plb
@@prvthprp.plb

Rem Streams Performance Advisor headers
@@prvthspa.plb

Rem Log-based replication Rpc Utility headers
@@prvthlru.plb

Rem Streams RPc headers
@@prvthsrp.plb

Rem Streams Change Data Capture headers
@@prvthcdc.plb

Rem Streams Switch Checkpoint-Free/Checkpoints header
@@prvthscp.plb

Rem Private XStream header
@@prvthxstr.plb

Rem Private Maintina_change_table header
@@prvthsmc.plb
