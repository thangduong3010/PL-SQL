Rem
Rem $Header: dbmssts.sql 11-may-2007.16:25:59 yizhang Exp $
Rem
Rem dbmssts.sql
Rem
Rem Copyright (c) 2003, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmssts.sql - DBMS Streams TableSpaces
Rem
Rem    DESCRIPTION
Rem      Simplifies data provisioning via transportable tablespaces
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yizhang     03/26/07 - Fix bug 5040073
Rem    yizhang     12/21/06 - Fix bug 5394563
Rem    htran       04/20/04 - add no permission error 
Rem    alakshmi    04/16/04 - return tablespace names in attach_tablespaces 
Rem    alakshmi    02/25/04 - Tablespace rack APIs 
Rem    alakshmi    07/01/03 - Change current_platform to datafile_platform
Rem    alakshmi    06/07/03 - alakshmi_integration_demo
Rem    alakshmi    04/18/03 - Rename dbms_streams_tablespaces to 
Rem                           dbms_streams_tablespace_adm
Rem    jstamos     03/20/03 - add error messages
Rem    jstamos     03/18/03 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_streams_tablespace_adm AUTHID CURRENT_USER IS

TYPE tablespace_set IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;

TYPE directory_object_set IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;

TYPE file IS RECORD(
  directory_object VARCHAR2(32),
  file_name        VARCHAR2(4000));

TYPE file_set IS TABLE OF file INDEX BY BINARY_INTEGER;

directory_object_not_found EXCEPTION;
  PRAGMA exception_init(directory_object_not_found, -23609);
  dir_obj_not_found_num NUMBER := -23609;

file_converted_to_exists EXCEPTION;
  PRAGMA exception_init(file_converted_to_exists, -23657);
  file_converted_to_exists_num NUMBER := -23657;

internal_error EXCEPTION;
  PRAGMA exception_init(internal_error, -23610);
  internal_error_num NUMBER := -23610;

not_simple_tablespace EXCEPTION;
  PRAGMA exception_init(not_simple_tablespace, -23611);
  not_simple_tablespace_num NUMBER := -23611;

tablespace_not_found EXCEPTION;
  PRAGMA exception_init(tablespace_not_found, -23612);
  tablespace_not_found_num NUMBER := -23612;

tablespaces_in_target_db EXCEPTION;
  PRAGMA exception_init(tablespaces_in_target_db, -23635);
  tablespaces_in_target_db_num NUMBER := -23635;

invalid_tablespace_names EXCEPTION;
  PRAGMA exception_init(invalid_tablespace_names, -23636);
  invalid_tablespace_names_num NUMBER := -23636;

no_permissions_error EXCEPTION;
  PRAGMA exception_init(no_permissions_error, -6564);
  no_permissions_error_num NUMBER := -6564;

PROCEDURE detach_simple_tablespace(
            tablespace_name      IN  VARCHAR2,
            directory_object     OUT VARCHAR2,
            tablespace_file_name OUT VARCHAR2);

PROCEDURE clone_simple_tablespace(
            tablespace_name      IN  VARCHAR2,
            directory_object     IN  VARCHAR2,
            destination_platform IN  VARCHAR2 DEFAULT NULL,
            tablespace_file_name OUT VARCHAR2);

PROCEDURE attach_simple_tablespace(
            directory_object     IN  VARCHAR2,
            tablespace_file_name IN  VARCHAR2,
            converted_file_name  IN  VARCHAR2 DEFAULT NULL,
            datafile_platform    IN  VARCHAR2 DEFAULT NULL,
            tablespace_name      OUT VARCHAR2);

PROCEDURE pull_simple_tablespace(
            tablespace_name          IN VARCHAR2,
            database_link            IN VARCHAR2,
            directory_object         IN VARCHAR2 DEFAULT NULL,
            conversion_extension     IN VARCHAR2 DEFAULT NULL,
            convert_directory_object IN VARCHAR2 DEFAULT NULL);

PROCEDURE detach_tablespaces(
            datapump_job_name IN OUT VARCHAR2,
            tablespace_names  IN     tablespace_set,
            dump_file         IN     file,
            log_file          IN     file DEFAULT NULL,
            tablespace_files     OUT file_set);

-- This version of detach_tablespace records the tablespace info in
-- the file group repository.
PROCEDURE detach_tablespaces(
            tablespace_names             IN     tablespace_set,
            export_directory_object      IN     VARCHAR2 DEFAULT NULL,
            log_file_directory_object    IN     VARCHAR2 DEFAULT NULL,
            file_group_name              IN     VARCHAR2,
            version_name                 IN     VARCHAR2 DEFAULT NULL,
            repository_db_link           IN     VARCHAR2 DEFAULT NULL);

PROCEDURE clone_tablespaces(
            datapump_job_name            IN OUT VARCHAR2,
            tablespace_names             IN     tablespace_set,
            dump_file                    IN     file,
            tablespace_directory_objects IN     directory_object_set,
            destination_platform         IN     VARCHAR2 DEFAULT NULL,
            log_file                     IN     file DEFAULT NULL,
            tablespace_files                OUT file_set);

-- This version of clone_tablespace records the tablespace info in
-- the file group repository
PROCEDURE clone_tablespaces(
            tablespace_names             IN     tablespace_set,
            tablespace_directory_object  IN     VARCHAR2 DEFAULT NULL,
            log_file_directory_object    IN     VARCHAR2 DEFAULT NULL,
            file_group_name              IN     VARCHAR2,
            version_name                 IN     VARCHAR2 DEFAULT NULL,
            repository_db_link           IN     VARCHAR2 DEFAULT NULL);

PROCEDURE attach_tablespaces(
            datapump_job_name  IN OUT VARCHAR2,
            dump_file          IN     file,
            tablespace_files   IN     file_set,
            converted_files    IN     file_set,
            datafiles_platform IN     VARCHAR2 DEFAULT NULL,
            log_file           IN     file DEFAULT NULL,
            tablespace_names      OUT tablespace_set);

-- This version of attach_tablespace plugs-in the specified version of
-- the tablespace(s) from the file group repository
PROCEDURE attach_tablespaces(
            file_group_name              IN     VARCHAR2,
            version_name                 IN     VARCHAR2 DEFAULT NULL,
            datafiles_directory_object   IN     VARCHAR2 DEFAULT NULL,
            log_file_directory_object    IN     VARCHAR2 DEFAULT NULL,
            repository_db_link           IN     VARCHAR2 DEFAULT NULL,
            tablespace_names                OUT tablespace_set);

-- Added convert_directory_object. This is the directory that should be
-- created at the source database. The file conversion will be done at
-- the source database.
PROCEDURE pull_tablespaces(
            datapump_job_name            IN OUT VARCHAR2,
            database_link                IN     VARCHAR2,
            tablespace_names             IN     tablespace_set,
            tablespace_directory_objects IN     directory_object_set,
            log_file                     IN     file,
            conversion_extension         IN     VARCHAR2 DEFAULT NULL,
            convert_directory_object     IN     VARCHAR2 DEFAULT NULL);

-- The following package variable is for internal use only.
"_trace_level" NUMBER;

END dbms_streams_tablespace_adm;
/

show error

CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_tablespace_adm FOR
   dbms_streams_tablespace_adm
/

GRANT EXECUTE ON dbms_streams_tablespace_adm TO execute_catalog_role
/
