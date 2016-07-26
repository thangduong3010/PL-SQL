Rem
Rem $Header: rdbms/admin/xdbes112.sql /st_rdbms_11.2.0/4 2013/07/31 14:30:10 dmelinge Exp $
Rem
Rem xdbes112.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbes112.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    07/30/13 - Backout RFI 532712, lrg 8504203
Rem    rpang       03/25/13 - XbranchMerge rpang_epg_4892564 from main
Rem    rpang       11/01/12 - 4892564: remove new enum values for EPG
Rem    dmelinge    04/23/12 - Downgrade changes for FTP host name
Rem    juding      07/28/11 - Get previous_version from CATPROC when it is NULL
Rem    juding      07/22/11 - Check previous_version for on-deny
Rem    hxzhang     07/14/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

set serveroutput on

-- Resource container - mark mutable
declare
  res_schema_ref  REF XMLTYPE;
begin
  select ref(s) into res_schema_ref                                                   from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '00'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'Container';
    
  commit;
end;
/   

/*-----------------------------------------------------------------------*/
/* Re-add:      */
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
  previous_version varchar2(30);
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if not (previous_version like '11.2.0.1%')
  then
    return;
  end if;

  select ref(s), s.xmldata.num_props
    into refs, numprops
    from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

  dbms_output.put_line('downgrading xdbconfig schema, numprops was ' || numprops);
             
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
   -- dbms_output.put_line(to_char(j) || ': ' || schema_url);
  end loop;

  if workgrpind = 0 and trustschelems.count = 6 then
    dbms_output.put_line('did not find workgroup, adding it');
    -- insert workgroup element
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata)
    values(XMLTYPEEXTRA(
            XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
                      '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
                      '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
            XMLTYPEPI('523030')),
           XDB.XDB$ELEMENT_T(
             XDB.XDB$PROPERTY_T(
               XDB.XDB$RAW_LIST_T('83B810200080030C000000040532330809181B23262A343503150C07292728'), 
               refs, xdb.xdb$propnum_seq.nextval, 'workgroup', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, NULL, 
               'string', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', 
               NULL, NULL, '00'), 
             NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, 
             NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL,
             NULL, NULL, NULL, NULL))
      returning ref(e) into workgrpref;
    trustschelems.extend(1);
    trustschelems(trustschelems.last) := workgrpref;
    update xdb.xdb$sequence_model m
       set m.xmldata.elements   = trustschelems,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800707')
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
       set s.xmldata.num_props     = s.xmldata.num_props + 1
     where ref(s) = refs;
    commit;
  elsif workgrpind > 0 then
    dbms_output.put_line('workgroup property existed');
  end if;
end;
/

/*-----------------------------------------------------------------------*/
/* Remove:      */
/*   /xdbconfig/xdbc:custom-authentication-type/custom-authentication-mappings/custom-authentication-mapping/on-deny */
/*-----------------------------------------------------------------------*/

declare
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  refcauthmapp         REF SYS.XMLTYPE;
  refcauthmappctype       REF SYS.XMLTYPE;
  cauthmappskid       REF SYS.XMLTYPE;
  cauthmappelems   XDB.XDB$XMLTYPE_REF_LIST_T;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  ref_ondeny    REF SYS.XMLTYPE;
  anypart        VARCHAR2(4000);
  new_cfgprop_count   number := 0;
  previous_version varchar2(30);
begin

  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if not (previous_version like '11.2.0.1%')
  then
    return;
  end if;

  select ref(s) into refs from xdb.xdb$schema s
     where s.xmldata.schema_url = schema_url;

  select ref(e), ref(c), c.xmldata.sequence_kid, m.xmldata.elements
    into refcauthmapp, refcauthmappctype, cauthmappskid, cauthmappelems
  from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
  where e.xmldata.property.name = 'custom-authentication-mapping'
    and e.xmldata.property.parent_schema = refs
    and ref(c) = e.xmldata.cplx_type_decl
    and ref(m) = c.xmldata.sequence_kid;

  if cauthmappelems.count = 5 then 
    -- ref to the on-deny element and its simple type
    select ref(e), e.xmldata.property.smpl_type_decl into ref_ondeny, ref_ondeny_typ
    from xdb.xdb$element e
    where e.xmldata.property.name='on-deny' and e.xmldata.property.parent_schema = refs;

    ------- Lets now do the cleanup
    cauthmappelems.trim(1);
  
    update xdb.xdb$sequence_model m
           set m.xmldata.elements   = cauthmappelems,    
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800407')
           where ref(m) = cauthmappskid;

    anypart := dbms_xdbmig_util.buildAnnotationKidList(cauthmappelems, null);

    update xdb.xdb$complex_type c
           set c.xmldata.annotation.appinfo =
           XDB.XDB$APPINFO_LIST_T(
                XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)),
           c.xmldata.annotation.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('1301000000')
           where c.xmldata.parent_schema = refs and ref(c)=refcauthmappctype;

    delete from xdb.xdb$element e where ref(e)=ref_ondeny;
    delete from xdb.xdb$simple_type t where ref(t)=ref_ondeny_typ;

    update xdb.xdb$schema s
           set s.xmldata.num_props = (s.xmldata.num_props - 1) 
           where ref(s) = refs;

    commit;

  end if;

end;
/


-- Downgrade enum type of input-filter-element to
-- <element name="input-filter-enable">
--   <simpleType>
--     <restriction base="string">
--       <enumeration value="On"/>
--       <enumeration value="Off"/>
--     </restriction>
--   </simpleType>
-- </element>

begin
  -- Revert 12.1 enum values to old "Off" value for some minimal security check
  for r in (select svt.*
              from xdb.xdb$config cfg,
                   xmltable(
                     xmlnamespaces(
                       default 'http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
                     '//httpconfig//servlet[servlet-language="PL/SQL"]'
                     passing cfg.object_value
                     columns
                       name
                         varchar2(4000) path 'servlet-name',
                       input_filter_enable
                         varchar2(4000) path 'plsql/input-filter-enable') svt)
  loop
    if (   r.input_filter_enable = 'SecurityOn'
        or r.input_filter_enable = 'SecurityOff') then
        dbms_epg.set_dad_attribute(r.name, 'input-filter-enable', 'Off');
    end if;
  end loop;
end;
/

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
     set s.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL)), NULL, NULL)
   where ref(s) = (select e.xmldata.property.type_ref from xdb.xdb$element e
                    where e.xmldata.property.parent_schema = config_sch_ref
                      and e.xmldata.property.name ='input-filter-enable');
  commit;
end;
/

Rem clean up updown utilities
@@dbmsxuducu.sql
