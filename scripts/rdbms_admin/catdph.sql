Rem
Rem $Header: rdbms/admin/catdph.sql /st_rdbms_11.2.0/1 2013/01/12 02:33:11 rphillip Exp $
Rem
Rem catdph.sql
Rem
Rem Copyright (c) 2004, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catdph.sql -  Main install script for all DataPump header components
Rem
Rem    DESCRIPTION
Rem     The DataPump is all the infrastructure required for new server-based
Rem     data movement utilities. This script handles the installation of all
Rem     of the header components.  catproc.sql will invoke this script
Rem     (catdph.sql) first and then invoke catdpb.sql (for package bodies)
Rem     later.
Rem
Rem    NOTES
Rem     1. Ordering of operations within this file:
Rem        a. Drop types
Rem        b. Separate type definitions
Rem        c. Package definitions (headers... may incl. types assoc withheader)
Rem     2. catnodp.sql drops all DataPump components. catnodpt.sql which drops
Rem        just the DataPump's type definitions is invoked
Rem        from catnodp and is the only 'drop' script invoked here in the
Rem        install script. This is necessary because CREATE OR REPLACE on
Rem        types does not work if there are dependencies on the type.
Rem     3. Please note inter-module dependencies (both internal and external
Rem        to catdp) and ordering, particularly between header files.
Rem        Ordering between bodies and headers is less critical since the
Rem        migration team is working on a plan to separate load of headers and
Rem        bodies into distinct phases.
Rem     4. When adding components to this file, remember to:
Rem        Update catnodp.sql, ship_it, getcat.tsc, tkdp2pfg.tsc, tkdpsuit.tsc,
Rem        tkdppfr.sql and tkdp2rst.tsc. (The last four are used for PL/SQL 
Rem        code coverage.)
Rem        Also consider upgrade/downgrade
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/11/13 - Backport rphillip_bug-15888410 from main
Rem    sdipirro    04/24/07 - Support multiple queue tables
Rem    wfisher     09/12/06 - Disable application roles
Rem    rburns      08/13/06 - split out for parallel
Rem    bpwang      10/05/05 - Grant execute on dbms_server_alert
Rem    wfisher     09/01/05 - Lrg 1908671: Factoring for Standard Edition 
Rem    wfisher     08/19/05 - Creating new roles 
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem

-- First drop all types FORCE. Don't have to drop other object types as
-- CREATE OR REPLACE works for them.
-- @@catnodpt.sql moved to catptabs

-------------------------------------------------------------------------
---     Separate type definitions go here. It is also OK to include public
---     type defs in scripts that contain package header defs rather than
---     isolating them here.
-------------------------------------------------------------------------


-------------------------------------------------------------------------
---     Public and private package headers go here. Type defs can be included
---     in these files as long as creation ordering dependencies are obeyed.
-------------------------------------------------------------------------

-- Metadata API public package header and type defs
-- @@dbmsmeta.sql moved to catpdbms.sql

-- Metadata API private definer's rights package header
-- @@dbmsmeti.sql moved to catpdeps.sql

-- Metadata API private utility package header and type defs
-- @@dbmsmetu.sql moved to catpdeps.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types
-- @@dbmsmetb.sql moved to catpdbms.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types used by Data Pump
-- @@dbmsmetd.sql moved to catpdbms.sql

-- Metadata API type and view defs for object view of dictionary
-- Dependent on dbmsmetu
-- @@catmeta.sql  moved to catpdeps.sql

-- DBMS_DATAPUMP public package header and type definitions
-- @@dbmsdp.sql moved to catpdbms.sql

-- KUPV$FT private package header (depends on types in dbmsdp.sql)
-- @@prvthpv.plb moved to catpdeps.sql

-- KUPCC private types and constants (depends on types in dbmsdp.sql
--                                    and routines in prvtbpv)
-- @@prvtkupc.plb moved to catpdeps.sql 

-- KUPC$QUEUE invoker's private package header (depends on types in prvtkupc)
-- @@prvthpc.plb moved to catpdeps.sql 

-- KUPC$QUEUE_INT definer's private package header (depends on prvtkupc)
-- @@prvthpci.plbmoved to catpdeps.sql 

-- KUPW$WORKER private package header (depends on types in prvtkupc.plb)
-- @@prvthpw.plb moved to catpdeps.sql 

-- KUPM$MCP private package header  (depends on types in prvtkupc.plb)
-- @@prvthpm.plb moved to catpdeps.sql 

-- KUPF$FILE_INT private package header
-- @@prvthpfi.plb moved to catpdeps.sql

-- KUPF$FILE private package header
-- @@prvthpf.plb moved to catpdeps.sql

-- KUPP$PROC private package header
-- @@prvthpp.plb moved to catpdbms.sql

-- KUPD$DATA invoker's private package header
-- @@prvthpd.plb moved to catpdbms.sql

-- KUPD$DATA_INT private package header
-- @@prvthpdi.plb moved to catpdbms.sql

-- KUPV$FT_INT private package header
-- @@prvthpvi.plb moved to catpdbms.sql

-- Application roles for Data Pump.  Object grants will occur in catdpb

