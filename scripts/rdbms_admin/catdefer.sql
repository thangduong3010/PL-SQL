rem 
rem $Header: catdefer.sql 03-nov-2006.16:42:28 elu Exp $ 
rem 
Rem Copyright (c) 1992, 2006, Oracle. All rights reserved.  
Rem    NAME
Rem      catdefer.sql - catalog of deferred rpc queues
Rem    DESCRIPTION
Rem      catalog of deferred rpc queues
Rem      This file contains sql which creates the base tables
Rem      used to store deferred remote procedure calls for used in
Rem      transaction replication.
Rem      Tables:
Rem         defTran
Rem         defTranDest
Rem         defError
Rem         defCallDest
Rem         defDefaultDest
Rem         defCall
Rem         defSchedule
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Tables created in this file are owned by user system (not) sys
Rem      views are owned by sys.
Rem      The defcall view is implemented by the prvtdfri.plb script.
Rem      The defcalldest view is implemented by the catrepc.sql script.
Rem      The deftrandest view is reimplemented by the catrepc.sql script.
Rem      If the repcat tables are installed,
Rem      the catrepc.sql script should always be run after this script is run.
Rem 
Rem      Tables are created in catdefrt.sql.  All other objects created here
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem     elu        11/03/06  - modify for parallel upgrade
Rem     rburns     07/27/06  - separate queues 
Rem     lkaplan    05/05/05  - grant analyze any to allow lock_table_stats
Rem     gviswana   01/29/02  - CREATE OR REPLACE SYNONYM
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     liwong     10/23/00  - Add disabled_internally_set
Rem     narora     10/02/00  - code review comments
Rem     narora     09/29/00  - use decode for txn_count=0 in defschedule
Rem     narora     09/13/00  - add comments to new def$_destination columns
Rem     narora     08/30/00  - enhance defschedule
Rem     elu        09/12/00  - add catchup to defschedule
Rem     liwong     09/03/00  - add master db w/o quiesce: fixes
Rem     narora     07/11/00  - grant priviliges to v$ views
Rem     jingliu    07/29/97 -  change deflob.enq_tid to deferred_tran_id
Rem     jstamos    04/04/97 -  tighter AQ integration
Rem     liwong     03/07/97 -  merge 433785 manually
Rem     liwong     02/10/97 -  Comment out defcalldest, 
Rem                         -  modify deftrandest, add queue_batch to deftran
Rem     liwong     01/15/97 -  Modified delete statement for expact$ and added
Rem                         -  def$_aqcall and def$_aqerror
Rem     jstamos    01/03/97 -  add drop user cascade support
Rem     jstamos    12/23/96 -  comment on nclob_col
Rem     jstamos    11/21/96 -  nchar support
Rem     ato        11/08/96 -  remove catqueue.sql
Rem     sjain      11/06/96 -  Change defcall and deftran for backwards compata
Rem     sjain      11/05/96 -  Fix type in defcall
Rem     mluong     10/28/96 -  remove dup calls to build AQ package
Rem     sjain      10/17/96 -  AQ Conversion
Rem     sjain      10/15/96 -  aq conversion
Rem     sjain      10/14/96 -  Aq conversion
Rem     sjain      10/01/96 -  AQ conversion
Rem     sjain      09/04/96 -  AQ cont.
Rem     sjain      07/25/96 -  continue with the aq conversion
Rem     sjain      07/22/96 -  Convert to AQ
Rem     jstamos    06/12/96 -  LOB support for deferred RPCs
Rem     ldoo       05/09/96 -  New security model
Rem     mmonajje   05/21/96 -  Replace interval col name with interval#
Rem     ixhu       04/11/96 -  AQ support: add obj_type in expact$
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     jstamos    08/17/95 -  code review changes
Rem     jstamos    08/16/95 -  add comments to views
Rem     hasun      01/23/95 -  Modify views for Rep3 - Object Groups
Rem     dsdaniel   01/25/95 -  merge changes from branch 1.5.720.4
Rem     dsdaniel   01/23/95 -  merge changes from branch 1.1.710.11
Rem     dsdaniel   01/05/95 -  need extra at sign
Rem     dsdaniel   12/23/94 -  merge changes from branch 1.5.720.1-3
Rem     dsdaniel   12/21/94 -  merge changes from branch 1.1.710.8-10
Rem     dsdaniel   12/08/94 -  revise defcalldest, deftrandest views
Rem     dsdaniel   11/22/94 -  split out table creations
Rem     dsdaniel   11/18/94 -  deftran-ectomy, deftrandest-ectomy
Rem     dsdaniel   11/17/94 -  merge changes from branch 1.1.710.7
Rem     dsdaniel   11/09/94 -  defcalldest, deftrandest changes
Rem     dsdaniel   08/04/94 -  make it a cluster (again)
Rem     dsdaniel   08/04/94 -  create a version without the cluster
Rem     dsdaniel   08/03/94 -  eliminate ON DELETE CASCADE *again
Rem     dsdaniel   08/02/94 -  make it a cluster
Rem     dsdaniel   07/28/94 -  restore ON DELETE CASCADE
Rem     dsdaniel   07/27/94 -  eliminate ON DELETE CASCADE
Rem     dsdaniel   07/19/94 -  export support changes
Rem     rjenkins   03/22/94 -  merge changes from branch 1.1.710.4
Rem     rjenkins   01/19/94 -  merge changes from branch 1.1.710.3
Rem     dsdaniel   01/18/94 -  merge changes from branch 1.1.710.2
Rem     rjenkins   01/17/94 -  changing jq to job
Rem     rjenkins   12/17/93 -  creating job queue
Rem     dsdaniel   10/31/93 -  merge changes from branch 1.1.710.1
Rem     dsdaniel   10/28/93 -  deferred rpc dblink security
Rem                         -  also removed table drops, since shouldnt
Rem                         -  loose data on upgrade
Rem     dsdaniel   10/26/93 -  merge changes from branch 1.1.400.1
Rem     dsdaniel   10/10/93 -  Creation from dbmsdefr


