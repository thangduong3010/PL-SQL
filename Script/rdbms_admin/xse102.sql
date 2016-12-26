Rem
Rem $Header: rdbms/admin/xse102.sql /st_rdbms_11.2.0/2 2013/03/05 06:24:41 apfwkr Exp $
Rem
Rem xse102.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xse102.sql - XS downgrade to 10.2
Rem
Rem    DESCRIPTION
Rem      This script downgrades Fusion Security to 10.2
Rem
Rem    NOTES
Rem      It is invoked from the XDB top-level downgrade script
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/01/13 - Backport yanlili_bug-13886408 from
Rem    apfwkr      12/27/12 - Backport mkandarp_bug-13683089 from main
Rem    dsirmuka    04/28/10 - #8865038.Drop dbms_xds,dbms_xdsutl in e1101000.sql
Rem    rburns      11/06/07 - add 11.1 XS downgrade
Rem    jsamuel     01/25/07 - downgrade changes for XS project branch
Rem    taahmed     12/06/06 - lrg-2672498
Rem    pthornto    10/11/06 - changing order of statements
Rem    mhho        08/31/06 - drop XS$NULL on downgrade
Rem    rpang       06/27/06 - drop PL/SQL network ACL security objects
Rem    clei        06/15/06 - drop data security specific objects
Rem    mhho        06/11/06 - drop lightweight session views 
Rem    pthornto    06/09/06 - drop XS$CACHE tables 
Rem    pnath       06/07/06 - drop document_links_2 
Rem    pthornto    05/11/06 - mid-tier cache stuff 
Rem    srtata      05/23/06 - drop packages to fix lrg 2214041 
Rem    mhho        05/12/06 - drop synonym for xs_session_roles fixed view 
Rem    petam       04/11/06 - Created
Rem

Rem ===================================================================
Rem BEGIN XS Downgrade from Current Release to 11.1
Rem ===================================================================

@@xse111.sql

Rem ===================================================================
Rem END XS Downgrade from Current Release to 11.1
Rem ===================================================================

Rem ===================================================================
Rem BEGIN XS Downgrade from Current Release to 10.2
Rem ===================================================================

-- Drop PL/SQL network ACL security objects
@@nacle102.sql

-- Drop the repository events
-- These must be dropped before the documents can be dropped below.
BEGIN
  DBMS_ResConfig.DeleteRepositoryResConfig(6);
  DBMS_ResConfig.DeleteRepositoryResConfig(5);
  DBMS_ResConfig.DeleteRepositoryResConfig(4);
  DBMS_ResConfig.DeleteRepositoryResConfig(3);
  DBMS_ResConfig.DeleteRepositoryResConfig(2);
  DBMS_ResConfig.DeleteRepositoryResConfig(1);
  DBMS_ResConfig.DeleteRepositoryResConfig(0);
END;
/

--downgrade for catzxs.sql
--remove all the resources created under sys/xs
DECLARE
  CURSOR c1 IS
    SELECT ANY_PATH p FROM RESOURCE_VIEW
      WHERE under_path(RES, '/sys/xs', 1) = 1
      ORDER BY depth(1) DESC;
  del_stmt VARCHAR2(500)
    := 'DELETE FROM RESOURCE_VIEW WHERE equals_path(RES, :1)=1';
BEGIN
  FOR r1 IN c1 LOOP
    EXECUTE IMMEDIATE del_stmt USING r1.p;
  END LOOP;
  DELETE FROM RESOURCE_VIEW WHERE EQUALS_PATH(res,'/sys/xs')=1;
END;
/

begin
dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/principal.xsd',
                            dbms_xmlschema.delete_cascade_force);
end;
/

begin
dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/roleset.xsd',
                             dbms_xmlschema.delete_cascade_force);
end;
/

begin
dbms_xmlschema.deleteschema(
schemaurl => 'http://xmlns.oracle.com/xs/dataSecurity.xsd',
delete_option =>dbms_xmlschema.DELETE_CASCADE_FORCE);
end;
/

begin
dbms_xmlschema.deleteschema(
schemaurl => 'http://xmlns.oracle.com/xs/aclids.xsd',
delete_option =>dbms_xmlschema.DELETE_CASCADE_FORCE);
end;
/

BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
    SCHEMAURL => 'http://xmlns.oracle.com/xs/securityclass.xsd',
    DELETE_OPTION => dbms_xmlschema.DELETE_CASCADE_FORCE);
