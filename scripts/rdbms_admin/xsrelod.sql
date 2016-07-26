Rem
Rem $Header: rdbms/admin/xsrelod.sql /main/6 2010/06/06 21:49:30 snadhika Exp $
Rem
Rem xsrelod.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xsrelod.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Replaces all XS - related packages with the current versions
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    snadhika    04/14/10 - remove PREDICATE xmlindex
Rem    atabar      03/09/09 - modified QName regexp
Rem    srtata      03/03/08 - remove grant on document_links2 view
Rem    rbhatti     02/01/08 - bug 6782472- move prvtkzxv
Rem    jsamuel     12/27/07 - xml index on xsprincipals
Rem    sichandr    12/18/07 - fix security_class catalog view
Rem    clei        12/11/07 - fix xds dictionary views
Rem    rburns      11/05/07 - add catnacl
Rem    snadhika    09/25/07 - Added new column in ALL_XSC_SECURITY_CLASS view
Rem                           Added new view ALL_XSC_SECURITY_CLASS_STATUS
Rem                           Added new package xs$catview_util
Rem    ningzhan    09/11/07 - fix the ALL_XSC_AGGREGATE_PRIVILEGE view
Rem                           defintion to remove namespace prefix.
Rem    pknaggs     08/27/07 - DSD schema: aclids to aclFiles or aclDirectory.
Rem    srtata      07/25/07 - move prvtkzxv.pkb before events packages
Rem    sgul        01/31/07 - Add prvtkzxv.plb
Rem    pthornto    10/09/06 - adding View creations
Rem    pthornto    10/04/06 - cleanup
Rem    pthornto    09/21/06 - file to load XS related packages
Rem    pthornto    09/21/06 - Created
Rem

Rem Create network ACL security views
@@catnacl

Rem Create event handlers for eXtensible Security events
CREATE OR REPLACE LIBRARY DBMS_XSU_LIB TRUSTED AS STATIC;
/
CREATE OR REPLACE LIBRARY DBMS_XSH_LIB TRUSTED AS STATIC;
/

Rem Create or replace VIEWs
create or replace view DBA_XDS_OBJECTS
  (SCHEMA_NAME, OBJECT_NAME, ENABLE_OPTION, STATUS)
as
select u.name, o.name,
       case bitand(r.stmt_type,8192)+
            bitand(r.stmt_type,16384)+
            bitand(r.stmt_type,32768)
         when 8192 then 'ENABLE_DYNAMIC_IS'
         when 16384 then 'ENABLE_ACLOID_COLUNM'
         when 32768 then 'ENABLE_STATIC_IS'
      end,
      decode(r.enable_flag, 0, 'DISABLE', 'ENABLE')
from user$ u, obj$ o, rls$ r
where u.user# = o.owner#
and r.obj# = o.obj# and
r.pname = 'SYS_XDS$POLICY'
/

comment on table DBA_XDS_OBJECTS is
'All XDS enabled objects in the database'
/
comment on column DBA_XDS_OBJECTS.SCHEMA_NAME is
'Owner of the object'
/
comment on column DBA_XDS_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_XDS_OBJECTS.ENABLE_OPTION is
'XDS enable option of the object'
/
comment on column DBA_XDS_OBJECTS.STATUS is
'Policy is enabled or disabled'
/

create or replace public synonym DBA_XDS_OBJECTS for DBA_XDS_OBJECTS
/
grant select on DBA_XDS_OBJECTS to select_catalog_role
/

create or replace view ALL_XDS_OBJECTS
  (SCHEMA_NAME, OBJECT_NAME, ENABLE_OPTION, STATUS)
as
select SCHEMA_NAME, o.OBJECT_NAME, ENABLE_OPTION, o.STATUS
from DBA_XDS_OBJECTS o, ALL_OBJECTS t
where
o.SCHEMA_NAME = t.OWNER and o.OBJECT_NAME = t.OBJECT_NAME
/

comment on table ALL_XDS_OBJECTS is
'All XDS enabled objects accessible to the user'
/
comment on column ALL_XDS_OBJECTS.SCHEMA_NAME is
'Owner of the object'
/
comment on column ALL_XDS_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_XDS_OBJECTS.ENABLE_OPTION is
'XDS enable option of the object'
/
comment on column ALL_XDS_OBJECTS.STATUS is
'Policy is enabled or disabled'
/
create or replace public synonym ALL_XDS_OBJECTS for ALL_XDS_OBJECTS
/
grant select on ALL_XDS_OBJECTS to PUBLIC
/

create or replace view USER_XDS_OBJECTS
  (OBJECT_NAME, ENABLE_OPTION, STATUS)
as
select OBJECT_NAME, ENABLE_OPTION, STATUS
from DBA_XDS_OBJECTS
where
SCHEMA_NAME = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_XDS_OBJECTS is
'All XDS enabled objects owned by the user'
/
comment on column USER_XDS_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_XDS_OBJECTS.ENABLE_OPTION is
'XDS enable option of the object'
/
comment on column USER_XDS_OBJECTS.STATUS is
'Policy is enabled or disabled'
/
create or replace public synonym USER_XDS_OBJECTS for USER_XDS_OBJECTS
/
grant select on USER_XDS_OBJECTS to PUBLIC
/

