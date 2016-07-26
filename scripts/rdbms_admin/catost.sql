Rem
Rem $Header: rdbms/admin/catost.sql /st_rdbms_11.2.0/2 2010/12/25 22:46:22 ptearle Exp $
Rem
Rem catost.sql
Rem
Rem Copyright (c) 2003, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catost.sql - Optimizer Statistics Tables and Views
Rem
Rem    DESCRIPTION
Rem      This file creates Optimizer Statistics tables and views that can not 
Rem      be created while running catalog.sql due to dependency on other objects.
Rem
Rem    NOTES
Rem      This file is run after all basic tables, views and objects required for
Rem      plsql execution are created. So any views/objects that depends on
Rem      these basic objects should be in this file.  For example 
Rem      *_stat_extensions views require a plsql function and hence created in
Rem      this file.
Rem
Rem      The optimizer tables and views are created in the following scripts.
Rem      (They are run in the order below.)
Rem
Rem      1- doptim.bsq
Rem
Rem         Called from sql.bsq during database creation time. sql.bsq contains 
Rem         all scripts used for creating basic dictionary tables for database 
Rem         operation.
Rem
Rem      2- cdoptim.sql
Rem 
Rem         Called from catalog.sql. Catalog.sql contains all scripts for 
Rem         creating basic catalog views.
Rem
Rem      3- catost.sql
Rem
Rem         Called during catproc time. catproc.sql creates all procedures, 
Rem         functions and depended views on these procedures and functions.
Rem         (pretty much everything that can not be done at catalog.sql run) 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ptearle     08/13/10 - 9447598: ignore items in the recyclebin
Rem    ptearle     07/22/10 - 9930151: quote names for dbms_stats calls
Rem    sursridh    04/16/10 - Use correct checks for IOTs in
Rem                           user_tab_statistics.
Rem    hosu        04/09/10 - reduce subpartition number in wri$_optstat_synopsis$
Rem    hosu        02/18/10 - move synopsis related tables from doptim.sql here
Rem    schakkap    07/14/08 - #(4921917) show stats lock on partitions
Rem    hosu        12/28/07 - 6684794: move statistics view dependent on dbms_stats 
Rem                           from cdoptim to catost
Rem    schakkap    10/01/06 - move optimizer tables and views to doptim.bsq and
Rem                           cdoptim.sql
Rem    hosu        06/20/06 - support expression clob in WRI$_OPTSTAT_HISTHEAD_
Rem                           HISTORY
Rem    mzait       06/15/06 - Add *_[TAB|IND|COL|HISTGRM]_PRIVATE_STATS 
Rem                           New dictionary views to show private stats 
Rem    mzait       06/13/06 - Add *_TAB_STAT_PREFS
Rem                           New dictionary views to show stats preferences
Rem    mzait       05/04/06 - Add support for statistics preferences 
Rem    hosu        04/17/06 - add new tables for incremental maintenance of 
Rem                           global stats
Rem    schakkap    12/09/03 - set pctfree to 1 for stats history tables 
Rem    schakkap    10/08/03 - support for changing defaults for dbms_stats 
Rem    schakkap    09/24/03 - remove owner column from USER_TAB_STATS_HISTORY 
Rem    schakkap    09/08/03 - *_TAB_STATS_HISTORY 
Rem    schakkap    05/31/03 - change OPTSTAT_SAVSKIP$ to OPTSTAT_HIST_CONTROL$
Rem    aime        04/25/03 - aime_going_to_main
Rem    schakkap    02/08/03 - schakkap_stat_history
Rem    schakkap    01/28/03 - Created
Rem

Rem
Rem  Family "STAT_EXTENSIONS"
Rem  Displays statistics extensions
Rem

Rem The following function returns the extension, given the rowid of
Rem the column in col$. We can not create plsql functions during catalog
Rem time since it depends on ALL_ERRORS created in catproc time. Hence
Rem the function and views depending on the function are created in this
Rem file.
create or replace function get_stats_extension(
  colrowid rowid)  return clob is
  extn     long;
  extnclob clob;
begin

  select 
    c.default$ into extn
  from sys.col$ c
  where c.rowid = colrowid;

  extnclob := extn;

  if (substr(extnclob, 1, 20) = 'SYS_OP_COMBINED_HASH') then
    return substr(extnclob, 21);
  else
    return '(' || extnclob || ')';
  end if;

end get_stats_extension;
/

show  errors;

Rem =========================================================================
Rem BEGIN Synopsis tables
Rem =========================================================================

Rem Synopsis tables are partitioned. They would fail to be created
Rem in doptim.bsq. Parititoning features requrires querying data 
Rem dictionary tables that are created later than doptim.bsq.

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

