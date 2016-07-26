Rem
Rem $Header: ovm/src/server/ovmrelod.sql /st_ovm_11.2.0/3 2012/03/14 17:15:01 bspeckha Exp $
Rem
Rem ovmrelod.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ovmrelod.sql - Reload script
Rem
Rem    DESCRIPTION
Rem          The "patch" script is used to apply bug fixes to the component. 
Rem          It is run in the context of catpatch.sql, after the RDBMS catalog.sql 
Rem          and catproc.sql scripts are run. It is run with a special EVENT set 
Rem          which causes CREATE OR REPLACE statements to only recompile objects 
Rem          if the new source is different than the source stored in the database. 
Rem          Tables, types, and public interfaces should not be changed by patch scripts. 
Rem          
Rem                 ALTER SESSION SET CURRENT_SCHEMA = MYCSYS;
Rem                 EXECUTE dbms_registry.loading('MYC','My Component Name');
Rem                 Rem Only reload views, private PL/SQL types and packages, and type/package bodies
Rem                 @@mycpvs.plb
Rem                 @@mycview.sql
Rem                 @@myctyb.plb
Rem                 @@mycplb.plb
Rem                  
Rem                 Rem Reload classes if Java is in the database
Rem                 COLUMN file_name NEW_VALUE comp_file NOPRINT;
Rem                 SELECT dbms_registry.script('JAVAVM','@initmyc.sql') AS file_name FROM DUAL;
Rem                 @&comp_file
Rem                 EXECUTE dbms_registry.loaded('MYC'); /* uses RDBMS release version number */
Rem                 EXECUTE myc_validate;
Rem                 ALTER SESSION SET CURRENT_SCHEMA = SYS;
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    03/14/12 - do not delete hidden rows in wm$env_vars
Rem    bspeckha    03/14/12 - Backport bspeckha_bug-13841182 from main
Rem    bspeckha    08/10/09 - do not set old_version with loaded procedure
Rem    bspeckha    03/11/09 - invoke v script
Rem    bspeckha    12/05/07 - change downgrading to loading
Rem    bspeckha    11/09/07 - use nls_sort=ascii7 when comparing versionstrings
Rem    bspeckha    10/24/06 - moving everything to wmsys
Rem    bspeckha    10/13/06 - grant execute on packages to wmsys
Rem    bspeckha    08/02/06 - oldest db release supported is now 9.2
Rem    bspeckha    01/25/05 - use recompileAllObjects 
Rem    bspeckha    10/11/04 - owm_validate changed to validate_owm 
Rem    bspeckha    08/08/03 - fix registry status after upgrade 
Rem    bspeckha    01/17/03 - call recompileObjects
Rem    saagarwa    12/16/02 - 
Rem    saagarwa    11/19/02 - Add calls in the begining and end
Rem    saagarwa    09/30/02 - use enablesystemtriggers_exp
Rem    saagarwa    09/11/02 - Remove creation of system views
Rem    saagarwa    08/28/02 - Recreate views while downgrading
Rem    saagarwa    07/31/02 - Reload OWM on downgrade
Rem    saagarwa    07/28/02 - saagarwa_conflict_view_perf_fix_and_922_scripts
Rem    saagarwa    07/23/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

VAR old_version varchar2(30);
begin
  select value into :old_version
  from wm_installation
  where name = 'OWM_VERSION' ;

  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS') ;
end;
/

/* --------------------------------------------------------------------- */
/* Create package specs                                                  */
/* --------------------------------------------------------------------- */
@@owmcpkgs.plb

@@owmv1120.plb

delete wmsys.wm$env_vars where name not in(select name from wmsys.wm$sysparam_all_values) and name!='OWM_VERSION' and hidden=0;
commit ;

/* --------------------------------------------------------------------- */
/* Create package body                                                   */
/* --------------------------------------------------------------------- */
@@owmcpkgb.plb

execute wmsys.ltadm.recreateAdtFunctions ;

/* --------------------------------------------------------------------- */
/* Light-weight EnableVersion the tables.                                */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;

execute wmsys.owm_mig_pkg.AllLwEnableVersioning ;

execute wmsys.ltric.recreatePtUpdDelTriggers;

/* Recompile any invalid objects */
execute wmsys.owm_mig_pkg.recompileAllObjects ;

/* --------------------------------------------------------------------- */
/* If there is atleast one versioned table, enable the system triggers.  */
/* This is because reinstall of WM creates triggers as disabled.         */
/* --------------------------------------------------------------------- */
declare
 found integer;
begin
   begin
     select 1 into found from dual where exists (select 1 from wmsys.wm$versioned_tables);
     wmsys.ltadm.enableSystemTriggers_exp;
   exception
     when no_data_found then null;
     when others then raise;
   end;
end;
/

create or replace public synonym DBMS_WM for wmsys.lt ;

select owner, name, type, text
from dba_errors
where owner = 'WMSYS' or
      owner in (select owner from wmsys.wm$versioned_tables) or
      (owner || '.' || name) in (select dispatcher_name from wmsys.wm$udtrig_dispatch_procs)
order by 1,2;

declare
  version_str        varchar2(100) ;
  compatibility_str  varchar2(100) ;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := wmsys.wm$convertDbVersion(version_str);

   dbms_registry.loaded('OWM') ;

   if ((nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.7.0', 'nls_sort=ascii7') and
        nlssort(version_str, 'nls_sort=ascii7') <  nlssort('A.0.0.0.0', 'nls_sort=ascii7')) or
       nlssort(version_str, 'nls_sort=ascii7')  >= nlssort('A.1.0.4.0', 'nls_sort=ascii7')) then
     execute immediate 'begin sys.validate_owm; end;' ;
   else
     execute immediate 'begin wmsys.validate_owm; end;' ;
   end if;
end;
/
