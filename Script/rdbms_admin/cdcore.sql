Rem
Rem $Header: rdbms/admin/cdcore.sql /st_rdbms_11.2.0/8 2013/07/07 09:03:20 mjungerm Exp $
Rem
Rem cdcore.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdcore.sql - Catalog DCORE.bsq views
Rem
Rem    DESCRIPTION
Rem      core objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dcore.bsq.
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ankrajes    09/07/12 - Backport hjhala_bug-12913317 from
Rem    jmadduku    05/05/11 - Backport jmadduku_bug-12327898 from main
Rem    sfeinste    02/24/11 - Backport sfeinste_bug-11791349 from main
Rem    sanagara    02/08/11 - Backport sanagara_bug-9935857 from main
Rem    rkagarwa    11/17/10 - Backport rkagarwa_bug-10048645 from main
Rem    aamor       11/07/10 - Backport 9371529: move joins out of
Rem                           _all_synonyms_tree
Rem    sursridh    05/21/10 - Bug 8937971: Return freelists, freelist_groups
Rem                           correctly for deferred case.
Rem    achoi       05/12/10 - bug 9543463
Rem    ruparame    03/15/10 - Bug 9192924 Add SYS_OP_DV_CHECK to sensitive columns
Rem    gkulkarn    10/06/09 - Include ID KEY LOG Groups in *_LOG_GROUPS views
Rem    nlee        08/04/09 - Fix for bug 8534445.
Rem    jklebane    07/14/09 - 8560951: remove NO_EXPAND hint from ALL_OBJECTS
Rem    rmacnico    06/11/09 - ARCHIVE LOW/HIGH
Rem    rmacnico    04/14/09 - Bug 8360974: dba_tables and AdvCmp
Rem    bvaranas    04/27/09 - Remove redundant query to access deferred_stg$
Rem    rramkiss    04/14/09 - fill in missing object type names
Rem    adalee      03/06/09 - new cachehint
Rem    bvaranas    03/03/09 - Fix storage parameters in views for deferred
Rem                           segment creation
Rem    rbhatti     02/10/09 - Fix bug 7635949; correct definition of view
Rem                           USER_ROLE_PRIVS (do not show pasword-protected
Rem                           roles as DEFAULT_ROLE)
Rem    krajaman    11/30/09 - Fix bug#7122614, add nocycle to all_synonyms_tree
Rem    bvaranas    12/11/08 - Fix segment_created for partitioned objects
Rem    pyoun       08/27/08 - fix comments for encrypted_columns
Rem    mcusson     08/13/08 - Do not include supplemental logging related
Rem                           constraints in dba_constraints
Rem    achoi       07/18/08 - fix bug6672949
Rem    slynn       08/14/08 - 
Rem    pyoun       05/05/08 - bug 7002207
Rem    slynn       04/16/08 - Add New Retention Column to *_LOBS.
Rem    mbastawa    04/16/08 - add result_cache column
Rem    sursridh    03/28/08 - Deferred Segment Creation bug fix.  Correct
Rem                           COMPRESSION, COMPRESS_FOR in *_tables views.
Rem    weizhang    03/13/08 - storage clause INITIAL/NEXT for ASSM segment
Rem    bvaranas    02/04/08 - Proj 25274: Deferred Segment Creation. Add
Rem                           segment_created to _tables, _indexes, _lobs
Rem    cvenezia    09/25/07 - add OLAP types 92-95 to ALL_OBJECTS (bug 6311970)
Rem    kquinn      07/27/07 - 2883037: extend constraint_type
Rem    achoi       04/26/07 - defining_edition instead of defining_edition_id
Rem    vmarwah     05/23/07 - Add COMPRESS_FOR in *_TABLES views
Rem    achoi       05/14/07 - improve all_synonyms
Rem    achoi       04/26/07 - defining_edition instead of defining_edition_id
Rem    sfeinste    04/03/07 - Add OLAP types to *_OBJECTS view decodes
Rem    vakrishn    01/04/07 - move Flashback Archive views to cdtxnspc.sql
Rem    ramekuma    03/20/07 - bug-5931139: remove extra spacing in defintion of
Rem                           'INVISIBLE' in index views VISIBILITY column
Rem    achoi       02/02/07 - fix undefined object in _AE views
Rem    slynn       11/20/06 - 
Rem    achoi       11/07/06 - obj$.spare3 stores base user#
Rem    rramkiss    01/08/07 - b5736514, add credential to *_OBJECTS_AE
Rem    rpang       01/02/07 - 5725761: show objs with debug priv in all_objects
Rem    kquinn      11/13/06 - 5550536: *_objects now hides recyclebin objects
Rem    rburns      11/06/06 - add view for invalid objects
Rem    slynn       10/12/06 - smartfile->securefile
Rem    schakkap    10/20/06 - move v$object_usage to cdmanege.sql
Rem    achoi       08/09/06 - add *_VIEWS_AE and *_EDITIONING_VIEWS_AE
Rem    achoi       07/21/06 - add read-only column for *_views family
Rem    achoi       06/26/06 - fix bug 5508217
Rem    jforsyth    09/13/06 - fix lob views
Rem    gviswana    09/29/06 - CURRENT_EDITION -> CURRENT_EDITION_NAME
Rem    vakrishn    09/29/06 - Flashback Archive Views
Rem    akruglik    09/01/06 - replace CMV$ with EV$, CMVCOL$ with EVCOL$ +
Rem                           rename a few columns and get rid of a few;
Rem                           rename *_COLUMN_MAP_VIEWS to *_EDITIONING_VIEWS
REM                           rename *_COLUMN_MAP_COLUMNS to 
REM                           *_EDITIONING_VIEW_COLUMNS
Rem    slynn       07/31/06 - change csce keywords.
Rem    gviswana    07/16/06 - Editions: non-versionable users 
Rem    rlathia     06/20/06 - bug5304489 Add check for KQDOBRBO in USER_LOBS 
Rem                           definition 
Rem    achoi       06/30/06 - fix performance on _CURRENT_EDITION_OBJ 
Rem    achoi       06/07/06 - stub obj# is 88 
Rem    pstengar    05/18/06 - update system priv numbers for mining models
Rem    jforsyth    06/06/06 - CSCE columns in lob views empty for NOLOCAL 
Rem    rramkiss    05/17/06 - all credential Scheduler object 
Rem    akruglik    05/31/06 - replace references to obj$ with 
Rem                           _CURRENT_EDITION_OBJ in EDITIONING_VIEWS and 
Rem                           EDITIONING_VIEW_COLUMNS views 
Rem    akruglik    05/30/06 - change EDITIONING_VIEWS views to return names, 
Rem                           rather than ids, of EVs and their base tables 
Rem    weizhang    05/17/06 - proj 19400: GTT tablespace option 
Rem    akruglik    05/26/06 - move EV-related comments from catalog.sql 
Rem    akruglik   05/04/06  - in definitions of EDITIONING_VIEWS add 
Rem                           restriction on type# when joining EV$ to OBJ$ 
Rem                           on base table schema id and name to avoid 
Rem                           returning multiple rows for EV defined on 
Rem                           partitioned tables 
Rem    akruglik   05/02/06  - remove EDITIONING_FREEZE_SCN column from 
Rem                           _EDITIONING_VIEWS views 
Rem    akruglik   04/29/06  - replace ev$.base_tbl_obj# with base_tbl_owner# 
Rem                           and base_tbl_name to make life simple for 
Rem                           online redef 
Rem    akruglik   04/07/06  - Add <user/all/dba>_EDITIONING_VIEWS and 
Rem                           <user/all/dba>_EDITIONING_VIEW_COLUMNS views 
Rem                           and add a EDITIONING_VIEW column to 
Rem                           <user/all/dba>_VIEWS 
Rem    akruglik    05/18/06 - move Editioning View-related changes from 
Rem                           catalog.sql 
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

remark
remark FAMILY "EDITION OBJ" - Objects annotated with edition information
remark These views are for internal use only.
remark
remark "_CURRENT_EDITION_OBJ" describes all objects visible in the current
remark edition. Starting with release 11 of the Oracle DB, any views exposing
remark metadata for versionable objects (package, function, procedure, object
remark type, view, synonym, library, trigger and assembly) must use this view
remark instead of obj$.
remark
remark "_ACTUAL_EDITION_OBJ" describes all actual objects (not stubs) in all
remark editions. Use this view instead of obj$ to describe all versions of
remark a versionable object.
remark
remark In both views, the owner# in is the base user# (not the adjunt schema).
remark
remark "_BASE_USER" describes all users (base and adjunt) in user$. This view will
remark always show the base username if it is an adjunt schema. If the view is
remark joining (user$, obj$) directly and the join is producing versionable
remark object rows, then use this view instead of user$.
remark 

create or replace view "_CURRENT_EDITION_OBJ"
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      owner#,
      defining_edition
 )
as
select o.*,
       o.spare3, 
       case when (o.type# not in (4,5,7,8,9,10,11,12,13,14,22,87) or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select eo.name from obj$ eo where eo.obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and (   /* non-versionable object */
          (   o.type# not in (4,5,7,8,9,10,11,12,13,14,22,87,88)
           or bitand(u.spare1, 16) = 0)
          /* versionable object visible in current edition */
       or (    o.type# in (4,5,7,8,9,10,11,12,13,14,22,87)
           and (   (u.type# <> 2 and 
                    sys_context('userenv', 'current_edition_name') = 'ORA$BASE')
                or (u.type# = 2 and
                    u.spare2 = sys_context('userenv', 'current_edition_id'))
                or exists (select 1 from obj$ o2, user$ u2
                           where o2.type# = 88
                             and o2.dataobj# = o.obj#
                             and o2.owner# = u2.user#
                             and u2.type#  = 2
                             and u2.spare2 = 
                                  sys_context('userenv', 'current_edition_id'))
               )
          )
      )
/

remark
remark all real objects in all the editions
remark
create or replace view "_ACTUAL_EDITION_OBJ"
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      owner#,
      defining_edition
 )
