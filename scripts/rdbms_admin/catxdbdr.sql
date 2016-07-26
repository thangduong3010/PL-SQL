Rem
Rem $Header: rdbms/admin/catxdbdr.sql /main/27 2010/03/16 12:15:55 vhosur Exp $
Rem
Rem catxdbdr.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbdr.sql -XDB initialization Data for Resource type
Rem
Rem    DESCRIPTION
Rem      Initialization data (schema for resource) for XDB.
Rem
Rem    NOTES
Rem      Property numbers for resources start at 701.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vhosur      01/16/10 - Fix for bug 9014297
Rem    vhosur      01/04/10 - Fix bug 4259338
Rem    ataracha    10/29/09 - make IsXMLIndexed unmutable
Rem    thbaby      05/11/06 - add IsXMLIndexed Resource attribute
Rem    pnath       03/05/06 - add res attr HasUnresolvedLinks 
Rem    spannala    08/13/04 - changing contents copy type to hexbinary 
Rem    spannala    06/28/04 - adding columns for attrcopy, contents copy 
Rem    najain      05/13/04 - add snapshot
Rem    thbaby      01/24/06 - make versioning-related attributes hidden 
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade
Rem    ataracha    04/20/04 - Make OIDList inlined
Rem    thoang      09/23/03 - Add RCList element 
Rem    smalde      05/26/05 - Add Content Size
Rem    spannala    08/13/04 - changing contents copy type to hexbinary 
Rem    spannala    06/28/04 - adding columns for attrcopy, contents copy 
Rem    najain      05/13/04 - add snapshot
Rem    rmurthy     02/17/05 - populate namespace array 
Rem    pnath       01/19/05 - make Locks top level 
Rem    pnath       10/05/04 - Introducing Locks element in Resource schema 
Rem    abagrawa    02/10/04 - Add SBResExtra 
Rem    najain      08/11/03 - add HierSchmBasedRes property
Rem    njalali     01/06/03 - making some props read-only
Rem    abagrawa    01/15/03 - Update insertSimple usage
Rem    najain      07/23/02 - sticky ref support
Rem    rmurthy     06/28/02 - change memtype from XOBD to XOB
Rem    mkrishna    04/03/02 - fix catxdbdr for XMLLob
Rem    rmurthy     03/15/02 - change to xdb$schema_t constructor
Rem    njalali     02/13/02 - adding boolan property VersionHistory
Rem    mkrishna    01/29/02 - fix xdb$resource to be non-PD
Rem    mkrishna    01/28/02 - fix xdb$resource to have ##other namespace
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    njalali     12/19/01 - making versionid and activityid sb4''s
Rem    njalali     12/04/01 - transient properties
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    rmurthy     11/21/01 - specify sql colltype names
Rem    sichandr    11/28/01 - set global flag in bootstrap schemas
Rem    sichandr    10/31/01 - add ID attribute
Rem    nmontoya    11/02/01 - setting max namelen to 4000 for LDAP
Rem    njalali     10/27/01 - using timestamp
Rem    njalali     10/26/01 - changing to date
Rem    nle         10/05/01 - versioning
Rem    nagarwal    08/28/01 - add version attrs
Rem    njalali     10/25/01 - using GUIDs instead of kusr
Rem    njalali     09/26/01 - propagating H_INDEX flags to resource
Rem    sichandr    09/18/01 - support storeVarrayAsTable
Rem    rmurthy     08/26/01 - add support for substitutionGroup, named group
Rem    njalali     08/01/01 - changed ANY types
Rem    rmurthy     08/10/01 - change XDB namespace
Rem    njalali     07/29/01 - Merged njalali_xmlres2
Rem    njalali     07/19/01 - added versatile ANY element
Rem    njalali     07/02/01 - Created
Rem


