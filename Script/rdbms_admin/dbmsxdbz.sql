Rem
Rem $Header: rdbms/admin/dbmsxdbz.sql /main/26 2009/09/03 15:01:32 spetride Exp $
Rem
Rem dbmsxdbz.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxdbz.sql - xdb zecurity 
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    07/09/09 - dynamic group store for custom trust
Rem    badeoti     03/19/09 - clean up 11.2 packages
Rem                           move dbms_xdb_admin.createnoncekey to dbms_xdbz
Rem                           move dbms_xdbz.get_username to dbms_xdbz0
Rem    spetride    06/11/08 - support application users and roles
Rem    taahmed     10/11/07 - 
Rem    mrafiq      10/04/07 - 
Rem    vhosur      08/16/07 - Add fusion ACL validation
Rem    thbaby      06/21/07 - documentation for validateacl
Rem    mrafiq      05/22/07 - move ValidateAcl here from dbms_xdbutil_int
Rem    pnath       05/24/06 - add ENABLE_LINKS hierarchy type 
Rem    thbaby      06/04/06 - coalesce versioning constants 
Rem    petam       04/18/06 - remove get_valid_acl function from dbms_xdbz 
Rem    petam       03/07/06 - add function get_Valid_ACL 
Rem    petam       11/14/05 - add function to purge acl 
Rem    thbaby      12/29/05 - new parameter values to disable_hierarchy
Rem    thbaby      12/28/05 - add versioning-related hierarchy types 
Rem    abagrawa    04/12/04 - Add hierarchy_type to enable_hierarchy, 
Rem                           is_enabled
Rem    najain      08/08/03 - add get_username
Rem    nmontoya    01/13/03 - add format arg to get_userid
Rem    nmontoya    07/09/02 - ADD dbms_xdbz.purgeLdapCache
Rem    nmontoya    05/10/02 - ADD get_acloid AND get_userid
Rem    nmontoya    03/18/02 - move internal functions to dbms_xdbz0
Rem    nmontoya    02/11/02 - remove xdb_userid, ADD xdb_username
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    12/28/01 - making dbms_xdbz public
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    nmontoya    11/12/01 - remove insertres function 
Rem    nmontoya    10/17/01 - is_hierarchy_enabled function
Rem    nmontoya    09/12/01 - Add guid argument to checkprivrls
Rem    nmontoya    08/02/01 - Creation
  
CREATE OR REPLACE PACKAGE xdb.dbms_xdbz AUTHID CURRENT_USER IS 

------------
-- CONSTANTS
--
------------
NAME_FORMAT_SHORT         CONSTANT pls_integer := 1;
NAME_FORMAT_DISTINGUISHED CONSTANT pls_integer := 2;
NAME_FORMAT_APPLICATION   CONSTANT pls_integer := 5;

ENABLE_CONTENTS           CONSTANT pls_integer := 1;
ENABLE_RESMETADATA        CONSTANT pls_integer := 2;
ENABLE_VERSION            CONSTANT pls_integer := 4;  
ENABLE_LINKS              CONSTANT pls_integer := 8;

IS_ENABLED_CONTENTS       CONSTANT pls_integer := 1;
IS_ENABLED_RESMETADATA    CONSTANT pls_integer := 2;
IS_ENABLED_VERSION        CONSTANT pls_integer := 4;

DISABLE_VERSION           CONSTANT pls_integer := 1;
DISABLE_ALL               CONSTANT pls_integer := 2;
SKIP_SYSCONSACL_FLG       CONSTANT pls_integer := 0;

APPLICATION_USER          CONSTANT pls_integer := 0;
APPLICATION_ROLE          CONSTANT pls_integer := 1;

DELETE_APP_NOFORCE        CONSTANT pls_integer := 0;
DELETE_APP_FORCE          CONSTANT pls_integer := 1;

MODE_MEMBERSHIP_ADD       CONSTANT pls_integer := 0;
MODE_MEMBERSHIP_DELETE    CONSTANT pls_integer := 1;

