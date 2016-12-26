update wmsys.wm$env_vars set value = '9.2.0.2.0' where name = 'OWM_VERSION';
commit;
create table wmsys.wm$constraints_table (
 owner                    varchar2(30),
 constraint_name          varchar2(30),
 constraint_type          varchar2(2),
 table_name               varchar2(30),
 search_condition         long,
 status                   varchar2(8),
 index_owner              varchar2(30),
 index_name               varchar2(30),
 index_type               varchar2(40),
 aliasedColumns           clob,
 numIndexCols             integer,
 constraint wm$constraints_table_pk primary key (owner, constraint_name)
) ;
create index wmsys.wm$constraints_table_tab_idx on wmsys.wm$constraints_table (owner, table_name) ;
create or replace view wmsys.user_wm_constraints as
  select /*+ ORDERED */ 
   constraint_name, constraint_type, table_name, 
   search_condition, status, index_owner, index_name, index_type
  from   wmsys.wm$constraints_table ct, user_views uv
  where  ct.owner = USER and
         ct.table_name = uv.view_name ; 
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_constraints to public with grant option');
create public synonym user_wm_constraints for wmsys.user_wm_constraints;
create or replace view wmsys.all_wm_constraints as
  select /*+ ORDERED */ 
   ct.owner, constraint_name, constraint_type, table_name, 
   search_condition, status, index_owner, index_name, index_type
  from   wmsys.wm$constraints_table ct, all_views av
  where  ct.owner = av.owner and
         ct.table_name = av.view_name ; 
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_constraints to public with grant option');
create public synonym all_wm_constraints for wmsys.all_wm_constraints ;
insert into wmsys.wm$constraints_table select t1.owner, t2.constraint_name, 'P', t1.table_name, null, 'ENABLED', t1.owner, t2.constraint_name, 'NORMAL', null, null from wmsys.wm$versioned_tables t1, dba_constraints t2 where t1.owner = t2.owner and t1.table_name || '_LT' = t2.table_name and t2.constraint_type = 'P'  ;
commit;
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
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_ind_columns to public with grant option');
create public synonym user_wm_ind_columns for wmsys.user_wm_ind_columns;
create or replace view wmsys.all_wm_ind_columns as
select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name, 
t2.column_position, t2.column_length,  t2.descend
from wmsys.wm$constraints_table t1, all_ind_columns t2
where t1.index_owner = t2.index_owner
and t1.index_name = t2.index_name 
and t1.constraint_type != 'P'
union
select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name, 
t2.column_position-1, t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, all_ind_columns t2
where t1.index_owner = t2.index_owner
and t1.index_name = t2.index_name 
and t1.constraint_type = 'P'
and t2.column_name not in ('VERSION','DELSTATUS') ;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_ind_columns to public with grant option');
create public synonym all_wm_ind_columns for wmsys.all_wm_ind_columns;
create or replace view wmsys.user_wm_ind_expressions as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, user_ind_expressions t2
where t1.index_owner = USER 
and t1.index_name = t2.index_name ;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_ind_expressions to public with grant option') ;
create public synonym user_wm_ind_expressions for wmsys.user_wm_ind_expressions ;
create or replace view wmsys.all_wm_ind_expressions as
select /*+ USE_NL(t1 t2) */ t2.index_owner,t2.index_name, t1.owner, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, all_ind_expressions t2
where t1.index_owner = t2.index_owner 
and t1.index_name = t2.index_name ;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_ind_expressions to public with grant option') ;
create public synonym all_wm_ind_expressions for wmsys.all_wm_ind_expressions ;
create or replace view wmsys.wm$conf1_hierarchy_view as
  select * from wmsys.wm$version_hierarchy_table 
  start with version = (select current_version from wmsys.wm$workspaces_table 
                        where workspace = sys_context('lt_ctx', 'conflict_state'))
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$conf2_hierarchy_view as
  select * from wmsys.wm$version_hierarchy_table 
  start with version = (select current_version from wmsys.wm$workspaces_table 
                        where workspace = sys_context('lt_ctx', 'parent_conflict_state'))
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$conf_base_hierarchy_view as
  select version from wmsys.wm$version_hierarchy_table 
  start with version = sys_context('lt_ctx', 'confbasever')
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$conf1_nextver_view as
  select next_vers from wmsys.wm$nextver_table 
  where version in 
  (select version from wmsys.wm$conf1_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$conf2_nextver_view as
  select next_vers from wmsys.wm$nextver_table 
  where version in 
  (select version from wmsys.wm$conf2_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$conf_base_nextver_view as
  select next_vers from wmsys.wm$nextver_table
  where version in
  (select version from wmsys.wm$conf_base_hierarchy_view)
WITH READ ONLY;
create public synonym wm$conf1_hierarchy_view for wmsys.wm$conf1_hierarchy_view ;
create public synonym wm$conf2_hierarchy_view for wmsys.wm$conf2_hierarchy_view ;
create public synonym wm$conf_base_hierarchy_view for wmsys.wm$conf_base_hierarchy_view ;
create public synonym wm$conf1_nextver_view for wmsys.wm$conf1_nextver_view ;
create public synonym wm$conf2_nextver_view for wmsys.wm$conf2_nextver_view ;
create public synonym wm$conf_base_nextver_view for wmsys.wm$conf_base_nextver_view ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf1_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf2_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf_base_hierarchy_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf1_nextver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf2_nextver_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$conf_base_nextver_view to public with grant option');
create or replace view wmsys.wm$all_nextver_view as
  select version, next_vers, workspace, split
  from wmsys.wm$nextver_table 
WITH READ ONLY;
create public synonym wm$all_nextver_view for wmsys.wm$all_nextver_view ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$all_nextver_view to public with grant option');
create table wmsys.wm$cons_columns (
owner                          varchar2(30),
constraint_name                varchar2(30),
table_name                     varchar2(30),
column_name                    varchar2(4000),
position                       number
) ;
create index wmsys.wm$cons_columns_idx on wmsys.wm$cons_columns(owner, constraint_name) ;
create or replace view wmsys.user_wm_cons_columns as
select /*+ ORDERED */ t1.* from 
wmsys.wm$cons_columns t1, user_views t2
where t1.owner = USER
and t1.table_name = t2.view_name;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_cons_columns to public with grant option');
create public synonym user_wm_cons_columns for wmsys.user_wm_cons_columns;
create or replace view wmsys.all_wm_cons_columns as
select /*+ ORDERED */ t1.* from 
wmsys.wm$cons_columns t1, all_views t2
where t1.owner = t2.owner
and t1.table_name = t2.view_name;
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_cons_columns to public with grant option');
create public synonym all_wm_cons_columns for wmsys.all_wm_cons_columns;
drop sequence wmsys.wm$nested_columns_seq ;
alter table wmsys.wm$versioned_tables add ( bl_workspace varchar2(30), bl_version integer );
create index wmsys.wm$ver_tab_bl_indx on wmsys.wm$versioned_tables(bl_workspace,bl_version);
create or replace view wmsys.wm$diff1_hierarchy_view as
  select * from wmsys.wm$version_hierarchy_table 
  start with version = 
             decode(sys_context('lt_ctx', 'diffver1'), -1,
             (select current_version from wmsys.wm$workspaces_table
              where workspace = sys_context('lt_ctx', 'diffWspc1')),
             sys_context('lt_ctx', 'diffver1'))
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$diff2_hierarchy_view as
  select version from wmsys.wm$version_hierarchy_table 
  start with version = 
             decode(sys_context('lt_ctx', 'diffver2'), -1,
             (select current_version from wmsys.wm$workspaces_table
              where workspace = sys_context('lt_ctx', 'diffWspc2')),
             sys_context('lt_ctx', 'diffver2'))
  connect by prior parent_version  = version
WITH READ ONLY;
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
        execute immediate 'drop view ' || verTabName || '_DIF1';
      EXCEPTION WHEN badtab_exception THEN
        NULL;
      END;
  
      BEGIN
        execute immediate 'drop view ' || verTabName || '_DIF2';
      EXCEPTION WHEN badtab_exception THEN
        NULL;
      END;
      
      
      BEGIN
        execute immediate 'alter table ' || verTabName || '_AUX add (wm_opcode varchar2(3))';
      EXCEPTION WHEN column_exists_exception THEN
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
create or replace view wmsys.wm$current_child_versions_view as
select vht.version
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where 
(
   vht.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version   = decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
) 
WITH READ ONLY ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_child_versions_view to public with grant option');
create public synonym wm$current_child_versions_view for wmsys.wm$current_child_versions_view ;
create index wmsys.wm$vt_anc_idx on wmsys.wm$version_table(anc_workspace, anc_version);
create or replace view wmsys.wm$current_child_nextvers_view as
select nvt.next_vers 
from wmsys.wm$nextver_table nvt, wmsys.wm$version_table vt
where 
(
   nvt.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version   = decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version 
                                    FROM wmsys.wm$workspaces_table 
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version 
                                  from wmsys.wm$workspaces_table 
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
) 
WITH READ ONLY ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_child_nextvers_view to public with grant option');
create public synonym wm$current_child_nextvers_view for wmsys.wm$current_child_nextvers_view ;
insert into wmsys.wm$nextver_table values(0,',0,','LIVE',0) ;
commit;
drop index wmsys.wm$nextver_table_nv_indx;
create unique index wmsys.wm$nextver_table_nv_indx on wmsys.wm$nextver_table(next_vers,version,workspace);
alter table wmsys.wm$workspaces_table add ( cr_status varchar2(20) );
alter table wmsys.wm$workspaces_table add ( sync_parver integer );
update wmsys.wm$workspaces_table wt
 set sync_parver = nvl( (select min(version) from wmsys.wm$version_hierarchy_table
      where version > wt.parent_version and workspace = wt.parent_workspace), wt.parent_version)
where wt.workspace != 'LIVE' ;
commit;
alter table wmsys.wm$workspaces_table add ( last_change date default sysdate);
declare
 cursor c1 is 
  select workspace, cr_status, rowid from wmsys.wm$workspaces_table;
 curWspc varchar2(30);
 curRID  ROWID;
 curCRStatus varchar2(20);
 newCRStatus varchar2(20);
 cursor childWspcCur is 
  select count(distinct isrefreshed), min(isrefreshed)
  from wmsys.wm$workspaces_table
  where parent_workspace = curWspc;
 cnt         integer;
 isRefreshed integer;
begin
 open c1;
 loop
   fetch c1 into curWspc, curCRStatus, curRID;
   EXIT when c1%NOTFOUND;
   if (curCRStatus is null) then
     open  childWspcCur;
     fetch childWspcCur into cnt, isRefreshed;

     if (cnt = 0) then
       newCRStatus := wmsys.lt_ctx_pkg.CRSTATUS_LEAF;
     elsif (cnt = 2) then
       newCRStatus := wmsys.lt_ctx_pkg.CRSTATUS_MIXED;
     else 
       if (isRefreshed = 0) then   
         newCRStatus := wmsys.lt_ctx_pkg.CRSTATUS_ALLNONCR;
       else 
         newCRStatus := wmsys.lt_ctx_pkg.CRSTATUS_ALLCR;
       end if;
     end if;
     update wmsys.wm$workspaces_table
       set cr_status = newCRStatus
     where rowid = curRID;
     close childWspcCur;
   end if;
 end loop;
 close c1;
 commit;
end;
/
create or replace view wmsys.wm$current_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$parent_workspace_view as 
  select * from wmsys.wm$workspaces_table  
  where workspace = SYS_CONTEXT('lt_ctx','parent_state')
WITH READ ONLY;
alter table wmsys.wm$workspaces_table add (depth integer) ;
alter table wmsys.wm$version_table add (anc_depth integer) ;
declare

  wspc   varchar2(30) ;
  cnt    integer ;
  rid    ROWID ;
  cursor all_workspaces is select workspace, rowid
                       from wmsys.wm$workspaces_table ;
begin

  open all_workspaces ;
  loop
    fetch all_workspaces into wspc, rid ;
    exit when all_workspaces%NOTFOUND ;

    select count(*) into cnt
    from wmsys.wm$version_table
    where workspace = wspc;

    update wmsys.wm$workspaces_table
    set depth = cnt
    where rowid = rid ;

    update wmsys.wm$version_table
    set anc_depth = cnt
    where anc_workspace = wspc ;

  end loop;
  close all_workspaces ;
end;
/
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
                    -1, decode(sys_context('lt_ctx','isCRChild'), 'true',
                               (select sync_parver
                                from wmsys.wm$workspaces_table
                                where workspace = sys_context('lt_ctx', 'diffWspc2')),
                                (select current_version
                                from wmsys.wm$workspaces_table
                                where workspace = sys_context('lt_ctx', 'diffWspc1'))),
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
                    -1, decode(sys_context('lt_ctx','isCRChild'), 'true',
                               (select sync_parver
                                from wmsys.wm$workspaces_table
                                where workspace = sys_context('lt_ctx', 'diffWspc1')),
                                (select current_version
                                from wmsys.wm$workspaces_table
                                where workspace = sys_context('lt_ctx', 'diffWspc2'))),
                       sys_context('lt_ctx', 'diffver2'))
       from dual where sys_context('lt_ctx', 'anc_workspace') = 
                       sys_context('lt_ctx', 'diffWspc2')
      ) vt2,
      wmsys.wm$workspaces_table wmt
