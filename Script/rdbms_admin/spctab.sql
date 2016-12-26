Rem
Rem $Header: rdbms/admin/spctab.sql /st_rdbms_11.2.0/3 2012/03/06 15:07:48 shsong Exp $
Rem
Rem spctab.sql
Rem
Rem Copyright (c) 1999, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spctab.sql
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file to create tables to hold
Rem      start and end "snapshot" statistical information
Rem
Rem    NOTES
Rem      Should be run as STATSPACK user, PERFSTAT
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       08/11/10 - Bug#9800868 - Add Missing Idle Events for
Rem                           11.2.0.2for Statspack & Standby Statspack
Rem    kchou       08/11/10 - Bug#9800868 - Add missing idle events to 11.2.0.2
Rem    cgervasi    05/13/09 - add idle event: cell worker idle
Rem    cgervasi    04/02/09 - bug8395154: missing idle events
Rem    rhlee       02/22/08 - 
Rem    cdgreen     03/14/07 - 11 F2
Rem    shsong      06/14/07 - Add idle events
Rem    cdgreen     02/28/07 - 5908354
Rem    cdgreen     04/26/06 - 11 F1 
Rem    cdgreen     06/26/06 - Increase column length 
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     04/18/05 - 4228432
Rem    cdgreen     03/08/05 - 10gR2 misc 
Rem    vbarrier    02/18/05 - 4081984
Rem    cdgreen     10/29/04 - 10gR2_sqlstats
Rem    cdgreen     07/16/04 - 10gR2
Rem    cdialeri    03/25/04 - 3516921 
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    12/04/03 - 3290482
Rem    cdialeri    11/05/03 - 3202706 
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3
Rem    cdialeri    02/27/03 - 10g F2: baseline, purge
Rem    vbarrier    02/25/03 - 10g RAC
Rem    cdialeri    11/15/02 - 10g F1
Rem    cdialeri    09/27/02 - sleep4
Rem    vbarrier    03/20/02 - 2143634
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    cdialeri    02/07/02 - 2218573
Rem    cdialeri    01/30/02 - 2184717
Rem    cdialeri    01/11/02 - 9.2 - features 2
Rem    cdialeri    11/30/01 - 9.2 - features 1
Rem    cdialeri    04/22/01 - Undostat changes
Rem    cdialeri    03/02/01 - 9.0
Rem    cdialeri    09/12/00 - sp_1404195
Rem    cdialeri    04/07/00 - 1261813
Rem    cdialeri    03/20/00 - Support for purge
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    01/26/00 - 1169401
Rem    cdialeri    11/01/99 - Enhance, 1059172
Rem    cmlim       07/17/97 - Added STATS$SQLAREA to store top sql stmts
Rem    gwood       10/16/95 - Version to run as sys without using many views
Rem    cellis.uk   11/15/89 - Created
Rem

set showmode off echo off;
whenever sqlerror exit;

spool spctab.lis

/* ------------------------------------------------------------------------- */

prompt
prompt  If this script is automatically called from spcreate (which is
prompt  the supported method), all STATSPACK segments will be created in 
prompt  the PERFSTAT user's default tablespace.
prompt

define tablespace_name=&&default_tablespace
prompt Using &&tablespace_name tablespace to store Statspack objects
prompt

/* ------------------------------------------------------------------------- */

Prompt ... Creating STATS$SNAPSHOT_ID Sequence

create sequence       STATS$SNAPSHOT_ID
       start with   1
       increment by 1
       nomaxvalue
       cache 10;

create public synonym STATS$SNAPSHOT_ID  for STATS$SNAPSHOT_ID;

/* ------------------------------------------------------------------------- */

Prompt ... Creating STATS$... tables

