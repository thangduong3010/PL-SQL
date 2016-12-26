Rem
Rem $Header: catxdbdt.sql 22-sep-2006.16:29:57 mrafiq Exp $
Rem
Rem catxdbdt.sql
Rem
Rem Copyright (c) 1900, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbdt.sql - XDB initialization DaTa 
Rem
Rem    DESCRIPTION
Rem      Initialization data (schema for schema) for XDB
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mrafiq      09/22/06 - remove default value for translate
Rem    mrafiq      09/20/06 - Fix typeid default value
Rem    smalde      02/16/06 - Translations.
Rem    nkandalu    12/06/05 - 4751888: add substitution to derivationChoice 
Rem    abagrawa    10/05/05 - Add sqltype to simpletype 
Rem    abagrawa    09/29/05 - Add typeID 
Rem    rmurthy     02/17/05 - populate namespace array 
Rem    rmurthy     10/16/03 - temp fix for timefacet 
Rem    njalali     02/18/03 - putting ABSTRACT back in
Rem    abagrawa    01/15/03 - Fix simpletype
Rem    njalali     10/29/02 - removing null annotation varray
Rem    bkhaladk    09/13/02 - add text type
Rem    sichandr    07/31/02 - rename simplecontent to simplecont
Rem    esedlar     06/25/02 - Fix memtype for binary
Rem    sichandr    07/17/02 - choice instead of sequence
Rem    bkhaladk    04/02/02 - baseProp should be system_qmtp TRUE
Rem    abagrawa    05/28/02 - Add ID attribute to facets
Rem    rmurthy     03/15/02 - add notation, unique, key, keyref
Rem    sichandr    02/25/02 - add owner parameter to xdb$ExtName2IntName
Rem    mkrishna    01/28/02 - pass namespace to inserAny
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    rmurthy     01/02/02 - change targetNamespace to XMLSchema
Rem    rmurthy     12/27/01 - remove userPrivilege and add defaultXSL
Rem    rmurthy     12/17/01 - set system=true for XDB specific attrs
Rem    rmurthy     12/07/01 - add PD columns to all types
Rem    njalali     12/04/01 - transient and base proprties
Rem    rmurthy     11/30/01 - dont insert empty varrays
Rem    sichandr    12/05/01 - fix annotation SQLCollType
Rem    sichandr    11/28/01 - set global flag in bootstrap schemas
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    rmurthy     11/20/01 - specify coll type info
Rem    sichandr    10/31/01 - add ID attribute
Rem    njalali     10/27/01 - adding T_TIMESTAMP constant
Rem    sichandr    10/29/01 - authid current_user for xdb$ExtName2IntName
Rem    sichandr    10/18/01 - add xdb$extname2intname
Rem    rmurthy     09/19/01 - fix maintainDOM
Rem    rmurthy     09/13/01 - change documentation/appinfo to mixed types
Rem    sichandr    09/18/01 - support storeVarrayAsTable
Rem    rmurthy     08/26/01 - add support for substitutionGroup, named group
Rem    njalali     08/06/01 - added QMXT_XOBD
Rem    rmurthy     08/03/01 - support for inheritance
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    rmurthy     05/31/01 - fix ctype decl. for schema/include
Rem    spannala    05/18/01 - xmltype_p -> xmltype
Rem    rmurthy     05/09/01 - remove conn stmt
Rem    rmurthy     04/25/01 - annotation, appinfo, documentation
Rem    rmurthy     04/20/01 - support for any, anyAttribute
Rem    rmurthy     03/27/01 - add use,value attrs for attribute
Rem    rmurthy     02/22/01 - major changes for new xml schemas
Rem    rmurthy     02/02/01 - add support for element ref
Rem    rmurthy     01/12/01 - consistently uppercase all schema object names
Rem    mkrishna    12/03/00 - change sys_nc values to xmldata
Rem    rmurthy     12/04/00 - uppercase type & schema names
Rem    njalali     11/16/00 - sqlschema/sqltype order switch
Rem    esedlar     11/01/00 - Add SQL schema
Rem    njalali     09/25/00 - Add typename for <schema> XML type
Rem    esedlar     07/12/00 - Created
Rem

create or replace library xdb.XMLSchema_lib trusted as static
/

Rem Function that converts namespace array to internal pickled 
Rem format. Used to bootstrap the schema for schemas and 
Rem also the resource schema
create or replace function xdb.xdb$getPickledNS
       (nsuri IN VARCHAR2, pfx IN VARCHAR2) 
return raw is
  external
  name "GET_PICKLED_NS"
  language C
  library XMLSCHEMA_LIB
  with context
  parameters (context,
              nsuri        STRING,
              nsuri        INDICATOR sb4,
              nsuri        LENGTH sb4,
              pfx        STRING,
              pfx        INDICATOR sb4,
              pfx        LENGTH sb4,
              return         LENGTH sb4,
              return      INDICATOR sb4, 
              return);
/

