@@owmr1010.plb
update wmsys.wm$env_vars set value = '9.2.0.2.0' where name = 'OWM_VERSION';
commit;
delete from wmsys.wm$sysparam_all_values where name = 'USE_TIMESTAMP_TYPE_FOR_HISTORY';
delete from wmsys.wm$env_vars where name = 'USE_TIMESTAMP_TYPE_FOR_HISTORY' ;
commit;
begin
  delete from wmsys.wm$sysparam_all_values where name = 'ALLOW_MULTI_PARENT_WORKSPACES';
  delete from wmsys.wm$env_vars where name = 'ALLOW_MULTI_PARENT_WORKSPACES' ;
  commit ;
end;
/
drop view wmsys.wm$mp_join_points;
drop view wmsys.wm$mp_graph_remaining_versions;
drop view wmsys.wm$current_mp_join_points;
drop view wmsys.wm$mp_graph_removed_versions;
drop view wmsys.user_mp_parent_workspaces ;
drop view wmsys.all_mp_parent_workspaces ;
drop view wmsys.user_mp_graph_workspaces ;
drop view wmsys.all_mp_graph_workspaces ;
drop view wmsys.wm$net_diff1_hierarchy_view ;
drop view wmsys.wm$net_diff2_hierarchy_view ;
drop public synonym user_mp_parent_workspaces ;
drop public synonym all_mp_parent_workspaces ;
drop public synonym user_mp_graph_workspaces ;
drop public synonym all_mp_graph_workspaces ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  begin
    execute immediate 'drop package sys.owm_9ip_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_iexp_pkg' ;

  exception when invalid_package then null;
  end ;
end;
/
create or replace view wmsys.all_workspaces_internal as
select 
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration
from   wmsys.wm$workspaces_table s
where  exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
union
select
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration
from   wmsys.wm$workspaces_table s, 
       (select distinct workspace from wmsys.user_wm_privs) u
