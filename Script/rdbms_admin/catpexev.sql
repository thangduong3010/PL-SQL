Rem
Rem $Header: catpexev.sql 18-dec-2007.14:32:38 achoi Exp $
Rem
Rem catpexev.sql
Rem
Rem Copyright (c) 2007, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      catpexev.sql - DBMS_PARALLEL_EXECUTE views
Rem
Rem    DESCRIPTION
Rem      Views dependent on dbms_(internal_)parallel_execute
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       11/13/07 - Created
Rem

-- User views
create or replace view USER_PARALLEL_EXECUTE_TASKS
(TASK_NAME,
 CHUNK_TYPE,
 STATUS,
 TABLE_OWNER,
 TABLE_NAME,
 NUMBER_COLUMN,
 TASK_COMMENT,
 JOB_PREFIX,
 SQL_STMT,
 LANGUAGE_FLAG,
 EDITION,
 APPLY_CROSSEDITION_TRIGGER,
 FIRE_APPLY_TRIGGER,
 PARALLEL_LEVEL,
 JOB_CLASS)
as
select task_name,
       decode( chunk_type, -1, 'UNDELARED',
                            0, 'ROWID_RANGE',
                            1, 'NUMBER_RANGE'),
       decode( dbms_parallel_execute_internal.task_status(task_owner#,
                                                          task_name),
               1, 'CREATED',
               2, 'CHUNKING',
               3, 'CHUNKING_FAILED',
               4, 'CHUNKED',
               5, 'PROCESSING',
               6, 'FINISHED',
               7, 'FINISHED_WITH_ERROR',
               8, 'CRASHED' ),
       TABLE_OWNER,
       TABLE_NAME,
       NUMBER_COLUMN,
       CMT,
       JOB_PREFIX,
       SQL_STMT,
       LANGUAGE_FLAG,
       EDITION,
       APPLY_CROSSEDITION_TRIGGER,
       FIRE_APPLY_TRIGGER,
       PARALLEL_LEVEL,
       JOB_CLASS
from DBMS_PARALLEL_EXECUTE_TASK$
where task_owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_PARALLEL_EXECUTE_TASKS
  for USER_PARALLEL_EXECUTE_TASKS
/
grant select on USER_PARALLEL_EXECUTE_TASKS to PUBLIC with grant option
/


create or replace view USER_PARALLEL_EXECUTE_CHUNKS
(CHUNK_ID,
 TASK_NAME,
 STATUS,
 START_ROWID,
 END_ROWID,
 START_ID,
 END_ID,
 JOB_NAME,
 START_TS,
 END_TS,
 ERROR_CODE,
 ERROR_MESSAGE)
as
select CHUNK_ID,
       TASK_NAME,
       decode( status, 0, 'UNASSIGNED',
                       1, 'ASSIGNED',
                       2, 'PROCESSED',
                       3, 'PROCESSED_WITH_ERROR' ),
       START_ROWID,
       END_ROWID,
       START_ID,
       END_ID,
       JOB_NAME,
       START_TS,
       END_TS,
       ERROR_CODE,
       ERROR_MESSAGE
from DBMS_PARALLEL_EXECUTE_CHUNKS$ c
where task_owner# = userenv('SCHEMAID')
/

create or replace public synonym USER_PARALLEL_EXECUTE_CHUNKS
  for USER_PARALLEL_EXECUTE_CHUNKS
/
grant select on USER_PARALLEL_EXECUTE_CHUNKS to PUBLIC with grant option
/


-- DBA Views
create or replace view DBA_PARALLEL_EXECUTE_TASKS
(TASK_OWNER,
 TASK_NAME,
 CHUNK_TYPE,
 STATUS,
 TABLE_OWNER,
 TABLE_NAME,
 NUMBER_COLUMN,
 TASK_COMMENT,
 JOB_PREFIX,
 SQL_STMT,
 LANGUAGE_FLAG,
 EDITION,
 APPLY_CROSSEDITION_TRIGGER,
 FIRE_APPLY_TRIGGER,
 PARALLEL_LEVEL,
 JOB_CLASS)
