Rem
Rem $Header: rdbms/admin/catxdbs.sql /st_rdbms_11.2.0/2 2011/03/02 08:25:02 spetride Exp $
Rem
Rem catxdbs.sql
Rem
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbs.sql - XDB Schema related types and tables
Rem
Rem    DESCRIPTION
Rem      This script creates the types, tables, etc required for 
Rem      XDB Schema i.e. the schema for schemas.
Rem
Rem    NOTES
Rem      This script should be run as the user "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ckavoor     11/02/09 - 2123504: Adding 'show errors'
Rem    mkandarp    06/11/09 - 8571751 : increase maxval for xdb$namesuff_seq
Rem    bhammers    02/01/09 - add indexes to xdb.xdb$element
Rem    mrafiq      01/23/07 - fix for bug 4870624: increase size of
Rem                           XDB$RAW_LIST_T
Rem    sichandr    05/29/07 - initialize typeID sequence from 100
Rem    nkandalu    02/08/07 - 3010822: Increase length of version
Rem    smalde      02/16/06 - Translations
Rem    abagrawa    10/05/05 - Add sqltype to simpletype 
Rem    abagrawa    09/29/05 - Add typeID 
Rem    njalali     02/13/03 - moved final_info to end of simpleType
Rem    abagrawa    01/15/03 - Fix simpletype - remove abstract, add final
Rem    abagrawa    12/11/02 - increase size of facet_list_t
Rem    sidicula    09/25/02 - Public synonym for xdb$string_list_t
Rem    sichandr    07/31/02 - rename simplecontent to simplecont
Rem    sichandr    07/19/02 - add simpleContent types
Rem    abagrawa    05/28/02 - Add ID attribute to facets
Rem    nmontoya    06/27/02 - GRANT SELECT ON xdb.xdb$namesuff_seq TO PUBLIC 
Rem    rmurthy     03/15/02 - add notation, unique, key, keyref
Rem    sichandr    02/01/02 - increase varray size
Rem    bkhaladk    01/24/02 - enable grant selects for client side issues.
Rem    spannala    01/08/02 - incorporating fge_caxdb_priv_indx_fix
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    rmurthy     12/27/01 - remove userPrivilege and add defaultXSL
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    njalali     12/04/01 - transient properties
Rem    rmurthy     12/07/01 - add PD columns to all types
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    sichandr    11/28/01 - create indexes
Rem    sichandr    10/31/01 - add ID attribute
Rem    rmurthy     09/13/01 - change documentation/appinfo to mixed types
Rem    sichandr    09/18/01 - support storeVarrayAsTable
Rem    rmurthy     08/26/01 - add support for substitutionGroup, named group
Rem    rmurthy     08/03/01 - support for inheritance
Rem    njalali     07/13/01 - removed resources from this file
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    rmurthy     06/01/01 - add include/import support
Rem    spannala    05/18/01 - xmltype_p -> xmltype
Rem    rmurthy     05/09/01 - remove conn stmt
Rem    rmurthy     05/04/01 - annotation, appinfo, documentation
Rem    rmurthy     04/20/01 - support for any, anyAttribute
Rem    njalali     04/06/01 - made RAW pos. desc. into a VARRAY of RAW
Rem    rmurthy     03/27/01 - support for list and union simpletypes
Rem    rmurthy     03/27/01 - add use,value attrs for attribute
Rem    rmurthy     03/09/01 - major changes for new xml schemas
Rem    rmurthy     02/14/01 - Created
Rem

/* ------------------------------------------------------------------- */
/*                   MISC TYPES                                        */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$xmltype_ref_list_t 
 OID '00000000000000000000000000020120'as varray(2147483647) of ref sys.xmltype;
/
show errors;

/* Qualified Name (QName) */
create or replace type xdb.xdb$qname OID '00000000000000000000000000020121' 
as object
(
    prefix_code     raw(4), /* Index into schema extras */
    name            varchar2(2000)
);
/
show errors;

create type xdb.xdb$string_list_t OID '00000000000000000000000000020122' 
as VARRAY(2147483647) of varchar2(4000);
/

create or replace public synonym xdb$string_list_t for xdb.xdb$string_list_t;

create or replace type xdb.xdb$raw_list_t OID '00000000000000000000000000020123'
as varray(2147483647) of raw(2000);
/
show errors;

/* ------------------------------------------------------------------- */
/*                   ENUM TYPES                                        */   
/* ------------------------------------------------------------------- */

/* generic ENUM type if number of values <= UB1MAXVAL */

create or replace type xdb.xdb$enum_t OID '00000000000000000000000000020124'
as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* generic ENUM type if number of values > UB1MAXVAL */

