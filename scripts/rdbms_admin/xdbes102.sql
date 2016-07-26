Rem
Rem $Header: rdbms/admin/xdbes102.sql /main/23 2010/05/05 15:12:00 badeoti Exp $
Rem
Rem xdbes102.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbes102.sql - xdb schema downgrade to the 10.2 release
Rem
Rem    DESCRIPTION
Rem      xdb schema downgrade from the 11 release to 10.2 release
Rem
Rem    NOTES
Rem      xdb downgrade document
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/19/10 - Bug 9591348
Rem    spetride    09/15/09 - ace in acl: minoccurs back to 1 (from 0)
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    rburns      12/20/07 - move new actions to xdbeo102.sql
Rem    shvenugo    12/05/07 - fix downgrade for xmltable index
Rem    rburns      11/06/07 - add 11.1 downgrade
Rem    thbaby      02/19/07 - drop function stragg and its implementation type
Rem    spetride    01/30/07 - drop dbms_csx_int, dbms_csx_admin  
Rem    bpwang      11/02/06 - revoke execute to dbms_streams_control_adm
Rem    mrafiq      11/08/06 - grant all to xdbadmin on xdb$config
Rem    mrafiq      10/17/06 - fix drop of is_vpd_enabled, downgrade for
Rem                           dbmsxmls.sql 
Rem    thbaby      09/07/06 - drop table xdb$dxptab and its index xdb$idxptab
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    thbaby      07/10/06 - drop get_table_name and is_vpd_enabled 
Rem    mrafiq      06/19/06 - changes number of attributes when calling insert 
Rem                           element 
Rem    thbaby      06/13/06 - fix xmlindex downgrade issue
Rem    ataracha    06/11/06 - drop xdb$xidx_imp_t
Rem    attran      06/06/06 - Drop all XMLIndexes + ReCreate XMLIndexType
Rem    thbaby      06/07/06 - remove 'IsXMLIndexed' during downgrade
Rem    pnath       06/07/06  - drop type locktokenlisttype 
Rem    mrafiq      05/08/06  - adding downgrade for locks 
Rem    pnath       04/06/06 - drop package xdb.XDB_DLTRIG_PKG 
Rem    pnath       03/16/06 - HasUnresolvedLinks attribute 
Rem    mrafiq      03/06/06 - adding downgrade for compound docs 
Rem    abagrawa    03/16/06  - Use correct file name
Rem    mrafiq      03/16/06  - adding call to xdbem102.sql 
Rem    abagrawa    03/15/06  - Remove acl/config manual up/downgrade 
Rem    smalde      03/13/06 - Downgrade attrs 'translate' and 'xdb:maxOccurs' 
Rem    abagrawa    03/16/06 - Use correct file name
Rem    mrafiq      03/16/06 - adding call to xdbem102.sql 
Rem    abagrawa    03/15/06 - Remove acl/config manual up/downgrade 
Rem    vkapoor     06/30/05 - NFS downgrade
Rem    nkandalu    12/30/05 -  4751888: add substitution to derivationChoice 
Rem    rtjoa       11/21/05 - Dropping http and http2 host element 
Rem    mrafiq      10/08/05 - upgrade/downgrade project 
Rem    sidicula    06/29/05 - sidicula_le
Rem    fge         12/15/04 - Created

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 11.1.0
Rem ================================================================

@@xdbes111.sql

Rem ================================================================
Rem END XDB Schema downgrade to 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 10.2.0
Rem ================================================================

-- Load utilities. Call xdbuuc4 because element_t has two extra
-- translation attrs.
@@xdbuuc4.sql

-- This should be the first downgrade action thing which needs 
-- to be done in this script
@@xdbe1m102.sql

grant all on xdb.xdb$config to xdbadmin;

Rem 060606 too mad to drop all the XML indexes and the XMLIndex type.
Rem The current XML Ix are useless because of the changes to the data format
Rem of the columns of the path table
DECLARE
  TYPE refcur_t IS REF CURSOR;
  cv   refcur_t;
  owner varchar2(32);
  name  varchar2(32);
  noexist_ex EXCEPTION;
  PRAGMA EXCEPTION_INIT(noexist_ex, -942);
BEGIN
  OPEN cv FOR
  'select index_owner, index_name from dba_xml_indexes';

  LOOP
    FETCH cv INTO owner,name;
    EXIT WHEN cv%NOTFOUND;

    BEGIN
      EXECUTE IMMEDIATE 'drop index "' || owner || '"."' || name || '"';
      EXCEPTION WHEN noexist_ex THEN NULL;
    END;
  END LOOP;
END;
/

-- Unset inline trigger flag on hierarchically enabled tables for
-- content size.
declare
        cursor mycur is
        SELECT object_name, object_owner
        FROM   dba_policies v
        WHERE  (policy_name LIKE '%xdbrls%' OR policy_name LIKE '%$xd_%')
        AND    v.function = 'CHECKPRIVRLS_SELECTPF';
begin
        for myrec in mycur
        loop
                xdb.dbms_xdbz0.set_delta_calc_inline_trigflag (
                myrec.object_name, myrec.object_owner, FALSE, FALSE );
        end loop;
end;
/

-- The fix for 4931915, which went into 11g, modified setmodflg (defined in 
-- prvtxdbz.sql) and moved it from the xdb schema to the sys schema. Hence, 
-- drop procedure in sys schema during downgrade. 
drop procedure sys.setmodflg;

drop procedure sys.get_table_name;

drop function sys.is_vpd_enabled;

-- old lock types created
/*
* Later will inherit from xdb.xdb$enum
*/
create or replace type XDB.XDB$LOCKSCOPE_T 
OID '00000000000000000000000000020119' AS OBJECT
(
  VALUE           RAW(1)
);
/

