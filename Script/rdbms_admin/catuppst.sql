Rem
Rem $Header: rdbms/admin/catuppst.sql /st_rdbms_11.2.0/3 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem catuppst.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catuppst.sql - CATalog UPgrade PoST-upgrade actions
Rem
Rem    DESCRIPTION
Rem      This post-upgrade script performs remaining upgrade actions that
Rem      don't require that the database be open in UPGRADE mode.
Rem      Automatically apply the latest PSU.
Rem
Rem    NOTES
Rem      You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: combine settings into same
Rem                           errorlogging stmt
Rem    surman      04/01/13 - Backport surman_bug-16094163 from main
Rem    cdilling    07/21/10 - add call to catbundle.sql for bug 9925339
Rem    srtata      12/16/08 - run olstrig.sql when upgrading from prior to 10.2 
Rem    srtata      10/15/08 - put back olstrig.sql as we found it cannot be run
Rem                           as part of upgrade
Rem    srtata      02/26/08 - move olstrig.sql to olsdbmig.sql
Rem    ushaft      02/05/07 - post upgrade for ADDM tasks.
Rem    cdilling    12/06/06 - add support for error logging
Rem    rburns      11/10/06 - post upgrade actions
Rem    rburns      11/10/06 - Created
Rem


Rem *********************************************************************
Rem BEGIN catuppst.sql
Rem *********************************************************************
Rem Set identifier to POSTUP for errorlogging

SET ERRORLOGGING ON TABLE sys.registry$error IDENTIFIER 'POSTUP';

SELECT dbms_registry_sys.time_stamp('postup_bgn') as timestamp from dual;

Rem =======================================================================
Rem Upgrade AWR Baseline information
Rem =======================================================================

@@awrblmig.sql

Rem =======================================================================
Rem Upgrade ADDM task metadata
Rem =======================================================================

@@addmtmig.sql

Rem =======================================================================
Rem If OLS in the database, run olstrig.sql to updated OLS policies
Rem =======================================================================

COLUMN :ols_name NEW_VALUE ols_file NOPRINT;
VARIABLE ols_name VARCHAR2(30)
DECLARE
 prev_version VARCHAR2(30);
BEGIN
   IF dbms_registry.is_loaded('OLS') IS NOT NULL THEN
       select prv_version into prev_version from sys.registry$
          where cid='OLS';
       IF (substr(prev_version,1,5)='9.2.0') OR
           (substr(prev_version,1,6)='10.1.0') THEN
        :ols_name := '@olstrig.sql';   -- OLS installed in DB
       ELSE
        :ols_name := dbms_registry.nothing_script;   -- 10.2 or above
       END IF;
   ELSE
      :ols_name := dbms_registry.nothing_script;   -- No OLS
   END IF;
END;
/
SELECT :ols_name FROM DUAL;
@&ols_file


SELECT dbms_registry_sys.time_stamp('postup_end') as timestamp from dual;

Rem Set errorlogging off
SET ERRORLOGGING OFF;

Rem =======================================================================
Rem Begin of catbundle.sql
Rem =======================================================================

Rem Call catbundleapply.sql to apply the correct script
@@catbundleapply.sql

Rem *********************************************************************
Rem END catuppst.sql
Rem *********************************************************************

