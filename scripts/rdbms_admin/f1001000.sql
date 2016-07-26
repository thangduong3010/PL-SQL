Rem $Header: rdbms/admin/f1001000.sql /st_rdbms_11.2.0/1 2010/12/02 02:20:42 ineall Exp $
Rem
Rem f1001000.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      f1001000.sql - additional downgrade script from current release 
Rem                     to 10.1.0
Rem
Rem    DESCRIPTION
Rem
Rem      Additional downgrade script to be run during the downgrade from
Rem      current release to 10.1. This must be run before e1001000.sql.
Rem
Rem	 Put any downgrade actions that reference PL/SQL packages here.
Rem      The PL/SQL packages must be called from this script prior to 
Rem      any downgrade actions in e1001000.sql which could invalidate
Rem      the referenced PL/SQL calls.  
Rem      
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ineall      12/02/10 - Bug 10128898: backport added new dependency
Rem    shbose      04/30/09 - bug 7530052: use create_base_view10_1_0 for
Rem                           single consumer queues
Rem    gagarg      04/23/09 - Bug 8450499: Use exec immediate instead of 
Rem                           sys.dbms_aqadm_sys.execute_stmt().
Rem    jkundu      03/16/09 - add call to reset_package before downgrading
Rem                           logmnr spill to 10.1
Rem    cdilling    11/29/07 - move dbms_assert calls from e1001000.sql
Rem    cdilling    09/26/07 - move drop_transformation here from e1001000.sql
Rem    cdilling    07/11/07 - move .downgraded calls here from e1001000.sql
Rem    qiwang      06/28/07 - BUG 5845153: LSBY ckpt downgrade
Rem    cdilling    09/14/06 - move e1001000.sql code that call pl/sql packages 
Rem    rburns      03/01/04 - rburns_more_10_1_updown 
Rem    rburns      02/23/04 - Created

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release to 10.2
Rem =========================================================================

@@f1002000

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release to 10.2
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade from 10.2.0 to 10.1.0
Rem =========================================================================

Rem=========================================================================
Rem Run PL/SQL blocks to downgrade procedural objects
Rem=========================================================================

Rem Remove any existing package state for the session
Rem execute DBMS_SESSION.RESET_PACKAGE; 

-- Drop scheduler chains
DECLARE
  CURSOR all_chains IS
    SELECT chain_name, owner from DBA_SCHEDULER_CHAINS;
BEGIN
  FOR chain in all_chains LOOP
    dbms_scheduler.drop_chain('"' || chain.owner || '"."' ||
      chain.chain_name || '"', TRUE);
  END LOOP;
END;
/

-- Drop aq_srvntfn_table
DECLARE
  QTAB_DOES_NOT_EXIST exception;
  pragma              EXCEPTION_INIT(QTAB_DOES_NOT_EXIST, -24002);
BEGIN
  dbms_aqadm.drop_queue_table(queue_table => 'SYS.AQ_SRVNTFN_TABLE',
                              force=> TRUE);
EXCEPTION
  WHEN QTAB_DOES_NOT_EXIST THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END;
/

Rem =========================================================================
Rem Begin downgrade sqltext signature fields in various dict tables
Rem =========================================================================

DECLARE
  CURSOR sig_sql_cur IS
    SELECT  signature old_sig, 
            flags force_flag              
    FROM    sys.sql$;
 
    sig_rec sig_sql_cur%ROWTYPE;
    sqltext clob;
    new_sig number;
    flag    binary_integer; 