create or replace type xdb.xdb$enum2_t OID '00000000000000000000000000020125'
as object
(
    value       raw(2),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* Note that more enum possibilities will overflow max contiguous 
   allocation size in shared memory */
create type xdb.xdb$enum_values_t OID '00000000000000000000000000020126'
as VARRAY(1000) of varchar2(1024);
/

/*
* Later will inherit from xdb.xdb$enum
*/
create or replace type xdb.xdb$derivationChoice 
OID '00000000000000000000000000020127' as object
(
    value       raw(2),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

create or replace type xdb.xdb$formChoice OID '00000000000000000000000000020128'
as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

create or replace type xdb.xdb$whitespaceChoice OID
'00000000000000000000000000020129' as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

create or replace type xdb.xdb$javatype OID '0000000000000000000000000002012A'
as object
(
    value       raw(2),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* USE CHOICE - used within attributes */
create or replace type xdb.xdb$useChoice OID '0000000000000000000000000002012B'
as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* PROCESS CHOICE - used within any and anyAttribute */
create or replace type xdb.xdb$processChoice OID
'0000000000000000000000000002012C' as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* Transient CHOICE - used within attribute/element */
create or replace type xdb.xdb$transientChoice OID
'0000000000000000000000000002012D' as object
(
    value       raw(1),

member function lookupValue RETURN VARCHAR2,
       pragma restrict_references (lookupValue, wnds, wnps, rnps, rnds),
member procedure setValue(val IN VARCHAR2),
       pragma restrict_references (setValue, wnds, wnps, rnps, rnds)
);
/
show errors;

/* ------------------------------------------------------------------- */
/*                  ANNOTATION RELATED TYPES                           */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$appinfo_t OID '00000000000000000000000000020133'
as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  anypart         varchar2(4000),
  source          varchar2(4000)
)  
/
show errors;

create or replace type xdb.xdb$appinfo_list_t OID
'00000000000000000000000000020134' as varray(1000) of xdb.xdb$appinfo_t;
/
show errors;

create or replace type xdb.xdb$documentation_t OID
'00000000000000000000000000020135' as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  anypart         varchar2(4000),
  source          varchar2(4000),
  lang            varchar2(4000)
)
/
show errors;

create or replace type xdb.xdb$documentation_list_t OID
'00000000000000000000000000020136'
  as varray(1000) of xdb.xdb$documentation_t;
/
show errors;

create or replace type xdb.xdb$annotation_t OID
'00000000000000000000000000020137' as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  appinfo         xdb.xdb$appinfo_list_t,
  documentation   xdb.xdb$documentation_list_t
)
/  
show errors;

create or replace type xdb.xdb$annotation_list_t OID
'00000000000000000000000000020138' as 
   varray(65535) of xdb.xdb$annotation_t;
/
show errors;

/* ------------------------------------------------------------------- */
/*                   FACET TYPES                                       */   
/* ------------------------------------------------------------------- */

/* String facet type */
create or replace type xdb.xdb$facet_t OID '0000000000000000000000000002012E' 
as object                 /* String Facet */
(
   sys_xdbpd$       xdb.xdb$raw_list_t,
   annotation       xdb.xdb$annotation_t,
   value            varchar2(2000),
   fixed            raw(1),
   id               varchar2(256)
)
/
show errors;

create type xdb.xdb$facet_list_t OID '0000000000000000000000000002012F' as
VARRAY(65535) of xdb.xdb$facet_t;
/

create or replace type xdb.xdb$numfacet_t OID '00000000000000000000000000020130'
as object              /* Number Facet */
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    annotation      xdb.xdb$annotation_t,
    value           integer,
    fixed           raw(1),
    id              varchar2(256)
)
/
show errors;

create or replace type xdb.xdb$timefacet_t OID
'00000000000000000000000000020131' as object               /* Time Facet */
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    annotation      xdb.xdb$annotation_t,
    value           date,
    fixed           raw(1),
    id              varchar2(256)
)
/
show errors;

create or replace type xdb.xdb$whitespace_t OID
'00000000000000000000000000020132' as object        /* Whitespace facet */
(
    sys_xdbpd$  xdb.xdb$raw_list_t,
    annotation  xdb.xdb$annotation_t,
    value       xdb.xdb$whitespaceChoice,
    fixed       raw(1),
    id          varchar2(256)
);
/
show errors;

/* Forward reference */
create or replace type xdb.xdb$element_t OID '00000000000000000000000000020146';
/
show errors;

/* Forward reference */
create or replace type xdb.xdb$schema_t OID '0000000000000000000000000002014D';
/
show errors;

/* ------------------------------------------------------------------- */
/*                  NOTATION RELATED TYPES                             */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$notation_t
OID '00000000000000000000000000020155'
as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  annotation      xdb.xdb$annotation_t,
  name            varchar2(2000),                    /* name of the notation */
  publicval       varchar2(4000),
  system          varchar2(4000)
)
/
show errors;

