Rem
Rem $Header: rdbms/admin/xdbpatch.sql /st_rdbms_11.2.0/18 2013/07/31 14:30:10 dmelinge Exp $
Rem
Rem xdbpatch.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbpatch.sql - Branch Specific Minor Version Patch Script for XDB
Rem
Rem    DESCRIPTION
Rem      Patches are minor releases of the database. This script, depending
Rem      on where it is checked in, attempts to migrate all the previous
Rem      minor versions of the database to the version it is checked in to.
Rem      Obviously, this is a no-op for the first major production release
Rem      in any version. In addition, the script is also expected to reload
Rem      all the related PL/SQL packages types when called via catpatch. 
Rem
Rem    NOTES
Rem      Dictionary changes are not supposed to be done in DB Minor versions,
Rem      We should conform to this directive in 10g. Also, several
Rem      irrelevant MODIFIED lines were deleted
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    07/26/13 - Backout RFI 532712, lrg 8504203
Rem    rpang       03/25/13 - 4892564: add new enum values for EPG
Rem    jkati       01/24/13 - bug 13649042 : Grant EXECUTE to XDB on
Rem                           User-defined Types that are used in the predicate
Rem                           returned by XDB VPD Policy Functions.
Rem    stirmizi    12/06/12 - create import_tt_info
Rem    dmelinge    05/07/12 - Downgrade changes for FTP host name
Rem    dmelinge    03/20/12 - Backport vhosur_b9591844 from main
Rem    dmelinge    03/20/12 - Remove unnecessary privileges on DOCUMENT_LINKS
Rem    bhammers    12/15/11 - bug 13089022: undo catxdbvfexp
Rem    bhammers    07/18/11 - bug 12674093, see below (search for 12674093)
Rem    juding      05/26/11 - Backport badeoti_bug-10168805 from main
Rem    spetride    05/16/11 - grant select to select_catalog_role
Rem    spetride    04/12/11 - Backport spetride_bug-12317504 from main
Rem    juding      04/08/11 - Backport juding_bug11071061u from main
Rem    mkandarp    03/10/11 - 11826429: SCHEMA_EXPORT_VIEW_TBL
Rem    spetride    01/11/11 - Backport badeoti_bug-10096889 from main
Rem    badeoti     08/21/10 - add schema changes during patch upgrade/downgrade
Rem    juding      08/03/10 - Backport juding_bug-9903850 from main
Rem    yiru        06/17/10 - Fix lrg 4720543 - Add XS patch
Rem    thbaby      06/08/10 - add column segattrs to xdb.xdb$xtab
Rem    badeoti     05/18/10 - lrg 4616786: xmltype table flags in sys.opqtype
Rem    juding      05/01/10 - add xdbxtbix.sql
Rem    badeoti     04/22/10 - lrg 4337840, dbms_xmlschema grant option
Rem    vhosur      03/08/10 - Fix bug 4259338
Rem    thbaby      03/01/10 - add column grppos to xdb.xdb$xidx_imp_t
Rem    thbaby      02/27/10 - add grppos, depgrppos to xdb.xdb$xtab
Rem    badeoti     02/16/10 - bug 9304342: fix-up complex type PDs
Rem    badeoti     12/21/09 - ensure limited acl table access privs for public
Rem    bhammers    11/10/09 - 8760324, set 'Unstructured Present' flag
Rem                           when upgrading XIDX from 11.2.0.1 to 11.2.0.2
Rem    sidicula    01/11/08 - Grants to DBA & System
Rem    mrafiq      11/08/05 - calling xdbrelod
Rem    mrafiq      11/08/05 - fix for bug 4721297: calling catxdbv 
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    spannala    04/30/04 - revalidate xdb at the end of patch 
Rem    najain      01/28/04 - call prvtxdz0 and prvtxdb0
Rem    spannala    12/16/03 - fix to be correct for main 
Rem    njalali     07/10/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

select dbms_registry.version('XDB') from dual;

Rem ================================================================
Rem BEGIN XDB Schema Data Patch Upgrade from earlier releases
Rem ================================================================

Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

set serveroutput on

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

-- schema_t version attribute should have length 4000
declare
  len     NUMBER;
