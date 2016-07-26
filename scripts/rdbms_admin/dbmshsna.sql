Rem
Rem $Header: dbmshsna.sql 19-feb-2001.16:44:32 nshodhan Exp $
Rem
Rem dbmshsna.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 1997, 1998, 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmshsna.sql - Header (package specification) of dbms_repcat_SNA
Rem
Rem    DESCRIPTION
Rem      These are utility procedures and functions for snapshots.
Rem      This package should be standalone for snapshots (i.e., it should not
Rem      call other dependent functions/procedures).
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem      See prvtbsna.sql for its body.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nshodhan    02/19/01  - Bug#1650475: change snap->mview
Rem    apadmana    10/07/99  - bug 724258: remove parameter 
Rem                            force_fail from switch_snapshot_master
Rem    hasun       05/07/99  - Modify comments re:Flavors                      
Rem    mimoy       01/06/99  - Add comments: failaltersnaprop, alreadymastered
Rem    liwong      12/16/98  - support for multiple snapshot repgroups         
Rem    hasun       12/12/98  - Modify repcat_import_check()                    
Rem    avaradar    12/09/98  - support for multiple snapshot repgroups         
Rem    jstamos     04/20/98  - add flavor routines                             
Rem    jstamos     03/06/98  - flavor support                                  
Rem    wesmith     09/15/97 -  Untrusted security model enhancements
Rem    hasun       06/05/97 -  Fix comments
Rem    sbalaram    06/03/97 -  more cleanup
Rem    sbalaram    05/09/97 -  cleanup comments
Rem    masubram    04/28/97 -  Fix merge problems
Rem    masubram    04/18/97 -  fix switch snapshot master
Rem    liwong      04/18/97 -  remove sname/execute_as_user in 
Rem                         -  switch_snapshot_master
Rem    masubram    04/13/97 -  use defined constants for (un)register_snapshot_
Rem    masubram    04/01/97 -  comment (un)register_snapshot_group
Rem    masubram    03/13/97 -  Modify definitions for snapshot registration
Rem    celsbern    01/23/97 -  Added register_snapshot_repgroup and
Rem                            unregister_snapshot_repgroup, missing after
Rem                            split.
Rem    celsbern    10/05/96 -  Creation (from splitting prvtrepc.sql)
Rem

