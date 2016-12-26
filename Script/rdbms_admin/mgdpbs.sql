Rem
Rem $Header: rdbms/admin/mgdpbs.sql /main/4 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdpbs.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdpbs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/20/10 - add mgd_id_xml_validator and mgd$sequence_category
Rem    hgong       07/12/06 - edit comments 
Rem    hgong       05/16/06 - rename MGD_ID_META to MGD_ID_UTL 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create public synonyms 
Rem    hgong       03/31/06 - create public synonyms 
Rem    hgong       03/31/06 - Created
Rem

prompt .. Creating Oracle IDCode Privileges for Types and Packages
  
GRANT EXECUTE ON mgd_id TO PUBLIC;
GRANT EXECUTE ON mgd_id_component TO PUBLIC;
GRANT EXECUTE ON mgd_id_component_varray TO PUBLIC;
GRANT EXECUTE ON DBMS_MGD_ID_UTL TO PUBLIC;

--prompt .. Granting SELECT to user and default views supporting the idcode

GRANT SELECT  ON mgd_id_category TO PUBLIC;
GRANT SELECT  ON mgd_id_scheme TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE  ON user_mgd_id_category TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_mgd_id_scheme TO PUBLIC;
GRANT SELECT  ON mgd_id_xml_validator TO PUBLIC;
GRANT SELECT  ON mgd$sequence_category TO PUBLIC;

prompt .. Creating Oracle IDCode Public Synonymns  

CREATE PUBLIC SYNONYM mgd_id FOR mgd_id;
CREATE PUBLIC SYNONYM mgd_id_component FOR mgd_id_component;
CREATE PUBLIC SYNONYM mgd_id_component_varray FOR mgd_id_component_varray;
CREATE PUBLIC SYNONYM DBMS_MGD_ID_UTL FOR DBMS_MGD_ID_UTL;

CREATE PUBLIC SYNONYM mgd_id_category FOR mgd_id_category;
CREATE PUBLIC SYNONYM mgd_id_scheme FOR mgd_id_scheme;
CREATE PUBLIC SYNONYM user_mgd_id_category FOR user_mgd_id_category;
CREATE PUBLIC SYNONYM user_mgd_id_scheme FOR user_mgd_id_scheme;
CREATE PUBLIC SYNONYM mgd_id_xml_validator FOR mgd_id_xml_validator;

/****************************** PROCEDURES *********************************/
/*** VALIDATION Procedures for MGD                                       ***/
/***************************************************************************/
create or replace procedure sys.validate_mgd as
  retnum  NUMBER;
begin
 -- ensure that mgd objects are all valid --
 select 1 into retnum from all_objects where
   owner = 'MGDSYS' and status != 'VALID' and
           (object_name like 'MGD%' or object_name like 'DBMS_MGD%' or 
               object_type = 'JAVA CLASS') and
           rownum < 2;

 sys.dbms_registry.invalid('MGD');
exception
  when no_data_found then
    sys.dbms_registry.valid('MGD');
end;
/
SHOW ERRORS;
/