where  u.workspace = s.workspace
union
select
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration
from wmsys.wm$workspaces_table s where owner = USER
WITH READ ONLY;
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
       decode(substr(st.wm_lockmode, 3, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override
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
       decode(substr(asp.wm_lockmode, 3, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override
from   wmsys.all_workspaces_internal asp, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  ((ssp.position is null) or ( ssp.position = 
	(select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and 
       asp.parent_version  = ssp.version (+) and 
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
create or replace view sys.dba_workspaces as
select asp.workspace, asp.parent_workspace, ssp.savepoint parent_savepoint, 
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status, 
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, 1, instr(asp.freeze_writer, ',')-1), null) sid,
       decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, instr(asp.freeze_writer, ',')+1), null) serial#,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
       rst.resolve_user 
from   wmsys.wm$workspaces_table asp, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, V$session s
where  nvl(ssp.is_implicit,1) = 1 and 
       asp.parent_version  = ssp.version (+) and 
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
alter table wmsys.wm$udtrig_info drop(TABLE_IMPORT_COL);
create or replace view wmsys.user_wm_tab_triggers 
(
  trigger_name,
  table_owner,
  table_name,
  trigger_type,
  status,
  when_clause,
  description,
  trigger_body,
  TAB_MERGE_WO_REMOVE,
  TAB_MERGE_W_REMOVE,
  WSPC_MERGE_WO_REMOVE,
  WSPC_MERGE_W_REMOVE,
  DML,          
  WORKSPACE_REFRESH,
  TABLE_REFRESH,
  TABLE_ROLLBACK,
  WORKSPACE_ROLLBACK,
  WORKSPACE_REMOVE
)
as 
select trig_name,
       table_owner_name,
       table_name,
       trig_type,
       status,
       when_clause,
       description,
       trig_code,       
       TAB_MERGE_WO_REMOVE_COL,
       TAB_MERGE_W_REMOVE_COL,
       WSPC_MERGE_WO_REMOVE_COL,
       WSPC_MERGE_W_REMOVE_COL,
       DML_COL,          
       WORKSPACE_REFRESH_COL,
       TABLE_REFRESH_COL,
       TABLE_ROLLBACK_COL,
       WORKSPACE_ROLLBACK_COL,
       WORKSPACE_REMOVE_COL
from   wmsys.wm$udtrig_info
where  trig_owner_name = USER
with READ ONLY;
create or replace view wmsys.all_wm_tab_triggers 
(
  trigger_owner,
  trigger_name,
  table_owner,
  table_name,
  trigger_type,
  status,
  when_clause,
  description,
  trigger_body,  
  TAB_MERGE_WO_REMOVE,
  TAB_MERGE_W_REMOVE,
  WSPC_MERGE_WO_REMOVE,
  WSPC_MERGE_W_REMOVE,
  DML,          
  WORKSPACE_REFRESH,
  TABLE_REFRESH,
  TABLE_ROLLBACK,
  WORKSPACE_ROLLBACK,
  WORKSPACE_REMOVE
)
as 
(select trig_owner_name, 
        trig_name,
        table_owner_name,
        table_name,
        trig_type,
        status,
        when_clause,
        description,
        trig_code,       
        TAB_MERGE_WO_REMOVE_COL,
        TAB_MERGE_W_REMOVE_COL,
        WSPC_MERGE_WO_REMOVE_COL,
        WSPC_MERGE_W_REMOVE_COL,
        DML_COL,          
        WORKSPACE_REFRESH_COL,
        TABLE_REFRESH_COL,
        TABLE_ROLLBACK_COL,
        WORKSPACE_ROLLBACK_COL,
        WORKSPACE_REMOVE_COL
 from   wmsys.wm$udtrig_info
 where  trig_owner_name = USER or
        table_owner_name = USER or
        EXISTS  
        ( select * 
          from   user_sys_privs
          where  privilege = 'CREATE ANY TRIGGER' ) )
with READ ONLY;
create or replace view wmsys.wm$current_child_versions_view as
select vht.version
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where 
(
   vht.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version   = decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
) 
WITH READ ONLY ;
create or replace view wmsys.wm$current_child_nextvers_view as
select nvt.next_vers 
from wmsys.wm$nextver_table nvt, wmsys.wm$version_table vt
where 
(
   nvt.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version   = decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
) 
WITH READ ONLY ;
create or replace view wmsys.wm$current_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers 
             from wmsys.wm$nextver_table nvt
where 
(
 (
   nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    nvt.version   <=   decode(sys_context('lt_ctx','version'),
                       null,(SELECT current_version 
                               FROM wmsys.wm$workspaces_table 
                               WHERE workspace = 'LIVE'),
                       -1,(select current_version 
                           from wmsys.wm$workspaces_table 
                           where workspace = sys_context('lt_ctx','state')),
                           sys_context('lt_ctx','version')
                          )
 )
 or 
 ( exists ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version )
 )
) ;
DECLARE
BEGIN
    dbms_aqadm.stop_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE');
END;
/
BEGIN
    dbms_aqadm.drop_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE');
END;
/
BEGIN
    dbms_aqadm.drop_queue_table(
        queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
        force => true);
END;
/
drop public synonym wm_events_info ;
drop view wmsys.wm_events_info ;
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  execute immediate 'drop table wmsys.wm$events_info' || purgeOption ;
end;
/
drop type wmsys.wm$event_type ;
drop type wmsys.wm$nv_pair_nt_type ;
drop type wmsys.wm$nv_pair_type ;
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.wm$all_locks_view as 
select t.table_owner, t.table_name,
       decode(sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKMODE''), ''E'', ''EXCLUSIVE'', ''S'', ''SHARED'') Lock_mode, 
       sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKUSER'') Lock_owner, 
       sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKSTATE'') Locking_state
from (select table_owner, table_name, info from 
      table( cast(sys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t 
with READ ONLY';

exception when compile_error then null ;
end;
/
alter table wmsys.wm$replication_table drop column isWriterSite;
delete from wmsys.wm$sysparam_all_values where name = 'ALLOW_NESTED_TABLE_COLUMNS' ;
delete from wmsys.wm$env_vars where name = 'ALLOW_NESTED_TABLE_COLUMNS' ;
delete from wmsys.wm$sysparam_all_values where name = 'ALLOW_CAPTURE_EVENTS' ;
delete from wmsys.wm$env_vars where name = 'ALLOW_CAPTURE_EVENTS' ;
commit ;
