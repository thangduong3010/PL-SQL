Rem
Rem $Header: catepg.sql 15-feb-2005.11:00:12 rpang Exp $
Rem
Rem catepg.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catepg.sql - Embedded PL/SQL Gateway related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the tables and views required for supporting the
Rem     the embedded PL/SQL gateway.
Rem
Rem    NOTES
Rem      This script should be run as "SYS".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       02/15/05 - No set echo 
Rem    rpang       10/08/04 - Created
Rem


Rem
Rem DAD authorization information storage
Rem

create table EPG$_AUTH
( DADNAME            varchar2(64) not null,                      /* DAD name */
  USER#              number not null, /* user authorized for use by this DAD */
  constraint epg$_auth_pk primary key (dadname,user#)
)
/

Rem
Rem User DAD authorization view
Rem

create or replace view USER_EPG_DAD_AUTHORIZATION
(DAD_NAME)
as
select ea.dadname
from epg$_auth ea
where ea.user# = userenv('SCHEMAID')
/
create or replace public synonym USER_EPG_DAD_AUTHORIZATION for USER_EPG_DAD_AUTHORIZATION
/
grant select on USER_EPG_DAD_AUTHORIZATION to public
/
comment on table USER_EPG_DAD_AUTHORIZATION is
'DADs authorized to use the user''s privileges'
/
comment on column USER_EPG_DAD_AUTHORIZATION.DAD_NAME is
'Name of DAD'
/

Rem
Rem DBA DAD authorization view
Rem

create or replace view DBA_EPG_DAD_AUTHORIZATION
(DAD_NAME, USERNAME)
as
select ea.dadname, u.name
from epg$_auth ea, user$ u
where ea.user# = u.user#
/
create or replace public synonym DBA_EPG_DAD_AUTHORIZATION for DBA_EPG_DAD_AUTHORIZATION
/
grant select on DBA_EPG_DAD_AUTHORIZATION to select_catalog_role
/
grant select on DBA_EPG_DAD_AUTHORIZATION to xdbadmin
/
comment on table DBA_EPG_DAD_AUTHORIZATION is
'DADs authorized to use different user''s privileges'
/
comment on column DBA_EPG_DAD_AUTHORIZATION.DAD_NAME is
'Name of DAD'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
'Name of the user whose privileges the DAD is authorized to use'
/
