update wmsys.wm$env_vars set value = '11.2.0.1.0' where name = 'OWM_VERSION';
commit;
grant alter user to wmsys ;
declare
  cnt     integer ;
begin
  select count(*) into cnt
  from dba_tab_columns
  where owner = 'WMSYS' and
        table_name = 'WM$UDTRIG_INFO' and
        column_name = 'TRIG_FLAG' ;

  if (cnt>0) then
    return ;
  end if;

  execute immediate 'alter table wmsys.wm$udtrig_info rename column trig_type to trig_flag' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (event_flag integer)' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (tmp_flag integer)' ;

  execute immediate
    'update wmsys.wm$udtrig_info
     set tmp_flag = (decode(trig_flag, ''BIR'', 1, 0) +
                     decode(trig_flag, ''AIR'', 2, 0) +
                     decode(trig_flag, ''BUR'', 4, 0) +
                     decode(trig_flag, ''AUR'', 8, 0) +
                     decode(trig_flag, ''BDR'', 16, 0) +
                     decode(trig_flag, ''ADR'', 32, 0)),
         event_flag = (decode(TAB_MERGE_WO_REMOVE_COL, ''ON'', 1, 0) +
                       decode(TAB_MERGE_W_REMOVE_COL, ''ON'', 2, 0) +
                       decode(WSPC_MERGE_WO_REMOVE_COL, ''ON'', 4, 0) +
                       decode(WSPC_MERGE_W_REMOVE_COL, ''ON'', 8, 0) +
                       decode(nvl(DML_COL, ''ON''), ''ON'', 16, 0) +
                       decode(WORKSPACE_REFRESH_COL, ''ON'', 32, 0) +
                       decode(TABLE_REFRESH_COL, ''ON'', 64, 0) +
                       decode(TABLE_ROLLBACK_COL, ''ON'', 128, 0) +
                       decode(WORKSPACE_ROLLBACK_COL, ''ON'', 256, 0) +
                       decode(WORKSPACE_REMOVE_COL, ''ON'', 512, 0) +
                       decode(TABLE_IMPORT_COL, ''ON'', 1024, 0))' ;

  execute immediate
    'update wmsys.wm$udtrig_info
     set trig_flag = null' ;
  commit ;

  execute immediate 'alter table wmsys.wm$udtrig_info modify (trig_flag integer)' ;

  execute immediate 'update wmsys.wm$udtrig_info set trig_flag = tmp_flag' ;
  commit ;

  execute immediate
    'declare
       cnt integer ;
       cursor udt_procs is
         select trig_owner_name, trig_name, trig_procedure, trig_code, rowid
         from wmsys.wm$udtrig_info
         where trig_procedure is not null and
               bitand(trig_flag, 4096)=0 ;
     begin
       for udt_rec in udt_procs loop
         select count(*) into cnt
         from dba_dependencies
         where owner = udt_rec.trig_owner_name and
               name = upper(udt_rec.trig_procedure) and
               referenced_owner = ''SYS'' and
               referenced_name = ''DBMS_STANDARD'' ;

         if (cnt>0) then
           update wmsys.wm$udtrig_info
           set trig_flag = trig_flag - bitand(trig_flag, 4096) + 4096
           where rowid = udt_rec.rowid ;
         end if ;
       end loop;
     end;' ;

  execute immediate 'alter table wmsys.wm$udtrig_info drop (tmp_flag, TAB_MERGE_WO_REMOVE_COL, TAB_MERGE_W_REMOVE_COL, WSPC_MERGE_WO_REMOVE_COL, WSPC_MERGE_W_REMOVE_COL, DML_COL, WORKSPACE_REFRESH_COL, TABLE_REFRESH_COL, TABLE_ROLLBACK_COL, WORKSPACE_ROLLBACK_COL, WORKSPACE_REMOVE_COL, TABLE_IMPORT_COL)' ;

  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (trig_flag integer)' ;

  execute immediate
    'update wmsys.wm$udtrig_dispatch_procs
     set trig_flag = (decode(BIR_FLAG, ''BIR'', 1, 0) +
                      decode(AIR_FLAG, ''AIR'', 2, 0) +
                      decode(BUR_FLAG, ''BUR'', 4, 0) +
                      decode(AUR_FLAG, ''AUR'', 8, 0) +
                      decode(BDR_FLAG, ''BDR'', 16, 0) +
                      decode(ADR_FLAG, ''ADR'', 32, 0))' ;
  commit ;

  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs drop (bir_flag, air_flag, bur_flag, aur_flag, bdr_flag, adr_flag)' ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_tab_columns
  where owner = 'WMSYS' and
        table_name = 'WM$ENV_VARS' and
        column_name = 'HIDDEN' ;

  if (cnt=1) then
    return ;
  end if;

  execute immediate 'alter table wmsys.wm$env_vars add (hidden integer default 0)' ;

  execute immediate 'update wmsys.wm$env_vars set hidden = 0 where hidden is null' ;
  commit ;
