rem 
rem $Header: rdbms/admin/dbmsdefr.sql /st_rdbms_11.2.0/1 2013/02/26 22:05:12 aayalaa Exp $ 
rem 
rem 
Rem Copyright (c) 1992, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem  ***** Oracle Proprietary                                           *****
Rem  ***** This file contains the embodiment of proprietary technology. *****
Rem  ***** It is for the sole use of Oracle employees and Oracle        *****
Rem  ***** customers who have executed non-disclosure agreements.       *****
Rem  ***** The contents of this file may not be disclosed to persons    *****
Rem  ***** or organization who have not executed a non-disclosure       *****
Rem  ***** agreement.                                                   *****
Rem    NAME
Rem      dbmsdefr.sql - replicated deferred remote procedure calls
Rem    DESCRIPTION
Rem      The external interfaces and bodies of two replication packages are 
Rem      also included, as are some sequences used by the packages.
Rem      All objects  are created in the schema 'SYS'.
Rem       Packages
Rem         dbms_defer
Rem         dbms_defer_query
Rem         dbms_defer_sys
Rem 
Rem    NOTES
Rem      The algorithms used here were originally conceived by Sandeep
Rem	     Jain, and are described in a forthcoming memo by Sandeep Jain
Rem      and Dean Daniels Titled "A Method for Deferring Remote Procedure Calls
Rem      Utilizing a Relational Database System."
Rem
Rem      The structures implemented by this package should probably be a
Rem      cluster.  The create table statements can be modified to include
Rem      storage information as appropriate for a particular installation.
Rem
Rem    DEPENDENCIES
Rem      These packages use calls from  the DBMS_SQL, DBMS_ASYNCRPC, and
Rem      DBMS_DEFER_PACK packages
Rem      
Rem    USAGE
Rem      This script is to be run by user connected as INTERNAL.
Rem
Rem    SECURITY
Rem      Tables and sequences created by this script are kept private
Rem      The dbms_defer package is granted to public, but it is reasonable to 
Rem      restrict access
Rem      to users creating replicated applications.  
Rem      The dbms_defer_query package can be executed by users who need to 
Rem      monitor deferred rpc queues, for example dba correcting conflicts.
Rem      The dbms_defer_sys package is granted to DBAs (by default)
Rem      The dbms_defer_internal_sys packages is 
Rem      kept  private. 
Rem      The dbms_defer_pack package is kept private, as is dbms_asyncrpc.
Rem     
Rem    COMPATIBILITY
Rem    MODIFIED   (MM/DD/YY)
Rem     apfwkr     02/13/13 - Backport aayalaa_16012237_main from main
Rem     gviswana   05/24/01 - CREATE OR REPLACE SYNONYM
Rem     alakshmi   01/17/01 - Bug 1514478
Rem     liwong     10/20/00 - Enhance set_disabled
Rem     narora     09/22/00 - add dbms_defer_sys.clear_prop_statistics
Rem     liwong     09/01/00 - add master w/o quiesce: fixes
Rem     liwong     07/19/00 - Move constants to dbms_defer_query
Rem     sbalaram   07/13/00 - local tz and dls support
Rem     liwong     06/17/00 - add_master_db w/o quiesce
Rem     sbalaram   02/07/00  - repl obj: Add object_arg
Rem     liwong     12/11/99  - repl obj: dbms_defer_query support
Rem     cbarclay   11/23/99  - new datetime subtypes
Rem     avaradar   07/07/99  - change get_call_args signature                  
Rem     sbalaram   06/09/99  - Support DATETIME datatypes                      
Rem     liwong     11/18/98  - Add execute_error_call{,as_user}                
Rem     liwong     09/22/98  - bug 674403: no parallel prop to pre-8.0 site    
Rem     liwong     07/24/98  - Add norpcprocessing                             
Rem     jstamos    07/20/98  - delete performance
Rem     liwong     04/02/98  - add condescfailure                              
Rem     liwong     05/16/97 -  add  get_arg_csetid
Rem     jstamos    04/24/97 -  reduce seconds_infinity
Rem     jstamos    04/24/97 -  default reset
Rem     jstamos    04/23/97 -  split push and purge
Rem     jstamos    04/10/97 -  tighter AQ integration
Rem     jstamos    04/07/97 -  tighter AQ integration
Rem     liwong     02/14/97 -  Add purge_option constants
Rem     liwong     02/12/97 -  Add purge_queue
Rem     liwong     02/05/97 -  Add delete_def_destination
Rem     jstamos    12/19/96 -  support any_cs
Rem     liwong     12/13/96 -  Added dbms_defer_sys.incompleteparallelpush
Rem                            exception for bug 430300
Rem     jstamos    11/22/96 -  nchar support
Rem     ademers    11/09/96 -  Add schedule_push, unschedule_push
Rem     ldoo       10/01/96 -  Interface change for unregister_propagator
Rem     sjain      09/05/96 -  Desupport dbms_defer_sys.copy
Rem     ldoo       08/21/96 -  Replace 23321-23322 with 23393-23394
Rem     jstamos    06/12/96 -  LOB support for deferred RPCs
Rem     ademers    05/31/96 -  add txn_log_run procs
Rem     ldoo       05/09/96 -  New security model
Rem     ajasuja    04/23/96 -
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     sbalaram   04/08/96 -  Remove internal procedure
Rem                            dbms_defer_sys.create_error from here
Rem                            and move it to prvtdefr.sql
Rem     sjain      11/20/95 -  Add toms
Rem     jstamos    08/17/95 -  code review changes
Rem     boki       07/07/95 -  new function to disable queue propagation
Rem     jstamos    06/29/95 -  merge changes from branch 1.9.720.6
Rem     hasun      03/20/95 -  Reset batch size to 0
Rem     hasun      01/24/95 -  Add gname parameter to call()
Rem     dsdaniel   01/17/95 -  eliminate grant to public
Rem     dsdaniel   12/05/94 -  eliminate def_trandest table
Rem     boki       12/02/94 -  modified execute(), adding new argument
Rem     hasun      11/17/94 -  add Exception NOREPOPTION for factoring
Rem     dsdaniel   10/26/94 -  coverage, interface changes
Rem     dsdaniel   09/12/94 -  comment in dbms_defer_query
Rem     dsdaniel   07/11/94 -  dbms_sys_error upgrade
Rem     adowning   04/29/94 -  merge latest revisions from repint
Rem     dsdaniel   03/29/94 -  error message change
Rem     dsdaniel   02/17/94 -  repcat integration
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     dsdaniel   01/20/94 -  dbms_sys_error error range change
Rem     rjenkins   01/13/94 -  giving RESET a default
Rem     dsdaniel   12/27/93 -  dbms_sys_sql change
Rem     rjenkins   12/22/93 -  oops
Rem     rjenkins   12/17/93 -  creating job queue
Rem     dsdaniel   11/02/93 -  dbms_sql.parse changes
Rem     dsdaniel   10/28/93 -  deferred rpc dblink security
Rem     dsdaniel   10/26/93 -  merge changes from branch 1.1.400.3
Rem     dsdaniel   10/10/93 -  break out queue tables
Rem     rjenkins   10/07/93 -  adding deferrcount
Rem     dsdaniel   08/30/93 -  package for installation by system
Rem     dsdaniel   08/04/93 -  Creation by renaming dbmsrrpc.sql
Rem     dsdaniel   05/17/93 -  upgrade to 7.0/7.1 version 
Rem     dsdaniel   02/22/93 -  Creation 
Rem   *******************************************************************
Rem 
Rem      
Rem

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD* ROUTINES MUST NOT BE CALLED
REM DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************