where wmt.workspace = sys_context('lt_ctx', 'anc_workspace');
execute wmsys.wm$execSQL('grant select on wmsys.wm$base_version_view to public with grant option');
create public synonym wm$base_version_view for wmsys.wm$base_version_view ;
create or replace view wmsys.wm$base_hierarchy_view as
  select -1 version from dual union all
  select version from wmsys.wm$version_hierarchy_table 
  start with version = (select version from wmsys.wm$base_version_view)
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_parvers_view (parent_vers, vtid) as 
  select version, vtid 
  from wmsys.wm$modified_tables
  where workspace = SYS_CONTEXT('lt_ctx','conflict_state')
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_nextvers_view as 
select version, next_vers, workspace, split, cpv.vtid
from wmsys.wm$nextver_table nt, wmsys.wm$curConflict_parvers_view cpv
where nt.version = cpv.parent_vers
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_parvers_view (parent_vers, vtid, afterSync) 
as 
 (select version, vtid,  decode(sign(mt.version - wt.sync_parver), -1, 'NO','YES') 
  from wmsys.wm$modified_tables mt, wmsys.wm$workspaces_table wt 
  where mt.workspace = SYS_CONTEXT('lt_ctx','parent_conflict_state') and
        wt.workspace = SYS_CONTEXT('lt_ctx','conflict_state')
        and mt.version >= decode(sign(wt.parent_version - wt.sync_parver),-1,
                                 (wt.parent_version+1), sync_parver)
 )
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_nextvers_view as 
select version, next_vers, workspace, split, ppv.vtid, ppv.afterSync
from wmsys.wm$nextver_table nt, wmsys.wm$parConflict_parvers_view ppv
where nt.version = ppv.parent_vers
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$version_hierarchy_table to public');
execute wmsys.wm$execSQL('grant select on wmsys.wm$version_table to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$nextver_table to public');
create or replace view wmsys.wm$mw_versions_view as
select distinct version, modified_by from 
(
select vht.version, vht.workspace modified_by from
wmsys.wm$mw_table mw, wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht 
where mw.workspace = vt.workspace
and vt.anc_workspace = vht.workspace 
and vht.version <= vt.anc_version
union all
select vht.version, vht.workspace modified_by from
wmsys.wm$mw_table mw, wmsys.wm$version_hierarchy_table vht
where mw.workspace = vht.workspace  
);
create or replace view wmsys.wm$mw_nextvers_view as
select nvt.next_vers
from wmsys.wm$nextver_table  nvt
where 
nvt.workspace in (select workspace from wmsys.wm$mw_table)
or 
exists
 ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace in (select workspace from wmsys.wm$mw_table) and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version ) ;
