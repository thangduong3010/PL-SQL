Rem
Rem $Header: catxdbr.sql 17-aug-2007.14:07:15 smalde Exp $
Rem
Rem catxdbr.sql
Rem
Rem Copyright (c) 2001, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbr.sql - XDB Resource View related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the views, packages, index types, operators and 
Rem     indexes required for providing SQL access to resource data.
Rem
Rem    NOTES
Rem      This script should be run as "XDB".
Rem
Rem    TODO: Support ACLs in functional implementation of prim oper
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smalde      08/17/07 - Bug 6344412: Change 9999 to 8888
Rem    fge         11/01/04 - move implementation to prvtxdr0.sql 
Rem    spannala    05/19/04 - make sure the types and indexes are valid 
Rem    fge         07/28/03 - add resid to resource_view
Rem    spannala    07/29/03 - change xdbhi_idxtyp creation
Rem    njalali     07/31/03 - recompiling xdb.xdbhi_im type after drop type
Rem    najain      07/29/03 - add ODCIIndexAlter for xdbhi_idx
Rem    fge         05/19/03 - move stats initialization to catxdbeo.sql
Rem    fge         03/05/03 - support xdb repository view cost model
Rem    mkrishna    02/17/03 - make prvt invokers rights
Rem    fge         01/16/03 - add WITH CURRENT_USER to xdbhi_idxtyp creation
Rem    fge         09/27/02 - forward merge fix of bug 2540212 from 9.2.0.2
Rem    fge         09/18/02 - add authid current_user to xdbhi_im/xdb_funcimpl
Rem    fge         09/04/02 - optimize path_view
Rem    varora      08/26/02 - change scanctx in xdbhi_im to raw 8
Rem    njalali     07/31/02 - undo resid change
Rem    fge         07/09/02 - add resid to resource_view
Rem    fge         05/21/02 - add ancillary operator abspath
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    fge         01/21/02 - move implementation to prvtxdbr.sql
Rem    sichandr    01/17/02 - grant execute on xdb.path_array
Rem    ayoaz       01/10/02 - specify without dml option for xdbhi_idxtyp
Rem    spannala    12/27/01 - xdb setup should run as sys
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    spannala    12/13/01 - removing connect
Rem    nagarwal    11/05/01 - grant DML privileges to resource view
Rem    nagarwal    11/08/01 - invoke prvtxdbpi
Rem    tsingh      11/17/01 - remove connection string
Rem    vnimani     10/01/01 - add contentschemais function
Rem    nle         09/20/01 - move versioning package
Rem    nagarwal    09/12/01 - add catxdbvr.sql
Rem    nagarwal    09/08/01 - add PATH VIEW definition
Rem    nagarwal    09/05/01 - privileges fix
Rem    nagarwal    08/29/01 - add support for ALL_PATH operator
Rem    nagarwal    08/22/01 - functional implementation for EQUALS_PATH operator
Rem    nagarwal    08/14/01 - grant priv on indextype
Rem    nagarwal    08/03/01 - add without column data to indextype
Rem    nagarwal    07/26/01 - changes wrt resource->xmltype
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    nagarwal    05/20/01 - overload operators
Rem    nagarwal    04/30/01 - Support for DML on resource view
Rem    nagarwal    04/24/01 - Add functional implementation for operators
Rem    nagarwal    04/15/01 - Add start, fetch, close routines for ext idx
Rem    nagarwal    04/03/01 - Created
Rem



/*------------------------------------------------------------------------*/
/*  OPERATORS and INDEXTYPES                                              */
/*------------------------------------------------------------------------*/
-- primary operator 
create operator xdb.under_path binding
  (sys.xmltype, number, varchar2) return number with index context, 
    scan context xdb.xdbhi_im compute ancillary data 
    without column data using XDB.XDB_FUNCIMPL.under_path_func,
  (sys.xmltype, varchar2) return number with index context, 
    scan context xdb.xdbhi_im compute ancillary data 
    without column data using XDB.XDB_FUNCIMPL.under_path_func1;

create operator xdb.equals_path binding 
  (sys.xmltype, varchar2) return number with index context, 
    scan context xdb.xdbhi_im compute ancillary data 
    without column data using XDB.XDB_FUNCIMPL.equal_path_func;

grant execute on xdb.under_path to public;
grant execute on xdb.equals_path to public;
create or replace public synonym under_path for xdb.under_path;
create or replace public synonym equals_path for xdb.equals_path;

-- ancillary operators
create operator xdb.path binding (number) return varchar2 ancillary to 
  xdb.under_path(sys.xmltype, number, varchar2),
  xdb.under_path(sys.xmltype, varchar2)
 without column data
using xdb.xdb_ancop.path_func;

create operator xdb.depth binding (number) return number ancillary to 
  xdb.under_path(sys.xmltype, varchar2),
  xdb.under_path(sys.xmltype, number, varchar2)
using xdb.xdb_ancop.depth_func;

create operator xdb.abspath binding (number) return varchar2 ancillary to 
  xdb.under_path(sys.xmltype, number, varchar2),
  xdb.under_path(sys.xmltype, varchar2)
 without column data
using xdb.xdb_ancop.abspath_func;

grant execute on xdb.path to public;
create or replace public synonym path for xdb.path;
grant execute on xdb.depth to public;
create or replace public synonym depth for xdb.depth;
grant execute on xdb.abspath to public;
create or replace public synonym abspath for xdb.abspath;

-- indextype 
create or replace indextype xdb.xdbhi_idxtyp for 
  xdb.under_path(sys.xmltype, number, varchar2),
  xdb.under_path(sys.xmltype, varchar2),
  xdb.equals_path(sys.xmltype, varchar2)
  using xdb.xdbhi_im without dml
  with current_user;

--  using xdb.xdbhi_im   without column data;
grant execute on xdb.xdbhi_idxtyp to public;

/*------------------------------------------------------------------------*/
/*  INDEXES                                                               */
/*------------------------------------------------------------------------*/
create index xdb.xdbhi_idx on xdb.xdb$resource p (value(p)) indextype is xdb.xdbhi_idxtyp;

/*-----------------------------------------------------------------------*/
/*  VIEWS                                                                */
/*-----------------------------------------------------------------------*/
create or replace view xdb.resource_view as 
  select value(p) res, abspath(8888) any_path, sys_nc_oid$ resid
  from xdb.xdb$resource p 
  where under_path(value(p), '/', 8888) = 1 ;


show errors;
create or replace public synonym resource_view for xdb.resource_view;
grant select on xdb.resource_view to public ; 
grant insert on xdb.resource_view to public;
grant delete on xdb.resource_view to public;
grant update on xdb.resource_view to public;