BEGIN
  OPEN sig_sql_cur;

  LOOP  

    FETCH sig_sql_cur INTO sig_rec;
    EXIT WHEN sig_sql_cur%NOTFOUND OR sig_sql_cur%NOTFOUND IS NULL;
   
    BEGIN        

    select sql_text into sqltext from sys.sql$text 
        where signature = sig_rec.old_sig;
    
    --downgrade requires invocation of old signature generation
    --force_flag is incremented to denote this to the callout
    flag := sig_rec.force_flag + 2;

    --compute new signature taking care of force flag
    new_sig := sys.dbms_sqltune_util0.sqltext_to_signature(sqltext, flag);
   
    --left bit shift new signature by 1 bit to avoid collision with old
    --signature
    new_sig := new_sig + 18446744073709551616;
    
    --update signature in sys.sql$, sys.sqlprof$, sys.sqlprof$desc, 
    --sys.sqlprof$attr and sys.sql$text
    update sys.sql$ 
      set signature = new_sig where signature = sig_rec.old_sig;

    update sys.sqlprof$ 
      set signature = new_sig where signature = sig_rec.old_sig;
  
    update sys.sqlprof$desc
      set signature = new_sig where signature = sig_rec.old_sig;

    update sys.sqlprof$attr 
      set signature = new_sig where signature = sig_rec.old_sig;
 
    update sys.sql$text 
      set signature = new_sig where signature = sig_rec.old_sig;

    commit;

    EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
       --hash collision encountered due to bug in signature generation
       --rollback the transaction
       --delete the profile from all tables, dump the info to alert.log        

       new_sig := new_sig - 18446744073709551616;

       dbms_system.ksdwrt(
        2, 'Internal error: Mismatch in signature for SQL Profile ' || '\n' ||
        'Downgrade failed for SQL statement : ' || sqltext || '\n' ||   
        'Dropping the SQL profile from the dictionary' || '\n' ||
        'Old Signature: ' || sig_rec.old_sig || ' ' || '\n' || 
        'New Signature: ' || new_sig);                
       
       delete from sys.sql$ where signature = sig_rec.old_sig;
        
       delete from sys.sqlprof$ where signature = sig_rec.old_sig;

       delete from sys.sqlprof$desc where signature = sig_rec.old_sig;        

       delete from sys.sqlprof$attr where signature = sig_rec.old_sig;

       delete from sys.sql$text where signature = sig_rec.old_sig;

       commit;       
    END;
   
  END LOOP;

  CLOSE sig_sql_cur;


  --now revert signature, shift right by 1 bit and compute the hash
  OPEN sig_sql_cur;
  LOOP  

    FETCH sig_sql_cur INTO sig_rec;
    EXIT WHEN sig_sql_cur%NOTFOUND OR sig_sql_cur%NOTFOUND IS NULL;
   
    BEGIN        

     new_sig := sig_rec.old_sig - 18446744073709551616;

      update sys.sql$ 
        set signature = new_sig
        where signature = sig_rec.old_sig;
      commit;

      update sys.sql$
        set nhash = mod(new_sig, 4294967296)
        where signature = new_sig;
     
      update sys.sqlprof$ 
        set signature = new_sig
        where signature = sig_rec.old_sig;
      commit;
  
      update sys.sqlprof$
        set nhash = mod(new_sig, 4294967296)
        where signature = new_sig;
       
      update sys.sqlprof$desc 
        set signature = new_sig
        where signature = sig_rec.old_sig;

      update sys.sqlprof$attr 
        set signature = new_sig
        where signature = sig_rec.old_sig;

      update sys.sql$text 
        set signature = new_sig
        where signature = sig_rec.old_sig;        
      commit;

    END;
   
  END LOOP;
  CLOSE sig_sql_cur;

END;
/
Rem =========================================================================
Rem End downgrade sqltext signature fields in various dict tables
Rem =========================================================================


Rem BEGIN dropping file group packages

BEGIN
  dbms_scheduler.drop_job('SYS.FGR$AUTOPURGE_JOB', TRUE);
END;
/

Rem remove notification subscriber
declare  
subscriber sys.aq$_agent; 
begin 
subscriber := sys.aq$_agent('HAE_SUB',null,null); 
dbms_aqadm.remove_subscriber(queue_name => 'SYS.ALERT_QUE', 
                             subscriber => subscriber);
end;
/

Rem=========================================================================
Rem Begin Scheduler Downgrade
Rem=========================================================================


Rem downgrade scheduler events 
DECLARE
  CURSOR evt_jobs IS
    SELECT job_name, owner FROM dba_scheduler_jobs
    WHERE bitand(flags, 134217728 + 268435456) <> 0;
  CURSOR rsevt_jobs IS
    SELECT job_name, owner FROM dba_scheduler_jobs
    WHERE raise_events is not null;
  CURSOR evt_schedules IS
    SELECT o.name SCHEDULE_NAME, u.name OWNER 
    FROM obj$ o, user$ u, scheduler$_schedule s
    WHERE bitand(s.flags, 4) <> 0 AND s.obj# = o.obj# AND o.owner# = u.user#;
