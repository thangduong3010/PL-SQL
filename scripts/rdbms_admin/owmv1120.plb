update wmsys.wm$env_vars set value = '11.2.0.4.0' where name = 'OWM_VERSION';
commit;
create or replace function wmsys.get_expanded_nextvers wrapped 
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
269 19d
pGwkFZjwr/4ajpli3MJGYw41Fgowg/AJ2SdqfC+KMQ8tB+ZWBkAbxux2kRK2mZExfTjaSczj
KWKJ34nPPwFs4ulr0G3bvMkXYIOI9/YrmTCI/59TNCJPSmqzQUDZOgswEtDH72OUYqDDi2yN
/Ra4gLKxynTBNhQn70T1jXtNXOpVmYoybSXgmlQuggoosuFe81+Q0fulgLvrM/5AdWerrVM0
4sUnE6P7tqv+Fsb6LvzVaJ/YUAFUOObevbfsNm/6Zlh/01S2B+zuQb0HpjTiEwjLr3aFdnpH
A0GyWZIrSmUYZrLHCDvbJiVdFzeMVwFlxsfoiHzko9zTu3OBFOuSMSiu9Z6n+ylDe3PR/J08
zn+KWEDiovOmfu6z6pDJu4ON/83qaEF68GCAuSL7Ql5P/A==

/
begin
  delete wmsys.wm$nextver_table
  where next_vers != '-1' and split=1 and
  exists (select 1
          from table(wmsys.get_expanded_nextvers(next_vers)) n
          where n.next_vers not in(select version from wmsys.wm$version_hierarchy_table v)) ;
end;
/
drop function wmsys.get_expanded_nextvers ;
create or replace view wmsys.wm$exp_map as
select *
from table(wmsys.lt_export_pkg.export_mapping_view_func()) ;
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_tables
  where owner = 'WMSYS' and
        table_name = 'WM$EXP_MAP_TBL' ;

  if (cnt=0) then
    execute immediate 'create table wmsys.wm$exp_map_tbl as (select * from wmsys.wm$exp_map where 1=2)' ;
  end if ;
end;
/
delete sys.impcalloutreg$ where tag='WMSYS';
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$EXP_MAP', 4, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$BATCH_COMPRESSIBLE_TABLES', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$CONSTRAINTS_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$CONS_COLUMNS', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$ENV_VARS', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$EVENTS_INFO', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$HINT_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$INSTEADOF_TRIGS_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$LOCKROWS_INFO', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$MODIFIED_TABLES', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$MP_GRAPH_WORKSPACES_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$MP_PARENT_WORKSPACES_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$NESTED_COLUMNS_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$NEXTVER_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$REMOVED_WORKSPACES_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$RESOLVE_WORKSPACES_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$RIC_LOCKING_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$RIC_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$RIC_TRIGGERS_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$UDTRIG_DISPATCH_PROCS', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$UDTRIG_INFO', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$VERSION_HIERARCHY_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$VERSION_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$VT_ERRORS_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$WORKSPACES_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$WORKSPACE_PRIV_TABLE', 2, 'Workspace Manager') ;
insert into sys.impcalloutreg$ values('LT_EXPORT_PKG', 'WMSYS', 'WMSYS', 3, 1000, 0, 'WMSYS', 'WM$WORKSPACE_SAVEPOINTS_TABLE', 2, 'Workspace Manager') ;
commit ;
begin
  delete wmsys.wm$hint_table where hint_id=5602 and isdefault=1;
  insert into wmsys.wm$hint_table values(5152, null, null, 'LEADING(conf_pkcA)', 1) ;
  insert into wmsys.wm$hint_table values(5202, null, null, 'LEADING(diff_thisA)', 1) ;
  insert into wmsys.wm$hint_table values(5402, null, null, 'LEADING(bpkc_cpvA)', 1) ;
  insert into wmsys.wm$hint_table values(5405, null, null, 'LEADING(bpkc_cpvB)', 1) ;
  insert into wmsys.wm$hint_table values(5501, null, null, 'LEADING(pkdb_thisA)', 1) ;
  insert into wmsys.wm$hint_table values(5502, null, null, 'LEADING(pkdb_dhvA)', 1) ;
  insert into wmsys.wm$hint_table values(5504, null, null, 'LEADING(pkdb_dhvB)', 1) ;
  insert into wmsys.wm$hint_table values(5506, null, null, 'LEADING(pkdb_thisB)', 1) ;
  insert into wmsys.wm$hint_table values(5507, null, null, 'LEADING(pkdb_dhvC)', 1) ;
  insert into wmsys.wm$hint_table values(5509, null, null, 'LEADING(pkdb_dhvD)', 1) ;
  insert into wmsys.wm$hint_table values(5511, null, null, 'LEADING(pkdb_thisA)', 1) ;
  insert into wmsys.wm$hint_table values(5520, null, null, 'LEADING(pkdb_thisB)', 1) ;
  insert into wmsys.wm$hint_table values(5551, null, null, 'LEADING(pkdc_thisA)', 1) ;
  insert into wmsys.wm$hint_table values(5601, null, null, 'LEADING(pkd_pkdcA)', 1) ;
  
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
declare
  cursor ver_tabs is
    select owner, table_name
    from wmsys.wm$versioned_tables ;
