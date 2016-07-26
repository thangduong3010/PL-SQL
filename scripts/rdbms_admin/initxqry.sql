Rem
Rem $Header: rdbms/admin/initxqry.sql /main/22 2009/12/24 15:21:56 yinlu Exp $
Rem
Rem initxqry.sql
Rem
Rem Copyright (c) 2004, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      initxqry.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED
Rem    yinlu       12/22/09 - bug 9226938
Rem    ayoaz       10/23/08 - add DBMS_XQUERY synonym and eval function
Rem    yinlu       06/20/08 - remove grant option
Rem    yinlu       12/26/06 - clean up: remove setLazyDom as it is already
Rem                           handled in flag
Rem    zliu        10/18/06 - handle transfer of builtin numeric type
Rem    zliu        10/06/06 - support xmlquery with xq atomic input
Rem    zliu        10/05/06 - support xquery in xmltable column expr
Rem    yinlu       08/25/06 - prepare with flags
Rem    zliu        03/29/06 - XbranchMerge zliu_xquery_nolimit from 
Rem                           st_rdbms_10.2 
Rem    zliu        02/05/06 - cache xquery plan 
Rem    zliu        12/01/05 - add constants 
Rem    zliu        11/30/05 - support XMLEXISTS func eval 
Rem    zliu        03/16/06 - handle xquery as clob input 
Rem    ayoaz       03/14/05 - change bind arg to xmltype
Rem    hxzhang     05/03/05 - added setLazyDom
Rem    kmuthiah    02/23/05 - load xquery in initxml.sql, not here
Rem    mkrishna    11/19/04 - pass in schema 
Rem    mkrishna    11/18/04 - multi args to JAva 
Rem    mkrishna    11/15/04 - remove references to xmlparser 
Rem    mkrishna    09/13/04 - make str size to be 4K 
Rem    mkrishna    08/23/04 - handle exceptions correctly 
Rem    mkrishna    08/21/04 - handle null entries in fetchall 
Rem    mkrishna    08/19/04 - use /a/node() instead of * 
Rem    mkrishna    08/15/04 - add new initxqry 
Rem    kmuthiah    08/11/04 - do not load private xmlparserv2.jar 
Rem    mkrishna    07/31/04 - add -f option 
Rem    mkrishna    07/23/04 - use nls_sort 
Rem    yinlu       07/21/04 - force to load xmlparserv2.jar 
Rem    mkrishna    06/15/04 - use clobs instead of strings 
Rem    zliu        05/11/04 - make execute parallel enabled
Rem    mkrishna    04/28/04 - mkrishna_xquery_server
Rem    mkrishna    03/31/04 - remove C dependency 
Rem    mkrishna    01/21/04 - change to DBMS_XQUERYINT 
Rem    mkrishna    01/15/04 - support function registeration 
Rem    mkrishna    01/15/04 - use CLOBS 
Rem    mkrishna    01/13/04 - use clobs 
Rem    mkrishna    01/07/04 - add range predicate 
Rem    mkrishna    12/22/03 - add public synonym for dbms_xquery 
Rem    mkrishna    12/08/03 - add getting XQueryX out 
Rem    mkrishna    09/04/03 - Created
Rem

