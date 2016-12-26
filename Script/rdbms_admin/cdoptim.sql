Rem
Rem $Header: rdbms/admin/cdoptim.sql /main/10 2010/04/13 23:57:37 ptearle Exp $
Rem
Rem cdoptim.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdoptim.sql - Catalog DOPTIM.bsq views
Rem
Rem    DESCRIPTION
Rem      statistic objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in doptim.bsq. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ptearle     04/06/10 - 8354888: create public synonym for
Rem                           DBA_TAB_MODIFICATIONS
Rem    ruparame    03/15/10 - Bug 9192924 Add SYS_OP_DV_CHECK to sensitive columns
Rem    hosu        12/27/07 - 6684794: use staleness defined in table 
Rem                           preference (move these views to catost.sql)
Rem    yzhu        04/12/07 - #(5958445) set partition stale status based on 
Rem                           last_analyzed time of that partition
Rem    mzait       02/08/07 - replace private by pending
Rem    mzait       12/14/06 - Allow cluster indexes to show in private
Rem                           statistics
Rem    schakkap    09/27/06 - TAB_COL_STATISTICS now shows hidden column stats
Rem    schakkap    09/20/06 - move catost.sql contents
Rem                           move statistics views from cdpart.sql
Rem    yhu         05/26/06 - Add MAINTENANCE_TYPE in *_ASSOCIATIONS 
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

Rem
Rem Family "TAB_COL_STATISTICS"
Rem This family of views contains column statistics and histogram
Rem information for table columns.
Rem
create or replace view USER_TAB_COL_STATISTICS
    (TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from user_tab_cols
where last_analyzed is not null
union all
select /* fixed table column stats */
       ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
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
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and userenv('SCHEMAID') = 0  /* SYS */
/
comment on table USER_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym USER_TAB_COL_STATISTICS for USER_TAB_COL_STATISTICS
/
grant select on USER_TAB_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from all_tab_cols
where last_analyzed is not null
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
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
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and (userenv('SCHEMAID') = 0  /* SYS */
            or /* user has system privileges */
            exists (select null from v$enabledprivs
                    where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                   )
           )
/
comment on table ALL_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column ALL_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym ALL_TAB_COL_STATISTICS for ALL_TAB_COL_STATISTICS
/
grant select on ALL_TAB_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from dba_tab_cols
where last_analyzed is not null
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
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
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
/
comment on table DBA_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column DBA_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym DBA_TAB_COL_STATISTICS for DBA_TAB_COL_STATISTICS
/
grant select on DBA_TAB_COL_STATISTICS to select_catalog_role
/

Rem
Rem  Family "TAB_HISTOGRAMS"
Rem  The histograms (part of the statistics used by the cost-based
Rem    optimizer) on columns.
Rem  The TAB_COL_STATISTICS contain general information about
Rem    each histogram, including the number of buckets.
Rem  These views contains that actual histogram data.
Rem
create or replace view USER_TAB_HISTOGRAMS
    (TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and userenv('SCHEMAID') = 0  /* SYS */
/
comment on table USER_TAB_HISTOGRAMS is
'Histograms on columns of user''s tables'
/
comment on column USER_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column USER_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym USER_TAB_HISTOGRAMS for USER_TAB_HISTOGRAMS
/
grant select on USER_TAB_HISTOGRAMS to PUBLIC with grant option
/

Rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym USER_HISTOGRAMS for USER_TAB_HISTOGRAMS
/

create or replace view ALL_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
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
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
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
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
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
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and (userenv('SCHEMAID') = 0  /* SYS */
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-237 /* SELECT ANY DICTIONARY */)
              )
      )
/
comment on table ALL_TAB_HISTOGRAMS is
'Histograms on columns of all tables visible to user'
/
comment on column ALL_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column ALL_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column ALL_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym ALL_TAB_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/
grant select on ALL_TAB_HISTOGRAMS to PUBLIC with grant option
/

Rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym ALL_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/

