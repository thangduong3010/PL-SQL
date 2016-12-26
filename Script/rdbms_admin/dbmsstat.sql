Rem
Rem dbmsstat.sql
Rem
Rem Copyright (c) 1998, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsstat.sql - statistics gathering package
Rem
Rem    DESCRIPTION
Rem      This package provides a mechanism for users to view and modify
Rem      optimizer statistics gathered for database objects.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mzait       11/01/12 - Backport
Rem                           amelidis_blr_backport_13262857_11.2.0.3.0 from
Rem    schakkap    10/29/12 - Backport
Rem                           schakkap_blr_backport_14607573_11.2.0.3.6exadbbp
Rem                           from st_rdbms_11.2.0.3.0exadbbp
Rem    mzait       09/23/12 - Backport mzait_bug-10248538 from
Rem    acakmak     04/28/11 - Backport acakmak_bug-10279045 from main
Rem    mzait       04/24/11 - Backport mzait_bug-10194490 from main
Rem                           #(10194490) import statistics as pending if
Rem                           publish is false
Rem    schakkap    05/18/10 - #(9577300) add create_extended_stats overload
Rem                           reset_col_usage, report_col_usage
Rem    hosu        05/17/10 - 8733965: add stat_category to
Rem                           import/export_*_stats
Rem    schakkap    03/10/09 - #(7116357) fix APPROX_GLOBAL definition
Rem    hosu        11/03/08 - add comments for import_*_stats
Rem    mzait       08/20/08 - #(7116357) document extension to APPROX_GLOBAL
Rem    schakkap    04/25/08 - #(6221403) add comments about compatible param
Rem                           requirements when creating extension
Rem    mzait       03/21/08 - add seed_column_usage
Rem    schakkap    02/07/08 - add/fix comments
Rem    mzait       01/16/08 - #(6718212) add merge_col_usage
Rem    mzait       05/03/07 - publish_pending_stats - add no_invalidate parameter
Rem                           delete_pending_stats  - null is default for tabname
Rem    schakkap    06/16/07 - lrg-2936177: convert diff stats to a table
Rem                           function
Rem    hosu        05/10/07 - obsolete reset_param_defaults; add reset_global
Rem                           _pref_defaults
Rem    hosu        05/10/07 - add obj_filter_list for gathering stats on a 
Rem                           group of objects
Rem    hosu        04/19/07 - change parameters related to default 
Rem                           preferences
Rem    mzait       05/02/07 - changes comments to remove reference to private
Rem                           stats
Rem    hosu        01/09/07 - update comments
Rem    mzait       02/08/07 - replace private by pending
Rem    mzait       09/01/06 - add diff_private_stats
Rem    femekci     10/30/06 - Adding the scale factor to copy_table_stats()
Rem    schakkap    09/28/06 - add comments for *extended_stats procedures
Rem    mzait       09/04/06 - fix spec of new procedures
Rem    schakkap    05/09/06 - extended stats 
Rem    mzait       05/30/06 - Support for separation between gather and 
Rem                           publish 
Rem    mzait       05/06/06 - Add support to USE the statistics preferences 
Rem    mzait       05/04/06 - Add support for statistics preferences
Rem    schakkap    03/21/05 - add diff stats procedures 
Rem    schakkap    10/02/06 - col_stat_type argument to delete_column_stats
Rem    schakkap    03/03/05 - #(4219954) force for gather*stats 
Rem    mtakahar    09/15/04 - add cleanup_stats_job_proc
Rem    schakkap    09/01/04 - #(3867864): no_invalidate for restore 
Rem    schakkap    06/03/04 - add reset_param_defaults 
Rem    dgagne      06/23/04 - allow stats table to be global temporary 
Rem    schakkap    12/23/03 - add comments for restore 
Rem    schakkap    12/09/03 - granularity and AUTOSTATS_TARGET for set_param
Rem    schakkap    10/28/03 - AUTO_INVALIDATE
Rem    schakkap    09/29/03 - [get|set]_param 
Rem    schakkap    08/26/03 - lock, copy partition stats 
Rem    schakkap    08/04/03 - gather_sys => true
Rem    schakkap    06/02/03 - make stats retention configurable
Rem    schakkap    01/15/03 - restore stats
Rem    mtyulene    01/07/03 - add gather cache stats
Rem    schakkap    12/31/02 - lock/unlock statistics
Rem    mtakahar    09/10/02 - automated statistics collection
Rem    schakkap    11/20/02 - statistics on dictionary
Rem    mtyulene    10/03/02 - add support for cache stats
Rem    mdcallag    10/22/02 - support binary_float and binary_double
Rem    schakkap    09/09/02 - gather/delete/export/import_fixed_objects_stats
Rem    mtakahar    09/25/02 - add AUTO_DEGREE/granularity='AUTO'
Rem    mtakahar    08/07/02 - make alter_*_tab_monitoring no-op
Rem    mtyulene    01/22/02 - change default gathering_mode in 
Rem                           gather_system_stats to NOWORKLOAD
Rem    mtakahar    01/31/02 - #(2200979): removed gather_index_stats overload
Rem    schakkap    10/12/01 - add gather_fixed.
Rem    mtakahar    10/15/01 - remove 'drop role gather_system_statistics'
Rem    ayoaz       09/24/01 - support user statistics
Rem    mtakahar    09/26/01 - gather_index_stats enhancements
Rem    mtakahar    07/20/01 - IOT guess quality
Rem    mtakahar    07/23/01 - #(1107252): add gather_temp
Rem    mtyulene    05/30/01 - #(1805416): create role gather_system_statistics 
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    mtakahar    03/28/01 - alter_*_tab_monitoring
Rem    mtakahar    03/26/01 - flush_database_monitoring_info
Rem    mtakahar    02/14/01 - add no_invalidate
Rem    mtakahar    02/20/01 - add gather_sys arg
Rem    mtakahar    11/15/00 - add options=>'GATHER AUTO' and 'LIST AUTO'
Rem    mtakahar    10/17/00 - add DEFAULT_DEGREE
Rem    mtyulene    09/05/00 - add *_system_stats procedures
Rem    amozes      07/28/99 - simple gather stats                              
Rem    amozes      06/15/99 - #(909413) split create_stat_table errors         
Rem    amozes      03/08/99 - add upgrade_stat_table                           
Rem    amozes      10/29/98 - bug 755475: string buffer to small               
Rem    amozes      10/21/98 - bug 598799
Rem    amozes      09/11/98 - add statown to most procedures                   
Rem    amozes      07/22/98 - add generate stats functionality                 
Rem    ncramesh    08/07/98 - change for sqlplus
Rem    amozes      06/16/98 - add dbms_stats library                           
Rem    ddas        05/06/98 - add purity pragmas
Rem    amozes      04/30/98 - auto_gather_stats feature support                
Rem    amozes      03/26/98 - new subpartition and func index options          
Rem    amozes      03/23/98 - allow flags to be passed in for import           
Rem    amozes      02/16/98 - delete functionality
Rem    amozes      01/14/98 - Created
Rem

create or replace package dbms_stats authid current_user is

