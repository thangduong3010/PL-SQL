Rem
Rem $Header: rdbms/admin/cdplsql.sql /st_rdbms_11.2.0/1 2011/12/25 21:24:57 ckavoor Exp $
Rem
Rem cdplsql.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdplsql.sql - Catalog DPLSQL.bsq views.
Rem
Rem    DESCRIPTION
Rem      libraries, procedure, etc
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in dplsql.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ckavoor     12/19/11 - Backport ckavoor_bug-7357877 from main
Rem    traney      03/04/10 - bug 9279149
Rem    rdecker     02/05/10 - bug 9297309: fix dba_identifiers
Rem    anighosh    04/29/09 - #(8469280): Improve DBA_PROCEDURES performance
Rem    kquinn      09/22/08 - 7281025: amend views to handle evolved TYPEs
Rem    rdecker     08/08/08 - bug 6054304: update *_IDENTIFIERS view comments
Rem    rdecker     12/17/07 - bug 6681502: libary perms fix in all_identifiers
Rem    rdecker     09/20/07 - bug 6418470: persistent library settings
Rem    rdecker     10/20/06 - plscope views for SYSAUX
Rem    achoi       06/26/06 - support application edition 
Rem    rdecker     06/30/06 - Changes to PL/Scope identifiers views
Rem    rdecker     06/05/06 - Add PL/Scope identifiers view
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

remark
remark  FAMILY "LIBRARIES"
remark
remark  Views for showing information about PL/SQL Libraries:
remark  USER_LIBRARIES, ALL_LIBRARIES and DBA_LIBRARIES
remark
create or replace view USER_LIBRARIES
(LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ l
where o.owner# = userenv('SCHEMAID')
  and o.obj# = l.obj#
/
rem  and ((l.property is null) or (bitand(l.property, 2) = 0))
comment on table USER_LIBRARIES is
'Description of the user''s own libraries'
/
comment on column USER_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column USER_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column USER_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column USER_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym USER_LIBRARIES for USER_LIBRARIES
/
grant select on USER_LIBRARIES to PUBLIC with grant option
/

create or replace view ALL_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select u.name,
       o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ l, sys.user$ u
where o.owner# = u.user#
  and o.obj# = l.obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or o.obj# in
          ( select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro)
          )
       or (
            exists (select NULL from v$enabledprivs
                    where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                         )
                   )
          )
      )
/
comment on table ALL_LIBRARIES is
'Description of libraries accessible to the user'
/
comment on column ALL_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column ALL_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column ALL_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column ALL_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column ALL_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym ALL_LIBRARIES for ALL_LIBRARIES
/
grant select on ALL_LIBRARIES to PUBLIC with grant option
/

create or replace view DBA_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select u.name,
       o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ l, sys.user$ u
where o.owner# = u.user#
  and o.obj# = l.obj#
/
comment on table DBA_LIBRARIES is
'Description of all libraries in the database'
/
comment on column DBA_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column DBA_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column DBA_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column DBA_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column DBA_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym DBA_LIBRARIES for DBA_LIBRARIES
/
grant select on DBA_LIBRARIES to select_catalog_role
/


remark FAMILY  "PROCEDURES"
remark   List of procedures (and functions) and associated properties

