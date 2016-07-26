Rem
Rem $Header: rdbms/admin/catxdbrs.sql /st_rdbms_11.2.0/2 2011/05/20 09:12:32 spetride Exp $
Rem
Rem catxdbrs.sql
Rem
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbrs.sql - XDB Resource Schema related types and tables
Rem
Rem    DESCRIPTION
Rem      This script creates the types, tables, etc required for 
Rem      XDB Resource schema.
Rem
Rem    NOTES
Rem      This script should be run as the user "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sidicula    09/25/08 - 
Rem    sichandr    09/11/08 - grant execute on xdb$nlocks_t
Rem    spetride    12/10/07 - option: use secure files for xdb$resource
Rem    spetride    10/03/07 - add XDB$RESOURCE_ACLOID_IDX index
Rem    pnath       10/07/04 - Introduce Locks element in Resource 
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade 
Rem    thoang      09/23/03 - add RCLIST 
Rem    smalde      05/26/05 - Add Content Size
Rem    spannala    06/28/04 - adding columns for attrcopy, contents copy 
Rem    najain      05/13/04 - add snapshot in xdb$resource_t
Rem    abagrawa    02/19/04 - Add SBRESEXTRA to XDB$RESOURCE_T 
Rem    spannala    07/27/03 - changing xdb$resource_oid_index to xdb ownership
Rem    njalali     01/17/03 - adding unique index on XMLREF column
Rem    fge         02/04/02 - grant execute on xdb$resource_t to public
Rem    spannala    01/08/02 - incorporating fge_caxdb_priv_indx_fix
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    njalali     12/04/01 - changed some integers to RAW in the resource type
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    njalali     10/27/01 - using timestamp
Rem    njalali     10/26/01 - fixing OIDs to be 16 bytes
Rem    nle         10/05/01 - versioning
Rem    nagarwal    08/28/01 - add version attrs
Rem    rmurthy     10/01/01 - allow primary key in xmlref col
Rem    rmurthy     08/10/01 - change XDB namespace
Rem    njalali     08/09/01 - resource format changes
Rem    spannala    08/03/01 - DAV
Rem    njalali     07/29/01 - Merged njalali_xmlres2
Rem    nagarwal    07/27/01 - add versionid, activityid to resource_t
Rem    njalali     07/19/01 - added column for the ANY element
Rem    njalali     07/06/01 - Created
Rem


/* ------------------------------------------------------------------- */
/*                   MISC TYPES                                        */   
/* ------------------------------------------------------------------- */


/* ------------------------------------------------------------------- */
/*                   ENUM TYPES                                        */   
/* ------------------------------------------------------------------- */

create or replace type xdb.xdb$nlocks_t OID '0000000000000000000000000002011C'
 AS OBJECT
(
    PARENT_OID  RAW(16),
    CHILD_NAME  VARCHAR2(256),
    RAWTOKEN    RAW(18)
);
/

create or replace type XDB.XDB$PREDECESSOR_LIST_T OID
'0000000000000000000000000002011D' AS varray(1000) of raw(16);
/

grant execute on xdb.xdb$nlocks_t to public with grant option;
grant execute on xdb.xdb$predecessor_list_t to public with grant option;

create or replace type XDB.XDB$OID_LIST_T OID
'0000000000000000000000000002011F' AS varray(65535) of raw(16);
/

grant execute on xdb.xdb$oid_list_t to public with grant option;

create or replace type XDB.XDB$RCLIST_T OID
'00000000000000000000000000020160' AS OBJECT
(
  OID    XDB$OID_LIST_T
)
/

grant execute on xdb.xdb$rclist_t to public with grant option;
/* ------------------------------------------------------------------- */
/*                  RESOURCE RELATED TYPES                             */
/* ------------------------------------------------------------------- */

