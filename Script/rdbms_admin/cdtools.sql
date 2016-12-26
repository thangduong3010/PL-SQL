Rem
Rem $Header: cdtools.sql 09-may-2006.14:20:03 cdilling Exp $
Rem
Rem cdtools.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdtools.sql - Catalog DTOOLS.bsq views
Rem
Rem    DESCRIPTION
Rem      exp_objects, exp_files, etc.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dtools.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    05/04/06 - Created
Rem

remark
remark  FAMILY "EXP_OBJECTS"
remark  Objects that have been incrementally exported.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_OBJECTS
    (OWNER, OBJECT_NAME, OBJECT_TYPE, CUMULATIVE, INCREMENTAL, EXPORT_VERSION)
as
select u.name, o.name,
       decode(o.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
                      12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                      22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                      30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
       o.ctime, o.itime, o.expid
from sys.incexp o, sys.user$ u
where o.owner# = u.user#
/
create or replace public synonym DBA_EXP_OBJECTS for DBA_EXP_OBJECTS
/
grant select on DBA_EXP_OBJECTS to select_catalog_role
/
comment on table DBA_EXP_OBJECTS is
'Objects that have been incrementally exported'
/
comment on column DBA_EXP_OBJECTS.OWNER is
'Owner of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_NAME is
'Name of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_TYPE is
'Type of exported object'
/
comment on column DBA_EXP_OBJECTS.CUMULATIVE is
'Timestamp of last cumulative export'
/
comment on column DBA_EXP_OBJECTS.INCREMENTAL is
'Timestamp of last incremental export'
/
comment on column DBA_EXP_OBJECTS.EXPORT_VERSION is
'The id of the export session'
/
remark
remark  FAMILY "EXP_VERSION"
remark  Version number of last incremental export
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_VERSION
    (EXP_VERSION)
as
select o.expid
from sys.incvid o
/
create or replace public synonym DBA_EXP_VERSION for DBA_EXP_VERSION
/
grant select on DBA_EXP_VERSION to select_catalog_role
/
comment on table DBA_EXP_VERSION is
'Version number of the last export session'
/
comment on column DBA_EXP_VERSION.EXP_VERSION is
'Version number of the last export session'
/
remark
remark  FAMILY "EXP_FILES"
remark  Files created by incremental exports.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_FILES
     (EXP_VERSION, EXP_TYPE, FILE_NAME, USER_NAME, TIMESTAMP)
as
select o.expid, decode(o.exptype, 'X', 'COMPLETE', 'C', 'CUMULATIVE',
                                  'I', 'INCREMENTAL', 'UNDEFINED'),
       o.expfile, o.expuser, o.expdate
from sys.incfil o
/
create or replace public synonym DBA_EXP_FILES for DBA_EXP_FILES
/
grant select on DBA_EXP_FILES to select_catalog_role
/
comment on table DBA_EXP_FILES is
'Description of export files'
/
comment on column DBA_EXP_FILES.EXP_VERSION is
'Version number of the export session'
/
comment on column DBA_EXP_FILES.FILE_NAME is
'Name of the export file'
/
comment on column DBA_EXP_FILES.USER_NAME is
'Name of user who executed export'
/
comment on column DBA_EXP_FILES.TIMESTAMP is
'Timestamp of the export session'
/
