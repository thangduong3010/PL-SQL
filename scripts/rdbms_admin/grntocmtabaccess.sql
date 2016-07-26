Rem
Rem $Header: emll/admin/scripts/grntocmtabaccess.sql /st_emll_10.3.8.1/1 2013/06/05 11:25:06 davili Exp $
Rem
Rem grntocmtabaccess.sql
Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      grntocmtabaccess.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    davili      05/31/13 - Fix for rdbms drop
Rem    jsutton     12/27/12 - more CDB required work
Rem    jsutton     12/20/12 - clean up
Rem    ameshram    04/12/12 - Created
Rem

 DECLARE
   l_is_cdb VARCHAR2(5) := 'NO';
   g_version_category VARCHAR2(10) := NULL;
   VERSION_817 CONSTANT VARCHAR(3) := '817';
   VERSION_9i CONSTANT VARCHAR(3) := '9i';
   VERSION_9iR2 CONSTANT VARCHAR(4) := '9iR2';
   VERSION_10gR1 CONSTANT VARCHAR(5) := '10gR1';
   VERSION_10gR2 CONSTANT VARCHAR(5) := '10gR2';
   VERSION_11gR1 CONSTANT VARCHAR(5) := '11gR1';
   VERSION_11gR2 CONSTANT VARCHAR(5) := '11gR2';
   VERSION_12gR0 CONSTANT VARCHAR(5) := '12gR0';
   VERSION_12gR1 CONSTANT VARCHAR(5) := '12gR1';

   MIN_SUPPORTED_VERSION CONSTANT VARCHAR2(10) := '08.1.7.0.0';
   NOT_SUPPORTED_VERSION CONSTANT VARCHAR(3) := 'NSV';
   VERSION_10g CONSTANT VARCHAR2(10) := '10g';
   HIGHER_SUPPORTED_VERSION CONSTANT VARCHAR(3) := 'HSV';
   VERSION_10L CONSTANT VARCHAR2(20) := 'VERSION_10L';

PROCEDURE grant_table_access(p_table VARCHAR2)
 IS
 BEGIN
   execute immediate 'GRANT SELECT ON ' || p_table || ' TO ORACLE_OCM';
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;

FUNCTION get_version_category RETURN VARCHAR2 IS
 l_db_version VARCHAR2(17):= NULL;
 l_temp_version VARCHAR2(17) :=NULL;
 l_compat_vers VARCHAR2(17):= NULL;
 l_major_version_ndx NUMBER;
BEGIN
 select version into l_db_version from v$instance;
 BEGIN
   select substr(value,1,5) into l_compat_vers from v$parameter where lower(name) = 'compatible';
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   l_compat_vers := SUBSTR(l_db_version,1,5);
 END;

 l_temp_version := LPAD(l_db_version,10, '0');
 IF l_temp_version < MIN_SUPPORTED_VERSION THEN
   return NOT_SUPPORTED_VERSION;
 END IF;
 
 IF l_temp_version < '10.0.0.0.0' THEN 
   return VERSION_10L;
 END IF;

 IF l_compat_vers = '8.1.7' THEN
   return VERSION_817;
 END IF;

 l_temp_version := SUBSTR(l_db_version,1,4);
 IF l_temp_version = '10.1' THEN
   return VERSION_10gR1;
 END IF;
 IF l_temp_version= '10.2' THEN
   return VERSION_10gR2;
 END IF;
 IF l_temp_version= '11.1' THEN
   return VERSION_11gR1;
 END IF;
 IF l_temp_version= '11.2' THEN
   return VERSION_11gR2;
 END IF;
 IF l_temp_version= '12.0' THEN
   return VERSION_12gR0; 
  END IF;
 IF l_temp_version= '12.1' THEN 
   return VERSION_12gR1; 
 END IF;

 l_temp_version := SUBSTR(l_db_version,1,3);
 IF l_temp_version = '9.2' THEN
   return VERSION_9iR2;
 END IF;
 IF l_temp_version = '9.0' THEN
   return VERSION_9i;
 END IF;

 l_temp_version := SUBSTR(l_db_version,1,5);
 IF l_temp_version = '8.1.7' THEN
   return VERSION_817;
 END IF;

 return HIGHER_SUPPORTED_VERSION;
