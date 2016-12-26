Rem
Rem $Header: rdbms/admin/catqm.sql /st_rdbms_11.2.0/4 2013/01/10 11:56:46 qyu Exp $
Rem
Rem catqm.sql
Rem
Rem Copyright (c) 1900, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catqm.sql - CAtalog script for sQl xMl management 
Rem
Rem    DESCRIPTION
Rem      Creates the tables and views needed to run the XDB system 
Rem      Run this script like this:
Rem        catqm.sql <XDB_PASSWD> <TABLESPACE> <TEMP_TABLESPACE> <SECURE_FILES_REPO>
Rem          -- XDB_PASSWD: password for XDB user
Rem          -- TABLESPACE: tablespace for XDB 
Rem          -- TEMP_TABLESPACE: temporary tablespace for XDB 
Rem          -- SECURE_FILES_REPO: if YES and compatibility is at least 11.2,
Rem               then XDB repository will be stored as secure files;
Rem               otherwise, old LOBS are used. There is no default value for
Rem               this parameter, the caller must pass either YES or NO.
Rem    NOTES
Rem      Must be run connected as SYS 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         12/26/12 - 16035192: set verify off
Rem    stirmizi    12/06/12 - adding import_tt_info
Rem    spetride    05/16/11 - grant select to select_catalog_role
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during install
Rem    vmedi       05/06/10 - revert 9144511 changes
Rem    badeoti     04/23/10 - 9451814: adding prompt for input parameters
Rem    spetride    12/02/09 - 9144511: disable sch validation for XS
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    yiru        03/06/09 - add XS$NULL into XDB schema list
Rem    spetride    03/06/09 - 8251841: children col in xdb.xdb$h_index 
Rem                           cannot be securefile
Rem    spetride    02/06/09 - lrg 3573827: install trigger to allow sequences
Rem    spetride    01/26/09 - 7714185: document user_opt_secfiles
Rem    spetride    11/15/08 - xdb_installation_trigger: allow triggers
Rem    spetride    06/24/08 - run catxdpapp
Rem    spetride    04/29/08 - option: use secure files for xdb$resource
Rem    sipatel      09/29/08 - bug 7414934. call catxtbix
Rem    sichandr    09/23/08 - load dbmsxdbrepos
Rem    badeoti     09/21/08 - 6451792: add object validation to XDB
Rem    achoi       03/11/08 - register ANONYMOUS as part of XDB
Rem    sidicula    01/10/08 - Grants to dba, system
Rem    thbaby      10/27/07 - split prvtxdb to create prvtxdba
Rem    vkapoor     04/27/07 - lrg 2941734
Rem    vkapoor     04/09/07 - bug 5640175
Rem    bpwang      10/19/06 - bug 5633032
Rem    thbaby      11/02/06 - move dbms_xmlindex package body into prvtxidx
Rem    pthornto    10/09/06 - move catzxs.sql to EOF
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    rtjoa       05/26/06 - change prvtxdz2.plb location
Rem    rmurthy     04/21/06 - add prvtxdz2.plb 
Rem    ataracha    06/08/06 - move dbmsxidx before catxidx
Rem    rmurthy     06/02/06 - call catxdbdl for document links 
Rem    pnath       03/22/06 - add prvtxdbdl.plb 
Rem    pthornto    05/18/06 - add DBMS_XSH_LIB 
Rem    nkhandel    02/20/06 - DOM streaming APIs added 
Rem    smalde      03/09/06 - Add dbms_xmltranslations 
Rem    petam       04/07/06 - separate out the install of ResConfig from ACL 
Rem    abagrawa    03/11/06 - Add xdbready 
Rem    cchui       03/02/06 - move after resconfig package is installed 
Rem    mrafiq      03/06/06 - move catzxs after catxdbpv 
Rem    pnath       02/15/06 - remove link_props from xdb.xdb$d_link 
Rem    rmurthy     02/03/06 - add xdb.d_link table 
Rem    thbaby      02/21/06 - add NFS info into rootinfo
Rem    rtjoa       02/16/06 - Create a schedule for nfsclient cleanup job 
Rem    pnath       10/13/05 - submit job for nfs client cleanup 
Rem    sidicula    01/18/06 - Adding protocol info into rootinfo 
Rem    taahmed     01/18/06 - Extensible Security 
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade 
Rem    thoang      09/22/04 - add dbmsxres.sql & prvtxres.plb 
Rem    ataracha    04/14/04 - add pl/sql dom, xml parser, AND xsl processor
Rem    nkandalu    07/25/05 - 4494717: set upgrade status if XDB is VALID 
Rem    sidicula    06/25/05 - No need for dbmsxadm as yet 
Rem    rmurthy     03/09/05  - drop function for patching namespace 
Rem    vkapoor     01/13/05 -  LRG 1804464 
Rem    pnath       12/01/04 - prvtxdb.sql needs prvtxmld.sql to be compiled 
Rem    pnath       11/16/04 - delete all objects created in installation 
Rem    rpang       11/18/04 - Add catepg.sql
Rem    rmurthy     11/11/04 - add dbmsxidx
Rem    petam       11/11/04 - added execution of xdbinstd.sql
Rem    najain      07/14/04 - add stateid_restart_sequence
Rem    pnath       10/22/04 - Make SYS the owner of package dbms_regxdb 
Rem    fge         10/29/04 - call prvtxdr0
Rem    attran      08/20/04 - xmlidx
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    rpang       07/16/04 - Renamed epgc to epg
Rem    fge         07/08/04 - extend xdb$h_link
Rem    sbalaram    06/10/04 - Add catxlcr - xml schema definitions for LCRs
Rem    rpang       06/07/04 - Add dbmsepgc.sql and prvtepgc.plb
Rem    smukkama    02/27/04 - move catxdbtm.sql to after prvtxdb.sql
Rem    smukkama    01/05/04 - add catxdbtm.sql for compact xml token mgmt
Rem    attran      02/17/04 - XMLIndex 
Rem    najain      01/27/04 - call prvtxdb0 and prvtxdz0
Rem    fge         08/01/03 - xdb$h_link: add secondary index on child_oid
Rem    sidicula    07/03/03 - prvtxdb to be executed after prvtxdbz
Rem    fge         05/19/03 - add catxdbeo.sql
Rem    sidicula    04/16/03 - Revoke powerful privileges from XDB
Rem    abagrawa    03/09/03 - Separate dbmsxsch and prvtxsch
Rem    njalali     02/11/03 - setting upgrade state to 1000
Rem    smuralid    01/09/03 - add dbmsxdbt
Rem    sichandr    12/16/02 - invoke pre-condition checks
Rem    njalali     11/14/02 - making sure 9.2.0.1 -> 9.2.0.2 mig. is noop
Rem    mkrishna    07/05/02 - dissallow ref cascade for resource and schema tables
Rem    fge         06/13/02 - rename prvtpidx.sql to prvtxdbp.sql
Rem    sichandr    04/14/02 - remove index on refcount
Rem    spannala    03/26/02 - tieing the xdb version to the database version
Rem    sidicula    02/22/02 - Anonymous login allowed only by HTTP
Rem    njalali     02/11/02 - removed refcount from H_INDEX
Rem    rmurthy     02/20/02 - remove owner user
Rem    fge         01/20/02 - call prvtxdbr.plb
Rem    fge         01/08/02 - rename prvtxdbpi.sql to prvtpidx.sql
Rem    spannala    01/13/02 - correcting compilation errors in prvtxreg
Rem    spannala    01/02/02 - registry
Rem    sichandr    01/11/02 - catxdbstd.sql becomes catxdbst.sql
Rem    spannala    01/11/02 - creating all types with fixed toids
Rem    rmurthy     01/18/02 - add xdbowner role
Rem    nmontoya    12/18/01 - grant select any table to xdb
Rem    spannala    12/19/01 - removing connects, creating objects in xdb schema
Rem    spannala    12/13/01 - beta showstopper cleanup
Rem    nmontoya    11/29/01 - replace calls of prvt*.sql to prvt*.plb
Rem    nmontoya    11/14/01 - changing owner ID to GUID
Rem    nmontoya    11/13/01 - reorder dbmsxdb pkg
Rem    nagarwal    11/12/01 - change ordering of packages
Rem    tsingh      11/09/01 - XDB Fake installation and cleanup.
Rem    nagarwal    11/08/01 - change ordering of catxdbpi.sql 
Rem    najain      11/08/01 - catxdbpi.sql gets loaded before catxdbz.sql
Rem    nagarwal    11/05/01 - add catxdbpi.sql
Rem    nle         09/20/01 - add versioning package
Rem    abagrawa    09/27/01 - Add catxdbc1, catxdbc2
Rem    nmontoya    10/12/01 - ADD xdbadmin role
Rem    nagarwal    09/08/01 - add catxdbpv
Rem    nmontoya    08/21/01 - ADD pl/sql dom, xml parser, AND xsl processor
Rem    nmontoya    08/16/01 - grant alter session and dbms_rls execute to xdb
Rem    nagarwal    08/10/01 - add catxdbr
Rem    esedlar     08/09/01 - XDB standard packages
Rem    njalali     07/11/01 - Resource as XMLType
Rem    spannala    05/18/01 - xmltype_p -> xmltype
Rem    njalali     05/17/01 - split schema OID in resource into two columns
Rem    rmurthy     03/09/01 - move schema related setup to catxdbs.sql
Rem    tsingh      03/01/01 - load xdb.jar
Rem    njalali     02/15/01 - reinstated the WITH ROWID in the resource table
Rem    nmontoya    02/14/01 - Add security initialization
Rem    njalali     02/13/01 - added schema OID to resource table
Rem    rmurthy     02/02/01 - add support for element ref
Rem    mkrishna    01/29/01 - remove xmlindex related stuff 
Rem    rmurthy     01/17/01 - changes to allow case-sensitive names
Rem    rmurthy     12/01/00 - grant create library to xdb
Rem    esedlar     11/01/00 - Add SQL schema
Rem    njalali     10/03/00 - removed 'datatype' from resource table
Rem    esedlar     09/27/00 - Add schema in uniqueness constraints
Rem    njalali     09/26/00 - removed the 'with rowid' in XDB$RESOURCE.
Rem    tsingh      09/22/00 - added catxdbdt.sql
Rem    nmontoya    09/18/00 - Changing default tablespace for xdb schema.
Rem    esedlar     09/05/00 - Type cache
Rem    njalali     08/15/00 - changed H_LINK to XDB$H_LINK.
Rem    tsingh      06/30/00 - Fix tablespace code.
Rem    tsingh      06/28/00 - sys to system.
Rem    tsingh      06/20/00 - Resource tables.
Rem    mkrishna    06/29/00 - add dbmsxidx 
Rem    njalali     04/20/00 - Initial revision
Rem    njalali     01/00/00 - Created
Rem
 
