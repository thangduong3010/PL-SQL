Rem
Rem $Header: rdbms/admin/xdbes111.sql /st_rdbms_11.2.0/1 2011/07/31 10:32:40 juding Exp $
Rem
Rem xdbes111.sql
Rem
Rem Copyright (c) 2007, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbes111.sql - XDB Schema Downgrade
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB schemas to 11.1
Rem
Rem    NOTES
Rem      It is invoked from the top-level XDB downgrade script (xdbe111.sql)
Rem      and from the 10.2 schema downgrade script (xdbes102.sql)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vhosur      03/04/10 - Downgrade changes for Conatiner mutable
Rem    spetride    07/30/09 - downgrade config for localApplicationGroupStore
Rem    samane      05/28/09 - drop xdb.XDB_PITRIG_PKG_01 (security fixes)
Rem    spetride    05/08/09 - downgrade XMLIndexMethods
Rem    spetride    02/16/09 - downgrade for Expire headers in xdbconfig
Rem    badeoti     03/02/09 - downgrade respond-with-server-info in httpcfg
Rem    atabar      02/03/09 - xdbconfig downgrade: default-type-mappings
Rem    spetride    02/02/09 - downgrade for realm under httpconfig
Rem    spetride    06/11/08 - downgrade XDBCONFIG schema 11.2 to 11.1
Rem    spetride    06/11/08 - downgrade ACL schema 11.2 to 11.1
Rem    badeoti     05/07/08 - manual downgrade of xdbrescfg schema,
Rem                           rescfg SGA cache unable to build with copyEvolve
Rem    attran      04/15/08 - De-support partitioning of XMLIndex
Rem    bhammers    03/19/08 - add downgrade for XML Index
Rem    yifeng      01/29/08 - lrg 3272185: delete the old resconfig schema from
Rem                           xdb$schema after copyevolve
Rem    yifeng      12/10/07 - downgrade xdbrescfg schema
Rem    rburns      11/06/07 - add XDB schema 11.1 downgrade
Rem    rburns      11/06/07 - Created
Rem
Rem ================================================================
Rem BEGIN XDB Schema downgrade to 11.2.0
Rem ================================================================

-- uncomment for next release
--@@xdbes121.sql

@@xdbes112.sql

Rem ================================================================
Rem END XDB Schema downgrade to 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 11.1.0
Rem ================================================================

Rem Load upgrade utilities functions
@@xdbuuc4.sql


Rem Drop xlink-config/pre-condition property from XDB resource config schema

declare 
  seq_ref            REF XMLTYPE;
  elem_arr           XDB.XDB$XMLTYPE_REF_LIST_T;
  attr_arr           XDB.XDB$XMLTYPE_REF_LIST_T;
  config_schema_url  VARCHAR2(100);
  config_schema_ref  REF XMLTYPE;
  numb               number(38) := 0;
  elem_propno        number(38);
  last_elem_name     varchar2(100);
  anypart            varchar2(4000);
  appinf             XDB.XDB$APPINFO_LIST_T;
  currAppinf         XDB.XDB$APPINFO_T;
begin
  config_schema_url := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';
  
  select ref(s) into config_schema_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = config_schema_url;
 
  select c.xmldata.sequence_kid into seq_ref 
  from xdb.xdb$complex_type c 
  where c.xmldata.name = 'xlink-config'
    and c.xmldata.parent_schema = config_schema_ref;

  -- Get a list of all elements in this sequence
  select m.xmldata.elements into elem_arr 
  from xdb.xdb$sequence_model m
  where ref(m) = seq_ref;

  -- determine position of pre-condition element
  numb := elem_arr.last;
  while numb <> 0 loop
    select e.xmldata.property.name into last_elem_name from xdb.xdb$element e
    where ref(e) = elem_arr(numb);

    if last_elem_name = 'pre-condition' then 
        dbms_output.put_line('downgrading rescfg:xlink-config');
        
        -- save prop number
        select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
        where ref(e) = elem_arr(numb);

        delete_elem_by_ref(elem_arr(numb));
        EXIT;
    end if;
    numb := numb - 1; 
  end loop;

  -- only update if pre-condition element was found
  if numb > 0  then
    
     -- splice off pre-condition element 
     while numb < elem_arr.last loop
        elem_arr(numb) := elem_arr(numb + 1);
        numb := numb + 1;
     end loop;
     elem_arr.trim(1);

     -- update child element sequence for the xlink-config complex type
     update xdb.xdb$sequence_model m 
     set m.xmldata.elements = elem_arr,
         m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800307')
     where ref(m) = seq_ref;
   
     -- edit annotation kidlist, we assume only 1 kidlist in 11.1.0.6, might change in 11.1.0.7+
     -- construct kidlist from element and attribute lists
     anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
     for i in 1..elem_arr.last loop
       select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
       where ref(e) = elem_arr(i);
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
     end loop;
   
     select c.xmldata.attributes into attr_arr
     from xdb.xdb$complex_type c
     where c.xmldata.name = 'xlink-config'
     and c.xmldata.parent_schema = config_schema_ref;

     for i in 1..attr_arr.last loop
       select e.xmldata.prop_number into elem_propno from xdb.xdb$attribute e
       where ref(e) = attr_arr(i);
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (elem_arr.last + i-1) || '"/>';
     end loop;

     anypart := anypart || chr(10) || '</xdb:kidList>';
 
     update xdb.xdb$complex_type c
     set c.xmldata.annotation.appinfo =  XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
     where c.xmldata.parent_schema = config_schema_ref 
     and c.xmldata.name = 'xlink-config';

     -- no need to alter type since this is not an object type
  end if;

  commit;
