Rem
Rem $Header: dbmshrmg.sql 24-may-2001.15:07:20 gviswana Exp $
Rem
Rem dbmshrmg.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 1997, 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmshrmg.sql - Header (package specification) of dbms_Repcat_MiG
Rem
Rem    DESCRIPTION
Rem      These procedures are called during migration of V7.3.x to V8.0.2
Rem      using the export/import utilities: the import utility will call it
Rem
Rem      These are private functions to be released in PL/SQL binary form.
Rem      These are procedures and functions that are shared by a snapshot
Rem      and master partitions.
Rem
Rem      Assumptions:
Rem        1. Only FULL database import is supported
Rem        2. The deferred RPC queue (def$_call) should be empty before
Rem           export it from 7.3.x
Rem
Rem    NOTES
Rem      See prvtbrmg.sql for its body.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01  - CREATE OR REPLACE SYNONYM
Rem    liwong      12/30/98  - Overload cleanup_import                         
Rem    liwong      07/18/97 -  add post_import
Rem    liwong      04/17/97 -  Fix after AQ integration
Rem    liwong      04/16/97 -  Add generate_recipient_key
Rem    liwong      03/24/97 -  Created
Rem

CREATE OR REPLACE PACKAGE dbms_repcat_mig AS 
  --
  -- Definitions
  --
 
  --- ==================================================================
  ---   procedures/functions will be called by others
  --- ==================================================================
  ----------------------------------------------------------------------
  --- NOTE: The following procedure is used by import/export to preserve
  ---       correctness of replication log information. If these
  ---       procedures are moved the following rules must be observed:
  ---       1) The new package must be publicly executable
  ---       2) Import/Export source code is modified to refresh change
  ----------------------------------------------------------------------
  --- After a V8 import, this procedure is called to clean up any V7
  --- replication objects (mlog$_%, triggers) that are needed to be
  --- modified
  PROCEDURE cleanup_import(dump_version IN NUMBER);

  ----------------------------------------------------------------------
  --- After a full replicated db import, this routine is invoked to
  --- do any necessary cleanup
  PROCEDURE cleanup_import(expseal IN VARCHAR2);

  ----------------------------------------------------------------------
  --- This routine is called before doing a full import of a database
  --- with replicated data
  PROCEDURE pre_import;

  ----------------------------------------------------------------------
  --- This routine is called after doing a full import of a database
  --- with replicated data
  PROCEDURE post_import;

END dbms_repcat_mig;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_repcat_mig FOR dbms_repcat_mig
/
 
GRANT EXECUTE ON dbms_repcat_mig TO IMP_FULL_DATABASE
/