BEGIN
  FOR job in evt_jobs LOOP
    dbms_scheduler.drop_job('"'||job.owner||'"."'||job.job_name||'"', TRUE);
  END LOOP;

  FOR job in rsevt_jobs LOOP
    dbms_scheduler.set_attribute_null('"'||job.owner||'"."'||job.job_name||'"',
                                      'RAISE_EVENTS');
  END LOOP;

  FOR sch in evt_schedules LOOP
    dbms_scheduler.drop_schedule('"'||sch.owner||'"."'||sch.schedule_name||'"',
                                 TRUE);
  END LOOP;
END;
/

DECLARE
  CURSOR all_subs IS
    SELECT '"' || agt_name || '"' agt_name FROM scheduler$_evtq_sub;
BEGIN
  FOR sub in all_subs LOOP
    dbms_scheduler.remove_event_queue_subscriber(sub.agt_name);
  END LOOP;
END;
/

BEGIN
  dbms_aqadm.stop_queue('SYS.SCHEDULER$_EVENT_QUEUE');
  dbms_aqadm.drop_queue('SYS.SCHEDULER$_EVENT_QUEUE');
  dbms_aqadm.drop_queue_table('SYS.SCHEDULER$_EVENT_QTAB');
END;
/

BEGIN
  dbms_aqadm.drop_aq_agent('SCHEDULER$_EVENT_AGENT');
END;
/

BEGIN
  dbms_isched.drop_scheduler_attribute('LAST_OBSERVED_EVENT');
  dbms_isched.drop_scheduler_attribute('EVENT_EXPIRY_TIME');
END;
/
Rem=========================================================================
Rem End Scheduler Downgrade
Rem=========================================================================

Rem=========================================================================
Rem Begin Advanced Queuing downgrade
Rem=========================================================================
DECLARE
  CURSOR cur IS SELECT qt.schema, qt.name qtname, q.name qname FROM 
    system.aq$_queues q, system.aq$_queue_tables qt 
    WHERE q.table_objno = qt.objno AND bitand(q.properties,512) = 512;
  stmt       VARCHAR2(200);
  sub_count  NUMBER;
BEGIN
  FOR bufq IN cur LOOP
    -- Make all non-streams buffered subscribers persistent
    stmt := 'UPDATE ' || bufq.schema || '.AQ$_' || bufq.qtname ||
      '_S SET subscriber_type = subscriber_type-128+64 WHERE ' || 
      'queue_name = :1 AND bitand(subscriber_type, 1+128+1024) = 1+128';
    EXECUTE IMMEDIATE stmt USING bufq.qname;

    -- Also, if no streams buffered subscribers, drop the queue's buffer
    stmt := 'SELECT COUNT(*) FROM ' || bufq.schema || '.AQ$_' || 
      bufq.qtname || '_S WHERE queue_name = :1 AND ' ||  
      'bitand(subscriber_type, 1+128+1024) = 1+128+1024';
    EXECUTE IMMEDIATE stmt INTO sub_count USING bufq.qname;
    IF sub_count = 0 THEN
      sys.dbms_aqadm_sys.drop_buffer(bufq.schema || '.' || bufq.qname, 
        TRUE, TRUE);
    END IF;
  END LOOP;
END;
/

DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
    FROM system.aq$_queue_tables qt;
BEGIN
        
  -- recreate buffer views for downgrade
  FOR qt_rec IN qt_cur LOOP

    -- drop buffer view
    IF bitand(qt_rec.flags, 8) = 8 THEN
      dbms_aqadm_sys.drop_buffer_view(qt_rec.schema, qt_rec.name);

      IF (bitand(qt_rec.flags, 1) = 1) THEN
        -- for multiconsumer newstyle recreate buffer view
        dbms_aqadm_sys.create_buffer_view101(qt_rec.schema, qt_rec.name,
                                             TRUE);
        sys.dbms_prvtaqim.create_base_view10_1_0(
               qt_rec.schema, qt_rec.name, qt_rec.flags);
      ELSE
        -- for singleconsumer queues, recreate queue table view       
        sys.dbms_aqadm_sys.create_base_view10_1_0(
                 qt_rec.schema, qt_rec.name, qt_rec.flags);
      END IF;
    END IF;

    BEGIN 

      -- Bug 8450499: Use exec immediate. 
      EXECUTE IMMEDIATE 'DROP VIEW ' || '"'||qt_rec.schema||'"."' ||
                        'AQ$_' || qt_rec.name|| '_F"';

    EXCEPTION 
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'f1001000.sql:  Dropping of deq view ' ||
                           'failed for ' || qt_rec.schema || '.' ||
                            qt_rec.name);
    END;
 END LOOP;

