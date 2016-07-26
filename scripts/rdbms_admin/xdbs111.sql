Rem
Rem $Header: rdbms/admin/xdbs111.sql /st_rdbms_11.2.0/5 2013/03/28 12:20:50 rpang Exp $
Rem
Rem xdbs111.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbs111.sql - XDB Upgrade from 11.1.0
Rem
Rem    DESCRIPTION
Rem      This script performs XDB schema upgrade actions to upgrade from 
Rem      11.1.0 to the current release
Rem
Rem    NOTES
Rem      It is invoked by xdbdbmig.sql and by xdbs102.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       03/25/13 - 4892564: add new enum values for EPG
Rem    spetride    05/16/11 - grant select to select_catalog_role
Rem    spetride    04/12/11 - Backport spetride_bug-12317504 from main
Rem    badeoti     08/19/10 - make re-runnable by modularizing
Rem    badeoti     05/28/10 - make sure schema_t version is upgraded
Rem    badeoti     05/18/10 - lrg 4616786: xmltype table flags in sys.opqtype
Rem    thbaby      03/01/10 - add column grppos to xdb.xdb$xidx_imp_t
Rem    vhosur      02/16/10 - Schema for simple types should be XDBResource
Rem    badeoti     02/15/10 - bug 9304342: fix-up complex type PDs
Rem    vhosur      01/20/10 - Fix bug 9014927
Rem    vhosur      01/07/10 - Mark Container unmuttable
Rem    ataracha    11/17/09 - XDBResource.xsd: IsXMLIndexed - mark immutable
Rem    badeoti     10/28/09 - Include sidicula_bug-7596530 fixes for 9201NT
Rem                           schema-for-schemas
Rem    spetride    07/29/09 - add localApplicationGroupStore and on-deny options
Rem    badeoti     07/23/09 - drop utility functions
Rem    mkandarp    06/16/09 - 8571751: increase maxval for xdb$namesuff_seq
Rem    spetride    05/08/09 - upgrade XMLIndexMethods
Rem    spetride    02/16/09 - upgrade for Expire headers in xdbconfig
Rem    badeoti     02/26/09 - add respond-with-server-info to httpcfg
Rem    atabar      02/09/09 - xdbconfig upgrade: default-type-mappings
Rem    spetride    02/02/09 - upgrade for realm under httpconfig
Rem    spetride    06/11/08 - upgrade ACL and CONFIG schemas 11.1 to 11.2
Rem    badeoti     10/28/08 - manual upgrade for resconfig schema, no
Rem                           inplaceEvolve
Rem    bhammers    04/22/08 - renamed col in XDB.XDB$XIDX_IMP_T
Rem    badeoti     04/29/08 - ipv6 support: ipaddress type upgrade
Rem    attran      04/15/08 - Add support for new partitioning M of XMLIndex
Rem    bhammers    03/18/08 - add upgrade for XML Index
Rem    yifeng      11/07/07 - use xmldiff before call to InPlaceEvolve
Rem    jwwarner    10/12/07 - add upgrade for ResConfig schema
Rem    mrafiq      09/26/07 - add upgrade for acl and ace any element
Rem    rburns      08/22/07 - add 11g XDB up/down scripts
Rem    rburns      08/22/07 - Created
Rem

-- utility functions may not have been dropped during prior upgrade from 10.2
-- drop them here
@@xdbuud2

Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

Rem Fix schema-for-schemas in DBs upgraded from 9201
execute dbms_xdbmig_util.checkSchSchCfgKids;
execute dbms_xdbmig_util.fixSchSchCfgKids;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

Rem Fix corrupted complex type rows
execute dbms_xdbmig_util.fixCfgPDs;
execute dbms_xdbmig_util.checkCfgPDs;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

-- increase maxval for namesuff_seq
alter sequence xdb.xdb$namesuff_seq maxvalue 99999;

-- schema_t version attribute should have length 4000
declare
  ubound  number;
  prvers varchar2(30);
  len     NUMBER;
begin
  select UPPER_BOUND into ubound
  from dba_coll_types
  where owner = 'XDB' and type_name = 'XDB$FACET_LIST_T';
  
  -- check if this has been upgraded previously
  select prv_version into prvers from registry$ where cid='XDB';

  if ((ubound < 65536) and (prvers is not null)) then
    -- Artificially increase facet_list_t version number to match table data
    -- Needed because a reset might have done on type during an earlier upgrade from 9.2
    execute immediate 
      'alter type xdb.xdb$facet_list_t 
       modify limit 65536 cascade not including table data';
    dbms_output.put_line('altered facet list limit');
  end if;

  select LENGTH into len
  from dba_type_attrs
  where owner = 'XDB' and TYPE_NAME = 'XDB$SCHEMA_T'
  and ATTR_NAME = 'VERSION';

  if(len < 4000) then
    -- DDL change to schema table
     execute immediate 
       'alter type XDB.XDB$SCHEMA_T 
        modify attribute version varchar2(4000) cascade not including table data';
     dbms_output.put_line('altered schema_t version attr');
  end if;

  if(((ubound < 65536) and (prvers is not null)) or 
     (len < 4000)) then
    -- Upgrade data for tables depending on xdb$facet_list_t, xdb$schema_t
    execute immediate 
      'alter table XDB.XDB$SCHEMA upgrade';
    execute immediate 
      'alter table XDB.XDB$SIMPLE_TYPE upgrade';
    execute immediate 
      'alter table XDB.XDB$COMPLEX_TYPE upgrade';
  end if;
end;
/

/*-----------------------------------------------------------------------*/
/* Update opqtype$ flag for XMLType Tables */
/*-----------------------------------------------------------------------*/
column table_name format a35
column opqflg format a9
column obj# format 999999
select o.obj#, '"'||u.name||'"."'||o.name||'"' table_name,
       '0x'||ltrim(rawtohex(utl_raw.cast_from_binary_integer(opq.flags)),'0') opqflg
from sys.obj$ o, sys.user$ u, xdb.xdb$element e,
     sys.opqtype$ opq, sys.tab$ t, sys.col$ c
where o.owner#=u.user# 
  and e.xmldata.default_table is not null 
  and e.xmldata.sql_inline = '00'
  and e.xmldata.property.global = '01' 
  and u.name = e.xmldata.default_table_schema
  and o.name = e.xmldata.default_table
  and opq.obj# = o.obj# and t.obj# = o.obj#
  and c.obj# = opq.obj# and c.intcol# = opq.intcol#
  and bitand(c.property, 512) = 512 --  rowinfo column
  and bitand(opq.flags, 32) = 32    --  OOL
order by 1, 2
/

select d.TABLE_NAME, d.SCHEMA_OWNER||'.'||d.ELEMENT_NAME element_name,
       d.STORAGE_TYPE, o.obj#, 
       '0x'||ltrim(rawtohex(utl_raw.cast_from_binary_integer(opq.flags)),'0') opqflg