create or replace type xdb.xdb$notation_list_t
OID '00000000000000000000000000020156'
as varray(1000) of xdb.xdb$notation_t
/
show errors;

/* ------------------------------------------------------------------- */
/*              UNIQUE/KEY/KEYREF RELATED TYPES                        */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$xpathspec_t
OID '00000000000000000000000000020157'
as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  annotation      xdb.xdb$annotation_t,
  xpath           varchar2(4000)
)
/
show errors;

create or replace type xdb.xdb$xpathspec_list_t
OID '00000000000000000000000000020158'
as varray(1000) of xdb.xdb$xpathspec_t
/
show errors;

create or replace type xdb.xdb$keybase_t
OID '00000000000000000000000000020159'
as object
(
  sys_xdbpd$      xdb.xdb$raw_list_t,
  annotation      xdb.xdb$annotation_t,
  name            varchar2(1000),               /* name of unique/key/keyref */
  refer           xdb.xdb$qname,             /* applicable ONLY for "keyref" */
  selector        xdb.xdb$xpathspec_t,
  fields          xdb.xdb$xpathspec_list_t
)
/
show errors;

create or replace type xdb.xdb$keybase_list_t
OID '0000000000000000000000000002015A'
as varray(1000) of xdb.xdb$keybase_t
/
show errors;

/* ------------------------------------------------------------------- */
/*                   SIMPLETYPE RELATED TYPES                          */   
/* ------------------------------------------------------------------- */

/* LIST type */
create or replace type xdb.xdb$list_t OID '00000000000000000000000000020139' as
object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    annotation      xdb.xdb$annotation_t,
    item_type       xdb.xdb$qname,                               /* item of list */
    type_ref        ref sys.xmltype,          /* LATER - ref to list item type */
    simple_type     ref sys.xmltype            /* locally declared simple type */
)
/
show errors;

/* UNION type */
create or replace type xdb.xdb$union_t OID '0000000000000000000000000002013A' as
object
(
    sys_xdbpd$         xdb.xdb$raw_list_t,
    annotation      xdb.xdb$annotation_t,
    member_types       varchar2(4000),                 /* members of union */
    simple_types       xdb.xdb$xmltype_ref_list_t,       /* local simple types */

    /* LATER - refs to all constituents of the union type */
    type_refs          xdb.xdb$xmltype_ref_list_t
)
/
show errors;

/* SIMPLE DERIVATION type */
create or replace type xdb.xdb$simple_derivation_t OID
'0000000000000000000000000002013B' AS OBJECT
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    base_type       ref sys.xmltype,
    base            xdb.xdb$qname,
    lcl_smpl_decl   ref sys.xmltype,        /* locally declared simple type */   

    /* Facets */
    fractiondigits  xdb.xdb$numfacet_t,
    totaldigits     xdb.xdb$numfacet_t,
    minlength       xdb.xdb$numfacet_t,
    maxlength       xdb.xdb$numfacet_t,
    length          xdb.xdb$numfacet_t,
    whitespace      xdb.xdb$whitespace_t,
    period          xdb.xdb$timefacet_t,
    duration        xdb.xdb$timefacet_t,
    min_inclusive   xdb.xdb$facet_t,
    max_inclusive   xdb.xdb$facet_t,
    min_exclusive   xdb.xdb$facet_t,
    max_exclusive   xdb.xdb$facet_t,
    pattern         xdb.xdb$facet_list_t,
    enumeration     xdb.xdb$facet_list_t,
    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
);
/ 
show errors;

create or replace type xdb.xdb$simple_t OID '0000000000000000000000000002013C'
AS OBJECT
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    /* Note that name does not need to be a QName since its namespace
    must always equal the target namespace for the schema */
    name            varchar2(256),
    abstract        raw(1),   /* boolean, obsoleted */
    /* Only one of the foll. fields is non-null */
    restriction     xdb.xdb$simple_derivation_t,
    list_type       xdb.xdb$list_t,
    union_type      xdb.xdb$union_t,

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256),
    final_info      xdb.xdb$derivationChoice,
    typeid          integer,
    sqltype         varchar2(30)
);
/ 
show errors;

/* ------------------------------------------------------------------- */
/*                  GROUP RELATED TYPES                                */   
/* ------------------------------------------------------------------- */

/* Group (of elements) definition type */
create or replace type xdb.xdb$group_def_t OID
'0000000000000000000000000002013D' as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    name            varchar2(2000),                /* name of the group */
    /* 
     * only one of the foll. can be non-null
     */
    all_kid         ref sys.xmltype,
    choice_kid      ref sys.xmltype,
    sequence_kid    ref sys.xmltype,

    annotation      xdb.xdb$annotation_t, 
    id              varchar2(256)
)
/
show errors;