create or replace view USER_PROCEDURES
(OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID, 
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
(select o.name, pi.procedurename, o.obj#, pi.procedure#, 
decode(pi.overload#, 0, NULL, pi.overload#),
decode(o.type#, 7, 'PROCEDURE',
       8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
       12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
       22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
       30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
decode(bitand(pi.properties,32),32,'YES','NO'),
decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from sys."_CURRENT_EDITION_OBJ" o, sys.procedureinfo$ pi,
     sys."_CURRENT_EDITION_OBJ" o2, sys.user$ u2
where o.owner# = userenv('SCHEMAID') and o.obj# = pi.obj#
and (o.type# in (7, 8, 9, 11, 12, 14, 22, 28, 29, 30, 87) or
     (o.type# = 13 and o.subname is null))
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+))
UNION ALL
(select tabobj.object_name, NULL, 
  tabobj.object_id, 
  case tabobj.object_type
    when 'TRIGGER' then 1
    else 0
  end,
  NULL, tabobj.object_type, 'NO', 'NO', NULL, NULL, 'NO', 'NO', 'NO', 
  case tabobj.object_type
    when 'TRIGGER' then 'DEFINER'
    else 
      decode(bitand(pi.properties,1024),
             NULL, NULL, 
             1024,'CURRENT_USER','DEFINER')
  end
  from user_objects tabobj, procedureinfo$ pi
  where
    ((tabobj.object_id = pi.obj# (+)) AND
     (tabobj.object_type IN ('TRIGGER', 'PACKAGE')) AND
     ((pi.procedure# is null) OR (pi.procedure# = 1))))
/
comment on table USER_PROCEDURES is
'Description of the user functions/procedures/packages/types/triggers'
/
comment on column USER_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column USER_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column USER_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column USER_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column USER_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column USER_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column USER_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column USER_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column USER_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column USER_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column USER_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym user_procedures for user_procedures
/
grant select on user_procedures to public with grant option
/

create or replace view ALL_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID,
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
(select u.name, o.name, pi.procedurename, o.obj#, pi.procedure#, 
decode(pi.overload#, 0, NULL, pi.overload#),
decode(o.type#, 7, 'PROCEDURE',
       8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
       12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
       22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
       30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
  decode(bitand(pi.properties,32),32,'YES','NO'),
  decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from sys."_CURRENT_EDITION_OBJ" o,  user$ u, procedureinfo$ pi, 
     sys."_CURRENT_EDITION_OBJ" o2, user$ u2
where u.user# = o.owner# and o.obj# = pi.obj#
and (o.type# in (7, 8, 9, 11, 12, 14, 22, 28, 29, 30, 87) or
     (o.type# = 13 and o.subname is null))
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+)
and (o.owner# = userenv('SCHEMAID')
     or exists
      (select null from v$enabledprivs where priv_number in (-144,-141))
     or o.obj# in (select obj# from sys.objauth$ where grantee# in
      (select kzsrorol from x$kzsro) and privilege# = 12)))
union all
(select tabobj.owner, tabobj.object_name, NULL, 
  tabobj.object_id, 
  case tabobj.object_type
    when 'TRIGGER' then 1
    else 0
  end,
  NULL, tabobj.object_type, 'NO', 'NO', NULL, NULL, 'NO', 'NO', 'NO', 
  case tabobj.object_type
    WHEN 'TRIGGER' then 'DEFINER'
    else
      case pi.properties
        WHEN NULL then NULL
        else
          decode(bitand(pi.properties,1024),
                 NULL, NULL,
                 1024,'CURRENT_USER',
                 'DEFINER')
        end
  end case
  from all_objects tabobj, procedureinfo$ pi
  where
    ((tabobj.object_id = pi.obj# (+)) AND
     (tabobj.object_type IN ('TRIGGER', 'PACKAGE')) AND
     ((pi.procedure# is null) OR (pi.procedure# = 1))))
/
comment on table ALL_PROCEDURES is
'Functions/procedures/packages/types/triggers available to the user'
/
comment on column ALL_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column ALL_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column ALL_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column ALL_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column ALL_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column ALL_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column ALL_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column ALL_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym all_procedures for all_procedures
/
grant select on all_procedures to public with grant option
/


create or replace view DBA_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID, 
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
(select u.name, o.name, pi.procedurename, o.obj#, pi.procedure#, 
decode(pi.overload#, 0, NULL, pi.overload#),
decode(o.type#, 7, 'PROCEDURE',
       8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
       12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
       22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
       30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
  decode(bitand(pi.properties,32),32,'YES','NO'),
  decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from sys."_CURRENT_EDITION_OBJ" o, user$ u, procedureinfo$ pi,
     sys."_CURRENT_EDITION_OBJ" o2, user$ u2
where u.user# = o.owner# and o.obj# = pi.obj#
and (o.type# in (7, 8, 9, 11, 12, 14, 22, 28, 29, 30, 87) or
     (o.type# = 13 and o.subname is null))
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+))
union all
(select u.name, o.name, NULL,
  o.obj#,
  CASE 
    WHEN o.type# = 12 THEN 1
    ELSE 0
  END,
  NULL, decode(o.type#,12,'TRIGGER',9,'PACKAGE'),
  'NO', 'NO', NULL, NULL, 'NO', 'NO', 'NO',
  CASE
    WHEN o.type#=12 THEN 'DEFINER'
    ELSE decode(bitand(pi.properties,1024),NULL,NULL,
                1024,'CURRENT_USER','DEFINER')
  END CASE
  from sys."_CURRENT_EDITION_OBJ" o, user$ u, procedureinfo$ pi
  where ((o.owner# = u.user# and o.obj# = pi.obj# (+)) AND
         (o.type# in (12,9)) AND
         ((pi.procedure# is null) OR (pi.procedure# = 1))))
/
comment on table DBA_PROCEDURES is
'Description of the dba functions/procedures/packages/types/triggers'
/
comment on column DBA_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column DBA_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column DBA_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column DBA_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column DBA_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column DBA_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column DBA_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column DBA_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym DBA_PROCEDURES for DBA_PROCEDURES
/
grant select on DBA_PROCEDURES to select_catalog_role
/


remark
remark Family STORED_SETTINGS
remark

CREATE OR REPLACE VIEW all_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value)
AS
SELECT u.name, o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.settings$ p
WHERE o.owner# = u.user#
AND o.linkname is null
AND (o.type# in (7, 8, 9, 11, 12, 14) or (o.type# = 13 and o.subname is null))
AND p.obj# = o.obj#
AND (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
         (
          (o.type# = 7 or o.type# = 8 or o.type# = 9 or 
           (o.type# = 13 and o.subname is null))
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 
                                          26 /* DEBUG */))
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (o.type# = 7 or o.type# = 8 or o.type# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              o.type# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type */
              o.type# = 13 and o.subname is null
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              o.type# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table all_stored_settings is
'Parameter settings for objects accessible to the user'
/
comment on column all_stored_settings.owner is
'Username of the owner of the object'
/
comment on column all_stored_settings.object_name is
'Name of the object'
/
comment on column all_stored_settings.object_id is
'Object number of the object'
/
comment on column all_stored_settings.object_type is
'Type of the object'
/
comment on column all_stored_settings.param_name is
'Name of the parameter'
/
comment on column all_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym all_stored_settings for all_stored_settings
/
grant select on all_stored_settings to public with grant option
/

CREATE OR REPLACE VIEW user_stored_settings
(object_name, object_id, object_type, param_name, param_value)
AS
SELECT o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys."_CURRENT_EDITION_OBJ" o, sys.settings$ p
WHERE o.linkname is null
AND p.obj# = o.obj#
AND o.owner# = userenv('SCHEMAID')
AND (o.type# in (7, 8, 9, 11, 12, 14) or (o.type# = 13 and o.subname is null))
/
comment on table user_stored_settings is
'Parameter settings for objects owned by the user'
/
comment on column user_stored_settings.object_name is
'Name of the object'
/
comment on column user_stored_settings.object_id is
'Object number of the object'
/
comment on column user_stored_settings.object_type is
'Type of the object'
/
comment on column user_stored_settings.param_name is
'Name of the parameter'
/
comment on column user_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym user_stored_settings for user_stored_settings
/
grant select on user_stored_settings to public with grant option
/

CREATE OR REPLACE VIEW dba_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value)
AS
SELECT u.name, o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.settings$ p
WHERE o.owner# = u.user#
AND o.linkname is null
AND p.obj# = o.obj#
AND (o.type# in (7, 8, 9, 11, 12, 14) or (o.type# = 13 and o.subname is null))
/
comment on table dba_stored_settings is
'Parameter settings for all objects'
/
comment on column dba_stored_settings.owner is
'Username of the owner of the object'
/
comment on column dba_stored_settings.object_name is
'Name of the object'
/
comment on column dba_stored_settings.object_id is
'Object number of the object'
/
comment on column dba_stored_settings.object_type is
'Type of the object'
/
comment on column dba_stored_settings.param_name is
'Name of the parameter'
/
comment on column dba_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym dba_stored_settings for dba_stored_settings
/
grant select on dba_stored_settings to select_catalog_role
/

create or replace view USER_PLSQL_OBJECT_SETTINGS
(NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS)
as
select o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plscope_settings')
from sys."_CURRENT_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')
  and (o.type# in (7, 8, 9, 11, 12, 14, 22)
  or  (o.type# = 13 and o.subname is null))
/
comment on table USER_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects owned by the user'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/
create or replace public synonym USER_PLSQL_OBJECT_SETTINGS for USER_PLSQL_OBJECT_SETTINGS
/
grant select on USER_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view ALL_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plscope_settings')
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and (o.type# in (7, 8, 9, 11, 12, 14, 22)
  or  (o.type# = 13 and o.subname is null))
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* EXECUTE privilege does not let user see package or type body */
      (o.type# in (7, 8, 9, 12, 22)
       or (o.type# = 13 and o.subname is null))
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (12 /* EXECUTE */, 
                                      26 /* DEBUG */)
                )
    )
    or
    (
       o.type# in (7, 8, 9) /* procedure, function, package */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -144 /* EXECUTE ANY PROCEDURE */,
                                      -141 /* CREATE ANY PROCEDURE */,
                                      -241 /* DEBUG ANY PROCEDURE */
                                    )
              )
    )
    or
    (
      o.type# = 11 /* package body */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-141 /* CREATE ANY PROCEDURE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
       o.type# = 12 /* trigger */
       and
       exists (select null from v$enabledprivs
               where priv_number in (-152 /* CREATE ANY TRIGGER */,
                                     -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      o.type# = 13 /* type */
      and o.subname is null
      and
      exists (select null from v$enabledprivs
              where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                    -181 /* CREATE ANY TYPE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      o.type# = 14 /* type body */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-181 /* CREATE ANY TYPE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      o.type# = 22 /* library */
      and
      exists (select null from v$enabledprivs
              where priv_number in ( -189 /* CREATE ANY LIBRARY */,
                                     -192 /* EXECUTE ANY LIBRARY */))
    )
  )
/
comment on table ALL_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects accessible to the user'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/
create or replace public synonym ALL_PLSQL_OBJECT_SETTINGS for ALL_PLSQL_OBJECT_SETTINGS
/
grant select on ALL_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view DBA_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plscope_settings')
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and (o.type# in (7, 8, 9, 11, 12, 14, 22) 
  or  (o.type# = 13 and o.subname is null))
/
create or replace public synonym DBA_PLSQL_OBJECT_SETTINGS for DBA_PLSQL_OBJECT_SETTINGS
/
grant select on DBA_PLSQL_OBJECT_SETTINGS to select_catalog_role
/
comment on table DBA_PLSQL_OBJECT_SETTINGS is
'Compiler settings of all objects in the database'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/

remark
remark Family ARGUMENTS
remark

create or replace view ALL_ARGUMENTS
(OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID,
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, PLS_TYPE,
CHAR_LENGTH, CHAR_USED)
as
select
u.name, /* OWNER */
nvl(a.procedure$,o.name), /* OBJECT_NAME */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.procedure#, /* SUBPROGRAM ID */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
58, 'OPAQUE/XMLTYPE',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
decode(default#, 1, 'Y', 'N'), /* DEFAULTED */
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0) /* CHAR_USED */
from sys."_CURRENT_EDITION_OBJ" o,argument$ a,user$ u
where o.obj# = a.obj#
and o.owner# = u.user#
and (o.type# in (7, 8, 9, 11, 14) or 
     (o.type# = 13 and o.subname is null))
and (owner# = userenv('SCHEMAID')
or exists
  (select null from v$enabledprivs where priv_number in (-144,-141))
or o.obj# in (select obj# from sys.objauth$ where grantee# in
  (select kzsrorol from x$kzsro) and privilege# = 12))
/
comment on table all_arguments is
'Arguments in object accessible to the user'
/
comment on column all_arguments.owner is
'Username of the owner of the object'
/
comment on column all_arguments.object_name is
'Procedure or function name'
/
comment on column all_arguments.overload is
'Overload unique identifier'
/
comment on column all_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column all_arguments.package_name is
'Package name'
/
comment on column all_arguments.object_id is
'Object number of the object'
/
comment on column all_arguments.argument_name is
'Argument name'
/
comment on column all_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column all_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column all_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column all_arguments.data_type is
'Datatype of the argument'
/
comment on column all_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column all_arguments.default_value is
'Default value for the argument'
/
comment on column all_arguments.default_length is
'Length of default value for the argument'
/
comment on column all_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column all_arguments.data_length is
'Length of the column in bytes'
/
comment on column all_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column all_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column all_arguments.radix is
'Argument radix for a number'
/
comment on column all_arguments.character_set_name is
'Character set name for the argument'
/
comment on column all_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column all_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column all_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column all_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column all_arguments.pls_type is
'PL/SQL type name for numeric arguments'
/
comment on column all_arguments.char_length is
'Character limit for string datatypes'
/
comment on column all_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
create or replace public synonym all_arguments for all_arguments
/
grant select on all_arguments to public with grant option
/

create or replace view USER_ARGUMENTS
(OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID, 
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, PLS_TYPE,
CHAR_LENGTH, CHAR_USED)
as
select
nvl(a.procedure$,o.name), /* OBJECT_NAME */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.procedure#, /* SUBPROGRAM ID */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
decode(default#, 1, 'Y', 'N'), /* DEFAULTED */
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0) /* CHAR_USED */
from "_CURRENT_EDITION_OBJ" o,argument$ a
where o.obj# = a.obj#
and (o.type# in (7, 8, 9, 11, 14) or
     (o.type# = 13 and o.subname is null))
and owner# = userenv('SCHEMAID')
/
comment on table user_arguments is
'Arguments in object accessible to the user'
/
comment on column user_arguments.object_name is
'Procedure or function name'
/
comment on column user_arguments.overload is
'Overload unique identifier'
/
comment on column user_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column user_arguments.package_name is
'Package name'
/
comment on column user_arguments.object_id is
'Object number of the object'
/
comment on column user_arguments.argument_name is
'Argument name'
/
comment on column user_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column user_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column user_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column user_arguments.data_type is
'Datatype of the argument'
/
comment on column user_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column user_arguments.default_value is
'Default value for the argument'
/
comment on column user_arguments.default_length is
'Length of default value for the argument'
/
comment on column user_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column user_arguments.data_length is
'Length of the column in bytes'
/
comment on column user_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column user_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column user_arguments.radix is
'Argument radix for a number'
/
comment on column user_arguments.character_set_name is
'Character set name for the argument'
/
comment on column user_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column user_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column user_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column user_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column user_arguments.pls_type is
'PL/SQL type name for numeric arguments'
/
comment on column user_arguments.char_length is
'Character limit for string datatypes'
/
comment on column user_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
create or replace public synonym user_arguments for user_arguments
/
grant select on user_arguments to public with grant option
/
create or replace view DBA_ARGUMENTS
(OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID,
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, PLS_TYPE,
CHAR_LENGTH, CHAR_USED)
as
select
u.name, /* OWNER */
nvl(a.procedure$,o.name), /* OBJECT_NAME */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.procedure#, /* SUBPROGRAM ID */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
decode(default#, 1, 'Y', 'N'), /* DEFAULTED */
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0) /* CHAR_USED */
from sys."_CURRENT_EDITION_OBJ" o,argument$ a,user$ u
where o.obj# = a.obj#
and (o.type# in (7, 8, 9, 11, 14) or
     (o.type# = 13 and o.subname is null))
and o.owner# = u.user#
/
comment on table dba_arguments is
'All arguments for objects in the database'
/
comment on column dba_arguments.object_name is
'Procedure or function name'
/
comment on column dba_arguments.overload is
'Overload unique identifier'
/
comment on column dba_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column dba_arguments.package_name is
'Package name'
/
comment on column dba_arguments.object_id is
'Object number of the object'
/
comment on column dba_arguments.argument_name is
'Argument name'
/
comment on column dba_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column dba_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column dba_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column dba_arguments.data_type is
'Datatype of the argument'
/
comment on column dba_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column dba_arguments.default_value is
'Default value for the argument'
/
comment on column dba_arguments.default_length is
'Length of default value for the argument'
/
comment on column dba_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column dba_arguments.data_length is
'Length of the column in bytes'
/
comment on column dba_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column dba_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column dba_arguments.radix is
'Argument radix for a number'
/
comment on column dba_arguments.character_set_name is
'Character set name for the argument'
/
comment on column dba_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column dba_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column dba_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column dba_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column dba_arguments.pls_type is
'PL/SQL type name for numeric arguments'
/
comment on column dba_arguments.char_length is
'Character limit for string datatypes'
/
comment on column dba_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
create or replace public synonym DBA_ARGUMENTS for DBA_ARGUMENTS
/
grant select on DBA_ARGUMENTS to select_catalog_role
/

remark
remark  FAMILY "ASSEMBLIES"
remark
remark  Views for showing information about PL/SQL Assemblies:
remark  USER_ASSEMBLIES, ALL_ASSEMBLIES and DBA_ASSEMBLIES
remark
create or replace view USER_ASSEMBLIES
(ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a
where o.owner# = userenv('SCHEMAID')
  and o.obj# = a.obj#
/
rem  and ((l.property is null) or (bitand(l.property, 2) = 0))
comment on table USER_ASSEMBLIES is
'Description of the user''s own assemblies'
/
comment on column USER_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column USER_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column USER_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column USER_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column USER_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym USER_ASSEMBLIES for USER_ASSEMBLIES
/
grant select on USER_ASSEMBLIES to PUBLIC with grant option
/

create or replace view ALL_ASSEMBLIES
(OWNER, ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select u.name,
       o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a, sys.user$ u
where o.owner# = u.user#
  and o.obj# = a.obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or o.obj# in
          ( select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro)
          )
       or (
            exists (select NULL from v$enabledprivs
                    where priv_number in (
                                           -282 /* CREATE ANY ASSEMBLY */,
                                           -283 /* ALTER ANY ASSEMBLY */,
                                           -284 /* DROP ANY ASSEMBLY */,
                                           -285 /* EXECUTE ANY ASSEMBLY */
                                         )
                   )
          )
      )
/
comment on table ALL_ASSEMBLIES is
'Description of assemblies accessible to the user'
/
comment on column ALL_ASSEMBLIES.OWNER is
'Owner of the assembly'
/
comment on column ALL_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column ALL_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column ALL_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column ALL_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column ALL_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym ALL_ASSEMBLIES for ALL_ASSEMBLIES
/
grant select on ALL_ASSEMBLIES to PUBLIC with grant option
/

create or replace view DBA_ASSEMBLIES
(OWNER, ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select u.name,
       o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a, sys.user$ u
where o.owner# = u.user#
  and o.obj# = a.obj#
/
comment on table DBA_ASSEMBLIES is
'Description of all assemblies in the database'
/
comment on column DBA_ASSEMBLIES.OWNER is
'Owner of the assembly'
/
comment on column DBA_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column DBA_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column DBA_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column DBA_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column DBA_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym DBA_ASSEMBLIES for DBA_ASSEMBLIES
/
grant select on DBA_ASSEMBLIES to select_catalog_role
/


remark
remark    FAMILY "IDENTIFIERS"
remark    PL/SQL IDENTIFIERS in stored objects.  Objects are types, type bodies,
remark    PL/SQL packages, package bodies, procedures and functions.
remark

create or replace view USER_IDENTIFIERS
(NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, LINE, 
COL, USAGE_CONTEXT_ID)
as
select i.symrep, i.signature,
decode(i.type#, 1, 'VARIABLE', 2, 'ITERATOR', 3, 'DATE DATATYPE',
                4, 'PACKAGE',  5, 'PROCEDURE', 6, 'FUNCTION', 7, 'FORMAL IN',
                8, 'SUBTYPE',  9, 'CURSOR', 10, 'INDEX TABLE', 11, 'OBJECT',
               12, 'RECORD', 13, 'EXCEPTION', 14, 'BOOLEAN DATATYPE', 15, 'CONSTANT',
               16, 'LIBRARY', 17, 'ASSEMBLY', 18, 'DBLINK', 19, 'LABEL',
               20, 'TABLE', 21, 'NESTED TABLE', 22, 'VARRAY', 23, 'REFCURSOR',
               24, 'BLOB DATATYPE', 25, 'CLOB DATATYPE', 26, 'BFILE DATATYPE', 
               27, 'FORMAL IN OUT', 28, 'FORMAL OUT', 29, 'OPAQUE DATATYPE', 
               30, 'NUMBER DATATYPE', 31, 'CHARACTER DATATYPE', 
               32, 'ASSOCIATIVE ARRAY', 33, 'TIME DATATYPE', 34, 'TIMESTAMP DATATYPE', 
               35, 'INTERVAL DATATYPE', 36, 'UROWID', 37, 'SYNONYM', 38, 'TRIGGER',
                   'UNDEFINED'),
o.name, 
decode(o.type#, 5, 'SYNONYM', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                22, 'LIBRARY', 33, 'SPEC OPERATOR', 87, 'ASSEMBLY',
                'UNDEFINED'),
decode(a.action, 1, 'DECLARATION', 2, 'DEFINITION', 3, 'CALL', 4, 'REFERENCE', 
                 5, 'ASSIGNMENT', 'UNDEFINED'),
a.action#, a.line, a.col, a.context#
from sys."_CURRENT_EDITION_OBJ" o, sys.plscope_identifier$ i, sys.plscope_action$ a
where i.signature = a.signature 
  and o.obj# = a.obj# 
  and ( o.type# in (5, 7, 8, 9, 11, 12, 14, 22, 33, 87) OR
       ( o.type# = 13 AND o.subname is null))
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_IDENTIFIERS is
'Identifiers in stored objects accessible to the user'
/
comment on column USER_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column USER_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column USER_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column USER_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column USER_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column USER_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column USER_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column USER_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column USER_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column USER_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/

create or replace public synonym USER_IDENTIFIERS for USER_IDENTIFIERS
/
grant select on USER_IDENTIFIERS to public with grant option
/

create or replace view ALL_IDENTIFIERS
(OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, 
LINE, COL, USAGE_CONTEXT_ID)
as
select u.name, i.symrep, i.signature,
decode(i.type#, 1, 'VARIABLE', 2, 'ITERATOR', 3, 'DATE DATATYPE',
                4, 'PACKAGE',  5, 'PROCEDURE', 6, 'FUNCTION', 7, 'FORMAL IN',
                8, 'SUBTYPE',  9, 'CURSOR', 10, 'INDEX TABLE', 11, 'OBJECT',
               12, 'RECORD', 13, 'EXCEPTION', 14, 'BOOLEAN DATATYPE', 15, 'CONSTANT',
               16, 'LIBRARY', 17, 'ASSEMBLY', 18, 'DBLINK', 19, 'LABEL',
               20, 'TABLE', 21, 'NESTED TABLE', 22, 'VARRAY', 23, 'REFCURSOR',
               24, 'BLOB DATATYPE', 25, 'CLOB DATATYPE', 26, 'BFILE DATATYPE', 
               27, 'FORMAL IN OUT', 28, 'FORMAL OUT', 29, 'OPAQUE', 
               30, 'NUMBER DATATYPE', 31, 'CHARACTER DATATYPE', 
               32, 'ASSOCIATIVE ARRAY', 33, 'TIME DATATYPE', 34, 'TIMESTAMP DATATYPE', 
               35, 'INTERVAL DATATYPE', 36, 'UROWID', 37, 'SYNONYM', 38, 'TRIGGER',
                   'UNDEFINED'),
o.name, 
decode(o.type#, 5, 'SYNONYM', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                22, 'LIBRARY', 33, 'SPEC OPERATOR', 87, 'ASSEMBLY',
                'UNDEFINED'),
decode(a.action, 1, 'DECLARATION', 2, 'DEFINITION', 3, 'CALL', 4, 'REFERENCE', 
                 5, 'ASSIGNMENT', 'UNDEFINED'),
a.action#, a.line, a.col, a.context#
from sys."_CURRENT_EDITION_OBJ" o, sys.plscope_identifier$ i, sys.plscope_action$ a, sys.user$ u
where i.signature = a.signature 
  and o.obj# = a.obj# 
  and o.owner# = u.user#
  and ( o.type# in (5, 7, 8, 9, 11, 12, 14, 22, 33, 87) OR
       ( o.type# = 13 AND o.subname is null))
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
         (
          (o.type# in (7 /* proc */, 8 /* func */, 9 /* pkg */, 13 /* type */,
                       22 /* library */))
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        )
        or
        (
          (o.type# in (11 /* package body */, 14 /* type body */))
          and
          exists
          (
            select null from sys.obj$ specobj, sys.objauth$ oa
            where specobj.owner# = o.owner#
              and specobj.name = o.name
              and specobj.type# = decode(o.type#,
                                         11 /* pkg body */, 9 /* pkg */,
                                         14 /* type body */, 13 /* type */,
                                         null)
              and oa.obj# = specobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        (
          (o.type# = 12 /* trigger */)
          and
          exists
          (
            select null from sys.trigger$ t, sys.obj$ tabobj, sys.objauth$ oa
            where t.obj# = o.obj#
              and tabobj.obj# = t.baseobject
              and tabobj.owner# = o.owner#
              and oa.obj# = tabobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (o.type# = 7 or o.type# = 8 or o.type# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              o.type# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type */
              o.type# = 13
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              o.type# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* triggers */
              o.type# = 12 and
              (
                privilege# = -152 /* CREATE ANY TRIGGER */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or 
            (
              /* library */
              o.type# = 22 and
              (
                privilege# = -189 /* CREATE ANY LIBRARY */
                or
                privilege# = -192 /* EXECUTE ANY LIBRARY */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_IDENTIFIERS is
'All identifiers in stored objects accessible to the user'
/
comment on column ALL_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column ALL_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column ALL_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column ALL_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column ALL_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column ALL_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column ALL_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column ALL_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column ALL_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column ALL_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/

create or replace public synonym ALL_IDENTIFIERS for ALL_IDENTIFIERS
/
grant select on ALL_IDENTIFIERS to public with grant option
/


create or replace view DBA_IDENTIFIERS
(OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, 
LINE, COL, USAGE_CONTEXT_ID)
as
select u.name, i.symrep, i.signature,
decode(i.type#, 1, 'VARIABLE', 2, 'ITERATOR', 3, 'DATE DATATYPE',
                4, 'PACKAGE',  5, 'PROCEDURE', 6, 'FUNCTION', 7, 'FORMAL IN',
                8, 'SUBTYPE',  9, 'CURSOR', 10, 'INDEX TABLE', 11, 'OBJECT',
               12, 'RECORD', 13, 'EXCEPTION', 14, 'BOOLEAN DATATYPE', 15, 'CONSTANT',
               16, 'LIBRARY', 17, 'ASSEMBLY', 18, 'DBLINK', 19, 'LABEL',
               20, 'TABLE', 21, 'NESTED TABLE', 22, 'VARRAY', 23, 'REFCURSOR',
               24, 'BLOB DATATYPE', 25, 'CLOB DATATYPE', 26, 'BFILE DATATYPE', 
               27, 'FORMAL IN OUT', 28, 'FORMAL OUT', 29, 'OPAQUE', 
               30, 'NUMBER DATATYPE', 31, 'CHARACTER DATATYPE', 
               32, 'ASSOCIATIVE ARRAY', 33, 'TIME DATATYPE', 34, 'TIMESTAMP DATATYPE', 
               35, 'INTERVAL DATATYPE', 36, 'UROWID', 37, 'SYNONYM', 38, 'TRIGGER',
                   'UNDEFINED'),
o.name, 
decode(o.type#, 5, 'SYNONYM', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                22, 'LIBRARY', 33, 'SPEC OPERATOR', 87, 'ASSEMBLY',
                'UNDEFINED'),
decode(a.action, 1, 'DECLARATION', 2, 'DEFINITION', 3, 'CALL', 4, 'REFERENCE', 
                 5, 'ASSIGNMENT', 'UNDEFINED'),
a.action#, a.line, a.col, a.context#
from sys."_CURRENT_EDITION_OBJ" o, sys.plscope_identifier$ i, sys.plscope_action$ a, sys.user$ u
where i.signature = a.signature 
  and o.obj# = a.obj# 
  and o.owner# = u.user#
  and ( o.type# in (5, 7, 8, 9, 11, 12, 14, 22, 33, 87) OR
       ( o.type# = 13 AND o.subname is null))
/
comment on table DBA_IDENTIFIERS is
'Identifiers in stored objects accessible to sys'
/
comment on column DBA_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column DBA_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column DBA_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column DBA_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column DBA_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column DBA_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column DBA_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column DBA_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column DBA_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column DBA_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/
create or replace public synonym DBA_IDENTIFIERS for DBA_IDENTIFIERS
/
grant select on DBA_IDENTIFIERS to select_catalog_role
/
