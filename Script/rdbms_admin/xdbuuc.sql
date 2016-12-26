Rem
Rem $Header: rdbms/admin/xdbuuc.sql /main/9 2010/05/05 15:12:00 badeoti Exp $
Rem
Rem xdbuuc.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbuuc.sql - XDB upgrade utility functions
Rem
Rem    DESCRIPTION
Rem      Functions useful during XDB upgrade. Culled from various files
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/19/10 - Bug 9591348
Rem    badeoti     07/23/09 - compile any_t
Rem    sanagara    12/01/08 - 7284151: compile types
Rem    mrafiq      05/08/06 - add choice removal to delete_elem_by_ref 
Rem    rpang       12/02/04 - Add type_name, find_element, find_child...
Rem    rpang       10/07/04 - cascade delete_elem_by_ref
Rem    spannala    05/18/04 - more utility procedures 
Rem    abagrawa    05/10/04 - Add xdb$insertElement 
Rem    thbaby      04/26/04 - thbaby_https
Rem    spannala    03/03/04 - adding alt_type_drop_attribute 
Rem    spannala    01/30/04 - Created
Rem

--
-- The following type compilations are necessary due to the fix
-- for bug 7284151. These types are directly depended on by tables
-- referenced in the pl/sql code that follows below. Due to changes
-- introduced by the fix for bug 7284151, the pl/sql code may get
-- ORA-942 errors and fail to compile if these types are invalid
-- (which they are likely to be at this stage of the upgrade)
--
alter type XDB.XDB$SCHEMA_T compile;
alter type XDB.XDB$ELEMENT_T compile;
alter type XDB.XDB$SIMPLE_T compile;
alter type XDB.XDB$COMPLEX_T compile;
alter type XDB.XDB$ANY_T compile;

-- UTILITY FUNCTIONS FOR UPGRADE
create or replace procedure element_type(schema_url IN varchar2, element_name IN
    varchar2, type_owner out varchar2, type_name out varchar2) as
qry varchar2(4000);
cur integer;
rc integer;
begin
  qry   := 
    'select e.xmldata.property.sqlschema, e.xmldata.property.sqltype ' ||
    'from xdb.xdb$element e, xdb.xdb$schema s '                        ||
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

CREATE OR REPLACE PROCEDURE ALT_TYPE_DROP_ATTRIBUTE(type_owner  IN varchar2,
                                                    type_name   IN varchar2,
                                                    attr_string IN varchar2) as
  sqlstr varchar2(1000);
BEGIN
  sqlstr := 'ALTER TYPE ' || 
            dbms_assert.enquote_name(type_owner, false) || '.' || 
            dbms_assert.enquote_name(type_name, false) ||
            ' DROP ATTRIBUTE (' || attr_string || ') CASCADE';
  EXECUTE IMMEDIATE sqlstr;
END;
/

show errors;

create or replace procedure alt_type_add_attribute(type_owner  IN varchar2,
                                                   type_name   IN varchar2, 
                                                   attr_string IN varchar2) as
  sqlstr varchar2(1000);
BEGIN
  sqlstr := 'ALTER TYPE ' || 
            dbms_assert.enquote_name(type_owner, false) || '.' || 
            dbms_assert.enquote_name(type_name, false) ||
            ' ADD ATTRIBUTE (' || attr_string || ') CASCADE';
  EXECUTE IMMEDIATE sqlstr;
END;
/

show errors;

create or replace function get_upgrade_status return integer as
m integer;
begin
  select n into m from xdb.migr9202status;
  return m;
end;
/

show errors;

create or replace procedure set_upgrade_status(m integer, docommit boolean) as
begin
  update xdb.migr9202status set n = m;
  if docommit then
    commit;
  end if;
end;
/

show errors;

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

-- This procedure executes the statement given by stmt only if the
-- current value of the migr9202status is GREATER than the given
-- value. It then updates the status and commits everything atomically
-- The statement CAN be a ddl.
CREATE OR REPLACE PROCEDURE exec_stmt_chg_status(status IN number,
                                                 stmt IN varchar2) as
  m integer;
BEGIN
  select n into m from xdb.migr9202status;
  IF m > status THEN
    update xdb.migr9202status set n  = status;
    execute immediate stmt;
    commit;
  END IF;
END;
/

show errors;

-- same function as above except it deletes the schema instead of
-- executing a statement.
CREATE OR REPLACE PROCEDURE drop_schema_chg_status(status IN number,
                                                   schurl IN varchar2) as
  m integer;