CREATE OR REPLACE PACKAGE dbms_repcat_sna AS

  --
  -- NOTE: The type varchar2s is equivalent to the type varchar2s
  --       in the package dbms_repcat.  If you make changes to this
  --       version, please make the same changes to the other version.
  --       
  TYPE varchar2s IS TABLE OF VARCHAR(60) INDEX BY BINARY_INTEGER;

  ----------------------------------------------------------------------------
  PROCEDURE register_snapshot_repgroup(gname    IN VARCHAR2, 
                                       snapsite IN VARCHAR2, 
                                       comment  IN VARCHAR2 := NULL,
                                       rep_type IN NUMBER
                                             := dbms_repcat_decl.reg_unknown,
                                       fname    IN VARCHAR2 := NULL,
                                       gowner   IN VARCHAR2 := 'PUBLIC');
  -- This procedure is used at the master site to manually register
  -- a snapshot repgroup.
  -- Arguments:
  --   gname: Name of the repgroup
  --   snapsite: Site of the snapshot repgroup
  --   comment: comment describing the snapshot repgroup
  --   rep_type: Version of the snapshot group (valid constants are
  --     defined in dbms_repcat package header)
  --   fname: This parameter is reserved for internal use.  
  --          Do not specify this parameter unless directed 
  --          by Oracle Worldwide Customer Support.
  --   gowner: Owner of the repgroup
  ----------------------------------------------------------------------------
  PROCEDURE unregister_snapshot_repgroup(gname    IN VARCHAR2, 
                                         snapsite IN VARCHAR2,
                                         gowner   IN VARCHAR2 := 'PUBLIC');
  -- This procedure is used at the master site to manually unregister
  -- a snapshot repgroup.
  -- Arguments:
  --   gname: Name of the repgroup
  --   snapsite: Site of the snapshot repgroup
  --   gowner: owner of the repgroup
  ----------------------------------------------------------------------------
  PROCEDURE alter_snapshot_propagation(gname            IN VARCHAR2,
                                       propagation_mode IN VARCHAR2,
                                       comment          IN VARCHAR2 := '',
                                       gowner           IN VARCHAR2 
                                                           := 'PUBLIC');
  -- Alter the propagation method of all replication snapshots, procedure,
  -- packages, and package bodies for all snapshot repobjects in the
  -- specified snapshot repgroup.
  --
  -- Altering the propagation method involves regenerating replication
  -- support at the materialized view site.
  --
  -- Arguments:
  --   gname: name of the snapshot object group
  --   propagation_mode: SYNCHRONOUS or ASYNCHRONOUS
  --   comment: comment added to the RepProp view
  --   gowner: owner of the snapshot object group
  --
  -- Exceptions:
  --   notcompat: only databases operating in 7.3 (or later) mode can
  --     use this procedure.
  --   missingrepgroup: replicated object group does not exist
  --   typefailure: incorrect propagation mode specified
  --   commfailure: cannot contact master
  --   failaltermviewrop: materialized view repgroup propagation can be 
  --   altered only when there is no other repgroup with the same master 
  --   sharing the site.
 ----------------------------------------------------------------------------
  PROCEDURE create_snapshot_repgroup(gname            IN VARCHAR2,
                                     master           IN VARCHAR2,
                                     comment          IN VARCHAR2 := '',
                                     propagation_mode IN VARCHAR2 
                                                         := 'ASYNCHRONOUS',
                                     fname            IN VARCHAR2 := NULL,
                                     gowner           IN VARCHAR2
                                                         := 'PUBLIC');
  -- Create a new empty snapshot repgroup at the local site. The group name
  -- must be a master repgroup at the master database.
  --
  -- Arguments:
  --   gname: name of the replicated object group
  --   master: database to use as the master
  --   comment: comment added to the schema_comment field of RepCat view
  --   propagation_mode: method of propagation for all updatable snapshots
  --     in the object group (SYNCHRONOUS or ASYNCHRONOUS)
  --   fname: This parameter is reserved for internal use.  
  --          Do not specify this parameter unless directed 
  --          by Oracle Worldwide Customer Support.
  --   gowner: owner of the replicated object group
  --
  -- Exceptions:
  --   duplicaterepgroup: if the objectgroup already exists as a repgroup
  --     at the invocation site.
  --   nonmaster: if the given database is not a master site.
  --   commfailure: if the given database is not accessible.
  --   norepoption: if advanced replication option not installed
  --   typefailure: if propagation mode specified incorrectly
  --   missingrepgroup: object group missing at master site
  --   invalidqualifier: connection qualifier specified for master is not
  --     valid for the object group
  --   alreadymastered: if at the local site there is another snapshot 
  --     repgroup with the same group name, but different master.
 ----------------------------------------------------------------------------
  PROCEDURE create_snapshot_repobject(sname             IN VARCHAR2,
                                      oname             IN VARCHAR2,
                                      type              IN VARCHAR2,
                                      ddl_text          IN VARCHAR2 := '',
                                      comment           IN VARCHAR2 := '',
                                      gname             IN VARCHAR2 := '',
                                      gen_objs_owner    IN VARCHAR2 := '',
                                      min_communication IN BOOLEAN := TRUE,
                                      generate_80_compatible
                                                        IN BOOLEAN := TRUE,
                                      gowner            IN VARCHAR2
                                                           := 'PUBLIC');
  -- Add the given object name and type to the RepObject view at the local
  -- snapshot repgroup. The allowed types are `package', `package body',
  -- 'procedure', `snapshot', `synonym', 'trigger', 'index' and `view'.
  --
  -- For objects of type `snapshot', create the row-level replication trigger
  -- and client-side half of the stored package if the underlying table
  -- uses row/column-level replication.
  --
  -- The parameter ddl_text defines the snapshot if the snapshot does not 
  -- already exist. The value of oname should match the snapshot
  -- name defined in the ddl_text.  The snaphot's master should match the
  -- master stored in all_repgroup, this includes the connection qualifier
  -- that may be associated with the master group.
  -- 
  -- gen_objs_owner indicates the schema in which the generated procedural 
  -- wrapper should be install. If this parameter is NULL, the value of the 
  -- sname parameter is used.
  --
  -- If min_communication is TRUE and type is 'SNAPSHOT', the update trigger
  -- sends the new value of a column only if the update statement modifies the
  -- column.  The update trigger sends the old value of the column only if it
  -- is a key column or a column in a modified column group.
  --
  -- If generate_80_compatible is true, deferred RPC's with the TOP
  -- flavor are generated using the 8.0 protocol.
  --
  -- gowner is the owner of the replicated object group
  --
  -- Exceptions:
  --   missingschema if specified owner of generated objects does not exist
  --   nonmview if the invocation site is not a materialized view site.
  --   nonmaster if the master is no longer a master site.
  --   missingobject if the given object does not exist in the master's
  --     replicated object group.
  --   duplicateobject if the given object already exists.
  --   typefailure if the type is not an allowable type.
  --   ddlfailure if the DDL does not succeed.
  --   commfailure if the master is not accessible.
  --   badmviewddl if th ddl was executed but materialized view does not exist
  --   onlyonemview if only one materialized view for master table can be 
  --                created
  --   badmviewname if materialized view base table differs from master table
  --   misingrepgroup if replicated object group does not exist
  ----------------------------------------------------------------------------
  PROCEDURE create_snapshot_repschema(sname   IN VARCHAR2,
                                      master  IN VARCHAR2,
                                      comment IN VARCHAR2 := '');
  -- OBSOLETE PROCEDURE: use create_snapshot_repgroup()
  -- Create a new empty snapshot repschema. The schema name must be a master
  -- repschema at the master database. In addition, the schema must also exist
  -- locally as a database schema.
  -- 
  -- Exceptions:
  --   duplicateschema: if the schema already exists as a replicated object  
  --                    group at the invocation site.
  --   nonmaster: if the given database is not a master site.
  --   commfailure: if the given database is not accessible.
  ----------------------------------------------------------------------------
  PROCEDURE drop_snapshot_repgroup(gname         IN VARCHAR2,
                                   drop_contents IN BOOLEAN := FALSE,
                                   gowner        IN VARCHAR2 := 'PUBLIC');
  -- Drop the given snapshot repgroup and optionally all of its contents
  -- at this materialized view site.
  --
  -- Arguments:
  --   gname: name of the replicated object group to be dropped
  --   drop_contents: (see comment above)
  --   gowner: owner of the replicated object group
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   missingrepgroup: the replicated object group does not exist
  ----------------------------------------------------------------------------
  PROCEDURE drop_snapshot_repobject(sname        IN VARCHAR2,
                                    oname        IN VARCHAR2, 
                                    type         IN VARCHAR2, 
                                    drop_objects IN BOOLEAN := FALSE);
  -- Remove the given object name from the local replication catalog
  -- and optionally drop the object and dependent objects.
  -- 
  -- Exceptions:
  --   nonmview if the invocation site is not a materialized view site.
  --   missingobject if the given object does not exist.
  --   typefailure if the given type parameter is not supported.
  ----------------------------------------------------------------------------
  PROCEDURE drop_snapshot_repschema(sname         IN VARCHAR2,
                                    drop_contents IN BOOLEAN := FALSE);
  -- OBSOLETE PROCEDURE: use drop_snapshot_repgroup()
  -- Drop the given snapshot repschema and optionally all of its contents
  -- at this materialized view site. In addition, the schema must also exist locally 
  -- as a database schema.
  -- 
  -- Exceptions:
  --   nonmview if the invocation site is not a materialized view site.
  ----------------------------------------------------------------------------
  PROCEDURE generate_snapshot_support(sname             IN VARCHAR2,
                                      oname             IN VARCHAR2,
                                      type              IN VARCHAR2,
                                      gen_objs_owner    IN VARCHAR2 := '',
                                      min_communication IN BOOLEAN := TRUE,
                                      generate_80_compatible
                                                        IN BOOLEAN := TRUE);
  -- If the object exists in the replicated snapshot object group
  -- as an updatable snapshot using row/column-level replication, 
  -- create the row-level replication trigger and stored package.   
  -- 
  -- If the object exists in the replicated object group as a procedure
  -- or package (body), then generate the appropriate wrappers.
  -- 
  -- Parameter gen_objs_owner specifies the schema in which the generated
  -- replication package and wrapper should be installed. If this value is
  -- NULL, then the generated package or wrapper will be installed in the
  -- schema specified by the sname parameter.
  --
  -- If min_communication is TRUE, then the update trigger sends the new value
  -- of a column only if the update statement modifies the column.  The update
  -- trigger sends the old value of the column only if it is a key column or
  -- a column in a modified column group.
  --
  -- If generate_80_compatible is true, deferred RPC's with the TOP
  -- flavor are generated using the 8.0 protocol.
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   missingobject: if the given object does not exist as a snapshot in the
  --                  replicated objevt group awaiting row/column-level 
  --                  replication information or as a procedure or package 
  --                  (body) awaiting wrapper generation.
  --   typefailure: if the given type parameter is not supported.
  --   missingschema: if specified owner of generated objects does not exist
  --   missingremoteobject: if the master object has not yet generated
  --                        replication support.
  --   commfailure: if the master is not accessible
  ----------------------------------------------------------------------------
  PROCEDURE refresh_snapshot_repgroup(gname                 IN VARCHAR2,
                                      drop_missing_contents IN BOOLEAN 
                                        := FALSE,
                                      refresh_snapshots     IN BOOLEAN 
                                        := FALSE,
                                      refresh_other_objects IN BOOLEAN 
                                        := FALSE,
                                      gowner                IN VARCHAR2
                                        := 'PUBLIC');
  -- Refresh the RepCat views for the given repgroup and optionally drop
  -- objects no longer in the repgroup.  Consistently refresh the snapshots
  -- if refresh_snapshots is TRUE.  Refresh the other objects if
  -- refresh_other_objects is TRUE. The value in gname must be an existing
  -- snapshot object group in the local database.
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   nonmaster: if the master is no longer a master site.
  --   commfailure: if the master is not accessible.
  --   missingrepgroup: if the replicated object group does not exist
  ----------------------------------------------------------------------------
  PROCEDURE refresh_snapshot_repschema(sname                 IN VARCHAR2,
                                       drop_missing_contents IN BOOLEAN
                                         := FALSE,
                                       refresh_snapshots     IN BOOLEAN
                                         := FALSE,
                                       refresh_other_objects IN BOOLEAN
                                         := FALSE,
                                       execute_as_user       IN BOOLEAN);
  PROCEDURE refresh_snapshot_repschema(sname                 IN VARCHAR2,
                                       drop_missing_contents IN BOOLEAN
                                         := FALSE,
                                       refresh_snapshots     IN BOOLEAN
                                         := FALSE,
                                       refresh_other_objects IN BOOLEAN
                                         := FALSE);
  -- OBSOLETE PROCEDURE: use refresh_snapshot_repgroup()
  -- Refresh the RepCat views for the given repgroup and optionally drop
  -- objects no longer in the repschema.  Consistently refresh the snapshots
  -- iff refresh_snapshots is TRUE.  Refresh the other objects if
  -- refresh_other_objects is TRUE. Deferred RPCs to the master site are
  -- pushed as the current session's user if execute_as_user is TRUE
  -- The schema sname must exist as a schema in the local database
  --
  -- Exceptions:
  --   nonmview if the invocation site is not a materialized view site.
  --   nonmaster if the master is no longer a master site.
  --   commfailure if the master is not accessible.
  ----------------------------------------------------------------------------
  PROCEDURE repcat_import_check(gname  IN VARCHAR2 := '',
                                master IN BOOLEAN,
                                sname  IN VARCHAR2 := '',
                                gowner IN VARCHAR2 := 'PUBLIC');
  -- Update the object identifiers and status values in repcat$_repobject
  -- for the given repgroup, preserving object status values other than VALID.
  --
  -- Exceptions:
  --   missingschema: if the replicated object group does not exist.
  --   nonmaster: if master is TRUE and either the database is not a master or
  --              the database is not the expected database.
  --   nonmview: if master is FALSE and the database is not a materialized view site.
  --   missingobject: if a valid repobject in the schema does not exist.
  ----------------------------------------------------------------------------
  PROCEDURE repcat_import_check;
  -- Invoke repcat_import_check(gowner, gname) for each replicated object group
  --
  -- Exceptions:
  --   nonmaster if the database is not the expected database for any
  --     replicated object group.
  --   missingobject if a valid replicated object in any schema does not exist.
  ----------------------------------------------------------------------------
  PROCEDURE switch_snapshot_master(gname      IN VARCHAR2,
                                   master     IN VARCHAR2,
                                   gowner     IN VARCHAR2 := 'PUBLIC');
  -- Change the master database of the snapshot repgroup to the given
  -- database. The new database must contain a replica of the master
  -- repgroup. Each snapshot in the local repgroup will be completely
  -- refreshed from the new master the next time it is refreshed.
  -- This procedure will raise an error if any snapshot definition query 
  -- is bigger than 32K.
  --
  -- Any snapshot logs should be created at all masters to avoid future
  -- complete refreshes.
  --
  -- Arguments:
  --   gname: name of the snapshot object group
  --   master: name of the new master
  --   gowner: owner of the snapshot object group
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   nonmaster: if the given database is not a master site.
  --   commfailure: if the given database is not accessible.
  --   missingrepgroup: snapshot repgroup does not exist
  --   qrytoolong: snapshot definition query is > 32K
  --   alreadymastered: if at the local site there is another snapshot repgroup
  --     with the same group name and mastered at the old master.
  ----------------------------------------------------------------------------
  ---
  --- 
  ---
  --- #######################################################################
  --- #######################################################################
  ---                        INTERNAL PROCEDURES
  ---
  --- The following procedures provide internal functionality and should
  --- not be called directly. Invoking these procedures may corrupt your
  --- replication environment.
  ---
  --- #######################################################################
  --- #######################################################################
  PROCEDURE validate_for_local_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    gowner IN VARCHAR2 := 'PUBLIC' );

  PROCEDURE set_local_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    validate IN BOOLEAN := TRUE,
    gowner IN VARCHAR2 := 'PUBLIC' );
END dbms_repcat_sna;
/

