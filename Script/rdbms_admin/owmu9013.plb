create or replace function sys.wm$convertDbVersion wrapped 
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
grant execute on sys.wm$convertDBVersion to public;
declare
  ver varchar2(100) ;
begin
  select value into ver
  from wm_installation
  where name = 'OWM_VERSION' ;

  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
  dbms_registry.loaded('OWM', ver, 'Oracle Workspace Manager ' || ver || ' - Production');
  dbms_registry.upgrading('OWM');
end;
/
@@owmt9013.plb
@@owmcpkgs.plb
@@owmv9013.plb
@@owmcpkgb.plb
execute wmsys.owm_mig_pkg.AllFixSentinelVersion ;
execute wmsys.owm_mig_pkg.FixCrWorkspaces ;
execute wmsys.ltadm.recreateAdtFunctions ;
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;
execute wmsys.owm_mig_pkg.AllLwEnableVersioning ;
execute wmsys.ltric.recreatePtUpdDelTriggers;
execute wmsys.owm_mig_pkg.moveWMMetaData;
execute wmsys.owm_mig_pkg.recompileAllObjects ;
declare
 found integer;
begin
   begin
     select 1 into found from dual where exists (select 1 from wmsys.wm$versioned_tables);
     sys.ltadm.enableSystemTriggers_exp;
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
  version_str             varchar2(100)  := '';
  compatibility_str       varchar2(100)  := '';
  ver                     varchar2(100)  := null;
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
       nlssort(version_str, 'nls_sort=ascii7') <  nlssort('A.0.0.0.0', 'nls_sort=ascii7')) or
      nlssort(version_str, 'nls_sort=ascii7')  >= nlssort('A.1.0.4.0', 'nls_sort=ascii7')) then
    execute immediate 'begin sys.validate_owm; end;' ;
  else
    execute immediate 'begin wmsys.validate_owm; end;' ;
  end if;
end;
/