from DBA_XML_TABLES d, sys.obj$ o, sys.opqtype$ opq, sys.user$ u, sys.col$ c
where o.name = d.table_name and o.owner# = u.user# and u.name = d.owner
  and o.obj# =  opq.obj#
  and c.obj# = opq.obj# and c.intcol# = opq.intcol#
  and bitand(c.property, 512) = 512  --  rowinfo column
  and bitand(opq.flags, 1024) = 0    -- xmltype table
/

-- XMLType tables should have KKDOOPQF_XMLTYPETABLE set
update sys.opqtype$ op
set op.flags = utl_raw.cast_to_binary_integer
               (
                  utl_raw.bit_or
                  (
                     utl_raw.cast_from_binary_integer(op.flags), 
                     utl_raw.cast_from_binary_integer(1024)
                  )
               )
where (op.obj#, op.intcol#) in 
   (select opq.obj#, opq.intcol#
    from sys.obj$ o, sys.user$ u, sys.opqtype$ opq, sys.col$ c, sys.coltype$ ac, sys.tab$ t
    where o.owner#=u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 1
    and opq.obj# = o.obj#
    and c.obj# = ac.obj#
    and c.intcol# = ac.intcol#
    and ac.toid = '00000000000000000000000000020100'
    and c.obj# = opq.obj# and c.intcol# = opq.intcol#
    and bitand(c.property, 512) = 512  /* rowinfo column */ 
    and bitand(opq.flags, 1024) = 0    /* flag not already set xmltype table */
    );

-- Default tables for global schema element are not OOL
update sys.opqtype$ op
set op.flags = op.flags - 32 
where (op.obj#, op.intcol#) in 
   (select opq.obj#, opq.intcol#
    from sys.obj$ o, sys.user$ u, xdb.xdb$element e,
         sys.opqtype$ opq, sys.tab$ t, sys.col$ c
    where o.owner#=u.user# 
      and e.xmldata.default_table is not null 
      and e.xmldata.sql_inline = '00'
      and e.xmldata.property.global = '01' 
      and u.name = e.xmldata.default_table_schema
      and o.name = e.xmldata.default_table
      and opq.obj# = o.obj# and t.obj# = o.obj#
      and c.obj# = opq.obj# and c.intcol# = opq.intcol#
      and bitand(c.property, 512) = 512 --  rowinfo column
      and bitand(opq.flags, 32) = 32    --  OOL
   );

/*************************************************************************/
/******************* Upgrade XDBResource schema to 11.2 ******************/
/*************************************************************************/
declare
  res_schema_ref  REF XMLTYPE;
  res_schema_url  VARCHAR2(100);
begin
  res_schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
  
  select ref(s) into res_schema_ref 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = res_schema_url;

/* Set numcolumns for simple types to 0 */
  execute immediate
  'update xdb.xdb$element e 
  set e.xmldata.num_cols = 0 
  where e.xmldata.property.name=''XMLRef'' or 
        e.xmldata.property.name=''XMLLob'' or 
        e.xmldata.property.name=''Flags'' or 
        e.xmldata.property.name=''SBResExtra'' or 
        e.xmldata.property.name=''Snapshot'' or 
        e.xmldata.property.name=''NodeNum'' or 
        e.xmldata.property.name=''ContentSize'' or 
        e.xmldata.property.name=''SizeOnDisk'' 
    and e.xmldata.property.parent_schema=:1' using  res_schema_ref;

/* IsXMLIndexed - mark unmutable */
  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '01'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'IsXMLIndexed';

/* container - mark unmutable */
  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '01'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'Container';


  commit;
end;
/


/*************************************************************************/
/********************** Upgrade ACL schema to 11.2  **********************/
/*************************************************************************/

-- This changes the processContents attribute for the any element in the acl and ace elements
-- to lax so that user defined data can be added to these any elements.
create or replace procedure xdb$updateAclProcessContents(ace_cplx_ref IN REF SYS.XMLTYPE)
as
  anylist         XDB.XDB$XMLTYPE_REF_LIST_T;
  any_ref           REF XMLTYPE;
  seq_ref           REF XMLTYPE;
begin
  -- update the any element of the ace element to make 
  -- processContents attibute equals lax 
  select c.xmldata.sequence_kid into seq_ref
  from xdb.xdb$complex_type c
  where ref(c) = ace_cplx_ref;

  select m.xmldata.anys into anylist
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  any_ref := anylist(1);

  update xdb.xdb$any a
  set a.xmldata.process_contents = XDB.XDB$PROCESSCHOICE('01'),
      a.xmldata.property.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43881800F000001E1F1C1D0809181B030B0C07')
  where ref(a) = any_ref;

  -- update the any element of the acl element to make 
  -- processContents attibute equals lax 
  select c.xmldata.sequence_kid into seq_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name like 'aclType';

  select m.xmldata.anys into anylist
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  any_ref := anylist(1);

  update xdb.xdb$any a
  set a.xmldata.process_contents = XDB.XDB$PROCESSCHOICE('01'),
      a.xmldata.property.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43881800F000001E1F1C1D0809181B030B0C07')
  where ref(a) = any_ref;

  commit;
end xdb$updateAclProcessContents;
/
show errors;

-- This adds 'ApplicationName' principal format
create or replace procedure xdb$addAclApplicationName(ace_cplx_ref IN REF SYS.XMLTYPE) as
  aceattrs      XDB.XDB$XMLTYPE_REF_LIST_T;
  i             NUMBER;
  nm            VARCHAR2(256);
  aceattr       REF SYS.XMLTYPE;
begin
  -- find the list of attributes for the ace's complex type
  select c.xmldata.attributes into aceattrs 
  from xdb.xdb$complex_type c
  where ref(c) = ace_cplx_ref;

  for i in 1..aceattrs.last loop
     select a.xmldata.name into nm from xdb.xdb$attribute a 
     where ref(a)=aceattrs(i);

     if (nm = 'principalFormat') then
        -- update the simple type for principalFormat
        update xdb.xdb$simple_type s
        set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020000000106'),
            s.xmldata.restriction = 
                 XDB.XDB$SIMPLE_DERIVATION_T(
                      XDB.XDB$RAW_LIST_T('330008020000118B8005'), NULL, 
                      XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, 
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                      XDB.XDB$FACET_LIST_T(
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'ShortName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'DistinguishedName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'GUID', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'XSName', '00', NULL), 
                          XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                          'ApplicationName', '00', NULL)),
                      NULL, NULL)
        where ref(s) = (select a.xmldata.smpl_type_decl from xdb.xdb$attribute a 
                        where ref(a)=aceattrs(i));
        dbms_output.put_line('updated acl.ace.principalFormat.restriction');
        -- exit the loop
        exit;
     end if;
  end loop;

  commit;
end xdb$addAclApplicationName;
/  
show errors;

declare
  acl_schema_url    VARCHAR2(100);
  acl_schema_ref    REF XMLTYPE;
  ace_cplxType_ref  REF XMLTYPE;