end;
/


-- downgrade to 11.1 ACL schema: remove 'ApplicationName' principal format
declare
  schema_url    VARCHAR2(700) :=  'http://xmlns.oracle.com/xdb/acl.xsd';
  refs          REF SYS.XMLTYPE;
  aceattrs      XDB.XDB$XMLTYPE_REF_LIST_T;
  i             NUMBER;
  nm            VARCHAR2(256);
  aceattr       REF SYS.XMLTYPE;
begin
  select ref(s) into refs from xdb.xdb$schema s where s.xmldata.schema_url = schema_url;

  -- find the list of attributes for the ace's complex type
  select c.xmldata.attributes into aceattrs from xdb.xdb$complex_type c,  xdb.xdb$element e, xdb.xdb$schema s
  where ref(s) = refs and e.xmldata.property.parent_schema = refs and
        e.xmldata.property.name ='ace' and e.xmldata.cplx_type_decl = ref(c);

  for i in 1..aceattrs.last loop
     select a.xmldata.name into nm from xdb.xdb$attribute a where ref(a)=aceattrs(i);
     if (nm = 'principalFormat') then
        -- update the simple type for principalFormat
        update xdb.xdb$simple_type s
        set s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020000000106'),
            s.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8004'), NULL, 
                                                                XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, 
                                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                                                                XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                                                                                                    NULL, 'ShortName', '00', NULL), 
                                                                                      XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                                                                                                      NULL, 'DistinguishedName', '00', NULL), 
                                                                                      XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                                                                                                      NULL, 'GUID', '00', NULL), 
                                                                                      XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), 
                                                                                                      NULL, 'XSName', '00', NULL)), 
                                                                NULL, NULL)
        where ref(s) = (select a.xmldata.smpl_type_decl from xdb.xdb$attribute a where ref(a)=aceattrs(i));

        exit;

     end if;
  end loop;

  commit;
end;
/  

-------------------------------------------------------------
-- start downgrading xdbconfig for localApplicationGroupStore
-------------------------------------------------------------
create or replace procedure downgradeConfigGroupStore as 
  isfound         BOOLEAN;
  confsch_ref     REF SYS.XMLTYPE;
  simpletype_ref  REF SYS.XMLTYPE;
  elem_ref        REF SYS.XMLTYPE;
  cplx_ref        REF SYS.XMLTYPE;
  seq_ref         REF SYS.XMLTYPE;
  seq_elems       XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_propnum    NUMBER(38);
  propnum         NUMBER(38); 
  NUM_PROPS CONSTANT INTEGER := 203; --prop_num after downgrade
  confsch_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  anypart         VARCHAR2(4000);
  i               NUMBER(38); 
  numprops        NUMBER(38);

begin
    
  -- ref for xdbconfig schema
  select ref(s) into confsch_ref from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url;

  -- num_props
  select s.xmldata.num_props into numprops from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url; 

  -- already downgraded?
  if (numprops <= NUM_PROPS) then
     dbms_output.put_line('xdbconfig schema already downgraded');
     return;
  end if;

  -- ref and prop num for the default-type-mappings element
  select ref(e), 
         e.xmldata.property.prop_number 
  into elem_ref, elem_propnum
  from xdb.xdb$element e
  where e.xmldata.property.name='localApplicationGroupStore' and 
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the sysconfig element and its type
  select e.xmldata.cplx_type_decl into cplx_ref  
  from xdb.xdb$element e
  where e.xmldata.property.name='sysconfig' and
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the sequence kid in the complex type for sysconfig
  select c.xmldata.sequence_kid into seq_ref from xdb.xdb$complex_type c
  where ref(c) = cplx_ref;

  -- elements in the sequence 
  select m.xmldata.elements into seq_elems from xdb.xdb$sequence_model m 
  where ref(m)= seq_ref;

  -- update annotation for the complex type declaration for sysconfig 
  --  (remove reference to default-type-mappings)
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..seq_elems.last loop
     select e.xmldata.property.prop_number into propnum 
     from xdb.xdb$element e
     where ref(e) = seq_elems(i);
     if (not (isfound)) then
       if (propnum != elem_propnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-2) || '"/>';
       seq_elems(i-1) := seq_elems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';

  seq_elems.trim(1);

  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo = XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)) 
  where c.xmldata.parent_schema = confsch_ref and ref(c) = cplx_ref;

   -- update elements and PD for seq kid of sysconfig 
  update xdb.xdb$sequence_model m set m.xmldata.elements = seq_elems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801B0')
  where ref(m)= seq_ref;

  -- update num_props for schema
  update xdb.xdb$schema s set s.xmldata.num_props = NUM_PROPS
  where s.xmldata.schema_url = confsch_url;  

  -- remove the default-type-mappings element
  delete from xdb.xdb$element e where ref(e) = elem_ref;

  commit; 