--
-- This package provides a mechanism for users to view and modify
-- optimizer statistics gathered for database objects.
-- The statistics can reside in two different locations:
--  1) in the dictionary
--  2) in a table created in the user's schema for this purpose
-- Only statistics stored in the dictionary itself will have an
-- impact on the cost-based optimizer.
--
-- This package also facilitates the gathering of some statistics 
-- in parallel.
-- 
-- The package is divided into three main sections:
--  1) procedures which set/get individual stats.
--  2) procedures which transfer stats between the dictionary and
--     user stat tables.
--  3) procedures which gather certain classes of optimizer statistics
--     and have improved (or equivalent) performance characteristics as 
--     compared to the analyze command.
--
-- Most of the procedures include the three parameters: statown,
-- stattab, and statid.  
-- These parameters are provided to allow users to store statistics in 
-- their own tables (outside of the dictionary) which will not affect 
-- the optimizer.  Users can thereby maintain and experiment with "sets" 
-- of statistics without fear of permanently changing good dictionary 
-- statistics.  The stattab parameter is used to specify the name of a 
-- table in which to hold statistics and is assumed to reside in the same
-- schema as the object for which statistics are collected (unless the
-- statown parameter is specified).  Users may create 
-- multiple such tables with different stattab identifiers to hold separate 
-- sets of statistics.  Additionally, users can maintain different sets of 
-- statistics within a single stattab by making use of the statid 
-- parameter (which can help avoid cluttering the user's schema).
--
-- For all of the set/get procedures, if stattab is not provided (i.e., null), 
-- the operation will work directly on the dictionary statistics; therefore, 
-- users need not create these statistics tables if they only plan to 
-- modify the dictionary directly.  However, if stattab is not null, 
-- then the set/get operation will work on the specified user statistics 
-- table, not the dictionary.
--
-- lock_*_stats/unlock_*_stats procedures: When statistics on a table is
-- locked, all the statistics depending on the table, including table
-- statistics, column statistics, histograms and statistics on all
-- dependent indexes, are considered to be locked. 
-- set_*, delete_*, import_*, gather_* procedures that modify statistics
-- in dictionary of an individual table/index/column will raise an error 
-- if statistics of the object is locked. Procedures that operates on
-- multiple objects (eg: gather_schema_stats) will skip modifying the
-- statistics of an object if it is locked. Most of the procedures have
-- force argument to override the lock. 
-- 
-- Whenever statistics in dictionary are modified, old versions of statistics 
-- are saved automatically for future restoring. Statistics can be restored 
-- using RESTORE procedures. These procedures use a time stamp as an argument 
-- and restore statistics as of that time stamp.
-- There are dictionary views that display the time of statistics 
-- modifications. These views are useful in determining the time stamp to 
-- be used for statistics restoration. 
--
--     Catalog view DBA_OPTSTAT_OPERATIONS contain history of 
--     statistics operations performed at schema and database level 
--     using DBMS_STATS. 
--
--     The views *_TAB_STATS_HISTORY views (ALL, DBA, or USER) contain 
--     history of table statistics modifications. 
--
-- The old statistics are purged automatically at regular intervals based on 
-- the statistics history retention setting and the time of the recent 
-- analyze of the system. Retention is configurable using the
-- ALTER_STATS_HISTORY_RETENTION procedure. The default value is 31 days, 
-- which means that you would be able to restore the optimizer statistics to 
-- any time in last 31 days. 
-- Automatic purging is enabled when STATISTICS_LEVEL parameter is set 
-- to TYPICAL or ALL. If automatic purging is disabled, the old versions 
-- of statistics need to be purged manually using the PURGE_STATS procedure. 
--
-- Other related functions:
--   GET_STATS_HISTORY_RETENTION: This function can be used to get the 
--     current statistics history retention value. 
--   GET_STATS_HISTORY_AVAILABILITY: This function gets the oldest time stamp 
--     where statistics history is available. Users cannot restore statistics 
--     to a time stamp older than the oldest time stamp. 
--
--
-- When a dbms_stats subprogram modifies or deletes the statistics
-- for an object, all the dependent cursors are invalidated by
-- default and corresponding statements are subject to recompilation
-- next time so that new statistics have immediate effects.  This
-- behavior can be altered with the no_invalidate argument when
-- applicable.
--
-- Extended Statistics: This package allows you to collect statistics for
-- column groups and expressions (known as "statistics extensions"). The
-- statistics collected for column groups and expressions are called
-- "extended statistics". Statistics on Column groups are used by optimizer for
-- accounting correlation between columns. For example, if query has predicates
-- c1=1 and c2=1 and if there are statistics on (c1, c2), optimizer will use
-- this statistics for estimating the combined selectivity of the predicates.
-- The expression statistics are used by optimizer for estimating selectivity 
-- of predicates on those expressions. The extended statistics are similar to
-- column statistics and the procedures that take columns names will accept
-- extension names in place of column names.
--
-- The following procedures can be used for managing extensions.
--      create_extended_stats    - create extensions manually or based on
--                                 groups of columns seen in workload.
--      drop_extended_stats      - drop an extension
--      show_extended_stats_name - show name of an extension
--
--      seed_col_usage           - record usage of column (group)s in a
--                                 workload
--      reset_col_usage          - delete recorded column (group)s usage
--                                 information
--      report_col_usage         - generate a report of column group(s) 
--                                 usage.
--
-- Comparing statistics:
--
-- diff_table_stats_* functions can be used to compare statistics for a table
-- from two different sources. The statistics can be from
--
--   - two different user statistics tables
--   - a single user statistics table containing two sets of
--     statistics that can be identified using statid's
--   - a user statistics table and dictionary
--   - history
--   - pending statistics

-- The functions also compares the statistics of the dependent objects
-- (indexes, columns, partitions).
-- They displays statistics of the object(s) from both sources if the
-- difference between those statistics exceeds a certain threshold (%).
-- The threshold can be specified as an argument to the function, with
-- a default of 10%.
-- The statistics corresponding to the first source (stattab1 or time1)
-- will be used as basis for computing the diff percentage.
--
-- Pending Statistics:
--
-- Optimizer statistics are gathered and saved in a pending state for tables 
-- that have FALSE value for the PUBLISH preference (see set_*_prefs()).
-- The default value of the PUBLISH preference is TRUE.
-- Pending statistics can be published, exported, or deleted. 
-- See the section corresponding to each of these procedures for details.
-- 
-- Pending statistics are not used by the Query Optimizer unless parameter 
-- optimizer_use_pending_statistics is set to TRUE (system or session level). 
-- The default value of this parameter is FALSE. 
-- Pending statistics provide a mechanism to verify the impact of the new 
-- statistics on query plans before making them available for general use.
--
-- There are two scenarios to verify the query plans:
-- 1. export the pending statistics (use export_pending_stats) to a test 
--    system, then run the query workload and check the performance or plans.
-- 2. set optimizer_use_pending_statistics to TRUE in a session on the system
--    where pending statistics have been gathered, run the workload, and
--    check the performance or plans.
--
-- Once the performance or query plans have been verified, the pending 
-- statistics can be published (run publish_pending_stats) if the performance 
-- are acceptable or delete (run delete_pending_stats) if not.
--
-- Related procedures:
--   publish_pending_stats
--   export_pending_stats
--   delete_pending_stats 
--
-- 
-- Nearly all the procedures in this package (more specifically, the
-- set_*, delete_*, export_*, import_*, gather_*, and *_stat_table
-- procedures) commit the current transaction, perform the operation, 
-- and then commit again.
--

-- types for minimum/maximum values and histogram endpoints
type numarray is varray(256) of number;
type datearray is varray(256) of date;
type chararray is varray(256) of varchar2(4000);
type rawarray is varray(256) of raw(2000);
type fltarray is varray(256) of binary_float;
type dblarray is varray(256) of binary_double;

type StatRec is record (
  epc    number,
  minval raw(2000),
  maxval raw(2000),
  bkvals numarray,
  novals numarray,
  chvals chararray,
  eavs   number);

-- type for objects whose statistics may be gathered
-- make sure to maintain satisfy_obj_filter when ObjectElem type
-- is changed
type ObjectElem is record (
  ownname     varchar2(32),     -- owner
  objtype     varchar2(6),      -- 'TABLE' or 'INDEX'
  objname     varchar2(32),     -- table/index
  partname    varchar2(32),     -- partition
  subpartname varchar2(32)      -- subpartition
);
type ObjectTab is table of ObjectElem;


-- type for displaying stats difference report
type DiffRepElem is record (
  report     clob,              -- stats difference report
  maxdiffpct number);           -- max stats difference (percentage)
type DiffRepTab is table of DiffRepElem;

-- type for gather_table_stats context -- internal only
type CContext is varray(10) of varchar2(100);

-- oracle decides whether to collect stats for indexes or not
AUTO_CASCADE CONSTANT BOOLEAN := null;

-- oracle decides when to invalidate dependend cursors
AUTO_INVALIDATE CONSTANT BOOLEAN := null;

-- constant used to indicate auto sample size algorithms should
-- be used.
AUTO_SAMPLE_SIZE        CONSTANT NUMBER := 0;

-- constant to indicate use of the system default degree of
-- parallelism determined based on the initialization parameters.
DEFAULT_DEGREE          CONSTANT NUMBER := 32767;
-- force serial execution if the object is relatively small.
-- use the system default degree of parallelism otherwise.
AUTO_DEGREE             CONSTANT NUMBER := 32768;

-- constant used to specify that we want the table cached block 
-- to be automatically computed
AUTO_TABLE_CACHED_BLOCKS CONSTANT INTEGER := 0;


--
-- Default values for key parameters passed to dbms_stats procedures
-- These values are specified in the DEFAULT clause when declaring the
-- corresponding parameter in any of the dbms_stats procedures.
--
DEFAULT_CASCADE          CONSTANT BOOLEAN  := null;
DEFAULT_DEGREE_VALUE     CONSTANT NUMBER   := 32766;
DEFAULT_ESTIMATE_PERCENT CONSTANT NUMBER   := 101;
DEFAULT_METHOD_OPT       CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_NO_INVALIDATE    CONSTANT BOOLEAN     := null;
DEFAULT_GRANULARITY      CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_PUBLISH          CONSTANT BOOLEAN     := true;
DEFAULT_INCREMENTAL      CONSTANT BOOLEAN     := false;
DEFAULT_STALE_PERCENT    CONSTANT NUMBER      := 10;
DEFAULT_AUTOSTATS_TARGET CONSTANT VARCHAR2(1) := 'Z';
DEFAULT_STAT_CATEGORY    CONSTANT VARCHAR2(20) := 'OBJECT_STATS';

-- Constant which is used as an indicator that purge_stats should
-- purge everything (i.e., truncate) in stats history tables.
PURGE_ALL CONSTANT TIMESTAMP WITH TIME ZONE := 
 TO_TIMESTAMP_TZ('1001-01-0101:00:00-00:00','YYYY-MM-DDHH:MI:SSTZH:TZM');

--
-- This set of procedures enable the storage and retrieval of 
-- individual column-, index-, table- and system-  related statistics
--
-- The procedures are:
--
--  prepare_column_values*
--
--  set_column_stats
--  set_index_stats
--  set_table_stats
--  set_system_stats
--
--  convert_raw_value*
--
--  get_column_stats
--  get_index_stats
--  get_table_stats
--  get_system_stats
--
--  delete_column_stats
--  delete_index_stats
--  delete_table_stats
--  delete_schema_stats
--  delete_database_stats
--  delete_system_stats
--  delete_fixed_objects_stats
--  delete_dictionary_stats
--


  procedure prepare_column_values(
        srec in out StatRec, charvals chararray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, datevals datearray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, numvals numarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, fltvals fltarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, dblvals dblarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, rawvals rawarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_nvarchar(
        srec in out StatRec, nvmin nvarchar2, nvmax nvarchar2);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_rowid(
        srec in out StatRec, rwmin rowid, rwmax rowid);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
--
-- Convert user-specified minimum, maximum, and histogram endpoint
-- datatype-specific values into Oracle's internal representation 
-- for future storage via set_column_stats.
--
-- Generic input arguments:
--   srec.epc - The number of values specified in charvals, datevals,
--      numvals, or rawvals.  This value must be between 2 and 256 inclusive.
--      Should be set to 2 for procedures which don't allow histogram
--      information (nvarchar and rowid).
--      The first corresponding array entry should hold the minimum 
--      value for the column and the last entry should hold the maximum.
--      If there are more than two entries, then all the others hold the
--      remaining height-balanced or frequency histogram endpoint values
--      (with in-between values ordered from next-smallest to next-largest).  
--      This value may be adjusted to account for compression, so the
--      returned value should be left as is for a call to set_column_stats.
--   srec.bkvals - If a frequency distribution is desired, this array contains
--      the number of occurrences of each distinct value specified in
--      charvals, datevals, numvals, or rawvals.  Otherwise, it is merely an
--      output argument and must be set to null when this procedure is
--      called.
--
-- Datatype specific input arguments (one of these):
--   charvals - The array of values when the column type is character-based.
--      Up to the first 32 bytes of each string should be provided.
--      Arrays must have between 2 and 256 entries, inclusive.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   datevals - The array of values when the column type is date-based.
--   numvals - The array of values when the column type is numeric-based.
--   rawvals - The array of values when the column type is raw.
--      Up to the first 32 bytes of each strings should be provided.
--   nvmin,nvmax - The minimum and maximum values when the column type
--      is national character set based (NLS).  No histogram information
--      can be provided for a column of this type.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   rwmin,rwmax - The minimum and maximum values when the column type
--      is rowid.  No histogram information can be provided for a column 
--      of this type.
--
-- Output arguments:
--   srec.minval - Internal representation of the minimum which is
--      suitable for use in a call to set_column_stats.
--   srec.maxval - Internal representation of the maximum which is
--      suitable for use in a call to set_column_stats.
--   srec.bkvals - array suitable for use in a call to set_column_stats.
--   srec.novals - array suitable for use in a call to set_column_stats.
--
-- Exceptions:
--   ORA-20001: Invalid or inconsistent input values
--

  procedure set_param(
    pname in varchar2,
    pval  in varchar2);
--
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use SET_GLOBAL_PREFS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- This procedure can be used to set default value for parameters 
-- of dbms_stats procedures.
--
-- The function get_param can be used to get the current
-- default value of a parameter. 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   pname   - parameter name
--             The default value for following parameters can be set.
--                CASCADE - The default value for CASCADE set by set_param
--                          is not used by export/import procedures.
--                          It is used only by gather procedures.
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                AUTOSTATS_TARGET
                        -- This parameter is applicable only for auto stats
--                         collection. The value of this parameter controls
--                         the objects considered for stats collection
--                         It takes the following values
--                         'ALL'    -- statistics collected 
--                                     for all objects in system
--                         'ORACLE' -- statistics collected 
--                                     for all oracle owned objects
--                         'AUTO'   -- oracle decide which objects 
--                                     to collect stats
--   pval    - parameter value. 
--             if null is specified, it will set the oracle default value
--
-- Notes:
--   Both arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_param('CASCADE','DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_param('ESTIMATE_PERCENT','5');
--        dbms_stats.set_param('DEGREE','NULL');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  function get_param(
    pname   in varchar2) 
  return varchar2;
-- 
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use GET_PREFS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- Get default value of parameters of dbms_stats procedures 
--
-- Input arguments:
--   pname   - parameter name
--
-- Exceptions:
--   ORA-20001: Invalid input values
--

  procedure reset_param_defaults;
--
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--     Please use RESET_GLOBAL_PREF_DEFAULTS() instead.
--  WARNING ** WARNING ---> obsoleted <--- WARNING  ** WARNING 
--
-- This procedure resets the default of parameters to ORACLE
-- recommended values.
--

  procedure reset_global_pref_defaults;
--
-- This procedure resets the global preference to the default values
--

  procedure set_global_prefs(
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the global statistics preferences.
-- This setting is honored only of there is no preference specified
-- for the table to be analyzed.
-- 
-- To run this procedure, you need to have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                AUTOSTATS_TARGET
--                CONCURRENT
--                TABLE_CACHED_BLOCKS
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--
--   
--  CASCADE: Please see CASCADE in gather_table_stats
--
--  DEGREE: Please see DEGREE in gather_table_stats
--
--  ESTIMATE_PERCENT: Please see ESTIMATE_PERCENT in gather_table_stats
--
--  METHOD_OPT: Please see METHOD_OPT in gather_table_stats
--
--  NO_INVALIDATE: Please see NO_INVALIDATE in gather_table_stats
--
--  GRANULARITY: Please see GRANULARITY in gather_table_stats
--
--  PUBLISH: The "PUBLISH" value determines whether or not newly gathered 
--    statistics will be published once the gather job has completed.  
--    Prior to 11g, once a statistic gathering job completed, the new 
--    statistics were automatically published into the dictionary tables. 
--    The user now has the ability to gather statistics but not publish 
--    them immediately. This allows the DBA to test the new statistics 
--    before publishing them.
--
--  INCREMENTAL: The "INCREMENTAL" value determines whether or not the global 
--    statistics of a partitioned table will be maintained without doing a 
--    full table scan. With partitioned tables it is very common to load new 
--    data into a new partition. As new partitions are added and data loaded, 
--    the global table statistics need to be kept up to date.  Oracle will 
--    update the global table statistics by scanning only the partitions that 
--    have been changed instead of the entire table if the following conditions
--    hold: (1) the INCREMENTAL value for the partitioned table is set to TRUE;
--    (2) the PUBLISH value for the partitioned table is set to TRUE; and
--    (3) the user specifies AUTO_SAMPLE_SIZE for estimate_percent and AUTO for 
--    granularity when gathering statistics on the table.
--    If the INCREMENTAL value for the partitioned table was set to FALSE 
--    (default value), then a full table scan would be used to maintain the 
--    global statistics.
--
--  STALE_PERCENT: The "STALE_PERCENT" value determines the percentage of rows 
--    in a table that have to change before the statistics on that table are 
--    deemed stale and should be regathered. The default value is 10%. 
--
--  AUTOSTATS_TARGET
--    This preference is applicable only for auto stats collection. The value 
--    of this parameter controls the objects considered for stats collection.
--    It takes the following values
--    'ALL'    -- statistics collected  for all objects in system
--    'ORACLE' -- statistics collected  for all oracle owned objects
--    'AUTO'   -- oracle decide which objects   to collect stats
--
--  CONCURRENT
--    This preference determines whether the statistics of tables or
--    (sub)partitions of tables to be gathered concurrently when user issues
--    gather_*_stats procedures. DBMS_STATS has the ability to collect 
--    statistics for a single object (table, (sub)partition) in parallel
--    based on the value of degree parameter. However the parallelism is 
--    limited to one object. CONCURRENT preference extends the scope of 
--    "parallelization" to multiple database objects by enabling users to 
--    concurrently gather statistics for multiple tables in a schema/database 
--    and multiple (sub)partitions within a table. Note that this is primarily
--    intented for multi cpu systems and it may not be suitable for small 
--    databases on single cpu machines.
--
--  TABLE_CACHED_BLOCKS
--    The average number of blocks cached in the buffer cache for any table
--    we can assume when gathering the index clustering factor.

--    To gather statistics concurrently, the user must have DBA role or have 
--    the following privileges in addition to privileges that are required for 
--    gathering statistics.
--      CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE
--
--    The preference takes the following values. 
--    'TRUE'  - Gather statistics concurrently
--    'FALSE' - Gather statistics in non concurrent fasion. This is the 
--              default.
--
-- Notes:
--   Both arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_global_prefs('ESTIMATE_PERCENT','9');
--        dbms_stats.set_global_prefs('DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  function get_prefs(
    pname   in varchar2,
    ownname in varchar2 default null,
    tabname in varchar2 default null) 
  return varchar2;
-- 
--
-- Get default value of the specified preference.
-- If the ownname and tabname are provided and a preference has been entered
-- for the table then it returns the preference as specified for the table.
-- In all other cases it returns the global preference, in case it has been 
-- specified, otherwise the default value is returned.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be retrieved.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                AUTOSTATS_TARGET
--                CONCURRENT
--                TABLE_CACHED_BLOCKS
--
--   ownname - owner name
--   tabname - table name
--  
--
-- Exceptions:
--   ORA-20001: Invalid input values
--

  procedure set_table_prefs(
    ownname varchar2,
    tabname varchar2,
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_table_prefs('SH', 'SALES', 'CASCADE',
--                                   'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_table_prefs('SH', 'SALES', 'ESTIMATE_PERCENT','9');
--        dbms_stats.set_table_prefs('SH', 'SALES', 'DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  procedure delete_table_prefs(
    ownname varchar2,
    tabname varchar2,
    pname   varchar2);
-- 
-- This procedure is used to delete the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_table_prefs('SH', 'SALES', 'CASCADE');
--        dbms_stats.delete_table_prefs('SH', 'SALES', 'DEGREE');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_table_prefs(
    ownname varchar2,
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to export the statistics preferences of the 
-- specified table in the specified schema into the specified statistics
-- table.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_table_prefs('SH', 'SALES', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges 
--


  procedure import_table_prefs(
    ownname varchar2,
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to set the statistics preferences of the 
-- specified table in the specified schema.
-- 
-- To run this procedure, you need to connect as owner of the table
-- or be granted ANALYZE ANY system privilege.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.import_table_prefs('SH', 'SALES', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure set_schema_prefs(
    ownname varchar2,
    pname   varchar2,
    pvalue  varchar2);
-- 
-- This procedure is used to set the statistics preferences of all
-- the tables owned by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers
--
-- Examples:
--        dbms_stats.set_schema_prefs('SH', 'CASCADE',
--                                    'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_schema_prefs('SH' 'ESTIMATE_PERCENT','9');
--        dbms_stats.set_schema_prefs('SH', 'DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--   ORA-20001: Invalid or Illegal input values
--


  procedure delete_schema_prefs(
    ownname varchar2,
    pname   varchar2);
-- 
-- This procedure is used to delete the statistics preferences of all
-- the tables owned by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_schema_prefs('SH', 'CASCADE');
--        dbms_stats.delete_schema_prefs('SH', 'ESTIMATE_PERCENT');
--        dbms_stats.delete_schema_prefs('SH', 'DEGREE');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_schema_prefs(
    ownname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to export the statistics preferences of all
-- the tables owner by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_schema_prefs('SH', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure import_schema_prefs(
    ownname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null);
-- 
-- This procedure is used to import the statistics preferences of all
-- the tables owner by the specified owner name.
-- 
-- To run this procedure, you need to connect as owner, have the SYSDBA 
-- privilege, OR have the ANALYZE ANY system privilege 
--
-- Input arguments:
--   ownname - owner name
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different from ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.import_schema_prefs('SH', 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20000: Schema "<schema>" does not exist 
--


  procedure set_database_prefs(
    pname   varchar2,
    pvalue  varchar2,
    add_sys boolean default false);
-- 
-- This procedure is used to set the statistics preferences of all
-- the tables, excluding the tables owned by Oracle. These tables
-- can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be set.
--                CASCADE 
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
--   pvalue  - preference value. 
--             if null is specified, it will set the oracle default value.
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes,
--   even when they represent numbers.
--
-- Examples:
--        dbms_stats.set_database_prefs('CASCADE', 'DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_database_prefs('ESTIMATE_PERCENT','9');
--        dbms_stats.set_database_prefs('DEGREE','99');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure delete_database_prefs(
    pname   varchar2,
    add_sys boolean default false);
-- 
-- This procedure is used to delete the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   pname   - preference name
--             The default value for following preferences can be deleted.
--                CASCADE 
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                PUBLISH
--                INCREMENTAL
--                STALE_PERCENT
--                TABLE_CACHED_BLOCKS
--
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_database_prefs('CASCADE', false);
--        dbms_stats.delete_database_prefs('ESTIMATE_PERCENT',true);
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--


  procedure export_database_prefs(
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null,
    add_sys boolean  default false);
-- 
-- This procedure is used to export the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   add_sys - value TRUE will include the Oracle-owned tables
--
-- Examples:
--        dbms_stats.export_database_prefs('MY_STAT_TAB', statown=>'SH');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--


  procedure import_database_prefs(
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default null,
    add_sys boolean  default false);
-- 
-- This procedure is used to import the statistics preferences of 
-- all the tables, excluding the tables owned by Oracle. These 
-- tables can by included by passing TRUE for the add_sys parameter.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab
--   add_sys - value TRUE will include the Oracle-owned tables
-- Examples:
--        dbms_stats.import_database_prefs('MY_STAT_TAB', statown=>'SH');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--


-- THE FOLLOWING PROCEDURES ARE FOR INTERNAL USE ONLY.
  function to_cascade_type(cascade varchar2) return boolean;
  function to_estimate_percent_type(estimate_percent varchar2) return number;
  function to_degree_type(degree varchar2) return number;
  function to_no_invalidate_type(no_invalidate varchar2) return boolean;
  function to_publish_type(publish varchar2) return boolean;
  procedure init_package;
-- THE ABOVE PROCEDURES ARE FOR INTERNAL USE ONLY.


  procedure publish_pending_stats(
    ownname varchar2 default USER, 
    tabname varchar2,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')),
    force   boolean default FALSE);
-- 
-- This procedure is used to publish the statistics gathered and stored
-- as pending.
-- If the parameter TABNAME is null then publish applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
-- 
-- To run this procedure, you need to have the privilge to collect stats
-- for the tables that will be touched by this procedure.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force   - to override the lock (TRUE will override the lock).
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.publish_pending_stats('SH', null);
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure export_pending_stats(
    ownname varchar2 default USER, 
    tabname varchar2,
    stattab varchar2,
    statid  varchar2 default null,
    statown varchar2 default USER);
-- 
-- This procedure is used to export the statistics gathered and stored
-- as pending.
-- 
-- If the parameter TABNAME is null then export applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--   stattab - statistics table name where to export the statistics
--   statid  - (optional) identifier to associate with these statistics
--             within stattab.
--   statown - The schema containing stattab (if different from ownname)
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.export_pending_stats(null, null, 'MY_STAT_TAB');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure delete_pending_stats(
    ownname varchar2 default USER, 
    tabname varchar2 default null);
-- 
-- This procedure is used to delete the pending statistics that have
-- been gathered but not published yet, i.e, stored as pending.
-- 
-- If the parameter TABNAME is null then delete applies to all tables 
-- of the specified schema. 
-- The default owner/schema is the user who runs the procedure.
--
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   ownname - owner name
--   tabname - table name
--
-- Notes:
--   All arguments are of type varchar2 and values are enclosed in quotes.
--
-- Examples:
--        dbms_stats.delete_pending_stats('SH', 'SALES');
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure resume_gather_stats;
-- 
-- This procedure is used to resume statistics gathering at the point
-- where it was interrupted. Statistics gathering can be interrupted
-- as a result of a user action or a system event. 
-- 
-- To run this procedure, you need to have the SYSDBA role OR both 
-- ANALYZE ANY DICTIONARY and ANALYZE ANY system privileges.
--
-- Input arguments:
--   None.
--
-- Examples:
--        dbms_stats.resume_gather_stats();
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt number default null, density number default null,
        nullcnt number default null, srec StatRec default null,
        avgclen number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);

  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set column-related information 
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   distcnt - The number of distinct values
--   density - The column density.  If this value is null and distcnt is
--      not null, density will be derived from distcnt.
--   nullcnt - The number of nulls
--   srec - StatRec structure filled in by a call to prepare_column_values
--      or get_column_stats.
--   avgclen - The average length for the column (in bytes)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows number default null, numlblks number default null,
        numdist number default null, avglblk number default null,
        avgdblk number default null, clstfct number default null,
        indlevel number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        guessq number default null,
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE);

  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set index-related information
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition in which to store
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be stored at the global index
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).  If not provided,
--      this value will be derived from numlblks and numdist.
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--      If not provided, this value will be derived from clstfct
--      and numdist.
--   clstfct - See clustering_factor column of the all_indexes view
--      for a description.
--   indlevel - The height of the index (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   guessq - IOT guess quality.  See pct_direct_access column of the
--      all_indexes view for a description.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
-- 

  procedure set_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows number default null,
        numblks number default null,
        avgrlen number default null, 
        flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE);
--
-- Set table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - set the values even if statistics of the object is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure convert_raw_value(
        rawval raw, resval out varchar2);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out date);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out number);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out binary_float);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out binary_double);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_nvarchar(
        rawval raw, resval out nvarchar2);
  pragma restrict_references(convert_raw_value_nvarchar,
                             WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_rowid(
        rawval raw, resval out rowid);
  pragma restrict_references(convert_raw_value_rowid, WNDS, RNDS, WNPS, RNPS);
--
-- Convert the internal representation of a minimum or maximum value
-- into a datatype-specific value.  The minval and maxval fields
-- of the StatRec structure as filled in by get_column_stats or
-- prepare_column_values are appropriate values for input.
--
-- Input argument
--   rawval - The raw representation of a column minimum or maximum
--
-- Datatype specific output arguments:
--   resval - The converted, type-specific value
--
-- Exceptions:
--   None
--


  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt out number, density out number,
        nullcnt out number, srec out StatRec,
        avgclen out number,
        statown varchar2 default null);

  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out raw, 
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all column-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   distcnt - The number of distinct values
--   density - The column density
--   nullcnt - The number of nulls
--   srec - structure holding internal representation of column minimum,
--      maximum, and histogram values
--   avgclen - The average length of the column (in bytes)
--
-- Output arguments for user-defined column statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null,
        guessq out number,
        cachedblk out number,
        cachehit out number);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null,
        guessq out number);
  
  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out raw,
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all index-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to get
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be retrieved for the global index
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--   clstfct - The clustering factor for the index (partition).
--   indlevel - The height of the index (partition).
--   guessq - IOT guess quality of the index (partition).
--
-- Output arguments for user defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numblks out number,
        avgrlen out number,
        statown varchar2 default null);

  procedure get_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows out number,
        numblks out number,
        avgrlen out number,
        statown varchar2 default null,
        cachedblk out number,
        cachehit out number);
--
-- Gets all table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--



  procedure delete_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        col_stat_type varchar2 default 'ALL');
--
-- Deletes column-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition for which to delete
--      the statistics.  If the table is partitioned and partname
--      is null, global column statistics will be deleted.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this column for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete statistics even if it is locked
--   col_stat_type - Type of column statitistics to be deleted.
--                   This argument takes the following values: 
--                   'HISTOGRAM' - delete column histogram only
--                   'ALL' - delete base column stats and histogram
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes index-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to delete
--      the statistics.  If the index is partitioned and partname
--      is null, index statistics will be deleted at the global level.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the index is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this index for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true, 
        cascade_columns boolean default true,
        cascade_indexes boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes table-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this table for all underlying partitions as well.
--   cascade_columns - Indicates that delete_column_stats should be
--      called for all underlying columns (passing the cascade_parts
--      parameter).
--   cascade_indexes - Indicates that delete_index_stats should be
--      called for all underlying indexes (passing the cascade_parts
--      parameter).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_schema_stats(
        ownname varchar2, 
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for a schema
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--           
--           
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure delete_database_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for an entire database
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab.
--      If stattab is not null and statown is null, it is assumed that
--      every schema in the database contains a user statistics table
--      with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--






--
-- This set of procedures enable the transferrance of statistics
-- from the dictionary to a user stat table (export_*) and from a user
-- stat table to the dictionary (import_*).
--
-- The procedures are:
--
--  create_stat_table
--  drop_stat_table
--  upgrade_stat_table
--
--  export_column_stats
--  export_index_stats
--  export_table_stats
--  export_schema_stats
--  export_database_stats
--  export_system_stats
--  export_fixed_objects_stats
--  export_dictionary_stats
--
--  import_column_stats
--  import_index_stats
--  import_table_stats
--  import_schema_stats
--  import_database_stats
--  import_system_stats
--  import_fixed_objects_stats
--  import_dictionary_stats
--  
--  Notes: 
--    We do not support export/import of stats across databases of 
--    different character sets.
--


  procedure create_stat_table(
        ownname varchar2, stattab varchar2,
        tblspace varchar2 default null,
        global_temporary boolean default false);
--
-- Creates a table with name 'stattab' in 'ownname's
-- schema which is capable of holding statistics.  The columns
-- and types that compose this table are not relevant as it
-- should be accessed solely through the procedures in this
-- package.
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The name of the table to create.  This value should
--      be passed as the 'stattab' argument to other procedures
--      when the user does not wish to modify the dictionary statistics
--      directly.
--   tblspace - The tablespace in which to create the stat tables.
--      If none is specified, they will be created in the user's 
--      default tablespace.
--   table_options - Whether or not the table should be created as a global
--      temporary table.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Tablespace does not exist
--   ORA-20002: Table already exists
--


  procedure drop_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Drops a user stat table
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Table is not a statistics table
--   ORA-20002: Table does not exist
--


  procedure upgrade_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Upgrade a user stat table from an older version
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Unable to upgrade table
--


  procedure export_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular column and stores them in the user
-- stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_index_stats(
        ownname varchar2, indname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular index and stores them 
-- in the user stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY
);
--
-- Retrieves statistics for a particular table and stores them 
-- in the user stat table.
-- Cascade will result in all index and column stats associated
-- with the specified table being exported as well.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be exported.
--   statown - The schema containing stattab (if different then ownname)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname and stores them in the user stat table identified
-- by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the database
-- and stores them in the user stat tables identified
-- by statown.stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular column from the user stat table
-- identified by stattab and stores them in the dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column or extension
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular index from the user
-- stat table identified by stattab and stores them in the 
-- dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_table_stats(
        ownname varchar2, tabname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for a particular table from the user
-- stat table identified by stattab and stores them in the dictionary.
-- Cascade will result in all index and column stats associated
-- with the specified table being imported as well.
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be imported.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import even if statistics of the object is locked
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname from the user stat table and stores them in the
-- dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges.
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) no statistics exist for the specified 
--              ownname or statid in the stattab; (2) statistics are locked; (3) 
--              objects in the stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY
        );
--
-- Retrieves statistics for all objects in the database
-- from the user stat table(s) and stores them in the
-- dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--








--
-- This set of procedures enable the gathering of certain
-- classes of optimizer statistics with possible performance 
-- improvements over the analyze command.
--
-- The procedures are:
--
--  gather_index_stats
--  gather_table_stats
--  gather_schema_stats
--  gather_database_stats
--  gather_system_stats
--  gather_fixed_objects_stats
--  gather_dictionary_stats
--
-- We also provide the following procedure for generating some
-- statistics for derived objects when we have sufficient statistics 
-- on related objects
--
-- generate_stats
--

  procedure gather_index_stats
    (ownname varchar2, indname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE);
--
-- This procedure gathers index statistics.
-- It attempts to parallelize as much of the work as possible.
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize with certain types of indexes,
-- including cluster indexes, domain indexes and bitmap join indexes.
-- The "granularity" and "no_invalidate" arguments are also not pertinent to
-- these types of indexes.
--
--   ownname - schema of index to analyze
--   indname - name of index
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER INDEX statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - gather statistics of index even if it is locked.
--
-- Exceptions:
--   ORA-20000: Index does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--

  procedure gather_table_stats
    (ownname varchar2, tabname varchar2, partname varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default  DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     -- the context is intended for internal use only.
     context dbms_stats.CContext default null);

--
-- This procedure gathers table and column (and index) statistics.
-- It attempts to parallelize as much of the work as possible, but there
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize if the user does not have select
-- privilege on the table being analyzed.
--
-- Input arguments:
--   ownname - schema of table to analyze
--   tabname - name of table
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--                        FOR COLUMNS [size_clause] 
--                        column|attribute [size_clause] 
--                        [,column|attribute [size_clause] ... ]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 254
--
--         column      := column name | extension name | extension
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      Optimizer related table statistics are always gathered.
--
--      If an extension is provided, the procedure create the extension if it 
--      does not exist already. Please refer to create_extended_stats for
--      description of extension.
--     
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'APPROX_GLOBAL AND PARTITION' - This option is similar to
--        'GLOBAL AND PARTITION'. But the global statistics are aggregated
--         from partition level statistics. It will aggregate all statistics except number of
--         distinct values for columns and number of distinct keys of indexes.
--         The existing histograms of the columns at the table level
--         are also aggregated.The global statistics are  gathered 
--         (i.e., going back to GLOBAL AND PARTITION behaviour) 
--         if partname argument is null. The aggregation will use only 
--         partitions with statistics, so to get accurate global statistics,
--         user has to make sure to have statistics for all partitions.
--
--
--         This option is useful when you collect statistics for a new partition added
--         into a range partitioned table (for example, a table  partitioned by month).
--         The new data in the partition makes the global statistics stale (especially
--         the min/max values of the partitioning column). This stale global statistics
--         may cause suboptimal plans.  In this scenario, users can collect statistics
--         for the newly added partition with 'APPROX_GLOBAL AND PARTITION'
--         option so that the global statistics will reflect the newly added range.
--         This option will take less time than 'GLOBAL AND PARTITION' option since the
--         global statistics are aggregated from underlying partition level statistics.
--         Note that, if you are using APPROX_GLOBAL AND PARTITION,
--         you still  need to collect global statistics (with granularity = 'GLOBAL' option)
--         when there is substantial amount of change at the table level.
--         For example you added 10% more data to the table.  This is needed to get the
--         correct number of distinct values/keys statistic at table level. 
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes for this table.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the table's indexes.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When the 'cascade' argument is specified, not pertinent with certain
--     types of indexes described in the gather_index_stats section.
--   force - gather statistics of table even if it is locked.
--   context - internal use only.
--   
-- Exceptions:
--   ORA-20000: Table does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--
 procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default  DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     obj_filter_list ObjectTab default null);
  procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE,
     obj_filter_list ObjectTab default null);
--
-- Input arguments:
--   ownname - schema to analyze (NULL means current schema)
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 254
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the schema in addition to 
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are ownname, stattab,
--        statid, objlist and statown; all other parameter settings will be
--        ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather statistics on fixed tables also. 
--     Statistics for fixed tables can be collected only by user SYS.
--     Also the ownname should be SYS or NULL.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   force - gather statistics of objects even if they are locked.
--   obj_filter_list - a list of object filters. When provided, gather_schema_stats 
--     will only gather statistics on the objects which satisfy at least one
--     object filter in the list as needed. Please refer to obj_filter_list 
--     in  gather_database_stats.
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure gather_database_stats
    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out ObjectTab,
     statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);
  procedure gather_database_stats
    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);
