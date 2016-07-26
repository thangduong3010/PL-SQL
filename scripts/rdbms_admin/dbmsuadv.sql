Rem
Rem $Header: dbmsuadv.sql 14-may-2003.12:29:33 wyang Exp $
Rem
Rem dbmsuadv.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsuadv.sql - Undo ADVisor
Rem
Rem    DESCRIPTION
Rem      Undo advisor gives users recommendation on setting undo retention
Rem      and sizing undo tablespace.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wyang       05/14/03 - fix comments
Rem    wyang       03/24/03 - change unit
Rem    wyang       02/16/03 - change to invoke by definer
Rem    wyang       01/14/03 - use SWRF for undo advisor
Rem    wyang       01/11/03 - wyang_undousage
Rem    wyang       11/19/02 - Created
Rem

Rem ------------------------------------------------------------------------
Rem NAME
Rem  dbms_undo_adv - Undo Advisor
Rem DESCRIPTION
Rem  The package is used to provide advisors for setting undo tablespace
Rem  and set undo_retention parameter.
Rem  It has the following subprograms:
Rem    undo_info - retunes current undo tablespace name, max possible size,
Rem                if it is auto extensible, current undo retention value
Rem                and if the undo tablespace has guaranteed undo retention.
Rem    longest_query - returns the length of the longest query (between 
Rem                starttime and endtime).
Rem    required_retention - returns required undo_retention to support 
Rem                longest query based on undo stats between starttime
Rem                and endtime.
Rem    best_possible_retention - the best possible undo retention current
Rem                undo tablespace can support based on undo stats between
Rem                starttime and endtime
Rem    required_undo_size - returns required undo tablespace size to support 
Rem                undo retention based on undo stats between starttime
Rem                and endtime.
Rem    undo_health - find out the problem in undo tablespace and provide
Rem                recommendation to fix the problem. If no problem found,
Rem                return value is 0. 
Rem    undo_advisor - using advisor framework to find out problem and provide
Rem                recommendations.
Rem    Except for undo_info, all other subprograms have three versions:
Rem    Version 1: subprogram is based on historical information 
Rem               in memory or in SWRF from starttime to endtime.
Rem    Version 2: subprogram is based on historical information
Rem               in memory or in SWRF from sysdate-7 to sysdate.
Rem    Version 3: subprogram is based on historical information
Rem               in SWRF from snapid s1 to snapid s2.
Rem ------------------------------------------------------------------------

CREATE OR REPLACE TYPE dbms_uadv_arr as VARRAY(100) of NUMBER;
/

grant execute on dbms_uadv_arr to dba 
/