end;
/

show errors;
exec downgradeConfigGroupStore;

-- clean up
drop procedure downgradeConfigGroupStore;

--------------------------------------------------
-- end downgrading xdbconfig localApplicationGroupStore
--------------------------------------------------


----------------------------------------------------
-- start downgrading xdbconfig for Expire Headers
----------------------------------------------------
create or replace procedure downgradeConfigForExpire as 
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  idem                 NUMBER := 0;
  numprops             NUMBER(38);
  CONFIG_PRPONUMS_NOEXP  CONSTANT INTEGER := 199;
  exppatnum            NUMBER(38);
  exppatelem           REF SYS.XMLTYPE;
  expdeftype           REF SYS.XMLTYPE;
  expdefnum            NUMBER(38);
  expdefelem           REF SYS.XMLTYPE;
  skidexpmap           XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidmap           REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
  i                    NUMBER;
  expmaptype           REF SYS.XMLTYPE;
  expmapnum            NUMBER(38);
  expmapelem           REF SYS.XMLTYPE;
  skidexp              XDB.XDB$XMLTYPE_REF_LIST_T;
  refskidexp           REF SYS.XMLTYPE;
  exptype              REF SYS.XMLTYPE;
  expnum               NUMBER(38);
  expelem              REF SYS.XMLTYPE;
  refhttptype          REF SYS.XMLTYPE;
  refskidhttp          REF SYS.XMLTYPE;
  skidhttpelems        XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_propno          NUMBER(38);
  clistinsch           XDB.XDB$XMLTYPE_REF_LIST_T;
  isfound              BOOLEAN := FALSE;
  typenm               VARCHAR2(256);
begin
  select ref(s) into refs from xdb.xdb$schema s
     where s.xmldata.schema_url = schema_url;

  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
     where s.xmldata.schema_url = schema_url;

  -- if at least one of the expire elements or types do not exist,
  -- then this is a rerun, so return
  select count(*) into idem from xdb.xdb$complex_type c
     where c.xmldata.name='expire-type' and c.xmldata.parent_schema=refs;
  if (idem < 1) then
     dbms_output.put_line('xdbconfig schema already downgraded for expire headers');
     return;
  end if;  

  -- get a ref to the expire-pattern element
  select ref(e) into exppatelem from  xdb.xdb$element e 
    where e.xmldata.property.name='expire-pattern' and e.xmldata.property.parent_schema=refs;
  dbms_output.put_line('1. got ref to expire-pattern');

  -- get refs to the expire-default element and its simple type
  select ref(e), e.xmldata.property.smpl_type_decl into expdefelem, expdeftype
    from xdb.xdb$element e
    where e.xmldata.property.name='expire-default' and e.xmldata.property.parent_schema=refs;
  dbms_output.put_line('2. got refs for expire-default and its type');

  -- get refs to expire-mapping element, its type and the sequence kid 
  select ref(e), e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
    into expmapelem, expmaptype, refskidmap
    from xdb.xdb$element e, xdb.xdb$complex_type c
    where e.xmldata.property.name='expire-mapping' and e.xmldata.property.parent_schema=refs
          and e.xmldata.cplx_type_decl = ref(c);
  dbms_output.put_line('3. got refs to expire-mapping, its type and sequence kid');

  -- get refs to expire element, expire-type and its sequence kid, and propnum for expire
  select ref(e), e.xmldata.property.prop_number  into expelem, expnum 
    from xdb.xdb$element e
    where e.xmldata.property.name='expire' and e.xmldata.property.parent_schema=refs;

  select ref(c), c.xmldata.sequence_kid into exptype, refskidexp
    from xdb.xdb$complex_type c 
    where c.xmldata.name='expire-type' and c.xmldata.parent_schema = refs;
  dbms_output.put_line('4. gor refs to expire element, its type and sequence-kid');

  -- update elements and PD for seq kid of httpconfig, update annotation
  select e.xmldata.cplx_type_decl into refhttptype from xdb.xdb$element e
    where e.xmldata.property.name ='httpconfig' and  e.xmldata.property.parent_schema = refs;

  select c.xmldata.sequence_kid into refskidhttp from xdb.xdb$complex_type c
                  where ref(c) = refhttptype;

  select m.xmldata.elements into skidhttpelems from xdb.xdb$sequence_model m where ref(m)= refskidhttp;

  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidhttpelems.last loop
     select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
     where ref(e) = skidhttpelems(i);
     if (not (isfound)) then
       if (elem_propno != expnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidhttpelems(i-1) := skidhttpelems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidhttpelems.trim(1);

  update xdb.xdb$complex_type c
  set c.xmldata.annotation = XDB.XDB$ANNOTATION_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                                                  XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), 
                                                                                                      anypart, NULL)
                                                                        ),
                                                  NULL)
  where c.xmldata.parent_schema = refs and ref(c)=refhttptype;    
  dbms_output.put_line('5. updated annotation for httpconfig type');

  update xdb.xdb$sequence_model m set m.xmldata.elements = skidhttpelems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801607')
  where ref(m)= refskidhttp;  
  dbms_output.put_line('6. updated sequence kid and pd for httpconfig'); 
  commit;

  -- remove expire-type from complex_types list in schema
  select s.xmldata.complex_types into clistinsch from xdb.xdb$schema s where s.xmldata.schema_url = schema_url;
  isfound := FALSE;
  for i in 1..clistinsch.last loop
     select c.xmldata.name into typenm from xdb.xdb$complex_type c where ref(c) = clistinsch(i);
     if (not (isfound)) then
        if (typenm = 'expire-type') then
           isfound := TRUE;
        end if;
     else
       -- shift left
       clistinsch(i-1) :=  clistinsch(i);
     end if;
  end loop;  
  clistinsch.trim(1);  
  dbms_output.put_line('7. removed expire-type from schema type list');

  -- update PD and num props for schema
   update xdb.xdb$schema s set s.xmldata.complex_types = clistinsch, 
                              s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B818002828003131416120A170D'),
                              s.xmldata.num_props = CONFIG_PRPONUMS_NOEXP
  where s.xmldata.schema_url = schema_url;   
  dbms_output.put_line('8. updated pd$ and num props fro schema');
  commit;

  -- now to the cleanup
  delete from xdb.xdb$element e where ref(e)=expelem;
  delete from xdb.xdb$complex_type c where ref(c)=exptype;
  delete from xdb.xdb$sequence_model m where ref(m)=refskidexp;
  dbms_output.put_line('9. cleanup for expire element');

  delete from xdb.xdb$element e where ref(e)=expmapelem;
  delete from xdb.xdb$complex_type c where ref(c)=expmaptype;
  delete from xdb.xdb$sequence_model m where ref(m)=refskidmap;
  dbms_output.put_line('10. cleanup for expire-mapping element');  

  delete from xdb.xdb$element e where ref(e)=expdefelem;
  delete from xdb.xdb$simple_type st where ref(st)=expdeftype;
  dbms_output.put_line('11. cleanup for expire-default element');

  delete from xdb.xdb$element e where ref(e)=exppatelem;
  dbms_output.put_line('12. cleanup for expire-pattern element');

  commit;
