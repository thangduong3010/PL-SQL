Rem
Rem $Header: execsec.sql 12-jun-2006.13:39:34 rburns Exp $
Rem
Rem execsec.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execsec.sql - secure configuration settings
Rem
Rem    DESCRIPTION
Rem      Secure configuration settings for the database include a reasonable
Rem      default password profile, password complexity checks, audit settings
Rem      (enabled, with admin actions audited), and as many revokes from PUBLIC
Rem      as possible. In the first phase, only the default password profile is
Rem      included.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      06/12/06 - add conditional 
Rem    nlewis      06/06/06 - change filename 
Rem    nlewis      06/05/06 - Secure configuration scripts 
Rem    nlewis      06/05/06 - Created
Rem

Rem  Only run the secconf.sql script for new database creations, not
Rem  for upgrades or any other reruns of catproc.sql.  The version column
Rem  in registry$ is NULL while catproc.sql is running the first time
Rem  on a new database.

VARIABLE secconf_name VARCHAR2(256)                   
COLUMN :secconf_name NEW_VALUE secconf_file NOPRINT

DECLARE
   p_version  varchar2(30);
BEGIN
   :secconf_name := '@nothing.sql';
   SELECT version INTO p_version FROM registry$
   WHERE cid='CATPROC';
   IF p_version IS NULL THEN
      :secconf_name := '@secconf.sql';
   END IF;
END;
/

SELECT :secconf_name FROM DUAL;
@&secconf_file


