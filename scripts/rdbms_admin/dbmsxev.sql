Rem
Rem $Header: rdbms/admin/dbmsxev.sql /main/3 2008/12/08 14:56:56 llsun Exp $
Rem
Rem dbmsxev.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      dbmsxev.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    llsun       08/01/08 - size of event handlers -> 32 
Rem    petam       05/02/06 - fix for bug 5197943 
Rem    thoang      04/26/04 - Created
Rem

Grant execute on xdb.xdb_privileges to public with grant option;

CREATE OR REPLACE PACKAGE xdb.dbms_XEvent AUTHID CURRENT_USER IS 
   
------------
-- CONSTANTS
------------

--
-- Event ID
--
RENDER_EVENT                        CONSTANT PLS_INTEGER := 1;
PRE_CREATE_EVENT                    CONSTANT PLS_INTEGER := 2;
POST_CREATE_EVENT                   CONSTANT PLS_INTEGER := 3;
PRE_DELETE_EVENT                    CONSTANT PLS_INTEGER := 4;
POST_DELETE_EVENT                   CONSTANT PLS_INTEGER := 5;
PRE_UPDATE_EVENT                    CONSTANT PLS_INTEGER := 6;
POST_UPDATE_EVENT                   CONSTANT PLS_INTEGER := 7;
PRE_LOCK_EVENT                      CONSTANT PLS_INTEGER := 8;
POST_LOCK_EVENT                     CONSTANT PLS_INTEGER := 9;
PRE_UNLOCK_EVENT                    CONSTANT PLS_INTEGER := 10;
POST_UNLOCK_EVENT                   CONSTANT PLS_INTEGER := 11;
PRE_LINKIN_EVENT                    CONSTANT PLS_INTEGER := 12;
POST_LINKIN_EVENT                   CONSTANT PLS_INTEGER := 13;
PRE_LINKTO_EVENT                    CONSTANT PLS_INTEGER := 14;
POST_LINKTO_EVENT                   CONSTANT PLS_INTEGER := 15;
PRE_UNLINKIN_EVENT                  CONSTANT PLS_INTEGER := 16;
POST_UNLINKIN_EVENT                 CONSTANT PLS_INTEGER := 17;
PRE_UNLINKFROM_EVENT                CONSTANT PLS_INTEGER := 18;
POST_UNLINKFROM_EVENT               CONSTANT PLS_INTEGER := 19;
PRE_CHECKIN_EVENT                   CONSTANT PLS_INTEGER := 20;
POST_CHECKIN_EVENT                  CONSTANT PLS_INTEGER := 21;
PRE_CHECKOUT_EVENT                  CONSTANT PLS_INTEGER := 22;
POST_CHECKOUT_EVENT                 CONSTANT PLS_INTEGER := 23;
PRE_UNCHECKOUT_EVENT                CONSTANT PLS_INTEGER := 24;
POST_UNCHECKOUT_EVENT               CONSTANT PLS_INTEGER := 25;
PRE_VERSIONCONTROL_EVENT            CONSTANT PLS_INTEGER := 26;
POST_VERSIONCONTROL_EVENT           CONSTANT PLS_INTEGER := 27;
PRE_OPEN_EVENT                      CONSTANT PLS_INTEGER := 28;
POST_OPEN_EVENT                     CONSTANT PLS_INTEGER := 29;
PRE_INCONSISTENTUPDATE_EVENT        CONSTANT PLS_INTEGER := 30;
POST_INCONSISTENTUPDATE_EVENT       CONSTANT PLS_INTEGER := 31;

SUBTYPE XDBEventID IS PLS_INTEGER RANGE 1 .. 31; 

--
-- NFS related constants
--
OPEN_ACCESS_READ           CONSTANT PLS_INTEGER := 1;
OPEN_ACCESS_WRITE          CONSTANT PLS_INTEGER := 2;
OPEN_ACCESS_READ_WRITE     CONSTANT PLS_INTEGER := 3;

OPEN_DENY_NONE             CONSTANT PLS_INTEGER := 0;
OPEN_DENY_READ             CONSTANT PLS_INTEGER := 1;
OPEN_DENY_READ_WRITE       CONSTANT PLS_INTEGER := 2;

--
-- Event interface types 
--
SUBTYPE EventType IS RAW(32);
SUBTYPE XDBRepositoryEvent is RAW(32);