Rem Table to store mapping relationship between partition groups 
Rem to synopis#. for example, 100 partitions are divided into 2 
Rem groups, partition 1 - 10 has one synopsis and partition 11 - 
Rem 100 has another synopsis
Rem if 1 partition corresponds to 1 group, we add a special row
Rem (obj#, ONE_TO_ONE) where obj# is the table's obj and ONE_TO_ONE
Rem marks the mapping from partitions to group is one to one.
create table wri$_optstat_synopsis_partgrp
( obj#   number not null,   /* obj# of a partition or a table */
  group# number not null                      /* group number */
) tablespace sysaux 
pctfree 1
enable row movement
/
create unique index i_wri$_optstat_synoppartgrp on 
  wri$_optstat_synopsis_partgrp (obj#)
  tablespace sysaux
/

Rem Table to store synopsis meta data
create table wri$_optstat_synopsis_head$ 
( bo#           number not null,    /* table obj# */
  group#        number not null,    /* partition group number */
  intcol#       number not null,             /* column number */
  synopsis#     number not null primary key,                           
  split         number,     
              /* number of splits during creation of synopsis */
  analyzetime   date,
              /* time when this synopsis is gathered */
  spare1        number,
  spare2        clob
) tablespace sysaux 
pctfree 1
enable row movement
/
create unique index i_wri$_optstat_synophead on 
  wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
  tablespace sysaux
/

Rem Table to store the synopsis
create table wri$_optstat_synopsis$
( bo#           number not null,
  group#        number not null,
  intcol#       number not null,           
  hashvalue     number not null 
) 
partition by range(bo#) 
  subpartition by hash(group#) 
  subpartitions 32
(
  partition p0 values less than (0)
) 
tablespace sysaux
pctfree 1
enable row movement
/

create sequence group_num_seq start with 1 increment by 1;

create sequence synopsis_num_seq start with 1 increment by 1;

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

Rem =========================================================================
Rem END Synopsis tables
Rem =========================================================================

CREATE OR REPLACE VIEW ALL_STAT_EXTENSIONS
  (
  owner,
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    u.name, o.name, c.name,
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
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
comment on table ALL_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column ALL_STAT_EXTENSIONS.OWNER is
'Owner of the extension'
/
comment on column ALL_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column ALL_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column ALL_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column ALL_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym ALL_STAT_EXTENSIONS for ALL_STAT_EXTENSIONS
/
grant select on ALL_STAT_EXTENSIONS to PUBLIC with grant option
/

CREATE OR REPLACE VIEW DBA_STAT_EXTENSIONS
  (
  owner,
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    u.name, o.name, c.name,
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
/
comment on table DBA_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column DBA_STAT_EXTENSIONS.OWNER is
'Owner of the extension'
/
comment on column DBA_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column DBA_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column DBA_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column DBA_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym DBA_STAT_EXTENSIONS for DBA_STAT_EXTENSIONS
/
grant select on DBA_STAT_EXTENSIONS to select_catalog_role
/

CREATE OR REPLACE VIEW USER_STAT_EXTENSIONS
  (
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    o.name, c.name, 
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column USER_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column USER_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column USER_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column USER_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym USER_STAT_EXTENSIONS for USER_STAT_EXTENSIONS
/
grant select on USER_STAT_EXTENSIONS to PUBLIC with grant option
/

Rem
Rem Family "TAB_STATISTICS"
Rem Table and index optimizer statistics 
Rem
Rem *_TAB_STATISTICS views can be used to display  statistics for
Rem tables(including fixed objects)/partitions.
Rem The view has the following union all branches
Rem   - tables
Rem   - non iot partitions
Rem   - iot partitions
Rem   - composite partitions
Rem   - subpartitions
Rem   - fixed objects
Rem stale_stats column values
Rem   null => if not analyzed or if it is fixed table
Rem   YES  => if truncated or if more than 10% modification
Rem   NO   => otherwise
Rem
CREATE OR REPLACE VIEW ALL_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             t.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 64
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > 
             tcp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tsp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(po.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
    and (po.owner# = userenv('SCHEMAID') 
         or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
          exists (select null FROM v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL 
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
/
create or replace public synonym ALL_TAB_STATISTICS for ALL_TAB_STATISTICS
/
grant select on ALL_TAB_STATISTICS to PUBLIC with grant option
/
comment on table ALL_TAB_STATISTICS is
'Optimizer statistics for all tables accessible to the user'
/
comment on column ALL_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column ALL_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column ALL_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column ALL_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column ALL_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/


CREATE OR REPLACE VIEW DBA_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             t.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.obj# = m.obj# (+)
    and bitand(tab.property, 64) = 64
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > 
             tcp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(o.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tsp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            DBMS_STATS_INTERNAL.DQ(u.name),
                                            DBMS_STATS_INTERNAL.DQ(po.name))
                      )/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
/
create or replace public synonym DBA_TAB_STATISTICS for DBA_TAB_STATISTICS
/
grant select on DBA_TAB_STATISTICS to select_catalog_role
/
comment on table DBA_TAB_STATISTICS is
'Optimizer statistics for all tables in the database'
/
comment on column DBA_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column DBA_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column DBA_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column DBA_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column DBA_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

CREATE OR REPLACE VIEW USER_TAB_STATISTICS
 (
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             t.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            SYS_CONTEXT('USERENV', 'SESSION_USER'), 
                                            DBMS_STATS_INTERNAL.DQ(o.name)))/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            SYS_CONTEXT('USERENV', 'SESSION_USER'), 
                                            DBMS_STATS_INTERNAL.DQ(o.name)))/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab, 
    sys.mon_mods_all$ m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* IOT Partitions */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            SYS_CONTEXT('USERENV', 'SESSION_USER'), 
                                            DBMS_STATS_INTERNAL.DQ(o.name)))/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 64
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > 
             tcp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            SYS_CONTEXT('USERENV', 'SESSION_USER'), 
                                            DBMS_STATS_INTERNAL.DQ(o.name)))/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.obj$ o, sys.tabcompartv$ tcp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* SUBPARTITIONS */
    po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > 
             tsp.rowcnt * 
             to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                            SYS_CONTEXT('USERENV', 'SESSION_USER'), 
                                            DBMS_STATS_INTERNAL.DQ(po.name)))/100 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp,
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.owner# = userenv('SCHEMAID') 
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* FIXED TABLES */
    t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and userenv('SCHEMAID') = 0  /* SYS */
