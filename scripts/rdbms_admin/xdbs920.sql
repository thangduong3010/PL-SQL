Rem
Rem $Header: rdbms/admin/xdbs920.sql /main/5 2010/05/05 15:12:00 badeoti Exp $
Rem
Rem xdbs920.sql
Rem
Rem Copyright (c) 2003, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbs920.sql - XDB Upgrade Schemas from 9.2.0.1
Rem
Rem    DESCRIPTION
Rem      Upgrades the bootstrap schemas from 9.2.0.1 to 9.2.0.2 and onward
Rem
Rem    NOTES
Rem      At the end of the file, calls xdbs9202.sql to continue
Rem      upgrading schmeas from 9.2.0.2 and onward.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/19/10 - Bug 9591328
Rem    samane      10/24/09 - Bug 8609997
Rem    spannala    06/24/03 - remove enable_hierarchy
Rem    spannala    05/22/03 - disable hierarchy on config until root schema is fully migrated
Rem    njalali     02/21/03 - njalali_bug-2796015
Rem    njalali     02/11/03 - Created
Rem


-- XDB Schema for Schemas (DDL first)

-- Add "ID" to the facets.  The new columns should be NULL after the migration.
declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 10) then
    execute immediate 
      'alter type xdb.xdb$facet_t add attribute ("ID" VARCHAR2(256)) cascade';
    update xdb.migr9202status set n = 10;
    commit;
  end if;
end;
/

declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 20) then
    execute immediate 
      'alter type xdb.xdb$numfacet_t add 
       attribute ("ID" VARCHAR2(256)) cascade';
    update xdb.migr9202status set n = 20;
    commit;
  end if;
end;
/

declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 30) then
    execute immediate 
      'alter type xdb.xdb$timefacet_t add 
       attribute ("ID" VARCHAR2(256)) cascade';
    update xdb.migr9202status set n = 30;
    commit;
  end if;
end;
/

declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if (m < 40) then
    execute immediate 
      'alter type xdb.xdb$whitespace_t add
       attribute ("ID" VARCHAR2(256)) cascade';
    update xdb.migr9202status set n = 40;
    commit;
  end if;
end;
/

-- Create type xdb$simplecont_res_t
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

-- Create type xdb$simplecont_ext_t
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

-- Create type xdb$simplecontent_t
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

-- Add attribute "SIMPLECONT" to xdb$complex_t
declare
  m integer;
begin
 select n into m from xdb.migr9202status for update;
 if (m < 60) then
  execute immediate 
    'alter type xdb.xdb$complex_t
     add attribute (simplecont xdb.xdb$simplecontent_t) cascade';
  update xdb.migr9202status set n = 60;
  commit;
 end if;
end;
/

-- grant execute privileges
grant execute on xdb.xdb$simplecont_res_t to public with grant option;
grant execute on xdb.xdb$simplecont_ext_t to public with grant option;
grant execute on xdb.xdb$simplecontent_t to public with grant option;

GRANT SELECT ON xdb.xdb$namesuff_seq TO PUBLIC;


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

                execute immediate 'insert into xdb.xdb$element e (xmldata) values (:1) returning ref(e) into :2' using elem_i returning into elem_ref;

                return elem_ref;
        end;
/

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

                execute immediate 'insert into xdb.xdb$attribute a (xmldata) values (:1) returning ref(a) into :2' using attr_i returning into attr_ref;

                return attr_ref;
        end;
/

create or replace function xdb.xdb$insertSequence(
  parent_schema ref sys.xmltype,
  elements          xdb.xdb$xmltype_ref_list_t,
  anyelems        xdb.xdb$xmltype_ref_list_t := null,
  choice_list     xdb.xdb$xmltype_ref_list_t := null
  )
return ref sys.xmltype is
  model_i   xdb.xdb$model_t;
  model_ref ref sys.xmltype;
begin
  if (elements is null and anyelems is null) then
    return null;
  else
    model_i := xdb.xdb$model_t(null, parent_schema, 1, '1', elements,
                               choice_list, null,
                               anyelems, null, null, null);

    execute immediate 'insert into xdb.xdb$sequence_model c (xmldata) values (:1) returning ref(c) into :2' using model_i returning into model_ref;
    return model_ref;
  end if;
end;
/

create or replace function xdb.xdb$insertComplex(
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                abstract        raw,
                derived_by      xdb.xdb$derivationChoice,
                flags           raw,
                precision       integer,
                scale           integer,
                minlength       integer,
                maxlength       integer,
                whitespace      xdb.xdb$whitespaceChoice,
                period          date,
                duration        date,
                min_bound       varchar2,
                max_bound       varchar2,
                pattern         varchar2,
                enumeration     xdb.xdb$enum_values_t,
                dummy           varchar2,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                glob_elements   xdb.xdb$xmltype_ref_list_t,
                local_elements  xdb.xdb$xmltype_ref_list_t,
                attributes      xdb.xdb$xmltype_ref_list_t,
                anyelems        xdb.xdb$xmltype_ref_list_t := null,
                mixed           raw := '0',
                model_ref       ref sys.xmltype := null
        ) return ref sys.xmltype is
                complex_i xdb.xdb$complex_t;
                complex_ref ref sys.xmltype;
                model_r     ref sys.xmltype;
                FALSE         RAW(1) := '0';
                TRUE          RAW(1) := '1';
        begin

            if model_ref is null then
              model_r := xdb$insertSequence(parent_schema, local_elements,
                                            anyelems);
            else
              model_r := model_ref;
            end if;

            if base_type is null then
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,mixed,final_info, block,
                                attributes,null,null,null,null,model_r,null,
                                null,null,null,null,null,null,null,null,null);
            else
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,mixed,final_info,block,
                                null, null, null, null, null,null,null,null,
                                xdb.xdb$content_t(null, FALSE, null,
                                  xdb.xdb$complex_derivation_t(
                                    null, base, attributes, null, null,
                                    null,null,model_r,null,null,null), null,null),
                                null, null,null,FALSE,null,null,null);
            end if;


            execute immediate 'insert into xdb.xdb$complex_type c (xmldata) values (:1) returning ref(c) into :2' using complex_i returning into complex_ref;
            return complex_ref;
        end;
/

create or replace function xdb.xdb$insertChoice(
  parent_schema ref sys.xmltype,
  elements          xdb.xdb$xmltype_ref_list_t,
  anyelems        xdb.xdb$xmltype_ref_list_t := null,
  maxoccurs       varchar2 := 'unbounded')
return ref sys.xmltype is
  model_i   xdb.xdb$model_t;
  model_ref ref sys.xmltype;
begin
  if (elements is null and anyelems is null) then
    return null;
  else
    model_i := xdb.xdb$model_t(null, parent_schema, 0, maxoccurs,
                               elements, null, null,
                               anyelems, null, null, null);

    execute immediate 'insert into xdb.xdb$choice_model c (xmldata) values (:1) returning ref(c) into :2' using model_i returning into model_ref;
    return model_ref;
   end if;
end;
/