begin
  select LENGTH into len
  from dba_type_attrs
  where owner = 'XDB' and TYPE_NAME = 'XDB$SCHEMA_T'
  and ATTR_NAME = 'VERSION';

  if(len < 4000) then
    -- DDL change to schema table
     execute immediate 
       'alter type XDB.XDB$SCHEMA_T 
        modify attribute version varchar2(4000) cascade';
     dbms_output.put_line('altered schema_t version attr');
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


/*-----------------------------------------------------------------------*/
/* Simple Upgrades for XDBResource.xsd go here  */
/*-----------------------------------------------------------------------*/
declare
  res_schema_ref  REF XMLTYPE;
begin
  select ref(s) into res_schema_ref 
    from xdb.xdb$schema s 
   where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  -- Set numcolumns for simple types to 0
  update xdb.xdb$element e
     set e.xmldata.num_cols = 0
   where e.xmldata.property.name = 'XMLRef' or
         e.xmldata.property.name = 'XMLLob' or 
         e.xmldata.property.name = 'Flags' or 
         e.xmldata.property.name = 'SBResExtra' or 
         e.xmldata.property.name = 'Snapshot' or 
         e.xmldata.property.name = 'NodeNum' or 
         e.xmldata.property.name = 'ContentSize' or 
         e.xmldata.property.name = 'SizeOnDisk' 
    and e.xmldata.property.parent_schema = res_schema_ref;

  -- IsXMLIndexed - mark unmutable
  -- container - mark unmutable
  update xdb.xdb$attribute a
     set a.xmldata.MUTABLE = '01'
   where a.xmldata.parent_schema = res_schema_ref
     and a.xmldata.name = 'IsXMLIndexed' or
         a.xmldata.name = 'Container';

  commit;
end;
/

/*-----------------------------------------------------------------------*/
/* Remove:      */
/*   /xdbconfig/xdbc:custom-authentication-trust-type/trust-scheme/workgroup  */
/*-----------------------------------------------------------------------*/
declare
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  numprops             NUMBER(38);
  refcauthtrusttype    REF SYS.XMLTYPE;
  cauthtrustskid       REF SYS.XMLTYPE;
  cauthtrustelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  reftrustsch         REF SYS.XMLTYPE;
  refCtrustsch         REF SYS.XMLTYPE;
  trustschskid       REF SYS.XMLTYPE;
  trustschelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  workgrpref      REF SYS.XMLTYPE;
  workgrpind     number := 0;
  anypart        VARCHAR2(4000);
begin
  select ref(s), s.xmldata.num_props
    into refs, numprops
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('upgrading xdbconfig schema, numprops was ' || numprops);
             
  select ref(c), c.xmldata.sequence_kid, m.xmldata.elements
    into refcauthtrusttype, cauthtrustskid, cauthtrustelems
    from xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where c.xmldata.name = 'custom-authentication-trust-type'
     and c.xmldata.parent_schema = refs
     and ref(m) = c.xmldata.sequence_kid;

  -- get trust-scheme element
  reftrustsch := cauthtrustelems(1);

  -- get trust-scheme's anonymous complex type's elements
  select ref(c), c.xmldata.sequence_kid, m.xmldata.elements 
    into refCtrustsch, trustschskid, trustschelems
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where ref(e) = reftrustsch
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  dbms_output.put_line(to_char(trustschelems.count) || ' elements under trust-scheme');
  for j in 1..trustschelems.last loop
   select e.xmldata.property.name into schema_url 
     from xdb.xdb$element e
    where ref(e) = trustschelems(j);
    
   if schema_url = 'workgroup' then
     workgrpind := j;
   end if;
   --dbms_output.put_line(to_char(j) || ': ' || schema_url);
  end loop;

  if workgrpind = 7 and trustschelems.count = 7 then
    workgrpref := trustschelems(workgrpind);
    trustschelems.trim(1);
    dbms_output.put_line('found workgroup at index ' || to_char(workgrpind));
    dbms_xdbmig_util.delete_elem_by_ref(workgrpref, true);
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = trustschelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800607')
     where ref(m) = trustschskid;

    anypart := dbms_xdbmig_util.buildAnnotationKidList(trustschelems, null);
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo =
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
     where c.xmldata.parent_schema = refs
       and ref(c)=refCtrustsch;
    update xdb.xdb$schema s
       set s.xmldata.num_props     = s.xmldata.num_props - 1
     where ref(s) = refs;
    commit;
  elsif workgrpind > 0 then
    dbms_output.put_line('Warning: workgroup property persists in 11.2.0.2 XDB config schema');
  end if;
