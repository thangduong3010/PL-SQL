Rem
Rem $Header: rdbms/admin/utlcxml.sql /st_rdbms_11.2.0/1 2013/01/15 08:01:19 gclaborn Exp $
Rem
Rem utlcxml.sql
Rem
Rem Copyright (c) 2000, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlcxml.sql - PL/SQL wrapper over COREs C-based XML/XSL processor
Rem
Rem    DESCRIPTION
Rem      This is the package header for the PL/SQL interface to CORE's C-based
Rem      XML Parser and XSL Processor. It currently does not provide an
Rem      interface to CORE's C-based DOM, SAX and Namespace APIs.
Rem
Rem    NOTES
Rem      1. You MUST call function XMLINIT before any others in this package.
Rem      2. Pkg. body and trusted lib. implementations are in:
Rem      /vobs/rdbms/src/server/datapump/ddl
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gclaborn    01/10/13 - Backport gclaborn_bug-16018315 from main
Rem    ebatbout    10/26/09 - 9002766: Add windows32 routine
Rem    lbarton     12/01/08 - TSTZ support
Rem    sumkumar    10/03/08 - bug 7446720: rename rowid param name for long2clob
Rem    lbarton     09/10/08 - bug 7339061: remove xmlGetTableFromDoc
Rem    lbarton     04/22/08 - bug 6730161: get version-specific hashcode
Rem    lbarton     01/31/08 - bug 5961283: get uncorrupted hashcode
Rem    lbarton     01/29/08 - bug 6661262: hashcode version
Rem    lbarton     02/23/07 - bug 5888578: change long2clob interface
Rem    lbarton     06/07/06 - xmlGetTableFromDoc
Rem    lbarton     02/21/06 - ParseExpr
Rem    rapayne     03/08/06 - add compare
Rem    sdavidso    09/08/05 - new interface for detecting OMF file names 
Rem    rpfau       11/08/04 - Make package utl_xml definers rights with no 
Rem                           synonym or grant. 
Rem    lbarton     07/30/03 - Bug 3056720: add long2clob
Rem    lbarton     07/03/03 - Bug 3016951: add getNextTypeid
Rem    lbarton     03/31/03 - change grant on utl_xml
Rem    gclaborn    09/19/02 - Change writable CLOB decl. to IN OUT NOCOPY
Rem    lbarton     09/30/02 - add get_fdo
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    lbarton     12/05/00 - add xslLoadFromFile
Rem    gclaborn    12/20/00 - Add multi-charset support
Rem    gclaborn    10/10/00 - Remove ResX routines: bug fixed
Rem    lbarton     08/01/00 - add "ResX" routines as workaround to OCI bug
Rem    gclaborn    05/10/00 - Created
Rem
CREATE OR REPLACE PACKAGE utl_xml AUTHID DEFINER AS

-- Opaque handles
SUBTYPE xmlCtx IS PLS_INTEGER;          -- Handle to a parser: It's really just
                                        -- a monotonically increasing ub4 per
                                        -- session.

----------------------------------------
--      CONSTANTS
----------------------------------------
--
-- These are parse flags corresponding to their counterparts in lpx.h
VALIDATE                CONSTANT BINARY_INTEGER := 1;
DISCARD_WHITESPACE      CONSTANT BINARY_INTEGER := 2;
DTD_ONLY                CONSTANT BINARY_INTEGER := 4;
STOP_ON_WARNING         CONSTANT BINARY_INTEGER := 8;

----------------------------------------
--              PUBLIC INTERFACE
----------------------------------------

-- XSLLOADFROMFILE: Load an XSL stylesheet from a BFILE into a CLOB
-- PARAMS:
--      destLob - LOB locator of target for the load
--      srcFile - BFILE locator of the source for the load
--      amount  - number of bytes to load from the BFILE

PROCEDURE xslLoadFromFile(destLob       IN CLOB,
                          srcFile       IN BFILE,
                          amount        IN BINARY_INTEGER
                         );

-- GETFDO: Return the format descriptor object for objects on this platform.
-- PARAMS: None.
-- Returns: Returns the RAW(100) FDO.

FUNCTION getFdo RETURN RAW;

