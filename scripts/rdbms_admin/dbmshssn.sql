Rem
Rem $Header: dbmshssn.sql 24-may-2001.15:07:36 gviswana Exp $
Rem
Rem dbmshssn.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmshssn.sql - Heterogeneous Services SNapshots
Rem
Rem    DESCRIPTION
Rem      This is that administrative API that allows users to create, delete,
Rem      and refresh snapshots at foreign datastores through heterogeneous 
Rem      services.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem      This packages are installed by sys (connect internal).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    hasun       11/21/96 - Add fdslink to API parameter list
Rem    hasun       11/05/96 - Created
Rem

REM  ***********************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST NOT BE MODIFIED BY THE CUSTOMER.
REM  DOING SO COULD CAUSE INTERNAL ERRORS AND CORRUPTIONS IN THE RDBMS.
REM  ***********************************************************************

REM  ************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST BE CREATED UNDER SYS.
REM  ************************************************************

CREATE OR REPLACE PACKAGE dbms_heterogeneous_snapshot AS
  --- #########################################################################
  --- Create a FDS snapshot object group and register it at the local master.
  --- INPUT
  ---   gname    
  ---     The name of the new object object.
  ---   fds_link 
  ---     The database link used to access the foreign datastore.
  ---   comment  
  ---     A comment for the new object group.
  --- OUTPUT
  ---   None
  --- NOTES
  ---   * An exception will be raised if the value of fds_link does not
  ---     point to a valid foreign data store.
  PROCEDURE create_hs_snapshot_repgroup(gname    IN VARCHAR2,
                                        fds_link IN VARCHAR2,
                                        comment  IN VARCHAR2 := '');

  --- #########################################################################
  --- Create a FDS snapshot and add it to the specified object group.
  --- INPUT
  ---   gname 
  ---     The name of the object group that will contain the new
  ---     snapshot repobject. This must be a valid object group.
  ---   oname 
  ---     The name of the new snapshot repobject.
  ---   definition_query
  ---     The query that defines the contents of the snapshot.
  ---   updatable
  ---     TRUE if the snapshot can be updated, FALSE otherwise.
  ---   snapshot_type 
  ---     PRIMARY KEY -> A fast refresh is driven by the primary key values
  ---                    of the master table
  ---     ROWID       -> A fast refresh is driven by rowid values
  ---                    of the master table
  ---   refresh_method
  ---     COMPLETE -> Reinstantiate the snapshot
  ---     FAST     -> Modify only the rows in that snapshot that have changed
  ---                 since the last refresh
  ---     FORCE    -> Perform a fast refresh if possiblem. Otherwise, perform
  ---                 a complete refresh
  ---   mas_roll_seg
  ---     The rollback segment to use at the Oracle master for refresh 
  ---     operations.
  ---   use_existing_object
  ---     If TRUE, then the existing object will be registered as a snapshot
  ---     repobject. Otherwise a new snapshot will be instantiated in the 
  ---     foreign datastore.
  ---   comment
  ---     A comment for the new snapshot repobject
  ---   sname
  ---     The name of the owner of the new snapshot repobject. If the foreign
  ---     datastore does not support the notion of database object owners,
  ---     this parameter should be set to NULL.
  --- OUTPUT
  ---   None
  --- NOTES
  PROCEDURE create_hs_snapshot_repobject(gname    IN VARCHAR2,
                                 oname            IN VARCHAR2,
                                 fds_link         IN VARCHAR2,
                                 definition_query IN VARCHAR2,
                                 updatable        IN BOOLEAN,
                                 snapshot_type    IN VARCHAR2 := 'PRIMARY KEY',
                                 refresh_method   IN VARCHAR2 := 'FORCE',
                                 mas_roll_seg     IN VARCHAR2 := '',
                              use_existing_object IN BOOLEAN  := TRUE,
                                 comment          IN VARCHAR2 := '',
                                 sname            IN VARCHAR2 := '');

  --- #########################################################################
  --- Remove an FDS object group from the local master.
  --- INPUT
  ---   gname 
  ---     The name of the new object object. This must be the name
  ---     of a valid object group.
  ---   drop_contents
  ---     If FALSE then just unregister all snapshots in the object group and 
  ---     leave the snasphots intact at the foreign datastore. Otherwise 
  ---     drop each snapshot in the object group from the foreign datastore.
  --- OUTPUT
  ---   None
  --- NOTES
  PROCEDURE drop_hs_snapshot_repgroup(gname         IN VARCHAR2,
                                      fds_link      IN VARCHAR2,
                                      drop_contents IN BOOLEAN := FALSE);

  --- #########################################################################
  --- Remove the specified snapshot from the object group.
  --- INPUT
  ---   gname 
  ---     The name of the a valid object object. 
  ---   oname 
  ---     The name of a valid snapshot repobject.
  ---   drop_contents
  ---     If FALSE then just unregister the snapshot and leave the snasphot
  ---     intact at the foreign datastore. Otherwise drop the snapshot at the
  ---     foreign datastore.
  ---   sname
  ---     The name of the owner of the new snapshot repobject. If the foreign
  ---     datastore does not support the notion of database object owners,
  ---     this parameter should be set to NULL.
  --- OUTPUT
  ---   None
  --- NOTES
  PROCEDURE drop_hs_snapshot_repobject(gname         IN VARCHAR2,
                                       oname         IN VARCHAR2,
                                       fds_link      IN VARCHAR2,
                                       drop_contents IN BOOLEAN  := FALSE,
                                       sname         IN VARCHAR2 := '');
  
  --- #########################################################################
  --- Perform a consistent refresh of all FDS snapshots in the specified group.
  --- INPUT
  ---   gname 
  ---     The name of the a valid object object. 
  ---   refresh_method
  ---     This value can be used to override the default refresh method of 
  ---     each snapshot in the object group. If a value is specified then all
  ---     snapshots in the object group will be refresh by the specified 
  ---     method. If the value is NULL, the default refresh medthod of each 
  ---     snasphot will be used.
  ---     COMPLETE -> Reinstantiate the snapshot
  ---     FAST     -> Modify only the rows in that snapshot that have changed
  ---                 since the last refresh
  ---     FORCE    -> Perform a fast refresh if possiblem. Otherwise, perform
  ---                 a complete refresh
  ---   refresh_after_errors
  ---     If there are errors in the deferred transaction queue that 
  ---     originated from the FDS snasphot site, the refresh will abort by 
  ---     default. Users can override the default behavior by setting this
  ---     parameter to TRUE.
  --- OUTPUT
  ---   None
  --- NOTES
  ---   * If there are queued transactions to the master site, calling this
  ---     procedure will cause the transactions to be applied to the master
  ---     site.
  PROCEDURE refresh_hs_snapshot_repgroup(gname          IN VARCHAR2,
                                         fds_link       IN VARCHAR2,
                                         refresh_method IN VARCHAR2 := '',
                                   refresh_after_errors IN BOOLEAN  := FALSE);

  --- #########################################################################
  --- Perform a consistent refresh of the specified set of FDS snapshots.
  --- INPUT
  ---   gname 
  ---     The name of the a valid object object. 
  ---   oname
  ---     A comma-separated list of the snapshots to refresh.
  ---     For example: '[<owner1>.]<snapshot1>,...,[<ownerN>.]<snapshotN>'
  ---     For foreign datastores that do not support the notion of schemas,
  ---     the owner may be omitted. If the owner is omitted and the foreign
  ---     datastore supports schemas, the owner is set to the current connect
  ---     user.
  ---   refresh_method
  ---     A comma-separated list of the refresh method to use for each 
  ---     snapshot. This parameter is used to override the default refresh
  ---     method of each snapshot. If the value is NULL, the default refresh 
  ---     medthod of each snasphot will be used.
  ---     For example: 'COMPLETE,FORCE,FAST,...'
  ---
  ---     COMPLETE -> Reinstantiate the snapshot
  ---     FAST     -> Modify only the rows in that snapshot that have changed
  ---                 since the last refresh
  ---     FORCE    -> Perform a fast refresh if possiblem. Otherwise, perform
  ---                 a complete refresh
  ---   refresh_after_errors
  ---     If there are errors in the deferred transaction queue that 
  ---     originated from the FDS snasphot site, the refresh will abort by 
  ---     default. Users can override the default behavior by setting this
  ---     parameter to TRUE.
  --- OUTPUT
  ---   None
  --- NOTES
  ---   * If there are queued transactions to the master site, calling this
  ---     procedure will cause the transactions to be applied to the master
  ---     site.
  ---   * All of the specified snapshot must belong to the same object group.
  ---     An error will be raised otherwise.
  PROCEDURE refresh_hs_snapshot_repobject(gname      IN VARCHAR2,
                                fds_link             IN VARCHAR2,
                                snapshots            IN VARCHAR2,
                                refresh_method       IN VARCHAR2 := '',
                                refresh_after_errors IN BOOLEAN  := FALSE);
END dbms_heterogeneous_snapshot;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_heterogeneous_snapshot 
   FOR sys.dbms_heterogeneous_snapshot
/
GRANT EXECUTE ON dbms_heterogeneous_snapshot TO execute_catalog_role
/