Rem IMPORTANT: For any object type owned by XDB, if changes are made
Rem with respect to pre-11.2.0.3 versions, do not issue a new 
Rem CREATE TYPE DDL part of XDB installation. Instead, use the 11.2.0.3
Rem CREATE TYPE DDL and follow it by required ALTER TYPE statements
Rem (essentially, the install and upgrade steps for XDB object types 
Rem  should proceed the same). This is to be done so that every XDB
Rem installation has the object type histories at least starting with 
Rem 11.2.0.3, and it is required by full/database export.   

prompt
prompt
prompt Starting Oracle XML DB Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter Parameter #1 <XDB_PASSWD>, password for XDB schema:
define xdb_pass    = &1
prompt
prompt Enter Parameter #2 <TABLESPACE>, tablespace for XDB:
define res_tbs     = &2
prompt
prompt Enter Parameter #3 <TEMP_TABLESPACE>, temporary tablespace for XDB: 
define temp_tbs    = &3
prompt

variable user_opt_secfiles varchar2(30);
variable usesecfiles varchar2(3);

Rem  Determine if secure files will be used for xdb.xdb$resource
Rem
prompt Enter Parameter #4 <SECURE_FILES_REPO>, YES/NO
prompt ...................If YES and compatibility is at least 11.2,
prompt ...................then XDB repository will be stored as secure files.
prompt ...................Otherwise, old LOBS are used
declare
  checkcompat  boolean := FALSE;
