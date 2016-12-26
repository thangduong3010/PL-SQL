Rem
Rem $Header: rdbms/admin/dbmscdcu.sql /main/24 2010/04/07 17:22:44 sramakri Exp $
Rem
Rem dbmscdcu.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscdcu.sql - dbms cdc utilities
Rem
Rem    DESCRIPTION
Rem      utility functions FOR change data capture
Rem
Rem    NOTES
Rem       This package is for Oracle Corporation internal use only!
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    01/12/10 - bug-9047335
Rem    bpanchap    09/26/06 - Removing jobno from check_purge
Rem    bpanchap    05/21/06 - Adding parameter to import_change_table 
Rem    twtong      11/09/04 - add verify_varchar_param 
Rem    twtong      09/17/04 - lrg-1742324
Rem    twtong      08/25/04 - bug-3848917
Rem    slawande    05/05/03 - Add PL/SQL callout to set purge boundary
Rem    wnorcott    01/16/02 - rename username to user_name.
Rem    wnorcott    07/13/01 - CDC factoring
Rem    mbrey       07/03/01 - add Is_Control_ColumnMV
Rem    mbrey       10/11/00 - integrating work on purgeMVLog
Rem    jgalanes    10/09/00 - interface changes for purge MV log
Rem    wnorcott    02/14/01 - add type, version fields to cdc_change_tables$.
Rem    jgalanes    11/30/00 - Adding Drop_User proc to fix bug 1504753
Rem    jgalanes    10/20/00 - Adding IMPORT_CHANGE_TABLE & EXPORT_CHANGE_TABLE
Rem    mbrey       09/01/00 - add chk_security and cdc_allocate_lock
Rem    wnorcott    08/30/00 - Bug 1391408 remove leading blanks before /
Rem    wnorcott    06/29/00 - add numtohex function
Rem    jgalanes    06/15/00 - Adding set_window_start
Rem    jgalanes    05/10/00 - Adding Is_Control_Column , qcccevnt &
Rem                           get_Event_level
Rem    wnorcott    04/27/00 - rid extraneous "space" character
Rem    jgalanes    04/12/00 - Adding parameters to Extend_Window_list
Rem    pabingha    03/02/00 - add sync stubs
Rem    wnorcott    02/16/00 - procedure lock_change_set testing purposes
Rem    wnorcott    02/07/00 - Utility functions for Change Data Capture
Rem    wnorcott    02/07/00 - William D. Norcott created
Rem
  CREATE OR REPLACE PACKAGE dbms_cdc_utility
  IS
     PROCEDURE qccgetee 
       ( 
       edition_o OUT binary_integer 
       ); 
 
      PROCEDURE qccgscn
       (
       scnbase_o OUT binary_integer,
       scnwrap_o OUT binary_integer
       );

     FUNCTION  get_current_scn
       RETURN NUMBER;

     PROCEDURE lock_change_set
       (
       change_set_name IN VARCHAR2
       );

     --
     -- perform extra steps to CREATE a sync. change table
     --
     PROCEDURE setup_sync_table
       (
       owner IN VARCHAR2,
       table_name IN VARCHAR2
       );

     --
     -- perform extra steps to ALTER a sync. change table
     --
     PROCEDURE fixup_sync_table
       (
       owner IN VARCHAR2,
       table_name IN VARCHAR2
       );

     --
     -- perform extra steps to DROP a sync. change table
     --
     PROCEDURE cleanup_sync_table
       (
       owner IN VARCHAR2,
       table_name IN VARCHAR2
       );

     --
     -- implementation of EXTEND_WINDOW_LIST()
     --
     PROCEDURE extend_window_list
       (
       subscription_list     IN VARCHAR2,
       source_schema_list    IN VARCHAR2,
       source_table_list     IN VARCHAR2,
       rollback_segment_list IN VARCHAR2,
       check_source          IN BOOLEAN,
       read_consistency      IN BOOLEAN,
       timestamp_scn_list    OUT VARCHAR2,
       tablemod_scn_list     OUT VARCHAR2,
       read_consistent_scn   OUT NUMBER
       );

     --
     -- Determine if a column name is a CDC control column,
     --
     FUNCTION  is_control_column
       ( column_name  IN VARCHAR2 )
       RETURN NUMBER;

     --
     -- Determine if a column name is a CDC control column for MVs,
     --
     FUNCTION  is_control_columnmv
       ( column_name  IN VARCHAR2 )
       RETURN NUMBER;


     -- Next 2 are for dynamic ChangeTable echo/debug
     PROCEDURE qccgelvl
       (
       event IN  binary_integer,
       level OUT  binary_integer
       );

     FUNCTION  get_event_level
       (
       event IN NUMBER
       )
       RETURN NUMBER;


     --
     --  Returns 1 if this is Oracle Enterprise Edition, else return 0
     --
     FUNCTION get_oracle_edition
        RETURN NUMBER;

     --
     -- Set subscription window starting SCN (EARLIEST)
     --
     PROCEDURE set_window_start
       ( subscription_handle IN NUMBER );


     --
     -- Convert an Oracle number to a hex string
     --
     FUNCTION  numtohex
       ( num IN NUMBER)
       RETURN VARCHAR2;

     --
     -- Verify user has access to a specified change table
     --
     PROCEDURE chk_security (owner       IN VARCHAR2,
                             ownerl      IN binary_integer,
                             table_name  IN VARCHAR2,
                             table_namel IN binary_integer,
                             mvlog       IN binary_integer,
                             success     OUT binary_integer);

     --
     -- allocate a unique lock for CDC use
     --
     PROCEDURE cdc_allocate_lock (lockname  IN VARCHAR2,
                                  lockhandle OUT VARCHAR2,
                                  expiration_secs IN integer default 864000);
     --
     -- do a logical purge of data from all change tables that are MV logs 
     -- related to a subscription.
     --
     --                          PARAMETERS
     --  
     --  subscription_handle: A unique identifier for a subscription 
     --
     --  purge_this_subscription: a flag indicating whether or not the 
     --                           subscription is going away.  'Y' means
     --                           ignore this subscription when computing
     --                           the purge point.
     -- returns 0 if nothing to do else > 0
     --
     PROCEDURE purgeMVLogLogical ( subscription_handle     IN  NUMBER,
                                   purge_this_subscription IN  CHAR,  
                                   updated_something       OUT NUMBER );

     --
     -- do a physical purge of a change table that is an MV log
     --
     PROCEDURE purgeMVLogPhysical ( schema_name IN  VARCHAR2,
                                    table_name  IN  VARCHAR2,
                                    rows_purged OUT NUMBER );

  
     --
     -- produce an IMPORT_CHANGE_TABLE call during export
     --
     FUNCTION export_change_table
       (
       schema_comma_table IN VARCHAR2
       )
       RETURN VARCHAR2;

     --
     -- Produce metadata for a Change Table during IMPORT
     --
     PROCEDURE import_change_table
        (
	change_table_type    IN VARCHAR2,
        major_version        IN VARCHAR2,
        minor_version        IN VARCHAR2,
        database_name        IN VARCHAR2,
        owner                IN VARCHAR2,
        change_table_name    IN VARCHAR2,
        change_set_name      IN VARCHAR2,
        source_schema        IN VARCHAR2,
        source_table         IN VARCHAR2,
        created_scn          IN VARCHAR2,
        lowest_scn           IN VARCHAR2,
        highest_scn          IN VARCHAR2,
        column_type_list     IN VARCHAR2,
        col_created          IN VARCHAR2,
        capture_values       IN VARCHAR2,
        rs_id                IN CHAR,
        row_id               IN CHAR,
        user_id              IN CHAR,
        timestamp            IN CHAR,
        object_id            IN CHAR,
        source_colmap        IN CHAR,
        target_colmap        IN CHAR,
        ddl_markers          IN CHAR,
        opt_created          IN VARCHAR2
        );


     --
     -- check for purge job in job queue. if none, then submit one.
     -- If submits one returns TRUE otherwise FALSE.
     --
     FUNCTION check_purge RETURN BOOLEAN;

     --
     -- (next 2 are for getting next "batch" SCN for SYNC)
     -- get the next "batch" SCN for a SYNC change table.
     --
     PROCEDURE qccsgnbs
        (
        highest_scn  IN  NUMBER,
        highest_len  IN  binary_integer,
        next_scn     OUT NUMBER
        );

     FUNCTION getSyncSCN
        (
        highest_scn  IN  NUMBER,
        highest_len  IN  NUMBER
        )
        RETURN NUMBER;


     --
     -- Drop Change Tables in schema when doing DROP USER CASCADE
     --
     PROCEDURE drop_user
        (
        user_name        IN VARCHAR2
        );

     -- set the purge boundary using SPLIT PARTITION
     PROCEDURE set_purgeBoundary
        (
          subscription_handle IN binary_integer
        );

     --
     -- To get database name, major version, and minor version
     --
     PROCEDURE get_instance 
        (
         major_version OUT NUMBER,
         minor_version OUT NUMBER,
         db_name       OUT VARCHAR2
        );
     
     --
     -- To get table object number
     --
     PROCEDURE get_table_objn(owner   IN VARCHAR2,
                              tabnam  IN VARCHAR2,
                              tabobjn OUT BINARY_INTEGER);

     --
     -- To count the number of purge job
     --
     PROCEDURE count_purge_job(purge_job IN  VARCHAR2,
                               job_cnt   OUT BINARY_INTEGER);

     --
     -- To count the number of subscribers on a change table
     --
     PROCEDURE count_subscribers(change_table_objn  IN  BINARY_INTEGER,
                                 num_of_subscribers OUT BINARY_INTEGER);

     --
     -- To count the number of object columns
     --
     PROCEDURE count_object_col(owner  IN  VARCHAR2,
                                tabnam IN  VARCHAR2,
                                colcount  OUT BINARY_INTEGER);

     --
     -- To count if a column exists in a table
     --
     PROCEDURE count_existing_col(tabobjn IN BINARY_INTEGER,
                                  colnam  IN VARCHAR2,
                                  colcount   OUT BINARY_INTEGER);

     --
     -- To delete the export action associated with the change table
     --
     PROCEDURE delete_export_action(change_table_owner IN VARCHAR2,
                                    change_table_name  IN VARCHAR2); 

     -- paramter max string length
     CDC_DB_NAME_MAX CONSTANT INTEGER := 128;
     CDC_ID_NAME_MAX CONSTANT INTEGER := 30;
     CDC_DESC_MAX    CONSTANT INTEGER := 255;
     CDC_VARCHAR_MAX  CONSTANT INTEGER := 32767;
     CDC_SINGLE_CHAR  CONSTANT INTEGER := 1;
     CDC_JOB_NAME_MAX CONSTANT INTEGER := 4000;
     CDC_DML_TYPE_MAX CONSTANT INTEGER := 6;
     CDC_ROOT_DIR_MAX CONSTANT INTEGER := 2000;
     --
     -- Verify the varchar/char parameter does not exceed the limit
     --
     PROCEDURE verify_varchar_param(param_name   IN VARCHAR2,
                                    param_value  IN VARCHAR2,
                                    param_max    IN BINARY_INTEGER);

     -- VERIFY_CDC_NAME
     -- Verify the param_value parameter does not exceed the limit
     -- and it conforms to the naming rules for CDC identifiers. 
     -- All Change Data Capture (CDC) identifiers must have at most 30
     -- characters, and must start with a letter that is followed
     -- by any combination of letters, numerals, and the signs 
     -- '$', '_', and '#'. Other characters cannot be used in identifiers.
     -- The rules for CDC identifiers are the same as for PL/SQL identifiers.
     -- 
    PROCEDURE verify_cdc_name(param_name   IN VARCHAR2,
                              param_value  IN VARCHAR2,
                              param_max    IN BINARY_INTEGER);
  END dbms_cdc_utility;
/

