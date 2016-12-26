Rem
Rem $Header: dbmscdcp.sql 07-jun-2007.08:22:26 mbrey Exp $
Rem
Rem dbmscdcp.sql
Rem
Rem Copyright (c) 2000, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmscdcp.sql - Public interface for the Change Data Capture Publisher
Rem
Rem    DESCRIPTION
Rem      defines specification for packages dbms_cdc_publish
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbrey       06/07/07 - bug 6117884
Rem    mbrey       05/17/06 - 11gR1 purge work 
Rem    bpanchap    05/03/06 - Adding DDL markers to change tables 
Rem    pabingha    09/16/04 - change hot_mine to online_log 
Rem    mbrey       05/21/04 - hot mine change 
Rem    mbrey       04/28/04 - make publish package invokers rights 
Rem    mbrey       04/05/04 - 10gR2 api changes 
Rem    pabingha    07/22/03 - remove supplemental_processes
Rem    mbrey       05/19/03 - adding param for alter_change_Set
Rem    pabingha    02/25/03 - fix undoc interfaces
Rem    pabingha    01/16/03 - fix drop_change_set param name
Rem    pabingha    12/16/02 - remove dbid autolog param
Rem    pabingha    10/04/02 - add DDL handler
Rem    pabingha    09/30/02 - add MVLog purge
Rem    mbrey       09/18/02 - integrate KGL changes for change tables
Rem    pabingha    08/15/02 - add purge entry points
Rem    pabingha    06/27/02 - add change source/set 10iR1 interfaces
Rem    wnorcott    01/31/02 - .
Rem    wnorcott    01/30/02 - add procedure active.
Rem    wnorcott    12/07/01 - Add set_directory_root.
Rem    wnorcott    12/03/01 - add memory_size variant
Rem    wnorcott    10/19/01 - .
Rem    wnorcott    06/13/01 - work on it.
Rem    wnorcott    05/31/01 - trickle feed variant.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    nshodhan    02/21/01 - 
Rem    nshodhan    02/16/01 - Bug#1647071: replace mv with mview
Rem    wnorcott    10/26/00 - Bug 1477568 rid trailing slash
Rem    mbrey       10/11/00 - integrate work on purgeMVLog into purge txn
Rem                            split into purgeMVLogLogical/Physical
Rem    jgalanes    10/09/00 - Moving purgeMVLog to util since private
Rem    wnorcott    06/19/00 - synonyms for dbms_logmnr_cdc
Rem    jgalanes    06/12/00 - Adding PurgeMVLog
Rem    jgalanes    04/03/00 - Making RSID$ control column optional.
Rem    mbrey       03/27/00 - adding grants
Rem    jgalanes    03/10/00 - Adding change_table_trigger
Rem    mbrey       02/16/00 - change routine name
Rem    mbrey       02/07/00 - remove CHAR
Rem    mbrey       01/26/00 - adding purge/drop_subscription
Rem    mbrey       01/25/00 - Created
Rem

CREATE OR REPLACE PACKAGE DBMS_CDC_PUBLISH AUTHID CURRENT_USER AS

