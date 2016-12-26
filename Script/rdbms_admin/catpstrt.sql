Rem
Rem $Header: catpstrt.sql 28-sep-2007.15:53:25 sylin Exp $
Rem
Rem catpstrt.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catpstrt.sql - CATProc STaRT script
Rem
Rem    DESCRIPTION
Rem      This script runs the initial startup code to prepare
Rem      to run the rest of the scripts in catproc.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It is run single process by catctl.pl.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       08/13/07 - Add utlident.sql
Rem    elu         11/03/06 - add prvthssq
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/25/06 - add BYTE semantics
Rem    rburns      08/28/06 - more prereqs
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

WHENEVER SQLERROR EXIT;         
 
DOC 
###################################################################### 
###################################################################### 
    The following PL/SQL block will cause an ORA-20000 error and
    terminate the current SQLPLUS session if the user is not SYS. 
    Disconnect and reconnect with AS SYSDBA. 
###################################################################### 
###################################################################### 
# 
 
DECLARE
  p_user VARCHAR2(30);
BEGIN
    SELECT USER INTO p_user FROM DUAL; 
    IF p_user != 'SYS' THEN 
        RAISE_APPLICATION_ERROR (-20000, 
           'This script must be run AS SYSDBA'); 
    END IF; 
END;
/

Rem Run catproc session initialization script
@@catpses.sql

WHENEVER SQLERROR CONTINUE;         


Rem indicate that catproc scripts are loading
BEGIN
   dbms_registry.loading ('CATPROC','Oracle Database Packages and Types',
              'dbms_registry_sys.validate_catproc');
END;
/

Rem basic procedural views (should be in catalog?)
@@catprc
@@catjobq

Rem Remote views
@@catrpc

Rem Setup for pl/sql
@@dbmsstdx
@@utlident
@@plitblm
@@plspur
@@pipidl
rem granting execute on the package created in pipidl.sql 
rem to execute_catalog_role...
grant execute on pidl to execute_catalog_role
/
@@pidian
rem granting execute on the package created in pidian.sql 
rem to execute_catalog_role...
grant execute on diana to execute_catalog_role
/
@@diutil
@@pistub
@@prvtpckl.plb

-- catsrvmgr.sql is dependent on this
@@catspace

-- prvtcmpl.plb is dependent on this
@@dbmslob.sql

-- utlcomp is dependent on this
@@prvtcmpl.plb

-- utlsmtp is dependent on this
@@utltcp

-- utlurl is dependent on this
@@utlhttp

-- dbms_transaction_internal_sys spec in this file
@@prvthtxn.plb

-- dbms_ddl is dependent on this
@@dbmssql

-- dbms_sys_sql - dbms_repcat_decl is dependent on this
@@prvthssq.plb

-- contains dbms_output (odci procedures dependent on this)
@@dbmsotpt

-- creates a role needed by prvtlsis.plb and prvtlsss.plb package specs
@@dbmslsby.sql

Rem dbms_session - used in package specs
@@dbmssess

Rem dbms_lock - used in package specs
@@dbmslock

Rem utl_file - used in package specs
@@utlfile
