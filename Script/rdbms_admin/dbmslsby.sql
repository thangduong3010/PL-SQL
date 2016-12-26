Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmslsby.sql - DBMS Logical StandBY
Rem
Rem    DESCRIPTION
Rem      dbms_logstdby package definition.
Rem      Used for administering Logical Standby
Rem
Rem    NOTES
Rem      execution requires logstdby_administrator role
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    svivian     12/29/09 - bug 8846600: disallow instantiate_table if
Rem                           EDS-maintained
Rem    svivian     03/26/09 - add EDS
Rem    dvoss       03/19/09 - bug 8350972 - ku_noexp_tab not yet created
Rem    dvoss       03/11/09 - do not export role
Rem    ajadams     12/02/08 - remove unused db_role proc
Rem    rmacnico    05/28/08 - add db_role
Rem    ajadams     03/03/08 - add db_is_logstdby
Rem    rmacnico    12/17/07 - bug 6470986: dbms_logstdby.is_apply_server
Rem    rmacnico    05/24/07 - bug 5666482: map primary scn
Rem    rmacnico    12/28/06 - Remove instantiate feature in 11g
Rem    rburns      08/23/06 - add library
Rem    rmacnico    04/20/06 - Add kernal PL/SQL support
Rem    ajadams     08/24/05 - move internal and safe_scn package to new files 
Rem    sslim       05/27/05 - new addition: prepare_for_new_primary 
Rem    ajadams     05/04/05 - remove stop_on_ddl 
Rem    ajadams     05/02/05 - dbms_logstdby_public now deprecated 
Rem    ajadams     04/15/05 - move internal package out
Rem    ajadams     09/01/04 - corrupted dictionary fixup support 
Rem    sslim       08/13/04 - New prototype for rebuild 
Rem    jnesheiw    08/03/04 - Remove grant of CONNECT role to 
Rem                           LOGSTDBY_ADMINISTRATOR 
Rem    sslim       06/06/04 - fast failover: dbms_logstdby.rebuild
Rem    mtao        05/31/04 - add verify_session_logautodelete for internal use
Rem    sslim       05/25/04 - add end_stream_shared internal routine
Rem    ajadams     04/28/04 - add update_dynamic_lsby_options 
Rem    sslim       04/13/04 - obsolete: get_mtime 
Rem    raguzman    04/16/04 - max_event_records 
Rem    jkundu      11/07/03 - add purge session 
Rem    mtao        10/17/03 - lock set_tablespace, bug: 2921044
Rem    wfisher     10/03/03 - Add version parameters to need_scn 
Rem    gmulagun    09/11/03 - change type of audit PROCESS# column
Rem    htran       06/01/03 - set_export_scn: add original schema and name
Rem    raguzman    06/20/03 - dbms_logstdby should be invokers rights
Rem    raguzman    06/17/03 - fix up logstdby.set_export_scn param names
Rem    htran       05/05/03 - add set_session_state.
Rem                           add flashback_scn to get_export_dml_scn
Rem    gmulagun    03/27/03 - bug 2822534: rename tran_id to xid
Rem    raguzman    01/22/03 - new col names for seq* aud* par* job* procs
Rem    sslim       12/31/02 - 1110668: correct end_stream
Rem    jmzhang     12/31/02  - update audins, audel, audupd 
Rem    jmzhang     11/13/02 -  update audins, auddel, audupd
Rem    sslim       10/15/02 - zero data loss historian prototypes
Rem    dvoss       10/18/02 - add set_tablespace
Rem    rguzman     10/07/02 - declare history record procedures
Rem    jmzhang     09/23/02 - declare dbms_internal_safe_scn
Rem    rguzman     10/01/02 - skip using like feature
Rem    jnesheiw    09/03/02 - create DBMS_LOGSTDBY_PUBLIC package
Rem    jnesheiw    07/23/02 - grant connect, resource to logstdby_administrator
Rem    jmzhang     08/20/02 - declare unskip(one para)
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    jnesheiw    10/31/01 - fix audins.
Rem    rguzman     10/11/01 - Using internal logmnr interface, drop some procs
Rem    sslim       09/25/01 - Logminer dictionary build as a background process
Rem    sslim       09/04/01 - Mods due new procedures with additional arguments
Rem    rguzman     08/31/01 - Add guard check
Rem    jnesheiw    09/13/01 - Add stop_on_ddl support.
Rem    jnesheiw    08/07/01 - change UTL_LOGSTDBY to DBMS_INTERNAL_LOGSTDBY.
Rem    rguzman     06/19/01 - Add verify_nosession.
Rem    sslim       04/11/01 - Add parins/parupd/pardel procedures
Rem    sslim       02/21/01 - Add procedure to prepare user statement for apply
Rem    jdavison    12/01/00 - Drop extra semicolons
Rem    rguzman     09/12/00 - Handle new flags column for sequences
Rem    svivian     07/27/00 - single table instantiation
Rem    svivian     06/01/00 - delete from job queue
Rem    svivian     05/31/00 - jobupd added
Rem    svivian     05/26/00 - add hidden columns to jobq
Rem    rguzman     05/19/00 - Adding apply_set/unset
Rem    svivian     04/20/00 - continue work on sequences
Rem    svivian     04/18/00 - add callout to set logical apply mode
Rem    svivian     03/31/00 - sequence support
Rem    svivian     03/22/00 - add test_jqc
Rem    svivian     03/13/00 - procedures for audit change record processing
Rem    svivian     02/25/00 - Created
Rem