/* ------------------------------------------------------------------- */
/*              RESOURCE-LOCK RELATED TYPES                            */
/* ------------------------------------------------------------------- */

create or replace type XDB.XDB$RESLOCK_T OID '0000000000000000000000000002011A'
 as object
(
  LOCKSCOPE       XDB.XDB$LOCKSCOPE_T,
  OWNER           VARCHAR2(30),
  EXPIRES         TIMESTAMP,
  LOCKTOKEN       RAW(2000)
);
/

create or replace type XDB.XDB$RESLOCK_ARRAY_T 
      OID '0000000000000000000000000002011B' as VARRAY(65535) of XDB.XDB$RESLOCK_T;
/

--this procedure drops a type and catches an exception if one occurs
create or replace procedure drop_type(attr_string IN varchar2) as
  attr_does_not_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(attr_does_not_exists,-22324);
begin
  execute immediate attr_string;
exception
  when attr_does_not_exists then
    NULL;
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


--this proedure drops and attr type and catches an exception if one occurs
CREATE OR REPLACE PROCEDURE ALT_TYPE_DROP_ATTRIBUTE_OWN(type_owner  IN varchar2,
                                                        type_name   IN varchar2,
                                                        attr_string IN varchar2) as
  sqlstr varchar2(1000);
  attr_does_not_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(attr_does_not_exists,-22324);
BEGIN
  sqlstr := 'ALTER TYPE ' || 
            dbms_assert.enquote_name(type_owner, false) || '.' || 
            dbms_assert.enquote_name(type_name, false) ||
            ' DROP ATTRIBUTE (' || attr_string || ') CASCADE';
  EXECUTE IMMEDIATE sqlstr;
EXCEPTION
   when attr_does_not_exists then
     dbms_output.put_line('XDBNB: no attr ' || dbms_assert.enquote_name(type_name, false));
END;
/
show errors;

-------------------------------------------------------------------------------
-- This procedure removes last element from config sequence.
-------------------------------------------------------------------------------
create or replace procedure remove_from_config_seq(
                              config_schema_ref IN REF XMLTYPE,
                              config_schema_url IN VARCHAR2,
                              config_name       IN varchar2,
                              name              IN varchar2,
                              pd                IN varchar2) as
  config_seq_ref         REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_ref          REF XMLTYPE;
  last_elem_name         varchar2(100);
  conf_type              varchar2(100);
  conf_type_owner        varchar2(100);
begin

  -- select the sequence kid corresponding to the config type
  select c.xmldata.sequence_kid into config_seq_ref from
    xdb.xdb$complex_type c where ref(c)= 
      (select e.xmldata.cplx_type_decl from xdb.xdb$element e
        where e.xmldata.property.name = config_name and
        e.xmldata.property.parent_schema = config_schema_ref);

  -- select the sequence elements
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = config_seq_ref;
    
  -- Look at the name of the last element
  last_elem_ref := elem_arr(elem_arr.last);
  select e.xmldata.property.name into last_elem_name from xdb.xdb$element e
    where ref(e) = last_elem_ref;

  -- If the name matches give-name then remove the element
  if last_elem_name = name then
    -- remove last element
    dbms_output.put_line('downgrading ' || name);
    delete_elem_by_ref(elem_arr(elem_arr.last), true);
    elem_arr.trim(1);

    -- update the table with the extended sequence and new pd
    update xdb.xdb$sequence_model m 
    set m.xmldata.elements = elem_arr,
        m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T(pd)
    where ref(m) = config_seq_ref;
    commit;
  end if;
    -- fetch the type and owner of the element
    element_type(config_schema_url, config_name, conf_type_owner,
                 conf_type);

    -- alter type drop attribute
    alt_type_drop_attribute_own(conf_type_owner, conf_type, '"'||name||'"');
 
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure downgrades the config schema
---------------------------------------------------------------------------------------
create or replace procedure downgrade_config_schema_rest as
  config_schema_ref  REF XMLTYPE;
  config_schema_url  VARCHAR2(100);
  simple_arr         XDB.XDB$XMLTYPE_REF_LIST_T;
  complex_arr        XDB.XDB$XMLTYPE_REF_LIST_T;
