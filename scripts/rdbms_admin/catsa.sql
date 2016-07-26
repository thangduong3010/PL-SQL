-- 
--  $Header: zlasl.pkh 03-dec-2001.15:00:17 shwong Exp $
-- 
--  zlasl.pkh
-- 
--   Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlasl.pkh - ZL Adapter Secure access Label management PacKage Header
-- 
--     DESCRIPTION
--       Contains both the internal and external label management functions
--       (SA_COMPONENTS and LBAC$SA_LABELS). These functions refer to the 
--       Secure Access tables that define the label components for each 
--       policy (sa$levels, sa$compartments, and sa$groups).
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     shwong      12/03/01 - add subset_groups()
--     srtata      08/27/01 - change headers for inverse groups.
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     psack       08/21/00 - Add Merge Label
--     psack       08/14/00 - Remove Compare Empty routines
--     rsripada    07/23/00 - api changes
--     cchui       04/16/00 - change compare functions to return PLS_INTEGER
--     rburns      04/11/00 - store user labels unexpanded
--     rburns      04/08/00 - add more compare functions
--     rburns      03/30/00 - sa_components rename
--     rburns      03/12/00 - fix alter interfaces
--     rburns      02/22/00 - fix short/long parameters
--     rburns      02/17/00 - change sa_labels to sa_policy_labels
--     rburns      02/14/00 - add compute write label
--     cchui       02/07/00 - add greatest_lbound and least_ubound functions
--     rburns      01/28/00 - fix bugs
--     cchui       01/26/00 - add procedures to insert read and write labels
--     cchui       01/19/00 - add procedures to update default and row labels
--     rburns      01/12/00 - add user label list
--     rburns      01/11/00 - add checks for existing labels
--     rburns      01/07/00 - Created

--------------------------------- SA_COMPONENTS --------------------------

CREATE OR REPLACE PACKAGE LBACSYS.sa_components AS
--
-- This package is the administrative interface for managing the compartments,
-- compartments, and groups for a Secure Access policy.

-- Levels

PROCEDURE create_level (policy_name IN VARCHAR2,
                        level_num   IN INTEGER,
                        short_name  IN VARCHAR2,
                        long_name   IN VARCHAR2);
                        
