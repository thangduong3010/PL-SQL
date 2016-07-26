Rem
Rem $Header: dbmsxml.sql 03-mar-2004.15:31:58 jwwarner Exp $
Rem
Rem dbmsxml.sql
Rem
Rem Copyright (c) 1999, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxml.sql - XML support 
Rem
Rem    DESCRIPTION
Rem      Implements the XML support functionality.   They are simply trusted 
Rem    callouts. See the dbmsxml.sql file for more information.
Rem
Rem    NOTES
Rem     This package is automatically converted to a fixed package and
Rem     compiled into the kernel.  
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       jwwarner 03/03/04 - add function to turn on/off invalid char 
Rem       jwwarner 10/21/02 - remove package variable
Rem       zliu     10/08/02 - implement bind value feature for dbms_xmlgen
Rem       jwwarner 10/15/02 - add pretty print setting fcns
Rem       jwwarner 10/11/02 - add xslt functionality to dbms_xmlgen
Rem       zliu     09/23/02 - add getXMLType procedure
Rem       zliu     09/13/02 - implement xml result from hq
Rem       jwwarner 09/30/02 - add DBMS_XMLSTORE package
Rem       jwwarner 04/15/02 - add null handling choices
Rem       mkrishna 09/06/02 - 10i merge
Rem       amanikut 10/15/01 - add convert()
Rem       amanikut 07/25/01 - add newContext(REF CURSOR)
Rem       amanikut 06/26/01 - bug 1840417
Rem       gviswana 05/24/01 - CREATE OR REPLACE SYNONYM
Rem       amanikut 06/25/01 - bug 1840147
Rem       amanikut 03/30/01 - add getXMLType
Rem       amanikut 12/22/00 - Conform DBMS_XMLGEN with Query
Rem       amanikut 11/02/00 - conform DBMS_XMLGen with DBMS_XMLQuery
Rem       mkrishna 06/27/00 - 
Rem       mkrishna 06/26/00 - add new function
Rem       mkrishna 05/18/00 - add more functions 
Rem       mkrishna 05/08/00 - change getCtx to getContext
Rem       mkrishna 05/05/00 - use AUTHID CURRENT_USER for package
Rem       mkrishna 12/28/99 - add more functions 
Rem       mkrishna 12/24/99 - DBMS_XML package
Rem                12/24/99 - Created
Rem

Rem The C version for the XML generation 