--
--
-- procedures for administering Logical Standby
--
--
CREATE OR REPLACE PACKAGE sys.dbms_logstdby AUTHID CURRENT_USER IS
   
-- Skip procedure constants   
SKIP_ACTION_SKIP    CONSTANT NUMBER :=  1;
SKIP_ACTION_APPLY   CONSTANT NUMBER :=  0;
SKIP_ACTION_REPLACE CONSTANT NUMBER := -1;
SKIP_ACTION_ERROR   CONSTANT NUMBER := -2;
SKIP_ACTION_NOPRIVS CONSTANT NUMBER := -3;

-- maximum event records that can be recorded in dba_logstdby_events
MAX_EVENTS          CONSTANT NUMBER := 2000000000;

--
-- NAME: apply_set
--
-- DESCRIPTION:
--      This procedure sets configuration options
--
-- PARAMETERS:
--      inname - config option (see documentation or validate_set)
--      value  - value for specified option
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16104 "invalid Logical Standby option requested"
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE apply_set(inname IN VARCHAR,
                    value  IN VARCHAR);


--
-- NAME: apply_unset
--
-- DESCRIPTION:
--      This procedure sets a configuration option back to its default value
--
-- PARAMETERS:
--      inname - config option (see documentation or validate_set)
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16104 "invalid Logical Standby option requested"
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE apply_unset(inname IN VARCHAR);


--
-- NAME: build
--
-- DESCRIPTION:
--      Build a LogMiner dictionary into the redo log steam.
--      Captures system catalog metadata from primary database for
--      use by Logical Standby while apply redo log changes.  This procedure
--      also turns on supplemental logging.
--
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
PROCEDURE build;