TYPE XDBEvent is RECORD (id RAW(32));
TYPE XDBHandlerList is RECORD (id RAW(32));
TYPE XDBHandler is RECORD (id RAW(32));
TYPE XDBPath is RECORD (id RAW(32));
TYPE XDBLink is RECORD (id RAW(32));
TYPE XDBLock is RECORD (id RAW(32));
 
---------------------------------------------
--        XDBEvent Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getCurrentUser
-- PARAMETERS -
--  ev  - XDB Event object
-- RETURNS -
--  Name of the user executing the operation that triggers the event.
---------------------------------------------
FUNCTION getCurrentUser(ev IN XDBEvent) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getEvent
-- PARAMETERS -
--  ev  - XDB Event object
-- RETURNS -
--   The ID identifying the triggering event. 
---------------------------------------------
FUNCTION getEvent(ev IN XDBEvent) RETURN XDBEventID;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  ev  - XDB Event object
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(ev IN XDBEvent) RETURN BOOLEAN;

---------------------------------------------
--        XDBRepositoryEvent Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getXDBEvent
--   Converts an XDBRepositoryEvent object to an  XDBEvent type.
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS - 
--  The XDBEvent object
---------------------------------------------
FUNCTION getXDBEvent(ev IN XDBRepositoryEvent) RETURN XDBEvent;

---------------------------------------------
-- FUNCTION - getInterface
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The top-level interface used to initiate the operation that 
--  triggered the event. This could be "HTTP", "FTP" or "SQL".
---------------------------------------------
FUNCTION getInterface(ev IN XDBRepositoryEvent) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getApplicationData
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The <applicationData> element extracted from the resource 
--  configuration that defines the invoking handler. 
---------------------------------------------
FUNCTION getApplicationData(ev IN XDBRepositoryEvent) RETURN SYS.XMLType;

---------------------------------------------
-- FUNCTION - getPath
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The XDBPath object representing the path of the resource for which 
--  the event was fired. From this object, functions are provided to get  
--  the different path segments.
---------------------------------------------
FUNCTION getPath(ev IN XDBRepositoryEvent) RETURN XDBPath;

---------------------------------------------
-- FUNCTION - getResource
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The target resource for the operation that fire the current event.
--  For a link* or unlink* event, this method returns the resource that 
--  the link is pointing to.
--  For a create event, this method  returns the resource that is being created.
---------------------------------------------
FUNCTION getResource(ev IN XDBRepositoryEvent) 
                RETURN DBMS_XDBResource.XDBResource;

---------------------------------------------
-- FUNCTION - getParent
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The parent of the target resource.
---------------------------------------------
FUNCTION getParent(ev IN XDBRepositoryEvent) 
                RETURN DBMS_XDBResource.XDBResource;

---------------------------------------------
-- FUNCTION - getHandlerList
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The list of handlers that will be executed after the currently 
--  executing handler.
---------------------------------------------
FUNCTION getHandlerList(ev IN XDBRepositoryEvent) RETURN XDBHandlerList;

---------------------------------------------
-- FUNCTION - getLink
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  an XDBLink object for the target resource.
---------------------------------------------
FUNCTION getLink(ev IN XDBRepositoryEvent) RETURN XDBLink;

---------------------------------------------
-- FUNCTION - getLock
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  This method is only valid for the lock and unlock events. It returns 
--  the lock object corresponding to the current operation.
---------------------------------------------
FUNCTION getLock(ev IN XDBRepositoryEvent) RETURN XDBLock;

---------------------------------------------
-- FUNCTION - getParameter
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  The value of a request or session-specific parameter. Currently, the 
--  only parameters supported are "Accept", "Accept-Language", "Accept-Charset"
--  and "Accept-Encoding". 
--  The definition of these parameters can be found in RFC 2616 (HTTP/1.1). 
---------------------------------------------
FUNCTION getParameter(ev IN XDBRepositoryEvent, key IN VARCHAR2) 
                              RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getOldResource
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  Returns the original XDBResource object before the current operation 
--  started. This method applies only to Update event. For other events, 
--   an error is returned.
---------------------------------------------
FUNCTION getOldResource(ev IN XDBRepositoryEvent) 
                RETURN DBMS_XDBResource.XDBResource;

---------------------------------------------
-- FUNCTION - getOutputStream
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  This is only valid for the Render event. It returns the output BLOB in 
--  which the handler can write the rendered data.
---------------------------------------------
FUNCTION getOutputStream(ev IN XDBRepositoryEvent) RETURN BLOB;