begin
  dbms_output.put_line('downgrading config schema rest');

  config_schema_url := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';

  select ref(s) into config_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = config_schema_url;

   remove_from_config_seq(config_schema_ref,config_schema_url,
                         'sysconfig','num_job_queue_processes',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

   remove_from_config_seq(config_schema_ref,config_schema_url,
                         'sysconfig','default-workspace',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

  remove_from_config_seq(config_schema_ref,config_schema_url,
                         'sysconfig','acl-evaluation-method',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');
  remove_from_config_seq(config_schema_ref, config_schema_url,
                         'sysconfig', 'rollback-on-sync-error',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

  remove_from_config_seq(config_schema_ref, config_schema_url,
                         'sysconfig', 'copy-on-inconsistent-update',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

  remove_from_config_seq(config_schema_ref,config_schema_url,
                         'sysconfig','non-folder-hard-links',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

  remove_from_config_seq(config_schema_ref,config_schema_url,
                         'sysconfig','folder-hard-links',
                         '23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801107');

  remove_from_config_seq(config_schema_ref, config_schema_url,
                         'protocolconfig', 'nfsconfig',
                         '230200030002001E207468657365206170706C7920746F20616C6C2070726F746F636F6C732002020E204654502073706563696669632002040F20485454502073706563696669632081800307');

  remove_from_config_seq(config_schema_ref, config_schema_url,
                         'httpconfig', 'http2-host', '230200000081801207');
 
  remove_from_config_seq(config_schema_ref, config_schema_url,
                         'httpconfig', 'http-host', '230200000081801207');


  select s.xmldata.simple_type into simple_arr
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = config_schema_url;

  if simple_arr.count() = 2 then

    simple_arr.trim(1);
  
    update xdb.xdb$schema s
    set s.xmldata.simple_type = simple_arr
    where s.xmldata.schema_url = config_schema_url;
    commit;
  end if;

  select s.xmldata.complex_types into complex_arr
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = config_schema_url;

  if complex_arr.count() = 12 then

    complex_arr.trim(1);
  
    update xdb.xdb$schema s
    set s.xmldata.complex_types = complex_arr
    where s.xmldata.schema_url = config_schema_url;

    commit;
  end if;

  update xdb.xdb$schema s
  set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B01131416120A170D')
  where s.xmldata.schema_url = config_schema_url;
  commit;

end;
/

show errors;

---------------------------------------------------------------------------------------
-- This procedure downgrades the config schema for digest
---------------------------------------------------------------------------------------
create or replace procedure downgrade_config_schema_digest as
  CONFIG_SCHEMA_URL      CONSTANT varchar2(100) :=
                           'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_schema_ref      ref xmltype;
  last_elem_ref          REF XMLTYPE;
  httpcf_seq_ref         REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;  
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  last_elem_name         varchar2(100);
begin

  select ref(s) into config_schema_ref from xdb.xdb$schema s where
    s.xmldata.schema_url = CONFIG_SCHEMA_URL;
  
  -- STEP 1 remove the last three elements of the sequence
  -- array kid if necessary

  -- For that, first look at the sequence in the httpconfig element
  select c.xmldata.sequence_kid into httpcf_seq_ref from 
    xdb.xdb$complex_type c where ref(c)=
      (select e.xmldata.cplx_type_decl from xdb.xdb$element e
        where e.xmldata.property.name='httpconfig' and
        e.xmldata.property.parent_schema = config_schema_ref);

  -- Get the list of all elements in this sequence
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
  where ref(m) = httpcf_seq_ref;

  -- Look at the name of the last element
  last_elem_ref := elem_arr(elem_arr.last);
  select e.xmldata.property.name into last_elem_name from xdb.xdb$element e
    where ref(e) = last_elem_ref;

  -- If the name matches 'authentication' the elements have to be removed
  if last_elem_name = 'authentication' then
    dbms_output.put_line('downgrading authentication');
    delete_elem_by_ref(elem_arr(elem_arr.last), true);
    elem_arr.trim(1);
    update xdb.xdb$sequence_model m set
           m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = xdb.XDB$RAW_LIST_T('230200000081801007') 
      where ref(m) = httpcf_seq_ref;
    commit;
  end if;
     -- STEP 2 DROP the extra attributes of the httpconfig object type
     -- fetch the type and owner of the element
  element_type(config_schema_url, 'httpconfig', httpconf_type_owner,
                  httpconf_type);

     -- alter type drop attribute
  alt_type_drop_attribute_own(httpconf_type_owner, httpconf_type,
                          '"authentication"');
 
end;
/
show errors;

create or replace procedure downgrade_config_schema as
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 139;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
begin  

-- get the Resource schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
  s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

    dbms_output.put_line('downgrading config schema');

    downgrade_config_schema_digest();
    downgrade_config_schema_rest();

    update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;
    commit;
  END IF;

  dbms_output.put_line('config schema downgraded');
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure downgrades the resource type.
---------------------------------------------------------------------------------------
create or replace procedure downgrade_resource_type as
  res_type               varchar2(100);
  res_type_owner         varchar2(100);
  schema_url             varchar2(100);
  ellist                 XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_ref               REF XMLTYPE;

begin

  schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
  element_type(schema_url, 'Resource', res_type_owner, res_type);

  dbms_output.put_line('downgrading resource types');

  alt_type_drop_attribute_own(res_type_owner, res_type, 'CHECKEDOUTBYID');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'BASEVERSION');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'RCLIST');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'SIZEONDISK');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'SNAPSHOT');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'ATTRCOPY');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'CTSCOPY');
  alt_type_drop_attribute_own(res_type_owner, res_type, 'NODENUM');

   select s.xmldata.elements into ellist
   from xdb.xdb$schema s
   where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
 
   elem_ref := ellist(1);
 
   update xdb.xdb$element e
   set e.xmldata.num_cols = 25
   where ref(e) = elem_ref;
 
   commit;

end;
/
show errors;
--------------------------------------------------------------------------------
-- This procedure removes attributes from xdb.xdb$attribute
--------------------------------------------------------------------------------
create or replace procedure delete_attr_by_ref (attrref ref xmltype) as
 BEGIN

  delete from xdb.xdb$attribute e where ref(e) = attrref;
 END;
/

show errors;

CREATE OR REPLACE PROCEDURE DELETE_ANY_BY_REF(anyref ref xmltype) as
BEGIN
  delete from xdb.xdb$any e where ref(e) = anyref;
END;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure is especially written to remove elem AttrCopy
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DELETE_ELEM_BY_REF_OWN (eltref ref xmltype,
                                                delete_cascade boolean
                                                  default false) as
  type_name  VARCHAR2(30);
  type_ref   REF XMLTYPE;
  seq_ref    REF XMLTYPE;
  any_arr   XDB.XDB$XMLTYPE_REF_LIST_T;
