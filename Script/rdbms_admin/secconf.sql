Rem
Rem $Header: rdbms/admin/secconf.sql /st_rdbms_11.2.0/1 2012/11/21 02:28:05 vpriyans Exp $
Rem
Rem secconf.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      secconf.sql - SECure CONFiguration script
Rem
Rem    DESCRIPTION
Rem      Secure configuration settings for the database include a reasonable
Rem      default password profile, password complexity checks, audit settings
Rem      (enabled, with admin actions audited), and as many revokes from PUBLIC
Rem      as possible. In the first phase, only the default password profile is
Rem      included.
Rem
Rem
Rem    NOTES
Rem      Only invoked for newly created databases, not for upgraded databases
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vpriyans    11/05/12 - Backport vpriyans_bug-12904308 from main
Rem    apsrivas    09/30/08 - bug 7428539: Add missing audit settings
Rem    asurpur     06/16/06 - audit changes for sec config 
Rem    rburns      06/12/06 - secure configuration script 
Rem    rburns      06/12/06 - Created
Rem

Rem Secure configuration settings. Currently, only the default password
Rem profile is included, without the password complexity check. We will add
Rem the audit settings, revokes from PUBLIC, and the password complexity 
Rem checks.

-- Create password profile without a password complexity routine, for backward
-- compatibility. Add the routine if possible without breaking tests

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 180
PASSWORD_GRACE_TIME 7
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_REUSE_MAX UNLIMITED
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME 1
;

-- Turn on auditing options

Audit alter any table by access;

Audit create any table by access;

Audit drop any table by access;

Audit Create any procedure by access;

Audit Drop any procedure by access;

Audit Alter any procedure by access;

Audit Grant any privilege by access;

Audit grant any object privilege by access;

Audit grant any role by access;

Audit audit system by access;

Audit create external job by access;

Audit create any job by access;

Audit create any library by access;

Audit create public database link by access;

Audit exempt access policy by access;

Audit alter user by access;

Audit create user by access;

Audit role by access;

Audit create session by access;

Audit drop user by access;

Audit alter database by access;

Audit alter system by access;

Audit alter profile by access;

Audit drop profile by access;

Audit database link by access;

Audit system audit by access;

Audit profile by access;

Audit public synonym by access;

Audit system grant by access;

Audit directory by access;
