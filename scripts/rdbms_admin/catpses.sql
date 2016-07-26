Rem
Rem $Header: catpses.sql22631 23-oct-2006.21:06:47 rburns Exp $
Rem
Rem catpses.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catpses.sql - CATalog and CATProc SESsion script
Rem
Rem    DESCRIPTION
Rem      This script initializes the session for running catalog 
Rem      and/or catproc scripts
Rem
Rem    NOTES
Rem      It is used as the session script for parallel processes
Rem      when catalog.sql and/or catproc.sql is run using multiprocesses
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/23/06 - Created
Rem
Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;


