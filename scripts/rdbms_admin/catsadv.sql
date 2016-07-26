Rem
Rem $Header: rdbms/admin/catsadv.sql /st_rdbms_11.2.0/2 2011/01/14 09:53:51 vchandar Exp $
Rem
Rem catsadv.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsadv.sql - Streams Advisor
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vchandar    01/12/11 - Backport vchandar_bug-10384221 from main
Rem    vchandar    12/29/10 - bug 10384221
Rem    vchandar    07/20/10 - Backport vchandar_bug-9891228 from main
Rem    vchandar    06/22/10 - bug 9216660
Rem    rmao        05/19/10 - change to dba_capture/apply.purpose
Rem    haxu        04/02/10 - exclude local anr from propagation receiver
Rem    vchandar    02/21/10 - fix apply latency/throughput queries for XOut
Rem    bpwang      01/28/10 - Bug 9256726: Add path status, component state
Rem    arbalakr    11/13/09 - increase length of module and action columns
Rem    thoang      06/01/09 - use hwm_time to compute XOut latency
Rem    jinwu       01/13/09 - display active paths only
Rem    tianli      10/14/08 - use server_id for xstream server filtering
Rem    jinwu       09/12/08 - decode component status
Rem    jinwu       09/09/08 - apply latency 0 if apply in idle state
Rem    tianli      08/11/08 - change XStream component
Rem    jinwu       04/08/08 - change CCA_MODE to OPTIMIZATION_MODE
Rem    jinwu       04/04/08 - remove column ORIGINAL_PATH_ID and ACTIVE
Rem    jinwu       04/01/08 - remove network stats for Capture
Rem    jinwu       03/31/08 - fix PS "src_schema"."src_queue"=>"".""@dstdb
Rem    jinwu       02/08/08 - change 'APPLY NETWORK RECEIVER' to
Rem                           'PROPAGATION SENDER+RECEIVER' for local CCAC
Rem    jinwu       01/24/08 - get rid of x$kwqps and x$kwqpd
Rem    jinwu       01/24/08 - use gv$streams_capture.OPTIMIZATION for CCA_MODE
Rem    jinwu       01/17/08 - use flags_knstcap to tell CCA or CCAC
Rem    jinwu       01/15/08 - change name for PS and PR
Rem    jinwu       01/02/08 - add capture prop CCA_MODE
Rem    jinwu       01/02/08 - remove direct link CAPTURE->APPLY
rem    jinwu       07/05/07 - rename 'CPATURE PROCESS' to 'CAPTURE SESSION'
rem    jinwu       06/08/07 - distinguish propagation sender based on dest db
Rem    jinwu       05/24/07 - add capture/apply parallelism in
Rem                           "_DBA_STREAMS_COMPONENT_PROP"
Rem    jinwu       05/19/07 - add sub_component_type in
Rem                           "_DBA_STREAMS_COMPONENT_EVENT"
Rem    jinwu       05/11/07 - correct TOTAL_COUNT in
Rem                           "_DBA_STREAMS_COMPONENT_EVENT"
Rem    jinwu       03/21/07 - collect event based on advisor_run_time
Rem    jinwu       03/09/07 - outer join in dba_streams_tp_path_bottleneck
Rem    jinwu       02/03/07 - support diagnostic pack access
Rem    jinwu       02/01/07 - change MESSAGE_DELIVERY_MODE from BUFFERED to
Rem                           CAPTURED for apply
Rem    jinwu       01/31/07 - compose component propagation sender using
Rem                           streams$_propagation_process
Rem    jinwu       12/18/06 - add column access_status
Rem    jinwu       12/15/06 - modify capture and apply latency
Rem    jinwu       11/13/06 - count(distinct sample_time) as total_count
Rem    jinwu       10/10/06 - replace OPTIMIZED with ORIGINAL_PATH_ID
Rem    jinwu       09/18/06 - add event_type to streams$_component_event_in
Rem    jinwu       09/07/06 - split streams advisor from catstr.sql
Rem    jinwu       09/07/06 - Created
Rem

rem --------------------------------------------------------------------------
rem temporary tables created for Configuration/Performance/Error advisors
rem   -  streams$_component_in
rem   -  streams$_component_link_in
rem   -  streams$_component_prop_in
rem   -  streams$_component_stat_in
rem   -  streams$_component_event_in
rem   -  streams$_local_findings_in
rem   -  streams$_local_actions_in
rem   -  streams$_local_recs_in
rem   -  streams$_component_stat_out
rem   -  streams$_path_stat_out
rem   -  streams$_path_bottleneck_out
rem ---------------------------------------------------------------------------
rem temporary table for streams component 
create global temporary table streams$_component_in
(
  component_id           number,                      /* ID of the component */
  component_name         varchar2(4000),            /* name of the component */
  component_db           varchar2(128),          /* db the component resides */
  component_type         number,            /* type of the Streams component */
                                                   /* 1              capture */
                                                   /* 2   propagation sender */
                                                   /* 3 propagation receiver */
                                                   /* 4                apply */
                                                   /* 5                queue */
  component_property     number,              /* properties of the component */
                                                  /* 0x01 downstream capture */
                                                  /* 0x02      local capture */
                                                  /* 0x04         hot mining */
                                                  /* 0x08        cold mining */
                                                  /* 0x10     buffered queue */
                                                  /* 0x20   persistent queue */
  component_changed_time date,   /* time that the component was last changed */
  analysis_flag          raw(4) default '00000000',  /* flag of the analysis */
                                         /* to be conducted on the component */
                     /* Value '00000001' - selected for statistical analysis */
  spare1                 number,                           /* spare column 1 */
  spare2                 number,                           /* spare column 2 */
  spare3                 varchar2(4000),                   /* spare column 3 */
  spare4                 date                              /* spare column 4 */
)ON COMMIT PRESERVE ROWS
/

