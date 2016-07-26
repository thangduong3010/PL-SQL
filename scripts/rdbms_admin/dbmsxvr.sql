Rem
Rem $Header: dbmsxvr.sql 18-jan-2006.17:18:06 thbaby Exp $
Rem
Rem dbmsxvr.sql
Rem
Rem Copyright (c) 2003, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxvr.sql - DBMS_XDB_VERSION package
Rem
Rem    DESCRIPTION
Rem      Package definiton and body of dbms_xdb_version package.
Rem
Rem    NOTES
Rem      Split out from catxdbvr for the purposes of independent loading
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      12/30/05 - new checkout api 
Rem    thbaby      12/30/05 - default parameter values 
Rem    thbaby      11/09/05 - add workspace related API routines 
Rem    vkapoor     03/07/05 - 
Rem    vkapoor     02/03/05 - bug 4075243 
Rem    vkapoor     02/06/05 - bug 4075253 
Rem    najain      10/01/04 - dbms_xdb_version is invoker\'s rights
Rem    spannala    12/23/03 - spannala_bug-3321840 
Rem    spannala    12/16/03 - Created
Rem

/* Package DBMS_XDB_VERSION */
create or replace package XDB.DBMS_XDB_VERSION authid current_user as

  SUBTYPE resid_type is RAW(16);
  TYPE resid_list_type is VARRAY(1000) of RAW(16);

  FUNCTION makeversioned(pathname VARCHAR2) RETURN resid_type;
  PROCEDURE checkout(pathname VARCHAR2);
  FUNCTION checkin(pathname VARCHAR2) RETURN resid_type;
  FUNCTION uncheckout(pathname VARCHAR2) RETURN resid_type;
  FUNCTION ischeckedout(pathname VARCHAR2) RETURN BOOLEAN;
  FUNCTION GetPredecessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetSuccessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType;
  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB;
  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB;
  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType;
  FUNCTION GetVersionHistoryID(pathname VARCHAR2) RETURN resid_type;
  FUNCTION GetVersionHistory(resid resid_type) RETURN resid_list_type;
  FUNCTION GetVersionHistoryRoot(resid resid_type) RETURN resid_type;

---------------------------------------------
-- PROCEDURE - CreateRealWorkspace
-- This procedure creates a real workspace called wsname, if a workspace (real 
-- or virtual) with the same name does not exist already. An existing real 
-- workspace\'s name can be given in the initializer argument, in which case, 
-- the folder hierarchy of that workspace is used to set up the folder 
-- hierarchy of the new workspace. All non-VCRs in the initializing workspace 
-- will be present in the new workspace. This includes non-VCRs in the 
-- initializing workspace that it shares with other real workspaces. If 
-- 'published' is TRUE, the new workspace is published; otherwise, it is not. 
-- Note that the create index privilege on the resource table is required to 
-- create a published workspace.
-- 
-- If a VCR is checked out in the initializing workspace, its DAV:checked-out 
-- property is used as the version for the corresponding VCR in the new 
-- workspace. If a VCR is not checked out in the initializing workspace, its 
-- DAV:checked-in property is used as the version for the corresponding VCR in 
-- the new workspace. If privateNonVCR is TRUE, all non-VCRs selected to be in 
-- the new workspace are made private to it and not shared with the 
-- initializing workspace; otherwise, non-VCRs that the initializing workspace 
-- shares with other workspaces continue to remain shared in the new workspace 
-- also. 
-- 
-- PARAMETERS: 
-- wsname	       	-	Name of the workspace being created.
-- published      	-	If TRUE, the new workspace is published; 
--                              otherwise, it is not. 
-- initializer      	- 	Name of the initializer workspace. 
-- privateNonVCR 	-	Should non-VCRs in initializer workspace be 
--                              made private in new workspace?
---------------------------------------------
  PROCEDURE CreateRealWorkspace(wsname        IN VARCHAR2, 
                                initializer   IN VARCHAR2,
                                published     IN BOOLEAN, 
                                privateNonVCR IN boolean);