--
-- NAME: rebuild
--
-- DESCRIPTION:
--      This procedure is called 
--      after an error was detected during the LSP1 LogMiner dictionary build. 
--      Unlike
--      normal LogMiner dictionary builds, the lockdown SCN has already been
--      determined.  This SCN is stored as the FIRST_CHANGE# of a record in 
--      system.logstdby$history that represents the current log stream.  The
--      lockdown SCN is simply fetched and supplied to the dictionary gather
--      routine.  This routine will also attempt to archive SRLs that were
--      purposely deferred during activation.  These two activities, build and
--      SRL archival, must complete in order for reinstatement of standbys
---     to be successful.  The status of these activities is reflected in the
--      REINSTATEMENT_STATUS parameter which can be any of the following values:
--      BUILD PENDING, SRL ARCHIVE PENDING, READY, or NOT POSSIBLE.  A status of 
--      BUILD PENDING means that the LogMiner dictionary build is pending.  A 
--      status of SRL ARCHIVE PENDING means that the SRL archival is pending. 
--      Due to the ordering of this routine, a status of SRL ARCHIVE PENDING also
--      implies that a LogMiner dictionary build was successful.  A status of 
--      READY means that reinstatement of standbys is possible.  A status of 
--      NOT POSSIBLE means that reinstatement is not possible.  The  NOT POSSIBLE 
--      status will only occur if the LogMiner dictionary build returns a snapshot 
--      too old error.  
-- 
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
PROCEDURE rebuild;


-- NAME: validate_auth
--
-- DESCRIPTION:
--      validate security aspects of skip procedures (sec bug 4315344)
--      this proc is here not dbms_logstdby_internal because
--      package is declared authid current_user while internal is
--      declared authid definer; we need roles to be active
--
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
FUNCTION validate_auth RETURN BOOLEAN;

--
-- NAME: skip
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row in the skip table
--      according to the data passed in.  Used to define filters that
--      prevent application of SQL statements by Logical Standby apply.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--
SUBTYPE CHAR1 IS CHAR(1);
PROCEDURE skip(stmt        IN VARCHAR2,
               schema_name IN VARCHAR2 DEFAULT NULL,
               object_name IN VARCHAR2 DEFAULT NULL,
               proc_name   IN VARCHAR2 DEFAULT NULL,
               use_like    IN BOOLEAN  DEFAULT TRUE,
               esc         IN CHAR1    DEFAULT NULL);


--
-- NAME: skip_error
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row into the
--      skip table according to the data passed in.  Used to tell Logical
--      Standby apply how to behave when encountering an error.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
-- 
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE skip_error(stmt        IN VARCHAR2,
                     schema_name IN VARCHAR2 DEFAULT NULL,
                     object_name IN VARCHAR2 DEFAULT NULL,
                     proc_name   IN VARCHAR2 DEFAULT NULL,
                     use_like    IN BOOLEAN  DEFAULT TRUE,
                     esc         IN CHAR1    DEFAULT NULL);


--
-- NAME: skip_transaction
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row into the
--      skip transaction table according to the data passed in.
--      Used to tell Logical Standby to skip a particular txn.
--
-- PARAMETERS
--      xid
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--      WARNING: be sure skipping of this transaction will not affect
--      applying future transactions.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-01031 "insufficient privileges"
--
PROCEDURE skip_transaction(xidusn_p IN NUMBER,
                           xidslt_p IN NUMBER,
                           xidsqn_p IN NUMBER);


--
-- NAME: unskip
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip table according to the data passed in.  Negates effects
--      from skip procedure.
--
-- PARAMETERS
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip(stmt        IN VARCHAR2,
                 schema_name IN VARCHAR2 DEFAULT NULL,
                 object_name IN VARCHAR2 DEFAULT NULL);


--
-- NAME: unskip_error
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip table according to the data passed in.  Negates effects
--      from skip_error procedure.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip_error(stmt        IN VARCHAR2,
                       schema_name IN VARCHAR2 DEFAULT NULL,
                       object_name IN VARCHAR2 DEFAULT NULL);


--
-- NAME: unskip_transaction
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip transaction table according to the data passed in.
--      Negates effects from skip_transaction procedure.
--
-- PARAMETERS
--      xid
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16100 "not a valid Logical Standby database"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip_transaction(xidusn_p IN NUMBER,
                             xidslt_p IN NUMBER,
                             xidsqn_p IN NUMBER);


