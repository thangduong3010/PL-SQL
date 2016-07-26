Rem
Rem $Header: rdbms/admin/cattsm.sql /main/6 2008/09/17 21:56:20 shiyer Exp $
Rem
Rem cattsm.sql
Rem
Rem Copyright (c) 2003, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cattsm.sql - Transparent Session Migration Catalog creation
Rem
Rem    DESCRIPTION
Rem      This file defines the catalog views related to
Rem      transparent session migration
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shiyer      06/24/08 - #6854917:do not create TSMSYS schema
Rem    lburgess    03/27/06 - use lowercase for TSMSYS password 
Rem    mbastawa    10/27/04 - add TSMSYS schema
Rem    skaluska    07/09/04 - define dba_tsm_source, dba_tsm_destination 
Rem    skaluska    03/30/04 - instance SID in tsm_hist$ 
Rem    skaluska    03/17/04 - recovery 
Rem    skaluska    03/05/04 - add roundtrips 
Rem    skaluska    07/31/03 - new failure reason 
Rem    skaluska    06/26/03 - prepare from client failed
Rem    sgollapu    05/31/03 - Add new faikure reasons
Rem    sgollapu    05/12/03 - sgollapu_tsm_stateless
Rem    sgollapu    05/07/03 - grant execute on types to PUBLIC
Rem    skaluska    05/01/03 - add types
Rem    skaluska    04/15/03 - Created
Rem



-----------------------------------------------
-- End of invoking component specific scripts
-----------------------------------------------

-- Create type tsm$session_id to describe a session
CREATE OR REPLACE TYPE sys.tsm$session_id
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020200'
AS OBJECT
(
  sid          number,
  serial#      number
)
/
show errors;
/

-- Create type tsm$session_id_list as a varray of tsm$session_id
CREATE OR REPLACE TYPE sys.tsm$session_id_list 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020201'
AS VARRAY(4096) of sys.tsm$session_id
/
show errors;
/

grant execute on sys.tsm$session_id to PUBLIC
/

grant execute on sys.tsm$session_id_list to PUBLIC
/

-- Create migration history view for source sessions
CREATE OR REPLACE VIEW DBA_TSM_SOURCE
(
  SOURCE_DATABASE_NAME,
  SOURCE_INSTANCE_NAME,
  SOURCE_INSTANCE_ID,
  SOURCE_INSTANCE_START_TIME,
  SEQUENCE#,
  SOURCE_SID,
  SOURCE_SERIAL#,
  SOURCE_STATE,
  CONNECT_STRING,
  SOURCE_START_TIME,
  COST,
  FAILURE_REASON,
  SOURCE_END_TIME,
  ROUNDTRIPS,
  SOURCE_USER_NAME,
  SOURCE_SCHEMA_NAME,
  DESTINATION_DATABASE_NAME
)
AS SELECT
  src_db_name,
  src_inst_name,
  src_inst_id,
  src_inst_start_time,
  sequence#,
  src_sid,
  src_serial#,
  decode(src_state,
          0,  'NONE',
          1,  'SELECTED',
          2,  'COMMITED SELECT',
          3,  'READY FOR PREPARE',
          4,  'PREPARED',
          5,  'READY FOR SWITCH',
          6,  'SWITCHED',
          7,  'FAILED',
          8,  'READY FOR STATE TRANSFER',
          9,  'IN STATE TRANSFER',
          10, 'END OF STATE TRANSFER',
          'UNKNOWN'),
  connect_string,
  src_start_time,
  cost,
  decode(failure_reason,
          0, 'None',
          1, 'Instance shutdown before migration',
          2, 'End of session before migration',
          3, 'Invalid OCI operation',
          4, 'OCI Server Attach',
          5, 'OCI logon',
          6, 'OCI logoff',
          7, 'OCI disconnect',
          8, 'Invalid client state',
          9, 'End of migration',
         10, 'Session migration',
         11, 'Prepare from client failed',
         12, 'Session became non-migratable',
          NULL, '',
          'Unknown'),
  src_end_time,
  roundtrips,
  u1.name,
  u2.name,
  dst_db_name
