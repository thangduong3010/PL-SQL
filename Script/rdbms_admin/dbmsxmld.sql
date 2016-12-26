Rem
Rem $Header: rdbms/admin/dbmsxmld.sql /main/27 2009/02/05 15:29:33 mkandarp Exp $
Rem
Rem dbmsxmld.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxmld.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mkandarp    01/13/09 - 6852013: Add FreeNodeList
Rem    mkandarp    12/11/08 - 7435201 : Add free element
Rem    mkandarp    11/30/06 - 5655708 : Increase handle size
Rem    ataracha    12/18/06 - add StreamIsNull
Rem    nkandalu    09/25/06 - 5477912: add freeDocType method
Rem    nkhandel    10/20/05 - large node streaming API
Rem    rxpeters    05/11/04 - remove WriteDTD 
Rem    rxpeters    11/17/03 - add support for all DOM Exceptions 
Rem    bkhaladk    10/29/03 - add schema synonyms 
Rem    rxpeters    10/28/03 - add getNodeFromFragment 
Rem    ataracha    10/21/03 - add function resolveNamespacePrefix
Rem    ataracha    09/17/03 - added adoptnode
Rem    bkhaladk    08/19/03 - add synonym for xmldom 
Rem    rxpeters    07/30/03 - increase size of domtype to 12 bytes
Rem    ataracha    01/17/03 - add domdoc paramater to getxmltype
Rem    nmontoya    01/16/03 - ADD importnode method
Rem    njalali     08/13/02 - removing SET statements
Rem    thoang      04/17/02 - grabtrans 'thoang_bug-2265790'
Rem    thoang      04/08/02 - Added new methods 
Rem    thoang      03/21/02 - Added CreateDocument method.
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    nmontoya    12/12/01 - remove set echo on
Rem    sichandr    11/06/01 - add freeNode
Rem    rbooredd    10/05/01 - fix show errors
Rem    sichandr    09/20/01 - add getSchemaNode
Rem    nmontoya    09/05/01 - Merged nmontoya_plsdom2
Rem    nmontoya    08/09/01 - Created
Rem

  
CREATE OR REPLACE PACKAGE xdb.dbms_xmldom AUTHID CURRENT_USER IS 

----------------------------------------------------------------------
-- DOM API
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Constants and Type Declarations
----------------------------------------------------------------------
  
--
-- DOM Node types (as returned by getNodeType)
--
ELEMENT_NODE CONSTANT PLS_INTEGER                := 1;
ATTRIBUTE_NODE CONSTANT PLS_INTEGER              := 2;
TEXT_NODE CONSTANT PLS_INTEGER                   := 3;
CDATA_SECTION_NODE CONSTANT PLS_INTEGER          := 4;
ENTITY_REFERENCE_NODE CONSTANT PLS_INTEGER       := 5;
ENTITY_NODE CONSTANT PLS_INTEGER                 := 6;
PROCESSING_INSTRUCTION_NODE CONSTANT PLS_INTEGER := 7;
COMMENT_NODE CONSTANT PLS_INTEGER                := 8;
DOCUMENT_NODE CONSTANT PLS_INTEGER               := 9;
DOCUMENT_TYPE_NODE CONSTANT PLS_INTEGER          := 10;
DOCUMENT_FRAGMENT_NODE CONSTANT PLS_INTEGER      := 11;
NOTATION_NODE CONSTANT PLS_INTEGER               := 12;

--
-- DOMException types
--
INDEX_SIZE_ERR              EXCEPTION;
DOMSTRING_SIZE_ERR          EXCEPTION;
HIERARCHY_REQUEST_ERR       EXCEPTION;
WRONG_DOCUMENT_ERR          EXCEPTION;
INVALID_CHARACTER_ERR       EXCEPTION;
NO_DATA_ALLOWED_ERR         EXCEPTION;
NO_MODIFICATION_ALLOWED_ERR EXCEPTION;
NOT_FOUND_ERR               EXCEPTION;
NOT_SUPPORTED_ERR           EXCEPTION;
INUSE_ATTRIBUTE_ERR         EXCEPTION;
INVALID_STATE_ERR           EXCEPTION;
SYNTAX_ERR                  EXCEPTION;
INVALID_MODIFICATION_ERR    EXCEPTION;
NAMESPACE_ERR               EXCEPTION;
INVALID_ACCESS_ERR          EXCEPTION; 

--
-- DOM interface types
--
SUBTYPE domtype IS RAW(13);

