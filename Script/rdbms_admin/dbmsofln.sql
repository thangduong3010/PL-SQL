rem 
rem $Header: dbmsofln.sql 23-apr-96.13:53:01 ajasuja Exp $ 
rem 
Rem
Rem    NAME
Rem
Rem      dbmsofln.sql - replication offline instantiation package spec
Rem
Rem    NOTES
Rem
Rem      The procedural option is needed to use this facility.
Rem
Rem      This package is installed by sys (connect internal).
Rem
Rem      The repcat tables are defined in catrep.sql and owned by system.
Rem
Rem    DEPENDENCIES
Rem
Rem      The object generator (dbmsobjg) and the replication procedure/trigger
Rem      generator (dbmsgen) must be previously loaded.
Rem
Rem      Uses dynamic SQL (dbmssql.sql) heavily.
Rem
Rem    USAGE
Rem
Rem    MESSAGES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     celsbern   07/12/99  - added drop of synonym prior to installing packag
Rem     hasun      05/07/99  - Modify comments re:Flavors                      
Rem     jstamos    04/02/98  - add resume override                             
Rem     jstamos    03/18/98  - flavor support                                  
Rem     celsbern   11/06/96 -  Split out snapshot package.
Rem     jstamos    09/12/96 -  bug fix 398867
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     ajasuja    04/23/96 -  merge OBJ to BIG
Rem     boki       10/05/95 -  add exceptions 23361 and 23363 from repcat
Rem     boki       06/21/95 -  modify for object groups
Rem     boki       01/10/95 -  merge changes from branch 1.1.720.2
Rem     boki       01/09/95 -  merge changes from branch 1.1.710.3
Rem     adowning   12/23/94 -  merge changes from branch 1.1.720.1
Rem     boki       12/21/94 -  merge changes from branch 1.1.710.1
Rem     boki       01/06/95 -  Tech writer to add explanatory comments on use
Rem     boki       01/06/95 -  Tech writer to add more self-explanatory info
Rem     boki       12/02/94 -  Branch_for_patch
Rem     boki       12/02/94 -  Creation
Rem     boki       12/02/94 -  Creation
Rem     boki       10/28/94  -- Substantial modification of Sandeep's original
Rem                             specification.
Rem
---------------------------------------------------------------------------
drop synonym dbms_offline_og;


