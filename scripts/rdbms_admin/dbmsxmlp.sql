Rem
Rem $Header: rdbms/admin/dbmsxmlp.sql /main/13 2008/07/31 11:10:28 mkandarp Exp $
Rem
Rem dbmsxmlp.sql
Rem
Rem Copyright (c) 2001, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      dbmsxmlp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mkandarp    07/15/08 - 7172798: Add csid to parse
Rem    rxpeters    10/04/04 - add retainCDATASection 
Rem    bkhaladk    10/29/03 - add schema synonyms 
Rem    ataracha    10/15/03 - add error codes
Rem    ataracha    10/14/03 - add writeErrors
Rem    ataracha    10/09/03 - add getBaseDir
Rem    bkhaladk    08/19/03 - add synonym for xmlparser 
Rem    njalali     08/13/02 - removing SET statements
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    nmontoya    12/12/01 - remove set echo on 
Rem    nmontoya    09/05/01 - Merged nmontoya_plsdom2
Rem    nmontoya    08/09/01 - Created
Rem

 
create or replace package xdb.dbms_xmlparser AUTHID CURRENT_USER IS 

/**
 * Parser interface type
 */
TYPE Parser IS RECORD (id dbms_xmldom.domtype);

/**
 * Internal error
 */
INTERNAL_ERR CONSTANT NUMBER := -20000;

/**
 * Other errors
 */
PARSE_ERR CONSTANT NUMBER := -20100;
FILE_ERR CONSTANT NUMBER := -20101;
CONN_ERR CONSTANT NUMBER := -20102;
NULL_ERR CONSTANT NUMBER := -20103;

/**
 * Return the release version of the Oracle XML Parser for PL/SQL
 */
FUNCTION getReleaseVersion RETURN VARCHAR2;

/**
 * Parses xml stored in the given url/file and returns the built DOM Document
 */
FUNCTION parse(url VARCHAR2, csid IN NUMBER := 0 ) 
 RETURN dbms_xmldom.DOMDocument;

/**
 * Returns a new parser instance
 */
FUNCTION newParser RETURN Parser;

PROCEDURE freeParser(p Parser);

/**
 * Parses xml stored in the given url/file
 */
PROCEDURE parse(p Parser, url VARCHAR2, csid IN NUMBER := 0);

/**
 * Parses xml stored in the given buffer
 */
PROCEDURE parseBuffer(p Parser, doc VARCHAR2);

/**
 * Parses xml stored in the given clob
 */
PROCEDURE parseClob(p Parser, doc CLOB);

/**
 * Parses the given dtd
 */
PROCEDURE parseDTD(p Parser, url VARCHAR2, root VARCHAR2, csid IN NUMBER :=0);

/**
 * Parses the given dtd
 */
PROCEDURE parseDTDBuffer(p Parser, dtd VARCHAR2, root VARCHAR2);

/**
 * Parses the given dtd
 */
PROCEDURE parseDTDClob(p Parser, dtd CLOB, root VARCHAR2);

/**
 * Sets base directory used to resolve relative urls
 */
PROCEDURE setBaseDir(p Parser, dir VARCHAR2);

/**
 * Gets base directory used to resolve relative urls
 */
FUNCTION getBaseDir(p Parser) return VARCHAR2;

/**
 * Sets warnings TRUE - on, FALSE - off
 */
PROCEDURE showWarnings(p Parser, yes BOOLEAN);

/**
 * Sets errors to be sent to the specified file
 */
PROCEDURE setErrorLog(p Parser, fileName VARCHAR2);

/**
 * Gets the error log file, if any
 */
FUNCTION getErrorLog(p Parser) RETURN VARCHAR2;

/**
 * Sets whitespace preserving mode TRUE - on, FALSE - off
 */
PROCEDURE setPreserveWhitespace(p Parser, yes BOOLEAN);

/**
 * Sets validation mode TRUE - validating, FALSE - non validation
 */
PROCEDURE setValidationMode(p Parser, yes BOOLEAN);

/**
 * Gets validation mode
 */
FUNCTION getValidationMode(p Parser) RETURN BOOLEAN;

/**
 * Sets DTD for validation purposes - MUST be before an xml document is parsed
 */
PROCEDURE setDoctype(p Parser, dtd dbms_xmldom.DOMDocumentType);

/**
 * Gets DTD parsed - MUST be called only after a dtd is parsed
 */
FUNCTION getDoctype(p Parser) RETURN dbms_xmldom.DOMDocumentType;

/**
 * Gets DOM Document built by the parser - MUST be called only after a
 * document is parsed
 */
FUNCTION getDocument(p Parser) RETURN dbms_xmldom.DOMDocument;

/**
 * Internal function: writes the errors to the errorlog file, if any
 */
PROCEDURE writeErrors(p Parser, err_num NUMBER, err_msg VARCHAR2); 

/**********************************************************/
/* retainCDATASection is a no-op procedure added strictly */
/* for compatibility with XDK. In violation to the W3C    */
/* spec, XDK allows a CDATA section to be parsed. If the  */
/* appl does not want this behavior then a value of FALSE */
/* passed to this procedure. Since XDB will never parse   */
/* CDATA sections, calling this procedure has no effect.  */
/**********************************************************/
PROCEDURE retainCDATASection (p Parser, flag boolean);

end dbms_xmlparser;
/
show errors;


CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLPARSER FOR xdb.dbms_xmlparser
/
CREATE OR REPLACE PUBLIC SYNONYM xmlparser FOR xdb.dbms_xmlparser
/
CREATE OR REPLACE SYNONYM sys.xmlparser FOR xdb.dbms_xmlparser
/
GRANT EXECUTE ON xdb.dbms_xmlparser TO PUBLIC
/
GRANT EXECUTE ON sys.xmlparser TO PUBLIC
/
show errors;






