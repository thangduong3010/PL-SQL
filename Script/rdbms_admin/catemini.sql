Rem
Rem $Header: catemini.sql 29-jun-2003.14:12:49 sgollapu Exp $
Rem
Rem catemini.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catemini.sql - emon notify initialization script
Rem
Rem    DESCRIPTION
Rem      creates queue used by emnotify, should be run as sys at db init time.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sgollapu    06/28/03 - Change agent from TAF to TAFTSM
Rem    abegueli    06/11/03 - abegueli_emnotify
Rem    abegueli    05/09/03 - Created
Rem

REM  create a multiple consumer queue table and queue        

DECLARE
  multiple_found        EXCEPTION;
  PRAGMA                EXCEPTION_INIT(multiple_found, -24006);

BEGIN

   DBMS_AQADM.CREATE_NP_QUEUE(                        
           QUEUE_NAME      => 'srvqueue',                 
           MULTIPLE_CONSUMERS => TRUE);                    
EXCEPTION
  WHEN multiple_found THEN
    NULL;

END;
/

execute dbms_aqadm.start_queue ( queue_name              => 'SRVQUEUE');

REM Add subscribers to the multi-consumer queues 

DECLARE
  subscriber_exists     EXCEPTION;
  PRAGMA                EXCEPTION_INIT(subscriber_exists, -24034);
  subs                  SYS.AQ$_AGENT;

BEGIN

   subs := SYS.AQ$_AGENT('TAFTSM', NULL, NULL);
   DBMS_AQADM.ADD_SUBSCRIBER('srvqueue', subs);

EXCEPTION
  WHEN subscriber_exists THEN
    NULL;

END;
/

REM set the permissions for the queue

execute dbms_aqadm.grant_queue_privilege('DEQUEUE','SRVQUEUE','PUBLIC',TRUE);