---------------------------------------------
-- PROCEDURE - setRenderStream
--  This is only valid for the Render event. Sets the BLOB from which the 
--  rendered contents can be read. This should not be called after the 
--  stream returned by getOutputStream() is written to or after 
--  setRenderPath() is called; doing so will result in an error.
-- PARAMETERS -
--  ev  - XDB Repository Event object
--  istr - input stream to get the rendered contents from
---------------------------------------------
PROCEDURE setRenderStream(ev IN XDBRepositoryEvent, istr IN BLOB); 

---------------------------------------------
-- PROCEDURE - setRenderPath
--  This is only valid for the Render event. Specifies the path of the 
--  resource that contains the rendered contents. This should not be called 
--  after the stream returned by getOutputStream() is written to or 
--  after setRenderStream() is called; doing so will result in an error.
-- PARAMETERS -
--  ev  - XDB Repository Event object
--  path - path of the resource containing the rendered contents
---------------------------------------------
PROCEDURE setRenderPath(ev IN XDBRepositoryEvent, path IN VARCHAR2); 

---------------------------------------------
-- FUNCTION - getUpdateByteOffset
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
-- This method is only valid for the inconsistent-update event. If the 
-- current operation is a byte-range write, it returns the byte offset at 
-- which the range begins
---------------------------------------------
FUNCTION getUpdateByteOffset(ev IN XDBRepositoryEvent) RETURN NUMBER;

---------------------------------------------
-- FUNCTION - getUpdateByteCount
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  This method is only valid for the inconsistent-update event. If the 
--  current operation is a byte-range write, it returns the byte count.
---------------------------------------------
FUNCTION getUpdateByteCount(ev IN XDBRepositoryEvent) RETURN NUMBER;

---------------------------------------------
-- FUNCTION - getOpenAccessMode
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  This method is only valid for the open event. It returns the access mode 
--  for the open operation, which could be one of:
--      OPEN_ACCESS_READ 
--      OPEN_ACCESS_WRITE
--      OPEN_ACCESS_READ_WRITE 
---------------------------------------------
FUNCTION getOpenAccessMode(ev IN XDBRepositoryEvent) RETURN PLS_INTEGER;

---------------------------------------------
-- FUNCTION - getOpenDenyMode
-- PARAMETERS -
--  ev  - XDB Repository Event object
-- RETURNS -
--  This method is only valid for the open event. It returns the deny mode 
--  for the open operation, which could be one of:
--      OPEN_DENY_NONE 
--      OPEN_DENY_READ 
--      OPEN_DENY_READ_WRITE
---------------------------------------------
FUNCTION getOpenDenyMode(ev IN XDBRepositoryEvent) RETURN PLS_INTEGER;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  repev - XDB Repository event object 
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(repev IN XDBRepositoryEvent) RETURN BOOLEAN;

---------------------------------------------
--        XDBHandlerList Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getFirst
-- PARAMETERS -
--  hl - XDB handler list.
-- RETURNS -
--  The first handler in the list.
---------------------------------------------
FUNCTION getFirst(hl IN XDBHandlerList) RETURN XDBHandler;

---------------------------------------------
-- FUNCTION - getNext
-- PARAMETERS -
--  hl - XDB handler list.
-- RETURNS -
--  Next handler in the list.
---------------------------------------------
FUNCTION getNext(hl IN XDBHandlerList) RETURN XDBHandler;

---------------------------------------------
-- FUNCTION - remove
-- Removes the given handler from the list.
-- PARAMETERS -
--  hl - XDB handler list.
--  handler - handler to be removed
---------------------------------------------
PROCEDURE remove(hl IN XDBHandlerList, handler IN XDBHandler);

---------------------------------------------
-- PROCEDURE - clear
-- Clears the handler list.
-- PARAMETERS -
--  hl - XDB handler list.
---------------------------------------------
PROCEDURE clear(hl IN XDBHandlerList);

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  hl - XDB handler list.
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(hl IN XDBHandlerList) RETURN BOOLEAN;

---------------------------------------------
--        XDBHandler Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getSource
-- PARAMETERS -
--  handler - an XDBHandler object
-- RETURNS - 
--  The name of the Java class, PL/SQL package or object type implementing 
--  the handler.
---------------------------------------------
FUNCTION getSource (handler IN XDBHandler) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getSchema
-- PARAMETERS -
--  handler - an XDBHandler object
-- RETURNS - 
--  the schema of the handler's source
---------------------------------------------
FUNCTION getSchema (handler IN XDBHandler) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getLanguage
-- PARAMETERS -
--  handler - an XDBHandler object
-- RETURNS -  
--  The implementation language of the handler
---------------------------------------------
FUNCTION getLanguage (handler IN XDBHandler) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  handler - the handler
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(handler IN XDBHandler) RETURN BOOLEAN;

