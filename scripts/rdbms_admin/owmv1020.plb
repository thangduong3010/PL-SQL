update wmsys.wm$env_vars set value = '11.1.0.6.0' where name = 'OWM_VERSION';
commit;
begin
  insert into wmsys.wm$sysparam_all_values values ('USE_SCALAR_TYPES_FOR_VALIDTIME', 'ON', 'NO');
  insert into wmsys.wm$sysparam_all_values values ('USE_SCALAR_TYPES_FOR_VALIDTIME', 'OFF', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('KEEP_REMOVED_WORKSPACES_INFO', 'ON', 'NO');
  insert into wmsys.wm$sysparam_all_values values ('KEEP_REMOVED_WORKSPACES_INFO', 'OFF', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('ADD_UNIQUE_COLUMN_TO_HISTORY_VIEW', 'ON', 'NO');
  insert into wmsys.wm$sysparam_all_values values ('ADD_UNIQUE_COLUMN_TO_HISTORY_VIEW', 'OFF', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('COMPRESS_PARENT_AFTER_REMOVE', 'ON', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('COMPRESS_PARENT_AFTER_REMOVE', 'OFF', 'NO');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('ROW_LEVEL_LOCKING', 'ON', 'NO');
  insert into wmsys.wm$sysparam_all_values values ('ROW_LEVEL_LOCKING', 'OFF', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  delete from wmsys.wm$sysparam_all_values where name = 'NUMBER_OF_ROWS_TO_PROCESS' ;
  delete from wmsys.wm$env_vars where name = 'NUMBER_OF_ROWS_TO_PROCESS' ;
  insert into wmsys.wm$sysparam_all_values values ('TARGET_PGA_MEMORY', '8388608', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
create table wmsys.wm$removed_workspaces_table
   (owner varchar2(30), workspace_name varchar2(30), workspace_id integer,
    parent_workspace_name varchar2(30), parent_workspace_id integer,
    createtime date, retiretime date, description varchar2(1000), mp_root_id integer, isRefreshed integer,
    constraint removed_workspaces_pk primary key(workspace_id)) ;
create or replace view wmsys.user_removed_workspaces as
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt
  where rwt.owner = USER;
execute wmsys.wm$execSQL('grant select on wmsys.user_removed_workspaces to public with grant option');
create public synonym user_removed_workspaces for wmsys.user_removed_workspaces;
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
execute wmsys.wm$execSQL('grant select on wmsys.all_removed_workspaces to public with grant option');
create public synonym all_removed_workspaces for wmsys.all_removed_workspaces;
create or replace view wmsys.dba_removed_workspaces as
  select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
         createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
  from wmsys.wm$removed_workspaces_table rwt;
execute wmsys.wm$execSQL('grant select on wmsys.dba_removed_workspaces to wm_admin_role');
create public synonym dba_removed_workspaces for wmsys.dba_removed_workspaces;
create table wmsys.wm$hint_table(
  hint_id     integer,
  owner       varchar2(30),
  table_name  varchar2(30),
  hint_text   varchar2(4000),
  isDefault   integer) ;
alter table wmsys.wm$hint_table add constraint hint_table_unq1 unique(hint_id, owner, table_name, isDefault);
begin
  insert into wmsys.wm$hint_table values(1001, null, null, 'USE_NL(z1) ROWID(z1)', 1) ;
  insert into wmsys.wm$hint_table values(1002, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t1 $$VERINDEX(t1)$$) INDEX(t2 $$PKI(t2)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1003, null, null, 'NO_INDEX(a $$AP1(a)$$ $$AP2(a)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1004, null, null, 'ORDERED USE_NL(lt)', 1) ;
  insert into wmsys.wm$hint_table values(1005, null, null, 'USE_HASH(t2)', 1) ;
  insert into wmsys.wm$hint_table values(1008, null, null, 'USE_NL(lt)', 1) ;
  insert into wmsys.wm$hint_table values(1009, null, null, 'ORDERED INDEX(t2 $$VERINDEX(t2)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1010, null, null, 'USE_NL(z1) ROWID(z1)', 1) ;
  insert into wmsys.wm$hint_table values(1011, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t1 $$VERINDEX(t1)$$) INDEX(t2 $$PKI(t2)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1012, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1013, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1014, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1015, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1016, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1017, null, null, 'ORDERED', 1) ;
  insert into wmsys.wm$hint_table values(1018, null, null, 'ORDERED', 1) ;
  insert into wmsys.wm$hint_table values(1019, null, null, 'NO_UNNEST', 1) ;
  insert into wmsys.wm$hint_table values(1020, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1022, null, null, 'USE_NL(v1 v2)', 1) ;
  insert into wmsys.wm$hint_table values(1023, null, null, 'USE_NL(lt)', 1) ; 
  insert into wmsys.wm$hint_table values(1024, null, null, 'ORDERED', 1) ; 
  insert into wmsys.wm$hint_table values(1025, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1026, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1027, null, null, 'USE_NL(lt)', 1) ; 
  insert into wmsys.wm$hint_table values(1028, null, null, 'ORDERED', 1) ;
  insert into wmsys.wm$hint_table values(1029, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1030, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1031, null, null, 'ORDERED USE_NL(lt)', 1) ;
  insert into wmsys.wm$hint_table values(1032, null, null, 'USE_HASH(t2)', 1) ;
  insert into wmsys.wm$hint_table values(1033, null, null, 'ORDERED USE_NL(lt)', 1) ; 
  insert into wmsys.wm$hint_table values(1034, null, null, 'USE_HASH(t2)', 1) ; 
  insert into wmsys.wm$hint_table values(1035, null, null, 'USE_NL(z1) ROWID(z1)', 1) ; 
  insert into wmsys.wm$hint_table values(1036, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t2 $$PKI(t2)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1037, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1038, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1039, null, null, 'USE_NL(z1) ROWID(z1)', 1) ; 
  insert into wmsys.wm$hint_table values(1040, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t1 $$VERINDEX(t1)$$) INDEX(t2 $$PKI(t2)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1041, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1042, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1043, null, null, 'USE_NL(z1) ROWID(z1)', 1) ; 
  insert into wmsys.wm$hint_table values(1044, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t2 $$PKI(t2)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1045, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1046, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1047, null, null, 'USE_NL(z1) ROWID(z1)', 1) ; 
  insert into wmsys.wm$hint_table values(1048, null, null, 'ORDERED USE_NL(t1 t2) INDEX(t1 $$VERINDEX(t1)$$) INDEX(t2 $$PKI(t2)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1049, null, null, 'INDEX(vt $$VERINDEX(vt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1050, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1051, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1052, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1053, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1054, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1055, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1056, null, null, 'INDEX(t1 $$VERINDEX(t1)$$)', 1) ; 
  insert into wmsys.wm$hint_table values(1057, null, null, 'INDEX(lt $$VERINDEX(lt)$$)', 1) ;
  insert into wmsys.wm$hint_table values(1058, null, null, 'RULE', 1) ;
  insert into wmsys.wm$hint_table values(1059, null, null, 'RULE', 1) ;
  insert into wmsys.wm$hint_table values(1060, null, null, 'RULE', 1) ;

  insert into wmsys.wm$hint_table values(2005, null, null, 'INDEX(pt $$PKI(pt)$$)', 1) ;

  commit ;

exception when dup_val_on_index then
  null ;
end;
/
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner, 
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from   wmsys.wm$versioned_tables t, dba_views u 
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY;
create or replace view wmsys.all_wm_versioned_tables as
 select /*+ ORDERED */ t.table_name, t.owner, 
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_views av
 where t.table_name = av.view_name and t.owner = av.owner
union all
 select /*+ ORDERED */ t.table_name, t.owner, 
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_tables at
 where t.table_name = at.table_name and t.owner = at.owner
WITH READ ONLY;
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
declare
  invalid_revoke EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_revoke, -01927);
begin
  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$version_hierarchy_table from public') ;
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$workspaces_table from public') ;
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$nextver_table from public') ;
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$modified_tables from public') ;
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$version_table from public') ;
  exception when invalid_revoke then null;
  end ;
end;
/
declare
cursor ver_tabs is
  select distinct owner
  from wmsys.wm$versioned_tables ;

begin
  for ver_rec in ver_tabs loop
    wmsys.wm$execSQL('grant select on wmsys.wm$version_hierarchy_table to ' || ver_rec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to ' || ver_rec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$nextver_table to ' || ver_rec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$modified_tables to ' || ver_rec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$version_table to ' || ver_rec.owner || ' with grant option') ;
  end loop ;
end;
/
declare
  cursor trig_cur is
    select trigger_name
    from dba_triggers
    where owner = 'SYS' and
          trigger_name in ('NO_VM_ALTER', 'NO_VM_CREATE', 'NO_VM_DROP', 'NO_VM_DROP_A') ;

begin
  for trig_rec in trig_cur loop
    execute immediate 'drop trigger sys.' || trig_rec.trigger_name ;
  end loop ;
end;
/
declare
  cursor proc_cur is
    select object_name
    from dba_objects
    where owner = 'SYS' and
          object_type = 'PROCEDURE' and
          object_name in ('NO_VM_ALTER_PROC', 'NO_VM_CREATE_PROC', 'NO_VM_DROP_PROC') ;

begin
  for proc_rec in proc_cur loop
    execute immediate 'drop procedure sys.' || proc_rec.object_name ;
  end loop ;
end;
/
grant execute on dbms_rls to wmsys ;
grant execute on dbms_aqadm to wmsys ;
grant execute on dbms_repcat to wmsys ;
grant execute on dbms_defer_sys to wmsys ;
grant select any dictionary to wmsys with admin option ;
grant select any table, insert any table, update any table, delete any table to wmsys ;
grant lock any table to wmsys ;
grant create any table, drop any table, alter any table to wmsys ;
grant create any index, drop any index, alter any index to wmsys ;
grant create any view, drop any view to wmsys ;
grant create any trigger, drop any trigger, alter any trigger to wmsys ;
grant create any procedure, drop any procedure, execute any procedure, alter any procedure to wmsys ;
grant administer database trigger, create sequence, execute any type to wmsys ;
declare
  invalid_view EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_view, -00942);
begin
  execute immediate 'drop view sys.wm_installation' ;

exception when invalid_view then null ;
end;
/
drop view sys.wm$workspace_sessions_view ;
create or replace view wmsys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr
from   v$lock dl,
       wmsys.wm$workspaces_table wt,
       v$session st
where  dl.type    = 'UL' and
       dl.id1 - 1 = wt.workspace_lock_id and
       dl.sid     = st.sid;
drop view sys.dba_workspace_sessions ;
create or replace view wmsys.dba_workspace_sessions as
select sut.username, 
       sut.workspace, 
       sut.sid, 
       decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from   wmsys.wm$workspace_sessions_view sut,
       v$transaction t
where  sut.saddr = t.ses_addr (+)
WITH READ ONLY;
grant  select on wmsys.dba_workspace_sessions to wm_admin_role;
create or replace public synonym dba_workspace_sessions for wmsys.dba_workspace_sessions;
drop view sys.user_workspaces ;
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
grant select on wmsys.user_workspaces to public with grant option;
create or replace public synonym user_workspaces for wmsys.user_workspaces;
drop view sys.all_workspaces ;
create or replace view wmsys.all_workspaces as
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
grant select on wmsys.all_workspaces to public with grant option;
create or replace public synonym all_workspaces for wmsys.all_workspaces;
drop view sys.dba_workspaces ;
create or replace view wmsys.dba_workspaces as
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
create or replace public synonym dba_workspaces for wmsys.dba_workspaces ;
grant select on wmsys.dba_workspaces to wm_admin_role, select_catalog_role;
drop view sys.wm_compress_batch_sizes ;
create or replace view wmsys.wm_compress_batch_sizes as
select /*+ RULE */ vt.owner, vt.table_name, 
decode(dt.data_type,
'CHAR',decode(dt.num_buckets,null,'TABLE',0,'TABLE',1,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
'VARCHAR2',decode(dt.num_buckets,null,'TABLE',0,'TABLE',1,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
'NUMBER',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
'DATE',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
'TIMESTAMP',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
'TABLE') BATCH_SIZE ,
decode(dt.data_type,
'CHAR',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets), 
'VARCHAR2',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets), 
'NUMBER',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
'DATE',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
'TIMESTAMP',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
1) NUM_BATCHES
from wmsys.wm$versioned_tables vt, dba_ind_columns di, dba_tab_columns dt
where di.table_owner = vt.owner 
and   di.table_name = vt.table_name || '_LT' 
and   di.index_name = vt.table_name || '_PKI$'
and   di.column_position = 1
and   dt.owner = vt.owner
and   dt.table_name = vt.table_name || '_LT'
and   dt.column_name = di.column_name ;
create or replace public synonym wm_compress_batch_sizes for wmsys.wm_compress_batch_sizes ;
grant select on wmsys.wm_compress_batch_sizes to wm_admin_role  ;
create or replace force view wmsys.wm$all_locks_view as 
select t.table_owner, t.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKMODE'), 'E', 'EXCLUSIVE', 'S', 'SHARED', 'VE', 'VERSION EXCLUSIVE', 'WE', 'WORKSPACE EXCLUSIVE') Lock_mode, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKUSER') Lock_owner, 
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKSTATE') Locking_state
from (select table_owner, table_name, info from 
      table( cast(wmsys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t 
with READ ONLY ;
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') IsRefreshed, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.user_workspaces uw
where mp.workspace = uw.workspace ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.user_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
create or replace view wmsys.all_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
decode(mp.isRefreshed,0,'NO','YES') ISREFRESHED, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') PARENT_FLAG
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.all_workspaces aw
where mp.workspace = aw.workspace ;
create or replace view wmsys.all_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE, 
decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG 
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.all_workspaces uw
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
      execute immediate 'drop function sys.OVMADT' || adt_rec.func_name ;

    exception when invalid_function then null ;
    end;
  end loop ;
end;
/
declare
  invalid_procedure EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_procedure, -04043);

  cursor proc_cur is
    select dispatcher_name
    from wmsys.wm$udtrig_dispatch_procs ;
begin
  for proc_rec in proc_cur loop
    begin
      execute immediate 'drop procedure ' || proc_rec.dispatcher_name ;

    exception when invalid_procedure then null ;
    end;

    begin
      execute immediate 'drop procedure ' || proc_rec.dispatcher_name || '_io';

    exception when invalid_procedure then null ;
    end;
  end loop;
end;
/
update wmsys.wm$udtrig_dispatch_procs set dispatcher_name = 'wmsys' || substr(dispatcher_name, 7)
where substr(lower(dispatcher_name), 1, 7) = 'system.' ;
commit ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  begin
    execute immediate 'drop package sys.lt' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltadm' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltaq' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltddl' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltdtrg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltpriv' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltric' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ltutil' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.lt_ctx_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.lt_export_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_9ip_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_assert_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_bulk_load_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_ddl_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_iexp_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_mig_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_mp_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_reputil' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_reputil' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.owm_vt_pkg' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.ud_trigs' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.wm_ddl_util' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.wm_error' ;

  exception when invalid_package then null;
  end ;

  begin
    execute immediate 'drop package sys.lt_repln' ;

  exception when invalid_package then null;
  end ;

end;
/
drop function sys.wm$convertDbVersion ;
declare
  invalid_revoke EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_revoke, -01927);
begin
  begin
    execute immediate 'revoke select on wmsys.wm$udtrig_info from system' ;
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$anc_version_view from sys') ;    
  exception when invalid_revoke then null;
  end ;

  begin
    wmsys.wm$execSQL('revoke select on wmsys.wm$ric_locking_table from sys') ;    
  exception when invalid_revoke then null;
  end ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_synonyms
  where owner = 'PUBLIC' and
        synonym_name = 'DBMS_WM' and
        table_owner = 'WMSYS' and
        table_name = 'LT' ;

  if (cnt=0) then
    execute immediate 'create or replace public synonym DBMS_WM for wmsys.lt' ;
  end if ;
end;
/
update sys.exppkgact$ set schema='WMSYS' where schema='SYS' and package='LT_EXPORT_PKG' ;
commit;
declare
  cursor oper_cur is
    select operator_name
    from dba_operators
    where owner = 'SYS' and
          operator_name in ('WM_OVERLAPS', 'WM_INTERSECTION', 'WM_LDIFF', 'WM_RDIFF', 'WM_CONTAINS',
                            'WM_MEETS', 'WM_LESSTHAN', 'WM_GREATERTHAN', 'WM_EQUALS') ;

  invalid_operator EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_operator, -29807);

begin
  for oper_rec in oper_cur loop
    begin
      execute immediate 'drop operator sys.' || oper_rec.operator_name ;

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

    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTADM'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTDDL'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''LTRIC'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_BULK_LOAD_PKG'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_DDL_PKG'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_IEXP_PKG'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_MIG_PKG'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''OWM_MP_PKG'', ''FULL'') ; end;' ;
    execute immediate 'begin sa_user_admin.SET_PROG_PRIVS(''' || policy_name || ''', ''WMSYS'', ''WM_DDL_UTIL'', ''FULL'') ; end;' ;

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
  sql_string varchar2(32000) ;

  cursor ind_cur is
    select ct.owner, ct.table_name, ct.index_owner, ct.index_name, dc.index_owner cio, dc.index_name cin, dc.status
    from wmsys.wm$versioned_tables vt, wmsys.wm$constraints_table ct, dba_constraints dc
    where vt.owner = ct.owner and
          vt.table_name = ct.table_name and
          vt.validtime = 0 and
          ct.table_name || '_LT' = dc.table_name and
          ct.owner = dc.owner and
          ct.constraint_type in ('P', 'PU', 'PN') and
          dc.constraint_type = 'P' and
          dc.status = 'DISABLED' ;
begin
  for ind_rec in ind_cur loop
    execute immediate 'alter table ' || ind_rec.owner || '.' || ind_rec.table_name || '_LT modify primary key enable' ;
  end loop ;
end;
/
@@owmv1116.plb
