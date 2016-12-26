Rem
Rem $Header: rdbms/admin/xdbs101.sql /main/17 2010/02/23 23:47:22 badeoti Exp $
Rem
Rem xdbs101.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbs101.sql - xdb schema upgrade from the 101 release
Rem
Rem    DESCRIPTION
Rem      xdb schema upgrade from the 10.1 release to 10.2 and onwards
Rem
Rem    NOTES
Rem      xdb upgrade document
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     02/16/10 - bug 9304342: fix-up complex type PDs
Rem    badeoti     10/28/09 - Include sidicula_bug-7596530 fixes for 9201NT
Rem                           schema-for-schemas
Rem    vkapoor     01/25/05 - Adding 102 upgrade script 
Rem    rpang       04/12/05 - request-validation-function/input-filter-enable
Rem    vkapoor     04/06/05 - LRG 1842450
Rem    rpang       03/24/05 - Fix SSO typo 
Rem    fge         10/27/04 - add 102 upgrade 
Rem    petam       03/21/05 - add <allow-repository-anonymous-access> under 
Rem                           httpconfig 
Rem    rpang       12/02/04 - add upgrade for embedded PL/SQL gateway
Rem    smukkama    11/19/04 - use even smaller token size (UTF8 ncharset)
Rem    petam       11/03/04 - bug 3957281: Added ftp-welcome-message in 
Rem                           xdbconfig.xml 
Rem    smukkama    09/30/04 - create token tables for xmlindex
Rem    attran      08/20/04 - xmlidx
Rem    sichandr    07/26/04 - add upgrade support for xmlindex 
Rem    spannala    05/18/04 - removing http2-listener 
Rem    abagrawa    05/10/04 - SB res metadata upgrade
Rem    thbaby      04/26/04 - thbaby_https
Rem    thbaby      04/21/04 - Created
Rem

Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

Rem Fix schema-for-schemas in DBs upgraded from 9201
execute dbms_xdbmig_util.checkSchSchCfgKids;
execute dbms_xdbmig_util.fixSchSchCfgKids;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

Rem Fix corrupted complex type rows
execute dbms_xdbmig_util.fixCfgPDs;
execute dbms_xdbmig_util.checkCfgPDs;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

Rem clean up updown utilities
@@dbmsxuducu.sql

-- Get utility functions, also compiles base types to avoid ORA-942 below
@@xdbuuc.sql

create or replace procedure upgrade_config_schema as
  CONFIG_SCHEMA_URL      CONSTANT VARCHAR2(100) :=
                           'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  config_schema_ref      REF XMLTYPE;
  enum_ref               REF XMLTYPE;
  seq_ref                REF XMLTYPE;
  cplx_ref               REF XMLTYPE;
  elem_ref_http2_port    REF XMLTYPE;
  elem_ref_http2_proto   REF XMLTYPE;
  elem_ref_plsql         REF XMLTYPE;
  elem_ref_anonymous     REF XMLTYPE;
  httpcf_seq_ref         REF XMLTYPE;
  servlet_seq_ref        REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  choices_arr            XDB.XDB$XMLTYPE_REF_LIST_T;
  httpconf_type          varchar2(100);
  httpconf_type_owner    varchar2(100);
  ftp_welcome_count      INTEGER; 
  elem_ref_ftp_welcome   REF XMLTYPE;
  ftpcf_seq_ref          REF XMLTYPE;
  ftpconf_type           varchar2(100);
  ftpconf_type_owner     varchar2(100);
  servlet_type           varchar2(100);
  servlet_type_owner     varchar2(100);
  plsql_conf_type        varchar2(100);
  plsql_svt_conf_type    varchar2(100);
  plsql_vc2_coll_type    varchar2(100);
  plsql_num_coll_type    varchar2(100);