begin
  acl_schema_url := 'http://xmlns.oracle.com/xdb/acl.xsd';

  select ref(s) into acl_schema_ref 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = acl_schema_url;
  
  select e.xmldata.cplx_type_decl into ace_cplxType_ref
  from xdb.xdb$element e
  where e.xmldata.property.name = 'ace'
  and e.xmldata.property.parent_schema = acl_schema_ref;

  xdb$updateAclProcessContents(ace_cplxType_ref);
  xdb$addAclApplicationName(ace_cplxType_ref);
end;
/

-- drop acl-specific procedures/functions
drop procedure xdb$updateAclProcessContents;
drop procedure xdb$addAclApplicationName;

/*-----------------------------------------------------------------------*/
/* End upgrade of ACL schema */
/*-----------------------------------------------------------------------*/

/****** Some utility functions ******/
/*-----------------------------------------------------------------------*/
/* Return complex type in input list under schema_ref,  */
/*             and with name = child                    */
/*    OR null if none exist in list                     */
/*-----------------------------------------------------------------------*/
create or replace function xdb$find_cmplx_type(seq  xdb.xdb$xmltype_ref_list_t,
                    child varchar2, 
                    schema_ref REF SYS.XMLTYPE) return ref xmltype as
  r  ref sys.xmltype;
begin                 
  select ref(c) into r from xdb.xdb$complex_type c
   where (seq is null OR (ref(c) in (select * from table(seq)))) 
     and c.xmldata.name = child
     and c.xmldata.parent_schema = schema_ref;
  return r;                      
exception
  when no_data_found then
    return null;
end xdb$find_cmplx_type;
/
show errors;


/*************************************************************************/
/********************* Upgrage XDBConfig to 11.2 *************************/
/*************************************************************************/

/* Insert one element under the xdbconfig schema into xdb$element table */
create or replace function xdb$insertCfgCplxElem(
--    elems_reflist     XDB.XDB$XMLTYPE_REF_LIST_T,
    prop_pd           XDB.XDB$RAW_LIST_T,
    prop_parschema    REF SYS.XMLTYPE,
    prop_elemname     VARCHAR2,
    prop_typename     XDB.XDB$QNAME,
    prop_memtypecode  RAW,
    prop_sqlname      VARCHAR2,
    prop_sqltype      VARCHAR2,
    prop_dfltval      VARCHAR2,
    prop_smpltypedecl REF SYS.XMLTYPE,
    prop_typeref      REF SYS.XMLTYPE,
    mem_inline        RAW,
    java_inline       RAW,
    cplx_type_decl    REF SYS.XMLTYPE,
    min_occurs        INTEGER,
    max_occurs        VARCHAR2) return REF SYS.XMLTYPE
AS
  elemref           REF SYS.XMLTYPE := NULL;
  prop_propnum      INTEGER;
BEGIN
  -- TODO: Need to check if element exists, to avoid dangling refs???
  -- TODO: this has to be done with element_exists_complextype since multiple elements with same name and other details can exist in the same schema, especially if many of these details are null or default
  
  -- extend sequence and insert new element
--  elems_reflist.extend(1);
  prop_propnum := xdb.xdb$propnum_seq.nextval;
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$ELEMENT_T(
           XDB.XDB$PROPERTY_T(prop_pd, prop_parschema, prop_propnum, 
             prop_elemname, prop_typename, 
             NULL, prop_memtypecode, '00', '00', NULL, -- 10  
             prop_sqlname, prop_sqltype, NULL, NULL, prop_dfltval, 
             prop_smpltypedecl, prop_typeref, NULL, NULL, NULL, -- 20
             NULL,  '00', NULL, NULL, NULL, '00', NULL, NULL, '00'),
           NULL, NULL, '00', NULL, NULL, '00', mem_inline, '01', java_inline, -- 10
           '01', NULL, NULL, NULL, NULL, 
           NULL, NULL, cplx_type_decl, NULL, NULL, -- 20
           min_occurs, max_occurs, '00', '01', NULL, 
           NULL, NULL, NULL, NULL, NULL, -- 30
           NULL, NULL))
  returning ref(e) into elemref;
--  elems_reflist(elems_reflist.last) := elemref;
  dbms_output.put_line('created new element ' || prop_elemname || 
      ' ,propnum = ' || prop_propnum);
  return elemref;
END xdb$insertCfgCplxElem;
/
show errors;

-- ipv6 support: modify simpletype ipaddress in xdbconfig
create or replace procedure xdb$updateConfigIpaddress(config_sch_ref IN REF SYS.XMLTYPE)
as
begin
  update xdb.xdb$simple_type e
  set e.xmldata.restriction.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('3310000200001104'),
      e.xmldata.restriction.maxlength  = XDB.XDB$NUMFACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 40, '00', NULL),
      e.xmldata.restriction.pattern    = NULL
  where e.xmldata.parent_schema = config_sch_ref
    and e.xmldata.name = 'ipaddress';

  commit;
end xdb$updateConfigIpaddress;
/
show errors;

/*-----------------------------------------------------------------------*/
/* Procedure to create custom-authentication-trust-type (global complex type in xdbconfig)
 *   If xdbconfig.custom-authentication-trust-type exists in xdb$complex_type, 
 *   we return that instead 
/*-----------------------------------------------------------------------*/
create or replace function xdb$getCustomAuthTrustType(config_sch_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  skidtrustelems      XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidtrustelems   REF SYS.XMLTYPE;
  anypart             VARCHAR2(4000);
  reftrustschtyp      REF SYS.XMLTYPE;
  skidtrustschs       XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidtrustschs    REF SYS.XMLTYPE;
  refcauthtrusttyp    REF SYS.XMLTYPE;
begin
  refcauthtrusttyp := xdb$find_cmplx_type(null, 'custom-authentication-trust-type', config_sch_ref);
  if refcauthtrusttyp is not null then
    dbms_output.put_line('custom-authentication-trust-type exists, not creating');
    return refcauthtrusttyp;
  end if;

  dbms_output.put_line('creating custom-authentication-trust-type ...');
  
  -- create seq(trust-scheme-name,        requireParsingSchema, allowRegistration, 
  --            trust-scheme-description, trusted-session-user, trusted-parsing-schema) 
  -- for trust-scheme
  skidtrustelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidtrustelems.extend(6);

  -- create trust-scheme-name element
  skidtrustelems(1):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'trust-scheme-name',
      XDB.XDB$QNAME('00','string'), '01', null, 'string', null, null, null,
      '01', '01', null, 0, NULL);

  -- create the requireParsingSchema element
  skidtrustelems(2):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'requireParsingSchema',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the allowRegistration element
  skidtrustelems(3):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'allowRegistration',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the trust-scheme-description element
  skidtrustelems(4):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'trust-scheme-description',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', null, 0, NULL);

  -- create the trusted-user-session element
  skidtrustelems(5):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'),
      config_sch_ref, 'trusted-session-user',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 1, 'unbounded');

  -- create the trusted-parsing-schema element
  skidtrustelems(6):= xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'),
      config_sch_ref, 'trusted-parsing-schema',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, 'unbounded');

  -- the workgroup element is not added anymore
  dbms_output.put_line(to_char(skidtrustelems.count) || ' elements in trust-scheme');
  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800607'),
                        config_sch_ref, 0, NULL, 
                        skidtrustelems,
                        NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidtrustelems;

  -- create annotation for trust-scheme
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidtrustelems, null);
 
  -- create complex type declaration for trust-scheme
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), config_sch_ref, 
           NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidtrustelems, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into reftrustschtyp;
 
  -- create seq(trust-scheme) for custom-authentication-trust-type
  skidtrustschs := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidtrustschs.extend(1);
 
  -- create complex element trust-scheme
  skidtrustschs(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'trust-scheme',
      NULL, '0102', NULL, NULL, NULL,  NULL, reftrustschtyp, 
      '00', '00', reftrustschtyp, 0, 'unbounded');

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                         skidtrustschs, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidtrustschs;

  -- create annotation for complex type custom-authentication-trust-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidtrustschs, null);

  -- create complex type custom-authentication-trust-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'),
           config_sch_ref, NULL, 'custom-authentication-trust-type', '00', '00', 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidtrustschs, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 215))
  returning ref(c) into refcauthtrusttyp;
  commit;
  return refcauthtrusttyp;
