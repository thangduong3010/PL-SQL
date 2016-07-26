Rem
Rem $Header: rdbms/admin/xdbs9202.sql /main/29 2010/06/23 09:59:36 badeoti Exp $
Rem
Rem xdbs9202.sql
Rem
Rem Copyright (c) 2003, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbs9202.sql - XDB Upgrade Schemas from 9.2.0.2
Rem
Rem    DESCRIPTION
Rem      Upgrades the bootstrap schemas from 9.2.0.2 to 10.1 and onward
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     05/18/10 - lrg 4616786: xmltype table flags in sys.opqtype
Rem    badeoti     04/19/10 - Bug 9591348
Rem    samane      10/24/09 - Bug 8609997
Rem    sidicula    02/23/09 - Fix 9201 schema-for-schemas
Rem    mrafiq      08/16/07 - remove 'alter type reset' for facet list
Rem    yifeng      06/11/07 - lrg 3002028: set event 22838 to allow dbms_sql
Rem                           update SYS_NC columns directly
Rem    kquinn      06/14/05 - 4421376: use event 10519 
Rem    vkapoor     04/13/05 - Bug 4294239
Rem    vkapoor     02/11/05 - LRG 1828813
Rem    spannala    05/04/04 - enabling 10g upgrade
Rem    thbaby      01/30/04 - adding 10g upgrade 
Rem    spannala    12/29/03 - fixing bug 3335694: refcount property is 
Rem                           read-only in 10g 
Rem    abagrawa    11/10/03 - Uncomment facet_list_t increase 
Rem    spannala    10/21/03 - move creation of migr9202status to xdbdbmig 
Rem    spannala    09/11/03 - status at the end of 9202 upgrade can be 600 
Rem    najain      08/19/03 - add HierSchmResource property
Rem    spannala    08/25/03 - moving xdbptrl1 to the end of xdbs9202.sql
Rem    spannala    08/21/03 - moving lcr upgrade to copy-evolve 
Rem    sichandr    07/10/03 - fix LCR upgrade for new element
Rem    athusoo     07/21/03 - Change the PD for lu and partition elements
Rem    spannala    07/15/03 - lcr_migrate update
Rem    spannala    07/09/03 - Add complex types to the base schema
Rem    spannala    07/03/03 - upgrade for schemaLocation-mappings
Rem    spannala    06/26/03 - moving lcr upgrade down
Rem    spannala    06/24/03 - remove enable_hierarchy
Rem    sidicula    06/17/03 - LCR upgrade should use status > 480
Rem    spannala    06/17/03 - Disable hierarchy on config for upgrade
Rem    athusoo     06/17/03 - config upgrade fixes
Rem    spannala    06/16/03 - removing linebreaks from hex numbers
Rem    athusoo     06/16/03 - add missing quote
Rem    athusoo     05/15/03 - Upgrade support for xdbcore-xobmem-bound 
Rem                           and xdbcore-loadableunit-size parameters
Rem    sidicula    05/01/03 - ACL schema should be upgraded only if necessary
Rem    sidicula    03/14/03 - ACL Schema upgrade
Rem    sichandr    03/26/03 - upgrade LCR schema
Rem    njalali     02/21/03 - njalali_bug-2796015
Rem    njalali     02/11/03 - Created
Rem

alter session set events '22838 trace name context forever';

/* Update information for XMLType Table/Columns */
update opqtype$ op
set op.flags = utl_raw.cast_to_binary_integer
               (
                  utl_raw.bit_or
                  (
                     utl_raw.cast_from_binary_integer(op.flags), 
                     utl_raw.cast_from_binary_integer(32)
                  )
               )
where (op.obj#, op.intcol#) in 
   (select opq.obj#, opq.intcol#
    from obj$ o, user$ u, xdb.xdb$element e, sys.opqtype$ opq, col$ c
    where o.owner#=u.user#
    and e.xmldata.default_table is not null
    and e.xmldata.sql_inline = '00'
    and e.xmldata.property.global = '00' 
    and u.name = e.xmldata.default_table_schema
    and o.name = e.xmldata.default_table
    and opq.obj# = o.obj#
    and c.obj# = opq.obj# and c.intcol# = opq.intcol#
    and bitand(c.property, 512) = 512 /* rowinfo column */ 
    );

-- Procedure to make sure we ignore exceptions in case facet_list
-- is already 64K.
-- We check for exception 22324 and then make sure exception PLS-00728 
-- was also thrown. PLS-00728 is exception 
-- "the limit of a VARRAY can only be increased..."
create or replace procedure increase_facet_list_size as
  facet_max_limit EXCEPTION;
  PRAGMA EXCEPTION_INIT(facet_max_limit, -22324);
begin
  execute immediate 'alter type xdb.xdb$facet_list_t modify limit ' ||  
                    '65535 cascade including table data';
exception
  when facet_max_limit then
    if (SQLERRM like '%PLS-00728%') then
      NULL;
    else
      RAISE;
    end if;
end;
/
show errors;

Rem Allow ALTER TYPE RESET
alter session set events '10519 trace name context forever';

Rem Alter the faect list type to have 64k elements instead of 1000
Rem as it used to have in 9i
declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 410) then
    execute immediate 'alter type xdb.xdb$simplecont_ext_t compile specification reuse settings';
    execute immediate 'alter type xdb.xdb$complex_derivation_t compile specification reuse settings';
    execute immediate 'alter type xdb.xdb$content_t compile specification reuse settings';
    execute immediate 'update xdb.migr9202status set n = 410';
    execute immediate 'commit';
  end if;

  increase_facet_list_size();
