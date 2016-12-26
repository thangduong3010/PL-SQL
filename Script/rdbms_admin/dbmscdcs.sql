Rem
Rem $Header: dbmscdcs.sql 15-mar-2006.11:31:54 mbrey Exp $
Rem
Rem dbmscdcs.sql
Rem
Rem Copyright (c) 2000, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmscdcs.sql - Public interface for the Change Data Capture Subscriber
Rem
Rem    DESCRIPTION
Rem      defines specificiation for package dbms_cdc_subscribe
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbrey       03/15/06 - 11gR1 API changes
Rem    pabingha    07/22/03 - remove name generation
Rem    pabingha    02/21/03 - update comments
Rem    pabingha    12/12/02 - 9i i/f compatability
Rem    wnorcott    08/23/02 - remove tabs
Rem    wnorcott    08/22/02 - rename get_subscription_handle to 
Rem                              create_subscription
Rem    wnorcott    07/26/02 - Bill Norcott compile
Rem    wnorcott    07/25/02 - named subscriptions
Rem    wnorcott    07/18/02 - fix
Rem    wnorcott    07/18/02 - grabtrans 'mbrey_view'
Rem    mbrey       07/15/02 - 10i subscriber view changes
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    wnorcott    10/26/00 - Bug 1477568 rid trailing slash
Rem    wnorcott    06/19/00 - synonyms for dbms_logmnr_cdc
Rem    jgalanes    04/07/00 - Adding parameters to Extend_Window_List
Rem    mbrey       03/27/00 - adding grants
Rem    mbrey       01/26/00 - adding /
Rem    mbrey       01/26/00 - add subscriber procedures
Rem    mbrey       01/26/00 - Created
Rem

CREATE OR REPLACE PACKAGE DBMS_CDC_SUBSCRIBE AS

------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_SUBSCRIBE.CREATE_SUBSCRIPTION
--
--  Purpose: Obtains a subscription name to be passed to all the other
--  subscription APIs
--
--  PROCEDURE DBMS_CDC_SUBSCRIBE.SUBSCRIBE
--
--  Purpose: Registers interest in a published source table or publication and
--  subscribes to those changes.
--
--  PROCEDURE DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION
--
--  Purpose: Activates a subscription, making it ready to receive change data.
--
--                          PARAMETERS
--
--  change_set: The name of an existing change set
--
--  description: A description of the subscription and what it will be used for
--
--  subscription_name: Subscription name for a given subscription.
--
--  source_schema: Schema name where source tables reside
--
--  source_table: Name of a published source table
--
--  column_list: A comma-separated list of columns from the published 
--  source table
--
--  publication_id: A specific publication ID (often used to distinguish
--  multiple publications on the same source_schema/source_table).
--
--  subscriber_view: Optional name of the subscriber view for subscription
--  to a particular source_schema/source_table or publication ID.
--
--                  EXCEPTION DESCRIPTION
--
--
------------------------------------------------------------------------------
--  PROCEDURE DBMS_CDC_SUBSCRIBE.EXTEND_WINDOW
--
--  Purpose: This procedure sets the high water mark of the subscription
--  window, thus permitting newly added change data to be seen.
--
--  PROCEDURE DBMS_CDC_SUBSCRIBE.PURGE_WINDOW
--
--  Purpose: Sets the low water mark equal to the high water mark for
--  this subscription window.  The subscription can no longer see any of the
--  old change data.
--
--  PROCEDURE DBMS_CDC_SUBSCRIBE.DROP_SUBSCRIPTION
--
--  Purpose: Remove an existing subscription.
--
--                          PARAMETERS
--
--  subscription_name: Name of an existing subscription
--
--
--                  EXCEPTION DESCRIPTION
--
--
------------------------------------------------------------------------------

--
-- 10i subscriber interface
--

 PROCEDURE create_subscription (change_set_name    IN VARCHAR2,
                                description       IN VARCHAR2,
                                subscription_name IN VARCHAR2);

 PROCEDURE subscribe (subscription_name IN VARCHAR2,
                      source_schema     IN VARCHAR2,
                      source_table      IN VARCHAR2,
                      column_list       IN VARCHAR2,
                      subscriber_view   IN VARCHAR2);

 PROCEDURE subscribe (subscription_name IN VARCHAR2,
                      publication_id    IN NUMBER,
                      column_list       IN VARCHAR2,
                      subscriber_view   IN VARCHAR2);

 PROCEDURE activate_subscription (subscription_name IN VARCHAR2);

 PROCEDURE extend_window (subscription_name IN VARCHAR2,
                          upper_bound IN DATE DEFAULT NULL);

 PROCEDURE purge_window (subscription_name IN VARCHAR2,
                         lower_bound IN DATE DEFAULT NULL);

 PROCEDURE drop_subscription (subscription_name IN VARCHAR2);


--
-- 9i subscriber interface - deprecated
--

 PROCEDURE get_subscription_handle (change_set          IN VARCHAR2,
                                    description         IN VARCHAR2,
                                    subscription_handle OUT NUMBER);

 PROCEDURE subscribe (subscription_handle IN NUMBER,
                      source_schema       IN VARCHAR2,
                      source_table        IN VARCHAR2,
                      column_list         IN VARCHAR2);

 PROCEDURE subscribe (subscription_handle  IN NUMBER,
                      publication_id       IN NUMBER,
                      column_list          IN VARCHAR2);

 PROCEDURE activate_subscription (subscription_handle  IN NUMBER);

 PROCEDURE extend_window (subscription_handle  IN NUMBER);

 PROCEDURE prepare_subscriber_view (subscription_handle IN NUMBER,
                                    source_schema       IN VARCHAR2,
                                    source_table        IN VARCHAR2,
                                    view_name           OUT VARCHAR2);

 PROCEDURE drop_subscriber_view (subscription_handle IN NUMBER,
                                 source_schema       IN VARCHAR2,
                                 source_table        IN VARCHAR2);

 PROCEDURE purge_window (subscription_handle  IN NUMBER);

 PROCEDURE drop_subscription (subscription_handle  IN NUMBER);

END DBMS_CDC_SUBSCRIBE;
/

GRANT EXECUTE ON sys.dbms_cdc_subscribe TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dbms_cdc_subscribe FOR sys.dbms_cdc_subscribe;
CREATE OR REPLACE PUBLIC SYNONYM dbms_logmnr_cdc_subscribe
   FOR sys.dbms_cdc_subscribe;

