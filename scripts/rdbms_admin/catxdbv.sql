Rem
Rem $Header: rdbms/admin/catxdbv.sql /st_rdbms_11.2.0/5 2012/02/18 04:39:33 atabar Exp $
Rem
Rem catxdbv.sql
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      02/15/12 - Backport atabar_bug-13031694 from main
Rem    bhammers    12/15/11 - bug 13089022, remove catxdbvfexp.sql
Rem    spetride    05/11/11 - created catxdbvfexp.sql script for export views
Rem    spetride    02/07/11 - additional view for XML schemas export
Rem    spetride    04/26/10 - DBA_XML_SCHEMA_DEPENDENCY: account for hidden sch
Rem    spetride    02/23/10 - add schemaoids to DBA_XML_SCHEMA_DEPENDENCY
Rem    spetride    01/21/10 - add DBA_XML_SCHEMA_DEPENDENCY 
Rem    bhammers    04/08/09 - add OR to type in USER_XML_INDEXES
Rem    attran      03/03/09 - #(8313982) - ASYNC
Rem    sipatel     10/01/08 - #(7414934) - xdb@xtab* moved from sys to xdb
Rem    shvenugo    08/19/08 - enhance *_xml_indexes definition
Rem    bsthanik    07/12/07 - 6152793:dont access repos for schema internal
Rem                           name
Rem    sichandr    11/22/06 - display ANYSCHEMA options
Rem    attran      10/18/06 - enhance the views **_xml_indexes
Rem    thbaby      08/12/06 - rename PATHS column to PARAMETERS
Rem    thbaby      06/15/06 - add async column to *_xml_indexes 
Rem    hxzhang     06/08/06 - lrg#2262415, remove all select * from dba_errors
Rem    ataracha    01/26/06 - change user_xml_indexes to use xdb$dxpath alone
Rem    sichandr    05/07/06 - fix CSX info for SB tables 
Rem    abagrawa    10/27/05 - Add XSLT for CSX schemas 
Rem    abagrawa    10/24/05 - Add CSX cols to views 
Rem    sichandr    08/11/05 - catalog view support 
Rem    pnath       05/18/05 - add view for bug 4376605 
Rem    thbaby      01/20/05 - Add HIER_TYPE column to XXX_XML_SCHEMAS
Rem    sichandr    07/19/04 - add xmlindex catalog views 
Rem    spannala    05/24/04 - upgrade might disable xdbhi_idx, rebuild it 
Rem    najain      12/08/03 - add xml_schema_name_present
Rem    njalali     05/12/03 - added all_xml_schemas2
Rem    amanikut    04/29/03 - 2917744 : include NSB cols/views in catalog views
Rem    amanikut    04/29/03 - bug 2917744 : include NSB XVs in USER_XML_VIEWS
Rem    njalali     03/26/03 - removing connect statement and recompiles
Rem    abagrawa    04/02/03 - Add comment to keep in sync
Rem    abagrawa    10/17/02 - Fix element name for element refs
Rem    njalali     08/13/02 - removing SET statements
Rem    ataracha    08/12/02 - compile KU$ views after catmetx
Rem    sichandr    02/25/02 - add int/qualified schema
Rem    sichandr    02/07/02 - fix hex conversions
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    01/08/02 - correcting name in comments
Rem    lbarton     01/09/02 - add catmetx.sql
Rem    nmontoya    12/12/01 - remove set echo on
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    sichandr    11/28/01 - catalog view fixes
Rem    mkrishna    09/26/01 - fix catxdbv
Rem    sichandr    09/05/01 - add xxx_XML_SCHEMAS and xxx_XML_VIEWS
Rem    mkrishna    08/02/01 - Merged mkrishna_bug-1753473
Rem    mkrishna    07/29/01 - Created
Rem

create or replace force view DBA_XML_TABLES
 (OWNER, TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE,
  ANYSCHEMA, NONSCHEMA)
 as select u.name, o.name, null, null, null,
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end
 from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
        decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
        case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
             when bitand(opq.flags,69) = 68 then 'BINARY'
        else 'CLOB' end,
        case when bitand(opq.flags,69) = 68 then
            case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
        else NULL end,
        case when bitand(opq.flags,69) = 68  then
            case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
        else NULL end
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_tables to select_catalog_role;

create or replace public synonym dba_xml_tables for dba_xml_tables; 

comment on table DBA_XML_TABLES is
'Description of all XML tables in the database'
/
comment on column DBA_XML_TABLES.OWNER is
'Name of the owner of the XML table'
/
comment on column DBA_XML_TABLES.TABLE_NAME is
'Name of the XML table'
/
comment on column DBA_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column DBA_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column DBA_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column DBA_XML_TABLES.ANYSCHEMA is
'If storage is BINARY, does this column allow ANYSCHEMA?'
/
comment on column DBA_XML_TABLES.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/

create or replace force view ALL_XML_TABLES
 (OWNER, TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE,
  ANYSCHEMA, NONSCHEMA)
 as 
  select u.name, o.name, null, null, null,
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end
 from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
 decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
  case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
       when bitand(opq.flags,69) = 68 then 'BINARY'
  else 'CLOB' end,
  case when bitand(opq.flags,69) = 68 then
      case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
  else NULL end,
  case when bitand(opq.flags,69) = 68  then
      case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
  else NULL end
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_tables to public;

create or replace public synonym all_xml_tables for all_xml_tables; 