as
select u.username,
       t.task_name,
       decode( t.chunk_type, -1, 'UNDELARED',
                              0, 'ROWID_RANGE',
                              1, 'NUMBER_RANGE'),
       decode( dbms_parallel_execute_internal.task_status(t.task_owner#,
                                                          t.task_name),
               1, 'CREATED',
               2, 'CHUNKING',
               3, 'CHUNKING_FAILED',
               4, 'CHUNKED',
               5, 'PROCESSING',
               6, 'FINISHED',
               7, 'FINISHED_WITH_ERROR',
               8, 'CRASHED' ),
       t.TABLE_OWNER,
       t.TABLE_NAME,
       t.NUMBER_COLUMN,
       t.CMT,
       t.JOB_PREFIX,
       t.SQL_STMT,
       t.LANGUAGE_FLAG,
       t.EDITION,
       t.APPLY_CROSSEDITION_TRIGGER,
       t.FIRE_APPLY_TRIGGER,
       t.PARALLEL_LEVEL,
       t.JOB_CLASS
from DBMS_PARALLEL_EXECUTE_TASK$ t,
     DBA_USERS                   u
where task_owner# = u.user_id
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_PARALLEL_EXECUTE_TASKS
  FOR DBA_PARALLEL_EXECUTE_TASKS
/
GRANT SELECT ON DBA_PARALLEL_EXECUTE_TASKS TO select_catalog_role
/
GRANT SELECT ON DBA_PARALLEL_EXECUTE_TASKS TO ADM_PARALLEL_EXECUTE_TASK
/


create or replace view DBA_PARALLEL_EXECUTE_CHUNKS
(CHUNK_ID,
 TASK_OWNER,
 TASK_NAME,
 STATUS,
 START_ROWID,
 END_ROWID,
 START_ID,
 END_ID,
 JOB_NAME,
 START_TS,
 END_TS,
 ERROR_CODE,
 ERROR_MESSAGE)
as
select c.CHUNK_ID,
       u.username,
       c.TASK_NAME,
       decode( c.status, 0, 'UNASSIGNED',
                         1, 'ASSIGNED',
                         2, 'PROCESSED',
                         3, 'PROCESSED_WITH_ERROR' ),
       c.START_ROWID,
       c.END_ROWID,
       c.START_ID,
       c.END_ID,
       c.JOB_NAME,
       c.START_TS,
       c.END_TS,
       c.ERROR_CODE,
       c.ERROR_MESSAGE
from DBMS_PARALLEL_EXECUTE_CHUNKS$ c,
     DBA_USERS                     u
where task_owner# = u.user_id
/

create or replace public synonym DBA_PARALLEL_EXECUTE_CHUNKS
  for DBA_PARALLEL_EXECUTE_CHUNKS
/
GRANT SELECT ON DBA_PARALLEL_EXECUTE_CHUNKS TO select_catalog_role
/
GRANT SELECT ON DBA_PARALLEL_EXECUTE_CHUNKS TO ADM_PARALLEL_EXECUTE_TASK
/





--
-- Utility View used by the package
-- User must be granted SELECT privil on this view before they can use
-- this package.
--
create or replace view DBMS_PARALLEL_EXECUTE_EXTENTS as 
SELECT owner, 
       segment_name, 
       partition_name, 
       segment_type, 
       data_object_id, 
       relative_fno,
       block_id,
       blocks 