begin
  :usesecfiles := 'NO';
  :user_opt_secfiles := '&4';

  -- if no option was passed, try using secure files
  if (nvl(:user_opt_secfiles,'YES') != 'NO') then
     checkcompat := TRUE;
  end if;

  -- secure files can only be used for 11.0.0.0 least compatibility level
  if (checkcompat) then 
    if ((dbms_metadata_util.get_canonical_vsn(dbms_metadata_util.get_compat_vsn()) >= 
         dbms_metadata_util.get_canonical_vsn('11.0.0.0')  )) then
      :usesecfiles := 'YES';
    end if;  
  end if;

  exception
     when others then
        return;
end;
/
prompt
prompt

Rem Table xdb_installation_tab will store all objects created
Rem as a part of XDB installation, where owner is not XDB.
Rem Objects already existing in the database and recreated 
Rem as a part of the installation, will not be added to the table.
Rem This table will be used during un-installation of XDB, 
Rem when all these objects will then be dropped. This table 
Rem need not contain objects which will be dropped automatically 
Rem as a result of dropping some other object 
Rem (eg. all PACKAGE BODY objects will be dropped when corresponding
Rem PACKAGE object is dropped).
Rem Point to note: Currently only certain object types are 
Rem inserted into this table. The creation of objects of 
Rem object type not handled will result in the need to modify 
Rem the trigger responsible for populating xdb_installation_tab.
CREATE TABLE sys.xdb_installation_tab (
   Owner           VARCHAR2(200),
   Object_name     VARCHAR2(200),
   Object_type     VARCHAR2(200));


