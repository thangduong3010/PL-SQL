Rem
Rem $Header: rdbms/admin/dbmscap.sql /main/21 2010/02/08 16:06:06 yurxu Exp $
Rem
Rem dbmscap.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscap.sql - streams CAPture
Rem
Rem    DESCRIPTION
Rem      This package contains APIs for Streams capture administration
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yurxu       12/24/09 - Bug-9216647: add start_time in alter_capture
Rem    juyuan      01/13/10 - remove wait_for_inflight_txns parameter
Rem    juyuan      11/16/09 - fix bug 9176560: build waits for inflight txns
Rem    yurxu       11/11/09 - add start_time parameter in create_capture
Rem    praghuna    12/07/07 - set_parameter prototype change
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    thoang      05/04/05 - support synchronous capture 
Rem    htran       10/27/04 - support adding supplemental logging for prepare
Rem    nshodhan    06/29/04 - lrg 1713076 
Rem    nshodhan    06/11/04 - add checkpoint_retention_time
Rem    alakshmi    03/06/03 - add capture_user
Rem    htran       11/04/02 - change drop_unused_rule_set param to
Rem                           drop_unused_rule_sets
Rem    htran       09/18/02 - add drop_unused_rule_set parameter
Rem                           to drop_capture
Rem    nshodhan    09/15/02 - use_dblink -> use_database_link
Rem    elu         08/20/02 - add negative rule sets
Rem    nshodhan    08/15/02 - create_capture : add logfile_assignment
Rem    liwong      07/22/02 - Extend LCR support
Rem    liwong      07/09/02 - Add exceptions, enhance alter_capture
Rem    nshodhan    07/02/02 - Add build()
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    wesmith     11/15/01 - make dbms_capture_adm invoker's rights pkg
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    wesmith     10/24/01 - alter_capture(): add remove_rule_set
Rem    wesmith     10/23/01 - Created
Rem

--
-- External package for capture administration
--
CREATE OR REPLACE PACKAGE dbms_capture_adm AUTHID CURRENT_USER AS

  -------------
  -- CONSTANTS
  infinite           CONSTANT NUMBER := 4294967295; 

  -------------
  -- EXCEPTIONS
  create_capture_proc EXCEPTION;
    PRAGMA exception_init(create_capture_proc, -26678);
    create_capture_proc_num NUMBER := -26678;

  inv_sync_capture_proc EXCEPTION;
    PRAGMA exception_init(inv_sync_capture_proc, -25338);
    inv_sync_capture_proc_num   NUMBER := -25338;

  exp_sync_capture      EXCEPTION;
    PRAGMA exception_init(exp_sync_capture, -25339);
    exp_sync_capture_num   NUMBER := -25339;

  -- prototype procedure for starting a capture process
  PROCEDURE start_capture(capture_name IN VARCHAR2);

  -- prototype procedure for stopping a capture process
  PROCEDURE stop_capture(capture_name IN VARCHAR2,
                         force        IN BOOLEAN DEFAULT FALSE);

  -- procedure for setting capture process parameters
  -- value=NULL will set the parameter to its default value.
  PROCEDURE set_parameter(capture_name IN VARCHAR2,
                          parameter    IN VARCHAR2,
                          value        IN VARCHAR2 DEFAULT NULL);

/*----------------------------------------------------------------------------
NAME
  create_capture()
FUNCTION
  Creates capture process 
PARAMETERS
  queue_name                (IN) - name of the queue
  capture_name              (IN) - name of the capture process
  rule_set_name             (IN) - name of the positive rule set
  start_scn                 (IN) - scn from which changes should be captured
  source_database           (IN) - global name of the source database
  use_database_link         (IN) - downstream capture: is db_link to source 
                                   available?
  first_scn                 (IN) - scn from which dictionary dump starts
  logfile_assignment        (IN) - type of logfile assignment: implicit or 
                                   explicit
  negative_rule_set_name    (IN) - name of the negative rule set
  capture_user              (IN) - capture user
  checkpoint_retention_time (IN) - checkpoint retention time in # of days
  start_time                (IN) - capture start time
NOTES
  - replaces dbms_aqadm.add_publisher()
  - this procedure commits
----------------------------------------------------------------------------*/
  PROCEDURE create_capture(
    queue_name                IN VARCHAR2,
    capture_name              IN VARCHAR2,
    rule_set_name             IN VARCHAR2 DEFAULT NULL,
    start_scn                 IN NUMBER   DEFAULT NULL,
    source_database           IN VARCHAR2 DEFAULT NULL,
    use_database_link         IN BOOLEAN  DEFAULT FALSE,
    first_scn                 IN NUMBER   DEFAULT NULL,
    logfile_assignment        IN VARCHAR2 DEFAULT 'IMPLICIT',
    negative_rule_set_name    IN VARCHAR2 DEFAULT NULL,
    capture_user              IN VARCHAR2 DEFAULT NULL,
    checkpoint_retention_time IN NUMBER   DEFAULT 60,
    start_time                IN TIMESTAMP DEFAULT NULL);

