Rem
Rem $Header: catfgr.sql 11-mar-2005.13:22:40 htran Exp $
Rem
Rem catfgr.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catfgr.sql - CAT File Group Repository
Rem
Rem    DESCRIPTION
Rem      File Group Repository Views
Rem
Rem    NOTES
Rem    
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    htran       03/11/05 - only tranportable tablespaces in tablespaces view
Rem    alakshmi    04/30/04 - alakshmi_tbs_set
Rem    htran       04/20/04 - column name changes
Rem    alakshmi    04/19/04 - system privilege READ_ANY_FILE_GROUP 
Rem    htran       04/16/04 - _ALL views for export
Rem    alakshmi    04/14/04 - move grant of manage_any_file_group to 
Rem    alakshmi    04/05/04 - grant manage_any_file_group to DBA and SYSTEM 
Rem    htran       03/24/04 - fix fg owner/name in DBA_FILE_GROUP_EXPORT_INFO
Rem    htran       03/09/04 - file group in obj$
Rem    htran       03/02/04 - add some views for export
Rem    htran       02/24/04 - name generation sequence
Rem    htran       02/20/04 - remove XDB stuff
Rem    htran       02/18/04 - add datapump metadata views
Rem    htran       02/18/04 - Created
Rem

--
-- sequences
--

-- name generation sequence
BEGIN
  execute immediate 'CREATE SEQUENCE fgr$_names_s START WITH 1 NOCACHE';
EXCEPTION WHEN others THEN
  -- ok if the object exists
  IF sqlcode = -955 THEN
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

--
-- views
--

create or replace view DBA_FILE_GROUPS
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, KEEP_FILES, MIN_VERSIONS, MAX_VERSIONS,
   RETENTION_DAYS, CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select u.name, o.name, g.keep_files, g.min_versions, g.max_versions,
       g.retention_days, g.creation_time, g.user_comment,
       g.default_dir_obj
from sys.obj$ o, sys.user$ u, sys.fgr$_file_groups g
where o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUPS is
'Details about file groups'
/
comment on column DBA_FILE_GROUPS.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUPS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUPS.KEEP_FILES is
'Should on-disk files be purged when removed?'
/
comment on column DBA_FILE_GROUPS.MIN_VERSIONS is
'Minimum number of versions to keep'
/
comment on column DBA_FILE_GROUPS.MAX_VERSIONS is
'Maximum number of versions to keep'
/
comment on column DBA_FILE_GROUPS.RETENTION_DAYS is
'Keep versions at least this number of days'
/
comment on column DBA_FILE_GROUPS.CREATED is
'When the file group was created'
/
comment on column DBA_FILE_GROUPS.COMMENTS is
'User specified comment'
/
comment on column DBA_FILE_GROUPS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym DBA_FILE_GROUPS for DBA_FILE_GROUPS
/
grant select on DBA_FILE_GROUPS to select_catalog_role
/

create or replace view DBA_FILE_GROUP_VERSIONS
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, CREATOR,
   CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select u.name, o.name, v.version_name, v.version_id, v.creator,
       v.creation_time, v.user_comment, v.default_dir_obj
from sys.obj$ o, sys.user$ u, sys.fgr$_file_groups g,
     sys.fgr$_file_group_versions v
where g.file_group_id = v.file_group_id
      and o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUP_VERSIONS is
'Details about file group versions'
/
comment on column DBA_FILE_GROUP_VERSIONS.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUP_VERSIONS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUP_VERSIONS.VERSION_NAME is
'Name of the version'
/
comment on column DBA_FILE_GROUP_VERSIONS.VERSION is
'Internal version number'
/
comment on column DBA_FILE_GROUP_VERSIONS.CREATOR is
'Creator of the version'
/
comment on column DBA_FILE_GROUP_VERSIONS.CREATED is
'When the version was created'
/
comment on column DBA_FILE_GROUP_VERSIONS.COMMENTS is
'User specified comment'
/
comment on column DBA_FILE_GROUP_VERSIONS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym DBA_FILE_GROUP_VERSIONS
  for DBA_FILE_GROUP_VERSIONS
/
grant select on DBA_FILE_GROUP_VERSIONS to select_catalog_role
/

create or replace view DBA_FILE_GROUP_EXPORT_INFO
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, EXPORT_VERSION,
   PLATFORM_NAME, EXPORT_TIME, EXPORT_SCN, SOURCE_GLOBAL_NAME)