-- Bug 979398: Have a before-row insert trigger on def$_propagator
-- which raises an exception if there is 1 or more rows in def$_propagator
GRANT EXECUTE ON dbms_sys_error TO system
/
CREATE OR REPLACE TRIGGER system.def$_propagator_trig
  BEFORE INSERT ON system.def$_propagator
DECLARE
  prop_count  NUMBER;
BEGIN
  SELECT count(*) into prop_count
    FROM system.def$_propagator;

  IF (prop_count > 0) THEN
    -- Raise duplicate propagator error
    sys.dbms_sys_error.raise_system_error(-23394);
  END IF;
END;
/

--
--
-- create def$_aqcall table. This contains one row for each deferred call.

-- bug 601972: split anonymous pl/sql blocks
DECLARE
queue_tab_exists  BINARY_INTEGER;
BEGIN
  -- dummy tables for def$_aqcall and def$_aqerror are created in 
  -- catdefrd.sql, since def$_aqcall and def$_aqerror are used in
  -- view and replicaiton package bodies. The real tables are created
  -- with AQ procedure call dbms_aqdm.create_queue_table, but
  -- package body dbms_aqdm is loaded after the replication views
  -- are created. The dummy tables are added so that the views and
  -- packages can be created. In catdefer.sql, the dummy views are
  -- dropped, and the real queue tables are created. Dependent views
  -- and packages are then recompiled.
  SELECT count(*) INTO queue_tab_exists
  FROM system.aq$_queue_tables t
  WHERE t.schema = 'SYSTEM' 
    AND t.name = 'DEF$_AQCALL';

  IF (0 = queue_tab_exists) THEN
    -- drop dummy table used for package compilation
    EXECUTE IMMEDIATE 'DROP TABLE SYSTEM.DEF$_AQCALL'; 

    dbms_aqadm.create_queue_table(QUEUE_TABLE => 'SYSTEM.DEF$_AQCALL', 
      QUEUE_PAYLOAD_TYPE => 'ANY',
      STORAGE_CLAUSE =>' lob (user_data) store as (pctversion 0)',
      COMPATIBLE=>'8.0');
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;           
END;
/

DECLARE
queue_exists  BINARY_INTEGER;
BEGIN
  select count(*) into queue_exists
  from system.aq$_queue_tables t, system.aq$_queues q
  WHERE q.table_objno = t.objno AND
  t.schema = 'SYSTEM' AND
  q.name = 'DEF$_AQCALL';

  IF queue_exists = 0 THEN
    BEGIN
      dbms_aqadm.create_queue(QUEUE_NAME => 'DEF$_AQCALL',
        QUEUE_TABLE => 'SYSTEM.DEF$_AQCALL', 
        DEPENDENCY_TRACKING => TRUE,
        COMMENT => 'Deferred RPC Queue');
    EXCEPTION
       WHEN OTHERS THEN
          IF SQLCODE = -24006 THEN NULL;
          ELSE RAISE;
          END IF;           
    END;

    BEGIN
      dbms_aqadm.start_queue(QUEUE_NAME => 'SYSTEM.DEF$_AQCALL',
        ENQUEUE => TRUE, DEQUEUE => TRUE);
    END;
  END IF;
END;
/

rem create an index on delivery order to speed things up
create index system.def$_tranorder on system.def$_aqcall(
 cscn, enq_tid)
/

BEGIN
  EXECUTE IMMEDIATE 'drop index system.aq$_def$_aqcall_i';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1418 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'drop index system.aq$_def$_aqcall_t';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1418 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

alter view system.aq$def$_aqcall compile
/


--  create the table def$_aqerror where the exceptions get logged. This
--  contains one row for each deferred call.

