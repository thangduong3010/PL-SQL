create or replace function sys.wm$convertDbVersion wrapped 
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
26f 158
6kmh8B/0cHagDPLeUzN0rZ0E5ScwgxDxJJkVfC+VkPg+SC+DrOMNRVR70nI9ORTm8W/ErAaP
cJnFRc7uAHmNFt9eFe3+Er9x8ZR6zH7X7p92ueySRSRMJXm+JJAoLs2JFhTejcPhl1oUQhTo
0efDAo9PrJUaRMjUlL43UgIMjvtcwGjDTIF5Mnp4S+BxZdx72XbCXqAZyZHQeR/mpa9EjYbr
/vqHRsptzh+lYCEJpZvM4BeyrxMR+w9qaV+kMWI31TpEQhsWuTfoGxYpN8+2iTNngrZGAFBo
NgEg47CgvDMZ7WSLNJq1eRkg/txzacHSrk4lmBF71q8d3mGJJQ==

/
grant execute on sys.wm$convertDBVersion to public;
var owm_version varchar2(30);
begin
  select value into :owm_version
  from wm_installation
  where name = 'OWM_VERSION' ;
end;
/
declare
 owm_ver varchar2(100);

 l_owner             varchar2(30);
 l_table_name        varchar2(30);

 l_workspace         varchar2(30);

 cursor vertab_cur is
   select owner, table_name
   from wm$versioned_tables
   where disabling_ver = 'NO' ;

begin

  begin
    execute immediate 'select value from wm_installation where name = ''OWM_VERSION''' into owm_ver ;

  exception when others then
    owm_ver := '9.0.1.0.0';
  end;

  if(owm_ver = '9.0.1.0.0') then

    









    
    delete from system.wm$env_vars where name = 'OWM_VERSION';
    insert into system.wm$env_vars values('OWM_VERSION','9.0.1.2.0');
    commit;

    


      open vertab_cur;
      loop
        fetch vertab_cur into l_owner,l_table_name;
        exit when vertab_cur%NOTFOUND;

        execute immediate 'create index ' || l_owner || '.' || l_table_name || '_AP1$ on ' || l_owner || '.' || l_table_name || '_AUX(ParentState,VersionParent)' ;

        execute immediate 'create index ' || l_owner || '.' || l_table_name || '_AP2$ on ' || l_owner || '.' || l_table_name || '_AUX(ChildState,VersionChild)' ;

        
        
        execute immediate 'delete from ' || l_owner || '.' || l_table_name || '_AUX
           where (parentstate in (select workspace from wm$workspaces_table where isRefreshed = 1)) or
                 (childstate in (select workspace from wm$workspaces_table where isRefreshed = 1))' ;

        commit;

      end loop;
      close vertab_cur;

  elsif(owm_ver = '9.0.1.2.0') then
    null;
  else
    RAISE_APPLICATION_ERROR(-20000, 'This script can only upgrade from OWM release 9.0.1.0.0 or 9.0.1.2.0.0');
  end if;
end;
/
create user wmsys identified by wmsys account lock;
grant connect, resource, create public synonym, drop public synonym, create role to wmsys;
begin
  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
  dbms_registry.loaded('OWM', :owm_version, 'Oracle Workspace Manager ' || :owm_version || ' - Production');
  dbms_registry.upgrading('OWM');
end;
/
create or replace procedure wmsys.wm$execSQL wrapped 
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
7
50 89
WeCtcur8g/RiT0kmc2+9WwlxhP8wg5nnm7+fMr2ywFwWclyhO1ouy8vSs6YGj8jKAnzGyhco
xsrvLkTGcNFJ6r+uJNFERLHn6sFQL+pErg8P6h+ugMqZUYPs2T1ylez7po3alPQ=

/
create type wmsys.wm$lock_info_type
 TIMESTAMP '2001-07-29:12:06:07'
 OID '8A3DB78598BD5DE2E034080020EDC61B' wrapped 
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
d
9b a2
h0zwrcf3rGjiA+skqR/I5E57XRMwg5n0dLhcFnJc+vqu/0pyRwzZ0JYmVlpDwHQrpb+bwDLL
s48JqdYvgEkssTC1uCSxygJ8xsoXKMbK77K2HS6kdCo/Srzinlc9MJK+Omq0uCpAOTnscWem
lLGgyaammllmeg==

/
create type wmsys.wm$lock_table_type
 TIMESTAMP '2001-07-29:12:06:07'
 OID '8A3DB78598C35DE2E034080020EDC61B'
