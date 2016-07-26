Rem
Rem $Header: rdbms/admin/xdbu111.sql /st_rdbms_11.2.0/6 2013/07/31 14:30:10 dmelinge Exp $
Rem
Rem xdbu111.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbu111.sql - XDB Upgrade from 11.1.0
Rem
Rem    DESCRIPTION
Rem      This script performs upgrade actions to upgrade from 11.1.0
Rem      to the current release
Rem
Rem    NOTES
Rem      It is invoked by xdbdbmig.sql and by xdbu102.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    07/26/13 - Backout RFI 532712, lrg 8504203
Rem    stirmizi    12/06/12 - creating xdb.xdb$import_tt_info
Rem    dmelinge    04/23/12 - Downgrade changes for FTP host name
Rem    dmelinge    04/13/12 - Add host-name under ftp-config
Rem    dmelinge    03/19/12 - Remove unnecessary privileges on DOCUMENT_LINKS
Rem    juding      05/26/11 - Backport badeoti_bug-10168805 from main
Rem    bhammers    06/07/10 - bug 9766227, remove 'grant option'
Rem    badeoti     04/22/10 - lrg 4337840, dbms_xmlschema grant option
Rem    thbaby      03/01/10 - add column grppos to xdb.xdb$xidx_imp_t
Rem    badeoti     12/21/09 - set acl/config table access privs
Rem    bhammers    11/10/09 - 8760324, set 'Unstructured Present' flag
Rem                           when upgrading XIDX from 11.1.0.7 to 11.2.0.2
Rem    bhammers    02/12/09 - add indexes to xdb.xdb$element
Rem    spetride    08/07/08 - upgrade for Aplication users and roles
Rem    achoi       11/13/08 - lrg3678340: move xdb_pi_trig to SYS
Rem    sidicula    09/25/08 - 
Rem    sichandr    09/23/08 - create XDB$REPOS tables
Rem    rburns      09/30/07 - add 11.1 schema upgrade
Rem    spetride    10/04/07 - create index XDB.XDB$RESOURCE_ACLOID_IDX 
Rem    rburns      08/22/07 - add 11g XDB up/down scripts
Rem    rburns      08/22/07 - Created
Rem

-- temporarily run "s" script here; move to xdbdbmig with re-org
@@xdbs111.sql

/*-----------------------------------------------------------------------*/
/*  Upgrade XMLIndex type */
/*-----------------------------------------------------------------------*/
drop table XDB.XDB$XIDX_IMP_T;
create global temporary table XDB.XDB$XIDX_IMP_T
                                (index_name VARCHAR2(40), 
                                 schema_name VARCHAR2(40),
                                 id VARCHAR2(40), 
                                 data CLOB,
                                 grppos NUMBER)
       on commit preserve rows;
 grant insert, select, delete on XDB.XDB$XIDX_IMP_T to public;

-- create ximetadata_pkg package
CREATE OR REPLACE PACKAGE XDB.ximetadata_pkg AS 
  FUNCTION getIndexMetadata (idxinfo  IN  sys.ODCIIndexInfo,
                           expver   IN  VARCHAR2,
                           newblock OUT number,
                           idxenv   IN  sys.ODCIEnv) return VARCHAR2;
  FUNCTION getIndexMetadataCallback (idxinfo  IN  sys.ODCIIndexInfo,
                                expver   IN  VARCHAR2,
                                newblock OUT number,
                                idxenv   IN  sys.ODCIEnv) return VARCHAR2;
  FUNCTION utlgettablenames(idxinfo  IN  sys.ODCIIndexInfo) return BOOLEAN;

 END ximetadata_pkg;
/

show errors;

CREATE OR REPLACE PACKAGE BODY XDB.ximetadata_pkg AS  
-- 'iterate' is a package level variable used to maintain state across calls 
-- by export in this session. 
 
iterate NUMBER := 0; 

FUNCTION getIndexMetadata (idxinfo  IN  sys.ODCIIndexInfo,
                           expver   IN  VARCHAR2,
                           newblock OUT number,
                           idxenv   IN  sys.ODCIEnv) return VARCHAR2 IS 
 
BEGIN 
 
-- We are generating only one PL/SQL block consisting of one line of code. 
  newblock := 1; 
 
  IF iterate = 0 
  THEN 
-- Increment iterate so we'll know we're done next time we're called. 
    iterate := iterate + 1; 
 
    RETURN getIndexMetadataCallback (idxinfo, expver, newblock, idxenv);
                              
  ELSE 