end;
/

alter session set events '10519 trace name context off';

Rem XML DB doesn't support the presence of empty varrays, but we get one
Rem as a result of a bug in the 9.2.0.1.0/9.2.0.2.0 schema for schema 
Rem bootstrapping process.
update xdb.xdb$complex_type c set c.xmldata.attributes = null 
  where c.xmldata.name = 'annotation';


Rem Function to insert new bootstrap schema elements
create or replace function xdb.xdb$insertElement(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2,
                sqlschema       varchar2,
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                subs_group      xdb.xdb$qname,
                num_cols        integer,
                nillable        raw,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                abstract        raw,
                mem_inline      raw,
                sql_inline      raw,
                java_inline     raw,
                maintain_dom    raw,
                default_table   varchar2,
                table_storage   varchar2,
                java_classname  varchar2,
                bean_classname  varchar2,
                global          raw,
                base_sqlname    varchar2,
                cplx_type_decl  ref sys.xmltype,
                subs_group_refs xdb.xdb$xmltype_ref_list_t,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype is
                elem_i xdb.xdb$element_t;
                elem_ref ref sys.xmltype;
        begin
                elem_i := xdb.xdb$element_t(
                            xdb.xdb$property_t(null,parent_schema,prop_number,
                                  name,typename,
                                  mem_byte_length,mem_type_code,system,
                                  mutable,null,
                                  sqlname,sqltype,sqlschema,java_type,
                                  default_value,smpl_type_decl,type_ref,
                                  propref_name,propref_ref,
                                  null, null, global,null,
                                  sqlcolltype, sqlcollschema,
                                  hidden, transient, null, baseprop),
                                subs_group,num_cols,nillable,
                                final_info,block,abstract,
                                mem_inline,sql_inline,java_inline,
                                maintain_dom,default_table,'XDB',
                                table_storage,java_classname,bean_classname,
                                base_sqlname,cplx_type_decl,
                                subs_group_refs, null,
                                min_occurs,to_char(max_occurs),
                                null,null,null,null,null,null,null,null);

  execute immediate 'insert into xdb.xdb$element e (xmldata) 
  values (:1) returning ref(e) into :2' using elem_i returning into elem_ref;

                return elem_ref;
        end;
/

show errors;

create or replace function xdb.xdb$insertAttr(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype is 
                attr_i xdb.xdb$property_t;
                attr_ref ref sys.xmltype;
        begin
                attr_i := xdb.xdb$property_t(null,parent_schema,prop_number,name,
                                typename,
                                mem_byte_length,mem_type_code,
                                system,mutable,null,
                                sqlname,sqltype,sqlschema,java_type,    
                                default_value,smpl_type_decl,type_ref,
                                propref_name, propref_ref, 
                                null, null,null,null,sqlcolltype,sqlcollschema,
                                hidden, transient, null, baseprop);

                execute immediate  
                  'insert into xdb.xdb$attribute a (xmldata) 
                   values (:1) returning ref(a) into :2' using attr_i 
                        returning into attr_ref;

                return attr_ref;
        end;
/
show errors;



Rem Add FINAL_INFO to XDB.XDB$SIMPLE_T
Rem STAUS NUMBER USED 420
declare
  m integer;
  rc  integer;
  cur integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 420) then
    cur := dbms_sql.open_cursor;
    dbms_sql.parse(
      cur, 
      'alter type xdb.xdb$simple_t add attribute 
           ("FINAL_INFO" XDB.XDB$DERIVATIONCHOICE) cascade',
      dbms_sql.native);
    rc := dbms_sql.execute(cur);
    dbms_sql.close_cursor(cur);
    update xdb.migr9202status set n = 420;
    commit;
  end if;
end;
/

Rem Add the 'text' element and 'final' attribute to the schema for schemas
Rem Repeatable -- does not use status
declare
  T_CLOB       CONSTANT RAW(2) :='70';
  PN_TOTAL_PROPNUMS CONSTANT INTEGER := 271;
  PN_SIMPLE_FINAL          CONSTANT INTEGER := 270;
  TRUE         CONSTANT RAW(1) := '1';
  FALSE        CONSTANT RAW(1) := '0';
  TR_STRING    CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 'string');
  JT_STREAM    CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('a');
  schels       xdb.xdb$xmltype_ref_list_t;
  num_props    integer;
  schref       REF sys.xmltype;
  T_ENUM       CONSTANT RAW(2) :='103';
  JT_ENUM      CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('f');
  drv_choice_ref ref sys.xmltype;
  attlist      xdb.xdb$xmltype_ref_list_t;

begin

-- Add the new property only if it wasn't already added
 select s.xmldata.num_props into num_props from xdb.xdb$schema s where
    s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

 if num_props = 269 then

   select ref(s) into schref from xdb.xdb$schema s where
      s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