BEGIN

  delete from xdb.xdb$element e where ref(e) = eltref
    returning e.xmldata.property.sqltype, e.xmldata.property.type_ref
         into type_name, type_ref;

  IF delete_cascade THEN

    IF type_ref IS NOT NULL THEN
      IF type_name = 'XDB$ENUM_T' THEN
        delete from xdb.xdb$simple_type s where ref(s) = type_ref;
      ELSE
        delete from xdb.xdb$complex_type c where ref(c) = type_ref
          returning c.xmldata.sequence_kid into seq_ref;

        IF seq_ref IS NOT NULL THEN
          delete from xdb.xdb$sequence_model m where ref(m) = seq_ref
            returning m.xmldata.anys into any_arr;
          FOR i IN 1..any_arr.last LOOP
            delete_any_by_ref(any_arr(i));
          END LOOP;
        END IF;
      END IF;
    END IF;
  END IF;

END;
/
show errors;

--------------------------------------------------------------------------------
-- This procedure removes elements from resource schema
--------------------------------------------------------------------------------
create or replace procedure remove_from_resource_schema(
                              schema_ref IN REF XMLTYPE) as
  seq_ref               REF XMLTYPE;
  last_elem_ref         REF XMLTYPE;
  last_attr_ref         REF XMLTYPE;
  complex_type          REF XMLTYPE;
  top_elem_ref          REF XMLTYPE;
  simple_ref            REF XMLTYPE;
  lock_scope_type_ref   REF XMLTYPE;
  lock_scope_ref        REF XMLTYPE;
  locktype_ref          REF XMLTYPE;
  owner_ref             REF XMLTYPE;
  expires_ref           REF XMLTYPE;
  locktoken_ref         REF XMLTYPE;
  ellist                xdb.xdb$xmltype_ref_list_t;
  attrlist              xdb.xdb$xmltype_ref_list_t;
  complex_arr           xdb.xdb$xmltype_ref_list_t;
  schema_ellist         xdb.xdb$xmltype_ref_list_t;
  simple_list           xdb.xdb$xmltype_ref_list_t;
  last_elem_name        varchar2(100);
  last_attr_name        varchar2(100);
  simple_name           varchar2(100);
  schema_url            varchar2(100);
