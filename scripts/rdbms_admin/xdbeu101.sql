Rem
Rem $Header: xdbeu101.sql 11-nov-2007.07:46:32 rburns Exp $
Rem
Rem xdbeu101.sql
Rem
Rem Copyright (c) 2004, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbeu101.sql - XDB Downgrade Data Script
Rem
Rem    DESCRIPTION
Rem      Downgrade XDB data (i.e., not schemas) from 10.2 to 10.1
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      11/11/07 - move object downgrade actions
Rem    rangrish    07/10/07 - remove WS role in downgrade
Rem    rpang       05/04/07 - remove uses of the EPG from xdbconfig.xml
Rem    mrafiq      10/22/05 - moving set acl of xdbconfig.xml to the 
Rem                           bootstrap acl to xdbeu102.sql
Rem    fge         12/15/04 - call 10.2 downgrade script 
Rem    thbaby      02/18/05 - grant PUBLIC access to xdbconfig.xml
Rem    spannala    09/02/04 - spannala_lrg-1734670
Rem    spannala    08/24/04 - Created
Rem

-- First downgrade data to 10.2 release
@@xdbeu102.sql

--
-- data downgrade to 10.1

-- Remove uses of the embedded PL/SQL gateway from xdbconfig.xml
declare
  cfg_data XMLTYPE;
  plssvt   VARCHAR2(2000);
  i        PLS_INTEGER;
begin
  cfg_data := dbms_xdb.cfg_get();

  -- Remove PL/SQL servlet mappings
  i := 1;
  loop
    SELECT extractValue(
             cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
               '/servletconfig/servlet-list'||
               '/servlet[servlet-language=''PL/SQL'']['||i||']'||
               '/servlet-name/text()')
    INTO   plssvt
    FROM   dual; 

    exit when (plssvt is null);

    SELECT deleteXML(
             cfg_data,
               '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
                 '/servletconfig/servlet-mappings'||
                 '/servlet-mapping[servlet-name='''||plssvt||''']')
    INTO   cfg_data
    FROM   dual;

    i := i + 1;

  end loop;

  -- Remove PL/SQL servlets
  SELECT deleteXML(
           cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
               '/servletconfig/servlet-list'||
               '/servlet[servlet-language=''PL/SQL'']')
  INTO   cfg_data
  FROM   dual; 

  -- Remove PL/SQL global-config
  SELECT deleteXML(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/plsql')
  INTO   cfg_data
  FROM   dual; 

  dbms_xdb.cfg_update(cfg_data);
end;
/

