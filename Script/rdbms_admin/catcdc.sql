Rem
Rem $Header: rdbms/admin/catcdc.sql /main/25 2010/02/12 13:23:18 sramakri Exp $
Rem
Rem catcdc.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catcdc.sql - catalog views FOR change data capture
Rem
Rem    DESCRIPTION
Rem      defines publisher- AND susbscriber-side views FOR change data Capture
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    02/10/10 - bug-9281829
Rem    astoler     02/27/09 - Use Streams metadata tables for ALL_CHANGE_SETS
Rem    astoler     12/17/08 - bug 7609594, fix *_published_columns views
Rem    mbrey       11/09/07 - bug 6501817
Rem    mbrey       05/30/07 - bug 6083095 security, make user_xxx = all_xxx
Rem    mbrey       03/19/07 - bug 5397623 add source db to xxx_subscribed_col
Rem    mbrey       07/21/06 - bug 5404108 11gR1 dictionary changes 
Rem    mbrey       03/15/06 - bug 5092790 remove datapump registration code
Rem    pabingha    12/03/04 - BUG 4044823 - dba sub tab/col filtered by user 
Rem    pabingha    09/16/04 - add DistHot, AutoLog Online to change_sources 
Rem    twtong      04/16/04 - distribute hotlog change views 
Rem    mbrey       04/06/04 - 10gR2 source type changes 
Rem    pabingha    09/24/03 - no public select for dba views 
Rem    pabingha    06/26/03 - doc issues
Rem    pabingha    05/13/03 - add Data Pump inserts
Rem    pabingha    02/18/03 - doc updates
Rem    pabingha    01/03/03 - missing user_pub_cols columns
Rem    pabingha    09/20/02 - add 10iR1 columns
Rem    desinha     04/29/02 - #2303866: change user => userenv('SCHEMAID')
Rem    wnorcott    01/15/02 - user_source_tab_columns.
Rem    wnorcott    01/04/02 - bug-2170929 fix USER_SOURCE_TAB_COLUMNS view.
Rem    wnorcott    09/06/01 - bug 1973738.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    wnorcott    06/28/00 - rid logmnr_dict view
Rem    wnorcott    06/27/00 - Add view sys.logmnr_dict
Rem    aime        06/21/00 - resolve tkzdicz1.dif
Rem    wnorcott    06/08/00 - Change Data Capture catalog views
Rem    wnorcott    06/08/00 - Created
Rem

REM add source database to predefined change sources, grab from global_names
update sys.cdc_change_sources$ set source_database = 
 (select global_name from global_name) where 
 source_name IN ('HOTLOG_SOURCE','SYNC_SOURCE')
/

REM Views for Change Data Capture  
CREATE OR REPLACE VIEW all_change_sources 
  (source_name, dbid, log_directory, logfile_pattern, 
   source_description, created, source_type, 
   source_database, first_scn, publisher,
   capture_name, capture_queue_name,
   capture_queue_table_name, source_enabled)
  AS SELECT 
   s.source_name, s.dbid, s.logfile_location, s.logfile_suffix, 
   s.source_description, s.created, 
   decode(bitand(s.source_type, 206),
                         2, 'AUTOLOG',
                         4, 'HOTLOG',
                         8, 'SYNCHRONOUS',
                        68, 'DISTRIBUTED HOTLOG',
                       130, 'AUTOLOG ONLINE',
                            'UNKNOWN'),
   s.source_database, s.first_scn, s.publisher,
   s.capture_name, s.capqueue_name, s.capqueue_tabname, 
   s.source_enabled
  FROM sys.cdc_change_sources$ s
