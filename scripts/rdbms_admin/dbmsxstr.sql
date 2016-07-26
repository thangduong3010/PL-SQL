Rem
Rem $Header: rdbms/admin/dbmsxstr.sql /st_rdbms_11.2.0/7 2013/03/29 08:08:08 aayalaa Exp $
Rem
Rem dbmsxstr.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxstr.sql - DBMS XStream Package
Rem
Rem    DESCRIPTION
Rem      This package contains the higher level APIs for creating
Rem      XStream outbound and inbound servers.
Rem
Rem    NOTES
Rem      Requires AQ and dbms_streams* related packages to have been 
Rem      previously installed.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aayalaa     03/20/13 - Bug 16355441. Changing default value
Rem                           in the parameter grant_select_privileges
Rem                           to true in dbms_goldengate_auth.grant_admin_privilege
Rem    huntran     01/21/13 - Backport huntran_bug-14338486 from main
Rem    thoang      02/16/12 - Backport thoang_bug-12983683 from main
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    elu         04/12/11 - xml schema
Rem    thoang      09/20/11 - add include_dml/ddl parms to create/add_outbound
Rem    huntran     02/28/11 - reset configuration constants
Rem    yurxu       03/05/10 - Bug-9469148: rename to dbms_goldengate_auth.
Rem                           grant_admin_privilege
Rem    thoang      03/05/10 - allow null qname in add_outbound
Rem    yurxu       01/12/10 - add dbms_xstream_auth.grant_privileges
Rem    juyuan      01/13/10 - remove wait_for_inflight_txns parameter
Rem    juyuan      12/23/09 - dbms_xstream_auth.grant_privileges
Rem    thoang      12/03/09 - move committed_data_only to dbms_xstream_gg
Rem    yurxu       11/10/09 - change start_scn_time to start_time
Rem    juyuan      10/31/09 - enable_gg_xstream_for_streams
Rem    thoang      10/04/09 - Add uncommitted_data argument
Rem    juyuan      10/26/09 - enable_xstream_for_streams
Rem    praghuna    10/09/09 - Added start_scn, start_scn_time-alter_outbound
Rem    thoang      11/20/08 - Change column_table to column_list
Rem    rihuang     10/28/08 - Change signature for add_subset_outbound_rules
Rem    thoang      03/15/08 - Created
Rem

----------------------------------------------------------------------
-- XStream Admin API 
----------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_xstream_adm AUTHID CURRENT_USER AS 
  -- constants for resetting configuration
  RESET_PARAMETERS       CONSTANT BINARY_INTEGER := 1;
  RESET_HANDLERS         CONSTANT BINARY_INTEGER := 2;
  RESET_PROGRESS         CONSTANT BINARY_INTEGER := 4;
  RESET_ALL              CONSTANT BINARY_INTEGER := 2147483647;

  -- flag for alter_outbound to identify whether is xstream
  is_xstream           BOOLEAN;

  -- Procedure create_outbound creates an outbound server, necessary queue 
  -- and associated capture to allow clients to stream out LCRs from the
  -- specified source database.   
  --
  -- If no table or schema specified then the outbound server will stream
  -- all DDL and DML changes.
  --
  -- If capture_name is not specified then a capture is created using a
  -- system-generated name. If capture_name is specified and existed then 
  -- that capture is used; otherwise, a new capture is created using the 
  -- given name.
  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

