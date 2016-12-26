Rem
Rem $Header: cdexttab.sql 09-may-2006.14:22:03 cdilling Exp $
Rem
Rem cdexttab.sql
Rem
Rem Copyright (c) 2000, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdexttab.sql - Catalog DEXTTAB.bsq views
Rem 
Rem      Previously known as catxpart
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for external organized tables 
Rem      This script contains catalog views for objects in dexttab.bsq.
Rem
Rem    NOTES
Rem      Must be run while connectd as SYS or INTERNAL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    05/09/06 - 
Rem    psuvarna    12/27/05 - #4715104: CASE construct for ACCESS_PARAMETERS
Rem    hsbedi      07/22/02 - external table property flag
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    abrumm      02/21/01 - add [USER,ALL]_EXTERNAL_[TABLES,LOCATIONS]
Rem    abrumm      02/16/01 - store access parms as LOB in dictionary
Rem    abrumm      10/12/00 - dba_external_locations: get default directory
Rem    abrumm      10/10/00 - add decode for reject_limit
Rem    evoss       06/21/00 - Created
Rem

Rem
Rem FAMILY "EXTERNAL_TABLES"
Rem (USER_, ALL_, DBA_)
Rem

create or replace view USER_EXTERNAL_TABLES
  (TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY)
as
select o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(xt.property, 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = xt.obj#
/
comment on table USER_EXTERNAL_TABLES is
'Description of the user''s own external tables'
/
comment on column USER_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column USER_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column USER_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column USER_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column USER_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column USER_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column USER_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column USER_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column USER_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
create or replace public synonym USER_EXTERNAL_TABLES for USER_EXTERNAL_TABLES
/
grant select on USER_EXTERNAL_TABLES to PUBLIC with grant option
/


create or replace view ALL_EXTERNAL_TABLES
  (OWNER,
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY)
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(xt.property, 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.obj#   = xt.obj#
  and ( o.owner# = userenv('SCHEMAID')
        or o.obj# in
            ( select oa.obj# from sys.objauth$ oa
              where grantee# in (select kzsrorol from x$kzsro)
            )
        or    /* user has system privileges */
          exists ( select null from v$enabledprivs
                   where priv_number in (-45 /* LOCK ANY TABLE */,
                                         -47 /* SELECT ANY TABLE */)
                 )
      )
/
comment on table ALL_EXTERNAL_TABLES is
'Description of the external tables accessible to the user'
/
comment on column ALL_EXTERNAL_TABLES.OWNER is
'Owner of the external table'
/
comment on column ALL_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column ALL_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column ALL_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column ALL_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column ALL_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column ALL_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column ALL_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column ALL_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column ALL_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
create or replace public synonym ALL_EXTERNAL_TABLES for ALL_EXTERNAL_TABLES
/
grant select on ALL_EXTERNAL_TABLES to PUBLIC with grant option
/
                                      

create or replace view DBA_EXTERNAL_TABLES
  (OWNER,
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY)
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(xt.property, 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.obj# = xt.obj#
/       
comment on table DBA_EXTERNAL_TABLES is
'Description of the external tables accessible to the DBA'
/
comment on column DBA_EXTERNAL_TABLES.OWNER is
'Owner of the external table'
/
comment on column DBA_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column DBA_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column DBA_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column DBA_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column DBA_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column DBA_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column DBA_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column DBA_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column DBA_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
create or replace public synonym DBA_EXTERNAL_TABLES for DBA_EXTERNAL_TABLES
/
grant select on DBA_EXTERNAL_TABLES to select_catalog_role
/

Rem
Rem FAMILY "EXTERNAL_LOCATIONS"
Rem (USER_, ALL_, DBA_)
Rem

create or replace view USER_EXTERNAL_LOCATIONS
        (TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.obj$ o, sys.external_tab$ xt
where o.owner# = userenv('SCHEMAID')
  and o.obj# = xl.obj#
  and o.obj# = xt.obj#
/       
comment on table USER_EXTERNAL_LOCATIONS is
'Description of the user''s external tables locations'
/
comment on column USER_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column USER_EXTERNAL_LOCATIONS.LOCATION is
'External table location clause'
/
comment on column USER_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column USER_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym USER_EXTERNAL_LOCATIONS
   for USER_EXTERNAL_LOCATIONS
/
grant select on USER_EXTERNAL_LOCATIONS to PUBLIC with grant option
/


create or replace view ALL_EXTERNAL_LOCATIONS
        (OWNER,
         TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.user$ u, sys.obj$ o, sys.external_tab$ xt
where o.owner# = u.user#
  and o.obj#   = xl.obj#
  and o.obj#   = xt.obj#
  and ( o.owner# = userenv('SCHEMAID')
        or o.obj# in
        ( select oa.obj# from sys.objauth$ oa
          where grantee# in (select kzsrorol from x$kzsro)
        )
        or    /* user has system privileges */
          exists ( select null from v$enabledprivs
                   where priv_number in (-45 /* LOCK ANY TABLE */,
                                         -47 /* SELECT ANY TABLE */)
                 )
      )
/
comment on table ALL_EXTERNAL_LOCATIONS is
'Description of the external tables locations accessible to the user'
/
comment on column ALL_EXTERNAL_LOCATIONS.OWNER is
'Owner of the external table location'
/
comment on column ALL_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column ALL_EXTERNAL_LOCATIONS.LOCATION is
'External table location clause'
/
comment on column ALL_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column ALL_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym ALL_EXTERNAL_LOCATIONS
   for ALL_EXTERNAL_LOCATIONS
/
grant select on ALL_EXTERNAL_LOCATIONS to PUBLIC with grant option
/


create or replace view DBA_EXTERNAL_LOCATIONS
        (OWNER,
         TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.user$ u, sys.obj$ o, sys.external_tab$ xt
where o.owner# = u.user#
  and o.obj# = xl.obj#
  and o.obj# = xt.obj#
/       
comment on table DBA_EXTERNAL_LOCATIONS is
'Description of the external tables locations accessible to the DBA'
/
comment on column DBA_EXTERNAL_LOCATIONS.OWNER is
'Owner of the external table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column DBA_EXTERNAL_LOCATIONS.LOCATION is
'External table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym DBA_EXTERNAL_LOCATIONS
   for DBA_EXTERNAL_LOCATIONS
/
grant select on DBA_EXTERNAL_LOCATIONS to select_catalog_role
/

