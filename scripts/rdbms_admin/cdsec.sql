Rem
Rem $Header: rdbms/admin/cdsec.sql /st_rdbms_11.2.0/1 2012/05/01 11:36:18 youyang Exp $
Rem
Rem cdsec.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdsec.sql - Catalog DSEC.bsq views
Rem
Rem    DESCRIPTION
Rem      Privilege objects
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in dsec.bsq.  
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     04/19/12 - lrg6921519:grant sys privileges with admin option
Rem    ssonawan    02/05/08 - bug 6757203: fix DBA_ROLES view definition to
Rem                           correctly describe role's authentication type
Rem    achoi       09/11/06 - fix bug 5508217
Rem    cdilling    08/08/06 - Add cataudit.sql
Rem    cdilling    05/04/06 - Created
Rem

@@cataudit

remark
remark  FAMILY "PRIVILEGE MAP"
remark  Tables for mapping privilege numbers to privilege names.
remark
remark  SYSTEM_PRIVILEGE_MAP now in sql.bsq
remark
remark  TABLE_PRIVILEGE_MAP now in sql.bsq
remark
remark
remark  FAMILY "PRIVS"
remark

create or replace view SESSION_PRIVS
    (PRIVILEGE)
as
select spm.name
from sys.v$enabledprivs ep, system_privilege_map spm
where spm.privilege = ep.priv_number
/
comment on table SESSION_PRIVS is
'Privileges which the user currently has set'
/
comment on column SESSION_PRIVS.PRIVILEGE is
'Privilege Name'
/
create or replace public synonym SESSION_PRIVS for SESSION_PRIVS
/
grant select on SESSION_PRIVS to PUBLIC with grant option
/


remark
remark  FAMILY "ROLES"
remark
create or replace view SESSION_ROLES
    (ROLE)
as
select u.name
from x$kzsro,user$ u
where kzsrorol!=userenv('SCHEMAID') and kzsrorol!=1 and u.user#=kzsrorol
/
comment on table SESSION_ROLES is
'Roles which the user currently has enabled.'
/
comment on column SESSION_ROLES.ROLE is
'Role name'
/
create or replace public synonym SESSION_ROLES for SESSION_ROLES
/
grant select on SESSION_ROLES to PUBLIC with grant option
/
create or replace view ROLE_SYS_PRIVS
    (ROLE, PRIVILEGE, ADMIN_OPTION)
as
select u.name,spm.name,decode(min(option$),1,'YES','NO')
from  sys.user$ u, sys.system_privilege_map spm, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
  and u.user#=sa.grantee# and sa.privilege#=spm.privilege
group by u.name, spm.name
/
comment on table ROLE_SYS_PRIVS is
'System privileges granted to roles'
/
comment on column ROLE_SYS_PRIVS.ROLE is
'Role name'
/
comment on column ROLE_SYS_PRIVS.PRIVILEGE is
'System Privilege'
/
comment on column ROLE_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym ROLE_SYS_PRIVS for ROLE_SYS_PRIVS
/
grant select on ROLE_SYS_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_TAB_PRIVS
    (ROLE, OWNER, TABLE_NAME, COLUMN_NAME, PRIVILEGE, GRANTABLE)
as
select u1.name,u2.name,o.name,col$.name,tpm.name,
       decode(max(mod(oa.option$,2)), 1, 'YES', 'NO')
from  sys.user$ u1,sys.user$ u2,sys.table_privilege_map tpm,
      sys.objauth$ oa,sys."_CURRENT_EDITION_OBJ" o,sys.col$
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=oa.grantee# and oa.privilege#=tpm.privilege
   and oa.obj#=o.obj# and oa.obj#=col$.obj#(+) and oa.col#=col$.col#(+)
   and u2.user#=o.owner#
  and (col$.property IS NULL OR bitand(col$.property, 32) = 0 )
group by u1.name,u2.name,o.name,col$.name,tpm.name
/

comment on table ROLE_TAB_PRIVS is
'Table privileges granted to roles'
/
comment on column ROLE_TAB_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_TAB_PRIVS.TABLE_NAME is
'Table Name or Sequence Name'
/
comment on column ROLE_TAB_PRIVS.COLUMN_NAME is
'Column Name if applicable'
/
comment on column ROLE_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
create or replace public synonym ROLE_TAB_PRIVS for ROLE_TAB_PRIVS
/
grant select on ROLE_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_ROLE_PRIVS
    (ROLE, GRANTED_ROLE, ADMIN_OPTION)
