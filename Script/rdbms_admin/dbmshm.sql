Rem
Rem $Header: dbmshm.sql 15-jun-2007.18:05:31 bkuchibh Exp $
Rem
Rem dbmshm.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmshm.sql - RDBMS Health Monitor package specification 
Rem
Rem    DESCRIPTION
Rem      Defines the interface for Health Monitor procedures 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bkuchibh    06/15/07 - change the param name declarations
Rem    bkuchibh    03/06/06 - change the default value for get_report 
Rem                         - function        
Rem    bkuchibh    10/16/06 - add function to invoke DDE user actions. 
Rem    siroych     10/09/06 - add offline dictionary procedure
Rem    bkuchibh    09/12/06 - fix bug#5520660 
Rem    bkuchibh    08/03/06 - drop format_msg_group function
Rem    bkuchibh    06/10/06 - add reporting interface 
Rem    bkuchibh    04/13/06 - Creation
Rem    bkuchibh    04/13/06 - Creation
Rem    bkuchibh    04/13/06 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_hm AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************

-- bkuchibh TODO: change number, add more, where are these defined?
internal_error    EXCEPTION;
PRAGMA exception_init(internal_error, -111);
internal_error_num NUMBER := -111;

--*****************************************************************************
-- Package Public Types
--*****************************************************************************

--*****************************************************************************
-- HM RUN CHECK Implementation
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     run_check
--
-- Description:  Runs a given check
--
-- Parameters:   check_name - check name
--               run_name   - run name to uniquely identify this run
--               timeout    - timeout for the given run (in seconds)
--               input_params   - text format of input parameters
--
-------------------------------------------------------------------------------
PROCEDURE run_check( check_name    IN varchar2,
                     run_name      IN varchar2 := null,
                     timeout       IN number := null,
                     input_params  IN varchar2 := null);

------------------------------------------------------------------------------
--
-- FUNCTION      get_run_report
--
-- Description:  Gets the report for a given run name 
--
-- Parameters:   run_name  -  run name
--               report_type      -  type of report (TEXT, HTML, XML) 
--               report_level     -  Level of report (BASIC, DETAILED)
--
-------------------------------------------------------------------------------

FUNCTION get_run_report(run_name IN varchar2,
                        report_type IN varchar2 := 'TEXT',
                        report_level IN varchar2 := 'BASIC' ) return clob;

-------------------------------------------------------------------------------
--
-- PROCEDURE     create_schema
--
-- Description:  creates HM schema in ADR 
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE create_schema;

-------------------------------------------------------------------------------
--
-- PROCEDURE     drop_schema
--
-- Description:  drops HM schema 
--
-- Parameters:  force   -  
--
-------------------------------------------------------------------------------
PROCEDURE drop_schema(force IN boolean := FALSE);
-------------------------------------------------------------------------------

--*****************************************************************************
-- HM - DDE User Action  Implementation
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- FUNCTION      run_dde_action
--
-- Description:  Runs a DDE (user) action for HM checks. 
--
-- Parameters:   incident_id    -   Incident ID 
--               directory_name -   directory info(should be NULL for HM)  
--               check_name     -   check to be executed 
--               run_name       -   run name given for the run/action(NULL??) 
--               timeout        -   timeout for the given run (in seconds)
--               params         -   text format of input parameters
--
-------------------------------------------------------------------------------
FUNCTION run_dde_action( incident_id         IN number,
                         directory_name      IN varchar2,
                         check_name          IN varchar2,
                         run_name            IN varchar2,
                         timeout             IN number,
                         params              IN varchar2) return boolean;

pragma TIMESTAMP('2006-04-13:12:00:00');

-------------------------------------------------------------------------------
--
-- PROCEDURE     create_offline_dictionary
--
-- Description:  creates LogMiner offline dictionary in ADR
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE create_offline_dictionary;

END;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_hm
FOR sys.dbms_hm
/
GRANT EXECUTE ON dbms_hm TO dba
/