create public synonym wm$mw_versions_view for wmsys.wm$mw_versions_view;
create public synonym wm$mw_nextvers_view for wmsys.wm$mw_nextvers_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_versions_view to public with grant option');
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_nextvers_view to public with grant option');
create table wmsys.wm$sysparam_all_values (
name varchar2(100),
value varchar2(512),
IsDefault varchar2(9),
constraint wm$env_sys_pk primary key(name, value) 
) ;
declare
  pess  varchar2(30) := WMSYS.LT.PESSIMISTIC_LOCKING;
  opt   varchar2(30) := WMSYS.LT.OPTIMISTIC_LOCKING;
begin
  insert into wmsys.wm$sysparam_all_values values ('CR_WORKSPACE_MODE',pess,'NO') ;
  insert into wmsys.wm$sysparam_all_values values ('CR_WORKSPACE_MODE',opt,'YES') ;
  insert into wmsys.wm$sysparam_all_values values ('NONCR_WORKSPACE_MODE', pess, 'NO') ;
  insert into wmsys.wm$sysparam_all_values values ('NONCR_WORKSPACE_MODE', opt,  'YES') ;
  insert into wmsys.wm$sysparam_all_values values ('FIRE_TRIGGERS_FOR_NONDML_EVENTS', 'ON', 'YES');
  insert into wmsys.wm$sysparam_all_values values ('FIRE_TRIGGERS_FOR_NONDML_EVENTS', 'OFF', 'NO');
  commit ;