--
-- Input arguments:
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 254
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the database in addition to
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are stattab,
--        statid, objlist and statown; all other parameter settings will be
--        ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab.  If null, it will assume
--      there is a table named stattab in each relevant schema in the 
--      database if stattab is specified for saving current statistics.
--   gather_sys - Gather statistics on the objects owned by the 'SYS' user
--      as well.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather stats on fixed tables also.
--     Statistics for fixed tables can be collected only by user SYS.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   obj_filter_list - a list of object filters. When provided, gather_database_
--     stats will only gather statistics on the objects which satisfy at least 
--     one of the object filters as needed.
--
--     In one single object filter, we can specify the constraints on the object
--     attributes. The attribute values specified in the object filter are case-
--     insensitive unless double-quoted. Wildcard is allowed in the attribute values. 
--     Suppose non-null values s1, s2, ... are specified for attributes a1, a2, ... in 
--     one object filter. An object o is said to satisfy this object filter if 
--     (o.a1 like s1) and (o.a2 like s2) and ... is true.
--     The following example specifies that any table with a "SALES" prefix in the 
--     SH schema and any table in the SYS schema, if stale, will be gathered. 
--     Note that the statistics for the partitions of the tables also will be
--     gathered if they are stale.
--   Example:
--     declare
--       filter_lst  dbms_stats.objecttab := dbms_stats.objecttab();
--     begin
--       filter_lst.extend(2);
--       filter_lst(1).ownname := 'sh';
--       filter_lst(1).objname := 'sales%';
--       filter_lst(2).ownname := 'sys';
--       dbms_stats.gather_schema_stats(null, obj_filter_list => filter_lst, 
--                                      options => 'gather_stale');
--     end;
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure generate_stats
    (ownname varchar2, objname varchar2,
     organized number default 7,
     force boolean default FALSE);