as
select u.name, o.name, v.version_name, v.version_id, i.export_version,
       i.export_platform, i.export_time, i.export_scn, i.source_db_name
from sys.obj$ o, sys.user$ u, sys.fgr$_file_group_export_info i,
     sys.fgr$_file_groups g, sys.fgr$_file_group_versions v
where i.version_guid = v.version_guid and v.file_group_id = g.file_group_id
      and o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUP_EXPORT_INFO is
'Details about export information of file group versions'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.VERSION_NAME is
'Name of the version'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.VERSION is
'Internal version number'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.EXPORT_VERSION is
'Compatibility level of export dump'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.PLATFORM_NAME is
'Platform export was done on'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.EXPORT_TIME is
'Export job start time'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.EXPORT_SCN is
'Export job scn'
/
comment on column DBA_FILE_GROUP_EXPORT_INFO.SOURCE_GLOBAL_NAME is
'Global name of the exporting database'
/
create or replace public synonym DBA_FILE_GROUP_EXPORT_INFO
  for DBA_FILE_GROUP_EXPORT_INFO
/
grant select on DBA_FILE_GROUP_EXPORT_INFO to select_catalog_role
/

create or replace view DBA_FILE_GROUP_FILES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, FILE_NAME,
   FILE_DIRECTORY, FILE_TYPE, FILE_SIZE, FILE_BLOCK_SIZE, COMMENTS)
as select u.name, o.name, v.version_name, v.version_id, f.file_name,
          f.file_dir_obj, f.file_type, f.file_size, f.file_blocksize,
          f.user_comment
from sys.obj$ o, sys.user$ u, sys.fgr$_file_group_files f,
     sys.fgr$_file_groups g, sys.fgr$_file_group_versions v
where f.version_guid = v.version_guid and v.file_group_id = g.file_group_id
      and o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUP_FILES is
'Details about file group files'
/
comment on column DBA_FILE_GROUP_FILES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUP_FILES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUP_FILES.VERSION_NAME is
'Name of the version'
/
comment on column DBA_FILE_GROUP_FILES.VERSION is
'Internal version number'
/
comment on column DBA_FILE_GROUP_FILES.FILE_NAME is
'Name of the file'
/
comment on column DBA_FILE_GROUP_FILES.FILE_DIRECTORY is
'Directory object for the file'
/
comment on column DBA_FILE_GROUP_FILES.FILE_TYPE is
'File type'
/
comment on column DBA_FILE_GROUP_FILES.FILE_SIZE is
'File size'
/
comment on column DBA_FILE_GROUP_FILES.FILE_BLOCK_SIZE is
'File block size'
/
comment on column DBA_FILE_GROUP_FILES.COMMENTS is
'User specified comment'
/
create or replace public synonym DBA_FILE_GROUP_FILES
  for DBA_FILE_GROUP_FILES
/
grant select on DBA_FILE_GROUP_FILES to select_catalog_role
/

create or replace view DBA_FILE_GROUP_TABLESPACES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, TABLESPACE_NAME)
as
select u.name, o.name, v.version_name, v.version_id,
       ti.tablespace_name
from sys.obj$ o, sys.user$ u, sys.fgr$_tablespace_info ti,
     sys.fgr$_file_groups g, sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
      and o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUP_TABLESPACES is
'Details about the transportable tablespaces in the file group repository'
/
comment on column DBA_FILE_GROUP_TABLESPACES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUP_TABLESPACES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUP_TABLESPACES.VERSION_NAME is
'Name of the version'
/
comment on column DBA_FILE_GROUP_TABLESPACES.VERSION is
'Internal version number'
/
comment on column DBA_FILE_GROUP_TABLESPACES.TABLESPACE_NAME is
'Name of the tablespace'
/
create or replace public synonym DBA_FILE_GROUP_TABLESPACES
  for DBA_FILE_GROUP_TABLESPACES
/
grant select on DBA_FILE_GROUP_TABLESPACES to select_catalog_role
/

create or replace view DBA_FILE_GROUP_TABLES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, OWNER,
   TABLE_NAME, TABLESPACE_NAME, SCN)
as
select u.name, o.name, v.version_name, v.version_id,
       ti.schema_name, ti.table_name, ti.tablespace_name, ti.scn
