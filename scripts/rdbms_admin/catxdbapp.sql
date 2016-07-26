Rem
Rem $Header: rdbms/admin/catxdbapp.sql /main/2 2009/09/03 15:01:33 spetride Exp $
Rem
Rem catxdbapp.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbapp.sql - Catalog script for Application users and workgroups 
Rem                      XDB support
Rem
Rem    DESCRIPTION
Rem      Defines XDB tables for Application users and workgroups 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    08/08/09 - changed AUTHORIZED into AUTHENTICATED
Rem    spetride    06/11/08 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


create table XDB.APP_USERS_AND_ROLES
 (guid    RAW(16),          
  name    VARCHAR2(1024) unique,    -- we should not be able to register a user and a role with same name
  isrole  VARCHAR2(3))
/

comment on table XDB.APP_USERS_AND_ROLES is
 'Application users and roles/workspaces'
/

comment on column XDB.APP_USERS_AND_ROLES.guid is
 'The GUID for user or role/workgroup'
/

comment on column XDB.APP_USERS_AND_ROLES.name is
'The name of user or role/workgroup'
/

comment on column XDB.APP_USERS_AND_ROLES.isrole is
 'Whether user or role/workgroup'
/


create table XDB.APP_ROLE_MEMBERSHIP
 (role_guid     RAW(16),
  member_guid   RAW(16))
/

comment on table XDB.APP_ROLE_MEMBERSHIP is
 'Application role membership'
/

comment on column XDB.APP_ROLE_MEMBERSHIP.role_guid is
 'The GUID for the role/workgroup'
/

comment on column XDB.APP_ROLE_MEMBERSHIP.member_guid is
 'The GUID of the role member'
/

grant select, insert, delete on XDB.APP_USERS_AND_ROLES to XDBADMIN;

grant select, insert, delete on XDB.APP_ROLE_MEMBERSHIP to XDBADMIN;


-- add the AUTHENTICATED role
declare
  ret boolean;
begin
  ret := dbms_xdbz.add_application_principal('AUTHENTICATED', XDB.DBMS_XDBZ.APPLICATION_ROLE);
end;
/