---------------------------------------------
-- PROCEDURE - CreateVirtualWorkspace
-- This procedure creates a virtual workspace called wsname based on the 
-- hierarchy of another workspace (base_wsname). No workspace, real or 
-- virtual, with the same name must exist. If not, an error is thrown. 
-- base_wsname must be the name of a real workspace that has no checked out 
-- resources, or else an error is thrown.
-- 
-- PARAMETERS: 
-- wsname 		- Name of the workspace to be created
-- base_wsname 	        - Name of the real workspace on which the virtual 
--                        workspace is based. 
---------------------------------------------
  PROCEDURE CreateVirtualWorkspace(wsname      IN VARCHAR2, 
                                   base_wsname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - DeleteWorkspace
-- This procedure deletes the workspace named wsname. If a workspace with this 
-- name does not exist, an error is thrown. The workspace must not have any 
-- checked-out resources and must not have any dependent virtual workspaces; 
-- otherwise, an error is thrown. The null workspace cannot be deleted. If a 
-- real workspace is deleted, its folder hierarchy is deleted. 
-- 
-- PARAMETERS: 
-- wsname	-	Name of the workspace to be deleted
---------------------------------------------
  PROCEDURE DeleteWorkspace(wsname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - SetWorkspace  
-- This procedure sets the current session\'s workspace to the workspace named 
-- wsname. If a workspace with this name does not exist, an error is thrown. 
-- The root of the folder hierarchy ('/') in the current session is set to the 
-- root of the workspace's folder hierarchy. 
-- 
-- PARAMETERS: 
-- wsname	- Name of the workspace to be used by current session
---------------------------------------------
  PROCEDURE SetWorkspace(wsname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - GetWorkspace
-- This procedure returns the name of the current workspace. The workspace 
-- could have been set explicitly by the user (via SetWorkspace or its 
-- equivalents in protocols) or could be the default workspace. 
---------------------------------------------
  PROCEDURE GetWorkspace(wsname OUT VARCHAR2);

---------------------------------------------
-- PROCEDURE - PublishWorkspace
-- This procedure publishes the real workspace named wsname. If a real 
-- workspace with this name does not exist, an error is thrown. Publishing a 
-- workspace improves the performance of Btree indexes for queries in the 
-- context of the workspace. Only real workspaces can be published. Note that 
-- the create index privilege on the resource table is required to publish a 
-- workspace.
-- 
-- PARAMETERS: 
-- wsname	- Name of the workspace to be published 
---------------------------------------------
  PROCEDURE PublishWorkspace(wsname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - UnPublishWorkspace
-- This procedure un-publishes the real workspace named wsname. If a real 
-- workspace with this name does not exist, an error is thrown. Un-publishing 
-- a workspace removes its association with Btree indexes on XDB$RESOURCE 
-- table and the workspace will no more provide improved performance for those 
-- indexes.  Note that the drop index privilege on the resource table is 
-- required to unpublish a workspace.
-- 
-- PARAMETERS: 
-- wsname	- Name of the workspace to be unpublished 
---------------------------------------------
  PROCEDURE UnPublishWorkspace(wsname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - UpdateWorkspace
-- This procedure updates (where the term "update" is used in the DeltaV
-- sense of the term) the workspace named target_wsname by using the
-- folder hierarchy and VCRs of the workspace named
-- source_wsname. target_wsname must be the name of a valid workspace
-- that can be updated and source_wsname must be the name of a real
-- workspace; otherwise, an error is thrown. If the target workspace
-- has checked-out VCRs or if it is virtual and has private copies, an
-- error is thrown.
-- 
-- Non-VCRs and VCRs are created/deleted/updated (update in the deltaV
-- sense) as required to make the source and target workspaces
-- identical. If the target workspace is real and if privateNonVCR is
-- TRUE, all non-VCRs selected to be in the target workspace are made
-- private to it and not shared with the source workspace; otherwise,
-- non-VCRs that the source workspace shares with other workspaces
-- continue to remain shared in the new workspace also. 
-- 
-- If a VCR is checked out in the source workspace, the value of its
-- DAV:checked-out property is used as the version for the corresponding
-- VCR in the target workspace. If a VCR is not checked out in the source
-- workspace, the value of its DAV:checked-in property is used as the
-- version for the corresponding VCR in the target workspace.  
-- 
-- PARAMETERS: 
-- target_wsname  - Name of the target workspace
-- source_wsname  - Name of the source workspace
-- privateNonVCR  - Should all non-VCRs in the source be made private
--                  in the target? 
---------------------------------------------
  PROCEDURE UpdateWorkspace(target_wsname IN VARCHAR2,
                            source_wsname IN VARCHAR2,
                            privateNonVCR IN BOOLEAN);

---------------------------------------------
-- PROCEDURE - CreateBranch
-- This procedure creates a new branch. If a branch named name exists
-- already, an error is thrown.  
-- 
-- PARAMETERS:
-- name 	- Name of the branch to create
---------------------------------------------
  PROCEDURE CreateBranch(name IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - MakeShared
-- This procedure makes a private VCR in a virtual workspace shared with
-- that of the real workspace on which it is based. A VCR becomes
-- private to a virtual workspace when it is checked out or it is
-- updated to point to a version different from that of the VCR in the
-- corresponding real workspace. 
---------------------------------------------
  PROCEDURE MakeShared(path IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - CreateVCR
-- This procedure creates a checked-in VCR based on an existing
-- version. Path resolution is aware of the current session's workspace
-- and therefore 'path' can be relative to the current workspace's
-- folder. If a resource exists at the path, an error is
-- thrown. VersionResID must be the OID of a version and the workspace
-- must not have a VCR with the same version history as VersionResId;
-- otherwise, an error is thrown.  
-- 
-- PARAMETERS: 
-- path			- Path to VCR.
-- versionResID	        - OID of the version to be used for VCR
---------------------------------------------
  PROCEDURE CreateVCR(path IN VARCHAR2, versionResID IN resid_type);

---------------------------------------------
-- PROCEDURE - UpdateVCRVersion
-- This procedure updates the VCR at given path (path) with a version
-- identified by newResID. newResID must be the OID of a version in the
-- same version history as the VCR; otherwise, an error is thrown. Path
-- resolution is aware of the current session's workspace and therefore
-- 'path' can be relative to the current workspace's folder. 
-- 
-- PARAMETERS: 
-- path 	- Path to VCR.
-- newResID 	- OID of the version to which VCR needs to be updated
---------------------------------------------
  PROCEDURE UpdateVCRVersion(path IN VARCHAR2, newResID IN resid_type);

---------------------------------------------
-- PROCEDURE - DeleteVersion
-- This procedure deletes the version with OID versionResID. If a VCR (in
-- any workspace) points to this version, an error is thrown. If the
-- version being deleted is the root version of a version history
-- resource, it must have exactly one successor version; otherwise, an
-- error is thrown. The DAV:successor-set property of each of the
-- deleted version's predecessors is updated to include all the
-- versions in the deleted version's DAV:successor-set property and the
-- DAV:predecessor-set property of each of the deleted version's
-- successors is updated to include all the versions in the deleted
-- version's DAV:predecessor-set property.  
-- 
-- PARAMETERS: 
-- versionResID - OID of the version to be deleted
---------------------------------------------
  PROCEDURE DeleteVersion(versionResID IN resid_type);

---------------------------------------------
-- PROCEDURE - DeleteVersionHistory
-- This procedure deletes the version history with version history id
-- vhid. All versions in the version history are deleted. All
-- preconditions of DeleteVersion will apply to each version before
-- it's deleted. If any version cannot be deleted the entire operation
-- is rolled back. 
-- 
-- PARAMETERS: 
-- vhid - VHID of the version history to be deleted
---------------------------------------------
  PROCEDURE DeleteVersionHistory(vhid resid_type);

end DBMS_XDB_VERSION;
/
show errors;

/* library for DBMS_XDB_VERSION */
CREATE OR REPLACE LIBRARY XDB.DBMS_XDB_VERSION_LIB TRUSTED AS STATIC
/

/* package body */
create or replace package body XDB.DBMS_XDB_VERSION as
  FUNCTION makeversioned(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsMakeVersioned"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  PROCEDURE checkout(pathname varchar2) is
    LANGUAGE C NAME "qmevsCheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname     OCIString, 
                  pathname indicator sb4);

  FUNCTION checkin(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsCheckin"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION uncheckout(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsUncheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION ischeckedout(pathname varchar2) RETURN BOOLEAN is
    LANGUAGE C NAME "qmevsIsResCheckedOut"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4, 
                  return
                 );

  FUNCTION getresid(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsGetResID"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION GetPredecessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetPredsByResId(resid);
  END;

  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetPredsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetSuccessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetSuccsByResId(resid);
  END;

  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetSuccsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetResByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB is
    LANGUAGE C NAME "qmevsGetCtsBlobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB is
    LANGUAGE C NAME "qmevsGetCtsClobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetCtsXmlByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetVersionHistoryID(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsGetVerHistID"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION GetVersionHistory(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetVerHist"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetVersionHistoryRoot(resid resid_type) RETURN resid_type IS
    LANGUAGE C NAME "qmevsGetVerHistRoot"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  PROCEDURE CreateRealWorkspace(wsname        IN VARCHAR2, 
                                initializer   IN VARCHAR2,
                                published     IN boolean, 
                                privateNonVCR IN boolean) IS
    LANGUAGE C NAME "qmevsCreateRealWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname            OCIString, 
                  wsname        indicator sb4,
                  initializer       OCIString, 
                  initializer   indicator sb4,
                  published               ub2, 
                  published     indicator sb4,
                  privateNonVCR           ub2, 
                  privateNonVCR indicator sb4
                 );

  PROCEDURE CreateVirtualWorkspace(wsname      IN VARCHAR2, 
                                   base_wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsCreateVirtualWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname          OCIString, 
                  wsname      indicator sb4,
                  base_wsname     OCIString, 
                  base_wsname indicator sb4
                 );

  PROCEDURE DeleteWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsDeleteWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE SetWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsSetWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE GetWorkspace(wsname OUT VARCHAR2) IS
    LANGUAGE C NAME "qmevsGetWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname          STRING,
                  wsname   INDICATOR sb4,
                  wsname      LENGTH sb4,
                  wsname      MAXLEN sb4
                 );

  PROCEDURE PublishWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsPublishWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE UnPublishWorkspace(wsname IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsUnPublishWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  wsname     OCIString, 
                  wsname indicator sb4
                 );

  PROCEDURE UpdateWorkspace(target_wsname IN VARCHAR2,
                            source_wsname IN VARCHAR2,
                            privateNonVCR IN BOOLEAN) IS
    LANGUAGE C NAME "qmevsUpdateWS"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  target_wsname     OCIString, 
                  target_wsname indicator sb4,
                  source_wsname     OCIString, 
                  source_wsname indicator sb4,
                  privateNonVCR           ub2,
                  privateNonVCR indicator sb4
                 );

  PROCEDURE CreateBranch(name IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsCreateBranch"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  name      OCIString, 
                  name  indicator sb4
                 );

  PROCEDURE MakeShared(path IN VARCHAR2) IS
    LANGUAGE C NAME "qmevsMakeShared"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path         OCIString, 
                  path     indicator sb4
                 );

  PROCEDURE CreateVCR(path IN VARCHAR2, versionResID IN resid_type) IS
    LANGUAGE C NAME "qmevsCreateVCR"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path             OCIString, 
                  path         indicator sb4,
                  versionResID        OCIRaw,
                  versionResID indicator sb4
                 );

  PROCEDURE UpdateVCRVersion(path IN VARCHAR2, newResID IN resid_type) IS
    LANGUAGE C NAME "qmevsUpdateVCR"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  path             OCIString, 
                  path         indicator sb4,
                  newResID            OCIRaw,
                  newResID     indicator sb4
                 );

  PROCEDURE DeleteVersion(versionResID IN resid_type) IS
    LANGUAGE C NAME "qmevsDelVersion"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  versionResID        OCIRaw,
                  versionResID indicator sb4
                 );

  PROCEDURE DeleteVersionHistory(vhid resid_type) IS
    LANGUAGE C NAME "qmevsDeleteVerHist"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  vhid        OCIRaw,
                  vhid indicator sb4
                 );

end DBMS_XDB_VERSION;
/
show errors;
GRANT EXECUTE ON XDB.DBMS_XDB_VERSION TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_VERSION FOR XDB.DBMS_XDB_VERSION;