-- Big migration of the root schema
create or replace procedure xdb.rootschemamigrate is
/*
 * Root schema changes
 *
 *  1. modelType         - changed from sequence to choice
 *  2. smplcontResType   - added in 9.2.0.2
 *  3. smplcontExtType   - added in 9.2.0.2
 *  4. smplcontType      - added in 9.2.0.2
 *  5. simpleContent     - use smplcontType for simpleContent
 *  6. complexDerivation - changed from sequence to choice
 *  7. complexType       - changed from sequence to choice
 *                       - copy over simpleContent to new type
 *  8. schema            - changed from sequence to choice
 *                       - update global complextypes and num_props
 *  9. hidden flag       - has been set in 9.2.0.2 for all attributes
 *                         whose value is a REF (example typeRef)
 * 10. ID attribute      - added in 9.2.0.2 for facets
 * 11. misc changes      - baseProp, binary etc
 */

        PN_FACET_ID CONSTANT INTEGER      := 234;
        PN_NUMFACET_ID CONSTANT INTEGER   := 235;
        PN_TIMEFACET_ID CONSTANT INTEGER  := 236;
        PN_WHITESPACE_ID CONSTANT INTEGER := 237;

        /* simpleContent -> extension */
        PN_SIMPLECONTEXT_BASE             CONSTANT INTEGER := 238;
        PN_SIMPLECONTEXT_ID               CONSTANT INTEGER := 239;
        PN_SIMPLECONTEXT_ANNOTATION       CONSTANT INTEGER := 240;
        PN_SIMPLECONTEXT_ATTRIBUTE        CONSTANT INTEGER := 241;
        PN_SIMPLECONTEXT_ANYATTR          CONSTANT INTEGER := 242;
        PN_SIMPLECONTEXT_ATTRGROUP        CONSTANT INTEGER := 243;
        
        /* simpleContent -> restriction */
        PN_SIMPLECONTRES_BASE             CONSTANT INTEGER := 244;
        PN_SIMPLECONTRES_ID               CONSTANT INTEGER := 245;
        PN_SIMPLECONTRES_ATTRIBUTE        CONSTANT INTEGER := 246;
        PN_SIMPLECONTRES_ANYATTR          CONSTANT INTEGER := 247;
        PN_SIMPLECONTRES_ATTRGROUP        CONSTANT INTEGER := 248;
        PN_SIMPLECONTRES_ANNOTATION       CONSTANT INTEGER := 249;
        PN_SIMPLECONTRES_FRACDIGITS       CONSTANT INTEGER := 250;
        PN_SIMPLECONTRES_TOTALDIGITS      CONSTANT INTEGER := 251;
        PN_SIMPLECONTRES_MINLENGTH        CONSTANT INTEGER := 252;
        PN_SIMPLECONTRES_MAXLENGTH        CONSTANT INTEGER := 253;
        PN_SIMPLECONTRES_WHITESPACE       CONSTANT INTEGER := 254;
        PN_SIMPLECONTRES_PERIOD           CONSTANT INTEGER := 255;
        PN_SIMPLECONTRES_DURATION         CONSTANT INTEGER := 256;
        PN_SIMPLECONTRES_MININCLUSIVE     CONSTANT INTEGER := 257;
        PN_SIMPLECONTRES_MAXINCLUSIVE     CONSTANT INTEGER := 258;
        PN_SIMPLECONTRES_PATTERN          CONSTANT INTEGER := 259;
        PN_SIMPLECONTRES_ENUMERATION      CONSTANT INTEGER := 260;
        PN_SIMPLECONTRES_MINEXCLUSIVE     CONSTANT INTEGER := 261;
        PN_SIMPLECONTRES_MAXEXCLUSIVE     CONSTANT INTEGER := 262;
        PN_SIMPLECONTRES_LENGTH           CONSTANT INTEGER := 263;
        PN_SIMPLECONTRES_SIMPLETYPE       CONSTANT INTEGER := 264;

        /* simpleContent */
        PN_SIMPLECONTENT_ID               CONSTANT INTEGER := 265;
        PN_SIMPLECONTENT_ANNOTATION       CONSTANT INTEGER := 266;
        PN_SIMPLECONTENT_RESTRICTION      CONSTANT INTEGER := 267;
        PN_SIMPLECONTENT_EXTENSION        CONSTANT INTEGER := 268;

        T_JAVASTRING  RAW(2) :='101';
        T_XOB         RAW(2) :='102';
        T_ENUM        RAW(2) :='103';
        T_QNAME       RAW(2) :='104'; 
        T_XOBD        RAW(2) :='105'; 
        T_CSTRING     RAW(2) :='1'; /* DTYCHR */
        T_NUMBER      RAW(2) :='2'; /* DTYNUM */
        T_INTEGER     RAW(2) :='3'; /* DTYINT */
        T_FLOAT       RAW(2) :='4'; /* DTYFLT */
        T_DATE        RAW(2) :='c'; /* DTYDAT */
        T_TIMESTAMP   RAW(2) :='b4'; /* DTYSTAMP */
        T_BINARY      RAW(2) :='17'; /* DTYBIN */
        T_UNSIGNINT   RAW(2) :='44'; /* DTYINT */
        T_REF         RAW(2) :='6e'; /* DTYREF */
        T_BOOLEAN     RAW(2) :='fc'; /* DTYBOL */
        T_BLOB        RAW(2) :='71'; /* DTYBLOB */
        T_CLOB       CONSTANT RAW(2) :='70';

        JT_STRING      xdb.xdb$javatype := xdb.xdb$javatype('0');
        JT_INT         xdb.xdb$javatype := xdb.xdb$javatype('1');
        JT_LONG        xdb.xdb$javatype := xdb.xdb$javatype('2');
        JT_SHORT       xdb.xdb$javatype := xdb.xdb$javatype('3');
        JT_BYTE        xdb.xdb$javatype := xdb.xdb$javatype('4');
        JT_FLOAT       xdb.xdb$javatype := xdb.xdb$javatype('5');
        JT_DOUBLE      xdb.xdb$javatype := xdb.xdb$javatype('6');
        JT_BIGDECIMAL  xdb.xdb$javatype := xdb.xdb$javatype('6');
        JT_BOOLEAN     xdb.xdb$javatype := xdb.xdb$javatype('8');
        JT_BYTEARRAY   xdb.xdb$javatype := xdb.xdb$javatype('9');
        JT_STREAM      xdb.xdb$javatype := xdb.xdb$javatype('a');
        JT_CHARSTREAM  xdb.xdb$javatype := xdb.xdb$javatype('b');
        JT_TIMESTAMP   xdb.xdb$javatype := xdb.xdb$javatype('c');
        JT_REFERENCE   xdb.xdb$javatype := xdb.xdb$javatype('d');
        JT_QNAME       xdb.xdb$javatype := xdb.xdb$javatype('e');
        JT_ENUM        xdb.xdb$javatype := xdb.xdb$javatype('f');
        JT_XMLTYPE     xdb.xdb$javatype := xdb.xdb$javatype('10');


        TR_STRING     xdb.xdb$qname := xdb.xdb$qname('00', 'string');
        TR_BOOLEAN    xdb.xdb$qname := xdb.xdb$qname('00', 'boolean');
        TR_BINARY     xdb.xdb$qname := xdb.xdb$qname('00', 'hexBinary');
        TR_INT        xdb.xdb$qname := xdb.xdb$qname('00', 'integer');
        TR_NNEGINT    xdb.xdb$qname := xdb.xdb$qname('00', 
                                                         'nonNegativeInteger');

        FALSE         RAW(1) := '0';
        TRUE          RAW(1) := '1';
       PN_TOTAL_PROPNUMS CONSTANT INTEGER := 270;

    seq_ref   ref sys.xmltype;
    sch_ref   ref sys.xmltype;
    ellist    xdb.xdb$xmltype_ref_list_t;
    ellist2              xdb.xdb$xmltype_ref_list_t;
    ann_el    ref sys.xmltype;
    choice_list xdb.xdb$xmltype_ref_list_t;
    choice_list2         xdb.xdb$xmltype_ref_list_t;
    attlist              xdb.xdb$xmltype_ref_list_t;
    simplecontRes_t_ref  ref sys.xmltype;
    attrgroupref_t_ref  ref sys.xmltype;
    simplecontExt_t_ref  ref sys.xmltype;
    any_t_ref            ref sys.xmltype;
    annotation_t_ref     ref sys.xmltype;
    num_facet_ref       ref sys.xmltype;
    whitespace_ref       ref sys.xmltype;
    smplcont_t_ref       ref sys.xmltype;
    time_facet_ref       ref sys.xmltype;
    facet_ref       ref sys.xmltype;
    simple_t_ref       ref sys.xmltype;
    attribute_t_ref  ref sys.xmltype;
    attr_colcount        integer;
    any_colcount         integer;
    attrgroupref_colcount integer;
    annotation_colcount   integer;
    simple_colcount       integer;
    simplecontRes_colcount integer;
    simplecontExt_colcount integer;
    smplcont_colcount      integer;

    schels       xdb.xdb$xmltype_ref_list_t;
    num_props    integer;
    schref       REF sys.xmltype;

    m   integer;
    rc  integer;
    cur integer;
begin
  select ref(s) into sch_ref from xdb.xdb$schema s where  
    s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

  select attributes into simple_colcount from all_types
    where type_name in ('XDB$SIMPLE_T') and owner = 'XDB';

  select attributes into attr_colcount from all_types
    where type_name in ('XDB$PROPERTY_T') and owner = 'XDB';

  select attributes into simplecontRes_colcount from all_types
    where type_name in ('XDB$SIMPLECONT_RES_T') and owner = 'XDB';

  select attributes into simplecontExt_colcount from all_types
    where type_name in ('XDB$SIMPLECONT_EXT_T') and owner = 'XDB';

  select attributes into smplcont_colcount from all_types
    where type_name in ('XDB$SIMPLECONTENT_T') and owner = 'XDB';

  select sum(attributes) - 1 into any_colcount from all_types
    where type_name in ('XDB$ANY_T', 'XDB$PROPERTY_T') and owner = 'XDB';

  select attributes into annotation_colcount from all_types
    where type_name in ('XDB$ANNOTATION_T') and owner = 'XDB';
  
  select ref(c) into any_t_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name='anyType';

  select ref(c) into attrgroupref_t_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name='attrGroupRefType';

  select ref(c) into attribute_t_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name='attribute';

  select ref(c) into annotation_t_ref
  from xdb.xdb$complex_type c
  where c.xmldata.name='annotation';

  