-- Insert the 'text' element
   select s.xmldata.elements into schels from xdb.xdb$schema s where
      s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

   schels.extend();
   schels(14) := xdb.xdb$insertElement(
                schref, 269, 'text', TR_STRING,
                0, null, null, T_CLOB, FALSE, FALSE, 
                FALSE, null, null,null,JT_STREAM,
                null, null,null,null,null, 
                null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                null, null, null, null, TRUE, null, null, null);
   update xdb.xdb$schema s set
     s.xmldata.elements = schels, 
     s.xmldata.num_props = PN_TOTAL_PROPNUMS
         where s.xmldata.schema_url = 
           'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

-- Insert the 'final' attribute
   select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'simpleType' and
      c.xmldata.parent_schema = schref
    for update;
   select ref(s) into drv_choice_ref from xdb.xdb$simple_type s where 
     s.xmldata.name = 'derivationChoice' and
     s.xmldata.parent_schema = schref;
   attlist.extend();
   attlist(5) := xdb.xdb$insertAttr(schref, PN_SIMPLE_FINAL, 'final', 
                               xdb.xdb$qname('01', 'derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'FINAL_INFO',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM,
                               null, null, drv_choice_ref,null,null);
   execute immediate 'update xdb.xdb$complex_type c set 
     c.xmldata.attributes = :1
   where
      c.xmldata.name = ''simpleType'' and
      c.xmldata.parent_schema = :2'
   using attlist, schref;

   commit;
 end if;
end;
/
show errors

Rem Output should be '271'
select s.xmldata.num_props from xdb.xdb$schema s where
    s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

Rem Fix schema-for-schemas in DBs upgraded from 9201
Rem Order of elements in complex type should be choice,seq,group,all,
Rem simpleCont, complexCont, attribute, attributeGrp, anyAttribute
declare
 ck xdb.xdb$xmltype_ref_list_t;
 ell xdb.xdb$xmltype_ref_list_t;
 ell2 xdb.xdb$xmltype_ref_list_t;
 oldsch integer;
begin
 select s.xmldata.choice_kids into ck
 from xdb.xdb$sequence_model s
 where 
  ref(s) = 
   (select c.xmldata.sequence_kid 
    from xdb.xdb$complex_type c
    where c.xmldata.name='complexType' and c.xmldata.parent_schema=
     (select ref(sc) 
      from xdb.xdb$schema sc 
      where sc.xmldata.schema_url='http://xmlns.oracle.com/xdb/XDBSchema.xsd')
   );

 execute immediate 
  'select ch.xmldata.elements 
   from xdb.xdb$choice_model ch 
   where ref(ch)=:1'
 into ell using ck(1);

 execute immediate 
  'select case when e.xmldata.property.name=''all'' then 1 else 0 end
   from xdb.xdb$element e 
   where ref(e)=:1'
 into oldsch using ell(1);

 if oldsch=1 then
  ell2 := xdb.xdb$xmltype_ref_list_t();
  ell2.extend(6);
  
  ell2(1) := ell(2);
  ell2(2) := ell(3);
  ell2(3) := ell(4);
  ell2(4) := ell(1);
  ell2(5) := ell(5);
  ell2(6) := ell(6);

  execute immediate 
   'update xdb.xdb$choice_model ch 
    set ch.xmldata.elements=:1 
    where ref(ch)=:2'
  using ell2, ck(1);
 end if;

 execute immediate 
  'select ch.xmldata.elements 
   from xdb.xdb$choice_model ch 
   where ref(ch)=:1'
 into ell using ck(2);

 execute immediate 
  'select case when e.xmldata.property.name=''anyAttribute'' then 1 else 0 end
   from xdb.xdb$element e 
   where ref(e)=:1'
 into oldsch using ell(2);

 if oldsch=1 then
  ell2 := xdb.xdb$xmltype_ref_list_t();
  ell2.extend(3);
  
  ell2(1) := ell(1);
  ell2(2) := ell(3);
  ell2(3) := ell(2);

  execute immediate 
   'update xdb.xdb$choice_model ch 
    set ch.xmldata.elements=:1 
    where ref(ch)=:2'
  using ell2, ck(2);
 end if;

end;
/

Rem ACL Schema Upgrade
Rem STATUS NUMBER USED 450
declare
  schema_ref     REF SYS.XMLTYPE;
  st_ref         REF SYS.XMLTYPE;
  pf_ref         REF SYS.XMLTYPE;
  col_ref        REF SYS.XMLTYPE;
  ACL_NUMPROPS   CONSTANT INTEGER := 32;
  m              integer;
  numprops       integer;
begin
  select n into m from xdb.migr9202status for update;  
  if (m < 450) then
   select s.xmldata.num_props into numprops from xdb.xdb$schema s where 
      s.xmldata.schema_url='http://xmlns.oracle.com/xdb/acl.xsd';
   if (numprops < ACL_NUMPROPS) then

    select ref(s) into schema_ref from xdb.xdb$schema s where 
       s.xmldata.schema_url='http://xmlns.oracle.com/xdb/acl.xsd';

    insert into xdb.xdb$simple_type e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI(
     '4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
     '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462',
     '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), schema_ref,
     NULL, '00',XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8003'),
     NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
     XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'),
     NULL, 'ShortName', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'DistinguishedName', '00', NULL), 
      XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'GUID', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL)) 
    returning ref(e) into st_ref;

    insert into xdb.xdb$attribute e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI(
    '4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
    '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', 
    '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('439A3828020000041913010809181B03150B0C0D07'),
    schema_ref, xdb.xdb$propnum_seq.nextval, 'principalFormat', NULL, NULL, 
    '0103', '00', '00', NULL, 'principalFormat', 'XDB$ENUM_T', 'XDB', NULL,
    NULL, st_ref, st_ref, NULL, NULL, XDB.XDB$USECHOICE('00'), NULL, '00', 
    NULL, NULL, NULL, '00',   XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00')) 
    returning ref(e) into pf_ref;

    insert into xdb.xdb$attribute e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI(
    '4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
    '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462',
    '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('43B81828020000040519130809181B03150B0C07'),
    schema_ref, xdb.xdb$propnum_seq.nextval, 'collection', 
    XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'collection',
    'RAW', NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$USECHOICE('00'), 
    NULL, '00', NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), 
    NULL, '00')) returning ref(e) into col_ref;

    update xdb.xdb$complex_type c
     set c.xmldata.attributes=XDB.XDB$XMLTYPE_REF_LIST_T(col_ref, pf_ref),
      c.xmldata.sys_xdbpd$=XDB.XDB$RAW_LIST_T('330801060000038880020D0E131112')
    where ref(c)=(select e.xmldata.property.type_ref from xdb.xdb$element e 
                where e.xmldata.property.name='ace' and 
                e.xmldata.property.parent_schema=schema_ref);

    update xdb.xdb$schema s set s.xmldata.num_props=ACL_NUMPROPS
     where s.xmldata.schema_url='http://xmlns.oracle.com/xdb/acl.xsd';

   end if;
   update xdb.migr9202status set n = 450;
   commit;
  end if;
