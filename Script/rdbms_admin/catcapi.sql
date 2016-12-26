Rem
Rem $Header: rdbms/admin/catcapi.sql /st_rdbms_11.2.0/2 2011/06/14 06:45:14 kkunchit Exp $
Rem
Rem catcapi.sql
Rem
Rem Copyright (c) 2009, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catcapi.sql - DBFS content/sfs-provider metadata tables/views
Rem
Rem    DESCRIPTION
Rem      DBFS content/sfs-provider metadata tables/views
Rem
Rem    NOTES
Rem      DBFS metadata tables maintain the state of stores and mounts. SFS
Rem      metadata tables maintain the state of filesystem tables and
Rem      filesystem stores. Canonical template tables also provider
Rem      cursor-types for the SFS provider.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkunchit    06/10/11 - Backport kkunchit_bug-12582607 from main
Rem    kkunchit    03/02/11 - Backport kkunchit_bug-10349967 from main
Rem    kkunchit    05/27/11 - bug-12568334: sfs sequence cache
Rem    kkunchit    02/17/11 - bug-10349967: dbfs export/import support
Rem    kkunchit    01/15/09 - Created
Rem



/* ------------------- dbms_dbfs_content metadata tables ------------------- */

create table sys.dbfs$_stores (
        s_owner     varchar2(32)    not null
    ,   s_name      varchar2(32)    not null
    ,   p_name      varchar2(32)    not null
    ,   p_pkg       varchar2(32)    not null
    ,   created     timestamp       not null
        /* global constraints */
    ,   primary key (s_owner, s_name)
);

grant select on sys.dbfs$_stores
    to dbfs_role;


create table sys.dbfs$_mounts (
        s_owner     varchar2(32)    not null
    ,   s_name      varchar2(32)    not null
    ,   s_mount     varchar2(32)
    ,   created     timestamp       not null
    ,   s_props     dbms_dbfs_content_properties_t
        /* global constraints */
    ,   foreign key (s_owner, s_name)
        references  sys.dbfs$_stores(s_owner, s_name)
    ,   unique      (s_owner, s_mount)
)
    nested table s_props store as s_props_tab;

create unique index sys.is_dbfs$_mounts
    on
    sys.dbfs$_mounts(decode(s_mount, null, s_owner, null));

grant select on sys.dbfs$_mounts
    to dbfs_role;


create table sys.dbfs$_stats (
        s_owner varchar2(32)    not null
    ,   s_name  varchar2(32)    not null
    ,   s_mount varchar2(32)
    ,   opcode  integer         not null
    ,   count   integer         not null
    ,   wtime   integer         not null
    ,   ctime   integer         not null
        /* global constraints */
    ,   unique  (s_owner, s_name, s_mount, opcode)
)
    tablespace sysaux;



/* --------------------- dbfs_dbfs_sfs metadata tables --------------------- */

create table sys.dbfs_sfs$_tab (
        tabid       number          not null
                    primary key
    ,   schema_name varchar2(32)    not null
    ,   table_name  varchar2(32)    not null
    ,   ptable_name varchar2(32)
    ,   version#    varchar2(32)    not null
    ,   created     timestamp       not null
    ,   formatted   timestamp       not null
    ,   properties  dbms_dbfs_content_properties_t
        /* global constraints */
    ,   unique      (schema_name, table_name)
)
    nested table properties
        store as properties_tab;

grant select on sys.dbfs_sfs$_tab
    to dbfs_role;


create table dbfs_sfs$_vol (
        tabid       number          not null
    ,   volid       number          not null
    ,   volname     varchar2(128)   not null
    ,   created     timestamp       not null
    ,   csnap#      number          not null
        /* volume <-> (volume, snapshot) dependency */
    ,   dvolid      number
    ,   dsnap#      number
    ,   deleted     number          not null
                    check (deleted in (0, 1))
        /* global constraints */
    ,   primary key (tabid, volid)
    ,   foreign key (tabid)
        references  sys.dbfs_sfs$_tab(tabid)
);