Rem Table dropped_xdb_instll_tab will consist of the items that
Rem existed prior to XDB installation and were dropped during 
Rem XDB installation. Creation of an object during the installation
Rem that is present in this table will not be added to 
Rem xdb_installation_tab, as this implies that the object did 
Rem exist prior to the installation.
CREATE TABLE sys.dropped_xdb_instll_tab (
   Owner           VARCHAR2(200),
   Object_name     VARCHAR2(200),
   Object_type     VARCHAR2(200));

Rem A trigger for every successful drop on the database during 
Rem XDB installation
create or replace trigger sys.dropped_xdb_instll_trigger
  AFTER
    DROP ON DATABASE
    BEGIN
      insert into dropped_xdb_instll_tab values
          (dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type);
    END;
/

Rem For eXtensible Security required library, cannot do it after the 
Rem install trigger is added
CREATE OR REPLACE LIBRARY DBMS_XSU_LIB TRUSTED AS STATIC;
/
CREATE OR REPLACE LIBRARY DBMS_XSH_LIB TRUSTED AS STATIC;
/

Rem A trigger for every object creation during XDB installation
Rem The trigger body may need to be modified if other object types
Rem are to be handled, which are currently not handled. In addition,
Rem catnoqm.sql might need to be modified to handle special
Rem cases while dropping objects.
create or replace trigger sys.xdb_installation_trigger
  BEFORE
    CREATE ON DATABASE
    DECLARE
       sql_text varchar2(200);
       val number;
    BEGIN
      if (dictionary_obj_owner != 'XDB') then
        if (dictionary_obj_type = 'FUNCTION' or
            dictionary_obj_type = 'INDEX' or
            dictionary_obj_type = 'PACKAGE' or
            dictionary_obj_type = 'PACKAGE BODY' or
            dictionary_obj_type = 'PROCEDURE' or
            dictionary_obj_type = 'SYNONYM' or
            dictionary_obj_type = 'TABLE' or
            dictionary_obj_type = 'TABLESPACE' or
            dictionary_obj_type = 'TYPE' or
            dictionary_obj_type = 'VIEW' or
            dictionary_obj_type = 'USER' or
            dictionary_obj_type = 'TYPE BODY' or
            dictionary_obj_type = 'BODY' or
            dictionary_obj_type = 'TRIGGER' or
            dictionary_obj_type = 'SEQUENCE'
          )then
          if (dictionary_obj_type  != 'PACKAGE BODY' 
             ) then
            sql_text := 'select count(*) from ALL_OBJECTS where owner = :1 and object_name = :2 and object_type = :3';
            execute immediate sql_text into val using dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type;
            if (val = 0) then
               sql_text := 'select count(*) from dropped_xdb_instll_tab where owner = :1 and object_name = :2 and object_type = :3';
               execute immediate sql_text into val using dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type;
               if (val = 0) then
                  insert into xdb_installation_tab values
                  (dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type);
               end if;
            end if;
          end if;
        else
          raise_application_error(-20000, 'Trigger xdb_installation_trigger does not support object creation of type '||dictionary_obj_type); 
        end if;
      end if;
   end;