----------------------------------------------------------------------------
-- PROCEDURE - enable_hierarchy
--     Enables XDB Hierarchy for a particular xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of the xmltype table/view
--  hierarchy_type
--     How to enable the hierarchy. Must be one or a combination of the 
--     following:
--     ENABLE_CONTENTS : enable hierarchy for contents i.e. this table will
--     store contents of resources in the repository. This flag cannot be 
---    combined with ENABLE_RESMETADATA. 
--     ENABLE_RESMETADATA : enable hierarchy for resource metadata i.e. this
--     table will store schema based custom metadata for resources. This flag
--     cannot be combined with ENABLE_CONTENTS. 
--     ENABLE_VERSION  : version-enable the xmltype table/view. This flag 
--     must be combined with either ENABLE_CONTENTS or ENABLE_RESMETADATA.
--  NOTE ON HIERARCHY TYPE: If a table is hierachy-enabled for contents or 
--  resource metadata, then it can be additionally version-enabled by 
--  calling this procedure. For example, a table that is hierarchy-enabled for
--  contents alone (ENABLE_CONTENTS) can be additionally version-enabled by 
--  calling this procedure with hierarchy_type ENABLE_CONTENTS+ENABLE_VERSION.
--  A table that is hierarchy-enabled for contents, irrespective of whether it 
--  is version-enabled or not, cannot be hierarchy-enabled for resource 
--  metadata. Similarly, a table that is hierarchy-enabled for resource 
--  metadata, irrespective of whether it is version-enabled or not, cannot be 
--  hierarchy-enabled for contents. A table that is hierarchy-enabled and 
--  version-enabled, irrespective of whether it is hierarchy-enabled for 
--  contents or resource metadata, cannot be version-disabled by calling
--  this procedure. 
--  NOTE ON VERSION-ENABLED TABLES: A resource that has REFs to schema-based 
--  content or metadata tables/views can be version-controlled only if all its
--  REFs point to version-enabled tables/views. Thus, if its content REF is not
--  null, then the REF must point to an xmltype table/view that is version-
--  enabled and hierarchy enabled for contents. Similarly, if it has a
--  non-null schema-based metadata REF, then the REF must point to an xmltype 
--  table/view that is version-enabled and hierarchy-enabled for resource 
--  metadata. 
--  schemareg
--     True iff called during schema registration (qmts.c).
----------------------------------------------------------------------------
PROCEDURE enable_hierarchy
(
   object_schema IN VARCHAR2, 
   object_name VARCHAR2,
   hierarchy_type IN pls_integer := ENABLE_CONTENTS,
   schemareg IN BOOLEAN := FALSE
);

----------------------------------------------------------------------------
-- PROCEDURE - disable_hierarchy
--     Disables XDB Hierarchy for a particular xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of teh xmltype table/view
--  hierarchy_type
--     How should the hierarchy be disabled? The various options are
--     (1) DISABLE_VERSION : disable versioning on the table/view. If the table
--     or view is not version-enabled, do nothing. Otherwise, version-disable
--     the table. If the table or view has more than one version per version 
--     history, throw error unless delete_old_versions is set to TRUE. 
--     (2) DISABLE_ALL : disable hierarchy and disable versioning on the 
--     table/view. If the table or view has more than one version per version 
--     history, throw error unless delete_old_versions is set to TRUE. 
--  delete_old_versions
--     Should old versions for a version history be deleted? 
--     (1) TRUE : delete all versions in each version history other than the 
--     one with the latest lastModifiedTime. 
--     (2) FALSE : do not delete old versions. The user needs to ensure that 
--     the table or view does not have more than one version per version
--     history; otherwise, an error is thrown. 
----------------------------------------------------------------------------
PROCEDURE disable_hierarchy(object_schema IN VARCHAR2, 
                            object_name VARCHAR2,
                            hierarchy_type IN PLS_INTEGER := DISABLE_ALL,
                            delete_old_versions IN BOOLEAN := FALSE);

----------------------------------------------------------------------------
-- FUNCTION - is_hierarchy_enabled
--     Checks if the XDB Hierarchy is enabled for a given xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of the xmltype table/view
--  hierarchy_type
--     The type of hierarchy to check for. Must be one of the following:
--     IS_ENABLED_CONTENTS : if table/view is hierarchy-enabled for contents 
--     IS_ENABLED_RESMETADATA : if table/view is hierarchy-enabled for 
--     resource metadata 
--     IS_ENABLED_VERSION : if table/view is version-enabled
-- RETURN - 
--     True, if given xmltype table/view has the XDB Hierarchy enabled of
--     the specified type
----------------------------------------------------------------------------
FUNCTION is_hierarchy_enabled(object_schema IN VARCHAR2, 
                              object_name VARCHAR2,
                              hierarchy_type IN pls_integer 
                                := IS_ENABLED_CONTENTS)
                              RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - purgeLdapCache
