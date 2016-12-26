drop context lt_ctx ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  execute immediate 'drop package lt_ctx_pkg' ;

exception when invalid_package then null;
end ;
/
@@owmcpkgs.plb
grant execute on sys.ltadm to wmsys with grant option;
grant execute on sys.ltutil to wmsys with grant option;
grant execute on sys.lt_ctx_pkg to wmsys with grant option;
grant select on  sys.dba_views to wmsys with grant option;
grant execute on sys.dbms_lob to wmsys with grant option;
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
execute sys.owm_mig_pkg.AllLwEnableVersioning ;
Declare
    delTrigCode varchar2(32000);
    updTrigCode varchar2(32000);

    cursor ricPtTrigCur is 
    select * 
    from wmsys.wm$ric_triggers_table
    where not exists
      ( select 1 from wmsys.wm$versioned_tables
        where owner = pt_owner
          and (table_name = pt_name or
               table_name || '_LT' = pt_name)
      ) ;

Begin
    for ricPtTrigCurRec in ricPtTrigCur loop
       sys.ltric.getPtBeforeTrigStrs(ricPtTrigCurRec.ct_owner,
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
drop function sys.wm$convertDbVersion ;
drop function wmsys.wm$getdbversionstr ;
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