as table of wmsys.wm$lock_info_type;
/
execute wmsys.wm$execSQL('grant execute on wm$lock_table_type to public');
create table wmsys.wm$ric_table (
ct_owner              varchar2(40),   /* child table owner */
ct_name               varchar2(40),   /* child table name */
pt_owner              varchar2(40),   /* parent table owner */
pt_name               varchar2(40),   /* parent table name */
ric_name              varchar2(40),
ct_cols               varchar2(4000),
pt_cols               varchar2(4000),
pt_unique_const_name  varchar2(40),
my_mode               varchar2(2),     /* cascade or restrict */
status                varchar2(8),     /* 'ENABLED' or 'DISABLED' */
constraint wm$ric_pk  PRIMARY KEY (ct_owner, ric_name) );
create index wmsys.wm$ric_table_ct_idx on wmsys.wm$ric_table(ct_owner, ct_name);
create index wmsys.wm$ric_table_pt_idx on wmsys.wm$ric_table(pt_owner, pt_name);
create table wmsys.wm$ric_triggers_table (
pt_owner                 varchar2(40),    /* parent table owner */
pt_name                  varchar2(40),    /* parent table name */
ct_owner                 varchar2(40),    /* child table owner */
ct_name                  varchar2(40),    /* child table name */
update_trigger_name      varchar2(40),    /* before update trigger name */
delete_trigger_name      varchar2(40),    /* before delete trigger name */
CONSTRAINT wm$ric_triggers_pk PRIMARY KEY (pt_owner, pt_name, ct_owner, ct_name) );
create table wmsys.wm$insteadof_trigs_table (
table_owner             varchar2(40),
table_name              varchar2(40),
insert_trig_name        varchar2(40),
update_trig_name        varchar2(40),
delete_trig_name        varchar2(40),
CONSTRAINT wm$insteadof_trigs_pk PRIMARY KEY (table_owner, table_name));
create table wmsys.wm$workspaces_table (
workspace         varchar2(30),
parent_workspace  varchar2(30),
current_version   number,
parent_version    number,
post_version      number,
verlist           varchar2(2000),
owner             varchar2(30),
createTime        date,
description       varchar2(1000),
workspace_lock_id integer,
freeze_status     varchar2(8),
freeze_mode       varchar2(12),
freeze_writer     varchar2(30),
oper_status       varchar2(30),
wm_lockmode       varchar2(5),
isRefreshed       integer,
constraint wm$workspaces_pk PRIMARY KEY (workspace)
);
create table wmsys.wm$version_table (
workspace     varchar2(30),
anc_workspace varchar2(30),
anc_version   integer,
constraint wm$version_pk PRIMARY KEY (workspace, anc_workspace));
create table wmsys.wm$nextver_table (
version     integer,
next_vers   varchar2(500),
workspace   varchar2(30),
split       integer);
create index wmsys.wm$nextver_table_indx on wmsys.wm$nextver_table(version);
create table wmsys.wm$version_hierarchy_table (
version        integer,
parent_version integer,
workspace      varchar2(30),
constraint wm$version_hierarchy_pk PRIMARY KEY (version));
create type wmsys.wm$ed_undo_code_node_type
 TIMESTAMP '2001-07-29:12:08:55'
 OID '8A3DA47750525DCEE034080020EDC61B' wrapped 
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
d
6e 9a
fHTTF+bP2yxALCA3XsB94Bz3+kkwg5n0dLhcFnJcoS70ltcM+tCu/66h8HId82yNRCZxSq+e
+dyH4v+onqtxnkE/0eLzCKjKpJ5n3OMKmPbIy1m01+s9xkSTV1dQSSJXFFr7Nm4Q5JCOITuI
pq51HHU=

/
execute wmsys.wm$execSQL('grant execute on wmsys.wm$ed_undo_code_node_type to public');
create type wmsys.wm$ed_undo_code_table_type
TIMESTAMP '2001-07-29:12:08:55'
OID '8A3DA47750585DCEE034080020EDC61B'
as table of wmsys.wm$ed_undo_code_node_type;
/
execute wmsys.wm$execSQL('grant execute on wmsys.wm$ed_undo_code_table_type to public');
create table wmsys.wm$versioned_tables (
vtid            integer not null,
table_name      varchar2(30),
owner           varchar2(30),
notification    integer,
notifyWorkspaces varchar2(4000),
disabling_ver   VARCHAR2(13),
ricWeight       integer,
isFastLive      integer default 0,
isWorkflow      integer default 0,
hist            varchar2(50) default 'NONE',      /* history option */
pkey_cols       varchar2(4000) default '',
undo_code       wmsys.wm$ed_undo_code_table_type,
constraint wm$versioned_tables__pk PRIMARY KEY (table_name, owner)
) nested table undo_code store as wm$versioned_tables_undo_code;
create table wmsys.wm$workspace_priv_table (
grantee        varchar2(30),
workspace      varchar2(30),
grantor        varchar2(30),
priv           varchar2(10),
admin          integer
);
create table wmsys.wm$workspace_sessions_table (
username        varchar2(30),
workspace       varchar2(30),
sid             varchar2(25),
myver           integer default -1,
constraint wm$workspace_sessions_pk PRIMARY KEY (workspace, sid));
create table wmsys.wm$workspace_savepoints_table (
workspace       varchar2(30),
savepoint       varchar2(30),
version         number,
position        integer,
is_implicit     number,
owner           varchar2(30),
createTime      date,
description     varchar2(1000),
constraint wm$workspace_savepoints_pk PRIMARY KEY (workspace, savepoint));
create type wmsys.wm$conflict_payload_type
TIMESTAMP '2001-07-29:12:06:11'
OID '8A3DB78598D25DE2E034080020EDC61B' wrapped 
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
d
c2 db
3YwKUdKWq/KvN+tzJk9r1uTl7fswg5n0dLhcFnJcof9yDNn6WdH0llrYR/quWfSWJlZaQ8B0
K6W/m8Ayy8xQjwnnsp+ynstSdFJcqal8xsoXKMbK77ILHS6k0QIvrg/qDqAgpsODRE3TFoqK
u8FvLLksXaR2j32Kq19QAeBwprPBfV2G/MF9bWpUILGFfIBPaXVW5oPnTZAM6+z7prXclo8=