-- GETNEXTTYPEID: Given the current value of next_typeid for a type hierarchy
--   and another typeid, see if next_typeid needs to be incremented,
--   and, if so, what its new value should be.
-- PARAMS:
--      next_typeid     - current next_typeid value
--      typeid          - another typeid
--      new_next_typeid - the new next_typeid value
--                       or NULL if no increment needed.

PROCEDURE getNextTypeid (next_typeid    IN  RAW,
                        typeid          IN  RAW,
                        new_next_typeid OUT RAW);

-- GETHASHCODE: Upgrade from 817 corrupts the hashcode in type$,
--   so we have to get it by calling kotgHashCode.
-- PARAMS:
--      schema          - type schema
--      typename        - type name
--      flag            - 1 = only return V1 hashcode
--                        0 = return the hashcode whatever version it is
--      hashcode        - returned hashcode

PROCEDURE getHashCode (schema   IN  VARCHAR2,
                       typename IN  VARCHAR2,
                       flag     IN  BINARY_INTEGER,
                       hashcode OUT RAW);

-- TYPEHASHCODEEQ: Does the hashcode match the hc for the type?
--   The type hashcode versions changed between 10.2 and 11g
--   so a simple compare doesn't work.  This is a wrapper around
--   kottyphcequ.
-- PARAMS:
--      schema          - type schema
--      typename        - type name
--      hashcode        - hashcode to check
-- RETURNS: TRUE if a match

FUNCTION typeHashCodeEq (schema   IN VARCHAR2,
                         typename IN VARCHAR2,
                         hashcode IN RAW)
  RETURN BOOLEAN;

-- HASTSTZ: Does the type have a TSTZ element or attribute?
-- PARAMS:
--      schema          - type schema
--      typename        - type name
-- RETURNS: TRUE if it does

FUNCTION HasTstz (schema   IN VARCHAR2,
                  typename IN VARCHAR2)
  RETURN BOOLEAN;

-- LONG2CLOB: Fetch a LONG as a CLOB
-- PARAMS:
--      tab             - table name
--      col             - column name
--      row_id          - rowid value
--      lobloc          - a LOB locator to receive the long value
-- NOTE: tab and col must belong to a short list of valid values;
--  see prvtcxml.sql


PROCEDURE long2clob    (
                        tab     IN VARCHAR2,
                        col     IN VARCHAR2,
                        row_id  IN ROWID,
                        lobloc  IN OUT NOCOPY CLOB
                       );

-- PARSEEXPR: Parse an expression (boolean or arithmetic)
--            and return in a CLOB as XML
-- PARAMS:
--      schema          - schema
--      tab             - table name
--      sqltext         - the text of the expression
--      arith           - non-0 = sqltext is an arithmetic expression
--      lobloc          - a LOB locator to receive the parsed value

PROCEDURE parseExpr    (schema  IN VARCHAR2,
                        tab     IN VARCHAR2,
                        sqltext IN CLOB,
                        arith   IN BINARY_INTEGER,
                        lobloc  IN OUT NOCOPY CLOB
                       );

-- PARSEQUERY: Parse a SQL query and return in a CLOB as XML
-- PARAMS:
--      user            - user
--      sqltext         - the text of the query
--      lobloc          - a LOB locator to receive the parsed value

PROCEDURE parseQuery   (user  IN VARCHAR2,
                        sqltext IN CLOB,
                        lobloc  IN OUT NOCOPY CLOB
                       );

-- XMLINIT: Initializes a DOM XML Parser.
-- PARAMS:  None. 
-- RETURNS: An opaque handle to this parser.
-- NOTE: Encoding (a param. in the C LpxInitialize) is specified in XMLPARSE
--      on a per-document basis. The implementation registers a private error
--      hdlr. and UGA memory alloc. routines for session duration scope.
--      This routine must be called before any others in this package.

FUNCTION xmlInit RETURN xmlCtx;

