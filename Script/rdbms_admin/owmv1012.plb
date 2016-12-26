update wmsys.wm$env_vars set value = '10.2.0.1.0' where name = 'OWM_VERSION';
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
       decode(substr(st.wm_lockmode, 1, instr(st.wm_lockmode, ',')-1), 
              'S', 'SHARED', 
              'E', 'EXCLUSIVE', 
              'WE', 'WORKSPACE EXCLUSIVE', 
              'VE', 'VERSION EXCLUSIVE', 
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(st.wm_lockmode, instr(st.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
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
create or replace view sys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr
from   v$lock dl,
       wmsys.wm$workspaces_table wt,
       sys.v$session st
where  dl.type    = 'UL' and
       dl.id1 - 1 = wt.workspace_lock_id and
       dl.sid     = st.sid;
declare
  version_str        varchar2(100) ;
  compatibility_str  varchar2(100) ;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := sys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
     execute immediate 'grant execute on dbms_registry to WMSYS' ;
   end if ;
end;
/
update wmsys.wm$workspaces_table wt
set post_version = (select (min(version)-1) from wmsys.wm$version_hierarchy_table vht where vht.workspace=wt.workspace)
where post_version is null or post_version=-1 ;
commit ;
declare
  drop_index EXCEPTION;
  PRAGMA EXCEPTION_INIT(drop_index, -01418);
begin
  execute immediate 'drop index wmsys.wm$adt_func_tab_tname' ;

exception when drop_index then
  null ;
end;
/
declare
  pk_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(pk_exception, -02260);
begin
  execute immediate 'alter table wmsys.wm$adt_func_table add constraint wm$adt_func_tab_pk PRIMARY KEY(type_name)' ;

exception when pk_exception then
  null ;
end;
/
create table wmsys.wm$log_table(group# integer, order# integer, owner varchar2(30), sql_str clob, constraint log_tab_pk PRIMARY KEY(group#, order#)) ;
create table wmsys.wm$log_table_errors(group# integer primary key, order# integer, status varchar2(100), error_msg varchar2(200)) ;
create or replace view wmsys.dba_wm_vt_errors as
  select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
  from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str, 4000, 1) sql_str
        from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
       wmsys.wm$vt_errors_table et
  where vt.owner = et.owner
    and vt.table_name = et.table_name
    and vt.index_type = et.index_type
    and vt.index_field = et.index_field
 union all
  select null, null, decode(lt.group#, 10, 'DROP USER COMMAND', 'UNKNOWN OPERATION'), lt.sql_str, lte.status, lte.error_msg
  from (select lt.group#, lt.order#, dbms_lob.substr(lt.sql_str, 4000, 1) sql_str from wmsys.wm$log_table lt) lt,
       wmsys.wm$log_table_errors lte
  where lt.group# = lte.group#
    and lt.order# = lte.order# ;
execute wmsys.wm$execSQL('grant select on wmsys.dba_wm_vt_errors to wm_admin_role') ;
create public synonym dba_wm_vt_errors for wmsys.dba_wm_vt_errors;
create or replace view wmsys.all_wm_vt_errors as
 select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
 from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str
       from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et, all_tables at
 where vt.owner = et.owner
   and vt.table_name = et.table_name
   and vt.index_type = et.index_type
   and vt.index_field = et.index_field
   and vt.owner = at.owner
   and vt.table_name || '_LT' = at.table_name
union all
 select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
 from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str
       from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et, all_tables at
 where vt.owner = et.owner
   and vt.table_name = et.table_name
   and vt.index_type = et.index_type
   and vt.index_field = et.index_field
   and vt.owner = at.owner 
   and vt.table_name = at.table_name
   and not exists(select 1 from all_tables at2
                  where at2.owner = at.owner
                    and at2.table_name = at.table_name || '_LT');
create or replace view wmsys.all_wm_versioned_tables as
 select /*+ ORDERED */ vt.table_name, vt.owner, 
        disabling_ver state,
        vt.hist history,
        decode(vt.notification,0,'NO',1,'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        wmsys.ltadm.AreThereConflicts(vt.owner, vt.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(vt.owner, vt.table_name) diff
 from wmsys.wm$versioned_tables vt, all_views av
 where vt.table_name = av.view_name and vt.owner = av.owner
union all
 select /*+ ORDERED */ vt.table_name, vt.owner, 
        disabling_ver state,
        vt.hist history,
        decode(vt.notification,0,'NO',1,'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,       
        wmsys.ltadm.AreThereConflicts(vt.owner, vt.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(vt.owner, vt.table_name) diff
 from wmsys.wm$versioned_tables vt, all_tables at
 where vt.table_name = at.table_name and vt.owner = at.owner
WITH READ ONLY;
begin
insert into wmsys.wm$constraints_table
  (select dc.owner, dc.constraint_name, 'C', vt.table_name, to_lob(dc.search_condition),
          dc.status, dc.index_owner, dc.index_name, null, null, null
   from wmsys.wm$versioned_tables vt, dba_constraints dc
   where vt.owner = dc.owner and
         vt.table_name || '_LT' = dc.table_name and
         dc.constraint_type = 'C' and
         not exists (select null
                     from wmsys.wm$constraints_table ct
                     where ct.owner = dc.owner and
                           ct.constraint_name = dc.constraint_name)
  ) ;
end;
/
commit; 
@@owmv1020.plb
