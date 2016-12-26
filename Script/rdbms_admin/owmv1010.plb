update wmsys.wm$env_vars set value = '10.1.0.2.0' where name = 'OWM_VERSION';
commit;
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
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_tab_triggers to public with grant option');
create or replace public synonym user_wm_tab_triggers for wmsys.user_wm_tab_triggers; 
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_tab_triggers to public with grant option');
create or replace public synonym all_wm_tab_triggers for wmsys.all_wm_tab_triggers; 
alter table wmsys.wm$versioned_tables add(validTime integer default 0) ; 
create or replace view wmsys.wm$mw_versions_view_9i as
select version, modified_by, wm_concat(workspace) seen_by from 
(
select vht.version, vht.workspace modified_by, mw.workspace from
wmsys.wm$mw_table mw, wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht 
where mw.workspace = vt.workspace
and vt.anc_workspace = vht.workspace 
and vht.version <= vt.anc_version
union all
select vht.version, vht.workspace modified_by, mw.workspace from
wmsys.wm$mw_table mw, wmsys.wm$version_hierarchy_table vht
where mw.workspace = vht.workspace  
)
group by (version,modified_by) ;
create public synonym wm$mw_versions_view_9i for wmsys.wm$mw_versions_view_9i;
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_versions_view_9i to public with grant option');
create or replace view wmsys.all_version_hview_wdepth as
select vht.version, vht.parent_version, vht.workspace, wt.depth
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$workspaces_table wt
where vht.workspace = wt.workspace;
create or replace public synonym wm$all_version_hview_wdepth for wmsys.all_version_hview_wdepth;
execute wmsys.wm$execSQL('grant select on WMSYS.all_version_hview_wdepth to public with grant option');
alter table wmsys.wm$versioned_tables ADD (initVTRange wmsys.wm_period);
create table wmsys.wm$batch_compressible_tables (
workspace varchar2(30),
table_name varchar2(65),
begin_version   integer,
end_version    integer,
where_clause varchar2(4000)
) ;
create index wmsys.wm$bct_idx on wmsys.wm$batch_compressible_tables(workspace,table_name) ;
create or replace view sys.wm_compress_batch_sizes
as
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
create public synonym wm_compress_batch_sizes for sys.wm_compress_batch_sizes ;
grant select on sys.wm_compress_batch_sizes to wm_admin_role  ;
create or replace view wmsys.wm_compressible_tables
as
select vt.owner, vt.table_name, sys_context('lt_ctx','compress_workspace') workspace, 
sys_context('lt_ctx','compress_beginsp') BEGIN_SAVEPOINT,
sys_context('lt_ctx','compress_endsp') END_SAVEPOINT
from wmsys.wm$versioned_tables vt
where exists
(select 1 from wmsys.wm$modified_tables mt
 where mt.table_name = vt.owner || '.' || vt.table_name
 and   mt.workspace = sys_context('lt_ctx','compress_workspace')
 and   mt.version > sys_context('lt_ctx','compress_beginver')
 and   mt.version <= sys_context('lt_ctx','compress_endver')
 and   substr(vt.hist,1,17) != 'VIEW_WO_OVERWRITE'
 and   mt.version in
     (
       select v.version
       from wmsys.wm$version_hierarchy_table v,
       (
        select w1.beginver, w2.endver
        from
         (select rownum rn,beginver from
           (select distinct beginver from
              (select to_number(sys_context('lt_ctx','compress_beginver')) beginver from dual
               where not exists
                 (select parent_version from wmsys.wm$workspaces_table 
                  where parent_workspace = sys_context('lt_ctx','compress_workspace')
                  and to_number(sys_context('lt_ctx','compress_beginver')) = parent_version
                 )
               union all
               select min(version) beginver from wmsys.wm$version_hierarchy_table,
                 (select distinct parent_version 
                  from wmsys.wm$workspaces_table
                  where parent_workspace = sys_context('lt_ctx','compress_workspace')
                  and   parent_version >= sys_context('lt_ctx','compress_beginver')
                  and   parent_version < sys_context('lt_ctx','compress_endver')) pv
               where workspace = sys_context('lt_ctx','compress_workspace')
               and version > pv.parent_version
               group by (pv.parent_version)
             )
            order by beginver
           )
         ) w1,            
         (select rownum rn,endver from
            (select distinct endver from
              (select parent_version endver 
               from wmsys.wm$workspaces_table
               where parent_workspace = sys_context('lt_ctx','compress_workspace')
               and   parent_version > sys_context('lt_ctx','compress_beginver')
               and   parent_version <= sys_context('lt_ctx','compress_endver')
               union all
               select to_number(sys_context('lt_ctx','compress_endver')) endver  from dual 
              )
             order by endver
            )
         ) w2           
         where w1.rn = w2.rn 
         and w2.endver > w1.beginver
       ) p
       where v.workspace = sys_context('lt_ctx','compress_workspace')
       and v.version > p.beginver
       and v.version <= p.endver
     )
 union all 
 select 1 from wmsys.wm$modified_tables mt
 where mt.table_name = vt.owner || '.' || vt.table_name
 and   mt.workspace = sys_context('lt_ctx','compress_workspace')
 and   mt.version >= sys_context('lt_ctx','compress_beginver')
 and   mt.version <= sys_context('lt_ctx','compress_endver')
 and   substr(vt.hist,1,17) = 'VIEW_WO_OVERWRITE'
) ;
create public synonym wm_compressible_tables for wmsys.wm_compressible_tables ;
execute wmsys.wm$execSQL('grant select on wmsys.wm_compressible_tables to wm_admin_role')  ;
begin
  insert into wmsys.wm$sysparam_all_values values ('NUMBER_OF_COMPRESS_BATCHES', '50', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
begin
  insert into wmsys.wm$sysparam_all_values values ('UNDO_SPACE', 'UNLIMITED', 'YES');
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
alter table wmsys.wm$replication_table add (status varchar2(1)  default 'E');
create table wmsys.wm$replication_details_table ( name varchar2(100), value varchar2(500) ); 
begin

  begin
    execute immediate 'drop procedure logoff_proc';
  exception when others then
    null;
  end;

  begin
    execute immediate 'drop trigger sys_logoff';    
  exception when others then
    null;
  end;

  begin
    execute immediate 'drop procedure logon_proc';
  exception when others then
    null;
  end;

  begin
    execute immediate 'drop trigger sys_logon';    
  exception when others then
    null;
  end;

end;
/
alter table wmsys.wm$adt_func_table modify(type_name varchar2(68)) ;
@@owmv1012.plb
