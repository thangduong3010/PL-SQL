Rem
Rem $Header: dbmshae.sql 06-jun-2006.09:13:51 kneel Exp $
Rem
Rem dbmshae.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmshae.sql - DBMS HA Event setup
Rem
Rem    DESCRIPTION
Rem      packages and libraries for HA events (FAN alerts)
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kneel       06/06/06 - removing auto-inserted SET commands 
Rem    kneel       06/01/06 - library & function creation for HA Events (FAN 
Rem                           alerts) 
Rem    kneel       06/01/06 - library & function creation for HA Events (FAN 
Rem                           alerts) 
Rem    kneel       06/01/06 - Created
Rem


/******************************************************************************

 HA ALERT ATTRIBUTES

 Fast Application Notification (FAN) defines a number of event attributes,
 some of which apply to all events, and others which apply only to certain
 events. Here, the attributes are listed along with the relevant events. Also,
 any notes on their usage (especially during submission) are included. More
 details on these events and attributes can be found in the FAN document listed
 in the RELATED DOCUMENTS section.

  HOST_NAME
  Used by: Node down, and instance, service member, service preconnect, and ASM
           instance up/down events
  Required: no default value

  DATABASE_DOMAIN
  Used by: All events except node down
  Default if unspecified at submission: domain of current database
 
  DATABASE_UNIQUE_NAME
  Used by: All events except node down
  Default if unspecified at submission: db_unique_name of current database

  INSTANCE_NAME
  Used by: Instance, service member, service preconnect, and ASM instance
           up/down events
  Required: no default value

  SERVICE_NAME
  Used by: Service, service member, and service preconnect up/down events
  Required: no default value

  INCARNATION
  Used by: node down
  Required: no default value

  CARDINALITY
  Used by: Service member up
  Required: no default value

******************************************************************************/



-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_HA_ALERT_LIB TRUSTED AS STATIC;
/



