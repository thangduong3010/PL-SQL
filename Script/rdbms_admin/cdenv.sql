Rem
Rem $Header: cdenv.sql 31-mar-2008.22:06:03 ssonawan Exp $
Rem
Rem cdenv.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdenv.sql - Catalog DENV.bsq views
Rem
Rem    DESCRIPTION
Rem      profiles, resources, etc.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in denv.bsq.   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssonawan    02/11/08 - bug 6757203: fix DBA_USERS view definition to
Rem                           correctly describe user's authentication type 
Rem    vigaur      01/25/07 - Bug 4758283 Changes
Rem    vigaur      12/18/06 - 
Rem    gviswana    08/25/06 - Use DECODE for EDITIONS_ENABLED
Rem    gviswana    07/27/06 - ALTER USER ENABLE EDITIONS 
Rem    rhanckel    05/19/06 - Modifing dba users. 
Rem    cdilling    05/04/06 - Created
Rem


remark
remark These are table that actually enables the user to see his or her
remark limits
remark
create or replace view DBA_PROFILES
    (PROFILE, RESOURCE_NAME, RESOURCE_TYPE, LIMIT)
as select
   n.name, m.name,
   decode(u.type#, 0, 'KERNEL', 1, 'PASSWORD', 'INVALID'),
   decode(u.limit#,
          0, 'DEFAULT',
          2147483647, decode(u.resource#,
                             4, decode(u.type#,
                                       1, 'NULL', 'UNLIMITED'),
                             'UNLIMITED'),
          decode(u.resource#,
                 4, decode(u.type#, 1, o.name, u.limit#),
                 decode(u.type#,
                        0, u.limit#,
                        decode(u.resource#,
                               1, trunc(u.limit#/86400, 4),
                               2, trunc(u.limit#/86400, 4),
                               5, trunc(u.limit#/86400, 4),
                               6, trunc(u.limit#/86400, 4),
                               u.limit#))))
  from sys.profile$ u, sys.profname$ n, sys.resource_map m, sys.obj$ o
  where u.resource# = m.resource#
  and u.type#=m.type#
  and o.obj# (+) = u.limit#
  and n.profile# = u.profile#
/
create or replace public synonym DBA_PROFILES for DBA_PROFILES
/
grant select on DBA_PROFILES to select_catalog_role
/
comment on table DBA_PROFILES is
'Display all profiles and their limits'
/
comment on column DBA_PROFILES.PROFILE is
'Profile name'
/
comment on column DBA_PROFILES.RESOURCE_NAME is
'Resource name'
/
comment on column DBA_PROFILES.LIMIT is
'Limit placed on this resource for this profile'
/

REM
REM  This view enables the user to see his own profile limits
REM
create or replace view USER_RESOURCE_LIMITS
    (RESOURCE_NAME, LIMIT)
as select m.name,
          decode (u.limit#, 2147483647, 'UNLIMITED',
                           0, decode (p.limit#, 2147483647, 'UNLIMITED',
                                               p.limit#),
                           u.limit#)
  from sys.profile$ u, sys.profile$ p,
       sys.resource_map m, user$ s
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 0
  and m.type# = 0
  and s.resource$ = u.profile#
  and s.user# = userenv('SCHEMAID')
/
comment on table USER_RESOURCE_LIMITS is
'Display resource limit of the user'
/
comment on column USER_RESOURCE_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_RESOURCE_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_RESOURCE_LIMITS for USER_RESOURCE_LIMITS
/
grant select on USER_RESOURCE_LIMITS to PUBLIC with grant option
/
create or replace view USER_PASSWORD_LIMITS
    (RESOURCE_NAME, LIMIT)
as select
  m.name,
  decode(u.limit#,
         2147483647, decode(u.resource#, 4, 'NULL', 'UNLIMITED'),
         -1, 0,
         0, decode(p.limit#,
                   2147483647, decode(p.resource#, 4, 'NULL', 'UNLIMITED'),
                   -1, 0,
                   decode(p.resource#,
                          4, po.name,
                          1, trunc(p.limit#/86400, 4),
                          2, trunc(p.limit#/86400, 4),
                          5, trunc(p.limit#/86400, 4),
                          6, trunc(p.limit#/86400, 4), p.limit#)),
         decode(u.resource#,
                4, uo.name,
                1, trunc(u.limit#/86400, 4),
                2, trunc(u.limit#/86400, 4),
                5, trunc(u.limit#/86400, 4),
                6, trunc(u.limit#/86400, 4),
                u.limit#))
  from sys.profile$ u, sys.profile$ p, sys.obj$ uo, sys.obj$ po,
       sys.resource_map m, sys.user$ s
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 1
  and m.type# = 1
  and uo.obj#(+) = u.limit#
  and po.obj#(+) = p.limit#
  and s.resource$ = u.profile#
  and s.user# = userenv('SCHEMAID')
/
comment on table USER_PASSWORD_LIMITS is
'Display password limits of the user'
/
comment on column USER_PASSWORD_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_PASSWORD_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_PASSWORD_LIMITS for USER_PASSWORD_LIMITS
/
grant select on USER_PASSWORD_LIMITS to PUBLIC with grant option
/

REM
REM  This view shows the resource cost of the system
REM
create or replace view RESOURCE_COST
    (RESOURCE_NAME, UNIT_COST)
as select m.name,c.cost
  from sys.resource_cost$ c, sys.resource_map m where
  c.resource# = m.resource#
  and m.type# = 0
  and c.resource# in (2, 4, 7, 8)
/
comment on table RESOURCE_COST is
'Cost for each resource'
/
comment on column RESOURCE_COST.RESOURCE_NAME is
'Name of resource'
/
comment on column RESOURCE_COST.UNIT_COST is
'Cost for resource'
/
create or replace public synonym RESOURCE_COST for RESOURCE_COST
/
grant select on RESOURCE_COST to PUBLIC
/

remark
remark  FAMILY "USERS"
remark  Users enrolled in the database.
remark
create or replace view USER_USERS
    (USERNAME, USER_ID, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
        DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, CREATED,
        INITIAL_RSRC_CONSUMER_GROUP, EXTERNAL_NAME)
as
select u.name, u.user#,
       m.status,
       decode(u.astatus, 4, u.ltime,
                         5, u.ltime,
                         6, u.ltime,
                         8, u.ltime,
                         9, u.ltime,
                         10, u.ltime, to_date(NULL)),
       decode(u.astatus,
              1, u.exptime,
              2, u.exptime,
              5, u.exptime,
              6, u.exptime,
              9, u.exptime,
              10, u.exptime,
              decode(u.ptime, '', to_date(NULL),
                decode(p.limit#, 2147483647, to_date(NULL),
                 decode(p.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + p.limit#/86400)))),
       dts.name, tts.name, u.ctime,
       nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
       u.ext_username
from sys.user$ u left outer join sys.resource_group_mapping$ cgm
     on (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
         cgm.value = u.name),
     sys.ts$ dts, sys.ts$ tts, sys.user_astatus_map m,
     profile$ p, profile$ dp
where u.datats# = dts.ts#
  and u.tempts# = tts.ts#
  and u.astatus = m.status#
  and u.type# = 1
  and u.user# = userenv('SCHEMAID')
  and u.resource$ = p.profile#
  and dp.profile# = 0
  and dp.type# = 1
  and dp.resource# = 1
  and p.type# = 1
  and p.resource# = 1
/
comment on table USER_USERS is
'Information about the current user'
/
comment on column USER_USERS.USERNAME is
'Name of the user'
/
comment on column USER_USERS.USER_ID is
'ID number of the user'
/
comment on column USER_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column USER_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
comment on column USER_USERS.CREATED is
'User creation date'
/
comment on column USER_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column USER_USERS.EXTERNAL_NAME is
'User external name'
/
create or replace public synonym USER_USERS for USER_USERS
/
grant select on USER_USERS to PUBLIC with grant option
/
create or replace view ALL_USERS
    (USERNAME, USER_ID, CREATED)
as
select u.name, u.user#, u.ctime
from sys.user$ u, sys.ts$ dts, sys.ts$ tts
where u.datats# = dts.ts#
  and u.tempts# = tts.ts#
  and u.type# = 1
/
comment on table ALL_USERS is
'Information about all users of the database'
/
comment on column ALL_USERS.USERNAME is
'Name of the user'
/
comment on column ALL_USERS.USER_ID is
'ID number of the user'
/
comment on column ALL_USERS.CREATED is
'User creation date'
/
create or replace public synonym ALL_USERS for ALL_USERS
/
grant select on ALL_USERS to PUBLIC with grant option
/
create or replace view DBA_USERS
    (USERNAME, USER_ID, PASSWORD, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
        DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, CREATED, PROFILE,
        INITIAL_RSRC_CONSUMER_GROUP,EXTERNAL_NAME,PASSWORD_VERSIONS,
        EDITIONS_ENABLED, AUTHENTICATION_TYPE)
as
select u.name, u.user#,
       decode(u.password, 'GLOBAL', u.password,
                          'EXTERNAL', u.password,
                          NULL), 
       m.status,
       decode(u.astatus, 4, u.ltime,
                         5, u.ltime,
                         6, u.ltime,
                         8, u.ltime,
                         9, u.ltime,
                         10, u.ltime, to_date(NULL)),
       decode(u.astatus,
              1, u.exptime,
              2, u.exptime,
              5, u.exptime,
              6, u.exptime,
              9, u.exptime,
              10, u.exptime,
              decode(u.ptime, '', to_date(NULL),
                decode(pr.limit#, 2147483647, to_date(NULL),
                 decode(pr.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + pr.limit#/86400)))),
       dts.name, tts.name, u.ctime, p.name,
       nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
       u.ext_username,
       decode(length(u.password),16,'10G ',NULL)||NVL2(u.spare4, '11G ' ,NULL),
       decode(bitand(u.spare1, 16),
              16, 'Y',
                  'N'),
       decode(u.password, 'GLOBAL',   'GLOBAL',
                          'EXTERNAL', 'EXTERNAL',
                          'PASSWORD')
       from sys.user$ u left outer join sys.resource_group_mapping$ cgm
            on (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
                cgm.value = u.name),
            sys.ts$ dts, sys.ts$ tts, sys.profname$ p,
            sys.user_astatus_map m, sys.profile$ pr, sys.profile$ dp
       where u.datats# = dts.ts#
       and u.resource$ = p.profile#
       and u.tempts# = tts.ts#
       and u.astatus = m.status#
       and u.type# = 1
       and u.resource$ = pr.profile#
       and dp.profile# = 0
       and dp.type#=1
       and dp.resource#=1
       and pr.type# = 1
       and pr.resource# = 1
/
create or replace public synonym DBA_USERS for DBA_USERS
/
grant select on DBA_USERS to select_catalog_role
/
comment on table DBA_USERS is
'Information about all users of the database'
/
comment on column DBA_USERS.USERNAME is
'Name of the user'
/
comment on column DBA_USERS.USER_ID is
'ID number of the user'
/
comment on column DBA_USERS.PASSWORD is
'Deprecated from 11.2 -- use AUTHENTICATION_TYPE instead'
/
comment on column DBA_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column DBA_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
comment on column DBA_USERS.CREATED is
'User creation date'
/
comment on column DBA_USERS.PROFILE is
'User resource profile name'
/
comment on column DBA_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column DBA_USERS.EXTERNAL_NAME is
'User external name'
/
comment on column DBA_USERS.PASSWORD_VERSIONS is
'Versions of encrypted passwords'
/
comment on column DBA_USERS.EDITIONS_ENABLED is
'Whether editions are enabled for this user'
/
comment on column DBA_USERS.AUTHENTICATION_TYPE is
'Authentication mechanism for the user'


