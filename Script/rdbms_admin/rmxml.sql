Rem
Rem $Header: xdk/admin/rmxml.sql /st_xdk_11.2.0/1 2013/03/01 15:06:05 mjaeger Exp $
Rem
Rem rmxml.sql
Rem
Rem Copyright (c) 1999, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rmxml.sql - ReMove XML components from the database
Rem
Rem    DESCRIPTION
Rem      Removes xml components from the the database
Rem
Rem    NOTES
Rem
Rem MODIFIED (MM/DD/YY)
Rem mjaeger   02/26/13 - bug 16357699: drop only XDK classes
Rem tyu       11/08/06 - lrg 2625031
Rem bihan     10/25/06 - rm org/xml/sax
Rem mdmehta   02/09/06 - mdmehta_binxml_java_fusionsecurity_only
Rem kmuthiah  02/23/05 - add xquery too
Rem kkarun    05/12/04 - update for 10g
Rem kkarun    12/11/03 - update packages
Rem bihan     12/15/03 - add oracle/xml/jdwp
Rem mjaeger   09/18/03 - bug 3015638: add removal of XSU parts
Rem kkarun    04/16/03 - update pkg list
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    12/12/02 - don't remove jserver system classes
Rem kkarun    11/12/02 - update version
Rem kkarun    09/26/02 - remove classgen
Rem kkarun    10/02/02 - update version
Rem kkarun    10/02/02 - update version
Rem kkarun    05/30/02 - remove plsql
Rem kkarun    12/17/01 - split drop  package v2
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    04/04/01 - add xsu.
Rem kkarun    07/13/00 - fix paths
Rem kkarun    04/07/00 - update rmxml.sql
Rem nramakri  10/21/99 - Created
Rem

-- Turn on options so that we can see the output from -verbose.

-- Ideally, we would like to see the verbose output.
-- But if we enable these flags so that we can see it,
-- then we end up with warnings because more than one of the jar files
-- contain the resource called META-INF/MANIFEST.MF.
-- All such jar files have the same resource, with the same name.
-- If we drop it more than once, then dbms_java.dropjava()
-- prints a warning message that causes a dif in regression testing.
-- Ideally, the regression test should filter out such benign warnings.

-- set serveroutput on size unlimited;
-- CALL dbms_java.set_output(1000000);

EXECUTE dbms_registry.removing('XML');

-- The undocumented flag "-install" is supposed to cause dropjava
-- to ignore any Java classes which are in classes.bin (i.e., classes
-- that belong to the Java runtime in the database).
-- That includes the operation of removing a synonym for such a class.

-- Drop Java packages.
create or replace procedure xdk_drop_package(pkg varchar2) is
   CURSOR classes is
      select dbms_java.longname(object_name) class_name
      from all_objects
      where object_type = 'JAVA CLASS'
        and dbms_java.longname(object_name) like pkg || '%';
begin
   FOR class IN classes LOOP
      dbms_java.dropjava('-verbose -synonym -install ' || class.class_name);
   END LOOP;
end xdk_drop_package;
/

show errors;

-- bug 16357699:
-- Use the jar files that were loaded to drive the dropjava,
-- instead of the original method that used patterns for class names.

-- We have to reset the Java session,
-- because otherwise the dbms_java.dropjava() sometimes
-- prints error messages like these, for reasons unknown:

-- ERROR at line 1:
-- ORA-29549: class SYS.oracle/xml/parser/v2/XMLDocument$NodeList_cache has
-- changed, Java session state cleared
-- ORA-06512: at "SYS.DBMS_JAVA", line 667

create or replace procedure xdk_drop_jar(jar varchar2) is
  retval varchar2(1000);
  cmd    varchar2(1000);
begin
  retval := dbms_java.endsession_and_related_state();
  dbms_output.put_line( 'retval from endsession: ' || retval ) ;
  -- dbms_java.set_output(1000000);
  cmd := '-verbose -synonym -install ' || jar;
  dbms_java.dropjava(cmd);
end;
/

show errors;

EXECUTE xdk_drop_jar('jlib/xquery.jar');

EXECUTE xdk_drop_jar('lib/xsu12.jar');

EXECUTE xdk_drop_jar('lib/xmlparserv2.jar rdbms/jlib/xdb.jar');

EXECUTE xdk_drop_jar('rdbms/jlib/servlet.jar');

-- bug 16357699:
-- Do NOT drop classes that do not belong to the XDK for Java,
-- such as packages that start with javax.xml, org.xml.sax, or org.w3c.dom.

-- XDK for Java:
EXECUTE xdk_drop_package('oracle/xml/async/');
EXECUTE xdk_drop_package('oracle/xml/binxml/');
EXECUTE xdk_drop_package('oracle/xml/comp/');
EXECUTE xdk_drop_package('oracle/xml/jaxp/');
EXECUTE xdk_drop_package('oracle/xml/jdwp/');
EXECUTE xdk_drop_package('oracle/xml/mesg/');
EXECUTE xdk_drop_package('oracle/xml/parser/schema/');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/');
EXECUTE xdk_drop_package('oracle/xml/scalable/');
EXECUTE xdk_drop_package('oracle/xml/sql/');
EXECUTE xdk_drop_package('oracle/xml/util/');
EXECUTE xdk_drop_package('oracle/xml/xpath/');
EXECUTE xdk_drop_package('oracle/xml/xqxp/');
EXECUTE xdk_drop_package('oracle/xml/xslt/');

-- XSU:
EXECUTE xdk_drop_package('OracleXML');
EXECUTE xdk_drop_package('OracleXMLStore');

-- XDB:
EXECUTE xdk_drop_package('oracle/xdb/');

-- XQuery:
EXECUTE xdk_drop_package('oracle/xquery/');

BEGIN
  dbms_java.dropjava('-verbose .xdk_version_' ||
                     dbms_registry.release_version || '_' ||
                     dbms_registry.release_status);
END;
/

drop procedure xdk_drop_package;
drop procedure xdk_drop_jar;

EXECUTE dbms_registry.removed('XML');

-- The following lines are necessary in order to turn off
-- the call to dbms_java.set_output() that we did earlier.

declare
  retval varchar2(1234);
begin
  retval := dbms_java.endsession_and_related_state();
  dbms_output.put_line('retval from endsession: ' || retval);
end ;
/

-- Reset to the default.
set serveroutput off;

Rem end of rmxml.sql