end xdb$getCustomAuthTrustType;
/  
show errors;


create or replace function xdb$getCAuthMappings(config_sch_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  refmapselem          REF SYS.XMLTYPE;
  skidmapelems         XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmap           REF SYS.XMLTYPE;
  refmaptype           REF SYS.XMLTYPE;
  skidmapselems        XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmaps          REF SYS.XMLTYPE;
  refmapstype          REF SYS.XMLTYPE;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  begin
    select ref(e) into refmapselem
      from xdb.xdb$complex_type c, xdb.xdb$element e
     where e.xmldata.property.name = 'custom-authentication-mappings'
       and e.xmldata.cplx_type_decl = ref(c)
       and e.xmldata.property.parent_schema = config_sch_ref
       and c.xmldata.parent_schema = config_sch_ref; 
    dbms_output.put_line('custom-authentication-mappings element exists, not creating');
    return refmapselem;
  exception
    when no_data_found then
      null;
  end;

  dbms_output.put_line('creating custom-authentication-mappings element');

  -- create seq(authentication-pattern, authentication-name, authentication-trust-name, 
  --            user-prefix,            on-deny)
  -- for custom-authentication-mapping
  skidmapelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidmapelems.extend(5);

  -- create authentication-pattern element
  skidmapelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-pattern',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-name element
  skidmapelems(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-trust-name element
  skidmapelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'authentication-trust-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create user-prefix element
  skidmapelems(4) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'user-prefix',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create the simple type for on-deny
  insert into xdb.xdb$simple_type t (t.xmlextra, t.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, 
             XDB.XDB$QNAME('00', 'string'), 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 'next-custom', '00', NULL), 
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 'basic', '00', NULL)), 
             NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(t) into ref_ondeny_typ;
  
  -- create the on-deny element
  skidmapelems(5) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A1020008003040000000432010809181B23262A343503150C07292728'),
      config_sch_ref, 'on-deny',
      NULL, '0103', NULL, 'string', NULL, ref_ondeny_typ, ref_ondeny_typ,
      '01', '01', NULL, 0, NULL);

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800507'),
           config_sch_ref, 0, NULL, skidmapelems,
           NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidmap;

  -- create annotation for custom-authentication-mapping
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidmapelems, null);
  
  -- create complex type declaration for custom-authentication-mapping
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           refskidmap, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                 anypart,
                 NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refmaptype;

  -- create seq(custom-authentication-mapping)
  skidmapselems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidmapselems.extend(1);

  -- create custom-authentication-mapping element
  skidmapselems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'custom-authentication-mapping',
      NULL, '0102', NULL, NULL, NULL, NULL, refmaptype,
      '00', '00', refmaptype, 0, 'unbounded');

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                         skidmapselems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidmaps;

  -- create annotation for complex type declaration for custom-authentication-mappings
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidmapselems, null);

  -- create complex type declaration for custom-authentication-mappings
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidmaps, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                 anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refmapstype;
  
  refmapselem := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('8398002010800300000000041C0809181B23262A323435031507292728'),
      config_sch_ref, 'custom-authentication-mappings',
      NULL, '0102', NULL, NULL, NULL, NULL, refmapstype,
      '00', '00', refmapstype, 0, NULL);

  return refmapselem;
end xdb$getCAuthMappings;
/
show errors;
 
create or replace function xdb$getCAuthList(config_sch_ref IN REF SYS.XMLTYPE)
return REF SYS.XMLTYPE
as
  reflistelem          REF SYS.XMLTYPE;
  reflangtype          REF SYS.XMLTYPE;
  skidauthelems        XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidauth          REF SYS.XMLTYPE;
  refauthtype          REF SYS.XMLTYPE;
  skidauthlistelems    XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidauthlist      REF SYS.XMLTYPE;
  refauthlisttype      REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  begin
    select ref(e) into reflistelem
      from xdb.xdb$complex_type c, xdb.xdb$element e
     where e.xmldata.property.name = 'custom-authentication-list'
       and e.xmldata.cplx_type_decl = ref(c)
       and e.xmldata.property.parent_schema = config_sch_ref
       and c.xmldata.parent_schema = config_sch_ref; 
    dbms_output.put_line('custom-authentication-list element exists, not creating');
    return reflistelem;
  exception
    when no_data_found then
      null;
  end;

  dbms_output.put_line('creating custom-authentication-list element');

  -- create seq(authentication-name, authentication-description, authentication-implement-schema, 
  --            authentication-implement-method, authentication-implement-language) 
  -- for custom-authentication-list.complexType.authentication
  skidauthelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidauthelems.extend(5);

  -- create authentication-name element
  skidauthelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-name',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-description element
  skidauthelems(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
      config_sch_ref, 'authentication-description',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-implement-schema element
  skidauthelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-schema',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create authentication-implement-method element
  skidauthelems(4) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-method',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);

  -- create annotation for simple type for authentication-implement-language (not needed)

  -- create simple type for authentication-implement-language
  insert into xdb.xdb$simple_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330008020000110B'), NULL, XDB.XDB$QNAME('00', 'string'),
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'PL/SQL', '00', NULL)), 
             NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(c) into reflangtype;

  -- create authentication-implement-language element
  skidauthelems(5) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A10200080030000000004010809181B23262A32343503150C07292728'),
      config_sch_ref, 'authentication-implement-language',
      NULL, '0103', NULL, 'string', NULL, reflangtype, reflangtype,
      '01', '01', NULL, 0, NULL);
  
  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800507'), config_sch_ref, 0, NULL, 
           skidauthelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidauth;  

  -- create annotation for complex type declaration for authentication
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidauthelems, null);

  -- create complex type declaration for authentication
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidauth, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refauthtype;

  -- create seq(authentication)
  skidauthlistelems := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidauthlistelems.extend(1);

  -- create authentication element
  skidauthlistelems(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'authentication',
      NULL, '0102', NULL, NULL, NULL, NULL, refauthtype,
      '00', '00', refauthtype, 0, 'unbounded');
  
  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('23020000000107'), 
           config_sch_ref, 0, NULL, skidauthlistelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidauthlist;

  -- create annotation for complex type declaration for custom-authentication-list
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidauthlistelems, null);

  -- create complex type declaration for custom-authentication-list
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidauthlist, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into refauthlisttype;

  reflistelem := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('8398002010800300000000041C0809181B23262A323435031507292728'),
      config_sch_ref, 'custom-authentication-list',
      NULL, '0102', NULL, NULL, NULL, NULL, refauthlisttype,
      '00', '00', refauthlisttype, 0, NULL);

  return reflistelem;
