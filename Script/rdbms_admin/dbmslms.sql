Rem
Rem $Header: dbmslms.sql 07-oct-2005.11:29:49 smangala Exp $
Rem
Rem dbmslmi.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmslmi.sql - logmnr_session package description
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smangala   10/07/05 - code coverage 
Rem    mtao       11/24/04 - bug: 3953131, add batch_rows to purge_session
Rem    ajadams    10/17/03 - signature change for mine functions 
Rem    ajadams    01/08/03 - clean up purge routines
Rem    abrown     11/20/02 - Add session_name to clone_context
Rem    ajadams    10/07/02 - remove Adhoc CDC support - separate_undo_redo
Rem    jkundu     10/11/02 - purge_session_to_scn param name change
Rem    jkundu     08/19/02 - change signature of krvics
Rem    mtao       09/30/02 - add purge_session_to_scn
Rem    smangala   01/28/02 - add purge_session
Rem    bgarin     01/08/02 - change session to private package
Rem    abrown     09/17/01 - Add record global name option to krvxcs
Rem    ajadams    09/20/01 - new dict option - NO_DDL_TRACKING
Rem    smangala   08/30/01 - Add support for clone context.
Rem    ajadams    08/21/01 - CREATE_FLAG_TRACK_AUDIT_INFO no longer needed
Rem    jkundu     07/27/01 - filter_none flag in create_session
Rem    qiwang     07/18/01 - add flag for audit info tracking
Rem    smangala   03/19/01 - Add ALLOW_MULTIPLE constant.
Rem    qiwang     03/14/01 - Correct long names in previous check-in.
Rem    jkundu     03/12/01 - adding new options to create_session
Rem    ajadams    08/24/00 - add mine() functions
Rem    ajadams    09/19/00 - add mine functions
Rem    ajadams    09/18/00 - add mine functions
Rem    ajadams    07/12/00 - move activate_session to debug package
Rem    ajadams    07/10/00 - rename cancel_select to stop_session
Rem    ajadams    06/13/00 - Creation
Rem


CREATE OR REPLACE PACKAGE sys.dbms_logmnr_session as

-----------------------------------
-- SUBTYPES and related CONSTANTS
--

-- constants for create_session
--
CREATE_FLAG_TRANSIENT_SESSION      CONSTANT NUMBER := 1;
CREATE_FLAG_UNCOMMITTED_DATA       CONSTANT NUMBER := 8;
CREATE_FLAG_WAIT_FOR_LOG           CONSTANT NUMBER := 16;
CREATE_FLAG_SKIP_CORRUPTION        CONSTANT NUMBER := 32;
CREATE_FLAG_ALLOW_MISSING_LOG      CONSTANT NUMBER := 64;
CREATE_FLAG_ALLOW_MULTIPLE         CONSTANT NUMBER := 128;
CREATE_FLAG_IGNORE_CONSISTENCY     CONSTANT NUMBER := 256;
CREATE_FLAG_NO_DICT_DDL_TRACK      CONSTANT NUMBER := 1024;
CREATE_FLAG_AUTO_ADD_ARCHIVED      CONSTANT NUMBER := 65536;
CREATE_FLAG_AUTO_ADD_ONLINE        CONSTANT NUMBER := 131072;
CREATE_FLAG_DISCARD_ROLLBACK       CONSTANT NUMBER := 16777216;
CREATE_FLAG_DISCARD_INTERNAL       CONSTANT NUMBER := 33554432;
CREATE_FLAG_FILTER_ALL             CONSTANT NUMBER := 67108864;
CREATE_FLAG_ENABLE_CKPT            CONSTANT NUMBER := 268435456;
CREATE_FLAG_RECORD_GLOBALNAME      CONSTANT NUMBER := 1073741824;

-- constants for set_dict_attr
--
DICT_FLAG_GENERATE_HEX             CONSTANT NUMBER := 0;
DICT_FLAG_REDO_LOGS                CONSTANT NUMBER := 1;
DICT_FLAG_ONLINE_CATALOG           CONSTANT NUMBER := 2;
DICT_FLAG_FLAT_FILE                CONSTANT NUMBER := 3;