create or replace view DBA_XDS_INSTANCE_SETS
  (SCHEMA_NAME, OBJECT_NAME, INSTANCE_SET, DESCRIPTION,
   STATIC, EVAL_RULE, ACL_FILE, ACL_LOCATION)
as
select
  substr(regexp_replace(r_xds.path,
                        '/xds/dsd/([^/]+)/([^.]+).xml', '\1'), 1, 30),
  substr(regexp_replace(r_xds.path,
                        '/xds/dsd/([^/]+)/([^.]+).xml', '\2'), 1, 30),
  substr(extractValue(value(ins),
                      '/instanceSet/name',
                      'xmlns="http://xmlns.oracle.com/xs"'), 1, 30),
  extractValue(value(ins),
               '/instanceSet/description',
               'xmlns="http://xmlns.oracle.com/xs"'),
  substr(extractValue(value(ins),
                      '/instanceSet/@static',
                      'xmlns="http://xmlns.oracle.com/xs"'), 1, 5),
  extractValue(value(ins),
               '/instanceSet/memberEvaluationRule',
               'xmlns="http://xmlns.oracle.com/xs"'),
  decode(existsNode(value(ins), '/instanceSet/acls/aclDirectory'),
         0, 'true', 'false'),
  extractvalue(value(acldirectory),
               '/aclDirectory',
               'xmlns="http://xmlns.oracle.com/xs"')
  from
     xdb.xs$data_security     xds,
     path_view            r_xds,
     table(XMLSequence(
       extract(xds.OBJECT_VALUE,
               '/DataSecurity/instanceSets/instanceSet',
               'xmlns="http://xmlns.oracle.com/xs"')))       ins,
     table(XMLSequence(
       extract(value(ins),
               '/instanceSet/acls/aclDirectory',
               'xmlns="http://xmlns.oracle.com/xs"')))       acldirectory
 where r_xds.path like '/xds/dsd/%.xml'
   and sys_op_r2o(extractvalue(r_xds.RES, '/Resource/XMLRef'))=xds.object_id
union all
select
  substr(regexp_replace(r_xds.path,
                        '/xds/dsd/([^/]+)/([^.]+).xml', '\1'), 1, 30),
  substr(regexp_replace(r_xds.path,
                        '/xds/dsd/([^/]+)/([^.]+).xml', '\2'), 1, 30),
  substr(extractValue(value(ins),
                      '/instanceSet/name',
                      'xmlns="http://xmlns.oracle.com/xs"'), 1, 30),
  extractValue(value(ins),
               '/instanceSet/description',
               'xmlns="http://xmlns.oracle.com/xs"'),
  substr(extractValue(value(ins),
                      '/instanceSet/@static',
                      'xmlns="http://xmlns.oracle.com/xs"'), 1, 5),
  extractValue(value(ins),
               '/instanceSet/memberEvaluationRule',
               'xmlns="http://xmlns.oracle.com/xs"'),
  decode(existsNode(value(ins), '/instanceSet/acls/aclDirectory'),
         0, 'true', 'false'),
  extractvalue(value(aclfile),
               '/aclFile',
               'xmlns="http://xmlns.oracle.com/xs"')
  from
     xdb.xs$data_security     xds,
     path_view            r_xds,
     table(XMLSequence(
       extract(xds.OBJECT_VALUE,
               '/DataSecurity/instanceSets/instanceSet',
               'xmlns="http://xmlns.oracle.com/xs"')))       ins,
     table(XMLSequence(
       extract(value(ins),
               '/instanceSet/acls/aclFiles/aclFile',
               'xmlns="http://xmlns.oracle.com/xs"')))       aclfile
 where r_xds.path like '/xds/dsd/%.xml'
   and sys_op_r2o(extractvalue(r_xds.RES, '/Resource/XMLRef'))=xds.object_id;

comment on table DBA_XDS_INSTANCE_SETS is
'All instance sets in the database'
/
comment on column DBA_XDS_INSTANCE_SETS.SCHEMA_NAME is
'Owner of the object'
/
comment on column DBA_XDS_INSTANCE_SETS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_XDS_INSTANCE_SETS.INSTANCE_SET is
'Name of the instance set'
/
comment on column DBA_XDS_INSTANCE_SETS.DESCRIPTION is
'Description of the instance set'
/
comment on column DBA_XDS_INSTANCE_SETS.STATIC is
'true for static instance sets, false for dynamic instance sets'
/
comment on column DBA_XDS_INSTANCE_SETS.EVAL_RULE is
'Membership evaluation rule of the instance set'
/
comment on column DBA_XDS_INSTANCE_SETS.ACL_FILE is
'true if ACL_LOCATION is a file, false if ACL_LOCATION is a directory'
/
comment on column DBA_XDS_INSTANCE_SETS.ACL_LOCATION is
'ACL file or directory associated with rule'
/
create or replace public synonym DBA_XDS_INSTANCE_SETS for DBA_XDS_INSTANCE_SETS
/
grant select on DBA_XDS_INSTANCE_SETS to select_catalog_role
/
create or replace view ALL_XDS_INSTANCE_SETS
 (SCHEMA_NAME, OBJECT_NAME, INSTANCE_SET,
  DESCRIPTION, STATIC, EVAL_RULE, ACL_FILE, ACL_LOCATION)