create or replace package dbms_xqueryint authid current_user is 
 
 /* flags defined in qmxqrs.c and OXQServer.java */
 /* Fragment flag */
 QMXQRS_JAVA_FRAGMENT    CONSTANT NUMBER := 1;
 QMXQRS_JAVA_SCHEMABASED CONSTANT NUMBER := 2;
 /* variable bind is SQL scalar input value */
 QMXQRS_JAVA_XS_DEC_INPUT   CONSTANT NUMBER := 4;
 QMXQRS_JAVA_XS_STR_INPUT   CONSTANT NUMBER := 8;
 QMXQRS_JAVA_XS_FLT_INPUT   CONSTANT NUMBER := 16;
 QMXQRS_JAVA_XS_DBL_INPUT   CONSTANT NUMBER := 32;
 QMXQRS_JAVA_XS_DATE_INPUT   CONSTANT NUMBER := 64;
 QMXQRS_JAVA_XS_TIME_INPUT   CONSTANT NUMBER := 128;
 QMXQRS_JAVA_XS_DATETIME_INPUT   CONSTANT NUMBER := 256;
 QMXQRS_JAVA_XDT_DYTMDUR_INPUT   CONSTANT NUMBER := 512;
 QMXQRS_JAVA_XDT_YRMONDUR_INPUT   CONSTANT NUMBER := 1024;
 /* called by exists evaluation */
 QMXQRS_JAVA_CHK_EXSTS   CONSTANT NUMBER := 2048;
 QMXQRS_JAVA_NO_DOCWRAP   CONSTANT NUMBER := 4096;

 /* qmt.h */
 QMTXT_ANYTYPE             CONSTANT NUMBER := 0;                           
 QMTXT_ANYSIMPLETYPE       CONSTANT NUMBER := 1;
 QMTXT_STRING              CONSTANT NUMBER := 2;
 QMTXT_BOOLEAN             CONSTANT NUMBER := 3;
 QMTXT_DECIMAL             CONSTANT NUMBER := 4;
 QMTXT_FLOAT               CONSTANT NUMBER := 5;
 QMTXT_DOUBLE              CONSTANT NUMBER := 6;
 QMTXT_DURATION            CONSTANT NUMBER := 7;
 QMTXT_DATETIME            CONSTANT NUMBER := 8;
 QMTXT_TIME                CONSTANT NUMBER := 9;
 QMTXT_DATE                CONSTANT NUMBER := 10;
 QMTXT_GDAY                CONSTANT NUMBER := 11;
 QMTXT_GMONTH              CONSTANT NUMBER := 12;
 QMTXT_GYEAR               CONSTANT NUMBER := 13;
 QMTXT_GYEARMONTH          CONSTANT NUMBER := 14;
 QMTXT_GMONTHDAY           CONSTANT NUMBER := 15;
 QMTXT_HEXBINARY           CONSTANT NUMBER := 16;
 QMTXT_BASE64BINARY        CONSTANT NUMBER := 17;
 QMTXT_ANYURI              CONSTANT NUMBER := 18;
 QMTXT_QNAME               CONSTANT NUMBER := 19;
 QMTXT_NOTATION            CONSTANT NUMBER := 20;

/*  Derived */
 QMTXT_NORMALIZEDSTRING    CONSTANT NUMBER := 21;
 QMTXT_TOKEN               CONSTANT NUMBER := 22;
 QMTXT_LANGUAGE            CONSTANT NUMBER := 23;
 QMTXT_NMTOKEN             CONSTANT NUMBER := 24;
 QMTXT_NMTOKENS            CONSTANT NUMBER := 25;
 QMTXT_NAME                CONSTANT NUMBER := 26;
 QMTXT_NCNAME              CONSTANT NUMBER := 27;
 QMTXT_ID                  CONSTANT NUMBER := 28;
 QMTXT_IDREF               CONSTANT NUMBER := 29;
 QMTXT_IDREFS              CONSTANT NUMBER := 30;
 QMTXT_ENTITY              CONSTANT NUMBER := 31;
 QMTXT_ENTITIES            CONSTANT NUMBER := 32;
 QMTXT_INTEGER             CONSTANT NUMBER := 33;
 QMTXT_NONPOSITIVEINTEGER  CONSTANT NUMBER := 34;
 QMTXT_NEGATIVEINTEGER     CONSTANT NUMBER := 35;
 QMTXT_LONG                CONSTANT NUMBER := 36;
 QMTXT_INT                 CONSTANT NUMBER := 37;
 QMTXT_SHORT               CONSTANT NUMBER := 38;
 QMTXT_BYTE                CONSTANT NUMBER := 39;
 QMTXT_NONNEGATIVEINTEGER  CONSTANT NUMBER := 40;
 QMTXT_UNSIGNEDLONG        CONSTANT NUMBER := 41;
 QMTXT_UNSIGNEDINT         CONSTANT NUMBER := 42;
 QMTXT_UNSIGNEDSHORT       CONSTANT NUMBER := 43;
 QMTXT_UNSIGNEDBYTE        CONSTANT NUMBER := 44;
 QMTXT_POSITIVEINTEGER     CONSTANT NUMBER := 45;