/*-----------------------------------------------------------------------------
 *                               S T E P    1
 *---------------------------------------------------------------------------*/
/* modelType
 *
 * This has changed from a sequence of elements (each with maxoccurs unb)
 * to a choice (unbounded) of elements.
 *
 * Original 9.2.0.1 definition of modelType
 *
 *    modelType :=                ----  annotation (0..1)
 *                               |
 *                               |----  all (0..unb)
 *                   sequence  ---   ...
 *                               |----  choice (0..unb)
 *
 *
 * New 9.2.0.2 definition of modelType
 *
 *   modelType :=                    -- annotation (0..1)
 *                                  |
 *                    sequence  ----
 *                     (1..1)       |
 *                                   -- choice (0..unb)
 *                                         -- all       (0..1)
 *                                         -- ...
 *                                         -- group     (0..1)
 *
 */

  select n into m from xdb.migr9202status for update;
  if (m < 100) then

    select c.xmldata.sequence_kid into seq_ref
    from   xdb.xdb$complex_type c
    where  c.xmldata.parent_schema = sch_ref
    and    c.xmldata.name = 'modelType';

    select s.xmldata.elements into ellist
    from   xdb.xdb$sequence_model s
    where  sys_op_r2o(ref(s)) = sys_op_r2o(seq_ref);
    
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(5);
    for i in 1..5 loop
      ellist2(i) := ellist(i+1);
    end loop;

    /* insert a choice */
    choice_list := xdb.xdb$xmltype_ref_list_t();
    choice_list.extend(1);
    choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist2);

    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(1);
    ellist2(1) := ellist(1);

    /* update the sequence */
    execute immediate 'update xdb.xdb$sequence_model s set
        s.xmldata.elements = :1,
        s.xmldata.choice_kids = :2
      where sys_op_r2o(ref(s)) = sys_op_r2o(:3)'
    using ellist2, choice_list, seq_ref;

    
/*-----------------------------------------------------------------------------
 *                               S T E P    2
 *---------------------------------------------------------------------------*/
/*
 * simpleContent Restriction
 *
 * This was not present in 9.2.0.1.
 *
 *    simpleContRes :=
 *                             -- annotation   (0..1)
 *                            |
 *                             -- simpleType   (0..1)
 *                            |
 *                            |-- minExclusive (0..1)
 *                            |-- minInclusive (0..1)
 *                            |     ....
 *          sequence ---------|-- pattern      (0..1)
 *                            |
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb.xdb$insertAttr(sch_ref, PN_SIMPLECONTRES_BASE,
                                     'base', xdb.xdb$qname('00', 'QName'), 0,1,
                                     null, T_QNAME, FALSE, FALSE, FALSE,
                                     'BASE', 'XDB$QNAME', 'XDB',
                                     JT_QNAME, null, null, null,null,null);

        attlist(2) := xdb.xdb$insertAttr(sch_ref, PN_SIMPLECONTRES_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        /* Construct choice of <attribute>, <attributeGroup>, <anyAttrib> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        ellist(1) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',
                                       JT_XMLTYPE, null, null, attribute_t_ref,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');
                                       
        ellist(2) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',
                                       JT_XMLTYPE, null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean',
                                       FALSE, 'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* insert choice of above */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist);

        /* obtain all the type definitions */
        select ref(s) into num_facet_ref
        from xdb.xdb$complex_type s
        where s.xmldata.parent_schema = sch_ref
          and s.xmldata.name = 'numFacet';

        select ref(s) into whitespace_ref
        from xdb.xdb$complex_type s
        where s.xmldata.parent_schema = sch_ref
          and s.xmldata.name = 'whiteSpace';

        select ref(s) into time_facet_ref
        from xdb.xdb$complex_type s
        where s.xmldata.parent_schema = sch_ref
          and s.xmldata.name = 'timeFacet';

        select ref(s) into facet_ref
        from xdb.xdb$complex_type s
        where s.xmldata.parent_schema = sch_ref
          and s.xmldata.name = 'facet';

        select ref(s) into simple_t_ref
        from xdb.xdb$complex_type s
        where s.xmldata.parent_schema = sch_ref
          and s.xmldata.name = 'simpleType';

        /* Construct sequence of <annotation>...<minExclusive> etc */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(16);

        ellist(1) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_FRACDIGITS,
                        'fractionDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                        T_XOB, FALSE, FALSE, FALSE, 'FRACTIONDIGITS', 
                        'XDB$NUMFACET_T', 'XDB', JT_SHORT, null, null, 
                        num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(3) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_TOTALDIGITS, 'totalDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'TOTALDIGITS', 'XDB$NUMFACET_T', 'XDB', JT_SHORT, null,null, 
                        num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(4) := xdb.xdb$insertElement(sch_ref,PN_SIMPLECONTRES_MINLENGTH, 
                                'minLength', 
                              xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                              T_XOB, FALSE, FALSE, FALSE, 'MINLENGTH', 
                              'XDB$NUMFACET_T', 'XDB', JT_INT, null, null, 
                              num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null) ;

        ellist(5) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_MAXLENGTH,
                              'maxLength', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'MAXLENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(6) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_WHITESPACE, 'whiteSpace', 
                        xdb.xdb$qname('01', 'whiteSpace'), 0, 1, '1', 
                         T_XOB, FALSE, FALSE, FALSE, 'WHITESPACE', 
                        'XDB$WHITESPACE_T', 'XDB', JT_ENUM, null, null, 
                        whitespace_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(7) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_PERIOD, 'period', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'PERIOD', 
                        'XDB$TIMEFACET_T', 'XDB', JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(8) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_DURATION,'duration', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'DURATION', 
                        'XDB$TIMEFACET_T','XDB',JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(9) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_MININCLUSIVE, 
                                'minInclusive', 
                                xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_INCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(10) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_MAXINCLUSIVE,
                                               'maxInclusive', 
                                        xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_INCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(11) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_PATTERN, 'pattern', 
                                xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 'PATTERN', 
                        'XDB$FACET_T', 'XDB', JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');


        ellist(12) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_ENUMERATION,
                                'enumeration', xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ENUMERATION', 'XDB$FACET_T', 'XDB',
                        JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');

        ellist(13) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_MINEXCLUSIVE, 
                            'minExclusive', xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_EXCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(14) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_MAXEXCLUSIVE,
                                'maxExclusive', xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_EXCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(15) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_LENGTH,
                              'length', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'LENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(16) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTRES_SIMPLETYPE, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'LCL_SMPL_DECL',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null);

        /* insert sequence of above */
        seq_ref := xdb.xdb$insertSequence(sch_ref, ellist, null, choice_list);

        simplecontRes_t_ref := xdb.xdb$insertComplex(sch_ref, null,
                                               'simpleContentResType', 
                                               null, FALSE, null, '0',
                                               null, null, null, null, null,
                                               null, null, null, null,
                                               null, null,
                                               null, null,
                                               null, null, null, attlist,
                                               null, FALSE, seq_ref);

/*-----------------------------------------------------------------------------
 *                               S T E P    3
 *---------------------------------------------------------------------------*/