as
select SCHEMA_NAME, OBJECT_NAME, INSTANCE_SET, DESCRIPTION,
       STATIC, EVAL_RULE, ACL_FILE, ACL_LOCATION
from dba_xds_instance_sets, all_tables t
where
SCHEMA_NAME = t.OWNER and OBJECT_NAME = t.TABLE_NAME
/
comment on table ALL_XDS_INSTANCE_SETS is
'All instance sets for objects accessible to the user in the database'
/
comment on column ALL_XDS_INSTANCE_SETS.SCHEMA_NAME is
'Owner of the object'
/
comment on column ALL_XDS_INSTANCE_SETS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_XDS_INSTANCE_SETS.INSTANCE_SET is
'Name of the instance set'
/
comment on column ALL_XDS_INSTANCE_SETS.DESCRIPTION is
'Description of the instance set'
/
comment on column ALL_XDS_INSTANCE_SETS.STATIC is
'true for static instance sets, false for dynamic instance sets'
/
comment on column ALL_XDS_INSTANCE_SETS.EVAL_RULE is
'Membership evaluation rule of the instance set'
/
comment on column ALL_XDS_INSTANCE_SETS.ACL_FILE is
'true if ACL_LOCATION is a file, false if ACL_LOCATION is a directory'
/
comment on column ALL_XDS_INSTANCE_SETS.ACL_LOCATION is
'ACL file or directory associated with rule'
/
create or replace public synonym ALL_XDS_INSTANCE_SETS for ALL_XDS_INSTANCE_SETS
/
grant select on ALL_XDS_INSTANCE_SETS to PUBLIC
/

create or replace view USER_XDS_INSTANCE_SETS
  (OBJECT_NAME, INSTANCE_SET, DESCRIPTION, STATIC,
   EVAL_RULE, ACL_FILE, ACL_LOCATION)
as
  select OBJECT_NAME, INSTANCE_SET, DESCRIPTION, STATIC,
         EVAL_RULE, ACL_FILE, ACL_LOCATION
from dba_xds_instance_sets
where
  SCHEMA_NAME = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_XDS_INSTANCE_SETS is
'All instance sets for objects owned by the user'
/
comment on column USER_XDS_INSTANCE_SETS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_XDS_INSTANCE_SETS.INSTANCE_SET is
'Name of the instance set'
/
comment on column USER_XDS_INSTANCE_SETS.DESCRIPTION is
'Description of the instance set'
/
comment on column USER_XDS_INSTANCE_SETS.STATIC is
'true for static instance sets, false for dynamic instance sets'
/
comment on column USER_XDS_INSTANCE_SETS.EVAL_RULE is
'Membership evaluation rule of the instance set'
/
comment on column USER_XDS_INSTANCE_SETS.ACL_FILE is
'true if ACL_LOCATION is a file, false if ACL_LOCATION is a directory'
/
comment on column USER_XDS_INSTANCE_SETS.ACL_LOCATION is
'ACL file or directory associated with rule'
/
create or replace public synonym USER_XDS_INSTANCE_SETS for USER_XDS_INSTANCE_SETS
/
grant select on USER_XDS_INSTANCE_SETS to PUBLIC
/

CREATE OR REPLACE VIEW DBA_XDS_ATTRIBUTE_SECS
  (SCHEMA_NAME, OBJECT_NAME,
   COLUMN_NAME, DESCRIPTION, PRIVILEGE) as
  SELECT
    substr(regexp_replace(r_xds.path,
                          '/xds/dsd/([^/]+)/([^.]+).xml', '\1'), 1, 30),
    substr(regexp_replace(r_xds.path,
                          '/xds/dsd/([^/]+)/([^.]+).xml', '\2'), 1, 30),
    substr(extractValue(value(ll),
           '/attributeSec/attribute/colName',
           'xmlns="http://xmlns.oracle.com/xs"'), 1, 30),
    extractValue(value(ll),
                 '/attributeSec/description',
                 'xmlns="http://xmlns.oracle.com/xs"'),
    SYS_XMLEXNSURI(value(ll),
                   '/attributeSec/privilege',
                   'xmlns="http://xmlns.oracle.com/xs"')||':'||
    REGEXP_REPLACE(extractValue(value(ll),
                                '/attributeSec/privilege',
                                'xmlns="http://xmlns.oracle.com/xs"'),
                   '(.+):(.+)', '\2')
    FROM XDB.XS$DATA_SECURITY p,
         path_view        r_xds,
         table(XMLSequence(
           extract(OBJECT_VALUE,
                   '/DataSecurity/attributeSecs/attributeSec',
                   'xmlns="http://xmlns.oracle.com/xs"')))       ll
   WHERE
     r_xds.path like '/xds/dsd/%.xml'
     and sys_op_r2o(extractvalue(r_xds.RES, '/Resource/XMLRef'))=p.object_id
     and SYS_XMLEXNSURI(value(ll),
                        '/attributeSec/privilege',
                        'xmlns="http://xmlns.oracle.com/xs"') is not NULL