/
create table wmsys.wm$modified_tables (
  vtid          integer,      /* unique id for versioned_table */
  table_name    varchar2(61), /* owner_name.table_name */
  version       integer,
  workspace     varchar2(30)
);
begin
   execute immediate 'alter table wmsys.wm$modified_tables add constraint modified_tables_pk PRIMARY KEY (workspace, table_name, version)';
end;
/
create table wmsys.wm$adt_func_table (
  func_name  varchar2(30),
  type_name  varchar2(30),
  ref_count  number        /* number of cols using this type */
);
create table wmsys.wm$udtrig_info (
trig_owner_name  varchar2(50),
trig_name        varchar2(50),
table_owner_name varchar2(50),
table_name       varchar2(50),
trig_type        varchar2(3),
status           varchar(10),  /* ENABLED OR DISABLED */
trig_procedure   varchar2(50), /* wm generated proc implementing the trigger */
when_clause      varchar2(4000),
description      varchar2(4000),
trig_code        long,
constraint wm$udtrig_info_pk primary key (trig_owner_name,trig_name));
create table wmsys.wm$udtrig_dispatch_procs (
table_owner_name varchar2(50),
table_name       varchar2(50),
dispatcher_name  varchar2(50),
bir_flag         varchar2(3) default '',
air_flag         varchar2(3) default '',
bur_flag         varchar2(3) default '',
aur_flag         varchar2(3) default '',
bdr_flag         varchar2(3) default '',
adr_flag         varchar2(3) default '',
constraint wm$udtrig_dispatch_procs_pk primary key (table_owner_name,table_name));
create table wmsys.wm$resolve_workspaces_table (
  workspace     varchar2(30),
  resolve_user  varchar2(30),
  undo_sp_name  varchar2(30),
  undo_sp_ver   integer,
  oldFreezeMode varchar2(30),
  oldFreezeWriter varchar2(30),
 constraint wm$resolve_workspaces_pk PRIMARY KEY (workspace)
);
create table wmsys.wm$env_vars( name varchar2(100), value varchar2(4000) );
create table wmsys.wm$lockrows_info( workspace    varchar2(30),
                                   owner        varchar2(30),
                                   table_name   varchar2(30),
                                   where_clause clob);
create index wmsys.wm$lockrows_info_idx on wmsys.wm$lockrows_info (workspace);
Declare
 val integer;
Begin

 select sys.wm$up_del_trig_name_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$up_del_trig_name_sequence start with ' || val;

 select sys.wm$insteadof_trigs_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$insteadof_trigs_sequence start with ' || val;

 select sys.wm$lock_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$lock_sequence start with ' || val;

 select sys.wm$vtid.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$vtid start with ' || val;

 select sys.wm$adt_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$adt_sequence start with ' || val;

 select sys.wm$version_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$version_sequence start with ' || val;

 select sys.wm$row_sync_id_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$row_sync_id_sequence start with ' || val;

 select sys.wm$udtrig_dispatcher_sequence.nextval into val from dual;
 execute immediate 'create sequence wmsys.wm$udtrig_dispatcher_sequence start with ' || val;