/* Group reference type */
create or replace type xdb.xdb$group_ref_t OID
'0000000000000000000000000002013E' as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    min_occurs      integer,
    max_occurs      varchar2(20), /* in string format incl. "unbounded" */

    groupref_name   xdb.xdb$qname,       /* name of the group being referenced */
    groupref_ref    ref sys.xmltype,   /* REF of the group being referenced */

    annotation      xdb.xdb$annotation_t, 
    id              varchar2(256)
)
/
show errors;

/* Attribute Group definition type */
create or replace type xdb.xdb$attrgroup_def_t OID
'0000000000000000000000000002013F' as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    name            varchar2(2000),               /* name of the attr group */

    attributes      xdb.xdb$xmltype_ref_list_t,  /* list of attrs within group */
    any_attrs       xdb.xdb$xmltype_ref_list_t,  /* list of anyAttribute decls. */
    attr_groups     xdb.xdb$xmltype_ref_list_t,          /* list of attr groups */

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/
show errors;

/* Attribute Group reference type */
create or replace type xdb.xdb$attrgroup_ref_t OID
'00000000000000000000000000020140' as object 
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,

    attrgroup_name  xdb.xdb$qname,   /* name of the attribute group being ref-ed */
    attrgroup_ref   ref sys.xmltype,   /* ref of the attr group being ref-ed */

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/
show errors;

/* ------------------------------------------------------------------- */
/*                   COMPLEXTYPE RELATED TYPES                         */   
/* ------------------------------------------------------------------- */

/* MODEL TYPE 
 *  This type is used as the common type for the following elements : 
 *   - all
 *   - choice 
 *   - sequence
*/
create type xdb.xdb$model_t OID '00000000000000000000000000020141';
/
create or replace type xdb.xdb$model_t OID '00000000000000000000000000020141' as
object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    min_occurs      integer,
    max_occurs      varchar2(20), /* in string format incl. "unbounded" */

    elements        xdb.xdb$xmltype_ref_list_t,
    choice_kids     xdb.xdb$xmltype_ref_list_t,
    sequence_kids   xdb.xdb$xmltype_ref_list_t,
    anys            xdb.xdb$xmltype_ref_list_t,
    groups          xdb.xdb$xmltype_ref_list_t,

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/
show errors;

/* COMPLEX DERIVATION TYPE */
create or replace type xdb.xdb$complex_derivation_t OID
'00000000000000000000000000020142' as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    base            xdb.xdb$qname,
    
    attributes      xdb.xdb$xmltype_ref_list_t,
    any_attrs       xdb.xdb$xmltype_ref_list_t,
    attr_groups     xdb.xdb$xmltype_ref_list_t,

    /* 
     * only one of the foll. can be non-null
     */
    all_kid         ref sys.xmltype,
    choice_kid      ref sys.xmltype,
    sequence_kid    ref sys.xmltype,
    group_kid       ref sys.xmltype,

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/
show errors;

/* CONTENT TYPE */
create or replace type xdb.xdb$content_t OID '00000000000000000000000000020143'
as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    mixed           raw(1),

    /* only one of the foll. can be non-null */    
    restriction     xdb.xdb$complex_derivation_t,
    extension       xdb.xdb$complex_derivation_t,

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/  
show errors;

/* SIMPLECONT_RES type */
create or replace type xdb.xdb$simplecont_res_t OID
'0000000000000000000000000002015B' AS OBJECT
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    base            xdb.xdb$qname,
    id              varchar2(256),
    lcl_smpl_decl   ref sys.xmltype,        /* locally declared simple type */   
    attributes      xdb.xdb$xmltype_ref_list_t,
    any_attrs       xdb.xdb$xmltype_ref_list_t,
    attr_groups     xdb.xdb$xmltype_ref_list_t,
    annotation      xdb.xdb$annotation_t,

    /* Facets */
    fractiondigits  xdb.xdb$numfacet_t,
    totaldigits     xdb.xdb$numfacet_t,
    minlength       xdb.xdb$numfacet_t,
    maxlength       xdb.xdb$numfacet_t,
    whitespace      xdb.xdb$whitespace_t,
    period          xdb.xdb$timefacet_t,
    duration        xdb.xdb$timefacet_t,
    min_inclusive   xdb.xdb$facet_t,
    max_inclusive   xdb.xdb$facet_t,
    pattern         xdb.xdb$facet_list_t,
    enumeration     xdb.xdb$facet_list_t,
    min_exclusive   xdb.xdb$facet_t,
    max_exclusive   xdb.xdb$facet_t,
    length          xdb.xdb$numfacet_t
);
/ 
show errors;

/* SIMPLECONT_EXT TYPE */
create or replace type xdb.xdb$simplecont_ext_t OID
'0000000000000000000000000002015C' as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    base            xdb.xdb$qname,
    id              varchar2(256),
    
    attributes      xdb.xdb$xmltype_ref_list_t,
    any_attrs       xdb.xdb$xmltype_ref_list_t,
    attr_groups     xdb.xdb$xmltype_ref_list_t,
    annotation      xdb.xdb$annotation_t
)
/
show errors;