-- Need this here because dbmsslrt.sql moved before catdph.sql in catproc.sql
GRANT EXECUTE ON dbms_server_alert TO datapump_imp_full_database;

-- from catdpb.sql

--
-- The global temp. table used by datapump import to store statistics
-- information that will be used with dbms_stats.import... The worker will load
-- statistics information into this table and then call the dbms_stats package
-- to take the data in this table and create statistics.
--
BEGIN
  DBMS_STATS.CREATE_STAT_TABLE('SYS','IMPDP_STATS', NULL, TRUE);
END;
/
GRANT SELECT ON sys.impdp_stats TO PUBLIC
/
GRANT INSERT ON sys.impdp_stats TO PUBLIC
/
GRANT DELETE ON sys.impdp_stats TO PUBLIC
/

-- 
-- The global temp table used by datapump for explain plan.
--
drop table SYS.DATA_PUMP_XPL_TABLE$
/

CREATE GLOBAL TEMPORARY TABLE SYS.DATA_PUMP_XPL_TABLE$
                            (statement_id      varchar2(30),
                             plan_id           number,
                             timestamp         date,
                             remarks           varchar2(4000),
                             operation         varchar2(30),
                             options           varchar2(255),
                             object_node       varchar2(128),
                             object_owner      varchar2(30),
                             object_name       varchar2(30),
                             object_alias      varchar2(65),
                             object_instance   numeric,
                             object_type       varchar2(30),
                             optimizer         varchar2(255),
                             search_columns    number,
                             id                numeric,
                             parent_id         numeric,
                             depth             numeric,
                             position          numeric,
                             cost              numeric,
                             cardinality       numeric,
                             bytes             numeric,
                             other_tag         varchar2(255),
                             partition_start   varchar2(255),
                             partition_stop    varchar2(255),
                             partition_id      numeric,
                             other             long,
                             distribution      varchar2(30),
                             cpu_cost          numeric,
                             io_cost           numeric,
                             temp_space        numeric,
                             access_predicates varchar2(4000),
                             filter_predicates varchar2(4000),
                             projection        varchar2(4000),
                             time              numeric,
                             qblock_name       varchar2(30),
                             other_xml         clob); 

GRANT SELECT ON SYS.DATA_PUMP_XPL_TABLE$ TO PUBLIC
/
GRANT INSERT ON SYS.DATA_PUMP_XPL_TABLE$ TO PUBLIC
/
GRANT DELETE ON SYS.DATA_PUMP_XPL_TABLE$ TO PUBLIC
/
GRANT UPDATE ON SYS.DATA_PUMP_XPL_TABLE$ TO PUBLIC
/


-------------------------------------------------------------------------
---     Finally, miscellaneous stuff like queue tables & stylesheets.
-------------------------------------------------------------------------

--
-- Create a global temporary table for when the export version is not the same
-- as the current version and the current master table needs to be downgraded.
-- This way, the data in the master can be copied to the global temporary table
-- and then it can be modified and once that is complete, the data can be
-- unloaded.
--
BEGIN
  SYS.KUPV$FT.create_gbl_temporary_masters();
END;
/

-- For transportable import, IMP_FULL_DATABASE needs access to the
-- dictionary table sys.expimp_tts_ct$
grant delete,insert,select,update on sys.expimp_tts_ct$ to imp_full_database;

-- Create our queue table.

------------------------------------------------------------------------------
---     Drop all DataPump queue tables and re-create base DataPump queue table
------------------------------------------------------------------------------

DECLARE
  qt_name varchar2(30);
  cursor c1 is select table_name from dba_tables where
    owner = 'SYS' and table_name like 'KUPC$DATAPUMP_QUETAB%';
BEGIN
  open c1;
  loop
    fetch c1 into qt_name;
    exit when c1%NOTFOUND;
    dbms_aqadm.drop_queue_table(queue_table => 'SYS.' || qt_name,
                                force       => TRUE);
  end loop;
  close c1;
EXCEPTION
   WHEN OTHERS THEN
      close c1;
      IF SQLCODE = -24002 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

DECLARE
  sysaux_alive NUMBER;
BEGIN
SELECT COUNT(*) INTO sysaux_alive FROM dba_tablespaces WHERE
  tablespace_name = 'SYSAUX' AND status = 'ONLINE';
IF sysaux_alive > 0 THEN
  dbms_aqadm.create_queue_table(queue_table => 'SYS.KUPC$DATAPUMP_QUETAB', multiple_consumers => TRUE, queue_payload_type =>'SYS.KUPC$_MESSAGE', comment => 'DataPump Queue Table', compatible=>'8.1.3');
ELSE
dbms_aqadm.create_queue_table(queue_table => 'SYS.KUPC$DATAPUMP_QUETAB', multiple_consumers => TRUE, queue_payload_type =>'SYS.KUPC$_MESSAGE', comment => 'DataPump Queue Table', compatible=>'8.1.3',storage_clause=>'TABLESPACE SYSTEM');
END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-- Builds heterogeneous type definitions
-- Installs XSL stylesheets (from rdbms/xml/xsl) in sys.metastylesheet
@@catmet2.sql

-- Create the Data Pump default directory object (DATA_PUMP_DIR)
@@prvtdput.plb
