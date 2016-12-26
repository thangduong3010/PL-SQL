rem 
rem $Header: rdbms/admin/catrpc.sql /st_rdbms_11.2.0/1 2013/04/08 11:46:38 wxli Exp $ 
rem 
Rem  Copyright (c) 1991, 1996, 1997 by Oracle Corporation 
Rem    NAME
Rem      catrpc.sql
Rem    DESCRIPTION
Rem      Creates internal views for RPC. 
Rem      
Rem      These views are needed only for databases with the procedural option
Rem      that are accessed by remote databases
Rem
Rem    NOTES
Rem      Must be run as SYS.
Rem    MODIFIED   (MM/DD/YY)
Rem     apfwkr     03/19/13  - Backport wxli_bug-8359243 from main
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     mramache   11/05/97 -  merge fix for bug #501839 from 8.0.4
Rem     mramache   08/27/97 -  bug #227309
Rem     skaluska   08/13/97 -  Bug 519207 - add property to ora_kglr7_dependenc
Rem     mramache   09/25/96 -  merge bug #398683 - Add obj# to KGLR7_IDL views
Rem     mramache   07/18/96 -  handle table dependencies
Rem     jwijaya    06/14/96 -  check for EXECUTE ANY TYPE
Rem     mmonajje   05/24/96 -  Replace type col name with type#
Rem     asurpur    04/10/96 -  Dictionary Protection Implementation
Rem     gpongrac   04/10/96 -  add fixed package support to dependency view for
Rem     jwijaya    09/26/95 -  mergetrans jwijaya_data_dict_views_for_objects
Rem     jwijaya    09/21/95 -  support ADTs/objects
Rem     mramache   02/17/95 -  merge changes from branch 1.4.720.1
Rem     mramache   02/02/95 -  bug 256246 - tuned ORA_KGLR7_DEPENDENCIES
Rem     jbellemo   12/17/93 -  merge changes from branch 1.3.710.1
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv schemaid
Rem     jwijaya    02/22/93 -  merge changes from branch 1.2.312.1 
Rem     jwijaya    02/12/93 -  heterogeneous/nls rpc bug
Rem     tpystyne   10/28/92 -  use create or replace view 
Rem     glumpkin   10/20/92 -  Renamed from KGLR.SQL 
Rem     jwijaya    09/09/92 -  also select from v$fixed_table 
Rem     jwijaya    07/17/92 -  remove database link owner from name 
Rem     jwijaya    02/20/92 -  v$enabledroles -> x$kzsro 
Rem     jwijaya    10/18/91 -  support portable IDL 
Rem     jwijaya    06/19/91 -         add ORA_KGLR7_DB_LINKS 
Rem     jwijaya    05/09/91 -         Creation 
Rem

create or replace view ORA_KGLR7_OBJECTS
  (OWNER, NAME, LINK_NAME, OWNER_ID, OBJECT_ID, TYPE)
as
select decode(o.linkname, null, u.name, o.remoteowner), o.name, 
       o.linkname, u.user#, o.obj#, o.type#
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and (o.namespace = 1 /* TABLE/PROCEDURE */  
       or
       o.namespace = 2 /* BODY */)
union
select 'SYS', name, null, 0, object_id,
       decode(type, 'TABLE', 2, 'VIEW', 4, 2)
from sys.v$fixed_table
/
grant select on ORA_KGLR7_OBJECTS to select_catalog_role
/

create or replace view ORA_KGLR7_DEPENDENCIES
  (OWNER, NAME, TYPE, PARENT_OWNER, PARENT_NAME, PARENT_TYPE,
   PARENT_LINK_NAME, PARENT_TIMESTAMP, ORDER_NUMBER, OBJ#, PROPERTY)
as
select u.name, o.name, o.type#,
    decode(o2.linkname, null, u2.name, o2.remoteowner), o2.name, o2.type#,
         o2.linkname, d.p_timestamp, d.order#, o.obj#, d.property
from sys.obj$ o, sys.dependency$ d,
     sys.user$ u, sys.obj$ o2, sys.user$ u2
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and o.status = 1 /* VALID/AUTHORIZED WITHOUT ERRORS */
  and (o2.obj# = d.p_obj# and o2.owner# = u2.user# and
       (o2.namespace = 1 /* TABLE/PROCEDURE */
       or
       o2.namespace = 2 /* BODY */))
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or (o.namespace in (1 /* TABLE/PROCEDURE */,
                           2 /* PACKAGE BODY */)
           and (o.type# in (2 /* TABLE */, 4 /* VIEW */, 9 /* PACKAGE */,
                           13 /* TYPE */)
                or
                o.obj# in (select obj# from sys.objauth$
                           where grantee# in (select kzsrorol
                                              from x$kzsro)
                             and privilege# = 12 /* EXECUTE */)
                or
                exists (select null from sys.sysauth$
                        where grantee# in (select kzsrorol
                                           from x$kzsro)
                             and (o.type# in (7 /* PROCEDURE */,
                                             8 /* FUNCTION */,
                                             11 /* PACKAGE BODY */) and
                                  privilege# = -144 /* EXECUTE ANY PROCEDURE */
                                  )))))