end;
/

-- Config schema

-- GRANT SELECT ON xdb.xdb$config TO PUBLIC;

Rem disable hierarchy on config so that it does call the update trigger
Rem Repeatable does not use status.
call dbms_xdbz.disable_hierarchy('XDB', 'XDB$CONFIG');


-- Create a procedure to get the type name and schema given schema url
-- and element name

create or replace procedure element_type(schema_url IN varchar2, element_name IN
    varchar2, type_owner out varchar2, type_name out varchar2) as
qry varchar2(4000);
cur integer;
rc integer;
begin
  qry   := 
    'select e.xmldata.property.sqlschema, e.xmldata.property.sqltype ' ||
    'from xdb.xdb$element e, xdb.xdb$schema s ' ||
    'where e.xmldata.property.name = :a ' || 
    'and e.xmldata.property.parent_schema = ref(s) ' ||
    'and s.xmldata.schema_url = :b';

  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur, qry, dbms_sql.native);
  dbms_sql.bind_variable(cur, ':a', element_name);
  dbms_sql.bind_variable(cur, ':b', schema_url);
  dbms_sql.define_column(cur, 1, type_owner, 30);
  dbms_sql.define_column(cur, 2, type_name, 30);
  rc := dbms_sql.execute(cur);
  IF dbms_sql.fetch_rows(cur) > 0 THEN
    dbms_sql.column_value(cur, 1, type_owner);
    dbms_sql.column_value(cur, 2, type_name);
  ELSE
    dbms_sql.close_cursor(cur);
    dbms_output.put_line('XDBNB: no element type, url=' || schema_url || 
        ', elem=' || element_name);
    RETURN;
  END IF;
  dbms_sql.close_cursor(cur);

END;
/
show errors;

create or replace procedure alt_type_add_attribute(type_owner IN varchar2,
     type_name IN varchar2, attr_string IN varchar2) as
cur integer;
rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur,
    'ALTER TYPE ' || 
    dbms_assert.enquote_name(type_owner, false) || '.' || 
    dbms_assert.enquote_name(type_name, false) ||
    ' ADD ATTRIBUTE (' || attr_string || ') CASCADE',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/
show errors;

create or replace function det_inst_schm_map( schema_url IN varchar2)
return boolean as
  elem_arr XDB.XDB$XMLTYPE_REF_LIST_T;
  name     VARCHAR2(1000);
  lastref  REF XMLTYPE;
begin

  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='extension-mappings' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url=schema_url))
;
    lastref := elem_arr(elem_arr.last);
    select e.xmldata.property.name into name from xdb.xdb$element e where ref(e) = lastref;
  if name = 'xml-extensions' then
    return FALSE;
  else
    return TRUE;
  end if;
end;
/
show errors;



