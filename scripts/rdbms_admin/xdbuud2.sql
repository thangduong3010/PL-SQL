rem
Rem $Header: rdbms/admin/xdbuud2.sql /main/4 2010/05/05 15:12:00 badeoti Exp $
Rem
Rem xdbuud2.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbuud2.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/20/10 - drop xdb.FixAcl_SchemaLoc
Rem    spetride    12/08/09 - drop create_csxinvalid_entries_tab
Rem    abagrawa    03/28/06 - Move update_config_ref to new file 
Rem    abagrawa    03/28/06 - Add check_user_dependents 
Rem    abagrawa    03/26/06 - Drop update_config_ref 
Rem    abagrawa    03/20/06 - Remove set echo on 
Rem    abagrawa    03/18/06 - Drop migrate_patchup_schema 
Rem    abagrawa    03/14/06 - Drop utility functions created in xdbuuc2.sql 
Rem    abagrawa    03/14/06 - Drop utility functions created in xdbuuc2.sql 
Rem    abagrawa    03/14/06 - Created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop procedure check_user_dependents;
drop procedure migrate_patchup_schema;
drop procedure xdb.FixAcl_SchemaLoc;
drop procedure create_csxinvalid_entries_tab;
drop procedure xdb$migratexmltable;
drop procedure delete_schema_if_exists;