/* XDB standard simple types */
 QMTXT_REF                 CONSTANT NUMBER := 46;
/* Oracle extensions */
 QMTXT_QNAMES              CONSTANT NUMBER := 47;

/*************** XDT basic types for XQuery Primitive Types Beg***************/
 QMTXT_XDT_ANYATOMICTYPE   CONSTANT NUMBER := 48;
 QMTXT_XDT_UNTYPEDANY      CONSTANT NUMBER := 49;
 QMTXT_XDT_UNTYPEDATOMIC   CONSTANT NUMBER := 50;
 QMTXT_XDT_DAYTIMEDURATION CONSTANT NUMBER := 51;
 QMTXT_XDT_YEARMONTHDURATION CONSTANT NUMBER := 52;
/*************** XDT basic types for XQuery Primitive Types End***************/

 QMTXT_INVALIDTYPE CONSTANT NUMBER := 255;

 /* dtydef.h */
 DTYCHR CONSTANT NUMBER := 1;
 DTYNUM CONSTANT NUMBER := 2;
 DTYIBFLOAT  CONSTANT NUMBER := 100;
 DTYIBDOUBLE  CONSTANT NUMBER := 101;
 DTYSTZ  CONSTANT NUMBER := 181;
 DTYESTZ  CONSTANT NUMBER := 188;
 DTYBIN  CONSTANT NUMBER := 23;
 DTYIDS  CONSTANT NUMBER := 183;
 DTYEIDS  CONSTANT NUMBER := 190;
 DTYIYM  CONSTANT NUMBER := 182;
 DTYEIYM  CONSTANT NUMBER := 189;
 
 /* flags used when prepare an XQuery, 
  * defined in qmxqrs.c and Configuration.java */
 QMXQRS_JCONF_XQ_PUSHDOWN CONSTANT NUMBER := 1;
 QMXQRS_JCONF_VAR_AS_EXTL CONSTANT NUMBER := 2;
 QMXQRS_JCONF_EXTL_FUNC_LAX CONSTANT NUMBER := 4;
 QMXQRS_JCONF_NO_XP_PUSHDOWN CONSTANT NUMBER := 8;
 QMXQRS_JCONF_NO_STATIC_TYPING CONSTANT NUMBER := 16;
 QMXQRS_JCONF_ENABLE_LAZY_DOM CONSTANT NUMBER := 32;

 function exec(hdl in number, retseq in number) 
   return sys.xmltype parallel_enable;

 /****************/
 FUNCTION execallCmn(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number, xqryclb in clob,
        xqisclob in number, hdl in out number)  
  return sys.xmltype;

 FUNCTION execall(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number, 
        hdl in out number)
  return sys.xmltype parallel_enable;


 FUNCTION execallxclb(xqryclb in clob,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number,
        hdl in out number)
  return sys.xmltype parallel_enable;
 /****************/

 /****************/
 FUNCTION executeCmn(xqry in varchar2, xctx in xmltype:=null, retseq in number := 0, xqryclb in clob, xqisclob in number) 
  return sys.xmltype  parallel_enable;

 function execute(xqry in varchar2, xctx in xmltype := null, 
                  retseq in number := 0) 
   return sys.xmltype parallel_enable;

 function executexclb(xqry in clob, xctx in xmltype := null, 
                  retseq in number := 0) 
   return sys.xmltype parallel_enable;
 /****************/

 function getXQueryX(xqry in varchar2) return clob parallel_enable;
 function getXQueryXxclb(xqry in clob) return clob parallel_enable;

  function prepare(xqry in varchar2, nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2, flags in number) return number;
  function preparexclb(xqry in clob, nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2, flags in number) return number;

  procedure bind(hdl in number, name in varchar2, flags in number, xctx in clob, schema in varchar2 ) ; 

  procedure bindWithType(hdl in number, name in varchar2, flags in number, xctx in clob, schema in varchar2 , xqtype in number) ; 

 function bindXML(hdl in number, name in varchar2, xctx in sys.xmltype) 
  return number
  as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.bindXML(int, java.lang.String, oracle.xdb.XMLType) 
     return int'; 

  procedure execQuery(hdl in number);
  function fetchAll(hdl in number, xctx in out clob, flags in out number)
  return number;
  function fetchOne(hdl in number, xctx in out clob, flags in out number, str out varchar2, xqtype in out number) return number;
  procedure closeHdl(hdl in number);

 /* XMLExists Support */
 function exec_exists(hdl in number, retseq in number) return number;
 function execall_exists(xqry in varchar2,  nlssrt in varchar2, 
        nlscmp in varchar2,
        dbchr in varchar2, retseq in number, flags in number,
        hdl in out number)
   return number;
 FUNCTION execallxclb_exists(xqryclb in clob,  nlssrt in varchar2, 
        nlscmp in varchar2,
        dbchr in varchar2, retseq in number, flags in number,
        hdl in out number)  
  return number;

