Rem
Rem $Header: rdbms/admin/catclust.sql /main/10 2008/10/10 20:52:50 nmacnaug Exp $
Rem
Rem catclust.sql
Rem
Rem Copyright (c) 2001, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catclust.sql - CLUSTer database specific views definitions
Rem
Rem    DESCRIPTION
Rem      Create all cluster database specific views
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       05/09/06 - support application edition
Rem    eyho        09/10/03 - remove product version from RAC registry 
Rem    nmacnaug    08/19/03 - cleanup rac statistics 
Rem    nmacnaug    04/02/03 - remove unused columns
Rem    eyho        03/08/02 - use rdbms release number with rac
Rem    eyho        12/05/01 - add validation procedure for catclust
Rem    eyho        11/14/01 - fix column name
Rem    eyho        11/02/01 - register to component registry
Rem    eyho        06/26/01 - optimize package creation
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    eyho        04/13/01 - Merged eyho_bug-1393413
Rem    eyho        04/11/01 - Rename catclustdb.sql to catclust.sql
Rem    eyho        04/09/01 - Merged eyho_rac_name_changes
Rem    eyho        04/03/01 - Rename catparr.sql to catclustdb.sql
Rem    ppjanic     01/14/01 - 601567: Correct v$lock_element definition
Rem    mjungerm    06/15/99 - add java shared data object type
Rem    nmacnaug    02/02/99 - zero out unused field
Rem    kquinn      05/13/98 - 666009: Correct v$cache definition
Rem    nmacnaug    06/10/98 - return zero for deleted columns
Rem    mcoyle      08/22/97 - Move v$lock_activity to kernel view
Rem    tlahiri     03/23/97 - Move v$bh to kqfv.h, remove use of ext_to_obj
Rem    tlahiri     07/23/96 - Proj-2721: Modifications for enhanced OPS statis
Rem    atsukerm    07/22/96 - change type for partitioned objects.
Rem    atsukerm    06/13/96 - fix EXT_TO_OBJ view.
Rem    mmonajje    05/24/96 - Replace type col name with type#
Rem    asurpur     04/08/96 - Dictionary Protection Implementation
Rem    atsukerm    02/29/96 - space support for partitions.
Rem    jwlee       02/05/96 - fix x$bh column name.
Rem    atsukerm    02/05/96 - fix ext_to_obj definition.
Rem    atsukerm    01/03/96 - tablespace-relative DBAs.
Rem    tlahiri     11/30/95 - Fix error in v$lock_element in last checkin
Rem    tlahiri     11/20/95 - Bugs 313766 and 313767
Rem    aho         11/02/95 - iot change clu# references in ext_to_obj_view
Rem    aezzat      08/09/95 - modify v$bh, v$ping to include buffer class
Rem    pgreenwa    10/21/94 - create public syn. for v$locks_with_collisions
Rem    svenkate    11/30/94 - bug 250244 : view changes
Rem    thayes      07/08/94 - Extend vbh view
Rem    svenkate    06/17/94 - bug 172282 : amendments
Rem    svenkate    06/08/94 - 172288 : add file_lock, file_PING
Rem    wmaimone    05/06/94 - #184921 run as sys/internal
Rem    jloaiza     03/17/94 - add false ping view, v$lock_element, etc
Rem    hrizvi      02/09/93 - apply changes to x$bh 
Rem    jloaiza     11/09/92 - get rid of quted column 
Rem    jklein      11/04/92 - fix view definitions 
Rem    jklein      10/28/92 - merge forward changes from v6 
Rem    Porter      12/03/90 - Added to control system, renamed to psviews.sql
Rem    Laursen     10/01/90 - Creation
Rem

Rem  create DBMS_CLUSTDB PACKAGE

CREATE OR REPLACE PACKAGE dbms_clustdb AS

PROCEDURE validate;

END dbms_clustdb;
/

CREATE OR REPLACE PACKAGE BODY dbms_clustdb AS

----------------------------------------------------------------------
-- PUBLIC FUNCTIONS
----------------------------------------------------------------------

PROCEDURE validate IS
start_time DATE;
end_time   DATE;
option_val VARCHAR2(64);
g_null     CHAR(1);
BEGIN

   BEGIN
      SELECT null INTO g_null FROM obj$ 
         WHERE owner#=0 AND name='V$CACHE_TRANSFER';