TYPE DOMNode IS RECORD (id RAW(13));
TYPE DOMNamedNodeMap IS RECORD (id RAW(13));
TYPE DOMNodeList IS RECORD (id RAW(13));
TYPE DOMAttr IS RECORD (id RAW(13));
TYPE DOMCDataSection IS RECORD (id RAW(13));
TYPE DOMCharacterData IS RECORD (id RAW(13));
TYPE DOMComment IS RECORD (id RAW(13));
TYPE DOMDocumentFragment IS RECORD (id RAW(13));
TYPE DOMElement IS RECORD (id RAW(13));
TYPE DOMEntity IS RECORD (id RAW(13));
TYPE DOMEntityReference IS RECORD (id RAW(13));
TYPE DOMNotation IS RECORD (id RAW(13));
TYPE DOMProcessingInstruction IS RECORD (id RAW(13));
TYPE DOMText IS RECORD (id RAW(13));
TYPE DOMImplementation IS RECORD (id RAW(13));
TYPE DOMDocumentType IS RECORD (id RAW(13));
TYPE DOMDocument IS RECORD (id RAW(13));
TYPE DOMStreamHandle IS RECORD (id RAW(12));
/*
SUBTYPE DOMNode IS domtype;
SUBTYPE DOMNamedNodeMap IS domtype;
SUBTYPE DOMNodeList IS domtype;
SUBTYPE DOMAttr IS domtype;
SUBTYPE DOMCDataSection IS domtype;
SUBTYPE DOMCharacterData IS domtype;
SUBTYPE DOMComment IS domtype;
SUBTYPE DOMDocumentFragment IS domtype;
SUBTYPE DOMElement IS domtype;
SUBTYPE DOMEntity IS domtype;
SUBTYPE DOMEntityReference IS domtype;
SUBTYPE DOMNotation IS domtype;
SUBTYPE DOMProcessingInstruction IS domtype;
SUBTYPE DOMText IS domtype;
SUBTYPE DOMImplementation IS domtype;
SUBTYPE DOMDocumentType IS domtype;
SUBTYPE DOMDocument IS domtype;
*/

-----------------------------------------------------------------------------
-- Public Interface
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Interface DOMImplementation:
--    
--    hasFeature
--    createDocument
--
--    implementation_isNull (Extension)
--
---------------------------------------------------------------------------


/**
 * DOM DOMImplementation interface methods
 * These methods implement the DOM DOMImplementation interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-102161490
 */
FUNCTION hasFeature(di DOMImplementation, feature IN VARCHAR2, 
                    version IN VARCHAR2) RETURN BOOLEAN;

FUNCTION createDocument(namespaceURI IN VARCHAR2, qualifiedName IN VARCHAR2,
                        doctype IN DOMType := NULL) RETURN DOMDocument;
 
/**
 * DOM Node XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(di DOMImplementation) RETURN BOOLEAN;


---------------------------------------------------------------------------
-- DOM Node interface:
--    
--    getNodeName
--    getNodeValue
--    setNodeValue
--    getNodeType
--    getParentNode
--    getChildNodes
--    getFirstChild
--    getLastChild
--    getPreviousSibling
--    getNextSibling
--    getAttributes
--    getOwnerDocument
--    getPrefix
--    setPrefix
--    insertBefore
--    replaceChild
--    removeChild
--    appendChild
--    hasChildNodes
--    cloneNode

--    node_isNull (Extension)
--    writeToFile (Extension)
--    node_writeToBuffer (Extension)
--    node_writeToClob (Extension)
--    getNodeFromFragment (Extension)
--    writeToFile (given charset, Extension)
--    writeToBuffer (given charset, Extension)
--    writeToClob (given charset, Extension)
--    makeAttr (Extension)
--    makeCDataSection (Extension)
--    makeCharacterData (Extension)
--    makeComment (Extension)
--    makeDocumentFragment (Extension)
--    makeDocumentType (Extension)
--    makeElement (Extension)
--    makeEntity (Extension)
--    makeEntityReference (Extension)
--    makeNotation (Extension)
--    makeProcessingInstruction (Extension)
--    makeText (Extension)
--    makeDocument (Extension)
--    getSchemaNode (Extension)
--    freeNode (Extension)

--    numChildNodes (available for C wrapper) 
--    getQualifiedName (available for C wrapper)
--    getNodeNameSpace (available for C wrapper)
--    getNodePrefix (available for C wrapper)
--    getNodeLocal (available for C wrapper)
---------------------------------------------------------------------------
--    

/**
 * DOM Node interface methods
 * These methods implement the DOM Node interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1950641247
 */
FUNCTION getNodeName(n DOMNode) RETURN VARCHAR2;
FUNCTION getNodeValue(n domnode) RETURN VARCHAR2;
PROCEDURE setNodeValue(n DOMNode, nodeValue IN VARCHAR2);
FUNCTION getNodeType(n DOMNode) RETURN pls_INTEGER;
FUNCTION getParentNode(n DOMNode) RETURN DOMNode;

-- FUNCTION domnode_getChildNodes (n IN domnode) RETURN DOMNodeList;
FUNCTION getChildNodes(n DOMNode) RETURN DOMNodeList;

FUNCTION getFirstChild(n DOMNode) RETURN DOMNode;
FUNCTION getLastChild(n DOMNode) RETURN DOMNode;
FUNCTION getPreviousSibling(n DOMNode) RETURN DOMNode;
FUNCTION getNextSibling(n DOMNode) RETURN DOMNode;
FUNCTION getAttributes(n DOMNode) RETURN DOMNamedNodeMap;
FUNCTION getOwnerDocument(n DOMNode) RETURN DOMDocument;
FUNCTION getPrefix(n domnode) RETURN VARCHAR2;
FUNCTION getNodeFromFragment (fragment IN sys.xmltype) return DOMNode;
PROCEDURE setPrefix(n DOMNode, prefix IN VARCHAR2);
FUNCTION insertBefore(n DOMNode, newChild IN DOMNode, refChild IN DOMNode) 
RETURN DOMNode;
FUNCTION replaceChild(n DOMNode, newChild IN DOMNode, oldChild IN DOMNode)
RETURN DOMNode;
FUNCTION removeChild(n DOMNode, oldChild IN DOMNode) RETURN DOMNode;
FUNCTION appendChild(n DOMNode, newChild IN DOMNode) RETURN DOMNode;
FUNCTION hasChildNodes(n DOMNode) RETURN BOOLEAN;
FUNCTION hasAttributes(n DOMNode) RETURN BOOLEAN;
FUNCTION cloneNode(n DOMNode, deep boolean) RETURN DOMNode;

