Rem
Rem $Header: dbmsdst.sql 29-apr-2008.10:45:35 huagli Exp $
Rem
Rem dbmsdst.sql
Rem
Rem Copyright (c) 2007, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsdst.sql -  utilities for DST patching on TIMESTAMP WITH TZ data
Rem
Rem    DESCRIPTION
Rem      See below
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huagli      04/29/08 - comments clean-up
Rem    huagli      11/21/07 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_dst AUTHID CURRENT_USER IS

  ------------
  --  OVERVIEW
  --
  --  These routines allow the user to apply Daylight Saving Time (DST) 
  --  patch to TIMESTAMP WITH TIME ZONE (TSTZ) data type

  ------------------------------------------------
  --  SUMMARY OF SERVICES PROVIDED BY THE PACKAGE
  --
  --  begin_upgrade         - begin upgrade process
  --  end_upgrade           - complete the upgrade process 
  --  begin_prepare         - begin the prepare window to check what tables
  --                          will be affected by the upgrade
  --  end_prepare           - complete the prepare window 
  --  upgrade_table         - upgrade a list of tables with column(s) defined
  --                          on TSTZ type or ADT containing TSTZ type
  --  upgrade_schema        - upgrade all tables with column(s) defined on
  --                          TSTZ type or ADT containing TSTZ type in a 
  --                          list of schemas
  --  find_affected_tables  - check all tables with TSTZ data during prepare
  --                          window and indicate which tables need upgrade
  --  create_errors_table   - create an error table for logging upgrade errors
  --  create_affected_table - create an affected table to discover tables
  --                          which need to be upgraded during prepare window
  --  create_trigger_table  - create a trigger table for logging triggers
  --                          which were disabled during upgrade process, but
  --                          not enabled after finishing upgrade
  --  load_secondary        - load secondary TZ data file
  --  unload_secondary      - unload secondary TZ data file
  
  
  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  --  -----------------------------------------------------------------------
  --  We have these general parameters:
  --  	
  --  TABLE_LIST
  --     A comma-separated list or PL/SQL table of the tables to be upgraded.
  --  UPGRADE_DATA
  --     A boolean flag indicating if TSTZ data should be converted
  --     using new Time Zone Data File (TRUE) or left uncoverted (FALSE).
  --     The default is TRUE.
  --  CONTINUE_AFTER_ERRORS
  --     A boolean flag indicating if we should continue after upgrade fails
  --     on the current table. 
  --     The default is TRUE.
  --  PARALLEL
  --     A boolean flag indicating if tables should be converted using 
  --     PDML (Parallel DML) or Serial DML.
  --     The default is FALSE.
  --  LOG_ERRORS
  --     A boolean flag indicating if we should log errors during upgrade. 
  --     If FALSE, any error will abort conversion of a current table and
  --     all upgrades to it will be rolled back. If TRUE, the error logged
  --     logged to log_errors_table and conversion will continue. Error
  --     logging internally uses Oracle Error logging.
  --     The default is FALSE.
  --  LOG_ERRORS_TABLE
  --     A table name with the following schema: 
  --      CREATE TABLE dst_error_table
  --      (
  --         table_owner   VARCHAR2(30),
  --         table_name    VARCHAR2(30),
  --         column_name   VARCHAR2(30),
  --         rid           urowid,
  --         error_number NUMBER
  --      )
  --    The table can be created with the create_errors_table procedure.
  --    The rid parameter records the rowids of the offending rows
  --    and the corresponding error number.
  --  ERROR_ON_OVERLAP_TIME
  --     A boolean flag indicating if we should report errors on the
  --     'overlap' time semantic conversion error. 
  --     The default is TRUE.
  --  ERROR_ON_NONEXISTING_TIME
  --     A boolean flag indicating if we should report errors on the
  --     'non-existing' time semantic conversion error. 
  --     The default is TRUE.
  --  ATOMIC_UPGRADE
  --     A boolean flag indicating if we should convert the listed
  --     tables atomically, i.e., in a single transaction. 
  --     If FALSE, each table is converted in its own transaction.
  --     The default is FALSE.
  --  NUM_OF_FAILURES
  --     A variable indicating how many tables fail to complete the upgrade
  --     process.
  --  

  ------------------------------- upgrade_table ----------------------------
  -- NAME: 
  --   upgrade_table
  --
  -- DESCRIPTION:
  --   This procedure upgrades a given list of tables, which have column(s)
  --   defined on TSTZ type or ADT containning TSTZ type. This procedure 
  --   can only be invoked after an upgrade window has been started. The
  --   table list has to satisfy the following partial ordering: 
  --   (1) a base table needs to have its materialized view log table 
  --       immediately followed by if there is any.
  --   (2) if the container table for a materialized view appears in the 
  --       given table list, the materialized view's 'non-upgraded' base  
  --       tables and log tables also need to appear in the table list 
  --       and before the container table
  --   Also, a base table and its materialized view table will be upgraded
  --   in an atomic transaction.
  --       
  -- PARAMETERS:
  --   num_of_failures           (OUT) - See above on general parameters
  --   table_list                (IN)  - Table name list (comma sep. str)
  --   upgrade_data              (IN)  - See above on general parameters
  --   parallel                  (IN)  - See above on general parameters
  --   continue_after_errors     (IN)  - See above on general parameters
  --   log_errors                (IN)  - See above on general parameters
  --   log_errors_table          (IN)  - See above on general parameters
  --   error_on_overlap_time	 (IN)  - See above on general parameters
  --   error_on_nonexisting_time (IN)  - See above on general parameters
  --   log_triggers_table        (IN)  - a table to log triggers which are
  --                                     disabled before upgrade, but not
  --                                     being enabled due to fatal failure
  --                                     when performing upgrade
  --   atomic_ugrade             (IN)  - See above on general parameters
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE upgrade_table(
     num_of_failures            OUT BINARY_INTEGER,
     table_list                 IN  VARCHAR2,
     upgrade_data               IN  BOOLEAN    := TRUE,
     parallel                   IN  BOOLEAN    := FALSE,
     continue_after_errors      IN  BOOLEAN    := TRUE,
     log_errors                 IN  BOOLEAN    := FALSE,
     log_errors_table           IN  VARCHAR2   := 'sys.dst$error_table',
     error_on_overlap_time	IN  BOOLEAN    := FALSE,
     error_on_nonexisting_time  IN  BOOLEAN    := FALSE,
     log_triggers_table         IN  VARCHAR2   := 'sys.dst$trigger_table',
     atomic_upgrade             IN  BOOLEAN    := FALSE);
  
  ------------------------------- upgrade_schema ---------------------------
  -- NAME: 
  --   upgrade_schema
  --
  -- DESCRIPTION:
  --   This procedure upgrades tables in given list of schemas, which have
  --   column(s) defined on TSTZ type or ADT containning TSTZ type. This
  --   procedure can only be invoked after an upgrade window has been
  --   started. Each table is upgraded in an atomic transaction. Note that, 
  --   a base table and its materialized view log table are upgraded in an
  --   atomic transaction.
  --
  -- PARAMETERS:
  --   num_of_failures           (OUT) - See above on general parameters
  --   schema_list               (IN)  - Schema name list (comma sep. str)
  --   upgrade_data              (IN)  - See above on general parameters
  --   parallel                  (IN)  - See above on general parameters
  --   continue_after_errors     (IN)  - See above on general parameters
  --   log_errors                (IN)  - See above on general parameters
  --   log_errors_table          (IN)  - See above on general parameters
  --   error_on_overlap_time	 (IN)  - See above on general parameters
  --   error_on_nonexisting_time (IN)  - See above on general parameters
  --   log_triggers_table        (IN)  - a table to log triggers which are
  --                                     disabled before upgrade, but not
  --                                     being enabled due to fatal failure
  --                                     when performing upgrade
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE upgrade_schema(
     num_of_failures           OUT BINARY_INTEGER,
     schema_list               IN  VARCHAR2,
     upgrade_data              IN  BOOLEAN    := TRUE,
     parallel                  IN  BOOLEAN    := FALSE,
     continue_after_errors     IN  BOOLEAN    := TRUE,
     log_errors                IN  BOOLEAN    := FALSE,
     log_errors_table          IN  VARCHAR2   := 'sys.dst$error_table',
     error_on_overlap_time     IN  BOOLEAN    := FALSE,
     error_on_nonexisting_time IN  BOOLEAN    := FALSE,
     log_triggers_table        IN  VARCHAR2   := 'sys.dst$trigger_table');

  ----------------------------- upgrade_database ---------------------------
  -- NAME: 
  --   upgrade_database
  --
  -- DESCRIPTION:
  --   This procedure upgrades all tables in the database, which have
  --   column(s) defined on TSTZ type or ADT type containning TSTZ type. 
  --   This procedure can only be invoked after an upgrade window has been 
  --   started. Each table is upgraded in an atomic transaction. Note that, 
  --   a base table and its materialized view log table are upgraded in an
  --   atomic transaction.
  --
  -- PARAMETERS:
  --   num_of_failures           (OUT) - See above on general parameters
  --   upgrade_data              (IN)  - See above on general parameters
  --   parallel                  (IN)  - See above on general parameters
  --   continue_after_errors     (IN)  - See above on general parameters
  --   log_errors                (IN)  - See above on general parameters
  --   log_errors_table          (IN)  - See above on general parameters
  --   error_on_overlap_time	 (IN)  - See above on general parameters
  --   error_on_nonexisting_time (IN)  - See above on general parameters
  --   log_triggers_table        (IN)  - a table to log triggers which are
  --                                     disabled before upgrade, but not
  --                                     being enabled due to fatal failure
  --                                     when performing upgrade
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE upgrade_database(
     num_of_failures           OUT BINARY_INTEGER,
     upgrade_data              IN  BOOLEAN    := TRUE,
     parallel                  IN  BOOLEAN    := FALSE, 
     continue_after_errors     IN  BOOLEAN    := TRUE,
     log_errors                IN  BOOLEAN    := FALSE,
     log_errors_table          IN  VARCHAR2   := 'sys.dst$error_table',
     error_on_overlap_time     IN  BOOLEAN    := FALSE,
     error_on_nonexisting_time IN  BOOLEAN    := FALSE,
     log_triggers_table        IN  VARCHAR2   := 'sys.dst$trigger_table');

  ------------------------------- begin_upgrade ----------------------------
  -- NAME: 
  --   begin_upgrade
  --
  -- DESCRIPTION:
  --   This procedure starts an upgrade window. Once an upgraded window
  --   is started successfully, TSTZ data in dictionary tables have been
  --   upgraded to reflect the new timezone version. Also, database property 
  --   'DST_UPGRADE_STATE' is set to 'UPGRADE'. Database property 
  --   'SECONDARY_TT_VERSION' is set to new timezone version. After an upgrade
  --   is started successfully, DB has to be restarted. After the restart,
  --   Database property 'PRIMARY_TT_VERSION' is the new timezone version and 
  --   'SECONDARY_TT_VERSION' is the old timezone version.
  --
  -- PARAMETERS:
  --   new_version               (IN) - new timezone version
  --   error_on_overlap_time     (IN) - report errors on overlap time?
  --   error_on_nonexisting_time (IN) - report errors on non-existing time?
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE begin_upgrade(
     new_version               IN BINARY_INTEGER, 
     error_on_overlap_time     IN  BOOLEAN    := FALSE,
     error_on_nonexisting_time IN  BOOLEAN    := FALSE);

  -------------------------------- end_upgrade -----------------------------
  -- NAME: 
  --   end_upgrade
  --
  -- DESCRIPTION:
  --   This procedure ends an upgrade window. An upgraded window will be
  --   ended if all the affected user tables have been upgraded. Otherwise,
  --   OUT parameter num_of_failures will indicate how many tables have not
  --   been converted yet.
  --
  --
  -- PARAMETERS:
  --   num_of_failures       (OUT) - See above on general parameters
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE end_upgrade(num_of_failures OUT BINARY_INTEGER);

  ------------------------------- begin_prepare ----------------------------
  -- NAME: 
  --   begin_prepare
  --
  -- DESCRIPTION:
  --   This procedure starts a prepare window. Once a prepare window
  --   is started successfully, Database property 'DST_UPGRADE_STATE' is
  --   set to 'PREPARE'. Database property 'SECONDARY_TT_VERSION' is set 
  --   to new timezone version.
  --
  -- PARAMETERS:
  --   new_version       (IN) - The new timezone version to be prepared to
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE begin_prepare(new_version IN BINARY_INTEGER);

  -------------------------------- end_prepare -----------------------------
  -- NAME: 
  --   end_prepare
  --
  -- DESCRIPTION:
  --   This procedure ends a prepare window.
  --
  -- PARAMETERS:
  --   NONE
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE end_prepare;

  --------------------------- find_affected_tables -------------------------
  -- NAME: 
  --   find_affected_tables
  --
  -- DESCRIPTION:
  --   This procedure finds all the tables which have affected TSTZ data
  --   due to the new timezone version. This procedure can only be invoked
  --   during a prepare window. The tables which have affected TSTZ data
  --   are recorded into a table indicated by parameter affected_tables.
  --   If semantic errors need to be logged, they will be recorded into a
  --   table indicated by parameter log_error_table.
  --
  -- PARAMETERS:
  --   affected_tables  (IN) -  A table name with the following schema: 
  --                            CREATE TABLE dst$affected_tables
  --                            (
  --                              table_owner   VARCHAR2(30),
  --                              table_name    VARCHAR2(30),
  --                              row_count     NUMBER,
  --                              error_count   NUMBER
  --                            )
  --                            The table can be created with the 
  --                            create_affected_table procedure.
  --   log_errors       (IN) -  See above on general parameters
  --   log_errors_table (IN) -  See above on general parameters
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE find_affected_tables(
    affected_tables       IN  VARCHAR2 := 'sys.dst$affected_tables',
    log_errors            IN  BOOLEAN  := FALSE,
    log_errors_table      IN  VARCHAR2 := 'sys.dst$error_table');

  --------------------------- create_affected_table ------------------------
  -- NAME: 
  --   create_affected_table
  --
  -- DESCRIPTION:
  --   This procedure creates a table which has the schema as shown in the 
  --   comments for procedure find_affected_tables. 
  --
  -- PARAMETERS:
  --   table_name  (IN) -  The name of the  table to be created
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE create_affected_table(table_name IN VARCHAR2);

  ----------------------------- create_error_table -------------------------
  -- NAME: 
  --   create_error_table
  --
  -- DESCRIPTION:
  --   This procedure creates a table which has the schema as shown in the 
  --   comments for general paramters
  --
  -- PARAMETERS:
  --   table_name  (IN) -  The name of the  table to be created
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE create_error_table(table_name IN VARCHAR2);

  ----------------------------- create_trigger_table -----------------------
  -- NAME: 
  --   create_trigger_table
  --
  -- DESCRIPTION:
  --   This procedure creates a table which has the following schema. This
  --   table is used to record active triggers which are disabled before
  --   performing upgrade on the table, but not being enabled due to fatal 
  --   failure during the upgrading process itself.
  -- 
  --   CREATE TABLE dst_trigger_table
  --      (
  --         trigger_owner   VARCHAR2(30),
  --         trigger_name    VARCHAR2(30)
  --      )
  -- PARAMETERS:
  --   table_name  (IN) -  The name of the  table to be created
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE create_trigger_table(table_name IN VARCHAR2);

  ------------------------------ load_secondary ----------------------------
  -- NAME: 
  --   load_secondary
  --
  -- DESCRIPTION:
  --   This procedure loads the secondary timezone data file into SGA. 
  --   In RAC, a Cross Instance Call is made to notify all other nodes in 
  --   the cluster to load the secondary timezone transition table into their
  --   own SGA as well. Database property 'DST_UPGRADE_STATE' is either set to 
  --   'ON_DEMAND' or if it is a data pump job, set to 'DATAPUMP(i)' - i is
  --   the counter for data pump jobs. Also, database property 
  --   'SECONDARY_TT_VERSION' is set to the timezone version of the loaded
  --   secondary timezone data file when it is on-demand loading or the
  --   first data pump job loading. Note that, if current 'DST_UPGRADE_STATE'
  --   is 'DATAPUM(i)' and a new data pump job is requesting a different
  --   secondary TZ version than the existing data pump jobs, we will not 
  --   allow it.
  --
  -- PARAMETERS:
  --   sec_version       (IN) - The secondary timezone version to be loaded

  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE load_secondary(sec_version IN BINARY_INTEGER);

  ---------------------------- unload_secondary ----------------------------
  -- NAME: 
  --   unload_secondary
  --
  -- DESCRIPTION:
  --   This procedure unloads the secondary timezone data file from SGA. 
  --   In RAC, a Cross Instance Call is made to notify all other nodes in 
  --   the cluster to unload the secondary timezone transition table from 
  --   their own SGA as well. Also, database property 'DST_UPGRADE_STATE' 
  --   is set to 'NORMAL' or 'DATAPUMP(i-1)' (if the caller is a data pump 
  --   job where i > 1) and database property 'SECONDARY_TT_VERSION' is 
  --   set to 0 when 'DST_UPGRADE_STATE' is set to 'NORMAL'.
  --
  -- PARAMETERS:
  --   NONE
  --
  -- RETURN:
  --     VOID 
  --------------------------------------------------------------------------
  PROCEDURE unload_secondary;

END dbms_dst;
/
GRANT EXECUTE ON dbms_dst TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_dst FOR dbms_dst
/