/*
 * simpleContent Extension
 *
 * This was not present in 9.2.0.1
 *
 *
 *   simpleContExt :=                -- annotation (0..1)
 *                                  |
 *                    sequence  ----
 *                     (1..1)       |
 *                                   -- choice (0..unb)
 *                                         -- attribute      (0..1)
 *                                         -- attributeGroup (0..1)
 *                                         -- anyAttribute   (0..1)
 *--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb.xdb$insertAttr(sch_ref, PN_SIMPLECONTEXT_BASE,
                                     'base', xdb.xdb$qname('00', 'QName'), 0,1,
                                     null, T_QNAME, FALSE, FALSE, FALSE,
                                     'BASE', 'XDB$QNAME', 'XDB',
                                     JT_QNAME, null, null, null,null,null);

        attlist(2) := xdb.xdb$insertAttr(sch_ref, PN_SIMPLECONTEXT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        /* Construct choice of <attribute>, <attributeGroup>, <anyAttrib> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        ellist(1) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTEXT_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',
                                       JT_XMLTYPE, null, null, attribute_t_ref,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');
                                       
        ellist(2) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTEXT_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',
                                       JT_XMLTYPE, null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean',
                                       FALSE, 'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTEXT_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* insert choice of above */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist);

        /* build annotation element */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb.xdb$insertElement(sch_ref,PN_SIMPLECONTEXT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        /* insert sequence of above */
        seq_ref := xdb.xdb$insertSequence(sch_ref, ellist, null, choice_list);

        simplecontExt_t_ref := xdb.xdb$insertComplex(sch_ref, null,
                                               'simpleContentExtType', 
                                               null, FALSE, null, '0',
                                               null, null, null, null, null,
                                               null, null, null, null,
                                               null, null,
                                               null, null,
                                               null, null, null, attlist,
                                               null, FALSE, seq_ref);


/*-----------------------------------------------------------------------------
 *                               S T E P    4
 *---------------------------------------------------------------------------*/
/*
 * smplcontentType
 *
 * This was not present in 9.2.0.1
 */

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(1);
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        attlist(1) := xdb.xdb$insertAttr(sch_ref, PN_SIMPLECONTENT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist(1) := xdb.xdb$insertElement(sch_ref,PN_SIMPLECONTENT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTENT_RESTRICTION,
                                       'restriction',
                                     xdb.xdb$qname('01', 'simpleContentResType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'RESTRICTION',
                                       'XDB$SIMPLECONT_RES_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, simplecontRes_t_ref,null,null,
                                       null, simplecontRes_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleContentRestriction', 
                                       'oracle.xdb.simpleContentRestrictionBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb.xdb$insertElement(sch_ref, PN_SIMPLECONTENT_EXTENSION,
                                       'extension',
                                     xdb.xdb$qname('01', 'simpleContentExtType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'EXTENSION',
                                       'XDB$SIMPLECONT_EXT_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, simplecontExt_t_ref,null,null,
                                       null, simplecontExt_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleContentExtension', 
                                       'oracle.xdb.simpleContentExtensionBean',
                                       FALSE, null, null, null);
    
        smplcont_t_ref := xdb.xdb$insertComplex(sch_ref, null,
                                           'smplcontentType', 
                                           null, FALSE, null, '0',
                                           null, null, null, null, null,
                                           null, null, null, null,
                                           null, null,
                                           null, null,
                                           null, null, ellist, attlist);

/*-----------------------------------------------------------------------------
 *                               S T E P    5
 *---------------------------------------------------------------------------*/
/*
 * simpleContent
 *
 * This was defined to be of type "complexDerivationType" in 9.2.0.1.
 * In 9.2.0.2, we change it to be of type "smplcontentType".
 */

   execute immediate 'update xdb.xdb$element e set
     e.xmldata.property.typename = xdb.xdb$qname(''01'', ''smplcontentType''),
     e.xmldata.property.sqltype  = ''XDB$SIMPLECONTENT_T'',
     e.xmldata.property.sqlname  = ''SIMPLECONT'',
     e.xmldata.property.type_ref = :1,
     e.xmldata.num_cols          = :2,
     e.xmldata.java_classname    = ''oracle.xdb.simpleContent'',
     e.xmldata.bean_classname    = ''oracle.xdb.simpleContent''
     where e.xmldata.property.name = ''simpleContent''
       and e.xmldata.property.parent_schema = :3'
   using smplcont_t_ref, smplcont_colcount, sch_ref;


/*-----------------------------------------------------------------------------
 *                               S T E P    6
 *---------------------------------------------------------------------------*/
/*
 * complexDerivation
 *
 * In 9.2.0.1 this was defined as a sequence of <choice>, <all> etc each
 * of which was marked unbounded.
 * In 9.2.0.2 we change this to a choice:
 *
 *      complexDerivation :=
 *                             -- annotation (0..1)
 *                            |
 *                            |             choice         (0..1)
 *                             -- choice -- sequence       (0..1)
 *                            |             group          (0..1)
 *          sequence ---------|             all            (0..1)
 *                            |             
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/

    select c.xmldata.sequence_kid into seq_ref
    from   xdb$complex_type c
    where  c.xmldata.parent_schema = sch_ref
    and    c.xmldata.name = 'complexDerivationType';

    select s.xmldata.elements into ellist
    from   xdb$sequence_model s
    where  sys_op_r2o(ref(s)) = sys_op_r2o(seq_ref);
    
    /* Construct choice of <group>, <choice>, <all>, <sequence> */
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(4);
    for i in 1..4 loop
      ellist2(i) := ellist(i+1);
    end loop;

    /* insert choice */
    choice_list := xdb.xdb$xmltype_ref_list_t();
    choice_list.extend(2);
    choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist2, null, '1');

    /* construct choice of <attribute>, <anyAttribute> and <attribGrp> */
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(3);
    for i in 1..3 loop
      ellist2(i) := ellist(i+5);
    end loop;

    /* insert choice of above */
    choice_list(2) := xdb.xdb$insertChoice(sch_ref, ellist2);

    /* build annotation element */
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(1);
    ellist2(1) := ellist(1);

    /* update sequence with <annotation> and the choice_list */
    execute immediate 'update xdb.xdb$sequence_model s set
      s.xmldata.elements = :1,
      s.xmldata.choice_kids = :2
      where s.xmldata.parent_schema = :3
        and sys_op_r2o(ref(s)) = (select sys_op_r2o(c.xmldata.sequence_kid)
                      from xdb$complex_type c
                      where c.xmldata.parent_schema = :4
                        and c.xmldata.name = ''complexDerivationType'')'
     using ellist2, choice_list, sch_ref, sch_ref;


/*-----------------------------------------------------------------------------
 *                               S T E P    7a
 *---------------------------------------------------------------------------*/
/*
 * complexType
 *
 * In 9.2.0.1, this was defined as a sequence of unbounded elements.
 * In 9.2.0.2, we change this to be choice (unb) of elements.
 *
 *       complexType :=
 *                             -- annotation (0..1)
 *                            |
 *                            |             simpleContent  (0..1)
 *                             -- choice -- complexContent (0..1)
 *                            |             group          (0..1)
 *          sequence ---------|             all            (0..1)
 *                            |             sequence       (0..1)
 *                            |             choice         (0..1)
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/

    select c.xmldata.sequence_kid into seq_ref
    from   xdb$complex_type c
    where  c.xmldata.parent_schema = sch_ref
    and    c.xmldata.name = 'complexType';

    select s.xmldata.elements into ellist
    from   xdb$sequence_model s
    where  sys_op_r2o(ref(s)) = sys_op_r2o(seq_ref);

   /* construct a choice of <simpleContent>, <complexContent>,
    * <group>, <all>, <seq>, <choice>
    */
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(6);
    for i in 1..6 loop
      ellist2(i) := ellist(i+1);
    end loop;

    /* Insert these as a choice */
    choice_list := xdb.xdb$xmltype_ref_list_t();
    choice_list.extend(2);
    choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist2, null, '1');

    /* Construct a choice of <attribute>, <attributeGroup> and
     * <anyAttribute>
     */
    ellist2 := xdb.xdb$xmltype_ref_list_t();
    ellist2.extend(3);
    for i in 1..3 loop
      ellist2(i) := ellist(i+7);
    end loop;

     /* Insert these as a choice */
     choice_list(2) := xdb.xdb$insertChoice(sch_ref, ellist2);

     ellist2 := xdb.xdb$xmltype_ref_list_t();
     ellist2.extend(2);
     ellist2(1) := ellist(1);
     ellist2(2) := ellist(11);

    /* update sequence with ellist2 and the choice_list */
    execute immediate 'update xdb.xdb$sequence_model s set
      s.xmldata.elements = :1,
      s.xmldata.choice_kids = :2
      where s.xmldata.parent_schema = :3
        and sys_op_r2o(ref(s)) = (select sys_op_r2o(c.xmldata.sequence_kid)
                      from xdb$complex_type c
                      where c.xmldata.parent_schema = :4
                        and c.xmldata.name = ''complexType'')'
     using ellist2, choice_list, sch_ref, sch_ref;

/*-----------------------------------------------------------------------------
 *                               S T E P    7b
 *---------------------------------------------------------------------------*/
/*
 * The attribute "simplecontent" in xdb$complex_t has been changed
 * from "xdb.xdb$content_t" to "xdb.xdb$simplecontent_t". For
 * migration, we add a new attribute called "simplecont" of "simplecontent_t"
 * and copy over the appropriate fields. Later during PD migration, we
 * handle this specially to migrate the PDs also.
 */
    /* set "id" and "annotation" */
    update xdb.xdb$complex_type c
      set c.xmldata.simplecont =
        xdb.xdb$simplecontent_t(c.xmldata.simplecontent.sys_xdbpd$, null, null,
                                c.xmldata.simplecontent.annotation,
                                c.xmldata.simplecontent.id)
    where c.xmldata.simplecontent is not null;

    /* copy over attributes of restriction */
    update xdb.xdb$complex_type c set c.xmldata.simplecont.restriction = 
     xdb.xdb$simplecont_res_t(c.xmldata.simplecontent.restriction.sys_xdbpd$,
                              c.xmldata.simplecontent.restriction.base,
                              c.xmldata.simplecontent.restriction.id,
                              null,
                              c.xmldata.simplecontent.restriction.attributes,
                              c.xmldata.simplecontent.restriction.any_attrs,
                              c.xmldata.simplecontent.restriction.attr_groups,
                              c.xmldata.simplecontent.restriction.annotation,
                              null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null)
    where c.xmldata.simplecontent is not null
      and c.xmldata.simplecontent.restriction is not null;

    /* copy over attributes of extension */
    update xdb.xdb$complex_type c set c.xmldata.simplecont.extension = 
     xdb.xdb$simplecont_ext_t(c.xmldata.simplecontent.extension.sys_xdbpd$,
                              c.xmldata.simplecontent.extension.base,
                              c.xmldata.simplecontent.extension.id,
                              c.xmldata.simplecontent.extension.attributes,
                              c.xmldata.simplecontent.extension.any_attrs,
                              c.xmldata.simplecontent.extension.attr_groups,
                              c.xmldata.simplecontent.extension.annotation)
    where c.xmldata.simplecontent is not null
      and c.xmldata.simplecontent.extension is not null;

    /* drop the old attribute now that we've copied the values */
    cur := dbms_sql.open_cursor;
    dbms_sql.parse(
      cur, 
      'alter type xdb.xdb$complex_t drop attribute (simplecontent) cascade',
      dbms_sql.native);
    rc := dbms_sql.execute(cur);
    dbms_sql.close_cursor(cur);

    update xdb.migr9202status set n = 100;
    commit;
 end if;

/*-----------------------------------------------------------------------------
 *                               S T E P    8
 *---------------------------------------------------------------------------*/
/*
 * schema
 *
 * In 9.2.0.1, we had a sequence of elements marked unbounded.
 * In 9.2.0.2, we change it to a choice unb.
 */

  select n into m from xdb.migr9202status for update;
  if (m < 110) then

    select c.xmldata.sequence_kid into seq_ref
    from   xdb$complex_type c
    where  c.xmldata.parent_schema = sch_ref
      and  c.xmldata.name = 'schema';

    select s.xmldata.elements into ellist
    from   xdb$sequence_model s
    where  sys_op_r2o(ref(s)) = sys_op_r2o(seq_ref);

    /* insert a choice */
    choice_list := xdb.xdb$xmltype_ref_list_t();
    choice_list.extend(1);
    choice_list(1) := xdb.xdb$insertChoice(sch_ref, ellist);

    execute immediate 'update xdb$complex_type c set
      c.xmldata.sequence_kid = null,
      c.xmldata.choice_kid   = :1
      where c.xmldata.parent_schema = :2
        and c.xmldata.name = ''schema'''
    using choice_list(1), sch_ref;

/*-----------------------------------------------------------------------------
 *                               S T E P    8
 *---------------------------------------------------------------------------*/
/* Since we've added 3 new complexTypes, we need to update the list
 * of global complexTypes. Similarly, the total propnums have to be
 * adjusted too.
 */
    select s.xmldata.complex_types into ellist
    from xdb$schema s
    where sys_op_r2o(ref(s)) = sys_op_r2o(sch_ref);
   
    /* assert ellist.count() == 26 */
    ellist.extend(3);
    ellist(27) := simplecontRes_t_ref;
    ellist(28) := simplecontExt_t_ref;
    ellist(29) := smplcont_t_ref;

    /* assert old num_props == 238 */
    execute immediate 'update xdb$schema s set
      s.xmldata.complex_types = :1,
      s.xmldata.num_props = 269
      where s.xmldata.schema_url = 
               ''http://xmlns.oracle.com/xdb/XDBSchema.xsd'''
    using ellist;
  

/*-----------------------------------------------------------------------------
 *                               S T E P    9
 *---------------------------------------------------------------------------*/
/* Set hidden flags for all REF values */

execute immediate 'update xdb$attribute a
  set a.xmldata.hidden = ''01''
  where a.xmldata.parent_schema = :1
    and a.xmldata.name in
       (''typeRef'', ''baseType'', ''parent_schema'', ''parentSchema'', 
        ''refRef'', ''headElementRef'')'
using sch_ref;

execute immediate 'update xdb$element e
  set e.xmldata.property.hidden = ''01''
  where e.xmldata.property.parent_schema = :1
    and e.xmldata.property.name in
       (''typeRef'', ''subtypeRef'', ''substitutionGroupRef'')'
using sch_ref;

/*-----------------------------------------------------------------------------
 *                               S T E P    1 0
 *---------------------------------------------------------------------------*/

-- Update the four FACET attributes to include an 'id' attribute
-- Since the schema for schemas has no positional descriptors, we need
-- only to modify the VARRAY.

  select c.xmldata.attributes into attlist 
    from xdb.xdb$complex_type c
    where c.xmldata.name='facet' and c.xmldata.parent_schema = sch_ref
    for update;
  attlist.extend();
  attlist(3) := xdb.xdb$insertAttr(sch_ref, PN_FACET_ID, 'id',
                               TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);
  execute immediate 'update xdb.xdb$complex_type c 
      set c.xmldata.attributes = :1
      where c.xmldata.name=''facet'' and c.xmldata.parent_schema = :2'
  using attlist, sch_ref;

  select c.xmldata.attributes into attlist 
    from xdb.xdb$complex_type c
    where c.xmldata.name='numFacet' and c.xmldata.parent_schema = sch_ref
    for update;
  attlist.extend();
  attlist(3) := xdb.xdb$insertAttr(sch_ref, PN_NUMFACET_ID, 'id',
                               TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

  execute immediate 'update xdb.xdb$complex_type c 
      set c.xmldata.attributes = :1
      where c.xmldata.name=''numFacet'' and c.xmldata.parent_schema = :2'
  using attlist, sch_ref;

  select c.xmldata.attributes into attlist 
    from xdb.xdb$complex_type c
    where c.xmldata.name='timeFacet' and c.xmldata.parent_schema = sch_ref
    for update;
  attlist.extend();
  attlist(3) := xdb.xdb$insertAttr(sch_ref, PN_TIMEFACET_ID, 'id',
                               TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

  execute immediate 'update xdb.xdb$complex_type c 
      set c.xmldata.attributes = :1
      where c.xmldata.name=''timeFacet'' and c.xmldata.parent_schema = :2'
  using attlist, sch_ref;

  select c.xmldata.attributes into attlist 
    from xdb.xdb$complex_type c
    where c.xmldata.name='whiteSpace' and c.xmldata.parent_schema = sch_ref
    for update;
  attlist.extend();
  attlist(3) := xdb.xdb$insertAttr(sch_ref, PN_WHITESPACE_ID,'id',
                               TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

  execute immediate 'update xdb.xdb$complex_type c 
      set c.xmldata.attributes = :1
      where c.xmldata.name=''whiteSpace'' and c.xmldata.parent_schema = :2'
  using attlist, sch_ref;

/*-----------------------------------------------------------------------------
 *                               S T E P    1 1
 *---------------------------------------------------------------------------*/
/* The binary element has a memType of DTYBLOB */
  execute immediate
  'update xdb.xdb$element e set e.xmldata.property.mem_type_code = :1
     where e.xmldata.property.prop_number = 83' using T_BLOB;

/* Set system_qmtp to TRUE for 'baseProp' */
  execute immediate
  'update xdb.xdb$attribute e set e.xmldata.system = ''01'' where
     e.xmldata.name=''baseProp'' and
     e.xmldata.parent_schema = :1'
  using sch_ref;

  update xdb.migr9202status set n = 110;
  commit;
 end if;


end;
/
show errors;

begin
  xdb.rootschemamigrate();
end;
/


-- Resource schema

-- Function to invert the STICKYREF flag (0x01)
-- Highest used flag bit is 0x20, so we stop the mapping at 0x3F.
create or replace function xdb.xdb$invertstickyflag(
  r RAW
)
return RAW is
  s RAW(1);
begin
case r
  when '00' then s := '01';
  when '01' then s := '00';
  when '02' then s := '03';
  when '03' then s := '02';
  when '04' then s := '05';
  when '05' then s := '04';
  when '06' then s := '07';
  when '07' then s := '06';
  when '08' then s := '09';
  when '09' then s := '08';
  when '0A' then s := '0B';
  when '0B' then s := '0A';
  when '0C' then s := '0D';
  when '0D' then s := '0C';
  when '0E' then s := '0F';
  when '0F' then s := '0E';
  when '10' then s := '11';
  when '11' then s := '10';
  when '12' then s := '13';
  when '13' then s := '12';
  when '14' then s := '15';
  when '15' then s := '14';
  when '16' then s := '17';
  when '17' then s := '16';
  when '18' then s := '19';
  when '19' then s := '18';
  when '1A' then s := '1B';
  when '1B' then s := '1A';
  when '1C' then s := '1D';
  when '1D' then s := '1C';
  when '1E' then s := '1F';
  when '1F' then s := '1E';
  when '20' then s := '21';
  when '21' then s := '20';
  when '22' then s := '23';
  when '23' then s := '22';
  when '24' then s := '25';
  when '25' then s := '24';
  when '26' then s := '27';
  when '27' then s := '26';
  when '28' then s := '29';
  when '29' then s := '28';
  when '2A' then s := '2B';
  when '2B' then s := '2A';
  when '2C' then s := '2D';
  when '2D' then s := '2C';
  when '2E' then s := '2F';
  when '2F' then s := '2E';
  when '30' then s := '31';
  when '31' then s := '30';
  when '32' then s := '33';
  when '33' then s := '32';
  when '34' then s := '35';
  when '35' then s := '34';
  when '36' then s := '37';
  when '37' then s := '36';
  when '38' then s := '39';
  when '39' then s := '38';
  when '3A' then s := '3B';
  when '3B' then s := '3A';
  when '3C' then s := '3D';
  when '3D' then s := '3C';
  when '3E' then s := '3F';
  when '3F' then s := '3E';
  else s := r;
end case;
return s;
end;
/

declare

  T_XOB                   CONSTANT RAW(2)  := '102';
  PN_RES_CONTENTS_ANY     CONSTANT INTEGER := 736;
  PN_RES_PARENTS          CONSTANT INTEGER := 741;
  PN_RES_STICKYREF        CONSTANT INTEGER := 743;
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 43;
  TRUE         CONSTANT RAW(1) := '1';
  FALSE        CONSTANT RAW(1) := '0';
  TR_BOOLEAN    xdb.xdb$qname := xdb.xdb$qname('00', 'boolean');
  T_BOOLEAN     RAW(2) :='fc'; /* DTYBOL */
  JT_BOOLEAN     xdb.xdb$javatype := xdb.xdb$javatype('8');
  TRANSIENT_GENERATED  CONSTANT xdb.xdb$transientChoice := 
                                        xdb.xdb$transientChoice('01');

  attlist              xdb.xdb$xmltype_ref_list_t;
  sch_ref              REF SYS.XMLTYPE;
  m                    integer;
begin

  select n into m from xdb.migr9202status for update;
  if (m < 200) then

-- get the Resource schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
    s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

-- the stickyref flag must be inverted (called "plainref" in 9.2.0.1)
  update xdb.xdb$resource e
    set e.xmldata.flags = xdb.xdb$invertstickyflag(e.xmldata.flags);

-- the default language for resources is now "en-US"
  update xdb.xdb$resource e
    set e.xmldata.language = 'en-US' where
    e.xmldata.language = 'us english' OR
    e.xmldata.language = 'en';

-- the 'utf-8' character set should read 'UTF-8'
  update xdb.xdb$resource e
    set e.xmldata.charset = 'UTF-8' where
    e.xmldata.charset = 'utf-8';

-- the root resource should have refcount zero
  update xdb.xdb$resource e set e.xmldata.refcount='00' 
    where e.rowid=(select resource_root from xdb.xdb$root_info);

-- the any element 'ContentsAny' now has memType QMXT_XOB
  update xdb.xdb$any a set a.xmldata.property.mem_type_code = T_XOB
    where a.xmldata.property.prop_number = PN_RES_CONTENTS_ANY;

-- 'Parents' should be SqlInline=TRUE
  update xdb.xdb$element e set e.xmldata.sql_inline = TRUE
    where e.xmldata.property.prop_number = PN_RES_PARENTS;

-- NSB XML docs marked as binary should now have no schema
  update xdb.xdb$resource e set 
    e.xmldata.elnum = NULL, e.xmldata.schoid = NULL 
    where e.xmldata.elnum = 83 and e.xmldata.contype = 'text/xml';

-- Add the StickyRef attribute to the Resource complexType
  select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
    c.xmldata.name = 'ResourceType' and
    c.xmldata.parent_schema = sch_ref;
  attlist.extend();
  attlist(8) := xdb.xdb$insertAttr(sch_ref,
                               PN_RES_STICKYREF, 'StickyRef',
                               TR_BOOLEAN, 1, 1,
                               '1', T_BOOLEAN, FALSE,
                               FALSE, FALSE,
                               null, null, null,
                               JT_BOOLEAN, 'false', null,
                               null, null, null, null, null, FALSE,
                               TRANSIENT_GENERATED, FALSE);
  update xdb.xdb$complex_type c set
    c.xmldata.attributes = attlist where
    c.xmldata.name = 'ResourceType' and
    c.xmldata.parent_schema = sch_ref;

  update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;

  update xdb.migr9202status set n = 200;
  commit;
 end if;

end;
/
show errors

-- Cleanup
drop function xdb.xdb$invertstickyflag;


-- Config schema

-- GRANT SELECT ON xdb.xdb$config TO PUBLIC;

declare
  cur             INTEGER;
  rc              INTEGER;
  owner_var_sc    VARCHAR2(30);
  owner_var_fc    VARCHAR2(30);
  owner_var_hc    VARCHAR2(30);
  type_var_sc     VARCHAR2(30);
  type_var_fc     VARCHAR2(30);
  type_var_hc     VARCHAR2(30);
  colname_acs     VARCHAR2(100);
  colname_bs      VARCHAR2(100);
  colname_rvcs    VARCHAR2(100);
  simple_ref      REF SYS.XMLTYPE;
  elem_ref_acs    REF SYS.XMLTYPE;
  elem_ref_rvcs   REF SYS.XMLTYPE;
  elem_ref_csic   REF SYS.XMLTYPE;
  elem_ref_bs     REF SYS.XMLTYPE;
  elem_ref_duc    REF SYS.XMLTYPE;
  elem_arr        XDB.XDB$XMLTYPE_REF_LIST_T;
  elem_data       XDB.XDB$ELEMENT_T;
  elem_extra      SYS.XMLTYPEEXTRA;
  m               integer;
begin

-- get the 'sysconfig' object type
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'select e.xmldata.property.sqlschema, e.xmldata.property.sqltype 
       from xdb.xdb$element e, xdb.xdb$schema s 
       where e.xmldata.property.name=''sysconfig'' and
       e.xmldata.property.parent_schema = ref(s) and
       s.xmldata.schema_url=''http://xmlns.oracle.com/xdb/xdbconfig.xsd''',
    dbms_sql.native);
  dbms_sql.define_column(cur, 1, owner_var_sc, 30);
  dbms_sql.define_column(cur, 2, type_var_sc, 30);
  rc := dbms_sql.execute(cur);
  IF dbms_sql.fetch_rows(cur) > 0 THEN
    dbms_sql.column_value(cur, 1, owner_var_sc);
    dbms_sql.column_value(cur, 2, type_var_sc);
  ELSE
    dbms_sql.close_cursor(cur);
    RETURN;
  END IF;
  dbms_sql.close_cursor(cur);

-- get the 'ftpconfig' object type
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'select e.xmldata.property.sqlschema, e.xmldata.property.sqltype 
       from xdb.xdb$element e, xdb.xdb$schema s 
       where e.xmldata.property.name=''ftpconfig'' and
       e.xmldata.property.parent_schema = ref(s) and
       s.xmldata.schema_url=''http://xmlns.oracle.com/xdb/xdbconfig.xsd''',
    dbms_sql.native);
  dbms_sql.define_column(cur, 1, owner_var_fc, 30);
  dbms_sql.define_column(cur, 2, type_var_fc, 30);
  rc := dbms_sql.execute(cur);
  IF dbms_sql.fetch_rows(cur) > 0 THEN
    dbms_sql.column_value(cur, 1, owner_var_fc);
    dbms_sql.column_value(cur, 2, type_var_fc);
  ELSE
    dbms_sql.close_cursor(cur);
    RETURN;
  END IF;
  dbms_sql.close_cursor(cur);

-- get the 'httpconfig' object type
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'select e.xmldata.property.sqlschema, e.xmldata.property.sqltype 
       from xdb.xdb$element e, xdb.xdb$schema s 
       where e.xmldata.property.name=''httpconfig'' and
       e.xmldata.property.parent_schema = ref(s) and
       s.xmldata.schema_url=''http://xmlns.oracle.com/xdb/xdbconfig.xsd''',
    dbms_sql.native);
  dbms_sql.define_column(cur, 1, owner_var_hc, 30);
  dbms_sql.define_column(cur, 2, type_var_hc, 30);
  rc := dbms_sql.execute(cur);
  IF dbms_sql.fetch_rows(cur) > 0 THEN
    dbms_sql.column_value(cur, 1, owner_var_hc);
    dbms_sql.column_value(cur, 2, type_var_hc);
  ELSE
    dbms_sql.close_cursor(cur);
    RETURN;
  END IF;
  dbms_sql.close_cursor(cur);

-- Add the 'resource-view-cache-size' element to the 'sysconfig' object type
 select n into m from xdb.migr9202status for update;
 if (m < 300) then
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'alter type ' || dbms_assert.enquote_name(owner_var_sc, false) || '.' || 
    dbms_assert.enquote_name(type_var_sc, false) ||
    ' add attribute ("resource-view-cache-size" NUMBER(10)) cascade',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  update xdb.migr9202status set n = 300;
  commit;
 end if;

-- Add the 'acl-cache-size' element to the 'sysconfig' object type
 select n into m from xdb.migr9202status for update;
 if (m < 310) then
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'alter type ' || dbms_assert.enquote_name(owner_var_sc, false) || '.' || 
    dbms_assert.enquote_name(type_var_sc, false) ||
    ' add attribute ("acl-cache-size" NUMBER(10)) cascade',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  update xdb.migr9202status set n = 310;
  commit;
 end if;

-- Add the 'case-sensitive-index-clause' element to the 'sysconfig' object type
 select n into m from xdb.migr9202status for update;
 if (m < 320) then
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur,
    'alter type ' || dbms_assert.enquote_name(owner_var_sc, false) || '.' || 
    dbms_assert.enquote_name(type_var_sc, false) ||
    ' add attribute ("case-sensitive-index-clause" VARCHAR2(4000)) cascade',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  update xdb.migr9202status set n = 320;
  commit;
 end if;

-- Add the 'buffer-size' element to the 'ftpconfig' object type
 select n into m from xdb.migr9202status for update;
 if (m < 330) then
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'alter type ' || dbms_assert.enquote_name(owner_var_fc, false) || '.' || 
    dbms_assert.enquote_name(type_var_fc, false) ||
    ' add attribute ("buffer-size" NUMBER(10)) cascade',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  update xdb.migr9202status set n = 330;
  commit;
 end if;

-- Add the 'default-url-charset' element to the 'httpconfig' object type
 select n into m from xdb.migr9202status for update;
 if (m < 340) then
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'alter type ' || dbms_assert.enquote_name(owner_var_hc, false) || '.' || 
    dbms_assert.enquote_name(type_var_hc, false) ||
    ' add attribute ("default-url-charset" VARCHAR2(4000)) cascade',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  update xdb.migr9202status set n = 340;
  commit;
 end if;

 select n into m from xdb.migr9202status for update;
 if (m < 350) then
-- Insert the new element definitions into XDB.XDB$ELEMENT.
-- WATCH
-- This will change if the PD format changes or if XDB$ELEMENT_T changes.
-- It can be obtained by selecting 'resource-view-cache-size',
-- 'acl-cache-size', etc. from XDB.XDB$ELEMENT in a 9.2.0.2 DB.
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
  (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
   '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
   '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
   SYS.XMLTYPEPI('523030')),
   XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030000000004050F03150B0C0706272928'),
   (select ref(s) from xdb.xdb$schema s where 
     s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
    xdb.xdb$propnum_seq.nextval,
    'resource-view-cache-size', XDB.XDB$QNAME('00', 'unsignedInt'), '04',
    '44', '00', '00', NULL, 'resource-view-cache-size', 'NUMBER', NULL,
    NULL, '1048576', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, 
    NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00',
    '01', '01', '01', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, 0, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_rvcs;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
  (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
   '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
   '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
    SYS.XMLTYPEPI('523030')),
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030000000004050F03150B0C0706272928'),
   (select ref(s) from xdb.xdb$schema s where 
     s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
    xdb.xdb$propnum_seq.nextval,
  'acl-cache-size', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00',
  '00', NULL, 'acl-cache-size', 'NUMBER', NULL, NULL, '32', NULL,
  NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, 
  NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01',
  '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL,
  '00', '00', NULL, NULL, NULL, NULL, NULL, NULL))
    returning ref(e) into elem_ref_acs;

   insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values
   (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
   '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
   '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'),
   SYS.XMLTYPEPI('523030')),
   XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('1302000001'),
    (select ref(s) from xdb.xdb$schema s where 
      s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
   NULL, '00', 
   XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('33000302020002020520314B422002040520314D4220110809'), 
   NULL, XDB.XDB$QNAME('00', 'unsignedInt'), NULL, NULL, NULL,
   NULL, NULL, NULL, NULL, NULL, NULL, 
   XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('1302000001'), NULL, '1024', 
  '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('1302000001'), 
   NULL, '1048496', '00', NULL), NULL, NULL, NULL, NULL, NULL, NULL),
   NULL, NULL, NULL, NULL))
  returning ref(s) into simple_ref;

   insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
   (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
   '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364',
   '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), 
   SYS.XMLTYPEPI('523030')),
   XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83DA982000800300000000040F0103150B0C0706272928'),
    (select ref(s) from xdb.xdb$schema s where 
      s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
    xdb.xdb$propnum_seq.nextval,
   'buffer-size', NULL, '04', '44', '00', '00', NULL, 'buffer-size',
   'NUMBER', NULL, NULL, '8192',
   simple_ref, simple_ref,
   NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'),
   NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '00', NULL,
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '00', 
   NULL, NULL, NULL, NULL, NULL, NULL))
     returning ref(e) into elem_ref_bs;

  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values  
  (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', 
   '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', 
   '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), 
   SYS.XMLTYPEPI('523030')),
   XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030400000004053203150B0C07272928'), 
    (select ref(s) from xdb.xdb$schema s where
      s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
    xdb.xdb$propnum_seq.nextval,
  'case-sensitive-index-clause', XDB.XDB$QNAME('00', 'string'), NULL, '01', 
  '00', '00', NULL, 'case-sensitive-index-clause', 'VARCHAR2', NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',
  NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01',
  '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 
  '00', '00', NULL, NULL, NULL, NULL, NULL, NULL))
     returning ref(e) into elem_ref_csic;

