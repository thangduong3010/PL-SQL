Rem
Rem $Header: rdbms/admin/catnoap.sql /main/1 2009/07/01 21:39:04 kkunchit Exp $
Rem
Rem catnoap.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catnoap.sql - undo metadata/packages for archive provider
Rem
Rem    DESCRIPTION
Rem     To drop dbfs_hs
Rem     
Rem    NOTES
Rem     This script will clean up all DBFS_HS settings - packages, tables,
Rem     views, types etc.  
Rem    
Rem     To start afresh, run the following as SYSDBA
Rem     sqlplus '/ as sysdba' @catnoap
Rem
Rem     If your intent is to run  canocapi.sql, then you should be running
Rem     catnoap.sql first, otherwise dbfs_hs packages and metadata will become 
Rem     invalid. If you have run catnocapi.sql already, run this script
Rem     to drop all invalid objects of dbfs_hs
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shase       06/18/09 - Created
Rem


/* -------------------------- { 11.2 references { -------------------------- */
/* ----------------------- drop dynamic tables ------------------------ */

declare
begin
  dbms_arch_provider_intl.dropProviderTables;
end;
/
show errors;


/* -------------------- undo "prvtpspi.sql" -------------------- */

drop package body dbms_apbackend;
drop package body dbms_arch_provider_intl;
drop package body dbms_dbfs_hs;

drop package sys.dbms_apbackend;
drop library dbms_apbackend_lib;
drop package sys.dbms_arch_provider_intl;
 
/* -------------------------- undo "depspspi.sql" -------------------------- */


drop PUBLIC SYNONYM USER_DBFS_HS_FILES;
drop VIEW USER_DBFS_HS_FILES; 


/* -------------------- undo "dbmspspi.sql" -------------------- */

drop public synonym dbms_dbfs_hs force;
drop package dbms_dbfs_hs;


/* -------------------------- undo "catpspi.sql" --------------------------- */

drop table sys.dbfs_hs$_fs; 
drop table sys.dbfs_hs$_property; 
drop table sys.dbfs_hs$_SFLocatorTable; 
drop table sys.dbfs_hs$_BackupFileTable;
drop table sys.dbfs_hs$_ContentFnMapTbl; 
drop table sys.dbfs_hs$_StoreCommands;
drop table sys.dbfs_hs$_StoreId2PolicyCtx;
drop table sys.dbfs_hs$_StoreProperties;
drop table sys.dbfs_hs$_StoreIdTable;
drop sequence sys.dbfs_hs$_rseq;     
drop sequence dbfs_hs$_StoreIdSeq;
drop sequence dbfs_hs$_ArchiveRefIdSeq;
drop sequence dbfs_hs$_TarballSeq;
drop sequence dbfs_hs$_PolicyIdSeq;
drop sequence dbfs_hs$_BackupFileIdSeq;

drop public synonym DBA_DBFS_HS; 
drop view DBA_DBFS_HS; 

drop public synonym USER_DBFS_HS;
drop view USER_DBFS_HS; 

drop public synonym DBA_DBFS_HS_PROPERTIES; 
drop view DBA_DBFS_HS_PROPERTIES;

drop public synonym USER_DBFS_HS_PROPERTIES; 
drop view USER_DBFS_HS_PROPERTIES; 

drop public synonym DBA_DBFS_HS_COMMANDS; 
drop view DBA_DBFS_HS_COMMANDS;

drop public synonym USER_DBFS_HS_COMMANDS; 
drop view USER_DBFS_HS_COMMANDS;

drop public synonym DBA_DBFS_HS_FIXED_PROPERTIES; 
drop view DBA_DBFS_HS_FIXED_PROPERTIES; 

drop public synonym USER_DBFS_HS_FIXED_PROPERTIES;
drop view USER_DBFS_HS_FIXED_PROPERTIES;  


/* -------------------------- undo "catcapit.sql" -------------------------- */

drop public synonym dbms_dbfs_hs_litems_t;
drop type dbms_dbfs_hs_litems_t;

drop public synonym dbms_dbfs_hs_item_t;
drop type dbms_dbfs_hs_item_t;


/* -------------------------- } 11.2 references } -------------------------- */



/* ------------------- { 11.2beta2 upgrade references { -------------------- */
/* ----------------------- drop dynamic tables ------------------------ */


/* -------------------- undo "prvtpspi.sql" -------------------- */

drop package body dbms_archive_provider;

/* -------------------------- undo "depspspi.sql" -------------------------- */


drop PUBLIC SYNONYM USER_AP_ARCHIVED_FILES;
drop VIEW USER_AP_ARCHIVED_FILES; 


/* -------------------- undo "dbmspspi.sql" -------------------- */


drop public synonym dbms_archive_provider force;
drop package dbms_archive_provider;


/* -------------------------- undo "catpspi.sql" --------------------------- */

drop table sys.arch_provider$_fs; 
drop table sys.arch_provider$_property; 
drop table sys.PSPI$_SFLocatorTable; 
drop table sys.PSPI$_BackupFileTable;
drop table sys.PSPI$_ContentFnMapTbl; 
drop table sys.PSPI$_ReposCommands;
drop table sys.PSPI$_ReposId2PolicyCtx;
drop table sys.PSPI$_ReposProperties;
drop table sys.PSPI$_ReposIdTable;
drop table sys.PSPI$_SegmentProperties;
drop sequence sys.arch_provider$_rseq;     
drop sequence PSPI$_ReposIdSeq;
drop sequence PSPI$_ArchiveRefIdSeq;
drop sequence PSPI$_TarballSeq;
drop sequence PSPI$_PolicyIdSeq;
drop sequence PSPI$_BackupFileIdSeq;

drop public synonym DBA_AP_REPOSITORIES; 
drop view DBA_AP_REPOSITORIES; 

drop public synonym USER_AP_REPOSITORIES;
drop view USER_AP_REPOSITORIES; 

drop public synonym DBA_AP_REPOS_PROPERTIES; 
drop view DBA_AP_REPOS_PROPERTIES;

drop public synonym USER_AP_REPOS_PROPERTIES; 
drop view USER_AP_REPOS_PROPERTIES; 

drop public synonym DBA_AP_REPOS_COMMANDS; 
drop view DBA_AP_REPOS_COMMANDS;

drop public synonym USER_AP_REPOS_COMMANDS; 
drop view USER_AP_REPOS_COMMANDS;

drop public synonym DBA_AP_SEGMENT_ARCH_CONTENT; 
drop view DBA_AP_SEGMENT_ARCH_CONTENT;  

drop public synonym USER_AP_SEGMENT_ARCH_CONTENT; 
drop view USER_AP_SEGMENT_ARCH_CONTENT; 

drop public synonym DBA_AP_REPOS_FIXED_PROPERTIES; 
drop view DBA_AP_REPOS_FIXED_PROPERTIES; 

drop public synonym USER_AP_REPOS_FIXED_PROPERTIES;
drop view USER_AP_REPOS_FIXED_PROPERTIES;  


/* -------------------------- undo "catcapit.sql" -------------------------- */

drop public synonym dbms_arch_provider_litems_t;
drop type dbms_arch_provider_litems_t;

drop public synonym dbms_arch_provider_item_t;
drop type dbms_arch_provider_item_t;


/* ------------------- { 11.2beta2 upgrade references { -------------------- */