FROM tsm_src$, user$ u1, user$ u2
WHERE
     (src_userid   = u1.user#)
 AND (src_schemaid = u2.user#)
/
COMMENT ON TABLE DBA_TSM_SOURCE IS
'Transparent session migration source session statistics'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_DATABASE_NAME IS
'Database name of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_INSTANCE_NAME IS
'Instance name of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_INSTANCE_ID IS
'Instance id of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_INSTANCE_START_TIME IS
'Instance start time of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SEQUENCE# IS
'Migration sequence number'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_SID IS
'Session id of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_SERIAL# IS
'Session serial# of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_STATE IS
'Migration state of source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.CONNECT_STRING IS
'Connect string specified for migration'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_START_TIME IS
'Start time for migration on source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.COST IS
'Estimate migration cost'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.FAILURE_REASON IS
'Failure reason for migration if any'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_END_TIME IS
'End time for migration on source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.ROUNDTRIPS IS
'Number of client-server round-trips during migration'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_USER_NAME IS
'User associated with the source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.SOURCE_SCHEMA_NAME IS
'Schema associated with the source session'
/
COMMENT ON COLUMN DBA_TSM_SOURCE.DESTINATION_DATABASE_NAME IS
'Database name of destination session'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_tsm_source FOR dba_tsm_source
/
GRANT SELECT ON dba_tsm_source TO select_catalog_role
/

-- Create migration history view for destination sessions
CREATE OR REPLACE VIEW DBA_TSM_DESTINATION
(
  SOURCE_DATABASE_NAME,
  DESTINATION_DATABASE_NAME,
  DESTINATION_INSTANCE_NAME,
  DESTINATION_INSTANCE_ID,
  DESTINATION_INST_START_TIME,
  SEQUENCE#,
  DESTINATION_SID,
  DESTINATION_SERIAL#,
  DESTINATION_START_TIME,
  DESTINATION_END_TIME,
  DESTINATION_USER_NAME,
  DESTINATION_SCHEMA_NAME,
  DESTINATION_STATE
)
AS SELECT
  src_db_name,
  dst_db_name,
  dst_inst_name,
  dst_inst_id,
  dst_inst_start_time,
  sequence#,
  dst_sid,
  dst_serial#,
  dst_start_time,
  dst_end_time,
  u1.name,
  u2.name,
  decode(dst_state,
          0,  'NONE',
          1,  'SELECTED',
          2,  'COMMITED SELECT',
          3,  'READY FOR PREPARE',
          4,  'PREPARED',
          5,  'READY FOR SWITCH',
          6,  'SWITCHED',
          7,  'FAILED',
          8,  'READY FOR STATE TRANSFER',
          9,  'IN STATE TRANSFER',
          10, 'END OF STATE TRANSFER',
          'UNKNOWN')
FROM tsm_dst$, user$ u1, user$ u2
WHERE
     (dst_userid   = u1.user#)
 AND (dst_schemaid = u2.user#)
/
COMMENT ON TABLE DBA_TSM_DESTINATION IS
'Transparent session migration source session statistics'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.SOURCE_DATABASE_NAME IS
'Database name of source session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_DATABASE_NAME IS
'Database name of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_INSTANCE_NAME IS
'Instance name of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_INSTANCE_ID IS
'Instance id of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_INST_START_TIME IS
'Instance start time of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.SEQUENCE# IS
'Migration sequence number'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_SID IS
'Session id of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_SERIAL# IS
'Session serial# of destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_START_TIME IS
'Start time for migration on destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_END_TIME IS
'End time for migration on destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_USER_NAME IS
'User associated with the destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_SCHEMA_NAME IS
'Schema associated with the destination session'
/
COMMENT ON COLUMN DBA_TSM_DESTINATION.DESTINATION_STATE IS
'Migration state of destination session'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_tsm_destination FOR dba_tsm_destination
/
GRANT SELECT ON dba_tsm_destination TO select_catalog_role
/

-- Create migration history view
CREATE OR REPLACE VIEW DBA_TSM_HISTORY
(
  SEQUENCE#,
  SOURCE_SID,
  SOURCE_SERIAL#,
  USER_NAME,
  SCHEMA_NAME,
  STATE,
  COST,
  SOURCE,
  SOURCE_INSTANCE_ID,
  SOURCE_START_TIME,
  CONNECT_STRING,
  FAILURE_REASON,
  DESTINATION_SID,
  DESTINATION_SERIAL#,
  DESTINATION_STATE,
  DESTINATION,
  DESTINATION_INSTANCE_ID,
  DESTINATION_START_TIME,
  ROUNDTRIPS,
  START_TIME,
  END_TIME
)
AS
  SELECT
  s.sequence#,
  s.source_sid,
  s.source_serial#,
  s.source_user_name,
  s.source_schema_name,
  s.source_state,
  s.cost,
  s.source_instance_name,
  s.source_instance_id,
  s.source_instance_start_time,
  s.connect_string,
  s.failure_reason,
  d.destination_sid,
  d.destination_serial#,
  d.destination_state,
  d.destination_instance_name,
  d.destination_instance_id,
  d.destination_inst_start_time,
  s.roundtrips,
  s.source_start_time,
  s.source_end_time
FROM DBA_TSM_SOURCE s, DBA_TSM_DESTINATION d
WHERE
  s.sequence# = d.sequence# (+)
/
COMMENT ON TABLE dba_tsm_history IS
'Transparent session migration statistics'
/
COMMENT ON COLUMN dba_tsm_history.sequence# IS
'Migration sequence number'
/
COMMENT ON COLUMN dba_tsm_history.source_sid IS
'Session id of the source session'
/
COMMENT ON COLUMN dba_tsm_history.source_serial# IS
'Serial# of the source session'
/
COMMENT ON COLUMN dba_tsm_history.user_name IS
'User name associated with the session'
/
COMMENT ON COLUMN dba_tsm_history.schema_name IS
'Schema name associated with the session'
/
COMMENT ON COLUMN dba_tsm_history.state IS
'Source session migration state'
/
COMMENT ON COLUMN dba_tsm_history.cost IS
'Estimated cost for migration'
/
COMMENT ON COLUMN dba_tsm_history.source IS
'Instance name from which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.source_instance_id IS
'Instance id from which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.source_start_time IS
'Instance start time from which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.connect_string IS
'Connect string for destination'
/
COMMENT ON COLUMN dba_tsm_history.failure_reason IS
'Additional information for migration failure'
/
COMMENT ON COLUMN dba_tsm_history.destination_sid IS
'Session id of the destination session'
/
COMMENT ON COLUMN dba_tsm_history.destination_serial# IS
'Serial# of the destination session'
/
COMMENT ON COLUMN dba_tsm_history.destination_state IS
'Destination session migration state'
/
COMMENT ON COLUMN dba_tsm_history.destination IS
'Instance name to which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.destination_instance_id IS
'Instance id to which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.destination_start_time IS
'Instance start time to which session was migrated'
/
COMMENT ON COLUMN dba_tsm_history.roundtrips IS
'Number of roundtrips during migration'
/
COMMENT ON COLUMN dba_tsm_history.start_time IS
'Time when migration was started'
/
COMMENT ON COLUMN dba_tsm_history.end_time IS
'Time when migration finished'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_tsm_history FOR dba_tsm_history
/
GRANT SELECT ON dba_tsm_history TO select_catalog_role
/