/
COMMENT ON TABLE all_change_sources IS
'Change Data Capture change sources'
/
COMMENT ON COLUMN all_change_sources.source_name IS
'Name of the change source'
/
COMMENT ON COLUMN all_change_sources.dbid IS
'Database identifier'
/
COMMENT ON COLUMN all_change_sources.log_directory IS
'Log file directory location'
/
COMMENT ON COLUMN all_change_sources.logfile_pattern IS
'File name wildcard pattern for log files'
/
COMMENT ON COLUMN all_change_sources.source_description IS
'Description of the change source'
/
COMMENT ON COLUMN all_change_sources.created IS
'Creation date of the change source'
/
COMMENT ON COLUMN all_change_sources.source_type IS
'Capture mode of the change source'
/
COMMENT ON COLUMN all_change_sources.source_database IS
'Global name of source database'
/
COMMENT ON COLUMN all_change_sources.first_scn IS
'SCN of a LogMiner dictionary at which capture can begin'
/
COMMENT ON COLUMN all_change_sources.publisher IS
'Publisher of the change source'
/
COMMENT ON COLUMN all_change_sources.capture_name IS
'Name of the Streams capture'
/
COMMENT ON COLUMN all_change_sources.capture_queue_name IS
'Name of the Streams capture queue name'
/
COMMENT ON COLUMN all_change_sources.capture_queue_table_name IS
'Name of the Streams capture table name'
/
COMMENT ON COLUMN all_change_sources.source_enabled IS
'Whether change source is enabled ?'
/

Rem we change name in 11gR1 to all_xxxx 
Rem have synonym for old name for backward compatibility
Rem should consider removing in 11gR2 timeframe
CREATE OR REPLACE public synonym all_change_sources for all_change_sources
/
CREATE OR REPLACE public synonym change_sources for all_change_sources
/
GRANT select on all_change_sources to select_catalog_role
/


CREATE OR REPLACE VIEW all_change_sets
  (set_name, change_source_name, begin_date, end_date, begin_scn, 
   end_scn, freshness_date, freshness_scn, advance_enabled, 
   ignore_ddl, created, rollback_segment_name, advancing, purging, 
   lowest_scn, tablespace, capture_enabled, stop_on_ddl, 
   capture_error, capture_name, queue_name, queue_table_name, 
   apply_name, set_description, publisher, lowest_timestamp, map_name)
  AS SELECT
   s.set_name, s.change_source_name, s.begin_date, s.end_date, s.begin_scn,
   s.end_scn, s.freshness_date, s.freshness_scn, 
   (case when (s.change_source_name = 'SYNC_SOURCE') then s.advance_enabled
         when (a.status = 2 and c.status = 2) then 'Y' 
         when a.status = 2 then 'C'
         else 'N' end) advance_enabled,
   s.ignore_ddl, s.created, s.rollback_segment_name, s.advancing, s.purging, 
   s.lowest_scn, s.tablespace, 
   (case when (s.change_source_name = 'SYNC_SOURCE') then s.capture_enabled 
         else decode(a.status, 2, 'Y', 'N') end) capture_enabled,
   s.stop_on_ddl, 
   (case when (s.change_source_name = 'SYNC_SOURCE') then s.capture_error
         when (a.status = 1 and e.error_number is not null) then 'Y'
         when (a.apply_name is null) then 'Y'
         else 'N' end) capture_error,
   s.capture_name, s.queue_name, s.queue_table_name, 
   s.apply_name, s.set_description, s.publisher, s.lowest_timestamp,
   s.time_scn_name
  FROM sys.cdc_change_sets$ s, 
       sys.streams$_apply_process a, sys.streams$_capture_process c,
       sys.apply$_error e
  WHERE s.apply_name = a.apply_name (+) 
  AND a.apply# = e.apply# (+)
  AND s.capture_name = c.capture_name (+)
