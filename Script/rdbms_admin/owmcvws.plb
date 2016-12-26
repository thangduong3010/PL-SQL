execute wmsys.wm$execSQL('create role wm_admin_role');
grant wm_admin_role to dba;
create or replace view wmsys.user_wm_privs (workspace, privilege,grantor, grantable)
as
select workspace,
       decode(priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',                               
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       grantor,
       decode(admin, 0, 'NO',
                     1, 'YES') grantable
from wmsys.wm$workspace_priv_table where grantee in
   (select role from session_roles 
    UNION ALL
    select 'WM_ADMIN_ROLE' from dual where USER = 'SYS'
    UNION ALL
    select USER from dual
    UNION ALL
    select 'PUBLIC' from dual)
WITH READ ONLY;
create or replace view wmsys.role_wm_privs (role, workspace, privilege, grantable)
as
select grantee role,
       workspace,
       decode(priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',                           
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       decode(admin, 0, 'NO',
                     1, 'YES') grantable
from wmsys.wm$workspace_priv_table where grantee in
   (select role from session_roles
    union all
    select 'WM_ADMIN_ROLE' from dual where USER = 'SYS') 
WITH READ ONLY;
create or replace view wmsys.all_workspaces_internal as
select s.*
from   wmsys.wm$workspaces_table s
where  exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
union
select s.*
from   wmsys.wm$workspaces_table s, 
       (select distinct workspace from wmsys.user_wm_privs) u
where  u.workspace = s.workspace
union
select s.*
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
grant select on sys.user_workspaces to public with grant option;
create public synonym user_workspaces for sys.user_workspaces;
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
create or replace view wmsys.dba_wm_sys_privs(grantee, privilege, grantor, grantable)
as
select spt.grantee,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',   
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from  wmsys.wm$workspace_priv_table spt
where spt.workspace is null;
create or replace view wmsys.user_workspace_privs (grantee, workspace, privilege, grantor, grantable)
as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',                          
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from  user_workspaces ult, wmsys.wm$workspace_priv_table spt
where ult.workspace = spt.workspace;
create or replace view wmsys.all_workspace_privs (grantee, workspace, privilege, grantor, grantable)
as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',                          
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from wmsys.all_workspaces_internal alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace;
create or replace view wmsys.dba_workspace_privs (grantee, workspace, privilege, grantor, grantable)
as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',
                   'CA','MERGE_ANY_WORKSPACE', 
                   'RA','ROLLBACK_ANY_WORKSPACE', 
                   'DA','REMOVE_ANY_WORKSPACE', 
                   'MA','CREATE_ANY_WORKSPACE', 
                   'FA','FREEZE_ANY_WORKSPACE', 
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from wmsys.wm$workspaces_table alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace;
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner, 
       disabling_ver state,
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
       decode(t.notification,0,'NO',1,'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff
from   wmsys.wm$versioned_tables t, dba_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY;
create or replace view wmsys.user_wm_modified_tables as
select table_name, workspace, savepoint 
from 
      (select distinct o.table_name, o.workspace, 
              nvl(s.savepoint, 'LATEST') savepoint,
              min(s.is_implicit) imp, count(s.version) counter 
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s
      where substr(o.table_name, 1, instr(table_name,'.')-1) = USER and 
            o.version = s.version (+) 
      group by o.table_name, o.workspace, savepoint) 
where (imp = 0 or imp is null or counter = 1);
create or replace view wmsys.all_wm_modified_tables as
select table_name, workspace, savepoint 
from 
     (select distinct o.table_name, o.workspace, 
             nvl(s.savepoint, 'LATEST') savepoint,
             min(s.is_implicit) imp, count(s.version) counter 
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s, all_views a 
      where substr(o.table_name, 1, instr(table_name,'.')-1) = a.owner and
            substr(o.table_name, instr(table_name,'.')+1) = a.view_name and
            o.version = s.version (+) 
      group by o.table_name, o.workspace, savepoint) 
where (imp = 0 or imp is null or counter = 1);
create or replace view wmsys.user_wm_tab_triggers 
(
  trigger_name,
  table_owner,
  table_name,
  trigger_type,
  status,
  when_clause,
  description,
  trigger_body  
)
as 
select trig_name,
       table_owner_name,
       table_name,
       trig_type,
       status,
       when_clause,
       description,
       trig_code       
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
  trigger_body  
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
        trig_code       
 from   wmsys.wm$udtrig_info
 where  trig_owner_name = USER or
        table_owner_name = USER or
        EXISTS  
        ( select * 
          from   user_sys_privs
          where  privilege = 'CREATE ANY TRIGGER' ) )
with READ ONLY;
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
create or replace view sys.dba_workspace_sessions as
select sut.username, 
       sut.workspace, 
       wmsys.ltUtil.getSid(sut.sid) sid, 
       wmsys.ltUtil.getsno(sut.sid) serial#,
       decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from   wmsys.wm$workspace_sessions_table sut,
       sys.v$session s,
       sys.v$transaction t
where  wmsys.ltUtil.getsid(sut.sid) = s.sid and 
       wmsys.ltUtil.getsno(sut.sid) = s.serial# and
       s.saddr = t.ses_addr (+)
WITH READ ONLY;
create or replace view wmsys.user_wm_ric_info 
  (ct_owner, ct_name, pt_owner, pt_name, ric_name, 
   ct_cols, pt_cols, r_constraint_name, delete_rule, status) as
  select ct_owner, ct_name, pt_owner, pt_name, ric_name, 
         rtrim(ct_cols,','), rtrim(pt_cols,','),
         pt_unique_const_name, my_mode, status 
  from   wmsys.wm$ric_table rt, user_views uv
  where  uv.view_name = rt.ct_name and
         rt.ct_owner = USER; 
create or replace view wmsys.all_wm_ric_info 
  (ct_owner, ct_name, pt_owner, pt_name, ric_name, 
   ct_cols, pt_cols, r_constraint_name, delete_rule, status) as
  select /*+ ORDERED */ ct_owner, ct_name, pt_owner, pt_name, ric_name, 
         rtrim(ct_cols,','), rtrim(pt_cols,','),
         pt_unique_const_name, my_mode, status 
  from   wmsys.wm$ric_table rt, all_views uv
  where  uv.view_name = rt.ct_name and
         uv.owner = rt.ct_owner;
create or replace view wmsys.all_version_hview as
   select version, parent_version, workspace 
   from wmsys.wm$version_hierarchy_table
WITH READ ONLY;
create or replace view wmsys.wm$all_locks_view as 
select t.table_owner, t.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKMODE'), 'E', 'EXCLUSIVE', 'S', 'SHARED') Lock_mode, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKUSER') Lock_owner, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKSTATE') Locking_state
from (select table_owner, table_name, info from 
      table( cast(wmsys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t 
with READ ONLY;
create or replace view wmsys.all_wm_locked_tables as 
select /*+ ORDERED */ t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state 
from wmsys.wm$all_locks_view t, all_views s 
where t.table_owner = s.owner and t.table_name = s.view_name 
with READ ONLY;
create or replace view wmsys.user_wm_locked_tables as 
select t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state 
from wmsys.wm$all_locks_view t
where t.table_owner = USER
with READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to public');
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_privs to public with grant option');
create public synonym user_wm_privs for wmsys.user_wm_privs;
execute wmsys.wm$execSQL('grant select on role_wm_privs to public with grant option');
create public synonym role_wm_privs for wmsys.role_wm_privs;
grant select on sys.all_workspaces to public with grant option;
create public synonym all_workspaces for sys.all_workspaces;
execute wmsys.wm$execSQL('grant select on wmsys.all_workspaces_internal to public with grant option');
create public synonym all_workspaces_internal for wmsys.all_workspaces_internal;
execute wmsys.wm$execSQL('grant select on wmsys.user_workspace_privs to public with grant option');
create public synonym user_workspace_privs for wmsys.user_workspace_privs;
execute wmsys.wm$execSQL('grant select on wmsys.all_workspace_privs to public with grant option');
create public synonym all_workspace_privs for wmsys.all_workspace_privs;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_versioned_tables to public with grant option');
create public synonym user_wm_versioned_tables for wmsys.user_wm_versioned_tables;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_versioned_tables to public with grant option');
create public synonym all_wm_versioned_tables for wmsys.all_wm_versioned_tables;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_modified_tables to public with grant option');
create public synonym user_wm_modified_tables for wmsys.user_wm_modified_tables;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_modified_tables to public with grant option');
create public synonym all_wm_modified_tables for wmsys.all_wm_modified_tables;
execute wmsys.wm$execSQL('grant select on wmsys.user_workspace_savepoints to public with grant option');
create public synonym user_workspace_savepoints for wmsys.user_workspace_savepoints;
execute wmsys.wm$execSQL('grant select on wmsys.all_workspace_savepoints to public with grant option');
create public synonym all_workspace_savepoints for wmsys.all_workspace_savepoints;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_tab_triggers to public with grant option');
create public synonym user_wm_tab_triggers for wmsys.user_wm_tab_triggers; 
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_tab_triggers to public with grant option');
create public synonym all_wm_tab_triggers for wmsys.all_wm_tab_triggers; 
grant  select on sys.dba_workspace_sessions to wm_admin_role;
create public synonym dba_workspace_sessions for sys.dba_workspace_sessions;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_ric_info to public with grant option');
create public synonym user_wm_ric_info for wmsys.user_wm_ric_info;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_ric_info to public with grant option');
create public synonym all_wm_ric_info for wmsys.all_wm_ric_info;
execute wmsys.wm$execSQL('grant select on wmsys.wm$all_locks_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_locked_tables to public with grant option');
create public synonym all_wm_locked_tables for wmsys.all_wm_locked_tables;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_locked_tables to public with grant option');
create public synonym user_wm_locked_tables for wmsys.user_wm_locked_tables;
execute wmsys.wm$execSQL('grant select on wmsys.all_version_hview to public with grant option');
create public synonym all_version_hview for wmsys.all_version_hview;
grant select on sys.dba_workspaces to wm_admin_role, select_catalog_role;
execute wmsys.wm$execSQL('grant select on wmsys.dba_workspace_savepoints to wm_admin_role, select_catalog_role');
execute wmsys.wm$execSQL('grant select on wmsys.dba_wm_versioned_tables to wm_admin_role, select_catalog_role');
execute wmsys.wm$execSQL('grant select on wmsys.dba_workspace_privs to wm_admin_role, select_catalog_role');
execute wmsys.wm$execSQL('grant select on wmsys.dba_wm_sys_privs to wm_admin_role, select_catalog_role');
create public synonym dba_workspaces for sys.dba_workspaces;
create public synonym dba_workspace_savepoints for wmsys.dba_workspace_savepoints;
create public synonym dba_wm_versioned_tables for wmsys.dba_wm_versioned_tables;
create public synonym dba_workspace_privs for wmsys.dba_workspace_privs;
create public synonym dba_wm_sys_privs for wmsys.dba_wm_sys_privs;
create or replace view wmsys.wm$version_view as 
         select vht1.version, vht2.version parent_vers, vht1.workspace from 
           wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2,
           wmsys.wm$version_table vt
          where (vht1.workspace = vt.workspace and
                 vht2.workspace = vt.anc_workspace and
                 vht2.version  <= vt.anc_version)
         union all
         select vht1.version, vht2.version parent_vers, vht1.workspace from 
           wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2
         where (vht2.version <= vht1.version and
                  vht2.workspace = vht1.workspace)
WITH READ ONLY;
begin 
  
  if ( 1=2 ) then
    execute immediate '
    create or replace view wmsys.wm$ver_bef_inst_parvers_view as
     (select parent_vers 
      from wmsys.wm$version_view 
      where version = wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''ver_before_instant''))
    WITH READ ONLY';

    execute immediate '
    create or replace view wmsys.wm$current_parvers_view  (parent_vers) as 
             (select version
              from wmsys.wm$version_hierarchy_table  
              where workspace = nvl(wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state''),''LIVE'') and
                    version   <= 
                decode(wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version''),
                       null,(SELECT current_version 
                               FROM wmsys.wm$workspaces_table 
                               WHERE workspace = ''LIVE''),
                       -1,(select current_version 
                           from wmsys.wm$workspaces_table 
                           where workspace = wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state'')),
                       wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version'')))
              union all
             (select vht.version 
              from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
              where vt.workspace  = nvl(wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''state''),''LIVE'')                     and
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
             WITH READ ONLY';
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
create or replace view wmsys.wm$ver_bef_inst_nextvers_view as 
         select next_vers
         from wmsys.wm$nextver_table  
         where version IN  
           (SELECT parent_vers FROM wmsys.wm$ver_bef_inst_parvers_view)  
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_parvers_view (parent_vers) as 
 (select version 
  from wmsys.wm$version_hierarchy_table  
  where workspace = SYS_CONTEXT('lt_ctx','conflict_state') and
        version   <= 
         (select current_version from wmsys.wm$workspaces_table 
          where workspace = SYS_CONTEXT('lt_ctx','conflict_state'))
 )
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_nextvers_view as 
select version, next_vers, workspace, split
from wmsys.wm$nextver_table  
where version in
  (select parent_vers FROM wmsys.wm$curConflict_parvers_view)
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_parvers_view (parent_vers) as 
 (select version 
  from wmsys.wm$version_hierarchy_table  
  where workspace = SYS_CONTEXT('lt_ctx','parent_conflict_state') and
        version   <= 
           (select current_version from wmsys.wm$workspaces_table 
            where workspace = SYS_CONTEXT('lt_ctx','parent_conflict_state')) and 
        version > SYS_CONTEXT('lt_ctx','parent_ver')
 )
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_nextvers_view as 
select version, next_vers, workspace, split
from wmsys.wm$nextver_table  
where version in
  (select parent_vers FROM wmsys.wm$parConflict_parvers_view)
