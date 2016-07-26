Rem
Rem NAME
Rem   CATPITR.SQL
Rem FUNCTION
Rem   Tablespace Point in Time specific views 
Rem NOTES
Rem   This script must be run while connected as SYS or INTERNAL
Rem    MODIFIED   (MM/DD/YY)
Rem     apfwkr    07/23/12  - Backport tbhukya_bug-14083382 from
Rem     mawatts   01/09/08  - bug 6620517: bogus row for an IOT-with-LOB
Rem     rasivara  05/16/06  - bug 5192382: Check for masked bits in trigflag 
Rem     ahwang    12/11/03  - Ignore recyclebin objects during RS check 
Rem     amsrivas  11/08/02  - 2477350: check snapshots on partitioned tables
Rem     araghava  02/11/02  - bug 1912886: partition numbers no longer go 
Rem                           from 1 -> n.
Rem     apareek   12/27/00  - bug 1560639
Rem     amozes    05/31/00  - bitmap join index support
Rem     cyyip     02/22/00 -  fix for sqlplus
Rem     apareek   08/05/99 -  Restrict REF columns with ref constraints
Rem     apareek   06/30/99 -  fix bug 860417
Rem     mjungerm  06/15/99 -  add java shared data object type
Rem     apareek   06/16/99 -  ignore dropped undo segs
Rem     apareek   04/26/99 -  iots with lobs should go against ind
Rem     apareek   03/11/99 -  partitioned iots self contained
Rem     apareek   03/11/99 -  exclude logical partitions 
Rem     apareek   03/11/99 -  check for iots against ind
Rem     apareek   12/03/98 -  fix blanks for sqlplus
Rem     apareek   10/20/98 -  block functional indexes
Rem     apareek   09/08/98 -  capture rollback segs
Rem     apareek	  08/28/98 -  make sure iot and overflow seg self-contained
Rem	apareek	  08/20/98 -  remove IOT,Nested tables,VARRAY restrictions
Rem     apareek   08/06/98 -  remove BFILE restriction
Rem     apareek   08/05/98 -  disallow SYS owned objects
Rem     ncramesh  08/04/98 -  change for sqlplus
Rem     apareek   06/12/98 -  partitioned lobs, subpartitions
Rem     apareek   06/11/98 -  check for subpartitions
Rem     apareek   04/10/98 -  secondary objs and functional indexes
Rem     apareek   06/23/97 -  detect snapshots,fix 484226
Rem     apareek   06/24/97 -  capture primary key constraint relationships 
Rem     apareek   06/06/97 -  capture global non-partitioned indexes
Rem     apareek   05/12/97 -  use nvl for ts2_name 
Rem     apareek   04/24/97 -  add constraint name to view
Rem     apareek   04/18/97 -  fix bug 480823
Rem     apareek   04/08/97 -  change TS_PITR_DROPPED_OBJECTS name
Rem     apareek   03/27/97 -  add tablespace column to TS_PITR_DROPPED_OBJECTS
Rem     apareek   03/17/97 -  new column for  partition name in TS_PITR_CHECK
Rem     asurpur   01/03/97 -  Granting select on views to SELECT_CATALOG_ROLE
Rem     apareek   11/12/96 -  view for reporting objects lost due to tspitr
Rem     apareek   11/12/96 -  added check for queue tables
Rem     apareek   11/10/96 -  check for queue tables using new property flag
Rem     apareek   10/08/96 -  Creation
Rem
Rem
Rem View Name   : TS_PITR_CHECK
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
Rem ======================================== ======== ====
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
Rem  CONSTRAINT_NAME		name of dependent constraint
Rem  REASON                       Reason why Tablespace Point in Recovery cannot proceed           
Rem
Rem
Rem
Rem Comments on View : TS_PITR_CHECK
Rem ================================
Rem
Rem
Rem
Rem To perform Point-Intime-Tablespace-Recovery(PITR) in Oracle Version 8.0 
Rem at the time of export there can be no references going in or out of the 
Rem the Recovery Set(RS) i.e the set of non-system tablespaces to be recovered.
Rem This view captures any such references not fully contained in the recovery
Rem set.
Rem In addition, it checks for presence of objects in the recovery set
Rem that are not supported 
Rem
Rem
Rem The view needs to return 0 rows for the export phase to proceed.