end;
/
declare
  v varchar2(40);
begin
  select value into v
  from wmsys.wm$env_vars
  where name = 'CR_WORKSPACE_MODE';

exception when no_data_found then
  insert into wmsys.wm$env_vars values('CR_WORKSPACE_MODE', WMSYS.LT.PESSIMISTIC_LOCKING) ;
  commit;
end;
/
alter table wmsys.wm$udtrig_info add (
  internal_type varchar2(50) default 'USER_DEFINED',
  tab_merge_wo_remove_col  varchar2(4) default 'ON', 
  tab_merge_w_remove_col   varchar2(4) default 'ON',
  wspc_merge_wo_remove_col varchar2(4) default 'ON',
  wspc_merge_w_remove_col  varchar2(4) default 'ON',
  dml_col                  varchar2(4) default 'ON',
  workspace_refresh_col    varchar2(4) default 'ON',
  table_refresh_col        varchar2(4) default 'ON',
  table_rollback_col       varchar2(4) default 'ON',
  workspace_rollback_col   varchar2(4) default 'ON',
  workspace_remove_col     varchar2(4) default 'ON'
); 
alter table wmsys.wm$workspaces_table add (mp_root varchar2(30) default null);
create index wmsys.wm$workspaces_mp_idx on wmsys.wm$workspaces_table(mp_root);
alter table wmsys.wm$version_table add (refCount integer default 1);
create table wmsys.wm$mp_parent_workspaces_table (
workspace varchar2(30), 
parent_workspace varchar2(30),
parent_version integer,
creator varchar2(30),
createtime date,
workspace_lock_id integer,
isRefreshed integer,
parent_flag varchar2(2),
constraint wm$mp_parent_pk primary key(workspace, parent_workspace)
) ;
create index wmsys.wm$mp_pws_tab_pws_ind on wmsys.wm$mp_parent_workspaces_table (parent_workspace);
create index wmsys.wm$mp_pws_tab_pver_ind on wmsys.wm$mp_parent_workspaces_table (parent_version);
create table wmsys.wm$mp_graph_workspaces_table (
  mp_leaf_workspace   varchar2(30),
  mp_graph_workspace  varchar2(30),
  anc_version         integer,
  mp_graph_flag       varchar2(1),
  constraint wm$mp_graph_workspaces_pk primary key (mp_leaf_workspace,mp_graph_workspace)
) ;
create index wmsys.wm$mp_graph_workspace_idx on wmsys.wm$mp_graph_workspaces_table(mp_graph_workspace) ;
create or replace view wmsys.wm$mp_graph_cons_versions as
select vht.version, vht.workspace
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.wm$version_hierarchy_table vht
where instr(SYS_CONTEXT('lt_ctx','current_mp_leafs'), mpg.mp_leaf_workspace) > 0
and   mpg.mp_graph_flag = 'I'
and   vht.workspace = mpg.mp_graph_workspace 
and   vht.version <= mpg.anc_version
and   ( 
        ( nvl(sys_context('lt_ctx','rowlock_status'),'X') = 'F' and nvl(sys_context('lt_ctx','flip_version'),'N') = 'Y' )
        OR
        ( nvl(sys_context('lt_ctx','isrefreshed'),'0') = '1' )
      )      