union
select u.name, o.name, o.type#, 'SYS', po.name,
      decode(po.type, 'TABLE', 2, 'VIEW', 4, 2),
         null, d.p_timestamp, d.order#, o.obj#, d.property
from sys.obj$ o, sys.v$fixed_table po, sys.dependency$ d,
     sys.user$ u
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and o.status = 1 /* VALID/AUTHORIZED WITHOUT ERRORS */
  and po.object_id = d.p_obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or (o.namespace in (1 /* TABLE/PROCEDURE */,
                           2 /* PACKAGE BODY */)
           and (o.type# in (2 /* TABLE */, 4 /* VIEW */, 9 /* PACKAGE */,
                           13 /* TYPE */)
                or
                o.obj# in (select obj# from sys.objauth$
                           where grantee# in (select kzsrorol
                                              from x$kzsro)
                             and privilege# = 12 /* EXECUTE */)
                or
                exists (select null from sys.sysauth$
                        where grantee# in (select kzsrorol
                                           from x$kzsro)
                             and (o.type# in (7 /* PROCEDURE */,
                                             8 /* FUNCTION */,
                                             11 /* PACKAGE BODY */) and
                                  privilege# = -144 /* EXECUTE ANY PROCEDURE */
                                  )))))
union
select u.name, o.name, o.type#, 'SYS', po.name_kqfp,
         po.type_kqfp, /* Note: currently spec=1 and body=2 */
         null, d.p_timestamp, d.order#, o.obj#, d.property
from sys.obj$ o, sys.x$kqfp po, sys.dependency$ d,
     sys.user$ u
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and o.status = 1 /* VALID/AUTHORIZED WITHOUT ERRORS */
  and po.kobjn_kqfp = d.p_obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or (o.namespace in (1 /* TABLE/PROCEDURE */,
                           2 /* PACKAGE BODY */)
           and (o.type# in (2 /* TABLE */, 4 /* VIEW */, 9 /* PACKAGE */,
                           13 /* TYPE */)
                or
                o.obj# in (select obj# from sys.objauth$
                           where grantee# in (select kzsrorol
                                              from x$kzsro)
                             and privilege# = 12 /* EXECUTE */)
                or
                exists (select null from sys.sysauth$
                        where grantee# in (select kzsrorol
                                           from x$kzsro)
                             and (o.type# in (7 /* PROCEDURE */,
                                             8 /* FUNCTION */,
                                             11 /* PACKAGE BODY */) and
                                  privilege# = -144 /* EXECUTE ANY PROCEDURE */
                                  )))))
/

create or replace public synonym ORA_KGLR7_DEPENDENCIES
   for ORA_KGLR7_DEPENDENCIES
/
grant select on ORA_KGLR7_DEPENDENCIES to PUBLIC with grant option
/