--     Purges ldap nickname cache
-- RETURNS
--     True if successful, false otherwise
---------------------------------------------
FUNCTION purgeLdapCache RETURN BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - get_acloid
--     Get's an ACL OID given the XDB Hierarchy path for the ACL Resource
-- PARAMETERS - 
--  acl_path
--     ACL Resource path in the XDB Hierarchy
--  acloid [OUT] 
--     Returns the corresponding ACLOID to the given ACL Resource
-- RETURN - 
--     True, if ACLOID is succesfully retrieved
--     The typical use of this function is to pass the acloid as an 
--     argument to the SYS_CHECKACL sql operator.
----------------------------------------------------------------------------
FUNCTION get_acloid(aclpath IN VARCHAR2, 
                    acloid OUT RAW) RETURN BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - get_userid
--     Retrieves the userid for the given user name 
-- PARAMETERS - 
--  username
--     Name of the resource user
--  userid [OUT] 
--     Returns the corresponding USERID for the given user name.
--  format (optional)
--     Format of the specified user name. By default, the name is assumed 
--     to be either a database user name or a LDAP nickname. The following 
--     are the allowed values for this argument : 
--        DBMS_XDBZ.NAME_FORMAT_SHORT
--        DBMS_XDBZ.NAME_FORMAT_DISTINGUISHED
--        DBMS_XDBZ.NAME_FORMAT_APPLICATION
-- RETURN - 
--     True, if USERID is succesfully retrieved
-- NOTE - 
--     The user name is first looked up in the local database, 
--     if it is not found there, and if an ldap server is available,
--     it is looked up in this latter one. In this case a GUID will be 
--     returned in USERID. 
--     The typical use of this function is to pass the userid as an 
--     argument to the SYS_CHECKACL sql operator.
----------------------------------------------------------------------------
FUNCTION get_userid(username IN VARCHAR2, 
                    userid OUT RAW,
                    format IN pls_integer := NAME_FORMAT_SHORT) RETURN BOOLEAN;

----------------------------------------------------------------------------
-- PROCEDURE - ValidateAcl
-- This function will validate the following aspects of the acl:
-- (1) Validate the security class for the acl. This validates the
--     security class and all its parents.
-- (2) Check for existence of the specified roles and users in each of the
--     aces.
-- (3) Validate that all custom privileges specified in the acl are
--     defined in the associated security class.
-- (4) Validate that security class of the parent acl is in the ancestor
--     tree of  the associated security class.
-- PARAMETERS - 
--  acloid [in] 
--     aclid of the acl to be validated
--     skip system constraining acls from certain validations(default false)
----------------------------------------------------------------------------
PROCEDURE ValidateAcl(acloid IN RAW,
                      skip_scacl IN pls_integer := SKIP_SYSCONSACL_FLG)
;

----------------------------------------------------------------------------
-- PROCEDURE - ValidateFusionAcl
-- This function will validate all aspects of the acl (covered by 
-- ValidateAcl) plus the following
-- (1) For a given acl chain, it must have a system constraining acl at 
--     its root.
-- (2) For any non-system constraining acl in this chain, all inheritance 
--     relationships till the first system constraining acl up in its 
--     chain should be constraining.
-- (3) For any acl in the system, which has a system constraining acl as its 
--     parent, the inheritance relationship between the two should be 
--     constraining.
-- PARAMETERS - 
--  acloid [in] 
--     aclid of the acl to be validated
----------------------------------------------------------------------------
PROCEDURE ValidateFusionAcl(acloid IN RAW);

----------------------------------------------------------------------------
-- FUNCTION - add_application_principal
--   Registers with XDB an Application user or workgroup/role.
-- PARAMETERS -
--   name - The name of the user or role/workgroup
--   flags - Whether user (if XDB.DBMS_XDBZ.APPLICATION_USER, default)
--           or role (XDB.DBMS_XDBZ.APPLICATION_ROLE)
-- RETURNS -
--   The status of the addition (TRUE if successful, FALSE otherwise)
----------------------------------------------------------------------------
FUNCTION add_application_principal(
         name IN VARCHAR2, 
         flags IN PLS_INTEGER := XDB.DBMS_XDBZ.APPLICATION_USER)
 return BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - change_application_membership
