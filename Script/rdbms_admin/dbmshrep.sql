Rem
Rem $Header: dbmshrep.sql 09-aug-2002.08:09:03 sbalaram Exp $
Rem
Rem dbmshrep.sql
Rem
Rem Copyright (c) 1996, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmshrep.sql - Header (specification) of dbms_REPcat
Rem
Rem    DESCRIPTION
Rem      dbms_repcat contains procedures and functions for defining and
Rem      maintaining definitions at a master site (MASTER partition)
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem      Public interface (types, exceptions, functions and procedures) must
Rem      be preserved in splitting prvtrepc.sql and retain in dbms_repcat.
Rem      See prvtbrep.sql for its body.
Rem
Rem      DO NOT REFERENCE ANY DECLARATIONS IN DBMS_REPCAT_DECL BECAUSE
Rem      DBMSHREP.SQL IS LOADED BEFORE PRVTHDCL.PLB
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sbalaram    05/28/02  - repcat->streams migration
Rem    gviswana    05/24/01  - CREATE OR REPLACE SYNONYM
Rem    liwong      04/04/01  - remove new_global_name
Rem    nshodhan    02/19/01  - Bug#1650475: change snap->mview
Rem    celsbern    02/12/01  - removed public add_master_column API.
Rem    liwong      10/02/00  - add_master_db w/o quiesce: rollback support
Rem    rvenkate    09/29/00  - MV repcat: add type,type body,operator,indextype
Rem    celsbern    09/11/00  - changed defaulting/parameters add_master_column.
Rem    liwong      09/01/00  - add master w/o quiesce: fixes
Rem    liwong      05/26/00  - add_master_db w/o quiesce
Rem    liwong      05/19/00  - add_master_db w/o quiesce
Rem    celsbern    05/15/00  - added error message for add column
Rem    celsbern    05/09/00  - added add_master_column procedure.
Rem    elu         05/05/00  - add onlyonecol exception
Rem    celsbern    03/16/00  - added safe_table_change flag to 
Rem                            alter_master_repobject.
Rem    celsbern    02/11/00  - added generate_flavor_name function.
Rem    sbalaram    02/03/00  - Add exceptions for new error msgs for
Rem                            Multi-tier mviews
Rem    evandeve    10/08/99  - mview integration
Rem    elu         09/14/99  - modify send/compare_old_values to use l_name_arr
Rem    liwong      09/09/99  - Repl obj: add ambcolumn and objectnotallowed
Rem    liwong      08/31/99  - Repl obj: overload set_columns                  
Rem    liwong      08/25/99  - Repl Obj support                                
Rem    vvishwan    08/25/99  - Add exception nottopcolumn                      
Rem    hasun       05/06/99  - Modify comments re:Flavors                      
Rem    mimoy       01/06/99  - Add exception alreadymastered
Rem    mimoy       12/23/98  - Add exception failaltersnaprop                  
Rem    hasun       12/12/98  - Modify repcat_import_check()                    
Rem    liwong      12/10/98  - support for multiple snapgrps at same site      
Rem    avaradar    12/09/98  - support for multiple snapshot repgroups         
Rem    liwong      09/23/98  - Bug 709286: raise keysendcomp                   
Rem    jstamos     05/04/98  - add overloading for flavor routines             
Rem    jstamos     04/27/98  - change create_snapshot_repgroup comment
Rem                            change set_local_flavor comment
Rem    jstamos     04/22/98  - clean up error descriptions                     
Rem    jstamos     04/20/98  - remove delete_flavor_definition                 
Rem    jstamos     04/17/98  - add obselete and purge for flavors              
Rem    jstamos     03/30/98  - add flavor interface for Al                     
Rem    ademers     03/28/98  - Flavor support                                  
Rem    liwong      03/20/98  - Flavor support                                  
Rem    jstamos     02/19/98  - flavor support                                  
Rem    liwong      12/20/97  - internal packages                               
Rem    wesmith     12/19/97 -  Add v7 compatibility comments
Rem    jnath       12/09/97 -  bug 447304: remove ampersands
Rem    wesmith     09/15/97 -  Untrusted security model enhancements
Rem    jingliu     07/03/97 -  Modify validate and fix comments
Rem    hasun       06/05/97 -  Sync exception
Rem    hasun       06/04/97 -  Fix comments and pragma exception
Rem    sbalaram    05/29/97 -  more cleanup
Rem    sbalaram    05/09/97 -  move conflict resolution routines together
Rem    sbalaram    05/09/97 -  cleanup comments
Rem    masubram    04/28/97 -  Fix merge problems
Rem    hasun       04/23/97 -  Fix comments for switch_snapshot_master
Rem    sbalaram    04/22/97 -  NCHAR support for conf resol
Rem    masubram    04/18/97 -  added qrytoolong exception
Rem    liwong      04/18/97 -  Remove obsolete repcat procedures
Rem    liwong      04/18/97 -  Remove sname, gen_rep2_trigger, execute_as_user,
Rem                         -  master_list,master_table in APIs
Rem    masubram    04/13/97 -  use defined constants for (un)register_snapshot_
Rem    masubram    03/27/97 -  fix comments for (drop)create_snapshot_repgroup
Rem    masubram    03/13/97 -  Modify definitions for snapshot registration
Rem    celsbern    01/23/97 -  Added register_snapshot_repgroup and
Rem                            unregister_snapshot_repgroup. Missing after
Rem                            split of prvtrepc.sql.
Rem    asgoel      11/22/96 -  typo fix
Rem    asgoel      11/21/96 -  Add a number table to order_user_objects
Rem    liwong      11/18/96 -  Added removal of private synonym
Rem    celsbern    11/14/96 -  Added removal of synonym before creating package
Rem    celsbern    11/07/96 -  Interfaced exceptions with dbms_repcat_decl exce
Rem    liwong      10/24/96 -  Added comments concerning referencing 
Rem                            dbms_repca_decl
Rem    jstamos     10/16/96 -  old value omission
Rem    liwong      10/08/96 -  Preserved public types, constants, exceptions
Rem                            and variables in dbms_repcat
Rem    celsbern    10/05/96 -  Creation (from splitting prvtrepc.sql)
Rem

Rem Drop synonym created in catreps.sql
drop synonym dbms_repcat
/

