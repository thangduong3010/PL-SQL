Rem
Rem $Header: rdbms/admin/dbmsldap.sql /main/17 2010/02/12 11:17:53 vmedam Exp $
Rem
Rem dbmsldap.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsldap.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       vmedam   02/01/10 - bug#9066715
Rem       rbollu   08/06/04 - fix bug#3264021 
Rem       rbollu   11/18/03 - 
Rem       bnanjund 10/30/03 - COLLECTION TYPE limit to 32k
Rem       rbollu   10/07/02 - fwdmrge bug#2382299
Rem       rbollu   04/15/02 - fix bug-2322803
Rem       rbollu   12/07/01 - 2127189
Rem       rbollu   11/12/01 - Add get_subscriber_ext_properties
Rem       rbollu   10/02/01 - Add VERSION to Packages
Rem       rbollu   09/25/01 - Add get_user_extended_properties
Rem       rbollu   08/22/01 - Add new package DBMS_LDAP_UTL
Rem       rbollu   04/24/01 - Add berfree,msgfree functions
Rem       akolli   08/07/00 - remove unnecessary traces
Rem       dlin     06/07/00 - modified entry associated parameters
Rem       dlin     05/24/00 - add mts_not_supported execption
Rem       dlin     05/17/00 - changed init_fail to init_failed
Rem       dlin     05/09/00 - comment out explode_rdn
Rem       dlin     05/02/00 - add exception_init
Rem       dlin     04/20/00 - add rename_s, explode_dn, explode_rdn
Rem       dlin     03/21/00 - modify modification functions
Rem       dlin     03/15/00 - add ldap_err2string
Rem       dlin     03/13/00 - add exception handling implementation
Rem       dlin     03/09/00 - changed ldap function names
Rem       dlin     03/02/00 - add modify logic
Rem       akolli   02/28/00 - extend ldap_search to all attributes
Rem       akolli   02/24/00 - add value functions
Rem       akolli   02/23/00 - remove trusted lib definition
Rem       dlin     02/22/00 - added data type definitions
Rem                         - modified API spec  
Rem       akolli   01/07/00 - PL/SQL interface to LDAP servers
Rem
REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS
REM  ***************************************



