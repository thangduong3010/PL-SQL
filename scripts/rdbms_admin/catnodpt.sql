Rem
Rem $Header: rdbms/admin/catnodpt.sql /st_rdbms_11.2.0/1 2013/01/22 12:32:58 lbarton Exp $
Rem
Rem catnodpt.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnodpt.sql - Drop types used by the DataPump
Rem
Rem    DESCRIPTION
Rem     One component of catnodp.sql. Types must be dropped upon install
Rem     because CREATE OR REPLACE TYPE doesnt work. This file is invoked from
Rem     both catdp.sql and catnodp.sql 
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     01/16/13 - Backport lbarton_bug-10186633 from
Rem    mjangir     04/14/10 - bug 9464968: add drop of type kupc$_LobPieces
Rem    sdipirro    01/15/08 - New status types for 11.2
Rem    rburns      08/13/06 - move queue and table drops
Rem    jkaloger    05/31/06 - PROJECT:15995_3
Rem    wfisher     05/05/06 - Drop data_remap too 
Rem    sdipirro    04/16/04 - New dumpfile info type and synonym 
Rem    sdipirro    03/02/04 - New status types and synonyms to drop 
Rem    dgagne      02/04/04 - add drop of type kupc post_mt_init 
Rem    sdipirro    08/11/03 - Versioning for public types
Rem    jkaloger    05/09/03 - Drop file-list objects & messages
Rem    gclaborn    03/11/03 - Remove kupc$q_message
Rem    lbarton     02/21/03 - bugfix
Rem    gclaborn    12/12/02 - Drop new tables
Rem    sdipirro    11/21/02 - Remove obsolete emulation types
Rem    wfisher     10/16/02 - Drop new release_file type
Rem    sdipirro    06/21/02 - New/renamed drops for types in prvtkupc
Rem    gclaborn    05/24/02 - Drop queue table and kupc$q_message
Rem    sdipirro    04/18/02 - Add dbmsdp and kupcc type drops
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/10/02 - Created
Rem

---------------------------------------------
---     Drop Metadata API types.
---------------------------------------------
@@catnomtt.sql

----------------------------------------------
---     Drop other DataPump types
----------------------------------------------

-- DataPump message object types

DROP TYPE kupc$_LobPieces FORCE;
DROP TYPE kupc$_add_device FORCE;
DROP TYPE kupc$_add_file FORCE;
DROP TYPE kupc$_data_filter FORCE;
DROP TYPE kupc$_data_remap FORCE;
DROP TYPE kupc$_log_entry FORCE;
DROP TYPE kupc$_log_error FORCE;
DROP TYPE kupc$_metadata_filter FORCE;
DROP TYPE kupc$_metadata_transform FORCE;
DROP TYPE kupc$_metadata_remap FORCE;
DROP TYPE kupc$_open FORCE;
DROP TYPE kupc$_restart FORCE;
DROP TYPE kupc$_set_parallel FORCE;
DROP TYPE kupc$_set_parameter FORCE;
DROP TYPE kupc$_start_job FORCE;
DROP TYPE kupc$_stop_job FORCE;
DROP TYPE kupc$_worker_exit FORCE;
DROP TYPE kupc$_workererror FORCE;
DROP TYPE kupc$_worker_log_entry FORCE;
DROP TYPE kupc$_table_data_array FORCE;
DROP TYPE kupc$_table_datas FORCE;
DROP TYPE kupc$_table_data FORCE;
DROP TYPE kupc$_bad_file FORCE;
DROP TYPE kupc$_device_ident FORCE;
DROP TYPE kupc$_worker_file FORCE;
DROP TYPE kupc$_get_work FORCE;
DROP TYPE kupc$_masterjobinfo FORCE;
DROP TYPE kupc$_mastererror FORCE;
DROP TYPE kupc$_post_mt_init FORCE;
DROP TYPE kupc$_api_ack FORCE;
DROP TYPE kupc$_exit FORCE;
DROP TYPE kupc$_sql_file_job FORCE;
DROP TYPE kupc$_estimate_job FORCE;
DROP TYPE kupc$_load_data FORCE;
DROP TYPE kupc$_load_metadata FORCE;
DROP TYPE kupc$_unload_data FORCE;
DROP TYPE kupc$_unload_metadata FORCE;
DROP TYPE kupc$_release_files FORCE;
DROP TYPE kupc$_sequential_file FORCE;
DROP TYPE kupc$_disk_file FORCE;
DROP TYPE kupc$_worker_file_list FORCE;
DROP TYPE kupc$_file_list FORCE;
DROP TYPE kupc$_worker_get_pwd FORCE;
DROP TYPE kupc$_encrypted_pwd FORCE;
DROP TYPE kupc$_worker_msg FORCE;
DROP TYPE kupc$_shadow_msg FORCE;
DROP TYPE kupc$_master_msg FORCE;
DROP TYPE kupc$_message FORCE;
DROP TYPE kupc$_fixup_virtual_column FORCE;

-- Types used by the DataPump message types

DROP TYPE kupc$_JobInfo FORCE;
DROP TYPE kupc$_LogEntries FORCE;
-- The following two types are only used internally by the File Manager.
DROP TYPE kupc$_FileList FORCE;
DROP TYPE kupc$_FileInfo FORCE;

-- Object types for the DBMS_DATAPUMP.GET_STATUS interface

DROP TYPE sys.ku$_Status1120 FORCE;
DROP TYPE sys.ku$_Status1020 FORCE;
DROP TYPE sys.ku$_Status1010 FORCE;
DROP TYPE sys.ku$_JobDesc1020 FORCE;
DROP TYPE sys.ku$_JobDesc1010 FORCE;
DROP TYPE sys.ku$_DumpFileSet1010 FORCE;
DROP TYPE sys.ku$_DumpFile1010 FORCE;
DROP TYPE sys.ku$_ParamValues1010 FORCE;
DROP TYPE sys.ku$_ParamValue1010 FORCE;
DROP TYPE sys.ku$_JobStatus1120 FORCE;
DROP TYPE sys.ku$_JobStatus1020 FORCE;
DROP TYPE sys.ku$_JobStatus1010 FORCE;
DROP TYPE sys.ku$_LogEntry1010 FORCE;
DROP TYPE sys.ku$_LogLine1010 FORCE;
DROP TYPE sys.ku$_WorkerStatusList1120 FORCE;
DROP TYPE sys.ku$_WorkerStatusList1020 FORCE;
DROP TYPE sys.ku$_WorkerStatusList1010 FORCE;
DROP TYPE sys.ku$_WorkerStatus1120 FORCE;
DROP TYPE sys.ku$_WorkerStatus1020 FORCE;
DROP TYPE sys.ku$_WorkerStatus1010 FORCE;

DROP TYPE sys.ku$_dumpfile_info FORCE;
DROP TYPE sys.ku$_dumpfile_item FORCE;

-- Object types for master table creation

DROP TYPE kupc$_mt_col_info_list FORCE;
DROP TYPE kupc$_mt_col_info FORCE;

-- Object type used for parameter conflict detection

DROP TYPE kupc$_par_con FORCE;
