Rem
Rem $Header: dbmsxtr.sql 14-mar-2006.17:25:56 smalde Exp $
Rem
Rem dbmsxtr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxtr.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smalde      03/03/06 - Add enableTranslations 
Rem    smalde      02/21/06 - Created
Rem

set echo on
set feedback 1
set numwidth 10
set linesize 80
set trimspool on
set tab off
set pagesize 100

grant execute on xdb.xdb_privileges to public with grant option;

create or replace package xdb.dbms_xmltranslations 
authid current_user is

function translatexml ( 
    doc  in xmltype,
    lang in varchar2
) return xmltype;

function getbasedocument ( 
    doc  in xmltype
) return xmltype;

function updatetranslation (
    doc   in xmltype,
    xpath in varchar2, 
    lang  in varchar2, 
    value in varchar2,
    namespace in varchar2 := null
) return xmltype;

function setsourcelang (
    doc   in xmltype,
    xpath in varchar2, 
    lang  in varchar2,
    namespace in varchar2 := null
) return xmltype;

function extractxliff (
    doc   in xmltype, 
    xpath in varchar2,
    namespace in varchar2 := null
) return xmltype;

function extractxliff (
    abspath in varchar2,
    xpath   in varchar2,
    namespace in varchar2 := null
) return xmltype;

function mergexliff (
    doc   in xmltype, 
    xliff in xmltype
) return xmltype;

procedure mergexliff (
    xliff in xmltype
);

procedure enableTranslation;
procedure disableTranslation;

end dbms_xmltranslations;
/
show errors;

create or replace public synonym dbms_xmltranslations for xdb.dbms_xmltranslations
/
grant execute on xdb.dbms_xmltranslations to public
/
show errors;
