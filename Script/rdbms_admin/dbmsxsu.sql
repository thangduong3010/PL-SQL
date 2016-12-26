Rem
Rem $Header: dbmsxsu.sql 03-oct-2005.12:03:08 mparthas Exp $
Rem
Rem dbmsxsu.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxsu.sql - create PL/SQL packages for XSU
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem MODIFIED (MM/DD/YY)
Rem mparthas  10/03/05 - 4640092: Add clearBindValues() 
Rem rangrish  08/09/04 - add useDBDates to save 
Rem mjaeger   01/26/04 - bug 1516368: query: check for invalid XML characters 
Rem mjaeger   09/30/03 - bug 3015638: move XSU source from RDBMS vob to XDK
Rem mjaeger   09/18/03 - bug 3015638: copy from rdbms vob to xdk vob
Rem mjaeger   09/18/03 - Created in xdk vob for bug 3015638
Rem vnimani   03/08/02 - add resetResultSet
Rem vnimani   04/27/01 - fix bug 1731250 -- add setPreserveWhitespace
Rem vnimani   03/20/01 - bug 1629260 -- add setSQLToXMLNameEscaping
Rem vnimani   12/18/00 - fix 1390272: make dbms xmlgen & xmlquery compat.
Rem vnimani   10/23/00 - add suppor for XSLT parameters
Rem vnimani   10/18/00 - add xmlgen.getxml like call
Rem vnimani   10/16/00 - ora600-kgmexchi11 workaround: declare ALL methods
Rem vnimani   08/24/00 - revert to no encoding tag by default
Rem vnimani   08/04/00 - add support for XSLT in dbms_xmlsave
Rem vnimani   06/23/00 - caching to true in dbms_lob.createtemporary
Rem vnimani   06/21/00 - fix call to setDataHeader
Rem vnimani   06/13/00 - add xslt support
Rem vnimani   05/17/00 - Created
Rem

rem SET ECHO ON
rem SET FEEDBACK 1
rem SET NUMWIDTH 10
rem SET LINESIZE 80
rem SET TRIMSPOOL ON
rem SET TAB OFF
rem SET PAGESIZE 100