/*  NOT SUPPORTING OUT PARAMETERS FOR NOW
  
  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    ddl_table_rule_names    OUT DBMS_UTILITY.UNCL_ARRAY,
    dml_table_rule_names    OUT DBMS_UTILITY.UNCL_ARRAY,
    ddl_schema_rule_names   OUT DBMS_UTILITY.UNCL_ARRAY,  
    dml_schema_rule_names   OUT DBMS_UTILITY.UNCL_ARRAY); 

  PROCEDURE create_outbound(
    server_name             IN VARCHAR2,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL, 
    ddl_table_rule_names    OUT VARCHAR2,
    dml_table_rule_names    OUT VARCHAR2,
    ddl_schema_rule_names   OUT VARCHAR2,
    dml_schema_rule_names   OUT VARCHAR2);  

*/

  PROCEDURE alter_outbound(
    server_name             IN VARCHAR2,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    add                     IN BOOLEAN DEFAULT TRUE,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    inclusion_rule          IN BOOLEAN  DEFAULT TRUE,  
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

  PROCEDURE alter_outbound(
    server_name             IN VARCHAR2,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    add                     IN BOOLEAN DEFAULT TRUE,
    capture_user            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    inclusion_rule          IN BOOLEAN  DEFAULT TRUE,  
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

  -- Add an outbound server to an existing queue or capture.
  -- Either the queue name or capture name must be specified. If both are 
  -- specified then the capture must be local, and the queue name must match 
  -- the capture's queue.
  PROCEDURE add_outbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2 DEFAULT NULL,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN DBMS_UTILITY.UNCL_ARRAY,
    schema_names            IN DBMS_UTILITY.UNCL_ARRAY,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

  PROCEDURE add_outbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2 DEFAULT NULL,
    source_database         IN VARCHAR2 DEFAULT NULL,
    table_names             IN VARCHAR2 DEFAULT NULL,
    schema_names            IN VARCHAR2 DEFAULT NULL,
    connect_user            IN VARCHAR2 DEFAULT NULL,
    comment                 IN VARCHAR2 DEFAULT NULL,  
    capture_name            IN VARCHAR2 DEFAULT NULL,
    start_scn               IN NUMBER   DEFAULT NULL,
    start_time              IN TIMESTAMP DEFAULT NULL,
    include_dml             IN BOOLEAN DEFAULT TRUE,
    include_ddl             IN BOOLEAN DEFAULT TRUE);

  PROCEDURE drop_outbound(
    server_name             IN VARCHAR2);

  PROCEDURE add_subset_outbound_rules(
    server_name             IN VARCHAR2,
    table_name              IN VARCHAR2,
    condition               IN VARCHAR2 DEFAULT NULL,
    column_list             IN DBMS_UTILITY.LNAME_ARRAY,
    keep                    IN BOOLEAN  DEFAULT TRUE);

  PROCEDURE add_subset_outbound_rules(
    server_name             IN VARCHAR2,
    table_name              IN VARCHAR2,
    condition               IN VARCHAR2 DEFAULT NULL,
    column_list             IN VARCHAR2 DEFAULT NULL, 
    keep                    IN BOOLEAN  DEFAULT TRUE);

  -- Removes the specified subsetting rules from the given outbound server.
  -- The specified rules must have been created for the same subsetting 
  -- condition.
  PROCEDURE remove_subset_outbound_rules(
    server_name             IN VARCHAR2,
    insert_rule_name        IN VARCHAR2, 
    update_rule_name        IN VARCHAR2, 
    delete_rule_name        IN VARCHAR2);
 
  -- Create an inbound server using the specified queue. If the specified
  -- queue does not exist then this procedure will create one. 
  PROCEDURE create_inbound(
    server_name             IN VARCHAR2,
    queue_name              IN VARCHAR2,
    apply_user              IN VARCHAR2 DEFAULT NULL,  
    comment                 IN VARCHAR2 DEFAULT NULL);

  PROCEDURE alter_inbound(
    server_name             IN VARCHAR2,
    apply_user              IN VARCHAR2 DEFAULT NULL,  
    comment                 IN VARCHAR2 DEFAULT NULL);

  PROCEDURE drop_inbound(
    server_name             IN VARCHAR2);

  PROCEDURE enable_gg_xstream_for_streams(
    enable                  IN BOOLEAN DEFAULT TRUE);

  FUNCTION is_gg_xstream_for_streams RETURN BOOLEAN;

END dbms_xstream_adm;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xstream_adm FOR sys.dbms_xstream_adm
/
GRANT EXECUTE ON sys.dbms_xstream_adm TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_xstream_auth AUTHID CURRENT_USER AS 

-- Grants the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee          - the user to whom privileges are granted
--   privilege_type   - CAPTURE, APPLY, both(*)
--   grant_select_privileges - should the select_catalog_role be granted?
--   do_grants        - should the privileges be granted ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   grant_optional_privileges - comma-separated list of optional prvileges
--                               to grant: XBADMIN, DV_XSTREAM_ADMIN,
--                               DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if grant_select_privileges = TRUE
--     grant select_catalog_role to grantee
--   if grant_select_privileges = FALSE
--     grant a min set of privileges to grantee
--   if do_grants = TRUE
--     the grant statements are to be executed.
--   if do_grants = FALSE
--     the grant statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grants is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE grant_admin_privilege(
  grantee          IN VARCHAR2,
  privilege_type   IN VARCHAR2 DEFAULT '*',
  grant_select_privileges IN BOOLEAN DEFAULT FALSE,
  do_grants        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  grant_optional_privileges IN VARCHAR2 DEFAULT NULL);

-- Revokes the privileges needed by a user to be an administrator for streams.
-- Optionally generates a script whose execution has the same effect.
-- INPUT:
--   grantee           - the user from whom the privileges are revoked
--   privilege_type    - CAPTURE, APPLY, both(*)
--   revoke_select_privileges - should the select_catalog_role be revoked?
--   do_revokes        - should the privileges be revoked ?
--   file_name         - name of the file to which the script will be written
--   directory_name    - the directory where the file will be written
--   revoke_optional_privileges - comma-separated list of optional prvileges
--                                to revoke: XBADMIN, DV_XSTREAM_ADMIN,
--                                DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if revoke_select_privileges = TRUE
--     revoke select_catalog_role from grantee
--   if revoke_select_privileges = FALSE
--     revoke a min set of privileges from grantee
--   if do_revokes = TRUE
--     the revoke statements are to be executed.
--   if do_revokes = FALSE
--     the revoke statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_revokes is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_revoke is true, each statement is appended to the script 
--     only if it executed successfully.
PROCEDURE revoke_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  revoke_select_privileges IN BOOLEAN DEFAULT FALSE,
  do_revokes        IN BOOLEAN DEFAULT TRUE,
  file_name         IN VARCHAR2 DEFAULT NULL,
  directory_name    IN VARCHAR2 DEFAULT NULL,
  revoke_optional_privileges IN VARCHAR2 DEFAULT NULL);

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