--
-- This procedure generates object statistics from previously collected
-- statistics of related objects.  For fully populated
-- schemas, the gather procedures should be used instead when more
-- accurate statistics are desired.
-- The currently supported objects are b-tree and bitmap indexes.
--
--   ownname - schema of object
--   objname - name of object
--   organized - the amount of ordering associated between the index and
--     its undelrying table.  A heavily organized index would have consecutive
--     index keys referring to consecutive rows on disk for the table
--     (the same block).  A heavily disorganized index would have consecutive
--     keys referencing different table blocks on disk.  This parameter is
--     only used for b-tree indexes.
--     The number can be in the range of 0-10, with 0 representing a completely
--     organized index and 10 a completely disorganized one.
--   force - generate statistics even if it is locked
-- Exceptions:
--   ORA-20000: Unsupported object type of object does not exist
--   ORA-20001: Invalid option or invalid statistics
--   ORA-20005: object statistics are locked
--




--
-- This procedure enables the flushing of in-memory monitoring
-- information to the dictionary.  Corresponding entries in the
-- *_tab_modifications views are updated immediately, without waiting
-- for Oracle to flush it periodically.  Useful for the users who need
-- up-to-date information in those views.
-- The gather_*_stats procedures internally flush the monitoring information
-- accordingly, and it is NOT necessary to run this procedure before
-- gathering the statistics.
-- 
--
-- The procedure is:
--
--  flush_database_monitoring_info
--
-- The modification monitoring mechanism is now controlled by the
-- STATISTICS_LEVEL initialization parameter, and the following
-- procedures no longer have any effect:
--
--  alter_schema_tab_monitoring
--  alter_database_tab_monitoring
--

