@@owmr1116.plb
update wmsys.wm$env_vars set value = '10.2.0.1.0' where name = 'OWM_VERSION';
commit;
begin
  if (wmsys.owm_mig_pkg.prv_version <= 'A.2.0.1.0') then
    delete from wmsys.wm$sysparam_all_values where name = 'USE_SCALAR_TYPES_FOR_VALIDTIME';
    delete from wmsys.wm$sysparam_all_values where name = 'KEEP_REMOVED_WORKSPACES_INFO' ;
    delete from wmsys.wm$sysparam_all_values where name = 'ADD_UNIQUE_COLUMN_TO_HISTORY_VIEW' ;
    delete from wmsys.wm$sysparam_all_values where name = 'COMPRESS_PARENT_AFTER_REMOVE' ;
    delete from wmsys.wm$sysparam_all_values where name = 'ROW_LEVEL_LOCKING' ;
    delete from wmsys.wm$sysparam_all_values where name = 'TARGET_PGA_MEMORY' ;
  end if ;

  commit ;
end;
/
begin
  if (wmsys.owm_mig_pkg.prv_version <= 'A.2.0.1.0') then
    execute immediate 'drop table wmsys.wm$removed_workspaces_table' ;
  end if ;
end;
/
drop view wmsys.user_removed_workspaces ;
drop public synonym user_removed_workspaces ;
drop view wmsys.all_removed_workspaces ;
drop public synonym all_removed_workspaces ;
drop view wmsys.dba_removed_workspaces ;
drop public synonym dba_removed_workspaces ;
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
begin
  if (wmsys.owm_mig_pkg.prv_version <= 'A.2.0.2.0') then
    execute immediate 'drop table wmsys.wm$hint_table' ;
  end if ;
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
       t.hist history,
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
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.all_wm_versioned_tables as
 select /*+ ORDERED */ vt.table_name, vt.owner, 
        disabling_ver state,
        vt.hist history,
        decode(vt.notification,0,''NO'',1,''YES'') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        sys.ltadm.AreThereConflicts(vt.owner, vt.table_name) conflict,
        sys.ltadm.AreThereDiffs(vt.owner, vt.table_name) diff
 from wmsys.wm$versioned_tables vt, all_views av
 where vt.table_name = av.view_name and vt.owner = av.owner
union all
 select /*+ ORDERED */ vt.table_name, vt.owner, 
        disabling_ver state,
        vt.hist history,
        decode(vt.notification,0,''NO'',1,''YES'') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        sys.ltadm.AreThereConflicts(vt.owner, vt.table_name) conflict,
        sys.ltadm.AreThereDiffs(vt.owner, vt.table_name) diff
 from wmsys.wm$versioned_tables vt, all_tables at
 where vt.table_name = at.table_name and vt.owner = at.owner
WITH READ ONLY';

exception when compile_error then null ;
end;
/
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
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
cursor ver_tabs is
  select distinct owner
  from wmsys.wm$versioned_tables ;

begin
  for ver_rec in ver_tabs loop
    wmsys.wm$execSQL('revoke select on wmsys.wm$version_hierarchy_table from ' || ver_rec.owner) ;
    wmsys.wm$execSQL('revoke select on wmsys.wm$workspaces_table from ' || ver_rec.owner) ;
    wmsys.wm$execSQL('revoke select on wmsys.wm$nextver_table from ' || ver_rec.owner) ;
    wmsys.wm$execSQL('revoke select on wmsys.wm$modified_tables from ' || ver_rec.owner) ;
    wmsys.wm$execSQL('revoke select on wmsys.wm$version_table from ' || ver_rec.owner) ;
  end loop ;
end;
/
begin
  wmsys.wm$execSQL('grant select on wmsys.wm$version_hierarchy_table to public') ;
  wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to public with grant option') ;
  wmsys.wm$execSQL('grant select on wmsys.wm$nextver_table to public') ;
  wmsys.wm$execSQL('grant select on wmsys.wm$modified_tables to public') ;
  wmsys.wm$execSQL('grant select on wmsys.wm$version_table to public with grant option') ;
end;
/
declare
  cursor trig_cur is
    select trigger_name
    from dba_triggers
    where owner = 'WMSYS' and
          trigger_name in ('NO_VM_DDL', 'NO_VM_DROP_A', 'NO_VM_DROP_E') ;

begin
  for trig_rec in trig_cur loop
    execute immediate 'drop trigger wmsys.' || trig_rec.trigger_name ;
  end loop ;
