Rem
Rem $Header: catnomgd.sql 12-jul-2006.10:26:45 hgong Exp $
Rem
Rem catnomgd.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnomgd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       05/25/06 - moved the uninstallation statements to mgdrm.sql
Rem    hgong       03/31/06 - Created
Rem

EXECUTE dbms_registry.removing('MGD');

--select comp_name,version,status from dba_registry;

prompt .. Dropping MGDSYS Java components
call sys.dbms_java.dropjava('-schema MGDSYS rdbms/jlib/mgd_idcode.jar');

prompt .. Dropping the Oracle MGDSYS user with cascade option 
DROP USER MGDSYS CASCADE;

prompt .. Dropping Public Synonyms

DROP PUBLIC SYNONYM mgd_id;
DROP PUBLIC SYNONYM mgd_id_component;
DROP PUBLIC SYNONYM mgd_id_component_varray;
DROP PUBLIC SYNONYM DBMS_MGD_ID_UTL;
DROP PUBLIC SYNONYM mgd_id_category;
DROP PUBLIC SYNONYM mgd_id_scheme;
DROP PUBLIC SYNONYM user_mgd_id_category;
DROP PUBLIC SYNONYM user_mgd_id_scheme;

--select comp_name,version,status from dba_registry;

------------------------------------------------------
-- No need to call removed, because MGDSYS is dropped
------------------------------------------------------
--EXECUTE dbms_registry.removed('MGD');