comment on table ALL_XML_TABLES is
'Description of the all XMLType tables that the user has privileges on'
/
comment on column ALL_XML_TABLES.OWNER is
'Owner of the table '
/
comment on column ALL_XML_TABLES.TABLE_NAME is
'Name of the table '
/
comment on column ALL_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column ALL_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column ALL_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column ALL_XML_TABLES.ANYSCHEMA is 
'If storage is BINARY, does this column allow ANYSCHEMA?'
/
comment on column ALL_XML_TABLES.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/ 

create or replace force view USER_XML_TABLES
 (TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE,
  ANYSCHEMA, NONSCHEMA)
 as select o.name, null, null, null,
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end
from sys.opqtype$ opq, sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
  case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
       when bitand(opq.flags,69) = 68 then 'BINARY'
  else 'CLOB' end,
  case when bitand(opq.flags,69) = 68 then
      case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
  else NULL end,
  case when bitand(opq.flags,69) = 68  then
      case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
  else NULL end
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_tables to public;

create or replace public synonym user_xml_tables for user_xml_tables; 

comment on table USER_XML_TABLES is
'Description of the user''s own XMLType tables'
/
comment on column USER_XML_TABLES.TABLE_NAME is
'Name of the XMLType table'
/
comment on column USER_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column USER_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column USER_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column USER_XML_TABLES.ANYSCHEMA is
'If storage is BINARY, does this column allow ANYSCHEMA?'
/ 
comment on column USER_XML_TABLES.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/ 

create or replace force view DBA_XML_TAB_COLS
 (OWNER, TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER,
  ELEMENT_NAME, STORAGE_TYPE, ANYSCHEMA, NONSCHEMA)
 as select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null,
   case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
        when bitand(opq.flags,69) = 68 then 'BINARY'
   else 'CLOB' end,
   case when bitand(opq.flags,69) = 68 then
       case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
   else NULL end,
   case when bitand(opq.flags,69) = 68  then
       case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
   else NULL end
from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
     sys.coltype$ ac, sys.col$ tc, sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end 
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_tab_cols to select_catalog_role;

create or replace public synonym dba_xml_tab_cols for dba_xml_tab_cols; 

comment on table DBA_XML_TAB_COLS is
'Description of all XML tables in the database'
/
comment on column DBA_XML_TAB_COLS.OWNER is
'Name of the owner of the XML table'
/
comment on column DBA_XML_TAB_COLS.TABLE_NAME is
'Name of the XML table'
/
comment on column DBA_XML_TAB_COLS.COLUMN_NAME is
'Name of the XML table column'
/
comment on column DBA_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column DBA_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column DBA_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column DBA_XML_TAB_COLS.ANYSCHEMA is
'If storage is BINARY, does this column allow ANYSCHEMA?'
/
comment on column DBA_XML_TAB_COLS.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/ 

create or replace force view ALL_XML_TAB_COLS
 (OWNER, TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER,
  ELEMENT_NAME, STORAGE_TYPE, ANYSCHEMA, NONSCHEMA)
  as select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),null,null,null,
   case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
        when bitand(opq.flags,69) = 68 then 'BINARY'
   else 'CLOB' end,
   case when bitand(opq.flags,69) = 68 then
       case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
   else NULL end,
   case when bitand(opq.flags,69) = 68  then
       case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
   else NULL end
from  sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
  and tc.name != 'SYS_NC_ROWINFO$'
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  union all
 select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
 where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and bitand(opq.flags,2) = 2
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_tab_cols to public;

create or replace public synonym all_xml_tab_cols for all_xml_tab_cols; 

comment on table ALL_XML_TAB_COLS is
'Description of the all XMLType tables that the user has privileges on'
/
comment on column ALL_XML_TAB_COLS.OWNER is
'Owner of the table '
/
comment on column ALL_XML_TAB_COLS.TABLE_NAME is
'Name of the table '
/
comment on column ALL_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column ALL_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column ALL_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column ALL_XML_TAB_COLS.ANYSCHEMA is
'If storage is BINARY, does this column allow ANYSCHEMA?'
/
comment on column ALL_XML_TAB_COLS.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/ 

create or replace force view USER_XML_TAB_COLS 
 (TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE,
  ANYSCHEMA, NONSCHEMA)
 as select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),null, null, null,
   case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
        when bitand(opq.flags,69) = 68 then 'BINARY'
   else 'CLOB' end,
   case when bitand(opq.flags,69) = 68 then
       case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
   else NULL end,
   case when bitand(opq.flags,69) = 68  then
       case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
   else NULL end
from  sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and bitand(opq.flags,2) = 0
  union all
 select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    case when bitand(opq.flags,69) = 1 then 'OBJECT-RELATIONAL'
         when bitand(opq.flags,69) = 68 then 'BINARY'
    else 'CLOB' end,
    case when bitand(opq.flags,69) = 68 then
        case when bitand(opq.flags,128) = 128 then 'YES' else 'NO' end
    else NULL end,
    case when bitand(opq.flags,69) = 68  then
        case when bitand(opq.flags,256) = 256 then 'NO' else 'YES' end
    else NULL end
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
 where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_tab_cols to public;

create or replace public synonym user_xml_tab_cols for user_xml_tab_cols; 

comment on table USER_XML_TAB_COLS is
'Description of the user''s own XMLType tables'
/
comment on column USER_XML_TAB_COLS.TABLE_NAME is
'Name of the XMLType table'
/
comment on column USER_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column USER_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column USER_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/
comment on column USER_XML_TAB_COLS.ANYSCHEMA is
'If storage is BINARY, does this column allow ANYSCHEMA?'
/
comment on column USER_XML_TAB_COLS.NONSCHEMA is
'If storage is BINARY, does this column allow NONSCHEMA?'
/ 

