Rem
Rem $Header: rdbms/admin/dbmsxslp.sql /main/14 2008/12/11 13:33:31 llsun Exp $
Rem
Rem dbmsxslp.sql
Rem
Rem Copyright (c) 2001, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxslp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mkandarp    12/08/06 - 5667235: Add new API to get output method for doc
Rem                           2 clob
Rem    rxpeters    05/11/04 - remove processxslu 
Rem    ataracha    11/10/03 - add url2clob
Rem    ataracha    10/24/03 - add function valueOf
Rem    bkhaladk    10/29/03 - add schema synonyms 
Rem    ataracha    10/15/03 - add error codes
Rem    bkhaladk    08/19/03 - add synonym for xslprocessor 
Rem    nmontoya    11/27/02 - ADD namespace awareness IN dbms_xslprocessor
Rem    abagrawa    09/19/02 - Fix read2clob
Rem    njalali     08/13/02 - removing SET statements
Rem    thoang      07/16/02 - Added charset support for clob2file 
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    nmontoya    12/12/01 - remove set echo on
Rem    nmontoya    09/05/01 - Merged nmontoya_plsdom2
Rem    nmontoya    08/09/01 - Created
Rem


create or replace package xdb.dbms_xslprocessor authid current_user as

/**
 * Processor interface type
 */
TYPE Processor IS RECORD (id dbms_xmldom.domtype);
/* SUBTYPE Processor IS RAW(8); */

/**
 * Stylesheet interface type
 */
TYPE Stylesheet IS RECORD (id dbms_xmldom.domtype);
/* SUBTYPE Stylesheet IS RAW(8); */

/**
 * Internal error
 */
INTERNAL_ERR CONSTANT NUMBER := -20000;

/**
 * Other errors
 */
PROCESSOR_ERR CONSTANT NUMBER := -20100;
FILE_ERR CONSTANT NUMBER := -20101;
CONN_ERR CONSTANT NUMBER := -20102;
NULL_ERR CONSTANT NUMBER := -20103;

/**
 * Read from a file to a clob, return clob
 */
function read2clob(flocation VARCHAR2, fname VARCHAR2, csid IN NUMBER := 0) 
RETURN clob;

/**
 * Read from url - file/http/XDB/oradb, return clob
 */
FUNCTION url2clob(url VARCHAR2, basedir VARCHAR2, csid IN NUMBER :=0)
RETURN clob;

/**
 * Write to url
 */
PROCEDURE clob2url(cl CLOB, url VARCHAR2, basedir VARCHAR2, 
                   csid IN NUMBER := 0);

/**
 * Write from a clob to a file with given character encoding.
 * If csid is zero or not given then the file will be in the db charset.
 */
procedure clob2file(cl clob, flocation VARCHAR2, fname VARCHAR2,
                    csid IN NUMBER := 0);

/**
 * Returns a new processor instance
 */
FUNCTION newProcessor RETURN Processor;

/**
 * Free XSL Processor
 */
PROCEDURE freeProcessor(p Processor);

/**
 * Transforms input XML document using given DOMDocument and stylesheet
 */
FUNCTION processXSL(p Processor, ss Stylesheet, xmldoc dbms_xmldom.DOMDocument)
return dbms_xmldom.DOMDocumentFragment;

/**
 * Transforms input XML document using given Doc as CLOB
 */
FUNCTION processXSL(p Processor, ss Stylesheet, cl clob)
return dbms_xmldom.DOMDocumentFragment;

/**
 * Transforms input XML document using given DOMDocument and stylesheet
 * and writes output to a file
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                   xmldoc dbms_xmldom.DOMDocument, dir varchar2, fileName varchar2);

/**
 * Transforms input XML document using given as URL and stylesheet
 * and writes output to a file
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                   url varchar2, dir varchar2, fileName varchar2);

/**
 * Transforms input XML document using given DOMDocument and stylesheet
 * and writes output to a buffer
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                    xmldoc dbms_xmldom.DOMDocument, buffer in out varchar2);

/**
 * Transforms input XML document using given DOMDocument and stylesheet
 * and writes output to a CLOB
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                    xmldoc dbms_xmldom.DOMDocument, cl in out clob);

/**
 * Transforms input XML document using given DOMDocument and stylesheet
 * and writes output to a CLOB. Provides information if style sheet output
 * method is xml or not.
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                     xmldoc dbms_xmldom.DOMDocument,
                     cl in out clob, isoutputxml out boolean);

/**
/**
 * Transforms input XML document fragment using given DOMDocumentFragment and 
 * stylesheet
 */
