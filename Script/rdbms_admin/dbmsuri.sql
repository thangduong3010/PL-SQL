Rem
Rem $Header: rdbms/admin/dbmsuri.sql /main/26 2009/11/08 07:01:25 ckavoor Exp $
Rem
Rem dbmsuri.sql
Rem
Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsuri.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ckavoor     11/02/09 - 2123504: Adding 'show errors'
Rem    rangrish    05/11/09 - remove grant under: 6613491
Rem    rangrish    06/20/08 - remove WITH GRANT OPTION on UriFactory
Rem    jwwarner    03/22/05 - 4252742: make geturl deterministic 
Rem    abagrawa    09/19/02 - add charset to XDBUriType getBlob function
Rem    amanikut    01/17/02 - add synonym for the UriTypes
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    sidicula    12/12/01 - Removing unnecessary methods in XDBUriType
Rem    amanikut    12/06/01 - LRG 82051 : fix constructor signature
Rem    qyu         11/21/01 - change getxxxInfo to overload getC/Blob 
Rem    sidicula    11/21/01 - Adding getResource() to XDBUriType
Rem    jwwarner    11/01/01 - fix upgrade issues
Rem    smuralid    10/24/01 - change ALTER TYPE REPLACE to CREATE
Rem    jwwarner    10/18/01 - Changes to Uri types for upgrade
Rem    qyu         10/04/01 - add getxxxInfo, getContentType methods 
Rem    amanikut    09/20/01 - Add user-defined constructors
Rem    sidicula    07/23/01 - Added XDBUriType
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    mkrishna    05/04/01 - add drop before creating
Rem    mkrishna    12/06/00 - change TOIDs for XML, uri types
Rem    mkrishna    11/15/00 - add TOID clause for uri types
Rem    mkrishna    11/10/00 - change createUri syntax
Rem    mkrishna    10/22/00 - use inheritance
Rem    mkrishna    10/30/00 - modify urifactory
Rem    mkrishna    09/08/00 - remove inheritance till func dispatch works
Rem    mkrishna    08/12/00 - change dburi to use inheritance
Rem    mkrishna    07/18/00 - add grant option
Rem    mkrishna    06/08/00 - use invokers rights
Rem    mkrishna    05/14/00 - fix errors
Rem    mkrishna    05/12/00 - fix errors
Rem    mkrishna    05/12/00 - Created
Rem

Rem ************************** UriType Definition ***************************
Rem ** IMPORTANT: The create or replace UriType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to this must be placed in the ALTER TYPE ADD
Rem ** following the create or replace type.
Rem *************************************************************************
create or replace type UriType oid '00000000000000000000000000020110'
 authid current_user as object
(
  url varchar2(4000),

  -- returns the lob value of the pointed URL
  not instantiable member function getClob RETURN clob,

  -- get the external url (escaped)
  member function getExternalUrl RETURN varchar2,

  -- get the un-escaped url 
  member function getUrl RETURN varchar2,

  -- get the blob value of the output
  not instantiable member function getBlob RETURN blob
) not final not instantiable;
/
show errors;

Rem *************************************************************************

Rem *********************** Alter type for UriType *************************
Rem ** All changes to UriType go here.
Rem *************************************************************************
alter type sys.UriType replace
 authid current_user as object
(
  url varchar2(4000),
  -- returns the lob value of the pointed URL
  not instantiable member function getClob RETURN clob,
  -- get the external url (escaped)
  member function getExternalUrl RETURN varchar2 deterministic,
  -- get the un-escaped url 
  member function getUrl RETURN varchar2 deterministic,
  -- get the blob value of the output
  not instantiable member function getBlob RETURN blob,
  member function getBlob(csid IN NUMBER) RETURN blob,
  -- new fcns in 9.2
  -- returns the value of this URI as an XMLType
  member function getXML return sys.XMLType,
  member function getContentType RETURN varchar2,
  member function getClob(content OUT varchar2) RETURN clob,
  member function getBlob(content OUT varchar2) RETURN blob,
  member function getXML(content OUT varchar2) RETURN sys.XMLType,
  static function makeBlobFromClob(src_clob IN OUT clob, csid IN NUMBER := 0) 
  RETURN blob
) not final not instantiable;
show errors;