end xdb$getCAuthList;
/
show errors;

create or replace function xdb$getCustomAuthType(config_sch_ref IN REF SYS.XMLTYPE,
                                            cauthtrusttyp_ref IN REF SYS.XMLTYPE) 
return REF SYS.XMLTYPE
as
  refcauthtype         REF SYS.XMLTYPE;
  skidcauthtypeelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidcauthtype     REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
begin
  refcauthtype := xdb$find_cmplx_type(null, 'custom-authentication-type', config_sch_ref);
  if refcauthtype is not null then 
    dbms_output.put_line('custom-authentication-type exists, not creating');
    return refcauthtype;
  end if;

  dbms_output.put_line('creating custom-authentication-type ...');

  -- create seq(custom-authentication-mappings, custom-authentication-list, 
  --            custom-authentication-trust) 
  -- for custom-authentication-type
  skidcauthtypeelems :=  XDB.XDB$XMLTYPE_REF_LIST_T();
  skidcauthtypeelems.extend(3);

  -- create custom-authentication-mappings element
  skidcauthtypeelems(1) := xdb$getCAuthMappings(config_sch_ref);

  -- create custom-authentication-list element
  skidcauthtypeelems(2) := xdb$getCAuthList(config_sch_ref);

  skidcauthtypeelems(3) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
      config_sch_ref, 'custom-authentication-trust',
      XDB.XDB$QNAME('01', 'custom-authentication-trust-type'), '0102', 
      NULL, NULL, NULL, NULL, cauthtrusttyp_ref,
      '00', '00', NULL, 0, NULL);

  insert into  xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(
           XDB.XDB$RAW_LIST_T('230200000081800307'), config_sch_ref, 0, NULL, 
           skidcauthtypeelems, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidcauthtype;  

  -- create annotation for custom-authentication-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidcauthtypeelems, null);
  
  -- create complex type custom-authentication-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'), 
           config_sch_ref, NULL, 'custom-authentication-type', '00', '00', NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, 
           refskidcauthtype, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 141))
  returning ref(c) into refcauthtype;
  commit;
  return refcauthtype;
end xdb$getCustomAuthType;
/
show errors;

/*-----------------------------------------------------------------------*/
/* Procedure to create expire-type (global complex type in xdbconfig)  */
/* If xdbconfig.expire-type exists in xdb$complex_type, we return that instead */
/*-----------------------------------------------------------------------*/
create or replace function xdb$getConfigExpireType (config_sch_ref IN REF SYS.XMLTYPE) 
return ref sys.xmltype 
as 
  exptype              REF SYS.XMLTYPE;
  expdeftype           REF SYS.XMLTYPE;
  skidexpmap           XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmap           REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
  expmaptype           REF SYS.XMLTYPE;
  skidexp              XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidexp           REF SYS.XMLTYPE;
begin
  exptype := xdb$find_cmplx_type(null, 'expire-type', config_sch_ref);
  if exptype is not null then
    dbms_output.put_line('expire-type exists, not creating');
    return exptype;
  end if;

  dbms_output.put_line('creating expire-type ...');
 
  skidexpmap := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidexpmap.extend(2);

  -- create the expire-pattern element
  skidexpmap(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B810200080030000000004050809181B23262A32343503150C07292728'),
      config_sch_ref, 'expire-pattern',
      XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
      '01', '01', NULL, 0, NULL);
  dbms_output.put_line('1. expire-pattern element created');

  -- create simple type for expire-default
  insert into xdb.xdb$simple_type st (st.xmlextra, st.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$SIMPLE_T(
           XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00',
           XDB.XDB$SIMPLE_DERIVATION_T(
             XDB.XDB$RAW_LIST_T('330004020000110A'), NULL, 
             XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
             XDB.XDB$FACET_LIST_T(
               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                 '(now|modification)(\s(plus))?(\s(([1]\s(year))|([0-9]*\s(years))))?(\s(([1]\s(month))|([0-9]*\s(months))))?(\s(([1]\s(week))|([0-9]*\s(weeks))))?(\s(([1]\s(day))|([0-9]*\s(days))))?(\s(([1]\s(hour))|([0-9]*\s(hours))))?(\s(([1]\s(minute))|([0-9]*\s(minutes))))?(\s(([1]\s(second))|([0-9]*\s(seconds))))?', 
                 '00', NULL)), 
             NULL, NULL, NULL), 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(st) into expdeftype;
  dbms_output.put_line('2. simple type for expire-default created');

  -- create expire-default element
  skidexpmap(2) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A10200080030000000004010809181B23262A32343503150C07292728'),
      config_sch_ref, 'expire-default',
      NULL, '01', NULL, 'string', NULL, expdeftype, expdeftype,
      '01', '01', NULL, 0, NULL);
  dbms_output.put_line('3. expire-default element created');

  --  seq(expire-pattern, expire-default)
  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
          XDB.XDB$MODEL_T(
            XDB.XDB$RAW_LIST_T('230200000081800207'), config_sch_ref, 0, NULL, 
            skidexpmap, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(m) into refskidmap;
  dbms_output.put_line('4. seq(expire-pattern, expire-default) created');

  -- create annotation for the type of expire-mapping
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidexpmap, null);

  -- create complex type declaration for expire-mapping
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('33090000000000030D0E13'), 
           config_sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidmap, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, NULL))
  returning ref(c) into expmaptype;
  dbms_output.put_line('5. complex type for expire-mapping created');

  -- seq(expire-mapping)
  skidexp := XDB.XDB$XMLTYPE_REF_LIST_T();
  skidexp.extend(1);

  -- create expire-mapping element
  skidexp(1) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839800201080030C0000000432331C0809181B23262A3435031507292728'),
      config_sch_ref, 'expire-mapping',
      NULL, '0102', NULL, NULL, NULL, NULL, expmaptype,
      '00', '00', expmaptype, 0, 'unbounded');
  dbms_output.put_line('6. expire-mapping element created');

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_sch_ref, 0, NULL, 
                          skidexp, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into refskidexp;
  dbms_output.put_line('7. seq(expire-mapping) created');

  -- create annotation for expire-type
  anypart := dbms_xdbmig_util.buildAnnotationKidList(skidexp, null);

  -- create expire-type
  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata)
  values(dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$COMPLEX_T(
           XDB.XDB$RAW_LIST_T('3309104000000C00030D0E1316'), 
           config_sch_ref, NULL, 'expire-type', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
           refskidexp, NULL, NULL, 
           XDB.XDB$ANNOTATION_T(
             XDB.XDB$RAW_LIST_T('1301000000'), 
             XDB.XDB$APPINFO_LIST_T(
               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)), 
             NULL), 
           NULL, NULL, '01', NULL, NULL, NULL, 143))
  returning ref(c) into exptype;
  dbms_output.put_line('8. expire-type created');
  commit;
  return exptype;