CREATE OR REPLACE PACKAGE dbms_undo_adv IS
  FUNCTION undo_info(table_space_name    OUT VARCHAR2,
                     table_space_size    OUT NUMBER,
                     auto_extend         OUT BOOLEAN,
                     undo_retention      OUT NUMBER,
                     retention_guarantee OUT BOOLEAN) RETURN BOOLEAN; 
  -- This function is used to get information about undo tablespace of the 
  -- current instnace. The output parameters are meaningful only when
  -- return value is TRUE.

  -- Input Parameters:
  --   None.
  
  -- Output Parameters:
  --   table_space_name: Name of the current undo tablespace the instance 
  --                     is using.
  --   table_space_size: If the undo tablespace is fixed-sized, it is
  --                     the size of the undo tablespace in MB. If the 
  --                     tablespace is auto_extensiable, it is the max 
  --                     possible size of the undo tablespace in MB. 
  --   auto_extend: TRUE if the undo tablespace is extensiable. FALSE otherwise.
  --   undo_retention: The value of init.ora parameter "undo_retention".
  --   retention_guarantee: TRUE if undo tablespace has guaranteed retention.
  --                        FALSE otherwise.

  -- RETURN:
  --   TRUE if init.ora parameters undo_managment is auto. 
  --   FALSE otherwise or some information not available. 

  -- EXCEPTIONS:
  --   None. 
  
  FUNCTION undo_autotune(autotune_enabled   OUT BOOLEAN) RETURN BOOLEAN;
  -- This function is used to find out if auto tuning of undo retention
  -- is enabled for the current undo tablespace. The output parameter is 
  -- meaningful only when return value is TRUE.

  -- Input Parameters:
  --   None.

  -- Output Parameters:
  --   autotune_enabled: TRUE if auto tuning of undo retention is enabled
  --                     FALSE otherwise.

  -- RETURN:
  --   TRUE if autotune_enabled output parameter has been set up properly.
  --   FALSE otherwise or some information is not available.

  -- EXCEPTIONS:
  --   None.

  FUNCTION longest_query(starttime IN DATE, endtime IN DATE) RETURN NUMBER;
  FUNCTION longest_query RETURN NUMBER;
  FUNCTION longest_query(s1 IN NUMBER, s2 IN NUMBER) RETURN NUMBER;
  -- This function returns the length of the longest query for a given period.
  -- If the information about the required period is not available, 0 will
  -- be returned.

  -- Input Parameters:
  --   starttime: Start time of the required period.
  --   endtime: End time of the requied period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   None.

  -- Return:
  --   length of the longest query in seconds. 0 if information about required
  --   period not available.

  -- Exceptions:
  --   None.

  FUNCTION required_retention(starttime IN DATE, endtime IN DATE)
  RETURN NUMBER;
  FUNCTION required_retention RETURN NUMBER;
  FUNCTION required_retention(s1 IN NUMBER, s2 IN NUMBER)
  RETURN NUMBER;
  -- This function returns required value for init.ora parameter undo_retention 
  -- in order to prevent snap-shot-too-old error based on historical 
  -- information of given period. 0 will be returned if information about
  -- the given period not available.

  -- Input Parameters:
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   None.

  -- Return:
  --   required value for init.ora parameter undo_retention. 0 if information 
  --   about the given period not available.

  -- Exceptions:
  --   None.

  FUNCTION best_possible_retention(starttime IN DATE, endtime IN DATE)
  RETURN NUMBER;
  FUNCTION best_possible_retention RETURN NUMBER;
  FUNCTION best_possible_retention(s1 IN NUMBER, s2 IN NUMBER)
  RETURN NUMBER;
  -- This function returns best possible value for init.ora parameter 
  -- undo_retention in order to maxmize the usage of current undo tablespace 
  -- based on historical information of given period. 0 will be returned if 
  -- information about the given period not available.

  -- Input Parameters:
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   None.

  -- Return:
  --   Best possible value for init.ora parameter undo_retention. 0 if 
  --   information about the given period not available.

  -- Exceptions:
  --   None.

  -- Note:
  --   For auto-extensiable undo tablespace, the best possible retention value
  --   is based on the max size the undo tablespace can grow to. You may not 
  --   want your undo tablespace to grow to that size.

  FUNCTION required_undo_size(retention IN NUMBER,
                              starttime IN DATE, endtime IN DATE)
  RETURN NUMBER;
  FUNCTION required_undo_size(retention IN NUMBER) RETURN NUMBER;
  FUNCTION required_undo_size(retention IN NUMBER,
                              s1 IN NUMBER, s2 IN NUMBER)
  RETURN NUMBER;
  -- This function returns the required undo tablespace size in order to
  -- satisfy undo_retention based on historical information of given period. 
  -- 0 will be returned if information about the given period not available.

  -- Input Parameters:
  --   retention: retention value you want to set for init.ora parameter
  --              undo_retention.
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   None.

  -- Return:
  --   Required size of undo tablespace in MB. 0 if 
  --   information about the given period not available.

  -- Exceptions:
  --   None.

  FUNCTION required_undo_size(retention IN dbms_uadv_arr,
                              utbsize   IN OUT dbms_uadv_arr,
                              starttime IN DATE, endtime IN DATE)
  RETURN NUMBER;
  FUNCTION required_undo_size(retention IN dbms_uadv_arr,
                              utbsize   IN OUT dbms_uadv_arr)
  RETURN NUMBER;
  FUNCTION required_undo_size(retention IN dbms_uadv_arr,
                              utbsize   IN OUT dbms_uadv_arr,
                              s1 IN NUMBER, s2 IN NUMBER)
  RETURN NUMBER;
  -- This function returns the required undo tablespace size given
  -- undo retention value. 0 will be returned if information about
  -- the given period not available. Both retention and utbsize
  -- are varray type. It is caller's responsibility to initialize
  -- utbsize array. This function simply appends results to utbsize
  -- array.

  -- Input Parameters:
  --   retention: retention value you want to set for init.ora parameter
  --              undo_retention.
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   utbsize: Required size of undo tablespace in MB.

  -- Return:
  --   0 if information about the given period not available.

  -- Exceptions:
  --   None.


  FUNCTION undo_health(problem        OUT VARCHAR2,
                       recommendation OUT VARCHAR2,
                       rationale      OUT VARCHAR2,
                       retention      OUT NUMBER,
                       utbsize        OUT NUMBER) RETURN NUMBER; 
  FUNCTION undo_health(starttime      IN  DATE,
                       endtime        IN  DATE,
                       problem        OUT VARCHAR2,
                       recommendation OUT VARCHAR2,
                       rationale      OUT VARCHAR2,
                       retention      OUT NUMBER,
                       utbsize        OUT NUMBER) RETURN NUMBER; 
  FUNCTION undo_health(s1             IN NUMBER,
                       s2             IN NUMBER,
                       problem        OUT VARCHAR2,
                       recommendation OUT VARCHAR2,
                       rationale      OUT VARCHAR2,
                       retention      OUT NUMBER,
                       utbsize        OUT NUMBER) RETURN NUMBER;
  -- This function is used to check if there is any problem with the current
  -- setting of undo_retention and undo tablespace size based on historical
  -- information of a given period. If the return value is 0, no problem is 
  -- found. Otherwise, parameter "problem" and "recommendation" are the 
  -- problem and recommendation on fixing the problem. 

  -- Input Parameters:
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.

  -- Output Parameters:
  --   problem: problem of the system. It can be:
  --            "long running query may fail" or "undo tablespace cannot
  --            support undo_retention".
  --   recommendation: recommendation on fixing the problem found.
  --   rationale: rationale for the recommendation.
  --   retention: numerical value of retention if recommendation is to change 
  --              retention.
  --   utbsize: numberical value of undo tablespace size in MB if 
  --            recommendation is to change undo tablespace size.    

  -- Return:
  --   If return value is 0, undo tablespace is OK. 
  --   If return value is 1:    
  --     problem: Undo tablespace cannot support the specified undo_retention
  --           or Undo tablespace cannot support auto tuning undo retention
  --     recommendation: Size undo tablespace to utbsize MB;
  --   If return value is 2:
  --     problem: Long running queries may fail
  --     recommendation: Set undo_retention to retention
  --   If return value is 3:
  --     problem: Undo tablespace cannot support the longest query
  --     recommendation: Set undo_retention to retention and 
  --                     Size undo tablespace to utbsize MB 
  --   If return value is 4:
  --     problem: System does not have an online undo tablespace  
  --     recommendation: Online undo tablespace with size utbsize MB 

  -- Exceptions:
  --   None.

  FUNCTION undo_advisor(starttime IN DATE, endtime IN DATE, instance IN NUMBER)
  RETURN VARCHAR2;
  FUNCTION undo_advisor(instance IN NUMBER) RETURN VARCHAR2;
  FUNCTION undo_advisor(s1 IN NUMBER, s2 IN NUMBER, instance IN NUMBER)
  RETURN VARCHAR2;
  -- This function uses advisor frame work to check if there is any problem
  -- with the current instance. This function should be used when
  -- undo_management is auto.

  -- Input Parameters:
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.
  --   s1: Begin snap shot id, if want to get information from SWRF.
  --   s2: End snap shot id, if want to get information from SWRF.
  --   instance: For now, please provide the instance id of the current 
  --             instance. 

  -- Output Parameters:
  --   None.

  -- Return:
  --   Problems found in the current instance along with 1 or 2 recommendations
  --   on fixing the problems. For each recommendation, there may be 1 or 2
  --   actions. 

  -- Exceptions:
  --   ORA-13516 SWRF not available
  --   ORA-13618 invalid value for parameter instance
  --   ORA-30014 system is running in non-AUM mode.
  --   ORA-30029 no active undo tablespace.

  FUNCTION rbu_migration(starttime IN DATE, endtime IN DATE) RETURN NUMBER; 
  FUNCTION rbu_migration RETURN NUMBER; 
  -- This functin returns required undo tablespace size if users want to 
  -- migrate from rbu to aum. This function should be called only when
  -- undo management is manual.

  -- Input Parameters:
  --   starttime: Start time of the given period.
  --   endtime: End time of the given period.

  -- Output Parameters:
  --   None.

  -- Return:
  --   Size of undo tablespace in MB.

  -- Exceptions:
  --   None.

