Rem
Rem $Header: rdbms/admin/catscqa.sql /st_rdbms_11.2.0/1 2011/06/02 07:16:05 desingh Exp $
Rem
Rem catscqa.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catscqa.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    desingh     05/29/11 - Backport desingh_bug-12423122 from main
Rem    nbhatt      06/04/10 - create secondary index on history iot
Rem    rgmani      02/26/08 - File watch
Rem    jawilson    07/19/06 - Script containing scheduler AQ calls 
Rem    jawilson    07/19/06 - Script containing scheduler AQ calls 
Rem    jawilson    07/19/06 - Created
Rem


/* moved down to after reloading dbms_job packages */
begin
  dbms_aqadm.create_queue_table
    (queue_table => 'scheduler$_event_qtab',
     queue_payload_type => 'sys.scheduler$_event_info',
     multiple_consumers => true,
     comment => 'Scheduler event queue table',
     secure => true);
exception
  when others then
    if sqlcode = -24001 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue
    (queue_name => 'scheduler$_event_queue',
     queue_table => 'scheduler$_event_qtab',
     retention_time => 3600,
     comment => 'Scheduler event queue');
exception
  when others then
    if sqlcode = -24006 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.start_queue(queue_name => 'scheduler$_event_queue');
end;
/

begin
  dbms_aqadm.grant_queue_privilege('DEQUEUE', 'SYS.SCHEDULER$_EVENT_QUEUE',
                                   'PUBLIC');
end;
/

begin
  dbms_aqadm.create_queue_table
    (queue_table => 'scheduler$_remdb_jobqtab',
     queue_payload_type => 'sys.scheduler$_remote_db_job_info',
     multiple_consumers => true,
     storage_clause => 'nested table user_data.arguments store as ' ||
                       'scheduler$_rjq_ant',
     comment => 'Scheduler remote db job queue table',
     secure => false);
exception
  when others then
    if sqlcode = -24001 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue
    (queue_name => 'scheduler$_remdb_jobq',
     queue_table => 'scheduler$_remdb_jobqtab',
     comment => 'Scheduler remote db job queue');
exception
  when others then
    if sqlcode = -24006 then NULL;
    else raise;
    end if;
end;
/


begin
  dbms_aqadm.start_queue(queue_name => 'scheduler$_remdb_jobq');
end;
/

-- Have to Call Internal AQ package because calling dbms_aqadm breaks
-- because of dependency on dbms_datapump has not been loaded. Since
-- this is an internal API call we do it from our internal package.
begin
  dbms_aqadm_sys.create_aq_agent(agent_name => 'SCHEDULER$_EVENT_AGENT',
                                 name_canonicalized => FALSE);
exception
  when others then
    if sqlcode = -24089 then null;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm_sys.enable_db_access('SCHEDULER$_EVENT_AGENT', 'SYS', FALSE);
end;
/

begin
  dbms_aqadm_sys.create_aq_agent(agent_name => 'SCHEDULER$_REMDB_AGENT',
                                 name_canonicalized => FALSE);
exception
  when others then
    if sqlcode = -24089 then null;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm_sys.enable_db_access('SCHEDULER$_REMDB_AGENT', 'SYS', FALSE);
end;
/

-- File watcher queues

begin
  dbms_aqadm.create_queue_table
    (queue_table => 'scheduler_filewatcher_qt',
     queue_payload_type => 'sys.scheduler_filewatcher_result',
     multiple_consumers => true,
     storage_clause => 'nested table user_data.matching_requests store as ' ||
                       'scheduler$_fwq_ant',
     comment => 'Scheduler file watcher result queue table',
     secure => true);
exception
  when others then
    if sqlcode = -24001 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue
    (queue_name => 'scheduler_filewatcher_q',
     queue_table => 'scheduler_filewatcher_qt',
     comment => 'Scheduler file watcher results queue');
exception
  when others then
    if sqlcode = -24006 then NULL;
    else raise;
    end if;
end;
/


begin
  dbms_aqadm.start_queue(queue_name => 'scheduler_filewatcher_q');
end;
/

begin
  dbms_aqadm.grant_queue_privilege('DEQUEUE', 'SYS.SCHEDULER_FILEWATCHER_Q',
                                   'PUBLIC');
end;
/
