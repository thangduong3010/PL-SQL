Rem
Rem $Header: rdbms/admin/xdbuuc2.sql /st_rdbms_11.2.0/2 2012/03/08 09:52:04 bhammers Exp $
Rem
Rem xdbuuc2.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbuuc2.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/07/12 - Backport bhammers_bug-12601205 from
Rem                           st_rdbms_11.2.0
Rem    thbaby      08/18/11 - catch exception during insertion to
Rem                           invalid_xdb$* (bug 12868961)
Rem    badeoti     10/29/08 - 7433383: re-enable hierarchy after table upgrade
Rem                           in migratexmltable
Rem    spetride    08/04/06 - add INVALID_XDB$ACL/CONFIG for csx migrate
Rem    mrafiq      06/21/06 - cleaning up 
Rem    mrafiq      04/07/06 - cleaning up 
Rem    mrafiq      04/13/06 - call 'alter table upgrade' for xdb$acl
Rem    abagrawa    03/29/06 - Remove user_dep check for now 
Rem    abagrawa    03/28/06 - Move update_config_ref to new file 
Rem    abagrawa    03/28/06 - Add check_user_dependents 
Rem    abagrawa    03/25/06 - Handle ACL downgrade 
Rem    abagrawa    03/17/06 - Fix migrateTable for downgrade 
Rem    abagrawa    03/14/06 - Utility functions for xdb up/downgrade 
Rem    abagrawa    03/14/06 - Created
Rem

-- This procedure checks for non-system (user) dependents of a schema
-- and raises an error if any are found. This will abort upgrade!
create or replace procedure check_user_dependents(schref ref xmltype) is
  objnum integer;
begin
  select o.obj# into objnum from obj$ o
  where o.name = xdb.dbms_xmlschema_int.xdb$oid2intname(sys_op_r2o(schref));

  xdb.dbms_xmlschema_int.checkuserdependents(schref, objnum);
end;
/
  

-- This procedure replaces a schema's oid with a new oid. This involves
-- several steps:
-- 1. Update object_id in xdb.xdb$schema table
-- 2. Update name in obj$
-- 3. Update schema resource's ref to point to new schema ref
-- 4. Update all refs from schema components (elements, attributes, types, etc)
--    to point to new schema ref
-- 5. Update table metadata in opqtype$ to point to new schema oid
create or replace procedure migrate_patchup_schema(oldschemaoid raw, 
                                                   newschemaoid raw) is
  oldschemaref ref xmltype;
  newschemaref ref xmltype;
  oldschemaref_str varchar2(2000);
  newschemaref_str varchar2(2000);
  oldschemaoid_str varchar2(2000);
  newschemaoid_str varchar2(2000);
  oldintname       varchar2(2000);
  newintname       varchar2(2000);