PROCEDURE alter_level  (policy_name IN VARCHAR2,
                        level_num   IN INTEGER,
                        new_short_name  IN VARCHAR2 DEFAULT NULL,
                        new_long_name   IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_level  (policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2,
                        new_long_name   IN VARCHAR2);

PROCEDURE drop_level   (policy_name IN VARCHAR2,
                        level_num   IN INTEGER);

PROCEDURE drop_level   (policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2);
                        
-- Compartments

PROCEDURE create_compartment (
                        policy_name IN VARCHAR2,
                        comp_num    IN INTEGER,
                        short_name  IN VARCHAR2,
                        long_name   IN VARCHAR2);
                        
PROCEDURE alter_compartment  (
                        policy_name IN VARCHAR2,
                        comp_num    IN INTEGER,
                        new_short_name  IN VARCHAR2 DEFAULT NULL,
                        new_long_name   IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_compartment  (
                        policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2,
                        new_long_name   IN VARCHAR2);

PROCEDURE drop_compartment   (
                        policy_name IN VARCHAR2,
                        comp_num    IN INTEGER);

PROCEDURE drop_compartment   (
                        policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2);
                        
-- Groups

PROCEDURE create_group (
                        policy_name IN VARCHAR2,
                        group_num   IN INTEGER,
                        short_name  IN VARCHAR2,
                        long_name   IN VARCHAR2,
                        parent_name IN VARCHAR2 DEFAULT NULL);
                        
PROCEDURE alter_group  (
                        policy_name IN VARCHAR2,
                        group_num   IN INTEGER,
                        new_short_name  IN VARCHAR2 DEFAULT NULL,
                        new_long_name   IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_group  (
                        policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2,
                        new_long_name   IN VARCHAR2);

PROCEDURE alter_group_parent  (
                        policy_name IN VARCHAR2,
                        group_num   IN INTEGER,
                        new_parent_num  IN INTEGER);

PROCEDURE alter_group_parent  (
                        policy_name IN VARCHAR2,
                        group_num   IN INTEGER,
                        new_parent_name  IN VARCHAR2);

PROCEDURE alter_group_parent  (
                        policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2,
                        new_parent_name IN VARCHAR2);

PROCEDURE drop_group   (
                        policy_name IN VARCHAR2,
                        group_num   IN INTEGER);
PROCEDURE drop_group   (
                        policy_name IN VARCHAR2,
                        short_name  IN VARCHAR2);
                                                
END sa_components;
/
show errors

------------------------- LBAC$SA_LABELS -----------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.lbac$sa_labels AS

-- This package encapsulates the interpretation of the Secure Access internal
-- labels.

PROCEDURE startup;

FUNCTION to_label (pol_id       IN PLS_INTEGER, 
                   label_string IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION from_label  (ilabel       IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE compare_labels (ilabel1 IN VARCHAR2,
                          ilabel2 IN VARCHAR2,
                          result  OUT PLS_INTEGER);
                          
PROCEDURE compare_levels (ilabel1 IN VARCHAR2,
                          ilabel2 IN VARCHAR2,
                          result  OUT PLS_INTEGER);
                          
PROCEDURE compare_comps  (ilabel1 IN VARCHAR2,
                          ilabel2 IN VARCHAR2,
                          result  OUT PLS_INTEGER);
                          
PROCEDURE compare_groups (ilabel1 IN VARCHAR2,
                          ilabel2 IN VARCHAR2,
                          result  OUT PLS_INTEGER);

FUNCTION components_dominate(flag1   IN PLS_INTEGER,
                             lvl1    IN PLS_INTEGER,
                             cmps1   IN VARCHAR2,
                             flag2   IN PLS_INTEGER, 
                             lvl2    IN PLS_INTEGER,
                             cmps2   IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION components_dominate(flag1   IN PLS_INTEGER,
                             lvl1    IN PLS_INTEGER,
                             cmps1   IN VARCHAR2,
                             grps1   IN VARCHAR2,                            
                             flag2   IN PLS_INTEGER, 
                             lvl2    IN PLS_INTEGER,
                             cmps2   IN VARCHAR2,
                             grps2   IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION merge_label (ilabel1 IN VARCHAR2,
                      ilabel2 IN VARCHAR2,
                      fmt     IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION level_in_use       (pol_id     IN PLS_INTEGER,
                             short_name IN VARCHAR2)
RETURN BOOLEAN;
 
FUNCTION compartment_in_use (pol_id     IN PLS_INTEGER,
                             short_name IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION group_in_use       (pol_id     IN  PLS_INTEGER,
                             short_name IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION user_label_list    (pol_id    IN PLS_INTEGER,
                             user_name IN VARCHAR2)
RETURN lbac_label_list;

FUNCTION expanded_user_label_list    (pol_id    IN PLS_INTEGER,
                             user_name IN VARCHAR2)
RETURN lbac_label_list;

PROCEDURE store_user_label_list    (pol_id    IN PLS_INTEGER,
                             user_name IN VARCHAR2);

PROCEDURE insert_read_label (pol_id    IN PLS_INTEGER,
                             user_name IN VARCHAR2,
                             ilabel    IN VARCHAR2);

PROCEDURE insert_write_label (pol_id        IN PLS_INTEGER,
                              user_name     IN VARCHAR2,
                              ilabel        IN VARCHAR2,
			      max_rd_ilabel IN VARCHAR2 DEFAULT NULL);

PROCEDURE update_default_label (pol_id          IN PLS_INTEGER,
                                user_name       IN VARCHAR2,
                                ilabel          IN VARCHAR2,
		                max_rd_ilabel   IN VARCHAR2 DEFAULT NULL);

PROCEDURE update_row_label (pol_id     IN PLS_INTEGER,
                            user_name  IN VARCHAR2,
                            ilabel     IN VARCHAR2,
                            def_ilabel IN VARCHAR2 DEFAULT NULL );

FUNCTION compute_write_label (pol_id    IN PLS_INTEGER,
                              max_write_label IN VARCHAR2,
                              read_label      IN VARCHAR2)
RETURN VARCHAR2;   

FUNCTION label_level_only (ilabel IN VARCHAR2)
RETURN PLS_INTEGER;

FUNCTION expand_label (ilabel IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION set_inverse_policy_bit(pol_id IN PLS_INTEGER)
RETURN PLS_INTEGER;

FUNCTION subset_groups(ilabel1 IN VARCHAR2, ilabel2 IN VARCHAR2)
RETURN BOOLEAN;

END lbac$sa_labels;
/
show errors


--
--  $Header: zlasdip.pkh 21-oct-2002.11:42:33 srtata Exp $
--
--  zlasdip.pkh
--
--   Copyright (c) Oracle Corporation 2000, 2001. All Rights Reserved.
--
--     NAME
--       zlasdip.pkh - ZL DIP Callback PacKage Specification.
--
--     DESCRIPTION
--       Contains the callback function which DIP would execute
--
--     NOTES
--       Run as LBACSYS
--
--     MODIFIED   (MM/DD/YY)
--     srtata      10/21/02 - remove DROP statements
--     srtata      10/08/02 - srtata_olsdip1
--     srtata      10/02/02 - Created
--

-- LDAP ATTR
----------------------------------------------------------------
--
--  Name        : LDAP_ATTR
--  Data Type   : OBJECT
--  DESCRIPTION : This structure contains details regarding
--                an attribute.
--
----------------------------------------------------------------
CREATE TYPE LBACSYS.LDAP_ATTR AS OBJECT (                                
     attr_name        VARCHAR2(256),
     attr_value       VARCHAR2(4000),
     attr_bvalue      BLOB,
     attr_value_len   INTEGER,
     attr_type        INTEGER,  -- (0 - String, 1 - Binary)
     attr_mod_op      INTEGER
);
/

show errors

 GRANT EXECUTE ON LBACSYS.LDAP_ATTR to public;

-------------------------------------------------------------
--
--  Name        : LDAP_ATTR_LIST
--  Data Type   : COLLECTION
--  DESCRIPTION : This structure contains collection
--                of attributes.
--
-------------------------------------------------------------
CREATE TYPE LBACSYS.LDAP_ATTR_LIST AS TABLE OF LBACSYS.LDAP_ATTR;
/

show errors

 GRANT EXECUTE ON LBACSYS.LDAP_ATTR_LIST to public;

CREATE TYPE LBACSYS.LDAP_EVENT AS OBJECT (                                
          event_type  VARCHAR2(32),
          event_id    VARCHAR2(32),
          event_src   VARCHAR2(1024),
          event_time  VARCHAR2(32),
          object_name VARCHAR2(1024),
          object_type VARCHAR2(32),
          object_guid VARCHAR2(32),
          object_dn   VARCHAR2(1024),
          profile_id  VARCHAR2(1024),
          attr_list   LBACSYS.LDAP_ATTR_LIST ) ;
/

GRANT EXECUTE ON LBACSYS.LDAP_EVENT to public;


CREATE TYPE LBACSYS.LDAP_EVENT_STATUS AS OBJECT (
          event_id          VARCHAR2(32),
          orclguid          VARCHAR(32),
          error_code        INTEGER,
          error_String      VARCHAR2(1024),
          error_disposition VARCHAR2(32)) ;
/

GRANT EXECUTE ON LBACSYS.LDAP_EVENT_STATUS to public;

-------------------------------------------------------------------------------
--
--  NAME        : OLS_DIP_NTFY
--  DESCRIPTION : This a notifier interface implemented by Label Security
--                to receive information about OLS related changes in OID
--                through the Directory integration provisioning system.
--
--
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.ols_dip_ntfy AS

    -- The Event Types

    USER_ADD                  CONSTANT VARCHAR2(32) := 'USER_ADD';
    USER_DELETE               CONSTANT VARCHAR2(32) := 'USER_DELETE';
    USER_MODIFY               CONSTANT VARCHAR2(32) := 'USER_MODIFY';

    GROUP_ADD                 CONSTANT VARCHAR2(32) := 'GROUP_ADD';
    GROUP_DELETE              CONSTANT VARCHAR2(32) := 'GROUP_DELETE';
    GROUP_MODIFY              CONSTANT VARCHAR2(32) := 'GROUP_MODIFY';

    IDENTITY_ADD              CONSTANT VARCHAR2(32) := 'IDENTITY_ADD';
    IDENTITY_DELETE           CONSTANT VARCHAR2(32) := 'IDENTITY_DELETE';
    IDENTITY_MODIFY           CONSTANT VARCHAR2(32) := 'IDENTITY_MODIFY';

    ENTRY_ADD              CONSTANT VARCHAR2(32) := 'ENTRY_ADD';
    ENTRY_DELETE           CONSTANT VARCHAR2(32) := 'ENTRY_DELETE';
    ENTRY_MODIFY           CONSTANT VARCHAR2(32) := 'ENTRY_MODIFY';

    SUBSCRIBER_ADD         CONSTANT VARCHAR2(32) := 'SUBSCRIBER_ADD';
    SUBSCRIBER_DELETE      CONSTANT VARCHAR2(32) := 'SUBSCRIBER_DELETE';
    SUBSCRIBER_MODIFY      CONSTANT VARCHAR2(32) := 'SUBSCRIBER_MODIFY';

    SUBSCRIPTION_ADD          CONSTANT VARCHAR2(32) := 'SUBSCRIPTION_ADD';
    SUBSCRIPTION_DELETE       CONSTANT VARCHAR2(32) := 'SUBSCRIPTION_DELETE';
    SUBSCRIPTION_MODIFY       CONSTANT VARCHAR2(32) := 'SUBSCRIPTION_MODIFY';

    -- The Attribute Type. Currently only Strings are Supported

    ATTR_TYPE_STRING          CONSTANT NUMBER  := 0;
    ATTR_TYPE_BINARY          CONSTANT NUMBER  := 1;

    -- The Attribute Modification Type

    MOD_ADD                   CONSTANT NUMBER  := 0;
    MOD_DELETE                CONSTANT NUMBER  := 1;
    MOD_REPLACE               CONSTANT NUMBER  := 2;

    -- The Event dispostions constants

    EVENT_SUCCESS             CONSTANT VARCHAR2(32)  := 'EVENT_SUCCESS';
    EVENT_ERROR               CONSTANT VARCHAR2(32)  := 'EVENT_ERROR';
    EVENT_RESEND              CONSTANT VARCHAR2(32)  := 'EVENT_RESEND';

    -- Error Code is 0 for SUCCESS and Non Zero for Errors and Resends

    -- The Actual Procedures

    -- PutOIDEvent : An Event from OID to Application DB. Gets back the Status 
    --               of the event as an OUT parameter

    PROCEDURE PutOIDEvent ( event          IN  LDAP_EVENT,
                            event_status   OUT LDAP_EVENT_STATUS);

    -- GetAppEvent :  An Event from Application DB to OID. Gets back the EVENT
    --                as an OUT parameter. DIP requesting the event with ID
    --                eventID passed as an IN OUT parameter. An Event is sent
    --                back and the eventID is set appropriately by 
    --                the function.

    FUNCTION GetAppEvent (eventID IN OUT VARCHAR2, 
                          event OUT LDAP_EVENT)
    RETURN NUMBER;

    -- the Return Value could be one of the following :

    EVENT_FOUND       CONSTANT NUMBER  := 0;
    EVENT_NOT_FOUND   CONSTANT NUMBER := 1403;

    PROCEDURE PutAppEventStatus (event_status IN LDAP_EVENT_STATUS);
 

END OLS_DIP_NTFY;
/

show errors;


CREATE PUBLIC SYNONYM LDAP_ATTR  FOR LBACSYS.LDAP_ATTR;

CREATE PUBLIC SYNONYM LDAP_ATTR_LIST FOR LBACSYS.LDAP_ATTR_LIST;

CREATE PUBLIC SYNONYM LDAP_EVENT FOR LBACSYS.LDAP_EVENT;

CREATE PUBLIC SYNONYM LDAP_EVENT_STATUS  FOR LBACSYS.LDAP_EVENT_STATUS;

-- 
--  $Header: zlasu.pkh 04-jan-2003.16:15:17 srtata Exp $
-- 
--  zlasu.pkh
-- 
--   Copyright (c) Oracle Corporation 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlasu.pkh - ZL Adapter Secure access end-User PacKage Header
-- 
--     DESCRIPTION
--       Contains the public interfaces for the Secure Access policy
--       adapter:
--           SA_USER_ADMIN - administration of user labels and program labels
--           SA_SESSION - session information (in varchar2) and session
--                    procedures for use from SQL
--           SA_UTL - session information (in lbac_label) and other
--                    Secure Access procedures for use from PL/SQL
--           PUBLIC "SA_" synonyms for LBAC admin packages
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     srtata      01/04/03 - fix bug 2735964
--     srtata      10/02/02 - add set_dip_debuglevel
--     srtata      09/07/01 - add WRITE_ONLY constant.
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     rsripada    10/09/00 - add drop_user
--     rsripada    10/06/00 - change default in add_groups/add_comps
--     vpesati     09/20/00 - new utility functions
--     vpesati     09/15/00 - TSP changes
--     cchui       08/21/00 - add merge_labels
--     rsripada    07/27/00 - remove user_label from sa_utl
--     rsripada    07/26/00 - rename become_user
--     rsripada    07/23/00 - api changes
--     rburns      04/17/00 - add max_read_label to sa_session and sa_utl
--     rburns      04/11/00 - store unexpanded user labels
--     cchui       03/31/00 - add sa_session and sa_utl label function, fix sa_
--     rburns      03/30/00 - consolidate sa_user_admin
--     rburns      03/08/00 - remove set_write_label
--     rburns      03/11/00 - change alter interfaces
--     rburns      03/07/00 - remove to_sa_label
--     rburns      02/27/00 - overload for numeric labels
--     rburns      02/23/00 - add interfaces for wrapper
--     rburns      02/06/00 - add program units
--     rburns      01/29/00 - add SA wrappers
--     cchui       01/27/00 - add alter_user_compartments and alter_user_groups
--     cchui       01/26/00 - add sa_user_labels.set_labels function
--     rburns      01/25/00 - add user label list function to sa_utl
--     cchui       01/20/00 - add more functions to sa_utl
--     rburns      01/19/00 - fix synonyms
--     cchui       01/14/00 - change function spec
--     cchui       01/11/00 - modify
--     rburns      01/07/00 - Created
                          
-------------------------------- SA_SYSDBA -----------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.sa_sysdba AS
--
-- This package is used by an administrator, with the SA_DBA role	
-- to create and maintain Secure Access policies in a database.
--

PROCEDURE create_policy (policy_name     IN VARCHAR2,
                         column_name     IN VARCHAR2 DEFAULT NULL,
                         default_options IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_policy (policy_name     IN VARCHAR2,
                        default_options IN VARCHAR2);

PROCEDURE drop_policy (policy_name IN VARCHAR2,
                       drop_column IN BOOLEAN DEFAULT FALSE);

PROCEDURE enable_policy (policy_name IN VARCHAR2);

PROCEDURE disable_policy (policy_name IN VARCHAR2);

PROCEDURE set_dip_debuglevel(level IN NUMBER);

END sa_sysdba;
/
show errors


-------------------------------- SA_SESSION ----------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.sa_session AS

FUNCTION privileges (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION privs (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION min_level (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION max_level (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION max_read_label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION max_write_label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION comp_read (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION comp_write (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION group_read (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION group_write (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION read_label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION write_label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION row_label (policy_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE set_label       (policy_name   IN VARCHAR2,
                           label         IN VARCHAR2);

PROCEDURE set_row_label   (policy_name   IN VARCHAR2,
                           label         IN VARCHAR2);

PROCEDURE save_default_labels    (policy_name   IN VARCHAR2);

PROCEDURE restore_default_labels (policy_name   IN VARCHAR2);

PROCEDURE set_access_profile(policy_name IN VARCHAR2,
                             user_name   IN VARCHAR2);

FUNCTION sa_user_name (policy_name IN VARCHAR2)
RETURN VARCHAR2;

END sa_session;
/
show errors


-------------------------------- SA_UTL --------------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.sa_utl AS

read_only  CONSTANT VARCHAR2(12) := 'READ_ONLY';
read_write CONSTANT VARCHAR2(12) := 'READ_WRITE';
write_only CONSTANT VARCHAR2(12) := 'WRITE_ONLY';

FUNCTION label (policy_name IN VARCHAR2)
RETURN lbac_label;

FUNCTION lbac_read_label (policy_name IN VARCHAR2)
RETURN lbac_label;

FUNCTION lbac_write_label (policy_name IN VARCHAR2)
RETURN lbac_label;

FUNCTION lbac_row_label (policy_name IN VARCHAR2)
RETURN lbac_label;

PROCEDURE set_label       (policy_name   IN VARCHAR2,
                           label         IN lbac_label);

PROCEDURE set_row_label   (policy_name   IN VARCHAR2,
                           label         IN lbac_label);

FUNCTION merge_label (label1 IN lbac_label,
                      label2 IN lbac_label,
                      merge_format IN VARCHAR2)
RETURN lbac_label;

FUNCTION greatest_lbound (label1 IN lbac_label,
                          label2 IN lbac_label)
RETURN lbac_label;

FUNCTION least_ubound (label1 IN lbac_label,
                       label2 IN lbac_label)
RETURN lbac_label;

FUNCTION dominates (label1 IN lbac_label,
                    label2 IN lbac_label)
RETURN BOOLEAN;

FUNCTION strictly_dominates (label1 IN lbac_label,
                             label2 IN lbac_label)
RETURN BOOLEAN;

FUNCTION dominated_by (label1 IN lbac_label,
                       label2 IN lbac_label)
RETURN BOOLEAN;

FUNCTION strictly_dominated_by (label1 IN lbac_label,
                                label2 IN lbac_label)
RETURN BOOLEAN;

FUNCTION numeric_label (policy_name IN VARCHAR2)
RETURN number;

FUNCTION numeric_read_label (policy_name IN VARCHAR2)
RETURN number;

FUNCTION numeric_write_label (policy_name IN VARCHAR2)
RETURN number;

FUNCTION numeric_row_label (policy_name IN VARCHAR2)
RETURN number;

FUNCTION check_read (policy_name IN VARCHAR2,
                     label       IN lbac_label)
RETURN number;

FUNCTION check_write (policy_name IN VARCHAR2,
                      label       IN lbac_label)
RETURN number;

FUNCTION check_label_change (policy_name IN VARCHAR2,
                             old_label   IN lbac_label,
                             new_label   IN lbac_label)
RETURN number;

PROCEDURE set_label       (policy_name   IN VARCHAR2,
                           label         IN number);

PROCEDURE set_row_label   (policy_name   IN VARCHAR2,
                           label         IN number);

FUNCTION merge_label (label1 IN number,
                      label2 IN number,
                      merge_format IN VARCHAR2)
RETURN number;

FUNCTION greatest_lbound (label1 IN number,
                          label2 IN number)
RETURN number;

FUNCTION least_ubound (label1 IN number,
                       label2 IN number)
RETURN number;

FUNCTION dominates (label1 IN number,
                    label2 IN number)
RETURN BOOLEAN;

FUNCTION strictly_dominates (label1 IN number,
                             label2 IN number)
RETURN BOOLEAN;

FUNCTION dominated_by (label1 IN number,
                       label2 IN number)
RETURN BOOLEAN;

FUNCTION strictly_dominated_by (label1 IN number,
                                label2 IN number)
RETURN BOOLEAN;

FUNCTION check_read (policy_name IN VARCHAR2,
                     label       IN NUMBER)
RETURN number;

FUNCTION check_write (policy_name IN VARCHAR2,
                      label       IN NUMBER)
RETURN number;

FUNCTION check_label_change (policy_name IN VARCHAR2,
                             old_label   IN number,
                             new_label   IN number)
RETURN number;

FUNCTION data_label(label IN LBAC_LABEL)
RETURN BOOLEAN;

FUNCTION data_label(label IN NUMBER)
RETURN BOOLEAN;

END sa_utl;
/
show errors

-------------------------------- SA_USER_ADMIN ------------------------------

CREATE OR REPLACE PACKAGE LBACSYS.sa_user_admin AS

PROCEDURE set_levels       (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2,
                            max_level        IN VARCHAR2,
                            min_level        IN VARCHAR2 DEFAULT NULL,
                            def_level        IN VARCHAR2 DEFAULT NULL,
                            row_level        IN VARCHAR2 DEFAULT NULL);
                            
PROCEDURE set_compartments (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2,
                            read_comps       IN VARCHAR2,
                            write_comps      IN VARCHAR2 DEFAULT NULL,
                            def_comps        IN VARCHAR2 DEFAULT NULL,
                            row_comps        IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_compartments (policy_name IN VARCHAR2,
                              user_name   IN VARCHAR2,
                              comps       IN VARCHAR2,
                              access_mode IN VARCHAR2 DEFAULT NULL,
                              in_def      IN VARCHAR2 DEFAULT NULL,
                              in_row      IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_groups       (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2,
                            read_groups      IN VARCHAR2,
                            write_groups     IN VARCHAR2 DEFAULT NULL,
                            def_groups       IN VARCHAR2 DEFAULT NULL,
                            row_groups       IN VARCHAR2 DEFAULT NULL);

PROCEDURE alter_groups (policy_name IN VARCHAR2,
                             user_name   IN VARCHAR2,
                             groups      IN VARCHAR2,
                             access_mode IN VARCHAR2 DEFAULT NULL,
                             in_def      IN VARCHAR2 DEFAULT NULL,
                             in_row      IN VARCHAR2 DEFAULT NULL);
                            
PROCEDURE add_compartments (policy_name  IN VARCHAR2,
                            user_name    IN VARCHAR2,
                            comps        IN VARCHAR2,
                            access_mode  IN VARCHAR2 DEFAULT SA_UTL.READ_ONLY,
                            in_def       IN VARCHAR2 DEFAULT 'Y',
                            in_row       IN VARCHAR2 DEFAULT 'N');

PROCEDURE drop_compartments (policy_name      IN VARCHAR2,
                             user_name        IN VARCHAR2,
                             comps            IN VARCHAR2);

PROCEDURE drop_all_compartments 
                           (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2);


PROCEDURE add_groups       (policy_name  IN VARCHAR2,
                            user_name    IN VARCHAR2,
                            groups       IN VARCHAR2,
                            access_mode  IN VARCHAR2 DEFAULT NULL,
                            in_def       IN VARCHAR2 DEFAULT NULL,
                            in_row       IN VARCHAR2 DEFAULT NULL);

PROCEDURE drop_groups      (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2,
                            groups           IN VARCHAR2);

PROCEDURE drop_all_groups  (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2);

PROCEDURE set_user_labels
                           (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2,
                            max_read_label   IN VARCHAR2,
                            max_write_label  IN VARCHAR2 DEFAULT NULL,
                            min_write_label  IN VARCHAR2 DEFAULT NULL,
                            def_label        IN VARCHAR2 DEFAULT NULL,
                            row_label        IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_default_label
                           (policy_name IN VARCHAR2,
                            user_name   IN VARCHAR2,
                            def_label   IN VARCHAR2);

PROCEDURE set_row_label
                           (policy_name IN VARCHAR2,
                            user_name   IN VARCHAR2,
                            row_label   IN VARCHAR2);

PROCEDURE drop_labels
                           (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2);

PROCEDURE set_user_privs (policy_name IN VARCHAR2,
                          user_name   IN VARCHAR2,
                          privileges  IN VARCHAR2);

PROCEDURE set_prog_privs (policy_name       IN VARCHAR2,
                          schema_name       IN VARCHAR2,
                          program_unit_name IN VARCHAR2,
                          privileges        IN VARCHAR2);

PROCEDURE drop_user_access (policy_name      IN VARCHAR2,
                            user_name        IN VARCHAR2);

FUNCTION user_labels (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION max_read_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION max_write_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION min_write_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION default_read_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION default_write_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION default_row_label (policy_name IN VARCHAR2, user_name IN VARCHAR2)
RETURN VARCHAR2;

END sa_user_admin;
/
show errors

-------------------------------- ADMIN Packages ------------------------------

CREATE PUBLIC SYNONYM sa_label_admin  FOR LBACSYS.lbac_label_admin;
CREATE PUBLIC SYNONYM sa_policy_admin FOR LBACSYS.lbac_policy_admin;
CREATE PUBLIC SYNONYM sa_audit_admin  FOR LBACSYS.lbac_audit_admin;



--
-- $Header: zlasc.pkh 08-apr-2001.11:42:47 gmurphy Exp $
--
-- zlasc.pkh
--
-- Copyright (c) Oracle Corporation 1999, 2000, 2001.  All rights reserved.
--
-- NAME
--    zlasc.pkh  - ZL Adapter SA SYS_CONTEXT PacKage Header
-- FUNCTION
--   SA Policy Adapter SYS_CONTEXT package specification
-- NOTES
--   Execute as LBACSYS or SYSDBA
-- MODIFIED
--   gmurphy 04/08/01 - add 2001 to copyright
--   gmurphy 02/26/01 - qualify objects for install as SYSDBA
--   gmurphy 02/02/01 - Merged gmurphy_ols_2rdbms
--   shwong  01/06/01 - overload set_user_privs with bitmask OUT
--   cchui   04/13/00 - add set_session_labels function
--   cchui   04/10/00 - add function to set regular sys context for user privil
--   rburns  02/28/00 - save become user name
--   rburns  02/11/00 - sys_context for session labels
--   rburns  01/19/00 - created
--
------------------------------------------------------------------------------


CREATE OR REPLACE PACKAGE LBACSYS.sa$ctx AS
--
-- This package maintains the SA SYS_CONTEXT variables:
--       INITIAL_LABEL     - used to set the initial session 
--                           read and write labels
--       INITIAL_ROW_LABEL - used to set the initial session row label
--
-- The SA$<pol>_X context is externally initialized and can be set
-- by the user with OCISetAttr function calls.

PROCEDURE set_initial_labels (policy_name IN VARCHAR2,
                              read_label  IN LBAC_LABEL,
                              row_label   IN LBAC_LABEL);

PROCEDURE get_initial_labels (policy_name IN VARCHAR2,
                              read_label  OUT LBAC_LABEL,
                              row_label   OUT LBAC_LABEL );

PROCEDURE set_user_name(policy_name IN VARCHAR2, user_name IN VARCHAR2);

FUNCTION get_user_name(policy_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE set_user_privs(policy_name IN VARCHAR2, privs IN LBAC_PRIVS);

PROCEDURE set_user_privs(policy_name IN VARCHAR2,
                         privs IN LBAC_PRIVS,
                         bitmask OUT PLS_INTEGER);

PROCEDURE set_session_labels(policy_name IN VARCHAR2,
                             labels      IN LBAC_LABEL_LIST);

END sa$ctx;
/


--  $Header: zlasdd.sql 30-jan-2003.10:52:21 srtata Exp $
-- 
--  zlasdd.sql
-- 
--   Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlasdd.sql - ZL Adapter Secure access create Data Dictionary
-- 
--     DESCRIPTION
--       Creates the SA data dictionary tables
--       Creates the SA SYS_CONTEXT
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     srtata      01/30/03 - increase privs field in saprofiles
--     srtata      01/21/03 - qualify with LBACSYS in insert stmts
--     srtata      01/11/03 - add constraint on saprofiles
--     shwong      01/07/03 - initialize rows in sadip_events
--     shwong      10/24/02 - change usr_name to 1024
--     srtata      10/31/02 - add sa$dip_events
--     srtata      10/02/02 - add table for profiles
--     srtata      08/27/01 - change contraint on sa$user_groups table.
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     04/02/01 - qualify REF objects
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/13/01 - change for upgrade script
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     rburns      03/06/00 - fix sysdba
--     rburns      02/21/00 - unique long names
--     rburns      02/11/00 - sys_context for session labels
--     rburns      02/06/00 - add sa_dba role
--     rburns      01/19/00 - fix context
--     cchui       01/13/00 - fix sa$user_groups
--     rburns      01/04/00 - Created
-- 

-- Create tables for levels, compartments, and groups
CREATE TABLE LBACSYS.sa$levels (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      level#  NUMBER(4)   NOT NULL,          /* sensitivity level */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      CONSTRAINT level_pk     PRIMARY KEY (pol#, level#),
      CONSTRAINT level_pol_fk FOREIGN KEY (pol#)
                              REFERENCES LBACSYS.lbac$pol ON DELETE CASCADE,
      CONSTRAINT level_range  CHECK (level# BETWEEN 0 AND 9999),
      CONSTRAINT level_short_unique 
                              UNIQUE (pol#, code),
      CONSTRAINT level_long_unique 
                              UNIQUE (pol#, name));

CREATE TABLE LBACSYS.sa$compartments (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      comp#   NUMBER(4)   NOT NULL,         /* compartment number */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      CONSTRAINT comp_pk     PRIMARY KEY (pol#, comp#),
      CONSTRAINT comp_pol_fk FOREIGN KEY (pol#)
                             REFERENCES LBACSYS.lbac$pol ON DELETE CASCADE,
      CONSTRAINT comp_range  CHECK (comp# BETWEEN 0 AND 9999),
      CONSTRAINT comp_short_unique 
                             UNIQUE (pol#, code),
      CONSTRAINT comp_long_unique 
                             UNIQUE (pol#, name));

CREATE TABLE LBACSYS.sa$groups (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      group#  NUMBER(4)   NOT NULL,         /* compartment number */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      parent# NUMBER(4),                   /* parent group number */   
      CONSTRAINT group_pk     PRIMARY KEY (pol#, group#),
      CONSTRAINT group_pol_fk FOREIGN KEY (pol#)
                              REFERENCES LBACSYS.lbac$pol ON DELETE CASCADE,
      CONSTRAINT group_parent FOREIGN KEY (pol#, parent#)
                              REFERENCES LBACSYS.sa$groups,
      CONSTRAINT group_range  CHECK (group# BETWEEN 0 AND 9999),
      CONSTRAINT group_short_unique 
                              UNIQUE (pol#, code),
      CONSTRAINT group_long_unique 
                              UNIQUE (pol#, name));

-- Create tables for user access authorizations for levels, 
--       compartments, and groups

CREATE TABLE LBACSYS.sa$user_levels (
      pol#      NUMBER       NOT NULL,    /* associated policy ID */
      usr_name  VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      max_level NUMBER(4),           /* maximum sensitivity level */
      min_level NUMBER(4),           /* minimum sensitivity level */
      def_level NUMBER(4), /* level for default read/write labels */
      row_level NUMBER(4),         /* level for default row label */
      CONSTRAINT user_level_pk PRIMARY KEY (pol#, usr_name),
      CONSTRAINT user_level_pol_fk FOREIGN KEY (pol#)
                             REFERENCES LBACSYS.lbac$pol ON DELETE CASCADE,
      CONSTRAINT user_max_fk FOREIGN KEY (pol#, max_level)
                             REFERENCES LBACSYS.sa$levels,
      CONSTRAINT user_min_fk FOREIGN KEY (pol#,min_level)
                             REFERENCES LBACSYS.sa$levels,
      CONSTRAINT user_def_fk FOREIGN KEY (pol#,def_level)
                             REFERENCES LBACSYS.sa$levels,
      CONSTRAINT user_row_fk FOREIGN KEY (pol#,row_level)
                             REFERENCES LBACSYS.sa$levels);

CREATE TABLE LBACSYS.sa$user_compartments (
      pol#      NUMBER       NOT NULL,    /* associated policy ID */
      usr_name  VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      comp#     NUMBER(4)    NOT NULL,      /* compartment number */
      rw_access NUMBER(2)    NOT NULL,         /* READ-0, WRITE-1 */
      def_comp  VARCHAR(1)   DEFAULT 'Y' NOT NULL,     /* Default */
      row_comp  VARCHAR(1)   DEFAULT 'Y' NOT NULL,   /* Row Label */
      CONSTRAINT user_comp_pk PRIMARY KEY (pol#, usr_name, comp#),
      CONSTRAINT user_comp_fk FOREIGN KEY (pol#, comp#)
                              REFERENCES LBACSYS.sa$compartments,
      CONSTRAINT user_comp_level_fk 
                              FOREIGN KEY (pol#, usr_name)
                              REFERENCES LBACSYS.sa$user_levels
                                ON DELETE CASCADE,
      CONSTRAINT user_comp_access CHECK (rw_access IN (0,1)),
      CONSTRAINT user_comp_def    CHECK (def_comp  IN ('Y','N')),
      CONSTRAINT user_comp_row    CHECK (row_comp  IN ('Y','N')));


CREATE TABLE LBACSYS.sa$user_groups (
      pol#       NUMBER       NOT NULL,    /* associated policy ID */
      usr_name   VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      group#     NUMBER(4)    NOT NULL,      /* compartment number */
      rw_access  NUMBER(2)    NOT NULL,         /* READ-0, WRITE-1 */
      def_group  VARCHAR(1)   DEFAULT 'Y' NOT NULL,     /* Default */
      row_group  VARCHAR(1)   DEFAULT 'Y' NOT NULL,   /* Row Label */
      CONSTRAINT user_grp_pk PRIMARY KEY (pol#, usr_name, group#),
      CONSTRAINT user_grp_fk FOREIGN KEY (pol#, group#)
                             REFERENCES LBACSYS.sa$groups,
      CONSTRAINT user_grp_level_fk 
                             FOREIGN KEY (pol#, usr_name)
                             REFERENCES LBACSYS.sa$user_levels
                               ON DELETE CASCADE,
      CONSTRAINT user_grp_access CHECK (rw_access IN (0,1,2)),
      CONSTRAINT user_grp_def    CHECK (def_group IN ('Y','N')),
      CONSTRAINT user_grp_row    CHECK (row_group  IN ('Y','N')));

-- The table sa$profiles stores the profiles which are created in the OID
-- It is populated when the events are propagated from OID to DIP and is
-- not directly used by the SA policy package.

CREATE TABLE LBACSYS.sa$profiles (
      policy_name     VARCHAR2(30)   NOT NULL,
      profile_name    VARCHAR2(30)   NOT NULL,
      max_read_label  VARCHAR2(4000),
      max_write_label VARCHAR2(4000),
      min_write_label VARCHAR2(4000),
      def_read_label  VARCHAR2(4000),
      def_row_label   VARCHAR2(4000),
      privs           VARCHAR2(256),
      CONSTRAINT profile_pk        PRIMARY KEY (policy_name, profile_name),
      CONSTRAINT profile_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.lbac$pol(pol_name) ON DELETE CASCADE);

-- The table sa$dip_debug stores information which assists in the 
-- debugging of event propagation from OID through DIP. It is populated 
-- by the DIP callback function when executed with a debug level greater
-- than 0.

CREATE TABLE LBACSYS.sa$dip_debug(
      event_id      VARCHAR2(32)  NOT NULL,
      objectdn      VARCHAR2(1024) NOT NULL,
      ols_operation VARCHAR2(50) );

-- The table sa$dip_events is needed to keep track of the DIP events
-- which have already been processed.

CREATE TABLE LBACSYS.sa$dip_events(
      event_id      VARCHAR2(32) NOT NULL,
      purpose       VARCHAR2(40) NOT NULL );

INSERT INTO LBACSYS.sa$dip_events values('0', 'LAST_PROCESSED_EVENT');
INSERT INTO LBACSYS.sa$dip_events values('0', 'BOOTSTRAP_END_EVENT');
-- 
--  $Header: zlasp.pkh 08-apr-2001.11:43:13 gmurphy Exp $
-- 
--  zlasp.pkh
-- 
--   Copyright (c) Oracle Corporation 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       zlasp.pkh - ZL Adpater Secure access Policy package
-- 
--     DESCRIPTION
--       Enforces the Secure Access Policy
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     vpesati     10/12/00 - add enforce_write
--     rsripada    09/28/00 - add get_audit_label
--     rsripada    09/25/00 - add get_row_label
--     psack       08/15/00 - Overload Enforce_Read and Write_allowed
--     rsripada    03/01/00 - change definition of set_audit_label
--     cchui       02/02/00 - modify bypass value
--     rburns      01/12/00 - add policy_name to label ops
--     rburns      01/04/00 - Created
-- 

CREATE OR REPLACE PACKAGE LBACSYS.lbac$sa AS 

------------------------------ create_policy --------------------------------

  PROCEDURE create_policy (policy_name    IN VARCHAR2,
                           column_name    IN OUT VARCHAR2,
                           default_format OUT VARCHAR2,
                           bin_label_size OUT PLS_INTEGER);

------------------------------ to_label -------------------------------------

  PROCEDURE to_label (policy_name    IN VARCHAR2,
                      label_string   IN  VARCHAR2,
                      format_string  IN  VARCHAR2,
                      binary_label   IN OUT lbac_bin_label,
                      internal_label OUT VARCHAR2);
  
-------------------------------- to_char -------------------------------------

  PROCEDURE from_label (binary_label   IN  lbac_bin_label,
                       internal_label IN  VARCHAR2,
                       format_string  IN  VARCHAR2,
                       label_string   OUT VARCHAR2);

------------------------------ compare_labels --------------------------------

  PROCEDURE compare_labels (blabel1    IN  lbac_bin_label, 
                            blabel2    IN  lbac_bin_label,
                            ilabel1    IN  VARCHAR2,
                            ilabel2    IN  VARCHAR2,
                            comparison OUT lbac_comps);

-------------------------------- validate_priv -------------------------------

 PROCEDURE validate_priv (privilege IN VARCHAR2, priv_num OUT PLS_INTEGER);

------------------------------ validate_format ------------------------------

  PROCEDURE validate_format (format IN VARCHAR2);
                              
------------------------------ label_names ----------------------------------

  PROCEDURE label_names (label_type  IN  PLS_INTEGER,
                         names       OUT lbac_name_list);
  
-------------------------------- priv_names ---------------------------------

  PROCEDURE priv_names (names OUT lbac_name_list);
   
--------------------------------- startup ------------------------------------

  PROCEDURE startup (policy_name  IN VARCHAR2,
                     dbname       IN VARCHAR2);
 
---------------------------------- logon -------------------------------------

  PROCEDURE logon (policy_name            IN VARCHAR2,
                   user_name              IN  VARCHAR2,
                   session_initial_privs  OUT lbac_privs,
                   session_initial_labels OUT lbac_label_list,
                   session_bypass         OUT PLS_INTEGER);
 
-------------------------- prog_invocation -----------------------------------

  PROCEDURE prog_invocation (
           policy_name            IN     VARCHAR2,   
           prog_privs             IN     lbac_privs,        
           prog_labels            IN     lbac_label_list,
           new_eff_privs          OUT    lbac_privs,        
           new_eff_initial_labels OUT    lbac_label_list,
           new_bypass             OUT PLS_INTEGER);

----------------------------- prog_termination -------------------------------

  PROCEDURE prog_termination (policy_name            IN     VARCHAR2);

------------------------- set_db_labels -------------------------------------
  PROCEDURE set_db_labels (policy_name   IN VARCHAR2,   
                           old_db_labels IN lbac_label_list,
                           new_db_labels IN lbac_label_list);

-------------------------- set_user_labels ----------------------------------

  PROCEDURE set_user_labels (policy_name   IN VARCHAR2,
                             old_user_labels IN lbac_label_list,
                             new_user_labels IN lbac_label_list);

--------------------------- set_prog_labels ---------------------------------

  PROCEDURE set_prog_labels (policy_name   IN VARCHAR2,
                             old_prog_labels IN lbac_label_list,
                             new_prog_labels IN lbac_label_list);
                                          
------------------------- set_effective_labels-------------------------------

  PROCEDURE set_effective_labels (
                           policy_name   IN VARCHAR2,
                           new_eff_labels  IN  lbac_label_list,
                           new_bypass      OUT PLS_INTEGER);

------------------------- set_effective_privs-------------------------------

  PROCEDURE set_effective_privs (
                           policy_name   IN VARCHAR2,
                           new_eff_privs   IN  lbac_privs,
                           new_bypass      OUT PLS_INTEGER);


------------------------- set_row_label ----------------------------

  PROCEDURE set_row_label (policy_name   IN VARCHAR2,
                           row_label  IN OUT lbac_label,
                           rule_label IN     lbac_label);
    
------------------------- get_row_label ----------------------------

  PROCEDURE get_row_label (policy_name   IN VARCHAR2,
                           row_label  IN OUT lbac_label);

------------------------- set_audit_label ----------------------------

  PROCEDURE set_audit_label (policy_id   IN PLS_INTEGER,
                             row_label   OUT    lbac_label);

------------------------- get_audit_label ----------------------------

  PROCEDURE get_audit_label (policy_name   IN VARCHAR2,
                             aud_label   IN OUT lbac_label);

---------------------------- enforce_read ---------------------------------


  FUNCTION enforce_read (policy_name   IN VARCHAR2,
                         row_label  IN lbac_label)
           RETURN INTEGER;

  FUNCTION enforce_read (policy_name   IN VARCHAR2,
                         row_ilabel    IN VARCHAR2)
           RETURN INTEGER;

-------------------------- enforce_write -----------------------------------

  FUNCTION enforce_write (policy_name   IN VARCHAR2,
                          row_label  IN lbac_label)
           RETURN INTEGER;

  FUNCTION enforce_write (policy_name   IN VARCHAR2,
                          row_ilabel  IN VARCHAR2)
           RETURN INTEGER;

-------------------------- enforce_insert -----------------------------------

  FUNCTION enforce_insert (policy_name   IN VARCHAR2,
                           new_row_label  IN lbac_label)
           RETURN INTEGER;

  FUNCTION enforce_insert (policy_name   IN VARCHAR2,
                           new_row_ilabel  IN VARCHAR2)
           RETURN INTEGER;

-------------------------- enforce_update -----------------------------------

  FUNCTION enforce_update (policy_name   IN VARCHAR2,
                           old_row_label  IN lbac_label)
           RETURN INTEGER;

  FUNCTION enforce_update (policy_name   IN VARCHAR2,
                           old_row_ilabel  IN VARCHAR2)
           RETURN INTEGER;

-------------------------- enforce_delete -----------------------------------

  FUNCTION enforce_delete (policy_name   IN VARCHAR2,
                           old_row_label  IN lbac_label)
           RETURN INTEGER;

  FUNCTION enforce_delete (policy_name   IN VARCHAR2,
                           old_row_ilabel  IN VARCHAR2)
           RETURN INTEGER;

--------------------- enforce_label_insert ----------------------------------

  PROCEDURE enforce_label_insert (policy_name   IN VARCHAR2,
                            new_row_label IN lbac_label);  
  
------------------------ enforce_label_update -------------------------------

  PROCEDURE enforce_label_update (policy_name   IN VARCHAR2,
              old_row_label     IN lbac_label,
              new_row_label     IN lbac_label);  

------------------------------ ddl_check ------------------------------------

  PROCEDURE ddl_check (policy_name   IN VARCHAR2,
              statement_type    IN PLS_INTEGER,
              object_type       IN PLS_INTEGER,
              object_name       IN VARCHAR2,
              owner             IN VARCHAR2);

END lbac$sa;
/
show errors
-- 
--  $Header: rdbms/src/server/security/ols/sa/zlasddv.sql /main/5 2009/03/23 10:25:40 skwak Exp $
-- 
--  zlasddv.sql
-- 
-- Copyright (c) 1999, 2009, Oracle and/or its affiliates. 
-- All rights reserved. 
-- 
--     NAME
--       zlasddv.sql - ZL Adapter Secure access create Data Dictionary Views
-- 
--     DESCRIPTION
--       Creates the SA data dictionary views
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     skwak       03/17/09 - add policy_subscribed column to dba_sa_policies
--     srtata      01/31/02 - fix user_labels field in views.
--     gmurphy     05/01/01 - qualify from clauses
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     04/02/01 - remove grants fro sysdba install
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     rsripada    10/30/00 - fix views
--     rsripada    10/13/00 - fix sa$pol and sa$admin views
--     rsripada    09/27/00 - use nls_substrb
--     vpesati     09/15/00 - TSP changes
--     vpesati     08/31/00 - fix all_sa_audit_options
--     cchui       08/21/00 - add public sa views
--     cchui       08/15/00 - Fix ALL_SA_LABELS
--     rsripada    07/12/00 - audit update
--     rsripada    05/11/00 - add options field to audit views
--     rburns      05/04/00 - fix all_sa_labels
--     rsripada    05/03/00 - add audit views
--     shwong      04/28/00 - fix dba_sa_user_levels
--     rburns      04/25/00 - use lbac views
--     rburns      04/17/00 - add programs view
--     rburns      04/12/00 - add views
--     vpesati     04/03/00 - remove orderby clause in views
--     rburns      03/30/00 - use SA_USER_ADMIN
--     rburns      03/07/00 - fix group view
--     rburns      03/02/00 - add dba_sa_policies
--     rburns      02/27/00 - add view for user_labels
--     rburns      02/21/00 - fix group view
--     rburns      02/15/00 - remove order column
--     rburns      02/04/00 - add all_sa_labels view, use short/long
--     rburns      01/30/00 - Add dba_sa_labels
--     rburns      01/20/00 - fix user_levels view
--     rburns      01/19/00 - Created
-- 

CREATE OR REPLACE VIEW LBACSYS.dba_sa_policies AS
   SELECT policy_name, column_name, status, policy_options, policy_subscribed
   FROM LBACSYS.dba_lbac_policies
   WHERE package = 'LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_schema_policies s
  WHERE p.policy_name=s.policy_name 
    AND p.package='LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_table_policies t
  WHERE p.policy_name=t.policy_name 
    AND p.package='LBAC$SA';


CREATE OR REPLACE VIEW LBACSYS.dba_sa_labels AS
   SELECT l.policy_name, label, label_tag, label_type
   FROM LBACSYS.dba_lbac_labels l, LBACSYS.dba_lbac_policies p
   WHERE l.policy_name = p.policy_name AND
         p.package = 'LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_data_labels AS
   SELECT l.policy_name, label, label_tag 
   FROM LBACSYS.dba_lbac_data_labels l, LBACSYS.dba_lbac_policies p
   WHERE l.policy_name = p.policy_name AND
         p.package = 'LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_levels AS
   SELECT p.pol_name AS policy_name, l.level# AS level_num, 
          l.code AS short_name, l.name AS long_name
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$levels l
   WHERE p.pol# = l.pol#;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_compartments AS
   SELECT p.pol_name AS policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$compartments c
   WHERE p.pol# = c.pol#;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_groups AS
   SELECT p.pol_name AS policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$groups g, LBACSYS.sa$groups pg
   WHERE p.pol# = g.pol# AND
         g.pol# = pg.pol# (+) AND
         g.parent# = pg.group#(+);

CREATE OR REPLACE VIEW LBACSYS.dba_sa_group_hierarchy AS
   SELECT l.pol_name AS policy_name, g.hierarchy_level, g.group_name
   FROM ( SELECT LEVEL AS hierarchy_level,
            RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
            pol# 
        FROM LBACSYS.sa$groups
        CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
        START WITH parent# IS NULL) g, lbac$pol l
   WHERE g.pol#=l.pol#;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name, 
          ul.usr_name AS user_name,
          lmax.code AS max_level, 
          lmin.code AS min_level, 
          ldef.code AS def_level, 
          lrow.code AS row_level
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$user_levels ul,
        LBACSYS.sa$levels lmax, LBACSYS.sa$levels lmin,
        LBACSYS.sa$levels ldef, LBACSYS.sa$levels lrow
   WHERE p.pol#=ul.pol# AND
         ul.pol#=lmax.pol# AND 
         ul.pol#=lmin.pol# AND 
         ul.pol#=ldef.pol# AND 
         ul.pol#=lrow.pol# AND 
         ul.max_level = lmax.level# AND
         ul.min_level = lmin.level# AND
         ul.def_level = ldef.level# AND
         ul.row_level = lrow.level#;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
        c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
        uc.def_comp, uc.row_comp
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$user_compartments uc,
        LBACSYS.sa$compartments c
   WHERE p.pol#=uc.pol# AND uc.pol#=c.pol# AND uc.comp# = c.comp#;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
        g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
        ug.def_group, ug.row_group
   FROM LBACSYS.lbac$pol p, LBACSYS.sa$user_groups ug, LBACSYS.sa$groups g
   WHERE p.pol#=ug.pol# AND ug.pol#=g.pol# AND ug.group# = g.group#;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_users AS
  SELECT user_name,  u.policy_name, user_privileges, 
         'MAX READ LABEL=''' || LABEL1 || ''',MAX WRITE LABEL=''' || LABEL2
         || ''',MIN WRITE LABEL=''' || LABEL3 || ''',DEFAULT READ LABEL=''' 
         || LABEL4 || ''',DEFAULT WRITE LABEL=''' || LABEL5 
         || ''',DEFAULT ROW LABEL=''' || LABEL6 || ''''
         AS user_labels,
         LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
         LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
         LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_users u
  WHERE p.policy_name=u.policy_name 
    AND p.package='LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_labels AS
  SELECT user_name,policy_name, user_labels as labels,
         MAX_READ_LABEL, MAX_WRITE_LABEL, MIN_WRITE_LABEL,
         DEFAULT_READ_LABEL, DEFAULT_WRITE_LABEL, DEFAULT_ROW_LABEL
  FROM LBACSYS.dba_sa_users
  WHERE MAX_READ_LABEL IS NOT NULL;

-- dba_sa_programs is a private view in 8.1.7 release
CREATE OR REPLACE VIEW LBACSYS.dba_sa_programs AS
  SELECT schema_name, program_name, p.policy_name, prog_privileges,
         prog_labels
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_programs g
  WHERE p.policy_name=g.policy_name 
    AND p.package='LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
  FROM LBACSYS.dba_sa_users 
  WHERE user_privileges IS NOT NULL;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_prog_privs AS
  SELECT schema_name, program_name, policy_name, 
         prog_privileges as program_privileges
  FROM LBACSYS.dba_sa_programs
  WHERE prog_privileges IS NOT NULL;

CREATE OR REPLACE VIEW LBACSYS.user_sa_session AS
  SELECT p.pol_name AS policy_name,
         sa_session.sa_user_name(p.pol_name)    AS sa_user_name,
         sa_session.privs(p.pol_name)           AS privs,
         sa_session.max_read_label(p.pol_name)  AS max_read_label,
         sa_session.max_write_label(p.pol_name) AS max_write_label,
         sa_session.min_level(p.pol_name)       AS min_level,
         sa_session.label(p.pol_name)           AS label,
         sa_session.comp_write(p.pol_name)      AS comp_write,
         sa_session.group_write(p.pol_name)     AS group_write,
         sa_session.row_label(p.pol_name)       AS row_label
  FROM LBACSYS.lbac$pol p
  WHERE p.package='LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.dba_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_audit_options a
  WHERE p.policy_name = a.policy_name AND
        p.package = 'LBAC$SA';

CREATE PUBLIC SYNONYM dba_sa_policies     FOR LBACSYS.dba_sa_policies;
CREATE PUBLIC SYNONYM dba_sa_labels       FOR LBACSYS.dba_sa_labels;
CREATE PUBLIC SYNONYM dba_sa_data_labels  FOR LBACSYS.dba_sa_data_labels;
CREATE PUBLIC SYNONYM dba_sa_levels       FOR LBACSYS.dba_sa_levels;
CREATE PUBLIC SYNONYM dba_sa_compartments FOR LBACSYS.dba_sa_compartments;
CREATE PUBLIC SYNONYM dba_sa_groups       FOR LBACSYS.dba_sa_groups;
CREATE PUBLIC SYNONYM dba_sa_group_hierarchy
                  FOR LBACSYS.dba_sa_group_hierarchy;
CREATE PUBLIC SYNONYM dba_sa_users          FOR LBACSYS.dba_sa_users;
CREATE PUBLIC SYNONYM dba_sa_user_levels    FOR LBACSYS.dba_sa_user_levels;
CREATE PUBLIC SYNONYM dba_sa_user_compartments
                  FOR LBACSYS.dba_sa_user_compartments;
CREATE PUBLIC SYNONYM dba_sa_user_groups    FOR LBACSYS.dba_sa_user_groups;
CREATE PUBLIC SYNONYM dba_sa_user_labels    FOR LBACSYS.dba_sa_user_labels;
CREATE PUBLIC SYNONYM dba_sa_user_privs     FOR LBACSYS.dba_sa_user_privs;
CREATE PUBLIC SYNONYM dba_sa_prog_privs     FOR LBACSYS.dba_sa_prog_privs;
CREATE PUBLIC SYNONYM user_sa_session       FOR LBACSYS.user_sa_session;
CREATE PUBLIC SYNONYM dba_sa_table_policies FOR LBACSYS.dba_sa_table_policies;
CREATE PUBLIC SYNONYM dba_sa_schema_policies
                  FOR LBACSYS.dba_sa_schema_policies;
CREATE PUBLIC SYNONYM dba_sa_audit_options  FOR LBACSYS.dba_sa_audit_options;

-- private views to Support All SA views

CREATE OR REPLACE VIEW LBACSYS.sa$pol AS
SELECT pol#,
       pol_name,
       column_name, 
       DECODE(bitand(flags,1),0,'DISABLED',1,'ENABLED','ERROR') AS status,
       default_format,
       policy_format,
       lbac_cache.option_string(options) AS policy_options,
       pol_role as Admin_Role
  FROM LBACSYS.lbac$pol
 WHERE package = 'LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.sa$admin AS
SELECT POL#, pol_name, granted_role admin_role, R.grantee usr_name
  FROM LBACSYS.lbac$pol P, 
       dba_role_privs R
 WHERE P.package = 'LBAC$SA' 
   AND R.granted_role = P.pol_role;
 
-- All public SA views   
-- The following views are intended for policy administrators.

CREATE OR REPLACE VIEW LBACSYS.all_sa_policies AS
   SELECT p.pol_name as policy_name, p.column_name, p.status, p.policy_options
     FROM LBACSYS.sa$pol p
    WHERE pol# in (select pol# from LBACSYS.sa$admin where usr_name=user);
  
CREATE OR REPLACE VIEW LBACSYS.all_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_schema_policies s
   WHERE p.pol_name = s.policy_name 
     AND pol# in (select pol# from LBACSYS.sa$admin where usr_name=user);

CREATE OR REPLACE VIEW LBACSYS.all_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_table_policies t
   WHERE p.pol_name=t.policy_name 
     AND pol# in (select pol# from LBACSYS.sa$admin where usr_name=user);
     
CREATE OR REPLACE VIEW LBACSYS.all_sa_data_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel AS label,
         lbac_label.to_tag(l.lab#) AS label_tag
   FROM LBACSYS.lbac$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol# 
    AND BITAND(l.flags, 1) = 1
    AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
         OR
         lbacsys.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);

CREATE OR REPLACE VIEW LBACSYS.all_sa_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel AS label,
         lbac_label.to_tag(l.lab#) AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
   FROM LBACSYS.lbac$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol# 
    AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
         OR
         LBACSYS.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);

-- The following views are intended for administrators and users

CREATE OR REPLACE VIEW LBACSYS.all_sa_levels AS
   SELECT p.pol_name as policy_name, l.level# AS level_num, 
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$levels l
    WHERE p.pol# = l.pol#       
      AND p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
    UNION          
   SELECT p.pol_name as policy_name, l.level# AS level_num, 
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$levels l, LBACSYS.sa$user_levels ul
    WHERE p.pol# = l.pol# 
      and l.pol# = ul.pol#
      and l.level# <= ul.max_level
      and ul.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(ul.pol#));
            
CREATE OR REPLACE VIEW LBACSYS.all_sa_compartments AS
   SELECT p.pol_name as policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$compartments c
    WHERE p.pol# = c.pol#
      and (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           OR
          (c.pol#,c.comp#) in (select pol#,comp# 
                               from LBACSYS.sa$user_compartments
                               where usr_name = sa_session.sa_user_name(
                                                 lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_groups AS
   SELECT p.pol_name as policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
     FROM LBACSYS.sa$pol p, LBACSYS.sa$groups g, LBACSYS.sa$groups pg
    WHERE p.pol# = g.pol# 
      AND g.pol# = pg.pol# (+) 
      AND g.parent# = pg.group#(+)
      and (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           OR
          (g.pol#,g.group#) in (select pol#,group# 
                                from LBACSYS.sa$user_groups
                                where usr_name = sa_session.sa_user_name(
                                                 lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_group_hierarchy AS
   SELECT p.pol_name as policy_name, g.hierarchy_level, g.group_name
     FROM (SELECT LEVEL AS hierarchy_level,
                  RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
                  pol# 
             FROM LBACSYS.sa$groups
                  CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
            START WITH ((pol# in (select pol# from LBACSYS.sa$admin
                                  where usr_name=user)
                         and parent# IS NULL)
                        or
                        (pol#,group#) in 
                        (select pol#,group# from LBACSYS.sa$user_groups
                          where usr_name = sa_session.sa_user_name(
                                           lbac_cache.policy_name(pol#))))
          ) g, 
          sa$pol p
    WHERE g.pol#=p.pol#;
    
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name, 
          ul.usr_name AS user_name,
          lmax.code AS max_level, 
          lmin.code AS min_level, 
          ldef.code AS def_level, 
          lrow.code AS row_level
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_levels ul, 
          LBACSYS.sa$levels lmax, LBACSYS.sa$levels lmin, 
          LBACSYS.sa$levels ldef, LBACSYS.sa$levels lrow
    WHERE p.pol#=ul.pol# 
      AND ul.pol#=lmax.pol#  
      AND ul.pol#=lmin.pol#  
      AND ul.pol#=ldef.pol#  
      AND ul.pol#=lrow.pol#  
      AND ul.max_level = lmax.level# 
      AND ul.min_level = lmin.level# 
      AND ul.def_level = ldef.level#
      AND ul.row_level = lrow.level# 
      AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           or
           ul.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));
        
                          
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
          c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
          uc.def_comp, uc.row_comp
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_compartments uc, 
          LBACSYS.sa$compartments c
    WHERE p.pol#=uc.pol# 
      AND uc.pol#=c.pol# 
      AND uc.comp# = c.comp#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           or
           uc.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));


CREATE OR REPLACE VIEW LBACSYS.all_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
          g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
          ug.def_group, ug.row_group
     FROM LBACSYS.sa$pol p, LBACSYS.sa$user_groups ug, LBACSYS.sa$groups g
    WHERE p.pol#=ug.pol# 
      AND ug.pol#=g.pol# 
      AND ug.group# = g.group#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           or
           ug.usr_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));

CREATE OR REPLACE VIEW LBACSYS.all_sa_users AS
   SELECT user_name,  u.policy_name, user_privileges,
          'MAX READ LABEL=''' || LABEL1 || ''',MAX WRITE LABEL=''' || LABEL2
          || ''',MIN WRITE LABEL=''' || LABEL3 || ''',DEFAULT READ LABEL='''
          || LABEL4 || ''',DEFAULT WRITE LABEL=''' || LABEL5
          || ''',DEFAULT ROW LABEL=''' || LABEL6 || ''''
          AS user_labels,
          LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
          LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
          LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
     FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_users u
    WHERE p.pol_name=u.policy_name
      AND (p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user)
           or
           u.user_name = sa_session.sa_user_name(lbac_cache.policy_name(p.pol#)));

CREATE OR REPLACE VIEW LBACSYS.all_sa_user_labels AS
   SELECT user_name,
          policy_name,
          user_labels as labels,
          MAX_READ_LABEL,
          MAX_WRITE_LABEL, MIN_WRITE_LABEL ,DEFAULT_READ_LABEL,
          DEFAULT_WRITE_LABEL ,  DEFAULT_ROW_LABEL
     FROM LBACSYS.all_sa_users
    WHERE MAX_READ_LABEL IS NOT NULL;

-- The following are intended for policy administrators only
-- all_sa_programs is a private view in 8.1.7 release
CREATE OR REPLACE VIEW LBACSYS.all_sa_programs AS
   SELECT schema_name, program_name, p.policy_name, prog_privileges,
          prog_labels
     FROM LBACSYS.sa$pol, LBACSYS.dba_lbac_programs p
    WHERE pol_name=p.policy_name 
      AND pol# in (select pol# from LBACSYS.sa$admin where usr_name=user);

CREATE OR REPLACE VIEW LBACSYS.all_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
    FROM LBACSYS.all_sa_users 
   WHERE user_privileges IS NOT NULL;

CREATE OR REPLACE VIEW LBACSYS.all_sa_prog_privs AS
  SELECT schema_name, program_name, policy_name, 
         prog_privileges as program_privileges
    FROM LBACSYS.all_sa_programs
   WHERE prog_privileges IS NOT NULL;

CREATE OR REPLACE VIEW LBACSYS.all_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_audit_options a
   WHERE p.pol_name = a.policy_name 
     AND p.pol# in (select pol# from LBACSYS.sa$admin where usr_name=user);

CREATE PUBLIC SYNONYM all_sa_policies      FOR LBACSYS.all_sa_policies;
CREATE PUBLIC SYNONYM all_sa_data_labels   FOR LBACSYS.all_sa_data_labels;
CREATE PUBLIC SYNONYM all_sa_levels        FOR LBACSYS.all_sa_levels;
CREATE PUBLIC SYNONYM all_sa_compartments  FOR LBACSYS.all_sa_compartments;
CREATE PUBLIC SYNONYM all_sa_groups        FOR LBACSYS.all_sa_groups;
CREATE PUBLIC SYNONYM all_sa_group_hierarchy
                  FOR LBACSYS.all_sa_group_hierarchy;
CREATE PUBLIC SYNONYM all_sa_users         FOR LBACSYS.all_sa_users;
CREATE PUBLIC SYNONYM all_sa_user_levels   FOR LBACSYS.all_sa_user_levels;
CREATE PUBLIC SYNONYM all_sa_user_compartments
                  FOR LBACSYS.all_sa_user_compartments;
CREATE PUBLIC SYNONYM all_sa_user_groups   FOR LBACSYS.all_sa_user_groups;
CREATE PUBLIC SYNONYM all_sa_user_labels   FOR LBACSYS.all_sa_user_labels;
CREATE PUBLIC SYNONYM all_sa_user_privs    FOR LBACSYS.all_sa_user_privs;
CREATE PUBLIC SYNONYM all_sa_prog_privs    FOR LBACSYS.all_sa_prog_privs;
CREATE PUBLIC SYNONYM all_sa_labels        FOR LBACSYS.all_sa_labels;
CREATE PUBLIC SYNONYM all_sa_table_policies
                  FOR LBACSYS.all_sa_table_policies;
CREATE PUBLIC SYNONYM all_sa_schema_policies
                  FOR LBACSYS.all_sa_schema_policies;
CREATE PUBLIC SYNONYM all_sa_audit_options  FOR LBACSYS.all_sa_audit_options;
-- 
--  $Header: sainc.sql 16-mar-2004.15:04:05 srtata Exp $
-- 
--  sainc.sql
-- 
--   Copyright (c) Oracle Corporation 1999, 2000, 2001. All Rights Reserved.
-- 
--     NAME
--       sainc.sql - ZL Adapter Secure Access 
-- 
--     DESCRIPTION
--       adds to lbac$installaitons
--       invokes the plb file
-- 
--     NOTES
--       Run as LBACSYS or SYSDBA
-- 
--     MODIFIED   (MM/DD/YY)
--     srtata      03/16/04 - select version from registry 
--     srtata      10/22/02 - update to 10.0.0.0.0
--     srtata      02/21/02 - update to 9.2.0.1.0.
--     shwong      10/10/01 - add OLS
--     gmurphy     04/08/01 - add 2001 to copyright
--     gmurphy     04/06/01 - change for 9.0.1 production
--     gmurphy     02/26/01 - qualify objects for install as SYSDBA
--     gmurphy     02/15/01 - update version number
--     gmurphy     02/13/01 - change for upgrade script
--     gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--     rsripada    09/14/00 - update version
--     cchui       05/03/00 - update version
--     rburns      02/15/00 - add insert to installations
--     rburns      01/18/00 - Created
-- 

-- Install Private SA Programs
@@prvtsa.plb

-- Note that SA has been installed
DELETE FROM LBACSYS.lbac$installations
WHERE component='SA';

BEGIN
INSERT INTO LBACSYS.lbac$installations values (
            'SA',
            'Secure Access',
            dbms_registry.release_version,
            'Secure Access '||dbms_registry.release_version || ' - Production',
            SYSDATE);

END;
/
