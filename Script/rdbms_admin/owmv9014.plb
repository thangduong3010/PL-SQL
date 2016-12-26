update wmsys.wm$env_vars set value = '9.2.0.1.0' where name = 'OWM_VERSION';
commit;
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
alter sequence wmsys.wm$up_del_trig_name_sequence nocache;
alter sequence wmsys.wm$insteadof_trigs_sequence nocache;
alter sequence wmsys.wm$lock_sequence nocache;
alter sequence wmsys.wm$vtid nocache;
alter sequence wmsys.wm$adt_sequence nocache;
alter sequence wmsys.wm$version_sequence nocache;
alter sequence wmsys.wm$row_sync_id_sequence nocache;
alter sequence wmsys.wm$udtrig_dispatcher_sequence nocache;
alter sequence wmsys.wm$nested_columns_seq nocache;
create or replace view sys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr
from   v$lock dl,
       wmsys.wm$workspaces_table wt,
       sys.v$session st
where  dl.type  = 'UL' and
       dl.id1   = wt.workspace_lock_id + 1 and
       dl.sid = st.sid;
create or replace view sys.dba_workspace_sessions as
select sut.username, 
       sut.workspace, 
       sut.sid, 
       decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from   sys.wm$workspace_sessions_view sut,
       sys.v$transaction t
where  sut.saddr = t.ses_addr (+)
WITH READ ONLY;
declare
 curTrigStatus varchar2(10) := null;
 badtab_exception EXCEPTION;
 PRAGMA EXCEPTION_INIT(badtab_exception, -00942);

 purgeOption varchar2(30) := null ;

begin
  begin
   select substr(status,1,length(status)-1) into curTrigStatus
   from all_triggers 
   where owner = 'SYS' and trigger_name = 'NO_VM_DROP';

   execute immediate 'alter trigger sys.no_vm_drop disable';

  exception when no_data_found then null ;
  end ;

  if (nlssort(wmsys.wm$getDbVersionStr, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;
  
  begin
    execute immediate 'drop table wmsys.wm$workspace_sessions_table' || purgeOption ;

  exception
    when badtab_exception then
      null ;
    when others then
      if (curTrigStatus is not null) then
        execute immediate 'alter trigger sys.no_vm_drop ' || curTrigStatus;
      end if;
      raise ;
  end ;

  if (curTrigStatus is not null) then
    execute immediate 'alter trigger sys.no_vm_drop ' || curTrigStatus;
  end if;
end;
/
declare
 dummy  integer;
 maxval integer := -1;
begin
 
 BEGIN
   select 1 into dummy from dual
   where exists (
    select 1 
    from wmsys.wm$workspaces_table wm1
    where MOD(wm1.workspace_lock_id,2) != 0);

   update wmsys.wm$workspaces_table 
    set workspace_lock_id = workspace_lock_id * 2;

   commit;


 EXCEPTION WHEN NO_DATA_FOUND THEN
   




   NULL;
 END;

 select max(workspace_lock_id) + 2 into maxval
 from   wmsys.wm$workspaces_table;

 
 
 execute immediate '
  drop sequence  wmsys.wm$lock_sequence';

 execute immediate '
   create sequence wmsys.wm$lock_sequence 
   start with ' || maxval || ' increment by 2 nocache';


end;
/
@@owmv920.plb
