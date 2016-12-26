Rem
Rem $Header: owadbginst.sql 19-nov-2001.18:00:00 pkapasi Exp $
Rem
Rem owadbginst.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      owadbginst.sql - OWA Debug Package installation script
Rem
Rem    DESCRIPTION
Rem      This file is a driver file that installs the OWA_DEBUG packages
Rem      and must be run as SYS.  This script is meant for development 
Rem      environments only.
Rem
Rem    NOTES 
Rem      DUE TO POSSIBLE SECURITY CONCERNS, THIS SCRIPT SHOULD NOT BE 
Rem      INSTALLED IN A PRODUCTION ENVIRONMENT
Rem   1. Install this script as SYS
Rem   2. Setup the DAD configuration as follows
Rem      - PlsqlOWADebugEnable On
Rem      - PlsqlMaxRequestsPerSession 1
Rem      - PlsqlExclusionList #None#
Rem   3. Access the url http://host:port/pls/DAD/owa_debug_demo.main_form
Rem      Select the options that you wish to enable for this session
Rem      and hit "Create Debug Session". This will create a cookie for you
Rem      which will be used to track your "Debug Session" preferences.
Rem   4. Access the procedure you want to get SQL*Trace/SQL*Profile for
Rem   5. To deinstall these scripts, run owadbgdrop.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     01/10/01 - Refine documentation 
Rem    pkapasi     11/19/01 - Created
Rem

Rem Install the OWA Debug packages
@pubowad.sql
@privowad.plb

Rem Install package needed for SQL*Trace
@pubtrace.sql

Rem Install package needed for SQL*Profiling
@pubprof.sql

Rem Install owa_debug_demo package 
@owaddemo.sql
grant execute on owa_debug_demo to public;
create public synonym owa_debug_demo for owa_debug_demo;