/
COMMENT ON TABLE all_change_sets IS
'Change Data Capture change sets'
/
COMMENT ON COLUMN all_change_sets.set_name IS
'Name of the change set'
/
COMMENT ON COLUMN all_change_sets.change_source_name IS
'Change source to which the change set belongs'
/
COMMENT ON COLUMN all_change_sets.begin_date IS
'Starting point for capturing change data'
/
COMMENT ON COLUMN all_change_sets.end_date IS
'Stopping point for capturing change data'
/
COMMENT ON COLUMN all_change_sets.begin_scn IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.end_scn IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.freshness_date IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.freshness_scn IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.advance_enabled IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.ignore_ddl IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.created IS
'Creation date of the change set'
/
COMMENT ON COLUMN all_change_sets.rollback_segment_name IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.advancing IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.purging IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.lowest_scn IS
'Low water mark for change data in change set'
/
COMMENT ON COLUMN all_change_sets.tablespace IS
'Not used'
/
COMMENT ON COLUMN all_change_sets.capture_enabled IS
'Whether capture is enabled for change set'
/
COMMENT ON COLUMN all_change_sets.stop_on_ddl IS
'Whether change set stops on DDL'
/
COMMENT ON COLUMN all_change_sets.capture_error IS
'Whether there is a capture error'
/
COMMENT ON COLUMN all_change_sets.capture_name IS
'Name of Streams capture process'
/
COMMENT ON COLUMN all_change_sets.queue_name IS
'Name of Streams queue'
/
COMMENT ON COLUMN all_change_sets.queue_table_name IS
'Name of Streams queue table'
/
COMMENT ON COLUMN all_change_sets.apply_name IS
'Name of the Streams apply process'
/
COMMENT ON COLUMN all_change_sets.set_description IS
'Description of the change set'
/
COMMENT ON COLUMN all_change_sets.publisher IS
'Publisher of the change set'
/
COMMENT ON COLUMN all_change_sets.lowest_timestamp IS
'Timestamp of record with lowest scn in the change set'
/
COMMENT ON COLUMN all_change_sets.map_name IS
'Name of the mapping table, maps scn to timestamp'
/

Rem we change name in 11gR1 to all_xxxx 
Rem have synonym for old name for backward compatibility
Rem should consider removing in 11gR2 timeframe
CREATE OR REPLACE public synonym all_change_sets for all_change_sets
/
CREATE OR REPLACE public synonym change_sets for all_change_sets
/
GRANT select on all_change_sets to select_catalog_role
/

CREATE OR REPLACE VIEW all_change_tables
  (change_table_schema, change_table_name, change_set_name, 
   source_schema_name, source_table_name, created, created_scn, 
   captured_values, pub_id)
  AS SELECT
   s.change_table_schema, s.change_table_name, s.change_set_name, 
   s.source_schema_name, s.source_table_name, s.created, s.created_scn, 
   s.captured_values, s.obj#
  FROM sys.cdc_change_tables$ s
/
COMMENT ON TABLE all_change_tables IS
'Change Data Capture change tables'
/
COMMENT ON COLUMN all_change_tables.change_table_schema IS
'Owner of the change table'
/
COMMENT ON COLUMN all_change_tables.change_table_name IS
'Name of the change table'
/
COMMENT ON COLUMN all_change_tables.change_set_name IS
'Change set to which change table belongs'
/
COMMENT ON COLUMN all_change_tables.source_schema_name IS
'Owner of the source table for the change table'
/
COMMENT ON COLUMN all_change_tables.source_table_name IS
'Name of the source table for the change table'
/
COMMENT ON COLUMN all_change_tables.created IS
'Creation date of the change table'
/
COMMENT ON COLUMN all_change_tables.created_scn IS
'Creation SCN of the change table'
/
COMMENT ON COLUMN all_change_tables.captured_values IS
'Indicates whether OLD, NEW or BOTH update values are captured'
/
COMMENT ON COLUMN all_change_tables.pub_id IS
'Publication ID displayed to subscribers for the change table'
/

Rem we change name in 11gR1 to all_xxxx 
Rem have synonym for old name for backward compatibility
Rem should consider removing in 11gR2 timeframe
CREATE OR REPLACE public synonym all_change_tables for all_change_tables
/
CREATE OR REPLACE public synonym change_tables for all_change_tables
/
GRANT select on all_change_tables to select_catalog_role
/

CREATE OR REPLACE VIEW all_change_propagations
  (propagation_source_name, propagation_name, staging_database,
   destination_queue_publisher, destination_queue)
  AS SELECT
   p.sourceid_name, p.propagation_name, p.staging_database,
   p.destqueue_publisher, p.destqueue_name
  FROM sys.cdc_propagations$ p