end;
/

CREATE OR REPLACE PACKAGE BODY dbms_xqueryint  AS
 
 FUNCTION prepare(xqry in varchar2,
              nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2, flags in number)  return number
   as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.prepareQuery(java.lang.String, 
         java.lang.String, java.lang.String, java.lang.String, int) return int';

 FUNCTION preparexclb(xqry in clob,
              nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2, flags in number)  return number
   as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.prepareQuery(oracle.sql.CLOB, 
         java.lang.String, java.lang.String, java.lang.String, int) return int';

 /*pass null for context binds. */
 procedure bind(hdl in number, name  in varchar2, flags  in number, 
    xctx in clob, schema in varchar2)
  as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.bind(int, java.lang.String, int, oracle.sql.CLOB,
     java.lang.String)'; 

  procedure bindWithType(hdl in number, name in varchar2, flags in number, xctx in clob, schema in varchar2 , xqtype in number) 
  as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.bindWithType(int, java.lang.String, int, 
     oracle.sql.CLOB,
     java.lang.String, int)'; 

 FUNCTION fetchOne(hdl in number, xctx in out clob, flags in out number,
     str out varchar2, xqtype in out number) return number as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.fetchOne(int, oracle.sql.CLOB[], int[],
     java.lang.String[], int[]) return int';

 FUNCTION fetchAll(hdl in number, xctx in out clob, flags in out number)
   return number
      as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.fetchAll(int, oracle.sql.CLOB[], int[]) return int';

 procedure execQuery(hdl in number) as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.execute(int)' ;

 procedure closeHdl(hdl in number) as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.closeHdl(int)' ;

 /* return xmltype(content) */
 FUNCTION exec_cont(hdl in number) return sys.xmltype is
    clb clob := ' '; 
   ret xmltype := null;
   outflg number := 0;
   fetch_ok number ;
 begin
  
   fetch_ok := fetchAll(hdl, clb, outflg); 

   if  fetch_ok >= 1 then 
     if outflg  = QMXQRS_JAVA_FRAGMENT then
       ret :=  
       xmltype.createxml('<A>'||  clb || '</A>',null,1,1).extract('/A/node()'); 
     else
        ret :=  xmltype.createxml(clb, null, 1,1); 
     end if;
   end if;

    /* we cache the xquery plan in qmxqrs.c level, so we don't close the
     * handle ourselves, instead, replying on qmxqrs.c to call plan close
     */
   /*closeHdl(hdl);*/
   return ret;

 end;

 /* return a sequence */
 FUNCTION exec_seq(hdl in number) return sys.xmltype is
  fetch_ok number;
  str varchar2(4000);
  clb clob := ' '; 
   xval xmltype;
   ret xmltype := null;
  outflg number := 0;
  xqtype number := QMTXT_INVALIDTYPE;
  noDocWrap number := 0;
 begin
  
   loop 

     /* initialize loop variables */
     outflg := 0;
     xqtype := QMTXT_INVALIDTYPE;
     noDocWrap := 0;

     fetch_ok := fetchOne(hdl, clb, outflg, str, xqtype);
     if  fetch_ok = 0 then exit; end if;

     if  str is not null then
       /* sync with OXQServerJava.getOutAtomicType() */
       /*
       dbms_output.put_line('xqtype = ' || to_char(xqtype));
       dbms_output.put_line('outflg = ' || to_char(outflg));
       */
       if xqtype = QMTXT_STRING then
         /*DTYCHR; QMTXT_STRING;*/
         select SYS_XQ_PKSQL2XML(str, 1, 2) into xval from dual;
       elsif xqtype =  QMTXT_DECIMAL then
         /*DTYNUM; QMTXT_DECIMAL;*/
         select SYS_XQ_PKSQL2XML(to_number(str), 2, 4) into xval from dual;
       elsif xqtype =  QMTXT_INTEGER then
         /*DTYNUM; QMTXT_INTEGER;*/
         select SYS_XQ_PKSQL2XML(to_number(str), 2, 33) into xval from dual;
       elsif xqtype =  QMTXT_DATE then
         /*DTYSTZ; QMTXT_DATE;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,10,0,0,181), 181, 10) 
         into xval 
         from dual;
       elsif xqtype =  QMTXT_TIME then
         /*DTYSTZ; QMTXT_TIME;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,9,0,0,181), 181, 9) 
         into xval 
         from dual;
       elsif xqtype =  QMTXT_DATETIME then
         /*DTYSTZ; QMTXT_DATETIME;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,8,0,0,181), 181, 8) 
         into xval 
         from dual;
       elsif xqtype =  QMTXT_FLOAT then
         /*DTYIBFLOAT; QMTXT_FLOAT;*/
         select SYS_XQ_PKSQL2XML(to_binary_float(str), 100, 5) into xval from dual;
       elsif xqtype =  QMTXT_DOUBLE then
         /*DTYIBDOUBLE; QMTXT_DOUBLE;*/
         select SYS_XQ_PKSQL2XML(to_binary_double(str), 101, 6) into xval from dual;
        elsif xqtype =  QMTXT_XDT_YEARMONTHDURATION then
         /*DTYEIYM; QMTXT_XDT_YEARMONTHDURATION;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,52,0,0,189), 189, 52) into xval from dual;
        elsif xqtype =  QMTXT_XDT_DAYTIMEDURATION then
         /*DTYEIDS; QMTXT_XDT_DAYTIMEDURATION;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,51,0,0,190), 190, 51) into xval from dual;
        elsif xqtype =  QMTXT_BOOLEAN then
         /*DTYBIN; QMTXT_BOOLEAN;*/
         select SYS_XQ_PKSQL2XML(case SYS_XQ_ATOMCNVCHK(str,1,3) WHEN '0' THEN HEXTORAW('00')  ELSE HEXTORAW('01')  END, 23, 3) into xval from dual;
        elsif xqtype =  QMTXT_GDAY then
         /*DTYSTZ; QMTXT_GDAY;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,11,0,0,181), 181, 11) into xval from dual;
        elsif xqtype =  QMTXT_GMONTH then
         /*DTYSTZ; QMTXT_GMONTH;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,12,0,0,181), 181, 12) into xval from dual;
        elsif xqtype =  QMTXT_GYEAR then
         /*DTYSTZ; QMTXT_GYEAR;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,13,0,0,181), 181, 13) into xval from dual;
        elsif xqtype =  QMTXT_GYEARMONTH then
         /*DTYSTZ; QMTXT_GYEARMONTH;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,14,0,0,181), 181, 14) into xval from dual;
        elsif xqtype =  QMTXT_GMONTHDAY then
         /*DTYSTZ; QMTXT_GMONTHDAY;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,15,0,0,181), 181, 15) into xval from dual;
        elsif xqtype =  QMTXT_DURATION then
         /*DTYCHR; QMTXT_DURATION;*/
         select SYS_XQ_PKSQL2XML(str, 1,7) into xval from dual;
        elsif xqtype =  QMTXT_XDT_UNTYPEDATOMIC then
         /*DTYCHR; QMTXT_XDT_UNTYPEDATOMIC;*/
         select SYS_XQ_PKSQL2XML(str, 1,50) into xval from dual;
        elsif xqtype =  QMTXT_BASE64BINARY  then
         /*DTYBIN; QMTXT_BASE64BINARY ;*/
         select SYS_XQ_PKSQL2XML(SYS_XMLCONV(str,3,17,0,0,23), 23, 17) into xval from dual;
        elsif xqtype =  QMTXT_HEXBINARY  then
         /*DTYBIN; QMTXT_HEXBINARY ;*/
         select SYS_XQ_PKSQL2XML(HEXTORAW(str), 23, 16) into xval from dual;
        elsif xqtype =  QMTXT_NONPOSITIVEINTEGER  then
         /*DTYNUM; QMTXT_NONPOSITIVEINTEGER ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,34), 2, 34) into xval from dual;
        elsif xqtype =  QMTXT_NEGATIVEINTEGER  then
         /*DTYNUM; QMTXT_NEGATIVEINTEGER ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,35), 2, 35) into xval from dual;
        elsif xqtype =  QMTXT_LONG  then
         /*DTYNUM; QMTXT_LONG ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,36), 2, 36) into xval from dual;
        elsif xqtype =  QMTXT_INT  then
         /*DTYNUM; QMTXT_POSITIVEINTEGER ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,37), 2, 37) into xval from dual;
        elsif xqtype =  QMTXT_SHORT  then
         /*DTYNUM; QMTXT_SHORT ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,38), 2, 38) into xval from dual;
        elsif xqtype =  QMTXT_BYTE  then
         /*DTYNUM; QMTXT_BYTE ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,39), 2, 39) into xval from dual;
        elsif xqtype =  QMTXT_NONNEGATIVEINTEGER  then
         /*DTYNUM; QMTXT_NONNEGATIVEINTEGER ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,40), 2, 40) into xval from dual;
        elsif xqtype =  QMTXT_UNSIGNEDLONG  then
         /*DTYNUM; UNSIGNEDLONG ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,41), 2, 41) into xval from dual;
        elsif xqtype =  QMTXT_UNSIGNEDINT  then
         /*DTYNUM; UNSIGNEDINT ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,42), 2, 42) into xval from dual;
        elsif xqtype =  QMTXT_UNSIGNEDSHORT  then
         /*DTYNUM; UNSIGNEDSHORT ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,43), 2, 43) into xval from dual;
        elsif xqtype =  QMTXT_UNSIGNEDBYTE  then
         /*DTYNUM; UNSIGNEDBYTE ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,44), 2, 44) into xval from dual;
        elsif xqtype =  QMTXT_POSITIVEINTEGER  then
         /*DTYNUM; QMTXT_POSITIVEINTEGER ;*/
         select SYS_XQ_PKSQL2XML(SYS_XQ_ATOMCNVCHK(to_number(str),2,45), 2, 45) into xval from dual;
       else
         /*DTYCHR; QMTXT_STRING;*/
         select SYS_XQ_PKSQL2XML(str, 1, 2) into xval from dual;
       end if;
     else
       if bitand(outflg, QMXQRS_JAVA_NO_DOCWRAP) = QMXQRS_JAVA_NO_DOCWRAP then
         noDocWrap := 1;
       end if;
       if bitand(outflg, QMXQRS_JAVA_FRAGMENT) = QMXQRS_JAVA_FRAGMENT then
         /* This make pi , comment, text, attribute node to go through this,
          * however, attribute node can not survive from /A/node() as it
          * becomes text node, we need standalone attribute node tran to
          * handle this. For these case, however, noDocWrap = 1 and 
          * sys_xqcon2seq() call below will make it turn on NO_DOCWRAP flag.
          * Also, for the case of xquery DM node constructed from 
          * document {} constructor, the xquery java engine uses
          * DOM QMXQRS_JAVA_FRAGMENT node to represent this, however, the
          * noDocWrap =0 in this case and xmltype.extract() returning content
          * which has NO NO_DOCWRAP flag on, which is right for this case.
          */
         xval := 
          xmltype.createxml('<A>'||clb ||'</A>',null,1,1).extract('/A/node()'); 
         /*
          select extract(xmltype.createxml('<A>'||clb ||'</A>',null,1,1),'/A/node()') into xval
          from dual; 
         */
       else
         /* only document node or single element node goes to here */
         xval := xmltype.createxml(clb,null,1,1); 
       end if;
       clb := ' ';
     end if;
       
     /*dbms_output.put_line('noDocWrap = ' || to_char(noDocWrap));*/
     if (noDocWrap = 1) then
       /* turn on NO_DOCWRAP flag in the image for node without document node
        * wrapper.
        */
       select sys_xqcon2seq(xval) into xval from dual;
     end if;

     select sys_xqconcat(ret, xval) into ret from dual; 
       
   end loop; 

    /* we cache the xquery plan in qmxqrs.c level, so we don't close the
     * handle ourselves, instead, replying on qmxqrs.c to call plan close
     */
   /*closeHdl(hdl); */
   return ret; 
 end;

 /* for XMLEXISTS(), we just want to make sure result is NOT empty sequnce*/
 FUNCTION exec_exists(hdl in number, retseq in number) return number is
  fetch_ok number;
  str varchar2(4000);
  clb clob := ' ';
  xval xmltype;
  ret number := 0;
  outflg number := QMXQRS_JAVA_CHK_EXSTS; /* pass on flag for XMLEXISTS check*/
  xqtype number := 0;
 begin


     fetch_ok := fetchOne(hdl, clb, outflg, str, xqtype);
     if  fetch_ok = 0 then 
      ret := 0;
     else
       ret := 1;
     end if;

    /* we cache the xquery plan in qmxqrs.c level, so we don't close the
     * handle ourselves, instead, replying on qmxqrs.c to call plan close
     */
   /*closeHdl(hdl);*/
   return ret; 
 end;

 FUNCTION exec(hdl in number, retseq in number) 
  return sys.xmltype is
 begin
   if retseq = 1 then
     return exec_seq(hdl);
   else
     return exec_cont(hdl);
   end if;
 end;

 FUNCTION getXQueryX(xqry in varchar2)  return clob  as LANGUAGE JAVA NAME
 'oracle.xquery.OXQServer.getXQueryX(java.lang.String) return oracle.sql.CLOB';

 FUNCTION getXQueryXxclb(xqry in clob)  return clob  as LANGUAGE JAVA NAME
 'oracle.xquery.OXQServer.getXQueryX(oracle.sql.CLOB) return oracle.sql.CLOB';

 FUNCTION execallCmn(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number, xqryclb in clob,
        xqisclob in number, hdl in out number)  
  return sys.xmltype is
    --hdl number;
 begin
  if (hdl = 0) then
    /* xquery plan has not been built, so let's build it */
    if xqisclob = 1 then
      hdl := preparexclb(xqryclb, nlssrt, nlscmp, dbchr, flags);
    else
      hdl := prepare(xqry, nlssrt, nlscmp, dbchr, flags);
    end if;
  end if;

  execQuery(hdl);
  return exec(hdl, retseq);
 end;

 FUNCTION execallCmn_exists(xqry in varchar2,  nlssrt in varchar2, 
        nlscmp in varchar2,
        dbchr in varchar2, retseq in number, flags in number, xqryclb in clob,
        xqisclob in number, hdl in out number)  
  return number is
    --hdl number;
 begin
  if (hdl = 0) then
    /* xquery plan has not been built, so let's build it */
    if xqisclob = 1 then
      hdl := preparexclb(xqryclb, nlssrt, nlscmp, dbchr, flags);
    else
      hdl := prepare(xqry, nlssrt, nlscmp, dbchr, flags);
    end if;
  end if;

  execQuery(hdl);
  return exec_exists(hdl, retseq);
 end;

 FUNCTION execall(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number, hdl in out number)  
  return sys.xmltype is
  begin
    return execallCmn(xqry, nlssrt, nlscmp, dbchr, retseq, flags, null, 0, hdl);
  end;

 FUNCTION execallxclb(xqryclb in clob,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, flags in number, hdl in out number)
  return sys.xmltype parallel_enable is
  begin
    return execallCmn(null, nlssrt, nlscmp, dbchr, retseq, flags, xqryclb, 1, hdl);
  end;

 FUNCTION execall_exists(xqry in varchar2,  nlssrt in varchar2, 
        nlscmp in varchar2,
        dbchr in varchar2, retseq in number, flags in number,
        hdl in out number)  
  return number is
  begin
    return execallCmn_exists(xqry, nlssrt, nlscmp, dbchr, retseq, flags, null, 0, hdl);
  end;

 FUNCTION execallxclb_exists(xqryclb in clob,  nlssrt in varchar2, 
        nlscmp in varchar2,
        dbchr in varchar2, retseq in number, flags in number,
        hdl in out number)  
  return number is
  begin
    return execallCmn_exists(null, nlssrt, nlscmp, dbchr, retseq, flags, xqryclb, 1, hdl);
  end;

 /* testing function */
 FUNCTION executeCmn(xqry in varchar2, xctx in xmltype:=null, retseq in number := 0, xqryclb in clob, xqisclob in number) 
  return sys.xmltype  parallel_enable is
   a number := 0;
   dbchr varchar2(30);
   nlscmp varchar2(30);
   nlssrt varchar2(30);
   hdl number;
 begin

  select value into dbchr from v$nls_parameters where 
      parameter = 'NLS_CHARACTERSET';
  select value into nlssrt from v$nls_parameters where 
      parameter = 'NLS_SORT';
  select value into nlscmp from v$nls_parameters where 
      parameter = 'NLS_COMP';

   if xqisclob = 1 then
     hdl := preparexclb(xqryclb, nlssrt, nlscmp, dbchr, 0);
   else
     hdl := prepare(xqry, nlssrt, nlscmp, dbchr, 0);
   end if;

   if xctx is not null then
      if xctx.isFragment() = 1 then
        a := QMXQRS_JAVA_FRAGMENT;
      end if; 
      bind(hdl, null, a, xctx.getclobval(), xctx.getSchemaURL());
   end if;

  execQuery(hdl);
  return exec(hdl, retseq);

 end;

 FUNCTION execute(xqry in varchar2, xctx in xmltype:=null, retseq in number := 0)
  return sys.xmltype  parallel_enable is
  begin
   return  executeCmn(xqry, xctx, retseq, null, 0);
  end;

 function executexclb(xqry in clob, xctx in xmltype := null, 
                  retseq in number := 0) 
   return sys.xmltype parallel_enable is
  begin
   return  executeCmn(null, xctx, retseq, xqry, 1);
  end;

end;
/
show errors;
/* in case user is upgrading from an earlier version where execute with
 * grant option was granted, we need to revoke the privilege
 * then regrant.
 */
begin
  execute immediate 'revoke execute on dbms_xqueryint from public force';
exception
  when others then
  null;
end;
/
grant execute on dbms_xqueryint to public;


-- DBMS_XQUERY

create or replace package dbms_xquery authid current_user is

  FUNCTION eval(xqry varchar2) return xmltype;

end;
/
show errors;

CREATE OR REPLACE PACKAGE BODY dbms_xquery AS
 
  FUNCTION eval(xqry varchar2) return xmltype is
    pragma autonomous_transaction;
    rval xmltype := null;
  begin
    execute immediate 'select xmlquery(:1 returning content) from dual' 
      into rval using xqry;
    commit;
    return rval;
  exception
    when others then
      rollback;
      raise;
  end;

end;
/
show errors;
grant execute on dbms_xquery to public;

create or replace public synonym dbms_xquery for sys.dbms_xquery;
 