Rem The following scenarios will show up in the view:

	
Rem  	- IOT tables exist in the recovery set
Rem	- IOT overflow segments exist in the recovery set
Rem	- Replication master tables are in the recovery set
Rem	- Snapshot tables are in the recovery set
Rem	- Snapshot logs are in the recovery set
Rem	- Tables or Extent tables that have associated nested tables
Rem	- Tables or Extent tables that contain a VARRAY collection type
Rem	- Tables/Clusters and associated indexes not fully contained in the RS
Rem	- Partitioned Objects (tables and indexes) not fully contained in the RS
Rem	  includes, straddling table partitions and straddling table and index
Rem	  partition
Rem	- Tables that have a parent-child relationship via referential integrity
Rem	  constraints are not fully contained in the RS
Rem	- Lob Segments, Lob Indexes and referencing tables are not fully 
Rem	  contained in the RS
Rem     - Secondary Objects, Functional indexes exist in the recovery set

Rem     - STRADDLING_RS_OBJECTS does not filter out the recyclebin objects.
Rem     - Views or code using STRADDLING_RS_OBJECTS must do such
Rem     - filtering. See TS_PITR_INFO for example.


Rem ==============================================================================

create or replace view STRADDLING_RS_OBJECTS 
	(OBJECT1,TS1,OBJECT2,TS2,REASON_ID ) 
as
/* check whether base table and lob segment are in different tablespaces */
/* Exclude iots */
(select t.obj#, t.ts#, l.lobj#, l.ts#, 'Base table and lob object not fully contained in recovery set'
from tab$ t, lob$ l
where l.ts#!=t.ts# 
  and l.obj#=t.obj#
  and bitand(t.property,64)=0)
union all
/* check iots having lobs */
select t.obj#,i.ts#,l.lobj#, l.ts#,'Base table and lob object not fully contained in pluggable set'
from  tab$ t, lob$ l, ind$ i
where bitand(t.property,64)!=0
  and l.ts#!=i.ts# 
  and l.obj#=t.obj#
  and i.bo# = t.obj#
union all
/* iot and overflow segment are self contained */
select t.obj#, t.ts#, i.obj#, i.ts#, 'IOT and Overflow segment not self contained'
from   tab$ t, ind$ i
where  t.bobj# = i.bo#
  and  t.ts# !=  i.ts#	
  and  bitand(t.property,512) != 0
union all
/* Are there dependencies between objects in different tablespaces that 
   are enforced through constraints, also ignore constraints that are 
   disabled
*/
select t.obj#,t.ts#,cdef$.obj#,t2.ts#,'constraint between tables not contained in recovery set'
from tab$ t2,cdef$, tab$ t
where cdef$.robj#=t.obj# 
  and cdef$.obj#=t2.obj#
  and t.ts# != t2.ts#
  and cdef$.enabled is not null
union all
/* tables whose indexes are not in the same tablespace.
   Ignore the following:
    partitioned object - checked separately
    indexes on unsupported TSPITR objects
    indexes enforcing primary key constraints - checked separately
    join indexes - checked separately
    IOT's with indexes of type LOB - see "check iots having lobs" above
*/
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the recovery set'
from  tab$ t, ind$ i
where t.obj#=i.bo# 
  and t.ts# != i.ts#
  and bitand(t.property,32)= 0
  and bitand(i.property,2 ) = 0
  and bitand(t.property, 4096) = 0
  and bitand(t.property, 131072)=0
  and bitand(i.property, 1024) = 0			/* skip join indexes */
minus  /* indexes enforcing primary key constraints */
      /* fix bug 860417 - exclude partitioned objects */
      /* fix bug 6620517 - exclude IOT's with indexes of type LOB */
      /* Fix bug 14083382 - Exclude IOT's with secondary index */