Rem Bootstrap for schema for schemas
create or replace package xdb.xdb$bootstrap as

        SIMPLE_SQL CONSTANT VARCHAR2(256) := 
                         'insert into xdb.xdb$simple_type s (xmldata) ' ||
                         'values (:1) returning ref(s) into :2';
        SEQUENCE_SQL CONSTANT VARCHAR2(256) := 
                    'insert into xdb.xdb$sequence_model c (xmldata) ' ||
                         'values (:1) returning ref(c) into :2';
        CHOICE_SQL CONSTANT VARCHAR2(256) :=
                    'insert into xdb.xdb$choice_model c (xmldata) ' ||
                         'values (:1) returning ref(c) into :2';
        COMPLEX_SQL CONSTANT VARCHAR2(256) := 
                    'insert into xdb.xdb$complex_type c (xmldata) ' ||
                         'values (:1) returning ref(c) into :2';
        COMPLEX_UPDATE_SQL CONSTANT VARCHAR2(256) := 
                    'update xdb.xdb$complex_type c set xmldata = :1 ' ||
                         'where ref(c) = :2';
        ATTR_SQL CONSTANT VARCHAR2(256) := 
                          'insert into xdb.xdb$attribute a (xmldata) ' ||
                         'values (:1) returning ref(a) into :2';
        ELEM_SQL CONSTANT vARCHAR2(256) := 
                          'insert into xdb.xdb$element e (xmldata) ' ||
                         'values (:1) returning ref(e) into :2';
        ANY_SQL CONSTANT VARCHAR2(256) := 
                          'insert into xdb.xdb$any a (xmldata) ' ||
                         'values (:1) returning ref(a) into :2';


        LPXELEMENT   CONSTANT INTEGER :=1;
        LPXATTR      CONSTANT INTEGER :=2;

        TD_EXTENSION   CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0001');
        TD_RESTRICTION CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0002');
        TD_LIST        CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0003');
        TD_ALL         CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0004');
        TD_SUBSTITUTION CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0005');
        TD_UNION       CONSTANT xdb.xdb$derivationChoice :=
                                xdb.xdb$derivationChoice('0006');

        TRANSIENT_GENERATED  CONSTANT xdb.xdb$transientChoice := 
                                        xdb.xdb$transientChoice('01');
        TRANSIENT_MANIFESTED CONSTANT xdb.xdb$transientChoice :=
                                        xdb.xdb$transientChoice('02');

        FC_UNQUAL      CONSTANT xdb.xdb$formChoice := xdb.xdb$formChoice('00');
        FC_QUAL        CONSTANT xdb.xdb$formChoice := xdb.xdb$formChoice('01');

        T_JAVASTRING CONSTANT RAW(2) :='101';
        T_XOB        CONSTANT RAW(2) :='102';
        T_ENUM       CONSTANT RAW(2) :='103';
        T_QNAME      CONSTANT RAW(2) :='104'; 
        T_XOBD       CONSTANT RAW(2) :='105'; 
        T_CSTRING    CONSTANT RAW(2) :='1'; /* DTYCHR */
        T_NUMBER     CONSTANT RAW(2) :='2'; /* DTYNUM */
        T_INTEGER    CONSTANT RAW(2) :='3'; /* DTYINT */
        T_FLOAT      CONSTANT RAW(2) :='4'; /* DTYFLT */
        T_DATE       CONSTANT RAW(2) :='c'; /* DTYDAT */
        T_TIMESTAMP  CONSTANT RAW(2) :='b4'; /* DTYSTAMP */
        T_BINARY     CONSTANT RAW(2) :='17'; /* DTYBIN */
        T_UNSIGNINT  CONSTANT RAW(2) :='44'; /* DTYINT */
        T_REF        CONSTANT RAW(2) :='6e'; /* DTYREF */
        T_BOOLEAN    CONSTANT RAW(2) :='fc'; /* DTYBOL */
        T_BLOB       CONSTANT RAW(2) :='71'; /* DTYBLOB */
        T_CLOB       CONSTANT RAW(2) :='70'; /* DTYBLOB */

        JT_STRING     CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('0');
        JT_INT        CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('1');
        JT_LONG       CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('2');
        JT_SHORT      CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('3');
        JT_BYTE       CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('4');
        JT_FLOAT      CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('5');
        JT_DOUBLE     CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('6');
        JT_BIGDECIMAL CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('6');
        JT_BOOLEAN    CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('8');
        JT_BYTEARRAY  CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('9');
        JT_STREAM     CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('a');
        JT_CHARSTREAM CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('b');
        JT_TIMESTAMP  CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('c');
        JT_REFERENCE  CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('d');
        JT_QNAME      CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('e');
        JT_ENUM       CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('f');
        JT_XMLTYPE    CONSTANT xdb.xdb$javatype := xdb.xdb$javatype('10');


        TR_STRING    CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 'string');
        TR_BOOLEAN   CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 'boolean');
        TR_BINARY    CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 'hexBinary');
        TR_INT       CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 'integer');
        TR_NNEGINT   CONSTANT xdb.xdb$qname := xdb.xdb$qname('00', 
                                                         'nonNegativeInteger');

        FALSE        CONSTANT RAW(1) := '0';
        TRUE         CONSTANT RAW(1) := '1';


        PN_TOTAL_PROPNUMS CONSTANT INTEGER := 276;

        PN_SCHEMA_LANG                CONSTANT INTEGER := 212;
        PN_NOTATION_ANNOTATION        CONSTANT INTEGER := 213;
        PN_NOTATION_NAME              CONSTANT INTEGER := 214;
        PN_NOTATION_PUBLIC            CONSTANT INTEGER := 215;
        PN_NOTATION_SYSTEM            CONSTANT INTEGER := 216;
        PN_SCHEMA_NOTATION            CONSTANT INTEGER := 217;
        PN_XPATHSPEC_ANNOTATION       CONSTANT INTEGER := 218;
        PN_XPATHSPEC_XPATH            CONSTANT INTEGER := 219;
        PN_KEYBASE_ANNOTATION         CONSTANT INTEGER := 220;
        PN_KEYBASE_NAME               CONSTANT INTEGER := 221;
        PN_KEYBASE_REFER              CONSTANT INTEGER := 222;
        PN_KEYBASE_SELECTOR           CONSTANT INTEGER := 223;
        PN_KEYBASE_FIELD              CONSTANT INTEGER := 224;
        PN_ELEMENT_UNIQUE             CONSTANT INTEGER := 225;
        PN_ELEMENT_KEY                CONSTANT INTEGER := 226;
        PN_ELEMENT_KEYREF             CONSTANT INTEGER := 227;

        PN_SCHEMA_MAPTONCHAR          CONSTANT INTEGER := 162;
        PN_SCHEMA_MAPTOLOB            CONSTANT INTEGER := 194;
        PN_SCHEMA_GROUP               CONSTANT INTEGER := 192;
        PN_SCHEMA_ATTRGROUP           CONSTANT INTEGER := 193;
        PN_SCHEMA_ID                  CONSTANT INTEGER := 206;
        PN_SCHEMA_VARRAYTAB           CONSTANT INTEGER := 209;
        PN_SCHEMA_OWNER               CONSTANT INTEGER := 210;

        PN_FACET_FIXED  CONSTANT INTEGER := 86;
        PN_NUMFACET_FIXED  CONSTANT INTEGER := 87;
        PN_TIMEFACET_FIXED  CONSTANT INTEGER := 88;
        PN_WHITESPACE_FIXED  CONSTANT INTEGER := 89;

        PN_FACET_ANNOTATION  CONSTANT INTEGER := 228;
        PN_NUMFACET_ANNOTATION  CONSTANT INTEGER := 229;
        PN_TIMEFACET_ANNOTATION  CONSTANT INTEGER := 230;
        PN_WHITESPACE_ANNOTATION  CONSTANT INTEGER := 231;

        PN_FACET_ID CONSTANT INTEGER      := 234;
        PN_NUMFACET_ID CONSTANT INTEGER   := 235;
        PN_TIMEFACET_ID CONSTANT INTEGER  := 236;
        PN_WHITESPACE_ID CONSTANT INTEGER := 237;

        PN_SIMPLE_PARENTSCHEMA        CONSTANT INTEGER := 4;
        PN_SIMPLE_NAME        CONSTANT INTEGER := 6;
        PN_SIMPLE_ABSTRACT        CONSTANT INTEGER := 8;
        PN_SIMPLE_FINAL          CONSTANT INTEGER := 270;
        PN_SIMPLE_BASETYPE        CONSTANT INTEGER := 5;
        PN_SIMPLE_BASE        CONSTANT INTEGER := 7;
        PN_SIMPLE_PRECISION     CONSTANT INTEGER := 11;
        PN_SIMPLE_SCALE         CONSTANT INTEGER := 12;
        PN_SIMPLE_MINLENGTH        CONSTANT INTEGER := 13;        
        PN_SIMPLE_MAXLENGTH        CONSTANT INTEGER := 14;        
        PN_SIMPLE_WHITESPACE        CONSTANT INTEGER := 15;        
        PN_SIMPLE_PERIOD        CONSTANT INTEGER := 16;        
        PN_SIMPLE_DURATION        CONSTANT INTEGER := 17;        
        PN_SIMPLE_MININCLUSIVE        CONSTANT INTEGER := 18;        
        PN_SIMPLE_MAXINCLUSIVE        CONSTANT INTEGER := 19;        
        PN_SIMPLE_PATTERN        CONSTANT INTEGER := 20;        
        PN_SIMPLE_ENUMERATION        CONSTANT INTEGER := 21;        
        PN_SIMPLE_MINEXCLUSIVE  CONSTANT INTEGER := 90;
        PN_SIMPLE_MAXEXCLUSIVE  CONSTANT INTEGER := 91;
        PN_SIMPLE_LENGTH        CONSTANT INTEGER := 92;
        PN_SIMPLE_ID            CONSTANT INTEGER := 196;
        PN_SIMPLEDER_SIMPLETYPE        CONSTANT INTEGER := 9;
        PN_SIMPLEDER_ANNOTATION        CONSTANT INTEGER := 144;
        PN_SIMPLEDER_ID                CONSTANT INTEGER := 195;
        PN_SIMPLE_RESTRICTION        CONSTANT INTEGER := 10;
        PN_SIMPLE_LIST            CONSTANT INTEGER := 117;
        PN_SIMPLE_UNION            CONSTANT INTEGER := 124;
        PN_SIMPLE_TYPEID          CONSTANT INTEGER := 271;
        PN_SIMPLE_SQLTYPE         CONSTANT INTEGER := 273;
        PN_LIST_ITEMTYPE          CONSTANT INTEGER := 118;
        PN_LIST_TYPEREF           CONSTANT INTEGER := 119;
        PN_LIST_SIMPLETYPE        CONSTANT INTEGER := 120;
        PN_LIST_ANNOTATION        CONSTANT INTEGER := 232;
        PN_UNION_MEMBERTYPES      CONSTANT INTEGER := 121;
        PN_UNION_SIMPLETYPE       CONSTANT INTEGER := 122;
        PN_UNION_TYPEREF          CONSTANT INTEGER := 123;
        PN_UNION_ANNOTATION        CONSTANT INTEGER := 233;

        PN_MODEL_PARENTSCHEMA CONSTANT INTEGER := 93;
        PN_MODEL_MINOCCURS    CONSTANT INTEGER := 94;
        PN_MODEL_MAXOCCURS    CONSTANT INTEGER := 95;
        PN_MODEL_ELEMENT      CONSTANT INTEGER := 96;
        PN_MODEL_CHOICE       CONSTANT INTEGER := 97;
        PN_MODEL_SEQUENCE     CONSTANT INTEGER := 98;
        PN_MODEL_ANY          CONSTANT INTEGER := 127;
        PN_MODEL_ANNOTATION   CONSTANT INTEGER := 143;
        PN_MODEL_ID           CONSTANT INTEGER := 201;
        PN_MODEL_GROUP        CONSTANT INTEGER := 165;
        PN_COMPLEXDERIVATION_BASE      CONSTANT INTEGER := 99;
        PN_COMPLEXDERIVATION_ATTRIBUTE CONSTANT INTEGER := 101;
        PN_COMPLEXDERIVATION_ALL       CONSTANT INTEGER := 102;
        PN_COMPLEXDERIVATION_CHOICE    CONSTANT INTEGER := 103;
        PN_COMPLEXDERIVATION_SEQUENCE  CONSTANT INTEGER := 104;
        PN_COMPLEXDERIVATION_ANYATTR   CONSTANT INTEGER := 128;
        PN_COMPLEXDERIVATION_ANNOT     CONSTANT INTEGER := 145;
        PN_COMPLEXDERIVATION_GROUP     CONSTANT INTEGER := 166;
        PN_COMPLEXDERIVATION_ATTRGROUP CONSTANT INTEGER := 167;
        PN_COMPLEXDERIVATION_ID        CONSTANT INTEGER := 202;
        PN_CONTENT_MIXED        CONSTANT INTEGER := 105;
        PN_CONTENT_RESTRICTION  CONSTANT INTEGER := 106;
        PN_CONTENT_EXTENSION    CONSTANT INTEGER := 107;
        PN_CONTENT_ANNOTATION   CONSTANT INTEGER := 146;
        PN_CONTENT_ID           CONSTANT INTEGER := 203;
        PN_COMPLEXTYPE_PARENTSCHEMA     CONSTANT INTEGER := 23;
        PN_COMPLEXTYPE_FINAL            CONSTANT INTEGER := 24;
        PN_COMPLEXTYPE_BLOCK            CONSTANT INTEGER := 25;
        PN_COMPLEXTYPE_MIXED            CONSTANT INTEGER := 108;
        PN_COMPLEXTYPE_ABSTRACT         CONSTANT INTEGER := 109;
        PN_COMPLEXTYPE_NAME             CONSTANT INTEGER := 110;
        PN_COMPLEXTYPE_SIMPLECONTENT    CONSTANT INTEGER := 26;
        PN_COMPLEXTYPE_COMPLEXCONTENT   CONSTANT INTEGER := 27;
        PN_COMPLEXTYPE_ATTRIBUTE        CONSTANT INTEGER := 28;
        PN_COMPLEXTYPE_ALL              CONSTANT INTEGER := 111;
        PN_COMPLEXTYPE_CHOICE           CONSTANT INTEGER := 112;
        PN_COMPLEXTYPE_SEQUENCE         CONSTANT INTEGER := 113;
        PN_COMPLEXTYPE_ANYATTR          CONSTANT INTEGER := 129;
        PN_COMPLEXTYPE_SQLTYPE          CONSTANT INTEGER := 159;
        PN_COMPLEXTYPE_SQLSCHEMA        CONSTANT INTEGER := 160;
        PN_COMPLEXTYPE_MAINTAINDOM      CONSTANT INTEGER := 161;
        PN_COMPLEXTYPE_SUBTYPEREF       CONSTANT INTEGER := 163;
        PN_COMPLEXTYPE_BASETYPE         CONSTANT INTEGER := 100;
        PN_COMPLEXTYPE_GROUP            CONSTANT INTEGER := 168;
        PN_COMPLEXTYPE_ATTRGROUP        CONSTANT INTEGER := 169;
        PN_COMPLEXTYPE_ID               CONSTANT INTEGER := 204;
  
        PN_COMPLEXTYPE_TYPEID           CONSTANT INTEGER := 272;
    
        PN_APPINFO_SOURCE               CONSTANT INTEGER := 130;
        PN_APPINFO_ANY                  CONSTANT INTEGER := 131;
        PN_DOCUMENTATION_SOURCE         CONSTANT INTEGER := 132;
        PN_DOCUMENTATION_LANG           CONSTANT INTEGER := 133;
        PN_DOCUMENTATION_ANY            CONSTANT INTEGER := 134;
        PN_ANNOTATION_APPINFO           CONSTANT INTEGER := 135;
        PN_ANNOTATION_DOCUMENTATION     CONSTANT INTEGER := 136;
        PN_SCHEMA_ANNOTATION            CONSTANT INTEGER := 137;
        PN_ATTRIBUTE_ANNOTATION         CONSTANT INTEGER := 138;
        PN_SIMPLE_ANNOTATION            CONSTANT INTEGER := 139;
        PN_COMPLEXTYPE_ANNOTATION       CONSTANT INTEGER := 140;

        PN_ELEMENT_DEFAULTXSL           CONSTANT INTEGER := 114;
        PN_ELEMENT_DEFTABLESCHEMA       CONSTANT INTEGER := 147;
        PN_ELEMENT_ISFOLDER             CONSTANT INTEGER := 155;
        PN_ELEMENT_MAINTAINORDER        CONSTANT INTEGER := 156;
        PN_ELEMENT_COLUMNPROPS          CONSTANT INTEGER := 157;
        PN_ELEMENT_DEFAULTACL           CONSTANT INTEGER := 158;
        PN_ELEMENT_HEADELEM_REF         CONSTANT INTEGER := 164;
        PN_ELEMENT_ISTRANSLATABLE       CONSTANT INTEGER := 274;
        PN_ELEMENT_XDBMAXOCCURS         CONSTANT INTEGER := 275;

        PN_ATTRIBUTE_USE                CONSTANT INTEGER := 115;
        PN_ATTRIBUTE_FIXED              CONSTANT INTEGER := 116;
        PN_ATTR_SQLCOLLTYPE             CONSTANT INTEGER := 148;
        PN_ATTR_SQLCOLLSCHEMA           CONSTANT INTEGER := 149;
        PN_ATTR_HIDDEN                  CONSTANT INTEGER := 153;
        PN_ATTR_TRANSIENT               CONSTANT INTEGER := 154;
        PN_ATTR_ID                      CONSTANT INTEGER := 205;
        PN_ATTR_BASEPROP                CONSTANT INTEGER := 211;

        PN_ANYTYPE_MINOCCURS            CONSTANT INTEGER := 141;
        PN_ANYTYPE_MAXOCCURS            CONSTANT INTEGER := 142;
        PN_ANYTYPE_NAMESPACE            CONSTANT INTEGER := 125;
        PN_ANYTYPE_PROCESSCONTENTS      CONSTANT INTEGER := 126;

        PN_INCLUDE_ANNOTATION           CONSTANT INTEGER := 150;        
        PN_INCLUDE_ID                   CONSTANT INTEGER := 207;        
        PN_INCLUDE_SCHEMALOCATION       CONSTANT INTEGER := 151;
        PN_IMPORT_ANNOTATION            CONSTANT INTEGER := 152;
        PN_IMPORT_ID                    CONSTANT INTEGER := 208;

        PN_GROUPDEF_PARENTSCHEMA        CONSTANT INTEGER := 170;
        PN_GROUPDEF_NAME                CONSTANT INTEGER := 171;
        PN_GROUPDEF_ANNOTATION          CONSTANT INTEGER := 172;
        PN_GROUPDEF_ID                  CONSTANT INTEGER := 197;
        PN_GROUPDEF_ALL                 CONSTANT INTEGER := 173;
        PN_GROUPDEF_CHOICE              CONSTANT INTEGER := 174;
        PN_GROUPDEF_SEQUENCE            CONSTANT INTEGER := 175;
      
        PN_GROUPREF_PARENTSCHEMA        CONSTANT INTEGER := 176;
        PN_GROUPREF_MINOCCURS           CONSTANT INTEGER := 177;
        PN_GROUPREF_MAXOCCURS           CONSTANT INTEGER := 178;
        PN_GROUPREF_NAME                CONSTANT INTEGER := 179;
        PN_GROUPREF_REF                 CONSTANT INTEGER := 180;
        PN_GROUPREF_ANNOTATION          CONSTANT INTEGER := 181;
        PN_GROUPREF_ID                  CONSTANT INTEGER := 198;

        PN_ATTRGROUPDEF_PARENTSCHEMA    CONSTANT INTEGER := 182;
        PN_ATTRGROUPDEF_NAME            CONSTANT INTEGER := 183;
        PN_ATTRGROUPDEF_ANNOTATION      CONSTANT INTEGER := 184;
        PN_ATTRGROUPDEF_ID              CONSTANT INTEGER := 199;
        PN_ATTRGROUPDEF_ATTRIBUTE       CONSTANT INTEGER := 185;
        PN_ATTRGROUPDEF_ANYATTR         CONSTANT INTEGER := 186;
        PN_ATTRGROUPDEF_ATTRGROUP       CONSTANT INTEGER := 187;

        PN_ATTRGROUPREF_PARENTSCHEMA    CONSTANT INTEGER := 188;
        PN_ATTRGROUPREF_NAME            CONSTANT INTEGER := 189;
        PN_ATTRGROUPREF_REF             CONSTANT INTEGER := 190;
        PN_ATTRGROUPREF_ANNOTATION      CONSTANT INTEGER := 191;
        PN_ATTRGROUPREF_ID              CONSTANT INTEGER := 200;

        /* simpleContent -> extension */
        PN_SIMPLECONTEXT_BASE           CONSTANT INTEGER := 238;
        PN_SIMPLECONTEXT_ID             CONSTANT INTEGER := 239;
        PN_SIMPLECONTEXT_ANNOTATION     CONSTANT INTEGER := 240;
        PN_SIMPLECONTEXT_ATTRIBUTE      CONSTANT INTEGER := 241;
        PN_SIMPLECONTEXT_ANYATTR        CONSTANT INTEGER := 242;
        PN_SIMPLECONTEXT_ATTRGROUP      CONSTANT INTEGER := 243;
        
        /* simpleContent -> restriction */
        PN_SIMPLECONTRES_BASE           CONSTANT INTEGER := 244;
        PN_SIMPLECONTRES_ID             CONSTANT INTEGER := 245;
        PN_SIMPLECONTRES_ATTRIBUTE      CONSTANT INTEGER := 246;
        PN_SIMPLECONTRES_ANYATTR        CONSTANT INTEGER := 247;
        PN_SIMPLECONTRES_ATTRGROUP      CONSTANT INTEGER := 248;
        PN_SIMPLECONTRES_ANNOTATION     CONSTANT INTEGER := 249;
        PN_SIMPLECONTRES_FRACDIGITS     CONSTANT INTEGER := 250;
        PN_SIMPLECONTRES_TOTALDIGITS    CONSTANT INTEGER := 251;
        PN_SIMPLECONTRES_MINLENGTH      CONSTANT INTEGER := 252;
        PN_SIMPLECONTRES_MAXLENGTH      CONSTANT INTEGER := 253;
        PN_SIMPLECONTRES_WHITESPACE     CONSTANT INTEGER := 254;
        PN_SIMPLECONTRES_PERIOD         CONSTANT INTEGER := 255;
        PN_SIMPLECONTRES_DURATION       CONSTANT INTEGER := 256;
        PN_SIMPLECONTRES_MININCLUSIVE   CONSTANT INTEGER := 257;
        PN_SIMPLECONTRES_MAXINCLUSIVE   CONSTANT INTEGER := 258;
        PN_SIMPLECONTRES_PATTERN        CONSTANT INTEGER := 259;
        PN_SIMPLECONTRES_ENUMERATION    CONSTANT INTEGER := 260;
        PN_SIMPLECONTRES_MINEXCLUSIVE   CONSTANT INTEGER := 261;
        PN_SIMPLECONTRES_MAXEXCLUSIVE   CONSTANT INTEGER := 262;
        PN_SIMPLECONTRES_LENGTH         CONSTANT INTEGER := 263;
        PN_SIMPLECONTRES_SIMPLETYPE     CONSTANT INTEGER := 264;

        /* simpleContent */
        PN_SIMPLECONTENT_ID             CONSTANT INTEGER := 265;
        PN_SIMPLECONTENT_ANNOTATION     CONSTANT INTEGER := 266;
        PN_SIMPLECONTENT_RESTRICTION    CONSTANT INTEGER := 267;
        PN_SIMPLECONTENT_EXTENSION      CONSTANT INTEGER := 268;

        function xdb$enums2facet(vals xdb.xdb$enum_values_t) 
                 return xdb.xdb$facet_list_t;

        function xdb$getNumFacet(val integer) return xdb.xdb$numfacet_t;
        function xdb$getWhitespaceFacet(val xdb.xdb$whitespaceChoice)
          return xdb.xdb$whitespace_t;
        function xdb$getTimeFacet(val date) return xdb.xdb$timefacet_t;
        function xdb$getFacet(val varchar2) return xdb.xdb$facet_t;

        function xdb$insertSimple(
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                final_info      xdb.xdb$derivationChoice,
                derived_by      xdb.xdb$derivationChoice,
                flags           raw,
                precision       integer,
                scale           integer,
                minlength       integer,
                maxlength       integer,
                whitespace      xdb.xdb$whitespaceChoice,
                period          date,
                duration        date,
                minInclusive    varchar2,
                maxInclusive    varchar2,
                pattern         varchar2,
                enumeration     xdb.xdb$enum_values_t
        ) return ref sys.xmltype;

        function xdb$insertSimpleList(
                parent_schema   ref sys.xmltype,
                name            varchar2,
                final_info      xdb.xdb$derivationChoice,
                itemtype        xdb.xdb$qname,
                itemref         ref sys.xmltype) return ref sys.xmltype;

        function xdb$insertSequence (
          parent_schema ref sys.xmltype,
          elements          xdb.xdb$xmltype_ref_list_t,
          anyelems        xdb.xdb$xmltype_ref_list_t := null,
          choice_list     xdb.xdb$xmltype_ref_list_t := null
        ) return ref sys.xmltype;

        function xdb$insertChoice (
          parent_schema ref sys.xmltype,
          elements          xdb.xdb$xmltype_ref_list_t,
          anyelems        xdb.xdb$xmltype_ref_list_t := null,
          maxoccurs       varchar2 := 'unbounded'
        ) return ref sys.xmltype;

        function xdb$insertEmptyComplex return ref sys.xmltype;

        function xdb$insertComplex(
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                abstract        raw,
                derived_by      xdb.xdb$derivationChoice,
                flags           raw,
                precision       integer,
                scale           integer,
                minlength       integer,
                maxlength       integer,
                whitespace      xdb.xdb$whitespaceChoice,
                period          date,
                duration        date,
                min_bound       varchar2,
                max_bound       varchar2,
                pattern         varchar2,
                enumeration     xdb.xdb$enum_values_t,
                dummy         varchar2,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                glob_elements   xdb.xdb$xmltype_ref_list_t,
                local_elements  xdb.xdb$xmltype_ref_list_t,
                attributes      xdb.xdb$xmltype_ref_list_t,
                anyelems        xdb.xdb$xmltype_ref_list_t := null,
                mixed           raw := FALSE,
                model_ref       ref sys.xmltype := null
        ) return ref sys.xmltype;


        procedure xdb$updateComplex(
                complex_ref     ref sys.xmltype,
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                abstract        raw,
                derived_by      xdb.xdb$derivationChoice,
                dummy           varchar2,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                glob_elements   xdb.xdb$xmltype_ref_list_t,
                local_elements  xdb.xdb$xmltype_ref_list_t,
                attributes      xdb.xdb$xmltype_ref_list_t,
                model_ref       ref sys.xmltype := null
        );

        function xdb$insertAttr(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype;


        function xdb$insertElement(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                subs_group      xdb.xdb$qname,
                num_cols        integer,
                nillable        raw,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                abstract        raw,
                mem_inline      raw,
                sql_inline      raw,
                java_inline     raw,
                maintain_dom    raw,
                default_table   varchar2,
                table_storage   varchar2,
                java_classname  varchar2,
                bean_classname  varchar2,
                global          raw,     
                base_sqlname    varchar2,
                cplx_type_decl  ref sys.xmltype,
                subs_group_refs xdb.xdb$xmltype_ref_list_t,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype;

        function xdb$insertAny(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                anynamespace    varchar2,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null
        ) return ref sys.xmltype;

        procedure driver;

end;
/
show errors



create or replace package body xdb.xdb$bootstrap is
  
        function xdb$enums2facet(vals xdb.xdb$enum_values_t) 
                 return xdb.xdb$facet_list_t is 
          facet_list xdb.xdb$facet_list_t := xdb.xdb$facet_list_t();
        begin
          if vals is null then 
            return null;
          end if;
          facet_list.extend(vals.count);
          for i in 1..vals.count loop
              facet_list(i) := xdb.xdb$facet_t(null, null, vals(i), FALSE, null);
          end loop;
          return facet_list;
        end;

        function xdb$getNumFacet(val integer) return xdb.xdb$numfacet_t is
        begin
          if val is null then
            return null;
          else
            return xdb.xdb$numfacet_t(null, null, val, FALSE, null);
          end if;
        end;

        function xdb$getWhitespaceFacet(val xdb.xdb$whitespaceChoice)
           return xdb.xdb$whitespace_t is
        begin
          if val is null then
            return null;
          else
            return xdb.xdb$whitespace_t(null, null, val, FALSE, null);
          end if;
        end;

        function xdb$getTimeFacet(val date) return xdb.xdb$timefacet_t is
        begin
          if val is null then
            return null;
          else
            return xdb.xdb$timefacet_t(null, null, val, FALSE, null);
          end if;
        end;

        function xdb$getFacet(val varchar2) return xdb.xdb$facet_t is
        begin
          if val is null then
            return null;
          else
            return xdb.xdb$facet_t(null, null, val, FALSE, null);
          end if;
        end;

        function xdb$insertSimple(
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                final_info      xdb.xdb$derivationChoice,
                derived_by      xdb.xdb$derivationChoice,
                flags           raw,
                precision       integer,
                scale           integer,
                minlength       integer,
                maxlength       integer,
                whitespace      xdb.xdb$whitespaceChoice,
                period          date,
                duration        date,
                minInclusive    varchar2,
                maxInclusive    varchar2,
                pattern         varchar2,
                enumeration     xdb.xdb$enum_values_t
        ) return ref sys.xmltype is 
                simple_i xdb.xdb$simple_t;
                simple_ref ref sys.xmltype;
        begin
                simple_i := xdb.xdb$simple_t(
                                null,
                                parent_schema,
                                name,
                                null,
                              xdb.xdb$simple_derivation_t(
                                null,
                                base_type,
                                base,
                                null,
                                xdb$getNumFacet(precision),
                                xdb$getNumFacet(scale),
                                xdb$getNumFacet(minlength),
                                xdb$getNumFacet(maxlength),
                                null,
                                xdb$getWhitespaceFacet(whitespace),
                                xdb$getTimeFacet(period),
                                xdb$getTimeFacet(duration),
                                xdb$getFacet(minInclusive),
                                xdb$getFacet(maxInclusive),
                                null,null,
                                null,
                                xdb$enums2facet(enumeration), null, null), 
                                null, null, null, null, 
                                final_info, null, null);

                execute immediate SIMPLE_SQL using simple_i 
                        returning into simple_ref;

                return simple_ref;
        end;

        function xdb$insertSimpleList(
                parent_schema   ref sys.xmltype,
                name            varchar2,
                final_info      xdb.xdb$derivationChoice,
                itemtype        xdb.xdb$qname,
                itemref         ref sys.xmltype) return ref sys.xmltype 
        is 
                simple_i xdb.xdb$simple_t;
                simple_ref ref sys.xmltype;
        begin
                simple_i := xdb.xdb$simple_t(
                                null,
                                parent_schema,
                                name,
                                null,
                                null,
                                xdb.xdb$list_t(null,null,itemtype,itemref,null),
                                null, null, null,
                                final_info, null, null);

                execute immediate SIMPLE_SQL using simple_i 
                        returning into simple_ref;

                return simple_ref;
        end;
  
        function xdb$insertSequence (
          parent_schema ref sys.xmltype,
          elements          xdb.xdb$xmltype_ref_list_t,
          anyelems        xdb.xdb$xmltype_ref_list_t := null,
          choice_list     xdb.xdb$xmltype_ref_list_t := null
        ) return ref sys.xmltype
        is 
          model_i   xdb.xdb$model_t;
          model_ref ref sys.xmltype;
        begin
          if (elements is null and anyelems is null) then
            return null;
          else              
            model_i := xdb.xdb$model_t(null, parent_schema, 1, '1', elements,
                                       choice_list, null,
                                       anyelems, null, null, null);

            execute immediate SEQUENCE_SQL using model_i 
                returning into model_ref;
            return model_ref;
          end if;
        end;  


        function xdb$insertChoice (
          parent_schema ref sys.xmltype,
          elements          xdb.xdb$xmltype_ref_list_t,
          anyelems        xdb.xdb$xmltype_ref_list_t := null,
          maxoccurs       varchar2 := 'unbounded'
        ) return ref sys.xmltype
        is 
          model_i   xdb.xdb$model_t;
          model_ref ref sys.xmltype;
        begin
          if (elements is null and anyelems is null) then
            return null;
          else 
            model_i := xdb.xdb$model_t(null, parent_schema, 0, maxoccurs,
                                       elements, null, null,
                                       anyelems, null, null, null);

            execute immediate CHOICE_SQL using model_i 
                returning into model_ref;
            return model_ref;
          end if;
        end;  


        function xdb$insertEmptyComplex return ref sys.xmltype is
                complex_i xdb.xdb$complex_t;
                complex_ref ref sys.xmltype;
        begin
                complex_i := xdb.xdb$complex_t(null,null,null,null,null,null,null,null,
                                null,null,null,null,null,null, null,null,
                                null,null,null,null,null,null,null,null);

                execute immediate COMPLEX_SQL using complex_i 
                        returning into complex_ref;

                return complex_ref;
        end;

        function xdb$insertComplex(
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                abstract        raw,
                derived_by      xdb.xdb$derivationChoice,
                flags           raw,
                precision       integer,
                scale           integer,
                minlength       integer,
                maxlength       integer,
                whitespace      xdb.xdb$whitespaceChoice,
                period          date,
                duration        date,
                min_bound       varchar2,
                max_bound       varchar2,
                pattern         varchar2,
                enumeration     xdb.xdb$enum_values_t,
                dummy           varchar2,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                glob_elements   xdb.xdb$xmltype_ref_list_t,
                local_elements  xdb.xdb$xmltype_ref_list_t,
                attributes      xdb.xdb$xmltype_ref_list_t,
                anyelems        xdb.xdb$xmltype_ref_list_t := null,
                mixed           raw := FALSE,
                model_ref       ref sys.xmltype := null
        ) return ref sys.xmltype is
                complex_i xdb.xdb$complex_t;
                complex_ref ref sys.xmltype;
                model_r     ref sys.xmltype;
        begin

            if model_ref is null then
              model_r := xdb$insertSequence(parent_schema, local_elements,
                                            anyelems);
            else
              model_r := model_ref;
            end if;

            if base_type is null then 
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,mixed,final_info, block, 
                                attributes,null,null,null,null,model_r,null,
                                null,null,null,null,null,null,null,null,null);
            else
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,mixed,final_info,block,
                                null, null, null, null, null,null,null,
                                xdb.xdb$content_t(null, FALSE, null, 
                                  xdb.xdb$complex_derivation_t(
                                    null, base, attributes, null, null,
                                    null,null,model_r,null,null,null), null,null),
                                null, null,null,FALSE,null,null,null,null);
            end if;          


            execute immediate COMPLEX_SQL using complex_i 
                        returning into complex_ref;

            return complex_ref;
        end;

        procedure xdb$updateComplex(
                complex_ref     ref sys.xmltype,
                parent_schema   ref sys.xmltype,
                base_type       ref sys.xmltype,
                name            varchar2,
                base            xdb.xdb$qname,
                abstract        raw,
                derived_by      xdb.xdb$derivationChoice,
                dummy           varchar2,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                glob_elements   xdb.xdb$xmltype_ref_list_t,
                local_elements  xdb.xdb$xmltype_ref_list_t,
                attributes      xdb.xdb$xmltype_ref_list_t,
                model_ref       ref sys.xmltype := null
        ) is 
                complex_i xdb.xdb$complex_t;
                model_r   ref sys.xmltype;
        begin
            if model_ref is null then
              model_r := xdb$insertSequence(parent_schema, local_elements);
            else
              model_r := model_ref;
            end if;

            if base_type is null then 
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,FALSE,final_info, block, 
                                attributes,null,null,null,null,model_r,null,
                                null,null,null,null,null,null,null,null,null);
            else
               complex_i := xdb.xdb$complex_t(null,parent_schema,base_type,name,
                                abstract,FALSE,final_info,block,
                                null, null, null, null, null,null,null,
                                xdb.xdb$content_t(null,FALSE, null, 
                                  xdb.xdb$complex_derivation_t(
                                    null,base, attributes, null, null,
                                    null,null,model_r,null,null,null), null,null),
                                null, null,null,FALSE,null,null,null,null);
            end if;          

            execute immediate COMPLEX_UPDATE_SQL
               using complex_i, complex_ref;
        end;

        function xdb$insertAttr(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype is 
                attr_i xdb.xdb$property_t;
                attr_ref ref sys.xmltype;
        begin
                attr_i := xdb.xdb$property_t(null,parent_schema,prop_number,name,
                                typename,
                                mem_byte_length,mem_type_code,
                                system,mutable,null,
                                sqlname,sqltype,sqlschema,java_type,    
                                default_value,smpl_type_decl,type_ref,
                                propref_name, propref_ref, 
                                null, null,null,null,sqlcolltype,sqlcollschema,
                                hidden, transient, null, baseprop);

                execute immediate ATTR_SQL using attr_i 
                        returning into attr_ref;

                return attr_ref;
        end;


        function xdb$insertElement(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                subs_group      xdb.xdb$qname,
                num_cols        integer,
                nillable        raw,
                final_info      xdb.xdb$derivationChoice,
                block           xdb.xdb$derivationChoice,
                abstract        raw,
                mem_inline      raw,
                sql_inline      raw,
                java_inline     raw,
                maintain_dom    raw,
                default_table   varchar2,
                table_storage   varchar2,
                java_classname  varchar2,
                bean_classname  varchar2,
                global          raw,     
                base_sqlname    varchar2,
                cplx_type_decl  ref sys.xmltype,
                subs_group_refs xdb.xdb$xmltype_ref_list_t,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null,
                hidden          raw := null,
                transient       xdb.xdb$transientChoice := null,
                baseprop        raw := null
        ) return ref sys.xmltype is 
                elem_i xdb.xdb$element_t;
                elem_ref ref sys.xmltype;
        begin
                elem_i := xdb.xdb$element_t(
                                xdb.xdb$property_t(null,parent_schema,prop_number,
                                  name,typename,
                                  mem_byte_length,mem_type_code,system,
                                  mutable,null,
                                  sqlname,sqltype,sqlschema,java_type,  
                                  default_value,smpl_type_decl,type_ref,
                                  propref_name,propref_ref, 
                                  null, null, global,null,
                                  sqlcolltype, sqlcollschema,
                                  hidden, transient, null, baseprop),
                                subs_group,num_cols,nillable,
                                final_info,block,abstract,
                                mem_inline,sql_inline,java_inline,
                                maintain_dom,default_table,'XDB',
                                table_storage,java_classname,bean_classname,
                                base_sqlname,cplx_type_decl,
                                subs_group_refs, null, 
                                min_occurs,to_char(max_occurs),
                                null,null,null,null,null,null,null,null,null,null);

                execute immediate ELEM_SQL using elem_i 
                        returning into elem_ref;

                return elem_ref;
        end;

        function xdb$insertAny(
                parent_schema   ref sys.xmltype,
                prop_number     integer,
                name            varchar2,
                typename        xdb.xdb$qname,
                anynamespace    varchar2,
                min_occurs      integer,
                max_occurs      integer,
                mem_byte_length raw,
                mem_type_code   raw,
                system          raw,
                mutable         raw,
                fixed           raw,
                sqlname         varchar2,
                sqltype         varchar2, 
                sqlschema       varchar2,                                    
                java_type       xdb.xdb$javatype,
                default_value   varchar2,
                smpl_type_decl  ref sys.xmltype,
                type_ref        ref sys.xmltype,
                propref_name    xdb.xdb$qname,
                propref_ref     ref sys.xmltype,
                sqlcolltype     varchar2 := null,
                sqlcollschema   varchar2 := null                
        ) return ref sys.xmltype is 
                any_i xdb.xdb$any_t;
                any_ref ref sys.xmltype;
        begin
                any_i := xdb.xdb$any_t(
                             xdb.xdb$property_t(null,parent_schema,prop_number,
                                name,typename,
                                mem_byte_length,mem_type_code,
                                system,mutable,null,
                                sqlname,sqltype,sqlschema,java_type,    
                                default_value,smpl_type_decl,type_ref,
                                propref_name,propref_ref, 
                                null, null, null, null,
                                sqlcolltype,sqlcollschema,
                                null, null, null, null),
                             anynamespace, null,min_occurs,to_char(max_occurs));

                execute immediate ANY_SQL using any_i 
                        returning into any_ref;

                return any_ref;
        end;


procedure driver is
        ellist          xdb.xdb$xmltype_ref_list_t;
        ellist2        xdb.xdb$xmltype_ref_list_t;
        simplelist      xdb.xdb$xmltype_ref_list_t;
        complexlist     xdb.xdb$xmltype_ref_list_t;
        schels          xdb.xdb$xmltype_ref_list_t;
        attlist         xdb.xdb$xmltype_ref_list_t;
        attlist2        xdb.xdb$xmltype_ref_list_t;
        anylist         xdb.xdb$xmltype_ref_list_t;
        choice_list     xdb.xdb$xmltype_ref_list_t;
        schref          ref sys.xmltype;
        ctyperef        ref sys.xmltype;                
        styperef        ref sys.xmltype;                
        list_t_ref      ref sys.xmltype;                
        union_t_ref     ref sys.xmltype;                
        simplederv_t_ref    ref sys.xmltype;            
        simple_t_ref    ref sys.xmltype;                
        attr_t_ref      ref sys.xmltype;                
        complex_t_ref   ref sys.xmltype;                
        model_t_ref     ref sys.xmltype;                
        complexderv_t_ref   ref sys.xmltype;            
        content_t_ref       ref sys.xmltype;            
        any_t_ref           ref sys.xmltype;            
        appinfo_t_ref       ref sys.xmltype;            
        documentation_t_ref ref sys.xmltype;            
        annotation_t_ref    ref sys.xmltype;            
        notation_t_ref       ref sys.xmltype;           
        xpathspec_t_ref       ref sys.xmltype;          
        keybase_t_ref       ref sys.xmltype;            
        groupdef_t_ref      ref sys.xmltype;
        groupref_t_ref      ref sys.xmltype;
        attrgroupdef_t_ref  ref sys.xmltype;
        attrgroupref_t_ref  ref sys.xmltype;
        simplecontExt_t_ref ref sys.xmltype;
        simplecontRes_t_ref ref sys.xmltype;
        smplcont_t_ref      ref sys.xmltype;
        drv_choice_ref  ref sys.xmltype;                
        form_choice_ref ref sys.xmltype;                
        content_ref     ref sys.xmltype;                
        javatype_ref    ref sys.xmltype;                
        whitespace_ref  ref sys.xmltype;                
        use_choice_ref  ref sys.xmltype;                
        process_choice_ref  ref sys.xmltype;            
        transient_choice_ref  ref sys.xmltype;
        facet_ref       ref sys.xmltype;                
        num_facet_ref   ref sys.xmltype;                
        time_facet_ref  ref sys.xmltype;                
        schel_ref       ref sys.xmltype;                
        simple_i        xdb.xdb$simple_t;
        complex_i       xdb.xdb$complex_t;
        elem_i          xdb.xdb$element_t;
        attr_i          xdb.xdb$property_t;
        schema_i        xdb.xdb$schema_t;
        extras_i        sys.xmltypeextra;
        seq_ref         ref sys.xmltype;        
        
        element_propnum integer;
        attr_propnum    integer;
        stype_propnum   integer;
        ctype_propnum   integer;
        colcount        integer;
        attr_colcount   integer;
        elem_colcount   integer;
        any_colcount    integer;
        appinfo_colcount    integer;
        documentation_colcount    integer;
        annotation_colcount   integer;
        notation_colcount    integer;
        xpathspec_colcount    integer;
        keybase_colcount    integer;
        groupdef_colcount     integer;
        groupref_colcount     integer;
        attrgroupdef_colcount integer;
        attrgroupref_colcount integer;
        simple_colcount integer;
        complex_colcount integer;
        model_colcount  integer;
        list_colcount   integer;
        union_colcount   integer;
        simpleder_colcount integer;
        complexder_colcount integer;
        content_colcount integer;
        simplecontRes_colcount integer;
        simplecontExt_colcount integer;
        smplcont_colcount integer;
        st              xdb.xdb$simple_t;
BEGIN
        schema_i := xdb.xdb$schema_t('http://xmlns.oracle.com/xdb/XDBSchema.xsd', 
              'http://www.w3.org/2001/XMLSchema', 
              '1.0', 0, null, TD_ALL, FC_QUAL, null, null, null, null, null,
              null, null, '17', null, null,FALSE,FALSE,
              null,null,null,FALSE,'XDB',null,null);

        extras_i := 
         sys.xmltypeextra( 
            sys.xmltypepi( 
               xdb.xdb$getpickledns(
                    'http://www.w3.org/2001/XMLSchema', 
                    null), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb', 
                    'xdb'), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb/XDBResource.xsd', 
                    'xdbres') 
              ), 
            null);

        execute immediate 'insert into xdb.xdb$schema s 
                (sys_nc_oid$, xmlextra, xmldata) values (:1, :2, :3) 
                returning ref(s) into :4' 
                using '6C3FCF2D9D354DC1E03408002087A0B7', extras_i, schema_i
                returning into schref;

        simplelist := xdb.xdb$xmltype_ref_list_t();
        simplelist.extend(7);

        complexlist := xdb.xdb$xmltype_ref_list_t();
        complexlist.extend(29);

        select attributes into simple_colcount from all_types
                where type_name in ('XDB$SIMPLE_T') and owner = 'XDB';

        select sum(attributes) - 1 into elem_colcount from all_types
                where type_name in ('XDB$ELEMENT_T', 'XDB$PROPERTY_T')
                and owner = 'XDB';

        select attributes into attr_colcount from all_types
                where type_name in ('XDB$PROPERTY_T') and owner = 'XDB';

        select attributes into complex_colcount from all_types
                where type_name in ('XDB$COMPLEX_T') and owner = 'XDB';

        select attributes into model_colcount from all_types
                where type_name in ('XDB$MODEL_T') and owner = 'XDB';

        select attributes into list_colcount from all_types
                where type_name in ('XDB$LIST_T') and owner = 'XDB';

        select attributes into union_colcount from all_types
                where type_name in ('XDB$UNION_T') and owner = 'XDB';

        select attributes into simpleder_colcount from all_types
                where type_name in ('XDB$SIMPLE_DERIVATION_T') and owner = 'XDB';

        select attributes into complexder_colcount from all_types
                where type_name in ('XDB$COMPLEX_DERIVATION_T') and owner = 'XDB';

        select attributes into content_colcount from all_types
                where type_name in ('XDB$CONTENT_T') and owner = 'XDB';

        select attributes into simplecontRes_colcount from all_types
                where type_name in ('XDB$SIMPLECONT_RES_T') and owner = 'XDB';

        select attributes into simplecontExt_colcount from all_types
                where type_name in ('XDB$SIMPLECONT_EXT_T') and owner = 'XDB';

        select attributes into smplcont_colcount from all_types
                where type_name in ('XDB$SIMPLECONTENT_T') and owner = 'XDB';

        select sum(attributes) - 1 into any_colcount from all_types
                where type_name in ('XDB$ANY_T', 'XDB$PROPERTY_T') and owner = 'XDB';

        select attributes into appinfo_colcount from all_types
                where type_name in ('XDB$APPINFO_T') and owner = 'XDB';

        select attributes into documentation_colcount from all_types
                where type_name in ('XDB$DOCUMENTATION_T') and owner = 'XDB';

        select attributes into annotation_colcount from all_types
                where type_name in ('XDB$ANNOTATION_T') and owner = 'XDB';

        select attributes into notation_colcount from all_types
                where type_name in ('XDB$NOTATION_T') and owner = 'XDB';

        select attributes into xpathspec_colcount from all_types
                where type_name in ('XDB$XPATHSPEC_T') and owner = 'XDB';

        select attributes into keybase_colcount from all_types
                where type_name in ('XDB$KEYBASE_T') and owner = 'XDB';

        select attributes into groupdef_colcount from all_types
                where type_name in ('XDB$GROUP_DEF_T') and owner = 'XDB';

        select attributes into groupref_colcount from all_types
                where type_name in ('XDB$GROUP_REF_T') and owner = 'XDB';

        select attributes into attrgroupdef_colcount from all_types
                where type_name in ('XDB$ATTRGROUP_DEF_T') and owner = 'XDB';

        select attributes into attrgroupref_colcount from all_types
                where type_name in ('XDB$ATTRGROUP_REF_T') and owner = 'XDB';