--   Adds or removes an Application user to/from a role/workgroup.
--   If either the user or the role/workgroup have not been 
--     previously registered with XDB, registration is done.
-- PARAMETERS -
--   user_name - The name of the Application user/role
--   group_name - The name of the role/workgroup
--   op_mode - Whether the user/role is to be added (XDB.DBMS_XDBZ.MODE_MEMBERSHIP_ADD),
--             which is the default, or deleted (XDB.DBMS_XDBZ.MODE_MEMBERSHIP_DELETE)
--             to/from the workgroup/role.
--   user_flags - Whether user_name is the name of a user 
--                (XDB.DBMS_XDBZ.APPLICATION_USER, default), or 
--                group (XDB.DBMS_XDBZ.APPLICATION_ROLE). Currently,
--                only XDB.DBMS_XDBZ.APPLICATION_USER supported.
-- RETURNS -
--   The status of the operation (TRUE if successful, FALSE otherwise)
----------------------------------------------------------------------------
FUNCTION change_application_membership(
         user_name IN VARCHAR2, 
         group_name IN VARCHAR2,
         op_mode IN PLS_INTEGER := XDB.DBMS_XDBZ.MODE_MEMBERSHIP_ADD,
         user_flags IN NUMBER := XDB.DBMS_XDBZ.APPLICATION_USER)
  return BOOLEAN;  

----------------------------------------------------------------------------
-- FUNCTION - delete_application_principal
--   Delete all information about an Application user or role/workgroup.
-- PARAMETERS -
--  name - Name of the Application user or role/workgroup
--  op_mode - Whether to raise an error if deleting a role/workgroup with
--            active members (if XDB.DBMS_XDBZ.DELETE_APP_NOFORCE, default),
--            or to delete all group membership information otherwise
--            (if XDB.DBMS_XDBZ.DELETE_APP_FORCE). 
--            Applies only in the case of role/workgroup names.
-- RETURNS -
--   The status of the deletion (TRUE if successful, FALSE otherwise)
--
----------------------------------------------------------------------------
FUNCTION delete_application_principal(
         name IN VARCHAR2,
         op_mode IN PLS_INTEGER := XDB.DBMS_XDBZ.DELETE_APP_NOFORCE)
 return BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - purgeApplicationCache
--  Purges the shared cache of GUIDs to Application user or roles names mappings.
--
-- RETURNS -
--   The status of the operation (TRUE if successful, FALSE otherwise)
----------------------------------------------------------------------------
FUNCTION purgeApplicationCache RETURN BOOLEAN;

-----------------------------------------------------------------------------
-- FUNCTION - set_application_principal
--  If the current user and schema are trusted (determined based on
--  XDB configuration document, allows the passed application user 
--  to be set as the current user in the session, for the purpose of
--  XDB repository access. This API is to be used for local application
--  group membership scheme.
-- PARAMETERS -
--  principal_name - Name of the application user (mandatory if local
--       application store
--  principal_guid - GUID of the application user; mandatory only under 
--       dynamic group membership scheme
--  allow_registration - Used only under local group scheme;
--        if true and the application user is not already
--        known to XDB, then the user is automatically registered with XDB.
--  group_membership - Used only under dynamic group scheme;
--        Concatenated list of GUIDs of all application
--        roles currently enabled for the application user.
-- RETURNS -
--  TRUE if the user was successfully set in the session (FALSE otherwise).
-----------------------------------------------------------------------------
FUNCTION set_application_principal(principal_name IN VARCHAR2 := NULL,
                                   allow_registration IN BOOLEAN := TRUE,
                                   principal_guid IN RAW := NULL,
                                   group_membership IN RAW := NULL)
RETURN BOOLEAN;


FUNCTION reset_application_principal RETURN BOOLEAN;

-- Procedure to insert the randomly generated nonce key into 
-- XDB$NONCEKEY table
--------
procedure CreateNonceKey;

end dbms_xdbz;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xdbz FOR xdb.dbms_xdbz;
GRANT EXECUTE ON xdb.dbms_xdbz TO PUBLIC;
show errors;

