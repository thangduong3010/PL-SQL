Rem
Rem $Header: rdbms/admin/catnocapi.sql /st_rdbms_11.2.0/1 2011/03/04 12:07:48 kkunchit Exp $
Rem
Rem catnocapi.sql
Rem
Rem Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnocapi.sql - Core DBFS cleanup.
Rem
Rem    DESCRIPTION
Rem      Core DBFS cleanup.
Rem
Rem    NOTES
Rem     To cleanup all core DBFS content and SFS reference provider
Rem     settings (registrations, mounts, tables, packages, types, roles,
Rem     etc.) and start afresh, run the following as SYSDBA.
Rem
Rem         sqlplus '/ as sysdba' @catnocapi
Rem
Rem     Once this script completes execution, the usual steps for
Rem     initializing/loading the DBFS API can be used.
Rem
Rem     This script can be run multiple times (ignoring any errors
Rem     it raises).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkunchit    03/02/11 - Backport kkunchit_bug-10349967 from main
Rem    kkunchit    02/25/11 - bug-10349967: dbfs export/import support
Rem    kkunchit    11/11/08 - Created
Rem



/* -------------------------- { 11.2 references { -------------------------- */
/* ----------------- cleanout export/import infrastructure ----------------- */

delete
from    sys.exppkgact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

delete
from    sys.expdepact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

commit;

/* ----------------------- drop all SFS filesystems ------------------------ */

declare
begin
    execute immediate 'dbms_dbfs_sfs_admin.drop_all_tables';
exception
    when others then
        dbms_output.put_line('ignoring dbms_dbfs_sfs_admin.drop_all_tables');
end;
/
show errors;



/* -------------------- undo "prvt{fspi,fuse,capi}.sql" -------------------- */

drop package body dbms_dbfs_sfs_admin;
drop package body dbms_dbfs_sfs;

drop package body dbms_fuse;

drop package body dbms_dbfs_content_admin;
drop package body dbms_dbfs_content;



/* -------------------------- undo "depscapi.sql" -------------------------- */

drop public synonym dbfs_content force;
drop view dbfs_content;

drop public synonym dbfs_content_properties force;
drop view dbfs_content_properties;




/* -------------------- undo "dbms{fspi,fuse,capi}.sql" -------------------- */

drop public synonym dbms_dbfs_sfs_admin force;
drop package dbms_dbfs_sfs_admin;

drop public synonym dbms_dbfs_sfs force;
drop package dbms_dbfs_sfs;

drop public synonym dbms_fuse force;
drop package dbms_fuse;

drop package dbms_dbfs_content_spi;

declare
begin
    execute immediate 'drop context dbfs_context';
exception
    when others then
        dbms_output.put_line('ignoring dbfs_context');
end;
/
show errors;

drop public synonym dbms_dbfs_content_admin force;
drop package dbms_dbfs_content_admin;

drop public synonym dbms_dbfs_content force;
drop package dbms_dbfs_content;



/* -------------------------- undo "catcapi.sql" --------------------------- */

drop table sys.dbfs_sfs$_fsto;
drop table sys.dbfs_sfs$_fstp;
drop table sys.dbfs_sfs$_fst;
drop sequence sys.dbfs_sfs$_fsseq;

drop table sys.dbfs_sfs$_fs;
drop table sys.dbfs_sfs$_snap;
drop table sys.dbfs_sfs$_vol;
drop table sys.dbfs_sfs$_tab;

drop table sys.dbfs$_stats;
drop table sys.dbfs$_mounts;
drop table sys.dbfs$_stores;



/* -------------------------- undo "catcapit.sql" -------------------------- */

drop public synonym dbms_dbfs_content_list_items_t force;
drop type dbms_dbfs_content_list_items_t force;

drop public synonym dbms_dbfs_content_list_item_t force;
drop type dbms_dbfs_content_list_item_t force;

drop public synonym dbms_dbfs_content_raw_t force;
drop type dbms_dbfs_content_raw_t force;

drop public synonym dbms_dbfs_content_context_t force;
drop type dbms_dbfs_content_context_t force;

drop public synonym dbms_dbfs_content_properties_t force;
drop type dbms_dbfs_content_properties_t force;

drop public synonym dbms_dbfs_content_property_t force;
drop type dbms_dbfs_content_property_t force;

declare
begin
    execute immediate 'drop role dbfs_role';
exception
    when others then
        dbms_output.put_line('ignoring dbfs_role');
end;
/
show errors;

/* -------------------------- } 11.2 references } -------------------------- */



/* ------------------- { 11.2beta2 upgrade references { -------------------- */
/* ---------------------- drop all POSIX filesystems ----------------------- */

declare
begin
    dbms_posix_admin.drop_all_tables;
end;
/
show errors;



/* -------------------- undo "prvt{fspi,fuse,capi}.sql" -------------------- */

drop package body dbms_posix_admin;
drop package body dbms_posix;

drop package body dbms_fuse;

drop package body dbms_content_admin;
drop package body dbms_content;



/* -------------------------- undo "depscapi.sql" -------------------------- */

drop public synonym capi_properties force;
drop view capi_properties;

drop public synonym capi_resources force;
drop view capi_resources;




/* -------------------- undo "dbms{fspi,fuse,capi}.sql" -------------------- */

drop public synonym dbms_posix_admin force;
drop package dbms_posix_admin;

drop public synonym dbms_posix force;
drop package dbms_posix;

drop public synonym dbms_fuse force;
drop package dbms_fuse;

drop package dbms_content_spi;

drop context capi_context;

drop public synonym dbms_content_admin force;
drop package dbms_content_admin;

drop public synonym dbms_content force;
drop package dbms_content;



/* -------------------------- undo "catcapi.sql" --------------------------- */

drop table sys.posix$_fsto;
drop table sys.posix$_fstp;
drop table sys.posix$_fst;
drop sequence sys.posix$_fsseq;

drop table sys.posix$_fs;
drop table sys.posix$_snap;
drop table sys.posix$_vol;
drop table sys.posix$_tab;

drop table sys.capi$_stats;
drop table sys.capi$_mounts;
drop table sys.capi$_repositories;



/* -------------------------- undo "catcapit.sql" -------------------------- */

drop public synonym dbms_content_list_items_t force;
drop type dbms_content_list_items_t force;

drop public synonym dbms_content_list_item_t force;
drop type dbms_content_list_item_t force;

drop public synonym dbms_content_raw_t force;
drop type dbms_content_raw_t force;

drop public synonym dbms_content_context_t force;
drop type dbms_content_context_t force;

drop public synonym dbms_content_properties_t force;
drop type dbms_content_properties_t force;

drop public synonym dbms_content_property_t force;
drop type dbms_content_property_t force;

drop role capi_user_role;

/* ------------------- } 11.2beta2 upgrade references } -------------------- */



