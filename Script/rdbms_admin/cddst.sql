Rem
Rem $Header: rdbms/admin/cddst.sql /st_rdbms_11.2.0/1 2013/03/01 13:53:31 qinkong Exp $
Rem
Rem cddst.sql
Rem
Rem Copyright (c) 2008, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cddst.sql
Rem
Rem    DESCRIPTION
Rem      Creates the data dictionary views for DST patching
Rem
Rem    NOTES
Rem        Must be run while connectd as SYS or INTERNAL
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qinkong     01/28/13 - Backport huagli_bug-13833939 from Main
Rem    qinkong     01/28/13 - Backport huagli_bug-13436809 from Main
Rem    huagli      07/16/09 - remove UPGRADE_ACTIVE column
Rem    awitkows    04/24/09 - improve performance of ALL_TSTZ_TAB_COLS
Rem    awitkows    03/27/08 - correct UPGRADE_IN_PROGRESS
Rem    huagli      01/07/08 - Created
Rem

remark
remark  FAMILY "TSTZ_TAB_COLS"
remark  The columns that make up table objects, which are defined on TIMESTAMP
remark  WITH TIME ZONE data type or ADT type containing attribute(s) of
remark  TIMESTAMP WITH TIME ZONE data type
remark
create or replace view USER_TSTZ_TAB_COLS
    (TABLE_NAME, QUALIFIED_COL_NAME)
as
with va_of_tstz_typ as
(select distinct o.name
 from
    ( select p_obj# obj# from sys.dependency$
      start with p_obj# in (
         select distinct o.obj# 
         from sys.obj$ o, sys.attribute$ a
         where o.oid$ = a.toid
           and a.attr_toid = '0000000000000000000000000000003E'
         union all
         select distinct o.obj# 
         from sys.obj$ o, sys.collection$ c
         where o.oid$ = c.toid 
           and c.elem_toid = '0000000000000000000000000000003E'
       )
      connect by prior d_obj# = p_obj# and bitand(prior property, 1) = 1 
      order siblings by d_obj#, p_obj#
     ) t, sys.obj$ o, sys.coltype$ c
 where t.obj# = o.obj# 
   and o.oid$ = c.toid 
   and bitand(c.flags, 8) = 8
)
select table_name, qualified_col_name
from
   ( select utc.table_name, utc.qualified_col_name, data_type
     from user_tab_cols utc, user_all_tables uat
     where (data_type like 'TIMESTAMP%WITH TIME ZONE' or
            data_type in (select name from va_of_tstz_typ))
       and utc.table_name = uat.table_name
     union all
     select table_name, qualified_col_name, data_type
     from user_nested_table_cols
     where data_type like 'TIMESTAMP%WITH TIME ZONE'
        or data_type in (select name from va_of_tstz_typ)
   )
/
comment on table USER_TSTZ_TAB_COLS is
'Columns of user''s tables, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column USER_TSTZ_TAB_COLS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TSTZ_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym USER_TSTZ_TAB_COLS for USER_TSTZ_TAB_COLS
/
grant select on USER_TSTZ_TAB_COLS to PUBLIC with grant option
/
create or replace view ALL_TSTZ_TAB_COLS
 (owner, table_name, column_name, qualified_col_name, nested, virtual_column)