create or replace package xdb.xdb$bootstrapres as
        PN_RES_HIDDEN           CONSTANT INTEGER := 705;
        PN_RES_INVALID          CONSTANT INTEGER := 706;
        PN_RES_VERSIONID        CONSTANT INTEGER := 707;
        PN_RES_ACTIVITYID       CONSTANT INTEGER := 708;
        PN_RES_CREDAT           CONSTANT INTEGER := 709;
        PN_RES_MODDAT           CONSTANT INTEGER := 710;
        PN_RES_AUTHOR           CONSTANT INTEGER := 711;
        PN_RES_DISPNAME         CONSTANT INTEGER := 712;
        PN_RES_RESCOMMENT       CONSTANT INTEGER := 713;
        PN_RES_LANGUAGE         CONSTANT INTEGER := 714;
        PN_RES_CHARSET          CONSTANT INTEGER := 715;
        PN_RES_CONTYPE          CONSTANT INTEGER := 716;
        PN_RES_REFCOUNT         CONSTANT INTEGER := 717;
        PN_RES_LOCKS            CONSTANT INTEGER := 718;
        PN_RES_ACLOID           CONSTANT INTEGER := 719;
        PN_RES_OWNER            CONSTANT INTEGER := 720;
        PN_RES_OWNERID          CONSTANT INTEGER := 721;
        PN_RES_CREATOR          CONSTANT INTEGER := 722;
        PN_RES_CREATORID        CONSTANT INTEGER := 723;
        PN_RES_LASTMODIFIER     CONSTANT INTEGER := 724;
        PN_RES_LASTMODIFIERID   CONSTANT INTEGER := 725;
        PN_RES_SCHELEM          CONSTANT INTEGER := 726;
        PN_RES_ELNUM            CONSTANT INTEGER := 727;
        PN_RES_SCHOID           CONSTANT INTEGER := 728;
        PN_RES_XMLREF           CONSTANT INTEGER := 729;
        PN_RES_XMLLOB           CONSTANT INTEGER := 730;
        PN_RES_FLAGS            CONSTANT INTEGER := 731;
        PN_RES_ACL              CONSTANT INTEGER := 732;
        PN_RES_CONTENTS         CONSTANT INTEGER := 733;
        PN_RES_RESOURCE         CONSTANT INTEGER := 734;
        PN_RES_RESEXTRA         CONSTANT INTEGER := 735;
        PN_RES_CONTENTS_ANY     CONSTANT INTEGER := 736;
        PN_RES_ACL_ANY          CONSTANT INTEGER := 737;
        PN_RES_CONTAINER        CONSTANT INTEGER := 738;
        PN_RES_CUSTRSLV         CONSTANT INTEGER := 739;
        PN_RES_VCRUID           CONSTANT INTEGER := 740;
        PN_RES_PARENTS          CONSTANT INTEGER := 741;
        PN_RES_VERHIS           CONSTANT INTEGER := 742;
        PN_RES_STICKYREF        CONSTANT INTEGER := 743;
        PN_RES_HIERSCHMRES      CONSTANT INTEGER := 744;
        PN_RES_SBRESEXTRA       CONSTANT INTEGER := 745;
        PN_RES_SNAPSHOT         CONSTANT INTEGER := 746;
        PN_RES_ATTRCOPY         CONSTANT INTEGER := 747;
        PN_RES_ATTRCOPY_ANY     CONSTANT INTEGER := 748;
        PN_RES_CTSCOPY          CONSTANT INTEGER := 749;
        PN_RES_NODENUM          CONSTANT INTEGER := 750;
        PN_RES_CONTENTSIZE      CONSTANT INTEGER := 751;
	PN_RES_SIZEONDISK       CONSTANT INTEGER := 752;
	PN_RES_SIZEACCURATE     CONSTANT INTEGER := 753;
        PN_RES_RCLIST           CONSTANT INTEGER := 754;
        PN_RES_OID_LIST         CONSTANT INTEGER := 755;
        PN_RES_ISVERSIONABLE    CONSTANT INTEGER := 756;
        PN_RES_ISCHECKEDOUT     CONSTANT INTEGER := 757;
        PN_RES_ISVERSION        CONSTANT INTEGER := 758;
        PN_RES_ISVCR            CONSTANT INTEGER := 759;
        PN_RES_ISVERSIONHISTORY CONSTANT INTEGER := 760;
        PN_RES_ISWORKSPACE      CONSTANT INTEGER := 761;
        PN_RES_BRANCH           CONSTANT INTEGER := 762;
        PN_RES_CHECKEDOUTBY     CONSTANT INTEGER := 763;
        PN_RES_CHECKEDOUTBYID   CONSTANT INTEGER := 764;
        PN_RES_BASEVERSION      CONSTANT INTEGER := 765;
        PN_RES_RESLOCKS         CONSTANT INTEGER := 766;
        PN_RES_LOCK             CONSTANT INTEGER := 767;
        PN_RES_LOCKOWNER        CONSTANT INTEGER := 768;
        PN_RES_LOCKMODE         CONSTANT INTEGER := 769;
        PN_RES_LOCKTYPE         CONSTANT INTEGER := 770;
        PN_RES_LOCKDEPTH        CONSTANT INTEGER := 771;
        PN_RES_LOCKEXPIRY       CONSTANT INTEGER := 772;
        PN_RES_LOCKTOKEN        CONSTANT INTEGER := 773;
        PN_RES_LOCKNODEID       CONSTANT INTEGER := 774;
      	PN_RES_RESLOCKS_TOPELT  CONSTANT INTEGER := 775;
        PN_RES_HASUNRES         CONSTANT INTEGER := 776;
        PN_RES_ISXMLINDEXED     CONSTANT INTEGER := 777;

        /* When adding new property change the value of PN_RES_MAX_PROP */ 

        PN_RES_MIN_PROP         CONSTANT INTEGER := PN_RES_HIDDEN;
        PN_RES_MAX_PROP         CONSTANT INTEGER := PN_RES_ISXMLINDEXED;
        PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 1 + 
                                       PN_RES_MAX_PROP - PN_RES_MIN_PROP;
        FALSE        CONSTANT RAW(1) := '0';
        TRUE         CONSTANT RAW(1) := '1';

        procedure driver;
