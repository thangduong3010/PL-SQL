Rem
Rem $Header: rdbms/admin/catkppls.sql /main/5 2009/04/09 21:42:12 ssahu Exp $
Rem
Rem catkppls.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catkppls.sql - Kernel Programmatic Pool Catalog creation
Rem
Rem    DESCRIPTION
Rem      This file defines the catalog views related to the 
Rem      connection pool on the server side.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssahu       04/07/09  - num_cbrok and max_conn_cbrok to dba_cpool_info
Rem    kamsubra    02/09/07  - add 2 new columns to the table, view
Rem    kamsubra    10/03/06  - bug-5552291 change column name
Rem    kamsubra    06/06/06 -  Updating the default pool values.
Rem    srseshad    06/04/06 - 
Rem    kamsubra    05/19/06 - Created
Rem

-- Create connection pool table
create table cpool$
(
  connection_pool_name      varchar2(128),           /* connection pool name */
  status                    varchar2(16),              /* status of the pool */
  minsize                   number,                   /* min servers in pool */
  maxsize                   number,                   /* max servers in pool */
  incrsize                  number,           /* increment number of servers */
  session_cached_cursors    number,         /* max cached cursors in session */
  inactivity_timeout        number,         /* drop conn after inactive time */
  max_think_time            number,                        /* max think time */
  max_use_session           number,                   /* max # session usage */
  max_lifetime_session      number,             /* max lifetime of a session */
  num_cbrok                 number,        /* # of CBrokers spawned per inst */
  maxconn_cbrok             number       /* max # of connections per CBroker */
)
/
create unique index cpool$_ui
  on cpool$ (connection_pool_name)
/

-- Cleanup the table before inserting the default pool row.
truncate table cpool$;

-- Insert the default pool into the pool table.
insert into cpool$ values ('SYS_DEFAULT_CONNECTION_POOL', 'INACTIVE', 
                           4, 40, 2, 20, 300, 120, 500000, 86400, 1, 40000);

-- Create connection pool view 
CREATE OR REPLACE VIEW DBA_CPOOL_INFO
(
  CONNECTION_POOL,
  STATUS,
  MINSIZE, 
  MAXSIZE,
  INCRSIZE,
  SESSION_CACHED_CURSORS,
  INACTIVITY_TIMEOUT,
  MAX_THINK_TIME,
  MAX_USE_SESSION,
  MAX_LIFETIME_SESSION,
  NUM_CBROK,
  MAXCONN_CBROK
)
AS SELECT
  connection_pool_name,
  status,
  minsize,
  maxsize,
  incrsize,
  session_cached_cursors,
  inactivity_timeout,
  max_think_time,
  max_use_session,
  max_lifetime_session,
  num_cbrok,
  maxconn_cbrok
FROM cpool$
/
COMMENT ON TABLE DBA_CPOOL_INFO IS
'Connection pool info'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.CONNECTION_POOL IS
'Connection pool name'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.STATUS IS
'connection pool status'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MINSIZE IS
'Minimum number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAXSIZE IS
'Maximum number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.INCRSIZE IS
'Increment number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.SESSION_CACHED_CURSORS IS
'Session cached cursors'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.INACTIVITY_TIMEOUT IS
'Timeout for an idle session'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_THINK_TIME IS
'Max time for client to start activity on an acquired session'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_USE_SESSION IS
'Maximum life of a session based on usage'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_LIFETIME_SESSION IS
'Maximum life of a session based on time'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_cpool_info FOR dba_cpool_info
/ 
GRANT SELECT ON dba_cpool_info TO select_catalog_role
/