Rem *************************************************************************

Rem ************************ FtpUriType Definition **************************
Rem ** IMPORTANT: The create or replace FtpUriType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to this must be placed in the ALTER TYPE ADD
Rem ** following the create or replace type.
Rem *************************************************************************
-- create or replace type FtpUriType authid current_user
create or replace type FtpUriType oid '00000000000000000000000000020111'
  authid current_user under sys.UriType 
(
 -- url varchar2(4000),  

  overriding member function getExternalUrl return varchar2,
  overriding member function getUrl return varchar2,

  -- returns the lob value of the pointed URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,

  static function createFtpUri(ftpurl in varchar2) return ftpuritype

);
/
show errors;

Rem *************************************************************************

Rem ********************** Alter types for FtpUriType ***********************
Rem ** All changes to FtpUriType go here.
Rem *************************************************************************

alter type FtpUriType replace
  authid current_user under sys.UriType 
(
 -- url varchar2(4000),  
  overriding member function getExternalUrl return varchar2 deterministic,
  overriding member function getUrl return varchar2 deterministic,
  -- returns the lob value of the pointed URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,
  overriding member function getBlob(csid IN NUMBER) RETURN blob,
  static function createFtpUri(ftpurl in varchar2) return ftpuritype,
  -- new fcns in 9.2
  overriding member function getXML return sys.XMLType,
  constructor function FtpUriType(url in varchar2) return self
                                  as result,
  overriding member function getContentType RETURN varchar2,
  overriding member function getClob(content OUT varchar2) RETURN clob,
  overriding member function getBlob(content OUT varchar2) RETURN blob,
  overriding member function getXML(content OUT varchar2)
    RETURN sys.XMLType 
);
show errors;

Rem *************************************************************************


Rem *********************** HttpUriType Definition **************************
Rem ** IMPORTANT: The create or replace HttpUriType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to this must be placed in the ALTER TYPE ADD
Rem ** following the create or replace type.
Rem *************************************************************************

create or replace type HttpUriType  oid '00000000000000000000000000020112'
  authid current_user under sys.UriType 
(
  -- url varchar2(4000),  

  overriding member function getExternalUrl return varchar2,
  overriding member function getUrl return varchar2,

  -- returns the lob value of the pointed URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,

  static function createUri(httpuri in varchar2) return httpuritype
);
/
show errors;

Rem *************************************************************************

Rem ********************* Alter types for HttpUriType ***********************
Rem ** All changes to HttpUriType go here.
Rem *************************************************************************

alter type HttpUriType replace
  authid current_user under sys.UriType 
(
  -- url varchar2(4000),  
  overriding member function getExternalUrl return varchar2 deterministic,
  overriding member function getUrl return varchar2 deterministic,
  -- returns the lob value of the pointed URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,
  overriding member function getBlob(csid IN NUMBER) RETURN blob,
  static function createUri(httpuri in varchar2) return httpuritype,
  -- new fcns in 9.2
  overriding member function getXML return sys.XMLType,
  constructor function HttpUriType(url in varchar2)
    return self as result,
  overriding member function getContentType RETURN varchar2,
  overriding member function getClob(content OUT varchar2) RETURN clob,
  overriding member function getBlob(content OUT varchar2) RETURN blob,
  overriding member function getXML(content OUT varchar2)
    RETURN sys.XMLType 
);
show errors;

Rem *************************************************************************

Rem ************************ DBUriType Definition ***************************
Rem ** IMPORTANT: The create or replace DBUriType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to this must be placed in the ALTER TYPE ADD
Rem ** following the create or replace type.
Rem *************************************************************************
-- create or replace type DBUriType under UriType

create or replace type DBUriType oid '00000000000000000000000000020113'
  authid current_user under sys.UriType 
(
 -- url varchar2(4000),
  spare raw(2000),

  overriding member function getExternalUrl return varchar2,
  overriding member function getUrl return varchar2,

  -- returns the clob value of the pointed to URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,

  static function createuri(dburi in varchar2) return dburitype
);
/
show errors;

Rem *************************************************************************

Rem ********************** Alter types for DBUriType ************************
Rem ** All changes to DBUriType go here.
Rem *************************************************************************

alter type DBUriType replace
  authid current_user under sys.UriType 