end;
/
show errors


create or replace package body xdb.xdb$bootstrapres is

procedure driver is
        choice_list     xdb.xdb$xmltype_ref_list_t;
        ellist          xdb.xdb$xmltype_ref_list_t;
        choice_ellist   xdb.xdb$xmltype_ref_list_t;
        simplelist      xdb.xdb$xmltype_ref_list_t;
        complexlist     xdb.xdb$xmltype_ref_list_t;
        schels          xdb.xdb$xmltype_ref_list_t;
        attlist         xdb.xdb$xmltype_ref_list_t;
        anylist         xdb.xdb$xmltype_ref_list_t;
        schref          ref sys.xmltype;
        oraclename_ref  ref sys.xmltype;
        resmetastr_ref  ref sys.xmltype;
        schelemtype_ref ref sys.xmltype;
        guid_ref        ref sys.xmltype;
        locksraw_ref    ref sys.xmltype;
        conttype_ref    ref sys.xmltype;
        attrcopytype_ref    ref sys.xmltype;
        acltype_ref     ref sys.xmltype;
        resource_ref    ref sys.xmltype;
        rcltype_ref     ref sys.xmltype;
        schema_i        xdb.xdb$schema_t;
	extras_i        sys.xmltypeextra;
        res_colcount    integer;
        lockmodetype_ref  ref sys.xmltype;
        locktypetype_ref  ref sys.xmltype;
        lockdepthtype_ref   ref sys.xmltype;
        lockcomponentseq_ref  ref sys.xmltype;
        lockseq_ref   ref sys.xmltype;
        lock_ref      ref sys.xmltype;
        locktype_ref  ref sys.xmltype; 
        lockstype_ref   ref sys.xmltype;
        toplocksel_ref  ref sys.xmltype;
       