from sys.obj$ o, sys.user$ u, sys.fgr$_table_info ti, sys.fgr$_file_groups g,
     sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
      and o.owner# = u.user# and o.obj# = g.file_group_id
/

comment on table DBA_FILE_GROUP_TABLES is
'Details about the tables in the file group repository'
/
comment on column DBA_FILE_GROUP_TABLES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column DBA_FILE_GROUP_TABLES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column DBA_FILE_GROUP_TABLES.VERSION_NAME is
'Name of the version'
/
comment on column DBA_FILE_GROUP_TABLES.VERSION is
'Internal version number'
/
comment on column DBA_FILE_GROUP_TABLES.OWNER is
'Schema table belongs to'
/
comment on column DBA_FILE_GROUP_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_FILE_GROUP_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_FILE_GROUP_TABLES.SCN is
'SCN table was exported at'
/
create or replace public synonym DBA_FILE_GROUP_TABLES
  for DBA_FILE_GROUP_TABLES
/
grant select on DBA_FILE_GROUP_TABLES to select_catalog_role
/

-- selects file group information for use by export and ALL views
create or replace view "_ALL_FILE_GROUPS"
  (FILE_GROUP_ID, FILE_GROUP_OWNER, FILE_GROUP_NAME, KEEP_FILES, 
   MIN_VERSIONS, MAX_VERSIONS, RETENTION_DAYS, CREATED, COMMENTS, 
   DEFAULT_DIRECTORY, CREATOR)
as
select g.file_group_id, u.name, o.name, g.keep_files, g.min_versions, 
       g.max_versions, g.retention_days, g.creation_time, g.user_comment,
       g.default_dir_obj, g.creator
from sys.obj$ o, sys.user$ u, sys.fgr$_file_groups g
where o.owner# = u.user# and o.obj# = g.file_group_id and
      (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
       o.obj# in (select oa.obj# from sys.objauth$ oa
                  where grantee# in (select kzsrorol from x$kzsro)) or
       exists (select null from v$enabledprivs where priv_number in (
                                                         -277, -278)))
/
grant select on "_ALL_FILE_GROUPS" to public with grant option
/

create or replace view ALL_FILE_GROUPS
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, KEEP_FILES, MIN_VERSIONS, MAX_VERSIONS,
   RETENTION_DAYS, CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select file_group_owner, file_group_name, keep_files, min_versions, 
       max_versions, retention_days, created, comments, 
       default_directory
from "_ALL_FILE_GROUPS"
/

comment on table ALL_FILE_GROUPS is
'Details about file groups'
/
comment on column ALL_FILE_GROUPS.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUPS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUPS.KEEP_FILES is
'Should on-disk files be purged when removed?'
/
comment on column ALL_FILE_GROUPS.MIN_VERSIONS is
'Minimum number of versions to keep'
/
comment on column ALL_FILE_GROUPS.MAX_VERSIONS is
'Maximum number of versions to keep'
/
comment on column ALL_FILE_GROUPS.RETENTION_DAYS is
'Keep versions at least this number of days'
/
comment on column ALL_FILE_GROUPS.CREATED is
'When the file group was created'
/
comment on column ALL_FILE_GROUPS.COMMENTS is
'User specified comment'
/
comment on column ALL_FILE_GROUPS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym ALL_FILE_GROUPS for ALL_FILE_GROUPS
/
grant select on ALL_FILE_GROUPS to public with grant option
/

-- selects version information for export
create or replace view "_ALL_FILE_GROUP_VERSIONS"
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION_ID, VERSION_GUID,
   CREATOR, CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select g.file_group_owner, g.file_group_name, v.version_name, v.version_id, 
       v.version_guid, v.creator, v.creation_time, v.user_comment,
       v.default_dir_obj
from "_ALL_FILE_GROUPS" g, sys.fgr$_file_group_versions v
where g.file_group_id = v.file_group_id
/
grant select on "_ALL_FILE_GROUP_VERSIONS" to public with grant option
/

create or replace view ALL_FILE_GROUP_VERSIONS
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, CREATOR,
   CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select v.file_group_owner, v.file_group_name, v.version_name, v.version_id, 
       v.creator, v.created, v.comments, v.default_directory
from "_ALL_FILE_GROUP_VERSIONS" v
/