END;
/

-- Drop Fusion Security specific VPD policies and triggers
DECLARE
  CURSOR xds_cur IS
   SELECT OBJECT_OWNER own, OBJECT_NAME obj, POLICY_NAME pol,
          FUNCTION pfn, PACKAGE pkg, POLICY_TYPE pty
     FROM DBA_POLICIES WHERE POLICY_TYPE like 'XDS%';
  trignam VARCHAR2(30);
  triglen INTEGER;
  stmt    VARCHAR2(1024);
begin
  for pr in xds_cur loop
-- drop static instance set synchronization trigger for XDS3 policies
    if (pr.pty = 'XDS3') then
      begin
        if (pr.pkg is null) then
          trignam := pr.pfn;
        else
          triglen := length(pr.pfn) - 3;
          trignam := substr(pr.pfn, 0, triglen);
        end if;
        stmt := 'DROP TRIGGER "' || pr.own || '"."' || trignam || '"';
        execute immediate stmt;
      exception
        when others then
          null;
      end;
    end if;

-- drop the policy
    begin
      stmt := 'BEGIN dbms_rls.drop_policy(''"' || replace(pr.own,'''','''''') 
               || '"'',''"' || replace(pr.obj,'''','''''')
               || '"'',''' || replace(pr.pol,'''','''''') || '''); END;';
      execute immediate stmt;
    exception
      when others then
        null;
    end;
  end loop;
end;
/

drop public synonym DBA_XDS_OBJECTS;
drop public synonym ALL_XDS_OBJECTS;
drop public synonym USER_XDS_OBJECTS;
drop public synonym DBA_XDS_INSTANCE_SETS;
drop public synonym ALL_XDS_INSTANCE_SETS;
drop public synonym USER_XDS_INSTANCE_SETS;
drop public synonym DBA_XDS_ATTRIBUTE_SECS;
drop public synonym ALL_XDS_ATTRIBUTE_SECS;
drop public synonym USER_XDS_ATTRIBUTE_SECS;
drop public synonym ALL_XSC_SECURITY_CLASS;
drop public synonym ALL_XSC_SECURITY_CLASS_DEP;
drop public synonym ALL_XSC_PRIVILEGE;
drop public synonym ALL_XSC_AGGREGATE_PRIVILEGE;
drop public synonym XS$CACHE_ACTIONS;
drop public synonym XS$CACHE_DELETE;
drop public synonym XS_SESSION_ROLES;
drop public synonym DOCUMENT_LINKS2;
drop public synonym V$XS_SESSION;
drop public synonym V$XS_SESSION_ROLE;
drop public synonym V$XS_SESSION_ATTRIBUTE;

drop view sys.DBA_XDS_OBJECTS;
drop view sys.ALL_XDS_OBJECTS;
drop view sys.USER_XDS_OBJECTS;
drop view sys.DBA_XDS_INSTANCE_SETS;
drop view sys.ALL_XDS_INSTANCE_SETS;
drop view sys.USER_XDS_INSTANCE_SETS;
drop view sys.DBA_XDS_ATTRIBUTE_SECS;
drop view sys.ALL_XDS_ATTRIBUTE_SECS;
drop view sys.USER_XDS_ATTRIBUTE_SECS;
drop view sys.ALL_XSC_SECURITY_CLASS;
drop view sys.ALL_XSC_SECURITY_CLASS_DEP;
drop view sys.ALL_XSC_PRIVILEGE;
drop view sys.ALL_XSC_AGGREGATE_PRIVILEGE;
drop view sys.XS_SESSION_ROLES;
drop view xdb.DOCUMENT_LINKS2;
drop view V$XS_SESSION;
drop view V$XS_SESSION_ROLE;
drop view V$XS_SESSION_ATTRIBUTE;

-- Drop event handlers packages
drop package dbms_xs_roleset_events_int;
drop package dbms_xs_principal_events_int;
drop package dbms_xs_principals;
drop package dbms_xs_principals_int;
drop package dbms_xs_data_security_events;
drop package dbms_xs_secclass_events;
drop package dbms_xs_mtcache;
drop package dbms_xs_mtcache_ffi;
drop library dbms_xsu_lib;
drop library dbms_xsh_lib;
drop table xdb.xs$cache_delete;
drop table xdb.xs$cache_actions;
drop user XS$NULL cascade;

Rem ===================================================================
Rem END XS downgrade to 10.2
Rem ===================================================================