-- XMLSETPARSEFLAGS: Sets parsing options for this parser.
--      NOTE: These are sticky across parses using the same parser.
-- PARAMS:
--      ctx     - Parser context to which the flag should apply.
--      flag    - a valid parsing option:
--              VALIDATE: Perform XML validation as per XML 1.0 spec.
--                      DEFAULT: NO
--              DISCARD_WHITESPACE: Remove all whitespace between elements
--                      DEFAULT: NO
--              DTD_ONLY: Parse just the DTD
--                      DEFAULT: NO
--              STOP_ON_WARNING: Return to caller on warnings rather than just
--                      throw the error to stdout and continuing.
--                      DEFAULT: NO
--      value   - TRUE or FALSE to enable or disable the flag.

PROCEDURE xmlSetParseFlag( ctx          IN xmlctx,
                           flag         IN BINARY_INTEGER,
                           value        IN BOOLEAN
                         );

-- XMLPARSE: Parses target of a URI (file or DB column) into a DOM format.
-- PARAMS:
--      ctx       - Parser's context. Resulting DOM tree is opaque within ctx.
--      uri       - URI of target. Can point to a file or be an Xpath to say,
--                  a CLOB col. holding a stylesheet. The latter might look
--                  like:
--      '/oradb/SCOTT/XSLTABLE/ROW[XSLTAG=''my_stylesheet''/xslCLOB/text()'
--                  Former would be a regular dir. path like:
--      '/usr/disk1/scott/my_stylesheet.xsl'
--      encoding  - Doc's encoding. If left NULL, then if uri starts with
--                  '/oradb/', then the database charset is used; otherwise,
--                  'UTF-8'. Use 'US-ASCII' for better perf. if you can.
-- NOTE: If the uri is an intra-DB uri (ie, /oradb) that points to an NCLOB
--       column or a CLOB with an encoding different from the database charset,
--       you must explicitly specify the encoding.

PROCEDURE xmlParse      (ctx            IN xmlCtx,
                         uri            IN VARCHAR2,
                         encoding       IN VARCHAR2 DEFAULT NULL
                        );

-- XMLPARSE: Parses the CLOB source doc into a DOM format.
-- PARAMS:
--      ctx       - Parser's context. Resulting DOM tree is opaque within ctx.
--      srcDoc    - XML document to parse.
-- NOTE: The document's char set encoding is implicit within the lob's locator.

PROCEDURE xmlParse      (ctx            IN xmlCtx,
                         srcDoc         IN CLOB
                        );

-- XSLSETSTYLESHEET: Sets the top-level style sheet for the upcoming transform
--      and also establishes the base URI for any included or imported
--      stylesheets. In other words, the href in <xsl:import/include> 
--      statements may be relative to the path established in this call.
--      This routine also parses the top-level stylesheet, so XMLPARSE should
--      not be called separately.
--      NOTE: *Must* be called prior to any of the transform routines.
-- PARAMS:
--      xslCtx     - Parser context to be used for XSL stylesheet.
--      uri        - XPath spec. to the stylesheet. May be a dir. path or
--               intra-DB spec; eg, /oradb/SYS/METAXSL$/ROW[...]/STYLESHEET
--      encoding  - Doc's encoding. If left NULL, then if uri starts with
--                  '/oradb/', then the database charset is used; otherwise,
--                  'UTF-8'. Use 'US-ASCII' for better perf. if you can.
-- NOTE: If the uri is an intra-DB uri (ie, /oradb) that points to an NCLOB
--       column or a CLOB with an encoding different from the database charset,
--       you must explicitly specify the encoding.

PROCEDURE xslSetStyleSheet (xslCtx              IN xmlCtx,
                            uri                 IN VARCHAR2,
                            encoding            IN VARCHAR2 DEFAULT NULL
                           );

-- XSLTRANSFORM: Transforms srcdoc into resdoc using the XSL stylesheet
--      associated with xslCtx.
-- PARAMS:
--      srcDoc    - The source XML document as a CLOB
--      xslCtx    - The XSL stylesheet document parser's context
--      resDoc    - The transformed output.

-- NOTE: There are several transformation variants accepting / returning either
--      a CLOB or a parser context. These are useful when chaining together
--      multiple transforms to avoid the cost of converting to/from
--      a CLOB on the intermediate steps.