-------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_PUBLISH.CREATE_AUTOLOG_CHANGE_SOURCE
--  
--  Purpose: Describes the source system that is providing the asynchronous 
--           AutoLog change data.
--  
--  PROCEDURE DBMS_CDC_PUBLISH.ALTER_AUTOLOG_CHANGE_SOURCE
--  
--  Purpose: Alter the properties of an AutoLog change source after it 
--           has been created.
--  
--  PROCEDURE DBMS_CDC_PUBLISH.DROP_CHANGE_SOURCE
--  
--  Purpose: Drops the specifed change source. 
--  
--                          PARAMETERS
--  
--  change_source_name: The name of the change source
--
--  description: A comment field used to describe the source system in 
--  more detail
--
--  remove_description: Whether to remove change source description (Y|N)
--
--  source_database: global database name of the source database that this
--  change source represents
--
--  first_scn: SCN of the LogMiner data dictionary at which capture can
--  begin
--  
--                  EXCEPTION DESCRIPTION
--  
--
-------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_PUBLISH.CREATE_CHANGE_SET
--  
--  Purpose: Creates a change set and defines properties for the 
--  change tables belonging to this change set.
--  
--  PROCEDURE DBMS_CDC_PUBLISH.ALTER_CHANGE_SET
--  
--  Purpose: Alter the properties of an existing change set.
--  
--  PROCEDURE DBMS_CDC_PUBLISH.DROP_CHANGE_SET
--  
--  Purpose: Drops the specifed change set.
--
--                          PARAMETERS
--  
--  change_set_name: The name of the change set.
--
--  description: A comment field used to describe the change set in 
--  more detail
--
--  remove_description: Whether to remove change set description (Y|N)
--
--  change_source_name: Name of an existing change source that will feed this 
--  change set.
--
--  stop_on_ddl: Indicates whether to stop capture when DDL is encountered
--  (Y|N)
--
--  begin_date: The date at which the change set should start capturing data.
--
--  end_date: The date at which the change set should end capturing data.
--
--  enable_capture: whether to enable capture for an asynchronous change set
--  (Y|N)
--
--  recover_after_error: whether to attempt to recover from previous
--  capture errors (Y|N)
--
--                  EXCEPTION DESCRIPTION
--  
--
-------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_PUBLISH.CREATE_CHANGE_TABLE
--  
--  Purpose: Creates a change table in the user's schema and sets several 
--  parameters.
--
--  PROCEDURE DBMS_CDC_PUBLISH.ALTER_CHANGE_TABLE
--  
--  Purpose: Alter the properties of an existing change table by adding or 
--  dropping columns.
--  
--  PROCEDURE DBMS_CDC_PUBLISH.DROP_CHANGE_TABLE
--  
--  Purpose: Drops the specifed change table.
--
--
--                          PARAMETERS
--  
--  owner: The schema name that owns the change table.
--
--  change_table_name: The name of the change table.
--
--  column_[type_]list: A comma-separated list of columns [and datatypes] 
--  that should be placed in the change table or dropped from the change table.
--
--  operation: Either the value 'DROP' or 'ADD' or NULL - indicates whether to
--  add or drop the columns when altering a change table.
--
--  rs_id: Indicates  whether a column containing a sequence number
--  is included in the change table (Y|N)
--
--  row_id: Indicates whether a column containing the rowid of
--  the change in the source table is included in the change table (Y|N)
--  
--  user_id: Indicates whether a column containing the username who issued 
--  the DML statement is included in the change table (Y|N)
--
--  timestamp: Indicates whether a column containing the 
--  timestamp of the change record is included in the change table (Y|N)
--
--  object_id: Indicates whethera column containing the 
--  object-id is included in the change table
--
--  source_colmap: Indicates whether a column containing a 
--  change column vector for the source table is included in the change table.
--
--  target_colmap: Indicates whether a column containing a 
--  change column vector for the change table is included in the change table.
--
--  options_string: Quoted string containing a list of options to pass into 
--  the CREATE TABLE DDL statement
--
--                  EXCEPTION DESCRIPTION
--  
--
-------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_PUBLISH.DROP_SUBSCRIPTION
--  
--  Purpose: Allows a publisher to remove an existing subscription.
--  
--                          PARAMETERS
--  
--  subscription_name: Name of an existing subscription to drop
--
--                  EXCEPTION DESCRIPTION
--  
--
-------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_PUBLISH.PURGE
--  
--  Purpose: Initiates a purge of all change sets on staging database
--
--  PROCEDURE DBMS_CDC_PUBLISH.PURGE_CHANGE_SET
--  
--  Purpose: Initiates a purge of the specified change set
--
--  PROCEDURE DBMS_CDC_PUBLISH.PURGE_CHANGE_TABLE
--  
--  Purpose: Initiates a purge of the specified change table
--
--                          PARAMETERS
--  
--  change_set_name: Name of an existing change set to purge 
--
--  owner: Owner of the change table to purge
--
--  change_table_name: Name of an existing change table to purge
--
--
-------------------------------------------------------------------------------
--
-- 10.2 publisher interface
--

-- This transaltes the DDLOPR$ value number into a text
-- This is used for quick understanding of this field 
FUNCTION get_DDLOper (ddloper IN BINARY_INTEGER) RETURN VARCHAR2;

PROCEDURE create_hotlog_change_source (
                    change_source_name IN VARCHAR2,
                    description        IN VARCHAR2 DEFAULT NULL,
                    source_database    IN VARCHAR2);

PROCEDURE alter_hotlog_change_source (
                    change_source_name IN VARCHAR2,
                    description        IN VARCHAR2 DEFAULT NULL,
                    remove_description IN CHAR DEFAULT 'N',
                    enable_source      IN CHAR DEFAULT NULL);