/*----------------------------------------------------------------------------
NAME
  alter_capture()
FUNCTION
  Alters capture process ruleset, start scn or capture_user
PARAMETERS
  capture_name              (IN)
  rule_set_name             (IN)
  remove_rule_set           (IN)
  start_scn                 (IN)
  use_database_link         (IN)
  use_dblink                (IN)
  first_scn                 (IN)
  negative_rule_set_name    (IN)
  remove_negative_rule_set  (IN)
  capture_user              (IN)
  checkpoint_retention_time (IN) 
  start_time                (IN) - capture start time
NOTES
  - replaces dbms_aqadm.alter_publisher()
  - a NULL value for rule_set_name, negative_rule_set_name, start_scn or
    capture_user means it is not altered
  - remove_rule_set must be either TRUE or FALSE
  - if remove_rule_set is TRUE, then the existing rule set will be removed
  - remove_rule_set can be TRUE only if rule_set_name is NULL
  - if remove_negative_rule_set is TRUE, then any existing negative rule
    set will be removed
  - remove_negative_rule_set can be TRUE only if negative_rule_set_name is NULL
  - this procedure first commits any existing user transaction,
    then commits all metadata changes
----------------------------------------------------------------------------*/
  PROCEDURE alter_capture(capture_name              IN VARCHAR2,
                          rule_set_name             IN VARCHAR2  DEFAULT NULL,
                          remove_rule_set           IN BOOLEAN   DEFAULT FALSE,
                          start_scn                 IN NUMBER    DEFAULT NULL,
                          use_database_link         IN BOOLEAN   DEFAULT NULL,
                          first_scn                 IN NUMBER    DEFAULT NULL,
                          negative_rule_set_name    IN VARCHAR2  DEFAULT NULL,
                          remove_negative_rule_set  IN BOOLEAN   DEFAULT FALSE,
                          capture_user              IN VARCHAR2  DEFAULT NULL,
                          checkpoint_retention_time IN NUMBER    DEFAULT NULL,
                          start_time                IN TIMESTAMP DEFAULT NULL);

/*----------------------------------------------------------------------------
NAME
  drop_capture()
FUNCTION
  Drops capture process 
PARAMETERS
  capture_name          (IN)
  drop_unused_rule_sets (IN)
NOTES
  - replaces dbms_aqadm.remove_publisher()
  - this procedure commits
----------------------------------------------------------------------------*/
  PROCEDURE drop_capture(capture_name IN VARCHAR2,
                         drop_unused_rule_sets IN BOOLEAN DEFAULT FALSE);

/*----------------------------------------------------------------------------
NAME
  prepare_table_instantiation()
FUNCTION
  procedure to prepare a table for instantiation at the source DB
PARAMETERS
  supplemental_logging   - (IN)  supplemental logging level
                                 ('NONE', 'KEYS', or 'ALL')
NOTES
  KEYS means PRIMARY KEY, UNIQUE INDEX, and FOREIGN KEY levels combined.
----------------------------------------------------------------------------*/
  PROCEDURE prepare_table_instantiation(
    table_name                IN VARCHAR2,
    supplemental_logging      IN VARCHAR2 DEFAULT 'KEYS');

/*----------------------------------------------------------------------------
NAME
  prepare_schema_instantiation()
FUNCTION
  prepare a schema for instantiation
PARAMETERS
  schema_name            - (IN)  the name of the schema to prepare
  supplemental_logging   - (IN)  supplemental logging level
                                 ('NONE', 'KEYS', or 'ALL')
NOTES
  KEYS means PRIMARY KEY, UNIQUE INDEX, and FOREIGN KEY levels combined.
----------------------------------------------------------------------------*/
  PROCEDURE prepare_schema_instantiation(
    schema_name               IN VARCHAR2,
    supplemental_logging      IN VARCHAR2 DEFAULT 'KEYS');

/*----------------------------------------------------------------------------
NAME
  prepare_global_instantiation()
FUNCTION
  prepare a database for instantiation
PARAMETERS
  supplemental_logging   - (IN)  supplemental logging level
                                 ('NONE', 'KEYS', or 'ALL')
NOTES
  KEYS means PRIMARY KEY, UNIQUE INDEX, and FOREIGN KEY levels combined.
----------------------------------------------------------------------------*/
  PROCEDURE prepare_global_instantiation(
    supplemental_logging       IN VARCHAR2 DEFAULT 'KEYS');