end;
/

/*
Add:
  /xdbconfig/xdbc:custom-authentication-type/custom-authentication-mappings/custom-authentication-mapping/on-deny
  /xdbconfig/sysconfig/localApplicationGroupStore
*/ 
declare
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  numprops             NUMBER(38);
  refcauthmapp         REF SYS.XMLTYPE;
  refcauthmappctype       REF SYS.XMLTYPE;
  cauthmappskid       REF SYS.XMLTYPE;
  cauthmappelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  ref_ondeny    REF SYS.XMLTYPE;
  anypart        VARCHAR2(4000);
  ref_localappgrpstore    REF SYS.XMLTYPE;
  refsystype     REF SYS.XMLTYPE;
  refskidsys     REF SYS.XMLTYPE;
  skidsyselems   XDB.XDB$XMLTYPE_REF_LIST_T;
  new_cfgprop_count   number := 0;
begin
  select ref(s), s.xmldata.num_props
    into refs, numprops
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('add on-deny to xdbconfig schema, numprops was ' || numprops);

  -- get custom-authentication-mapping element and its complex-type children
  select ref(e), ref(c), c.xmldata.sequence_kid, m.xmldata.elements
    into refcauthmapp, refcauthmappctype, cauthmappskid, cauthmappelems
  from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
  where e.xmldata.property.name = 'custom-authentication-mapping'
    and e.xmldata.property.parent_schema = refs
    and ref(c) = e.xmldata.cplx_type_decl
    and ref(m) = c.xmldata.sequence_kid;
 
  dbms_output.put_line(to_char(cauthmappelems.count) || ' elements under trust-scheme');
  ref_ondeny := dbms_xdbmig_util.find_child(cauthmappelems, 'on-deny');

  if ref_ondeny is null then
    -- create the simple type for on-deny
    insert into xdb.xdb$simple_type t (t.xmlextra, t.xmldata)
    values(dbms_xdbmig_util.getConfigXtra,
           XDB.XDB$SIMPLE_T(
             XDB.XDB$RAW_LIST_T('23020000000106'), refs, NULL, '00', 
             XDB.XDB$SIMPLE_DERIVATION_T(
               XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), 
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
               XDB.XDB$FACET_LIST_T(
                 XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                 'next-custom', '00', NULL), 
                 XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 
                                 'basic', '00', NULL)), 
               NULL, NULL), 
             NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(t) into ref_ondeny_typ;
    
    -- create the on-deny element
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
      values(dbms_xdbmig_util.getConfigXtra,
             XDB.XDB$ELEMENT_T(
               XDB.XDB$PROPERTY_T(
                 XDB.XDB$RAW_LIST_T('839A1020008003040000000432010809181B23262A343503150C07292728'), 
                 refs, xdb.xdb$propnum_seq.nextval, 'on-deny', NULL, NULL, '0103', '00', '00', 
                 NULL, NULL, 'string', NULL, NULL, NULL, 
                 ref_ondeny_typ, ref_ondeny_typ,
                 NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), 
               NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, 
               NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into ref_ondeny;
    cauthmappelems.extend(1);
    cauthmappelems(cauthmappelems.last) := ref_ondeny;
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = cauthmappelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800507')
     where ref(m) = cauthmappskid;
  
    anypart := dbms_xdbmig_util.buildAnnotationKidList(cauthmappelems, null);
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo =
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
     where c.xmldata.parent_schema = refs
       and ref(c)=refcauthmappctype;
    dbms_output.put_line('added on-deny to trust-scheme child list');
    commit;
    new_cfgprop_count := new_cfgprop_count + 1;
  end if;

  -- add localApplicationGroupStore
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements
    into refsystype, refskidsys, skidsyselems 
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where e.xmldata.property.name ='sysconfig' 
     and e.xmldata.property.parent_schema = refs 
     and ref(c) = e.xmldata.cplx_type_decl
     and ref(m) = c.xmldata.sequence_kid;

  dbms_output.put_line(to_char(skidsyselems.count) || ' elements under sysconfig');
  ref_localappgrpstore := dbms_xdbmig_util.find_child(skidsyselems, 'localApplicationGroupStore');
  if ref_localappgrpstore is null then
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values (dbms_xdbmig_util.getConfigXtra,
         XDB.XDB$ELEMENT_T(
           XDB.XDB$PROPERTY_T(
             XDB.XDB$RAW_LIST_T('83B890200080030400000004050F320809181B23262A343503150C07292728'),
             refs,
             xdb.xdb$propnum_seq.nextval, 'localApplicationGroupStore', XDB.XDB$QNAME('00', 'boolean'),
             NULL, 'FC', '00', '00', NULL, NULL, 'boolean', NULL, NULL, 'true',
             NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'),
           NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', 
           NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into ref_localappgrpstore;
    skidsyselems.extend(1);
    skidsyselems(skidsyselems.last) := ref_localappgrpstore;
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = skidsyselems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801C07')
     where ref(m) = refskidsys; 

    anypart := dbms_xdbmig_util.buildAnnotationKidList(skidsyselems, null);
    update xdb.xdb$complex_type c
       set c.xmldata.annotation.appinfo =
              XDB.XDB$APPINFO_LIST_T(
                  XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
     where c.xmldata.parent_schema = refs
       and ref(c)=refsystype;
    dbms_output.put_line('added localApplicationGroupStore to sysconfig child list');
    commit;
    new_cfgprop_count := new_cfgprop_count + 1;
  end if;

  -- update xdbconfig num_props
  update xdb.xdb$schema s
     set s.xmldata.num_props     = s.xmldata.num_props + new_cfgprop_count
   where ref(s) = refs;
  commit;
end;
/
  
Rem clean up updown utilities
-- @@dbmsxuducu.sql -This has been moved down.

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

Rem clean up updown utilities
@@dbmsxuducu.sql

Rem bug 12674093, we need to bring xdb packages (especially dbms_xsc_int) to
Rem 11.2.0.3 version before executing the next pl/sql blocks.
@@xdbptrl1.sql    

Rem ================================================================
Rem BEGIN XDB User Data Patch Upgrade from earlier releases
Rem ================================================================

/* Grant EXECUTE to XDB on User-defined Types that are used in the predicate
 * returned by XDB VPD Policy Functions.
*/
DECLARE
 stmt          CLOB;
 TYPE          refcurs IS REF CURSOR;
 curs          refcurs;
 type_name     VARCHAR2(128);
 schema_name   VARCHAR2(128);
 sqltxt        VARCHAR2(300);
BEGIN
  stmt := 'select distinct po.name, u.name from' ||
          ' dependency$ dep, dba_xml_schemas x, obj$ do, obj$ po, user$ u' ||
          ' where do.obj#=dep.d_obj# and po.obj#=dep.p_obj# and do.type#=55' ||
          ' and do.name=x.int_objname and po.type#=13 and po.owner#=u.user#';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO type_name,schema_name;
    EXIT WHEN curs%NOTFOUND;
      sqltxt := 'grant execute on ' ||
                dbms_assert.enquote_name(schema_name, FALSE) || '.' || 
                dbms_assert.enquote_name(type_name, FALSE) || ' to xdb';
      EXECUTE IMMEDIATE sqltxt;
  END LOOP;
END;
/
          
/*
 * Updates for XDB DEFAULT CONFIG
 */

-- (Re-)Insert the authentication element into xdbconfig.xml
declare
  auth_count      INTEGER := 0;
  auth_frag xmltype;
  cfg xmltype;
begin
   cfg := dbms_xdb.cfg_get();
   begin
   select 1 into auth_count from dual
    where XMLExists(
       'declare namespace c = "http://xmlns.oracle.com/xdb/xdbconfig.xsd";
        /c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication'
        PASSING cfg);
   exception 
     when no_data_found then null;
   end;
 
   -- enable INSERTXMLBEFORE, APPENDCHILDXML, DELETEXML(4)
   -- Turn on rewrite for updxml/delxml/insertxml over collections(128)
   execute immediate 
     'alter session set events ''19027 trace name context forever, level 132'' ';

   if auth_count = 0 then
     auth_frag := xmltype('<authentication xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"><allow-mechanism>basic</allow-mechanism><digest-auth><nonce-timeout>300</nonce-timeout></digest-auth></authentication>');
   else
     -- extract authentication fragment for later re-insertion
     dbms_output.put_line('authentication fragment existed, deleting');
     auth_frag := cfg.extract('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication');
     select deletexml (cfg,
        '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication',
        'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
     into cfg from dual;
   end if;

   dbms_output.put_line('inserting authentication fragment');
   select insertchildxml (cfg,
       '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig',
       'authentication',
       auth_frag,
       'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
   into cfg from dual;
   dbms_output.put_line('updating xdbconfig doc');
   dbms_xdb.cfg_update(cfg); 
  end;
/

begin
-- set 'UNSTRUCTURED PRESENT' flag for all unstructured and hybrid  
-- XML indexes where flag is not set, yet.  Flag is set if and only if
-- XML index is NOT a structured-only index. A structured only index is
-- characterized by dxptab.idxobj# == dxptab.pathtabobj# because it has no 
-- path table. 
execute immediate 'UPDATE xdb.xdb$dxptab dxptab
                   SET dxptab.flags = dxptab.flags + 268435456 
                   WHERE bitand(dxptab.flags, 268435456) = 0 
                     AND dxptab.idxobj# != dxptab.pathtabobj#';
exception
  when others then dbms_output.put_line('XDBNB: flag update failed');
end;
/
commit;


-- Explicit grants to DBA,System; "any" privileges are no more applicable for 
-- XDB tables. Listing these specifically since there are certain tables
-- for which we dont grant full access by default even to DBA & System.
-- (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.)
grant all on XDB.XDB$RESOURCE to dba;
grant all on XDB.XDB$RESOURCE to system with grant option;
grant all on XDB.XDB$H_INDEX to dba;
grant all on XDB.XDB$H_INDEX to system with grant option;
grant all on XDB.XDB$H_LINK to dba;
grant all on XDB.XDB$H_LINK to system with grant option;
grant all on XDB.XDB$D_LINK to dba;
grant all on XDB.XDB$D_LINK to system with grant option;
grant all on XDB.XDB$NLOCKS to dba;
grant all on XDB.XDB$NLOCKS to system with grant option;
grant all on XDB.XDB$WORKSPACE to dba;
grant all on XDB.XDB$WORKSPACE to system with grant option;
grant all on XDB.XDB$CHECKOUTS to dba;
grant all on XDB.XDB$CHECKOUTS to system with grant option;
grant all on XDB.XDB$ACL to dba;
grant all on XDB.XDB$ACL to system with grant option;
grant all on XDB.XDB$CONFIG to dba;
grant all on XDB.XDB$CONFIG to system with grant option;
grant all on XDB.XDB$RESCONFIG to dba;
grant all on XDB.XDB$RESCONFIG to system with grant option;
grant all on XDB.XS$DATA_SECURITY to dba;
grant all on XDB.XS$DATA_SECURITY to system with grant option;
grant all on XDB.XS$PRINCIPALS to dba;
grant all on XDB.XS$PRINCIPALS to system with grant option;
grant all on XDB.XS$ROLESETS to dba;
grant all on XDB.XS$ROLESETS to system with grant option;
grant all on XDB.XS$SECURITYCLASS to dba;
grant all on XDB.XS$SECURITYCLASS to system with grant option;

-- ensure that public has limited privileges on acl table
revoke all on XDB.XDB$ACL from public;
grant select, insert, update, delete on XDB.XDB$ACL to public;
commit;

-- lrg 4337840
-- Remove 'with grant option' by revoking rights and
-- re-granting without grant option.
revoke execute on XDB.DBMS_XMLSCHEMA from public;
revoke execute on XDB.DBMS_XMLSCHEMA_INT from public;

-- Both sys and xdb might appear as grantors, revoke again
BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA_INT from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

grant execute on XDB.DBMS_XMLSCHEMA to public;
grant execute on XDB.DBMS_XMLSCHEMA_INT to public;

declare
  suf  varchar2(26);
  stmt varchar2(2000);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;
  stmt := 'grant all on XDB.X$PT' || suf || ' to DBA';
  execute immediate stmt;
  stmt := 'grant all on XDB.X$PT' || suf || ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;
/

drop table XDB.XDB$XIDX_IMP_T;
create global temporary table XDB.XDB$XIDX_IMP_T
                                (index_name VARCHAR2(40), 
                                 schema_name VARCHAR2(40),
                                 id VARCHAR2(40), 
                                 data CLOB,
                                 grppos NUMBER)
       on commit preserve rows;
grant insert, select, delete on XDB.XDB$XIDX_IMP_T to public;

/*************** Create XDB.XDB$IMPORT_TT_INFO table *****************/
begin
   execute immediate
      'create table xdb.xdb$import_tt_info( 
          guid     raw(16), 
          nmspcid      raw(8),
          localname    varchar2(2000),
          flags        raw(4),
          id           raw(8))';
  exception
       when others then
         -- raise no error if table already exists
         NULL;
end;
/

grant select,insert,update,delete on xdb.xdb$import_tt_info to public;

-- add columns 'GRPPOS' and 'DEPGRPPOS' to xdb.xdb$xtab
-- add column 'SEGATTRS' to xdb.xdb$xtab
declare
  col_num     number;
  xtab_obj#   number;
  length      number;
begin
  
  SELECT OBJ# INTO xtab_obj#
  FROM OBJ$ O, USER$ U
  WHERE O.NAME = 'XDB$XTAB'
    AND O.OWNER# = U.USER#
    AND U.NAME ='XDB';

  SELECT COLS INTO col_num
  FROM TAB$
  WHERE OBJ# = xtab_obj#;

  if col_num <> 11 then
    EXECUTE IMMEDIATE
      'ALTER TABLE XDB.XDB$XTAB ADD (
         GRPPOS      NUMBER)';
    EXECUTE IMMEDIATE
      'ALTER TABLE XDB.XDB$XTAB ADD (
         DEPGRPPOS      NUMBER)';
    EXECUTE IMMEDIATE
      'ALTER TABLE XDB.XDB$XTAB ADD (
         SEGATTRS       VARCHAR2(4000))';
    EXECUTE IMMEDIATE
      'UPDATE XDB.XDB$XTAB SET GRPPOS = 0';
    EXECUTE IMMEDIATE
      'UPDATE XDB.XDB$XTAB SET DEPGRPPOS = 0';
    EXECUTE IMMEDIATE
      'UPDATE XDB.XDB$XTAB SET SEGATTRS = NULL';
  end if;
end;
/

-- change indexes for xdb.xdb$xtab, xdb.xdb$xtabnmsp, xdb.xdb$xtabcols
declare
  need_upgrade number;
begin
  select count(*) into need_upgrade
  from DBA_INDEXES
  where TABLE_OWNER = 'XDB'
  and TABLE_NAME = 'XDB$XTAB'
  and INDEX_NAME = 'XDB$IDXXTAB';

  if need_upgrade <> 0 then
    EXECUTE IMMEDIATE
      'drop index xdb.xdb$idxxtab';
    EXECUTE IMMEDIATE
      'drop index xdb.xdb$idxtabnmsp';
    EXECUTE IMMEDIATE
      'drop index xdb.xdb$idxtabnmsp_xmltabobj';
    EXECUTE IMMEDIATE
      'drop index xdb.xdb$idxtabcols';
    EXECUTE IMMEDIATE
      'drop index xdb.xdb$idxtabcols_xmltabobj';
    EXECUTE IMMEDIATE
      'create index xdb.xdb$idxxtab_1 on xdb.xdb$xtab(idxobj#, groupname, ptabobj#)';
    EXECUTE IMMEDIATE
      'create index xdb.xdb$idxxtab_2 on xdb.xdb$xtab(idxobj#, depgrppos, xmltabobj#)';
    EXECUTE IMMEDIATE
      'create index xdb.xdb$idxtabnmsp_1 on xdb.xdb$xtabnmsp(idxobj#, groupname, xmltabobj#, flags)';
    EXECUTE IMMEDIATE
      'create index xdb.xdb$idxtabcols_1 on xdb.xdb$xtabcols(idxobj#, groupname, xmltabobj#)';
  end if;
end;
/

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

-- fix for lrg 4720543, drop PREDICATE xmlindex for upgrade from 
-- 11.2.0.1 to 11.2.0.2
@@xspatch.sql

set serveroutput off
--fix for lrg 1957560
--replaced all the other files by xdbrelod as it loads all the files
--which were being loaded before including catxdbv which is needed for fixing 
--lrg 1957560
@@xdbrelod.sql

@@xdbxtbix.sql

set serveroutput on
-- check status of xdb schema cache event
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
  -- set level 0x8000 
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                                utl_raw.cast_from_binary_integer(lev),
                                utl_raw.cast_from_binary_integer(32768)))), '0');
  -- make sure event is set
  execute immediate
    'alter session set events ''31150 trace name context forever, level ' ||
    newlvls || ''' ';
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
end;
/

-- additionally, trace any further lxs-0002x errors 
alter session set events '31061 trace name errorstack level 3, forever';

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


Rem ================================================================
Rem BEGIN resecure DOCUMENT_LINKS
Rem ================================================================

Rem
Rem DOCUMENT_LINKS was incorrectly granted insert, update, and delete
Rem permissions for PUBLIC.  Revoke them.  Bug 13019222.
Rem

BEGIN
EXECUTE IMMEDIATE 'revoke insert on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke update on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke delete on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/
show errors;

Rem ================================================================
Rem END resecure DOCUMENT_LINKS
Rem ================================================================

Rem ================================================================
Rem Remove Views and callout registries for XDB datapump export/import
Rem ================================================================

-- remove registered callouts 
declare
  stmt varchar2(10000);
begin
  begin
    stmt := 
       'delete from sys.impcalloutreg$ where tag = ''XDB_REPOSITORY''';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
  begin
    stmt := 'delete from sys.exppkgact$ where package = ''' || 
            'DBMS_XDBUTIL_INT' || ''' and schema=''' || 'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