CREATE OR REPLACE PACKAGE DBMS_XMLQUERY AUTHID CURRENT_USER AS

  -- types
  SUBTYPE ctxType IS NUMBER;                                 /* context type */
  SUBTYPE ctxHandle IS NUMBER;

  DEFAULT_ROWSETTAG   CONSTANT VARCHAR2(6) := 'ROWSET';         /* rowsettag */
  DEFAULT_ERRORTAG    CONSTANT VARCHAR2(5) := 'ERROR';          /* error tag */
  DEFAULT_ROWIDATTR   CONSTANT VARCHAR2(3) := 'NUM';          /* Row ID attr */
  DEFAULT_ROWTAG      CONSTANT VARCHAR2(3) := 'ROW';               /* rowtag */
  DEFAULT_DATE_FORMAT CONSTANT VARCHAR2(21):= 'MM/dd/yyyy HH:mm:ss';

  ALL_ROWS            CONSTANT NUMBER      := -1;      /* NO MAX, render all */

  NONE                CONSTANT NUMBER      := 0;                  /* NO META */
  DTD                 CONSTANT NUMBER      := 1;               /* META = DTD */
  SCHEMA              CONSTANT NUMBER      := 2;            /* META = SCHEMA */

  LOWER_CASE          CONSTANT NUMBER      := 1;               /* LOWER case */
  UPPER_CASE          CONSTANT NUMBER      := 2;               /* UPPER case */

  -- used to signal that the DB encoding is to be used
  DB_ENCODING          CONSTANT VARCHAR2(1) := '_';

  ----------------------------- misc functions ------------------------------
  PROCEDURE getVersion;

  -------------------- constructor/destructor functions ---------------------
  FUNCTION newContext(sqlQuery IN VARCHAR2) RETURN ctxType;
  FUNCTION newContext(sqlQuery IN CLOB) RETURN ctxType;
  PROCEDURE closeContext(ctxHdl IN ctxType);

  -------------------- parameters to the XML generation engine ----------------
  PROCEDURE setRowsetTag(ctxHdl IN ctxType, tag IN VARCHAR2);
  PROCEDURE setRowTag(ctxHdl IN ctxType, tag IN VARCHAR2);
  PROCEDURE setErrorTag(ctxHdl IN ctxType, tag IN VARCHAR2);

  PROCEDURE setRowIdAttrName(ctxHdl IN ctxType, attrName IN VARCHAR2);
  PROCEDURE setRowIdAttrValue(ctxHdl IN ctxType, colName IN VARCHAR2);
  PROCEDURE setCollIdAttrName(ctxHdl IN ctxType, attrName IN VARCHAR2);
  PROCEDURE useTypeForCollElemTag(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE useNullAttributeIndicator(ctxHdl IN ctxType, flag IN BOOLEAN := true);

  PROCEDURE setSQLToXMLNameEscaping(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE setTagCase(ctxHdl IN ctxType, tCase IN NUMBER);
  PROCEDURE setDateFormat(ctxHdl IN ctxType, mask IN VARCHAR2);

  PROCEDURE setMaxRows (ctxHdl IN ctxType, rows IN NUMBER);
  PROCEDURE setSkipRows(ctxHdl IN ctxType, rows IN NUMBER);

  PROCEDURE setStylesheetHeader(ctxHdl IN ctxType, uri IN VARCHAR2, type IN VARCHAR2 := 'text/xsl');
  PROCEDURE setXSLT(ctxHdl IN ctxType,uri IN VARCHAR2,ref IN VARCHAR2 := null);
  PROCEDURE setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2 := null);
  PROCEDURE setXSLTParam(ctxHdl IN ctxType,name IN VARCHAR2,value IN VARCHAR2);
  PROCEDURE removeXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2);

  PROCEDURE setStrictLegalXMLCharCheck(ctxHdl IN ctxType, flag IN BOOLEAN := true);

  PROCEDURE setEncodingTag(ctxHdl IN ctxType, enc IN VARCHAR2 := DB_ENCODING);

  PROCEDURE setBindValue(ctxHdl IN ctxType, bindName IN VARCHAR2, bindValue IN VARCHAR2);
  PROCEDURE clearBindValues(ctxHdl IN ctxType);

  PROCEDURE setMetaHeader(ctxHdl IN ctxType, header IN CLOB := null);
  PROCEDURE setDataHeader(ctxHdl IN ctxType, header IN CLOB := null, tag IN VARCHAR2 := null);

  PROCEDURE setRaiseException(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE setRaiseNoRowsException(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE propagateOriginalException(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE getExceptionContent(ctxHdl IN ctxType, errNo OUT NUMBER, errMsg OUT VARCHAR2);

  ------------------- generation ----------------------------------------------
  FUNCTION  getDTD(ctxHdl IN ctxType, withVer IN BOOLEAN := false) RETURN CLOB;
  PROCEDURE getDTD(ctxHdl IN ctxType, xDoc IN CLOB, withVer IN BOOLEAN := false);

  FUNCTION  getXML(ctxHdl IN ctxType, metaType IN NUMBER := NONE) RETURN CLOB;
  PROCEDURE getXML(ctxHdl IN ctxType, xDoc IN CLOB, metaType IN NUMBER := NONE);
  FUNCTION  getXML(sqlQuery IN VARCHAR2, metaType IN NUMBER := NONE) RETURN CLOB;
  FUNCTION  getXML(sqlQuery IN CLOB, metaType IN NUMBER := NONE) RETURN CLOB;

  PROCEDURE resetResultSet(ctxHdl IN ctxType);
  FUNCTION  getNumRowsProcessed(ctxHdl IN ctxType) RETURN NUMBER;

  -------private method declarations------------------------------------------
  -- we must do this as a bug workaround; otherwise we get ora-600 [kgmexchi11]
  PROCEDURE p_useTypeForCollElemTag(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_useNullAttrInd(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setSQLToXMLNameEsc(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setStylesheetHeader(ctxHdl IN ctxType, uri IN VARCHAR2, type IN VARCHAR2);
  PROCEDURE p_setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2);
  PROCEDURE p_setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2);
  PROCEDURE p_setStrictLegalXMLCharCheck(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setEncodingTag(ctxHdl IN ctxType, enc IN VARCHAR2);
  PROCEDURE p_setMetaHeader(ctxHdl IN ctxType, header IN CLOB);
  PROCEDURE p_setDataHeader(ctxHdl IN ctxType, header IN CLOB,tag IN VARCHAR2);
  PROCEDURE p_setRaiseException(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setRaiseNoRowsExc(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_propOrigExc(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_getDTD(ctxHdl IN ctxType, xDoc IN CLOB, withVer IN NUMBER);
  PROCEDURE p_getXML(ctxHdl IN ctxType, xDoc IN CLOB, metaType IN NUMBER);

END dbms_xmlquery;
/
show errors;

CREATE OR REPLACE PACKAGE BODY DBMS_XMLQUERY AS

  procedure getVersion IS
  begin
    DBMS_OUTPUT.PUT_LINE(CHR(0));
    DBMS_OUTPUT.PUT_LINE(CHR(0));
    DBMS_OUTPUT.PUT_LINE('XSU Version                ' ||
                         'Owner         Timestamp');
    DBMS_OUTPUT.PUT_LINE('-------------------------- ' ||
                         '------------- ----------------');

    FOR i IN (select object_name, owner, timestamp
              from all_objects
              where object_name like '%XSU%VERSION%')
    LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(i.object_name,27) ||
                           RPAD(i.owner,14) || SUBSTR(i.timestamp,1,16));
    END LOOP;
      DBMS_OUTPUT.NEW_LINE;
  end getVersion;

  FUNCTION newContext(sqlQuery IN VARCHAR2) return ctxType
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.newContext(java.lang.String) return int';

  FUNCTION newContext(sqlQuery IN CLOB) return ctxType
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.newContext(oracle.sql.CLOB) return int';

  PROCEDURE closeContext(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.closeContext(int)';

  PROCEDURE setRowsetTag(ctxHdl IN ctxType, tag IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRowsetTag(int, java.lang.String)';

  PROCEDURE setRowTag(ctxHdl IN ctxType, tag IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRowTag(int, java.lang.String)';

  PROCEDURE setErrorTag(ctxHdl IN ctxType, tag IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setErrorTag(int, java.lang.String)';

  PROCEDURE setRowIdAttrName(ctxHdl IN ctxType, attrName IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRowIdAttrName(int, java.lang.String)';

  PROCEDURE setRowIdAttrValue(ctxHdl IN ctxType, colName IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRowIdAttrValue(int, java.lang.String)';


  PROCEDURE setCollIdAttrName(ctxHdl IN ctxType, attrName IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setCollIdAttrName(int, java.lang.String)';


  PROCEDURE p_useTypeForCollElemTag(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.useTypeForCollElemTag(int,byte)';

  PROCEDURE useTypeForCollElemTag(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_useTypeForCollElemTag(ctxHdl, 1);
    else
      p_useTypeForCollElemTag(ctxHdl, 0);
    end if;
  end useTypeForCollElemTag;


  PROCEDURE p_useNullAttrInd(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.useNullAttributeIndicator(int, byte)';

  PROCEDURE useNullAttributeIndicator(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_useNullAttrInd(ctxHdl, 1);
    else
      p_useNullAttrInd(ctxHdl, 0);
    end if;
  end useNullAttributeIndicator;

  PROCEDURE p_setSQLToXMLNameEsc(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setSQLToXMLNameEscaping(int, byte)';

  PROCEDURE setSQLToXMLNameEscaping(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_setSQLToXMLNameEsc(ctxHdl, 1);
    else
      p_setSQLToXMLNameEsc(ctxHdl, 0);
    end if;
  end setSQLToXMLNameEscaping;

  PROCEDURE setTagCase(ctxHdl IN ctxType, tCase IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setTagCase(int, byte)';


  PROCEDURE setDateFormat(ctxHdl IN ctxType, mask IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setDateFormat(int, java.lang.String)';


  PROCEDURE setMaxRows (ctxHdl IN ctxType, rows IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setMaxRows(int, int)';


  PROCEDURE setSkipRows(ctxHdl IN ctxType, rows IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setSkipRows(int, int)';


  PROCEDURE p_setStylesheetHeader(ctxHdl IN ctxType, uri IN VARCHAR2, type IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setStylesheetHeader(int, java.lang.String, java.lang.String)';

  PROCEDURE setStylesheetHeader(ctxHdl IN ctxType, uri IN VARCHAR2, type IN VARCHAR2 := 'text/xsl') is
  begin
    p_setStylesheetHeader(ctxHdl, uri, type);
  end setStylesheetHeader;


  PROCEDURE p_setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setXSLT(int, java.lang.String, java.lang.String)';

  PROCEDURE setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2 := null) IS
  begin
    p_setXSLT(ctxHdl, uri, ref);
  end setXSLT;

  PROCEDURE p_setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setXSLT(int, oracle.sql.CLOB, java.lang.String)';

  PROCEDURE setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2 := null) IS
  begin
    p_setXSLT(ctxHdl, stylesheet, ref);
  end setXSLT;

  PROCEDURE setXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2,value IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setXSLTParam(int, java.lang.String, java.lang.String)';

  PROCEDURE removeXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.removeXSLTParam(int, java.lang.String)';

  PROCEDURE p_setEncodingTag(ctxHdl IN ctxType, enc IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setEncodingTag(int, java.lang.String)';

  PROCEDURE setEncodingTag(ctxHdl IN ctxType,enc IN VARCHAR2 := DB_ENCODING) is
  begin
    p_setEncodingTag(ctxHdl, enc);
  end setEncodingTag;

  PROCEDURE setBindValue(ctxHdl IN ctxType, bindName IN VARCHAR2, bindValue IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setBindValue(int, java.lang.String, java.lang.String)';


  PROCEDURE clearBindValues(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.clearBindValues(int)';

  PROCEDURE p_setMetaHeader(ctxHdl IN ctxType, header IN CLOB)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setMetaHeader(int, oracle.sql.CLOB)';

  PROCEDURE setMetaHeader(ctxHdl IN ctxType, header IN CLOB := null) IS
  begin
    p_setMetaHeader(ctxHdl, header);
  end setMetaHeader;

  PROCEDURE p_setDataHeader(ctxHdl IN ctxType, header IN CLOB, tag IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setDataHeader(int, oracle.sql.CLOB, java.lang.String)';

  PROCEDURE setDataHeader(ctxHdl IN ctxType, header IN CLOB := null, tag IN VARCHAR2 := null) is
  begin
    p_setDataHeader(ctxHdl, header, tag);
  end setDataHeader;


  PROCEDURE p_setRaiseException(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRaiseException(int, byte)';

  PROCEDURE setRaiseException(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_setRaiseException(ctxHdl, 1);
    else
      p_setRaiseException(ctxHdl, 0);
    end if;
  end setRaiseException;

  PROCEDURE p_setRaiseNoRowsExc(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setRaiseNoRowsException(int, byte)';

  PROCEDURE setRaiseNoRowsException(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_setRaiseNoRowsExc(ctxHdl, 1);
    else
      p_setRaiseNoRowsExc(ctxHdl, 0);
    end if;
  end setRaiseNoRowsException;

  PROCEDURE p_propOrigExc(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.propagateOriginalException(int, byte)';

  PROCEDURE propagateOriginalException(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_propOrigExc(ctxHdl, 1);
    else
      p_propOrigExc(ctxHdl, 0);
    end if;
  end propagateOriginalException;

  PROCEDURE getExceptionContent(ctxHdl IN ctxType, errNo OUT NUMBER, errMsg OUT VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.getExceptionContent(int, int[], java.lang.String[])';

  PROCEDURE p_setStrictLegalXMLCharCheck(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.setStrictLegalXMLCharCheck(int, byte)';

  PROCEDURE setStrictLegalXMLCharCheck(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_setStrictLegalXMLCharCheck(ctxHdl, 1);
    else
      p_setStrictLegalXMLCharCheck(ctxHdl, 0);
    end if;
  end setStrictLegalXMLCharCheck;

  ------------------- generation ----------------------------------------------
  FUNCTION getDTD(ctxHdl IN ctxType, withVer IN BOOLEAN := false) RETURN CLOB IS
    clb CLOB;
  begin
    dbms_lob.createtemporary(clb, true, DBMS_LOB.SESSION);
    getDTD(ctxHdl, clb, withVer);
    return clb;
  end getDTD;

  PROCEDURE p_getDTD(ctxHdl IN ctxType, xDoc IN CLOB, withVer IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.getDTD(int, oracle.sql.CLOB, byte)';

  PROCEDURE getDTD(ctxHdl IN ctxType, xDoc IN CLOB, withVer IN BOOLEAN := false) IS
  begin
    if withVer = true then
      p_getDTD(ctxHdl, xDoc, 1);
    else
      p_getDTD(ctxHdl, xDoc, 0);
    end if;
  end getDTD;


  FUNCTION getXML(ctxHdl IN ctxType, metaType IN NUMBER := NONE) RETURN CLOB IS
    clb CLOB;
  begin
    dbms_lob.createtemporary(clb, true, DBMS_LOB.SESSION);
    getXML(ctxHdl, clb, metaType);
    return clb;
  end getXML;

  PROCEDURE p_getXML(ctxHdl IN ctxType, xDoc IN CLOB, metaType IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.getXML(int, oracle.sql.CLOB, byte)';

  PROCEDURE getXML(ctxHdl IN ctxType, xDoc IN CLOB, metaType IN NUMBER := NONE) IS
  begin
    p_getXML(ctxHdl, xDoc, metaType);
  end getXML;

  FUNCTION getXML(sqlQuery IN VARCHAR2, metaType IN NUMBER := NONE) RETURN CLOB IS
    ctx    ctxType;
    clb    CLOB;
  begin
    ctx := newContext(sqlQuery);
    clb := getXML(ctx, metaType);
    closeContext(ctx);
    return clb;
  end getXML;

  FUNCTION getXML(sqlQuery IN CLOB, metaType IN NUMBER := NONE) RETURN CLOB IS
    ctx    ctxType;
    clb    CLOB;
  begin
    ctx := newContext(sqlQuery);
    clb := getXML(ctx, metaType);
    closeContext(ctx);
    return clb;
  end getXML;


  PROCEDURE resetResultSet(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.resetResultSet(int)';


  FUNCTION getNumRowsProcessed(ctxHdl IN ctxType) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.query.OracleXMLStaticQuery.getNumRowsProcessed(int) return long';


END DBMS_XMLQUERY;
/
show errors;



--=============================================================================
--=============================================================================
--=============================================================================
--=============================================================================
CREATE OR REPLACE PACKAGE DBMS_XMLSAVE AUTHID CURRENT_USER AS

  SUBTYPE ctxType IS NUMBER;                                 /* context type */

  DEFAULT_ROWTAG      CONSTANT VARCHAR2(3) := 'ROW';               /* rowtag */
  DEFAULT_DATE_FORMAT CONSTANT VARCHAR2(21):= 'YYYY-MM-DD HH24:MI:SS';

  MATCH_CASE          CONSTANT NUMBER      := 0;               /* match case */
  IGNORE_CASE         CONSTANT NUMBER      := 1;             /* ignore case */


  -------------------- constructor/destructor functions ---------------------
  FUNCTION newContext(targetTable IN VARCHAR2) RETURN ctxType;
  PROCEDURE closeContext(ctxHdl IN ctxType);

  -------------------- parameters to the save (XMLtoDB) engine ----------------
  PROCEDURE setXSLT(ctxHdl IN ctxType,uri IN VARCHAR2,ref IN VARCHAR2 := null);
  PROCEDURE setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2 := null);
  PROCEDURE setXSLTParam(ctxHdl IN ctxType,name IN VARCHAR2,value IN VARCHAR2);
  PROCEDURE removeXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2);

  PROCEDURE setRowTag(ctxHdl IN ctxType, tag IN VARCHAR2);
  PROCEDURE setSQLToXMLNameEscaping(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE setPreserveWhitespace(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  PROCEDURE setIgnoreCase(ctxHdl IN ctxType, flag IN NUMBER);

  PROCEDURE setDateFormat(ctxHdl IN ctxType, mask IN VARCHAR2);

  PROCEDURE setBatchSize(ctxHdl IN ctxType, batchSize IN NUMBER);
  PROCEDURE setCommitBatch(ctxHdl IN ctxType, batchSize IN NUMBER);

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
  -- updateXML
  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER;
  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER;
  -- deleteXML
  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER;
  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER;

  ------------------- misc ----------------------------------------------------
  PROCEDURE propagateOriginalException(ctxHdl IN ctxType, flag IN BOOLEAN);
  PROCEDURE getExceptionContent(ctxHdl IN ctxType, errNo OUT NUMBER, errMsg OUT VARCHAR2);
  PROCEDURE useDBDates(ctxHdl IN ctxType, flag IN BOOLEAN := true);
  
  -------private method declarations------------------------------------------
  -- we must do this as a bug workaround; otherwise we get ora-600 [kgmexchi11]
  PROCEDURE p_useDBDates(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2);
  PROCEDURE p_setXSLT(ctxHdl IN ctxType, stylesheet CLOB, ref IN VARCHAR2);
  PROCEDURE p_propagateOriginalException(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setSQLToXMLNameEsc(ctxHdl IN ctxType, flag IN NUMBER);
  PROCEDURE p_setPreserveWhitespace(ctxHdl IN ctxType, flag IN NUMBER);

END dbms_xmlsave;
/
show errors;


CREATE OR REPLACE PACKAGE BODY DBMS_XMLSAVE AS

  FUNCTION newContext(targetTable IN VARCHAR2) RETURN ctxType
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.newContext(java.lang.String) return int';

  PROCEDURE closeContext(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.closeContext(int)';


  PROCEDURE p_setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setXSLT(int, java.lang.String, java.lang.String)';

  PROCEDURE setXSLT(ctxHdl IN ctxType, uri IN VARCHAR2, ref IN VARCHAR2 := null) IS
  begin
    p_setXSLT(ctxHdl, uri, ref);
  end setXSLT;

  PROCEDURE p_setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setXSLT(int, oracle.sql.CLOB, java.lang.String)';

  PROCEDURE setXSLT(ctxHdl IN ctxType, stylesheet IN CLOB, ref IN VARCHAR2 := null) IS
  begin
    p_setXSLT(ctxHdl, stylesheet, ref);
  end setXSLT;

  PROCEDURE setXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2,value IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setXSLTParam(int, java.lang.String, java.lang.String)';

  PROCEDURE removeXSLTParam(ctxHdl IN ctxType, name IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.removeXSLTParam(int, java.lang.String)';


  PROCEDURE setRowTag(ctxHdl IN ctxType, tag IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setRowTag(int, java.lang.String)';


  PROCEDURE p_setSQLToXMLNameEsc(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setSQLToXMLNameEscaping(int, byte)';

  PROCEDURE setSQLToXMLNameEscaping(ctxHdl IN ctxType, flag IN BOOLEAN := true ) is
  begin
    if flag = true then
      p_setSQLToXMLNameEsc(ctxHdl, 1);
    else
      p_setSQLToXMLNameEsc(ctxHdl, 0);
    end if;
  end setSQLToXMLNameEscaping;

  PROCEDURE p_setPreserveWhitespace(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setPreserveWhitespace(int, byte)';

  PROCEDURE setPreserveWhitespace(ctxHdl IN ctxType,flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_setPreserveWhitespace(ctxHdl, 1);
    else
      p_setPreserveWhitespace(ctxHdl, 0);
    end if;
  end setPreserveWhitespace;

  PROCEDURE setIgnoreCase(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setIgnoreCase(int, byte)';


  PROCEDURE setDateFormat(ctxHdl IN ctxType, mask IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setDateFormat(int, java.lang.String)';


  PROCEDURE setBatchSize(ctxHdl IN ctxType, batchSize IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setBatchSize(int, int)';


  PROCEDURE setCommitBatch(ctxHdl IN ctxType, batchSize IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setCommitBatch(int, int)';


  PROCEDURE setUpdateColumn(ctxHdl IN ctxType, colName IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setUpdateColumn(int, java.lang.String)';


  PROCEDURE clearUpdateColumnList(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.clearUpdateColumnList(int)';


  PROCEDURE setKeyColumn(ctxHdl IN ctxType, colName IN VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.setKeyColumn(int, java.lang.String)';


  PROCEDURE clearKeyColumnList(ctxHdl IN ctxType)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.clearKeyColumnList(int)';


  ------------------- save ----------------------------------------------------
  FUNCTION  insertXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.insertXML(int, java.lang.String) return int';

  FUNCTION  insertXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.insertXML(int, oracle.sql.CLOB) return int';


  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.updateXML(int, java.lang.String) return int';

  FUNCTION  updateXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.updateXML(int, oracle.sql.CLOB) return int';


  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN VARCHAR2) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.deleteXML(int, java.lang.String) return int';

  FUNCTION  deleteXML(ctxHdl IN ctxType, xDoc IN CLOB) RETURN NUMBER
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.deleteXML(int, oracle.sql.CLOB) return int';


  ------------------- misc ----------------------------------------------------
  PROCEDURE p_propagateOriginalException(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.propagateOriginalException(int, byte)';

  PROCEDURE propagateOriginalException(ctxHdl IN ctxType, flag IN BOOLEAN) is
  begin
    if flag = true then
      p_propagateOriginalException(ctxHdl, 1);
    else
      p_propagateOriginalException(ctxHdl, 0);
    end if;
  end propagateOriginalException;

  PROCEDURE getExceptionContent(ctxHdl IN ctxType, errNo OUT NUMBER, errMsg OUT VARCHAR2)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.getExceptionContent(int, int[], java.lang.String[])';

  PROCEDURE p_useDBDates(ctxHdl IN ctxType, flag IN NUMBER)
  as LANGUAGE JAVA NAME
   'oracle.xml.sql.dml.OracleXMLStaticSave.useDBDates(int, byte)';

  PROCEDURE useDBDates(ctxHdl IN ctxType, flag IN BOOLEAN := true) is
  begin
    if flag = true then
      p_useDBDates(ctxHdl, 1);
    else
      p_useDBDates(ctxHdl, 0);
    end if;
  end useDBDates;      
   
END DBMS_XMLSAVE;
/
show errors;

--=============================================================================
GRANT EXECUTE ON DBMS_XMLQUERY TO PUBLIC;
GRANT EXECUTE ON DBMS_XMLSAVE  TO PUBLIC;

create or replace public synonym dbms_xmlquery for dbms_xmlquery;
create or replace public synonym dbms_xmlsave  for dbms_xmlsave;

