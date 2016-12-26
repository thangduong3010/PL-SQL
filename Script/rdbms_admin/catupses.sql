Rem
Rem $Header: rdbms/admin/catupses.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem catupses.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupses.sql - CATalog UPgrade SESsion script
Rem
Rem    DESCRIPTION
Rem      This script contains session initialization statements
Rem      that perform per-session start up actions when running
Rem      catupgrd.sql in parallel processes.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/30/13 - bug_16816410_11204: add identifier to errorlogging
Rem                           syntax
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/23/06 - Created
Rem

Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =====================================================================
Rem Turn off PL/SQL event used by APPS
Rem =====================================================================

ALTER SESSION SET EVENTS='10933 trace name context off';

Rem =====================================================================
Rem Set the error logging table for the session
Rem =====================================================================

SET ERRORLOGGING ON TABLE sys.registry$error IDENTIFIER 'RDBMS';
