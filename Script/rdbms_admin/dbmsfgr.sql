Rem
Rem $Header: dbmsfgr.sql 25-mar-2005.15:39:24 alakshmi Exp $
Rem
Rem dbmsfgr.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsfgr.sql - DBMS File GRoup
Rem
Rem    DESCRIPTION
Rem      This package contains the APIs for building and managing 
Rem      a File Group repository.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alakshmi    03/25/05 - fix file type constants 
Rem    htran       03/11/05 - default min_versions to 2 for create
Rem    alakshmi    04/30/04 - alakshmi_tbs_set
Rem    htran       04/20/04 - rename some parameters
Rem    alakshmi    04/19/04 - system privilege READ_ANY_FILE_GROUP 
Rem    htran       04/14/04 - purge procedure
Rem    alakshmi    04/13/04 - browse privileges 
Rem    alakshmi    03/29/04 - object privileges 
Rem    alakshmi    02/23/04 - Add security APIs 
Rem    htran       02/18/04 - file type constants 
Rem    alakshmi    02/16/04 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_file_group AUTHID CURRENT_USER AS 

  INFINITE           CONSTANT NUMBER := 4294967295;

  -- file type constants
  EXPORT_DUMP_FILE   CONSTANT VARCHAR2(30) := 'DUMPSET';
  DATAPUMP_LOG_FILE  CONSTANT VARCHAR2(30) := 'DATAPUMPLOG';
  DATAFILE           CONSTANT VARCHAR2(30) := 'DATAFILE';

  -- system privileges
  MANAGE_FILE_GROUP           CONSTANT BINARY_INTEGER := 1;
  MANAGE_ANY_FILE_GROUP       CONSTANT BINARY_INTEGER := 2;
  READ_ANY_FILE_GROUP         CONSTANT BINARY_INTEGER := 3;

  -- object privileges
  MANAGE_ON_FILE_GROUP        CONSTANT BINARY_INTEGER := 1;
  READ_ON_FILE_GROUP          CONSTANT BINARY_INTEGER := 2;

  -- this procedure will be used to define a new file group to associate 
  -- versions of file sets. 
  PROCEDURE create_file_group(
    file_group_name               IN   VARCHAR2,
    keep_files                    IN   VARCHAR2  DEFAULT 'Y',
    min_versions                  IN   NUMBER    DEFAULT 2,
    max_versions                  IN   NUMBER    DEFAULT INFINITE,
    retention_days                IN   NUMBER    DEFAULT INFINITE,
    default_directory             IN   VARCHAR2  DEFAULT NULL,
    comments                      IN   VARCHAR2  DEFAULT NULL);

  -- this is used to alter the properties of the file group
  PROCEDURE alter_file_group(
    file_group_name                IN  VARCHAR2,
    keep_files                     IN  VARCHAR2 DEFAULT NULL,
    min_versions                   IN  NUMBER   DEFAULT NULL,
    max_versions                   IN  NUMBER   DEFAULT NULL,
    retention_days                 IN  NUMBER   DEFAULT NULL,
    new_default_directory          IN  VARCHAR2 DEFAULT NULL,
    remove_default_directory       IN  VARCHAR2 DEFAULT 'N',
    new_comments                   IN  VARCHAR2 DEFAULT NULL,
    remove_comments                IN  VARCHAR2 DEFAULT 'N');

  -- used to drop the file group
  PROCEDURE drop_file_group(
    file_group_name   IN  VARCHAR2,
    keep_files        IN  VARCHAR2 DEFAULT NULL);

  -- purges the file group using the retention policy
  PROCEDURE purge_file_group(
    file_group_name   IN VARCHAR2);

  -- create a versioned file set
  PROCEDURE create_version(
    file_group_name             IN  VARCHAR2,
    version_name                IN  VARCHAR2 DEFAULT NULL,
    default_directory           IN  VARCHAR2 DEFAULT NULL,
    comments                    IN  VARCHAR2 DEFAULT NULL);

  -- create a versioned file set. overloaded version to return version id.
  PROCEDURE create_version(
    file_group_name             IN  VARCHAR2,
    version_name                IN  VARCHAR2 DEFAULT NULL,
    default_directory           IN  VARCHAR2 DEFAULT NULL,
    comments                    IN  VARCHAR2 DEFAULT NULL,
    version_out                 OUT VARCHAR2);

  -- alter some properties of a file set version
  PROCEDURE alter_version( 
    file_group_name                IN  VARCHAR2, 
    version_name                   IN  VARCHAR2  DEFAULT NULL,
    new_version_name               IN  VARCHAR2  DEFAULT NULL,
    remove_version_name            IN  VARCHAR2  DEFAULT 'N',
    new_default_directory          IN  VARCHAR2  DEFAULT NULL,
    remove_default_directory       IN  VARCHAR2  DEFAULT 'N',
    new_comments                   IN  VARCHAR2  DEFAULT NULL,
    remove_comments                IN  VARCHAR2  DEFAULT 'N');

  -- drop a file set version from the file group
  PROCEDURE drop_version( 
    file_group_name   IN  VARCHAR2, 
    version_name      IN  VARCHAR2 DEFAULT NULL,
    keep_files        IN  VARCHAR2 DEFAULT NULL);

  -- add a file to a specific file set version of file group
  PROCEDURE add_file(
    file_group_name           IN  VARCHAR2,
    file_name                 IN  VARCHAR2,
    file_type                 IN  VARCHAR2 DEFAULT NULL,
    file_directory            IN  VARCHAR2 DEFAULT NULL,
    version_name              IN  VARCHAR2 DEFAULT NULL,
    comments                  IN  VARCHAR2 DEFAULT NULL);

  -- alter some properties of a file
  PROCEDURE alter_file( 
    file_group_name            IN  VARCHAR2,
    file_name                  IN  VARCHAR2,
    version_name               IN  VARCHAR2  DEFAULT NULL,
    new_file_name              IN  VARCHAR2  DEFAULT NULL,
    new_file_directory         IN  VARCHAR2  DEFAULT NULL,
    new_file_type              IN  VARCHAR2  DEFAULT NULL,
    remove_file_type           IN  VARCHAR2  DEFAULT 'N', 
    new_comments               IN  VARCHAR2  DEFAULT NULL,
    remove_comments            IN  VARCHAR2  DEFAULT 'N');

  -- remove a file from a versioned file set
  PROCEDURE remove_file(
    file_group_name            IN  VARCHAR2,
    file_name                  IN  VARCHAR2,
    version_name               IN  VARCHAR2 DEFAULT NULL,
    keep_file                  IN  VARCHAR2 DEFAULT NULL);

  -- grant system privileges for file group operations
  PROCEDURE grant_system_privilege(
    privilege                  IN  BINARY_INTEGER,
    grantee                    IN  VARCHAR2,
    grant_option               IN  BOOLEAN DEFAULT FALSE);

  -- revoke system privileges for file group operations
  PROCEDURE revoke_system_privilege(
    privilege                  IN  BINARY_INTEGER,
    revokee                    IN  VARCHAR2);

  -- grant alter/read_file_group privilege on the specified file group
  PROCEDURE grant_object_privilege(
    object_name             IN  VARCHAR2,
    privilege               IN  BINARY_INTEGER,
    grantee                 IN  VARCHAR2,
    grant_option            IN  BOOLEAN DEFAULT FALSE);

  -- revoke alter/read_file_group privilege on the specified file group
  PROCEDURE revoke_object_privilege(
    object_name             IN  VARCHAR2,
    privilege               IN  BINARY_INTEGER,
    revokee                 IN  VARCHAR2);

END dbms_file_group;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_file_group FOR sys.dbms_file_group
/
GRANT EXECUTE ON sys.dbms_file_group TO execute_catalog_role
/