create or replace procedure update_config as
  cur             INTEGER;
  rc              INTEGER;
  owner_var_sc    VARCHAR2(30);
  type_var_sc     VARCHAR2(30);
  colname_xmb     VARCHAR2(100);
  colname_lus     VARCHAR2(100);
  elem_ref_xmb    REF SYS.XMLTYPE;
  elem_ref_lus    REF SYS.XMLTYPE;
  elem_ref_nspc   REF SYS.XMLTYPE;
  elem_ref_elem   REF SYS.XMLTYPE;
  elem_ref_surl   REF SYS.XMLTYPE;
  elem_ref_slmp   REF SYS.XMLTYPE;
  elem_ref_slms   REF SYS.XMLTYPE;
  type_ref_cpxt1  REF SYS.XMLTYPE;
  type_ref_cpxt2  REF SYS.XMLTYPE;
  xml_ext_seq_mod_ref REF SYS.XMLTYPE;
  xml_ext_cmplx_typ_ref  REF SYS.XMLTYPE;
  elem_arr        XDB.XDB$XMLTYPE_REF_LIST_T;
  extmap_seq_ref  REF SYS.XMLTYPE;
  extension_element_ref  REF SYS.XMLTYPE;
  xml_ext_elt_ref REF SYS.XMLTYPE;
  elem_data       XDB.XDB$ELEMENT_T;
  elem_extra      SYS.XMLTYPEEXTRA;
  m               integer;
  sch_ref         ref sys.xmltype;
  ext_type_ref    ref sys.xmltype;
  ellist          xdb.xdb$xmltype_ref_list_t;
  ellist2         xdb.xdb$xmltype_ref_list_t;
  seq_ref         ref sys.xmltype;
  sysconf_seq_ref ref sys.xmltype;
  out             varchar2(10000);
  cplx_list       xdb.xdb$xmltype_ref_list_t;
  attr1           varchar2(1000);
  attr1_nm        varchar2(1000);
  attr1_ty        varchar2(1000);
  attr2           varchar2(1000);
  attr2_nm        varchar2(1000);
  attr2_ty        varchar2(1000);
  create_type_str varchar2(1000);
  type_name       varchar2(1000);
  config_schema_url varchar2(100);
  inst_schm_map   boolean;