/**
 * DOM Node XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(n DOMNode) RETURN BOOLEAN;

-- Write DOMNode object using the database character set
PROCEDURE writeToFile(n DOMNode, fileName VARCHAR2);
PROCEDURE writeToBuffer(n DOMNode, buffer IN OUT VARCHAR2);
PROCEDURE writeToClob(n DOMNode, cl IN OUT CLOB);

-- Write DOMNode object using database character set and Print Options
PROCEDURE writeToFile(n DOMNode, fileName VARCHAR2,
                      pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToBuffer(n DOMNode, buffer IN OUT VARCHAR2,
                       pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToClob(n DOMNode, cl IN OUT CLOB,
                      pflag IN NUMBER, indent IN NUMBER);

-- Write DOMNode object using the specified character set
PROCEDURE writeToFile(n DOMNode, fileName VARCHAR2, charset VARCHAR2);
PROCEDURE writeToBuffer(n DOMNode, buffer IN OUT VARCHAR2, charset VARCHAR2);
PROCEDURE writeToClob(n DOMNode, cl IN OUT CLOB, charset VARCHAR2);

-- Write DOMNode object using the specified character set and print options
PROCEDURE writeToFile(n DOMNode, fileName VARCHAR2, charset VARCHAR2,
                      pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToBuffer(n DOMNode, buffer IN OUT VARCHAR2, charset VARCHAR2,
                       pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToClob(n DOMNode, cl IN OUT CLOB, charset VARCHAR2,
                      pflag IN NUMBER, indent IN NUMBER);

-- Cast DOMNode objects
FUNCTION makeAttr(n DOMNode) RETURN DOMAttr;
FUNCTION makeCDataSection(n DOMNode) RETURN DOMCDataSection;
FUNCTION makeCharacterData(n DOMNode) RETURN DOMCharacterData;
FUNCTION makeComment(n DOMNode) RETURN DOMComment;
FUNCTION makeDocumentFragment(n DOMNode) RETURN DOMDocumentFragment;
FUNCTION makeDocumentType(n DOMNode) RETURN DOMDocumentType;
FUNCTION makeElement(n DOMNode) RETURN DOMElement;
FUNCTION makeEntity(n DOMNode) RETURN DOMEntity;
FUNCTION makeEntityReference(n DOMNode) RETURN DOMEntityReference;
FUNCTION makeNotation(n DOMNode) RETURN DOMNotation;
FUNCTION makeProcessingInstruction(n DOMNode) RETURN DOMProcessingInstruction;
FUNCTION makeText(n DOMNode) RETURN DOMText;
FUNCTION makeDocument(n DOMNode) RETURN DOMDocument;

FUNCTION  getSchemaNode(n DOMnode) RETURN DOMnode;
PROCEDURE getNamespace(n DOMnode, data IN OUT VARCHAR2);
PROCEDURE getLocalName(n DOMnode, data OUT VARCHAR2);
PROCEDURE getExpandedName(n DOMnode, data OUT VARCHAR2);
PROCEDURE freeNode(n DOMnode);



-------------------------------------------------------------------------------
-- The following functions and procedures are added to support the 4 Streaming
-- models defined for Large Node access
-------------------------------------------------------------------------------
-- Get-Pull methods
-------------------------------------------------------------------------------
FUNCTION getNodeValueAsBinaryStream (n in domnode) 
                                        return sys.utl_BinaryInputStream;
FUNCTION getNodeValueAsCharacterStream (n      in domnode) 
                                        return sys.utl_CharacterInputStream;
----------------------------------------------------------------------------
-- Get-Push methods
----------------------------------------------------------------------------
PROCEDURE getNodeValueAsBinaryStream (n         in domnode, 
                                      pushValue in out sys.utl_BinaryOutputStream);
PROCEDURE getNodeValueAsCharacterStream (n         in domnode,
                                         pushValue in out sys.utl_CharacterOutputStream);
----------------------------------------------------------------------------
-- Set-Pull methods
----------------------------------------------------------------------------
PROCEDURE setNodeValueAsBinaryStream (n         in domnode,
                                      nodeValue in out sys.utl_BinaryInputStream);
PROCEDURE setNodeValueAsCharacterStream (n         in domnode,
                                      nodeValue in out sys.utl_CharacterInputStream);
----------------------------------------------------------------------------
-- "Deferred" Set-Pull
----------------------------------------------------------------------------
PROCEDURE setNodeValueAsDeferredBfile (n     in domnode,
                                       value in bfile);
PROCEDURE setNodeValueAsDeferredBlob (n     in domnode,
                                      value in blob);
PROCEDURE setNodeValueAsDeferredClob (n     in domnode,
                                      value in clob);
----------------------------------------------------------------------------
-- Set-Push methods
----------------------------------------------------------------------------
FUNCTION setNodeValueAsBinaryStream (n in domnode) return                                     sys.utl_BinaryOutputStream;
FUNCTION setNodeValueAsCharacterStream (n in domnode) return
                                     sys.utl_CharacterOutputStream;
----------------------------------------------------------------------------
-- Determining if use of Binary Stream is valid
----------------------------------------------------------------------------
FUNCTION useBinaryStream (n in domnode) return boolean;
FUNCTION xmld_useBinStream (n in raw) return boolean;
----------------------------------------------------------------------------
-- XMLBinaryInputStream methods
----------------------------------------------------------------------------
FUNCTION createXMLBinaryInputStream (n in raw) return raw;
FUNCTION BinaryInputStreamAvailable (handle in raw) return integer;
PROCEDURE readBytesFromBIS1 (   handle in RAW,
                                bytes in out raw
--                                offset in pls_integer,
--                                numBytes in pls_integer
);

FUNCTION readBinaryInputStream (handle   in raw,
                                numBytes in integer) return raw;
PROCEDURE readBinaryInputStream (handle   in            raw,
                                 bytes    in out nocopy raw,
                                 numBytes in out        integer);
PROCEDURE readBinaryInputStream (handle   in            raw,
                                 bytes    in out nocopy raw,
                                 offset   in            integer,
                                 numBytes in out        integer);
PROCEDURE closeBinaryInputStream (handle in raw);
----------------------------------------------------------------------------
-- XMLBinaryOutputStream methods
----------------------------------------------------------------------------
FUNCTION createXMLBinaryOutputStream (n in raw) return raw;
FUNCTION writeBinaryOutputStream (handle   in            raw,
                                  bytes    in out nocopy raw,
                                  numBytes in            integer) 
                            return integer;
PROCEDURE writeBinaryOutputStream (handle   in            raw,
                                   bytes    in out nocopy raw,
                                   numBytes in out        integer);
PROCEDURE writeBinaryOutputStream (handle   in            raw,
                                   bytes    in out nocopy raw,
                                   offset   in            integer,
                                   numBytes in out        integer);
PROCEDURE flushBinaryOutputStream (handle in raw);
PROCEDURE closeBinaryOutputStream (handle in raw);
----------------------------------------------------------------------------
-- XMLCharacterInputStream methods
----------------------------------------------------------------------------
FUNCTION createXMLCharacterInputStream (n in raw) return raw;
FUNCTION CharacterInputStreamAvailable (handle in raw) return integer;
FUNCTION readCharacterInputStream (handle   in raw,
                                   numChars in integer,
                                   lineFeed in boolean) return varchar2;
PROCEDURE readCharacterInputStream (handle   in            raw,
                                    chars    in out nocopy varchar2,
                                    numChars in out        integer,
                                    lineFeed in            boolean);
PROCEDURE readCharacterInputStream (handle   in            raw ,
                                    chars    in out nocopy varchar2,
                                    offset   in            integer ,
                                    numChars in out        integer,
                                    lineFeed in            boolean);
PROCEDURE closeCharacterInputStream (handle in raw);
----------------------------------------------------------------------------
-- XMLCharacterOutputStream methods
----------------------------------------------------------------------------
FUNCTION createXMLCharacterOutputStream (n in raw) return raw;
FUNCTION writeCharacterOutputStream (handle   in            raw,
                                     chars    in out nocopy varchar2,
                                     numChars in            integer,
                                     lineFeed in            boolean) return integer;

PROCEDURE writeCharacterOutputStream (handle   in            raw,
                                      chars    in out nocopy varchar2,
                                      numChars in out        integer,
                                      lineFeed in            boolean);

PROCEDURE writeCharacterOutputStream (handle   in            raw,
                                      chars    in out nocopy varchar2,
                                      offset   in            integer,
                                      numChars in out        integer,
                                      lineFeed in            boolean);

PROCEDURE flushCharacterOutputStream (handle in raw);
PROCEDURE closeCharacterOutputStream (handle in raw);

----------------------------------------------------------------------------
-- isNull methods
----------------------------------------------------------------------------

FUNCTION StreamIsNull(handle raw)  RETURN BOOLEAN;

---------------------------------------------------------------------------
-- DOM NodeList interface:
--    
--    nodelist_item  
--    nodelist_getLength

--    nodelist_isNull (Extension)

--   freeNodeList (Extension)
---------------------------------------------------------------------------

/**
 * DOM NodeList interface methods
 * These methods implement the DOM NodeList interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-536297177
*/

 -- item:
 --
 -- Get the indexth item in the collection.  If index is greater than or 
 -- equal to the number of nodes in the list, this returns null.
 --
 -- PARAMETERS
 --      nl       - input DOM node list
 --      idx      - index into the list
 -- RETURN
 --      indexed child node 
 -- EXCEPTIONS
 --   <exception name> - <description>
 -- NOTES
 --      
 --
 -- FUNCTION domnodel_item (nl IN DOMNodeList, 
 --                         idx IN PLS_INTEGER) RETURN DOMNode;
