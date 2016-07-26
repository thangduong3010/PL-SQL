update wmsys.wm$env_vars set value = '11.2.0.1.0' where name = 'OWM_VERSION';
commit;
drop view wmsys.wm$exp_map ;
drop table wmsys.wm$exp_map_tbl ;
drop type wmsys.wm$exp_map_tab ;
drop type wmsys.wm$exp_map_type ;
delete sys.impcalloutreg$ where tag='WMSYS' ;
delete wmsys.wm$hint_table where hint_id>5000 and isdefault=1 ;
commit ;
delete wmsys.wm$env_vars where name='DIFF_MODIFIED_ONLY' ;
commit ;
alter type wmsys.wm_period drop MAP member function wm_period_map return varchar2 cascade ;
drop type body wmsys.wm_period ;
revoke alter session from wmsys ;
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
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc1')),
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
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc2')),
                       sys_context('lt_ctx', 'diffver2'))
       from dual where sys_context('lt_ctx', 'anc_workspace') = 
                       sys_context('lt_ctx', 'diffWspc2')
      ) vt2,
      wmsys.wm$workspaces_table wmt
where wmt.workspace = sys_context('lt_ctx', 'anc_workspace');
create or replace view wmsys.wm$base_hierarchy_view as
  select -1 version from dual union all
  select version from wmsys.wm$version_hierarchy_table 
  start with version = (select version from wmsys.wm$base_version_view)
  connect by prior parent_version  = version
WITH READ ONLY;
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
