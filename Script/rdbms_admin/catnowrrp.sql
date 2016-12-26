Rem
Rem $Header: rdbms/admin/catnowrrp.sql /st_rdbms_11.2.0/2 2013/03/11 01:24:28 yujwang Exp $
Rem
Rem catnowrrp.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnowrrp.sql - Catalog script to delete the 
Rem                      Workload Replay schema
Rem
Rem    DESCRIPTION
Rem      Undo file for all objects created in catwrrtbp.sql
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hpoduri     07/18/12 - add for ash time period object type
Rem    lgalanis    12/27/11 - add user map
Rem    spapadom    11/10/11 - drop WRR$_ASREPLAY_DATA table
Rem    kmorfoni    04/12/11 - drop WRR$_FILE_ID_MAP table
Rem    yujwang     01/05/11 - drop workload consolidation tables
Rem    lgalanis    02/15/10 - workload attributes
Rem    rcolle      09/09/08 - 
Rem    rcolle      11/07/08 - drop WRR$_REPLAY_CALL_FILTER
Rem    sburanaw    03/28/08 - drop wrr$_replay_data
Rem    lgalanis    08/07/08 - drop the seqeunce exception table
Rem    rcolle      07/08/08 - drop WRR$_REPLAY_SQL_TEXT and
Rem                           WRR$_REPLAY_SQL_BINDS
Rem    rcolle      05/08/08 - drop WRR$_REPLAY_UC_GRAPH
Rem    rcolle      04/04/08 - drop tables for new synchronization (dep_graph,
Rem                           commits and references)
Rem    yujwang     08/05/06 - drop wrr$_replay_stats
Rem    veeve       07/13/06 - stop replay in catnowrr.sql
Rem    lgalanis    06/03/06 - connection information 
Rem    veeve       06/02/06 - drop replay divergence, scn order, seqdata
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - Created
Rem

Rem =========================================================
Rem Dropping the Workload Replay Tables
Rem =========================================================
Rem

delete from PROPS$
where name = 'WORKLOAD_REPLAY_MODE'
/
commit
/

drop table WRR$_REPLAYS
/

drop sequence WRR$_REPLAY_ID
/

drop table WRR$_REPLAY_DIVERGENCE
/

drop table WRR$_REPLAY_SCN_ORDER
/

drop table WRR$_REPLAY_SEQ_DATA
/

drop table WRR$_CONNECTION_MAP
/

drop table WRR$_REPLAY_STATS
/

drop table WRR$_REPLAY_UC_GRAPH
/

drop table WRR$_REPLAY_SQL_TEXT
/

drop table WRR$_REPLAY_SQL_BINDS
/

drop table WRR$_SEQUENCE_EXCEPTIONS
/

drop table WRR$_REPLAY_DATA
/

drop table WRR$_REPLAY_CALL_FILTER
/

drop table WRR$_REPLAY_FILTER_SET
/

drop table WRR$_REPLAY_DEP_GRAPH
/

drop table WRR$_REPLAY_COMMITS
/

drop table WRR$_REPLAY_REFERENCES
/

drop table WRR$_WORKLOAD_ATTRIBUTES
/

drop table WRR$_SCHEDULE_ORDERING
/

drop table WRR$_SCHEDULE_CAPTURES
/

drop table WRR$_REPLAY_SCHEDULES
/

drop table WRR$_FILE_ID_MAP
/

drop table WRR$_REPLAY_DIRECTORY
/

drop table WRR$_USER_MAP
/

drop type  WRR$_ASH_TIME_PERIOD
/
