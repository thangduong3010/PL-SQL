Rem
Rem $Header: rdbms/admin/dbmsamgt.sql /main/6 2009/04/05 23:36:14 nkgopal Exp $
Rem
Rem dbmsaudmgmt.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsaudmgmt.sql - DBMS_AUDIT_MGMT package
Rem
Rem    DESCRIPTION
Rem      This will install the interfaces for DBMS_AUDIT_MGMT package
Rem      and the tables required by the package.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nkgopal     03/31/09 - Bug 8392745: Add FILE_DELETE_BATCH_SIZE
Rem    nkgopal     02/24/09 - Bug 8272269: Add AUD_TAB_MOVEMENT_FLAG
Rem    nkgopal     12/03/08 - Bug 7576198: Default value for
Rem                           RAC_INSTANCE_NUMBER will be null
Rem    ssonawan    03/28/08 - Bug 6887943: add move_dbaudit_tables() 
Rem    nkgopal     03/13/08 - Bug 6810355: Add DB_DELETE_BATCH_SZ
Rem    rahanum     11/02/07 - Merge dbms_audit_mgmt
Rem    nkgopal     05/22/07 - DBMS_AUDIT_MGMT package
Rem    nkgopal     05/22/07 - Created
Rem

------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_audit_mgmt AS

  -- Constants

  -- Audit Trail types
  -- 
  AUDIT_TRAIL_AUD_STD           CONSTANT NUMBER := 1;
  AUDIT_TRAIL_FGA_STD           CONSTANT NUMBER := 2;
  --
  -- Both AUDIT_TRAIL_AUD_STD and AUDIT_TRAIL_FGA_STD
  AUDIT_TRAIL_DB_STD            CONSTANT NUMBER := 3;
  --
  AUDIT_TRAIL_OS                CONSTANT NUMBER := 4;
  AUDIT_TRAIL_XML               CONSTANT NUMBER := 8;
  --
  -- Both AUDIT_TRAIL_OS and AUDIT_TRAIL_XML
  AUDIT_TRAIL_FILES             CONSTANT NUMBER := 12;
  --
  -- All above audit trail types
  AUDIT_TRAIL_ALL               CONSTANT NUMBER := 15;

  --
  -- OS Audit File Configuration parameters
  OS_FILE_MAX_SIZE              CONSTANT NUMBER := 16;
  OS_FILE_MAX_AGE               CONSTANT NUMBER := 17;

  -- 
  -- 
  CLEAN_UP_INTERVAL             CONSTANT NUMBER := 21;
  DB_AUDIT_TABLEPSACE           CONSTANT NUMBER := 22;
  DB_DELETE_BATCH_SIZE          CONSTANT NUMBER := 23;
  TRACE_LEVEL                   CONSTANT NUMBER := 24;
  -- AUD_TAB_MOVEMENT_FLAG will not be entered in DAM_CONFIG_PARAM$
  AUD_TAB_MOVEMENT_FLAG         CONSTANT NUMBER := 25;
  FILE_DELETE_BATCH_SIZE        CONSTANT NUMBER := 26;

  --
  -- Values for PURGE_JOB_STATUS
  PURGE_JOB_ENABLE              CONSTANT NUMBER := 31;
  PURGE_JOB_DISABLE             CONSTANT NUMBER := 32;

  --
  -- Values for TRACE_LEVEL
  TRACE_LEVEL_DEBUG             CONSTANT PLS_INTEGER := 1;
  TRACE_LEVEL_ERROR             CONSTANT PLS_INTEGER := 2;

  ----------------------------------------------------------------------------
  /*

  NOTE: The package can be split into two packages - one intended for use by
  AV collectors and the one by Audit Admin.

  The first 3 procedures will be mainly used by the Collectors and the rest
  must be executed by Audit Admins.

  Alternately, wrapper packages can be written to achieve this Seperation of
  Duty.

  */

  /* APIS REQUIRED BY COLLECTORS */
  ----------------------------------------------------------------------------

  -- set_last_archive_timestamp - Sets timestamp when last audit records 
  --                              were archived
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the last audit 
  --                                record timestamp is being set
  --   last_archive_time          - Timestamp when last audit record was 
  --                                archived
  --   rac_instance_number        - RAC instance number to which this applies
  --                                def. value = null(applies to no RAC node)
  
  PROCEDURE set_last_archive_timestamp
            (audit_trail_type           IN PLS_INTEGER,
             last_archive_time          IN TIMESTAMP,
             rac_instance_number        IN PLS_INTEGER := null
            );
  
  ----------------------------------------------------------------------------

  -- clear_last_archive_timestamp - Deletes the timestamp set by 
  --                                set_last_archive_timestamp
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the last audit 
  --                                record timestamp was set
  --   rac_instance_number        - RAC instance number to which this applies
  --                                def. value = null(applies to no RAC node)
  
  PROCEDURE clear_last_archive_timestamp
            (audit_trail_type           IN PLS_INTEGER,
             rac_instance_number        IN PLS_INTEGER := null
            );

   -----------------------------------------------------------------------------

  -- get_audit_commit_delay - GETs the audit commit delay set in the db.
  --
  -- INPUT PARAMETERS
  --   None
  -- RETURNS
  --   AUD_AUDIT_COMMIT_DELAY
  -- 

  FUNCTION get_audit_commit_delay RETURN PLS_INTEGER;

  ----------------------------------------------------------------------------
 
  -- is_cleanup_initialized - Checks if Audit Cleanup is initialized for the 
  --                          audit trail type
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail to check initialization for.
  -- RETURNS
  --   TRUE  - If audit trail is initialized for clean up.
  --   FALSE - otherwise.
  -- 

  FUNCTION is_cleanup_initialized
           (audit_trail_type           IN PLS_INTEGER)
  RETURN BOOLEAN;
 
  ----------------------------------------------------------------------------

  /* APIS NEED TO BE RUN BY AUDIT ADMINS */
  ----------------------------------------------------------------------------

  -- init_cleanup  - Initialize DBMS_AUDIT_MGMT
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which set-up must done.
  --   default_cleanup_interval   - Default interval at which clean up is
  --                                invoked.    

  PROCEDURE init_cleanup
            (audit_trail_type           IN PLS_INTEGER,
             default_cleanup_interval   IN PLS_INTEGER
            );

  ----------------------------------------------------------------------------

  -- set_audit_trail_location - Set destination for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the location 
  --                                is being set
  --   audit_trail_location_value - Value of the location

  PROCEDURE set_audit_trail_location
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_location_value IN VARCHAR2
            );

  ----------------------------------------------------------------------------

  -- deinit_cleanup  - De-Initialize DBMS_AUDIT_MGMT
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which set-up must done.

  PROCEDURE deinit_cleanup
            (audit_trail_type           IN PLS_INTEGER);
  
  ----------------------------------------------------------------------------

  -- set_audit_trail_property - Set a property of an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail whose parameter must be set
  --   audit_trail_property       - Property that must be set
  --   audit_trail_property_value - Value to which the property must set

  PROCEDURE set_audit_trail_property
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_property       IN PLS_INTEGER,
             audit_trail_property_value IN PLS_INTEGER
            );

  ----------------------------------------------------------------------------

  -- clear_audit_trail_property - Clears a property of an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail whose parameter must be set
  --   audit_trail_property       - Property that must be cleared
  --   use_default_values         - Use default values after clearing the 
  --                                property, default value is FALSE.

  PROCEDURE clear_audit_trail_property
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_property       IN PLS_INTEGER,
             use_default_values         IN BOOLEAN := FALSE
            );

 ----------------------------------------------------------------------------
  
  -- clean_audit_trail - Deletes entries in audit trail according to the
  --                     timestamp set in set_last_archive_timestamp
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail which should be cleared
  --   use_last_arch_timestamp    - Use Last Archive Timestamp set.
  --                                default value = TRUE.

  PROCEDURE clean_audit_trail
            (audit_trail_type           IN PLS_INTEGER,
             use_last_arch_timestamp    IN BOOLEAN := TRUE 
            );
  
  ----------------------------------------------------------------------------

  -- create_purge_job - Creates a purge job for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which this job is created
  --   audit_trail_purge_interval - Interval to determine frequency of 
  --                                purge operation
  --   audit_trail_interval_unit  - Unit of measurement for 
  --                                audit_trail_purge_interval
  --   audit_trail_purge_name     - Name to identify this job
  --   use_last_arch_timestamp    - Use Last Archive Timestamp set.
  --                                default value = TRUE.
  
  PROCEDURE create_purge_job
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_purge_interval IN PLS_INTEGER,
             audit_trail_purge_name     IN VARCHAR2,
             use_last_arch_timestamp    IN BOOLEAN := TRUE
            );
  
  ----------------------------------------------------------------------------
  
  -- set_purge_job_status - Set the status of the purge job
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name of the purge job created
  --   audit_trail_status_value   - Value to which the status must set
  
  PROCEDURE set_purge_job_status
            (audit_trail_purge_name     IN VARCHAR2,
             audit_trail_status_value   IN PLS_INTEGER
            );
  
  ----------------------------------------------------------------------------

  -- set_purge_job_interval - Set the interval of the purge job
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name of the purge job created
  --   audit_trail_interval_type  - Type of interval that must be set
  --   audit_trail_interval_value - Value to which the interval must set

  PROCEDURE set_purge_job_interval
            (audit_trail_purge_name     IN VARCHAR2,
             audit_trail_interval_value IN PLS_INTEGER
            );
  
  ----------------------------------------------------------------------------
  
  -- drop_purge_job - Drops the purge job for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name to identify this job
  
  PROCEDURE drop_purge_job
            (audit_trail_purge_name     IN VARCHAR2
            );
 
  ----------------------------------------------------------------------------

  -- move_dbaudit_tables - Moves DB audit tables to specified tablespace 
  --
  -- INPUT PARAMETERS
  --   audit_trail_tbs - The table space to which to move the DB audit tables.
  --                     The default value is the SYSAUX tablespace.      
  
  PROCEDURE move_dbaudit_tables
            (audit_trail_tbs     IN VARCHAR2  DEFAULT 'SYSAUX'
            );
 
  ----------------------------------------------------------------------------

  -- set_debug_level - Sets the debug level for tracing
  --
  -- INPUT PARAMETERS
  --   debug_level - Number to identify the trace level

  PROCEDURE set_debug_level(debug_level IN PLS_INTEGER := TRACE_LEVEL_ERROR);
 
  ----------------------------------------------------------------------------

END dbms_audit_mgmt;
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_audit_mgmt TO execute_catalog_role
/