--
-- 10i publisher interface
--

 PROCEDURE create_autolog_change_source (
                    change_source_name IN VARCHAR2,
                    description        IN VARCHAR2 DEFAULT NULL,
                    source_database    IN VARCHAR2,
                    first_scn          IN NUMBER,
                    online_log         IN CHAR DEFAULT 'N');

 PROCEDURE alter_autolog_change_source (
                    change_source_name IN VARCHAR2,
                    description        IN VARCHAR2 DEFAULT NULL,
                    remove_description IN CHAR DEFAULT 'N',
                    first_scn          IN NUMBER DEFAULT NULL);

 PROCEDURE drop_change_source (change_source_name IN VARCHAR2); 

 PROCEDURE create_change_set (
                    change_set_name        IN VARCHAR2,
                    description            IN VARCHAR2 DEFAULT NULL,
                    change_source_name     IN VARCHAR2,
                    stop_on_ddl            IN CHAR DEFAULT 'N',
                    begin_date             IN DATE DEFAULT NULL,
                    end_date               IN DATE DEFAULT NULL);

 PROCEDURE alter_change_set (
                    change_set_name        IN VARCHAR2,
                    description            IN VARCHAR2 DEFAULT NULL,
                    remove_description     IN CHAR DEFAULT 'N',
                    enable_capture         IN CHAR DEFAULT NULL,
                    recover_after_error    IN CHAR DEFAULT NULL,
                    remove_ddl             IN CHAR DEFAULT NULL,
                    stop_on_ddl            IN CHAR DEFAULT NULL);

 PROCEDURE drop_change_set (change_set_name IN VARCHAR2);

 PROCEDURE create_change_table (owner             IN VARCHAR2,
                                change_table_name IN VARCHAR2,
                                change_set_name   IN VARCHAR2,
                                source_schema     IN VARCHAR2,
                                source_table      IN VARCHAR2,
                                column_type_list  IN VARCHAR2,
                                capture_values    IN VARCHAR2,
                                rs_id             IN CHAR,
                                row_id            IN CHAR,
                                user_id           IN CHAR,
                                timestamp         IN CHAR,
                                object_id         IN CHAR,
                                source_colmap     IN CHAR,
                                target_colmap     IN CHAR,
                                options_string    IN VARCHAR2,
                                ddl_markers       IN CHAR DEFAULT 'Y');

 PROCEDURE alter_change_table (owner             IN VARCHAR2,
                               change_table_name IN VARCHAR2,
                               operation         IN VARCHAR2,
                               column_list       IN VARCHAR2,
                               rs_id             IN CHAR,
                               row_id            IN CHAR,
                               user_id           IN CHAR,
                               timestamp         IN CHAR,
                               object_id         IN CHAR,
                               source_colmap     IN CHAR,
                               target_colmap     IN CHAR,
                               ddl_markers       IN CHAR DEFAULT NULL);
 
 PROCEDURE drop_change_table (owner             IN VARCHAR2,
                              change_table_name IN VARCHAR2,
                              force_flag        IN CHAR);

 PROCEDURE drop_subscription (subscription_name IN VARCHAR2);

 PROCEDURE purge;

 PROCEDURE purge_change_set (change_set_name IN VARCHAR2,
                             force           IN CHAR DEFAULT 'Y',
                             purge_date      IN DATE DEFAULT NULL);

 PROCEDURE purge_change_table (owner             IN VARCHAR2,
                               change_table_name IN VARCHAR2,
                               force             IN CHAR DEFAULT 'Y',
                               purge_date        IN DATE DEFAULT NULL);

--
-- 9i publisher interface - deprecated
--

 PROCEDURE drop_subscriber_view (subscription_handle IN NUMBER,
                                 source_schema       IN VARCHAR2,
                                 source_table        IN VARCHAR2);

 PROCEDURE drop_subscription (subscription_handle IN NUMBER);

END DBMS_CDC_PUBLISH;
/
GRANT EXECUTE ON sys.dbms_cdc_publish TO execute_catalog_role;
CREATE OR REPLACE PUBLIC SYNONYM dbms_cdc_publish FOR sys.dbms_cdc_publish;
CREATE OR REPLACE PUBLIC SYNONYM dbms_logmnr_cdc_publish
   FOR sys.dbms_cdc_publish;