End;
/
insert into wmsys.wm$version_table select * from sys.wm$version_table;
insert into wmsys.wm$nextver_table select * from sys.wm$nextver_table;
insert into wmsys.wm$version_hierarchy_table select * from sys.wm$version_hierarchy_table;
insert into wmsys.wm$workspaces_table select * from sys.wm$workspaces_table;
insert into wmsys.wm$workspace_priv_table select * from sys.wm$workspace_priv_table;
insert into wmsys.wm$workspace_sessions_table select * from sys.wm$workspace_sessions_table;
insert into wmsys.wm$workspace_savepoints_table select * from sys.wm$workspace_savepoints_table;
insert into wmsys.wm$resolve_workspaces_table select * from sys.wm$resolve_workspaces_table;
insert into wmsys.wm$adt_func_table select * from sys.wm$adt_func_table;
insert into wmsys.wm$env_vars select * from system.wm$env_vars;
declare
 vtid_v          integer;
 table_name_v    varchar2(30);
 owner_v         varchar2(30);
 notification_v  integer;
 notifyWorkspaces_v varchar2(4000);
 disabling_ver_v VARCHAR2(13);
 ricWeight_v     integer;
 isFastLive_v    integer default 0;
 isWorkflow_v    integer default 0;
 hist_v          varchar2(50) ;
 pkey_cols_v     varchar2(4000) default '';
 undo_code_v     wmsys.wm$ed_undo_code_table_type;
 index_type_v    integer;
 index_field_v   integer;
 sql_str_v      clob;

 cursor c1 is select vtid,table_name,owner,notification,notifyWorkspaces,disabling_ver,ricWeight,isFastLive,isWorkflow,hist,pkey_cols from sys.wm$versioned_tables;

 cursor c2 is select index_type, index_field, sql_str from table (select undo_code from sys.wm$versioned_tables where owner = owner_v and table_name = table_name_v);

begin

  open c1;
  loop
    fetch c1 into vtid_v,table_name_v,owner_v,notification_v,notifyWorkspaces_v,disabling_ver_v,ricWeight_v,isFastLive_v,isWorkflow_v,hist_v,pkey_cols_v;
    exit when c1%NOTFOUND;

    insert into wmsys.wm$versioned_tables values(vtid_v,table_name_v,owner_v,notification_v,notifyWorkspaces_v,disabling_ver_v,ricWeight_v,isFastLive_v,isWorkflow_v,hist_v,pkey_cols_v,wmsys.wm$ed_undo_code_table_type());

    open c2;
    loop
      fetch c2 into index_type_v, index_field_v, sql_str_v;
      exit when c2%NOTFOUND;

      insert into table (select undo_code
                       from wmsys.wm$versioned_tables
                       where owner = owner_v and
                             table_name = table_name_v )
           values (wmsys.wm$ed_undo_code_node_type(index_type_v,index_field_v,sql_str_v));
     end loop;
     close c2;

  end loop;
  close c1;

end;
/
insert into wmsys.wm$ric_table select * from sys.wm$ric_table;
insert into wmsys.wm$ric_triggers_table select * from sys.wm$ric_triggers_table;
insert into wmsys.wm$insteadof_trigs_table select * from sys.wm$insteadof_trigs_table;
insert into wmsys.wm$modified_tables select * from sys.wm$modified_tables;
declare
 trig_owner_name_v  varchar2(50);
 trig_name_v        varchar2(50);
 table_owner_name_v varchar2(50);
 table_name_v       varchar2(50);
 trig_type_v        varchar2(3);
 status_v           varchar(10);
 trig_procedure_v   varchar2(50);
 when_clause_v      varchar2(4000);
 description_v      varchar2(4000);
 trig_code_v        long;

 cursor c1 is select trig_owner_name,trig_name,table_owner_name,table_name,trig_type,status, trig_procedure,when_clause,description,trig_code from system.wm$udtrig_info;

begin

  open c1;
  loop
    fetch c1 into trig_owner_name_v,trig_name_v,table_owner_name_v,table_name_v,trig_type_v,status_v, trig_procedure_v,when_clause_v,description_v,trig_code_v;
    exit when c1%NOTFOUND;

    insert into wmsys.wm$udtrig_info values(trig_owner_name_v,trig_name_v,table_owner_name_v,table_name_v,trig_type_v,status_v, trig_procedure_v,when_clause_v,description_v,trig_code_v);
  end loop;
  close c1;

end;
/
insert into wmsys.wm$udtrig_dispatch_procs select * from sys.wm$udtrig_dispatch_procs;
insert into wmsys.wm$lockrows_info select * from system.wm$lockrows_info;
update wmsys.wm$versioned_tables set disabling_ver = 'VERSIONED';
update wmsys.wm$workspace_savepoints_table set savepoint = workspace || '-' || savepoint
where is_implicit = 1;
delete from sys.wm$version_table;
delete from sys.wm$nextver_table;
delete from sys.wm$version_hierarchy_table;
delete from sys.wm$workspaces_table;
delete from sys.wm$workspace_priv_table;
delete from sys.wm$workspace_sessions_table;
delete from sys.wm$workspace_savepoints_table;
delete from sys.wm$resolve_workspaces_table;
delete from sys.wm$adt_func_table;
delete from system.wm$env_vars;
delete from sys.wm$versioned_tables;
delete from sys.wm$ric_table;
delete from sys.wm$ric_triggers_table;
delete from sys.wm$insteadof_trigs_table;
delete from sys.wm$modified_tables;
delete from system.wm$udtrig_info;
delete from sys.wm$udtrig_dispatch_procs;
delete from system.wm$lockrows_info;
commit;
create or replace procedure wm$execSQLIgnoreError wrapped 
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
7
92 c6
UfM+oefAf0BVyzUoV+H6GZksZXgwgyptmMvhqC/pOzoYPlagDVWeOGa3pVQHNc1WdC0lLhHS
TkSM1xBdQdrHZRGZ7zQcHpLixM/S9arRO+D2DAXSI9fTNtzs8Os0BeEBDcYd6UQkHd2Z7Gbn
juGjJQBzqrf8jK+TFhD6A2rnoXbAOYitb7tbjs0aQNgiZutJjQ==

