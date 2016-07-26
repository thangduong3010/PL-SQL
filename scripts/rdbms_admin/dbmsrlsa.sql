Rem Copyright (c) 1998, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrlsa.sql - Row Level Security Adminstrative interface
Rem
Rem    DESCRIPTION
Rem      dbms_rls package for row level security adminstrative interface
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ajadams     11/10/08 - add _with_commit to supplemental_log_data pragma
Rem    clei        10/22/07 - new DBMS_XDS API for XDS enhancements
Rem    pknaggs     08/31/07 - DSD schema: aclids to aclFiles or aclDirectory.
Rem    preilly     03/26/07 - Pragma dbms_xds to not replicate in Logical
Rem                           Standby
Rem    clei        01/08/07 - remove DV_INTERNAL
Rem    fjlee       04/27/06 - XbranchMerge ayalaman_dv_overlay_5112125_0418 
Rem                           from st_rdbms_10.2 
Rem    clei        03/15/06 - remove grant to XDB
Rem    clei        02/11/06 - add dbms_xdsutl
Rem    clei        12/19/05 - add dbms_xds
Rem    cchui       04/02/06 - XbranchMerge cchui_skip_function_call from 
Rem                           st_rdbms_10.2dv 
Rem    cchui       03/28/06 - add new type for Data Vault 
Rem    clei        10/13/03 - ALL_COLUMNS -> ALL_ROWS
Rem    clei        08/13/03 - add security relevant column option
Rem    clei        05/28/02 - policy types, sec relevant cols, and predicate sz
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    clei        04/12/01 - support static policy 
Rem    dmwong      08/16/00 - rename UI to grouped_policies.
Rem    dmwong      02/09/00 - add groups for refresh and enable
Rem    dmwong      01/25/00 - add group extension
Rem    clei        03/16/98 -
Rem    clei        02/24/98 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_rls AS

  STATIC                     CONSTANT   BINARY_INTEGER := 1;
  SHARED_STATIC              CONSTANT   BINARY_INTEGER := 2;
  CONTEXT_SENSITIVE          CONSTANT   BINARY_INTEGER := 3;
  SHARED_CONTEXT_SENSITIVE   CONSTANT   BINARY_INTEGER := 4;
  DYNAMIC                    CONSTANT   BINARY_INTEGER := 5;
  XDS1                       CONSTANT   BINARY_INTEGER := 6;
  XDS2                       CONSTANT   BINARY_INTEGER := 7;
  XDS3                       CONSTANT   BINARY_INTEGER := 8;


  -- security relevant columns options, default is null
  ALL_ROWS                   CONSTANT   BINARY_INTEGER := 1;

  -- Support log based replication of RLS (proj 17779)
  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO_WITH_COMMIT);

  -- ------------------------------------------------------------------------
  -- add_policy -  add a row level security policy to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant column option

  PROCEDURE add_policy(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       policy_name     IN VARCHAR2,
                       function_schema IN VARCHAR2 := NULL,
                       policy_function IN VARCHAR2,
                       statement_types IN VARCHAR2 := NULL,
                       update_check    IN BOOLEAN  := FALSE,
                       enable          IN BOOLEAN  := TRUE,
                       static_policy   IN BOOLEAN  := FALSE,
                       policy_type     IN BINARY_INTEGER := NULL,
                       long_predicate BOOLEAN  := FALSE,
                       sec_relevant_cols IN VARCHAR2  := NULL,
                       sec_relevant_cols_opt IN BINARY_INTEGER := NULL);
 
  -- drop_policy - drop a row level security policy from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be dropped
 
  PROCEDURE drop_policy(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2,
                        policy_name   IN VARCHAR2); 

  -- refresh_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be refreshed
 
  PROCEDURE refresh_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL); 

  -- enable_policy - enable or disable a security policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy
 
  PROCEDURE enable_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE );

  -- create_policy_group - create a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be created

  PROCEDURE create_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- ------------------------------------------------------------------------
  -- add_grouped_policy -  add a row level security policy to a policy group
  --                        for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy group to be added
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant columns option

  PROCEDURE add_grouped_policy(object_schema   IN VARCHAR2 := NULL,
                                object_name     IN VARCHAR2,
                                policy_group    IN VARCHAR2 := 'SYS_DEFAULT',
                                policy_name     IN VARCHAR2,
                                function_schema IN VARCHAR2 := NULL,
                                policy_function IN VARCHAR2,
                                statement_types IN VARCHAR2 := NULL,
                                update_check    IN BOOLEAN  := FALSE,
                                enable          IN BOOLEAN  := TRUE,
                                static_policy   IN BOOLEAN  := FALSE,
                                policy_type     IN BINARY_INTEGER := NULL,
                                long_predicate BOOLEAN  := FALSE,
                                sec_relevant_cols IN VARCHAR2  := NULL,
                              sec_relevant_cols_opt IN BINARY_INTEGER := NULL);


  -- ------------------------------------------------------------------------
  -- add_policy_context -  add a driving context to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE add_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- delete_policy_group - drop a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be dropped

  PROCEDURE delete_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- drop_grouped_policy - drop a row level security policy from a policy
  --                          group of a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of policy to be dropped
  --   policy_name     - name of policy to be dropped

  PROCEDURE drop_grouped_policy(object_schema IN VARCHAR2 := NULL,
                                   object_name   IN VARCHAR2,
                                   policy_group  IN VARCHAR2 := 'SYS_DEFAULT',
                                   policy_name   IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- drop_policy_context -  drop a driving context from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE drop_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- refresh_grouped_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of group of the policy to be refreshed
  --   policy_name     - name of policy to be refreshed

  PROCEDURE refresh_grouped_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           group_name    IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL);

  -- enable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE enable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE);

  -- disable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE disable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2);

