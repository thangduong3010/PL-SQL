Rem
Rem $Header: javavm/install/catjvm.sql /st_javavm_11.2.0/2 2013/07/05 10:36:12 mjungerm Exp $
Rem
Rem catjvm.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catjvm.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      create USER|DBA|ALL_JAVA_* views
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rhlee       05/11/05 - rewrite view definitions to "encourage"
Rem                           fixed-table index-access path
Rem    xuhuali     10/24/01 - Merged xuhuali_create_java_views
Rem    xuhuali     10/24/01 - Created
Rem

remark
remark FAMILY "JAVA_CLASSES"
remark

create or replace view USER_JAVA_CLASSES
(NAME, MAJOR, MINOR, KIND, ACCESSIBILITY, 
       IS_INNER, IS_ABSTRACT, IS_FINAL, IS_DEBUG, SOURCE, SUPER, OUTER)
as 
select /*+ ordered use_nl(o m)*/ 
       nvl(j.longdbcs, o.name), m.maj, m.min, 
       decode(BITAND(m.acc, 512), 512, 'CLASS', 
                                  0, 'INTERFACE'),
       decode(BITAND(m.acc, 1), 1, 'PUBLIC', 
                                0, NULL),
       decode(BITAND(m.acc, 131072), 131072, 'YES', 
                                     0, 'NO'),
       decode(BITAND(m.acc, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.acc, 16), 16, 'YES',
                                 0, 'NO'),
       decode(m.dbg, 1, 'YES',
                     0, 'NO'),    
       m.src, m.spl, m.oln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_CLASSES is
'class level information of stored java class owned by the user'
/
comment on column USER_JAVA_CLASSES.NAME is 
'name of the java class'
/
comment on column USER_JAVA_CLASSES.MAJOR is
'the major version number of the java class as defined in JVM specification'
/
comment on column USER_JAVA_CLASSES.MINOR is
'the minor version number of the java class as defined in JVM specification'
/
comment on column USER_JAVA_CLASSES.KIND is
'is the stored object a java class or java interface?'
/
comment on column USER_JAVA_CLASSES.ACCESSIBILITY is
'the accessiblity of the java class'
/
comment on column USER_JAVA_CLASSES.IS_INNER is
'is this java class an inner class'
/
comment on column USER_JAVA_CLASSES.IS_ABSTRACT is
'is this an abstract class?'
/
comment on column USER_JAVA_CLASSES.IS_FINAL is
'is this an final class?'
/
comment on column USER_JAVA_CLASSES.IS_DEBUG is
'does this class contain debug information?'
/
comment on column USER_JAVA_CLASSES.SOURCE is
'source designation of the java class '
/
comment on column USER_JAVA_CLASSES.SUPER is
'super class of this java class'
/
comment on column USER_JAVA_CLASSES.OUTER is
'outer class of this java class if this java class is an inner class'
/
create or replace public synonym USER_JAVA_CLASSES for USER_JAVA_CLASSES
/
grant select on USER_JAVA_CLASSES to public with grant option
/

create or replace view ALL_JAVA_CLASSES
(OWNER, NAME, MAJOR, MINOR, KIND, ACCESSIBILITY, IS_INNER,
       IS_ABSTRACT, IS_FINAL, IS_DEBUG, SOURCE, SUPER, OUTER)
as 
select /*+ ordered use_nl(o m)*/ 
       u.name, nvl(j.longdbcs, o.name), m.maj, m.min, 
       decode(BITAND(m.acc, 512), 512, 'CLASS', 
                                  0, 'INTERFACE'),
       decode(BITAND(m.acc, 1), 1, 'PUBLIC', 
                                0, NULL),
       decode(BITAND(m.acc, 131072), 131072, 'YES', 
                                     0, 'NO'),
       decode(BITAND(m.acc, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.acc, 16), 16, 'YES',
                                 0, 'NO'),
       decode(m.dbg, 1, 'YES',
                     0, 'NO'),    
       m.src, m.spl, m.oln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_CLASSES is
'class level information of stored java class accessible to the user'
/
comment on column ALL_JAVA_CLASSES.OWNER is
'owner of the java class'
/
comment on column ALL_JAVA_CLASSES.NAME is 
'name of the java class'
/
comment on column ALL_JAVA_CLASSES.MAJOR is
'the major version number of the java class as defined in JVM specification'
/
comment on column ALL_JAVA_CLASSES.MINOR is
'the minor version number of the java class as defined in JVM specification'
/
comment on column ALL_JAVA_CLASSES.KIND is
'is the stored object a java class or java interface?'
/
comment on column ALL_JAVA_CLASSES.ACCESSIBILITY is
'the accessiblity of the java class'
/
comment on column ALL_JAVA_CLASSES.IS_INNER is
'is this java class an inner class'
/
comment on column ALL_JAVA_CLASSES.IS_ABSTRACT is
'is this an abstract class?'
/
comment on column ALL_JAVA_CLASSES.IS_FINAL is
'is this an final class?'
/
comment on column ALL_JAVA_CLASSES.IS_DEBUG is
'does this class contain debug information?'
/
comment on column ALL_JAVA_CLASSES.SOURCE is
'source designation of the java class '
/
comment on column ALL_JAVA_CLASSES.SUPER is
'super class of this java class'
/
comment on column ALL_JAVA_CLASSES.OUTER is
'outer class of this java class if this java class is an inner class'
/
create or replace public synonym ALL_JAVA_CLASSES for ALL_JAVA_CLASSES
/
grant select on ALL_JAVA_CLASSES to public with grant option
/

create or replace view DBA_JAVA_CLASSES
(OWNER,NAME, MAJOR, MINOR, KIND, ACCESSIBILITY, IS_INNER, 
       IS_ABSTRACT, IS_FINAL, IS_DEBUG, SOURCE, SUPER, OUTER)
as 
select /*+ ordered use_nl(o m) */ 
       u.name, nvl(j.longdbcs, o.name), m.maj, m.min, 
       decode(BITAND(m.acc, 512), 512, 'CLASS', 
                                  0, 'INTERFACE'),
       decode(BITAND(m.acc, 1), 1, 'PUBLIC', 
                                0, NULL),
       decode(BITAND(m.acc, 131072), 131072, 'YES', 
                                     0, 'NO'),
       decode(BITAND(m.acc, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.acc, 16), 16, 'YES',
                                 0, 'NO'),
       decode(m.dbg, 1, 'YES',
                     0, 'NO'),    
       m.src, m.spl, m.oln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_CLASSES is
'class level information of all stored java classes'
/
comment on column DBA_JAVA_CLASSES.OWNER is
'owner of this java class'
/
comment on column DBA_JAVA_CLASSES.NAME is 
'name of the java class'
/
comment on column DBA_JAVA_CLASSES.MAJOR is
'the major version number of the java class as defined in JVM specification'
/
comment on column DBA_JAVA_CLASSES.MINOR is
'the minor version number of the java class as defined in JVM specification'
/
comment on column DBA_JAVA_CLASSES.KIND is
'is the stored object a java class or java interface?'
/
comment on column DBA_JAVA_CLASSES.ACCESSIBILITY is
'the accessiblity of the java class'
/
comment on column DBA_JAVA_CLASSES.IS_INNER is
'is this java class an inner class'
/
comment on column DBA_JAVA_CLASSES.IS_ABSTRACT is
'is this an abstract class?'
/
comment on column DBA_JAVA_CLASSES.IS_FINAL is
'is this an final class?'
/
comment on column DBA_JAVA_CLASSES.IS_DEBUG is
'does this class contain debug information?'
/
comment on column DBA_JAVA_CLASSES.SOURCE is
'source designation of the java class '
/
comment on column DBA_JAVA_CLASSES.SUPER is
'super class of this java class'
/
comment on column DBA_JAVA_CLASSES.OUTER is
'outer class of this java class if this java class is an inner class'
/
create or replace public synonym DBA_JAVA_CLASSES for DBA_JAVA_CLASSES
/
grant select on DBA_JAVA_CLASSES to select_catalog_role
/

