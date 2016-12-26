Rem
Rem $Header: execrep.sql 03-nov-2006.20:10:23 elu Exp $
Rem
Rem execrep.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execrep.sql - EXEC REPlication
Rem
Rem    DESCRIPTION
Rem      PL/SQL blocks for replication executed after package bodies 
Rem      are loaded.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    elu         10/23/06 - Created
Rem

Rem Objects for deferred RPC and Materialized Views
Rem Dependencies on queues and jobs; required for Replication
@@catdefer

Rem Recompile views, synonyms and packages that were dependent
Rem on the dummy def$_aqcall and def$_aqerror tables (which were
Rem dropped and recreated in catdefer.sql).

alter view deftrandest compile
/
alter public synonym deftrandest compile
/
alter view defcalldest compile
/
alter public synonym defcalldest compile
/
alter view DEFCALL compile
/
alter public synonym DEFCALL compile
/
alter synonym DEF$_AQCALL compile
/
alter view "_DEFTRANDEST" compile
/
alter package DBMS_SNAPSHOT  compile
/
alter package DBMS_REPCAT_UTL compile
/
alter package DBMS_REPCAT_SNA_UTL compile
/
alter package DBMS_REPCAT_MAS compile
/
alter package DBMS_DEFER_QUERY compile
/
alter package DBMS_DEFER_SYS_PART1 compile
/
alter package DBMS_DEFER_SYS compile
/
alter package DBMS_ASYNCRPC_PUSH compile
/


begin
 system.ora$_sys_rep_auth;
end;  
/


Rem From catreps.sql
Rem Set up export actions for RepAPI tables:
Rem sys.snap_site$ table and system.def$_pushed_transactions

DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_SITES'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REFRESH_EXP_SITES', 'SYS', 2, 1)
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_LWM'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REFRESH_EXP_LWM', 'SYS', 2, 2)
/
COMMIT
/



Rem From catrepm.sql

Rem Added to support dbms_repcat.wait_master_log
GRANT EXECUTE ON dbms_alert TO system
/
CREATE OR REPLACE TRIGGER system.repcatlogtrig
AFTER UPDATE OR DELETE ON system.repcat$_repcatlog
BEGIN
  sys.dbms_alert.signal('repcatlog_alert', '');
END;
/

Rem  support sanity check upon import of system.repcat$_repschema
DELETE FROM sys.expact$
  WHERE owner='SYSTEM' AND name='REPCAT$_REPSCHEMA'
    AND func_proc='REPCAT_IMPORT_REPSCHEMA_STRING'
/
INSERT INTO sys.expact$(owner, name, func_schema, func_package, func_proc,
                        code, callorder, obj_type)
  VALUES('SYSTEM', 'REPCAT$_REPSCHEMA', 'SYS', 'DBMS_REPCAT',
         'REPCAT_IMPORT_REPSCHEMA_STRING', 2, 1, 2)
/
GRANT EXECUTE ON dbms_repcat TO SYSTEM
/

Rem support DROP USER CASCADE
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_REPCAT_UTL' 
  AND proc='DROP_USER_REPSCHEMA' AND operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS', 'DBMS_REPCAT_UTL', 'DROP_USER_REPSCHEMA', 1, 1,
          'Drop any local repschema for this user')
/
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='DBMS_REPCAT_RGT_UTL' 
  and proc='DROP_USER_TEMPLATES' and operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS','DBMS_REPCAT_RGT_UTL','DROP_USER_TEMPLATES', 1, 1,
          'Run during drop user cascade to drop all user template info')
/
commit
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_RGT_EXP'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REPCAT_RGT_EXP', 'SYS', 2, 2)
/
COMMIT
/

Rem system-level
Rem This should be one of the first system-level actions to be executed,
Rem so set level# to 1.
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 1
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_REPCAT_EXP', 'SYS', 1, 1)
/
COMMIT
/

Rem schema-level
Rem This should be one of the last schema-level actions to be executed,
Rem so set level# to 5000
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 2
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_REPCAT_EXP', 'SYS', 2, 5000)
/
COMMIT
/