CREATE OR REPLACE PACKAGE dbms_defer_query AS
  -------------------
  --  OVERVIEW
  -- 
  -- This package permits querying the deferred RPC queue data that
  -- is not exposed through views.

  -------------
  --  CONSTANTS
  --
  --     constants used in the arg_type column of the def$_args table
  --     definitions copied from dtydef.h
  --
  arg_type_num       CONSTANT NUMBER := 2;   -- DTYNUM 
  arg_type_char      CONSTANT NUMBER := 96;  -- DTYAFC
  arg_type_varchar2  CONSTANT NUMBER := 1;   -- DTYCHAR
  arg_type_date      CONSTANT NUMBER := 12;  -- DTYDAT
  arg_type_rowid     CONSTANT NUMBER := 11;  -- DTYRID
  arg_type_raw       CONSTANT NUMBER := 23;  -- DTYBIN
  arg_type_blob      CONSTANT NUMBER := 113; -- DTYBLOB
  arg_type_clob      CONSTANT NUMBER := 112; -- DTYCLOB
  arg_type_bfil      CONSTANT NUMBER := 114; -- DTYBFIL
  arg_type_cfil      CONSTANT NUMBER := 115; -- DTYCFIL
  arg_type_time      CONSTANT NUMBER := 178; -- DTYTIME
  arg_type_ttz       CONSTANT NUMBER := 179; -- DTYTTZ
  arg_type_timestamp CONSTANT NUMBER := 180; -- DTYSTAMP
  arg_type_tstz      CONSTANT NUMBER := 181; -- DTYSTZ
  arg_type_iym       CONSTANT NUMBER := 182; -- DTYIYM
  arg_type_ids       CONSTANT NUMBER := 183; -- DTYIDS
  arg_type_tsltz     CONSTANT NUMBER := 231; -- DTYSITZ
  -----------
  -- the following constants are added for replicated objects
  --
  arg_type_object_null_vector    CONSTANT NUMBER := 121; -- DTYADT
  -- anydata includes instance for VARRAY, Nested Table, Object Type, REF Type
  -- and Opaque type.
  arg_type_anydata              CONSTANT NUMBER := 109; -- DTYINTY

  -- constants derived from SQLCS_% constants in sqldef.h
  arg_csetid_none       CONSTANT NUMBER := 0; -- DATE, NUMBER, ROWID, RAW, BLOB
                                              -- user-defined types
  arg_form_none         CONSTANT NUMBER := 0; -- DATE, NUMBER, ROWID, RAW, BLOB
                                              -- user-defined types
  arg_form_implicit     CONSTANT NUMBER := 1; -- CHAR, VARCHAR2, CLOB
  arg_form_nchar        CONSTANT NUMBER := 2; -- NCHAR, NVARCHAR2, NCLOB
  arg_form_any          CONSTANT NUMBER := 4;
  --     definition same as dbms_repcat_mas.repcat_status_normal
  --     (don't want to require repcat to be loaded)
  repcat_status_normal  CONSTANT NUMBER := 0.0;

  -- The following type declaration are used by get_call_args call.
  TYPE type_ary is table of number
	index by binary_integer;

  TYPE val_ary is table of varchar2(2000)
	index by binary_integer;

  FUNCTION get_arg_type(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2)
    RETURN NUMBER;
  -- Return type  of a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id
  ----
  --  Result
  --    The type of the deferred rpc parameter.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  ------

  FUNCTION get_arg_csetid(callno           IN  NUMBER,
                          arg_no           IN  NUMBER,
                          deferred_tran_id IN  VARCHAR2)
    RETURN NUMBER;
  -- Return the character set id of a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id
  ----
  --  Result
  --    The character set id of the deferred rpc parameter.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  ------

  FUNCTION get_arg_form(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2)
    RETURN NUMBER;
  -- Return the character set form of a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id
  ----
  --  Result
  --    The character set form of the deferred rpc parameter.
  --    Examples include dbms_defer.arg_form_implicit and
  --    dbms_defer.arg_form_nchar.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  ------
  FUNCTION get_number_arg(callno           IN  NUMBER,
                          arg_no           IN  NUMBER,
                          deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;
  -- Return a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a number.
  -------
  FUNCTION get_varchar2_arg(callno           IN  NUMBER,
                            arg_no           IN  NUMBER,
                            deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a VARCHAR2.
  -------
  FUNCTION get_nvarchar2_arg(callno           IN  NUMBER,
                             arg_no           IN  NUMBER,
                             deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN NVARCHAR2;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not an NVARCHAR2.
  -------
  FUNCTION get_char_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN CHAR;
  -- Return type  of a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a char.
  -------
  FUNCTION get_nchar_arg(callno           IN  NUMBER,
                         arg_no           IN  NUMBER,
                         deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN NCHAR;
  -- Return type  of a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not an nchar.
  -------
  FUNCTION get_date_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN DATE;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a date.
  -------
  FUNCTION get_raw_arg(callno            IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN RAW;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a raw.
  -------
  FUNCTION get_rowid_arg(callno           IN  NUMBER,
                         arg_no           IN  NUMBER,
                         deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN ROWID;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a rowid.
  -------
  FUNCTION get_blob_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN BLOB;
  -- Return a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a blob.
  -------
  FUNCTION get_clob_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN CLOB;
  -- Return a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a clob.
  -------
  FUNCTION get_nclob_arg(callno           IN  NUMBER,
                         arg_no           IN  NUMBER,
                         deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN NCLOB;
  -- Return a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not an nclob.
  -------
  FUNCTION get_time_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN TIME_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a time.
  -------
  FUNCTION get_timestamp_arg(callno           IN  NUMBER,
                             arg_no           IN  NUMBER,
                             deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN TIMESTAMP_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not a timestamp.
  -------
  FUNCTION get_ttz_arg(callno           IN  NUMBER,
                       arg_no           IN  NUMBER,
                       deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN TIME_TZ_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not time with time zone.
  -------
  FUNCTION get_tstz_arg(callno           IN  NUMBER,
                        arg_no           IN  NUMBER,
                        deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN TIMESTAMP_TZ_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not timestamp with time zone.
  -------
  FUNCTION get_tsltz_arg(callno           IN  NUMBER,
                         arg_no           IN  NUMBER,
                         deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN TIMESTAMP_LTZ_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not timestamp with local
  --    time zone.
  -------
  FUNCTION get_iym_arg(callno           IN  NUMBER,
                       arg_no           IN  NUMBER,
                       deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN yminterval_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not interval year to month.
  -------
  FUNCTION get_ids_arg(callno           IN  NUMBER,
                       arg_no           IN  NUMBER,
                       deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN DSINTERVAL_UNCONSTRAINED;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not interval day to second.
  -------
  FUNCTION get_object_null_vector_arg(
                            callno           IN  NUMBER,
                            arg_no           IN  NUMBER,
                            deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN system.repcat$_object_null_vector;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter .
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not an object_null_vector type
  -------
  FUNCTION get_anydata_arg(callno           IN  NUMBER,
                           arg_no           IN  NUMBER,
                           deferred_tran_id IN  VARCHAR2 DEFAULT NULL)
    RETURN Sys.AnyData;
  -- Return  a deferred call parameter.
  -- Input parameters
  --  callno
  --    call identifier from the defCall view
  --  arg_no
  --    position of desired parameter in calls argument list
  --    parameter positions are 1..number of parameters in call
  --  deferred_tran_id
  --    deferred transaction id, defaults to one passed in get_arg_type
  ----
  --  Result
  --    The value of the parameter.
  --  Notes
  --    Supported types include Collections, Object types, REF types and
  --    opaque types.
  --    Not all types supported by get_anydata_arg can be enqueued
  --    using anydata_arg.
  ------
  --  EXCEPTIONS
  --    NO_DATA_FOUND desired parameter value not found in the deferred rpc
  --    queue tables.
  --    WRONG_TYPE if the desired parameter is not one of the types that
  --    can be handled by anydata type
  -------
  PROCEDURE get_call_args
       (
	callno IN NUMBER,		-- deferred call number
	startarg IN NUMBER := 1,	 -- starting argument to fetch
	argcnt IN NUMBER,		-- number of arguments in the call
	argsize IN NUMBER,	 	-- maximum size of returned argument
	tran_db IN VARCHAR2,	        -- origin database
	tran_id IN VARCHAR2,	        -- transaction id
	date_fmt IN VARCHAR2,	        -- date format
	types OUT TYPE_ARY,		-- output array for types 
                                        -- of the arguments
	vals OUT VAL_ARY		-- output array of the values 
       );
  -- This procedure returns the text version of the various arguments for the
  -- given call. The exceptions returned by this function are the same ones
  -- as returned by get_arg_type and get _xxx_arg.
  -- This is obsolete in V8.

  PROCEDURE get_call_args
       (
	callno IN NUMBER,		-- deferred call number
	startarg IN NUMBER := 1,	 -- starting argument to fetch
	argcnt IN NUMBER,		-- number of arguments in the call
	argsize IN NUMBER,	 	-- maximum size of returned argument
	tran_id IN VARCHAR2,	        -- transaction id
	date_fmt IN VARCHAR2,	        -- date format
        time_fmt IN VARCHAR2,           -- time format
        ttz_fmt  IN VARCHAR2,           -- time with time zone format
        timestamp_fmt IN VARCHAR2,      -- timestamp format
        tstz_fmt IN VARCHAR2,           -- timestamp with time zone format
	types OUT TYPE_ARY,		-- output array for types 
                                        -- of the arguments
        forms OUT TYPE_ARY,             -- output array for forms
                                        -- of the arguments
	vals OUT VAL_ARY		-- output array of the values 
       );
  -- This procedure returns the text version of the various arguments for the
  -- given call. The exceptions returned by this function are the same ones
  -- as returned by get_arg_type and get _xxx_arg.

  PROCEDURE get_call_args
       (
	callno        IN  NUMBER,       -- deferred call number
	startarg      IN  NUMBER := 1,  -- starting argument to fetch
	argcnt        IN  NUMBER,       -- number of arguments in the call
	argsize       IN  NUMBER,       -- maximum size of returned argument
	tran_id       IN  VARCHAR2,     -- transaction id
	date_fmt      IN  VARCHAR2,     -- date format
        time_fmt      IN  VARCHAR2,     -- time format
        ttz_fmt       IN  VARCHAR2,     -- time with time zone format
        timestamp_fmt IN  VARCHAR2,     -- timestamp format
        tstz_fmt      IN  VARCHAR2,     -- timestamp with time zone format
        tsltz_fmt     IN  VARCHAR2,     -- timestamp with local timezone format
	types         OUT TYPE_ARY,     -- output array for types 
                                        -- of the arguments
        forms         OUT TYPE_ARY,     -- output array for forms
                                        -- of the arguments
	vals          OUT VAL_ARY       -- output array of the values 
       );
  -- This procedure returns the text version of the various arguments for the
  -- given call. The exceptions returned by this function are the same ones
  -- as returned by get_arg_type and get _xxx_arg.

END dbms_defer_query;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_defer_query FOR dbms_defer_query
/
GRANT EXECUTE on dbms_defer_query TO DBA
/

CREATE OR REPLACE PACKAGE dbms_defer AS
  -------------------
  --  OVERVIEW
  -- 
  -- This package is the user interface to a replicated transactional 
  -- deferred remote
  -- procedure call facility.  Replicated applications use the calls 
  -- in this interface
  -- to queue procedure call for later transactional execution at remote nodes.
  -- These routines are typically called from either after row triggers 
  -- or application
  -- specified update procedures.
  ------------
  --  SECURITY
  --
  -- This package is not granted to public because a user can 
  -- potentially steal the rights of the user pushing the deferred rpcs.
  -- Be careful when granting execute privileges on dbms_defer.
  -------------
  --  CONSTANTS
  --
  --    The following constants are deprecated, please
  --    use the corresponding one defined in DBMS_DEFER_QUERY.
  --
  arg_type_num       CONSTANT NUMBER := dbms_defer_query.arg_type_num;
  arg_type_char      CONSTANT NUMBER := dbms_defer_query.arg_type_char;
  arg_type_varchar2  CONSTANT NUMBER := dbms_defer_query.arg_type_varchar2;
  arg_type_date      CONSTANT NUMBER := dbms_defer_query.arg_type_date;
  arg_type_rowid     CONSTANT NUMBER := dbms_defer_query.arg_type_rowid;
  arg_type_raw       CONSTANT NUMBER := dbms_defer_query.arg_type_raw;
  arg_type_blob      CONSTANT NUMBER := dbms_defer_query.arg_type_blob;
  arg_type_clob      CONSTANT NUMBER := dbms_defer_query.arg_type_clob;
  arg_type_bfil      CONSTANT NUMBER := dbms_defer_query.arg_type_bfil;
  arg_type_cfil      CONSTANT NUMBER := dbms_defer_query.arg_type_cfil;
  arg_type_time      CONSTANT NUMBER := dbms_defer_query.arg_type_time;
  arg_type_ttz       CONSTANT NUMBER := dbms_defer_query.arg_type_ttz;
  arg_type_timestamp CONSTANT NUMBER := dbms_defer_query.arg_type_timestamp;
  arg_type_tstz      CONSTANT NUMBER := dbms_defer_query.arg_type_tstz;
  arg_type_iym       CONSTANT NUMBER := dbms_defer_query.arg_type_iym;
  arg_type_ids       CONSTANT NUMBER := dbms_defer_query.arg_type_ids;
  arg_type_tsltz     CONSTANT NUMBER := dbms_defer_query.arg_type_tsltz;
  -----------
  --    The following constants are deprecated, please
  --    use the corresponding one defined in DBMS_DEFER_QUERY.
  arg_csetid_none       CONSTANT NUMBER := dbms_defer_query.arg_csetid_none;
  arg_form_none         CONSTANT NUMBER := dbms_defer_query.arg_form_none;
  arg_form_implicit     CONSTANT NUMBER := dbms_defer_query.arg_form_implicit;
  arg_form_nchar        CONSTANT NUMBER := dbms_defer_query.arg_form_nchar;
  arg_form_any          CONSTANT NUMBER := dbms_defer_query.arg_form_any;
  --     definition same as dbms_repcat_mas.repcat_status_normal
  --     (don't want to require repcat to be loaded)
  repcat_status_normal  CONSTANT NUMBER := 0.0;
  --
  ---------
  --  TYPES
  --
  --    node list type used for the defer_txn call
  --      representation is an array (table) indexed from 1 up to a NULL
  --      entry or NO_DATA_FOUND
  TYPE node_list_t IS TABLE OF  VARCHAR2(128) INDEX BY BINARY_INTEGER;
  --
  -----------------
  --  EXCEPTIONS
  --
  --  Parameter type does not match actual type. 
  bad_param_type EXCEPTION;
  PRAGMA exception_init(bad_param_type, -23325);
  bad_param_num NUMBER := -23325;

  --  The database is being quiesced.
  deferred_rpc_quiesce EXCEPTION;
  PRAGMA exception_init(deferred_rpc_quiesce, -23326);
  quiesce_num NUMBER := -23326;
  quiesce_msg VARCHAR(76) := 'the system is being quiesced.';

  --  Generic errors that are not important enough for specific exceptions
  --  string text will explain them further.  These are internal errors.
  --  message varies.
  dbms_defererror EXCEPTION;
  PRAGMA exception_init(dbms_defererror, -23305);
  deferror_num NUMBER := -23305;

  --  
  --    dbms_defer package detects mal-formed call (e.g. argument count
  --     miss-match).  Message varies.
  malformedcall EXCEPTION;
  PRAGMA  exception_init(malformedcall, -23304);  
  malformed_num NUMBER := -23304;

  --   generic exceptions that (user-written) deferred procedures 
  --   can raise to indicate
  --   that the remote update has failed because of data updates by concurrent 
  --   transactions.  A deferror table record will be created by the deferred 
  --    rpc executor
  updateconflict  EXCEPTION;
  PRAGMA  exception_init(updateconflict, -23303);
  conflict_num NUMBER := -23303;
  conflict_msg VARCHAR(76) := 'Remote update failed due to conflict.';

  --   generic exceptions that (user-written) deferred procedures 
  --   can raise to indicate 
  --   that the remote update has failed because communications failures
  --   so that a a deferror table record will not be created by the 
  --   deferred rpc 
  --   executor.

  condescfailure  EXCEPTION; -- connection description for remote db not found
  PRAGMA  exception_init(condescfailure, -2019);
  condescfail_num NUMBER := -2019;

  commfailure  EXCEPTION;
  PRAGMA  exception_init(commfailure, -23302);
  commfail_num NUMBER := -23302;
  commfail_msg VARCHAR(76) := 
                         'Remote update failed due to communication failure';

  noparalprop  EXCEPTION;
  PRAGMA  exception_init(noparalprop, -26575);
  noparalprop_num NUMBER := -26575;

  --   mixed use repcat determined destinations and non-repcat destinations
  --   in one transaction 
  mixeddest  EXCEPTION;
  PRAGMA  exception_init(mixeddest, -23301);
  mixeddest_num NUMBER := -23301;
  mixeddest_msg VARCHAR(76) := 
           'Destinations for transaction not consistently specified';

  --   parameter length exceed deferred rpc limits (2000 char/varchar2, 
  --   255 raw) in one transaction 
  parameterlength  EXCEPTION;
  PRAGMA  exception_init(parameterlength, -23323);
  paramlen_num NUMBER := -23323;
  paramlen_msg VARCHAR(76) := 'parameter length exceeds deferred rpc limits';

  --   deferred rpc execution is disabled
  executiondisabled  EXCEPTION;
  PRAGMA  exception_init(executiondisabled, -23354);
  executiondisabled_num NUMBER := -23354;
  paramlen_msg VARCHAR(76) := 'parameter length exceeds deferred rpc limits';

  --   deferred rpc processing is disabled
  rpcdisabled  EXCEPTION;
  PRAGMA  exception_init(rpcdisabled, -23473);
  rpcdisabled_num NUMBER := -23473;
  ----------------------
  --  PROCEDURES
  --
  PROCEDURE commit_work(commit_work_comment IN VARCHAR2);
  --  Perform a transaction commit after checking for well-formed 
  --    deferred RPCs.
  --    Must be used instead of the commit work sql call for 
  --    transactions deferring RPCS.
  --    Updates the comment_comment and commit_scn fields in 
  --    the def$_txn table.
  --  Input parameters:
  --    commit_work_comment
  --      Up to fifty characters to describe the transaction 
  --        in the def$_txns
  --        table and system two-phase commit tables (this latter 
  --        once we figure out
  --        how to get it in.)  Comment is truncated to fifty characters.
  --  Exceptions
  --    ORA-23304 (malformedcall) if there is an defer_rpc_arg 
  --      call missing or defer_txn
  --      was not called for this transaction.
  --
  --
  --
  --  Transaction and call deferral procedures
  --    A deferred transaction consist of the following:
  --      Call to dbms_defer.transaction (this is optional, the first call to 
  --      dbms_defer.call will call transaction)
  --      one or more complete calls, each of which consists of 
  --        Call to dbms_defer.call
  --           zero of more calls (depending on arg_count in 
  --           dbms_defer.call) to dbms_defer.arg_*
  --      commit or call to commit_work
  -- 
  --  DESTINATION SPECIFICATION
  --  Destinations can be specified in several ways
  --  A) All deferred procedures are in repcat and the default list is
  --     NOT specified in the transaction call.
  --  OR
  --  B) destinations are specified without repcat using the following order 
  --     of precedence
  --   1) list specified in the nodes parameter to dbms_defer.call
  --   2) list specified in the nodes parameter to dbms_defer.transaction
  --   3) list specified in defdefaultdest table.
  --   The mixeddest exception is raised if an attempt to mix destinations
  --   modes is detected.
  --
  PROCEDURE transaction;
  PROCEDURE transaction(nodes      IN node_list_t);
  --  Mark a transaction as deferred (as containing deferred RPCs )
  --     This call is optional.  The first call to dbms_defer.call 
  --     in a transaction will call
  --     deftxn (with no arguments) if it has not been previously called.
  --     Input parameters are optional, and if they are not 
  --     specified the destination
  --     list is taken from the system defaults stored in the 
  --     def$_defaultdest table and
  --     maintained by the dbms_defer_sys.add_default_node and 
  --     dbms_defer_sys.delete_default_node calls
  --  Input parameters:
  --    nodes
  --      Table containing a list of nodes (dblink) to propagate the 
  --      deferred calls of the 
  --        transaction to.  Indexed from 1 until a NULL entry is
  --        found or NO_DATA_FOUND is raised.  
  --        Case insensitive comparison
  --        used for node lists.
  --        Use of this parameter overrides distribution lists as 
  --        specified in repcat.
  --  Exceptions
  --    ORA-23304 (malformedcall) if the previous transaction 
  --      not correctly formed 
  --      or terminated
  --    ORA-23319 Parameter value is not appropriate
  --    ORA-23352 Raised by dbms_defer.call if the node 
  --              list contains duplicates
  ----

  PROCEDURE call( schema_name  IN VARCHAR2,
                  package_name IN VARCHAR2,
                  proc_name    IN VARCHAR2,    
                  arg_count    IN NATURAL,
                  group_name   IN VARCHAR2 := '');

  PROCEDURE call( schema_name  IN VARCHAR2,
                  package_name IN VARCHAR2,
                  proc_name    IN VARCHAR2,
                  arg_count    IN NATURAL,
                  nodes        IN node_list_t);
  --  Defer a remote procedure call.  Automatically call 
  --    deftxn if this is the first
  --    call call of a transaction.
  --  Input parameters:
  --    schema_name
  --      Name of the schema containing the remote procedure.  For
  --      compatibility with future compile-time checking only string
  --      constants should be used.  
  --    package_name
  --      Name of the package containing the remote procedure.  For
  --      compatibility with future compile-time checking only string
  --      constants should be used.  
  --    proc_name
  --      Name of the remote procedure to call.  
  --        For compatibility with
  --        future syntactic integration
  --        and compile-time checking only string constants should be used.
  --    arg_count
  --       Number of parameters to the procedure.  This must 
  --       exactly match the number of
  --       defrpcarg_* calls immediately following the dbms_defer.call call.
  --    group_name
  --       Reserved for internal use
  --    nodes
  --      Optional table containing a list of nodes to propagate the 
  --      deferred call to.  
  --        Indexed from 1 until a NULL entry is
  --        found or NO_DATA_FOUND is raised.  
  --        Case insensitive comparison
  --        used for node lists.
  --      If not specified, the destination list is determined by the
  --      list passed to the transaction procedure, or the system defaults,
  --      Use of this parameter in any deferred call invalidate the use of
  --      the use of repcat to determine distribution lists in any
  --      calls for a transaction.
  --  Exceptions  -- 
  --  Exceptions
  --    ORA-23304 (malformedcall) if the previous call not 
  --      correctly formed (number of
  --      defrpcarg_* call not matched to arg_count).
  --    ORA-23319 Parameter value is not appropriate
  --    ORA-23352  If the destination list (specified by nodes or by a previous
  --              dbms_defer.transaction call contains a duplicate.
  ----

  PROCEDURE number_arg(arg IN nUMBER);
  --  Queue a number parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The number value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------

  PROCEDURE date_arg(arg IN DATE);
  --  Queue a date parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The date value of the parameter to the call previously 
  --      deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE varchar2_arg(arg  IN VARCHAR2);
  --  Queue a varchar2 parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The varchar2 value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  PROCEDURE nvarchar2_arg(arg IN NVARCHAR2);
  --  Queue an nvarchar2 parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The nvarchar2 value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  PROCEDURE any_varchar2_arg(arg  IN VARCHAR2 CHARACTER SET ANY_CS);
  --  Queue a varchar2 parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The varchar2 value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  PROCEDURE char_arg(arg  IN CHAR);
  --  Queue a char parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The char value of the parameter to the call previously 
  --        deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  PROCEDURE nchar_arg(arg IN NCHAR);
  --  Queue an nchar parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The nchar value of the parameter to the call previously 
  --        deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  PROCEDURE any_char_arg(arg  IN CHAR CHARACTER SET ANY_CS);
  --  Queue a char parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The char value of the parameter to the call previously 
  --        deferred with a 
  --        dbms_defer.call call. The length of arg is limited to 2000.
  --  Exceptions: 
  --    whatever error sql gives if arg exceeds 2000 characters.

  ---------------------
  -- rowids can not be
  -- used on different nodes.  It might be reasonable to use a
  -- rid in a deferred call 
  -- to a local node, but be careful.
  PROCEDURE rowid_arg(arg IN ROWID);
  --  Queue a rowid parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The rowid value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: 
  --    dbms_deferError
  --------

  -- The following calls will not be supported until dbms_sql 
  -- supports 
  -- 
  PROCEDURE raw_arg(arg IN raw);
  --  Queue a rowid parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The raw value of the parameter to the call 
  --        previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: 
  --    dbms_deferError
  --------

  PROCEDURE blob_arg(arg IN BLOB);
  --  Queue a BLOB for a deferred call.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

  PROCEDURE clob_arg(arg IN CLOB);
  --  Queue a CLOB for a deferred call.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

  PROCEDURE any_clob_arg(arg IN CLOB CHARACTER SET ANY_CS);
  --  Queue a CLOB for a deferred call.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

  PROCEDURE nclob_arg(arg IN NCLOB);
  --  Queue an NCLOB for a deferred call.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

  PROCEDURE time_arg(arg IN TIME_UNCONSTRAINED);
  --  Queue a time parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The time value of the parameter to the call previously 
  --      deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE timestamp_arg(arg IN TIMESTAMP_UNCONSTRAINED);
  --  Queue a timestamp parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The timestamp value of the parameter to the call previously 
  --      deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE ttz_arg(arg IN TIME_TZ_UNCONSTRAINED);
  --  Queue a time with time zone parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The time with time zone value of the parameter to the call previously 
  --      deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE tstz_arg(arg IN TIMESTAMP_TZ_UNCONSTRAINED);
  --  Queue a timestamp with time zone parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The timestamp with time zone value of the parameter to the call
  --      previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE tsltz_arg(arg IN TIMESTAMP_LTZ_UNCONSTRAINED);
  --  Queue a timestamp with local timezone parameter value for a deferred call.
  --  Input parameter:
  --    arg
  --      The timestamp with local time zone value of the parameter to the call
  --      previously deferred with a
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------

  PROCEDURE iym_arg(arg IN YMINTERVAL_UNCONSTRAINED);
  --  Queue a interval year to month parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The interval year to month value of the parameter to the call
  --      previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
  PROCEDURE ids_arg(arg IN DSINTERVAL_UNCONSTRAINED);
  --  Queue a interval date to second parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The interval date to second value of the parameter to the call
  --      previously deferred with a 
  --        dbms_defer.call call.
  --  Exceptions: none.
  --------
    
--  PROCEDURE bfile_arg(arg IN BFILE);
  --  Queue the contents of a binary file for a deferred call.  The contents
  --    are interpreted and stored as a BLOB.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

--  PROCEDURE cfile_arg(arg IN CFILE);
  --  Queue the contents of a binary file for a deferred call.  The contents
  --    are interpreted and stored as a CLOB.
  --  Input parameter:
  --    arg 
  --      The value of the parameter to the call previously 
  --        deferred with a dbms_defer.call call.
  --------

  PROCEDURE anydata_arg(arg IN Sys.AnyData);
  --  Queue a anydata for the parameter value for a deferred call.
  --  Input parameter:
  --    arg 
  --      The user data
  --      previously deferred with a dbms_defer.call call.
  --      The supported types are Collections and Object types.
  --      It does not support REF types, Opaque types, AnyData, AnyType and
  --      AnyDataSet.
  --------

  --
  -- Public procs for parallel prop txn log records
  --

  PROCEDURE record_transaction(origin_site_p        IN VARCHAR2,
                               origin_dblink_p      IN VARCHAR2,
                               transaction_number_p IN NUMBER);
  -- Record transaction in def$_origin as current connected user
  --
  -- Inputs:
  --    origin_site_p
  --      fully qualified global name of the pushing site
  --    origin_dblink_p
  --      dblink used by the pushing site (may have a qualifier)
  --    transaction_number_p
  --      trans seq number to record
  --------
  --------

  PROCEDURE purge_transaction_log(origin_site_p        IN VARCHAR2,
                                  origin_dblink_p      IN VARCHAR2,
                                  transaction_number_p IN NUMBER);
  -- Purge from def$_origin all txns with given parameters and current
  --   connected user id
  -- Inputs:
  --   origin_site_p
  --      fully qualified global name of the pushing site
  --    origin_dblink_p
  --      dblink used by the pushing site (may have a qualifier)
  --    transaction_number_p
  --      least transaction seq number to retain
  --------
  --------

  --
  -- Public procs for parallel prop recovery set retrieval
  --

  PROCEDURE get_txn_log_runs(
      origin_site IN VARCHAR2,
      origin_dblink IN VARCHAR2,
      in_tran_seq IN NUMBER);
  --  Initialize for retrieving run-encoded set of txn sequence numbers
  --    from destination site
  --  Input parameters:
  --    origin_site
  --      fully qualified global name of the pushing site
  --    origin_dblink
  --      dblink used by the pushing site (may have a qualifier)
  --    in_tran_seq
  --      initial trans seq number to return (all earlier seqs
  --      are known by pushing site already)
  --
  --   It's obsolete in 8.2[+].
  --------
  --------

  PROCEDURE get_next_txn_log_run(
      run_seq       OUT NUMBER,
      run_len       OUT NUMBER,
      scn_first     OUT NUMBER,
      id_first      OUT VARCHAR2,
      scn_last      OUT NUMBER,
      id_last       OUT VARCHAR2);
  --  Retrieve next run of applied txn sequence numbers
  --    as specified by prior call to get_txn_log_runs
  --  Runs are returned in increasing order by seq
  --    which is also increasing order by commit number
  --    (i.e. <scn, id>)
  -- Outputs:
  --   run_seq, run_len
  --     returned run bounds; an empty (0-length) run indicates
  --     end-of-data
  --   scn_first, id_first
  --     commit number of first txn in run
  --   scn_last, id_last
  --     commit number of last txn in run
  --
  --   It's obsolete in 8.2[+].
  --------
  --------

END dbms_defer;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_defer FOR dbms_defer
/
GRANT EXECUTE ON dbms_defer TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_defer_sys AS
  -------------------
  --  OVERVIEW
  -- 
  -- This package is the system administrator  interface to a replicated 
  -- transactional deferred remote
  -- procedure call facility.  Administrators and replication 
  -- deamons can execute
  -- transactions queued for remote nodes using this facility 
  -- and administrators
  -- can control the nodes to which remote calls are destined.
  ------------
  --  SECURITY
  --
  -- By default, this package is owned by user SYS and 
  -- execution should be granted
  -- only to administrators and deamons that perform 
  -- replication administration and
  -- execute deferred transactions.  See the security considerations for 
  -- the dbms_defer package for related considerations.
  -------------
  --  EXCEPTIONS
  --
  --  Parameter type does not match actual type. Message varies.
  crt_err_err EXCEPTION;
  PRAGMA exception_init(crt_err_err, -23324);
  crt_err_num NUMBER := -23324;
  crt_err_msg  VARCHAR(76) := 'Error creating deferror entry: ';

  --  Replication is not linked as an option
  norepoption EXCEPTION;
  PRAGMA exception_init(norepoption, -2094);   
  norepoption_num NUMBER := -2094;

  -- Invalid user
  missinguser EXCEPTION;
  PRAGMA exception_init(missinguser, -23362);
  missinguser_num NUMBER := -23362;

  -- Already the propagator
  alreadypropagator EXCEPTION;
  PRAGMA exception_init(alreadypropagator, -23393);
  alreadypropagator_num NUMBER := -23393;

  -- Duplicate propagator
  duplicatepropagator EXCEPTION;
  PRAGMA exception_init(duplicatepropagator, -23394);
  duplicatepropagator_num NUMBER := -23394;

  -- Missing propagator
  missingpropagator EXCEPTION;
  PRAGMA exception_init(missingpropagator, -23357);
  missingpropagator_num NUMBER := -23357;

  -- Propagator in use
  propagator_inuse EXCEPTION;
  PRAGMA exception_init(propagator_inuse, -23418);
  propagator_inuse_num NUMBER := -23418;

  -- Incomplete parallel propagation/push, added for bug 430300
  incompleteparallelpush EXCEPTION;
  PRAGMA exception_init(incompleteparallelpush, -23388);
  incompleteparallelpush_num NUMBER := -23388;

  -- purge queue argument is out of range
  argoutofrange EXCEPTION;
  PRAGMA exception_init(argoutofrange, -23427);
  argoutofrange_num NUMBER := -23427;

  -- there are deferred RPC for some destination
  notemptyqueue EXCEPTION;
  PRAGMA exception_init(notemptyqueue, -23426);
  notemptyqueue_num NUMBER := -23426;

  -- serial propagation can not be used
  serialpropnotallowed EXCEPTION;
  PRAGMA exception_init(serialpropnotallowed, -23495);
  serialpropnotallowed_num NUMBER := -23495;

  cantsetdisabled EXCEPTION;
  PRAGMA exception_init(cantsetdisabled, -23496);
  cantsetdisabled_num NUMBER := -23496;

  -------------
  --  CONSTANTS

  --
  -- constants for result of push or purge
  --
  result_ok                    BINARY_INTEGER := 0;
    -- okay, terminated after delay_seconds expired
  result_startup_seconds       BINARY_INTEGER := 1;
    -- terminated by lock timeout while starting
  result_execution_seconds     BINARY_INTEGER := 2;
    -- terminated by exceeding execution_seconds
  result_transaction_count     BINARY_INTEGER := 3;
    -- terminated by exceeding transaction_count
  result_delivery_order_limit  BINARY_INTEGER := 4;
    -- terminated at delivery_order_limit
  result_errors                BINARY_INTEGER := 5;
    -- terminated after errors
  result_push_disabled         BINARY_INTEGER := 6;
    -- terminated after detecting that propagation is disabled
  result_purge_disabled        BINARY_INTEGER := 6;
    -- terminated after detecting that purge is disabled
  result_cant_get_sr_enq       BINARY_INTEGER := 7;
    -- terminated after failing to acquire SR enqueue

  --
  -- constants for purge_method in purge_queue
  --
  purge_method_quick   BINARY_INTEGER := 1;
  purge_method_precise BINARY_INTEGER := 2;
  --
  -- constants for parameter defaults
  --
  seconds_infinity          BINARY_INTEGER := 60*60*24*180;
  transactions_infinity     BINARY_INTEGER := 1000000000;
  delivery_order_infinity   NUMBER := 100000000000000000000;

  --  PROCEDURES

  -- manage default replication node lists

  PROCEDURE add_default_dest(dblink IN VARCHAR2);
  --  Add a node to the default list for replication targets.
  --  Input parameters
  --    dblink
  --      name of the node (dblink) to add tRo the default list.
  --  Exceptions 
  --    ORA-23352
  --     dblink is already in the default list.
  ----------
 
  PROCEDURE delete_default_dest(dblink IN VARCHAR2);
  --  Delete a node from the default list for replication targets
  --  Input parameters
  --    dblink
  --      name of the node (dblink) to delete from the default list.
  --      Operation is a no-op if dblink is not in the list.
  --  Exceptions
  --    none.
  -----------------

  FUNCTION push(
      destination          IN VARCHAR2,
      parallelism          IN BINARY_INTEGER := 0,
      heap_size            IN BINARY_INTEGER := 0,
      stop_on_error        IN BOOLEAN := FALSE,
      write_trace          IN BOOLEAN := FALSE,
      startup_seconds      IN BINARY_INTEGER := 0,
      execution_seconds    IN BINARY_INTEGER := seconds_infinity,
      delay_seconds        IN BINARY_INTEGER := 0,
      transaction_count    IN BINARY_INTEGER := transactions_infinity,
      delivery_order_limit IN NUMBER := delivery_order_infinity
  ) RETURN BINARY_INTEGER;
  --
  -- Push transactions queued for destination node, choosing either
  --   serial or parallel propagation.
  --
  -- Parameters:
  --   destination
  --     name of destination (dblink) to push to
  --   parallelism
  --     max degree of parallelism of the push
  --     0 = (old algorithm) serial propagation
  --     1 = (new algorithm) parallel propagation with only 1 slave
  --     n = (new algorithm) parallel propagation with n slaves
  --   heap_size
  --     if > 0, max number of txns to be examined simultaneously for
  --     parallel scheduling computation; default is to compute this
  --     from specified parallelism
  --   stop_on_error
  --     stop on first error even if not fatal
  --   write_trace
  --     record execution result value and non-fatal errors in trace file
  --   startup_seconds
  --     max secs to wait for another instance of push
  --     (pushing to the same destination) to finish
  --   execution_seconds
  --     shutdown cleanly after this many seconds of real time
  --   delay_seconds
  --     shutdown cleanly if queue is empty for this long
  --   transaction_count
  --     shutdown cleanly after pushing this many transactions
  --   delivery_order_limit
  --     shutdown cleanly before pushing a transaction with
  --     delivery_order >= delivery_order_limit
  --
  -- Result:
  --   a value from the constants
  --     dbms_defer_sys.result_%
  --   indicating how the push completed
  --
  ----------------

  PROCEDURE execute(destination       IN VARCHAR2,
                    stop_on_error     IN BOOLEAN := FALSE,
                    transaction_count IN BINARY_INTEGER := 0,
                    execution_seconds IN BINARY_INTEGER := 0,
		    execute_as_user   IN BOOLEAN,
                    delay_seconds     IN NATURAL := 0,
                    batch_size        IN NATURAL := 0);
  -- The execute_as_user parameter is obsolete and ignored.
  -----------------

  PROCEDURE execute(destination       IN VARCHAR2,
                    stop_on_error     IN BOOLEAN := FALSE,
                    transaction_count IN BINARY_INTEGER := 0,
                    execution_seconds IN BINARY_INTEGER := 0,
                    delay_seconds     IN NATURAL := 0,
                    batch_size        IN NATURAL := 0);
  --  Execute transactions queued for destination_node using the security
  --  context of the propagator. stop_on_error 
  --  determines whether processing of subsequent transaction continues
  --  after an error is detected. 
  --  deftrandest (and defcalldest if appropriate) entries 
  --  for the successfully executed transactions are deleted and if there
  --  are no other references, the defcall and deftran entries are deleted.
  --
  --  Input Parameters:
  --    destination
  --      node (dblink) at which to execute 
  --      deferred transaction.  Case
  --      insensitive comparisons used.
  --    stop_on_error
  --      If TRUE, execution of queued transactions will 
  --      alway stop when an error is
  --      encountered, leaving unattempted transaction in 
  --      the queue.  If FALSE,
  --      execution continues except when errors that appear 
  --      to mean that node is 
  --      unavailable are encountered, it which case execution 
  --      always stops, leaving
  --      unattempted transactions queued.
  --    transaction_count
  --      If positive, at most this many transactions will be executed.
  --    executions_seconds
  --      If positive, execution will stop after completions of the
  --      last transaction after this many seconds of executions.
  --    delay_seconds
  --      If positive, the routine will sleep for this many seconds before
  --      returning when it finds no deferred RPCs queued for the destination
  --      Non-zero values can reduce execution overhead compared to calling
  --      dbms_defer_sys.execute from a tight loop.
  --    batch_size
  --      The number of deferred rpc calls should be executed before 
  --      committing deferred transactions.  If batch_size is 0 a commit will
  --      occur after each deferred transaction.  If batch_size is greater than
  --      zero a commit will occur when the total number of deferred calls
  --      executed exceeds batch_size and a complete transaction has been
  --      executed.
  --
  --  Exceptions
  --    Raises the last exception encountered before execution 
  --    stops because of 
  --    an exception.
  ----------------

  PROCEDURE execute_error(deferred_tran_id IN VARCHAR2,
                          destination      IN VARCHAR2);
  --  (Re)Execute transactions that previously encountered conflicts. 
  --  Each transaction is executed in the security context of the original
  --  receiver of the transaction.
  --  Execution stops when any error is encountered.  If some input is null,
  --  then each transaction is committed as it completes. If exactly one 
  --  transaction is specified, then the transactions is not committed.
  --  Upon successful execution, transactions are removed for deferror, and if
  --  there are no other references, entries are deleted from 
  --  defcall and deftran.
  --  Input Parameters:
  --    deferred_tran_id
  --      The identifier of the transaction to be reexecuted.
  --      If null then all transactions in deferror matching
  --      destination (as specified) are re-executed.
  --    destination
  --      dblink that transaction was originally destined to.
  --      Must not be null.
  --  Exceptions
  --    Raises an exception if destination is null.
  --    Raises an exception if the original receiver is an invalid user.
  --    Raises the last exception encountered before execution 
  --    stops because of an exception.
  ----------------

  PROCEDURE execute_error_as_user(deferred_tran_id IN VARCHAR2,
                                  destination      IN VARCHAR2);
  --  (Re)Execute transactions that previously encountered conflicts.
  --  Each transaction is executed in the security context of the connected
  --  user.
  --  Execution stops when any error is encountered.  If some input is null,
  --  then each transaction is committed as it completes. If exactly one 
  --  transaction is specified, then the transactions is not committed.
  --  Upon successful execution, transactions are removed for deferror, and if
  --  there are no other references, entries are deleted from 
  --  defcall and deftran.
  --  Input Parameters:
  --    deferred_tran_id
  --      The identifier of the transaction to be reexecuted.
  --      If null then all transactions in deferror matching 
  --      destination (as specified) are re-executed.
  --    destination
  --      dblink that transaction was originally destined to.
  --      Must not be null.
  --  Exceptions
  --    Raises an exception if destination is null.
  --    Raises the last exception encountered before execution 
  --    stops because of an exception.
  ----------------

  PROCEDURE delete_tran(deferred_tran_id IN VARCHAR2,
                        destination      IN VARCHAR2);
  --  Delete transactions from  queues. Deletes deftrandest (and defcalldest
  --  entries if appropriate.  If there are not other references,
  --  deftran and defcall entries are deleted.
  --  Input Parameters:
  --    destination
  --      dblink for which transaction(s) are to be removed from queues.
  --      If null, the transaction specified by the other parameters are 
  --      deleted from queues for all destinations.
  --    deferred_tran_id
  --      The identifier of the transaction to be deleted
  --      If null then all transactions matching destination
  --      are deleted.
  --  Exceptions
  --    tid and/or node not found.
  ---------------
  PROCEDURE delete_error(deferred_tran_id IN VARCHAR2,
                         destination      IN VARCHAR2);

  --  Delete transactions from  deferror table. If there are 
  --  not other references,
  --  deftran and defcall entries are deleted.
  --  Input Parameters:
  --    destination
  --      destination for which transaction(s) are to be removed from 
  --      deferror.
  --      If null, the transaction specified by the other parameters are 
  --      deleted from deferror for all destinations.
  --    deferred_tran_id
  --      The identifier of the transaction to be deleted
  --      If null then all transactions matching destination and 
  --      are deleted.
  --  Exceptions
  --    tid and/or node not found.
  ---------------

  PROCEDURE schedule_execution(dblink         IN VARCHAR2,
                               interval       IN VARCHAR2,
                               next_date      IN DATE,
                               reset          IN BOOLEAN default FALSE,
                               stop_on_error  IN BOOLEAN := NULL,
                               transaction_count IN BINARY_INTEGER := NULL,
                               execution_seconds IN BINARY_INTEGER := NULL,
            		       execute_as_user   IN BOOLEAN,
                               delay_seconds     IN NATURAL := NULL,
                               batch_size        IN NATURAL := NULL);
  -- The execute_as_user parameter is obsolete and ignored.
  -----------------

  PROCEDURE schedule_execution(dblink         IN VARCHAR2,
                               interval       IN VARCHAR2,
                               next_date      IN DATE,
                               reset          IN BOOLEAN default FALSE,
                               stop_on_error  IN BOOLEAN := NULL,
                               transaction_count IN BINARY_INTEGER := NULL,
                               execution_seconds IN BINARY_INTEGER := NULL,
                               delay_seconds     IN NATURAL := NULL,
                               batch_size        IN NATURAL := NULL);
  -- Insert or update a defschedule entry and signal the background process.
  -- this procedure does a commit;
  -- Input Parameters:
  --   dblink
  --     Queue name to schedule execution for;
  --   interval
  --     If non-null then DefSchedule.interval for dblink is set to this 
  --     value. If null and the DefSchedule entry for dblink exists, 
  --     the value of DefSchedule.interval is not modified. If 
  --     null and the DefSchedule entry 
  --     for dblink does not exist, then the DefSchedule entry for 
  --     dblink is created with a null interval value.
  --   next_date
  --     If non-null then DefSchedule.next_date for dblink is set to this 
  --     value. If null and the DefSchedule entry for dblink exists, the value
  --     of DefSchedule.next_date is not modified. If null and 
  --     the DefSchedule entry 
  --     for dblink does not exist, then the DefSchedule entry 
  --     for dblink is created with a null next_date value.
  --   reset
  --     If TRUE then last_txn_count, last_error, and last_msg are nulled.
  --    stop_on_error
  --    transaction_count
  --    execution_seconds
  --    delay_seconds
  --    batch_size
  --      If non-null, these parameters are passed to the
  --      dbms_defer_sys.execute call that is scheduled for execution by
  --      this call.
  -----------------

  PROCEDURE schedule_push(
      destination          IN VARCHAR2,
      interval             IN VARCHAR2,
      next_date            IN DATE,
      reset                IN BOOLEAN := FALSE,
      parallelism          IN BINARY_INTEGER := NULL,
      heap_size            IN BINARY_INTEGER := NULL,
      stop_on_error        IN BOOLEAN := NULL,
      write_trace          IN BOOLEAN := NULL,
      startup_seconds      IN BINARY_INTEGER := NULL,
      execution_seconds    IN BINARY_INTEGER := NULL,
      delay_seconds        IN BINARY_INTEGER := NULL,
      transaction_count    IN BINARY_INTEGER := NULL
  );
  --
  -- Schedule a job to invoke push
  --
  -- Parameters:
  --   interval
  --     used to calculate the next next_date, via
  --       select _interval_ into next_date from dual;
  --   next_date
  --     the next date that the queue will be pushed
  --     to the specified destination
  --   reset
  --     if TRUE then last_txn_count, last_error, and last_msg
  --     are nulled in the def$_destination row for the
  --     specified destination
  --
  --   remaining parameters are as for push
  -----------------

  PROCEDURE unschedule_execution(dblink         IN VARCHAR2);
  --  Delete a defschedule entry. Signal to background process to stop 
  --  servicing this queue.
  --  Obsolescent; use unschedule_push, below.
  -- Input Parameters:
  --   dblink
  --     Queue name to stop automatic execution of.
  -- Exceptions:
  --   NO_DATA_FOUND
  --     no entry for dblink in DefSchedule.
  -----------------

  PROCEDURE unschedule_push(dblink IN VARCHAR2);
  --  Delete a defschedule entry.
  --  Signal to background process to stop servicing this queue.
  --  Input Parameters:
  --   dblink
  --     Queue name to stop automatic execution of.
  --  Exceptions:
  --   NO_DATA_FOUND
  --     no entry for dblink in DefSchedule.
  -----------------

  FUNCTION disabled(destination IN VARCHAR2,
                    catchup     IN RAW := '00') RETURN BOOLEAN;
  --
  --   Test whether disabled for given destination.
  --
  --   Parameters:
  --     destination or NULL (which implicitly identifies the purge row)
  --     catchup: extension ID if any
  --   Returns:
  --     TRUE iff the deferred RPC queue is disabled for the given
  --     destination.
  --
  --   Raises the following exceptions:
  --       no_data_found:
  --          if the "destination" does not appear in defschedule.
  -----------------

  PROCEDURE set_disabled(destination IN VARCHAR2,
                         disabled    IN BOOLEAN := TRUE,
                         catchup     IN RAW := '00',
                         override    IN BOOLEAN := FALSE);
  --
  --   Turn on/off the disabled state for a destination.
  --
  --   Parameters:
  --     destination
  --       name of dest site, or NULL (implicitly identifies the purge row)
  --     disabled
  --       on/off
  --     catchup
  --       extension ID if any
  --     override
  --       see comment below
  --       WARNING: Do not set this parameter unless directed to do so by
  --                Oracle Support Services.
  --
  --     If "disabled" is TRUE, disable propagation to the given
  --   "destination." All future invocations of dbms_defer_sys.execute
  --   will not be able to push the deferred RPC queue to this
  --   destination until it is enabled.  This function has no effect
  --   on a session already pushing the queue to the given
  --   destination.  This function has no effect on sessions appending
  --   to the queue with dbms_defer.
  --     If "disabled" is FALSE, enable propagation to the given "destination."
  --   Although this does not push the queue, it permits future invocations
  --   of dbms_defer_sys.execute to push the queue to the given destination.
  --     In either case, a COMMIT is required for this to take effect in other
  --   sessions.
  --   If "override" is TRUE, it ignores whether the disabled state
  --   was set internally for synchronization and always tries to set
  --   the state as specified by the "disabled" parameter.
  --
  --   Raises the following exceptions:
  --      no_data_found:
  --        if the "destination" does not appear in defschedule.
  --      dbms_defer_sys.cantsetdisabled:
  --        if the disabled was set internally for synchronization.
  -----------------

  PROCEDURE register_propagator(username IN VARCHAR2);
  -- Register the given user as the propagator for the local database. It
  -- also grants to the given user CREATE SESSION, CREATE PROCEDURE,
  -- CREATE DATABASE LINK and EXECUTE ANY PROCEDURE
  -- privileges (so that the user can create wrappers).
  -- It ensures that only one user is the propagator.  It ignores any existing
  -- invalid propagator that may be in the catalog.
  -- Input Parameters:
  --   username
  --     Name of the user
  -- Exceptions:
  --   missinguser
  --     The given user does not exist.
  --   alreadypropagator
  --     The given user is already the propagator.
  --   duplicatepropagator
  --     There is already a different propagator.
  -----------------

  PROCEDURE unregister_propagator(username IN VARCHAR2,
                                  timeout  IN INTEGER
                                                    DEFAULT dbms_lock.maxwait);
  -- Unregister the given user as the given propagator for the local database.
  -- It also revokes all privileges that were granted by register_propagator()
  -- from the given user, including those identical privileges that were
  -- granted independently of register_propagator().
  -- It drops any existing genereted wrappers in the schema of the given
  -- propagator, and marks them as dropped in the replication catalog.
  -- If the propagator is in use, it will wait until the provided timeout
  -- (in seconds), then an exception will be raised.
  -- Input Parameters:
  --   username
  --     Name of the user
  --   timeout
  --     Timeout in seconds.  If the propagator is in use, it will wait until
  --     the given timeout.  The default value is dbms_lock.maxwait.
  -- Exceptions:
  --   missingpropagator
  --     The given user is not the propagator.
  --   propagator_inuse
  --     The propagator is in use, thus cannot be unregistered. Try later.
  -----------------

  FUNCTION exclude_push(timeout IN INTEGER) RETURN INTEGER;
  -- Acquire an exclusive lock that prevents deferred transaction push
  --   (either serial or parallel).
  --
  -- Input:
  --   timeout
  --     Timeout in seconds.  If the lock cannot be acquired within this
  --     time period (either because of an error or because a push is
  --     currently under way) then the call returns a value of 1 (see
  --     below).
  --     A timeout value of dbms_lock.maxwait waits forever.
  -- Return value (lock held?):
  --   (as for dbms_lock.acquire(.))
  --     0 - success (Y)
  --     1 - timeout (N)
  --     2 - deadlock (N)
  --     4 - already own the lock (Y)
  --
  -- Note:
  --   ** this function does a commit **
  --   The lock is acquired with release_on_commit=>TRUE, so pushing may
  --   resume after the next commit.
  -----------------

  PROCEDURE delete_def_destination(destination IN VARCHAR2,
                                   force IN BOOLEAN := FALSE,
                                   catchup IN RAW := NULL);
  -- This procedure is to delete a row in system.def$_destination.
  -- It is used to get rid of some destination which is not active (no
  -- replication activities) and will not be active for a significant amount
  -- of time. Without that entry in def$_destination, purge_method_quick will
  -- serve its purpose by being able to purge effectively.
  --   
  -- Input:
  --   destination: the row with dblink to be deleted
  --
  --   force: ignore any safety check and delete the row anyway
  --
  --   catchup: catchup value for the destination to be deleted.
  --            If null, all the rows matching destination will be deleted.
  --
  -- Notes:
  --   1. To do that, we need to lock the site-specific lock for pushing to
  --      make sure no one is pushing at that time.
  --   2. To avoid repushing transactions after a site is deleted and then
  --      added back, we make sure there are no transactions for this site
  --      (regardless whether the transactions have been pushed or not)
  --   3. To avoid deleting the destination after an incomplete (unclean)
  --      parallel push, we have an explicit check on that.
  --   4. If force is TRUE, we will ignore condition (2) and (3). What it means
  --      is unless you are absolutely sure you want to get rid of the site
  --      (destination) and there is NO transaction for it and parallel push is
  --      clean, do NOT set force to TRUE. Otherwise, you may end up 
  --      repushing some transactions.
  --   5. To delete a dblink which has some repschema and D-type transaction,
  --      you need to remove the repschema and push, purge the D-type 
  --      transaction first.
  --   6. There is no commit in this procedure. So, the caller can rollback
  --      the change if necessary.
  ------------------

  FUNCTION purge(
      purge_method      IN BINARY_INTEGER := purge_method_quick,
      rollback_segment  IN VARCHAR2 := NULL,
      startup_seconds   IN BINARY_INTEGER := 0,
      execution_seconds IN BINARY_INTEGER := seconds_infinity,
      delay_seconds     IN BINARY_INTEGER := 0,
      transaction_count IN BINARY_INTEGER := transactions_infinity,
      write_trace       IN BOOLEAN := FALSE
  ) RETURN BINARY_INTEGER;

  -- Purge pushed transactions from the queue
  --
  -- Parameters:
  --   purge_method
  --     a value controlling cost-precision tradeoff; either
  --     purge_method_quick or purge_method_precise
  --   rollback_segment
  --     rollback segment to use while purging the queue
  --   startup_seconds
  --     max secs to wait for another instance of push
  --     (pushing to the same destination) to finish
  --   execution_seconds
  --     shutdown cleanly after this many seconds of real time
  --   delay_seconds
  --     shutdown cleanly if queue is empty for this long
  --   transaction_count
  --     shutdown cleanly after purging this many transactions
  --   write_trace
  --     record result value in trace file
  --
  -- Result:
  --   a value from the constants
  --     dbms_defer_sys.result_%
  --   indicating how the purge completed
  --
  -- Exception:
  --   argoutofrange(-23427): "argument '%s' is out of range"
  ----------

  PROCEDURE schedule_purge(
      interval          IN VARCHAR2,
      next_date         IN DATE,
      reset             IN BOOLEAN := FALSE,
      purge_method      IN BINARY_INTEGER := NULL,
      rollback_segment  IN VARCHAR2 := NULL,
      startup_seconds   IN BINARY_INTEGER := NULL,
      execution_seconds IN BINARY_INTEGER := NULL,
      delay_seconds     IN BINARY_INTEGER := NULL,
      transaction_count IN BINARY_INTEGER := NULL,
      write_trace       IN BOOLEAN := NULL
  );
  --
  -- Schedule a job to invoke purge
  --
  -- Parameters:
  --   interval
  --     used to calculate the next next_date, via
  --       select _interval_ into next_date from dual;
  --   next_date
  --     the next date that the queue will be pushed
  --     to the specified destination
  --   reset
  --     if TRUE then last_txn_count, last_error, and last_msg
  --     are nulled in the "purge" def$_destination row, i.e.,
  --     the row for this site's unqualified global name.
  --
  --   other parameters as for purge
  --

  -------------------------------------------------------------------------

  PROCEDURE unschedule_purge;
  --
  --   Delete defschedule entry for purge.
  --   Signal to background process to stop servicing purge.
  --

  -------------------------------------------------------------------------

  PROCEDURE clear_prop_statistics(dblink in VARCHAR2);
  --
  -- Clear the statistics of a destination in defschdule. This procedure
  -- will clear the following information from defschedule:
  --
  -- total_txn_count
  -- avg_throughput
  -- avg_latency
  -- total_bytes_sent
  -- total_bytes_received
  -- total_round_trips
  -- total_admin_count
  -- total_error_count
  -- total_sleep_time
  --
  -- Parameters :
  --   dblink
  --     The destination whose statistics in defschedule are to be cleared.
  --

  -------------------------------------------------------------------------

  PROCEDURE nullify_trans_to_destination(dblink IN VARCHAR2,
                                         catchup IN RAW := NULL);
  --   For internal use only.

  -------------------------------------------------------------------------

  PROCEDURE nullify_all_trans;
  --   For internal use only.

  PROCEDURE execute_error_call_as_user(deferred_tran_id IN VARCHAR2,
                                       callno           IN NUMBER);
  --   For internal use only.

  PROCEDURE execute_error_call(deferred_tran_id IN VARCHAR2,
                               callno           IN NUMBER);
  --   For internal use only.

  FUNCTION push_with_catchup(
      destination          IN VARCHAR2,
      parallelism          IN BINARY_INTEGER := 0,
      heap_size            IN BINARY_INTEGER := 0,
      stop_on_error        IN BOOLEAN := FALSE,
      write_trace          IN BOOLEAN := FALSE,
      startup_seconds      IN BINARY_INTEGER := 0,
      execution_seconds    IN BINARY_INTEGER := seconds_infinity,
      delay_seconds        IN BINARY_INTEGER := 0,
      transaction_count    IN BINARY_INTEGER := transactions_infinity,
      delivery_order_limit IN NUMBER := delivery_order_infinity,
      catchup              IN RAW := NULL
  ) RETURN BINARY_INTEGER;
  --   For internal use only.

END dbms_defer_sys;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_defer_sys FOR dbms_defer_sys
/
GRANT EXECUTE ON dbms_defer_sys TO DBA
/