create or replace type XDB.XDB$RESOURCE_T OID 
'0000000000000000000000000002011E' as object
(
  VERSIONID           INTEGER,
  CREATIONDATE        TIMESTAMP,
  MODIFICATIONDATE    TIMESTAMP,
  AUTHOR              VARCHAR2(128),
  DISPNAME            VARCHAR2(128),
  RESCOMMENT          VARCHAR2(128),
  LANGUAGE            VARCHAR2(128),
  CHARSET             VARCHAR2(128),
  CONTYPE             VARCHAR2(128),
  REFCOUNT            RAW(4),
  LOCKS               RAW(2000),
  ACLOID              RAW(16),
  OWNERID             RAW(16),
  CREATORID           RAW(16),
  LASTMODIFIERID      RAW(16),
  ELNUM               INTEGER,
  SCHOID              RAW(16),
  XMLREF              REF SYS.XMLTYPE,
  XMLLOB              BLOB,
  FLAGS               RAW(4),
  RESEXTRA            CLOB,
  ACTIVITYID          INTEGER,
  VCRUID              RAW(16),
  PARENTS             XDB.XDB$PREDECESSOR_LIST_T,
  SBRESEXTRA          XDB.XDB$XMLTYPE_REF_LIST_T,
  SNAPSHOT            RAW(6),
  ATTRCOPY            BLOB,
  CTSCOPY             BLOB,
  NODENUM             RAW(6),
  SIZEONDISK          INTEGER,
  RCLIST              XDB.XDB$RCLIST_T,
  CHECKEDOUTBYID      RAW(16),
  BASEVERSION         RAW(16)
);
/

grant execute on xdb.xdb$resource_t to public with grant option;

/* ------------------------------------------------------------------- */
/*                      TABLES                                         */   
/* ------------------------------------------------------------------- */

/* Well known ID for XDB schema for resources */
/* '8758D485E6004793E034080020B242C6' */

declare
 stmt_basiclob   varchar2(3000);
 stmt_seclob     varchar2(3000);
begin
  stmt_basiclob := ' create table XDB.XDB$RESOURCE of sys.xmltype ' ||
                   ' xmlschema "http://xmlns.oracle.com/xdb/XDBResource.xsd" ' ||
                   '      id ''' || '8758D485E6004793E034080020B242C6' || ''' ' ||
                   ' element "Resource" id 734 ' ||
                   ' type XDB.XDB$RESOURCE_T ';
  stmt_seclob := stmt_basiclob || ' lob (xmldata.xmllob) store as securefile ';
   
  if (:usesecfiles = 'YES') then
   execute immediate stmt_seclob;
  else
   execute immediate stmt_basiclob;
  end if;
end;
/

--for reference: check if secure files used
set long 1000000
select dbms_metadata.get_ddl('TABLE', 'XDB$RESOURCE', 'XDB') from dual;


alter table XDB.XDB$RESOURCE add (ref(xmldata.XMLREF) with rowid);
alter table XDB.XDB$RESOURCE add (ref(xmldata.XMLREF) allow primary key);

create unique index xdb.xdb$resource_oid_index on XDB.XDB$RESOURCE e
  (sys_op_r2o(e.xmldata.xmlref));

create index xdb.xdb$resource_acloid_idx on XDB.XDB$RESOURCE e (e.xmldata.ACLOID);

/*
NOLOGGING LOB (xmllob) STORE AS 
  (tablespace xdb_resinfo storage (initial 100m next 100m pctincrease 0)
   nocache nologging chunk 32k);
*/

create table xdb.xdb$nlocks of xdb.xdb$nlocks_t;

/* ------------------------------------------------------------------- */
/*                          INDEXES                                    */   
/* ------------------------------------------------------------------- */

/*
create index xdb$resource_xmlref_i on xdb$resource (sys_op_r2o(xmldata.xmlref));
*/

create index xdb.xdb$nlocks_rawtoken_idx on xdb.xdb$nlocks (rawtoken);
create index xdb.xdb$nlocks_child_name_idx on xdb.xdb$nlocks (child_name);
create index xdb.xdb$nlocks_parent_oid_idx on xdb.xdb$nlocks (parent_oid);
/* None for now */