create or replace view DBA_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
/
comment on table DBA_TAB_HISTOGRAMS is
'Histograms on columns of all tables'
/
comment on column DBA_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column DBA_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column DBA_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym DBA_TAB_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/
grant select on DBA_TAB_HISTOGRAMS to select_catalog_role
/

Rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym DBA_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/

Rem 
Rem  Family "PART_COL_STATISTICS"
Rem   These views contain column statistics and histogram information
Rem   for table partitions.
Rem
create or replace view TP$ as
select tp.obj#, tp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabpart$ tp, attrcol$ a 
      where tp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
union
select tcp.obj#, tcp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabcompart$ tcp, attrcol$ a 
      where tcp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
/
grant select on TP$ to select_catalog_role
/

create or replace view USER_PART_COL_STATISTICS 
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tp.cname, h.distcnt, 
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from  obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_PART_COL_STATISTICS
   for USER_PART_COL_STATISTICS 
/
grant select on USER_PART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, 
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys.hist_head$ h, tp$ tp, user$ u
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
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
create or replace public synonym ALL_PART_COL_STATISTICS
   for ALL_PART_COL_STATISTICS 
/
grant select on ALL_PART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, 
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys.hist_head$ h, tp$ tp, user$ u
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_PART_COL_STATISTICS
   for DBA_PART_COL_STATISTICS
/
grant select on DBA_PART_COL_STATISTICS to select_catalog_role
/

Rem
Rem  Family "PART_HISTOGRAMS"
Rem   These views contain the actual histogram data (end-points per
Rem   histogram) for histograms on table partitions.
Rem
create or replace view USER_PART_HISTOGRAMS
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, tp$ tp
where o.obj# = h.obj# and h.obj# = tp.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_PART_HISTOGRAMS for USER_PART_HISTOGRAMS
/
grant select on USER_PART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view ALL_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
create or replace public synonym ALL_PART_HISTOGRAMS for ALL_PART_HISTOGRAMS
/
grant select on ALL_PART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view DBA_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_PART_HISTOGRAMS for DBA_PART_HISTOGRAMS
/
grant select on DBA_PART_HISTOGRAMS to select_catalog_role
/

Rem 
Rem  Family "SUBPART_COL_STATISTICS"
Rem   These views contain column statistics and histogram information
Rem   for table subpartitions.
Rem
create or replace view TSP$ as
select tsp.obj#, tcp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabsubpart$ tsp, sys.tabcompart$ tcp, attrcol$ a 
      where tsp.pobj# = tcp.obj# and tcp.bo# = c.obj#
      and bitand(c.property,32768) != 32768    /* not unused columns */
      and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
/
grant select on TSP$ to select_catalog_role
/
create or replace view USER_SUBPART_COL_STATISTICS 
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tsp.cname, h.distcnt, 
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj#
  and tsp.obj# = h.obj#(+) and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_COL_STATISTICS
   for USER_SUBPART_COL_STATISTICS 
/
grant select on USER_SUBPART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then  h.hival
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or tsp.bo# in
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
create or replace public synonym ALL_SUBPART_COL_STATISTICS
   for ALL_SUBPART_COL_STATISTICS 
/
grant select on ALL_SUBPART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then  h.hival
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
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_COL_STATISTICS
   for DBA_SUBPART_COL_STATISTICS
/
grant select on DBA_SUBPART_COL_STATISTICS to select_catalog_role
/

Rem
Rem  Family "SUBPART_HISTOGRAMS"
Rem   These views contain the actual histogram data (end-points per
Rem   histogram) for histograms on table subpartitions.
Rem
create or replace view USER_SUBPART_HISTOGRAMS
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, tsp$ tsp
where o.obj# = h.obj# and h.obj# = tsp.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_HISTOGRAMS
   for USER_SUBPART_HISTOGRAMS
/
grant select on USER_SUBPART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view ALL_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
create or replace public synonym ALL_SUBPART_HISTOGRAMS
   for ALL_SUBPART_HISTOGRAMS
/
grant select on ALL_SUBPART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view DBA_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_HISTOGRAMS
   for DBA_SUBPART_HISTOGRAMS
/
grant select on DBA_SUBPART_HISTOGRAMS to select_catalog_role
/