create or replace view ORA_KGLR7_IDL_UB1
  (OWNER, NAME, TYPE, PART, VERSION, PIECE#, LENGTH, PIECE, OBJ#)
as
select /*+ index(i i_idl_ub11) +*/
       o.owner, o.name, o.type, i.part, i.version,
       i.piece#, i.length, i.piece, o.object_id
from sys.ora_kglr7_objects o, sys.idl_ub1$ i
where o.object_id = i.obj#
  and (o.type in (5 /* SYNONYM */, 2 /* TABLE */, 4 /* VIEW */,
                  9 /* PACKAGE */, 13 /* TYPE */)
       and
       (o.owner_id in (userenv('SCHEMAID'), 1 /* PUBLIC */)
        or
        o.object_id in (select obj# from sys.objauth$
                  where grantee# in (select kzsrorol from x$kzsro)
                    and privilege# in (3 /* DELETE */, 6 /* INSERT */,
                                       7 /* LOCK */, 9 /* SELECT */,
                                       10 /* UPDATE */,
                                       12 /* EXECUTE */))
        or
        exists (select null from sys.sysauth$
               where grantee# in (select kzsrorol from x$kzsro)
                 and (o.type in (7 /* PROCEDURE */, 8 /* FUNCTION */,
                                 11 /* PACKAGE BODY */)
                                 and
                      privilege# = -144 /* EXECUTE ANY PROCEDURE */
                      or
                      o.type = 6 /* SEQUENCE */ and
                      privilege# = -109 /* SELECT ANY SEQUENCE */))))
/
create or replace public synonym ORA_KGLR7_IDL_UB1 for ORA_KGLR7_IDL_UB1
/
grant select on ORA_KGLR7_IDL_UB1 to PUBLIC with grant option
/

create or replace view ORA_KGLR7_IDL_CHAR
  (OWNER, NAME, TYPE, PART, VERSION, PIECE#, LENGTH, PIECE, OBJ#)
as
select /*+ index(i i_idl_char1) +*/
       o.owner, o.name, o.type, i.part, i.version,
       i.piece#, i.length, i.piece, o.object_id
from sys.ora_kglr7_objects o, sys.idl_char$ i
where o.object_id = i.obj#
  and (o.type in (5 /* SYNONYM */, 2 /* TABLE */, 4 /* VIEW */,
                  9 /* PACKAGE */, 13 /* TYPE */)
       and
       (o.owner_id in (userenv('SCHEMAID'), 1 /* PUBLIC */)
        or
        o.object_id in (select obj# from sys.objauth$
                  where grantee# in (select kzsrorol from x$kzsro)
                    and privilege# in (3 /* DELETE */, 6 /* INSERT */,
                                       7 /* LOCK */, 9 /* SELECT */,
                                       10 /* UPDATE */,
                                       12 /* EXECUTE */))
        or
        exists (select null from sys.sysauth$
               where grantee# in (select kzsrorol from x$kzsro)
                 and (o.type in (7 /* PROCEDURE */, 8 /* FUNCTION */,
                                 11 /* PACKAGE BODY */)
                                 and
                      privilege# = -144 /* EXECUTE ANY PROCEDURE */
                      or
                      o.type = 6 /* SEQUENCE */ and
                      privilege# = -109 /* SELECT ANY SEQUENCE */))))
/
create or replace public synonym ORA_KGLR7_IDL_CHAR for ORA_KGLR7_IDL_CHAR
/
grant select on ORA_KGLR7_IDL_CHAR to PUBLIC with grant option
/

create or replace view ORA_KGLR7_IDL_UB2
  (OWNER, NAME, TYPE, PART, VERSION, PIECE#, LENGTH, PIECE, OBJ#)
as
select /*+ index(i i_idl_ub21) +*/
       o.owner, o.name, o.type, i.part, i.version,
       i.piece#, i.length, i.piece, o.object_id
from sys.ora_kglr7_objects o, sys.idl_ub2$ i
where o.object_id = i.obj#
  and (o.type in (5 /* SYNONYM */, 2 /* TABLE */, 4 /* VIEW */,
                  9 /* PACKAGE */, 13 /* TYPE */)
       and
       (o.owner_id in (userenv('SCHEMAID'), 1 /* PUBLIC */)
        or
        o.object_id in (select obj# from sys.objauth$
                  where grantee# in (select kzsrorol from x$kzsro)
                    and privilege# in (3 /* DELETE */, 6 /* INSERT */,
                                       7 /* LOCK */, 9 /* SELECT */,
                                       10 /* UPDATE */,
                                       12 /* EXECUTE */))
        or
        exists (select null from sys.sysauth$
               where grantee# in (select kzsrorol from x$kzsro)
                 and (o.type in (7 /* PROCEDURE */, 8 /* FUNCTION */,
                                 11 /* PACKAGE BODY */)
                                 and
                      privilege# = -144 /* EXECUTE ANY PROCEDURE */
                      or
                      o.type = 6 /* SEQUENCE */ and
                      privilege# = -109 /* SELECT ANY SEQUENCE */))))
/
create or replace public synonym ORA_KGLR7_IDL_UB2 for ORA_KGLR7_IDL_UB2
/
grant select on ORA_KGLR7_IDL_UB2 to PUBLIC with grant option
/

create or replace view ORA_KGLR7_IDL_SB4
  (OWNER, NAME, TYPE, PART, VERSION, PIECE#, LENGTH, PIECE, OBJ#)
as
select /*+ index(i i_idl_sb41) +*/
       o.owner, o.name, o.type, i.part, i.version,
       i.piece#, i.length, i.piece, o.object_id
from sys.ora_kglr7_objects o, sys.idl_sb4$ i
where o.object_id = i.obj#
  and (o.type in (5 /* SYNONYM */, 2 /* TABLE */, 4 /* VIEW */,
                  9 /* PACKAGE */, 13 /* TYPE */)
       and
       (o.owner_id in (userenv('SCHEMAID'), 1 /* PUBLIC */)
        or
        o.object_id in (select obj# from sys.objauth$
                  where grantee# in (select kzsrorol from x$kzsro)
                    and privilege# in (3 /* DELETE */, 6 /* INSERT */,
                                       7 /* LOCK */, 9 /* SELECT */,
                                       10 /* UPDATE */,
                                       12 /* EXECUTE */))
        or
        exists (select null from sys.sysauth$
               where grantee# in (select kzsrorol from x$kzsro)
                 and (o.type in (7 /* PROCEDURE */, 8 /* FUNCTION */,
                                 11 /* PACKAGE BODY */)
                                 and
                      privilege# = -144 /* EXECUTE ANY PROCEDURE */
                      or
                      o.type = 6 /* SEQUENCE */ and
                      privilege# = -109 /* SELECT ANY SEQUENCE */))))
/
create or replace public synonym ORA_KGLR7_IDL_SB4 for ORA_KGLR7_IDL_SB4
/
grant select on ORA_KGLR7_IDL_SB4 to PUBLIC with grant option
/
create or replace view ORA_KGLR7_DB_LINKS
  (OWNER, NAME, USERNAME)
as
select u.name, l.name, l.userid
from sys.link$ l, sys.user$ u
where l.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
  and l.owner# = u.user#
/
create or replace public synonym ORA_KGLR7_DB_LINKS for ORA_KGLR7_DB_LINKS
/
grant select on ORA_KGLR7_DB_LINKS to PUBLIC with grant option
/


