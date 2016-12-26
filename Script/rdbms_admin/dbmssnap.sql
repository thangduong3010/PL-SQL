Rem 
Rem $Header: rdbms/admin/dbmssnap.sql /st_rdbms_11.2.0/1 2010/12/10 19:17:58 mthiyaga Exp $ 
Rem  
Rem Copyright (c) 1991, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      dbmssnap.sql - utilities for snapshots
Rem    DESCRIPTION
Rem      See below
Rem    RETURNS
Rem
Rem  MODIFIED
Rem     mthiyaga   12/06/10  - Backport mthiyaga_bug-4217441 from main
Rem     rburns     08/25/06  - move types into catsnap.sql
Rem     sbodagal   07/24/06  - Lrg 2402759 - Modify ExplainMVArrayType
Rem     mthiyaga   06/02/04  - Add rewritten_txt field to RewriteMessage 
Rem     mxiao      09/17/04  - mark pmarker function parallel 
Rem     mxiao      10/27/03  - move estimate_mview_size to dbms_mview
Rem     mthiyaga   10/15/02  - Add CLOB interface for EXPLAIN_REWRITE()
Rem     nfolkert   10/07/02  - code review cleanup for MV schedule refresh
Rem     nfolkert   10/03/02  - add comments
Rem     nfolkert   09/25/02  - interface change for refresh_mv
Rem     nfolkert   09/10/02  - add flag to schedule object
Rem     nfolkert   07/12/02  - add refresh scheduling
Rem     mthiyaga   10/10/02  - Add extra fields to RewriteMessage
Rem     tfyu       09/24/02  - add nested parameter for refresh(_dependent)
Rem     twtong     11/20/01  - add clob interface for explain_mview
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     wesmith    04/04/01 -  dbms_snapshot: add constants for register_mview
Rem     mthiyaga   02/26/01 -  Remove redundant '/' after CREATE PUBLIC SYNONYM
Rem     nshodhan   02/16/01 -  Bug#1647071: replace mv with mview
Rem     mthiyaga   01/11/01 -  Use fully qualified MV name for EXPLAIN_REWRITE.
Rem     mthiyaga   11/08/00 -  Make xrw's API look similar to xmv
Rem     twtong     11/03/00 -  change explain_mv function prototype
Rem     mthiyaga   09/12/00 -  Move EXPLAIN_REWRITE from dbmssum.sql to dbmssna
Rem     mthiyaga   08/21/00 -  Add VARRAY support for EXPLAIN_MV
Rem     twtong     09/13/00 -  enhance explain_mv
Rem     twtong     09/13/00 -  enhance explain_mv
Rem     slawande   07/20/00 -  Get/Set some session prms when using jobq ref.
Rem     slawande   06/06/00 -  Add procedure to execute refresh thru job_queue
Rem     jraitto    06/27/00 -  explain mv
Rem     tfyu       02/19/00 -  add partition marker function
Rem     evandeve   10/08/99 -  mview integration
Rem     kdias      07/07/99 -  add get_mv_dependencies                        
Rem     wesmith    08/06/99 -  Preserve refresh group id when exporting
Rem                            RepAPI snapshots
Rem     nshodhan   03/19/99 -  Add flag to make_repapi                         
Rem     igreenbe   01/04/99 -  bug#784822 - fix comments for refresh_dependent 
Rem                            and refresh_all_mviews
Rem     wesmith    11/14/98 -  change user_export_child signature              
Rem     wesmith    11/13/98 -  RepAPI export code review fixes                 
Rem     wesmith    11/05/98 -  Add support for export of RepAPI refresh groups 
Rem     avaradar   10/14/98 -  Bug#708846: Remove rbdms_snapshot_utility       
Rem     hasun      05/20/98 -  Integrate with SM API                           
Rem     hasun      05/12/98 -  Add dbms_mview as a synonym for dbms_snapshot   
Rem     igreenbe   12/16/97 -  Update consistent snapshot refresh limit to 400
Rem     hasun      10/09/97 -  Change defaults in dbms_snapshot_utility
Rem     hasun      06/09/97 -  Add dbms_snapshot_utility package
Rem     liwong     04/21/97 -  Remove execute_as_user parameter
Rem     masubram   04/04/97 -  Fix merge conflicts
Rem     masubram   03/27/97 -  declare constants for snapshot version
Rem     masubram   03/11/97 -  re-implement snapshot registration
Rem     hasun      03/05/97 -  Expose heap_size for parallel propagation
Rem     hasun      02/27/97 -  Expose new queueu push parameters in for refresh
Rem     masubram   01/27/97 -  Make purge_snapshot_from_log public
Rem     hasun      10/14/96 -  Remove table_reorganized()
Rem     hasun      10/07/96 -  Relocate snapshot registration procedures
Rem     hasun      10/07/96 -  Relocate setup, wrapup and other V7 RPCs
Rem     hasun      10/04/96 -  Move internal trigger support procedures
Rem     hasun      10/01/96 -  Reorganize V8 RPCs
Rem     hasun      08/09/96 -  Move get_lob_columns_info to dbms_snapshot
Rem     ldoo       05/15/96 -  New security model
Rem     ldoo       05/09/96 -  Add support for exp/imp snapshot triggers
Rem     hasun      05/06/96 -  replmerge
Rem     hasun      04/29/96 -  Remove public synonym for dbms_snapshot_utl
Rem     ashgupta   04/25/96 -  adding dbms_snapshot_utl
Rem     ashgupta   04/25/96 -  moving vector_compare to dbms_snapshot
Rem     ashgupta   04/15/96 -  modifying get_log_name
Rem     ashgupta   04/10/96 -  modifying verify-log
Rem     hasun      04/08/96 -  Implement new snapshot id
Rem     ashgupta   04/04/96 -  adding log validation
Rem     hasun      03/08/96 -  Fix merge problems
Rem     hasun      02/09/96 -  Start V8 project: Subquery Snapshots
Rem     ashgupta   02/09/96 -  Merging  snapshot registration code (proj 2045)
Rem     ashgupta   02/07/96 -  adding RPC for getting flag from mlog$
Rem     hasun      01/10/96 -  Split verification() from set_up()
Rem     hasun      01/02/96 -  Add table_reorganized()
Rem     hasun      12/19/95 -  Modify set_up and wrap_up for pk snaps
Rem     hasun      12/11/95 -  Add support procs for primary key snasphots
Rem     adowning   12/23/94 -  merge changes from branch 1.13.720.1
Rem     boki       12/21/94 -  merge changes from branch 1.6.710.10
Rem     boki       12/08/94 -  add new formal parameter to refresh()
Rem     adowning   11/11/94 -  merge changes from branch 1.6.710.9
Rem     adowning   10/24/94 -  add comments to refresh
Rem     adowning   10/11/94 -  make i_am_a_refresh a function
Rem     rjenkins   02/17/94 -  adding defaults
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     rjenkins   01/13/94 -  adding rollback seg to refresh groups
Rem     rjenkins   12/21/93 -  supporting import/export
Rem     rjenkins   12/17/93 -  creating job queue
Rem     rjenkins   11/02/93 -  adding explicit language flag to parse
Rem     rjenkins   10/22/93 -  work even if name_tokenize does not work
Rem     rjenkins   10/14/93 -  merge changes from branch k7010101
Rem     rjenkins   10/12/93 -  moving comma_to_table to dbmsutil
Rem     rjenkins   10/11/93 -  change default refresh method to NULL
Rem     rjenkins   08/30/93 -  push deferred txn queues before refresh
Rem     rjenkins   08/17/93 -  adding clear_refresh
Rem     rjenkins   07/22/93 -  stop hardcoding foo, bar
Rem     rjenkins   07/06/93 -  adding i_am_a_refresh
Rem     ghallmar   05/02/93 -  add multi-table consistent refresh 
Rem     mmoore     10/02/92 -  change pls_integer to binary_integer 
Rem     rjenkins   06/02/92 -  changing comment types 
Rem     rjenkins   02/12/92 -  more snapshot changes 
Rem     rjenkins   11/25/91 -  Creation 