FUNCTION item(nl DOMNodeList, idx IN PLS_INTEGER) RETURN DOMNode;

FUNCTION getLength(nl DOMNodeList) RETURN pls_INTEGER;

/**
 * DOM Node XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(nl DOMNodeList) RETURN BOOLEAN;


PROCEDURE freeNodeList(nl DOMNodeList);
---------------------------------------------------------------------------
-- DOM NamedNodeMap interface:
--    
--    getNamedItem
--    setNamedItem
--    removeNamedItem
--    namednodemap_item
--    namednodemap_getLength

--    namednodemap_isNull (Extension)

---------------------------------------------------------------------------

/**
 * DOM Node interface methods
 * These methods implement the DOM Node interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1950641247
 */

FUNCTION getNamedItem(nnm DOMNamedNodeMap, name IN VARCHAR2) RETURN DOMNode;
FUNCTION getNamedItem(nnm DOMNamedNodeMap, name IN VARCHAR2,
                      ns IN VARCHAR2) RETURN DOMNode;
FUNCTION setNamedItem(nnm DOMNamedNodeMap, arg IN DOMNode) RETURN DOMNode;
FUNCTION setNamedItem(nnm DOMNamedNodeMap, arg IN DOMNode,
                      ns IN VARCHAR2) RETURN DOMNode;
