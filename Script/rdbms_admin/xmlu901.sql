Rem
Rem $Header: xmlu901.sql 18-sep-2003.15:57:30 mjaeger Exp $
Rem
Rem xmlu901.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      xmlu901.sql - Upgrade from 9.0.1 database
Rem
Rem    DESCRIPTION
Rem      Upgrade from 9.0.1 database
Rem
Rem
Rem MODIFIED (MM/DD/YY)
Rem mjaeger   09/18/03 - bug 3015638: add parts for XSU
Rem kkarun    06/05/03 - fix bug 2973904
Rem kkarun    04/16/03 - use execute instead of call
Rem kkarun    04/14/03 - update upgraded calls
Rem kkarun    04/13/03 - list ncomp classes for removal
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    12/12/02 - don't remove jserver system classes
Rem kkarun    11/12/02 - update version
Rem kkarun    05/30/02 - update to 10i
Rem kkarun    05/30/02 - remove plsql
Rem tyu       03/14/02 - drop class .../org_w3c_dom_range_Installer
Rem kkarun    02/20/02 - drop 901 ncomp classes
Rem kkarun    02/13/02 - update version
Rem kkarun    12/17/01 - split drop  package v2
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    10/30/01 - Merged kkarun_fix_migration_scritps
Rem kkarun    10/24/01 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: Remove 9.0.1 XML Classes and packages
Rem =========================================================================

EXECUTE dbms_registry.upgrading('XML', 'Oracle XDK');

-- Drop Java Packages
create or replace procedure xdk_drop_package(pkg varchar2) is
   CURSOR classes is select dbms_java.longname(object_name) class_name
      from all_objects
      where object_type = 'JAVA CLASS'
	and dbms_java.longname(object_name) like '%' || pkg || '%';
begin
   FOR class IN classes LOOP
      dbms_java.dropjava('-r -v -synonym ' || class.class_name);
   END LOOP;
end xdk_drop_package;
/

EXECUTE xdk_drop_package('oracle/xml/jaxp');
EXECUTE xdk_drop_package('oracle/xml/comp');
EXECUTE xdk_drop_package('oracle/xml/async');
EXECUTE xdk_drop_package('oracle/xml/classgen');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/XML');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/XSL');
EXECUTE xdk_drop_package('oracle/xml/parser/v2');
EXECUTE xdk_drop_package('oracle/xml/parser/plsql');
EXECUTE xdk_drop_package('oracle/xml/parser/schema');
EXECUTE xdk_drop_package('oracle/xml/sql');
EXECUTE xdk_drop_package('OracleXML');

drop procedure xdk_drop_package;

-- Drop PL/SQL XML Parser Packages
drop package xmlattrcover;
drop package xmlchardatacover;
drop package xmldocumentcover;
drop package xmldom;
drop package xmldomimplcover;
drop package xmldtdcover;
drop package xmlelementcover;
drop package xmlentitycover;
drop package xmlnnmcover;
drop package xmlnodecover;
drop package xmlnodelistcover;
drop package xmlnotationcover;
drop package xmlparser;
drop package xmlparsercover;
drop package xmlpicover;
drop package xmltextcover;
drop package xslprocessor;
drop package xslprocessorcover;
drop package xslstylesheetcover;
drop public synonym xmldom;
drop public synonym xmlparser;
drop public synonym xslprocessor;

-- Drop PL/SQL packages for XML/SQL Utility (XSU).
drop package dbms_xmlquery;
drop package dbms_xmlsave;
drop public synonym dbms_xmlquery;
drop public synonym dbms_xmlsave;

Rem =========================================================================
Rem Drop NCOMP related classes from 9.0.1
Rem =========================================================================

drop java class "oracle/aurora/deploy/javax_xml_parsers_Installer";
drop java class "oracle/aurora/deploy/oracle_xml_async_Installer";
drop java class "oracle/aurora/deploy/oracle_xml_comp_Installer";
drop java class "oracle/aurora/deploy/oracle_xml_jaxp_Installer";
drop java class "oracle/aurora/deploy/oracle_xml_parser_v2_Installer";
drop java class "oracle/aurora/deploy/org_w3c_dom_Installer";
drop java class "oracle/aurora/deploy/org_w3c_dom_events_Installer";
drop java class "oracle/aurora/deploy/org_w3c_dom_range_Installer";
drop java class "oracle/aurora/deploy/org_w3c_dom_traversal_Installer";
drop java class "oracle/aurora/deploy/org_xml_sax_Installer";
drop java class "oracle/aurora/deploy/org_xml_sax_helpers_Installer";

Rem =========================================================================
Rem END STAGE 1: Remove 9.0.1 XML Classes and packages
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: Initialize with 10.1.0 Classes and packages
Rem =========================================================================

@@initxml.sql

Rem =========================================================================
Rem END STAGE 2: Initialize with 10.1.0 Classes and packages
Rem =========================================================================