begin

  -- The schema url of config
  config_schema_url := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';

  -- determine if there is a need to install schema mappings
  inst_schm_map := det_inst_schm_map(config_schema_url);

  -- get the 'sysconfig' object type
  element_type(config_schema_url, 'sysconfig', owner_var_sc, type_var_sc);

  -- Add the 'xdbcore-xobmem-bound' element to the 'sysconfig' object type
  select n into m from xdb.migr9202status for update;
  if (m < 460) then
    update xdb.migr9202status set n = 460;
    -- The alter type ddl will commit the above update
    alt_type_add_attribute(owner_var_sc, type_var_sc, 
                           '"xdbcore-xobmem-bound" NUMBER(10)');
  end if;

  -- Add the 'xdbcore-loadableunit-size' to sysconfig object type
  select n into m from xdb.migr9202status for update;
  if (m < 461) then
    update xdb.migr9202status set n = 461;
    alt_type_add_attribute(owner_var_sc, type_var_sc,
                           '"xdbcore-loadableunit-size" NUMBER(10)');
  end if;

  -- Create type 'schemaLocation-mapping26_T' 
  select n into m from xdb.migr9202status for update;
  if (m < 470) then
    update xdb.migr9202status set n = 470;
    if inst_schm_map then
      create_type_str := 'create or replace type ' || 
                         dbms_assert.enquote_name(owner_var_sc, false) || '.' ||
                         '"schemaLocation-mapping26_T" as object ( '        ||
                              'sys_xdbpd$ xdb.xdb$raw_list_t, '             ||
                              '"namespace"    varchar2(4000 char), '        ||
                              '"element"      varchar2(4000 char), '        ||
                              '"schemaURL"    varchar2(4000 char))';
      execute immediate create_type_str;
    else
      commit;
    end if;
 end if;

  -- Create type 'schemaLocation-mappi27_COLL' 
  select n into m from xdb.migr9202status for update;
  if (m < 471) then
    update xdb.migr9202status set n = 471;
    if inst_schm_map then
      create_type_str := 'create or replace type ' || 
                    dbms_assert.enquote_name(owner_var_sc, false) || '.' ||
                    '"schemaLocation-mappi27_COLL" as VARRAY(2147483647) OF'||
                    ' "' || owner_var_sc || '".' ||
                    '"schemaLocation-mapping26_T"';
      execute immediate create_type_str;
    else
      commit;
    end if;
  end if;

  -- Create type 'schemaLocation-mapping-25_T' 
  select n into m from xdb.migr9202status for update;
  if (m < 472) then
    update xdb.migr9202status set n = 472;
    if inst_schm_map then
      type_name := dbms_assert.enquote_name(owner_var_sc, false) || 
                   '."schemaLocation-mapping-25_T"';
      attr1     := 'SYS_XDBPD$ XDB.XDB$RAW_LIST_T';
      attr2_nm  := '"schemaLocation-mapping"';
      attr2_ty  := dbms_assert.enquote_name(owner_var_sc, false) || 
                   '."schemaLocation-mappi27_COLL"';
      attr2     := attr2_nm || ' '|| attr2_ty;

      create_type_str := 'create or replace type ' || type_name ||
                         'as object ('|| attr1 || ', '          ||
                                         attr2 || ') NOT FINAL';
      execute immediate create_type_str;
    else
      commit;
    end if;
  end if;

  -- add type 'schemaLocation-mapping-25_T' to sysconfig type
  select n into m from xdb.migr9202status for update;
  if (m < 473) then
    update xdb.migr9202status set n = 473;
    if inst_schm_map then
      alt_type_add_attribute(owner_var_sc, type_var_sc,
          '"schemaLocation-mappings" "' || owner_var_sc || '".' ||
          '"schemaLocation-mapping-25_T"');
    else
      commit;
    end if;
  end if;

  -- Create type 'extension29_COLL'
  select n into m from xdb.migr9202status for update;
  if (m < 474) then
    update xdb.migr9202status set n = 474;
    if inst_schm_map then
      create_type_str := 'create or replace type ' || 
                         dbms_assert.enquote_name(owner_var_sc, false) || 
                         '."extension29_COLL" as '           ||
                         'VARRAY(2147483647) of VARCHAR2(4000 CHAR)';
       -- this will auto commit and udpate the status
       execute immediate create_type_str;
     else
       commit;
     end if;
  end if;

  -- Create type "xml-extension-type28_T"
  select n into m from xdb.migr9202status for update;
  if (m < 475) then
    update xdb.migr9202status set n = 475;
    if inst_schm_map then
      create_type_str := 'create or replace type ' || 
                         dbms_assert.enquote_name(owner_var_sc, false) ||
                         '."xml-extension-type28_T" as object('        ||
                         'SYS_XDBPD$ xdb.XDB$RAW_LIST_T,'              ||
                         ' "extension" ' || 
                         dbms_assert.enquote_name(owner_var_sc, false) ||
                         '."extension29_COLL")';
       -- this will auto commit and this udpate the status
       execute immediate create_type_str;
     else
       commit;
     end if;
  end if;

  -- Now alter the extension-mappings type in extension-mappings
  -- to add the "extensions"
  if(m < 476) then
    update xdb.migr9202status set n = 476;
    if inst_schm_map then
      element_type(config_schema_url, 'extension-mappings', owner_var_sc, type_var_sc);
      alt_type_add_attribute(owner_var_sc, type_var_sc,
               '"xml-extensions" "' || owner_var_sc || '"."xml-extension-type28_T"');
    else
      commit;
    end if;
  end if; 

  select n into m from xdb.migr9202status for update;
  if (m < 480) then
    -- get the schema ref
    select ref(s) into sch_ref from xdb.xdb$schema s where
    s.xmldata.schema_url = config_schema_url;
 
    -- Insert the new element definitions into XDB.XDB$ELEMENT.
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
     '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
     '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
     SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030400000004050F320809181B23262A343503150B0C0706272928'),
     sch_ref,
     xdb.xdb$propnum_seq.nextval,
     'xdbcore-xobmem-bound', XDB.XDB$QNAME('00', 'unsignedInt'), '04',
     '44', '00', '00', NULL, 'xdbcore-xobmem-bound', 'NUMBER', NULL,
     NULL, '1024', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL,
     NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00',
     '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_xmb;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
     '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
     '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), 
     SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030400000004050F320809181B23262A343503150B0C0706272928'),
     sch_ref, xdb.xdb$propnum_seq.nextval, 'xdbcore-loadableunit-size',
     XDB.XDB$QNAME('00', 'unsignedInt'), '04',
     '44', '00', '00', NULL, 'xdbcore-loadableunit-size', 'NUMBER', NULL,
     NULL, '16', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL,
     NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00',
     '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_lus;


    -- Upgrade stuff added in 9.2.0.3.0 install to the config
    -- Since we do not know if these elements exist, we cannot depend
    -- on the config status for this upgrade

    if inst_schm_map then
      -- Add the complex type for schemaLocation-mapping-type
      insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'),
       sch_ref, xdb.xdb$propnum_seq.nextval, 'namespace',
       XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL,
       'namespace', 'VARCHAR2', NULL, NULL, NULL, NULL,
       NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',
       NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01',
       '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
       NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_nspc;

      insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'),
       sch_ref, xdb.xdb$propnum_seq.nextval, 'element',
       XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL,
       'element', 'VARCHAR2', NULL, NULL, NULL, NULL,
       NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',
       NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01',
       '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
       NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_elem;

      insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'),
       sch_ref, xdb.xdb$propnum_seq.nextval, 'schemaURL',
       XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL,
       'schemaURL', 'VARCHAR2', NULL, NULL, NULL, NULL,
       NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',
       NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01',
       '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
       NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_surl;

      ellist := xdb.xdb$xmltype_ref_list_t();
      ellist.extend(3);

      ellist(1) := elem_ref_nspc;
      ellist(2) := elem_ref_elem;
      ellist(3) := elem_ref_surl;

      insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
       SYS.XMLTYPEPI('523030')),
       XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800307'), sch_ref,
          0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(m) into seq_ref;

      insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'),
       sch_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref,
       NULL, NULL, NULL, 'schemaLocation-mapping26_T', 'XDB', '01', NULL, NULL, NULL))
      returning ref(c) into type_ref_cpxt1;

      insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838E01080030C0000000432331C0809181B23262A343503150B0C0D072729281617'),
       sch_ref, xdb.xdb$propnum_seq.nextval,
       'schemaLocation-mapping', NULL, NULL, '0102', '00', '00', NULL,
       'schemaLocation-mapping', 'schemaLocation-mapping26_T', 'XDB', NULL, NULL, NULL,
       type_ref_cpxt1, NULL, NULL, NULL, NULL, '00', NULL, 'schemaLocation-mappi27_COLL', 'XDB', '00',
       NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL,
       NULL, NULL, NULL, NULL, type_ref_cpxt1, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL,
       NULL, NULL, NULL, NULL))
         returning ref(e) into elem_ref_slmp;

      ellist2 := xdb.xdb$xmltype_ref_list_t();
      ellist2.extend(1);

      ellist2(1) := elem_ref_slmp;

      insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), sch_ref,
       0, NULL, ellist2, NULL, NULL, NULL, NULL, NULL, NULL))
         returning ref(m) into seq_ref;

      insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('3308100600000C030D0E131112'), sch_ref,
       NULL, 'schemaLocation-mapping-type', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       seq_ref,
       NULL, NULL, NULL, 'schemaLocation-mapping-25_T', 'XDB', '01', NULL, NULL,NULL))
         returning ref(c) into type_ref_cpxt2;


      insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
       '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
       '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83820008003040000000405320809181B23262A343503150B0C0D07272928'),
       sch_ref, xdb.xdb$propnum_seq.nextval, 'schemaLocation-mappings',
       XDB.XDB$QNAME('01', 'schemaLocation-mapping-type'), NULL, '0102', '00', '00', NULL,
       'schemaLocation-mappings', 'schemaLocation-mapping-25_T', 'XDB', NULL, NULL, NULL,
       type_ref_cpxt2, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL,
       NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
          returning ref(e) into elem_ref_slms;

    -- select the ref to simple type 'exttype'
    select ref(sim) into ext_type_ref from xdb.xdb$simple_type sim, xdb.xdb$schema sch where sim.xmldata.parent_schema = ref(sch) and sch.xmldata.schema_url = config_schema_url and sim.xmldata.name = 'exttype';

    -- insert the element into xdb.xdb$element
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
      XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523029')),
      xdb.XDB$ELEMENT_T(xdb.XDB$PROPERTY_T(xdb.XDB$RAW_LIST_T('83B818E00080030C000000040532330809181B23262A343503150B0C072729281617'), sch_ref, xdb.xdb$propnum_seq.nextval, 'extension', xdb.XDB$QNAME('01', 'exttype'), NULL, '01', '00', '00', NULL, 'extension', 'VARCHAR2', NULL, NULL, NULL, NULL, ext_type_ref, NULL, NULL, NULL, NULL, '00', NULL, 'extension29_COLL', 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into extension_element_ref;

    -- now insert the element into xdb.xdb$sequence_model
    insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values(
      XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
      XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), sch_ref, 0, NULL, XDB.XDB$XMLTYPE_REF_LIST_T(extension_element_ref), NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(m) into xml_ext_seq_mod_ref;
    
    -- now insert the element into xdb.xdb$complex_type
    insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values(
      XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
      XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('3308100600000C030D0E131112'), sch_ref, NULL, 'xml-extension-type', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, xml_ext_seq_mod_ref, NULL, NULL, NULL, 'xml-extension-type28_T', 'XDB', '01', NULL, NULL, NULL))
    returning ref(c) into xml_ext_cmplx_typ_ref;

    -- insert the actual element with the above complex type
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
      XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
      XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83820008003040000000405320809181B23262A343503150B0C0D07272928'), sch_ref, xdb.xdb$propnum_seq.nextval, 'xml-extensions', XDB.XDB$QNAME('01', 'xml-extension-type'), NULL, '0102', '00', '00', NULL, 'xml-extensions', 'xml-extension-type28_T', 'XDB', NULL, NULL, NULL, xml_ext_cmplx_typ_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into xml_ext_elt_ref;


  -- Get the list of complex types
     select s.xmldata.complex_types into cplx_list
     from xdb.xdb$schema s
     where s.sys_nc_oid$ = sys_op_r2o(sch_ref);

     cplx_list.extend(2);
     cplx_list(cplx_list.last -1) := xml_ext_cmplx_typ_ref;
     cplx_list(cplx_list.last)   := type_ref_cpxt2;

     update
     xdb.xdb$schema s set
       s.xmldata.sys_xdbpd$ =
          xdb.xdb$raw_list_t('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800A01131416120A170D'), 
       s.xmldata.complex_types = cplx_list
    where ref(s) = sch_ref;

     -- Get the varray of element refs in the "extension-mappings" sequence
    select c.xmldata.sequence_kid into extmap_seq_ref from xdb.xdb$complex_type c 
      where ref(c)=
          (select e.xmldata.cplx_type_decl 
            from xdb.xdb$element e, xdb.xdb$schema s 
            where e.xmldata.property.name='extension-mappings' and
            e.xmldata.property.parent_schema = ref(s) and
            s.xmldata.schema_url= config_schema_url);
    select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
     where ref(m) = extmap_seq_ref for update;

    -- add the 'xml-extensions' element
    elem_arr.extend(1);
    elem_arr(elem_arr.last) := xml_ext_elt_ref;

    update xdb.xdb$sequence_model m
      set m.xmldata.elements = elem_arr,
          m.xmldata.SYS_XDBPD$ = XDB.XDB$RAW_LIST_T('230200000081800507')
     where ref(m) = extmap_seq_ref;
   end if; -- end if inst_schm_map

    -- Get the VARRAY of element REFs in the sysconfig sequence
    select c.xmldata.sequence_kid into sysconf_seq_ref from xdb.xdb$complex_type c 
        where ref(c)=
          (select e.xmldata.cplx_type_decl 
            from xdb.xdb$element e, xdb.xdb$schema s 
            where e.xmldata.property.name='sysconfig' and
            e.xmldata.property.parent_schema = ref(s) and
            s.xmldata.schema_url= config_schema_url);

    select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
     where ref(m) = sysconf_seq_ref for update;

    -- schemaLocation-mappings element occurs before the loadableunit-size
    -- and xobmem-bound
    if inst_schm_map then
      elem_arr.extend(1);
      elem_arr(elem_arr.last) := elem_ref_slms;
    end if;


    -- now insert the two new elements.
    elem_arr.extend(2);
    elem_arr(elem_arr.last-1) := elem_ref_xmb;
    elem_arr(elem_arr.last) := elem_ref_lus;

    -- Update the VARRAY of element refs in the sysconfig sequence and fix
    -- the PD to reflect the added entries.
    -- This will change if the PD format changes.  The PD can be obtained by
    -- selecting it from the corresponding row in a 10.0 DB.
    -- This will also change if the number of entries in 'elem_arr' changes.
    update xdb.xdb$sequence_model m
     set m.xmldata.elements = elem_arr, 
         m.xmldata.SYS_XDBPD$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F706572746965732002101E2070726F746F636F6C2073706563696669632070726F706572746965732081801107')
     where ref(m) = sysconf_seq_ref;

  -- Now populate the new columns in the XDB.XDB$CONFIG table
  select c.name into colname_xmb from col$ c, obj$ o, attrcol$ a where
    c.obj#=o.obj# and 
    o.name='XDB$CONFIG' and
    o.owner#=(select user# from user$ where name='XDB') and
    c.intcol#=a.intcol# and
    a.obj#=o.obj# and
    a.name='"XMLDATA"."sysconfig"."xdbcore-xobmem-bound"';
  select c.name into colname_lus from col$ c, obj$ o, attrcol$ a where
    c.obj#=o.obj# and 
    o.name='XDB$CONFIG' and
    o.owner#=(select user# from user$ where name='XDB') and
    c.intcol#=a.intcol# and
    a.obj#=o.obj# and
    a.name='"XMLDATA"."sysconfig"."xdbcore-loadableunit-size"';

  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'update xdb.xdb$config c set c.' || 
    DBMS_ASSERT.ENQUOTE_NAME(colname_xmb, false) || ' = 1024, c.' || 
    DBMS_ASSERT.ENQUOTE_NAME(colname_lus, false) || ' = 16', 
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);

  update xdb.migr9202status set n = 480;
  commit;
 end if; -- end if m < 480
