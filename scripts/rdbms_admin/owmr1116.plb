@@owmr1120.plb
update wmsys.wm$env_vars set value = '11.1.0.6.0' where name = 'OWM_VERSION';
commit;
revoke alter user from wmsys ;
declare
  cnt      integer ;
begin
  select count(*) into cnt
  from dba_tab_columns
  where owner = 'WMSYS' and
        table_name = 'WM$UDTRIG_INFO' and
        column_name = 'TRIG_FLAG' ;

  if (cnt=0) then
    return ;
  end if;

  execute immediate 'alter table wmsys.wm$udtrig_info rename column trig_flag to trig_type' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (tmp_flag varchar2(3))' ;

  execute immediate 'alter table wmsys.wm$udtrig_info add (TAB_MERGE_WO_REMOVE_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (TAB_MERGE_W_REMOVE_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (WSPC_MERGE_WO_REMOVE_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (WSPC_MERGE_W_REMOVE_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (DML_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (WORKSPACE_REFRESH_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (TABLE_REFRESH_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (TABLE_ROLLBACK_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (WORKSPACE_ROLLBACK_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (WORKSPACE_REMOVE_COL varchar2(4))' ;
  execute immediate 'alter table wmsys.wm$udtrig_info add (TABLE_IMPORT_COL varchar2(4))' ;

  execute immediate
    'update wmsys.wm$udtrig_info
     set TAB_MERGE_WO_REMOVE_COL = decode(bitand(event_flag, 1), 1, ''ON'', ''OFF''),
         TAB_MERGE_W_REMOVE_COL = decode(bitand(event_flag, 2), 2, ''ON'', ''OFF''),
         WSPC_MERGE_WO_REMOVE_COL = decode(bitand(event_flag, 4), 4, ''ON'', ''OFF''),
         WSPC_MERGE_W_REMOVE_COL= decode(bitand(event_flag, 8), 8, ''ON'', ''OFF'') ,
         DML_COL = decode(bitand(event_flag, 16), 16, ''ON'', ''OFF''),
         WORKSPACE_REFRESH_COL = decode(bitand(event_flag, 32), 32, ''ON'', ''OFF''),
         TABLE_REFRESH_COL = decode(bitand(event_flag, 64), 64, ''ON'', ''OFF''),
         TABLE_ROLLBACK_COL = decode(bitand(event_flag, 128), 128, ''ON'', ''OFF''),
         WORKSPACE_ROLLBACK_COL = decode(bitand(event_flag, 256), 256, ''ON'', ''OFF''),
         WORKSPACE_REMOVE_COL = decode(bitand(event_flag, 512), 512, ''ON'', ''OFF''),
         TABLE_IMPORT_COL = decode(bitand(event_flag, 1024), 1024, ''ON'', ''OFF'')' ;
  commit ;

  execute immediate
    'declare
       type_var varchar2(3) ;
     begin
       for row_rec in (select u.*, u.rowid r from wmsys.wm$udtrig_info u) loop
         if (bitand(row_rec.trig_type, 2048)!=0) then
           type_var := ''ADS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 1024)!=0) then
           type_var := ''BDS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 512)!=0) then
           type_var := ''AUS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 256)!=0) then
           type_var := ''BUS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 128)!=0) then
           type_var := ''AIS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 64)!=0) then
           type_var := ''BIS'' ;
         end if ;

         if (bitand(row_rec.trig_type, 32)!=0) then
           type_var := ''ADR'' ;
         end if ;

         if (bitand(row_rec.trig_type, 16)!=0) then
           type_var := ''BDR'' ;
         end if ;

         if (bitand(row_rec.trig_type, 8)!=0) then
           type_var := ''AUR'' ;
         end if ;

         if (bitand(row_rec.trig_type, 4)!=0) then
           type_var := ''BUR'' ;
         end if ;

         if (bitand(row_rec.trig_type, 2)!=0) then
           type_var := ''AIR'' ;
         end if ;

         if (bitand(row_rec.trig_type, 1)!=0) then
           type_var := ''BIR'' ;
         end if ;

         update wmsys.wm$udtrig_info
         set tmp_flag = type_var
         where rowid = row_rec.r;
       end loop;
     end;'  ;

  execute immediate 'update wmsys.wm$udtrig_info set trig_type = null' ;
  commit ;

  execute immediate 'alter table wmsys.wm$udtrig_info modify(trig_type varchar2(3))' ;

  execute immediate 'update wmsys.wm$udtrig_info set trig_type = tmp_flag' ;
  commit ;

  execute immediate 'alter table wmsys.wm$udtrig_info drop (tmp_flag, event_flag)' ;

  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (bir_flag varchar2(3))' ;
  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (air_flag varchar2(3))' ;
  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (bur_flag varchar2(3))' ;
  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (aur_flag varchar2(3))' ;
  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (bdr_flag varchar2(3))' ;
  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs add (adr_flag varchar2(3))' ;

  execute immediate
    'update wmsys.wm$udtrig_dispatch_procs
     set bir_flag = decode(bitand(trig_flag, 1), 1, ''BIR'', null),
         air_flag = decode(bitand(trig_flag, 2), 2, ''AIR'', null),
         bur_flag = decode(bitand(trig_flag, 4), 4, ''BUR'', null),
         aur_flag = decode(bitand(trig_flag, 8), 8, ''AUR'', null),
         bdr_flag = decode(bitand(trig_flag, 16), 16, ''BDR'', null),
         adr_flag = decode(bitand(trig_flag, 32), 32, ''ADR'', null)' ;
  commit ;

  execute immediate 'alter table wmsys.wm$udtrig_dispatch_procs drop column trig_flag' ;

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

  if (cnt=0) then
    return ;
  end if;

  execute immediate 'delete wmsys.wm$env_vars where hidden=1' ;
  commit ;

  execute immediate 'alter table wmsys.wm$env_vars drop column hidden' ;