end;
/
declare
  cursor proc_cur is
    select object_name
    from dba_objects
    where owner = 'WMSYS' and
          object_type = 'PROCEDURE' and
          object_name in ('NO_VM_ALTER_PROC', 'NO_VM_CREATE_PROC', 'NO_VM_DROP_PROC') ;

begin
  for proc_rec in proc_cur loop
    execute immediate 'drop procedure wmsys.' || proc_rec.object_name ;
  end loop ;
end;
/
revoke select any dictionary from wmsys ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);

  cursor pkgs_cur is
  select object_name
  from dba_objects
  where owner = 'WMSYS' and
        object_type='PACKAGE' ;
begin

  for p_rec in pkgs_cur loop
    begin
      execute immediate 'drop package wmsys.' || p_rec.object_name ;
    exception when invalid_package then null;
    end ;
  end loop ;
end;
/
revoke execute on dbms_aq from wmsys ;
revoke execute on dbms_rls from wmsys ;
revoke execute on dbms_aqadm from wmsys ;
revoke execute on dbms_repcat from wmsys ;
revoke execute on dbms_defer_sys from wmsys ;
revoke execute on dbms_lock from wmsys ;
revoke select any table, insert any table, update any table, delete any table from wmsys ;
revoke lock any table from wmsys ;
revoke create any table, drop any table, alter any table from wmsys ;
revoke create any index, drop any index, alter any index from wmsys ;
revoke create any view, drop any view from wmsys ;
revoke create any trigger, drop any trigger, alter any trigger from wmsys ;
revoke create any procedure, drop any procedure, execute any procedure, alter any procedure from wmsys ;
revoke administer database trigger, create sequence, execute any type from wmsys ;
drop view wmsys.wm$workspace_sessions_view ;
create or replace view sys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr
from   v$lock dl,
       wmsys.wm$workspaces_table wt,
       sys.v$session st
where  dl.type    = 'UL' and
       dl.id1 - 1 = wt.workspace_lock_id and
       dl.sid     = st.sid;
drop view wmsys.dba_workspace_sessions ;
create or replace view sys.dba_workspace_sessions as
select sut.username, 
       sut.workspace, 
       sut.sid, 
       decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from   sys.wm$workspace_sessions_view sut,
       sys.v$transaction t