end;
/
grant execute on dbms_lob to wmsys ;
grant execute on dbms_utility to wmsys ;
grant execute on utl_file to wmsys ;
alter table wmsys.wm$constraints_table drop constraint wm$constraints_table_pk ;
alter table wmsys.wm$constraints_table add constraint wm$constraints_table_pk primary key(owner, constraint_name, status) ;
drop view wmsys.wm$parConflict_hierarchy_view ;
drop view wmsys.wm$curConflict_hierarchy_view ;
drop public synonym wm$parConflict_hierarchy_view ;
drop public synonym wm$curConflict_hierarchy_view ;
create or replace view wmsys.all_removed_workspaces as
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt
  where exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
 union
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt, 
       (select distinct workspace from wmsys.user_wm_privs) u
  where rwt.workspace_name = u.workspace
 union
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt
  where rwt.owner = (select username from all_users where user_id=userenv('schemaid'));
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
  TABLE_IMPORT
)
as 
(select trig_owner_name, 
        trig_name,
        table_owner_name,
        table_name,
        wmsys.ltUtil.getTrigTypes(trig_flag),
        status,
        when_clause,
        description,
        trig_code,       
        decode(bitand(event_flag, 1), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 2), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 4), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 8), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 16), 0, 'OFF', 'ON'),          
        decode(bitand(event_flag, 1024), 0, 'OFF', 'ON')
 from   wmsys.wm$udtrig_info
 where  (trig_owner_name   = (select username from all_users where user_id=userenv('schemaid'))    OR
         table_owner_name  = (select username from all_users where user_id=userenv('schemaid'))    OR
         EXISTS (
           SELECT 1
           FROM   user_sys_privs
           WHERE  privilege = 'CREATE ANY TRIGGER'
         ) 
         OR
         EXISTS  
         ( SELECT 1 
           FROM   session_roles sr, role_sys_privs rsp 
           WHERE  sr.role       = rsp.role     AND  
                  rsp.privilege = 'CREATE ANY TRIGGER' ))  AND
         internal_type   = 'USER_DEFINED') 
with READ ONLY;
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
from wmsys.wm$workspaces_table s where owner = (select username from all_users where user_id=userenv('schemaid'))
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
    select 'WM_ADMIN_ROLE' from dual where (select username from all_users where user_id=userenv('schemaid')) = 'SYS') 
WITH READ ONLY;
create or replace view wmsys.user_removed_workspaces as
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt
  where rwt.owner = (select username from all_users where user_id=userenv('schemaid'));
create or replace view wmsys.user_wm_constraints as
  select /*+ ORDERED */ 
   constraint_name, constraint_type, table_name, 
   search_condition, status, index_owner, index_name, index_type
  from   wmsys.wm$constraints_table ct, user_views uv
  where  ct.owner = (select username from all_users where user_id=userenv('schemaid')) and
         ct.table_name = uv.view_name ; 
