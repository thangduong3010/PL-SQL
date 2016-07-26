@@owmr1012.plb
update wmsys.wm$env_vars set value = '10.1.0.0.0' where name = 'OWM_VERSION';
commit;
alter table wmsys.wm$versioned_tables drop(validTime) ;
drop public synonym wm_period ;
drop public synonym wm$mw_versions_view_9i;
drop view wmsys.wm$mw_versions_view_9i; 
drop public synonym wm_concat ;
drop type wmsys.wm_concat_impl ;
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);
begin
  execute immediate 'drop package sys.owm_vt_pkg' ;

exception when invalid_package then null;
end ;
/
drop public synonym wm$all_version_hview_wdepth;
drop view wmsys.all_version_hview_wdepth; 
ALTER TABLE wmsys.wm$versioned_tables DROP (initVTRange);
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  execute immediate 'drop table wmsys.wm$batch_compressible_tables' || purgeOption ;
end;
/
drop view sys.wm_compress_batch_sizes ;
drop public synonym wm_compress_batch_sizes ;
drop view wmsys.wm_compressible_tables ;
drop public synonym wm_compressible_tables ;
begin
  delete from wmsys.wm$sysparam_all_values where name = 'NUMBER_OF_COMPRESS_BATCHES';
  delete from wmsys.wm$env_vars where name = 'NUMBER_OF_COMPRESS_BATCHES';
  commit ;
end;
/
begin
  delete from wmsys.wm$sysparam_all_values where name = 'UNDO_SPACE';
  delete from wmsys.wm$env_vars where name = 'UNDO_SPACE';
  commit ;
end;
/
alter table wmsys.wm$replication_table drop (status) ;
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  execute immediate 'drop table wmsys.wm$replication_details_table' || purgeOption ;
end;
/
drop operator wmsys.wm_contains ;
drop operator wmsys.wm_equals ;
drop operator wmsys.wm_greaterthan ;
drop operator wmsys.wm_intersection ;
drop operator wmsys.wm_ldiff ;
drop operator wmsys.wm_lessthan ;
drop operator wmsys.wm_meets;
drop operator wmsys.wm_overlaps ;
drop operator wmsys.wm_rdiff ;
drop function wmsys.wm_concat ;
