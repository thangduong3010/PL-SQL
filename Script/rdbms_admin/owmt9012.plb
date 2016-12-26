create index wmsys.wm$udtrig_info_indx on wmsys.wm$udtrig_info(table_owner_name, table_name, trig_type,status);
create global temporary table wmsys.wm$mw_table ( workspace varchar2(30) ) on commit preserve rows ;
create table wmsys.wm$vt_errors_table ( 
owner           varchar2(30),
table_name      varchar2(30),
index_type      integer,
index_field     integer,
status          varchar2(100),
error_msg       varchar2(200),
constraint wm$vt_errors_pk primary key (owner, table_name)
);
update wmsys.wm$env_vars set value = '9.0.1.3.0' where name = 'OWM_VERSION';
commit;
alter table wmsys.wm$env_vars add constraint wm$env_vars_pk primary key (name);
execute wmsys.wm$execSQL('grant select on wmsys.wm$udtrig_info to system');
alter table wmsys.wm$workspaces_table modify freeze_mode varchar2(20) ;
alter table wmsys.wm$workspaces_table add freeze_owner varchar2(30) ;
alter table wmsys.wm$workspaces_table add session_duration integer ;
update wmsys.wm$workspaces_table set session_duration=0 ;
commit ;
create index wmsys.wm$vht_idx on wmsys.wm$version_hierarchy_table(workspace,version);
create index wmsys.wm$nextver_table_nv_indx on wmsys.wm$nextver_table(next_vers);
create index wmsys.wm$mod_tab_ver_ind on wmsys.wm$modified_tables (version);
create index wmsys.wm$ws_sp_tab_ver_ind on wmsys.wm$workspace_savepoints_table (version);
create index wmsys.wm$ws_priv_tab_ws_grte_ind on wmsys.wm$workspace_priv_table (workspace,grantee);
create index wmsys.wm$ws_priv_tab_grte_ind on wmsys.wm$workspace_priv_table (grantee);
create index wmsys.wm$ws_priv_tab_grtor_ind on wmsys.wm$workspace_priv_table (grantor);
create index wmsys.wm$ws_sess_tab_sid_ind on wmsys.wm$workspace_sessions_table (sid);
create index wmsys.wm$ws_sess_tab_ws_ind on wmsys.wm$workspace_sessions_table (workspace);
declare
 found integer;
begin
  BEGIN
    select 1 into found from v$option where 
    upper(parameter) like 'INDEX%FUNCTIONAL%' and value = 'TRUE';

    execute immediate 'create index wmsys.wm$ric_tab_own_ct_ind on wmsys.wm$ric_table ( ct_owner || ''.'' || ct_name )';
    execute immediate 'create index wmsys.wm$ric_tab_own_pt_ind on wmsys.wm$ric_table ( pt_owner || ''.'' || pt_name )';

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;
end;
/
create index wmsys.wm$ws_tab_pws_ind on wmsys.wm$workspaces_table (parent_workspace);
create index wmsys.wm$ws_tab_pver_ind on wmsys.wm$workspaces_table (parent_version);
create index wmsys.wm$adt_func_tab_tname on wmsys.wm$adt_func_table (type_name);
delete from wmsys.wm$workspace_priv_table where grantee = 'WM_ADMIN_ROLE' 
 and workspace is null and grantor = 'SYS' and priv = 'FA' and admin = 1;
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','FA',1);
commit;
create table wmsys.wm$tmp_dba_constraints(owner varchar2(30), table_name varchar2(30), constraint_name varchar2(30), constraint_type varchar2(30), r_constraint_name varchar2(30), r_owner varchar2(30));
create index wmsys.wm$tmp_dba_cons_ind on wmsys.wm$tmp_dba_constraints(owner,table_name);
@@owmt9013.plb
