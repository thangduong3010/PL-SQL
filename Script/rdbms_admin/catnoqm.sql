Rem
Rem $Header: rdbms/admin/catnoqm.sql /st_rdbms_11.2.0/1 2011/02/07 03:47:42 dkoppar Exp $
Rem
Rem catnoqm.sql
Rem
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnoqm.sql - CATalog script for removing (NO) XDB
Rem
Rem    DESCRIPTION
Rem      this script drops the metadata created for SQL XML management
Rem      This scirpt must be invoked as sys. It is to be invoked as
Rem
Rem          @@catnoqm
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkoppar     02/06/11 - Backport dkoppar_bug-9892139 from main
Rem    yiru        03/25/09 - Add catnozxs.sql - XS clean up
Rem    badeoti     02/11/09 - 4557710: clean up
Rem    spetride    02/06/09 - lrg 3573827: install trigger to allow sequences
Rem    spetride    11/15/08 - xdb_installation_trigger: allow triggers
Rem    vkapoor     04/27/07 - lrg 2941734
Rem    vkapoor     04/09/07 - bug 5640175
Rem    mrafiq      12/19/06 - fix for bug 5711758
Rem    mrafiq      09/13/06 - fix for lrg 2356244: not dropping cursor temp
Rem                           tables
Rem    mrafiq      08/17/06 - drop xdb installation trigger
Rem    rtjoa       02/16/06 - drop nfsclient cleanup job 
Rem    pnath       11/10/04 - drop all objects created in installation 
Rem    spannala    01/03/02 - tables are not handled by xdb
Rem    spannala    01/02/02 - registry
Rem    spannala    12/20/01 - passing in the resource tablespace name
Rem    tsingh      11/17/01 - remove connection string
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    amanikut    02/13/01 - Creation
Rem
Rem  


execute dbms_registry.removing('XDB');

Rem XS clean up - Put it here suggested by Bosun
@@catnozxs.sql

Rem drop objects created to track object creation during XDB
Rem installation
drop trigger sys.xdb_installation_trigger;
drop trigger sys.dropped_xdb_instll_trigger;
drop table dropped_xdb_instll_tab;

Rem drop pi_trig before dropping user XDB. pi_trig moved to sys schema
drop trigger SYS.XDB_PI_TRIG;

drop user xdb cascade;

Rem During the un-installation of XDB, drop every object existing in 
Rem table xdb_installation_tab (explanation of objects inserted into 
Rem xdb_installation_tab is given in catqm.sql). Only certain object 
Rem types are handled. Objects of object type not handled below will 
Rem result in need to modify this block of code. 
DECLARE
   c NUMBER;
   CURSOR c1 IS SELECT unique owner, object_name, object_type FROM xdb_installation_tab;
BEGIN
   FOR item IN c1 LOOP
     IF (item.object_type = 'FUNCTION' or
            item.object_type = 'INDEX' or
            item.object_type = 'PACKAGE' or
            item.object_type = 'PACKAGE BODY' or
            item.object_type = 'PROCEDURE' or
            item.object_type = 'SYNONYM' or
            item.object_type = 'TABLE' or
            item.object_type = 'TABLESPACE' or
            item.object_type = 'TYPE' or
            item.object_type = 'VIEW' or
            item.object_type = 'USER' or
            item.object_type = 'TYPE BODY' or
            item.object_type = 'TRIGGER' or
            item.object_type = 'SEQUENCE')
     THEN
       BEGIN
         IF item.owner = 'PUBLIC' and item.object_type = 'SYNONYM' THEN
            execute immediate 'DROP PUBLIC SYNONYM "'||item.object_name||'"';
         ELSIF item.object_type = 'TABLE' THEN
            select count(*) into c from all_objects
            where owner = item.owner and object_name = item.object_name
            and object_type = item.object_type;

            --cursor temp tables are prefixed with SYS_TEMP and
            --do not show up in all_objects table
            IF c != 0 or substr(item.object_name,1,8) != 'SYS_TEMP' THEN
               execute immediate 'DROP '||item.object_type||' "'||item.owner||'"."'||item.object_name||'"';
            END IF;
         ELSE    
            execute immediate 'DROP '||item.object_type||' "'||item.owner||'"."'||item.object_name||'"';
         END IF;
       EXCEPTION
           when others then 
              null;
       END;
     ELSE
       raise_application_error(-20000, 'Drop of object in xdb_installation_tab of object '||item.owner||'.'||item.object_name||', type '||item.object_type||' is not handled.');
     END IF;  
   END LOOP;
END;
/

Rem Drop nfsclient cleanup job
DECLARE
  c number;
BEGIN
  select count(*) into c
  from ALL_SCHEDULER_JOBS
  where JOB_NAME = 'XMLDB_NFS_CLEANUP_JOB';
            
  if c != 0 then
    dbms_scheduler.drop_job('SYS.XMLDB_NFS_CLEANUP_JOB' , true);
  end if;

  select count(*) into c
  from ALL_SCHEDULER_JOB_CLASSES
  where JOB_CLASS_NAME = 'XMLDB_NFS_JOBCLASS';

  if c != 0 then
    dbms_scheduler.drop_job_class('SYS.XMLDB_NFS_JOBCLASS', TRUE);
  end if;
  execute immediate 'delete from noexp$ where name = :1' using 'XMLDB_NFS_JOBCLASS';
end;       
/             


Rem Drop accessory objects 
drop table xdb_installation_tab;

Rem Make XDB Dummy views
@@catxdbdv.sql