--    valid if v$ges_statistics exists;
      SELECT value INTO option_val FROM v$option
         WHERE parameter = 'Real Application Clusters';
--    check if RAC option has been linked in
      IF option_val = 'TRUE' THEN
         dbms_registry.valid('RAC');
      ELSE
         dbms_registry.invalid('RAC');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      dbms_registry.invalid('RAC');
   END;
END validate;

END dbms_clustdb;
/

Rem  Load catclust to the Component Registry
EXECUTE dbms_registry.loading('RAC','Oracle Real Application Clusters','dbms_clustdb.validate');

Rem  Old views prior to 9.0.1
Rem

Rem  This table maps extents to database objects. This table must be dropped 
Rem  and recreated to include any new extents that are added after the last 
Rem  time it was created.
Rem 
Rem  NOTE: As of 8.0.3, none of the remaining views in this file depend upon
Rem  ext_to_obj. v$cache and v$ping (and their new gv$ versions) use obj$ and
Rem  undo$ to obtain the object name, partition name, type and owner#. The
Rem  advantage of using obj$ and undo$ is that it is no longer necessary to
Rem  repeatedly recreate ext_to_obj (an expensive operation) to keep the 
Rem  dynamic performance views consistent.  
Rem  
Rem  ext_to_obj has been retained only for backward compatability reasons. 
Rem
Rem  Create ext_to_obj as a view to avoid expensive populating during
Rem  table creation.

create or replace view ext_to_obj_view as
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , NULL partition_name
       , 'TABLE' kind
       , owner#
  from tab$, uet$, obj$, file$
  where bitand(tab$.property, 1024) = 0          /* exclude clustered tables */
    and tab$.file# = uet$.segfile#
    and tab$.block# = uet$.segblock#
    and tab$.ts# = uet$.ts#
    and tab$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , obj$.subname partition_name
       , 'TABLE PARTITION' kind
       , owner#
  from tabpart$, uet$, obj$, file$
  where tabpart$.file# = uet$.segfile#
    and tabpart$.block# = uet$.segblock#
    and tabpart$.ts# = uet$.ts#
    and tabpart$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select distinct
         file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , NULL partition_name
       , 'CLUSTER' kind
       , owner#
  from tab$, uet$, obj$, file$
  where bitand(tab$.property, 1024) = 1024               /* clustered tables */
    and tab$.file# = uet$.segfile#
    and tab$.block# = uet$.segblock#
    and tab$.ts# = uet$.ts#
    and tab$.bobj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb 
       , obj$.name name 
       , NULL artition_name
       , 'INDEX' kind
       , owner#
  from ind$, uet$, obj$, file$
  where ind$.file# = uet$.segfile#
    and ind$.block# = uet$.segblock#
    and ind$.ts# = uet$.ts#
    and ind$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb 
       , obj$.name name 
       , obj$.subname partition_name
       , 'INDEX PARTITION' kind
       , owner#
  from indpart$, uet$, obj$, file$
  where indpart$.file# = uet$.segfile#
    and indpart$.block# = uet$.segblock#
    and indpart$.ts# = uet$.ts#
    and indpart$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file#
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , undo$.name name
       , NULL partition_name
       , 'UNDO' kind
       , user# owner#
  from undo$, uet$, file$
  where undo$.file# = uet$.segfile#
    and undo$.block# = uet$.segblock#
    and undo$.ts# = uet$.ts#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file#
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , 'TEMP SEGMENT' name
       , NULL partition_name
       , 'TEMP SEGMENT' kind
       , 1 owner#
  from uet$, seg$, file$
  where seg$.file# = uet$.segfile#
   and  seg$.block# = uet$.block#
   and  seg$.ts# = uet$.ts#
   and  seg$.type# = 3
   and file$.ts# = uet$.ts#
   and file$.relfile# = uet$.file#
union all
  select file$.file#
       , fet$.block#
       , fet$.length + fet$.block# - 1
       , 'FREE EXTENT' name
       , NULL partition_name
       , 'FREE EXTENT' kind
       , 1  owner#
  from fet$, file$
  where file$.ts# = fet$.ts#
    and file$.relfile# = fet$.file#
  ;
create or replace public synonym ext_to_obj for ext_to_obj_view;
grant select on ext_to_obj_view to select_catalog_role;