FUNCTION processXSL(p Processor, ss Stylesheet, 
                   xmldf dbms_xmldom.DOMDocumentFragment) 
return dbms_xmldom.DOMDocumentFragment;

/**
 * Transforms input XML document fragment using given DOMDocumentFragment 
 * and stylesheet and writes output to a file
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
            xmldf dbms_xmldom.DOMDocumentFragment, dir varchar2, fileName varchar2);

/**
 * Transforms input XML document fragment using given DOMDocumentFragment 
 * and stylesheet and writes output to a buffer
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                    xmldf dbms_xmldom.DOMDocumentFragment, buffer in out varchar2);

/**
 * Transforms input XML document fragment using given DOMDocumentFragment 
 * and stylesheet and writes output to a CLOB
 */
PROCEDURE processXSL(p Processor, ss Stylesheet, 
                    xmldf dbms_xmldom.DOMDocumentFragment, cl in out clob);

/**
 * Sets errors to be sent to the specified file
 */
PROCEDURE setErrorLog(p Processor, fileName VARCHAR2);

/**
 * Sets warnings TRUE - on, FALSE - off
 */
PROCEDURE showWarnings(p Processor, yes BOOLEAN);

/**
 * Create a new stylesheet using the given DOMDocument and base directory URL
 */
FUNCTION newStylesheet(xmldoc dbms_xmldom.DOMDocument, refurl varchar2) 
return Stylesheet;

/**
 * Create a new stylesheet using the given input file and base directory URLs
 */
FUNCTION newStylesheet(inp varchar2, refurl varchar2) return Stylesheet;

PROCEDURE freeStylesheet(ss Stylesheet);

/**
 * Sets the value of a top-level stylesheet parameter.
 * The parameter value is expected to be a valid XPath expression (note 
 * that string literal values would therefore have to be explicitly quoted).
 */
PROCEDURE setParam(ss Stylesheet, name VARCHAR2, val VARCHAR2);

/**
 * Remove a top-level stylesheet parameter.
 */
PROCEDURE removeParam(ss Stylesheet, name VARCHAR2);

/**
 * Resets the top-level stylesheet parameters.
 */
PROCEDURE resetParams(ss Stylesheet);

/**
 * Transforms a node in the tree using the given stylesheet
 */
FUNCTION transformNode(n dbms_xmldom.DOMNode, ss Stylesheet) 
return dbms_xmldom.DOMDocumentFragment;

/**
 * Selects nodes from the tree which match the given pattern
 */
FUNCTION selectNodes(n dbms_xmldom.DOMNode, pattern VARCHAR2, 
                     namespace IN VARCHAR2 := NULL) 
return dbms_xmldom.DOMNodeList;

/**
 * Selects the first node from the tree that matches the given pattern
 */
FUNCTION selectSingleNode(n dbms_xmldom.DOMNode, pattern varchar2, 
                          namespace IN VARCHAR2 := NULL) 
return dbms_xmldom.DOMNode;

/**
 * Retrieves the value of the first node from the tree that matches the given 
 * pattern
 */
PROCEDURE valueOf(n dbms_xmldom.DOMNode, pattern VARCHAR2, val OUT VARCHAR2, 
                  namespace IN VARCHAR2 := NULL);
FUNCTION valueOf(n xmldom.DOMNode, pattern varchar2,
                 namespace IN VARCHAR2 := NULL) return VARCHAR2 ;
end dbms_xslprocessor;
/
show errors;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_xslprocessor FOR xdb.dbms_xslprocessor 
/
CREATE OR REPLACE PUBLIC SYNONYM xslprocessor FOR xdb.dbms_xslprocessor 
/
CREATE OR REPLACE SYNONYM sys.xslprocessor FOR xdb.dbms_xslprocessor 
/
GRANT EXECUTE ON xdb.dbms_xslprocessor TO PUBLIC
/
GRANT EXECUTE ON sys.xslprocessor TO PUBLIC
/
GRANT EXECUTE ON dbms_xslprocessor TO PUBLIC
/
show errors;
/

