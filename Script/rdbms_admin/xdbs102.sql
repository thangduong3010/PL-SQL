Rem
Rem $Header: rdbms/admin/xdbs102.sql /st_rdbms_11.2.0/1 2011/01/13 13:43:13 sidicula Exp $
Rem
Rem xdbs102.sql
Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbs102.sql - xdb schema upgrade from the 10.2 release
Rem
Rem    DESCRIPTION
Rem	 xdb schema upgrade from the 10.2 release to 11 and onwards
Rem
Rem    NOTES
Rem	 xdb upgrade document
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sidicula    01/06/11 - Backport sidicula_bug-10368698 from main
Rem    badeoti     05/27/10 - use choid index during hlink upgrade
Rem    badeoti     04/19/10 - Bug 9591348
Rem    badeoti     02/16/10 - bug 9304342: fix-up complex type PDs
Rem    badeoti     10/28/09 - Include sidicula_bug-7596530 fixes for 9201NT
Rem                           schema-for-schemas
Rem    badeoti     10/28/09 - fix type version mismatch caused by
Rem                           xdb$facet_list_t reset
Rem    spetride    09/15/09 - allow 0 ACEs in an ACL
Rem    badeoti     03/05/09 - additional hlink upgrade improvements
Rem    spetride    02/17/09 - disable hierarchy xdb$schema
Rem    badeoti     12/11/08 - improve hlink upgrade performance
Rem    achoi       04/10/08 - type can be non-exists
Rem    yifeng      01/25/08 - lrg 3272185: Register 11.1 resconfig schema
Rem    sidicula    11/21/07 - Create child_oid index before setLinkParents
Rem    mrafiq      11/20/07 - fix for bug 6629855
Rem    yifeng      11/12/07 - create XDBResConfig schema before calling xdbs111
Rem    rburns      09/12/07 - add 11g XDB up/down scripts
Rem    mrafiq      07/02/07 - making it rerunnable
Rem    mrafiq      06/27/07 - fix for lrg 2975452
Rem    mrafiq      06/04/07 - fix for bug 4870624
Rem    sichandr    05/29/07 - typeid_seq starts with 100
Rem    ningzhan    04/12/07 - increase snapshot size in DXPTAB to 20
Rem    nkandalu    02/08/07 - 3010822: increase length of schema attribute
Rem    bpwang      11/09/06 - grant execute on dbms_streams_control_adm
Rem    vkapoor     09/18/06 - Ipaddress needs correct pattern
Rem    mrafiq      09/22/06 - remove default value for translate
Rem    mrafiq      09/20/06 - Fix typeid default value
Rem    thbaby      08/12/06 - rename pathsdoc to parameters in xdb$dxptab
Rem    spetride    08/10/06 - token table upgrade idempotent
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    attran      06/19/06 - lrg2290840: drop indextype after xdbptrl1
Rem    thbaby      06/13/06 - fix xmlindex indextype upgrade
Rem    attran      06/06/06 - Drop all XMLIndexes + ReCreate XMLIndexType
Rem    thbaby      06/07/06 - add attribute 'IsXMLIndexed' during upgrade
Rem    mrafiq      02/13/06 - adding changes for locks up/dw 
Rem    pnath       03/16/06 - add HasUnresolvedLinks to Resource schema 
Rem    mrafiq      03/06/06 - adding upgrade for compound docs 
Rem    thbaby      05/24/06 - delete obsolete xmlindex operators 
Rem    ataracha    03/16/06 - XMLIndex dictionary changes
Rem    smalde      03/13/06 - Upgrade attrs 'translate' and 'xdb:maxOccurs' 
Rem    abagrawa    03/16/06 - Add xdb1m102.sql 
Rem    abagrawa    03/15/06 - Remove acl/config manual up/downgrade 
Rem    thbaby      02/21/06 - Add NFS columns to root_info
Rem    vkapoor     01/25/05 - Adding NFS upgrade 
Rem    sidicula    02/03/06 - Adding protocol_info cols to root_info 
Rem    nkandalu    12/29/05 - 4751888: add substitution to derivationChoice 
Rem    rtjoa       11/21/05 - Adding http and http2 host element to xdb config 
Rem    mrafiq      10/04/05 - updating for upgrade/downgrade project for 11g 
Rem    sidicula    06/29/05 - sidicula_le
Rem    sidicula    06/24/05 - Move setLinkParents to xdbutil_int
Rem    fge         10/27/04 - Created
Rem

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

Rem clean up updown utilities
@@dbmsxuducu.sql

-- we have enabled hierarchy fro xdb$schema in 10.2, but not in main
BEGIN
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/

COLUMN :tm_name NEW_VALUE tm_file NOPRINT
VARIABLE tm_name VARCHAR2(50)

-- Get utility functions, also compiles base types to avoid ORA-942 below
@@xdbuuc4

alter type xdb.xdb$raw_list_t modify limit 2147483647 cascade not including table data;

commit;

-- Artificially increase facet_list_t version number to match table data
-- Needed because a reset might have done on type during upgrade from 9.2
alter type xdb.xdb$facet_list_t modify limit 65536 cascade not including table data;

commit;

-- DDL change to schema table
alter type XDB.XDB$SCHEMA_T modify attribute version varchar2(4000) cascade;

-- Upgrade data for tables depending on xdb$facet_list_t, xdb$schema_t
alter table XDB.XDB$SCHEMA upgrade;
alter table XDB.XDB$SIMPLE_TYPE upgrade;
alter table XDB.XDB$COMPLEX_TYPE upgrade;

commit;

create or replace procedure alt_type_add_attribute_own(type_owner IN varchar2,
     type_name IN varchar2, attr_string IN varchar2) as
  cur integer;
  rc  integer;
  attr_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(attr_exists,-22324);
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
exception 
  when attr_exists then
    dbms_output.put_line('XDBNB: Could not add attribute ' || attr_string ||
                         ' to type ' || type_owner || '.' || type_name);
end;
/
show errors;

create or replace procedure alter_type(attr_string IN varchar2) as
  attr_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(attr_exists,-22324);
begin
  execute immediate attr_string;
exception
  when attr_exists then
    dbms_output.put_line('XDBNB: ("' || attr_string || '") failed');
end;
/
show errors;

create or replace function attr_exists(schema_url IN varchar2,attr_name IN varchar2) return boolean
as
  c  integer;
begin 

  select count(e.xmldata.name) into c from xdb.xdb$attribute e, xdb.xdb$schema s where s.xmldata.schema_url = schema_url  and e.xmldata.parent_schema = ref(s) and e.xmldata.name = attr_name;

  if c = 0 then
    return FALSE;
  else
    return TRUE;
  end if;
end;
/
show errors;

create or replace function attr_exists_num ( 
	schema_url IN varchar2,
	attr_name IN varchar2,
	prop_num IN integer
) return boolean
as
  c  integer;
begin 

  select count ( e.xmldata.name ) into c 
	from xdb.xdb$attribute e, xdb.xdb$schema s 
	where s.xmldata.schema_url = schema_url  
	and e.xmldata.parent_schema = ref(s) 
	and e.xmldata.name = attr_name
	and e.xmldata.prop_number = prop_num;

  if c = 0 then
    return FALSE;
  else
    return TRUE;
  end if;

end;
/
show errors;

create or replace procedure create_types_schemas as
begin

  alter_type('alter type xdb.xdb$simple_t add attribute (typeid integer) cascade');

  alter_type('alter type xdb.xdb$simple_t add attribute (sqltype varchar2(30)) cascade');
  
  alter_type('alter type xdb.xdb$complex_t add attribute (typeid integer) cascade');

end;
/
show errors;

create or replace procedure add_simple_typeid(
	xdb_schema_ref IN REF XMLTYPE, xdb_schema_url IN VARCHAR2) as
  cur             integer;
  rc              integer;
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  typeid_ref      REF XMLTYPE; 
  sqltype_ref     REF XMLTYPE;
  c               number;