end;
/
create or replace view wmsys.wm_installation as 
  select * from wmsys.wm$env_vars
 union
  select name, value from wmsys.wm$sysparam_all_values sv where isdefault = 'YES' and
	 not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name)
WITH READ ONLY ;
revoke execute on dbms_lob from wmsys ;
revoke execute on dbms_utility from wmsys ;
revoke execute on utl_file from wmsys ;
delete wmsys.wm$constraints_table ct1
where status = 'DISABLED' and
      exists(select 1
             from wmsys.wm$constraints_table ct2
             where ct1.owner = ct2.owner and
                   ct1.constraint_name = ct2.constraint_name and
                   ct2.status = 'ENABLED') ;
commit ;
alter table wmsys.wm$constraints_table drop constraint wm$constraints_table_pk ;
alter table wmsys.wm$constraints_table add constraint wm$constraints_table_pk primary key(owner, constraint_name) ;
create or replace view wmsys.wm$parConflict_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = sys_context('lt_ctx','parent_conflict_state') and
         version   > sys_context('lt_ctx','parent_ver')
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_hierarchy_view as 
   select * from wmsys.wm$version_hierarchy_table 
   where workspace = nvl(sys_context('lt_ctx','conflict_state'),'LIVE')
WITH READ ONLY;
create public synonym wm$curConflict_hierarchy_view for wmsys.wm$curConflict_hierarchy_view;
create public synonym wm$parConflict_hierarchy_view for wmsys.wm$parConflict_hierarchy_view;
execute wmsys.wm$execSQL('grant select,insert,update,delete on wmsys.wm$parConflict_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select,insert,update,delete on wmsys.wm$curConflict_hierarchy_view to public with grant option');
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
  where rwt.owner = USER;
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
        TABLE_IMPORT_COL
 from   wmsys.wm$udtrig_info
 where  (trig_owner_name   = USER    OR
         table_owner_name  = USER    OR
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
from wmsys.wm$workspaces_table s where owner = USER
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
create or replace view wmsys.user_removed_workspaces as
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt
  where rwt.owner = USER;
create or replace view wmsys.user_wm_constraints as
  select /*+ ORDERED */ 
   constraint_name, constraint_type, table_name, 
   search_condition, status, index_owner, index_name, index_type
  from   wmsys.wm$constraints_table ct, user_views uv
  where  ct.owner = USER and
         ct.table_name = uv.view_name ; 
create or replace view wmsys.user_wm_cons_columns as
select /*+ ORDERED */ t1.* from 
wmsys.wm$cons_columns t1, user_views t2
where t1.owner = USER
and t1.table_name = t2.view_name;
create or replace view wmsys.user_wm_ind_columns as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position, 
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = USER 
and t1.index_name = t2.index_name 
and t1.constraint_type != 'P'
union
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position-1, 
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = USER 
and t1.index_name = t2.index_name 
and t1.constraint_type = 'P'
and t2.column_name not in ('VERSION','DELSTATUS') ;
create or replace view wmsys.user_wm_ind_expressions as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, user_ind_expressions t2
where t1.index_owner = USER 
and t1.index_name = t2.index_name ;
create or replace view wmsys.user_wm_locked_tables as 
select t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state 
from wmsys.wm$all_locks_view t
where t.table_owner = USER
with READ ONLY;
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
create or replace view wmsys.user_wm_ric_info 
  (ct_owner, ct_name, pt_owner, pt_name, ric_name, 
   ct_cols, pt_cols, r_constraint_name, delete_rule, status) as
  select ct_owner, ct_name, pt_owner, pt_name, ric_name, 
         rtrim(ct_cols,','), rtrim(pt_cols,','),
         pt_unique_const_name, my_mode, status 
  from   wmsys.wm$ric_table rt, user_views uv
  where  uv.view_name = rt.ct_name and
         rt.ct_owner = USER; 
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
       TABLE_IMPORT_COL
from   wmsys.wm$udtrig_info
where  trig_owner_name = USER  and
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
where  t.owner = USER
WITH READ ONLY;
create or replace view wmsys.user_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg from
(select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt, wmsys.wm$vt_errors_table et
where vt.owner = et.owner
and   vt.table_name = et.table_name
and   vt.index_type = et.index_type
and   vt.index_field = et.index_field
and   vt.owner = USER;
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
from   wmsys.wm$workspaces_table st, wmsys.wm$workspace_savepoints_table ssp, 
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  st.owner = USER and ((ssp.position is null) or ( ssp.position = 
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
       and u.owner = USER and
       t.workspace = max.pw (+) and
       t.version = parent_vers.parent_version (+)
WITH READ ONLY;
