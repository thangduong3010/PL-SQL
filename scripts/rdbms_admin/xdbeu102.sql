Rem
Rem $Header: rdbms/admin/xdbeu102.sql /st_rdbms_11.2.0/1 2011/06/07 12:30:50 juding Exp $
Rem
Rem xdbeu102.sql
Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbeu102.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juding      05/26/11 - Backport badeoti_bug-10168805 from main
Rem    spetride    09/15/09 - issue warning if ACLs with 0 ACEs exist in the db
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    rburns      11/11/07 - move object downgrade actions
Rem    rangrish    07/10/07 - remove new WS roles, add old ones
Rem    rpang       05/04/07 - remove PublishedContentServlet
Rem    vkapoor     04/27/07 - lrg 2941734
Rem    vkapoor     04/16/07 - bug 5640175
Rem    rpang       12/01/06 - remoev anonymousServletRole for PL/SQL servlets
Rem    pthornto    10/09/06 - remove call to zxse102
Rem    rmurthy     06/22/06 - delete csx forms of xlink and xinclude schemas 
Rem    spetride    07/21/06 - moved token table downgrade to xdbe1m102.sql
Rem    spetride    07/13/06 - token tables downgrade
Rem    rtjoa       07/10/06 - Additional check to verify all XDB XMLindexes 
Rem                           are dropped 
Rem    rmurthy     06/12/06 - drop acl index objects 
Rem    rmurthy     06/02/06 - fix xinclude deletion 
Rem    pnath       04/13/06 - drop all $dl triggers during downgrade 
Rem    petam       06/05/06 - remove the digest elements 
Rem    smalde      03/12/06 - Add dbms_xmltranslations 
Rem    mrafiq      05/22/06 - dropping acl-evaluation-method from 
Rem                           xdbconfig.xml 
Rem    pbelknap    03/26/06 - report framework servlet downgrade
Rem    petam       04/11/06 - separate out fusion security downgrade 
Rem    abagrawa    03/28/06 - Remove more views 
Rem    pknaggs     03/24/06 - drop Extensible Security Class Catalog Views.
Rem    mrafiq      03/16/06 - 
Rem    abagrawa    03/14/06 - Add ACL/xdbconfig downgrade 
Rem    cchui       03/02/06 - drop extensible security packages 
Rem    taahmed     03/06/06 - 
Rem    smalde      12/19/05 - Contentsize upgrade/downgrade 
Rem    taahmed     01/18/06 - downgrade for extensible security resource 
Rem                           folders 
Rem    thbaby      01/06/06 - drop procedure setmodflg 
Rem    mrafiq      10/10/05 - removing xdbresconfig schema if registered 
Rem    sidicula    06/29/05 - sidicula_le
Rem    fge         12/15/04 - Created
Rem

Rem ================================================================
Rem BEGIN XDB User data downgrade to 11.1.0
Rem ================================================================

@@xdbeu111.sql

Rem ================================================================
Rem END XDB User data downgrade to 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB User data downgrade to 10.2.0
Rem ================================================================

-- Remove NFS job
DECLARE
  c number;                   
BEGIN  
  select count(*) into c
  from ALL_SCHEDULER_JOBS
  where JOB_NAME = 'XMLDB_NFS_CLEANUP_JOB';
       
  if c != 0 then
    dbms_scheduler.drop_job('SYS.XMLDB_NFS_CLEANUP_JOB' , true);
  end if;

  select count(*) into c
  from ALL_SCHEDULER_JOB_CLASSES
  where JOB_CLASS_NAME = 'XMLDB_NFS_JOBCLASS';

  if c != 0 then
    dbms_scheduler.drop_job_class('SYS.XMLDB_NFS_JOBCLASS', TRUE);
  end if;
  execute immediate 'delete from noexp$ where name = :1' using 'XMLDB_NFS_JOBCLASS';
end;
/

-- This function removes acl-evaluation-method from xmlconfig.xml
-- as part of downgrade. This is done to remove PD information
create or replace procedure remove_xdbconfig_data_elements as
  configxml sys.xmltype;
  doc       dbms_xmldom.DOMDocument;
  dn        dbms_xmldom.DOMNode;
  de        dbms_xmldom.DOMElement;
  nl        dbms_xmldom.DOMNodeList;
  sysn      dbms_xmldom.DOMNode;
  syse      dbms_xmldom.DOMElement;
  cn        dbms_xmldom.DOMNode;
  begin
-- Select the resource and set it into the config
  select sys_nc_rowinfo$ into configxml from xdb.xdb$config ;

  doc  := dbms_xmldom.newDOMDocument(configxml);
  dn   := dbms_xmldom.makeNode(doc);
  dn   := dbms_xmldom.getFirstChild(dn);
  de   := dbms_xmldom.makeElement(dn);

  nl   := dbms_xmldom.getChildrenByTagName(de, 'sysconfig');
  sysn := dbms_xmldom.item(nl, 0);
  syse := dbms_xmldom.makeElement(sysn);

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'acl-evaluation-method');

  if not(dbms_xmldom.isNull(nl)) then
    cn := dbms_xmldom.item(nl, 0);
    if not(dbms_xmldom.isNull(cn)) then
      cn := dbms_xmldom.removeChild(sysn, cn);
    end if;
  end if;

  dbms_xdb.cfg_update(configxml);
  commit;

