Rem
Rem $Header: cdsqlddl.sql 18-may-2006.15:51:54 achoi Exp $
Rem
Rem cdsqlddl.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdsqlddl.sql - Catalog DSQLDDL.bsq views
Rem
Rem    DESCRIPTION
Rem      database links, dictionary, recyclebin objects, etc
Rem
Rem    NOTES
Rem      This script contains Catalog Views for objects in dsqlddl.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

remark
remark  FAMILY "DB_LINKS"
remark  All relevant information about database links.
remark
create or replace view USER_DB_LINKS
    (DB_LINK, USERNAME, PASSWORD, HOST, CREATED)
as
select l.name, l.userid, l.password, l.host, l.ctime
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_DB_LINKS is
'Database links owned by the user'
/
comment on column USER_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column USER_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column USER_DB_LINKS.PASSWORD is
'Deprecated-Password for logon'
/
comment on column USER_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column USER_DB_LINKS.CREATED is
'Creation time of the database link'
/
create or replace public synonym USER_DB_LINKS for USER_DB_LINKS
/
grant select on USER_DB_LINKS to PUBLIC with grant option
/
create or replace view ALL_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED)
as
select u.name, l.name, l.userid, l.host, l.ctime
from sys.link$ l, sys.user$ u
where l.owner# in ( select kzsrorol from x$kzsro )
  and l.owner# = u.user#
/
comment on table ALL_DB_LINKS is
'Database links accessible to the user'
/
comment on column ALL_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column ALL_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column ALL_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column ALL_DB_LINKS.CREATED is
'Creation time of the database link'
/
create or replace public synonym ALL_DB_LINKS for ALL_DB_LINKS
/
grant select on ALL_DB_LINKS to PUBLIC with grant option
/
create or replace view DBA_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED)
as
select u.name, l.name, l.userid, l.host, l.ctime
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_DB_LINKS for DBA_DB_LINKS
/
grant select on DBA_DB_LINKS to select_catalog_role
/
comment on table DBA_DB_LINKS is
'All database links in the database'
/
comment on column DBA_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column DBA_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column DBA_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column DBA_DB_LINKS.CREATED is
'Creation time of the database link'
/


remark
remark  VIEW "DICTIONARY"
remark  Online documentation for data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the names of public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the short-hand synonyms we have created.
*/
create or replace view DICTIONARY
    (TABLE_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and c.col# is null
  and o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or (o.name like 'DBA%'
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */)
           )
      )
union all
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and o.owner# = 0
  and o.name in ('AUDIT_ACTIONS', 'COLUMN_PRIVILEGES', 'DICTIONARY',
        'DICT_COLUMNS', 'DUAL', 'GLOBAL_NAME', 'INDEX_HISTOGRAM',
        'INDEX_STATS', 'RESOURCE_COST', 'ROLE_ROLE_PRIVS', 'ROLE_SYS_PRIVS',
        'ROLE_TAB_PRIVS', 'SESSION_PRIVS', 'SESSION_ROLES',
        'TABLE_PRIVILEGES','NLS_SESSION_PARAMETERS','NLS_INSTANCE_PARAMETERS',
        'NLS_DATABASE_PARAMETERS', 'DATABASE_COMPATIBLE_LEVEL',
        'DBMS_ALERT_INFO', 'DBMS_LOCK_ALLOCATED')
  and c.col# is null
union all
select so.name, 'Synonym for ' || sy.name
from sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and ro.linkname is null
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and (ro.owner# = userenv('SCHEMAID')
       or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  ))
/
comment on table DICTIONARY is
'Description of data dictionary tables and views'
/
comment on column DICTIONARY.TABLE_NAME is
'Name of the object'
/
comment on column DICTIONARY.COMMENTS is
'Text comment on the object'
/

