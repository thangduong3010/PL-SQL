Rem  Copyright (c) 1995-2001 by Oracle Corp.  All Rights Reserved.
Rem
Rem   NAME
Rem     owaload.sql - PL/SQL Gateway package installation
Rem
Rem   PURPOSE
Rem     Install the PL/SQL packages needed to run the PL/SQL
Rem     gateway.
Rem
Rem   NOTES
Rem     This driver script installs the PL/SQL gateway toolkit 
Rem     packages (such as HTP/HTP/OWA_UTIL, WPG_DOCLOAD etc.)
Rem     as well as other internal packages needed by the 
Rem     PL/SQL gateway.
Rem
Rem   HOW TO INSTALL
Rem     Connect as sys using SQL*Plus
Rem     Issue "owaload.sql your_log_filename" at the SQL Prompt
Rem
Rem   CHECKLIST
Rem
Rem     Make sure that you have write permissions to create/overwrite
Rem     the log file specified by 'your_log_filename'
Rem
Rem     After the install, make sure that there are no errors in the log file
Rem
Rem     Make sure that there is only one instance of the OWA packages which
Rem     is installed in SYS. The following query will give you all instances
Rem     of the OWA packages
Rem       'select object_name, owner from all_objects where object_name like
Rem       HTP%';
Rem     If multiple instances are detected in other schemas, it is recommended
Rem     that you deinstall other versions before installing the OWA packages
Rem
Rem     Newer OWA packages are backward compatible with older versions
Rem
Rem     It is OK to install the OWA packages multiple times. The OWA packages
Rem     detect older versions in the current schema and reinstalls if required.
Rem
Rem     Notes
Rem     -----
Rem     OWA packages will get reinstalled even if the version
Rem     matches that of the ones you are trying to install. Refer to
Rem     owainst.sql for an explanation of this
Rem
Rem     Installing the OWA packages invalidates all dependent objects. These
Rem     packages will automatically recompile on first access, but it is 
Rem     recommended that a manual recompile be done after reinstall.
Rem
Rem   HISTORY
Rem     pkapasi    06/12/01 -  OWA package install merged with owainst.sql
Rem

whenever oserror exit 32767
set define on
spool &&1

set pagesize 65
set serverout on size 100000
set verify off
set echo off
set termout off
set feedback off
set trimspool on

whenever oserror exit 32767

@@owainst.sql

spool off

exit

