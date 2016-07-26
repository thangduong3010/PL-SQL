Rem
Rem NAME
Rem   CATPLUG.SQL
Rem FUNCTION
Rem   Pluggable Tablespace check views
Rem NOTES
Rem   This script must be run while connected as SYS or INTERNAL
Rem    MODIFIED   (MM/DD/YY)
Rem     dgagne    03/16/11  - remove checks for sys owned objects
Rem     tbhukya   03/15/11  - Backport tbhukya_bug-11682089 from main
Rem     kgiyer    05/28/10  - Bug-9723566: unify constraint checking in 
Rem                           straddling_ts_objects
Rem     kgiyer    05/28/10  - Bug-8576103: correct TS_PLUG_INFO
Rem     kgiyer    05/26/10  - Bug-8738668: exclude domain indexes
Rem     kgiyer    12/07/07  - Bug-6652830: correct checking on msgid 30 and 41
Rem     dgagne    02/26/07  - add restrition for ref_part tables
Rem     achoi     09/27/06  - only show obj$ column in TTS_OBJ_VIEW
Rem     achoi     05/15/06  - handle application edition 
Rem     clei      06/11/04  - disallow tables with encrypted columns
Rem     ahwang    05/20/04  - catch unupgraded evolved type data 
Rem     apareek   03/23/04  - fix domain idx tablespace 0 problem - Bug3543844
Rem     ahwang    11/13/03  - system owned objects filering
Rem     ahwang    10/08/03  - filter out recyclebin objects 
Rem     ahwang    09/23/03  - correct checking on REFs with partitions and 
Rem                           IOT;correct checking on bitmap join index; 
Rem     ahwang    09/10/03  - remove the incorrect REF self-containment check 
Rem     apareek   05/20/03  - allow MV support 
Rem     ahwang    03/16/03  - bug2723389 - proper detection of unsupported 
Rem                           MV objects
Rem     apareek   03/06/03  - allow ref col to be transported (Bug 895775)
Rem     amsrivas  10/18/02  - 2477350: check snapshots on partitioned tables
Rem     amsrivas  10/08/02  - 2447432: iot constraints should use ind$
Rem     araghava  02/12/02  - bug 1912886: partition numbers no longer go 
Rem                           from 1 -> n.
Rem     apareek   12/27/00  - bug 1560639
Rem     apareek   10/24/00 -  default tablespace for coop indexes ignored
Rem     apareek   08/15/00 -  allow non PL/SQL functional indexes in tts set
Rem     apareek   08/15/00 -  allow sec objs in tts set
Rem     amozes    07/21/00  - bitmap join index
Rem     amsrivas  04/06/00  - 1167617 capture indexes enforcing unique key
Rem     rshaikh   11/10/99 -  fix for sqlplus
Rem     apareek   08/05/99 -  block REF with referential cons- bug895775
Rem     apareek   07/19/99 -  fix bug 860417
Rem     mjungerm  06/15/99 -  add java shared data object type
Rem     apareek   06/16/99 -  ignore dropped undo segs
Rem     apareek   03/25/99 -  iots with lobs should go against ind$
Rem     apareek   02/22/99 -  bug824907 - partitioned iots
Rem     apareek   03/11/99 -  go against ind$ for iots
Rem     jwlee     01/06/99 -  Allow AQ to be transported
Rem     apareek   12/03/98 -  fix blanks for sqlplus
Rem     apareek   10/20/98 -  block functional indexes
Rem     apareek   10/12/98 -  add check for default tablespace
Rem     apareek   09/01/98 -  check for undo segs
Rem     apareek   08/25/98 -  IOT and overflow segment self contained
Rem     apareek   08/24/98 -  foreign key constraint is only a 1 way violation
Rem     apareek   08/20/98 -  allow VARRAY, NESTED TABLES, IOTS
Rem     apareek   08/06/98 -  disallow SYS owned objects
Rem     apareek   08/06/98 -  capture secondary objects, domain indexes
Rem     apareek   08/05/98 -  allow FILE columns
Rem     apareek   07/31/98 -  fix bug 707999
Rem     apareek   07/31/98 -  add checks for subpartitions, partitioned lobs
Rem     ncramesh  08/04/98 -  change for sqlplus
Rem     apareek   06/24/98 -  TS_PITR_INFO -> TS_PLUG_INFO
Rem     apareek   05/19/98 -  Add mesg_id column
Rem     jwlee     05/18/98 -  STRADDLING_RS_OBJECTS -> STRADDLING_TS_OBJECTS
Rem     jwlee     05/03/98 -  pluggable_set_check -> transportable_set_check
Rem     apareek   04/27/98 -  creation
Rem     apareek   04/06/98 -  Creation
Rem

