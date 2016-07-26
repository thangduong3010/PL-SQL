Rem Copyright (c) 2003, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlprp.sql - Recompile invalid objects in the database
Rem
Rem    DESCRIPTION
Rem      This script recompiles invalid objects in the database.
Rem
Rem      This script is typically used to recompile invalid objects
Rem      remaining at the end of a database upgrade or downgrade. 
Rem 
Rem      Although invalid objects are automatically recompiled on demand,
Rem      running this script ahead of time will reduce or eliminate
Rem      latencies due to automatic recompilation.
Rem
Rem      This script is a wrapper based on the UTL_RECOMP package. 
Rem      UTL_RECOMP provides a more general recompilation interface,
Rem      including options to recompile objects in a single schema. Please
Rem      see the documentation for package UTL_RECOMP for more details.
Rem
Rem    INPUTS
Rem      The degree of parallelism for recompilation can be controlled by
Rem      providing a parameter to this script. If this parameter is 0 or
Rem      NULL, UTL_RECOMP will automatically determine the appropriate
Rem      level of parallelism based on Oracle parameters cpu_count and
Rem      parallel_threads_per_cpu. If the parameter is 1, sequential
Rem      recompilation is used. Please see the documentation for package
Rem      UTL_RECOMP for more details.
Rem
Rem    NOTES
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/03/12 - Backport apfwkr_blr_backport_13059165_11.2.0.3.0
Rem                           from st_rdbms_11.2.0
Rem    cdilling    05/15/10 - fix bug 9712478 - call local enquote_name
Rem    anighosh    02/19/09 - #(8264899): re-enabling of function based indexes
Rem                           not needed.
Rem    cdilling    07/21/08 - check bitand for functional index - bug 7243270
Rem    cdilling    01/21/08 - add support for ORA-30552
Rem    cdilling    08/27/07 - check disabled indexes only
Rem    cdilling    05/22/07 - add support for ORA-38301
Rem    cdilling    02/19/07 - 5530085 - renable invalid indexes
Rem    rburns      03/17/05 - use dbms_registry_sys 
Rem    gviswana    02/07/05 - Post-compilation diagnostics 
Rem    gviswana    09/09/04 - Auto tuning and diagnosability
Rem    rburns      09/20/04 - fix validate_components 
Rem    gviswana    12/09/03 - Move functional-index re-enable here 
Rem    gviswana    06/04/03 - gviswana_bug-2814808
Rem    gviswana    05/28/03 - Created
Rem

SET VERIFY OFF;

SELECT dbms_registry_sys.time_stamp('utlrp_bgn') as timestamp from dual;

DOC
   The following PL/SQL block invokes UTL_RECOMP to recompile invalid
   objects in the database. Recompilation time is proportional to the
   number of invalid objects in the database, so this command may take
   a long time to execute on a database with a large number of invalid
   objects.
  
   Use the following queries to track recompilation progress:
   
   1. Query returning the number of invalid objects remaining. This
      number should decrease with time.
         SELECT COUNT(*) FROM obj$ WHERE status IN (4, 5, 6);
   
   2. Query returning the number of objects compiled so far. This number
      should increase with time.
         SELECT COUNT(*) FROM UTL_RECOMP_COMPILED;
  
   This script automatically chooses serial or parallel recompilation
   based on the number of CPUs available (parameter cpu_count) multiplied
   by the number of threads per CPU (parameter parallel_threads_per_cpu).
   On RAC, this number is added across all RAC nodes.
  
   UTL_RECOMP uses DBMS_SCHEDULER to create jobs for parallel
   recompilation. Jobs are created without instance affinity so that they
   can migrate across RAC nodes. Use the following queries to verify
   whether UTL_RECOMP jobs are being created and run correctly:
  
   1. Query showing jobs created by UTL_RECOMP
         SELECT job_name FROM dba_scheduler_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
  
   2. Query showing UTL_RECOMP jobs that are running
         SELECT job_name FROM dba_scheduler_running_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
#

DECLARE
   threads pls_integer := &&1;
BEGIN
   utl_recomp.recomp_parallel(threads);
END;
/

SELECT dbms_registry_sys.time_stamp('utlrp_end') as timestamp from dual;

Rem #(8264899): The code to Re-enable functional indexes, which used to exist
Rem here, is no longer needed.

DOC
 The following query reports the number of objects that have compiled
 with errors.

 If the number is higher than expected, please examine the error
 messages reported with each object (using SHOW ERRORS) to see if they
 point to system misconfiguration or resource constraints that must be
 fixed before attempting to recompile these objects.