create or replace view wmsys.user_wm_cons_columns as
select /*+ ORDERED */ t1.* from 
wmsys.wm$cons_columns t1, user_views t2
where t1.owner = (select username from all_users where user_id=userenv('schemaid'))
and t1.table_name = t2.view_name;
create or replace view wmsys.user_wm_ind_columns as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position, 
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid')) 
and t1.index_name = t2.index_name 
and t1.constraint_type != 'P'
union
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position-1, 
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid')) 
and t1.index_name = t2.index_name 
and t1.constraint_type = 'P'
and t2.column_name not in ('VERSION','DELSTATUS') ;
create or replace view wmsys.user_wm_ind_expressions as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, user_ind_expressions t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid')) 
and t1.index_name = t2.index_name ;
create or replace view wmsys.user_wm_locked_tables as 
select t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state 
from wmsys.wm$all_locks_view t
where t.table_owner = (select username from all_users where user_id=userenv('schemaid'))
with READ ONLY;
create or replace view wmsys.user_wm_modified_tables as
select table_name, workspace, savepoint 
from 
      (select distinct o.table_name, o.workspace, 
              nvl(s.savepoint, 'LATEST') savepoint,
              min(s.is_implicit) imp, count(s.version) counter 
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s
      where substr(o.table_name, 1, instr(table_name,'.')-1) = (select username from all_users where user_id=userenv('schemaid')) and 
            o.version = s.version (+) 
      group by o.table_name, o.workspace, savepoint) 
where (imp = 0 or imp is null or counter = 1);
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
    select 'WM_ADMIN_ROLE' from dual where (select username from all_users where user_id=userenv('schemaid')) = 'SYS'
    UNION ALL
    select username from all_users where user_id=userenv('schemaid')
    UNION ALL
    select 'PUBLIC' from dual)
WITH READ ONLY;
create or replace view wmsys.user_wm_ric_info 
  (ct_owner, ct_name, pt_owner, pt_name, ric_name, 
   ct_cols, pt_cols, r_constraint_name, delete_rule, status) as
  select ct_owner, ct_name, pt_owner, pt_name, ric_name, 
         rtrim(ct_cols,','), rtrim(pt_cols,','),
         pt_unique_const_name, my_mode, status 
  from   wmsys.wm$ric_table rt, user_views uv
  where  uv.view_name = rt.ct_name and
         rt.ct_owner = (select username from all_users where user_id=userenv('schemaid')); 
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
  TABLE_IMPORT
)
as 
select trig_name,
       table_owner_name,
       table_name,
       wmsys.ltUtil.getTrigTypes(trig_flag),
       status,
       when_clause,
       description,
       trig_code,       
       decode(bitand(event_flag, 1), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 2), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 4), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 8), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 16), 0, 'OFF', 'ON'),          
       decode(bitand(event_flag, 1024), 0, 'OFF', 'ON')
from   wmsys.wm$udtrig_info
where  trig_owner_name = (select username from all_users where user_id=userenv('schemaid'))  and
       internal_type   = 'USER_DEFINED' 
with READ ONLY;
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from   wmsys.wm$versioned_tables t
where  t.owner = (select username from all_users where user_id=userenv('schemaid'))
WITH READ ONLY;
create or replace view wmsys.user_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg from
(select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt, wmsys.wm$vt_errors_table et
where vt.owner = et.owner
and   vt.table_name = et.table_name
and   vt.index_type = et.index_type
and   vt.index_field = et.index_field
and   vt.owner = (select username from all_users where user_id=userenv('schemaid'));
create or replace view wmsys.user_workspaces as
select st.workspace, st.workspace_lock_id workspace_id, st.parent_workspace, ssp.savepoint parent_savepoint, 
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
       decode(substr(st.wm_lockmode, 1, instr(st.wm_lockmode, ',')-1), 
              'S', 'SHARED', 
              'E', 'EXCLUSIVE', 
              'WE', 'WORKSPACE EXCLUSIVE', 
              'VE', 'VERSION EXCLUSIVE', 
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(st.wm_lockmode, instr(st.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from   wmsys. wm$workspaces_table st, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  st.owner = (select username from all_users where user_id=userenv('schemaid')) and ((ssp.position is null) or ( ssp.position = 
	(select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and 
       st.parent_version = ssp.version (+) and 
       st.workspace = rst.workspace (+) and 
       to_char(s.sid(+)) = substr(st.freeze_owner, 1, instr(st.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',')+1)
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
       and u.owner = (select username from all_users where user_id=userenv('schemaid')) and
       t.workspace = max.pw (+) and
       t.version = parent_vers.parent_version (+)
WITH READ ONLY;
@@owmv1120.plb