procedure flush_database_monitoring_info;
--
-- Flush in-memory monitoring information for all the tables to the dictionary.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

procedure alter_schema_tab_monitoring
  (ownname varchar2 default NULL, monitoring boolean default TRUE);
procedure alter_database_tab_monitoring
  (monitoring boolean default TRUE, sysobjs boolean default FALSE);



procedure gather_system_stats (
  gathering_mode  varchar2 default 'NOWORKLOAD',
  interval  integer  default 60,
  stattab   varchar2 default null, 
  statid    varchar2 default null,
  statown   varchar2 default null);
--
-- This procedure gathers system statistics. 
--
-- Input arguments:
--   gathering_mode - Values: NOWORKLOAD, INTERVAL, START, STOP, EXADATA
--     NOWORKLOAD:
--       In this mode system statistics will be gathered based on system
--       characteristics only, without regard to the workload.
--     INTERVAL:
--       In this mode the user can specify a time interval parameter, in 
--       minutes. 
--       After <interval> minutes has passed the system statistics will be 
--       updated either in dictionary, or stattab if specified. The system
--       statistics are based on system activity during specified interval.
--     START | STOP:
--       The procedure is first called with START then followed by another
--       call using STOP. It is assumed that between these two calls some
--       SQL workload has been running allowing the procedure to capture
--       workload-specific statistics.
--       START will initiate gathering statistics. STOP will calculate 
--       statistics for elapsed period of time (since START) and refresh
--       dictionary or stattab. Interval in these modes is ignored.
--     EXADATA:
--       In this mode the gathered system statistics takes into account the
--       unique capabilities provided by using Exadata such as large IO size
--       and high IO throughput. The multi-block read count and IO throughput 
--       statistics are set along with the CPU speed.
--
--   interval - Specifies period of time in minutes for gathering statistics
--      in INTERVAL mode.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to gather system statistics
--   ORA-20004: Error in "INTERVAL" mode :
--              system parameter job_queue_processes must be > 0
--

