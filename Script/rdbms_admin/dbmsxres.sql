Rem
Rem $Header: dbmsxres.sql 04-dec-2006.19:13:39 mkandarp Exp $
Rem
Rem dbmsxres.sql
Rem
Rem Copyright (c) 2005, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxres.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mkandarp    12/04/06 - 5655708: Increase DOM handle size
Rem    ataracha    07/27/06 - Add getContentRef
Rem    thoang      08/09/04 - Add isNull function for XDBResource 
Rem    ataracha    03/19/04 - Add XDBResource and related APIs
Rem    thoang      09/13/04 - Created - Moved APIs from dbmsxdb.sql
Rem

CREATE OR REPLACE PACKAGE xdb.dbms_xdbresource AUTHID CURRENT_USER IS 
   
--------------------------------------------
-- TYPES
--
--------------------------------------------
SUBTYPE xdbrestype IS RAW(13);
TYPE XDBResource IS RECORD(id xdbrestype);

---------------------------------------------------------------------------
-- XDBResource related API
---------------------------------------------------------------------------

---------------------------------------------
-- FUNCTION - isNull
--    Checks if the input res is null.
-- PARAMETERS - 
--    res - input resource
-- RETURNS -
--    TRUE if the input res is null.
--------------------------------------------- 
FUNCTION isNull(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- PROCEDURE - freeResource
--    Frees any memory associated with an XDBResource 
-- PARAMETERS - 
--    res - The XDBResource to free
---------------------------------------------
PROCEDURE freeResource (res IN XDBResource);

---------------------------------------------
-- FUNCTION - getACL
--    Given an XDBResource, returns its ACL as string.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The ACL of the XDBResource as VARCHAR2
---------------------------------------------
FUNCTION getACL (res IN XDBResource) return VARCHAR2;

FUNCTION getACLDocFromRes(res IN XDBResource) return sys.xmltype;

---------------------------------------------
-- FUNCTION - getAuthor
--    Given an XDBResource, returns its author.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The Author of the XDBResource.
---------------------------------------------
FUNCTION getAuthor(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getCharacterSet
--    Given an XDBResource, returns its characterset.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The character set of the XDBResource.
---------------------------------------------
FUNCTION getCharacterSet(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getComment
--    Given an XDBResource, returns its comment.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The Comment of the XDBResource.
---------------------------------------------
FUNCTION getComment(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getContentType
--    Given an XDBResource, returns its content-type.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The content type of the XDBResource.
---------------------------------------------
FUNCTION getContentType(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getCreationDate
--    Given an XDBResource, returns its creation date.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The creation date of the XDBResource.
---------------------------------------------
FUNCTION getCreationDate(res IN XDBResource) return TIMESTAMP;

---------------------------------------------
-- FUNCTION - getCreator
--    Given an XDBResource, returns its creator.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The creator of the XDBResource.
---------------------------------------------
FUNCTION getCreator(res IN XDBResource) return VARCHAR2;

---------------------------------------------
-- FUNCTION - getDisplayName
--    Given an XDBResource, returns its display name.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The display name of the XDBResource.
---------------------------------------------
FUNCTION getDisplayName(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getLanguage
--    Given an XDBResource, returns its language.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The language of the XDBResource.
---------------------------------------------
FUNCTION getLanguage (res IN XDBResource) return VARCHAR2;

---------------------------------------------
-- FUNCTION - getLastModifier
--    Given an XDBResource, returns its last modifier.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The last modifier of the XDBResource.
---------------------------------------------
FUNCTION getLastModifier(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getModificationDate
--    Given an XDBResource, returns its modification date.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The modification date of the XDBResource.
---------------------------------------------
FUNCTION getModificationDate(res IN XDBResource)  return TIMESTAMP;

---------------------------------------------
-- FUNCTION - getOwner
--    Given an XDBResource, returns its owner.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The owner of the XDBResource.
---------------------------------------------
FUNCTION getOwner(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getRefCount
--    Given an XDBResource, returns its reference count.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
-- The reference count of the XDBResource.
---------------------------------------------
FUNCTION getRefCount (res IN XDBResource) return PLS_INTEGER;

---------------------------------------------
-- FUNCTION - getVersionId
--    Given an XDBResource, returns its version id.
-- PARAMETERS - 
--    res - An XDBResource
-- RETURNS -
--    The version id of the XDBResource.
---------------------------------------------
FUNCTION getVersionId(res IN XDBResource)  return PLS_INTEGER;

---------------------------------------------
-- PROCEDURE - setAuthor
--    Sets the author of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res    - An XDBResource
--    author - The new author
-- 
---------------------------------------------
PROCEDURE setAuthor(res IN OUT XDBResource, author IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setACL
--    Sets the acl of the given XDBResource to the path specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    ACLPath - The absolute path of the new acl
---------------------------------------------
PROCEDURE setACL(res IN OUT XDBResource, ACLPath IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setCharacterSet
--   Sets the character set of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    charset - The new charset
---------------------------------------------
PROCEDURE setCharacterSet(res IN OUT XDBResource, charSet IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setComment
--    Sets the comment of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    comment - The new comment
---------------------------------------------
PROCEDURE setComment(res IN OUT XDBResource, comment IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setContentType
--    Sets the content-type of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res      - An XDBResource
--    conttype - The new content-type
---------------------------------------------
PROCEDURE setContentType(res IN OUT XDBResource, conttype IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setDisplayName
--    Sets the display name of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    name    - The new display name
---------------------------------------------
PROCEDURE setDisplayName(res IN OUT XDBResource, name IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setLanguage
--    Sets the language of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    lang    - The new language
---------------------------------------------
PROCEDURE setLanguage(res IN OUT XDBResource, lang IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - setOwner
--    Sets the owner of the given XDBResource to the specified varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
--    owner   - The new owner
---------------------------------------------
PROCEDURE setOwner(res IN OUT XDBResource, owner IN VARCHAR2);

---------------------------------------------
-- FUNCTION - hasAuthorChanged
--    Returns TRUE if the author of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- 
---------------------------------------------
FUNCTION hasAuthorChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasCharacterSetChanged
--     Returns TRUE if the charset of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the charset of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasCharacterSetChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasCommentChanged
--     Returns TRUE if the comment of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the comment of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasCommentChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasContentTypeChanged
--     Returns TRUE if the content-type of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the content-type of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasContentTypeChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasContentChanged
--     Returns TRUE if the contents of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the contents of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasContentChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasCreationDateChanged
--     Returns TRUE if the creation date of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the creation date of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasCreationDateChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasCreatorChanged
--     Returns TRUE if the creator of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the creator of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasCreatorChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasDisplayName
--     Returns TRUE if the display name of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the display name of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasDisplayNameChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasLanguageChanged
--     Returns TRUE if the language of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the language of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasLanguageChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasLastModifierChanged
--     Returns TRUE if the last modifier of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the last modifier of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasLastModifierChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasModificationDate
--    Returns TRUE if the modification date of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the modification date of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasModificationDateChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasOwnerChanged
--     Returns TRUE if the owner of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the owner of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasOwnerChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasRefCountChanged
--     Returns TRUE if the reference count of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the reference count of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasRefCountChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasVersionId
--     Returns TRUE if the version id of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the version id of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasVersionIdChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - hasACLChanged
--     Returns TRUE if the ACL of the given resource has changed, 
--         FALSE otherwise.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the ACL of the given resource has changed, 
--         FALSE otherwise.
---------------------------------------------
FUNCTION hasACLChanged(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - isFolder
--    Checks if the given resource is a folder or not.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
-- TRUE if the given resource is a folder,
--         FALSE otherwise.
---------------------------------------------
FUNCTION isFolder(res IN XDBResource) return BOOLEAN;

---------------------------------------------
-- FUNCTION - getContentClob
--    Returns the contents of the resource as a clob.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
--    The contents as CLOB.
---------------------------------------------
FUNCTION getContentClob(res IN XDBResource)  return CLOB;

---------------------------------------------
-- FUNCTION - getContentBlob
--    Returns the contents of the resource as a blob.
-- PARAMETERS - 
--    res        - An XDBResource
--    csid - OUT - The character set id of the blob returned.
-- RETURNS -
--    The contents as BLOB.
---------------------------------------------
FUNCTION getContentBlob(res IN XDBResource, csid OUT PLS_INTEGER) return BLOB;

---------------------------------------------
-- FUNCTION - getContentXML
--    Returns the contents of the resource as an XMLType.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
--    The contents as XMLType.
---------------------------------------------
FUNCTION getContentXML(res IN XDBResource)  return SYS.XMLType;

---------------------------------------------
-- FUNCTION - getContentVarchar2
--    Returns the contents of the resource as an Varchar2.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
--    The contents as Varchar2.
---------------------------------------------
FUNCTION getContentVarchar2(res IN XDBResource)  return VARCHAR2;

---------------------------------------------
-- FUNCTION - getContentRef
--    Returns the contents of the resource as a Ref.
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
--    The contents as an XMLTypeRef.
---------------------------------------------
FUNCTION getContentRef(res IN XDBResource)  return REF SYS.XMLType;

---------------------------------------------
-- PROCEDURE - setContent
--    Replaces the contents of the given resource with the given clob.
-- PARAMETERS - 
--    res     - An XDBResource
--    data    - The clob
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN CLOB);

---------------------------------------------
-- PROCEDURE -
--    Replaces the contents of the given resource with the given blob.
-- PARAMETERS - 
--    res     - An XDBResource
--    data    - The blob
--    csid    - The character-set id of the blob
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN BLOB, csid IN PLS_INTEGER);
		
---------------------------------------------
-- PROCEDURE -
--    Replaces the contents of the given resource with the given XMLType.
-- PARAMETERS - 
--    res     - An XDBResource
--    data    - The XMLType
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN SYS.XMLType);

---------------------------------------------
-- PROCEDURE -
--    Replaces the contents of the given resource with the given string.
-- PARAMETERS - 
--    res     - An XDBResource
--    data    - The input string
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN VARCHAR2);

---------------------------------------------
-- PROCEDURE -
--    Replaces the contents of the given resource with the given REF to XMLType.
-- PARAMETERS - 
--    res     - An XDBResource
--    data    - The REF to XMLType
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN REF SYS.XMLType,
                     sticky IN BOOLEAN := TRUE);

---------------------------------------------
-- PROCEDURE -
--    Replaces the contents of the given resource with the given BFILE.
-- PARAMETERS -
--    res     - An XDBResource
--    data    - The input bfile 
--    csid_bfile  - The character set id of the bfile
---------------------------------------------
PROCEDURE setContent(res IN OUT XDBResource, data IN BFILE,
                     csid_bfile IN PLS_INTEGER);

---------------------------------------------
-- PROCEDURE - save
--    Updates the resource with any modifications that were done on it.
-- PARAMETERS - 
--    res     - An XDBResource
---------------------------------------------
PROCEDURE save(res IN XDBResource);

---------------------------------------------
-- FUNCTION - makeDocument
--    Converts the XDBResource to DOMDocument. This can be used in 
--      XMLDOM APIs. (Please refer to the XMLDOM package).
-- PARAMETERS - 
--    res     - An XDBResource
-- RETURNS -
--    The DOMDocument for this resource.
---------------------------------------------
FUNCTION makeDocument(res IN XDBResource) return DBMS_XMLDOM.DOMDocument;

FUNCTION hasChanged(res IN XDBResource, xpath IN VARCHAR2, 
                    bnamespace IN VARCHAR2) return BOOLEAN;

FUNCTION getCustomMetadata(res IN XDBResource, xpath IN VARCHAR2,
                           namespace IN VARCHAR2) return SYS.XMLType;

FUNCTION hasCustomMetadataChanged(res IN XDBResource) return BOOLEAN;

PROCEDURE setCustomMetadata(res IN XDBResource, xpath IN VARCHAR2,
                            namespace IN VARCHAR2, newMetadata IN SYS.XMLType);
end dbms_xdbresource;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_xdbresource FOR xdb.dbms_xdbresource
/
GRANT EXECUTE ON xdb.dbms_xdbresource TO PUBLIC
/
show errors;

