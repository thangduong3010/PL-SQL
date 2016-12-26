Rem
Rem $Header: owadbgdrop.sql 19-nov-2001.18:00:00 pkapasi Exp $
Rem
Rem owadbgdrop.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      owadbgdrop.sql - Drop OWA Debug Package install
Rem
Rem    DESCRIPTION
Rem      This file is a driver file that deinstalls the OWA_DEBUG packages
Rem      and must run be run as SYS.  
Rem
Rem    NOTES 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     11/19/01 - Created
Rem

Rem
Rem Deinstall owa_debug_demo package 
Rem
drop public synonym owa_debug_demo;
drop package owa_debug_demo_app;
drop package owa_debug_demo;

Rem
Rem Deinstall package needed for SQL*Profiling
Rem
drop public synonym owa_debug_profiler;
drop package owa_debug_profiler;

Rem
Rem Deinstall package needed for SQL*Tracing
Rem
drop public synonym owa_debug_trace;
drop package owa_debug_trace;

Rem
Rem Deinstall the OWA Debug packages
Rem
drop public synonym owa_debug;
drop package owa_debug;
drop table prvt_owa_debug_sessions;
drop package prvt_owa_debug_log;

