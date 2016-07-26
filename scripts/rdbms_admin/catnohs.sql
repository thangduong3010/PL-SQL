Rem
Rem $Header: catnohs.sql 05-may-2008.17:01:12 kchen Exp $
Rem
Rem catnohs.sql
Rem
Rem Copyright (c) 1997, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem
Rem      catnohs.sql - Drop HS data dictionary tables & views
Rem
Rem    DESCRIPTION
Rem      This SQL script drops all database objects created for
Rem      Heterogeneous Services by caths.sql.
Rem
Rem      This script is available to HS content in the DD in the event
Rem      that DD content is seriously damaged.  Beginning with Oracle
Rem      9.0.2 the caths.sql script no longer purges table contents
Rem      in tables that exist when it is executed.  Executing caths.sql
Rem      alone would certail classes of errors but not all. Complete
Rem      replacement of HS DD content requires running catnohs.sql
Rem      first, then rerunning caths.sql.
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS or INTERNAL.
Rem
Rem      catnohs.sql was originally required to deinstall the
Rem      Heterogeneous Option.  This functionality is no longer
Rem      optional, it now comprises the Heterogeneous Services feature
Rem      of Oracle 8 and subsequent RDBMS releases.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kchen       05/05/08 - fixed bug 6943575
Rem    pcastro     04/16/07 - add Table Function support (bug 5610906)
Rem    kchen       02/19/07 - drop bulk load objects
Rem    pcastro     05/22/06 - adding HS DDTF cleanup
Rem    pravelin    07/31/01 - Document expected usage of this script.
Rem    rhungund    10/12/00 - adding the HS_FDS_CLASS_DATE table and view
Rem    delson      08/28/00 - remove processing of unused tables.
Rem    jdraaije    03/26/97 - Name consistency: ho => hs
Rem    pravelin    11/22/96 - Resynchronize this script with catho.sql updates
Rem    pravelin    06/26/96 - Drop HS data dictionary tables & views
Rem    pravelin    06/26/96 - Created
Rem


drop role hs_admin_select_role;
drop role hs_admin_execute_role;
drop role hs_admin_role;
drop table hs$_fds_class cascade constraints; 
drop sequence hs$_fds_class_s; 
drop view hs_fds_class; 
drop table hs$_fds_inst cascade constraints; 
drop sequence hs$_fds_inst_s; 
drop view hs_fds_inst;
drop table hs$_base_caps cascade constraints; 
drop view hs_base_caps;
drop table hs$_class_caps cascade constraints; 
drop sequence hs$_class_caps_s;
drop view hs_class_caps;
drop table hs$_inst_caps cascade constraints; 
drop sequence hs$_inst_caps_s; 
drop view hs_inst_caps;
drop table hs$_base_dd cascade constraints; 
drop sequence hs$_base_dd_s; 
drop view hs_base_dd;
drop table hs$_class_dd cascade constraints; 
drop sequence hs$_class_dd_s; 
drop view hs_class_dd;
drop table hs$_inst_dd cascade constraints; 
drop sequence hs$_inst_dd_s; 
drop view hs_inst_dd;
drop table hs$_class_init cascade constraints; 
drop sequence hs$_class_init_s; 
drop view hs_class_init;
drop table hs$_inst_init cascade constraints; 
drop sequence hs$_inst_init_s; 
drop view hs_inst_init;
drop view hs_all_caps;
drop view hs_all_dd;
drop view hs_all_inits;
drop package dbms_hs;
drop package dbms_hs_alt;
drop package dbms_hs_chk;
drop package dbms_hs_utl;
Rem %%% HS Table Function implementation
DROP FUNCTION SYS.HS$_DDTF_SQLTabStats;
DROP FUNCTION SYS.HS$_DDTF_SQLTabForKeys;
DROP FUNCTION SYS.HS$_DDTF_SQLTabPriKeys;
DROP FUNCTION SYS.HS$_DDTF_SQLStatistics;
DROP TYPE     SYS.HS$_DDTF_SQLStatistics_T;
DROP TYPE     SYS.HS$_DDTF_SQLStatistics_O;
DROP FUNCTION SYS.HS$_DDTF_SQLProcedures;
DROP TYPE     SYS.HS$_DDTF_SQLProcedures_T;
DROP TYPE     SYS.HS$_DDTF_SQLProcedures_O;
DROP FUNCTION SYS.HS$_DDTF_SQLForeignKeys;
DROP TYPE     SYS.HS$_DDTF_SQLForeignKeys_T;
DROP TYPE     SYS.HS$_DDTF_SQLForeignKeys_O;
DROP FUNCTION SYS.HS$_DDTF_SQLPrimaryKeys;
DROP TYPE     SYS.HS$_DDTF_SQLPrimaryKeys_T;
DROP TYPE     SYS.HS$_DDTF_SQLPrimaryKeys_O;
DROP FUNCTION SYS.HS$_DDTF_SQLColumns;
DROP TYPE     SYS.HS$_DDTF_SQLColumns_T;
DROP TYPE     SYS.HS$_DDTF_SQLColumns_O;
DROP FUNCTION SYS.HS$_DDTF_SQLTables;
DROP TYPE     SYS.HS$_DDTF_SQLTables_T;
DROP TYPE     SYS.HS$_DDTF_SQLTables_O;
Rem %%% HS Table Function implementation
drop public synonym hs_fds_class;
drop public synonym hs_fds_inst;
drop public synonym hs_base_caps;
drop public synonym hs_class_caps;
drop public synonym hs_inst_caps;
drop public synonym hs_base_dd;
drop public synonym hs_class_dd;
drop public synonym hs_inst_dd;
drop public synonym hs_class_init;
drop public synonym hs_inst_init;
drop public synonym hs_all_caps;
drop public synonym hs_all_dd;
drop public synonym hs_all_inits;
drop public synonym dbms_hs;
drop table hs$_fds_class_date;
drop view hs_fds_class_date;

drop public synonym DBMS_HS_PARALLEL;
drop package  DBMS_HS_PARALLEL;

drop public synonym dbms_hs_parallel_metadata;
drop package dbms_hs_parallel_metadata;

drop type HS_PARTITION_OBJ force;
drop type HS_PART_OBJ force;
drop type hs_sample_obj force;

drop type HSBLKNamLst force;
drop type HSBLKValAry force;

drop sequence hs_bulk_seq;

drop table HS_BULKLOAD_VIEW_OBJ;

drop public synonym HS_PARALLEL_METADATA;
drop view HS_PARALLEL_METADATA;
drop public synonym hs_parallel_partition_data;
drop view hs_parallel_partition_data;
drop public synonym hs_parallel_histogram_data;
drop view hs_parallel_histogram_data;
drop public synonym hs_parallel_sample_data;
drop view hs_parallel_sample_data;

drop  table hs$_parallel_partition_data;
drop  table hs$_parallel_histogram_data;
drop  table hs$_parallel_sample_data;
drop  table hs$_parallel_metadata;

begin

sys.dbms_scheduler.drop_program ( 'hs_parallel_sampling', true ) ;

end;
/