comment on table ALL_FILE_GROUP_VERSIONS is
'Details about file group versions'
/
comment on column ALL_FILE_GROUP_VERSIONS.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUP_VERSIONS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUP_VERSIONS.VERSION_NAME is
'Name of the version'
/
comment on column ALL_FILE_GROUP_VERSIONS.VERSION is
'Internal version number'
/
comment on column ALL_FILE_GROUP_VERSIONS.CREATOR is
'Creator of the version'
/
comment on column ALL_FILE_GROUP_VERSIONS.CREATED is
'When the version was created'
/
comment on column ALL_FILE_GROUP_VERSIONS.COMMENTS is
'User specified comment'
/
comment on column ALL_FILE_GROUP_VERSIONS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym ALL_FILE_GROUP_VERSIONS
  for ALL_FILE_GROUP_VERSIONS
/
grant select on ALL_FILE_GROUP_VERSIONS to public with grant option
/

-- selects export info for export
create or replace view "_ALL_FILE_GROUP_EXPORT_INFO"
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION_ID, VERSION_GUID,
   EXPORT_VERSION, PLATFORM_NAME, EXPORT_TIME, EXPORT_SCN,
   SOURCE_GLOBAL_NAME)
as
select g.file_group_owner, g.file_group_name, v.version_name, v.version_id, 
       v.version_guid, i.export_version, i.export_platform, i.export_time,
       i.export_scn, i.source_db_name 
from "_ALL_FILE_GROUPS" g, sys.fgr$_file_group_export_info i,
     sys.fgr$_file_group_versions v
where i.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/
grant select on "_ALL_FILE_GROUP_EXPORT_INFO" to public with grant option
/

create or replace view ALL_FILE_GROUP_EXPORT_INFO
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, EXPORT_VERSION,
   PLATFORM_NAME, EXPORT_TIME, EXPORT_SCN, SOURCE_GLOBAL_NAME)
as
select file_group_owner, file_group_name, version_name, version_id, 
       export_version, platform_name, export_time, export_scn,
       source_global_name 
from "_ALL_FILE_GROUP_EXPORT_INFO"
/

comment on table ALL_FILE_GROUP_EXPORT_INFO is
'Details about export information of file group versions'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.VERSION_NAME is
'Name of the version'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.VERSION is
'Internal version number'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.EXPORT_VERSION is
'Compatibility level of export dump'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.PLATFORM_NAME is
'Platform export was done on'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.EXPORT_TIME is
'Export job start time'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.EXPORT_SCN is
'Export job scn'
/
comment on column ALL_FILE_GROUP_EXPORT_INFO.SOURCE_GLOBAL_NAME is
'Global name of the exporting database'
/
create or replace public synonym ALL_FILE_GROUP_EXPORT_INFO
  for ALL_FILE_GROUP_EXPORT_INFO
/
grant select on ALL_FILE_GROUP_EXPORT_INFO to public with grant option
/

-- selects file group file information for export
create or replace view "_ALL_FILE_GROUP_FILES"
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION_ID, VERSION_GUID,
   FILE_NAME, FILE_DIRECTORY, FILE_TYPE, FILE_SIZE, FILE_BLOCKSIZE,
   COMMENTS, CREATOR, CREATED)
as select g.file_group_owner, g.file_group_name, v.version_name, 
     v.version_id, v.version_guid, f.file_name, f.file_dir_obj, f.file_type,
     f.file_size, f.file_blocksize, f.user_comment, f.creator, f.creation_time
from "_ALL_FILE_GROUPS" g, sys.fgr$_file_group_files f,
     sys.fgr$_file_group_versions v
where f.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/
grant select on "_ALL_FILE_GROUP_FILES" to public with grant option
/

create or replace view ALL_FILE_GROUP_FILES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, FILE_NAME,
   FILE_DIRECTORY, FILE_TYPE, FILE_SIZE, FILE_BLOCK_SIZE,COMMENTS)
as select file_group_owner, file_group_name, version_name, 
     version_id, file_name, file_directory, file_type, file_size,
     file_blocksize, comments
from "_ALL_FILE_GROUP_FILES"
/