end;
/


show errors;

exec downgradeConfigForExpire;
-- clean-up
drop procedure downgradeConfigForExpire;


----------------------------------------------------
-- start downgrading xdbconfig default-type-mappings
----------------------------------------------------
-- removing element /sysconfig/default-type-mappings
-- Note: Downgrading more sysconfig elements should come after this 
--       procedure. 
--       Please be careful about num_props and PD changes after 
--       this procedure execution. 
create or replace procedure downgradeConfigDTM as 
  isfound         BOOLEAN;
  confsch_ref     REF SYS.XMLTYPE;
  simpletype_ref  REF SYS.XMLTYPE;
  elem_ref        REF SYS.XMLTYPE;
  cplx_ref        REF SYS.XMLTYPE;
  seq_ref         REF SYS.XMLTYPE;
  seq_elems       XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_propnum    NUMBER(38);
  propnum         NUMBER(38); 
  NUM_PROPS CONSTANT INTEGER := 198; --prop_num after downgrade
  confsch_url     VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  anypart         VARCHAR2(4000);
  i               NUMBER(38); 
  numprops        NUMBER(38);

begin
    
  -- ref for xdbconfig schema
  select ref(s) into confsch_ref from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url;

  -- num_props
  select s.xmldata.num_props into numprops from xdb.xdb$schema s
  where s.xmldata.schema_url = confsch_url; 

  -- already downgraded?
  if (numprops <= NUM_PROPS) then
     dbms_output.put_line('xdbconfig schema already downgraded');
     return;
  end if;

  -- ref and prop num for the default-type-mappings element
  select ref(e), 
         e.xmldata.property.prop_number, 
         e.xmldata.property.smpl_type_decl 
  into elem_ref, elem_propnum, simpletype_ref
  from xdb.xdb$element e
  where e.xmldata.property.name='default-type-mappings' and 
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the sysconfig element and its type
  select e.xmldata.cplx_type_decl into cplx_ref  
  from xdb.xdb$element e
  where e.xmldata.property.name='sysconfig' and
        e.xmldata.property.parent_schema = confsch_ref;

  -- ref to the sequence kid in the complex type for sysconfig
  select c.xmldata.sequence_kid into seq_ref from xdb.xdb$complex_type c
  where ref(c) = cplx_ref;

  -- elements in the sequence 
  select m.xmldata.elements into seq_elems from xdb.xdb$sequence_model m 
  where ref(m)= seq_ref;

  -- update annotation for the complex type declaration for sysconfig 
  --  (remove reference to default-type-mappings)
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..seq_elems.last loop
     select e.xmldata.property.prop_number into propnum 
     from xdb.xdb$element e
     where ref(e) = seq_elems(i);
     if (not (isfound)) then
       if (propnum != elem_propnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || propnum || '" kidNum="' || (i-2) || '"/>';
       seq_elems(i-1) := seq_elems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';

  seq_elems.trim(1);

  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo = XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL)) 
  where c.xmldata.parent_schema = confsch_ref and ref(c) = cplx_ref;

   -- update elements and PD for seq kid of sysconfig 
  update xdb.xdb$sequence_model m set m.xmldata.elements = seq_elems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801A07')
  where ref(m)= seq_ref;

  -- update num_props for schema
  update xdb.xdb$schema s set s.xmldata.num_props = NUM_PROPS
  where s.xmldata.schema_url = confsch_url;  

  -- remove the default-type-mappings element
  delete from xdb.xdb$element e where ref(e) = elem_ref;

  -- remove annonymous simple type
  delete from xdb.xdb$simple_type st where ref(st) = simpletype_ref;

  commit; 