/*--------------------------------------------------------------------------*/
/* Forward declarations (of some complex types) */
/*--------------------------------------------------------------------------*/

        /* Forward decl for "simpleType" */
        simple_t_ref := xdb$insertEmptyComplex();

        /* Forward decl for "anyType" */
        any_t_ref := xdb$insertEmptyComplex();


/*--------------------------------------------------------------------------*/
/* Simple type definition for "derivationChoice" */
/*--------------------------------------------------------------------------*/
        drv_choice_ref := xdb$insertSimple(schref, null, 'derivationChoice',
               TR_STRING, null, TD_LIST, '0',null, null, null, null, null, 
               null, null, null, null, null, 
               xdb.xdb$enum_values_t('','extension', 'restriction', 'list', 
                                      '#all', 'substitution', 'union'));

        simplelist(1) := drv_choice_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "formChoice" */
/*--------------------------------------------------------------------------*/
        form_choice_ref := xdb$insertSimple(schref, null, 'formChoice', TR_STRING,
               null, TD_RESTRICTION, '0',null, null, null, null, null, 
               null, null, null, null, null, 
               xdb.xdb$enum_values_t('unqualified', 'qualified'));
        simplelist(2) := form_choice_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "content" */
/*--------------------------------------------------------------------------*/
        content_ref := xdb$insertSimple(schref, null, 'content', TR_STRING,
               null, TD_RESTRICTION, '0', null, null, null, null, null, null, 
               null, null, null, null, 
               xdb.xdb$enum_values_t('elementOnly','textOnly','mixed','empty'));

        simplelist(3) := content_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "javatype" */