Rem  **************** NOTE FOR ORACLE 8.0.3 (and beyond) ******************
Rem  v$bh is now defined internally in the server (like other true
Rem  fixed views). A new view: gv$bh,  has also been added which is a
Rem  view on buffer headers across all instances. Correspondingly, there
Rem  are gv$ version of v$cache, v$ping, etc. (defined later). 
Rem 
Rem  The commented out definition of v$bh below is been retained so that a
Rem  description of the columns remains for the benefit of users and DBAs. 
Rem  gv$bh is identical to v$bh execept for an additional INST_ID column,
Rem  which gives the instance id of the corresponding buffer header.  

Rem  ***************** OLD DEFINITION OF V$BH   ********************
Rem  v$bh gives the status and number of x_to_null conversions, forced
Rem  writes and forced reads for every buffer in Rem  the buffer cache.
Rem  It gives the file number, block number, and data-object# for each
Rem  buffer, but unlike the v$cache  and v$ping views, it does not
Rem  translate  that to a database object.
Rem
Rem  There are three columns in v$bh for detecting i/o due to lock
Rem  lock conversion requests from other instances:
Rem 
Rem  1. The x_to_null column counts the number of times the block has
Rem  gone from exclusive mode to null on this instance due to a
Rem  conflicting lock request on another instance. This column has been
Rem  retained purely  for backward compatibility reasons. It provides only
Rem  a limited view of pinging, since it  does not capture other lock
Rem  transitions types such as  exclusive to share.
Rem 
Rem  2. The forced_write column counts the number of times DBWR had to
Rem  write this this block to disk because this instance had dirtied the
Rem  block and another instance had requested the lock on the block in a
Rem  conflicting mode.
Rem 
Rem  3. The forced_read column counts the number of times the block had
Rem  to be re-read from disk because another instance had forced it out
Rem  of this instance's cache by requesting the PCM lock on the block in
Rem  exclusive mode.
Rem
Rem  Columns 2 and 3  together represent the number of disk i/o's an
Rem  instance had to perform on each block in the cache due to
Rem  conflicting lock requests by other instances.
Rem 
Rem  These i/o's are wasteful since they occur only due to lock activity
Rem  and would not have occurred in a single instance environment. 
Rem  
Rem  In order to get a true picture of the pings you need to look at v$bh
Rem  on all instances. NOTE FOR ORACLE 8.0.3 and beyond - you can achive
Rem  this by looking at GV$BH. 
Rem
Rem  The 'lock_element_addr' column contains the address of the lock
Rem  element  contains the Parallel Cache Management (PCM) lock element
Rem  that is locking this buffer.
Rem
Rem  If two buffers have the same lock_element_addr, then they are being
Rem  protected by the same lock. Anytime two buffers are covered by the
Rem  PCM lock, you can have false collisions between the buffers.
Rem  With releasable locking, the association of a lock element to a PCM
Rem  lock  may change. This is the reason for including the
Rem  'lock_element_name' and  'lock_element_class' in this and subsequent
Rem  views, since they together uniquely identify a specific PCM lock.
Rem 
Rem  create or replace view v$bh as          /* view on buffer headers */
Rem  select FILE#                     file#,
Rem         DBABLK                    block#,
Rem         CLASS                     class#,
Rem         decode(state, 0, 'FREE',  /* not currently is use */
Rem                       1, 'XCUR',  /* held exclusive by this instance */
Rem                       2, 'SCUR',  /* held shared by this instance */
Rem                       3, 'CR',    /* only valid for consistent read */
Rem                       4, 'READ',  /* is being read from disk */
Rem                       5, 'MREC',  /* in media recovery mode */
Rem                       6, 'IREC')  /* in instance(crash) recovery mode */
Rem         status,
Rem         0                         xnc, /* count of ping outs */
Rem         0                         forced_reads,
Rem         0                         forced_writes,
Rem         bh.le_addr                lock_element_addr,
Rem         name                      lock_element_name,
Rem         le_class                  lock_element_class,
Rem         decode(bitand(flag,1), 0, 'N', 'Y')
Rem         dirty,                      /* Dirty bit */
Rem         decode(bitand(flag,16), 0, 'N', 'Y')
Rem         temp,                       /* temporary bit */
Rem         decode(bitand(flag,1536), 0, 'N', 'Y')
Rem         ping,                       /* ping (to shared or null) bit */
Rem         decode(bitand(flag,16384), 0, 'N', 'Y')
Rem         stale,                      /* stale bit */
Rem         decode(bitand(flag,65536), 0, 'N', 'Y')
Rem         direct,                     /* direct access bit */
Rem         decode(bitand(flag,1048576), 0, 'N', 'Y')
Rem         new,                        /* new bit */
Rem         obj    objd
Rem         from x$bh bh, x$le le
Rem         where bh.le_addr = le.le_addr;
Rem grant select on v$bh to public;
Rem create or replace public synonym v$bh for v$bh;

