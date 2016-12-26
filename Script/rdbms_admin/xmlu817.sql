Rem
Rem $Header: xmlu817.sql 18-sep-2003.15:57:30 mjaeger Exp $
Rem
Rem xmlu817.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      xmlu817.sql - Upgrade from 8.1.7 database
Rem
Rem    DESCRIPTION
Rem       Upgrade from 8.1.7 database
Rem
Rem MODIFIED (MM/DD/YY)
Rem mjaeger   09/18/03 - bug 3015638: add parts for XSU
Rem kkarun    06/05/03 - fix bug 2973904
Rem kkarun    04/16/03 - use execute instead of call
Rem kkarun    04/14/03 - update upgraded calls
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    12/12/02 - don't remove jserver system classes
Rem kkarun    12/04/02 - update version
Rem kkarun    11/12/02 - update version
Rem kkarun    05/30/02 - update to 10i
Rem kkarun    05/30/02 - remove plsql
Rem tyu       03/19/02 - drop xsu
Rem kkarun    02/13/02 - update version
Rem kkarun    12/17/01 - split drop  package v2
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    01/09/01 - XML Upgrade scripts
Rem kkarun    01/09/01 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: Remove 8.1.7 XML Classes and packages
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

EXECUTE xdk_drop_package('oracle/xml/async');
EXECUTE xdk_drop_package('oracle/xml/classgen');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/XML');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/XSL');
EXECUTE xdk_drop_package('oracle/xml/parser/v2');
EXECUTE xdk_drop_package('oracle/xml/parser/plsql');
EXECUTE xdk_drop_package('oracle/xml/sql');
EXECUTE xdk_drop_package('OracleXML');

EXECUTE dbms_java.dropjava('xmlparser_2.0.2.9_production');

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
Rem END STAGE 1: Remove 8.1.7 XML Classes and packages
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: Initialize with 10.1.0 Classes and packages
Rem =========================================================================

@@initxml.sql

Rem =========================================================================
Rem END STAGE 2: Initialize with 10.1.0 Classes and packages
Rem =========================================================================