END;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_undo_adv for sys.dbms_undo_adv
/
GRANT EXECUTE ON dbms_undo_adv TO dba;
/

Rem  -----------------------------------------------------------------------
Rem  The following two procedures are for testing purposes only. 
Rem  -----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE load_undo_stat(qlen IN NUMBER, ubks IN NUMBER)
IS
  loadsql varchar2(1024);
  val     number;
  cid     number;
  rows    integer;
BEGIN
  val := ubks * 100000 + qlen + 100;
  loadsql := 'alter system set "_undo_debug_usage" = ' || val;
  dbms_output.put_line(loadsql);
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid, loadsql, dbms_sql.native);
  rows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
END load_undo_stat;
/

grant execute on load_undo_stat to dba 
/
  
CREATE OR REPLACE PROCEDURE reset_undo_stat
IS
  resetsql varchar2(1024);
  val     number;
  cid     number;
  rows    integer;
BEGIN
  val := 2;
  resetsql := 'alter system set "_undo_debug_usage" = ' || val;
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid, resetsql, dbms_sql.native);
  rows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
END reset_undo_stat;
/

grant execute on reset_undo_stat to dba 
/

Rem -----------------------------------------------------------------------

CREATE OR REPLACE LIBRARY DBMS_UNDOADV_LIB TRUSTED AS STATIC
/

