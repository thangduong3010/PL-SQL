Rem
Rem $Header: ovm/src/server/ovme112.sql /main/1 2009/06/23 10:03:42 bspeckha Exp $
Rem
Rem ovme112.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      ovme112.sql
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    06/22/09 - Created
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

/* --------------------------------------------------------------------- */
/* Light-weight DisableVersion the tables. They will be lwEnabled later. */
/* This is becuase triggers, dispatch procs, views etc are dependent on  */
/* new packages and tables.                                              */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.AllLwDisableVersioning('11.2.0.1.0') ;

/* --------------------------------------------------------------------- */
/* rollback the metadate to appropriate version.                         */
/* --------------------------------------------------------------------- */
@@owmr1120.plb

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