remark 
remark FAMILY "JAVA_LAYOUTS
remark
 
create or replace view USER_JAVA_LAYOUTS
(NAME, INTERFACES, INNER_CLASSES, 
       FIELDS, STATIC_FIELDS, 
       METHODS, STATIC_METHODS, NATIVE_METHODS)
as 
select /*+ ordered use_nl(o m) */
              nvl(j.longdbcs, o.name), m.lic, m.lnc,
              m.lfc, m.lsf, 
              m.lmc, m.lsm, m.jnc
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_LAYOUTS is
'class layout information about stored java class owned by the user'
/
comment on column USER_JAVA_LAYOUTS.NAME is 
'name of the stored java class'
/
comment on column USER_JAVA_LAYOUTS.INTERFACES is 
'how many interfaces does this class implement?'
/
comment on column USER_JAVA_LAYOUTS.INNER_CLASSES is 
'how many inner classes does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.FIELDS is 
'how many locally declared fields does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.STATIC_FIELDS is 
'how many locally declared static fields does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.METHODS is 
'how many locally declared methods does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.STATIC_METHODS is 
'how many locally declared static methods does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.NATIVE_METHODS is 
'how many locally declared native methods does this class contain?'
/
create or replace public synonym USER_JAVA_LAYOUTS for USER_JAVA_LAYOUTS
/
grant select on USER_JAVA_LAYOUTS to public with grant option
/

create or replace view ALL_JAVA_LAYOUTS
(OWNER, NAME, INTERFACES, INNER_CLASSES,
       FIELDS, STATIC_FIELDS, 
       METHODS, STATIC_METHODS, NATIVE_METHODS)
as 
select /*+ ordered use_nl(o m) */ 
              u.name, nvl(j.longdbcs, o.name), m.lic, m.lnc,
              m.lfc, m.lsf, 
              m.lmc, m.lsm, m.jnc
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_LAYOUTS is
'class layout information about stored java class accessible to the user'
/
comment on column ALL_JAVA_LAYOUTS.OWNER is
'owner of the java class'
/
comment on column USER_JAVA_LAYOUTS.NAME is 
'name of the stored java class'
/
comment on column ALL_JAVA_LAYOUTS.INTERFACES is 
'how many interfaces does this class implement?'
/
comment on column ALL_JAVA_LAYOUTS.INNER_CLASSES is 
'how many inner classes does this class contain?'
/
comment on column ALL_JAVA_LAYOUTS.FIELDS is 
'how many locally declared fields does this class contain?'
/
comment on column ALL_JAVA_LAYOUTS.STATIC_FIELDS is 
'how many locally declared static fields does this class contain?'
/
comment on column ALL_JAVA_LAYOUTS.METHODS is 
'how many locally declared methods does this class contain?'
/
comment on column ALL_JAVA_LAYOUTS.STATIC_METHODS is 
'how many locally declared static methods does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.NATIVE_METHODS is 
'how many locally declared native methods does this class contain?'
/
create or replace public synonym ALL_JAVA_LAYOUTS for ALL_JAVA_LAYOUTS
/
grant select on ALL_JAVA_LAYOUTS to public with grant option
/

create or replace view DBA_JAVA_LAYOUTS
(OWNER, NAME, INTERFACES, INNER_CLASSES,
       FIELDS, STATIC_FIELDS, 
       METHODS, STATIC_METHODS, NATIVE_METHODS)
as 
select /*+ ordered use_nl(o m) */ 
              u.name, nvl(j.longdbcs, o.name), m.lic, m.lnc,
              m.lfc, m.lsf, 
              m.lmc, m.lsm, m.jnc
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmob m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_LAYOUTS is
'class layout information about stored java class'
/
comment on column DBA_JAVA_LAYOUTS.OWNER is
'owner of this java class'
/
comment on column DBA_JAVA_LAYOUTS.NAME is
'name of the stored java class'
/
comment on column DBA_JAVA_LAYOUTS.INTERFACES is 
'how many interfaces does this class implement?'
/
comment on column DBA_JAVA_LAYOUTS.INNER_CLASSES is 
'how many inner classes does this class contain?'
/
comment on column DBA_JAVA_LAYOUTS.FIELDS is 
'how many locally declared fields does this class contain?'
/
comment on column DBA_JAVA_LAYOUTS.STATIC_FIELDS is 
'how many locally declared static fields does this class contain?'
/
comment on column DBA_JAVA_LAYOUTS.METHODS is 
'how many locally declared methods does this class contain?'
/
comment on column DBA_JAVA_LAYOUTS.STATIC_METHODS is 
'how many locally declared static methods does this class contain?'
/
comment on column USER_JAVA_LAYOUTS.NATIVE_METHODS is 
'how many locally declared native methods does this class contain?'
/
create or replace public synonym DBA_JAVA_LAYOUTS for DBA_JAVA_LAYOUTS
/
grant select on DBA_JAVA_LAYOUTS to select_catalog_role
/


remark 
remark FAMILY "JAVA_IMPLEMENTS"
remark 
create or replace view USER_JAVA_IMPLEMENTS
(NAME, INTERFACE_INDEX, INTERFACE_NAME) 
as 
select /*+ ordered use_nl(o m) */ nvl(j.longdbcs, o.name), m.ifx, m.iln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmif m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_IMPLEMENTS is
'interfaces implemented by the stored java class owned by user'
/
comment on column USER_JAVA_IMPLEMENTS.NAME is 
'name of the stored java class'
/
comment on column USER_JAVA_IMPLEMENTS.INTERFACE_INDEX is 
'index of the interfaces implemented by the stored java class'
/
comment on column USER_JAVA_IMPLEMENTS.INTERFACE_NAME is 
'name of the interface identified by the INTERFACE_INDEX'
/
create or replace public synonym USER_JAVA_IMPLEMENTS for USER_JAVA_IMPLEMENTS
/
grant select on USER_JAVA_IMPLEMENTS to public with grant option
/

create or replace view ALL_JAVA_IMPLEMENTS
(OWNER, NAME, INTERFACE_INDEX, INTERFACE_NAME) 
as 
select /*+ ordered use_nl(o m) */ 
       u.name, nvl(j.longdbcs, o.name), m.ifx, m.iln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmif m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_JAVA_IMPLEMENTS is
'interfaces implemented by the stored java class accessible to the user'
/
comment on column ALL_JAVA_IMPLEMENTS.OWNER is
'owner of the java class'
/
comment on column ALL_JAVA_IMPLEMENTS.NAME is 
'name of the stored java class'
/
comment on column ALL_JAVA_IMPLEMENTS.INTERFACE_INDEX is 
'index of the interfaces implemented by the stored java class'
/
comment on column ALL_JAVA_IMPLEMENTS.INTERFACE_NAME is 
'name of the interface identified by the INTERFACE_INDEX'
/
create or replace public synonym ALL_JAVA_IMPLEMENTS for ALL_JAVA_IMPLEMENTS
/
grant select on ALL_JAVA_IMPLEMENTS to public with grant option
/

create or replace view DBA_JAVA_IMPLEMENTS
(OWNER, NAME, INTERFACE_INDEX, INTERFACE_NAME) 
as 
select /*+ ordered use_nl(o m) */ 
       u.name, nvl(j.longdbcs, o.name), m.ifx, m.iln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmif m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_IMPLEMENTS is
