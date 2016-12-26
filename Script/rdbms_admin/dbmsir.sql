Rem
Rem $Header: dbmsir.sql 31-oct-2007.15:37:34 mjstewar Exp $
Rem
Rem dbmsir.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsir.sql - RDBMS Intelligent Repair package specification
Rem
Rem    DESCRIPTION
Rem      Defines the interface for Intelligent Repair functions
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjstewar    09/12/07 - 6412947: add timeout to revalidation
Rem    mjstewar    01/16/07 - Bug 5695402
Rem    mjstewar    09/12/06 - 5475532: add getfile for EM
Rem    molagapp    05/15/06 - add execSqlScript, controlfileCheck
Rem    mjstewar    03/17/06 - Created
Rem

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_ir AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

--*****************************************************************************
-- Package Public Types
--*****************************************************************************

--
-- Some routines act on a set of failures.  This type is for defining the
-- input list of failures.
--
TYPE ir_failure_list_type IS TABLE OF number index by binary_integer;

--
-- Those routines that act on a list of failures will continue with all
-- failures even when there is are errors for some of the failures.
-- So, we must be able to return the error status for the failures that
-- cannot be changed.  In those cases we'll return a table of failure/error
-- pairs.  There will one entry for each failure that could not be changed.
--

TYPE ir_failure_op_error IS RECORD (
  failureID  number,
  errorCode  number );

TYPE ir_error_list_type IS TABLE OF ir_failure_op_error 
   index by binary_integer;

--
-- adviseDone returns a list of Repair ID, Option Idx
--
TYPE ir_repair_option_id IS RECORD (
  repairID  number,
  optionIdx number,
  spare1    number default NULL,
  spare2    number default NULL,
  spare3    number default NULL,
  spare4    number default NULL,
  spare5    number default NULL);

TYPE ir_repair_option_list IS TABLE OF ir_repair_option_id
   index by binary_integer;

--
-- updateFeasibilityAndImpact can work on a set of repairs.
-- This record is for identifying a repair (failureIdx, repairIdx) and
-- for supplying the new feasibility and impact information for the
-- repair.  A table of these is supplied to updateFeasibilityAndImpact.
-- 
TYPE ir_repair_feasibility IS RECORD (
  failureIdx  number,
  repairIdx   number,
  feasibility boolean,
  dataLoss    number default NULL,
  repairTime  number default NULL,
  spare1      number default NULL,
  spare2      number default NULL,
  spare3      number default NULL,
  spare4      number default NULL,
  spare5      number default NULL,
-- mjs TODO: get max size of impact string
  impact      varchar2(2000) default NULL);

TYPE ir_repair_feasibility_list IS TABLE OF ir_repair_feasibility
  index by binary_integer;

--
-- Repair script file can be returned or supplied via one call using
-- this array of varchars.
--
TYPE ir_script_file_type IS TABLE OF varchar2(513) index by binary_integer;

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************

internal_error               EXCEPTION;
PRAGMA exception_init        (internal_error, -51190);
internal_error_num           NUMBER := -51190;

too_many_opens_error         EXCEPTION;
PRAGMA exception_init        (too_many_opens_error, -51191);
too_many_opens_error_num     NUMBER := -51191;

not_open_error               EXCEPTION;
PRAGMA exception_init        (not_open_error, -51192);
not_open_error_num           NUMBER := -51192;

invalid_param_error          EXCEPTION;
PRAGMA exception_init        (invalid_param_error, -51193);
invalid_param_error_num      NUMBER := -51193;

--*****************************************************************************
-- IR List Routines
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     reevaluateOpenFailures
--
-- Description:  Reevaluate the status of open IR failures.
-- 
-- Parameters:   reevaluateCritical - reevaluate all critical open IR failures
--               reevaluateHigh - reevaluate all high open IR failures
--               reevaluateLow - reevaluate all low open IR failures
-- 
-------------------------------------------------------------------------------
PROCEDURE reevaluateOpenFailures( reevaluateCritical IN boolean default TRUE
                                 ,reevaluateHigh     IN boolean default TRUE
                                 ,reevaluateLow      IN boolean default TRUE );