(
 -- url varchar2(4000),
  spare raw(2000),
  overriding member function getExternalUrl return varchar2 deterministic,
  overriding member function getUrl return varchar2 deterministic,
  -- returns the clob value of the pointed to URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,
  overriding member function getBlob(csid IN NUMBER) RETURN blob,
  static function createuri(dburi in varchar2) return dburitype,
  -- new fcns in 9.2
  overriding member function getXML return sys.XMLType,
  constructor function DBUriType(url in varchar2, spare in raw := null)
    return self as result,
  overriding member function getContentType RETURN varchar2,
  overriding member function getClob(content OUT varchar2) RETURN clob,
  overriding member function getBlob(content OUT varchar2) RETURN blob,
  overriding member function getXML(content OUT varchar2)
    RETURN sys.XMLType 
);
show errors;

Rem *************************************************************************

-- Will be frozen as of 9iR2, methods will be added with alter type add
-- create or replace type XDBUriType under UriType
create or replace type XDBUriType OID '00000000000000000000000000020152'
  authid current_user under UriType 
(
 -- url varchar2(4000),
  spare raw(2000),
  overriding member function getExternalUrl return varchar2,
  overriding member function getUrl return varchar2,
  -- returns the clob value of the pointed to URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,
  -- returns the value of this URI as an XMLType
  overriding member function getXML return sys.XMLType,
  -- return Info
  overriding member function getContentType RETURN varchar2,
  -- return the XMLType of the resource
  member function getResource RETURN sys.XMLType,
  static function createuri(xdburi in varchar2) return xdburitype,
  constructor function XDBUriType(url in varchar2, spare in raw := null) 
    return self as result
);
/
show errors;

alter type XDBUriType replace
  authid current_user under sys.UriType 
(
  spare raw(2000),
  overriding member function getExternalUrl return varchar2 deterministic,
  overriding member function getUrl return varchar2 deterministic,
  -- returns the clob value of the pointed to URL
  overriding member function getClob RETURN clob,
  overriding member function getBlob RETURN blob,
  overriding member function getBlob(csid IN NUMBER) RETURN blob,
  -- returns the value of this URI as an XMLType
  overriding member function getXML return sys.XMLType,
  -- return Info
  overriding member function getContentType RETURN varchar2,
  -- return the XMLType of the resource
  member function getResource RETURN sys.XMLType,
  static function createuri(xdburi in varchar2) return xdburitype,
  constructor function XDBUriType(url in varchar2, spare in raw := null) 
    return self as result
);
show errors;

create or replace type urifacelem oid '00000000000000000000000000020114'
  as object
(
  prefix varchar2(100),
  schemaname varchar2(100),
  typename varchar2(100),
  ignorecase char(1),
  stripprefix char(1)
);
/
show errors;

create or replace type urifaclist oid '00000000000000000000000000020115'
  as varray(100) of urifacelem;
/
show errors;

create or replace package UriFactory authid current_user as 
  
  faclist urifaclist;
  
  -- returns the correct uritype
  function getUri(url IN varchar2) RETURN UriType;
  function unescapeUri(escapedurl IN varchar2) RETURN varchar2;
  function escapeUri(unescapedurl IN varchar2) RETURN varchar2;

  -- register a url handler..
  procedure registerUrlHandler(prefix in varchar2, schemaname in varchar2,
    typename in varchar2, ignorePrefixCase in boolean := true, 
    stripprefix in boolean := true);

 procedure UnRegisterUrlHandler(prefix in varchar2);

end;
/

grant execute on UriType to PUBLIC with grant option;
grant execute on DBUriType to PUBLIC with grant option;
grant execute on FtpUriType to PUBLIC with grant option;
grant execute on XDBUriType to PUBLIC with grant option;
grant execute on HttpUriType to PUBLIC with grant option;
grant execute on UriFactory to PUBLIC;

create or replace public synonym Uritype for sys.Uritype;
create or replace public synonym DBUriType for sys.DBUriType;
create or replace public synonym FtpUriType for sys.FtpUriType;
create or replace public synonym XDBUriType for sys.XDBUriType;
create or replace public synonym HttpUriType for sys.HttpUriType;
create or replace public synonym UriFactory for UriFactory;
