Rem
Rem $Header: rdbms/admin/xsdbmig.sql /main/4 2009/08/25 21:49:28 badeoti Exp $
Rem
Rem xsdbmig.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xsdbmig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      10/02/07 - add 11.1 upgrade
Rem    pthornto    10/09/06 - Main migration/upgrade file for Xtensible
Rem                           Security
Rem    pthornto    10/09/06 - Created
Rem

Rem ============================================================
Rem    Initialize environment for XS upgrade
Rem ============================================================

-- Initialize ResConfig before proceeding
-- is this necessary?
call xdb.dbms_xdbz0.initXDBResConfig();

-- temp load package and create directory
-- move xdbdbmig in restructure
@@catxdbh
exec dbms_metadata_hack.cre_dir;
exec dbms_metadata_hack.cre_xml_dir;

Rem ============================================================
Rem Determine which release is being upgraded
Rem and set upgrade script name
Rem ============================================================

VARIABLE xs_version VARCHAR2(30);

DECLARE
   xdb_version       registry$.version%type;
   xdb_prv_version   registry$.prv_version%type;
BEGIN
   -- check that XDB has been upgraded to current version
   SELECT version, prv_version into xdb_version, xdb_prv_version
   FROM registry$ where cid='XDB';
   IF xdb_version = dbms_registry.release_version THEN
      -- XDB has been upgraded to current version, use previous version
      IF substr(xdb_prv_version,1,6) = '11.1.0' THEN
         :xs_version := '111';
      ELSE
         :xs_version := '102';  -- for all upgrades prior to 11.1
      END IF;
   ELSE  
      -- XDB not yet current version for some reason, use version
      IF substr(xdb_version,1,6) = '11.1.0' THEN
         :xs_version := '111';
      ELSE
         :xs_version := '102';  -- for all upgrades prior to 11.1
      END IF;
   END IF;
END;
/

Rem get version being upgraded into xs_file variable
COLUMN :xs_version NEW_VALUE xs_file NOPRINT;
SELECT :xs_version FROM DUAL;

Rem Run Fusion security base upgrade script
@@xsu&xs_file

Rem Reload Fusion Security packages and views 
@@xsrelod

Rem Run Fusion Security post-reload upgrade script
@@xsa&xs_file

-- temporarily drop directories and package
-- move to xdbdbmig.sql
execute dbms_metadata_hack.drop_dir;
execute dbms_metadata_hack.drop_xml_dir;
drop package dbms_metadata_hack;