----------------------------------------------------------------------------
--- Package specification for DBMS_LDAP
---     This is the primary interface used by various clients to
---     make LDAP requests
----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE DBMS_LDAP AUTHID CURRENT_USER AS

    VERSION                         CONSTANT VARCHAR2(256) := '2';
    INTERFACE_VERSION               CONSTANT VARCHAR2(256) := '2';

    --
    -- DBMS_LDAP data type definitions
    --

    -- We use RAW(32) as a data structure to store external pointers
    -- It is big enough to store 256 bit pointers!

    -- this data structure holds a pointer to an LDAP session
    SUBTYPE SESSION IS RAW(32);            

    -- this data structure holds a pointer to an LDAP message
    SUBTYPE MESSAGE IS RAW(32);

    -- this data structure holds a pointer to an LDAP mod array
    SUBTYPE MOD_ARRAY IS RAW(32);    

    -- this data structure is used to hold binary value
    SUBTYPE BERVAL IS raw(32000);

    -- this data structure is used to pass time limit information to
    -- the LDAP api.
    TYPE TIMEVAL IS RECORD
      ( seconds  PLS_INTEGER,
        useconds PLS_INTEGER
        );

    -- this data structure is used to pass LDAP control to the api.
    TYPE ldapcontrol IS RECORD
      (ldctl_oid        VARCHAR2(256),
       ldctl_value      BERVAL,
       ldctl_iscritical VARCHAR2(1));
    
    -- this data structure holds a pointer to the BER Element used
    -- for decoding the incoming message
    SUBTYPE BER_ELEMENT is RAW(32);
    
    -- this data structure is used to hold a list of values
    TYPE STRING_COLLECTION is TABLE of VARCHAR2(32767)
      INDEX BY BINARY_INTEGER;        

    -- this data structure is used to hold a list of binary values
    TYPE BINVAL_COLLECTION is TABLE of RAW(32767) 
      INDEX BY BINARY_INTEGER;

    -- this data structure is used to hold a list of berval values
    TYPE BERVAL_COLLECTION is TABLE of RAW(32767) 
      INDEX BY BINARY_INTEGER;

    -- this data structure is used to hold a list of berval values
    TYPE BLOB_COLLECTION is TABLE of BLOB
      INDEX BY BINARY_INTEGER;



    
    --
    -- DBMS_LDAP function definitions
    --

    -- Checks the Support for Interface Version. 
    FUNCTION check_interface_version(interface_version IN VARCHAR2)
    RETURN PLS_INTEGER;
    
    -- Initializes the LDAP library and return a session handler
    -- for use in subsequent calls.
    FUNCTION init (hostname IN VARCHAR2, 
                   portnum  IN PLS_INTEGER )
      RETURN SESSION;
    
    
    -- Synchronously authenticates to the directory server using
    -- a Distinguished Name and password.
    FUNCTION simple_bind_s (ld     IN SESSION,
                            dn     IN VARCHAR2,
                            passwd IN VARCHAR2)
      RETURN PLS_INTEGER;

    
    -- Synchronously authenticates to the directory server using
    -- a Distinguished Name and some arbitrary credentials.
    FUNCTION bind_s (ld   IN SESSION,
                     dn   IN VARCHAR2,
                     cred IN VARCHAR2,
                     meth IN PLS_INTEGER )
      RETURN PLS_INTEGER;

    
    -- Synchronously disposes of an LDAP session, freeing all
    -- associated resources.
    FUNCTION unbind_s (ld IN OUT SESSION )
      RETURN PLS_INTEGER;

    
    -- Compares a value with a attribute value contained in an
    -- entry.
    FUNCTION compare_s (ld    IN SESSION,
                        dn    IN VARCHAR2,
                        attr  IN VARCHAR2,
                        value IN VARCHAR2)
      RETURN PLS_INTEGER;

    
    -- Searches for directory entries.
    FUNCTION search_s  (ld       IN  SESSION,
                        base     IN  VARCHAR2,
                        scope    IN  PLS_INTEGER,
                        filter   IN  VARCHAR2,
                        attrs    IN  STRING_COLLECTION,
                        attronly IN  PLS_INTEGER,
                        res      OUT MESSAGE)
      RETURN PLS_INTEGER;

    
    -- Searches for directory entries, respecting a local timeout.
    FUNCTION search_st  (ld       IN  SESSION,
                         base     IN  VARCHAR2,
                         scope    IN  PLS_INTEGER,
                         filter   IN  VARCHAR2,
                         attrs    IN  STRING_COLLECTION,
                         attronly IN  PLS_INTEGER,
                         tv       IN  TIMEVAL,
                         res      OUT MESSAGE)
      RETURN PLS_INTEGER;
    
    
    -- Returns the first entry in a chain of results.
    FUNCTION first_entry (ld  IN SESSION,
                          msg IN MESSAGE )
      RETURN MESSAGE;

    
    -- Returns the next entry in a chain of search results.
    FUNCTION next_entry (ld  IN SESSION,
                         msg IN MESSAGE )
      RETURN MESSAGE;

    
    -- Determines the number of entries in an LDAP result
    -- message chain.
    FUNCTION count_entries (ld  IN SESSION,
                            msg IN MESSAGE )
      RETURN PLS_INTEGER;

    
    -- Returns the first attribute in an entry.
    FUNCTION first_attribute (ld        IN  SESSION,
                              ldapentry IN  MESSAGE,
                              ber_elem  OUT BER_ELEMENT)
      RETURN VARCHAR2;

    
    -- Returns the next attribute contained in an entry.
    FUNCTION next_attribute (ld        IN SESSION,
                             ldapentry IN MESSAGE,
                             ber_elem  IN BER_ELEMENT)
      RETURN VARCHAR2;

    
    -- Retrieves the Distinguished Name of an entry.
    FUNCTION get_dn(ld        IN SESSION,
                    ldapentry IN MESSAGE)
      RETURN VARCHAR2;

    --  Retrieves values associated with a char  attribute for a given entry
    FUNCTION get_values(ld         IN SESSION,
                        ldapentry  IN MESSAGE,
                        attr       IN VARCHAR2)
      RETURN STRING_COLLECTION;
                             
    --  Retrieves binary values associated with an attribute for a given entry
    FUNCTION get_values_len(ld         IN SESSION,
                            ldapentry  IN MESSAGE,
                            attr       IN VARCHAR2)
      RETURN BINVAL_COLLECTION;

    --  Retrieves large binary values(greater than 32kb) 
    --  associated with an attribute for a given entry
    FUNCTION get_values_blob(ld         IN SESSION,
                            ldapentry  IN MESSAGE,
                            attr       IN VARCHAR2)
      RETURN BLOB_COLLECTION;

    -- Deletes an entry from the LDAP directory. The caller is
    -- blocked until the deletion is complete.
    FUNCTION delete_s(ld      IN SESSION,
                      entrydn IN VARCHAR2)
      RETURN PLS_INTEGER;
    
    -- Deletes an entry from the LDAP directory.
    FUNCTION delete(ld      IN SESSION,
                    entrydn IN VARCHAR2)
      RETURN PLS_INTEGER;
    
    -- Renames the given entry to have the new relative
    -- distinguished name. The caller is blocked until the
    -- renaming is complete.
    FUNCTION modrdn2_s(ld           IN SESSION,
                       entrydn      IN VARCHAR2,
                       newrdn       IN VARCHAR2,
                       deleteoldrdn IN PLS_INTEGER)
      RETURN PLS_INTEGER;


    -- Gets the string representation of an LDAP return code
    FUNCTION err2string( ldap_err   IN PLS_INTEGER )
      RETURN VARCHAR2;


    -- Gets the pointer of the ldapmod representation
    -- which contains size, count, and a pointer to an array
    -- of ldapmod structure.
    -- ldapmod structure contains mod_op, mod_type, and an
    -- array of string/berval.
    -- If the return value is NULL, then there is an error.
    FUNCTION create_mod_array(num IN PLS_INTEGER)
      RETURN MOD_ARRAY;

    
    -- Populates the ldapmod structure, string value.
    -- If the return modptr is NULL, then there is an error.
    PROCEDURE populate_mod_array(modptr   IN MOD_ARRAY,
                                 mod_op   IN PLS_INTEGER,
                                 mod_type IN VARCHAR2,
                                 modval   IN STRING_COLLECTION);
    

    -- Populates the ldapmod structure, binary value.
    -- If the return modptr is NULL, then there is an error.
    PROCEDURE populate_mod_array(modptr   IN MOD_ARRAY,
                                 mod_op   IN PLS_INTEGER,
                                 mod_type IN VARCHAR2,
                                 modbval  IN BERVAL_COLLECTION);

    -- Populates the ldapmod structure, large binary value (greater than 32kb).
    -- If the return modptr is NULL, then there is an error.
    PROCEDURE populate_mod_array(modptr   IN MOD_ARRAY,
                                 mod_op   IN PLS_INTEGER,
                                 mod_type IN VARCHAR2,
                                 modbval  IN BLOB_COLLECTION);


    -- Modifies an existing LDAP directory entry. The caller is
    -- blocked until the modification is complete.
    FUNCTION modify_s(ld      IN SESSION,
                      entrydn IN VARCHAR2,
                      modptr  IN MOD_ARRAY)
      RETURN PLS_INTEGER;

    -- Adds a new entry to the LDAP directory. The caller is
    -- blocked until the addition is complete.
    FUNCTION add_s(ld      IN SESSION,
                   entrydn IN VARCHAR2,
                   modptr  IN MOD_ARRAY)
      RETURN PLS_INTEGER;
    

    -- Frees up the memory used by the ldapmod representation (array).
    PROCEDURE free_mod_array(modptr IN MOD_ARRAY);
    

    -- Counts the number of values returned by get_values()
    FUNCTION count_values(vals IN STRING_COLLECTION)
      RETURN PLS_INTEGER;


    -- Counts the number of values returned by get_values_len()
    FUNCTION count_values_len(vals IN BINVAL_COLLECTION)
      RETURN PLS_INTEGER;

    -- Counts the number of values returned by get_values_blob()
    FUNCTION count_values_blob(vals IN BLOB_COLLECTION)
      RETURN PLS_INTEGER;

    -- Frees the memory associated with binary attribute values
    -- that were returned by get_values_blob() function.
    PROCEDURE value_free_blob(vals IN OUT BLOB_COLLECTION);
    


    -- Performs modify dn operation
    FUNCTION rename_s(ld           IN SESSION,
                      dn           IN VARCHAR2,
                      newrdn       IN VARCHAR2,
                      newparent    IN VARCHAR2,
                      deleteoldrdn IN PLS_INTEGER,
                      serverctrls  IN LDAPCONTROL DEFAULT NULL,
                      clientctrls  IN LDAPCONTROL DEFAULT NULL)
      RETURN PLS_INTEGER;

    
    -- Breaks a Distinguished Name (DN) up into its components
    FUNCTION explode_dn(dn      IN VARCHAR2,
                        notypes IN PLS_INTEGER)
      RETURN STRING_COLLECTION;

    

    -- Establishes a SSL connection
    FUNCTION open_ssl(ld              IN SESSION,
                      sslwrl          IN VARCHAR2,
                      sslwalletpasswd IN VARCHAR2,
                      sslauth         IN PLS_INTEGER)
      RETURN PLS_INTEGER;

    FUNCTION get_session_info(ld        IN  SESSION,
                              data_type IN  PLS_INTEGER,
                              data      OUT VARCHAR2)
      RETURN PLS_INTEGER;

    FUNCTION msgfree(lm              IN MESSAGE)
      RETURN PLS_INTEGER;
    PROCEDURE ber_free(ber   IN BER_ELEMENT,
                                 freebuf   IN PLS_INTEGER);

   
    FUNCTION nls_convert_to_utf8 ( data_local    IN   VARCHAR2)

      RETURN VARCHAR2;

    FUNCTION nls_convert_to_utf8 ( data_local    IN   STRING_COLLECTION)

      RETURN STRING_COLLECTION; 

    FUNCTION nls_convert_from_utf8 ( data_utf8    IN   VARCHAR2)

      RETURN VARCHAR2;

    FUNCTION nls_convert_from_utf8 ( data_utf8    IN   STRING_COLLECTION)

      RETURN STRING_COLLECTION; 

    FUNCTION nls_get_dbcharset_name

      RETURN VARCHAR2;
    -------------------- Tracing functions ----------------
    ---- To be used by Oracle Support Analysts ONLY -------
    -------------------------------------------------------
    PROCEDURE set_trace_level(new_trace_level IN PLS_INTEGER);
    FUNCTION  get_trace_level RETURN PLS_INTEGER;
    ---------------- End of Trace Functions -----------------
        
    
    -- LDAP Flag definitions

    -- set use_exception flag to FALSE: not use exception (return error code)
    -- set use_exception flag to TRUE: use exception.
    USE_EXCEPTION BOOLEAN DEFAULT TRUE;

    -- set user_conversion flag to TRUE: All the input string data to the
    --                                   Package functions would
    --                                  be converted from database characterset
    --                                  to UTF8 character set.
    --                                  All the output string data would be
    --                                  converted from UTF8 character set to
    --                                  database character set.
    -- set user_conversion flag to FALSE: No conversions would be done.
    UTF8_CONVERSION BOOLEAN DEFAULT TRUE;
    
    
    --
    -- LDAP constant definitions
    --
    
    PORT     CONSTANT NUMBER := 389;
    SSL_PORT CONSTANT NUMBER := 636;

    -- various options that can be set/unset
    OPT_DESC               CONSTANT NUMBER := 1;
    OPT_DEREF              CONSTANT NUMBER := 2;
    OPT_SIZELIMIT          CONSTANT NUMBER := 3;
    OPT_TIMELIMIT          CONSTANT NUMBER := 4;
    OPT_THREAD_FN_PTRS     CONSTANT NUMBER := 5;
    OPT_REBIND_FN          CONSTANT NUMBER := 6;
    OPT_REBIND_ARG         CONSTANT NUMBER := 7;
    OPT_REFERRALS          CONSTANT NUMBER := 8;
    OPT_RESTART            CONSTANT NUMBER := 9;
    OPT_SSL                CONSTANT NUMBER := 10;
    OPT_IO_FN_PTRS         CONSTANT NUMBER := 11;
    OPT_CACHE_FN_PTRS      CONSTANT NUMBER := 13;
    OPT_CACHE_STRATEGY     CONSTANT NUMBER := 14;
    OPT_CACHE_ENABLE       CONSTANT NUMBER := 15;
    OPT_REFERRAL_HOP_LIMIT CONSTANT NUMBER := 16;
    OPT_PROTOCOL_VERSION   CONSTANT NUMBER := 17;
    OPT_SERVER_CONTROLS    CONSTANT NUMBER := 18;
    OPT_CLIENT_CONTROLS    CONSTANT NUMBER := 19;
    OPT_PREFERRED_LANGUAGE CONSTANT NUMBER := 20;
    OPT_ERROR_NUMBER       CONSTANT NUMBER := 49;
    OPT_ERROR_STRING       CONSTANT NUMBER := 50;


    -- for on/off options
    OPT_ON  CONSTANT NUMBER := 1;
    OPT_OFF CONSTANT NUMBER := 0;

    -- SSL Authentication modes
    GSLC_SSL_NO_AUTH     CONSTANT NUMBER := 1;
    GSLC_SSL_ONEWAY_AUTH CONSTANT NUMBER := 32;
    GSLC_SSL_TWOWAY_AUTH CONSTANT NUMBER := 64;

    -- search scopes
    SCOPE_BASE     CONSTANT NUMBER := 0;
    SCOPE_ONELEVEL CONSTANT NUMBER := 1;
    SCOPE_SUBTREE  CONSTANT NUMBER := 2;

    -- for modifications
    MOD_ADD     CONSTANT NUMBER := 0;
    MOD_DELETE  CONSTANT NUMBER := 1;
    MOD_REPLACE CONSTANT NUMBER := 2;
    MOD_BVALUES CONSTANT NUMBER := 128;

    /* authentication methods available */
    AUTH_NONE   CONSTANT NUMBER := 0;
    AUTH_SIMPLE CONSTANT NUMBER := 128; -- context specific + primitive
    AUTH_SASL   CONSTANT NUMBER := 163; -- v3 SASL

    -- structure for representing an LDAP server connection
    CONNST_NEEDSOCKET CONSTANT NUMBER := 1;
    CONNST_CONNECTING CONSTANT NUMBER := 2;
    CONNST_CONNECTED  CONSTANT NUMBER := 3;

    -- structure used to track outstanding requests
    REQST_INPROGRESS   CONSTANT NUMBER := 1;
    REQST_CHASINGREFS  CONSTANT NUMBER := 2;
    REQST_NOTCONNECTED CONSTANT NUMBER := 3;
    REQST_WRITING      CONSTANT NUMBER := 4;

    -- structure representing an ldap connection
    DEREF_NEVER     CONSTANT NUMBER := 0;
    DEREF_SEARCHING CONSTANT NUMBER := 1;
    DEREF_FINDING   CONSTANT NUMBER := 2;
    DEREF_ALWAYS    CONSTANT NUMBER := 3;

    -- types for ldap URL handling
    URL_ERR_NOTLDAP  CONSTANT NUMBER := 1; -- URL doesn't begin with "ldap
    URL_ERR_NODN     CONSTANT NUMBER := 2; -- URL has no DN (required)
    URL_ERR_BADSCOPE CONSTANT NUMBER := 3; -- URL scope string is invalid
    URL_ERR_MEM      CONSTANT NUMBER := 4; -- can't allocate memory space

    -- types for session info
    TYPE_ADD_INFO    CONSTANT NUMBER := 1;

    
    -- 
    -- possible error codes we can return from LDAP server
    --
    SUCCESS                   CONSTANT NUMBER := 0;
    OPERATIONS_ERROR          CONSTANT NUMBER := 1;
    PROTOCOL_ERROR            CONSTANT NUMBER := 2;
    TIMELIMIT_EXCEEDED        CONSTANT NUMBER := 3;
    SIZELIMIT_EXCEEDED        CONSTANT NUMBER := 4;
    COMPARE_FALSE             CONSTANT NUMBER := 5;
    COMPARE_TRUE              CONSTANT NUMBER := 6;
    STRONG_AUTH_NOT_SUPPORTED CONSTANT NUMBER := 7;
    STRONG_AUTH_REQUIRED      CONSTANT NUMBER := 8;
    PARTIAL_RESULTS           CONSTANT NUMBER := 9;
    REFERRAL                  CONSTANT NUMBER := 10;
    ADMINLIMIT_EXCEEDED       CONSTANT NUMBER := 11;
    UNAVAILABLE_CRITIC        CONSTANT NUMBER := 12;

    NO_SUCH_ATTRIBUTE         CONSTANT NUMBER := 16;
    UNDEFINED_TYPE            CONSTANT NUMBER := 17;
    INAPPROPRIATE_MATCHING    CONSTANT NUMBER := 18;
    CONSTRAINT_VIOLATION      CONSTANT NUMBER := 19;
    TYPE_OR_VALUE_EXISTS      CONSTANT NUMBER := 20;
    INVALID_SYNTAX            CONSTANT NUMBER := 21;

    NO_SUCH_OBJECT            CONSTANT NUMBER := 32;
    ALIAS_PROBLEM             CONSTANT NUMBER := 33;
    INVALID_DN_SYNTAX         CONSTANT NUMBER := 34;
    IS_LEAF                   CONSTANT NUMBER := 35;
    ALIAS_DEREF_PROBLEM       CONSTANT NUMBER := 36;

    INAPPROPRIATE_AUTH        CONSTANT NUMBER := 48;
    INVALID_CREDENTIALS       CONSTANT NUMBER := 49;
    INSUFFICIENT_ACCESS       CONSTANT NUMBER := 50;
    BUSY                      CONSTANT NUMBER := 51;
    UNAVAILABLE               CONSTANT NUMBER := 52;
    UNWILLING_TO_PERFORM      CONSTANT NUMBER := 53;
    LOOP_DETECT               CONSTANT NUMBER := 54;

    NAMING_VIOLATION          CONSTANT NUMBER := 64;
    OBJECT_CLASS_VIOLATION    CONSTANT NUMBER := 65;
    NOT_ALLOWED_ON_NONLEAF    CONSTANT NUMBER := 66;
    NOT_ALLOWED_ON_RDN        CONSTANT NUMBER := 67;
    ALREADY_EXISTS            CONSTANT NUMBER := 68;
    NO_OBJECT_CLASS_MODS      CONSTANT NUMBER := 69;
    RESULTS_TOO_LARGE         CONSTANT NUMBER := 70;

    OTHER                     CONSTANT NUMBER := 80;
    SERVER_DOWN               CONSTANT NUMBER := 81;
    LOCAL_ERROR               CONSTANT NUMBER := 82;
    ENCODING_ERROR            CONSTANT NUMBER := 83;
    DECODING_ERROR            CONSTANT NUMBER := 84;
    TIMEOUT                   CONSTANT NUMBER := 85;
    AUTH_UNKNOWN              CONSTANT NUMBER := 86;
    FILTER_ERROR              CONSTANT NUMBER := 87;
    USER_CANCELLED            CONSTANT NUMBER := 88;
    PARAM_ERROR               CONSTANT NUMBER := 89;
    NO_MEMORY                 CONSTANT NUMBER := 90;


    -- 
    -- possible error codes we can return from LDAP client
    --
    INVALID_LDAP_SESSION      CONSTANT NUMBER := 1024;
    INVALID_LDAP_AUTH_METHOD  CONSTANT NUMBER := 1025;
    INVALID_LDAP_SEARCH_SCOPE CONSTANT NUMBER := 1026;
    INVALID_LDAP_TIME_VALUE   CONSTANT NUMBER := 1027;
    INVALID_LDAP_MESSAGE      CONSTANT NUMBER := 1027;
    INVALID_LDAP_ENTRY_DN     CONSTANT NUMBER := 1028;
    INVALID_LDAPMOD           CONSTANT NUMBER := 1029;
    INVALID_LDAP_DN           CONSTANT NUMBER := 1030;
    INVALID_LDAP_NEWRDN       CONSTANT NUMBER := 1031;
    INVALID_LDAP_NEWPARENT    CONSTANT NUMBER := 1032;
    INVALID_LDAP_DELETEOLDRDN CONSTANT NUMBER := 1033;
    INVALID_SSLWRL            CONSTANT NUMBER := 1034;
    INVALID_SSLWALLETPASSWD   CONSTANT NUMBER := 1035;
    INVALID_SSLAUTH           CONSTANT NUMBER := 1036;
    
    
    
    --
    -- LDAP SERVER exception definitions
    --

    -- LDAP general error
    general_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(general_error, -31202);
    
    -- LDAP Init Failed
    init_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(init_failed, -31203);

    -- Invalid LDAP Session
    invalid_session EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_session, -31204);
    
    -- Invalid LDAP Auth method
    invalid_auth_method EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_auth_method, -31205);
    
    -- Invalid LDAP search scope
    invalid_search_scope EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_search_scope, -31206);

    -- Invalid LDAP search time value
    invalid_search_time_val EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_search_time_val, -31207);
    
    -- Invalid LDAP Message
    invalid_message EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_message, -31208);

    -- LDAP count_entry error
    count_entry_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(count_entry_error, -31209);
    
    -- LDAP get_dn error
    get_dn_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(get_dn_error, -31210);

    -- Invalid LDAP entry dn
    invalid_entry_dn EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_entry_dn, -31211);
    
    -- Invalid LDAP mod_array
    invalid_mod_array EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_mod_array, -31212);

    -- Invalid LDAP mod option
    invalid_mod_option EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_mod_option, -31213);
    
    -- Invalid LDAP mod type
    invalid_mod_type EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_mod_type, -31214);

    -- Invalid LDAP mod value
    invalid_mod_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_mod_value, -31215);
    
    -- Invalid LDAP rdn
    invalid_rdn EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_rdn, -31216);

    -- Invalid LDAP newparent
    invalid_newparent EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_newparent, -31217);
    
    -- Invalid LDAP deleteoldrdn
    invalid_deleteoldrdn EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_deleteoldrdn, -31218);

    -- Invalid LDAP notypes
    invalid_notypes EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_notypes, -31219);

    -- Invalid LDAP SSL wallet location
    invalid_ssl_wallet_loc EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_ssl_wallet_loc, -31220);

    -- Invalid LDAP SSL wallet passwd
    invalid_ssl_wallet_passwd EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_ssl_wallet_passwd, -31221);

    -- Invalid LDAP SSL authentication mode
    invalid_ssl_auth_mode EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_ssl_auth_mode, -31222);    

    -- Not supporting MTS mode
    mts_mode_not_supported EXCEPTION;
    PRAGMA EXCEPTION_INIT(mts_mode_not_supported, -31398);
    
