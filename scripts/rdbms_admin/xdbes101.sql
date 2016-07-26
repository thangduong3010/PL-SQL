Rem
Rem $Header: rdbms/admin/xdbes101.sql /main/19 2010/05/05 15:12:00 badeoti Exp $
Rem
Rem xdbes101.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbes101.sql - downgrade script for 10.2 to 10.1
Rem
Rem    DESCRIPTION
Rem      callable downgrade script that moves the dictionary from 10.2 
Rem      10.1
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/19/10 - Bug 9591348
Rem    rburns      11/06/07 - add 11.1 downgrade
Rem    mrafiq      10/22/05 - loading and droping utility functions
Rem    vkapoor     06/14/05 - Bug 4429533 
Rem    petam       04/12/05 - LRG 1844414 
Rem    vkapoor     04/05/05 - LRG 1842450 
Rem    petam       03/21/05 - add downgrade for anonymous access 
Rem    vkapoor     03/14/05 - LRG 1836363 
Rem    vkapoor     01/10/05 - LRG 1804464 
Rem    fge         12/15/04 - call 10.2 downgrade script 
Rem    rpang       12/02/04 - add downgrade for embedded PL/SQL gateway
Rem    smukkama    09/24/04 - drop token tables
Rem    attran      11/03/04 - bug3986741
Rem    spannala    10/11/04 - remove select packages so that they get reloaded 
Rem    spannala    09/24/04 - remove exception blocks from upgrade and 
Rem                           downgrade scripts 
Rem    attran      09/20/04 - lrgum5-lrgum6
Rem    attran      09/07/04 - xmlidx
Rem    spannala    09/02/04 - spannala_lrg-1734670
Rem    spannala    08/23/04 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 10.2.0
Rem ================================================================

@@xdbes102.sql

Rem ================================================================
Rem END XDB Schema downgrade to 10.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 10.1.0
Rem ================================================================

-- Get utility functions
@@xdbuuc.sql

create or replace procedure downgrade_config_schema as
  CONFIG_SCHEMA_URL      CONSTANT varchar2(100) :=
                           'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_schema_ref      ref xmltype;
  last_elem_ref          REF XMLTYPE;
  httpcf_seq_ref         REF XMLTYPE;
  servlet                REF XMLTYPE;
  plsql                  REF XMLTYPE;
  plsql_model            REF XMLTYPE;  -- choice_model that 'plsql' is in
  model_type             varchar2(100);
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_arr2              XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_name         varchar2(100);
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  servlet_type           varchar2(100);
  servlet_type_owner     varchar2(100);
  araa_type              varchar2(100);
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

  -- If the name matches 'allow-repository-anonymous-access' the 
  -- elements have to be removed
  if last_elem_name = 'allow-repository-anonymous-access' then

    select e.xmldata.property.sqlname into araa_type 
      from xdb.xdb$element e 
      where e.xmldata.property.name = 'allow-repository-anonymous-access';

    delete_elem_by_ref(elem_arr(elem_arr.last), true);
    delete_elem_by_ref(elem_arr(elem_arr.last-1), true);
    delete_elem_by_ref(elem_arr(elem_arr.last-2), true);
    delete_elem_by_ref(elem_arr(elem_arr.last-3), true);
    elem_arr.trim(4);

    update xdb.xdb$sequence_model m set
           m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = xdb.XDB$RAW_LIST_T('230200000081800D07') 
      where ref(m) = httpcf_seq_ref;

    -- STEP 2 DROP the extra attributes of the httpconfig object type
    -- fetch the type and owner of the element
    element_type(config_schema_url, 'httpconfig', httpconf_type_owner,
                 httpconf_type);

    -- alter type drop attribute
    alt_type_drop_attribute(httpconf_type_owner, httpconf_type,
       '"http2-port", "http2-protocol", "plsql", "' || araa_type || '"');

    commit;
  end if;

  -- Drop 'plsql' element under 'servlet'
  servlet := find_element(CONFIG_SCHEMA_URL,
                          '/xdbconfig/sysconfig/protocolconfig/httpconfig/'||
                          'webappconfig/servletconfig/servlet-list/servlet');
  plsql := find_child_with_model(servlet, 'plsql', plsql_model, model_type);
  if plsql is not null then

    -- delete 'plsql-servlet-config' type
    select s.xmldata.complex_types into elem_arr2
      from xdb.xdb$schema s where ref(s) = config_schema_ref;
    elem_arr2.trim(1);
    update xdb.xdb$schema s
       set s.xmldata.complex_types = elem_arr2,
           s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800A01131416120A170D')
     where ref(s) = config_schema_ref;

    -- Make sure that 'plsql' element is a choice
    if model_type <> 'xdb$choice_model' then
      raise program_error;
    end if;

    -- Get the list of all elements in this sequence
    select m.xmldata.elements into elem_arr
      from xdb.xdb$choice_model m where ref(m) = plsql_model;

    -- Make sure that 'plsql' is the last element in the choice list
    if elem_arr(elem_arr.last) <> plsql then
      raise program_error;
    end if;

    delete_elem_by_ref(elem_arr(elem_arr.last), true);
    elem_arr.trim(1);
    update xdb.xdb$choice_model m set
           m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = xdb.xdb$raw_list_t('230200000081800207') 
      where ref(m) = plsql_model;
    commit;

    -- fetch the type and owner of the element
    element_type(CONFIG_SCHEMA_URL, 'servlet',
                 servlet_type_owner, servlet_type);

    -- alter type drop attribute
    alt_type_drop_attribute(servlet_type_owner, servlet_type, '"plsql"');

  end if;