create or replace force view DBA_XML_VIEWS
 (OWNER, VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select u.name, o.name, null, null, null
 from sys.opqtype$ opq, sys.view$ v, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_views to select_catalog_role;

create or replace public synonym dba_xml_views for dba_xml_views; 

comment on table DBA_XML_VIEWS is
'Description of all XML views in the database'
/
comment on column DBA_XML_VIEWS.OWNER is
'Name of the owner of the XML view'
/
comment on column DBA_XML_VIEWS.VIEW_NAME is
'Name of the XML view'
/
comment on column DBA_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column DBA_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view ALL_XML_VIEWS
 (OWNER, VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
 select u.name, o.name, null, null, null
 from sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
   decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_views to public;

create or replace public synonym all_xml_views for all_xml_views; 

comment on table ALL_XML_VIEWS is
'Description of the all XMLType views that the user has privileges on'
/
comment on column ALL_XML_VIEWS.OWNER is
'Owner of the view '
/
comment on column ALL_XML_VIEWS.VIEW_NAME is
'Name of the view '
/
comment on column ALL_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column ALL_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view USER_XML_VIEWS
 (VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as
 select o.name, null, null, null
from sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
union all
 select o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_views to public;

create or replace public synonym user_xml_views for user_xml_views; 

comment on table USER_XML_VIEWS is
'Description of the user''s own XMLType views'
/
comment on column USER_XML_VIEWS.VIEW_NAME is
'Name of the XMLType view'
/
comment on column USER_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column USER_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/
create or replace force view DBA_XML_VIEW_COLS
 (OWNER, VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null
from  sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
union all
select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_view_cols to select_catalog_role;

create or replace public synonym dba_xml_view_cols for dba_xml_view_cols; 

comment on table DBA_XML_VIEW_COLS is
'Description of all XML views in the database'
/
comment on column DBA_XML_VIEW_COLS.OWNER is
'Name of the owner of the XML view'
/
comment on column DBA_XML_VIEW_COLS.VIEW_NAME is
'Name of the XML view'
/
comment on column DBA_XML_VIEW_COLS.COLUMN_NAME is
'Name of the XML view column'
/
comment on column DBA_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column DBA_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view ALL_XML_VIEW_COLS
 (OWNER, VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
 select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  null, null, null
from sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY VIEWLE */,
                                       -47 /* SELECT ANY VIEWLE */,
                                       -48 /* INSERT ANY VIEWLE */,
                                       -49 /* UPDATE ANY VIEWLE */,
                                       -50 /* DELETE ANY VIEWLE */)
                 )
      )
union all
select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY VIEWLE */,
                                       -47 /* SELECT ANY VIEWLE */,
                                       -48 /* INSERT ANY VIEWLE */,
                                       -49 /* UPDATE ANY VIEWLE */,
                                       -50 /* DELETE ANY VIEWLE */)
                 )
      )
/
grant select on all_xml_view_cols to public;

create or replace public synonym all_xml_view_cols for all_xml_view_cols; 

comment on table ALL_XML_VIEW_COLS is
'Description of the all XMLType views that the user has privileges on'
/
comment on column ALL_XML_VIEW_COLS.OWNER is
'Owner of the view '
/
comment on column ALL_XML_VIEW_COLS.VIEW_NAME is
'Name of the view '
/
comment on column ALL_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column ALL_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view USER_XML_VIEW_COLS 
 (VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null
from  sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
union all
select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_view_cols to public;

create or replace public synonym user_xml_view_cols for user_xml_view_cols; 

comment on table USER_XML_VIEW_COLS is
'Description of the user''s own XMLType views'
/
comment on column USER_XML_VIEW_COLS.VIEW_NAME is
'Name of the XMLType view'
/
comment on column USER_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column USER_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

Rem DBA_XML_SCHEMAS
Rem This view presents a listing of all XML Schemas registered
Rem in the system.
 
create or replace force view DBA_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE, BINARY, SCHEMA_ID, HIDDEN)
 as select s.xmldata.schema_owner, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
	  case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
               then xdb.dbms_csx_int.GetCSXSchema(xmltype(value(s).getclobval())) else value(s) end,
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
              then 'YES' else 'NO' end,
          s.sys_nc_oid$,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 32768) = 32768
              then 'YES' else 'NO' end
    from xdb.xdb$schema s
/
grant select on dba_xml_schemas to select_catalog_role;

create or replace public synonym dba_xml_schemas for dba_xml_schemas;

comment on table DBA_XML_SCHEMAS is
'Description of all the XML Schemas registered'
/
comment on column DBA_XML_SCHEMAS.OWNER is
'Owner of the XML Schema'
/
comment on column DBA_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column DBA_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column DBA_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column DBA_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column DBA_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column DBA_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/
comment on column DBA_XML_SCHEMAS.BINARY is
'Is this XML Schema registered for binary encoding usage?'
/
comment on column DBA_XML_SCHEMAS.SCHEMA_ID is
'16 byte opaque schema identifier'
/
comment on column DBA_XML_SCHEMAS.HIDDEN is
'Has this XML Schema been deleted in hidden mode?'
/

Rem NOTE: Make sure that ALL_XML_SCHEMAS AND ALL_XML_SCHEMAS2
Rem are kept in sync with catxdbdv.sql