/
declare
  t                  integer;
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
    dbms_utility.db_version(version_str,compatibility_str);
    version_str := sys.wm$convertDbVersion(version_str);

    if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
      purgeOption := ' PURGE' ;
    end if ;

    




    
    wm$execSQLIgnoreError('drop trigger no_vm_create');
    wm$execSQLIgnoreError('drop trigger no_vm_drop');
    wm$execSQLIgnoreError('drop trigger sys_logoff');

    
    wm$execSQLIgnoreError('drop procedure no_vm_create_proc');
    wm$execSQLIgnoreError('drop procedure no_vm_drop_proc');
    wm$execSQLIgnoreError('drop procedure logoff_proc');

    
    wm$execSQLIgnoreError('drop type wm$lock_table_type');
    wm$execSQLIgnoreError('drop type wm$lock_info_type');

    wm$execSQLIgnoreError('drop package sys.ltadm');
    wm$execSQLIgnoreError('drop package sys.ltUtil');
    wm$execSQLIgnoreError('drop context lt_ctx');
    wm$execSQLIgnoreError('drop package sys.lt_ctx_pkg');
    wm$execSQLIgnoreError('drop package sys.ltdtrg');
    wm$execSQLIgnoreError('drop package sys.ltaq');
    wm$execSQLIgnoreError('drop package sys.ltric');
    wm$execSQLIgnoreError('drop package sys.ltrls');
    wm$execSQLIgnoreError('drop package sys.wm_ddl_util');
    wm$execSQLIgnoreError('drop package sys.ltddl');
    wm$execSQLIgnoreError('drop package sys.ltPriv');
    wm$execSQLIgnoreError('drop package sys.lt_expadm_pkg');
    wm$execSQLIgnoreError('drop package sys.lt_export_pkg');
    wm$execSQLIgnoreError('drop package sys.lt');
    wm$execSQLIgnoreError('drop package sys.ud_trigs');
    wm$execSQLIgnoreError('drop package sys.wm_error');

    
    wm$execSQLIgnoreError('drop table wm$version_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$nextver_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$version_hierarchy_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$workspaces_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$versioned_tables' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$workspace_priv_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$workspace_sessions_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$workspace_savepoints_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$resolve_workspaces_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$adt_func_table' || purgeOption);
    wm$execSQLIgnoreError('drop table system.wm$env_vars' || purgeOption);
	
    
    wm$execSQLIgnoreError('drop table wm$ric_table' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$ric_triggers_table' || purgeOption);

    
    wm$execSQLIgnoreError('drop table wm$insteadof_trigs_table' || purgeOption);

    
    wm$execSQLIgnoreError('drop table wm$modified_tables' || purgeOption);

    
    wm$execSQLIgnoreError('drop table system.wm$udtrig_info' || purgeOption);
    wm$execSQLIgnoreError('drop table wm$udtrig_dispatch_procs' || purgeOption);

    
    wm$execSQLIgnoreError('drop type wm$ed_undo_code_table_type');
    wm$execSQLIgnoreError('drop type wm$ed_undo_code_node_type');

    
    wm$execSQLIgnoreError('drop table system.wm$lockrows_info' || purgeOption);

    







    wm$execSQLIgnoreError('drop type wm$conflict_payload_type');

    
    wm$execSQLIgnoreError('drop sequence wm$vtid');

    
    wm$execSQLIgnoreError('drop sequence wm$version_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$row_sync_id_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$up_del_trig_name_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$insteadof_trigs_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$udtrig_dispatcher_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$adt_sequence');

    
    wm$execSQLIgnoreError('drop sequence wm$lock_sequence');

    wm$execSQLIgnoreError('drop view all_workspaces_internal');
    wm$execSQLIgnoreError('drop view all_version_hview');
    wm$execSQLIgnoreError('drop view user_wm_privs');
    wm$execSQLIgnoreError('drop view role_wm_privs');
    wm$execSQLIgnoreError('drop view user_workspaces');
    wm$execSQLIgnoreError('drop view all_workspaces');
    wm$execSQLIgnoreError('drop view lt_workspace_tree');
    wm$execSQLIgnoreError('drop view user_workspace_privs');
    wm$execSQLIgnoreError('drop view all_workspace_privs');
    wm$execSQLIgnoreError('drop view user_wm_modified_tables');
    wm$execSQLIgnoreError('drop view all_wm_modified_tables');
    wm$execSQLIgnoreError('drop view user_wm_tab_triggers');
    wm$execSQLIgnoreError('drop view all_wm_tab_triggers');
    wm$execSQLIgnoreError('drop view user_wm_versioned_tables');
    wm$execSQLIgnoreError('drop view all_wm_versioned_tables');
    wm$execSQLIgnoreError('drop view user_workspace_savepoints');
    wm$execSQLIgnoreError('drop view all_workspace_savepoints');
    wm$execSQLIgnoreError('drop view dba_workspace_sessions');
    wm$execSQLIgnoreError('drop view dba_workspaces');
    wm$execSQLIgnoreError('drop view dba_wm_sys_privs');
    wm$execSQLIgnoreError('drop view dba_workspace_privs');
    wm$execSQLIgnoreError('drop view dba_wm_versioned_tables');
    wm$execSQLIgnoreError('drop view dba_workspace_savepoints');
    wm$execSQLIgnoreError('drop view user_wm_ric_info');
    wm$execSQLIgnoreError('drop view all_wm_ric_info');
    wm$execSQLIgnoreError('drop view all_wm_locked_tables');
    wm$execSQLIgnoreError('drop view user_wm_locked_tables');

    wm$execSQLIgnoreError('drop public synonym all_workspaces_internal');
    wm$execSQLIgnoreError('drop public synonym all_version_hview');
    wm$execSQLIgnoreError('drop public synonym user_wm_privs');
    wm$execSQLIgnoreError('drop public synonym role_wm_privs');
    wm$execSQLIgnoreError('drop public synonym user_workspaces');
    wm$execSQLIgnoreError('drop public synonym all_workspaces');
    wm$execSQLIgnoreError('drop public synonym lt_workspace_tree');
    wm$execSQLIgnoreError('drop public synonym user_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym all_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym user_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym all_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym user_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym all_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym user_wm_modified_tables');
    wm$execSQLIgnoreError('drop public synonym all_wm_modified_tables');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_sessions');
    wm$execSQLIgnoreError('drop public synonym user_wm_ric_info');
    wm$execSQLIgnoreError('drop public synonym all_wm_ric_info');
    wm$execSQLIgnoreError('drop public synonym user_wm_tab_triggers');
    wm$execSQLIgnoreError('drop public synonym all_wm_tab_triggers');
    wm$execSQLIgnoreError('drop public synonym all_wm_locked_tables');
    wm$execSQLIgnoreError('drop public synonym user_wm_locked_tables');

    wm$execSQLIgnoreError('drop public synonym dba_workspaces');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym dba_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym dba_wm_sys_privs');

    wm$execSQLIgnoreError('drop view wm$version_view');
    wm$execSQLIgnoreError('drop view wm$current_parvers_view');
    wm$execSQLIgnoreError('drop view wm$current_nextvers_view');
    wm$execSQLIgnoreError('drop view wm$curConflict_parvers_view');
    wm$execSQLIgnoreError('drop view wm$curConflict_nextvers_view');
    wm$execSQLIgnoreError('drop view wm$parConflict_parvers_view');
    wm$execSQLIgnoreError('drop view wm$parConflict_nextvers_view');
    wm$execSQLIgnoreError('drop view wm$current_workspace_view');
    wm$execSQLIgnoreError('drop view wm$parent_workspace_view');
    wm$execSQLIgnoreError('drop view wm$current_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$parent_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$curConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$parConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$current_savepoints_view');
    wm$execSQLIgnoreError('drop view wm$diff1_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$diff2_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$base_hierarchy_view');
    wm$execSQLIgnoreError('drop view wm$diff1_nextver_view');
    wm$execSQLIgnoreError('drop view wm$diff2_nextver_view');
    wm$execSQLIgnoreError('drop view wm$base_nextver_view');
    wm$execSQLIgnoreError('drop view wm$all_locks_view');
    wm$execSQLIgnoreError('drop view wm$current_ver_view');
    wm$execSQLIgnoreError('drop view wm$ver_bef_inst_parvers_view');
    wm$execSQLIgnoreError('drop view wm$ver_bef_inst_nextvers_view');
    wm$execSQLIgnoreError('drop view wm$modified_tables_view');

    wm$execSQLIgnoreError('drop public synonym wm$current_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_workspace_view');
    wm$execSQLIgnoreError('drop public synonym wm$parent_workspace_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$parent_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_savepoints_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff1_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff2_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$base_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff1_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff2_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$base_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_ver_view');
    wm$execSQLIgnoreError('drop public synonym wm$ver_bef_inst_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$ver_bef_inst_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm_installation');

    wm$execSQLIgnoreError('drop role wm_admin_role');

    
    wm$execSQLIgnoreError('drop package sys.lt_expadm_pkg');

    
    commit;

End;
/
@@owmt9012.plb
@@owmcpkgs.plb
@@owmcvws.plb
@@owmcpkgb.plb
declare

  l_owner varchar2(30);
  l_table_name varchar2(30);

  cursor vertab_cur is
    select owner, table_name
    from wmsys.wm$versioned_tables
    order by ricWeight;

  drop_view_table EXCEPTION;
  PRAGMA EXCEPTION_INIT(drop_view_table, -00942);


begin

  for tab_rec in vertab_cur loop
    begin
      execute immediate 'drop view ' || tab_rec.owner || '.' || tab_rec.table_name || '_MWB' ;

    exception when drop_view_table then null;
    end;
  end loop;

end;
/
declare

  l_owner varchar2(30);
  l_table_name varchar2(30);
  l_hist       varchar2(50);
  l_pkey_cols  varchar2(4000);
  l_pkey_cols_lt varchar2(4100);
  l_constraint_name varchar2(30);

  error_flag boolean := false;

  err_num             number;
  err_msg             varchar2(200);
  err_msg_full        varchar2(1000) := '';

  cursor vertab_cur is
    select vt.owner, vt.table_name, vt.hist, vt.pkey_cols, dc.constraint_name
    from wmsys.wm$versioned_tables vt, dba_constraints dc
    where vt.owner = dc.owner and vt.table_name || '_LT' = dc.table_name
          and vt.hist = 'VIEW_WO_OVERWRITE'
          and dc.constraint_type = 'P'
    order by ricWeight desc;

begin

  open vertab_cur;
  loop
    begin
      fetch vertab_cur into l_owner, l_table_name, l_hist, l_pkey_cols, l_constraint_name;
      exit when vertab_cur%NOTFOUND;

      
      execute immediate 'alter table ' || l_owner || '.' || l_table_name || '_LT drop constraint ' || l_constraint_name ;

      l_pkey_cols_lt := 'VERSION,' || l_pkey_cols || ',DELSTATUS';

      
      execute immediate 'alter table ' || l_owner || '.' || l_table_name || '_LT add constraint '
                 || l_constraint_name || ' PRIMARY KEY (' || l_pkey_cols_lt || ')';

    exception when others then
      err_num := SQLCODE;
      err_msg := substr(SQLERRM,1,200);
      err_msg_full := err_msg_full || l_owner || '.' || l_table_name || '_LT:
' || err_msg || '
';
      error_flag := true;
    end;
  end loop;
  close vertab_cur;

  if (error_flag) then
    
    WMSYS.WM_ERROR.RAISEERROR(WMSYS.LT.WM_ERROR_195_NO, err_msg_full);
  end if;
end;
/
declare
  cursor dispatcher_name_cur is
   select dispatcher_name, trig_flag
   from wmsys.wm$udtrig_dispatch_procs ;

 invalid_procedure EXCEPTION;
 PRAGMA EXCEPTION_INIT(invalid_procedure, -04043);

Begin
  for proc_rec in dispatcher_name_cur loop
    if (bitand(proc_rec.trig_flag, wmsys.ud_trigs.BIR_FLAG)!=0 or bitand(proc_rec.trig_flag, wmsys.ud_trigs.BUR_FLAG)!=0) then
      begin
        execute immediate 'drop procedure ' || proc_rec.dispatcher_name || '_io';

      exception when invalid_procedure then null ;
      end ;
    end if;

    if (bitand(proc_rec.trig_flag, wmsys.ud_trigs.AIR_FLAG)!=0 or bitand(proc_rec.trig_flag, wmsys.ud_trigs.AUR_FLAG)!=0 or
        bitand(proc_rec.trig_flag, wmsys.ud_trigs.BDR_FLAG)!=0 or bitand(proc_rec.trig_flag, wmsys.ud_trigs.ADR_FLAG)!=0) then
      begin
        execute immediate 'drop procedure ' || proc_rec.dispatcher_name ;

      exception when invalid_procedure then null ;
      end ;
    end if;

  end loop ;

  execute immediate 'begin delete from wmsys.wm$udtrig_dispatch_procs ; commit ; end;' ;
end;
/
declare

  l_owner varchar2(60);
  l_trig1 varchar2(60);
  l_trig2 varchar2(60);

  cursor trigs_cur is select table_owner, update_trig_name, delete_trig_name from wmsys.wm$insteadof_trigs_table ;

  drop_trigger EXCEPTION;
  PRAGMA EXCEPTION_INIT(drop_trigger, -04080);

begin

  open trigs_cur;
  loop
    fetch trigs_cur into l_owner, l_trig1, l_trig2;
    exit when trigs_cur%NOTFOUND;

    
    begin
      execute immediate 'drop trigger ' || l_owner || '.MAIN_' || l_trig1 ;
      execute immediate 'drop trigger ' || l_owner || '.MAIN_' || l_trig2 ;

    exception when drop_trigger then null;
    end;
  end loop;
  close trigs_cur;

end;
/
declare
 trig_owner_var   varchar2(50);
 table_name_var   varchar2(50);
 table_owner_var  varchar2(50);
 trig_proc_var    varchar2(50);

 cursor c1 is
   select trig_owner_name, table_name, table_owner_name, trig_procedure
   from wmsys.wm$udtrig_info;

begin

 open c1;
 loop
   fetch c1 into trig_owner_var, table_name_var, table_owner_var, trig_proc_var;
   exit when c1%NOTFOUND;

   
   
   if (table_owner_var != trig_owner_var) then
     execute immediate
            'create or replace procedure ' || trig_owner_var || '.' || table_name_var || '_g is
             begin
               execute immediate ''grant execute on ' || trig_owner_var || '.' || trig_proc_var || ' to ' || table_owner_var || ''';
             end;' ;

     execute immediate 'Begin ' || trig_owner_var || '.' || table_name_var || '_g; End;' ;

     execute immediate 'drop procedure ' || trig_owner_var || '.' || table_name_var || '_g';
   end if;

   execute immediate
          'create or replace procedure ' || trig_owner_var || '.' || table_name_var || '_g is
           begin
             execute immediate ''grant execute on ' || trig_owner_var || '.' || trig_proc_var || ' to wmsys'';
           end;' ;

   execute immediate 'Begin ' || trig_owner_var || '.' || table_name_var || '_g; End;' ;

   execute immediate 'drop procedure ' || trig_owner_var || '.' || table_name_var || '_g';

 end loop;
 close c1;

end;
/
execute wmsys.owm_mig_pkg.AllFixSentinelVersion ;
execute wmsys.owm_mig_pkg.FixCrWorkspaces ;
create or replace view wmsys.wm$current_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers
             from wmsys.wm$nextver_table nvt
where
(
 (
   nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    nvt.version   <=   decode(sys_context('lt_ctx','version'),
                       null,(SELECT current_version
                               FROM wmsys.wm$workspaces_table
                               WHERE workspace = 'LIVE'),
                       -1,(select current_version
                           from wmsys.wm$workspaces_table
                           where workspace = sys_context('lt_ctx','state')),
                           sys_context('lt_ctx','version')
                          )
 )
 or
 ( exists ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version )
 )
);
begin
  wmsys.owm_mig_pkg.old_owm_version_for_upgrade := '9.0.1.0.0' ;
end;
/
execute wmsys.ltadm.recreateAdtFunctions ;
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;
execute wmsys.owm_mig_pkg.AllLwEnableVersioning ;
create or replace view wmsys.wm$current_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers, nvt.version
             from wmsys.wm$nextver_table nvt
where
(
 (
   nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    nvt.version   <=   decode(sys_context('lt_ctx','version'),
                       null,(SELECT current_version
                               FROM wmsys.wm$workspaces_table
                               WHERE workspace = 'LIVE'),
                       -1,(select current_version
                           from wmsys.wm$workspaces_table
                           where workspace = sys_context('lt_ctx','state')),
                           sys_context('lt_ctx','version')
                          )
 )
 or
 ( exists ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version )
 )
);
execute wmsys.ltric.recreatePtUpdDelTriggers;
execute wmsys.owm_mig_pkg.moveWMMetaData;
execute wmsys.owm_mig_pkg.recompileAllObjects ;
declare
 found integer;
