Rem  Copyright (c) 1995, 2004, Oracle.  All Rights Reserved.
Rem
Rem   NAME
Rem     owacsyn.sql - OWA Create public SYNonyms
Rem   PURPOSE
Rem     Create the public OWA synonyms needed to run the PL/SQL
Rem     gateway.
Rem   NOTES
Rem     This script must be run as a user which has create public
REM     synonym privileges.    
Rem   history
Rem     dnonkin    08/31/04 -  added "..or replace.." option 
Rem     rdecker    07/21/00 -  split off from owacomm.sql
Rem

create or replace public synonym OWA_CUSTOM for OWA_CUSTOM;
create or replace public synonym OWA_GLOBAL for OWA_CUSTOM;
create or replace public synonym OWA for OWA;
create or replace public synonym HTF for HTF;
create or replace public synonym HTP for HTP;
create or replace public synonym OWA_COOKIE for OWA_COOKIE;
create or replace public synonym OWA_IMAGE for OWA_IMAGE;
create or replace public synonym OWA_OPT_LOCK for OWA_OPT_LOCK;
create or replace public synonym OWA_PATTERN for OWA_PATTERN;
create or replace public synonym OWA_SEC for OWA_SEC;
create or replace public synonym OWA_TEXT for OWA_TEXT;
create or replace public synonym OWA_UTIL for OWA_UTIL;
create or replace public synonym OWA_INIT for OWA_CUSTOM;
create or replace public synonym OWA_CACHE for OWA_CACHE;
create or replace public synonym OWA_MATCH for OWA_MATCH;
create or replace public synonym WPG_DOCLOAD for WPG_DOCLOAD;