WITH READ ONLY;
create or replace view wmsys.wm$current_cons_versions_view
as
 select version from wmsys.wm$current_child_versions_view
 union all
 select parent_vers from wmsys.wm$current_parvers_view 
 union all
 select version from wmsys.wm$mp_graph_cons_versions
 union all
 select version from wmsys.wm$version_hierarchy_table
 where workspace in (
   select workspace from wmsys.wm$version_table
   where anc_workspace = sys_context('lt_ctx','state')
 )
 and  ( nvl(sys_context('lt_ctx','rowlock_status'),'X') = 'F' and nvl(sys_context('lt_ctx','flip_version'),'N') = 'Y' ) 
WITH READ ONLY ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_cons_versions_view to public with grant option');
create public synonym wm$current_cons_versions_view for wmsys.wm$current_cons_versions_view ;
create or replace view wmsys.wm$current_cons_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers 
             from wmsys.wm$nextver_table nvt
where 
(
 (
   nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') 
   and nvt.version   <=   decode(sys_context('lt_ctx','version'),
                       null,(SELECT current_version 
                               FROM wmsys.wm$workspaces_table 
                               WHERE workspace = 'LIVE'),
                       -1,(select current_version 
                           from wmsys.wm$workspaces_table 
                           where workspace = sys_context('lt_ctx','state')),
                           sys_context('lt_ctx','version')
                          )
   and not ( nvl(sys_context('lt_ctx','rowlock_status'),'X') = 'F' and nvl(sys_context('lt_ctx','flip_version'),'N') = 'Y' )
 )
 or 
 ( exists ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version )
 )
) 
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_cons_nextvers_view to public with grant option');
create public synonym wm$current_cons_nextvers_view for wmsys.wm$current_cons_nextvers_view ;
create or replace view wmsys.wm$mp_graph_new_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where vt.workspace = sys_context('lt_ctx','new_mp_leaf') 
and vht.workspace = vt.anc_workspace
and vht.version <= vt.anc_version
and (vt.refCount < 0 or ( vht.workspace = sys_context('lt_ctx','new_mp_root')
                          and vht.version > sys_context('lt_ctx','old_root_anc_version') )
    ) 
