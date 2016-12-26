Rem
Rem $Header: rdbms/admin/cdobj.sql /main/9 2010/03/27 23:05:32 ruparame Exp $
Rem
Rem cdobj.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdobj.sql - Catalog DOBJ.bsq views
Rem
Rem    DESCRIPTION
Rem      Nested tables, directories, operators, types, etc.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dobj.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ruparame    03/16/10 - Bug 9192024 Add SYS_OP_DV_CHECK
Rem    schakrab    01/11/10 - #9138524: skip dropped tables in *_nested_tables
Rem    spsundar    12/10/07 - support for all partn methods by indextypes
Rem    spsundar    12/10/07 - support for all partn methods by indextypes
Rem    achoi       06/28/06 - support application edition 
Rem    cdilling    08/03/06 - add catadt.sql
Rem    yhu         08/04/06 - add MAINTENANCE_TYPE in *_INDEXTYPES
Rem    yhu         06/01/06 - add SECONDARY_OBJDATA_TYPE 
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

Rem Object views
@@catadt

remark
remark  FAMILY "_NESTED_TABLE_COLS"
remark  The columns of the nested table's storage tables
remark
create or replace view USER_NESTED_TABLE_COLS
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
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
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
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.coltype$ ac, sys.obj$ ot,
     sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192           /* nested tables */
/
comment on table USER_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column USER_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column USER_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column USER_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column USER_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column USER_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column USER_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column USER_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym USER_NESTED_TABLE_COLS for USER_NESTED_TABLE_COLS
/
grant select on USER_NESTED_TABLE_COLS to PUBLIC with grant option
/
create or replace view ALL_NESTED_TABLE_COLS
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
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
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
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192        /* nested tables */
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
comment on table ALL_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column ALL_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column ALL_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column ALL_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column ALL_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column ALL_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column ALL_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym ALL_NESTED_TABLE_COLS for ALL_NESTED_TABLE_COLS
/
grant select on ALL_NESTED_TABLE_COLS to PUBLIC with grant option
/
create or replace view DBA_NESTED_TABLE_COLS
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
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
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
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192            /* nested tables */
/
comment on table DBA_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column DBA_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column DBA_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column DBA_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column DBA_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column DBA_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column DBA_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym DBA_NESTED_TABLE_COLS for DBA_NESTED_TABLE_COLS
/
grant select on DBA_NESTED_TABLE_COLS to select_catalog_role
/

remark
remark  FAMILY "DIRECTORIES"
remark
remark  Views for showing information about directories:
remark  ALL_DIRECTORIES and DBA_DIRECTORIES
remark
create or replace view ALL_DIRECTORIES
       (OWNER, DIRECTORY_NAME, DIRECTORY_PATH)
as
select u.name, o.name, d.os_path
from sys.user$ u, sys.obj$ o, sys.dir$ d
where u.user# = o.owner#
  and o.obj# = d.obj#
  and ( o.owner# =  userenv('SCHEMAID')
        or o.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol
                               from x$kzsro
                              )
           )
        or exists (select null from v$enabledprivs
                   where priv_number in (-177, /* CREATE ANY DIRECTORY */
                                         -178  /* DROP ANY DIRECTORY */)
                  )
      )
/
comment on table ALL_DIRECTORIES is
'Description of all directories accessible to the user'
/
comment on column ALL_DIRECTORIES.OWNER is
'Owner of the directory (always SYS)'
/
comment on column ALL_DIRECTORIES.DIRECTORY_NAME is
'Name of the directory'
/
comment on column ALL_DIRECTORIES.DIRECTORY_PATH is
'Operating system pathname for the directory'
/
create or replace public synonym ALL_DIRECTORIES for ALL_DIRECTORIES
/
grant select on ALL_DIRECTORIES to PUBLIC with grant option
/
create or replace view DBA_DIRECTORIES
       (OWNER, DIRECTORY_NAME, DIRECTORY_PATH)
as
select u.name, o.name, d.os_path
from sys.user$ u, sys.obj$ o, sys.dir$ d
where u.user# = o.owner#
  and o.obj# = d.obj#