begin

  select ref(s) into config_schema_ref from xdb.xdb$schema s
   where s.xmldata.schema_url = CONFIG_SCHEMA_URL;

  -- Upgrade http2-port, http2-protocol, plsql and 
  -- allow-repository-anonymous-access elements if necessary
  if find_element(CONFIG_SCHEMA_URL,
                  '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-port')
    is null then

    element_type(CONFIG_SCHEMA_URL, 'httpconfig', httpconf_type_owner,
                 httpconf_type);

    plsql_conf_type := type_name('plsql', 'T');
    execute immediate 'create or replace type "' || httpconf_type_owner||'".'||
      '"'||plsql_conf_type||'" as object ( '                    ||
          'sys_xdbpd$         xdb.xdb$raw_list_t, ' ||
          '"log-level"        number(10), '         ||
          '"max-parameters"   number(10))';

    -- Since allow-repository-anonymous-access is such a long name, we truncated the 
    -- name here so that it will not exceed the 32-character restriction for an 
    -- attribute name in SQL. The sql name for this element is 'allow-repository-anonymou69'
    alt_type_add_attribute(httpconf_type_owner, httpconf_type,
                           '"http2-port" NUMBER(5), ' ||
                           '"http2-protocol" VARCHAR2(4000 CHAR),' ||
                           '"plsql" "'||httpconf_type_owner||'"."'||
                                        plsql_conf_type||'", ' || 
                           '"allow-repository-anonymou69" RAW(1)');

    -- create the element and sub-element types corresponding to
    -- /sysconfig/protocolconfig/httpconfig/plsql
    elem_arr := xdb.xdb$xmltype_ref_list_t();
    elem_arr.extend(2);

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'log-level', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'log-level', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(1); -- log-level

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'max-parameters', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'max-parameters', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(2); -- max-parameters

    insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081800207'), config_schema_ref, 0, NULL, elem_arr, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(m) into seq_ref;  -- seq(log-leve, max-parameters)

    insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('330800060000030D0E131112'), config_schema_ref, NULL, NULL, '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, plsql_conf_type, 'XDB', '01', NULL, NULL, NULL))
      returning ref(c) into cplx_ref; -- complex_type(plsql)

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839838201080030400000004321C0809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'plsql', NULL, NULL, '0102', '00', '00', NULL, 'plsql', plsql_conf_type, 'XDB', NULL, NULL, NULL, cplx_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00',NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, cplx_ref, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_plsql; -- plsql element

    -- select the element type corresponding to http config and add
    -- the three new elements to it
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F898200080030400000004050F320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'http2-port', XDB.XDB$QNAME('00', 'unsignedShort'), '02', '44', '00', '00', NULL, 'http2-port', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_http2_port;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004050F320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'http2-protocol', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'http2-protocol', 'VARCHAR2', NULL, NULL, 'tcp', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      return ref(e) into elem_ref_http2_proto;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')), 
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B898200080030400000004320F050809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'allow-repository-anonymous-access', XDB.XDB$QNAME('00', 'boolean'), NULL, 'FC', '00', '00', NULL, 'allow-repository-anonymou69', 'RAW', NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      return ref(e) into elem_ref_anonymous;

    -- select the sequence kid corresponding to the httpconfig type
    select c.xmldata.sequence_kid into httpcf_seq_ref from 
      xdb.xdb$complex_type c where ref(c)=
        (select e.xmldata.cplx_type_decl from xdb.xdb$element e
          where e.xmldata.property.name='httpconfig' and
          e.xmldata.property.parent_schema = config_schema_ref);

    -- select the sequence elements
    select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
     where ref(m) = httpcf_seq_ref;
  
    -- extend it to add the three elements just created
    elem_arr.extend(4);
    elem_arr(elem_arr.last-3) := elem_ref_http2_port;
    elem_arr(elem_arr.last-2) := elem_ref_http2_proto;
    elem_arr(elem_arr.last-1) := elem_ref_plsql;
    elem_arr(elem_arr.last)   := elem_ref_anonymous;

    -- update the table with the extended sequence and new pd
    update xdb.xdb$sequence_model m
       set m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081801107')
      where ref(m) = httpcf_seq_ref;

  end if; -- Upgrade httpconfig

  -- Upgrade servlet/plsql element if necessary
  if find_element(CONFIG_SCHEMA_URL,
                  '/xdbconfig/sysconfig/protocolconfig/httpconfig/'||
                  'webappconfig/servletconfig/servlet-list/servlet/plsql')
    is null then

    element_type(CONFIG_SCHEMA_URL, 'servlet', servlet_type_owner,
                 servlet_type);

    plsql_svt_conf_type := type_name('plsql-servlet-config', 'T');
    plsql_vc2_coll_type := type_name('upload-as-long-raw', 'COLL');
    plsql_num_coll_type := type_name('bind-bucket-lengths', 'COLL');

    -- Create type 'plsql-servlet-config??_T' and 'plsql??_T'
    execute immediate 'create or replace type "' || servlet_type_owner||'".'||
    '"'||plsql_vc2_coll_type||'" as varray(2147483647) of varchar2(4000 char)';
    execute immediate 'create or replace type "' || servlet_type_owner||'".'||
    '"'||plsql_num_coll_type||'" as varray(2147483647) of number(10)';
    execute immediate 'create or replace type "' || servlet_type_owner||'".'||
    '"'||plsql_svt_conf_type||'" as object ( '             ||
        'sys_xdbpd$                  xdb.xdb$raw_list_t, '  ||
        '"database-username"         varchar2(4000 char), ' ||
        '"authentication-mode"       xdb.xdb$enum_t, '      ||
        '"session-cookie-name"       varchar2(4000 char), ' ||
        '"session-state-management"  xdb.xdb$enum_t, '      ||
        '"max-requests-per-session"  number(10), '          ||
        '"default-page"              varchar2(4000 char), ' ||
        '"document-table-name"       varchar2(4000 char), ' ||
        '"document-path"             varchar2(4000 char), ' ||
        '"document-procedure"        varchar2(4000 char), ' ||
        '"upload-as-long-raw"        "'||servlet_type_owner||'"."'||
                                         plsql_vc2_coll_type||'", ' ||
        '"path-alias"                varchar2(4000 char), ' ||
        '"path-alias-procedure"      varchar2(4000 char), ' ||
        '"exclusion-list"            "'||servlet_type_owner||'"."'||
                                         plsql_vc2_coll_type||'", ' ||
        '"cgi-environment-list"      "'||servlet_type_owner||'"."'||
                                         plsql_vc2_coll_type||'", ' ||
        '"compatibility-mode"        number(10), '          ||
        '"nls-language"              varchar2(4000 char), ' ||
        '"fetch-buffer-size"         number(10), '          ||
        '"error-style"               xdb.xdb$enum_t, '      ||
        '"transfer-mode"             xdb.xdb$enum_t, '      ||
        '"before-procedure"          varchar2(4000 char), ' ||
        '"after-procedure"           varchar2(4000 char), ' ||
        '"bind-bucket-lengths"       "'||servlet_type_owner||'"."'||
                                         plsql_num_coll_type||'", ' ||
        '"bind-bucket-widths"        "'||servlet_type_owner||'"."'||
                                         plsql_num_coll_type||'", ' ||
        '"always-describe-procedure" xdb.xdb$enum_t, '      ||
        '"info-logging"              xdb.xdb$enum_t, '      ||
        '"owa-debug-enable"          xdb.xdb$enum_t, '      ||
        '"request-validation-function" varchar2(4000 char), ' ||
        '"input-filter-enable"       xdb.xdb$enum_t)';

    alt_type_add_attribute(servlet_type_owner, servlet_type,
                           '"plsql" "'||servlet_type_owner||'"."'||
                                        plsql_svt_conf_type||'"');

    -- create the element and sub-element types corresponding to
    -- /sysconfig/protocolconfig/httpconfig/webappconfig/servletconfig/...
    -- ...servlet-list/servlet/plsql
    elem_arr := xdb.xdb$xmltype_ref_list_t();
    elem_arr.extend(28);

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'database-username', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'database-username', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00',NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(1); -- database-username

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8005'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Basic', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'SingleSignOn', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'GlobalOwa', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'CustomOwa', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'PerPackageOwa', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'authentication-mode', NULL, NULL, '0103', '00', '00', NULL, 'authentication-mode', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(2); -- authentication-mode

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'session-cookie-name', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'session-cookie-name', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(3); -- session-cookie-name

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8003'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'StatelessWithResetPackageState', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'StatelessWithFastResetPackageState', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'StatelessWithPreservePackageState', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'session-state-management', NULL, NULL, '0103', '00', '00', NULL, 'session-state-management', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(4); -- session-state-management

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'max-requests-per-session', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'max-requests-per-session', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(5); -- max-requests-per-session

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'default-page', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'default-page', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(6); -- default-page

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'document-table-name', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'document-table-name', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(7); -- document-table-name

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'document-path', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'document-path', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(8); -- document-path

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'document-procedure', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'document-procedure', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(9); -- document-procedure

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818E00080030C000000040532330809181B23262A343503150B0C072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'upload-as-long-raw', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'upload-as-long-raw', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, plsql_vc2_coll_type, 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(10); -- upload-as-long-raw

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'path-alias', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'path-alias', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(11); -- path-alias

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'path-alias-procedure', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'path-alias-procedure', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(12); -- path-alias-procedure

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818E00080030C000000040532330809181B23262A343503150B0C072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'exclusion-list', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'exclusion-list', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, plsql_vc2_coll_type, 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(13); -- exclusion-list

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818E00080030C000000040532330809181B23262A343503150B0C072729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'cgi-environment-list', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'cgi-environment-list', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, plsql_vc2_coll_type, 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(14); -- cgi-environment-list

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'compatibility-mode', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'compatibility-mode', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(15); -- compatibility-mode

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'nls-language', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'nls-language', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(16); -- nls-language

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F81820008003040000000405320809181B23262A343503150B0C0706272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'fetch-buffer-size', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'fetch-buffer-size', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(17); -- fetch-buffer-size

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8003'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'ApacheStyle', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'ModplsqlStyle', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'DebugStyle', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'error-style', NULL, NULL, '0103', '00', '00', NULL, 'error-style', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(18); -- error-style

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Char', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Raw', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'transfer-mode', NULL, NULL, '0103', '00', '00', NULL, 'transfer-mode', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(19); -- transfer-mode

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'before-procedure', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'before-procedure', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(20); -- before-procedure

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'after-procedure', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'after-procedure', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(21); -- after-procedure

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F818E00080030C000000040532330809181B23262A343503150B0C07062729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'bind-bucket-lengths', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'bind-bucket-lengths', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, plsql_num_coll_type, 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(22); -- bind-bucket-lengths

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83F818E00080030C000000040532330809181B23262A343503150B0C07062729281617'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'bind-bucket-widths', XDB.XDB$QNAME('00', 'unsignedInt'), '04', '44', '00', '00', NULL, 'bind-bucket-widths', 'NUMBER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, plsql_num_coll_type, 'XDB', '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'unbounded', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(23); -- bind-bucket-widths

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'always-describe-procedure', NULL, NULL, '0103', '00', '00', NULL, 'always-describe-procedure', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(24); -- always-describe-procedure

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000110B'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'InfoDebug', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'info-logging', NULL, NULL, '0103', '00', '00', NULL, 'info-logging', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(25); -- info-logging

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'owa-debug-enable', NULL, NULL, '0103', '00', '00', NULL, 'owa-debug-enable', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(26); -- owa-debug-enable

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B81820008003040000000405320809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'request-validation-function', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'request-validation-function', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(27); -- request-validation-function

    insert into xdb.xdb$simple_type s (s.xmlextra, s.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$SIMPLE_T(XDB.XDB$RAW_LIST_T('23020000000106'), config_schema_ref, NULL, '00', XDB.XDB$SIMPLE_DERIVATION_T(XDB.XDB$RAW_LIST_T('330008020000118B8002'), NULL, XDB.XDB$QNAME('00', 'string'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, XDB.XDB$FACET_LIST_T(XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'On', '00', NULL), XDB.XDB$FACET_T(XDB.XDB$RAW_LIST_T('130200000102'), NULL, 'Off', '00', NULL)), NULL, NULL), NULL, NULL, NULL, NULL, NULL))
      returning ref(s) into enum_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('839A3820008003040000000432010809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'input-filter-enable', NULL, NULL, '0103', '00', '00', NULL, 'input-filter-enable', 'XDB$ENUM_T', 'XDB', NULL, NULL, enum_ref, enum_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_arr(28); -- input-filter-enable

    insert into xdb.xdb$sequence_model m (m.xmlextra, m.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$MODEL_T(XDB.XDB$RAW_LIST_T('230200000081801C07'), config_schema_ref, 0, NULL, elem_arr, NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(m) into seq_ref;

    insert into xdb.xdb$complex_type c (c.xmlextra, c.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$COMPLEX_T(XDB.XDB$RAW_LIST_T('3308100600000C030D0E131112'), config_schema_ref, NULL, 'plsql-servlet-config', '00', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, seq_ref, NULL, NULL, NULL, plsql_svt_conf_type, 'XDB', '01', NULL, NULL, NULL))
      returning ref(c) into cplx_ref;

    -- Add plsql-servlet-config to xdbconfig.xsd schema
    select s.xmldata.complex_types into elem_arr from 
      xdb.xdb$schema s where ref(s) = config_schema_ref;
    elem_arr.extend(1);
    elem_arr(elem_arr.last) := cplx_ref;
    update xdb.xdb$schema s
       set s.xmldata.complex_types = elem_arr,
           s.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('43163C8600050084010084020184030202081820637573746F6D697A6564206572726F7220706167657320020A3E20706172616D6574657220666F72206120736572766C65743A206E616D652C2076616C7565207061697220616E642061206465736372697074696F6E20200B0C110482800B01131416120A170D')
     where ref(s) = config_schema_ref;

    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
SYS.XMLTYPEEXTRA(SYS.XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), SYS.XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B83820008003040000000405320809181B23262A343503150B0C0D07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'plsql', XDB.XDB$QNAME('01', 'plsql-servlet-config'), NULL, '0102', '00', '00', NULL, 'plsql', plsql_svt_conf_type, 'XDB', NULL, NULL, NULL, cplx_ref, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL, '00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '00', '01', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_plsql;

    -- select the sequence kid corresponding to the servlet type
    select c.xmldata.sequence_kid into servlet_seq_ref from 
      xdb.xdb$complex_type c where ref(c) =
        (select e.xmldata.cplx_type_decl from xdb.xdb$element e
          where e.xmldata.property.name = 'servlet' and
                e.xmldata.property.parent_schema = config_schema_ref);

    -- select the first group of the choices of servlet sequence kid
    select m.xmldata.choice_kids into choices_arr from xdb.xdb$sequence_model m
     where ref(m) = servlet_seq_ref;
    select m.xmldata.elements into elem_arr from xdb.xdb$choice_model m
     where ref(m) = choices_arr(1);

    -- extend it to add the plsql element just created
    elem_arr.extend(1);
    elem_arr(elem_arr.last) := elem_ref_plsql;

    -- update the table with the extended choices and new pd
    update xdb.xdb$choice_model m
       set m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800307')
     where ref(m) = choices_arr(1);

  end if; -- Upgrade servlet/plsql

  -- check if ftp-welcome-message exists
  -- We check it here because we can't have http2-port 
  -- but not ftp-welcome-message
  select count(e.xmldata.property.name) into ftp_welcome_count 
     from xdb.xdb$element e, xdb.xdb$schema s
     where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/xdbconfig.xsd' 
     and e.xmldata.property.parent_schema = ref(s) 
     and e.xmldata.property.name = 'ftp-welcome-message'; 

  if ftp_welcome_count = 0 then 
    -- select the element type corresponding to http config and add
    -- the two new elements to it
    insert into xdb.xdb$element e (e.xmlextra, e.xmldata) values(
XMLTYPEEXTRA(XMLTYPEPI('4E0020687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D61', '500004786462630029687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F7864622F786462636F6E6669672E787364', '500003786462001B687474703A2F2F786D6C6E732E6F7261636C652E636F6D2F786462'), XMLTYPEPI('523030')),
XDB.XDB$ELEMENT_T(XDB.XDB$PROPERTY_T(XDB.XDB$RAW_LIST_T('83B818200080030C000000040532330809181B23262A343503150B0C07272928'), config_schema_ref, xdb.xdb$propnum_seq.nextval, 'ftp-welcome-message', XDB.XDB$QNAME('00', 'string'), NULL, '01', '00', '00', NULL, 'ftp-welcome-message', 'VARCHAR2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00', NULL, NULL, NULL,'00', NULL, NULL, '00'), NULL, NULL, '00', NULL, NULL, '00', '01', '01', '01', '01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1', '00', '01', NULL, NULL, NULL, NULL, NULL, NULL))
      returning ref(e) into elem_ref_ftp_welcome;

    -- select the sequence kid corresponding to the httpconfig type
    select c.xmldata.sequence_kid into ftpcf_seq_ref from 
      xdb.xdb$complex_type c where ref(c)=
        (select e.xmldata.cplx_type_decl from xdb.xdb$element e
          where e.xmldata.property.name='ftpconfig' and
          e.xmldata.property.parent_schema = config_schema_ref);

    -- select the sequence elements
    select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
     where ref(m) = ftpcf_seq_ref;
  
    -- extend it to add the three elements just created
    elem_arr.extend(1);
    elem_arr(elem_arr.last)   := elem_ref_ftp_welcome;

    -- update the table with the extended sequence and new pd
    update xdb.xdb$sequence_model m
       set m.xmldata.elements = elem_arr,
           m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T('230200000081800807')
      where ref(m) = ftpcf_seq_ref;

    -- Insert ftp-welcome-message into schema if none found
    element_type(CONFIG_SCHEMA_URL, 'ftpconfig', ftpconf_type_owner,
                 ftpconf_type);

    alt_type_add_attribute(ftpconf_type_owner, ftpconf_type,
                           '"ftp-welcome-message" VARCHAR2(4000 CHAR)');
  end if;
  commit;
end;
/

show errors;
create or replace procedure upgrade_resource_type as
begin
  if get_upgrade_status() < 510 then
    set_upgrade_status(510, FALSE);
    execute immediate 
    'alter type xdb.xdb$resource_t add attribute (sbresextra xdb.xdb$xmltype_ref_list_t) cascade';
  end if;
end;
/

show errors;

create or replace procedure upgrade_resource_schema as
  FALSE_BOOL              CONSTANT BOOLEAN := FALSE;
  PN_RES_SBRESEXTRA       CONSTANT INTEGER := 745;
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 45;
  TRUE_RAW                CONSTANT RAW(1) := '1';
  FALSE_RAW               CONSTANT RAW(1) := '0';
  T_REF        CONSTANT RAW(2) :='6e'; /* DTYREF */      
  JT_REFERENCE CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('d');

  ellist                 xdb.xdb$xmltype_ref_list_t;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;

begin  

   if get_upgrade_status() >= 515 then
     return;  
   end if;

-- get the Resource schema's REF
   select ref(s) into sch_ref from xdb.xdb$schema s where  
   s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBResource.xsd';

-- Has the property already been added
   select s.xmldata.num_props into numprops from xdb.xdb$schema s 
   where ref(s) = sch_ref;

   IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

-- Add the SBResExtra element to the Resource complexType
     select m.xmldata.elements into ellist from xdb.xdb$sequence_model m, 
     xdb.xdb$complex_type c  where c.xmldata.name = 'ResourceType' and
     c.xmldata.parent_schema = sch_ref and ref(m) = c.xmldata.sequence_kid;

     ellist.extend();
     ellist(28) := xdb.xdb$insertElement(sch_ref,
                                 PN_RES_SBRESEXTRA, 'SBResExtra',
                                 xdb.xdb$qname('00', 'REF'), 0, 2147483647, 
                                 null, T_REF, FALSE_RAW, TRUE_RAW, 
                                 FALSE_RAW, 'SBRESEXTRA', 'REF', null,
                                 JT_REFERENCE, null, null, 
                                 null, null, null, 
                                 null, 1, FALSE_RAW, null, null, 
                                 FALSE_RAW, FALSE_RAW, TRUE_RAW, FALSE_RAW, FALSE_RAW, 
                                 null, null, null, null, FALSE_RAW, null, null, 
                                 null, 'XDB$XMLTYPE_REF_LIST_T', 'XDB', TRUE_RAW,
                                 null, FALSE_RAW);

     update xdb.xdb$sequence_model m
     set m.xmldata.elements = ellist where
     ref(m) = (select c.xmldata.sequence_kid from xdb.xdb$complex_type c 
     where c.xmldata.name = 'ResourceType' and
     c.xmldata.parent_schema = sch_ref);

     update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
     where ref(s) = sch_ref;
     
     set_upgrade_status(515, FALSE_BOOL);
     commit;
   END IF;

end;
/

-- For debugging purposes
select n from xdb.migr9202status;

show errors;
-- Upgrade config schema from the 10102 version
call upgrade_config_schema();

-- Upgrade resource schema from the 10102 version
call upgrade_resource_type();
call upgrade_resource_schema();

-- For debugging purposes
select n from xdb.migr9202status;

drop procedure upgrade_config_schema;
drop procedure upgrade_resource_type;
drop procedure upgrade_resource_schema;

-- drop utility functions
@@xdbuud.sql

-- xmlindex dictionary table creations
-- Done in catxidx.sql invoked by xdbptrl1.sql, below.

-- create the token tables for token manager (used by XML index)
declare
  exist            number;
  bsz              number;
  nmspc_tok_chars  number;
  qname_tok_chars  number;
  path_tok_bytes   number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$PATH_ID'
  and owner = 'XDB';

  if exist = 0 then

    /* figure out block size of XDB user and use appropriate token size */
    select t.block_size into bsz from dba_tablespaces t, dba_users u
       where u.username = 'XDB' and u.default_tablespace = t.tablespace_name;
 
    if bsz < 4096 then
       nmspc_tok_chars := 464;
       qname_tok_chars := 460;
       path_tok_bytes  := 1395;
    elsif bsz < 8192 then
       nmspc_tok_chars := 984;
       qname_tok_chars := 979;
       path_tok_bytes  := 2000;
    else
       nmspc_tok_chars := 2000;
       qname_tok_chars := 2000;
       path_tok_bytes  := 2000;
    end if;
 
    execute immediate                           -- Namespace URI ID Token Table
       'create table xdb.xdb$nmspc_id (
          nmspcuri nvarchar2(' || nmspc_tok_chars || '), 
          id        raw(8))';
 
    execute immediate                           -- QName ID Token Table
       'create table xdb.xdb$qname_id (
          nmspcid      raw(8),
          localname    nvarchar2(' || qname_tok_chars || '),
          flags        raw(4),
          id           raw(8))';
 
    execute immediate                           -- PathID Token Table
       'create table xdb.xdb$path_id (
          path         raw(' || path_tok_bytes || '),
          id           raw(8))';

    /************ Insert reserved values into tables *********************/
    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://www.w3.org/XML/1998/namespace'',          HEXTORAW(''01''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://www.w3.org/XML/2000/xmlns'',              HEXTORAW(''02''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://www.w3.org/XML/2001/XMLSchema-instance'', HEXTORAW(''03''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://www.w3.org/XML/2001/XMLSchema'',          HEXTORAW(''04''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://xmlns.oracle.com/2004/csx'',              HEXTORAW(''05''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://xmlns.oracle.com/xdb'',                   HEXTORAW(''06''))';

    execute immediate
      'insert into xdb.xdb$nmspc_id values(
         ''http://xmlns.oracle.com/xdb/nonamespace'',       HEXTORAW(''07''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''01''),''space'',
         HEXTORAW(''01''), HEXTORAW(''10''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''01''),''lang'',
         HEXTORAW(''01''), HEXTORAW(''11''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''03''),''type'',
         HEXTORAW(''01''), HEXTORAW(''12''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''03''),''nil'',
         HEXTORAW(''01''), HEXTORAW(''13''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''03''),''schemaLocation'',
         HEXTORAW(''01''), HEXTORAW(''14''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''03''),''noNamespaceSchemaLocation'',
         HEXTORAW(''01''), HEXTORAW(''15''))';

    execute immediate
      'insert into xdb.xdb$qname_id values(HEXTORAW(''02''),''xmlns'',
         HEXTORAW(''01''), HEXTORAW(''16''))';

    commit;

    /************ Create Indexes on token tables *********************/
    execute immediate
      'create unique index xdb.xdb$nmspc_id_nmspcuri
         on xdb.xdb$nmspc_id (nmspcuri)';

    execute immediate
      'create unique index xdb.xdb$nmspc_id_id
         on xdb.xdb$nmspc_id (id)';

    execute immediate
      'create index xdb.xdb$qname_id_nmspcid
         on xdb.xdb$qname_id (nmspcid)';

    execute immediate
      'create unique index xdb.xdb$qname_id_qname
         on xdb.xdb$qname_id (nmspcid, localname, flags)';

    execute immediate
      'create unique index xdb.xdb$qname_id_id
         on xdb.xdb$qname_id (id)';

    execute immediate
      'create unique index xdb.xdb$path_id_path
         on xdb.xdb$path_id (path)';

    execute immediate
      'create unique index xdb.xdb$path_id_id
         on xdb.xdb$path_id (id)';

    execute immediate
      'create unique index xdb.xdb$path_id_revpath
         on xdb.xdb$path_id (SYS_PATH_REVERSE(path))';
  end if;