BEGIN
        schema_i := xdb.xdb$schema_t('http://xmlns.oracle.com/xdb/XDBResource.xsd',
              'http://xmlns.oracle.com/xdb/XDBResource.xsd',
              '1.0', 0, null, null, XDB$BOOTSTRAP.FC_QUAL, null, null, null, null, null,
              null, null, '17', null, null, FALSE, FALSE, null, null,
              null, FALSE, 'XDB',null,null);

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
                using '8758D485E6004793E034080020B242C6', extras_i, schema_i
                returning into schref;

        /* VARRAY tracking top-level schema elements */
        schels := xdb.xdb$xmltype_ref_list_t();
        schels.extend(2);

        simplelist := xdb.xdb$xmltype_ref_list_t();
        simplelist.extend(8);

        complexlist := xdb.xdb$xmltype_ref_list_t();
        complexlist.extend(7);

        select attributes into res_colcount from all_types
                where type_name in ('XDB$RESOURCE_T') and owner = 'XDB';

/*--------------------------------------------------------------------------*/
/* Simple type definition for "OracleUserName"                              */
/*--------------------------------------------------------------------------*/

        /* LDAP users require a 4000-byte maximum length */
        oraclename_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'OracleUserName', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0',null, null, 
               1, 4000, null, null, null, null, null, null, null);

        simplelist(1) := oraclename_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "ResMetaStr"                                  */
/*--------------------------------------------------------------------------*/

        resmetastr_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'ResMetaStr', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               1, 128, null, null, null, null, null, null, null);

        simplelist(2) := resmetastr_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "SchElemType"                                 */
/*--------------------------------------------------------------------------*/

        schelemtype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'SchElemType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               1, 4000, null, null, null, null, null, null, null);

        simplelist(3) := schelemtype_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "GUID"                                        */
/*--------------------------------------------------------------------------*/

        /*
         * DB users will continue to be stored as KUSRs (4 bytes), whereas
         * LDAP users will be stored as GUIDs (16 bytes).  Doubling these
         * values for hexBinary output, we end up with a range of 8 to 32
         * characters for this simpletype.  We use hexBinary because it 
         * makes it easier to cut-and-paste OIDs into SQL*Plus.
         */
        guid_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, null, 'GUID', 
               xdb.xdb$BOOTSTRAP.TR_BINARY,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               8, 32, null, null, null, null, null, null, null);

        simplelist(4) := guid_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "LocksRaw"                                    */
/*--------------------------------------------------------------------------*/

        locksraw_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, null, 
               'LocksRaw', xdb.xdb$BOOTSTRAP.TR_BINARY,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               0, 2000, null, null, null, null, null, null, null);

        simplelist(5) := locksraw_ref;


/*-------------------------------------------------------------*/
/*                       Locks element starts                  */
/*-------------------------------------------------------------*/

        lockmodetype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'lockModeType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               null, null, null, null, null, null, null, null, 
               xdb.xdb$enum_values_t('exclusive', 'shared'));

        simplelist(6) := lockmodetype_ref;
        locktypetype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'lockTypeType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               null, null, null, null, null, null, null, null, 
               xdb.xdb$enum_values_t('read-write', 'write', 'read'));
        simplelist(7) := locktypetype_ref;
        
        lockdepthtype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'lockDepthType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               null, null, null, null, null, null, null, null, 
                xdb.xdb$enum_values_t('0', 'infinity'));
        simplelist(8) := lockdepthtype_ref;


        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(5);

        ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKOWNER,
                      'LockOwner',  xdb.xdb$BOOTSTRAP.TR_STRING,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, TRUE, FALSE, 
                      null,null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);




        ellist(2) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKMODE,
                      'Mode', xdb.xdb$qname('01', 'lockModeType'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      lockmodetype_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);


        ellist(3) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKTYPE,
                      'Type', xdb.xdb$qname('01', 'lockTypeType'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      locktypetype_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);


        ellist(4) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKDEPTH,
                      'Depth', xdb.xdb$qname('01', 'lockDepthType'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      lockdepthtype_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);



        ellist(5) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKEXPIRY,
                      'Expiry', xdb.xdb$qname('00', 'dateTime'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);



        choice_ellist := xdb.xdb$xmltype_ref_list_t();
        choice_ellist.extend(2);
         choice_ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKTOKEN,
                      'Token', xdb.xdb$BOOTSTRAP.TR_STRING,
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING, FALSE, 
                      TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

        choice_ellist(2) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LOCKNODEID,
                      'NodeId',  xdb.xdb$BOOTSTRAP.TR_STRING,
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

        choice_list := xdb.xdb$xmltype_ref_list_t();
        choice_list.extend(1);
        choice_list(1) := xdb.xdb$bootstrap.xdb$insertChoice(schref, 
                          choice_ellist);


        lockcomponentseq_ref := xdb.xdb$bootstrap.xdb$insertSequence(schref,
                                ellist, null, choice_list);

        locktype_ref := xdb.xdb$bootstrap.xdb$insertEmptyComplex();
         xdb.xdb$bootstrap.xdb$updateComplex(locktype_ref, schref, null,
                       'lockType', null, FALSE,
                       null, null, null, null, null, null, null, 
                       lockcomponentseq_ref);

        complexlist(1) := locktype_ref;