-- reset iterate for next index 
    iterate := 0; 
-- Return a 0-length string; we won't be called again for this index. 
    RETURN ''; 
  END IF; 
END getIndexMetadata; 

 function getIndexMetadataCallback (idxinfo  IN  sys.ODCIIndexInfo,
                                    expver   IN  VARCHAR2,
                                    newblock OUT number,
                                    idxenv   IN  sys.ODCIEnv)
         return VARCHAR2
  is language C name "QMIX_XMETADATA" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       expver,  expver   INDICATOR,
       newblock,newblock INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCIString);

 FUNCTION utlgettablenames(idxinfo  IN  sys.ODCIIndexInfo) return BOOLEAN
 is language C name "QMIX_TABLEUTILS" library  XDB.XMLINDEX_LIB
      with context
      parameters (
        context,
        idxinfo, idxinfo  INDICATOR struct,
        RETURN            INDICATOR sb4,
        return);

END ximetadata_pkg; 
/

show errors;

grant execute on XDB.ximetadata_pkg to public;
/  
create or replace public synonym ximetadata_pkg for XDB.ximetadata_pkg;
/

-- alter type in xdb.XMLIndexMethods
-- first drop the old definition
 ALTER TYPE xdb.XMLIndexMethods DROP  static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, len_newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2;

-- create new definition
 ALTER TYPE xdb.XMLIndexMethods ADD  static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2;

ALTER TYPE xdb.XMLIndexMethods ADD static function ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, read_only IN PLS_INTEGER, version IN varchar2, context OUT PLS_INTEGER) return BOOLEAN;

ALTER TYPE xdb.XMLIndexMethods ADD static procedure ODCIIndexUtilCleanup (context  IN PLS_INTEGER);

-- create body
create or replace type body xdb.XMLIndexMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;

  static function ODCIIndexUpdPartMetadata(ixdxinfo sys.ODCIIndexInfo,
                                           palist   sys.ODCIPartInfoList,
                                           idxenv   sys.ODCIEnv)
         return NUMBER
  is
  BEGIN
   RETURN ODCICONST.SUCCESS;
  END;

  static function ODCIIndexGetMetadata(idxinfo  IN  sys.ODCIIndexInfo,
                                       expver   IN  VARCHAR2,
                                       newblock OUT number,
                                       idxenv   IN  sys.ODCIEnv)
         return VARCHAR2
  is
  begin
    return XDB.ximetadata_pkg.getIndexMetadata(idxinfo, expver, newblock, idxenv);
  end ODCIIndexGetMetadata; 

  -- path table and secondary indexes on it are already exported in schema-mode
  -- this routine should only expose them for Transportable Tablespaces,
  -- via DataPump
  static function ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, 
                                             read_only IN PLS_INTEGER, 
                                             version IN varchar2, 
                                             context OUT PLS_INTEGER)
         return BOOLEAN
  is
  begin
    return XDB.ximetadata_pkg.utlgettablenames(ia);
  end ODCIIndexUtilGetTableNames;

  static procedure ODCIIndexUtilCleanup (context  PLS_INTEGER)
  is
  begin
    -- dummy routine
    return;
  end ODCIIndexUtilCleanup;

end;
/

show errors;

----------------------------------------------------------------------------
-- Support new partitioning methods
alter indextype XDB.xmlindex
  using XDB.XMLIndexMethods
  with local partition
  with system managed storage tables;


-- temporarily run first part of reload here (redundantly on earlier upgrades)
@@xdbptrl1.sql


Rem ==================================================================
Rem Upgrade XDB Data from 11.1.0
Rem ==================================================================

/*
 * Updates for XDB DEFAULT CONFIG
 */

-- (Re-)Insert the authentication element into xdbconfig.xml
declare
  auth_count      INTEGER := 0;
  auth_frag xmltype;
  cfg xmltype;