Rem
Rem  Family "ASSOCIATIONS"
Rem  Info on user defined statistics associations
Rem
create or replace view DBA_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#, 
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
/
create or replace public synonym DBA_ASSOCIATIONS for DBA_ASSOCIATIONS
/
grant select on DBA_ASSOCIATIONS to select_catalog_role
/
Comment on table DBA_ASSOCIATIONS is
'All associations'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column DBA_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/
Comment on column DBA_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/

create or replace view USER_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#,
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_ASSOCIATIONS for USER_ASSOCIATIONS
/
grant select on USER_ASSOCIATIONS to public with grant option
/
Comment on table USER_ASSOCIATIONS is
'All assocations defined by the user'
/
Comment on column USER_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column USER_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.INTERFACE_VERSION is
'Interface number of Statistics type interface implemented'
/
Comment on column USER_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/

create or replace view ALL_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#,
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
       or
       ( o.type# in (8, 9)   /* package or function */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-140 /* CREATE PROCEDURE */,
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -142 /* ALTER ANY PROCEDURE */,
                                        -143 /* DROP ANY PROCEDURE */,
                                        -144 /* EXECUTE ANY PROCEDURE */)
                 )
       )
       or
       ( o.type# in (13)     /* type */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-180 /* CREATE TYPE */,
                                        -181 /* CREATE ANY TYPE */,
                                        -182 /* ALTER ANY TYPE */,
                                        -183 /* DROP ANY TYPE */,
                                        -184 /* EXECUTE ANY TYPE */)
                 )
       )
       or
       ( o.type# in (1)     /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
       or
       ( o.type# in (32)     /* indextype */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
       )
    )
/
create or replace public synonym ALL_ASSOCIATIONS for ALL_ASSOCIATIONS
/
grant select on ALL_ASSOCIATIONS to PUBLIC with grant option
/
Comment on table ALL_ASSOCIATIONS is
'All associations available to the user'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - column, type, package or function'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column ALL_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/
Comment on column ALL_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/

Rem
Rem Family "USTATS"
Rem User defined statistics
Rem
create or replace view DBA_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
/
create or replace public synonym DBA_USTATS for DBA_USTATS
/
grant select on DBA_USTATS to select_catalog_role
/
Comment on table DBA_USTATS is
'All statistics collected on either tables or indexes'
/
Comment on column DBA_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column DBA_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column DBA_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column DBA_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column DBA_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column DBA_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column DBA_USTATS.STATISTICS is
'User collected statistics for the object'
/

create or replace view USER_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    o.owner#=userenv('SCHEMAID')
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#  and o.owner#=userenv('SCHEMAID')
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    o.owner#= userenv('SCHEMAID')
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_USTATS for USER_USTATS
/
grant select on USER_USTATS to public with grant option
/
Comment on table USER_USTATS is
'All statistics on tables or indexes owned by the user'
/
Comment on column USER_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column USER_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column USER_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column USER_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column USER_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column USER_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column USER_USTATS.STATISTICS is
'User collected statistics for the object'
/

create or replace view ALL_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
/
create or replace public synonym ALL_USTATS for ALL_USTATS
/
grant select on ALL_USTATS to public with grant option
/
Comment on table ALL_USTATS is
'All statistics'
/
Comment on column ALL_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column ALL_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column ALL_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column ALL_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column ALL_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column ALL_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column ALL_USTATS.STATISTICS is
'User collected statistics for the object'
/