union all
  SELECT
    substr(regexp_replace(r_xds.path,
                          '/xds/dsd/([^/]+)/([^.]+).xml', '\1'), 1, 30),
    substr(regexp_replace(r_xds.path,
                          '/xds/dsd/([^/]+)/([^.]+).xml', '\2'), 1, 30),
    substr(extractValue(value(ll),
                        '/attributeSec/attribute/colName',
                        'xmlns="http://xmlns.oracle.com/xs"'), 1, 30),
    extractValue(value(ll),
                 '/attributeSec/description',
                 'xmlns="http://xmlns.oracle.com/xs"'),
    extractValue(value(ll),
                 '/attributeSec/privilege',
                 'xmlns="http://xmlns.oracle.com/xs"')
    FROM XDB.XS$DATA_SECURITY p,
         path_view        r_xds,
         table(XMLSequence(
           extract(OBJECT_VALUE,
                   '/DataSecurity/attributeSecs/attributeSec',
                   'xmlns="http://xmlns.oracle.com/xs"')))       ll
   WHERE
     r_xds.path like '/xds/dsd/%.xml'
     and sys_op_r2o(extractvalue(r_xds.RES, '/Resource/XMLRef'))=p.object_id
     and SYS_XMLEXNSURI(value(ll),
                        '/attributeSec/privilege',
                        'xmlns="http://xmlns.oracle.com/xs"') is NULL
/
comment on table DBA_XDS_ATTRIBUTE_SECS is
'All XDS column security defined in the database'
/
comment on column DBA_XDS_ATTRIBUTE_SECS.SCHEMA_NAME is
'Owner of the object'
/
comment on column DBA_XDS_ATTRIBUTE_SECS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_XDS_ATTRIBUTE_SECS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_XDS_ATTRIBUTE_SECS.DESCRIPTION is
'Description'
/
comment on column DBA_XDS_ATTRIBUTE_SECS.PRIVILEGE is
'Name of the privilege'
/
create or replace public synonym DBA_XDS_ATTRIBUTE_SECS for
 DBA_XDS_ATTRIBUTE_SECS
/
grant select on DBA_XDS_ATTRIBUTE_SECS to select_catalog_role
/

CREATE OR REPLACE VIEW ALL_XDS_ATTRIBUTE_SECS
  (SCHEMA_NAME, OBJECT_NAME, COLUMN_NAME, DESCRIPTION, PRIVILEGE)
 as
select SCHEMA_NAME, o.OBJECT_NAME, COLUMN_NAME, DESCRIPTION, PRIVILEGE
  from DBA_XDS_ATTRIBUTE_SECS o, all_objects t
where
SCHEMA_NAME = t.OWNER and o.OBJECT_NAME = t.OBJECT_NAME
/

comment on table ALL_XDS_ATTRIBUTE_SECS is
'All objects with XDS column security and accessible to the user'
/
comment on column ALL_XDS_ATTRIBUTE_SECS.SCHEMA_NAME is
'Owner of the object'
/
comment on column ALL_XDS_ATTRIBUTE_SECS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_XDS_ATTRIBUTE_SECS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_XDS_ATTRIBUTE_SECS.DESCRIPTION is
'Description'
/
comment on column ALL_XDS_ATTRIBUTE_SECS.PRIVILEGE is
'Name of the privilege'
/
create or replace public synonym ALL_XDS_ATTRIBUTE_SECS for
 ALL_XDS_ATTRIBUTE_SECS
/
grant select on ALL_XDS_ATTRIBUTE_SECS to PUBLIC
/

CREATE OR REPLACE VIEW USER_XDS_ATTRIBUTE_SECS
  (OBJECT_NAME, COLUMN_NAME, DESCRIPTION, PRIVILEGE)
 as
select OBJECT_NAME, COLUMN_NAME, DESCRIPTION, PRIVILEGE
  from ALL_XDS_ATTRIBUTE_SECS where
  SCHEMA_NAME = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_XDS_ATTRIBUTE_SECS is
'All objects with column security and owned by the user'
/
comment on column USER_XDS_ATTRIBUTE_SECS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_XDS_ATTRIBUTE_SECS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_XDS_ATTRIBUTE_SECS.DESCRIPTION is
'Description'
/
comment on column USER_XDS_ATTRIBUTE_SECS.PRIVILEGE is
'Name of the privilege'
/
create or replace public synonym USER_XDS_ATTRIBUTE_SECS for
 USER_XDS_ATTRIBUTE_SECS
/
grant select on USER_XDS_ATTRIBUTE_SECS to PUBLIC
/

CREATE OR REPLACE VIEW XDB.DOCUMENT_LINKS2 AS
SELECT
resid source_id,
any_path source_path,
(select
  resid
 from resource_view
 where equals_path(res, extractvalue(value(xl), '/*/@xlink:href', 'xmlns:xlink="http://www.w3.org/1999/xlink"')) = 1) target_id,
extractvalue(value(xl), '/*/@xlink:href', 'xmlns:xlink="http://www.w3.org/1999/xlink"') target_path
FROM
resource_view r,
table(xmlsequence(extract(res, '//*[@xlink:href]', 'xmlns:xlink="http://www.w3.org/1999/xlink"'))) xl;