-- New 'httpconfig' child 'default-url-charset' is almost identical to 
-- the existing child 'servlet-realm'.  We change only the property number,
-- XML name, and SQL name.
  select e.xmlextra into elem_extra from xdb.xdb$element e where
    e.xmldata.property.parent_schema = 
      (select ref(s) from xdb.xdb$schema s where 
        s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd') and
    e.xmldata.property.name = 'servlet-realm';
  select e.xmldata into elem_data from xdb.xdb$element e where
    e.xmldata.property.parent_schema = 
      (select ref(s) from xdb.xdb$schema s where 
        s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd') and
    e.xmldata.property.name = 'servlet-realm';
  insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values
    (elem_extra, elem_data)
     returning ref(e) into elem_ref_duc;
  update xdb.xdb$element e set
    e.xmldata.property.prop_number = xdb.xdb$propnum_seq.nextval,
    e.xmldata.property.name = 'default-url-charset',
    e.xmldata.property.sqlname = 'default-url-charset' 
    where ref(e) = elem_ref_duc;

-- Modify the 'acl-max-age' param to be an 'unsignedInt'.
  update xdb.xdb$element e set e.xmldata = 
    XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030000000004050F03150B0C0706272928'),
    (select ref(s) from xdb.xdb$schema s where 
      s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
 (select p.xmldata.property.prop_number 
     from xdb.xdb$element p, xdb.xdb$schema s where 
   p.xmldata.property.parent_schema = ref(s) and 
   p.xmldata.property.name = 'acl-max-age' and
   s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'),
  'acl-max-age', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00',
   NULL, 'acl-max-age', 'NUMBER', NULL, NULL, '1000', NULL, NULL, NULL, NULL,
   NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL,
   '00', NULL, NULL, '00', '01', '01', '01', '00', NULL, NULL, NULL, NULL,
   NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '00', NULL, NULL, 
  NULL, NULL, NULL, NULL)
  where
    e.xmldata.property.prop_number = (select p.xmldata.property.prop_number 
     from xdb.xdb$element p, xdb.xdb$schema s where 
   p.xmldata.property.parent_schema = ref(s) and 
   p.xmldata.property.name = 'acl-max-age' and
   s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd');


-- Get the VARRAY of element REFs in the sysconfig sequence
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='sysconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'))
    for update;

-- Add the new elements to the sysconfig sequence
-- WATCH
-- This depends on how many elements are being added to the 'sysconfig'
-- sequence.  Currently we are adding 'acl-cache-size' in the 2nd position
-- followed by 'resource-view-cache-size' in the 12th position, followed
-- by 'case-sensitive-index-clause' in the 13th position.

   elem_arr.extend(3);

   for i in reverse 3..elem_arr.last loop
     elem_arr(i) := elem_arr(i - 1);
   end loop;
   elem_arr(2) := elem_ref_acs;

   for i in reverse 13..elem_arr.last loop
     elem_arr(i) := elem_arr(i - 1);
   end loop;
   elem_arr(12) := elem_ref_rvcs;

   for i in reverse 14..elem_arr.last loop
     elem_arr(i) := elem_arr(i - 1);
   end loop;
   elem_arr(13) := elem_ref_csic;

-- Update the VARRAY of element refs in the sysconfig sequence and fix
-- the PD to reflect the added entries.
-- WATCH
-- This will change if the PD format changes.  The PD can be obtained by
-- selecting it from the corresponding row in a 9.2.0.2 DB.
-- This will also change if the number of entries in 'elem_arr' changes.
  update xdb.xdb$sequence_model m
   set m.xmldata.elements = elem_arr, 
       m.xmldata.SYS_XDBPD$ = XDB.XDB$RAW_LIST_T('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081800E')
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='sysconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'));

