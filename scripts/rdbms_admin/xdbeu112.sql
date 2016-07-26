Rem
Rem $Header: rdbms/admin/xdbeu112.sql /st_rdbms_11.2.0/1 2011/07/31 10:32:40 juding Exp $
Rem
Rem xdbeu112.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      xdbeu112.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juding      07/28/11 - Get previous_version from CATPROC when it is NULL
Rem    hxzhang     07/14/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

Rem ================================================================
Rem BEGIN XDB downgrade for XDB Repository export/ import
Rem ================================================================

create or replace type sv as varray(18) of varchar2(2000);
/

declare
  stmt_tbl   sv := sv('XDB.XDB$SCHEMA_EXPORT_VIEW_TBL',
                      'XDB.XDB$RESOURCE_EXPORT_VIEW_TBL',
                      'DBA_TYPE_XMLSCHEMA_DEP_TBL',
                      'DBA_XML_SCHEMA_DEPENDENCY_TBL',
                      'xdb.xdb$simple_type_view_tbl',
                      'xdb.xdb$complex_type_view_tbl',
                      'xdb.xdb$all_model_view_tbl',
                      'xdb.xdb$choice_model_view_tbl',
                      'xdb.xdb$sequence_model_view_tbl',
                      'xdb.xdb$group_def_view_tbl',
                      'xdb.xdb$group_ref_view_tbl',
                      'xdb.xdb$attribute_view_tbl',
                      'xdb.xdb$element_view_tbl',
                      'xdb.xdb$any_view_tbl',
                      'xdb.xdb$anyattr_view_tbl',
                      'xdb.xdb$attrgroup_def_view_tbl',
                      'xdb.xdb$attrgroup_ref_view_tbl',
                      'SYS.XML_TABNAME2OID_VIEW_TBL');
  stmt_view  sv := sv('XDB.XDB$SCHEMA_EXPORT_VIEW',
                      'XDB.XDB$RESOURCE_EXPORT_VIEW',
                      'DBA_TYPE_XMLSCHEMA_DEP',
                      'xdb.xdb$simple_type_view',
                      'xdb.xdb$complex_type_view',
                      'xdb.xdb$all_model_view',
                      'xdb.xdb$choice_model_view',
                      'xdb.xdb$sequence_model_view',
                      'xdb.xdb$group_def_view',
                      'xdb.xdb$group_ref_view',
                      'xdb.xdb$attribute_view',
                      'xdb.xdb$element_view',
                      'xdb.xdb$any_view',
                      'xdb.xdb$anyattr_view',
                      'xdb.xdb$attrgroup_def_view',
                      'xdb.xdb$attrgroup_ref_view',
                      'SYS.XML_TABNAME2OID_VIEW');
  i      number;
  stmt   varchar2(2000);
  previous_version varchar2(30);
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if not (previous_version like '11.2.0.2%' or
          previous_version like '11.2.0.1%' or
          previous_version like '11.2.0.0%' or
          previous_version like '11.1%' or
          previous_version like '11.0%' or
          previous_version like '10.%' or
          previous_version like '9.%')
  then
    return;
  end if;

  for i in 1..18 loop
    begin
      stmt := 'drop table ' || upper(stmt_tbl(i));
      --dbms_output.put_line(stmt);
      execute immediate stmt;
      exception
         when OTHERS then
            null;
    end; 
  end loop;
  for i in 1..17 loop
    begin
      stmt := 'drop view ' || upper(stmt_view(i));
      --dbms_output.put_line(stmt);
      execute immediate stmt;
      exception
         when OTHERS then
            null;
    end;    
  end loop;

  begin
    stmt := 'delete from sys.impcalloutreg$ where tgt_schema = ''' || 
            'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
  begin
    stmt := 'delete from sys.exppkgact$ where package = ''' || 
            'DBMS_XDBUTIL_INT' || ''' and schema=''' || 'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
end;
/

begin
  execute immediate 'drop type sv';
exception
   when others then
     NULL;
end;
/


Rem ================================================================
Rem END XDB downgrade for XDB Repository export/ import
Rem ================================================================
