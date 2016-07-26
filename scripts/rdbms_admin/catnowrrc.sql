Rem
Rem $Header: rdbms/admin/catnowrrc.sql /main/3 2008/08/22 10:50:37 rcolle Exp $
Rem
Rem catnowrrc.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnowrrc.sql - Catalog script to delete the 
Rem                      Workload Capture schema
Rem
Rem    DESCRIPTION
Rem      Undo file for all objects created in catwrrtbc.sql
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rcolle      05/08/08 - drop WRR$_CAPTURE_UC_GRAPH
Rem    veeve       07/13/06 - stop capture in catnowrr.sql
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       01/25/06 - Created
Rem

Rem =========================================================
Rem Dropping the Workload Capture Tables
Rem =========================================================
Rem

delete from PROPS$
where name = 'WORKLOAD_CAPTURE_MODE'
/
commit
/

drop table WRR$_CAPTURES
/

drop sequence WRR$_CAPTURE_ID
/

drop table WRR$_CAPTURE_STATS
/

drop table WRR$_CAPTURE_UC_GRAPH
/