-------------------------------------------------------------------------------
--
-- PROCEDURE     reevaluateOpenFailures
--
-- Description:  Reevaluate the status of open IR failures.
-- 
-- Parameters:   reevaluateCritical - 
--                      'TRUE'   - reevaluate all critital open failures
--                      'FALSE'  - don't reevaluate critical open failures
--               reevaluateHigh - 
--                      'TRUE'   - reevaluate all high open failures
--                      'FALSE'  - don't reevaluate high open failures
--               reevaluateLow - 
--                      'TRUE'   - reevaluate all low open failures
--                      'FALSE'  - don't reevaluate low open failures
--               timeout - maximum number of seconds to run
-- 
-------------------------------------------------------------------------------
PROCEDURE reevaluateOpenFailures( reevaluateCritical IN varchar
                                 ,reevaluateHigh     IN varchar
                                 ,reevaluateLow      IN varchar
                                 ,timeout            IN varchar );



--*****************************************************************************
-- IR Change Routines
--*****************************************************************************

--
-- Values for newPriority parameter for changePriority routine
--

-- Changing to critical is not allowed at this time
IR_FAILURE_CRITICAL          constant binary_integer := 1; 
IR_FAILURE_HIGH              constant binary_integer := 2;
IR_FAILURE_LOW               constant binary_integer := 3;

-------------------------------------------------------------------------------
--
-- PROCEDURE     changePriority
--
-- Description:  Change the priority of one or more IR failures.
--               Will attempt to change all the failures in the list, even
--               if errors prevent changing some of the failures.
--
--               The priority of a 'critical' failure cannot be changed and 
--               a failure's priority cannot be changed to 'critical'.
--
--               The priorities of parents and children should remain the 
--               same, hence the priority of a child failure cannot be 
--               changed.  If the priority of a parent failure is changed, 
--               then all the children will also be changed to the same 
--               priority.
-- 
-- Parameters:   failureList - list of failure identifiers
--               newPriority - The new priority for the failures.  One of:
--                             IR_FAILURE_HIGH
--                             IR_FALURE_LOW
--               errorList   - failure-id/error pairs for the failures that
--                             could not be changed.
-- 
-------------------------------------------------------------------------------
PROCEDURE changePriority( failureList IN  ir_failure_list_type
                         ,newPriority IN  binary_integer
                         ,errorList   OUT ir_error_list_type );

-------------------------------------------------------------------------------
--
-- PROCEDURE     changePriority
--
-- Description:  See above.
--
-- Parameters:   failureList - comma separated list of failure identifiers
--               newPriority - The new priority for the failures.  One of:
--                             IR_FAILURE_HIGH
--                             IR_FALURE_LOW
--               errorID     - Identifier for retrieving errors.  
--                             0, if no errors encountered.
-- 
-------------------------------------------------------------------------------

PROCEDURE changePriority( failureList IN  varchar2
                         ,newPriority IN  binary_integer
                         ,errorID     OUT number );


-------------------------------------------------------------------------------
--
-- PROCEDURE     closeFailures
--
-- Description:  Close one or more IR failures.
--               Will attempt to close all the failures in the list, even
--               if errors prevent changing some of the failures.
--               Closing a parent failure will cause all the children to
--               be closed.
-- 
-- Parameters:   failureList - list of failure identifiers
--               errorList   - failure-id/error pairs for the failures that
--                             could not be closed.
-- 
-------------------------------------------------------------------------------
PROCEDURE closeFailures( failureList IN  ir_failure_list_type 
                        ,errorList   OUT ir_error_list_type );