end;
/

show errors;
exec downgradeConfigDTM;

-- clean up
drop procedure downgradeConfigDTM;

--------------------------------------------------
-- end downgrading xdbconfig default-type-mappings
--------------------------------------------------


-- downgrade to 11.1 CONFIG schema
-- this is the downgrade for custom authentication and trust,
-- as well as the 'realm' element under httpconfig
create or replace procedure downgradeConfig as 
  schema_url           VARCHAR2(700) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  refs                 REF SYS.XMLTYPE;
  idem                 NUMBER := 0;
  CONFIG_PRPONUMS_DOWN CONSTANT INTEGER := 171;
  numprops             NUMBER(38);
  refauthpat           REF SYS.XMLTYPE;
  authpatnum           NUMBER(38);
  refauthname1         REF SYS.XMLTYPE;
  authnamenum1         NUMBER(38);
  refskidmap           REF SYS.XMLTYPE;
  anypart              VARCHAR2(4000);
  i                    NUMBER(38);
  refmaptype           REF SYS.XMLTYPE;
  refmap               REF SYS.XMLTYPE;
  mapnum               NUMBER(38);
  refskidmaps          REF SYS.XMLTYPE;
  refmapstype          REF SYS.XMLTYPE;
  refmaps              REF SYS.XMLTYPE;
  mapsnum              NUMBER(38);
  authnamenum2         NUMBER(38);
  refauthname2         REF SYS.XMLTYPE;
  descrnum             NUMBER(38);
  refdescr             REF SYS.XMLTYPE;
  implnum              NUMBER(38);
  refimpl              REF SYS.XMLTYPE;
  methodnum            NUMBER(38);
  refmethod            REF SYS.XMLTYPE;
  langnum              NUMBER(38);
  reflang              REF SYS.XMLTYPE;
  reflangtype          REF SYS.XMLTYPE;
  refskidauth          REF SYS.XMLTYPE;
  refauthtype          REF SYS.XMLTYPE;
  authnum              NUMBER(38);
  refauth              REF SYS.XMLTYPE;
  refskidauthlist      REF SYS.XMLTYPE;
  refauthlisttype      REF SYS.XMLTYPE;
  authlistnum          NUMBER(38);
  refauthlist          REF SYS.XMLTYPE;
  refskidcauthtype     REF SYS.XMLTYPE;
  refcauthtype         REF SYS.XMLTYPE;
  cauthnum             NUMBER(38);
  refcauth             REF SYS.XMLTYPE;
  refskidcauth         REF SYS.XMLTYPE;
  refhttp              REF SYS.XMLTYPE;
  refhttptype          REF SYS.XMLTYPE;
  refskidhttp          REF SYS.XMLTYPE;
  elem_propno          NUMBER(38);
  isfound              BOOLEAN := FALSE;
  typenm               VARCHAR2(256);
  refctrusttype        REF SYS.XMLTYPE;
  refallowtrust        REF SYS.XMLTYPE;
  allowtrustnum        NUMBER(38);
  refsys               REF SYS.XMLTYPE;
  refsystype           REF SYS.XMLTYPE;
  refskidsys           REF SYS.XMLTYPE;
  propname             VARCHAR2(256);
  refrealm             REF SYS.XMLTYPE;
  realmnum             NUMBER(38);
  refsrvinfo           REF SYS.XMLTYPE;
  srvinfonum           NUMBER(38);
  skidhttpelems        XDB.XDB$XMLTYPE_REF_LIST_T;
  skidsyselems         XDB.XDB$XMLTYPE_REF_LIST_T;
  clistinsch           XDB.XDB$XMLTYPE_REF_LIST_T;
  reftrustschtyp       REF SYS.XMLTYPE;
  refskidtrustelems    REF SYS.XMLTYPE;
  refcauthtrusttyp     REF SYS.XMLTYPE;
  refskidtrustschs     REF SYS.XMLTYPE;
  refskidclistelems    XDB.XDB$XMLTYPE_REF_LIST_T;
  ref_ondeny_typ       REF SYS.XMLTYPE;
  ref_ondeny           REF SYS.XMLTYPE;
