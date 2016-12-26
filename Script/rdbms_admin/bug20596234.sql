Rem
Rem $Header: rdbms/admin/bug20596234.sql fball_extra_22502456_stuff/1 2016/03/04 05:37:30 fball Exp $
Rem
Rem bug20596234.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      bug20596234.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      drops sys.aw_drop_trg before running dbmsaw.sql to prevent ORA-04098
Rem      COMPILEs required after changes to DBMS_AW package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/bug20596234.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/bug20596234.sql
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ghicks      02/22/16 - Added drop trigger
Rem    ghicks      02/16/16 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

BEGIN  
  EXECUTE IMMEDIATE 'DROP TRIGGER sys.aw_drop_trg';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

@@?/rdbms/admin/dbmsaw.sql
@@?/rdbms/admin/prvtaw.plb

ALTER PACKAGE sys.dbms_aw_exp COMPILE;
ALTER PACKAGE sys.dbms_cube_log COMPILE;
ALTER PROCEDURE sys.aps_validate COMPILE;
ALTER VIEW sys.dba_aw_prop COMPILE;
ALTER VIEW sys.user_aw_prop COMPILE;
ALTER VIEW sys.all_aw_prop COMPILE;
ALTER PUBLIC SYNONYM dba_aw_prop COMPILE;
ALTER PUBLIC SYNONYM user_aw_prop COMPILE;
ALTER PUBLIC SYNONYM all_aw_prop COMPILE;
ALTER PACKAGE sys.dbms_cube COMPILE;
ALTER PACKAGE sys.dbms_cube_exp COMPILE;
ALTER PACKAGE sys.dbms_cube_util COMPILE;
ALTER PACKAGE olapsys.cwm2_olap_aw_awutil COMPILE;
ALTER PACKAGE olapsys.cwm2_olap_olapapi_enable COMPILE;
ALTER PACKAGE olapsys.dbms_awm COMPILE;