begin
   cfg := dbms_xdb.cfg_get();
   begin
   select 1 into auth_count from dual
    where XMLExists(
       'declare namespace c = "http://xmlns.oracle.com/xdb/xdbconfig.xsd";
        /c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication'
        PASSING cfg);
   exception 
     when no_data_found then null;
   end;
 
   -- enable INSERTXMLBEFORE, APPENDCHILDXML, DELETEXML(4)
   -- Turn on rewrite for updxml/delxml/insertxml over collections(128)
   execute immediate 
     'alter session set events ''19027 trace name context forever, level 132'' ';

   if auth_count = 0 then
     auth_frag := xmltype('<authentication xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"><allow-mechanism>basic</allow-mechanism><digest-auth><nonce-timeout>300</nonce-timeout></digest-auth></authentication>');
   else
     -- extract authentication fragment for later re-insertion
     dbms_output.put_line('authentication fragment existed, deleting');
     auth_frag := cfg.extract('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication');
     select deletexml (cfg,
        '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication',
        'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
     into cfg from dual;
   end if;

   dbms_output.put_line('inserting authentication fragment');
   select insertchildxml (cfg,
       '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig',
       'authentication',
       auth_frag,
       'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
   into cfg from dual;
   dbms_output.put_line('updating xdbconfig doc');
   dbms_xdb.cfg_update(cfg); 
  end;
/

/*-----------------------------------------------------------------------*/
/*  Set 'UNSTRUCTURED PRESENT' flag for all XML indexes where flag is not */
/*  yet set.  This is valid because there are only unstructured XML  */
/*  indexes in 11.1.0.7. It is also required because on 11.2 we differentiate */
/*  structured and unstructured component using this flag. */
/*-----------------------------------------------------------------------*/
BEGIN
EXECUTE IMMEDIATE 'UPDATE xdb.xdb$dxptab 
                   SET flags = flags + 268435456 
                   WHERE bitand(flags, 268435456) = 0';
EXCEPTION
  WHEN others THEN dbms_output.put_line('XDBNB: xdb$dxptab flag update failed');
end;
/
commit;
show errors;


create index xdb.xdb$resource_acloid_idx on XDB.XDB$RESOURCE e (e.xmldata.ACLOID);

grant execute on xdb.xdb$nlocks_t to public with grant option;

/*-----------------------------------------------------------------------*/
/*  Create XDB$REPOS table */
/*-----------------------------------------------------------------------*/
CREATE TABLE XDB.XDB$REPOS
(
   obj#         NUMBER NOT NULL,
   flags        NUMBER,
   rootinfo#    NUMBER,
   hindex#      NUMBER,
   hlink#       NUMBER,
   resource#    NUMBER,
   acl#         NUMBER,
   config#      NUMBER,
   dlink#       NUMBER,
   nlocks#      NUMBER,
   stats#       NUMBER,
   checkouts#   NUMBER,
   resconfig#   NUMBER
);

/*-----------------------------------------------------------------------*/
/*  Create XDB$MOUNTS table */
/*-----------------------------------------------------------------------*/
CREATE TABLE XDB.XDB$MOUNTS
(
   dobj#        NUMBER,
   dpath        VARCHAR2(4000),
   sobj#        NUMBER,
   flags        NUMBER
);

begin
  execute immediate 'drop trigger xdb.xdb_pi_trig';
exception
  when others then null;
end;
/

/*************** Create XDB.XDB$IMPORT_TT_INFO table *****************/
begin
   execute immediate
      'create table xdb.xdb$import_tt_info( 
          guid     raw(16), 
          nmspcid      raw(8),
          localname    varchar2(2000),
          flags        raw(4),
          id           raw(8))';
  exception
       when others then
         -- raise no error if table already exists
         NULL;
end;
/

grant select,insert,update,delete on xdb.xdb$import_tt_info to public;

/*-----------------------------------------------------------------------*/
/*  Upgrade for Application user and roles support */
/*-----------------------------------------------------------------------*/
COLUMN :xdbapp_name NEW_VALUE xdbapp_file NOPRINT
VARIABLE xdbapp_name VARCHAR2(50)

declare
  stmt    varchar2(4000);
  cnt     number := 0;
begin
  :xdbapp_name := '@nothing.sql';
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_USERS_AND_ROLES' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt = 0) then
    :xdbapp_name := '@catxdbapp.sql';
  end if;

  exception
     when others then
      :xdbapp_name := '@nothing.sql'; 
end;
/
SELECT :xdbapp_name FROM DUAL;
@&xdbapp_file


-- add app users and groups virtual folders
declare
 ret boolean;
begin
  begin
    ret := 
      xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/application');
    if ret then
      dbms_xdb.setACL('/sys/principals/users/application', 
                      '/sys/acls/bootstrap_acl.xml');
      dbms_output.put_line('added app users');
    end if;
    
    exception
      when others then
        dbms_output.put_line('XDBNB: error adding app users');
  end;  

  begin
    ret := 
      xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/application');
    if ret then
      dbms_xdb.setACL('/sys/principals/groups/application', 
                      '/sys/acls/bootstrap_acl.xml');
      dbms_output.put_line('added app groups');
    end if;

    exception
      when others then
        dbms_output.put_line('XDBNB: error adding app groups');
  end;
end;
/
commit;

/*-----------------------------------------------------------------------*/
/*  Add indexes to xdb.xdb$element */
/*-----------------------------------------------------------------------*/
BEGIN
  /* parent_schema */
  execute immediate 
    'CREATE INDEX xdb.xdb$element_ps ON ' ||
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.parent_schema))';   

  /* propref_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_pr ON ' || 
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.propref_ref))'; 

  /* type_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_tr ON ' ||
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.type_ref))'; 

  /* head_elem_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_her ON ' ||
    '  xdb.xdb$element ct (sys_op_r2o(ct.xmldata.head_elem_ref))';

  /* global */
  execute immediate 
    'CREATE  BITMAP index xdb.xdb$element_global ON ' ||
    '  xdb.xdb$element e (e.xmldata.property.global)';

  /* sequence_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_sk ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.sequence_kid))'; 

  /* choice_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_ck ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.choice_kid))'; 

  /* all_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_ak ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.all_kid))';
EXCEPTION
  WHEN others THEN dbms_output.put_line('XDBNB: xdb$element index not created');
END;
/
commit;

/*-----------------------------------------------------------------------*/
/* Explicit grants to DBA,System; "any" privileges are no more applicable for */
/* XDB tables. Listing these specifically since there are certain tables */
/* for which we dont grant full access by default even to DBA & System. */
/* (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.) */
/*-----------------------------------------------------------------------*/
grant all on XDB.XDB$RESOURCE to dba;
grant all on XDB.XDB$RESOURCE to system with grant option;
grant all on XDB.XDB$H_INDEX to dba;
grant all on XDB.XDB$H_INDEX to system with grant option;
grant all on XDB.XDB$H_LINK to dba;
grant all on XDB.XDB$H_LINK to system with grant option;
grant all on XDB.XDB$D_LINK to dba;
grant all on XDB.XDB$D_LINK to system with grant option;
grant all on XDB.XDB$NLOCKS to dba;
grant all on XDB.XDB$NLOCKS to system with grant option;
grant all on XDB.XDB$WORKSPACE to dba;
grant all on XDB.XDB$WORKSPACE to system with grant option;
grant all on XDB.XDB$CHECKOUTS to dba;
grant all on XDB.XDB$CHECKOUTS to system with grant option;
grant all on XDB.XDB$ACL to dba;
grant all on XDB.XDB$ACL to system with grant option;
grant all on XDB.XDB$CONFIG to dba;
grant all on XDB.XDB$CONFIG to system with grant option;
grant all on XDB.XDB$RESCONFIG to dba;
grant all on XDB.XDB$RESCONFIG to system with grant option;