FUNCTION removeNamedItem(nnm DOMNamedNodeMap, name IN VARCHAR2) RETURN DOMNode;
FUNCTION removeNamedItem(nnm DOMNamedNodeMap, name IN VARCHAR2,
                         ns IN VARCHAR2) RETURN DOMNode;
FUNCTION item(nnm DOMNamedNodeMap, idx IN pls_integer) 
                           RETURN domNode;
FUNCTION getLength(nnm DOMNamedNodeMap) RETURN pls_integer;

/**
 * DOM Node XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(nnm DOMNamedNodeMap) RETURN BOOLEAN;


---------------------------------------------------------------------------
-- DOM Character Data interface:
--    
--    cdata_getData
--    cdata_setData
--    cdata_getLength
--    substringData
--    appendData
--    insertData
--    deleteData
--    replaceData
--    
--    cdata_isNull (extension)
--    cdata_makeNode (extension)

---------------------------------------------------------------------------

/**
 * DOM CharacterData interface methods
 * These methods implement the DOM CharacterData interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-FF21A306
 */

 -- getData:
 -- 
 -- Get data for character node
 --
 -- PARAMETERS
 --      cd       - input DOM Character node
 -- RETURN
 --      data for character node
 -- EXCEPTIONS
 --   <exception name> - <description>
 -- NOTES
 --      Returns data for character node, or NULL if node isn't
 --      character-type.
 --
 -- PROCEDURE domcdata_getCharData (cd IN DOMNode, data OUT VARCHAR2);
FUNCTION getData(cd domcharacterdata) return VARCHAR2;

PROCEDURE setData(cd DOMCharacterData, data IN VARCHAR2);
FUNCTION getLength(cd DOMCharacterData) RETURN pls_integer;
FUNCTION substringData(cd DOMCharacterData, offset IN PLS_INTEGER, 
                        cnt IN PLS_integer) RETURN VARCHAR2;
PROCEDURE appendData(cd DOMCharacterData, arg IN VARCHAR2);
PROCEDURE insertData(cd DOMCharacterData, offset IN PLS_INTEGER, arg IN VARCHAR2);
PROCEDURE deleteData(cd DOMCharacterData, offset IN PLS_INTEGER, cnt IN PLS_INTEGER);
PROCEDURE replaceData(cd DOMCharacterData, offset IN PLS_INTEGER, 
                      cnt IN PLS_INTEGER, arg IN VARCHAR2);

/**
 * DOM Node XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(cd DOMCharacterData) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(cd DOMCharacterData) RETURN DOMNode;


---------------------------------------------------------------------------
-- DOM Attribute interface:
--    
--    getName
--    getOwnerElement
--    getSpecified
--    getValue
--    setValue
--
--    attr_isNull (Extension)
--    attr_makeNode (Extension)
--    attr_getQualifiedName (Extension)
--    attr_getNamespace (Extension)
--    attr_getLocalName (Extension)
--    attr_getExpandedName (Extension)
--
---------------------------------------------------------------------------

/**
 * DOM interface methods
 * These methods implement the DOM Node interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1950641247
 */

FUNCTION getName(a DOMAttr) return varchar2;
FUNCTION getOwnerElement(a DOMAttr) RETURN DOMElement;
FUNCTION getSpecified(a DOMAttr) RETURN BOOLEAN;
FUNCTION getValue (a IN DOMAttr) return varchar2;
PROCEDURE setValue(a DOMAttr, newvalue IN VARCHAR2);

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(a DOMAttr) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(a DOMAttr) RETURN DOMNode;

FUNCTION getQualifiedName(a DOMAttr) return varchar2;
FUNCTION getNamespace(a DOMAttr) return varchar2;
FUNCTION getLocalName(a DOMAttr) return varchar2;
FUNCTION getExpandedName(a DOMAttr) return varchar2;


