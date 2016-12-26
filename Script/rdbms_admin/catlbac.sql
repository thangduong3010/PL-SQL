-- 
--  $Header: zlla.pkh 09-apr-2001.18:00:45 vpesati Exp $
-- 
--  zlla.pkh
-- 
--   Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlla.pkh 
-- 
--     DESCRIPTION
--       Label Based Access Control opaque datatype definitions -
--           LBAC_LABEL
--           LBAC_LABEL_LIST
--           LBAC_BIN_LABEL
--           LBAC_PRIVS
--           LBAC_COMPS      
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA     
-- 
--     MODIFIED   (MM/DD/YY)
--     vpesati     04/09/01 - fix bug 1718582 HP64 porting exception
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     04/02/01 - change for sys install
--     gmurphy     03/06/01 - don't replace or drop type libs
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/13/01 - change for upgrade script
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     vpesati     07/28/00 - remove bin label methods
--     cchui       04/25/00 - use oid clause to create opaque types
--     cchui       12/13/99 - change lbac_label map method
--     rburns      11/03/99 - cleanup PRAGMAS
--     vpesati     08/24/99 - new method on bin label
--     vpesati     08/21/99 - fix is_subset
--     cchui       08/20/99 - fix size for lbac_label
--     cchui       08/20/99 - add fix size for lbac_label
--     cchui       08/05/99 - add new_lbac_comps constructor
--     cchui       08/02/99 - modify lbac_label map function
--     cchui       07/30/99 - add method to retrieve lbac_label tag value
--     rburns      07/19/99 - add lbac_bin_label.eq method
--     cchui       07/16/99 - change lbac_label.eq to return PLS_INTEGER
--     cchui       07/14/99 - change lbac_label_list size to 39
--     rburns      07/13/99 - code to_label, etc in PL/SQL
--     vpesati     07/12/99 - add lbac_bin_label constructor
--     cchui       07/12/99 - add constructors for lbac datatypes
--     rburns      07/08/99 - change interfaces for lbac_label_list
--     rburns      07/07/99 - Add to_char_format
--     cchui       07/07/99 - add lbac_label_list
--     rburns      06/30/99 - Add LBAC_PRIVS functions
--     cchui       06/27/99 - Update lbac datatypes libraries
--     cchui       06/25/99 - Add new libraries for lbac datatypes
--     vpesati     06/03/99 - change protoypes
--     cchui       05/31/99 - Fix comilation error
--     rburns      04/21/99 - Re-org PL/SQL modules
--     cchui       03/03/99 - Create LBAC_LABEL type.
--     cchui       02/10/99 - Creation of LBAC interface specification.
--     cchui       02/10/99 - Created
-- 

-- Type libraries cannot be replaced or dropped when types are
-- being used in tables.  This causes the types to become badly
-- messed up.  So, for upgrade or re-usablilty we cannot "create
-- or replace".
CREATE LIBRARY LBACSYS.lbac$type_libt TRUSTED IS STATIC; 
/
CREATE LIBRARY LBACSYS.lbac$label_libt TRUSTED IS STATIC; 
/
CREATE LIBRARY LBACSYS.lbac$comps_libt TRUSTED IS STATIC; 
/
CREATE LIBRARY LBACSYS.lbac$privs_libt TRUSTED IS STATIC; 
/
CREATE LIBRARY LBACSYS.lbac$lablt_libt TRUSTED IS STATIC; 
/

-------------------------- lbac_label ----------------------------------------

CREATE OR REPLACE TYPE LBACSYS.lbac_label OID '6619848A7F882205E034000077904948' 
AS OPAQUE VARYING(3889)
USING LIBRARY LBACSYS.lbac$label_libt
(
--  The LBAC_LABEL type contains a 4 byte numeric representation of a binary
--  label.  It provides an index into the LBAC$LAB table to locate the
--  corresponding binary label.
--
--  The MAP member function returns the binary label in RAW form for
--  standard Oracle comparisons.  

-- BUG 1718582 requires the lbac_label size to be less than 3890 on
-- 64 bit platforms.
-- Due to other overheads in opaque type lbac_label size of 3890
-- works out to be 3897 on Solaris 32 bit platform
-- The code in kkbo.c is checking if the size > slal4d(3900) and this
-- results in a different behavior on 64 bit platforms. With 8 byte
-- alignment slal4d(3900) works out to 3896 resulting in column being
-- stored in a LOB thus causing this bug. Using 3889 works on HP 64 bit
-- platform

-- Constructor
   STATIC FUNCTION new_lbac_label(num IN PLS_INTEGER)
   RETURN lbac_label,
   PRAGMA RESTRICT_REFERENCES(new_lbac_label, RNDS, WNDS, RNPS, WNPS),

-- Map method
   MAP MEMBER FUNCTION lbac_label_map
   RETURN PLS_INTEGER DETERMINISTIC,
    
-- For lookup in lbac$lab
   MEMBER FUNCTION eq_sql (SELF IN lbac_label,
                           comp_label IN lbac_label)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION eq (SELF IN lbac_label,
                       comp_label IN lbac_label)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS),

-- Converts label to integer tag
   MEMBER FUNCTION to_tag(SELF IN lbac_label)
   RETURN PLS_INTEGER DETERMINISTIC,
   PRAGMA RESTRICT_REFERENCES(to_tag, RNDS, WNDS, RNPS, WNPS)

);
/
show errors
-------------------------- lbac_bin_label ------------------------------------

CREATE OR REPLACE TYPE LBACSYS.lbac_bin_label OID '6619848A7F9C2205E034000077904948'
AS OPAQUE VARYING(*)
USING LIBRARY LBACSYS.lbac$type_libt
(
--  The LBAC_BIN_LABEL type contains the binary label, as well as a label
--  size and an identifier for the associated policy.  The interpretation
--  of the label is made by each policy package.  As for the LBAC_LABEL
--  type, the RAW binary value is used for standard comparisons.
--
--  The type methods include functions to extract portions of the label, 
--  functions to manipulate the bits within the label, and functions to 
--  test the bit settings.

-- Constructor  
  STATIC FUNCTION new_lbac_bin_label (policy_id IN PLS_INTEGER,
                                      bin_size IN PLS_INTEGER)
  RETURN LBAC_BIN_LABEL,
  PRAGMA RESTRICT_REFERENCES(new_lbac_bin_label, RNDS, WNDS, RNPS, WNPS),

-- Equality tests for lookup in lbac$lab
  MEMBER FUNCTION eq_sql (SELF IN lbac_bin_label,
                          comp_label IN lbac_bin_label)
  RETURN PLS_INTEGER DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),

  MEMBER FUNCTION eq (SELF IN lbac_bin_label,
                       comp_label IN lbac_bin_label)
  RETURN BOOLEAN DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS),

-- Size of binary_label portion 
  MEMBER FUNCTION bin_size (SELF IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(bin_size, RNDS, WNDS, RNPS, WNPS),

-- Procedures and Functions to store values into the binary label

  MEMBER FUNCTION set_raw (SELF      IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            raw_label IN RAW)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_raw, RNDS, WNDS, RNPS, WNPS),
  
  MEMBER FUNCTION set_int (SELF IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            int_label IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_int, RNDS, WNDS, RNPS, WNPS),

  
-- Functions to test the contents on the binary label