END DBMS_LDAP;
/

--show errors

CREATE OR REPLACE PACKAGE DBMS_LDAP_UTL AS

/**
*************************************************************************************************
*   NAME
*     DBMS_LDAP_UTL
*
*   DESCRIPTION
*     Package specification for DBMS_LDAP_UTL
*     This pakcage contains Oracle EXtension utility functions.
*     These functions can be used for authentication or querying information
*     on users, groups or subscribers in the LDAP server.
*
*   SYNTAX
*     N/A
*
*   REQUIRES
*   1.  Most of the functions accept a valid ldap session as an argument.
*       This ldap session has to be obtained from DBMS_LDAP.init() function.
*   2.  The functions in the package lookup the Oracle Context schema in the 
*       LDAP server to query information on users, groups and subscribers.
*
*   PARAMETERS
*     NONE
*
*   RETURNS
*     This package returns error codes and does not raise any exceptions.
*     See the documentation on individual functions for corresponding
*     error codes returned.
*
*   EXCEPTIONS
*     THIS PACKAGE DOES NOT RAISE ANY EXCEPTIONS.
*
*   USAGE 
*     This Package can be used for querying information on users, groups
*     and subscribers in the LDAP server. 
*
*   EXAMPLES
*   
*   SEE 
*   
****************************************************************************************************
*/
    VERSION                       CONSTANT VARCHAR2(256) := '2';
    INTERFACE_VERSION             CONSTANT VARCHAR2(256) := '2';

    --
    -- DBMS_LDAP_UTL data type definitions
    --

    -- We use RAW(32) as a data structure to store external pointers
    -- It is big enough to store 256 bit pointers!

    -- this data structure holds a pointer to Handle.
    SUBTYPE HANDLE IS RAW(32);            

    -- this data structure holds a pointer to List of Properties. 
    SUBTYPE PROPERTY_SET IS RAW(32);

    -- this data structure holds a pointer to List of Properties. 
    SUBTYPE MOD_PROPERTY_SET IS RAW(32);

    -- this data structure holds a pointer to List of Property sets.
    TYPE PROPERTY_SET_COLLECTION is TABLE of PROPERTY_SET
      INDEX BY BINARY_INTEGER; 
  
    -- String collection.
    SUBTYPE STRING_COLLECTION IS
     DBMS_LDAP.STRING_COLLECTION;

    -- Binval collection.
    SUBTYPE BINVAL_COLLECTION IS
     DBMS_LDAP.BINVAL_COLLECTION;

    -- BLOB collection.
    SUBTYPE BLOB_COLLECTION IS
     DBMS_LDAP.BLOB_COLLECTION;

    -- Session.
    SUBTYPE SESSION IS DBMS_LDAP.SESSION;

    --
    -- DBMS_LDAP_UTL function definitions
    --
/**
*******************************************************************************
*   NAME
*    check_interface_version
*
*   DESCRIPTION
*     Checks for the support of interface version.
*
*   SYNTAX
*   FUNCTION check_interface_version
*   (
*
*   interface_version IN  VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (VARCHAR2 )           interface_version   - Version of the Interface.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   Version Supported.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -   Version not Supported.
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.create_user_handle()
*   
******************************************************************************
*/
FUNCTION check_interface_version ( interface_version IN  VARCHAR2)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    create_subscriber_handle
*
*   DESCRIPTION
*     This function creates a subscriber handle.
*
*   SYNTAX
*   FUNCTION create_subscriber_handle
*   (
*
*   subscriber_hd   OUT HANDLE,
*   subscriber_type IN  PLS_INTEGER,
*   subscriber_id   IN  VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )  subscriber_hd     - A pointer to a handle to 
*                                                   subscriber.
*    (PLS_INTEGER )           subscriber_type   - The type of subscriber id that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.TYPE_DN
*                                                - DBMS_LDAP_UTL.TYPE_GUID
*                                                - DBMS_LDAP_UTL.TYPE_NICKNAME
*                                                - DBMS_LDAP_UTL.TYPE_DEFAULT
*    (VARCHAR2 )              subscriber_id      - The subscriber id representing
*                                               the subscriber entry.
*                                               This can be NULL if 
*                                                subscriber_type is :
*                                                 - DBMS_LDAP_UTL.TYPE_DEFAULT
*                                                then the default subscriber
*                                                would be fetched from 
*                                                Root Oracle Context.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.LDAP_SUCCESS                   -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_subscriber_properties().
*   
******************************************************************************
*/
FUNCTION create_subscriber_handle ( subscriber_hd   OUT HANDLE,
                                    subscriber_type IN  PLS_INTEGER,
                                    subscriber_id   IN  VARCHAR2)
         RETURN PLS_INTEGER;
    