-- Get the VARRAY of element REFs in the ftpconfig sequence
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='ftpconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'))
    for update;

-- Add the new elements to the ftpconfig sequence
-- WATCH
-- This depends on how many elements are being added to the 'ftpconfig'
-- sequence.  Currently we are adding 'buffer-size' in the last position.
-- (So no PD changes are required in the config instance!)
   elem_arr.extend();
   elem_arr(elem_arr.last) := elem_ref_bs;

-- Update the VARRAY of element refs in the ftpconfig sequence and fix
-- the PD to reflect the added entries.
-- WATCH
-- This will change if the PD format changes.  The PD can be obtained by
-- selecting it from the corresponding row in a 9.2.0.2 DB.
  update xdb.xdb$sequence_model m
   set m.xmldata.elements = elem_arr, 
       m.xmldata.SYS_XDBPD$ = XDB.XDB$RAW_LIST_T('2302000000818007')
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='ftpconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'));

-- Get the VARRAY of element REFs in the httpconfig sequence
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='httpconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'))
    for update;

-- Add the new elements to the ftpconfig sequence
-- WATCH
-- This depends on how many elements are being added to the 'httpconfig'
-- sequence.  Currently we are adding 'default-url-charset' in the 
-- last position. (So no PD changes are required in the config instance!)
   elem_arr.extend();
   elem_arr(elem_arr.last) := elem_ref_duc;