--making lock element from lock complex type
         lock_ref := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCK,
                                       'Lock',
                                       xdb.xdb$qname('01', 'lockType'), 
                                       0, 2147483647, null, 
                                       xdb.xdb$BOOTSTRAP.T_XOB, FALSE, 
                                       TRUE, FALSE,
                                       null, null, null,
                                       xdb.xdb$BOOTSTRAP.JT_XMLTYPE,
                                       null, null, locktype_ref,
                                       null,null,
                                       null,null,  
                                       FALSE, null, null, FALSE, TRUE,
                                       TRUE, FALSE, FALSE, 
                                       null, null,
                                       null, 
                                       null,
                                       FALSE, null, null, null,
                                       null, null, null, null, null);

-- making sequence model with only 1 element in the array (lock element) 
        ellist := xdb.xdb$xmltype_ref_list_t();
        ellist.extend(1);

        ellist(1) := lock_ref;

        lockseq_ref    := xdb.xdb$bootstrap.xdb$insertSequence(schref, ellist,
                          null, null);

        lockstype_ref := xdb.xdb$bootstrap.xdb$insertEmptyComplex();
         xdb.xdb$bootstrap.xdb$updateComplex(lockstype_ref, schref, null,
                       'locksType', null, FALSE,
                       null, null, null, null, null, null, null, lockseq_ref);

        complexlist(2) := lockstype_ref;

/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResContentsType"                            */
/*--------------------------------------------------------------------------*/


      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_CONTENTS_ANY,
                                  'ContentsAny', null, null, 0, 1, null, 
                                  xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                  null, null, null,
                                  xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                  null, null, null, null);

     conttype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'ResContentsType', null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null,
                          anylist);
     complexlist(3) := conttype_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResAclType"                                 */
/*--------------------------------------------------------------------------*/


      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_ACL_ANY,
                                  'ACLAny', null, null, 0, 1, null, 
                                  xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                  null, null, null,
                                  xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                  null, null, null, null);

     acltype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'ResAclType', null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null,
                          anylist);
     complexlist(4) := acltype_ref;


/* Top Level Locks Element */
     toplocksel_ref := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_RESLOCKS_TOPELT,
                      'Locks', xdb.xdb$qname('01', 'locksType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null,
                       lockstype_ref,null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null,null, null, FALSE, null ,null,null,
                      null, null, FALSE,
                      null, null);

/*--------------------------------------------------------------------------*/
/* Complex type definition for "AttrCopyType"                               */
/*--------------------------------------------------------------------------*/


      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_ATTRCOPY_ANY,
                                  'AttrCopyAny', null, null, 0, 65535, null, 
                                  xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                  null, null, null,
                                  xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                  null, null, null, null);

     attrcopytype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'AttrCopyType', null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null,
                          anylist);
     complexlist(5) := attrcopytype_ref;