/

SET VERIFY OFF

Rem Check for pre-conditions
@@catxdbck &xdb_pass &res_tbs &temp_tbs :usesecfiles

Rem Create XDB User.
create user xdb identified by &xdb_pass account lock password expire 
       default tablespace &res_tbs temporary tablespace &temp_tbs;

Rem Invoke Registry. The package is defined later.
EXECUTE dbms_registry.loading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB', 'XDB');
Rem Set parent rowid''s for XDB$H_LINK. Used only by upgrade.

Rem should go away soon
create user anonymous identified by values 'anonymous' default tablespace &res_tbs;
EXECUTE dbms_registry.loading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB', 'XDB', dbms_registry.schema_list_t('ANONYMOUS'));
grant create session to anonymous;
alter user anonymous account lock;

SET VERIFY ON

grant resource to xdb;
grant create session to xdb;
grant alter session to xdb;
GRANT execute ON dbms_rls TO xdb;
grant unlimited tablespace to xdb;
grant create library to xdb;
grant create public synonym to xdb;
grant drop public synonym to xdb;
GRANT SELECT ON user$ TO xdb;

grant execute on dbms_streams_control_adm to xdb;

CREATE role xdbadmin;
GRANT xdbadmin TO dba;

-- Pseudo user that can be used in ACLs to refer to the resource owner
-- create user owner identified by values 'OWNER';

-- Needed for prvtxdbz
grant administer database trigger to xdb;

-- Needed for catxdbj
GRANT javauserpriv TO xdb;

-- Needed by catxdbr and catxdbpi
grant create view to xdb;
grant query rewrite to xdb;
grant create operator to xdb;
grant create indextype to xdb;

-- Needed by catxdbpi
-- This is needed because we are selecting from the hierarchially enabled
-- table (as a part of the path index trigger) while dropping/truncating it.

/* REF CASCADE IS DISSALLOWED FOR SCHEMA AND RESOURCE TABLES */

/* turn off the REF cascade semantics for resource$ */
alter session set events '22830 trace name context forever, level 4';

-- XDB$ROOT_INFO table
create table xdb.xdb$root_info 
(resource_root rowid,
 rclist raw(2000),
 ftp_port number(5),
 ftp_protocol varchar2(4000),
 http_port number(5),
 http_protocol varchar2(4000),
 http_host varchar2(4000),
 http2_port number(5),
 http2_protocol varchar2(4000),
 http2_host varchar2(4000),
 nfs_port number(5),
 nfs_protocol varchar2(4000)
);

-- XDB$XDB_READY table
create table xdb.xdb$xdb_ready
(data CLOB
);

-- XDB.XDB$IMPORT_TT_INFO table
-- needed by prvtxdb
create table xdb.xdb$import_tt_info
(guid         raw(16),
 nmspcid      raw(8),
 localname    varchar2(2000),
 flags        raw(4),
 id           raw(8));

grant select,insert,update,delete on xdb.xdb$import_tt_info to public;

-- XDB$RCLIST view
create view xdb.xdb$rclist_v as (select rclist from xdb.xdb$root_info);

-- This is needed for users to be able to query the repository's rclist
grant select on xdb.xdb$rclist_v to public;