CREATE OR REPLACE PACKAGE dbms_offline_og AS

  -------------
  -- TYPE DEFINITIONS
  --
  TYPE SetOfSiteType IS TABLE OF VARCHAR2(256)
     INDEX BY BINARY_INTEGER;

  -------------
  -- EXCEPTIONS
  --

  badargument EXCEPTION;
    PRAGMA exception_init(badargument, -23430);
    badargument_num NUMBER := -23430;

  wrongstate EXCEPTION;
    PRAGMA exception_init(wrongstate, -23431);
    wrongstate_num NUMBER := -23431;

  sitealreadyexists EXCEPTION;
    PRAGMA exception_init(sitealreadyexists, -23432);
    sitealreadyexists_num NUMBER := -23432;

  wrongsite EXCEPTION;
    PRAGMA exception_init (wrongsite, -23433);
    wrongsite_num NUMBER := -23433;

  unknownsite EXCEPTION;
    PRAGMA exception_init (unknownsite, -23434);
    unknownsite_num NUMBER := -23434;


  -------------
  -- PROCEDURES
  --

  -------------------------------------------------------------------------
  -- Effects: This routine adds a new site "new_site" to the object group
  --   "gname."  It readies the new site for offline importation of the
  --   group's objects.  The fname parameter is reserved for internal use.
  --   Do not specify this parameter unless directed
  --   by Oracle Worldwide Customer Support.
  --   The state of the replicated object group must be
  --   QUIESCED before this routine is run; otherwise, an exception
  --   is raised. This routine must be run at the master definition site.
  --   Raises the following exceptions:
  --      badargument:
  --            if "gname" or "new_site" is NULL or ''
  --      dbms_repcat.nonmasterdef:  
  --            if the site this routine is executing at is not the
  --            master def. site.
  --      sitealreadyexists:
  --            if "new_site" is already a new master site
  --      wrongstate:
  --            if master def site is not in QUIESCED state
  --      dbms_repcat.missingrepgroup:
  --            if "gname" does not name an object group
  --      dbms_repcat.missingflavor:
  --            if "fname" does not name a published flavor
  --            for the object group
  --
  PROCEDURE begin_instantiation (gname     IN VARCHAR2,
                                 new_site  IN VARCHAR2,
                                 fname     IN VARCHAR2 := NULL);

  -------------------------------------------------------------------------
  -- Effects:  For the object group "gname" this routine resumes
  --   normal activity for all master sites except for the new site
  --   "new_site."  The state of the replicated object group at each site
  --   must be QUIESCED; otherwise, an exception is raised.  When this
  --   routine returns normally, all sites are in the NORMAL state except
  --   for the new site, which is still in the QUIESCED state.  This 
  --   routine disables propagation of the queues from all sites
  --   originally in the object group to the new site "new_site."  It
  --   is meant to prevent the pushing of the queues to the new site
  --   until the new site is instantiated.
  --   This routine must be executed at the master definition site.
  --   Raises the following exceptions:
  --      badargument:    
  --           if "gname" or "new_site" is NULL or ''
  --      dbms_repcat.nonmasterdef: 
  --           if the site this routine is executing at is not the
  --           master def. site.
  --      unknownsite: 
  --           "new_site" not known to object group
  --      wrongstate:  
  --          if master def site is not in QUIESCED state
  --      dbms_repcat.missingrepgroup:
  --          if "gname" does not name an object group
  --
  PROCEDURE resume_subset_of_masters (gname    IN VARCHAR2,
          	                      new_site IN VARCHAR2,
                                      override IN BOOLEAN := FALSE);


  -------------------------------------------------------------------------
  -- Effects: For object group "gname" this routine integrates the site
  --   "new_site" into the set of existing sites.  When the routine returns
  --   normally, all sites can communicate with each other. 
  --   This routine re-enables propagation of the queues from all sites
  --   originally in the object group to the new site "new_site." 
  --   Applications may now push the queues to the new site, now that it is
  --   instantiated.  All sites in the object group are in the NORMAL state.
  --   This routine  must be executed at the master definition site.
  --   Raises the following exceptions:
  --      badargument: 
  --            if "gname" or "new_site" is NULL or ''
  --      dbms_repcat.nonmasterdef:
  --            if the site this routine is executing at is not the
  --            master def. site.
  --      unknownsite:
  --            site "new_site" is not known to schema "sname".
  --      wrongstate:  
  --            if master def site is not in NORMAL state
  --      dbms_repcat.missingrepgroup:
  --            if "gname" does not name an object group
  --
  PROCEDURE end_instantiation (gname    IN VARCHAR2,
		               new_site In VARCHAR2);

  -------------------------------------------------------------------------
  -- Effects: Starts the instantiation or migration of the object group
  --    "gname" at site "new_site." When this routine returns normally, this
  --    site is readied for loading or migrating user-defined tables.
  --    The site must be in the QUIESCED state when this routine is
  --    invoked; otherwise an exception is raised.  It disables
  --    propagation of the queues from the site "new_site" to
  --    all sites originally in the object group.  This routine must
  --    be invoked at the site.
  --    Raises the following exceptions:
  --      badargument: 
  --            if "gname" or "site" is null or ''
  --      wrongsite:
  --            routine is not executing against site "site"
  --      unknownsite: 
  --            "site" is an unknown master site
  --      wrongstate:
  --            if this site is not in QUIESCED state
  --      dbms_recpat.missingrepgroup:
  --            if "gname" does not name an object group
  --
  PROCEDURE begin_load (gname     IN VARCHAR2,
  	                new_site  IN VARCHAR2);

  -------------------------------------------------------------------------
  --  Effects:  This routine ends the instantiation of object group
  --    "gname" at site "new_site" and resumes normal activity.  It verifies
  --    the local object group is at the given flavor.  The site
  --    must be in the NORMAL state; otherwise, an exception is raised.
  --    It re-enables propagation of the queues from the new site
  --    "new_site" to all the sites originally in the object group
  --    before the new site was added.  The object group is now ready
  --    for normal activity that, from now on, will involve the new
  --    site. The fname parameter is reserved for internal use.  
  --    Do not specify this parameter unless directed 
  --    by Oracle Worldwide Customer Support.
  --   Raises the following exceptions:
  --      badargument:    
  --           if "sname" or "new_site" is NULL or ''
  --      wrongsite: 
  --           routine is not executing against site "new_site"
  --      unknownsite:
  --           "new_site" is an unknown master site
  --      wrongstate: 
  --          if this site is not in NORMAL state
  --      dbms_repcat.missingrepgroup:
  --          if "gname" does not name an object group
  --      dbms_repcat.flavornoobject:
  --          if there is an extra column or attribute
  --      dbms_repcat.flavorcontains:
  --          if an object, column or attribute is missing
  --
  PROCEDURE end_load (gname    IN VARCHAR2,
                      new_site IN VARCHAR2,
                      fname    IN VARCHAR2 := NULL);

  -------------------------------------------------------------------------
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
  PROCEDURE begin_flavor_change (gname   IN VARCHAR2,
                                 site    IN VARCHAR2,
                                 fname   IN VARCHAR2 := NULL);
  PROCEDURE end_flavor_change (gname  IN VARCHAR2,
		               site   IN VARCHAR2);
end;
/
grant execute on dbms_offline_og to execute_catalog_role
/