---------------------------------------------
--        XDBPath Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getName
-- PARAMETERS -
--  path - a XDBPath object
-- RETURNS - 
--  the string representation of the path.
---------------------------------------------
FUNCTION getName (path IN XDBPath) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getName
-- PARAMETERS -
--  path - a XDBPath object
--  level - indicates the number of levels up the hierarchy. This value 
--          must be greater than zero. Level 1 means the immediate parent. 
--          If level exceeds the height of the tree then a null is returned.
-- RETURNS - 
--  The parent's path.
---------------------------------------------
FUNCTION getParentPath (path IN XDBPath, level IN PLS_INTEGER) RETURN XDBPath;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  path - a XDBPath object
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(path IN XDBPath) RETURN BOOLEAN;

---------------------------------------------
--        XDBLink Methods
---------------------------------------------

---------------------------------------------
-- FUNCTION - getParentName
-- PARAMETERS -
--  link - an XDBLink object
-- RETURNS - 
--  the link's parent folder's name.
---------------------------------------------
FUNCTION getParentName (link IN XDBLink) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getParentOID
-- PARAMETERS -
--  link - an XDBLink object
-- RETURNS - 
--  the link's parent folder's OID
---------------------------------------------
FUNCTION getParentOID (link IN XDBLink) RETURN RAW;

---------------------------------------------
-- FUNCTION - getChildOID
-- PARAMETERS -
--  link - an XDBLink object
-- RETURNS - 
--  the OID of the resource that the link is pointing to.
---------------------------------------------
FUNCTION getChildOID (link IN XDBLink) RETURN RAW;

---------------------------------------------
-- FUNCTION - getLinkName
-- PARAMETERS -
--  link - an XDBLink object
-- RETURNS - 
--  the name of the link
---------------------------------------------
FUNCTION getLinkName (link IN XDBLink) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  link - an XDBLink object
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(link IN XDBLink) RETURN BOOLEAN;

---------------------------------------------
--        XDBLock Methods
---------------------------------------------
SCOPE_EXCLUSIVE CONSTANT PLS_INTEGER      := 0;
SCOPE_SHARED CONSTANT PLS_INTEGER         := 1;
TYPE_WRITE CONSTANT PLS_INTEGER           := 0;
TYPE_READ_WRITE CONSTANT PLS_INTEGER      := 1;

---------------------------------------------
-- FUNCTION - getLockMode
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the lock's mode (shared or exlusive). 
---------------------------------------------
FUNCTION getLockMode (lk in XDBLock) RETURN PLS_INTEGER;

---------------------------------------------
-- FUNCTION - getLockType
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the lock's type (write or read-write)
---------------------------------------------
FUNCTION getLockType (lk in XDBLock) RETURN PLS_INTEGER;

---------------------------------------------
-- FUNCTION - getDAVToken
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the token id if this is a DAV lock. Otherwise null
---------------------------------------------
FUNCTION getDAVToken (lk in XDBLock) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getDAVOwner
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the DAV:owner if this is a DAV lock. Otherwise null
---------------------------------------------
FUNCTION getDAVOwner (lk in XDBLock) RETURN VARCHAR2;

---------------------------------------------
-- FUNCTION - getNFSNodeId
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the RAC node id if this is an NFSv4 lock. Otherwise null
---------------------------------------------
FUNCTION getNFSNodeId (lk in XDBLock) RETURN RAW;

---------------------------------------------
-- FUNCTION - getDepth
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  the depth of the lock (either 0 or INFINITY_DEPTH)
---------------------------------------------
FUNCTION getDepth (lk in XDBLock) RETURN PLS_INTEGER;

---------------------------------------------
-- FUNCTION - getExpiry
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - 
--  If DAV lock returns the date and time at which the lock will expire; 
--  otherwise returns null.
---------------------------------------------
FUNCTION getExpiry (lk in XDBLock) RETURN TIMESTAMP;

---------------------------------------------
-- FUNCTION - isNull
-- PARAMETERS -
--  lk - a XDBLock object
-- RETURNS - TRUE if input argument is null.
---------------------------------------------
FUNCTION isNull(lk IN XDBLock) RETURN BOOLEAN;

end dbms_XEvent;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XEvent FOR xdb.dbms_XEvent
/
GRANT EXECUTE ON xdb.dbms_XEvent TO PUBLIC
/
show errors;