Rem This view is depreciated
Rem
create or replace view gv$ping as
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr,
       lock_element_name 
       from gv$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#) and
             (bh.forced_reads + bh.forced_writes) > 0
union all                     
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL             partition_name,
       'UNDO'           kind,
       un.user#         owner#,      
       lock_element_addr,
       lock_element_name
       from gv$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor((bh.class# - 11) / 2)) and
      (bh.forced_reads + bh.forced_writes) > 0;

grant select on gv$ping to public;
create or replace public synonym gv$ping for gv$ping;

create or replace view v$ping as
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr,
       lock_element_name
       from v$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#) and
             (bh.forced_reads + bh.forced_writes) > 0
union all                     
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL             partition_name,
       'UNDO'           kind,
       un.user#         owner#,      
       lock_element_addr,
       lock_element_name
       from v$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor((bh.class# - 11) / 2)) and
      (bh.forced_reads + bh.forced_writes) > 0;

grant select on v$ping to public;
create or replace public synonym v$ping for v$ping;

Rem This view is depreciated
Rem
create or replace view gv$cache as
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr,
       lock_element_name
       from gv$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#)
union all
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL              partition_name,
       'UNDO'            kind,
       un.user#          owner#,      
       lock_element_addr,
       lock_element_name
       from gv$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor(bh.class# - 11) / 2);

grant select on gv$cache to public;
create or replace public synonym gv$cache for gv$cache;

create or replace view v$cache as
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr,
       lock_element_name
       from v$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#)
union all
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL              partition_name,
       'UNDO'            kind,
       un.user#          owner#,      
       lock_element_addr,
       lock_element_name
       from v$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor((bh.class# - 11) / 2));

grant select on v$cache to public;
create or replace public synonym v$cache for v$cache;

Rem This view is depreciated
Rem
create or replace view v$cache_lock as
select file#, block#, status, xnc, forced_reads, forced_writes, 
       name, kind, owner#, c.lock_element_addr, c.lock_element_name,
       indx, class
  from v$cache c, v$lock_element l
where l.lock_element_addr = c.lock_element_addr;

grant select on v$cache_lock to public;
create or replace public synonym v$cache_lock for v$cache_lock;

Rem This view is depreciated
Rem  
create or replace view gv$false_ping as
select p.inst_id,
       file#,
       block#,
       status,
       xnc,
       p.forced_reads,
       p.forced_writes,
       name,
       partition_name,
       kind,
       owner#,
       p.lock_element_addr,
       p.lock_element_name,
       p.class#          lock_element_class
    from gv$ping p, gv$locks_with_collisions c
  where (p.forced_reads + p.forced_writes) > 5 
   and  p.lock_element_addr = c.lock_element_addr
   and  p.inst_id = c.inst_id;

grant select on gv$false_ping to public;
create or replace public synonym gv$false_ping for gv$false_ping;

create or replace view v$false_ping as
select file#,
       block#,
       status,
       xnc,
       p.forced_reads,
       p.forced_writes,
       name,
       partition_name,
       kind,
       owner#,
       p.lock_element_addr,
       p.lock_element_name,
       p.class#          lock_element_class
    from v$ping p, v$locks_with_collisions c
  where (p.forced_reads + p.forced_writes) > 5 
   and  p.lock_element_addr = c.lock_element_addr;

grant select on v$false_ping to public;
create or replace public synonym v$false_ping for v$false_ping;

Rem This view is depreciated
Rem
create or replace view file_ping as 
select file_id, file_name,
       tablespace_name ts_name, 
       0               frequency,
       0               x_2_null,          
       0               x_2_null_forced_write,
       0               x_2_null_forced_stale,
       0               x_2_s,
       0               x_2_s_forced_writes,
       0               x_2_ssx,
       0               x_2_ssx_forced_writes,
       0               s_2_null,
       0               s_2_null_forced_stale,
       0               ss_2_null,
       0               wrb,
       0               wrb_forced_write,
       0               rbr,
       0               rbr_forced_write, 
       0               rbr_forced_stale,
       0               cbr,
       0               cbr_forced_write,
       0               null_2_x,
       0               s_2_x,
       0               ssx_2_x,
       0               n_2_s,
       0               n_2_ss
       from dba_data_files;
grant select on file_ping to select_catalog_role;
 
Rem This view is depreciated
Rem
create or replace view file_lock as 
select file_id, file_name, 
       tablespace_name ts_name, 
       0 start_lk, 0 nlocks, 0 blocking 
       from dba_data_files;
grant select on file_lock to select_catalog_role;

Rem  New views for cluster database in 9.0.1
Rem

create or replace public synonym v$ges_statistics for v$dlm_misc;

create or replace public synonym v$ges_latch for v$dlm_latch;

create or replace public synonym v$ges_convert_local for v$dlm_convert_local;

create or replace public synonym v$ges_convert_remote for v$dlm_convert_remote;

create or replace public synonym v$ges_traffic_controller
   for v$dlm_traffic_controller;

create or replace public synonym v$ges_resource for v$dlm_ress;

create or replace public synonym gv$ges_statistics for gv$dlm_misc;

create or replace public synonym gv$ges_latch for gv$dlm_latch;

create or replace public synonym gv$ges_convert_local for gv$dlm_convert_local;

create or replace public synonym gv$ges_convert_remote
   for gv$dlm_convert_remote;

create or replace public synonym gv$ges_traffic_controller
   for gv$dlm_traffic_controller;

create or replace public synonym gv$ges_resource for gv$dlm_ress;

Rem This view is depreciated
Rem
create or replace view gv$cache_transfer as
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr "GC_ELEMENT_ADDR",
       lock_element_name "GC_ELEMENT_NAME"
       from gv$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#) and
             (bh.forced_reads + bh.forced_writes) > 0
union all                     
select bh.inst_id,
       bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL             partition_name,
       'UNDO'           kind,
       un.user#         owner#,      
       lock_element_addr "GC_ELEMENT_ADDR",
       lock_element_name "GC_ELEMENT_NAME"
       from gv$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor((bh.class# - 11) / 2)) and
      (bh.forced_reads + bh.forced_writes) > 0;

grant select on gv$cache_transfer to public;
create or replace public synonym gv$cache_transfer for gv$cache_transfer;

create or replace view v$cache_transfer as
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       ob.name,
       ob.subname partition_name,
       decode (ob.type#,  1, 'INDEX',
                          2, 'TABLE',
                          3, 'CLUSTER',
                          4, 'VIEW',
                          5, 'SYNONYM',
                          6, 'SEQUENCE',
                          7, 'PROCEDURE',
                          8,  'FUNCTION',
                          9, 'PACKAGE',
                         10, 'NON-EXISTENT',
                         11, 'PACKAGE BODY',
                         12, 'TRIGGER',
                         13, 'TYPE',
                         14, 'TYPE BODY',
                         19, 'TABLE PARTITION',
                         20, 'INDEX PARTITION',
                         21, 'LOB',
                         22, 'LIBRARY',
                         28, 'JAVA SOURCE',
                         29, 'JAVA CLASS',
                         30, 'JAVA RESOURCE',
                         56, 'JAVA DATA',
                         'UNKNOWN') kind,
       ob.owner#,
       lock_element_addr "GC_ELEMENT_ADDR",
       lock_element_name "GC_ELEMENT_NAME"
       from v$bh bh, "_CURRENT_EDITION_OBJ" ob
       where (bh.objd = ob.dataobj#) and
             (bh.forced_reads + bh.forced_writes) > 0
union all                     
select bh.file#,
       bh.block#,
       bh.class#,
       bh.status,
       bh.xnc,
       bh.forced_reads,
       bh.forced_writes,
       un.name,
       NULL             partition_name,
       'UNDO'           kind,
       un.user#         owner#,      
       lock_element_addr "GC_ELEMENT_ADDR",
       lock_element_name "GC_ELEMENT_NAME"
       from v$bh bh, undo$ un
where (bh.class# >= 11) and
      (un.us# = floor((bh.class# - 11) / 2)) and
      (bh.forced_reads + bh.forced_writes) > 0;

grant select on v$cache_transfer to public;
create or replace public synonym v$cache_transfer for v$cache_transfer;

Rem  successfully load the RAC component and validate the package

BEGIN
  dbms_registry.loaded('RAC');
  dbms_clustdb.validate;
END;
/