end;
/
show errors;

call update_config();

-- drop all the temporary procedures created.
drop procedure increase_facet_list_size;
drop procedure update_config;
drop function det_inst_schm_map;
drop procedure alt_type_add_attribute;
drop procedure element_type;

declare

  PN_RES_HIERSCHMRES      CONSTANT INTEGER := 744;
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 44;
  TRUE                    CONSTANT RAW(1) := '1';
  FALSE                   CONSTANT RAW(1) := '0';
  TR_BOOLEAN              xdb.xdb$qname := xdb.xdb$qname('00', 'boolean');
  T_BOOLEAN               RAW(2) :='fc'; /* DTYBOL */
  JT_BOOLEAN              xdb.xdb$javatype := xdb.xdb$javatype('8');
  TRANSIENT_GENERATED     CONSTANT xdb.xdb$transientChoice := 
                                       xdb.xdb$transientChoice('01');

  attlist                 xdb.xdb$xmltype_ref_list_t;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;

begin  

-- get the Resource schema's REF
   select ref(s) into sch_ref from xdb.xdb$schema s where  
   s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

-- Set the 'Lock', 'Flags' and 'RefCount' Properties to be Read-Only
-- This operation is repeatable and does not use status
   update xdb.xdb$element e set e.xmldata.property.mutable = '01' where
   e.xmldata.property.parent_schema = sch_ref and
   e.xmldata.property.name in ('RefCount', 'Lock', 'Flags');