/**
*******************************************************************************
*   NAME
*    get_subscriber_properties
*
*   DESCRIPTION
*     Retrieves the subsciber properties for the given subscriber handle.
*
*   SYNTAX
*   FUNCTION get_subscriber_properties
*   (
*
*   ld                IN   SESSION,
*   subscriber_handle IN   HANDLE,
*   attrs             IN   STRING_COLLECTION,
*   ptype             IN   PLS_INTEGER,
*   ret_pset_coll     OUT  PROPERTY_SET_COLLECTION,
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )           ld                 - A valid ldap session handle.
*    (HANDLE )        subscriber_handle      - The subscriber handle 
*    (STRING_COLLECTION ) attrs              - List of Attributes that 
*                                                        need to be fetched for 
*                                                        the subscriber.
*    (PLS_INTEGER )                 ptype              - Type of properties to be
*                                                        returned.
*                                                        Valid values:
*                                                         - DBMS_LDAP_UTL.ENTRY_PROPERITES
*                                                         - DBMS_LDAP_UTL.COMMON_PROPERITES : To retrieve Subscriber's Oracle Context Properties.
*    (PROPERTY_SET_COLLECTION )  ret_pset_coll      - The subscriber details 
*                                                        containing the requested
*                                                        attributes by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_subscriber_handle().
*   
******************************************************************************
*/
FUNCTION get_subscriber_properties( ld                IN   SESSION,
                             subscriber_handle IN   HANDLE,
                             attrs             IN   STRING_COLLECTION,
                             ptype             IN   PLS_INTEGER,
                             ret_pset_coll     OUT  PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_subscriber_ext_properties
*
*   DESCRIPTION
*     Retrieves the subsciber extended properties for the given subscriber handle.
*
*   SYNTAX
*   FUNCTION get_subscriber_ext_properties
*   (
*
*   ld                IN   SESSION,
*   subscriber_handle IN   HANDLE,
*   attrs             IN   STRING_COLLECTION,
*   ptype             IN   PLS_INTEGER,
*   filter            IN   VARCHAR2,
*   ret_pset_coll     OUT  PROPERTY_SET_COLLECTION,
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )           ld                 - A valid ldap session handle.
*    (HANDLE )        subscriber_handle      - The subscriber handle 
*    (STRING_COLLECTION ) attrs              - List of Attributes that 
*                                                        need to be fetched for 
*                                                        the subscriber.
*    (PLS_INTEGER )                 ptype              - Type of properties to be
*                                                        returned.
*                                                        Valid values:
*                                                         - DBMS_LDAP_UTL.DEFAULT_RAD_PROPERTIES
*                                                         - DBMS_LDAP_UTL.COMMON_PROPERITES : To retrieve Subscriber's Oracle Context Properties.
*    (VARCHAR2)                    filter              - Ldap filter to further
*                                                        refine the user properties
*                                                        returned by function.
*    (PROPERTY_SET_COLLECTION )  ret_pset_coll      - The subscriber details 
*                                                        containing the requested
*                                                        attributes by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_subscriber_handle().
*   
******************************************************************************
*/
FUNCTION get_subscriber_ext_properties( ld                IN   SESSION,
                             subscriber_handle IN   HANDLE,
                             attrs             IN   STRING_COLLECTION,
                             ptype             IN   PLS_INTEGER,
                             filter            IN   VARCHAR2,
                             ret_pset_coll     OUT  PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_subscriber_dn
*
*   DESCRIPTION
*     Returns the subscriber DN.
*
*   SYNTAX
*   FUNCTION get_subscriber_dn
*   (
*
*   ld                IN     SESSION,
*   subscriber_handle IN     HANDLE,
*   dn                OUT    VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )     ld                 - A valid ldap session handle.
*    (HANDLE )  subscriber_handle  - The subscriber handle 
*    (VARCHAR2 )              dn                 - The subscriber DN 
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init().
*   
******************************************************************************
*/
FUNCTION get_subscriber_dn( ld                IN     SESSION,
                                subscriber_handle IN     HANDLE, 
                                dn                OUT    VARCHAR2)
       RETURN PLS_INTEGER;
/**
*******************************************************************************
*   NAME
*    free_propertyset_collection
*
*   DESCRIPTION
*     Frees the memory associated with Property set collection.
*
*   SYNTAX
*   PROCEDURE free_propertyset_collection
*   (
*
*   pset_collection      IN OUT   PROPERTY_SET_COLLECTION
*
*   );
*
*   REQUIRES
*
*   PARAMETERS
*    (PROPERTY_SET_COLLECTION )      pset_collection    - Property set collection
*                                                     returned from one of the 
*                                                     following functions:
*                                                       - DBMS_LDAP_UTL.get_group_membership().
*                                                       - DBMS_LDAP_UTL.get_subscriber_properties().
*                                                       - DBMS_LDAP_UTL.get_user_properties().
*                                                       - DBMS_LDAP_UTL.get_group_properties().
*
*   RETURNS
*     NONE 
* 
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_group_membership(), DBMS_LDAP_UTL.get_subscriber_properties(), DBMS_LDAP_UTL.get_user_properties(), DBMS_LDAP_UTL.get_group_properties().
*   
******************************************************************************
*/
PROCEDURE free_propertyset_collection ( pset_collection      IN OUT   PROPERTY_SET_COLLECTION);


/**
*******************************************************************************
*   NAME
*    create_user_handle
*
*   DESCRIPTION
*     This function creates a user handle.
*
*   SYNTAX
*   FUNCTION create_user_handle
*   (
*
*   user_hd   OUT HANDLE,
*   user_type IN  PLS_INTEGER,
*   user_id   IN  VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )  user_hd     - A pointer to a handle to 
*                                                   user.
*    (PLS_INTEGER )           user_type   - The type of user id that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.TYPE_DN
*                                                - DBMS_LDAP_UTL.TYPE_GUID
*                                                - DBMS_LDAP_UTL.TYPE_NICKNAME
*    (VARCHAR2 )              user_id      - The user id representing
*                                               the user entry.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_user_properties(), DBMS_LDAP_UTL.set_user_handle_properties().
*   
******************************************************************************
*/
FUNCTION create_user_handle ( user_hd   OUT HANDLE,
                              user_type IN  PLS_INTEGER,
                              user_id   IN  VARCHAR2)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    set_user_handle_properties
*
*   DESCRIPTION
*     Configures the user handle properties.
*
*   SYNTAX
*   FUNCTION set_user_handle_properties
*   (
*
*   user_hd         IN  HANDLE,
*   property_type   IN  PLS_INTEGER,
*   property        IN  HANDLE
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )       user_hd           - A pointer to a handle to 
*                                               user.
*    (PLS_INTEGER )  property_type     - The type of property that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.SUBSCRIBER_HANDLE
*    (HANDLE )       property          - The property describing
*                                                the user entry.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.RESET_HANDLE                   -   When caller tries to reset
*                                                  the existing handle
*                                                  properties.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   Subscriber Handle need not be set in User Handle Properties 
*   if the User Handle is created with TYPE_DN or TYPE_GUID as user_type.
*
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_user_properties().
*   
******************************************************************************
*/
FUNCTION set_user_handle_properties ( user_hd     IN  HANDLE,
                                    property_type IN  PLS_INTEGER,
                                    property      IN  HANDLE)
      RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_user_properties
*
*   DESCRIPTION
*     Retrieves the user properties. 
*
*   SYNTAX
*   FUNCTION get_user_properties
*   (
*
*   ld                IN   SESSION,
*   user_handle       IN   HANDLE,
*   attrs             IN   STRING_COLLECTION,
*   ptype             IN   PLS_INTEGER,
*   ret_pset_coll     OUT  PROPERTY_SET_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*       
*
*   PARAMETERS
*    (SESSION )         ld                   - A valid ldap session handle.
*    (HANDLE )          user_handle          - The user handle 
*    (STRING_COLLECTION ) attrs              - List of Attributes that 
*                                                        need to be fetched for 
*                                                        the user.
*    (PLS_INTEGER )                 ptype              - Type of properties to be
*                                                        returned.
*                                                        Valid values:
*                                                         - DBMS_LDAP_UTL.ENTRY_PROPERITES
*                                                         - DBMS_LDAP_UTL.NICKNAME_PROPERTY
*    (PROPERTY_SET_COLLECTION )    ret_pset_collection - The user details 
*                                                        containing the requested
*                                                        attributes by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  user.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*    This function requires a valid subscriber handle to be set
*       in the user handle properties if the user type is of:
*        - DBMS_LDAP_UTL.TYPE_NICKNAME.
*       This function doesn't identify a NULL subscriber handle
*       as a default subscriber.
*       Default subscriber can be obtained from :
*        - DBMS_LDAP_UTL.create_subscriber_handle()
*       where a NULL subscriber_id is passed as an argument.
*    If the user type is any of the following:
*        - DBMS_LDAP_UTL.TYPE_GUID.
*        - DBMS_LDAP_UTL.TYPE_DN.
*       then the subscriber handle need not be set in the user
*       handle properties, even if set it would be ignored.
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_user_handle().
*   
******************************************************************************
*/
FUNCTION get_user_properties( ld                IN   SESSION,
                             user_handle       IN   HANDLE,
                             attrs             IN   STRING_COLLECTION,
                             ptype             IN   PLS_INTEGER,
                             ret_pset_coll     OUT  PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_user_dn
*
*   DESCRIPTION
*     Returns the user DN.
*
*   SYNTAX
*   FUNCTION get_user_dn
*   (
*
*   ld                IN     SESSION,
*   user_handle       IN     HANDLE,
*   dn                OUT    VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )     ld                 - A valid ldap session handle.
*    (HANDLE )  user_handle        - The user handle 
*    (VARCHAR2 )              dn                 - The user DN 
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES    -   Multiple number of user 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  user.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init().
*   
******************************************************************************
*/
FUNCTION get_user_dn( ld                IN     SESSION,
                             user_handle       IN     HANDLE, 
                             dn                OUT    VARCHAR2)
       RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    create_group_handle
*
*   DESCRIPTION
*     This function creates a group handle.
*
*   SYNTAX
*   FUNCTION create_group_handle
*   (
*
*   group_hd   OUT HANDLE,
*   group_type IN  PLS_INTEGER,
*   group_id   IN  VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )  group_hd     - A pointer to a handle to 
*                                                   group.
*    (PLS_INTEGER )           group_type   - The type of group id that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.TYPE_DN
*                                                - DBMS_LDAP_UTL.TYPE_GUID
*                                                - DBMS_LDAP_UTL.TYPE_NICKNAME
*    (VARCHAR2 )              group_id      - The group id representing
*                                               the group entry.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_group_properties(), DBMS_LDAP_UTL.set_group_handle_properties().
*   
******************************************************************************
*/
FUNCTION create_group_handle ( group_hd   OUT HANDLE,
                              group_type IN  PLS_INTEGER,
                              group_id   IN  VARCHAR2)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    set_group_handle_properties
*
*   DESCRIPTION
*     Configures the group handle properties.
*
*   SYNTAX
*   FUNCTION set_group_handle_properties
*   (
*
*   group_hd       IN  HANDLE,
*   property_type  IN  PLS_INTEGER,
*   property       IN  HANDLE
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )        group_hd          - A pointer to a handle to 
*                                               group.
*    (PLS_INTEGER )   property_type     - The type of property that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.GROUP_HANDLE
*    (HANDLE )        property          - The property describing
*                                                the group entry.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.RESET_HANDLE                   -   When caller tries to reset
*                                                  the existing handle
*                                                  properties.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   Subscriber Handle need not be set in Group Handle Properties 
*   if the Group Handle is created with TYPE_DN or TYPE_GUID as group_type.
*
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_group_properties().
*   
******************************************************************************
*/
FUNCTION set_group_handle_properties ( group_hd       IN  HANDLE,
                                    property_type IN  PLS_INTEGER,
                                    property      IN  HANDLE)
      RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_group_properties
*
*   DESCRIPTION
*     Retrieves the group properties. 
*
*   SYNTAX
*   FUNCTION get_group_properties
*   (
*
*   ld                IN   SESSION,
*   group_handle      IN   HANDLE,
*   attrs             IN   STRING_COLLECTION,
*   ptype             IN   PLS_INTEGER,
*   ret_pset_coll     OUT  PROPERTY_SET_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*       has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )         ld                  - A valid ldap session handle.
*    (HANDLE )          group_handle        - The group handle 
*    (STRING_COLLECTION ) attrs             - List of Attributes that 
*                                                        need to be fetched for 
*                                                        the group.
*    (PLS_INTEGER )                 ptype              - Type of properties to be
*                                                        returned.
*                                                        Valid values:
*                                                         - DBMS_LDAP_UTL.ENTRY_PROPERITES
*    (PROPERTY_SET_COLLECTION )    ret_pset_coll      - The group details 
*                                                        containing the requested
*                                                        attributes by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_GROUP                  -   Group doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_GROUP_ENTRIES         -   Multiple number of group 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  group.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*    This function requires a valid ldap session handle which
*       has to be obtained from DBMS_LDAP.init() function.
*    This function requires a valid subscriber handle to be set
*       in the group handle properties if the group type is of:
*        - DBMS_LDAP_UTL.TYPE_NICKNAME.
*       This function doesn't identify a NULL subscriber handle
*       as a default subscriber.
*       Default subscriber can be obtained from :
*        - DBMS_LDAP_UTL.create_subscriber_handle()
*       where a NULL subscriber_id is passed as an argument.
*    If the group type is any of the following:
*        - DBMS_LDAP_UTL.TYPE_GUID.
*        - DBMS_LDAP_UTL.TYPE_DN.
*       then the subscriber handle need not be set in the group
*       handle properties, even if set it would be ignored.
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_group_handle().
*   
******************************************************************************
*/
FUNCTION get_group_properties( ld                IN   SESSION,
                             group_handle      IN   HANDLE,
                             attrs             IN   STRING_COLLECTION,
                             ptype             IN   PLS_INTEGER,
                             ret_pset_coll     OUT  PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_group_dn
*
*   DESCRIPTION
*     Returns the group DN.
*
*   SYNTAX
*   FUNCTION get_group_dn
*   (
*
*   ld                IN     SESSION,
*   group_handle      IN     HANDLE,
*   dn                OUT    VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )     ld                 - A valid ldap session handle.
*    (HANDLE )  group_handle        - The group handle 
*    (VARCHAR2 )              dn                 - The group DN 
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_GROUP                  -   Group doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_GROUP_ENTRIES    -   Multiple number of group 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  group.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init().
*   
******************************************************************************
*/
FUNCTION get_group_dn( ld                IN     SESSION,
                             group_handle       IN     HANDLE, 
                             dn                OUT    VARCHAR2)
       RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    authenticate_user
*
*   DESCRIPTION
*     This function Authenticates the user against OiD.
*
*   SYNTAX
*    FUNCTION authenticate_user 
*    (
*
*    ld                  IN SESSION,
*    user_handle         IN HANDLE,
*    auth_type           IN PLS_INTEGER,
*    credentials         IN VARCHAR2,
*    binary_credentials  IN RAW
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from init() function.
*
*   PARAMETERS
*     (SESSION )       ld                  - A valid ldap session handle.
*     (HANDLE )    user                - User handle.
*     (PLS_INTEGER )             auth_type           - Type of authentication,
*                                                      Valid values are:
*                                                       - DBMS_LDAP_UTL.AUTH_SIMPLE
*     (VARCHAR2 )                credentials         - The user credentials,
*                                                       Valid values :
*                                                       for DBMS_LDAP_UTL.AUTH_SIMPLE - password
*     (RAW )                     binary_credentials  - The binary credentials,
*                                                       Valid values :
*                                                       for DBMS_LDAP_UTL.AUTH_SIMPLE - NULL
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -   Authentication failed.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user DN 
*                                                entries exist in the 
*                                                directory for the given user.
*     DBMS_LDAP_UTL.INVALID_SUBSCRIBER_ORCL_CTX    -   Invalid Subscriber Oracle Context.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                DN entries exist in the 
*                                                directory for the given 
*                                                subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -   Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.ACCT_TOTALLY_LOCKED_EXCP       -   User account is locked. 
*     DBMS_LDAP_UTL.AUTH_PASSWD_CHANGE_WARN        -   Password should be changed.
*     DBMS_LDAP_UTL.AUTH_FAILURE_EXCP              -   Authentication failed.
*     DBMS_LDAP_UTL.PWD_EXPIRED_EXCP               -   User password has expired.
*     DBMS_LDAP_UTL.PWD_GRACELOGIN_WARN             -   Grace login for User.
*     LDAP error codes                      -   Returns proper DBMS_LDAP error 
*                                               codes for unconditional 
*                                               failures while carrying out
*                                               LDAP operations by the ldap 
*                                               server.
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_user_handle().
*   
****************************************************************************
*/
FUNCTION authenticate_user( ld                  IN SESSION,
                            user_handle         IN HANDLE,
                            auth_type           IN PLS_INTEGER,
                            credentials         IN VARCHAR2,
                            binary_credentials  IN RAW)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_user_props_and_auth
*
*   DESCRIPTION
*     This function Authenticates the user against OiD.
*
*   SYNTAX
*    FUNCTION get_user_props_and_auth 
*    (
*
*    ld                  IN   SESSION,
*    user_handle         IN   HANDLE,
*    auth_type           IN   PLS_INTEGER,
*    attrs               IN   STRING_COLLECTION,
*    credentials         IN   VARCHAR2,
*    binary_credentials  IN   RAW,
*    ret_pset_coll       OUT  PROPERTY_SET_COLLECTION
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from init() function.
*
*   PARAMETERS
*     (SESSION )       ld                  - A valid ldap session handle.
*     (HANDLE )    user                - User handle.
*     (PLS_INTEGER )             auth_type           - Type of authentication,
*                                                      Valid values are:
*                                                       - DBMS_LDAP_UTL.AUTH_SIMPLE
*     (STRING_COLLECTION)        attrs               - List of required attributes
*                                                      of user.
*     (VARCHAR2 )                credentials         - The user credentials,
*                                                       Valid values :
*                                                       for DBMS_LDAP_UTL.AUTH_SIMPLE - password
*     (RAW )                     binary_credentials  - The binary credentials,
*                                                       Valid values :
*                                                       for DBMS_LDAP_UTL.AUTH_SIMPLE - NULL
*    (PROPERTY_SET_COLLECTION )  ret_pset_coll       - The user details 
*                                                        containing the attributes
*                                                        requested by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -   Authentication failed.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user DN 
*                                                entries exist in the 
*                                                directory for the given user.
*     DBMS_LDAP_UTL.INVALID_SUBSCRIBER_ORCL_CTX    -   Invalid Subscriber Oracle Context.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                DN entries exist in the 
*                                                directory for the given 
*                                                subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -   Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.ACCT_TOTALLY_LOCKED_EXCP       -   User account is locked. 
*     DBMS_LDAP_UTL.AUTH_PASSWD_CHANGE_WARN        -   Password should be changed.
*     DBMS_LDAP_UTL.AUTH_FAILURE_EXCP              -   Authentication failed.
*     DBMS_LDAP_UTL.PWD_EXPIRED_EXCP               -   User password has expired.
*     DBMS_LDAP_UTL.PWD_GRACELOGIN_WARN             -   Grace login for User.
*     LDAP error codes                      -   Returns proper DBMS_LDAP error 
*                                               codes for unconditional 
*                                               failures while carrying out
*                                               LDAP operations by the ldap 
*                                               server.
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_user_handle().
*   
****************************************************************************
*/
FUNCTION get_user_props_and_auth( ld                  IN  SESSION,
                            user_handle         IN  HANDLE,
                            auth_type           IN  PLS_INTEGER,
                            attrs               IN  STRING_COLLECTION,
                            credentials         IN  VARCHAR2,
                            binary_credentials  IN  RAW,
                            ret_pset_coll       OUT PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    authenticate_user_ext
*
*   DESCRIPTION
*     This function Authenticates the user against OiD.
*
*   SYNTAX
*    FUNCTION authenticate_user_ext
*    (
*
*    ld                  IN SESSION,
*    user_handle         IN HANDLE,
*    auth_type           IN PLS_INTEGER,
*    password_attr       IN VARCHAR2,
*    password            IN VARCHAR2,
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from init() function.
*
*   PARAMETERS
*     (SESSION )       ld                  - A valid ldap session handle.
*     (HANDLE )    user                - User handle.
*     (PLS_INTEGER )             auth_type           - Type of authentication,
*                                                      Valid values are:
*                                                       - DBMS_LDAP_UTL.AUTH_EXTENDED
*     (VARCHAR2 )                password_attr       - The password attribute
*                                                       for comparision.
*     (VARCHAR2)                 password            - User Credentials.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -   Authentication failed.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user DN 
*                                                entries exist in the 
*                                                directory for the given user.
*     DBMS_LDAP_UTL.INVALID_SUBSCRIBER_ORCL_CTX    -   Invalid Subscriber Oracle Context.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                DN entries exist in the 
*                                                directory for the given 
*                                                subscriber.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -   Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.ACCT_TOTALLY_LOCKED_EXCP       -   User account is locked. 
*     DBMS_LDAP_UTL.AUTH_PASSWD_CHANGE_WARN        -   Password should be changed.
*     DBMS_LDAP_UTL.AUTH_FAILURE_EXCP              -   Authentication failed.
*     DBMS_LDAP_UTL.PWD_EXPIRED_EXCP               -   User password has expired.
*     DBMS_LDAP_UTL.PWD_GRACELOGIN_WARN             -   Grace login for User.
*     LDAP error codes                      -   Returns proper DBMS_LDAP error 
*                                               codes for unconditional 
*                                               failures while carrying out
*                                               LDAP operations by the ldap 
*                                               server.
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_user_handle().
*   
****************************************************************************
*/
FUNCTION authenticate_user_ext( ld                  IN SESSION,
                            user_handle         IN HANDLE,
                            auth_type           IN PLS_INTEGER,
                            password_attr       IN VARCHAR2,
                            password            IN VARCHAR2)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_group_membership
*
*   DESCRIPTION
*     This function returns the list of groups of which the user
*     is a member.
*
*   SYNTAX
*    FUNCTION get_group_membership
*    (
*
*    ld           IN  SESSION,
*    user_handle  IN  HANDLE,
*    nested       IN  PLS_INTEGER,
*    attr_list    IN  STRING_COLLECTION,
*    ret_groups   OUT PROPERTY_SET_COLLECTION,
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )            ld          - LDAP session handle.
*    (HANDLE )         user_handle - User handle.
*    (PLS_INTEGER )                  nested      - Type of membership the
*                                                 user holds in groups 
*                                                 valid values are :
*                                                  DBMS_LDAP_UTL.NESTED_MEMBERSHIP
*                                                  DBMS_LDAP_UTL.DIRECT_MEMBERSHIP
*    (STRING_COLLECTION )        attr_list  - List of attributes to be
*                                                returned.
*    (PROPERTY_SET_COLLECTION )  ret_groups - Pointer to pointer to a 
*                                               array of group entries.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS              -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR        -    Other Error
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init().
*   
******************************************************************************
*/
FUNCTION get_group_membership ( ld           IN  SESSION,
                                user_handle  IN  HANDLE,
                                nested       IN  PLS_INTEGER,
                                attr_list    IN  STRING_COLLECTION,
                                ret_groups   OUT PROPERTY_SET_COLLECTION)
     RETURN PLS_INTEGER;
/**
*******************************************************************************
*   NAME
*    free_handle
*
*   DESCRIPTION
*     Frees the memory associated with the handle.
*
*   SYNTAX
*   PROCEDURE free_handle
*   (
*
*   handle    IN OUT  HANDLE
*
*   );
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE *)        handle         - Pointer to handle.
*
*   RETURNS
*     NONE 
* 
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.create_user_handle(), DBMS_LDAP_UTL.create_subscriber_handle(), DBMS_LDAP_UTL.create_group_handle().
*   
******************************************************************************
*/
PROCEDURE free_handle ( handle    IN OUT  HANDLE);

/**
*******************************************************************************
*   NAME
*    check_group_membership
*
*   DESCRIPTION
*     This function checks the membership of the user to a group.
*
*   SYNTAX
*    FUNCTION check_group_membership
*    (
*
*    ld             IN  SESSION,
*    user_handle    IN  HANDLE,
*    group_handle   IN  HANDLE,
*    nested         IN  PLS_INTEGER
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from DBMS_LDAP.init() function.
*
*   PARAMETERS
*    (SESSION )     ld                 - LDAP session handle.
*    (HANDLE )  user_handle        - User handle.
*    (HANDLE )  group_handle       - Group Handle.
*    (PLS_INTEGER )           nested             - Type of membership the
*                                                user holds in groups 
*                                                valid values are :
*                                                 DBMS_LDAP_UTL.NESTED_MEMBERSHIP
*                                                 DBMS_LDAP_UTL.DIRECT_MEMBERSHIP
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   If user is a member.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_GROUP_MEMBERSHIP            -   If user is not a member.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP_UTL.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_group_membership().
*   
******************************************************************************
*/
FUNCTION check_group_membership( ld             IN  SESSION,
                                 user_handle    IN  HANDLE,
                                 group_handle   IN  HANDLE,
                                 nested         IN  PLS_INTEGER)
       RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_property_names
*
*   DESCRIPTION
*     Retrieves the list of property names in the propertyset.
*
*   SYNTAX
*   FUNCTION get_property_names
*   (
*
*   pset                   IN   PROPERTY_SET,
*   property_names         OUT  STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (PROPERTY_SET )      pset           - PropertySet in the PropertySet collection 
*                                                        returned from any of
                                                         the following functions:
*                                                         - DBMS_LDAP_UTL.get_group_membership()
*                                                         - DBMS_LDAP_UTL.get_subscriber_properties()
*                                                         - DBMS_LDAP_UTL.get_user_properties()
*                                                         - DBMS_LDAP_UTL.get_group_properties()
*    (STRING_COLLECTION)  property_names   - List of Property Names associated
*                                            with PropertySet.
*
*   RETURNS
* 
*    DBMS_LDAP_UTL.SUCCESS             - On successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR        -   Invalid input parameters.
*    DBMS_LDAP_UTL.GENERAL_ERROR       - On Error.
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_property_values().
*   
******************************************************************************
*/
FUNCTION get_property_names( pset             IN   PROPERTY_SET,
                             property_names   OUT  STRING_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_property_values
*
*   DESCRIPTION
*     Retrieves the property values(strings) for a given property name
*     and property.
*
*   SYNTAX
*   FUNCTION get_property_values
*   (
*
*   pset              IN   PROPERTY_SET,
*   property_name     IN   VARCHAR2,
*   property_values   OUT  STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (VARCHAR2 )       property_name        - Property name.
*    (PROPERTY_SET )   pset                 - PropertySet in PropertySet Collection obtained from 
*                                             any of the following function returns:
*                                               - DBMS_LDAP_UTL.get_group_membership()
*                                               - DBMS_LDAP_UTL.get_subscriber_properties()
*                                               - DBMS_LDAP_UTL.get_user_properties()
*                                               - DBMS_LDAP_UTL.get_group_properties()
*    (STRING_COLLECTION ) property_values   - List of property values(strings).
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                  - On successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR            - On failure.
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_property_values_len().
*   
******************************************************************************
*/
FUNCTION get_property_values(pset            IN   PROPERTY_SET,
                             property_name   IN   VARCHAR2,
                             property_values OUT  STRING_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_property_values_len
*
*   DESCRIPTION
*     Retrieves the binary property values for a given property name
*     and property.
*
*   SYNTAX
*   FUNCTION get_property_values_len
*   (
*
*   pset              IN   PROPERTY_SET,
*   property_name     IN   VARCHAR2,
*   property_values   OUT  BINVAL_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (VARCHAR2 )       property_name        - Property name.
*    (PROPERTY_SET )   pset                 - PropertySet in PropertySet Collection obtained from 
*                                             any of the following function returns:
*                                               - DBMS_LDAP_UTL.get_group_membership()
*                                               - DBMS_LDAP_UTL.get_subscriber_properties()
*                                               - DBMS_LDAP_UTL.get_user_properties()
*                                               - DBMS_LDAP_UTL.get_group_properties()
*    (BINVAL_COLLECTION ) property_values   - List of binary property values.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                  - On successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR            - On failure.
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_property_values().
*   
******************************************************************************
*/
FUNCTION get_property_values_len(pset            IN   PROPERTY_SET,
                                 property_name   IN   VARCHAR2,
                                 property_values OUT  BINVAL_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_property_values_blob
*
*   DESCRIPTION
*     Retrieves the binary property values for a given property name
*     and property.
*
*   SYNTAX
*   FUNCTION get_property_values_blob
*   (
*
*   pset              IN   PROPERTY_SET,
*   property_name     IN   VARCHAR2,
*   property_values   OUT  BLOB_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (VARCHAR2 )       property_name        - Property name.
*    (PROPERTY_SET )   pset                 - PropertySet in PropertySet Collection obtained from 
*                                             any of the following function returns:
*                                               - DBMS_LDAP_UTL.get_group_membership()
*                                               - DBMS_LDAP_UTL.get_subscriber_properties()
*                                               - DBMS_LDAP_UTL.get_user_properties()
*                                               - DBMS_LDAP_UTL.get_group_properties()
*    (BLOB_COLLECTION ) property_values     - List of binary property values.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                  - On successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR            - On failure.
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_property_values().
*   
******************************************************************************
*/
FUNCTION get_property_values_blob(pset            IN   PROPERTY_SET,
                                 property_name   IN   VARCHAR2,
                                 property_values OUT  BLOB_COLLECTION)
     RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    property_value_free_blob
*
*   DESCRIPTION
*     Frees the property value memory
*
*   SYNTAX
*   PROCEDURE property_value_free_blob
*   (
*
*   vals              IN OUT   BLOB_COLLECTION
*
*   );
*
*   REQUIRES
*
*   PARAMETERS
*    (BLOB_COLLECTION )       vals        - Property values obtained from
*                                           get_property_values_len
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                  - On successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR            - On failure.
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_property_values_len().
*   
******************************************************************************
*/
PROCEDURE property_value_free_blob(vals   IN OUT BLOB_COLLECTION);

/**
*******************************************************************************
*   NAME
*    locate_subscriber_for_user
*
*   DESCRIPTION
*     Retrieves the subsciber for the given user and returns a handle to it.
*
*   SYNTAX
*   FUNCTION locate_subscriber_for_user
*   (
*
*   ld                IN  SESSION,
*   user_handle       IN  HANDLE,
*   subscriber_handle OUT HANDLE
*
*   )
*   RETURN PLS_INTEGER
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from ldap_init() function.
*
*   PARAMETERS
*    (SESSION )           ld                 - A valid ldap session handle.
*    (HANDLE )            user_handle        - The user handle 
*    (HANDLE )            subscriber_handle  - The subscriber handle.

*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.NO_SUCH_SUBSCRIBER             -   Subscriber doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_SUBSCRIBER_ENTRIES    -   Multiple number of subscriber 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  subscriber.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  user.
*     DBMS_LDAP_UTL.SUBSCRIBER_NOT_FOUND           -   Unable to locate subscriber
*                                                      for the given user.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to ldap_init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.create_user_handle().
*   
******************************************************************************
*/
FUNCTION locate_subscriber_for_user ( ld                IN  SESSION,
                                      user_handle       IN  HANDLE,
                                      subscriber_handle OUT HANDLE)

   RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    set_user_properties
*
*   DESCRIPTION
*     Modifies the properties of a user.
*
*   SYNTAX
*   FUNCTION set_user_properties
*   (
*
*   ld                IN  SESSION,
*   user_handle       IN  HANDLE,
*   pset_type         IN  PLS_INTEGER,
*   mod_pset          IN  PROPERTY_SET,
*   mod_op            IN  PLS_INTEGER
*
*   )
*   RETURN PLS_INTEGER
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from ldap_init() function.
*
*   PARAMETERS
*    (SESSION )           ld                 - A valid ldap session handle.
*    (HANDLE )            user_handle        - The user handle 
*    (PLS_INTEGER)        pset_type          - Type of PropertySet being
*                                              Modified:
*                                              Valid Values:
*                                               - ENTRY_PROPERTIES
*    (PROPERTY_SET)       mod_pset           - Data Structure containing
*                                              Modify operations to be 
*                                              performed on PropertySet.
*    (PLS_INTEGER)        mod_op             - Type of Modify operation to be
*                                              performed on the PropertySet:
*                                              Valid Values are:
*                                               - ADD_PROPERTYSET
*                                               - MODIFY_PROPERTYSET
*                                               - DELETE_PROPERTYSET
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  user.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.PWD_MIN_LENGTH_ERROR          -  Password length is less
*                                                    than minimum required 
*                                                    length.
*     DBMS_LDAP_UTL.PWD_NUMERIC_ERROR             -  Password must contain
*                                                    numeric characters.
*     DBMS_LDAP_UTL.PWD_NULL_ERROR                -  Password cannot be NULL.
*     DBMS_LDAP_UTL.PWD_INHISTORY_ERROR           -  Password cannot not be
*                                                    the same as the one
*                                                    that is being replaced.
*     DBMS_LDAP_UTL.PWD_ILLEGALVALUE_ERROR        -  Password contains
*                                                    illegal characters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to ldap_init().
*
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.get_user_properties().
*   
******************************************************************************
*/
FUNCTION set_user_properties ( ld                IN  SESSION,
                               user_handle       IN  HANDLE,
                               pset_type         IN  PLS_INTEGER,
                               mod_pset          IN  PROPERTY_SET,
                               mod_op            IN  PLS_INTEGER)
   RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    create_mod_propertyset
*
*   DESCRIPTION
*     Creates a MOD_PROPERTY_SET data structure.
*
*   SYNTAX
*   FUNCTION create_mod_propertyset
*   (
*
*   pset_type         IN   PLS_INTEGER,
*   pset_name         IN   VARCHAR2,
*   mod_pset          OUT  MOD_PROPERTY_SET
*
*   )
*   RETURN PLS_INTEGER
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from ldap_init() function.
*
*   PARAMETERS
*    (PLS_INTEGER)        pset_type          - Type of PropertySet being
*                                              Modified:
*                                              Valid Values:
*                                               - ENTRY_PROPERTIES
*    (VARCHAR2)           pset_name          - Name of PropertySet.
*                                              This can be NULL if 
*                                              ENTRY_PROPERTIES are being
*                                              modified.
*    (MOD_PROPERTY_SET)       mod_pset           - Data Structure to contain
*                                              Modify operations to be 
*                                              performed on PropertySet.
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.populate_mod_propertyset().
*   
******************************************************************************
*/
FUNCTION create_mod_propertyset ( pset_type         IN   PLS_INTEGER,
                                  pset_name         IN   VARCHAR2,
                                  mod_pset          OUT  MOD_PROPERTY_SET)
   RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    populate_mod_propertyset
*
*   DESCRIPTION
*     Populates the MOD_PROPERTY_SET data structure. 
*
*   SYNTAX
*   FUNCTION populate_mod_propertyset
*   (
*
*   mod_pset          IN   MOD_PROPERTY_SET,
*   property_mod_op   IN   PLS_INTEGER,
*   property_name     IN   VARCHAR2,
*   property_values   IN   STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from ldap_init() function.
*
*   PARAMETERS
*    (MOD_PROPERTY_SET)       mod_pset           - Mod-PropertySet data structure.
*    (PLS_INTEGER)        property_mod_op    - Type of Modify operation
*                                              to be performed on a Property.
*                                              Valid Values:
*                                               - ADD_PROPERTY
*                                               - REPLACE_PROPERTY
*                                               - DELETE_PROPERTY
*    (VARCHAR2)           property_name      - Name of the Property.
*    (STRING_COLLECTION)  propery_values     - Values associated to the
*                                              Property.
* 
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.create_mod_propertyset().
*   
******************************************************************************
*/
FUNCTION populate_mod_propertyset ( mod_pset          IN   MOD_PROPERTY_SET,
                                    property_mod_op   IN   PLS_INTEGER,
                                    property_name     IN   VARCHAR2,
                                    property_values   IN   STRING_COLLECTION)
   RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    free_mod_propertyset
*
*   DESCRIPTION
*     Frees the MOD_PROPERTY_SET data structure.
*
*   SYNTAX
*   PROCEDURE free_mod_propertyset
*   (
*
*   mod_pset          IN   MOD_PROPERTY_SET
*
*   );
*
*   REQUIRES
*   NONE
*
*   PARAMETERS
*    (PROPERTY_SET)       mod_pset           - Mod-PropertySet data structure.
* 
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.create_mod_propertyset().
*   
******************************************************************************
*/
PROCEDURE free_mod_propertyset      ( mod_pset          IN OUT  MOD_PROPERTY_SET);

/**
*******************************************************************************
*   NAME
*    get_user_extended_properties
*
*   DESCRIPTION
*     Retrives user extended Properties.
*
*   SYNTAX
*   FUNCTION get_user_extended_properties
*   (
*
*   ld                IN   SESSION,
*   user_handle       IN   HANDLE,
*   attrs             IN   STRING_COLLECTION,
*   ptype             IN   PLS_INTEGER,
*   filter            IN   VARCHAR2,
*   ret_pset_coll     OUT  PROPERTY_SET_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*    This function requires a valid ldap session handle which
*    has to be obtained from ldap_init() function.
*
*   PARAMETERS
*    (SESSION )         ld                   - A valid ldap session handle.
*    (HANDLE )          user_handle          - The user handle 
*    (STRING_COLLECTION ) attrs              - List of Attributes that 
*                                                        need to be fetched for 
*                                                        the user.
*    (PLS_INTEGER )                 ptype              - Type of properties to be
*                                                        returned.
*                                                        Valid values:
*                                                         - DBMS_LDAP_UTL.EXTPROPTYPE_RAD
*    (VARCHAR2)                    filter              - Ldap filter to further
*                                                        refine the user properties
*                                                        returned by function.
*    (PROPERTY_SET_COLLECTION )    ret_pset_collection - The user details 
*                                                        containing the requested
*                                                        attributes by the caller.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_USER                   -   User doesn't exist.
*     DBMS_LDAP_UTL.MULTIPLE_USER_ENTRIES          -   Multiple number of user 
*                                                  DN entries exist in the 
*                                                  directory for the given 
*                                                  user.
*     USER_PROPERTY_NOT_FOUND                      -    User Extended Property 
*                                                       doesn't exist.
*     DBMS_LDAP_UTL.INVALID_ROOT_ORCL_CTX          -    Invalid Root Oracle Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*     DBMS_LDAP error codes                      -    Returns proper LDAP error codes
*                                                for unconditional failures 
*                                                while carrying out
*                                                LDAP operations by the ldap 
*                                                server.
*
*   USAGE 
*   This function can only be called after a valid
*   ldap session is obtained from a call to DBMS_LDAP.init().
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP.init(), DBMS_LDAP_UTL.get_user_properties().
*   
******************************************************************************
*/
FUNCTION get_user_extended_properties ( ld              IN   SESSION,
                               user_handle     IN   HANDLE,
                               attrs           IN   STRING_COLLECTION,
                               ptype           IN   PLS_INTEGER,
                               filter          IN   VARCHAR2,
                               ret_pset_coll   OUT  PROPERTY_SET_COLLECTION)
    RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    normalize_dn_with_case
*
*   DESCRIPTION
*     Normalizes the given DN.
*
*   SYNTAX
*    FUNCTION normalize_dn_with_case 
*    (
*
*    dn              IN  VARCHAR2,
*    lower_case      IN  PLS_INTEGER,
*    norm_dn         OUT VARCHAR2
*
*    )
*    RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*     (VARCHAR2 )                  dn                - DN.
*     (PLS_INTEGER )               lower_case        - If set to 1 : The 
*                                                         normalized DN would 
*                                                         be returned in
*                                                         lower case.
*                                                      If set to 0 : The case
*                                                         would be preserved
*                                                         in the normalized
*                                                         DN string.
*                                            
*     (VARCHAR2 )                  norm_dn           - Normalized DN.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -   On failure.
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   N/A
*   
****************************************************************************
*/
FUNCTION normalize_dn_with_case ( dn             IN  VARCHAR2,
                                  lower_case     IN  PLS_INTEGER,
                                  norm_dn        OUT VARCHAR2)
    RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    create_service_handle
*
*   DESCRIPTION
*     This function creates a service handle.
*
*   SYNTAX
*   FUNCTION create_service_handle
*   (
*
*   service_handle   OUT HANDLE,
*   service_type     IN  PLS_INTEGER,
*   service_id       IN  VARCHAR2
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (HANDLE )             service_handle    - A pointer to a handle to 
*                                                   service.
*    (PLS_INTEGER )           service_type   - The type of service id that 
*                                               is passed.
*                                             Valid values for this argument are:
*                                                - DBMS_LDAP_UTL.TYPE_DN
*    (VARCHAR2 )              service_id      - The service id representing
*                                               the service entry.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_subscribed_users().
*   
******************************************************************************
*/
FUNCTION create_service_handle ( service_handle   OUT HANDLE,
                              service_type        IN  PLS_INTEGER,
                              service_id          IN  VARCHAR2)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_subscribed_users
*
*   DESCRIPTION
*     This function retrieves all the users subscribed to a service.
*
*   SYNTAX
*   FUNCTION get_subscribed_users
*   (
*
*   ld              IN  SESSION,
*   service_handle  IN  HANDLE,
*   users           OUT STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    
*    (SESSION )         ld             - A valid ldap session handle.
*
*    (HANDLE )  service_handle         - A pointer to a handle to 
*                                                   service.
*    (STRING_COLLECTION )      users   - List of users subscribed to a service.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUCH_SERVICE                -   Service doesn't exist.
*     DBMS_LDAP_UTL.NO_USER_SUBSCRIPTIONS          -   No users have been
*                                                      subscribed for this 
*                                                      service.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.check_user_subscription(), DBMS_LDAP_UTL.subscribe_user(), DBMS_LDAP_UTL.unsubscribe_user().
*   
******************************************************************************
*/
FUNCTION get_subscribed_users ( ld             IN  SESSION,
                              service_handle   IN  HANDLE,
                              users            OUT STRING_COLLECTION)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_subscribed_services
*
*   DESCRIPTION
*     This function retrieves all the services to which a user is subscribed.
*
*   SYNTAX
*   FUNCTION get_subscribed_services
*   (
*
*   ld           IN  SESSION,
*   user_handle  IN  HANDLE,
*   services     OUT STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*
*    (SESSION )             ld              - A valid ldap session handle.
*
*    (HANDLE )              user_handle     - A pointer to a handle to 
*                                                   user.
*    (STRING_COLLECTION )   services        - List of services to which a user is subscribed.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SUBSCRIPTIONS_TO_SERVICES   -   User hasen't been
*                                                      subscribed to any 
*                                                      services.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_available_services().
*   
******************************************************************************
*/
FUNCTION get_subscribed_services ( ld            IN   SESSION,
                                   user_handle   IN HANDLE,
                                   services OUT  STRING_COLLECTION)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    get_available_services
*
*   DESCRIPTION
*     This function retrieves all the Distinguished Names of services under
*     a subscriber.
*
*   SYNTAX
*   FUNCTION get_available_services
*   (
*
*   ld                 IN  SESSION,
*   subscriber_handle  IN  HANDLE,
*   services           OUT STRING_COLLECTION
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*    (SESSION )             ld                    - A valid ldap session handle.
*    (HANDLE )              subscriber_handle     - A pointer to a handle to 
*                                                   subscriber.
*    (STRING_COLLECTION )   services      - List of services under a subscriber.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.NO_SERVICES_INSTALLED          -   No services are 
*                                                      available for this
*                                                      Subscriber.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.get_subscribed_services().
*   
******************************************************************************
*/
FUNCTION get_available_services ( ld                  IN   SESSION,
                                  subscriber_handle   IN   HANDLE,
                                  services            OUT  STRING_COLLECTION)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    check_user_subscription
*
*   DESCRIPTION
*     This function checks if a user is subscribed to a service.
*
*   SYNTAX
*   FUNCTION check_user_subscription
*   (
*
*   ld             IN  SESSION,
*   user_handle    IN  HANDLE,
*   service_handle IN  HANDLE
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*
*    (SESSION )         ld      - A valid ldap session handle.
*
*    (HANDLE )  user_handle     - A pointer to a handle to 
*                                                   user.
*    (HANDLE )  service_handle  - A pointer to a handle to 
*                                                   service.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.USER_NOT_SUBSCRIBED            -   User is not subscribed
*                                                      to the Service.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.subscribe_user(), DBMS_LDAP_UTL.unsubscribe_user().
*   
******************************************************************************
*/
FUNCTION check_user_subscription ( ld             IN SESSION,
                                   user_handle    IN HANDLE,
                                   service_handle IN HANDLE)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    subscribe_user
*
*   DESCRIPTION
*     This function subscribes a user to a service.
*
*   SYNTAX
*   FUNCTION subscribe_user
*   (
*
*   ld             IN  SESSION,
*   user_handle    IN  HANDLE,
*   service_handle IN  HANDLE
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*
*    (SESSION )         ld      - A valid ldap session handle.
*
*    (HANDLE )  user_handle     - A pointer to a handle to 
*                                                   user.
*    (HANDLE )  service_handle  - A pointer to a handle to 
*                                                   service.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.INVALID_SERVICE_SCHEMA         -   Unable to subscribe
*                                                      the user due to 
*                                                      invalid service schema
*                                                      in Subscriber Oracle
*                                                      Context.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.unsubscribe_user(), DBMS_LDAP_UTL.check_user_subscription().
*   
******************************************************************************
*/
FUNCTION subscribe_user ( ld             IN SESSION,
                          user_handle    IN HANDLE,
                          service_handle IN HANDLE)
         RETURN PLS_INTEGER;

/**
*******************************************************************************
*   NAME
*    unsubscribe_user
*
*   DESCRIPTION
*     This function unsubscribes a user from a service.
*
*   SYNTAX
*   FUNCTION unsubscribe_user
*   (
*
*   ld             IN  SESSION,
*   user_handle    IN  HANDLE,
*   service_handle IN  HANDLE
*
*   )
*   RETURN PLS_INTEGER;
*
*   REQUIRES
*
*   PARAMETERS
*
*    (SESSION )         ld      - A valid ldap session handle.
*
*    (HANDLE )  user_handle     - A pointer to a handle to 
*                                                   user.
*    (HANDLE )  service_handle  - A pointer to a handle to 
*                                                   service.
*
*   RETURNS
* 
*     DBMS_LDAP_UTL.SUCCESS                        -   On a successful completion.
*     DBMS_LDAP_UTL.PARAM_ERROR                    -   Invalid input parameters.
*     DBMS_LDAP_UTL.GENERAL_ERROR                  -    Other Error
*
*
*   USAGE 
*   N/A
*
*   EXAMPLES
*   
*   SEE 
*   DBMS_LDAP_UTL.subscribe_user().
*   
******************************************************************************
*/
FUNCTION unsubscribe_user ( ld             IN SESSION,
                            user_handle    IN HANDLE,
                            service_handle IN HANDLE)
         RETURN PLS_INTEGER;

    -- Error Code Constants

    -- Except for DBMS_LDAP_UTL.SUCCESS all error codes are negative, 
    -- (this is to distinguish them from DBMS_LDAP error codes)

    -- Successful completion
    SUCCESS                       CONSTANT NUMBER :=  0;
  
    -- Other error
    GENERAL_ERROR                 CONSTANT NUMBER := -1;

    -- Invalid input parameters.
    PARAM_ERROR                   CONSTANT NUMBER := -2;

    -- User doesn't have any group membership.
    NO_GROUP_MEMBERSHIP           CONSTANT NUMBER := -3;

    -- SUBSCRIBER doesn't exist.
    NO_SUCH_SUBSCRIBER            CONSTANT NUMBER := -4;

    -- User DN doesn't exist.
    NO_SUCH_USER                  CONSTANT NUMBER := -5;

    -- Root oracle context doesn't exist.
    NO_ROOT_ORCL_CTX        CONSTANT NUMBER := -6;
  
    -- More than one SUBSCRIBER entries
    MULTIPLE_SUBSCRIBER_ENTRIES   CONSTANT NUMBER := -7; 

    -- Root oracle context 
    -- either doesn't contain
    --   all the required attributes and entries 
    -- or 
    --   does not have valid attribute values.
    INVALID_ROOT_ORCL_CTX   CONSTANT NUMBER := -8;

    -- SUBSCRIBER's oracle context dosen't exist.
    NO_SUBSCRIBER_ORCL_CTX  CONSTANT NUMBER := -9;

    -- Subscriber's oracle context 
    -- either doesn't contain
    --   all the required attributes and entries 
    -- or 
    --   does not have valid attribute values.
    INVALID_SUBSCRIBER_ORCL_CTX   CONSTANT NUMBER := -10;

    -- More than one SUBSCRIBER entries
    MULTIPLE_USER_ENTRIES   CONSTANT NUMBER := -11; 

    -- GROUP does not exist.
    NO_SUCH_GROUP           CONSTANT NUMBER := -12;

    -- Multiple group entries.
    MULTIPLE_GROUP_ENTRIES  CONSTANT NUMBER := -13;

    -- Password Policy Error Codes
  
    AUTH_FAILURE_EXCEPTION            CONSTANT NUMBER := -16;

    -- Error Codes Returned by Server.
    ACCT_TOTALLY_LOCKED_EXCEPTION     CONSTANT NUMBER := 9001;
    PWD_EXPIRED_EXCEPTION             CONSTANT NUMBER := 9000;
    PWD_EXPIRE_WARN                   CONSTANT NUMBER := 9002;
    PWD_MINLENGTH_ERROR               CONSTANT NUMBER := 9003;
    PWD_NUMERIC_ERROR                 CONSTANT NUMBER := 9004;
    PWD_NULL_ERROR                    CONSTANT NUMBER := 9005;
    PWD_INHISTORY_ERROR               CONSTANT NUMBER := 9006;
    PWD_ILLEGALVALUE_ERROR            CONSTANT NUMBER := 9007;
    PWD_GRACELOGIN_WARN               CONSTANT NUMBER := 9008;
    PWD_MUSTCHANGE_ERROR              CONSTANT NUMBER := 9009;
    USER_ACCT_DISABLED_ERROR          CONSTANT NUMBER := 9050;

    -- Deprecated 
    AUTH_PASSWD_CHANGE_WARN           CONSTANT NUMBER := -15;

    RESET_HANDLE                      CONSTANT NUMBER := -18;
    SUBSCRIBER_NOT_FOUND              CONSTANT NUMBER := -19;

    USER_PROPERTY_NOT_FOUND           CONSTANT NUMBER := -28;
    PROPERTY_NOT_FOUND                CONSTANT NUMBER := -30;

    -- Errors Related to Service Entity
    NO_SUCH_SERVICE                CONSTANT NUMBER := -31;
    NO_USER_SUBSCRIPTIONS          CONSTANT NUMBER := -32;
    NO_SUBSCRIPTIONS_TO_SERVICES   CONSTANT NUMBER := -33;
    NO_SERVICES_INSTALLED          CONSTANT NUMBER := -34;
    USER_NOT_SUBSCRIBED            CONSTANT NUMBER := -35;
    INVALID_SERVICE_SCHEMA         CONSTANT NUMBER := -36;

    -- Cannot Allocate Memory
    ERR_MEM_ALLOC                  CONSTANT NUMBER := -37;

    -- Internal Error
    ERR_INTERNAL                   CONSTANT NUMBER := -38;


    -- Options for various input arguments to functions

    --  nested levels 

   NESTED_MEMBERSHIP         CONSTANT NUMBER := 0;
   DIRECT_MEMBERSHIP         CONSTANT NUMBER := 1;

    -- Type of User properties 

   ENTRY_PROPERTIES                CONSTANT NUMBER := 0;
   DETACHED_PROPERTIES             CONSTANT NUMBER := 1;
   COMMON_PROPERTIES               CONSTANT NUMBER := 2;
   NICKNAME_PROPERTY               CONSTANT NUMBER := 3;
   EXTPROPTYPE_RAD                 CONSTANT NUMBER := 4;
   DEFAULT_RAD_PROPERTIES          CONSTANT NUMBER := 5;
   IDENTIFICATION_PROPERTIES       CONSTANT NUMBER := 6;

   -- Modify 
   ADD_PROPERTY              CONSTANT NUMBER := 0;
   REPLACE_PROPERTY          CONSTANT NUMBER := 1;
   DELETE_PROPERTY           CONSTANT NUMBER := 2;

   ADD_PROPERTY_SET          CONSTANT NUMBER := 0;
   MODIFY_PROPERTY_SET       CONSTANT NUMBER := 1;
   DELETE_PROPERTY_SET       CONSTANT NUMBER := 2;

    --  Auth types 
   AUTH_SIMPLE               CONSTANT NUMBER := 0;
   AUTH_EXTENDED             CONSTANT NUMBER := 1;

    --  Hint types 
   TYPE_NICKNAME             CONSTANT NUMBER := 1;
   TYPE_GUID                 CONSTANT NUMBER := 2;
   TYPE_DN                   CONSTANT NUMBER := 3;
   TYPE_DEFAULT              CONSTANT NUMBER := 4;
   
    -- Handle Types

   SUBSCRIBER_HANDLE         CONSTANT NUMBER := 1;
   USER_HANDLE               CONSTANT NUMBER := 2;
   GROUP_HANDLE              CONSTANT NUMBER := 3;
   APP_HANDLE                CONSTANT NUMBER := 4;
   ORCLCTX_HANDLE            CONSTANT NUMBER := 5;
   SERVICE_HANDLE            CONSTANT NUMBER := 6;
    
END DBMS_LDAP_UTL;
/

--show errors