---------------------------------------------------------------------------
-- DOM Element interface:
--    
--    getTagName
--    getAttribute
--    hasAttribute
--    setAttribute
--    removeAttribute
--    getAttributeNode
--    setAttributeNode
--    removeAttributeNode
--    element_getElementsByTagName
--
--    element_isNull (Extension)
--    element_makeNode (Extension)
--    normalize (extension)
--    element_getQualifiedName (extension)
--    element_getNamespace (extension)
--    element_getLocalName (extension)
--    element_getExpandedName (extension)
--    getChildrenByTagName (extension)
--    getChildrenByTagName (extension)
--    resolveNamespacePrefix (extension)
--    freeElement (extension)
--
---------------------------------------------------------------------------

/**
 * DOM Element interface methods
 * These methods implement the DOM Element interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-745549614
 */

FUNCTION getTagName(elem DOMElement) return varchar2;
FUNCTION getAttribute(elem DOMElement, name IN VARCHAR2) return varchar2;
FUNCTION getAttribute(elem DOMElement, name IN VARCHAR2, 
                      ns IN VARCHAR2) return varchar2;
FUNCTION hasAttribute(elem DOMElement, name IN VARCHAR2) return BOOLEAN;
FUNCTION hasAttribute(elem DOMElement, name IN VARCHAR2,
                      ns IN VARCHAR2) return BOOLEAN;
PROCEDURE setAttribute(elem DOMElement, name IN VARCHAR2, newvalue IN VARCHAR2);
PROCEDURE setAttribute(elem DOMElement, name IN VARCHAR2, newvalue IN VARCHAR2,
                       ns IN VARCHAR2);
PROCEDURE removeAttribute(elem DOMElement, name IN VARCHAR2);
PROCEDURE removeAttribute(elem DOMElement, name IN VARCHAR2, ns IN VARCHAR2);
FUNCTION getAttributeNode(elem DOMElement, name IN VARCHAR2) RETURN DOMAttr;
FUNCTION getAttributeNode(elem DOMElement, name IN VARCHAR2,
                          ns IN VARCHAR2) RETURN DOMAttr;
FUNCTION setAttributeNode(elem DOMElement, newAttr IN DOMAttr) RETURN DOMAttr;
FUNCTION setAttributeNode(elem DOMElement, newAttr IN DOMAttr,
                          ns IN VARCHAR2) RETURN DOMAttr;
FUNCTION removeAttributeNode(elem DOMElement, oldAttr IN DOMAttr) 
RETURN DOMAttr;
FUNCTION getElementsByTagName(elem DOMElement, name IN VARCHAR2) 
                              RETURN DOMNodeList;
PROCEDURE freeElement(elem DOMElement);

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(elem DOMElement) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(elem DOMElement) RETURN domnode;

PROCEDURE normalize(elem DOMElement);
FUNCTION getQualifiedName(elem DOMElement) return varchar2;
FUNCTION getNamespace(elem DOMElement) return varchar2;
FUNCTION getLocalName(elem DOMElement) return varchar2;
FUNCTION getExpandedName(elem DOMElement) return varchar2;
FUNCTION getChildrenByTagName(elem DOMElement, name varchar2) 
                              return DOMNodeList;
FUNCTION getChildrenByTagName(elem DOMElement, name varchar2, ns varchar2) 
                              return DOMNodeList;
FUNCTION getElementsByTagName(elem DOMElement, name IN VARCHAR2, 
                                        ns varchar2) RETURN DOMNodeList;
PROCEDURE resolveNamespacePrefix(elem DOMElement, prefix varchar2, 
                                                  data OUT VARCHAR2);
FUNCTION resolveNamespacePrefix(elem DOMElement, prefix varchar2)
                                return VARCHAR2;


---------------------------------------------------------------------------
-- Interface DOMText:
--    
--    splitText
--    
--    text_isNull (extension)
--    text_makeNode (extension)
---------------------------------------------------------------------------

/**
 * DOM Text interface methods
 * These methods implement the DOM Text interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1312295772
*/

FUNCTION splitText(t DOMText, offset IN PLS_INTEGER) RETURN DOMText;

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(t DOMText) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(t DOMText) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface DOMComment
--    
--    comment_isNull (extension)
--    makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(com DOMComment) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(com DOMComment) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface DOMCDATASection
--    
--    cdatasection_isNull (extension)
--    makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(cds DOMCDATASection) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(cds DOMCDATASection) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface Document Type:
--    
--    getName
--    getEntities
--    getNotations
--    getpublicid (dom 2)
--    getsystemid (dom 2)
--   
--    doctype_isNull (extension)
--    makeNode (extension)
--    findEntity (extension)
--    findNotation (extension)
--    
---------------------------------------------------------------------------

/**
 * DOM DocumentType interface methods
 * These methods implement the DOM DocumentType interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-412266927
 */
FUNCTION getName(dt DOMDocumentType) return varchar2;
FUNCTION getEntities(dt DOMDocumentType) RETURN DOMNamedNodeMap;
FUNCTION getNotations(dt DOMDocumentType) RETURN DOMNamedNodeMap;

-- DOM 2
FUNCTION getPublicId(dt DOMDocumentType) return varchar2;
FUNCTION getSystemId(dt DOMDocumentType) return varchar2;

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(dt DOMDocumentType) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(dt DOMDocumentType) RETURN DOMNode;

-- Other
FUNCTION findEntity(dt DOMDocumentType, name varchar2, par boolean) 
                    return DOMEntity;