(
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the recovery set'
from  tab$ t, ind$ i , cdef$ cf
where t.obj#=cf.obj#
  and i.obj#=cf.enabled
  and cf.type#=2 
  and t.ts# != i.ts#
  and i.bo#=t.obj#
  and bitand(t.property,32)= 0 
  and bitand(t.property, 4096) = 0 
union all
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the recovery set'
from  tab$ t, ind$ i
where t.obj#=i.bo#
  and t.ts# != i.ts#
  and  bitand(t.property,64)!=0   /* IOT base table */
  and i.type# = 8                 /* index type is LOB */
union all
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the recovery set'
from  tab$ t, ind$ i
where t.obj#=i.bo#
  and t.ts# != i.ts#
  and bitand(t.property,64)!=0   /* IOT base table */
  and bitand(i.flags,128)!=0
)
union all
/* Capture indexes enforcing primary key constraints, ignore internally generated snapshot/indexes */
/* Exclude iots , ALso exclude partitioned tables since they have no storage */ 
/* The tablespace for partitioned tables defaults to 0 and thus there will   */
/* always be a violation */
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Table and Index enforcing primary key constraint not in same tablespace'
from  tab$ t, ind$ i , cdef$ cf
where t.obj#=cf.obj#
  and i.obj#=cf.enabled
  and cf.type#=2 
  and t.ts# != i.ts#
  and i.bo#=t.obj#
  and bitand(t.property,64)=0
  and bitand(t.property,32)= 0
  and bitand(t.property, 4096) = 0
minus  /* primary key constraints on internally generated snapshot tables */
/* exclude partitioned objects and unsupported objects */
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Table and Index enforcing primary key constraint not in same tablespace'
from  tab$ t, ind$ i, obj$ o, user$ u, snap$ s
where t.obj#=i.bo# 
  and t.ts# != i.ts#
  and s.tname=o.name
  and s.sowner=u.name
  and o.obj#=t.obj#
  and o.owner#=u.user#
  and bitand(t.property,32)= 0
  and bitand(t.property, 4096) = 0
union all
/* clusters whose indexes are not in the same tablespace 		*/
select c.obj# object1, c.ts# ts1, i.obj# object2, i.ts# ts2,'Tables/Clusters and associated indexes not fully contained in the recovery set' 
from clu$ c, ind$ i
where c.obj#=i.bo# 
  and c.ts# != i.ts#