-- Update the VARRAY of element refs in the httpconfig sequence and fix
-- the PD to reflect the added entries.
-- WATCH
-- This will change if the PD format changes.  The PD can be obtained by
-- selecting it from the corresponding row in a 9.2.0.2 DB.
  update xdb.xdb$sequence_model m
   set m.xmldata.elements = elem_arr, 
       m.xmldata.SYS_XDBPD$ = XDB.XDB$RAW_LIST_T('230200000081800D')
   where ref(m) = 
    (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
      where ref(c)=
        (select e.xmldata.cplx_type_decl 
          from xdb.xdb$element e, xdb.xdb$schema s 
          where e.xmldata.property.name='httpconfig' and
          e.xmldata.property.parent_schema = ref(s) and
          s.xmldata.schema_url='http://xmlns.oracle.com/xdb/xdbconfig.xsd'));

-- Now populate the new columns in the XDB$CONFIG table
  select c.name into colname_rvcs from col$ c, obj$ o, attrcol$ a where
    c.obj#=o.obj# and 
    o.name='XDB$CONFIG' and
    o.owner#=(select user# from user$ where name='XDB') and
    c.intcol#=a.intcol# and
    a.obj#=o.obj# and
    a.name='"XMLDATA"."sysconfig"."resource-view-cache-size"';
  select c.name into colname_acs from col$ c, obj$ o, attrcol$ a where
    c.obj#=o.obj# and 
    o.name='XDB$CONFIG' and
    o.owner#=(select user# from user$ where name='XDB') and
    c.intcol#=a.intcol# and
    a.obj#=o.obj# and
    a.name='"XMLDATA"."sysconfig"."acl-cache-size"';
 select c.name into colname_bs from col$ c, obj$ o, attrcol$ a where
    c.obj#=o.obj# and 
    o.name='XDB$CONFIG' and
    o.owner#=(select user# from user$ where name='XDB') and
    c.intcol#=a.intcol# and
    a.obj#=o.obj# and
    a.name='"XMLDATA"."sysconfig"."protocolconfig"."ftpconfig"."buffer-size"';

  cur := dbms_sql.open_cursor;
  dbms_xdbz.disable_hierarchy('XDB', 'XDB$CONFIG');
  dbms_sql.parse(
    cur, 
    'update xdb.xdb$config c set c.' || 
     DBMS_ASSERT.ENQUOTE_NAME(colname_rvcs, FALSE) || ' = 1048576, c.' ||
     DBMS_ASSERT.ENQUOTE_NAME(colname_acs, FALSE)  || ' = 32, c.' || 
     DBMS_ASSERT.ENQUOTE_NAME(colname_bs, FALSE)   || ' = 8192',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);

  update xdb.migr9202status set n = 350;
  commit;
 end if;