END dbms_rls;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_rls FOR sys.dbms_rls
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_rls TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_xds AS

  ENABLE_DYNAMIC_IS          CONSTANT   BINARY_INTEGER := 1;
  ENABLE_ACLOID_COLUNM       CONSTANT   BINARY_INTEGER := 2;
  ENABLE_STATIC_IS           CONSTANT   BINARY_INTEGER := 3;

  -- Disable log based replication for this package
  PRAGMA SUPPLEMENTAL_LOG_DATA(default, UNSUPPORTED_WITH_COMMIT);

  -- enable_xds -  Enables XDS for a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object
  --   enable_option   - enable option 
  --                     ENABLE_DYNAMIC_IS: enable XDS with dynamic instance
  --                       set support only.
  --                     ENABLE_ACLOID_COLUNM: enable XDS with dynamic instance
  --                       set support and SYS_ACLOID column avaliable
  --                       for static ACLID storage.
  --                     ENABLE_STATIC_IS: enable XDS with dynamic and static
  --                       instance set support.
  --                     NULL (default): re-enable with the current option or
  --                       ENABLE_DYNAMIC_IS if it is enabled the first time.
  --  dsd_path        - DSD path, default is null (no change on designated
  --                    or the link to the designated location)
  
  PROCEDURE enable_xds(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       enable_option   IN BINARY_INTEGER := NULL,
                       dsd_path        IN VARCHAR2 := NULL);

  ----------------------------------------------------------------------------
  -- disable_xds - disable XDS for a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object

  PROCEDURE disable_xds(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- drop_xds - drop XDS policy from a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object

  PROCEDURE drop_xds(object_schema IN VARCHAR2 := NULL,
                     object_name   IN VARCHAR2);
  ----------------------------------------------------------------------------

  -- refresh_dsd - refresh XDS document cache for a table/view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object

  PROCEDURE REFRESH_DSD(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2);
  ----------------------------------------------------------------------------

  -- refresh_dsd - refresh XDS document cache identified by its DSD path
  --
  -- INPUT PARAMETERS
  --   dsd_path        - DSD resource path

  PROCEDURE REFRESH_DSD(dsd_path      IN VARCHAR2);

END dbms_xds;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xds FOR sys.dbms_xds
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_xds TO execute_catalog_role
/


  ----------------------------------------------------------------------------
  -- This is an internal API to invalidate entries in the DataSecurity 
  -- document kgl cache.
  -- We need this before c api is available for XML event handling.
  -- Don't publish this package because we will remove it soon!

CREATE OR REPLACE PACKAGE dbms_xdsutl AS

  -- invalidate_dsd_cache
  --
  -- Given the object_id of a DataSecurity document, invalidate 
  -- the DSD kgl cache entry associated with this object_id.
  --
  -- INPUT PARAMETERS
  --   object_id - XMLRef of DataSecurity doc to invalidate

  PROCEDURE invalidate_dsd_cache(object_id IN VARCHAR2);

  -- invalidate_dsd_cache_by_aclid
  --
  -- Given hex string containing the ACLID of an ACL, invalidate all 
  -- of the DSD kgl cache entries associated with this ACL.
  --
  -- INPUT PARAMETERS
  --   aclid - Hex string of ACLID

  PROCEDURE invalidate_dsd_cache_by_aclid(aclid IN VARCHAR2);

END dbms_xdsutl;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_xdsutl FOR sys.dbms_xdsutl
/