-------------
-- PROCEDURES 
--

PROCEDURE create_session(
     client_id          IN  NUMBER default 0,
     db_id              IN  NUMBER default 0,
     reset_scn          IN  NUMBER default 0,
     reset_timestamp    IN  NUMBER default 0,
     flags              IN  NUMBER default 0,
     global_dbname      IN  VARCHAR2 default '',
     session_name       IN  VARCHAR2,
     session_id         OUT NUMBER);


PROCEDURE attach_session(
     session_id         IN  NUMBER default 0);


PROCEDURE set_session_params(
     session_id         IN  NUMBER default 0,
     num_process        IN  NUMBER default 0,
     memory_size        IN  NUMBER default 10,
     max_log_lookback   IN  NUMBER default 4294967295);


PROCEDURE set_dict_attr(
     session_id         IN  NUMBER default 0,
     dict_attr          IN  NUMBER default DICT_FLAG_REDO_LOGS,
     dict_file          IN  VARCHAR2 default '');


PROCEDURE prepare_scn_range(
     session_id         IN  NUMBER default 0,
     start_scn          IN  NUMBER default 0,
     end_scn            IN  NUMBER default 0);


PROCEDURE release_scn_range(
     session_id         IN  NUMBER default 0,
     end_scn            IN  NUMBER default 0);


PROCEDURE detach_session(
     session_id         IN  NUMBER default 0);


PROCEDURE destroy_session(
     session_id         IN  NUMBER default 0);


PROCEDURE add_log_file(
     session_id         IN  NUMBER default 0,
     logfile_name       IN  VARCHAR2 default '');


PROCEDURE remove_log_file(
     session_id         IN  NUMBER default 0,
     logfile_name       IN  VARCHAR2 default '');


FUNCTION mine_value(
     sql_redo_undo      IN  NUMBER,
     column_name        IN  VARCHAR2 default '') RETURN VARCHAR2;


FUNCTION column_present(
     sql_redo_undo      IN  NUMBER,
     column_name        IN  VARCHAR2 default '') RETURN BINARY_INTEGER;


/******************************************************************************
 *
 * NAME
 *   clone_context
 *
 * DESCRIPTION
 *   Clone an existing LogMiner persistent context.  The specified persistent
 *   context is duplicated and its session# is returned.  The new context
 *   shares the dictionary with the parent context.  If the specified SCN is
 *   zero (default) or there are no valid checkpoints at or below it then the
 *   new context is created with start_scn of the parent context.
 *
 *   With the exception of session# and session_name the new context inherits
 *   all attributes of the parent context and may itself be subsequently
 *   cloned.  The shared dictionary is kept intact as long as there are
 *   sharers.
 *
 * PARAMETERS
 *   session_id    IN: The session# of context to be duplicated.
 *   new_session_name IN: The unique name to be given to the cloned session.
 *   scn           IN: SCN at or above a checkpoint where the new context is
 *                     to be started.  By default, the new context starts at
 *                     the start_scn of the parent context.
 * TRANSACTION
 *   Autonomous
 *
 * ERRORS
 *   Error conditions are raised.
 */
FUNCTION clone_context(
     session_id         IN  NUMBER,
     new_session_name   IN  VARCHAR2,
     scn                IN  NUMBER default 0) RETURN NUMBER;

/******************************************************************************
 *
 * NAME
 *   purge_session
 *
 * DESCRIPTION
 * PARAMETERS
 *   session_id    IN: The session# of context to be purged.
 *   scn           IN: SCN below which all checkpoints and log entries
 *                     are to be purged.
 * TRANSACTION
 *   Autonomous
 *
 * ERRORS
 *   Error conditions are raised.
 */
PROCEDURE purge_session(
     session_id         IN  NUMBER default 0,
     scn                IN  NUMBER default 0,
     batch_rows         IN  NUMBER default 2500);

END dbms_logmnr_session;
/
show errors

grant execute on dbms_logmnr_session to execute_catalog_role;