Rem
Rem Family "TAB_MODIFICATIONS"
Rem
Rem These views provide information about the amount and type of
Rem modifications made to rows in a table.
Rem
create or replace view USER_TAB_MODIFICATIONS
(TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS, UPDATES,
 DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.obj# = t.obj#
union all
  select o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
  from sys.mon_mods_all$ m, sys.obj$ o
  where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.type#=19
union all
select o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table USER_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column USER_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column USER_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column USER_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column USER_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column USER_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column USER_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym USER_TAB_MODIFICATIONS for USER_TAB_MODIFICATIONS
/
grant select on USER_TAB_MODIFICATIONS to PUBLIC with grant option
/

create or replace view ALL_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
/
comment on table ALL_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column ALL_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column ALL_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column ALL_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column ALL_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column ALL_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym ALL_TAB_MODIFICATIONS for ALL_TAB_MODIFICATIONS
/
grant select on ALL_TAB_MODIFICATIONS to PUBLIC with grant option
/

create or replace view DBA_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table DBA_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column DBA_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column DBA_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column DBA_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column DBA_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column DBA_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym DBA_TAB_MODIFICATIONS for DBA_TAB_MODIFICATIONS
/
grant select on DBA_TAB_MODIFICATIONS to select_catalog_role
/

Rem
Rem OPTSTAT_OPERATIONS
Rem This view contains history of statistics operations performed
Rem at schema/database level using dbms_stats package.
Rem
create or replace view DBA_OPTSTAT_OPERATIONS
  (OPERATION, TARGET, START_TIME, END_TIME) as 
  select operation, target, start_time, end_time
  from sys.wri$_optstat_opr
/
create or replace public synonym DBA_OPTSTAT_OPERATIONS for 
DBA_OPTSTAT_OPERATIONS
/
grant select on DBA_OPTSTAT_OPERATIONS to select_catalog_role
/
comment on table DBA_OPTSTAT_OPERATIONS is
'History of statistics operations performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.OPERATION is
'Operation name'
/
comment on column DBA_OPTSTAT_OPERATIONS.TARGET is
'Target on which operation performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.START_TIME is
'Start time of operation'
/
comment on column DBA_OPTSTAT_OPERATIONS.END_TIME is
'End time of operation'
/

Rem
Rem Family "TAB_STATS_HISTORY"
Rem Views for displaying the statistics update time from history
Rem
create or replace view ALL_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select /*+ rule */ u.name, o.name, null, null, h.savtime
  from sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
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
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from  sys.user$ u, sys.obj$ o, sys.obj$ ot,
        sys.wri$_optstat_tab_history h
  where h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
        and ot.name = o.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime <= systimestamp  -- exclude pending statistics
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u, sys.obj$ osp, obj$ ocp,  sys.obj$ ot, 
        sys.tabsubpart$ tsp, sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj#
        and tsp.pobj# = ocp.obj# and osp.owner# = u.user#
        and ot.name = ocp.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime <= systimestamp  -- exclude pending statistics
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and  h.savtime <= systimestamp  -- exclude pending statistics
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
/
create or replace public synonym ALL_TAB_STATS_HISTORY for
ALL_TAB_STATS_HISTORY
/
grant select on ALL_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table ALL_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column ALL_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/

create or replace view DBA_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select u.name, o.name, null, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u,  sys.obj$ osp, obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
    and tsp.pobj# = ocp.obj# and osp.owner# = u.user#
    and h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and h.savtime <= systimestamp  -- exclude pending statistics
/
create or replace public synonym DBA_TAB_STATS_HISTORY for
DBA_TAB_STATS_HISTORY
/
grant select on DBA_TAB_STATS_HISTORY to select_catalog_role
/
comment on table DBA_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column DBA_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/

create or replace view USER_TAB_STATS_HISTORY
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select o.name, null, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 
    and  o.owner# = userenv('SCHEMAID')
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- partitions
  select o.name, o.subname, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 
    and  o.owner# = userenv('SCHEMAID')
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- sub partitions
  select osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.obj$ osp, sys.obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
    and tsp.pobj# = ocp.obj# and osp.owner# = userenv('SCHEMAID')
    and h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- fixed tables
  select t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and userenv('SCHEMAID') = 0  /* SYS */
    and  h.savtime <= systimestamp  -- exclude pending statistics
/
create or replace public synonym USER_TAB_STATS_HISTORY for
USER_TAB_STATS_HISTORY
/
grant select on USER_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table USER_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column USER_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/

Rem
Rem Family "TAB_STAT_PREFS"
Rem Table statistics preferences
Rem
create or replace view ALL_TAB_STAT_PREFS
  (OWNER, TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select u.name, o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o, user$ u
where p.obj#=o.obj#
  and u.user#=o.owner#
  and o.type#=2
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
create or replace public synonym ALL_TAB_STAT_PREFS for
ALL_TAB_STAT_PREFS
/
grant select on ALL_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table ALL_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column ALL_TAB_STAT_PREFS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column ALL_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/

create or replace view DBA_TAB_STAT_PREFS
  (OWNER, TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select u.name, o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o, user$ u
where p.obj#=o.obj#
  and u.user#=o.owner#
  and o.type#=2
/
create or replace public synonym DBA_TAB_STAT_PREFS for
DBA_TAB_STAT_PREFS
/
grant select on DBA_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table DBA_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column DBA_TAB_STAT_PREFS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column DBA_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/

create or replace view USER_TAB_STAT_PREFS
  (TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o
where p.obj#=o.obj#
  and o.type#=2
  and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_TAB_STAT_PREFS for
USER_TAB_STAT_PREFS
/
grant select on USER_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table USER_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column USER_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column USER_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/

Rem
Rem Family "TAB_PENDING_STATS"
Rem Table pending statistics
Rem
create or replace view ALL_TAB_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.samplesize, h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime > systimestamp
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
  -- partitions
  select u.name, o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.samplesize, h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.obj$ ot,
         sys.wri$_optstat_tab_history h
  where h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
        and ot.name = o.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime > systimestamp
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.samplesize, h.analyzetime
  from  sys.user$ u, sys.obj$ osp, obj$ ocp,  sys.obj$ ot, 
        sys.tabsubpart$ tsp, sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
        and ot.name = ocp.name and ot.type# = 2 and ot.owner# = u.user#
        and  h.savtime > systimestamp
        and  (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
create or replace public synonym ALL_TAB_PENDING_STATS for
ALL_TAB_PENDING_STATS
/
grant select on ALL_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_TAB_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_TAB_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column ALL_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column ALL_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column ALL_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column ALL_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view DBA_TAB_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.samplesize, h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.samplesize, h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.samplesize, h.analyzetime
  from  sys.user$ u,  sys.obj$ osp, obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
    and h.savtime > systimestamp
/
create or replace public synonym DBA_TAB_PENDING_STATS for
DBA_TAB_PENDING_STATS
/
grant select on DBA_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_TAB_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_TAB_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column DBA_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column DBA_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column DBA_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column DBA_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view USER_TAB_PENDING_STATS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.samplesize, h.analyzetime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 
         and o.owner# = userenv('SCHEMAID')
         and h.savtime > systimestamp
  union all
  -- partitions
  select o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.samplesize, h.analyzetime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 
         and o.owner# = userenv('SCHEMAID')
         and h.savtime > systimestamp
  union all
  -- sub partitions
  select osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.samplesize, h.analyzetime
  from  sys.obj$ osp, sys.obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
        and tsp.pobj# = ocp.obj# 
        and osp.owner# = userenv('SCHEMAID')
        and h.savtime > systimestamp
/
create or replace public synonym USER_TAB_PENDING_STATS for
USER_TAB_PENDING_STATS
/
grant select on USER_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_TAB_PENDING_STATS is
'History of table statistics modifications'
/
comment on column USER_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column USER_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column USER_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column USER_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column USER_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

Rem
Rem Family "IND_PENDING_STATS"
Rem Index pending statistics
Rem
create or replace view ALL_IND_PENDING_STATS
  (OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
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
  -- partitions
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
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
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
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
  -- sub partitions
  select ui.name, oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, sys.user$ ui,
         sys.wri$_optstat_ind_history h
  where  ui.user# = oi.owner#
    and  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
create or replace public synonym ALL_IND_PENDING_STATS for
ALL_IND_PENDING_STATS
/
grant select on ALL_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on table ALL_IND_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_IND_PENDING_STATS.OWNER is
'Index owner name'
/
comment on column ALL_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column ALL_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column ALL_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column ALL_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column ALL_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column ALL_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column ALL_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column ALL_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column ALL_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column ALL_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column ALL_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column ALL_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column ALL_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view DBA_IND_PENDING_STATS
  (OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select ui.name, oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, sys.user$ ui,
         sys.wri$_optstat_ind_history h
  where  ui.user# = oi.owner#
    and  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
/
create or replace public synonym DBA_IND_PENDING_STATS for
DBA_IND_PENDING_STATS
/
grant select on DBA_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on table DBA_IND_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_IND_PENDING_STATS.OWNER is
'Index owner name'
/
comment on column DBA_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column DBA_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column DBA_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column DBA_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column DBA_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column DBA_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column DBA_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column DBA_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column DBA_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column DBA_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column DBA_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column DBA_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column DBA_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view USER_IND_PENDING_STATS
  (INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, 
         sys.wri$_optstat_ind_history h
  where  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  ot.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_IND_PENDING_STATS for
USER_IND_PENDING_STATS
/
grant select on USER_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on table USER_IND_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column USER_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column USER_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column USER_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column USER_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column USER_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column USER_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column USER_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column USER_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column USER_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column USER_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column USER_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column USER_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column USER_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

Rem
Rem Family "COL_PENDING_STATS"
Rem Column pending statistics
Rem
create or replace view ALL_COL_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end, 
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histhead_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
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
  -- partitions
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval 
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
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
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
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
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(op.name, op.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(op.name, op.owner#) = 1
            then h.hival
            else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histhead_history h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and (os.owner# = userenv('SCHEMAID')
        or os.obj# in
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
create or replace public synonym ALL_COL_PENDING_STATS for
ALL_COL_PENDING_STATS
/
grant select on ALL_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_COL_PENDING_STATS.OWNER is
'Table owner name'
/
comment on column ALL_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column ALL_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column ALL_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column ALL_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column ALL_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column ALL_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column ALL_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/

create or replace view DBA_COL_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histhead_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histhead_history h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and  h.savtime > systimestamp
/
create or replace public synonym DBA_COL_PENDING_STATS for
DBA_COL_PENDING_STATS
/
grant select on DBA_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_COL_PENDING_STATS.OWNER is
'Table owner name'
/
comment on column DBA_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column DBA_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column DBA_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column DBA_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column DBA_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column DBA_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column DBA_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/

create or replace view USER_COL_PENDING_STATS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select o.name, null, null, c.name, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histhead_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.type# = 2 
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end, 
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histhead_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select op.name, op.subname, os.subname, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.hival
              else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histhead_history h
  where os.obj# = tsp.obj#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and os.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_COL_PENDING_STATS for
USER_COL_PENDING_STATS
/
grant select on USER_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column USER_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column USER_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column USER_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column USER_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column USER_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column USER_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column USER_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/

Rem
Rem Family "TAB_HISTGRM_PENDING_STATS"
Rem Histogram pending statistics
Rem
create or replace view ALL_TAB_HISTGRM_PENDING_STATS 
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
AS
  -- tables
  select u.name, o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue
            else null
       end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histgrm_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
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
  -- partitions
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
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
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
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
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue
              else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histgrm_history h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and (os.owner# = userenv('SCHEMAID')
        or os.obj# in
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
create or replace public synonym ALL_TAB_HISTGRM_PENDING_STATS for
ALL_TAB_HISTGRM_PENDING_STATS
/
grant select on ALL_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/

create or replace view DBA_TAB_HISTGRM_PENDING_STATS 
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
AS
  -- tables
  select u.name, o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histgrm_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue
              else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histgrm_history h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
/
create or replace public synonym DBA_TAB_HISTGRM_PENDING_STATS for
DBA_TAB_HISTGRM_PENDING_STATS
/
grant select on DBA_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/

create or replace view USER_TAB_HISTGRM_PENDING_STATS 
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
AS
  -- tables
  select o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys.wri$_optstat_histgrm_history h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue
              else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys.wri$_optstat_histgrm_history h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue
              else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.col$ c, sys.obj$ op,
        sys.wri$_optstat_histgrm_history h
  where os.obj# = tsp.obj#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and os.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_TAB_HISTGRM_PENDING_STATS for
USER_TAB_HISTGRM_PENDING_STATS
/
grant select on USER_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