begin
  for ver_rec in ver_tabs loop
    execute immediate 'alter table ' || ver_rec.owner || '.' || ver_rec.table_name || '_LT modify (ltlock varchar2(150))' ;
  end loop ;
end;
/
begin
  insert into wmsys.wm$env_vars values ('DIFF_MODIFIED_ONLY', 'OFF', 1) ;
  commit ;

exception when dup_val_on_index then
  null ;
end;
/
grant alter session to wmsys ;
create or replace view wmsys.wm$base_version_view as
select decode(sign(vt1.anc_version - vt2.anc_version), 1, vt2.anc_version, vt1.anc_version) version,
       decode(sign(vt1.anc_version - vt2.anc_version), 1, vt2.anc_workspace, vt1.anc_workspace) workspace
from (select vt1.anc_version, vt1.anc_workspace
      from wmsys.wm$version_table vt1
      where vt1.workspace = sys_context('lt_ctx', 'diffWspc1') and
            vt1.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
      union all
      select decode(sys_context('lt_ctx', 'diffver1'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc1')),
                     sys_context('lt_ctx', 'diffver1')),
             sys_context('lt_ctx', 'diffWspc1')
      from dual
      where sys_context('lt_ctx', 'anc_workspace') = sys_context('lt_ctx', 'diffWspc1')
     ) vt1,
     (select vt2.anc_version, vt2.anc_workspace
      from wmsys.wm$version_table vt2
      where vt2.workspace = sys_context('lt_ctx', 'diffWspc2') and
            vt2.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
      union all
      select decode(sys_context('lt_ctx', 'diffver2'),
                   -1, (select current_version
                        from wmsys.wm$workspaces_table
                        where workspace = sys_context('lt_ctx', 'diffWspc2')),
                      sys_context('lt_ctx', 'diffver2')),
             sys_context('lt_ctx', 'diffWspc2')
      from dual where sys_context('lt_ctx', 'anc_workspace') = sys_context('lt_ctx', 'diffWspc2')
     ) vt2
WITH READ ONLY ;
create or replace view wmsys.wm$base_hierarchy_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$base_version_view bv
 where vht.workspace = bv.workspace and
       vht.version <= bv.version
union all
 select vht.version
 from wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht, wmsys.wm$base_version_view bv
 where vt.workspace = bv.workspace and
       vht.workspace = vt.anc_workspace and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff1_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table
 where workspace = sys_context('lt_ctx', 'diffWspc1') and
       version <= decode(sys_context('lt_ctx', 'diffver1'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table
                              where workspace = sys_context('lt_ctx', 'diffWspc1')),
                         sys_context('lt_ctx', 'diffver1'))
union all
 select version
 from wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht
 where vt.workspace = sys_context('lt_ctx', 'diffWspc1') and
       vt.anc_workspace = vht.workspace and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff2_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table
 where workspace = sys_context('lt_ctx', 'diffWspc2') and
       version <= decode(sys_context('lt_ctx', 'diffver2'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table
                              where workspace = sys_context('lt_ctx', 'diffWspc2')),
                         sys_context('lt_ctx', 'diffver2'))
union all
 select version
 from wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht
 where vt.workspace = sys_context('lt_ctx', 'diffWspc2') and
       vt.anc_workspace = vht.workspace and
       vht.version <= vt.anc_version
WITH READ ONLY ;
