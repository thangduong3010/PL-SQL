update wmsys.wm$env_vars set value = '9.0.1.4.0' where name = 'OWM_VERSION';
commit;
drop index wmsys.wm$nextver_table_indx;
create index wmsys.wm$nextver_table_indx on wmsys.wm$nextver_table(version,next_vers);
create table wmsys.wm$replication_table(groupname  varchar2(30) primary key, 
                                        masterDefSite     varchar2(128),
                                        oldMasterDefSites varchar2(4000));
alter table wmsys.wm$versioned_tables add (sitesList varchar2(4000));
alter table wmsys.wm$versioned_tables add( repSiteCount integer default 0 );
create table wmsys.wm$nested_columns_table(
owner        varchar2(30),
table_name   varchar2(30),
column_name  varchar2(30),
position     integer,
type_owner   varchar2(30),
type_name    varchar2(30),
nt_owner     varchar2(30),
nt_name      varchar2(30),
nt_store     varchar2(30),
CONSTRAINT wm$nested_columns_pk PRIMARY KEY (owner, table_name, column_name)
);
create sequence wmsys.wm$nested_columns_seq ;
drop index wmsys.wm$mod_tab_ver_ind;
create index wmsys.wm$mod_tab_ver_ind on wmsys.wm$modified_tables (version, workspace);
alter table wmsys.wm$workspaces_table add( implicit_sp_cnt integer default 0 ) ;
update wmsys.wm$workspaces_table set implicit_sp_cnt = current_version ;
commit;