WITH READ ONLY;
create or replace view wmsys.wm$mp_graph_other_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where
(vt.workspace = sys_context('lt_ctx','new_mp_leaf') 
 and vht.workspace = vt.anc_workspace
 and vht.version <= vt.anc_version
 and vt.refCount > 0
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
  WORKSPACE_REMOVE
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
       WORKSPACE_REMOVE_COL
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
  WORKSPACE_REMOVE
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
        WORKSPACE_REMOVE_COL
 from   wmsys.wm$udtrig_info
 where  trig_owner_name = USER or
        table_owner_name = USER or
        EXISTS  
        ( select * 
          from   user_sys_privs
          where  privilege = 'CREATE ANY TRIGGER' ) )
with READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.user_wm_tab_triggers to public with grant option');
create or replace public synonym user_wm_tab_triggers for wmsys.user_wm_tab_triggers; 
execute wmsys.wm$execSQL('grant select on wmsys.all_wm_tab_triggers to public with grant option');
create or replace public synonym all_wm_tab_triggers for wmsys.all_wm_tab_triggers; 
create table wmsys.wm$ric_locking_table( pt_owner varchar2(30), pt_name varchar2(30), slockNo integer, elockNo integer );
execute wmsys.wm$execSQL('grant select on wmsys.wm$ric_locking_table to sys');
alter table wmsys.wm$workspaces_table add constraint workspace_lock_id_unq unique(workspace_lock_id);
create or replace view wmsys.wm$anc_version_view as 
         select vht1.version, vht2.version parent_vers, vht1.workspace from 
           wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2,
           wmsys.wm$version_table vt
          where (vht1.workspace = vt.workspace and
                 vht2.workspace = vt.anc_workspace and
                 vht2.version  <= vt.anc_version)
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$anc_version_view to sys');
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

    sql_string := 'create or replace function OVMADT' || adt_rec.func_name || ' return ' || type_name_var || ' is
                   begin
                     return null;
                   end;';

    execute immediate sql_string;

    sql_string := 'grant execute on OVMADT' || adt_rec.func_name || ' to public with grant option';
    execute immediate sql_string;
  end loop;
end;
/
update wmsys.wm$ric_triggers_table set pt_name = substr(pt_name,1,instr(pt_name,'_LT',-1,1)-1)
 where ( instr(pt_name,'_LT',-1,1) + 2 = length(pt_name) )
 and length(pt_name) > 3
 and pt_owner = ct_owner and substr(pt_name,1,instr(pt_name,'_LT',-1,1)-1) = ct_name  ; 
commit ;
update wmsys.wm$ric_triggers_table 
 set update_trigger_name = upper(update_trigger_name), 
     delete_trigger_name = upper(delete_trigger_name) ;
@@owmv922.plb
