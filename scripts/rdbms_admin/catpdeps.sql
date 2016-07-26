Rem
Rem $Header: rdbms/admin/catpdeps.sql /st_rdbms_11.2.0/3 2013/06/22 10:12:01 davili Exp $
Rem $Header: rdbms/admin/catpdeps.sql /st_rdbms_11.2.0/3 2013/06/22 10:12:01 davili Exp $
Rem
Rem catpdeps.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpdeps.sql - CATProc DEPendents
Rem
Rem    DESCRIPTION
Rem      This script creates objects that have dependencies on package 
Rem      specifications and standalone procedures and functions.
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql
Rem      It is run single process by catctl.pl.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    davili      06/19/13 - Move the packages to support emll
Rem    arbalakr    02/01/13 - Add prvt_awr_data.plb
Rem    yujwang     08/08/12 - fix lrg 7156708 by moving prvtwrr.plb from
Rem                           catpprvt.sql to catpdeps.sql
Rem    schitti     01/29/09 - AP Support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    rcolle      01/21/09 - add catwrrvw.sql
Rem    sjanardh    07/01/08 - Add prvtaqiu.lb
Rem    rapayne     06/27/08 - load catmeta.sql after prvtkupc.plb
Rem    msakayed    04/16/08 - compression/encryption feature tracking for 11.2
Rem    hosu        12/27/07 - add catost.sql (view dependent on dbmsstat)
Rem    sylin       11/27/07 - move prvtutil.plb to catpprvt
Rem    sylin       11/15/07 - Add prvtsys.plb
Rem    achoi       11/13/07 - add catpexev
Rem    vakrishn    02/16/07 - txn layer dependent objects
Rem    rburns      09/17/06 - add svrm dependents
Rem    jinwu       11/14/06 - add prvthsts prvthfgr prvthcmp
Rem    jinwu       11/13/06 - add catstr.sql
Rem    rburns      08/23/06 - more restructuring
Rem    cdilling    08/07/06 - add catadv.sql
Rem    rburns      07/29/06 - more restructure 
Rem    kneel       06/05/06 - moving execution of prvthdbu to catpdeps.sql 
Rem    kneel       06/04/06 - moving execution of dbmshae.sql to catpdeps.sql 
Rem    rburns      05/24/06 - add prvthlrt 
Rem    rburns      05/19/06 - break up catqueue.sql 
Rem    rburns      01/13/06 - split for parallel processing 
Rem    rburns      01/13/06 - Created
Rem

Rem pl/sql tracing package
@@prvthdbu.plb

Rem Optimizer Statistics tables and views that can not be created while running 
Rem catalog.sql due to dependency on other objects
@@catost

Rem High Availabilty Events (FAN alerts)
Rem  - dependent on dbmsslrt.sql (dbms_server_alert)
@@dbmshae.sql

Rem Views for XA recovery - depends on dbmsraw
@@catxpend

-- STREAMS scripts use SET SERVEROUTPUT ON
@@prvtotpt.plb

Rem STREAMS
Rem need to load prvthlut here because of dependency on bit,bis,bic
@@prvthlut.plb
Rem need to load prvthlin here because AQ export needs it
@@prvthlin.plb
Rem Streams Datapump package specs. AQ and LSBY need it.
@@prvthsdp.plb

-- contains packge spec and body for dbms_system
@@prvtsys.plb

-- contains package body and spec for dbms_appctx
Rem Global Context internal package
@@prvtctx.plb

Rem on-disk versions of rman support
-- contains type body for v_lbRecSetImpl_t
@@dbmsrman.sql
@@dbmsbkrs.sql

Rem System event attribute functions
-- contains standalone functions
@@dbmstrig.sql

Rem Random number generator
-- contains spec and body for dbms_random
@@dbmsrand.sql

Rem Multi-language debug support
-- contains bodies with order dependencies
@@dbmsjdwp.sql
@@dbmsjdcu.sql
@@dbmsjdmp.sql

Rem OLAP Services
@@catxs.sql

Rem dbms_snapshot
-- depends on dbms_sql?
@@dbmssnap

Rem Materialized views
-- depends on type created in dbmssnap
@@prvtxrmv.plb

Rem AQ dependencies
@@depsaq.sql
@@prvtaqiu.plb

Rem Server-generated alert dependent file
@@prvthlrt.plb

Rem Manageability Advisor
@@catadv

-- AQ Dependencies on Scheduler:
@@cataqsch.sql

Rem Views for transportable tablespace
-- Dependencies on queues
@@catplug


-- load dbms_sql and ddbms_assert before logminer
@@prvtsql.plb
@@prvtssql.plb
@@prvtasrt.plb

-- runs logmnr_install
@@prvtlmd.plb
@@prvtlmcs.plb
@@prvtlmrs.plb
@@dbmslms.sql

-- KUPU$UTILITIES invoker's private package header
@@prvthpu.plb

-- KUPU$UTILITIES definer's private package header
@@prvthpui.plb

-- Metadata API private definer's rights package header
@@dbmsmeti.sql

-- Metadata API private utility package header and type defs
@@dbmsmetu.sql

-- KUPV$FT private package header (depends on types in dbmsdp.sql)
@@prvthpv.plb

-- KUPCC private types and constants (depends on types in dbmsdp.sql
--                                    and routines in prvtbpv)
@@prvtkupc.plb 

-- Metadata API type and view defs for object view of dictionary
-- Dependent on dbmsmetu
@@catmeta.sql

-- KUPC$QUEUE invoker's private package header (depends on types in prvtkupc)
@@prvthpc.plb 

-- KUPC$QUEUE_INT definer's private package header (depends on prvtkupc)
@@prvthpci.plb

-- KUPW$WORKER private package header (depends on types in prvtkupc.plb)
@@prvthpw.plb 

-- KUPM$MCP private package header  (depends on types in prvtkupc.plb)
@@prvthpm.plb 

-- KUPF$FILE_INT private package header
@@prvthpfi.plb

-- KUPF$FILE private package header
@@prvthpf.plb

Rem Data Mining
-- depends on dbms_assert and dbms metadata
@@dbmsodm.sql

Rem Logical Standby tables & views & procedures
-- depends on dbmscr.sql and other objects
@@catlsby

Rem Internal Trigger package spec and body 
-- snapshot package bodies depend on this
@@prvtitrg.plb

Rem Summary Advisor
@@prvtsms.plb

Rem Server Manageability
@@depssvrm

Rem Transaction layer dependent objects
@@deptxn

-- dba_capture depends on dba_logmnr_session (prvtlmd)
Rem Streams catalog views
@@catstr.sql

-- prvthsts prvthfgr and prvthcmp need DBMS_LOGREP_UTIL (prvthlut),
-- ku$_Status and ku$_JobDesc (dbmsdp.sql).
Rem Streams TableSpaces headers
@@prvthsts.plb

Rem File Group headers
@@prvthfgr.plb
@@prvthfie.plb

Rem Data Comparison headers
@@prvthcmp.plb

Rem DBMS_PARALLEL_EXECUTE views
@@catpexev.sql

Rem ContentAPI
@@depscapi

Rem PSPI Views
@@depspspi

Rem DBMS_WORKLOAD_CAPTURE and DBMS_WORKLOAD_REPLAY views
@@catwrrvw.sql

Rem Create DBMS_WORKLOAD_ package body
@@prvtwrr.plb

Rem 
Rem prvtcpaddm pkg
Rem
@@prvt_awr_data.plb