begin

  select ref(s) into refs from xdb.xdb$schema s
     where s.xmldata.schema_url = schema_url;

  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
     where s.xmldata.schema_url = schema_url;

  -- if at least one of the custom-auth elements or types do not exist,
  -- then this is a rerun, so return
  select count(*) into idem from xdb.xdb$complex_type c
     where c.xmldata.name='custom-authentication-trust-type'
     and c.xmldata.parent_schema=refs;
  if (idem < 1) then
     dbms_output.put_line('xdbconfig schema already downgrated');
     return;
  end if;

  -- save type and seq kid for custom-authentication-mapping
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
     into refmaptype, refskidmap
  from xdb.xdb$element e, xdb.xdb$complex_type c
  where e.xmldata.property.name='custom-authentication-mapping'
  and e.xmldata.property.parent_schema=refs
  and e.xmldata.cplx_type_decl = ref(c);

  -- save type and seq kid for custom-authentication-mappings
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
     into refmapstype, refskidmaps
  from xdb.xdb$element e, xdb.xdb$complex_type c
  where e.xmldata.property.name='custom-authentication-mappings'
  and e.xmldata.property.parent_schema=refs
  and e.xmldata.cplx_type_decl = ref(c) ;

  -- save type for authentication-implement-language
  select e.xmldata.property.type_ref into reflangtype
  from  xdb.xdb$element e 
  where e.xmldata.property.name='authentication-implement-language'
  and e.xmldata.property.parent_schema=refs;

  -- save complex type declaration and seq kid for custom-authentication-list
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid, m.xmldata.elements
     into refauthlisttype, refskidauthlist, refskidclistelems
  from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
  where e.xmldata.property.name='custom-authentication-list'
  and e.xmldata.property.parent_schema=refs
  and e.xmldata.cplx_type_decl = ref(c)
  and c.xmldata.sequence_kid = ref(m);

  refcauth := refskidclistelems(1);
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
     into refauthtype, refskidauth
  from xdb.xdb$element e,  xdb.xdb$complex_type c
  where ref(e)=refcauth and e.xmldata.cplx_type_decl = ref(c);

  -- save ref, prop num, complex type declaration and seq kid for custom-authentication
  select ref(e), e.xmldata.property.prop_number
   into refcauth, cauthnum
  from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication'
  and e.xmldata.property.parent_schema=refs;

  select ref(c), c.xmldata.sequence_kid
    into refcauthtype, refskidcauthtype
  from xdb.xdb$complex_type c
  where c.xmldata.name='custom-authentication-type'
  and c.xmldata.parent_schema = refs; 

  -- save complex_type declaration and seq kid for trust-scheme
  select e.xmldata.cplx_type_decl, c.xmldata.sequence_kid
     into reftrustschtyp, refskidtrustelems
  from xdb.xdb$element e, xdb.xdb$complex_type c
  where e.xmldata.property.name='trust-scheme'
  and e.xmldata.property.parent_schema=refs
  and e.xmldata.cplx_type_decl = ref(c);

  -- save complex_type declaration and seq kid for 
  -- custom-authentication-trust
  select ref(c), c.xmldata.sequence_kid
     into refcauthtrusttyp, refskidtrustschs
  from xdb.xdb$complex_type c
  where c.xmldata.name='custom-authentication-trust-type'
  and c.xmldata.parent_schema=refs;

  -- ref to the httpconfig element and its type
  select ref(e), e.xmldata.cplx_type_decl into refhttp, refhttptype  from xdb.xdb$element e
  where e.xmldata.property.name='httpconfig' and e.xmldata.property.parent_schema = refs;

  -- ref to the sequence kid in the complex type for httpconfig
  select c.xmldata.sequence_kid into refskidhttp from xdb.xdb$complex_type c
  where ref(c) = refhttptype;

  -- elements in the sequence 
  select m.xmldata.elements into skidhttpelems from xdb.xdb$sequence_model m where ref(m)= refskidhttp;

   -- ref and prop num for the allow-authentication-trust element
  select ref(e), e.xmldata.property.prop_number into refallowtrust, allowtrustnum from xdb.xdb$element e
  where e.xmldata.property.name='allow-authentication-trust' and e.xmldata.property.parent_schema = refs;

  -- ref to the sysconfig element and its type
  select ref(e), e.xmldata.cplx_type_decl into refsys, refsystype  from xdb.xdb$element e
  where e.xmldata.property.name='sysconfig' and e.xmldata.property.parent_schema = refs;

  -- ref to the sequence kid in the complex type for sysconfig
  select c.xmldata.sequence_kid into refskidsys from xdb.xdb$complex_type c
  where ref(c) = refsystype;

  -- elements in the sequence 
  select m.xmldata.elements into skidsyselems from xdb.xdb$sequence_model m where ref(m)= refskidsys;

  -- ref and prop num for the realm element
  select ref(e), e.xmldata.property.prop_number into refrealm, realmnum from xdb.xdb$element e
  where e.xmldata.property.name='realm' and e.xmldata.property.parent_schema = refs; 

  -- ref and prop num for the respond-with-server-info element
  select ref(e), e.xmldata.property.prop_number into refsrvinfo, srvinfonum from xdb.xdb$element e
  where e.xmldata.property.name='respond-with-server-info'
    and e.xmldata.property.parent_schema = refs; 

  -- ref to the on-deny element and its simple type
  select ref(e), e.xmldata.property.smpl_type_decl into ref_ondeny, ref_ondeny_typ
  from xdb.xdb$element e
  where e.xmldata.property.name='on-deny' and e.xmldata.property.parent_schema = refs;

  -- remove 'custom' for 'allow-mechanism' 
  -- Note: if more than one 'allow-mechanism' subelemnts will ever be added to the CONFIG schema,
  --       change this code to go through the kids of httpconfig, find 'authentication', and pick 
  --       the 'allow-mechanism' in the authentication kids
  update xdb.xdb$simple_type t
  set t.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020000000106'),
      t.xmldata.restriction = XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, 
                                                          XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, 
                                                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                                                          XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'),
                                                                                               NULL, 'digest', '00', NULL), 
                                                                               XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'),
                                                                                               NULL, 'basic', '00', NULL)), 
                                                                               NULL, NULL)
  where ref(t) = (select e.xmldata.property.smpl_type_decl from xdb.xdb$element e
                  where e.xmldata.property.name ='allow-mechanism' and e.xmldata.property.parent_schema = refs);

  -- update annotation for the complex type declaration for httpconfig
  --  This step and the two below can be much simplified
  --  if we are guaranteed custom-auth, realm and srvinfo are 
  --  the last 3 kids in the sequence, until then we follow a very safe approach
 
  -- remove reference to srvinfo
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidhttpelems.last loop
     select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
     where ref(e) = skidhttpelems(i);
     if (not (isfound)) then
       if (elem_propno != srvinfonum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidhttpelems(i-1) := skidhttpelems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidhttpelems.trim(1);

  -- remove reference to realm 
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidhttpelems.last loop
     select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
     where ref(e) = skidhttpelems(i);
     if (not (isfound)) then
       if (elem_propno != realmnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidhttpelems(i-1) := skidhttpelems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidhttpelems.trim(1);
 
  -- remove reference to custom-authentication
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidhttpelems.last loop
     select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
     where ref(e) = skidhttpelems(i);
     if (not (isfound)) then
       if (elem_propno != cauthnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidhttpelems(i-1) := skidhttpelems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidhttpelems.trim(1);
  
  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo =  XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
  where c.xmldata.parent_schema = refs and ref(c)=refhttptype;    

  -- update elements and PD for seq kid of httpconfig (remove custom-authentication)
  update xdb.xdb$sequence_model m set m.xmldata.elements = skidhttpelems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801407')
  where ref(m)= refskidhttp;


  -- update annotation for the complex type declaration for sysconfig 
  --  (remove reference to allow-authentication-trust and custom-authentication-trust)
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidsyselems.last loop
     select e.xmldata.property.prop_number into elem_propno from xdb.xdb$element e
     where ref(e) = skidsyselems(i);
     if (not (isfound)) then
       if (elem_propno != allowtrustnum) then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidsyselems(i-1) := skidsyselems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidsyselems.trim(1);

  -- Note: there are 2 custom-authentication-trust elements in xdbconfig, so need a different approach than
  --       with allow-authentication-trust
  isfound := FALSE;
  anypart := '<xdb:kidList xmlns:xdb="http://xmlns.oracle.com/xdb" sequential="true">';
  for i in 1..skidsyselems.last loop
     select distinct e.xmldata.property.name into propname from xdb.xdb$element e
     where ref(e) = skidsyselems(i);
     if (not (isfound)) then
       if (propname != 'custom-authentication-trust') then 
         anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-1) || '"/>';
       else
         isfound := TRUE;
       end if;
     else
       -- shift left
       anypart := anypart || chr(10) || '  <xdb:kid propNum="' || elem_propno || '" kidNum="' || (i-2) || '"/>';
       skidsyselems(i-1) := skidsyselems(i);
     end if;
  end loop;  
  anypart := anypart || chr(10) || '</xdb:kidList>';
  skidsyselems.trim(1);

  update xdb.xdb$complex_type c
  set c.xmldata.annotation.appinfo =  XDB.XDB$APPINFO_LIST_T(XDB.XDB$APPINFO_T(XDB.XDB$RAW_LIST_T('1301000000'), anypart, NULL))
  where c.xmldata.parent_schema = refs and ref(c)=refsystype;    

  -- update elements and PD for seq kid of sysconfig 
  update xdb.xdb$sequence_model m set m.xmldata.elements = skidsyselems,
                                      m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081801807')
  where ref(m)= refskidsys;

  -- remove custom-authentication-type and custom-authentication-trust-type from complex_types list in schema
  select s.xmldata.complex_types into clistinsch from xdb.xdb$schema s where s.xmldata.schema_url = schema_url;
  isfound := FALSE;
  for i in 1..clistinsch.last loop
     select c.xmldata.name into typenm from xdb.xdb$complex_type c where ref(c) = clistinsch(i);
     dbms_output.put_line(typenm);
     if (not (isfound)) then
        if (typenm = 'custom-authentication-type') then
           isfound := TRUE;
        end if;
     else
       -- shift left
       clistinsch(i-1) :=  clistinsch(i);
     end if;
  end loop;  
  clistinsch.trim(1);  

  isfound := FALSE;
  for i in 1..clistinsch.last loop
     select c.xmldata.name into typenm from xdb.xdb$complex_type c where ref(c) = clistinsch(i);
     if (not (isfound)) then
        if (typenm = 'custom-authentication-trust-type') then
           isfound := TRUE;
        end if;
     else
       -- shift left
       clistinsch(i-1) :=  clistinsch(i);
     end if;
  end loop;  
  clistinsch.trim(1); 

  -- update PD and num props for schema
  update xdb.xdb$schema s set s.xmldata.complex_types = clistinsch, 
                              s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B81800202131416120A170D'),
                              s.xmldata.num_props = CONFIG_PRPONUMS_DOWN
  where s.xmldata.schema_url = schema_url;  

  ------- now do the cleanup
  delete from xdb.xdb$element e
  where e.xmldata.property.name='realm'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='respond-with-server-info'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$complex_type c where ref(c)=refcauthtype;
  delete from xdb.xdb$sequence_model m where ref(m)= refskidcauthtype;

  
  delete from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication-trust'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$complex_type c where ref(c)= refcauthtrusttyp;
  delete from xdb.xdb$sequence_model m where ref(m)=refskidtrustschs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='trust-scheme'
  and e.xmldata.property.parent_schema=refs; 

  delete from xdb.xdb$complex_type c  where ref(c)=reftrustschtyp;
  delete from xdb.xdb$sequence_model m  where ref(m)=refskidtrustelems;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='trusted-parsing-schema'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='trusted-session-user'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='trust-scheme-description'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='allowRegistration'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='requireParsingSchema'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='trust-scheme-name'
  and e.xmldata.property.parent_schema=refs;


  delete from xdb.xdb$element e
  where e.xmldata.property.name='allow-authentication-trust'
  and e.xmldata.property.parent_schema=refs;


  delete from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication-list'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$complex_type c where ref(c)= refauthlisttype;
  delete from xdb.xdb$sequence_model m where ref(m)=refskidauthlist;  

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-implement-language'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$simple_type c
  where ref(c)=reflangtype;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-implement-method'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-implement-schema'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-description'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-name'
  and e.xmldata.property.parent_schema=refs;


  delete from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication-mappings'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$complex_type c where ref(c) = refmapstype;
  delete from xdb.xdb$sequence_model m where ref(m) = refskidmaps; 


  delete from xdb.xdb$element e
  where e.xmldata.property.name='custom-authentication-mapping'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$complex_type c where ref(c) = refmaptype;
  delete from xdb.xdb$sequence_model m where ref(m) = refskidmap; 

  delete from xdb.xdb$element e
  where e.xmldata.property.name='user-prefix'
  and e.xmldata.property.parent_schema=refs;


  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-trust-name'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e where ref(e)=ref_ondeny;
  delete from xdb.xdb$simple_type t where ref(t)=ref_ondeny_typ;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-name'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e
  where e.xmldata.property.name='authentication-pattern'
  and e.xmldata.property.parent_schema=refs;

  delete from xdb.xdb$element e where ref(e)=refcauth;
  delete from xdb.xdb$complex_type c where ref(c)=refauthtype;
  delete from xdb.xdb$sequence_model m where ref(m)=refskidauth;

  commit;
end;
/
show errors;

exec downgradeConfig;
-- clean-up
drop procedure downgradeConfig;

Rem Drop upgrade utility functions
@@xdbuud.sql

-- BEGIN: downgrade for XML Index
drop table XDB.XDB$XIDX_IMP_T;
create global temporary table XDB.XDB$XIDX_IMP_T
                                (index_name VARCHAR2(40), 
                                 schema_name VARCHAR2(40),
                                 id VARCHAR2(40), 
                                 sqlstr CLOB);

drop package XDB.ximetadata_pkg;

ALTER TYPE xdb.XMLIndexMethods DROP static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2; 

ALTER TYPE xdb.XMLIndexMethods ADD  static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, len_newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2 is language C name "QMIX_XMETADATA" library XDB.XMLINDEX_LIB with context parameters (context, idxinfo, idxinfo INDICATOR struct, idxenv,  idxenv  INDICATOR struct, expver,  expver  INDICATOR, len_newblock, len_newblock INDICATOR sb4, RETURN LENGTH, RETURN);

ALTER TYPE xdb.XMLIndexMethods DROP static function ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, read_only IN PLS_INTEGER, version IN varchar2, context OUT PLS_INTEGER) return BOOLEAN;

ALTER TYPE xdb.XMLIndexMethods DROP static procedure ODCIIndexUtilCleanup (context  IN PLS_INTEGER);

create or replace type body xdb.XMLIndexMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;

  static function ODCIIndexUpdPartMetadata(ixdxinfo sys.ODCIIndexInfo,
                                           palist   sys.ODCIPartInfoList,
                                           idxenv   sys.ODCIEnv)
         return NUMBER
  is
  BEGIN
   RETURN ODCICONST.SUCCESS;
  END;

end;
/

----------------------------------------------------------------------------
-- De-support partitioning of XMLIndex
alter indextype XDB.xmlindex
  using XDB.XMLIndexMethods
  without local partition
  with system managed storage tables;

-- END: downgrade for XML Index
-- container - mark mutable
declare
  res_schema_ref  REF XMLTYPE;
  res_schema_url  VARCHAR2(100);
begin
  res_schema_url := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

  select ref(s) into res_schema_ref
  from xdb.xdb$schema s
  where s.xmldata.schema_url = res_schema_url;

  update xdb.xdb$attribute a
  set a.xmldata.MUTABLE = '00'
  where a.xmldata.parent_schema = res_schema_ref
    and a.xmldata.name = 'Container';

  commit;
end;
/

drop package xdb.XDB_PITRIG_PKG_01;

-- Clean up session/shared state 
exec xdb.dbms_xdbutil_int.flushsession;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

Rem ================================================================
Rem END XDB Schema downgrade to 11.1.0
Rem ================================================================