DECLARE
queue_tab_exists  BINARY_INTEGER;
BEGIN
  -- dummy tables for def$_aqcall and def$_aqerror are created in 
  -- catdefrd.sql, since def$_aqcall and def$_aqerror are used in
  -- view and replicaiton package bodies. The real tables are created
  -- with AQ procedure call dbms_aqdm.create_queue_table, but
  -- package body dbms_aqdm is loaded after the replication views
  -- are created. The dummy tables are added so that the views and
  -- packages can be created. In catdefer.sql, the dummy views are
  -- dropped, and the real queue tables are created. Dependent views
  -- and packages are then recompiled.
  SELECT count(*) INTO queue_tab_exists
  FROM system.aq$_queue_tables t
  WHERE t.schema = 'SYSTEM' 
    AND t.name = 'DEF$_AQERROR';

  IF (0 = queue_tab_exists) THEN
    -- drop dummy table used for package compilation
    EXECUTE IMMEDIATE 'DROP TABLE SYSTEM.DEF$_AQERROR'; 

    dbms_aqadm.create_queue_table(QUEUE_TABLE => 'SYSTEM.DEF$_AQERROR',
      QUEUE_PAYLOAD_TYPE => 'ANY',
      STORAGE_CLAUSE =>' lob (user_data) store as (pctversion 0)',
      COMPATIBLE=>'8.0');
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;           
END;
/

DECLARE
queue_exists  BINARY_INTEGER;
BEGIN
  select count(*) into queue_exists
  from system.aq$_queue_tables t, system.aq$_queues q
  WHERE q.table_objno = t.objno AND
  t.schema = 'SYSTEM' AND
  q.name = 'DEF$_AQERROR';

  IF queue_exists = 0 THEN
    BEGIN
      dbms_aqadm.create_queue(QUEUE_NAME => 'DEF$_AQERROR',
        QUEUE_TABLE => 'SYSTEM.DEF$_AQERROR', 
        DEPENDENCY_TRACKING => TRUE,
        COMMENT => 'Error Queue for Deferred RPCs');
    EXCEPTION
       WHEN OTHERS THEN
          IF SQLCODE = -24006 THEN NULL;
          ELSE RAISE;
          END IF;           
    END;

    BEGIN
      dbms_aqadm.start_queue(QUEUE_NAMe => 'SYSTEM.DEF$_AQERROR',
        ENQUEUE => TRUE, DEQUEUE => TRUE);
    END;
  END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'drop index system.aq$_def$_aqerror_i';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1418 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'drop index system.aq$_def$_aqerror_t';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1418 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

alter view system.aq$def$_aqerror compile
/

CREATE OR REPLACE PUBLIC SYNONYM deftran FOR deftran
/


REM Set up export actions for deferred rpc tables.
rem delete existing export data

DELETE FROM expact$ WHERE name like 'DEF$_%' 
  AND func_package = 'DBMS_DEFER_IMPORT_INTERNAL'
/

insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_AQERROR','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/                                       
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_AQCALL','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_CALLDEST','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_ERROR','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_DEFAULTDEST','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_DESTINATION','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
COMMIT
/

DELETE FROM sys.duc$
  WHERE owner = 'SYS' AND pack = 'DBMS_DEFER_IMPORT_INTERNAL'
    AND proc = 'DROP_PROPAGATOR_CASCADE' AND operation# = 1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES('SYS', 'DBMS_DEFER_IMPORT_INTERNAL', 'DROP_PROPAGATOR_CASCADE', 1, 1,
         'Remove propagator if necessary')
/
COMMIT
/

-- Create synonyms for replication dynamic performance views and
-- grant select_catalog_role access to these views
create or replace view gv_$replqueue as select * from gv$replqueue
/
create or replace public synonym gv$replqueue for gv_$replqueue
/
grant select on gv_$replqueue to select_catalog_role
/

create or replace view v_$replqueue as select * from v$replqueue
/
create or replace public synonym v$replqueue for v_$replqueue
/
grant select on v_$replqueue to select_catalog_role
/

create or replace view gv_$replprop as select * from gv$replprop
/
create or replace public synonym gv$replprop for gv_$replprop
/
grant select on gv_$replprop to select_catalog_role
/

create or replace view v_$replprop as select * from v$replprop
/
create or replace public synonym v$replprop for v_$replprop
/
grant select on v_$replprop to select_catalog_role
/

create or replace view gv_$mvrefresh as select * from gv$mvrefresh
/
create or replace public synonym gv$mvrefresh for gv_$mvrefresh
/
grant select on gv_$mvrefresh to select_catalog_role
/

create or replace view v_$mvrefresh as select * from v$mvrefresh
/
create or replace public synonym v$mvrefresh for v_$mvrefresh
/
grant select on v_$mvrefresh to select_catalog_role
/