-- Functions to extract the contents of the binary label
  
  MEMBER FUNCTION  to_raw (SELF     IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN RAW,
  PRAGMA RESTRICT_REFERENCES(to_raw, RNDS, WNDS, RNPS, WNPS),

  MEMBER FUNCTION to_int (SELF     IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(to_int, RNDS, WNDS, RNPS, WNPS),

  MEMBER FUNCTION policy_id (SELF   IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)
);
/
show errors

-------------------------- lbac_privs ----------------------------------------

CREATE OR REPLACE TYPE LBACSYS.lbac_privs OID '6619848A7FDF2205E034000077904948'
AS OPAQUE FIXED(9)
USING LIBRARY LBACSYS.lbac$privs_libt
(
-- The LBAC_PRIVS type contains the bit string representation of policy
-- package privileges (32 bits).  The functions provide setting, clearing,
-- and testing of specific privileges based on their numeric value.
-- Union and diff functions are also provided to operate on two sets 
-- of privileges. 

-- Constructor
   STATIC FUNCTION new_lbac_privs(policy_id IN PLS_INTEGER)
   RETURN lbac_privs,
   PRAGMA RESTRICT_REFERENCES(new_lbac_privs, RNDS, WNDS, RNPS, WNPS),

-- Procedures to set contents
   MEMBER PROCEDURE clear_priv(SELF IN OUT NOCOPY lbac_privs, 
                               priv_number IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(clear_priv, RNDS, WNDS, RNPS, WNPS),
 
   MEMBER PROCEDURE set_priv(SELF IN OUT NOCOPY lbac_privs, 
                             priv_number IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(set_priv, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE union_privs(SELF IN OUT NOCOPY lbac_privs, 
                                other_privs IN lbac_privs), 
   PRAGMA RESTRICT_REFERENCES(union_privs, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE diff_privs(SELF IN OUT NOCOPY lbac_privs,
                                other_privs IN lbac_privs),
   PRAGMA RESTRICT_REFERENCES(diff_privs, RNDS, WNDS, RNPS, WNPS),                                
-- Functions to test contents
   MEMBER FUNCTION test_priv(SELF IN lbac_privs, 
                             priv_number IN PLS_INTEGER) 
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_priv, RNDS, WNDS, RNPS, WNPS),
  
   MEMBER FUNCTION none(SELF IN lbac_privs)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(none, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION policy_id(SELF IN lbac_privs)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)

);
/
show errors

--------------------------- lbac_comps ------------------------------------

CREATE OR REPLACE TYPE LBACSYS.lbac_comps
OID '6619848A7FFB2205E034000077904948'
AS OPAQUE FIXED(5)
USING LIBRARY LBACSYS.lbac$comps_libt 

-- This opaque type is used with the label comparison cache when a policy
-- package has non-comparable labels (e.g., the MLS policy).  The standard
-- Oracle sort order is based on comparing the RAW binary values.  A policy
-- package may use the LBAC_COMPS type and label comparison cache to store 
-- and use a different comparison, 

(

-- Constructor
   STATIC FUNCTION new_lbac_comps
   RETURN lbac_comps,
   PRAGMA RESTRICT_REFERENCES(new_lbac_comps, RNDS, WNDS, RNPS, WNPS),

-- Procedures to set the contents
   MEMBER PROCEDURE set_gt(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_gt, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE set_eq(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_eq, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE set_lt(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_lt, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE set_sortgt(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_gt, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE set_sorteq(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_eq, RNDS, WNDS, RNPS, WNPS),

   MEMBER PROCEDURE set_sortlt(SELF IN OUT NOCOPY lbac_comps),
   PRAGMA RESTRICT_REFERENCES(set_lt, RNDS, WNDS, RNPS, WNPS),

-- Functions to test the contents
   MEMBER FUNCTION test_lt(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_lt, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION test_le(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_le, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION test_eq(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_eq, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION test_ne(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_ne, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION test_ge(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_ge, RNDS, WNDS, RNPS, WNPS),
 
   MEMBER FUNCTION test_gt(SELF IN lbac_comps)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(test_gt, RNDS, WNDS, RNPS, WNPS)


);
/
show errors

CREATE OR REPLACE TYPE LBACSYS.lbac_label_list
OID '6619848A801E2205E034000077904948'
AS OPAQUE FIXED(39)
USING LIBRARY LBACSYS.lbac$lablt_libt

-- The lbac_label_list type contains up to six lbac_labels.  It is
-- used to store the labels associated with a database, a user, 
-- a program unit, or a session.  

(
-- Constructor
   STATIC FUNCTION new_lbac_label_list(policy_id IN PLS_INTEGER)
   RETURN lbac_label_list,
   PRAGMA RESTRICT_REFERENCES(new_lbac_label_list, RNDS, WNDS, RNPS, WNPS),

-- Store a label
   MEMBER PROCEDURE put(SELF IN OUT lbac_label_list,
                             label IN lbac_label, pos IN PLS_INTEGER),
   PRAGMA RESTRICT_REFERENCES(put, RNDS, WNDS, RNPS, WNPS),

-- Functions to retrieve the contents of the list

   MEMBER FUNCTION get(SELF IN lbac_label_list, pos IN PLS_INTEGER)
   RETURN lbac_label,
   PRAGMA RESTRICT_REFERENCES(get, RNDS, WNDS, RNPS, WNPS),

   MEMBER FUNCTION count(SELF IN lbac_label_list)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(count, RNDS, WNDS, RNPS, WNPS),
   
   MEMBER FUNCTION policy_id(SELF IN lbac_label_list)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)

);
/
show errors

--  VARRAY specifications

CREATE OR REPLACE TYPE LBACSYS.lbac_name_list
IS VARRAY(32) OF VARCHAR2(30);
/

--
-- $Header: rdbms/src/server/security/ols/lbac/zllc.pkh /main/13 2010/03/03 16:26:48 skwak Exp $
--
-- zllc.pkh
--
-- Copyright (c) 2007, 2010, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      zllc.pkh - ZL Cache PacKage Header
--
--    DESCRIPTION
--      This file contains the specifications for the procedures to 
--      handle the LBAC label comparison cache and label conversion cache
--
--    NOTES
--       Run as LBACSYS 
--
--    MODIFIED   (MM/DD/YY)
--    skwak       02/22/10 - add max_ses_policy_id
--    srtata      06/20/07 - add check_cache_initialized
--    snadhika    03/28/07 - remove set_data_accessed and data_accessed 
--    cchui       05/03/04 - Add get_unique_id, and is_rac_enabled 
--    srtata      06/04/03 - add check_policysubscribed
--    srtata      01/30/03 - add check_sessioncontext
--    shwong      01/15/03 - add check_policyadmin
--    shwong      11/22/02 - rename policy to policy_name
--    shwong      11/21/02 - new prototypes for oid_subscribe/oid_unsubscribe
--    shwong      11/07/02 - add subscribe/unsubscribe routines for OID
--    srtata      10/10/02 - add functions for dip flag
--    srtata      10/09/02 - add oid_enabled
--    srtata      07/09/02 - add insert_label_internal
--    vpesati     04/05/01 - remove unused functions
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    vpesati     10/18/00 - change cache_tags
--    vpesati     10/12/00 - add caching functions
--    vpesati     09/21/00 - inverse group changes
--    vpesati     08/15/00 - add function for column type
--    rsripada    07/11/00 - remove compute_labelflags
--    cchui       05/03/00 - add new option_string function to return HIDE opti
--    cchui       05/01/00 - change create context statement
--    vpesati     04/28/00 - add insert label to lbac_cache
--    vpesati     04/10/00 - add set data access function
--    rsripada    03/20/00 - add audit-action parameter in check_role
--    rsripada    02/11/00 - remove to_order function
--    vpesati     02/07/00 - cleanup
--    cchui       02/01/00 - add bypass function
--    rsripada    01/13/00 - add comments
--    cchui       01/10/00 - add option_string function
--    cchui       12/13/99 - add lbac_compare.to_order
--    cchui       12/10/99 - add functions to set/unset alter_table bit
--    rsripada    12/07/99 - Add check_policyrole function
--    rsripada    12/02/99 - Add computeflag
--    cchui       11/30/99 - add bypass_read, bypass_all to store_sesison_initi
--    rsripada    11/30/99 - add option_number function
--    rsripada    11/15/99 - add policyexists function to lbac_cache
--    rburns      11/03/99 - cleanup PRAGMAS
--    vpesati     10/25/99 - drop column check
--    rburns      09/24/99 - make populate_temp_tabel autonomous
--    cchui       09/22/99 - add data_accessed function
--    cchui       09/16/99 - add function to populate tmp tables
--    vpesati     09/09/99 - overload failedstartup
--    vpesati     09/08/99 - add new functions
--    vpesati     09/07/99 - add functions to get cache info
--    cchui       09/02/99 - remove cache size from initialize_cache
--    rburns      08/08/99 - Cache implementation
--    rburns      08/07/99 - Created

------------------------------ lbac_cache --------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_cache IS
--
--  Store caches via C, but access them using PL/SQL
--
PROCEDURE initialize_cache;
PRAGMA RESTRICT_REFERENCES (initialize_cache, RNDS, WNDS);

PROCEDURE store_labels (label     IN lbac_label, 
                        bin_label IN lbac_bin_label);
PRAGMA RESTRICT_REFERENCES (store_labels, RNDS, WNDS);

FUNCTION find_bin_label(label IN lbac_label)
RETURN lbac_bin_label;
PRAGMA RESTRICT_REFERENCES(find_bin_label, WNPS, RNDS, WNDS);

FUNCTION find_label(bin_label IN lbac_bin_label)
RETURN lbac_label;
PRAGMA RESTRICT_REFERENCES(find_label, WNPS, RNDS, WNDS);

PROCEDURE store_comps(comps  IN lbac_comps, 
                      label1 IN lbac_label, 
                      label2 IN lbac_label);
PRAGMA RESTRICT_REFERENCES (store_comps, RNDS, WNDS);

FUNCTION find_comps(label1 IN lbac_label,
                    label2 IN lbac_label)
RETURN lbac_comps;
PRAGMA RESTRICT_REFERENCES(find_label, WNPS, RNDS, WNDS);


   PROCEDURE insert_label(label      IN lbac_label,
                          pol_number IN PLS_INTEGER,
                          num_label  IN PLS_INTEGER,
                          bin_label  IN lbac_bin_label,
                          str_label  IN VARCHAR2,
                          ilabel     IN VARCHAR2,
                          flags      IN PLS_INTEGER);

   PROCEDURE store_session_info(user_name IN VARCHAR2);

   PROCEDURE store_session_initial_info(policy_name IN VARCHAR2,
                         session_initial_labels IN lbac_label_list,
                         session_initial_privs IN lbac_privs,
                         session_bypass IN PLS_INTEGER);
                   
   PROCEDURE store_effective_initial_labels(
                         policy_name              IN VARCHAR2,
                         effective_initial_labels IN lbac_label_list,
                         effective_initial_bypass IN PLS_INTEGER);

   PROCEDURE store_effective_labels(
                         policy_name      IN VARCHAR2,
                         effective_labels IN lbac_label_list,
                         effective_bypass IN PLS_INTEGER);
   
   PROCEDURE store_database_labels(
                         policy_name      IN VARCHAR2,
                         database_labels  IN lbac_label_list);   
 
   PROCEDURE store_effective_privs(
                         policy_name     IN VARCHAR2,
                         effective_privs IN lbac_privs,
                         effective_bypass IN PLS_INTEGER);
  
   PROCEDURE store_default_format(
                         policy_name    IN VARCHAR2,
                         default_format IN VARCHAR2);

   PROCEDURE store_default_options(
                         policy_name     IN VARCHAR2,
                         default_options IN PLS_INTEGER);

FUNCTION pol_number (policy_name IN VARCHAR2)
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(pol_number, WNPS, RNDS, WNDS);

FUNCTION column_name (policy_name IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(column_name, WNPS, RNDS, WNDS);

FUNCTION package(policy_name IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(column_name, WNPS, RNDS, WNDS);

FUNCTION bin_size (policy_name IN VARCHAR2)
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(bin_size, WNPS, RNDS, WNDS);

FUNCTION failedstartup (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(failedstartup, WNPS, RNDS, WNDS);

FUNCTION failedstartup (policy_id IN PLS_INTEGER)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(failedstartup, WNPS, RNDS, WNDS);

FUNCTION policy_format (policy_name IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(policy_format, WNPS, RNDS, WNDS);

FUNCTION db_format (policy_name IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(db_format, WNPS, RNDS, WNDS);

FUNCTION max_ses_policy_id 
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(max_ses_policy_id, WNPS, RNDS, WNDS);

FUNCTION max_policies
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(max_policies, WNPS, RNDS, WNDS);

FUNCTION policy_name (policy_id IN PLS_INTEGER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(policy_name, WNPS, RNDS, WNDS);

FUNCTION policyexists (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(policyexists, WNPS, RNDS, WNDS);

FUNCTION drop_column
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(drop_column, WNPS, RNDS, WNDS);

FUNCTION column_type
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(column_type, WNPS, RNDS, WNDS);

FUNCTION bypassread(policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(bypassread, WNPS, RNDS, WNDS);

FUNCTION bypassall(policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(bypassall, WNPS, RNDS, WNDS);

FUNCTION bypass(policy_name IN VARCHAR2)
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(bypass, WNPS, RNDS, WNDS);

FUNCTION option_number (options IN VARCHAR2)
RETURN PLS_INTEGER;
PRAGMA RESTRICT_REFERENCES(option_number, WNPS, RNDS, WNDS);

FUNCTION option_string (options IN PLS_INTEGER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(option_string, WNPS, RNDS, WNDS);

FUNCTION option_string_imp(options IN PLS_INTEGER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(option_string_imp, WNPS, RNDS, WNDS);

FUNCTION inverse_group (pol_number IN PLS_INTEGER)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(inverse_group, WNPS, RNDS, WNDS);

FUNCTION oid_enabled
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(oid_enabled, WNPS, RNDS, WNDS);

FUNCTION check_cache_initialized
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(check_cache_initialized, WNPS, RNDS, WNDS);

PROCEDURE set_dip_flag(dip_flag IN PLS_INTEGER);
PRAGMA RESTRICT_REFERENCES (set_dip_flag, RNDS, WNDS);

FUNCTION is_dip_set
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(is_dip_set, WNPS, RNDS, WNDS);

-- This function raises an error if a NULL policy name or
-- non-existent policy name is passed. Otherwise, it returns TRUE
-- if the user has the policy role.
FUNCTION check_policyrole (policy_name IN VARCHAR2,
                           audit_action IN PLS_INTEGER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(check_policyrole, WNPS, RNDS, WNDS);

PROCEDURE set_alter_allow(allow IN INTEGER);

PROCEDURE build_context(pol_number IN PLS_INTEGER,
                        package_name IN VARCHAR2,
                        session_bypass IN PLS_INTEGER);

PROCEDURE cache_tags(type IN PLS_INTEGER);

PROCEDURE oid_subscribe(policy_name IN VARCHAR2);

PROCEDURE oid_unsubscribe(policy_name IN VARCHAR2);

FUNCTION check_policyadmin(policy_name IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION check_policysubscribed(policy_name IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION check_sessioncontext
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(check_sessioncontext, WNPS, RNDS, WNDS);

FUNCTION get_unique_id
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_unique_id, WNPS, RNDS, WNDS);

FUNCTION is_rac_enabled
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(is_rac_enabled, WNPS, RNDS, WNDS);

FUNCTION is_failover
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(is_failover, WNPS, RNDS, WNDS);

PROCEDURE reset_failover;

END lbac_cache;
/
show errors

-- Create context for alter allow bit
CREATE OR REPLACE CONTEXT lbac_ctx
USING LBACSYS.lbac_cache;

-- Create context for lbac labels
CREATE OR REPLACE CONTEXT lbac$labels
USING LBACSYS.lbac_cache;

------------------------------lbac_compare --------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_compare IS
--
-- Uses label comparison cache, not MAP function, for comparisons.
-- Provides INTEGER returns for SQL and BOOLEAN returns for PL/SQL.

FUNCTION lt (l1 IN lbac_label, l2 IN lbac_label)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(lt, RNPS, WNPS, WNDS);

FUNCTION lt_sql (l1 IN lbac_label, l2 IN lbac_label)
RETURN INTEGER;
--PRAGMA RESTRICT_REFERENCES(lt_sql, RNPS, WNPS, WNDS);

FUNCTION le (l1 IN lbac_label, l2 IN lbac_label)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(le, RNPS, WNPS, WNDS);

FUNCTION le_sql (l1 IN lbac_label, l2 IN lbac_label)
RETURN INTEGER;
--PRAGMA RESTRICT_REFERENCES(le_sql, RNPS, WNPS, WNDS);

FUNCTION ge (l1 IN lbac_label, l2 IN lbac_label)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ge, RNPS, WNPS, WNDS);

FUNCTION ge_sql (l1 IN lbac_label, l2 IN lbac_label)
RETURN INTEGER;
--PRAGMA RESTRICT_REFERENCES(ge_sql, RNPS, WNPS, WNDS);

FUNCTION gt (l1 IN lbac_label, l2 IN lbac_label)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(gt, RNPS, WNPS, WNDS);

FUNCTION gt_sql (l1 IN lbac_label, l2 IN lbac_label)
RETURN INTEGER;
--PRAGMA RESTRICT_REFERENCES(gt_sql, RNPS, WNPS, WNDS);

FUNCTION to_bin_label (label IN lbac_label)
RETURN lbac_bin_label;

END lbac_compare;
/
show errors
--
-- $Header: rdbms/src/server/security/ols/lbac/zlle.pkh /main/6 2009/06/26 15:08:29 skwak Exp $
--
-- zlle.pkh
--
-- Copyright (c) 1999, 2009, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      zlle.pkh - ZL Events PacKage Header
--
--    DESCRIPTION
--      This file contains the specifications for the procedures to 
--      handle the LBAC database events.
--
--    NOTES
--       Run as LBACSYS 
--
--    MODIFIED   (MM/DD/YY)
--    skwak       06/23/09 - lrg3915855: remove schema, program name from parameter
--                           list of prog_termination    
--    skwak       03/05/09 - 8199050: use NUMBER for table_objno in 
--                           check_lob_policyauth
--    cchui       03/28/05 - 4257038: use UROWID for check_lob_policyauth 
--    srtata      04/26/02 - remove startup trigger
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    rsripada    12/29/00 - add check_lob_policyauth
--    vpesati     10/25/99 - add before_alter
--    rburns      09/09/99 - more cleanup - remove PL/SQL tables
--    vpesati     09/07/99 - cleanup
--    rsripada    08/26/99 - add store_database_labels
--    vpesati     08/26/99 - initialize pol_cnt
--    rburns      08/02/99 - restore lbac_compare
--    rburns      07/28/99 - add procedure invocation
--    rburns      07/28/99 - add lbac_compare pakage
--    cchui       07/14/99 -
--    rburns      07/14/99 - add policy format
--    rburns      07/14/99 - work around PL/SQL record problem
--    cchui       07/13/99 - add session info API
--    rburns      07/09/99 - create global structures
--    rburns      05/10/99 - Rename PL/SQL packages
--    rburns      05/07/99 - Renamed and added parameters.
--    cchui       03/03/99 - Add DDL events handling.
--    cchui       02/16/99 - Create LBAC_EVENT package.
--    cchui       02/16/99 - Created
--
------------------------------------lbac_events ------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_events AS

--  This package contains the procedures that implement the LBAC database 
--  events.

   PROCEDURE servererror(error_number IN PLS_INTEGER);
   
   PROCEDURE logon(user_name IN VARCHAR2);
   
   PROCEDURE logoff;
   
   PROCEDURE after_create(object_type IN VARCHAR2, 
                          object_name IN VARCHAR2, 
                          schema_name IN VARCHAR2);
                          
   PROCEDURE after_drop(object_type  IN VARCHAR2,
                        object_name  IN VARCHAR2,
                        schema_name  IN VARCHAR2);

   PROCEDURE before_alter (object_type IN VARCHAR2,
                           object_name IN VARCHAR2,
                           schema_name IN VARCHAR2);
                           
   PROCEDURE before_ddl(sql_command  IN VARCHAR2,
                        object_type  IN VARCHAR2,
                        object_name  IN VARCHAR2,
                        schema_name  IN VARCHAR2);
                           
   PROCEDURE prog_invocation (schema_name IN VARCHAR2,
                              prog_name   IN VARCHAR2,
                              trusted     IN BOOLEAN);

   PROCEDURE prog_termination (trusted     IN BOOLEAN);

   PROCEDURE check_lob_policyauth(table_objno IN NUMBER,
                                  rid IN UROWID);
   
   
END lbac_events;
/
show errors
-- $Header: rdbms/src/server/security/ols/lbac/zllu.pkh /st_rdbms_11.2.0/1 2011/06/24 13:29:44 jkati Exp $
--
-- zllu.pkh
--
-- Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      zllu.pkh - ZL LBAC User PacKage Headers.
--
--    DESCRIPTION   
--      PL/SQL specifications for LBAC_SYSDBA, LBAC_POLICY_ADMIN,
--      LBAC_USER_ADMIN, LBAC_AUDIT_ADMIN, LBAC_SESSION, and LBAC_SERVICES.
--
--    NOTES
--      Run as LBACSYS.
--
--    MODIFIED   (MM/DD/YY)
--    jkati       06/17/11 - declare system_info_exp function in lbac_utl
--    srtata      09/09/08 - remove validate in lbac_utl
--    srtata      06/06/03 - add functions for OID subscribing
--    shwong      11/30/01 - add lbac_utl.validate()
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    vpesati     10/31/00 - prototype fixes
--    rsripada    10/24/00 - add pragma to nls_substrb
--    rsripada    10/10/00 - add nls_validname
--    rsripada    10/09/00 - add view_name param to create_view
--    rsripada    09/28/00 - add function to return policy column datatype
--    vpesati     09/15/00 - TSP changes
--    vpesati     08/15/00 - remove apply database policy
--    rsripada    08/10/00 - rename audit_admin procs
--    rsripada    08/08/00 - add nls_substrb
--    rsripada    08/01/00 - add procs in lbac_audit_admin
--    rsripada    07/27/00 - remove user_label from lbac_utl
--    rsripada    07/21/00 - change order of params in audit/noaudit procs
--    rsripada    07/20/00 - add set_user_labels_internal
--    rsripada    07/16/00 - add label_tagseq
--    rsripada    07/10/00 - changes to USER/DATA label functionality
--    shwong      04/14/00 - add alter_label_sql
--    rsripada    03/24/00 - overload alter_label, drop_label
--    rsripada    03/22/00 - changes to label_admin package
--    cchui       03/20/00 - add set_effective function
--    rsripada    03/13/00 - default some parameters in audit/noaudit procedure
--    rsripada    02/15/00 - change from lbac_audit to lbac_audit_admin
--    rsripada    02/11/00 - add support for user-defined tags for label defini
--    cchui       02/01/00 - add lbac_session bypass functions
--    rsripada    01/27/00 - remove sys_label functions in lbac_utl
--    rsripada    01/21/00 - change label_exists definition
--    vpesati     01/20/00 - implement alter schema policy
--    cchui       01/19/00 - add set_effective_privs
--    rsripada    01/17/00 - add label_exists to lbac_utl
--    cchui       01/11/00 - remove appsch and apptab
--    cchui       01/04/00 - add to_order function to lbac_utl
--    vpesati     01/04/00 - add disable_table_policy
--    rsripada    01/04/00 - move label methods to lbac_utl
--    vpesati     12/17/99 - remove enable from interface
--    cchui       12/15/99 - split lbac_admin package
--    rsripada    12/13/99 - Add createviews and dropviews procedures
--    vpesati     12/14/99 - change interfaces
--    cchui       12/09/99 - modify admin functions
--    vpesati     12/08/99 - change remove table policy interface
--    rsripada    12/03/99 - Add new procedures
--    vpesati     12/02/99 - change apply table policy interface
--    rsripada    12/01/99 - Define LBAC_LABEL_ADMIN package
--    rsripada    11/30/99 - Change alter policy
--    vpesati     11/25/99 - change create policy
--    cchui       11/29/99 - add lbac_utl package
--    rburns      11/03/99 - cleanup PRAGMAS
--    vpesati     09/07/99 - remove session functions
--    rsripada    08/20/99 - change interface to audit_privilege
--    rsripada    08/15/99 - add audit_action
--    shwong      08/13/99 - return boolean for policy_enable
--    shwong      08/12/99 - add more lbac_session functions
--    vpesati     08/11/99 - fix column_name
--    shwong      08/10/99 - add lbac_session functions to access policy info
--    rburns      07/18/99 - fix to_label
--    rburns      07/15/99 - fix bugs
--    cchui       07/15/99 - add user_privileges and user_labels functions
--    rburns      07/14/99 - work around PL/SQL record problem
--    rburns      07/13/99 - change interfaces for use by policy packages
--    rburns      07/05/99 - Wrap procedures/functions with default vlaues
--    rburns      06/29/99 - Add db labels to lbac_session
--    rburns      06/04/99 - Revise for new spec
--    rburns      05/28/99 - Rename
--    rburns      05/03/99 - Created
--

------------------------------ lbac_sysdba -----------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_sysdba AS
--
-- This package is used by an administrator, connected AS SYSDBA,
-- to create and maintain LBAC policies in a database.
--

PROCEDURE create_policy (policy_name IN VARCHAR2,
                         package     IN VARCHAR2,
                         column_name IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_policy (policy_name     IN VARCHAR2,
                        default_options IN VARCHAR2 DEFAULT NULL,
                        default_format  IN VARCHAR2 DEFAULT NULL,
                        database_labels IN LBAC_LABEL_LIST DEFAULT NULL);

PROCEDURE drop_policy (policy_name IN VARCHAR2,
                       drop_column IN BOOLEAN DEFAULT FALSE);

PROCEDURE enable_policy (policy_name IN VARCHAR2);

PROCEDURE disable_policy (policy_name IN VARCHAR2);

END lbac_sysdba;
/
show errors

---------------------------- lbac_policy_admin ------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_policy_admin AS

--  This package is used to apply policies to tables and schemas and
--  to maintain the labels and privleges associated with users and 
--  stored program units.

--  Administrative users must be granted EXECUTE privilege on this package.

PROCEDURE apply_schema_policy (policy_name IN VARCHAR2,
                               schema_name IN VARCHAR2,
                               default_options IN VARCHAR2 DEFAULT NULL);

PROCEDURE remove_schema_policy (policy_name IN VARCHAR2,
                                schema_name IN VARCHAR2,
                                drop_column IN BOOLEAN DEFAULT FALSE);

PROCEDURE enable_schema_policy (policy_name IN VARCHAR2,
                                schema_name IN VARCHAR2);

PROCEDURE alter_schema_policy (policy_name     IN VARCHAR2,
                               schema_name     IN VARCHAR2,
                               default_options IN VARCHAR2);

PROCEDURE apply_table_policy (policy_name IN VARCHAR2,
                              schema_name IN VARCHAR2,
                              table_name  IN VARCHAR2,
                              table_options IN VARCHAR2 DEFAULT NULL,
                              label_function IN VARCHAR2 DEFAULT NULL,
                              predicate IN VARCHAR2 DEFAULT NULL);
                              
PROCEDURE remove_table_policy (policy_name IN VARCHAR2,
                               schema_name IN VARCHAR2,
                               table_name  IN VARCHAR2,
                               drop_column IN BOOLEAN DEFAULT FALSE);

PROCEDURE policy_subscribe(policy_name IN VARCHAR2);

PROCEDURE policy_unsubscribe(policy_name IN VARCHAR2);

PROCEDURE enable_table_policy (policy_name IN VARCHAR2,
                               schema_name IN VARCHAR2,
                               table_name  IN VARCHAR2);
                               
PROCEDURE disable_table_policy (policy_name IN VARCHAR2,
                                schema_name IN VARCHAR2,
                                table_name  IN VARCHAR2);

PROCEDURE disable_schema_policy (policy_name IN VARCHAR2,
                                 schema_name IN VARCHAR2);

FUNCTION priv_names (policy_name IN VARCHAR2)
RETURN lbac_name_list;

FUNCTION label_names (policy_name IN VARCHAR2,
                      label_type  IN PLS_INTEGER)
RETURN lbac_name_list;

END lbac_policy_admin;
/
show error

---------------------------- lbac_user_admin ------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_user_admin AS

PROCEDURE set_user_labels (policy_name IN VARCHAR2,
                           user_name   IN VARCHAR2,
                           user_labels IN lbac_label_list);

PROCEDURE set_user_privs   (policy_name IN VARCHAR2,
                            user_name   IN VARCHAR2,
                            privileges  IN VARCHAR2);

PROCEDURE grant_user_privs (policy_name IN VARCHAR2,
                            user_name   IN VARCHAR2,
                            privileges  IN VARCHAR2);

PROCEDURE revoke_user_privs (policy_name IN VARCHAR2,
                             user_name   IN VARCHAR2,
                             privileges  IN VARCHAR2);

PROCEDURE set_prog_privs   (policy_name IN VARCHAR2,
                            schema_name IN VARCHAR2,
                            prog_name   IN VARCHAR2,
                            privileges  IN VARCHAR2);

PROCEDURE grant_prog_privs (policy_name IN VARCHAR2,
                            schema_name IN VARCHAR2,
                            prog_name   IN VARCHAR2,
                            privileges  IN VARCHAR2);

PROCEDURE revoke_prog_privs (policy_name IN VARCHAR2,
                             schema_name IN VARCHAR2,
                             prog_name   IN VARCHAR2,
                             privileges  IN VARCHAR2);

-- internal function
PROCEDURE set_user_labels_internal (policy_name IN VARCHAR2,
                           user_name   IN VARCHAR2,
                           user_labels IN lbac_label_list);

END lbac_user_admin;
/
show errors

------------------------------ lbac_audit_admin -------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_audit_admin AS
--
--  This package allows an administrative user to establish auditing of
--  administrative actions, the use of privileges, and potential "covert
--  channels" in the enforcement of unique keys and referential integrity

PROCEDURE audit (policy_name  IN VARCHAR2,
                 users        IN VARCHAR2 DEFAULT NULL,
                 audit_option IN VARCHAR2 DEFAULT NULL,
                 audit_type   IN VARCHAR2 DEFAULT NULL,
                 success      IN VARCHAR2 DEFAULT NULL);

PROCEDURE noaudit (policy_name  IN VARCHAR2,
                   users        IN VARCHAR2 DEFAULT NULL,
                   audit_option IN VARCHAR2 DEFAULT NULL);

PROCEDURE noaudit_label(policy_name IN VARCHAR2);

PROCEDURE audit_label(policy_name IN VARCHAR2);

FUNCTION audit_label_enabled(policy_name IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION audit_label_enabled_sql(policy_name IN VARCHAR2)
RETURN PLS_INTEGER;

PROCEDURE create_view(policy_name IN VARCHAR2,
                      view_name   IN VARCHAR2 DEFAULT NULL);

PROCEDURE drop_view(policy_name IN VARCHAR2,
                    view_name   IN VARCHAR2 DEFAULT NULL);
                            
END lbac_audit_admin;
/
show errors

------------------------------ lbac_session ----------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_session AS
--
--  This package provides information about the session's security attributes
--  and supports changes to the session labels if allowed by the policy
--  package.

FUNCTION policy_enable (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(policy_enable, WNPS, RNDS, WNDS);

FUNCTION label_format (policy_name IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(label_format, WNPS, RNDS, WNDS);

FUNCTION user_privileges (policy_name IN VARCHAR2)
RETURN lbac_privs;
PRAGMA RESTRICT_REFERENCES(user_privileges, WNPS, RNDS, WNDS);

FUNCTION user_labels (policy_name IN VARCHAR2)
RETURN lbac_label_list;
PRAGMA RESTRICT_REFERENCES(user_labels, WNPS, RNDS, WNDS);

FUNCTION session_initial_privileges (policy_name IN VARCHAR2)
RETURN lbac_privs;
PRAGMA RESTRICT_REFERENCES(session_initial_privileges, WNPS, RNDS, WNDS);

FUNCTION session_initial_labels (policy_name IN VARCHAR2)
RETURN lbac_label_list;
PRAGMA RESTRICT_REFERENCES(session_initial_labels, WNPS, RNDS,  WNDS);

FUNCTION effective_privileges (policy_name IN VARCHAR2)
RETURN lbac_privs;
PRAGMA RESTRICT_REFERENCES(effective_privileges, WNPS, RNDS,  WNDS);

FUNCTION effective_initial_labels (policy_name IN VARCHAR2)
RETURN lbac_label_list;
PRAGMA RESTRICT_REFERENCES(effective_initial_labels, WNPS, RNDS, WNDS);

FUNCTION effective_labels (policy_name IN VARCHAR2)
RETURN lbac_label_list;
PRAGMA RESTRICT_REFERENCES(effective_labels, WNPS, RNDS,  WNDS);

FUNCTION database_labels (policy_name IN VARCHAR2)
RETURN lbac_label_list;
PRAGMA RESTRICT_REFERENCES(database_labels, WNPS, RNDS,  WNDS);

FUNCTION policy_disabled (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(policy_disabled, WNPS, RNDS,  WNDS);

PROCEDURE set_label_format (policy_name  IN VARCHAR2,
                            label_format IN VARCHAR2);

PROCEDURE set_effective (policy_name IN VARCHAR2,
                         labels      IN lbac_label_list,
                         privs       IN lbac_privs);

PROCEDURE set_effective_labels (policy_name IN VARCHAR2,
                                labels IN lbac_label_list);

PROCEDURE set_effective_privs (policy_name IN VARCHAR2,
                               effective_privs IN lbac_privs);

FUNCTION bypassread (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(bypassread, WNPS, RNDS, WNDS);

FUNCTION bypassall (policy_name IN VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(bypassread, WNPS, RNDS, WNDS);

END lbac_session;
/

show errors


------------------------------ lbac_services ---------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_services AS

--
--  The LBAC_SERVICES package provides services for policy packages.

PROCEDURE audit_privilege (policy_name  IN VARCHAR2,
                           audit_action IN PLS_INTEGER,
                           privilege    IN PLS_INTEGER,
                           success      IN BOOLEAN,
                           comment_text IN VARCHAR2);

PROCEDURE audit_action(policy_name  IN VARCHAR2, 
                       action       IN PLS_INTEGER,
                       success      IN BOOLEAN,
                       comment_text IN VARCHAR2);
END lbac_services;
/
show errors

-------------------- to_label_list --------------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.to_label_list AS

-- This package builds lbac_label lists from character strings and 
-- LBAC_LABELs

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2, 
                    label1 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2, 
                    label1 IN VARCHAR2, 
                    label2 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2, 
                    label1 IN VARCHAR2, 
                    label2 IN VARCHAR2, 
                    label3 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2,
                    label1 IN VARCHAR2,
                    label2 IN VARCHAR2,
                    label3 IN VARCHAR2,
                    label4 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2,
                    label1 IN VARCHAR2,
                    label2 IN VARCHAR2,
                    label3 IN VARCHAR2,
                    label4 IN VARCHAR2,
                    label5 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_char (policy_name IN VARCHAR2,
                    format IN VARCHAR2,
                    label1 IN VARCHAR2,
                    label2 IN VARCHAR2,
                    label3 IN VARCHAR2,
                    label4 IN VARCHAR2,
                    label5 IN VARCHAR2,
                    label6 IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION from_label (policy_name IN VARCHAR2,  
                    label1 IN lbac_label)
RETURN lbac_label_list;

FUNCTION from_label ( policy_name IN VARCHAR2, 
                    label1 IN lbac_label, 
                    label2 IN lbac_label)
RETURN lbac_label_list;

FUNCTION from_label ( policy_name IN VARCHAR2, 
                    label1 IN lbac_label, 
                    label2 IN lbac_label, 
                    label3 IN lbac_label)
RETURN lbac_label_list;

FUNCTION from_label (policy_name IN VARCHAR2, 
                    label1 IN lbac_label,
                    label2 IN lbac_label,
                    label3 IN lbac_label,
                    label4 IN lbac_label)
RETURN lbac_label_list;

FUNCTION from_label (policy_name IN VARCHAR2, 
                    label1 IN lbac_label,
                    label2 IN lbac_label,
                    label3 IN lbac_label,
                    label4 IN lbac_label,
                    label5 IN lbac_label)
RETURN lbac_label_list;

FUNCTION from_label (policy_name IN VARCHAR2, 
                    label1 IN lbac_label,
                    label2 IN lbac_label,
                    label3 IN lbac_label,
                    label4 IN lbac_label,
                    label5 IN lbac_label,
                    label6 IN lbac_label)
RETURN lbac_label_list;


END to_label_list;
/
show errors

----------------------------- lbac_utl --------------------------------
CREATE OR REPLACE PACKAGE LBACSYS.lbac_utl AS

FUNCTION system_info_exp(prepost IN  PLS_INTEGER,
                         connectstring  OUT VARCHAR2,
                         version        IN  VARCHAR2,
                         new_block      OUT PLS_INTEGER)
RETURN VARCHAR2;

FUNCTION instance_info_exp(name IN VARCHAR2,
                           schema IN VARCHAR2,
                           prepost IN PLS_INTEGER,
                           isdba IN PLS_INTEGER,
                           version IN VARCHAR2,
                           new_block OUT PLS_INTEGER)
   RETURN VARCHAR2;

FUNCTION schema_info_exp(schema IN VARCHAR2,
                         prepost IN PLS_INTEGER,
                         isdba IN PLS_INTEGER,
                         version IN VARCHAR2,
                         new_block OUT PLS_INTEGER)
   RETURN VARCHAR2;

/* String returned can be only 128 bytes long */
FUNCTION nls_substrb (in_string IN VARCHAR2,
                      num_bytes IN PLS_INTEGER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (nls_substrb, RNDS, WNDS, RNPS, WNPS);

FUNCTION nls_validname (in_string IN VARCHAR2)
RETURN PLS_INTEGER;

FUNCTION number_policy_column
RETURN BOOLEAN;

FUNCTION label_flags(label IN LBAC_LABEL)
RETURN PLS_INTEGER;

FUNCTION label_flags(label_tag IN INTEGER)
RETURN PLS_INTEGER;

FUNCTION data_label(label IN LBAC_LABEL)
RETURN BOOLEAN;

FUNCTION user_data_label(label IN LBAC_LABEL)
RETURN BOOLEAN;

FUNCTION data_label(label_tag IN INTEGER)
RETURN BOOLEAN;

FUNCTION user_data_label(label_tag IN INTEGER)
RETURN BOOLEAN;

FUNCTION label_tagseq(label IN LBAC_LABEL)
RETURN LBAC_LABEL;

FUNCTION label_tagseq(label_tag IN NUMBER)
RETURN LBAC_LABEL;

FUNCTION label_exists(policy_name      IN VARCHAR2, 
                      label_string     IN VARCHAR2,
                      label_tag        IN INTEGER,
                      bin_label        OUT LBAC_BIN_LABEL,
                      int_label        OUT VARCHAR2,
                      policy_strlabel  OUT VARCHAR2,
                      label_flags      OUT PLS_INTEGER)
RETURN PLS_INTEGER;

FUNCTION get_label_info(policy_name  IN  VARCHAR2, 
                        label_string IN  VARCHAR2,
                        label_tag    IN OUT INTEGER,
                        label_flags  IN OUT INTEGER, 
                        bin_label    OUT LBAC_BIN_LABEL,
                        int_label    OUT VARCHAR2,
                        policy_strlabel OUT VARCHAR2)
RETURN BOOLEAN;

END lbac_utl;
/
show errors

------------------------------ lbac_label_admin -------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_label_admin AS
--
-- This package is used by an administrator, with <policy>_DBA role,
-- to create and maintain labels in a database.
--

PROCEDURE create_label (policy_name     IN VARCHAR2,
                        label_tag       IN INTEGER,
                        label_value     IN VARCHAR2,
                        data_label      IN BOOLEAN DEFAULT TRUE);

PROCEDURE alter_label (policy_name      IN VARCHAR2,
                       label_tag        IN INTEGER,
                       new_label_value  IN VARCHAR2 DEFAULT NULL,
                       new_data_label   IN BOOLEAN  DEFAULT NULL);

PROCEDURE alter_label (policy_name       IN VARCHAR2,
                       label_value       IN VARCHAR2,
                       new_label_value   IN VARCHAR2 DEFAULT NULL,
                       new_data_label    IN BOOLEAN DEFAULT NULL);

PROCEDURE alter_label_sql (policy_name       IN VARCHAR2,
                           label_tag         IN INTEGER,
                           new_data_label    IN INTEGER);

PROCEDURE alter_label_sql (policy_name       IN VARCHAR2,
                           label_value       IN VARCHAR2,
                           new_label_value   IN VARCHAR2,
                           new_data_label    IN INTEGER);

PROCEDURE drop_label (policy_name IN VARCHAR2,
                      label_tag   IN INTEGER);

PROCEDURE drop_label (policy_name IN VARCHAR2,
                      label_value IN VARCHAR2);

END lbac_label_admin;
/
show errors
--
-- $Header: zllr.pkh 13-aug-2002.12:25:43 srtata Exp $
--
-- zllr.pkh
--
--  Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
--
--    NAME
--      zllr.pkh - ZL Row-level security PacKage Header
--
--    DESCRIPTION
--      This file contains the specifications for the procedures to 
--      implement the LBAC RLS functions.
--
--    NOTES
--       Run as LBACSYS 
--
--    MODIFIED   (MM/DD/YY)
--       srtata   08/13/02 - add readcheck_filter2
--       vpesati  08/28/01 - cleanup
--       gmurphy  04/08/01 - add 2001 to copyright
--       gmurphy  02/26/01 - qualify objects for install as SYSDBA
--       gmurphy  02/02/01 - Merged gmurphy_ols_2rdbms
--       vpesati  10/18/00 - caching changes
--       vpesati  09/06/00 - add policy functions
--       vpesati  04/08/00 - add policy function using context
--       cchui    12/01/99 - clean up
--       cchui    09/17/99 - add gen_filter function
--    rburns      6/04/99 - Created
--
---------------------------- lbac_rls ------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac_rls AS

--  This package contains the procedures that implement the LBAC Row Level
--  Security (RLS) functions.  The first three functions return a predicate
--  that includes a clause for each policy the table has.  The second three
--  functions are the functions invoked for each policy in the predicate 
--  clauses.

-- Predicate Generation Function

   FUNCTION read_filter (schema_name IN VARCHAR2,
                             table_name  IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION check_filter (schema_name IN VARCHAR2,
                             table_name  IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION readcheck_filter (schema_name IN VARCHAR2,
                             table_name  IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION readcheck_filter2 (schema_name IN VARCHAR2,
                               table_name  IN VARCHAR2)
   RETURN VARCHAR2;

END lbac_rls;
/
show errors
-- 
--  $Header: zlla.pkb 04-nov-2003.00:58:26 evarghes Exp $
-- 
--  zlla.pkb
-- 
--   Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlla.pkb
-- 
--     DESCRIPTION
--       Label Based Access Control type bodies for
--           LBAC_LABEL
--           LBAC_LABEL_LIST
--           LBAC_BIN_LABEL
--           LBAC_PRIVS
--           LBAC_COMPS      
-- 
--     NOTES
--       Run as LBACSYS
-- 
--     MODIFIED   (MM/DD/YY)
--     evarghes    10/31/03 - Bug# 3106363 PLSQL dur in zllalgeel, zlluel
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     04/02/01 - no grants for sys install
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/13/01 - change for upgrade script
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     vpesati     07/28/00 - remove bin label methods
--     cchui       03/28/00 - add indicator for new_lbac_label
--     rsripada    02/11/00 - change calls from to_order to to_tag
--     cchui       01/04/00 - user lbac_utl.to_order
--     cchui       12/13/99 - change lbac_label map method
--     rburns      11/03/99 - Remove unused functions
--     vpesati     10/08/99 - change zllabeqs to zllabseq
--     vpesati     09/07/99 - cleanup
--     vpesati     08/24/99 - new method on bin label
--     vpesati     08/21/99 - fix is_subset
--     rburns      08/09/99 - cleanup
--     cchui       08/13/99 - modify lbac_label map function
--     cchui       08/05/99 - modify return para for lbac_comps test methods
--     cchui       08/02/99 - add mapping function for lbac_label
--     cchui       07/30/99 - add method to retrieve lbac_label tag value
--     rburns      07/23/99 - add EQ method for bin_label & lbac_compare
--     vpesati     07/20/99 - fix zllalgeel
--     vpesati     07/20/99 - change grants on types
--     cchui       07/19/99 - fix lbac_privs.policy_id function
--     cchui       07/19/99 - fix lbac_bin_label.eq function
--     rburns      07/19/99 - add lbac_bin_label.eq method
--     cchui       07/16/99 - change lbac_label.eq to return PLS_INTEGER
--     cchui       07/13/99 - add constructor for lbac_privs
--     rburns      07/13/99 - code to_label, etc in PL/SQL
--     vpesati     07/12/99 - add lbac_bin_label constructor
--     cchui       07/12/99 - add constructors for lbac datatypes
--     rburns      07/08/99 - change label_list to opaque
--     rburns      07/06/99 - add labels_to_char and to_char_format
--     cchui       07/07/99 - add lbac_label_list
--     rburns      07/05/99 - Wrap TO_LABEL to not require a format string
--     rburns      06/30/99 - Add LBAC_PRIVS functions
--     cchui       06/27/99 - Change parameters on zllaltc
--     cchui       06/25/99 - Add new libraries for lbac datatypes
--     vpesati     06/10/99 - change type of return length
--     vpesati     06/02/99 - change prototypes
--     cchui       05/31/99 - Fix compilation errors
--     rburns      05/22/99 - remove char functions for lbac_bin_label
--     rburns      04/21/99 - Re-org PL/SQL modules
--     cchui       03/03/99 - Add LBAC_LABEL type.
--     cchui       02/10/99 - Creation of LBAC interface package body.
--     cchui       02/10/99 - Created
-- 

CREATE OR REPLACE FUNCTION LBACSYS.bin_to_raw (
                       bin_label IN lbac_bin_label)
RETURN RAW AS EXTERNAL LIBRARY LBACSYS.lbac$type_libt NAME "zllabctr"
WITH CONTEXT PARAMETERS(context, bin_label,
                        bin_label INDICATOR SB2,
                        RETURN LENGTH SB4,
                        RETURN INDICATOR SB2,
                        RETURN RAW);
/
show errors;

-------------------------- lbac_label ----------------------------------------

CREATE OR REPLACE TYPE BODY LBACSYS.lbac_label AS

  STATIC FUNCTION new_lbac_label(num IN PLS_INTEGER)
  RETURN lbac_label
      IS LANGUAGE C
      NAME "zllanlab"
      LIBRARY LBACSYS.lbac$label_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 num UB4,
                 num INDICATOR SB2,
                 RETURN INDICATOR SB2,
                 RETURN DURATION OCIDuration,
                 RETURN);

--  MAP MEMBER FUNCTION lbac_label_map
--  RETURN RAW IS
--  bin_label lbac_bin_label;
--  BEGIN
--     bin_label := lbac_compare.to_bin_label(SELF);
--     RETURN bin_to_raw(bin_label);
--  END;

  MEMBER FUNCTION to_tag (SELF IN lbac_label)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllaltt"
      LIBRARY LBACSYS.lbac$label_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB4);

  MAP MEMBER FUNCTION lbac_label_map
  RETURN PLS_INTEGER IS
  BEGIN
     RETURN lbac_label.to_tag(SELF); 
  END;

  MEMBER FUNCTION eq_sql (SELF IN lbac_label,
                          comp_label IN lbac_label)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllaleqs"
      LIBRARY LBACSYS.lbac$label_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 comp_label,
                 comp_label INDICATOR SB2,
                 RETURN SB4);

  MEMBER FUNCTION eq (SELF IN lbac_label,
                      comp_label IN lbac_label)
  RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllaleq"
      LIBRARY LBACSYS.lbac$label_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 comp_label,
                 comp_label INDICATOR SB2,
                 RETURN UB1);

END;
/

show errors

-------------------------- lbac_bin_label ------------------------------------

CREATE OR REPLACE TYPE BODY LBACSYS.lbac_bin_label AS 

  STATIC FUNCTION new_lbac_bin_label ( policy_id  IN PLS_INTEGER,
                            bin_size  IN PLS_INTEGER)
  RETURN LBAC_BIN_LABEL
      IS LANGUAGE C
      NAME "zllabnbl"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 policy_id SIZE_T,
                 bin_size SIZE_T,
                 RETURN INDICATOR SB2,
                 RETURN DURATION OCIDuration,
                 RETURN);

  
  MEMBER FUNCTION bin_size (SELF IN lbac_bin_label)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllabsz"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN SIZE_T);


  MEMBER FUNCTION set_raw (SELF IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            raw_label IN RAW)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllabsr"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 position SIZE_T,
                 byte_len SIZE_T,
                 raw_label RAW,
                 raw_label LENGTH SIZE_T,
                 RETURN SIZE_T);

  
  MEMBER FUNCTION set_int (SELF IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            int_label IN PLS_INTEGER)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllabsi"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 position SIZE_T,
                 byte_len SIZE_T,
                 int_label INT,
                 RETURN SIZE_T);

  MEMBER FUNCTION to_raw (SELF IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN RAW
      IS LANGUAGE C
      NAME "zllabtr"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 position SIZE_T,
                 byte_len SIZE_T,
                 RETURN LENGTH SB4,
                 RETURN INDICATOR SB2,
                 RETURN RAW);

  MEMBER FUNCTION to_int (SELF IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllabti"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 position SIZE_T,
                 byte_len SIZE_T,
                 RETURN INT);

  MEMBER FUNCTION policy_id (SELF IN lbac_bin_label)
     RETURN PLS_INTEGER
     IS LANGUAGE C
     NAME "zllabpid"
     LIBRARY LBACSYS.lbac$type_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT,
                SELF,
                SELF INDICATOR SB2,
                RETURN UB4);

  MEMBER FUNCTION eq_sql (SELF IN lbac_bin_label,
                          comp_label IN lbac_bin_label)
  RETURN PLS_INTEGER
      IS LANGUAGE C
      NAME "zllabseq"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 comp_label,
                 comp_label INDICATOR SB2,
                 RETURN SB4);

  MEMBER FUNCTION eq (SELF IN lbac_bin_label,
                      comp_label IN lbac_bin_label)
  RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllabeq"
      LIBRARY LBACSYS.lbac$type_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 comp_label,
                 comp_label INDICATOR SB2,
                 RETURN UB1);

END;
/
show errors

--------------------------- lbac_privs ------------------------------------

CREATE OR REPLACE TYPE BODY LBACSYS.lbac_privs AS

  STATIC FUNCTION new_lbac_privs(policy_id IN PLS_INTEGER)
  RETURN lbac_privs
      IS LANGUAGE C
      NAME "zllanprv"
      LIBRARY LBACSYS.lbac$privs_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 policy_id UB4,
                 RETURN INDICATOR SB2,
                 RETURN DURATION OCIDuration,
                 RETURN);

   MEMBER PROCEDURE clear_priv(SELF IN OUT NOCOPY lbac_privs, 
                               priv_number IN PLS_INTEGER)
      IS LANGUAGE C 
      NAME "zllapclr" 
      LIBRARY LBACSYS.lbac$privs_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF,
                 SELF INDICATOR SB2,
                 priv_number UB4);


   MEMBER PROCEDURE set_priv(SELF IN OUT NOCOPY lbac_privs, 
                             priv_number IN PLS_INTEGER) 
      IS LANGUAGE C 
      NAME "zllapset" 
      LIBRARY LBACSYS.lbac$privs_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF, 
                 SELF INDICATOR SB2, 
                 priv_number UB4);

   MEMBER FUNCTION test_priv(SELF IN lbac_privs, 
                             priv_number IN PLS_INTEGER) 
   RETURN BOOLEAN 
      IS LANGUAGE C 
      NAME "zllaptst" 
      LIBRARY LBACSYS.lbac$privs_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF, 
                 SELF INDICATOR SB2, 
                 priv_number UB4, 
                 RETURN INT);

   MEMBER FUNCTION none(SELF IN lbac_privs)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllapnon"
      LIBRARY LBACSYS.lbac$privs_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN INT);

  MEMBER PROCEDURE union_privs(SELF IN OUT NOCOPY lbac_privs,
                              other_privs IN lbac_privs)
      IS LANGUAGE C
      NAME "zllapun"
      LIBRARY LBACSYS.lbac$privs_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 other_privs,
                 other_privs INDICATOR SB2);

  MEMBER PROCEDURE diff_privs(SELF IN OUT NOCOPY lbac_privs,
                              other_privs IN lbac_privs)
      IS LANGUAGE C
      NAME "zllapdf"
      LIBRARY LBACSYS.lbac$privs_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 other_privs,
                 other_privs INDICATOR SB2);
                 
MEMBER FUNCTION policy_id (SELF IN lbac_privs)
     RETURN PLS_INTEGER
     IS LANGUAGE C
     NAME "zllappid"
     LIBRARY LBACSYS.lbac$privs_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT,
                SELF, SELF INDICATOR SB2,
                RETURN UB4 );

END;
/
show errors

-------------------------- lbac_comps ----------------------------------------

CREATE OR REPLACE TYPE BODY LBACSYS.lbac_comps AS

  STATIC FUNCTION new_lbac_comps
  RETURN lbac_comps
      IS LANGUAGE C
      NAME "zllancmp"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 RETURN INDICATOR SB2,
                 RETURN DURATION OCIDuration,
                 RETURN);

   MEMBER PROCEDURE set_gt(SELF IN OUT NOCOPY lbac_comps) 
      IS LANGUAGE C
      NAME "zllacgt" 
      LIBRARY LBACSYS.lbac$comps_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF, 
                 SELF INDICATOR SB2);

   MEMBER PROCEDURE set_eq(SELF IN OUT NOCOPY lbac_comps) 
      IS LANGUAGE C
      NAME "zllaceq" 
      LIBRARY LBACSYS.lbac$comps_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF, 
                 SELF INDICATOR SB2);

   MEMBER PROCEDURE set_lt(SELF IN OUT NOCOPY lbac_comps) 
      IS LANGUAGE C
      NAME "zllaclt" 
      LIBRARY LBACSYS.lbac$comps_libt          
      WITH CONTEXT
      PARAMETERS(CONTEXT, 
                 SELF, 
                 SELF INDICATOR SB2);

   MEMBER PROCEDURE set_sortgt(SELF IN OUT NOCOPY lbac_comps)
      IS LANGUAGE C
      NAME "zllacsgt"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2);

   MEMBER PROCEDURE set_sorteq(SELF IN OUT NOCOPY lbac_comps)
      IS LANGUAGE C
      NAME "zllacseq"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2);

   MEMBER PROCEDURE set_sortlt(SELF IN OUT NOCOPY lbac_comps)
      IS LANGUAGE C
      NAME "zllacslt"
      LIBRARY LBACSYS.lbac$comps_libt 
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2);

   MEMBER FUNCTION test_lt(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllactlt"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);

   MEMBER FUNCTION test_le(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllactle"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);


   MEMBER FUNCTION test_eq(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllacteq"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);

   MEMBER FUNCTION test_ne(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllactne"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);

   MEMBER FUNCTION test_ge(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllactge"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);

   MEMBER FUNCTION test_gt(SELF IN lbac_comps)
   RETURN BOOLEAN
      IS LANGUAGE C
      NAME "zllactgt"
      LIBRARY LBACSYS.lbac$comps_libt
      WITH CONTEXT
      PARAMETERS(CONTEXT,
                 SELF,
                 SELF INDICATOR SB2,
                 RETURN UB1);



END;
/
show errors

-------------------------- lbac_label_list ----------------------------------

CREATE OR REPLACE TYPE BODY LBACSYS.lbac_label_list AS

   STATIC FUNCTION new_lbac_label_list(policy_id IN PLS_INTEGER)
     RETURN lbac_label_list
     IS LANGUAGE C
     NAME "zllalinit"
     LIBRARY LBACSYS.lbac$lablt_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT, 
                policy_id UB4,
                RETURN INDICATOR SB2, 
                RETURN DURATION OCIDuration,
                RETURN);

   MEMBER PROCEDURE put (SELF  IN OUT lbac_label_list,
                         label IN lbac_label, 
                         pos   IN PLS_INTEGER)
     IS LANGUAGE C
     NAME "zllalpuel"
     LIBRARY LBACSYS.lbac$lablt_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT, 
                SELF, SELF INDICATOR SB2,
                label,
                label INDICATOR SB2,
                pos UB4);

   MEMBER FUNCTION get (SELF IN lbac_label_list, 
                        pos IN PLS_INTEGER)
     RETURN lbac_label
     IS LANGUAGE C
     NAME "zllalgeel"
     LIBRARY LBACSYS.lbac$lablt_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT, 
                SELF, SELF INDICATOR SB2, 
                pos UB4, 
                RETURN INDICATOR SB2,
                RETURN DURATION OCIDuration,
                RETURN);

   MEMBER FUNCTION count (SELF IN lbac_label_list)
     RETURN PLS_INTEGER
     IS LANGUAGE C
     NAME "zllalcnt"
     LIBRARY LBACSYS.lbac$lablt_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT,
                SELF, SELF INDICATOR SB2,
                RETURN INT );
                
   MEMBER FUNCTION policy_id (SELF IN lbac_label_list)
     RETURN PLS_INTEGER
     IS LANGUAGE C
     NAME "zllalpid"
     LIBRARY LBACSYS.lbac$lablt_libt
     WITH CONTEXT
     PARAMETERS(CONTEXT,
                SELF, SELF INDICATOR SB2,
                RETURN UB4 );


END;
/
show errors
-- 
--  $Header: rdbms/src/server/security/ols/lbac/lbaccrdd.sql /st_rdbms_11.2.0/4 2011/06/22 21:59:14 dsirmuka Exp $
--
-- lbaccrdd.sql
--
-- Copyright (c) 1999, 2011, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      lbaccrdd.sql - LBAC CrReate Data Dictionary.
--
--    DESCRIPTION
--      Label Based Access Control data dictionary definitions.
--
--    NOTES
--      Run as LBACSYS
--
--    MODIFIED   (MM/DD/YY)
--    dsirmuka    06/08/11 - LRG 5540722.create index on (pol#,ilabel) in a 
--                           exception handler.
--    dsirmuka    11/08/10 - #8202485.Add index on (pol#,ilabel) of lbac$lab
--    gclaborn    02/17/11 - Fix wildcard spec. in import callout reg.
--    srtata      01/07/11 - OLS 11.2.0.3 datapump registrations
--    cchui       06/29/04 - reduce the size of name column on sessinfo table 
--    cchui       04/30/04 - Add sessinfo table for RAC 
--    gmulagun    01/02/03 - Remove AUDIT_SEQUENCE sequence
--    shwong      10/24/02 - change usr_name to 1024 in lbacshwong
--    srtata      10/09/02 - add table for policy admins
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     04/06/01 - add index to lbac$lab table
--    gmurphy     04/02/01 - LBAC_DBA to lbacsys.sql
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/16/01 - fix version info
--    gmurphy     02/13/01 - change for upgrade script
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    rsripada    10/30/00 - add policy role column to lbac$pol
--    rsripada    09/14/00 - modify lbac$installations entries
--    vpesati     04/19/00 - create indexes
--    vpesati     04/10/00 - add tag sequence
--    rburns      03/05/00 - use NUMBER(10) for nlabel
--    rsripada    03/02/00 - remove insert into lbac$props
--    rburns      02/28/00 - add numeric label interfaces
--    rsripada    02/21/00 - input numeric/opaque datatype option
--    rburns      02/15/00 - add banner column to installations
--    rsripada    02/11/00 - remove order column
--    rsripada    02/04/00 - add lbac$props table to store install time paramet
--    rsripada    02/02/00 - add a view to look for policy columns
--    rsripada    01/31/00 - create lbac_dba role
--    rsripada    01/19/00 - remove connect statements
--    rsripada    01/11/00 - change primary key in lbac$prog
--    rburns      01/12/00 - allow NULL bin label
--    cchui       12/02/99 - increase the size of polt.predicate
--    vpesati     11/25/99 - dictionary changes for SA int
--    rsripada    10/18/99 - combine lbac$prog and lbac$prog_priv
--    rsripada    10/06/99 - create a new sequence for audit records
--    rburns      09/02/99 - remove NOT NULL privs
--    rburns      08/26/99 - fix scope
--    rburns      08/25/99 - fix user tables
--    rsripada    08/22/99 - create LBAC_AUDIT_ACTIONS table
--    rsripada    08/17/99 - fix lbacsys.aud$ creation
--    rsripada    08/11/99 - Create lbacsys.aud$ table
--    rsripada    08/06/99 - Change lbacaudit defintion
--    rburns      07/30/99 - add trusted_prg view
--    rburns      07/28/99 - fix package_functions
--    vpesati     07/23/99 - add view lbac all_table_policies
--    cchui       07/14/99 - modify lbac$user_logon
--    vpesati     07/14/99 - fix order of columns in lbacpol
--    rburns      07/13/99 - add policy format
--    vpesati     07/14/99 - change pol table
--    rburns      07/08/99 - fix to_char functions
--    rburns      07/06/99 - add dd views
--    vpesati     07/03/99 - add user logon view
--    rburns      06/29/99 - Fix minor problems
--    vpesati     06/21/99 - cleanup merge changes
--    rburns      06/10/99 - Fix merge problems
--    rburns      06/07/99 - Add keys and change char names to NUMBER
--    cchui       05/05/99 - Add sequence for lbacsys$lab table
--    cchui       04/21/99 - Remove sys from all the opaque types
--    cchui       04/13/99 - Add lbac_tab_col view.
--    cchui       04/13/99 - LBAC data dictionary.
--    cchui       04/13/99 - Created
--

CREATE TABLE LBACSYS.lbac$pol (
   pol#           NUMBER PRIMARY KEY,	
   pol_name       VARCHAR2(30) NOT NULL UNIQUE,
   column_name    VARCHAR2(30) NOT NULL UNIQUE,
   package        VARCHAR2(30) NOT NULL,
   pol_role       VARCHAR2(30) NOT NULL,
   bin_size       NUMBER NOT NULL,
   default_format VARCHAR2(30),
   db_labels      LBACSYS.lbac_label_list,
   policy_format  VARCHAR2(30),
   options        NUMBER,
   flags          NUMBER NOT NULL);

CREATE TABLE LBACSYS.lbac$pols (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.lbac$pol (pol#) ON DELETE CASCADE,
   owner        VARCHAR2(30) NOT NULL,
   options      NUMBER,
   flags        NUMBER,
   PRIMARY KEY (pol#,owner));

CREATE TABLE LBACSYS.lbac$polt (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.lbac$pol (pol#) ON DELETE CASCADE,
   tbl_name     VARCHAR2(30) NOT NULL,
   owner        VARCHAR2(30) NOT NULL,
   predicate    VARCHAR2(256),
   function     VARCHAR2(1024),
   options      NUMBER,
   flags        NUMBER,
   PRIMARY KEY (pol#,owner,tbl_name));

CREATE TABLE LBACSYS.lbac$user (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.lbac$pol (pol#) ON DELETE CASCADE,
   usr_name     VARCHAR2(1024) NOT NULL,
   labels       LBACSYS.lbac_label_list,
   privs        LBACSYS.lbac_privs,
   saved_labels LBACSYS.lbac_label_list,
   saved_privs  LBACSYS.lbac_privs,
   PRIMARY KEY (pol#,usr_name));

CREATE TABLE LBACSYS.lbac$prog (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.lbac$pol (pol#) ON DELETE CASCADE,
   pgm_name     VARCHAR2(30) NOT NULL,
   owner        VARCHAR2(30) NOT NULL,
   labels       LBACSYS.lbac_label_list,
   privs        LBACSYS.lbac_privs,
   PRIMARY KEY (pol#,pgm_name,owner));

CREATE TABLE LBACSYS.lbac$audit (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.lbac$pol (pol#) ON DELETE CASCADE,
   usr_name     VARCHAR2(30) NOT NULL,
   option#      NUMBER,
   success      NUMBER,
   failure      NUMBER,
   suc_type     NUMBER,
   fail_type    NUMBER,
   option_priv#   NUMBER,
   success_priv   NUMBER,
   failure_priv   NUMBER,
   suc_priv_type  NUMBER,
   fail_priv_type NUMBER,
   PRIMARY KEY (pol#,usr_name));

-- Create lbac_audit_actions table
CREATE TABLE LBACSYS.lbac_audit_actions (
  action#       NUMBER NOT NULL,
  name          VARCHAR2(40) NOT NULL);

delete from LBACSYS.lbac_audit_actions;
insert into LBACSYS.lbac_audit_actions values
                (500, 'APPLY TABLE OR SCHEMA POLICY');
insert into LBACSYS.lbac_audit_actions values
                (501, 'REMOVE TABLE OR SCHEMA POLICY');
insert into LBACSYS.lbac_audit_actions values
                (502, 'SET USER OR PROGRAM UNIT LABEL RANGES');
insert into LBACSYS.lbac_audit_actions values
                (503, 'GRANT POLICY SPECIFIC PRIVILEGES');
insert into LBACSYS.lbac_audit_actions values
                (504, 'REVOKE POLICY SPECIFIC PRIVILEGES');
insert into LBACSYS.lbac_audit_actions values
                (505, 'OBJECT EXISTS ERRORS');
insert into LBACSYS.lbac_audit_actions values
                (506, 'PRIVILEGED ACTION');
insert into LBACSYS.lbac_audit_actions values
                (507, 'DBA ACTION');

-- opaque types cannot be primary or unique keys
CREATE TABLE LBACSYS.lbac$lab (
   tag#         NUMBER(10),
   lab#         LBACSYS.lbac_label NOT NULL,
   pol#         NUMBER NOT NULL,
   nlabel       NUMBER(10) NOT NULL,
   blabel       LBACSYS.lbac_bin_label,
   slabel       VARCHAR2(4000),
   ilabel       VARCHAR2(4000),
   flags        NUMBER,
   CONSTRAINT   label_pk PRIMARY KEY(nlabel),
   CONSTRAINT   label_policy_fk FOREIGN KEY (pol#) 
                REFERENCES LBACSYS.lbac$pol ON DELETE CASCADE);

CREATE TABLE LBACSYS.lbac$policy_admin(
      admin_dn    VARCHAR2(1024) NOT NULL,
      policy_name VARCHAR2(30)   NOT NULL,
      CONSTRAINT admin_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.lbac$pol(pol_name) ON DELETE CASCADE );

CREATE SEQUENCE LBACSYS.lbac$lab_sequence
   INCREMENT BY 1
   MINVALUE 1000000000
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

CREATE SEQUENCE LBACSYS.lbac$tag_sequence
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 4000000000
   CACHE 20
   ORDER;


CREATE TABLE LBACSYS.lbac$installations (
   component     VARCHAR(30),
   description   VARCHAR2(500),
   version       VARCHAR2(64),
   banner        VARCHAR2(80),
   installed     DATE);


CREATE TABLE LBACSYS.lbac$props (
   name         VARCHAR2(30) CONSTRAINT PK_LP PRIMARY KEY, 
   value$       VARCHAR2(4000),
   comment$     VARCHAR2(4000));

CREATE TABLE LBACSYS.sessinfo (
   key          VARCHAR2(32) NOT NULL,
   inst_number  NUMBER,
   userid       NUMBER,
   sid          NUMBER,
   serial#      NUMBER,
   startup_time DATE,
   type         INTEGER,
   name         VARCHAR2(1024),
   strvalue1    VARCHAR2(4000),
   strvalue2    VARCHAR2(4000),
   strvalue3    VARCHAR2(4000),
   numvalue1    INTEGER,
   numvalue2    INTEGER);

CREATE OR REPLACE VIEW LBACSYS.lbac$user_logon (pol#, usr_name,
usr_labels, package, db_labels, privs, default_format) AS
  SELECT usr.pol#, usr.usr_name, usr.labels, 
  pol.package, pol.db_labels, usr.privs, pol.default_format
  FROM LBACSYS.lbac$user usr, LBACSYS.lbac$pol pol
  WHERE pol.pol# = usr.pol#;

CREATE OR REPLACE VIEW LBACSYS.lbac$all_table_policies (pol#,
table_name, owner) AS 
  SELECT lbac$pols.pol#, all_tables.table_name, lbac$pols.owner
  FROM LBACSYS.lbac$pols, all_tables
  WHERE lbac$pols.owner = all_tables.owner
  UNION
  SELECT pol#, tbl_name, owner from LBACSYS.lbac$polt;


CREATE OR REPLACE VIEW LBACSYS.lbac$package_functions AS
  SELECT DISTINCT p.pol#, p.package, a.object_name AS function
    FROM LBACSYS.lbac$pol p, all_arguments a
  WHERE p.package = a.package_name AND a.owner = 'LBACSYS';

CREATE OR REPLACE VIEW LBACSYS.lbac$trusted_progs AS
  SELECT l.pol#, l.owner, l.pgm_name, l.privs, l.labels,
         po.pol_name, po.package
  FROM LBACSYS.lbac$prog l, LBACSYS.lbac$pol po
  where l.pol#=po.pol#;

CREATE OR REPLACE VIEW LBACSYS.lbac$policy_columns
   (owner, table_name, column_name, column_data_type)
AS
SELECT u.name, o.name,
       c.name,
       decode(c.type#, 2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER'),
                                 'NUMBER'),
                       58, 'OPAQUE')
FROM sys.col$ c, sys.obj$ o, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot
WHERE o.obj# = c.obj#
  AND o.owner# = u.user#
  AND c.obj# = ac.obj#(+) AND c.intcol# = ac.intcol#(+)
  AND ac.toid = ot.oid$(+)
  AND ot.type#(+) = 13
  AND o.type# =  2;

CREATE INDEX LBACSYS.LBAC$POL_PFCPIDX 
ON LBACSYS.lbac$pol(pol#,flags,column_name);

CREATE INDEX LBACSYS.LBAC$POLT_OTFPIDX 
ON LBACSYS.lbac$polt(owner,tbl_name,flags,pol#,predicate);

CREATE INDEX LBACSYS.LBAC$POLS_OWNPOLIDX 
ON LBACSYS.lbac$pols(owner,pol#);

CREATE INDEX LBACSYS.i_lbac$lab_1
ON LBACSYS.lbac$lab(tag#);

--
-- ORA-01450 happens during upgrade of 9.2 DB. This is due to 
-- smaller block size in 9.2. Block size cannot be increased
-- as other data is still in the smaller block size, and 
-- cannot reduce the size of ilabel column also. So, just
-- ignore ORA-01450
--

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX LBACSYS.i_lbac$lab_2 ON LBACSYS.lbac$lab(ilabel,pol#)';
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -1450 THEN
      NULL;
    ELSE 
      RAISE;
    END IF;
END;
/

CREATE INDEX LBACSYS.SESSINFO_IDX
ON LBACSYS.SESSINFO(key, userid, name);

-- Note : We have import callout registrations here as opposed to in 
-- lbacsys.sql , because having it here, will cover install, upgrade
-- as well as patch scenarios

-- Datapump import callout registrations
DELETE FROM sys.impcalloutreg$ WHERE tag = 'LABEL_SECURITY';

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP','LBACSYS', 'LABEL_SECURITY', 3, 1, 1,
                 'LBACSYS', 'LBAC$%', 2,
                 'Oracle Label Security');

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP','LBACSYS', 'LABEL_SECURITY', 3, 2, 1,
                 'LBACSYS', 'SA$%', 2,
                 'Oracle Label Security');
--
-- $Header: lbacerr.sql 08-apr-2001.11:36:47 gmurphy Exp $
--
-- Copyright (c) Oracle Corporation 1999, 2000, 2001.  All rights reserved.
--
--  NAME
--    lbacerr.sql
--  FUNCTION
--    Exceptions and error numbers for LBAC facility
--  NOTES
--    To be incorporated into the lbac script at some point.
--  MODIFIED
--     gmurphy    04/08/01 - add 2001 to copyright
--     gmurphy    02/26/01 - qualify objects for install as SYSDBA
--     gmurphy    02/02/01 - Merged gmurphy_ols_2rdbms
--    rburns   03/1/99 - created
--

CREATE OR REPLACE PACKAGE LBACSYS.lbac_errors AS

  invalid_label_string_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (invalid_label_string_ex, -12401);
  invalid_label_string_ec CONSTANT INTEGER := 12401;

  invalid_format_string_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (invalid_format_string_ex, -12402);
  invalid_format_string_ec CONSTANT INTEGER := 12402;
  
  invalid_binary_label_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (invalid_binary_label_ex, -12403);
  invalid_binary_label_ec CONSTANT INTEGER := 12403;
 
  invalid_privilege_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (invalid_privilege_ex, -12404);
  invalid_privilege_ec CONSTANT INTEGER := 12404;

  invalid_label_list_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (invalid_label_list_ex, -12405);
  invalid_label_list_ec CONSTANT INTEGER := 12405;
  
  unauthorized_sql_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (unauthorized_sql_ex, -12406);
  unauthorized_sql_ec CONSTANT INTEGER := 12406;
 
  unauthorized_op_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (unauthorized_sql_ex, -12407);
  unauthorized_op_ec CONSTANT INTEGER := 12407;
 
  internal_error_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT (internal_error_ex, -12410);
  internal_error_ec CONSTANT INTEGER := 12410;
 
END lbac_errors;
/

--
-- $Header: lbacinc.sql 08-oct-2004.16:33:21 cchui Exp $
--
-- Copyright (c) Oracle Corporation 1999, 2000, 2001.  All rights reserved.
--
--  NAME
--    lbacinc.sql
--  FUNCTION
--    lbacinc - OLS LBAC Framework
--  NOTES
--    Could be incorporated into the lbac script at some point.
--  MODIFIED
--    cchui    10/08/04 - 3936531: create validate_ols procedure in SYS schema 
--    srtata   03/16/04 - select version from registry 
--    srtata   10/22/02 - update to 10.0.0.0.0
--    srtata   02/21/02 - update to 9.2.0.1.0.
--    shwong   10/10/01 - update to 9.2.0.0.0
--    gmurphy  04/08/01 - add 2001 to copyright
--    gmurphy  04/06/01 - change for 9.0.1 production
--    gmurphy  02/26/01 - qualify objects for install as SYSDBA
--    gmurphy  02/16/01 - fix version info
--    gmurphy  02/15/01 - update version number
--    gmurphy  02/13/00 - Insert from lbacrdd for upgrade script
--    gmurphy  02/02/01 - Merged gmurphy_ols_2rdbms
--    rburns   03/1/99 - created
--

-- Install lbac the package bodies
@@prvtlbac.plb

-- Note that the LBAC framework is installed
DELETE FROM LBACSYS.lbac$installations
WHERE component = 'LBAC';

BEGIN

INSERT INTO LBACSYS.lbac$installations values (
            'LBAC',
            'Label-Based Access Control Framework',
            dbms_registry.release_version,
            'Label-Based Access Control ' ||dbms_registry.release_version ||
            ' - Production',
            SYSDATE);

END;
/

-- create validate_ols procedure in SYS schema
CREATE OR REPLACE PROCEDURE SYS.validate_ols AS
  num number;
BEGIN
  SELECT COUNT(*) INTO num from all_objects
    WHERE owner = 'LBACSYS' AND status = 'INVALID'
          AND object_name NOT IN (select trigger_name from all_triggers
                                  where owner='LBACSYS' AND
                                        table_owner <>'SYS');
  IF num = 0 THEN
    SYS.dbms_registry.valid('OLS');
  ELSE
    SYS.dbms_registry.invalid('OLS');
  END IF;
END validate_ols;
/
show errors;