-----------------------------------------------------------
-- DBMS_XMLGEN package
-----------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_xmlgen AUTHID CURRENT_USER AS 

  -- context handle
  SUBTYPE ctxHandle IS NUMBER;
  SUBTYPE ctxType IS NUMBER;
  SUBTYPE conversionType IS NUMBER;

  TYPE PARAM_HASH IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(32);

  -- DTD or schema specifications
  NONE CONSTANT NUMBER := 0;
  DTD CONSTANT NUMBER := 1;
  SCHEMA CONSTANT NUMBER := 2;

  -- conversion type
  ENTITY_ENCODE CONSTANT conversionType := 0;
  ENTITY_DECODE CONSTANT conversionType := 1;

  -- constants for null handling
  DROP_NULLS CONSTANT NUMBER := 0;
  NULL_ATTR  CONSTANT NUMBER := 1;
  EMPTY_TAG  CONSTANT NUMBER := 2;

  -- procedure to create the XML document
  FUNCTION newContext(queryString IN varchar2) RETURN ctxHandle;

  FUNCTION newContext(queryString IN SYS_REFCURSOR) RETURN ctxHandle;

  FUNCTION newContextFromHierarchy(queryString IN varchar2) RETURN ctxHandle;

  -- set the row tag name
  PROCEDURE setRowTag(ctx IN ctxHandle, rowTagName IN varchar2);

  -- set the rowset tag name
  PROCEDURE setRowSetTag(ctx IN ctxHandle, rowSetTagName IN varchar2);

  -- XSLT support
  PROCEDURE setXSLT(ctx IN ctxType, stylesheet IN CLOB);
  PROCEDURE setXSLT(ctx IN ctxType, stylesheet IN XMLType);
  PROCEDURE setXSLT(ctx IN ctxType, uri IN VARCHAR2);
  PROCEDURE setXSLTParam(ctx IN ctxType,name IN VARCHAR2,value IN VARCHAR2);
  PROCEDURE removeXSLTParam(ctx IN ctxType, name IN VARCHAR2);

  PROCEDURE getXML(ctx IN ctxHandle, tmpclob IN OUT NOCOPY clob, 
                   dtdOrSchema IN number := NONE);

  FUNCTION getXML(ctx IN ctxHandle, dtdOrSchema IN number := NONE) 
    RETURN clob;
    
  FUNCTION getXML(sqlQuery IN VARCHAR2, dtdOrSchema IN NUMBER := NONE) 
    RETURN CLOB;
    
  PROCEDURE getXMLType(ctx IN ctxHandle, tmpxmltype IN OUT NOCOPY xmltype, 
                   dtdOrSchema IN number := NONE);

  FUNCTION getXMLType(ctx IN ctxHandle, dtdOrSchema IN number:= NONE)
        RETURN sys.XMLType;

  FUNCTION getXMLType(sqlQuery IN VARCHAR2, dtdOrSchema IN NUMBER := NONE)
        RETURN sys.XMLType;

  -- returns the number of rows processed by the last call to getXML()
  FUNCTION getNumRowsProcessed(ctx IN ctxHandle) RETURN number;

  PROCEDURE setMaxRows(ctx IN ctxHandle, maxRows IN number);
  PROCEDURE setSkipRows(ctx IN ctxHandle, skipRows IN number);

  -- This procedure sets whether you want to replace characters such as 
  -- <. > etc.. by their codes. (lt;, gt; etc..)
  PROCEDURE setConvertSpecialChars(ctx IN ctxHandle, replace IN boolean);

  -- This procedure sets whether you want to check for invalid characters
  -- such as the null character.
  PROCEDURE setCheckInvalidChars(ctx IN ctxHandle, chk IN boolean);

  -- This forces the use of the _ITEM for collectionitems. The default is to
  -- set the underlying object type name  for collection base elements.
  PROCEDURE useItemTagsForColl(ctx IN ctxHandle);

  -- reset the query to start fetching from the begining
  PROCEDURE restartQuery(ctx IN ctxHandle);

  PROCEDURE closeContext(ctx IN ctxHandle);

  -- conversion functions
  FUNCTION convert(xmlData IN varchar2, flag IN NUMBER := ENTITY_ENCODE) 
           return varchar2;

  FUNCTION convert(xmlData IN CLOB, flag IN NUMBER := ENTITY_ENCODE) 
           return CLOB;

  -- This procedure sets how you want nulls handled during generation
  PROCEDURE setNullHandling(ctx IN ctxHandle, flag IN NUMBER);

  PROCEDURE useNullAttributeIndicator(ctx IN ctxHandle,
                                      attrind IN boolean := TRUE);

  PROCEDURE setBindValue(ctx IN ctxHandle, bindName IN VARCHAR2, 
    bindValue IN VARCHAR2);

  PROCEDURE clearBindValues(ctx IN ctxHandle);

  -- Procedures for setting pretty print settings
  PROCEDURE setPrettyPrinting(ctx IN ctxHandle, pp IN boolean);
  PROCEDURE setIndentationWidth(ctx IN ctxHandle, width IN NUMBER);

END dbms_xmlgen;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLGEN FOR DBMS_XMLGEN;

GRANT EXECUTE ON DBMS_XMLGEN TO PUBLIC;

-----------------------------------------------------------
-- DBMS_XMLSTORE package
-----------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_xmlstore AUTHID CURRENT_USER AS 

  -- context handle
  SUBTYPE ctxHandle IS NUMBER;
  SUBTYPE ctxType IS NUMBER;
  SUBTYPE conversionType IS NUMBER;

  -------------------- constructor/destructor functions ---------------------
  FUNCTION newContext(targetTable IN VARCHAR2) RETURN ctxHandle;
  PROCEDURE closeContext(ctxHdl IN ctxHandle);

  -- set the row tag name
  PROCEDURE setRowTag(ctx IN ctxHandle, rowTagName IN varchar2);

  -- set the columns to update. Relevant for insert and update routines..
  PROCEDURE setUpdateColumn(ctxHdl IN ctxType, colName IN VARCHAR2);
  PROCEDURE clearUpdateColumnList(ctxHdl IN ctxType);

  -- set the key column name to be used for updates and deletes.
  PROCEDURE setKeyColumn(ctxHdl IN ctxType, colName IN VARCHAR2);
  PROCEDURE clearKeyColumnList(ctxHdl IN ctxType);

  ------------------- save ----------------------------------------------------
  -- insertXML
  FUNCTION  insertXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER;
  FUNCTION  insertXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER;
  FUNCTION  insertXML(ctxHdl IN ctxType, xDoc IN XMLTYPE) RETURN NUMBER;
  -- updateXML
  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER;
  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER;
  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN XMLTYPE) RETURN NUMBER;
  -- deleteXML
  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER;
  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER;
  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN XMLTYPE) RETURN NUMBER;

END dbms_xmlstore;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLSTORE FOR DBMS_XMLSTORE;

GRANT EXECUTE ON DBMS_XMLSTORE TO PUBLIC;