END get_version_category;

 BEGIN
 -- Get the version category
 g_version_category := get_version_category();

 IF g_version_category = VERSION_10L THEN 
   grant_table_access('lbacsys.lbac$polt');
   grant_table_access('odm.odm_mining_model');
   grant_table_access('olapsys.dba$olap_cubes');
 END IF;

 IF g_version_category = VERSION_817
 OR g_version_category = VERSION_9i
 OR g_version_category = VERSION_9iR2 THEN
   grant_table_access('all_sdo_geom_metadata');
   grant_table_access('lbacsys.lbac$polt');
   grant_table_access('olapsys.dba$olap_cubes');
   grant_table_access('odm.odm_mining_model');
   grant_table_access('sys.partobj$');
   grant_table_access('sys.ind$');
 END IF;

 IF g_version_category = VERSION_10gR1
 OR g_version_category = VERSION_10gR2 THEN
  grant_table_access('sys.v_$asm_client');
 END IF;

 IF g_version_category = VERSION_10gR1
 OR g_version_category = VERSION_10gR2
 OR g_version_category = VERSION_11gR1
 OR g_version_category = VERSION_11gR2
 OR g_version_category = VERSION_12gR0
 OR g_version_category = VERSION_12gR1
 OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
   grant_table_access('dba_high_water_mark_statistics');
   grant_table_access('sys.gv_$asm_disk');
   grant_table_access('dba_registry_history');
   grant_table_access('sys.smon_scn_time');
   grant_table_access('sys.v_$sysstat');
 END IF;

 IF g_version_category = VERSION_10gR2
 OR g_version_category = VERSION_11gR1
 OR g_version_category = VERSION_11gR2
 OR g_version_category = VERSION_12gR0
 OR g_version_category = VERSION_12gR1
 OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
   grant_table_access('dba_cpu_usage_statistics');
 END IF;

 IF g_version_category = VERSION_11gR1
 OR g_version_category = VERSION_11gR2
 OR g_version_category = VERSION_12gR0
 OR g_version_category = VERSION_12gR1
 OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
   grant_table_access('dba_autotask_client');
 END IF;

 IF g_version_category = VERSION_11gR2
 OR g_version_category = VERSION_12gR0
 OR g_version_category = VERSION_12gR1
 OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
   grant_table_access('sys.v_$cell_config');
 END IF;

 IF g_version_category = VERSION_12gR1
 OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
   BEGIN
   execute immediate 'SELECT UPPER(CDB) FROM V$DATABASE' into l_is_cdb;
   EXCEPTION
       WHEN OTHERS THEN null;
     END;
   IF l_is_cdb = 'YES' THEN
     grant_table_access('sys.cdb_data_files');
     grant_table_access('sys.cdb_properties');
     grant_table_access('sys.cdb_rollback_segs');
     grant_table_access('sys.cdb_services');
     grant_table_access('sys.cdb_tablespaces');
     grant_table_access('sys.cdb_temp_files');
     grant_table_access('sys.cdb_users');
     grant_table_access('sys.dba_pdbs');
     grant_table_access('sys.gv_$containers');
     grant_table_access('sys.gv_$pdbs');
     grant_table_access('sys.gv_$process');
     grant_table_access('sys.gv_$system_parameter');
   END IF;
 END IF;

 -- Version agnostic
 grant_table_access('change_tables');
 grant_table_access('content.odm_document');
 grant_table_access('content.odm_record');
 grant_table_access('database_properties');
 grant_table_access('dba_aws');
 grant_table_access('dba_feature_usage_statistics');
 grant_table_access('dba_free_space');
 grant_table_access('dba_indexes');
 grant_table_access('dba_jobs');
 grant_table_access('dba_tables');
 grant_table_access('dba_users');
 grant_table_access('DVSYS.DBA_DV_REALM');
 grant_table_access('global_name');
 grant_table_access('sys.cdc_change_tables$');
 grant_table_access('sys.dba_data_files');
 grant_table_access('sys.dba_objects');
 grant_table_access('sys.dba_registry');
 grant_table_access('sys.dba_rollback_segs');
 grant_table_access('sys.dba_scheduler_jobs');
 grant_table_access('sys.dba_tablespaces');
 grant_table_access('sys.dba_temp_files');
 grant_table_access('sys.obj$');
 grant_table_access('sys.ts$');
 grant_table_access('sys.user$');
 -- The following are public synonyms of views whose table is owned
 -- by sys user. Ex: v$database corresponds to sys.v_$database
 grant_table_access('sys.gv_$database');
 grant_table_access('sys.gv_$instance');
 grant_table_access('sys.gv_$nls_parameters');
 grant_table_access('sys.gv_$parameter');
 grant_table_access('sys.gv_$sga');
 grant_table_access('sys.gv_$sgastat');
 grant_table_access('sys.gv_$sort_segment');
 grant_table_access('sys.gv_$version');
 grant_table_access('sys.v_$controlfile');
 grant_table_access('sys.v_$database');
 grant_table_access('sys.v_$datafile');
 grant_table_access('sys.v_$instance');
 grant_table_access('sys.v_$license');
 grant_table_access('sys.v_$log');
 grant_table_access('sys.v_$logfile');
 grant_table_access('sys.v_$option');
 grant_table_access('sys.v_$parameter');
 grant_table_access('sys.v_$process');
 grant_table_access('sys.v_$rman_configuration');
 grant_table_access('sys.v_$rollstat');
 grant_table_access('sys.v_$session');
 grant_table_access('sys.v_$tempfile');
 grant_table_access('DBA_DB_LINKS');
 grant_table_access('dba_audit_trail');
 grant_table_access('DVSYS.DBA_DV_REALM');
 grant_table_access('content.odm_document');
 grant_table_access('content.odm_record');
 END;
/