end;
/

Rem Load embedded PL/SQL gateway schema objects
declare
  exist  number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'EPG$_AUTH'
  and owner = 'SYS';

  if exist = 0 then

    execute immediate
      'create table EPG$_AUTH
       ( DADNAME            varchar2(64) not null,
         USER#              number not null,
         constraint epg$_auth_pk primary key (dadname,user#))';

    execute immediate
      'create or replace view USER_EPG_DAD_AUTHORIZATION
       (DAD_NAME)
       as
       select ea.dadname
         from epg$_auth ea
        where ea.user# = userenv(''SCHEMAID'')';

    execute immediate
      'create or replace public synonym USER_EPG_DAD_AUTHORIZATION for USER_EPG_DAD_AUTHORIZATION';

    execute immediate
      'grant select on USER_EPG_DAD_AUTHORIZATION to public';

    execute immediate
      'comment on table USER_EPG_DAD_AUTHORIZATION is
       ''DADs authorized to use the user''''s privileges''';

    execute immediate
      'comment on column USER_EPG_DAD_AUTHORIZATION.DAD_NAME is
       ''Name of DAD''';

    execute immediate
      'create or replace view DBA_EPG_DAD_AUTHORIZATION
       (DAD_NAME, USERNAME)
       as
       select ea.dadname, u.name
         from epg$_auth ea, user$ u
        where ea.user# = u.user#';

    execute immediate
      'create or replace public synonym DBA_EPG_DAD_AUTHORIZATION for DBA_EPG_DAD_AUTHORIZATION';

    execute immediate
      'grant select on DBA_EPG_DAD_AUTHORIZATION to select_catalog_role';

    execute immediate
      'grant select on DBA_EPG_DAD_AUTHORIZATION to xdbadmin';

    execute immediate
      'comment on table DBA_EPG_DAD_AUTHORIZATION is
       ''DADs authorized to use different user''''s privileges''';

    execute immediate
      'comment on column DBA_EPG_DAD_AUTHORIZATION.DAD_NAME is
       ''Name of DAD''';

    execute immediate
      'comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
       ''Name of the user whose privileges the DAD is authorized to use''';
  end if;
end;
/

-- When subsequent upgrades are written for 10g, add them here
@@xdbs102