/* SIMPLECONTENT TYPE */
create or replace type xdb.xdb$simplecontent_t OID '0000000000000000000000000002015D'
as object
(
    sys_xdbpd$      xdb.xdb$raw_list_t,

    /* only one of the foll. can be non-null */    
    restriction     xdb.xdb$simplecont_res_t,
    extension       xdb.xdb$simplecont_ext_t,

    annotation      xdb.xdb$annotation_t,
    id              varchar2(256)
)
/  
show errors;

/* COMPLEX TYPE */
create or replace type xdb.xdb$complex_t OID '00000000000000000000000000020144'
AS OBJECT
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    base_type       ref sys.xmltype,      /* applicable for derived types */
    name            varchar2(256),
    abstract        raw(1), 
    mixed           raw(1),
    final_info      xdb.xdb$derivationChoice,
    block           xdb.xdb$derivationChoice,

    attributes      xdb.xdb$xmltype_ref_list_t,
    any_attrs       xdb.xdb$xmltype_ref_list_t,
    attr_groups     xdb.xdb$xmltype_ref_list_t, 

    /* 
     * only one of the foll. can be non-null, else all have to be null.
     */
    all_kid         ref sys.xmltype,
    choice_kid      ref sys.xmltype,
    sequence_kid    ref sys.xmltype,
    group_kid       ref sys.xmltype,

    complexcontent  xdb.xdb$content_t,

    annotation      xdb.xdb$annotation_t,

    sqltype         varchar2(30),                 /* Name of corr. SQL type */
    sqlschema       varchar2(30),     /* Name of schema containing SQL type */
    maintain_dom    raw(1), 
    subtype_refs    xdb.xdb$xmltype_ref_list_t,     /* List of refs to subtypes */
    id              varchar2(256),
    simplecont      xdb.xdb$simplecontent_t,
    typeid          integer
);
/
show errors;

/* ------------------------------------------------------------------- */
/*                   ATTRIBUTE RELATED TYPES                           */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$property_t OID '00000000000000000000000000020145'
AS OBJECT
(
    sys_xdbpd$      xdb.xdb$raw_list_t,
    parent_schema   ref sys.xmltype,
    prop_number     integer,
    /* Note that name does not need to be a QName since its namespace
    must always equal the target namespace for the schema */
    name            varchar2(256),
    typename        xdb.xdb$qname,
    mem_byte_length raw(2),       /* buffer size--NULL for variable size*/
    mem_type_code   raw(2),
    system          raw(1),
    mutable         raw(1),
    form            xdb.xdb$formChoice,          /* form choice - qualified/not */
    sqlname         varchar2(30),
    sqltype         varchar2(30), 
    sqlschema       varchar2(30),                                    
    java_type       xdb.xdb$javatype,
    default_value   varchar2(4000),
    smpl_type_decl  ref sys.xmltype,          /* Locally declared type */
    type_ref        ref sys.xmltype,          /* Globally declared type */
    /* The following two fields are relevant if the attr/element is defined 
     * by a ref to a global attr/element
     */
    propref_name    xdb.xdb$qname,               /* name of global attr/element */
    propref_ref     ref sys.xmltype,           /* REF of global attr/element */
    attr_use        xdb.xdb$useChoice,             /* only applicable for attrs */
    fixed_value     varchar2(2000),
    global          raw(1),     /* TRUE for global attr/element declarations */
    annotation      xdb.xdb$annotation_t,
    sqlcolltype     varchar2(30),                   /* collection type name */
    sqlcollschema   varchar2(30),
    hidden          raw(1),
    transient       xdb.xdb$transientChoice,    /* = none/generated/manifested ? */
    id              varchar2(256),
    baseprop        raw(1) /* are there generated props based on this prop ? */
);
/
show errors;