Rem ALL_XML_SCHEMAS
Rem Lists all schemas that user has permission to see. This should
Rem be the ones owned by the user plus the global ones. Note that we
Rem do not have the concept of "schema/user" qualified names so we
Rem don't need to include schemas owned by others that this user
Rem has permission to read (because anyway they can't be used)

create or replace force view ALL_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE, BINARY, SCHEMA_ID, HIDDEN)
 as select u.name, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
	  case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
               then xdb.dbms_csx_int.GetCSXSchema(xmltype(value(s).getclobval())) else value(s) end,
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
              then 'YES' else 'NO' end,
          s.sys_nc_oid$,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 32768) = 32768
              then 'YES' else 'NO' end
    from user$ u, xdb.xdb$schema s
    where u.user# = userenv('SCHEMAID')
    and   u.name  = s.xmldata.schema_owner
    union all
    select s.xmldata.schema_owner, s.xmldata.schema_url, 'NO', value(s),
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
              then 'YES' else 'NO' end,
          s.sys_nc_oid$,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 32768) = 32768
              then 'YES' else 'NO' end
    from xdb.xdb$schema s
    where bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
    and s.xmldata.schema_url
       not in (select s2.xmldata.schema_url
               from xdb.xdb$schema s2, user$ u2
               where u2.user# = userenv('SCHEMAID')
               and   u2.name  = s.xmldata.schema_owner)
/
grant select on all_xml_schemas to public with grant option;

create or replace public synonym all_xml_schemas for all_xml_schemas;

comment on table ALL_XML_SCHEMAS is
'Description of all XML Schemas that user has privilege to reference'
/
comment on column ALL_XML_SCHEMAS.OWNER is
'Owner of the XML Schema'
/
comment on column ALL_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column ALL_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column ALL_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column ALL_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column ALL_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column ALL_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/
comment on column ALL_XML_SCHEMAS.BINARY is
'Is this XML Schema registered for binary encoding usage?'
/
comment on column ALL_XML_SCHEMAS.SCHEMA_ID is
'16 byte opaque schema identifier'
/
comment on column ALL_XML_SCHEMAS.HIDDEN is
'Has this XML Schema been deleted in hidden mode?'
/

Rem ALL_XML_SCHEMAS2
Rem Since XMLTYPE may not be present at the stage when catalog.sql runs
Rem this file, we need a version of ALL_XML_SCHEMAS that ALL_OBJECTS
Rem can depend on that doesn't include XMLTYPE.  This way, ALL_OBJECTS
Rem won't be invalidated when we redefine the real ALL_XML_SCHEMAS from
Rem dbmsxmlt.sql.

create or replace force view ALL_XML_SCHEMAS2
 (OWNER, SCHEMA_URL, LOCAL, INT_OBJNAME, QUAL_SCHEMA_URL)
 as select u.name, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end
    from user$ u, xdb.xdb$schema s
    where u.user# = userenv('SCHEMAID')
    and   u.name  = s.xmldata.schema_owner
    union all
    select s.xmldata.schema_owner, s.xmldata.schema_url, 'NO', 
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          s.xmldata.schema_url
    from xdb.xdb$schema s
    where bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
    and s.xmldata.schema_url
       not in (select s2.xmldata.schema_url
               from xdb.xdb$schema s2, user$ u2
               where u2.user# = userenv('SCHEMAID')
               and   u2.name  = s.xmldata.schema_owner)
/
grant select on all_xml_schemas2 to public with grant option;

create or replace public synonym all_xml_schemas2 for all_xml_schemas2;

comment on table ALL_XML_SCHEMAS2 is
'Dummy version of ALL_XML_SCHEMAS that does not have an XMLTYPE column'
/
comment on column ALL_XML_SCHEMAS2.OWNER is
'Owner of the XML Schema'
/
comment on column ALL_XML_SCHEMAS2.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column ALL_XML_SCHEMAS2.LOCAL is
'Is this XML Schema local or global'
/
comment on column ALL_XML_SCHEMAS2.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column ALL_XML_SCHEMAS2.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/

Rem ALL_OBJECTS depends on xml_schema_name_present. Recreate the package 
Rem body, nothing will get invalidated

create or replace package body xml_schema_name_present as

function is_schema_present(objname in varchar2,
                           userno  in number) return number as

  sel_stmt        VARCHAR2(4000);
  tmp_num         NUMBER;

BEGIN

    sel_stmt := ' select count(*) ' ||
    ' from user$ u, xdb.xdb$schema s ' ||
    ' where u.user# = :1 ' ||
    ' and   u.name  = s.xmldata.schema_owner ' ||
    ' and  (xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id) = :2)';

    EXECUTE IMMEDIATE sel_stmt INTO tmp_num USING userno, objname;

    /* schema found */   
    IF (tmp_num > 0) THEN
      RETURN 1;
    END IF;

    sel_stmt := ' select count(*) '||
    ' from xdb.xdb$schema s ' ||
    ' where bitand(to_number(s.xmldata.flags, ''xxxxxxxx''), 16) = 16 ' ||
    ' and xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id)  = :1 ' ||
    ' and s.xmldata.schema_url ' ||
    '   not in (select s2.xmldata.schema_url ' ||
    '          from xdb.xdb$schema s2, user$ u2 ' ||
    '          where u2.user# = :2 ' ||
    '          and   u2.name  = s.xmldata.schema_owner) ';

    EXECUTE IMMEDIATE sel_stmt INTO tmp_num USING objname, userno;

    /* schema found */   
    IF (tmp_num > 0) THEN
      RETURN 1;
    END IF;

    RETURN 0;
END;

end xml_schema_name_present;
/

