Rem
Rem $Header: rdbms/admin/dbmshpro.sql /main/4 2009/02/04 11:03:51 dbronnik Exp $
Rem
Rem dbmshpro.sql
Rem
Rem Copyright (c) 2003, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmshpro.sql - dbms hierarchical profiler
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dbronnik    11/19/08 - Add memory profile support
Rem    lvbcheng    10/11/06 - Remove grants to public
Rem    sylin       08/28/06 - Disable trace with multiple symbols
Rem    sylin       04/20/06 - analyze output in database tables
Rem    lvbcheng    04/08/05 - Add exceptions 
Rem    sylin       03/30/05 - Add run_comment to analyze 
Rem    lvbcheng    03/22/05 - Add exception 
Rem    sylin       05/25/04 - Add options to analyze
Rem    kmuthukk    02/24/03 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_hprof AUTHID CURRENT_USER IS
      
   PROCEDURE start_profiling(location  VARCHAR2    DEFAULT NULL,
                             filename  VARCHAR2    DEFAULT NULL,
                             max_depth PLS_INTEGER DEFAULT NULL,
                             profile_uga BOOLEAN   DEFAULT NULL,
                             profile_pga BOOLEAN   DEFAULT NULL
                            );
   /* DESCRIPTION:
        Start profiling at this point and collect profile information in the
        specified location.

      ARGUMENTS
        location -
          The name of a directory object. The filesystem directory mapped to
          this directory object is where the raw profiler output is generated.

        filename -
          The output filename for the raw profiler data.

        max_depth -
          By default (when max_depth value is NULL) profile information is
          gathered for all functions irrespective of their call depth.  When a
          non-NULL value is specified for max_depth, the profiler collects
          data only for functions up to a call depth level of max_depth.
          [Note: Even though the profiler does not individually track functions
          at depth greater than max_depth, the time spent in such functions is
          charged to the ancestor function at depth max_depth.] This can be
          used for collecting coarse grain profile information. For example, if
          all that is needed is a high level overview of the subtree times
          spent under the top level functions and not much detailed drill down
          analysis is required, then the max_depth could be set at 1. 

        profile_uga -
          Profile session memory usage (undocumented, for internal use only)

        profile_pga -
          Profile process memory usage (undocumented, for internal use only)

      EXCEPTION
        invalid filename
        invalid directory object 
        incorrect directory permission
        invalid maxdepth
   */

   PROCEDURE stop_profiling;
   
   /* DESCRIPTION
        Stop profiler data collection in the user's session.
        This function also has the side effect of flushing data collected so
        far in the session, and it signals the end of a run.

      ARGUMENTS
        None.

      EXCEPTION
        None.
   */

   FUNCTION  analyze(location          VARCHAR2,
                     filename          VARCHAR2,
                     summary_mode      BOOLEAN     DEFAULT FALSE,
                     trace             VARCHAR2    DEFAULT NULL,
                     skip              PLS_INTEGER DEFAULT 0,
                     collect           PLS_INTEGER DEFAULT NULL,
                     run_comment       VARCHAR2    DEFAULT NULL,
                     profile_uga       BOOLEAN     DEFAULT NULL,
                     profile_pga       BOOLEAN     DEFAULT NULL
                    ) RETURN NUMBER;
   /* DESCRIPTION:
      This function analyzes the raw profiler output and produces hierarchical
      profiler information in database tables.
      [Note: Use the dbmshptab.sql script located in the rdbms/admin directory
       to create the hierarchical profiler database tables and other data
       structures required for persistently storing the profiler data.]

      ARGUMENTS:
      location -
        The name of a directory object. The raw profiler data file is
        read from the filesystem directory mapped to this directory
        object. Output files are written to this directory as well.

      filename -
        Name of the raw profiler data file to be analyzed.

      summary_mode -
        By default (when "summary_mode" is FALSE), the full analysis is done.
        When "summary_mode" is TRUE, only top level summary information is
        generated into the database tables.

      trace -
        Analyze only the subtrees rooted at the specified "trace" entry.
        By default (when "trace" is NULL), the analysis/reporting is generated
        for the entire run.  The "trace" entry must be specified in the
        qualified format as in for example, "HR"."PKG"."FOO".  [If multiple
        overloads exist for the specified name, all of them will be analyzed.]

      skip -
        Used only when "trace" is specified.  Analyze only the subtrees rooted
        at the specified "trace", but ignore the first "skip" invocations to
        "trace".
        The default value for "skip" is 0.

      collect -
        Used only when "trace" is specified.  Analyze "collect" number of
        invocations of "trace" (starting from "skip"+1'th invocation).
        By default only 1 invocation is collected.

      run_comment -
        User provided comment for this run.

      profile_uga -
        Report UGA usage

      profile_pga - 
        Report PGA usage

      RETURN
        Unique run identifier from dbmshp_runnumber sequence for this run of
        the analyzer.

      EXCEPTION
        invalid filename
        invalid directory object 
        incorrect directory permission
   */

END dbms_hprof;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_hprof FOR sys.dbms_hprof;