create table          STATS$DATABASE_INSTANCE
(dbid                 number       not null
,instance_number      number       not null
,startup_time         date         not null         
,snap_id              number       not null
,parallel             varchar2(3)  not null
,version              varchar2(17) not null
,db_name              varchar2(9)  not null
,instance_name        varchar2(16) not null
,host_name            varchar2(64)
,platform_name        varchar2(101)
,constraint STATS$DATABASE_INSTANCE_PK primary key
    (dbid, instance_number, startup_time)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$DATABASE_INSTANCE  for STATS$DATABASE_INSTANCE;

/* ------------------------------------------------------------------------- */

create table          STATS$LEVEL_DESCRIPTION
(snap_level           number          not null
,description          varchar2(300)
,constraint STATS$LEVEL_DESCRIPTION_PK primary key (snap_level)
 using index tablespace &&tablespace_name
  storage (initial 100k next 100k pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 100k next 100k pctincrease 0)
;

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (0,  'This level captures general statistics, including rollback segment, row cache, SGA, system events, background events, session events, system statistics, wait statistics, lock statistics, and Latch information');

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (5,  'This level includes capturing high resource usage SQL Statements, along with all data captured by lower levels');

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (6,  'This level includes capturing SQL plan and SQL plan usage information for high resource usage SQL Statements, along with all data captured by lower levels');

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (7,  'This level captures segment level statistics, including logical and physical reads, row lock, itl and buffer busy waits, along with all data captured by lower levels');

insert into STATS$LEVEL_DESCRIPTION (snap_level, description)
  values (10,  'This level includes capturing Child Latch statistics, along with all data captured by lower levels');

commit;

create public synonym  STATS$LEVEL_DESCRIPTION   for STATS$LEVEL_DESCRIPTION;

/* ------------------------------------------------------------------------- */

create table          STATS$SNAPSHOT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,snap_time            date             not null
,startup_time         date             not null
,session_id           number           not null
,serial#              number
,snap_level           number
,ucomment             varchar2(160)
,executions_th        number
,parse_calls_th       number
,disk_reads_th        number
,buffer_gets_th       number
,sharable_mem_th      number
,version_count_th     number
,seg_phy_reads_th     number         not null
,seg_log_reads_th     number         not null
,seg_buff_busy_th     number         not null
,seg_rowlock_w_th     number         not null
,seg_itl_waits_th     number         not null
,seg_cr_bks_rc_th     number
,seg_cu_bks_rc_th     number
,seg_cr_bks_sd_th     number         -- left for prior
,seg_cu_bks_sd_th     number         -- releases
,snapshot_exec_time_s number
,all_init             varchar2(5)
,baseline             varchar2(1)
,constraint STATS$SNAPSHOT_PK primary key (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SNAPSHOT_LVL_FK
    foreign key (snap_level) references STATS$LEVEL_DESCRIPTION
,constraint STATS$SNAPSHOT_BASE_CK
    check (baseline in ('Y'))
,constraint STATS$SNAPSHOT_FK foreign key (dbid, instance_number, startup_time)
    references STATS$DATABASE_INSTANCE on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SNAPSHOT  for STATS$SNAPSHOT;

/* ------------------------------------------------------------------------- */

create table          STATS$DB_CACHE_ADVICE
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,id                   number          not null
,name                 varchar2(20)    not null
,block_size           number          not null
,buffers_for_estimate number          not null
,advice_status        varchar2(3)
,size_for_estimate    number
,size_factor          number
,estd_physical_read_factor     number
,estd_physical_reads           number  
,estd_physical_read_time       number
,estd_pct_of_db_time_for_reads number
,estd_cluster_reads            number
,estd_cluster_read_time        number
,constraint STATS$DB_CACHE_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, id, buffers_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DB_CACHE_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$DB_CACHE_ADVICE  for STATS$DB_CACHE_ADVICE;

/* ------------------------------------------------------------------------- */

create table          STATS$FILESTATXS
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,tsname               varchar2 (30)   not null
,filename             varchar2 (513)  not null
,phyrds               number
,phywrts              number
,singleblkrds         number
,readtim              number
,writetim             number
,singleblkrdtim       number
,phyblkrd             number
,phyblkwrt            number
,wait_count           number
,time                 number
,file#                number
,constraint STATS$FILESTATXS_PK primary key 
     (snap_id, dbid, instance_number, tsname, filename)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$FILESTATXS_FK foreign key (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$FILESTATXS  for STATS$FILESTATXS;
 
/* ------------------------------------------------------------------------- */

create table STATS$TEMPSTATXS
(snap_id             number        not null
,dbid                number        not null
,instance_number     number        not null
,tsname              varchar2(30)  not null
,filename            varchar2(513) not null
,phyrds              number
,phywrts             number
,singleblkrds        number
,readtim             number
,writetim            number
,singleblkrdtim      number
,phyblkrd            number
,phyblkwrt           number
,wait_count          number
,time                number
,file#               number
,constraint STATS$TEMPSTATXS_PK primary key
     (snap_id, dbid, instance_number, tsname, filename)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$TEMPSTATXS_FK foreign key (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$TEMPSTATXS  for STATS$TEMPSTATXS;

/* ------------------------------------------------------------------------- */

create table          STATS$LATCH
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,name                 varchar2(64)    not null
,latch#               number          not null
,level#               number
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint STATS$LATCH_PK primary key 
    (snap_id, dbid, instance_number, name) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LATCH_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$LATCH  for STATS$LATCH;

/* ------------------------------------------------------------------------- */

create table          STATS$LATCH_CHILDREN
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,latch#               number          not null
,child#               number          not null
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint STATS$LATCH_CHILDREN_PK primary key 
    (snap_id, dbid, instance_number, latch#, child#) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LATCH_CHILDREN_FK foreign key 
    (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$LATCH_CHILDREN  for STATS$LATCH_CHILDREN;

/* ------------------------------------------------------------------------- */

create table          STATS$LATCH_PARENT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,latch#               number          not null
,level#               number          not null
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint STATS$LATCH_PARENT_PK primary key 
    (snap_id, dbid, instance_number, latch#) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LATCH_PARENT_FK foreign key 
    (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$LATCH_PARENT  for STATS$LATCH_PARENT;

/* ------------------------------------------------------------------------- */

create table          STATS$LATCH_MISSES_SUMMARY
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parent_name          varchar2(50)
,where_in_code        varchar2(64)
,nwfail_count         number
,sleep_count          number
,wtr_slp_count        number
,constraint STATS$LATCH_MISSES_SUMMARY_PK primary key 
    (snap_id, dbid, instance_number, parent_name, where_in_code)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LATCH_MISSES_SUMMARY_FK foreign key 
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$LATCH_MISSES_SUMMARY  for STATS$LATCH_MISSES_SUMMARY;

/* ------------------------------------------------------------------------- */

create table            STATS$LIBRARYCACHE
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,namespace              varchar2(15)    not null
,gets                   number
,gethits                number
,pins                   number
,pinhits                number
,reloads                number
,invalidations          number
,dlm_lock_requests      number
,dlm_pin_requests       number
,dlm_pin_releases       number
,dlm_invalidation_requests  number
,dlm_invalidations      number
,constraint STATS$LIBRARYCACHE_PK primary key 
    (snap_id, dbid, instance_number, namespace)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$LIBRARYCACHE_FK foreign key 
    (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$LIBRARYCACHE  for STATS$LIBRARYCACHE;

/* ------------------------------------------------------------------------- */

create table             STATS$BUFFER_POOL_STATISTICS
(snap_id                 number           not null
,dbid                    number           not null
,instance_number         number           not null
,id                      number           not null
,name                    varchar2(20)		
,block_size              number
,set_msize               number
,cnum_repl               number
,cnum_write              number
,cnum_set                number
,buf_got                 number
,sum_write               number
,sum_scan                number
,free_buffer_wait        number
,write_complete_wait     number
,buffer_busy_wait        number
,free_buffer_inspected   number
,dirty_buffers_inspected number
,db_block_change         number
,db_block_gets           number
,consistent_gets         number
,physical_reads          number
,physical_writes         number       
,constraint STATS$BUFFER_POOL_STATS_PK primary key
    (snap_id, dbid, instance_number, id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$BUFFER_POOL_STATS_FK foreign key
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$BUFFER_POOL_STATISTICS  for STATS$BUFFER_POOL_STATISTICS;

/* ------------------------------------------------------------------------- */

create table          STATS$ROLLSTAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,usn                  number           not null
,extents              number
,rssize               number
,writes               number
,xacts                number
,gets                 number
,waits                number
,optsize              number
,hwmsize              number
,shrinks              number
,wraps                number
,extends              number
,aveshrink            number
,aveactive            number
,constraint STATS$ROLLSTAT_PK primary key 
     (snap_id, dbid, instance_number, usn) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$ROLLSTAT_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$ROLLSTAT  for STATS$ROLLSTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$ROWCACHE_SUMMARY
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parameter            varchar2 (32)
,total_usage          number
,usage                number
,gets                 number
,getmisses            number
,scans                number
,scanmisses           number
,scancompletes        number
,modifications        number
,flushes              number
,dlm_requests         number
,dlm_conflicts        number
,dlm_releases         number
,constraint STATS$ROWCACHE_SUMMARY_PK primary key 
    (snap_id, dbid, instance_number, parameter) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$ROWCACHE_SUMMARY_FK foreign key 
    (snap_id, dbid, instance_number) 
        references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$ROWCACHE_SUMMARY  for STATS$ROWCACHE_SUMMARY;

/* ------------------------------------------------------------------------- */

create table          STATS$SGA
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,name                 varchar2(64)     not null
,value                number           not null
,startup_time         date
,parallel             varchar2(3)
,version              varchar2(17)
,constraint STATS$SGA_PK primary key 
    (snap_id, dbid, instance_number, name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SGA_FK foreign key 
    (snap_id, dbid, instance_number)
        references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SGA    for STATS$SGA;

/* ------------------------------------------------------------------------- */

create table          STATS$SGASTAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,name                 varchar2(64)     not null 
,pool                 varchar2(12)
,bytes                number
,constraint STATS$SGASTAT_U unique
    (snap_id, dbid, instance_number, name, pool)
  using index tablespace &&tablespace_name
    storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SGASTAT_FK foreign key 
    (snap_id, dbid, instance_number) 
        references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SGASTAT  for STATS$SGASTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$SYSSTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,statistic#           number          not null
,name                 varchar2 (64)   not null
,value                number
,constraint STATS$SYSSTAT_PK primary key 
    (snap_id, dbid, instance_number, name) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SYSSTAT_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SYSSTAT  for STATS$SYSSTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$SESSTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,statistic#           number          not null
,value                number
,constraint STATS$SESSTAT_PK primary key 
    (snap_id, dbid, instance_number, statistic#) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SESSTAT_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SESSTAT  for STATS$SESSTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$SYSTEM_EVENT
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,event                varchar2(64)   not null
,total_waits          number
,total_timeouts       number
,time_waited_micro    number
,total_waits_fg       number
,total_timeouts_fg    number
,time_waited_micro_fg number
,event_id             number
,constraint STATS$SYSTEM_EVENT_PK primary key 
    (snap_id, dbid, instance_number, event) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SYSTEM_EVENT_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SYSTEM_EVENT  for STATS$SYSTEM_EVENT;

/* ------------------------------------------------------------------------- */

create table          STATS$SESSION_EVENT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,event                varchar2(64)     not null
,total_waits          number
,total_timeouts       number
,time_waited_micro    number
,max_wait             number
,constraint STATS$SESSION_EVENT_PK primary key 
    (snap_id, dbid, instance_number, event) 
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SESSION_EVENT_FK foreign key 
    (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SESSION_EVENT  for STATS$SESSION_EVENT;

/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */

create table          STATS$WAITSTAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,class                varchar2(22)
,wait_count           number
,time                 number
,constraint STATS$WAITSTAT_PK primary key 
    (snap_id, dbid, instance_number, class)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$WAITSTAT_FK foreign key (snap_id, dbid, instance_number) 
    references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$WAITSTAT  for STATS$WAITSTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$ENQUEUE_STATISTICS
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,eq_type              varchar2(2)      not null
,req_reason           varchar2(64)     not null
,total_req#           number
,total_wait#          number
,succ_req#            number
,failed_req#          number
,cum_wait_time        number 
,event#               number
,constraint STATS$ENQUEUE_STATISTICS_PK primary key 
    (snap_id, dbid, instance_number, eq_type, req_reason)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$ENQUEUE_STATISTICS_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$ENQUEUE_STATISTICS  for STATS$ENQUEUE_STATISTICS;

 
/* ------------------------------------------------------------------------- */

create table          STATS$SQL_SUMMARY
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,text_subset          varchar2(31)     not null
,old_hash_value       number           not null
,sql_text             varchar2(1000)
,sql_id               varchar2(13)
,sharable_mem         number
,sorts                number
,module               varchar2(64)
,loaded_versions      number
,fetches              number
,executions           number
,px_servers_executions number
,end_of_fetch_count   number
,loads                number
,invalidations        number
,parse_calls          number
,disk_reads           number
,direct_writes        number
,buffer_gets          number
,application_wait_time number
,concurrency_wait_time number
,cluster_wait_time     number
,user_io_wait_time     number
,plsql_exec_time       number
,java_exec_time        number
,rows_processed       number
,command_type         number
,address              raw(8)
,hash_value           number
,version_count        number
,cpu_time             number
,elapsed_time         number
,avg_hard_parse_time  number
,outline_sid          number
,outline_category     varchar2(64)
,child_latch          number
,sql_profile          varchar2(64)
,program_id           number
,program_line#        number
,exact_matching_signature number
,force_matching_signature number
,last_active_time     date
,constraint STATS$SQL_SUMMARY_PK primary key
    (snap_id, dbid, instance_number, old_hash_value, text_subset)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_SUMMARY_FK foreign key (snap_id, dbid, instance_number)
                references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_SUMMARY  for STATS$SQL_SUMMARY;
 
/* ------------------------------------------------------------------------- */

create table STATS$SQLTEXT
(old_hash_value  number       not null
,text_subset     varchar2(31) not null
,piece           number       not null
,sql_id          varchar2(13)
,sql_text        varchar2(64)
,address         raw(8)
,command_type    number
,last_snap_id    number
,constraint STATS$SQLTEXT_PK primary key (old_hash_value, text_subset, piece)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQLTEXT  for STATS$SQLTEXT;

/* ------------------------------------------------------------------------- */

create table          STATS$SQL_STATISTICS
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,total_sql            number           not null
,total_sql_mem        number           not null
,single_use_sql       number           not null
,single_use_sql_mem   number           not null
,total_cursors        number
,constraint STATS$SQL_STATISTICS_PK primary key 
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_STATISTICS_FK foreign key 
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_STATISTICS  for STATS$SQL_STATISTICS;
 
/* ------------------------------------------------------------------------- */

create table          STATS$RESOURCE_LIMIT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,resource_name        varchar2(30)     not null
,current_utilization  number
,max_utilization      number
,initial_allocation   varchar2(10)
,limit_value          varchar2(10)
,constraint STATS$RESOURCE_LIMIT_PK primary key
    (snap_id, dbid, instance_number, resource_name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$RESOURCE_LIMIT_FK foreign key
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
)tablespace &&tablespace_name
storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$RESOURCE_LIMIT  for STATS$RESOURCE_LIMIT;

/* ------------------------------------------------------------------------- */

create table STATS$DLM_MISC
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,statistic#           number          not null
,name                 varchar2(38)
,value                number
,constraint STATS$DLM_MISC_PK primary key
    (snap_id, dbid, instance_number, statistic#)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DLM_MISC_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$DLM_MISC  for STATS$DLM_MISC;

/* ------------------------------------------------------------------------- */

create table STATS$CR_BLOCK_SERVER
(snap_id                   number          not null
,dbid                      number          not null
,instance_number           number          not null
,cr_requests               number
,current_requests          number
,data_requests             number
,undo_requests             number
,tx_requests               number
,current_results           number
,private_results           number
,zero_results              number
,disk_read_results         number
,fail_results              number
,fairness_down_converts    number
,fairness_clears           number
,free_gc_elements          number
,flushes                   number
,flushes_queued            number
,flush_queue_full          number
,flush_max_time            number
,light_works               number
,errors                    number
,constraint STATS$CR_BLOCK_SERVER_PK primary key
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$CR_BLOCK_SERVER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$CR_BLOCK_SERVER  for STATS$CR_BLOCK_SERVER;

/* ------------------------------------------------------------------------- */

create table STATS$CURRENT_BLOCK_SERVER
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,pin1                 number
,pin10                number
,pin100               number
,pin1000              number
,pin10000             number
,flush1               number
,flush10              number
,flush100             number
,flush1000            number
,flush10000           number
,write1               number
,write10              number
,write100             number
,write1000            number
,write10000           number
,constraint STATS$CURRENT_BLOCK_SERVER_PK primary key
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$CURRENT_BLOCK_SERVER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$CURRENT_BLOCK_SERVER  for STATS$CURRENT_BLOCK_SERVER;

/* ------------------------------------------------------------------------- */

create table STATS$INSTANCE_CACHE_TRANSFER
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,instance                 number          not null
,class                    varchar2(18)    not null
,cr_block                 number
,cr_busy                  number
,cr_congested             number
,current_block            number
,current_busy             number
,current_congested        number
,constraint STATS$INST_CACHE_TRANSFER_PK primary key
    (snap_id, dbid, instance_number, instance, class)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INST_CACHE_TRANSFER_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INSTANCE_CACHE_TRANSFER  for STATS$INSTANCE_CACHE_TRANSFER;

/* ------------------------------------------------------------------------- */

create table STATS$UNDOSTAT
(begin_time           date            not null
,end_time             date            not null
,snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,undotsn              number          not null
,undoblks             number
,txncount             number
,maxquerylen          number
,maxqueryid           varchar2(13)
,maxconcurrency       number
,unxpstealcnt         number
,unxpblkrelcnt        number
,unxpblkreucnt        number
,expstealcnt          number
,expblkrelcnt         number
,expblkreucnt         number
,ssolderrcnt          number
,nospaceerrcnt        number
,activeblks           number
,unexpiredblks        number
,expiredblks          number
,tuned_undoretention  number
,constraint STATS$UNDOSTAT_PK primary key
  (begin_time, end_time, snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$UNDOSTAT_FK foreign key
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$UNDOSTAT  for STATS$UNDOSTAT;

/* ------------------------------------------------------------------------- */

create table STATS$SQL_PLAN_USAGE
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,old_hash_value       number           not null
,text_subset          varchar2(31)     not null
,plan_hash_value      number           not null
,hash_value           number
,sql_id               varchar2(13)
,cost                 number
,address              raw(8)
,optimizer            varchar2(20)
,last_active_time     date
,constraint STATS$SQL_PLAN_USAGE_PK primary key
    (snap_id, dbid, instance_number
    ,old_hash_value, text_subset, plan_hash_value, cost)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_PLAN_USAGE_FK foreign key
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40;

create index STATS$SQL_PLAN_USAGE_HV ON STATS$SQL_PLAN_USAGE (old_hash_value)
  tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0);

create public synonym  STATS$SQL_PLAN_USAGE  for STATS$SQL_PLAN_USAGE;

/* ------------------------------------------------------------------------- */

create table STATS$SQL_PLAN
(plan_hash_value      number          not null
,id                   number          not null
,operation            varchar2(30)
,options              varchar2(30)
,object_node          varchar2(40)
,object#              number
,object_owner         varchar2(31)
,object_name          varchar2(31)
,object_alias         varchar2(65)
,object_type          varchar2(20)
,optimizer            varchar2(20)
,parent_id            number
,depth                number
,position             number
,search_columns       number
,cost                 number
,cardinality          number
,bytes                number
,other_tag            varchar2(35)
,partition_start      varchar2(64)
,partition_stop       varchar2(64)
,partition_id         number
,other                varchar2(4000)
,distribution         varchar2(20)
,cpu_cost             number
,io_cost              number
,temp_space           number
,access_predicates    varchar2(4000)
,filter_predicates    varchar2(4000)
,projection           varchar2(4000)
,time                 number
,qblock_name          varchar2(31)
,remarks              varchar2(4000)
,snap_id              number
,constraint STATS$SQL_PLAN_PK primary key
    (plan_hash_value, id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 5m next 5m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_PLAN  for STATS$SQL_PLAN;

/* ------------------------------------------------------------------------- */

create table STATS$SEG_STAT
(snap_id                           number      not null
,dbid                              number      not null
,instance_number                   number      not null
,dataobj#                          number      not null
,obj#                              number      not null
,ts#                               number      not null
,logical_reads                     number
,buffer_busy_waits                 number
,db_block_changes                  number
,physical_reads                    number
,physical_writes                   number
,direct_physical_reads             number
,direct_physical_writes            number
,gc_cr_blocks_received             number
,gc_current_blocks_received        number
,gc_buffer_busy                    number
,itl_waits                         number
,row_lock_waits                    number
,global_cache_cr_blocks_served     number -- Starting with 10g these cols
,global_cache_cu_blocks_served     number -- are no longer used
, constraint STATS$SEG_STAT_PK primary key
   (snap_id, dbid, instance_number, dataobj#, obj#, ts#)
  using index tablespace &&tablespace_name
    storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SEG_STAT_FK foreign key
    (snap_id, dbid, instance_number)
   references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
    storage (initial 3m next 3m pctincrease 0);

create public synonym STATS$SEG_STAT for STATS$SEG_STAT;

-- Segment names having statistics

create table STATS$SEG_STAT_OBJ
(dataobj#             number      not null
,obj#                 number      not null
,ts#                  number      not null
,dbid                 number      not null
,owner                varchar(30) not null
,object_name          varchar(30) not null
,subobject_name       varchar(30)
,object_type          varchar2(18)
,tablespace_name      varchar(30) not null
,constraint STATS$SEG_STAT_OBJ_PK primary key
  (dataobj#, obj#, ts#, dbid)
  using index tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0);

create public synonym STATS$SEG_STAT_OBJ for STATS$SEG_STAT_OBJ;

/* ------------------------------------------------------------------------- */

create table STATS$PGASTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,name                 varchar2(64)    not null
,value                number
,constraint STATS$SQL_PGASTAT_PK primary key
    (snap_id, dbid, instance_number, name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_PGASTAT_FK foreign key
     (snap_id, dbid, instance_number)
     references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$PGASTAT  for STATS$PGASTAT;

/* ------------------------------------------------------------------------- */

create table          STATS$PARAMETER
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,name                 varchar2(64)     not null
,value                varchar2(4000)
,isdefault            varchar2(9)
,ismodified           varchar2(10)
,constraint STATS$PARAMETER_PK primary key 
    (snap_id, dbid, instance_number, name)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PARAMETER_FK foreign key (snap_id, dbid, instance_number)
                references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$PARAMETER  for STATS$PARAMETER;

/* ------------------------------------------------------------------------- */

create table          STATS$INSTANCE_RECOVERY
(snap_id                          number           not null
,dbid                             number           not null
,instance_number                  number           not null
,recovery_estimated_ios           number
,actual_redo_blks                 number
,target_redo_blks                 number
,log_file_size_redo_blks          number
,log_chkpt_timeout_redo_blks      number
,log_chkpt_interval_redo_blks     number
,fast_start_io_target_redo_blks   number
,target_mttr                      number
,estimated_mttr                   number
,ckpt_block_writes                number
,constraint STATS$INSTANCE_RECOVERY_PK primary key 
    (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INSTANCE_RECOVERY_FK foreign key 
    (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INSTANCE_RECOVERY  for STATS$INSTANCE_RECOVERY;

/* ------------------------------------------------------------------------- */

create table          STATS$STATSPACK_PARAMETER
(dbid                 number         not null
,instance_number      number         not null
,session_id           number         not null
,snap_level           number         not null
,num_sql              number         not null
,executions_th        number         not null
,parse_calls_th       number         not null
,disk_reads_th        number         not null
,buffer_gets_th       number         not null
,sharable_mem_th      number         not null
,version_count_th     number         not null
,pin_statspack        varchar2(10)   not null
,all_init             varchar2(5)    not null
,last_modified        date
,ucomment             varchar2(160)
,job                  number
,seg_phy_reads_th     number         not null
,seg_log_reads_th     number         not null
,seg_buff_busy_th     number         not null
,seg_rowlock_w_th     number         not null
,seg_itl_waits_th     number         not null
,seg_cr_bks_rc_th     number         not null
,seg_cu_bks_rc_th     number         not null
,old_sql_capture_mth  varchar2(10)   not null
,constraint STATS$STATSPACK_PARAMETER_PK primary key 
    (dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 100k next 100k pctincrease 0)
,constraint STATS$STATSPACK_LVL_FK
    foreign key (snap_level) references STATS$LEVEL_DESCRIPTION
,constraint STATS$STATSPACK_P_PIN_CK
    check (pin_statspack in ('TRUE', 'FALSE'))
,constraint STATS$STATSPACK_ALL_INIT_CK
    check (all_init in ('TRUE', 'FALSE'))
,constraint STATS$STATSPACK_SQL_MTH_CK
    check (old_sql_capture_mth in ('TRUE','FALSE'))
) tablespace &&tablespace_name
  storage (initial 100k next 100k pctincrease 0);

create public synonym  STATS$STATSPACK_PARAMETER  for STATS$STATSPACK_PARAMETER;


/* ------------------------------------------------------------------------- */

create table STATS$SHARED_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,shared_pool_size_for_estimate  number     not null
,shared_pool_size_factor        number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_load_time              number
,estd_lc_load_time_factor       number
,estd_lc_memory_object_hits     number
,constraint STATS$SHARED_POOL_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, shared_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SHARED_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SHARED_POOL_ADVICE  for STATS$SHARED_POOL_ADVICE;

/* ------------------------------------------------------------------------- */

create table STATS$SQL_WORKAREA_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,low_optimal_size               number     not null
,high_optimal_size              number     not null
,optimal_executions             number
,onepass_executions             number
,multipasses_executions         number
,total_executions               number
,constraint STATS$SQL_WORKAREA_HIST_PK primary key 
     (snap_id, dbid, instance_number, low_optimal_size, high_optimal_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SQL_WORKAREA_HIST_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$SQL_WORKAREA_HISTOGRAM  for STATS$SQL_WORKAREA_HISTOGRAM;


/* ------------------------------------------------------------------------- */

create table STATS$PGA_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,pga_target_for_estimate        number     not null
,pga_target_factor              number
,advice_status                  varchar2(3)
,bytes_processed                number
,estd_time                      number
,estd_extra_bytes_rw            number
,estd_pga_cache_hit_percentage  number
,estd_overalloc_count           number
,constraint STATS$PGA_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, pga_target_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PGA_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$PGA_TARGET_ADVICE  for STATS$PGA_TARGET_ADVICE;


/* ------------------------------------------------------------------------- */

create table STATS$JAVA_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,java_pool_size_for_estimate    number     not null
,java_pool_size_factor          number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_load_time              number
,estd_lc_load_time_factor       number
,estd_lc_memory_object_hits     number
,constraint STATS$JAVA_POOL_ADVICE_PK primary key
     (snap_id, dbid, instance_number, java_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$JAVA_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$JAVA_POOL_ADVICE  for STATS$JAVA_POOL_ADVICE;


/* ------------------------------------------------------------------------- */

create table STATS$THREAD
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,thread#                        number     not null
,thread_instance_number         number
,status                         varchar2(6)
,open_time                      date
,current_group#                 number
,sequence#                      number
,constraint STATS$THREAD_PK primary key
     (snap_id, dbid, instance_number, thread#)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$THREAD_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$THREAD  for STATS$THREAD;


/* ------------------------------------------------------------------------- */

create table STATS$FILE_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,file#                          number     not null
,singleblkrdtim_milli           number     not null
,singleblkrds                   number
,constraint STATS$FILE_HISTOGRAM_PK primary key
     (snap_id, dbid, instance_number, file#, singleblkrdtim_milli)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$FILE_HISTOGRAM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$FILE_HISTOGRAM  for STATS$FILE_HISTOGRAM;

/* ------------------------------------------------------------------------- */

create table STATS$EVENT_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,event_id                       number     not null
,wait_time_milli                number     not null
,wait_count                     number
,constraint STATS$EVENT_HISTOGRAM_PK primary key
     (snap_id, dbid, instance_number, event_id, wait_time_milli)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$EVENT_HISTOGRAM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$EVENT_HISTOGRAM  for STATS$EVENT_HISTOGRAM;


/* ------------------------------------------------------------------------- */

create table STATS$TIME_MODEL_STATNAME
(stat_id                number       not null
,stat_name              varchar2(64) not null
,constraint STATS$TIME_MODEL_STATNAME_PK primary key
     (stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$TIME_MODEL_STATNAME  for STATS$TIME_MODEL_STATNAME;

/* ------------------------------------------------------------------------- */

create table STATS$SYS_TIME_MODEL
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,stat_id                        number     not null
,value                          number     not null
,constraint STATS$SYS_TIME_MODEL_PK primary key
     (snap_id, dbid, instance_number, stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SYS_TIME_MODEL_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SYS_TIME_MODEL  for STATS$SYS_TIME_MODEL;

/* ------------------------------------------------------------------------- */

create table STATS$SESS_TIME_MODEL
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,stat_id                        number     not null
,value                          number     not null
,constraint STATS$SESS_TIME_MODEL_PK primary key
     (snap_id, dbid, instance_number, stat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SESS_TIME_MODEL_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SESS_TIME_MODEL  for STATS$SESS_TIME_MODEL;

/* ------------------------------------------------------------------------- */

--
-- Streams support

--
-- Streams Capture

create table STATS$STREAMS_CAPTURE
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,capture_name                   varchar2(30) not null
,startup_time                   date         not null
,total_messages_captured        number
,total_messages_enqueued        number
,elapsed_capture_time           number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,elapsed_lcr_time               number
,elapsed_redo_wait_time         number
,elapsed_pause_time             number
,constraint STATS$STREAMS_CAPTURE_PK primary key
  (snap_id, dbid, instance_number, capture_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_CAPTURE_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$STREAMS_CAPTURE  for STATS$STREAMS_CAPTURE;

/* ------------------------------------------------------------------------- */

--
-- Streams Apply
-- Summary of data from v$apply_coordinator, v$apply_reader and v$apply_server

create table STATS$STREAMS_APPLY_SUM
(snap_id                              number       not null
,dbid                                 number       not null
,instance_number                      number       not null
,apply_name                           varchar2(30) not null
,startup_time                         date         not null
,reader_total_messages_dequeued       number
,reader_elapsed_dequeue_time          number
,reader_elapsed_schedule_time         number
,coord_total_received                 number
,coord_total_applied                  number
,coord_total_wait_deps                number
,coord_total_wait_commits             number
,coord_elapsed_schedule_time          number
,server_total_messages_applied        number
,server_elapsed_dequeue_time          number
,server_elapsed_apply_time            number
,constraint STATS$STREAMS_APPLY_SUM_PK primary key
  (snap_id, dbid, instance_number, apply_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_APPLY_SUM_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$STREAMS_APPLY_SUM for STATS$STREAMS_APPLY_SUM;

/* ------------------------------------------------------------------------- */

--
-- Propagation Sender

create table STATS$PROPAGATION_SENDER
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,queue_schema                   varchar2(30)  not null
,queue_name                     varchar2(30)  not null
,dblink                         varchar2(128) not null
,dst_queue_schema               varchar2(30)  not null
,dst_queue_name                 varchar2(30)  not null
,startup_time                   date
,total_msgs                     number
,total_bytes                    number
,elapsed_dequeue_time           number
,elapsed_pickle_time            number
,elapsed_propagation_time       number
,constraint STATS$PROPAGATION_SENDER_PK primary key
  (snap_id, dbid, instance_number
  ,queue_schema, queue_name, dblink, dst_queue_schema, dst_queue_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROPAGATION_SENDER_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROPAGATION_SENDER for STATS$PROPAGATION_SENDER;

/* ------------------------------------------------------------------------- */

--
-- Propagation Receiver

create table STATS$PROPAGATION_RECEIVER
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,src_queue_schema               varchar2(30)  not null
,src_queue_name                 varchar2(30)  not null
,src_dbname                     varchar2(128) not null
,dst_queue_schema               varchar2(30)  not null
,dst_queue_name                 varchar2(30)  not null
,startup_time                   date          not null
,elapsed_unpickle_time          number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,constraint STATS$PROPAGATION_RECEIVER_PK primary key
  (snap_id, dbid, instance_number
  ,src_queue_schema, src_queue_name, src_dbname
  ,dst_queue_schema, dst_queue_name )
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROPAGATION_RECEIVER_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROPAGATION_RECEIVER for STATS$PROPAGATION_RECEIVER;


/* ------------------------------------------------------------------------- */

--
-- Buffered Queues

create table STATS$BUFFERED_QUEUES
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,startup_time                   date         not null
,num_msgs                       number
,cnum_msgs                      number
,cspill_msgs                    number
,constraint STATS$BUFFERED_QUEUES_PK primary key
  (snap_id, dbid, instance_number, queue_schema, queue_name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$BUFFERED_QUEUES_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$BUFFERED_QUEUES for STATS$BUFFERED_QUEUES;

/* ------------------------------------------------------------------------- */

--
-- Buffered Subscribers
-- Joins to v$instance, dba_queues

create table STATS$BUFFERED_SUBSCRIBERS
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,subscriber_id                  number       not null 
,subscriber_name                varchar2(30) 
,subscriber_address             varchar2(1024)
,subscriber_type                varchar2(30)
,startup_time                   date         not null
,num_msgs                       number
,cnum_msgs                      number
,total_spilled_msg              number
,constraint STATS$BUFFERED_SUBSCRIBERS_PK primary key
  (snap_id, dbid, instance_number, queue_schema, queue_name, subscriber_id)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$BUFFERED_SUBSCRIBERS_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$BUFFERED_SUBSCRIBERS for STATS$BUFFERED_SUBSCRIBERS;

/* ------------------------------------------------------------------------- */

--
-- Rule Set

create table STATS$RULE_SET
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,owner                          varchar2(30) not null
,name                           varchar2(30) not null
,startup_time                   date         not null
,cpu_time                       number
,elapsed_time                   number
,evaluations                    number
,sql_free_evaluations           number
,sql_executions                 number
,reloads                        number
,constraint STATS$RULE_SET_PK primary key
  (snap_id, dbid, instance_number, owner, name)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$RULE_SET_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$RULE_SET for STATS$RULE_SET;


/* ------------------------------------------------------------------------- */

create table STATS$OSSTATNAME
(osstat_id              number       not null
,stat_name              varchar2(64) not null
,cumulative             varchar2(3)
,constraint STATS$OSSSTATNAME_PK primary key
     (osstat_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$OSSTATNAME  for STATS$OSSTATNAME;

/* ------------------------------------------------------------------------- */

--
-- OS Stat

create table STATS$OSSTAT
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,osstat_id                      number       not null
,value                          number
,constraint STATS$OSSTAT_PK primary key
  (snap_id, dbid, instance_number, osstat_id)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$OSSTAT_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$OSSTAT for STATS$OSSTAT;

/* ------------------------------------------------------------------------- */

--
-- Process - Rollup

create table STATS$PROCESS_ROLLUP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,pid                            number       not null
,serial#                        number       not null
,spid                           varchar2(12)
,program                        varchar2(48)
,background                     varchar2(1)
,pga_used_mem                   number
,pga_alloc_mem                  number
,pga_freeable_mem               number
,max_pga_alloc_mem              number
,max_pga_max_mem                number
,avg_pga_alloc_mem              number
,stddev_pga_alloc_mem           number
,num_processes                  number
,constraint STATS$$PROCESS_ROLLUP_PK primary key
  (snap_id, dbid, instance_number, pid, serial#)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$$PROCESS_ROLLUP_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROCESS_ROLLUP for STATS$PROCESS_ROLLUP;

/* ------------------------------------------------------------------------- */

--
-- Process Memory

create table STATS$PROCESS_MEMORY_ROLLUP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,pid                            number       not null
,serial#                        number       not null
,category                       varchar2(15) not null
,allocated                      number
,used                           number
,max_allocated                  number
,max_max_allocated              number
,avg_allocated                  number
,stddev_allocated               number
,non_zero_allocations           number
,constraint STATS$PROCESS_MEMORY_ROLLUP_PK primary key
  (snap_id, dbid, instance_number, pid, serial#, category)
   using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$PROCESS_MEMORY_ROLLUP_FK foreign key 
  (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym STATS$PROCESS_MEMORY_ROLLUP for STATS$PROCESS_MEMORY_ROLLUP;

/* ------------------------------------------------------------------------- */

create table STATS$SGA_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,sga_size                       number     not null
,sga_size_factor                number
,estd_db_time                   number
,estd_db_time_factor            number
,estd_physical_reads            number
,constraint STATS$SGA_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, sga_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$SGA_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$SGA_TARGET_ADVICE  for STATS$SGA_TARGET_ADVICE;

/* ------------------------------------------------------------------------- */

create table STATS$STREAMS_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,streams_pool_size_for_estimate number     not null
,streams_pool_size_factor       number
,estd_spill_count               number
,estd_spill_time                number
,estd_unspill_count             number
,estd_unspill_time              number
,constraint STATS$STREAMS_POOL_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, streams_pool_size_for_estimate)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$STREAMS_POOL_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$STREAMS_POOL_ADVICE  for STATS$STREAMS_POOL_ADVICE;

/* ------------------------------------------------------------------------- */

create table STATS$MUTEX_SLEEP
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,mutex_type                     varchar2(32) not null
,location                       varchar2(40) not null
,sleeps                         number
,wait_time                      number
,constraint STATS$MUTEX_SLEEP_PK primary key 
     (snap_id, dbid, instance_number, mutex_type, location)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MUTEX_SLEEP_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$MUTEX_SLEEP  for STATS$MUTEX_SLEEP;

/* ------------------------------------------------------------------------- */

create table STATS$DYNAMIC_REMASTER_STATS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,remaster_ops                   number
,remaster_time                  number
,remastered_objects             number
,quiesce_time                   number
,freeze_time                    number
,cleanup_time                   number
,replay_time                    number
,fixwrite_time                  number
,sync_time                      number
,resources_cleaned              number
,replayed_locks_sent            number
,replayed_locks_received        number
,current_objects                number
,constraint STATS$DYNAMIC_REM_STATS_PK primary key 
     (snap_id, dbid, instance_number)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$DYNAMIC_REM_STATS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$DYNAMIC_REMASTER_STATS  for STATS$DYNAMIC_REMASTER_STATS;

/* ------------------------------------------------------------------------- */

create global temporary table STATS$TEMP_SQLSTATS
( old_hash_value           number
, text_subset              varchar2(31) 
, module                   varchar2(64)
, delta_buffer_gets        number
, delta_executions         number
, delta_cpu_time           number
, delta_elapsed_time       number
, avg_elapsed_time         number
, avg_hard_parse_time      number
, delta_disk_reads         number
, delta_parse_calls        number
, max_sharable_mem         number
, last_sharable_mem        number
, delta_version_count      number 
, max_version_count        number 
, last_version_count       number 
, delta_cluster_wait_time  number
, delta_rows_processed     number
)
on commit preserve rows;

create public synonym  STATS$TEMP_SQLSTATS for STATS$TEMP_SQLSTATS;

/* ------------------------------------------------------------------------- */

create table STATS$IOSTAT_FUNCTION_NAME
(function_id                   number        not null
,function_name                 varchar2(18)  not null
,constraint STATS$IOSTAT_FUNCTION_NAME_PK primary key 
     (function_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$IOSTAT_FUNCTION_NAME for STATS$IOSTAT_FUNCTION_NAME;

/* ------------------------------------------------------------------------- */

create table STATS$IOSTAT_FUNCTION
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,function_id                    number     not null
,small_read_megabytes           number
,small_write_megabytes          number
,large_read_megabytes           number
,large_write_megabytes          number
,small_read_reqs                number
,small_write_reqs               number
,large_read_reqs                number
,large_write_reqs               number
,number_of_waits                number
,wait_time                      number
,constraint STATS$IOSTAT_FUNCTION_PK primary key 
     (snap_id, dbid, instance_number, function_id)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$IOSTAT_FUNCTION_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;
 
create public synonym  STATS$IOSTAT_FUNCTION  for STATS$IOSTAT_FUNCTION;

/* ------------------------------------------------------------------------- */

create table STATS$MEMORY_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,memory_size                    number     not null
,memory_size_factor             number
,estd_db_time                   number
,estd_db_time_factor            number
,version                        number
,constraint STATS$MEMORY_TARGET_ADVICE_PK primary key 
     (snap_id, dbid, instance_number, memory_size)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_TARGET_ADVICE_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_TARGET_ADVICE  for STATS$MEMORY_TARGET_ADVICE
;

/* ------------------------------------------------------------------------- */

create table STATS$MEMORY_DYNAMIC_COMPS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,component                      varchar2(64) not null
,current_size                   number
,min_size                       number
,max_size                       number
,user_specified_size            number
,oper_count                     number
,last_oper_type                 varchar2(13)
,last_oper_mode                 varchar2(9)
,last_oper_time                 date
,granule_size                   number
,constraint STATS$MEMORY_DYNAMIC_COMPS_PK primary key 
     (snap_id, dbid, instance_number, component)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_DYNAMIC_COMPS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_DYNAMIC_COMPS  for STATS$MEMORY_DYNAMIC_COMPS;


/* ------------------------------------------------------------------------- */

create table STATS$MEMORY_RESIZE_OPS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,component                      varchar2(64) not null
,oper_type                      varchar2(13) not null
,oper_mode                      varchar2(9) not null
,start_time                     date        not null
,initial_size                   number      not null
,target_size                    number      not null
,final_size                     number      not null
,status                         varchar2(9) not null
,end_time                       date        not null
,parameter                      varchar2(80)
,num_ops                        number
,constraint STATS$MEMORY_RESIZE_OPS_PK primary key 
     ( snap_id, dbid, instance_number
     , component, oper_type, start_time, oper_mode
     , initial_size, target_size, final_size,status, end_time )
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$MEMORY_RESIZE_OPS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$MEMORY_RESIZE_OPS  for STATS$MEMORY_RESIZE_OPS;


/* ------------------------------------------------------------------------- */

create table STATS$INTERCONNECT_PINGS
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,target_instance                number     not null
,iter_500b                      number
,wait_500b                      number
,waitsq_500b                    number
,iter_8k                        number
,wait_8k                        number
,waitsq_8k                      number
,constraint STATS$INTERCONNECT_PINGS_PK primary key 
     (snap_id, dbid, instance_number, target_instance)
 using index tablespace &&tablespace_name
   storage (initial 1m next 1m pctincrease 0)
,constraint STATS$INTERCONNECT_PINGS_FK foreign key 
     (snap_id, dbid, instance_number)
    references STATS$SNAPSHOT on delete cascade
) tablespace &&tablespace_name
  storage (initial 1m next 1m pctincrease 0) pctfree 5 pctused 40;

create public synonym  STATS$INTERCONNECT_PINGS  for 
                       STATS$INTERCONNECT_PINGS;

/* ------------------------------------------------------------------------- */

create or replace view STATS$BG_EVENT_SUMMARY as
select snap_id
     , dbid
     , instance_number
     , event
     , total_waits       - total_waits_fg       total_waits
     , total_timeouts    - total_timeouts_fg    total_timeouts
     , time_waited_micro - time_waited_micro_fg time_waited_micro
  from stats$system_event;
create or replace public synonym  STATS$BG_EVENT_SUMMARY for 
                                  STATS$BG_EVENT_SUMMARY;

/* ------------------------------------------------------------------------- */

create table          STATS$IDLE_EVENT
(event                varchar2(64)     not null
,constraint STATS$IDLE_EVENT_PK primary key (event)
 using index tablespace &&tablespace_name
   storage (initial 100k next 100k pctincrease 0)
) tablespace &&tablespace_name
  storage (initial 100k next 100k pctincrease 0) pctfree 5 pctused 40;

insert into STATS$IDLE_EVENT (event) values ('smon timer');
insert into STATS$IDLE_EVENT (event) values ('pmon timer');
insert into STATS$IDLE_EVENT (event) values ('rdbms ipc message');
insert into STATS$IDLE_EVENT (event) values ('Null event');
insert into STATS$IDLE_EVENT (event) values ('parallel query dequeue');
insert into STATS$IDLE_EVENT (event) values ('pipe get');
insert into STATS$IDLE_EVENT (event) values ('client message');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net message to client');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net message from client');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net more data from client');
insert into STATS$IDLE_EVENT (event) values ('dispatcher timer');
insert into STATS$IDLE_EVENT (event) values ('virtual circuit status');
insert into STATS$IDLE_EVENT (event) values ('lock manager wait for remote message');
insert into STATS$IDLE_EVENT (event) values ('PX Idle Wait');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Execution Msg');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Table Q Normal');
insert into STATS$IDLE_EVENT (event) values ('wakeup time manager');
insert into STATS$IDLE_EVENT (event) values ('slave wait');
insert into STATS$IDLE_EVENT (event) values ('i/o slave wait');
insert into STATS$IDLE_EVENT (event) values ('jobq slave wait');
insert into STATS$IDLE_EVENT (event) values ('null event');
insert into STATS$IDLE_EVENT (event) values ('gcs remote message');
insert into STATS$IDLE_EVENT (event) values ('gcs for action');
insert into STATS$IDLE_EVENT (event) values ('ges remote message');
insert into STATS$IDLE_EVENT (event) values ('queue messages');
insert into STATS$IDLE_EVENT (event) values ('wait for unread message on broadcast channel');
insert into STATS$IDLE_EVENT (event) values ('PX Deq Credit: send blkd');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Execute Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Signal ACK');
insert into STATS$IDLE_EVENT (event) values ('PX Deque wait');
insert into STATS$IDLE_EVENT (event) values ('PX Deq Credit: need buffer');
insert into STATS$IDLE_EVENT (event) values ('STREAMS apply coord waiting for slave message'); 
insert into STATS$IDLE_EVENT (event) values ('STREAMS apply slave waiting for coord message'); 
insert into STATS$IDLE_EVENT (event) values ('Queue Monitor Wait'); 
insert into STATS$IDLE_EVENT (event) values ('Queue Monitor Slave Wait'); 
insert into STATS$IDLE_EVENT (event) values ('wakeup event for builder'); 
insert into STATS$IDLE_EVENT (event) values ('wakeup event for preparer'); 
insert into STATS$IDLE_EVENT (event) values ('wakeup event for reader'); 
insert into STATS$IDLE_EVENT (event) values ('wait for activate message'); 
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Par Recov Execute');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Table Q Sample');
insert into STATS$IDLE_EVENT (event) values ('STREAMS apply slave idle wait');
insert into STATS$IDLE_EVENT (event) values ('STREAMS capture process filter callback wait for ruleset');
insert into STATS$IDLE_EVENT (event) values ('STREAMS fetch slave waiting for txns');
insert into STATS$IDLE_EVENT (event) values ('STREAMS waiting for subscribers to catch up');
insert into STATS$IDLE_EVENT (event) values ('Queue Monitor Shutdown Wait');
insert into STATS$IDLE_EVENT (event) values ('AQ Proxy Cleanup Wait');
insert into STATS$IDLE_EVENT (event) values ('knlqdeq');
insert into STATS$IDLE_EVENT (event) values ('class slave wait');
insert into STATS$IDLE_EVENT (event) values ('master wait');
insert into STATS$IDLE_EVENT (event) values ('DIAG idle wait');
insert into STATS$IDLE_EVENT (event) values ('ASM background timer');
insert into STATS$IDLE_EVENT (event) values ('KSV master wait');
insert into STATS$IDLE_EVENT (event) values ('EMON idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: RAC qmn coordinator idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: qmn coordinator idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: qmn slave idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: waiting for time management or cleanup tasks');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: waiting for messages in the queue');
insert into STATS$IDLE_EVENT (event) values ('Streams fetch slave: waiting for txns');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: deallocate messages from Streams Pool');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: delete acknowledged messages');
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC archive log');
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC dest activation');
insert into STATS$IDLE_EVENT (event) values ('LNS ASYNC end of log');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: client waiting for transaction');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: slave waiting for activate message');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for builder');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for preparer');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: wakeup event for reader');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: generic process sleep');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: reader waiting for more redo');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: waiting for processes to soft detach');
insert into STATS$IDLE_EVENT (event) values ('Space Manager: slave idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams capture: waiting for archive log');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery coordinator waits for slave cleanup');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave idle wait');
insert into STATS$IDLE_EVENT (event) values ('watchdog main loop');
insert into STATS$IDLE_EVENT (event) values ('DBRM Logical Idle Wait');
insert into STATS$IDLE_EVENT (event) values ('EMON slave idle wait');
insert into STATS$IDLE_EVENT (event) values ('IORM Scheduler Slave Idle Wait');
insert into STATS$IDLE_EVENT (event) values ('pool server timer');
insert into STATS$IDLE_EVENT (event) values ('cmon timer');
insert into STATS$IDLE_EVENT (event) values ('fbar timer');
insert into STATS$IDLE_EVENT (event) values ('PING');
insert into STATS$IDLE_EVENT (event) values ('MRP redo arrival');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave next change');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery slave wait for change');
-- added for 11.2
insert into STATS$IDLE_EVENT (event) values ('JOX Jit Process Sleep');
insert into STATS$IDLE_EVENT (event) values ('HS message to agent');
insert into STATS$IDLE_EVENT (event) values ('JS external job');
insert into STATS$IDLE_EVENT (event) values ('LGWR real time apply sync');
insert into STATS$IDLE_EVENT (event) values ('LogMiner reader: log (idle)');
insert into STATS$IDLE_EVENT (event) values ('LogMiner reader: redo (idle)');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: activate');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: find session');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: internal');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: other');
insert into STATS$IDLE_EVENT (event) values ('LogMiner: reset');
insert into STATS$IDLE_EVENT (event) values ('Logical Standby Apply Delay');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Close');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Execute');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Index Merge Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Join ACK');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Metadata Update');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Msg Fragment');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Parse Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Txn Recovery Reply');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: Txn Recovery Start');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: kdcph_mai');
insert into STATS$IDLE_EVENT (event) values ('PX Deq: kdcphc_ack');
insert into STATS$IDLE_EVENT (event) values ('SGA: MMAN sleep for component shrink');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net vector message from client');
insert into STATS$IDLE_EVENT (event) values ('SQL*Net vector message from dblink');
insert into STATS$IDLE_EVENT (event) values ('Streams AQ: emn coordinator idle wait');
insert into STATS$IDLE_EVENT (event) values ('Streams: waiting for messages');
insert into STATS$IDLE_EVENT (event) values ('VKRM Idle');
insert into STATS$IDLE_EVENT (event) values ('VKTM Init Wait for GSGA');
insert into STATS$IDLE_EVENT (event) values ('VKTM Logical Idle Wait');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay client notify');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay clock');
insert into STATS$IDLE_EVENT (event) values ('WCR: replay paused');
insert into STATS$IDLE_EVENT (event) values ('auto-sqltune: wait graph update');
insert into STATS$IDLE_EVENT (event) values ('heartbeat monitor sleep');
insert into STATS$IDLE_EVENT (event) values ('shared server idle wait');
insert into STATS$IDLE_EVENT (event) values ('simulated log write delay');
insert into STATS$IDLE_EVENT (event) values ('single-task message');
insert into STATS$IDLE_EVENT (event) values ('wait for unread message on multiple broadcast channels');
insert into STATS$IDLE_EVENT (event) values ('cell worker idle');
/*------------------------------------------------------------*/
/* 8/11/2010 Bug#9800868 Add Missing Idle Events for 11.2.0.2 */
/*------------------------------------------------------------*/
insert into STATS$IDLE_EVENT (event) values ('GCR sleep');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: branch');
insert into STATS$IDLE_EVENT (event) values ('LogMiner builder: idle');
insert into STATS$IDLE_EVENT (event) values ('LogMiner client: transaction');
insert into STATS$IDLE_EVENT (event) values ('LogMiner preparer: idle');
insert into STATS$IDLE_EVENT (event) values ('parallel recovery control message reply');

commit;
 
create public synonym  STATS$IDLE_EVENT   for STATS$IDLE_EVENT;

/* ------------------------------------------------------------------------- */

-- In anticipation of creating statspack
create public synonym STATSPACK  for STATSPACK;

/* ------------------------------------------------------------------------- */

prompt
prompt NOTE:
prompt   SPCTAB complete. Please check spctab.lis for any errors.
prompt

spool off;
undefine tablespace_name default_tablespace temporary_tablespace
whenever sqlerror continue;
set echo on;
