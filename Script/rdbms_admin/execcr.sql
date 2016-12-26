Rem
Rem $Header: execcr.sql 12-jul-2006.15:26:37 cdilling Exp $
Rem
Rem execcr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execcr.sql - EXECute Component Registry packages
Rem
Rem    DESCRIPTION
Rem      This scripts executes component registry procedures
Rem      required as part of database creation.
Rem
Rem    NOTES
Rem      Run from catpexec.sql (catproc.sql)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    07/12/06 - clean up session state 
Rem    rburns      05/06/06 - component registry execute 
Rem    rburns      05/06/06 - Created
Rem

Rem
Rem Start with a clean session state for the package
Rem
execute DBMS_SESSION.RESET_PACKAGE; 

Rem
Rem Set up drop user invocation
Rem

DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_REGISTRY_SYS';
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS','DBMS_REGISTRY_SYS','DROP_USER',1, 1,
          'Delete registry entries when schema or invoker is dropped');
COMMIT;

Rem
Rem  Create CONTEXT for Registry Variables and set namespace to SERVER
Rem

CREATE OR REPLACE CONTEXT registry$ctx USING dbms_registry_sys;

BEGIN
   dbms_registry.set_session_namespace('SERVER');
   dbms_registry_sys.set_registry_context('COMPONENT','RDBMS');
END;
/


