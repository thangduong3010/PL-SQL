create or replace view wmsys.wm$table_parvers_view  (table_name,parent_vers) as 
         (select table_name,version
          from wmsys.wm$modified_tables  
          where workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
                version   <= 
            decode(sys_context('lt_ctx','version'),
                   null,(SELECT current_version 
                           FROM wmsys.wm$workspaces_table 
                           WHERE workspace = 'LIVE'),
                   -1,(select current_version 
                       from wmsys.wm$workspaces_table 
                       where workspace = sys_context('lt_ctx','state')),
                   sys_context('lt_ctx','version')))
          union all
         (select table_name,vht.version 
          from wmsys.wm$modified_tables vht, wmsys.wm$version_table vt
          where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')  and
                vht.workspace = vt.anc_workspace and
                vht.version  <= vt.anc_version)
WITH READ ONLY;
create or replace view wmsys.wm$table_nextvers_view as
select /*+ INDEX(v1 WM$NEXTVER_TABLE_NV_INDX) USE_NL(v1 v2) */ v2.table_name, v1.next_vers 
             from wmsys.wm$nextver_table v1,wmsys.wm$table_parvers_view v2
              where v1.version = v2.parent_vers ;
create public synonym wm$table_parvers_view for wmsys.wm$table_parvers_view;
create public synonym wm$table_nextvers_view for wmsys.wm$table_nextvers_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$table_parvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$table_nextvers_view to public with grant option');
create or replace view wmsys.wm$table_versions_in_live_view  (table_name,parent_vers) as 
             (select table_name,version
              from wmsys.wm$modified_tables  
              where workspace = 'LIVE') 
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$table_versions_in_live_view to public with grant option');
create public synonym wm$table_versions_in_live_view for wmsys.wm$table_versions_in_live_view;
create or replace view wmsys.wm$parvers_view  (parent_vers) as 
  (select version
   from wmsys.wm$version_hierarchy_table  
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE'))
   union all
      (select vht.version 
       from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
       where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and 
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
WITH READ ONLY;
create or replace view wmsys.wm$table_ws_parvers_view  (table_name,parent_vers) as 
  (select table_name,version
   from wmsys.wm$modified_tables  
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE'))
   union all
      (select vht.table_name,vht.version 
       from wmsys.wm$modified_tables vht, wmsys.wm$version_table vt
       where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and 
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$table_ws_parvers_view to public with grant option');
create public synonym wm$table_ws_parvers_view for wmsys.wm$table_ws_parvers_view;
create or replace view wmsys.wm$diff1_hierarchy_view as
  select -1 version,-2 parent_version ,'LIVE' workspace from dual union
  select * from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffver1')
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$diff2_hierarchy_view as
  select -1 version from dual union
  select version from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffver2')
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$base_hierarchy_view as
  select -1 version from dual union
  select version from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'diffbasever')
  connect by prior parent_version  = version
WITH READ ONLY;
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
       decode(st.freeze_mode, 
                '1WRITER_SESSION',
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) Current_Session,
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
       decode(asp.freeze_mode, 
                '1WRITER_SESSION',
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) Current_Session,
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
       decode(asp.freeze_mode, 
                '1WRITER_SESSION',
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')), 
                           1, 'YES', 'NO'),
             null) Current_Session,
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
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification,0,'NO',1,'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t
where  t.owner = USER
WITH READ ONLY;
create or replace view wmsys.all_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification,0,'NO',1,'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, all_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY;
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification,0,'NO',1,'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, dba_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY;
create or replace view wmsys.user_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo,
       decode( t.is_implicit || decode(parent_vers.parent_version,null,'NOT_EXISTS','EXISTS'),
         '1EXISTS','NO','YES') removable
from   wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table u,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max,
       (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where  t.workspace = u.workspace
       and u.owner = USER and
       t.workspace = max.pw (+) and
       t.version = parent_vers.parent_version (+)
WITH READ ONLY;
create or replace view wmsys.all_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo,
       decode( t.is_implicit || decode(parent_vers.parent_version,null,'NOT_EXISTS','EXISTS'),
         '1EXISTS','NO','YES') removable
from   wmsys.wm$workspace_savepoints_table t, 
       wmsys.all_workspaces_internal asi,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max,
       (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where  t.workspace = asi.workspace and 
       t.workspace = max.pw (+) and
       t.version = parent_vers.parent_version (+)
WITH READ ONLY;
create or replace view wmsys.dba_workspace_savepoints as
select t.savepoint, t.workspace, 
       decode(t.is_implicit,0,'NO',1,'YES') implicit, t.position,
       t.owner, t.createTime, t.description, 
       decode(sign(t.version - max.pv), -1, 'NO','YES') canRollbackTo,
       decode( t.is_implicit || decode(parent_vers.parent_version,null,'NOT_EXISTS','EXISTS'),
         '1EXISTS','NO','YES') removable
from   wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table asi,
       (select max(parent_version) pv, parent_workspace pw
        from wmsys.wm$workspaces_table group by parent_workspace) max,
       (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where  t.workspace = asi.workspace and 
       t.workspace = max.pw (+) and
       t.version = parent_vers.parent_version (+)
WITH READ ONLY;
create or replace view wmsys.wm$replication_info as 
         select groupName, masterdefsite writerSite
         from wmsys.wm$replication_table 
WITH READ ONLY;
create public synonym wm_replication_info for wmsys.wm$replication_info;
execute wmsys.wm$execSQL('grant select on wmsys.wm$replication_info to public');
create or replace view wmsys.wm$current_parvers_view as
select vht.version parent_vers
from wmsys.wm$version_hierarchy_table  vht
where 
(
 (
   vht.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    vht.version   <=   decode(sys_context('lt_ctx','version'),
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
                          vht.workspace = vt.anc_workspace and
                          vht.version  <= vt.anc_version )
 )
) ;
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
@@owmv9014.plb