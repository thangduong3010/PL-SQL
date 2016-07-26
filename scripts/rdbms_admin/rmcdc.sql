Rem
Rem $Header: rmcdc.sql 29-jan-2002.09:49:28 wnorcott Exp $
Rem
Rem rmcdc.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      rmcdc.sql - ReMove Change Data Capture
Rem
Rem    DESCRIPTION
Rem      This file removes the Java triggers that are used by 
Rem      Change Data Capture, then removes CDC Java classes
Rem
Rem
Rem    NOTES
Rem
Rem      This is not safe to call if there are users of Change Data Capture
Rem      on this database instance.  Only call this if you want to remove
Rem      Change Data Capture classes and triggers.
Rem
Rem      If you later want to reinstall CDC, you must call initcdc.sql
Rem 
Rem      This must be called before rmjvm.sql if you want to remove Java
Rem      from an Oracle database.  Should be run as sys schema or at least
Rem      a user with privileges to remove objects from sys schema
Rem      If java is removed without calling rmcdc.sql first, all 
Rem      CREATE TABLE, ALTER TABLE, and DROP TABLE commands will fail with:
Rem
Rem ORA-00604: error occurred at recursive SQL level 1                              
Rem ORA-29540: class oracle/CDC/PublishApi does not exist                           
Rem ORA-06512: at "SYS.DBMS_CDC_PUBLISH", line 0                                    
Rem ORA-06512: at line 4                                  
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wnorcott    01/29/02 - Merged wnorcott_bug-2187432
Rem    wnorcott    01/21/02 - Created
Rem
DROP TRIGGER sys.cdc_alter_ctable_before;
DROP TRIGGER sys.cdc_create_ctable_after;
DROP TRIGGER sys.cdc_create_ctable_before ;
DROP TRIGGER sys.cdc_drop_ctable_before;
CALL sys.dbms_java.dropjava('-s rdbms/jlib/CDC.jar');