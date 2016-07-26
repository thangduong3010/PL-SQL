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
execute wmsys.owm_mig_pkg.RollbackFixCrWorkspaces ;
execute wmsys.owm_mig_pkg.AllRollbackFixSentinelVersion ;
execute wmsys.ltadm.disableSystemTriggers_exp ;
execute wmsys.owm_mig_pkg.AllLwDisableVersioning('9.0.1.3.0') ;
Declare
    delTrigCode varchar2(32000);
    updTrigCode varchar2(32000);

    cursor ricPtTrigCur is 
    select * 
    from wmsys.wm$ric_triggers_table;
    where not exists
      ( select 1 from wmsys.wm$versioned_tables
        where owner = pt_owner
          and (table_name = pt_name or
               table_name || '_LT' = pt_name)
      ) ;

Begin
    for ricPtTrigCurRec in ricPtTrigCur loop
       wmsys.ltric.getPtBeforeTrigStrs(ricPtTrigCurRec.ct_owner,
                                       ricPtTrigCurRec.ct_name, 
                                       ricPtTrigCurRec.pt_owner,
                                       ricPtTrigCurRec.pt_name,
                                       ricPtTrigCurRec.update_trigger_name,
                                       updTrigCode,
                                       ricPtTrigCurRec.delete_trigger_name,
                                       delTrigCode);

       execute immediate delTrigCode;
       execute immediate updTrigCode;
    end loop;
End;
/
create or replace procedure wm$execSQLIgnoreError wrapped 
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
7
93 c6
jYoiorwkXZxEdejjceDzjtPmL2Ewgypt7cvhqC9GO0IYYlagDe2eOO8T3cAVUZ9vQHFjnFB9
hpn03063Osncsw5ive5zaDyuEF0DsEMNYRg7O3mxHgAML1N9kW7cBwBpK4B689XOiKYZUI41
Di9Q8bkptRPDLLL/5vc4DuoHdMx26HRlZR+7W5WfCYTfD2AjSQ0=

/
@@owmr9013.plb
drop context lt_ctx ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  execute immediate 'drop package lt_ctx_pkg' ;

exception when invalid_package then null;
end ;
/
drop type wmsys.oper_lockvalues_array_type ;
drop type wmsys.oper_lockvalues_type ;
drop type wmsys.IntToStr_array_type ;
drop type wmsys.trigOptionsType ;
@@owmcpkgs.plb
grant execute on lt_ctx_pkg to public with grant option;
create or replace view wmsys.wm$current_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
WITH READ ONLY;
@@owmcpkgb.plb
create or replace function wmsys.wm$disallowQnDML wrapped 
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
44 79
RIUuftz0JjpQ88DFC6YWeaC3/Lwwg8eZgcfLCNL+XhZyXKH6VtxH+vqWKEfHCIHM58CyvbKb
XqXSmVIyv7IJpXSLwMAy/tKGCan6BBZUx76SvlSCpqaXC9N3

/
declare

  l_owner varchar2(30);
  l_table_name varchar2(30);

  found integer;
  error_flag boolean := false;

  err_num             number;
  err_msg             varchar2(200);

  l_pt_owner          varchar2(30);
  l_pt_table_name     varchar2(30);

  cursor vertab_cur is
    select owner, table_name
    from wmsys.wm$versioned_tables 
    where disabling_ver = 'LW_DISABLED' order by ricWeight desc;

  cursor pt_cur is
    select pt_owner, pt_name
    from wmsys.wm$ric_table 
    where ct_owner = l_owner and ct_name = l_table_name 
      and not(pt_owner = ct_owner and pt_name = ct_name) and status = 'ENABLED';

begin

     open vertab_cur;
     loop
        fetch vertab_cur into l_owner, l_table_name;
        EXIT WHEN vertab_cur%NOTFOUND;

        
        begin
          sys.owm_ddl_pkg.lwEnableVersioning(l_owner,l_table_name);

          open pt_cur;
          loop
            fetch pt_cur into l_pt_owner, l_pt_table_name;
            exit when pt_cur%NOTFOUND;
            execute immediate 'drop view ' || l_pt_owner || '.' || l_pt_table_name ; 
          end loop;
          close pt_cur;                                 

        exception 
          when others then 
            begin
             err_num := SQLCODE;
             err_msg := substr(SQLERRM,1,200);
	     error_flag := true;
            end;
        end;
     end loop;
     close vertab_cur;
   
   if(error_flag) then
     
     SYS.WM_ERROR.RAISEERROR(SYS.LT.WM_ERROR_194_NO, err_msg);
   end if;

end;
/
declare
 found integer;
begin
   begin
     select 1 into found from dual where exists (select 1 from wmsys.wm$versioned_tables);
     sys.ltadm.enableSystemTriggers;
   exception
     when no_data_found then null;
     when others then raise;
   end;
end;
/
drop procedure wm$execSQLIgnoreError;
declare
  version_str             varchar2(100)  := '';
  compatibility_str       varchar2(100)  := '';
  cnt                     integer        := 0 ;
  ver                     varchar2(100)  := null;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := sys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7')  >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
     select count(*) into cnt from user_objects where status = 'VALID' and object_type = 'PACKAGE BODY' and object_name = 'LT' ;
     if(cnt = 0) then
       execute immediate 'begin dbms_registry.invalid(''OWM''); end;' ;
     else
       execute immediate 'select value from wm_installation where name = ''OWM_VERSION''' into ver ;
       execute immediate 'begin dbms_registry.downgraded(''OWM'',''' || ver || '''); end;' ;
     end if;
   end if;
end;
/