/
create or replace public synonym USER_TAB_STATISTICS for USER_TAB_STATISTICS
/
grant select on USER_TAB_STATISTICS to PUBLIC with grant option
/
comment on table USER_TAB_STATISTICS is
'Optimizer statistics of the user''s own tables'
/
comment on column USER_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column USER_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column USER_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column USER_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column USER_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column USER_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column USER_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/


Rem
Rem Family "IND_STATISTICS"
Rem *_IND_STATISTICS views can be used to display  statistics for
Rem index/index partitions.
Rem The view has the following union all branches
Rem   - indexes (types 1, 2, 4, 6, 7, 8)
Rem   - cluster indexes (staleness, stattype_locked is different from above)
Rem   - partitions
Rem   - composite partitions
Rem   - subpartitions
Rem
Rem We don't display domain indexes since it is not available in dictionary 
Rem tables (ind$, indpart$ ...). So type 9 is excluded.
Rem
Rem index types:
Rem    normal : 1
Rem    bitmap : 2
Rem    cluster: 3
Rem    iot - top : 4
Rem    iot - nested : 5
Rem    secondary : 6
Rem    ansi : 7
Rem    lob : 8
Rem    cooperative index method (domain indexes) : 9
Rem stale_stats column values
Rem   null => if index/table (partition) is not analyzed 
Rem   YES  => if global index
Rem             if corresponding table is stale OR
Rem                the index is analyzed before table 
Rem           if local_index
Rem             if corresponding table partition is stale OR
Rem                the index partition is analyzed before table partition
Rem           if cluster index
Rem             if one of the tables in cluster is stale
Rem   NO   => otherwise
Rem
create or replace view ALL_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  /* Non cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > 
                  t.rowcnt * 
                  to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                 DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                 DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > 
                        tab.rowcnt *
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3 /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and ip.bo# = i.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  and (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Composite partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tcp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and i.obj# = icp.bo# 
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  and (io.owner# = userenv('SCHEMAID') 
        or 
        i.bo# in (select oa.obj#
                  FROM sys.objauth$ oa
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      ) 
                   )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  /* Subpartitions */
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tsp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and icp.bo# = i.obj# 
  and i.type# != 9  --  no domain indexes
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
  and (op.owner# = userenv('SCHEMAID')
        or i.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_IND_STATISTICS for ALL_IND_STATISTICS
/
grant select on ALL_IND_STATISTICS to PUBLIC with grant option
/
comment on table ALL_IND_STATISTICS is
'Optimizer statistics for all indexes on tables accessible to the user'
/
comment on column ALL_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column ALL_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column ALL_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column ALL_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column ALL_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column ALL_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/


create or replace view DBA_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  /* Non cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
          (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > 
                 t.rowcnt * 
                 to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > 
                        tab.rowcnt *
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Composite partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tcp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Subpartitions */
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tsp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
/
create or replace public synonym DBA_IND_STATISTICS for DBA_IND_STATISTICS
/
grant select on DBA_IND_STATISTICS to select_catalog_role 
/
comment on table DBA_IND_STATISTICS is
'Optimizer statistics for all indexes in the database'
/
comment on column DBA_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column DBA_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column DBA_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column DBA_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column DBA_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column DBA_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

create or replace view USER_IND_STATISTICS
  (
  INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  /* Non cluster indexes */
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > 
                 t.rowcnt * 
                 to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Cluster indexes */
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > 
                        tab.rowcnt *
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3  /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Partitions */
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Composite partitions */
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tcp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Subpartitions */
  SELECT 
    op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#,
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tab.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > 
                        tsp.rowcnt * 
                        to_number(DBMS_STATS.GET_PREFS('STALE_PERCENT', 
                                                       DBMS_STATS_INTERNAL.DQ(ut.name), 
                                                       DBMS_STATS_INTERNAL.DQ(ot.name)))/100 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.owner# = userenv('SCHEMAID')
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
/
create or replace public synonym USER_IND_STATISTICS for USER_IND_STATISTICS
/
grant select on USER_IND_STATISTICS to PUBLIC with grant option 
/
comment on table USER_IND_STATISTICS is
'Optimizer statistics for user''s own indexes'
/
comment on column USER_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column USER_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column USER_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column USER_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column USER_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
