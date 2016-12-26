Rem
Rem $Header: rdbms/admin/cmpupend.sql /st_rdbms_11.2.0/2 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupend.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupend.sql - CoMPonent UPgrade END script
Rem
Rem    DESCRIPTION
Rem      Final component upgrade actions
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    mdietric    05/18/12 - Backport mdietric_bug-11901407 from main
Rem    cdilling    04/18/07 - add timestamp for gather_stats
Rem    rburns      12/07/06 - move gather_stats
Rem    cdilling    12/14/06 - add RDBMS identifier
Rem    rburns      07/19/06 - move final actions to catupend.sql 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

set serveroutput off
set errorlogging on table sys.registry$error identifier 'ACTIONS';

SELECT dbms_registry_sys.time_stamp('ACTIONS_BGN') AS timestamp FROM DUAL;