begin
  -- Print out input parameters
  select rawtohex(oldschemaoid) into oldschemaoid_str from dual;
  dbms_output.put_line('migrate_patchup_schema:oldschemaoid = ' 
                       || oldschemaoid_str);
  select rawtohex(newschemaoid) into newschemaoid_str from dual;
  dbms_output.put_line('migrate_patchup_schema:newschemaoid = ' 
                       || newschemaoid_str);

  -- Get oldschemaref from oldschemaoid
  select ref(e) into oldschemaref from xdb.xdb$schema e 
  where e.object_id = oldschemaoid;

  select reftohex(oldschemaref) into oldschemaref_str from dual;
  dbms_output.put_line('migrate_patchup_schema:oldschemaref = ' 
                       || oldschemaref_str);

  -- Get old internal name from oldschemaoid
  -- The reason we added xdb$oid2intname instead of using xdb$extname2intname
  -- is that we might not want to pin the schema. Also, in some cases (such as
  -- for newschemaoid during upgrade), the new schemaoid might not exist yet
  -- and xdb$extname2intname returns null in that case
  select xdb.dbms_xmlschema_int.xdb$oid2intname(oldschemaoid) 
  into oldintname from dual;

  dbms_output.put_line('migrate_patchup_schema:oldintname = ' || oldintname);

  -- Get new internal name from newschemaoid 
  select xdb.dbms_xmlschema_int.xdb$oid2intname(newschemaoid) 
  into newintname from dual;

  dbms_output.put_line('migrate_patchup_schema:newintname = ' || newintname);

  -- 1. Update the schema table to have the correct oid
  update xdb.xdb$schema e set e.object_id = newschemaoid 
  where ref(e) = oldschemaref;

  -- Get the new schema ref 
  select ref(e) into newschemaref from xdb.xdb$schema e 
  where e.object_id = newschemaoid;
  
  select reftohex(newschemaref) into newschemaref_str from dual;
  dbms_output.put_line('migrate_patchup_schema:newschemaref = ' 
                       || newschemaref_str);

  -- 2. Update the name in obj$ to the new internal name
  update obj$ set name = newintname where name = oldintname;

  -- 3. Update the schema resource's ref to point to newschemaref
  update xdb.xdb$resource r set r.xmldata.xmlref = newschemaref 
  where r.xmldata.xmlref = oldschemaref;

  -- 4. Update all references from elements, types, and other schema
  --    components to point to the new schema ref too
  update xdb.xdb$element e 
  set e.xmldata.property.parent_schema = newschemaref
  where e.xmldata.property.parent_schema = oldschemaref;

  update xdb.xdb$attribute e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$simple_type e
  set e.xmldata.parent_schema = newschemaref 
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$complex_type e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$all_model e 
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$choice_model e 
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$sequence_model e 
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$anyattr e
  set e.xmldata.property.parent_schema = newschemaref
  where e.xmldata.property.parent_schema = oldschemaref;

  update xdb.xdb$any e
  set e.xmldata.property.parent_schema = newschemaref
  where e.xmldata.property.parent_schema = oldschemaref;

  update xdb.xdb$group_def e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$group_ref e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$attrgroup_def e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  update xdb.xdb$attrgroup_ref e
  set e.xmldata.parent_schema = newschemaref
  where e.xmldata.parent_schema = oldschemaref;

  -- 5. Update the table metadata to point to the new schema oid
  update opqtype$ set schemaoid = newschemaoid 
  where schemaoid = oldschemaoid;

  commit;
end;
/

show errors;


create or replace procedure xdb.FixAcl_SchemaLoc(errtabname IN VARCHAR2)
is
  stmt varchar2(2000);
begin
 stmt := 'update ' || errtabname || ' t set t.object_value = '; 
 stmt := stmt || ' updatexml(t.object_value, ''/acl/@xsi:schemaLocation'', ''http://';
 stmt := stmt || 'xmlns.oracle.com/xdb/acl.xsd                           http://xmlns.oracle.com/xdb/acl.xsd'', '' xmlns=';
 stmt :=  stmt || '"http://xmlns.oracle.com/xdb/acl.xsd" xmlns:xsi=';
 stmt := stmt || '"http://www.w3.org/2001/XMLSchema-instance"'')';
 stmt := stmt || ' where t.object_value is not null';
 dbms_output.put_line(stmt); 
 execute immediate stmt;
end;
/

show errors;


-- Helper procedure for migration to CSX storage
create or replace procedure create_csxinvalid_entries_tab(
tabname varchar2, temptabname varchar2, schemaowner varchar2, 
transformfn varchar2, need_2nd_fn number, defaultdoc varchar2) is
  full_errtabname  varchar2(50);
  stmterrtab  varchar2(2000);
  stmtselcur  varchar2(2000);
  TYPE        obj_list_cur IS REF CURSOR;
  cur         obj_list_cur;
  myobj_id    raw(16);
  myacloid    raw(16);
  myownerid   raw(16);
  stmtins1row varchar2(2000);
  stmtfix1row varchar2(2000);
  stmtinserr  varchar2(2000);
  stmtinserr2 varchar2(2000);
  myobj_id_str varchar2(2000);
  nfixobjval  sys.xmltype;
  fixobjval   sys.xmltype;
  stmtchk1    varchar2(2000);
  noinv       number := 0;
  stmtfixtab  varchar2(2000);
  stmtdelrow  varchar2(2000);
  stmtselcur2 varchar2(2000);
  stmtinsdef  varchar2(2000);
  stmtdefxml  varchar2(2000);
  defaultxml  sys.xmltype;
  gotdefault  boolean;
  xmldirname  varchar2(2000);