CREATE OR REPLACE PACKAGE dbms_repcat AS
  -------------------------
  -- OVERVIEW
  --
  -- This package provides routines to administer and update the replication
  -- catalog and environment. An alternative would be to invent SQL DDL syntax.

  --------
  -- TYPES
  --

  --
  -- NOTE: The type varchar2s is equivalent to the type varchar2s
  --       in the package dbms_repcat_sna.  If you make changes to this
  --       version, please make the same changes to the other version.
  --       
  TYPE varchar2s IS TABLE OF VARCHAR(60) INDEX BY BINARY_INTEGER;

  TYPE validate_err_record IS RECORD (err_msg VARCHAR2(2000), err_num number);
  TYPE validate_err_table IS TABLE OF validate_err_record 
    INDEX BY BINARY_INTEGER; 

  ------------
  -- CONSTANTS
  --

  -- The are constants for the rep_type parameter used in snapshot group 
  -- registration
  -- These constants have to be kept in sync with those defined in 
  -- prvthdcl.sql
  reg_unknown	        CONSTANT NUMBER := 0;
  reg_v7_group          CONSTANT NUMBER := 1;
  reg_v8_group          CONSTANT NUMBER := 2;
  reg_repapi_group      CONSTANT NUMBER := 3;  

  -- constants for conflict resolution result enumeration type
  --  
  -- These constants must be kept in sync with the macros in
  -- knip.h
  --
  resolved_false        CONSTANT NUMBER := 1; -- fail to resolve
  resolved_error        CONSTANT NUMBER := 2; -- similar to raise exception
  resolved_ignore       CONSTANT NUMBER := 3; -- ignore the remote rpc
  resolved_proceed      CONSTANT NUMBER := 4; -- possibly using changed values

  -------------
  -- EXCEPTIONS
  --
  -- These exceptions must be kept in sync with those defined in 
  -- prvthdcl.sql

  missingschema EXCEPTION;
    PRAGMA exception_init(missingschema, -23306);
    missschema_num NUMBER := -23306;

  duplicateschema EXCEPTION;
    PRAGMA exception_init(duplicateschema, -23307);
    duplschema_num NUMBER := -23307;

  missingobject EXCEPTION;
    PRAGMA exception_init(missingobject, -23308);
    missobj_num NUMBER := -23308;

  duplicateobject EXCEPTION;
    PRAGMA exception_init(duplicateobject, -23309);
    duplobj_num NUMBER := -23309;

  notquiesced EXCEPTION;
    PRAGMA exception_init(notquiesced, -23310);
    notquiesced_num NUMBER := -23310;

  notnormal EXCEPTION;
    PRAGMA exception_init(notnormal, -23326);
    notnormal_num NUMBER := -23326;

  nonmasterdef EXCEPTION;
    PRAGMA exception_init(nonmasterdef, -23312);
    nonmasterdef_num NUMBER := -23312;

  nonmaster EXCEPTION;
    PRAGMA exception_init(nonmaster, -23313);
    nonmaster_num NUMBER := -23313;

  nonsnapshot EXCEPTION;
    PRAGMA exception_init(nonsnapshot, -23314);
    nonsnapshot_num NUMBER := -23314;

  nonmview EXCEPTION;
    PRAGMA exception_init(nonmview, -23314);
    nonmview_num NUMBER := -23314;

  version EXCEPTION;
    PRAGMA exception_init(version, -23315);
    version_num NUMBER := -23315;

  reconfigerror EXCEPTION;
    PRAGMA exception_init(reconfigerror, -23316);
    reconfig_num NUMBER := -23316;

  commfailure EXCEPTION;
    PRAGMA exception_init(commfailure, -23317);
    commfail_num NUMBER := -23317;

  ddlfailure EXCEPTION;
    PRAGMA exception_init(ddlfailure, -23318);
    ddlfail_num NUMBER := -23318;

  typefailure EXCEPTION;
    PRAGMA exception_init(typefailure, -23319);
    typefail_num NUMBER := -23319;

  corrupt EXCEPTION;
    PRAGMA exception_init(corrupt, -23320);
    corrupt_num NUMBER := -23320;

  badsnapname EXCEPTION;
    PRAGMA exception_init(badsnapname, -23328);
    badsnapname_num NUMBER := -23328;

  badmviewname EXCEPTION;
    PRAGMA exception_init(badmviewname, -23328);
    badmviewname_num NUMBER := -23328;

  badsnapddl EXCEPTION;
    PRAGMA exception_init(badsnapddl, -23329);
    badsnapddl_num NUMBER := -23329;

  badmviewddl EXCEPTION;
    PRAGMA exception_init(badmviewddl, -23329);
    badmviewddl_num NUMBER := -23329;

  fullqueue EXCEPTION;
    PRAGMA exception_init(fullqueue, -23353);
    fullqueue_num NUMBER := -23353;

  misssnapobject EXCEPTION;
    PRAGMA exception_init(misssnapobject, -23355);
    misssnapobj_num NUMBER := -23355;

  missmviewobject EXCEPTION;
    PRAGMA exception_init(missmviewobject, -23355);
    missmviewobj_num NUMBER := -23355;

  masternotremoved EXCEPTION;
    PRAGMA exception_init(masternotremoved,-23356);
    mstrntrmvd_num NUMBER := -23356;

  invalidqualifier EXCEPTION;
    PRAGMA exception_init(invalidqualifier,-23378);
    invldqual_num NUMBER := -23378;

  qualifiertoolong EXCEPTION;
    PRAGMA exception_init(qualifiertoolong,-23379);
    qualtoolong_num NUMBER := -23379;

  invalidpropmode EXCEPTION;
    PRAGMA exception_init(invalidpropmode,-23380);
    invldpmode_num NUMBER := -23380;

  missingremoteobject EXCEPTION;
    PRAGMA exception_init(missingremoteobject, -23381);
    missrmtobj_num NUMBER := -23381;

  invalidremoteuser EXCEPTION;
    PRAGMA exception_init(invalidremoteuser, -23358);
    invalidremoteuser_num NUMBER := -23358;

  addrepddlerror EXCEPTION;
    PRAGMA exception_init(addrepddlerror, -23359);
    addrepddlerror_num NUMBER := -23359;
 
  failaltersnaprop EXCEPTION;
    PRAGMA exception_init(failaltersnaprop, -23477);
    failaltersnaprop_num NUMBER := -23477;
 
  failaltermviewrop EXCEPTION;
    PRAGMA exception_init(failaltermviewrop, -23477);
    failaltermviewrop_num NUMBER := -23477;

  alreadymastered EXCEPTION;
    PRAGMA exception_init(alreadymastered, -23478);
    alreadymastered_num NUMBER := -23478;

  -----
  -- Conflict Resolution exceptions
  -----

  paramtype EXCEPTION;
    PRAGMA exception_init(paramtype, -23325);
    paramtype_num NUMBER := -23325;

  duplicategroup EXCEPTION;
    PRAGMA exception_init(duplicategroup, -23330);
    dupgrp_num NUMBER := -23330;
   
  missinggroup EXCEPTION;
    PRAGMA exception_init(missinggroup, -23331);
    missgrp_num NUMBER := -23331;
   
  referenced EXCEPTION;
    PRAGMA exception_init(referenced, -23332);
    ref_num NUMBER := -23332;
  
  duplicatecolumn EXCEPTION;
    PRAGMA exception_init(duplicatecolumn, -23333);
    dupcol_num NUMBER := -23333;
  
  missingcolumn EXCEPTION;
    PRAGMA exception_init(missingcolumn, -23334);
    misscol_num NUMBER := -23334;
   
  duplicateprioritygroup EXCEPTION;
    PRAGMA exception_init(duplicateprioritygroup, -23335);
    duppriorgrp_num NUMBER := -23335;
   
  missingprioritygroup EXCEPTION;
    PRAGMA exception_init(missingprioritygroup, -23336);
    misspriorgrp_num NUMBER := -23336;
  
  missingvalue EXCEPTION;
    PRAGMA exception_init(missingvalue, -23337);
    missval_num NUMBER := -23337;
  
  duplicatevalue EXCEPTION;
    PRAGMA exception_init(duplicatevalue, -23338);
    dupval_num NUMBER := -23338;
  
  duplicateresolution EXCEPTION;
    PRAGMA exception_init(duplicateresolution, -23339);
    dupres_num NUMBER := -23339;
   
  invalidmethod EXCEPTION;
    PRAGMA exception_init(invalidmethod, -23340);
    badmeth_num NUMBER := -23340;
   
  missingfunction EXCEPTION;
    PRAGMA exception_init(missingfunction, -23341);
    missfunc_num NUMBER := -23341;
   
  invalidparameter EXCEPTION;
    PRAGMA exception_init(invalidparameter, -23342);
    badparam_num NUMBER := -23342;
   
  missingresolution EXCEPTION;
    PRAGMA exception_init(missingresolution, -23343);
    missres_num NUMBER := -23343;
  
  missingconstraint EXCEPTION;
    PRAGMA exception_init(missingconstraint, -23344);
    missconst_num NUMBER := -23344;

  statnotreg  EXCEPTION;
    PRAGMA exception_init(statnotreg, -23345);
    statnotreg_num NUMBER := -23345;

  onlyonesnap EXCEPTION;
    PRAGMA exception_init(onlyonesnap, -23360);
    onlyonesnap_num NUMBER := -23360;

  onlyonemview EXCEPTION;
    PRAGMA exception_init(onlyonemview, -23360);
    onlyonemview_num NUMBER := -23360;

  keysendcomp EXCEPTION;
    PRAGMA exception_init(keysendcomp, -23475);
    keysendcomp_num NUMBER := -23475;

  onlyonecol EXCEPTION;
    PRAGMA exception_init(onlyonecol, -23485);
    onlyonecol_num NUMBER := -23485;

  -----
  -- Product factoring exceptions
  -----

  norepoption EXCEPTION;
    PRAGMA exception_init(norepoption, -23364);
    norepoption_num NUMBER := -23364;

  ------
  --- Object Group exceptions
  ------

  missingrepgroup EXCEPTION;
    PRAGMA exception_init(missingrepgroup, -23373);
    missrepgrp_num NUMBER := -23373;

  duplicaterepgroup EXCEPTION;
    PRAGMA exception_init(duplicaterepgroup, -23374);
    duplrepgrp_num NUMBER := -23374;

  dbnotcompatible EXCEPTION;
    PRAGMA exception_init(dbnotcompatible, -23375);
    notcompat_num NUMBER := -23375;

  repnotcompatible EXCEPTION;
    PRAGMA exception_init(repnotcompatible, -23376);
    repcompat_num NUMBER := -23376;

  ------
  --- Materialized View Repgroup Registration
  ------

  unregsnaprepgroup EXCEPTION;
    PRAGMA exception_init(unregsnaprepgroup, -23382);
    unreggrp_num NUMBER := -23382;

  unregmviewrepgroup EXCEPTION;
    PRAGMA exception_init(unregmviewrepgroup, -23382);
    unreggrpmv_num NUMBER := -23382;

  failregsnaprepgroup EXCEPTION;
    PRAGMA exception_init(failregsnaprepgroup, -23383);
    failreggrp_num NUMBER := -23383;

  failregmviewrepgroup EXCEPTION;
    PRAGMA exception_init(failregmviewrepgroup, -23383);
    failreggrpmv_num NUMBER := -23383;

  ------
  --- V8 exceptions
  ------

  qrytoolong EXCEPTION;
    PRAGMA exception_init(qrytoolong, -23389);
    qrytoolong_num NUMBER := -23389;
 
  misssna EXCEPTION;
    PRAGMA exception_init(misssna, -23392);
    misssna_num NUMBER := -23392;
 
  missmview EXCEPTION;
    PRAGMA exception_init(missmview, -23392);
    missmview_num NUMBER := -23392;

  incorrectobjtype EXCEPTION;
    PRAGMA exception_init(incorrectobjtype, -23395);
    incorrectobjtype_num NUMBER := -23395;
    
  missingdblink EXCEPTION;
    PRAGMA exception_init(missingdblink, -23396);
    missingdblink_num NUMBER := -23396;
    
  dblinkmismatch EXCEPTION;
    PRAGMA exception_init(dblinkmismatch, -23397);
    dblinkmismatch_num NUMBER := -23397;
    
  dblinkuidmismatch EXCEPTION;
    PRAGMA exception_init(dblinkuidmismatch, -23398);
    dblinkuidmismatch_num NUMBER := -23398;
    
  objectnotgenerated EXCEPTION;
    PRAGMA exception_init(objectnotgenerated, -23399);
    objectnotgenerated_num NUMBER := -23399;
    
  opnotsupported EXCEPTION;
    PRAGMA exception_init(opnotsupported, -23408);
    opnotsupported_num NUMBER := -23408;

  notallgenerated EXCEPTION;
    PRAGMA exception_init(notallgenerated, -23419);
    notallgenerated_num NUMBER := -23419;

  updlobnotsupported EXCEPTION;
    PRAGMA exception_init(updlobnotsupported, -23435);
    updlobnotsupported_num NUMBER := -23435;

  flavorduplicateobj EXCEPTION;
    PRAGMA exception_init(flavorduplicateobj, -23450);
    flavorduplicateobj_num NUMBER := -23450;

  duplicateflavor EXCEPTION;
    PRAGMA exception_init(duplicateflavor, -23451);
    duplicateflavor_num NUMBER := -23451;

  flavorpublished EXCEPTION;
    PRAGMA exception_init(flavorpublished, -23452);
    flavorpublished_num NUMBER := -23452;

  topflavor EXCEPTION;
    PRAGMA exception_init(topflavor, -23453);
    topflavor_num NUMBER := -23453;

  missingflavor EXCEPTION;
    PRAGMA exception_init(missingflavor, -23454);
    missingflavor_num NUMBER := -23454;

  flavorobject EXCEPTION;
    PRAGMA exception_init(flavorobject, -23455);
    flavorobject_num NUMBER := -23455;

  flavornoobject EXCEPTION;
    PRAGMA exception_init(flavornoobject, -23456);
    flavornoobject_num NUMBER := -23456;

  flavorbad EXCEPTION;
    PRAGMA exception_init(flavorbad, -23458);
    flavorbad_num NUMBER := -23458;

  flavorcontains EXCEPTION;
    PRAGMA exception_init(flavorcontains, -23459);
    flavorcontains_num NUMBER := -23459;

  flavorinuse EXCEPTION;
    PRAGMA exception_init(flavorinuse, -23462);
    flavorinuse_num NUMBER := -23462;

  flavorbadshape EXCEPTION;
    PRAGMA exception_init(flavorbadshape, -23463);
    flavorbadshape_num NUMBER := -23463;

  flavormissingcol EXCEPTION;
    PRAGMA exception_init(flavormissingcol, -23464);
    flavormissingcol_num NUMBER := -23464;

  flavorduplicatecol EXCEPTION;
    PRAGMA exception_init(flavorduplicatecol, -23465);
    flavorduplicatecol_num NUMBER := -23465;

  flavorobjrequired EXCEPTION;
    PRAGMA exception_init(flavorobjrequired, -23466);
    flavorobjrequired_num NUMBER := -23466;

  flavormissingobj EXCEPTION;
    PRAGMA exception_init(flavormissingobj, -23467);
    flavormissingobj_num NUMBER := -23467;

  ------
  --- Objects Replication exceptions
  ------
  nottopcolumn EXCEPTION;
    PRAGMA exception_init(nottopcolumn, -23480);
    nottopcolumn_num NUMBER := -23480;

  invalidnamestr EXCEPTION;
    PRAGMA exception_init(invalidnamestr, -23481);
    invalidnamestr_num NUMBER := -23481;
 
  adtcolumn EXCEPTION;
    PRAGMA exception_init(adtcolumn, -23482);
    adtcolumn_num NUMBER := -23482;

  objectnotallowed EXCEPTION;
    PRAGMA exception_init(objectnotallowed, -23483);
    objectnotallowed_num NUMBER := -23483;
  
  ------
  --- Multi-tier mview exceptions
  ------
  nonmasterrepgrp EXCEPTION;
    PRAGMA exception_init(nonmasterrepgrp, -23500);
    nonmasterrepgrp_num NUMBER := -23500;

  reftmplinvalidcompat EXCEPTION;
    PRAGMA exception_init(reftmplinvalidcompat, -23501);
    reftmplinvalidcompat_num NUMBER := -23501;

  -------
  -- Reduce Quiesce exceptions
  -------
  rqduplcolumn EXCEPTION;
    pragma exception_init(rqduplcolumn, -23504);
    rqduplcolumn_num NUMBER := -23504;  

  ------
  --- add_master_db w/o quiesce exceptions
  ------
  notsamecq EXCEPTION; -- not having same connection qualifier
    PRAGMA exception_init(notsamecq, -23487);
    notsamecq_num NUMBER := -23487;

  propmodenotallowed EXCEPTION; -- propagation mode is not allowed for this op
    PRAGMA exception_init(propmodenotallowed, -23488);
    propmodenotallowed_num NUMBER := -23488;

  dupentry EXCEPTION; -- duplicated entry
    PRAGMA exception_init(dupentry, -23489);
    dupentry_num NUMBER := -23489;

  extstinapp EXCEPTION; -- extension status is inappropriate
    PRAGMA exception_init(extstinapp, -23490);
    extstinapp_num NUMBER := -23490;

  novalidextreq EXCEPTION; -- no valid extension request
    PRAGMA exception_init(novalidextreq, -23491);
    novalidextreq_num NUMBER := -23491;

  nonewsites EXCEPTION; -- no new sites for extension request
    PRAGMA exception_init(nonewsites, -23492);
    nonewsites_num NUMBER := -23492;

  notanewsite EXCEPTION; -- not a new site for extension request
    PRAGMA exception_init(notanewsite, -23493);
    notanewsite_num NUMBER := -23493;

  toomanydes EXCEPTION; -- too many rows for destination.
    PRAGMA exception_init(toomanydes, -23494);
    toomanydes_num NUMBER := -23494;

  -------------
  -- VARIABLES
  --

  err_table dbms_repcat.validate_err_table;

  ---------------------------------------------------------------------------
  --
  -- MASTER REPLICATION PROCEDURES
  --
  -- The following procedure are used to create and manage master replication
  -- sites.
  --
  ---------------------------------------------------------------------------
  PROCEDURE register_mview_repgroup(gname    IN VARCHAR2, 
                                    mviewsite IN VARCHAR2, 
                                    comment  IN VARCHAR2 := NULL,
                                    rep_type IN NUMBER   := reg_unknown,
                                    fname    IN VARCHAR2 := NULL,
                                    gowner   IN VARCHAR2 := 'PUBLIC');

  -- This procedure is used at master sites to manually register
  -- a materialized view repgroup. 
  --
  -- Arguments:
  --   gname: Name of the repgroup
  --   snapsite: Site of the materialized view repgroup
  --   comment: comment describing the materialized view repgroup
  --   rep_type: Version and type of the materialized view group (valid 
  --     constants are defined in dbms_repcat package header)
  --   fname: This parameter is reserved for internal use.  
  --          Do not specify this parameter unless directed 
  --          by Oracle Worldwide Customer Support.
  --   gowner: owner of the materialized view repgroup
  --
  -- Exceptions:
  --   failregmviewrepgroup: registration failed
  --   missingrepgroup: given repgroup does not exist
  --   nonmaster: given repgroup is not mastered at the master site
  --   duplicaterepgroup: repgroup is already registered
  ---------------------------------------------------------------------------
  PROCEDURE unregister_mview_repgroup(gname    IN VARCHAR2, 
                                      mviewsite IN VARCHAR2,
                                      gowner   IN VARCHAR2 := 'PUBLIC');
  -- This procedure is used at master sites to manually unregister
  -- a materialized view repgroup. 
  --
  -- Arguments:
  --   gname: Name of the repgroup
  --   snapsite: Site of the materialized view repgroup
  --   gowner: owner of the repgroup
  --
  -- Exceptions:
  --   unregmviewrepgroup: materialized view repgroup is not registered
  ---------------------------------------------------------------------------
  PROCEDURE add_master_database(gname                IN VARCHAR2,
                                master               IN VARCHAR2, 
                                use_existing_objects IN BOOLEAN := TRUE,
                                copy_rows            IN BOOLEAN := TRUE,
                                comment              IN VARCHAR2 := '',
                                propagation_mode     IN VARCHAR2
                                                           := 'ASYNCHRONOUS',
                                fname                IN VARCHAR2 := NULL);
  -- Adds the given master site to the given repgroup. This must be called
  -- at the master definition site. All master repgroup replicas must have
  -- been quiesced with an earlier call to suspend_master_activity.
  --
  -- The new master database is initialized with a consistent copy of all of
  -- the contents of the repgroup at the master definition site. If a
  -- replicated object does not exist at the new master, it is created at the
  -- new master.  If copy_rows is TRUE, then it copies any contents from the
  -- masterdef site.
  -- 
  -- If a replicated object already exists at the new master, the situation
  -- is more complicated.  If use_existing_objects is FALSE, or if the
  -- object has the wrong type or "shape," the name conflict is recorded.
  -- On the contrary, if the object has the right name, type, and "shape,"
  -- and if use_existing_objects is TRUE, the object is reused.
  -- If copy_rows is TRUE, the contents of the two objects are compared
  -- piece by piece, and any discrepancies are rectified by using the
  -- contents of the masterdef's object.  A probabilistic comparison
  -- algorithm (such as one based on a checksum) may be used.  Such an
  -- algorithm never states that two objects with identical contents are
  -- different.
  -- 
  -- If prop_mode is "ASYNCHRONOUS", then the new site's repgroup propagation 
  -- mode will be asynchronous to all other masters, and all other masters
  -- will be asynchronous to it. If prop_mode is "SYNCHRONOUS", then the new
  -- site's repgroup propagation mode will be synchronous to all other masters,
  -- and all other masters will be synchronous to it.
  --
  -- The fname parameter is reserved for internal use.
  -- Do not specify this parameter unless directed 
  -- by Oracle Worldwide Customer Support.
  --
  -- Because this procedure may use asynchronous activities, interim status
  -- and all asynchronous errors are recorded in the RepCatlog. If the
  -- request completes successfully, the new master is added to all
  -- RepSites views, and no mention of the request appears in the RepCatlog.
  -- 
  -- Arguments:
  --   gname: name of the object group being replicated
  --   master: name of the new master being added to the replicated environment
  --   use_existing_objects: (see comment above)
  --   copy_rows: (see comment above)
  --   comment: comment added to the master_comment field of RepSites view
  --   propagation_mode: method of forwarding and receiving changes from
  --          the new master
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site for
  --     the given replicated object group
  --   notquiesced: if the replicated object group has not been suspended.
  --   commfailure: if the new master is not accessible.
  --   typefailure: incorrect propagation mode specified
  --   notcompat: new master must have compatibility 7.3 or greater
  --   duplicaterepgroup: object group already exists, master is already
  --     part of this replicatd environment
  --   missingobject: a member of the replicated object group does not
  --     exist at the masterdef site with a status of VALID
  ---------------------------------------------------------------------------
  PROCEDURE alter_master_propagation(gname        IN VARCHAR2,
                                     master       IN VARCHAR2,
                                     dblink_table IN dbms_utility.dblink_array,
                                     propagation_mode IN VARCHAR2 := 
                                                  'ASYNCHRONOUS',
                                     comment      IN VARCHAR2 := '');

  PROCEDURE alter_master_propagation(gname        IN VARCHAR2,
                                     master       IN VARCHAR2,
                                     dblink_list  IN VARCHAR2,
                                     propagation_mode IN VARCHAR2 := 
                                                  'ASYNCHRONOUS',
                                     comment      IN VARCHAR2 := '');

  --  This call modifies the propagation method for the given object group
  --  at the given master site for the destinations specified by the list
  --  of dblinks. This must be called at the masterdef and requires the object
  --  group to be quiesced.
  -- 
  -- Arguments:
  --   gname: object group that is having its propagation mode altered
  --   master: master at which to alter the propagation mode
  --   dblink_table/dblink_list: PL/SQL table or list of dblinks for which
  --     to alter propagation
  --   propagation_mode: can be SYNCHRONOUS or ASYNCHRONOUS
  --   comment: comment added to the repprop view
  --
  -- Exceptions: 
  --   nonmasterdef: if local site is not the masterdef site
  --   notquiesced: if given object group is not quiesced
  --   typefailure: an unknown propagation type was specified
  --   nonmaster: given site is not a master site for the given object group
  --      or the list of dblinks contains a site which is not a master site
  --      for the given object group.
  ---------------------------------------------------------------------------
  PROCEDURE alter_master_repobject(sname    IN VARCHAR2,
                                   oname    IN VARCHAR2, 
                                   type     IN VARCHAR2,
                                   ddl_text IN VARCHAR2,
                                   comment  IN VARCHAR2 := '',
                                   retry    IN BOOLEAN  := FALSE,
                                   safe_table_change in BOOLEAN := FALSE);

  -- This applies DDL changes to a replicated object at the masterdef site
  -- and the changes are synchronously multicast to all the master sites.
  -- Each master asynchronously checks that the object exists locally and
  -- then applies the DDL to its replica. If comment is not NULL, then each
  -- altered object's comment is updated. If retry is TRUE,
  -- alter_master_repobject alters the object only at masters whose object
  -- status is not 'valid'. The RepCatlog contains interim status and any
  -- asynchronous error messages generated by the request. This requires the
  -- object group be quiesced with suspend_master_activity.
  -- 
  -- Local customization of individual replicas is outside the
  -- scope of RepCat.  Replication administrators should ensure that local
  -- customizations do not interfere with the global customizations done
  -- with alter_master_repobject. 
  -- 
  -- Arguments:
  --   sname: schema containing the replicated object
  --   oname: the replicated object
  --   type: type of object (TABLE, INDEX, SYNONYM, TRIGGER, VIEW, PROCEDURE,
  --     FUNCTION, PACKAGE or PACKAGE BODY)
  --   ddl_text: ddl text used to alter the object
  --   comment: comment to be added to the RepObject view
  --   retry: (see comment above)
  --   safe_table_change: when true and used with type TABLE objects, 
  --     indicates that change is safe to do without quiesce.
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the replicated object group has not been suspended.
  --   missingobject: if the given object does not exist.
  --   typefailure: if the given type parameter is not supported.
  --   ddlfailure: if any DDL at the masterdef does not succeed.
  --   commfailure: if a master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_repgroup(gname   IN VARCHAR2,
                                comment IN VARCHAR2);
  -- Update the comment field for the given repgroup in RepCat view.
  --
  -- in 8.1, this procedure is always executed at master sites, no need
  -- to include gowner
  --
  -- Arguments:
  --   gname: name of object group to comment on
  --   comment: updated comment
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   commfailure: if any master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_repobject(sname   IN VARCHAR2,
                                 oname   IN VARCHAR2,
                                 type    IN VARCHAR2,
                                 comment IN VARCHAR2);
  -- Update the comment field for the given repobject in RepObject view.
  --
  -- Arguments:
  --   sname: name od schema containing the object
  --   oname: name of replicated object to comment on
  --   type: type of object (TABLE, INDEX, SYNONYM, TRIGGER, VIEW, PROCEDURE,
  --     FUNCTION, PACKAGE or PACKAGE BODY)
  --   comment: updated comment
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist.
  --   typefailure: if the given type parameter is not supported.
  --   commfailure: if any master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_repsites(gname   IN VARCHAR2,
                                master  IN VARCHAR,
                                comment IN VARCHAR2);
  -- Update the comment field for the given master in RepGroup view
  -- The group name must be registered locally as a replicated 
  -- master object group. Must be issued from a masterdef site.
  --
  -- Arguments:
  --   gname: name of the object group
  --   master: master site that you want to comment on
  --   comment: updated comment
  --
  -- Exceptions:
  --   missingrepgroup: object group does not exist
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   nonmaster: if the given master is not a master.
  --   commfailure: if any master is not accessible.
  --   corrupt: inconsistency in repcat views.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_repsites(gname   IN VARCHAR2,
                                comment IN VARCHAR2);
  -- Update the comment field for the given materialized view object group.
  -- The group name must be registered locally as a replicated 
  -- materialized view object group. Must be issued from a materialized view 
  -- site.
  --
  -- Arguments:
  --   gname: name of object group
  --   comment: updated comment
  --
  -- Exceptions:
  --   missingrepgroup: if the object group does not exist
  --   nonmview: if the invocation site is not a materialized view site.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_mview_repsites(gowner  IN VARCHAR2,
                                      gname   IN VARCHAR2,
                                      comment IN VARCHAR2);
  -- Update the comment field for the given materialized view object group.
  -- The group name must be registered locally as a replicated 
  -- materialized view object group. Must be issued from a materialized view 
  -- site.
  --
  -- Arguments:
  --   gowner: owner of the object group
  --   gname: name of object group
  --   comment: updated comment
  --
  -- Exceptions:
  --   missingrepgroup: if the object group does not exist
  --   nonmview: if the invocation site is not a materialized view site.
  ---------------------------------------------------------------------------
  PROCEDURE create_master_repgroup(gname          IN VARCHAR2,
                                   group_comment  IN VARCHAR2 := '',
                                   master_comment IN VARCHAR2 := '',
                                   qualifier      IN VARCHAR2 := '');
  -- Create a new, empty, quiesced master repgroup, making the local database
  -- the first replica and the masterdef. 
  --
  -- Arguments:
  --   gname: name of the object group to be created
  --   group_comment: comment added in the RepCat view
  --   master_comment: comment added in the RepSites view
  --   qualifier: connection qualifier for object group
  --
  -- Exceptions:
  --   duplicaterepgroup: if the object group already exists as a repgroup.
  --   norepopt: advanced replication option not installed
  --   missingrepgrp: object group name not specified
  --   qualifiertoolong: connection qualifier too long (the maximum length
  --     of a database link including connection qualifier is 128 bytes)
  ---------------------------------------------------------------------------
  PROCEDURE create_master_repobject(sname               IN VARCHAR2,
                                    oname               IN VARCHAR2,
                                    type                IN VARCHAR2,
                                    use_existing_object IN BOOLEAN := TRUE,
                                    ddl_text            IN VARCHAR2 := NULL,
                                    comment             IN VARCHAR2 := '',
                                    retry               IN BOOLEAN := FALSE,
                                    copy_rows           IN BOOLEAN := TRUE,
                                    gname               IN VARCHAR2 := '');
  -- This adds an object of the given name and type to the replicated
  -- object group. This operates in an asynchronous fashion, and requires
  -- that the replicated object group be quiesced with suspend_master_activity.
  --
  -- It optionally uses the given DDL text to create the object at the
  -- masterdef site. If no DDL text is provided, the object must already
  -- exist at the masterdef site. If retry is TRUE, it creates the object
  -- only at masters whose object status is not 'valid'.
  -- 
  -- If the object does not exist at a non-masterdef site, the object is
  -- is created at that site. If copy_rows is TRUE, it then copies any
  -- contents from the masterdef site.
  -- 
  -- If the object already exists at a non-masterdef site, the situation is
  -- more complicated.  If use_existing_object is FALSE, or if the object has
  -- the wrong type or "shape," a duplicateobject exception is stored in the
  -- RepCatlog. On the contrary, if the object has the right name, type,
  -- and "shape," and if use_existing_object is TRUE, the object is reused.
  -- If copy_rows is TRUE, the contents of the two objects are
  -- (probabilistically) compared piece by piece and any discrepancies are
  -- rectified by using the contents of the masterdef's object.
  -- 
  -- The RepCatlog contains interim status and any asynchronous error
  -- messages generated by the request.
  -- 
  -- Arguments:
  --   sname: name of schema containing object to be replicated
  --   oname: name of the object to be replicated
  --   type: type of object (TABLE, INDEX, SYNONYM, TRIGGER, VIEW, PROCEDURE,
  --     FUNCTION, PACKAGE or PACKAGE BODY)
  --   use_existing_object: (see comment above)
  --   ddl_text: (see comment above)
  --   comment: comment added to the object_comment field of RepObject view
  --   retry: 
  --   copy_rows: (see comment above)
  --   gname: name of the object group in which to create the replicated object
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the replicated object group has not been suspended.
  --   duplicateobject: if the given object already exists in the repgroup
  --     and retry is FALSE, or if a name conflict occurs.
  --   missingobject: if the given object does not exist and no DDL text is
  --     given, or if oname directly or indirectly refers to a remote object.
  --   typefailure: if objects of the given type can not be replicated.
  --   ddlfailure: if any DDL at the masterdef does not succeed.
  --   commfailure: if any master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE do_deferred_repcat_admin(gname     IN VARCHAR2,
                                     all_sites IN BOOLEAN := FALSE);
  -- Execute local outstanding deferred administrative procedures for the
  -- given replicated object group requested by the current user.  If all_sites
  -- is TRUE, do this at each master.
  --
  -- Arguments:
  --   gname: name of replicated object group
  --   all_sites: (see comment above)
  --
  -- Exceptions:
  --   nonmaster: if the invocation site is not a master site.
  --   commfailure: if all_sites is TRUE and a master is not accessible
  ---------------------------------------------------------------------------
  PROCEDURE drop_master_repgroup(gname         IN VARCHAR2,
                                 drop_contents IN BOOLEAN := FALSE,
                                 all_sites     IN BOOLEAN := FALSE);
  -- Drop the master repgroup and optionally all of its contents (drop_contents
  -- is TRUE). If all_sites is TRUE and the invocation site is the masterdef,
  -- synchronously multicast the request to all masters.  In this case
  -- execution is immediate at the masterdef and possibly deferred at all
  -- other master sites. Note that this procedure may leave some dangling
  -- materialized views.
  --
  -- Arguments:
  --   gname: name of the replicated object group to be dropped
  --   drop_contents: (see comment above)
  --   all_sites: (see comment above)
  --
  -- Exceptions:
  --   nonmaster: if the invocation site is not a master site.
  --   nonmasterdef: if all_sites is TRUE and the invocation site is not
  --     the masterdef site
  --   fullqueue: if the deferred RPC queue has entries for the repgroup.
  --   commfailure: if a master is not accessible and all_sites is TRUE.
  ---------------------------------------------------------------------------
  PROCEDURE drop_master_repobject(sname        IN VARCHAR2,
                                  oname        IN VARCHAR2, 
                                  type         IN VARCHAR2, 
                                  drop_objects IN BOOLEAN := FALSE);
  -- This procedure drops a replicated object from a replicated object group.
  -- This removes the given object name from the RepObject view at all sites,
  -- and optionally drops the object and dependent objects at all sites
  -- (drop_objects is TRUE). This procedure typically operates in an
  -- asynchronous fashion. The RepCatlog contains interim status and any
  -- asynchronous error messages generated by the request.
  --
  -- Arguments: 
  --   sname: name of schema containing the repobject
  --   oname: name of the replicated object to be dropped
  --   type: type of object
  --   drop_objects: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist.
  --   typefailure: if the given type parameter is not supported.
  --   commfailure: if a master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE execute_DDL(gname       IN VARCHAR2,
                        master_list IN VARCHAR2 := NULL,
                        ddl_text    IN VARCHAR2);

  PROCEDURE execute_DDL(gname        IN VARCHAR2,
                        master_table IN dbms_utility.dblink_array,
                        ddl_text     IN VARCHAR2);
  -- Executes the DDL provided in ddl_text. The DDL is applied at the given
  -- set of masters. master_list is a comma-separated list of masters.
  -- master_table is a PL/SL table of masters. If NULL, it means all masters
  -- including the masterdef. The DDL is typically applied asynchronously.
  -- The RepCatlog contains interim status and any asynchronous error messages
  -- generated by the request. Although the repgroup need not be quiesced
  -- when execute_DDL is invoked, an administrator may quiesce the group first.
  --
  -- Arguments:
  --   gname: name of replicated object group
  --   master_list/master_table: (see comment above)
  --   ddl_text: DDL to be executed at the given master sites
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   nonmaster: if any site is not a master.
  --   ddlfailure: if any DDL at the masterdef does not succeed.
  --   commfailure: if a master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE generate_replication_package(sname IN VARCHAR2,
                                         oname IN VARCHAR2);
  --- Internal packages:
  ---   This is obsolete in 8.1?
  ---
  -- This generates the $RP, $RL and conflict resolution packages
  -- for a particular object at ALL masters. The object group that contains
  -- the specified replication object must be quiesced for this operation.
  -- The RepCatLog contains interim status and any asynchronous error messages
  -- generated by the request.
  --
  -- Arguments:
  --   sname: schema containing replicated object
  --   oname: name of replicated object for which to generate replication
  --     package
  --
  -- Exceptions:
  --   nonmasterdef: invocation site is not the masterdef site
  --   missingobject: given object does not exist
  --   notquiesced: object group not quiesced
  --   notcompat: all the the masters in the replicated object group must have
  --     compatibility 73 or greater
  ---------------------------------------------------------------------------
  PROCEDURE generate_replication_support(sname             IN VARCHAR2,
                                         oname             IN VARCHAR2,
                                         type              IN VARCHAR2,
                                         package_prefix    IN VARCHAR2 := NULL,
                                         procedure_prefix  IN VARCHAR2 := NULL,
                                         distributed       IN BOOLEAN  := TRUE,
                                         gen_objs_owner    IN VARCHAR2 := NULL,
                                         min_communication IN BOOLEAN := TRUE,
                                         generate_80_compatible
                                                           IN BOOLEAN := TRUE);
  -- This generates packages and procedures needed to support replication.
  -- If the object exists in the replicated object group as a table using
  -- row/column-level replication, this procedure generates the stored package.
  -- When row-level or column-level replication is used for an object,
  -- generate_replication_support should be called immediately after all
  -- calls to set_columns.
  --
  -- If the object exists in the replicated object group as a procedure, 
  -- the procedure generates the procedure wrapper using the given procedure 
  -- prefix. If the object exists in the object group as a package (body), 
  -- this procedure generates the procedure wrappers using the given package 
  -- and procedure prefixes. In either case generate_replication_support should
  -- be called immediately after create_master_repobject or 
  -- alter_master_repobject.
  -- 
  -- The parameter gen_objs_owner specifies the schema in which the generated
  -- procedural wrapper should be installed. If this value if NULL, then 
  -- the generated procedural wrapper will be installed in the schema
  -- specified by the sname parameter.
  --
  -- If min_communication is TRUE and type is 'TABLE', then the update trigger
  -- sends the new value of a column only if the update statement modifies the
  -- column.  The update trigger sends the old value of the column only if it
  -- is a key column or a column in a modified column group. If the specified 
  -- object is a replicated table and contains BLOB, CLOB, and/or NCLOB columns
  -- the input value for this parameter will be ignored and the value is always
  -- set to TRUE.
  --
  -- If generate_80_compatible is true, deferred RPC's from sites with the TOP
  -- flavor are generated using the 8.0 protocol.
  --
  -- The RepCatLog contains interim status and any asynchronous error
  -- messages generated by the request.
  --
  -- Arguments:
  --   sname: name of schema containing the object
  --   oname: name of object
  --   type: type of object (TABLE, PACKAGE, PACKAGE BODY, PROCEDURE)
  --   package_prefix: for PACKAGE and PACKAGE BODY, prepend this to the
  --     generated wrapper package name (default is DEFER_).
  --   procedure_prefix: for PROCEDURE, prepend this to the generate
  --     wrapper procedure name (default is DEFER_).
  --   distributed: is always TRUE
  --   gen_objs_owner: (see comment above)
  --   min_communication: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist as a table in the
  --     replicated object group awaiting row/column-level replication
  --     information or as a procedure or package (body) awaiting wrapper
  --     generation.
  --   missingschema: if specified schema does not exist
  --   typefailure: if the given type parameter is not supported.
  --   notquiesced: if the replicated object group has not been suspended.
  --   commfailure: if any master is not accessible.
  --   notcompat: all the the masters in the replicated object group must have
  --     compatibility 73 or greater
  ---------------------------------------------------------------------------
  PROCEDURE purge_master_log(id     IN NATURAL,
                             source IN VARCHAR2,
                             gname  IN VARCHAR2);
  -- Removes all local log records corresponding to the request on a given
  -- replicated object group that originated at the given master with the
  -- given identification. If any parameter is NULL, treats it as a wildcard.
  --
  -- Arguments:
  --   id: id of the request
  --   source: master site from which request originated
  --   gname: name of the replicated object group
  --
  -- Exceptions:
  --   nonmaster: if sname is not NULL and the invocation site is not a
  --     master site.
  ---------------------------------------------------------------------------
  PROCEDURE relocate_masterdef(gname                 IN VARCHAR2,
                               old_masterdef         IN VARCHAR2, 
                               new_masterdef         IN VARCHAR2,
                               notify_masters        IN BOOLEAN := TRUE,
                               include_old_masterdef IN BOOLEAN := TRUE,
                               require_flavor_change IN BOOLEAN := FALSE);
  -- Move the masterdef designation from old_masterdef to new_masterdef.
  -- Old_masterdef must be the current masterdef, and new_masterdef must be
  -- a master. If notify_masters is TRUE, sychronously multicast the change
  -- to all masters (including old_masterdef only if include_old_masterdef
  -- is TRUE). If any master does not make the change, rollback the changes
  -- at all masters.
  -- 
  -- In a planned reconfiguration, relocate_masterdef should be invoked
  -- with notify_masters TRUE and include_old_masterdef TRUE. If just the
  -- masterdef fails, relocate_masterdef should be invoked with
  -- notify_masters TRUE and include_old_masterdef FALSE. If several
  -- masters and the masterdef fail, the administrator should invoke
  -- relocate_masterdef at each operational master with notify_masters FALSE.
  --
  -- The require_flavor_change is reserved for internal use. 
  -- Do not specify this parameter unless directed 
  -- by Oracle Worldwide Customer Support.
  -- 
  -- Arguments:
  --   gname: name of replicated object group
  --   old_masterdef: current masterdef site
  --   new_masterdef: name of an existing master site that is now going
  --     to be the new masterdef site
  --   notify_masters: (see comment above)
  --   include_old_masterdef: (see comment above)
  --
  -- Exceptions:
  --   nonmaster: if new_masterdef is not a master site or if the invocation
  --     site is not a master site.
  --   nonmasterdef: if old_masterdef is not the masterdef site.
  --   commfailure: if a master is not accessible and notify_masters is TRUE.
  ---------------------------------------------------------------------------
  PROCEDURE resume_master_activity(gname    IN VARCHAR2,
                                   override IN BOOLEAN  := FALSE);
  -- This resumes normal replication activity after a repgroup has been 
  -- quiesced. So the replicated object group must be quiescing or quiesced
  -- when this procedure is called. If override is TRUE, it ignores any
  -- pending RepCat administration requests and restores normal replication
  -- activity at each master as quickly as possible. If override is FALSE,
  -- it restores normal replication activity at each master only when there
  -- is no pending RepCat administration request for the object group at
  -- that master. The RepCatlog contains interim status and any asynchronous
  -- error messages generated by the request.
  --
  -- Arguments:
  --   gname: name of replicated object group
  --   override: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the status of the replicated object group is not  
  --                quiescing or quiesced.
  --   commfailure: if any master is not accessible.
  --   notallgenerated: need to generate replication support before
  --     resuming replication activity
  ---------------------------------------------------------------------------

  -- ***********************************************************************
  -- WARNING: send_and_compare_old_values must be used with extreme caution.
  -- Indiscriminate use may hide conflicts from symmetric replication.
  -- This in turn can lead to replicated data divergence.
  -- ***********************************************************************

  PROCEDURE send_and_compare_old_values(sname       IN VARCHAR2,
                                        oname       IN VARCHAR2,
                                        column_list IN VARCHAR2,
                                        operation   IN VARCHAR2 := 'UPDATE',
                                        send        IN BOOLEAN := TRUE);

  PROCEDURE send_and_compare_old_values(sname        IN VARCHAR2,
                                        oname        IN VARCHAR2,
                                        column_table IN dbms_repcat.varchar2s,
                                        operation    IN VARCHAR2 := 'UPDATE',
                                        send         IN BOOLEAN := TRUE);

  -- Determine whether or not to send and compare old column values for
  -- deletes or updates.  sname.oname must be a replicated table.
  -- column_list is a comma-separated list of columns in the table
  -- (column_table is a PL/SQL table of columns in the table)
  -- or '*' for all non-key columns.  Operation must be 'UPDATE,' 'DELETE,'
  -- or '*,' with '*' meaning both 'UPDATE' and 'DELETE'.  If send is TRUE,
  -- the old values of the specified columns are sent.  If send is FALSE,
  -- the old values of the specified columns are not sent.  Unspecified
  -- columns and unspecified operations are not affected.  The specified
  -- change takes effect at the master definition site as soon as
  -- min_communication is TRUE for the table.  The change takes effect at a
  -- master site or at a materialized view site the next time replication 
  -- support is generated at that site with min_communication TRUE.
  --
  -- Arguments:
  --   sname: schema in which table is located
  --   oname: name of the table
  --   column_list/column_table: (see comment above)
  --   operation: (see comment above)
  --   send: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the replicated object group has not been suspended.
  --   missingobject: if the given object does not exist as a replicated table.
  --   missingcolumn: if any column doesn't exist as a replicated column.
  --   typefailure: if an illegal operation is given.
  --   keysendcomp: if any column is not a non-key column in the table.
  --   dbnotcompatible: if node is not compatible with replication version.
  --   flavornoobject: if any column does not exist.
  ---------------------------------------------------------------------------

  -- ***********************************************************************
  -- WARNING: send_old_values must be used with extreme caution.
  -- Indiscriminate use may hide conflicts from symmetric replication.
  -- This in turn can lead to replicated data divergence.
  -- ***********************************************************************

  PROCEDURE send_old_values(sname       IN VARCHAR2,
                            oname       IN VARCHAR2,
                            column_list IN VARCHAR2,
                            operation   IN VARCHAR2 := 'UPDATE',
                            send        IN BOOLEAN := TRUE);

  PROCEDURE send_old_values(sname        IN VARCHAR2,
                            oname        IN VARCHAR2,
                            column_table IN dbms_repcat.varchar2s,
                            operation    IN VARCHAR2 := 'UPDATE',
                            send         IN BOOLEAN := TRUE);

  PROCEDURE send_old_values(sname        IN VARCHAR2,
                            oname        IN VARCHAR2,
                            column_table IN dbms_utility.lname_array,
                            operation    IN VARCHAR2 := 'UPDATE',
                            send         IN BOOLEAN := TRUE);

  -- Determine whether or not to send old column values for
  -- deletes or updates.  sname.oname must be a replicated table.
  -- column_list is a comma-separated list of columns in the table
  -- (column_table is a PL/SQL table of columns in the table)
  -- or '*' for all non-key columns.  Columns cannot be an object type, 
  -- including top-level and embedded object types.  Operation must be 
  -- 'UPDATE,' 'DELETE,' or '*,' with '*' meaning both 'UPDATE' and 
  -- 'DELETE'.  If send is TRUE, the old values of the specified columns 
  -- are sent.  If send is FALSE, the old values of the specified 
  -- columns are not sent.  Unspecified columns and unspecified 
  -- operations are not affected.  The specified change takes effect at 
  -- the master definition site as soon as min_communication is TRUE for 
  -- the table.  The change takes effect at a master site or at a 
  -- materialized view site the next time replication support is generated at 
  -- that site with min_communication TRUE.
  --
  -- Arguments:
  --   sname: schema in which table is located
  --   oname: name of the table
  --   column_list/column_table: (see comment above)
  --   operation: (see comment above)
  --   send: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the replicated object group has not been suspended.
  --   missingobject: if the given object does not exist as a replicated table.
  --   missingcolumn: if any column doesn't exist as a replicated column.
  --   typefailure: if an illegal operation is given.
  --   keysendcomp: if any column is not a non-key column in the table.
  --   dbnotcompatible: if node is not compatible with replication version.
  --   flavornoobject: if any column does not exist.
 ---------------------------------------------------------------------------

  -- ***********************************************************************
  -- WARNING: compare_old_values must be used with extreme caution.
  -- Indiscriminate use may hide conflicts from symmetric replication.
  -- This in turn can lead to replicated data divergence.
  -- ***********************************************************************

  PROCEDURE compare_old_values(sname       IN VARCHAR2,
                               oname       IN VARCHAR2,
                               column_list IN VARCHAR2,
                               operation   IN VARCHAR2 := 'UPDATE',
                               compare     IN BOOLEAN := TRUE);

  PROCEDURE compare_old_values(sname        IN VARCHAR2,
                               oname        IN VARCHAR2,
                               column_table IN dbms_repcat.varchar2s,
                               operation    IN VARCHAR2 := 'UPDATE',
                               compare      IN BOOLEAN := TRUE);

  PROCEDURE compare_old_values(sname        IN VARCHAR2,
                               oname        IN VARCHAR2,
                               column_table IN dbms_utility.lname_array,
                               operation    IN VARCHAR2 := 'UPDATE',
                               compare      IN BOOLEAN := TRUE);

  -- Determine whether or not to compare old column values for deletes or
  -- updates when they are sent.  sname.oname must be a replicated table.
  -- column_list is a comma-separated list of columns in the table
  -- (column_table is a PL/SQL table of columns in the table) or '*' for
  -- all non-key columns. Columns cannot be an object type, including
  --  top-level and embedded object types.  Operation must be 'UPDATE,' 
  -- 'DELETE,' or '*,' with '*' meaning both 'UPDATE' and 'DELETE'.  If 
  -- compare is TRUE, the old values of the specified columns are 
  -- compared when sent.  If compare is FALSE, the old values of the 
  -- specified columns are not compared when sent.  Unspecified columns 
  -- and unspecified operations are not affected.  The specified change 
  -- takes effect at the master definition site as soon as 
  -- min_communication is TRUE for the table.  The change takes effect 
  -- at a master site or at a materialized view site the next time replication 
  -- support is generated at that site with min_communication TRUE.
  --
  -- Arguments:
  --   sname: schema in which table is located
  --   oname: name of the table
  --   column_list/column_table: (see comment above)
  --   operation: (see comment above)
  --   send: (see comment above)
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notquiesced: if the replicated object group has not been suspended.
  --   missingobject: if the given object does not exist as a replicated table.
  --   missingcolumn: if any column doesn't exist as a replicated column.
  --   typefailure: if an illegal operation is given.
  --   keysendcomp: if any column is not a non-key column in the table.
  --   dbnotcompatible: if node is not compatible with replication version.
  --   flavornoobject: if any column does not exist.
  ---------------------------------------------------------------------------
  PROCEDURE set_columns(sname       IN VARCHAR2,
                        oname       IN VARCHAR2,
                        column_list IN VARCHAR2);

  PROCEDURE set_columns(sname        IN VARCHAR2,
                        oname        IN VARCHAR2,
                        column_table IN dbms_utility.name_array);

  PROCEDURE set_columns(sname        IN VARCHAR2,
                        oname        IN VARCHAR2,
                        column_table IN dbms_utility.lname_array);

  -- If oname exists in the replicated object group as a table using
  -- column-level replication, record the set of columns to be used as the
  -- "primary key" for replication purposes. Unlike true primary keys, these
  -- columns may contain NULLS. Set_columns does not affect the generated
  -- PL/SQL until the next call to generate_replication_support on the
  -- given object.
  --
  -- Arguments:
  --   sname: schema containing the table
  --   oname: name of the table
  --   column_list: a comma-separated list of column names
  --   column_table: a PL/SQL table of column names
  --
  -- Exceptions:
  --  nonmasterdef: if the invocation site is not the masterdef site.
  --  missingobject: if the given object does not exist as a table in the
  --    replicated object group awaiting column-level replication information.
  --  missingcolumn: if any column is not in the table.
  --  notquiesced: replication object group not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE suspend_master_activity(gname           IN VARCHAR2);
  -- This suspends replication activity for the given object group.
  -- So the repgroup must be in normal operation when this procedure
  -- is called. It quiesces all activity at all master sites, disables
  -- deferred procedure calls, and processes all pending queued procedure
  -- calls. Each master remains in this state until resume_master_activity
  -- is invoked. Queued Deferred RPCs are pushed to remote masters
  -- 
  -- Several of the above administrative procedures (e.g. adding a master
  -- database) must first suspend activity. Administrators may wish to
  -- suspend activity and manually perform a distributed query and update
  -- on the replicas in order to restore equivalence in the event of an
  -- errant conflict resolution.
  -- 
  -- This procedure typically operates asynchronously at the masterdef and
  -- the masters. The RepCatlog contains interim status.
  -- 
  -- Arguments:
  --   gname: name of the replicated object group for which to suspend
  --     master activity
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   notnormal: if the replicated object group is not in normal operation.
  --   commfailure: if any master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE tickle_job(canon_sname IN VARCHAR2,
                       start_now   IN BOOLEAN := FALSE);

  -- Start the background job for processing the group's repcatlog records,
  -- creating the job if necessary.  This procedure is normally called by
  -- repcat executing as the user, and is here only for privilege reasons.
  -- NOTE: for v7 compatibility, do not move the above procedure or 
  --       change its interface.
  ---------------------------------------------------------------------------
  FUNCTION validate(gname             IN  VARCHAR2, 
                    check_genflags    IN  BOOLEAN := FALSE, 
                    check_valid_objs  IN  BOOLEAN := FALSE,
                    check_links_sched IN  BOOLEAN := FALSE,
                    check_links       IN  BOOLEAN := FALSE, 
                    error_table       OUT dbms_repcat.validate_err_table)
  RETURN BINARY_INTEGER;
  -- Validate the configuration of the specified object group.
  -- This procedure should be called from the master definition site 
  -- when check_genflags and check_valide_objs are set to TRUE.
  --
  -- INPUT:
  --   gname             - The name of the object group to validate
  --   check_genflags    - Check if all the replicated objects in the group 
  --                       have generated replication support. The validity
  --                       check is done at master definition site.  
  --   check_valid_objs  - Check if all replicated object in the group are 
  --                       valid. The validity check is done at all master 
  --                       sites.
  --   check_links_sched - Check if all database links are scheduled for
  --                       execution. 
  --   check_links       - Check if the connected user, usually the repadmin,
  --                       has the necessary database links from adminitering
  --                       the replication environment.
  -- OUTPUT:
  --   error_table - This table contains any errors found.
  --   The return value of this function is the number of errors found
  --   (i.e., the number of elements in error_table).
  
  ---------------------------------------------------------------------------
  FUNCTION validate(gname             IN  VARCHAR2, 
                    check_genflags    IN  BOOLEAN := FALSE, 
                    check_valid_objs  IN  BOOLEAN := FALSE,
                    check_links_sched IN  BOOLEAN := FALSE,
                    check_links       IN  BOOLEAN := FALSE, 
                    error_msg_table   OUT dbms_utility.uncl_array,
                    error_num_table   OUT dbms_utility.number_array)
                    RETURN BINARY_INTEGER;
  -- Validate the configuration of the specified object group.
  -- This procedure should be called from the master definition site 
  -- when check_genflags and check_valide_objs are set to TRUE. 
  --
  -- INPUT:
  --   gname             - The name of the object group to validate
  --   check_genflags    - Check if all the replicated objects in the group 
  --                       have generated replication support.  
  --   check_valid_objs  - Check if all replicated object in the group are 
  --                       valid. The validity check is done at all master 
  --                       sites.
  --   check_links_sched - Check if all database links are scheduled for
  --                       execution. 
  --   check_links       - Check if the connected user, usually the repadmin,
  --                       has the necessary database links from adminitering
  --                       the replication environment.
  -- OUTPUT:
  --   error_msg_table - This table contains the text of any errors found.
  --   error_num_table - This table contains the error number of any errors
  --                     found.
  --   The return value of this function is the number of errors found
  --   (i.e., the number of elements in error_num_table and error_msg_table).

  ---------------------------------------------------------------------------
  PROCEDURE wait_master_log(gname        IN  VARCHAR2,
                            record_count IN  NATURAL,
                            timeout      IN  NATURAL,
                            true_count   OUT NATURAL);
  -- Wait until either timeout seconds have passed or there are at most
  -- record_count records in the local RepCatlog that represent administrative
  -- activities for the given replicated object group that have not completed.
  -- Activities that have completed with or without an error are not
  -- considered. The number of incomplete activities is returned in the
  -- parameter true_count.
  -- 
  -- If there are N masters and 1 masterdef for a replicated object group, most
  -- asynchronous administrative requests eventually create N+1 log records
  -- at the masterdef and 1 log record at each master.  Add_master_database
  -- is an exception and may create a log record at the masterdef and a log
  -- record at the new master for each object in the replicated object group.
  -- 
  -- Arguments:
  --   gname: replicated object group
  --   record_count: procedure returns whenever the number of incomplete
  --     requests is at or below this limit
  --   timeout: maximum number of seconds to wait before the procedure returns
  --   true_count: returns number of incomplete requests
  --
  -- Exceptions:
  --   nonmaster: if the invocation site is not a master site.
  ---------------------------------------------------------------------------
  PROCEDURE generate_replication_trigger(sname             IN VARCHAR2,
                                         oname             IN VARCHAR2,
                                         gen_objs_owner    IN VARCHAR2 := NULL,
                                         min_communication IN BOOLEAN := TRUE);

  -- NOTE: This procedure is obsolete in Oracle8 and is included only for
  --       backward compatibility in replication configurations that contain
  --       one or more pre-Oracle8 site.
  -- 
  -- The system must be quiesced.  The procedure must be called at 
  -- the masterdef.  
  --
  -- It generates the $TP package and triggers for the specified particular 
  -- object at all masters.
  -- 
  -- Parameter gen_objs_owner specifies the schema in which the generated
  -- replication trigger and trigger package or procedural wrapper should
  -- be installed. If this value if NULL, then the generated trigger and 
  -- trigger package or procedural wrapper will be installed in the schema
  -- specified by the sname parameter.
  --
  --
  -- If min_communication is TRUE, then the update trigger sends the new value
  -- of a column only if the update statement modifies the column.  The
  -- update trigger sends the old value of the column only if it is a
  -- key column or a column in a modified column group.
  --
  -- Good in conjunction with generate_replication_package for asynch-only 
  -- configurations when adding replication support for a new replicated 
  -- 	object.
  -- 
  -- Do not call generate_replication_trigger without previously having
  -- called generate_replication_support or generate_replication_package
  -- for the same object.
  --
  -- Exceptions:
  --   missingschema if specified owner of generated objects does not exist

  PROCEDURE generate_replication_trigger(gname             IN VARCHAR2,
                                         gen_objs_owner    IN VARCHAR2 := NULL,
                                         min_communication IN BOOLEAN := NULL);
  -- NOTE: This procedure is obsolete in Oracle8 and is included only for
  --       backward compatibility in replication configurations that contain
  --       one or more pre-Oracle8 site.
  -- 
  -- The system must be quiesced. The procedure must be called at the 
  -- masterdef.  
  -- 
  -- It generates the $TP package and triggers and procedural replication
  -- wrappers for all generated objects in the repgroup at all masters.
  --
  -- Parameter gen_objs_owner specifies the schema in which the generated
  -- replication trigger and trigger package or procedural wrapper should
  -- be installed. If this value if NULL, then the generated trigger and 
  -- trigger package or procedural wrapper will be installed in the schema
  -- in which they currently reside.
  -- 
  -- If min_communication is TRUE, then the update trigger sends the new value
  -- of a column only if the update statement modifies the column.  The
  -- update trigger sends the old value of the column only if it is a key
  -- column or a column in a modified column group.  If min_communication is
  -- FALSE, the update trigger always send both the new and old values
  -- of each column.  If min_communication is NULL, the current setting is
  -- retained.
  --
  -- This procedure will normally be called after calls to 
  -- alter_master_propagation.
  -- 
  -- Triggers that have synchronous destinations require that the $RP
  -- package for the oname is already generated at that site.  This lock-step
  -- generation is provided automatically if generate_replication_support
  -- or add_master_database is used to generate the triggers.
  --
  -- Exceptions:
  --   missingschema if specified owner of generated objects does not exist
  ---------------------------------------------------------------------------
  PROCEDURE remove_master_databases(gname       IN VARCHAR2,
                                    master_list IN VARCHAR2);

  PROCEDURE remove_master_databases(gname        IN VARCHAR2,
                                    master_table IN dbms_utility.dblink_array);
  -- To handle the case where several masters are inaccessible and must be
  -- removed at one time, we provide a procedure that deletes a set of
  -- masters. Master_list is a comma-separated list of masters.
  -- Remove_master_databases does not require any removed database to be
  -- accessible.  The other masters must be accessible.
  -- 
  -- For example, suppose A is the masterdef site and sites B, C, D, and E
  -- are master sites for object group G. If masters C and E become
  -- inaccessible and should no longer be masters, the following should
  -- be executed at site A:
  -- 
  --      remove C, E from RepGroup G at A, B, D
  --   remove_master_databases(`G', `C,E');
  -- 
  -- If master_table is a PL/SQL table of type dbms_utility.dblink_array -
  --      master_table(1) := `C';
  --      master_table(2) := `E';
  --   remove_master_databases(`G', master_table);
  -- 
  -- Replication packages are regenerated at the remaining sites.
  -- 
  -- Arguments:
  --   gname: name of the replicated object group
  --   master_list: comma separated list of masters to be removed
  --   master_table: PL/SQL table of masters to be removed
  --
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   nonmaster: if any of the given databases is not a master site.
  --   reconfigerror: if any of the given masters is the masterdef site.
  --   commfailure: if any remaining master is not accessible.
  ---------------------------------------------------------------------------
  PROCEDURE comma_to_table(list   IN  VARCHAR2,
                           len    OUT BINARY_INTEGER,
                           result OUT dbms_utility.dblink_array);
  -- convert a comma-separated list to a PL/SQL table
  -- the table is 1-based, increasing, dense, and terminated by a NULL
  -- the dbms_utility.comma_to_table procedure cannot handle dblinks
  ---------------------------------------------------------------------------
  PROCEDURE repcat_import_check(gname  IN VARCHAR2,
                                master IN BOOLEAN,
                                gowner IN VARCHAR2 := 'PUBLIC');
  -- Update the object identifiers and status values in repcat$_repobject
  -- for the given repgroup, preserving object status values other than VALID.
  --
  -- Exceptions:
  --   missingschema if the replicated object group does not exist.
  --   nonmaster if master is TRUE and either the database is not a master or
  --      the database is not the expected database.
  --   nonmview if master is FALSE and the database is not a materialized view
  --            site.
  --   missingobject if a valid replicated object in the object group does
  --      not exist.
  ---------------------------------------------------------------------------
  PROCEDURE repcat_import_check;
  -- Invoke repcat_import_check(gowner, gname) for each replicated object group
  --
  -- Exceptions:
  --   nonmaster if the database is not the expected database for any
  --     replicated object group.
  --   missingobject if a valid replicated object in any schema does not exist.

  ---------------------------------------------------------------------------
  PROCEDURE specify_new_masters(
    gname                   IN VARCHAR2,
    master_list             IN VARCHAR2);
  -- Specify the masters you intend to add to existing replication groups.
  --
  -- This routine will replace any masters in the local DBA_REPSITES_NEW view
  -- for the given replication group with the masters in the list.
  --
  -- Arguments:
  --   gname: name of an existing replication group.
  --   master_list: the set of masters that will be instantiated.
  --
  -- Notes:
  --   If master_list is empty, all masters for the given replication group
  --   will be removed from the DBA_REPSITES_NEW view.
  --   This procedure must be called at the masterdef site for the given
  --   replication group.
  --
  -- Exceptions:
  --   duplicaterepgroup: object group already exists.
  --   nonmasterdef: not the masterdef.
  --   propmodenotallowed: propagation mode not allowed for this operation.
  --   extstinapp: extension request with status not allowed.
  --   dbnotcompatible: feature is incompatible with database version.
  --   notsamecq: object group  \"%s\".\"%s\" and \"%s\".\"%s\" do not
  --              have the same connection qualifier."
  --

  ---------------------------------------------------------------------------
  PROCEDURE specify_new_masters(
    gname                   IN VARCHAR2,
    master_table            IN dbms_utility.dblink_array);
  ---------------------------------------------------------------------------
  -- Please see the comment in the above overloaded version.
  --
  -- master_table is the set of masters that will be instantiated.
  -- The first master site should be at position 1, the second
  -- at position 2, and so on. A terminating NULL is
  -- permitted, but not required.
  --

  ---------------------------------------------------------------------------
  PROCEDURE add_new_masters(
    export_required             IN     BOOLEAN,
    available_master_table      IN     dbms_utility.dblink_array,
    masterdef_flashback_scn        OUT NUMBER,
    extension_id                   OUT RAW,
    break_trans_to_masterdef    IN     BOOLEAN := FALSE,
    break_trans_to_new_masters  IN     BOOLEAN := FALSE,
    percentage_for_catchup_mdef IN     BINARY_INTEGER := 100,
    cycle_seconds_mdef          IN     BINARY_INTEGER := 60,
    percentage_for_catchup_new  IN     BINARY_INTEGER := 100,
    cycle_seconds_new           IN     BINARY_INTEGER := 60);
  --
  -- Add the masters in the DBA_REPSITES_NEW view to the replication
  -- catalog at all available masters. All masters instantiated with
  -- table-level export must be accessible at this time. Their
  -- new replication groups are added in the quiesced state. Masters
  -- instantiated via full database export-import or via changed-based
  -- recovery need not be accessible.
  --
  -- Arguments:
  --
  --   export_required: set it to TRUE if and only if export is required.
  --   available_master_table: list of masters to be instantiated using
  --                           table-level export/import.
  --                           Do NOT specify masters which will be
  --                           instantiated using full database export-import
  --                           or change-based recovery.
  --                           The first master site should be at position 1,
  --                           the second  at position 2, and so on.
  --                           A terminating NULL is permitted, but not
  --                           required.
  --   masterdef_flashback_scn: the instantiation FLASHBACK_SCN that should be
  --                            used for export or change-based recovery.
  --   extension_id: the identifier for the current pending add master database
  --                 without quiesce request.
  --   break_trans_to_masterdef: If TRUE and export_required, existing masters
  --                             may continue to propagate their deferred RPC
  --                             queues to the masterdef for replication
  --                             groups that are not changing membership.
  --   break_trans_to_new_masters: If TRUE, existing masters may continue to
  --                               propagate their deferred RPC queues to
  --                               the new masters for replication groups that
  --                               are not changing membership. Otherwise,
  --                               propagation to the new masters will be
  --                               disabled.
  --   percentage_for_catchup_mdef: The percentage of propagation resources
  --                                that should be used for catching up to
  --                                masterdef. Must be a multiple of 10
  --                                between 0 and 100.
  --   cycle_seconds_mdef: This parameter is meaningful when
  --                       percentage_for_catchup_mdef is both meaningful and
  --                       between 10 and 90, inclusive. In this case,
  --                       propagation to the masterdef alternates between
  --                       non-extended replication groups and extended
  --                       replication groups, with one push to each during
  --                       each cycle.  This parameter indicates the length of
  --                       the cycle in seconds.
  --   percentage_for_catchup_new: The percentage of propagation resources that
  --                               should be used for catching up to new.
  --                               masters. Must be a multiple of 10 between 0
  --                               and 100.
  --   cycle_seconds_new: This parameter is meaningful when
  --                      percentage_for_catchup_new is both meaningful and
  --                      between 10 and 90, inclusive. In this case,
  --                      propagation to a new master alternates between
  --                      non-extended replication groups and extended
  --                      replication groups, with one push to
  --                      each during each cycle.  This parameter indicates
  --                      the length of the cycle in seconds.
  --
  -- Notes:
  --   For masters to be instantiated via change-based recovery or full db
  --   export-import, they must get all repgroups in the masterdef.
  --
  --   For table-level export-import, ensure that all the repcatlog requests
  --   in DBA_REPCATLOG view for the extended groups have been processed
  --   without any error before import.
  --
  -- Exceptions:
  --   nonmasterdef: not the masterdef.
  --   typefail: parameter value %s is not appropriate
  --   novalidextreq: no valid extension request
  --   nonewsites: no new sites for extension request
  --   notanewsite: not a new site for extension request
  --   dbnotcompatible: feature is incompatible with database version.
  --
  ---------------------------------------------------------------------------
  PROCEDURE add_new_masters(
    export_required             IN     BOOLEAN,
    available_master_list       IN     VARCHAR2,
    masterdef_flashback_scn        OUT NUMBER,
    extension_id                   OUT RAW,
    break_trans_to_masterdef    IN     BOOLEAN := FALSE,
    break_trans_to_new_masters  IN     BOOLEAN := FALSE,
    percentage_for_catchup_mdef IN     BINARY_INTEGER := 100,
    cycle_seconds_mdef          IN     BINARY_INTEGER := 60,
    percentage_for_catchup_new  IN     BINARY_INTEGER := 100,
    cycle_seconds_new           IN     BINARY_INTEGER := 60);
  -- See the comment in the overloaded version with available_master_table.
  -- available_master_list is a comma-separated list of masters to be
  -- instantiated using table-level export-import.

  ---------------------------------------------------------------------------
  PROCEDURE alter_catchup_parameters(
    extension_id                  IN RAW,
    percentage_for_catchup_mdef   IN BINARY_INTEGER := NULL,
    cycle_seconds_mdef            IN BINARY_INTEGER := NULL,
    percentage_for_catchup_new    IN BINARY_INTEGER := NULL,
    cycle_seconds_new             IN BINARY_INTEGER := NULL);
  --
  -- This procedure alters percentage_for_catchup_mdef, cycle_seconds_mdef,
  -- percentage_for_catchup_new and cycle_seconds_new stored in
  -- DBA_REPEXTENSIONS.
  -- It is executed at each master, including masterdef. The effect is only
  -- local to the local site.
  --
  -- Arguments:
  --   extension_id: extension request identifier.
  --   percentage_for_catchup_mdef: The percentage of propagation resources
  --                                that should be used for catching up to
  --                                masterdef. Must be a multiple of 10
  --                                between 0 and 100.
  --   cycle_seconds_mdef: This parameter is meaningful when
  --                       percentage_for_catchup_mdef is both meaningful and
  --                       between 10 and 90, inclusive.  In this case,
  --                       propagation to the masterdef alternates between
  --                       non-extended replication groups and extended
  --                       replication groups, with one push to each during
  --                       each cycle.  This parameter indicates the length of
  --                       the cycle in seconds.
  --   percentage_for_catchup_new: The percentage of propagation resources that
  --                               should be used for catching up to new.
  --                               masters. Must be a multiple of 10 between 0
  --                               and 100.
  --   cycle_seconds_new: This parameter is meaningful when
  --                      percentage_for_catchup_new is both meaningful and
  --                      between 10 and 90, inclusive. In this case,
  --                      propagation to a new master alternates between
  --                      non-extended replication groups and extended
  --                      replication groups, with one push to
  --                      each during each cycle.  This parameter indicates
  --                      the length of the cycle in seconds.
  --
  -- Exceptions:
  --   dbnotcompatible: feature is incompatible with database version.
  --   typefail: parameter value %s is not appropriate
  --

  ---------------------------------------------------------------------------
  PROCEDURE resume_propagation_to_mdef(extension_id       IN RAW);
  -- This indicates that export has been effectively finished and
  -- propagation for both extended and unaffect replication groups from
  -- existing masters to masterdef can be enabled if break_trans_to_masterdef
  -- is FALSE.
  --
  -- Arguments:
  --   extension_id: extension request identifier.
  --
  -- Exceptions:
  --   nonmasterdef: not the masterdef.
  --   extstinapp: extension status is inappropriate
  --   dbnotcompatible: feature is incompatible with database version.
  --

  ---------------------------------------------------------------------------
  PROCEDURE prepare_instantiated_master(
    extension_id          IN RAW);
  --
  -- This procedure enables the propagation of deferred transactions from
  -- other prepared new master sites and existing master sites to the
  -- invocation master site. This procedure also enables the propagation of
  -- deferred transactions from the invocation master site to the other
  -- prepared new master sites and existing master sites.
  --
  -- Before invoking this procedure for a new master instantiated using
  -- change based recovery or full database export/import, perform the
  -- following two additional steps at the new master:
  --   1. Ensure that the new master has the right
  --      global_name, which must be the same name as specified
  --      when invoking dbms_repcat.specify_new_masters at the master
  --      definition site. Use ALTER DATABASE RENAME GLOBAL_NAME to change
  --      the global_name if necessary.
  --
  --   2. Ensure the new master has the appropriate database link(s) to the
  --      master definition site.
  --
  --
  -- The deferrend transaction queue should be empty before the import is done
  -- for the full database export/import.
  --
  -- For the full database export/import and changed-based recovery,
  -- no transactions should be added during or after the import until this
  -- procedure completes successfully.
  --
  -- For the full database export/import and changed-based recovery,
  -- no job queue processes at the invocation until this procedure
  -- completes. Otherwise, deferred transactions could be pushed
  -- before this procedure deletes them.
  --
  -- Do NOT invoke this procedure until instantiation, export-import or
  -- change-based recovery, for the new master is done.
  --
  -- Do NOT perform any DMLs directly on the objects in the extended
  -- group in the new master until prepare_instantiated_master returns
  -- successfully. Those DMLs may not be replicated.
  --
  -- For table-level export-import, ensure that all the repcatlog requests
  -- in DBA_REPCATLOG view for the extended groups have been processed
  -- without error before import.
  --
  -- Arguments:
  --   extension_id: extension request identifier.
  --
  -- Exceptions:
  --   dbnotcompatible: feature is incompatible with database version.
  --   typefail: parameter value %s is not appropriate
  --   notanewsite: not a new site for extension request
  --

  ---------------------------------------------------------------------------
  PROCEDURE undo_add_new_masters_request(
    extension_id                  IN RAW,
    drop_contents                 IN BOOLEAN := TRUE);
  -- This procedure undoes the add_new_masters and specify_new_masters
  -- invocation for a given extension_id.
  --
  -- This procedure is executed at masters, including master definition site.
  -- Its effect is local.
  --
  -- ***********************************************************************
  -- WARNING:
  --   This procedure is used in emergency when add new masters without quiesce
  --   can not proceed after specify_new_masters and add_new_masters, but
  --   BEFORE resume_propagation_to_mdef and prepare_instantiated_master.
  -- ***********************************************************************
  --
  -- Arguments:
  --   extension_id: extension request identifier.
  --   drop_contents: drop the contents of objects in new repgroups being
  --                  extended at the local site if TRUE.
  --
  -- Exceptions:
  --   dbnotcompatible: feature is incompatible with database version.
  --   typefail: parameter value %s is not appropriate

  ---------------------------------------------------------------------------
  --
  -- MATERIALIZED VIEW REPLICATION PROCEDURES
  --
  -- The following procedure are used to create and manage materialized view 
  -- replication sites.
  --
  PROCEDURE create_mview_repgroup(gname            IN VARCHAR2,
                                  master           IN VARCHAR2,
                                  comment          IN VARCHAR2 := '',
                                  propagation_mode IN VARCHAR2 
                                                      := 'ASYNCHRONOUS',
                                  fname            IN VARCHAR2 := NULL,
                                  gowner           IN VARCHAR2 := 'PUBLIC');
  -- Create a new empty materialized view repgroup at the local site. The 
  -- group name must be a master repgroup at the master database.
  --
  -- Arguments:
  --   gname: name of the replicated object group
  --   master: database to use as the master
  --   comment: comment added to the schema_comment field of RepCat view
  --   propagation_mode: method of propagation for all updatable materialized 
  --     views in the object group (SYNCHRONOUS or ASYNCHRONOUS)
  --   fname: This parameter is reserved for internal use.  
  --          Do not specify this parameter unless directed 
  --   gowner: owner of replicated materialized view group
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
  --   alreadymastered: if at the local site there is another materialized view
  --   repgroup with the same group name, but different master.
  ---------------------------------------------------------------------------
  PROCEDURE drop_mview_repgroup(gname         IN VARCHAR2,
                                drop_contents IN BOOLEAN := FALSE,
                                gowner        IN VARCHAR2 := 'PUBLIC');
  -- Drop the given materialized view repgroup and optionally all of its 
  -- contents at this materialized view site.
  -- 
  -- Arguments:
  --   gname: name of the replicated object group to be dropped
  --   drop_contents: (see comment above)
  --   gowner: owner of the replicated object group
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   missingrepgroup: the replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE refresh_mview_repgroup(gname                 IN VARCHAR2,
                                   drop_missing_contents IN BOOLEAN := FALSE,
                                   refresh_mviews        IN BOOLEAN := FALSE,
                                   refresh_other_objects IN BOOLEAN := FALSE,
                                   gowner                IN VARCHAR2
                                                              := 'PUBLIC');
  -- Refresh the RepCat views for the given repgroup and optionally drop
  -- objects no longer in the repgroup.  Consistently refresh the materialized
  -- views iff refresh_snapshots is TRUE.  Refresh the other objects if
  -- refresh_other_objects is TRUE. The value in gname must be an existing
  -- object group in the local database. The value of gowner is the
  -- owner of the object group.
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   nonmaster: if the master is no longer a master site.
  --   commfailure: if the master is not accessible.
  --   missingrepgroup: if the replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE switch_mview_master(gname  IN VARCHAR2,
                                master IN VARCHAR2,
                                gowner IN VARCHAR2 := 'PUBLIC');
  -- Change the master database of the materialized view repgroup to the given
  -- database. The new database must contain a replica of the master
  -- repgroup. Each materialized view in the local repgroup will be completely
  -- refreshed from the new master the next time it is refreshed.
  -- This procedure will raise an error if any materialized view definition 
  -- query is bigger than 32K.
  --
  -- Any materialized view logs should be created at all masters to avoid 
  -- future complete refreshes.
  --
  -- Arguments:
  --   gname: name of the materialized view object group
  --   master: name of the new master
  --   gowner: owner of the materialized view object group
  --
  -- Exceptions:
  --   nonmview: if the invocation site is not a materialized view site.
  --   nonmaster: if the given database is not a master site.
  --   commfailure: if the given database is not accessible.
  --   missingrepgroup: materialized view repgroup does not exist
  --   qrytoolong: materialized view definition query is > 32K
  --   alreadymastered: if at the local site there is another materialized 
  --     view repgroup with the same group name and mastered at the old master.
  ---------------------------------------------------------------------------
  PROCEDURE create_mview_repobject(sname             IN VARCHAR2,
                                   oname             IN VARCHAR2,
                                   type              IN VARCHAR2,
                                   ddl_text          IN VARCHAR2 := '',
                                   comment           IN VARCHAR2 := '',
                                   gname             IN VARCHAR2 := '',
                                   gen_objs_owner    IN VARCHAR2 := '',
                                   min_communication IN BOOLEAN  := TRUE,
                                   generate_80_compatible IN BOOLEAN := TRUE,
                                   gowner            IN VARCHAR2 := 'PUBLIC');
  -- Add the given object name and type to the RepObject view at the local
  -- materialized view repgroup. The allowed types are `package', 
  -- `package body', `procedure', `snapshot', `synonym', 'trigger', 'index', 
  -- `view', 'type', 'type body', 'operator', 'indextype'.
  -- 
  -- For objects of type `snapshot', generate the client-side half of the 
  -- replication packages if the underlying table uses row/column-level 
  -- replication.  
  -- 
  -- The parameter ddl_text defines the materialized view if the materialized
  -- view does not already exist. The value of oname should match the 
  -- materialized view name defined in the ddl_text.  The snaphot's master 
  -- should match the master stored in all_repgroup, this includes the 
  -- connection qualifier that may be associated with the master group.
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
  -- gowner is the owner of the replicated group
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
  --   created badmviewname if materialized view base table differs from 
  --   master table misingrepgroup if replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE generate_mview_support(sname             IN VARCHAR2,
                                   oname             IN VARCHAR2,
                                   type              IN VARCHAR2,
                                   gen_objs_owner    IN VARCHAR2 := '',
                                   min_communication IN BOOLEAN := TRUE,
                                   generate_80_compatible
                                                     IN BOOLEAN := TRUE);
  -- If the object exists in the replicated materialized view object group
  -- as an updatable materialized view using row/column-level replication, 
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
  --   nonmview if the invocation site is not a materialized view site.
  --   missingobject if the given object does not exist as a materialized view
  --     in the replicated object group awaiting row/column-level replication
  --     information or as a procedure or package (body) awaiting wrapper
  --     generation.
  --   typefailure if the given type parameter is not supported.
  --   missingschema if specified owner of generated objects does not exist
  --   missingremoteobject if the master object has not yet generated
  --     replication support.
  --   commfailure if the master is not accessible
  ---------------------------------------------------------------------------
  PROCEDURE drop_mview_repobject(sname        IN VARCHAR2,
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
  ---------------------------------------------------------------------------
  PROCEDURE alter_mview_propagation(gname            IN VARCHAR2,
                                    propagation_mode IN VARCHAR2,
                                    comment          IN VARCHAR2 := '',
                                    gowner           IN VARCHAR2 := 'PUBLIC');
  -- Alter the propagation method of all replication materialized views, 
  -- procedure, packages, and package bodies for all materialized view 
  -- repobjects in the specified materialized view repgroup.
  --
  -- Altering the propagation method involves regenerating replication
  -- support at the materialized view site. When converting from asynchronous
  -- replication to synchronous replication, the deferred RPC queue is
  -- pushed before conversion.
  --
  -- Queued Deferred RPCs are pushed to remote masters
  --
  -- Exceptions:
  --   notcompat: only databases operating in 7.3 (or later) mode can
  --   use this procedure.
  --   failaltermviewrop: materialized view repgroup propagation can be 
  --   altered only when there is no other repgroup with the same master 
  --   sharing the site.
  ---------------------------------------------------------------------------
  --
  -- CONFLICT RESOLUTION PROCEDURES
  --
  -- The following procedures are added to support automatic conflict 
  -- resolution.  Note that these procedures are available only on master 
  -- sites.  Conflict resolution is not available on materialized view sites.
  ---------------------------------------------------------------------------
  PROCEDURE define_column_group(sname        IN VARCHAR2, 
                                oname        IN VARCHAR2, 
                                column_group IN VARCHAR2, 
                                comment      IN VARCHAR2 := NULL);
  -- Create a new column group for the given repobject. The column group
  -- has no members yet. Define_column_group does not affect the generated
  -- PL/SQL until the next call to generate_replication_support.
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.  
  --           Defaults to invoking user. 
  --    oname: The name of the table being replicated.
  --    column_group: The name of the column group being defined. 
  --    comment: Comment text for the column group being defined. 
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicategroup: if the given column group already exists for the 
  --                    repobject.
  --    missingobject: if the given repobject does not exist.
  --    notquiesced: if the object group that the replicated table belongs
  --           to is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_column_group(sname        IN VARCHAR2, 
                                    oname        IN VARCHAR2, 
                                    column_group IN VARCHAR2, 
                                    comment      IN VARCHAR2);

  -- Update the comment field for the given column group in the
  -- *_RepColumn_Group views.
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.  
  --           Defaults to invoking user. 
  --    oname: The name of the table being replicated.
  --    column_group: The name of the column group.
  --    comment: Comment text for the column group being defined. 
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missinggroup: if the given column group does not exist.
  --    missingobj: if the given repobject does not exist
  ---------------------------------------------------------------------------
  PROCEDURE drop_column_group(sname        IN VARCHAR2, 
                              oname        IN VARCHAR2, 
                              column_group IN VARCHAR2);
  -- Drop the given column group.  Drop_column_group does not affect the 
  -- PL/SQL until the next call to generate_replication_support.
  -- Input Parameters:
  --   sname: The name of the schema containing the table to be replicated.  
  --          Defaults to invoking user.
  --   oname: The name of the table being replicated.
  --   column_group: The name of the column group to be dropped
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   referenced: if the given column group is being used in conflict 
  --                detection and resolution.
  --   missingobject: if given table does not exist
  --   missinggroup: if given column group does not exist
  --   notquiesced: if object group that the replicated table belongs to
  --          is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE add_grouped_column(sname                IN VARCHAR2,
                               oname                IN VARCHAR2,
                               column_group         IN VARCHAR2,
                               list_of_column_names IN VARCHAR2);

  PROCEDURE add_grouped_column(sname                IN VARCHAR2, 
                               oname                IN VARCHAR2,
                               column_group         IN VARCHAR2,
                               list_of_column_names IN dbms_repcat.varchar2s);
  -- Assign a set of columns to the given column group.  Add_grouped_column 
  -- does not affect the generated PL/SQL until the next call to 
  -- generate_replication_support.
  -- Arguments:
  --   sname: The name of the schema containing the table to be replicated.
  --          Defaults to invoking user.
  --   oname: The name of the table being replicated.
  --   column_group: The name of the column group.
  --   list_of_column_names: A list of columns being added to the column .
  --          group. The list can be a comma separated list of columns or
  --          a pl/sql table of columns.
  --          a '*' as the only entry in the list results in all the
  --          columns in the table being entered as part of the column group 
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given table does not exist
  --   duplicatecolumn: if the given column already exists in the column group
  --   missinggroup: if the given column group does not exist.
  --   missingcolumn: if the given column does not exist in the repobject.
  --   missingschema: if the given schema does not exist
  --   notquiesced: the object group that the given table belongs to is
  --          not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE make_column_group (sname                IN VARCHAR2,
                               oname                IN VARCHAR2,
                               column_group         IN VARCHAR2,
                               list_of_column_names IN VARCHAR2);

  PROCEDURE make_column_group (sname                IN VARCHAR2, 
                               oname                IN VARCHAR2,
                               column_group         IN VARCHAR2,
                               list_of_column_names IN dbms_repcat.varchar2s);
  -- Create a new column group with one or more members
  -- i.e. do a combined define and add
  -- Input parameters:
  --   sname: name of schema containing the replicated table
  --   oname: name of the replicated table
  --   colgrp: name of the new column group
  --   list_of_column_name: names of columns in the new column group
  ---------------------------------------------------------------------------
  PROCEDURE drop_grouped_column(sname                IN VARCHAR2,
                                oname                IN VARCHAR2,
                                column_group         IN VARCHAR2,
                                list_of_column_names IN dbms_repcat.varchar2s);
 
  PROCEDURE drop_grouped_column(sname                IN VARCHAR2,
                                oname                IN VARCHAR2,
                                column_group         IN VARCHAR2,
                                list_of_column_names IN VARCHAR2);
  -- Remove a column from the given column group.  Drop_grouped_column does not
  -- affect the generated PL/SQL until the next call to 
  -- generate_replication_support.
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.
  --           Defaults to invoking user.
  --    oname: The name of the table being replicated.
  --    column_group: The name of the column group.
  --    list_of_column_names: names of columns to be removed
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingobject: if given table does not exist
  --    notquiesced: if the object group the replicated table belongs to
  --           is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE define_priority_group(gname        IN VARCHAR2,
                                  pgroup       IN VARCHAR2,
                                  datatype     IN VARCHAR2,
                                  fixed_length IN INTEGER := NULL,
                                  comment      IN VARCHAR2 := NULL);
  -- Create a new priority group.  The name of the priority group must be 
  -- unique in a repgroup.  The valid values of datatype are those, except 
  -- rowid, that are supported by Rep2.  
  -- Define_priority_group does not affect the generated PL/SQL until the
  -- next call to generate_replication_support.  
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    pgroup: The name of the priority group being created.
  --    datatype: The datatype of value in the priority group being created.  
  --            Supported datatypes are: `CHAR', `VARCHAR2', `NUMBER', `DATE', 
  --            `RAW', `NCHAR' and `NVARCHAR2'.
  --    fixed_length: The fixed length for data of type CHAR.  
  --    comment: Comment text for the priority group being created.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicateprioritygroup: if the given priority group already exists 
  --             in the replicated object group.
  --    typefailure: if the given datatype is not an allowable type.
  --    missingrepgroup: if given replicated object group does not exist
  --    notquiesced: if replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_priority_group(gname   IN VARCHAR2,
                                      pgroup  IN VARCHAR2, 
                                      comment IN VARCHAR2);
  -- Update the comment field for the given priority group in the
  -- *_RepPriority_Group views
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    pgroup: The name of the priority group.
  --    comment: Comment text for the priority group being created.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingprioritygroup: if the given priority group does not exist.
  --    missingrepgroup: if the replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE drop_priority_group(gname  IN VARCHAR2,
                                pgroup IN VARCHAR2);
  -- Drop the given priority group.  Drop_priority_group does not affect the 
  -- generated PL/SQL until the next call to generate_replication_support.  
  -- Users cannot drop a priority group if the priority group is still 
  -- referenced in any generated resolution packages.
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    pgroup: The name of the priority group.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    referenced: if the given priority group is being used in conflict 
  --           resolution.
  --    missingrepgroup: if the given replicated object group does not exist
  --    notquiesced: if the given replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE add_priority_char(gname    IN VARCHAR2,
                              pgroup   IN VARCHAR2,
                              value    IN CHAR,
                              priority IN NUMBER);

  PROCEDURE add_priority_nchar(gname    IN VARCHAR2,
                               pgroup   IN VARCHAR2,
                               value    IN NCHAR,
                               priority IN NUMBER);

  PROCEDURE add_priority_date(gname    IN VARCHAR2,
                              pgroup   IN VARCHAR2,
                              value    IN DATE,
                              priority IN NUMBER);

  PROCEDURE add_priority_number(gname    IN VARCHAR2,
                                pgroup   IN VARCHAR2, 
                                value    IN NUMBER,
                                priority IN NUMBER);

  PROCEDURE add_priority_raw(gname    IN VARCHAR2,
                             pgroup   IN VARCHAR2,
                             value    IN RAW,
                             priority IN NUMBER);

  PROCEDURE add_priority_varchar2(gname    IN VARCHAR2,
                                  pgroup   IN VARCHAR2,
                                  value    IN VARCHAR2,
                                  priority IN NUMBER);

  PROCEDURE add_priority_nvarchar2(gname    IN VARCHAR2,
                                   pgroup   IN VARCHAR2,
                                   value    IN NVARCHAR2,
                                   priority IN NUMBER);
  -- Add a new value to the given priority group.  The new value
  -- must be unique, and the priority must be unique.  The addition of this
  -- value becomes effective immediately.
  -- Input Parameters:
  --   gname: The name of the repgroup.
  --   pgroup: The name of the priority group.
  --   value: A new value for the priority group.
  --   priority: The priority for the new value.
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   duplicatevalue: if the given value already exists in the priority group.
  --   duplicatepriority: if the given priority already exists in the 
  --                      priority group.
  --   missingprioritygroup: if the given priority group does not exist.
  --   typefailure: if the given value has an incorrect datatype for the
  --                priority group.
  ---------------------------------------------------------------------------
  PROCEDURE alter_priority_char(gname     IN VARCHAR2,
                                pgroup    IN VARCHAR2,
                                old_value IN CHAR,
                                new_value IN CHAR);

  PROCEDURE alter_priority_nchar(gname     IN VARCHAR2,
                                 pgroup    IN VARCHAR2,
                                 old_value IN NCHAR,
                                 new_value IN NCHAR);

  PROCEDURE alter_priority_date(gname     IN VARCHAR2,
                                pgroup    IN VARCHAR2,
                                old_value IN DATE,
                                new_value IN DATE);

  PROCEDURE alter_priority_number(gname     IN VARCHAR2,
                                  pgroup    IN VARCHAR2,
                                  old_value IN NUMBER,
                                  new_value IN NUMBER);

  PROCEDURE alter_priority_raw(gname     IN VARCHAR2,
                               pgroup    IN VARCHAR2,
                               old_value IN RAW,
                               new_value IN RAW);

  PROCEDURE alter_priority_varchar2(gname     IN VARCHAR2,
                                    pgroup    IN VARCHAR2,
                                    old_value IN VARCHAR2,
                                    new_value IN VARCHAR2);

  PROCEDURE alter_priority_nvarchar2(gname     IN VARCHAR2,
                                     pgroup    IN VARCHAR2,
                                     old_value IN NVARCHAR2,
                                     new_value IN NVARCHAR2);
  -- Alter the priority value of a member in a priority group. The new value
  -- must be unique. The change in value becomes effective immediately.
  -- Note that implicit conversion will work from many different
  -- data types into VARCHAR2.
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    pgroup: The name of the priority group.
  --    old_value: The old value to be altered.
  --    new_value: The new value. 
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicatevalue: if the given new value already exists in the priority 
  --           group.
  --    missingprioritygroup: if the given priority group does not exist.
  --    misingrepgroup: if given object group does not exist
  --    missingvalue: if old_value does not exist
  --    paramtype: if new vvalue has incorrect datatype for priority group
  --    notquiesced: if replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE alter_priority(gname        IN VARCHAR2,
                           pgroup       IN VARCHAR2,
                           old_priority IN NUMBER,
                           new_priority IN NUMBER);
  -- Update an old priority to a new priority. The new priority must be unique.
  -- The change in priority becomes effective immediately.  
  -- Input Parameters:
  --    gname: The name of the object group containing the table to be
  --           replicated.
  --    pgroup: The name of the priority group.
  --    old_priority: The priority to be altered.  
  --    new_priority:  The new priority.  
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicatepriority: if the given new priority already exists in the 
  --           priority group.
  --    missingprioritygroup: if the given priority group does not exist.
  --    missingvalue: if the value was not previously registered by
  --           a call to dbms_repcat.add_priority_"dataytype"
  --    notquiesced: if the given replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE drop_priority(gname        IN VARCHAR2,
                          pgroup       IN VARCHAR2,
                          priority_num IN NUMBER);
  -- Remove a value from the given priority group by priority.  
  -- The removal of this value becomes effective immediately.  
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    pgroup: The name of the priority group.
  --    priority: The priority for the value being dropped.  
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingprioritygroup: if the given priority group does not exist.
  --    missingrepgroup: if given replicated object group does not exist
  --    notquiesced: if given replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE drop_priority_char(gname  IN VARCHAR2,
                               pgroup IN VARCHAR2,
                               value  IN CHAR);

  PROCEDURE drop_priority_nchar(gname  IN VARCHAR2,
                                pgroup IN VARCHAR2,
                                value  IN NCHAR);

  PROCEDURE drop_priority_date(gname  IN VARCHAR2,
                               pgroup IN VARCHAR2,
                               value  IN DATE);

  PROCEDURE drop_priority_number(gname  IN VARCHAR2,
                                 pgroup IN VARCHAR2,
                                 value  IN NUMBER);

  PROCEDURE drop_priority_raw (gname  IN VARCHAR2,
                               pgroup IN VARCHAR2,
                               value  IN RAW);

  PROCEDURE drop_priority_varchar2(gname  IN VARCHAR2,
                                   pgroup IN VARCHAR2,
                                   value  IN VARCHAR2);

  PROCEDURE drop_priority_nvarchar2(gname  IN VARCHAR2,
                                    pgroup IN VARCHAR2,
                                    value  IN NVARCHAR2);
  -- Remove a value from the given priority group.  
  -- The removal of this value becomes effective immediately.  
  -- Note that implicit conversion will work from many different
  -- data types into VARCHAR2.
  -- Input Parameters:
  --    gname: The replicated object group with which the priority group
  --           is associated
  --    pgroup: The name of the priority group.
  --    value: The value to be dropped
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingprioritygroup: if the given priority group does not exist.
  --    paramtype: if the given value has an incorrect datatype for the 
  --           priority group.
  --   notquiesced: if the replicated object group is not quiesced
  --   missingrepgroup: if the replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE define_site_priority(gname   IN VARCHAR2,
                                 name    IN VARCHAR2,
                                 comment IN VARCHAR2 := NULL);
  -- Create a new site priority group. The site priority name must be unique
  -- in a repgroup.  Define_site_priority does not affect the generated PL/SQL 
  -- until the next call to generate_replication_support.  
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    name: The name of the site priority being created.
  --    comment: Comment text for the site priority being created.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicateprioritygroup: if the given site priority group already
  --         exists in the repgroup.
  --    notquiesced: if the given replicated object group is not quiesced
  --    missingrepgroup: if given replicated object group does not exist
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_site_priority(gname   IN VARCHAR2,
                                     name    IN VARCHAR2,
                                     comment IN VARCHAR2);
  -- Update the comment field for the given site priority group in the
  -- *_RepPriority_Group views
  -- Input Parameters:
  --    gname: The name of the schema containing the table to be replicated.  
  --    name: The name of the site priority.
  --    comment: Comment text for the site priority being created.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingpriority: if the given site priority does not exist.
  ---------------------------------------------------------------------------
  PROCEDURE drop_site_priority(gname IN VARCHAR2,
                               name  IN VARCHAR2);
  -- Drop the given site priority.  Drop_site_priority does not affect the 
  -- generated PL/SQL until the next call to generate_replication_support.  
  -- Users cannot drop a site priority if the site priority is still referenced 
  -- in any generated resolution packages.
  -- Input Parameters:
  --    gname: The name of the repgroup containing the table to be replicated.
  --    name: The name of the site priority.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    referenced: if the given priority group is being used in conflict 
  --           resolution.
  --    missingrepgroup: if the given replicated object group does not exist
  --    notquiesced: if the given replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE add_site_priority_site(gname    IN VARCHAR2,
                                   name     IN VARCHAR2,
                                   site     IN VARCHAR2,
                                   priority IN NUMBER);
  -- Add a new site to the given site priority.  The new site must be unique, 
  -- and the priority must be unique.  The addition of this site becomes 
  -- effective immediately.  
  -- Input Parameters:
  --    gname: The name of the replicated object group.
  --    name: The name of the site priority.
  --    site: A new site for the site priority.  The site value should come 
  --          from global_name view.  It must already be canonicalized.
  --    priority: The priority for the new site.  
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    duplicateval: if the given site already exists in the site priority.
  --    duplicatepriority: if the given priority already exists in the site 
  --           priority.
  --    missingpriority: if the given site priority group does not exist.
  --    missingrepgroup: if the replicated object group does not exist
  --    notquiesced: if the replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE alter_site_priority_site(gname    IN VARCHAR2,
                                     name     IN VARCHAR2,
                                     old_site IN VARCHAR2,
                                     new_site IN VARCHAR2);
  -- Alter the site associated with a priority level. The new site must
  -- be unique. The change in site becomes effective immediately.
  -- Input Parameters:
  --    gname: The name of the object group containing the table to be
  --           replicated. Defaults to invoking user. 
  --    name: The name of the site priority group.
  --    old_site: The old site to be altered.
  --    old_site: The new site. 
  -- Exceptions:
  --  nonmasterdef if the invocation site is not the masterdef site.
  --  missingpriority if the given site priority does not exist.
  --  missingrepgroup: if given replicated object group does not exist
  --  missingvalue: if old_site is not a group membeer
  --  notquiesced: if object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE alter_site_priority(gname        IN VARCHAR2,
                                name         IN VARCHAR2,
                                old_priority IN NUMBER,
                                new_priority IN NUMBER);
  -- Alter the priority level of a site. The new priority must be unique.
  -- The change in priority becomes effective immediately.
  -- Input Parameters:
  --   gname: The name of the repgroup containing the table to be replicated.
  --   name: The name of the site priority.
  --   old_priority: The priority to be altered.
  --   new_priority: The new priority.
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingpriority: if the given site priority does not exist.
  --   missingrepgroup: if the given replicated object group does not exist
  --   missingvalue: if old value does not exist
  --   notquiesced: if replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE drop_site_priority_site(gname IN VARCHAR2,
                                    name  IN VARCHAR2,
                                    site  IN VARCHAR2);
  -- Remove a site, by name, from the given site priority group. The removal
  -- of this site becomes effective immediately.  
  -- Input Parameters:
  --    gname: The name of the schema containing the table to be replicated.  
  --           Defaults to invoking user. 
  --    name: The name of the site priority.
  --    site: The site to be dropped.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingpriority: if the given site priority does not exist.
  --    missingrepgroup: if given replicated object group does not exist
  --    notquiesced: if given replicated object group is not quiesced
  ---------------------------------------------------------------------------
  PROCEDURE add_update_resolution(sname                 IN VARCHAR2,
                                  oname                 IN VARCHAR2,
                                  column_group          IN VARCHAR2,
                                  sequence_no           IN NUMBER,
                                  method                IN VARCHAR2,
                                  parameter_column_name 
                                            IN dbms_repcat.varchar2s,
                                  priority_group IN VARCHAR2 := NULL,
                                  function_name  IN VARCHAR2 := NULL,
                                  comment        IN VARCHAR2 := NULL);

  PROCEDURE add_update_resolution(sname                 IN VARCHAR2,
                                  oname                 IN VARCHAR2,
                                  column_group          IN VARCHAR2,
                                  sequence_no           IN NUMBER,
                                  method                IN VARCHAR2,
                                  parameter_column_name 
                                            IN dbms_utility.lname_array,
                                  priority_group IN VARCHAR2 := NULL,
                                  function_name  IN VARCHAR2 := NULL,
                                  comment        IN VARCHAR2 := NULL);

  PROCEDURE add_update_resolution(sname                 IN VARCHAR2,
                                  oname                 IN VARCHAR2,
                                  column_group          IN VARCHAR2,
                                  sequence_no           IN NUMBER,
                                  method                IN VARCHAR2,
                                  parameter_column_name IN VARCHAR2,
                                  priority_group IN VARCHAR2 := NULL,
                                  function_name  IN VARCHAR2 := NULL,
                                  comment        IN VARCHAR2 := NULL);
  -- Add a new conflict resolution for the given object.  
  -- Add_update_resolution does not affect the generated PL/SQL until the 
  -- next call to generate_replication_support on the given object.   
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.  
  --           Defaults to invoking user. 
  --    oname: The name of the table being replicated.
  --    column_group: name of the column_group
  --    sequence_no: A number which indicates the order conflict resolutions 
  --           are applied.  A smaller sequence number precedes a larger one.  
  --    method: The conflict resolution method. 
  --    parameter_column_name: An ordered list of columns to be used for 
  --           resolving the conflict.  May also be a comma-separated list.
  --           a '*' as the only entry in the list results in all the
  --           columns in the column group being entered in the alphebetical
  --           order (only applicable for 'user function').
  --           Scalar leaf attribute of an object type for system built-in
  --           resolution routine may be allowed.
  --    priority_group: If the method is `PRIORITY GROUP', enter the name of 
  --           priority group used for resolving the conflict.
  --    function_name: If the method is `USER FUNCTION', enter the user 
  --           resolution function name here.
  --    comment: Comment text for the conflict resolution being defined.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingobject: if the given object does not exist as a table in the 
  --           replicated object group awaiting replication information.
  --    duplicatesequence: if the sequence number already exists for the given 
  --           object.
  --    missingcolumn: if the given columns do not exist in the table.  
  --    missinggroup: if the given column group does not exist for the table.
  --    invalidmethod: if the given resolution method does not exist.
  --    invalidprioritygroup: if the given priority group does not exist.
  --    invalidparameter: if the given number of parameter columns is invalid.
  --    missingfunction: if the user function does not exist. 
  ---------------------------------------------------------------------------
  PROCEDURE add_delete_resolution(sname          IN VARCHAR2,
                                  oname          IN VARCHAR2,
                                  sequence_no    IN NUMBER,
                                  parameter_column_name 
                                            IN dbms_repcat.varchar2s,
                                  function_name  IN VARCHAR2,
                                  comment        IN VARCHAR2 := NULL,
                                  method         IN VARCHAR2 :=
                                            'USER FUNCTION');

  PROCEDURE add_delete_resolution(sname          IN VARCHAR2,
                                  oname          IN VARCHAR2,
                                  sequence_no    IN NUMBER,
                                  parameter_column_name IN VARCHAR2,
                                  function_name  IN VARCHAR2,
                                  comment        IN VARCHAR2 := NULL,
                                  method         IN VARCHAR2 :=
                                            'USER FUNCTION');
  -- Designates a method for resolving delete conflicts. This must be called
  -- from the masterdef site.
  -- Arguments:
  --   sname: name of schema containing the replicated table. Defaults to
  --          invoking user.
  --   oname: table name
  --   sequence_no: order in which the conflict resolution menthod should
  --          be applied. This is a number which indicates the order conflict
  --          resolutions are applied. A smaller sequence number precedes a
  --          larger one.
  --   parameter_column_name: name of columns used to resolve the conflict,
  --                          only top-level column is allowed.
  --   function_name: name of the conflict resolution routine
  --   comment: comment text for the conflict resolution being defined. This
  --          is inserted in the *_represoluton views.
  --   method: must be either 'USER FUNCTION' or 'USER FLAVOR FUNCTION'
  ---------------------------------------------------------------------------
  PROCEDURE add_unique_resolution(sname           IN VARCHAR2,
                                  oname           IN VARCHAR2,
                                  constraint_name IN VARCHAR2,
                                  sequence_no     IN NUMBER,
                                  method          IN VARCHAR2, 
                                  parameter_column_name 
                                            IN dbms_repcat.varchar2s,
                                  function_name   IN VARCHAR2 := NULL,
                                  comment         IN VARCHAR2 := NULL);

  PROCEDURE add_unique_resolution(sname           IN VARCHAR2,
                                  oname           IN VARCHAR2,
                                  constraint_name IN VARCHAR2,
                                  sequence_no     IN NUMBER,
                                  method          IN VARCHAR2, 
                                  parameter_column_name 
                                            IN dbms_utility.lname_array,
                                  function_name   IN VARCHAR2 := NULL,
                                  comment         IN VARCHAR2 := NULL);

  PROCEDURE add_unique_resolution(sname           IN VARCHAR2,
                                  oname           IN VARCHAR2,
                                  constraint_name IN VARCHAR2,
                                  sequence_no     IN NUMBER,
                                  method          IN VARCHAR2,
                                  parameter_column_name IN VARCHAR2,
                                  function_name   IN VARCHAR2 := NULL,
                                  comment         IN VARCHAR2 := NULL);
  -- Designate a method for resolving uniqueness conflicts involving a given
  -- unique constraint.
  -- Input parameters:
  --   sname: name of schema containing the replicated table
  --   oname: name of the replicated table
  --   constraint_name: name of unique constraint for which to add a conflict
  --          resolution routine
  --   sequence_no: order in which the conflict resolution menthod should
  --          be applied. This is a number which indicates the order conflict
  --          resolutions are applied. A smaller sequence number precedes a
  --          larger one.
  --   method: type of conflict resolution method to be created
  --   parameter_column_name: columns used to resolve conflict.
  --                          Scalar leaf attribute of an object type for
  --                          system built-in resolution routine may be
  --                          allowed.
  --   function_name: name of conflict resolution reutine. If using one of
  --          the standard ones, use the default value, NULL
  --   comment: comment text for the conflict resolution being added
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_update_resolution(sname        IN VARCHAR2,
                                         oname        IN VARCHAR2,
                                         column_group IN VARCHAR2,
                                         sequence_no  IN NUMBER,
                                         comment      IN VARCHAR2);
  -- Update the comment field for the given update conflict resolution
  -- in the *_RepResolution views
  -- Input parameters:
  --   sname: name of schema containing the replicated table. Defaults to
  --          invoking user
  --   oname: name of replicated table with which the conflict resoluton
  --          routine is associated
  --   column_group: name of the column group with which the update
  --          conflict resolution routine is associated
  --   sequence_no: seq number of the conflict resolution routine.
  --          This is a number which indicates the order conflict resolutions
  --          are applied.  A smaller sequence number precedes a larger one.
  --   comment: new comment text for the conflict type resolution
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist as a table in the
  --          replicated object group awaiting replication information.
  --   missingresolution: if the given conflict resolution does not exist
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_delete_resolution(sname       IN VARCHAR2,
                                         oname       IN VARCHAR2,
                                         sequence_no IN NUMBER,
                                         comment     IN VARCHAR2) ;
  -- Update the comment field for the given delete conflict resolution
  -- in the *_RepResolution views
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.  
  --           Defaults to invoking user. 
  --    oname: The name of the table being replicated.
  --    sequence_no: A number which indicates the order conflict resolutions 
  --           are applied.  A smaller sequence number precedes a larger one.  
  --    comment: Comment text for the conflict resolution being defined.
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingobject: if the given object does not exist as a table in the 
  --           replicated object group awaiting replication information.
  --    missingresolution: if the given conflict resolution does not exist.
  ---------------------------------------------------------------------------
  PROCEDURE comment_on_unique_resolution(sname           IN VARCHAR2,
                                         oname           IN VARCHAR2,
                                         constraint_name IN VARCHAR2,
                                         sequence_no     IN NUMBER,
                                         comment         IN VARCHAR2) ;
  -- Update the comment field for the given unique conflict resolution in the
  -- *_RepResolution views
  -- Input parameters:
  --   sname: name of schema containing the replicated table. Defaults to
  --          invoking user
  --   oname: name of replicated table with which the conflict resoluton
  --          routine is associated
  --   constraint_name: name of unique constraint with which the unique
  --          conflict resolution routine is associated
  --   sequence_no: seq number of the conflict resolution routine.
  --          This is a number which indicates the order conflict resolutions
  --          are applied.  A smaller sequence number precedes a larger one.
  --   comment: new comment text for the conflict type resolution
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist as a table in the
  --          replicated object group awaiting replication information.
  --   missingresolution: if the given conflict resolution does not exist
  ---------------------------------------------------------------------------
  PROCEDURE drop_update_resolution(sname        IN VARCHAR2,
                                   oname        IN VARCHAR2,
                                   column_group IN VARCHAR2,
                                   sequence_no  IN NUMBER) ;

  -- Remove an update conflict resolution for the given object.    
  -- Drop_update_resolution does not affect the generated PL/SQL until the 
  -- next call to generate_replication_support on the given object.   
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.
  --           Defaults to invoking user.
  --    oname: The name of the table being replicated.
  --    column_group_name: name of the column group for which you want to 
  --           drop an update conflict resolution routine
  --    sequence_no: A number which indicates the order conflict resolutions 
  --           are applied.  A smaller sequence number precedes a larger one.  
  -- Exceptions:
  --    nonmasterdef: if the invocation site is not the masterdef site.
  --    missingobject: if the given object does not exist as a table in 
  --           the replicated object group awaiting replication information.
  ---------------------------------------------------------------------------
  PROCEDURE drop_delete_resolution(sname       IN VARCHAR2,
                                   oname       IN VARCHAR2,
                                   sequence_no IN NUMBER) ;
  -- Remove a delete conflict resolution for the given object.  
  -- Drop_delete_resolution does not affect the generated PL/SQL until 
  -- the next call to generate_replication_support on the given object.   
  -- Input Parameters:
  --   sname: The name of the schema containing the table to be replicated.  
  --          Defaults to invoking user. 
  --   oname: The name of the table being replicated.
  --   sequence_no: A number which indicates the order conflict resolutions 
  --          are applied.  A smaller sequence number precedes a larger one.  
  -- Exceptions:
  --   nonmasterdef: if the invocation site is not the masterdef site.
  --   missingobject: if the given object does not exist as a table in 
  --          the replicated object group awaiting replication information.
  ---------------------------------------------------------------------------
  PROCEDURE drop_unique_resolution(sname           IN VARCHAR2,
                                   oname           IN VARCHAR2,
                                   constraint_name IN VARCHAR2,
                                   sequence_no     IN NUMBER) ;
  -- Remove a uniqueness conflict resolution for the given object.    
  -- Drop_unique_resolution does not affect the generated PL/SQL 
  -- until the next call to generate_replication_support on the given object.   
  -- Input Parameters:
  --     sname: The name of the schema containing the table to be replicated.  
  --            Defaults to invoking user.
  --     oname: The name of the table being replicated.
  --     constraint_name: The name of the unique constraint for which you
  --            want to drop a unique conflict resolution routine
  --     sequence_no: A number which indicates the order conflict resolutions 
  --            are applied.  A smaller sequence number precedes a larger one.
  -- Exceptions:
  --     nonmasterdef: if the invocation site is not the masterdef site.
  --     missingobject: if the given object does not exist as a table in 
  --            the replicated object group awaiting replication information.
  ---------------------------------------------------------------------------
  PROCEDURE purge_statistics(sname      IN VARCHAR2,
                             oname      IN VARCHAR2,
                             start_date IN DATE,
                             end_date   IN DATE);
  -- Purge the collected statistics for the given range of date in which
  -- conflicts were resolved. 
  -- Input Parameters:
  --   sname: The name of the schema containing the table to be replicated.
  --   oname: The name of the table being replicated.
  --   start_date: The start date of the given range.  If NULL, assume no
  --               start date.
  --   end_date: The end date of the given range.  If NULL, assume no end date.
  ---------------------------------------------------------------------------
  PROCEDURE register_statistics(sname IN VARCHAR2,
                                oname IN VARCHAR2);
  -- Enable the collection of conflict resolution statistics for the given
  -- replicated table.
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.
  --    oname: The name of the table being replicated.
  ---------------------------------------------------------------------------
  PROCEDURE cancel_statistics(sname IN VARCHAR2,
                              oname IN VARCHAR2);
  -- Cancel the collection of conflict resolution statistics for the given
  -- replicated table. 
  -- Input Parameters:
  --    sname: The name of the schema containing the table to be replicated.
  --    oname: The name of the table being replicated.
  ---------------------------------------------------------------------------
  procedure rename_shadow_column_group(sname  in VARCHAR2,
                                       oname  in VARCHAR2,
                                       new_col_group_name in VARCHAR2);
  -- renames shadow column group to a named column group
  -- Input Parameters:
  --    sname: the name of the schema containing the table 
  --    oname: the name of the table with the column group to be renamed
  ---------------------------------------------------------------------------
  PROCEDURE streams_migration (
    gnames        IN DBMS_UTILITY.NAME_ARRAY,
    file_location IN VARCHAR2,
    filename      IN VARCHAR2);
  -- This procedure is called at the masterdef site to generate a script
  -- that can be run at all the master sites in the repgroup to migrate
  -- repgroup from a repcat environment to the Streams environment.
  -- Input Parameters:
  --    gnames: A list of repgroup to be migrated from repcat to Streams env.
  --            It is a PL/SQL index-by table of type DBMS_UTILITY.NAME_ARRAY,
  --            the index must be 1-based, increasing, dense, and need not
  --            be terminated by a NULL. The repgroups listed in gnames
  --            must have exactly the same masters.
  --    file_location: location of the generated script
  --    filename: name of the generated script
  ---------------------------------------------------------------------------
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
  PROCEDURE repcat_import_repschema;

  FUNCTION repcat_import_repschema_string RETURN VARCHAR2;

  PROCEDURE order_user_objects(owners  IN  dbms_repcat.varchar2s,
                               objects IN  dbms_repcat.varchar2s,
                               types   IN  dbms_repcat.varchar2s,
                               len     IN  BINARY_INTEGER,
                               indices OUT dbms_utility.number_array);
  
  PROCEDURE order_user_objects(owners  IN  VARCHAR2,
                               objects IN  VARCHAR2,
                               types   IN  VARCHAR2,
                               len     IN  BINARY_INTEGER,
                               indices OUT dbms_utility.number_array);

  PROCEDURE begin_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2);

  PROCEDURE begin_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    copy_fname IN VARCHAR2);
 
  PROCEDURE add_object_to_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    type IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE drop_object_from_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    type IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE add_columns_to_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    cname_list IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE add_columns_to_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    cname_table IN dbms_repcat.varchar2s,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE add_column_group_to_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    column_group IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE drop_columns_from_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    cname_list IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE drop_columns_from_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    cname_table IN dbms_repcat.varchar2s,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE drop_column_group_from_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    sname IN VARCHAR2,
    oname IN VARCHAR2,
    column_group IN VARCHAR2,
    defer_validate IN BOOLEAN := FALSE );

  PROCEDURE validate_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2 );

  PROCEDURE abort_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2 );

  PROCEDURE publish_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    skip_validate IN BOOLEAN := FALSE );

  PROCEDURE obsolete_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2);

  PROCEDURE purge_flavor_definition(
    gname IN VARCHAR2,
    fname IN VARCHAR2);

  PROCEDURE validate_for_local_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    gowner IN VARCHAR2 := 'PUBLIC' );

  PROCEDURE set_local_flavor(
    gname IN VARCHAR2,
    fname IN VARCHAR2,
    validate IN BOOLEAN := TRUE,
    gowner   IN VARCHAR2 := 'PUBLIC' );

  FUNCTION generate_flavor_name(
    gname IN VARCHAR2) RETURN VARCHAR2;


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
  PROCEDURE register_snapshot_repgroup(
    gname    IN VARCHAR2, 
    snapsite IN VARCHAR2, 
    comment  IN VARCHAR2 := NULL,
    rep_type IN NUMBER   := reg_unknown,
    fname    IN VARCHAR2 := NULL,
    gowner   IN VARCHAR2 := 'PUBLIC');

  PROCEDURE unregister_snapshot_repgroup(
    gname    IN VARCHAR2, 
    snapsite IN VARCHAR2,
    gowner   IN VARCHAR2 := 'PUBLIC');

  PROCEDURE comment_on_snapshot_repsites(
    gowner  IN VARCHAR2,
    gname   IN VARCHAR2,
    comment IN VARCHAR2);

  PROCEDURE create_snapshot_repgroup(
    gname            IN VARCHAR2,
    master           IN VARCHAR2,
    comment          IN VARCHAR2 := '',
    propagation_mode IN VARCHAR2 := 'ASYNCHRONOUS',
    fname            IN VARCHAR2 := NULL,
    gowner           IN VARCHAR2 := 'PUBLIC');

  PROCEDURE drop_snapshot_repgroup(
    gname         IN VARCHAR2,
    drop_contents IN BOOLEAN := FALSE,
    gowner        IN VARCHAR2 := 'PUBLIC');

  PROCEDURE refresh_snapshot_repgroup(
    gname                 IN VARCHAR2,
    drop_missing_contents IN BOOLEAN := FALSE,
    refresh_snapshots     IN BOOLEAN := FALSE,
    refresh_other_objects IN BOOLEAN := FALSE,
    gowner                IN VARCHAR2 := 'PUBLIC');

  PROCEDURE switch_snapshot_master(
    gname  IN VARCHAR2,
    master IN VARCHAR2,
    gowner IN VARCHAR2 := 'PUBLIC');

  PROCEDURE create_snapshot_repobject(
    sname             IN VARCHAR2,
    oname             IN VARCHAR2,
    type              IN VARCHAR2,
    ddl_text          IN VARCHAR2 := '',
    comment           IN VARCHAR2 := '',
    gname             IN VARCHAR2 := '',
    gen_objs_owner    IN VARCHAR2 := '',
    min_communication IN BOOLEAN  := TRUE,
    generate_80_compatible IN BOOLEAN := TRUE,
    gowner            IN VARCHAR2 := 'PUBLIC');

  PROCEDURE generate_snapshot_support(
    sname             IN VARCHAR2,
    oname             IN VARCHAR2,
    type              IN VARCHAR2,
    gen_objs_owner    IN VARCHAR2 := '',
    min_communication IN BOOLEAN := TRUE,
    generate_80_compatible IN BOOLEAN := TRUE);

  PROCEDURE drop_snapshot_repobject(
    sname        IN VARCHAR2,
    oname        IN VARCHAR2, 
    type         IN VARCHAR2, 
    drop_objects IN BOOLEAN := FALSE);

  PROCEDURE alter_snapshot_propagation(
    gname            IN VARCHAR2,
    propagation_mode IN VARCHAR2,
    comment          IN VARCHAR2 := '',
    gowner           IN VARCHAR2 := 'PUBLIC');

END dbms_repcat;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_repcat for dbms_repcat
/ 
GRANT EXECUTE ON dbms_repcat TO  execute_catalog_role
/