FUNCTION findNotation(dt DOMDocumentType, name varchar2) return DOMNotation;

---------------------------------------------------------------------------
-- Interface DOMNotation
--    
--    getPublicId
--    getSystemId
--
--    notation_isNull (extension)
--    makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM Notation interface methods
 * These methods implement the DOM Notation interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-5431D1B9
 */

FUNCTION getPublicId(n DOMNotation) return varchar2;
FUNCTION getSystemId(n DOMNotation) return varchar2;

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(n DOMNotation) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(n DOMNotation) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface DOMEntity:
--    
--    getPublicID
--    getSystemID
--    getNotationName
--    
--    entity_isNull (extension)
--    makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM Entity interface methods
 * These methods implement the DOM Entity interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-527DCFF2
 */
FUNCTION getPublicId(ent DOMEntity) return varchar2;
FUNCTION getSystemId(ent DOMEntity) return varchar2;
FUNCTION getNotationName(ent DOMEntity) return varchar2;

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(ent DOMEntity) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(ent DOMEntity) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface DOMEntityReference 
--    
--    entityref_isNull (extension)
--    makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(eref DOMEntityReference) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(eref DOMEntityReference) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface Processing Instruction:
--    
--    pi_getData
--    getTarget
--    pi_setData
--    
--    pi_isNull (extension)
--    pi_makeNode (extension)
--
---------------------------------------------------------------------------

/**
 * DOM ProcessingInstruction interface methods
 * These methods implement the DOM ProcessingInstruction interface as 
 * specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1004215813
 */

FUNCTION getData(pi DOMProcessingInstruction) return varchar2;
FUNCTION getTarget(pi DOMProcessingInstruction) return varchar2;
PROCEDURE setData(pi DOMProcessingInstruction, data IN VARCHAR2);

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(pi DOMProcessingInstruction) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(pi DOMProcessingInstruction) RETURN DOMNode;


---------------------------------------------------------------------------
-- Interface DocumentFragment:
--    
--    docfrag_isNull (extension)
--    makeNode (extension)
--
----------------------------------------------------------------------------

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(df DOMDocumentFragment) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(df DOMDocumentFragment) RETURN DOMNode;

PROCEDURE writeToBuffer(df DOMDocumentFragment, buffer IN OUT VARCHAR2);

PROCEDURE writeToBuffer(df DOMDocumentFragment, buffer IN OUT VARCHAR2,
                        pflag IN NUMBER, indent IN NUMBER);

---------------------------------------------------------------------------
-- Interface DOMDocument:
--    
--    getDoctype
--    setDoctype
--    getImplementation
--    getDocumentElement
--    createElement
--    createDocumentFragment
--    createComment
--    createTextNode
--    createCDATASection
--    createProcessingInstruction
--    createAttribute
--    createEntityReference
--    document_getElementsByTagName
--    importNode
--    adoptNode
--
--    document_isNull (extension)
--    document_makeNode (extension)
--    newDOMDocument (extension)
--    getVersion (extension)
--    setVersion (extension)
--    getCharset (extension)
--    setCharset (extension)
--    getStandalone (extension)
--    setStandalone (extension)
--    writeToFile (extension)
--    document_writeToBuffer (extension)
--    document_writeToClob (extension)
--    writeToFile (extension)
--    writeToBuffer (extension)
--    writeToClob (extension)
--    writeExternalDTDToFile (extension)
--    writeExternalDTDToBuffer (extension)
--    writeExternalDTDToClob (extension)
--    writeExternalDTDToFile (extension)
--    writeExternalDTDToBuffer (extension)
--    writeExternalDTDToClob (extension)
--    freeDocument (extension)
--
---------------------------------------------------------------------------

/**
 * DOM Document interface methods
 * These methods implement the DOM Document interface as specified in:
 * http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#i-Document
 */

FUNCTION getDoctype(doc DOMDocument) RETURN DOMDocumentType;
PROCEDURE setDoctype(doc DOMDocument, name VARCHAR2, 
                     sysid VARCHAR2, pubid VARCHAR2);
FUNCTION getImplementation(doc DOMDocument) RETURN DOMImplementation;
FUNCTION getDocumentElement(doc DOMDocument) RETURN DOMElement;
FUNCTION createElement(doc DOMDocument, tagName IN VARCHAR2) RETURN DOMElement;
FUNCTION createElement(doc DOMDocument, tagName IN VARCHAR2,
                       ns IN VARCHAR2) RETURN DOMElement;
FUNCTION createDocumentFragment(doc DOMDocument) RETURN DOMDocumentFragment;
FUNCTION createTextNode(doc DOMDocument, data IN VARCHAR2) RETURN DOMText;
FUNCTION createComment(doc DOMDocument, data IN VARCHAR2) RETURN DOMComment;
FUNCTION createCDATASection(doc DOMDocument, data IN VARCHAR2) 
                            RETURN DOMCDATASection;
FUNCTION createProcessingInstruction(doc DOMDocument, target IN VARCHAR2, 
                                     data IN VARCHAR2) 
                                     RETURN DOMProcessingInstruction;
FUNCTION createAttribute(doc DOMDocument, name IN VARCHAR2) RETURN DOMAttr;
FUNCTION createAttribute(doc DOMDocument, name IN VARCHAR2,
                         ns IN VARCHAR2) RETURN DOMAttr;
