update wmsys.wm$env_vars set value = '10.1.0.0.0' where name = 'OWM_VERSION';
commit;
execute wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to public with grant option');
declare
 curTrigStatus varchar2(10) := null;
 verTabName varchar2(61);
 cursor verTabsCur is 
   select owner || '.' || table_name from wmsys.wm$versioned_tables;
 badtab_exception EXCEPTION;
 PRAGMA EXCEPTION_INIT(badtab_exception, -00942);
 column_exists_exception EXCEPTION;
 PRAGMA EXCEPTION_INIT(column_exists_exception, -01430);
begin

  BEGIN
   select substr(status,1,length(status)-1) into curTrigStatus
   from all_triggers 
   where owner = 'SYS' and trigger_name = 'NO_VM_DROP';

   execute immediate 'alter trigger sys.no_vm_drop disable';

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;
  
  BEGIN

    open verTabsCur;
    loop
  
      fetch verTabsCur into verTabName;
      EXIT when verTabsCur%NOTFOUND;
      
      
      BEGIN
        execute immediate 'drop view ' || verTabName || '_BPKB';
      EXCEPTION WHEN badtab_exception THEN
        NULL;
      END;
  
    end loop;
    close verTabsCur;

  EXCEPTION WHEN OTHERS THEN
    if (curTrigStatus is not null) then
      execute immediate 'alter trigger sys.no_vm_drop ' || curTrigStatus;
    end if;
    RAISE;
  END;
  if (curTrigStatus is not null) then
    execute immediate 'alter trigger sys.no_vm_drop ' || curTrigStatus;
  end if;

end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_MULTI_PARENT_WORKSPACES', 'OFF', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_MULTI_PARENT_WORKSPACES', 'ON', 'NO');
  commit ;
end;
/
create or replace view wmsys.wm$mp_join_points(workspace,version) as
select mpwst.mp_leaf_workspace,  vht.version 
from   wmsys.wm$mp_graph_workspaces_table mpwst, wmsys.wm$workspaces_table wt, wmsys.wm$version_hierarchy_table vht
where  mpwst.mp_graph_workspace  = sys_context('lt_ctx','new_mp_leaf')  and
       mpwst.mp_leaf_workspace   = wt.workspace                         and
       wt.workspace              = vht.workspace                        and
       wt.parent_version         = vht.parent_version
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$mp_join_points to public with grant option');
create or replace view wmsys.wm$current_mp_join_points(workspace,version) as
select mpwst.mp_leaf_workspace,  vht.version 
from   wmsys.wm$mp_graph_workspaces_table mpwst, wmsys.wm$workspaces_table wt, wmsys.wm$version_hierarchy_table vht
where  mpwst.mp_graph_workspace  = sys_context('lt_ctx','state')  and
       mpwst.mp_leaf_workspace   = wt.workspace                   and
       wt.workspace              = vht.workspace                  and
       wt.parent_version         = vht.parent_version
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_mp_join_points to public with grant option');
create or replace view wmsys.wm$mp_graph_removed_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where vt.workspace = sys_context('lt_ctx','mp_workspace') 
and vht.workspace = vt.anc_workspace
and vht.version <= vt.anc_version
and (vt.refCount = 0 or ( vht.workspace = sys_context('lt_ctx','mp_root')
                          and vht.version > sys_context('lt_ctx','new_root_anc_version') ) 
    ) 
WITH READ ONLY;
create or replace view wmsys.wm$mp_graph_remaining_versions as
(select vht.version
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where vt.anc_workspace = sys_context('lt_ctx','mp_workspace') 
 and   vht.workspace    = vt.workspace
 union all
 select vht.version
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = sys_context('lt_ctx','mp_workspace')) 
WITH READ ONLY;
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') IsRefreshed, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, sys.user_workspaces uw
where mp.workspace = uw.workspace ;
execute wmsys.wm$execSQL('grant select on wmsys.user_mp_parent_workspaces to public with grant option');
create public synonym user_mp_parent_workspaces for wmsys.user_mp_parent_workspaces ;
create or replace view wmsys.all_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') ISREFRESHED, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') PARENT_FLAG
from wmsys.wm$mp_parent_workspaces_table mp, sys.all_workspaces aw
where mp.workspace = aw.workspace ;
execute wmsys.wm$execSQL('grant select on wmsys.all_mp_parent_workspaces to public with grant option');
create public synonym all_mp_parent_workspaces for wmsys.all_mp_parent_workspaces ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, sys.user_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
execute wmsys.wm$execSQL('grant select on wmsys.user_mp_graph_workspaces to public with grant option');
create public synonym user_mp_graph_workspaces for wmsys.user_mp_graph_workspaces ;
create or replace view wmsys.all_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, sys.all_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
execute wmsys.wm$execSQL('grant select on wmsys.all_mp_graph_workspaces to public with grant option');
create public synonym all_mp_graph_workspaces for wmsys.all_mp_graph_workspaces ;
create or replace view wmsys.wm$mp_graph_other_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where
(vt.workspace = sys_context('lt_ctx','new_mp_leaf') 
 and vht.workspace = vt.anc_workspace
 and vht.version <= vt.anc_version
 and vt.refCount > 0
 and vt.anc_workspace not in 
   (select sys_context('lt_ctx','new_mp_root') from dual
    union all
    select anc_workspace from wmsys.wm$version_table root_anc
    where workspace = sys_context('lt_ctx','new_mp_root')) 
) or
(
 (vt.anc_workspace = sys_context('lt_ctx','new_mp_leaf')
  and vht.workspace = vt.workspace
 )
) 
union all
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht
where vht.workspace = sys_context('lt_ctx','new_mp_leaf') 
union all
select version, workspace
from wmsys.wm$mp_graph_cons_versions
WITH READ ONLY;
create or replace view wmsys.all_workspaces_internal as
select 
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration, s.mp_root
from   wmsys.wm$workspaces_table s
where  exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
union
select
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration, s.mp_root
from   wmsys.wm$workspaces_table s, 
       (select distinct workspace from wmsys.user_wm_privs) u