/
COMMENT ON TABLE all_change_propagations IS
'Change Data Capture propagations '
/
COMMENT ON COLUMN all_change_propagations.propagation_source_name IS
'Name of the change source'
/
COMMENT ON COLUMN all_change_propagations.propagation_name IS
'Name of the propagation'
/
COMMENT ON COLUMN all_change_propagations.staging_database IS
'Name of the staging database for the propagation'
/
COMMENT ON COLUMN all_change_propagations.destination_queue_publisher IS
'Owner of the destination queue'
/
COMMENT ON COLUMN all_change_propagations.destination_queue IS
'Name of the destination queue'
/

Rem we change name in 11gR1 to all_xxxx 
Rem have synonym for old name for backward compatibility
Rem should consider removing in 11gR2 timeframe
CREATE OR REPLACE public synonym all_change_propagations for all_change_propagations 
/
CREATE OR REPLACE public synonym change_propagations for all_change_propagations 
/
GRANT select on all_change_propagations to select_catalog_role
/

CREATE OR REPLACE VIEW all_change_propagation_sets
  (propagation_source_name, propagation_name, staging_database,
   change_set_publisher, change_set_name)
  AS SELECT
   p.sourceid_name, p.propagation_name, p.staging_database,
   s.change_set_publisher, s.change_set_name
  FROM sys.cdc_propagations$ p, sys.cdc_propagated_sets$ s
  WHERE s.propagation_name = p.propagation_name
/
COMMENT ON TABLE all_change_propagation_sets IS
'Change Data Capture propagated change set'
/
COMMENT ON COLUMN all_change_propagation_sets.propagation_source_name IS
'Name of the change source'
/
COMMENT ON COLUMN all_change_propagation_sets.propagation_name IS
'Name of the propagation'
/
COMMENT ON COLUMN all_change_propagation_sets.staging_database IS
'Name of the staging database for the propagation'
/
COMMENT ON COLUMN all_change_propagation_sets.change_set_publisher IS
'Publisher of the distributed change set'
/
COMMENT ON COLUMN all_change_propagation_sets.change_set_name IS
'Name of the distributed change set'
/

Rem we change name in 11gR1 to all_xxxx 
Rem have synonym for old name for backward compatibility
Rem should consider removing in 11gR2 timeframe
CREATE OR REPLACE public synonym all_change_propagation_sets for all_change_propagation_sets
/
CREATE OR REPLACE public synonym change_propagation_sets for all_change_propagation_sets
/
GRANT select on all_change_propagation_sets to select_catalog_role
/
    
CREATE OR REPLACE VIEW dba_source_tables
  (source_schema_name, source_table_name)
  AS SELECT DISTINCT
   s.source_schema_name, s.source_table_name
  FROM sys.cdc_change_tables$ s, dba_tables t
  WHERE s.change_table_schema=t.owner AND
        s.change_table_name=t.table_name
/
COMMENT ON TABLE dba_source_tables IS
'Source tables available for Change Data Capture'
/
COMMENT ON COLUMN dba_source_tables.source_schema_name IS
'Schema of the source table'
/
COMMENT ON COLUMN dba_source_tables.source_table_name IS
'Name of the source table'
/
CREATE OR REPLACE public synonym dba_source_tables for dba_source_tables
/
GRANT select on dba_source_tables to select_catalog_role
/
    
Rem 11.1 making all_source_tables a synonym for user_source_tables        
CREATE OR REPLACE VIEW user_source_tables
  (source_schema_name, source_table_name)
  AS SELECT DISTINCT
   s.source_schema_name, s.source_table_name
  FROM sys.cdc_change_tables$ s, all_tables t, sys.user$ u
  WHERE s.change_table_schema=t.owner AND
        s.change_table_name=t.table_name AND
        s.change_table_schema = u.name AND
        u.user# = userenv('SCHEMAID');