procedure get_system_stats (
   status     out   varchar2,
   dstart     out   date,
   dstop      out   date,
   pname            varchar2,
   pvalue     out   number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   pname - parameter name to get
--
-- Output arguments:
--   status - returns one of the following: COMPLETED, AUTOGATHERING, 
--   MANUALGATHERING, BADSTATS
--   dstart - date when system stats gathering has been started
--   dstop - date when gathering was finished if status =  COMPLETE,
--   will be finished if status = AUTOGATHERING, 
--   had to be finished if status = BADSTATS,
--   dstarted if status = MANUALGATHERING,
--   the following parameters defined only if status = COMPLETE
--   pvalue   - parameter value to get
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to get system statistics
--   ORA-20004: Parameter doesn't exist 
--

procedure set_system_stats (
   pname            varchar2,
   pvalue           number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   pname - parameter name to set
--   pvalue   - parameter value to set
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to set system statistics
--   ORA-20004: Parameter doesn't exist 
--


procedure delete_system_stats (
   stattab         varchar2  default nulL, 
   statid          varchar2  default nulL,
   statown         varchar2  default null);

--
-- Deletes system statistics
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

procedure import_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics from the user
-- stat table identified by stattab and stores it in the
-- dictionary
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to import system statistics
--


procedure export_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics and stores it
-- in the user stat table identified by stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to export system statistics
--


  procedure gather_fixed_objects_stats
    (stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')));
--
-- Gather statistics for fixed tables. 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure delete_fixed_objects_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
        to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Deletes statistics for fixed tables
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for fixed tables and stores them in the user 
-- stat table identified by stattab
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null, 
        no_invalidate boolean default 
           to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for fixed tables from the user stat table and 
-- stores them in the dictionary 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', objlist out ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);
  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,
     block_sample boolean default FALSE,
     method_opt varchar2 default DEFAULT_METHOD_OPT,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default DEFAULT_GRANULARITY,
     cascade boolean default DEFAULT_CASCADE,
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     obj_filter_list ObjectTab default null);

--
-- Gather statistics for dictionary schemas 'SYS', 'SYSTEM' and schemas of
-- RDBMS components.
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   comp_id - component id of the schema to analyze (NULL means schemas
--             of all RDBMS components). 
--             Please refer to comp_id column of dba_registry view.
--             The procedure always gather stats on 'SYS' and 'SYSTEM' schemas
--             regardless of this argument.
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--
--         method_opt  := FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--
--         size_clause := SIZE [integer | auto | skewonly | repeat],
--                        where integer is between 1 and 254
--
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Using this option is equivalent to running the gather_index_stats 
--      procedure on each of the indexes in the schema in addition to 
--      gathering table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are comp_id, stattab,
--        statid and statown; all other parameter settings will be
--        ignored. Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   obj_filter_list - a list of object filters. When provided, gather_dictionary_
--     stats will only gather statistics on the objects which satisfy at least 
--     one of the object filters as needed. Please refer to obj_filter_list in 
--     gather_database_stats
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure delete_dictionary_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure export_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) and stores them in the user stat table 
-- identified by stattab
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--   stat_category - what statistics to export. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--
  procedure import_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE,
        stat_category varchar2 default DEFAULT_STAT_CATEGORY);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) from the user stat table and stores them in 
-- the dictionary 
-- The statistics will be imported as pending in case PUBLISH preference
-- is set to FALSE.
---
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--   stat_category - what statistics to import. It accepts multiple values
--   separated by comma. The values we support now are 'OBJECT_STATS' 
--   (i.e., table statistics, column statistics and index statistics) and 
--   'SYNOPSES'
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--              if ORA-20000 shows "no statistics are imported", several
--              possible reasons are: (1) user specified statid does not
--              exist; (2) statistics are locked; (3) objects in the 
--              stattab no longer exist in the current database  
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure lock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to lock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to lock
--   tabname  - name of the table
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  


  procedure lock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

