Rem
Rem $Header: catxdbdbca.sql 22-jan-2002.15:57:47 spannala Exp $
Rem
Rem catxdbdbca.sql
Rem
Rem  Copyright (c) Oracle Corporation 2002. All Rights Reserved.
Rem
Rem    NAME
Rem      catxdbdbca.sql - XDB protocol port registration.
Rem
Rem    DESCRIPTION
Rem      This file changes the ports on which the FTP and HTTP
Rem      servers (protocol interpreters) run. This script MUST be run
Rem      as SYS or XDB.
Rem
Rem    NOTES
Rem	 The port change is effective only with proper setting of the
Rem      listener.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    01/16/02 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

define ftpport  = &1
define httpport = &2
Rem Create a function to traverse the dom elements.
CREATE OR REPLACE FUNCTION traverseDom
          (parnode dbms_xmldom.DOMNode, pathSeg VARCHAR2) 
          RETURN dbms_xmldom.DOMNode IS
nodeList    dbms_xmldom.DOMNodeList;
anElement   dbms_xmldom.DOMElement;
aNode       dbms_xmldom.DOMNode;
BEGIN
  -- Convert the passed in dom node to an element
  anElement := dbms_xmldom.makeElement(parnode);

  -- Select the path segment requested by the user
  nodeList  := dbms_xmldom.getChildrenByTagName(anElement, pathSeg);

  -- get the first node out of the list
  aNode := dbms_xmldom.item(nodeList, 0);

  -- return that node (ignore errors here).
  return aNode;
END;
/

declare
   configxml    sys.xmltype;
   configdomdoc dbms_xmldom.DOMDocument;
   textNode     dbms_xmldom.DOMNode;
   aNode        dbms_xmldom.DOMNode;
   protNode     dbms_xmldom.DOMNode;
   anElement    dbms_xmldom.DOMElement;
   listOfNodes  dbms_xmldom.DOMNodeList;
   aString      VARCHAR2(100);
begin

-- Select the resource and set it into the config
select sys_nc_rowinfo$ into configxml from xdb.xdb$config ;

-- Create a dom document out of the xmltype
configdomdoc := dbms_xmldom.newDOMDocument(configxml);

-- Get the root Element of the dom
anElement := dbms_xmldom.getDocumentElement(configdomdoc);

-- Convert this to a node
aNode := dbms_xmldom.makeNode(anElement);

-- Traverse One Element Down At A Time.
aNode := traverseDom(aNode, 'sysconfig');
protNode := traverseDom(aNode, 'protocolconfig');

-- Set the FTP port by traversing /ftpconfig/ftp-port
aNode := traverseDom(protNode, 'ftpconfig');
aNode := traverseDom(aNode, 'ftp-port');
textNode := dbms_xmldom.getFirstChild(aNode);
dbms_xmldom.setNodeValue(textNode, &ftpport);

-- Set the FTP port by traversing /ftpconfig/ftp-port
aNode := traverseDom(protNode, 'httpconfig');
aNode := traverseDom(aNode, 'http-port');
textNode := dbms_xmldom.getFirstChild(aNode);
dbms_xmldom.setNodeValue(textNode, &httpport);

dbms_xdb.cfg_update(configxml);
commit;

end;
/


drop function traverseDom;
