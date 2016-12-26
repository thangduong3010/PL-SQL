Rem
Rem $Header: dbmsepg.sql 05-jan-2006.17:56:32 rpang Exp $
Rem
Rem dbmsepg.sql
Rem
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsepg.sql - DBMS Embedded PL/SQL Gateway package
Rem
Rem    DESCRIPTION
Rem      This package provides the PL/SQL interface to administer the
Rem      embedded PL/SQL gateway.
Rem
Rem    NOTES
Rem      This package must be created under SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       01/05/06 - Add constants for log-levels
Rem    rpang       09/22/05 - Add anonymous authentication
Rem    rpang       04/21/05 - Add new DAD attributes
Rem    rpang       03/11/05 - Add invalid_dad_name exception 
Rem    rpang       10/08/04 - Move table creation to catepg.sql
Rem    rpang       08/31/04 - Add authorization API
Rem    rpang       06/22/04 - Created for XML DB integration
Rem

CREATE OR REPLACE PACKAGE dbms_epg AUTHID CURRENT_USER IS

  --
  -- The PL/SQL gateway enables a Web browser to invoke a PL/SQL stored
  -- procedure through an HTTP listener. It is a platform on which PL/SQL
  -- users develop and deploy PL/SQL Web applications. The embedded PL/SQL
  -- gateway is an embedded version of the PL/SQL gateway that runs in the
  -- XML DB HTTP Server in the Oracle database. It provides the core
  -- features of mod_plsql in the database but does not require the
  -- Oracle HTTP Server powered by Apache.
  --

  ----------------
  ---- Types -----
  ----------------
  type VARCHAR2_TABLE is table of varchar2(4000) INDEX BY BINARY_INTEGER;

  ----------------
  -- Exceptions --
  ----------------
  invalid_dad_name  EXCEPTION;
  dad_not_found     EXCEPTION;
  unknown_attribute EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_dad_name,       -24240);
  PRAGMA EXCEPTION_INIT(dad_not_found,          -24231);
  PRAGMA EXCEPTION_INIT(unknown_attribute,      -24232);
  invalid_dad_name_num  constant PLS_INTEGER := -24240;
  dad_not_found_num     constant PLS_INTEGER := -24231;
  unknown_attribute_num constant PLS_INTEGER := -24232;

  ---------------
  -- Constants --
  ---------------
  -- Log levels for the global attribute "log-level"
  LOG_EMERG   CONSTANT PLS_INTEGER := 0;
  LOG_ALERT   CONSTANT PLS_INTEGER := 1;
  LOG_CRIT    CONSTANT PLS_INTEGER := 2;
  LOG_ERR     CONSTANT PLS_INTEGER := 3;
  LOG_WARNING CONSTANT PLS_INTEGER := 4;
  LOG_NOTICE  CONSTANT PLS_INTEGER := 5;
  LOG_INFO    CONSTANT PLS_INTEGER := 6;
  LOG_DEBUG   CONSTANT PLS_INTEGER := 7;

  ----------------------------- Configuration API ----------------------------
  -- The XDBADMIN role is required to modify the embedded gateway
  -- configuration through the configuration API. Modification of the
  -- configuration by a user without the role will result in an "access denied"
  -- exception.

  --------------------------------------------
  ------ Global Attribute Configuration ------
  --------------------------------------------

  --
  -- Sets a global attribute.
  --
  -- If the attribute has been set before, the old value will be overwritten
  -- with the new value. The attribute name is case sensitive. The value
  -- may or may not be case-sensitive depending on the attribute.
  --
  -- PARAMETERS
  --   attr_name   The global attribute to set
  --   attr_value  The attribute value to set
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the attribute is unknown
  --   - if the invoker does not have the XDBADMIN role
  -- EXAMPLES
  --   dbms_epg.set_global_attribute('max-parameters', '100');
  --
  procedure set_global_attribute(attr_name  IN varchar2,
                                 attr_value IN varchar2);

  --
  -- Gets the value of a global attribute.
  --
  -- PARAMETERS
  --   attr_name   The global attribute to retrieve
  -- RETURN
  --   The global attribute value. Returns NULL if the attribute is unknown or
  --   has not been set.
  -- EXCEPTIONS
  --   None
  --
  function get_global_attribute(attr_name IN varchar2) return varchar2;

  --
  -- Deletes a global attribute.
  --
  -- PARAMETERS
  --   attr_name   The global attribute to delete
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   None
  --
  procedure delete_global_attribute(attr_name IN varchar2);

  --
  -- Gets all global attributes/values.
  --
  -- The outputs are 2 correlated index-by tables of the name/value pairs.
  --
  -- PARAMETERS
  --   attr_names  The global attribute names
  --   attr_values The values of the global attributes
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   If no global attribute has been set, "attr_names" and "attr_values"
  --   will be set to empty arrays.
  --
  procedure get_all_global_attributes(attr_names  OUT NOCOPY VARCHAR2_TABLE,
                                      attr_values OUT NOCOPY VARCHAR2_TABLE);

  ----------------------------------------------------------
  ----- Database Access Descriptor (DAD) Configuration -----
  ----------------------------------------------------------

  --
  -- In order to make a PL/SQL application accessible from the browser via
  -- HTTP, a Database Access Descriptor (DAD) must be created and mapped to
  -- a virtual path. A DAD is a set of configuration values used for database
  -- access and the virtual-path mapping makes the application accessible
  -- under a virtual path of the XML DB HTTP Server. A DAD is represented
  -- as a servlet in XML DB HTTP Server.
  --

  --
  -- Creates a new DAD. None of its attributes will be set. If a virtual path
  -- is given, the DAD will be mapped to the virtual path. Otherwise, the DAD
  -- will not be mapped. If the virtual path exists already, the virtual path
  -- will be mapped to the new DAD.
  --
  -- DAD name is case-sensitive. If a DAD with this name already exists,
  -- the old DAD's information will be deleted.
  --
  -- The embedded gateway handles database authentication differently from
  -- mod_plsql. In particular, it does not store any database password in a
  -- DAD. The following explains the database authentication schemes.
  --
  -- 1. Static Authentication
  --
  -- For mod_plsql users who store database usernames/passwords in the DADs
  -- so that the browser user will not be required to enter the database
  -- authentication information, they can utilize the embedded gateway's static
  -- authentication scheme. To use this scheme, the administrator with the
  -- XDBADMIN role creates the DAD with the DAD attribute "database-username"
  -- set, for example,
  --
  --   > sqlplus xdb/...
  --   SQL> begin
  --     dbms_epg.create_dad('HR', '/hrweb/*');
  --     dbms_epg.set_dad_attribute('HR', 'database-username', 'SCOTT');
  --    end;/
  --
  -- and the database user authorizes the embedded gateway to use his
  -- privileges to invoke procedures and access document tables through the
  -- DAD, for example,
  --
  --   > sqlplus scott/...
  --   SQL> begin
  --     dbms_epg.authorize_dad('HR');
  --   end;
  --   /
  --
  -- In order to use this scheme, both the DAD attribute "database-username"
  -- must be set and the DAD must be authorized to use the user's privileges.
  -- The DAD attribute "database-username" is case-sensitive. See the
  -- description of the "set_dad_attribute" procedure for details.
  --
  -- Note that in this scheme, the embedded gateway, unlike mod_plsql, logs on
  -- to the database as the special user "ANONYMOUS" but accesses database
  -- objects using the user's privileges and default roles. Access will be
  -- rejected if the browser user attempts to log on explicitly with the HTTP
  -- "Authorization" header.
  --
  -- 2. Dynamic Authentication
  --
  -- For mod_plsql users who do not store database usernames/passwords in
  -- the DADs, they can utilize the embedded gateway's dynamic authentication
  -- scheme. To use this scheme, the administrator with the XDBADMIN role
  -- simply creates the DAD. For example,
  --
  --   > sqlplus xdb/...
  --   SQL> begin
  --     dbms_epg.create_dad('HR', '/hrweb/*');
  --   end;
  --   /
  --
  -- To access the procedures or document tables through the DAD, browser users
  -- will be required to supply the database authentication information via the
  -- HTTP Basic Authentication scheme to log on to the database. If the DAD
  -- attribute "database-username" is set, logon will be restricted to the
  -- specified user. Caution: since the passwords sent through the HTTP Basic
  -- Authentication scheme are not encrypted, the administrator should set up
  -- the embedded gateway to use the HTTPS protocol to protect the passwords
  -- sent by the browser users.
  --
  -- Note that in this scheme, the embedded gateway logs on to the database as
  -- the user supplied by the browser user. The database user does not have to
  -- authorize the embedded gateway to use his privileges to access database
  -- objects since the browser user provides the database authentication
  -- information to log on explicitly.
  --
  -- 3. Anonymous Authentication
  --
  -- For mod_plsql users who create a special DAD database user for database
  -- logon purpose but store the application procedures and document tables
  -- in a different schema and grant access to the procedures and document
  -- tables to PUBLIC, they can utilize the embedded gateway's anonymous
  -- authentication scheme. To use this scheme, the administrator with the
  -- XDBADMIN role simply creates the DAD with the DAD attribute
  -- "database-username" set to "ANONYMOUS" (case-sensitive). For example,
  --
  --   > sqlplus xdb/...
  --   SQL> begin
  --     dbms_epg.create_dad('HR', '/hrweb/*');
  --     dbms_epg.set_dad_attribute('HR', 'database-username', 'ANONYMOUS');
  --   end;
  --   /
  --
  -- In order to use this scheme, the DAD attribute "database-username" must be
  -- set to "ANONYMOUS" (case-sensitive). There is no need to authorize the
  -- embedded gateway to use ANONYMOUS' privileges to access database objects
  -- since ANONYMOUS has no system privileges and owns no database objects.
  --
  -- PARAMETERS
  --   dad_name    The name of the DAD to create
  --   path        The virtual path to map the DAD to
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the invoker does not have the XDBADMIN role
  --
  procedure create_dad(dad_name IN varchar2, path IN varchar2 DEFAULT NULL);

  --
  -- Drops a DAD. All virtual-path mappings of the DAD will be dropped also
  -- but the authorizations of the DAD will not be dropped.
  --
  -- PARAMETERS
  --   dad_name    The DAD to drop
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --   - if the invoker does not have the XDBADMIN role
  --
  procedure drop_dad(dad_name IN varchar2);

  --
  -- Sets an attribute for a DAD.
  --
  -- If the attribute has been set before, the old value will be overwritten
  -- with the new value for single-occurrence attributes. For multi-occurrence
  -- attributes, the value will be appended instead.
  --
  -- The DAD attribute name is case-sensitive. The attribute value may or may
  -- not be case-sensitive depending on the attribute.
  --
  -- DAD attributes are named differently from the DAD attributes of mod_plsql.
  -- The name mapping is as follows:
  --
  --   mod_plsql attributes            embedded PL/SQL gateway attributes
  --   -----------------------------   ----------------------------------
  --   PlsqlDatabaseUsername           database-username
  --   PlsqlAuthenticationMode         authentication-mode
  --   PlsqlSessionCookieName          session-cookie-name
  --   PlsqlSessionStateManagement     session-state-management
  --   PlsqlMaxRequestsPerSession      max-requests-per-session
  --   PlsqlDefaultPage                default-page
  --   PlsqlDocumentTablename          document-table-name
  --   PlsqlDocumentPath               document-path
  --   PlsqlDocumentProcedure          document-procedure
  --   PlsqlUploadAsLongRaw            upload-as-long-raw
  --   PlsqlPathAlias                  path-alias
  --   PlsqlPathAliasProcedure         path-alias-procedure
  --   PlsqlExclusionList              exclusion-list
  --   PlsqlCGIEnvironmentList         cgi-environment-list
  --   PlsqlCompatibilityMode          compatibility-mode
  --   PlsqlNLSLanguage                nls-language
  --   PlsqlFetchBufferSize            fetch-buffer-size
  --   PlsqlErrorStyle                 error-style
  --   PlsqlTransferMode               transfer-mode
  --   PlsqlBeforeProcedure            before-procedure
  --   PlsqlAfterProcedure             after-procedure
  --   PlsqlBindBucketLengths          bind-bucket-lengths
  --   PlsqlBindBucketWidths           bind-bucket-widths
  --   PlsqlAlwaysDescribeProcedure    always-describe-procedure
  --   PlsqlInfoLogging                info-logging
  --   PlsqlOWADebugEnable             owa-debug-enable
  --   PlsqlRequestValidationFunction  request-validation-function
  --   PlsqlInputFilterEnable          input-filter-enable
  --
  -- Note that the embedded gateway DAD attribute "database-username", unlike
  -- its matching mod_plsql DAD attribute "PlsqlDatabaseUsername", is
  -- case-sensitive as in the USERNAME column of the ALL_USERS view. The DAD
  -- attribute "PlsqlDatabasePassword" is not needed. See the explanation of
  -- the database authentication schemes in the "create_dad" procedure. Also,
  -- the DAD attribute "PlsqlDatabaseConnectString" is not needed since the
  -- embedded gateway does not support logon to external databases.
  --
  -- PARAMETERS
  --   dad_name    The DAD to set attribute
  --   attr_name   The DAD attribute to set
  --   attr_value  The attribute value to set
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --   - if the attribute is unknown
  --   - if the invoker does not have the XDBADMIN role
  -- EXAMPLES
  --   dbms_epg.set_dad_attribute('HR', 'default-page', 'HRApp.home');
  --
  procedure set_dad_attribute(dad_name   IN varchar2,
                              attr_name  IN varchar2,
                              attr_value IN varchar2);

  --
  -- Gets the value of a DAD attribute.
  --
  -- PARAMETERS
  --   dad_name    The DAD to get attribute
  --   attr_name   The DAD attribute to get
  -- RETURN
  --   The DAD attribute value. Returns NULL if the attribute is unknown or
  --   has not been set.
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --
  function get_dad_attribute(dad_name   IN varchar2,
                             attr_name  IN varchar2) return varchar2;

  --
  -- Gets all attributes of a DAD.
  --
  -- The outputs are 2 correlated index-by tables of the name/value pairs.
  --
  -- PARAMETERS
  --   dad_name    The DAD to get attributes
  --   attr_names  The DAD attribute names
  --   attr_values The values of the DAD attributes
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  -- NOTE
  --   If the DAD has no attributes set, "attr_names" and "attr_values"
  --   will be set to empty arrays.
  --
  procedure get_all_dad_attributes(dad_name    IN  varchar2,
                                   attr_names  OUT NOCOPY VARCHAR2_TABLE,
                                   attr_values OUT NOCOPY VARCHAR2_TABLE);

  --
  -- Deletes a DAD attribute.
  --
  -- PARAMETERS
  --   dad_name    The DAD to delete attribute
  --   attr_name   The DAD attribute to delete
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --
  procedure delete_dad_attribute(dad_name   IN varchar2,
                                 attr_name  IN varchar2);

  --
  -- Maps a DAD to a virtual path. If the virtual path exists already, the
  -- virtual path will be mapped to the new DAD.
  --
  -- PARAMETERS
  --   dad_name    The DAD to map
  --   path        The virtual path to map
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --
  procedure map_dad(dad_name IN varchar2, path IN varchar2);

  --
  -- Unmaps a DAD from a virtual path. If the virtual path is NULL, unmap the
  -- DAD from all virtual paths.
  --
  -- PARAMETERS
  --   dad_name    The DAD to unmap
  --   path        The virtual path to unmap
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  --
  procedure unmap_dad(dad_name IN varchar2, path IN varchar2 DEFAULT NULL);

  --
  -- Gets all virtual paths a DAD is mapped to.
  --
  -- PARAMETERS
  --   dad_name    The DAD to retrieve virtual-path mappings
  --   paths       The virtual paths mapped to the DAD
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the DAD does not exist
  -- NOTE
  --   If the DAD is not mapped to any virtual path, "paths" will be set
  --   to an empty array.
  --
  procedure get_all_dad_mappings(dad_name IN  varchar2,
                                 paths    OUT NOCOPY VARCHAR2_TABLE);

  --
  -- Gets the list of all DADs.
  --
  -- PARAMETERS
  --   dad_names   The list of all DADs
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTE
  --   If no DADs exist, "dad_names" will be set to an empty array.
  --
  procedure get_dad_list(dad_names OUT NOCOPY VARCHAR2_TABLE);

  ---------------------------- Authorization API -----------------------------
  -- Any user can authorize the use of his privileges to the embedded gateway
  -- through the authorization API in his schema. The XDBADMIN role is not
  -- required to perform such authorization.

  --
  -- Authorizes a DAD to use a user's privileges to invoke procedures and
  -- access document tables. The invoker can always authorize the use of
  -- his own privileges. To authorize the use of another user's privileges,
  -- the invoker must have the the ALTER USER system privilege.
  --
  -- The DAD authorization may be performed before the DAD is created. The
  -- DAD attribute "database-username" does not have to be set to user to
  -- authorize. Multiple users can authorize the same DAD and it is up to
  -- DAD's "database-username" attribute setting to decide which user's
  -- privileges to use. To view the DAD authorizations, see the database
  -- dictionary views USER_EPG_DAD_AUTHORIZATION and DBA_EPG_DAD_AUTHORIZATION.
  --
  -- PARAMETERS
  --   dad_name  The DAD to authorize use
  --   user      The user whose privileges to authorize. If the user is NULL,
  --             the invoker is assumed. The username is case-sensitive as in
  --             the USERNAME column of the ALL_USERS view.

  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the user does not exist
  --   - if the invoker authorizes for another user but he does not have the
  --     ALTER USER system privilege
  -- EXAMPLE
  --   dbms_epg.authorize_dad('HR');
  --
  procedure authorize_dad(dad_name IN varchar2,
                          user     IN varchar2 DEFAULT NULL);

  --
  -- Deauthorizes a DAD's use of a user's privileges to invoke procedures and
  -- access document tables. The invoker can always deauthorize the use of
  -- his own privileges. To deauthorize the use of another user's privileges,
  -- the invoker must have the the ALTER USER system privilege.
  --
  -- PARAMETERS
  --   dad_name  The DAD to deauthorize use
  --   user      The user whose privileges to deauthorize. If the user is NULL,
  --             the invoker is assumed. The username is case-sensitive as in
  --             the USERNAME column of the ALL_USERS view.
  -- RETURN
  --   None
  -- EXCEPTIONS
  --   - if the user does not exist
  --   - if the invoker deauthorizes for another user but he does not have the
  --     ALTER USER system privilege
  -- EXAMPLE
  --   dbms_epg.deauthorize_dad('HR');
  --
  procedure deauthorize_dad(dad_name IN varchar2,
                            user     IN varchar2 DEFAULT NULL);

END dbms_epg;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_epg FOR sys.dbms_epg
/
GRANT EXECUTE ON dbms_epg TO PUBLIC
/
