Rem
Rem $Header: rdbms/admin/cataqsch.sql /main/17 2010/01/11 13:39:50 rmao Exp $
Rem
Rem cataqsch.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cataqsch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      AQ dictionary objects that depend on the scheduler
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rmao        01/07/10 - bug9267327: cast date to timestamp
Rem    xingjin     03/25/09 - bug 8368685: add check to ensure package 
Rem                           owner is SYS
Rem    jawilson    02/27/09 - Adjust all time data to seconds
Rem    swshekha    01/12/08 - add ALL_QUEUE_SCHEDULES
Rem    jinwu       09/17/08 - populate user_queue_schedules using CCA stats
Rem    jhan        09/15/08 - Change DBA_QUEUE_SCHEDULE by using scheduler
Rem                           tables instead of views
Rem    jinwu       02/18/08 - populate dba_queue_schedules using CCA stats
Rem    jawilson    07/17/07 - populate cur_start_time
Rem    shbose      05/08/07 - 
Rem    asohi       04/11/07 - Backward compatible propagation
Rem    jhan        04/26/07 - change v$propagation_sender 
Rem                           to gv$propagation_sender
Rem    jhan        03/28/07 - change instance from scheduler jobs
Rem    jhan        03/22/07 - change union to union all 
Rem    jawilson    03/06/07 - job_name column for dba_queue_schedules
Rem    swshekha    01/16/07 - view definition changed: Total_time computation
Rem                           for dba_queue_schedules and user_queue_schedules
Rem                           from total_time of aq$_schedules
Rem    jawilson    09/14/06 - fix view definition
Rem    rburns      07/31/06 - move package bodies
Rem    jawilson    07/19/06 - Move AQ scheduler calls into separate file 
Rem    nbhatt      07/16/06 - 
Rem    jawilson    07/13/06 - move aq to cataqsch 
Rem    nbhatt      07/10/06 - 
Rem    jawilson    06/29/06 - 
Rem    adowning    06/26/06 - view changed because of new scheduler 
Rem    jawilson    06/20/06 - Created
Rem

-- Create the view _ALL_QUEUE_SCHEDULES

create or replace view "_ALL_QUEUE_SCHEDULES"
as
select t.schema SCHEMA, q.name QNAME,
        s.destination DESTINATION,
        j.start_date START_DATE,
        substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
        to_number(s.duration) PROPAGATION_WINDOW,
        DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL)
        NEXT_TIME, to_number(s.latency) LATENCY,
        decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED,
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and
          v.spid = rj.os_process_id) PROCESS_NAME,
        (select concat(to_char(rj.session_id), concat(', ', to_char(vs.serial#)))
          from gv$session vs where vs.sid = rj.session_id and
          vs.inst_id = j.instance_id) SESSION_ID,
        j.instance_id INSTANCE,
        j.last_start_date LAST_RUN_DATE,
        substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536), 2, j.last_start_date, NULL) CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536), 2, substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),NULL) CURRENT_START_TIME,
        j.next_run_date NEXT_RUN_DATE,
        substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
        s.total_time TOTAL_TIME,
        s.total_msgs TOTAL_NUMBER,
        s.total_bytes TOTAL_BYTES,
        s.total_msgs MAX_NUMBER, s.max_size MAX_BYTES,
        s.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER,
        s.total_bytes/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_SIZE,
        s.total_time/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_TIME,
        decode(j.failure_count, 1, 16, j.retry_count) FAILURES,
        s.error_time LAST_ERROR_DATE,
        substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
        s.last_error_msg LAST_ERROR_MSG,
        'PERSISTENT' MESSAGE_DELIVERY_MODE,
        null ELAPSED_DEQUEUE_TIME, null ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from    system.aq$_queues q, system.aq$_queue_tables t,
        sys.aq$_schedules s, sys.scheduler$_job j,
        gv$scheduler_running_jobs rj, sys.obj$ ro, sys.obj$ jo,
        dba_services d, sys.user$ u