/* ------------------------------------------------------------------- */
/*                   ELEMENT RELATED TYPES                             */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$element_t OID '00000000000000000000000000020146'
as object
(
    property        xdb.xdb$property_t,
    subs_group      xdb.xdb$qname,
    num_cols        integer,
    nillable        raw(1),
    final_info      xdb.xdb$derivationChoice,
    block           xdb.xdb$derivationChoice,
    abstract        raw(1),
/* XDB extensions */
    mem_inline      raw(1),
    sql_inline      raw(1),
    java_inline     raw(1),
    maintain_dom    raw(1),
    default_table   varchar2(30),
    default_table_schema   varchar2(30), 
    table_props     varchar2(2000),              /* table properties string */
    java_classname  varchar2(2000),
    bean_classname  varchar2(2000),
    base_sqlname    varchar2(61),
    cplx_type_decl  ref sys.xmltype,
    subs_group_refs xdb.xdb$xmltype_ref_list_t, /* REFs to all elements for which 
                                             * this is the head element 
                                             */
    default_xsl     varchar2(2000),     /* URL of default XSL to be applied */
    min_occurs      integer,
    max_occurs      varchar2(20),     /* in string format incl. "unbounded" */
    is_folder       raw(1),
    maintain_order  raw(1),
    col_props       varchar2(2000),             /* column properties string */
    default_acl     varchar2(2000),                   /* URL of default ACL */
    head_elem_ref  ref sys.xmltype,    /* REF to head element of subs. group */
    uniques        xdb.xdb$keybase_list_t,
    keys           xdb.xdb$keybase_list_t,
    keyrefs        xdb.xdb$keybase_list_t,
    is_translatable raw(1),                  /* Is this element translatable */
    xdb_max_occurs  varchar2(20)                            /* xdb:maxOccurs */
);
/
show errors;

/* ------------------------------------------------------------------- */
/*                  ANY RELATED TYPES                                  */   
/* ------------------------------------------------------------------- */

/* type used for both any and anyAttribute elements */
create type xdb.xdb$any_t OID '00000000000000000000000000020147' as object
(
  property         xdb.xdb$property_t,
  namespace        varchar2(2000),
  process_contents xdb.xdb$processChoice,
  min_occurs       integer,
  max_occurs       varchar2(20)   /* in string format incl. "unbounded" */
)
/

/* ------------------------------------------------------------------- */
/*                 INCLUDE/IMPORT RELATED TYPES                        */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$include_t OID '00000000000000000000000000020148'
as object
(
    sys_xdbpd$          xdb.xdb$raw_list_t,
    schema_location     varchar2(700),
    annotation          xdb.xdb$annotation_t,
    id                  varchar2(256)
);
/
show errors;

create or replace type xdb.xdb$include_list_t OID
'00000000000000000000000000020149' as varray(65535) of xdb.xdb$include_t;
/
show errors;

create or replace type xdb.xdb$import_t OID '0000000000000000000000000002014A'
as object
(
    sys_xdbpd$          xdb.xdb$raw_list_t,
    namespace           varchar2(700),
    schema_location     varchar2(700),
    annotation          xdb.xdb$annotation_t,
    id                  varchar2(256)
);
/
show errors;

create or replace type xdb.xdb$import_list_t OID
'0000000000000000000000000002014B' as varray(65535) of xdb.xdb$import_t;
/
show errors;

/* ------------------------------------------------------------------- */
/*                   SCHEMA RELATED TYPES                              */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$extra_list_t OID
'0000000000000000000000000002014C' as varray(65535) of varchar2(2000);
/
show errors;

create or replace type xdb.xdb$schema_t OID '0000000000000000000000000002014D'
as object
(
    schema_url          varchar2(700), /* Maximum key length for an index*/
    target_namespace    varchar2(2000),
    version             varchar2(4000),
    num_props           integer, /* Total # of properties */
    final_default       xdb.xdb$derivationChoice,
    block_default       xdb.xdb$derivationChoice,
    element_form_dflt   xdb.xdb$formChoice,
    attribute_form_dflt xdb.xdb$formChoice,
    elements            xdb.xdb$xmltype_ref_list_t,
    simple_type         xdb.xdb$xmltype_ref_list_t,
    complex_types       xdb.xdb$xmltype_ref_list_t,
    attributes          xdb.xdb$xmltype_ref_list_t,
    imports             xdb.xdb$import_list_t,
    includes            xdb.xdb$include_list_t,
    flags               raw(4),
    sys_xdbpd$          xdb.xdb$raw_list_t,
    annotations         xdb.xdb$annotation_list_t,
    map_to_nchar        raw(1),   /* map strings to NCHAR/NVARCHAR2/NCLOB ? */
    map_to_lob          raw(1),           /* map unbounded strings to LOB ? */
    groups              xdb.xdb$xmltype_ref_list_t,
    attrgroups          xdb.xdb$xmltype_ref_list_t,
    id                  varchar2(256),
    varray_as_tab       raw(1),     /* should varrays be stored as tables ? */
    schema_owner        varchar2(30),
    notations           xdb.xdb$notation_list_t,
    lang                varchar2(4000)
);
/
show errors;

/* ------------------------------------------------------------------- */
/*                      TABLES                                         */   
/* ------------------------------------------------------------------- */


/*
 * Each column has an array of ub2s (in bytecomparable order) specifying
 * property numbers at each level for the XML property associated with 
 * a particular column.
 */
create table xdb.xdb$column_info
(
    schema_ref          ref sys.xmltype,
    elnum               integer,
    colnum              integer,
    propinfo            raw(2000)
);

/* Well known ID for XDB schema for schema */
/* '6C3FCF2D9D354DC1E03408002087A0B7' */