'interfaces implemented by the stored java class'
/
comment on column DBA_JAVA_IMPLEMENTS.OWNER is
'owner of the java stored class'
/
comment on column DBA_JAVA_IMPLEMENTS.NAME is 
'name of the stored java class'
/
comment on column DBA_JAVA_IMPLEMENTS.INTERFACE_INDEX is 
'index of the interfaces implemented by the stored java class'
/
comment on column DBA_JAVA_IMPLEMENTS.INTERFACE_NAME is 
'name of the interface identified by the column INTERFACE_INDEX'
/
create or replace public synonym DBA_JAVA_IMPLEMENTS for DBA_JAVA_IMPLEMENTS
/
grant select on DBA_JAVA_IMPLEMENTS to select_catalog_role
/

remark
remark FAMILY "JAVA_INNERS"
remark 
remark TODO should add a field to show whether the inner class
remark is a member of the refering class? Some x$joxfm changes
remark are needed to make this possible.

create or replace view USER_JAVA_INNERS
(NAME, INNER_INDEX, SIMPLE_NAME, FULL_NAME, ACCESSIBILITY, 
 IS_STATIC, IS_FINAL, IS_ABSTRACT, IS_INTERFACE)
as 
select /*+ ordered use_nl(o m) */ 
       nvl(j.longdbcs, o.name), m.nix, m.nsm, m.nln, 
       decode(BITAND(m.oac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.acc, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.acc, 16), 16, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.acc, 1024), 1024, 'YES',
                                   0, 'NO'),
       decode(BITAND(m.acc, 512), 512, 'YES',
                                  0, 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmic m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_INNERS is
'list of inner classes refered by the stored java class owned by user'
/
comment on column USER_JAVA_INNERS.NAME is 
'name of the stored java class'
/
comment on column USER_JAVA_INNERS.INNER_INDEX is 
'index of the refered inner class'
/
comment on column USER_JAVA_INNERS.SIMPLE_NAME is 
'simple name of the refered inner class'
/
comment on column USER_JAVA_INNERS.FULL_NAME is 
'full name of the refered inner class'
/
comment on column USER_JAVA_INNERS.IS_STATIC is 
'is the refered inner class declared static in the sorce file'
/
comment on column USER_JAVA_INNERS.IS_FINAL is 
'is the refered inner class declared final in the sorce file'
/
comment on column USER_JAVA_INNERS.IS_ABSTRACT is 
'is the refered inner class declared abstract in the sorce file'
/
comment on column USER_JAVA_INNERS.IS_INTERFACE is 
'is the refered inner class declared interface in the sorce file'
/
create or replace public synonym USER_JAVA_INNERS for USER_JAVA_INNERS
/
grant select on USER_JAVA_INNERS to public with grant option
/

create or replace view ALL_JAVA_INNERS
(OWNER, NAME, INNER_INDEX, SIMPLE_NAME, FULL_NAME, ACCESSIBILITY, 
 IS_STATIC, IS_FINAL, IS_ABSTRACT, IS_INTERFACE)
as 
select /*+ ordered use_nl(o m) */ 
       u.name, nvl(j.longdbcs, o.name) , m.nix, m.nsm, m.nln, 
       decode(BITAND(m.oac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.acc, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.acc, 16), 16, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.acc, 1024), 1024, 'YES',
                                   0, 'NO'),
       decode(BITAND(m.acc, 512), 512, 'YES',
                                  0, 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmic m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_INNERS is
'list of inner classes refered by the stored java class accessible to user'
/
comment on column ALL_JAVA_INNERS.OWNER is
'owner of the stored java class'
/
comment on column ALL_JAVA_INNERS.NAME is 
'name of the stored java class'
/
comment on column ALL_JAVA_INNERS.INNER_INDEX is 
'index of the refered inner class'
/
comment on column ALL_JAVA_INNERS.SIMPLE_NAME is 
'simple name of the refered inner class'
/
comment on column ALL_JAVA_INNERS.FULL_NAME is 
'full name of the refered inner class'
/
comment on column ALL_JAVA_INNERS.IS_STATIC is 
'is the refered inner class declared static in the sorce file'
/
comment on column ALL_JAVA_INNERS.IS_FINAL is 
'is the refered inner class declared final in the sorce file'
/
comment on column ALL_JAVA_INNERS.IS_ABSTRACT is 
'is the refered inner class declared abstract in the sorce file'
/
comment on column ALL_JAVA_INNERS.IS_INTERFACE is 
'is the refered inner class declared interface in the sorce file'
/
create or replace public synonym ALL_JAVA_INNERS for ALL_JAVA_INNERS
/
grant select on ALL_JAVA_INNERS to public with grant option
/

create or replace view DBA_JAVA_INNERS
(OWNER, NAME, INNER_INDEX, SIMPLE_NAME, FULL_NAME, ACCESSIBILITY, 
 IS_STATIC, IS_FINAL, IS_ABSTRACT, IS_INTERFACE)
as 
select /*+ ordered use_nl(o m) */ 
       u.name, nvl(j.longdbcs, o.name), m.nix, m.nsm, m.nln, 
       decode(BITAND(m.oac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.acc, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.acc, 16), 16, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.acc, 1024), 1024, 'YES',
                                   0, 'NO'),
       decode(BITAND(m.acc, 512), 512, 'YES',
                                  0, 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmic m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_INNERS is
'list of inner classes refered by the stored java class'
/
comment on column DBA_JAVA_INNERS.OWNER is 
'owner of the stored java class'
/
comment on column DBA_JAVA_INNERS.NAME is 
'name of the stored java class'
/
comment on column DBA_JAVA_INNERS.INNER_INDEX is 
'index of the refered inner class'
/
comment on column DBA_JAVA_INNERS.SIMPLE_NAME is 
'simple name of the refered inner class'
/
comment on column DBA_JAVA_INNERS.FULL_NAME is 
'full name of the refered inner class'
/
comment on column DBA_JAVA_INNERS.IS_STATIC is 
'is the refered inner class declared static in the sorce file'
/
comment on column DBA_JAVA_INNERS.IS_FINAL is 
'is the refered inner class declared final in the sorce file'
/
comment on column DBA_JAVA_INNERS.IS_ABSTRACT is 
'is the refered inner class declared abstract in the sorce file'
/
comment on column DBA_JAVA_INNERS.IS_INTERFACE is 
'is the refered inner class declared interface in the sorce file'
/
create or replace public synonym DBA_JAVA_INNERS for DBA_JAVA_INNERS
/
grant select on DBA_JAVA_INNERS to select_catalog_role
/


remark
remark FAMILY "JAVA_FIELDS"
remark

create or replace view USER_JAVA_FIELDS
(NAME, FIELD_INDEX, FIELD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_VOLATILE, IS_TRANSIENT, 
       ARRAY_DEPTH, BASE_TYPE, FIELD_CLASS) 
as 
select /*+ ordered use_nl(o m) */ nvl(j.longdbcs, o.name), m.fix, m.fnm, 
       decode(BITAND(m.fac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.fac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.fac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.fac, 64), 64, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.fac, 128), 128, 'YES',
                                  0, 'NO'),
       m.fad, 
       decode(m.fbt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       m.fln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmfd m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_FIELDS is
'field information of stored java class owned by the user'
/
comment on column USER_JAVA_FIELDS.NAME is 
'name of the java class'
/
comment on column USER_JAVA_FIELDS.FIELD_INDEX is
'the index of the field'
/
comment on column USER_JAVA_FIELDS.FIELD_NAME is
'the name of the field at FIELD_INDEX'
/
comment on column USER_JAVA_FIELDS.ACCESSIBILITY is
'the accessiblity of the field, public/private/protected/null(i.e. package)'
/
comment on column USER_JAVA_FIELDS.IS_STATIC is
'is the field a static field?'
/
comment on column USER_JAVA_FIELDS.IS_FINAL is
'is the field a final field?'
/
comment on column USER_JAVA_FIELDS.IS_VOLATILE is
'is the field volotile?'
/
comment on column USER_JAVA_FIELDS.IS_TRANSIENT is
'is the field transient?'
/
comment on column USER_JAVA_FIELDS.ARRAY_DEPTH is
'array depth of the type of the field'
/
comment on column USER_JAVA_FIELDS.BASE_TYPE is
'base type of the type of the field'
/
comment on column USER_JAVA_FIELDS.FIELD_CLASS is
'if base_type is class, this gives the actual class name of the base object'
/
create or replace public synonym USER_JAVA_FIELDS for USER_JAVA_FIELDS
/
grant select on USER_JAVA_FIELDS to public with grant option
/

create or replace view ALL_JAVA_FIELDS
(OWNER, NAME, FIELD_INDEX, FIELD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_VOLATILE, IS_TRANSIENT, 
       ARRAY_DEPTH, BASE_TYPE, FIELD_CLASS) 
as 
select /*+ ordered use_nl(o m) */ u.name, nvl(j.longdbcs, o.name), m.fix, m.fnm, 
       decode(BITAND(m.fac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.fac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.fac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.fac, 64), 64, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.fac, 128), 128, 'YES',
                                  0, 'NO'),
       m.fad, 
       decode(m.fbt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       m.fln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmfd m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_FIELDS is
'field information of stored java class accessible to user'
/
comment on column ALL_JAVA_FIELDS.OWNER is
'owner of the stored java class'
/
comment on column ALL_JAVA_FIELDS.NAME is 
'name of the java class'
/
comment on column ALL_JAVA_FIELDS.FIELD_INDEX is
'the index of the field'
/
comment on column ALL_JAVA_FIELDS.FIELD_NAME is
'the name of the field at FIELD_INDEX'
/
comment on column ALL_JAVA_FIELDS.ACCESSIBILITY is
'the accessiblity of the field, public/private/protected/null(i.e. package)'
/
comment on column ALL_JAVA_FIELDS.IS_STATIC is
'is the field a static field?'
/
comment on column ALL_JAVA_FIELDS.IS_FINAL is
'is the field a final field?'
/
comment on column ALL_JAVA_FIELDS.IS_VOLATILE is
'is the field volotile?'
/
comment on column ALL_JAVA_FIELDS.IS_TRANSIENT is
'is the field transient?'
/
comment on column ALL_JAVA_FIELDS.ARRAY_DEPTH is
'array depth of the type of the field'
/
comment on column ALL_JAVA_FIELDS.BASE_TYPE is
'base type of the type of the field'
/
comment on column ALL_JAVA_FIELDS.FIELD_CLASS is
'if base_type is class, this gives the actual class name of the base object'
/
create or replace public synonym ALL_JAVA_FIELDS for ALL_JAVA_FIELDS
/
grant select on ALL_JAVA_FIELDS to public with grant option
/

create or replace view DBA_JAVA_FIELDS
(OWNER, NAME, FIELD_INDEX, FIELD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_VOLATILE, IS_TRANSIENT, 
       ARRAY_DEPTH, BASE_TYPE, FIELD_CLASS) 
as 
select /*+ ordered use_nl(o m) */ u.name, nvl(j.longdbcs, o.name), m.fix, m.fnm, 
       decode(BITAND(m.fac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.fac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.fac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.fac, 64), 64, 'YES', 
                                 0, 'NO'), 
       decode(BITAND(m.fac, 128), 128, 'YES',
                                  0, 'NO'),
       m.fad, 
       decode(m.fbt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       m.fln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmfd m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_FIELDS is
'field information of all stored java class'
/
comment on column DBA_JAVA_FIELDS.NAME is 
'name of the java class'
/
comment on column DBA_JAVA_FIELDS.FIELD_INDEX is
'the index of the field'
/
comment on column DBA_JAVA_FIELDS.FIELD_NAME is
'the name of the field at FIELD_INDEX'
/
comment on column DBA_JAVA_FIELDS.ACCESSIBILITY is
'the accessiblity of the field, public/private/protected/null(i.e. package)'
/
comment on column DBA_JAVA_FIELDS.IS_STATIC is
'is the field a static field?'
/
comment on column DBA_JAVA_FIELDS.IS_FINAL is
'is the field a final field?'
/
comment on column DBA_JAVA_FIELDS.IS_VOLATILE is
'is the field volotile?'
/
comment on column DBA_JAVA_FIELDS.IS_TRANSIENT is
'is the field transient?'
/
comment on column DBA_JAVA_FIELDS.ARRAY_DEPTH is
'array depth of the type of the field'
/
comment on column DBA_JAVA_FIELDS.BASE_TYPE is
'base type of the type of the field'
/
comment on column DBA_JAVA_FIELDS.FIELD_CLASS is
'if base_type is class, this gives the actual class name of the base object'
/
create or replace public synonym DBA_JAVA_FIELDS for DBA_JAVA_FIELDS
/
grant select on DBA_JAVA_FIELDS to select_catalog_role
/


remark
remark FAMILY "JAVA_METHODS"
remark

create or replace view USER_JAVA_METHODS
(NAME, METHOD_INDEX, METHOD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_SYNCHRONIZED, 
       IS_NATIVE, IS_ABSTRACT, IS_STRICT,
       ARGUMENTS, THROWS,  
       ARRAY_DEPTH, BASE_TYPE, RETURN_CLASS, IS_COMPILED) 
as 
select /*+ ordered use_nl(o m) */
       nvl(j.longdbcs, o.name), m.mix, m.mnm, 
       decode(BITAND(m.mac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.mac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.mac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.mac, 32), 32, 'YES',
                                 0, 'NO'),
       decode(BITAND(m.mac, 256), 256, 'YES',
                                  0, 'NO'),
       decode(BITAND(m.mac, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.mac, 2048), 2048, 'YES',
                                   0, 'NO'),
       m.agc, m.exc, m.rad, 
       decode(m.rbt, 10, 'int',
                     11, 'long',
                     6,  'float',
                     7,  'double',
                     4,  'boolean',
                     8,  'byte',
                     5,  'char',
                     9,  'short',
                     2,  'class',
                     12, 'void',
                     NULL),
       m.rln,
       nvl((select 'YES' from sys.java$mc$ j where 
               j.method#=m.mmt and 
               j.obj#=m.obn and
               rownum=1), 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmmd m
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_METHODS is
'method information of stored java class owned by the user'
/
comment on column USER_JAVA_METHODS.NAME is 
'name of the java class'
/
comment on column USER_JAVA_METHODS.METHOD_INDEX is
'the index of the method'
/
comment on column USER_JAVA_METHODS.METHOD_NAME is
'the name of the field at METHOD_INDEX'
/
comment on column USER_JAVA_METHODS.ACCESSIBILITY is
'the accessiblity of the method, public/private/protected/null(i.e. package)'
/
comment on column USER_JAVA_METHODS.IS_STATIC is
'is the method a static method?'
/
comment on column USER_JAVA_METHODS.IS_FINAL is
'is the method a final method?'
/
comment on column USER_JAVA_METHODS.IS_SYNCHRONIZED is
'is the method a synchronized method?'
/
comment on column USER_JAVA_METHODS.IS_NATIVE is
'is the method a native method?'
/
comment on column USER_JAVA_METHODS.IS_ABSTRACT is
'is the method an abstract method?'
/
comment on column USER_JAVA_METHODS.IS_STRICT is
'is the method a strict method?'
/
comment on column USER_JAVA_METHODS.ARGUMENTS is
'number of arguments of the method'
/
comment on column USER_JAVA_METHODS.THROWS is
'number of exceptions thrown by the method'
/

comment on column USER_JAVA_METHODS.ARRAY_DEPTH is
'array depth of the return type of the method'
/
comment on column USER_JAVA_METHODS.BASE_TYPE is
'base type of the return type of the field'
/
comment on column USER_JAVA_METHODS.RETURN_CLASS is
'if base_type is class, this gives the actual class name of the return value'
/
create or replace public synonym USER_JAVA_METHODS for USER_JAVA_METHODS
/
grant select on USER_JAVA_METHODS to public with grant option
/

create or replace view ALL_JAVA_METHODS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_SYNCHRONIZED, 
       IS_NATIVE, IS_ABSTRACT, IS_STRICT,
       ARGUMENTS, THROWS,  
       ARRAY_DEPTH, BASE_TYPE, RETURN_CLASS, IS_COMPILED) 
as 
select /*+ ordered use_nl(o m) */ u.name, nvl(j.longdbcs, o.name), m.mix, m.mnm, 
       decode(BITAND(m.mac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.mac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.mac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.mac, 32), 32, 'YES',
                                 0, 'NO'),
       decode(BITAND(m.mac, 256), 256, 'YES',
                                  0, 'NO'),
       decode(BITAND(m.mac, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.mac, 2048), 2048, 'YES',
                                   0, 'NO'),
       m.agc, m.exc, m.rad, 
       decode(m.rbt, 10, 'int',
                     11, 'long',
                     6,  'float',
                     7,  'double',
                     4,  'boolean',
                     8,  'byte',
                     5,  'char',
                     9,  'short',
                     2,  'class',
                     12, 'void',
                     NULL),
       m.rln,
       nvl((select 'YES' from sys.java$mc$ j where 
               j.method#=m.mmt and 
               j.obj#=m.obn and
               rownum=1), 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmmd m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_METHODS is
'method information of stored java class accessible to user'
/
comment on column ALL_JAVA_METHODS.OWNER is
'owner of the stored java class'
/
comment on column ALL_JAVA_METHODS.NAME is 
'name of the java class'
/
comment on column ALL_JAVA_METHODS.METHOD_INDEX is
'the index of the method'
/
comment on column ALL_JAVA_METHODS.METHOD_NAME is
'the name of the field at METHOD_INDEX'
/
comment on column ALL_JAVA_METHODS.ACCESSIBILITY is
'the accessiblity of the method, public/private/protected/null(i.e. package)'
/
comment on column ALL_JAVA_METHODS.IS_STATIC is
'is the method a static method?'
/
comment on column ALL_JAVA_METHODS.IS_FINAL is
'is the method a final method?'
/
comment on column ALL_JAVA_METHODS.IS_SYNCHRONIZED is
'is the method a synchronized method?'
/
comment on column ALL_JAVA_METHODS.IS_NATIVE is
'is the method a native method?'
/
comment on column ALL_JAVA_METHODS.IS_ABSTRACT is
'is the method an abstract method?'
/
comment on column ALL_JAVA_METHODS.IS_STRICT is
'is the method a strict method?'
/
comment on column ALL_JAVA_METHODS.ARGUMENTS is
'number of arguments of the method'
/
comment on column ALL_JAVA_METHODS.THROWS is
'number of exceptions thrown by the method'
/

comment on column ALL_JAVA_METHODS.ARRAY_DEPTH is
'array depth of the return type of the method'
/
comment on column ALL_JAVA_METHODS.BASE_TYPE is
'base type of the return type of the field'
/
comment on column ALL_JAVA_METHODS.RETURN_CLASS is
'if base_type is class, this gives the actual class name of the return value'
/
create or replace public synonym ALL_JAVA_METHODS for ALL_JAVA_METHODS
/
grant select on ALL_JAVA_METHODS to public with grant option
/

create or replace view DBA_JAVA_METHODS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, ACCESSIBILITY,
       IS_STATIC, IS_FINAL, IS_SYNCHRONIZED, 
       IS_NATIVE, IS_ABSTRACT, IS_STRICT,
       ARGUMENTS, THROWS,  
       ARRAY_DEPTH, BASE_TYPE, RETURN_CLASS, IS_COMPILED) 
as 
select /*+ ordered use_nl(o m) */ u.name, nvl(j.longdbcs, o.name), m.mix, m.mnm, 
       decode(BITAND(m.mac, 7), 1, 'PUBLIC', 
                                2, 'PRIVATE',
                                4, 'PROTECTED',
                                NULL),
       decode(BITAND(m.mac, 8), 8, 'YES', 
                                0, 'NO'),
       decode(BITAND(m.mac, 16), 16, 'YES', 
                                 0, 'NO'),
       decode(BITAND(m.mac, 32), 32, 'YES',
                                 0, 'NO'),
       decode(BITAND(m.mac, 256), 256, 'YES',
                                  0, 'NO'),
       decode(BITAND(m.mac, 1024), 1024, 'YES', 
                                   0, 'NO'), 
       decode(BITAND(m.mac, 2048), 2048, 'YES',
                                   0, 'NO'),
       m.agc, m.exc, m.rad, 
       decode(m.rbt, 10, 'int',
                     11, 'long',
                     6,  'float',
                     7,  'double',
                     4,  'boolean',
                     8,  'byte',
                     5,  'char',
                     9,  'short',
                     2,  'class',
                     12, 'void',
                     NULL),
       m.rln,
       nvl((select 'YES' from sys.java$mc$ j where 
               j.method#=m.mmt and 
               j.obj#=m.obn and
               rownum=1), 'NO')
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmmd m, sys.user$ u
where o.obj# = m.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_METHODS is
'method information of all stored java class'
/
comment on column DBA_JAVA_METHODS.OWNER is 
'owner of the java class'
/
comment on column DBA_JAVA_METHODS.NAME is 
'name of the java class'
/
comment on column DBA_JAVA_METHODS.METHOD_INDEX is
'the index of the method'
/
comment on column DBA_JAVA_METHODS.METHOD_NAME is
'the name of the field at METHOD_INDEX'
/
comment on column DBA_JAVA_METHODS.ACCESSIBILITY is
'the accessiblity of the method, public/private/protected/null(i.e. package)'
/
comment on column DBA_JAVA_METHODS.IS_STATIC is
'is the method a static method?'
/
comment on column DBA_JAVA_METHODS.IS_FINAL is
'is the method a final method?'
/
comment on column DBA_JAVA_METHODS.IS_SYNCHRONIZED is
'is the method a synchronized method?'
/
comment on column DBA_JAVA_METHODS.IS_NATIVE is
'is the method a native method?'
/
comment on column DBA_JAVA_METHODS.IS_ABSTRACT is
'is the method an abstract method?'
/
comment on column DBA_JAVA_METHODS.IS_STRICT is
'is the method a strict method?'
/
comment on column DBA_JAVA_METHODS.ARGUMENTS is
'number of arguments of the method'
/
comment on column DBA_JAVA_METHODS.THROWS is
'number of exceptions thrown by the method'
/
comment on column DBA_JAVA_METHODS.ARRAY_DEPTH is
'array depth of the return type of the method'
/
comment on column DBA_JAVA_METHODS.BASE_TYPE is
'base type of the return type of the field'
/
comment on column DBA_JAVA_METHODS.RETURN_CLASS is
'if base_type is class, this gives the actual class name of the return value'
/
create or replace public synonym DBA_JAVA_METHODS for DBA_JAVA_METHODS
/
grant select on DBA_JAVA_METHODS to select_catalog_role
/

remark 
remark FAMILY "JAVA_ARGUMENTS"
remark
 
create or replace view USER_JAVA_ARGUMENTS
(NAME, METHOD_INDEX, METHOD_NAME, ARGUMENT_POSITION, 
       ARRAY_DEPTH, BASE_TYPE, ARGUMENT_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mag.aix, 
       mag.aad, 
       decode(mag.abt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       mag.aln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxfm mmd, sys.x$joxmag mag
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
  and mmd.mix = mag.mix
  and mmd.obn = mag.obn;
/
comment on table USER_JAVA_ARGUMENTS is
'argument information of stored java class owned by the user'
/
comment on column USER_JAVA_ARGUMENTS.NAME is 
'name of the java class'
/
comment on column USER_JAVA_ARGUMENTS.METHOD_INDEX is
'the index of hosting method of the argument'
/
comment on column USER_JAVA_ARGUMENTS.METHOD_NAME is
'the name of hosting method of the argument'
/
comment on column USER_JAVA_ARGUMENTS.ARGUMENT_POSITION is
'the position of the argument, starting from 0'
/
comment on column USER_JAVA_ARGUMENTS.ARRAY_DEPTH is
'array depth of the type of the arguement'
/
comment on column USER_JAVA_ARGUMENTS.BASE_TYPE is
'base type of the type of the argument'
/
comment on column USER_JAVA_ARGUMENTS.ARGUMENT_CLASS is
'if base_type is class, this gives the actual class name of the argument'
/
create or replace public synonym USER_JAVA_ARGUMENTS for USER_JAVA_ARGUMENTS
/
grant select on USER_JAVA_ARGUMENTS to public with grant option
/

create or replace view ALL_JAVA_ARGUMENTS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, ARGUMENT_POSITION, 
       ARRAY_DEPTH, BASE_TYPE, ARGUMENT_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ u.name, nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mag.aix, 
       mag.aad, 
       decode(mag.abt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       mag.aln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxfm mmd, sys.x$joxmag mag, sys.user$ u
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and mmd.mix = mag.mix
  and mmd.obn = mag.obn
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_ARGUMENTS is
'argument information of stored java class accessible to the user'
/
comment on column ALL_JAVA_ARGUMENTS.OWNER is
'owner of the stored java class'
/
comment on column ALL_JAVA_ARGUMENTS.NAME is 
'name of the java class'
/
comment on column ALL_JAVA_ARGUMENTS.METHOD_INDEX is
'the index of hosting method of the argument'
/
comment on column ALL_JAVA_ARGUMENTS.METHOD_NAME is
'the name of hosting method of the argument'
/
comment on column ALL_JAVA_ARGUMENTS.ARGUMENT_POSITION is
'the position of the argument, starting from 0'
/
comment on column ALL_JAVA_ARGUMENTS.ARRAY_DEPTH is
'array depth of the type of the arguement'
/
comment on column ALL_JAVA_ARGUMENTS.BASE_TYPE is
'base type of the type of the argument'
/
comment on column ALL_JAVA_ARGUMENTS.ARGUMENT_CLASS is
'if base_type is class, this gives the actual class name of the argument'
/
create or replace public synonym ALL_JAVA_ARGUMENTS for ALL_JAVA_ARGUMENTS
/
grant select on ALL_JAVA_ARGUMENTS to public with grant option
/

create or replace view DBA_JAVA_ARGUMENTS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, ARGUMENT_POSITION, 
       ARRAY_DEPTH, BASE_TYPE, ARGUMENT_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ u.name, nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mag.aix, 
       mag.aad, 
       decode(mag.abt, 10, 'int',
                     11, 'long',
                     6, 'float',
                     7, 'double',
                     4, 'boolean',
                     8, 'byte',
                     5, 'char',
                     9, 'short',
                     2, 'class',
                     NULL),
       mag.aln
from sys.javasnm$ j, sys.obj$ o, sys.x$joxfm mmd, sys.x$joxmag mag, sys.user$ u
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and mmd.mix = mag.mix
  and mmd.obn = mag.obn
/
comment on table DBA_JAVA_ARGUMENTS is
'argument information of all stored java class'
/
comment on column DBA_JAVA_ARGUMENTS.OWNER is 
'owner of the java class'
/
comment on column DBA_JAVA_ARGUMENTS.NAME is 
'name of the java class'
/
comment on column DBA_JAVA_ARGUMENTS.METHOD_INDEX is
'the index of hosting method of the argument'
/
comment on column DBA_JAVA_ARGUMENTS.METHOD_NAME is
'the name of hosting method of the argument'
/
comment on column DBA_JAVA_ARGUMENTS.ARGUMENT_POSITION is
'the position of the argument, starting from 0'
/
comment on column DBA_JAVA_ARGUMENTS.ARRAY_DEPTH is
'array depth of the type of the arguement'
/
comment on column DBA_JAVA_ARGUMENTS.BASE_TYPE is
'base type of the type of the argument'
/
comment on column DBA_JAVA_ARGUMENTS.ARGUMENT_CLASS is
'if base_type is class, this gives the actual class name of the argument'
/
create or replace public synonym DBA_JAVA_ARGUMENTS for DBA_JAVA_ARGUMENTS
/
grant select on DBA_JAVA_ARGUMENTS to select_catalog_role
/

remark 
remark FAMILY "JAVA_THROWS"
remark

create or replace view USER_JAVA_THROWS
(NAME, METHOD_INDEX, METHOD_NAME, EXCEPTION_INDEX, EXCEPTION_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mex.xix, mex.xln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmex mex, sys.x$joxmmd mmd
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
  and mmd.mix = mex.mix
  and mmd.obn = mex.obn;
/
comment on table USER_JAVA_THROWS is
'list of exceptions thrown from a method of a class owned by user'
/
comment on column USER_JAVA_THROWS.NAME is 
'name of the java class'
/
comment on column USER_JAVA_THROWS.METHOD_INDEX is
'the index of throwing method of the exception'
/
comment on column USER_JAVA_THROWS.METHOD_NAME is
'the name of throwing method of the exception'
/
comment on column USER_JAVA_THROWS.EXCEPTION_INDEX is
'the index of the exception'
/
comment on column USER_JAVA_THROWS.EXCEPTION_CLASS is
'the class of the exception'
/
create or replace public synonym USER_JAVA_THROWS for USER_JAVA_THROWS
/
grant select on USER_JAVA_THROWS to public with grant option
/

create or replace view ALL_JAVA_THROWS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, EXCEPTION_INDEX, EXCEPTION_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ u.name, nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mex.xix, mex.xln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmex mex, sys.x$joxmmd mmd, sys.user$ u
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and mmd.mix = mex.mix
  and mmd.obn = mex.obn
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/      
comment on table ALL_JAVA_THROWS is
'list of exceptions thrown from a method of a class accessible to user'
/
comment on column ALL_JAVA_THROWS.OWNER is
'owner of the stored java class'
/
comment on column ALL_JAVA_THROWS.NAME is 
'name of the java class'
/
comment on column ALL_JAVA_THROWS.METHOD_INDEX is
'the index of throwing method of the exception'
/
comment on column ALL_JAVA_THROWS.METHOD_NAME is
'the name of throwing method of the exception'
/
comment on column ALL_JAVA_THROWS.EXCEPTION_INDEX is
'the index of the exception'
/
comment on column ALL_JAVA_THROWS.EXCEPTION_CLASS is
'the class of the exception'
/
create or replace public synonym ALL_JAVA_THROWS for ALL_JAVA_THROWS
/
grant select on ALL_JAVA_THROWS to public with grant option
/

create or replace view DBA_JAVA_THROWS
(OWNER, NAME, METHOD_INDEX, METHOD_NAME, EXCEPTION_INDEX, EXCEPTION_CLASS) 
as 
select /*+ ordered use_nl(o mmd) */ u.name, nvl(j.longdbcs, o.name), mmd.mix, mmd.mnm, mex.xix, mex.xln 
from sys.javasnm$ j, sys.obj$ o, sys.x$joxmex mex, sys.x$joxmmd mmd, sys.user$ u
where o.obj# = mmd.obn 
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and mmd.mix = mex.mix
  and mmd.obn = mex.obn
/
comment on table DBA_JAVA_THROWS is
'list of exceptions thrown from a method of a class owned by user'
/
comment on column DBA_JAVA_THROWS.OWNER is 
'owner of the java class'
/
comment on column DBA_JAVA_THROWS.NAME is 
'name of the java class'
/
comment on column DBA_JAVA_THROWS.METHOD_INDEX is
'the index of throwing method of the exception'
/
comment on column DBA_JAVA_THROWS.METHOD_NAME is
'the name of throwing method of the exception'
/
comment on column DBA_JAVA_THROWS.EXCEPTION_INDEX is
'the index of the exception'
/
comment on column DBA_JAVA_THROWS.EXCEPTION_CLASS is
'the class of the exception'
/
create or replace public synonym DBA_JAVA_THROWS for DBA_JAVA_THROWS
/
grant select on DBA_JAVA_THROWS to select_catalog_role
/


remark
remark FAMILY "JAVA_DERIVATIONS"
remark

create or replace view USER_JAVA_DERIVATIONS
(SOURCE_NAME, CLASS_INDEX, CLASS_NAME)
as 
select nvl(j.longdbcs, o.name),
       t.joxftderivedclassnumber,
       nvl(j2.longdbcs, t.joxftderivedclassname)
from sys.javasnm$ j, sys.javasnm$ j2, sys.obj$ o, sys.x$joxdrc t
where o.obj# = t.joxftobn
  and o.type# = 28
  and j.short(+) = o.name
  and j2.short(+) = t.joxftderivedclassname
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_JAVA_DERIVATIONS is
'this view maps java source objects and their derived java class objects and java resource objects  for the java class owned by user'
/
comment on column USER_JAVA_DERIVATIONS.SOURCE_NAME is 
'name of the java source object'
/
comment on column USER_JAVA_DERIVATIONS.CLASS_INDEX is 
'index of the derived java class object'
/
comment on column USER_JAVA_DERIVATIONS.CLASS_NAME is 
'name of the derived java class object'
/
create or replace public synonym USER_JAVA_DERIVATIONS for USER_JAVA_DERIVATIONS
/
grant select on USER_JAVA_DERIVATIONS to public with grant option
/

create or replace view ALL_JAVA_DERIVATIONS
(OWNER, SOURCE_NAME, CLASS_INDEX, CLASS_NAME)
as 
select u.name,
       nvl(j.longdbcs, o.name),
       t.joxftderivedclassnumber,
       nvl(j2.longdbcs, t.joxftderivedclassname)
from sys.javasnm$ j, sys.javasnm$ j2, sys.obj$ o, sys.x$joxdrc t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 28
  and o.owner# = u.user#
  and j.short(+) = o.name
  and j2.short(+) = t.joxftderivedclassname
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_JAVA_DERIVATIONS is
'this view maps java source objects and their derived java class objects and java resource objects  for the java class accessible to user'
/
comment on column ALL_JAVA_DERIVATIONS.OWNER is 
'owner of the java class object'
/
comment on column ALL_JAVA_DERIVATIONS.SOURCE_NAME is 
'name of the java source object'
/
comment on column ALL_JAVA_DERIVATIONS.CLASS_INDEX is 
'index of the derived java class object'
/
comment on column ALL_JAVA_DERIVATIONS.CLASS_NAME is 
'name of the derived java class object'
/
create or replace public synonym ALL_JAVA_DERIVATIONS for ALL_JAVA_DERIVATIONS
/
grant select on ALL_JAVA_DERIVATIONS to public with grant option
/

create or replace view DBA_JAVA_DERIVATIONS
(OWNER, SOURCE_NAME, CLASS_INDEX, CLASS_NAME)
as 
select u.name,
       nvl(j.longdbcs, o.name),
       t.joxftderivedclassnumber,
       nvl(j2.longdbcs, t.joxftderivedclassname)
from sys.javasnm$ j, sys.javasnm$ j2, sys.obj$ o, sys.x$joxdrc t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 28
  and o.owner# = u.user#
  and j.short(+) = o.name
  and j2.short(+) = t.joxftderivedclassname
/
comment on table DBA_JAVA_DERIVATIONS is
'this view maps java source objects and their derived java class objects and java resource objects  for all java classes'
/ 
comment on column DBA_JAVA_DERIVATIONS.OWNER is 
'owner of the java class object'
/
comment on column DBA_JAVA_DERIVATIONS.SOURCE_NAME is 
'name of the java source object'
/
comment on column DBA_JAVA_DERIVATIONS.CLASS_INDEX is 
'index of the derived java class object'
/
comment on column DBA_JAVA_DERIVATIONS.CLASS_NAME is 
'name of the derived java class object'
/
create or replace public synonym DBA_JAVA_DERIVATIONS for DBA_JAVA_DERIVATIONS
/
grant select on DBA_JAVA_DERIVATIONS to select_catalog_role
/

remark
remark FAMILY "JAVA_RESOLVERS"
remark

create or replace view USER_JAVA_RESOLVERS
(NAME, TERM_INDEX, PATTERN, SCHEMA)
as 
select nvl(j.longdbcs, o.name),
       t.joxftresolvertermnumber,
       t.joxftresolvertermpattern,
       t.joxftresolvertermschema
from sys.javasnm$ j, sys.obj$ o, sys.x$joxrsv t
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_RESOLVERS is
'resolver of java class owned by user'
/
comment on column USER_JAVA_RESOLVERS.NAME is 
'name of the java class object'
/
comment on column USER_JAVA_RESOLVERS.TERM_INDEX is 
'index of the resolver term in this row'
/
comment on column USER_JAVA_RESOLVERS.PATTERN is 
'resolver pattern of the resolver term identified by TERM_INDEX column'
/
comment on column USER_JAVA_RESOLVERS.SCHEMA is 
'resolver schema of the resolver term identified by TERM_INDEX column'
/ 
create or replace public synonym USER_JAVA_RESOLVERS for USER_JAVA_RESOLVERS
/
grant select on USER_JAVA_RESOLVERS to public with grant option
/

create or replace view ALL_JAVA_RESOLVERS
(OWNER, NAME, TERM_INDEX, PATTERN, SCHEMA)
as 
select u.name,
       nvl(j.longdbcs, o.name),
       t.joxftresolvertermnumber,
       t.joxftresolvertermpattern,
       t.joxftresolvertermschema
from sys.javasnm$ j, sys.obj$ o, sys.x$joxrsv t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_JAVA_RESOLVERS is
'resolver of java class owned by user'
/
comment on column ALL_JAVA_RESOLVERS.OWNER is 
'owner of the java class object'
/
comment on column ALL_JAVA_RESOLVERS.NAME is 
'name of the java class object'
/
comment on column ALL_JAVA_RESOLVERS.TERM_INDEX is 
'index of the resolver term in this row'
/
comment on column ALL_JAVA_RESOLVERS.PATTERN is 
'resolver pattern of the resolver term identified by TERM_INDEX column'
/
comment on column ALL_JAVA_RESOLVERS.SCHEMA is 
'resolver schema of the resolver term identified by TERM_INDEX column'
/ 
create or replace public synonym ALL_JAVA_RESOLVERS for ALL_JAVA_RESOLVERS
/
grant select on ALL_JAVA_RESOLVERS to public with grant option
/

create or replace view DBA_JAVA_RESOLVERS
(OWNER, NAME, TERM_INDEX, PATTERN, SCHEMA)
as 
select u.name,
       nvl(j.longdbcs, o.name),
       t.joxftresolvertermnumber,
       t.joxftresolvertermpattern,
       t.joxftresolvertermschema
from sys.javasnm$ j, sys.obj$ o, sys.x$joxrsv t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table DBA_JAVA_RESOLVERS is
'resolver of java class owned by user'
/
comment on column DBA_JAVA_RESOLVERS.OWNER is 
'owner of the java class object'
/
comment on column DBA_JAVA_RESOLVERS.NAME is 
'name of the java class object'
/
comment on column DBA_JAVA_RESOLVERS.TERM_INDEX is 
'index of the resolver term in this row'
/
comment on column DBA_JAVA_RESOLVERS.PATTERN is 
'resolver pattern of the resolver term identified by TERM_INDEX column'
/
comment on column DBA_JAVA_RESOLVERS.SCHEMA is 
'resolver schema of the resolver term identified by TERM_INDEX column'
/ 
create or replace public synonym DBA_JAVA_RESOLVERS for DBA_JAVA_RESOLVERS
/
grant select on DBA_JAVA_RESOLVERS to select_catalog_role
/

remark
remark FAMILY "JAVA_NCOMPS"
remark

create or replace view USER_JAVA_NCOMPS
(NAME, SOURCE, INITIALIZER, LIBRARYFILE, LIBRARY)
as 
select /*+ ordered use_nl(o t) */ nvl(j.longdbcs, o.name),
       t.joxftncompsource,
       t.joxftncompinitializer,
       t.joxftncomplibraryfile,
       t.joxftncomplibrary
from sys.javasnm$ j, sys.obj$ o, sys.x$joxobj t
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = userenv('SCHEMAID')
  and j.short(+) = o.name
/
comment on table USER_JAVA_NCOMPS is
'ncomp related information of java classes owned by user'
/
comment on column USER_JAVA_NCOMPS.NAME is 
'name of the java class object'
/
comment on column USER_JAVA_NCOMPS.SOURCE is 
'ncomp source shown in this row'
/
comment on column USER_JAVA_NCOMPS.INITIALIZER is 
'ncomp initializer shown in this row'
/
comment on column USER_JAVA_NCOMPS.LIBRARYFILE is 
'ncomp libraryfile shown in this row'
/ 
comment on column USER_JAVA_NCOMPS.LIBRARY is 
'ncomp library shown in this row'
/ 
create or replace public synonym USER_JAVA_NCOMPS for USER_JAVA_NCOMPS
/
grant select on USER_JAVA_NCOMPS to public with grant option
/

create or replace view ALL_JAVA_NCOMPS
(OWNER, NAME, SOURCE, INITIALIZER, LIBRARYFILE, LIBRARY)
as 
select /*+ ordered use_nl(o t) */
       u.name,
       nvl(j.longdbcs, o.name),
       t.joxftncompsource,
       t.joxftncompinitializer,
       t.joxftncomplibraryfile,
       t.joxftncomplibrary
from sys.javasnm$ j, sys.obj$ o, sys.x$joxobj t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
  and 
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_JAVA_NCOMPS is
'ncomp related information of java classes accessible to user'
/
comment on column ALL_JAVA_NCOMPS.OWNER is 
'owner of the java class object'
/
comment on column ALL_JAVA_NCOMPS.NAME is 
'name of the java class object'
/
comment on column ALL_JAVA_NCOMPS.SOURCE is 
'ncomp source shown in this row'
/
comment on column ALL_JAVA_NCOMPS.INITIALIZER is 
'ncomp initializer shown in this row'
/
comment on column ALL_JAVA_NCOMPS.LIBRARYFILE is 
'ncomp libraryfile shown in this row'
/ 
comment on column ALL_JAVA_NCOMPS.LIBRARY is 
'ncomp library shown in this row'
/ 
create or replace public synonym ALL_JAVA_NCOMPS for ALL_JAVA_NCOMPS
/
grant select on ALL_JAVA_NCOMPS to public with grant option
/

create or replace view DBA_JAVA_NCOMPS
(OWNER, NAME, SOURCE, INITIALIZER, LIBRARYFILE, LIBRARY)
as 
select /*+ ordered use_nl(o t) */
       u.name,
       nvl(j.longdbcs, o.name),
       t.joxftncompsource,
       t.joxftncompinitializer,
       t.joxftncomplibraryfile,
       t.joxftncomplibrary
from sys.javasnm$ j, sys.obj$ o, sys.x$joxobj t, sys.user$ u
where o.obj# = t.joxftobn
  and o.type# = 29
  and o.owner# = u.user#
  and j.short(+) = o.name
/
comment on table ALL_JAVA_NCOMPS is
'ncomp related information of all java classes'
/
comment on column ALL_JAVA_NCOMPS.OWNER is 
'owner of the java class object'
/
comment on column ALL_JAVA_NCOMPS.NAME is 
'name of the java class object'
/
comment on column ALL_JAVA_NCOMPS.SOURCE is 
'ncomp source shown in this row'
/
comment on column ALL_JAVA_NCOMPS.INITIALIZER is 
'ncomp initializer shown in this row'
/
comment on column ALL_JAVA_NCOMPS.LIBRARYFILE is 
'ncomp libraryfile shown in this row'
/ 
comment on column ALL_JAVA_NCOMPS.LIBRARY is 
'ncomp library shown in this row'
/ 
create or replace public synonym DBA_JAVA_NCOMPS for DBA_JAVA_NCOMPS
/
grant select on DBA_JAVA_NCOMPS to select_catalog_role
/




remark
remark FAMILY "JAVA_COMPILER_OPTIONS"
remark

create or replace view USER_JAVA_COMPILER_OPTIONS
(OPTION_NAME, VALUE)
as 
select o.property,
       dbms_java.decode_native_compiler_option(o.property, o.value)
from sys.java$compiler$options o
where o.owner# = userenv('SCHEMAID')
/
comment on table USER_JAVA_COMPILER_OPTIONS is
'native compiler options provided by the user'
/
comment on column USER_JAVA_COMPILER_OPTIONS.OPTION_NAME is 
'name of native-compiler option'
/
comment on column USER_JAVA_COMPILER_OPTIONS.VALUE is
'value of the native-compiler option'
/
create or replace public synonym USER_JAVA_COMPILER_OPTIONS for USER_JAVA_COMPILER_OPTIONS
/
grant select on USER_JAVA_COMPILER_OPTIONS to public with grant option
/

create or replace view ALL_JAVA_COMPILER_OPTIONS
(OWNER, OPTION_NAME, VALUE)
as 
select u.name, o.property,
       dbms_java.decode_native_compiler_option(o.property, o.value)
from sys.user$ u, sys.java$compiler$options o
where o.owner# = u.user#
and o.owner# in (userenv('SCHEMAID'), 0 /* SYS */)
/
comment on table ALL_JAVA_COMPILER_OPTIONS is
'native-compiler options applicable to user'
/
comment on column ALL_JAVA_COMPILER_OPTIONS.OWNER is
'owner of native-compiler option'
/
comment on column ALL_JAVA_COMPILER_OPTIONS.OPTION_NAME is 
'name of the native-compiler option'
/
comment on column ALL_JAVA_COMPILER_OPTIONS.VALUE is
'value of the native-compiler option'
/
create or replace public synonym ALL_JAVA_COMPILER_OPTIONS for ALL_JAVA_COMPILER_OPTIONS
/
grant select on ALL_JAVA_COMPILER_OPTIONS to public with grant option
/

create or replace view DBA_JAVA_COMPILER_OPTIONS
(OWNER, OPTION_NAME, VALUE) 
as 
select u.name, o.property,
       dbms_java.decode_native_compiler_option(o.property, o.value)
from sys.user$ u, sys.java$compiler$options o
where o.owner# = u.user#
/
comment on table DBA_JAVA_COMPILER_OPTIONS is
'all native-compiler options'
/
comment on column DBA_JAVA_COMPILER_OPTIONS.OWNER is 
'owner of the native-compiler option'
/
comment on column DBA_JAVA_COMPILER_OPTIONS.OPTION_NAME is 
'name of the native-compiler option'
/
comment on column DBA_JAVA_COMPILER_OPTIONS.VALUE is
'value of the native-compiler option'
/
create or replace public synonym DBA_JAVA_COMPILER_OPTIONS for DBA_JAVA_COMPILER_OPTIONS
/
grant select on DBA_JAVA_COMPILER_OPTIONS to select_catalog_role
/