create or replace public synonym DOCUMENT_LINKS2 for XDB.DOCUMENT_LINKS2;

create or replace view ALL_XSC_SECURITY_CLASS
  (OWNER, CLASS_NAME, TARGET_NAMESPACE, TITLE, DESCRIPTION,
   SECURITY_CLASS, ENABLE, PATH)
as
select
   extractValue(r.RES,
     'Resource/Owner'),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@name'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   extractValue(OBJECT_VALUE,
    '/securityClass/title'),
   extractValue(OBJECT_VALUE,
    '/securityClass/description'),
   extract(OBJECT_VALUE, '/securityClass'),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@enable'),1,5),
   ANY_PATH
from XDB.XS$SECURITYCLASS p,
     RESOURCE_VIEW r
where
   sys_op_r2o(extractValue(r.RES, '/Resource/XMLRef')) = p.object_id;

comment on table ALL_XSC_SECURITY_CLASS is
'All security class definitions in the database'
/
comment on column ALL_XSC_SECURITY_CLASS.OWNER is
'The owner of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.CLASS_NAME is
'Name of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.TARGET_NAMESPACE is
'The target namespace for the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.TITLE is
'Title of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.DESCRIPTION is
'Description of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.SECURITY_CLASS is
'XMLType for the security class document'
/
comment on column ALL_XSC_SECURITY_CLASS.ENABLE is
'Enable attribute of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS.PATH is
'The path where the security class is stored in the XML DB repository'
/
create or replace public synonym ALL_XSC_SECURITY_CLASS
   for ALL_XSC_SECURITY_CLASS
/
grant select on ALL_XSC_SECURITY_CLASS to select_catalog_role
/
create or replace package xs$catview_util as
function disablebyancestor (sc_name IN VARCHAR2, target_ns IN VARCHAR2,
sc_xml IN XMLType) return XMLType;
end xs$catview_util;
/
create or replace package body xs$catview_util as
/* the hash table used for keeping track of visited ancestors */
/* used as part of cycle detection in security class */
type xs$hash is table of boolean index by varchar2(5024);

/* Given a security class xml this function finds whether the security class
 * is disabled by its ancestor. If yes, it returns the ancestor by which
 * the security class is disabled and the ancestors target_namespace*/ 
function disablebyancestor_int (visited_list IN OUT xs$hash, sc_xml IN XMLType) 
return XMLType is
enable VARCHAR2(5);
parent VARCHAR2(1024);
parent_target_ns VARCHAR2(4000);
parent_sc_name VARCHAR2(5024);
parent_sc XMLType;
nodelist XMLSequenceType;
result XMLType;
begin 
/* select the parents of the security class in a XMLSequenceType*/
select XMLSequence(extract(sc_xml,'/securityClass/inherits-from'))
       into nodelist from dual;