-- Has the property already been added
   select s.xmldata.num_props into numprops from xdb.xdb$schema s 
   where ref(s) = sch_ref;

   IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

-- Add the HierSchmResource attribute to the Resource complexType
     select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
     c.xmldata.name = 'ResourceType' and
     c.xmldata.parent_schema = sch_ref;

     attlist.extend();
     attlist(9) := xdb.xdb$insertAttr(sch_ref,
                                 PN_RES_HIERSCHMRES, 'HierSchmResource',
                                 TR_BOOLEAN, 1, 1,
                                 '1', T_BOOLEAN, FALSE,
                                 FALSE, FALSE,
                                 null, null, null,
                                 JT_BOOLEAN, 'false', null,
                                 null, null, null, null, null, TRUE,
                                 TRANSIENT_GENERATED, FALSE);

     update xdb.xdb$complex_type c set
     c.xmldata.attributes = attlist where
     c.xmldata.name = 'ResourceType' and
     c.xmldata.parent_schema = sch_ref;

     update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
     where ref(s) = sch_ref;

     commit;
   END IF;

end;
/

Rem Cleanup
drop function xdb.xdb$insertElement;
drop function xdb.xdb$insertAttr;
alter session set events '22838 trace name context off';

Rem call 10g schema upgrades
@@xdbs101.sql