/
COMMENT ON TABLE user_source_tables IS
'Source tables available for Change Data Capture'
/
COMMENT ON COLUMN user_source_tables.source_schema_name IS
'Schema of the source table'
/
COMMENT ON COLUMN user_source_tables.source_table_name IS
'Name of the source table'
/
CREATE OR REPLACE public synonym user_source_tables for user_source_tables
/
GRANT select on user_source_tables to public
/
CREATE OR REPLACE public synonym all_source_tables for user_source_tables
/
GRANT select on all_source_tables to public
/


CREATE OR REPLACE VIEW dba_published_columns
  (change_set_name, change_table_schema, change_table_name, pub_id, 
   source_schema_name, source_table_name, column_name,
   data_type, data_length, data_precision, data_scale, nullable)
  AS SELECT
   s.change_set_name, s.change_table_schema, s.change_table_name, s.obj#,
   s.source_schema_name, s.source_table_name, c.column_name,
   c.data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
  FROM sys.cdc_change_tables$ s, dba_tables t, dba_tab_columns c
  WHERE s.change_table_schema=t.owner AND
        s.change_table_name=t.table_name AND
        c.owner=s.change_table_schema AND
        c.table_name=s.change_table_name AND
        c.column_name NOT IN ('OPERATION$','CSCN$','DDLDESC$','DDLPDOBJN$',
           'DDLOPER$','RSID$','SOURCE_COLMAP$','TARGET_COLMAP$',
           'COMMIT_TIMESTAMP$','TIMESTAMP$','USERNAME$','ROW_ID$',
           'XIDUSN$','XIDSLT$','XIDSEQ$','SYS_NC_OID$')
/
COMMENT ON TABLE dba_published_columns IS
'Source columns available for Change Data Capture'
/
COMMENT ON COLUMN dba_published_columns.change_set_name IS
'Change set in which source column is published'
/
COMMENT ON COLUMN dba_published_columns.change_table_schema IS
'Change table schema in which source column is published'
/
COMMENT ON COLUMN dba_published_columns.change_table_name IS
'Change table name in which source column is published'
/
COMMENT ON COLUMN dba_published_columns.pub_id IS
'Publication ID in which source column is published'
/
COMMENT ON COLUMN dba_published_columns.source_schema_name IS
'Source schema name of published column'
/
COMMENT ON COLUMN dba_published_columns.source_table_name IS
'Source table name of published column'
/
COMMENT ON COLUMN dba_published_columns.column_name IS
'Column name of published column'
/
COMMENT ON COLUMN dba_published_columns.data_type IS
'Column datatype'
/
COMMENT ON COLUMN dba_published_columns.data_length IS
'Column length'
/
COMMENT ON COLUMN dba_published_columns.data_precision IS
'Column precision'
/
COMMENT ON COLUMN dba_published_columns.data_scale IS
'Column scale'
/
COMMENT ON COLUMN dba_published_columns.nullable IS
'Whether column is nullable'
/
CREATE OR REPLACE public synonym dba_published_columns
   for dba_published_columns
/
GRANT select on dba_published_columns to select_catalog_role
/

Rem 11.1 make all_published_columns a synonym fro user_published_columns
CREATE OR REPLACE VIEW user_published_columns
  (change_set_name, pub_id, source_schema_name, source_table_name, 
   column_name, data_type, data_length, data_precision, data_scale, 
   nullable)
  AS SELECT
   s.change_set_name, s.obj#, s.source_schema_name, s.source_table_name, 
   c.column_name, c.data_type, c.data_length, c.data_precision, c.data_scale, 
   c.nullable
  FROM sys.cdc_change_tables$ s, all_tables t, all_tab_columns c, sys.user$ u
  WHERE s.change_table_schema=t.owner AND
        s.change_table_name=t.table_name AND
        c.owner=s.change_table_schema AND
        c.table_name=s.change_table_name AND
        c.column_name NOT IN ('OPERATION$','CSCN$','DDLDESC$','DDLPDOBJN$',
           'DDLOPER$','RSID$','SOURCE_COLMAP$','TARGET_COLMAP$',
           'COMMIT_TIMESTAMP$','TIMESTAMP$','USERNAME$','ROW_ID$',
           'XIDUSN$','XIDSLT$','XIDSEQ$','SYS_NC_OID$') AND
        s.change_table_schema = u.name AND
        u.user# = userenv('SCHEMAID');
