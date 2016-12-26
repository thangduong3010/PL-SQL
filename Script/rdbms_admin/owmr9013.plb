@@owmr9014.plb
update wmsys.wm$env_vars set value = '9.0.1.3.0' where name = 'OWM_VERSION';
commit;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  begin
    execute immediate 'drop package owm_mig_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package owm_reputil' ;
  exception when invalid_package then null;
  end ;
end;
/
drop public synonym wm$table_parvers_view ;
drop public synonym wm$table_nextvers_view ;
drop public synonym wm$table_versions_in_live_view ;
drop public synonym wm$table_ws_parvers_view ;
drop view wmsys.wm$table_parvers_view ;
drop view wmsys.wm$table_nextvers_view ;
drop view wmsys.wm$table_versions_in_live_view ;
drop view wmsys.wm$table_ws_parvers_view ;
create or replace view wmsys.wm$diff1_hierarchy_view as
  select * from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffver1')
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$diff2_hierarchy_view as
  select version from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffver2')
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$base_hierarchy_view as
  select version from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffbasever')
  connect by prior parent_version  = version
WITH READ ONLY;
drop view wmsys.wm$replication_info ;
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

  execute immediate 'drop table wmsys.wm$replication_table' || purgeOption ;
end;
/
drop public synonym wm_replication_info ;
alter table wmsys.wm$versioned_tables drop (sitesList);
alter table wmsys.wm$versioned_tables drop( repSiteCount );
create or replace view sys.user_workspaces as
select st.workspace, st.parent_workspace, ssp.savepoint parent_savepoint, 
       st.owner, st.createTime, st.description,
       decode(st.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status, 
       decode(st.oper_status, null, st.freeze_mode,'INTERNAL') freeze_mode,
       decode(st.freeze_mode, '1WRITER_SESSION', s.username, st.freeze_writer) freeze_writer,
       decode(st.session_duration, 0, st.freeze_owner, s.username) freeze_owner,
       decode(st.freeze_status, 'UNLOCKED', null, decode(st.session_duration, 1, 'YES', 'NO')) session_duration,
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
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner, 
       disabling_ver state,
       decode(t.notification,0,''NO'',1,''YES'') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       sys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       sys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t
where  t.owner = USER
WITH READ ONLY';

exception when compile_error then null ;
end;
/
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.all_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       decode(t.notification,0,''NO'',1,''YES'') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
       sys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       sys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, all_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY';

exception when compile_error then null ;
end;
/
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.dba_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       decode(t.notification,0,''NO'',1,''YES'') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       sys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       sys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, dba_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY';

exception when compile_error then null ;
end;
/
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

  execute immediate 'drop table wmsys.wm$nested_columns_table' || purgeOption ;
end;
/
drop sequence wmsys.wm$nested_columns_seq ;
drop index wmsys.wm$mod_tab_ver_ind;
create index wmsys.wm$mod_tab_ver_ind on wmsys.wm$modified_tables (version);
alter table wmsys.wm$workspaces_table drop( implicit_sp_cnt ) ;
create or replace view wmsys.user_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo
from   wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table u,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max
where  t.workspace = u.workspace
       and u.owner = USER and
       t.workspace = max.pw (+)
WITH READ ONLY;
create or replace view wmsys.all_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo
from   wmsys.wm$workspace_savepoints_table t, 
       wmsys.all_workspaces_internal asi,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max
where  t.workspace = asi.workspace and 
       t.workspace = max.pw (+)
WITH READ ONLY;
create or replace view wmsys.dba_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo
from   wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table asi,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max
where  t.workspace = asi.workspace and 
       t.workspace = max.pw (+)
WITH READ ONLY;
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  if (1=2) then
    begin
      execute immediate '
      create or replace view force wmsys.wm$ver_bef_inst_parvers_view as
       (select parent_vers 
        from wmsys.wm$version_view 
        where version = sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''ver_before_instant''))
      WITH READ ONLY';
    exception when compile_error then null;
    end ;

    begin
      execute immediate '
      create or replace force view wmsys.wm$current_parvers_view  (parent_vers) as 
               (select version
                from wmsys.wm$version_hierarchy_table  
                where workspace = nvl(sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state''),''LIVE'') and
                      version   <= 
                  decode(sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version''),
                         null,(SELECT current_version 
                                 FROM wmsys.wm$workspaces_table 
                                 WHERE workspace = ''LIVE''),
                         -1,(select current_version 
                             from wmsys.wm$workspaces_table 
                             where workspace = sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state'')),
                         sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version'')))
                union all
               (select vht.version 
                from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
                where vt.workspace  = nvl(sys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state''),''LIVE'')                     and
                      vht.workspace = vt.anc_workspace and
                      vht.version  <= vt.anc_version)
               WITH READ ONLY';
    exception when compile_error then null;
    end ;

  else
    execute immediate '
      create or replace view wmsys.wm$ver_bef_inst_parvers_view as
       (select parent_vers 
        from wmsys.wm$version_view 
        where version = sys_context(''lt_ctx'',''ver_before_instant''))
      WITH READ ONLY';

    execute immediate '
      create or replace view wmsys.wm$current_parvers_view  (parent_vers) as 
             (select version
              from wmsys.wm$version_hierarchy_table  
              where workspace = nvl(sys_context(''lt_ctx'',''state''),''LIVE'') and
                    version   <= 
                decode(sys_context(''lt_ctx'',''version''),
                       null,(SELECT current_version 
                               FROM wmsys.wm$workspaces_table 
                               WHERE workspace = ''LIVE''),
                       -1,(select current_version 
                           from wmsys.wm$workspaces_table 
                           where workspace = sys_context(''lt_ctx'',''state'')),
                       sys_context(''lt_ctx'',''version'')))
              union all
             (select vht.version 
              from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
              where vt.workspace  = nvl(sys_context(''lt_ctx'',''state''),''LIVE'')                     and
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
             WITH READ ONLY';
  end if;
end;
/
create or replace view wmsys.wm$current_nextvers_view as 
         select next_vers
         from wmsys.wm$nextver_table  
         where version IN  
           (SELECT parent_vers FROM wmsys.wm$current_parvers_view)  
WITH READ ONLY;
create or replace view wmsys.wm$current_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$parent_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = SYS_CONTEXT('lt_ctx','parent_state')
WITH READ ONLY;