CREATE OR REPLACE PACKAGE dbms_ha_alerts AS
  
  /****************************************************************************
  * NAME
  *   get_XXX - Kernel High availability Notifications get alert attributes
  *
  * DESCRIPTION
  *   These routines are the PL/SQL public interface for getting attributes
  *   from HA alerts.
  * 
  * PARAMETER
  *  alert      - an HA alert to decompose
  *
  * RETURNS
  *  the appropriate attribute
  ****************************************************************************/
  FUNCTION get_service       (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_instance      (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_db_unique_name(alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_db_domain     (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_host          (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_incarnation   (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_cardinality   (alert ALERT_TYPE) RETURN BINARY_INTEGER;
  FUNCTION get_severity      (alert ALERT_TYPE) RETURN BINARY_INTEGER;
  FUNCTION get_event_time    (alert ALERT_TYPE)RETURN TIMESTAMP WITH TIME ZONE;
  FUNCTION get_reason        (alert ALERT_TYPE) RETURN VARCHAR2;
  FUNCTION get_version       (alert ALERT_TYPE) RETURN VARCHAR2;
  
END dbms_ha_alerts;
/



CREATE OR REPLACE PACKAGE dbms_ha_alerts_prvt AS
  
  /****************************************************************************
  * NAME
  *   post_ha_alert - Kernel High availability Notifications POST HA ALERT
  *
  * DESCRIPTION
  *   This routine is the PL/SQL public interface for posting HA alerts.
  *
  *   It calls keltpost() or keltpost_bg() in kelt.c after packaging the alert
  *   attributes appropriately.
  *
  *   It can call keltpost[_bg] up to three times:
  *    1. to clear old versions of same alert [optional]
  *    2. to post the alert (level = requested severity)
  *    3. to immediately clear the alert [optional]
  *
  *   The clearing calls can help ensure that this alert (or a following one)
  *   isn't rejected as duplicate of an earlier one.
  * 
  * PARAMETERS
  *
  *  reason_id           - taken from dbmsslrt.sql (e.g.
  *                        dbms_server_alert.RSN_FAN_DATABASE_DOWN)
  *                                                          
  *  same_transaction    - the post should occur in the caller's
  *                        transaction (which must already have been
  *                        started) [passes KELT_SAME_TRAN to keltpost].
  *                        Otherwise, a recursive transaction is
  *                        used [passes KELT_SEP_TRAN to keltpost].
  *                        Ignored KJHN_BACKGROUND_PROCESS is turned on.
  *                                                       
  *  clear_old_alert     - kjhn_post_ha_alert should clear any existing
  *                        version of the same alert before posting. This
  *                        helps ensure that the new alert won't be
  *                        rejected as duplicate.  Most users will
  *                        want to specify clear_old_alert => TRUE.
  *                        Note: calls keltpos[_bg] first w/ LEVEL_CLEAR,
  *                        then calls again with requested severity.
  *
  *  severity            - an integer severity level (such as critical), one of
  *                        dbms_server_alert.LEVEL_* (see dbmsslrt.sql).
  *                        Defaults to LEVEL_WARNING.
  *                       
  *  host_name           - the host that failed, or the host on which the
  *                        resource affected was run
  *                       
  *  event_reason        - a string indicating the reason the event occurred;
  *                        e.g. 'user' or 'unplanned'
  *                       
  *  event_time          - best approximation of time at which the event
  *                        occurred
  *                       
  *  database_domain     - FAN attributes representing the resource affacted.
  *  database_unique_name  Which attributes are needed depends on the
  *  instance_name         value of reason_id; see 'HA ALERT ATTRIBUTES' above.
  *  service_name        
  *  incarnation         
  *  cardinality         
  *                                                          
  *  event_id            - a numeric id used for avoiding duplicate events.
  *                        Most posters should use the default, unless they
  *                        wish to control the duplication of events;
  *                        e.g. if multiple nodes may post the same event.
  *                                                          
  *  metric_value        - value for metric associated with the event
  *                        (see kjhn2.h for list of alerts and their metrics).
  *                        Currently, no values are defined, so use default.
  *                                                          
  *  timeout_seconds     - minimum time to hold the event before timeout
  *                        allows duplicates to be submitted. Should be
  *                        left to the default for most posters.
  *                       
  *  immediate_timeout   - TRUE means clear alert immediately after posting,
  *                        thus avoiding conflict with later postings.
  *                        Recommended to be TRUE for most posters.
  *                        Choose FALSE if multiple nodes may post the same
  *                        event with the same event_id, to avoid duplication.
  *                                                             
  *                                                             
  *  background_process  - the actual queue posting should happen
  *                        asynchronously in MMON. Uses keltpost_bg()
  *                        rather than keltpost().
  *                                                        
  *  signal_internal     - if TRUE, signal some errors as internal errors;
  *                        if FALSE, use only normal errors
  *                                                        
  *  duplicates_ok       - silently ignore and discard events that duplicate
  *                        existing ones. Use to avoid duplicate if
  *                        multiple nodes will attempt to post the same event.
  *                        Most users will not want to set this.
  *
  * NOTES
  *   An event is considered a duplicate if it shares the following
  *   attributes with an event that has not yet timed out:
  *    reason_id
  *    event_id
  *    object_id (generally, the name hash of the service or database service)
  *
  *   This means that two events with different event time, incarnation, etc.
  *   will still be treated as equivalent.
  *
  ****************************************************************************/
  PROCEDURE post_ha_alert(reason_id             IN dbms_server_alert.
                                                   reason_id_t,
                          same_transaction      IN BOOLEAN,
                          clear_old_alert       IN BOOLEAN,
                          severity              IN dbms_server_alert.
                                                   SEVERITY_LEVEL_T
                                                   DEFAULT
                                                   dbms_server_alert.
                                                   LEVEL_WARNING,
                          database_domain       IN VARCHAR2 DEFAULT
                                                   SYS_CONTEXT('USERENV',
                                                               'DB_DOMAIN'),
                          database_unique_name  IN VARCHAR2 DEFAULT NULL,
                          instance_name         IN VARCHAR2 DEFAULT NULL,
                          service_name          IN VARCHAR2 DEFAULT NULL,
                          host_name             IN VARCHAR2 DEFAULT NULL,
                          incarnation           IN VARCHAR2 DEFAULT NULL,
                          event_reason          IN VARCHAR2,
                          event_time            IN TIMESTAMP WITH TIME ZONE,
                          cardinality           IN BINARY_INTEGER DEFAULT NULL,
                          event_id              IN NUMBER DEFAULT NULL,
                          metric_value          IN NUMBER DEFAULT NULL,
                          timeout_seconds       IN BINARY_INTEGER DEFAULT NULL,
                          immediate_timeout     IN BOOLEAN DEFAULT TRUE,
                          background_process    IN BOOLEAN DEFAULT FALSE,
                          signal_internal       IN BOOLEAN DEFAULT TRUE,
                          duplicates_ok         IN BOOLEAN DEFAULT FALSE);



  -- THE FOLLOWING FOR KJHN INTERNAL USE ONLY [see body for details] --
  
  FUNCTION  post_instance_up RETURN VARCHAR2;

  FUNCTION  check_ha_resources RETURN VARCHAR2;

  PROCEDURE clear_instance_resources(database_domain      IN VARCHAR2, 
                                     database_unique_name IN VARCHAR2, 
                                     instance_name        IN VARCHAR2,
                                     event_time           IN TIMESTAMP 
                                                             WITH TIME ZONE);
  
  /****************************************************************************
  *
  * Convert a startup time from v$instance/gv$instance to a timestamp
  * with time zone, so it can pe stored persistently and compared
  * safely with other timestamps.
  *
  ****************************************************************************/
  FUNCTION instance_startup_timestamp_tz(startup_time DATE)
  RETURN TIMESTAMP WITH TIME zone;
  

END dbms_ha_alerts_prvt;
/



Rem Create library which contains all 3gl callouts for HA Event Notification
CREATE OR REPLACE LIBRARY DBMS_HAEVENTNOT_PRVT_LIB TRUSTED AS STATIC;
/

Rem Define a transformation procedure to be used during notification
create or replace function haen_txfm_text(
             message in sys.alert_type) return VARCHAR2 IS
EXTERNAL
NAME "kpkhetp"
WITH CONTEXT
PARAMETERS(context,
           message, message  indicator  struct,
           RETURN OCISTRING)      
LIBRARY DBMS_HAEVENTNOT_PRVT_LIB;
/