from (select ds.owner,
             ds.segment_name,
             ds.partition_name,
             ds.segment_type, 
             e.block#           BLOCK_ID, 
             e.length           BLOCKS,
             e.file#            RELATIVE_FNO, 
             ds.data_object_id
      from sys.uet$ e, 
           (select u.name           OWNER,
                   o.name           SEGMENT_NAME,
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE,
                   ts.ts#           TABLESPACE_ID,
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select 'TABLE'  OBJECT_TYPE, 
                         2        OBJECT_TYPE_ID, 
                         5        SEGMENT_TYPE_ID, 
                         t.obj#   OBJECT_ID, 
                         t.file#  HEADER_FILE, 
                         t.block# HEADER_BLOCK, 
                         t.ts#    TS_NUMBER 
                  from sys.tab$ t 
                  where bitand(t.property, 1024) = 0    
                    and bitand(t.property, 8192) != 8192 
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
            UNION ALL 
            select /*+ USE_NL(U O SO) */
                   u.name           OWNER,
                   o.name           SEGMENT_NAME,
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE,
                   ts.ts#           TABLESPACE_ID,
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select /*+ INDEX(TP) */ 
                         'TABLE PARTITION' OBJECT_TYPE, 
                         19                OBJECT_TYPE_ID, 
                         5                 SEGMENT_TYPE_ID, 
                         tp.obj#           OBJECT_ID, 
                         tp.file#          HEADER_FILE, 
                         tp.block#         HEADER_BLOCK, 
                         tp.ts#            TS_NUMBER 
                  from sys.tabpart$ tp 
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
            UNION ALL 
            select u.name           OWNER,
                   o.name           SEGMENT_NAME,
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE,
                   ts.ts#           TABLESPACE_ID,
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select /*+ INDEX(TSP) */ 
                         'TABLE SUBPARTITION' OBJECT_TYPE, 
                         34                   OBJECT_TYPE_ID, 
                         5                    SEGMENT_TYPE_ID, 
                         tsp.obj#             OBJECT_ID, 
                         tsp.file#            HEADER_FILE, 
                         tsp.block#           HEADER_BLOCK, 
                         tsp.ts#              TS_NUMBER
                  from sys.tabsubpart$ tsp  
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
           ) ds,
           sys.file$ f 
      where e.segfile#  = ds.relative_fno 
        and e.segblock# = ds.header_block 
        and e.ts#       = ds.tablespace_id 
        and e.ts#       = f.ts# 
        and e.file#     = f.relfile# 
        and bitand(NVL(ds.segment_flags,0), 1) = 0 
      union all 
      select /*+ ordered use_nl(e) use_nl(f) */ 
             ds.owner,
             ds.segment_name,
             ds.partition_name,
             ds.segment_type, 
             e.ktfbuebno       BLOCK_ID, 
             e.ktfbueblks      BLOCKS,
             e.ktfbuefno       RELATIVE_FNO, 
             ds.data_object_id
      from (select u.name           OWNER,
                   o.name           SEGMENT_NAME,
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE,
                   ts.ts#           TABLESPACE_ID,
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select 'TABLE'  OBJECT_TYPE, 
                         2        OBJECT_TYPE_ID, 
                         5        SEGMENT_TYPE_ID, 
                         t.obj#   OBJECT_ID, 
                         t.file#  HEADER_FILE, 
                         t.block# HEADER_BLOCK, 
                         t.ts#    TS_NUMBER 
                  from sys.tab$ t 
                  where bitand(t.property, 1024) = 0
                    and bitand(t.property, 8192) != 8192 
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
            UNION ALL 
            select /*+ USE_NL(U O SO) */ 
                   u.name           OWNER,
                   o.name           SEGMENT_NAME,
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE,
                   ts.ts#           TABLESPACE_ID,
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select /*+ INDEX(TP) */ 
                         'TABLE PARTITION' OBJECT_TYPE, 
                         19                OBJECT_TYPE_ID, 
                         5                 SEGMENT_TYPE_ID, 
                         tp.obj#           OBJECT_ID, 
                         tp.file#          HEADER_FILE, 
                         tp.block#         HEADER_BLOCK, 
                         tp.ts#            TS_NUMBER
                  from sys.tabpart$ tp 
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
            UNION ALL 
            select u.name           OWNER,
                   o.name           SEGMENT_NAME, 
                   o.subname        PARTITION_NAME, 
                   so.object_type   SEGMENT_TYPE, 
                   ts.ts#           TABLESPACE_ID, 
                   s.block#         HEADER_BLOCK,
                   s.file#          RELATIVE_FNO, 
                   NVL(s.spare1,0)  SEGMENT_FLAGS, 
                   o.dataobj#       DATA_OBJECT_ID  
            from sys.user$ u, 
                 sys.obj$  o, 
                 sys.ts$   ts, 
                 sys.seg$  s, 
                 sys.file$ f, 
                 (select /*+ INDEX(TSP) */ 
                         'TABLE SUBPARTITION' OBJECT_TYPE, 
                         34                   OBJECT_TYPE_ID, 
                         5                    SEGMENT_TYPE_ID, 
                         tsp.obj#             OBJECT_ID, 
                         tsp.file#            HEADER_FILE, 
                         tsp.block#           HEADER_BLOCK, 
                         tsp.ts#              TS_NUMBER
                  from sys.tabsubpart$ tsp  
                 ) so 
            where s.file#  = so.header_file 
              and s.block# = so.header_block 
              and s.ts#    = so.ts_number 
              and s.ts#    = ts.ts# 
              and o.obj#   = so.object_id 
              and o.owner# = u.user# 
              and s.type#  = so.segment_type_id 
              and o.type#  = so.object_type_id 
              and s.ts#    = f.ts# 
              and s.file#  = f.relfile# 
           ) ds, 
           sys.x$ktfbue e, 
           sys.file$ f 
      where e.ktfbuesegfno = ds.relative_fno 
        and e.ktfbuesegbno = ds.header_block 
        and e.ktfbuesegtsn = ds.tablespace_id 
        and e.ktfbuesegtsn = f.ts# 
        and e.ktfbuefno    = f.relfile# 
        and bitand(NVL(ds.segment_flags, 0), 1) = 1
     ); 