create or replace public synonym DICTIONARY for DICTIONARY
/
create or replace public synonym DICT for DICTIONARY
/
grant select on DICTIONARY to PUBLIC with grant option
/
remark
remark  VIEW "DICT_COLUMNS"
remark  Online documentation for columns in data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the column comments for public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the columns of the short-hand synonyms we have created.
*/
create or replace view DICT_COLUMNS
    (TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or (o.name like 'DBA%'
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */)
           )
      )
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.name in ('AUDIT_ACTIONS','DUAL','DICTIONARY', 'DICT_COLUMNS')
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select so.name, c.name, co.comment$
from sys.com$ co,sys.col$ c, sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and ro.obj# = c.obj#
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and c.obj# = co.obj#(+)
/
comment on table DICT_COLUMNS is
'Description of columns in data dictionary tables and views'
/
comment on column DICT_COLUMNS.TABLE_NAME is
'Name of the object that contains the column'
/
comment on column DICT_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DICT_COLUMNS.COMMENTS is
'Text comment on the object'
/
create or replace public synonym DICT_COLUMNS for DICT_COLUMNS
/
grant select on DICT_COLUMNS to PUBLIC with grant option
/


Rem
Rem Trusted Servers View
Rem
create or replace view TRUSTED_SERVERS(TRUST, NAME)
as
select a.trust, b.dbname from sys.trusted_list$ b,
(select decode (dbname, '+*','Untrusted', '-*', 'Trusted') trust
from sys.trusted_list$ where dbname like '%*') a
where b.dbname not like '%*'
union
select decode (dbname, '-*', 'Untrusted', '+*', 'Trusted') trust, 'All'
from sys.trusted_list$
where dbname like '%*'
/
create or replace public synonym TRUSTED_SERVERS for TRUSTED_SERVERS
/
grant select on TRUSTED_SERVERS to select_catalog_role
/
comment on table TRUSTED_SERVERS is
'Trustedness of Servers'
/
comment on column TRUSTED_SERVERS.TRUST is
'Trustedness of the server listed. Unlisted servers have opposite trustedness.'
/
comment on column TRUSTED_SERVERS.NAME is
'Server name'
/


remark
remark  FAMILY "RECYCLEBIN"
remark  List of objects in recycle bin
remark
create or replace view USER_RECYCLEBIN
    (OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys."_CURRENT_EDITION_OBJ" o, sys.recyclebin$ r, sys.ts$ t
where r.owner# = userenv('SCHEMAID')
  and o.obj# = r.obj#
  and r.ts# = t.ts#(+)
/
comment on table USER_RECYCLEBIN is
'User view of his recyclebin'
/
comment on column USER_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column USER_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column USER_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column USER_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column USER_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column USER_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column USER_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column USER_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column USER_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column USER_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.CAN_PURGE is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column USER_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column USER_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column USER_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym USER_RECYCLEBIN for USER_RECYCLEBIN
/
create or replace public synonym RECYCLEBIN for USER_RECYCLEBIN
/
grant select on USER_RECYCLEBIN to PUBLIC with grant option
/

create or replace view DBA_RECYCLEBIN
    (OWNER, OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select u.name, o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys."_CURRENT_EDITION_OBJ" o, sys.recyclebin$ r, sys.user$ u, sys.ts$ t
where o.obj# = r.obj#
  and r.owner# = u.user#
  and r.ts# = t.ts#(+)
/
comment on table DBA_RECYCLEBIN is
'Description of the Recyclebin view accessible to the user'
/
comment on column DBA_RECYCLEBIN.OWNER is
'Name of the original owner of the object'
/
comment on column DBA_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column DBA_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column DBA_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column DBA_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column DBA_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column DBA_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column DBA_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column DBA_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column DBA_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column DBA_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column DBA_RECYCLEBIN.CAN_PURGE is
'User can purge this object'
/
comment on column DBA_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column DBA_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column DBA_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column DBA_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym DBA_RECYCLEBIN for DBA_RECYCLEBIN
/
grant select on DBA_RECYCLEBIN to select_catalog_role
/