--
-- This procedure enables the user to lock statistics for a partition
-- 
-- Input arguments:
--   ownname   - schema of the table to lock
--   tabname   - name of the table
--   partname  - name of the partition
--   


  procedure lock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');

-- 
-- This procedure enables the user to lock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to lock
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  


  procedure unlock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to unlock
--   tabname  - name of the table
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default  


  procedure unlock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

--
-- This procedure enables the user to unlock statistics for a partition
-- 
-- Input arguments:
--   ownname   - schema of table to unlock
--   tabname   - name of the table
--   partname  - name of the partition
--   


  procedure unlock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to unlock
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default  

  procedure restore_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    as_of_timestamp timestamp with time zone,
    restore_cluster_index boolean default FALSE,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of a table as of
-- a specified timestamp (as_of_timestamp). The procedure will restore 
-- statistics of associated indexes and columns as well. If the table 
-- statistics were locked at the specified timestamp the procedure will 
-- lock the statistics.
-- Note:
--   The procedure may not restore statistics correctly if analyze interface 
--   is used for computing/deleting statistics.
--   Old statistics versions are not saved when SYSAUX tablespace is
--   offline, this affects restore functionality. 
--   The procedure may not restore statistics if the table defn is
--   changed (eg: column added/deleted, partition exchanged etc).
--   Also it will not restore stats if the object is created after
--   the specified timestamp.
--   The procedure will not restore user defined statistics.
-- Input arguments:
--   ownname  - schema of table for which statistics to be restored
--   tabname  - table name 
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   restore_cluster_index - If the table is part of a cluster,
--     restore statistics of the cluster index if set to TRUE.
--   force - restore statistics even if the table statistics are locked.
--           if the table statistics were not locked at the specified 
--           timestamp, it will unlock the statistics 
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_schema_stats(
    ownname varchar2, 
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- a schema as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   ownname  - schema of tables for which statistics to be restored
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_database_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- the database as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_fixed_objects_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all fixed tables
-- as of a specified timestamp (as_of_timestamp). 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_dictionary_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all dictionary 
-- tables (tables of 'SYS', 'SYSTEM' and RDBMS component schemas)
-- as of a specified timestamp (as_of_timestamp). 
--
-- To run this procedure, you must have the SYSDBA OR
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistics of tables even if their statistics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_system_stats(
    as_of_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to restore system statistics 
-- as of a specified timestamp (as_of_timestamp). 
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure purge_stats(
    before_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to purge old versions of statistics 
-- saved in dictionary
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   before_timestamp - versions of statistics saved before this timestamp
--             will be purged. if null, it uses the purging policy 
--             used by automatic purge. The automatic purge deletes all
--             history older than 
--               min(current time - stats history retention, 
--                   time of recent analyze in the system - 1). 
--             stats history retention value can be changed using 
--             alter_stats_history_retention procedure. 
--             The default is 31 days. 
--
--   When before_timestamp is specified as DBMS_STATS.PURGE_ALL, all stats 
--   history tables are truncated. Please note that interrupting
--   (e.g., hitting Ctrl-C) purge_stats while it is running with PURGE_ALL 
--   option may lead to inconsistencies. Hence, please avoid interrupting 
--   purge_stats manually.
--             
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 

  procedure alter_stats_history_retention(
    retention in number);
--
-- This procedure enables the user to change stats history retention
-- value.  Stats history retention is used by both the automatic 
-- purge and purge_stats procedure. 
--  
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   retention - The retention time in days. The stats history will be
--               ratained for at least these many number of days.
--               The valid range is [1,365000].  Also the following
--               values can be used for special purposes.
--                 0 - old stats are never saved. The automatic purge will
--                     delete all stats history
--                -1 - stats history is never purged by automatic purge.
--                null -  change stats history retention to default value
 
--               

  function get_stats_history_retention return number;

-- This function returns the current retention value.

  function get_stats_history_availability
             return timestamp with time zone;

--  This function returns oldest timestamp where stats history 
--  is available.
--  Users can not restore stats to timestamp older than  this one.


  procedure copy_table_stats(
        ownname varchar2,
        tabname varchar2,
        srcpartname varchar2,
        dstpartname varchar2,
        scale_factor number DEFAULT 1,
        flags number DEFAULT null,
        force boolean DEFAULT FALSE);

--
-- This procedure copies the statistics of the source [sub] partition to the 
-- destination [sub] partition. It also copies statistics of all dependent 
-- objects such as columns and local indexes. If the statistics for source 
-- are not available, then nothing is copied. It can optionally scale the 
-- statistics (such as the number of blks, or number of rows) based on the 
-- given scale_factor.
-- 
-- Usage notes:
--
-- a) To invoke this procedure you must be owner of the table, or you need 
--   the ANALYZE ANY privilege. For objects owned by SYS, you need to be 
--   either the owner of the table, or you need the ANALYZE ANY DICTIONARY 
--   privilege or the SYSDBA privilege.
--
-- b) This procedure updates the minimum and maximum values of destination 
--   partition for the first partitioning column as follows:
--
--  - If the partitioning type is HASH the minimum and maximum values of the 
--    destination partition are same as that of the source partition.
--
--  - If the partitioning type is LIST then
--     if the destination partition is a NOT DEFAULT partition then
--
--        The minimum value of the destination partition is set to the 
--        minimum value of the value list that describes the destination 
--        partition.
--        The maximum value of the destination partition is set to the 
--        maximum value of the value list that describes the destination 
--        partition.
--
--     Alternatively, if the destination partition is a DEFAULT partition, then
--       The minimum value of the destination partition is set to the minimum 
--       value of the source partition
--       The maximum value of the destination partition is set to the maximum 
--       value of the source partition
--
--  - If the partitioning type is RANGE then

--     The minimum value of the destination partition is set to the high bound 
--     of previous partition unless the destination partition is the first 
--     partition. For the first partition, the minimum value is set to the
--     high bound of the destination partition.
--     The maximum value of the destination partition is set to the high bound 
--     of the destination partition unless the high bound of the destination 
--     partition is MAXVALUE, in which case the maximum value of the 
--     destination partition is set to the high bound of the previous 
--     partition.
--
-- c) Additional modification to minimum and maximum values if the 
--   partitioning type is RANGE:
--
--   - If the source partition column's minimum value is equal to its maximum 
--     value, and both are equal to the source partition's lower bound, and 
--     it has a single distinct value, then the destination partition column's
--     minimum and maximum values are both set to the destination partition's 
--     lower bound. This is done for all partitioning columns.
-- 
--   - If the above condition does not apply, second and subsequent 
--     partitioning columns are updated as follows:
--     The destination partition column's maximum value is set to the greater 
--     of the destination partition upper bound and the source partition 
--     column's maximum value, with the following exception: if the 
--     destination partition is D and its preceding partition is D-1 and the 
--     key column to be adjusted is Cn, the maximum value for Cn is set to 
--     the upper bound of D (ignoring the maximum value of the source 
--     partition column) provided that the upper bounds of the previous key 
--     column Cn-1 are the same in partitions D and D-1.
-- 
-- d) If the minimum and maximum values are different for a column after 
--   modifications, and if the number of distinct values is less than 1,
--   the number of disctinct values is updated as 2.
--
-- e) This procedure does not copy statistics of the underlying subpartitions 
--   if the source/destination is a partition of a composite partitioned table.

-- Parameters:
--   ownname      - Schema of the table of source and destination 
--                  [sub] partitions
--   tabname      - Table name of source and destination [sub] partitions
--   srcpartname  - Source [sub] partition
--   dtspartname  - Destination [sub] partition
--   scale_factor - Scale factor to scale nblks, nrows etc. in dstpartname
--   flags        - For internal Oracle use (should be left as NULL)
--   force        - When value of this argument is TRUE copy statistics even 
--                  if the destination [sub]partition is locked

-- Exceptions:
--   ORA-20000: Invalid partition name
--   ORA-20001: Bad input value
--


  function diff_table_stats_in_stattab(
      ownname      varchar2,
      tabname      varchar2,
      stattab1     varchar2,
      stattab2     varchar2 default null,
      pctthreshold number   default 10,
      statid1      varchar2 default null,
      statid2      varchar2 default null,
      stattab1own  varchar2 default null,
      stattab2own  varchar2 default null)
   return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for current schema.
--   tabname  - table for which statistics are to be compared. 
--   stattab1 - user stats table 1.
--   stattab2 - user stats table 2. If null, statistics in stattab1
--              is compared with current statistics in dictionary.
--              This is the default.
--              Specify same table as stattab1 to compare two sets
--              within the stats table (Please see statid below).
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   statid1  - (optional) identifies statistics set within stattab1.
--   statid2  - (optional) identifies statistics set within stattab2.
--   stattab1own - The schema containing stattab1 (if different than ownname)
--   stattab2own - The schema containing stattab2 (if different than ownname)
--

  function diff_table_stats_in_history(
      ownname      varchar2,
      tabname      varchar2,
      time1        timestamp with time zone,
      time2        timestamp with time zone default null,
      pctthreshold number   default 10)
    return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for current schema.