begin
  -- 1. create table that will contain invalid entries in the temporary table
  full_errtabname := schemaowner || '.' || 'INVALID_' || tabname;
  dbms_output.put_line(full_errtabname);
  stmterrtab := 'create table ' || full_errtabname  || ' ( ' ||
                   'object_id    raw(16), ' ||
                   'object_value sys.xmltype, ' ||
                   'acloid       raw(16), ' ||
                   'ownerid      raw(16)) ' ||
                   'xmltype object_value store as CLOB';
  dbms_output.put_line(stmterrtab);
  execute immediate stmterrtab;
  commit;

  -- creating the statements beforehand
  stmtselcur := 'select object_id, value(x), acloid, ownerid from ' ||
                   schemaowner || '.' || temptabname || ' x';

  stmtfix1row := 'select xmltype(' || transformfn || '(:1).getclobval()) ' ||
                 ' from dual ';

  stmtins1row := 'insert into ' || schemaowner || '.' || tabname || 
                 '(object_id, object_value, acloid, ownerid)' ||
                 '  values(:1, :2, :3 , :4)';

  stmtinserr := 'insert into ' || full_errtabname || 
                '(object_id, object_value, acloid, ownerid)' ||
                ' values(:1, :2, :3 , :4)';

  stmtinserr2 := 'insert into ' || full_errtabname || 
                '(object_id, acloid, ownerid) values(:1, :2, :3)';

  stmtdelrow := 'delete from ' || full_errtabname || 
                ' where (object_id = :1 ) and (acloid = :2 ) ' ||
                ' and (ownerid = :3 )';

  stmtselcur2 := 'select object_id, x.object_value, acloid, ownerid from ' ||
                  full_errtabname || ' x where x.object_value is not null';

  stmtinsdef :=  'insert into ' || schemaowner || '.' || tabname || 
                 '(object_id, object_value, acloid, ownerid)' ||
                 '  values(:1, :2, :3 , :4)';

  -- 2. open a cursor on the temporary table
  dbms_output.put_line(stmtselcur);
  open cur for stmtselcur;
  loop
    fetch cur into myobj_id, nfixobjval, myacloid, myownerid;
    exit when cur%notfound;
    -- 3. for each row in the temporary table, insert the fixed xml value
    begin
      dbms_output.put_line(stmtfix1row);
      execute immediate stmtfix1row into fixobjval using nfixobjval;

      begin
        execute immediate stmtins1row using 
           myobj_id, fixobjval, myacloid, myownerid;
      exception
       when others then
          -- if insert fails, add the  transformed row into the error table
          dbms_output.put_line('insert failed');
          dbms_output.put_line(stmtinserr);
          begin
             execute immediate stmtinserr using 
                myobj_id, fixobjval, myacloid, myownerid;
          -- exception block added by fix for bug 12868961
          exception
           when others then
              -- insert into invalid_xdb$* table fails
              -- insert null into xmltype column. Object id stored
              -- in this table can be used to figure out the offending
              -- ACL document. 
              dbms_output.put_line('insert into invalid table failed');
              dbms_output.put_line(stmtinserr2);
              begin
                execute immediate stmtinserr2 using 
                  myobj_id, myacloid, myownerid;
              exception
               when others then
                  -- insert into invalid_xdb$* table fails
                  dbms_output.put_line('insert into invalid table (null) failed');
                  begin
                     select rawtohex(myobj_id) into myobj_id_str from dual;
                     dbms_output.put_line('myobj_id = ' || myobj_id_str);
                  exception
                   when others then
                      null;
                  end;
              end;
          end;
          -- END OF exception block added by fix for bug 12868961
          noinv := noinv + 1;
      end;

    exception
       when others then
          -- if fix fails, add the orginal row  into the error table
          dbms_output.put_line('fix failed');
          dbms_output.put_line(stmtinserr);
          begin
             execute immediate stmtinserr using 
                myobj_id, nfixobjval, myacloid, myownerid;
          -- exception block added by fix for bug 12868961
          exception
           when others then
              -- insert into invalid_xdb$* table fails
              -- insert null into xmltype column. Object id stored
              -- in this table can be used to figure out the offending
              -- ACL document. 
              dbms_output.put_line('insert into invalid table failed');
              dbms_output.put_line(stmtinserr2);
              begin
                execute immediate stmtinserr2 using 
                  myobj_id, myacloid, myownerid;
              exception
               when others then
                  -- insert into invalid_xdb$* table fails
                  dbms_output.put_line('insert into invalid table (null) failed');
                  begin
                     select rawtohex(myobj_id) into myobj_id_str from dual;
                     dbms_output.put_line('myobj_id = ' || myobj_id_str);
                  exception
                   when others then
                      null;
                  end;
              end;
          end;
          -- END OF exception block added by fix for bug 12868961
          noinv := noinv + 1;
    end; 
  end loop;

  if (noinv = 0) then
    return;
  end if;

  -- 4. if default document provided, replace each invalid with it
  --    keep invalid rows in the error table
  if (need_2nd_fn = 0) then
    if (defaultdoc is not null) then
       begin
         -- construct the default xml
         execute immediate 
           'select dbms_metadata_hack.get_xml_dirname() from dual'
           into xmldirname;
         defaultxml := xmltype(BFILENAME(xmldirname, defaultdoc), 0);
         --defaultxml := xmltype(dbms_metadata_hack.get_xml_bfile(defaultdoc), 0);
 
         -- open cursor on the error table
         dbms_output.put_line(stmtselcur2);
         open cur for stmtselcur2;

         loop
           fetch cur into myobj_id, fixobjval, myacloid, myownerid;
           exit when cur%notfound;
           -- insert default doc
           begin
             dbms_output.put_line(stmtinsdef);
             execute immediate stmtinsdef using 
               myobj_id, defaultxml, myacloid, myownerid;
           exception
              -- if we reach an exception here, the default doc must be invalid
              -- should never come to this point
              when others then
                 dbms_output.put_line('error inserting default doc');
                 null;             
           end;
         end loop;
         exception
          when others then
           dbms_output.put_line('error constructing default doc'); 
           null;
         end;
      end if; 
      return;
   end if;

  -- need_2nd_fn > 0
  -- 4. if second fix provided, and invalid rows exist,
  --    apply the fix to the error table
  case
    when (tabname = 'XDB$ACL') then
      xdb.FixAcl_SchemaLoc(full_errtabname);
      -- cannot pass the name of 2nd fix as string, since 
      -- execute immediate stmt does not allow stmt to contain DDLs
      -- Note: If needed for other tables, add here the call to 2nd fixes
  end case; 

  gotdefault := false; 
  -- open cursor on the error table
  dbms_output.put_line(stmtselcur2);
  open cur for stmtselcur2;
  loop
    fetch cur into myobj_id, fixobjval, myacloid, myownerid;
    exit when cur%notfound;

    begin
      dbms_output.put_line(stmtins1row);
      execute immediate stmtins1row using 
         myobj_id, fixobjval, myacloid, myownerid;

      -- if insert successful, delete the row from the error table
      begin
        dbms_output.put_line(stmtdelrow);
        execute immediate stmtdelrow using myobj_id, myacloid, myownerid;
      exception
        when others then
           dbms_output.put_line('delete from errortable failed');
           null;
      end;
    exception
      when others then
        dbms_output.put_line('2nd insert failed');
        -- insert default document, if provided
        if (defaultdoc is not null) then
          begin
            if (not gotdefault) then
              execute immediate 
                'select dbms_metadata_hack.get_xml_dirname() from dual'
                 into xmldirname;
              defaultxml := xmltype(BFILENAME(xmldirname, defaultdoc), 0);
              --defaultxml := xmltype(dbms_metadata_hack.get_xml_bfile(defaultdoc), 0);
              gotdefault := true;
            end if;
 
            dbms_output.put_line(stmtinsdef);
            execute immediate stmtinsdef using 
              myobj_id, defaultxml, myacloid, myownerid; 
          exception
              when others then
                  null;
          end;
        end if;
    end;
  end loop;
 