/* loop through the parents */
for x in 1..nodelist.count() loop
    /* get parent name */
    select substr(REGEXP_REPLACE(extractValue(nodelist(x),
    '/inherits-from','xmlns="http://xmlns.oracle.com/xs"'),
    '(.+):(.+)', '\2'),1,1024) into parent from dual;
    
    /* get parent target namespace */
    select substr(SYS_XMLEXNSURI(nodelist(x),'/inherits-from',
    'xmlns="http://xmlns.oracle.com/xs"'),1,4000)
    into parent_target_ns from dual;
   
    parent_sc_name := parent_target_ns ||':'|| parent;
    /* check if there is cycle in security classes */
    /* i.e there is an entry for parent in hash table */ 
      if visited_list.exists(parent_sc_name) then
          return xmltype ('<disablebyancestor></disablebyancestor>');
      end if;
       /* put parent in visited list */
        visited_list(parent_sc_name) := TRUE;   
       /* beginnig of the exception block */
        begin
       /* get parent securty class xml */
       /* will throw no data found exception if parent doesn't exist */
       select OBJECT_VALUE into parent_sc from XDB.XS$SECURITYCLASS
          where 
       (substr(extractValue(OBJECT_VALUE,'/securityClass/@name'),1,1024)=parent)
          and
       (substr(extractValue(OBJECT_VALUE,'/securityClass/@targetNamespace'),
          1,4000)=parent_target_ns);
       /* get enable attribute of parent */
        select substr(extractValue(parent_sc,'/securityClass/@enable'),1,5) 
        into enable from dual; 
    
       /* if parent is disabled */
        if enable = 'false' then 
           /* return the result as xmltype */
           return xmltype('<disablebyancestor enable="false">
                  <parent>'||parent||'</parent>
                  <parent_target_ns>'||parent_target_ns||'
                  </parent_target_ns>
                  </disablebyancestor>');
       /* if parent is not directly disabled */
         else
           /* check whether it is disabled by its ancestor */
           result := disablebyancestor_int(visited_list,parent_sc) ;

	   /* delete entry from hash table once the recursive call returns */
	   visited_list.delete(parent_sc_name) ;

	   /* check the enable attribute in retuirned result */
           select substr(extractValue(result,'/disablebyancestor/@enable'),1,5) 
           into enable from dual;

           /* if parent is disabled by its ancestor */
	   /* or there was a cycle in security class */
           if (enable = 'false') or (enable is null) then
              return result;
           end if;
         end if;
    
        /* exception is thrown when parent security class is not found */
         exception
           when no_data_found then
         return xmltype ('<disablebyancestor></disablebyancestor>');    
         end;
 end loop;
 
 /* If security class is not disabled by any of its parent */
 return xmltype('<disablebyancestor enable="true"></disablebyancestor>');
end disablebyancestor_int;

/* Given a security class name and target namespace this function 
 * finds whether the security class is disabled by its ancestor
 * If security class is disabled by ancestor it returns the ancestor
 * and the target namespace of the ancestor. The result is returned
 * as xmltype */
 
function disablebyancestor(sc_name IN VARCHAR2,target_ns IN VARCHAR2, 
sc_xml IN XMLType) return XMLType is
visited_list xs$hash;
result XMLType;
begin
 visited_list(target_ns ||':'|| sc_name) := TRUE;
 result := disablebyancestor_int(visited_list,sc_xml);
 return result;
end disablebyancestor;
end xs$catview_util;
/

grant execute on xs$catview_util to select_catalog_role;
/

CREATE OR REPLACE view ALL_XSC_SECURITY_CLASS_STATUS
  (CLASS_NAME,TARGET_NAMESPACE, ENABLE, 
   DISABLED_BY_CLASS_NAME,DISABLED_BY_CLASS_TARGET_NS, 
   MUTABLE)
as
select
   substr(extractValue(OBJECT_VALUE,
   '/securityClass/@name'),1,1024),
   substr(extractValue(OBJECT_VALUE,
   '/securityClass/@targetNamespace'),1,4000),
   substr(extractValue(OBJECT_VALUE,
   '/securityClass/@enable'),1,5),
   null,
   null,
   substr(extractValue(OBJECT_VALUE,
   '/securityClass/@mutable'),1,5)
from XDB.XS$SECURITYCLASS  
where substr(extractValue(OBJECT_VALUE,
      '/securityClass/@enable'),1,5)='false'
      or
      extract(OBJECT_VALUE,
      '/securityClass/inherits-from') is NULL
union all
select
    substr(extractValue(securityclass,
    '/securityClass/@name'),1,1024),
    substr(extractValue(securityclass,
    '/securityClass/@targetNamespace'),1,4000),
    substr(extractValue(disablebyxml,'/disablebyancestor/@enable'),1,5),
    substr(extractValue(disablebyxml,'/disablebyancestor/parent'),1,1024),
    substr(extractValue(disablebyxml,'/disablebyancestor/parent_target_ns'),1,4000),
    substr(extractValue(securityclass,'/securityClass/@mutable'),1,5)
from (select OBJECT_VALUE securityclass,
          xs$catview_util.disablebyancestor(substr(extractValue(OBJECT_VALUE,
          '/securityClass/@name'),1,1024),substr(extractValue(OBJECT_VALUE,
          '/securityClass/@targetNamespace'),1,4000),OBJECT_VALUE) disablebyxml 
	  from XDB.XS$SECURITYCLASS) tab
where substr(extractValue(securityclass,
      '/securityClass/@enable'),1,4)='true'
     and 
     extract(securityclass,
     '/securityClass/inherits-from') is not NULL;

comment on table ALL_XSC_SECURITY_CLASS_STATUS is
'Security class "enable" and "mutable" status'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.CLASS_NAME is
'The name of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.TARGET_NAMESPACE is
'The target namespace for the security class'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.ENABLE is
'enable status of security class'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.DISABLED_BY_CLASS_NAME is
'The target name of the ancestor by which security class is disabled'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.DISABLED_BY_CLASS_TARGET_NS is
'The target namespace for the ancestor by which security class is disabled'
/
comment on column ALL_XSC_SECURITY_CLASS_STATUS.MUTABLE is
'True if security class is mutable,else false'
/
create or replace public synonym ALL_XSC_SECURITY_CLASS_STATUS
 for ALL_XSC_SECURITY_CLASS_STATUS
/
grant select on ALL_XSC_SECURITY_CLASS_STATUS to select_catalog_role
/
create or replace view ALL_XSC_SECURITY_CLASS_DEP
  (CLASS_NAME, CLASS_TARGET_NAMESPACE,
   PARENT_CLASS_NAME, PARENT_CLASS_TARGET_NAMESPACE)
as
select
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@name'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   substr(REGEXP_REPLACE(extractValue(value(ancestors),
        '/inherits-from', 'xmlns="http://xmlns.oracle.com/xs"'),
      '(.+):(.+)', '\2'),
    1, 4000),
   substr(SYS_XMLEXNSURI(value(ancestors),
      '/inherits-from', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 4000)
from XDB.XS$SECURITYCLASS p,
       table(XMLSequence(
         extract(p.OBJECT_VALUE, '/securityClass/inherits-from'))
       ) ancestors;

comment on table ALL_XSC_SECURITY_CLASS_DEP is
'All security class dependencies in the database'
/
comment on column ALL_XSC_SECURITY_CLASS_DEP.CLASS_NAME is
'The name of the security class'
/
comment on column ALL_XSC_SECURITY_CLASS_DEP.CLASS_TARGET_NAMESPACE is
'The target namespace for the security class'
/
comment on column ALL_XSC_SECURITY_CLASS_DEP.PARENT_CLASS_NAME is
'The name of a parent security class'
/
comment on column ALL_XSC_SECURITY_CLASS_DEP.PARENT_CLASS_TARGET_NAMESPACE is
'The target namespace for the parent security class'
/
create or replace public synonym ALL_XSC_SECURITY_CLASS_DEP
   for ALL_XSC_SECURITY_CLASS_DEP
/
grant select on ALL_XSC_SECURITY_CLASS_DEP to select_catalog_role
/

create or replace view ALL_XSC_PRIVILEGE
  (CLASS_NAME, TARGET_NAMESPACE, PRIVILEGE_NAME, TITLE, DESCRIPTION)
as
select
   substr(extractValue(value(s), 
    '/s:securityClass/@name', 'xmlns:s="http://xmlns.oracle.com/xs"'), 
    1, 1024),
   substr(extractValue(value(s), 
  '/s:securityClass/@targetNamespace', 'xmlns:s="http://xmlns.oracle.com/xs"'), 
    1, 4000),
   substr(extractValue(value(privs), 
    '/privilege/@name', 'xmlns="http://xmlns.oracle.com/xs"'), 
    1, 1024),
   extractValue(value(titles),
    '/title', 'xmlns="http://xmlns.oracle.com/xs"'),
   extractValue(value(descriptions),
    '/description', 'xmlns="http://xmlns.oracle.com/xs"')
from XDB.XS$SECURITYCLASS p,
     table(XMLSequence(
       extract(p.OBJECT_VALUE, '/securityClass', 'xmlns="http://xmlns.oracle.com/xs"'))
     ) s,
     table(XMLSequence(
       extract(value(s), '/securityClass/privilege', 'xmlns="http://xmlns.oracle.com/xs"'))
     ) privs,
     table(XMLSequence(
       extract(value(privs), '/privilege/title',  
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) (+) titles,
     table(XMLSequence(
       extract(value(privs), '/privilege/description', 
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) (+) descriptions;


comment on table ALL_XSC_PRIVILEGE is
'All mappings of privileges to security classes in the database'
/
comment on column ALL_XSC_PRIVILEGE.CLASS_NAME is
'The name of the security class'
/
comment on column ALL_XSC_PRIVILEGE.TARGET_NAMESPACE is
'The target namespace for the security class'
/
comment on column ALL_XSC_PRIVILEGE.PRIVILEGE_NAME is
'The name of a privilege defined in the specified security class'
/
comment on column ALL_XSC_PRIVILEGE.TITLE is
'Title of the privilege'
/
comment on column ALL_XSC_PRIVILEGE.DESCRIPTION is
'Description of the privilege'
/
create or replace public synonym ALL_XSC_PRIVILEGE
   for ALL_XSC_PRIVILEGE
/
grant select on ALL_XSC_PRIVILEGE to select_catalog_role
/

create or replace view ALL_XSC_AGGREGATE_PRIVILEGE
  (AGGREGATE_PRIVILEGE_NAME, AGGREGATE_PRIVILEGE_TARGET_NS,
   TITLE, DESCRIPTION, PRIVILEGE_NAME, PRIVILEGE_TARGET_NAMESPACE)
as
select
   substr(extractValue(value(aggregates),
    '/aggregatePrivilege/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   extractValue(value(titles),
    '/title', 'xmlns="http://xmlns.oracle.com/xs"'),
   extractValue(value(descriptions),
    '/description', 'xmlns="http://xmlns.oracle.com/xs"'),
   REGEXP_REPLACE(substr(extractValue(value(privrefs),
                                      '/privilegeRef/@name', 
                                      'xmlns="http://xmlns.oracle.com/xs"'), 
                         1, 1024),
                  '(.+):(.+)', '\2'),
   substr(
     SYS_XMLEXNSURI(value(privrefs),
       '/privilegeRef/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 4000)
from XDB.XS$SECURITYCLASS p,
     table(XMLSequence(
       extract(p.OBJECT_VALUE, '/securityClass/aggregatePrivilege'))
     ) aggregates,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/privilegeRef',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) privrefs,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/title',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) titles,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/description',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) descriptions
union all
select
   substr(extractValue(value(aggregates),
    '/aggregatePrivilege/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   NULL,
   NULL,
   REGEXP_REPLACE(substr(extractValue(value(privrefs),
                                      '/privilegeRef/@name', 
                                      'xmlns="http://xmlns.oracle.com/xs"'), 
                         1, 1024),
                  '(.+):(.+)', '\2'),
   substr(
     SYS_XMLEXNSURI(value(privrefs),
       '/privilegeRef/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 4000)
from XDB.XS$SECURITYCLASS p,
     table(XMLSequence(
       extract(p.OBJECT_VALUE, '/securityClass/aggregatePrivilege'))
     ) aggregates,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/privilegeRef',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) privrefs
union all
select
   substr(extractValue(value(aggregates),
    '/aggregatePrivilege/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   NULL,
   extractValue(value(descriptions),
    '/description', 'xmlns="http://xmlns.oracle.com/xs"'),
   REGEXP_REPLACE(substr(extractValue(value(privrefs),
                                      '/privilegeRef/@name', 
                                      'xmlns="http://xmlns.oracle.com/xs"'), 
                         1, 1024),
                  '(.+):(.+)', '\2'),
   substr(
     SYS_XMLEXNSURI(value(privrefs),
       '/privilegeRef/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 4000)
from XDB.XS$SECURITYCLASS p,
     table(XMLSequence(
       extract(p.OBJECT_VALUE, '/securityClass/aggregatePrivilege'))
     ) aggregates,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/privilegeRef',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) privrefs,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/description',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) descriptions
union all
select
   substr(extractValue(value(aggregates),
    '/aggregatePrivilege/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 1024),
   substr(extractValue(OBJECT_VALUE,
    '/securityClass/@targetNamespace'),
    1, 4000),
   extractValue(value(titles),
    '/title', 'xmlns="http://xmlns.oracle.com/xs"'),
   NULL,
   REGEXP_REPLACE(substr(extractValue(value(privrefs),
                                      '/privilegeRef/@name', 
                                      'xmlns="http://xmlns.oracle.com/xs"'), 
                         1, 1024),
                  '(.+):(.+)', '\2'),
   substr(
     SYS_XMLEXNSURI(value(privrefs),
       '/privilegeRef/@name', 'xmlns="http://xmlns.oracle.com/xs"'),
    1, 4000)
from XDB.XS$SECURITYCLASS p,
     table(XMLSequence(
       extract(p.OBJECT_VALUE, '/securityClass/aggregatePrivilege'))
     ) aggregates,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/privilegeRef',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) privrefs,
     table(XMLSequence(
       extract(value(aggregates), '/aggregatePrivilege/title',
               'xmlns="http://xmlns.oracle.com/xs"'))
     ) titles;

comment on table ALL_XSC_AGGREGATE_PRIVILEGE is
'All privileges that make up an aggregate privilege in the database'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.AGGREGATE_PRIVILEGE_NAME is
'The name of the aggregate privilege'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.AGGREGATE_PRIVILEGE_TARGET_NS is
'The target namespace for the aggregate privilege'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.TITLE is
'Title of the aggregate privilege'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.DESCRIPTION is
'Description of the aggregate privilege'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.PRIVILEGE_NAME is
'Name of a privilege defined in the specified aggregate privilege'
/
comment on column ALL_XSC_AGGREGATE_PRIVILEGE.PRIVILEGE_TARGET_NAMESPACE is
'The target namespace for this privilege'
/
create or replace public synonym ALL_XSC_AGGREGATE_PRIVILEGE
   for ALL_XSC_AGGREGATE_PRIVILEGE
/
grant select on ALL_XSC_AGGREGATE_PRIVILEGE to select_catalog_role
/

Rem Fixed view for enabled lightweigh session roles
create or replace view XS_SESSION_ROLES (ROLE, UUID, DBID, FLAGS)
as
select u.role_name, u.uuid, u.dbid, u.flags
from x$xs_session_roles u;
/
comment on table XS_SESSION_ROLES is
'Roles enabled in the current lightweight session'
/
comment on column XS_SESSION_ROLES.ROLE is
'Role name'
/
comment on column XS_SESSION_ROLES.UUID is
'UUID of role'
/
comment on column XS_SESSION_ROLES.DBID is
'Database internal ID of role'
/
comment on column XS_SESSION_ROLES.FLAGS is
'Status flags'
/

create or replace public synonym XS_SESSION_ROLES for XS_SESSION_ROLES;
grant select on XS_SESSION_ROLES to PUBLIC;

Rem Fixed view for xs$session namespace
create or replace view v$xs_session as
select *
from xs$sessions with read only;
create or replace public synonym V$XS_SESSION for v$xs_session ;
grant select on V$XS_SESSION to DBA;

Rem Fixed view for all lightweight session roles
create or replace view v$xs_session_role (name, roleid, uuid, lwsid) as
  select rolename, roleintid, roleid, sid
    from xs$session_roles where roleflags = 1 with read only;
create or replace public synonym V$XS_SESSION_ROLE for v$xs_session_role;
grant select on V$XS_SESSION_ROLE to DBA;

Rem Fixed view for all lightweight session namespaces and attributes
create or replace view v$xs_session_attribute (lwsid, namespace, name, value,
                                               acloid, event_handler) as
  select sid, nsname, attrname, attrvalue, nsacloid, nshandler
    from xs$session_appns with read only;
create or replace public synonym V$XS_SESSION_ATTRIBUTE for v$xs_session_attribute;
grant select on V$XS_SESSION_ATTRIBUTE to DBA;

Rem Event handlers for eXtensible Security events
@@prvtkzxu.plb

Rem Mid-Tier Cache related packages
@@prvtkzxh.plb

@@prvtkzxevents.plb

Rem Create network ACL security packages
@@dbmsnacl
@@prvtnacl.plb

--Enable xml index
--alter index xdb.prin_xidx enable;
--alter index xdb.sc_xidx enable;