Rem USER_XML_SCHEMAS
Rem List of all XML Schemas owned by the current user
create or replace force view USER_XML_SCHEMAS
 (SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE, BINARY, SCHEMA_ID, HIDDEN)
 as select s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
      	  case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
               then xdb.dbms_csx_int.GetCSXSchema(xmltype(value(s).getclobval())) else value(s) end,
          xdb.dbms_xmlschema_int.xdb$Oid2IntName(s.object_id),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end, 
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16384) = 16384
              then 'YES' else 'NO' end,
          s.sys_nc_oid$,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 32768) = 32768
              then 'YES' else 'NO' end
    from user$ u, xdb.xdb$schema s
    where u.name = s.xmldata.schema_owner
    and u.user# = userenv('SCHEMAID')
/
grant select on user_xml_schemas to public with grant option;

create or replace public synonym user_xml_schemas for user_xml_schemas;

comment on table USER_XML_SCHEMAS is
'Description of XML Schemas registered by the user'
/
comment on column USER_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column USER_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column USER_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column USER_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column USER_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column USER_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/
comment on column USER_XML_SCHEMAS.BINARY is
'Is this XML Schema registered for binary encoding usage?'
/
comment on column USER_XML_SCHEMAS.SCHEMA_ID is
'16 byte opaque schema identifier'
/
comment on column USER_XML_SCHEMAS.HIDDEN is
'Has this XML Schema been deleted in hidden mode?'
/