/
COMMENT ON TABLE user_published_columns IS
'Source columns available for Change Data Capture'
/
COMMENT ON COLUMN user_published_columns.change_set_name IS
'Change set in which source column is published'
/
COMMENT ON COLUMN user_published_columns.pub_id IS
'Publication ID in which source column is published'
/
COMMENT ON COLUMN user_published_columns.source_schema_name IS
'Source schema name of published column'
/
COMMENT ON COLUMN user_published_columns.source_table_name IS
'Source table name of published column'
/
COMMENT ON COLUMN user_published_columns.column_name IS
'Column name of published column'
/
COMMENT ON COLUMN user_published_columns.data_type IS
'Column datatype'
/
COMMENT ON COLUMN user_published_columns.data_length IS
'Column length'
/
COMMENT ON COLUMN user_published_columns.data_precision IS
'Column precision'
/
COMMENT ON COLUMN user_published_columns.data_scale IS
'Column scale'
/
COMMENT ON COLUMN user_published_columns.nullable IS
'Whether column is nullable'
/
CREATE OR REPLACE public synonym user_published_columns
   for user_published_columns
/
GRANT select on user_published_columns to public
/
CREATE OR REPLACE public synonym all_published_columns
   for user_published_columns
/
GRANT select on all_published_columns to public
/
    
    
Rem Subscriptions are not first-class objects, so there is no
Rem difference between subscriptions that are "accessible" to user
Rem subscriptions that user owns. Constrain "all" view to user's
Rem subscriptions only.    
 
CREATE OR REPLACE VIEW dba_subscriptions
  (handle, set_name, username, created, status, earliest_scn, 
   latest_scn, description, last_purged, last_extended, 
   subscription_name)
  AS SELECT 
   s.handle, s.set_name, s.username, s.created, s.status, s.earliest_scn,
   s.latest_scn, s.description, s.last_purged, s.last_extended,
   s.subscription_name
  FROM sys.cdc_subscribers$ s
/
COMMENT ON TABLE dba_subscriptions IS
'Change Data Capture subscriptions'
/
COMMENT ON COLUMN dba_subscriptions.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN dba_subscriptions.set_name IS
'Change set for the subscription'
/
COMMENT ON COLUMN dba_subscriptions.username IS
'User name of the subscriber'
/
COMMENT ON COLUMN dba_subscriptions.created IS
'Creation date of the subscription'
/
COMMENT ON COLUMN dba_subscriptions.status IS
'Status of the subscriptions (N not activated, A activated)'
/
COMMENT ON COLUMN dba_subscriptions.earliest_scn IS
'Subscription window low boundary'
/
COMMENT ON COLUMN dba_subscriptions.latest_scn IS
'Subscription window high boundary'
/
COMMENT ON COLUMN dba_subscriptions.description IS
'Description of the subscription'
/
COMMENT ON COLUMN dba_subscriptions.last_purged IS
'Last time subscriber called purge_window'
/
COMMENT ON COLUMN dba_subscriptions.last_extended IS
'Last time subscriber called extend_window'
/
COMMENT ON COLUMN dba_subscriptions.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym dba_subscriptions for dba_subscriptions
/
GRANT select on dba_subscriptions to select_catalog_role
/

Rem 11.1 make all_subscriptions a synonym for user_subscriptions      
CREATE OR REPLACE VIEW user_subscriptions
  (handle, set_name, username, created, status, earliest_scn, 
   latest_scn, description, last_purged, last_extended, subscription_name)
  AS SELECT 
   s.handle, s.set_name, s.username, s.created, s.status, s.earliest_scn,
   s.latest_scn, s.description, s.last_purged, s.last_extended,
   s.subscription_name
  FROM sys.cdc_subscribers$ s, sys.user$ u
  WHERE s.username= u.name AND
        u.user#   = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_subscriptions IS
