@@owmr1020.plb
update wmsys.wm$env_vars set value = '10.1.0.2.0' where name = 'OWM_VERSION';
commit;
drop public synonym wm_contains ;
drop public synonym wm_equals ;
drop public synonym wm_greaterthan ;
drop public synonym wm_intersection ;
drop public synonym wm_ldiff ;
drop public synonym wm_lessthan ;
drop public synonym wm_meets ;
drop public synonym wm_overlaps ;
drop public synonym wm_rdiff ;
create or replace view sys.user_workspaces as
select st.workspace, st.parent_workspace, ssp.savepoint parent_savepoint, 
       st.owner, st.createTime, st.description,
       decode(st.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status, 
       decode(st.oper_status, null, st.freeze_mode,'INTERNAL') freeze_mode,
       decode(st.freeze_mode, '1WRITER_SESSION', s.username, st.freeze_writer) freeze_writer,
       decode(st.session_duration, 0, st.freeze_owner, s.username) freeze_owner,
       decode(st.freeze_status, 'UNLOCKED', null, decode(st.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(st.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
       rst.resolve_user, 
       decode(st.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(st.wm_lockmode, 1, 1), 
              'S', 'SHARED', 
              'E', 'EXCLUSIVE', 
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(st.wm_lockmode, 3, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from   wmsys.wm$workspaces_table st, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, V$session s
where  st.owner = USER and ((ssp.position is null) or ( ssp.position = 
	(select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and 
       st.parent_version = ssp.version (+) and 
       st.workspace = rst.workspace (+) and 
       to_char(s.sid(+)) = substr(st.freeze_owner, 1, instr(st.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',')+1)
WITH READ ONLY;
create or replace view sys.all_workspaces as
select asp.workspace, asp.parent_workspace, ssp.savepoint parent_savepoint, 
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status, 
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
       rst.resolve_user, 
       decode(asp.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(asp.wm_lockmode, 1, 1), 
              'S', 'SHARED', 
              'E', 'EXCLUSIVE', 
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(asp.wm_lockmode, 3, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from   wmsys.all_workspaces_internal asp, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  ((ssp.position is null) or ( ssp.position = 
	(select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and 
       asp.parent_version  = ssp.version (+) and 
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
declare
  version_str        varchar2(100) ;
  compatibility_str  varchar2(100) ;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := sys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
     execute immediate 'revoke execute on dbms_registry from WMSYS' ;
   end if ;
end;
/
update wmsys.wm$workspaces_table wt
set post_version = null
where post_version < (select (min(version)) from wmsys.wm$version_hierarchy_table vht where vht.workspace=wt.workspace) ;
commit ;
alter table wmsys.wm$adt_func_table drop constraint wm$adt_func_tab_pk ;
create index wmsys.wm$adt_func_tab_tname on wmsys.wm$adt_func_table (type_name);
drop table wmsys.wm$log_table ;
drop table wmsys.wm$log_table_errors ;
drop view wmsys.dba_wm_vt_errors ;
drop public synonym dba_wm_vt_errors ;
create or replace view wmsys.all_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg from
(select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt, wmsys.wm$vt_errors_table et, all_tables av
where vt.owner = et.owner
and   vt.table_name = et.table_name
and   vt.index_type = et.index_type
and   vt.index_field = et.index_field
and   vt.owner = av.owner 
and   vt.table_name || '_LT' = av.table_name;
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.all_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification,0,''NO'',1,''YES'') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
       sys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       sys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, all_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY' ;

exception when compile_error then null ;
end;
/
declare
  invalid_trigger EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_trigger, -04080);
begin
  execute immediate 'drop trigger no_vm_drop_a' ;

exception when invalid_trigger then null;
end ;
/
