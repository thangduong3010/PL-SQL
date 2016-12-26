Rem
Rem $Header: rdbms/admin/odmpatch.sql /st_rdbms_11.2.0/1 2011/05/03 09:34:10 xbarr Exp $ odmpatch.sql
Rem
Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      odmpatch.sql
Rem
Rem    DESCRIPTION
Rem      Script for Data Mining patch loading 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS. After running the script, 
Rem      ODM should be at 11.2.0.X patch release level   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr    04/29/11 - update ODM in dba registry 
Rem    xbarr    01/12/05 - remove version info for odm registry
Rem    xbarr    02/03/05 - updated banner in registry
Rem    xbarr    01/27/05 - updated for 10.2 patchset 
Rem    xbarr    10/29/04 - move validation proc to SYS 
Rem    xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem    amozes   06/23/04 - remove hard tabs
Rem    xbarr    03/25/04 - updated for 10.1.0.3 ODM patch release 
Rem    xbarr    12/22/03 - remove dbms_java.set_output 
Rem    fcay     06/23/03 - Update copyright notice
Rem    xbarr    05/30/03 - updated for ODM 9204 patch release 
Rem    xbarr    02/14/03 - xbarr_txn106309
Rem    xbarr    02/12/03 - Creation
Rem
Rem #########################################################################

Rem =====================================================================================
Rem In 11g, ODM component has been migrated from DMSYS to SYS. ODM is no longer a component.
Rem Once a user decides there is no need to perform a rdbms downgrade, DMSYS schema can be
Rem dropped from the upgraded database.  ODM entry will be removed from dba registry once
Rem DMSYS is dropped.
Rem
Rem If DMSYS was not dropped in 11.2.0.1 after being upgraded from 10.2, and the database
Rem is upgrading to 11.2.0.X patchset, then the registry will be updated by this script
Rem for ODM.
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

COMMIT;