end xdb$getConfigExpireType;
/
show errors;

/*
 Upgrade /xdbconfig/sysconfig/httpconfig children
 Add:
   /sysconfig/httpconfig/custom-authentication
   /sysconfig/httpconfig/realm
   /sysconfig/httpconfig/respond-with-server-info
   /sysconfig/httpconfig/expire
 */
create or replace procedure xdb$updateHttpConfig(config_sch_ref IN REF SYS.XMLTYPE, 
                                                 refcauthtype   IN REF SYS.XMLTYPE,
                                                 refexptype     IN REF SYS.XMLTYPE) as 
  PRAGMA AUTONOMOUS_TRANSACTION;
  refhttptype    REF SYS.XMLTYPE;
  refskidhttp    REF SYS.XMLTYPE;
  skidhttpelems  XDB.XDB$XMLTYPE_REF_LIST_T;
  anypart        VARCHAR2(4000);
  r              REF SYS.XMLTYPE;
  seqsize        number;
begin
  -- update elements and PD for seq kid of httpconfig
  -- new elements : { ..., custom-authentication, realm, respond-with-server-info, 
  --                        expire} 
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements 
    into refhttptype, refskidhttp, skidhttpelems 
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='httpconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;
 
  -- save initial count
  seqsize := skidhttpelems.count;

  -- create custom-authentication element of type custom-authentication-type
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'custom-authentication');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'custom-authentication',
        XDB.XDB$QNAME('01', 'custom-authentication-type'), '0102', 
        NULL, NULL, NULL, NULL, refcauthtype,
        '00', '00', NULL, 0, NULL);
    dbms_output.put_line('added custom-authentication to http elem list');
  end if;

  -- create the realm element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'realm');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B81020008003040000000405320809181B23262A343503150C07292728'),
        config_sch_ref, 'realm',
        XDB.XDB$QNAME('00', 'string'), '01', NULL, 'string', NULL, NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added realm to http elem list');
  end if;

  -- create the respond-with-server-info element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'respond-with-server-info');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
        config_sch_ref, 'respond-with-server-info',
        XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added respond-with-server-info to http elem list');
  end if;

  -- create the expire element
  r := dbms_xdbmig_util.find_child(skidhttpelems, 'expire');
  if r is null then
    skidhttpelems.extend(1);
    skidhttpelems(skidhttpelems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'expire',
        XDB.XDB$QNAME('01', 'expire-type'), '0102', NULL, NULL, NULL, NULL, refexptype,
        '00', '00', NULL, 0, NULL);
    dbms_output.put_line('added expire to http elem list');
  end if;

  commit;

  -- update elements and PD for seq kid of httpconfig, if new element was added
  if skidhttpelems.count > seqsize then
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidhttpelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801807')
     where ref(m)= refskidhttp;
    dbms_output.put_line('httpconfig: updated sequence kid and PD');
  
    -- update annotations for the complex type declaration for httpconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidhttpelems, null);
  
    -- needed in the 11.1.0.7 upgrade to main
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo = 
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000') 
     where c.xmldata.parent_schema = config_sch_ref 
       and ref(c)=refhttptype;  
  
    commit;
  end if;
end xdb$updateHttpConfig;
/
show errors;

/*
 Upgrade /xdbconfig/sysconfig children
 Add:
   /sysconfig/allow-authentication-trust
   /sysconfig/custom-authentication-trust
   /sysconfig/default-type-mappings
   /sysconfig/localApplicationGroupStore
 */
create or replace procedure xdb$updateSysConfig(config_sch_ref IN REF SYS.XMLTYPE, 
                                                refcauthtrusttyp IN REF SYS.XMLTYPE) as 
  PRAGMA AUTONOMOUS_TRANSACTION;
  refsystype     REF SYS.XMLTYPE;
  refskidsys     REF SYS.XMLTYPE;
  skidsyselems   XDB.XDB$XMLTYPE_REF_LIST_T;
  anypart        VARCHAR2(4000);
  r              REF SYS.XMLTYPE;
  simpletype_ref REF SYS.XMLTYPE;
  seqsize        NUMBER;
begin
  -- update elements and PD for seq kid of sysconfig
  -- adding elements { ..., allow-authentication-trust, custom-authentication-trust }
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements
    into refsystype, refskidsys, skidsyselems
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='sysconfig' 
     and e.xmldata.property.parent_schema = config_sch_ref
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  -- save initial count
  seqsize := skidsyselems.count;

  -- create allow-authentication-trust element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'allow-authentication-trust');
  if r is null then
    skidsyselems.extend(1);
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
        config_sch_ref, 'allow-authentication-trust',
        XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'false', NULL, NULL,
        '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added allow-authentication-trust to sysconfig child list');
  end if;

  -- create custom-authentication-trust element under sysconfig
  r := dbms_xdbmig_util.find_child(skidsyselems, 'custom-authentication-trust');
  if r is null then
    skidsyselems.extend(1);
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
        XDB.XDB$RAW_LIST_T('83B80020008003040000000405320809181B23262A3435031507292728'),
        config_sch_ref, 'custom-authentication-trust',
        XDB.XDB$QNAME('01', 'custom-authentication-trust-type'), 
        '0102', NULL, NULL, NULL, NULL, refcauthtrusttyp,
        '00', '00', NULL, 0, NULL);
     dbms_output.put_line('added custom-authentication-trust to sysconfig child list');
  end if;

  -- create default-type-mappings element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'default-type-mappings');
  if r is null then
    -- create simple type declaration for default-type-mappings
    insert into xdb.xdb$simple_type st (st.xmlextra, st.xmldata)  
    values (dbms_xdbmig_util.getConfigXtra,
   	        XDB.XDB$SIMPLE_T(
              XDB.XDB$RAW_LIST_T('23020000000106'), config_sch_ref, NULL, '00', 
              XDB.XDB$SIMPLE_DERIVATION_T(
                XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, 
                XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, 
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                XDB.XDB$FACET_LIST_T(
                  XDB.XDB$FACET_T(
                    XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'pre-11.2', '00', NULL), 
                  XDB.XDB$FACET_T(
                    XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'post-11.2', '00', NULL)), 
                NULL, NULL), 
              NULL, NULL, NULL, NULL, NULL, NULL, NULL)) 
    returning ref(st) into simpletype_ref;

    skidsyselems.extend(1); 
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('839A1020008003040000000432010809181B23262A343503150C07292728'),
      config_sch_ref, 'default-type-mappings',
      NULL, '0103', NULL, 'string', NULL, simpletype_ref, simpletype_ref,
      '01', '01', NULL, 0, NULL);
      dbms_output.put_line('added default-type-mappings to sysconfig child list');
  end if;

  -- create localApplicationGroupStore element
  r := dbms_xdbmig_util.find_child(skidsyselems, 'localApplicationGroupStore');
  if r is null then
    skidsyselems.extend(1); 
    skidsyselems(skidsyselems.last) := xdb$insertCfgCplxElem(
      XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
      config_sch_ref, 'localApplicationGroupStore',
      XDB.XDB$QNAME('00', 'boolean'), 'FC', NULL, 'boolean', 'true', NULL, NULL,
      '01', '01', NULL, 0, NULL);
    dbms_output.put_line('added localApplicationGroupStore to sysconfig child list');
  end if;

  commit;

  -- update elements and PD for seq kid of sysconfig, if new element was added
  if skidsyselems.count > seqsize then
    update xdb.xdb$sequence_model m 
       set m.xmldata.elements   = skidsyselems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801C07')
     where ref(m) = refskidsys;
  
    -- update annotations for the complex type declaration for sysconfig
    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidsyselems, null);
  
    -- pd update needed in the 11.1.0.7 upgrade to main
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000'), 
           c.xmldata.annotation.appinfo    = XDB.XDB$APPINFO_LIST_T(
                                               XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                                                                 anypart, NULL))
     where c.xmldata.parent_schema = config_sch_ref
       and ref(c) = refsystype; 
  
     commit;
   end if;