begin
   begin
     select 1 into found from dual where exists (select 1 from wmsys.wm$versioned_tables);
     wmsys.ltadm.enableSystemTriggers_exp;
   exception
     when no_data_found then null;
     when others then raise;
   end;
end;
/
drop procedure wm$execSQLIgnoreError;
create or replace public synonym DBMS_WM for wmsys.lt ;
select owner, name, type, text
from dba_errors
where owner = 'WMSYS' or
      owner in (select owner from wmsys.wm$versioned_tables) or
      (owner || '.' || name) in (select dispatcher_name from wmsys.wm$udtrig_dispatch_procs)
order by 1,2;
declare
  version_str        varchar2(100) ;
  compatibility_str  varchar2(100) ;
  ver                varchar2(100) ;
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := wmsys.wm$convertDbVersion(version_str);

  if (1=1) then
    dbms_registry.upgraded('OWM');
  else
    select value into ver
    from wm_installation
    where name = 'OWM_VERSION' ;

    dbms_registry.upgraded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Production');
  end if ;

  if ((nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.7.0', 'nls_sort=ascii7') and
       nlssort(version_str, 'nls_sort=ascii7') <  nlssort('A.0.0.0.0', 'nls_sort=ascii7')) or
      nlssort(version_str, 'nls_sort=ascii7')  >= nlssort('A.1.0.4.0', 'nls_sort=ascii7')) then
    execute immediate 'begin sys.validate_owm; end;' ;
  else
    execute immediate 'begin wmsys.validate_owm; end;' ;
  end if;
end;
/
