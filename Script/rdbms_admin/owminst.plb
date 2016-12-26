@@owmctab.plb
begin
  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
end;
/
@@owmcpkgs.plb
alter package wmsys.lt compile ;
begin
  insert into wmsys.wm$env_vars values('CR_WORKSPACE_MODE', WMSYS.LT.OPTIMISTIC_LOCKING) ;
  commit;
end;
/
@@owmcvws.plb
@@owmcpkgb.plb
create or replace public synonym DBMS_WM for wmsys.lt ;
select owner, name, type, text
from dba_errors
where owner = 'WMSYS'
order by 1,2;
declare
  version_str        varchar2(30) ;
  compatibility_str  varchar2(30) ;
  ver                varchar2(30) ;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := wmsys.wm$convertDbVersion(version_str);

   if (1=1) then
     dbms_registry.loaded('OWM');
   else
     select value into ver
     from wm_installation
     where name = 'OWM_VERSION' ;

     dbms_registry.loaded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Production');
   end if ;

   if ((nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.7.0', 'nls_sort=ascii7') and
        nlssort(version_str, 'nls_sort=ascii7') <  nlssort('A.0.0.0.0', 'nls_sort=ascii7')) or
       nlssort(version_str, 'nls_sort=ascii7')  >= nlssort('A.1.0.4.0', 'nls_sort=ascii7')) then
     execute immediate 'begin sys.validate_owm; end;' ;
   else
     execute immediate 'begin wmsys.validate_owm; end;' ;
   end if ;
end;
/