END dbms_xstream_auth;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xstream_auth FOR sys.dbms_xstream_auth
/
GRANT EXECUTE ON sys.dbms_xstream_auth TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_goldengate_auth AUTHID CURRENT_USER AS 

-- Grants the privileges needed by a user to be an administrator for OGG 
-- Integration with XStreamOut
-- INPUT:
--   grantee          - the user to whom privileges are granted
--   privilege_type   - CAPTURE, APPLY, both(*)
--   grant_select_privileges - should the select_catalog_role be granted?
--   do_grants        - should the privileges be granted ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   grant_optional_privileges - comma-separated list of optional prvileges
--                               to grant: XBADMIN, DV_XSTREAM_ADMIN,
--                               DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if grant_select_privileges = TRUE
--     grant select_catalog_role to grantee
--   if grant_select_privileges = FALSE
--     grant a min set of privileges to grantee
--   if do_grants = TRUE
--     the grant statements are to be executed.
--   if do_grants = FALSE
--     the grant statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grant is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE grant_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  grant_select_privileges IN BOOLEAN DEFAULT TRUE,
  do_grants        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  grant_optional_privileges IN VARCHAR2 DEFAULT NULL);

-- Revokes the privileges needed by a user to be an administrator for OGG 
-- Integration with XStreamOut
-- INPUT:
--   grantee          - the user from whom privileges are revoked
--   privilege_type   - CAPTURE, APPLY, both(*)
--   revoke_select_privileges - should the select_catalog_role be revoked?
--   do_revokes       - should the privileges be revoked ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   revoke_optional_privileges - comma-separated list of optional prvileges
--                                to revoke: XBADMIN, DV_XSTREAM_ADMIN,
--                                DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if revoke_select_privileges = TRUE
--     revoke select_catalog_role from grantee
--   if revoke_select_privileges = FALSE
--     revoke a min set of privileges from grantee
--   if do_revokes = TRUE
--     the revoke statements are to be executed.
--   if do_revokes = FALSE
--     the revoke statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grants is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE revoke_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  revoke_select_privileges IN BOOLEAN DEFAULT TRUE,
  do_revokes        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  revoke_optional_privileges IN VARCHAR2 DEFAULT NULL);

END dbms_goldengate_auth;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_goldengate_auth FOR sys.dbms_goldengate_auth
/
GRANT EXECUTE ON sys.dbms_goldengate_auth TO execute_catalog_role
/