create or replace force view DBA_XML_INDEXES
 (INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, TYPE, INDEX_TYPE, PATH_TABLE_NAME, 
  PARAMETERS, ASYNC, STALE, PEND_TABLE_NAME,EX_or_INCLUDE)
 as select
   u.name         INDEX_OWNER,
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   case when bitand(p.flags, 536870912)=536870912 then 'REPOSITORY'
        when bitand(p.flags, 4096)=4096 then 'BINARY'
        when bitand(p.flags, 8192)=8192 then 'CLOB in OR'
        when bitand(p.flags, 16384)=16384 then 'CLOB'
        else '????' end TYPE,
   case when bitand(p.flags , 268435456 ) != 268435456 then 'STRUCTURED'
        when bitand(p.flags, 268435456 ) = 268435456 and exists (select xt.idxobj# from xdb.xdb$xtab xt where xt.idxobj# = p.idxobj#) then 'STRUCTURED and UNSTRUCTURED'
        else 'UNSTRUCTURED' end INDEX_TYPE,
   case when bitand(p.flags,  268435456 ) != 268435456 then ''
        else     ot.name  end PATH_TABLE_NAME,
   p.parameters   PARAMETERS,
   case when bitand(p.flags, 65011712)=6291456 then 'ON-COMMIT'
        when bitand(p.flags, 65011712)=10485760 then 'MANUAL'
        when bitand(p.flags, 65011712)=18874368 then 'EVERY'
        else 'ALWAYS' end ASYNC,
   case when bitand(p.flags, 2097152)=2097152 then 'TRUE'
        else 'FALSE' end STALE,
   case when bitand(p.flags, 2097152)=2097152 then 
        (select op.name from sys.obj$ op
         where  op.obj# = p.pendtabobj#)
        else '' end PEND_TABLE_NAME,
   case when bitand(p.flags, 32)=32 then 'INCLUDE'
        when bitand(p.flags, 128)=128 then 'EXCLUDE'
        else 'FULLY IX' end EX_or_INCLUDE
  from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
     sys.obj$ bo, sys.user$ bu, sys.ind$ i
where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user#
/
show errors;
grant select on dba_xml_indexes to select_catalog_role;

create or replace public synonym dba_xml_indexes for dba_xml_indexes; 

comment on table DBA_XML_INDEXES is
'Description of all XML indexes in the database'
/
comment on column DBA_XML_INDEXES.INDEX_OWNER is
'Username of the owner of the XML index'
/
comment on column DBA_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column DBA_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column DBA_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column DBA_XML_INDEXES.PARAMETERS is
'Structured index groups, path subsetting xpaths and scheduler job information'
/
comment on column DBA_XML_INDEXES.ASYNC is
'Asynchronous index type'
/
comment on column DBA_XML_INDEXES.STALE is
'Stale index type'
/
comment on column DBA_XML_INDEXES.PEND_TABLE_NAME is
'Name of the PENDING TABLE'
/
comment on column DBA_XML_INDEXES.TYPE is
'Type of indexed column (CLOB, CSX, CLOB_IN_OR, REPOSITORY)'
/
comment on column DBA_XML_INDEXES.EX_or_INCLUDE is
'Path Subsetting (Include or Exclude)'
/
comment on column DBA_XML_INDEXES.INDEX_TYPE is
'Index Type (Structured, Unstructured or both)'
/
create or replace force view ALL_XML_INDEXES
 (INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, TYPE, INDEX_TYPE,
  PATH_TABLE_NAME,PARAMETERS, ASYNC, STALE, PEND_TABLE_NAME, EX_or_INCLUDE)
 as select
   u.name         INDEX_OWNER,   
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   case when bitand(p.flags, 536870912)=536870912 then 'REPOSITORY'
        when bitand(p.flags, 4096)=4096 then 'BINARY'
        when bitand(p.flags, 8192)=8192 then 'CLOB in OR'
        when bitand(p.flags, 16384)=16384 then 'CLOB'
        else '????' end TYPE,
   case when bitand(p.flags , 268435456 ) != 268435456 then 'STRUCTURED'
        when bitand(p.flags, 268435456 ) = 268435456 and exists (select xt.idxobj# from xdb.xdb$xtab xt where xt.idxobj# = p.idxobj#) then 'STRUCTURED and UNSTRUCTURED'
        else 'UNSTRUCTURED' end INDEX_TYPE,
   case when bitand(p.flags,  268435456 ) != 268435456 then ''
        else     ot.name  end PATH_TABLE_NAME,
   p.parameters   PARAMETERS,
   case when bitand(p.flags, 65011712)=6291456 then 'ON-COMMIT'
        when bitand(p.flags, 65011712)=10485760 then 'MANUAL'
        when bitand(p.flags, 65011712)=18874368 then 'EVERY'
        else 'ALWAYS' end ASYNC,
   case when bitand(p.flags, 2097152)=2097152 then 'TRUE'
        else 'FALSE' end STALE,
   case when bitand(p.flags, 2097152)=2097152 then 
        (select op.name from sys.obj$ op
         where  op.obj# = p.pendtabobj#)
        else '' end PEND_TABLE_NAME,
   case when bitand(p.flags, 32)=32 then 'INCLUDE'
        when bitand(p.flags, 128)=128 then 'EXCLUDE'
        else 'FULLY IX' end EX_or_INCLUDE
 from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
      sys.user$ bu, sys.obj$ bo, sys.ind$ i
 where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user# and
       (u.user# = userenv('SCHEMAID')
        or oi.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)))
/
show errors;
grant select on all_xml_indexes to public;

create or replace public synonym all_xml_indexes for all_xml_indexes; 

comment on table ALL_XML_INDEXES is
'Description of the all XMLType indexes that the user has privileges on'
/
comment on column ALL_XML_INDEXES.INDEX_OWNER is
'Username of the owner of the XML index'
/
comment on column ALL_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column ALL_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column ALL_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column ALL_XML_INDEXES.PARAMETERS is
'Structured index groups, path subsetting xpaths and scheduler job information'
/
comment on column ALL_XML_INDEXES.ASYNC is
'Asynchronous index type'
/
comment on column ALL_XML_INDEXES.STALE is
'Stale index type'
/
comment on column ALL_XML_INDEXES.PEND_TABLE_NAME is
'Name of the PENDING TABLE'
/
comment on column ALL_XML_INDEXES.TYPE is
'Type of indexed column (CLOB, CSX, CLOB_IN_OR, REPOSITORY)'
/
comment on column ALL_XML_INDEXES.EX_or_INCLUDE is
'Path Subsetting (Include or Exclude)'
/
comment on column ALL_XML_INDEXES.INDEX_TYPE is
'Index Type (Structured, Unstructured or both)'
/
create or replace force view USER_XML_INDEXES
 (INDEX_NAME, TABLE_OWNER, TABLE_NAME, TYPE, INDEX_TYPE, PATH_TABLE_NAME, PARAMETERS, 
  ASYNC, STALE, PEND_TABLE_NAME, EX_or_INCLUDE)
 as select
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   case when bitand(p.flags, 536870912)=536870912 then 'REPOSITORY'
        when bitand(p.flags, 4096)=4096 then 'BINARY'
        when bitand(p.flags, 8192)=8192 then 'CLOB in OR'
        when bitand(p.flags, 16384)=16384 then 'CLOB'
        else 'OR' end TYPE,
   case when bitand(p.flags , 268435456 ) != 268435456 then 'STRUCTURED'
        when bitand(p.flags, 268435456 ) = 268435456 and exists (select xt.idxobj# from xdb.xdb$xtab xt where xt.idxobj# = p.idxobj#) then 'STRUCTURED and UNSTRUCTURED'
        else 'UNSTRUCTURED' end INDEX_TYPE,
   case when bitand(p.flags,  268435456 ) != 268435456 then ''
        else     ot.name  end PATH_TABLE_NAME,
   p.parameters   PARAMETERS,
   case when bitand(p.flags, 65011712)=6291456 then 'ON-COMMIT'
        when bitand(p.flags, 65011712)=10485760 then 'MANUAL'
        when bitand(p.flags, 65011712)=18874368 then 'EVERY'
        else 'ALWAYS' end ASYNC,
   case when bitand(p.flags, 2097152)=2097152 then 'TRUE'
        else 'FALSE' end STALE,
   case when bitand(p.flags, 2097152)=2097152 then 
        (select op.name from sys.obj$ op
         where  op.obj# = p.pendtabobj#)
        else '' end PEND_TABLE_NAME,
   case when bitand(p.flags, 32)=32 then 'INCLUDE'
        when bitand(p.flags, 128)=128 then 'EXCLUDE'
        else 'FULLY IX' end EX_or_INCLUDE
  from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
      sys.user$ bu, sys.obj$ bo, sys.ind$ i
 where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user# and
       u.user# = userenv('SCHEMAID')
/
show errors;
grant select on user_xml_indexes to public;

create or replace public synonym user_xml_indexes for user_xml_indexes; 

comment on table USER_XML_INDEXES is
'Description of the user''s own XMLType indexes'
/
comment on column USER_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column USER_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column USER_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column USER_XML_INDEXES.PARAMETERS is
'Structured index groups, path subsetting xpaths and scheduler job information'
/
comment on column USER_XML_INDEXES.ASYNC is
'Asynchronous index type'
/
comment on column USER_XML_INDEXES.STALE is
'Stale index type'
/
comment on column USER_XML_INDEXES.PEND_TABLE_NAME is
'Name of the PENDING TABLE'
/
comment on column USER_XML_INDEXES.TYPE is
'Type of indexed column (CLOB, CSX, CLOB_IN_OR, REPOSITORY)'
/
comment on column USER_XML_INDEXES.EX_or_INCLUDE is
'Path Subsetting (Include or Exclude)'
/
comment on column USER_XML_INDEXES.INDEX_TYPE is
'Index Type (Structured, Unstructured or both)'
/
Rem Bug fix 4376605, create a view owned by SYS which queries the 
Rem dictionary tables, and exposes only necessary columns to 
Rem qmxdpGetColName in qmxdp.c.
create or replace force view USER_XML_COLUMN_NAMES
 (SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, OBJECT_COLUMN_NAME, EXTERNAL_COLUMN_NAME)
 as 
 select 
   u.name, o.name, c.name,
   (select name from sys.col$ c where c.obj# = o.obj# and c.intcol# = p.objcol),
   (select name from sys.col$ c where c.obj# = o.obj# and c.intcol# = p.extracol)
 from
   sys.opqtype$ p, sys.col$ c, sys.obj$ o, sys.user$ u
 where
   u.user# = o.owner# and
   o.type# = 2 and
   c.obj# = o.obj# and 
   p.intcol# = c.intcol# and
   p.obj# = o.obj# and
   (u.user# = userenv('SCHEMAID')
     or o.obj# in
        (select oa.obj#
         from sys.objauth$ oa
         where grantee# in ( select kzsrorol
                             from x$kzsro
                           )
        )
     or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))

/ 

grant select on USER_XML_COLUMN_NAMES to public;

create or replace public synonym USER_XML_COLUMN_NAMES for USER_XML_COLUMN_NAMES;

Rem XMLSchema dependencies on included or imported schemas; needed for Data Pump
create or replace force view DBA_XML_SCHEMA_IMPORTS
 (SCHEMA_URL, SCHEMA_OWNER, SCHEMA_OID, DEP_SCHEMA_URL, DEP_SCHEMA_OWNER, DEP_SCHEMA_OID)
 as
  select distinct x.xmldata.schema_url, 
         x.xmldata.schema_owner,
         x.sys_nc_oid$,
         xt.schema_location,
         xd.owner,
         xd.schema_id     
  from xdb.xdb$schema x,
       table(x.xmldata.imports) xt,
       dba_xml_schemas xd,
       dba_xml_schemas xd2 
  where (not (x.xmldata.schema_owner ='SYS')) and
        (x.xmldata.imports is not null) and
        (xd2.schema_id = x.sys_nc_oid$) and (xd2.hidden = xd.hidden) and
        ( /* included schema owned by same user as schema */
          ((xd.schema_url = xt.schema_location) and 
           (xd.owner = x.xmldata.schema_owner)) 
          or 
          /* included schema is not owned by same user as schema */
          /*  so must be  global */
          (not exists (select * from dba_xml_schemas 
                       where owner = x.xmldata.schema_owner and
                             schema_url = xt.schema_location)
           and 
           (xd.schema_url = xt.schema_location)
           and
           (xd.local = 'NO'))
        );
show errors;
grant select on DBA_XML_SCHEMA_IMPORTS to select_catalog_role;
create or replace public synonym DBA_XML_SCHEMA_IMPORTS for DBA_XML_SCHEMA_IMPORTS;
comment on table DBA_XML_SCHEMA_IMPORTS is
'Description of all XML schema first level dependencies on imported XML schemas'
/
comment on column DBA_XML_SCHEMA_IMPORTS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column DBA_XML_SCHEMA_IMPORTS.SCHEMA_OWNER is
'Owner of the XML Schema'
/
comment on column DBA_XML_SCHEMA_IMPORTS.SCHEMA_OID is
'Oid of the XML Schema'
/
comment on column DBA_XML_SCHEMA_IMPORTS.DEP_SCHEMA_URL is
'Schema URL of the imported XML Schema'
/
comment on column DBA_XML_SCHEMA_IMPORTS.DEP_SCHEMA_OWNER is
'Owner of the imported XML Schema'
/
comment on column DBA_XML_SCHEMA_IMPORTS.DEP_SCHEMA_OID is
'Oid of the imported XML Schema'
/

create or replace force view DBA_XML_SCHEMA_INCLUDES
 (SCHEMA_URL, SCHEMA_OWNER, SCHEMA_OID, DEP_SCHEMA_URL, DEP_SCHEMA_OWNER, DEP_SCHEMA_OID)
 as
  select distinct x.xmldata.schema_url, 
         x.xmldata.schema_owner,
         x.sys_nc_oid$,
         xt.schema_location,
         xd.owner,
         xd.schema_id     
  from xdb.xdb$schema x,
       table(x.xmldata.includes) xt,
       dba_xml_schemas xd,
       dba_xml_schemas xd2 
  where (not (x.xmldata.schema_owner ='SYS')) and
        (x.xmldata.includes is not null) and
        (xd2.schema_id = x.sys_nc_oid$) and (xd2.hidden = xd.hidden) and
        ( /* included schema owned by same user as schema */
          ((xd.schema_url = xt.schema_location) and 
           (xd.owner = x.xmldata.schema_owner)) 
          or 
          /* included schema is not owned by same user as schema */
          /*  so must be  global */
          (not exists (select * from dba_xml_schemas 
                       where owner = x.xmldata.schema_owner and
                             schema_url = xt.schema_location)
           and 
           (xd.schema_url = xt.schema_location)
           and
           (xd.local = 'NO'))
        );
show errors;
grant select on DBA_XML_SCHEMA_INCLUDES to select_catalog_role;
create or replace public synonym DBA_XML_SCHEMA_INCLUDES for DBA_XML_SCHEMA_INCLUDES;
comment on table DBA_XML_SCHEMA_INCLUDES is
'Description of all XML schema first level dependencies on included XML schemas'
/
comment on column DBA_XML_SCHEMA_INCLUDES.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column DBA_XML_SCHEMA_INCLUDES.SCHEMA_OID is
'Oid of the XML Schema'
/
comment on column DBA_XML_SCHEMA_INCLUDES.SCHEMA_OWNER is
'Owner of the XML Schema'
/
comment on column DBA_XML_SCHEMA_INCLUDES.DEP_SCHEMA_URL is
'Schema URL of the included XML Schema'
/
comment on column DBA_XML_SCHEMA_INCLUDES.DEP_SCHEMA_OWNER is
'Owner of the included XML Schema'
/
comment on column DBA_XML_SCHEMA_INCLUDES.DEP_SCHEMA_OID is
'Oid of the included XML Schema'
/

create or replace force view DBA_XML_SCHEMA_DEPENDENCY(SCHEMA_URL, SCHEMA_OWNER, SCHEMA_OID,
                                                       DEP_SCHEMA_URL, DEP_SCHEMA_OWNER, DEP_SCHEMA_OID)
as select distinct SCHEMA_URL, SCHEMA_OWNER, SCHEMA_OID, 
                   DEP_SCHEMA_URL, DEP_SCHEMA_OWNER, DEP_SCHEMA_OID
             from DBA_XML_SCHEMA_IMPORTS 
   union  
   select distinct SCHEMA_URL, SCHEMA_OWNER, SCHEMA_OID,
                   DEP_SCHEMA_URL, DEP_SCHEMA_OWNER, DEP_SCHEMA_OID
             from DBA_XML_SCHEMA_INCLUDES;
show errors;

grant select on DBA_XML_SCHEMA_DEPENDENCY to select_catalog_role;
create or replace public synonym DBA_XML_SCHEMA_DEPENDENCY for DBA_XML_SCHEMA_DEPENDENCY;
comment on table DBA_XML_SCHEMA_DEPENDENCY is
'Description of all XML schema first level dependencies on imported and included XML schemas'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.SCHEMA_OWNER is
'Owner of the XML Schema'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.SCHEMA_OID is
'Oid of the XML Schema'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.DEP_SCHEMA_URL is
'Schema URL of the dependent (include or imported) XML Schema'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.DEP_SCHEMA_OWNER is
'Owner of the dependent (include or imported) XML Schema'
/
comment on column DBA_XML_SCHEMA_DEPENDENCY.DEP_SCHEMA_OID is
'Oid of the dependent XML Schema'
/

-- view for xmlschemas dependencies
create or replace view DBA_XMLSCHEMA_LEVEL_VIEW_DUP
        (schema_url, schema_owner, schema_oid, lvl, IN_CYCLE ) as
select schema_url, schema_owner, schema_oid, max(level)+1, CONNECT_BY_ISCYCLE 
from DBA_XML_SCHEMA_DEPENDENCY
 connect by NOCYCLE prior schema_url   = dep_schema_url   and
            prior schema_owner = dep_schema_owner and
            prior schema_oid = dep_schema_oid
 group by  schema_url, schema_owner, schema_oid, CONNECT_BY_ISCYCLE
union
select x.xmldata.schema_url, x.xmldata.schema_owner, x.sys_nc_oid$, 1, 0 
from xdb.xdb$schema x
  where x.xmldata.includes is NULL and x.xmldata.imports is NULL
/

show errors;
grant select on DBA_XMLSCHEMA_LEVEL_VIEW_DUP to select_catalog_role;

-- we need this view as the view above returns actually two rows for cyclic schemas, 
-- one for the level at which the cycle was detected and with connect_by_iscycle set to 0, 
-- and one with the level incremented by 1 and connect_by_iscycle set to 1
create or replace view DBA_XMLSCHEMA_LEVEL_VIEW
         (schema_url, schema_owner, schema_oid, lvl) as 
select l.schema_url, l.schema_owner, l.schema_oid, l.lvl from DBA_XMLSCHEMA_LEVEL_VIEW_DUP l 
  where not exists (select 1 from DBA_XMLSCHEMA_LEVEL_VIEW_DUP
                    where schema_url = l.schema_url and schema_owner = l.schema_owner and
                          schema_oid = l.schema_oid and in_cycle=1) 
union 
select l.schema_url, l.schema_owner, l.schema_oid, 0 from DBA_XMLSCHEMA_LEVEL_VIEW_DUP l
  where exists (select 1 from  DBA_XMLSCHEMA_LEVEL_VIEW_DUP
                where schema_url = l.schema_url and schema_owner = l.schema_owner and
                       schema_oid = l.schema_oid and in_cycle=1)
/

show errors;
-- the xmlschema_level_view is required for sys.ku$_xmlschema_view, which
-- allows select to PUBLIC; follow the same model and grant select to PUBLIC
grant select on DBA_XMLSCHEMA_LEVEL_VIEW to public
/
create or replace public synonym DBA_XMLSCHEMA_LEVEL_VIEW for DBA_XMLSCHEMA_LEVEL_VIEW;

Rem Upgrade Might disbale xdbhi_idx, rebuild it
alter package xdb.xdb_funcimpl compile;
alter index xdb.xdbhi_idx rebuild;

rem
rem create metadata API views
rem
@@catmetx.sql





