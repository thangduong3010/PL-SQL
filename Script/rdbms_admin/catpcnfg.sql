Rem
Rem $Header: catpcnfg.sql 13-nov-2006.08:35:48 ilistvin Exp $
Rem
Rem catpcnfg.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catpcnfg.sql - CATPROC CoNFiGuration
Rem
Rem    DESCRIPTION
Rem      This script runs required configuration scripts to set up
Rem      scheduler and other required objects
Rem
Rem    NOTES
Rem      The script is run by catproc.sql as a single process script
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    11/13/06 - add catmwin.sql
Rem    jinwu       11/02/06 - move catstr.sql and catpstr.sql
Rem    elu         10/23/06 - catrep restructure
Rem    rburns      08/25/06 - move prvtsnap
Rem    rburns      07/27/06 - configuration scripts 
Rem    rburns      07/27/06 - Created
Rem

Rem Resource Manager
@@execrm.sql

Rem Scheduler objects
@@execsch.sql

-- Scheduler calls to AQ packages
@@catscqa.sql

-- Svrman calls to AQ and Scheduler
@@catmwin.sql

Rem on-disk versions of rman support
-- dependent on streams
@@prvtrmns.plb
@@prvtbkrs.plb

REM change data capture packages
REM prvtcdcu calls into prvtcdcp
REM prvtcdpe calls int prvtcdpi, so prvtcdpi must be before prvtcdpe
REM NOTE: must be placed after Streams packages
REM NOTE: must also be placed after Data Pump packages
REM NOTE: must also be placed after internal trigger package
@@prvtcdcu.plb
@@prvtcdcp.plb
@@prvtcdcs.plb
@@prvtcdpu.plb
@@prvtcdpi.plb
@@prvtcdpe.plb