REM
REM  tts_tab_view is a view used by TTS containment check. 
REM  tts_tab_view column set is a subset of of tab$'s except it resolves 
REM  the tablespace nmber. Note that tab$.ts# is zero for objects like IOTs
REM  and partitioned tables. This view currenly resolves ts# for 'normal'
REM  tables, IOTs, partitioned tables. It is currently employed by REF
REM  and joined index containment check. If ts# resolution for other table
REM  types are necessary, one can add to this union view definition.
REM

create or replace view tts_tab_view(obj#, ts#, property) as
/* 'simple' case, no IOT, no parition - return object's ts#*/
select t.obj#,t.ts#, t.property
from   tab$ t
where  BITAND(t.property, 2151678048)=0
union all
/* IOT - returns IOT index object's ts# */
select t.obj#, i.ts#, t.property
from   tab$ t, ind$ i
where  BITAND(t.property, 72)=72 AND i.bo#=t.obj#
union all
/* partitioned table - returns partitioned objects default ts#.
   Note that it is not necessary to check against all partitions and
   subpartitions because (1) there is already a check for containment
   among default tablespace and partition and subpartition tablespaces,
   (2) containment property is transitive.
*/
select t.obj#, po.defts#, t.property
from   tab$ t, partobj$ po
where  BITAND(t.property, 40)=40 and po.obj#=t.obj#;

REM tts_obj_view - view of obj$ that filters out recyclebin objects
create or replace view tts_obj_view as
select obj#,
       dataobj#,
       owner#,
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
       spare6
from "_CURRENT_EDITION_OBJ" where bitand(flags, 128)=0;

grant select on tts_obj_view to SELECT_CATALOG_ROLE;
grant select on tts_tab_view to SELECT_CATALOG_ROLE;

Rem
Rem View Name   : PLUGGABLE_SET_CHECK
Rem
Rem View Schema 
Rem ===========
Rem
Rem     (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
Rem      OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER, TS2_NAME,
Rem      CONSTRAINT_NAME,REASON
Rem     )
Rem
Rem Column Name                    Description
Rem ======================================================
Rem  OBJ1_OWNER                   Owner of object 1
Rem  OBJ1_NAME                    Object 1
Rem  OBJ1_SUBNAME                 SubObject1Name
Rem  OBJ1_TYPE                    Object Type     
Rem  TS1_NAME                     Tablespace containing Object 1 
Rem  OBJ2_NAME                    Object Name 
Rem  OBJ2_SUBNAME                 SubObject2Name
Rem  OBJ2_TYPE                    Object Type
Rem  OBJ2_OWNER                   Object owner of second object 
Rem  TS2_NAME                     Tablespace containing Object 1
Rem  CONSTRAINT_NAME              Name of dependent constraint
Rem  REASON                       Reason for Pluggable check violation
Rem
Rem
Rem
Rem Comments on View : PLUGGABLE_SET_CHECK
Rem ==========================================
Rem
Rem
Rem
Rem A transportable set needs to be self contained.  This means that there
Rem should be no dependencies that exist on objects that are not contained
Rem in the tablespaces that are being transported.
Rem To transport a tablespace in Oracle Version 8.1 
Rem at the time of export there can be no references going out of the 
Rem the Pluggable Set(PS) i.e the set of non-system tablespaces to be
Rem transported.  This view captures any  references not fully contained in
Rem the pluggable set.

Rem In addition, it checks for presence of objects in the pluggable set
Rem that are not supported 
Rem
Rem
Rem The view needs to return 0 rows for the export phase to proceed.

Rem The following scenarios will show up in the view:



Rem     - Replication master tables are in the pluggable set
Rem     - Tables/Clusters and associated indexes not fully contained in the RS
Rem     - Partitioned Objects (tables and indexes) not fully contained in the
Rem       PS
Rem     - includes, straddling table partitions and straddling table and index
Rem       partition
Rem     - Tables that have a parent-child relationship via referential 
Rem       integrity
Rem       constraints are not fully contained in the RS
Rem     - Lob Segments, Lob Indexes and referencing tables are not fully 
Rem       contained in the RS





Rem =========================================================================
Rem 05/05/2002
Rem In 10i we will allow transport of objects having ref columns.  Please see
Rem Bugs 802824, 895775, 907734 which all were fixed after column ordering
Rem support was added to the kernel and export and import. I earlier had a 
Rem check that would catch these types of objects (col$.property = 0x80000)
Rem and prevent them for being exported.  (Msg id 42)
Rem
Rem 05/09/2002
Rem Allow primary key-based IOD$ column (property 0x1000)

Rem ==========================================================================


CREATE OR REPLACE VIEW straddling_ts_objects
    (object1, ts1, object2, ts2, reason_id, mesg_id) AS
  -- Report base table and lob segment that are in different tablespaces
  -- Exclude iots
  SELECT t.obj#, t.ts#, l.lobj#, l.ts#,
         'Base table and lob object not fully contained in pluggable set', 1
  FROM   tab$ t, lob$ l
  WHERE  l.ts# != t.ts# AND l.obj# = t.obj# AND BITAND(t.property, 64) = 0
UNION ALL
  -- Report dependencies between objects in different tablespaces that are 
  -- enforced through constraints.
  -- Exclude disabled constraints.
  -- Handle IOTs (property 0x40) and partitioned (property 0x20) tables 
  --   whose tablespace # is always 0.
  SELECT t.obj#, 
         decode(BITAND(t.property, 96), 0, t.ts#, 
                32, (select po.defts# from partobj$ po where po.obj# = t.obj#),
                64, (select max(i.ts#) from ind$ i where i.bo# = t.obj#)),
         c.obj#,
         decode(BITAND(t2.property, 96), 0, t2.ts#, 
                32, (select po.defts# from partobj$ po where po.obj# = t2.obj#),
                64, (select max(i.ts#) from ind$ i where i.bo# = t2.obj#)),
         'Constraint between tables not contained in pluggable set', 2
  FROM   tab$ t2, cdef$ c, tab$ t
  WHERE  c.robj# = t.obj# AND c.obj# = t2.obj# AND 
         decode(BITAND(t.property, 96), 0, t.ts#, 
                32, (select po.defts# from partobj$ po where po.obj# = t.obj#),
                64, (select max(i.ts#) from ind$ i where i.bo# = t.obj#)) != 
         decode(BITAND(t2.property, 96), 0, t2.ts#, 
                32, (select po.defts# from partobj$ po where po.obj# = t2.obj#),
                64, (select max(i.ts#) from ind$ i where i.bo# = t2.obj#)) AND
         c.enabled IS NOT NULL
UNION ALL
  -- Report tables whose indexes are not in the same tablespace.
  -- Exclude partitioned objects , they are checked for separately.
  -- Exclude indexes on any unsupported TSPITR objects.
  -- Exclude indexes enforcing primary key constraints and unique constraints,
  --   these are checked for separately
  -- Exclude iots
  -- Exclude domain indexes, they are done separately
  SELECT t.obj#, t.ts#, i.obj#, i.ts#,
      'Tables and associated indexes not fully contained in the pluggable set',
         3
  FROM   tab$ t, ind$ i
  WHERE  t.obj# = i.bo# AND t.ts# != i.ts# AND BITAND(t.property, 32) = 0 AND
         BITAND(i.property, 2) = 0 AND BITAND(t.property, 131072) = 0 AND
         BITAND(t.property, 64) = 0 AND i.type# != 9
  MINUS
  -- Excluding indexes enforcing primary key constraints
  -- fix bug 860417  - exclude partitioned objects */
  --     bug 1167617 - exclude indexes enforcing unique key constraints
  SELECT t.obj#, t.ts#, i.obj#, i.ts#,
      'Tables and associated indexes not fully contained in the pluggable set',
         3
  FROM   tab$ t, ind$ i , cdef$ cf
  WHERE  t.obj# = cf.obj# AND i.obj# = cf.enabled AND cf.type# in( 2,3) AND
         t.ts# != i.ts# AND i.bo#=t.obj# AND BITAND(t.property, 32) = 0 
UNION ALL
  -- Report any partitioned tables where the default ts is 0
  -- Bug 11682089: exclude global partitioned index enforcing primary key/
  --               unique key constraint on non-partitioned table.
  SELECT t.obj#, t.ts#, i.obj#, i.ts#,
         'Table and Index enforcing primary key/unique key constraint not in same tablespace',
         4
  FROM   tab$ t, ind$ i , cdef$ cf
  WHERE  t.obj# = cf.obj# AND i.obj# = cf.enabled AND cf.type# in (2,3) AND
         t.ts# != i.ts# AND i.bo#=t.obj# AND BITAND(t.property, 64) = 0 AND
         BITAND(t.property, 32) = 0 AND BITAND(i.property, 2) = 0
UNION ALL
  -- Report clusters whose indexes are not in the same tablespace
  SELECT c.obj#, c.ts#, i.obj#, i.ts#,
         'Tables/Clusters and associated indexes not fully contained in the pluggable set',
         5
  FROM   clu$ c, ind$ i
  WHERE  c.obj# = i.bo# AND c.ts# != i.ts#
UNION ALL
  -- Report partitioned tables with at least two partitions in different
  -- tablespaces
  SELECT tp1.obj#, tp1.ts#, tp.obj#, tp.ts#,
         'Partitioned Objects not fully contained in the pluggable set', 6
  FROM   tabpart$ tp,
         (SELECT  bo#,
                  min(ts#) keep (dense_rank first order by part#) ts#,
                  min(file#) keep (dense_rank first order by part#) file#,
                  min(block#) keep (dense_rank first order by part#) block#,
                  min(obj#) keep (dense_rank first order by part#) obj#
          FROM    tabpart$
          WHERE   file# != 0 and block# != 0
          GROUP BY bo#) tp1
  WHERE   tp1.bo# = tp.bo# AND tp1.ts# != tp.ts# AND tp.file# !=0 AND
          tp.block# != 0
UNION ALL
  -- Report partitioned indexes that are in different tablespaces than any
  -- partition in the table.
  -- Exclude partitioned iots - no storage (check for null header)
  SELECT tp1.obj#, tp1.ts#, ip.obj#, ip.ts#,
         'Partitioned Objects not fully contained in the pluggable set', 7
  FROM   indpart$ ip, ind$ i,
         (SELECT bo#,
                 min(ts#) keep (dense_rank first order by part#) ts#,
                 min(file#) keep (dense_rank first order by part#) file#,
                 min(block#) keep (dense_rank first order by part#) block#,
                 min(obj#) keep (dense_rank first order by part#) obj#
          FROM   tabpart$
          WHERE  file# != 0 AND block# != 0
          GROUP BY bo#) tp1
  WHERE   tp1.bo# = i.bo# AND ip.bo# = i.obj# and tp1.ts# != ip.ts#
UNION ALL
  -- Report partitioned tables and non-partitioned index in different
  -- tablespaces
  -- Exclude domain indexes, they are done separately
  SELECT tp.obj#, tp.ts#, i.obj#, i.ts#,
         'Partitioned Objects not fully contained in the pluggable set', 8
  FROM   tabpart$ tp, ind$ i
  WHERE  tp.ts#! = i.ts# AND BITAND(i.property, 2) = 0 AND tp.bo# = i.bo# AND
         i.type# != 9
union all
  -- Report partitioned index and non-partitioned table in different
  -- tablespaces
  -- Exclude domain indexes, they are done separately
  SELECT t.obj#, t.ts#, ip.obj#, ip.ts#,
         'Partitioned Objects not fully contained in the pluggable set', 9
  FROM   indpart$ ip, tab$ t, ind$ i
  WHERE  ip.ts#! = t.ts# AND t.property = 0 AND ip.bo# = i.obj# AND
         i.bo# = t.obj# AND i.type# != 9
UNION ALL
  -- Reoprt objects that are not supported
  --   tab$.property - 0x20000 = AQs  
  -- Look at objects that have storage Tables, IOTs, Partitions, Subpartitions
  --
  -- 8.0 compatible AQ with multiple recipients
  SELECT t.obj#, t.ts#, -1, -1 , 'Object not allowed in Pluggable Set', 10
  FROM   sys.dba_queue_Tables q, obj$ o, user$ u, tab$ t
  WHERE  q.recipients = 'MULTIPLE' AND SUBSTR(q.compatible, 1, 3) = '8.0' AND
         q.queue_table = o.name AND q.owner = u.name AND u.user# = o.owner# AND
         o.obj# = t.obj#
UNION ALL
  -- Report any Composite partitions/Subpartitions that are not in the same
  -- tablespace.  Check the tablespace of the first subpartition of partition 1
  -- against all tablespaces of other subpartitions for the same object
  SELECT v1.obj#, v1.ts#, v2.obj#, v2.ts#,
         'Subpartitions not fully contained in Transportable Set', 15
  FROM   (SELECT MIN(tsp.obj#) keep (dense_rank first 
                 order by tcp.part#, tsp.subpart#) obj#,
                 MIN(tsp.ts#) keep (dense_rank first 
                 order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
          FROM   tabcompart$ tcp, tabsubpart$ tsp
          WHERE  tsp.pobj# = tcp.obj#
          GROUP BY tcp.bo#) v1,
         (SELECT tsp.obj#, ts#, tcp.bo# 
          FROM   tabcompart$ tcp, tabsubpart$ tsp
          WHERE  tsp.pobj# = tcp.obj#) v2
  WHERE   v1.bo# = v2.bo# AND v1.ts# != v2.ts#
UNION ALL
  -- Report any composite table partitions and index composite partitions that
  -- are not in the same tablespace.
  SELECT v3.obj#, v3.ts#, v4.obj#, v4.ts#,
         'Table subpartition and index subpartition not fully contained in the Transportable Set',
         16
  FROM   (SELECT MIN(tsp.obj#) keep (dense_rank first 
                 order by tcp.part#, tsp.subpart#) obj#,
                 MIN(tsp.ts#) keep (dense_rank first
                 order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
          FROM   tabcompart$ tcp, tabsubpart$ tsp
          WHERE  tsp.pobj# = tcp.obj#
          GROUP BY tcp.bo#) v3,
         (SELECT isp.obj#,ts#,icp.bo#
          FROM   indcompart$ icp, indsubpart$ isp
          WHERE  isp.pobj# = icp.obj#) v4, ind$ i
  WHERE  i.bo# = v3.bo# AND v4.bo# = i.obj# AND v4.ts# != V3.ts#
UNION ALL
  SELECT lf.fragobj#, lf.ts#, tp.obj#, tp.ts#,
         'Table partition and lob fragment not in Transportable Set', 17
  FROM   lobfrag$ lf, tabpart$ tp
  WHERE  lf.tabfragobj# = tp.obj# AND tp.ts# !=lf.ts#
UNION ALL
  -- Report Subpartitions having lob fragments
  SELECT tsp.obj#, tsp.ts#, lf.fragobj#, lf.ts#,
         'Table Subpartition and lob fragment not fully contained in pluggable set',
         18
 FROM    tabsubpart$ tsp, lobfrag$ lf
  WHERE  tsp.obj# = lf.tabfragobj# AND tsp.ts# != lf.ts#
--UNION ALL
--  -- Report all objects owned by SYS
--  -- NON-Partitioned table
--  SELECT o.obj#, t.ts#, -1, -1,
--         'Sys owned tables not allowed in Transportable Set', 19
--  FROM   tab$ t, obj$ o
--  WHERE  t.obj# = o.obj# AND BITAND(t.property, 32) = 0 AND o.owner# = 0
--UNION ALL
--  -- Partitioned tables
--  SELECT o.obj#, tp.ts#, -1, -1,
--         'Sys owned partitions not allowed in Transportable Set', 20
--  FROM   tabpart$ tp, obj$ o
--  WHERE  tp.obj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- clusters
--  SELECT o.obj#, c.ts#, -1, -1,
--         'Sys owned clusters not allowed in Transportable Set', 21
--  FROM   clu$ c, obj$ o
--  WHERE  c.obj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- subpartitions
--  SELECT o.obj#, tsp.ts#, -1, -1,
--         'Sys owned subpartitions not allowed in Transportable Set', 22
--  FROM   tabsubpart$ tsp, obj$ o
--  WHERE  tsp.obj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- non-partitioned indexes
--  SELECT o.obj#, i.ts#, -1, -1,
--         'Sys owned indexes not allowed in Transportable Set', 23
--  FROM   ind$ i, obj$ o
--  WHERE  i.obj# = o.obj# AND o.owner# = 0 AND BITAND(i.property, 2) =0
--UNION ALL
--  -- Partitioned indexes
--  SELECT o.obj#, ip.ts#, -1, -1,
--         'Sys owned partitioned indexes not allowed in Transportable Set', 24
--  FROM   indpart$ ip, obj$ o
--  WHERE  ip.obj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- subpartitioned indexes
--  SELECT o.obj#, isp.ts#, -1, -1,
--         'Sys owned subpartitioned indexes not allowed in Transportable Set',
--         25
--  FROM   indsubpart$ isp, obj$ o
--  WHERE  isp.obj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- lobs
--  SELECT l.lobj#, l.ts#, -1, -1,
--         'Sys owned lobs not allowed in Transportable Set', 26
--  FROM   lob$ l, obj$ o
--  WHERE  l.lobj# = o.obj# AND o.owner# = 0
--UNION ALL
--  -- partitioned lobs
--  SELECT lf.fragobj#, lf.ts#, -1, -1,
--         'Sys owned lob fragments not allowed in Transportable Set', 27
--  FROM   lobfrag$ lf, obj$ o
--  WHERE  lf.fragobj# = o.obj# AND o.owner# = 0
UNION ALL
  -- Report any PL/SQL Functional Indexes
  SELECT i.obj#, i.ts#, -1, -1,
         'PLSQL Functional Indexes not allowed in Transportable Set', 29
  FROM   ind$ i
  WHERE  BITAND(i.property, 2048) = 2048
UNION ALL
  -- Report any iot and overflow segment are not in same tablespace
  -- The following will capture the IOT table.
  -- Bug-6652830: take care of partitioned objects and ignore lob indexes
  SELECT t.obj#,
         decode(BITAND(t.property, 32), 0, t.ts#, 32,
               (select po.defts# from partobj$ po where po.obj# = t.obj#)),
         i.obj#,
         decode(BITAND(i.property, 2), 0, i.ts#, 2,
               (select po.defts# from partobj$ po where po.obj# = i.obj#)),
         'IOT and Overflow segment not self contained', 30
  from   tab$ t, ind$ i
  where  t.bobj# = i.bo# AND i.type# != 8 AND
         BITAND(t.property,512) != 0 AND
         decode(BITAND(t.property, 32), 0, t.ts#, 32,
               (select po.defts# from partobj$ po where po.obj# = t.obj#)) !=
         decode(BITAND(i.property, 2), 0, i.ts#, 2,
               (select po.defts# from partobj$ po where po.obj# = i.obj#)) 
UNION ALL
  -- Report all default storage for a partitioned object that are outside of
  -- the transportable set.  Logical partitions are being excluded since they
  -- don't occupy storage.
  -- Exclude logical partitions
  -- Ensure that the default partition tablespace for table partitions is self
  -- contained
  SELECT po.obj#, defts#, tp.obj#, tp.ts#,
         'Default tablespace and partition not selfcontained', 33
  FROM   tabpart$ tp, partobj$ po
  WHERE  po.obj# = tp.bo# AND po.defts# != tp.ts# AND tp.block# != 0 AND
         tp.file# !=0
UNION ALL
  -- Default for partitioned object and table subpartition are self contained
  SELECT po.obj#, po.defts#, tcp.obj#, tcp.defts#,
         'Default tablespace and partition not selfcontained', 37
  FROM   tabcompart$ tcp, partobj$ po
  WHERE  tcp.bo# = po.obj# AND tcp.defts# != po.defts#
UNION ALL
  -- Report any default partition tablespace for index partitions not contained
  SELECT po.obj#, defts#, ip.obj#, ip.ts#,
         'Default tablespace and partition not selfcontained', 34
  FROM   ind$ i, indpart$ ip, partobj$ po
  WHERE  po.obj# = ip.bo# AND po.defts# != ip.ts# AND i.obj# = ip.bo# AND
         i.type# != 9
UNION ALL
  -- Report partitioned object and index subpartition default tablespace are
  -- self contained
  SELECT po.obj#, po.defts#, icp.obj#, icp.defts#,
         'Default tablespace and partition not selfcontained', 38
  FROM   indcompart$ icp, partobj$ po
  WHERE  icp.bo# = po.obj# AND icp.defts# != po.defts#
UNION ALL
  -- Report any default partition tablespace for subpartitions not contained
  -- for Tables
  SELECT tcp.obj#, defts#, tsp.obj#, tsp.ts#,
         'Default tablespace and partition not selfcontained', 35
  FROM   tabcompart$ tcp, tabsubpart$ tsp
  WHERE  tcp.obj# = tsp.pobj# AND tcp.defts# != tsp.ts#
UNION ALL
  -- Report any default partition tablespace for subpartitions not contained
  -- for Indexes
  SELECT icp.obj#, defts#, isp.obj#, isp.ts#,
         'Default tablespace and partition not selfcontained', 36
  FROM   indcompart$ icp, indsubpart$ isp
  WHERE  icp.obj# = isp.pobj# AND icp.defts# != isp.ts#
UNION ALL
  -- Report any IOTs where the index partitions are not contained
  SELECT ip1.obj#, ip1.ts#, ip2.obj#, ip2.ts#,
         'IOT partitions not self contained', 39
  FROM   (SELECT bo#, 
                 MIN(ts#) keep (dense_rank first order by part#) ts#,
                 MIN(obj#) keep (dense_rank first order by part#) obj#
          FROM   indpart$
          GROUP BY bo#) ip1, indpart$ ip2, ind$ i, tab$ t
  WHERE  ip1.bo#= i.obj# AND ip1.ts# != ip2.ts# AND ip2.bo# = i.obj# AND
         i.bo# = t.obj# AND BITAND(t.property, 64) != 0
UNION ALL
  -- Report all IOTs, overflow segments and index partitions not contained. We
  -- can take the first overflow segment partition and run it against all the
  -- index partitions.  This guarantees completeness since all index partitions
  -- are checked for seperately for self containment
  SELECT tp.obj#, tp.ts#,ip.obj#,ip.ts#,
         'Overflow and index partition not self contained', 40
  FROM   indpart$ ip, ind$ i, tab$ t,
         (SELECT  bo#, 
                  min(ts#) keep (dense_rank first order by part#) ts#,
                  min(obj#) keep (dense_rank first order by part#) obj#
          FROM    tabpart$
          GROUP BY bo#) tp
  WHERE   tp.bo# = t.obj# AND BITAND(t.property, 512) != 0 AND
          t.bobj# = i.bo# AND ip.bo#= i.obj# AND ip.ts# != tp.ts#
UNION ALL
  -- check iots having lobs
  -- Bug-6652830: exclude partitioned tables (property 0x20) since
  -- partitioned lob objects don't have ts# set while lob fragments do.
  SELECT t.obj#,i.ts#,l.lobj#, l.ts#,
         'Base table and lob object not fully contained in pluggable set', 41
  FROM   tab$ t, lob$ l, ind$ i
  WHERE  BITAND(t.property, 64)! = 0 AND BITAND(t.property, 32) = 0 AND
         l.ts#! = i.ts# AND l.obj# = t.obj# AND
         i.bo# = t.obj#
UNION ALL
  -- Report any join indexes that are not contained. The logging tables of join
  -- indexes are used during a transaction for updating purpose. They are not
  -- relevant for TTS since TTS are made read-only.
  -- Note that this is a one-way dependency.
  SELECT o1.obj#, t1.ts#, o2.obj#, t2.ts#,
         'Tables of the join index are not in the same tablespace', 43
  FROM   tts_obj_view o1, tts_obj_view o2, jijoin$ j, tts_tab_view t1,
         tts_tab_view t2
  WHERE  j.tab1obj# = o1.obj# AND j.tab2obj# = o2.obj# AND
         o1.obj# = t1.obj# AND o2.obj# = t2.obj# AND t1.ts# != t2.ts#
UNION ALL
  -- Report all tables having scoped REF constraints in different tablespaces.
  --   t.property  8 (0x08) -> has REF column
  --   Note that this is a one-way dependency
  SELECT t2.obj#, t2.ts#, o.obj#, t.ts#,
         'based table and its scoped REF object are in different tablespaces',
         44
  FROM   tts_obj_view o, tts_tab_view t, refcon$ c, 
         tts_obj_view o2, tts_tab_view t2
  WHERE  o.obj# = t.obj# AND c.obj# = o.obj# AND c.stabid = o2.oid$ AND
         BITAND(c.reftyp, 1) != 0 AND o2.obj#=t2.obj# AND t.ts# != t2.ts# AND
         BITAND(t.property, 8) = 8
UNION ALL
  -- Disallow evolved type data that have not been upgraded.
  SELECT o.obj#, t.ts#, -1, -1,
         'Evolved type data that have not been upgraded are not allowed in a Transportable Set',
         45
  FROM   coltype$ c, obj$ o, tts_tab_view t
  WHERE  o.obj# = c.obj# AND t.obj# = o.obj# AND BITAND(c.flags, 256) != 0
UNION ALL
  -- Tables with encrypted columns not supported
  SELECT t.obj#, t.ts#, -1, -1,
         'Tables with encrypted columns not allowed in Transportable Set', 46
  FROM   tab$ t, tts_obj_view o
  WHERE  t.obj# = o.obj# AND BITAND(t.trigflag, 65536) = 65536
UNION ALL
  -- Tables with parent ref partition tables
  SELECT t1.bo#, t1.ts#, t2.bo#, t2.ts#,
         'Ref partitioned child table included but not parent table', 47
  FROM   tabpart$ t1, tabpart$ t2, cdef$ c
  WHERE  t1.bo# = c.obj# and t2.bo# = c.robj# and t1.part# = t2.part# and
         t1.ts# != t2.ts# 
;

grant select on STRADDLING_TS_OBJECTS to SELECT_CATALOG_ROLE;


Rem =============================================================================
Rem                                                                             #
Rem      VIEW NAME     TS_PLUG_INFO                                             #
Rem                                                                             #
Rem =============================================================================

/* need to exclude recyclebin objects by checking obj$.flags mask 128 */

create or replace view TS_PLUG_INFO 
       (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
        OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
        CONSTRAINT_NO,REASON,MESG_ID)
as
select u.name owner,o1.name,o1.subname,
       decode(o1.type#,0, 'NEXT OBJECT', 1, 'INDEX',
                          2, 'TABLE', 3, 'CLUSTER',
                          4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                          7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                          11, 'PACKAGE BODY', 12, 'TRIGGER',
                          13, 'TYPE', 14, 'TYPE BODY',
                          19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                          21, 'LOB', 22, 'LIBRARY', 23, 'DIRECTORY',
                          28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                          30, 'JAVA RESOURCE', 34, 'TABLE SUBPARTITION', 
                          40, 'LOB', 56, 'JAVA DATA', '         '),
        ts1.name,o2.name,o2.subname, 
        decode(o2.type#, 0, 'NEXT OBJECT', 1, 'INDEX',
                          2, 'TABLE', 3, 'CLUSTER',
                          4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                          7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                          11, 'PACKAGE BODY', 12, 'TRIGGER',
                          13, 'TYPE', 14, 'TYPE BODY',
                          19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                          21, 'LOB', 22, 'LIBRARY', 23, 'DIRECTORY',
                          28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                          30, 'JAVA RESOURCE', 34,'TABLE SUBPARTITION', 
                          40, 'LOB', 56, 'JAVA DATA', '         '),
        o2.owner#,ts2.name,cf.con#,s.reason_id,mesg_id
from straddling_ts_objects s, obj$ o1, obj$ o2, ts$ ts1, ts$ ts2 , user$ u,cdef$ cf
where s.object1=o1.obj# 
  and s.object2=o2.obj#(+)
  and s.ts1=ts1.ts#
  and s.ts2=ts2.ts#(+)
  and o1.owner#=u.user#
  and s.object2=cf.obj#(+)
  and s.object1=cf.robj#(+)
  and bitand(o1.flags, 128)=0
  and (o2.flags is null or bitand(o2.flags, 128)=0)
union all
  -- Report undo segs in transportable set
  SELECT 'SYS', u.name, NULL, 'ROLLBACK SEGMENT', ts.name, NULL, NULL, NULL,
         -1, NULL, -1, 'Rollback Segment not allowed in transportable set',  32
  FROM   undo$ u, ts$ ts
  WHERE  u.ts# = ts.ts# AND ts.ts# != 0 AND u.status$ != 1;

grant select on TS_PLUG_INFO to SELECT_CATALOG_ROLE;

Rem ===========================================================================
Rem                                                                           #
Rem     VIEW NAME       UNI_PLUGGABLE_SET_CHECK                               #
Rem                                                                           #
Rem ===========================================================================



create or replace view UNI_PLUGGABLE_SET_CHECK
        (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
         OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
         CONSTRAINT_NAME,REASON,MESG_ID)
as
   select obj1_owner,obj1_name,obj1_subname,obj1_type,ts1_name,
          obj2_name,obj2_subname,obj2_type,u.name,nvl(ts2_name,'-1'),
          c.name,reason,mesg_id
   from  ts_plug_info t, user$ u, con$ c
   where u.user#(+)=t.obj2_owner
   and   c.con#(+)=t.constraint_no ;



Rem ===========================================================================
Rem                                                                           #
Rem     VIEW NAME       PLUGGABLE_SET_CHECK                                   #
Rem                                                                           #
Rem ===========================================================================


Rem Create the main view as a self union of UNI_PLUGGABLE_SET_CHECK so that we
Rem can capture dependencies in either direction

create or replace view PLUGGABLE_SET_CHECK
        (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
         OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
         CONSTRAINT_NAME,REASON,MESG_ID)
as
    select * from UNI_PLUGGABLE_SET_CHECK
union all
    select OBJ2_OWNER,OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,TS2_NAME,
           OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,OBJ1_OWNER,TS1_NAME,
           CONSTRAINT_NAME,REASON,MESG_ID
    from  UNI_PLUGGABLE_SET_CHECK
    where obj1_type in ('TABLE PARTITION','LOB','TABLE',
                        'TABLE SUBPARTITION') and  
          obj2_type in ('TABLE PARTITION','LOB','TABLE',
                        'TABLE SUBPARTITION') 
      and mesg_id not in (2, 43, 44);

/* Note that we skip 2, 43, 44 since they are one-way  dependencies. */
/* Bug-6652830: msgid 30 IOT and overflow straddling is one-way dependency */

grant select on PLUGGABLE_SET_CHECK to SELECT_CATALOG_ROLE;

Rem============================================================================
