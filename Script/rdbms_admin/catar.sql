Rem
Rem $Header: catar.sql 24-may-2001.11:44:24 gviswana Exp $
Rem
Rem catar.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      catar.sql - catalog for application role
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for application role
Rem
Rem    NOTES
Rem      Must be run while connected to SYS
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    dmwong      03/11/01 - fix missing and's.
Rem    dmwong      03/01/01 - rename dict vws to be consistent with the rest.
Rem    dmwong      01/15/01 - add comments to columns.
Rem    dmwong      12/19/00 - add public synonyms.
Rem    dmwong      09/22/98 - catalog view for application role                
Rem    dmwong      09/22/98 - Created
Rem

create or replace view DBA_APPLICATION_ROLES
(ROLE, SCHEMA, PACKAGE )
as
select u.name, schema, package  from 
user$ u, approle$ a 
where  u.user# = a.role#
/
comment on column DBA_APPLICATION_ROLES.ROLE is
'Name of Application Role'
/
comment on column DBA_APPLICATION_ROLES.SCHEMA is
'Schema name of authorizing package'
/
comment on column DBA_APPLICATION_ROLES.PACKAGE is
'Name of authorizing package'
/
create or replace public synonym DBA_APPLICATION_ROLES
   for DBA_APPLICATION_ROLES
/
grant select on DBA_APPLICATION_ROLES to select_catalog_role
/

create or replace view USER_APPLICATION_ROLES
(ROLE, SCHEMA, PACKAGE )
as
select u.name, schema, package  from 
user$ u, approle$ a 
where  u.user# = a.role#
and u.user# = uid
/
comment on column USER_APPLICATION_ROLES.ROLE is
'Name of Application Role'
/
comment on column USER_APPLICATION_ROLES.SCHEMA is
'Schema name of authorizing package'
/
comment on column USER_APPLICATION_ROLES.PACKAGE is
'Name of authorizing package'
/
create or replace public synonym USER_APPLICATION_ROLES
   for USER_APPLICATION_ROLES
/
grant select on USER_APPLICATION_ROLES to public with grant option
/