#
select COUNT(DISTINCT(obj#)) "OBJECTS WITH ERRORS" from utl_recomp_errors;


DOC
 The following query reports the number of errors caught during
 recompilation. If this number is non-zero, please query the error
 messages in the table UTL_RECOMP_ERRORS to see if any of these errors
 are due to misconfiguration or resource constraints that must be
 fixed before objects can compile successfully.
#
select COUNT(*) "ERRORS DURING RECOMPILATION" from utl_recomp_errors;


Rem
Rem Declare function local_enquote_name to pass FALSE 
Rem into underlying dbms_assert.enquote_name function
Rem 
CREATE OR REPLACE FUNCTION local_enquote_name (str varchar2)
 return varchar2 is
   begin
        return dbms_assert.enquote_name(str, FALSE);
   end local_enquote_name; 
/
Rem
Rem If sys.enabled$index table exists, then re-enable
Rem list of functional indexes that were enabled prior to upgrade
Rem The table sys.enabled$index table is created in catupstr.sql 
Rem
SET serveroutput on
DECLARE
   TYPE tab_char IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
   commands tab_char;
   p_null   CHAR(1);
   p_schemaname  VARCHAR2(30);
   p_indexname   VARCHAR2(30);
   rebuild_idx_msg BOOLEAN := FALSE;
   non_existent_index exception;
   recycle_bin_objs exception;
   cannot_change_obj exception;
   no_such_table  exception;
   pragma exception_init(non_existent_index, -1418);
   pragma exception_init(recycle_bin_objs, -38301);
   pragma exception_init(cannot_change_obj, -30552);
   pragma exception_init(no_such_table, -942);
   type cursor_t IS REF CURSOR;
   reg_cursor   cursor_t;

BEGIN
   -- Check for existence of the table marking disabled functional indices

   SELECT NULL INTO p_null FROM DBA_OBJECTS
   WHERE owner = 'SYS' and object_name = 'ENABLED$INDEXES' and
            object_type = 'TABLE' and rownum <=1;
 
      -- Select indices to be re-enabled
      EXECUTE IMMEDIATE q'+
         SELECT 'ALTER INDEX ' || 
                 local_enquote_name(e.schemaname) || '.' || 
                 local_enquote_name(e.indexname) || ' ENABLE'
            FROM   enabled$indexes e, ind$ i
            WHERE  e.objnum = i.obj# AND bitand(i.flags, 1024) != 0 AND
                   bitand(i.property, 16) != 0+'
      BULK COLLECT INTO commands;

      IF (commands.count() > 0) THEN
         FOR i IN 1 .. commands.count() LOOP
            BEGIN
            EXECUTE IMMEDIATE commands(i);
            EXCEPTION
               WHEN NON_EXISTENT_INDEX THEN NULL;
               WHEN RECYCLE_BIN_OBJS THEN NULL;
               WHEN CANNOT_CHANGE_OBJ THEN rebuild_idx_msg := TRUE;
            END;
         END LOOP;     
      END IF;
      
      -- Output any indexes in the table that could not be re-enabled
      -- due to ORA-30552 during ALTER INDEX...ENBLE command

      IF  rebuild_idx_msg THEN
       BEGIN
         DBMS_OUTPUT.PUT_LINE
('The following indexes could not be re-enabled and may need to be rebuilt:');

         OPEN reg_cursor FOR  
             'SELECT e.schemaname, e.indexname
              FROM   enabled$indexes e, ind$ i 
              WHERE  e.objnum = i.obj# AND bitand(i.flags, 1024) != 0';

         LOOP
           FETCH reg_cursor INTO p_schemaname, p_indexname;
           EXIT WHEN reg_cursor%NOTFOUND;
           DBMS_OUTPUT.PUT_LINE
              ('.... INDEX ' || p_schemaname || '.' || p_indexname);
         END LOOP;
         CLOSE reg_cursor;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN CLOSE reg_cursor;
            WHEN NO_SUCH_TABLE THEN CLOSE reg_cursor;
            WHEN OTHERS THEN CLOSE reg_cursor; raise; 
       END;

      END IF;

      EXECUTE IMMEDIATE 'DROP TABLE sys.enabled$indexes';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;

END;
/

DROP function local_enquote_name;

Rem =====================================================================
Rem Run component validation procedure
Rem =====================================================================

EXECUTE dbms_registry_sys.validate_components; 
SET serveroutput off