create table xdb.xdb$simple_type of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "simpleType" id 22
        type xdb.xdb$simple_t;                      

create table xdb.xdb$complex_type of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "complexType" id 29
        type xdb.xdb$complex_t;                     

create table xdb.xdb$all_model of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "all" id 111
        type xdb.xdb$model_t;                     

create table xdb.xdb$choice_model of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "choice" id 112
        type xdb.xdb$model_t;                     

create table xdb.xdb$sequence_model of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "sequence" id 113
        type xdb.xdb$model_t;                     

create table xdb.xdb$element of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "element" id 67
        type xdb.xdb$element_t;                     

create table xdb.xdb$attribute of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "attribute" id 48
        type xdb.xdb$property_t;                    

create table xdb.xdb$anyattr of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "anyAttribute" id 129
        type xdb.xdb$any_t;                      

create table xdb.xdb$any of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "any" id 127
        type xdb.xdb$any_t;                      

create table xdb.xdb$group_def of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "group" id 192
        type xdb.xdb$group_def_t;

create table xdb.xdb$group_ref of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "group" id 165
        type xdb.xdb$group_ref_t;

create table xdb.xdb$attrgroup_def of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "attributeGroup" id 193
        type xdb.xdb$attrgroup_def_t;

create table xdb.xdb$attrgroup_ref of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "attributeGroup" id 169
        type xdb.xdb$attrgroup_ref_t;

create table xdb.xdb$schema of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBSchema.xsd" 
                id '6C3FCF2D9D354DC1E03408002087A0B7'
        element "schema" id 81
        type xdb.xdb$schema_t;                      

/* ------------------------------------------------------------------- */
/*                          PRIVS                                      */   
/* ------------------------------------------------------------------- */

/* grant execute privs on all types */

grant execute on xdb.xdb$annotation_list_t to public with grant option;
grant execute on xdb.xdb$annotation_t to public with grant option;
grant execute on xdb.xdb$any_t to public with grant option;
grant execute on xdb.xdb$appinfo_t to public with grant option;
grant execute on xdb.xdb$appinfo_list_t to public with grant option;
grant execute on xdb.xdb$complex_derivation_t to public with grant option;
grant execute on xdb.xdb$complex_t to public with grant option;
grant execute on xdb.xdb$content_t to public with grant option;
grant execute on xdb.xdb$simplecont_res_t to public with grant option;
grant execute on xdb.xdb$simplecont_ext_t to public with grant option;
grant execute on xdb.xdb$simplecontent_t to public with grant option;
grant execute on xdb.xdb$derivationchoice to public with grant option;
grant execute on xdb.xdb$documentation_t to public with grant option;
grant execute on xdb.xdb$documentation_list_t to public with grant option;
grant execute on xdb.xdb$element_t to public with grant option;
grant execute on xdb.xdb$whitespacechoice to public with grant option;
grant execute on xdb.xdb$whitespace_t to public with grant option;
grant execute on xdb.xdb$enum_t to public with grant option;
grant execute on xdb.xdb$enum2_t to public with grant option;
grant execute on xdb.xdb$enum_values_t to public with grant option;
grant execute on xdb.xdb$extra_list_t to public with grant option;
grant execute on xdb.xdb$facet_t to public with grant option;
grant execute on xdb.xdb$facet_list_t to public with grant option;
grant execute on xdb.xdb$formchoice to public with grant option;
grant execute on xdb.xdb$transientchoice to public with grant option;
grant execute on xdb.xdb$group_def_t to public with grant option;
grant execute on xdb.xdb$group_ref_t to public with grant option;
grant execute on xdb.xdb$attrgroup_def_t to public with grant option;
grant execute on xdb.xdb$attrgroup_ref_t to public with grant option;
grant execute on xdb.xdb$import_t to public with grant option;
grant execute on xdb.xdb$include_t to public with grant option;
grant execute on xdb.xdb$import_list_t to public with grant option;
grant execute on xdb.xdb$include_list_t to public with grant option;
grant execute on xdb.xdb$javatype to public with grant option;
grant execute on xdb.xdb$link_t to public with grant option;
grant execute on xdb.xdb$list_t to public with grant option;
grant execute on xdb.xdb$model_t to public with grant option;
grant execute on xdb.xdb$numfacet_t to public with grant option;
grant execute on xdb.xdb$processchoice to public with grant option;
grant execute on xdb.xdb$property_t to public with grant option;
grant execute on xdb.xdb$qname to public with grant option;
grant execute on xdb.xdb$raw_list_t to public with grant option;
Rem (catxdbrs) grant execute on xdb.xdb$resource_t to public with grant option;
grant execute on xdb.xdb$schema_t to public with grant option;
grant execute on xdb.xdb$simple_derivation_t to public with grant option;
grant execute on xdb.xdb$simple_t to public with grant option;
grant execute on xdb.xdb$string_list_t to public with grant option;
grant execute on xdb.xdb$timefacet_t to public with grant option;
grant execute on xdb.xdb$union_t to public with grant option;
grant execute on xdb.xdb$usechoice to public with grant option;
grant execute on xdb.xdb$notation_t to public with grant option;
grant execute on xdb.xdb$notation_list_t to public with grant option;
grant execute on xdb.xdb$xpathspec_t to public with grant option;
grant execute on xdb.xdb$xpathspec_list_t to public with grant option;
grant execute on xdb.xdb$keybase_t to public with grant option;
grant execute on xdb.xdb$keybase_list_t to public with grant option;
grant execute on xdb.xdb$xmltype_ref_list_t to public with grant option;
grant execute on sys.xmltype to public with grant option;