as
select o.*,
       o.spare3, 
       case when (o.type# not in (4,5,7,8,9,10,11,12,13,14,22,87) or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select name from obj$ where obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and o.type# != 88
/

remark
remark Always shows base user name
remark
create or replace view "_BASE_USER"
  (USER#,
   TYPE#,
   DATATS#,
   TEMPTS#,
   CTIME,
   PTIME,
   EXPTIME,
   LTIME,
   RESOURCE$,
   AUDIT$,
   DEFROLE,
   DEFGRP#,
   DEFGRP_SEQ#,
   ASTATUS,
   LCOUNT,
   DEFSCHCLASS,
   EXT_USERNAME,
   SPARE1,
   SPARE2,
   SPARE6,
   NAME
  )
as
select USER#,TYPE#,DATATS#,TEMPTS#,CTIME,PTIME,EXPTIME,LTIME,
       RESOURCE$,AUDIT$,DEFROLE,DEFGRP#,DEFGRP_SEQ#,ASTATUS,
       LCOUNT,DEFSCHCLASS,EXT_USERNAME,SPARE1,SPARE2,SPARE6,
       decode(u.type#, 2, substr(u.ext_username, 0, 30), u.name)
from sys.user$ u
/



remark
remark  FAMILY "CONS_COLUMNS"
remark
create or replace view USER_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column USER_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column USER_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column USER_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column USER_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant select on USER_CONS_COLUMNS to public with grant option
/
create or replace public synonym USER_CONS_COLUMNS for USER_CONS_COLUMNS
/
create or replace view ALL_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column ALL_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column ALL_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column ALL_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column ALL_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant select on ALL_CONS_COLUMNS to public with grant option
/
create or replace public synonym ALL_CONS_COLUMNS for ALL_CONS_COLUMNS
/
create or replace view DBA_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CONS_COLUMNS for DBA_CONS_COLUMNS
/
grant select on DBA_CONS_COLUMNS to select_catalog_role
/
comment on table DBA_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column DBA_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column DBA_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column DBA_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column DBA_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/

remark
remark  FAMILY "LOG_GROUP_COLUMNS"
remark
create or replace view USER_LOG_GROUP_COLUMNS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column USER_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/
grant select on USER_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym USER_LOG_GROUP_COLUMNS
   for USER_LOG_GROUP_COLUMNS
/
create or replace view ALL_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column ALL_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/

grant select on ALL_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym ALL_LOG_GROUP_COLUMNS
   for ALL_LOG_GROUP_COLUMNS
/
create or replace view DBA_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_LOG_GROUP_COLUMNS
   for DBA_LOG_GROUP_COLUMNS
/
grant select on DBA_LOG_GROUP_COLUMNS to select_catalog_role
/
comment on table DBA_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column DBA_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/


rem
rem V5 views required for other Oracle products
rem

create or replace view syscatalog_
    (tname, creator, creatorid, tabletype, remarks)
  as
  select o.name, u.name, o.owner#,
         decode(o.type#, 2, 'TABLE', 4, 'VIEW', 6, 'SEQUENCE','?'), c.comment$
  from  sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.com$ c
  where u.user# = o.owner#
  and (o.type# in (4, 6)                                    /* view, sequence */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
    and o.linkname is null
    and o.obj# = c.obj#(+)
    and ( o.owner# = userenv('SCHEMAID')
          or o.obj# in
             (select oa.obj#
              from   sys.objauth$ oa
              where  oa.grantee# in (userenv('SCHEMAID'), 1)
              )
          or
          (
            (o.type# in (4)                                           /* view */
             or
             (o.type# = 2 /* tables, excluding iot-overflow and nested tables */
              and
              not exists (select null
                            from sys.tab$ t
                           where t.obj# = o.obj#
                             and (bitand(t.property, 512) = 512 or
                                  bitand(t.property, 8192) = 8192))))
          and
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
           )
          or
         ( o.type# = 6 /* sequence */
           and
           exists (select null from v$enabledprivs
                   where priv_number = -109 /* SELECT ANY SEQUENCE */)
         )
       )
/
grant select on syscatalog_ to select_catalog_role
/
create or replace view syscatalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from syscatalog_
/
grant select on syscatalog to public with grant option;
create or replace synonym system.syscatalog for syscatalog;
rem
rem The catalog view returns almost all tables accessible to the user
rem except tables in SYS and SYSTEM ("dictionary tables").
rem
create or replace view catalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from  syscatalog_
  where creatorid not in (select user# from sys.user$ where name in
        ('SYS','SYSTEM'))
/
grant select on catalog to public with grant option;
create or replace synonym system.catalog for catalog;

create or replace view tab (tname, tabtype, clusterid) as
   select o.name,
      decode(o.type#, 2, 'TABLE', 3, 'CLUSTER',
             4, 'VIEW', 5, 'SYNONYM'), t.tab#
  from  sys.tab$ t, sys."_CURRENT_EDITION_OBJ" o
  where o.owner# = userenv('SCHEMAID')
  and o.type# >=2
  and o.type# <=5
  and o.linkname is null
  and o.obj# = t.obj# (+)
/
grant select on tab to public with grant option;
create or replace synonym system.tab for tab;
create or replace public synonym tab for tab;
create or replace view col
  (tname, colno, cname, coltype, width, scale, precision, nulls, defaultval,
   character_set_name) as
  select t.name, c.col#, c.name,
         decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                         2, decode(c.scale, null,
                                   decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                  'NUMBER'),
                         8, 'LONG',
                         9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                         12, 'DATE',
                         23, 'RAW', 24, 'LONG RAW',
                         69, 'ROWID',
                         96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                         100, 'BINARY_FLOAT',
                         101, 'BINARY_DOUBLE',
                         105, 'MLSLABEL',
                         106, 'MLSLABEL',
                         111, 'REF '||'"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                         113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                         121, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         122, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         123, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         178, 'TIME(' ||c.scale|| ')',
                         179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                         180, 'TIMESTAMP(' ||c.scale|| ')',
                         181, 'TIMESTAMP(' ||c.scale|| ')'||' WITH TIME ZONE',
                         231, 'TIMESTAMP(' ||c.scale|| ')'||' WITH LOCAL TIME ZONE',
                         182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                         183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                               c.scale || ')',
                         208, 'UROWID',
                         'UNDEFINED'),
         c.length, c.scale, c.precision#,
         decode(sign(c.null$),-1,'NOT NULL - DISABLED', 0, 'NULL',
        'NOT NULL'), c.default$,
         decode(c.charsetform, 1, 'CHAR_CS',
                               2, 'NCHAR_CS',
                               3, NLS_CHARSET_NAME(c.charsetid),
                               4, 'ARG:'||c.charsetid)
  from  sys.col$ c, sys."_CURRENT_EDITION_OBJ" t, sys.coltype$ ac,
        sys.obj$ ot, sys."_BASE_USER" ut
  where t.obj# = c.obj#
  and   t.type# in (2, 3, 4)
  and   t.owner# = userenv('SCHEMAID')
  and   bitand(c.property, 32) = 0 /* not hidden column */
  and   c.obj# = ac.obj#(+)
  and   c.intcol# = ac.intcol#(+)
  and   ac.toid = ot.oid$(+)
  and   ot.owner# = ut.user#(+)
/
grant select on col to public with grant option;
create or replace synonym system.col for col;
create or replace public synonym col for col;

rem
rem V5 views required for other Oracle products
rem

create or replace view syscatalog_
    (tname, creator, creatorid, tabletype, remarks)
  as
  select o.name, u.name, o.owner#,
         decode(o.type#, 2, 'TABLE', 4, 'VIEW', 6, 'SEQUENCE','?'), c.comment$
  from  sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.com$ c
  where u.user# = o.owner#
  and (o.type# in (4, 6)                                    /* view, sequence */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
    and o.linkname is null
    and o.obj# = c.obj#(+)
    and ( o.owner# = userenv('SCHEMAID')
          or o.obj# in
             (select oa.obj#
              from   sys.objauth$ oa
              where  oa.grantee# in (userenv('SCHEMAID'), 1)
              )
          or
          (
            (o.type# in (4)                                           /* view */
             or
             (o.type# = 2 /* tables, excluding iot-overflow and nested tables */
              and
              not exists (select null
                            from sys.tab$ t
                           where t.obj# = o.obj#
                             and (bitand(t.property, 512) = 512 or
                                  bitand(t.property, 8192) = 8192))))
          and
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
           )
          or
         ( o.type# = 6 /* sequence */
           and
           exists (select null from v$enabledprivs
                   where priv_number = -109 /* SELECT ANY SEQUENCE */)
         )
       )
/
grant select on syscatalog_ to select_catalog_role
/
create or replace view syscatalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from syscatalog_
/
grant select on syscatalog to public with grant option;
create or replace synonym system.syscatalog for syscatalog;
rem
rem The catalog view returns almost all tables accessible to the user
rem except tables in SYS and SYSTEM ("dictionary tables").
rem
create or replace view catalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from  syscatalog_
  where creatorid not in (select user# from sys.user$ where name in
        ('SYS','SYSTEM'))
/
grant select on catalog to public with grant option;
create or replace synonym system.catalog for catalog;

create or replace view tab (tname, tabtype, clusterid) as
   select o.name,
      decode(o.type#, 2, 'TABLE', 3, 'CLUSTER',
             4, 'VIEW', 5, 'SYNONYM'), t.tab#
  from  sys.tab$ t, sys."_CURRENT_EDITION_OBJ" o
  where o.owner# = userenv('SCHEMAID')
  and o.type# >=2
  and o.type# <=5
  and o.linkname is null
  and o.obj# = t.obj# (+)
/
grant select on tab to public with grant option;
create or replace synonym system.tab for tab;
create or replace public synonym tab for tab;
create or replace view col
  (tname, colno, cname, coltype, width, scale, precision, nulls, defaultval,
   character_set_name) as
  select t.name, c.col#, c.name,
         decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                         2, decode(c.scale, null,
                                   decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                  'NUMBER'),
                         8, 'LONG',
                         9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                         12, 'DATE',
                         23, 'RAW', 24, 'LONG RAW',
                         69, 'ROWID',
                         96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                         100, 'BINARY_FLOAT',
                         101, 'BINARY_DOUBLE',
                         105, 'MLSLABEL',
                         106, 'MLSLABEL',
                         111, 'REF '||'"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                         113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                         121, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         122, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         123, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         178, 'TIME(' ||c.scale|| ')',
                         179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                         180, 'TIMESTAMP(' ||c.scale|| ')',
                         181, 'TIMESTAMP(' ||c.scale|| ')'||' WITH TIME ZONE',
                         231, 'TIMESTAMP(' ||c.scale|| ')'||' WITH LOCAL TIME ZONE',
                         182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                         183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                               c.scale || ')',
                         208, 'UROWID',
                         'UNDEFINED'),
         c.length, c.scale, c.precision#,
         decode(sign(c.null$),-1,'NOT NULL - DISABLED', 0, 'NULL',
        'NOT NULL'), c.default$,
         decode(c.charsetform, 1, 'CHAR_CS',
                               2, 'NCHAR_CS',
                               3, NLS_CHARSET_NAME(c.charsetid),
                               4, 'ARG:'||c.charsetid)
  from  sys.col$ c, sys."_CURRENT_EDITION_OBJ" t, sys.coltype$ ac,
        sys.obj$ ot, sys."_BASE_USER" ut
  where t.obj# = c.obj#
  and   t.type# in (2, 3, 4)
  and   t.owner# = userenv('SCHEMAID')
  and   bitand(c.property, 32) = 0 /* not hidden column */
  and   c.obj# = ac.obj#(+)
  and   c.intcol# = ac.intcol#(+)
  and   ac.toid = ot.oid$(+)
  and   ot.owner# = ut.user#(+)
/
grant select on col to public with grant option;
create or replace synonym system.col for col;
create or replace public synonym col for col;


create or replace view syssegobj
    (obj#, file#, block#, type, pctfree$, pctused$) as
  select obj#,
       decode(bitand(property, 32+64), 0, file#, to_number(null)),
       decode(bitand(property, 32+64), 0, block#, to_number(null)),
       'TABLE',
       decode(bitand(property, 32+64), 0, mod(pctfree$, 100), to_number(null)),
       decode(bitand(property, 32+64), 0, pctused$, to_number(null))
  from sys.tab$
  union all
  select obj#, file#, block#, 'CLUSTER', pctfree$, pctused$ from sys.clu$
  union all
  select obj#, file#, block#, 'INDEX', to_number(null), to_number(null)
         from sys.ind$
/
grant select on syssegobj to public with grant option;
create or replace view tabquotas (tname, type, objno, nextext, maxext, pinc,
                       pfree, pused) as
  select t.name, so.type, t.obj#,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                s.extsize * ts.blocksize),
  s.maxexts,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
  so.pctfree$, decode(bitand(ts.flags, 32), 32, to_number(NULL), so.pctused$)
  from  sys.ts$ ts, sys.seg$ s, sys.obj$ t, syssegobj so
  where t.owner# = userenv('SCHEMAID')
  and   t.obj# = so.obj#
  and   so.file# = s.file#
  and   so.block# = s.block#
  and   s.ts# = ts.ts#
/
grant select on tabquotas to public with grant option;
create or replace synonym system.tabquotas for tabquotas;

rem ### do we need to fix this for bitmapped tablespaces
create or replace view sysfiles (tsname, fname, blocks) as
  select ts.name, dbf.name, f.blocks
  from  sys.ts$ ts, sys.file$ f, sys.v$dbfile dbf
  where ts.ts# = f.ts#(+) and dbf.file# = f.file# and f.status$ = 2
/
grant select on sysfiles to public with grant option;
create or replace synonym system.sysfiles for sysfiles;
create or replace view synonyms
    (sname, syntype, creator, tname, database, tabtype) as
  select s.name,
         decode(s.owner#,1,'PUBLIC','PRIVATE'), t.owner, t.name, 'LOCAL',
         decode(ot.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER', 4, 'VIEW',
                         5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                         8, 'FUNCTION', 9, 'PACKAGE', 22, 'LIBRARY',
                         29, 'JAVA CLASS', 87, 'ASSEMBLY', 'UNDEFINED')
  from  sys."_CURRENT_EDITION_OBJ" s, sys."_CURRENT_EDITION_OBJ" ot, 
        sys.syn$ t, sys.user$ u
  where s.obj# = t.obj#
    and ot.linkname is null
    and s.type# = 5
    and ot.name = t.name
    and t.owner = u.name
    and ot.owner# = u.user#
    and s.owner# in (1,userenv('SCHEMAID'))
    and t.node is null
union all
  select s.name, decode(s.owner#, 1, 'PUBLIC', 'PRIVATE'),
         t.owner, t.name, t.node, 'REMOTE'
  from  sys."_CURRENT_EDITION_OBJ" s, sys.syn$ t
  where s.obj# = t.obj#
    and s.type# = 5
    and s.owner# in (1, userenv('SCHEMAID'))
    and t.node is not null
/
grant select on synonyms to public with grant option;
create or replace view publicsyn (sname, creator, tname, database, tabtype) as
  select sname, creator, tname, database, tabtype
  from  synonyms
  where syntype = 'PUBLIC'
/
grant select on publicsyn to public with grant option;
create or replace synonym system.publicsyn for publicsyn;


rem
rem V6 views required for other Oracle products
rem

create or replace view TABLE_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR,
       SELECT_PRIV, INSERT_PRIV, DELETE_PRIV,
       UPDATE_PRIV, REFERENCES_PRIV, ALTER_PRIV, INDEX_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 7, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
     decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
       decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
              13, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 6, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 19, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             5, 2),'01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 10, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             3, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 11, 1, 0))), 0, 'N', 'S')),
   decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 25, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 15, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur, sys.user$ u
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, ur.name, ue.name
/
comment on table TABLE_PRIVILEGES is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column TABLE_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column TABLE_PRIVILEGES.OWNER is
'Owner of the object'
/
comment on column TABLE_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column TABLE_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column TABLE_PRIVILEGES.SELECT_PRIV is
'Permission to SELECT from the object?'
/
comment on column TABLE_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the object?'
/
comment on column TABLE_PRIVILEGES.DELETE_PRIV is
'Permission to DELETE from the object?'
/
comment on column TABLE_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the object?'
/
comment on column TABLE_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the object?'
/
comment on column TABLE_PRIVILEGES.ALTER_PRIV is
'Permission to ALTER the object?'
/
comment on column TABLE_PRIVILEGES.INDEX_PRIV is
'Permission to create/drop an INDEX on the object?'
/
comment on column TABLE_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym TABLE_PRIVILEGES for TABLE_PRIVILEGES
/
grant select on TABLE_PRIVILEGES to PUBLIC
/
create or replace view COLUMN_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR,
       INSERT_PRIV, UPDATE_PRIV, REFERENCES_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, c.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 13, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 5, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 3, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys.col$ c,sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue,
     sys.user$ ur, sys.user$ u
where oa.col# is not null
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, c.name, ur.name, ue.name
/
comment on table COLUMN_PRIVILEGES is
'Grants on columns for which the user is the grantor, grantee, owner, or
 an enabled role or PUBLIC is the grantee'
/
comment on column COLUMN_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column COLUMN_PRIVILEGES.OWNER is
'Username of the owner of the object'
/
comment on column COLUMN_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column COLUMN_PRIVILEGES.COLUMN_NAME is
'Name of the column'
/
comment on column COLUMN_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column COLUMN_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the column?'
/
comment on column COLUMN_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the column?'
/
comment on column COLUMN_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the column?'
/
comment on column COLUMN_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym COLUMN_PRIVILEGES for COLUMN_PRIVILEGES
/
grant select on COLUMN_PRIVILEGES to PUBLIC
/

remark
remark  FAMILY "LOBS"
remark
remark  Views for showing information about LOBs:
remark  USER_LOBS, ALL_LOBS, and DBA_LOBS
remark
create or replace view USER_LOBS
    (TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE,
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       decode(bitand(l.property, 8),
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES', 512,
                                    'YES', 'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 'YES',
                                   'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.lob$ l, sys.obj$ lo,
     sys.obj$ io, sys.ts$ ts, sys.tab$ ta, sys.user$ ut, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and o.owner# = ut.user#
  and ut.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(plob.defflags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(plob.defflags, 32), 32, 
              decode(bitand(plob.defpro, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                          512, 'YES', 'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO', 512, 'YES',
                                         'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table USER_LOBS is
'Description of the user''s own LOBs contained in the user''s own tables'
/
comment on column USER_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column USER_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column USER_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column USER_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column USER_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column USER_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column USER_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column USER_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column USER_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column USER_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column USER_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column USER_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column USER_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column USER_LOBS.DEDUPLICATION is
'What kind of DEDUPLICATION is used for this lob?'
/
comment on column USER_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column USER_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column USER_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column USER_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column USER_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
comment on column USER_LOBS.RETENTION_TYPE is
'What kind of retention is inuse?'
/
comment on column USER_LOBS.RETENTION_VALUE is
'What is the retention value?'
/
create or replace public synonym USER_LOBS for USER_LOBS
/
grant select on USER_LOBS to PUBLIC with grant option
/
create or replace view ALL_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE,
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES', 512, 'YES',
                                    'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 'YES',
                                    'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768, 
              'HIGH',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO', 
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32    /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(plob.defflags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(plob.defflags, 32), 32, 
              decode(bitand(plob.defpro, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                         512, 'YES', 'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO', 512, 'YES', 
                                        'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO', 'YES'),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u, sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32         /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table ALL_LOBS is
'Description of LOBs contained in tables accessible to the user'
/
comment on column ALL_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column ALL_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column ALL_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column ALL_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column ALL_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column ALL_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column ALL_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column ALL_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column ALL_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column ALL_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column ALL_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column ALL_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column ALL_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column ALL_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column ALL_LOBS.DEDUPLICATION is
'What kind of deduplication is used for this lob?'
/
comment on column ALL_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column ALL_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column ALL_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column ALL_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column ALL_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
create or replace public synonym ALL_LOBS for ALL_LOBS
/
grant select on ALL_LOBS to PUBLIC with grant option
/
create or replace view DBA_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE, 
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES',
                                   512, 'YES', 'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 
                                       'YES', 'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768, 
              'HIGH',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(l.flags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, l.retention, to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                         512, 'YES',  'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO',
                                        512, 'YES', 'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u, sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table DBA_LOBS is
'Description of LOBs contained in all tables'
/
comment on column DBA_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column DBA_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column DBA_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column DBA_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column DBA_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column DBA_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column DBA_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column DBA_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column DBA_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column DBA_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column DBA_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column DBA_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column DBA_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column DBA_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column DBA_LOBS.DEDUPLICATION is
'What kind of deduplication is used for this lob?'
/
comment on column DBA_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column DBA_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column DBA_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column DBA_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column DBA_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
create or replace public synonym DBA_LOBS for DBA_LOBS
/
grant select on DBA_LOBS to select_catalog_role
/

remark
remark  FAMILY "CATALOG"
remark  Objects which may be used as tables in SQL statements:
remark  Tables, Views, Synonyms.
remark

create or replace view USER_CATALOG
    (TABLE_NAME,
     TABLE_TYPE)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys."_CURRENT_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
/
comment on table USER_CATALOG is
'Tables, Views, Synonyms and Sequences owned by the user'
/
comment on column USER_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column USER_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym USER_CATALOG for USER_CATALOG
/
create or replace public synonym CAT for USER_CATALOG
/
grant select on USER_CATALOG to PUBLIC with grant option
/
remark
remark  This view shows all tables, views, synonyms, and sequences owned by the
remark  user and those tables, views, synonyms, and sequences that PUBLIC
remark  has been granted access.
remark
create or replace view ALL_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o
where o.owner# = u.user#
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
  and (o.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
       or
       obj# in ( select obj#  /* directly granted privileges */
                 from sys.objauth$
                 where grantee# in ( select kzsrorol
                                      from x$kzsro
                                    )
                )
       or
       (
          o.type# in (2, 4, 5) /* table, view, synonym */
          and
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */))
       )
       or
       ( o.type# = 6 /* sequence */
         and
         exists (select null from v$enabledprivs
                 where priv_number = -109 /* SELECT ANY SEQUENCE */)))
/
comment on table ALL_CATALOG is
'All tables, views, synonyms, sequences accessible to the user'
/
comment on column ALL_CATALOG.OWNER is
'Owner of the object'
/
comment on column ALL_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column ALL_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym ALL_CATALOG for ALL_CATALOG
/
grant select on ALL_CATALOG to PUBLIC with grant option
/
create or replace view DBA_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o
where o.owner# = u.user#
  and o.linkname is null
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
create or replace public synonym DBA_CATALOG for DBA_CATALOG
/
grant select on DBA_CATALOG to select_catalog_role
/
comment on table DBA_CATALOG is
'All database Tables, Views, Synonyms, Sequences'
/
comment on column DBA_CATALOG.OWNER is
'Owner of the object'
/
comment on column DBA_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column DBA_CATALOG.TABLE_TYPE is
'Type of the object'
/
remark
remark  FAMILY "CLUSTERS"
remark  CREATE CLUSTER parameters.
remark
create or replace view USER_CLUSTERS
    (CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
             decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
             decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
          decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.ts# = ts.ts#
  and c.ts# = s.ts#
  and c.file# = s.file#
  and c.block# = s.block#
/
comment on table USER_CLUSTERS is
'Descriptions of user''s own clusters'
/
comment on column USER_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column USER_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column USER_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column USER_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column USER_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column USER_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column USER_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column USER_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column USER_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column USER_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column USER_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column USER_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column USER_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column USER_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column USER_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
create or replace public synonym USER_CLUSTERS for USER_CLUSTERS
/
create or replace public synonym CLU for USER_CLUSTERS
/
grant select on USER_CLUSTERS to PUBLIC with grant option
/
create or replace view ALL_CLUSTERS
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select u.name, o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
           decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
           decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
          decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj#   = c.obj#
  and c.ts#    = ts.ts#
  and c.ts#    = s.ts#
  and c.file#  = s.file#
  and c.block# = s.block#
  and (o.owner# = userenv('SCHEMAID')
       or  /* user has system privilages */
         exists (select null from v$enabledprivs
                 where priv_number in (-61 /* CREATE ANY CLUSTER */,
                                       -62 /* ALTER ANY CLUSTER */,
                                       -63 /* DROP ANY CLUSTER */ )
                )
      )
/
create or replace public synonym ALL_CLUSTERS for ALL_CLUSTERS
/
grant select on ALL_CLUSTERS to PUBLIC with grant option
/
comment on table ALL_CLUSTERS is
'Description of clusters accessible to the user'
/
comment on column ALL_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column ALL_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column ALL_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column ALL_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column ALL_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column ALL_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column ALL_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column ALL_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column ALL_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column ALL_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column ALL_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column ALL_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column ALL_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
create or replace view DBA_CLUSTERS
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL,  FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select u.name, o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
          decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.ts# = ts.ts#
  and c.ts# = s.ts#
  and c.file# = s.file#
  and c.block# = s.block#
/
create or replace public synonym DBA_CLUSTERS for DBA_CLUSTERS
/
grant select on DBA_CLUSTERS to select_catalog_role
/
comment on table DBA_CLUSTERS is
'Description of all clusters in the database'
/
comment on column DBA_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column DBA_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column DBA_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column DBA_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column DBA_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column DBA_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column DBA_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column DBA_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column DBA_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column DBA_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column DBA_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column DBA_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/

remark
remark  FAMILY "CLU_COLUMNS"
remark  Mapping of cluster columns to table columns.
remark  This family has no ALL member.
remark
create or replace view USER_CLU_COLUMNS
    (CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc, sys.tab$ t,
     sys.attrcol$ ac
where oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and oc.owner#  = userenv('SCHEMAID')
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
comment on table USER_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column USER_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column USER_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column USER_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column USER_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/
create or replace public synonym USER_CLU_COLUMNS for USER_CLU_COLUMNS
/
grant select on USER_CLU_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_CLU_COLUMNS
    (OWNER, CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select u.name, oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.user$ u, sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc,
     sys.tab$ t, sys.attrcol$ ac
where oc.owner#  = u.user#
  and oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CLU_COLUMNS for DBA_CLU_COLUMNS
/
grant select on DBA_CLU_COLUMNS to select_catalog_role
/
comment on table DBA_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column DBA_CLU_COLUMNS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column DBA_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column DBA_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column DBA_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/

remark
remark  FAMILY "COL_COMMENTS"
remark  Comments on columns of tables and views.
remark
create or replace view USER_COL_COMMENTS
    (TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select o.name, c.name, co.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.com$ co
where o.owner# = userenv('SCHEMAID')
  and o.type# in (2, 4)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table USER_COL_COMMENTS is
'Comments on columns of user''s tables and views'
/
comment on column USER_COL_COMMENTS.TABLE_NAME is
'Object name'
/
comment on column USER_COL_COMMENTS.COLUMN_NAME is
'Column name'
/
comment on column USER_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
create or replace public synonym USER_COL_COMMENTS for USER_COL_COMMENTS
/
grant select on USER_COL_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select u.name, o.name, c.name, co.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.user$ u, sys.com$ co
where o.owner# = u.user#
  and o.type# in (2, 4, 5)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
         (select obj#
          from sys.objauth$
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
          )
       or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */))
      )
/
comment on table ALL_COL_COMMENTS is
'Comments on columns of accessible tables and views'
/
comment on column ALL_COL_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
create or replace public synonym ALL_COL_COMMENTS for ALL_COL_COMMENTS
/
grant select on ALL_COL_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select u.name, o.name, c.name, co.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.user$ u, sys.com$ co
where o.owner# = u.user#
  and o.type# in (2, 4)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
/
create or replace public synonym DBA_COL_COMMENTS for DBA_COL_COMMENTS
/
grant select on DBA_COL_COMMENTS to select_catalog_role
/
comment on table DBA_COL_COMMENTS is
'Comments on columns of all tables and views'
/
comment on column DBA_COL_COMMENTS.OWNER is
'Name of the owner of the object'
/
comment on column DBA_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_COMMENTS.COMMENTS is
'Comment on the object'
/
remark
remark  FAMILY "COL_PRIVS"
remark  Grants on columns.
remark
create or replace view USER_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
/
comment on table USER_COL_PRIVS is
'Grants on columns for which the user is the owner, grantor or grantee'
/
comment on column USER_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS for USER_COL_PRIVS
/
grant select on USER_COL_PRIVS to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME,
       PRIVILEGE, GRANTABLE)
as
select ur.name, ue.name, u.name, o.name, c.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
/
comment on table ALL_COL_PRIVS is
'Grants on columns for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS for ALL_COL_PRIVS
/
grant select on ALL_COL_PRIVS to PUBLIC with grant option
/
create or replace view DBA_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
/
create or replace public synonym DBA_COL_PRIVS for DBA_COL_PRIVS
/
grant select on DBA_COL_PRIVS to select_catalog_role
/
comment on table DBA_COL_PRIVS is
'All grants on columns in the database'
/
comment on column DBA_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column DBA_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column DBA_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
remark
remark  FAMILY "COL_PRIVS_MADE"
remark  Grants on columns made by the user.
remark  This family has no DBA member.
remark
create or replace view USER_COL_PRIVS_MADE
      (GRANTEE, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_COL_PRIVS_MADE is
'All grants on columns of objects owned by the user'
/
comment on column USER_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS_MADE for USER_COL_PRIVS_MADE
/
grant select on USER_COL_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
/
comment on table ALL_COL_PRIVS_MADE is
'Grants on columns for which the user is owner or grantor'
/
comment on column ALL_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_MADE.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS_MADE for ALL_COL_PRIVS_MADE
/
grant select on ALL_COL_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "COL_PRIVS_RECD"
remark  Received grants on columns
remark
create or replace view USER_COL_PRIVS_RECD
      (OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
/
comment on table USER_COL_PRIVS_RECD is
'Grants on columns for which the user is the grantee'
/
comment on column USER_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_RECD.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS_RECD for USER_COL_PRIVS_RECD
/
grant select on USER_COL_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
/
comment on table ALL_COL_PRIVS_RECD is
'Grants on columns for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_COL_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_RECD.PRIVILEGE is
'Column privilege'
/
comment on column ALL_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS_RECD for ALL_COL_PRIVS_RECD
/
grant select on ALL_COL_PRIVS_RECD to PUBLIC with grant option
/
remark
remark  FAMILY "ENCRYPTED_COLUMNS"
remark  information about encrypted columns.
remark
create or replace view DBA_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO'),
          case e.INTALG when 1 then 'SHA-1'
                        when 2 then 'NOMAC'
                        else 'Internal Err'
          end
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864
/
comment on table DBA_ENCRYPTED_COLUMNS is
'Encryption information on columns in the database'
/
comment on column DBA_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column DBA_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
create or replace public synonym DBA_ENCRYPTED_COLUMNS for DBA_ENCRYPTED_COLUMNS
/
grant select on DBA_ENCRYPTED_COLUMNS to select_catalog_role
/
create or replace view ALL_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO'),
          case e.INTALG when 1 then 'SHA-1'
                        when 2 then 'NOMAC'
                        else 'Internal Err'
          end
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864 and
         (o.owner# = userenv('SCHEMAID')
          or
          e.obj# in (select obj# from sys.objauth$ where grantee# in
                        (select kzsrorol from x$kzsro))
          or
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */))
          )
/
comment on table ALL_ENCRYPTED_COLUMNS is
'Encryption information on all accessible columns'
/
comment on column ALL_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column ALL_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
drop public synonym ALL_ENCRYPTED_COLUMNS
/
create public synonym ALL_ENCRYPTED_COLUMNS for ALL_ENCRYPTED_COLUMNS
/
grant select on ALL_ENCRYPTED_COLUMNS to public
/
create or replace view USER_ENCRYPTED_COLUMNS
  (TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
  select TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG,SALT, INTEGRITY_ALG from DBA_ENCRYPTED_COLUMNS
  where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_ENCRYPTED_COLUMNS is
'Encryption information on columns of tables owned by the user'
/
comment on column USER_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column USER_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column USER_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column USER_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
drop public synonym USER_ENCRYPTED_COLUMNS
/
create public synonym USER_ENCRYPTED_COLUMNS for USER_ENCRYPTED_COLUMNS
/
grant select on USER_ENCRYPTED_COLUMNS to public
/

remark
remark  FAMILY "INDEXES"
remark  CREATE INDEX parameters.
remark
create or replace view USER_INDEXES
    (INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED)
as
select o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       to_number(decode(bitand(i.property, 2),2, null, i.initrans)),
       to_number(decode(bitand(i.property, 2),2, null, i.maxtrans)),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                    decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES'))
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 8, 9)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
/
comment on table USER_INDEXES is
'Description of the user''s own indexes'
/
comment on column USER_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column USER_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column USER_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column USER_INDEXES.UNIQUENESS is
'Uniqueness status of the index:  "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column USER_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column USER_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column USER_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column USER_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_INDEXES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_INDEXES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column USER_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column USER_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column USER_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_INDEXES.LOGGING is
'Logging attribute'
/
comment on column USER_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column USER_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_INDEXES.NUM_ROWS is
'Number of rows in the index'
/
comment on column USER_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column USER_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column USER_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column USER_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column USER_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column USER_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column USER_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column USER_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column USER_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column USER_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column USER_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column USER_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column USER_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column USER_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column USER_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column USER_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column USER_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column USER_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column USER_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column USER_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column USER_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/
create or replace public synonym USER_INDEXES for USER_INDEXES
/
create or replace public synonym IND for USER_INDEXES
/
grant select on USER_INDEXES to PUBLIC with grant option
/
remark
remark  This view does not include cluster indexes on clusters
remark  containing tables which are accessible to the user.
remark
create or replace view ALL_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS,  FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED)
 as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name, 'TABLE',
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INRPOGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',            
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),             
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES'))
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io,
     sys.user$ u, sys.ind$ i, sys.obj$ o, sys.user$ itu, sys.obj$ ito,
     sys.deferred_stg$ ds
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and io.type# = 2 /* tables */
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
  and (io.owner# = userenv('SCHEMAID')
        or
       io.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_INDEXES is
'Descriptions of indexes on tables accessible to the user'
/
comment on column ALL_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column ALL_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column ALL_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column ALL_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column ALL_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column ALL_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column ALL_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column ALL_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column ALL_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column ALL_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column ALL_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column ALL_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-organized table top index'
/
comment on column ALL_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column ALL_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_INDEXES.LOGGING is
'Logging attribute'
/
comment on column ALL_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column ALL_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column ALL_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column ALL_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column ALL_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column ALL_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column ALL_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column ALL_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column ALL_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column ALL_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column ALL_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column ALL_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column ALL_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column ALL_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column ALL_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column ALL_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column ALL_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column ALL_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column ALL_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column ALL_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column ALL_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column ALL_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/
create or replace public synonym ALL_INDEXES for ALL_INDEXES
/
grant select on ALL_INDEXES to PUBLIC with grant option
/
create or replace view DBA_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING, BLEVEL,
     LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED)
as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES'))
from sys.ts$ ts, sys.seg$ s,
     sys.user$ iu, sys.obj$ io, sys.user$ u, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito, sys.deferred_stg$ ds
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
/
create or replace public synonym DBA_INDEXES for DBA_INDEXES
/
grant select on DBA_INDEXES to select_catalog_role
/
comment on table DBA_INDEXES is
'Description for all indexes in the database'
/
comment on column DBA_INDEXES.STATUS is
'Whether non-partitioned index is in UNUSABLE state or not'
/
comment on column DBA_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column DBA_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column DBA_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column DBA_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column DBA_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column DBA_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column DBA_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column DBA_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column DBA_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column DBA_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column DBA_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column DBA_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column DBA_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_INDEXES.LOGGING is
'Logging attribute'
/
comment on column DBA_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column DBA_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column DBA_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column DBA_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column DBA_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column DBA_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column DBA_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column DBA_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column DBA_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column DBA_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column DBA_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column DBA_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column DBA_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column DBA_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column DBA_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column DBA_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column DBA_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column DBA_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column DBA_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column DBA_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column DBA_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column DBA_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/
remark
remark  FAMILY "IND_COLUMNS"
remark  Displays information on which columns are contained in which
remark  indexes
remark
create or replace view USER_IND_COLUMNS
    (INDEX_NAME, TABLE_NAME, COLUMN_NAME,
     COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and ic.bo# = base.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5) /* table or cluster namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
union all
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
               from sys.col$ tc, attrcol$ ac
               where tc.intcol# = c.intcol#-1
                 and tc.obj# = c.obj#
                 and tc.obj# = ac.obj#(+)
                 and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
/
comment on table USER_IND_COLUMNS is
'COLUMNs comprising user''s INDEXes and INDEXes on user''s TABLES'
/
comment on column USER_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column USER_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column USER_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column USER_IND_COLUMNS.DESCEND is
'DESC if this column is sorted descending on disk, otherwise ASC'
/
create or replace public synonym USER_IND_COLUMNS for USER_IND_COLUMNS
/
grant select on USER_IND_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (idx.owner# = userenv('SCHEMAID') or
       base.owner# = userenv('SCHEMAID')
       or
       base.obj# in ( select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_IND_COLUMNS is
'COLUMNs comprising INDEXes on accessible TABLES'
/
comment on column ALL_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column ALL_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column ALL_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column ALL_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'
/
create or replace public synonym ALL_IND_COLUMNS for ALL_IND_COLUMNS
/
grant select on ALL_IND_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_IND_COLUMNS for DBA_IND_COLUMNS
/
grant select on DBA_IND_COLUMNS to select_catalog_role
/
comment on table DBA_IND_COLUMNS is
'COLUMNs comprising INDEXes on all TABLEs and CLUSTERs'
/
comment on column DBA_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column DBA_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column DBA_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column DBA_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'

/
remark
remark  FAMILY "IND_EXPRESSIONS"
remark  Displays information on which functional index expressions
remark
create or replace view USER_IND_EXPRESSIONS
    (INDEX_NAME, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and ic.bo# = base.obj#
  and ic.intcol# = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5)
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
union all
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and ic.intcol# = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
/
comment on table USER_IND_EXPRESSIONS is
'Functional index expressions in user''s indexes and indexes on user''s tables'
/
comment on column USER_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym USER_IND_EXPRESSIONS for USER_IND_EXPRESSIONS
/
grant select on USER_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view ALL_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (idx.owner# = userenv('SCHEMAID') or
       base.owner# = userenv('SCHEMAID')
       or
       base.obj# in ( select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on accessible TABLES'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym ALL_IND_EXPRESSIONS for ALL_IND_EXPRESSIONS
/
grant select on ALL_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view DBA_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
/
create or replace public synonym DBA_IND_EXPRESSIONS for DBA_IND_EXPRESSIONS
/
grant select on DBA_IND_EXPRESSIONS to select_catalog_role
/
comment on table DBA_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on all TABLES and CLUSTERS'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/

create or replace view INDEX_STATS as
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln+kdxstpln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, ind$ i, seg$ s, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = i.file#
  and  s.block# = i.block#
  and  s.ts# = i.ts#
  and  i.obj#   = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, seg$ s, indpart$ ip, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = ip.file#
  and  s.block# = ip.block#
  and  s.ts#    = ip.ts#
  and  ip.obj#  = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, seg$ s, indsubpart$ isp, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = isp.file#
  and  s.block# = isp.block#
  and  s.ts#    = isp.ts#
  and  isp.obj#  = o.obj#
/
comment on table INDEX_STATS is
'statistics on the b-tree'
/
comment on column index_stats.height is
'height of the b-tree'
/
comment on column index_stats.blocks is
'blocks allocated to the segment'
/
comment on column index_stats.name is
'name of the index'
/
comment on column index_stats.partition_name is
'name of the index partition, if partitioned'
/
comment on column index_stats.lf_rows is
'number of leaf rows (values in the index)'
/
comment on column index_stats.lf_blks is
'number of leaf blocks in the b-tree'
/
comment on column index_stats.lf_rows_len is
'sum of the lengths of all the leaf rows'
/
comment on column index_stats.lf_blk_len is
'useable space in a leaf block'
/
comment on column index_stats.br_rows is
'number of branch rows'
/
comment on column index_stats.br_blks is
'number of branch blocks in the b-tree'
/
comment on column index_stats.br_rows_len is
'sum of the lengths of all the branch blocks in the b-tree'
/
comment on column index_stats.br_blk_len is
'useable space in a branch block'
/
comment on column index_stats.del_lf_rows is
'number of deleted leaf rows in the index'
/
comment on column index_stats.del_lf_rows_len is
'total length of all deleted rows in the index'
/
comment on column index_stats.distinct_keys is
'number of distinct keys in the index'
/
comment on column index_stats.most_repeated_key is
'how many times the most repeated key is repeated'
/
comment on column index_stats.btree_space is
'total space currently allocated in the b-tree'
/
comment on column index_stats.used_space is
'total space that is currently being used in the b-tree'
/
comment on column index_stats.pct_used is
'percent of space allocated in the b-tree that is being used'
/
comment on column index_stats.rows_per_key is
'average number of rows per distinct key'
/
comment on column index_stats.blks_gets_per_access is
'Expected number of consistent mode block gets per row. This assumes that a row chosen at random from the table is being searched for using the index'
/
comment on column index_stats.pre_rows is
'number of prefix rows (values in the index)'
/
comment on column index_stats.pre_rows_len is
'sum of lengths of all prefix rows'
/
comment on column index_stats.opt_cmpr_count is
'optimal prefix compression count for the index'
/
comment on column index_stats.opt_cmpr_pctsave is
'percentage storage saving expected from optimal prefix compression'
/
create or replace public synonym INDEX_STATS for INDEX_STATS
/
grant select on INDEX_STATS to public with grant option
/
create or replace view INDEX_HISTOGRAM as
 select hist.indx * power(2, stats.kdxstscl-4)  repeat_count,
        hist.kdxhsval                           keys_with_repeat_count
        from  x$kdxst stats, x$kdxhs hist
/
comment on table INDEX_HISTOGRAM is
'statistics on keys with repeat count'
/
comment on column index_histogram.repeat_count is
'number of times that a key is repeated'
/
comment on column index_histogram.keys_with_repeat_count is
'number of keys that are repeated REPEAT_COUNT times'
/
create or replace public synonym INDEX_HISTOGRAM for INDEX_HISTOGRAM
/
grant select on INDEX_HISTOGRAM to public with grant option
/

remark
remark  FAMILY "JOIN_IND_COLUMNS"
remark  Displays information on the join conditions of join
remark  indexes
remark
create or replace view USER_JOIN_IND_COLUMNS
    (INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and oi.owner# = userenv('SCHEMAID')
/
comment on table USER_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column USER_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym USER_JOIN_IND_COLUMNS for USER_JOIN_IND_COLUMNS
/
grant select on USER_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and (oi.owner# = userenv('SCHEMAID')
        or
       oti.owner# = userenv('SCHEMAID')
        or
       oto.owner# = userenv('SCHEMAID')
        or
       oti.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
       oto.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym ALL_JOIN_IND_COLUMNS for ALL_JOIN_IND_COLUMNS
/
grant select on ALL_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
/
comment on table DBA_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym DBA_JOIN_IND_COLUMNS for DBA_JOIN_IND_COLUMNS
/
grant select on DBA_JOIN_IND_COLUMNS to select_catalog_role
/

remark
remark  FAMILY "OBJECTS"
remark  List of objects, including creation and modify times.
remark
create or replace view USER_OBJECTS
    (OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE,
     CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED,
     SECONDARY, NAMESPACE, EDITION_NAME)
as
select o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY',  24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL',  87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                      'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_CURRENT_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */,
                      10 /* NON-EXISTENT */)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 8, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
union all
select l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID', 'N', 'N', 'N', NULL, NULL
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_OBJECTS is
'Objects owned by the user'
/
comment on column USER_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column USER_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column USER_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column USER_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column USER_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column USER_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column USER_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column USER_OBJECTS.STATUS is
'Status of the object'
/
comment on column USER_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column USER_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column USER_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/

create or replace public synonym USER_OBJECTS for USER_OBJECTS
/
create or replace public synonym OBJ for USER_OBJECTS
/
grant select on USER_OBJECTS to PUBLIC with grant option
/
create or replace view ALL_OBJECTS
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */,
                      10 /* NON-EXISTENT */)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* non-procedural objects */
      o.type# not in (7, 8, 9, 11, 12, 13, 14, 28, 29, 30, 56, 93)
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                      7 /* LOCK */,     9 /* SELECT */,
                                      10 /* UPDATE */, 12 /* EXECUTE */,
                                      11 /* USAGE */,  16 /* CREATE */,
                                      17 /* READ */,   18 /* WRITE  */ ))
    )
    or
    (
       o.type# in (7, 8, 9, 28, 29, 30, 56) /* prc, fcn, pkg */
       and
       (
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -144 /* EXECUTE ANY PROCEDURE */,
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
                )
       )
    )
    or
    (
       o.type# in (19) /* partitioned table objects */
       and
       exists (select bo# from tabpart$ where obj# = o.obj# and
               bo# in  (select obj# from sys.objauth$
                where grantee# in (select kzsrorol from x$kzsro)
                  and privilege# in (9 /* SELECT */ ))
              )
    )
    or
    (
       o.type# in (12) /* trigger */
       and
       (
         exists (select null from sys.trigger$ t, sys.objauth$ oa
                  where bitand(t.property, 24) = 0
                    and t.obj# = o.obj#
                    and oa.obj# = t.baseobject
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or         
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -152 /* CREATE ANY TRIGGER */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
              )
       )
    )
    or
    (
       o.type# = 11 /* pkg body */
       and
       (
         exists (select null
                   from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                        sys.objauth$ oa
                  where specobj.owner# = o.owner#
                    and specobj.name = o.name
                    and specobj.type# = 9 /* pkg */
                    and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                    and oa.obj# = specobj.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
                )
       )
    )
    or
    (
       o.type# in (22) /* library */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                    )
              )
    )
    or
    (
       /* index, table, view, synonym, table partn, indx partn, */
       /* table subpartn, index subpartn, cluster               */
       o.type# in (1, 2, 3, 4, 5, 19, 20, 34, 35)
       and
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)
               )
    )
    or
    ( o.type# = 6 /* sequence */
      and
      exists (select null from v$enabledprivs
              where priv_number = -109 /* SELECT ANY SEQUENCE */)
    )
    or
    ( o.type# = 13 /* type */
      and
      (
        exists (select null from sys.objauth$ oa
                 where oa.obj# = o.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        or
        exists (select null from v$enabledprivs
                where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                      -181 /* CREATE ANY TYPE */,
                                      -241 /* DEBUG ANY PROCEDURE */))
      )
    )
    or
    (
      o.type# = 14 /* type body */
      and
      (
        exists (select null
                  from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                       sys.objauth$ oa
                 where specobj.owner# = o.owner#
                   and specobj.name = o.name
                   and specobj.type# = 13 /* type */
                   and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                   and oa.obj# = specobj.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# = 26 /* DEBUG */)
        or
        exists (select null from v$enabledprivs
                where priv_number in (
                                       -181 /* CREATE ANY TYPE */,
                                       -241 /* DEBUG ANY PROCEDURE */
                                     )
               )
      )
    )
    or
    (
       o.type# = 23 /* directory */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -177 /* CREATE ANY DIRECTORY */,
                                      -178 /* DROP ANY DIRECTORY */
                                    )
              )
    )
    or
    (
       o.type# = 42 /* summary jjf table privs have to change to summary */
       and
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
    )
    or
    (
      o.type# = 32   /* indextype */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -205  /* CREATE INDEXTYPE */ ,
                                      -206  /* CREATE ANY INDEXTYPE */ ,
                                      -207  /* ALTER ANY INDEXTYPE */ ,
                                      -208  /* DROP ANY INDEXTYPE */
                                    )
             )
    )
    or
    (
      o.type# = 33   /* operator */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -200  /* CREATE OPERATOR */ ,
                                      -201  /* CREATE ANY OPERATOR */ ,
                                      -202  /* ALTER ANY OPERATOR */ ,
                                      -203  /* DROP ANY OPERATOR */ ,
                                      -204  /* EXECUTE OPERATOR */
                                    )
             )
    )
    or
    (
      o.type# = 44   /* context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -222  /* CREATE ANY CONTEXT */,
                                      -223  /* DROP ANY CONTEXT */
                                    )
             )
    )
    or
    (
      o.type# = 48  /* resource consumer group */
      and
      exists (select null from v$enabledprivs
              where priv_number in (12)  /* switch consumer group privilege */
             )
    )
    or
    (
      o.type# = 46 /* rule set */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -251, /* create any rule set */
                                      -252, /* alter any rule set */
                                      -253, /* drop any rule set */
                                      -254  /* execute any rule set */
                                    )
             )
    )
    or
    (
      o.type# = 55 /* XML schema */
      and
      1 = (select /*+ NO_MERGE */ xml_schema_name_present.is_schema_present(o.name, u2.id2) id1 from (select /*+ NO_MERGE */ userenv('SCHEMAID') id2 from dual) u2)
      /* we need a sub-query instead of the directy invoking
       * xml_schema_name_present, because inside a view even the function
       * arguments are evaluated as definers rights.
       */
    )
    or
    (
      o.type# = 59 /* rule */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -258, /* create any rule */
                                      -259, /* alter any rule */
                                      -260, /* drop any rule */
                                      -261  /* execute any rule */
                                    )
             )
    )
    or
    (
      o.type# = 62 /* evaluation context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -246, /* create any evaluation context */
                                      -247, /* alter any evaluation context */
                                      -248, /* drop any evaluation context */
                                      -249 /* execute any evaluation context */
                                    )
             )
    )
    or
    (
      o.type# IN (66, 100)  /* scheduler job or file watcher */
      and
      exists (select null from v$enabledprivs
               where priv_number = -265 /* create any job */
             )
    )
    or
    (
      o.type# IN (67, 79) /* scheduler program or chain */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -265, /* create any job */
                                      -266 /* execute any program */
                                    )
             )
    )
    or
    (
      o.type# = 68 /* scheduler job class */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -268, /* manage scheduler */
                                      -267 /* execute any class */
                                    )
             )
    )
    or (o.type# in (69, 72, 74, 101))
    /* scheduler windows, scheduler groups, schedules and destinations */
    /* no privileges are needed to view these objects */
    or
    (
      o.type# = 81 /* file group */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                       -277, /* manage any file group */
                                       -278  /* read any file group */
                                    )
             )
    )
    or
    (
      o.type# = 57 /* edition */
    )
    or
    (
      o.type# = 82 /* mining model */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                       -292, /* drop any mining model */
                                       -293, /* select any mining model */
                                       -294  /* alter any mining model */
                                    )
             )
    )
    or
    (
       o.type# in (87) /* assembly */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -282 /* CREATE ANY ASSEMBLY */,
                                      -283 /* ALTER ANY ASSEMBLY */,
                                      -284 /* DROP ANY ASSEMBLY */,
                                      -285 /* EXECUTE ANY ASSEMBLY */
                                    )
              )
    )
    or
    (
      o.type# = 92 /* cube dimension */
      and
      exists (select null from v$enabledprivs
              where priv_number in (
                                      -302, /* ALTER ANY PRIMARY DIMENSION */
                                      -303, /* CREATE ANY PRIMARY DIMENSION */
                                      -304, /* DELETE ANY PRIMARY DIMENSION */
                                      -305, /* DROP ANY PRIMARY DIMENSION */
                                      -306, /* INSERT ANY PRIMARY DIMENSION */
                                      -307  /* SELECT ANY PRIMARY DIMENSION */
                                   )
             )
    )
    or
    (
      o.type# = 93 /* cube */
      and 
      (o.obj# in 
            ( select obj#  /* directly granted privileges */
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or
       (
        exists (select null from v$enabledprivs
                where priv_number in (
                                        -309, /* ALTER ANY CUBE */
                                        -310, /* CREATE ANY CUBE */
                                        -311, /* DROP ANY CUBE */
                                        -312, /* SELECT ANY CUBE */
                                        -313  /* UPDATE ANY CUBE */
                                     )
               )
       )
      )   
      and  /* require access to all Dimensions of the Cube */
      ( 1 = ( SELECT decode(have_all_dim_access, null, 1, have_all_dim_access)
              FROM
                ( SELECT
                    obj#,
                    MIN(have_dim_access) have_all_dim_access
                  FROM
                    ( SELECT
                        c.obj# obj#,
                        ( CASE
                          WHEN
                            ( do.owner# in ( userenv('SCHEMAID'), 1 )  /* public objects */
                              or do.obj# in
                              ( select obj#  /* directly granted privileges */
                                from sys.objauth$
                                where grantee# in ( select kzsrorol from x$kzsro )
                              )
                              or  /* user has system privileges */
                              ( exists ( select null from v$enabledprivs
                                         where priv_number in (
                                                                 -302, /* ALTER ANY PRIMARY DIMENSION */
                                                                 -303, /* CREATE ANY PRIMARY DIMENSION */
                                                                 -304, /* DELETE ANY PRIMARY DIMENSION */
                                                                 -305, /* DROP ANY PRIMARY DIMENSION */
                                                                 -306, /* INSERT ANY PRIMARY DIMENSION */
                                                                 -307  /* SELECT ANY PRIMARY DIMENSION */
                                                              ) 
                                       ) 
                              )
                            )
                          THEN 1
                          ELSE 0
                          END ) have_dim_access
                      FROM
                        olap_cubes$ c,
                        dependency$ d,
                        obj$ do
                      WHERE
                        do.obj# = d.p_obj#
                        AND do.type# = 92 /* CUBE DIMENSION */
                        AND c.obj# = d.d_obj#
                    )
                  GROUP BY obj# ) da
              WHERE
                o.obj#=da.obj#(+)     
            )
      )
    )
    or
    (
      o.type# = 94 /* measure folder */
      and
      exists (select null from v$enabledprivs
              where priv_number in (
                                      -315, /* CREATE ANY MEASURE FOLDER */
                                      -316, /* DELETE ANY MEASURE FOLDER */
                                      -317, /* DROP ANY MEASURE FOLDER */
                                      -318  /* INSERT ANY MEASURE FOLDER */
                                   )
             )
    )
    or
    (
      o.type# = 95 /* cube build process */
      and
      exists (select null from v$enabledprivs
              where priv_number in (
                                      -320, /* CREATE ANY BUILD PROCESS */
                                      -321, /* DROP ANY BUILD PROCESS */
                                      -322  /* UPDATE ANY BUILD PROCESS */
                                   )
             )
    )
  )
/

comment on table ALL_OBJECTS is
'Objects accessible to the user'
/
comment on column ALL_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column ALL_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column ALL_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column ALL_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column ALL_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column ALL_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column ALL_OBJECTS.STATUS is
'Status of the object'
/
comment on column ALL_OBJECTS.TEMPORARY is
'Can the current session only see data that it placed in this object itself?'
/
comment on column ALL_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column ALL_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column ALL_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/

create or replace public synonym ALL_OBJECTS for ALL_OBJECTS
/
grant select on ALL_OBJECTS to PUBLIC with grant option
/
create or replace view DBA_OBJECTS
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and o.type# !=  10 /* NON-EXISTENT */
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
union all
select u.name, l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID','N','N', 'N', NULL, NULL
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_OBJECTS for DBA_OBJECTS
/
grant select on DBA_OBJECTS to select_catalog_role
/
comment on table DBA_OBJECTS is
'All objects in the database'
/
comment on column DBA_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column DBA_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column DBA_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column DBA_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column DBA_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column DBA_OBJECTS.STATUS is
'Status of the object'
/
comment on column DBA_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column DBA_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column DBA_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/

Rem
Rem DBA view to identify INVALID objects before/after an upgrade
Rem
Rem This view eliminates old versions of object types from the DBA_OBJECTS
Rem view.  These objects may be invalid after an upgrade due to changes made
Rem during the upgrade, but they are no longer used.

create or replace view DBA_INVALID_OBJECTS
as
select * from DBA_OBJECTS
where STATUS = 'INVALID' and
  (OBJECT_TYPE != 'TYPE' or (OBJECT_TYPE='TYPE' and SUBOBJECT_NAME is null));

create or replace public synonym DBA_INVALID_OBJECTS for DBA_INVALID_OBJECTS;

grant select on DBA_INVALID_OBJECTS to select_catalog_role;


remark
remark  FAMILY "OBJECTS_AE"
remark  List of objects in all the editions
remark
create or replace view USER_OBJECTS_AE
    (OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE,
     CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED,
     SECONDARY, NAMESPACE, EDITION_NAME)
as
select o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY',  24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL',  87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')
  and o.linkname is null
  and (o.type# != 1  /* INDEX - handled below */
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 8, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
union all
select l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID', 'N', 'N', 'N', NULL, NULL
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_OBJECTS_AE is
'Objects owned by the user'
/
comment on column USER_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column USER_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/
comment on column USER_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column USER_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/
comment on column USER_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/
comment on column USER_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column USER_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column USER_OBJECTS_AE.STATUS is
'Status of the object'
/
comment on column USER_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/
comment on column USER_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/
comment on column USER_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/

create or replace public synonym USER_OBJECTS_AE for USER_OBJECTS_AE
/
grant select on USER_OBJECTS_AE to PUBLIC with grant option
/

create or replace view ALL_OBJECTS_AE
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# != 1  /* INDEX - handled below */
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* non-procedural objects */
      o.type# not in (7, 8, 9, 11, 12, 13, 14, 28, 29, 30, 56)
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                      7 /* LOCK */,     9 /* SELECT */,
                                      10 /* UPDATE */, 12 /* EXECUTE */,
                                      11 /* USAGE */,  16 /* CREATE */,
                                      17 /* READ */,   18 /* WRITE  */))
    )
    or
    (
       o.type# in (19) /* partitioned table objects */
       and
       exists (select bo# from tabpart$ where obj# = o.obj# and
               bo# in  (select obj# from sys.objauth$
                where grantee# in (select kzsrorol from x$kzsro)
                  and privilege# in (9 /* SELECT */ ))
              )
    )
    or
    (
       o.type# in (7, 8, 9, 28, 29, 30, 56) /* prc, fcn, pkg */
       and
       (
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -144 /* EXECUTE ANY PROCEDURE */,
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
                )
       )
    )
    or
    (
       o.type# in (12) /* trigger */
       and
       (
         exists (select null from sys.trigger$ t, sys.objauth$ oa
                  where bitand(t.property, 24) = 0
                    and t.obj# = o.obj#
                    and oa.obj# = t.baseobject
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or         
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -152 /* CREATE ANY TRIGGER */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
              )
       )
    )
    or
    (
       o.type# = 11 /* pkg body */
       and
       (
         exists (select null
                   from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                        sys.objauth$ oa
                  where specobj.owner# = o.owner#
                    and specobj.name = o.name
                    and specobj.type# = 9 /* pkg */
                    and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                    and oa.obj# = specobj.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or
         exists (select null from v$enabledprivs
                 where priv_number in (
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -241 /* DEBUG ANY PROCEDURE */
                                      )
                )
       )
    )
    or
    (
       o.type# in (22) /* library */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                    )
              )
    )
    or
    (
       /* index, table, view, synonym, table partn, indx partn, */
       /* table subpartn, index subpartn, cluster               */
       o.type# in (1, 2, 3, 4, 5, 19, 20, 34, 35)
       and
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)
               )
    )
    or
    ( o.type# = 6 /* sequence */
      and
      exists (select null from v$enabledprivs
              where priv_number = -109 /* SELECT ANY SEQUENCE */)
    )
    or
    ( o.type# = 13 /* type */
      and
      (
        exists (select null from sys.objauth$ oa
                 where oa.obj# = o.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        or
        exists (select null from v$enabledprivs
                where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                      -181 /* CREATE ANY TYPE */,
                                      -241 /* DEBUG ANY PROCEDURE */))
      )
    )
    or
    (
      o.type# = 14 /* type body */
      and
      (
        exists (select null
                  from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                       sys.objauth$ oa
                 where specobj.owner# = o.owner#
                   and specobj.name = o.name
                   and specobj.type# = 13 /* type */
                   and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                   and oa.obj# = specobj.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# = 26 /* DEBUG */)
        or
        exists (select null from v$enabledprivs
                where priv_number in (
                                       -181 /* CREATE ANY TYPE */,
                                       -241 /* DEBUG ANY PROCEDURE */
                                     )
               )
      )
    )
    or
    (
       o.type# = 23 /* directory */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -177 /* CREATE ANY DIRECTORY */,
                                      -178 /* DROP ANY DIRECTORY */
                                    )
              )
    )
    or
    (
       o.type# = 42 /* summary jjf table privs have to change to summary */
       and
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
    )
    or
    (
      o.type# = 32   /* indextype */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -205  /* CREATE INDEXTYPE */ ,
                                      -206  /* CREATE ANY INDEXTYPE */ ,
                                      -207  /* ALTER ANY INDEXTYPE */ ,
                                      -208  /* DROP ANY INDEXTYPE */
                                    )
             )
    )
    or
    (
      o.type# = 33   /* operator */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -200  /* CREATE OPERATOR */ ,
                                      -201  /* CREATE ANY OPERATOR */ ,
                                      -202  /* ALTER ANY OPERATOR */ ,
                                      -203  /* DROP ANY OPERATOR */ ,
                                      -204  /* EXECUTE OPERATOR */
                                    )
             )
    )
    or
    (
      o.type# = 44   /* context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -222  /* CREATE ANY CONTEXT */,
                                      -223  /* DROP ANY CONTEXT */
                                    )
             )
    )
    or
    (
      o.type# = 48  /* resource consumer group */
      and
      exists (select null from v$enabledprivs
              where priv_number in (12)  /* switch consumer group privilege */
             )
    )
    or
    (
      o.type# = 46 /* rule set */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -251, /* create any rule set */
                                      -252, /* alter any rule set */
                                      -253, /* drop any rule set */
                                      -254  /* execute any rule set */
                                    )
             )
    )
    or
    (
      o.type# = 55 /* XML schema */
      and
      1 = (select /*+ NO_MERGE */ xml_schema_name_present.is_schema_present(o.name, u2.id2) id1 from (select /*+ NO_MERGE */ userenv('SCHEMAID') id2 from dual) u2)
      /* we need a sub-query instead of the directy invoking
       * xml_schema_name_present, because inside a view even the function
       * arguments are evaluated as definers rights.
       */
    )
    or
    (
      o.type# = 59 /* rule */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -258, /* create any rule */
                                      -259, /* alter any rule */
                                      -260, /* drop any rule */
                                      -261  /* execute any rule */
                                    )
             )
    )
    or
    (
      o.type# = 62 /* evaluation context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -246, /* create any evaluation context */
                                      -247, /* alter any evaluation context */
                                      -248, /* drop any evaluation context */
                                      -249 /* execute any evaluation context */
                                    )
             )
    )
    or
    (
      o.type# = 66 /* scheduler job */
      and
      exists (select null from v$enabledprivs
               where priv_number = -265 /* create any job */
             )
    )
    or
    (
      o.type# IN (67, 79) /* scheduler program or chain */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -265, /* create any job */
                                      -266 /* execute any program */
                                    )
             )
    )
    or
    (
      o.type# = 68 /* scheduler job class */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -268, /* manage scheduler */
                                      -267 /* execute any class */
                                    )
             )
    )
    or (o.type# in (69, 72, 74))
    /* scheduler windows, window groups and schedules */
    /* no privileges are needed to view these objects */
    or
    (
      o.type# = 81 /* file group */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                       -277, /* manage any file group */
                                       -278  /* read any file group */
                                    )
             )
    )
    or
    (
      o.type# = 57 /* edition */
    )
    or
    (
       o.type# in (87) /* assembly */
       and
       exists (select null from v$enabledprivs
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

comment on table ALL_OBJECTS_AE is
'Objects accessible to the user'
/
comment on column ALL_OBJECTS_AE.OWNER is
'Username of the owner of the object'
/
comment on column ALL_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column ALL_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column ALL_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/
comment on column ALL_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/
comment on column ALL_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column ALL_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column ALL_OBJECTS_AE.STATUS is
'Status of the object'
/
comment on column ALL_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it placed in this object itself?'
/
comment on column ALL_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/
comment on column ALL_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/
comment on column ALL_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/

create or replace public synonym ALL_OBJECTS_AE for ALL_OBJECTS_AE
/
grant select on ALL_OBJECTS_AE to PUBLIC with grant option
/
create or replace view DBA_OBJECTS_AE
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
union all
select u.name, l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID','N','N', 'N', NULL, NULL
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_OBJECTS_AE for DBA_OBJECTS_AE
/
grant select on DBA_OBJECTS_AE to select_catalog_role
/
comment on table DBA_OBJECTS_AE is
'All objects in the database'
/
comment on column DBA_OBJECTS_AE.OWNER is
'Username of the owner of the object'
/
comment on column DBA_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column DBA_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column DBA_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/
comment on column DBA_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column DBA_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column DBA_OBJECTS_AE.STATUS is
'Status of the object'
/
comment on column DBA_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/
comment on column DBA_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/
comment on column DBA_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/


remark
remark  FAMILY "ROLLBACK_SEGS"
remark  CREATE ROLLBACK SEGMENT parameters.
remark  This family has a DBA member only.
remark
create or replace view DBA_ROLLBACK_SEGS
    (SEGMENT_NAME, OWNER, TABLESPACE_NAME, SEGMENT_ID, FILE_ID, BLOCK_ID,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     STATUS, INSTANCE_NUM, RELATIVE_FNO)
as
select un.name, decode(un.user#,1,'PUBLIC','SYS'),
       ts.name, un.us#, f.file#, un.block#,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(un.status$, 2, 'OFFLINE', 3, 'ONLINE',
                          4, 'UNDEFINED', 5, 'NEEDS RECOVERY',
                          6, 'PARTLY AVAILABLE', 'UNDEFINED'),
       decode(un.inst#, 0, NULL, un.inst#), un.file#
from sys.undo$ un, sys.seg$ s, sys.ts$ ts, sys.file$ f
where un.status$ != 1
  and un.ts# = s.ts#
  and un.file# = s.file#
  and un.block# = s.block#
  and s.type# in (1, 10)
  and s.ts# = ts.ts#
  and un.ts# = f.ts#
  and un.file# = f.relfile#
/
create or replace public synonym DBA_ROLLBACK_SEGS for DBA_ROLLBACK_SEGS
/
grant select on DBA_ROLLBACK_SEGS to select_catalog_role
/
comment on table DBA_ROLLBACK_SEGS is
'Description of rollback segments'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_NAME is
'Name of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.OWNER is
'Owner of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.TABLESPACE_NAME is
'Name of the tablespace containing the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_ID is
'ID number of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.FILE_ID is
'ID number of the file containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.BLOCK_ID is
'ID number of the block containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.INITIAL_EXTENT is
'Initial extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.NEXT_EXTENT is
'Secondary extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.MIN_EXTENTS is
'Minimum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.MAX_EXTENTS is
'Maximum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.PCT_INCREASE is
'Percent increase for extent size'
/
comment on column DBA_ROLLBACK_SEGS.STATUS is
'Rollback segment status'
/
comment on column DBA_ROLLBACK_SEGS.INSTANCE_NUM is
'Rollback segment owning parallel server instance number'
/
comment on column DBA_ROLLBACK_SEGS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/

remark
remark  FAMILY "ROLE GRANTS"
remark
remark
create or replace view USER_ROLE_PRIVS
    (USERNAME, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE, OS_GRANTED)
as
select /*+ ordered */ decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(option$), 1, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 1, decode(min(u2.password),null,'YES','NO'),
              2, decode(min(ud.role#),null,'NO','YES'),
              3, decode(min(ud.role#),null,'YES','NO'), 'NO'), 'NO'
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee# in (userenv('SCHEMAID'),1) and sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union
select su.name,u.name,decode(kzdosadm,'A','YES','NO'),
       decode(kzdosdef,'Y','YES','NO'), 'YES'
 from sys.user$ u,x$kzdos, sys.user$ su
where u.user#=x$kzdos.kzdosrol and
      su.user#=userenv('SCHEMAID');
/
comment on table USER_ROLE_PRIVS is
'Roles granted to current user'
/
comment on column USER_ROLE_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column USER_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column USER_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/
comment on column USER_ROLE_PRIVS.OS_GRANTED is
'Role is granted via the operating system (using OS_ROLES = TRUE)'
/
create or replace public synonym USER_ROLE_PRIVS for USER_ROLE_PRIVS
/
grant select on USER_ROLE_PRIVS to PUBLIC with grant option
/
create or replace view DBA_ROLE_PRIVS
    (GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE)
as
select /*+ ordered */ decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(option$), 1, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 1, 'YES',
              2, decode(min(ud.role#),null,'NO','YES'),
              3, decode(min(ud.role#),null,'YES','NO'), 'NO')
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
/
create or replace public synonym DBA_ROLE_PRIVS for DBA_ROLE_PRIVS
/
grant select on DBA_ROLE_PRIVS to select_catalog_role
/
comment on table DBA_ROLE_PRIVS is
'Roles granted to users and roles'
/
comment on column DBA_ROLE_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column DBA_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column DBA_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/

remark
remark  FAMILY "SEQUENCES"
remark  CREATE SEQUENCE information.
remark
create or replace view USER_SEQUENCES
  (SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = s.obj#
/
comment on table USER_SEQUENCES is
'Description of the user''s own SEQUENCEs'
/
comment on column USER_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column USER_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column USER_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column USER_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column USER_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column USER_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column USER_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column USER_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
create or replace public synonym USER_SEQUENCES for USER_SEQUENCES
/
create or replace public synonym SEQ for USER_SEQUENCES
/
grant select on USER_SEQUENCES to PUBLIC with grant option
/
create or replace view ALL_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or
         exists (select null from v$enabledprivs
                 where priv_number = -109 /* SELECT ANY SEQUENCE */
                 )
      )
/
comment on table ALL_SEQUENCES is
'Description of SEQUENCEs accessible to the user'
/
comment on column ALL_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column ALL_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column ALL_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column ALL_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column ALL_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column ALL_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column ALL_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column ALL_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column ALL_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
create or replace public synonym ALL_SEQUENCES for ALL_SEQUENCES
/
grant select on ALL_SEQUENCES to PUBLIC with grant option
/
create or replace view DBA_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
/
create or replace public synonym DBA_SEQUENCES for DBA_SEQUENCES
/
grant select on DBA_SEQUENCES to select_catalog_role
/
comment on table DBA_SEQUENCES is
'Description of all SEQUENCEs in the database'
/
comment on column DBA_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column DBA_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column DBA_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column DBA_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column DBA_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column DBA_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column DBA_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column DBA_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column DBA_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/

remark
remark  FAMILY "SYNONYMS"
remark  CREATE SYNONYM information.
remark

rem The DBA_SYNONYMS view shows all synonyms in the database.
rem It is driven by the OBJ$ table,
rem restricting on type code 5 (synonym).
rem We join with the SYN$ table by object number,
rem to get the owner and name of the base object
rem that the synonym points to.
rem Note that despite the column names TABLE_OWNER and TABLE_NAME,
rem the base object might not be a table at all,
rem but rather a view, stored procedure, synonym, etc.
rem From SYN$, we also get the optional database link.
rem If the database link is null, then it's a local object.
rem Otherwise, it's a remote object.
rem Finally, we join with the USER$ table to get the name
rem of the user who owns the synonym, or PUBLIC.
rem

create or replace view DBA_SYNONYMS
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
/

create or replace public synonym DBA_SYNONYMS for DBA_SYNONYMS
/
grant select on DBA_SYNONYMS to select_catalog_role
/
comment on table DBA_SYNONYMS is
'All synonyms in the database'
/
comment on column DBA_SYNONYMS.OWNER is
'Username of the owner of the synonym'
/
comment on column DBA_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column DBA_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/

rem
rem The view USER_SYNONYMS is identical to DBA_SYNONYMS,
rem except that we only look at synonyms owned by the current user,
rem by restricting on the owner id from OBJ$.
rem

create or replace view USER_SYNONYMS
    (SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as select o.name, s.owner, s.name, s.node
from sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = userenv('SCHEMAID')
/

comment on table USER_SYNONYMS is
'The user''s private synonyms'
/
comment on column USER_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column USER_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.DB_LINK is
'Database link referenced in a remote synonym'
/
create or replace public synonym SYN for USER_SYNONYMS
/
create or replace public synonym USER_SYNONYMS for USER_SYNONYMS
/
grant select on USER_SYNONYMS to PUBLIC with grant option
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_SYNONYMS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined for synonyms
rem (as opposed to those that are defined for some base object,
rem such as a table or view).
rem The view should not be publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_FOR_SYNONYMS"
    (SYN_ID, BASE_SYN_ID)
as
select s.obj#, bo.obj#
from sys.syn$ s, sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
where s.owner = bu.name         /* get the owner id for the base object */
  and bu.user# = bo.owner#      /* get the obj$ entry for the base object */
  and s.name = bo.name          /* get the obj$ entry for the base object */
  and bo.type# = 5              /* restrict to synonyms for synonyms */
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_AUTH_OBJECTS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined directly
rem for an accessible object (and not for another synonym).
rem If the synonym is for an object via a database link,
rem then it won't appear here, because we have no way of knowing
rem whether remote objects are accessible or not.
rem The view should not be publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_FOR_AUTH_OBJECTS"
    (SYN_ID, BASE_OBJ_OWNER, BASE_OBJ_NAME)
as
select s.obj#, s.owner, s.name
from sys.syn$ s
where (    s.node is null
       and exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                     )
       )
   or
      exists
        (select null
         from sys.objauth$ ba, sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
         where s.node is null
           and bu.name = s.owner
           and bo.name = s.name
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
               )
        )
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_TREE is a support view for ALL_SYNONYMS.
rem The view is for internal use only and may change without notice.
rem It gives the hierarchical tree of synonyms that ultimately point
rem to a base object that is accessible by the current user and session.
rem It may perform poorly, due to the CONNECT BY clause.
rem It should not be made publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_TREE"
    (SYN_ID)
as
select s.syn_id
from sys."_ALL_SYNONYMS_FOR_SYNONYMS" s
/* user has any privs on ultimate base object */
start with exists (
  select null
  from sys."_ALL_SYNONYMS_FOR_AUTH_OBJECTS" sa
  where s.base_syn_id = sa.syn_id
  )
connect by nocycle prior s.syn_id = s.base_syn_id
/

rem
rem The view ALL_SYNONYMS shows synonyms that are "accessible"
rem to the current user and session.
rem That includes all private synonyms (owned by the user);
rem plus all public synonyms;
rem plus synonyms that ultimately resolve to a base object
rem that is accessible to the current user and session.
rem The latter condition includes synonyms that resolve
rem through a chain of synonyms to an accessible base object.
rem Finally, if the user has special privileges,
rem then we also show all synonyms that point to local objects.
rem

create or replace view ALL_SYNONYMS
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as
select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
  and (
       o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */)  /* user's private, any public */
       or /* local object, and user has system privileges */
         (s.node is null /* don't know accessibility if syn is for db link */
          and exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                     )
         )
       or /* user has any privs on base object in local database */
        exists
        (select null
         from sys.objauth$ ba, sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
         where s.node is null /* don't know accessibility if syn for db link */
           and bu.name = s.owner
           and bo.name = s.name
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
               )
        )
      )
union
select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o,
     sys."_ALL_SYNONYMS_TREE" st
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user# 
  and o.obj# = st.syn_id /* syn is in tree pointing to accessible base obj */
  and s.obj# = st.syn_id /* syn is in tree pointing to accessible base obj */
/

comment on table ALL_SYNONYMS is
'All synonyms for base objects accessible to the user and session'
/
comment on column ALL_SYNONYMS.OWNER is
'Owner of the synonym'
/
comment on column ALL_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column ALL_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/
create or replace public synonym ALL_SYNONYMS for ALL_SYNONYMS
/
grant select on ALL_SYNONYMS to PUBLIC with grant option
/

remark
remark  FAMILY "TABLES"
remark  CREATE TABLE parameters.
remark
create or replace view USER_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL,  FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE)
as
select o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',                                    
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(t.property, 8388608), 8388608,
                  'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216   -- 0x1000000
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO', 
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',
                     4398046511104,'MANUAL','DEFAULT')
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o, 
     sys.deferred_stg$ ds, sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, 
     x$ksppi ksppi
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table USER_TABLES is
'Description of the user''s own relational tables'
/
comment on column USER_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column USER_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column USER_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
create or replace public synonym USER_TABLES for USER_TABLES
/
create or replace public synonym TABS for USER_TABLES
/
grant select on USER_TABLES to PUBLIC with grant option
/
create or replace view USER_OBJECT_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED)
as
select o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),           
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES'))
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su,
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table USER_OBJECT_TABLES is
'Description of the user''s own object tables'
/
comment on column USER_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table
entry belongs'
/
comment on column USER_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
create or replace public synonym USER_OBJECT_TABLES for USER_OBJECT_TABLES
/
grant select on USER_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view USER_ALL_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED)
as
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE,
     NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED
from user_tables
union all
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED
from user_object_tables
/
comment on table USER_ALL_TABLES is
'Description of all object and relational tables owned by the user''s'
/
comment on column USER_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column USER_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
create or replace public synonym USER_ALL_TABLES for USER_ALL_TABLES
/
grant select on USER_ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE)
as
select u.name, o.name,
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',    
                 4398046511104,'MANUAL','DEFAULT') 
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi, 
     sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.obj# = ds.obj# (+)
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table ALL_TABLES is
'Description of relational tables accessible to the user'
/
comment on column ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column ALL_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
create or replace public synonym ALL_TABLES for ALL_TABLES
/
grant select on ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES'))
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su, 
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.obj# = ds.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table ALL_OBJECT_TABLES is
'Description of all object tables accessible to the user'
/
comment on column ALL_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
create or replace public synonym ALL_OBJECT_TABLES for ALL_OBJECT_TABLES
/
grant select on ALL_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view ALL_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED
from all_tables
union all
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED
from all_object_tables
/
comment on table ALL_ALL_TABLES is
'Description of all object and relational tables accessible to the user'
/
comment on column ALL_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
create or replace public synonym ALL_ALL_TABLES for ALL_ALL_TABLES
/
grant select on ALL_ALL_TABLES to PUBLIC with grant option
/
create or replace view DBA_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',     
                4398046511104,'MANUAL','DEFAULT')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi, 
     sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.obj# = ds.obj# (+)
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
create or replace public synonym DBA_TABLES for DBA_TABLES
/
grant select on DBA_TABLES to select_catalog_role
/
comment on table DBA_TABLES is
'Description of all relational tables in the database'
/
comment on column DBA_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column DBA_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column DBA_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
create or replace view DBA_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'OLTP'
               else decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                          2, 'QUERY HIGH',
                                          3, 'ARCHIVE LOW',
                                             'ARCHIVE HIGH') end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'OLTP'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then 'QUERY LOW'
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then 'QUERY HIGH'
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then 'ARCHIVE LOW'
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then 'ARCHIVE HIGH'
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES'))
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su,
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.owner# = tu.user#
  and ty.type# <> 10
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
create or replace public synonym DBA_OBJECT_TABLES for DBA_OBJECT_TABLES
/
grant select on DBA_OBJECT_TABLES to select_catalog_role
/
comment on table DBA_OBJECT_TABLES is
'Description of all object tables in the database'
/
comment on column DBA_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
create or replace view DBA_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED
from dba_tables
union all
select * from dba_object_tables
/
create or replace public synonym DBA_ALL_TABLES for DBA_ALL_TABLES
/
grant select on DBA_ALL_TABLES to select_catalog_role
/
comment on table DBA_ALL_TABLES is
'Description of all object and relational tables in the database'
/
comment on column DBA_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
remark
remark  FAMILY "TAB_COLS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
create or replace view USER_TAB_COLS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.hist_head$ h, 
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut
where o.obj# = c.obj#
  and bitand(o.flags, 128) = 0
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                    /* cluster, view */
       or
       (o.type# = 2    /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
comment on table USER_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column USER_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column USER_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column USER_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column USER_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym USER_TAB_COLS for USER_TAB_COLS
/
grant select on USER_TAB_COLS to PUBLIC with grant option
/
create or replace view ALL_TAB_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and bitand(o.flags, 128) = 0
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
/
comment on table ALL_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column ALL_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column ALL_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column ALL_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column ALL_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym ALL_TAB_COLS for ALL_TAB_COLS
/
grant select on ALL_TAB_COLS to PUBLIC with grant option
/
create or replace view DBA_TAB_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
comment on table DBA_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column DBA_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column DBA_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column DBA_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column DBA_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym DBA_TAB_COLS for DBA_TAB_COLS
/
grant select on DBA_TAB_COLS to select_catalog_role
/
remark
remark  FAMILY "TAB_COLUMNS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
create or replace view USER_TAB_COLUMNS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from USER_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table USER_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLUMNS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym USER_TAB_COLUMNS for USER_TAB_COLUMNS
/
create or replace public synonym COLS for USER_TAB_COLUMNS
/
grant select on USER_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from ALL_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table ALL_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLUMNS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym ALL_TAB_COLUMNS for ALL_TAB_COLUMNS
/
grant select on ALL_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from DBA_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table DBA_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLUMNS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym DBA_TAB_COLUMNS for DBA_TAB_COLUMNS
/
grant select on DBA_TAB_COLUMNS to select_catalog_role
/





remark
remark  FAMILY "TAB_COMMENTS"
remark  Comments on objects.
remark
create or replace view USER_TAB_COMMENTS
    (TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.com$ c
where o.owner# = userenv('SCHEMAID')
  and bitand(o.flags,128) = 0
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
/
comment on table USER_TAB_COMMENTS is
'Comments on the tables and views owned by the user'
/
comment on column USER_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_COMMENTS.TABLE_TYPE is
'Type of the object:  "TABLE" or "VIEW"'
/
comment on column USER_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
create or replace public synonym USER_TAB_COMMENTS for USER_TAB_COMMENTS
/
grant select on USER_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.com$ c
where o.owner# = u.user#
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
  and bitand(o.flags, 128) = 0
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
/
comment on table ALL_TAB_COMMENTS is
'Comments on tables and views accessible to the user'
/
comment on column ALL_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column ALL_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
create or replace public synonym ALL_TAB_COMMENTS for ALL_TAB_COMMENTS
/
grant select on ALL_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.com$ c
where o.owner# = u.user#
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
/
create or replace public synonym DBA_TAB_COMMENTS for DBA_TAB_COMMENTS
/
grant select on DBA_TAB_COMMENTS to select_catalog_role
/
comment on table DBA_TAB_COMMENTS is
'Comments on all tables and views in the database'
/
comment on column DBA_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column DBA_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
remark
remark  FAMILY "TAB_PRIVS"
remark  Grants on objects.
remark
create or replace view USER_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
/
comment on table USER_TAB_PRIVS is
'Grants on objects for which the user is the owner, grantor or grantee'
/
comment on column USER_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS for USER_TAB_PRIVS
/
grant select on USER_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, GRANTABLE,
       HIERARCHY)
as
select ur.name, ue.name, u.name, o.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
/
comment on table ALL_TAB_PRIVS is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS for ALL_TAB_PRIVS
/
grant select on ALL_TAB_PRIVS to PUBLIC with grant option
/
create or replace view DBA_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
/
create or replace public synonym DBA_TAB_PRIVS for DBA_TAB_PRIVS
/
grant select on DBA_TAB_PRIVS to select_catalog_role
/
comment on table DBA_TAB_PRIVS is
'All grants on objects in the database'
/
comment on column DBA_TAB_PRIVS.GRANTEE is
'User to whom access was granted'
/
comment on column DBA_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column DBA_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column DBA_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
remark
remark  FAMILY "TAB_PRIVS_MADE"
remark  Grants made on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_MADE
      (GRANTEE, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_TAB_PRIVS_MADE is
'All grants on objects owned by the user'
/
comment on column USER_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS_MADE for USER_TAB_PRIVS_MADE
/
grant select on USER_TAB_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
/
comment on table ALL_TAB_PRIVS_MADE is
'User''s grants and grants on user''s objects'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_MADE.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS_MADE for ALL_TAB_PRIVS_MADE
/
grant select on ALL_TAB_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "TAB_PRIVS_RECD"
remark  Grants received on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_RECD
      (OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
/
comment on table USER_TAB_PRIVS_RECD is
'Grants on objects for which the user is the grantee'
/
comment on column USER_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS_RECD for USER_TAB_PRIVS_RECD
/
grant select on USER_TAB_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
/
comment on table ALL_TAB_PRIVS_RECD is
'Grants on objects for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS_RECD for ALL_TAB_PRIVS_RECD
/
grant select on ALL_TAB_PRIVS_RECD to PUBLIC with grant option
/

remark
remark  FAMILY "VIEWS"
remark  All relevant information about views, except columns.
remark
create or replace view USER_VIEWS
    (VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY)
as
select o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, "_CURRENT_EDITION_OBJ" sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N')
from sys."_CURRENT_EDITION_OBJ" o, sys.view$ v, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_VIEWS is
'Description of the user''s own views'
/
comment on column USER_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column USER_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column USER_VIEWS.TEXT is
'View text'
/
comment on column USER_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column USER_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column USER_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is a object view'
/
comment on column USER_VIEWS.VIEW_TYPE is
'Type of the view if the view is a object view'
/
comment on column USER_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column USER_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column USER_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
create or replace public synonym USER_VIEWS for USER_VIEWS
/
grant select on USER_VIEWS to PUBLIC with grant option
/
create or replace view ALL_VIEWS
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, "_CURRENT_EDITION_OBJ" sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N')
from sys."_CURRENT_EDITION_OBJ" o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_VIEWS is
'Description of views accessible to the user'
/
comment on column ALL_VIEWS.OWNER is
'Owner of the view'
/
comment on column ALL_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column ALL_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column ALL_VIEWS.TEXT is
'View text'
/
comment on column ALL_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column ALL_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column ALL_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column ALL_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column ALL_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column ALL_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column ALL_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
create or replace public synonym ALL_VIEWS for ALL_VIEWS
/
grant select on ALL_VIEWS to PUBLIC with grant option
/
create or replace view DBA_VIEWS
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, "_CURRENT_EDITION_OBJ" sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N')
from sys."_CURRENT_EDITION_OBJ" o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
/
create or replace public synonym DBA_VIEWS for DBA_VIEWS
/
grant select on DBA_VIEWS to select_catalog_role
/
comment on table DBA_VIEWS is
'Description of all views in the database'
/
comment on column DBA_VIEWS.OWNER is
'Owner of the view'
/
comment on column DBA_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column DBA_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column DBA_VIEWS.TEXT is
'View text'
/
comment on column DBA_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column DBA_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column DBA_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column DBA_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column DBA_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column DBA_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column DBA_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/

remark
remark  FAMILY "VIEWS_AE"
remark  All relevant information about views, except columns in all editions.
remark
create or replace view USER_VIEWS_AE
    (VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, EDITION_NAME)
as
select o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N'),
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o, sys.view$ v, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_VIEWS_AE is
'Description of the user''s own views'
/
comment on column USER_VIEWS_AE.VIEW_NAME is
'Name of the view'
/
comment on column USER_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/
comment on column USER_VIEWS_AE.TEXT is
'View text'
/
comment on column USER_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column USER_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/
comment on column USER_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is a object view'
/
comment on column USER_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is a object view'
/
comment on column USER_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column USER_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column USER_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column USER_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/

create or replace public synonym USER_VIEWS_AE for USER_VIEWS_AE
/
grant select on USER_VIEWS_AE to PUBLIC with grant option
/
create or replace view ALL_VIEWS_AE
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, EDITION_NAME)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N'),
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_VIEWS_AE is
'Description of views accessible to the user'
/
comment on column ALL_VIEWS_AE.OWNER is
'Owner of the view'
/
comment on column ALL_VIEWS_AE.VIEW_NAME is
'Name of the view'
/
comment on column ALL_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/
comment on column ALL_VIEWS_AE.TEXT is
'View text'
/
comment on column ALL_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column ALL_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/
comment on column ALL_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column ALL_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column ALL_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column ALL_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column ALL_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column ALL_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/
create or replace public synonym ALL_VIEWS_AE for ALL_VIEWS_AE
/
grant select on ALL_VIEWS_AE to PUBLIC with grant option
/
create or replace view DBA_VIEWS_AE
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, EDITION_NAME)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N'),
       o.defining_edition
from sys."_ACTUAL_EDITION_OBJ" o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
/
create or replace public synonym DBA_VIEWS_AE for DBA_VIEWS_AE
/
grant select on DBA_VIEWS_AE to select_catalog_role
/
comment on table DBA_VIEWS_AE is
'Description of all views in the database'
/
comment on column DBA_VIEWS_AE.OWNER is
'Owner of the view'
/
comment on column DBA_VIEWS_AE.VIEW_NAME is
'Name of the view'
/
comment on column DBA_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/
comment on column DBA_VIEWS_AE.TEXT is
'View text'
/
comment on column DBA_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column DBA_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/
comment on column DBA_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column DBA_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column DBA_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column DBA_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column DBA_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column DBA_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/

remark
remark  FAMILY "CONSTRAINTS"
remark
create or replace view USER_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', 8, 'H', 9, 'F',
              10, 'F', 11, 'F', 13, 'F', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys."_BASE_USER" ou, sys."_BASE_USER" ru,
     sys."_CURRENT_EDITION_OBJ" ro, sys."_CURRENT_EDITION_OBJ" o, sys.cdef$ c,
     sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
  and o.owner# = userenv('SCHEMAID')
  and c.type# != 8
  and (c.type# < 14 or c.type# > 17)    /* don't include supplog cons   */
  and (c.type# != 12)                   /* don't include log group cons */
/
comment on table USER_CONSTRAINTS is
'Constraint definitions on user''s own tables'
/
comment on column USER_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column USER_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column USER_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column USER_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column USER_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column USER_CONSTRAINTS.STATUS is
'Enforcement status of constraint -  ENABLED or DISABLED'
/
comment on column USER_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column USER_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column USER_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column USER_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column USER_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column USER_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column USER_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column USER_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by the constraint'
/
comment on column USER_CONSTRAINTS.INDEX_NAME is
'The index used by the constraint'
/
grant select on USER_CONSTRAINTS to public with grant option
/
create or replace public synonym USER_CONSTRAINTS for USER_CONSTRAINTS
/
create or replace view ALL_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', 8, 'H', 9, 'F',
              10, 'F', 11, 'F', 13, 'F', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys."_BASE_USER" ou, sys."_BASE_USER" ru,
     sys."_CURRENT_EDITION_OBJ" ro, sys."_CURRENT_EDITION_OBJ" o, sys.cdef$ c,
     sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8
  and (c.type# < 14 or c.type# > 17)    /* don't include supplog cons   */
  and (c.type# != 12)                   /* don't include log group cons */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+) 
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_CONSTRAINTS is
'Constraint definitions on accessible tables'
/
comment on column ALL_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column ALL_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column ALL_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column ALL_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column ALL_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column ALL_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column ALL_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column ALL_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column ALL_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column ALL_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column ALL_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column ALL_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column ALL_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column ALL_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column ALL_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/
grant select on ALL_CONSTRAINTS to public with grant option
/

create or replace public synonym ALL_CONSTRAINTS for ALL_CONSTRAINTS
/
create or replace view DBA_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', 8, 'H', 9, 'F',
              10, 'F', 11, 'F', 13, 'F', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys."_BASE_USER" ou, sys."_BASE_USER" ru,
     sys."_CURRENT_EDITION_OBJ" ro, sys."_CURRENT_EDITION_OBJ" o, sys.cdef$ c,
     sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8        /* don't include hash expressions */
  and (c.type# < 14 or c.type# > 17)    /* don't include supplog cons   */
  and (c.type# != 12)                   /* don't include log group cons */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
/
create or replace public synonym DBA_CONSTRAINTS for DBA_CONSTRAINTS
/
grant select on DBA_CONSTRAINTS to select_catalog_role
/
comment on table DBA_CONSTRAINTS is
'Constraint definitions on all tables'
/
comment on column DBA_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column DBA_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column DBA_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column DBA_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column DBA_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column DBA_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column DBA_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column DBA_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column DBA_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column DBA_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column DBA_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column DBA_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column DBA_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column DBA_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column DBA_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/

remark
remark  FAMILY "LOG_GROUPS"
remark
create or replace view USER_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then (case bitand(t.trigflag, 512) 
                                  when 512 then 'EXTENDED PRIMARY KEY LOGGING'
                                  else 'PRIMARY KEY LOGGING'
                                  end)
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c, sys.tab$ t
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and o.obj# = t.obj#
  and o.owner# = userenv('SCHEMAID')
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/
comment on table USER_LOG_GROUPS is
'Log group definitions on user''s own tables'
/
comment on column USER_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column USER_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column USER_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant select on USER_LOG_GROUPS to public with grant option
/
create or replace public synonym USER_LOG_GROUPS for USER_LOG_GROUPS
/
create or replace view ALL_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then (case bitand(t.trigflag, 512) 
                                  when 512 then 'EXTENDED PRIMARY KEY LOGGING'
                                  else 'PRIMARY KEY LOGGING'
                                  end)
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c, sys.tab$ t
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and o.obj# = t.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_LOG_GROUPS is
'Log group definitions on accessible tables'
/
comment on column ALL_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column ALL_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column ALL_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant select on ALL_LOG_GROUPS to public with grant option
/
create or replace public synonym ALL_LOG_GROUPS for ALL_LOG_GROUPS
/
create or replace view DBA_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then (case bitand(t.trigflag, 512) 
                                  when 512 then 'EXTENDED PRIMARY KEY LOGGING'
                                  else 'PRIMARY KEY LOGGING'
                                  end)
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc, sys.user$ ou, sys.obj$ o, sys.cdef$ c, sys.tab$ t
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and o.obj# = t.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/

comment on column DBA_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
create or replace public synonym DBA_LOG_GROUPS for DBA_LOG_GROUPS
/
grant select on DBA_LOG_GROUPS to select_catalog_role
/
comment on table DBA_LOG_GROUPS is
'Log group definitions on all tables'
/
comment on column DBA_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column DBA_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column DBA_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/


remark
remark FAMILY CLUSTER_HASH_EXPRESSIONS
remark
create or replace view USER_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   us.user# = userenv('SCHEMAID')
/

comment on table USER_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for the user''s hash clusters'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant select on USER_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym USER_CLUSTER_HASH_EXPRESSIONS for
 USER_CLUSTER_HASH_EXPRESSIONS
/

create or replace view ALL_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   ( us.user# = userenv('SCHEMAID')
        or  /* user has system privilages */
           exists (select null from v$enabledprivs
               where priv_number in (-61 /* CREATE ANY CLUSTER */,
                                     -62 /* ALTER ANY CLUSTER */,
                                     -63 /* DROP ANY CLUSTER */ )
                  )
      )
/

comment on table ALL_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all accessible clusters'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant select on ALL_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym ALL_CLUSTER_HASH_EXPRESSIONS for
 ALL_CLUSTER_HASH_EXPRESSIONS
/

create or replace view DBA_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type# = 8
and c.obj#   = o.obj#
and us.user# = o.owner#
/

comment on table DBA_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all clusters'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Text of hash function of the cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
create or replace public synonym DBA_CLUSTER_HASH_EXPRESSIONS for
 DBA_CLUSTER_HASH_EXPRESSIONS
/
grant select on DBA_CLUSTER_HASH_EXPRESSIONS to select_catalog_role
/

remark
remark  FAMILY "UPDATABLE_COLUMNS"
remark
create or replace view USER_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and u.user# = userenv('SCHEMAID')
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table USER_UPDATABLE_COLUMNS is
'Description of updatable columns'
/
comment on column USER_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column USER_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column USER_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column USER_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column USER_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym USER_UPDATABLE_COLUMNS
   for USER_UPDATABLE_COLUMNS
/
grant select on USER_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where o.owner# = u.user#
  and o.obj#  = c.obj#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
comment on table ALL_UPDATABLE_COLUMNS is
'Description of all updatable columns'
/
comment on column ALL_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column ALL_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column ALL_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column ALL_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column ALL_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym ALL_UPDATABLE_COLUMNS
   for ALL_UPDATABLE_COLUMNS
/
grant select on ALL_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table DBA_UPDATABLE_COLUMNS is
'Description of dba updatable columns'
/
comment on column DBA_UPDATABLE_COLUMNS.OWNER is
'table owner'
/
comment on column DBA_UPDATABLE_COLUMNS.TABLE_NAME is
'table name'
/
comment on column DBA_UPDATABLE_COLUMNS.COLUMN_NAME is
'column name'
/
comment on column DBA_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column DBA_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column DBA_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym DBA_UPDATABLE_COLUMNS
   for DBA_UPDATABLE_COLUMNS
/
grant select on DBA_UPDATABLE_COLUMNS to select_catalog_role
/

remark
remark  FAMILY "UNUSED_COL_TABS"
remark
remark  Views for showing information about tables with unused columns:
remark  USER_UNUSED_COL_TABS, ALL_UNUSED_COL_TABS, and DBA_UNUSED_COL_TABS
remark
create or replace view USER_UNUSED_COL_TABS
    (TABLE_NAME, COUNT)
as
select o.name, count(*)
from sys.col$ c, sys.obj$ o
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(c.property, 32768) = 32768             -- is unused columns
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  group by o.name
/
create or replace public synonym USER_UNUSED_COL_TABS for USER_UNUSED_COL_TABS
/
grant select on USER_UNUSED_COL_TABS to PUBLIC with grant option
/
comment on table USER_UNUSED_COL_TABS is
'User tables with unused columns'
/
Comment on column USER_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column USER_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace view ALL_UNUSED_COL_TABS
    (OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where o.owner# = u.user#
  and o.obj# = c.obj#
  and bitand(c.property,32768) = 32768              -- is unused column
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  group by u.name, o.name
/
comment on table ALL_UNUSED_COL_TABS is
'All tables with unused columns accessible to the user'
/
Comment on column ALL_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column ALL_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym ALL_UNUSED_COL_TABS for ALL_UNUSED_COL_TABS
/
grant select on ALL_UNUSED_COL_TABS to PUBLIC with grant option
/
create or replace view DBA_UNUSED_COL_TABS
(OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where c.obj# = o.obj#
      and bitand(c.property,32768) = 32768          -- is unused column
      and bitand(c.property, 1) != 1                -- not ADT attribute col
      and bitand(c.property, 1024) != 1024          -- not NTAB's setid col
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_UNUSED_COL_TABS is
'All tables with unused columns in the database'
/
Comment on column DBA_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column DBA_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym DBA_UNUSED_COL_TABS for DBA_UNUSED_COL_TABS
/
grant select on DBA_UNUSED_COL_TABS to select_catalog_role
/
remark
remark  FAMILY "PARTIAL_DROP_TABS"
remark
remark  Views for showing tables with partial dropped columns:
remark  USER_PARTIAL_DROP_TABS, ALL_PARTIAL_DROP_TABS, DBA_PARTIAL_DROP_TABS
remark
create or replace view USER_PARTIAL_DROP_TABS
    (TABLE_NAME)
as
select o.name from sys.tab$ t, sys.obj$ o
where o.obj# = t.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(t.flags, 32768) = 32768
/
create or replace public synonym USER_PARTIAL_DROP_TABS
   for USER_PARTIAL_DROP_TABS
/
grant select on USER_PARTIAL_DROP_TABS to PUBLIC with grant option
/
comment on table USER_PARTIAL_DROP_TABS is
'User tables with unused columns'
/
Comment on column USER_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace view ALL_PARTIAL_DROP_TABS
    (OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.flags,32768) = 32768
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  group by u.name, o.name
/
comment on table ALL_PARTIAL_DROP_TABS is
'All tables with patially dropped columns accessible to the user'
/
Comment on column ALL_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym ALL_PARTIAL_DROP_TABS
   for ALL_PARTIAL_DROP_TABS
/
grant select on ALL_PARTIAL_DROP_TABS to PUBLIC with grant option
/
create or replace view DBA_PARTIAL_DROP_TABS
(OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where t.obj# = o.obj#
      and bitand(t.flags,32768) = 32768
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_PARTIAL_DROP_TABS is
'All tables with partially dropped columns in the database'
/
Comment on column DBA_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym DBA_PARTIAL_DROP_TABS
   for DBA_PARTIAL_DROP_TABS
/
grant select on DBA_PARTIAL_DROP_TABS to select_catalog_role
/

create or replace view DATABASE_PROPERTIES
  (PROPERTY_NAME, PROPERTY_VALUE, DESCRIPTION)
as
  select name, value$, comment$
  from props$
/
comment on table DATABASE_PROPERTIES is
'Permanent database properties'
/
comment on column DATABASE_PROPERTIES.PROPERTY_NAME is
'Property name'
/
comment on column DATABASE_PROPERTIES.PROPERTY_VALUE is
'Property value'
/
comment on column DATABASE_PROPERTIES.DESCRIPTION is
'Property description'
/
create or replace public synonym DATABASE_PROPERTIES for DATABASE_PROPERTIES
/
grant select on DATABASE_PROPERTIES to PUBLIC with grant option
/

Rem     GLOBAL DATABASE NAME

create or replace view GLOBAL_NAME ( GLOBAL_NAME ) as
       select value$ from sys.props$ where name = 'GLOBAL_DB_NAME'
/
comment on table GLOBAL_NAME is 'global database name'
/
comment on column GLOBAL_NAME.GLOBAL_NAME is 'global database name'
/
grant select on GLOBAL_NAME to public with grant option
/
create or replace public synonym GLOBAL_NAME for GLOBAL_NAME
/

create or replace view FLASHBACK_TRANSACTION_QUERY
as select xid, start_scn, start_timestamp,
          decode(commit_scn, 0, commit_scn, 281474976710655, NULL, commit_scn)
          commit_scn, commit_timestamp,
          logon_user, undo_change#, operation, table_name, table_owner,
          row_id, undo_sql
from sys.x$ktuqqry
/
comment on table FLASHBACK_TRANSACTION_QUERY is
'Description of the flashback transaction query view'
/
comment on column FLASHBACK_TRANSACTION_QUERY.XID is
'Transaction identifier'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_SCN is
'Transaction start SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_TIMESTAMP is
'Transaction start timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_SCN is
'Transaction commit SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_TIMESTAMP is
'Transaction commit timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.LOGON_USER is
'Logon user for transaction'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_CHANGE# is
'1-based undo change number'
/
comment on column FLASHBACK_TRANSACTION_QUERY.OPERATION is
'forward operation for this undo'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_NAME is
'table name to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_OWNER is
'owner of table to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.ROW_ID is
'rowid to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_SQL is
'SQL corresponding to this undo'
/
create or replace public synonym FLASHBACK_TRANSACTION_QUERY
     for FLASHBACK_TRANSACTION_QUERY
/
grant select on FLASHBACK_TRANSACTION_QUERY to public;
/

remark
remark  FAMILY "RESUMABLE"
remark  Resumable statement related information
remark
create or replace view DBA_RESUMABLE
    (USER_ID, SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID,
     STATUS, TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct S.USER# as USER_ID, R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
/
create or replace public synonym DBA_RESUMABLE for DBA_RESUMABLE
/
grant select on DBA_RESUMABLE to select_catalog_role
/
comment on table DBA_RESUMABLE is
'Resumable session information in the system'
/
comment on column DBA_RESUMABLE.USER_ID is
'User who own this resumable session'
/
comment on column DBA_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column DBA_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column DBA_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column DBA_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column DBA_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column DBA_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column DBA_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column DBA_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column DBA_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column DBA_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_MSG is
'The current error message'
/
create or replace view USER_RESUMABLE
    (SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID, STATUS,
     TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
      and S.USER# = userenv('SCHEMAID')
/
create or replace public synonym USER_RESUMABLE for USER_RESUMABLE
/
grant select on USER_RESUMABLE to public with grant option
/
comment on table USER_RESUMABLE is
'Resumable session information for current user'
/
comment on column USER_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column USER_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column USER_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column USER_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column USER_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column USER_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column USER_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column USER_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column USER_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column USER_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column USER_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column USER_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_MSG is
'The current error message'
/

remark
remark  FAMILY "EDITIONING_VIEWS"
remark  
remark  These views describe relationships between Editioning Views (a.k.a. 
remark  EVs) and their base tables
remark

create or replace view USER_EDITIONING_VIEWS
    (VIEW_NAME, TABLE_NAME)
as
select ev_obj.name, ev.base_tbl_name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.ev$ ev
where 
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV */
       ev_obj.obj# = ev.ev_obj#
       /* ensure that the EV belongs to the current schema */
  and  ev_obj.owner# = userenv('SCHEMAID')
/

comment on table USER_EDITIONING_VIEWS is
'Descriptions of the user''s own Editioning Views'
/
comment on column USER_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/

create or replace public synonym USER_EDITIONING_VIEWS 
  for USER_EDITIONING_VIEWS
/
grant select on USER_EDITIONING_VIEWS to PUBLIC with grant option
/

create or replace view ALL_EDITIONING_VIEWS
    (OWNER, VIEW_NAME, TABLE_NAME)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _CURRENT_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
  and  (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/

comment on table ALL_EDITIONING_VIEWS is
'Description of Editioning Views accessible to the user'
/
comment on column ALL_EDITIONING_VIEWS.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/

create or replace public synonym ALL_EDITIONING_VIEWS for ALL_EDITIONING_VIEWS
/
grant select on ALL_EDITIONING_VIEWS to PUBLIC with grant option
/

create or replace view DBA_EDITIONING_VIEWS
    (OWNER, VIEW_NAME, TABLE_NAME)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _CURRENT_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#
/

comment on table DBA_EDITIONING_VIEWS is
'Description of all Editioning Views in the database'
/
comment on column DBA_EDITIONING_VIEWS.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/

create or replace public synonym DBA_EDITIONING_VIEWS for DBA_EDITIONING_VIEWS
/
grant select on DBA_EDITIONING_VIEWS to select_catalog_role
/

remark
remark  FAMILY "EDITIONING_VIEWS_AE"
remark  
remark  These views describe relationships between Editioning Views (a.k.a. 
remark  EVs) and their base tables in all the editions
remark

create or replace view USER_EDITIONING_VIEWS_AE
    (VIEW_NAME, TABLE_NAME, EDITION_NAME)
as
select ev_obj.name, ev.base_tbl_name, ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.ev$ ev
where 
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV */
       ev_obj.obj# = ev.ev_obj#
       /* ensure that the EV belongs to the current schema */
  and  ev_obj.owner# = userenv('SCHEMAID')
/

comment on table USER_EDITIONING_VIEWS_AE is
'Descriptions of the user''s own Editioning Views'
/
comment on column USER_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column USER_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym USER_EDITIONING_VIEWS_AE 
  for USER_EDITIONING_VIEWS_AE
/
grant select on USER_EDITIONING_VIEWS_AE to PUBLIC with grant option
/

create or replace view ALL_EDITIONING_VIEWS_AE
    (OWNER, VIEW_NAME, TABLE_NAME, EDITION_NAME)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name, ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _ACTUAL_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
  and  (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/

comment on table ALL_EDITIONING_VIEWS_AE is
'Description of Editioning Views accessible to the user'
/
comment on column ALL_EDITIONING_VIEWS_AE.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column ALL_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/


create or replace public synonym ALL_EDITIONING_VIEWS_AE for ALL_EDITIONING_VIEWS_AE
/
grant select on ALL_EDITIONING_VIEWS_AE to PUBLIC with grant option
/

create or replace view DBA_EDITIONING_VIEWS_AE
    (OWNER, VIEW_NAME, TABLE_NAME, EDITION_NAME)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name, ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _ACTUAL_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#
/

comment on table DBA_EDITIONING_VIEWS_AE is
'Description of all Editioning Views in the database'
/
comment on column DBA_EDITIONING_VIEWS_AE.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column DBA_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym DBA_EDITIONING_VIEWS_AE for DBA_EDITIONING_VIEWS_AE
/
grant select on DBA_EDITIONING_VIEWS_AE to select_catalog_role
/

remark
remark  FAMILY "EDITIONING_VIEW_COLS"
remark  
remark  These views describe relationship between columns of Editioning 
remark  Views (a.k.a. EVs) and the table columns to which they map
remark

create or replace view USER_EDITIONING_VIEW_COLS
    (VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME)
as
select ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and ensure that the EV belongs to the current */
       /* schema */
  and  ev_obj.obj# = ev.ev_obj#
  and  ev_obj.owner# = userenv('SCHEMAID')
/

comment on table USER_EDITIONING_VIEW_COLS is
'Relationship between columns of user''s Editioning Views and the table columns to which they map'
/
comment on column USER_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'The name of the column in the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column USER_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

create or replace public synonym USER_EDITIONING_VIEW_COLS for USER_EDITIONING_VIEW_COLS
/
grant select on USER_EDITIONING_VIEW_COLS to PUBLIC with grant option
/

create or replace view ALL_EDITIONING_VIEW_COLS
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _CURRENT_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
   and ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
   and (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/

comment on table ALL_EDITIONING_VIEW_COLS is
'Relationship between columns of Editioning Views accessible to the user and the table columns to which they map'
/
comment on column ALL_EDITIONING_VIEW_COLS.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column ALL_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

create or replace public synonym ALL_EDITIONING_VIEW_COLS for ALL_EDITIONING_VIEW_COLS
/
grant select on ALL_EDITIONING_VIEW_COLS to PUBLIC with grant option
/

create or replace view DBA_EDITIONING_VIEW_COLS
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
from   sys."_CURRENT_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _CURRENT_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _CURRENT_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
   and ev_obj.owner# = ev_user.user#
/

comment on table DBA_EDITIONING_VIEW_COLS is
'Relationship between columns of all Editioning Views in the database and the table columns to which they map'
/
comment on column DBA_EDITIONING_VIEW_COLS.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column DBA_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

create or replace public synonym DBA_EDITIONING_VIEW_COLS for DBA_EDITIONING_VIEW_COLS
/
grant select on DBA_EDITIONING_VIEW_COLS to PUBLIC with grant option
/


remark
remark  FAMILY "EDITIONING_VIEW_COLS_AE"
remark  
remark  These views describe relationship between columns of Editioning 
remark  Views (a.k.a. EVs) and the table columns to which they map in all
remark  editions
remark

create or replace view USER_EDITIONING_VIEW_COLS_AE
    (VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME,
     EDITION_NAME)
as
select ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name,
       ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and ensure that the EV belongs to the current */
       /* schema */
  and  ev_obj.obj# = ev.ev_obj#
  and  ev_obj.owner# = userenv('SCHEMAID')
/

comment on table USER_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of user''s Editioning Views and the table columns to which they map'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'The name of the column in the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym USER_EDITIONING_VIEW_COLS_AE for USER_EDITIONING_VIEW_COLS_AE
/
grant select on USER_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/

create or replace view ALL_EDITIONING_VIEW_COLS_AE
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME,
     EDITION_NAME)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name,
       ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _ACTUAL_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
   and ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
   and (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/

comment on table ALL_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of Editioning Views accessible to the user and the table columns to which they map'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym ALL_EDITIONING_VIEW_COLS_AE for ALL_EDITIONING_VIEW_COLS_AE
/
grant select on ALL_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/

create or replace view DBA_EDITIONING_VIEW_COLS_AE
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME,
     EDITION_NAME)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name,
       ev_obj.defining_edition
from   sys."_ACTUAL_EDITION_OBJ" ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _ACTUAL_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _ACTUAL_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
   and ev_obj.owner# = ev_user.user#
/

comment on table DBA_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of all Editioning Views in the database and the table columns to which they map'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym DBA_EDITIONING_VIEW_COLS_AE for DBA_EDITIONING_VIEW_COLS_AE
/
grant select on DBA_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/


remark
remark  FAMILY "*_EDITIONS"
remark
remark  Describes all editions in the database
remark
create or replace view ALL_EDITIONS
    (EDITION_NAME, PARENT_EDITION_NAME, USABLE)
as
select o.name, po.name, decode(bitand(e.flags,1),1,'NO','YES')
from sys.obj$ o, sys.edition$ e, sys.obj$ po
where o.obj# = e.obj#
  and po.obj# (+)= e.p_obj#
/

comment on table ALL_EDITIONS is
'Describes all editions in the database'
/
comment on column ALL_EDITIONS.EDITION_NAME is
'Name of the edition'
/
comment on column ALL_EDITIONS.PARENT_EDITION_NAME is
'Name of the parent edition for this edition'
/
comment on column ALL_EDITIONS.USABLE is
'A value of ''YES'' means edition is usable and ''NO'' means unusable'
/
grant select on ALL_EDITIONS to public with grant option
/
create or replace public synonym ALL_EDITIONS for ALL_EDITIONS
/

create or replace view DBA_EDITIONS
    (EDITION_NAME, PARENT_EDITION_NAME, USABLE)
as
select o.name, po.name, decode(bitand(e.flags,1),1,'NO','YES')
from sys.obj$ o, sys.edition$ e, sys.obj$ po
where o.obj# = e.obj#
  and po.obj# (+)= e.p_obj#
/

comment on table DBA_EDITIONS is
'Describes all editions in the database'
/
comment on column DBA_EDITIONS.EDITION_NAME is
'Name of the edition'
/
comment on column DBA_EDITIONS.PARENT_EDITION_NAME is
'Name of the parent edition for this edition'
/
comment on column DBA_EDITIONS.USABLE is
'A value of ''YES'' means edition is usable and ''NO'' means unusable'
/
create or replace public synonym DBA_EDITIONS for DBA_EDITIONS
/
grant select on DBA_EDITIONS to select_catalog_role
/


remark
remark  FAMILY "*_EDITION_COMMENTS"
remark
remark Describe comments on all editions in the database
remark

create or replace view ALL_EDITION_COMMENTS
    (EDITION_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj# (+)
  and o.type# = 57
/

comment on table ALL_EDITION_COMMENTS is
'Describes comments on all editions in the database'
/
comment on column ALL_EDITION_COMMENTS.EDITION_NAME is
'Name of the edition'
/
comment on column ALL_EDITION_COMMENTS.COMMENTS is
'Edition comments'
/
grant select on ALL_EDITION_COMMENTS to public with grant option
/
create or replace public synonym ALL_EDITION_COMMENTS for ALL_EDITION_COMMENTS
/

create or replace view DBA_EDITION_COMMENTS
    (EDITION_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj# (+)
  and o.type# = 57
/

comment on table DBA_EDITION_COMMENTS is
'Describes comments on all editions in the database'
/
comment on column DBA_EDITION_COMMENTS.EDITION_NAME is
'Name of the edition'
/
comment on column DBA_EDITION_COMMENTS.COMMENTS is
'Edition comments'
/
create or replace public synonym DBA_EDITION_COMMENTS for DBA_EDITION_COMMENTS
/
grant select on DBA_EDITION_COMMENTS to select_catalog_role
/
