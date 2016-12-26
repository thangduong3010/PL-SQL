Rem
Rem $Header: undopwd.sql 11-jul-2006.12:07:15 asurpur Exp $
Rem
Rem undopwd.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      undopwd.sql - undo 11g password changes to the default profile  
Rem
Rem    DESCRIPTION
Rem      This script is called by DBCA to undo the 11g secure configuration
Rem      changes to the password portion of the default profile. It reverts
Rem      to the default 10gR2 settings. It is not intended to be run during
Rem      upgrade, since that would undo all customer settings as well.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nlewis      07/11/06 - add comments, fix script
Rem    asurpur     06/16/06 - audit changes for sec config 
Rem    asurpur     06/16/06 - Created
Rem

ALTER PROFILE DEFAULT LIMIT
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LIFE_TIME UNLIMITED
PASSWORD_GRACE_TIME UNLIMITED
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_REUSE_MAX UNLIMITED
;

--To check values:

--  select resource_name, limit from dba_profiles 
--  where profile='DEFAULT' and resource_type='PASSWORD';