/
comment on table DBA_DIRECTORIES is
'Description of all directories'
/
comment on column DBA_DIRECTORIES.OWNER is
'Owner of the directory (always SYS)'
/
comment on column DBA_DIRECTORIES.DIRECTORY_NAME is
'Name of the directory'
/
comment on column DBA_DIRECTORIES.DIRECTORY_PATH is
'Operating system pathname for the directory'
/
create or replace public synonym DBA_DIRECTORIES for DBA_DIRECTORIES
/
grant select on DBA_DIRECTORIES to select_catalog_role
/

remark
remark  FAMILY "REFS"
remark
remark  Views for showing information about REFs:
remark  USER_REFS, ALL_REFS, and DBA_REFS
remark
create or replace view USER_REFS
    (TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.obj$ o, sys.col$ c, sys.refcon$ rc, sys.obj$ so, sys.user$ su,
     sys.attrcol$ ac
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
/

comment on table USER_REFS is
'Description of the user''s own REF columns contained in the user''s own tables'
/
comment on column USER_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column USER_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column USER_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column USER_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column USER_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column USER_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system generated OID, then SYSTEM GENERATED'
/
create or replace public synonym USER_REFS for USER_REFS
/
grant select on USER_REFS to PUBLIC with grant option
/
create or replace view ALL_REFS
    (OWNER, TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.refcon$ rc, sys.obj$ so,
     sys.user$ su, sys.attrcol$ ac
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
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
/
comment on table ALL_REFS is
'Description of REF columns contained in tables accessible to the user'
/
comment on column ALL_REFS.OWNER is
'Owner of the table containing the REF column'
/
comment on column ALL_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column ALL_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column ALL_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column ALL_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column ALL_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column ALL_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system
 generated OID, then SYSTEM GENERATED'
/
create or replace public synonym ALL_REFS for ALL_REFS
/
grant select on ALL_REFS to PUBLIC with grant option
/
create or replace view DBA_REFS
    (OWNER, TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.obj$ o, sys.col$ c, sys.user$ u, sys.refcon$ rc, sys.obj$ so,
     sys.user$ su, sys.attrcol$ ac
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
/
comment on table DBA_REFS is
'Description of REF columns contained in all tables'
/
comment on column DBA_REFS.OWNER is
'Owner of the table containing the REF column'
/
comment on column DBA_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column DBA_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column DBA_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column DBA_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column DBA_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column DBA_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system
 generated OID, then SYSTEM GENERATED'
/
create or replace public synonym DBA_REFS for DBA_REFS
/
grant select on DBA_REFS to select_catalog_role
/

REM
REM  NESTED TABLES:
REM  Views for showing information about nested tables
REM
create or replace view USER_NESTED_TABLES
    (TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys."_BASE_USER" ut,
  sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and op.owner# = userenv('SCHEMAID')
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
union all
select o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys."_BASE_USER" ut,
  sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and op.owner# = userenv('SCHEMAID')
  and  n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
/
create or replace public synonym USER_NESTED_TABLES for USER_NESTED_TABLES
/
grant select on USER_NESTED_TABLES to PUBLIC with grant option
/
comment on table USER_NESTED_TABLES is
'Description of nested tables contained in the user''s own tables'
/
comment on column USER_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column USER_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column USER_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column USER_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column USER_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column USER_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/

create or replace view ALL_NESTED_TABLES
    (OWNER, TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op, 
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
union all
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c,  sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
create or replace public synonym ALL_NESTED_TABLES for ALL_NESTED_TABLES
/
grant select on ALL_NESTED_TABLES to PUBLIC with grant option
/
comment on table ALL_NESTED_TABLES is
'Description of nested tables in tables accessible to the user'
/
comment on column ALL_NESTED_TABLES.OWNER is
'Owner of the nested table'
/
comment on column ALL_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column ALL_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column ALL_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column ALL_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column ALL_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column ALL_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/

create or replace view DBA_NESTED_TABLES
    (OWNER, TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
union all
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and bitand(o.flags,128) = 0                     /* not in recycle bin */
/
create or replace public synonym DBA_NESTED_TABLES for DBA_NESTED_TABLES
/
grant select on DBA_NESTED_TABLES to select_catalog_role
/
comment on table DBA_NESTED_TABLES is
'Description of nested tables contained in all tables'
/
comment on column DBA_NESTED_TABLES.OWNER is
'Owner of the nested table'
/
comment on column DBA_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column DBA_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column DBA_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column DBA_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column DBA_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column DBA_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/



REM
REM  VARRAYS:
REM  Views for showing information about varrays
REM
create or replace view USER_VARRAYS
    (PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select distinct op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where op.owner# = userenv('SCHEMAID')
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol# = c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8) = 8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select distinct op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8) = 8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where op.owner# = userenv('SCHEMAID')
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol# = c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys."_BASE_USER" ut,
  sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym USER_VARRAYS for USER_VARRAYS
/
grant select on USER_VARRAYS to PUBLIC with grant option
/
comment on table USER_VARRAYS is
'Description of varrays contained in the user''s own tables'
/
comment on column USER_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column USER_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column USER_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column USER_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column USER_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column USER_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column USER_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column USER_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

create or replace view ALL_VARRAYS
    (OWNER, PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct,
  sys.user$ u, sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
union all
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u, sys."_BASE_USER" ut,
  sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct,
  sys.user$ u, sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u, sys."_BASE_USER" ut,
  sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
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
create or replace public synonym ALL_VARRAYS for ALL_VARRAYS
/
grant select on ALL_VARRAYS to PUBLIC with grant option
/
comment on table ALL_VARRAYS is
'Description of varrays in tables accessible to the user'
/
comment on column ALL_VARRAYS.OWNER is
'Owner of the varray'
/
comment on column ALL_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column ALL_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column ALL_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column ALL_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column ALL_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column ALL_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column ALL_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column ALL_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

create or replace view DBA_VARRAYS
    (OWNER, PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct,
  sys.user$ u, sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys."_CURRENT_EDITION_OBJ" op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct,
  sys.user$ u, sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from "_BASE_USER" u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o where o.obj#=ct.synobj#),
            ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" op,
  sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys."_BASE_USER" ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym DBA_VARRAYS for DBA_VARRAYS
/
grant select on DBA_VARRAYS to select_catalog_role
/
comment on table DBA_VARRAYS is
'Description of varrays in tables accessible to the user'
/
comment on column DBA_VARRAYS.OWNER is
'Owner of the varray'
/
comment on column DBA_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column DBA_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column DBA_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column DBA_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column DBA_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column DBA_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column DBA_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column DBA_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

REM
REM Object Columns and Attributes
REM
create or replace view USER_OBJ_COLATTRS
    (TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select o.name, c.name, lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.col$ c
where o.owner# = userenv('SCHEMAID')
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
union all
select o.name, ac.name, lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac, col$ c
where o.owner# = userenv('SCHEMAID')
  and bitand(ct.flags, 2) = 2                                  /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
/
create or replace public synonym USER_OBJ_COLATTRS for USER_OBJ_COLATTRS
/
grant select on USER_OBJ_COLATTRS to PUBLIC with grant option
/
comment on table USER_OBJ_COLATTRS is
'Description of object columns and attributes contained in tables owned by the user'
/
comment on column USER_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column USER_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column USER_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

create or replace view ALL_OBJ_COLATTRS
    (OWNER, TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select u.name, o.name, c.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.user$ u
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
  and not exists (select null                   /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
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
union all
select u.name, o.name, ac.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac,
     sys.user$ u, col$ c
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768               /* not unused column */
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
create or replace public synonym ALL_OBJ_COLATTRS for ALL_OBJ_COLATTRS
/
grant select on ALL_OBJ_COLATTRS to PUBLIC with grant option
/
comment on table ALL_OBJ_COLATTRS is
'Description of object columns and attributes contained in the tables accessible to the user'
/
comment on column ALL_OBJ_COLATTRS.OWNER is
'Owner of the table'
/
comment on column ALL_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column ALL_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column ALL_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

create or replace view DBA_OBJ_COLATTRS
    (OWNER, TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select u.name, o.name, c.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.user$ u
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
  and not exists (select null                   /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
union all
select u.name, o.name, ac.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac,
     sys.user$ u, col$ c
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym DBA_OBJ_COLATTRS for DBA_OBJ_COLATTRS
/
grant select on DBA_OBJ_COLATTRS to select_catalog_role
/
comment on table DBA_OBJ_COLATTRS is
'Description of object columns and attributes contained in all tables in the database'
/
comment on column DBA_OBJ_COLATTRS.OWNER is
'Owner of the table'
/
comment on column DBA_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column DBA_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column DBA_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

Rem
Rem Constrained substitutability info
Rem
create or replace view USER_CONS_OBJ_COLUMNS
    (TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME, CONS_TYPE_ONLY)
as
select oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut, sys.obj$ ot,
     sys.subcoltype$ sc
where oc.owner# = userenv('SCHEMAID')
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
union all
select oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut, sys.obj$ ot,
     sys.subcoltype$ sc, sys.attrcol$ ac
where oc.owner# = userenv('SCHEMAID')
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym USER_CONS_OBJ_COLUMNS for USER_CONS_OBJ_COLUMNS
/
grant select on USER_CONS_OBJ_COLUMNS to PUBLIC with grant option
/
comment on table USER_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in the tables owned by the user'
/
comment on column USER_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column USER_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

create or replace view ALL_CONS_OBJ_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME,
     CONS_TYPE_ONLY)
as
select uc.name, oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut,
     sys.obj$ ot, sys.subcoltype$ sc
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
  and (oc.owner# = userenv('SCHEMAID')
       or oc.obj# in
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
union all
select uc.name, oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut,
     sys.obj$ ot, sys.subcoltype$ sc, sys.attrcol$ ac
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and (oc.owner# = userenv('SCHEMAID')
       or oc.obj# in
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
create or replace public synonym ALL_CONS_OBJ_COLUMNS for ALL_CONS_OBJ_COLUMNS
/
grant select on ALL_CONS_OBJ_COLUMNS to PUBLIC with grant option
/
comment on table ALL_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in the tables accessible to the user'
/
comment on column ALL_CONS_OBJ_COLUMNS.OWNER is
'Owner of the table'
/
comment on column ALL_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column ALL_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

create or replace view DBA_CONS_OBJ_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME,
     CONS_TYPE_ONLY)
as
select uc.name, oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut,
     sys.obj$ ot, sys.subcoltype$ sc
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
union all
select uc.name, oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys."_CURRENT_EDITION_OBJ" oc, sys.col$ c, sys."_BASE_USER" ut,
     sys.obj$ ot, sys.subcoltype$ sc, sys.attrcol$ ac
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym DBA_CONS_OBJ_COLUMNS for DBA_CONS_OBJ_COLUMNS
/
grant select on DBA_CONS_OBJ_COLUMNS to select_catalog_role
/
comment on table DBA_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in all tables in the database'
/
comment on column DBA_CONS_OBJ_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column DBA_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

create or replace view DBA_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPERATORS for DBA_OPERATORS
/
grant select on DBA_OPERATORS to select_catalog_role
/
comment on table DBA_OPERATORS is
'All operators'
/
comment on column DBA_OPERATORS.OWNER is
'Owner of the operator'
/
comment on column DBA_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
comment on column DBA_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view ALL_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user# and
  ( b.owner# = userenv ('SCHEMAID')
    or
    b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPERATORS for ALL_OPERATORS
/
grant select on ALL_OPERATORS to PUBLIC with grant option
/
Comment on table ALL_OPERATORS is
'All operators available to the user'
/
Comment on column ALL_OPERATORS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view USER_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user# and
  b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPERATORS for USER_OPERATORS
/
grant select on USER_OPERATORS to PUBLIC with grant option
/
Comment on table USER_OPERATORS is
'All user operators'
/
Comment on column USER_OPERATORS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view DBA_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select c.name, b.name, a.bind#, a.functionname, a.returnschema,
        a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO' ,
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
  from  sys.opbinding$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPBINDINGS for DBA_OPBINDINGS
/
grant select on DBA_OPBINDINGS to select_catalog_role
/
Comment on table DBA_OPBINDINGS is
'All operator binding functiosn or methods'
/
Comment on column DBA_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column DBA_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column DBA_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column DBA_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column DBA_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column DBA_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column DBA_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column DBA_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column DBA_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view USER_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select  c.name, b.name, a.bind#, a.functionname, a.returnschema,
        a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO',
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
  from  sys.opbinding$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPBINDINGS for USER_OPBINDINGS
/
grant select on USER_OPBINDINGS to PUBLIC with grant option
/
Comment on table USER_OPBINDINGS is
'All binding functions or methods on operators defined by the user'
/
Comment on column USER_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column USER_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column USER_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column USER_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column USER_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column USER_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column USER_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view ALL_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select   c.name, b.name, a.bind#, a.functionname, a.returnschema,
         a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO' ,
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
   from  sys.opbinding$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user#
  and ( b.owner# = userenv ('SCHEMAID')
    or
    b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPBINDINGS for ALL_OPBINDINGS
/
grant select on ALL_OPBINDINGS to PUBLIC with grant option
/
Comment on table ALL_OPBINDINGS is
'All binding functions for operators available to the user'
/
Comment on column ALL_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column ALL_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column ALL_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column ALL_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column ALL_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column ALL_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column ALL_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view DBA_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#  AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
/
create or replace public synonym DBA_OPANCILLARY for DBA_OPANCILLARY
/
grant select on DBA_OPANCILLARY to select_catalog_role
/
Comment on table DBA_OPANCILLARY is
'All ancillary operators'
/
Comment on column DBA_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column DBA_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column DBA_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view USER_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#   AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
       and o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_OPANCILLARY for USER_OPANCILLARY
/
grant select on USER_OPANCILLARY to PUBLIC with grant option
/
Comment on table USER_OPANCILLARY is
'All ancillary opertors defined by user'
/
Comment on column USER_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column USER_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column USER_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view ALL_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#   AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
  and ( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPANCILLARY for ALL_OPANCILLARY
/
grant select on ALL_OPANCILLARY to PUBLIC with grant option
/
Comment on table ALL_OPANCILLARY is
'All ancillary operators available to the user'
/
Comment on column ALL_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column ALL_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column ALL_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view DBA_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPARGUMENTS for DBA_OPARGUMENTS
/
grant select on DBA_OPARGUMENTS to select_catalog_role
/
Comment on table DBA_OPARGUMENTS is
'All operator arguments'
/
Comment on column DBA_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column DBA_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column DBA_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column DBA_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column DBA_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view USER_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and   b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPARGUMENTS for USER_OPARGUMENTS
/
grant select on USER_OPARGUMENTS to PUBLIC with grant option
/
Comment on table USER_OPARGUMENTS is
'All operator arguments of operators defined by user'
/
Comment on column USER_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column USER_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column USER_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view ALL_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and  (b.owner# = userenv ('SCHEMAID')
        or
        b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
           or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPARGUMENTS for ALL_OPARGUMENTS
/
grant select on ALL_OPARGUMENTS to PUBLIC with grant option
/
Comment on table ALL_OPARGUMENTS is
'All arguments of the operators available to the user'
/
Comment on column ALL_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column ALL_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column ALL_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view DBA_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
/
create or replace public synonym DBA_OPERATOR_COMMENTS
   for DBA_OPERATOR_COMMENTS
/
grant select on DBA_OPERATOR_COMMENTS to select_catalog_role
/
comment on table DBA_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column DBA_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column DBA_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column DBA_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

create or replace view USER_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
       and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_OPERATOR_COMMENTS
   for USER_OPERATOR_COMMENTS
/
grant select on USER_OPERATOR_COMMENTS to PUBLIC with grant option
/
comment on table USER_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column USER_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column USER_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column USER_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

create or replace view ALL_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
       and
       ( o.owner# = userenv('SCHEMAID')
         or
         o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
         or exists (select null from v$enabledprivs
                    where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPERATOR_COMMENTS
   for ALL_OPERATOR_COMMENTS
/
grant select on ALL_OPERATOR_COMMENTS to PUBLIC with grant option
/
comment on table ALL_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column ALL_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column ALL_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column ALL_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

Rem
Rem Indextype Views
Rem
create or replace view DBA_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML, MAINTENANCE_TYPE)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'LOCAL     '),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES'),
decode(bitand(i.property, 1024), 0, 'USER_MANAGED', 1024, 'SYSTEM_MANAGED')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid
/
create or replace public synonym DBA_INDEXTYPES for DBA_INDEXTYPES
/
grant select on DBA_INDEXTYPES to select_catalog_role
/
comment on table DBA_INDEXTYPES is
'All indextypes'
/
comment on column DBA_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column DBA_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column DBA_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column DBA_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column DBA_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column DBA_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/
comment on column DBA_INDEXTYPES.MAINTENANCE_TYPE is
'An indicator of whether the indextype is system managed or user managed'
/

create or replace view USER_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML, MAINTENANCE_TYPE)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'LOCAL     '),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES'),
decode(bitand(i.property, 1024), 0, 'USER_MANAGED', 1024, 'SYSTEM_MANAGED')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid and
o.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPES for USER_INDEXTYPES
/
grant select on USER_INDEXTYPES to PUBLIC with grant option
/
comment on table USER_INDEXTYPES is
'All user indextypes'
/
comment on column USER_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column USER_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column USER_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column USER_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column USER_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column USER_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/
comment on column USER_INDEXTYPES.MAINTENANCE_TYPE is
'An indicator of whether the indextype is system managed or user managed'
/

create or replace view ALL_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML, MAINTENANCE_TYPE)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'LOCAL     '),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES'),
decode(bitand(i.property, 1024), 0, 'USER_MANAGED', 1024, 'SYSTEM_MANAGED')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid and
( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
      )
/
create or replace public synonym ALL_INDEXTYPES for ALL_INDEXTYPES
/
grant select on ALL_INDEXTYPES to PUBLIC with grant option
/
Comment on table ALL_INDEXTYPES is
'All indextypes available to the user'
/
comment on column ALL_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column ALL_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column ALL_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column ALL_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column ALL_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column ALL_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/
comment on column ALL_INDEXTYPES.MAINTENANCE_TYPE is
'An indicator of whether the indextype is system managed or user managed'
/

create or replace view DBA_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj#
/
create or replace public synonym DBA_INDEXTYPE_COMMENTS for DBA_INDEXTYPE_COMMENTS
/
grant select on DBA_INDEXTYPE_COMMENTS to select_catalog_role
/
comment on table DBA_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column DBA_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column DBA_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column DBA_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view USER_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj#
        and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPE_COMMENTS
   for USER_INDEXTYPE_COMMENTS
/
grant select on USER_INDEXTYPE_COMMENTS to PUBLIC with grant option
/
comment on table USER_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column USER_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column USER_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column USER_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view ALL_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj# and
( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
 )
/
create or replace public synonym ALL_INDEXTYPE_COMMENTS
   for ALL_INDEXTYPE_COMMENTS
/
grant select on ALL_INDEXTYPE_COMMENTS to PUBLIC with grant option
/
comment on table ALL_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column ALL_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column ALL_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column ALL_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view DBA_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
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
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo, sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner#
/
create or replace public synonym DBA_INDEXTYPE_ARRAYTYPES
for DBA_INDEXTYPE_ARRAYTYPES
/
grant select on DBA_INDEXTYPE_ARRAYTYPES to select_catalog_role
/
comment on table DBA_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view USER_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
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
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo,  sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner# and indtypo.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPE_ARRAYTYPES
for USER_INDEXTYPE_ARRAYTYPES
/
grant select on USER_INDEXTYPE_ARRAYTYPES to PUBLIC with grant option
/
comment on table USER_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view ALL_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
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
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo, sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner# and
      ( indtypo.owner# = userenv ('SCHEMAID')
        or
        indtypo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or exists (select null from v$enabledprivs
                   where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                  )
      )
/
create or replace public synonym ALL_INDEXTYPE_ARRAYTYPES
for ALL_INDEXTYPE_ARRAYTYPES
/
grant select on ALL_INDEXTYPE_ARRAYTYPES to PUBLIC with grant option
/
comment on table ALL_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view DBA_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and bitand(i.property, 4) != 4 and
      u1.user#=op.owner#
/
create or replace public synonym DBA_INDEXTYPE_OPERATORS
for DBA_INDEXTYPE_OPERATORS
/
grant select on DBA_INDEXTYPE_OPERATORS to select_catalog_role
/
comment on table DBA_INDEXTYPE_OPERATORS is
'All indextype operators'
/
comment on column DBA_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column DBA_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column DBA_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column DBA_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column DBA_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

create or replace view USER_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and u1.user#=op.owner# and
      o.owner# = userenv ('SCHEMAID') and bitand(i.property, 4) != 4
/
create or replace public synonym USER_INDEXTYPE_OPERATORS
for USER_INDEXTYPE_OPERATORS
/
grant select on USER_INDEXTYPE_OPERATORS to PUBLIC
with grant option
/
Comment on table USER_INDEXTYPE_OPERATORS is
'All user indextype operators'
/
Comment on column USER_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column USER_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column USER_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column USER_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column USER_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

create or replace view ALL_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and bitand(i.property, 4) != 4 and u1.user#=op.owner# and
      ( o.owner# = userenv ('SCHEMAID')
      or
      o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
      )
/
create or replace public synonym ALL_INDEXTYPE_OPERATORS
for ALL_INDEXTYPE_OPERATORS
/
grant select on ALL_INDEXTYPE_OPERATORS to PUBLIC
with grant option
/
Comment on table ALL_INDEXTYPE_OPERATORS is
'All operators available to the user'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column ALL_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column ALL_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

rem
rem   FAMILY  "SECONDARY_OBJECT"
rem   Comments on secondary objects associated with a domain index
rem
create or replace view DBA_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME,
    SECONDARY_OBJDATA_TYPE)
as
select u.name, o.name, u1.name, o1.name, decode(s.spare1, 0, 'FROM INDEXTYPE',
                                                1, 'FROM STATISTICS TYPE')
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user#
/
create or replace public synonym DBA_SECONDARY_OBJECTS for DBA_SECONDARY_OBJECTS
/
grant select on DBA_SECONDARY_OBJECTS to select_catalog_role
/
comment on table DBA_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column DBA_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column DBA_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column DBA_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column DBA_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/
comment on column DBA_SECONDARY_OBJECTS.SECONDARY_OBJDATA_TYPE is
'Type of the secondary object'
/

create or replace view USER_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME,
    SECONDARY_OBJDATA_TYPE)
as
select u.name, o.name, u1.name, o1.name, decode(s.spare1, 0, 'FROM INDEXTYPE',
                                                1, 'FROM STATISTICS TYPE')
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user# and
       o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_SECONDARY_OBJECTS
   for USER_SECONDARY_OBJECTS
/
grant select on USER_SECONDARY_OBJECTS to PUBLIC with grant option
/
comment on table USER_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column USER_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column USER_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column USER_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column USER_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/
comment on column USER_SECONDARY_OBJECTS.SECONDARY_OBJDATA_TYPE is
'Type of the secondary object'
/

create or replace view ALL_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME,
    SECONDARY_OBJDATA_TYPE)
as
select u.name, o.name, u1.name, o1.name, decode(s.spare1, 0, 'FROM INDEXTYPE',
                                                1, 'FROM STATISTICS TYPE')
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user# and
       ( o.owner# = userenv('SCHEMAID')
         or
         o.obj# in ( select obj#
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
create or replace public synonym ALL_SECONDARY_OBJECTS
   for ALL_SECONDARY_OBJECTS
/
grant select on ALL_SECONDARY_OBJECTS to PUBLIC with grant option
/
comment on table ALL_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column ALL_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column ALL_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column ALL_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column ALL_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/
comment on column ALL_SECONDARY_OBJECTS.SECONDARY_OBJDATA_TYPE is
'Type of the secondary object'
/