/*----------------------------------------------------------------------------
NAME
  abort_table_instantiation()
FUNCTION
  undo prepare_table_instantiation
PARAMETERS
  table_name   - (IN)  the table name to abort the prepare
NOTES
----------------------------------------------------------------------------*/
  PROCEDURE abort_table_instantiation(table_name IN VARCHAR2);

/*----------------------------------------------------------------------------
NAME
  abort_schema_instantiation()
FUNCTION
  undo prepare_schema_instantiation
PARAMETERS
  schema_name   - (IN)  the schema name to abort the prepare
NOTES
----------------------------------------------------------------------------*/
  PROCEDURE abort_schema_instantiation(schema_name IN VARCHAR2);

/*----------------------------------------------------------------------------
NAME
  abort_global_instantiation()
FUNCTION
  undo prepare_global_instantiation
PARAMETERS
NOTES
----------------------------------------------------------------------------*/
  PROCEDURE abort_global_instantiation;

  PROCEDURE include_extra_attribute(
                          capture_name        IN VARCHAR2,
                          attribute_name      IN VARCHAR2,
                          include             IN BOOLEAN DEFAULT TRUE);

  -- procedure for obtaining dictionary dump at the source database
  PROCEDURE build;

  -- procedure for obtaining dictionary dump at the source database
  PROCEDURE build (first_scn OUT NUMBER);
  
/*----------------------------------------------------------------------------
NAME
  create_sync_capture()
FUNCTION
  Creates sync capture process. If the specified capture_name is 
  already being used by an existing synchronous or asynchronous capture, 
  then an error will be raised. 
PARAMETERS
  queue_name                (IN) - name of the queue
  capture_name              (IN) - name of the sync capture process
  rule_set_name             (IN) - name of the positive rule set
  capture_user              (IN) - capture user
NOTES
  - this procedure commits
  - A valid rule_set_name must be specified
----------------------------------------------------------------------------*/
  PROCEDURE create_sync_capture(
    queue_name                IN VARCHAR2,
    capture_name              IN VARCHAR2,
    rule_set_name             IN VARCHAR2,
    capture_user              IN VARCHAR2 DEFAULT NULL);

/*----------------------------------------------------------------------------
NAME
  alter_sync_capture()
FUNCTION
  Alters sync capture process ruleset or capture_user
PARAMETERS
  capture_name              (IN) - name of the sync capture process
  rule_set_name             (IN) - name of the positive rule set
  capture_user              (IN) - capture user
NOTES
  - capture_name must be a sync capture; otherwise, an error will be
    raised.
  - a NULL value for rule_set_name or capture_user means it is not altered
  - this procedure first commits any existing user transaction,
    then commits all metadata changes
----------------------------------------------------------------------------*/
  PROCEDURE alter_sync_capture(capture_name  IN VARCHAR2,
                          rule_set_name             IN VARCHAR2  DEFAULT NULL,
                          capture_user              IN VARCHAR2  DEFAULT NULL);

/*----------------------------------------------------------------------------
NAME
  prepare_sync_instantiation()
FUNCTION
  procedure to prepare a list of tables for instantiation at the source DB
PARAMETERS
  table_names   - (IN)  - list of comma-separated table names 
RETURNS
  The instantiation SCN
----------------------------------------------------------------------------*/
  FUNCTION prepare_sync_instantiation(
    table_names    IN VARCHAR2) RETURN NUMBER;

/*----------------------------------------------------------------------------
NAME
  abort_sync_instantiation()
FUNCTION
  undo prepare_sync_instantiation
PARAMETERS
  table_name   - (IN)  the table name to abort the prepare
NOTES
----------------------------------------------------------------------------*/
  PROCEDURE abort_sync_instantiation(table_names IN VARCHAR2);

/*----------------------------------------------------------------------------
NAME
  prepare_sync_instantiation()
FUNCTION
  procedure to prepare a list of tables for instantiation at the source DB
PARAMETERS
  table_names  - (IN)  - array of table names 
RETURNS
  The instantiation SCN
----------------------------------------------------------------------------*/
  FUNCTION prepare_sync_instantiation(
    table_names   IN DBMS_UTILITY.UNCL_ARRAY) RETURN NUMBER;

/*----------------------------------------------------------------------------
NAME
  abort_sync_instantiation()
FUNCTION
  undo prepare_sync_instantiation
PARAMETERS
  table_name   - (IN)  the table name to abort the prepare
NOTES
----------------------------------------------------------------------------*/
  PROCEDURE abort_sync_instantiation(table_names IN DBMS_UTILITY.UNCL_ARRAY);

END dbms_capture_adm;
/
GRANT EXECUTE ON dbms_capture_adm TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_capture_adm FOR dbms_capture_adm
/

