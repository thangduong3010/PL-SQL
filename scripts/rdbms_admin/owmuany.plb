declare
  ver    varchar2(100) ;
  found  integer ;
begin
  select 1 into found
  from dba_registry
  where comp_id = 'OWM' ;

  dbms_registry.upgrading('OWM', new_proc=>'VALIDATE_OWM');

exception when no_data_found then
  select value into ver
  from wm_installation
  where name = 'OWM_VERSION' ;

  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
  dbms_registry.loaded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Beta');
  dbms_registry.upgrading('OWM');
end;
/
create or replace function wmsys.wm$convertDbVersion wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
270 158
7YzoyUrxd7Gdk3sWAMdGV8+fL5QwgxDxJJkVfC+VkPg+SC+DrOMNRVR70nI9ORTm8W/ErAaP
cJnFRc7uAHmNFt9eFe3+Er9x8ZR6zH7X7p92ueySRSRMJXm+JJAoLs2JFhTejcPhl1oUQhTo
0efDAo9P4VRZo6becfekBOpTovNpbMYuPVyah8bHHdXUbIYaA0eo2gEeEGAztJ+oNixxaa0i
EE+K6efC46r7IKKCRJYsbJ88LzT0b6UqdJW091XTU/EPyBesBhwRJ6zxHIV4Nd4oIYI1tB3X
LmkzQDDyHva7VR32//hzmotzn7t3KDLctSqW7W3oggR6ptu2iZs=

/
grant execute on wmsys.wm$convertDBVersion to public;
declare
  owm_curr_version   varchar2(50) ;
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := wmsys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  select wmsys.wm$convertDBVersion(value) into owm_curr_version
  from wm_installation
  where name = 'OWM_VERSION';

  if (nlssort(owm_curr_version, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7') and
      nlssort(owm_curr_version, 'nls_sort=ascii7') < nlssort('9.2.0.4.0', 'nls_sort=ascii7')) then
    begin
      dbms_aqadm.stop_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE');

      dbms_aqadm.drop_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE');

      dbms_aqadm.drop_queue_table(
        queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
        force => true);

      execute immediate 'drop public synonym wm_events_info' ;
      execute immediate 'drop view wmsys.wm_events_info' ;
      execute immediate 'drop table wmsys.wm$events_info' || purgeOption ;

      execute immediate 'drop type wmsys.wm$event_type' ;
      execute immediate 'drop type wmsys.wm$nv_pair_nt_type' ;
      execute immediate 'drop type wmsys.wm$nv_pair_type' ;

    exception when others then null; 
    end;
  end if ;
end;
/
@@owmcpkgs.plb
column v_file_name new_value v_file noprint;
var owm_version varchar2(30);
var owm_v_script varchar2(30);
declare
  nver varchar2(100) ;
begin
  select wmsys.wm$convertDBVersion(value) into :owm_version from wm_installation where name = 'OWM_VERSION';
  nver := nlssort(:owm_version, 'nls_sort=ascii7') ;

  if (nver = nlssort('9.0.1.4.0', 'nls_sort=ascii7')) then
    :owm_v_script := 'owmv9014.plb' ;

  elsif (nver >= nlssort('9.2.0.1.0', 'nls_sort=ascii7') and nver < nlssort('9.2.0.4.0', 'nls_sort=ascii7')) then
    :owm_v_script := 'owmv920.plb' ;

  elsif (nver >= nlssort('A.0.0.0.0', 'nls_sort=ascii7') and nver < nlssort('A.1.0.2.0', 'nls_sort=ascii7')) then
    :owm_v_script := 'owmv1010.plb' ;

  elsif ((nver >= nlssort('9.0.1.5.0', 'nls_sort=ascii7') and nver <= nlssort('9.0.1.6.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('9.2.0.4.0', 'nls_sort=ascii7') and nver <= nlssort('9.2.0.5.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('A.1.0.2.0', 'nls_sort=ascii7') and nver <= nlssort('A.1.0.5.0', 'nls_sort=ascii7'))) then
    :owm_v_script := 'owmv1012.plb' ;

  elsif ((nver >= nlssort('9.0.1.6.1', 'nls_sort=ascii7') and nver <= nlssort('9.0.1.6.1', 'nls_sort=ascii7')) or
         (nver >= nlssort('9.2.0.5.1', 'nls_sort=ascii7') and nver <= nlssort('9.2.0.8.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('A.1.0.5.1', 'nls_sort=ascii7') and nver <= nlssort('A.1.0.8.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('A.2.0.0.0', 'nls_sort=ascii7') and nver <= nlssort('A.2.0.4.1', 'nls_sort=ascii7'))) then
    :owm_v_script := 'owmv1020.plb' ;

  elsif ((nver >= nlssort('9.2.0.9.0', 'nls_sort=ascii7') and nver <= nlssort('9.2.0.9.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('A.1.0.9.0', 'nls_sort=ascii7') and nver <= nlssort('A.1.0.9.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('A.2.0.4.2', 'nls_sort=ascii7') and nver <= nlssort('A.2.0.5.0', 'nls_sort=ascii7')) or
         (nver >= nlssort('B.1.0.6.0', 'nls_sort=ascii7') and nver <= nlssort('B.1.0.7.0', 'nls_sort=ascii7'))) then
    :owm_v_script := 'owmv1116.plb' ;

  elsif (1=1
) then
    :owm_v_script := 'owmv1120.plb' ;

  else
    :owm_v_script := 'nothing.sql' ;
  end if;
end;
/
select :owm_v_script AS v_file_name from dual;
@@&v_file
@@owmcpkgb.plb
execute wmsys.ltadm.recreateAdtFunctions ;
begin
 wmsys.owm_mig_pkg.old_owm_version_for_upgrade := :owm_version ;
end;
/
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;
execute wmsys.owm_mig_pkg.AllLwEnableVersioning ;
execute wmsys.ltric.recreatePtUpdDelTriggers;
execute wmsys.owm_mig_pkg.moveWMMetaData;
execute wmsys.owm_mig_pkg.recompileAllObjects ;
declare
 found integer;
begin
  select 1 into found from dual where exists (select 1 from wmsys.wm$versioned_tables);
  wmsys.ltadm.enableSystemTriggers_exp;

exception when no_data_found then
  null;
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
  ver                varchar2(100) ;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := wmsys.wm$convertDbVersion(version_str);

   if (1=1) then
     dbms_registry.upgraded('OWM');
   else
     select value into ver
     from wm_installation
     where name = 'OWM_VERSION' ;

     dbms_registry.upgraded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Production');
   end if ;

   if ((nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.7.0', 'nls_sort=ascii7') and
        nlssort(version_str, 'nls_sort=ascii7') < nlssort('A.0.0.0.0', 'nls_sort=ascii7')) or
       nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.1.0.4.0', 'nls_sort=ascii7')) then
     execute immediate 'begin sys.validate_owm; end;' ;
   else
     execute immediate 'begin wmsys.validate_owm; end;' ;
   end if;
end;
/