grant select on sys.dbfs_sfs$_vol
    to dbfs_role;


create table dbfs_sfs$_snap (
        tabid       number          not null
    ,   volid       number          not null
    ,   snap#       number          not null
    ,   snapname    varchar2(128)   not null
    ,   created     timestamp       not null
    ,   deleted     number          not null
                    check (deleted in (0, 1))
        /* global constraints */
    ,   primary key (tabid, volid, snap#)
    ,   foreign key (tabid, volid)
        references  sys.dbfs_sfs$_vol(tabid, volid)
);

grant select on sys.dbfs_sfs$_snap
    to dbfs_role;


create table sys.dbfs_sfs$_fs (
        store_owner varchar2(32)    not null
    ,   store_name  varchar2(32)    not null
    ,   tabid       number          not null
    ,   volid       number          not null
    ,   snap#       number
    ,   created     timestamp       not null
        /* global constraints */
    ,   unique      (store_owner, store_name)
    ,   unique      (store_owner, tabid, volid, snap#)
    ,   foreign key (tabid, volid)
        references  sys.dbfs_sfs$_vol(tabid, volid)
);

grant select on sys.dbfs_sfs$_fs
    to dbfs_role;



/* --------------------------- dbfs_sfs sequence --------------------------- */

create sequence sys.dbfs_sfs$_fsseq
    minvalue 1
    start with 1
    cache 8192;

grant select on sys.dbfs_sfs$_fsseq
    to dbfs_role;



/* -------- dbfs_sfs dummy filesystem table (for type compilation) --------- */
/* ----------------------- using parent-child tables ----------------------- */

create table sys.dbfs_sfs$_fst (
        /* volume/snapshot fields */
        volid                   number          default 0
                                                not null
    ,   csnap#                  number          default 0
                                                not null
    ,   lsnap#                  number          default null
        /* basic fields for the DBFS-API */
    ,   pathname                varchar2(1024)  not null
    ,   item                    varchar2(256)   not null
    ,   pathtype                integer         not null
                                check (pathtype in (1, 2, 3, 4))
    ,   filedata                blob
        /* POSIX-specific fields */
    ,   posix_nlink             integer         default 1
                                check (posix_nlink > 0)
    ,   posix_mode              integer         default 0      /* ---------- */
    ,   posix_uid               integer         default 0          /* root=0 */
    ,   posix_gid               integer         default 0          /* root=0 */
        /* standard properties for the DBFS-API */
    ,   std_access_time         timestamp       not null
    ,   std_acl                 varchar2(1024)
    ,   std_change_time         timestamp       not null
    ,   std_content_type        varchar2(1024)
    ,   std_creation_time       timestamp       not null
    ,   std_deleted             integer         not null
                                check (std_deleted in (0, 1))
    ,   std_guid                integer         not null
    ,   std_modification_time   timestamp       not null
    ,   std_owner               varchar2(32)
    ,   std_parent_guid         integer         not null
    ,   std_referent            varchar2(1024)
        /* optional properties for the DBFS-API */
    ,   opt_hash_type           varchar2(32)
    ,   opt_hash_value          varchar2(128)
    ,   opt_lock_count          integer
    ,   opt_lock_data           varchar2(128)
    ,   opt_lock_status         integer
        /* global constraints */
    ,   primary key             (volid, std_guid, csnap#)
    ,   unique                  (volid, pathname, csnap#)
    ,   unique                  (volid, std_parent_guid, std_guid, csnap#)
);

create table sys.dbfs_sfs$_fstp (
        /* foreign key */
        volid                   number          default 0
                                                not null
    ,   csnap#                  number          default 0
                                                not null
    ,   lsnap#                  number          default null
    ,   std_guid                integer         not null
        /* sys.dbms_dbfs_content_properties_t expanded */
    ,   propname                varchar2(32)    not null
    ,   propvalue               varchar2(1024)  not null
    ,   typecode                integer         not null
        /* global constraints */
    ,   unique                  (volid, std_guid, csnap#, propname)
    ,   foreign key             (volid, std_guid, csnap#)
        references              sys.dbfs_sfs$_fst(volid, std_guid, csnap#)
);

grant select on sys.dbfs_sfs$_fst
    to dbfs_role;

grant select on sys.dbfs_sfs$_fstp
    to dbfs_role;



/* -------- dbfs_sfs dummy filesystem table (for type compilation) --------- */
/* -------------------------- using object types --------------------------- */

create table sys.dbfs_sfs$_fsto (
        /* volume/snapshot fields */
        volid                   number          default 0
                                                not null
    ,   csnap#                  number          default 0
                                                not null
    ,   lsnap#                  number          default null
        /* basic fields for the DBFS-API */
    ,   pathname                varchar2(1024)  not null
    ,   item                    varchar2(256)   not null
    ,   pathtype                integer         not null
                                check (pathtype in (1, 2, 3, 4))
    ,   filedata                blob
        /* POSIX-specific fields */
    ,   posix_nlink             integer         default 1
                                check (posix_nlink > 0)
    ,   posix_mode              integer         default 0      /* ---------- */
    ,   posix_uid               integer         default 0          /* root=0 */
    ,   posix_gid               integer         default 0          /* root=0 */
        /* standard properties for the DBFS-API */
    ,   std_access_time         timestamp       not null
    ,   std_acl                 varchar2(1024)
    ,   std_change_time         timestamp       not null
    ,   std_content_type        varchar2(1024)
    ,   std_creation_time       timestamp       not null
    ,   std_deleted             integer         not null
                                check (std_deleted in (0, 1))
    ,   std_guid                integer         not null
    ,   std_modification_time   timestamp       not null
    ,   std_owner               varchar2(32)
    ,   std_parent_guid         integer         not null
    ,   std_referent            varchar2(1024)
        /* optional properties for the DBFS-API */
    ,   opt_hash_type           varchar2(32)
    ,   opt_hash_value          varchar2(128)
    ,   opt_lock_count          integer
    ,   opt_lock_data           varchar2(128)
    ,   opt_lock_status         integer
        /* user-defined properties for the DBFS-API */
    ,   usr_properties          sys.dbms_dbfs_content_properties_t
        /* global constraints */
    ,   primary key             (volid, std_guid, csnap#)
    ,   unique                  (volid, pathname, csnap#)
    ,   unique                  (volid, std_parent_guid, std_guid, csnap#)
)
    nested table usr_properties
        store as usr_properties_tab;

grant select on sys.dbfs_sfs$_fsto
    to dbfs_role;



/* ------------------- export/import procedural actions -------------------- */
/* -------- export/import dependency registrations during upgrades --------- */

-- equivalent to dbms_dbfs_sfs_admin.eximregisterAll
declare
begin
    lock table sys.dbfs_sfs$_tab
        in exclusive mode;

    -- (re)establish registrations
    delete
    from    sys.exppkgact$
    where   package = 'DBMS_DBFS_SFS_ADMIN'
        and schema  = 'SYS';

    insert into sys.exppkgact$(package, schema, class, level#)
        values ('DBMS_DBFS_SFS_ADMIN', 'SYS', 3, 1000);


    -- (re)establish dependencies
    delete
    from    sys.expdepact$
    where   package = 'DBMS_DBFS_SFS_ADMIN'
        and schema  = 'SYS';

    for rws in
    (
        select  o.object_id
        from    dba_objects         o
            ,   sys.dbfs_sfs$_tab   t
        where   o.owner       = t.schema_name
            and o.object_name = t.table_name
            and o.object_type = 'TABLE'
    )
    loop
        insert
        into    sys.expdepact$
        (
                obj#
            ,   package
            ,   schema
        )
        values
        (
                rws.object_id
            ,   'DBMS_DBFS_SFS_ADMIN'
            ,   'SYS'
        );
    end loop;

    commit;
end;
/
show errors;