where   s.oid  = q.oid
and     s.job_name = jo.name
and     j.obj# = jo.obj#
and     rj.job_id (+)= j.obj#
and     q.table_objno = t.objno
and     ro.owner# = u.user#
and     ro.obj# = q.eventid
and    (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -219 /* ENQUEUE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q,
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))
     )
and   q.service_name = d.name (+)
union all
select  p.queue_schema SCHEMA, p.queue_name QNAME,
        p.dblink DESTINATION, j.start_date START_DATE,
        substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
        to_number(s.duration) PROPAGATION_WINDOW,
        DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL)
        NEXT_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               p.last_lcr_latency, to_number(s.latency)) LATENCY,
        decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED,
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and
          v.spid = decode(p.schedule_status,
                          'SCHEDULE OPTIMIZED', p.spid,
                          rj.os_process_id)) PROCESS_NAME,
        case when p.schedule_status = 'SCHEDULE OPTIMIZED'
             then (p.session_id || ', ' || p.serial#)
             else (select concat(to_char(rj.session_id),
                          concat(', ', to_char(vs.serial#)))
                   from gv$session vs
                   where vs.sid = rj.session_id and vs.inst_id = j.instance_id)
        end SESSION_ID,
        j.instance_id INSTANCE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               cast(p.last_lcr_propagation_time as timestamp with time zone), j.last_start_date)
        LAST_RUN_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               substr(to_char(p.last_lcr_propagation_time, 'HH24:MI:SS'),1,8),
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8))
        LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536),2, j.last_start_date,
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      cast(p.startup_time as timestamp with time zone), NULL))
        CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536),2,
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      substr(to_char(p.startup_time,'HH24:MI:SS'),1,8), NULL))
        CURRENT_START_TIME,
        j.next_run_date NEXT_RUN_DATE,
        substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
        p.elapsed_propagation_time/100 TOTAL_TIME, p.total_msgs TOTAL_NUMBER,
        p.total_bytes TOTAL_BYTES,
        p.max_num_per_win MAX_NUMBER, p.max_size MAX_BYTES,
        p.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER,
        p.total_bytes/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_SIZE,
        (p.elapsed_propagation_time/100)/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', 0,
                decode(j.failure_count, 1, 16, j.retry_count)) FAILURES,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', to_date(NULL),
               s.error_time) LAST_ERROR_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               substr(to_char(s.error_time,'HH24:MI:SS'),1,8)) LAST_ERROR_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               s.last_error_msg) LAST_ERROR_MSG,
        'BUFFERED' MESSAGE_DELIVERY_MODE,
        p.elapsed_dequeue_time/100 ELAPSED_DEQUEUE_TIME,
        p.elapsed_pickle_time/100 ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from    system.aq$_queues q, gv$propagation_sender p,
        sys.aq$_schedules s, sys.scheduler$_job j, obj$ jo,
        gv$scheduler_running_jobs rj,sys.obj$ ro,
        dba_services d, sys.user$ u
where   q.eventid = p.queue_id
  and   q.oid = s.oid
  and   s.job_name = jo.name
  and   jo.obj# = j.obj#
  and   rj.job_id (+)= j.obj#
  and   p.dblink = s.destination
  and   ro.owner# = u.user#
  and   ro.obj# = q.eventid
  and  (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -219 /* ENQUEUE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q,
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))
     )
  and   q.service_name = d.name (+)

/

-- Create the view _DBA_QUEUE_SCHEDULES
-- This view provides all the details of all the propagation schedules
-- This includes scheduling parameters (start_time, duration, latency,
-- next_time, destination), qschema, qname, SNP process name and (session
-- ID, serial) if the schedule is in progress, statistics such as total and
-- averages of messages/bytes sent, message size, schedules status (Disabled/
-- enabled) and information about the last error (message, time) if one 
-- occured.
-- This view is 11G specific and uses dba_scheduler_jobs and
-- dba_scheduler_running_jobs to populate the fields

create or replace view "_DBA_QUEUE_SCHEDULES"
as
select t.schema SCHEMA, q.name QNAME, 
       	s.destination DESTINATION, 
	j.start_date START_DATE,
       	substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
       	to_number(s.duration) PROPAGATION_WINDOW,
       	DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL)
        NEXT_TIME, to_number(s.latency) LATENCY,
       	decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED, 
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and 
          v.spid = rj.os_process_id) PROCESS_NAME,
        (select concat(to_char(rj.session_id), concat(', ', to_char(vs.serial#)))
          from gv$session vs where vs.sid = rj.session_id and
          vs.inst_id = j.instance_id) SESSION_ID,
       	j.instance_id INSTANCE, 
	j.last_start_date LAST_RUN_DATE, 
       	substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536), 2, j.last_start_date, NULL) CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536), 2, substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),NULL) CURRENT_START_TIME,
       	j.next_run_date NEXT_RUN_DATE, 
       	substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
        s.total_time TOTAL_TIME,
	s.total_msgs TOTAL_NUMBER, 
       	s.total_bytes TOTAL_BYTES,
       	s.total_msgs MAX_NUMBER, s.max_size MAX_BYTES,
       	s.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER, 
       	s.total_bytes/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_SIZE, 
       	s.total_time/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_TIME,
       	decode(j.failure_count, 1, 16, j.retry_count) FAILURES, 
        s.error_time LAST_ERROR_DATE,
       	substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       	s.last_error_msg LAST_ERROR_MSG,
       	'PERSISTENT' MESSAGE_DELIVERY_MODE,
       	null ELAPSED_DEQUEUE_TIME, null ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from 	system.aq$_queues q, system.aq$_queue_tables t, 
     	sys.aq$_schedules s, sys.scheduler$_job j, obj$ jo, 
	gv$scheduler_running_jobs rj
where 	s.oid  = q.oid
and   	s.job_name = jo.name
and     j.obj# = jo.obj#
and     rj.job_id (+)= j.obj#
and   	q.table_objno = t.objno
union all
select 	p.queue_schema SCHEMA, p.queue_name QNAME,
       	p.dblink DESTINATION, j.start_date START_DATE,
       	substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
       	to_number(s.duration) PROPAGATION_WINDOW,
       	DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL)
        NEXT_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               p.last_lcr_latency, to_number(s.latency)) LATENCY,
       	decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED, 
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and 
          v.spid = decode(p.schedule_status,
                          'SCHEDULE OPTIMIZED', p.spid,
                          rj.os_process_id)) PROCESS_NAME,
        case when p.schedule_status = 'SCHEDULE OPTIMIZED'
             then (p.session_id || ', ' || p.serial#)
             else (select concat(to_char(rj.session_id),
                          concat(', ', to_char(vs.serial#)))
                   from gv$session vs
                   where vs.sid = rj.session_id and vs.inst_id = j.instance_id)
        end SESSION_ID,
       	j.instance_id INSTANCE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               cast(p.last_lcr_propagation_time as timestamp with time zone), j.last_start_date)
        LAST_RUN_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               substr(to_char(p.last_lcr_propagation_time, 'HH24:MI:SS'),1,8),
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8))
        LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536),2, j.last_start_date, 
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      cast(p.startup_time as timestamp with time zone), NULL))
        CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536),2,
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      substr(to_char(p.startup_time,'HH24:MI:SS'),1,8), NULL))
        CURRENT_START_TIME,
       	j.next_run_date NEXT_RUN_DATE,
       	substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       	p.elapsed_propagation_time/100 TOTAL_TIME, p.total_msgs TOTAL_NUMBER,
       	p.total_bytes TOTAL_BYTES,
       	p.max_num_per_win MAX_NUMBER, p.max_size MAX_BYTES,
       	p.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER,
       	p.total_bytes/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_SIZE, 
       	(p.elapsed_propagation_time/100)/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', 0,
              	decode(j.failure_count, 1, 16, j.retry_count)) FAILURES, 
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', to_date(NULL),
               s.error_time) LAST_ERROR_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               substr(to_char(s.error_time,'HH24:MI:SS'),1,8)) LAST_ERROR_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               s.last_error_msg) LAST_ERROR_MSG,
       	'BUFFERED' MESSAGE_DELIVERY_MODE,
       	p.elapsed_dequeue_time/100 ELAPSED_DEQUEUE_TIME,
       	p.elapsed_pickle_time/100 ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from 	system.aq$_queues q, gv$propagation_sender p,
     	sys.aq$_schedules s, sys.scheduler$_job j, obj$ jo, 
	gv$scheduler_running_jobs rj
where 	q.eventid = p.queue_id
  and 	q.oid = s.oid
  and 	s.job_name = jo.name
  and   jo.obj# = j.obj#
  and 	rj.job_id (+)= j.obj#
  and 	p.dblink = s.destination
/

-- Create the view _USER_QUEUE_SCHEDULES
-- This view provides all the details of the propagation schedules whose
-- source queues reside in the user's schema.
-- This includes scheduling parameters (start_time, duration, latency,
-- next_time, destination), qschema, qname, SNP process name and (session
-- ID, serial) if the schedule is in progress, statistics such as total and
-- averages of messages/bytes sent, message size, schedules status (Disabled/
-- enabled) and information about the last error (message, time) if one 
-- occured.
-- This view is 11G specific and uses dba_scheduler_jobs and
-- dba_scheduler_running_jobs to populate the fields
 
create or replace view "_USER_QUEUE_SCHEDULES"
as
select  q.name QNAME, 
       	s.destination DESTINATION, 
	s.start_time START_DATE,
       	substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
       	to_number(s.duration) PROPAGATION_WINDOW,
       	DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL)
        NEXT_TIME, to_number(s.latency) LATENCY,
       	decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED, 
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and 
          v.spid = rj.os_process_id) PROCESS_NAME,
        (select concat(to_char(rj.session_id), concat(', ', to_char(vs.serial#)))
          from gv$session vs where vs.sid = rj.session_id and
          vs.inst_id = j.instance_id) SESSION_ID,
       	j.instance_id INSTANCE, 
	j.last_start_date LAST_RUN_DATE, 
       	substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536), 2, j.last_start_date, NULL) CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536), 2, substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),NULL) CURRENT_START_TIME,
       	j.next_run_date NEXT_RUN_DATE, 
       	substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
	s.total_time TOTAL_TIME, 
	s.total_msgs TOTAL_NUMBER, 
       	s.total_bytes TOTAL_BYTES,
       	s.total_msgs MAX_NUMBER, s.max_size MAX_BYTES,
       	s.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER, 
       	s.total_bytes/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_SIZE, 
       	s.total_time/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_TIME,
       	decode(j.failure_count, 1, 16, j.retry_count) FAILURES, 
        s.error_time LAST_ERROR_DATE,
       	substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       	s.last_error_msg LAST_ERROR_MSG,
       	'PERSISTENT' MESSAGE_DELIVERY_MODE,
       	null ELAPSED_DEQUEUE_TIME, null ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from 	system.aq$_queues q, system.aq$_queue_tables t, 
     	sys.aq$_schedules s, sys.scheduler$_job j, obj$ jo, 
	gv$scheduler_running_jobs rj, sys.user$ u
where 	s.oid  = q.oid
and   	s.job_name = jo.name
and     j.obj# = jo.obj#
and   	rj.job_id (+)= j.obj# 
and   	q.table_objno = t.objno
and 	u.user# = USERENV('SCHEMAID')
and   	u.name  = t.schema
union all
select 	q.name QNAME,
       	s.destination DESTINATION, j.start_date START_DATE,
       	substr(to_char(j.start_date,'HH24:MI:SS'),1,8) START_TIME,
       	to_number(s.duration) PROPAGATION_WINDOW,
        DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL) NEXT_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               p.last_lcr_latency, to_number(s.latency)) LATENCY,
        decode(BITAND(j.job_status,1), 0, 'Y', 'N') SCHEDULE_DISABLED, 
        (select substr(v.program, LENGTH(v.program)-4, 4)
          from gv$process v where v.inst_id = j.instance_id and 
          v.spid = decode(p.schedule_status,
                          'SCHEDULE OPTIMIZED', p.spid,
                          rj.os_process_id)) PROCESS_NAME,
        case when p.schedule_status = 'SCHEDULE OPTIMIZED'
             then (p.session_id || ', ' || p.serial#)
             else (select concat(to_char(rj.session_id),
                          concat(', ', to_char(vs.serial#)))
                   from gv$session vs
                   where vs.sid = rj.session_id and vs.inst_id = j.instance_id)
        end SESSION_ID,
       	j.instance_id INSTANCE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               cast(p.last_lcr_propagation_time as timestamp with time zone), j.last_start_date)
        LAST_RUN_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
               substr(to_char(p.last_lcr_propagation_time, 'HH24:MI:SS'),1,8),
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8))
        LAST_RUN_TIME,
        decode(BITAND(j.job_status,2+65536), 2, j.last_start_date, 
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      cast(p.startup_time as timestamp with time zone), NULL))
        CURRENT_START_DATE,
        decode(BITAND(j.job_status,2+65536), 2,
               substr(to_char(j.last_start_date,'HH24:MI:SS'),1,8),
               decode(p.schedule_status, 'SCHEDULE OPTIMIZED',
                      substr(to_char(p.startup_time,'HH24:MI:SS'),1,8), NULL))
        CURRENT_START_TIME,
       	j.next_run_date NEXT_RUN_DATE,
       	substr(to_char(j.next_run_date,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       	p.elapsed_propagation_time/100 TOTAL_TIME, p.total_msgs TOTAL_NUMBER,
       	p.total_bytes TOTAL_BYTES,
       	p.max_num_per_win MAX_NUMBER, p.max_size MAX_BYTES,
       	p.total_msgs/GREATEST(1, (select count (*) from dba_scheduler_job_run_details where job_name = s.job_name)) AVG_NUMBER,
       	p.total_bytes/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_SIZE, 
       	(p.elapsed_propagation_time/100)/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', 0,
              	decode(j.failure_count, 1, 16, j.retry_count)) FAILURES, 
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', to_date(NULL),
               s.error_time) LAST_ERROR_DATE,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               substr(to_char(s.error_time,'HH24:MI:SS'),1,8)) LAST_ERROR_TIME,
        decode(p.schedule_status, 'SCHEDULE OPTIMIZED', NULL,
               s.last_error_msg) LAST_ERROR_MSG,
       	'BUFFERED' MESSAGE_DELIVERY_MODE,
       	p.elapsed_dequeue_time/100 ELAPSED_DEQUEUE_TIME,
       	p.elapsed_pickle_time/100 ELAPSED_PICKLE_TIME,
        s.job_name JOB_NAME
from 	system.aq$_queues q, system.aq$_queue_tables t, 
        gv$propagation_sender p, sys.aq$_schedules s, 
        sys.user$ u, sys.scheduler$_job j, obj$ jo, 
	gv$scheduler_running_jobs rj
where 	q.eventid = p.queue_id
  and 	q.oid = s.oid
  and 	s.job_name = jo.name
  and   jo.obj# = j.obj#
  and 	rj.job_id(+) = j.obj#
  and 	p.dblink = s.destination
  and 	u.user# = USERENV('SCHEMAID')
  and   u.name  = t.schema
  and   q.table_objno = t.objno
/

-- Create view for 10.2 compat.
-- Create the view _DBA_QUEUE_SCHEDULES_COMPAT
-- This view provides all the details of all the propagation schedules
-- This includes scheduling parameters (start_time, duration, latency,
-- next_time, destination), qschema, qname, SNP process name and (session
-- ID, serial) if the schedule is in progress, statistics such as total and
-- averages of messages/bytes sent, message size, schedules status (Disabled/
-- enabled) and information about the last error (message, time) if one 
-- occured.
-- The view does not query dba_scheduler_jobs and dba_scheduler_running_jobs
-- since in 102 mode of propagation the queries will return nothing.

create or replace view "_DBA_QUEUE_SCHEDULES_COMPAT"
as
select t.schema SCHEMA, q.name QNAME, 
       s.destination DESTINATION, 
       cast(s.start_time as timestamp(6) with time zone) START_DATE,
       substr(to_char(s.start_time,'HH24:MI:SS'),1,8) START_TIME,
       to_number(s.duration) PROPAGATION_WINDOW,
       s.next_time NEXT_TIME, to_number(s.latency) LATENCY,
       s.disabled SCHEDULE_DISABLED, 
       substr(s.process_name,1,4)  PROCESS_NAME, 
       decode(s.sid, NULL, NULL, 
         concat(to_char(s.sid), concat(', ',to_char(s.serial)))) SESSION_ID,
       s.instance INSTANCE,
       cast( s.last_run as timestamp(6) with time zone)  LAST_RUN_DATE, 
       substr(to_char(s.last_run,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
       s.cur_start_time CURRENT_START_DATE, 
       substr(to_char(s.cur_start_time,'HH24:MI:SS'),1,8) CURRENT_START_TIME,
       cast(s.next_run as timestamp(6) with time zone) NEXT_RUN_DATE, 
       substr(to_char(s.next_run,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       s.total_time TOTAL_TIME, s.total_msgs TOTAL_NUMBER, 
       s.total_bytes TOTAL_BYTES,
       s.max_num_per_win MAX_NUMBER, s.max_size MAX_BYTES,
       s.total_msgs/decode(s.total_windows, 0, 1, s.total_windows) AVG_NUMBER, 
       s.total_bytes/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_SIZE, 
       s.total_time/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_TIME,
       s.failures FAILURES, s.error_time LAST_ERROR_DATE,
       substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       s.last_error_msg LAST_ERROR_MSG,
       'PERSISTENT' MESSAGE_DELIVERY_MODE,
       null ELAPSED_DEQUEUE_TIME, null ELAPSED_PICKLE_TIME,
       s.job_name JOB_NAME
from system.aq$_queues q, system.aq$_queue_tables t, 
     sys.aq$_schedules s
where s.oid  = q.oid
and   q.table_objno = t.objno
union
select p.queue_schema SCHEMA, p.queue_name QNAME,
       p.dblink DESTINATION, 
       cast(s.start_time as timestamp(6) with time zone) START_DATE,
       substr(to_char(s.start_time,'HH24:MI:SS'),1,8) START_TIME,
       to_number(s.duration) PROPAGATION_WINDOW,
       s.next_time NEXT_TIME, to_number(s.latency) LATENCY,
       s.disabled SCHEDULE_DISABLED, 
       substr(s.process_name,1,4)  PROCESS_NAME, 
       decode(s.sid, NULL, NULL, 
         concat(to_char(s.sid), concat(', ',to_char(s.serial)))) SESSION_ID,
       s.instance INSTANCE, 
       cast(s.last_run as timestamp(6) with time zone) LAST_RUN_DATE, 
       substr(to_char(s.last_run,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
       s.cur_start_time,            -- CURRENT_START_DATE
       substr(to_char(s.cur_start_time,'HH24:MI:SS'),1,8) CURRENT_START_TIME,
       cast(s.next_run as timestamp(6) with time zone) NEXT_RUN_DATE, 
       substr(to_char(s.next_run,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       p.elapsed_propagation_time/100 TOTAL_TIME, p.total_msgs TOTAL_NUMBER,
       p.total_bytes TOTAL_BYTES,
       p.max_num_per_win MAX_NUMBER, p.max_size MAX_BYTES,
       p.total_msgs/decode(s.total_windows, 0, 1, s.total_windows) AVG_NUMBER,
       p.total_bytes/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_SIZE, 
       s.total_time/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_TIME,
       s.failures FAILURES, s.error_time LAST_ERROR_DATE,
       substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       s.last_error_msg LAST_ERROR_MSG,
       'BUFFERED' MESSAGE_DELIVERY_MODE,
       p.elapsed_dequeue_time/100 ELAPSED_DEQUEUE_TIME,
       p.elapsed_pickle_time/100 ELAPSED_PICKLE_TIME,
       s.job_name JOB_NAME
from system.aq$_queues q, v$propagation_sender p, sys.aq$_schedules s
where q.eventid = p.queue_id
  and q.oid = s.oid
  and p.dblink = s.destination
/

-- Create the view _USER_QUEUE_SCHEDULES_COMPAT for 102 compatibility
-- This view provides all the details of the propagation schedules whose
-- source queues reside in the user's schema.
-- This includes scheduling parameters (start_time, duration, latency,
-- next_time, destination), qschema, qname, SNP process name and (session
-- ID, serial) if the schedule is in progress, statistics such as total and
-- averages of messages/bytes sent, message size, schedules status (Disabled/
-- enabled) and information about the last error (message, time) if one 
-- occured.
-- The view does not query dba_scheduler_jobs and dba_scheduler_running_jobs
-- since in 102 mode of propagation the queries will return nothing.

create or replace view "_USER_QUEUE_SCHEDULES_COMPAT"
as
select q.name QNAME, 
       s.destination DESTINATION, 
       cast(s.start_time as timestamp(6) with time zone) START_DATE,
       substr(to_char(s.start_time,'HH24:MI:SS'),1,8) START_TIME,
       to_number(s.duration) PROPAGATION_WINDOW,
       s.next_time NEXT_TIME, to_number(s.latency) LATENCY,
       s.disabled SCHEDULE_DISABLED, 
       substr(s.process_name,1,4) PROCESS_NAME, 
       decode(s.sid, NULL, NULL, 
         concat(to_char(s.sid), concat(', ',to_char(s.serial)))) SESSION_ID,
       s.instance INSTANCE, 
       cast(s.last_run as timestamp(6) with time zone) LAST_RUN_DATE, 
       substr(to_char(s.last_run,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
       s.cur_start_time CURRENT_START_DATE, 
       substr(to_char(s.cur_start_time,'HH24:MI:SS'),1,8) CURRENT_START_TIME,
       cast(s.next_run as timestamp(6) with time zone) NEXT_RUN_DATE, 
       substr(to_char(s.next_run,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       s.total_time TOTAL_TIME, s.total_msgs TOTAL_NUMBER, 
       s.total_bytes TOTAL_BYTES,
       s.max_num_per_win MAX_NUMBER, s.max_size MAX_BYTES,
       s.total_msgs/decode(s.total_windows, 0, 1, s.total_windows) AVG_NUMBER, 
       s.total_bytes/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_SIZE, 
       s.total_time/decode(s.total_msgs, 0, 1, s.total_msgs) AVG_TIME,
       s.failures FAILURES, s.error_time LAST_ERROR_DATE,
       substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       s.last_error_msg LAST_ERROR_MSG,
       'PERSISTENT' MESSAGE_DELIVERY_MODE,
       null ELAPSED_DEQUEUE_TIME, null ELAPSED_PICKLE_TIME,
       s.job_name JOB_NAME
from system.aq$_queues q, system.aq$_queue_tables t, 
     sys.aq$_schedules s, sys.user$ u
where u.user# = USERENV('SCHEMAID')
and   u.name  = t.schema
and   s.oid  = q.oid
and   q.table_objno = t.objno
union
select q.name QNAME, 
       s.destination DESTINATION, 
       cast(s.start_time as timestamp(6) with time zone) START_DATE,
       substr(to_char(s.start_time,'HH24:MI:SS'),1,8) START_TIME,
       to_number(s.duration) PROPAGATION_WINDOW,
       s.next_time NEXT_TIME, to_number(s.latency) LATENCY,
       s.disabled SCHEDULE_DISABLED, 
       substr(s.process_name,1,4) PROCESS_NAME, 
       decode(s.sid, NULL, NULL, 
         concat(to_char(s.sid), concat(', ',to_char(s.serial)))) SESSION_ID,
       s.instance INSTANCE, 
       cast(s.last_run as timestamp(6) with time zone) LAST_RUN_DATE, 
       substr(to_char(s.last_run,'HH24:MI:SS'),1,8) LAST_RUN_TIME,
       s.cur_start_time CURRENT_START_DATE, 
       substr(to_char(s.cur_start_time,'HH24:MI:SS'),1,8) CURRENT_START_TIME,
       cast(s.next_run as timestamp(6) with time zone) NEXT_RUN_DATE, 
       substr(to_char(s.next_run,'HH24:MI:SS'),1,8) NEXT_RUN_TIME,
       p.elapsed_propagation_time/100 TOTAL_TIME, p.total_msgs TOTAL_NUMBER,
       p.total_bytes TOTAL_BYTES,
       p.max_num_per_win MAX_NUMBER, p.max_size MAX_BYTES,
       p.total_msgs/decode(s.total_windows, 0, 1, s.total_windows) AVG_NUMBER,
       p.total_bytes/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_SIZE, 
       s.total_time/decode(p.total_msgs, 0, 1, p.total_msgs) AVG_TIME,
       s.failures FAILURES, s.error_time LAST_ERROR_DATE,
       substr(to_char(s.error_time,'HH24:MI:SS'),1,8) LAST_ERROR_TIME,
       s.last_error_msg LAST_ERROR_MSG,
       'BUFFERED' MESSAGE_DELIVERY_MODE,
       p.elapsed_dequeue_time/100 ELAPSED_DEQUEUE_TIME,
       p.elapsed_pickle_time/100 ELAPSED_PICKLE_TIME,
       s.job_name JOB_NAME
from system.aq$_queues q, system.aq$_queue_tables t, v$propagation_sender p, 
     sys.aq$_schedules s, sys.user$ u
where u.user# = USERENV('SCHEMAID')
and   u.name  = t.schema
and   s.oid  = q.oid
and   q.table_objno = t.objno
and   q.eventid = p.queue_id
and   p.dblink = s.destination

/

-- create view and synonym all_queue_schedules which will be visible
-- to the user. By default view is built over _all_queue_schedules view
-- assuming 11g mode of propagation. 
create or replace view ALL_QUEUE_SCHEDULES as
select  * from  "_ALL_QUEUE_SCHEDULES"
/

create or replace public synonym ALL_QUEUE_SCHEDULES for ALL_QUEUE_SCHEDULES
/
grant select on ALL_QUEUE_SCHEDULES to PUBLIC with grant option
/

-- create view and synonym dba_queue_schedules which will be visible
-- to the user. By default view is built over _dba_queue_schedules view
-- assuming 11g mode of propagation. 
create or replace view DBA_QUEUE_SCHEDULES as 
select  * from  "_DBA_QUEUE_SCHEDULES"
/

create or replace public synonym DBA_QUEUE_SCHEDULES for DBA_QUEUE_SCHEDULES
/
grant select on DBA_QUEUE_SCHEDULES to SELECT_CATALOG_ROLE
/

-- create view and synonym user_queue_schedules which will be visible
-- to the user. By default view is built over _user_queue_schedules view
-- assuming 11g mode of propagation
create or replace view USER_QUEUE_SCHEDULES as
select * from "_USER_QUEUE_SCHEDULES"
/

create or replace public synonym USER_QUEUE_SCHEDULES for USER_QUEUE_SCHEDULES
/
grant select on USER_QUEUE_SCHEDULES to PUBLIC with grant option
/
