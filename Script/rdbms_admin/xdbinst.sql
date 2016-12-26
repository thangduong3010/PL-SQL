Rem
Rem $Header: rdbms/admin/xdbinst.sql /st_rdbms_11.2.0/2 2011/06/23 23:28:30 spetride Exp $
Rem
Rem xdbinst.sql
Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbinst.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    06/14/11 - Backport spetride_bug-12562859 from
Rem                           st_rdbms_11.2.0
Rem    spetride    05/11/11 - add DBA_TYPE_XMLSCHEMA_DEP
Rem    spetride    01/22/10 - add DBA_XML_SCHEMA_DEPENDENCY
Rem    badeoti     03/20/09 - clean up 11.2 packages: remove public synonyms
Rem                           for internal packages
Rem    thbaby      07/10/06 - add is_vpd_enabled and get_table_name 
Rem    thbaby      01/06/06 - add procedure sys.setmodflg 
Rem    nitgupta    11/03/05 - add dbms_xdb_print
Rem    pnath       01/20/05 - pnath_bug-4112707
Rem    pnath       01/19/05 - remove all SET statements 
Rem    pnath       12/08/04 - pnath_bug-3936353
Rem    pnath       12/02/04 - Created
Rem

declare 
  val number;
begin
  select count(*) into val from all_tables where owner = 'SYS' and table_name = 'XDB_INSTALLATION_TAB';
  if val = 0 then
     execute immediate 'create table xdb_installation_tab (owner varchar2(200), object_name varchar2(200), object_type varchar2(200))';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB$STRING_LIST_T','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLSCHEMA','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDBZ','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDB','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ISXMLTYPETABLE','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','SET_TABLESPACE','PROCEDURE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','CHECK_UPGRADE','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDB_PRINT','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','UNDER_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','EQUALS_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DEPTH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ABSPATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','RESOURCE_VIEW','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB_RVTRIG_PKG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','CONTENTSCHEMAIS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDB_VERSION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','PATH_VIEW','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB_PVTRIG_PKG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBMS_EPG','PACKAGE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_EPG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','EPG$_AUTH','TABLE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','EPG$_AUTH_PK','INDEX';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_EPG_DAD_AUTHORIZATION','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_EPG_DAD_AUTHORIZATION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_EPG_DAD_AUTHORIZATION','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_EPG_DAD_AUTHORIZATION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_SCHEMAS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_SCHEMAS2','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_SCHEMAS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLINDEX','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','LCR$_XML_SCHEMA','PACKAGE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','datetime_format73_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','anydata72_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute71_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','column_value74_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_valu77_COLL','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_values76_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DDL_LCR75_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','old_value80_COLL','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','old_values79_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','new_values81_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_values82_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ROW_LCR78_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBMS_REGXDB','PACKAGE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','SETMODFLG','PROCEDURE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','GET_TABLE_NAME','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','IS_VPD_ENABLED','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_SCHEMA_IMPORTS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_SCHEMA_IMPORTS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_SCHEMA_INCLUDES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_SCHEMA_INCLUDES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_SCHEMA_DEPENDENCY','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_SCHEMA_DEPENDENCY','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XMLSCHEMA_LEVEL_VIEW_DUP','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XMLSCHEMA_LEVEL_VIEW','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XMLSCHEMA_LEVEL_VIEW','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_TYPE_XMLSCHEMA_DEP','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_TYPE_XMLSCHEMA_DEP','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XML_TABNAME2OID_VIEW','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XML_TABNAME2OID_VIEW','SYNONYM';
     commit;
   end if;
exception
   when others then
      select count(*) into val from all_tables where owner = 'SYS' and table_name = 'XDB_INSTALLATION_TAB';
      if val = 1 then
         execute immediate 'drop table xdb_installation_tab';
      end if;
end;
/
