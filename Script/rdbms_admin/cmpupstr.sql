Rem
Rem $Header: cmpupstr.sql 23-may-2006.16:54:43 rburns Exp $
Rem
Rem cmpupstr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cmpupstr.sql - CoMPonent UPgrade STaRt script
Rem
Rem    DESCRIPTION
Rem      Initial component upgrade actions
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/23/06 - parallel upgrade 
Rem    rburns      05/23/06 - Created
Rem

Rem =========================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =========================================================================

WHENEVER SQLERROR EXIT;

Rem check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem =========================================================================
Rem Continue even if there are SQL errors in remainder of script 
Rem =========================================================================

WHENEVER SQLERROR CONTINUE;