/*--------------------------------------------------------------------------*/
/* Complex type definition for "RCList" */
/*--------------------------------------------------------------------------*/

     ellist := xdb.xdb$xmltype_ref_list_t();
     ellist.extend(1);

     ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_OID_LIST,
                      'OID', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 65535, '16', xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 'OID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null,
                      null, 1, FALSE, null, null,
                      FALSE, TRUE, TRUE, FALSE, FALSE,
                      null, null, null, null, FALSE, null, null, null, 
                      'XDB$OID_LIST_T', 'XDB', FALSE, null);

     rcltype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'RCListType',
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, null,
                          null);
     complexlist(6) := rcltype_ref;

/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResourceType" */
/*--------------------------------------------------------------------------*/

      attlist := xdb.xdb$xmltype_ref_list_t();
      attlist.extend(18);

      attlist(1) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_HIDDEN, 'Hidden', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(2) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_INVALID, 'Invalid', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(3) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_VERSIONID, 'VersionID', 
                               xdb.xdb$BOOTSTRAP.TR_INT, 0, 1, 
                               '4', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, 
                               FALSE, FALSE, 
                               'VERSIONID', 'INTEGER', null,
                               xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                               null, null, null);

      attlist(4) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ACTIVITYID, 'ActivityID',
                               xdb.xdb$BOOTSTRAP.TR_INT, 0, 1, 
                               '4', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, 
                               FALSE, FALSE, 
                               'ACTIVITYID', 'INTEGER', null,
                               xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                               null, null, null);

      attlist(5) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_CONTAINER, 'Container',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               TRUE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(6) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_CUSTRSLV, 'CustomRslv', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(7) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_VERHIS, 'VersionHistory', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(8) := xdb.xdb$bootstrap.xdb$insertAttr(schref,
                               PN_RES_STICKYREF, 'StickyRef',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1,
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE,
                               FALSE, FALSE,
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null,
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(9) := xdb.xdb$bootstrap.xdb$insertAttr(schref,
                               PN_RES_HIERSCHMRES, 'HierSchmResource',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1,
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE,
                               FALSE, FALSE,
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null,
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(10):= xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_SIZEACCURATE, 'SizeAccurate',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 0, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(11) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISVERSIONABLE, 'IsVersionable', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(12) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISCHECKEDOUT, 'IsCheckedOut', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(13) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISVERSION, 'IsVersion', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(14) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISVCR, 'IsVCR', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

       attlist(15) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISVERSIONHISTORY, 'IsVersionHistory', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

       attlist(16) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISWORKSPACE, 'IsWorkspace', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

       attlist(17) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_HASUNRES, 'HasUnresolvedLinks', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(18) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ISXMLINDEXED, 'IsXMLIndexed', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               TRUE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist := xdb.xdb$xmltype_ref_list_t();
      ellist.extend(40);

      ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREDAT,
                      'CreationDate', xdb.xdb$qname('00', 'dateTime'), 1, 1,
                      null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP, FALSE, FALSE, FALSE, 
                      'CREATIONDATE', 'TIMESTAMP', null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null,
                      null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(2) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_MODDAT,
                      'ModificationDate', xdb.xdb$qname('00', 'dateTime'), 1, 1,
                      null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP, FALSE, FALSE, FALSE, 
                      'MODIFICATIONDATE', 'TIMESTAMP', null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null,
                      null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(3) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_AUTHOR,
                      'Author', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'AUTHOR', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(4) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_DISPNAME,
                      'DisplayName', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'DISPNAME', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(5) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_RESCOMMENT,
                      'Comment', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'RESCOMMENT', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(6) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LANGUAGE,
                      'Language', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'LANGUAGE', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, 'en', null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(7) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CHARSET,
                      'CharacterSet', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'CHARSET', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(8) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CONTYPE,
                      'ContentType', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'CONTYPE', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(9) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_REFCOUNT,
                      'RefCount', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_UNSIGNINT,
                      FALSE, TRUE, FALSE, 
                      'REFCOUNT', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(10) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKS,
                      'LockBuf',  xdb.xdb$qname('01', 'LocksRaw'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, TRUE, FALSE, 
                      'LOCKS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, locksraw_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(11) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ACL,
                      'ACL', xdb.xdb$qname('01', 'ResAclType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, acltype_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, null, null,
                      'oracle.xdb.ResAclType', 
                      'oracle.xdb.ResAclTypeBean', 
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(12) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ACLOID,
                      'ACLOID', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'ACLOID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(13) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_OWNER,
                      'Owner', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(14) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_OWNERID,
                      'OwnerID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'OWNERID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(15) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREATOR,
                      'Creator', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(16) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREATORID,
                      'CreatorID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'CREATORID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(17) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LASTMODIFIER,
                      'LastModifier', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(18) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LASTMODIFIERID,
                      'LastModifierID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'LASTMODIFIERID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(19) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SCHELEM,
                      'SchemaElement', xdb.xdb$qname('01', 'SchElemType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      schelemtype_ref, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, FALSE,
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(20) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ELNUM,
                      'ElNum', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_INTEGER,
                      FALSE, FALSE, FALSE, 
                      'ELNUM', 'INTEGER', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, TRUE);

      ellist(21) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SCHOID,
                      'SchOID', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'SCHOID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(22) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CONTENTS,
                      'Contents', xdb.xdb$qname('01', 'ResContentsType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, conttype_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, null, null,
                      'oracle.xdb.ResContentsType', 
                      'oracle.xdb.ResContentsTypeBean', 
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_MANIFESTED, FALSE);

      ellist(23) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_XMLREF,
                      'XMLRef', xdb.xdb$qname('00', 'REF'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_REF, FALSE, TRUE, FALSE, 
                      'XMLREF', 'REF', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, 
                      null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      null, null, TRUE, null, FALSE);

      ellist(24) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_XMLLOB,
                      'XMLLob', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      0, 1, null, '71',
                      FALSE, TRUE, FALSE, 
                      'XMLLOB', 'BLOB', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, FALSE);

      ellist(25) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_FLAGS,
                      'Flags', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_INTEGER,
                      FALSE, TRUE, FALSE, 
                      'FLAGS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      null, null, TRUE, null, TRUE);

      ellist(26) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_VCRUID,
                      'VCRUID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'VCRUID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null);

      ellist(27) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_PARENTS, 
                      'Parents', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      0, 1000,null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'PARENTS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, null,
                      null, null, null, 0, FALSE, null, null,
                      FALSE, FALSE, TRUE, FALSE, FALSE,
                      null, null, null, null,
                      FALSE, null, null, null, 'XDB$PREDECESSOR_LIST_T','XDB');

      ellist(28) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SBRESEXTRA,
                      'SBResExtra', xdb.xdb$qname('00', 'REF'),
                      0, 2147483647, null, xdb.xdb$BOOTSTRAP.T_REF, FALSE, TRUE, 
                      FALSE, 'SBRESEXTRA', 'REF', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, 
                      null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      'XDB$XMLTYPE_REF_LIST_T', 'XDB', TRUE, null, FALSE);
      ellist(29) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SNAPSHOT,
                      'Snapshot', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, TRUE, FALSE, 
                      'SNAPSHOT', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null, 
		      null, null, null, 0, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, TRUE);

      ellist(30) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ATTRCOPY,
               'AttrCopy', xdb.xdb$qname('01', 'AttrCopyType'),
               0, /* minoccurs */
               1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, TRUE, /* mutable */
               FALSE, 'ATTRCOPY', 'BLOB', null,
               xdb.xdb$BOOTSTRAP.JT_XMLTYPE, /* java_type */
               null, null, attrcopytype_ref, null, null,  /* propref_ref */
               null, 0, FALSE, null, null,  /* block */
               FALSE, FALSE, TRUE, FALSE, FALSE,/* maintain_dom */
               null, null, null, null, FALSE,  /* global */
               null, null, null, null, null, /* sqlcollschema */
               TRUE, null, TRUE);

      ellist(31) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CTSCOPY,
                      'CtsCopy', xdb.xdb$BOOTSTRAP.TR_BINARY, 0, 1, null, '71',
                      FALSE, TRUE, FALSE, 'CTSCOPY', 'BLOB', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, null, null,
                      null, null, 1, FALSE, null, null, FALSE, FALSE, TRUE,
                      FALSE, FALSE, null, null, null, null, FALSE, null, null,
                      null, null, null, TRUE, null, FALSE);


      ellist(32) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_NODENUM,
                      'NodeNum', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, TRUE, FALSE, 
                      'NODENUM', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null, 
		      null, null, null, 0, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, TRUE);

      ellist(33) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CONTENTSIZE,
                      'ContentSize', xdb.xdb$BOOTSTRAP.TR_INT,
                      0, 1, '8', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, FALSE,
                      FALSE, null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                      null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, 
                      FALSE, null, null, null, null, null, TRUE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(34) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SIZEONDISK,
                      'SizeOnDisk', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      0, 1, '8', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, FALSE,
                      FALSE, 'SIZEONDISK', 'INTEGER', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                      null, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, 
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(35) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_RCLIST,
                      'RCList', xdb.xdb$qname('01', 'RCListType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, 
                      FALSE, 'RCLIST', 'XDB$RCLIST_T', 'XDB',
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, 
                      rcltype_ref, null, null, null, 
                      1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      FALSE, null, 'oracle.xdb.RCList', 
                      'oracle.xdb.RCListBean', TRUE, null, null, null,
                      null, null, TRUE, null, TRUE);
       
        ellist(36) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_BRANCH,
                      'Branch', xdb.xdb$BOOTSTRAP.TR_STRING,
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'BRANCH', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

        ellist(37) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_CHECKEDOUTBY,
                      'CheckedOutBy', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(38) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_CHECKEDOUTBYID,
                      'CheckedOutByID', xdb.xdb$qname('01', 'GUID'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'CHECKEDOUTBYID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(39) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_BASEVERSION,
                      'BaseVersion', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'BASEVERSION', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, null, FALSE);

        
      ellist(40) := xdb.xdb$bootstrap.xdb$insertElement(schref,
                      PN_RES_RESLOCKS,
                      'Locks', xdb.xdb$qname('01', 'locksType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB,
                      FALSE, TRUE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null,
                      lockstype_ref,null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null,null, null, FALSE, null ,null,null,
                      null, null, TRUE,
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, null);

      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_RESEXTRA,
                                'ResExtra', null, '##other', 0, 65535, null, 
                                xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                'RESEXTRA', 'CLOB', null,
                                xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                null, null, null, null);

     resource_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, 
                          null, 'ResourceType',
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist,
                          anylist);
     complexlist(7) := resource_ref;