PROCEDURE xslTransform (srcDoc  IN CLOB,
                        xslCtx  IN xmlCtx,
                        resDoc  IN OUT NOCOPY CLOB
                       );
                      
-- This one takes a CLOB and returns the xmlCtx of the result... to be used as
-- the first stage of chained transforms. It must have a different name because
-- its signature differs from the previous only in return type.
-- NOTE: It is the responsibility of the caller to clean up the returned parser
--      handle when finished using xmlTerm.

FUNCTION xslTransformCtoX (srcDoc       IN CLOB,
                           xslCtx       IN xmlCtx
                          ) RETURN xmlCtx;

-- Perform a transformation on a pre-parsed xmlCtx returning another xmlCtx
-- Used as the middle stage for 3 or more chained transforms.
-- NOTE: It is the responsibility of the caller to clean up the returned parser
--      handle when finished using xmlTerm.

FUNCTION xslTransformXtoX(srcCtx                IN xmlCtx,
                          xslCtx                IN xmlCtx
                         ) RETURN xmlCtx;

-- Perform an XSL transformation on a pre-parsed xmlctx returning a CLOB. To be
-- used as the final stage in chained transforms or where the caller wants to
-- parse source documents separately.

PROCEDURE xslTransformXtoC (srcCtx      IN xmlctx,
                            xslCtx      IN xmlCtx,
                            resDoc      IN OUT NOCOPY CLOB
                           );

-- XSLSETPARAM: set a parameter value for a stylesheet.
-- PARAMS:
--      xslCtx    - Parser context for the XSL stylesheet (already parsed)
--      paramName - The parameter whose value we're setting
--      paramVal  - The parameter's value
-- NOTE: These settings are 'sticky' and remain in effect until xslResetParams
--       is called.

PROCEDURE xslSetParam   (xslCtx         IN xmlCtx,
                         paramName      IN VARCHAR2,
                         paramVal       IN VARCHAR2
                        );

-- XSLRESETPARAMS: Resets all parameters to their default values for the given
--                 XSL parser ctx.
-- PARAMS:
--      ctx       - Parser's context.

PROCEDURE xslResetParams (xslCtx        IN xmlCtx);

-- XMLCLEAN: Cleans up memory from last doc. assoc. with this parser.
-- PARAMS:
--      ctx       - Parser's context.

PROCEDURE xmlClean (ctx IN xmlCtx);

-- XMLTERM: Runs this parser down: Deletes all mem. assoc. with ctx.
-- PARAMS:
--      ctx       - Parser's context. Invalid upon return.

PROCEDURE xmlTerm  (ctx IN xmlCtx);

-- isnameomf: Test the file name to see if it is an OMF name.
-- PARAMS:

PROCEDURE isnameomf(fname   IN  varchar2,
                    isomf   OUT binary_integer);

--
-- compare - compare ddl of 2 input objects and return a diff document
-- Params:
--    ctx     xml context
--    doc1    sxml doc1
--    doc2    sxml doc2
--    difDoc  resultant diff document
--    flags   (IN) input flags for XmlDiff (currently not used)
--            (OUT) kuxDifOb return flags (e.g., no difference found)

PROCEDURE compare
(
   ctx       IN xmlCtx,
   doc1      IN CLOB,
   doc2      IN CLOB,
   difDoc    IN CLOB,
   flags     IN OUT BINARY_INTEGER
);

-- windows32: Determine if running on 32 bit Windows NT system.
-- Params:
--    flag   (OUT) if value 1, then 32 bit Windows NT system
--                 otherwise 0.

PROCEDURE windows32(flag OUT binary_integer);


-- GETDDLSRCFROMXML: Bypass XSL processing for retrieval of pl/sql source from source$
--      Generating DDL for very large pkgs via XSL can be very expensive. This routine
--      forms the heart of an alternate fast method of retrieving the source of an
--      object via C string manipulations rather than XSL transformations.
-- PARAMS:
--      src     - The CLOB containing the object's XML representation
--      dst     - The CLOB to receive the DDL src
PROCEDURE getDDLSrcFromXML (src     IN            CLOB,
                            dst     IN OUT NOCOPY CLOB
                           );

END utl_xml;
/