--
-- NAME: instantiate_table
--
-- DESCRIPTION:
--      This procedure creates and populates a table and its
--      children from a table existing on a source database as
--      accessed via the dblink parameter.
--
--      If the table currently exists in the target database,
--      it will be dropped. Any constraint or index that exists
--      on the source table will also be created but physical 
--      storage characteristics will be omitted.
--
-- PARAMETERS:
--      table_name      Name of table to be instantiated
--      schema_name     Schema name in which the table resides
--      dblink          link to database in which the table resides
--
-- USAGE NOTES:
--      This procedure should be called on a logical standby database
--      whenever a table needs to be re-instantiated. If the apply
--      engine is currently running, and exception will be raised.
--      The target table will be dropped first if it currently exists.
--      Uses datapump so datapump rules apply.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16277 "specified table is not supported by logical standby"
--      ora-16278 "specified table has a multi-object skip rule defined"
--      ora-00942 "Table does not exist (on primary)"
--      ora-16308 "specified table has extended data type support"
--
PROCEDURE instantiate_table(schema_name IN VARCHAR2,
                            table_name  IN VARCHAR2,
                            dblink      IN VARCHAR2);

--
-- NAME: set_tablespace
--
-- DESCRIPTION:
--      This procedure changes the tablespace used to store logical
--      standby metadata.  By default this data is stored in SYSAUX.
--      Users have the option to move the metadata to another schema
--      provided APPLY is not running when the data is moved.
--
-- PARAMETERS:
--      new_tablespace      Name of tablespace to hold metadata
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE set_tablespace(new_tablespace IN VARCHAR2);


--
-- NAME: purge_session
--
-- DESCRIPTION:
--      This procedure purges the session metadata up to the latest
--      safe purge scn. This procedure can be called while the logical
--      standby apply is running
--
-- PARAMETERS:
--      NONE
--
-- USAGE NOTES:
--      This procedure can be called while apply is running
--
-- EXCEPTIONS:
--      ora-01309 "invalid session"
--
PROCEDURE purge_session;


--
-- NAME: prepare_for_new_primary
--
-- DESCRIPTION:
--
--      This procedure is called to ready the local logical standby
--      for configuration with a failed-over primary.  This routine will:
--      
--        1. Ensure the primary is only one role transition ahead of us.
--        2. Ensure we haven't applied too far (i.e. flashback required).
--        3. Purge log$ of all logfiles that need to be obtained from the
--           new primary's copy (a.k.a terminal logs).
--
--      If the new primary was formerly a physical standby, the user should
--      issue a START LOGICAL STANDBY APPLY.  If the new primary was formerly 
--      a logical standby, the user must ensure to copy and re-register the
--      terminal logs, as indicated in the alert.log, and issue a START 
--      LOGICAL STANDBY APPLY NEW PRIMARY.  This DDL will ensure the apply
--      runs in the appropriate apply mode.
--
-- PARAMETERS:
--      former_standby_type -- Type of standby the new primary was activated
--                             from.  Valid values are 'PHYSICAL' | 'LOGICAL'
--      dblink              -- dblink to the activated primary
--
-- USAGE NOTES:
--      NONE
--
-- EXCEPTIONS:
--      NONE
--
PROCEDURE prepare_for_new_primary (former_standby_type IN VARCHAR2, 
                                   dblink              IN VARCHAR2);

--
-- NAME: map_primary_scn
--
-- DESCRIPTION:
--   Return conservative scn on standby for specified scn on primary
--
-- PARAMETERS:
--      scn -- Valid scn on primary
--
-- USAGE NOTES:
--      Return an scn on the standby that predates the supplied scn
--      from the primary by at least 5 minutes. This is a safe scn to
--      flashback the standby to prior to the scn to which the primary 
--      was flashed back
--
-- EXCEPTIONS:
--      -20001, primary scn before mapped range
--      -20002, scn mapping requires PRESERVE_COMMIT_ORDER true
--      

FUNCTION map_primary_scn(primary_scn NUMBER) RETURN NUMBER;