end;
/
show errors


-- ACL Schema

declare

  elref           REF SYS.XMLTYPE;
  anyref          REF SYS.XMLTYPE;
  choice_ref      REF SYS.XMLTYPE;
  ellist          XDB.XDB$XMLTYPE_REF_LIST_T; 
  anylist         XDB.XDB$XMLTYPE_REF_LIST_T; 
  m               integer;

begin

 select n into m from xdb.migr9202status for update;
 if (m < 400) then

  select m.xmldata.anys into anylist
   from xdb.xdb$sequence_model m
   where ref(m) = (select c.xmldata.sequence_kid from xdb.xdb$complex_type c
  where ref(c) = 
  (select e.xmldata.property.type_ref from xdb.xdb$element e
   where e.xmldata.property.name = 'privilege' and
         e.xmldata.property.parent_schema = 
         (select ref(s) from xdb.xdb$schema s where 
          s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd')));

  select m.xmldata.elements into ellist
   from xdb.xdb$sequence_model m
   where ref(m) = (select c.xmldata.sequence_kid from xdb.xdb$complex_type c
  where ref(c) = 
  (select e.xmldata.property.type_ref from xdb.xdb$element e
   where e.xmldata.property.name = 'privilege' and
         e.xmldata.property.parent_schema = 
         (select ref(s) from xdb.xdb$schema s where 
          s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd')));
    
  anyref := anylist(1);
  elref := ellist(1);

  insert into xdb.xdb$choice_model h (h.xmlextra, h.xmldata) values
    (SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61',
      '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462',
      '50000678646261636C0023687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F61636C2E787364'), 
       SYS.XMLTYPEPI('523030')),
   XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('23120101000202112048494444454E20454C454D454E545320080401'), 
    (select ref(s) from xdb.xdb$schema s where 
      s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd'),
    0, 'unbounded', 
   ellist,
   NULL, NULL, 
   anylist,
    NULL, NULL, NULL))
   returning ref(h) into choice_ref;

  update xdb.xdb$complex_type c set c.xmldata = 
    XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330400060000021112'), 
    (select ref(s) from xdb.xdb$schema s where 
      s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd'),
   NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL,
   choice_ref,
  NULL, NULL, NULL, NULL, 'XDB$PRIV_T', 'XDB', '00', NULL, NULL, NULL)
  where ref(c) = 
  (select e.xmldata.property.type_ref from XDB.xdb$element e
   where e.xmldata.property.name = 'privilege' and
         e.xmldata.property.parent_schema = 
         (select ref(s) from xdb.xdb$schema s where 
          s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd'));

  update xdb.migr9202status set n = 400;
  commit;
 end if;
end;
/
show errors;


Rem Now continue upgrade of 9.2.0.2 bootstrap schemas
@@xdbs9202.sql