as
select u1.name,u2.name,decode(min(option$),1,'YES','NO')
from  sys.user$ u1, sys.user$ u2, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=sa.grantee# and u2.user#=sa.privilege#
group by u1.name,u2.name
/
comment on table ROLE_ROLE_PRIVS is
'Roles which are granted to roles'
/
comment on column ROLE_ROLE_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_ROLE_PRIVS.GRANTED_ROLE is
'Role which was granted'
/
comment on column ROLE_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym ROLE_ROLE_PRIVS for ROLE_ROLE_PRIVS
/
grant select on ROLE_ROLE_PRIVS to PUBLIC with grant option
/
create or replace view DBA_ROLES (ROLE, PASSWORD_REQUIRED, AUTHENTICATION_TYPE)
as
select name, decode(password, null,          'NO',
                              'EXTERNAL',    'EXTERNAL',
                              'GLOBAL',      'GLOBAL',
                              'YES'),
             decode(password, null,          'NONE',
                              'EXTERNAL',    'EXTERNAL',
                              'GLOBAL',      'GLOBAL',
                              'APPLICATION', 'APPLICATION',
                              'PASSWORD')
from  user$
where type# = 0 and name not in ('PUBLIC', '_NEXT_USER')
/
create or replace public synonym DBA_ROLES for DBA_ROLES
/
grant select on DBA_ROLES to select_catalog_role
/
comment on table DBA_ROLES is
'All Roles which exist in the database'
/
comment on column DBA_ROLES.ROLE is
'Role Name'
/
comment on column DBA_ROLES.PASSWORD_REQUIRED is
'Depreacted from 11.2 -- use AUTHENTICATION_TYPE instead'
/
comment on column DBA_ROLES.AUTHENTICATION_TYPE is
'Indicates authentication mechanism for the role'
/

remark
remark  FAMILY "SYS GRANTS"
remark
remark
create or replace view USER_SYS_PRIVS
    (USERNAME, PRIVILEGE, ADMIN_OPTION)