as
 with rw (p_obj#, d_obj#, property)  as
 (
     select p_obj#, d_obj#, property
     from sys.dependency$
     where p_obj# in
          (
          select distinct o.obj#
          from sys.obj$ o, sys.attribute$ a
          where o.oid$ = a.toid
            and a.attr_toid = '0000000000000000000000000000003E'
          union all
          select distinct o.obj#
          from sys.obj$ o, sys.collection$ c
          where o.oid$ = c.toid
            and c.elem_toid = '0000000000000000000000000000003E'
        )
 union all
     select d.p_obj#, d.d_obj#, d.property
     from rw, sys.dependency$ d
     where rw.d_obj# = d.p_obj# and bitand(rw.property, 1) = 1
 ),
 va_of_tstz_typ (name) as
 (
   select distinct o.name
   from rw, sys.obj$ o, sys.coltype$ c
   where rw.p_obj# = o.obj#
     and o.oid$ = c.toid
     and bitand(c.flags, 8) = 8
 ),
 all_tstz_candiate_tab_cols
     (owner, table_name, table_property, table_nested, column_name, data_type,
     qualified_col_name, virtual_column) as
 (
   select u.name, o.name, t.property,
      case when bitand(t.property, 8192) = 8192 then 1 else 0 end,
      c.name,
      case when c.type# = 181 then
                   'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE'
           when c.type# in (58, 111, 121, 122, 123) then
                   nvl2(ac.synobj#, (select o.name from obj$ o
                                     where o.obj#=ac.synobj#), ot.name)
           else 'UNDEFINED'
      end,
      decode(bitand(c.property, 1024), 1024,
             (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
              from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
              and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
              cl.intcol# = rc.intcol#(+)),
             decode(bitand(c.property, 1), 0, c.name,
                    (select tc.name from sys.attrcol$ tc
                     where c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
      decode(c.property, 0, 0, decode(bitand(c.property, 8), 8, 1, 0))
 from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
      sys.coltype$ ac, sys.obj$ ot, sys.tab$ t
 where o.obj# = c.obj#
   and o.owner# = u.user#
   and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
   and ac.toid = ot.oid$(+)
   and ot.type#(+) = 13
   and o.obj# = t.obj#
   and c.type# in (58, 111, 121, 122, 123, 181)
 )
select owner, table_name, column_name,
       qualified_col_name, table_nested, virtual_column 
from  all_tstz_candiate_tab_cols
    where data_type like 'TIMESTAMP%WITH TIME ZONE'
       or data_type in (select name from va_of_tstz_typ)
/
comment on table ALL_TSTZ_TAB_COLS is
'Columns of user''s tables, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column ALL_TSTZ_TAB_COLS.OWNER is
'Owner of the table'
/
comment on column ALL_TSTZ_TAB_COLS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TSTZ_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TSTZ_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
comment on column ALL_TSTZ_TAB_COLS.NESTED is
'Nested table column?'
/
comment on column ALL_TSTZ_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
create or replace public synonym ALL_TSTZ_TAB_COLS for ALL_TSTZ_TAB_COLS
/
grant select on ALL_TSTZ_TAB_COLS to PUBLIC with grant option
/
create or replace view DBA_TSTZ_TAB_COLS
    (OWNER, TABLE_NAME, QUALIFIED_COL_NAME)
as
with va_of_tstz_typ as
(select distinct o.name
 from
    ( select p_obj# obj# from sys.dependency$
      start with p_obj# in (
         select distinct o.obj# 
         from sys.obj$ o, sys.attribute$ a
         where o.oid$ = a.toid
           and a.attr_toid = '0000000000000000000000000000003E'
         union all
         select distinct o.obj# 
         from sys.obj$ o, sys.collection$ c
         where o.oid$ = c.toid 
           and c.elem_toid = '0000000000000000000000000000003E'
       )
      connect by prior d_obj# = p_obj# and bitand(prior property, 1) = 1 
      order siblings by d_obj#, p_obj#
     ) t, sys.obj$ o, sys.coltype$ c
 where t.obj# = o.obj# 
   and o.oid$ = c.toid 
   and bitand(c.flags, 8) = 8
)
select owner, table_name, qualified_col_name
from
   ( select dtc.owner, dtc.table_name, dtc.qualified_col_name, data_type
     from dba_tab_cols dtc, dba_all_tables dat
     where (data_type like 'TIMESTAMP%WITH TIME ZONE' or
            data_type in (select name from va_of_tstz_typ))
       and dtc.owner = dat.owner 
       and dtc.table_name = dat.table_name
     union all
     select owner, table_name, qualified_col_name, data_type
     from dba_nested_table_cols
     where data_type like 'TIMESTAMP%WITH TIME ZONE' 
        or data_type in (select name from va_of_tstz_typ)
   )
/
comment on table DBA_TSTZ_TAB_COLS is
'Columns of all tables in the database, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column DBA_TSTZ_TAB_COLS.OWNER is
'Owner of the table'
/
comment on column DBA_TSTZ_TAB_COLS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TSTZ_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym DBA_TSTZ_TAB_COLS for DBA_TSTZ_TAB_COLS
/
grant select on DBA_TSTZ_TAB_COLS to select_catalog_role
/

remark
remark  FAMILY "TSTZ_TABLES"
remark  Tables which are defined on TIMESTAMP WITH TIME ZONE data type or
remark  ADT type containing attribute(s) of TIMESTAMP WITH TIME ZONE data type
remark
create or replace view USER_TSTZ_TABLES
    (TABLE_NAME, UPGRADE_IN_PROGRESS)
as
select distinct table_name, 
       decode(bitand(t.property, 137438953472), 137438953472, 'YES', 'NO')
from user_tstz_tab_cols uttc, sys.obj$ o, sys.tab$ t
where uttc.table_name = o.name
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
/
comment on table USER_TSTZ_TABLES is
'Description of the user''s own tables, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column USER_TSTZ_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_TSTZ_TABLES.UPGRADE_IN_PROGRESS is
'Is table upgrade in progress?'
/
create or replace public synonym USER_TSTZ_TABLES for USER_TSTZ_TABLES
/
grant select on USER_TSTZ_TABLES to PUBLIC with grant option
/
create or replace view ALL_TSTZ_TABLES
    (OWNER, TABLE_NAME, UPGRADE_IN_PROGRESS)
as
select /*+ leading(actt, o, u, t) */ attc.owner, attc.table_name, 
       decode(bitand(t.property, 137438953472), 137438953472, 'YES', 'NO')
from (select distinct owner, table_name from all_tstz_tab_cols) attc, sys.obj$ o, sys.user$ u, sys.tab$ t
where attc.table_name = o.name
  and attc.owner = u.name
  and o.owner# = u.user#
  and o.obj# = t.obj#
/
comment on table ALL_TSTZ_TABLES is
'Description of tables accessible to the user, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column ALL_TSTZ_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_TSTZ_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TSTZ_TABLES.UPGRADE_IN_PROGRESS is
'Is table upgrade in progress?'
/
create or replace public synonym ALL_TSTZ_TABLES for ALL_TSTZ_TABLES
/
grant select on ALL_TSTZ_TABLES to PUBLIC with grant option
/
create or replace view DBA_TSTZ_TABLES
    (OWNER, TABLE_NAME, UPGRADE_IN_PROGRESS)
as
select distinct owner, table_name, 
       decode(bitand(t.property, 137438953472), 137438953472, 'YES', 'NO')
from dba_tstz_tab_cols dttc, sys.obj$ o, sys.user$ u, sys.tab$ t
where dttc.table_name = o.name
  and dttc.owner = u.name
  and o.owner# = u.user#
  and o.obj# = t.obj#
/
comment on table DBA_TSTZ_TABLES is
'Description of all tables in the database, which have column(s) defined on timestamp with time zone data type or ADT type containing attribute(s) of timestamp with time zone data type'
/
comment on column DBA_TSTZ_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_TSTZ_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TSTZ_TABLES.UPGRADE_IN_PROGRESS is
'Is table upgrade in progress?'
/
create or replace public synonym DBA_TSTZ_TABLES for DBA_TSTZ_TABLES
/
grant select on DBA_TSTZ_TABLES to PUBLIC with grant option
/