where  sut.saddr = t.ses_addr (+)
WITH READ ONLY;
grant  select on sys.dba_workspace_sessions to wm_admin_role;
create or replace public synonym dba_workspace_sessions for sys.dba_workspace_sessions;
drop view wmsys.user_workspaces ;
create or replace view sys.user_workspaces as
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
grant select on sys.user_workspaces to public with grant option;
create or replace public synonym user_workspaces for sys.user_workspaces;
drop view wmsys.all_workspaces ;
create or replace view sys.all_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint, 
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
       decode(substr(asp.wm_lockmode, 1, instr(asp.wm_lockmode, ',')-1), 
              'S', 'SHARED', 
              'E', 'EXCLUSIVE', 
              'WE', 'WORKSPACE EXCLUSIVE', 
              'VE', 'VERSION EXCLUSIVE', 
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(asp.wm_lockmode, instr(asp.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
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
grant select on sys.all_workspaces to public with grant option;
create or replace public synonym all_workspaces for sys.all_workspaces;
drop view wmsys.dba_workspaces ;
create or replace view sys.dba_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint, 
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
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  nvl(ssp.is_implicit,1) = 1 and 
       asp.parent_version  = ssp.version (+) and 
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and 
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
create or replace public synonym dba_workspaces for sys.dba_workspaces ;
grant select on sys.dba_workspaces to wm_admin_role, select_catalog_role;
drop view wmsys.wm_compress_batch_sizes ;
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate 'create or replace package sys.ltadm as function getSystemParameter(name varchar2) return  varchar2; end;' ;

  execute immediate '
create or replace force view sys.wm_compress_batch_sizes as
select /*+ RULE */ vt.owner, vt.table_name, 
decode(dt.data_type,
''CHAR'',decode(dt.num_buckets,null,''TABLE'',0,''TABLE'',1,''TABLE'',''TABLE/PRIMARY_KEY_RANGE''),
''VARCHAR2'',decode(dt.num_buckets,null,''TABLE'',0,''TABLE'',1,''TABLE'',''TABLE/PRIMARY_KEY_RANGE''),
''NUMBER'',decode(dt.num_buckets,null,''TABLE'',0,''TABLE'',''TABLE/PRIMARY_KEY_RANGE''),
''DATE'',decode(dt.num_buckets,null,''TABLE'',0,''TABLE'',''TABLE/PRIMARY_KEY_RANGE''),
''TIMESTAMP'',decode(dt.num_buckets,null,''TABLE'',0,''TABLE'',''TABLE/PRIMARY_KEY_RANGE''),
''TABLE'') BATCH_SIZE ,
decode(dt.data_type,
''CHAR'',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets), 
''VARCHAR2'',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets), 
''NUMBER'',decode(dt.num_buckets,null,1,0,1,1,(sys.ltadm.GetSystemParameter(''NUMBER_OF_COMPRESS_BATCHES'')),dt.num_buckets),
''DATE'',decode(dt.num_buckets,null,1,0,1,1,(sys.ltadm.GetSystemParameter(''NUMBER_OF_COMPRESS_BATCHES'')),dt.num_buckets),
''TIMESTAMP'',decode(dt.num_buckets,null,1,0,1,1,(sys.ltadm.GetSystemParameter(''NUMBER_OF_COMPRESS_BATCHES'')),dt.num_buckets),
1) NUM_BATCHES
from wmsys.wm$versioned_tables vt, dba_ind_columns di, dba_tab_columns dt
where di.table_owner = vt.owner 
and   di.table_name = vt.table_name || ''_LT'' 
and   di.index_name = vt.table_name || ''_PKI$''
and   di.column_position = 1
and   dt.owner = vt.owner
and   dt.table_name = vt.table_name || ''_LT''
and   dt.column_name = di.column_name';

exception when compile_error then null ;
end;
/
create or replace public synonym wm_compress_batch_sizes for sys.wm_compress_batch_sizes ;
grant select on sys.wm_compress_batch_sizes to wm_admin_role  ;
begin
  execute immediate 'drop package sys.ltadm' ;
end;
/
declare
  compile_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(compile_error, -24344);
begin
  execute immediate '
create or replace force view wmsys.wm$all_locks_view as 
select t.table_owner, t.table_name,
       decode(sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKMODE''), ''E'', ''EXCLUSIVE'', ''S'', ''SHARED'', ''VE'', ''VERSION EXCLUSIVE'', ''WE'', ''WORKSPACE EXCLUSIVE'') Lock_mode, 
       sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKUSER'') Lock_owner, 
       sys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),''ROW_LOCKSTATE'') Locking_state
from (select table_owner, table_name, info from 
      table( cast(sys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t 
with READ ONLY';

exception when compile_error then null ;
end;
/
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') IsRefreshed, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, sys.user_workspaces uw
where mp.workspace = uw.workspace ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, sys.user_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
create or replace view wmsys.all_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') ISREFRESHED, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') PARENT_FLAG
from wmsys.wm$mp_parent_workspaces_table mp, sys.all_workspaces aw
where mp.workspace = aw.workspace ;
create or replace view wmsys.all_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, sys.all_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
declare
  invalid_function EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_function, -04043);

  cursor adt_cur is
    select func_name
    from wmsys.wm$adt_func_table ;
begin
  for adt_rec in adt_cur loop
    begin
      execute immediate 'drop function wmsys.OVMADT' || adt_rec.func_name ;

    exception when invalid_function then null ;
    end;
  end loop ;
end;
/
update wmsys.wm$udtrig_dispatch_procs set dispatcher_name = 'system' || substr(dispatcher_name, 6)
where substr(lower(dispatcher_name), 1, 6) = 'wmsys.' ;
drop function wmsys.wm$convertDbVersion ;
create or replace function sys.wm$convertDbVersion wrapped 
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
270 158
7YzoyUrxd7Gdk3sWAMdGV8+fL5QwgxDxJJkVfC+VkPg+SC+DrOMNRVR70nI9ORTm8W/ErAaP
cJnFRc7uAHmNFt9eFe3+Er9x8ZR6zH7X7p92ueySRSRMJXm+JJAoLs2JFhTejcPhl1oUQhTo
0efDAo9P4VRZo6becfekBOpTovNpbMYuPVyah8bHHdXUbIYaA0eo2gEeEGAztJ+oNixxaa0i
EE+K6efC46r7IKKCRJYsbJ88LzT0b6UqdJW091XTU/EPyBesBhwRJ6zxHIV4Nd4oIYI1tB3X
LmkzQDDyHva7VR32//hzmotzn7t3KDLctSqW7W3oggR6ptu2iZs=

/
grant execute on sys.wm$convertDBVersion to public;
grant select on wmsys.wm$udtrig_info to system ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$ric_locking_table to sys') ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$anc_version_view to sys') ;
declare
  type_name_var   varchar2(100);
  sql_string      varchar2(32000);

  cursor adt_func_cur is 
    select func_name, type_name 
    from wmsys.wm$adt_func_table;