where  u.workspace = s.workspace
union
select
s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
s.freeze_owner, s.session_duration, s.mp_root
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
       rst.resolve_user,
       mp_root mp_root_workspace
from   wmsys.wm$workspaces_table asp, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, V$session s
where  nvl(ssp.is_implicit,1) = 1 and 
       asp.parent_version  = ssp.version (+) and 
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
alter table wmsys.wm$udtrig_info add(TABLE_IMPORT_COL varchar2(4) default 'ON') ; 
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
  WORKSPACE_REMOVE,
  TABLE_IMPORT_COL
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
       WORKSPACE_REMOVE_COL,
       TABLE_IMPORT_COL
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
  WORKSPACE_REMOVE,
  TABLE_IMPORT_COL
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
        WORKSPACE_REMOVE_COL,
        TABLE_IMPORT_COL
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
   vt.anc_version  >= decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
)
union all
select vht.version
from wmsys.wm$version_hierarchy_table vht
where vht.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
      vht.version > decode(sys_context('lt_ctx','version'),
                            null,(SELECT current_version 
                                  FROM wmsys.wm$workspaces_table 
                                  WHERE workspace = 'LIVE'),
                            -1,(select current_version 
                                from wmsys.wm$workspaces_table 
                                where workspace = sys_context('lt_ctx','state')),
                            sys_context('lt_ctx','version')
                          )
WITH READ ONLY ;
create or replace view wmsys.wm$current_child_nextvers_view as
select nvt.next_vers 
from wmsys.wm$nextver_table nvt, wmsys.wm$version_table vt
where 
(
   nvt.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version  >= decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
) 
union all
select nvt.next_vers
from wmsys.wm$nextver_table nvt
where nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
      nvt.version > decode(sys_context('lt_ctx','version'),
                            null,(SELECT current_version 
                                  FROM wmsys.wm$workspaces_table 
                                  WHERE workspace = 'LIVE'),
                            -1,(select current_version 
                                from wmsys.wm$workspaces_table 
                                where workspace = sys_context('lt_ctx','state')),
                            sys_context('lt_ctx','version')
                          )
WITH READ ONLY ;
begin
   execute immediate 'alter table wmsys.wm$constraints_table modify ( search_condition clob )';
   execute immediate 'alter table wmsys.wm$udtrig_info modify ( trig_code clob )';

   execute immediate 'alter index WMSYS.WM$UDTRIG_INFO_INDX rebuild';
   execute immediate 'alter index WMSYS.WM$CONSTRAINTS_TABLE_TAB_IDX rebuild';
   execute immediate 'alter index WMSYS.WM$UDTRIG_INFO_PK rebuild' ;
   execute immediate 'alter index WMSYS.WM$CONSTRAINTS_TABLE_PK rebuild' ;
end;
/
create or replace view wmsys.wm$net_diff1_hierarchy_view as
select version from wmsys.wm$diff1_hierarchy_view
            minus
            select version from wmsys.wm$base_hierarchy_view 
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$net_diff1_hierarchy_view to public with grant option');
create or replace view wmsys.wm$net_diff2_hierarchy_view as
select version from wmsys.wm$diff2_hierarchy_view
            minus
            select version from wmsys.wm$base_hierarchy_view 
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$net_diff2_hierarchy_view to public with grant option');
create or replace view wmsys.wm$base_version_view as
select decode(sign(vt1.anc_version - vt2.anc_version),
              1, vt2.anc_version, vt1.anc_version) version,
       decode(sys_context('lt_ctx', 'isAncestor'), 'false','NO',
              decode(decode(sign(vt1.anc_version - vt2.anc_version),
                     1, vt2.anc_version, vt1.anc_version), 
                     wmt.current_version, 'YES', 'NO')) isCRAnc
