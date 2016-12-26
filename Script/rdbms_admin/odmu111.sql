Rem
Rem $Header: rdbms/admin/odmu111.sql /main/1 2009/02/06 14:26:04 xbarr Exp $
Rem
Rem odmu111.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      odmu111.sql - ODM upgrade script for 11.1 to 11.2 upgrade 
Rem
Rem    DESCRIPTION
Rem      This script updates ODM in the rdbms dba registry
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr       01/29/09 - Upgrade from 11.1 to 11.2
Rem    xbarr       01/29/09 - Created
Rem

Rem   PL/SQL API model upgrades (to be run as SYS only)
Rem
Rem   Migrate dmsys metadata and dmuser model to 11g
Rem   exec dmp_sys.upgrade_models('11.0.0');
Rem   /
Rem   commit;

Rem =====================================================================================
Rem Update ODM entry in DBA_REGISTRY for downgrade purpose
Rem
Rem In 11g, ODM component has been migrated from DMSYS to SYS. ODM is no longer a component.
Rem Once a user decides there is no need to perform a rdbms downgrade, DMSYS schema can be
Rem dropped from the upgraded database.  ODM entry will be removed from dba registry once
Rem DMSYS is dropped.
Rem =====================================================================================

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

BEGIN
   SYS.DBMS_REGISTRY.UPGRADED('ODM');
     EXCEPTION WHEN OTHERS THEN
        IF SQLCODE IN ( -39705 )
        THEN NULL;
        ELSE RAISE;
        END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'UPDATE SYS.REGISTRY$
                     SET VPROC=NULL
                     WHERE CID = ''ODM''
                     AND CNAME = ''Oracle Data Mining''';
  EXCEPTION WHEN OTHERS THEN
        IF SQLCODE IN ( -39705 )
         THEN NULL;
         ELSE RAISE;
         END IF;
END;
/

BEGIN
   SYS.DBMS_REGISTRY.VALID('ODM');
     EXCEPTION WHEN OTHERS THEN
        IF SQLCODE IN ( -39705 )
        THEN NULL;
        ELSE RAISE;
        END IF;
END;
/ 

commit;
