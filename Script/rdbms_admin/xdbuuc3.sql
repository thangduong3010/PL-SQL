Rem
Rem $Header: xdbuuc3.sql 07-apr-2006.17:52:07 mrafiq Exp $
Rem
Rem xdbuuc3.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbuuc3.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Upgrade/downgrade utility functions that are to be used
Rem      after migration of acl/config docs
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mrafiq      04/07/06 - cleaning up 
Rem    abagrawa    03/28/06 - Created
Rem

-- Updates the xmlref of xdbconfig.xml in xdb.xdb$resource to point to
-- the correct value from xdb.xdb$config. This makes sure that no invalid
-- rowid hint is hanging around in the old xmlref after up/downgrade
create or replace procedure update_config_ref is
  configoid      raw(16);
  configelnum    integer;
  configdocref   ref xmltype;
  configschref   ref xmltype;
  configdocref_str varchar2(4000);
  configschref_str varchar2(4000);
  configurl   varchar2(100) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  confignmspc varchar2(100) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
begin
  select ref(c) into configdocref from xdb.xdb$config c;
  
  select reftohex(configdocref) into configdocref_str from dual;
  dbms_output.put_line('update_config_ref:configdocref = ' || configdocref_str);

  select ref(s) into configschref from xdb.xdb$schema s where
  s.xmldata.schema_url=configurl and s.xmldata.target_namespace=confignmspc;

  select reftohex(configschref) into configschref_str from dual;
  dbms_output.put_line('update_config_ref:configschref = ' || configschref_str);

  select e.xmldata.property.prop_number into configelnum from xdb.xdb$element e
  where e.xmldata.property.parent_schema=configschref  
  and e.xmldata.property.name='xdbconfig';

  dbms_output.put_line('update_config_ref:configelnum = ' || configelnum);

  update xdb.xdb$resource r set r.xmldata.xmlref=configdocref 
  where r.xmldata.dispname = 'xdbconfig.xml' and r.xmldata.elnum = configelnum
  and r.xmldata.schoid = sys_op_r2o(configschref);
end;
/