CREATE OR REPLACE PACKAGE dbms_snapshot IS

  -- constants for snapshot version
  reg_unknown	      CONSTANT NUMBER := 0;
  reg_v7_snapshot     CONSTANT NUMBER := 1;
  reg_v8_snapshot     CONSTANT NUMBER := 2;
  reg_repapi_snapshot CONSTANT NUMBER := 3;  

  -- constants for register_mview(), parameter 'flag'
  -- NOTE: keep these constants in sync with snap$.flag 
  --       and dba_registered_mviews
  reg_rowid_mview            CONSTANT NUMBER := 16;
  reg_primary_key_mview      CONSTANT NUMBER := 32;
  reg_object_id_mview        CONSTANT NUMBER := 536870912;
  reg_fast_refreshable_mview CONSTANT NUMBER := 1;
  reg_updatable_mview        CONSTANT NUMBER := 2;
  
  ------------
  --  OVERVIEW
  --
  --  These routines allow the user to refresh snapshots and purge logs.

  ------------------------------------------------
  --  SUMMARY OF SERVICES PROVIDED BY THIS PACKAGE
  --
  --  refresh		         - refresh a given snapshot
  --  refresh_all	         - refresh all snapshots that are due
  --			           to be refreshed
  --  refresh_dependent          - refresh all stale snapshots that depend
  --                               on the specified master tables
  --  refresh_all_mviews         - refresh all stale snapshots
  --  get_mv_dependencies	 - gets the list of snapshots that depend
  --                               on the specified tables/snapshots. 
  --  i_am_a_refresh             - return TRUE if local site is in the process
  --                               of refreshing one or more snapshots
  --  set_i_am_a_refresh         - set the refresh indicator
  --  begin_table_reorganization - indicate the start of a table reorganization
  --  end_table_reorganization   - indicate the end of a table reorganization
  --  purge_log		         - purge log of unnecessary rows
  --  purge_direct_load_log	 - purge direct loader log of unnecessary rows
  --  register_snapshot          - register a snapshot with the master site
  --  unregister_snapshot        - unregister a snapshot with the master site
  --  purge_snapshot_from_log    - purge the snapshot log for a specific 
  --                               snapshot
  --  pmarker			 - partition marker generator
  --  explain_rewrite            - explain why a query failed to rewrite
  --  explain_mview              - explain an mv or potential mv
  --  estimate_mview_size        - estimate the size of a potential MV

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  --  -----------------------------------------------------------------------
  --  Transaction consistent refresh of an array of snapshots.
  --  The max number of snapshots that can be consistently refreshed is 400.
  --  The snapshots are refreshed atomically and consistently. 
  --  Atomically: all snapshots are refreshed or none are.
  --  Consistently: all integrity constraints that hold among master tables 
  --                will hold among the snapshot tables. 
  --  	
  --   LIST
  --     A comma-separated list or PL/SQL table of the snapshots 
  --     to be refreshed.
  --   METHOD
  --     A string that contains a letter for each 
  --     of the snapshots in the array according to the following codes:
  --     '?' -- use fast refresh when possible
  --     'F' -- use fast refresh or raise an error if not possible
  --     'C' -- perform a complete refresh, copying the entire snapshot from
  --            the master
  --     The default method for refreshing a snapshot is the method stored for
  --     that snapshot in the data dictionary.
  --   ROLLBACK_SEG 
  --     The name of the rollback segment to use while 
  --     refreshing snapshots.
  --   PUSH_DEFERRED_RPC 
  --     If TRUE then push all changes made to an updatable snapshot to its 
  --     associated master before refreshing the snapshot.  Otherwise, these
  --     changes may appear to be temporarily lost.
  --   REFRESH_AFTER_ERRORS
  --     If TRUE, then allow the refresh to proceed
  --     even if there are outstanding conflicts logged in the DefError
  --     table for the snapshot's master.
  --   PURGE_OPTION
  --     How to purge the transaction queue if PUSH_DEFERRED_RPC is true.
  --     0 = don't
  --     1 = cheap but imprecise (optimize for time)
  --     2 = expensive but precise (optimize for space)
  --   PARALLELISM
  --     Max degree of parallelism for pushing deferred RPCs. This value
  --     is considered only if PUSH_DEFERRED_RPC is true.
  --     0 = (old algorithm) serial propagation
  --     1 = (new algorithm) parallel propagation with only 1 slave
  --     n = (new algorithm) parallel propagation with n slaves
  --   HEAP_SIZE
  --     The max number of txns to be examined simultaneously for
  --     parallel scheduling computation. This parameter is used only if
  --     the value of the PARALLELISM parameter is greater than 0.
  --   ATOMIC_REFRESH
  --     If TRUE, then perform the refresh operations for the specified
  --     set of snapshots in a single transaction. This guarantees that either
  --     all of the snapshots are successfully refresh or none of the snapshots
  --     are refreshed.
  --   NESTED
  --     If TRUE, then perform nested refresh operations for the specified
  --     set of MVs. Nested refresh operations refresh all the depending MVs 
  --     and the specified set of MVs based on a dependency order to ensure
  --     the MVs are truly fresh with respect to the underlying base tables.
  PROCEDURE refresh(list                 IN VARCHAR2,
                    method               IN VARCHAR2       := NULL,
                    rollback_seg         IN VARCHAR2       := NULL,
                    push_deferred_rpc    IN BOOLEAN        := TRUE,
                    refresh_after_errors IN BOOLEAN        := FALSE,
                    purge_option         IN BINARY_INTEGER := 1,
                    parallelism          IN BINARY_INTEGER := 0,
                    heap_size            IN BINARY_INTEGER := 0,
                    atomic_refresh       IN BOOLEAN        := TRUE,
                    nested               IN BOOLEAN        := FALSE);

  PROCEDURE refresh(tab                  IN OUT dbms_utility.uncl_array,
                    method               IN VARCHAR2       := NULL,
                    rollback_seg         IN VARCHAR2       := NULL,
                    push_deferred_rpc    IN BOOLEAN        := TRUE,
                    refresh_after_errors IN BOOLEAN        := FALSE,
                    purge_option         IN BINARY_INTEGER := 1,
                    parallelism          IN BINARY_INTEGER := 0,
                    heap_size            IN BINARY_INTEGER := 0,
                    atomic_refresh       IN BOOLEAN        := TRUE,
                    nested               IN BOOLEAN        := FALSE);

  --  -----------------------------------------------------------------------
  --  Execute all refresh jobs due to be executed
  --  Requires ALTER ANY SNAPSHOT privilege
  PROCEDURE refresh_all;

  --  -----------------------------------------------------------------------
  --  Refresh all local snapshots based on a specified local master table where 
  --    1) the table has been modified since it was last successfully refreshed
  --    2) the snapshot is a member of dba_mview_analysis
  --  NOTE: 
  --    A snapshot will be considered only if all of its tables are local.
  --
  --   NUMBER_OF_FAILURES
  --     Returns the number of failures that occurred during processing.
  --   LIST
  --     A comma-separated list of the master tables to consider.
  --   TAB
  --     A PL/SQL table of the master tables to consider.
  --   METHOD
  --     A string of refresh methods indicating how to refresh the dependent
  --     snapshots.  All of the snapshots that depend on a particular table 
  --     are refreshed according to the refresh method associated with that 
  --     table.  If a table does not have a corresponding refresh method 
  --     (that is, more tables are specified than refresh methods), then any 
  --     snapshot that depends on that table is refreshed according to its 
  --     default refresh method.  The default refresh method for a snapshot 
  --     is stored in the data dictionary.
  --     The refresh methods are represented by the following codes:
  --     '?' -- use fast refresh if possible;  otherwise, use complete refresh
  --     'F' -- use fast refresh if possible;  otherwise, raise an error
  --     'C' -- use complete refresh to construct the entire snapshot from 
  --            the master tables
  --   ROLLBACK_SEG 
  --     The name of the rollback segment to use while refreshing the snapshots.
  --   REFRESH_AFTER_ERRORS
  --     If TRUE and if ATOMIC_REFRESH is FALSE, then an error will not be 
  --     raised if an error is encountered during the refresh.  Otherwise, 
  --     any error encountered during refresh will be raised.
  --   ATOMIC_REFRESH
  --     If TRUE, then refresh all of the dependent snapshots in a single 
  --     transaction.  This guarantees that either all of the snapshots are 
  --     successfully refreshed or none of the snapshots are refreshed.  
  --     Otherwise, refresh each dependent snapshot in a separate transaction.
  --   NESTED
  --     If TRUE, then perform nested refresh operations for the specified
  --     set of tables. Nested refresh operations refresh all the depending MVs 
  --     of the specified set of tables based on a dependency order to ensure
  --     the MVs are truly fresh with respect to the underlying base tables.
  PROCEDURE refresh_dependent(number_of_failures   OUT BINARY_INTEGER,
                              list                  IN VARCHAR2,
                              method                IN VARCHAR2 := NULL,
                              rollback_seg          IN VARCHAR2 := NULL,
                              refresh_after_errors  IN BOOLEAN  := FALSE,
                              atomic_refresh        IN BOOLEAN  := TRUE,
                              nested                IN BOOLEAN  := FALSE);

  PROCEDURE refresh_dependent(number_of_failures   OUT BINARY_INTEGER,
                              tab                   IN dbms_utility.uncl_array,
                              method                IN VARCHAR2 := NULL,
                              rollback_seg          IN VARCHAR2 := NULL,
                              refresh_after_errors  IN BOOLEAN  := FALSE,
                              atomic_refresh        IN BOOLEAN  := TRUE,
                              nested                IN BOOLEAN  := FALSE);

  --  -----------------------------------------------------------------------
  --  Refresh all local snapshots based on a local master table where 
  --    1) the table has been modified since it was last successfully refreshed
  --    2) the snapshot is a member of dba_mview_analysis
  --  NOTE: 
  --    A snapshot will be considered only if all of its tables are local.
  --
  --   NUMBER_OF_FAILURES
  --     Returns the number of failures that occurred during processing.
  --   METHOD
  --     A single refresh method indicating how to refresh the dependent 
  --     snapshots.  If a refresh method is not specified, then any dependent
  --     snapshot is refreshed according to its default refresh method.  The 
  --     default refresh method for a snapshot is stored in the data dictionary.
  --     A refresh method is represented by the following codes:
  --     '?' -- use fast refresh if possible;  otherwise, use complete refresh
  --     'F' -- use fast refresh if possible;  otherwise, raise an error 
  --     'C' -- use complete refresh to construct the entire snapshot from 
  --            the master tables
  --   ROLLBACK_SEG 
  --     The name of the rollback segment to use while refreshing the snapshots.
  --   REFRESH_AFTER_ERRORS
  --     If TRUE and if ATOMIC_REFRESH is FALSE, then an error will not be 
  --     raised if an error is encountered during the refresh.  Otherwise, 
  --     any error encountered during refresh will be raised.
  --   ATOMIC_REFRESH
  --     If TRUE, then refresh all of the dependent snapshots in a single 
  --     transaction.  This guarantees that either all of the snapshots are 
  --     successfully refreshed or none of the snapshots are refreshed.  
  --     Otherwise, refresh each dependent snapshot in a separate transaction.
  PROCEDURE refresh_all_mviews(number_of_failures   OUT BINARY_INTEGER,
                               method                IN VARCHAR2 := NULL,
                               rollback_seg          IN VARCHAR2 := NULL,
                               refresh_after_errors  IN BOOLEAN  := FALSE,
                               atomic_refresh        IN BOOLEAN  := TRUE);

  -- ------------------------------------------------------------------------
  -- This procedure finds the list of materialized view that are directly
  -- dependent on the list of tables or materialized views that has been 
  -- specified.
  --
  -- LIST : 
  --   A comma separated list of the tables/materialized views to consider
  -- DEPLIST
  --   The list of materialized views that are directly dependent on the 
  --   tables/materialized view that has been specified in "LIST".
  --
  PROCEDURE get_mv_dependencies(list		IN VARCHAR2,		
 				deplist	       OUT VARCHAR2);

  -- ------------------------------------------------------------------------
  -- This procedure disables or enables snapshot replication trigger at the
  -- local snapshot site.
  -- value = TRUE  -> disable all local replication triggers for snapshots
  -- value = FALSE -> enable all local replication triggers for snapshots
  PROCEDURE set_i_am_a_refresh(value IN BOOLEAN);

  -- ------------------------------------------------------------------------
  -- Returns TRUE if the local site is in the process of refreshing one or
  -- more snapshots. Return FALSE otherwise.
  FUNCTION i_am_a_refresh RETURN BOOLEAN;

  -- ------------------------------------------------------------------------
  -- This procedure must be called before a master table is reorganized. It 
  -- performs process to preserve snapshot data needed for refresh.
  PROCEDURE begin_table_reorganization(tabowner IN VARCHAR2,
                                       tabname  IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- This procedure myst be call after a master tanel is reorganized. It
  -- ensures that the snapshot data for the master table is valid and that
  -- the master table is in the proper state.
  PROCEDURE end_table_reorganization(tabowner IN VARCHAR2,
                                     tabname  IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- Purge the snapshot log for the specified master master of unecessary rows.
  PROCEDURE purge_log(master IN VARCHAR2, 
                      num    IN BINARY_INTEGER := 1, 
                      flag   IN VARCHAR2       := 'NOP' );

  -- ------------------------------------------------------------------------
  -- Remove entries from the direct loader log after they are no longer
  -- needed for any known snapshot.
  PROCEDURE purge_direct_load_log;

  -- ------------------------------------------------------------------------
  -- Invoked at the master site by (remote) snapshot site 'snapsite' to 
  -- register snapshot 'snapname' at the master site. The invocation
  -- is done using a synchronous RPC. 
  -- May also be invoked directly at the master site by the DBA to manually
  -- register a snapshot.
  --
  -- Input argugments:
  --    snapowner   Owner of the snapshot
  --    snapname    Name of the snapshot
  --    snapsite    Name of the snapshot site (should contain no double qoutes)
  --    snapshot_id V7 snapshot identifier
  --    flag        Attributes of the snapshot
  --    qry_txt     Snapshot definition query
  --    rep_type    Version of snapshot
  PROCEDURE register_mview(mviewowner   IN VARCHAR2,
                           mviewname    IN VARCHAR2,
                           mviewsite    IN VARCHAR2,
                           mview_id     IN DATE,
                           flag         IN BINARY_INTEGER, 
                           qry_txt      IN VARCHAR2,
			   rep_type     IN BINARY_integer
			                   := dbms_snapshot.reg_unknown);
  -- Input argugments:
  --    snapowner   Owner of the snapshot
  --    snapname    Name of the snapshot
  --    snapsite    Name of the snapshot site (should contain no double qoutes)
  --    snapshot_id snapshot identifier
  --    flag        Attributes of the snapshot
  --    qry_txt     Snapshot definition query
  --    rep_type    Version of snapshot
  PROCEDURE register_mview(mviewowner   IN VARCHAR2,
                           mviewname    IN VARCHAR2,
                           mviewsite    IN VARCHAR2,
                           mview_id     IN BINARY_INTEGER,
                           flag         IN BINARY_INTEGER, 
                           qry_txt      IN VARCHAR2,
			   rep_type     IN BINARY_integer
			                   := dbms_snapshot.reg_unknown);

  -- ------------------------------------------------------------------------
  -- Invoked at the master site by (remote) snapshot site 'snapsite' to 
  -- unregister snapshot 'snapname' at the master site. The invocation
  -- is done using a synchronous RPC. 
  -- May also be invoked directly at the master site by the DBA to manually
  -- register a snapshot.
  --
  -- Input argugments:
  --    snapowner   Owner of the snapshot
  --    snapname    Name of the snapshot
  --    snapsite    Name of the snapshot site (should contain no double qoutes)
  PROCEDURE unregister_mview(mviewowner IN VARCHAR2,
                             mviewname  IN VARCHAR2,
                             mviewsite  IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- This procedure is called on the master site to delete the rows in 
  -- snapshot refresh related data dictionary tables maintained at the 
  -- master site for the specified snapshot identified by its snapshot_id. 
  -- If the snapshot specified is the oldest snapshot to have refreshed
  -- from any of the  master tables, then the snapshot log is also purged. 
  -- This procedure does not unregister the snapshot.
  --
  -- In case there is an error while purging one of the snapshot logs, the 
  -- successful purge operations of the previous snapshot logs are not rolled 
  -- back. This is to  minimize the size of the snapshot logs. In case of an
  -- error, this procedure can be invoked again until all the snapshot
  -- logs are purged.
  PROCEDURE purge_mview_from_log(mview_id IN BINARY_INTEGER); 

  -- ------------------------------------------------------------------------
  -- This procedure is called on the master site to delete the rows in 
  -- snapshot refresh related data dictionary tables maintained at the 
  -- master site for the specified snapshot. If the snapshot specified is
  -- the oldest snapshot to have refreshed  from any of the master tables, 
  -- then the snapshot log is also purged. This procedure does not unregister
  -- the snapshot.
  --
  -- In case there is an error while purging one of the snapshot logs, the 
  -- successful purge operations of the previous snapshot logs are not rolled 
  -- back. This is to  minimize the size of the snapshot logs. In case of an
  -- error, this procedure can be invoked again until all the snapshot
  -- logs are purged.
  PROCEDURE purge_mview_from_log(mviewowner   IN VARCHAR2, 
                                 mviewname    IN VARCHAR2, 
                                 mviewsite    IN VARCHAR2);

  FUNCTION pmarker (rid IN ROWID) RETURN NUMBER PARALLEL_ENABLE;
  
  
  -- ------------------------------------------------------------------------
  -- Interface for EXPLAIN_MVIEW PROCEDURES
  -- ------------------------------------------------------------------------
  --
  -- ------------------------------------------------------------------------
  -- This procedure explains the various capabilities of a potential 
  -- materialized view or an existing materialized view and the reasons 
  -- why certain capabilities would not be possible for the materialized 
  -- view.  Specify a potential materialized view as a SQL SELECT statement.  
  -- Alternatively, specify an existing materialized view by giving the name
  -- and the schema in which the materialized view was created ([schema.]mvname)
  -- The output is placed in MV_CAPABILITIES_TABLE.  Invoke the admin/utlxmv.sql 
  -- script to define MV_CAPABILITIES_TABLE prior to invoking this procedure.
  PROCEDURE explain_mview ( mv     IN VARCHAR2,
                           stmt_id IN VARCHAR2 := NULL );

  -- ------------------------------------------------------------------------
  -- This procedure explains the various capabilities of a potential
  -- materialized view or an existing materialized view and the reasons
  -- why certain capabilities would not be possible for the materialized
  -- view.  Specify a potential materialized view as a SQL SELECT statement.
  -- Alternatively, specify an existing materialized view by giving the name
  -- and the schema in which the materialized view was created ([schema.]mvname)
  -- It accepts a CLOB instead of VARCHAR, so users can specify SQL string up  
  -- to 4G. The output is placed in MV_CAPABILITIES_TABLE.  Invoke the 
  -- admin/utlxmv.sql script to define MV_CAPABILITIES_TABLE prior to invoking 
  -- this procedure.
  PROCEDURE explain_mview ( mv     IN CLOB,
                           stmt_id IN VARCHAR2 := NULL );
 
  -- ------------------------------------------------------------------------
  -- This procedure explains the various capabilities of a potential
  -- materialized view or an existing materialized view and the reasons 
  -- why certain capabilities would not be possible for the materialized 
  -- view.  Specify a potential materialized view as a SQL SELECT statement.  
  -- Alternatively, specify an existing materialized view by giving the name
  -- and the schema in which the materialized view was created ([schema.]mvname)
  -- The output is placed into an VARRAY.  
  PROCEDURE explain_mview ( mv        IN     VARCHAR2,
                            msg_array IN OUT SYS.ExplainMVArrayType);
 
  -- ------------------------------------------------------------------------
  -- This procedure explains the various capabilities of a potential
  -- materialized view or an existing materialized view and the reasons
  -- why certain capabilities would not be possible for the materialized
  -- view.  Specify a potential materialized view as a SQL SELECT statement.
  -- Alternatively, specify an existing materialized view by giving the name
  -- and the schema in which the materialized view was created ([schema.]mvname)
  -- It accepts a CLOB instead of VARCHAR, so users can specify SQL string up to
  -- 4G. The output is placed into an VARRAY.
  PROCEDURE explain_mview ( mv        IN     CLOB,
                            msg_array IN OUT SYS.ExplainMVArrayType);
 
  -- ------------------------------------------------------------------------
  -- End of user interface for EXPLAIN_MVIEW PROCEDURES
  -- ------------------------------------------------------------------------
 
  -- ------------------------------------------------------------------------
  -- Interface for EXPLAIN_REWRITE PROCEDURES
  -- ------------------------------------------------------------------------
  --
  
  -- PROCEDURE EXPLAIN_REWRITE
  --
  -- PURPOSE: Explain Rewrite user interface using a table for output
  --
  -- PARAMETERS
  -- ========== 
  --
  -- QUERY       : SQL select statement to be explained
  -- MV          : Fully qualified MV name specified by the user (mv_owner.mv_name)
  -- STATEMENT_ID: a unique id from the user to distinguish output messages
  --
  PROCEDURE Explain_Rewrite ( QUERY IN VARCHAR2,
                              MV IN VARCHAR2 := NULL,
                              STATEMENT_ID IN VARCHAR2 := NULL);

  -- PROCEDURE EXPLAIN_REWRITE
  --
  -- PURPOSE: Explain Rewrite user interface using a table for output. This
  --          overloaded function uses CLOB instead of VARCHAR, so users can
  --          specify a SQL query upto 4GB.
  --
  -- PARAMETERS
  -- ==========
  --
  -- QUERY       : SQL select statement to be explained in CLOB
  -- MV          : Fully qualified MV name specified by the user (mv_owner.mv_name)
  -- STATEMENT_ID: a unique id from the user to distinguish output messages
  --
  PROCEDURE Explain_Rewrite ( QUERY IN CLOB,
                              MV IN VARCHAR2 := NULL,
                              STATEMENT_ID IN VARCHAR2 := NULL);

  -- 
  -- PROCEDURE EXPLAIN_REWRITE
  --
  -- PURPOSE: Explain Rewrite user interface using a VARRAY for output
  --
  -- PARAMETERS
  -- ==========
  --
  -- QUERY       : SQL select statement to be explained
  -- MV          : Fully qualified MV name specified by the user (mv_owner.mv_name)
  -- MSG_ARRAY   : name of the output array 
  --
  PROCEDURE Explain_Rewrite ( QUERY IN VARCHAR2,
                                   MV IN VARCHAR2 := NULL,
                                   MSG_ARRAY IN OUT SYS.RewriteArrayType);

  --
  -- PROCEDURE EXPLAIN_REWRITE
  --
  -- PURPOSE: Explain Rewrite user interface using a VARRAY for output. This
  --          overloaded function uses CLOB instead of VARCHAR, so users can
  --          specify a SQL query upto 4GB.
  --
  -- PARAMETERS
  -- ==========
  --
  -- QUERY       : SQL select statement to be explained in CLOB
  -- MV          : Fully qualified MV name specified by the user (mv_owner.mv_name)
  -- MSG_ARRAY   : name of the output array
  --
  PROCEDURE Explain_Rewrite ( QUERY IN CLOB,
                                   MV IN VARCHAR2 := NULL,
                                   MSG_ARRAY IN OUT SYS.RewriteArrayType);

-- PROCEDURE EXPLAIN_REWRITE_SQLID
  --
  -- PURPOSE: Explain Rewrite user interface using a table for output for
  -- using on EM
  --
  -- PARAMETERS
  -- ========== 
  --
  -- QUERY       : SQL select statement to be explained
  -- MV          : Fully qualified MV name specified by the user (mv_owner.mv_name)
  -- STATEMENT_ID: a unique id from the user to distinguish output messages
  -- SQLID       : SQL_ID of the query from EM
  --
  PROCEDURE Explain_Rewrite_SQLID ( QUERY IN VARCHAR2,
                              MV IN VARCHAR2 := NULL,
                              STATEMENT_ID IN VARCHAR2 := NULL,
                              SQLID IN VARCHAR2 := NULL);

  -- ------------------------------------------------------------------------
  -- End of user interface for EXPLAIN_REWRITE PROCEDURES
  -- ------------------------------------------------------------------------

  -- ------------------------------------------------------------------------
  -- This estimates the size of a materialized view that you might create, 
  -- in bytes and number of rows.
  -- PARAMETERS:
  --      stmt_id: NUMBER
  --            User-specified id
  --      select_clause: VARCHAR2
  --            SQL text for the defining query
  --      num_row: NUMBER
  --            Estimated number of rows
  --      num_col: NUMBER
  --            Estimated number of bytes
  -- COMMENTS:
  --      This procedure requires that 'utlxplan.sql' be executed
  PROCEDURE estimate_mview_size (stmt_id         IN VARCHAR2,
                                 select_clause   IN VARCHAR2,
                                 num_rows        OUT NUMBER,
                                 num_bytes       OUT NUMBER);


  --- #######################################################################
  --- INTERNAL PROCEDURES
  ---
  --- The following procedure provide internal functionality and should
  --- not be called directly. 
  ---
  --- #######################################################################

  ---  These interfaces are obselete in V8 and are present only for 
  ---  providing backwards compatibility

  PROCEDURE set_up(mowner   IN     VARCHAR2, 
                   master   IN     VARCHAR2, 
                   log      IN OUT VARCHAR2,
	           snapshot IN OUT DATE,
                   snaptime IN OUT DATE);

  PROCEDURE wrap_up(mowner IN VARCHAR2, 
                    master IN VARCHAR2, 
                    sshot  IN DATE, 
                    stime  IN DATE);

  PROCEDURE get_log_age(oldest IN OUT DATE, 
                        mow    IN     VARCHAR2, 
                        mas    IN     VARCHAR2);

  -- obselete interface, present for backward compatability
  PROCEDURE drop_snapshot(mowner   IN VARCHAR2, 
                          master   IN VARCHAR2, 
                          snapshot IN DATE);

  PROCEDURE testing;

  -- Internal Procedure ONLY. DO NOT USE DIRECTLY
  -- Note: added parameter 'resources' for internal parallel resource 
  -- load balancing
  PROCEDURE refresh_mv (pipename       IN  VARCHAR2,
                        mv_index       IN  BINARY_INTEGER,
                        owner          IN  VARCHAR2,
                        name           IN  VARCHAR2,
                        method         IN  VARCHAR2,
                        rollseg        IN  VARCHAR2,
                        atomic_refresh IN  BINARY_INTEGER,
                        env            IN BINARY_INTEGER,
                        resources      IN BINARY_INTEGER DEFAULT 0);
  
  --- #######################################################################
  --- #######################################################################
  ---                        DEPRECATED PROCEDURES
  ---
  --- The following procedures will soon obsolete due to the materialized
  --- view integration with snapshots. They are kept around for backwards
  --- compatibility purposes.
  ---
  --- #######################################################################
  --- #######################################################################
  PROCEDURE register_snapshot(snapowner   IN VARCHAR2,
                  snapname    IN VARCHAR2,
                  snapsite    IN VARCHAR2,
                  snapshot_id IN DATE,
                  flag        IN BINARY_INTEGER, 
                  qry_txt     IN VARCHAR2,
                  rep_type    IN BINARY_INTEGER := dbms_snapshot.reg_unknown);

  PROCEDURE register_snapshot(snapowner   IN VARCHAR2,
                  snapname    IN VARCHAR2,
                  snapsite    IN VARCHAR2,
                  snapshot_id IN BINARY_INTEGER,
                  flag        IN BINARY_INTEGER, 
                  qry_txt     IN VARCHAR2,
                  rep_type    IN BINARY_INTEGER := dbms_snapshot.reg_unknown);

  PROCEDURE unregister_snapshot(snapowner IN VARCHAR2,
                                snapname  IN VARCHAR2,
                                snapsite  IN VARCHAR2);

  PROCEDURE purge_snapshot_from_log(snapshot_id IN BINARY_INTEGER); 

  PROCEDURE purge_snapshot_from_log(snapowner   IN VARCHAR2, 
                                    snapname    IN VARCHAR2, 
                                    snapsite    IN VARCHAR2);





END dbms_snapshot;
/
GRANT EXECUTE ON dbms_snapshot TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_snapshot FOR dbms_snapshot
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_mview FOR dbms_snapshot
/


CREATE OR REPLACE PACKAGE dbms_refresh IS
  -- dbms_refresh is the interface for administering refresh groups.

  -- CONSTANTS
  --
  -- constants for rgroup$.flag
  -- NOTE: if you make any changes here, you must change the 
  --       corresponding constants in prvtsnap.sql
  --
  REPAPI_RGROUP CONSTANT NUMBER := 8;

  -- ------------------------------------------------------------------------
  -- MAKE a new refresh group.
  --
  -- PARAMETERS:
  -- NAME is of the form 'foo' or 'user.foo' or '"USER"."FOO"'.  
  --   The logged-in user is used as a default.
  -- LIST is a comma-separated list of objects to be refreshed, such as
  --     'foo, scott.bar ,"SCOTT"."BLUE"'.  The default user is the owner
  --     of the refresh group.
  -- TAB  is a PL/SQL table of objects to be refreshed, starting with 1
  --   and filling every number until an entry is NULL, with every entry
  --   formatted the same way as NAME.  The default user is the owner
  --   of the refresh group.
  -- NEXT_DATE is the date for the refresh group to first be refreshed.
  --   See dbmsjobq.sql .  If there is no current job, the default interval
  --   will be 'null' and the job will delete itself after refreshing the
  --   group at NEXT_DATE.
  -- INTERVAL is used to determine the next NEXT_DATE.  See dbmsjobq.sql .
  --   If there is no current job, NEXT_DATE will default to null and the
  --   job will not run until you manually set NEXT_DATE to something else
  --   or manually refresh the group.
  -- IMPLICIT_DESTROY means to delete the refresh group when the last item
  --   is subtracted from it.  The value is stored with the group definition.
  --   Empty groups can be created with IMPLICIT_DESTROY set.

  PROCEDURE make(name                 IN VARCHAR2,
                 list                 IN VARCHAR2,
                 next_date            IN DATE,
                 interval             IN VARCHAR2,
                 implicit_destroy     IN BOOLEAN        := FALSE,
                 lax                  IN BOOLEAN        := FALSE,
                 job                  IN BINARY_INTEGER := 0,
                 rollback_seg         IN VARCHAR2       := NULL,
                 push_deferred_rpc    IN BOOLEAN        := TRUE,
                 refresh_after_errors IN BOOLEAN        := FALSE,
                 purge_option         IN BINARY_INTEGER := 1,
                 parallelism          IN BINARY_INTEGER := 0,
                 heap_size            IN BINARY_INTEGER := 0);

  PROCEDURE make(name                 IN VARCHAR2,
                 tab                  IN dbms_utility.uncl_array,
                 next_date            IN DATE,
                 interval             IN VARCHAR2,
                 implicit_destroy     IN BOOLEAN        := FALSE,
                 lax                  IN BOOLEAN        := FALSE,
                 job                  IN BINARY_INTEGER := 0,
                 rollback_seg         IN VARCHAR2       := NULL,
                 push_deferred_rpc    IN BOOLEAN        := TRUE,
                 refresh_after_errors IN BOOLEAN        := FALSE,
                 purge_option         IN BINARY_INTEGER := 1,
                 parallelism          IN BINARY_INTEGER := 0,
                 heap_size            IN BINARY_INTEGER := 0);

  PROCEDURE make_repapi(
                 refgroup    IN BINARY_INTEGER,
                 name        IN VARCHAR2,
                 siteid      IN BINARY_INTEGER,
                 refresh_seq IN BINARY_INTEGER,
                 export_db   IN VARCHAR2,
                 flag        IN BINARY_INTEGER DEFAULT REPAPI_RGROUP);

  -- ------------------------------------------------------------------------
  -- ADD some refreshable objects to a refresh group.
  PROCEDURE add(name      IN VARCHAR2,
                list      IN VARCHAR2,
                lax       IN BOOLEAN  := FALSE,
                siteid    IN BINARY_INTEGER := 0,
                export_db IN VARCHAR2 := NULL );
  PROCEDURE add(name      IN VARCHAR2,
                tab       IN dbms_utility.uncl_array,
                lax       IN BOOLEAN  := FALSE,
                siteid    IN BINARY_INTEGER := 0,
                export_db IN VARCHAR2 := NULL );

  -- ------------------------------------------------------------------------
  -- SUBTRACT some refreshable objects from a refresh group.
  PROCEDURE subtract(name IN VARCHAR2,
                     list IN VARCHAR2,
                     lax  IN BOOLEAN  := FALSE );
  PROCEDURE subtract(name IN VARCHAR2,
                     tab  IN dbms_utility.uncl_array,
                     lax  IN BOOLEAN  := FALSE );

  -- ------------------------------------------------------------------------
  -- DESTROY a refresh group, make it cease to exist.
  PROCEDURE destroy(name IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- Change any changeable pieces of the job that does the refresh
  PROCEDURE change(name                 IN VARCHAR2,
                   next_date            IN DATE           := NULL,
                   interval             IN VARCHAR2       := NULL,
                   implicit_destroy     IN BOOLEAN        := NULL,
                   rollback_seg         IN VARCHAR2       := NULL,
                   push_deferred_rpc    IN BOOLEAN        := NULL,
                   refresh_after_errors IN BOOLEAN        := NULL,
                   purge_option         IN BINARY_INTEGER := NULL,
                   parallelism          IN BINARY_INTEGER := NULL,
                   heap_size            IN BINARY_INTEGER := NULL);
  
  -- ------------------------------------------------------------------------
  -- Atomically, consistently refresh all objects in a refresh group now.
  -- Clear the BROKEN flag for the job if the refresh succeeds
  PROCEDURE refresh(name IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- Produce the text of a call for recreating the given group
  PROCEDURE user_export(rg#    IN      BINARY_INTEGER,
                        mycall IN OUT VARCHAR2);

  -- ------------------------------------------------------------------------
  -- Produce the text of a call for recreating the given group item
  PROCEDURE user_export_child(myowner IN     VARCHAR2,
                              myname  IN     VARCHAR2,
                              mytype  IN     VARCHAR2,
                              mycall  IN OUT VARCHAR2, 
                              mysite  IN     BINARY_INTEGER := 0);

END dbms_refresh;
/
GRANT EXECUTE ON dbms_refresh TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_refresh FOR dbms_refresh
/