END;
/

DECLARE
  CURSOR buf_cur IS 
  SELECT qt.schema, qt.name, qt.flags 
    FROM system.aq$_queue_tables qt
   WHERE EXISTS (SELECT q.name
                   FROM system.aq$_queues q
                  WHERE q.table_objno = qt.objno
                    AND (bitand(q.properties, 512) = 512));
  alt_stmt1 VARCHAR2(300);
  alt_stmt2 VARCHAR2(300);
BEGIN

  FOR buf_rec IN buf_cur LOOP
    alt_stmt1 := 'ALTER TABLE ' ||
             dbms_assert.enquote_name(buf_rec.schema, FALSE) || '.' || 
             dbms_assert.enquote_name('AQ$_' || buf_rec.name || '_P', FALSE) ||
                 ' DROP PRIMARY KEY';
    EXECUTE IMMEDIATE alt_stmt1;

    alt_stmt2 := 'ALTER TABLE ' ||
             dbms_assert.enquote_name(buf_rec.schema, FALSE) || '.' ||
             dbms_assert.enquote_name('AQ$_' || buf_rec.name || '_P', FALSE) ||
                 ' ADD PRIMARY KEY (msgid)';
    EXECUTE IMMEDIATE alt_stmt2;

  END LOOP;
END;
/


DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name FROM system.aq$_queue_tables qt;
  dv_stmt  VARCHAR2(200);
BEGIN
  FOR qt_rec IN qt_cur LOOP
    BEGIN
      dv_stmt := 'DROP VIEW ' ||  
              dbms_assert.enquote_name(qt_rec.schema, FALSE) || '.' ||
              dbms_assert.enquote_name('AQ$' || qt_rec.name|| '_D', FALSE);
      EXECUTE IMMEDIATE dv_stmt;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END;
/

Rem=========================================================================
Rem Begin Logminer Downgrade
Rem=========================================================================

alter table system.logmnr_session_evolve$ disable primary key;

Rem In the same tablespace, drop the 10.2 primary key and recreate
Rem the 10.1 primary key for logmnr_log$.
DECLARE
  tableSpaceName varchar2(32);
BEGIN
  BEGIN
    select s.name into tablespacename
    from sys.obj$ o, sys.ts$ s, sys.user$ u, sys.ind$ i
    where s.ts# = i.ts# and o.obj# = i.obj# and
          o.owner# = u.user# and u.name = 'SYSTEM' and
          o.name = 'LOGMNR_LOG$_PK' and rownum = 1;
  EXCEPTION
  WHEN OTHERS THEN
    tablespacename := 'SYSAUX';
  END;
  BEGIN
    execute immediate
      'alter table system.logmnr_log$ drop primary key cascade';
  EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode <> -2441 THEN
      RAISE;
    END IF;
  END;
  execute immediate 'alter table system.logmnr_log$ add constraint
    logmnr_log$_pk primary key (session#, thread#, sequence#, first_change#,
    next_change#, db_id, resetlogs_change#, reset_timestamp)
    USING INDEX TABLESPACE ' || 
    dbms_assert.enquote_name(tableSpaceName, FALSE) || ' LOGGING';
END;
/
truncate table system.logmnr_filter$;

truncate table system.logmnrp_ctas_part_map;

Rem=========================================================================
Rem End Logminer Downgrade
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Logical Standby downgrade items
Rem=========================================================================
Rem
Rem BUG 5845153
Rem Convert Logical Standby Ckpt data from 10.2 format to 10.1 format
Rem

execute dbms_session.reset_package;

begin
  sys.dbms_logmnr_internal.agespill_102to101;
end;
/

Rem=========================================================================
Rem End Logical Standby downgrade items
Rem=========================================================================

execute sys.dbms_transform.drop_transformation('SYS', 'haen_txfm_obj');

Rem =========================================================================
Rem END STAGE 2: downgrade from 10.2.0 to 10.1.0
Rem =========================================================================

Rem update status in component registry (last)

BEGIN
   dbms_registry.downgraded('CATALOG','10.1.0');
   dbms_registry.downgraded('CATPROC','10.1.0');
END;
/

Rem *************************************************************************
Rem END f1001000.sql
Rem *************************************************************************