end;
/

show errors;


-- This procedure migrates schema based data between CSX storage and OR storage
-- It makes sure that the table name, table extent oid, schema oid, propnum
-- for root element are all unchanged. This makes sure that any other
-- metadata that is relying on these will not have to be updated. The
-- main use case right now is for migrating ACL documents to CSX, but this
-- can be used for any schema
-- This can only be used when there is one root element in the schema
-- Parameters: 
-- xsd: new schema to be registered
-- nmspc: target namespace of old schema
-- url: old schema's URL
-- tabname: old schema's root element's table name
-- schemaowner: owner of the XML schema
-- root: root element name
-- absdir: absolute path where schema is located in repository
-- absfile: resource name of schema doc in repository
-- NOTE: although absdir and absfile can be inferred from nmspc and url,
-- we want to avoid XDB initialization so we ask users to pass this in
-- csx: true if moving data to csx, false if moving data from csx
-- need_2nd_fn : set to non-zero if, after applying  transformfn
--                on each row, we want to apply a second correction;
--                the 2nd correction is applied on the entire
--                table with invalid rows; a 2nd insert is then attempted
--                for each of the rows in the invalid entries table
--   Note: now only called for XDB$ACL for correcting schemaLocation
-- defaultdoc : if provided, this document will be used to replace
--              each invalid document; the invalid document is still
--              present in the invalid entries table;
--              the post-recovery step will later on attempt to correct 
--              the invalid document
create or replace procedure xdb$migratexmltable(xsd in sys.xmltype,
nmspc varchar2, url varchar2, tabname varchar2, schemaowner varchar2,
root varchar2, absdir varchar2, absfile varchar2, csx in boolean,
transformfn varchar2 := null, need_2nd_fn number := 0,
defaultdoc varchar2 := null) is
  oldschemaoid raw(16);
  regschemaoid raw(16) := null;
  oldschemaref ref xmltype;  
  oldschemaref_str varchar2(2000);
  oldschemaoid_str varchar2(2000);
  oldtableoid_str varchar2(2000);
  newtableoid_str varchar2(2000);
  oldtableoid raw(16);
  newschemaref ref xmltype;
  newschemaoid raw(16);
  newtableoid raw(16);
  createtableddl varchar2(4000);
  oldpropnum integer;
  altertableddl varchar2(4000);
  upgradetableddl varchar2(4000);
  abspath varchar2(2000);
  tempabspath varchar2(2000);
  temptabname varchar2(2000);
  tempurl varchar2(2000);
  tempabsfile varchar2(2000);
  xdbuser varchar2(2000) := 'XDB';
  xdbschematab varchar2(2000) := 'XDB$SCHEMA';
  regoptions pls_integer := 0;
  gentypesval boolean := true;
  binaryval number;
  isbinary boolean;
  delete_option number := xdb.dbms_xmlschema.delete_cascade_force +
                          xdb.dbms_xmlschema.delete_migrate;
  insertsql varchar2(4000);