-------------------------------------------------------------------------------
--
-- PROCEDURE     closeFailures
--
-- Description:  See above.
--
-- Parameters:   failureList - comma separated list of failure identifiers
--               errorList   - Identifier fro retrieving errors.
--                             0, if no errors encountered.
-- 
-------------------------------------------------------------------------------
PROCEDURE closeFailures( failureList IN  varchar2
                        ,errorID     OUT number );


-------------------------------------------------------------------------------
--
-- PROCEDURE     getError
--
-- Description:  Return an error from a previous changePriority() or
--               closeFailures() request where the failure list was
--               passed in as a comma separated list of failure-ids.
-- 
-- Parameters:   errorId     - an identifier for the error list.
--                             Returned by changePriority() or closeFailures().
--               failureId   - the failure for which the command failed.
--               errorStr    - the error message text.
--               done        - FALSE if there are more errors to return.
--                             TRUE if there are no more errors.
--                             If TRUE, then 'errorStr' will be empty.
--
-------------------------------------------------------------------------------
PROCEDURE getError( errorId   IN  number
                   ,failureID OUT number
                   ,errorStr  OUT varchar2
                   ,done      OUT boolean );

--*****************************************************************************
-- IR Advise Routines
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     getAdviseID
--
-- Description:  Start an ADVISE command and get the ADVISE identifier.
-- 
-- Parameters:   failureList - list of failure identifiers
--               adviseID    - the ADVISE identifier
-- 
-------------------------------------------------------------------------------
PROCEDURE getAdviseID( failureList  IN  ir_failure_list_type
                       ,adviseID    OUT number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     getAdviseID
--
-- Description:  Start an ADVISE command and get the ADVISE identifier.
-- 
-- Parameters:   failureList - comma separted list of failure identifiers
--               adviseID    - the ADVISE identifier
-- 
-------------------------------------------------------------------------------
PROCEDURE getAdviseID( failureList  IN  varchar2
                      ,adviseID     OUT number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     createWorkingRepairSet
--
-- Description:  Create intermediate working repair set for ADVISE command.
-- 
-- Parameters:   adviseID    - the ADVISE identifier
-- 
-------------------------------------------------------------------------------
PROCEDURE createWorkingRepairSet( adviseID  IN  number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     adviseCancel
--
-- Description:  Cancels an ADVISE conversation, releasing the context.
--               This needs to be done if a conversation is going to be
--               abandoned without successfully completing the command.
--               This can be done anytime within the conversation after
--               createWorkingRepairSet has been called and before
--               adviseDone has been called.
-- 
-- Parameters:   adviseID    - the ADVISE identifier
-- 
-------------------------------------------------------------------------------
PROCEDURE adviseCancel( adviseID  IN number);

-------------------------------------------------------------------------------
--
-- PROCEDURE     getFeasibilityAndImpact
--
-- Description:  Used by RMAN to get the feasibility and impact of a
--               particular repair on the server.
--
-- Parameters:   repairType      - The CTS repair type identifier.
--               parameterList   - Repair parameters as name=value pairs
--               feasibility     - Returned TRUE if the repair is feasible
--               dataLoss        - Dataloss (if any) for the repair
--               repairTime      - Repair time in seconds
--               impact          - Repair impact text string
-- 
-------------------------------------------------------------------------------
PROCEDURE getFeasibilityAndImpact( repairType    IN  binary_integer
                                  ,parameterList IN  varchar2
                                  ,feasibility   OUT boolean
                                  ,dataLoss      OUT number
                                  ,repairTime    OUT number
                                  ,impact        OUT varchar2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     updateFeasibilityAndImpact
--
-- Description:  Used by RMAN to update the feasibility and impact of
--               a set of repairs (which are in the memory of the
--               server) during an ADVISE command.
--
-- Parameters:   adviseID        - The advise ID of the command.
--               repairList      - A list of repairs and the associated
--                                 feasibility, dataLoss, repairTime,
--                                 and impact to assign to each.
-- 
-------------------------------------------------------------------------------
PROCEDURE updateFeasibilityAndImpact( 
                        adviseID    IN  number
                       ,repairList  IN  ir_repair_feasibility_list );

-------------------------------------------------------------------------------
--
-- PROCEDURE     consolidateRepair
--
-- Description:  Called by RMAN to consolidate the repair options for
--               an ADVISE command.
-- 
-- Parameters:   adviseID    - the ADVISE identifier
-- 
-------------------------------------------------------------------------------
PROCEDURE consolidateRepair( adviseID  IN  number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     updateRepairOption
--
-- Description:  Update an ADVISE repair option with its script name,
--               data loss, repair time, and impact.
-- 
--
-- Parameters:   adviseID    - the ADVISE identifier
--               optionIdx   - In-memory index of the option.
--                             Can be retrieved from x$idr_repair_option.
--               scriptName  - Name of the repair script.
--               dataLoss    - Data loss for the repair.
--               repairTime  - Time (seconds) to do the repair.
--               impact      - Impact text string.
-- 
-------------------------------------------------------------------------------
PROCEDURE updateRepairOption( adviseID     IN  number 
                             ,optionIdx    IN  number
                             ,scriptName   IN  varchar2
                             ,dataLoss     IN  number default NULL
                             ,repairTime   IN  number default NULL
                             ,impact       IN  varchar2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     adviseDone
--
-- Description:  Called by RMAN to tell the server that an ADVISE has 
--               completed.  Will cause the repair option information to
--               be written to disk.
-- 
-- Parameters:   adviseID    - the ADVISE identifier
--               generatedRepairs - a list of the repair options generated.
--                                  Each entry includes the identifier
--                                  for the repair when it was written to
--                                  ADR and the index of the repair option 
--                                  during the ADVISE.
-------------------------------------------------------------------------------
PROCEDURE adviseDone( adviseID  IN  number
                     ,generatedRepairs OUT ir_repair_option_list );


--*****************************************************************************
-- IR Repair Routines
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     startRepairOption
--
-- Description:  Called prior to executing a repair option.  It 
--               verifies that all the failures associated with the repair
--               are still open and then updates the status of the repair
--               to indicate that it is running.  It does NOT execute the
--               repair.  It will signal an error if it is not ok to start
--               the repair.
-- 
-- Parameters:   repairID   -  ID of the repair option to be executed.
--               generatedRepairs - a list of the repair options generated
--                                  (ADR repair identifer/repair option index)
-- 
-------------------------------------------------------------------------------
PROCEDURE startRepairOption( repairID IN number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     completeRepairOption
--
-- Description:  Called after completing a repair.  It updates 
--               the status of the repair in ADR.  If the repair was
--               successful it also reevaluates all open failures.
-- 
-- Parameters:   repairID         -  ID of the repair option that was 
--                                   tried.
--               repairSucceeded  -  TRUE if the repair was successful.
-- 
-------------------------------------------------------------------------------
PROCEDURE completeRepairOption( repairID         IN number
                               ,repairSucceeded  IN boolean );

--*****************************************************************************
-- IR Misc Routines
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     createScriptFile
--
-- Description:  Called by RMAN to create and open a file to write a repair
--               script.
-- 
-- Parameters:   fileId    - An identifier for the open file.  Can be used
--                           to write/read from the file and close it, but
--                           only from the same session.
--               fileName  - The name of the file that was created.
-- 
-------------------------------------------------------------------------------
PROCEDURE createScriptFile( fileID    OUT number
                           ,fileName  OUT varchar2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     openScriptFile
--
-- Description:  Open a repair script file.
-- 
-- Parameters:   repairID    - the repair identifier for the script to open
--               fileID      - an identifier for the open file.  Can be used
--                             to write/read from the file and close it,
--                             but only from the same session.
-- 
-- Notes: Only one script file can be open at a time from the same session.
-------------------------------------------------------------------------------
PROCEDURE openScriptFile( repairID    IN  number
                         ,fileID      OUT number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     openScriptFile
--
-- Description:  Open a repair script file.
-- 
-- Parameters:   fileName    - The name of the script file.
--               fileID      - an identifier for the open file.  Can be used
--                             to write/read from the file and close it,
--                             but only from the same session.
-- 
-- Notes: Only one script file can be open at a time from the same session.
-------------------------------------------------------------------------------
PROCEDURE openScriptFile( fileName    IN  varchar2
                         ,fileID      OUT number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     addLine
--
-- Description:  Write a line to a script file.
-- 
-- Parameters:   fileID      - The identifier for an open file.
--                             Must have been opened from this session.
--               line        - Line of text to write.
-- 
-------------------------------------------------------------------------------
PROCEDURE addLine( fileID      IN   number
                  ,line        IN   varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     getLine
--
-- Description:  Read a line from a script file.
-- 
-- Parameters:   fileId      - an identifier for an open script file.
--                             Returned by openScriptFile().
--               line        - The first/next line of text from the file.
--                             The first line, if this is the first call
--                             with fileID.
--                             It may be up to 513 bytes long.
--               done        - FALSE if there are more lines to return.
--                             TRUE if there are no more lines.
--                             If TRUE, then 'line' is undefined.
--
-------------------------------------------------------------------------------
PROCEDURE getLine( fileID    IN  number
                  ,line      OUT varchar2
                  ,done      OUT boolean );


-------------------------------------------------------------------------------
--
-- PROCEDURE     writeFile
--
-- Description:  Write multiple lines to a script file.
-- 
-- Parameters:   fileID      - The identifier for an open file.
--                             Must have been opened from this session.
--               contents    - The set of lines to write.
-- 
-------------------------------------------------------------------------------
PROCEDURE writeFile( fileID      IN   number
                    ,contents    IN   ir_script_file_type );

-------------------------------------------------------------------------------
--
-- PROCEDURE     getFile
--
-- Description:  Returns the contents of an IR script file.
-- 
-- Parameters:   fileId      - an identifier for an open script file.
--                             Returned by openScriptFile().
--               contents    - The lines from the file.
--
-------------------------------------------------------------------------------
PROCEDURE getFile( fileID   IN  number
                  ,contents OUT ir_script_file_type );

-------------------------------------------------------------------------------
--
-- PROCEDURE     getFile
--
-- Description:  Returns the contents of an IR script file.
-- 
-- Parameters:   fileId      - an identifier for an open script file.
--                             Returned by openScriptFile().
--               outBuf      - Contains the lines from the file concatentated
--                             together, each line terminated by a newline
--                             character, and the whole string NULL 
--                             terminated.  outBuf should be at least 32767
--                             chars long, which is the maximum script size.
--
-------------------------------------------------------------------------------
PROCEDURE getFile( fileID   IN  number
                  ,outBuf   OUT varchar2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     closeScriptFile
--
-- Description:  Close a repair script file.
-- 
-- Parameters:   fileID      - an identifier for an open script file.
--                             Must have been returned from openScriptFile().
-- 
-------------------------------------------------------------------------------
PROCEDURE closeScriptFile( fileID  IN number );

-------------------------------------------------------------------------------
--
-- PROCEDURE     execSqlScript
--
-- Description:  execute the specified sql script
-- 
-- Parameters:   filename    - sql script location
-- 
-------------------------------------------------------------------------------
PROCEDURE execSqlScript( filename IN varchar2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     controlfileCheck
--
-- Description:  execute IR crosscheck for controlfile
-- 
-- Parameters:   filename    - controlfile name
--
-- Returns: TRUE if crosscheck is successful. Otherwise, FALSE.
-- 
-------------------------------------------------------------------------------
FUNCTION controlfileCheck( cfname IN varchar2 ) RETURN boolean;

-------------------------------------------------------------------------------

pragma TIMESTAMP('2006-03-17:12:00:00');

-------------------------------------------------------------------------------

END;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_ir FOR sys.dbms_ir
/

GRANT EXECUTE ON dbms_ir TO dba
/