/*--------------------------------------------------------------------------*/
/* "Resource" top-level element */
/*--------------------------------------------------------------------------*/

     schels(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_RESOURCE,
                'Resource', xdb.xdb$qname('01', 'ResourceType'),
                 1, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, 
                 FALSE, 'RESOURCE', 'XDB$RESOURCE_T', 'XDB', 
                 xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, 
                 resource_ref, null, null, null,
                 res_colcount, FALSE, null, null, 
                 FALSE, FALSE, FALSE, FALSE, FALSE,
                'XDB$RESOURCE', null, 'oracle.xdb.Resource', 
                'oracle.xdb.ResourceBean', TRUE, null, null, null);
     schels(2) := toplocksel_ref;

/*--------------------------------------------------------------------------*/
/* Update schema to have all top-level property definitions */
/*--------------------------------------------------------------------------*/

        execute immediate 'update xdb.xdb$schema s set 
                s.xmldata.elements = :1, 
                s.xmldata.simple_type = :2, 
                s.xmldata.complex_types = :3,
                s.xmldata.num_props = :4 
               where s.xmldata.schema_url = 
               ''http://xmlns.oracle.com/xdb/XDBResource.xsd'''
                using schels, simplelist, complexlist, PN_RES_TOTAL_PROPNUMS;

end;

END;
/
show errors


/***** KGL initialization is invoked internally ******/

/* -------------  INVOKE BOOTSTRAP DRIVER FOR RESOURCE SCHEMA -------------- */

begin
  xdb.xdb$bootstrapres.driver();
  commit;       
end;
/

