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
270 158
7YzoyUrxd7Gdk3sWAMdGV8+fL5QwgxDxJJkVfC+VkPg+SC+DrOMNRVR70nI9ORTm8W/ErAaP
cJnFRc7uAHmNFt9eFe3+Er9x8ZR6zH7X7p92ueySRSRMJXm+JJAoLs2JFhTejcPhl1oUQhTo
0efDAo9P4VRZo6becfekBOpTovNpbMYuPVyah8bHHdXUbIYaA0eo2gEeEGAztJ+oNixxaa0i
EE+K6efC46r7IKKCRJYsbJ88LzT0b6UqdJW091XTU/EPyBesBhwRJ6zxHIV4Nd4oIYI1tB3X
LmkzQDDyHva7VR32//hzmotzn7t3KDLctSqW7W3oggR6ptu2iZs=

/
grant execute on sys.wm$convertDBVersion to public;
Declare
  cnt                  integer; 
  version_str          varchar2(1000) := '';
  compatibility_str    varchar2(1000) := '';
Begin
    dbms_utility.db_version(version_str,compatibility_str);
    version_str := sys.wm$convertDbVersion(version_str);
    compatibility_str := sys.wm$convertDbVersion(compatibility_str);

    select count(*) into cnt
    from   dba_tablespaces 
    where  tablespace_name = 'SYSAUX';

    if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7') and
        nlssort(compatibility_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7') and cnt > 0) then
       execute immediate 'create user wmsys identified by wmsys account lock password expire default tablespace SYSAUX';
    else
       execute immediate 'create user wmsys identified by wmsys account lock password expire'; 
    end if;
End;
/
grant connect, resource, create public synonym, drop public synonym, create role to wmsys;
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
9c a2
xByvrbM+14dgykYpNRIWwI7LR5owg5n0dLhcFnJc+vqu/0pyRwzZ0JYmVlpDCbh0K6W/m8Ay
y7OPCanWL4BJLLEwtbgkscoCfMbKFyjGyu+yth0upHQqP0q84p5XPTCSvjpqtLgqQDk57HFn
ppSxoMmmps7fZnE=

/
create type wmsys.wm$lock_table_type 
 TIMESTAMP '2001-07-29:12:06:07'
 OID '8A3DB78598C35DE2E034080020EDC61B'
as table of wmsys.wm$lock_info_type;
/
execute wmsys.wm$execSQL('grant execute on wmsys.wm$lock_table_type to public');
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
create sequence wmsys.wm$up_del_trig_name_sequence;
create table wmsys.wm$insteadof_trigs_table (
table_owner             varchar2(40),
table_name              varchar2(40),
insert_trig_name        varchar2(40),
update_trig_name        varchar2(40),
delete_trig_name        varchar2(40),
CONSTRAINT wm$insteadof_trigs_pk PRIMARY KEY (table_owner, table_name));
create sequence wmsys.wm$insteadof_trigs_sequence;
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
insert into wmsys.wm$workspaces_table values ('LIVE',null,0,null,null,null,'SYS', null, null, 0, 'UNLOCKED',null,null,null,null,0);
commit;
create sequence wmsys.wm$lock_sequence;
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
insert into wmsys.wm$version_hierarchy_table values (0,-1,'LIVE');
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
create sequence wmsys.wm$vtid;
create table wmsys.wm$workspace_priv_table (
grantee        varchar2(30),
workspace      varchar2(30),
grantor        varchar2(30),
priv           varchar2(10),
admin          integer
);
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','AA',1);
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','CA',1);
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','RA',1);
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','DA',1);
insert into wmsys.wm$workspace_priv_table values ('WM_ADMIN_ROLE',null,'SYS','MA',1);
insert into wmsys.wm$workspace_priv_table values ('PUBLIC','LIVE','SYS','M',0);
insert into wmsys.wm$workspace_priv_table values ('PUBLIC','LIVE','SYS','A',0);
commit;
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
alter table wmsys.wm$modified_tables add constraint modified_tables_pk PRIMARY KEY (workspace, table_name, version) ;
create table wmsys.wm$adt_func_table (
  func_name  varchar2(30),    
  type_name  varchar2(30),
  ref_count  number        /* number of cols using this type */
);
create sequence wmsys.wm$adt_sequence;
create sequence wmsys.wm$version_sequence;
create sequence wmsys.wm$row_sync_id_sequence start with 11;
create table wmsys.wm$udtrig_info (
trig_owner_name  varchar2(50),
trig_name        varchar2(50),
table_owner_name varchar2(50),
table_name       varchar2(50),
trig_type        varchar2(3),
status           varchar(10),  /* ENABLED OR DISABLED */
trig_procedure   varchar2(50), /* wmsys.wm generated proc implementing the trigger */
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
create sequence wmsys.wm$udtrig_dispatcher_sequence;
create table wmsys.wm$resolve_workspaces_table (
  workspace     varchar2(30), 
  resolve_user  varchar2(30),
  undo_sp_name  varchar2(30),
  undo_sp_ver   integer,
  oldFreezeMode varchar2(30),
  oldFreezeWriter varchar2(30),
 constraint wm$resolve_workspaces_pk PRIMARY KEY (workspace)
);
INSERT INTO sys.exppkgact$ VALUES ('LT_EXPORT_PKG','WMSYS',1,1000);
INSERT INTO sys.exppkgact$ VALUES ('LT_EXPORT_PKG','WMSYS',2,1000);
commit;
create table wmsys.wm$env_vars( name varchar2(100), value varchar2(4000) ); 
create table wmsys.wm$lockrows_info( workspace    varchar2(30), 
                                   owner        varchar2(30),
                                   table_name   varchar2(30),
                                   where_clause clob);
create index wmsys.wm$lockrows_info_idx on wmsys.wm$lockrows_info (workspace);
insert into wmsys.wm$env_vars values('OWM_VERSION','9.0.1.2.0');
commit;
@@owmt9012.plb
