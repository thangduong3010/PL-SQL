Rem
Rem $Header: rdbms/admin/catupend.sql /st_rdbms_11.2.0/3 2012/06/26 11:49:09 jerrede Exp $
Rem
Rem catupend.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catupend.sql - CATalog UPgrade END
Rem
Rem    DESCRIPTION
Rem      Final scripts for the Complete upgrade
Rem
Rem    NOTES
Rem      Invoked by catupgrd.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     06/21/12 - Backport jerrede_bug-13719893 from main
Rem    mdietric    05/18/12 - Backport mdietric_bug-11901407 from main
Rem    apfwkr      03/02/12 - Backport dvoss_bug-13719292 from main
Rem    cmlim       03/02/10 - bug 9412562: add reminder to run DBMS_DST after
Rem                           db upgrade
Rem    cdilling    08/17/09 - don't invoke utlmmig.sql for 11.2 patch upgrades
Rem    nlee        04/02/09 - Fix for bug 8289601.
Rem    yiru        02/28/09 - fix lrg problem: 3795747
Rem    srtata      02/03/09 - validate LBAC_EVENTS : reupgrade issue
Rem    achoi       04/03/08 - run utlmmig.sql for 11.2
Rem    rburns      07/11/07 - no utlmmig for patch upgrade
Rem    cdilling    04/23/07 - add end timestamp for gathering stats
Rem    rburns      02/17/07 - remove edition column if it exists (XE database)
Rem    achoi       11/06/06 - add utlmmig to add index to bootstrap object
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem


Rem =====================================================================
Rem Recreate XS component - V$XS_SESSION view if it is invalid
Rem Used when customers rerun catupgrd mutiple times
Rem =====================================================================

DECLARE
  stat VARCHAR(4000);
BEGIN
  SELECT status into stat FROM DBA_OBJECTS  
  WHERE object_name = 'V$XS_SESSION' and owner='SYS' ;
  IF stat = 'INVALID' THEN
    execute immediate 'create or replace view v$xs_session as
         select *
           from xs$sessions with read only'; 
    execute immediate 'create or replace public synonym V$XS_SESSION 
              for v$xs_session';
    execute immediate 'grant select on V$XS_SESSION to DBA';
  END IF; 
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
/

Rem =====================================================================
Rem Set XE edition to NULL in registry$ table (AFTER all component upgrades)
Rem =====================================================================

BEGIN
   EXECUTE IMMEDIATE 'update registry$ set edition = NULL';
EXCEPTION
   WHEN OTHERS THEN NULL;   -- ignore any errors since column may not exist
END;
/

Rem =====================================================================
Rem Recompile DDL triggers
Rem =====================================================================

@@utlrdt

Rem ======================================================================
Rem Recompile all views
Rem ======================================================================

@@utlrvw

Rem ====================================================================
Rem Validate OLS package on which OLS logon and DDL triggers depend.
Rem If not validated these triggers fire with invalid package state
Rem and cause issues in post upgrade mode. 
Rem =====================================================================

DECLARE
  objid NUMBER;
BEGIN
  IF dbms_registry.is_loaded('OLS') IS NOT NULL THEN
    BEGIN
    SELECT object_id into objid from dba_objects WHERE
           object_name='LBAC_EVENTS' AND status = 'INVALID' 
           AND object_type='PACKAGE BODY';
    dbms_utility.validate(objid);
    EXCEPTION
    WHEN OTHERS THEN
      RETURN;
    END;
  END IF;
END;
/

DOC
#######################################################################
#######################################################################

   The above PL/SQL lists the SERVER components in the upgraded
   database, along with their version and status at the completion of
   the component upgrade.  Any error messages generated during the 
   component upgrade are also listed.

   Please review the status and version columns and check the details
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the current version,
   consult the Oracle Database Upgrade Guide for troubleshooting 
   recommendations.

#######################################################################
#######################################################################
#
Rem =====================================================================
Rem Index Creation for Bootstrap Objects. utlmmig will shutdown the
Rem database.
Rem DB must be restarted after this script.
Rem For 11.2 patch upgrades, utlmmig.sql is not run, but the database
Rem is shutdown via catupshd.sql.
Rem =====================================================================

SELECT version_script FROM DUAL; 

Rem Display start time of utlmmig 
SELECT sys.dbms_registry_sys.time_stamp_comp_display('UTLMMIG_BG') AS
       timestamp FROM DUAL;

COLUMN mig_name NEW_VALUE mig_file NOPRINT;
SELECT version_script AS mig_name FROM DUAL;

VARIABLE utl_name VARCHAR2(50)
COLUMN :utl_name NEW_VALUE utl_file NOPRINT;

BEGIN
   IF '&&mig_file' = '1102000' THEN
      :utl_name := 'catupshd.sql';
   ELSE
      :utl_name := 'utlmmig.sql';
   END IF;
END;
/
drop version_script;   -- no longer needed

SELECT :utl_name FROM DUAL;
@@&utl_file

DOC
#######################################################################
#######################################################################
 
   The above sql script is the final step of the upgrade. Please
   review any errors in the spool log file. If there are any errors in
   the spool file, consult the Oracle Database Upgrade Guide for
   troubleshooting recommendations.
 
   Next restart for normal operation, and then run utlrp.sql to
   recompile any invalid application objects.

   If the source database had an older time zone version prior to
   upgrade, then please run the DBMS_DST package.  DBMS_DST will upgrade
   TIMESTAMP WITH TIME ZONE data to use the latest time zone file shipped
   with Oracle.
 
#######################################################################
#######################################################################
#