/* grant select privs on all tables
 *  TODO : enable ACL enforcement during selects
 */
grant select on xdb.xdb$schema to public with grant option;

grant select on xdb.xdb$any to public with grant option;
grant select on xdb.xdb$anyattr to public with grant option;
grant select on xdb.xdb$attribute to public with grant option;
grant select on xdb.xdb$complex_type to public with grant option;
grant select on xdb.xdb$element to public with grant option;
grant select on xdb.xdb$simple_type to public with grant option;
grant select on xdb.xdb$all_model to public with grant option;
grant select on xdb.xdb$choice_model to public with grant option;
grant select on xdb.xdb$sequence_model to public with grant option;
grant select on xdb.xdb$group_def to public with grant option;
grant select on xdb.xdb$group_ref to public with grant option;
grant select on xdb.xdb$attrgroup_def to public with grant option;
grant select on xdb.xdb$attrgroup_ref to public with grant option;


/* ------------------------------------------------------------------- */
/*                          INDEXES                                    */   
/* ------------------------------------------------------------------- */

/*
create unique index xdb.xdb$propnum_a on 
xdb.xdb$attribute e (reftohex(e.xmldata.parent_schema), 
                 e.xmldata.prop_number);

create unique index xdb.xdb$propnum_e on 
xdb.xdb$element e(reftohex(e.xmldata.property.parent_schema), 
              e.xmldata.property.prop_number);

create unique index xdb.xdb$schema_pk_url on xdb.xdb$schema e
   (e.xmldata.schema_url);
*/


/* if you add/alter an here please make sure to also update xdbu111.sql */

/* prop_number index */
create index xdb.xdb$element_propnumber on
xdb.xdb$element e (e.xmldata.property.prop_number);

/* prop_name index */
create index xdb.xdb$element_propname on
xdb.xdb$element e (e.xmldata.property.name);

/* schema_url */
create index xdb.xdb$schema_url on
xdb.xdb$schema s (s.xmldata.schema_url);

/* parent_schema */
create index xdb.xdb$element_ps on 
xdb.xdb$element e (sys_op_r2o(e.xmldata.property.parent_schema));   

/* propref_ref */
create  index xdb.xdb$element_pr on 
xdb.xdb$element e (sys_op_r2o(e.xmldata.property.propref_ref)); 

/* type_ref */
create  index xdb.xdb$element_tr on 
xdb.xdb$element e (sys_op_r2o(e.xmldata.property.type_ref)); 

/* sequence_kid */
create  index xdb.xdb$complex_type_sk on 
xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.sequence_kid)); 

/* choice_kid */
create  index xdb.xdb$complex_type_ck on 
xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.choice_kid)); 

/* all_kid */
create  index xdb.xdb$complex_type_ak on 
xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.all_kid));

/* head_elem_ref */
create  index xdb.xdb$element_her on 
xdb.xdb$element ct (sys_op_r2o(ct.xmldata.head_elem_ref));

/* global */
BEGIN
execute immediate 
'create bitmap index xdb.xdb$element_global on 
xdb.xdb$element e (e.xmldata.property.global)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
commit;

/* analyze xdb.xdb$element to force cbo on DBA_XML_TABLES */
analyze table xdb.xdb$element compute statistics;

/* ------------------------------------------------------------------- */
/*                      SEQUENCES                                      */   
/* ------------------------------------------------------------------- */

/* Sequence number generator for Property Numbers 
 *   The initial set of numbers are reserved for XDB internal use.
 */
create sequence xdb.xdb$propnum_seq 
  start with 2000
  cache 20;

/* Sequence number generator for name suffixes (schema compiler)
 */
create sequence xdb.xdb$namesuff_seq 
  maxvalue 99999 cycle cache 20;
GRANT SELECT ON xdb.xdb$namesuff_seq TO PUBLIC;

/* Type id generator for global simple and complex types
 * The initial numbers are reserved for built-in types.
 */
create sequence xdb.xdb$typeid_seq
  start with 100
  cache 20;