comment on table ALL_FILE_GROUP_FILES is
'Details about file group files'
/
comment on column ALL_FILE_GROUP_FILES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUP_FILES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUP_FILES.VERSION_NAME is
'Name of the version'
/
comment on column ALL_FILE_GROUP_FILES.VERSION is
'Internal version number'
/
comment on column ALL_FILE_GROUP_FILES.FILE_NAME is
'Name of the file'
/
comment on column ALL_FILE_GROUP_FILES.FILE_DIRECTORY is
'Directory object for the file'
/
comment on column ALL_FILE_GROUP_FILES.FILE_TYPE is
'File type'
/
comment on column ALL_FILE_GROUP_FILES.FILE_SIZE is
'File size'
/
comment on column ALL_FILE_GROUP_FILES.FILE_BLOCK_SIZE is
'File block size'
/
comment on column ALL_FILE_GROUP_FILES.COMMENTS is
'User specified comment'
/
create or replace public synonym ALL_FILE_GROUP_FILES
  for ALL_FILE_GROUP_FILES
/
grant select on ALL_FILE_GROUP_FILES to public with grant option
/

-- select tablespaces information for export
create or replace view "_ALL_FILE_GROUP_TABLESPACES"
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION_ID, VERSION_GUID,
   TABLESPACE_NAME)
as
select g.file_group_owner, g.file_group_name, v.version_name, v.version_id,
       v.version_guid, ti.tablespace_name
from "_ALL_FILE_GROUPS" g, sys.fgr$_tablespace_info ti,
     sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/
grant select on "_ALL_FILE_GROUP_TABLESPACES" to public with grant option
/

create or replace view ALL_FILE_GROUP_TABLESPACES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, TABLESPACE_NAME)
as
select file_group_owner, file_group_name, version_name, version_id,
       tablespace_name
from "_ALL_FILE_GROUP_TABLESPACES"
/

comment on table ALL_FILE_GROUP_TABLESPACES is
'Details about the transportable tablespaces in the file group repository'
/
comment on column ALL_FILE_GROUP_TABLESPACES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUP_TABLESPACES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUP_TABLESPACES.VERSION_NAME is
'Name of the version'
/
comment on column ALL_FILE_GROUP_TABLESPACES.VERSION is
'Internal version number'
/
comment on column ALL_FILE_GROUP_TABLESPACES.TABLESPACE_NAME is
'Name of the tablespace'
/
create or replace public synonym ALL_FILE_GROUP_TABLESPACES
  for ALL_FILE_GROUP_TABLESPACES
/
grant select on ALL_FILE_GROUP_TABLESPACES to public with grant option
/

-- select table information for export
create or replace view "_ALL_FILE_GROUP_TABLES"
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION_ID, VERSION_GUID,
   OWNER, TABLE_NAME, TABLESPACE_NAME, SCN)
as
select g.file_group_owner, g.file_group_name, v.version_name, v.version_id,
       ti.version_guid, ti.schema_name, ti.table_name, ti.tablespace_name,
       ti.scn
from "_ALL_FILE_GROUPS" g, sys.fgr$_table_info ti, 
     sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/
grant select on "_ALL_FILE_GROUP_TABLES" to public with grant option
/

create or replace view ALL_FILE_GROUP_TABLES
  (FILE_GROUP_OWNER, FILE_GROUP_NAME, VERSION_NAME, VERSION, OWNER,
   TABLE_NAME, TABLESPACE_NAME, SCN)
as
select file_group_owner, file_group_name, version_name, version_id,
       owner, table_name, tablespace_name, scn
from "_ALL_FILE_GROUP_TABLES" 
/

comment on table ALL_FILE_GROUP_TABLES is
'Details about the tables in the file group repository'
/
comment on column ALL_FILE_GROUP_TABLES.FILE_GROUP_OWNER is
'Owner of the file group'
/
comment on column ALL_FILE_GROUP_TABLES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column ALL_FILE_GROUP_TABLES.VERSION_NAME is
'Name of the version'
/
comment on column ALL_FILE_GROUP_TABLES.VERSION is
'Internal version number'
/
comment on column ALL_FILE_GROUP_TABLES.OWNER is
'Schema table belongs to'
/
comment on column ALL_FILE_GROUP_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_FILE_GROUP_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_FILE_GROUP_TABLES.SCN is
'SCN table was exported at'
/
create or replace public synonym ALL_FILE_GROUP_TABLES
  for ALL_FILE_GROUP_TABLES
/
grant select on ALL_FILE_GROUP_TABLES to public with grant option
/

create or replace view "_USER_FILE_GROUPS"
  (FILE_GROUP_ID, FILE_GROUP_NAME, KEEP_FILES, 
   MIN_VERSIONS, MAX_VERSIONS, RETENTION_DAYS, CREATED, COMMENTS, 
   DEFAULT_DIRECTORY)