FUNCTION createEntityReference(doc DOMDocument, name IN VARCHAR2) 
                               RETURN DOMEntityReference;

FUNCTION getElementsByTagName(doc DOMDocument, tagname IN VARCHAR2) 
                                       RETURN DOMNodeList;
 -------------------------getDocElementsByTagName--------------------------
 -- Get element by tag name
 --
 -- PARAMETERS
 --      doc          - input DOM Document
 --      tagname      - tagname of new element.
 -- RETURN
 --      Elements list.
 -- EXCEPTIONS
 --   <exception name> - <description>
 -- NOTES
 --    
 --
 -- FUNCTION domdoc_getElementsByTagName(doc IN DOMDocument, 
 --                                      tagname IN VARCHAR2) 
 --                                      RETURN DOMNodeList;

/**
 * DOM XDK interface methods
 */

-- Check validity of object
FUNCTION isNull(doc DOMDocument) RETURN BOOLEAN;

-- Cast
FUNCTION makeNode(doc DOMDocument) RETURN DOMNode;

-- New document
FUNCTION newDOMDocument RETURN domdocument;
FUNCTION newDOMDocument(xmldoc IN sys.xmltype) RETURN DOMDocument;
----------------------------------create----------------------------------
 -- Create domdocument given xmltype
 --
 -- PARAMETERS
 --      xmldoc       - input xmltype
 -- RETURN
 --      DOM Document
 -- EXCEPTIONS
 --   <exception name> - <description>
 -- NOTES
 --    
 --
 -- FUNCTION domdoc_create(xmldoc IN sys.xmltype) RETURN DOMDocument;

FUNCTION newDOMDocument(cl IN clob) RETURN domdocument;
FUNCTION getxmltype(doc in DOMDocument) RETURN sys.xmltype;

FUNCTION getVersion(doc DOMDocument) return varchar2;
PROCEDURE setVersion(doc DOMDocument, version VARCHAR2);
FUNCTION getCharset(doc DOMDocument) return varchar2;
PROCEDURE setCharset(doc DOMDocument, charset VARCHAR2);
FUNCTION getStandalone(doc DOMDocument) return varchar2;
PROCEDURE setStandalone(doc DOMDocument, newvalue VARCHAR2);
PROCEDURE writeToFile(doc DOMDocument, fileName VARCHAR2);
PROCEDURE writeToBuffer(doc DOMDocument, buffer IN OUT VARCHAR2);
PROCEDURE writeToClob(doc DOMDocument, cl IN OUT CLOB);
PROCEDURE writeToFile(doc DOMDocument, fileName VARCHAR2,
                      pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToBuffer(doc DOMDocument, buffer IN OUT VARCHAR2,
                         pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToClob(doc DOMDocument, cl IN OUT CLOB,
                      pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToFile(doc DOMDocument, fileName VARCHAR2, charset VARCHAR2);
PROCEDURE writeToBuffer(doc DOMDocument, buffer IN OUT VARCHAR2, 
                        charset VARCHAR2);
PROCEDURE writeToClob(doc DOMDocument, cl IN OUT CLOB, charset VARCHAR2);
PROCEDURE writeToFile(doc DOMDocument, fileName VARCHAR2, charset VARCHAR2,
                      pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToBuffer(doc DOMDocument, buffer IN OUT VARCHAR2,
                        charset VARCHAR2, pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeToClob(doc DOMDocument, cl IN OUT CLOB, charset VARCHAR2,
                         pflag IN NUMBER, indent IN NUMBER);
PROCEDURE writeExternalDTDToFile(doc DOMDocument, fileName varchar2);
PROCEDURE writeExternalDTDToBuffer(doc DOMDocument, buffer in out varchar2);
PROCEDURE writeExternalDTDToClob(doc DOMDocument, cl in out clob);
PROCEDURE writeExternalDTDToFile(doc DOMDocument, fileName varchar2, 
                                 charset varchar2);
PROCEDURE writeExternalDTDToBuffer(doc DOMDocument, buffer in out varchar2, 
                                   charset varchar2);
PROCEDURE writeExternalDTDToClob(doc DOMDocument, cl in out clob, 
                                                  charset varchar2);

PROCEDURE freeDocument(doc DOMDocument);
PROCEDURE freeDocFrag(df IN DOMDocumentFragment);
PROCEDURE freeDocType(dt IN DOMDocumentType);
-- PROCEDURE domdoc_remove (doc IN domdocument);

FUNCTION importnode(doc DOMDocument, importednode domnode, deep boolean) 
                    RETURN DOMNode;
FUNCTION adoptnode(doc DOMDocument, adoptednode domnode) 
                   RETURN DOMNode;

end dbms_xmldom;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLDOM FOR xdb.dbms_xmldom
/
CREATE OR REPLACE PUBLIC SYNONYM xmldom FOR xdb.dbms_xmldom
/
CREATE OR REPLACE SYNONYM sys.xmldom FOR xdb.dbms_xmldom
/
GRANT EXECUTE ON xdb.dbms_xmldom TO PUBLIC
/
GRANT EXECUTE ON sys.xmldom TO PUBLIC
/
show errors;

