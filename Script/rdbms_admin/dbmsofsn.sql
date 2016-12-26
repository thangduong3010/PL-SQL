Rem
Rem $Header: dbmsofsn.sql 19-feb-2001.16:44:32 nshodhan Exp $
Rem
Rem dbmsofsn.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmsofsn.sql - Public APIs for offline instantiation of snapshots
Rem
Rem    DESCRIPTION
Rem      Public APIs for offline instantiation of snapshots.  Originally
Rem      this was in the dbmsofln.sql file
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nshodhan    02/19/01 - Bug#1650475: change snap->mview
Rem    celsbern    07/12/99 - added drop of synonym prior to compiling package 
Rem    celsbern    11/06/96 - New public APIs for dbms_offline_snapshot
Rem    celsbern    11/06/96 - Created
Rem

drop synonym dbms_offline_snapshot;

---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_offline_snapshot AS

  -------------
  -- Exceptions
  --

  badargument EXCEPTION;
    PRAGMA exception_init(badargument, -23430);
    badargument_num NUMBER := -23430;

  missingremotesnap EXCEPTION;
    PRAGMA exception_init(missingremotesnap, -23361);
    misremsnap_num NUMBER := -23361;

  missingremotemview EXCEPTION;
    PRAGMA exception_init(missingremotemview, -23361);
    misremmview_num NUMBER := -23361;

  snaptabmismatch EXCEPTION;
    PRAGMA exception_init(snaptabmismatch, -23363);
    snaptabmis_num NUMBER := -23363;

  mviewtabmismatch EXCEPTION;
    PRAGMA exception_init(mviewtabmismatch, -23363);
    mviewtabmis_num NUMBER := -23363;

  -------------
  -- PROCEDURES
  --

  -------------------------------------------------------------------------
  -- Effects:  This routine creates the snapshot named "snapshot_oname" at
  --   in schema "snapshot_sname" that is in object group "gname."
  --   The snapshot is derived from a snapshot of the same name  at
  --   the master site "master_site" located in the same schema "sname." 
  --   When this routine returns normally, the snapshot site is readied
  --   for offline importation of the snapshot tables from the master site.
  --   "storage_c" may be specified by the user for indicating storage
  --   options for snapshot creation.  "comment" will be stored with
  --   the snapshot information.
  --   Raises the following exceptions:
  --      badargument:      
  --            if "gname," "sname," "master_site," 
  --            or "snapshot_oname" is NULL or ''.
  --      dbms_repcat.missingrepgroup:
  --            if "gname" does not name an object group
  --      missingremotemview:
  --            if materialized view named "snapshot_oname" does not exist
  --            at remote master site "master_site"
  --      mviewtabmismatch:  
  --            if the base table name of the materialized view at master site
  --            and materialized view site do not match.
  --      dbms_repcat.missingschema:
  --            if "snapshot_sname" is not a schema in the object group
  --            "gname"
  --
  PROCEDURE begin_load (gname               IN VARCHAR2, 
		        sname               IN VARCHAR2,
                        master_site         IN VARCHAR2,
                        snapshot_oname      IN VARCHAR2, 
                        storage_c           IN VARCHAR2 := '',
                        comment             IN VARCHAR2 := '',
                        min_communication   IN BOOLEAN := TRUE);

  -------------------------------------------------------------------------
  --  Effects: This routine ends the instantiation of the snapshot
  --    "snapshot_oname" in schema "sname" of object group
  --    "gname."  This routine must be run at the snapshot site.
  --  Raises the following exceptions:
  --      badargument:  
  --            if "gname," "snapshot_oname," "snapshot_sname"
  --            is NULL or ''.
  --      dbms_repcat.missingrepgroup: 
  --            if "gname" does not name a valid object group.
  --      dbms_repcat.nonmview:
  --            if site executing against is not a snapshot site
  -- 
  PROCEDURE end_load (gname            IN VARCHAR2,
		      sname            IN VARCHAR2,
		      snapshot_oname   IN VARCHAR2);

end;
/
grant execute on dbms_offline_snapshot to execute_catalog_role
/
 