/*--------------------------------------------------------------------------*/
        javatype_ref := xdb$insertSimple(schref, null, 'javatype', TR_STRING,
               null, TD_RESTRICTION, '0',null, null, null, null, null, null, 
               null, null, null, null, 
               xdb.xdb$enum_values_t('String','int','long','short','byte','float',
                                 'double','BigDecimal','boolean','byteArray',
                                 'Stream','CharStream','TimeStamp',
                                 'Reference','QNAme','Enum','XMLType'));

        simplelist(4) := javatype_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "useChoice" */
/*--------------------------------------------------------------------------*/
        use_choice_ref := xdb$insertSimple(schref, null, 'useChoice',
                                           TR_STRING,
               null, TD_LIST, '0',null, null, null, null, null, null, null, 
               null, null, null, 
               xdb.xdb$enum_values_t('optional','required','prohibited'));

        simplelist(5) := use_choice_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "processChoice" */
/*--------------------------------------------------------------------------*/
        process_choice_ref := xdb$insertSimple(schref, null, 'processChoice',
                                           TR_STRING,
               null, TD_LIST, '0',null, null, null, null, null, null, null, 
               null, null, null, 
               xdb.xdb$enum_values_t('skip','lax','strict'));

        simplelist(6) := process_choice_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "transientChoice" */
/*--------------------------------------------------------------------------*/
        transient_choice_ref := xdb$insertSimple(schref, null, 
                                      'transientChoice', TR_STRING,
               null, TD_LIST, '0',null, null, null, null, null, null, null, 
               null, null, null, 
               xdb.xdb$enum_values_t('','generated','manifested'));

        simplelist(7) := transient_choice_ref;