as
select g.file_group_id, o.name, g.keep_files, g.min_versions, 
       g.max_versions, g.retention_days, g.creation_time, g.user_comment,
       g.default_dir_obj
from sys.obj$ o, sys.user$ u, sys.fgr$_file_groups g
where o.owner# = u.user# and 
      o.owner# = USERENV('SCHEMAID') and 
      o.obj# = g.file_group_id
/

create or replace view USER_FILE_GROUPS
  (FILE_GROUP_NAME, KEEP_FILES, MIN_VERSIONS, MAX_VERSIONS,
   RETENTION_DAYS, CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select file_group_name, keep_files, min_versions, 
       max_versions, retention_days, created, comments, 
       default_directory
from "_USER_FILE_GROUPS"
/

comment on table USER_FILE_GROUPS is
'Details about file groups'
/
comment on column USER_FILE_GROUPS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUPS.KEEP_FILES is
'Should on-disk files be purged when removed?'
/
comment on column USER_FILE_GROUPS.MIN_VERSIONS is
'Minimum number of versions to keep'
/
comment on column USER_FILE_GROUPS.MAX_VERSIONS is
'Maximum number of versions to keep'
/
comment on column USER_FILE_GROUPS.RETENTION_DAYS is
'Keep versions at least this number of days'
/
comment on column USER_FILE_GROUPS.CREATED is
'When the file group was created'
/
comment on column USER_FILE_GROUPS.COMMENTS is
'User specified comment'
/
comment on column USER_FILE_GROUPS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym USER_FILE_GROUPS for USER_FILE_GROUPS
/
grant select on USER_FILE_GROUPS to public with grant option
/

create or replace view USER_FILE_GROUP_VERSIONS
  (FILE_GROUP_NAME, VERSION_NAME, VERSION, CREATOR,
   CREATED, COMMENTS, DEFAULT_DIRECTORY)
as
select g.file_group_name, v.version_name, v.version_id, 
       v.creator, v.creation_time, v.user_comment, v.default_dir_obj
from "_USER_FILE_GROUPS" g, sys.fgr$_file_group_versions v
where g.file_group_id = v.file_group_id
/

comment on table USER_FILE_GROUP_VERSIONS is
'Details about file group versions'
/
comment on column USER_FILE_GROUP_VERSIONS.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUP_VERSIONS.VERSION_NAME is
'Name of the version'
/
comment on column USER_FILE_GROUP_VERSIONS.VERSION is
'Internal version number'
/
comment on column USER_FILE_GROUP_VERSIONS.CREATOR is
'Creator of the version'
/
comment on column USER_FILE_GROUP_VERSIONS.CREATED is
'When the version was created'
/
comment on column USER_FILE_GROUP_VERSIONS.COMMENTS is
'User specified comment'
/
comment on column USER_FILE_GROUP_VERSIONS.DEFAULT_DIRECTORY is
'Default directory object'
/
create or replace public synonym USER_FILE_GROUP_VERSIONS
  for USER_FILE_GROUP_VERSIONS
/
grant select on USER_FILE_GROUP_VERSIONS to public with grant option
/

create or replace view USER_FILE_GROUP_EXPORT_INFO
  (FILE_GROUP_NAME, VERSION_NAME, VERSION, EXPORT_VERSION,
   PLATFORM_NAME, EXPORT_TIME, EXPORT_SCN, SOURCE_GLOBAL_NAME)
as
select g.file_group_name, v.version_name, v.version_id, 
       i.export_version, i.export_platform, i.export_time, i.export_scn,
       i.source_db_name
from "_USER_FILE_GROUPS" g, sys.fgr$_file_group_export_info i,
     sys.fgr$_file_group_versions v
where i.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/

comment on table USER_FILE_GROUP_EXPORT_INFO is
'Details about export information of file group versions'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.VERSION_NAME is
'Name of the version'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.VERSION is
'Internal version number'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.EXPORT_VERSION is
'Compatibility level of export dump'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.PLATFORM_NAME is
'Platform export was done on'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.EXPORT_TIME is
'Export job start time'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.EXPORT_SCN is
'Export job scn'
/
comment on column USER_FILE_GROUP_EXPORT_INFO.SOURCE_GLOBAL_NAME is
'Global name of the exporting database'
/
create or replace public synonym USER_FILE_GROUP_EXPORT_INFO
  for USER_FILE_GROUP_EXPORT_INFO
/
grant select on USER_FILE_GROUP_EXPORT_INFO to public with grant option
/

create or replace view USER_FILE_GROUP_FILES
  (FILE_GROUP_NAME, VERSION_NAME, VERSION, FILE_NAME,
   FILE_DIRECTORY, FILE_TYPE, FILE_SIZE, FILE_BLOCK_SIZE,COMMENTS)
as select g.file_group_name, v.version_name, 
     v.version_id, f.file_name, f.file_dir_obj, f.file_type,
     f.file_size, f.file_blocksize, f.user_comment
from "_USER_FILE_GROUPS" g, sys.fgr$_file_group_files f,
     sys.fgr$_file_group_versions v
where f.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/

comment on table USER_FILE_GROUP_FILES is
'Details about file group files'
/
comment on column USER_FILE_GROUP_FILES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUP_FILES.VERSION_NAME is
'Name of the version'
/
comment on column USER_FILE_GROUP_FILES.VERSION is
'Internal version number'
/
comment on column USER_FILE_GROUP_FILES.FILE_NAME is
'Name of the file'
/
comment on column USER_FILE_GROUP_FILES.FILE_DIRECTORY is
'Directory object for the file'
/
comment on column USER_FILE_GROUP_FILES.FILE_TYPE is
'File type'
/
comment on column USER_FILE_GROUP_FILES.FILE_SIZE is
'File size'
/
comment on column USER_FILE_GROUP_FILES.FILE_BLOCK_SIZE is
'File block size'
/
comment on column USER_FILE_GROUP_FILES.COMMENTS is
'User specified comment'
/
create or replace public synonym USER_FILE_GROUP_FILES
  for USER_FILE_GROUP_FILES
/
grant select on USER_FILE_GROUP_FILES to public with grant option
/

create or replace view USER_FILE_GROUP_TABLESPACES
  (FILE_GROUP_NAME, VERSION_NAME, VERSION, TABLESPACE_NAME)
as
select g.file_group_name, v.version_name, v.version_id,
       ti.tablespace_name
from "_USER_FILE_GROUPS" g, sys.fgr$_tablespace_info ti,
     sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/

comment on table USER_FILE_GROUP_TABLESPACES is
'Details about the transportable tablespaces in the file group repository'
/
comment on column USER_FILE_GROUP_TABLESPACES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUP_TABLESPACES.VERSION_NAME is
'Name of the version'
/
comment on column USER_FILE_GROUP_TABLESPACES.VERSION is
'Internal version number'
/
comment on column USER_FILE_GROUP_TABLESPACES.TABLESPACE_NAME is
'Name of the tablespace'
/
create or replace public synonym USER_FILE_GROUP_TABLESPACES
  for USER_FILE_GROUP_TABLESPACES
/
grant select on USER_FILE_GROUP_TABLESPACES to public with grant option
/

create or replace view USER_FILE_GROUP_TABLES
  (FILE_GROUP_NAME, VERSION_NAME, VERSION, OWNER,
   TABLE_NAME, TABLESPACE_NAME, SCN)
as
select g.file_group_name, v.version_name, v.version_id,
       ti.schema_name, ti.table_name, ti.tablespace_name, ti.scn
from "_USER_FILE_GROUPS" g, sys.fgr$_table_info ti, 
     sys.fgr$_file_group_versions v
where ti.version_guid = v.version_guid and v.file_group_id = g.file_group_id
/

comment on table USER_FILE_GROUP_TABLES is
'Details about the tables in the file group repository'
/
comment on column USER_FILE_GROUP_TABLES.FILE_GROUP_NAME is
'Name of the file group'
/
comment on column USER_FILE_GROUP_TABLES.VERSION_NAME is
'Name of the version'
/
comment on column USER_FILE_GROUP_TABLES.VERSION is
'Internal version number'
/
comment on column USER_FILE_GROUP_TABLES.OWNER is
'Schema table belongs to'
/
comment on column USER_FILE_GROUP_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_FILE_GROUP_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_FILE_GROUP_TABLES.SCN is
'SCN table was exported at'
/
create or replace public synonym USER_FILE_GROUP_TABLES
  for USER_FILE_GROUP_TABLES
/
grant select on USER_FILE_GROUP_TABLES to public with grant option
/