begin

  schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  -- 1) first downgrade top level elements
  select s.xmldata.elements into schema_ellist
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  top_elem_ref := schema_ellist(schema_ellist.last);
  select e.xmldata.property.name into last_elem_name
  from xdb.xdb$element e
  where ref(e) = top_elem_ref;

  if last_elem_name = 'Locks' then
   dbms_output.put_line('downgrading top level element');
   delete_elem_by_ref(top_elem_ref, true);
   schema_ellist.trim(1);

   update xdb.xdb$schema s 
   set s.xmldata.elements = schema_ellist
   where s.xmldata.schema_url = schema_url;
  end if;


   -- 3) downgrade simple types

  select s.xmldata.simple_type into simple_list
  from xdb.xdb$schema s
  where s.xmldata.schema_url = schema_url;

  simple_ref := simple_list(simple_list.last);
  select s.xmldata.name into simple_name
  from xdb.xdb$simple_type s
  where ref(s) = simple_ref;

  if simple_name = 'lockDepthType' then
    dbms_output.put_line('downgrading resource schema  simple types'); 
    delete from xdb.xdb$simple_type s where ref(s) = simple_ref;

    simple_ref := simple_list(simple_list.last-1);
    delete from xdb.xdb$simple_type s where ref(s) = simple_ref;

    simple_ref := simple_list(simple_list.last-2);    
    delete from xdb.xdb$simple_type s where ref(s) = simple_ref;

    simple_list.trim(2);

    --insert back the old LockScopeType simple type
   insert into xdb.xdb$simple_type s (s.xmldata) values
   (XDB.XDB$SIMPLE_T(NULL, schema_ref, 'LockScopeType', NULL, XDB.XDB$SIMPLE_DERIVATION_T(NULL,NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(NULL, NULL, 'Exclusive', '00', NULL), XDB.XDB$FACET_T(NULL, NULL, 'Shared', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(s) into lock_scope_type_ref;

    simple_list(simple_list.last) := lock_scope_type_ref;

    update xdb.xdb$schema s
    set s.xmldata.simple_type = simple_list
    where s.xmldata.schema_url = schema_url;
  end if;

  -- 2) downgrade complex types

  -- 2a) downgrade Resource Type elements
  -- For that, first look at the sequence in the ResourceType element
  select c.xmldata.sequence_kid into seq_ref
  from xdb.xdb$complex_type c 
  where c.xmldata.name='ResourceType' and c.xmldata.parent_schema=schema_ref;

  -- Get the list of all elements in this sequence
  select m.xmldata.elements into ellist 
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  -- Look at the name of the last element
  last_elem_ref := ellist(ellist.last);
  select e.xmldata.property.name into last_elem_name
  from xdb.xdb$element e
  where ref(e) = last_elem_ref;

  -- If the name matches 'Locks' the element has to be removed
  if last_elem_name = 'Locks' then
    dbms_output.put_line('downgrading resource schema elements');
    delete_elem_by_ref(ellist(ellist.last));
    delete_elem_by_ref(ellist(ellist.last - 1));
    delete_elem_by_ref(ellist(ellist.last - 2));
    delete_elem_by_ref(ellist(ellist.last - 3));
    delete_elem_by_ref(ellist(ellist.last - 4));
    delete_elem_by_ref(ellist(ellist.last - 5),true);
    delete_elem_by_ref(ellist(ellist.last - 6));
    delete_elem_by_ref(ellist(ellist.last - 7));
    delete_elem_by_ref(ellist(ellist.last - 8));
    delete_elem_by_ref(ellist(ellist.last - 9));
    --should also set cascade to true but need to change func to also 
    --remove from any lists (this is for AttrCopy) 
    delete_elem_by_ref_own(ellist(ellist.last - 10),true);
    delete_elem_by_ref(ellist(ellist.last - 11));
    ellist.trim(12);

    update xdb.xdb$sequence_model m 
    set m.xmldata.elements = ellist
    where ref(m) = seq_ref;
    commit;

   -- 2b) downgrade other complex types
   
   select s.xmldata.complex_types into complex_arr
   from xdb.xdb$schema s
   where s.xmldata.schema_url = schema_url;

   -- save the ResourceType element 
   complex_type := complex_arr(complex_arr.last);

   --remove AttrCopy and RCList complex types and set 
   -- ResourceType as last element
   complex_arr.trim(2);
   complex_arr(complex_arr.last) := complex_type;

   -- Remove lockType and locksType complex from position 1 and 2
   complex_arr(2) := complex_arr(3);
   complex_arr(3) := complex_arr(4);
   complex_arr(4) := complex_arr(5);
   complex_arr.trim(1);

   -- set complex_arr(1) to old lock complex type
      
   attrlist := xdb.xdb$xmltype_ref_list_t();
   attrlist.extend(1);

   insert into xdb.xdb$attribute e (e.xmldata) values
  (XDB.XDB$PROPERTY_T(NULL, schema_ref, 701, 'LockScope', XDB.XDB$QNAME('01', 'LockScopeType'), '01', '0103', '00', '00', NULL, 'LOCKSCOPE', 'XDB$LOCKSCOPE_T', 'XDB', XDB.XDB$JAVATYPE('0F'), NULL, NULL, lock_scope_type_ref, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL))
  returning ref(e) into lock_scope_ref;

  attrlist(1) := lock_scope_ref;

  ellist := xdb.xdb$xmltype_ref_list_t();
  ellist.extend(3);    

  insert into xdb.xdb$element e (e.xmldata) values
   (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 702, 'owner', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'OWNER', 'VARCHAR2', NULL, XDB.XDB$JAVATYPE('00'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into owner_ref;

  insert into xdb.xdb$element e (e.xmldata) values
   (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 703, 'expires', XDB.XDB$QNAME('00', 'dateTime'), NULL, 'B4', '00', '00', NULL, 'EXPIRES', 'TIMESTAMP', NULL, XDB.XDB$JAVATYPE('0C'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL,NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '01', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into expires_ref;
  
  insert into xdb.xdb$element e (e.xmldata) values
   (XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(NULL, schema_ref, 704, 'lockToken', XDB.XDB$QNAME('00', 'hexBinary'), NULL, '17', '00', '00', NULL, 'LOCKTOKEN', 'RAW', NULL, XDB.XDB$JAVATYPE('09'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL), NULL, 1, '00', NULL, NULL, '00', '00', '01', '00', '00', NULL, 'XDB', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
  returning ref(e) into locktoken_ref;

  ellist(1) := owner_ref;
  ellist(2) := expires_ref;
  ellist(3) := locktoken_ref;

  insert into xdb.xdb$sequence_model m (m.xmldata) values
    (XDB.XDB$MODEL_T(NULL, schema_ref, 1, '1', ellist, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(m) into seq_ref;

  insert into xdb.xdb$complex_type e (e.xmldata) values
   (XDB.XDB$COMPLEX_T(NULL, schema_ref, NULL, 'LockType', '00', '00', NULL, NULL, attrlist, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
   returning ref(e) into locktype_ref;

  complex_arr(1) := locktype_ref;

   update xdb.xdb$schema s
   set s.xmldata.complex_types = complex_arr
   where s.xmldata.schema_url = schema_url;

  end if;

  --Rename element LockBuf to Lock
   if element_exists(schema_url,'LockBuf') then
   
     dbms_output.put_line('renaming LockBuf element');
     update xdb.xdb$element e
     set e.xmldata.property.name = 'Lock'
     where e.xmldata.property.prop_number = 718 and 
     e.xmldata.property.name = 'LockBuf';
   end if;

  -- 2c) downgrade ResourceType attributes
  select c.xmldata.attributes into attrlist
  from xdb.xdb$complex_type c 
  where c.xmldata.name = 'ResourceType' and
        c.xmldata.parent_schema = schema_ref;

  last_attr_ref := attrlist(attrlist.last);
  select e.xmldata.name into last_attr_name
  from xdb.xdb$attribute e
  where ref(e) = last_attr_ref;

  if last_attr_name = 'IsXMLIndexed' then  
    dbms_output.put_line('downgrading resource schema attributes');
    delete_attr_by_ref(attrlist(attrlist.last));
    delete_attr_by_ref(attrlist(attrlist.last-1));
    delete_attr_by_ref(attrlist(attrlist.last-2));
    delete_attr_by_ref(attrlist(attrlist.last-3));
    delete_attr_by_ref(attrlist(attrlist.last-4));
    delete_attr_by_ref(attrlist(attrlist.last-5));
    delete_attr_by_ref(attrlist(attrlist.last-6));
    delete_attr_by_ref(attrlist(attrlist.last-7));
    delete_attr_by_ref(attrlist(attrlist.last-8));
    attrlist.trim(9);

    update xdb.xdb$complex_type c
    set c.xmldata.attributes = attrlist
    where c.xmldata.name = 'ResourceType' and
          c.xmldata.parent_schema = schema_ref;
    commit;
  end if;


end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure drops a sequence. If the sequence does not exist, it ignores the 
-- error
---------------------------------------------------------------------------------------
create or replace procedure drop_sequence(seq_name IN varchar2) as
  seq_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(seq_does_not_exist, -02289);
begin  
  execute immediate 'drop sequence ' || seq_name ;
exception
  when seq_does_not_exist then
    NULL;
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure removes the stateid and clientid seq
---------------------------------------------------------------------------------------
create or replace procedure remove_nfs_sequences as
begin
    dbms_output.put_line('downgrading nfs sequences'); 
    drop_sequence('xdb.stateid_restart_sequence');
    drop_sequence('xdb.clientid_sequence');
end;
/
show errors;


---------------------------------------------------------------------------------------
-- This procedure downgrades the resource schema.
---------------------------------------------------------------------------------------
create or replace procedure downgrade_resource_schema as
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 45;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
begin  

-- get the Resource schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
  s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

    dbms_output.put_line('downgrading resource schema');

    downgrade_resource_type();
    remove_from_resource_schema(sch_ref);
    remove_nfs_sequences();

    update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;
    commit;
  END IF;

  dbms_output.put_line('resource schema downgraded');
end;
/
show errors;

create or replace procedure downgrade_subgroup_elem as
begin

  dbms_output.put_line('downgrading subs group elems');

  update xdb.xdb$element e
  set e.xmldata.subs_group_refs = cast(multiset(
                                select ref(e2) from xdb.xdb$element e2
                                where e2.xmldata.head_elem_ref = ref(e))
                                   as xdb.xdb$xmltype_ref_list_t)
  where e.xmldata.property.name = 'privilegeName' and 
        e.xmldata.property.parent_schema = (select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd');

end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure downgrades the acl schema
---------------------------------------------------------------------------------------
create or replace procedure downgrade_acl_schema as
  acl_schema_ref  REF XMLTYPE;
  acl_schema_url  VARCHAR2(100);
  ell_arr         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_ref   REF XMLTYPE;
  last_elem_name  VARCHAR2(100);
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 32;
  numprops                number;
begin
  
  acl_schema_url := 'http://xmlns.oracle.com/xdb/acl.xsd';

  select ref(s) into acl_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = acl_schema_url;

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = acl_schema_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

  dbms_output.put_line('downgrading acl schema');

  select s.xmldata.elements into ell_arr
  from xdb.xdb$schema s
  where s.xmldata.schema_url = acl_schema_url;

  last_elem_ref := ell_arr(ell_arr.last);
  select e.xmldata.property.name into last_elem_name
  from xdb.xdb$element e
  where ref(e) = last_elem_ref;

  if last_elem_name = 'write-config' then
    dbms_output.put_line('downgrading write-config');
    delete_elem_by_ref(ell_arr(ell_arr.last));
    ell_arr.trim(1);

    update xdb.xdb$schema s
    set s.xmldata.elements = ell_arr
    where s.xmldata.schema_url = acl_schema_url;

    update xdb.xdb$schema s
    set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43153C860009008400008403018404020207322070726976696C6567654E616D655479706520287468697320697320616E20656D707479636F6E74656E74207479706529200209762070726976696C6567654E616D6520656C656D656E740A20202020202020416C6C2073797374656D20616E6420757365722070726976696C656765732061726520696E2074686520737562737469747574696F6E47726F75700A202020202020206F66207468697320656C656D656E742E0A20202020020B3020616C6C2073797374656D2070726976696C6567657320696E20746865205844422041434C206E616D657370616365200218132070726976696C65676520656C656D656E7420021A0D2061636520656C656D656E7420021C0D2061636C20656C656D656E74200B0C110002848010131416120A170D')
    where s.xmldata.schema_url = acl_schema_url;
  end if;

   update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = acl_schema_ref;
    commit;
  END IF;

  dbms_output.put_line('acl schema downgraded');
end;
/
show errors;


---------------------------------------------------------------------------------------
-- This procedure downgrades the dav schema
---------------------------------------------------------------------------------------
create or replace procedure downgrade_dav_schema as
  dav_schema_ref  REF XMLTYPE;
  dav_schema_url  VARCHAR2(100);
  ell_arr         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_ref   REF XMLTYPE;
  last_elem_name  VARCHAR2(100);
  elem_ref_lock   REF XMLTYPE;
  type_ref        REF XMLTYPE;
  head_elem_ref   REF XMLTYPE;
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 7;
  numprops                number;
begin
  dav_schema_url := 'http://xmlns.oracle.com/xdb/dav.xsd';

  select ref(s) into dav_schema_ref from xdb.xdb$schema s where
         s.xmldata.schema_url = dav_schema_url;

  -- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = dav_schema_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

   dbms_output.put_line('downgrading dav schema');

   select s.xmldata.elements into ell_arr
   from xdb.xdb$schema s
   where s.xmldata.schema_url = dav_schema_url;

   last_elem_ref := ell_arr(ell_arr.last);
   select e.xmldata.property.name into last_elem_name
   from xdb.xdb$element e
   where ref(e) = last_elem_ref;

   if last_elem_name = 'execute' then
    dbms_output.put_line('downgrading dav elements');
    delete_elem_by_ref(ell_arr(ell_arr.last));
    delete_elem_by_ref(ell_arr(ell_arr.last - 1));
    delete_elem_by_ref(ell_arr(ell_arr.last - 2));
    delete_elem_by_ref(ell_arr(ell_arr.last - 3));
    delete_elem_by_ref(ell_arr(ell_arr.last - 4));
    delete_elem_by_ref(ell_arr(ell_arr.last - 5));
    delete_elem_by_ref(ell_arr(ell_arr.last - 6));
    ell_arr.trim(7);

    update xdb.xdb$schema s
    set s.xmldata.elements = ell_arr
    where s.xmldata.schema_url = dav_schema_url;
    
    update xdb.xdb$schema s
    set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43313C8600050084000084030184040284050302091C206465636C61726520616C6C204441562070726976696C65676573200B0C110005848007131416120A170D')
    where s.xmldata.schema_url = dav_schema_url;

   end if;

   update xdb.xdb$schema s
   set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
   where ref(s) = dav_schema_ref;

   downgrade_subgroup_elem();
   commit;
  END IF;

  dbms_output.put_line('dav schema downgraded');

  
end;
/
show errors;


create or replace procedure downgrade_simple_type(
	                    sch_ref IN REF XMLTYPE) as
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_att_ref    REF XMLTYPE;
  last_att_name  varchar2(100);
begin
  dbms_output.put_line('downgrading simple types');
  drop_type('alter type xdb.xdb$simple_t drop attribute (typeid) cascade');
 
  drop_type('alter type xdb.xdb$simple_t drop attribute (sqltype) cascade');

  select c.xmldata.attributes into attlist
  from xdb.xdb$complex_type c
  where c.xmldata.name = 'simpleType' and
        c.xmldata.parent_schema = sch_ref;

  last_att_ref := attlist(attlist.last);
  select e.xmldata.name into last_att_name
  from xdb.xdb$attribute e
  where ref(e) = last_att_ref;

  if last_att_name = 'SQLType' then
    dbms_output.put_line('downgrading simple type attrs');
    delete_attr_by_ref(attlist(attlist.last));
    delete_attr_by_ref(attlist(attlist.last - 1));
    attlist.trim(2);

    update xdb.xdb$complex_type c
    set c.xmldata.attributes = attlist
    where c.xmldata.name = 'simpleType' and
          c.xmldata.parent_schema = sch_ref;
 
    commit;
  end if;
 
end;
/
show errors;

create or replace procedure downgrade_complex_type(
	                    sch_ref IN REF XMLTYPE) as
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_att_ref    REF XMLTYPE;
  last_att_name  varchar2(100);
begin
  dbms_output.put_line('downgrading complex type');
  drop_type('alter type xdb.xdb$complex_t drop attribute (typeid) cascade');

  select c.xmldata.attributes into attlist
  from xdb.xdb$complex_type c
  where c.xmldata.name = 'complexType' and
        c.xmldata.parent_schema = sch_ref;

  last_att_ref := attlist(attlist.last);
  select e.xmldata.name into last_att_name
  from xdb.xdb$attribute e
  where ref(e) = last_att_ref;

  if last_att_name = 'typeID' then
    dbms_output.put_line('downgrading complex type attrs');
    delete_attr_by_ref(attlist(attlist.last));
    attlist.trim(1);

    update xdb.xdb$complex_type c
    set c.xmldata.attributes = attlist
    where c.xmldata.name = 'complexType' and
          c.xmldata.parent_schema = sch_ref;
 
    commit;
  end if;
 
end;
/
show errors;

create or replace procedure downgrade_translate(
	                    sch_ref IN REF XMLTYPE) as
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_att_ref    REF XMLTYPE;
  last_att_name  varchar2(100);
begin
  dbms_output.put_line('downgrading xdb:translate');
  drop_type('alter type xdb.xdb$element_t drop attribute (is_translatable) cascade');

  select c.xmldata.complexcontent.extension.attributes into attlist
  from xdb.xdb$complex_type c
  where c.xmldata.name = 'element' and
        c.xmldata.parent_schema = sch_ref;

  last_att_ref := attlist(attlist.last);
  select e.xmldata.name into last_att_name
  from xdb.xdb$attribute e
  where ref(e) = last_att_ref;

  if last_att_name = 'translate' then
    dbms_output.put_line('downgrading translate attr');
    delete_attr_by_ref(attlist(attlist.last));
    attlist.trim(1);

    update xdb.xdb$complex_type c
    set c.xmldata.complexcontent.extension.attributes = attlist
    where c.xmldata.name = 'element' and
          c.xmldata.parent_schema = sch_ref;
 
    commit;
  end if;
 
end;
/
show errors;

create or replace procedure downgrade_xdbmaxoccurs(
	                    sch_ref IN REF XMLTYPE) as
  attlist         XDB.XDB$XMLTYPE_REF_LIST_T;
  last_att_ref    REF XMLTYPE;
  last_att_name  varchar2(100);
begin
  dbms_output.put_line('downgrading xdbmaxoccurs');
  drop_type('alter type xdb.xdb$element_t drop attribute (xdb_max_occurs) cascade');

  select c.xmldata.complexcontent.extension.attributes into attlist
  from xdb.xdb$complex_type c
  where c.xmldata.name = 'element' and
        c.xmldata.parent_schema = sch_ref;

  last_att_ref := attlist(attlist.last);
  select e.xmldata.name into last_att_name
  from xdb.xdb$attribute e
  where ref(e) = last_att_ref;

  if last_att_name = 'maxOccurs' then
    dbms_output.put_line('downgrading xdbmaxoccurs attr');
    delete_attr_by_ref(attlist(attlist.last));
    attlist.trim(1);

    update xdb.xdb$complex_type c
    set c.xmldata.complexcontent.extension.attributes = attlist
    where c.xmldata.name = 'element' and
          c.xmldata.parent_schema = sch_ref;
 
    commit;
  end if;
 
end;
/
show errors;

---------------------------------------------------------------------------------------
-- This procedure removes the typeid seq
---------------------------------------------------------------------------------------
create or replace procedure downgrade_typeid_seq as
begin
    dbms_output.put_line('downgrading schema_for_schema sequences'); 
    drop_sequence('xdb.xdb$typeid_seq');
end;
/
show errors;

-- Bug 4751888: remove "substitution" and "union" from derivationChoice"
create or replace procedure downgrade_derivationChoice as
  schref         REF XMLTYPE;
  xdb_schema_url CONSTANT VARCHAR2(100) :=
                  'http://xmlns.oracle.com/xdb/XDBSchema.xsd';
  enumeration     xdb.xdb$enum_values_t;
  facet_list      xdb.xdb$facet_list_t := xdb.xdb$facet_list_t();
  FALSE           CONSTANT RAW(1) := '0';

begin

  select ref(s) into schref from xdb.xdb$schema s where
         s.xmldata.schema_url = xdb_schema_url;

  enumeration := xdb.xdb$enum_values_t('','extension', 'restriction', 'list',
                                       '#all');

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
show errors;

create or replace procedure downgrade_schema_for_schemas as
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 271;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
begin  

-- get the schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
  s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

    dbms_output.put_line('downgrading schema_for_schemas');

    downgrade_xdbmaxoccurs(sch_ref);
    downgrade_translate(sch_ref);
    downgrade_simple_type(sch_ref);
    downgrade_complex_type(sch_ref);
    downgrade_typeid_seq();
    downgrade_derivationChoice();

    update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;
    commit;
  END IF;

  execute immediate 'alter system flush shared_pool';

  dbms_output.put_line('schema for schemas downgraded');
end;
/
show errors;

create or replace procedure downgrade_standard_schema as
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 21;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
  schema_url              varchar2(1000);
  len_val                 number;
begin  

  schema_url := 'http://xmlns.oracle.com/xdb/XDBStandard.xsd';
-- get the schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
  s.xmldata.schema_url = schema_url;

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

    dbms_output.put_line('downgrading standard schema');

    select c.xmldata.restriction.length.value into len_val
    from xdb.xdb$simple_type c 
    where ref(c) = (select e.xmldata.property.type_ref 
		    from xdb.xdb$element e, xdb.xdb$schema s 
                    where s.xmldata.schema_url = schema_url
		    and e.xmldata.property.parent_schema = ref(s) 
		    and e.xmldata.property.name = 'ChildName');

    if(len_val != 256) then

       dbms_output.put_line('downgrading length value');

       update xdb.xdb$simple_type c 
       set c.xmldata.restriction.length.value = 256  
       where ref(c) = (select e.xmldata.property.type_ref 
                       from xdb.xdb$element e, xdb.xdb$schema s 
                       where s.xmldata.schema_url = schema_url 
                       and e.xmldata.property.parent_schema = ref(s) 
                       and e.xmldata.property.name = 'ChildName');
    end if;

    remove_from_config_seq(sch_ref, schema_url,'LINK','LinkType',
                         '230200000081800607');

    update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;
    commit;
  END IF;

  dbms_output.put_line('standard schema downgraded');
end;
/
show errors;

---------------------------------------------------------------------------------------
-- Call the functions defined above.
---------------------------------------------------------------------------------------
-- We do not need to downgrade the acl and config schemas manually to 10.2
-- since we invoke xdb$migrateXMLTable to do this for us

-- Downgrade config schema to 10102 version
-- call downgrade_config_schema();

-- Downgrade resource schema to 10102 version
call downgrade_resource_schema();

--Downgarde acl schema to 10102 version
-- call downgrade_acl_schema();

--Downgarde dav schema to 10102 version
-- call downgrade_dav_schema();

--Downgarde standard schema to 10102 version
call downgrade_standard_schema();

--Downgarde schema for schemas to 10102 version
call downgrade_schema_for_schemas();

-- set minoccurs for ace in ACL schema back to 1 (from 0)
update xdb.xdb$element e set e.xmldata.min_occurs=1 where 
  e.xmldata.property.parent_schema = (select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url='http://xmlns.oracle.com/xdb/acl.xsd')
  and e.xmldata.property.name is NULL and e.xmldata.property.propref_name.name like 'ace';
commit;

drop procedure downgrade_standard_schema;
drop procedure downgrade_config_schema;
drop procedure downgrade_config_schema_rest;
drop procedure downgrade_resource_type;
drop procedure downgrade_resource_schema;
drop procedure remove_nfs_sequences;
drop procedure drop_sequence;
drop procedure remove_from_resource_schema;
drop procedure remove_from_config_seq;
drop procedure downgrade_config_schema_digest;
drop procedure delete_attr_by_ref;
drop procedure downgrade_acl_schema;
drop procedure delete_any_by_ref;
drop procedure delete_elem_by_ref_own;
drop procedure downgrade_dav_schema;
drop procedure downgrade_subgroup_elem;
drop procedure downgrade_schema_for_schemas;
drop procedure downgrade_simple_type;
drop procedure downgrade_complex_type;
drop procedure downgrade_typeid_seq;
drop procedure downgrade_derivationChoice;
drop procedure drop_type;
drop procedure alt_type_drop_attribute_own;
drop procedure downgrade_xdbmaxoccurs;
drop procedure downgrade_translate;
drop function element_exists;

-- this needs to be done after we downgrade the XDB Standard Schema
create or replace view xdb.path_view as
  select /*+ ORDERED */ t2.path path, t.res res,
      xmltype.createxml(xdb.xdb_link_type(NULL, r2.xmldata.dispname, t.name,
                        h.name, h.flags, h.parent_oid, h.child_oid),
			'http://xmlns.oracle.com/xdb/XDBStandard.xsd', 'LINK')         link,t.resid
  from  ( select xdb.all_path(9999) paths, value(p) res, p.sys_nc_oid$ resid,
          p.xmldata.dispname name
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

-- drop utility functions
@@xdbuud.sql

Rem ================================================================
Rem END XDB Schema downgrade to 10.2.0
Rem ================================================================