union all
/* partitioned tables with at least two partitions in different tablespaces */
/* Exclude logical partitions - they have no storage . eg partitioned iots */
select tp1.obj#, tp1.ts#, tp.obj#, tp.ts#, ' Partitioned Objects not fully contained in the recovery set' 
from tabpart$ tp, 
     (select  bo#, 
              min(ts#) keep (dense_rank first order by part#) ts#,
              min(file#) keep (dense_rank first order by part#) file#,
              min(block#) keep (dense_rank first order by part#) block#,
              min(obj#) keep (dense_rank first order by part#) obj#
      from     tabpart$
      where file# != 0 and block# != 0
      group by bo#) tp1
where tp1.bo# = tp.bo#
  and tp1.ts# != tp.ts#
  and tp.file# != 0
  and tp.block# != 0
union all
/* partitioned indexes that are in tablespace different than any table 
   partitions. Exclude partitioned iots - no storage (check for null header)
*/
select tp1.obj#,tp1.ts#,ip.obj#,ip.ts#, '  Partitioned Objects not fully contained in the recovery set'
from indpart$ ip, ind$ i,
     (select   bo#, 
               min(ts#) keep (dense_rank first order by part#) ts#,
               min(file#) keep (dense_rank first order by part#) file#,
               min(block#) keep (dense_rank first order by part#) block#,
               min(obj#) keep (dense_rank first order by part#) obj#
      from     tabpart$
      where    file# != 0 and block# != 0
      group by bo#) tp1
where tp1.bo# = i.bo#
  and ip.bo#  = i.obj#
  and tp1.ts# != ip.ts#
union all
/* partitioned table and non-partitioned index in different tablespaces */ 
select tp.obj#, tp.ts#, i.obj#, i.ts#, ' Partitioned Objects not fully contained in the recovery set'
from tabpart$ tp, ind$ i
where tp.ts#!=i.ts#
  and bitand(i.property,2) =0
  and tp.bo#=i.bo#
  and bitand(i.property, 1024) = 0			/* skip join indexes */
union all
/*  partitioned index and non-partitioned table in different tablespaces */
select t.obj#, t.ts#, ip.obj#, ip.ts#, ' Partitioned Objects not fully contained in the recovery set' 
from indpart$ ip, tab$ t, ind$ i
where ip.ts#!=t.ts#
  and t.property=0
  and ip.bo#=i.obj#
  and i.bo#=t.obj#
  and bitand(i.property, 1024) = 0			/* skip join indexes */
union all
/* join index and parent table (or table (sub)partition) in different ts */
select v1.obj#, v1.ts#, v2.obj#, v2.ts#, 'Join Index related objects not fully contained in the recovery set'
from
 (select obj# to#, obj#, ts# from tab$
  union all
  select bo# to#, obj#, ts# from tabpart$
  union all
  select tcp.bo# to#, tsp.obj#, tsp.ts# from tabsubpart$ tsp, tabcompart$ tcp
   where tsp.pobj# = tcp.obj#
 ) v1,
 (select obj# io#, obj#, ts# from ind$
   where bitand(property, 1024) = 1024
  union all
  select ip.bo# io#, ip.obj#, ip.ts# from indpart$ ip, ind$ i
   where ip.bo# = i.obj# and bitand(i.property, 1024) = 1024
  union all
  select icp.bo# io#, isp.obj#, isp.ts# 
   from indsubpart$ isp, indcompart$ icp, ind$ i
   where isp.pobj# = icp.obj# and icp.bo# = i.obj#
   and bitand(i.property, 1024) = 1024
 ) v2,
 jijoin$ j
where v2.io# = j.obj#
and (v1.to# = j.tab1obj# or v1.to# = j.tab2obj#)
and v1.ts# != v2.ts#
union all
/* Handle Composite partitions */
/* Subpartitions that are not in the same tablespace */
/* Check the tablespace of the first subpartition of partition 1
   against all tablespaces of other subpartitions for the same object */ 
select V1.obj#, V1.ts# , V2.obj#, V2.ts#, 'Subpartitions not fully contained in recovery set'
from
      ( select   min(tsp.obj#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) obj#,
                 min(tsp.ts#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
        from     tabcompart$ tcp, tabsubpart$ tsp 
        where    tsp.pobj# = tcp.obj#
        group by tcp.bo#) V1,
      ( select tsp.obj#,ts#,tcp.bo# 
        from   tabcompart$ tcp, tabsubpart$ tsp 
        where  tsp.pobj# = tcp.obj#) V2
where
      V1.bo# = V2.bo#
  and V1.ts# != V2.ts#
union all
/* Make sure that composite table partitions and index composite partitions 
   are in the same tablespace */
select V3.obj#,V3.ts#,V4.obj#,V4.ts#, 'Table subpartition and index subpartition not fully contained in the recovery set'
from
      ( select   min(tsp.obj#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) obj#,
                 min(tsp.ts#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
        from     tabcompart$ tcp, tabsubpart$ tsp 
        where    tsp.pobj# = tcp.obj#
        group by tcp.bo#) V3,
      ( select isp.obj#,ts#,icp.bo# 
         from  indcompart$ icp, indsubpart$ isp 
         where isp.pobj# = icp.obj#) V4, ind$ i
where
        i.bo#  =  V3.bo# 
  and   V4.bo# =  i.obj# 
  and   V4.ts# != V3.ts#
union all
/* Partitions having lob fragments */
select lf.fragobj#,lf.ts#, tp.obj#,tp.ts#,'Table partition and lob fragment not in recovery set'
from   lobfrag$ lf, tabpart$ tp
where  lf.tabfragobj# = tp.obj# 
  and  tp.ts# !=lf.ts# 
union all
/* Subpartitions having lob fragments */
select tsp.obj#,tsp.ts#,lf.fragobj#,lf.ts#,'Table Subpartition and lob fragment not fully contained in pluggable set'
from tabsubpart$ tsp, lobfrag$ lf
where tsp.obj# = lf.tabfragobj#
  and tsp.ts# != lf.ts#
union all
/* Objects that are not supported 
	tab$.property
	- 0x1000  = Primary Key based OID$ column
	- 0x20000 = AQs  to be defined
   Block REF columns with ref constraints - bug 895775
*/
/* get all non partitioned, non iot unsupported objects */
select obj#, ts#, -1, -1 , ' Object not allowed in Recovery Set'
from  tab$
where (bitand(property ,4096) != 0
   or bitand(property,131072)!=0)
  and bitand(property,64)=0 
  and bitand(property,32)=0
union all
/* get iot objects that aren't supported */
select i.bo#, i.ts# , -1, -1,' Object not allowed in Pluggable Set'
from tab$ t, ind$ i
where t.obj# = i.bo#
  and bitand(t.property, 64)!=0 
  and (bitand(t.property, 4096)!=0
        or bitand(t.property,131072)!=0)
union all
/* partitioned objects that aren't supported */
select tp.bo#,tp.ts#,-1,-1, ' Object not allowed in Pluggable Set'
from tabpart$ tp, tab$ t
where t.obj# = tp.bo#
  and (bitand(t.property, 4096)!=0
       or bitand(t.property,131072)!=0)
union all
/* Capture subpartitioned tables that have REFs having ref constraints */
select tcp.bo#,tsp.ts#, -1, -1, '104 Object not allowed in Pluggable Set'
from tab$ t, tabcompart$ tcp, tabsubpart$ tsp
where tsp.pobj# = tcp.obj#
  and tcp.bo# = t.obj#
  and (bitand(t.property, 4096)!=0
       or bitand(t.property,131072)!=0)
union all
/* Bug 895775 Begin  */
/*  Once this bug gets fixed we should rip this code out */
/* Capture tables having referential constraints on REF column */
/* Ignore tables that are stored as IOTs or are partitioned/subpartitioned */
select t.obj#, t.ts#, -1, -1, 'Table has REF column as OID column'
from tab$ t, col$ c
where c.obj# = t.obj# 
  and bitand(c.property, 524288)!=0
  and bitand(t.property,64)=0 
  and bitand(t.property,32)=0
union all
/* Capture IOTs having referential constraints on REF column */
select i.bo#, i.ts# , -1, -1, 'Table has REF column as OID column'
from ind$ i, col$ c, tab$ t
where c.obj# = i.bo# 
and bitand(c.property, 524288)!=0
and bitand(t.property,64)!=0
and t.obj# = i.bo#
union all
/* Capture partitioned tables that have REFs having ref constraints */
select tp.bo#,tp.ts#,-1,-1, 'Table has REF column as OID column'
from tabpart$ tp, col$ c
where c.obj# = tp.bo#
  and bitand(c.property, 524288)!=0
union all
/* Capture subpartitioned tables that have REFs having ref constraints */
select tcp.bo#,tsp.ts#, -1, -1, 'Table has REF column as OID column'
from col$ c, tabcompart$ tcp, tabsubpart$ tsp
where tsp.pobj# = tcp.obj#
  and tcp.bo# = c.obj#
  and bitand(c.property, 524288)!=0
/* End Bug 895775 */
union all
/* Check for Snapshots */
select o2.obj#,t.ts#, -1,-1, 'Snapshots not allowed in recovery set' 
from obj$ o, obj$ o2, tab$ t, user$ u, snap$ s
where t.obj#=o.obj#
  and s.tname=o.name
  and s.sowner=u.name
  and u.user#=o.owner#
  and o2.owner#=o.owner#
  and o2.name=s.vname
union all
/* Master tables without snapshot logs not supported */
/* Bug 5192382: The lower 2 bytes of trigflag are used for various
   combinations of snapshot/replication. The upper flags are used
   by other layers. So check for a table being master table for
   snapshot/replication is bitand(t.trigflag, 65535) != 0.
   See KQLDTVTF_MSK in kqld.h.
*/
select distinct(t.obj#), t.ts#, -1,-1 ,'Master table used for snapshots not allowed in recovery set'
from obj$ o,tab$ t,snap$ s,user$ u
where o.obj#=t.obj#
  and o.name=s.master
  and o.owner#=u.user#
  and s.mowner=u.name
  and bitand(t.trigflag, 65535) = 0
union all 
/* Master tables used for replication/snapshots not allowed in recovery set 
   Exclude partitioned tables, they will be checked saperately.
*/
select distinct t.obj#,t.ts#, -1, -1 ,'Master table used for snapshots/replication not allowed in recovery set'
from tab$ t
where bitand(t.trigflag, 65535) != 0
  and bitand(t.property,32) = 0
union all
/* Master tables used for replication/snapshots not allowed in pluggable set
   Tablespace for partitioned tables defaults to 0, hence we need to
   do the check against tabpart$
*/
select distinct t.obj#,tp.ts#, -1, -1 ,'Master table used for snapshots/replication not allowed in pluggable set'
from tab$ t, tabpart$ tp
where bitand(t.trigflag, 65535) != 0
  and t.obj#      = tp.bo#
  and bitand(t.property,32) != 0
union all
/* Capture snapshots on subpartitioned tables */
select distinct t.obj#, tsp.ts#, -1, -1, 'Master table used for snapshots/replication not allowed in pluggable set'
from tab$ t, tabcompart$ tcp, tabsubpart$ tsp
where tsp.pobj#     = tcp.obj#
  and tcp.bo#       = t.obj#
  and bitand(t.trigflag, 65535) != 0
  and bitand(t.property,32) != 0
union all
/* Check for snapshot logs */
select o.obj#,t.ts#,-1,-1, 'Snapshot logs not allowed in recovery set' 
from mlog$ m, tab$ t, obj$ o
where m.log=o.name 
  and o.obj#=t.obj#
/* Secondary Objects not allowed in the recovery Set */
union all
select o.obj#, t.ts#,-1,-1, 'Secondary Objects not allowed in Recovery Set'
from tab$ t, obj$ o
where o.obj#=t.obj#
  and o.flags=16
union all
/* Domain/Functional  Indexes not supported */
select i.obj#,i.ts#,-1,-1,'Domain/Functional Indexes not supported'
from ind$ i
where i.type# = 9
   or i.property = 16
union all
/****************************************************/
/*                                                  */
/* Don't allow objects owned by SYS                 */     
/*                                                  */
/****************************************************/
/* Capture non-partitioned tables owned by SYS */
select o.obj#, t.ts#,-1,-1, 'Sys owned tables not allowed in Recovery Set'
from tab$ t, obj$ o
where t.obj# = o.obj#
  and bitand(t.property,32) = 0
  and o.owner# = 0
union all
/* Capture partitioned tables owned by SYS */
select o.obj#, tp.ts#,-1,-1, 'Sys owned partitions not allowed in Recovery Set'
from tabpart$ tp, obj$ o
where tp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture clusters owned by SYS */
select o.obj#, c.ts#,-1,-1, 'Sys owned clusters not allowed in Recovery Set'
from clu$ c, obj$ o
where c.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture subpartitions owned by SYS */
select o.obj#, tsp.ts#,-1,-1, 'Sys owned subpartitions not allowed in Recovery Set'
from tabsubpart$ tsp, obj$ o
where tsp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture non-partitioned indexes owned by SYS */
select o.obj#, i.ts#,-1,-1, 'Sys owned indexes not allowed in Recovery Set'
from ind$ i, obj$ o
where i.obj# = o.obj#
  and o.owner# = 0
  and bitand(i.property,2) =0
union all
/* Capture partitioned indexes owned by SYS */
select o.obj#, ip.ts#,-1,-1, 'Sys owned partitioned indexes not allowed in Recovery Set'
from indpart$ ip, obj$ o
where ip.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture subpartitioned indexes owned by SYS */
select o.obj#, isp.ts#,-1,-1, 'Sys owned subpartitioned indexes not allowed in Recovery Set'
from indsubpart$ isp, obj$ o
where isp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture SYS owned lobs */
select l.lobj#, l.ts#,-1,-1, 'Sys owned lobs not allowed in Recovery Set'
from lob$ l, obj$ o
where l.lobj# = o.obj#
  and o.owner# = 0
union all
/* Capture partitioned lobs */
select lf.fragobj#, lf.ts#,-1,-1, 'Sys owned lob fragments not allowed in Recovery Set'
from lobfrag$ lf, obj$ o
where lf.fragobj# = o.obj#
  and o.owner# = 0
union all
/* Make sure that for IOTs the index partitions are all self contained */
select ip1.obj#, ip1.ts#, ip2.obj#, ip2.ts# , ' IOT partitions not self contained'
from (select   bo#, 
               min(ts#) keep (dense_rank first order by part#) ts#,
               min(obj#) keep (dense_rank first order by part#) obj#
      from     indpart$
      group by bo#) ip1, indpart$ ip2, ind$ i, tab$ t
where ip1.bo#= i.obj# 
and ip1.ts# != ip2.ts#
and ip2.bo# = i.obj#
and i.bo# = t.obj#
and bitand(t.property,64)!=0
union all
/* Make sure that for IOTs, overflow segments and index partitions are self
contained. We can take the first overflow segment partition and run it against
all the index partitions.  This guarantees completeness since all index
partitions are checked for seperately for self containment */
select tp.obj#, tp.ts#,ip.obj#,ip.ts#, ' Overflow segment and index partition not self contained'
from   indpart$ ip, ind$ i, tab$ t,
       (select  bo#, 
                min(ts#) keep (dense_rank first order by part#) ts#,
                min(obj#) keep (dense_rank first order by part#) obj#
        from     tabpart$
        group by bo#) tp
where  tp.bo# = t.obj#
  and  bitand(t.property,512)!=0
  and  t.bobj# = i.bo# 
  and  ip.bo#= i.obj#
  and  ip.ts# != tp.ts#;

grant select on STRADDLING_RS_OBJECTS to SELECT_CATALOG_ROLE;


create or replace view TS_PITR_INFO 
	(OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,CONSTRAINT_NO,REASON)
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
                          30, 'JAVA RESOURCE', 56, 'JAVA DATA', '         '),
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
                          30, 'JAVA RESOURCE', 56, 'JAVA DATA', '         '),
	o2.owner#,ts2.name,cf.con#,s.reason_id
from straddling_rs_objects s, obj$ o1, obj$ o2, ts$ ts1, ts$ ts2 , user$ u,cdef$ cf
where s.object1=o1.obj# 
  and s.object2=o2.obj#(+)
  and s.ts1=ts1.ts#
  and s.ts2=ts2.ts#(+)
  and o1.owner#=u.user#
  and s.object2=cf.obj#(+) 
  and bitand(o1.flags, 128)=0
  and (o2.flags is null or bitand(o2.flags, 128)=0)
union all
/* capture rollback segs */
select 'SYS', u.name, NULL, 'ROLLBACK SEGMENT', ts.name,NULL , NULL, NULL,-1, NULL,-1,'Rollback Segment not allowed in transportable set'
from   undo$ u, ts$ ts
where  u.ts# = ts.ts# 
  and  ts.ts# != 0
  and  u.status$ != 1;

grant select on TS_PITR_INFO to SELECT_CATALOG_ROLE;

Rem ===============================================================================
Rem	VIEW NAME	TS_PITR_CHECK                                             #
Rem       									  #
Rem ===============================================================================



create or replace view TS_PITR_CHECK
	(OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,CONSTRAINT_NAME,REASON)
as
select obj1_owner,obj1_name,obj1_subname,obj1_type,ts1_name,obj2_name,obj2_subname,obj2_type,u.name,nvl(ts2_name,'-1'),c.name,reason
from ts_pitr_info t, user$ u, con$ c
where u.user#(+)=t.obj2_owner
 and c.con#(+)=t.constraint_no ;

grant select on TS_PITR_CHECK to SELECT_CATALOG_ROLE;





Rem ===============================================================================
Rem	VIEW NAME	TS_PITR_OBJECTS_TO_BE_DROPPED                             #
Rem       									  #
Rem ===============================================================================

Rem This view describes all objects created in the future of the pitr recovery 
Rem time that will be lost as a consequence of performing tablespace point 
Rem in time recovery.

create or replace view TS_PITR_OBJECTS_TO_BE_DROPPED
	(owner,name,creation_time,tablespace_name)
as
(select u.name,o.name,o.ctime,tablespace_name
from user$ u, obj$ o, dba_segments s
where u.user# = o.owner#
  and o.name  = s.segment_name
  and u.name  = s.owner);

grant select on TS_PITR_OBJECTS_TO_BE_DROPPED to SELECT_CATALOG_ROLE;