end xdb$updateSysConfig;
/
show errors;


/*
 ************ PLEASE MAKE SURE THIS REMAINS COMPLETELY RE-RUNNABLE **********
 --add global complex types
 *custom-authentication-trust-type and
 *custom-authentication-type (dependent on custom-authentication-trust-type)
 *expire-type
 
 --add elements to sysconfig
 *allow-authentication-trust (type boolean)
 *custom-authentication-trust (type xdbc:custom-authentication-trust-type)
 *default-type-mappings (simple type)
 *localApplicationGroupStore (type boolean)

 --add elements to sysconfig->httpconfig
 *custom-authentication (type xdbc:custom-authentication-type)
 *realm  (type string)
 *respond-with-server-info (type boolean)
 *expire

 --add value custom to restriction sysconfig->httpconfig->authentication->allow-mechanism

 */
create or replace procedure xdb$upgradeConfigSchema as 
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  CONFIG_PRPONUMS      CONSTANT INTEGER := 204;
  clistinsch           XDB.XDB$XMLTYPE_REF_LIST_T;
  numprops             NUMBER(38);
  anypart              VARCHAR2(4000);
  r                    REF SYS.XMLTYPE;
  refcauthtrusttyp     REF SYS.XMLTYPE;
  refcauthtype         REF SYS.XMLTYPE;
  refexptype           REF SYS.XMLTYPE;