end;
/
show errors;

create or replace procedure downgrade_resource_schema as
  res_schema_url varchar2(100);
  res_schema_ref ref xmltype;
  last_elem_ref          REF XMLTYPE;
  res_seq_ref            REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_name         varchar2(100);
  res_type               varchar2(100);
  res_type_owner         varchar2(100);
  PN_RES_TOTAL_PROPNUMS  CONSTANT INTEGER := 44;
begin
  res_schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
  select ref(s) into res_schema_ref from xdb.xdb$schema s where
    s.xmldata.schema_url = res_schema_url;
  
  -- STEP 1 Remove the last element, SBResExtra

  -- For that, first look at the sequence in the ResourceType element
  select c.xmldata.sequence_kid into res_seq_ref from 
    xdb.xdb$complex_type c where c.xmldata.name='ResourceType'
    and c.xmldata.parent_schema=res_schema_ref;
  
  -- Get the list of all elements in this sequence
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
    where ref(m) = res_seq_ref;

  -- Look at the name of the last element
  last_elem_ref := elem_arr(elem_arr.last);
  select e.xmldata.property.name into last_elem_name from xdb.xdb$element e
    where ref(e) = last_elem_ref;

  -- If the name matches 'SBResExtra' the element has to be removed
  if last_elem_name = 'SBResExtra' then
    delete_elem_by_ref(elem_arr(elem_arr.last));
    elem_arr.trim(1);
    update xdb.xdb$sequence_model m set
           m.xmldata.elements = elem_arr
      where ref(m) = res_seq_ref;

  -- Reduce the total number of props by 1
     update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
     where ref(s) = res_schema_ref;

    commit;
  end if;

  -- STEP 2 DROP the extra attributes of the resource object type
  -- fetch the type and owner of the element
  element_type(res_schema_url, 'Resource', res_type_owner,
               res_type);

  -- alter type drop attribute
  alt_type_drop_attribute(res_type_owner, res_type, '"SBRESEXTRA"');

  update xdb.xdb$schema e
  set e.xmlextra = NULL
  where
    e.object_id = '6C3FCF2D9D354DC1E03408002087A0B7' or
    e.object_id = '8758D485E6004793E034080020B242C6';
  commit;
end;
/
show errors;

CALL downgrade_config_schema();
CALL downgrade_resource_schema();

-- For debugging
select n from xdb.migr9202status;

-- remove the procedures
drop procedure downgrade_config_schema;
drop procedure downgrade_resource_schema;
drop function sys.check_upgrade;
drop function sys.isXMLTypeTable;
drop function sys.USER_XML_PARTITIONED_TABLE_OK;

-- drop utility functions
@@xdbuud.sql

Rem ================================================================
Rem END XDB Schema downgrade to 10.1.0
Rem ================================================================