rem temporary table for streams component link
create global temporary table streams$_component_link_in
(
  source_component_id   number,                /* ID of the source component */
  source_component_name varchar2(4000),      /* name of the source component */
  source_component_db   varchar2(128),            /* the source component db */
  source_component_type number,              /* type of the source component */
  dest_component_id     number,                  /* ID of the dest component */
  dest_component_name   varchar2(4000),        /* name of the dest component */
  dest_component_db     varchar2(128),              /* the dest component db */
  dest_component_type   number,         /* type of the destination component */
  path_id               number,   /* ID of the path the component belongs to */
  position              number,   /* position of the link in the stream path */
  path_flag             raw(4) default '00000000',/* flag of the stream path */
                         /* bit 1 -    whether the link is on an active path */
                         /* bit 2 - whether the link is on an optimized path */
                             /* value '00000000' - inactive unoptimized path */
                             /* value '00000001' -   active unoptimized path */
                             /* value '00000002' -   inactive optimized path */
                             /* value '00000003' -     active optimized path */
  spare1                number,
  spare2                number,
  spare3                varchar2(4000),
  spare4                date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for Streams component properties
rem This table contains information such as SOURCE_DATABASE, APPLY_CAPTURED
rem and MESSAGE_DELIVERY_MODE. Such information can be used to prune topology
rem path calculation. 
create global temporary table streams$_component_prop_in
(
  component_name varchar2(4000),                    /* name of the component */
  component_db   varchar2(128),         /* db on which the component resides */
  component_type number,                            /* type of the component */
  prop_name      varchar2(30),                       /* name of the property */
  prop_value     varchar2(4000),                    /* value of the property */
  spare1         number,
  spare2         number,
  spare3         varchar2(4000),
  spare4         date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for Streams component statistics
create global temporary table streams$_component_stat_in
(
  component_name varchar2(4000),                    /* name of the component */
  component_db   varchar2(128),         /* db on which the component resides */
  component_type number,                            /* type of the component */
  stat_time      date,                    /* time that statistics were taken */
  count1         number,                /* first count dependent on the type */
  count2         number,               /* second count dependent on the type */
  count3         number,                       /* third count (spare column) */
  count4         number,                       /* fouth count (spare column) */
  latency        number,                         /* latency of the component */
  status         number,                          /* status of the component */
  snapshot       number,          /* number of component statistics snapshot */
  spare1         number,
  spare2         number,
  spare3         varchar2(4000),
  spare4         date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for Streams component event
create global temporary table streams$_component_event_in
(
  component_name  varchar2(4000),                  /* name of the component */
  component_db    varchar2(128),       /* db on which the component resides */
  component_type  number,                          /* type of the component */
  sub_component_type
                  number default null,         /* type of the sub-component */
  stat_time       date,                  /* time that statistics were taken */
  session_id      number,                    /* session id of the component */
  session_serial# number,         /* session serial number of the component */
  event           varchar2(128),                /* description of the event */
  event_type      number,                              /* type of the event */
                                            /* Value 0 : BUSY event         */
                                            /* Value 1 : IDLE event         */
                                            /* Value 2 : FLOW CONTROL event */
  event_count     number,         /* number of times the event has appeared */
  total_count     number,     /* total number of occurrence times of events */
  module_name     varchar2(64),    /* name of the module where event occurs */
  action_name     varchar2(64),    /* name of the action where event occurs */
                                /* Example: module_name =         'STREAMS' */
                                /* Example: action_name = 'STREAMS Capture' */
  spare1          number,
  spare2          number,
  spare3          varchar2(4000),
  spare4          date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for Streams local findings
create global temporary table streams$_local_findings_in
(
  message_id   number,                          /* id of the finding message */
  message_arg1 varchar2(4000),          /* argument 1 to the finding message */
  message_arg2 varchar2(4000),          /* argument 2 to the finding message */
  message_arg3 varchar2(4000),          /* argument 3 to the finding message */
  message_arg4 varchar2(4000),          /* argument 4 to the finding message */
  message_arg5 varchar2(4000),          /* argument 5 to the finding message */
  type         number,                                /* type of the finding */
  more_info_id number,             /* id of more_info related to the finding */
  info_arg1    varchar2(4000),        /* argument 1 to the finding more info */
  info_arg2    varchar2(4000),        /* argument 2 to the finding more info */
  info_arg3    varchar2(4000),        /* argument 3 to the finding more info */
  info_arg4    varchar2(4000),        /* argument 4 to the finding more info */
  info_arg5    varchar2(4000),        /* argument 5 to the finding more info */
  advisor_type varchar2(30),            /* type of the advisor: PERFORMANCE, */
                                                 /* CONFIGURATION, and ERROR */
  run_time     date,                        /* time that the advisor was run */
  spare1       number,
  spare2       number,
  spare3       varchar2(4000),
  spare4       date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for Streams local recommendations
create global temporary table streams$_local_recs_in
(
  benefit_id   number,          /* ID for the benefit of this recommendation */
  benefit_arg1 varchar2(4000),             /* argument 1 to the rec. benefit */
  benefit_arg2 varchar2(4000),             /* argument 2 to the rec. benefit */
  benefit_arg3 varchar2(4000),             /* argument 3 to the rec. benefit */
  benefit_arg4 varchar2(4000),             /* argument 4 to the rec. benefit */
  benefit_arg5 varchar2(4000),             /* argument 5 to the rec. benefit */
  advisor_type varchar2(30),                          /* type of the advisor */
  run_time     date,                        /* time that the advisor was run */
  spare1       number,
  spare2       number,
  spare3       varchar2(4000),
  spare4       date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for streams local actions
create global temporary table streams$_local_actions_in
(
  message_id   number,                           /* id of the action message */
  message_arg1 varchar2(4000),           /* argument 1 to the action message */
  message_arg2 varchar2(4000),           /* argument 2 to the action message */
  message_arg3 varchar2(4000),           /* argument 3 to the action message */
  message_arg4 varchar2(4000),           /* argument 4 to the action message */
  message_arg5 varchar2(4000),           /* argument 5 to the action message */
  command      varchar2(64),         /* command to run to execute the action */
  command_id   number,                           /* id of the command to run */
  flags        number,                   /* flags associated with the action */
  attr1        varchar2(4000),                                /* attribute 1 */
  attr2        varchar2(4000),                                /* attribute 2 */
  attr3        varchar2(4000),                                /* attribute 3 */
  attr4        varchar2(4000),                                /* attribute 4 */
  attr5        clob,                                          /* attribute 5 */
  attr6        clob,                                          /* attribute 6 */
  num_attr1    number,                       /* attribute 1 in number format */
  num_attr2    number,                       /* attribute 2 in number format */
  num_attr3    number,                       /* attribute 3 in number format */
  num_attr4    number,                       /* attribute 4 in number format */
  num_attr5    number,                       /* attribute 5 in number format */
  advisor_type varchar2(30),                          /* type of the advisor */
  run_time     date,                        /* time that the advisor was run */
  spare1       number,
  spare2       number,
  spare3       varchar2(4000),
  spare4       date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for streams component statistics for tuning
create global temporary table streams$_component_stat_out
(
  component_id     number,                            /* id of the component */
  statistic_time   date,                /* time that the statistic was taken */
  statistic_name   varchar2(64),  /* name of the statistic. arbitrary length */
  statistic_value  number,                         /* value of the statistic */
  statistic_unit   varchar2(64),  /* unit of the statistic. arbitrary length */
  advisor_run_id   number,          /* 1-based logical number of advisor run */
  advisor_run_time date,                    /* time that the advisor was run */
  sub_component_type
                   number default null,     /* type of Streams sub-component */
  /* Specify the id and serial# of session for which statistic is calculated */
  session_id       number default null,                 /* id of the session */
  session_serial#  number default null,            /* serial# of the session */
  spare1           number,
  spare2           number,
  spare3           varchar2(4000),
  spare4           date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for derived stream statistics
create global temporary table streams$_path_stat_out
(
  path_id          number,                                  /* id the stream */
  statistic_time   date,                /* time that the statistic was taken */
  statistic_name   varchar2(64),  /* name of the statistic. arbitrary length */
  statistic_value  number,                         /* value of the statistic */
  statistic_unit   varchar2(64),  /* unit of the statistic. arbitrary length */
  advisor_run_id   number,          /* 1-based logical number of advisor run */
  advisor_run_time date,                    /* time that the advisor was run */
  spare1           number,
  spare2           number,
  spare3           varchar2(4000),
  spare4           date
)ON COMMIT PRESERVE ROWS
/

rem temporary table for stream bottleneck components
create global temporary table streams$_path_bottleneck_out
(
  path_id             number,                               /* id the stream */
  component_id        number,                         /* id of the component */
  top_session_id      number,             /* top session id of the component */
  top_session_serial# number,  /* top session serial number of the component */
  module_name         varchar2(64),  /* the module name for the top session */
  action_name         varchar2(64),  /* the action name for the top session */
  bottleneck_identified
                      varchar2(30),     /* whether bottleneck was identified */
  advisor_run_id      number,       /* 1-based logical number of advisor run */
  advisor_run_time    date,                 /* time that the advisor was run */
  advisor_run_reason  varchar2(4000),       /* reason for bottleneck results */
  spare1              number,
  spare2              number,
  spare3              varchar2(4000),
  spare4              date
)ON COMMIT PRESERVE ROWS
/

----------------------------------------------------------------------------
-- Streams Performance Advisor
----------------------------------------------------------------------------
-- Per database views
--    "_DBA_STREAMS_COMPONENT"
--    "_DBA_STREAMS_COMPONENT_LINK"
--    "_DBA_STREAMS_COMPONENT_PROP"
--    "_DBA_STREAMS_COMPONENT_STAT"
--    "_DBA_STREAMS_COMPONENT_EVENT"
--
-- Each view has four spare columns
--    SPARE1: number
--    SPARE2: number
--    SPARE3: varchar2(4000)
--    SPARE4: date
-- 
----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT"
----------------------------------------------------------------------------
-- COMPONENT_TYPE:
--     1    - capture
--     2    - propagation sender
--     3    - propagation receiver
--     4    - apply
--     5    - queue
-- Note: should be consistent with constant definitions in package 
--       dbms_streams_advisor_adm
-- COMPONENT_PROPERTY:
--     0x01 - downstream capture (bit 1)
--     0x02 - local capture (bit 2)
--     0x04 - hotmining (bit 3)
--     0x08 - coldmining (bit 4)
--     0x10 - buffered queue (bit 5)
--     0x20 - persistent queue (bit 6)
--
-- Since 11.1.0.7, PROPAGATON SENDER and PROPAGATION RECEIVER take
-- the following name formats respectively:
--     "SRC_SCHEMA"."SRC_QUEUE"=>"DST_SCHEMA"."DST_QUEUE"@DST_DB
--     "SRC_SCHEMA"."SRC_QUEUE"@SRC_DB=>"DST_SCHEMA"."DST_QUEUE"
--
-- Since 11,2,  PROPAGATION RECEIVER takes the following name in case
-- of XStream Inbound server, where the SRC_DB name is the source name
-- users provided in the XStreamInAttach call. 
--     "SRC_DB"=>"DST_SCHEMA"."DST_QUEUE"
--
CREATE OR REPLACE VIEW "_DBA_STREAMS_COMPONENT"(
        COMPONENT_NAME,
        COMPONENT_DB,
        COMPONENT_TYPE,
        COMPONENT_PROPERTY,
        COMPONENT_CHANGED_TIME,
        SPARE1, SPARE2, SPARE3, SPARE4)
AS
SELECT v.COMPONENT_NAME,
       v.COMPONENT_DB,
       v.COMPONENT_TYPE,
       v.COMPONENT_PROPERTY,
       v.COMPONENT_CHANGED_TIME,
       0, 0, NULL, to_date(NULL, '')
FROM (
   SELECT caq.COMPONENT_NAME,
          global_name                       as COMPONENT_DB,
          caq.COMPONENT_TYPE,
          caq.COMPONENT_PROPERTY,
          o.mtime                           as COMPONENT_CHANGED_TIME
   FROM (
-- Capture
      SELECT c.capture_name                 as COMPONENT_NAME,
             1                              as COMPONENT_TYPE,
             decode(bitand(c.flags, 64), 64,
-- Downstream 0001; Downstream Hotmining 0101; Downstream Coldmining 1001
                    decode(p.value, 'Y', 5, 'N', 9, null, 0, 1),
-- Local 0010; Local Hotmining 0110; Local Coldmining 1010; Unknown 0000
                    decode(p.value, 'Y', 6, 'N',10, null, 0, 2))
                                            as COMPONENT_PROPERTY,
             'SYS'                          as OBJECT_OWNER,
             c.capture_name                 as OBJECT_NAME
      -- OPTIMIZE: Replace dba_capture with sys.streams$_capture_process
      -- and dba_capture_parameters with sys.streams$_process_params to
      -- optimize query performance.
      FROM sys.streams$_capture_process c, sys.streams$_process_params p
      WHERE p.process_type = 2 AND   -- type 2 indicates capture process
            p.process# = c.capture# AND
      -- For local and downstream capture, 'DOWNSTREAM_REAL_TIME_MINE'
      -- is always populated.
            p.name = 'DOWNSTREAM_REAL_TIME_MINE'
      UNION
-- Apply
      SELECT apply_name                     as COMPONENT_NAME,
             4                              as COMPONENT_TYPE,
             0                              as COMPONENT_PROPERTY,
             'SYS'                          as OBJECT_OWNER,
             apply_name                     as OBJECT_NAME
      -- OPTIMIZE: Replace dba_apply with sys.streams$_apply_process
      FROM sys.streams$_apply_process
      UNION
-- Queue
-- Every queue in 'gv$buffered_queues' is buffered. Otherwise, persistent.
      SELECT ('"'||q.queue_schema||'"."'||q.queue_name||'"')
                                            as COMPONENT_NAME,
             5                              as COMPONENT_TYPE,
             16                             as COMPONENT_PROPERTY,
             q.queue_schema                 as OBJECT_OWNER,
             q.queue_name                   as OBJECT_NAME
      FROM   gv$buffered_queues q
      UNION
      SELECT ('"'||t.schema||'"."'||q.name||'"')
                                            as COMPONENT_NAME,
             5                              as COMPONENT_TYPE,
             32                             as COMPONENT_PROPERTY,
             t.schema                       as OBJECT_OWNER,
             q.name                         as OBJECT_NAME
      FROM   system.aq$_queues q,
             system.aq$_queue_tables t
      WHERE  q.table_objno = t.objno AND
-- Use system.aq$_queues.usage to find 'NORMAL_QUEUE' in dba_queues
             q.usage NOT IN (1, 2) AND
             q.eventid NOT IN (SELECT queue_id FROM gv$buffered_queues)
         ) caq, sys.obj$ o, sys.user$ u, global_name
   -- OPTIMIZE: Replace dba_objects with sys.obj$ and sys.user$
   --           and extract global_name
   WHERE caq.object_owner = u.name AND
         caq.object_name = o.name AND
         o.owner# = u.user# AND
-- namespace values for queue, capture and apply are 10, 37 and 39 respectively
         o.namespace in (10, 37, 39)
   UNION
-- Propagation Sender
-- Using sys.streams$_propagation_process instead of gv$propagation_sender,
-- we can have propagation sender even when dst_database_name is missing in
-- gv$propagation_sender. We can have creation_time as component_changed_time.
   SELECT ('"'||source_queue_schema||'"."'||source_queue||
           '"=>"'||destination_queue_schema||'"."'||destination_queue||
           '"@'||destination_dblink)     as COMPONENT_NAME,
          global_name                    as COMPONENT_DB,
          2                              as COMPONENT_TYPE,
          0                              as COMPONENT_PROPERTY,
-- The creation time of propagation is the last ddl time.
          creation_time                  as COMPONENT_CHANGED_TIME
   FROM sys.streams$_propagation_process, global_name
   UNION
-- Propagation Receiver
-- Using sys.streams$_propagation_process, we can always produce
-- propagation receiver, even when gv$propagation_receiver is missing.
-- NOTE: This streams component is stored on the source database though
-- it physically resides on the destination database.
   SELECT ('"'||source_queue_schema||'"."'||source_queue||
           '"@'||global_name||'=>"'||destination_queue_schema||'"."'||
           destination_queue||'"')       as COMPONENT_NAME,
          destination_dblink             as COMPONENT_DB,
          3                              as COMPONENT_TYPE,
          0                              as COMPONENT_PROPERTY,
          to_date(null, '')              as COMPONENT_CHANGED_TIME
   -- OPTIMIZE: Replace dba_propagation with sys.streams$_propagation_process
   FROM sys.streams$_propagation_process, global_name
   WHERE destination_dblink IS NOT NULL
   UNION
-- Propagation Receiver in case of XStreamIn, using xstream$_server.
-- The component name is formatted as:
--     "SOURCE_NAME"=>"QUEUE_SCHEMA"."QUEUE_NAME"
   SELECT ('"'||xs.cap_src_database||'"=>"'||
           xs.queue_owner||'"."'||xs.queue_name||'"')
                                        as COMPONENT_NAME,
          global_name                   as COMPONENT_DB,
          3                             as COMPONENT_TYPE,
          0                             as COMPONENT_PROPERTY,
          xs.create_date                as COMPONENT_CHANGED_TIME
   FROM xstream$_server xs, global_name
   WHERE xs.flags = 2
   ) v
/


comment on table "_DBA_STREAMS_COMPONENT" is
'DBA Streams Component'
/
comment on column "_DBA_STREAMS_COMPONENT".COMPONENT_NAME is
'Name of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT".COMPONENT_DB is
'Database on which the streams component resides'
/
comment on column "_DBA_STREAMS_COMPONENT".COMPONENT_TYPE is
'Type of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT".COMPONENT_PROPERTY is
'Properties of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT".COMPONENT_CHANGED_TIME is
'Time that the streams component was last changed by a DDL'
/
create or replace public synonym "_DBA_STREAMS_COMPONENT"
  for "_DBA_STREAMS_COMPONENT"
/
grant select on "_DBA_STREAMS_COMPONENT" to select_catalog_role
/

----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT_LINK"
----------------------------------------------------------------------------

CREATE OR REPLACE VIEW "_DBA_STREAMS_COMPONENT_LINK"(
        SOURCE_COMPONENT_NAME,
        SOURCE_COMPONENT_DB,
        SOURCE_COMPONENT_TYPE,
        DEST_COMPONENT_NAME,
        DEST_COMPONENT_DB,
        DEST_COMPONENT_TYPE,
        SPARE1, SPARE2, SPARE3, SPARE4)
AS
SELECT v.SOURCE_COMPONENT_NAME,
       v.SOURCE_COMPONENT_DB,
       v.SOURCE_COMPONENT_TYPE,
       v.DEST_COMPONENT_NAME,
       v.DEST_COMPONENT_DB,
       v.DEST_COMPONENT_TYPE,
       0                        as SPARE1,
       0                        as SPARE2,
       NULL                     as SPARE3,
       to_date(NULL, '')        as SPARE4
FROM (
-- CAPTURE -> QUEUE
   SELECT
     c.capture_name             as SOURCE_COMPONENT_NAME,
     global_name                as SOURCE_COMPONENT_DB,
     1                          as SOURCE_COMPONENT_TYPE,
     ('"'||c.queue_owner||'"."'||c.queue_name||'"')
                                as DEST_COMPONENT_NAME,
     global_name                as DEST_COMPONENT_DB,
     5                          as DEST_COMPONENT_TYPE
   -- OPTIMIZE: Replace dba_capture with sys.streams$_capture_process
   FROM sys.streams$_capture_process c, global_name
   UNION
-- QUEUE -> PROPAGATION SENDER
   SELECT
     ('"'||source_queue_schema||'"."'||source_queue||'"')
                                as SOURCE_COMPONENT_NAME,
     global_name                as SOURCE_COMPONENT_DB,
     5                          as SOURCE_COMPONENT_TYPE,
     ('"'||source_queue_schema||'"."'||source_queue||
      '"=>"'||destination_queue_schema||'"."'||destination_queue||
      '"@'||destination_dblink) as DEST_COMPONENT_NAME,
     global_name                as DEST_COMPONENT_DB,
     2                          as DEST_COMPONENT_TYPE
   FROM sys.streams$_propagation_process, global_name
   UNION
-- PROPAGATION SENDER -> PROPAGATION RECEIVER
   SELECT
     ('"'||source_queue_schema||'"."'||source_queue||
      '"=>"'||destination_queue_schema||'"."'||destination_queue||
      '"@'||destination_dblink) as SOURCE_COMPONENT_NAME,
     global_name                as SOURCE_COMPONENT_DB,
     2                          as SOURCE_COMPONENT_TYPE,
     ('"'||source_queue_schema||'"."'||source_queue||
      '"@'||global_name||'=>"'||destination_queue_schema||'"."'||
      destination_queue||'"')   as DEST_COMPONENT_NAME,
     destination_dblink         as DEST_COMPONENT_DB,
     3                          as DEST_COMPONENT_TYPE
   -- OPTIMIZE: Replace dba_propagation with sys.streams$_propagation_process
   FROM sys.streams$_propagation_process, global_name
   UNION
-- PROPAGATION RECEIVER -> QUEUE
-- NOTE: This link is stored on the source database though it physically
-- resides on the destination database
   SELECT
     ('"'||source_queue_schema||'"."'||source_queue||
      '"@'||global_name||'=>"'||destination_queue_schema||'"."'||
      destination_queue||'"')   as SOURCE_COMPONENT_NAME,
     destination_dblink         as SOURCE_COMPONENT_DB,
     3                          as SOURCE_COMPONENT_TYPE,
     ('"'||destination_queue_schema||'"."'||destination_queue||'"')
                                as DEST_COMPONENT_NAME,
     destination_dblink         as DEST_COMPONENT_DB,
     5                          as DEST_COMPONENT_TYPE
   -- OPTIMIZE: Replace dba_propagation with sys.streams$_propagation_process
   FROM sys.streams$_propagation_process, global_name
   WHERE destination_dblink IS NOT NULL
   UNION
-- PROPAGATION RECEIVER -> QUEUE in case of XStreamIn
-- XStream inbound server is presented as PROPAGATION RECEIVER and we need 
-- to add a link from propagation receiver to queue
   SELECT ('"'||xs.cap_src_database||'"=>"'||
            xs.queue_owner||'"."'||xs.queue_name||'"')
                                     as SOURCE_COMPONENT_NAME,
          global_name                as SOURCE_COMPONENT_DB,
          3                          as SOURCE_COMPONENT_TYPE,
          ('"'||xs.queue_owner||'"."'||xs.queue_name||'"')      
                                     as DEST_COMPONENT_NAME,
          global_name                as DEST_COMPONENT_DB,
          5                          as DEST_COMPONENT_TYPE
   FROM xstream$_server xs, global_name
   WHERE xs.flags = 2
   UNION
-- QUEUE -> APPLY
   SELECT
     ('"'||a.queue_owner||'"."'||a.queue_name||'"')
                                as SOURCE_COMPONENT_NAME,
     global_name                as SOURCE_COMPONENT_DB,
     5                          as SOURCE_COMPONENT_TYPE,
     a.apply_name               as DEST_COMPONENT_NAME,
     global_name                as DEST_COMPONENT_DB,
     4                          as DEST_COMPONENT_TYPE
   -- OPTIMIZE: Replace dba_apply with sys.streams$_apply_process
   FROM sys.streams$_apply_process a, global_name ) v
/

comment on table "_DBA_STREAMS_COMPONENT_LINK" is
'DBA Streams Component Link'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".SOURCE_COMPONENT_NAME is
'Name of the source component'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".SOURCE_COMPONENT_DB is
'Database on which the source component resides'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".SOURCE_COMPONENT_TYPE is
'Type of the source component'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".DEST_COMPONENT_NAME is
'Name of the destination component'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".DEST_COMPONENT_DB is
'Database on which the destination component resides'
/
comment on column "_DBA_STREAMS_COMPONENT_LINK".DEST_COMPONENT_TYPE is
'Type of the destination component'
/
create or replace public synonym "_DBA_STREAMS_COMPONENT_LINK"
  for "_DBA_STREAMS_COMPONENT_LINK"
/
grant select on "_DBA_STREAMS_COMPONENT_LINK" to select_catalog_role
/

----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT_PROP"
----------------------------------------------------------------------------
-- CAPTURE - PROP_NAMEs include SOURCE_DATABASE, OPTIMIZATION_MODE
-- APPLY   - PROP_NAMEs include SOURCE_DATABASE, APPLY_CAPTURED and
--           MESSAGE_DELIVERY_MODE
--
-- This view is useful for (streams topology) path pruning and configuration
-- checking. For example, the SOURCE_DATABASE properties for capture and
-- apply can be matched to speed up streams topology calculation.
--
CREATE OR REPLACE VIEW "_DBA_STREAMS_COMPONENT_PROP"(
        COMPONENT_NAME,
        COMPONENT_DB,
        COMPONENT_TYPE,
        PROP_NAME,
        PROP_VALUE,
        SPARE1, SPARE2, SPARE3, SPARE4)
AS
SELECT  v.COMPONENT_NAME,
        global_name                   as COMPONENT_DB,
        v.COMPONENT_TYPE,
        v.PROP_NAME,
        v.PROP_VALUE,
        0, 0, NULL, to_date(NULL, '')
FROM ( -- Capture property: SOURCE_DATABASE
       SELECT c.capture_name          as COMPONENT_NAME,
              1                       as COMPONENT_TYPE,
              'SOURCE_DATABASE'       as PROP_NAME,
              c.source_dbname         as PROP_VALUE
       -- OPTIMIZE: Replace dba_capture with sys.streams$_capture_process
       FROM sys.streams$_capture_process c
       UNION
       -- CAPTURE property: PARALLELISM
       SELECT c.capture_name          as COMPONENT_NAME,
              1                       as COMPONENT_TYPE,
              'PARALLELISM'           as PROP_NAME,
              p.value                 as PROP_VALUE
       FROM sys.streams$_capture_process c,
            sys.streams$_process_params p
       WHERE c.capture# = p.process# AND
             p.name = 'PARALLELISM' AND
             p.process_type = 2       -- type 2 indicates capture process
       UNION
       -- Capture property: OPTIMIZATION_MODE
       SELECT c.capture_name          as COMPONENT_NAME,
              1                       as COMPONENT_TYPE,
              'OPTIMIZATION_MODE'     as PROP_NAME,
              decode(c.optimization, 1, '1', 2, '2', '0')
                                      as PROP_VALUE
       FROM gv$streams_capture c
       UNION
       -- Apply property: PARALLELISM
       SELECT apply_name                as COMPONENT_NAME, 
              4                         as COMPONENT_TYPE,
              'PARALLELISM'             as PROP_NAME,
              to_char(count(server_id)) as PROP_VALUE 
       FROM  v$streams_apply_server 
       GROUP BY apply_name
       UNION
       -- Apply property: SOURCE_DATABASE
       SELECT ap.apply_name           as COMPONENT_NAME,
              4                       as COMPONENT_TYPE,
              'SOURCE_DATABASE'       as PROP_NAME,
              am.source_db_name       as PROP_VALUE
       -- OPTIMIZE: Replace dba_apply_progress with
       -- sys.streams$_apply_process and sys.streams$_apply_milestone
       FROM sys.streams$_apply_process ap,
            sys.streams$_apply_milestone am
       WHERE ap.apply# = am.apply# (+)
       UNION
       -- Apply property: APPLY_CAPTURED
       SELECT a.apply_name            as COMPONENT_NAME,
              4                       as COMPONENT_TYPE,
              'APPLY_CAPTURED'        as PROP_NAME,
              decode(bitand(a.flags, 1), 1, 'YES', 0, 'NO')
                                      as PROP_VALUE
       -- OPTIMIZE: Replace dba_apply with sys.streams$_apply_process
       FROM sys.streams$_apply_process a
       UNION
       -- Apply property: MESSAGE_DELIVERY_MODE
       SELECT a.apply_name            as COMPONENT_NAME,
              4                       as COMPONENT_TYPE,
              'MESSAGE_DELIVERY_MODE' as PROP_NAME,
              decode(bitand(a.flags, 1), 1, 'CAPTURED',
                     decode(bitand(a.flags, 128),
                            128, 'CAPTURED', 0, 'PERSISTENT'))
                                      as PROP_VALUE
       -- OPTIMIZE: Replace dba_apply with sys.streams$_apply_process
       FROM sys.streams$_apply_process a
     ) v, global_name
/

comment on table "_DBA_STREAMS_COMPONENT_PROP" is
'DBA Streams Component Properties'
/
comment on column "_DBA_STREAMS_COMPONENT_PROP".COMPONENT_NAME is
'Name of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_PROP".COMPONENT_DB is
'Database on which the streams component resides'
/
comment on column "_DBA_STREAMS_COMPONENT_PROP".COMPONENT_TYPE is
'Type of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_PROP".PROP_NAME is
'Name of the property'
/
comment on column "_DBA_STREAMS_COMPONENT_PROP".PROP_VALUE is
'Value of the property'
/
create or replace public synonym "_DBA_STREAMS_COMPONENT_PROP"
  for "_DBA_STREAMS_COMPONENT_PROP"
/
grant select on "_DBA_STREAMS_COMPONENT_PROP" to select_catalog_role
/

----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT_STAT"
-- capture, apply, queue, propagation sender
----------------------------------------------------------------------------
-- STATUS of Streams Component
--    1 aborted
--    2 disabled
--    3 flow control

CREATE OR REPLACE VIEW "_DBA_STREAMS_COMPONENT_STAT"(
        COMPONENT_NAME,
        COMPONENT_DB,
        COMPONENT_TYPE,
        STAT_TIME,
        COUNT1,
        COUNT2,
        COUNT3,
-- COUNT4 is a spare for future extension.
        COUNT4,
        LATENCY,
        STATUS,
        SPARE1, SPARE2, SPARE3, SPARE4)
AS
SELECT v.COMPONENT_NAME,
       global_name COMPONENT_DB,
       v.COMPONENT_TYPE,
       sysdate STAT_TIME,
       v.COUNT1,
       v.COUNT2,
       v.COUNT3,
       0 COUNT4,
       v.LATENCY,
decode(v.STATUS, 'ENABLED',      0,
                 'ABORTED',      1,
                 'DISABLED',     2,
                 'FLOW CONTROL', 3,
                 'VALID',        0,
                 'INVALID',      1,
                 'N/A',          2, 0),
       0, 0, NULL, to_date(NULL, '')
FROM global_name,
 ( -- CAPTURE
   SELECT
     c.capture_name                       as COMPONENT_NAME,
     1                                    as COMPONENT_TYPE,
     -- COUNT1: TOTAL MESSAGES CAPTURED
     nvl(vcap.total_messages_captured, 0) as COUNT1,
     -- COUNT2: TOTAL MESSAGES ENQUEUED
     nvl(vcap.total_messages_enqueued, 0) as COUNT2,
     -- COUNT3: TOTAL BYTES SENT
     nvl(vcap.bytessent, 0)               as COUNT3,
     -- LATENCY: SECONDS
     nvl((vcap.AVAILABLE_MESSAGE_CREATE_TIME-vcap.CAPTURE_MESSAGE_CREATE_TIME)
         * 86400, -1)                     as LATENCY,
     CASE WHEN (vcap.state = 'PAUSED FOR FLOW CONTROL')
          THEN 'FLOW CONTROL'
          ELSE decode(c.status, 1, 'DISABLED',
                                2, 'ENABLED',
                                4, 'ABORTED', 'UNKNOWN')
     END                                  as STATUS
   -- OPTIMIZE: Replace dba_capture with sys.streams$_capture_process
   FROM sys.streams$_capture_process c,
      ( SELECT cap.capture_name,
               cap.total_messages_captured,
               cap.total_messages_enqueued,
               cap.available_message_create_time,
               cap.capture_message_create_time,
               cap.state,
               sess.value as bytessent
        FROM gv$streams_capture cap, gv$statname stat, gv$sesstat sess
        WHERE cap.sid = sess.sid AND sess.statistic# = stat.statistic# AND
              stat.name = 'bytes sent via SQL*Net to dblink') vcap
   WHERE c.capture_name = vcap.capture_name (+)
   UNION
   -- APPLY
   SELECT a.apply_name                    as COMPONENT_NAME,
          4                               as COMPONENT_TYPE,
          -- COUNT1: TOTAL MESSAGES APPLIED
          nvl(aps.COUNT1, 0)              as COUNT1,
          -- COUNT2: TOTAL TRANSACTIONS APPLIED
          nvl(apc.total_applied, 0)       as COUNT2,
          0                               as COUNT3,
          -- LATENCY: SECONDS
          CASE WHEN aps.state != 'IDLE' THEN
                 nvl((aps.apply_time - aps.create_time)*86400, -1)
               WHEN apc.state != 'IDLE' THEN
                 nvl((apc.apply_time - apc.create_time)*86400, -1)
               WHEN apr.state != 'IDLE' THEN
                 nvl((apr.apply_time - apr.create_time)*86400, -1)
               ELSE 0
          END                             as LATENCY,
          decode(a.status, 1, 'DISABLED',
                           2, 'ENABLED',
                           4, 'ABORTED', 'UNKNOWN')
                                          as STATUS
   -- OPTIMIZE: Replace dba_apply with sys.streams$_apply_process
   -- Calculate apply latency in order of SERVER, COORDINATOR, READER
   FROM sys.streams$_apply_process a,
        ( SELECT apply_name,
                 state,
                 apply_time,
                 max_create_time as create_time,
                 count1
          FROM ( SELECT apply_name,
                        state,
                        apply_time,
                        applied_message_create_time,
                        MAX(applied_message_create_time)
                          OVER (PARTITION BY apply_name)
                          as max_create_time,
                        SUM(total_messages_applied)
                          OVER (PARTITION BY apply_name)
                          as count1
                 FROM gv$streams_apply_server) 
                 -- There may be many apply slaves, pick the first one for
                 -- apply_time, apply_message_create_time
          WHERE ROWNUM <= 1) aps,
        ( SELECT c.apply_name,
                 state,
                 -- If XOut use hwm_time else use lwm_time
                 CASE WHEN (bitand(p.flags, 256)) = 256
                      THEN c.hwm_time 
                      ELSE c.lwm_time           
                 END                          as apply_time,
                 CASE WHEN (bitand(p.flags, 256)) = 256
                      THEN hwm_message_create_time
                      ELSE lwm_message_create_time           
                 END                          as create_time,
                 total_applied
          FROM gv$streams_apply_coordinator c, 
               sys.streams$_apply_process p 
          WHERE p.apply_name = c.apply_name) apc,
        ( SELECT apply_name,
                 state,
                 dequeue_time                 as apply_time,
                 dequeued_message_create_time as create_time
          FROM gv$streams_apply_reader ) apr
   WHERE a.apply_name = apc.apply_name (+) AND
         apc.apply_name = apr.apply_name (+) AND
         apr.apply_name = aps.apply_name (+)
   UNION
   -- QUEUE
   SELECT ('"'||q.queue_schema||'"."'||q.queue_name||'"')
                                          as COMPONENT_NAME,
          5                               as COMPONENT_TYPE,
          -- COUNT1: CUMULATIVE MESSAGES ENQUEUED
          q.cnum_msgs                     as COUNT1,
          -- COUNT2: CUMULATIVE MESSAGES SPILLED
          q.cspill_msgs                   as COUNT2,
          -- COUNT3: CURRENT QUEUE SIZE
          q.num_msgs                      as COUNT3,
          0                               as LATENCY,
          decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
                                          as STATUS
   -- OPTIMIZE: Replace dba_objects with sys.obj$ and sys.user$
   FROM gv$buffered_queues q, sys.obj$ o, sys.user$ u
   WHERE q.queue_schema = u.name AND
         q.queue_id = o.obj# AND
         o.owner# = u.user#
   UNION
   -- PROPAGATION SENDER
   SELECT ('"'||ps.queue_schema||'"."'||ps.queue_name||'"=>'||
           CASE WHEN ps.dblink IS NOT NULL AND
                     (ps.dst_queue_schema IS NULL OR ps.dst_queue_name IS NULL)
                THEN ps.dblink
                ELSE ('"'||ps.dst_queue_schema||'"."'||ps.dst_queue_name||
                      '"@'||ps.dst_database_name)
           END)                           as COMPONENT_NAME,
          2                               as COMPONENT_TYPE,
          -- COUNT1: TOTAL MESSAGES SENT
          ps.total_msgs                   as COUNT1,
          -- COUNT1: TOTAL BYTES SENT
          ps.total_bytes                  as COUNT2,
          0                               as COUNT3,
          -- LATENCY: SECONDS
          ps.last_lcr_latency             as LATENCY,
          CASE WHEN (regexp_instr(s.last_error_msg,
                    '.*flow control.*', 1, 1, 0, 'i') > 0)
               -- ORA-25307: Enqueue rate too high, flow control enabled
               -- Subscribers could not keep pace with the enqueue rate,
               -- propagation is in flow control
                    THEN 'FLOW CONTROL'
               WHEN (ps.schedule_status = 'SCHEDULE DISABLED')
                    THEN 'DISABLED'
               WHEN (ps.schedule_status = 'PROPAGATION UNSCHEDULED')
                    THEN 'ABORTED'
               WHEN (j.enabled != 'TRUE' AND j.retry_count >= 16)
                 -- (dqs.schedule_disabled = 'Y' AND dqs.failures >= 16)
                    THEN 'ABORTED'
               ELSE ps.schedule_status
          END                             as STATUS
   FROM gv$propagation_sender ps,
        -- OPTIMIZE: Replace DBA_QUEUE_SCHEDULES dqs with base tables q, s, j
        system.aq$_queues q, sys.aq$_schedules s, sys.dba_scheduler_jobs j
   WHERE ps.dst_database_name IS NOT NULL AND
         ps.queue_id = q.eventid AND ps.queue_name = q.name AND
         q.oid = s.oid (+) AND s.job_name = j.job_name (+) ) v
/

comment on table "_DBA_STREAMS_COMPONENT_STAT" is
'DBA Streams Component Statistics'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COMPONENT_NAME is
'Name of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COMPONENT_DB is
'Database on which the streams component resides'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COMPONENT_TYPE is
'Type of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".STAT_TIME is
'Time that statistics were taken'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COUNT1 is
'First count, dependent on the type of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COUNT2 is
'Second count, dependent on the type of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COUNT3 is
'Third count, dependent on the type of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".COUNT4 is
'Fourth count, dependent on the type of the component (Spare Column)'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".LATENCY is
'Latency of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_STAT".STATUS is
'Status of the component'
/
create or replace public synonym "_DBA_STREAMS_COMPONENT_STAT"
  for "_DBA_STREAMS_COMPONENT_STAT"
/
grant select on "_DBA_STREAMS_COMPONENT_STAT" to select_catalog_role
/

----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT_EVENT"
-- capture, apply, propagation sender, propagation receiver
----------------------------------------------------------------------------
-- "_DBA_STREAMS_COMPONENT_EVENT" contains only session information.
--
-- The 11gR1 supports only the following SUB_COMPONENT_TYPE(s):
-- CAPTURE SUB_COMPONENT_TYPE:
--   11  LOGMINER READER
--   12  LOGMINER PREPARER
--   13  LOGMINER BUILDER
--   14  CAPTURE SESSION
--
-- APPLY SUB_COMPONENT_TYPE:
--   41  PROPAGATION SENDER+RECEIVER (LOCAL CCAC)
--   42  APPLY READER
--   43  APPLY COORDINATOR
--   44  APPLY SERVER
--
-- Since patch release 11.1.0.7, APPLY NETWORK RECEIVER is changed to
-- PROPAGATION SENDER+RECEIVER. This subcomponent will only show up for
-- CAPTURE SERVER in local CCAC. See the following for all combinations:
--
-- ----------------------         -------------------------
-- LOCAL CCA                      REMOTE CCA
-- ----------------------         -------------------------
-- CAPTURE                        CAPTURE
--   LOGMINER READER                LOGMINER READER 
--   LOGMINER PREPARER              LOGMINER PREPARER
--   LOGMINER BUILDER               LOGMINER BUILDER
--   CAPTURE SESSION                CAPTURE SESSION
--
--                                PROPGATION SENDER (CAPTURE SESSION)
--                                PROPAGATION RECEIVER (APPLY NETWORK RECEIVER)
--
-- APPLY                          APPLY
--   APPLY READER                   APPLY READER
--   APPLY COORDINATOR              APPLY COORDINATOR
--   APPLY SERVER                   APPLY SERVER
--
-- ----------------------         -------------------------
-- LOCAL CCAC                     REMOTE CCAC
-- ----------------------         -------------------------
-- CAPTURE                        CAPTURE
--   LOGMINER READER                LOGMINER READER 
--   LOGMINER PREPARER              LOGMINER PREPARER
--   LOGMINER BUILDER               LOGMINER BUILDER
--   CAPTURE SESSION                CAPTURE SESSION
--
--                                PROPGATION SENDER (CAPTURE SERVER)
--                                PROPAGATION RECEIVER (APPLY NETWORK RECEIVER)
--
-- APPLY                          APPLY
--   PROPAGATION SENDER+RECEIVER
--   APPLY READER                   APPLY READER
--   APPLY COORDINATOR              APPLY COORDINATOR
--   APPLY SERVER                   APPLY SERVER
--
--
-- In case of XStreamIn there will be two components:
--
-- PROPAGATION RECEIVER (XStream Inbound Server)
--
-- APPLY          
--   APPLY READER 
--   APPLY COORDINATOR
--   APPLY SERVER     
--
--
-- The numbering of SUB_COMPONENT_TYPE indicates the relative position of
-- sub-components within top_level components. 
--
CREATE OR REPLACE VIEW "_DBA_STREAMS_COMPONENT_EVENT"(
        COMPONENT_NAME,
        COMPONENT_DB,
        COMPONENT_TYPE,
        SUB_COMPONENT_TYPE,
        STAT_TIME,
        SESSION_ID,
        SESSION_SERIAL#,
        EVENT,
        EVENT_COUNT,
        TOTAL_COUNT,
        MODULE_NAME,
        ACTION_NAME,
        SPARE1, SPARE2, SPARE3, SPARE4)
AS
SELECT C.COMPONENT_NAME,
       global_name AS COMPONENT_DB,
       C.COMPONENT_TYPE,
       C.SUB_COMPONENT_TYPE,
       sysdate AS STAT_TIME,
       C.SESSION_ID,
       C.SESSION_SERIAL#,
       V.EVENT,
       0 AS EVENT_COUNT,
       0 AS TOTAL_COUNT,
       SUBSTRB(V.MODULE_NAME,1,
             (SELECT KSUMODLEN FROM X$MODACT_LENGTH)) MODULE_NAME,
       SUBSTRB(V.ACTION_NAME,1,
             (SELECT KSUACTLEN FROM X$MODACT_LENGTH)) ACTION_NAME,
       0, 0, STATE, to_date(NULL, '')
FROM global_name,
 ( -- CAPTURE
   SELECT capture_name AS COMPONENT_NAME,
          1            AS COMPONENT_TYPE,
          14           AS sub_component_type,
          sid          AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$streams_capture
   UNION
   SELECT capture_name AS COMPONENT_NAME,
          1            AS COMPONENT_TYPE,
          decode(l.role,
            'reader',  11,
            'preparer',12,
            'builder', 13,
            14)        AS sub_component_type,
          l.sid        AS SESSION_ID,
          l.serial#    AS SESSION_SERIAL#,
          NULL         AS STATE
   FROM gv$streams_capture c, gv$logmnr_process l
   WHERE c.logminer_id = l.session_id
     -- Don't want row for capture process since state is NULL
     AND l.role in ('reader', 'preparer', 'builder')
   UNION
   -- APPLY SERVER, non-XStreamOut case
   SELECT apply_name   AS COMPONENT_NAME,
          4            AS COMPONENT_TYPE,
          44           AS SUB_COMPONENT_TYPE,
          sid          AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$streams_apply_server
   WHERE apply_name NOT IN 
         (SELECT apply_name FROM dba_apply WHERE UPPER(purpose)= 'XSTREAM OUT')
   UNION
   -- APPLY SERVER, XStreamOut case
   -- In case of XStreamOut, only includes the XStream Outbound Server
   SELECT sas.apply_name   AS COMPONENT_NAME,
          4                AS COMPONENT_TYPE,
          44               AS SUB_COMPONENT_TYPE,
          sas.sid          AS SESSION_ID,
          sas.serial#      AS SESSION_SERIAL#,
          sas.state        AS STATE
   FROM gv$streams_apply_server sas, dba_apply da
   WHERE sas.server_id = 2 AND
         sas.apply_name = da.apply_name AND
         UPPER(da.purpose) = 'XSTREAM OUT'
   UNION
   -- APPLY COORDINATOR
   SELECT apply_name   AS COMPONENT_NAME,
          4            AS COMPONENT_TYPE,
          43           AS SUB_COMPONENT_TYPE,
          sid          AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$streams_apply_coordinator
   UNION
   -- APPLY READER
   SELECT apply_name   AS COMPONENT_NAME,
          4            AS COMPONENT_TYPE,
          42           AS SUB_COMPONENT_TYPE,
          sid          AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$streams_apply_reader
   UNION
   -- PROPAGATION SENDER+RECEIVER
   -- In case of XStreamIn, we will populate the XStream inbound server as 
   -- PROPAGATION RECEIVER, so do not show it as PROPAGATION SENDER+RECEIVER
   SELECT apply_name   AS COMPONENT_NAME,
          4            AS COMPONENT_TYPE,
          41           AS SUB_COMPONENT_TYPE,
          proxy_sid    AS SESSION_ID,
          proxy_serial AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$streams_apply_reader 
   WHERE proxy_sid > 0 AND
         ((proxy_sid, proxy_serial) NOT IN
          (SELECT sid, serial# FROM gv$streams_capture)) AND  
         (apply_name NOT IN
          (SELECT apply_name FROM dba_apply WHERE UPPER(purpose)='XSTREAM IN'))
   UNION
   -- PROPAGATION SENDER
   SELECT ('"'||queue_schema||'"."'||queue_name||'"=>'||
           CASE WHEN dblink IS NOT NULL AND
                     (dst_queue_schema IS NULL OR dst_queue_name IS NULL)
                THEN dblink
                ELSE ('"'||dst_queue_schema||'"."'||dst_queue_name||
                      '"@'||dst_database_name)
           END)        AS COMPONENT_NAME,
          2            AS COMPONENT_TYPE,
          NULL         AS SUB_COMPONENT_TYPE,
          session_id   AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$propagation_sender
   UNION
   -- PROPAGATION RECEIVER, exclude the case for XStreamIn where src_queue_schema
   -- and src_queue_name are NULL. Also exclude local anr for backward 
   -- compatibility. A propagation receiver is considered local anr if source 
   -- and destination queues are the same and the source db is the same as
   -- the local db.
   SELECT ('"'||src_queue_schema||'"."'||src_queue_name||
           '"@'||src_dbname||'=>"'||
           dst_queue_schema||'"."'||dst_queue_name||'"')
                       AS COMPONENT_NAME,
          3            AS COMPONENT_TYPE,
          NULL         AS SUB_COMPONENT_TYPE,
          session_id   AS SESSION_ID,
          serial#      AS SESSION_SERIAL#,
          state        AS STATE
   FROM gv$propagation_receiver P
   WHERE src_queue_schema IS NOT NULL AND
         src_queue_name IS NOT NULL AND
         NOT ((P.SRC_QUEUE_SCHEMA = P.DST_QUEUE_SCHEMA) and 
              (P.SRC_QUEUE_NAME = P.DST_QUEUE_NAME) and 
              (P.SRC_DBNAME = (SELECT GLOBAL_NAME FROM GLOBAL_NAME)))
   UNION
   -- PROPAGATION RECEIVER in case of XStreamIn, we will populate the 
   -- XStream inbound server as PROPAGATION RECEIVER
   -- Note: in gv$propagation receiver, there is no source queue name and 
   -- queue owner, the src_dbname is populated with the XStreamIn source
   -- name, thus the src_dbname in gv$propagation receiver should be the same 
   -- as the cap_src_database in xstream$_server table. 
   SELECT ('"'||pr.src_dbname||'"=>"'||
           pr.dst_queue_schema||'"."'||pr.dst_queue_name||'"')
                       AS COMPONENT_NAME,
          3            AS COMPONENT_TYPE,
          NULL         AS SUB_COMPONENT_TYPE,
          pr.session_id   AS SESSION_ID,
          pr.serial#      AS SESSION_SERIAL#,
          pr.state        AS STATE
   FROM gv$propagation_receiver pr, xstream$_server xs
   WHERE  pr.src_dbname = xs.cap_src_database AND
          NOT ((pr.SRC_QUEUE_SCHEMA = pr.DST_QUEUE_SCHEMA) and 
               (pr.SRC_QUEUE_NAME = pr.DST_QUEUE_NAME) and 
               (pr.SRC_DBNAME = (SELECT GLOBAL_NAME FROM GLOBAL_NAME)))
   ) C,
   -- Need to get proper size for EVENT, MODULE_NAME, ACTION_NAME
 ( SELECT NULL               AS COMPONENT_NAME,
          LPAD(' ', 64, ' ') AS EVENT,
          LPAD(' ', 64, ' ') AS MODULE_NAME,
          LPAD(' ', 64, ' ') AS ACTION_NAME
   FROM DUAL) V
WHERE C.SESSION_ID IS NOT NULL AND
      C.SESSION_SERIAL# IS NOT NULL AND
      C.COMPONENT_NAME = V.COMPONENT_NAME (+)
/

comment on table "_DBA_STREAMS_COMPONENT_EVENT" is
'DBA Streams Component Event'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".COMPONENT_NAME is
'Name of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".COMPONENT_DB is
'Database on which the streams component resides'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".COMPONENT_TYPE is
'Type of the streams component'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".STAT_TIME is
'Time that statistics were taken'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".SESSION_ID is
'Session ID of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".SESSION_SERIAL# is
'Session serial number of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".EVENT is
'Description of the event of the component'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".EVENT_COUNT is
'The number of times that this event has appeared so far'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".TOTAL_COUNT is
'The total number of events'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".MODULE_NAME is
'Name of the module where the event occurs'
/
comment on column "_DBA_STREAMS_COMPONENT_EVENT".ACTION_NAME is
'Name of the action where the event occurs'
/
create or replace public synonym "_DBA_STREAMS_COMPONENT_EVENT"
  for "_DBA_STREAMS_COMPONENT_EVENT"
/
grant select on "_DBA_STREAMS_COMPONENT_EVENT" to select_catalog_role
/

----------------------------------------------------------------------------
-- Create views that contain per-database information needed
-- by three advisors: Configuration, Performance and Error.
----------------------------------------------------------------------------

-- Todo: ADVISOR_TYPE needs to be decoded properly
CREATE OR REPLACE VIEW "_DBA_STREAMS_FINDINGS"(
        MESSAGE_ID,
        MESSAGE_ARG1,
        MESSAGE_ARG2,
        MESSAGE_ARG3,
        MESSAGE_ARG4,
        MESSAGE_ARG5,
        TYPE,
        MORE_INFO_ID,
        INFO_ARG1,
        INFO_ARG2,
        INFO_ARG3,
        INFO_ARG4,
        INFO_ARG5,
        ADVISOR_TYPE,
        RUN_TIME)
AS
SELECT f.msg_id MESSAGE_ID,
       m.p1 MESSAGE_ARG1,
       m.p2 MESSAGE_ARG2,
       m.p3 MESSAGE_ARG3,
       m.p4 MESSAGE_ARG4,
       m.p5 MESSAGE_ARG5,
       f.type,
       f.more_info_id,
       i.p1 INFO_ARG1,
       i.p2 INFO_ARG2,
       i.p3 INFO_ARG3,
       i.p4 INFO_ARG4,
       i.p5 INFO_ARG5,
       t.advisor_name ADVISOR_TYPE,
       sysdate RUN_TIME
FROM wri$_adv_tasks t,
     wri$_adv_findings f,
     wri$_adv_message_groups m,
     wri$_adv_message_groups i
WHERE f.task_id = t.id AND
      -- wri$_adv_tasks.property 0x04 -> Task
      bitand(t.property,4) = 4 AND
      f.task_id = m.task_id AND f.msg_id = m.id AND
      f.task_id = i.task_id AND f.more_info_id = i.id
/

comment on table "_DBA_STREAMS_FINDINGS" is
'DBA Streams Findings'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ID is
'ID of the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ARG1 is
'Argument 1 to the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ARG2 is
'Argument 2 to the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ARG3 is
'Argument 3 to the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ARG4 is
'Argument 4 to the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".MESSAGE_ARG5 is
'Argument 5 to the finding message'
/
comment on column "_DBA_STREAMS_FINDINGS".TYPE is
'Type of the finding'
/
comment on column "_DBA_STREAMS_FINDINGS".MORE_INFO_ID is
'ID for more information related to the finding'
/
comment on column "_DBA_STREAMS_FINDINGS".INFO_ARG1 is
'Argument 1 to the finding more info'
/
comment on column "_DBA_STREAMS_FINDINGS".INFO_ARG2 is
'Argument 2 to the finding more info'
/
comment on column "_DBA_STREAMS_FINDINGS".INFO_ARG3 is
'Argument 3 to the finding more info'
/
comment on column "_DBA_STREAMS_FINDINGS".INFO_ARG4 is
'Argument 4 to the finding more info'
/
comment on column "_DBA_STREAMS_FINDINGS".INFO_ARG5 is
'Argument 5 to the finding more info'
/
comment on column "_DBA_STREAMS_FINDINGS".ADVISOR_TYPE is
'Type of the advisor (PERFORMANCE, CONFIGURATION, ERROR)'
/
comment on column "_DBA_STREAMS_FINDINGS".RUN_TIME is
'Time that the advisor was run'
/
create or replace public synonym "_DBA_STREAMS_FINDINGS"
  for "_DBA_STREAMS_FINDINGS"
/
grant select on "_DBA_STREAMS_FINDINGS" to select_catalog_role
/

-- Todo: ADVISOR_TYPE needs to be decoded properly
CREATE OR REPLACE VIEW "_DBA_STREAMS_RECOMMENDATIONS"(
    BENEFIT_ID,
    BENEFIT_ARG1,
    BENEFIT_ARG2,
    BENEFIT_ARG3,
    BENEFIT_ARG4,
    BENEFIT_ARG5,
    ADVISOR_TYPE,
    RUN_TIME)
AS
SELECT r.benefit_msg_id BENEFIT_ID,
       m.p1 BENEFIT_ARG1,
       m.p2 BENEFIT_ARG2,
       m.p3 BENEFIT_ARG3,
       m.p4 BENEFIT_ARG4,
       m.p5 BENEFIT_ARG5,
       t.advisor_name ADVISOR_TYPE,
       sysdate RUN_TIME
FROM wri$_adv_recommendations r, wri$_adv_tasks t,
     wri$_adv_message_groups m
WHERE r.task_id = t.id
  AND r.task_id = m.task_id
  AND r.benefit_msg_id = m.id
  -- wri$_adv_tasks.property 0x04 -> Task
  AND bitand(t.property,4) = 4
/

comment on table "_DBA_STREAMS_RECOMMENDATIONS" is
'DBA Streams Recommendations'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ID is
'ID of the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ARG1 is
'Argument 1 to the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ARG2 is
'Argument 2 to the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ARG3 is
'Argument 3 to the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ARG4 is
'Argument 4 to the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".BENEFIT_ARG5 is
'Argument 5 to the recommendation benefit'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".ADVISOR_TYPE is
'Type of the advisor (PERFORMANCE, CONFIGURATION, ERROR)'
/
comment on column "_DBA_STREAMS_RECOMMENDATIONS".RUN_TIME is
'Time that the advisor was run'
/
create or replace public synonym "_DBA_STREAMS_RECOMMENDATIONS"
  for "_DBA_STREAMS_RECOMMENDATIONS"
/
grant select on "_DBA_STREAMS_RECOMMENDATIONS" to select_catalog_role
/

-- Todo: ADVISOR_TYPE needs to be decoded properly
CREATE OR REPLACE VIEW "_DBA_STREAMS_ACTIONS"(
    MESSAGE_ID,
    MESSAGE_ARG1,
    MESSAGE_ARG2,
    MESSAGE_ARG3,
    MESSAGE_ARG4,
    MESSAGE_ARG5,
    COMMAND,
    COMMAND_ID,
    FLAGS,
    ATTR1,
    ATTR2,
    ATTR3,
    ATTR4,
    ATTR5,
    ATTR6,
    NUM_ATTR1,
    NUM_ATTR2,
    NUM_ATTR3,
    NUM_ATTR4,
    NUM_ATTR5,
    ADVISOR_TYPE,
    RUN_TIME)
AS
SELECT a.msg_id as MESSAGE_ID,
       m.p1 as MESSAGE_ARG1,
       m.p2 as MESSAGE_ARG2,
       m.p3 as MESSAGE_ARG3,
       m.p4 as MESSAGE_ARG4,
       m.p5 as MESSAGE_ARG5,
       c.command_name as COMMAND,
       a.command as COMMAND_ID,
       a.flags as FLAGS,
       a.attr1 as ATTR1,
       a.attr2 as ATTR2,
       a.attr3 as ATTR3,
       a.attr4 as ATTR4,
       a.attr5 as ATTR5,
       a.attr6 as ATTR6,
       a.num_attr1 as NUM_ATTR1,
       a.num_attr2 as NUM_ATTR2,
       a.num_attr3 as NUM_ATTR3,
       a.num_attr4 as NUM_ATTR4,
       a.num_attr5 as NUM_ATTR5,
       t.advisor_name as ADVISOR_TYPE,
       sysdate as RUN_TIME
FROM wri$_adv_actions a, wri$_adv_tasks t, x$keacmdn c,
     wri$_adv_message_groups m
WHERE a.task_id = t.id
  AND a.command = c.indx
  -- wri$_adv_tasks.property 0x04 -> Task
  AND bitand(t.property,4) = 4
  AND a.task_id = m.task_id
  AND a.msg_id = m.id
/

comment on table "_DBA_STREAMS_ACTIONS" is
'DBA Streams Actions'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ID is
'ID of the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ARG1 is
'Argument 1 to the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ARG2 is
'Argument 2 to the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ARG3 is
'Argument 3 to the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ARG4 is
'Argument 4 to the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".MESSAGE_ARG5 is
'Argument 5 to the action message'
/
comment on column "_DBA_STREAMS_ACTIONS".COMMAND is
'Command to run to execute the action'
/
comment on column "_DBA_STREAMS_ACTIONS".COMMAND_ID is
'ID of the command to run'
/
comment on column "_DBA_STREAMS_ACTIONS".FLAGS is
'Flags associated with the action'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR1 is
'Attribute 1'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR2 is
'Attribute 2'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR3 is
'Attribute 3'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR4 is
'Attribute 4'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR5 is
'Attribute 5'
/
comment on column "_DBA_STREAMS_ACTIONS".ATTR6 is
'Attribute 6'
/
comment on column "_DBA_STREAMS_ACTIONS".NUM_ATTR1 is
'Attribute 1 in number format'
/
comment on column "_DBA_STREAMS_ACTIONS".NUM_ATTR2 is
'Attribute 2 in number format'
/
comment on column "_DBA_STREAMS_ACTIONS".NUM_ATTR3 is
'Attribute 3 in number format'
/
comment on column "_DBA_STREAMS_ACTIONS".NUM_ATTR4 is
'Attribute 4 in number format'
/
comment on column "_DBA_STREAMS_ACTIONS".NUM_ATTR5 is
'Attribute 5 in number format'
/
comment on column "_DBA_STREAMS_ACTIONS".ADVISOR_TYPE is
'Type of the advisor (PERFORMANCE, CONFIGURATION, ERROR)'
/
comment on column "_DBA_STREAMS_ACTIONS".RUN_TIME is
'Time that the advisor was run'
/
create or replace public synonym "_DBA_STREAMS_ACTIONS"
  for "_DBA_STREAMS_ACTIONS"
/
grant select on "_DBA_STREAMS_ACTIONS" to select_catalog_role
/

----------------------------------------------------------------------------
-- Streams topoloy/statistics/bottleneck views 
----------------------------------------------------------------------------
--
--   DBA_STREAMS_TP_DATABASE
--   DBA_STREAMS_TP_COMPONENT
--   DBA_STREAMS_TP_COMPONENT_LINK
--   "_DBA_STREAMS_TP_COMPONENT_PROP"
--   DBA_STREAMS_TP_COMPONENT_STAT
--   DBA_STREAMS_TP_PATH_STAT
--   DBA_STREAMS_TP_PATH_BOTTLENECK
--

-- Create public DBA Streams Database view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_DATABASE(
    GLOBAL_NAME,
    LAST_QUERIED,
    VERSION,
    COMPATIBILITY,
    MANAGEMENT_PACK_ACCESS)
AS
SELECT global_name,
       last_queried,
       version,
       compatibility,
       management_pack_access
FROM streams$_database
/

comment on table DBA_STREAMS_TP_DATABASE is
'DBA Streams Database'
/
comment on column DBA_STREAMS_TP_DATABASE.GLOBAL_NAME is
'Global Name of the Streams Database'
/
comment on column DBA_STREAMS_TP_DATABASE.LAST_QUERIED is
'Time the Streams Database Was Last Queried'
/
comment on column DBA_STREAMS_TP_DATABASE.VERSION is
'Database Version of the Streams Database'
/
comment on column DBA_STREAMS_TP_DATABASE.COMPATIBILITY is
'Compatible Setting of the Streams Database'
/
comment on column DBA_STREAMS_TP_DATABASE.MANAGEMENT_PACK_ACCESS is
'Management Pack Access of the Streams Database'
/
create or replace public synonym DBA_STREAMS_TP_DATABASE
  for DBA_STREAMS_TP_DATABASE
/
grant select on DBA_STREAMS_TP_DATABASE to select_catalog_role
/

-- Create public DBA Streams Component view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_COMPONENT(
    COMPONENT_ID,
    COMPONENT_NAME,
    COMPONENT_DB,
    COMPONENT_TYPE,
    COMPONENT_CHANGED_TIME)
AS
SELECT COMPONENT_ID,
       nvl(COMPONENT_NAME, SPARE3) COMPONENT_NAME,
       COMPONENT_DB,
       decode(COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL) COMPONENT_TYPE,
       COMPONENT_CHANGED_TIME
FROM streams$_component
/

comment on table DBA_STREAMS_TP_COMPONENT is
'DBA Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT.COMPONENT_ID is
'ID of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT.COMPONENT_NAME is
'Name of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT.COMPONENT_DB is
'Database Where the Streams Component Resides'
/
comment on column DBA_STREAMS_TP_COMPONENT.COMPONENT_TYPE is
'Type of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT.COMPONENT_CHANGED_TIME is
'Time That the Component Was Last Changed by a DDL'
/
create or replace public synonym DBA_STREAMS_TP_COMPONENT
  for DBA_STREAMS_TP_COMPONENT
/
grant select on DBA_STREAMS_TP_COMPONENT to select_catalog_role
/

-- Create DBA Streams Component Link (Streams Topology Links) view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_COMPONENT_LINK(
    SOURCE_COMPONENT_ID,
    SOURCE_COMPONENT_NAME,
    SOURCE_COMPONENT_DB,
    SOURCE_COMPONENT_TYPE,
    DESTINATION_COMPONENT_ID,
    DESTINATION_COMPONENT_NAME,
    DESTINATION_COMPONENT_DB,
    DESTINATION_COMPONENT_TYPE,
    PATH_ID,
    POSITION)
AS
SELECT L.SOURCE_COMPONENT_ID,
       nvl(S.COMPONENT_NAME, S.SPARE3) COMPONENT_NAME,
       S.COMPONENT_DB,
       decode(S.COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL),
       L.DEST_COMPONENT_ID,
       nvl(D.COMPONENT_NAME, D.SPARE3) COMPONENT_NAME,
       D.COMPONENT_DB,
       decode(D.COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL),
       L.PATH_ID,
       L.POSITION
FROM streams$_component S,
     streams$_component D,
     streams$_component_link L
WHERE L.SOURCE_COMPONENT_ID = S.COMPONENT_ID AND
      L.DEST_COMPONENT_ID = D.COMPONENT_ID AND
   -- Display active stream paths only
   -- '00000001' is ACTIVE_PATH_FLAG defined by dbms_streams_adv_adm_utl
      utl_raw.bit_and(L.PATH_FLAG, '00000001') = '00000001'
/

comment on table DBA_STREAMS_TP_COMPONENT_LINK is
'DBA Streams Component Link (Streams Topology Links)'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.SOURCE_COMPONENT_ID is
'ID of the Source Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.SOURCE_COMPONENT_NAME is
'Name of the Source Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.SOURCE_COMPONENT_DB is
'Database Where the Source Streams Component Resides'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.SOURCE_COMPONENT_TYPE is
'Type of the Source Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.DESTINATION_COMPONENT_ID is
'ID of the Destination Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.DESTINATION_COMPONENT_NAME is
'Name of the Destination Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.DESTINATION_COMPONENT_DB is
'Database Where the Destination Streams Component Resides'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.DESTINATION_COMPONENT_TYPE is
'Type of the Destination Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.PATH_ID is
'ID of the Stream Path'
/
comment on column DBA_STREAMS_TP_COMPONENT_LINK.POSITION is
'Position of the Link within the Stream Path'
/
create or replace public synonym DBA_STREAMS_TP_COMPONENT_LINK
  for DBA_STREAMS_TP_COMPONENT_LINK
/
grant select on DBA_STREAMS_TP_COMPONENT_LINK to select_catalog_role
/

-- Create DBA Streams Component Property view
CREATE OR REPLACE VIEW "_DBA_STREAMS_TP_COMPONENT_PROP"(
    COMPONENT_ID,
    COMPONENT_NAME,
    COMPONENT_DB,
    COMPONENT_TYPE,
    PROP_NAME,
    PROP_VALUE)
AS
SELECT C.COMPONENT_ID,
       nvl(C.COMPONENT_NAME, C.SPARE3) COMPONENT_NAME,
       C.COMPONENT_DB,
       decode(C.COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL),
       P.PROP_NAME,
       P.PROP_VALUE
FROM streams$_component C,
     streams$_component_prop P
WHERE C.COMPONENT_ID = P.COMPONENT_ID
/

comment on table "_DBA_STREAMS_TP_COMPONENT_PROP" is
'DBA Streams Component Properties'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".COMPONENT_ID is
'ID of the Streams Component'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".COMPONENT_NAME is
'Name of the Streams Component'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".COMPONENT_DB is
'Database Where the Streams Component Resides'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".COMPONENT_TYPE is
'Type of the Streams Component'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".PROP_NAME is
'Name of the Property'
/
comment on column "_DBA_STREAMS_TP_COMPONENT_PROP".PROP_VALUE is
'Value of the Property'
/
create or replace public synonym "_DBA_STREAMS_TP_COMPONENT_PROP"
  for "_DBA_STREAMS_TP_COMPONENT_PROP"
/
grant select on "_DBA_STREAMS_TP_COMPONENT_PROP" to select_catalog_role
/

-- Create DBA Streams Component Statistics view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_COMPONENT_STAT(
    COMPONENT_ID,
    COMPONENT_NAME,
    COMPONENT_DB,
    COMPONENT_TYPE,
    SUB_COMPONENT_TYPE,
    SESSION_ID,
    SESSION_SERIAL#,
    STATISTIC_TIME,
    STATISTIC_NAME,
    STATISTIC_VALUE,
    STATISTIC_UNIT,
    ADVISOR_RUN_ID,
    ADVISOR_RUN_TIME)
AS
SELECT C.COMPONENT_ID,
       nvl(C.COMPONENT_NAME, C.SPARE3) COMPONENT_NAME,
       C.COMPONENT_DB,
       decode(C.COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL),
       decode(S.SUB_COMPONENT_TYPE,
              -- Capture sub-components
              11, 'LOGMINER READER',
              12, 'LOGMINER PREPARER',
              13, 'LOGMINER BUILDER',
              14, 'CAPTURE SESSION',
              -- Apply sub-components
              41, 'PROPAGATION SENDER+RECEIVER',
              42, 'APPLY READER',
              43, 'APPLY COORDINATOR',
              44, 'APPLY SERVER',
              NULL),
       S.SESSION_ID,
       S.SESSION_SERIAL#,
       S.STATISTIC_TIME,
       S.STATISTIC_NAME,
       -- State is a varchar2 stored in spare3, everything else is a number
       decode(S.STATISTIC_NAME,
              'STATE', S.SPARE3,
              S.STATISTIC_VALUE),
       S.STATISTIC_UNIT,
       S.ADVISOR_RUN_ID,
       S.ADVISOR_RUN_TIME
FROM streams$_component C,
     streams$_component_stat_out S
WHERE C.COMPONENT_ID = S.COMPONENT_ID
  AND S.STATISTIC_NAME IS NOT NULL
  AND S.STATISTIC_NAME NOT IN (
       'SEND RATE TO APPLY',
       'BYTES SENT VIA SQL*NET TO DBLINK')
/

comment on table DBA_STREAMS_TP_COMPONENT_STAT is
'DBA Streams Component Statistics'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.COMPONENT_ID is
'ID of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.COMPONENT_NAME is
'Name of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.COMPONENT_DB is
'Database Where the Streams Component Resides'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.COMPONENT_TYPE is
'Type of the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.SUB_COMPONENT_TYPE is
'Type of the Streams Sub-component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.SESSION_ID is
'ID of the Streams Session for the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.SESSION_SERIAL# is
'Serial# of the Streams Session for the Streams Component'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.STATISTIC_TIME is
'Time That the Statistic Was Taken'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.STATISTIC_NAME is
'Name of the Statistic'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.STATISTIC_VALUE is
'Value of the Statistic'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.STATISTIC_UNIT is
'Unit of the Statistic'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.ADVISOR_RUN_ID is
'1-based Logical Number of Advisor Run'
/
comment on column DBA_STREAMS_TP_COMPONENT_STAT.ADVISOR_RUN_TIME is
'Time That the Advisor Was Run'
/
create or replace public synonym DBA_STREAMS_TP_COMPONENT_STAT
  for DBA_STREAMS_TP_COMPONENT_STAT
/
grant select on DBA_STREAMS_TP_COMPONENT_STAT to select_catalog_role
/

-- Create DBA Streams Path Statistics view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_PATH_STAT(
    PATH_ID,
    STATISTIC_TIME,
    STATISTIC_NAME,
    STATISTIC_VALUE,
    STATISTIC_UNIT,
    ADVISOR_RUN_ID,
    ADVISOR_RUN_TIME)
AS
SELECT PATH_ID,
       STATISTIC_TIME,
       STATISTIC_NAME,
       STATISTIC_VALUE,
       STATISTIC_UNIT,
       ADVISOR_RUN_ID,
       ADVISOR_RUN_TIME
FROM streams$_path_stat_out
/

comment on table DBA_STREAMS_TP_PATH_STAT is
'DBA Streams Path Statistics'
/
comment on column DBA_STREAMS_TP_PATH_STAT.PATH_ID is
'ID of the Streams Path'
/
comment on column DBA_STREAMS_TP_PATH_STAT.STATISTIC_TIME is
'Time That the Statistic Was Taken'
/
comment on column DBA_STREAMS_TP_PATH_STAT.STATISTIC_NAME is
'Name of the Statistic'
/
comment on column DBA_STREAMS_TP_PATH_STAT.STATISTIC_VALUE is
'Value of the Statistic'
/
comment on column DBA_STREAMS_TP_PATH_STAT.STATISTIC_UNIT is
'Unit of the Statistic'
/
comment on column DBA_STREAMS_TP_PATH_STAT.ADVISOR_RUN_ID is
'1-based Logical Number of Advisor Run'
/
comment on column DBA_STREAMS_TP_PATH_STAT.ADVISOR_RUN_TIME is
'Time That the Advisor Was Run'
/
create or replace public synonym DBA_STREAMS_TP_PATH_STAT
  for DBA_STREAMS_TP_PATH_STAT
/
grant select on DBA_STREAMS_TP_PATH_STAT to select_catalog_role
/

-- Create DBA Streams Bottleneck Statistics view
CREATE OR REPLACE VIEW DBA_STREAMS_TP_PATH_BOTTLENECK(
    PATH_ID,
    COMPONENT_ID,
    COMPONENT_NAME,
    COMPONENT_DB,
    COMPONENT_TYPE,
    TOP_SESSION_ID,
    TOP_SESSION_SERIAL#,
    ACTION_NAME,
    BOTTLENECK_IDENTIFIED,
    ADVISOR_RUN_ID,
    ADVISOR_RUN_TIME,
    ADVISOR_RUN_REASON)
AS
SELECT B.PATH_ID,
       B.COMPONENT_ID,
       nvl(C.COMPONENT_NAME, C.SPARE3) COMPONENT_NAME,
       C.COMPONENT_DB,
       decode(C.COMPONENT_TYPE,
              1, 'CAPTURE',
              2, 'PROPAGATION SENDER',
              3, 'PROPAGATION RECEIVER',
              4, 'APPLY',
              5, 'QUEUE',
              NULL),
       B.TOP_SESSION_ID,
       B.TOP_SESSION_SERIAL#,
       B.ACTION_NAME,
       B.BOTTLENECK_IDENTIFIED,
       B.ADVISOR_RUN_ID,
       B.ADVISOR_RUN_TIME,
       B.ADVISOR_RUN_REASON
FROM streams$_component C,
     streams$_path_bottleneck_out B
WHERE B.COMPONENT_ID = C.COMPONENT_ID (+);
/

comment on table  DBA_STREAMS_TP_PATH_BOTTLENECK is
'DBA Streams Path Bottleneck'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.PATH_ID is
'ID of the Streams Path'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.COMPONENT_NAME is
'Name of the Bottleneck Component'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.COMPONENT_DB is
'Database Where the Bottleneck Component resides'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.COMPONENT_TYPE is
'Type of the Bottleneck Component'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.TOP_SESSION_ID is
'ID of the Top Session for the Bottleneck Component'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.TOP_SESSION_SERIAL# is
'Serial# of the Top Session for the Bottleneck Component'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.ACTION_NAME is
'Action Name for the Bottleneck Process'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.BOTTLENECK_IDENTIFIED is
'Whether Bottlecneck Was Identified'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.ADVISOR_RUN_ID is
'1-Based Logical Number of Advisor Run'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.ADVISOR_RUN_TIME is
'Time That the Advisor Was Run'
/
comment on column DBA_STREAMS_TP_PATH_BOTTLENECK.ADVISOR_RUN_REASON is
'Reasons for Bottleneck Analysis Results'
/
create or replace public synonym DBA_STREAMS_TP_PATH_BOTTLENECK
  for DBA_STREAMS_TP_PATH_BOTTLENECK
/
grant select on DBA_STREAMS_TP_PATH_BOTTLENECK to select_catalog_role
/