'Change Data Capture subscriptions'
/
COMMENT ON COLUMN user_subscriptions.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN user_subscriptions.set_name IS
'Change set for the subscription'
/
COMMENT ON COLUMN user_subscriptions.username IS
'User name of the subscriber'
/
COMMENT ON COLUMN user_subscriptions.created IS
'Creation date of the subscription'
/
COMMENT ON COLUMN user_subscriptions.status IS
'Status of the subscriptions (N not activated, A activated)'
/
COMMENT ON COLUMN user_subscriptions.earliest_scn IS
'Subscription window low boundary'
/
COMMENT ON COLUMN user_subscriptions.latest_scn IS
'Subscription window high boundary'
/
COMMENT ON COLUMN user_subscriptions.description IS
'Description of the subscription'
/
COMMENT ON COLUMN user_subscriptions.last_purged IS
'Last time subscriber called purge_window'
/
COMMENT ON COLUMN user_subscriptions.last_extended IS
'Last time subscriber called extend_window'
/
COMMENT ON COLUMN user_subscriptions.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym user_subscriptions for user_subscriptions
/
GRANT select on user_subscriptions to public
/
CREATE OR REPLACE public synonym all_subscriptions for user_subscriptions
/
GRANT select on all_subscriptions to public
/

      
Rem Subscriptions are not first-class objects, so there is no
Rem difference between subscriptions that are "accessible" to user
Rem subscriptions that user owns. Constrain "all" view to user's
Rem subscriptions only.    

CREATE OR REPLACE VIEW dba_subscribed_tables
  (handle, source_schema_name, source_table_name, view_name,
   change_set_name, subscription_name)
  AS SELECT
   st.handle, t.source_schema_name, t.source_table_name, st.view_name, 
   t.change_set_name, s.subscription_name
  FROM sys.cdc_subscribed_tables$ st, sys.cdc_change_tables$ t,
       sys.cdc_subscribers$ s
  WHERE st.change_table_obj#=t.obj# AND 
        s.handle = st.handle
/
COMMENT ON TABLE dba_subscribed_tables IS
'Change Data Capture subscribed tables'
/
COMMENT ON COLUMN dba_subscribed_tables.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN dba_subscribed_tables.source_schema_name IS
'Source schema name of the subscribed table'
/
COMMENT ON COLUMN dba_subscribed_tables.source_table_name IS
'Source table name of the subscribed table'
/
COMMENT ON COLUMN dba_subscribed_tables.view_name IS
'Subscriber view name for the subscribed table'
/
COMMENT ON COLUMN dba_subscribed_tables.change_set_name IS
'Change set name for the subscribed table'
/
COMMENT ON COLUMN dba_subscribed_tables.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym dba_subscribed_tables
   for dba_subscribed_tables
/
GRANT select on dba_subscribed_tables to select_catalog_role
/

Rem 11.1 make all_subscribed_tables a synonym for user_subscribed_tables
CREATE OR REPLACE VIEW user_subscribed_tables
  (handle, source_schema_name, source_table_name, view_name,
   change_set_name, subscription_name)
  AS SELECT
   s.handle, t.source_schema_name, t.source_table_name, s.view_name,
   t.change_set_name, u.subscription_name
  FROM sys.cdc_subscribed_tables$ s, sys.cdc_change_tables$ t,
       sys.cdc_subscribers$ u, sys.user$ su
  WHERE s.change_table_obj#=t.obj# AND
        s.handle=u.handle AND
        u.username= su.name AND
        su.user#= USERENV('SCHEMAID')
