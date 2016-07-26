Rem
Rem $Header: catxdbpv.sql 02-jun-2006.10:52:28 rmurthy Exp $
Rem
Rem catxdbpv.sql
Rem
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbpv.sql - XDB Path View related Schema Objects
Rem
Rem    DESCRIPTION
Rem     This scripts contains the types, packages, views and triggers 
rem     required for the Path View
Rem
Rem    NOTES
Rem      This script should be run as "XDB"
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rmurthy     05/22/06 - remove extractvalue from path view
Rem    rmurthy     01/17/05 - add symbolic links 
Rem    rmurthy     01/10/05 - add link type to path view 
Rem    fge         07/28/03 - add resid tp path_view
Rem    athusoo     06/19/03 - Adding alias to resource_view query
Rem    fge         05/19/03 - move stats initialization to catxdbeo.sql
Rem    fge         05/07/03 - add stats schema registration
Rem    mkrishna    02/20/03 - invokers rights for path view
Rem    fge         09/05/02 - 
Rem    fge         09/04/02 - optimize path_view
Rem    njalali     07/31/02 - undo resid change
Rem    fge         07/09/02 - add resid to path_view
Rem    fge         02/04/02 - redefine path_view
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    sichandr    01/31/02 - fix path view query to use link name
Rem    sichandr    01/18/02 - fix path_view definition
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    spannala    12/13/01 - removin set echo on
Rem    nagarwal    11/15/01 - cast the path view def
Rem    nagarwal    11/05/01 - move path view schema to catxdbstd
Rem    nagarwal    10/31/01 - fix path view type definition
Rem    nagarwal    10/29/01 - grant privileges to path view
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    nagarwal    09/18/01 - Merged nagarwal_xdb_path_view
Rem    nagarwal    09/13/01 - add DML routines for path view
Rem    nagarwal    09/09/01 - PATH_VIEW definition
Rem    nagarwal    09/08/01 - Created
Rem

drop operator xdb.all_path force;

/*-----------------------------------------------------------------------*/
/*  LIBRARY                                                              */
/*-----------------------------------------------------------------------*/
-- the path_view_lib is created in catxdbr.sql

/*------------------------------------------------------------------------*/
/*  OPERATORS                                                             */
/*------------------------------------------------------------------------*/
-- ancillary operator
create operator xdb.all_path binding (number) return xdb.path_array ancillary to 
  xdb.under_path(sys.xmltype, number, varchar2),
  xdb.under_path(sys.xmltype, varchar2)
 without column data
using xdb_ancop.allpath_func;

grant execute on xdb.all_path to public;
create or replace public synonym all_path for xdb.all_path;

/*------------------------------------------------------------------------*/
/*  XMLTYPE VIEW & PATH VIEW                                              */
/*------------------------------------------------------------------------*/
create or replace view xdb.path_view as
  select /*+ ORDERED */ t2.path path, t.res res,
      xmltype.createxml(xdb.xdb_link_type(NULL, r2.xmldata.dispname, t.name,
                        h.name, h.flags, h.parent_oid, h.child_oid, 
                        decode(bitand(sys_op_rawtonum(h.flags), 1024), 1024, 
                              xdb.xdb$enum_t(hextoraw('01')), 
                              decode(bitand(sys_op_rawtonum(h.flags), 512), 512, 
                                xdb.xdb$enum_t(hextoraw('02')), 
                                xdb.xdb$enum_t(hextoraw('00'))))), 
                   'http://xmlns.oracle.com/xdb/XDBStandard.xsd', 'LINK') link,
      t.resid
  from  ( select xdb.all_path(9999) paths, value(p) res, p.sys_nc_oid$ resid,
          decode(bitand(sys_op_rawtonum(p.xmldata.flags), 8388608), 8388608, 
                 utl_raw.cast_to_varchar2(dbms_lob.substr(p.xmldata.xmllob, 4000)),
                 p.xmldata.dispname) name
          from xdb.xdb$resource p
          where xdb.under_path(value(p), '/', 9999)=1 ) t,
        TABLE( cast (t.paths as xdb.path_array) ) t2,
        xdb.xdb$h_link h, xdb.xdb$resource r2
   where t2.parent_oid = h.parent_oid and t2.childname = h.name and
         t2.parent_oid = r2.sys_nc_oid$;

show errors;
create or replace public synonym path_view for xdb.path_view;
grant select on xdb.path_view to public ; 
grant insert on xdb.path_view to public ; 
grant delete on xdb.path_view to public ; 
grant update on xdb.path_view to public ; 

/*-----------------------------------------------------------------------*/
/* PACKAGES and FUNCTIONS for instead-of trigger                         */
/*-----------------------------------------------------------------------*/

create or replace package xdb.XDB_PVTRIG_PKG  authid current_user AS 

  procedure pvtrig_ins(res sys.xmltype, link sys.xmltype, path varchar2) 
   is language C name "INSERT_XDBPV" 
   library xdb.PATH_VIEW_LIB
   with context 
   parameters (
    context, 
    res, res INDICATOR, 
    link, link INDICATOR,
    path, path INDICATOR, path LENGTH);

  procedure pvtrig_del(res sys.xmltype, link sys.xmltype, path varchar2)
   is language C name "DELETE_XDBPV" 
   library xdb.PATH_VIEW_LIB
   with context 
   parameters (
    context, 
    res, res INDICATOR, 
    link, link INDICATOR,
    path, path INDICATOR, path LENGTH );

  procedure pvtrig_upd(o_res sys.xmltype, n_res sys.xmltype, 
                       o_link sys.xmltype, n_link sys.xmltype, 
                       o_path varchar2, n_path varchar2)
   is language C name "UPDATE_XDBPV" 
   library xdb.PATH_VIEW_LIB
   with context 
   parameters (
    context, 
    o_res, o_res INDICATOR, n_res, n_res INDICATOR,
    o_link, o_link INDICATOR, n_link, n_link INDICATOR,
    o_path, o_path INDICATOR, o_path LENGTH,
    n_path, n_path INDICATOR, n_path LENGTH);

end XDB_PVTRIG_PKG;
/
show errors;

create or replace public synonym xdb_pvtrig_pkg for xdb.xdb_pvtrig_pkg;

grant execute on xdb.xdb_pvtrig_pkg to public;


/*-----------------------------------------------------------------------*/
/*  INSTEAD-OF TRIGGER                                                   */
/*-----------------------------------------------------------------------*/
create or replace trigger xdb.xdb_pv_trig INSTEAD OF insert or delete or update
on xdb.path_view for each row 
begin 
  if inserting then 
    xdb.xdb_pvtrig_pkg.pvtrig_ins(:new.res, :new.link, :new.path);

    /* check that either the REF or the BLOB columns are filled, not both */
  end if;

  if deleting then 
     xdb.xdb_pvtrig_pkg.pvtrig_del(:old.res, :old.link, :old.path);

    /* check if we get the correct values from two tables in a view */
  end if;

  if updating then 
     xdb.xdb_pvtrig_pkg.pvtrig_upd(:old.res,    :new.res,
                               :old.link,   :new.link,
                               :old.path,   :new.path );
  end if;
end;
/
show errors;

