Rem
Rem $Header: catawr.sql 21-feb-2008.10:03:01 ilistvin Exp $
Rem
Rem catawr.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catawr.sql - Catalog script for Automatic Workload Repository
Rem                   (AWR)
Rem
Rem    DESCRIPTION
Rem      Creates tables, views, package for AWR
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem      The newly created tables should be TRUNCATE in the downgrade script.
Rem      Any new views and their synonyms should be dropped in the downgrade
Rem      script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    01/31/08 - add prvsawri.plb
Rem    ilistvin    09/14/07 - add prv[st]awrs.plb
Rem    ilistvin    11/22/06 - changes for catproc restructuring
Rem    mlfeng      06/11/06 - package spec first 
Rem    veeve       06/04/04 - added prvtash.plb
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/29/03 - change SWRF to AWR everywhere
Rem    mlfeng      01/24/03 - Remove catdbfus.sql
Rem    mlfeng      01/16/03 - Adding call to catswrvw.sql to create views
Rem    mlfeng      01/07/03 - Add script to create DB Feature Usage
Rem    mlfeng      09/26/02 - Enable WR schema creation
Rem    mlfeng      08/01/02 - updating dba_sysaux_occupant
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/14/02 - Adding DBA_SYSAUX_OCCUPANT view
Rem    mlfeng      06/11/02 - Created
Rem

Rem The following script will create the WR tables
@@catawrtb

Rem Create the DBMS_WORKLOAD_REPOSITORY package
@@dbmsawr

Rem The following script will create the DBA_HIST views for the 
Rem Workload Repository
@@catawrvw
@@catawrpd

Rem Create DBMS_ASH_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvsash.plb
@@prvtash.plb

Rem Create DBMS_WORKLOAD_REPOSITORY package body,
Rem Create DBMS_SWRF_INTERNAL package and package body,
Rem Create DBMS_SWRF_REPORT_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvsawr.plb
@@prvsawri.plb
@@prvsawrs.plb
@@prvtawr.plb
@@prvtawri.plb
@@prvtawrs.plb