-- NAME: db_is_logstdby
--
-- DESCRIPTION:
--      Function returns 1 if called from a Logical Standby database
--      and 0 otherwise.
--
-- PARAMETERS:
-- USAGE NOTES:
-- EXCEPTIONS:
--
FUNCTION db_is_logstdby RETURN BINARY_INTEGER;

--
-- NAME: is_apply_server
--
-- DESCRIPTION:
--      Functions returns TRUE/FALSE on whether called from apply process
--
-- PARAMETERS:
--
-- USAGE NOTES:
--      Needed for standby trigger support
--
-- EXCEPTIONS:
--
FUNCTION is_apply_server RETURN BOOLEAN;


--
-- Name:  eds_add_table - Add Trigger-Based Support for EDS table
--
-- Description:
--      Feature procedure for Extended Datatype Support on logical standby.
--      By calling this procedure on the primary first and then the standby,
--      tables with extended datatypes can be supported on a logical standby.
--
-- Parameters:
--      table_owner     (IN)    owner of the table
--      table_name      (IN)    table name to support
--      p_dblink        (IN)    db link to the primary
--
-- Usage:
--      Call on primary first, then on standby. It creates a shadow table and
--      2 triggers; one on the base table and one on the shadow table. On the
--      standby it must be called with a dblink to the primary which it will
--      use for dictionary queries and for instantiate_table.
--
PROCEDURE eds_add_table(
        table_owner     IN      varchar2,
        table_name      IN      varchar2,
        p_dblink        IN      varchar2 default NULL);


--
-- Name:  eds_remove_table - Remove Trigger-Based Support for EDS table
--
-- Description:
--      Feature procedure for Extended Datatype Support on logical standby.
--      This can be invoked on the primary or the standby. If invoked on the
--      primary, its actions will be replicated by way of an AUTO pragma.
--      If invoked from the standby it will only drop EDS on that standby.
--
-- Parameters:
--      table_owner     (IN)    owner of the table
--      table_name      (IN)    table name to support
--
-- Usage:
--
PROCEDURE eds_remove_table(
        table_owner     IN      varchar2,
        table_name      IN      varchar2);

--
-- Name:  eds_evolve_table - Evolve Trigger-Based Support for EDS table
--
-- Description:
--      This procedure evolves EDS support for a table that has been altered
--      in some way that has compromised the existing triggering infrastructure
--      to the extent that DML on the table is rejected due to failures in the
--      base table trigger.
--
-- Parameters:
--      table_owner     (IN)    owner of the table
--      table_name      (IN)    table name to support
--
-- Usage:
--
PROCEDURE eds_evolve_table(
        table_owner     IN      varchar2,
        table_name      IN      varchar2);

END dbms_logstdby;
/
show errors
  
CREATE OR REPLACE PUBLIC SYNONYM dbms_logstdby FOR sys.dbms_logstdby;

-- Revoke execute on DBMS_LOGSTDBY from public.  If it has already
-- been revoked, do not throw an error. NOTE this is to accomodate
-- 9iR1 databases that formerly had the package executable to public. 
DECLARE
  already_revoked EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_revoked,-01927);
BEGIN
   execute immediate 'REVOKE EXECUTE ON dbms_logstdby FROM public';
EXCEPTION WHEN already_revoked then null;
END;
/
GRANT EXECUTE ON dbms_logstdby TO dba;

-- Create role lesser than dba to manage logstdby 
-- BUT: they will not be able to skip/unskip which requires 'BECOME USER'
-- Note this role is included in ku_noexp_tab via catdpb.sql.
CREATE ROLE logstdby_administrator;
GRANT EXECUTE ON dbms_logstdby TO logstdby_administrator;
GRANT RESOURCE TO logstdby_administrator;
/

-- needed by several prvt scripts
CREATE OR REPLACE LIBRARY sys.dbms_logstdby_lib TRUSTED IS STATIC;
/

