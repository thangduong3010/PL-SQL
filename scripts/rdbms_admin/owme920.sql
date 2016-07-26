Rem
Rem $Header: ovme920.sql 06-mar-2008.10:16:38 bspeckha Exp $
Rem
Rem ovme920.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ovme920.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    03/06/08 - added version to LwDisableVersioning
Rem    bspeckha    12/05/07 - drop dbms_registry validate procedures
Rem    bspeckha    11/08/07 - use nls_sort=ascii7 when comparing version strings
Rem    bspeckha    04/02/07 - call disableversionTopoIndexTables
Rem    bspeckha    10/24/06 - moving everything to wmsys
Rem    bspeckha    11/19/03 - move convertDbVersion 
Rem    saagarwa    07/02/03 - Use env_vars instead of wm_installation
Rem    saagarwa    06/20/03 - Always set the registrinfo at the end
Rem    bspeckha    03/26/03 - 
Rem    bspeckha    01/28/03 - drop types use in ltadm
Rem    rachatte    09/19/02 - move to system tablespace 
Rem    saagarwa    06/21/02 - Create execSQL here
Rem    saagarwa    04/29/02 - saagarwa_multi_workspace_and_test_fix
Rem    saagarwa    04/29/02 - Created
Rem

/* --------------------------------------------------------------------- */
/* Create procedure in wmsys schema for grating privs, etc.              */
/* --------------------------------------------------------------------- */
create or replace procedure wmsys.wm$execSQL(sqlstr varchar2) as
begin
  execute immediate sqlstr;
end;
/

/* 
 * Call dbms_registry.downgrade This is always the first call in Upgrade. 
 */
declare
  version_str             varchar2(1000) := '';
  compatibility_str       varchar2(1000) := '';
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := wmsys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
     execute immediate 'begin dbms_registry.downgrading(''OWM''); end;' ;
   end if;
end;
/

-- ################################################################
-- Disable System Triggers to allow Temporary DisableVersioning
-- ################################################################

execute wmsys.ltadm.disableSystemTriggers_exp ;

-- ################################################################
-- Downgrade tables, packages, metadata
-- ################################################################

/* --------------------------------------------------------------------- */
/* Light-weight DisableVersion the tables. They will be lwEnabled later. */
/* This is becuase triggers, dispatch procs, views etc are dependent on  */
/* new packages and tables.                                              */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.disableversionTopoIndexTables ;

execute wmsys.owm_mig_pkg.AllLwDisableVersioning('9.2.0.0.0') ;

-- downgrade history columns
execute wmsys.owm_mig_pkg.dgHistoryColumns_internal;

execute wmsys.owm_mig_pkg.moveWMMetaData('SYSTEM');

/* --------------------------------------------------------------------- */
/* Call owmr9013.plb to Rollback the metadate to 9013.                   */
/* --------------------------------------------------------------------- */
@@owmr920.plb

-- Drop objects that did not exist in the 920 release
drop type wmsys.oper_lockvalues_array_type ;
drop type wmsys.oper_lockvalues_type ;
drop type wmsys.IntToStr_array_type ;
drop type wmsys.trigOptionsType ;

drop procedure sys.validate_owm ;
drop procedure wmsys.validate_owm ;

/* 
 * Update the regsitry. This should always be the last step.
 */
declare
  version_str             varchar2(100)  := '';
  compatibility_str       varchar2(100)  := '';
  cnt                     integer        := 0 ;
  ver                     varchar2(100)  := null;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := sys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
       execute immediate 'select value from wmsys.wm$env_vars where name = ''OWM_VERSION''' into ver ;
       execute immediate 'begin dbms_registry.downgraded(''OWM'',''' || ver || '''); end;' ;
   end if;
end;
/