begin

  select ref(s), s.xmldata.num_props, s.xmldata.complex_types 
    into refs, numprops, clistinsch
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('upgrading xdbconfig schema, numprops was ' || numprops);
  
  xdb$updateConfigIpaddress(refs);
      
  -- create/retrieve custom-authentication-trust-type complex type
  refcauthtrusttyp := xdb$getCustomAuthTrustType(refs);

  -- create/retrieve custom-authentication-type complex type
  refcauthtype := xdb$getCustomAuthType(refs, refcauthtrusttyp);

  -- create/retrieve expire-type complex type
  refexptype  := xdb$getConfigExpireType(refs);

  commit;

  -- update /sysconfig/httpconfig children
  xdb$updateHttpConfig(refs, refcauthtype, refexptype);

  -- add 'custom' for 'allow-mechanism' 
  -- Note: if more than one 'allow-mechanism' subelemnts will ever be added to the CONFIG schema,
  --       change this code to go through the kids of httpconfig, find 'authentication', and pick 
  --       the 'allow-mechanism' in the authentication kids
  update xdb.xdb$simple_type t
     set t.xmldata.sys_xdbpd$  = XDB.XDB$RAW_LIST_T('23020000000106'),
         t.xmldata.restriction = 
              XDB.XDB$SIMPLE_DERIVATION_T(
                  XDB.XDB$RAW_LIST_T('330008020000118B8003'), 
                  NULL, XDB.XDB$QNAME('00', 'string'), 
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                  NULL, NULL, NULL, 
                  XDB.XDB$FACET_LIST_T(
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'digest', '00', NULL), 
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'basic', '00', NULL), 
                    XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                      NULL, 'custom', '00', NULL)), 
                  NULL, NULL)
   where ref(t) = (select e.xmldata.property.smpl_type_decl from xdb.xdb$element e
                    where e.xmldata.property.name ='allow-mechanism' 
                      and e.xmldata.property.parent_schema = refs);

   commit;

  -- update sysconfig children
  xdb$updateSysConfig(refs, refcauthtrusttyp);

  commit;

  -- update complex_types list in schema to include the new custom-authentication and trust types
  -- update num_props in schema 
  r := xdb$find_cmplx_type(clistinsch, 'custom-authentication-trust-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refcauthtrusttyp;
    dbms_output.put_line('added custom-authentication-trust-type to config schema list');
  end if;
  r := xdb$find_cmplx_type(clistinsch, 'custom-authentication-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refcauthtype;
    dbms_output.put_line('added custom-authentication-type to config schema list');
  end if;
  -- update complex_types list in schema to include the new expire-type  types
  r := xdb$find_cmplx_type(clistinsch, 'expire-type', refs);
  if r is null then
    clistinsch.extend(1);
    clistinsch(clistinsch.last) := refexptype;
    dbms_output.put_line('added expire-type to config schema list');
  end if;
  
  commit;
  
  update xdb.xdb$schema s 
     set s.xmldata.complex_types = clistinsch, 
         s.xmldata.sys_xdbpd$    = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B818002828004131416120A170D'), 
         s.xmldata.num_props     = CONFIG_PRPONUMS
   where s.xmldata.schema_url = schema_url;  

  commit;
end xdb$upgradeConfigSchema;
/

show errors;

-- now upgrade XDB$CONFIG schema
exec xdb$upgradeConfigSchema;

-- drop config-specific procedures/functions
drop procedure xdb$upgradeConfigSchema;
drop procedure xdb$updateSysConfig;
drop procedure xdb$updateHttpConfig;
drop function xdb$getConfigExpireType;
drop function xdb$getCustomAuthType;
drop function xdb$getCAuthList;
drop function xdb$getCAuthMappings;
drop function xdb$getCustomAuthTrustType;
drop procedure xdb$updateConfigIpaddress;
drop function xdb$insertCfgCplxElem;

/*-----------------------------------------------------------------------*/
-- Upgrade enum type of input-filter-element to
-- <element name="input-filter-enable">
--   <simpleType>
--     <restriction base="string">
--       <enumeration value="On"/>
--       <enumeration value="Off"/>
--       <enumeration value="SecurityOn"/>
--       <enumeration value="SecurityOff"/>
--     </restriction>
--   </simpleType>
-- </element>
/*-----------------------------------------------------------------------*/
declare
  schema_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_sch_ref REF SYS.XMLTYPE;
begin

  select ref(s) into config_sch_ref
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

/*
select s.xmlextra, s.xmldata from xdb.xdb$simple_type s
 where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                  where e.xmldata.property.name ='input-filter-enable');
*/

  -- update emum type
  update xdb.xdb$simple_type s
     set s.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8004'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'SecurityOn', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'SecurityOff', '00', NULL)), NULL, NULL)
   where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                    where e.xmldata.property.parent_schema = config_sch_ref
                      and e.xmldata.property.name ='input-filter-enable');
  commit;
end;
/

/*-----------------------------------------------------------------------*/
/* End of upgrade of input-filter-element                                */
/*-----------------------------------------------------------------------*/

/* End upgrade of XDBConfig schema */

/*************************************************************************/
/********************* Upgrade XDBResConfig to 11.2 **********************/
/*************************************************************************/
Rem Manually add xlink-config/pre-condition property to XDB resource config schema

declare
  seq_ref                REF SYS.XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  attr_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  config_schema_url      VARCHAR2(100);
  config_schema_ref      REF SYS.XMLTYPE;
  elem_ref_precond       REF SYS.XMLTYPE;
  elem_typeref_precond   REF SYS.XMLTYPE;
  elem_propno            number(38);
  anypart                varchar2(4000);
begin
  config_schema_url := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';

  if not dbms_xdbmig_util.element_exists_complextype(config_schema_url, 'xlink-config', 'pre-condition') then
     select ref(s) into config_schema_ref
       from xdb.xdb$schema s
      where s.xmldata.schema_url = config_schema_url;

     select c.xmldata.sequence_kid, c.xmldata.attributes into seq_ref, attr_arr
       from xdb.xdb$complex_type c
      where c.xmldata.name = 'xlink-config'
        and c.xmldata.parent_schema = config_schema_ref;

     -- Get a list of all elements in this sequence
     select m.xmldata.elements into elem_arr
       from xdb.xdb$sequence_model m
      where ref(m) = seq_ref;

     -- create pre-condition element
     select ref(c) into elem_typeref_precond
      from xdb.xdb$complex_type c
     where c.xmldata.name = 'condition'
       and c.xmldata.parent_schema = config_schema_ref;

     insert into xdb.xdb$element e (e.xmlextra, e.xmldata) 
     values (SYS.XMLTYPEEXTRA(
                SYS.XMLTYPEPI(
                  dbms_xdbmig_util.getpickledns('http://www.w3.org/2001/XMLSchema', null), 
                  dbms_xdbmig_util.getpickledns('http://xmlns.oracle.com/xdb','xdb'),
                  dbms_xdbmig_util.getpickledns('http://xmlns.oracle.com/xdb/XDBResConfig.xsd', 
                    'rescfg')), 
                SYS.XMLTYPEPI('523030')),
             XDB.XDB$ELEMENT_T(
               XDB.XDB$PROPERTY_T(
                 XDB.XDB$RAW_LIST_T('83B800200080030C000000040532330809181B23262A3435031507292728'), 
                 config_schema_ref, xdb.xdb$propnum_seq.nextval, 'pre-condition', 
                 XDB.XDB$QNAME('02', 'condition'), NULL, '0102', '00', '00', 
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, elem_typeref_precond, 
                 NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), 
               NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', '00', '01', 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
     returning ref(e) into elem_ref_precond;

     -- extend elem_arr and add new element 
     elem_arr.extend(1);
     elem_arr(elem_arr.last)  := elem_ref_precond; 
     
     -- update child element sequence for the xlink-config complex type
     update xdb.xdb$sequence_model m
        set m.xmldata.elements   = elem_arr,
            m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800407')
      where ref(m) = seq_ref;

     -- edit annotation kidlist
     -- construct kidlist from element and attribute lists
     anypart := dbms_xdbmig_util.buildAnnotationKidList(elem_arr, attr_arr);

     update xdb.xdb$complex_type c
        set c.xmldata.annotation.appinfo =  
                XDB.XDB$APPINFO_LIST_T(
                    XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
      where c.xmldata.parent_schema = config_schema_ref
        and c.xmldata.name = 'xlink-config';

     -- no need to alter type since this is not an object type
  end if;

  commit;
end;
/

/* End upgrade of XDBResConfig schema */

Rem clean up updown utilities
@@dbmsxuducu.sql

-- drop functions
drop function xdb$find_cmplx_type;

begin
  begin
    execute immediate 'drop procedure sys.set_tablespace';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
  begin
    execute immediate 'drop procedure sys.movexdb_table';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
  begin
    execute immediate 'drop procedure sys.movexdb_table_part2';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
end;
/

Rem Data Pump has the new requirement that users granted 
Rem DATAPUMP_FULL_EXP_DATABASE be able to export in FULL mode
Rem tables in the XDB schema. The advise is actually to grant
Rem SELECT on XDB tables to the SELECT_CATALOG_ROLE, which in 
Rem turn is granted to DATAPUMP_FULL_EXP_DATABASE, to be in sync
Rem with other components to be supported by FULL export.
Rem Some XDB tables are actually allowing PUBLIC access, so this
Rem grant will be a noop for them, but some do not. 
Rem If other XDB scripts are run beyond this point,
Rem it is the responsability of the script developer to allow similar
Rem grants on any XDB-owned tables that may get created in the script.
Rem
prompt Granting SELECT on XDB tables to SELECT_CATALOG_ROLE
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set serveroutput on

declare
  type    cur_type is ref cursor;
  cur     cur_type;
  tname   varchar2(100);
  stmt    varchar2(2000);
begin
  open cur for 'select table_name from dba_tables where owner=:1 union ' ||
               'select table_name from dba_xml_tables where owner=:2 union ' ||
               'select table_name from dba_object_tables where owner=:3 '
    using 'XDB', 'XDB', 'XDB';
  loop
    fetch cur into tname;
    exit when cur%NOTFOUND;

    tname := 'XDB."' ||    tname || '"';
    stmt := 'grant select on ' || tname || ' to SELECT_CATALOG_ROLE';
    begin
       execute immediate stmt;
       exception
          when OTHERS then
             if ((SQLCODE != -22812) and (SQLCODE != -30967)) then
               dbms_output.put_line(stmt);
               dbms_output.put_line(SQLERRM);
             end if;
    end;
  end loop;
end;
/

set serveroutput off

-- Clean up session/shared state 
exec xdb.dbms_xdbutil_int.flushsession;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;




Rem ================================================================
Rem END XDB Schema Data upgrade from 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema Data upgrade from next release
Rem ================================================================

-- uncomment for next release
--@@xdbs112.sql

Rem ================================================================
Rem END XDB Schema Data upgrade from next release
Rem ================================================================