/
COMMENT ON TABLE user_subscribed_tables IS
'Change Data Capture subscribed tables'
/
COMMENT ON COLUMN user_subscribed_tables.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN user_subscribed_tables.source_schema_name IS
'Source schema name of the subscribed table'
/
COMMENT ON COLUMN user_subscribed_tables.source_table_name IS
'Source table name of the subscribed table'
/
COMMENT ON COLUMN user_subscribed_tables.view_name IS
'Subscriber view name for the subscribed table'
/
COMMENT ON COLUMN user_subscribed_tables.change_set_name IS
'Change set name for the subscribed table'
/
COMMENT ON COLUMN user_subscribed_tables.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym user_subscribed_tables
   for user_subscribed_tables
/
GRANT select on user_subscribed_tables to public
/
CREATE OR REPLACE public synonym all_subscribed_tables
   for user_subscribed_tables
/
GRANT select on all_subscribed_tables to public
/


Rem Subscriptions are not first-class objects, so there is no
Rem difference between subscriptions that are "accessible" to user
Rem subscriptions that user owns. Constrain "all" view to user's
Rem subscriptions only.    

CREATE OR REPLACE VIEW dba_subscribed_columns
  (handle, source_schema_name, source_table_name, column_name,
   subscription_name, source_db)
  AS SELECT
   sc.handle, t.source_schema_name, t.source_table_name, sc.column_name, 
   s.subscription_name, y.source_database
  FROM sys.cdc_subscribed_columns$ sc, sys.cdc_change_tables$ t,
       sys.cdc_subscribers$ s, sys.cdc_change_sets$ x,
       sys.cdc_change_sources$ y
  WHERE sc.change_table_obj#=t.obj# AND 
        s.handle = sc.handle AND
        t.change_set_name=x.set_name AND
        x.change_source_name = y.source_name
/
COMMENT ON TABLE dba_subscribed_columns IS
'Change Data Capture subscribed columns'
/
COMMENT ON COLUMN dba_subscribed_columns.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN dba_subscribed_columns.source_schema_name IS
'Source schema name of the subscribed column'
/
COMMENT ON COLUMN dba_subscribed_columns.source_table_name IS
'Source table name of the subscribed column'
/
COMMENT ON COLUMN dba_subscribed_columns.column_name IS
'Name of the subscribed column'
/
COMMENT ON COLUMN dba_subscribed_columns.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym dba_subscribed_columns
   for dba_subscribed_columns
/
GRANT select on dba_subscribed_columns to select_catalog_role
/
    
Rem make all_subscribed_columns a synonym for user_subscribed_columns
CREATE OR REPLACE VIEW user_subscribed_columns
  (handle, source_schema_name, source_table_name, column_name,
   subscription_name, source_db)
  AS SELECT
   s.handle, t.source_schema_name, t.source_table_name, s.column_name, 
   u.subscription_name, z.source_database
  FROM sys.cdc_subscribed_columns$ s, sys.cdc_change_tables$ t,
       sys.cdc_subscribers$ u, sys.user$ su, sys.cdc_change_sets$ x,
       sys.cdc_change_sources$ z
  WHERE s.change_table_obj#=t.obj# AND
        s.handle=u.handle AND
        u.username = su.name AND
        su.user#   = userenv('SCHEMAID') AND
        t.change_set_name=x.set_name AND
        x.change_source_name = z.source_name
/
COMMENT ON TABLE user_subscribed_columns IS
'Change Data Capture subscribed columns'
/
COMMENT ON COLUMN user_subscribed_columns.handle IS
'Unique identifier of the subscription'
/
COMMENT ON COLUMN user_subscribed_columns.source_schema_name IS
'Source schema name of the subscribed column'
/
COMMENT ON COLUMN user_subscribed_columns.source_table_name IS
'Source table name of the subscribed column'
/
COMMENT ON COLUMN user_subscribed_columns.column_name IS
'Name of the subscribed column'
/
COMMENT ON COLUMN user_subscribed_columns.subscription_name IS
'Name of the subscription'
/
CREATE OR REPLACE public synonym user_subscribed_columns
   for user_subscribed_columns
/
GRANT select on user_subscribed_columns to public
/
CREATE OR REPLACE public synonym all_subscribed_columns
   for user_subscribed_columns
/
GRANT select on all_subscribed_columns to public
/