from (select vt1.anc_version 
      from wmsys.wm$version_table vt1
      where vt1.workspace = sys_context('lt_ctx', 'diffWspc1') and
            vt1.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
      union all 
      select decode(sys_context('lt_ctx', 'diffver1'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc1')),
                     sys_context('lt_ctx', 'diffver1'))
      from dual where sys_context('lt_ctx', 'anc_workspace') = 
                      sys_context('lt_ctx', 'diffWspc1')
      ) vt1,
      (select vt2.anc_version
       from wmsys.wm$version_table vt2
       where vt2.workspace = sys_context('lt_ctx', 'diffWspc2') and
             vt2.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
       union all 
       select decode(sys_context('lt_ctx', 'diffver2'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc2')),
                       sys_context('lt_ctx', 'diffver2'))
       from dual where sys_context('lt_ctx', 'anc_workspace') = 
                       sys_context('lt_ctx', 'diffWspc2')
      ) vt2,
      wmsys.wm$workspaces_table wmt
where wmt.workspace = sys_context('lt_ctx', 'anc_workspace');
create or replace view wmsys.wm$current_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers, nvt.version
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
);
BEGIN
    dbms_aqadm.CREATE_queue_table(
        queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
        storage_clause => 'nested table user_data.aux_params store as WM$EVENT_AUX_PARAMS_NT',
        multiple_consumers => TRUE,
        queue_payload_type => 'WMSYS.WM$EVENT_TYPE');
END;
/
BEGIN
    dbms_aqadm.CREATE_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE',
        queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
        comment => 'OWM Events Queue');
END;
/
DECLARE
BEGIN
    dbms_aqadm.start_queue(
        queue_name => 'WMSYS.WM$EVENT_QUEUE');
END;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_CAPTURE_EVENTS', 'OFF', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_CAPTURE_EVENTS', 'ON', 'NO');
  commit ;
end;
/
grant execute on SYS.AQ$_HISTORY to wmsys with grant option ;
execute wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE to aq_administrator_role');
execute wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE to wm_admin_role');
begin
    wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE_S to aq_administrator_role');
    wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE_S to wm_admin_role');
end;
/
declare
  version_str          varchar2(1000) := '';
  compatibility_str    varchar2(1000) := '';
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
    wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE_R to aq_administrator_role');
    wmsys.wm$execSQL('grant select on wmsys.AQ$WM$EVENT_QUEUE_TABLE_R to wm_admin_role');
  end if;
end;
/
create table wmsys.wm$events_info (
 event_name varchar2(30) primary key,
 capture varchar2(10)
) ;
insert into wmsys.wm$events_info values('WORKSPACE_MERGE_WO_REMOVE','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_MERGE_W_REMOVE','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_REFRESH','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_ROLLBACK','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_REMOVE','OFF') ;        
insert into wmsys.wm$events_info values('TABLE_MERGE_WO_REMOVE_DATA','OFF') ;        
insert into wmsys.wm$events_info values('TABLE_MERGE_W_REMOVE_DATA','OFF') ;        
insert into wmsys.wm$events_info values('TABLE_REFRESH','OFF') ;        
insert into wmsys.wm$events_info values('TABLE_ROLLBACK','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_COMPRESS','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_CREATE','OFF') ;        
insert into wmsys.wm$events_info values('WORKSPACE_VERSION','OFF') ;        
commit ;
create or replace view wmsys.wm_events_info as select * from wmsys.wm$events_info 
WITH READ ONLY ;
create public synonym wm_events_info for wmsys.wm_events_info ;
execute wmsys.wm$execSQL('grant select on WMSYS.WM_EVENTS_INFO to public with grant option');
create or replace view wmsys.wm$all_locks_view as 
select t.table_owner, t.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKMODE'), 'E', 'EXCLUSIVE', 'S', 'SHARED', 'VE', 'VERSION EXCLUSIVE', 'WE', 'WORKSPACE EXCLUSIVE') Lock_mode, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKUSER') Lock_owner, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKSTATE') Locking_state
from (select table_owner, table_name, info from 
      table( cast(wmsys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t 
with READ ONLY;
alter table wmsys.wm$replication_table add (isWriterSite varchar2(1));
declare
found integer ;
begin
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_NESTED_TABLE_COLUMNS', 'OFF', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('ALLOW_NESTED_TABLE_COLUMNS', 'ON', 'NO');
  commit ;

  select count(*) into found 
  from wmsys.wm$nested_columns_table ;

  if (found>0) then
    insert into wmsys.wm$env_vars values('ALLOW_NESTED_TABLE_COLUMNS', 'ON') ;
  end if ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('USE_TIMESTAMP_TYPE_FOR_HISTORY', 'ON', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('USE_TIMESTAMP_TYPE_FOR_HISTORY', 'OFF', 'NO');
  commit ;
end;
/
@@owmv1010.plb