begin
  for adt_rec in adt_func_cur loop

    if (substr(upper(adt_rec.type_name), 1, 7) = 'REF TO ') then 
      type_name_var := replace(upper(adt_rec.type_name), 'REF TO ', 'REF ');
    else
      type_name_var := adt_rec.type_name ;
    end if;  

    sql_string := 'create or replace function SYS.OVMADT' || adt_rec.func_name || ' return ' || type_name_var || ' is
                   begin
                     return null;
                   end;';

    execute immediate sql_string;

    sql_string := 'grant execute on SYS.OVMADT' || adt_rec.func_name || ' to public with grant option';
    execute immediate sql_string;
  end loop;
end;
/
declare
  l varchar2(32000) ;
begin
  select text into l
  from dba_views
  where owner = 'WMSYS' and
        view_name = 'WM_INSTALLATION' ;

  execute immediate 'drop view wmsys.wm_installation' ;

  execute immediate 'create or replace view sys.wm_installation as ' || l ;
end;
/
create or replace public synonym wm_installation for sys.wm_installation ;
create or replace public synonym dbms_wm for sys.lt ;
update sys.exppkgact$ set schema='SYS' where schema='WMSYS' and package='LT_EXPORT_PKG' ;
commit;
declare
  cursor oper_cur is
    select operator_name
    from dba_operators
    where owner = 'WMSYS' and
          operator_name in ('WM_OVERLAPS', 'WM_INTERSECTION', 'WM_LDIFF', 'WM_RDIFF', 'WM_CONTAINS',
                            'WM_MEETS', 'WM_LESSTHAN', 'WM_GREATERTHAN', 'WM_EQUALS') ;

  invalid_operator EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_operator, -29807);

begin
  for oper_rec in oper_cur loop
    begin
      execute immediate 'drop public synonym ' || oper_rec.operator_name ;
      execute immediate 'drop operator wmsys.' || oper_rec.operator_name ;

    exception when invalid_operator then null ;
    end ;
  end loop ;
end;
/
declare
policy_name varchar2(30) ;
found integer ;

type cursor_type is ref cursor ;
ols_rec cursor_type;
ols_policy_str varchar2(200) :=
  'select policy_name
   from dba_sa_table_policies dp, wmsys.wm$versioned_tables vt
   where dp.schema_name = vt.owner
     and dp.table_name = vt.table_name || ''_LT''' ;

no_view EXCEPTION;
PRAGMA EXCEPTION_INIT(no_view, -00942);

begin
  open ols_rec for ols_policy_str ;
  loop
    fetch ols_rec into policy_name ;
    exit when ols_rec%NOTFOUND ;

    select count(*) into found
    from session_roles
    where role = policy_name || '_DBA' ;

    if (found=0) then
      execute immediate 'grant ' || policy_name || '_DBA to sys' ;
    end if ;

    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTADM'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTDDL'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTRIC'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_BULK_LOAD_PKG'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_DDL_PKG'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_IEXP_PKG'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_MIG_PKG'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_MP_PKG'', null) ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''WM_DDL_UTIL'', null) ; end;' ;

    if (found=0) then
      execute immediate 'revoke ' || policy_name || '_DBA from sys' ;
    end if ;
  end loop ;
  close ols_rec ;

exception when no_view then
  null;
end;
/
declare
  cursor vttab_cur is
    select owner, table_name
    from wmsys.wm$versioned_tables ;

  no_table EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_table, -00942);
begin
  for vttab_rec in vttab_cur loop
    begin
      execute immediate 'drop table ' || vttab_rec.owner || '.' || vttab_rec.table_name || '_LCK' ;

    exception when no_table then null; 
    end;
  end loop;
end;
/
declare
  cursor adt_cur is
    select func_name
    from wmsys.wm$adt_func_table ;
begin
  for adt_rec in adt_cur loop
    begin
      execute immediate 'grant execute on ' || adt_rec.func_name || ' to system' ;

    exception when others then null; 
    end;
  end loop;
end;
/
