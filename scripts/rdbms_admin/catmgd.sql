Rem
Rem $Header: catmgd.sql 18-jul-2006.06:46:15 hgong Exp $
Rem
Rem catmgd.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catmgd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/31/06 - remove internal utility package 
Rem    hgong       05/16/06 - rename meta and utility packages 
Rem    hgong       04/04/06 - rename oidcode.jar
Rem    hgong       03/31/06 - mgd installation script 
Rem    hgong       03/31/06 - mgd installation script 
Rem    hgong       03/31/06 - Created
Rem

SET SERVEROUTPUT ON;

Rem
Rem .. Creating MGDSYS Schema
Rem

@@mgdsys.sql
    
Rem
Rem Running as sysdba : set current schema to MGDSYS
Rem

CALL sys.dbms_registry.loading('MGD', 'Oracle Machine Generated Data', 'validate_mgd','MGDSYS');  
ALTER SESSION SET CURRENT_SCHEMA = MGDSYS;

CALL sys.dbms_java.set_output(100000);

Rem
Rem Create required schema objects in the MGDSYS Schema
Rem
     
prompt .. Load java components for tag translation

@@initmgd.sql;

prompt .. Check whether java has been loaded successfully

select owner, object_name, status from all_objects where object_name = dbms_java.shortname('oracle/mgd/idcode/IDCodeTranslator') ;

prompt .. Creating Oracle IDCode Types
  
@@mgdtyp.sql

prompt .. Creating Oracle IDCode Dictionary Tables
  
@@mgdtab.sql

prompt .. Creating Oracle IDCode views
  
@@mgdview.sql

-- Package Specifications Public

prompt .. Creating Oracle IDCode Utility Package Specification in MGDSYS  
  
@@mgdus.sql

-- Package Specifications Private

prompt .. Creating Oracle IDCode Internal Utility Package Specification in MGDSYS  
  
@@prvtmgduis.plb    

-- Type Bodies 

prompt .. Creating Oracle IDCode Type Body in MGDSYS  

@@prvtmgdtypb.plb 

-- Package Bodies 

prompt .. Creating Oracle IDCode Utility Package Body in MGDSYS  

@@prvtmgdub.plb 

prompt .. Creating Oracle IDCode Internal Utility Package Body in MGDSYS  

@@prvtmgduib.plb 
    
--- Create trigger and load metadata has to be placed after loading utility packages
prompt .. Creating Oracle IDCode triggers
  
@@mgdtrg.sql

prompt .. Creating Public Synonyms
  
@@mgdpbs.sql  

prompt .. Load metadata

@@mgdmeta.sql;

ALTER SESSION SET CURRENT_SCHEMA = SYS;     
  
EXECUTE sys.dbms_registry.loaded('MGD');

prompt .. Validate MGD installation

EXECUTE sys.validate_mgd;