-- ensure that public has limited privileges on acl table
revoke all on XDB.XDB$ACL from public;
grant select, insert, update, delete on XDB.XDB$ACL to public;
commit;

-- lrg 4337840
-- Remove 'with grant option' by revoking rights and
-- re-granting without grant option.
revoke execute on XDB.DBMS_XMLSCHEMA from public;
revoke execute on XDB.DBMS_XMLSCHEMA_INT from public;

-- Both sys and xdb might appear as grantors, revoke again
BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA_INT from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGGSUM from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGGAVG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.XQSEQUENCEFROMXMLTYPE  from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXMLAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_XMLAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/


grant execute on XDB.DBMS_XMLSCHEMA to public;
grant execute on XDB.DBMS_XMLSCHEMA_INT to public;

BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_XMLAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXMLAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.XQSEQUENCEFROMXMLTYPE to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGGAVG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGGSUM to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

Rem ================================================================
Rem END XDB User Data upgrade from 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN resecure DOCUMENT_LINKS
Rem ================================================================

Rem
Rem DOCUMENT_LINKS was incorrectly granted insert, update, and delete
Rem permissions for PUBLIC.  Revoke them.  Bug 13019222.
Rem

BEGIN
EXECUTE IMMEDIATE 'revoke insert on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke update on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'revoke delete on xdb.document_links from PUBLIC';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1927 THEN NULL;
       -- suppress error if not found
  ELSE raise;
  END IF;
END;
/
show errors;

Rem ================================================================
Rem END resecure DOCUMENT_LINKS
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB User Data upgrade from next release
Rem ================================================================

-- uncomment for next release
--@@xdbu112.sql

Rem ================================================================
Rem END XDB User Data upgrade from next release
Rem ================================================================
