rem 
rem $Header: catdbsyn.sql 24-may-2001.11:33:53 gviswana Exp $ 
rem 
Rem  Copyright (c) 1991 by Oracle Corporation 
Rem    NAME
Rem      catdbsyn.sql - catalog dba synonyms
Rem    DESCRIPTION
Rem      Creates private synonyms for DBA-only dictionary views.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This file is made obsolete as DBA is now a role.  All DBA_% catalog
Rem      views have a corresponding public synonym, and are accessible to
Rem      any user with SELECT ANY TABLE privilege.
Rem    MODIFIED   (MM/DD/YY)
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     wmaimone   05/26/94 -  #186155 add public synoyms for dba_
Rem     glumpkin   10/20/92 -  Renamed from DBA_SYN.SQL 
Rem     mmoore     07/13/92 - #(118440) add dba_priv_audit_opts synonym 
Rem     mmoore     07/06/92 -  change 'grants' to 'privs' in privilege views 
Rem     rjenkins   04/24/92 -  adding snapshot views 
Rem     mmoore     09/18/91 -  add dba_roles 
Rem     rlim       08/22/91 - Creation - rename dba_synonyms.sql to dba_syn.sql
Rem     rlim       07/30/91 -         added dba synonyms from catalog.sql & aud
Rem     Kooi       03/11/91 - new stuff for procedures/triggers
Rem     Moore      10/04/90 - add dba_col_grants
rem	Grayson	   03/20/88 - Creation
rem     Mendels    05/11/89 - rename dba_exp_tables -> dba_exp_objects
rem
create or replace synonym DBA_CATALOG for SYS.DBA_CATALOG
/
create or replace synonym DBA_CLUSTERS for SYS.DBA_CLUSTERS
/
create or replace synonym DBA_CLU_COLUMNS for SYS.DBA_CLU_COLUMNS
/
create or replace synonym DBA_COL_COMMENTS for SYS.DBA_COL_COMMENTS
/
create or replace synonym DBA_CROSS_REFS for SYS.DBA_CROSS_REFS
/
create or replace synonym DBA_DATA_FILES for SYS.DBA_DATA_FILES
/
create or replace synonym DBA_DB_LINKS for SYS.DBA_DB_LINKS
/
create or replace synonym DBA_EXP_FILES for SYS.DBA_EXP_FILES
/
create or replace synonym DBA_EXP_OBJECTS for SYS.DBA_EXP_OBJECTS
/
create or replace synonym DBA_EXP_VERSION for SYS.DBA_EXP_VERSION
/
create or replace synonym DBA_EXTENTS for SYS.DBA_EXTENTS
/
create or replace synonym DBA_FREE_SPACE for SYS.DBA_FREE_SPACE
/
create or replace synonym DBA_INDEXES for SYS.DBA_INDEXES
/
create or replace synonym DBA_IND_COLUMNS for SYS.DBA_IND_COLUMNS
/
create or replace synonym DBA_OBJECTS for SYS.DBA_OBJECTS
/
create or replace synonym DBA_SEQUENCES for SYS.DBA_SEQUENCES
/
create or replace synonym DBA_TAB_COLUMNS for SYS.DBA_TAB_COLUMNS
/
create or replace synonym DBA_TAB_COMMENTS for SYS.DBA_TAB_COMMENTS
/
create or replace synonym DBA_TAB_PRIVS for SYS.DBA_TAB_PRIVS
/
create or replace synonym DBA_ROLLBACK_SEGS for SYS.DBA_ROLLBACK_SEGS
/
create or replace synonym DBA_SEGMENTS for SYS.DBA_SEGMENTS
/
create or replace synonym DBA_SYNONYMS for SYS.DBA_SYNONYMS
/
create or replace synonym DBA_TABLESPACES for SYS.DBA_TABLESPACES
/
create or replace synonym DBA_TABLES for SYS.DBA_TABLES
/
create or replace synonym DBA_TS_QUOTAS for SYS.DBA_TS_QUOTAS
/
create or replace synonym DBA_USERS for SYS.DBA_USERS
/
create or replace synonym DBA_VIEWS for SYS.DBA_VIEWS
/
create or replace synonym DBA_COL_PRIVS for SYS.DBA_COL_PRIVS
/
create or replace synonym DBA_TRIGGERS for SYS.DBA_TRIGGERS
/
create or replace synonym DBA_ROLE_PRIVS for SYS.DBA_ROLE_PRIVS
/
create or replace synonym DBA_SYS_PRIVS for SYS.DBA_SYS_PRIVS
/
create or replace synonym DBA_CONSTRAINTS for SYS.DBA_CONSTRAINTS
/
create or replace synonym DBA_CONS_COLUMNS for SYS.DBA_CONS_COLUMNS
/
create or replace synonym DBA_OBJ_AUDIT_OPTS for SYS.DBA_OBJ_AUDIT_OPTS
/
create or replace synonym DBA_STMT_AUDIT_OPTS for SYS.DBA_STMT_AUDIT_OPTS
/
create or replace synonym DBA_PRIV_AUDIT_OPTS for SYS.DBA_PRIV_AUDIT_OPTS
/
create or replace synonym DBA_AUDIT_TRAIL for SYS.DBA_AUDIT_TRAIL
/
create or replace synonym DBA_AUDIT_SESSION for SYS.DBA_AUDIT_SESSION
/
create or replace synonym DBA_AUDIT_STATEMENT for SYS.DBA_AUDIT_STATEMENT
/
create or replace synonym DBA_AUDIT_OBJECT for SYS.DBA_AUDIT_OBJECT
/
create or replace synonym DBA_AUDIT_EXISTS for SYS.DBA_AUDIT_EXISTS
/
create or replace synonym DBA_2PC_PENDING for SYS.DBA_2PC_PENDING
/
create or replace synonym DBA_2PC_NEIGHBORS for SYS.DBA_2PC_NEIGHBORS
/
create or replace synonym DBA_DEPENDENCIES for SYS.DBA_DEPENDENCIES
/
create or replace synonym DBA_ERRORS for SYS.DBA_ERRORS
/
create or replace synonym DBA_OBJECT_SIZE for SYS.DBA_OBJECT_SIZE
/
create or replace synonym DBA_SOURCE for SYS.DBA_SOURCE
/
create or replace synonym DBA_PROFILES for SYS.DBA_PROFILES
/
create or replace synonym DBA_ROLES for SYS.DBA_ROLES
/
create or replace synonym DBA_SNAPSHOTS for SYS.DBA_SNAPSHOTS
/
create or replace synonym DBA_SNAPSHOT_LOGS for SYS.DBA_SNAPSHOT_LOGS
/