begin
 

  if not attr_exists(xdb_schema_url,'typeID') then

   dbms_output.put_line('upgrading simple typeid');

   select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'simpleType' and
      c.xmldata.parent_schema = xdb_schema_ref;

   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, xdb_schema_ref,271, 'typeID', XDB.XDB$QNAME('00', 'integer'), NULL, '44', '01', '00', NULL, 'TYPEID', 'NUMBER', NULL, XDB.XDB$JAVATYPE('01'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into typeid_ref;

   attlist.extend(1);
   attlist(attlist.last) := typeid_ref;
   update xdb.xdb$complex_type c 
   set c.xmldata.attributes = attlist
   where c.xmldata.name = 'simpleType' and
        c.xmldata.parent_schema = xdb_schema_ref;
  end if;


  select count(e.xmldata.name) into c 
  from xdb.xdb$attribute e
  where e.xmldata.name = 'SQLType' and 
        e.xmldata.parent_schema = xdb_schema_ref;


  if(c = 2) then
   dbms_output.put_line('upgrading simple sqltype');

   select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'simpleType' and
      c.xmldata.parent_schema = xdb_schema_ref;

   insert into xdb.xdb$attribute e (e.xmldata) values
   (XDB.XDB$PROPERTY_T(NULL, xdb_schema_ref,273, 'SQLType', XDB.XDB$QNAME('00', 'string'), NULL, '01', '01', '00', NULL, 'SQLTYPE', 'VARCHAR2', NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into sqltype_ref;

   attlist.extend(1);
   attlist(attlist.last) := sqltype_ref;
   update xdb.xdb$complex_type c 
   set c.xmldata.attributes = attlist
   where c.xmldata.name = 'simpleType' and
        c.xmldata.parent_schema = xdb_schema_ref;
  end if;

end;
/
show errors;

create or replace procedure add_complex_typeid(
	xdb_schema_ref IN REF XMLTYPE, xdb_schema_url IN VARCHAR2) as
  cur             integer;
  rc              integer;
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  typeid_ref      REF XMLTYPE;
  c               number;
begin

  select count(e.xmldata.name) into c 
  from xdb.xdb$attribute e
  where e.xmldata.name = 'typeID' and 
        e.xmldata.parent_schema = xdb_schema_ref;


  if(c = 1) then
   dbms_output.put_line('upgrading complex typeid');

   select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'complexType' and
      c.xmldata.parent_schema = xdb_schema_ref;

   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, xdb_schema_ref,272, 'typeID', XDB.XDB$QNAME('00', 'integer'), NULL, '44', '01', '00', NULL, 'TYPEID', 'NUMBER', NULL, XDB.XDB$JAVATYPE('01'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into typeid_ref;

   attlist.extend(1);
   attlist(attlist.last) := typeid_ref;
   update xdb.xdb$complex_type c 
   set c.xmldata.attributes = attlist
   where c.xmldata.name = 'complexType' and
        c.xmldata.parent_schema = xdb_schema_ref;
  end if;

end;
/
show errors;

create or replace procedure add_translate(
	xdb_schema_ref IN REF XMLTYPE, xdb_schema_url IN VARCHAR2) as
  cur             integer;
  rc              integer;
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  trans_ref      REF XMLTYPE; 
  sqltype_ref     REF XMLTYPE;
  c               number;
begin
 
  if not attr_exists ( xdb_schema_url, 'translate' ) then

    dbms_output.put_line ( 'upgrading xdb:translate' );

    select c.xmldata.complexcontent.extension.attributes 
      into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'element' and
      c.xmldata.parent_schema = xdb_schema_ref;

    insert into xdb.xdb$attribute e ( e.xmldata ) values
      ( XDB.XDB$PROPERTY_T ( NULL, xdb_schema_ref, 274, 'translate', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '01', '00', NULL, 'IS_TRANSLATABLE', 'RAW', NULL, XDB.XDB$JAVATYPE('08'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into trans_ref;

    attlist.extend(1);
    attlist(attlist.last) := trans_ref;
    update xdb.xdb$complex_type c 
      set c.xmldata.complexcontent.extension.attributes = attlist
      where c.xmldata.name = 'element' and
      c.xmldata.parent_schema = xdb_schema_ref;

  end if;
end;
/
show errors;

create or replace procedure add_xdbmaxocc(
	xdb_schema_ref IN REF XMLTYPE, xdb_schema_url IN VARCHAR2) as
  cur             integer;
  rc              integer;
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  xdbmaxocc_ref      REF XMLTYPE; 
  sqltype_ref     REF XMLTYPE;
  c               number;
begin
 
  if not attr_exists_num ( xdb_schema_url, 'maxOccurs', 275 ) then

    dbms_output.put_line ( 'upgrading xdb:maxoccurs' );

    select c.xmldata.complexcontent.extension.attributes 
      into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'element' and
      c.xmldata.parent_schema = xdb_schema_ref;

    insert into xdb.xdb$attribute e (e.xmldata) values
      (XDB.XDB$PROPERTY_T(NULL, xdb_schema_ref, 275, 'maxOccurs', XDB.XDB$QNAME('00', 'string'), NULL, '01', '01', '00', NULL, 'XDB_MAX_OCCURS', 'VARCHAR2', NULL, XDB.XDB$JAVATYPE('00'),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
	 returning ref(e) into xdbmaxocc_ref;

    attlist.extend(1);
    attlist(attlist.last) := xdbmaxocc_ref;
    update xdb.xdb$complex_type c 
      set c.xmldata.complexcontent.extension.attributes = attlist
      where c.xmldata.name = 'element' and
      c.xmldata.parent_schema = xdb_schema_ref;

  end if;
end;
/
show errors;

create or replace procedure add_sequence as
begin  
  dbms_output.put_line('upgrading sequence for schema for schemas'); 

  execute immediate
  	'create sequence xdb.xdb$typeid_seq start with 100 cache 20';

  dbms_output.put_line('schema for schemas sequence upgraded'); 
end;
/
show errors;

-- Bug: 4751888 add "substitution" and "union" to derivationChoice

create or replace procedure update_derviationChoice as
  schref         REF XMLTYPE;
  xdb_schema_url CONSTANT VARCHAR2(100) :=
                  'http://xmlns.oracle.com/xdb/XDBSchema.xsd';
  enumeration    xdb.xdb$enum_values_t;
  facet_list     xdb.xdb$facet_list_t := xdb.xdb$facet_list_t();
  FALSE          CONSTANT RAW(1) := '0';

begin

  select ref(s) into schref from xdb.xdb$schema s where
         s.xmldata.schema_url = xdb_schema_url;

  enumeration := xdb.xdb$enum_values_t('','extension', 'restriction', 'list',
                                       '#all', 'substitution', 'union');

  facet_list.extend(enumeration.count);
  for i in 1..enumeration.count loop
    facet_list(i) := xdb.xdb$facet_t(null, null, enumeration(i), FALSE, null);
  end loop;

execute immediate 'update xdb.xdb$simple_type s
  set s.xmldata.RESTRICTION.ENUMERATION = :1
  where :2 = s.xmldata.PARENT_SCHEMA and s.xmldata.name = ''derivationChoice'''
  using facet_list, schref;

end;
/
show error;

---------------------------------------------------------------------------------------
-- This procedure upgrades the schema for schemas
---------------------------------------------------------------------------------------
create or replace procedure upgrade_schema_for_schemas as
  xdb_schema_ref  REF XMLTYPE;
  xdb_schema_url  VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 276;
  num_props       number;
begin
  xdb_schema_url := 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

  select ref(s) into xdb_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = xdb_schema_url;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s 
    where ref(s) = xdb_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then

   dbms_output.put_line('upgrading schema for schemas'); 

   add_simple_typeid(xdb_schema_ref,xdb_schema_url);
   add_complex_typeid(xdb_schema_ref,xdb_schema_url); 
   add_translate ( xdb_schema_ref, xdb_schema_url );
   add_xdbmaxocc ( xdb_schema_ref, xdb_schema_url );

   update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
      where ref(s) = xdb_schema_ref; 
   commit;
  end if;
  create_types_schemas();

  -- Add translation attrs to element_t
  alter_type
    ('alter type xdb.xdb$element_t add attribute (is_translatable raw(1)) cascade');
  alter_type
    ('alter type xdb.xdb$element_t add attribute (xdb_max_occurs varchar2(20)) cascade');

  add_sequence();   
  update_derviationChoice();

  dbms_output.put_line('schema for schemas upgraded'); 
end;
/
show errors;

---------------------------------------------------------------------------------------
-- Call the functions defined above.
---------------------------------------------------------------------------------------
-- Upgrade schema for schemas from the 10102 version
call upgrade_schema_for_schemas();

-- Function to insert new bootstrap schema elements. This function now
-- needs 10 nulls in the end because we have added 2 new attrs to
-- element_t.
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
                                null,null,null,null,null,null,null,null,null,null);

  execute immediate 'insert into xdb.xdb$element e (xmldata) 
  values (:1) returning ref(e) into :2' using elem_i returning into elem_ref;

                return elem_ref;
        end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds 1 element to config sequence.
-------------------------------------------------------------------------------
create or replace procedure add_to_config_seq(
                              config_schema_ref IN REF XMLTYPE,
                              name IN varchar2,
                              pd   IN varchar2,
                              elem_ref IN REF XMLTYPE) as
  sysconfig_seq_ref      REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  -- select the sequence kid corresponding to the sysconfig type
  select c.xmldata.sequence_kid into sysconfig_seq_ref from
    xdb.xdb$complex_type c where ref(c)= 
      (select e.xmldata.cplx_type_decl from xdb.xdb$element e
        where e.xmldata.property.name=name and
        e.xmldata.property.parent_schema = config_schema_ref);

  -- select the sequence elements
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
  where ref(m) = sysconfig_seq_ref;
    
  -- extend it to add 1 element just created
  elem_arr.extend(1);
  elem_arr(elem_arr.last)   := elem_ref;
    
  -- update the table with the extended sequence and new pd
  update xdb.xdb$sequence_model m 
  set m.xmldata.elements = elem_arr,
      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T(pd)
  where ref(m) = sysconfig_seq_ref;
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'rollback_on_sync_error' to xmlconfig.
--------------------------------------------------------------------------------
create or replace procedure ats_rollback_on_sync_error(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var      VARCHAR2(100);
  sysconfig_type     VARCHAR2(100);
  elem_ref_rollback  REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
  
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/rollback-on-sync-error')
   is null then

   dbms_output.put_line('upgrading rollback'); 
 
   alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"rollback-on-sync-error" RAW(1)');
 
 
   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
       (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
        XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004050F320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'rollback-on-sync-error', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'rollback-on-sync-error', 'RAW', NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
   returning ref(e) into elem_ref_rollback;

   add_to_config_seq(config_schema_ref, 'sysconfig',
                     '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_rollback);
   commit;
  end if;
end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds 'copy-on-inconsistent-update' to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_copy_on_inconsist_upd(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var    VARCHAR2(100);
  sysconfig_type   VARCHAR2(100);
  elem_ref_copy    REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
 
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/copy-on-inconsistent-update')
    is null then

    dbms_output.put_line('upgrading copy'); 

    alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"copy-on-inconsistent-update" RAW(1)');

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
       XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004050F320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'copy-on-inconsistent-update', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'copy-on-inconsistent-update', 'RAW', NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
    returning ref(e) into elem_ref_copy;

    add_to_config_seq(config_schema_ref, 'sysconfig',
                      '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_copy);
    commit;
  end if;
end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds 'folder-hard-links' to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_folder_hard_links(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var    VARCHAR2(100);
  sysconfig_type   VARCHAR2(100);
  elem_ref_links    REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
 
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/folder-hard-links')
    is null then

    dbms_output.put_line('upgrading folder hard links'); 

    alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"folder-hard-links" RAW(1)');

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
     (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004050F320809181B23262A343503150B0C07292728'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'folder-hard-links', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'folder-hard-links', 'RAW', NULL,NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01',NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) 
    returning ref(e) into elem_ref_links;

    add_to_config_seq(config_schema_ref, 'sysconfig',
                      '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_links);
    commit;
  end if;
end;
/
show errors;


-------------------------------------------------------------------------------
-- This procedure adds 'non-folder-hard-links' to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_non_folder_hard_links(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var    VARCHAR2(100);
  sysconfig_type   VARCHAR2(100);
  elem_ref_links    REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
 
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/non-folder-hard-links')
    is null then

    dbms_output.put_line('upgrading non-folder hard links'); 

    alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"non-folder-hard-links" RAW(1)');

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
	(SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
	XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004050F320809181B23262A343503150B0C07292728'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'non-folder-hard-links', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'non-folder-hard-links', 'RAW', NULL, NULL, 'true', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_links;

    add_to_config_seq(config_schema_ref, 'sysconfig',
                      '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_links);
    commit;
  end if;
end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure creates types used by NFS
-------------------------------------------------------------------------------
create or replace procedure ats_create_types(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2) as
  create_type_str VARCHAR2(1000);
begin

    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-export-path31_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"path" varchar2(4000 char), ' ||
                       '"mode" xdb.XDB$ENUM_T)';
    execute immediate create_type_str;

    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-export-path32_COLL" as VARRAY(2147483647) OF' ||
                       ' "' || sysconfig_var || '".' || '"nfs-export-path31_T"';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-export-paths30_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-export-path"' ||
                       ' "' || sysconfig_var || '".' || '"nfs-export-path32_COLL")';
    execute immediate create_type_str;

    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-client28_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-client-subnet" varchar2(4000 char), ' ||
                       '"nfs-client-dnsname" varchar2(4000 char), ' ||
                       '"nfs-client-address" varchar2(4000 char), ' ||
                       '"nfs-client-netmask" varchar2(4000 char))';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-client29_COLL" as VARRAY(2147483647) OF' ||
                       ' "' || sysconfig_var || '".' || '"nfs-client28_T"';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-clientgroup27_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-client" ' || '"' || sysconfig_var || '".' ||
                       '"nfs-client29_COLL")';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-export26_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-clientgroup"' || ' "' ||sysconfig_var|| '".' || '"nfs-clientgroup27_T",' ||
                       '"nfs-export-paths"' || ' "' ||sysconfig_var|| '".' || '"nfs-export-paths30_T")';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-export33_COLL" as VARRAY(2147483647) OF' ||
                       ' "' || sysconfig_var || '".' || '"nfs-export26_T"';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfs-exports-type25_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-export"' || ' "' || sysconfig_var || '".' ||
                       '"nfs-export33_COLL")';
    execute immediate create_type_str;


    create_type_str := 'create or replace type "' || sysconfig_var || '".' ||
                       '"nfsconfig78_T" as object ( ' ||
                       'sys_xdbpd$ xdb.xdb$raw_list_t,' ||
                       '"nfs-port" NUMBER(5),' ||
                       '"nfs-listener" varchar2(4000 char),' ||
                       '"nfs-protocol" varchar2(4000 char),' ||
                       '"logfile-path" varchar2(4000 char),' ||
                       '"log-level" NUMBER(10),' ||
                       '"nfs-exports"' || ' "' || sysconfig_var || '".' || '"nfs-exports-type25_T")';
    execute immediate create_type_str;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds ipaddress to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_type_ipaddress(
                              config_schema_ref IN REF XMLTYPE,
                              config_schema_url IN VARCHAR2,
                              smplt_ref_ipadd  OUT REF SYS.XMLTYPE) as
  temp_ref    REF XMLTYPE;
  simple_arr  XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  insert into xdb.xdb$simple_type e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('2322000000050106'), config_schema_ref, 'ipaddress', '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330004020000110A'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, '(\d{1,3}\.){3}\d{1,3}', '00', NULL)), NULL, NULL, NULL), NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into temp_ref;

  smplt_ref_ipadd := temp_ref;

  select s.xmldata.simple_type into simple_arr
  from xdb.xdb$schema s
  where s.xmldata.schema_url = config_schema_url;

  simple_arr.extend(1);
  simple_arr(simple_arr.last) := temp_ref;
  
  update xdb.xdb$schema s
  set s.xmldata.simple_type = simple_arr
  where s.xmldata.schema_url = config_schema_url;

  update xdb.xdb$schema s
  set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B81800202131416120A170D')
  where s.xmldata.schema_url = config_schema_url;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type mode
-------------------------------------------------------------------------------
create or replace procedure ats_type_mode(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_mode     OUT REF SYS.XMLTYPE) as
  smplt_ref_mode      REF SYS.XMLTYPE;
begin

  insert into xdb.xdb$simple_type e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'read-write', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'read-only', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into smplt_ref_mode;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A38200080030000000004010809181B23262A32343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'mode', NULL, NULL, '0103', '00', '00', NULL, 'mode', 'XDB$ENUM_T', 'XDB', NULL, NULL, smplt_ref_mode, smplt_ref_mode, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_mode;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type path
-------------------------------------------------------------------------------
create or replace procedure ats_type_path(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_path     OUT REF SYS.XMLTYPE) as
begin
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'path', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'path', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_path;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs_export_path
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_export_path(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_mode     IN  REF SYS.XMLTYPE,
                              elem_ref_path     IN  REF SYS.XMLTYPE,
                              elem_ref_nexpath  OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(2);
  ellist(1) := elem_ref_path;
  ellist(2) := elem_ref_mode;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
   (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-export-path31_T', 'XDB', '01', NULL, NULL, NULL,null))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838E01080030C0000000432331C0809181B23262A343503150B0C0D072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-export-path', NULL, NULL, '0102', '00', '00', NULL, 'nfs-export-path', 'nfs-export-path31_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, 'nfs-export-path32_COLL', 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 1, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_nexpath;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs_export_paths
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_export_paths(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_nexpath  IN  REF SYS.XMLTYPE,
                              elem_ref_nexpaths OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(1);
  ellist(1) := elem_ref_nexpath;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-export-paths30_T', 'XDB', '01', NULL, NULL, NULL,NULL))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('8398382010800300000000041C0809181B23262A32343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-export-paths', NULL, NULL, '0102', '00', '00', NULL, 'nfs-export-paths', 'nfs-export-paths30_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_nexpaths;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs-client-types
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_client_types(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              smplt_ref_ipadd   IN  REF SYS.XMLTYPE,
                              elem_ref_subnet   OUT REF SYS.XMLTYPE,
                              elem_ref_dnsname  OUT REF SYS.XMLTYPE,
                              elem_ref_address  OUT REF SYS.XMLTYPE,
                              elem_ref_mask     OUT REF SYS.XMLTYPE) as
begin

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-client-subnet', XDB.XDB$QNAME('01', 'ipaddress'), NULL, '01', '00', '00', NULL, 'nfs-client-subnet', 'VARCHAR2', NULL, NULL, NULL, NULL, smplt_ref_ipadd, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_subnet;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-client-dnsname', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'nfs-client-dnsname', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_dnsname;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-client-address', XDB.XDB$QNAME('01', 'ipaddress'), NULL, '01', '00', '00', NULL, 'nfs-client-address', 'VARCHAR2', NULL, NULL, NULL, NULL, smplt_ref_ipadd, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_address;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-client-netmask', XDB.XDB$QNAME('01', 'ipaddress'), NULL, '01', '00', '00', NULL, 'nfs-client-netmask', 'VARCHAR2', NULL, NULL, NULL, NULL, smplt_ref_ipadd, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_mask;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs_client
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_client(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_subnet   IN  REF SYS.XMLTYPE,
                              elem_ref_dnsname  IN  REF SYS.XMLTYPE,
                              elem_ref_address  IN  REF SYS.XMLTYPE,
                              elem_ref_mask     IN  REF SYS.XMLTYPE,
                              elem_ref_nclient  OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  ellist2         xdb.xdb$xmltype_ref_list_t;
  ellist3         xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  choice_ref      REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(3);
  ellist(1) := elem_ref_subnet;
  ellist(2) := elem_ref_dnsname;
  ellist(3) := elem_ref_address;

  insert into xdb.xdb$choice_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
     XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800307'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into choice_ref;

  ellist2 := xdb.xdb$xmltype_ref_list_t();
  ellist2.extend(1);
  ellist2(1) := elem_ref_mask;

  ellist3 := xdb.xdb$xmltype_ref_list_t();
  ellist3.extend(1);
  ellist3(1) := choice_ref;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('2306000000020107'), config_schema_ref, 0, NULL, ellist2, ellist3, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-client28_T', 'XDB', '01', NULL, NULL, NULL,NULL))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838E01080030C0000000432331C0809181B23262A343503150B0C0D072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-client', NULL, NULL, '0102', '00', '00', NULL, 'nfs-client', 'nfs-client28_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, 'nfs-client29_COLL', 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 1, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_nclient;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs_clientgroup
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_clientgroup(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_nclient  IN  REF SYS.XMLTYPE,
                              elem_ref_ncltgrp  OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(1);
  ellist(1) := elem_ref_nclient;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-clientgroup27_T', 'XDB', '01', NULL, NULL, NULL,NULL))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('8398382010800300000000041C0809181B23262A32343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-clientgroup', NULL, NULL, '0102', '00', '00', NULL, 'nfs-clientgroup', 'nfs-clientgroup27_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_ncltgrp;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds to xmlconfig type nfs_export
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_export(
                              config_schema_ref IN  REF SYS.XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_nexpaths IN  REF SYS.XMLTYPE,
                              elem_ref_ncltgrp  IN  REF SYS.XMLTYPE,
                              elem_ref_nfsexp   OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(2);
  ellist(1) := elem_ref_ncltgrp;
  ellist(2) := elem_ref_nexpaths;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-export26_T', 'XDB', '01', NULL, NULL, NULL,NULL))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838E01080030C0000000432331C0809181B23262A343503150B0C0D072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-export', NULL, NULL, '0102', '00', '00', NULL, 'nfs-export', 'nfs-export26_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, 'nfs-export33_COLL', 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 1, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_nfsexp;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds nfs-exports-type to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_exports_type(
                              config_schema_ref IN REF XMLTYPE,
                              config_schema_url IN VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_nfsexp   IN REF SYS.XMLTYPE,
                              elem_ref_nfsexps  OUT REF SYS.XMLTYPE) as
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
  complex_arr     xdb.xdb$xmltype_ref_list_t;
begin

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(1);
  ellist(1) := elem_ref_nfsexp;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23020000000107'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('3308100600000C030D0E131112'), config_schema_ref, NULL, 'nfs-exports-type', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfs-exports-type25_T', 'XDB', '01', NULL, NULL, NULL,NULL)) 
  returning ref(c) into cpxt_ref;

  select s.xmldata.complex_types into complex_arr
  from xdb.xdb$schema s
  where s.xmldata.schema_url = config_schema_url;

  complex_arr.extend(1);
  complex_arr(complex_arr.last) := cpxt_ref;
  
  update xdb.xdb$schema s
  set s.xmldata.complex_types = complex_arr
  where s.xmldata.schema_url = config_schema_url;

  update xdb.xdb$schema s
  set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B81800202131416120A170D')
  where s.xmldata.schema_url = config_schema_url;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B838200080030000000004050809181B23262A32343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-exports', XDB.XDB$QNAME('01', 'nfs-exports-type'), NULL, '0102', '00', '00', NULL, 'nfs-exports', 'nfs-exports-type25_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_nfsexps;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds nfs-exports-type to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_type_nfs_exports_type2(
                              config_schema_ref IN  REF XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              smplt_ref_ipadd   IN  REF SYS.XMLTYPE,
                              elem_ref_nfsexps  OUT REF SYS.XMLTYPE) as
  elem_ref_mode      REF SYS.XMLTYPE;
  elem_ref_path      REF SYS.XMLTYPE;
  elem_ref_nexpath   REF SYS.XMLTYPE;
  elem_ref_nexpaths  REF SYS.XMLTYPE;
  elem_ref_subnet    REF SYS.XMLTYPE;
  elem_ref_dnsname   REF SYS.XMLTYPE;
  elem_ref_address   REF SYS.XMLTYPE;
  elem_ref_mask      REF SYS.XMLTYPE;
  elem_ref_nclient   REF SYS.XMLTYPE;
  elem_ref_ncltgrp   REF SYS.XMLTYPE;
  elem_ref_nfsexp    REF SYS.XMLTYPE;
begin

  ats_type_mode(config_schema_ref, config_schema_url, sysconfig_var, elem_ref_mode);
  ats_type_path(config_schema_ref, config_schema_url, sysconfig_var, elem_ref_path);
  ats_type_nfs_export_path(config_schema_ref, config_schema_url, sysconfig_var,
                                     elem_ref_mode, elem_ref_path, 
                                     elem_ref_nexpath);
  ats_type_nfs_export_paths(config_schema_ref, config_schema_url, sysconfig_var,
                                 elem_ref_nexpath, elem_ref_nexpaths);
  ats_type_nfs_client_types(config_schema_ref, config_schema_url, sysconfig_var,
                                      smplt_ref_ipadd, elem_ref_subnet,
                                      elem_ref_dnsname, elem_ref_address,
                                      elem_ref_mask);
  ats_type_nfs_client(config_schema_ref, config_schema_url, sysconfig_var,
                                elem_ref_subnet, elem_ref_dnsname,
                                elem_ref_address, elem_ref_mask,
                                elem_ref_nclient);
  ats_type_nfs_clientgroup(config_schema_ref, config_schema_url, sysconfig_var,
                                     elem_ref_nclient, elem_ref_ncltgrp);
  ats_type_nfs_export(config_schema_ref, config_schema_url, sysconfig_var,
                                elem_ref_nexpaths, elem_ref_ncltgrp,
                                elem_ref_nfsexp);
  ats_type_nfs_exports_type(config_schema_ref, config_schema_url, sysconfig_var,
                                      elem_ref_nfsexp, elem_ref_nfsexps);

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds nfs-config elements to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_nfs_config2(
                              config_schema_ref IN  REF XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_port     OUT REF SYS.XMLTYPE,
                              elem_ref_lsnr     OUT REF SYS.XMLTYPE,
                              elem_ref_proto    OUT REF SYS.XMLTYPE,
                              elem_ref_logf     OUT REF SYS.XMLTYPE,
                              elem_ref_logl     OUT REF SYS.XMLTYPE) as
begin

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030000000004050F0809181B23262A32343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-port', XDB.XDB$QNAME('00', 'unsignedShort'), '02', '44', '00', '00', NULL, 'nfs-port', 'NUMBER', NULL, NULL, '2049', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL))
  returning ref(e) into elem_ref_port;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-listener', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'nfs-listener', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into elem_ref_lsnr;
    
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030000000004050809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfs-protocol', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'nfs-protocol', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into elem_ref_proto;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030000000004050F0809181B23262A32343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'logfile-path', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'logfile-path', 'VARCHAR2', NULL, NULL, '/sys/log/nfslog.xml', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into elem_ref_logf;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
     XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030000000004050F0809181B23262A32343503150B0C0706272928'),  config_schema_ref, xdb.xdb$propnum_seq.nextval, 'log-level', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'log-level', 'NUMBER', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into elem_ref_logl;

end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds nfs-exports-type to xmlconfig
-------------------------------------------------------------------------------
create or replace procedure ats_nfsconfig(
                              config_schema_ref IN  REF XMLTYPE,
                              config_schema_url IN  VARCHAR2,
                              sysconfig_var     IN  VARCHAR2,
                              elem_ref_nfsexps  IN  REF SYS.XMLTYPE) as
  elem_ref_port   REF SYS.XMLTYPE;
  elem_ref_lsnr   REF SYS.XMLTYPE;
  elem_ref_proto  REF SYS.XMLTYPE;
  elem_ref_logf   REF SYS.XMLTYPE;
  elem_ref_logl   REF SYS.XMLTYPE;
  elem_ref_cfg    REF SYS.XMLTYPE;
  ellist          xdb.xdb$xmltype_ref_list_t;
  seq_ref         REF SYS.XMLTYPE;
  cpxt_ref        REF SYS.XMLTYPE;
  config_var      VARCHAR2(100);
  config_type     VARCHAR2(100);
begin

  ats_nfs_config2(config_schema_ref, config_schema_url, sysconfig_var,
                  elem_ref_port, elem_ref_lsnr, elem_ref_proto,
                  elem_ref_logf, elem_ref_logl);

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(6);
  ellist(1) := elem_ref_port;
  ellist(2) := elem_ref_lsnr;
  ellist(3) := elem_ref_proto;
  ellist(4) := elem_ref_logf;
  ellist(5) := elem_ref_logl;
  ellist(6) := elem_ref_nfsexps;

  insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800607'), config_schema_ref, 0, NULL, ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, 'nfsconfig78_T', 'XDB', '01', NULL, NULL, NULL,NULL))
  returning ref(c) into cpxt_ref;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838201080030400000004321C0809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nfsconfig', NULL, NULL, '0102', '00', '00', NULL, 'nfsconfig', 'nfsconfig78_T', 'XDB', NULL, NULL, NULL, cpxt_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cpxt_ref, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into elem_ref_cfg;

  element_type(config_schema_url, 'protocolconfig', config_var, config_type);
  add_to_config_seq(config_schema_ref, 'protocolconfig',
                   '230200030002001E207468657365206170706C7920746F20616C6C2070726F746F636F6C732002020E204654502073706563696669632002040F20485454502073706563696669632081800407', elem_ref_cfg);
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'nfsconfig' to 'protoconfig'.
--------------------------------------------------------------------------------
create or replace procedure ats_add_protoconfig(
                              config_schema_ref IN REF XMLTYPE,
                              config_schema_url IN VARCHAR2) as
  config_var         VARCHAR2(100);
  config_type        VARCHAR2(100);
  typestr            VARCHAR2(100);
begin
  element_type(config_schema_url, 'protocolconfig', config_var, config_type);

  typestr := '"nfsconfig" "' || config_var || '"."nfsconfig78_T"';

  alt_type_add_attribute_own(config_var, config_type, typestr);
  
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'default-workspace' to xmlconfig.
--------------------------------------------------------------------------------
create or replace procedure ats_default_workspace(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var               VARCHAR2(100);
  sysconfig_type              VARCHAR2(100);
  elem_ref_default_workspace  REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
  
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/default-workspace')
    is null then

   dbms_output.put_line('upgrading workspace'); 

   alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"default-workspace" VARCHAR2(4000 CHAR)');
  
   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'default-workspace', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'default-workspace', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_default_workspace;

    add_to_config_seq(config_schema_ref, 'sysconfig',
                     '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_default_workspace);
    commit;
  end if;

end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'num_job_queue_processes' to xmlconfig.
--------------------------------------------------------------------------------
create or replace procedure ats_num_job(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var               VARCHAR2(100);
  sysconfig_type              VARCHAR2(100);
  elem_ref_num_job            REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
  
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/num_job_queue_processes')
    is null then

   dbms_output.put_line('upgrading num_job'); 

   alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"num_job_queue_processes" NUMBER(10)');

  
   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
   XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'num_job_queue_processes', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'num_job_queue_processes', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_num_job;

    add_to_config_seq(config_schema_ref, 'sysconfig',
			'23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_num_job);
    commit;
  end if;

end;
/
show errors;


--------------------------------------------------------------------------------
-- This procedure adds 'http-host' to xdbconfig
--------------------------------------------------------------------------------
create or replace procedure ats_http_host(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  elem_ref_http_host     REF XMLTYPE;
begin

  element_type(config_schema_url, 'httpconfig', httpconf_type_owner,
                 httpconf_type);

  -- upgrade http-host if necessary
  if find_element(CONFIG_SCHEMA_URL,
                  '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host')
    is null then

    dbms_output.put_line('insert http-host into xdbconfig');

    alt_type_add_attribute_own(httpconf_type_owner, httpconf_type,
                               '"http-host" VARCHAR2(4000 CHAR)');

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'http-host', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'http-host', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_http_host;

    add_to_config_seq(config_schema_ref, 'httpconfig','230200000081801407',
                      elem_ref_http_host);
   
    commit;
  end if;
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'http2-host' to xdbconfig
--------------------------------------------------------------------------------
create or replace procedure ats_http2_host(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  elem_ref_http2_host     REF XMLTYPE;
begin

  element_type(config_schema_url, 'httpconfig', httpconf_type_owner,
                 httpconf_type);

  -- upgrade http2-host if necessary
  if find_element(CONFIG_SCHEMA_URL,
                  '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host')
    is null then

    dbms_output.put_line('insert http2-host into xdbconfig');

    alt_type_add_attribute_own(httpconf_type_owner, httpconf_type,
                               '"http2-host" VARCHAR2(4000 CHAR)');

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'http2-host', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'http2-host', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_http2_host;

    add_to_config_seq(config_schema_ref, 'httpconfig','230200000081801407',
                      elem_ref_http2_host);
   
    commit;
  end if;
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'acl-evaluation-method' to xmlconfig.
--------------------------------------------------------------------------------
create or replace procedure ats_acl_evaluation(
                              config_schema_ref IN REF XMLTYPE, 
                              config_schema_url IN VARCHAR2) as
  sysconfig_var      VARCHAR2(100);
  sysconfig_type     VARCHAR2(100);
  enum_ref           REF XMLTYPE;
  elem_ref_acl_eval      REF XMLTYPE;
begin
  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);
  
  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/acl-evaluation-method')
    is null then

    dbms_output.put_line('upgrading acl-evaluation'); 
 
    alt_type_add_attribute_own(sysconfig_var, sysconfig_type,
                             '"acl-evaluation-method" XDB.XDB$ENUM_T');
 
    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'deny-trumps-grant', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'ace-order', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL,NULL,NULL))
    returning ref(s) into enum_ref;


   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
   (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839AB82000800304000000040F32010809181B23262A343503150B0C0D07272928'), config_schema_ref,xdb.xdb$propnum_seq.nextval, 'acl-evaluation-method', NULL,NULL, '0103', '00', '00', NULL, 'acl-evaluation-method', 'XDB$ENUM_T', 'XDB', NULL, 'deny-trumps-grant', enum_ref,enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_acl_eval;

    add_to_config_seq(config_schema_ref, 'sysconfig',
                     '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807', elem_ref_acl_eval);
    commit;
  end if;
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure upgrades the config schema for rest of the projects
---------------------------------------------------------------------------------------
create or replace procedure upgrade_config_schema_rest as
  config_schema_ref  REF XMLTYPE;
  config_schema_url  VARCHAR2(100);
  smplt_ref_ipadd    REF SYS.XMLTYPE;
  elem_ref_nfsexps   REF SYS.XMLTYPE;
  sysconfig_var      VARCHAR2(100);
  sysconfig_type     VARCHAR2(100);
begin
  config_schema_url := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';

  select ref(s) into config_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = config_schema_url;

  element_type(config_schema_url, 'sysconfig', sysconfig_var, sysconfig_type);

  dbms_output.put_line('upgrading config schema');
  
  ats_folder_hard_links(config_schema_ref, config_schema_url);
  ats_non_folder_hard_links(config_schema_ref, config_schema_url);
  ats_copy_on_inconsist_upd(config_schema_ref, config_schema_url);
  ats_rollback_on_sync_error(config_schema_ref, config_schema_url);

  if find_element(config_schema_url,
                  '/xdbconfig/sysconfig/protocolconfig/nfsconfig')
    is null then

        dbms_output.put_line('upgrading nfsconfig');         

  	ats_create_types(config_schema_ref, config_schema_url, sysconfig_var);
        ats_add_protoconfig(config_schema_ref, config_schema_url);
  	ats_type_ipaddress(config_schema_ref, config_schema_url, smplt_ref_ipadd);
  	ats_type_nfs_exports_type2(config_schema_ref, config_schema_url, sysconfig_var,smplt_ref_ipadd, elem_ref_nfsexps);
  	ats_nfsconfig(config_schema_ref, config_schema_url, sysconfig_var,
                  elem_ref_nfsexps);
   
  	commit;
  end if;

  ats_acl_evaluation(config_schema_ref,config_schema_url);
  ats_default_workspace(config_schema_ref, config_schema_url);
  ats_num_job(config_schema_ref, config_schema_url);
  ats_http_host(config_schema_ref, config_schema_url);
  ats_http2_host(config_schema_ref, config_schema_url);

  dbms_output.put_line('config schema upgraded'); 
end;
/
show errors;

create or replace function element_exists(schema_url IN varchar2,ell_name IN varchar2) return boolean
as
  c  integer;
begin 

  select count(e.xmldata.property.name) into c from xdb.xdb$element e, xdb.xdb$schema s where s.xmldata.schema_url = schema_url  and e.xmldata.property.parent_schema = ref(s) and e.xmldata.property.name = ell_name;

  if c = 0 then
    return FALSE;
  else
    return TRUE;
  end if;
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure upgrades the resource type.
---------------------------------------------------------------------------------------
create or replace procedure upgrade_resource_type as
  ellist    XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_ref  REF XMLTYPE;
begin

  dbms_output.put_line('upgrading resource types'); 

  alter_type('alter type xdb.xdb$resource_t add attribute (snapshot raw(6)) cascade');

  alter_type('alter type xdb.xdb$resource_t add attribute (attrcopy blob) cascade');

  alter_type('alter type xdb.xdb$resource_t add attribute (ctscopy  blob) cascade');
  
  alter_type('alter type xdb.xdb$resource_t add attribute (nodenum  raw(6)) cascade');
  
  alter_type('alter type xdb.xdb$resource_t add attribute (sizeondisk  integer) cascade');  

  alter_type('alter type xdb.xdb$resource_t add attribute (checkedoutbyid  raw(16)) cascade');  

  alter_type('alter type xdb.xdb$resource_t add attribute (baseversion  raw(16)) cascade');  

  alter_type('create or replace type xdb.xdb$oid_list_t as varray(65535) of raw(16)');

  alter_type('create or replace type xdb.xdb$rclist_t ' ||                                 'as object ( oid          xdb.xdb$oid_list_t)'); 
 
  alter_type('alter type xdb.xdb$resource_t add attribute (rclist xdb.xdb$rclist_t) cascade');  

  select s.xmldata.elements into ellist
  from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  elem_ref := ellist(1);

  update xdb.xdb$element e
  set e.xmldata.num_cols = 33
  where ref(e) = elem_ref;
  commit; 
  
  dbms_output.put_line('resource types upgraded'); 
end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds 1 element to ResourceType sequence.
-------------------------------------------------------------------------------
create or replace procedure add_to_resource_element_seq(
                              sch_ref  IN REF XMLTYPE,
                              elem_ref IN REF XMLTYPE) as
  restype_seq_ref        REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  -- select the sequence kid corresponding to the restype type
  select c.xmldata.sequence_kid into restype_seq_ref
  from xdb.xdb$complex_type c 
  where c.xmldata.name = 'ResourceType' and
        c.xmldata.parent_schema = sch_ref;

  -- select the sequence elements
  select m.xmldata.elements into elem_arr 
  from xdb.xdb$sequence_model m
  where ref(m) = restype_seq_ref;

  -- extend it to add 1 element just created
  elem_arr.extend(1);
  elem_arr(elem_arr.last)   := elem_ref;

  -- update the table with the extended sequence and new pd
  update xdb.xdb$sequence_model m
  set m.xmldata.elements = elem_arr
  where ref(m) = restype_seq_ref;
end;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure adds 1 attribute to ResourceType attributes.
-------------------------------------------------------------------------------
create or replace procedure add_to_resource_attr_seq(
                              sch_ref  IN REF XMLTYPE,
                              attr_ref IN REF XMLTYPE) as
  attr_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  -- select the attributes array corresponding to the restype type
  select c.xmldata.attributes into attr_arr
  from xdb.xdb$complex_type c 
  where c.xmldata.name = 'ResourceType' and
        c.xmldata.parent_schema = sch_ref;

  -- extend it to add 1 element just created
  attr_arr.extend(1);
  attr_arr(attr_arr.last)   := attr_ref;

  -- update the table with the extended list and new pd
  update xdb.xdb$complex_type c
  set c.xmldata.attributes = attr_arr
  where c.xmldata.name = 'ResourceType' and
        c.xmldata.parent_schema = sch_ref;
end;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure adds 'snapshot' to resource schema
--------------------------------------------------------------------------------
create or replace procedure add_to_resource_schema(
                              schema_ref IN REF XMLTYPE) as
  elem_ref_snapshot           REF XMLTYPE;
  elem_ref_attrcopyt          REF XMLTYPE;
  elem_ref_attrcopy           REF XMLTYPE;
  elem_ref_ctscopy            REF XMLTYPE;
  elem_ref_nodenum            REF XMLTYPE;
  elem_ref_sizeondisk         REF XMLTYPE;
  elem_ref_contentsize        REF XMLTYPE;
  elem_ref_branch             REF XMLTYPE;
  elem_ref_checkedoutby       REF XMLTYPE;
  elem_ref_checkedoutbyid     REF XMLTYPE;
  elem_ref_base_version       REF XMLTYPE;
  elem_ref_oid                REF XMLTYPE;
  elem_ref_rclist             REF XMLTYPE;
  elem_ref_rclist_t           REF XMLTYPE;
  attr_ref_sizeaccurate       REF XMLTYPE;
  attr_ref_isversionable      REF XMLTYPE;
  attr_ref_ischeckedout       REF XMLTYPE;
  attr_ref_isversion          REF XMLTYPE;
  attr_ref_isvcr              REF XMLTYPE;
  attr_ref_isversionhistory   REF XMLTYPE;
  attr_ref_isworkspace        REF XMLTYPE;
  attr_ref_hasunresolvedlinks REF XMLTYPE;
  attr_ref_isxmlindexed       REF XMLTYPE;
  seq_ref                     REF XMLTYPE;
  seq_ref_oid                 REF XMLTYPE;
  any_ref                     REF XMLTYPE;
  oraclename_ref              REF XMLTYPE;
  guid_ref                    REF XMLTYPE;
  complex_type                REF XMLTYPE;
  toplocksel_ref              REF XMLTYPE;
  lockstype_ref               REF XMLTYPE;
  lock_ref                    REF XMLTYPE;
  locktype_ref                REF XMLTYPE;
  seq_ref_lock                REF XMLTYPE;
  lock_mode_type_simple_ref   REF XMLTYPE;
  lock_type_type_simple_ref   REF XMLTYPE;
  lock_depth_type_simple_ref  REF XMLTYPE;
  lockowner_ref               REF XMLTYPE;
  mode_ref                    REF XMLTYPE;
  type_ref                    REF XMLTYPE;
  depth_ref                   REF XMLTYPE;
  expiry_ref                  REF XMLTYPE;
  token_ref                   REF XMLTYPE;
  nodeid_ref                  REF XMLTYPE;
  choice_ref                  REF XMLTYPE;
  elem_ref_locks              REF XMLTYPE;
  simple_ref                  REF XMLTYPE;
  ellist                      xdb.xdb$xmltype_ref_list_t;
  ellist_oid                  xdb.xdb$xmltype_ref_list_t;
  simplelist                  XDB.XDB$XMLTYPE_REF_LIST_T;
  complex_arr                 XDB.XDB$XMLTYPE_REF_LIST_T;
  schema_ellist               XDB.XDB$XMLTYPE_REF_LIST_T;
  ellist_lock                 xdb.xdb$xmltype_ref_list_t;
  complex_arr_new             XDB.XDB$XMLTYPE_REF_LIST_T;
  simple_list                 XDB.XDB$XMLTYPE_REF_LIST_T;
  choice_ellist               XDB.XDB$XMLTYPE_REF_LIST_T;
  choice_list                 XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_count                  number;  
  schema_url                  varchar2(100);
begin

  schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  select s.xmldata.simple_type into simplelist
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  oraclename_ref := simplelist(1);
  guid_ref := simplelist(4);

  if not element_exists(schema_url,'Snapshot') then
   dbms_output.put_line('upgrading snapshot');  
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 746, 'Snapshot', XDB.XDB$QNAME('00', 'hexBinary'), NULL, '17', '00', '01', NULL, 'SNAPSHOT', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', NULL, NULL, '01'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_snapshot;
   add_to_resource_element_seq(schema_ref, elem_ref_snapshot);
  end if;

  if  not element_exists(schema_url,'AttrCopy') then
   insert into xdb.xdb$any e (e.xmldata) values
    (XDB.XDB$ANY_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 748, 'AttrCopyAny', NULL, NULL, '0102', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('10'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, NULL, 0, '65535'))
   returning ref(e) into any_ref;

   ellist := xdb.xdb$xmltype_ref_list_t();
   ellist.extend(1);
   ellist(1) := any_ref;

   insert into xdb.xdb$sequence_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL, schema_ref, 1, '1', NULL, NULL, NULL, ellist, NULL, NULL, NULL))
   returning ref(m) into seq_ref;

   insert into xdb.xdb$complex_type e (e.xmldata) values
    (XDB.XDB$COMPLEX_T(NULL, schema_ref, NULL, 'AttrCopyType', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL))
   returning ref(e) into elem_ref_attrcopyt;

   select s.xmldata.complex_types into complex_arr
   from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

   complex_type := complex_arr(complex_arr.last);
   complex_arr.extend(1);
   complex_arr(complex_arr.last - 1) := elem_ref_attrcopyt;
   complex_arr(complex_arr.last) := complex_type;

   update xdb.xdb$schema s
   set s.xmldata.complex_types = complex_arr
   where s.xmldata.schema_url = schema_url;

 
   dbms_output.put_line('upgrading attrcopy');  
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 747, 'AttrCopy', XDB.XDB$QNAME('01', 'AttrCopyType'), NULL, '0102', '00', '01', NULL, 'ATTRCOPY', 'BLOB', NULL, XDB.XDB$JAVATYPE('10'), NULL, NULL, elem_ref_attrcopyt, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', NULL, NULL, '01'), NULL, 0, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_attrcopy;
   add_to_resource_element_seq(schema_ref, elem_ref_attrcopy);
  end if;

  if not element_exists(schema_url,'CtsCopy') then 
   dbms_output.put_line('upgrading ctscopy'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 749, 'CtsCopy', XDB.XDB$QNAME('00', 'hexBinary'), NULL, '71', '00', '01', NULL, 'CTSCOPY', 'BLOB', NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', NULL, NULL, '00'), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_ctscopy;
   add_to_resource_element_seq(schema_ref, elem_ref_ctscopy);
  end if;

  if not element_exists(schema_url,'NodeNum') then
   dbms_output.put_line('upgrading nodenum');  
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 750, 'NodeNum', XDB.XDB$QNAME('00', 'hexBinary'), NULL, '17', '00', '01', NULL, 'NODENUM', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', NULL, NULL, '01'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_nodenum;
   add_to_resource_element_seq(schema_ref, elem_ref_nodenum);
  end if;

  if not element_exists(schema_url,'ContentSize') then
   dbms_output.put_line('upgrading content size');  
   insert into xdb.xdb$element e (e.xmldata) values 
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,751, 'ContentSize', XDB.XDB$QNAME('00', 'nonNegativeInteger'), '08', '03', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('02'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_contentsize;
   add_to_resource_element_seq(schema_ref, elem_ref_contentsize);
  end if;

  if not element_exists(schema_url,'SizeOnDisk') then
   dbms_output.put_line('upgrading sizeondisk');  
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,752,'SizeOnDisk', XDB.XDB$QNAME('00', 'nonNegativeInteger'), '08', '03', '00', '00', NULL, 'SIZEONDISK', 'INTEGER', NULL, XDB.XDB$JAVATYPE('02'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', NULL, NULL, '01'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_sizeondisk;
   add_to_resource_element_seq(schema_ref, elem_ref_sizeondisk);
  end if;

  if not attr_exists(schema_url,'SizeAccurate') then 
   dbms_output.put_line('upgrading sizeaccurate'); 
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,753, 'SizeAccurate', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '01', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_sizeaccurate;
   add_to_resource_attr_seq(schema_ref, attr_ref_sizeaccurate);
  end if;

  if not element_exists(schema_url,'OID') then
   dbms_output.put_line('upgrading oid');   
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,755, 'OID', XDB.XDB$QNAME('00', 'hexBinary'), '16', '17', '00', '00', NULL, 'OID', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, 'XDB$OID_LIST_T', 'XDB', '00',NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '65535', NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_oid;
  
   ellist_oid := xdb.xdb$xmltype_ref_list_t();
   ellist_oid.extend(1);
   ellist_oid(1) := elem_ref_oid;

   insert into xdb.xdb$sequence_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL, schema_ref, 1, '1', ellist_oid, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(m) into seq_ref_oid;

   insert into xdb.xdb$complex_type e (e.xmldata) values
    (XDB.XDB$COMPLEX_T(NULL, schema_ref, NULL, 'RCListType', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref_oid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL))
   returning ref(e) into elem_ref_rclist_t;

   select s.xmldata.complex_types into complex_arr
   from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

   complex_type := complex_arr(complex_arr.last);
   complex_arr.extend(1);
   complex_arr(complex_arr.last - 1) := elem_ref_rclist_t;
   complex_arr(complex_arr.last) := complex_type;

   update xdb.xdb$schema s
   set s.xmldata.complex_types = complex_arr
   where s.xmldata.schema_url = schema_url;
   end if;


  if not element_exists(schema_url,'RCList') then 
   dbms_output.put_line('upgrading rclist'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 754, 'RCList', XDB.XDB$QNAME('01', 'RCListType'), NULL, '0102', '00', '00', NULL, 'RCLIST', 'XDB$RCLIST_T', 'XDB', XDB.XDB$JAVATYPE('10'), NULL, NULL, elem_ref_rclist_t, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '01', NULL, NULL, '01'), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', '00', 'XDB', NULL, 'oracle.xdb.RCList', 'oracle.xdb.RCListBean', NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_rclist;
   add_to_resource_element_seq(schema_ref, elem_ref_rclist);
  end if;

  if not attr_exists(schema_url,'IsVersionable') then 
   dbms_output.put_line('upgrading isversionable'); 
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,756, 'IsVersionable', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))  
   returning ref(e) into attr_ref_isversionable;
   add_to_resource_attr_seq(schema_ref, attr_ref_isversionable);
  end if;

  if not attr_exists(schema_url,'IsCheckedOut') then
   dbms_output.put_line('upgrading ischeckedout');  
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL,schema_ref,757, 'IsCheckedOut', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_ischeckedout;
   add_to_resource_attr_seq(schema_ref, attr_ref_ischeckedout);
  end if;

  if  not attr_exists(schema_url,'IsVersion') then
   dbms_output.put_line('upgrading isversion'); 
   insert into xdb.xdb$attribute e (e.xmldata) values
     (XDB.XDB$PROPERTY_T(NULL, schema_ref,758, 'IsVersion', XDB.XDB$QNAME('00', 'boolean'), '01','FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_isversion;
   add_to_resource_attr_seq(schema_ref, attr_ref_isversion);
  end if;

  if not attr_exists(schema_url,'IsVCR') then
   dbms_output.put_line('upgrading isvcr'); 
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,759, 'IsVCR', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_isvcr;
   add_to_resource_attr_seq(schema_ref, attr_ref_isvcr);
  end if;

  if not attr_exists(schema_url,'IsVersionHistory') then
   dbms_output.put_line('upgrading isversionhistory'); 
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,760, 'IsVersionHistory', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_isversionhistory;
   add_to_resource_attr_seq(schema_ref, attr_ref_isversionhistory);
  end if;

  if not attr_exists(schema_url,'IsWorkspace') then
   dbms_output.put_line('upgrading isworkspace');  
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,761, 'IsWorkspace', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_isworkspace;
   add_to_resource_attr_seq(schema_ref, attr_ref_isworkspace);
  end if;

  if not attr_exists(schema_url,'HasUnresolvedLinks') then
   dbms_output.put_line('upgrading HasUnresolvedLinks');  
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,776, 'HasUnresolvedLinks', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_hasunresolvedlinks;
   add_to_resource_attr_seq(schema_ref, attr_ref_hasunresolvedlinks);
  end if;

  if not element_exists(schema_url,'Branch') then
   dbms_output.put_line('upgrading branch'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,762, 'Branch', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'BRANCH', 'VARCHAR2', NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'), NULL, 1, '00', NULL, NULL, '00', '00', '01','00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_branch;
   add_to_resource_element_seq(schema_ref, elem_ref_branch);
  end if;

  if not element_exists(schema_url,'CheckedOutBy') then
   dbms_output.put_line('upgrading checkedout by'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,763, 'CheckedOutBy', XDB.XDB$QNAME('01','OracleUserName'), NULL, '01', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, oraclename_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'), NULL, 0, '00', NULL, NULL, '00', '00','01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_checkedoutby;
   add_to_resource_element_seq(schema_ref, elem_ref_checkedoutby);
  end if;

  if not element_exists(schema_url,'CheckedOutByID') then
   dbms_output.put_line('upgrading checkedoutbyid'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,764, 'CheckedOutByID', XDB.XDB$QNAME('01', 'GUID'), NULL, '17', '00', '00', NULL, 'CHECKEDOUTBYID', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, guid_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL,'01', NULL, NULL, '01'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_checkedoutbyid;
   add_to_resource_element_seq(schema_ref, elem_ref_checkedoutbyid);
  end if;

  if not element_exists(schema_url,'BaseVersion') then
   dbms_output.put_line('upgrading baseversion'); 
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref,765, 'BaseVersion', XDB.XDB$QNAME('00', 'hexBinary'), NULL, '17', '00', '00', NULL, 'BASEVERSION', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_base_version;
   add_to_resource_element_seq(schema_ref, elem_ref_base_version);
  end if;

  if not attr_exists(schema_url,'IsXMLIndexed') then
   dbms_output.put_line('upgrading isxmlindexed');  
   insert into xdb.xdb$attribute e (e.xmldata) values
    (XDB.XDB$PROPERTY_T(NULL, schema_ref,777, 'IsXMLIndexed', XDB.XDB$QNAME('00', 'boolean'), '01', 'FC', '00', '00', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('08'), 'false', NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '01', XDB.XDB$TRANSIENTCHOICE('01'), NULL, '00'))
   returning ref(e) into attr_ref_isxmlindexed;
   add_to_resource_attr_seq(schema_ref, attr_ref_isxmlindexed);
  end if;

   dbms_output.put_line('upgrading simple types');
   select s.xmldata.simple_type into simple_list
   from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

   -- delete old LockScopeType simple type
   simple_ref := simple_list(simple_list.last);
   delete from xdb.xdb$simple_type s where ref(s) = simple_ref;   

   insert into xdb.xdb$simple_type e (e.xmldata) values
     (XDB.XDB$SIMPLE_T(NULL, schema_ref, 'lockModeType', NULL, XDB.XDB$SIMPLE_DERIVATION_T(NULL, NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(NULL, NULL, 'exclusive', '00', NULL), XDB.XDB$FACET_T(NULL, NULL, 'shared', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into lock_mode_type_simple_ref;

   insert into xdb.xdb$simple_type e (e.xmldata) values
   (XDB.XDB$SIMPLE_T(NULL, schema_ref, 'lockTypeType', NULL, XDB.XDB$SIMPLE_DERIVATION_T(NULL, NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(NULL, NULL, 'read-write', '00', NULL), XDB.XDB$FACET_T(NULL, NULL, 'write', '00', NULL), XDB.XDB$FACET_T(NULL, NULL, 'read', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into lock_type_type_simple_ref;

   insert into xdb.xdb$simple_type e (e.xmldata) values
     (XDB.XDB$SIMPLE_T(NULL, schema_ref, 'lockDepthType', NULL, XDB.XDB$SIMPLE_DERIVATION_T(NULL,NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(NULL, NULL, '0', '00', NULL), XDB.XDB$FACET_T(NULL, NULL, 'infinity', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into lock_depth_type_simple_ref;
   
   simple_list.extend(2);
   simple_list(6) := lock_mode_type_simple_ref;
   simple_list(7) := lock_type_type_simple_ref;
   simple_list(8) := lock_depth_type_simple_ref;

    update xdb.xdb$schema s
    set s.xmldata.simple_type = simple_list
    where s.xmldata.schema_url = schema_url;

   -- remove old elements and attributes
   select c.xmldata.attributes,c.xmldata.sequence_kid into ellist,seq_ref
   from xdb.xdb$complex_type c
   where c.xmldata.name = 'LockType';

   delete from xdb.xdb$attribute e where ref(e) = ellist(1);

   select m.xmldata.elements into ellist
   from xdb.xdb$sequence_model m
   where ref(m) = seq_ref;  

   delete_elem_by_ref(ellist(1));
   delete_elem_by_ref(ellist(2));	
   delete_elem_by_ref(ellist(3));

   delete from xdb.xdb$sequence_model m where ref(m) = seq_ref;

   delete from xdb.xdb$complex_type c where ref(c) = (select ref(c) 
	from xdb.xdb$complex_type c where c.xmldata.name = 'LockType');
   

   ellist := xdb.xdb$xmltype_ref_list_t();
   ellist.extend(5);

  if not element_exists(schema_url,'LockOwner') then
   dbms_output.put_line('upgrading element LockOwner');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 768, 'LockOwner', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL,NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into lockowner_ref;
  
    ellist(1) := lockowner_ref;
  end if;

   if not element_exists(schema_url,'Mode') then
   dbms_output.put_line('upgrading element Mode');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 769, 'Mode', XDB.XDB$QNAME('01', 'lockModeType'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, lock_mode_type_simple_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB',NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into mode_ref;
  
    ellist(2) := mode_ref;
  end if;

   if not element_exists(schema_url,'Type') then
   dbms_output.put_line('upgrading element Type');   
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 770, 'Type', XDB.XDB$QNAME('01', 'lockTypeType'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, lock_type_type_simple_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB',NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into type_ref;
  
    ellist(3) := type_ref;
  end if;

   if not element_exists(schema_url,'Depth') then
   dbms_output.put_line('upgrading element Depth');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 771, 'Depth', XDB.XDB$QNAME('01', 'lockDepthType'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, lock_depth_type_simple_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into depth_ref;

    ellist(4) := depth_ref;
  end if;

    if not element_exists(schema_url,'Expiry') then
   dbms_output.put_line('upgrading element Expiry');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 772, 'Expiry', XDB.XDB$QNAME('00', 'dateTime'), NULL, 'B4', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('0C'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into expiry_ref;

    ellist(5) := expiry_ref;
  end if;

  choice_ellist := xdb.xdb$xmltype_ref_list_t();
  choice_ellist.extend(2);

  if not element_exists(schema_url,'Token') then
   dbms_output.put_line('upgrading element Token');   
   insert into xdb.xdb$element e (e.xmldata) values
    (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 773, 'Token', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into token_ref;

   choice_ellist(1) := token_ref;
 end if;

    if not element_exists(schema_url,'NodeId') then
   dbms_output.put_line('upgrading element NodeId');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 774, 'NodeId', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL,NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL))
   returning ref(e) into nodeid_ref;

   choice_ellist(2) := nodeid_ref;
 end if;


  insert into xdb.xdb$choice_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL, schema_ref, 0, 'unbounded',choice_ellist, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into choice_ref;

  choice_list := xdb.xdb$xmltype_ref_list_t();
  choice_list.extend(1);
  choice_list(1) := choice_ref;

  insert into xdb.xdb$sequence_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL,schema_ref, 1, '1', ellist,choice_list, NULL, NULL, NULL, NULL, NULL))
  returning ref(m) into seq_ref;

   insert into xdb.xdb$complex_type e (e.xmldata) values
    (XDB.XDB$COMPLEX_T(NULL, schema_ref, NULL, 'lockType', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into locktype_ref;

  select count(*) into elem_count from xdb.xdb$element e 
  where e.xmldata.property.prop_number = 767;
  

  if elem_count = 0 then
   dbms_output.put_line('upgrading element Lock');   
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 767, 'Lock', XDB.XDB$QNAME('01', 'lockType'), NULL, '0102', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('10'), NULL, NULL, locktype_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2147483647', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into lock_ref;
  
   ellist_lock:= xdb.xdb$xmltype_ref_list_t();
   ellist_lock.extend(1);
   ellist_lock(1) := lock_ref;

   insert into xdb.xdb$sequence_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL, schema_ref, 1, '1', ellist_lock, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(m) into seq_ref_lock;

   insert into xdb.xdb$complex_type e (e.xmldata) values
     (XDB.XDB$COMPLEX_T(NULL, schema_ref, NULL, 'locksType', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref_lock, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into lockstype_ref;

   select s.xmldata.complex_types into complex_arr
   from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

   complex_arr_new := xdb.xdb$xmltype_ref_list_t();
   complex_arr_new.extend(7);

   complex_arr_new(1) := locktype_ref;
   complex_arr_new(2) := lockstype_ref;
   complex_arr_new(3) := complex_arr(2);
   complex_arr_new(4) := complex_arr(3);
   complex_arr_new(5) := complex_arr(4);
   complex_arr_new(6) := complex_arr(5);
   complex_arr_new(7) := complex_arr(6);

   update xdb.xdb$schema s
   set s.xmldata.complex_types = complex_arr_new
   where s.xmldata.schema_url = schema_url;
   end if;  
   
   --Rename Lock to LockBuf
   select count(*) into elem_count from xdb.xdb$element e
   where e.xmldata.property.prop_number = 718;

   if not elem_count = 0 then
   
     dbms_output.put_line('renaming Lock element');
     update xdb.xdb$element e
     set e.xmldata.property.name = 'LockBuf'
     where e.xmldata.property.prop_number = 718 and 
     e.xmldata.property.name = 'Lock';
   end if;

   if not element_exists(schema_url,'Locks') then
   dbms_output.put_line('upgrading Locks');  
   insert into xdb.xdb$element e (e.xmldata) values
     (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 766, 'Locks', XDB.XDB$QNAME('01', 'locksType'), NULL, '0102', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('10'), NULL, NULL, lockstype_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '01', XDB.XDB$TRANSIENTCHOICE('01'), NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_locks;
   add_to_resource_element_seq(schema_ref, elem_ref_locks);

   dbms_output.put_line('upgrading top level locks element');
    insert into xdb.xdb$element e (e.xmldata) values
      (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 775, 'Locks', XDB.XDB$QNAME('01', 'locksType'), NULL, '0102', '00', '01', NULL, NULL, NULL, NULL, XDB.XDB$JAVATYPE('10'), NULL, NULL, lockstype_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB',NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into toplocksel_ref;

    select s.xmldata.elements into schema_ellist
    from xdb.xdb$schema s
    where s.xmldata.schema_url = schema_url;

    schema_ellist.extend(1);
    schema_ellist(schema_ellist.last) := toplocksel_ref;

    update xdb.xdb$schema s
    set s.xmldata.elements = schema_ellist
    where s.xmldata.schema_url = schema_url;
  end if;  
  
   

end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure adds the stateid and clientid seq
---------------------------------------------------------------------------------------
create or replace procedure add_nfs_sequences as
  sch_ref                 REF SYS.XMLTYPE;
begin  
 
  dbms_output.put_line('upgrading nfs sequences'); 

  execute immediate
      'create sequence xdb.stateid_restart_sequence increment by 1 start with 1 minvalue 1 nocycle';
  
  execute immediate
      'create sequence xdb.clientid_sequence increment by 1 start with 1 minvalue 1 cache 10 nocycle';

  dbms_output.put_line('nfs sequences upgraded'); 

  end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure upgrades the resource schema.
---------------------------------------------------------------------------------------
create or replace procedure upgrade_resource_schema as
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 73;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
begin  

-- get the Resource schema's REF
    select ref(s) into sch_ref from xdb.xdb$schema s where  
    s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

-- Has the property already been added
    select s.xmldata.num_props into numprops from xdb.xdb$schema s 
    where ref(s) = sch_ref;

    IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

      dbms_output.put_line('upgrading resource schema'); 

      add_to_resource_schema(sch_ref);      

      update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
      where ref(s) = sch_ref;
      commit;
    END IF;
    upgrade_resource_type();
    add_nfs_sequences();

   dbms_output.put_line('resource schema upgraded'); 
end;
/
show errors;


-----------------------------------------------------------------------------
--- This procedure updates the config schema for digest ---
-----------------------------------------------------------------------------

create or replace procedure upgrade_config_schema_digest as
  CONFIG_SCHEMA_URL      CONSTANT VARCHAR2(100) :=
                           'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_schema_ref      REF XMLTYPE;
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  auth_type              varchar2(100);
  digest_auth_type       varchar2(100); 
  almech_enum_coll_type  varchar2(100); 
  enum_ref               REF XMLTYPE;
  seq_ref                REF XMLTYPE;
  cplx_ref               REF XMLTYPE;
  elem_ref_digest_auth   REF XMLTYPE;
  elem_ref_almech        REF XMLTYPE; 
  elem_ref_auth          REF XMLTYPE; 
  httpcf_seq_ref         REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
begin

  select ref(s) into config_schema_ref from xdb.xdb$schema s
   where s.xmldata.schema_url = CONFIG_SCHEMA_URL;

  -- Upgrade authentication element if necessary
  if find_element(CONFIG_SCHEMA_URL,
                  '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication')
    is null then

     dbms_output.put_line('upgrading config schema for digest'); 

    element_type(CONFIG_SCHEMA_URL, 'httpconfig', httpconf_type_owner,
                 httpconf_type);

    almech_enum_coll_type := type_name('allow-mechanism', 'COLL');
    digest_auth_type := type_name('digest-auth', 'T'); 
    auth_type := type_name('authentication', 'T');

    -- Create type 'digest-auth??_T' and 'authentication??_T'
    execute immediate 'create or replace type "' || httpconf_type_owner||'".'||
      '"'||digest_auth_type||'" as object ( '                    ||
          'sys_xdbpd$         xdb.xdb$raw_list_t, ' ||
          '"nonce-timeout"        number(10), '         ||
          '"force-integrity"      number(1))';
    execute immediate 'create or replace type "' || httpconf_type_owner||'".'||
    '"'||almech_enum_coll_type||'" as varray(2147483647) of xdb.xdb$enum_t';
    execute immediate 'create or replace type "' || httpconf_type_owner||'".'||
    '"'||auth_type||'" as object ( '             ||
        'sys_xdbpd$                  xdb.xdb$raw_list_t, '  ||
        '"allow-mechanism"           "'||httpconf_type_owner||'"."'||
                                         almech_enum_coll_type||'", ' ||
        '"digest-auth"               "'||httpconf_type_owner||'"."'||
                                         digest_auth_type||'")'; 

    alt_type_add_attribute_own(httpconf_type_owner, httpconf_type,
                           '"authentication" "'||httpconf_type_owner||'"."'||
                                        auth_type || '"');

    -- create the element and sub-element types corresponding to
    -- /sysconfig/protocolconfig/httpconfig/authentication/digest-auth
    elem_arr := xdb.xdb$xmltype_ref_list_t();
    elem_arr.extend(2);

    -- Need to find the corresponding values though... most value are not correct
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030C000000040532330F0809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nonce-timeout', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'nonce-timeout', 'NUMBER', NULL, NULL, '300', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(1); -- nonce-time

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030C000000040532330F0809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'force-integrity', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'force-integrity', 'RAW', NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(2); -- force-integrity

    insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), config_schema_ref, 0, NULL, elem_arr, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(m) into seq_ref;  -- seq(nonce-timeout, force-integrity)

    insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, digest_auth_type, 'XDB', '01', NULL, NULL, NULL,NULL))
      returning ref(c) into cplx_ref; -- complex_type(digest-auth)

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838201080030C0000000432331C0809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'digest-auth', NULL, NULL, '0102', '00', '00', NULL, 'digest-auth', digest_auth_type, 'XDB', NULL, NULL, NULL, cplx_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cplx_ref, NULL, NULL, 0, '1', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_digest_auth; -- digest-auth element

    -- create the element and sub-element types corresponding to
    -- /sysconfig/protocolconfig/httpconfig/authentication
    elem_arr := xdb.xdb$xmltype_ref_list_t();
    elem_arr.extend(2);

    -- Now let's deal with allow-mechanism. 
    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'digest', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'basic', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL,NULL,NULL))
      returning ref(s) into enum_ref; -- simple type for allow-mechanism

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A38E00080030C000000043233010809181B23262A343503150B0C0D072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'allow-mechanism', NULL, NULL, '0103', '00', '00', NULL, 'allow-mechanism', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, almech_enum_coll_type,'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01','01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_almech; -- allow-mechanism

    elem_arr(1)  :=  elem_ref_almech; 
    elem_arr(2)  :=  elem_ref_digest_auth; 

    insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), config_schema_ref, 0, NULL, elem_arr, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(m) into seq_ref;  -- seq(allow-mechanism, digest-auth)

    insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, auth_type, 'XDB', '01', NULL, NULL, NULL,NULL))
      returning ref(c) into cplx_ref; -- complex_type(authentication)

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838201080030C0000000432331C0809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'authentication', NULL, NULL, '0102', '00', '00', NULL, 'authentication', auth_type, 'XDB', NULL, NULL, NULL, cplx_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cplx_ref, NULL, NULL, 0, '1', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_auth; -- authentication element

    -- select the sequence kid corresponding to the httpconfig type
    select c.xmldata.sequence_kid into httpcf_seq_ref from 
      xdb.xdb$complex_type c where ref(c)=
        (select e.xmldata.cplx_type_decl from xdb.xdb$element e
          where e.xmldata.property.name='httpconfig' and
          e.xmldata.property.parent_schema = config_schema_ref);

    -- select the sequence elements
    select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
     where ref(m) = httpcf_seq_ref;
  
    -- extend it to add the three elements just created
    elem_arr.extend(1);
    elem_arr(elem_arr.last)   := elem_ref_auth;

    -- update the table with the extended sequence and new pd
    update xdb.xdb$sequence_model m
       set m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801207')
      where ref(m) = httpcf_seq_ref;

  end if; -- Upgrade authentication
  commit;
   dbms_output.put_line('config schema upgraded for digest'); 
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure upgrades the config schema
---------------------------------------------------------------------------------------
create or replace procedure upgrade_config_schema as
  config_schema_ref  REF XMLTYPE;
  config_schema_url  VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 171;
  num_props          number;
begin
  config_schema_url := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';

  select ref(s) into config_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = config_schema_url;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s 
    where ref(s) = config_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then
   upgrade_config_schema_rest();
   upgrade_config_schema_digest();

   update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
   where ref(s) = config_schema_ref;
  
   commit;
  end if; 
end;
/
show errors;

create or replace procedure add_to_acl_schema(
			      acl_schema_url IN VARCHAR2,
                              elem_ref       IN REF XMLTYPE) as
 
  ell_arr    XDB.XDB$XMLTYPE_REF_LIST_T;
  subs_arr   XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  select s.xmldata.elements into ell_arr
  from xdb.xdb$schema s
  where s.xmldata.schema_url = acl_schema_url;

  ell_arr.extend(1);
  ell_arr(ell_arr.last) := elem_ref;

  update xdb.xdb$schema s
  set s.xmldata.elements = ell_arr
  where s.xmldata.schema_url = acl_schema_url; 

  update xdb.xdb$schema s
  set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43153C860009008400008403018404020207322070726976696C6567654E616D655479706520287468697320697320616E20656D707479636F6E74656E74207479706529200209762070726976696C6567654E616D6520656C656D656E740A20202020202020416C6C2073797374656D20616E6420757365722070726976696C656765732061726520696E2074686520737562737469747574696F6E47726F75700A202020202020206F66207468697320656C656D656E742E0A20202020020B3020616C6C2073797374656D2070726976696C6567657320696E20746865205844422041434C206E616D657370616365200218132070726976696C65676520656C656D656E7420021A0D2061636520656C656D656E7420021C0D2061636C20656C656D656E74200B0C110002848011131416120A170D')
  where s.xmldata.schema_url = acl_schema_url; 

  select e.xmldata.subs_group_refs into subs_arr
  from xdb.xdb$element e
  where e.xmldata.property.name = 'privilegeName';

  subs_arr.extend(1);
  subs_arr(subs_arr.last) := elem_ref;

  update xdb.xdb$element e
  set e.xmldata.subs_group_refs = subs_arr
  where e.xmldata.property.name = 'privilegeName'; 

end;
/
show errors;


create or replace procedure ats_write_config(
                              acl_schema_ref IN REF XMLTYPE, 
                              acl_schema_url IN VARCHAR2) as
 
  elem_ref_write_config    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(acl_schema_url,
                  '/write-config')
    is null then

    dbms_output.put_line('upgrading write-config'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'read-acl' and 
          e.xmldata.property.parent_schema = acl_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'read-acl' and 
          e.xmldata.property.parent_schema = acl_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83820000418000000000405222B0809181B23262728292A32343503150B0C0D072C'), acl_schema_ref,xdb.xdb$propnum_seq.nextval, 'write-config', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'write-config', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
     returning ref(e) into elem_ref_write_config;

    add_to_acl_schema(acl_schema_url,elem_ref_write_config);
  end if;
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure upgrades the acl schema
---------------------------------------------------------------------------------------
create or replace procedure upgrade_acl_schema as
  acl_schema_ref  REF XMLTYPE;
  acl_schema_url  VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 33;
  num_props       number;
begin
  acl_schema_url := 'http://xmlns.oracle.com/xdb/acl.xsd';

  select ref(s) into acl_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = acl_schema_url;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s 
    where ref(s) = acl_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then

   dbms_output.put_line('upgrading acl-schema'); 

   ats_write_config(acl_schema_ref, acl_schema_url);

   update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
   where ref(s) = acl_schema_ref;
  
   commit;
  end if; 

   dbms_output.put_line('acl-schema upgraded');
end;
/
show errors;


create or replace procedure add_to_dav_schema(
			      dav_schema_url IN VARCHAR2,
                              elem_ref       IN REF XMLTYPE) as

  ell_arr    XDB.XDB$XMLTYPE_REF_LIST_T;
  subs_arr    XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  select s.xmldata.elements into ell_arr
  from xdb.xdb$schema s
  where s.xmldata.schema_url = dav_schema_url;

  ell_arr.extend(1);
  ell_arr(ell_arr.last) := elem_ref;

  update xdb.xdb$schema s
  set s.xmldata.elements = ell_arr
  where s.xmldata.schema_url = dav_schema_url; 

  update xdb.xdb$schema s
  set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43313C8600050084000084030184040284050302091C206465636C61726520616C6C204441562070726976696C65676573200B0C11000584800E131416120A170D')
  where s.xmldata.schema_url = dav_schema_url; 

  select e.xmldata.subs_group_refs into subs_arr
  from xdb.xdb$element e
  where e.xmldata.property.name = 'privilegeName';

  subs_arr.extend(1);
  subs_arr(subs_arr.last) := elem_ref;

  update xdb.xdb$element e
  set e.xmldata.subs_group_refs = subs_arr
  where e.xmldata.property.name = 'privilegeName'; 

end;
/
show errors;

create or replace procedure add_write_prop(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_write_prop    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/write-properties')
    is null then

     dbms_output.put_line('upgrading write-prop'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'write-properties', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'write-properties', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_write_prop;

    add_to_dav_schema(dav_schema_url,elem_ref_write_prop);
  end if;
end;
/
show errors;

create or replace procedure add_write_con(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_write_con    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/write-content')
    is null then

     dbms_output.put_line('upgrading write-content'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'write-content', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'write-content', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_write_con;

    add_to_dav_schema(dav_schema_url,elem_ref_write_con);
  end if;
end;
/
show errors;


create or replace procedure add_bind(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_bind    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/bind')
    is null then

    dbms_output.put_line('upgrading bind'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
     (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'bind', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'bind', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_bind;

    add_to_dav_schema(dav_schema_url,elem_ref_bind);
  end if;
end;
/
show errors;


create or replace procedure add_unbind(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_unbind    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/unbind')
    is null then

     dbms_output.put_line('upgrading unbind'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'unbind', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'unbind', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL,NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_unbind;

    add_to_dav_schema(dav_schema_url,elem_ref_unbind);
  end if;
end;
/
show errors;


create or replace procedure add_read_current(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_read_current    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/read-current-user-privilege-set')
    is null then

    dbms_output.put_line('upgrading read-current'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'read-current-user-privilege-set', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'read-current-user-privile17', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_read_current;

    add_to_dav_schema(dav_schema_url,elem_ref_read_current);
  end if;
end;
/
show errors;

create or replace procedure add_take_ownership(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_take_ownership    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/take-ownership')
    is null then

    dbms_output.put_line('upgrading take-owner'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'take-ownership', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'take-ownership', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL,NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_take_ownership;

    add_to_dav_schema(dav_schema_url,elem_ref_take_ownership);
  end if;
end;
/
show errors;

create or replace procedure add_execute(
                              dav_schema_ref IN REF XMLTYPE, 
                              dav_schema_url IN VARCHAR2) as
 
  elem_ref_execute    REF XMLTYPE;
  type_ref                 REF XMLTYPE;
  head_elem_ref            REF XMLTYPE;
begin
 
  if find_element(dav_schema_url,
                  '/execute')
    is null then

     dbms_output.put_line('upgrading execute'); 

    select e.xmldata.property.type_ref into type_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    select e.xmldata.head_elem_ref into head_elem_ref
    from xdb.xdb$element e
    where e.xmldata.property.name = 'unlock' and 
          e.xmldata.property.parent_schema = dav_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
      (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462', '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364', '50000364617600044441563A'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83821000418000100000405222B0809181B23262728292A323435031538100B0C0D072C'), dav_schema_ref,xdb.xdb$propnum_seq.nextval, 'execute', XDB.XDB$QNAME('02', 'privilegeNameType'), NULL, '0102', '00', '00', NULL, 'execute', 'privilegeNameType1_T', 'XDB', NULL, NULL, NULL, type_ref, NULL, NULL, NULL, NULL, '01', NULL, NULL, NULL, '00', NULL, NULL, '00'), XDB.XDB$QNAME('02', 'privilegeName'), NULL, '00', NULL, NULL, '00', '00', '00', '00', '01', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, head_elem_ref, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into elem_ref_execute;

    add_to_dav_schema(dav_schema_url,elem_ref_execute);
  end if;
end;
/
show errors;


---------------------------------------------------------------------------------------
-- This procedure upgrades the dav schema
---------------------------------------------------------------------------------------
create or replace procedure upgrade_dav_schema as
  dav_schema_ref  REF XMLTYPE;
  dav_schema_url  VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 13;
  num_props       number;
begin
  dav_schema_url := 'http://xmlns.oracle.com/xdb/dav.xsd';

  select ref(s) into dav_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = dav_schema_url;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s 
    where ref(s) = dav_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then

   dbms_output.put_line('upgrading dav-schema'); 

   add_write_prop(dav_schema_ref, dav_schema_url);
   add_write_con(dav_schema_ref, dav_schema_url);
   add_bind(dav_schema_ref, dav_schema_url);
   add_unbind(dav_schema_ref, dav_schema_url);
   add_read_current(dav_schema_ref, dav_schema_url);
   add_take_ownership(dav_schema_ref, dav_schema_url);
   add_execute(dav_schema_ref, dav_schema_url);

   update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
      where ref(s) = dav_schema_ref;
  
   commit;
  end if;

  dbms_output.put_line('dav-schema upgraded'); 
end;
/
show errors;

-----------------------------------------------------------------------------
--- This procedure updates the XDB Standard schema for ---
-----------------------------------------------------------------------------

create or replace procedure upgrade_standard_schema as
  STANDARD_SCHEMA_URL      CONSTANT VARCHAR2(100) :=
                           'http://xmlns.oracle.com/xdb/XDBStandard.xsd';
  standard_schema_ref      REF XMLTYPE;
  link_type                varchar2(100);
  link_type_owner          varchar2(100);
  enum_ref                 REF XMLTYPE;
  elem_ref_linktype        REF XMLTYPE;
  link_seq_ref             REF XMLTYPE;
  elem_arr                 XDB.XDB$XMLTYPE_REF_LIST_T;
  PN_RES_TOTAL_PROPNUMS    CONSTANT INTEGER := 22;
  num_props                number;
  len_val                  number;
begin

  select ref(s) into standard_schema_ref from xdb.xdb$schema s
   where s.xmldata.schema_url = STANDARD_SCHEMA_URL;

  select s.xmldata.num_props into num_props from xdb.xdb$schema s 
    where ref(s) = standard_schema_ref;

  if(num_props != PN_RES_TOTAL_PROPNUMS) then

    dbms_output.put_line('upgrading standard schema'); 

  select c.xmldata.restriction.length.value into len_val
  from xdb.xdb$simple_type c 
  where ref(c) = (select e.xmldata.property.type_ref 
		  from xdb.xdb$element e, xdb.xdb$schema s 
                  where s.xmldata.schema_url = STANDARD_SCHEMA_URL 
		  and e.xmldata.property.parent_schema = ref(s) 
		  and e.xmldata.property.name = 'ChildName');

  if(len_val != 1024) then

     dbms_output.put_line('upgrading length value');

     update xdb.xdb$simple_type c 
     set c.xmldata.restriction.length.value = 1024  
     where ref(c) = (select e.xmldata.property.type_ref 
                     from xdb.xdb$element e, xdb.xdb$schema s 
                     where s.xmldata.schema_url = STANDARD_SCHEMA_URL 
                     and e.xmldata.property.parent_schema = ref(s) 
                     and e.xmldata.property.name = 'ChildName');
  end if;

  -- Upgrade LinkType element if necessary
  if find_element(STANDARD_SCHEMA_URL,'/LINK/LinkType')
    is null then

    dbms_output.put_line('upgrading LinkType'); 

    element_type(STANDARD_SCHEMA_URL, 'LINK', link_type_owner,
                 link_type);

    alt_type_add_attribute_own(link_type_owner, link_type,
                             '"LinkType" XDB.XDB$ENUM_T');

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values
    	(SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
	XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('2302000000010609'), standard_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8003'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Hard', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Weak', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Symbolic', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL, 0, NULL))	
	returning ref(s) into enum_ref;	

   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
	(SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
	XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A38200080030000000004010809181B23262A32343503150B0C0D07292728'), standard_schema_ref, xdb.xdb$propnum_seq.nextval, 'LinkType', NULL, NULL, '0103', '00', '00', NULL, 'LinkType', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
	returning ref(e) into elem_ref_linktype;

	
    -- select the sequence kid corresponding to the LINK type
  select c.xmldata.sequence_kid into link_seq_ref from
    xdb.xdb$complex_type c where ref(c)= 
      (select e.xmldata.cplx_type_decl from xdb.xdb$element e
        where e.xmldata.property.name='LINK' and
        e.xmldata.property.parent_schema = standard_schema_ref);

  -- select the sequence elements
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
  where ref(m) = link_seq_ref;
    
  -- extend it to add 1 element just created
  elem_arr.extend(1);
  elem_arr(elem_arr.last)   := elem_ref_linktype;
    
  -- update the table with the extended sequence and new pd
  update xdb.xdb$sequence_model m 
  set m.xmldata.elements = elem_arr,
      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800707')
  where ref(m) = link_seq_ref;

  end if; -- Upgrade LinkType

   update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
      where ref(s) = standard_schema_ref;
  end if;
  commit;
   dbms_output.put_line('XDB Standard schema upgraded'); 
end;
/
show errors;

---------------------------------------------------------------------------------------
-- Call the functions defined above.
---------------------------------------------------------------------------------------
-- We do not need to upgrade the config and acl schemas manually from 10.2
-- to 11.0 any more, as we invoke xdb$migrateXMLTable to do this for us
-- Upgrade config schema from the 10102 version
-- call upgrade_config_schema();

--Upgrade acl schema from the 10102 version
-- call upgrade_acl_schema();

--Upgrade dav schema from the 10102 version
-- call upgrade_dav_schema();

-- Upgrade resource schema from the 10102 version
call upgrade_resource_schema();

--grant execute to public on types created during resource schema upgrade
grant execute on xdb.xdb$oid_list_t to public with grant option;
grant execute on xdb.xdb$rclist_t to public with grant option; 

-- Upgrade XDB Standard schema from the 10102 version
call upgrade_standard_schema();

drop procedure upgrade_standard_schema;
drop procedure upgrade_config_schema;
drop procedure add_to_config_seq;
drop procedure ats_rollback_on_sync_error;
drop procedure ats_copy_on_inconsist_upd;
drop procedure ats_folder_hard_links;
drop procedure ats_non_folder_hard_links;
drop procedure ats_http_host;
drop procedure ats_http2_host;
drop procedure ats_create_types;
drop procedure ats_type_ipaddress;
drop procedure ats_type_mode;
drop procedure ats_type_path;
drop procedure ats_type_nfs_export_path;
drop procedure ats_type_nfs_export_paths;
drop procedure ats_type_nfs_client_types;
drop procedure ats_type_nfs_client;
drop procedure ats_type_nfs_clientgroup;
drop procedure ats_type_nfs_export;
drop procedure ats_type_nfs_exports_type;
drop procedure ats_type_nfs_exports_type2;
drop procedure ats_nfs_config2;
drop procedure ats_nfsconfig;
drop procedure ats_add_protoconfig;
drop procedure ats_default_workspace;
drop procedure ats_num_job;
drop procedure ats_acl_evaluation;
drop procedure upgrade_config_schema_rest;
drop procedure upgrade_resource_type;
drop procedure add_to_resource_element_seq;
drop procedure add_to_resource_attr_seq;
drop procedure add_to_resource_schema;
drop procedure upgrade_resource_schema;
drop procedure add_nfs_sequences;
drop function element_exists;
drop function attr_exists;
drop function attr_exists_num;

--Digest
drop procedure upgrade_config_schema_digest;

--ACL Schema
drop procedure upgrade_acl_schema;
drop procedure ats_write_config;
drop procedure add_to_acl_schema;

--DAV Schema
drop procedure upgrade_dav_schema;
drop procedure add_write_prop;
drop procedure add_write_con;
drop procedure add_bind;
drop procedure add_unbind;
drop procedure add_read_current;
drop procedure add_take_ownership;
drop procedure add_execute;

--schema for schemas
drop procedure upgrade_schema_for_schemas;
drop procedure add_simple_typeid;
drop procedure add_complex_typeid;
drop procedure add_sequence;
drop procedure create_types_schemas;
drop procedure update_derviationChoice;
drop procedure add_xdbmaxocc;
drop procedure add_translate;

drop procedure alter_type;
drop procedure alt_type_add_attribute_own;

-- drop utility functions
@@xdbuud.sql

Rem 060606 too mad to drop all the XML indexes and the XMLIndex type.
Rem The current XML Ix are useless because of the changes to the data format
Rem of the columns of the path table
DECLARE
  TYPE refcur_t IS REF CURSOR;
  cv   refcur_t;
  owner varchar2(32);
  name  varchar2(32);
  noexist_ex EXCEPTION;
  exist number;
  PRAGMA EXCEPTION_INIT(noexist_ex, -942);
BEGIN
  select count(*) into exist from DBA_VIEWS
    where view_name = 'DBA_XML_INDEXES';

 if exist != 0 then
  OPEN cv FOR
  'select index_owner, index_name from dba_xml_indexes';

  LOOP
    FETCH cv INTO owner,name;
    EXIT WHEN cv%NOTFOUND;

    BEGIN
      EXECUTE IMMEDIATE 
        'drop index ' || dbms_assert.enquote_name(owner, false) || '.' || 
        dbms_assert.enquote_name(name, false);
      EXCEPTION WHEN noexist_ex THEN NULL;
    END;
  END LOOP;
 end if;
END;
/

Rem indextype needs to be recreated
drop indextype XDB.XMLIndex force;
drop operator XDB.xmlindex_noop force;
drop package XDB.XMLIndex_FUNCIMPL;
drop type xdb.XMLIndexMethods force;

-- change xdb.xdb$h_link from IOT to regular heap table
select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "Starting H_LINK Upgrade" from dual;
drop table xdb.xdb$h_link_tmp;
create table xdb.xdb$h_link_tmp as select * from xdb.xdb$h_link;
select count(*) from xdb.xdb$h_link;
drop table xdb.xdb$h_link;
drop type xdb.xdb$link_t;

create type xdb.xdb$link_t OID '00000000000000000000000000020151' AS OBJECT
(
    parent_oid    raw(16),
    child_oid     raw(16),
    name          varchar2(256),
    flags         raw(4),
    link_sn       raw(16),
    child_acloid  raw(16),
    child_ownerid raw(16),
    parent_rids   raw(2000)
);
/

create table xdb.xdb$h_link of xdb.xdb$link_t
(
    constraint xdb_pk_h_link primary key (parent_oid, name)
)
as select parent_oid, child_oid, name, flags, link_sn, null, null, null
from xdb.xdb$h_link_tmp;
select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "created temp table" from dual;

drop type xdb.xdb$lockscope_t;
drop type xdb.xdb$reslock_t ;
drop type xdb.xdb$reslock_array_t;

-- create document links table
create table xdb.xdb$d_link 
(
  source_id    raw(16),
  target_id    raw(16),
  target_path  varchar2(4000),
  flags        raw(8)
);

create index xdb.xdb$d_link_source_id on xdb.xdb$d_link(source_id);

create index xdb.xdb$d_link_target_id on xdb.xdb$d_link(target_id);

-- xdb needs access to dbms_streams_control_adm.  This is needed
-- before the loading of prvtxdbz.plb.
grant execute on dbms_streams_control_adm to xdb;

Rem Note that this reload is necessary for the call to setLinkParents
Rem below. Either this SHOULD NOT be moved out of this file or it should be
Rem replaced by a minimal reload of prvtxdb and all its dependencies.
@@xdbptrl1.sql

-- clear h_link table ... left populated during reload 
select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "creating indexes on temp table" 
from dual;
drop table xdb.xdb$h_link;
-- pre-allocate space
create table xdb.xdb$h_link of xdb.xdb$link_t;

Rem Create child_oid index, parent_oid constraint
create index xdb.xdb_hltmp_child_oid on xdb.xdb$h_link_tmp(child_oid);
alter table xdb.xdb$h_link_tmp add (constraint xdb_pk_h_link_tmp primary key (parent_oid, name) enable novalidate);

-- Create child_oid index for parent rowid query
create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);

commit;

select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "SetLinkParents Starting" from dual;

Rem Set h_link parent rids. This needs to be done here before the data upgrade
Rem since repository operations (example: creation of /sys/apps in xdbu9202)
Rem might need these to be populated.
BEGIN
  xdb.dbms_xdbutil_int.setLinkParents();
END;
/

select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "SetLinkParents Done" from dual;
drop table xdb.xdb$h_link_tmp;

-- Drop indexes in case they are created in C
DROP INDEX XDB.XDB_H_LINK_CHILD_OID;
ALTER TABLE XDB.XDB$H_LINK DROP PRIMARY KEY CASCADE DROP INDEX;

-- add constraint to h_link table
ALTER TABLE xdb.xdb$h_link 
   ADD (CONSTRAINT xdb_pk_h_link PRIMARY KEY (parent_oid, name) ENABLE NOVALIDATE);
-- ReCreate child_oid index
create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);

select count(*) from xdb.xdb$h_link;
select index_name from dba_indexes where table_name like '%XDB$H_LINK%';
select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "Ended H_LINK Upgrade" from dual;

Rem Add protocol info & rclist columns to root_info table
alter table xdb.xdb$root_info add 
(rclist raw(2000),
 ftp_port number(5),
 ftp_protocol varchar2(4000),
 http_port number(5),
 http_protocol varchar2(4000),
 http_host varchar2(4000),
 http2_port number(5),
 http2_protocol varchar2(4000),
 http2_host varchar2(4000),
 nfs_port number(5),
 nfs_protocol varchar2(4000)
);

Rem Delete obsolete xmlindex operators
drop operator XDB.xmlindex_isattribute force;
drop operator XDB.xmlindex_getnodes force;

Rem Upgrade XDB$DXPTAB and XDB$DXPATH
drop index xdb.xdb$idxpath;
drop table XDB.XDB$DXPATH;

declare
  col_num     number;
  dxptab_obj# number;
  length      number;
begin
  
  SELECT OBJ# INTO dxptab_obj#
  FROM OBJ$ O, USER$ U
  WHERE O.NAME = 'XDB$DXPTAB'
    AND O.OWNER# = U.USER#
    AND U.NAME ='XDB';

  SELECT COLS INTO col_num
  FROM TAB$
  WHERE OBJ# = dxptab_obj#;

  if col_num = 7 then
    -- already been upgraded, check whether snapshot is of length 20
    SELECT LENGTH INTO length 
    FROM COL$
    WHERE OBJ# = dxptab_obj#
      AND name = 'SNAPSHOT';
    if length != 20 then
      EXECUTE IMMEDIATE
        'ALTER TABLE XDB.XDB$DXPTAB MODIFY (SNAPSHOT   RAW(20))';
    end if;
  else
    -- not been upgraded, add 3 more columns
    EXECUTE IMMEDIATE
      'ALTER TABLE XDB.XDB$DXPTAB ADD (
         PARAMETERS  XMLTYPE,
         PENDTABOBJ# NUMBER,                  
         SNAPSHOT    RAW(20))';
  end if;
end;
/

Rem  TODO - DROP all existing XML Indexes here

Rem DECLARE
Rem  CURSOR c1 IS
Rem    SELECT  INDEX_OWNER o, INDEX_NAME n FROM dba_xml_indexes;
Rem BEGIN
Rem  FOR r1 IN c1 LOOP
Rem    EXECUTE IMMEDIATE 
Rem      'DROP INDEX '|| dbms_assert.enquote_name(r1.o, false) ||'.'||
Rem      dbms_assert.enquote_name(r1.n, false);
Rem END LOOP;
Rem END;
Rem /


Rem Change Token Manager Tables to use VARCHAR2 columns
Rem catxdbtm.sql also changes the names of token tables

declare
  xdb11inst      number := 0;
  stmt11inst     varchar2(2000);
  localname_type varchar2(2000);
begin
  :tm_name := '@nothing.sql';
  stmt11inst := 'select count(*) from dba_tables ' ||
                'where (owner = ''XDB'') and (table_name = ''XDB$TTSET'')';
  execute immediate stmt11inst into  xdb11inst;
  if ( xdb11inst = 0 ) then
    select data_type into localname_type from dba_tab_columns 
    where TABLE_NAME = 'XDB$QNAME_ID' and column_name = 'LOCALNAME';

    if (localname_type = 'NVARCHAR2') then
     execute immediate 'drop table xdb.xdb$nmspc_id';
     execute immediate 'drop table xdb.xdb$qname_id';
     execute immediate 'drop table xdb.xdb$path_id';
     :tm_name  := '@catxdbtm.sql';
    end if;
    -- exception handler not needed here:
    -- an error here indicates token tables do not exist;
    -- the error should be exposed 
  end if;
end;
/

select :tm_name from dual;
@&tm_file;

-- When subsequent upgrades are written for 11g, add them here
-- @@xdbs110

@@xdb1m102.sql

--fix for lrg 2975452. This type should have ideally been dropped during downgrade to 10.1
--However this can not be done there at this point due to a bug in the object types layer.
--Cuasing this to drop in 10.1 downgrade leads to type version mismatch, which causes the re-upgrade to fail.
--It is safe to drop it here as this type no longer exists with the migration of the config schema to CSX, and we 
--can safely conclude that the type lying around is from the old 10.2 version and can be dropped as it is not being 
--used anymore nor are there any types dependent on this anymore.
CREATE OR REPLACE PROCEDURE DROP_TYPE(type_owner IN varchar2,
                                      type_name  IN varchar2) as
  sqlstr varchar2(1000);
BEGIN
  sqlstr := 'drop type ' || dbms_assert.enquote_name(type_owner, false) || '.' || 
            dbms_assert.enquote_name(type_name, false);
  dbms_output.put_line('sqlstr:' || sqlstr);
  EXECUTE IMMEDIATE sqlstr;
END;
/
show errors;

update xdb.migr9202status set n = 750;

declare
 c                 number;
 type_owner        varchar2(100);
 type_name         varchar2(100);
begin
  select count(*) into c from obj$ o,user$ u where o.name like 'plsql-servlet-config%' and o.owner# = u.user# and u.name = 'XDB' and o.type# != 10;

  if c > 0 then
    select u.name,o.name into type_owner,type_name from obj$ o,user$ u where o.name like 'plsql-servlet-config%' and o.owner# = u.user# and u.name = 'XDB' and o.type# != 10;
    drop_type(type_owner, type_name);
  end if;
end;
/

drop procedure drop_type;  


--create XDBResConfig schema (will be used in xdbs111.sql)
DECLARE
  c number;
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('rescfg.xsd.11.1');
  XMLNSURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';
BEGIN
  select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url ='http://xmlns.oracle.com/xdb/XDBResConfig.xsd';

  if c = 0 then
    dbms_output.put_line('creating xdbresconfig schema');
    xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, FALSE, FALSE, 
	   TRUE, FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);  

    execute immediate 'grant select, insert, update, delete on xdb.xdb$resconfig to public';

    -- Add refcount to xdb$resconfig table 
    execute immediate 'alter session set events=''12498 trace name context level 2, forever''';
    execute immediate 'alter table xdb.xdb$resconfig add (refcount number default 0)';
    execute immediate 'alter session set events=''12498 trace name context off''';

    -- The XDB_SET_INVOKER is needed to define an invoker-rights handler in
    -- a resource resconfig. 
    execute immediate 'create role XDB_SET_INVOKER';
    execute immediate 'grant XDB_SET_INVOKER to DBA';
  
  end if;

END;
/

-- set minoccurs for ACE in ACL to 0
update xdb.xdb$element e set e.xmldata.min_occurs=0 where 
  e.xmldata.property.parent_schema = (select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url='http://xmlns.oracle.com/xdb/acl.xsd')
  and e.xmldata.property.name is NULL and e.xmldata.property.propref_name.name like 'ace';
commit;


Rem Invoke Schema upgrade for next release
@@xdbs111.sql