-- XDB$H_INDEX table
-- Note: chidren column cannot be securefiles for now
variable param_secf varchar2(4000);
select value from v$parameter  where name='db_securefile';
begin 
 select value into :param_secf from v$parameter where UPPER(name)='DB_SECUREFILE'; 
end;
/
alter system set db_securefile='NEVER';

create table xdb.xdb$h_index 
  (
    oid raw(16), 
    acl_id raw(16), 
    owner_id raw(16),
    flags raw(4), 
    children BLOB
  ) 
  pctfree 99 pctused 1;

-- revert
declare
  s varchar2(4100);
begin
  s := 'alter system set db_securefile=''' || :param_secf || ''' ';
execute immediate s;
end;
/


CREATE INDEX xdb.xdb$h_index_oid_i ON xdb.xdb$h_index (OID);

create type xdb.xdb$link_t OID '00000000000000000000000000020151' AS OBJECT
(
    parent_oid    raw(16),
    child_oid     raw(16),
    name          varchar2(256),
    flags         raw(4),
    link_sn       raw(16),
    child_acloid  raw(16),
    child_ownerid raw(16),
    parent_rids   raw(2000)
);
/

create table xdb.xdb$h_link of xdb.xdb$link_t
(
    constraint xdb_pk_h_link primary key (parent_oid, name)
);

create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);

-- create document links table
create table xdb.xdb$d_link 
(
  source_id    raw(16),
  target_id    raw(16),
  target_path  varchar2(4000),
  flags        raw(8)
);

create index xdb.xdb$d_link_source_id on xdb.xdb$d_link(source_id);

create index xdb.xdb$d_link_target_id on xdb.xdb$d_link(target_id);

------------------------------------------------------------------------------
create sequence xdb.stateid_restart_sequence
  increment by 1
  start with 1
  minvalue 1
  nocycle
/

create sequence xdb.clientid_sequence
  increment by 1
  start with 1
  minvalue 1
  cache 10
  nocycle
/

Rem Create XML schema related types and tables
@@catxdbs.sql

Rem Add XDB schema for schemas
@@catxdbdt.sql

Rem Create XML resource schema related types and tables
@@catxdbrs.sql :usesecfiles

Rem Add XDB schema for resources
@@catxdbdr.sql

/* turn off the ref cascade event */
alter session set events '22830 trace name context off';

Rem Add the schema registration/compilation module
@@dbmsxsch.sql

Rem Add the security module
@@dbmsxdbz.sql

@@dbmsxmlu.sql
@@dbmsxmls.sql
@@dbmsxmld.sql

@@dbmsxres.sql

Rem Add definition for various xdb utilities  
@@dbmsxdb.sql

Rem Add definition for various xdb administrative utilities
@@dbmsxdba.sql

Rem Create Path Index
@@catxdbpi

-- Load the dbms_xdbutil_int specification
@@prvtxdb0.plb

-- Load the dbms_xdbz0 specification
@@prvtxdz0.plb

Rem Implementation of XDB Security modules
@@prvtxdbz.plb

REM ADD pl/sql dom, xml parser, AND xsl processor
@@dbmsxmlp.sql
@@dbmsxslp.sql
@@prvtxmlstreams.plb
@@prvtxmld.plb
@@prvtxmlp.plb
@@prvtxslp.plb

Rem Implementation of DBMS_XDBResource 
@@prvtxres.plb

Rem Implementation of XDB Utilities Package
@@prvtxdb.plb

Rem Implementation of XDB Admin Package
@@prvtxdba.plb

Rem Create the Compact XML Token Manager tables
@@catxdbtm.sql

Rem Create tables for Application users and roles
@@catxdbapp.sql

Rem Implementation of schema registration/compilation module
@@prvtxsch.plb

Rem Resource View
@@prvtxdr0.plb
@@catxdbr.sql 

Rem Resource view implementaion
@@prvtxdbr.plb

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

Rem add xdb_dltrig_pkg - pre-update trigger to invoke document link proc
@@prvtxdbdl.plb

Rem XDB Path Index Implementation
@@prvtxdbp.plb 

Rem Initialize bootstrap acl
@@catxdbz.sql 

Rem Initialize ResConfig 
@@catxev

Rem Initialize XDB standard packages (Configuration, Servlets, etc.)
@@catxdbst.sql

Rem Create the Versioning Package 
@@catxdbvr.sql

Rem Create Path View
@@catxdbpv

Rem Initialize document links support
@@catxdbdl.sql

Rem Create helper package for xml index
@@dbmsxidx
Rem Load body of xmlindex helper package (dbms_xmlindex)
@@prvtxidx.plb

Rem Create the XMLIndex
@@catxidx

Rem Create the Structured XMLIndex tables
@@catxtbix

Rem Initialize extensible optimizer
@@catxdbeo.sql

Rem Initialize XDB configuration management
@@catxdbc1
@@catxdbc2

Rem Setup XDB Digest Authentication
@@xdbinstd.sql

Rem Create Embedded PL/SQL Gateway package and schema objects
@@dbmsepg
@@prvtepg.plb
@@catepg

Rem Add the various views to be created on xdb data
@@catxdbv

Rem Create the DBMS_RESCONFIG package
@@dbmsxrc
@@prvtxrc.plb

Rem Create the DBMS_XEVENT package
@@dbmsxev
@@prvtxev.plb

Rem Create the dbms_xmltranslations package
@@dbmsxtr
@@prvtxtr.plb

-- XDB$REPOS table
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
   resconfig#   NUMBER,
   wkspc#       NUMBER,
   vershist#    NUMBER,
   params       XMLType
);

-- XDB$MOUNTS table
CREATE TABLE XDB.XDB$MOUNTS
(
   dobj#        NUMBER,
   dpath        VARCHAR2(4000),
   sobj#        NUMBER,
   spath        VARCHAR2(4000),
   flags        NUMBER
);

Rem Create the DBMS_XDBREPOS package
@@dbmsxdbrepos
@@prvtxdbrepos.plb

Rem Create helper package for text index on xdb resource data
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem Add XML schema definitions for LCRs
@@catxlcr

Rem Indicate that xdb has been Loaded
begin
dbms_registry.loaded('XDB', dbms_registry.release_version,
           'Oracle XML Database Version ' || dbms_registry.release_version ||
           ' - ' || dbms_registry.release_status);
end;
/

Rem Create a schedule for cleanup of expired nfs clients job
Rem Disabling the job for 11gR1. It needs to be reenabled 
Rem explicitly by customers, or enabled automatically by NFS
Rem server in 11gR2.
Rem dbms_scheduler.enable('nfsclient_cleanup_job');

DECLARE
  c number;
BEGIN  
  select count(*) into c
  from ALL_SCHEDULER_JOB_CLASSES
  where JOB_CLASS_NAME = 'XMLDB_NFS_JOBCLASS';

  if c = 0 then
    dbms_scheduler.create_job_class(
      job_class_name  => 'SYS.XMLDB_NFS_JOBCLASS',
      logging_level   => DBMS_SCHEDULER.LOGGING_FAILED_RUNS);
  end if;

  select count(*) into c
  from ALL_SCHEDULER_JOBS
  where JOB_NAME = 'XMLDB_NFS_CLEANUP_JOB';

  if c = 0 then
    dbms_scheduler.create_job(
        job_name => 'SYS.XMLDB_NFS_CLEANUP_JOB' ,
        job_type=>'STORED_PROCEDURE',  
        job_action=>'xdb.dbms_xdbutil_int.cleanup_expired_nfsclients',
        job_class=>'SYS.XMLDB_NFS_JOBCLASS',
        repeat_interval=>'Freq=minutely;interval=5');
  end if;
  execute immediate 'delete from noexp$ where name = :1' using 'XMLDB_NFS_JOBCLASS';
  execute immediate 'insert into noexp$ (owner, name, obj_type) values(:1, :2, :3)' using 'SYS', 'XMLDB_NFS_JOBCLASS', '68';
end;   
/

Rem Create the registry package and the validation procedure
@@dbmsxreg

grant execute on dbms_registry to xdb;

@@prvtxreg.plb

Rem Part 2 of ACL setup
@@prvtxdz2.plb

revoke administer database trigger from xdb;

set serveroutput on
set long 10000

Rem at catqm.sql, Invoke Validation for registry.
execute sys.dbms_regxdb.validatexdb;

Rem Show that no upgrade is needed to bring XDB to a valid 10.1 state.
BEGIN
  IF dbms_registry.status('XDB') = 'VALID' THEN
    execute immediate 'create table xdb.migr9202status (n integer)';
    execute immediate 'insert into xdb.migr9202status values (1000)';
  END IF;
END;
/

Rem drop objects created to track object creation during XDB
Rem installation
drop trigger sys.xdb_installation_trigger;
drop trigger sys.dropped_xdb_instll_trigger;
drop table dropped_xdb_instll_tab;
drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;
drop function xdb.xdb$getPickledNS;

commit;

prompt XML DB Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt
prompt
prompt Triggering Extensible Security (XS) Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Always keep this at the end. XS
Rem Initialize bootstrap extensible security
@@catzxs.sql

-- Add XS$NULL to XDB schema list
BEGIN
   dbms_registry.update_schema_list('XDB',
     dbms_registry.schema_list_t('ANONYMOUS', 'XS$NULL'));
END;
/

-- Explicit grants to DBA,System; "any" privileges are no more applicable for 
-- XDB tables. Listing these specifically since there are certain tables
-- for which we dont grant full access by default even to DBA & System.
-- (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.)
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
grant all on XDB.XS$DATA_SECURITY to dba;
grant all on XDB.XS$DATA_SECURITY to system with grant option;
grant all on XDB.XS$PRINCIPALS to dba;
grant all on XDB.XS$PRINCIPALS to system with grant option;
grant all on XDB.XS$ROLESETS to dba;
grant all on XDB.XS$ROLESETS to system with grant option;
grant all on XDB.XS$SECURITYCLASS to dba;
grant all on XDB.XS$SECURITYCLASS to system with grant option;
declare
  suf  varchar2(26);
  stmt varchar2(2000);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;
  stmt := 'grant all on XDB.X$PT' || suf || ' to DBA';
  execute immediate stmt;
  stmt := 'grant all on XDB.X$PT' || suf || ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;
/

prompt Extensible Security (XS) Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt


prompt Extensible Security (XS) Installation completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt


Rem Data Pump has the new requirement that users granted 
Rem DATAPUMP_FULL_EXP_DATABASE be able to export in FULL mode
Rem tables in the XDB schema. The advise is actually to grant
Rem SELECT on XDB tables to the SELECT_CATALOG_ROLE, which in 
Rem turn is granted to DATAPUMP_FULL_EXP_DATABASE, to be in sync
Rem with other components to be supported by FULL export.
Rem Some XDB tables are actually allowing PUBLIC access, so this
Rem grant will be a noop for them, but some do not. 
Rem If other XDB scripts are run beyond this point (outside of catqm.sql),
Rem it is the responsability of the script developer to allow similar
Rem grants on any XDB-owned tables that may get created in the script.
Rem
prompt Granting SELECT on XDB tables to SELECT_CATALOG_ROLE
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set serveroutput on

declare
  type    cur_type is ref cursor;
  cur     cur_type;
  tname   varchar2(100);
  stmt    varchar2(2000);
begin
  open cur for 'select table_name from dba_tables where owner=:1 union ' ||
               'select table_name from dba_xml_tables where owner=:2 union ' ||
               'select table_name from dba_object_tables where owner=:3 '
    using 'XDB', 'XDB', 'XDB';
  loop
    fetch cur into tname;
    exit when cur%NOTFOUND;

    tname := 'XDB."' ||    tname || '"';
    stmt := 'grant select on ' || tname || ' to SELECT_CATALOG_ROLE';
    begin
       execute immediate stmt;
       exception
          when OTHERS then
             if ((SQLCODE != -22812) and (SQLCODE != -30967)) then
               dbms_output.put_line(stmt);
               dbms_output.put_line(SQLERRM);
             end if;
    end;
  end loop;
end;
/

set serveroutput off