end;
/


-- remove views. tables, public synonyms, function
declare
  stmt varchar2(10000);
begin
  begin
    stmt := 
       'drop table SYS.XML_TABNAME2OID_VIEW_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop public synonym XML_TABNAME2OID_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view SYS.XML_TABNAME2OID_VIEW ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table XDB.XDB$RESOURCE_EXPORT_VIEW_TBL ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop view XDB.XDB$RESOURCE_EXPORT_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table DBA_XML_SCHEMA_DEPENDENCY_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table DBA_TYPE_XMLSCHEMA_DEP_TBL ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
  begin
    stmt := 
       'drop public synonym DBA_TYPE_XMLSCHEMA_DEP';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view DBA_TYPE_XMLSCHEMA_DEP';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attrgroup_ref_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attrgroup_ref_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attrgroup_def_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attrgroup_def_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$anyattr_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$anyattr_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$any_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$any_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$element_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$element_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$attribute_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$attribute_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$group_ref_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$group_ref_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$group_def_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop view xdb.xdb$group_def_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$sequence_model_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$sequence_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;


  begin
    stmt := 
       'drop table xdb.xdb$choice_model_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop  view xdb.xdb$choice_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop  table xdb.xdb$all_model_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$all_model_view ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$complex_type_view_tbl ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$complex_type_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table xdb.xdb$simple_type_view_tbl';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view xdb.xdb$simple_type_view';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

  begin
    stmt := 
       'drop table XDB.XDB$SCHEMA_EXPORT_VIEW_TBL';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
   begin
    stmt := 
       'drop view XDB.XDB$SCHEMA_EXPORT_VIEW';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;

   begin
    stmt := 
       'drop function getUserIdOnTarget';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
 
end;
/


set serveroutput off
