Rem
Rem $Header: rdbms/admin/catptabs.sql /st_rdbms_11.2.0/2 2012/08/25 00:06:30 pknaggs Exp $
Rem
Rem catptabs.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catptabs.sql - CATProc TABleS and views
Rem
Rem    DESCRIPTION
Rem      This script runs the "cat" scripts that create the tables
Rem      and views required by the features loaded in catproc.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    pknaggs     01/31/12 - RADM: add catredact
Rem    amullick    06/15/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove catam.sql
Rem    amullick    01/22/09 - Add Archive Provider catalog tables
Rem    rcolle      01/21/09 - only load WRR tables and not views
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    ssvemuri    03/27/08 - Archive Manager catalog tables
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT tables and views
Rem    hosu        12/28/07 - move catost.sql to catpdeps.sql
Rem    sylin       12/06/07 - add prvtrctv.plb required by prvtrcmp.plb
Rem    sylin       11/29/07 - add prvtuttv.plb required by prvtutil.plb
Rem    achoi       11/13/07 - add catpexe
Rem    shan        04/13/07 - added catdef.sql
Rem    dvoss       01/03/07 - add catlmnr.sql
Rem    ilistvin    11/22/06 - use catawrtv instead of catawr
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    elu         10/23/06 - add catrep.sql
Rem    schakkap    09/20/06 - fix comments for catost.sql
Rem    mbastawa    08/31/06 - add catcrc.sql
Rem    rburns      08/23/06 - more restructuring
Rem    cdilling    08/03/06 - add catadvtb.sql
Rem    rburns      07/27/06 - more reorganization 
Rem    chliang     05/24/06 - add sscr cat script
Rem    kamsubra    05/19/06 - Adding catkppls.sql 
Rem    kneel       06/01/06 - add cathae.sql 
Rem    rburns      05/19/06 - add queue files 
Rem    mabhatta    05/18/06 - adding transaction backout catalog file 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem


-- Drop all dp types FORCE. Don't have to drop other object types as
-- CREATE OR REPLACE works for them.
@@catnodpt.sql

Rem Flashback transaction backout
Rem The types are used in dbmstran and prvttran
@@catbac.sql

Rem tables and views for UTL_RECOMP package body
@@prvtrctv.plb

Rem Views for Application context ( dbmsutil and prvtutil depends on it )
@@catactx.sql

Rem View and types for dbms_utility package body
@@prvtuttv.plb

Rem Server Manager views -- depends on views created in catspace
@@catsvrmg

-- need before dbms_jobs can be run, so include in this script
Rem Logical Standby package specs
@@prvtlsis.plb
@@prvtlsss.plb

Rem Transformations
@@cattrans.sql

Rem Rules engine
@@catrule.sql

@@catsnap

Rem Views for tablespace point in time recovery
@@catpitr

Rem DIP account creation
@@catdip.sql

Rem Row Level Security catalog views
@@catrls

Rem Views for tablespace point in time recovery
@@catpitr

Rem Script for Application Role
@@catar.sql

Rem Manageability/Diagnosability Report Framework
-- tables are created in catpstrt.sql
@@catrepv

Rem Script for Fine Grained Auditing
@@catfga.sql

Rem Script for DBMS_AUDIT_MGMT
@@catamgt.sql

Rem Index Rebuild Views and Body
@@catidxu

Rem Transparent Session Migration
@@cattsm.sql

Rem Change Notification
@@catchnf.sql

Rem Data Mining
@@catodm.sql

Rem Connection pool
@@catkppls.sql

Rem Session State Capture and Restore (SSCR)
@@catsscr.sql

Rem Advanced Queues
@@catqueue.sql

Rem High Availabilty Events (FAN alerts)
@@cathae.sql

Rem Manageability Advisor
@@catadvtb.sql

Rem Resource Manager Views
@@catrm.sql

Rem Scheduler tables
@@catsch.sql

Rem Stored outline catalog views
@@catol.sql

Rem DataPump views
@@catdpb.sql

Rem Client result cache
@@catcrc.sql

Rem Component Registry Package spec and views
@@dbmscr.sql

Rem dbms_utility used in package specs
@@dbmsutil

Rem Create the DB Feature Usage tables/views
@@catdbfus

Rem Create server alert schema
@@catalrt

Rem Create Autotask Schema
@@catatsk

Rem create dbms monitor schema
@@catmntr

Rem create SQL Tune schema
@@catsqlt

Rem create AWR schema
@@catawrtv

Rem SQL Management Base (SMB) catalog views
@@catsmbvw.sql

Rem Create the WRR$ schema
@@catwrrtb.sql

Rem SQL Access Advisor tables
@@catsumat

Rem Replication tables and views
@@catrep.sql

Rem Logminer tables and views
@@catlmnr.sql

Rem Catdef, default password table and views
@@catdef.sql

Rem Catadrvw - the adr views/synonyms/grants
@@catadrvw

Rem DBMS_PARALLEL_EXECUTE table
@@catpexe.sql

Rem ContentAPI
@@catcapi

Rem archive provider catalog tables
@@catpspi.sql

Rem Real-time Application-controlled Data Masking
@@catredact

Rem RAT Masking tables
@@catratmask.sql


Rem *********************************************************************
Rem END catptabs.sql
Rem *********************************************************************
