Rem
Rem $Header: ovm/src/server/ovme111.sql /main/4 2009/04/29 11:42:31 bspeckha Exp $
Rem
Rem ovme111.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ovme111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    04/27/09 - invoke ovmr1117
Rem    bspeckha    04/21/08 - convertDbVersion in wmsys schema after to 11106
Rem    bspeckha    03/06/08 - added version to LwDisableVersioning
Rem    bspeckha    11/19/07 - Created
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
 * Call dbms_registry.downgrade This is always the first call in Downgrade. 
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

column v_file_name new_value v_file noprint;
var owm_v_script varchar2(30);

begin
  wmsys.owm_mig_pkg.prv_version := null ;

  begin
    select wmsys.wm$convertDbVersion(prv_version) into wmsys.owm_mig_pkg.prv_version
    from sys.registry$
    where cid='OWM'; 

  exception when no_data_found then null ;
  end;

  if (wmsys.owm_mig_pkg.prv_version is null) then
    wmsys.owm_mig_pkg.prv_version := 'B.1.0.6.0' ;
  end if ;

  if (wmsys.owm_mig_pkg.prv_version = 'B.1.0.7.0') then
    :owm_v_script := 'owmr1117.plb' ;
  else
    :owm_v_script := 'owmr1116.plb' ;
  end if ;
end ;
/

/* --------------------------------------------------------------------- */
/* Light-weight DisableVersion the tables. They will be lwEnabled later. */
/* This is becuase triggers, dispatch procs, views etc are dependent on  */
/* new packages and tables.                                              */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.AllLwDisableVersioning(wmsys.owm_mig_pkg.prv_version) ;

/* --------------------------------------------------------------------- */
/* rollback the metadate to appropriate version.                         */
/* --------------------------------------------------------------------- */
select :owm_v_script AS v_file_name from dual;
@@&v_file

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
   version_str := wmsys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
       execute immediate 'select value from wmsys.wm$env_vars where name = ''OWM_VERSION''' into ver ;
       execute immediate 'begin dbms_registry.downgraded(''OWM'',''' || ver || '''); end;' ;
   end if;
end;
/