as
select decode(sa.grantee#,1,'PUBLIC',su.name),spm.name,
       decode(min(option$),1,'YES','NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, sys.user$ su
where ((sa.grantee#=userenv('SCHEMAID') and su.user#=sa.grantee#)
       or sa.grantee#=1)
  and sa.privilege#=spm.privilege
group by decode(sa.grantee#,1,'PUBLIC',su.name),spm.name
/
comment on table USER_SYS_PRIVS is
'System privileges granted to current user'
/
comment on column USER_SYS_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column USER_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym USER_SYS_PRIVS for USER_SYS_PRIVS
/
grant select on USER_SYS_PRIVS to PUBLIC with grant option
/
create or replace view DBA_SYS_PRIVS
    (GRANTEE, PRIVILEGE, ADMIN_OPTION)
as
select u.name,spm.name,decode(min(option$),1,'YES','NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, user$ u
where sa.grantee#=u.user# and sa.privilege#=spm.privilege
group by u.name,spm.name
/
create or replace public synonym DBA_SYS_PRIVS for DBA_SYS_PRIVS
/
grant select on DBA_SYS_PRIVS to select_catalog_role
/
comment on table DBA_SYS_PRIVS is
'System privileges granted to users and roles'
/
comment on column DBA_SYS_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column DBA_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/

remark
remark  FAMILY "PROXIES"
remark  Allowed proxy authentication methods
remark
create or replace view USER_PROXIES
    (CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE)
as
select u.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE'),
       (select u.name from sys.user$ u where pr.role# = u.user#)
from sys.user$ u, sys.proxy_info$ p, sys.proxy_role_info$ pr
where u.user#  = p.client#
  and p.proxy#  = pr.proxy#(+)
  and p.client# = pr.client#(+)
  and p.proxy# = userenv('SCHEMAID')
/
comment on table USER_PROXIES is
'Description of connections the user is allowed to proxy'
/
comment on column USER_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column USER_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column USER_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column USER_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
create or replace public synonym USER_PROXIES for USER_PROXIES
/
grant select on USER_PROXIES to PUBLIC with grant option
/

create or replace view DBA_PROXIES
    (PROXY, CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE, PROXY_AUTHORITY)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE',
                      16, 'PROXY MAY ACTIVATE ALL CLIENT ROLES'),
       (select u.name from sys.user$ u where pr.role# = u.user#),
       case p.flags when 16 then 'DIRECTORY' else 'DATABASE' end
from sys.user$ u1, sys.user$ u2,
     sys.proxy_info$ p, sys.proxy_role_info$ pr
where u1.user#(+)  = p.proxy#
  and u2.user#     = p.client#
  and p.proxy#     = pr.proxy#(+)
  and p.client#    = pr.client#(+)
/
comment on table DBA_PROXIES is
'Information about all proxy connections'
/
comment on column DBA_PROXIES.PROXY is
'Name of the proxy user'
/
comment on column DBA_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column DBA_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column DBA_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column DBA_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
comment on column DBA_PROXIES.PROXY_AUTHORITY is
'Indicates where proxy permissions are managed'
/
create or replace public synonym DBA_PROXIES for DBA_PROXIES
/
grant select on DBA_PROXIES to select_catalog_role
/

rem Contains a list of all proxy users and the clients upon whose behalf they
rem can act
create or replace view PROXY_USERS
    (PROXY, CLIENT, AUTHENTICATION, FLAGS)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE')
from sys.user$ u1, sys.user$ u2, sys.proxy_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
/
comment on table PROXY_USERS is
'List of proxy users and the client on whose behalf they can act.'
/
comment on column PROXY_USERS.PROXY is
'Name of a proxy user'
/
comment on column PROXY_USERS.CLIENT is
'Name of the client user who the proxy user can act as'
/
comment on column PROXY_USERS.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column PROXY_USERS.FLAGS is
'Flags associated with the proxy/client pair'
/
create or replace public synonym PROXY_USERS for PROXY_USERS
/
grant select on PROXY_USERS to SELECT_CATALOG_ROLE
/

rem List of roles that may executed by a proxy user on behalf of a client.
create or replace view PROXY_ROLES (PROXY, CLIENT, ROLE)
as
select u1.name,
       u2.name,
       u3.name
from sys.user$ u1, sys.user$ u2, sys.user$ u3, sys.proxy_role_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
  and u3.user# = p.role#
/
comment on table PROXY_ROLES is
'Table of roles that a proxy can set on behalf of a client'
/
comment on column PROXY_ROLES.PROXY is
'Name of a proxy user'
/
comment on column PROXY_ROLES.CLIENT is
'Name of the client user who the proxy user acts as'
/
comment on column PROXY_ROLES.ROLE is
'Name of the role that the proxy can execute'
/
create or replace public synonym PROXY_ROLES for PROXY_ROLES
/
grant select on PROXY_ROLES to SELECT_CATALOG_ROLE
/

rem List of all proxies, clients and roles.
create or replace view PROXY_USERS_AND_ROLES (PROXY, CLIENT, FLAGS, ROLE)
as
select u.proxy,
       u.client,
       u.flags,
       r.role
from sys.proxy_users u, sys.proxy_roles r
where u.proxy  = r.proxy
  and u.client = r.client
/
comment on table PROXY_USERS_AND_ROLES is
'List of all proxies, clients and roles.'
/
comment on column PROXY_USERS_AND_ROLES.PROXY is
'Name of the proxy user'
/
comment on column PROXY_USERS_AND_ROLES.CLIENT is
'Name of the client user'
/
comment on column PROXY_USERS_AND_ROLES.FLAGS is
'Flags corresponding to the proxy/client combination'
/
comment on column PROXY_USERS_AND_ROLES.ROLE is
'Name of the role that a proxy can execute while acting on behalf of the
client'
/
create or replace public synonym PROXY_USERS_AND_ROLES
   for PROXY_USERS_AND_ROLES
/
grant select on PROXY_USERS_AND_ROLES to SELECT_CATALOG_ROLE
/

create or replace view DBA_CONNECT_ROLE_GRANTEES
  (GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'CONNECT'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from user$ where name = upper(grantee)),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('CONNECT'))
/
comment on table DBA_CONNECT_ROLE_GRANTEES is
'Information regarding which users are granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.GRANTEE is
'User or schema to which CONNECT is granted'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.PATH_OF_CONNECT_ROLE_GRANT is
'The path of role inheritence through which the grantee is granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.ADMIN_OPT is
'If the grantee was granted the CONNECT role with Admin Option'
/
create or replace public synonym DBA_CONNECT_ROLE_GRANTEES
for DBA_CONNECT_ROLE_GRANTEES
/
grant select on DBA_CONNECT_ROLE_GRANTEES to select_catalog_role
/
grant select any table, delete any table, update any table, insert any table to sys with admin option
/