--   tabname  - table for which statistics are to be compared. 
--   time1    - first time stamp
--   time2    - second time stamp
-- 
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   
--   NOTE:
--   If the second timestamp is null, the function compares the current
--   statistics in dictionary with the statistics as of the other timestamp.

  function diff_table_stats_in_pending(
      ownname      varchar2,
      tabname      varchar2,
      time_stamp   timestamp with time zone default null,
      pctthreshold number   default 10)
    return DiffRepTab pipelined;

-- Input arguments:
--   ownname  - owner of the table. Specify null for the current schema.
--   tabname  - table for which statistics are to be compared. 
--   time_stamp - time stamp to get statistics from the history
-- 
--   pctthreshold - The function report difference in statistics
--                  only if it exceeds this limit. The default value is 10.
--   
--   NOTE:
--   If the time_stamp parameter is null, the function compares the current
--   statistics in the dictionary with the pending statistics.  This is the 
--   default



  function create_extended_stats(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2) 
    return varchar2;

-- This function creates a column stats entry in the system for a user specified 
-- column group or an expression in a table. Statistics for this extension will 
-- be gathered when user or auto statistics gathering job gathers statistics for
-- the table. We call statistics for such an extension, "extended statistics".
-- This function returns the name of this newly created entry for the extension.
-- If the extension already exists then this function  throws an error.

-- 
--  Parameters:
--      ownname       -- owner name of a table
--      tabname       -- table name
--      extension     -- can be either a column group or an expression. Suppose
--                       the specified table has two column c1, c2. An example 
--                       column group can be '(c1, c2)', an example expression 
--                       can be '(c1 + c2)'.
-- 
--  Notes:
-- 
--      1. An extension cannot contain a virtual column.
-- 
--      2. You can not create extensions on tables owned by SYS. 
--
--      3. You can not create extensions on cluster tables, index organized 
--         tables, temporary tables, external tables.
--
--      4. Total number of extensions in a table cannot be greater than
--         maximum of (20, 10 % of number of non-virtual columns in the table).
-- 
--      5. Number of columns in a column group must be in the range [2, 32].
-- 
--      6. A column can not appear more than once in a column group.
-- 
--      7. Column group can not contain expressions.
--
--      8. An expression must contain at least one column.
--
--      9. An expression can not contain subquery.
--
--     10. COMPATIBLE parameter needs to be 11.0.0.0.0 or greater.
-- 
-- Exceptions:
--
--   ORA-20000: Insufficient privileges / creating extension is not supported
--
--   ORA-20001: Error when processing extension
--
--   ORA-20007: Extension already exist
--
--   ORA-20008: Reached the upper limit on number of extensions 
--  

  function create_extended_stats(
      ownname    varchar2,
      tabname    varchar2)
    return clob;

-- This function is very similar to the function above but creates statistics
-- extension based on the column group usage recorded by seed_col_usage 
-- procedure. This function returns a report of extensions created.
-- 
-- 
--  Parameters:
--      ownname       -- owner name of a table. If null, all schemas in the
--                       database.
--      tabname       -- table name. If null, creates statistics extensions
--                       for all tables of ownname.

  function show_extended_stats_name(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2) 
    return varchar2;

--  This function returns the name of the statistics entry that is created for 
--  the user specified extension. It raises error if no extension is created
--  yet
-- 
-- 
--  Parameters:
--      ownname      -- owner name of a table
--      tabname      -- table name
--      extension    -- can be either a column group or an expression
--                      (see description in create_extended_stats)
-- Exceptions:
--   ORA-20000: Insufficient privileges or extension does not exist.
--   ORA-20001: Error when processing extension

  procedure drop_extended_stats(
      ownname    varchar2,
      tabname    varchar2,
      extension  varchar2);

-- This function drops the statistics entry that is created for the user 
-- specified extension. This cancels the effects of created_extended_stats.
-- If no extension is created for the extension, this function
-- throws an error.
-- 
--
--  Parameters:
--      ownname      -- owner name of a table
--      tabname      -- table name
--      extension    -- can be either a column group or an expression
--                      (see description in create_extended_stats)
-- Exceptions:
--   ORA-20000: Insufficient privileges or extension does not exist.
--   ORA-20001: Error when processing extension
--
-- The following procedure is for internal use only.
--
--  gather_database_stats_job_proc
--  cleanup_stats_job_proc
--


  procedure merge_col_usage(
      dblink varchar2);

--
-- This procedure merges column usage information from a source database,
-- specified via a dblink, into the local database.
-- If the column usage information already exists for a given table and 
-- column then it will combine both the local and the remote information
-- otherwise it will insert the remote information as new.
-- This procedure is allowed is executed as SYS only, otherwise you will
-- an error message 'Insufficient privileges'.
-- In addition the user specified during the creation of the dblink is
-- expected to have privileges to select from tables in the SYS schema.
-- 
-- Parameters:
--     dblink     - dblink name
--
-- Exceptions:
--   ORA-20000: Insufficient privileges 
--   ORA-20001: Parameter dblink cannot be null
--   ORA-20002: Unable to create a temp table
--


  procedure seed_col_usage(
      sqlset_name IN         VARCHAR2,
      owner_name  IN         VARCHAR2,
      time_limit  IN         POSITIVE DEFAULT NULL);

--
-- This procedure seeds column usage information from a statements in 
-- the specified sql tuning set.
-- The procedure will iterate over the SQL statements in the SQL tuning
-- set and compile them in order to seed column usage information for
-- the columns that appear in these statements. This procedure records
-- group of columns as well. Extensions for the recorded group of columns 
-- can be created using create_extended_stats procedure.
-- 
-- Parameters:
--     sqlset_name     - sqlset name
--     owner_name      - owner name
--     time_limit      - time limit (in seconds)
--
-- If sqlset_name and owner_name is null, it records the column (group) usage 
-- information for the statements executed in the system in next time_limit 
-- seconds.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges 
--

  procedure reset_col_usage(
      ownname      varchar2,
      tabname      varchar2);

-- This procedure deletes the recorded column (group) usage information
-- from dictionary. Column (group) usage information is used by gather 
-- procedures to automatically determine the columns that require histograms.
-- Also this information is used by create_extended_stats to create extensions
-- for the group of columns seen in the workload. So resetting column usage
-- will affect these functionalities. This procedure should be used only in very
-- rare cases where you need to start from scratch and need to seed 
-- column usage all over again.
--
-- Parameters:
--     ownname         - owner name. If null it resets column usage information
--                       for tables in all schemas in the database.
--     tabname         - table name. If null, resets column usage information
--                       for all tables of ownname.
-- If ownname and tabname is null, it will stop seeding column usage, if 
-- currently seeding column usage using seed_col_usage.

  function report_col_usage(
      ownname      varchar2,
      tabname      varchar2)  return clob;

-- This procedure reports the recorded column (group) usage information.
--
-- Parameters:
--     ownname         - owner name. If null it reports column usage information
--                       for tables in all schemas in the database.
--     tabname         - table name. If null, it reports column usage information
--                       for all tables of ownname.
-- Examples:
--     The following example shows column usage information for customers table
--     in SH schema.
--
--SQL> set long 100000
--SQL> set lines 120
--SQL> set pages 0
--SQL> 
--SQL> -- Display column usage
--SQL> select dbms_stats.report_col_usage('sh', 'customers') from dual;
--LEGEND:                                                                                                                 
--.......                                                                                                                 
--                                                                                                                        
--EQ         : Used in single table EQuality predicate                                                                    
--RANGE      : Used in single table RANGE predicate                                                                       
--LIKE       : Used in single table LIKE predicate                                                                        
--NULL       : Used in single table is (not) NULL predicate                                                               
--EQ_JOIN    : Used in EQuality JOIN predicate                                                                            
--NONEQ_JOIN : Used in NON EQuality JOIN predicate                                                                        
--FILTER     : Used in single table FILTER predicate                                                                      
--JOIN       : Used in JOIN predicate                                                                                     
--GROUP_BY   : Used in GROUP BY expression                                                                                
--...............................................................................                                         
--                                                                                                                        
--###############################################################################                                         
--                                                                                                                        
--COLUMN USAGE REPORT FOR SH.CUSTOMERS                                                                                    
--....................................                                                                                    
--                                                                                                                        
--1. COUNTRY_ID                          : EQ                                                                             
--2. CUST_CITY                           : EQ                                                                             
--3. CUST_STATE_PROVINCE                 : EQ                                                                             
--4. (CUST_CITY, CUST_STATE_PROVINCE,                                                                                     
--    COUNTRY_ID)                        : FILTER                                                                         
--5. (CUST_STATE_PROVINCE, COUNTRY_ID)   : GROUP_BY                                                                       
--###############################################################################                                         



procedure gather_database_stats_job_proc;

procedure cleanup_stats_job_proc(
      ctx number, job_owner varchar2, job_name varchar2,
      sesid number, sesser number);

end;
/

show errors;

create or replace public synonym dbms_stats for sys.dbms_stats
/
grant execute on dbms_stats to public
/
create role gather_system_statistics
/
grant update, insert, select, delete on aux_stats$ to gather_system_statistics 
/
grant gather_system_statistics to dba
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_STATS_LIB TRUSTED AS STATIC;
/