WITH READ ONLY;
create or replace view wmsys.wm$current_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$parent_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = SYS_CONTEXT('lt_ctx','parent_state')
WITH READ ONLY;
create or replace view wmsys.wm$current_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$parent_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = sys_context('lt_ctx','parent_state')
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = nvl(sys_context('lt_ctx','conflict_state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = sys_context('lt_ctx','parent_conflict_state') and
         version   > sys_context('lt_ctx','parent_ver')
WITH READ ONLY;
create or replace view wmsys.wm$current_savepoints_view as 
   select * from wmsys.wm$workspace_savepoints_table 
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$modified_tables_view as
   select table_name, version, workspace from wmsys.wm$modified_tables
WITH READ ONLY;
begin 
  
  if ( 1=2 ) then
     execute immediate '
     create or replace view wmsys.wm$current_ver_view as
     select (decode( nvl(wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version''), -1), -1, 
                ( select current_version
                  from wmsys.wm$workspaces_table 
               where workspace = nvl(wmsys.lt_ctx_pkg.my_SYS_CONTEXT(''lt_ctx'',''state''),''LIVE'') ),
                  wmsys.lt_ctx_pkg.my_sys_context(''lt_ctx'',''version'') )) cver from dual
     WITH READ ONLY';
  else
     execute immediate '
       create or replace view wmsys.wm$current_ver_view as 
       (select current_version
         from wmsys.wm$workspaces_table 
         where workspace = nvl(SYS_CONTEXT(''lt_ctx'',''state''),''LIVE'')
               and ( sys_context(''lt_ctx'', ''version'') is null or 
                     sys_context(''lt_ctx'', ''version'') = -1)) 
        union all
        (select to_number(sys_context(''lt_ctx'', ''version'')) from dual where 
          sys_context(''lt_ctx'', ''version'') is not null and 
          sys_context(''lt_ctx'', ''version'') != -1) WITH READ ONLY';
  end if;
end;
/
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
create or replace view wmsys.wm$diff1_nextver_view as
  select next_vers from wmsys.wm$nextver_table 
  where version in 
  (select version from wmsys.wm$diff1_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$diff2_nextver_view as
  select next_vers from wmsys.wm$nextver_table 
  where version in 
  (select version from wmsys.wm$diff2_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$base_nextver_view as
  select next_vers from wmsys.wm$nextver_table
  where version in
  (select version from wmsys.wm$base_hierarchy_view)
WITH READ ONLY;
create public synonym wm$current_parvers_view for wmsys.wm$current_parvers_view;
create public synonym wm$current_nextvers_view for wmsys.wm$current_nextvers_view;
create public synonym wm$curConflict_parvers_view for wmsys.wm$curConflict_parvers_view;
create public synonym wm$curConflict_nextvers_view for wmsys.wm$curConflict_nextvers_view;
create public synonym wm$parConflict_parvers_view for wmsys.wm$parConflict_parvers_view;
create public synonym wm$parConflict_nextvers_view for wmsys.wm$parConflict_nextvers_view;
create public synonym wm$current_workspace_view for wmsys.wm$current_workspace_view;
create public synonym wm$parent_workspace_view for wmsys.wm$parent_workspace_view;
create public synonym wm$current_hierarchy_view for wmsys.wm$current_hierarchy_view;
create public synonym wm$parent_hierarchy_view for wmsys.wm$parent_hierarchy_view;
create public synonym wm$curConflict_hierarchy_view for wmsys.wm$curConflict_hierarchy_view;
create public synonym wm$parConflict_hierarchy_view for wmsys.wm$parConflict_hierarchy_view;
create public synonym wm$current_savepoints_view for wmsys.wm$current_savepoints_view;
create public synonym wm$diff1_hierarchy_view for wmsys.wm$diff1_hierarchy_view;
create public synonym wm$diff2_hierarchy_view for wmsys.wm$diff2_hierarchy_view;
create public synonym wm$base_hierarchy_view for wmsys.wm$base_hierarchy_view;
create public synonym wm$diff1_nextver_view for wmsys.wm$diff1_nextver_view;
create public synonym wm$diff2_nextver_view for wmsys.wm$diff2_nextver_view;
create public synonym wm$base_nextver_view for wmsys.wm$base_nextver_view;
create public synonym wm$current_ver_view for wmsys.wm$current_ver_view; 
create public synonym wm$ver_bef_inst_parvers_view for wmsys.wm$ver_bef_inst_parvers_view; 
create public synonym wm$ver_bef_inst_nextvers_view for wmsys.wm$ver_bef_inst_nextvers_view; 
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_parvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_nextvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$curConflict_parvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$curConflict_nextvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$parConflict_parvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$parConflict_nextvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_workspace_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$parent_workspace_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$parent_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select,insert,update,delete on wmsys.wm$curConflict_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select,insert,update,delete on wmsys.wm$parConflict_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_savepoints_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$diff1_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$diff2_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$base_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$diff1_nextver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$diff2_nextver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$base_nextver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_ver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$ver_bef_inst_parvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$ver_bef_inst_nextvers_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$modified_tables_view to public with grant option');
create or replace view wmsys.wm$mw_parvers_view as
select unique parent_vers from wmsys.wm$version_view where 
  version in ( select current_version from wmsys.wm$workspaces_table 
		where workspace in (select workspace from wmsys.wm$mw_table) );
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_parvers_view to public with grant option');
create or replace view wmsys.wm$mw_nextvers_view as 
select next_vers from wmsys.wm$nextver_table where version in 
        (select parent_vers from wmsys.wm$mw_parvers_view);
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_nextvers_view to public with grant option');
create or replace view wmsys.all_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg from
(select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt, wmsys.wm$vt_errors_table et, all_tables av
where vt.owner = et.owner
and   vt.table_name = et.table_name
and   vt.index_type = et.index_type
and   vt.index_field = et.index_field
and   vt.owner = av.owner 
and   vt.table_name || '_LT' = av.table_name;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_vt_errors to public with grant option');
create public synonym all_wm_vt_errors for wmsys.all_wm_vt_errors;
create or replace view wmsys.user_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg from
(select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt, wmsys.wm$vt_errors_table et
where vt.owner = et.owner
and   vt.table_name = et.table_name
and   vt.index_type = et.index_type
and   vt.index_field = et.index_field
and   vt.owner = USER;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_vt_errors to public with grant option');
create public synonym user_wm_vt_errors for wmsys.user_wm_vt_errors;
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
execute wmsys.wm$execSQL('grant select on wmsys.wm$parvers_view to public with grant option');
create public synonym wm$parvers_view for wmsys.wm$parvers_view;
create or replace view wmsys.wm$versions_in_live_view  (parent_vers) as 
             (select version
              from wmsys.wm$version_hierarchy_table  
              where workspace = 'LIVE') 
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$versions_in_live_view to public with grant option');
create public synonym wm$versions_in_live_view for wmsys.wm$versions_in_live_view;
@@owmv9013.plb