begin

  -- The basic algorithm used by this procedure is:
  -- 1. Rename the schema URL to a temporary URL
  -- 2. Rename the table to a temporary name
  -- 3. Change the table extent OID to a new and unique temporary OID
  -- 4. Change schema oid (and all other metadata to make this work) 
  --    NOTE: if we are moving data from CSX, this step occurs after
  --    step 8 because the schema OID is stored along with CSX data
  --    and we need to keep the old schema to decode data properly
  -- 5. Rename repository link for schema resource to temporary URL
  -- 6. Register new schema and maintain the propnum for the root. Also
  --    if we are moving data to CSX, then maintain the old schema's OID
  -- 7. Copy data into new table from old table
  --    NOTE: this step requires a fixit operation to make the old documents
  --    compliant with the new schema, as well as to ensure that certain
  --    events that fire normally are fired because the schema URL has been
  --    changed
  -- 8. Delete old schema in cascade force mode
  -- 9. reenable hierarchy
 
  -- set up some constants 
  tempabsfile := absfile || '_2';
  abspath := absdir || '/' || absfile;
  tempabspath := abspath || '_2';  
  temptabname := tabname || '_2';
  tempurl := url || '_2';

  -- First check if this schema is registered for CSX or not
  select bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) into binaryval 
  from xdb.xdb$schema s 
  where s.xmldata.target_namespace = nmspc and s.xmldata.schema_url = url;

  isbinary := (binaryval = 16384);

  -- Nothing to be done, just return
  if (isbinary = csx) then 
    dbms_output.put_line('migratexmltable: nothing to be done');
    return;
  else
    dbms_output.put_line('migratexmltable: need to migrate data');
  end if; 

  -- Select some data out that will be needed later
  select object_id into oldschemaoid from xdb.xdb$schema e 
  where e.xmldata.target_namespace = nmspc
  and e.xmldata.schema_url = url;

  select rawtohex(oldschemaoid) into oldschemaoid_str from dual;
  dbms_output.put_line('migratexmltable: oldschemaoid = ' || oldschemaoid_str);

  select ref(e) into oldschemaref from xdb.xdb$schema e 
  where e.xmldata.target_namespace = nmspc
  and e.xmldata.schema_url = url;

  -- TODO:check user dependents and abort upgrade if any are found
  -- check_user_dependents(oldschemaref);

  select reftohex(oldschemaref) into oldschemaref_str from dual;
  dbms_output.put_line('migratexmltable: oldschemaref = ' || oldschemaref_str);

  select oid$ into oldtableoid from obj$ where name = tabname 
  and owner# = (select user# from user$ where name = schemaowner);

  select rawtohex(oldtableoid) into oldtableoid_str from dual;
  dbms_output.put_line('migratexmltable: oldtableoid = ' || oldtableoid_str);

  select e.xmldata.property.prop_number into oldpropnum
  from xdb.xdb$element e where e.xmldata.property.parent_schema=oldschemaref
  and e.xmldata.property.name=root;

  dbms_output.put_line('migratexmltable: oldpropnum = ' || oldpropnum);

  -- Generate a new table extend oid for the table to copy data to
  newtableoid := xdb.dbms_xdbutil_int.getnewoid();
  
  select rawtohex(newtableoid) into newtableoid_str from dual;
  dbms_output.put_line('migratexmltable: newtableoid = ' || newtableoid_str);

  -- Disable hierarchy on old table
  xdb.dbms_xdbz.disable_hierarchy(schemaowner, tabname);

  -- Rename schema URL 
  update xdb.xdb$schema e set e.xmldata.schema_url = tempurl
  where  e.xmldata.target_namespace = nmspc 
  and e.xmldata.schema_url = url ;

  dbms_output.put_line('migratexmltable: tempurl = ' || tempurl);

  -- Upgrade Table
  upgradetableddl := 'alter table ' || schemaowner || '.' || tabname || 
                   ' upgrade';

  execute immediate upgradetableddl;

  -- Rename table
  altertableddl := 'alter table ' || schemaowner || '.' || tabname || 
                   ' rename to ' || temptabname;

  execute immediate altertableddl;

  dbms_output.put_line('migratexmltable: altertableddl = ' || altertableddl);

  -- Rename table extend OID
  update obj$ set oid$ = newtableoid where oid$ = oldtableoid;
  update oid$ set oid$ = newtableoid where oid$ = oldtableoid;

  dbms_output.put_line('migratexmltable: updated table eoid');

  -- Change xdb:defaulttable attribute
  update xdb.xdb$element e set e.xmldata.default_table = temptabname
  where e.xmldata.default_table = tabname 
  and e.xmldata.default_table_schema = schemaowner; 

  dbms_output.put_line('migratexmltable: updated defaulttable attr');

  -- If moving data to CSX, then generate a new schema OID, and rename
  -- the old schema to point to that OID 
  if csx then
    newschemaoid := xdb.dbms_xdbutil_int.getnewoid();
    migrate_patchup_schema(oldschemaoid, newschemaoid);
  end if;

  -- Clean up session/shared state
  xdb.dbms_xdbutil_int.flushsession;
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';

  -- Rename schema link (in repository)
  xdb.dbms_xdb.renameresource(abspath, absdir, tempabsfile); 
  commit;

  dbms_output.put_line('migratexmltable: renamed resource');

  -- Clean up session/shared state again
  xdb.dbms_xdbutil_int.flushsession;
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush shared_pool';

  -- If moving data to CSX, the schema must be registered with different
  -- flags and parameter values
  if csx then
    regoptions := dbms_xmlschema.register_binaryxml;
    gentypesval := false;
    regschemaoid := oldschemaoid;
  end if;

  -- Register the schema again while keeping the same propnum for the
  -- root element. Also, when moving data to CSX, make sure we preserve
  -- the OID of the schema document 
  xdb.dbms_xmlschema_int.registerschema(
  schemaurl=>url, schemadoc=>xsd.getclobval(), local=>false,
  gentypes=>gentypesval, genbean=>false,                                 
  gentables=>false, force=>false, 
  owner=>schemaowner, 
  enablehierarchy=>dbms_xmlschema.enable_hierarchy_contents,
  options=>regoptions, 
  schemaoid=>regschemaoid, elname=>root, elnum=>oldpropnum);

  commit;
  dbms_output.put_line('migratexmltable: registered new schema');

  -- Create the default table for the root element
  createtableddl :=  
  'create table ' || schemaowner || '.' || tabname || ' of xmltype oid '''
  || oldtableoid || '''';

  if csx then
    createtableddl := createtableddl || ' xmltype store as basicfile binary xml';
  end if;

  createtableddl := createtableddl || ' xmlschema "' || 
                    url || '"' || ' element "' || root || '"';

  execute immediate createtableddl;

  dbms_output.put_line('migratexmltable: createtableddl = ' || createtableddl);

  -- Enable xrls hierarchy to add in acloid column
  xdb.dbms_xdbz.enable_hierarchy(schemaowner, tabname);

  -- Disable xrls hierarchy priv check
  xdb.dbms_xdbz.disable_hierarchy(schemaowner, tabname);
  xdb.dbms_xdbz.disable_hierarchy(xdbuser, xdbschematab);

  -- Also, re-enable hierarchy on temptable to make sure extra columns
  -- ownerid and acloid are present
  xdb.dbms_xdbz.enable_hierarchy(schemaowner, temptabname);
  xdb.dbms_xdbz.disable_hierarchy(schemaowner, temptabname);

  -- Copy data from old table into new table
  if csx then
    create_csxinvalid_entries_tab(tabname, temptabname, schemaowner, 
                                  transformfn, need_2nd_fn, defaultdoc);
  else
    insertsql := 
    'insert into ' || schemaowner || '.' || tabname || 
    ' (object_id, object_value, acloid, ownerid) (select object_id, ';

    insertsql := insertsql || transformfn || 
                 '(xmltype(value(x).getclobval()))';

    insertsql := insertsql || ', acloid, ownerid from ' || 
                 schemaowner || '.' || temptabname || ' x)'; 

    dbms_output.put_line('migratexmltable:insertsql = ' || insertsql);

    execute immediate insertsql;
  end if;

  -- Disable hierarchy (to disable triggers)
  xdb.dbms_xdbz.disable_hierarchy(schemaowner, temptabname);

  -- Delete schema cascade force mode
  xdb.dbms_xmlschema.deleteschema(tempurl,
                		  delete_option);

  dbms_output.put_line('migratexmltable: deleted old schema');

  -- If the old data was in CSX, we defer the schemaOID rename to after
  -- the data copy because CSX data stores schemaOID in it
  if (csx = false) then
    select object_id into newschemaoid from xdb.xdb$schema s 
    where s.xmldata.target_namespace = nmspc and s.xmldata.schema_url = url;

    migrate_patchup_schema(newschemaoid, oldschemaoid);
  end if;

   -- finally enable hierarchy again since it was enabled prior migration
   xdb.dbms_xdbz.enable_hierarchy(schemaowner, tabname);
end;
/

show errors;

-- Checks if a schema exists and deletes it if found
create or replace procedure delete_schema_if_exists(schurl IN varchar2,
                                                    options IN pls_integer) is
 c  number;
BEGIN

  select count(*) into c
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = schurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(schurl, options);
  end if;
END;
/