/*--------------------------------------------------------------------------*/
/* Complex type definition for "annotation", and its related */
/* "appInfo", "documentation"                                */
/*--------------------------------------------------------------------------*/

        /* appInfo complextype */
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(1);

        attlist(1) := xdb$insertAttr(schref, PN_APPINFO_SOURCE,
                                     'source', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'SOURCE', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

        anylist := xdb.xdb$xmltype_ref_list_t();
        anylist.extend(1);

        anylist(1) := xdb$insertAny(schref, PN_APPINFO_ANY, null, 
                                    null, null, 0, 1000, null, 
                                    T_XOB , FALSE, FALSE, FALSE, 
                                    'ANYPART', 'VARCHAR2', null, 
                                    JT_XMLTYPE, null, null, null, null, null);

        appinfo_t_ref := xdb$insertComplex(schref, null, 'appinfo', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, attlist,
                          anylist, TRUE);
        complexlist(16) := appinfo_t_ref;

        /* documentation complextype */
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_DOCUMENTATION_SOURCE,
                                     'source', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'SOURCE', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_DOCUMENTATION_LANG,
                                     'lang', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'LANG', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

        anylist := xdb.xdb$xmltype_ref_list_t();
        anylist.extend(1);

        anylist(1) := xdb$insertAny(schref, PN_DOCUMENTATION_ANY, null, 
                                    null, null, 0, 1000, null, 
                                    T_XOB, FALSE, FALSE, FALSE, 
                                    'ANYPART', 'VARCHAR2', null, 
                                    JT_XMLTYPE, null, null, null, null, null);

        documentation_t_ref := xdb$insertComplex(schref, null,'documentation', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, attlist,
                          anylist, TRUE);
        complexlist(17) := documentation_t_ref;

        /* annotation complextype */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(2);

        ellist(1) := xdb$insertElement(schref, PN_ANNOTATION_APPINFO,
                                       'appinfo',
                                       xdb.xdb$qname('01', 'appinfo'), 
                                       0, 1000, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'APPINFO',
                                       'XDB$APPINFO_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, appinfo_t_ref,null,null,
                                       null, appinfo_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.appinfoBean', 
                                       'oracle.xdb.appinfoBean',
                                       FALSE, null, null, null,
                                       'XDB$APPINFO_LIST_T', 'XDB');

        ellist(2) := xdb$insertElement(schref, PN_ANNOTATION_DOCUMENTATION,
                                       'documentation',
                                       xdb.xdb$qname('01', 'documentation'), 
                                       0, 1000, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'DOCUMENTATION',
                                       'XDB$DOCUMENTATION_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, documentation_t_ref,
                                       null,null,
                                       null, documentation_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.documentationBean', 
                                       'oracle.xdb.documentationBean',
                                       FALSE, null, null, null,
                                       'XDB$DOCUMENTATION_LIST_T','XDB');

        annotation_t_ref := xdb$insertComplex(schref, null,'annotation', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, null);
        complexlist(18) := annotation_t_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "notation" */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_NOTATION_NAME, 'name', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_NOTATION_PUBLIC, 'public', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'PUBLICVAL', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_NOTATION_SYSTEM, 'system', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'SYSTEM', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref, PN_NOTATION_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        notation_t_ref := xdb$insertComplex(schref, null,'notation', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist);
        complexlist(24) := notation_t_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "xpathspec", "keybase" */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(1);

        attlist(1) := xdb$insertAttr(schref, PN_XPATHSPEC_XPATH, 'xpath', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'XPATH', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref, PN_XPATHSPEC_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        xpathspec_t_ref := xdb$insertComplex(schref, null,'xpathspec', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist);
        complexlist(25) := xpathspec_t_ref;


        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_KEYBASE_NAME, 'name', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_KEYBASE_REFER, 'refer', 
                                   xdb.xdb$qname('00', 'QName'), 0, 1, null, 
                               T_QNAME, FALSE, FALSE, FALSE, 'REFER', 
                               'XDB$QNAME', 'XDB', JT_QNAME, null, null, 
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);
        ellist(1) := xdb$insertElement(schref, PN_KEYBASE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_KEYBASE_SELECTOR,
                                       'selector',
                                     xdb.xdb$qname('01', 'xpathspec'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'SELECTOR',
                                       'XDB$XPATHSPEC_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, xpathspec_t_ref,null,null,
                                       null, xpathspec_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null, null, null, 
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_KEYBASE_FIELD,
                                       'field',
                                     xdb.xdb$qname('01', 'xpathspec'), 
                                       0, 1000, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'FIELDS',
                                       'XDB$XPATHSPEC_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, xpathspec_t_ref,null,null,
                                       null, xpathspec_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null, null, null, 
                                       FALSE, null, null, null,
                                       'XDB$XPATHSPEC_LIST_T','XDB');

        keybase_t_ref := xdb$insertComplex(schref, null,'keybase', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist);
        complexlist(26) := keybase_t_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "facet" (strings only) */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);

        attlist(1) := xdb$insertAttr(schref, 0, 'value', TR_STRING,
                               1, 1, null, T_CSTRING, FALSE, FALSE, FALSE, 
                               'VALUE', 'VARCHAR2', null, JT_STRING, null,
                               null,null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_FACET_FIXED, 'fixed', TR_BOOLEAN,
                               0, 1, null, T_BOOLEAN, FALSE, FALSE, FALSE, 
                               'FIXED', 'RAW', null, JT_BOOLEAN, 'false',
                               null,null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_FACET_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_FACET_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        facet_ref := xdb$insertComplex(schref, null, 'facet', 
                        null, FALSE, null, '0', null, null,
                        null, null, null, null, null, null, null, null, null,
                        null, null, null, null, ellist, attlist);
        complexlist(1) := facet_ref;    

/*--------------------------------------------------------------------------*/
/* Complex type definition for "numFacet" */
/*--------------------------------------------------------------------------*/
        
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);
        attlist(1) := xdb$insertAttr(schref, 1, 'value', TR_NNEGINT,
                               1, 1, '02', T_INTEGER, FALSE, FALSE, FALSE, 
                               'VALUE', 'NUMBER', null, JT_INT, null, null, 
                               null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_NUMFACET_FIXED, 'fixed', TR_BOOLEAN,
                               0, 1, null, T_BOOLEAN, FALSE, FALSE, FALSE, 
                               'FIXED', 'RAW', null, JT_BOOLEAN, 'false',
                               null,null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_NUMFACET_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);                       

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_NUMFACET_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        num_facet_ref := xdb$insertComplex(schref, null, 'numFacet', 
                        null, FALSE, null, '0', null, null, 
                        null, null, null, null, null, null, null, null, null,
                        null, null, null, null, ellist, attlist);
        complexlist(2) := num_facet_ref;        

/*--------------------------------------------------------------------------*/
/* Complex type definition for "timeFacet" */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);
        attlist(1) := xdb$insertAttr(schref, 2, 'value', 
                               xdb.xdb$qname('00', 'dateTime'),
                               1, 1, null, T_DATE, FALSE, FALSE, FALSE, 
                               'VALUE', 'DATE', null, JT_TIMESTAMP, null, 
                               null,null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_TIMEFACET_FIXED, 'fixed', TR_BOOLEAN,
                               0, 1, null, T_BOOLEAN, FALSE, FALSE, FALSE, 
                               'FIXED', 'RAW', null, JT_BOOLEAN, 'false',
                               null,null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_TIMEFACET_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_TIMEFACET_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        time_facet_ref := xdb$insertComplex(schref, null, 'timeFacet', 
                        null, FALSE, null, '0',
                        null, null, null, null, null, null, null, null, null,
                        null, null,
                        null, null, null, null, ellist, attlist);
        complexlist(3) := time_facet_ref;       

/*--------------------------------------------------------------------------*/
/* Anonymous type for "whitespace"--derived from facet */
/*--------------------------------------------------------------------------*/

        /* Anonymous type for "value" attribute for enumeration */

        styperef := xdb$insertSimple(schref, null,null,xdb.xdb$qname('00', 'NMTOKEN'), 
               null, TD_RESTRICTION, '0', null, null, null, null, null, null, 
               null, null, null, null, xdb.xdb$enum_values_t('preserve','replace','collapse'));

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);
        attlist(1) := xdb$insertAttr(schref, 3, 'value', null, 1, 1, null, 
                               T_ENUM, FALSE, FALSE, FALSE, 'VALUE', 
                               'XDB$WHITESPACECHOICE', 'XDB', JT_ENUM, 
                               null, styperef, styperef,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_WHITESPACE_FIXED, 'fixed', TR_BOOLEAN,
                               0, 1, null, T_BOOLEAN, FALSE, FALSE, FALSE, 
                               'FIXED', 'RAW', null, JT_BOOLEAN, 'false',
                               null,null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_WHITESPACE_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_WHITESPACE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        whitespace_ref := xdb$insertComplex(schref, null, 'whiteSpace', 
                                null, FALSE, null, '0',
                        null, null, null, null, null, null, null, null, null,
                        null, null,
                        null, null, null, null, ellist, attlist);
        complexlist(4) := whitespace_ref;

        /* VARRAY tracking top-level schema elements */
        schels := xdb.xdb$xmltype_ref_list_t();
        schels.extend(14);

/*--------------------------------------------------------------------------*/
/* Definition of "annotation" global element */
/*--------------------------------------------------------------------------*/

        schels(1) := xdb$insertElement(schref, PN_SCHEMA_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATIONS', 'XDB$ANNOTATION_T', 'XDB',       
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null,
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null,
                        'XDB$ANNOTATION_LIST_T','XDB');
                                       

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:listType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_LIST_ITEMTYPE, 'itemType', 
                                   xdb.xdb$qname('00', 'QName'), 0, 1, null, 
                               T_QNAME, FALSE, FALSE, FALSE, 'ITEM_TYPE', 
                               'XDB$QNAME', 'XDB', JT_QNAME, null, null, 
                               null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_LIST_TYPEREF, 'typeRef', 
                               xdb.xdb$qname('00', 'REF'), 0, 1,null,
                               T_REF, TRUE, FALSE, FALSE, 'TYPE_REF', 
                               'REF', null, JT_REFERENCE, null, null, null,
                               null,null,null,null,'01');

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(2);

        ellist(1) := xdb$insertElement(schref, PN_LIST_SIMPLETYPE, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'SIMPLE_TYPE',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_LIST_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        list_t_ref := xdb$insertComplex(schref, null, 
                                'listType', 
                                null, FALSE, null, '0',
                       null, null, null, null, null, null, null, null, null,
                       null, null,
               null, null, null, null, ellist, attlist);
        complexlist(13) := list_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:unionType" complex type */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(1);

        attlist(1) := xdb$insertAttr(schref, PN_UNION_MEMBERTYPES, 
                        'memberTypes', xdb.xdb$qname('00', 'QNames'), 
                        0, 1, null, T_CSTRING, FALSE, FALSE, FALSE, 
                        'MEMBER_TYPES', 'VARCHAR2', null, 
                        JT_QNAME, null, null, 
                        null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        ellist(1) := xdb$insertElement(schref, PN_UNION_SIMPLETYPE, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1000, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'SIMPLE_TYPES',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null,
                 'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(2) := xdb$insertElement(schref, PN_UNION_TYPEREF, 
                         'typeRef', xdb.xdb$qname('00', 'REF'), 0, 1000,null,
                         T_REF, TRUE, FALSE, FALSE, 'TYPE_REFS', 
                         'REF', null, JT_REFERENCE, null, null, null,null,null,
                 null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE,
                 null, null, null, null, FALSE, null, null, null,
                 'XDB$XMLTYPE_REF_LIST_T','XDB', '01');

        ellist(3) := xdb$insertElement(schref, PN_UNION_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        union_t_ref := xdb$insertComplex(schref, null, 'unionType', 
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist);
        complexlist(14) := union_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:simpleDerivationType" XML element */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_SIMPLE_BASETYPE, 'baseType', 
                               xdb.xdb$qname('00', 'REF'), 0, 1,null,
                               T_REF, TRUE, FALSE, FALSE, 'BASE_TYPE', 
                               'REF', null, JT_REFERENCE, null, null, null,
                               null,null,null,null,'01');

        attlist(2) := xdb$insertAttr(schref, PN_SIMPLE_BASE, 'base', 
                                   xdb.xdb$qname('00', 'QName'), 0, 1, null, 
                               T_QNAME, FALSE, FALSE, FALSE, 'BASE', 
                               'XDB$QNAME', 'XDB', JT_QNAME, null, null, 
                               null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_SIMPLEDER_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(16);

        ellist(1) := xdb$insertElement(schref, PN_SIMPLEDER_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_SIMPLE_PRECISION, 
                        'fractionDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                        T_XOB, FALSE, FALSE, FALSE, 'FRACTIONDIGITS', 
                        'XDB$NUMFACET_T', 'XDB', JT_SHORT, null, null, 
                        num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_SIMPLE_SCALE, 'totalDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'TOTALDIGITS', 'XDB$NUMFACET_T', 'XDB', JT_SHORT, null,null, 
                        num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref,PN_SIMPLE_MINLENGTH, 
                                'minLength', 
                              xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                              T_XOB, FALSE, FALSE, FALSE, 'MINLENGTH', 
                              'XDB$NUMFACET_T', 'XDB', JT_INT, null, null, 
                              num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null) ;

        ellist(5) := xdb$insertElement(schref, PN_SIMPLE_MAXLENGTH,
                              'maxLength', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'MAXLENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(6) := xdb$insertElement(schref, PN_SIMPLE_WHITESPACE, 'whiteSpace', 
                        xdb.xdb$qname('01', 'whiteSpace'), 0, 1, '1', 
                         T_XOB, FALSE, FALSE, FALSE, 'WHITESPACE', 
                        'XDB$WHITESPACE_T', 'XDB', JT_ENUM, null, null, 
                        whitespace_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(7) := xdb$insertElement(schref, PN_SIMPLE_PERIOD, 'period', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'PERIOD', 
                        'XDB$TIMEFACET_T', 'XDB', JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(8) := xdb$insertElement(schref, PN_SIMPLE_DURATION,'duration', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'DURATION', 
                        'XDB$TIMEFACET_T','XDB',JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(9) := xdb$insertElement(schref, PN_SIMPLE_MININCLUSIVE, 
                                'minInclusive', 
                                xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_INCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(10) := xdb$insertElement(schref, PN_SIMPLE_MAXINCLUSIVE,
                                               'maxInclusive', 
                                        xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_INCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(11) := xdb$insertElement(schref, PN_SIMPLE_PATTERN, 'pattern', 
                                xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 'PATTERN', 
                        'XDB$FACET_T', 'XDB', JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');


        ellist(12) := xdb$insertElement(schref, PN_SIMPLE_ENUMERATION,
                                'enumeration', xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ENUMERATION', 'XDB$FACET_T', 'XDB',
                        JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');

        ellist(13) := xdb$insertElement(schref, PN_SIMPLE_MINEXCLUSIVE, 
                            'minExclusive', xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_EXCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(14) := xdb$insertElement(schref, PN_SIMPLE_MAXEXCLUSIVE,
                                'maxExclusive', xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_EXCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(15) := xdb$insertElement(schref, PN_SIMPLE_LENGTH,
                              'length', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'LENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(16) := xdb$insertElement(schref, PN_SIMPLEDER_SIMPLETYPE, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'LCL_SMPL_DECL',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null);

        simplederv_t_ref := xdb$insertComplex(schref, null, 
                                'simpleDerivationType', 
                                null, FALSE, null, '0',
                       null, null, null, null, null, null, null, null, null,
                       null, null,
               null, null, null, null, ellist, attlist);
        complexlist(12) := simplederv_t_ref;


/*--------------------------------------------------------------------------*/
/* Definition of "xdb:simpleType" XML element */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(7);

        attlist(1) := xdb$insertAttr(schref, PN_SIMPLE_PARENTSCHEMA, 
                               'parent_schema', 
                               xdb.xdb$qname('00', 'REF'), 0, 1,null,
                               T_REF, TRUE, FALSE, FALSE, 'PARENT_SCHEMA', 
                               'REF', null, JT_REFERENCE, null, null, 
                               null,null,null,null,null,'01');
        attlist(2) := xdb$insertAttr(schref, PN_SIMPLE_NAME, 'name', 
                                TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);
        attlist(3) := xdb$insertAttr(schref, PN_SIMPLE_ABSTRACT, 'abstract', 
                                TR_BOOLEAN, 0, 1,null, 
                               T_BOOLEAN, FALSE, FALSE, FALSE, 'ABSTRACT',
                               'RAW', null, JT_BOOLEAN, 'false', null, 
                               null,null,null);
        attlist(4) := xdb$insertAttr(schref, PN_SIMPLE_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);
        attlist(5) := xdb$insertAttr(schref, PN_SIMPLE_FINAL, 'final', 
                               xdb.xdb$qname('01', 'derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'FINAL_INFO',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM,
                               null, null, drv_choice_ref,null,null);
        attlist(6) := xdb$insertAttr(schref, PN_SIMPLE_TYPEID, 'typeID', 
                               TR_INT, 0, 1, null, 
                               T_UNSIGNINT, TRUE, FALSE, FALSE, 'TYPEID',
                               'NUMBER', null, JT_INT, null, null, null,null,
                               null);

        attlist(7) := xdb$insertAttr(schref, PN_SIMPLE_SQLTYPE, 
                               'SQLType', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLTYPE', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(4);

        ellist(1) := xdb$insertElement(schref, PN_SIMPLE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_SIMPLE_RESTRICTION,
                                       'restriction',
                                     xdb.xdb$qname('01', 'simpleDerivationType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'RESTRICTION',
                                       'XDB$SIMPLE_DERIVATION_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, simplederv_t_ref,null,null,
                                       null, simpleder_colcount, 
                                       FALSE, null, null, FALSE, TRUE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleDerivation', 
                                       'oracle.xdb.simpleDerivationBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_SIMPLE_LIST,
                                       'list',
                                     xdb.xdb$qname('01', 'listType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'LIST_TYPE',
                                       'XDB$LIST_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, list_t_ref,null,null,
                                       null, list_colcount, 
                                       FALSE, null, null, FALSE, TRUE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.listBean', 
                                       'oracle.xdb.listBean',
                                       FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref, PN_SIMPLE_UNION,
                                       'union',
                                     xdb.xdb$qname('01', 'unionType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'UNION_TYPE',
                                       'XDB$UNION_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, union_t_ref,null,null,
                                       null, union_colcount, 
                                       FALSE, null, null, FALSE, TRUE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.unionBean', 
                                       'oracle.xdb.unionBean',
                                       FALSE, null, null, null);

        xdb$updateComplex(simple_t_ref, schref, null, 'simpleType', 
                                null, FALSE, null, null,
                                null, null, null, 
                                ellist, attlist);
        complexlist(5) := simple_t_ref;


        stype_propnum := 22;
        schels(2) := xdb$insertElement(schref, stype_propnum, 
                                'simpleType', 
                         xdb.xdb$qname('01', 'simpleType'), 0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'SIMPLE_TYPE',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null,
                         simple_t_ref,null,null, 
                xdb.xdb$qname('01', 'schemaTop'), simple_colcount, FALSE, null, null, 
                FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', TRUE, null, null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

/*--------------------------------------------------------------------------*/
/* Forward definitions of "xdb:groupRefType" and "xdb:attrGroupRefType" */
/*--------------------------------------------------------------------------*/
        groupref_t_ref := xdb$insertEmptyComplex();
        attrgroupref_t_ref := xdb$insertEmptyComplex();

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:modelType" XML element */
/*
 *   modelType :=                    -- annotation (0..1)
 *                                  |
 *                    sequence  ----
 *                     (1..1)       |
 *                                   -- choice (0..unb)
 *                                         -- all       (0..1)
 *                                         -- choice    (0..1)
 *                                         -- sequence  (0..1)
 *                                         -- any       (0..1)
 *                                         -- group     (0..1)
 */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(4);

        /* Forward definition of modelType */
        model_t_ref := xdb$insertEmptyComplex();

        attlist(1) := xdb$insertAttr(schref, PN_MODEL_PARENTSCHEMA,
                                     'parentSchema', 
                                     xdb.xdb$qname('00','REF'), 0, 1,
                                     null, T_REF, TRUE, FALSE, FALSE, 
                                     'PARENT_SCHEMA', 'REF', null,
                                     JT_REFERENCE, 
                                     null, null, null,null,null,
                                     null,null,'01');
        attlist(2) := xdb$insertAttr(schref, PN_MODEL_MINOCCURS,
                                     'minOccurs', TR_INT, 0, 1, null, 
                                     T_INTEGER, FALSE, FALSE, FALSE,
                                     'MIN_OCCURS', 'NUMBER', null,
                                     JT_INT, '0', null, null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_MODEL_MAXOCCURS,
                                     'maxOccurs', TR_STRING, 0, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'MAX_OCCURS', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

        attlist(4) := xdb$insertAttr(schref, PN_MODEL_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(5);

        ellist(1) := xdb$insertElement(schref, PN_MODEL_ELEMENT, 
                         'element', xdb.xdb$qname('01', 'element'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'ELEMENTS',
                         'XDB$ELEMENT_T', 'XDB', JT_XMLTYPE,
                                       null, null, null,null,null,
                                       null, elem_colcount,
                 FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$ELEMENT', null, 'oracle.xdb.Element', 
                'oracle.xdb.ElementBean', FALSE, 'PROPERTY', null, null,
                'XDB$XMLTYPE_REF_LIST_T','XDB');


        ellist(2) := xdb$insertElement(schref, PN_MODEL_CHOICE, 
                         'choice', xdb.xdb$qname('01', 'modelType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'CHOICE_KIDS',
                         'XDB$MODEL_T', 'XDB', JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                 FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$CHOICE_MODEL', null, 'oracle.xdb.Model', 
                'oracle.xdb.ModelBean', FALSE, null, null, null,
               'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_MODEL_SEQUENCE, 
                         'sequence', xdb.xdb$qname('01', 'modelType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'SEQUENCE_KIDS',
                         'XDB$MODEL_T', 'XDB', JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                 FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SEQUENCE_MODEL', null, 'oracle.xdb.Model', 
                'oracle.xdb.ModelBean', FALSE, null, null, null,
               'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(4) := xdb$insertElement(schref, PN_MODEL_ANY, 
                         'any', xdb.xdb$qname('01', 'anyType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'ANYS',
                         'XDB$ANY_T', 'XDB', JT_XMLTYPE,
                                       null, null, any_t_ref,null,null,
                                       null, any_colcount,
                 FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$ANY', null, 'oracle.xdb.Any', 
                'oracle.xdb.AnyBean', FALSE, 'PROPERTY', null, null,
               'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(5) := xdb$insertElement(schref, PN_MODEL_GROUP, 
                         'group', xdb.xdb$qname('01', 'groupRefType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'GROUPS',
                         'XDB$GROUP_REF_T', 'XDB', JT_XMLTYPE,
                                       null, null, groupref_t_ref,null,null,
                                       null, groupref_colcount,
                 FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$GROUP_REF', null, 'oracle.xdb.Group', 
                'oracle.xdb.GroupBean', FALSE, null, null, null,
               'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* choice 0..unbounded of above elements */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb$insertChoice(schref, ellist);
        
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref, PN_MODEL_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        /* sequence of annotation and choice */
        seq_ref    := xdb$insertSequence(schref, ellist, null, choice_list);

        xdb$updateComplex(model_t_ref, schref, null,
                       'modelType', null, FALSE,
                       null, null, null, null, null, null, attlist, seq_ref);
        complexlist(9) := model_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:simpleContentResType"
 * This captures the simpleContent -> restriction case.
 * Strictly speaking, the W3C schema allows the facets like minInclusive
 * etc to appear in any order. They really should be part of the choice (unb)
 * but that would map them to arrays. Since we know there can be only one
 * minInclusive it seems to be an overkill to map them to arrays. Hence
 * we make them as a sequence
 *
 *    simpleContRes :=
 *                             -- annotation   (0..1)
 *                            |
 *                             -- simpleType   (0..1)
 *                            |
 *                            |-- minExclusive (0..1)
 *                            |-- minInclusive (0..1)
 *                            |     ....
 *          sequence ---------|-- pattern      (0..1)
 *                            |
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_SIMPLECONTRES_BASE,
                                     'base', xdb.xdb$qname('00', 'QName'), 0,1,
                                     null, T_QNAME, FALSE, FALSE, FALSE,
                                     'BASE', 'XDB$QNAME', 'XDB',
                                     JT_QNAME, null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_SIMPLECONTRES_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        /* Construct choice of <attribute>, <attributeGroup>, <anyAttrib> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        ellist(1) := xdb$insertElement(schref, PN_SIMPLECONTRES_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',
                                       JT_XMLTYPE, null, null, null,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');
                                       
        ellist(2) := xdb$insertElement(schref, PN_SIMPLECONTRES_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',
                                       JT_XMLTYPE, null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean',
                                       FALSE, 'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_SIMPLECONTRES_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* insert choice of above */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb$insertChoice(schref, ellist);

        /* Construct sequence of <annotation>...<minExclusive> etc */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(16);

        ellist(1) := xdb$insertElement(schref, PN_SIMPLECONTRES_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_SIMPLECONTRES_FRACDIGITS,
                        'fractionDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                        T_XOB, FALSE, FALSE, FALSE, 'FRACTIONDIGITS', 
                        'XDB$NUMFACET_T', 'XDB', JT_SHORT, null, null, 
                        num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_SIMPLECONTRES_TOTALDIGITS, 'totalDigits', 
                        xdb.xdb$qname('01', 'numFacet'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'TOTALDIGITS', 'XDB$NUMFACET_T', 'XDB', JT_SHORT, null,null, 
                        num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref,PN_SIMPLECONTRES_MINLENGTH, 
                                'minLength', 
                              xdb.xdb$qname('01', 'numFacet'), 0, 1, null, 
                              T_XOB, FALSE, FALSE, FALSE, 'MINLENGTH', 
                              'XDB$NUMFACET_T', 'XDB', JT_INT, null, null, 
                              num_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null) ;

        ellist(5) := xdb$insertElement(schref, PN_SIMPLECONTRES_MAXLENGTH,
                              'maxLength', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'MAXLENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(6) := xdb$insertElement(schref, PN_SIMPLECONTRES_WHITESPACE, 'whiteSpace', 
                        xdb.xdb$qname('01', 'whiteSpace'), 0, 1, '1', 
                         T_XOB, FALSE, FALSE, FALSE, 'WHITESPACE', 
                        'XDB$WHITESPACE_T', 'XDB', JT_ENUM, null, null, 
                        whitespace_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(7) := xdb$insertElement(schref, PN_SIMPLECONTRES_PERIOD, 'period', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'PERIOD', 
                        'XDB$TIMEFACET_T', 'XDB', JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(8) := xdb$insertElement(schref, PN_SIMPLECONTRES_DURATION,'duration', 
                                         xdb.xdb$qname('01', 'timeFacet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'DURATION', 
                        'XDB$TIMEFACET_T','XDB',JT_TIMESTAMP, null, null, 
                        time_facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(9) := xdb$insertElement(schref, PN_SIMPLECONTRES_MININCLUSIVE, 
                                'minInclusive', 
                                xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_INCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(10) := xdb$insertElement(schref, PN_SIMPLECONTRES_MAXINCLUSIVE,
                                               'maxInclusive', 
                                        xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_INCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(11) := xdb$insertElement(schref, PN_SIMPLECONTRES_PATTERN, 'pattern', 
                                xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 'PATTERN', 
                        'XDB$FACET_T', 'XDB', JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');


        ellist(12) := xdb$insertElement(schref, PN_SIMPLECONTRES_ENUMERATION,
                                'enumeration', xdb.xdb$qname('01', 'facet'), 
                        0, 65535, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ENUMERATION', 'XDB$FACET_T', 'XDB',
                        JT_STRING, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                'XDB$FACET_LIST_T','XDB');

        ellist(13) := xdb$insertElement(schref, PN_SIMPLECONTRES_MINEXCLUSIVE, 
                            'minExclusive', xdb.xdb$qname('01', 'facet'),
                 0, 1, null, T_XOB, FALSE, FALSE, FALSE, 'MIN_EXCLUSIVE', 
                        'XDB$FACET_T', 'XDB', JT_INT, null, null, facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(14) := xdb$insertElement(schref, PN_SIMPLECONTRES_MAXEXCLUSIVE,
                                'maxExclusive', xdb.xdb$qname('01', 'facet'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                         'MAX_EXCLUSIVE', 'XDB$FACET_T', 'XDB', JT_INT, null, null, 
                         facet_ref,null,null, 
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null);

        ellist(15) := xdb$insertElement(schref, PN_SIMPLECONTRES_LENGTH,
                              'length', xdb.xdb$qname('01', 'numFacet'),
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'LENGTH', 'XDB$NUMFACET_T', 'XDB', JT_INT, null, 
                        null, num_facet_ref,null,null,
                null, 2, FALSE, null, null, FALSE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null); 

        ellist(16) := xdb$insertElement(schref, PN_SIMPLECONTRES_SIMPLETYPE, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'LCL_SMPL_DECL',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null);

        /* insert sequence of above */
        seq_ref := xdb$insertSequence(schref, ellist, null, choice_list);

        simplecontRes_t_ref := xdb$insertComplex(schref, null,
                                               'simpleContentResType', 
                                               null, FALSE, null, '0',
                                               null, null, null, null, null,
                                               null, null, null, null,
                                               null, null,
                                               null, null,
                                               null, null, null, attlist,
                                               null, FALSE, seq_ref);
        complexlist(27) := simplecontRes_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:simpleContentExtType"
 * This captures the simpleContent -> extension case.
 * It allows a superset of W3C schemas.
 *
 *   simpleContExt :=                -- annotation (0..1)
 *                                  |
 *                    sequence  ----
 *                     (1..1)       |
 *                                   -- choice (0..unb)
 *                                         -- attribute      (0..1)
 *                                         -- attributeGroup (0..1)
 *                                         -- anyAttribute   (0..1)
 *--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_SIMPLECONTEXT_BASE,
                                     'base', xdb.xdb$qname('00', 'QName'), 0,1,
                                     null, T_QNAME, FALSE, FALSE, FALSE,
                                     'BASE', 'XDB$QNAME', 'XDB',
                                     JT_QNAME, null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_SIMPLECONTEXT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        /* Construct choice of <attribute>, <attributeGroup>, <anyAttrib> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        ellist(1) := xdb$insertElement(schref, PN_SIMPLECONTEXT_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',
                                       JT_XMLTYPE, null, null, null,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');
                                       
        ellist(2) := xdb$insertElement(schref, PN_SIMPLECONTEXT_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',
                                       JT_XMLTYPE, null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean',
                                       FALSE, 'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_SIMPLECONTEXT_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* insert choice of above */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb$insertChoice(schref, ellist);

        /* build annotation element */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref,PN_SIMPLECONTEXT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        /* insert sequence of above */
        seq_ref := xdb$insertSequence(schref, ellist, null, choice_list);

        simplecontExt_t_ref := xdb$insertComplex(schref, null,
                                               'simpleContentExtType', 
                                               null, FALSE, null, '0',
                                               null, null, null, null, null,
                                               null, null, null, null,
                                               null, null,
                                               null, null,
                                               null, null, null, attlist,
                                               null, FALSE, seq_ref);
        complexlist(28) := simplecontExt_t_ref;


/*--------------------------------------------------------------------------*/
/* Definition of "xdb:complexDerivationType" XML element
 * Again, this does not strictly reflect the W3C schema for schemas but
 * only serves to define our O-R mapping and allow a superset.
 *
 *      complexDerivation :=
 *                             -- annotation (0..1)
 *                            |
 *                            |             choice         (0..1)
 *                             -- choice -- sequence       (0..1)
 *                            |             group          (0..1)
 *          sequence ---------|             all            (0..1)
 *                            |             
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);

        attlist(1) := xdb$insertAttr(schref, PN_COMPLEXDERIVATION_BASE,
                                     'base', xdb.xdb$qname('00', 'QName'), 0, 1,
                                     null, T_QNAME, FALSE, FALSE, FALSE,
                                     'BASE', 'XDB$QNAME', 'XDB',
                                     JT_QNAME, null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_COMPLEXDERIVATION_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        /* Construct choice of <group>, <choice>, <all>, <sequence> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(4);

        ellist(1) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_ALL, 
                                       'all', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'ALL_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ALL_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_CHOICE, 
                                       'choice', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'CHOICE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$CHOICE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_SEQUENCE, 
                                       'sequence', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'SEQUENCE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$SEQUENCE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_GROUP, 
                                       'group', xdb.xdb$qname('01', 'groupRefType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'GROUP_KID', 'XDB$GROUP_REF_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, groupref_t_ref,null,null,
                                       null, groupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$GROUP_REF', null,
                                       'oracle.xdb.Group', 
                                       'oracle.xdb.GroupBean',
                                       FALSE, null, null, null);


        /* insert choice */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(2);
        choice_list(1) := xdb$insertChoice(schref, ellist, null, '1');

        /* construct choice of <attribute>, <anyAttribute> and <attribGrp> */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);
        ellist(1) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',
                                       JT_XMLTYPE, null, null, null,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');
                                       
        ellist(2) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',
                                       JT_XMLTYPE, null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean',
                                       FALSE, 'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_COMPLEXDERIVATION_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* insert choice of above */
        choice_list(2) := xdb$insertChoice(schref, ellist);

        /* build annotation element */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref,PN_COMPLEXDERIVATION_ANNOT, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        /* insert sequence of above */
        seq_ref := xdb$insertSequence(schref, ellist, null, choice_list);

        complexderv_t_ref := xdb$insertComplex(schref, null,
                                               'complexDerivationType', 
                                               null, FALSE, null, '0',
                                               null, null, null, null, null,
                                               null, null, null, null,
                                               null, null,
                                               null, null,
                                               null, null, null, attlist,
                                               null, FALSE, seq_ref);
        complexlist(10) := complexderv_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:smplcontentType" XML element */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(1);
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_SIMPLECONTENT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist(1) := xdb$insertElement(schref,PN_SIMPLECONTENT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_SIMPLECONTENT_RESTRICTION,
                                       'restriction',
                                     xdb.xdb$qname('01', 'simpleContentResType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'RESTRICTION',
                                       'XDB$SIMPLECONT_RES_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, simplecontRes_t_ref,null,null,
                                       null, simplecontRes_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleContentRestriction', 
                                       'oracle.xdb.simpleContentRestrictionBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_SIMPLECONTENT_EXTENSION,
                                       'extension',
                                     xdb.xdb$qname('01', 'simpleContentExtType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'EXTENSION',
                                       'XDB$SIMPLECONT_EXT_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, simplecontExt_t_ref,null,null,
                                       null, simplecontExt_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleContentExtension', 
                                       'oracle.xdb.simpleContentExtensionBean',
                                       FALSE, null, null, null);
    
        smplcont_t_ref := xdb$insertComplex(schref, null,
                                           'smplcontentType', 
                                           null, FALSE, null, '0',
                                           null, null, null, null, null,
                                           null, null, null, null,
                                           null, null,
                                           null, null,
                                           null, null, ellist, attlist);
        complexlist(29) := smplcont_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:cplxcontentType" XML element */
/*--------------------------------------------------------------------------*/
        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(2);
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_CONTENT_MIXED,
                                     'mixed', TR_BOOLEAN, 0, 1,null, 
                                     T_BOOLEAN, FALSE, FALSE, FALSE,
                                     'MIXED', 'RAW', null, JT_BOOLEAN,
                                     'false', null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_CONTENT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist(1) := xdb$insertElement(schref,PN_CONTENT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_CONTENT_RESTRICTION,
                                       'restriction',
                                     xdb.xdb$qname('01', 'complexDerivationType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'RESTRICTION',
                                       'XDB$COMPLEX_DERIVATION_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, complexderv_t_ref,null,null,
                                       null, complexder_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.complexDerivation', 
                                       'oracle.xdb.complexDerivationBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_CONTENT_EXTENSION,
                                       'extension',
                                     xdb.xdb$qname('01', 'complexDerivationType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'EXTENSION',
                                       'XDB$COMPLEX_DERIVATION_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, complexderv_t_ref,null,null,
                                       null, complexder_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.complexDerivation', 
                                       'oracle.xdb.complexDerivationBean',
                                       FALSE, null, null, null);
    
        content_t_ref := xdb$insertComplex(schref, null,
                                           'cplxcontentType', 
                                           null, FALSE, null, '0',
                                           null, null, null, null, null,
                                           null, null, null, null,
                                           null, null,
                                           null, null,
                                           null, null, ellist, attlist);
        complexlist(11) := content_t_ref;


/*--------------------------------------------------------------------------*/
/* Definition of "xdb:complexType" XML element.
 * Note that this does not strictly match the W3C schema for schemas. We
 * will accept a superset of W3C schemas but schema validator will catch these.
 *
 *       complexType :=
 *                             -- annotation (0..1)
 *                            |
 *                            |             simpleContent  (0..1)
 *                             -- choice -- complexContent (0..1)
 *                            |             group          (0..1)
 *          sequence ---------|             all            (0..1)
 *                            |             sequence       (0..1)
 *                            |             choice         (0..1)
 *                            |
 *                            |             attribute      (0..1)
 *                             -- choice -- attributeGrp   (0..1)
 *                               (0..unb)   anyAttribute   (0..1) 
 *
 *--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(12);

        attlist(1) := xdb$insertAttr(schref, PN_COMPLEXTYPE_PARENTSCHEMA,
                                     'parentSchema', 
                                     xdb.xdb$qname('00','REF'), 0, 1,
                                     null, T_REF, TRUE, FALSE, FALSE, 
                                     'PARENT_SCHEMA', 'REF', null,
                                     JT_REFERENCE, 
                                     null, null, null,null,null,
                                     null, null, '01');
        attlist(2) := xdb$insertAttr(schref, PN_COMPLEXTYPE_NAME,
                                     'name', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                                     'VARCHAR2', null, JT_STRING, null, null,
                                     null,null,null);
        attlist(3) := xdb$insertAttr(schref, PN_COMPLEXTYPE_ABSTRACT,
                                     'abstract', TR_BOOLEAN, 0, 1,null, 
                                     T_BOOLEAN, FALSE, FALSE, FALSE,
                                     'ABSTRACT', 'RAW', null, JT_BOOLEAN,
                                     'false', null, null,null,null);
        attlist(4) := xdb$insertAttr(schref, PN_COMPLEXTYPE_MIXED,
                                     'mixed', TR_BOOLEAN, 0, 1,null, 
                                     T_BOOLEAN, FALSE, FALSE, FALSE,
                                     'MIXED', 'RAW', null, JT_BOOLEAN,
                                     'false', null, null,null,null);
        attlist(5) := xdb$insertAttr(schref, PN_COMPLEXTYPE_FINAL, 'final', 
                               xdb.xdb$qname('01', 'derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'FINAL_INFO',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM,
                               null, null, drv_choice_ref,null,null);
        attlist(6) := xdb$insertAttr(schref, PN_COMPLEXTYPE_BLOCK, 'block', 
                               xdb.xdb$qname('01', 'derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'BLOCK',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM, 
                               null, null, drv_choice_ref,null,null);
        attlist(7) := xdb$insertAttr(schref, PN_COMPLEXTYPE_SQLTYPE, 
                               'SQLType', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLTYPE', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);
        attlist(8) := xdb$insertAttr(schref, PN_COMPLEXTYPE_SQLSCHEMA, 
                               'SQLSchema', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLSCHEMA', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);
        attlist(9) := xdb$insertAttr(schref, PN_COMPLEXTYPE_MAINTAINDOM, 
                               'maintainDOM', TR_BOOLEAN, 0,1, 
                                null, T_BOOLEAN, TRUE, FALSE, FALSE,
                               'MAINTAIN_DOM', 'RAW', null, JT_BOOLEAN, 
                               'true', null, null,null,null);
        attlist(10) := xdb$insertAttr(schref, PN_COMPLEXTYPE_BASETYPE,
                                     'baseType', xdb.xdb$qname('00', 'REF'), 0, 1,
                                     null, T_REF, TRUE, FALSE, FALSE,
                                     'BASE_TYPE', 'REF', null, JT_REFERENCE,
                                     null, null, null,null,null,
                                     null, null, '01');
        attlist(11) := xdb$insertAttr(schref, PN_COMPLEXTYPE_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);
        attlist(12) := xdb$insertAttr(schref, PN_COMPLEXTYPE_TYPEID, 'typeID',
                               TR_INT, 0, 1, null, 
                               T_UNSIGNINT, TRUE, FALSE, FALSE, 'TYPEID',
                               'NUMBER', null, JT_INT, null, null, null,null,
                                null);


        /* construct a choice of <simpleContent>, <complexContent>,
         * <group>, <all>, <seq>, <choice>
         */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(6);

        ellist(1) := xdb$insertElement(schref, PN_COMPLEXTYPE_CHOICE, 
                                     'choice', xdb.xdb$qname('01','modelType'),
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'CHOICE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$CHOICE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_COMPLEXTYPE_SEQUENCE, 
                                       'sequence', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'SEQUENCE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$SEQUENCE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_COMPLEXTYPE_GROUP, 
                                       'group', xdb.xdb$qname('01', 'groupRefType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'GROUP_KID', 'XDB$GROUP_REF_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, groupref_t_ref,null,null,
                                       null, groupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$GROUP_REF', null,
                                       'oracle.xdb.Group', 
                                       'oracle.xdb.GroupBean',
                                       FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref, PN_COMPLEXTYPE_ALL, 
                                       'all', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'ALL_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ALL_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(5) := xdb$insertElement(schref, PN_COMPLEXTYPE_SIMPLECONTENT, 
                                       'simpleContent',
                                     xdb.xdb$qname('01', 'smplcontentType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'SIMPLECONT',
                                       'XDB$SIMPLECONTENT_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, smplcont_t_ref,null,null,
                                       null, smplcont_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.simpleContent', 
                                       'oracle.xdb.simpleContent',
                                       FALSE, null, null, null);

        ellist(6) := xdb$insertElement(schref, PN_COMPLEXTYPE_COMPLEXCONTENT, 
                                       'complexContent',
                                       xdb.xdb$qname('01', 'cplxcontentType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'COMPLEXCONTENT',
                                       'XDB$CONTENT_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, content_t_ref,null,null,
                                       null, content_colcount, 
                                       FALSE, null, null, FALSE, FALSE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       'oracle.xdb.content', 
                                       'oracle.xdb.content',
                                       FALSE, null, null, null);

        /* Insert these as a choice */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(2);
        choice_list(1) := xdb$insertChoice(schref, ellist, null, '1');

        /* Construct a choice of <attribute>, <attributeGroup> and
         * <anyAttribute>
         */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(3);
        
        ellist(1) := xdb$insertElement(schref, PN_COMPLEXTYPE_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1, null, T_XOB, FALSE,
                                       FALSE, FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',JT_XMLTYPE,
                                       null, null, null,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean', FALSE,
                                       null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(2) := xdb$insertElement(schref, PN_COMPLEXTYPE_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_COMPLEXTYPE_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1, null, T_XOB, FALSE,
                                       FALSE, FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',JT_XMLTYPE,
                                       null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean', FALSE,
                                       'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* Insert these as a choice */
        choice_list(2) := xdb$insertChoice(schref, ellist);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(2);
        ellist(1) := xdb$insertElement(schref, PN_COMPLEXTYPE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_COMPLEXTYPE_SUBTYPEREF, 
                             'subtypeRef',xdb.xdb$qname('00', 'REF'), 0, 1000,null,
                              T_REF, TRUE, FALSE, FALSE, 'SUBTYPE_REFS', 
                       'REF', null, JT_REFERENCE, null, null, null,null,null,
                 null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE,
                 null, null, null, null, FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB', '01');


        /* insert the sequence */
        seq_ref := xdb$insertSequence(schref, ellist, null, choice_list);

        complex_t_ref := xdb$insertComplex(schref, null, 
                       'complexType', null, FALSE, 
                       null, '0', null, null, null, null, null, null, 
                       null, null, null, null, null,
                       null, null, null, null, null, attlist, null, FALSE,
                       seq_ref);
        complexlist(6) := complex_t_ref;


        ctype_propnum := 29;
        schels(3) := xdb$insertElement(schref, ctype_propnum, 
                        'complexType', 
                         xdb.xdb$qname('01','complexType'), 0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'COMPLEX_TYPES',
                         'XDB$COMPLEX_T', 'XDB', JT_XMLTYPE, null, null, 
                         complex_t_ref,null,null,
                xdb.xdb$qname('01', 'schemaTop'), complex_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$COMPLEX_TYPE', null, 'oracle.xdb.ComplexType', 
                'oracle.xdb.ComplexTypeBean', TRUE, null, null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:attribute" XML element */
/*--------------------------------------------------------------------------*/


        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(26);
        attlist(1) := xdb$insertAttr(schref, 30, 'parentSchema', 
                               xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'PARENT_SCHEMA', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');
        attlist(2) := xdb$insertAttr(schref, 31, 'propNumber', TR_INT, 0, 1, null, 
                               T_UNSIGNINT, TRUE, FALSE, FALSE, 'PROP_NUMBER',
                               'NUMBER', null, JT_INT, '0', null, null,null,null);
        attlist(3) := xdb$insertAttr(schref, 32, 'name', TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);
        attlist(4) := xdb$insertAttr(schref, 33, 'type', 
                               xdb.xdb$qname('00', 'QName'), 0, 1, null, 
                               T_QNAME, FALSE, FALSE, FALSE, 'TYPENAME', 
                               'XDB$QNAME', 'XDB', JT_QNAME, 
                               null, null, null,null,null);

        attlist(5) := xdb$insertAttr(schref, 36, 'memByteLength', TR_INT, 0, 
                                1, '2', T_INTEGER, TRUE, FALSE, FALSE, 
                               'MEM_BYTE_LENGTH', 'RAW', null, JT_SHORT, null, 
                               null, null,null,null);

        attlist(6) := xdb$insertAttr(schref, 37, 'memType', TR_INT, 0, 
                                1, '2', T_INTEGER, TRUE, FALSE, FALSE, 
                               'MEM_TYPE_CODE', 'RAW', null, JT_SHORT, null, 
                               null, null,null,null);

        attlist(7) := xdb$insertAttr(schref, 38, 'system', TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'SYSTEM',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(8) := xdb$insertAttr(schref, 39, 'mutable', TR_BOOLEAN, 0, 1, null,
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'MUTABLE',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(9) := xdb$insertAttr(schref, 40, 'form', 
                               xdb.xdb$qname('01','formChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'FORM', 'XDB$FORMCHOICE', 'XDB',
                               JT_ENUM, null, null, form_choice_ref,null,null);

        attlist(10) := xdb$insertAttr(schref, 41, 'SQLName', TR_STRING, 1, 1, null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLNAME', 
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(11) := xdb$insertAttr(schref, 42, 'SQLType', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLTYPE', 
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(12) := xdb$insertAttr(schref, 43, 'SQLSchema', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLSCHEMA', 
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(13) := xdb$insertAttr(schref, 44, 'JavaType', 
                                xdb.xdb$qname('01', 'javatype'), 1, 1, null,
                               T_ENUM, TRUE, FALSE, FALSE, 'JAVA_TYPE', 
                               'XDB$JAVATYPE', 'XDB', JT_ENUM, null, null, 
                               javatype_ref,null,null);

        attlist(14) := xdb$insertAttr(schref, 45, 'default', TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'DEFAULT_VALUE',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(15) := xdb$insertAttr(schref, 46, 'typeRef', 
                               xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'TYPE_REF', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');

        attlist(16) := xdb$insertAttr(schref, 84, 'ref', 
                                 xdb.xdb$qname('00', 'QName'), 0,1, null,
                                 T_QNAME, FALSE, FALSE, FALSE, 
                                 'PROPREF_NAME', 'XDB$QNAME', 'XDB', 
                                 JT_QNAME, null, null,null,null,null);

        attlist(17) := xdb$insertAttr(schref, 85, 'refRef', 
                                 xdb.xdb$qname('00', 'REF'), 0,1, null,
                                 T_REF, TRUE, FALSE, FALSE, 
                                 'PROPREF_REF', 'REF', null, 
                                 JT_REFERENCE, null, null,null,null,null,
                                 null, null, '01');

        attlist(18) := xdb$insertAttr(schref, PN_ATTRIBUTE_USE, 'use', 
                               xdb.xdb$qname('01','useChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'ATTR_USE', 'XDB$USECHOICE', 'XDB',
                               JT_ENUM, null, null, use_choice_ref,null,null);

        attlist(19) := xdb$insertAttr(schref, PN_ATTRIBUTE_FIXED, 'fixed',
                                      TR_STRING, 1, 1, null, 
                                      T_CSTRING, FALSE, FALSE, FALSE,
                                      'FIXED_VALUE', 'VARCHAR2', null,
                                      JT_STRING, null, null, null,null,null);

        attlist(20) := xdb$insertAttr(schref,63, 'global', TR_BOOLEAN,1,1,null,
                                      T_BOOLEAN, TRUE, FALSE, FALSE, 
                                      'GLOBAL', 'RAW', null, 
                                      JT_BOOLEAN, null, null, null,null,null);

        attlist(21) := xdb$insertAttr(schref, PN_ATTR_SQLCOLLTYPE, 
                               'SQLCollType', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLCOLLTYPE', 
                               'VARCHAR2', null, JT_STRING, null, null, null,
                               null,null);

        attlist(22) := xdb$insertAttr(schref, PN_ATTR_SQLCOLLSCHEMA, 
                               'SQLCollSchema', TR_STRING, 1, 1,null,
                               T_CSTRING, TRUE, FALSE, FALSE, 'SQLCOLLSCHEMA',
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);
     
        attlist(23) := xdb$insertAttr(schref, PN_ATTR_HIDDEN, 'hidden', 
                               TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'HIDDEN',
                               'RAW', null, JT_BOOLEAN, 'false', null, 
                               null,null,null);

        attlist(24) := xdb$insertAttr(schref, PN_ATTR_TRANSIENT, 'transient', 
                               xdb.xdb$qname('01','transientChoice'), 0, 1, '01', 
                               T_ENUM, TRUE, FALSE, FALSE, 'TRANSIENT',
                               'XDB$TRANSIENTCHOICE', 'XDB', JT_ENUM, 
                               null, null, transient_choice_ref, null, null);

        attlist(25) := xdb$insertAttr(schref, PN_ATTR_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        attlist(26) := xdb$insertAttr(schref, PN_ATTR_BASEPROP, 'baseProp', 
                               TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'BASEPROP',
                               'RAW', null, JT_BOOLEAN, 'false', null, 
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(2);

        ellist(1) := xdb$insertElement(schref, PN_ATTRIBUTE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, 47, 
                        'simpleType', xdb.xdb$qname('01','simpleType'), 
                         0, 1, null, 
                         T_XOB, FALSE, FALSE, FALSE, 'SMPL_TYPE_DECL',
                         'XDB$SIMPLE_T', 'XDB', JT_XMLTYPE, null, null, 
                         simple_t_ref,null,null,
                         null, simple_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$SIMPLE_TYPE', null, 'oracle.xdb.SimpleType', 
                'oracle.xdb.SimpleTypeBean', FALSE, null, null, null);

        attr_t_ref := xdb$insertComplex(schref, null, 'attribute', 
                                null, FALSE, null, '0',
                       null, null, null, null, null, null, null, null, null,
                       null, null,
                null, null, null, null, ellist, attlist);
        complexlist(7) := attr_t_ref;


        attr_propnum := 48;
        schels(4) := xdb$insertElement(schref, attr_propnum, 
                        'attribute', xdb.xdb$qname('01','attribute'), 0,1,
                         null, T_XOB, FALSE, FALSE, FALSE, 'ATTRIBUTES',
                        'XDB$PROPERTY_T', 'XDB', JT_XMLTYPE, null, null, 
                        attr_t_ref,null,null,
                xdb.xdb$qname('01', 'schemaTop'), attr_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$ATTRIBUTE', null, 'oracle.xdb.Attribute', 
                'oracle.xdb.AttributeBean', TRUE, null, null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

        execute immediate 'update xdb.xdb$element e set 
                e.xmldata.property.type_ref = 
                :1 where e.xmldata.property.typename.name = ''attribute'''
                using attr_t_ref;


/*--------------------------------------------------------------------------*/
/* Definition of "xdb:element" XML element */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(26);

        attlist(1) := xdb$insertAttr(schref, 49, 'baseSQLname', 
                               TR_STRING, 0, 1, 
                               null, T_CSTRING, TRUE, FALSE, FALSE, 
                               'BASE_SQLNAME', 'VARCHAR2', null, JT_STRING, 
                               null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, 50, 'substitutionGroup', 
                                xdb.xdb$qname('00', 'QName'), 0,1,null, 
                               T_QNAME, FALSE, FALSE, FALSE, 'SUBS_GROUP',
                               'XDB$QNAME', 'XDB', JT_QNAME, null, null, null,null,null);

        attlist(3) := xdb$insertAttr(schref, 51, 'nillable', TR_BOOLEAN, 0, 1,null,
                               T_BOOLEAN, FALSE, FALSE, FALSE, 'NILLABLE',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(4) := xdb$insertAttr(schref, 52, 'final', 
                               xdb.xdb$qname('01','derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'FINAL_INFO',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM,
                               null, null, drv_choice_ref,null,null);

        attlist(5) := xdb$insertAttr(schref, 53, 'block', 
                               xdb.xdb$qname('01','derivationChoice'), 0, 1, 
                               null, T_ENUM, FALSE, FALSE, FALSE, 'BLOCK',
                               'XDB$DERIVATIONCHOICE', 'XDB', JT_ENUM,
                               null, null, drv_choice_ref,null,null);

        attlist(6) := xdb$insertAttr(schref, 54, 'abstract', TR_BOOLEAN, 0, 1,null,
                               T_BOOLEAN, FALSE, FALSE, FALSE, 'ABSTRACT',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(7) := xdb$insertAttr(schref, 55, 'SQLInline', TR_BOOLEAN,0,1,null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'SQL_INLINE',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(8) := xdb$insertAttr(schref, 56,'JavaInline', TR_BOOLEAN,0,1,null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'JAVA_INLINE',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(9) := xdb$insertAttr(schref, 57,'MemInline', TR_BOOLEAN, 0,1,null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'MEM_INLINE',
                               'RAW', null, JT_BOOLEAN, 'false', null, null,null,null);

        attlist(10) := xdb$insertAttr(schref, 58, 'maintainDOM', TR_BOOLEAN, 0,1, 
                                null, T_BOOLEAN, TRUE, FALSE, FALSE,
                               'MAINTAIN_DOM', 'RAW', null, JT_BOOLEAN, 
                               'true', null, null,null,null);

        attlist(11) := xdb$insertAttr(schref, 59,'defaultTable', TR_STRING,0,1,null,
                               T_CSTRING, TRUE, FALSE, FALSE,'DEFAULT_TABLE',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(12) := xdb$insertAttr(schref, PN_ELEMENT_DEFTABLESCHEMA,
                               'defaultTableSchema', 
                               TR_STRING,0,1,null,
                               T_CSTRING, TRUE, FALSE, FALSE,
                               'DEFAULT_TABLE_SCHEMA', 
                               'VARCHAR2', null, JT_STRING, null,
                               null, null,null,null);
        
        attlist(13) := xdb$insertAttr(schref,60,'tableProps', TR_STRING,0,1,null, 
                               T_CSTRING, TRUE, FALSE, FALSE, 'TABLE_PROPS',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(14) := xdb$insertAttr(schref,61,'JavaClassname',TR_STRING,0,1,null, 
                               T_CSTRING, TRUE, FALSE, FALSE,'JAVA_CLASSNAME',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(15) := xdb$insertAttr(schref,62,'beanClassname', TR_STRING,0,1,null,
                               T_CSTRING, TRUE, FALSE, FALSE,'BEAN_CLASSNAME',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(16) := xdb$insertAttr(schref, 64, 'numCols', TR_INT, 1,1, 
                                 '02', T_INTEGER, TRUE, FALSE, FALSE, 
                               'NUM_COLS', 'INTEGER', null, JT_INT, null, 
                               null,null,null,null);

        attlist(17) := xdb$insertAttr(schref, PN_ELEMENT_DEFAULTXSL, 
                                'defaultXSL', TR_STRING, 
                                1,1,null, T_CSTRING, TRUE, FALSE, FALSE, 
                                'DEFAULT_XSL', 'VARCHAR2', null, JT_STRING, 
                                null, null, null,null,null);

        attlist(18) := xdb$insertAttr(schref, 34, 'minOccurs', 
                               TR_INT, 0, 1, null, 
                               T_INTEGER, FALSE, FALSE, FALSE, 'MIN_OCCURS', 
                               'NUMBER', null, JT_INT, '0', 
                               null, null,null,null);

        attlist(19) := xdb$insertAttr(schref, 35, 'maxOccurs', 
                               TR_STRING, 0, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'MAX_OCCURS', 
                               'VARCHAR2', null, JT_STRING, null, 
                               null, null,null,null);

        attlist(20) := xdb$insertAttr(schref, PN_ELEMENT_ISFOLDER, 'isFolder', 
                               TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'IS_FOLDER',
                               'RAW', null, JT_BOOLEAN, 'false', null, 
                               null,null,null);

        attlist(21) := xdb$insertAttr(schref, PN_ELEMENT_MAINTAINORDER, 
                              'maintainOrder', TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'MAINTAIN_ORDER',
                               'RAW', null, JT_BOOLEAN, 'true', null, 
                               null,null,null);

        attlist(22) := xdb$insertAttr(schref,PN_ELEMENT_COLUMNPROPS,
                               'columnProps', TR_STRING,0,1,null, 
                               T_CSTRING, TRUE, FALSE, FALSE, 'COL_PROPS',
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(23) := xdb$insertAttr(schref, PN_ELEMENT_DEFAULTACL, 
                                'defaultACL', TR_STRING, 
                                1,1,null, T_CSTRING, TRUE, FALSE, FALSE, 
                                'DEFAULT_ACL', 'VARCHAR2', null, JT_STRING, 
                                null, null, null,null,null);

        attlist(24) := xdb$insertAttr(schref, PN_ELEMENT_HEADELEM_REF, 
                                 'headElementRef', 
                                 xdb.xdb$qname('00', 'REF'), 0,1, null,
                                 T_REF, TRUE, FALSE, FALSE, 
                                 'HEAD_ELEM_REF', 'REF', null, 
                                 JT_REFERENCE, null, null,null,null,null,
                                 null, null, '01');

        attlist(25) := xdb$insertAttr(schref, PN_ELEMENT_ISTRANSLATABLE, 'translate', 
                               TR_BOOLEAN, 0, 1, null, 
                               T_BOOLEAN, TRUE, FALSE, FALSE, 'IS_TRANSLATABLE',
                               'RAW', null, JT_BOOLEAN, null, null, 
                               null,null,null);
	
        attlist(26) := xdb$insertAttr(schref, PN_ELEMENT_XDBMAXOCCURS, 'maxOccurs', 
                               TR_STRING, 0, 1, null, 
                               T_CSTRING, TRUE, FALSE, FALSE, 'XDB_MAX_OCCURS', 
                               'VARCHAR2', null, JT_STRING, null, 
                               null, null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(5);

        ellist(1) := xdb$insertElement(schref, 65,
                         'complexType', xdb.xdb$qname('01','complexType'), 0, 1, 
                         null, T_XOB, FALSE, FALSE, FALSE, 'CPLX_TYPE_DECL',
                         'XDB$COMPLEX_T', 'XDB', JT_XMLTYPE, null, null, 
                         complex_t_ref,null,null, 
                null, complex_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$COMPLEX_TYPE', null, 'oracle.xdb.ComplexType', 
                'oracle.xdb.ComplexTypeBean', FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, 66, 'substitutionGroupRef', 
                               xdb.xdb$qname('00', 'REF'), 0, 1000,null,
                               T_REF, TRUE, FALSE, FALSE, 'SUBS_GROUP_REFS', 
                               'REF', null, JT_REFERENCE, null, null, null,null,null,
                 null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE,
                 'XDB$ELEMENT', null, null, null, FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB', '01');

        ellist(3) := xdb$insertElement(schref, PN_ELEMENT_UNIQUE,
                        'unique', xdb.xdb$qname('01','keybase'), 0,1000,
                         null, T_XOB, FALSE, FALSE, FALSE, 'UNIQUES',
                        'XDB$KEYBASE_T', 'XDB', JT_XMLTYPE, null, null, 
                        keybase_t_ref,null,null, null, keybase_colcount,
                FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                        'XDB$KEYBASE_LIST_T','XDB');

        ellist(4) := xdb$insertElement(schref, PN_ELEMENT_KEY,
                        'key', xdb.xdb$qname('01','keybase'), 0,1000,
                         null, T_XOB, FALSE, FALSE, FALSE, 'KEYS',
                        'XDB$KEYBASE_T', 'XDB', JT_XMLTYPE, null, null, 
                        keybase_t_ref,null,null, null, keybase_colcount,
                FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                        'XDB$KEYBASE_LIST_T','XDB');

        ellist(5) := xdb$insertElement(schref, PN_ELEMENT_KEYREF,
                        'keyref', xdb.xdb$qname('01','keybase'), 0,1000,
                         null, T_XOB, FALSE, FALSE, FALSE, 'KEYREFS',
                        'XDB$KEYBASE_T', 'XDB', JT_XMLTYPE, null, null, 
                        keybase_t_ref,null,null, null, keybase_colcount,
                FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null,
                        'XDB$KEYBASE_LIST_T','XDB');

        ctyperef := xdb$insertComplex(schref, attr_t_ref, 'element', 
                                xdb.xdb$qname('01', 'attribute'), FALSE, null,'0',
                       null, null, null, null, null, null, null, null, null,
                       null, null,
                         null, null, null, null, ellist, attlist);
        complexlist(8) := ctyperef;

        schels(5) := xdb$insertElement(schref, 67, 
                        'element', xdb.xdb$qname('01', 'element'),
                         0, 1, null, T_XOB, FALSE, FALSE, FALSE,'ELEMENTS',
                         'XDB$ELEMENT_T', 'XDB', JT_XMLTYPE, null, null, 
                         ctyperef,null,null,
                xdb.xdb$qname('01', 'schemaTop'), 
                elem_colcount, FALSE, null, null, 
                FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$ELEMENT', null, 'oracle.xdb.Element', 
                'oracle.xdb.ElementBean', TRUE, 'PROPERTY', null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

        /* Update all of the forward references for element */
        execute immediate 'update xdb.xdb$element e set 
                e.xmldata.property.type_ref = 
                :1 where e.xmldata.property.typename.name = ''element'''
                using ctyperef;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:anyType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(4);

        attlist(1) := xdb$insertAttr(schref, PN_ANYTYPE_NAMESPACE,
                                     'namespace', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'NAMESPACE', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

        attlist(2) := xdb$insertAttr(schref, PN_ANYTYPE_PROCESSCONTENTS,
                                     'processContents', 
                                     xdb.xdb$qname('01','processChoice'), 0, 1, 
                                     '01', T_ENUM, FALSE, FALSE, FALSE, 
                                     'PROCESS_CONTENTS',
                                     'XDB$PROCESSCHOICE', 'XDB',
                                     JT_ENUM, null, null,
                                     process_choice_ref,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_ANYTYPE_MINOCCURS,'minOccurs', 
                               TR_INT, 0, 1, null, 
                               T_INTEGER, FALSE, FALSE, FALSE, 'MIN_OCCURS', 
                               'NUMBER', null, JT_INT, '0', 
                               null, null,null,null);

        attlist(4) := xdb$insertAttr(schref, PN_ANYTYPE_MAXOCCURS,'maxOccurs', 
                               TR_STRING, 0, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'MAX_OCCURS', 
                               'VARCHAR2', null, JT_STRING, null, 
                               null, null,null,null);

        xdb$updateComplex(any_t_ref, schref, attr_t_ref, 'anyType', 
                          xdb.xdb$qname('01', 'attribute'), FALSE, null,null,
                          null, null, null, null, attlist);

        complexlist(15) := any_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:groupDefType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_GROUPDEF_PARENTSCHEMA, 
                               'parentSchema', xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'PARENT_SCHEMA', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');

        attlist(2) := xdb$insertAttr(schref, PN_GROUPDEF_NAME, 'name', 
                               TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_GROUPDEF_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(4);

        ellist(1) := xdb$insertElement(schref, PN_GROUPDEF_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_GROUPDEF_ALL, 
                                       'all', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'ALL_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ALL_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(3) := xdb$insertElement(schref, PN_GROUPDEF_CHOICE, 
                                       'choice', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'CHOICE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$CHOICE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        ellist(4) := xdb$insertElement(schref, PN_GROUPDEF_SEQUENCE, 
                                       'sequence', xdb.xdb$qname('01', 'modelType'), 
                                       0, 1, null, 
                                       T_XOB, FALSE, FALSE, FALSE,
                                       'SEQUENCE_KID', 'XDB$MODEL_T', 'XDB',
                                       JT_XMLTYPE,
                                       null, null, model_t_ref,null,null,
                                       null, model_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$SEQUENCE_MODEL', null,
                                       'oracle.xdb.Model', 
                                       'oracle.xdb.ModelBean',
                                       FALSE, null, null, null);

        groupdef_t_ref := xdb$insertComplex(schref, null, 
                       'groupDefType', null, FALSE, 
                       null, '0', null, null, null, null, null, null, 
                       null, null, null, null, null,
                       null, null, null, null, ellist, attlist);
        complexlist(20) := groupdef_t_ref;


/*--------------------------------------------------------------------------*/
/* Definition of "xdb:groupRefType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(6);

        attlist(1) := xdb$insertAttr(schref, PN_GROUPREF_PARENTSCHEMA, 
                               'parentSchema', xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'PARENT_SCHEMA', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');

        attlist(2) := xdb$insertAttr(schref,PN_GROUPREF_MINOCCURS,'minOccurs', 
                               TR_INT, 0, 1, null, 
                               T_INTEGER, FALSE, FALSE, FALSE, 'MIN_OCCURS', 
                               'NUMBER', null, JT_INT, '0', 
                               null, null,null,null);

        attlist(3) := xdb$insertAttr(schref,PN_GROUPREF_MAXOCCURS,'maxOccurs', 
                               TR_STRING, 0, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'MAX_OCCURS', 
                               'VARCHAR2', null, JT_STRING, null, 
                               null, null,null,null);

        attlist(4) := xdb$insertAttr(schref, PN_GROUPREF_NAME, 'ref', 
                                 xdb.xdb$qname('00', 'QName'), 0,1, null,
                                 T_QNAME, FALSE, FALSE, FALSE, 
                                 'GROUPREF_NAME', 'XDB$QNAME', 'XDB', 
                                 JT_QNAME, null, null,null,null,null);

        attlist(5) := xdb$insertAttr(schref, PN_GROUPREF_REF, 'refRef', 
                                 xdb.xdb$qname('00', 'REF'), 0,1, null,
                                 T_REF, TRUE, FALSE, FALSE, 
                                 'GROUPREF_REF', 'REF', null, 
                                 JT_REFERENCE, null, null,null,null,null,
                                 null, null, '01');

        attlist(6) := xdb$insertAttr(schref, PN_GROUPREF_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_GROUPREF_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        xdb$updateComplex(groupref_t_ref, schref, null,
                       'groupRefType', null, FALSE,
                       null, null, null, null, null, ellist, attlist);
        complexlist(21) := groupref_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:attrGroupDefType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(3);

        attlist(1) := xdb$insertAttr(schref, PN_ATTRGROUPDEF_PARENTSCHEMA, 
                               'parentSchema', xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'PARENT_SCHEMA', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');

        attlist(2) := xdb$insertAttr(schref, PN_ATTRGROUPDEF_NAME, 'name', 
                               TR_STRING, 1, 1, null, 
                               T_CSTRING, FALSE, FALSE, FALSE, 'NAME', 
                               'VARCHAR2', null, JT_STRING, null, null, 
                               null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_ATTRGROUPDEF_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(4);

        ellist(1) := xdb$insertElement(schref, PN_ATTRGROUPDEF_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        ellist(2) := xdb$insertElement(schref, PN_ATTRGROUPDEF_ATTRIBUTE, 
                                       'attribute',
                                       xdb.xdb$qname('01', 'attribute'),
                                       0, 1000, null, T_XOB, FALSE,
                                       FALSE, FALSE, 'ATTRIBUTES',
                                       'XDB$PROPERTY_T','XDB',JT_XMLTYPE,
                                       null, null, attr_t_ref,null,null, 
                                       null, attr_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRIBUTE', null,
                                       'oracle.xdb.Attribute', 
                                       'oracle.xdb.AttributeBean', FALSE,
                                       null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(3) := xdb$insertElement(schref, PN_ATTRGROUPDEF_ANYATTR, 
                                       'anyAttribute',
                                       xdb.xdb$qname('01', 'anyType'),
                                       0, 1000, null, T_XOB, FALSE,
                                       FALSE, FALSE, 'ANY_ATTRS',
                                       'XDB$ANY_T','XDB',JT_XMLTYPE,
                                       null, null, any_t_ref,null,null, 
                                       null, any_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ANYATTR', null,
                                       'oracle.xdb.anyAttribute', 
                                       'oracle.xdb.anyAttributeBean', FALSE,
                                       'PROPERTY', null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        ellist(4) := xdb$insertElement(schref, PN_ATTRGROUPDEF_ATTRGROUP, 
                                       'attributeGroup',
                                       xdb.xdb$qname('01', 'attrGroupRefType'),
                                       0, 1000, null, T_XOB, FALSE, FALSE,
                                       FALSE, 'ATTR_GROUPS',
                                       'XDB$ATTRGROUP_REF_T','XDB',
                                       JT_XMLTYPE, null, null, 
                                       attrgroupref_t_ref,null,null, 
                                       null, attrgroupref_colcount,
                                       FALSE, null, null, FALSE, FALSE,
                                       FALSE, FALSE, FALSE, 
                                       'XDB$ATTRGROUP_REF', null,
                                       'oracle.xdb.attributeGroup', 
                                       'oracle.xdb.attributeGroupBean',
                                       FALSE, null, null, null,
                                       'XDB$XMLTYPE_REF_LIST_T','XDB');

        attrgroupdef_t_ref := xdb$insertComplex(schref, null, 
                       'attrGroupDefType', null, FALSE, 
                       null, '0', null, null, null, null, null, null, 
                       null, null, null, null, null,
                       null, null, null, null, ellist, attlist);
        complexlist(22) := attrgroupdef_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:attrGroupRefType" complex type */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(4);

        attlist(1) := xdb$insertAttr(schref, PN_ATTRGROUPREF_PARENTSCHEMA, 
                               'parentSchema', xdb.xdb$qname('00','REF'), 0, 1,
                               null, T_REF, TRUE, FALSE, FALSE, 
                               'PARENT_SCHEMA', 'REF', null, JT_REFERENCE, 
                               null, null, null,null,null,
                               null, null, '01');

        attlist(2) := xdb$insertAttr(schref, PN_ATTRGROUPREF_NAME, 'ref', 
                                 xdb.xdb$qname('00', 'QName'), 0,1, null,
                                 T_QNAME, FALSE, FALSE, FALSE, 
                                 'ATTRGROUP_NAME', 'XDB$QNAME', 'XDB', 
                                 JT_QNAME, null, null,null,null,null);

        attlist(3) := xdb$insertAttr(schref, PN_ATTRGROUPREF_REF, 'refRef', 
                                 xdb.xdb$qname('00', 'REF'), 0,1, null,
                                 T_REF, TRUE, FALSE, FALSE, 
                                 'ATTRGROUP_REF', 'REF', null, 
                                 JT_REFERENCE, null, null,null,null,null,
                                 null, null, '01');

        attlist(4) := xdb$insertAttr(schref, PN_ATTRGROUPREF_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := xdb$insertElement(schref, PN_ATTRGROUPREF_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);

        xdb$updateComplex(attrgroupref_t_ref, schref, null,
                       'attrGroupRefType', null, FALSE,
                       null, null, null, null, null, ellist, attlist);
        complexlist(23) := attrgroupref_t_ref;

/*--------------------------------------------------------------------------*/
/* Definition of "xdb:schema" XML element */
/*--------------------------------------------------------------------------*/

        attlist := xdb.xdb$xmltype_ref_list_t();
        attlist.extend(15);

        attlist(1) := xdb$insertAttr(schref, 68, 'schemaURL', TR_STRING, 
                                1,1,null, T_CSTRING, TRUE, FALSE, FALSE, 
                                'SCHEMA_URL',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);
        attlist(2) := xdb$insertAttr(schref, 69, 'targetNamespace', TR_STRING, 
                                0,1,null, T_CSTRING, FALSE, FALSE, FALSE, 
                                'TARGET_NAMESPACE',
                               'VARCHAR2', null, JT_STRING, null, null, null,null,null);

        attlist(3) := xdb$insertAttr(schref, 70, 'version', TR_STRING, 
                                0,1,null, T_CSTRING, FALSE, FALSE, FALSE, 
                                'VERSION', 'VARCHAR2', null, JT_STRING, null, 
                                null, null,null,null);

        attlist(4) := xdb$insertAttr(schref, 71, 'numProps', TR_NNEGINT, 
                                1,1,null, T_INTEGER, TRUE, FALSE, FALSE, 
                                'NUM_PROPS', 'INTEGER', null, JT_LONG, null, 
                                null, null,null,null);

        attlist(5) := xdb$insertAttr(schref, 72, 'finalDefault', 
                               xdb.xdb$qname('01','derivationChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'FINAL_DEFAULT','XDB$DERIVATIONCHOICE', 'XDB', 
                               JT_ENUM, null, null, drv_choice_ref,null,null);

        attlist(6) := xdb$insertAttr(schref, 73, 'blockDefault', 
                               xdb.xdb$qname('01','derivationChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'BLOCK_DEFAULT','XDB$DERIVATIONCHOICE', 'XDB',
                               JT_ENUM, null, null, drv_choice_ref,null,null);

        attlist(7) := xdb$insertAttr(schref, 74, 'attributeFormDefault', 
                               xdb.xdb$qname('01','formChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'ATTRIBUTE_FORM_DFLT', 'XDB$FORMCHOICE', 'XDB',
                               JT_ENUM, null, null, form_choice_ref,null,null);
                               
        attlist(8) := xdb$insertAttr(schref, 75, 'elementFormDefault', 
                               xdb.xdb$qname('01','formChoice'), 0, 1, 
                               '01', T_ENUM, FALSE, FALSE, FALSE, 
                               'ELEMENT_FORM_DFLT', 'XDB$FORMCHOICE', 'XDB',
                               JT_ENUM, null, null, form_choice_ref,null,null);

        attlist(9) := xdb$insertAttr(schref, 76, 'flags', TR_NNEGINT, 1, 1,
                                '4', T_UNSIGNINT, TRUE, FALSE, FALSE, 
                                'FLAGS', 'RAW', null, JT_LONG, null, 
                                null, null,null,null);

        attlist(10) := xdb$insertAttr(schref, PN_SCHEMA_MAPTONCHAR, 
                               'mapStringToNCHAR', TR_BOOLEAN, 1, 1,
                                null, T_BOOLEAN, TRUE, FALSE, FALSE, 
                                'MAP_TO_NCHAR', 'RAW', null, JT_BOOLEAN, 
                                'false', null, null,null,null);

        attlist(11) := xdb$insertAttr(schref, PN_SCHEMA_MAPTOLOB, 
                               'mapUnboundedStringToLob', TR_BOOLEAN, 1, 1,
                                null, T_BOOLEAN, TRUE, FALSE, FALSE, 
                                'MAP_TO_LOB', 'RAW', null, JT_BOOLEAN, 
                                'false', null, null,null,null);

        attlist(12) := xdb$insertAttr(schref, PN_SCHEMA_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        attlist(13) := xdb$insertAttr(schref, PN_SCHEMA_VARRAYTAB, 
                               'storeVarrayAsTable', TR_BOOLEAN, 1, 1,
                                null, T_BOOLEAN, TRUE, FALSE, FALSE, 
                                'VARRAY_AS_TAB', 'RAW', null, JT_BOOLEAN, 
                                'false', null, null,null,null);

        attlist(14) := xdb$insertAttr(schref, PN_SCHEMA_OWNER, 'schemaOwner',
                                      TR_STRING, 1,1,null, T_CSTRING, TRUE,
                                      FALSE, FALSE, 'SCHEMA_OWNER', 'VARCHAR2',
                                      null, JT_STRING, null, null, null,null,null);

        attlist(15) := xdb$insertAttr(schref, PN_SCHEMA_LANG,
                                     'lang', TR_STRING, 1, 1, null, 
                                     T_CSTRING, FALSE, FALSE, FALSE,
                                     'LANG', 'VARCHAR2', null,
                                     JT_STRING, null, null, null,null,null);

/* ---------------------- local type for "import" ------------------------ */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref, PN_IMPORT_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);
        attlist2 := xdb.xdb$xmltype_ref_list_t();
        attlist2.extend(3);
        attlist2(1) := xdb$insertAttr(schref, 77, 'namespace', TR_STRING,
                               0, 1, null, T_CSTRING, FALSE, FALSE, FALSE, 
                               'NAMESPACE', 'VARCHAR2', null, JT_STRING, null, 
                               null, null,null,null);
        attlist2(2) := xdb$insertAttr(schref, 78, 'schemaLocation', TR_STRING,
                                 0, 1, null, T_CSTRING, FALSE, FALSE, FALSE, 
                                 'SCHEMA_LOCATION', 'VARCHAR2', null, 
                                 JT_STRING, null, null, null,null,null);
        attlist2(3) := xdb$insertAttr(schref, PN_IMPORT_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ctyperef := xdb$insertComplex(schref, null, null, 
                        null, FALSE, null, '0', null, null, 
                        null, null, null, null, null, null, null, null, null,
                        null, null, null, null, ellist, attlist2);

        schels(6) := xdb$insertElement(schref, 79, 'import', null, 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'IMPORTS', 'XDB$IMPORT_T', 'XDB', 
                        JT_XMLTYPE, null, null, null,null,null, 
                null, 3, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, ctyperef, null,
                        'XDB$IMPORT_LIST_T','XDB');

/* ----------------------local  type for "include" ----------------------- */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);
        ellist(1) := xdb$insertElement(schref, PN_INCLUDE_ANNOTATION, 
                        'annotation', xdb.xdb$qname('01', 'annotation'), 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'ANNOTATION', 'XDB$ANNOTATION_T', 'XDB',        
                        JT_STRING, null, null, annotation_t_ref,null,null, 
                        null, annotation_colcount, FALSE, null, null, 
                        FALSE, FALSE, TRUE, FALSE, FALSE, 
                        null, null, null, null, FALSE, null, null, null);
        attlist2 := xdb.xdb$xmltype_ref_list_t();
        attlist2.extend(2);
        attlist2(1) := xdb$insertAttr(schref, PN_INCLUDE_SCHEMALOCATION, 
                                 'schemaLocation', TR_STRING,
                                 0, 1, null, T_CSTRING, FALSE, FALSE, FALSE, 
                                 'SCHEMA_LOCATION', 'VARCHAR2', null, 
                                 JT_STRING, null, null, null,null,null);
        attlist2(2) := xdb$insertAttr(schref, PN_INCLUDE_ID, 'id',
                                TR_STRING, 0, 1, null,
                               T_CSTRING, FALSE, FALSE, FALSE, 'ID',
                               'VARCHAR2', null, JT_STRING, null, null,
                               null,null,null);

        ctyperef := xdb$insertComplex(schref, null, null, 
                        null, FALSE, null, '0', null, null, 
                        null, null, null, null, null, null, null, null, null,
                        null, null, null, null, ellist, attlist2);

        schels(7) := xdb$insertElement(schref, 80, 'include', null, 
                        0, 1, null, T_XOB, FALSE, FALSE, FALSE, 
                        'INCLUDES', 'XDB$INCLUDE_T', 'XDB',     
                        JT_XMLTYPE, null, null, null,null,null, 
                null, 2, FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, ctyperef, null,
                        'XDB$INCLUDE_LIST_T','XDB');

        schels(8) := xdb$insertElement(schref, PN_SCHEMA_GROUP,
                        'group', xdb.xdb$qname('01','groupDefType'), 0,1,
                         null, T_XOB, FALSE, FALSE, FALSE, 'GROUPS',
                        'XDB$GROUP_DEF_T', 'XDB', JT_XMLTYPE, null, null, 
                        groupdef_t_ref,null,null,
                xdb.xdb$qname('01', 'schemaTop'), groupdef_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$GROUP_DEF', null, 'oracle.xdb.group', 
                'oracle.xdb.groupBean', TRUE, null, null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

        schels(9) := xdb$insertElement(schref, PN_SCHEMA_ATTRGROUP,
                        'attributeGroup',xdb.xdb$qname('01','attrGroupDefType'),
                        0,1, null, T_XOB, FALSE, FALSE, FALSE,'ATTRGROUPS',
                        'XDB$ATTRGROUP_DEF_T', 'XDB', JT_XMLTYPE, null, null, 
                        attrgroupdef_t_ref,null,null,
                xdb.xdb$qname('01', 'schemaTop'), attrgroupdef_colcount,
                FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                'XDB$ATTRGROUP_DEF', null, 'oracle.xdb.attributeGroup', 
                'oracle.xdb.attributeGroupBean', TRUE, null, null, null,
                        'XDB$XMLTYPE_REF_LIST_T','XDB');

        schels(10) := xdb$insertElement(schref, PN_SCHEMA_NOTATION,
                        'notation', xdb.xdb$qname('01','notation'), 0,1,
                         null, T_XOB, FALSE, FALSE, FALSE, 'NOTATIONS',
                        'XDB$NOTATION_T', 'XDB', JT_XMLTYPE, null, null, 
                        notation_t_ref,null,null, null, notation_colcount,
                FALSE, null, null, FALSE, FALSE, TRUE, TRUE, FALSE, 
                null, null, null, null, FALSE, null, null, null, 
                        'XDB$NOTATION_LIST_T','XDB');


/* ---------------------- type for "schema" -------------------------- */
        /* set up all elements occuring within "schema" element
         * Note that there are other elements within XDB schema but not 
         * legal within user schema documents e.g. schemaTop, binary
         */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(10);
        ellist(1) := schels(1);
        ellist(2) := schels(2);
        ellist(3) := schels(3);
        ellist(4) := schels(4);
        ellist(5) := schels(5);
        ellist(6) := schels(6);
        ellist(7) := schels(7);
        ellist(8) := schels(8);
        ellist(9) := schels(9);
        ellist(10) := schels(10);

        /* insert a choice */
        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb$insertChoice(schref, ellist);
        ctyperef := xdb$insertComplex(schref, null, 'schema', 
                                null, FALSE, null,'0',
                       null, null, null, null, null, null, null, null, null,
                       null, null,
                         null, null, null, null, ellist, attlist,
                         null, FALSE, choice_list(1));
        complexlist(19) := ctyperef;

        element_propnum := 81;
        select attributes into colcount from all_types
                where type_name in ('XDB$SCHEMA_T') and owner = 'XDB';
        schels(11) := xdb$insertElement(schref, element_propnum, 
                        'schema', xdb.xdb$qname('01','schema'), 
                        0, null, null, T_XOB, 
                        FALSE, FALSE, FALSE, null, 'XDB$SCHEMA_T', 'XDB', 
                         JT_XMLTYPE, null, null, ctyperef,null,null, 
                null, colcount, FALSE, null, null, 
                FALSE, FALSE, FALSE, FALSE, TRUE, 
                'XDB$SCHEMA', null, 'oracle.xdb.Schema', 
                'oracle.xdb.SchemaBean', TRUE, null, null, null);

        /* Handle all of the substitution groups for schemaTop - why do we need this element at all ??? */
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(4);
        ellist(1) := schels(2);
        ellist(2) := schels(3);
        ellist(3) := schels(4);
        ellist(4) := schels(5);

        schels(12) := xdb$insertElement(schref, 82, 'schemaTop', 
                                xdb.xdb$qname('00', 'string'),
                                0, null, null, T_CSTRING, FALSE, FALSE, 
                                FALSE, null, null,null,null,null, null,null,null,null, 
                null, 0, FALSE, null, null, TRUE, TRUE, TRUE, TRUE, FALSE, 
                null, null, null, null, TRUE, null, null, null);

        schels(13) := xdb$insertElement(schref, 83, 'binary', TR_BINARY,
                                0, null, null, T_BLOB, FALSE, FALSE, 
                                FALSE, null, null,null,JT_STREAM,
                                null, null,null,null,null, 
                null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                null, null, null, null, TRUE, null, null, null);

        schels(14) := xdb$insertElement(schref, 269, 'text', TR_STRING,
                                0, null, null, T_CLOB, FALSE, FALSE, 
                                FALSE, null, null,null,JT_STREAM,
                                null, null,null,null,null, 
                null, 0, FALSE, null, null, FALSE, FALSE, FALSE, FALSE, FALSE, 
                null, null, null, null, TRUE, null, null, null);

        /* Update schema to have all toplevel property definitions */
        execute immediate 'update xdb.xdb$schema s set 
                s.xmldata.elements = :1, 
                s.xmldata.simple_type = :2, 
                s.xmldata.complex_types = :3,
                s.xmldata.num_props = :4 
               where s.xmldata.schema_url = 
               ''http://xmlns.oracle.com/xdb/XDBSchema.xsd'''
                using schels, simplelist, complexlist, PN_TOTAL_PROPNUMS;

end;

END;
/
show errors

Rem Function that creates the database schema object corr. to the root
Rem XDB schema.
create or replace procedure xdb.xdb$InitXDBSchema
 is language C name "INIT_XDBSCHEMA"
 library XMLSCHEMA_LIB;
/

Rem Function that converts an external schema name (URL) to
Rem the internal representation (XDxxxx). An optional schema owner
Rem name can be passed in. Of course, the executing user needs to
Rem have permissions to read the path corresponding to the URL.
create or replace function xdb.xdb$ExtName2IntName
  (schemaURL IN VARCHAR2, schemaOwner IN VARCHAR2 := '')
return varchar2 authid current_user deterministic
is external name "EXT2INT_NAME" library XMLSCHEMA_LIB with context
parameters (context, schemaURL OCIString, schemaOwner OCIString,
            return INDICATOR sb4, return OCIString);
/

grant execute on xdb.xdb$ExtName2IntName to public;
grant execute on xdb.xdb$bootstrap to public;

/* ----------------------  INVOKE BOOTSTRAP DRIVER -------------------*/

begin
  xdb.xdb$bootstrap.driver();
  xdb.xdb$InitXDBSchema();
  commit;       
end;
/