end;
/
show errors;

call remove_xdbconfig_data_elements();

-- Remove new servlets
declare
  cfg_data XMLTYPE;
begin
  cfg_data := dbms_xdb.cfg_get();

  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
            '/servletconfig/servlet-mappings/' ||
            'servlet-mapping[servlet-name=''ReportFmwkServlet'']')
  INTO   cfg_data
  FROM   dual; 

  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
            '/servletconfig/servlet-list/' ||
            'servlet[servlet-name=''ReportFmwkServlet'']')
  INTO   cfg_data
  FROM   dual; 

  -- Remove anonymousServletRole security-role-ref for PL/SQL servlets using
  -- static or anonymous authentication, which have database-username set.
  SELECT deleteXML(
           cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
              '/servletconfig/servlet-list/servlet[plsql/database-username]' ||
              '/security-role-ref[role-name=''anonymousServletRole'']')
  INTO   cfg_data
  FROM   dual; 

  -- Remove PublishedContentServlet
  SELECT deleteXML(
           cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
               '/servletconfig/servlet-mappings'||
               '/servlet-mapping[servlet-name=''PublishedContentServlet'']')
  INTO   cfg_data
  FROM   dual; 

  SELECT deleteXML(
           cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
               '/servletconfig/servlet-list'||
               '/servlet[servlet-name=''PublishedContentServlet'']')
  INTO   cfg_data
  FROM   dual; 

  dbms_xdb.cfg_update(cfg_data);
end;
/

-- Remove new digest elements
-- Remove new http-host/http2-host elements possibly added at 10.2XE
declare
  cfg_data XMLTYPE;
begin
  cfg_data := dbms_xdb.cfg_get();

  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication')
  INTO   cfg_data
  FROM   dual; 

  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host')
  INTO   cfg_data
  FROM   dual; 

  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host')
  INTO   cfg_data
  FROM   dual; 

  dbms_xdb.cfg_update(cfg_data);
end;
/

--this has been moved from xdbeu101.sql to here because during data downgrade 
--from 11g to 10.2 the dbms_xdb package was getting invalid due to 
--the change to root_info table.
-- set the acl of xdbconfig.xml to the bootstrap acl
-- don't care about migrate status since setacl is an idempotent opern
DECLARE
  acl_abspath          VARCHAR2(200);
  b_abspath VARCHAR(20) := '/xdbconfig.xml';
BEGIN
   acl_abspath := '/sys/acls/bootstrap_acl.xml';
   dbms_xdb.setAcl(b_abspath, acl_abspath);	
END;
/

commit; 
Rem delete XInclude, xlink schemas if it exists
begin 
  dbms_xmlschema.deleteschema('http://www.w3.org/2001/XInclude.xsd', 
      dbms_xmlschema.delete_cascade);
exception when others then null;
end;
/

begin 
  dbms_xmlschema.deleteschema('http://www.w3.org/2001/csx.XInclude.xsd', 
      dbms_xmlschema.delete_cascade);
exception when others then null;
end;
/

begin 
  dbms_xmlschema.deleteschema('http://www.w3.org/1999/xlink.xsd', 
      dbms_xmlschema.delete_cascade);
exception when others then null;
end;
/

begin 
  dbms_xmlschema.deleteschema('http://www.w3.org/1999/csx.xlink.xsd', 
      dbms_xmlschema.delete_cascade);
exception when others then null;
end;
/


-- Unset inline trigger flag on hierarchically enabled tables for
-- content size.
declare
        cursor mycur is
        SELECT object_name, object_owner
        FROM   dba_policies v
        WHERE  (policy_name LIKE '%xdbrls%' OR policy_name LIKE '%$xd_%')
        AND    v.function = 'CHECKPRIVRLS_SELECTPF';
begin
        for myrec in mycur
        loop
                xdb.dbms_xdbz0.set_delta_calc_inline_trigflag (
                myrec.object_name, myrec.object_owner, FALSE, FALSE );
        end loop;
end;
/

Rem ================================================================
Rem END XDB User data downgrade to 10.2.0
Rem ================================================================

-- during downgrade to 10.2, we are changing the minOccurs for aces
-- in an ACL from 0 to 1; there could be ACLs in the system that
-- still have 0 aces, though the requirement to support ACLs with
-- no aces was meant only for initial and setup phases of applications,
-- and we should expect downgrade to be typically done after that phase;
-- Issue a warning if such empty ACls exist.

declare
  cnt    number := 0;
  msg    varchar2(30000);
begin
  select count(*) into cnt from xdb.xdb$acl a where existsNode(value(a), '/acl/ace', 'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')=0;
  if (cnt > 0) then
    if (cnt = 1) then
      msg := 'There is ' || cnt || ' ACL in XDB.XDB$ACL table with no ACEs.';
    else
      msg := 'There are ' || cnt || ' ACLs in XDB.XDB$ACL table with no ACEs.';
    end if;
    msg := msg || ' ACLs with no ACEs are now usuable, as ACEs are required to have minOccurs=1 in the downgrade database.';
    msg := msg || ' Such ACLs are not granting privileges to any user and are now schema invalid.';
    msg := msg || ' It is advisable to update such ACLs to include one ACE that denies all privileges.';
    dbms_system.ksdwrt(2, msg);
  end if;
  exception
    when others then
       NULL;
end;
/