BEGIN
  select n into m from xdb.migr9202status;
  IF m > status THEN
    update xdb.migr9202status set n  = status;
    select count(*) into m from xdb.xdb$schema s where
         s.xmldata.schema_url = schurl;
    IF m > 0 THEN
      dbms_xmlschema.deleteschema(schurl, dbms_xmlschema.delete_cascade);
    END IF;
    commit;
  END IF;
END;
/

show errors;

CREATE OR REPLACE PROCEDURE DELETE_ELEM_BY_REF (eltref ref xmltype,
                                                delete_cascade boolean
                                                  default false) as
  type_name    VARCHAR2(30);
  type_ref     REF XMLTYPE;
  seq_ref      REF XMLTYPE;
  choice_ref   REF XMLTYPE;
  elem_arr     XDB.XDB$XMLTYPE_REF_LIST_T;
  choice_list  XDB.XDB$XMLTYPE_REF_LIST_T;
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
            returning m.xmldata.elements, m.xmldata.choice_kids
             into elem_arr, choice_list;
          FOR i IN 1..elem_arr.last LOOP
            delete_elem_by_ref(elem_arr(i), true);
          END LOOP;
          IF choice_list IS NOT NULL THEN
            FOR i IN 1..choice_list.last LOOP
              choice_ref := choice_list(i);
              delete from xdb.xdb$choice_model m where ref(m) = choice_ref
                returning m.xmldata.elements into elem_arr;
              FOR i IN 1..elem_arr.last LOOP
                delete_elem_by_ref(elem_arr(i), true);
              END LOOP;
            END LOOP;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;

END;
/

show errors;

-- Find child element in a sequence by name
create or replace function find_child(seq   xdb.xdb$xmltype_ref_list_t,
                                      child varchar2) return ref xmltype
as
  r  ref xmltype;
begin
  select ref(e) into r from xdb.xdb$element e
   where ref(e) in (select * from table(seq)) and
         e.xmldata.property.name = child;
  return r;
exception
  when no_data_found then
    return null;
end;
/

show errors;

create or replace function find_child_with_model(parent         ref xmltype,
                                                 child          varchar2,
                                                 model      out ref xmltype,
                                                 model_type out varchar2)
  return ref xmltype
as
  r        ref xmltype;
  elems    xdb.xdb$xmltype_ref_list_t; -- child elements
  choices  xdb.xdb$xmltype_ref_list_t; -- choice elements
begin

  -- Find child element under parent's elements and choices
  select ref(m), m.xmldata.elements, m.xmldata.choice_kids
    into model, elems, choices
    from xdb.xdb$element e, xdb.xdb$complex_type c, xdb.xdb$sequence_model m
   where ref(e) = parent and
         ref(c) in (e.xmldata.cplx_type_decl,
                    e.xmldata.property.type_ref) and
         ref(m) = c.xmldata.sequence_kid;
  r := find_child(elems, child);
  if r is not null then
    model_type := 'xdb$sequence_model';
    return r;
  end if;

  if choices is not null then
    for i in 1..choices.count loop
      select ref(m), m.xmldata.elements
        into model, elems
        from xdb.xdb$choice_model m
       where ref(m) = choices(i);
      r := find_child(elems, child);
      if r is not null then
        model_type := 'xdb$choice_model';
        return r;
      end if; 
    end loop;
  end if;

  return null;
end;
/

show errors;

-- Find child element under a parent element
create or replace function find_element(schema_url  varchar2,
                                        xpath       varchar2,
                                        parent      ref xmltype default null)
  return ref xmltype
as

  r          ref xmltype;
  elems      xdb.xdb$xmltype_ref_list_t; -- child elements
  sep        pls_integer;                -- '/' separator
  child      varchar2(80);               -- child element name
  model      ref xmltype;
  model_type varchar2(80);

begin

  -- Find child name
  sep := instr(xpath, '/', 2);
  if (sep > 2) then
    child := substr(xpath, 2, sep-2);
  else
    child := substr(xpath, 2);
  end if;

  if parent is null then
    -- Find root element
    select s.xmldata.elements into elems
      from xdb.xdb$schema s where s.xmldata.schema_url = schema_url;
    r := find_child(elems, child);
  else
    -- Find child element under parent's elements and choices
    r := find_child_with_model(parent, child, model, model_type);
  end if;

  -- Keep traversing the xpath if this is not the leaf child
  if (sep > 2) then
    return find_element(null, substr(xpath, sep), r);
  end if;
  return r;
end;
/

show errors;

-- Generate type name with a sequence number
create or replace function type_name(prefix varchar2, suffix varchar2)
  return varchar2
as
  name varchar2(80);
begin
  select prefix || xdb.xdb$namesuff_seq.nextval || '_' || suffix
    into name from dual;
  return name;
end;
/

show errors;
