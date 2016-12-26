Rem
Rem $Header: rdbms/admin/catexp.sql /st_rdbms_11.2.0/4 2013/07/07 09:03:20 mjungerm Exp $ expvew.sql
Rem
Rem Copyright (c) 1987, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATEXP81.SQL - CATalog EXPort/import sql script
Rem  FUNCTION
Rem    Creates internal views for Export/Import utility
Rem  NOTES
Rem    Must be run when connected to SYS or INTERNAL.
Rem
Rem    This file is organized into 3 sections:
Rem     Section 1: Views needed by BOTH export and import
Rem     Section 2: Views required by import ONLY
Rem     Section 3: Views required by export ONLY
Rem
Rem     Import does not currently require any views of its own. The views
Rem     used by both tools are moved to the top so that a user doing an import
Rem     only has to run part of this file. Since there are common views
Rem     a separate file called catimp.sql was not created for now for
Rem     maintenance reasons.
Rem
Rem     No views depend on catalog.sql. This script can be run standalone.
Rem
Rem
Rem  MODIFIED
Rem     mjangir    02/02/12 - bug 13482990
Rem     apfwkr     07/02/12 - Backport jibyun_bug-9524209 from main
Rem     tbhukya    19/04/10 - Bug 9595499: Get fragflags for sub partiton 
Rem                           lob columns
Rem     mjangir    11/12/09 - do not export the jobs owns by sys if exporting
Rem                           by other than sys user
Rem     mjangir    10/28/09 - bug 8982033: restrict password access
Rem                           EXP_FULL_DATABASE
Rem     tbhukya    08/25/09 - Bug 8833245: remove deferred storage segment 
Rem                                        check from view exu10tabs
Rem     tbhukya    07/13/09 - Bug 8679246: use to_char for password_date 
Rem                                        in exu8phs
Rem     tbhukya    05/08/09 - Bug 8467693: use col# also
Rem     ebatbout   04/09/09 - bug 8397778: Prefix session_roles with SYS
Rem     adalee     03/06/09 - new cachehint
Rem     mjangir    12/10/08 - bug 7632440: add support for VPD policies with
Rem                           sstatement_type of "INDEX
Rem     mjangir    11/20/08 - bug 7568350: Policy type changed
Rem     tbhukya    10/06/08 - Bug 7422758 : Add imp9synu
Rem     mjangir    07/28/08 - bug 6936881: ORA-01436: CONNECT BY loop 
Rem     msakayed   05/12/08 - Lrg #3390108: fix exu8dir view
Rem     dsemler    02/29/08 - update to exclude APPQOSSYS user
Rem     mjangir    02/04/08 - 6119138: grant to exp_full_db instead of
Rem                           select_catalog_role for exu8phs
Rem     mjangir    09/11/07 - XbranchMerge mjangir_bug-5872788_10.2.0.4 from
Rem                           st_rdbms_10.2
Rem     mjangir    06/07/07 - bug 5872788 operator dependency ordering
Rem     weizhang   03/08/07 - lrg 2884728: support tablespace MAXSIZE
Rem     hosu       02/27/07 - add administer sql management object to
Rem                           exp_full_database and imp_full_database roles 
Rem     kamble     11/02/06 - add IDR_DIR to noexp$
Rem     slynn      10/12/06 - smartfile->securefile
Rem     yhu        09/14/06 - export with system managed statistics
Rem     mhho       09/10/06 - add XS$NULL to be excluded from all views
Rem     kamble     09/07/06 - exu11xml view for getting opqtype$ flags
Rem     kamble     08/10/06 - encrypted tablespace
Rem     ataracha   07/13/06 - add user anonymous to be excluded from all views
Rem     mjangir    07/10/06 - 5176017: Adding ifreepool column in exu9lob view 
Rem     dkapoor    07/03/06 - don't export ORACLE_OCM 
Rem     weizhang   06/06/06 - proj 18567: support LOBRETENTION and MAXSIZE 
Rem     xbarr      06/06/06 - remove DMSYS schema - obsolete in 11g 
Rem     sramakri   05/15/06 - define exu11ind similar to exu9ind
Rem     sramakri   04/12/06 - index changes for mvs 
Rem     wesmith    04/05/06 - add snapshot views for v11 
Rem     kamble     03/13/06 - 4711857: comment$ problem(long column involved)
Rem     dgagne     01/26/06 - add replace for apos in exu10asc view for 
Rem                           columns with apos in them 
Rem     jgalanes   12/20/05 - Add expxsldelim for 4656020
Rem     sdavidso   11/30/05 - Fix 4087161 - MDAPI for nested tables w/XMLtype 
Rem     jgalanes   08/04/05 - Fix 4526056 - exu81ixsp - get compression 
Rem     jgalanes   07/13/05 - 4375555 IOT w/mapping table in TRANSPORTABLE 
Rem                           mode 
Rem     cdilling   05/11/05 - Fix 4347949 - ignore java classes owned by SYS 
Rem     jgalanes   05/09/05 - Fix 4046842 - exclude types not related to 
Rem                           subject table 
Rem     cdilling   05/02/05 - ignore WMSYS 
Rem     kneel      11/11/04 - fix lrg 1795214: unique constraint error on 
Rem                           import 
Rem     jgalanes   10/27/04 - Fix 3906846 - add exu102xtyp view 
Rem     araghava   10/25/04 - 3448802: don't partobj$ to get blocksize in 
Rem                           *_LOBS 
Rem     jgalanes   10/15/04 - 3651756 switch from SELECT_CATALOG_ROLE         
Rem                           to ExP_FULL_DATABASE on exu?lnk   
Rem     jgalanes   09/28/04 - PLSQL_CCFLAGS
Rem     rburns     09/13/04 - check for SYS user 
Rem     jgalanes   08/31/04 - Column encryption 
Rem     jgalanes   07/21/04 - Fix 3047454 TTS with unused ADT columns 
Rem     cdilling   07/01/04 - Do not export EXFSYS schema or HELP table
Rem     jgalanes   06/10/04 - 3617574 add HAKAN factor to exu81tts 
Rem     rvissapr   06/09/04 - proj 5523 dblink pswd encode 
Rem     jgalanes   04/23/04 - Fix 3447083 - IOT degree lost 
Rem     mxiao      03/25/03 - add EXU10SNAP*
Rem     jgalanes   03/05/04 - Adding new views for 3467567 imp_tab_trig & 
Rem                           imp_lob_notnull
Rem     jgalanes   02/25/04 - Fix 2654811 exu81tabs trigflag with row movement 
Rem     bmccarth   02/03/04 - check tables making use of template part. 
Rem     jgalanes   12/18/03 - Fix 2734632 - PRESERVE SPECIFICATION TIMESTAMP
Rem     jgalanes   12/18/03 - Fix 3107208 - replacing missing view 
Rem     jgalanes   01/26/04 - Fix 2539145 EXEMPT ACCESS POLICY - EXPExEMPT 
Rem     hikimura   11/11/03 - 3159568: add type to exu8ref
Rem     jgalanes   11/10/03 - lrg1566954 dataobj# ordering 
Rem     jgalanes   11/06/03 - new views for 3230116 - compression 
Rem     kamble     09/08/03 - 3071475: return attr name if lob is user defined
Rem     hikimura   08/01/03 - 2977202: add view imp9con
Rem     jgalanes   08/20/03 - Fix lrg1336525 - table stats for IOTs 
Rem     clei       07/15/03 - synonym polices no longer attached to base object
Rem     kamble     06/25/03 - 2803911: add view exu8col_tts_unused_col 
Rem     mramache   06/23/03 - sql profiles
Rem     bmccarth   06/27/03 - 10i version of exu9coe that includes column 
Rem                           with default values for object tables
Rem     jgalanes   05/21/03 - PLSQL_COMPILER_FLAGS changes
Rem     cdilling   05/19/03 - Do not export DBSNMP user
Rem     aramarao   04/24/03 - 2900891 fix ora-904 on spolicy exporting from 817
Rem     jgalanes   05/20/03 - create exu10doso for 2946068
Rem     krajaman   05/20/03 - Remove d_owner# from dependency$
Rem     jgalanes   05/02/03 - 2859106 more supplemental log stuff
Rem     jgalanes   04/01/03 - Fix 2869900 by fixing DECODE in imp_lob_info view
Rem     bmccarth   03/18/03 - ignore DMSYS
Rem     bmccarth   03/20/03 - exclude recycle bin object from transportable
Rem                           and domain index secondary object views
Rem     kamble     02/27/03 - imp9tvoid - get latest tvoid
Rem     bmccarth   01/22/03 - binary float/double values incorrect
Rem     wfisher    01/27/03 - Granting RESUMABLE priv to *_FULL_DATABASE roles
Rem     jgalanes   01/29/03 - PL/SQL compiler optimize switch changes
Rem     mxiao      01/13/03 - retrieve COMMENT in exu9snap
Rem     bmccarth   01/13/03 - return opqtype$ out-of-line flag
Rem     atsukerm   12/27/02 - grant profile creation to imp_full_database
Rem     jgalanes   01/03/03 - Fix lrg by adding lob.property to lob_chunksize view
Rem     bmccarth   01/08/03 - exclude 21/22 types from tabxxx views
Rem     cdilling   01/06/03 - Do not export DIP
Rem     jdavison   12/13/02 - Do not export SI_INFORMTN_SCHEMA
Rem     bmccarth   10/29/02 - exclude recycle bin objects
Rem     tkeefe     09/24/02 - Move proxy_data$ and proxy_role_data$ out of
Rem                           bootstrap region
Rem     vkarra     08/08/02 - tablespace groups
Rem     sasriniv   09/05/02 - Fix 2544428
Rem     nireland   09/04/02 - Add select any seq to exp_full_database
Rem     bmccarth   08/20/02 - don't exclude secondary object from exu9ltts
Rem     mxiao      08/07/02 - add new view for 10i mv logs
Rem     twtong     08/22/02 - add alias_txt to exu9snap
Rem     jgalanes   08/08/02 - Fix 2383871 by exporting typeid
Rem     sasriniv   08/01/02 - Fix lrg caused by 2261722
Rem     jgalanes   07/18/02 - Add new view for 2247291 LOB triggers to 
Rem                           get chunk size
Rem     sasriniv   07/03/02 - Fix 2261722
Rem     araghava   05/15/02 - partition #s no longer go from 1->n. don't use
Rem                           predicate part# = 1.
Rem     jgalanes   05/07/02 - Fix bug 2349201.
Rem     bmccarth   04/29/02 - v$compatibility going away
Rem     bmccarth   03/29/02 - remove uid check from exu9xmlst
Rem     jgalanes   04/03/02 - Fix bug 2300104 - support UNDER clause of 
Rem                           CREATE VIEW.
Rem     jgalanes   02/15/02 - Fix 2226749 by improving type ordering.
Rem     emagrath   02/08/02 - Exclude hidden columns for NOT NULL constr.
Rem     jgalanes   01/30/02 - bug 2182686 - use source$ for triggers export.
Rem     bmccarth   01/28/02 - exclude xdb schema, add views to grab xdb info
Rem     emagrath   01/07/02 - Elim. endian REF problem
Rem     jgalanes   12/19/01 - Fix bug 2127010 by ordering types..
Rem     jgalanes   12/10/01 - make imp9tvoid fetch object STATUS.
Rem     bmccarth   12/21/01 - ordered collections
Rem     nireland   11/14/01 - Fix column comment problem. #2106151
Rem     nireland   11/06/01  - Add defsubpcnt to EXU9PDS. #2089034
Rem     celsbern   11/01/01 - adding grant on exu9actionobj.
Rem     bmccarth   10/23/01 - merge error in exu81actionobj
Rem     celsbern   10/19/01  - merge LOG to MAIN
Rem     clei       10/11/01  - 
Rem     prakumar   10/10/01  - 2035111:Add a hint to exu9lbp & exu81lbsp to 
Rem                            improve performance  
Rem     bmccarth   10/17/01  - log branch merge
Rem     dgagne     10/12/01  - add support for table/tablespace compress option
Rem     jgalanes   10/05/01  - implement support for type synonyms.
Rem     prakumar   09/18/01  - add support for grant on java (re)source objects
Rem     clei       08/30/01  - change exu9rls to support VPD policies on
Rem                            synonym
Rem     dgagne     09/12/01  - add support for subpartition templates
Rem     dgagne     08/29/01  - add support for range/list composite partitions
Rem     bmccarth   08/27/01  - typeo in 8lnk view
Rem     bmccarth   08/21/01  - return flags from link table
Rem     emagrath   08/14/01  - Elim. probs with REF and other constraints
Rem     bmccarth   08/02/01  - New view to containing tables with unused 
Rem                            columns
Rem     bmccarth   07/24/01  - log based replication
Rem     pabingha   07/17/01  - add exu9mvlu view
Rem     nireland   07/05/01  - Amend exu9ind to exclude ALL OID PK indices
Rem     druthven   06/29/01  - 1826338 - improve performance of exu81lbspu
Rem     dmwong     05/30/01  - bug1796876 - quotes in FGA predicates.
Rem     dmwong     05/27/01  - bug1802004 - remove trailing spaces in exu9rls.
Rem     pabingha   05/09/01  - add oldest times to CDC MV Log views
Rem     htseng     04/12/01  - eliminate execute twice (remove ;).
Rem     clei       04/16/01  - add static policy
Rem     wfisher    04/18/01  - Relax restrictions on when 'is type of' is
Rem                            generated.
Rem     prakumar   04/03/01 -  Support col NOT NULL constraint for object table
Rem     gclaborn   04/02/01  - Inc. perf. of partitioned lob views: #1712758
Rem     dgagne     04/04/01  - Add import view to get compatibility mode
Rem     nireland   03/14/01  - Fix pre-8.1 trigger export. #1675586
Rem     tkeefe     03/14/01  - Simplify normalization of n-tier schema.
Rem     htseng     03/13/01  - remove an extra line from create/select imp9usr
Rem     somichi    03/05/01  - 1206380: Grant 'analyze any' privilege to
Rem                                     imp_full_database role
Rem     wesmith    03/01/01  - exu8coo: include snapshot hidden column
Rem     htseng     03/01/01  - add new query imp9usr for checking import user.
Rem     abrumm     02/20/01  - external_tab$: store access params as lob
Rem     dgagne     02/26/01  - fix exu9ind for stats on sys gen constraints
Rem     emagrath   02/16/01  - Support Opaque Type LOB storage
Rem     bmccarth   02/15/01  - imp9tvoid needs to use kzsrorol
Rem     bmccarth   02/07/01  - exu8col need coltype
Rem     bmccarth   01/08/01  - type evolution
Rem     emagrath   01/29/01  - Support XMLType CLOB storage
Rem     dmwong     01/28/01  - remove EXEMPT ACCESS POLICY for 8.0
Rem                            compatibility
Rem     prakumar   01/15/01  - Fix for bug 1218370
Rem     wfisher    01/08/01  - Type inheritance.
Rem     wesmith    12/28/00  - code review comments
Rem     dgagne     12/27/00  - change views with connect by for perf. gain
Rem     wesmith    12/13/00  - 9.0 export/import support for MVs
Rem     gmurphy    12/11/00  - Dont export LBACSYS in full export
Rem     jingliu    12/07/00  - add column synnam2 in exu8syn
Rem     abgupta    12/07/00  - disallow export of functional indices created
Rem                            as part of create MV.
Rem     dgagne     12/08/00  - add support for null associations
Rem     arithikr   12/13/00  - 1489592: expect ORA-1921 for
Rem                            imp_,exp_full_database
Rem     dgagne     12/04/00  - update for 9i
Rem     htseng     12/08/00  - Decode AL16UTF16 to UTF8 in exu8cset to fix
Rem                            9idb to 8i.
Rem     emagrath   11/28/00  - Exclude OIDINDEXs from index view
Rem     cku        11/17/00  - PBMJI
Rem     htseng     11/13/00  - add constraint using index support
Rem     dgagne     11/16/00  - remove tab_ovf references
Rem     rburns     11/09/00  - remove & for sqlplus
Rem     slawande   11/09/00  - Add export support for seq# in mvlog.
Rem     emagrath   10/31/00  - Support IOT MAPPING TABLE
Rem     prakumar   10/30/00  - #1421243:Ref column not null constraint was lost
Rem     emagrath   10/20/00  - Provide statistics info for PIOTs
Rem     dgagne     10/18/00  - put exu8dimu back in for 8.1.5 exp
Rem     nshodhan   10/17/00  - filter out oid only snapshot logs for 81views
Rem     jingliu    10/13/00  - code review comment
Rem     wfisher    10/11/00  - NLS_CHAR_LENGTH -> NLS_LENGTH_SEMANTICS
Rem     jingliu    09/29/00  - modify jobq related export view
Rem     bmccarth   09/28/00  - add view for domain index partitions
Rem     jgalanes   09/25/00  - Adding table qualifiers to new MV log views.
Rem     jgalanes   07/06/00  - Adding view for CDC style MV logs
Rem     dgagne     09/29/00  - update exu8ref for ref const on views
Rem     dgagne     09/26/00  - add support for tab_ovf$ to all table views
Rem     prakumar   09/18/00  - Fix view exu81javt to support shortened java obj
Rem     prakumar   09/10/00  - Bug 1347528:fix ts_type in exu8sto view.
Rem     nshodhan   09/06/00  - Add exu9snapl
Rem     wfisher    09/05/00  - Bitmap join indexes
Rem     htseng     08/31/00  - add row level scn support
Rem     htseng     08/24/00  - correct rollback seg bit
Rem     emagrath   07/28/00  - Multi-blocksize support
Rem     dgagne     10/11/00  - add view for obtaining compiler switches
Rem     nireland   07/25/00  - Fix exu81fil. #1244182
Rem     htseng     07/17/00  - undo tablespace support
Rem     bmccarth   07/12/00  - Domain index v2 changes
Rem     dgagne     07/11/00  - Update constraint views to not include tables in
Rem     dmwong     07/10/00  - add support for partitiond fine grained access.
Rem     dgagne     06/26/00  - Add support for 9.0 N-tier authentication
Rem     dgagne     07/18/00  - modify exu81tabs for external tables
Rem     bmccarth   06/22/00  - Change exu9nta for breakup of proxy$ table
Rem     nireland   06/07/00  - Add isonline to exu81sto
Rem     wfisher    06/16/00  - Unicode support
Rem     rmurthy    06/20/00  - change objauth.option column to hold flag bits
Rem     nireland   05/31/00  - Don't export constraints for ORDSYS etc.#1308267
Rem     wfisher    05/24/00  - Use partitioning info for logical tablespace exp
Rem     bmccarth   05/16/00  - bug 1296644 - performance of stored procedure ex
Rem     arithikr   05/10/00  - Bad merge, restore the file
Rem     jdavison   04/25/00  - Adjust creation of exu816ctx view.
Rem     htseng     04/11/00  - need quots for column name in lob clause
Rem     dmwong     08/31/98  - add exu81approle to support application role
Rem     tlee       10/13/98  - support adt attribute column on partition keys
Rem     nireland   03/21/00  - Fix outer join problem with exu8syn
Rem     dgagne     04/06/00  - add support for n-tier 8.1 project
Rem     rvissapr   03/06/00  - add support to create context accessed globally
Rem     dgagne     03/21/00  - update views used to examine indexes with const
Rem     dgagne     02/29/00  - Change exu81nos to export stats with named contr
Rem     emagrath   02/25/00  - Get attributes for LOBs in PIOTs
Rem     bmccarth   01/14/00  - icache: check for icache_imp_plsql
Rem     nireland   01/20/00  - tempflags now obsolete
Rem     wfisher    02/08/00  -  Create mode for logically exporting tablespaces
Rem     nireland   12/22/99  - Fetch index partition base object #
Rem     bmccarth   11/11/99  - incorrect merge- remove outer joints from
Rem                            exu816tgr
Rem     bmccarth   11/01/99  - performance work on exu816tgr
Rem     wfisher    10/21/99  - Don't look at invalid types on scalar nested tab
Rem     bmccarth   10/13/99  - bug 991834 - exu8orfs - remove cdef$ use
Rem     htseng     09/09/99  - fix primary key missing nologging attribute
Rem     cchui      08/18/99  - modify exu8coo to check for RLS hidden col
Rem     wfisher    08/17/99  - Fixing up grant for exu816sqv
Rem     wfisher    08/04/99  - Support sql versioning for snapshots/ update ver
Rem     wfisher    08/09/99  - fixing exu81tts and exu81usci
Rem     nireland   07/28/99  - Need update any table for LOBs. #861310
Rem     thoang     07/22/99  - Not using spare1 and spare2 from col$.
Rem     emagrath   07/08/99  - Support enhanced trigger events
Rem     dmwong     07/06/99  - add view to test for trusted oracle
Rem     mjungerm   06/15/99  - add java shared data object type
Rem     wfisher    06/24/99  - SQL Version support
Rem     cyyip      05/26/99  - remove special character '&'
Rem     wfisher    05/28/99  - Speeding up EXUTTS query
Rem     nvishnub   05/04/99  - Fix bug # 882543 (filter_non_existent_types)
Rem     nireland   04/21/99  - Remove bogus DROP ROLE. #874826
Rem     lbarton    04/26/99  - make export sensitive to COLLSTO COMPATIBILITY
Rem     nvishnub   04/19/99  - Fix views to improve performance.
Rem     nireland   04/09/99  - Cope with large tables. #867018
Rem     nvishnub   03/24/99  - E/I support for fast rebuild of domain indexes.
Rem     wfisher    03/26/99  - Make synonym ordering y2k ready
Rem     wfisher    03/18/99  - Redo view dependency ordering
Rem     wfisher    03/08/99  - TS for IOTS comes from index
Rem     wfisher    02/24/99  - more column statistics
Rem     lbarton    03/12/99  - change exu81javt
Rem     wfisher    02/15/99  - Don't export precomputed statistics when associa
Rem     nvishnub   01/07/99  - Handle indexes due to constraints correctly.
Rem     lbarton    02/22/99  - filter cartridge-owned objects
Rem     nvishnub   02/25/99  - Optimize view exu8dim(u).
Rem     wfisher    01/06/99  - bug 745470: vlen needed for testing overflow
Rem     wfisher    12/21/98  - Support associations
Rem     tlee       12/10/98  - change privilege rewrite to query rewrite
Rem     vkarra     11/19/98  - fix 81ind_base
Rem     masubram   11/17/98  - code review comments
Rem     masubram   10/13/98  - add two columns to exu81srt
Rem     mimoy      11/13/98  - Support NEVER REFRESH for snapshot in exu81snap
Rem     wesmith    11/13/98  - RepAPI export code review fixes
Rem     jingliu    11/12/98  - Fix imp/exp snapshot log related difs
Rem     lbarton    11/09/98  - new priv: administer database trigger
Rem     wfisher    11/04/98  - Add new privs to impexp roles
Rem     wesmith    11/02/98  - Fix view exu81rgsu
Rem     jingliu    10/30/98  - Support snapshot log export for 8.1
Rem     tlee       10/27/98  - get compress option for piot in exu81usci
Rem     wesmith    10/20/98  - Modify view exu81snap to nvl() flavor_id
Rem     wesmith    10/15/98  - Add support for export of RepAPI snapshots
Rem     tlee       10/13/98  - support adt attribute column on partition keys
Rem     avaradar   10/07/98  - get property value in exu8col
Rem     nvishnub   10/20/98  - Enumerate partitioned constraints indices.
Rem     tlee       10/02/98  - get subpart storage for transportable tablespace
Rem     avaradar   09/28/98  - compare intcol# in exu8spok, exu8poki, exu8pok
Rem     wfisher    09/08/98  - Specify default histograms if no histograms exis
Rem     avaradar   09/07/98  - Hidden column support for snapshots
Rem     lbarton    09/09/98  - Filter types owned by cartridges
Rem     tlee       09/01/98  - transportable tablespace with nested table
Rem     nvishnub   08/26/98  - Filter special schema objects.
Rem     tlee       08/25/98  - transportable tablespace with iot
Rem     tlee       08/25/98  - update defbufpool of default level
Rem     whuang     08/19/98  - fake index
Rem     nvishnub   08/05/98  - E/I of primary key refs.
Rem     nvishnub   07/29/98  - Filter datetime interval types.
Rem     nireland   07/28/98  - Correctly identify constraint indices. #686272
Rem     lbarton    08/04/98  - use new dbms_java names
Rem     tlee       07/22/98  - remove ts_type from exupds, update exu8lob
Rem     lbarton    07/13/98  - lrid downgrade support
Rem     nvishnub   07/13/98  - Add tablespace_type to storage info.
Rem     lbarton    06/19/98  - Java longname support
Rem     tlee       06/14/98  - lob and varray as lob partitioned obj support
Rem     tlee       06/10/98  - tspitr support of new partitioning
Rem     amsrivas   06/07/98  - Bug 536970
Rem     gclaborn   06/08/98  - Add system procedural object and action support
Rem     nvishnub   06/05/98  - Put back lob-index storage clause.
Rem     gclaborn   06/04/98  - Separate new export tables
Rem     asurpur    06/03/98  - Adding changes to exu8grs
Rem     asurpur    06/02/98  - Changing view exu8spv to not export some privile
Rem     gclaborn   06/02/98  - Update operator / indextype support
Rem     lbarton    05/26/98  - javasnm$ has changed
Rem     nvishnub   05/20/98  - Fix exu8ink to not to include 0 cols.
Rem     gclaborn   05/08/98  - Add views on exppkgs$ / expdep$: Subset exu8tab
Rem                            and exu8typ from 81 versions; no secondary obj.
Rem     tlee       05/07/98  - fix exu8pds and update tabcompart$ changes
Rem     dmwong     05/07/98  - require select_catalog_role for exu81rls
Rem     nvishnub   05/01/98  - Lob storage for varrays.
Rem     ayalaman   05/01/98  - Key compression : add preccnt to exu81ind
Rem     nvishnub   04/29/98  - Nested table enhancements.
Rem     hasun      04/28/98  - Exclude 8.1 snapshots from V8.0.X export
Rem     wfisher    04/27/98  - Adding support for flags
Rem     nvishnub   04/21/98  - Support for bitmapped tablespaces.
Rem     lbarton    04/16/98  - filter system events from pre8.1 triggers
Rem     wfisher    04/15/98  - Support Dimensions
Rem     dmwong     04/15/98  - add exu81rls for fine grain access control
Rem     smuthuli   04/13/98  - bug 487555.roll forward from 805
Rem     tlee       04/13/98  - rename comppart$->tabcompart$ add indcompart$
Rem     gclaborn   04/07/98  - Fetch implementation type details in exu81doi
Rem     dmwong     04/02/98  - add support for application context
Rem     ayalaman   03/27/98  - use 2 bytes of pctthres for guess quality
Rem     sparrokk   03/18/98  - 621964: EXECUTE ANY TYPE for exp/imp roles
Rem     nvishnub   03/13/98  - Fix view exu8iov to use bitand.
Rem     nvishnub   03/11/98  - E/I of partitioned IOTs.
Rem     wfisher    03/02/98  - Save raw analyze statistics at export
Rem     lbarton    02/23/98  - changes for java
Rem     vkarra     02/12/98  - single table cluster
Rem     tlee       02/09/98  - 81 partitioned object support
Rem     nireland   02/06/98  - SYS_NC_ROWINFO$ is 0x200 in sys.col$. #606078
Rem     nvishnub   12/17/97  - Support for datetime-interval datatypes.
Rem     cfreiwal   02/24/98  - key compression : add preccnt to exu8uscu
Rem     thoang     12/11/97  - Updated views to exclude unused columns
Rem     gclaborn   12/19/97  - Filter 2ndary objects, add oper/indextype sup.
Rem     wfisher    12/02/97  - Merge from wfisher_catexp804 in 8.0.4
Rem     gclaborn   12/02/97  - Add Functional / Domain Index support
Rem     wesmith    11/21/97  - Correct grant of snapshot view
Rem     wesmith    11/20/97  - add 8.1 views to support aggregate snapshots
Rem     mdepledg   10/08/97  - add spare1 to exu8tab
Rem     wfisher    09/19/97  - Bug 547977 -- support parallel for indexes
Rem     bmoy       09/16/97  - fix imp8repcat view.
Rem     wfisher    09/16/97  - Allow export of privs and role grants to public
Rem     wfisher    08/27/97  - fix exu8opt definition
Rem     wfisher    08/26/97  - Add exu8opt
Rem     bmoy       07/03/97  - Fix imp8repcat, add check for user#.
Rem     jpearson   06/20/97  - bug 498610 - view text and trigger action sizes
Rem     jstenois   06/12/97  - distributed security domains in export
Rem     wfisher    06/12/97  - Support trusted links
Rem     jstenois   06/06/97  - recover from V$OPTIONS changes
Rem     rsarwal    05/29/97  - Remove Echo
Rem     gdoherty   05/10/97  - remove blank lines that break sqlplus
Rem     bmoy       05/05/97  - Fix bug 454318.
Rem     jstenois   04/17/97  - support trigger with different owner than table
Rem     bmoy       03/27/97  - Replication support for Imp, added imp8repcat
Rem     jpearson   04/01/97  - fix index on nested_table_id col of inner table
Rem     jpearson   03/11/97  - partitioned cache support
Rem     wfisher    03/25/97  - adding exu8csn and exu8csnu (scalar nested table
Rem     jstenois   03/21/97  - get account status from user$
Rem     jpearson   02/13/97  - fix date specifications
Rem     gdoherty   01/30/97  - Get dataobj# in exu8lob for PITR
Rem     syeung     11/14/96  - Snapshot DDL: grant exu8glob to public
Rem     adowning   10/08/96  - fix snapshot views
Rem     syeung     08/29/96  - snapshot ddl
Rem     wfisher    11/08/96  - exu8tab(u) and exu8cset are used by import too
Rem     wfisher    10/31/96  - SYS_NC_SETID$ -> NESTED_TABLE_ID
Rem     jpearson   10/29/96  - bitmap indexes on inner nested tables
Rem     gdoherty   10/22/96  - add dobjid to exu8tbp and exu8ixp
Rem     jpearson   10/22/96  - export views in dependency order
Rem     syeung     10/07/96  - bug 374657: merge bitmap index fix from 7.3
Rem     syeung     10/03/96  - bump up EXPORT_VIEWS_VERSION for 8.0.2
Rem     syeung     09/25/96  - nchar support
Rem     echong     09/26/96  - modify exu8ink to handle ADTs
Rem     echong     09/17/96  - define exu8ink for iots
Rem     jpearson   09/17/96  - fix exu8tabi modified flag
Rem     jpearson   09/13/96  - fix exu8lob view
Rem     syeung     09/11/96  - password management
Rem     ixhu       07/31/96  - dataobj# and tabno for point-in-time recovery
Rem     jpearson   09/11/96  - modify ref scope handling
Rem     jpearson   08/30/96  - fix column comments on extent tables and views
Rem     jpearson   08/28/96  - fix cache flag in exu8tab and exu8clu
Rem     jpearson   08/21/96  - nested table column names
Rem     asurpur    07/31/96  - Granting *_catalog_roles to *_full_database
Rem     jpearson   08/19/96  - modify nested table support
Rem     wfisher    08/14/96  - LOB clauses on CREATE TABLE for attributes
Rem     jpearson   08/08/96  - support REF SCOPE
Rem     jpearson   08/06/96  - extent views fix for dropped types
Rem     syeung     07/19/96  - purified
Rem     jpearson   07/29/96  - handle INSTEAD OF triggers
Rem     jpearson   07/24/96  - simplify incremental export
Rem     jpearson   07/11/96  - fix merge errors
Rem     syeung     07/01/96  - system generated name changed
Rem     jpearson   07/10/96  - add catalog roles
Rem     syeung     06/24/96  - clu.spare4->avgchn in exu8clu
Rem     syeung     06/19/96  - fix snapshot views
Rem     echong     07/08/96  - define exu8iovu for iots
Rem     echong     06/24/96  - add iot comments
Rem     echong     06/17/96  - add defer to exu8con
Rem     jpearson   06/27/96  - support for librarys and execute any type priv
Rem     wfisher    06/25/96  - Don't get lob descriptions for lob attributes
Rem     jpearson   06/14/96  - change views for indices to support objects
Rem     jpearson   06/13/96  - support constraints on adt columns
Rem     wfisher    06/13/96  - Add SYS_NC_ to system generated column names
Rem     jpearson   06/12/96  - fix type body audit information
Rem     jpearson   06/11/96  - support for objects in incremental export
Rem     jpearson   06/11/96  - fix type body views
Rem     jpearson   06/10/96  - add views for types, librarys and directory alia
Rem     wfisher    06/07/96  - Add in more object views
Rem     wfisher    06/06/96  - Adding object views
Rem     jpearson   06/05/96  - modify exugrn[u] for directorys
Rem     asurpur    05/29/96  - Removing select on private views from select_cat
Rem     wfisher    05/23/96  - Adding object support for columns
Rem     mmonajje   05/22/96  - Replace action col name with action#
Rem     wfisher    05/16/96  - Return property and type information for tables
Rem     echong     05/24/96  - Modify exu8tab to include iots
Rem     syeung     05/16/96  - fix merge problem
Rem     asurpur    05/15/96  - Dictionary Protection: Granting privileges
Rem     syeung     05/14/96  - modified for replication changes
Rem     ixhu       05/13/96  - export v7 tables, clusters, p'd tables in Beta1
Rem     ccchang    05/10/96  - add nologging support
Rem     ixhu       05/08/96  - support ts$ online$ and contents$ changes
Rem     asurpur    04/08/96  - Dictionary Protection Implementation
Rem     ajasuja    05/02/96  - merge OBJ to BIG
Rem     ixhu       04/11/96  - AQ support: new expact$ columns
Rem     syeung     04/24/96  - Add property to exu8uscu
Rem     syeung     04/12/96  - fix header conflict
Rem     ccchang    03/15/96  - Support for PTI
Rem     syeung     04/10/96  - change unique$ to property in exu8ind
Rem     ixhu       04/03/96  - increment export view version number for 8.0
Rem     ixhu       02/28/96  - tablespace point-in-time recovery: exu8tsn
Rem     syeung     02/28/96  - add support deferred constraints and
Rem                            temporary tables
Rem     ixhu       02/26/96  - fix exu8fil view
Rem     ixhu       02/24/96  - fix exu8clu tsno
Rem     atsukerm   02/09/96  - fix file$ references.
Rem     ixhu       01/16/96  - ind$ spare8 to type in exu8ind* for bitmap index
Rem     ixhu       01/03/96  - ts-rel DBA: exu8sto, exu8stou, exu8tne,
Rem                            exu8tab, exu8clu, exu8ind, exu8rsg, exu8uscu,
Rem     achaudhr   10/25/95  - PTI: fix parallel, cache
Rem                          - PTI: global replace {imp, exu}7* -> {imp, exu}8*
Rem     aho        11/13/95  - iot
Rem     achaudhr   10/25/95  - PTI: fix parallel, cache
Rem     achaudhr   08/22/95  - PTI: t$.modified -> t$.flags
Rem     gdoherty   08/31/95  - mergetrans fix_pti_merge_bugs
Rem     achaudhr   07/20/95  - PTI: t.modified -> t.flags
Rem     ccchang    10/10/95  - add bitmap to exu7ind view for bitmap index
Rem     ixhu       09/18/95  - bug 250819 - misspelt RECORD, referential
Rem     ixhu       09/11/95  - bug 110894 - add exu7ordu to speed up exu7vewu
Rem     bhimatsi   07/11/95  - merge changes from branch 1.37.720.2
Rem     ssamu      06/15/95  - change views on tab$
Rem     ixhu       05/25/95  - add content to exu7tbs
Rem     ixhu       05/15/95  - bug 274629 - export ts quota even for dropped ts
Rem     lcprice    05/08/95  - merge changes from branch 1.37.720.1
Rem     ixhu       04/18/95  - add imp7uec for unlimited extent compatibility
Rem     jcchou     04/17/95  - (258186) fix
Rem     ixhu       04/04/95  - temporary/permanent tablespace in exu7tbs
Rem     ixhu       03/09/95  - add segcol# in exu7col & exu7colu, exu7cset
Rem     lcprice    04/18/95  - Fix bug #267737 - default roles processing
Rem     vraghuna   08/19/94  - move views reqd by both imp and exp to the top
Rem     vraghuna   08/18/94  - move compatibility checks from sql.bsq
Rem     vraghuna   08/15/94  - bug 227714 - add exu7cpo
Rem     jloaiza    07/08/94  - bitand modified column
Rem     vraghuna   06/20/94  - add support for hash cluster functions
Rem     vraghuna   06/10/94  - bug 218372 - speed up exu7del
Rem     vraghuna   06/09/94  - bug 219654 - add NVLs for ||l and cache params
Rem     vraghuna   05/16/94  - bug 215597 - change exu7snaplu also
Rem     vraghuna   05/12/94  - bug 215597 - change exu7snapl to exclude slog
Rem     vraghuna   04/24/94  - bug 211989 - add create roles but not drop
Rem     ltung      03/02/94  - merge changes from branch 1.15.710.1
Rem     vraghuna   02/09/94  - add exu7ver for version control
Rem     vraghuna   02/02/94  - bug 190236 - add outer join to exu7ord in exu7ve
Rem     vraghuna   01/17/94  - bug 191751 - add support for deferred RPC/RepCat
Rem     vraghuna   01/12/94  - bug 191750 - add support for refresh groups
Rem     vraghuna   01/11/94  - bug 191749 - add support for job queues exu7jbq
Rem     vraghuna   01/11/94  - bug 193733 - use basename in incr trigger views
Rem     vraghuna   01/11/94  - bug 193732 - fix exu7del for trigs, pkg bodies
Rem     vraghuna   01/10/94  - bug 192781 - add basetable name for trigger view
Rem     vraghuna   12/30/93  - bug 192652 - change MM to MI for exu7spr
Rem     vraghuna   12/21/93  - bug 191879 - grants issued twice
Rem     vraghuna   12/06/93  - bug 186073 - add read only tablespaces
Rem     vraghuna   08/18/93  - bug 174029 - moving role creation to sql.bsq
Rem     vraghuna   07/07/93  - add support for updatable snapshots
Rem     vraghuna   06/17/93  - bug 166480 - add exu7erc for resource costs
Rem     vraghuna   06/17/93  - bug 168261 - imp_full_database needs insert priv
Rem     vraghuna   06/17/93  - bug 166482 - export role passwords
Rem     vraghuna   05/27/93  - bug 166484 - add audt to exu7spr
Rem     ltung      05/16/93  - export parallel/cache parameters
Rem     vraghuna   03/15/93  - bug 140485 - incrementals on tables with constra
Rem     vraghuna   03/12/93  - bug 152906 - add tspname to exu7uscu
Rem     vraghuna   01/27/93  - bug 146283 - add exu7usc
Rem     vraghuna   12/18/92  - bug 143375 - break up exu7col
Rem     vraghuna   12/02/92  - bug 139302 - speed up exu7colnn
Rem     tpystyne   11/07/92  - use create or replace view
Rem     vraghuna   10/28/92  - bug 130560 - add exu7ful
Rem     vraghuna   10/23/92  - bug 135594 - remove exu7inv and exu7invu
Rem     glumpkin   10/20/92  - Renamed from EXPVEW.SQL
Rem     vraghuna   10/14/92  - bug 131957 - add field to exu7sto and exu7stou
Rem     vraghuna   07/14/92  - bug 115048 - support for analyze statement
Rem     cheigham   06/24/92  - add exu7colnn view
Rem     cheigham   06/22/92  - fix cdef$, col$ joins to accommodate changes for
Rem     jbellemo   06/12/92  - add mapping for MLSLABEL
Rem     vraghuna   06/03/92  - bug 39511 - add exu7grs
Rem     cheigham   05/27/92  - speed up exu7vew
Rem     cheigham   02/13/92  - add select any to imp_full_database
Rem     cheigham   02/13/92  - grant alter any table to imp_full_database
Rem     cheigham   01/29/92  - export altered clusters in inc. exports
Rem     cheigham   01/09/92  - add more privs to imp_full_database
Rem     cheigham   11/15/91  - fix object codes
Rem     cheigham   11/06/91  - fix inc. trigger views
Rem     cheigham   11/02/91  - merge in hash changes
Rem     cheigham   10/11/91  - view names: exu -> exu7
Rem     cheigham   09/27/91  - add snapshot views
Rem     sksingh    09/30/91  - merge changes from branch 1.13.50.1
Rem     sksingh    09/23/91  - replace spare1, 2, 3 with match, refact, enabled
Rem     agupta     09/20/91  - add support for lists/groups storage params
Rem     agupta     08/16/91  - enable|disable constraints
Rem     agupta     07/30/91  - 7037 - views not created in dependency or
Rem     agupta     07/02/91  - timestamp syntax for procedures
Rem     agupta     06/21/91  - fix errors in exurlg
Rem     agupta     06/14/91  - user$ column name changes
Rem     agupta     05/31/91  - add userid to tablespace quota view
Rem     agupta     05/04/91  - fix unique constraints bug
Rem     agupta     04/16/91  - fix auditing views
Rem     jwijaya    04/12/91  - remove LINKNAME IS NULL
Rem     rkooi      04/01/91  - add 'o.linkname IS NULL' clause
Rem     Gupta      02/26/90  - Lots of modifications for V7
Rem     Hong       10/31/88  - don't export quotas of 0
Rem     Hong       09/21/88  - allow null precision/scale
Rem     Hong       09/10/88  - fix outer joins
Rem     Hong       08/10/88  - get default/temp tablespace in exuusr
Rem     Hong       07/01/88  - get obj id in some views
Rem     Hong       06/10/88  - remove userid != 0 from views
Rem     Hong       04/28/88  - comment$ moved to com$
Rem     Hong       03/24/88  - add audit field to exu7seq
Rem     Hong       03/07/88  - deal with initrans, maxtrans
Rem                            add views for constraints, sequence #
Rem     Hong       02/01/88  - add exuico and exuicou
Rem                            temporary commented out col$.default$
Rem     Hong       02/01/88  - fix exufil to use v$dbfile directly
Rem     Hong       12/12/87  - fix exutbs
Rem     Hong       12/07/87  - handle min extents
Rem

WHENEVER SQLERROR EXIT;          
DOC  
######################################################################  
######################################################################  
    The following PL/SQL block will cause an ORA-20000 error and
    terminate the current SQLPLUS session if the user is not SYS. 
    Disconnect and reconnect with AS SYSDBA.  
######################################################################  
######################################################################  
#  
  
DECLARE 
  p_user VARCHAR2(30); 
BEGIN 
    SELECT USER INTO p_user FROM DUAL;  
    IF p_user != 'SYS' THEN  
        RAISE_APPLICATION_ERROR (-20000,  
           'This script must be run AS SYSDBA');  
    END IF;  
END; 
/ 
WHENEVER SQLERROR CONTINUE;          

REM
REM This role allows the grantee to perform full database exports including
REM incremental exports
REM
REM Expect ORA-1921 for CREATE ROLE exp_full_database if this file is run
REM as part of the migration script and the role existed in the previous
REM release. Dropping will require DBA to regrant the role.
REM
CREATE ROLE exp_full_database;
GRANT SELECT ANY TABLE TO exp_full_database;
GRANT BACKUP ANY TABLE TO exp_full_database;
GRANT EXECUTE ANY PROCEDURE TO exp_full_database;
GRANT EXECUTE ANY TYPE TO exp_full_database;
GRANT SELECT ANY SEQUENCE to exp_full_database;
GRANT RESUMABLE to exp_full_database;
GRANT INSERT, UPDATE, DELETE ON sys.incexp TO exp_full_database;
GRANT INSERT, UPDATE, DELETE ON sys.incvid TO exp_full_database;
GRANT INSERT, UPDATE, DELETE ON sys.incfil TO exp_full_database;
GRANT ADMINISTER SQL MANAGEMENT OBJECT TO exp_full_database;
GRANT exp_full_database TO DBA;

REM
REM This role allows the grantee to perform full database imports
REM
REM Expect ORA-1921 for CREATE ROLE imp_full_database if this file is run
REM as part of the migration script and the role existed in the previous
REM release. Dropping will require DBA to regrant the role.
REM
CREATE ROLE imp_full_database;
GRANT BECOME USER TO imp_full_database;
GRANT CREATE ANY CLUSTER TO imp_full_database;
GRANT CREATE ANY INDEX TO imp_full_database;
GRANT CREATE ANY TABLE TO imp_full_database;
GRANT CREATE ANY PROCEDURE TO imp_full_database;
GRANT CREATE ANY SEQUENCE TO imp_full_database;
GRANT CREATE ANY SNAPSHOT TO imp_full_database;
GRANT CREATE ANY SYNONYM TO imp_full_database;
GRANT CREATE ANY TRIGGER TO imp_full_database;
GRANT CREATE ANY VIEW TO imp_full_database;
GRANT CREATE PROFILE TO imp_full_database;
GRANT CREATE PUBLIC DATABASE LINK TO imp_full_database;
GRANT CREATE DATABASE LINK TO imp_full_database;
GRANT CREATE PUBLIC SYNONYM TO imp_full_database;
GRANT CREATE ROLLBACK SEGMENT TO imp_full_database;
GRANT CREATE ROLE TO imp_full_database;
GRANT CREATE TABLESPACE TO imp_full_database;
GRANT CREATE USER TO imp_full_database;
GRANT AUDIT ANY TO imp_full_database;
GRANT COMMENT ANY TABLE TO imp_full_database;
GRANT ALTER ANY TABLE TO imp_full_database;
GRANT SELECT ANY TABLE TO imp_full_database;
GRANT EXECUTE ANY PROCEDURE TO imp_full_database;
GRANT EXECUTE ANY TYPE TO imp_full_database;
GRANT INSERT ANY TABLE TO imp_full_database;
GRANT UPDATE ANY TABLE TO imp_full_database;
GRANT CREATE ANY DIRECTORY TO imp_full_database;
GRANT CREATE ANY TYPE TO imp_full_database;
GRANT CREATE ANY LIBRARY TO imp_full_database;
GRANT CREATE ANY CONTEXT TO imp_full_database;
GRANT ADMINISTER DATABASE TRIGGER TO imp_full_database;
GRANT CREATE ANY OPERATOR TO imp_full_database;
GRANT CREATE ANY INDEXTYPE TO imp_full_database;
GRANT CREATE ANY DIMENSION TO imp_full_database;
GRANT GLOBAL QUERY REWRITE TO imp_full_database;
GRANT CREATE ANY SQL PROFILE TO imp_full_database;
GRANT ADMINISTER SQL MANAGEMENT OBJECT TO imp_full_database;

REM
REM Privileges needed to execute PL/SQL blocks
REM
REM NOTE:  privileges that need to be granted via packages (e.g.,
REM        MANAGE_ANY_QUEUE) will be granted in the relevant package (e.g.,
REM        catqueue.sql) rather than here.  These privileges are identified in
REM        the SYSTEM_PRIVILEGE_MAP with PROPERTY!= 0
REM
GRANT DROP ANY OUTLINE TO imp_full_database;

REM
REM Granting the roles access views/packages from the dictionary;
REM
GRANT SELECT_CATALOG_ROLE TO exp_full_database;
GRANT SELECT_CATALOG_ROLE TO imp_full_database;
GRANT EXECUTE_CATALOG_ROLE TO imp_full_database;
GRANT EXECUTE_CATALOG_ROLE TO exp_full_database;

REM
REM For import of incremental export files
REM
GRANT DROP ANY CLUSTER TO imp_full_database;
GRANT DROP ANY INDEX TO imp_full_database;
GRANT DROP ANY TABLE TO imp_full_database;
GRANT DROP ANY PROCEDURE TO imp_full_database;
GRANT DROP ANY SEQUENCE TO imp_full_database;
GRANT DROP ANY SNAPSHOT TO imp_full_database;
GRANT DROP ANY SYNONYM TO imp_full_database;
GRANT DROP ANY TRIGGER TO imp_full_database;
GRANT DROP ANY VIEW TO imp_full_database;
GRANT DROP PROFILE TO imp_full_database;
GRANT DROP PUBLIC DATABASE LINK TO imp_full_database;
GRANT DROP PUBLIC SYNONYM TO imp_full_database;
GRANT DROP ROLLBACK SEGMENT TO imp_full_database;
GRANT DROP ANY ROLE TO imp_full_database;
GRANT DROP TABLESPACE TO imp_full_database;
GRANT DROP USER TO imp_full_database;
GRANT DROP ANY DIRECTORY TO imp_full_database;
GRANT ALTER ANY TYPE TO imp_full_database;
GRANT DROP ANY TYPE TO imp_full_database;
GRANT DROP ANY LIBRARY TO imp_full_database;
GRANT DROP ANY CONTEXT TO imp_full_database;
GRANT ALTER ANY PROCEDURE TO  imp_full_database;
GRANT ALTER ANY TRIGGER TO  imp_full_database;
GRANT DROP ANY OPERATOR TO imp_full_database;
GRANT DROP ANY INDEXTYPE TO imp_full_database;
GRANT DROP ANY DIMENSION TO imp_full_database;
GRANT ANALYZE ANY TO imp_full_database;
GRANT RESUMABLE TO imp_full_database;
GRANT DROP ANY SQL PROFILE TO imp_full_database;

GRANT imp_full_database TO DBA;

REM **********  I M P O R T A N T  **********  I M P O R T A N T  **********
REM This first view selects all rows from sys.obj$ that are NOT secondary
REM objects as created by Domain Indexes. Secondary objects are not normally
REM exported because the domain index's CREATE INDEX at import time will create
REM them. However, when doing domain index 'fast rebuild' we do place certain
REM classes of secondary objects (tables & their types, indexes) in the
REM export file.
REM
REM exu81obj should be used as a substitute for obj$ in all top level views
REM of object classes whose secondary objects will NEVER be exported; i.e, are
REM not exported during DI 'fast rebuild'.  Those object classes that can be
REM exp. in DI fast rebuild (tables/indexes) should continue to use obj$ and
REM filtering (or not) of 2ndary objects will be done at run time via a bind
REM var. on the WHERE clauses of the appropriate SELECT statements in exuiss.c.
REM
REM When and if Pt. In Time Recovery ever supports domain indexes, it will have
REM to allow export of secondary objects because these comprise the storage for
REM the index. At that time, all object classes that PITR exports will have to
REM switch from using exu81obj (static filtering) back to obj$ and dynamically
REM filter off secondary objects as appropriate.
REM **********  I M P O R T A N T  **********  I M P O R T A N T  **********

CREATE OR REPLACE VIEW exu81obj AS
        SELECT  o$.*
        FROM    sys.obj$ o$, sys.user$ u$
        WHERE   BITAND(o$.flags, 16) != 16 AND
                /* Ignore recycle bin objects */
                BITAND(o$.flags, 128) != 128 AND 
                o$.owner# = u$.user# AND
                u$.name NOT IN ('ORDSYS',  'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                'LBACSYS', 'XDB',   'SI_INFORMTN_SCHEMA',
                                'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS','ORACLE_OCM',
                                'ANONYMOUS', 'XS$NULL', 'APPQOSSYS')
/
GRANT SELECT ON sys.exu81obj TO SELECT_CATALOG_ROLE;

REM
REM Get SQL Version information -- this version needs to be hardcoded as 8.1.6
REM when new versions of sql are generated.
REM
CREATE OR REPLACE VIEW exu816maxsqv (
                version#, sql_version) AS
        SELECT  sv.version#, sv.sql_version
        FROM    sys.sql_version$ sv
        WHERE   sv.version# = (
                    SELECT  MAX(sv2.version#)
                    FROM    sys.sql_version$ sv2)
/
GRANT SELECT ON sys.exu816maxsqv TO PUBLIC;

REM
REM The following helper view identifies interesting older sql versions in
REM the database. Only sql versions other than the database sql version are
REM identified.  Versions later than the export view's version are down-graded
REM to the version of the export views being used.
REM
CREATE OR REPLACE VIEW exu816sqv AS
        SELECT  sv.*
        FROM    sys.sql_version$ sv
        WHERE   sv.version# < (
                    SELECT  m.version#
                    FROM    sys.exu816maxsqv m)
/
GRANT SELECT ON sys.exu816sqv TO SELECT_CATALOG_ROLE;

REM
REM ***************************************************
REM Section 1: Views required by BOTH export and import
REM ***************************************************
REM

REM
REM 'Database' (SYSTEM tablespace) block size - used only in pre 9.0 Exports
REM for db blocksize and Imports that need to support V5 CREATE/ALTER SPACE
REM
CREATE OR REPLACE VIEW exu8bsz (
                blocksize) AS
        SELECT  ts$.blocksize
        FROM    sys.ts$ ts$
/
GRANT SELECT ON sys.exu8bsz TO PUBLIC;

REM
REM all users
REM
CREATE OR REPLACE VIEW exu8usr (
                name, userid, passwd, defrole, datats, tempts, profile#,
                profname, astatus, ext_username) AS
        SELECT  u.name, u.user#, DECODE(u.password, 'N', '', u.password),
                DECODE(u.defrole, 0, 'N', 1, 'A', 2, 'L', 3, 'E', 'X'),
                ts1.name, DECODE(BITAND(ts2.flags,2048),2048,'SYSTEM',ts2.name),
                u.resource$, p.name, u.astatus,
                u.ext_username
        FROM    sys.user$ u, sys.ts$ ts1, sys.ts$ ts2, sys.profname$ p
        WHERE   u.datats# = ts1.ts# AND
                u.tempts# = ts2.ts# AND
                u.type# = 1 AND
                u.resource$ = p.profile# AND
                u.name NOT IN ( 'ORDSYS',  'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                'LBACSYS', 'XDB',   'SI_INFORMTN_SCHEMA',
                                'DIP',  'DBSNMP', 'EXFSYS', 'WMSYS',
                                'ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                                'APPQOSSYS')
/
GRANT SELECT ON sys.exu8usr TO SELECT_CATALOG_ROLE;

REM
REM current user
REM
CREATE OR REPLACE VIEW exu8usru AS
        SELECT  *
        FROM    sys.exu8usr
        WHERE   userid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8usru TO PUBLIC;

REM
REM check if user has priv to do a full db export
REM
CREATE OR REPLACE VIEW exu8ful(
                role) AS
        SELECT  u.name
        FROM    sys.x$kzsro, sys.user$ u
        WHERE   kzsrorol != userenv('SCHEMAID') AND
                kzsrorol != 1 AND
                u.user# = kzsrorol
/
GRANT SELECT ON sys.exu8ful TO PUBLIC;

REM ---------------------------------------------------------------------
REM                        General and User Table Views
REM ---------------------------------------------------------------------
REM
REM  Notes:
REM      The 'latest' release view will return all supportable 
REM      tables while views used by prior releases should exclude 
REM      (if at all possible) tables which contain items 
REM      (such as data types) that are not supported on the specific 
REM      version's platform.  
REM
REM ---------------------------------------------------------------------

REM
REM V10.0 Table view
REM
REM Notes: 
REM    Includes tables with columns we don't deal with so we can 
REM    produce a better error to the 10i user.
REM
REM  xdbool added for 10i and out-of-line ordering
REM
CREATE OR REPLACE VIEW exu10tabs (
                objid, dobjid, name, owner, ownerid, tablespace, tsno, fileno,
                blockno, audit$, comment$, clusterflag, mtime, modified, tabno,
                pctfree$, pctused$, initrans, maxtrans, degree, instances,
                cache, tempflags, property, deflog, tsdeflog, roid, recpblk,
                secondaryobj, rowcnt, blkcnt, avgrlen, tflags, trigflag,
                objstatus, xdbool)
      AS                                                      /* Heap tables */
        SELECT
                o$.obj#, o$.dataobj#, o$.name, u$.name, o$.owner#, ts$.name,
                t$.ts#, t$.file#, t$.block#, t$.audit$, c$.comment$,
                NVL(t$.bobj#, 0), o$.mtime,
                DECODE(BITAND(t$.flags, 1), 1, 1, 0), NVL(t$.tab#, 0),
                MOD(t$.pctfree$, 100), t$.pctused$, t$.initrans, t$.maxtrans,
                NVL(t$.degree, 1), NVL(t$.instances, 1),
                DECODE(BITAND(t$.flags, 8), 8, 1, 0),
                MOD(TRUNC(o$.flags / 2), 2), t$.property,
                DECODE(BITAND(t$.flags, 32), 32, 1, 0), ts$.dflogging, o$.oid$,
                t$.spare1, DECODE(BITAND(o$.flags, 16), 16, 1, 0),
                NVL(t$.rowcnt, -1), NVL(t$.blkcnt, -1), NVL(t$.avgrln, -1),
                t$.flags, t$.trigflag, o$.status, 
                (SELECT COUNT(*) 
                    FROM sys.opqtype$ opq$ 
                    WHERE opq$.obj# = o$.obj# AND
                          BITAND(opq$.flags, 32) = 32 )
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.user$ u$,
                sys.com$ c$
        WHERE   t$.obj# = o$.obj# AND
                t$.ts# = ts$.ts# AND
                u$.user# = o$.owner# AND
                o$.obj# = c$.obj#(+) AND
                c$.col#(+) IS NULL AND
                BITAND(o$.flags,128) != 128 AND      /* Skip recycle bin */
                BITAND(t$.property, 64+512) = 0 AND /*skip IOT and ovflw segs*/
                BITAND(t$.flags, 536870912) = 0    /* skip IOT mapping table */
      UNION ALL                                         /* Index-only tables */
        SELECT  o$.obj#, o$.dataobj#, o$.name, u$.name, o$.owner#, ts$.name,
                i$.ts#, t$.file#, t$.block#, t$.audit$, c$.comment$,
                NVL(t$.bobj#, 0), o$.mtime,
                DECODE(BITAND(t$.flags, 1), 1, 1, 0),
                NVL(t$.tab#, 0), 0, 0, 0, 0, 
                NVL(t$.degree, 1), NVL(t$.instances, 1),
                DECODE(BITAND(t$.flags, 8), 8, 1, 0),
                MOD(TRUNC(o$.flags / 2), 2), t$.property,
                DECODE(BITAND(t$.flags, 32), 32, 1, 0), ts$.dflogging, o$.oid$,
                t$.spare1, DECODE(BITAND(o$.flags, 16), 16, 1, 0), 
                NVL(t$.rowcnt, -1), NVL(t$.blkcnt, -1), NVL(t$.avgrln, -1),
                t$.flags, t$.trigflag, o$.status,
                (SELECT COUNT(*) 
                    FROM sys.opqtype$ opq$ 
                    WHERE opq$.obj# = o$.obj# AND
                          BITAND(opq$.flags, 32) = 32 )
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.user$ u$,
                sys.com$ c$, sys.ind$ i$
        WHERE   t$.obj# = o$.obj# AND
                u$.user# = o$.owner# AND
                o$.obj# = c$.obj#(+) AND
                c$.col#(+) IS NULL AND
                BITAND(o$.flags,128) != 128 AND      /* Skip recycle bin */
                BITAND(t$.property, 64+512) = 64 AND /* IOT, but not overflow*/
                t$.pctused$ = i$.obj# AND/* For IOTs, pctused has index obj# */
                i$.ts# = ts$.ts#
/
GRANT SELECT ON sys.exu10tabs TO SELECT_CATALOG_ROLE;

REM
REM V10.0 Table views
REM

REM
REM V10.0 current user's tables
REM
CREATE OR REPLACE VIEW exu10tabsu AS
        SELECT  *
        FROM    sys.exu10tabs
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10tabsu TO PUBLIC;

REM
REM exu10tab
REM
REM Notes: filtered for secondaryobjs from above
REM
CREATE OR REPLACE VIEW exu10tab AS
        SELECT  *
        FROM    sys.exu10tabs t$ 
        WHERE   t$.secondaryobj = 0 
/
GRANT SELECT ON sys.exu10tab TO SELECT_CATALOG_ROLE;

REM
REM current user's tables
REM
CREATE OR REPLACE VIEW exu10tabu AS
        SELECT  *
        FROM    sys.exu10tab
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10tabu TO PUBLIC;

REM
REM End V10.0 Table views 
REM

REM
REM V9.0 Table views
REM
REM Notes: 
REM    Exclude tables with:
REM        columns of type BINARY_FLOAT (100) or BINARY_DOUBLE (101)
REM
CREATE OR REPLACE VIEW exu9tabs AS
        SELECT  * 
        FROM    sys.exu10tabs 
        WHERE  NOT EXISTS ( 
                   SELECT * 
                   FROM   sys.col$ c$ 
                   WHERE  (c$.obj# = objid AND
                           (c$.type# = 100 OR
                           c$.type# = 101 )))
/
GRANT SELECT ON sys.exu9tabs TO SELECT_CATALOG_ROLE;

REM
REM V9.0 current user's tables
REM
CREATE OR REPLACE VIEW exu9tabsu AS
        SELECT  *
        FROM    sys.exu9tabs
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9tabsu TO PUBLIC;

REM
REM exu9tab
REM
REM Notes: filtered for secondaryobjs from above
REM
CREATE OR REPLACE VIEW exu9tab AS
        SELECT  *
        FROM    sys.exu9tabs t$ 
        WHERE   t$.secondaryobj = 0 
/
GRANT SELECT ON sys.exu9tab TO SELECT_CATALOG_ROLE;

REM
REM current user's tables
REM
CREATE OR REPLACE VIEW exu9tabu AS
        SELECT  *
        FROM    sys.exu9tab
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9tabu TO PUBLIC;

REM
REM List of all tables with unused columns - taken directly from 
REM catalog.sql's all_unused_col_tabs
REM Notes:
REM    Modifications to this view to filter out specific new datatypes
REM    are not required.
REM
CREATE OR REPLACE VIEW exu9tab_unused_cols ( 
                OBJID ) AS
        SELECT  o.obj# 
        FROM    sys.user$ u, sys.obj$ o, sys.col$ c
        WHERE   o.owner# = u.user#
           AND  o.obj# = c.obj#
           AND BITAND(c.property,32768) = 32768            -- is unused column
           AND BITAND(c.property, 1) != 1              -- not ADT attribute col
           AND BITAND(c.property, 1024) != 1024         -- not NTAB's setid col
           AND (o.owner# = userenv('SCHEMAID')
                OR o.obj# IN
                   (SELECT oa.obj#
                     FROM sys.objauth$ oa
                     WHERE grantee# IN ( select kzsrorol
                                 FROM x$kzsro
                               )
                    )
                OR EXISTS (SELECT NULL FROM v$enabledprivs
                            WHERE priv_number IN (-45 /* LOCK ANY TABLE */,
                                                  -47 /* SELECT ANY TABLE */,
                                                  -48 /* INSERT ANY TABLE */,
                                                  -49 /* UPDATE ANY TABLE */,
                                                  -50 /* DELETE ANY TABLE */)
                          )
                )
/
GRANT SELECT ON sys.exu9tab_unused_cols to PUBLIC;

REM
REM V8.1 table views
REM
REM Notes: - exu81tabs is subseted off exu9tabs to filter out tables with
REM          non-null values in trigflag<30:5>
REM        - tempflags is now deprecated
REM
REM 2654811 row_movement_enabled (2097152) flag added in 9.2
REM          2097152 + 31 = 2097183
CREATE OR REPLACE VIEW exu81tabs AS
        SELECT  *
        FROM    sys.exu9tabs
        WHERE   BITAND(trigflag, 2097183) = trigflag
/
GRANT SELECT ON sys.exu81tabs TO SELECT_CATALOG_ROLE;

REM
REM current user's tables
REM
CREATE OR REPLACE VIEW exu81tabsu AS
        SELECT  *
        FROM    sys.exu81tabs
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81tabsu TO PUBLIC;

REM
REM exu81tab
REM
REM Notes: filtered for secondaryobjs from above
REM
CREATE OR REPLACE VIEW exu81tab AS
        SELECT  *
        FROM    sys.exu81tabs
        WHERE   secondaryobj = 0 AND
                ( NOT EXISTS (
                         SELECT  *
                         FROM    sys.col$ c$, sys.coltype$ ct$, sys.type$ t$
                         WHERE   c$.obj# = objid AND
                                 ct$.toid = t$.toid AND
                                 c$.obj# = ct$.obj# AND
                                 c$.col# = ct$.col# AND
                                 ((BITAND(t$.PROPERTIES, 8) = 8) OR
                                 (BITAND(t$.PROPERTIES, 8192) = 8192)))) 
/
GRANT SELECT ON sys.exu81tab TO SELECT_CATALOG_ROLE;

REM
REM current user's tables
REM
CREATE OR REPLACE VIEW exu81tabu AS
        SELECT  *
        FROM    sys.exu81tab
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81tabu TO PUBLIC;

REM
REM V8.0 table view
REM
REM Notes: exu8tab is subseted off exu81tab to filter out tables with:
REM        columns of type UROWID (208)
REM        datetime interval types : (178 <= type <= 183)
REM        varying width character LOBs :
REM        - (type = 112 & ((800 < charsetid < 1000) or (charsetid > 2000)))
REM
CREATE OR REPLACE VIEW exu8tab AS
        SELECT  *
        FROM    sys.exu81tab
        WHERE   NOT EXISTS (
                    SELECT  *
                    FROM    sys.col$ c$
                    WHERE   c$.obj# = objid AND
                            (c$.type# = 208 OR
                             (c$.type# >= 178 AND
                              c$.type# <= 183) OR
                             (c$.type# = 112 AND
                              ((c$.charsetid > 800 AND
                                c$.charsetid < 1000) OR
                               c$.charsetid > 2000))))
/
GRANT SELECT ON sys.exu8tab TO SELECT_CATALOG_ROLE;

REM
REM V8.0 User's tables
REM
CREATE OR REPLACE VIEW exu8tabu AS
        SELECT  *
        FROM    sys.exu8tab
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8tabu TO PUBLIC;

REM
REM Database Character Set and NCHAR Character Set
REM
REM Notes: For import and old versions of export
REM
CREATE OR REPLACE VIEW exu8cset (
                name, value) AS
        SELECT  name, DECODE (value$,'AL16UTF16','UTF8', value$)
        FROM    sys.props$
        WHERE   name IN ('NLS_CHARACTERSET',
                         'NLS_NCHAR_CHARACTERSET')
/
GRANT SELECT ON sys.exu8cset TO PUBLIC;

REM
REM Database NLS settings
REM
REM Notes: for current version of export
REM
CREATE OR REPLACE VIEW exu9nls (
                name, value) AS
        SELECT  name, value$
        FROM    sys.props$
        WHERE   name IN ('NLS_CHARACTERSET',
                         'NLS_NCHAR_CHARACTERSET',
                         'NLS_LENGTH_SEMANTICS')
/
GRANT SELECT ON sys.exu9nls TO PUBLIC;

REM
REM Check for Database Options
REM
CREATE OR REPLACE VIEW exu8opt (
                parameter, value) AS
        SELECT  parameter, DECODE(value, 'TRUE', 1, 'FALSE', 0, 2)
        FROM    sys.v$option
/
GRANT SELECT ON sys.exu8opt TO PUBLIC;

REM
REM ****************************************
REM Section 2: Views required by import ONLY
REM ****************************************
REM

REM
REM build replication procedures view
REM
CREATE OR REPLACE VIEW imp8repcat (
                name, type) AS
        SELECT  name, type#
        FROM    sys.obj$
        WHERE   name IN ('DBMS_SNAPSHOT_UTL', 'DBMS_REPCAT_MIG') AND
                type# = 11 AND
                owner# = 0
/
GRANT SELECT ON sys.imp8repcat TO PUBLIC;

REM
REM Get Unlimited Extent Compatibility Information
REM
REM 8.0.6 import references this view which never returned any rows
REM so WHERE 1=0 will make sure that continues.
REM
CREATE OR REPLACE VIEW imp8uec (
                release) AS
        SELECT  * 
        FROM    DUAL
        WHERE   1=0
/
GRANT SELECT ON sys.imp8uec TO PUBLIC;

REM
REM obtain the TOID of an existing type
REM
CREATE OR REPLACE VIEW imp8ttd (
                tname, towner, toid) AS
        SELECT  o$.name, u$.name, o$.oid$
        FROM    sys.obj$ o$, sys.user$ u$, sys.type$ t$
        WHERE   o$.type# = 13 AND
                o$.owner# = u$.user# AND
                o$.oid$   = t$.toid  AND
                t$.toid   = t$.tvoid                          /* Only latest */
/
GRANT SELECT ON sys.imp8ttd TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW imp8ttdu (
                tname, towner, toid) AS
        SELECT  o$.name, u$.name, o$.oid$
        FROM    sys.obj$ o$, sys.user$ u$, sys.type$ t$
        WHERE   o$.type# = 13 AND
                o$.owner# = u$.user# AND
                o$.oid$   = t$.toid  AND
                t$.toid  = t$.tvoid AND                  /* Only the latest */
                (o$.owner# = userenv('SCHEMAID') OR      /* owned by current user */
                /* current user or public role have execute access to type */
                 o$.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o$.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                 /* current user or public role can execute any type */
                 EXISTS (
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184))
/
GRANT SELECT ON sys.imp8ttdu TO PUBLIC;

CREATE OR REPLACE VIEW imp8cdt (
                ownerid, bad) AS
        SELECT  co$.owner#, DECODE(BITAND(c$.defer, 16), 16, 1, 0)
        FROM    sys.cdef$ c$, sys.con$ co$
        WHERE   c$.defer IS NOT NULL AND
                BITAND(c$.defer, 16) = 16 AND
                c$.con# = co$.con#
/
GRANT SELECT ON sys.imp8cdt TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW imp8cdtu  AS
        SELECT  *
        FROM    sys.imp8cdt
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.imp8cdtu TO PUBLIC;

CREATE OR REPLACE VIEW imp8con (
                ctname, tbname, username, intcol) AS
        SELECT  c.name, o.name, u.name, cc.intcol#
        FROM    sys.obj$ o, sys.user$ u, sys.con$ c, sys.ccol$ cc,
                sys.cdef$ cd
        WHERE   o.obj# = cc.obj# AND
                c.con# = cc.con# AND
                o.obj# = cd.obj# AND
                u.user# = c.owner# AND
                cd.con# = c.con# AND
                cd.type# = 3 AND
                BITAND(cd.defer, 8) = 8
/
GRANT SELECT ON sys.imp8con TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW imp9con (
                ctname, tbname, username, intcol, colno, type) AS
        SELECT  c.name, o.name, u.name, cc.intcol#, cc.col#, cd.type#
        FROM    sys.obj$ o, sys.user$ u, sys.con$ c, sys.ccol$ cc,
                sys.cdef$ cd
        WHERE   o.obj# = cc.obj# AND
                c.con# = cc.con# AND
                o.obj# = cd.obj# AND
                u.user# = c.owner# AND
                cd.con# = c.con# AND
                BITAND(cd.defer, 8) = 8
/
GRANT SELECT ON sys.imp9con TO SELECT_CATALOG_ROLE;

REM
REM obtain the tvoid/hash of an existing type ("only latest" check is not
REM required here)
REM
CREATE OR REPLACE VIEW imp9tvoid (
                tname, towner, hash, tvoid, status, typeid, roottoid) AS
        SELECT  o$.name, u$.name, t$.hashcode, t$.tvoid, o$.status, t$.typeid,
                t$.roottoid
        FROM    sys.obj$ o$, sys.user$ u$, sys.type$ t$
        WHERE   o$.type# = 13 AND
                o$.owner# = u$.user# AND
                t$.toid   = o$.oid$ AND
                t$.toid   = t$.tvoid AND                  /* only the latest */
                (userenv('SCHEMAID')  IN (o$.owner#, 0) OR/* System or owner */
                   EXISTS (                          /* user has select role */
                     SELECT  role
                     FROM    sys.session_roles
                     WHERE   role = 'SELECT_CATALOG_ROLE') OR
                  (o$.obj# IN                       /* user has execute priv */
                   (SELECT oa$.obj#
                    FROM   sys.objauth$ oa$
                    WHERE o$.obj# = oa$.obj# AND
                          oa$.grantee# IN  /* granted to current user/public */
                                (SELECT kzsrorol from x$kzsro)  AND
                          privilege# = 12)))                 /* Execute priv */
/
GRANT SELECT ON sys.imp9tvoid TO PUBLIC;


REM
REM all users for IMPORT
REM
CREATE OR REPLACE VIEW imp9usr (name, userid) AS
        SELECT  u.name, u.user#
        FROM    sys.user$ u
        WHERE   u.user# = userenv('SCHEMAID')
/
GRANT SELECT ON sys.imp9usr TO PUBLIC;

REM
REM View to get compatible parameter of target database.
REM
CREATE OR REPLACE VIEW imp9compat (compatible) AS
        SELECT  value
        FROM    v$parameter
        WHERE   name = 'compatible'
/
GRANT SELECT ON sys.imp9compat TO PUBLIC;

REM
REM View to get SYNONYMs for TYPEs.
REM This view is used by import in order to verify that a pre-existing
REM object is a SYNonym for (4) a TYPe.
REM
CREATE OR REPLACE VIEW sys.imp9syn4 (
                synname, synowner, typename, typeowner) AS
        SELECT  o.name, u.name, s.name, s.owner
        FROM    sys.obj$ o, sys.user$ u, sys.syn$ s
        WHERE   s.obj# = o.obj# AND
                u.user# = o.owner# AND
                /* user is sys, or owner, or synonym is PUBLIC */
                (userenv('SCHEMAID') IN (o.owner#, 0) OR o.owner# = 1 OR 
                   EXISTS (                         /* user has select role */
                     SELECT  role
                     FROM    sys.session_roles
                     WHERE   role = 'SELECT_CATALOG_ROLE')) AND
                EXISTS (
                  SELECT ot.obj#
                  FROM sys.obj$ ot
                  WHERE ot.name = s.name AND
                        ot.type# = 13 AND
                        ot.owner# = (
                            SELECT ut.user#
                            FROM sys.user$ ut
                            WHERE ut.name = s.owner))
/
GRANT SELECT ON sys.imp9syn4 TO PUBLIC;

REM
REM View to get the CHUNK size and Endian for a LOB column.
REM This view is used to get the CHUNK size and Endian property bit of an 
REM existing LOB column in a table 
REM (table may have been pre-created or different than Export size).
REM
create or replace view sys.imp_lob_info
    (OWNER, TABLE_NAME, COLUMN_NAME, CHUNK, LITTLE_ENDIAN)
as
select u.name, o.name, c.name, l.chunk * ts.blocksize, 
        DECODE(BITAND(l.property, 512), 512, 1, 0)
from sys.obj$ o, sys.col$ c, sys.tab$ ta, sys.lob$ l, sys.user$ u, sys.ts$ ts
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.ts# = ts.ts#(+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32    /* not partitioned table */
union all
select u.name, o.name, c.name, 
       plob.defchunk * NVL(ts1.blocksize, NVL(
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
        DECODE(BITAND(l.property, 512), 512, 1, 0)
from sys.obj$ o, sys.col$ c, sys.partlob$ plob,
     sys.lob$ l, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32         /* partitioned table */
/
GRANT SELECT ON sys.imp_lob_info TO PUBLIC;


REM
REM View to see if a TYPE is used by any table in the database.
REM
CREATE OR REPLACE VIEW sys.imp10typused
    (OWNER, NAME, OID$) AS
        SELECT u.name, o_tab.name, o_typ.oid$ 
        FROM   sys.obj$ o_tab, sys.user$ u, sys.obj$ o_typ, sys.dependency$ d
        WHERE d.p_obj# = o_typ.obj#
        AND d.d_obj# = o_tab.obj#
        AND o_tab.type# = 2
        AND o_tab.owner# = u.user#
/
GRANT SELECT ON sys.imp10typused TO SELECT_CATALOG_ROLE;


REM
REM View to see if a TYPEID is used by another type in a type hierarchy.
REM
CREATE OR REPLACE VIEW sys.imp10typidused
    (TYPEID, TOID, ROOTTOID) AS
        SELECT typeid, toid, roottoid
        FROM sys.type$
/
GRANT SELECT ON sys.imp10typidused TO SELECT_CATALOG_ROLE;


REM
REM View to see if a table has a BEFORE ROW trigger defined on it.
REM
CREATE OR REPLACE VIEW sys.imp_tab_trig
    (TNAME, OWNER, TYPE) AS
        SELECT o.name, u.name, o.type#
        FROM sys.trigger$ tr, sys.obj$ o, sys.user$ u
        WHERE tr.baseobject = o.obj#
        AND    u.user#      = o.owner#
        AND   tr.type#      = 1             /* BEFORE ROW */
        AND   tr.insert$    = 1             /* for INSERT */
        AND   tr.enabled    = 1
        AND    o.owner#     = userenv('SCHEMAID')
/
GRANT SELECT ON sys.imp_tab_trig TO PUBLIC;


REM
REM View to see if any LOB columns for a table have NOT NULL constraints.
REM
CREATE OR REPLACE VIEW sys.imp_lob_notnull
    (TNAME, OWNER, TYPE, ISNULL) AS
        SELECT o.name, u.name, c.type#, c.null$
        FROM sys.col$ c, sys.obj$ o, sys.user$ u
        WHERE c.obj#   = o.obj#
        AND   u.user#  = o.owner#
        AND   o.owner# = userenv('SCHEMAID')
/
GRANT SELECT ON sys.imp_lob_notnull TO PUBLIC;

-------------------------


REM
REM ****************************************
REM Section 3: Views required by export ONLY
REM ****************************************
REM

REM
REM IOT overflow segments
REM
REM Note tempflags now deprecated
REM
CREATE OR REPLACE VIEW exu8iov (
                objid, dobjid, name, bobjid, owner, ownerid, tablespace, tsno,
                fileno, blockno, audit$, comment$, clusterflag, mtime,
                modified, pctfree$, pctused$, initrans, maxtrans, degree,
                instances, cache, tempflags, property, deflog, tsdeflog) AS
        SELECT  o$.obj#, o$.dataobj#, o$.name, t$.bobj#, u$.name, o$.owner#,
                ts$.name, t$.ts#, t$.file#, t$.block#, t$.audit$, c$.comment$,
                NVL(t$.bobj#, 0), o$.mtime,
                DECODE(BITAND(t$.flags, 1), 1, 1, 0), MOD(t$.pctfree$, 100),
                t$.pctused$, t$.initrans, t$.maxtrans, NVL(t$.degree, 1),
                NVL(t$.instances, 1), DECODE(BITAND(t$.flags, 128), 128, 1, 0),
                MOD(TRUNC(o$.flags / 2), 2), t$.property,
                DECODE(BITAND(t$.flags, 32), 32, 1, 0), ts$.dflogging
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.user$ u$,
                sys.com$ c$
        WHERE   t$.obj# = o$.obj# AND
                t$.ts# = ts$.ts# AND
                u$.user# = o$.owner# AND
                o$.obj# = c$.obj#(+) AND
                c$.col#(+) IS NULL AND
                BITAND(t$.property, 512) = 512
/
GRANT SELECT ON sys.exu8iov TO SELECT_CATALOG_ROLE;

REM
REM current user's overflow segments
REM
CREATE OR REPLACE VIEW exu8iovu AS
        SELECT  *
        FROM    sys.exu8iov
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8iovu TO PUBLIC;

REM
REM iot INCLUDING key columns
REM
CREATE OR REPLACE VIEW exu8ink (
                objid, ownerid, intcolid, name) AS
        SELECT  o$.obj#, o$.owner#, c$.intcol#, c$.name
        FROM    sys.obj$ o$, sys.ind$ i$, sys.col$ c$
        WHERE   i$.bo# = o$.obj# AND
                c$.obj# = o$.obj# AND
                c$.col# = i$.trunccnt AND
                i$.trunccnt != 0
/
GRANT SELECT ON sys.exu8ink TO SELECT_CATALOG_ROLE;

REM
REM current user's INCLUDING key columns
REM
CREATE OR REPLACE VIEW exu8inku AS
        SELECT  *
        FROM    sys.exu8ink
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8inku TO PUBLIC;

REM
REM 9.0 tables for incremental export
REM
REM Notes: modified, altered or new
REM
CREATE OR REPLACE VIEW exu9tabi AS
        SELECT  t.*
        FROM    sys.exu9tab t, sys.incexp i, sys.incvid v
        WHERE   t.name = i.name(+) AND
                t.ownerid = i.owner#(+) AND
                NVL(i.type#, 2) = 2 AND
                BITAND(t.property, 8192) = 0 AND          /* not inner table */
                (BITAND(t.modified, 1) = 1 OR
                 t.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid OR
                 /* determine if it has inner tables that have been
                 ** changed since last incremental export */
                 (BITAND(t.property, 4) = 4 AND          /* has inner tables */
                  EXISTS (
                    SELECT  0
                    FROM    sys.obj$ o2, sys.tab$ t2
                    WHERE   o2.obj# = t2.obj# AND
                            BITAND(t2.property, 8192) = 8192 AND
                            (o2.mtime > i.itime OR
                             BITAND(t2.flags, 1) = 1) AND
                            o2.obj# IN (
                                SELECT  nt.ntab#
                                FROM    sys.ntab$ nt
                                START WITH nt.obj# = t.objid
                                CONNECT BY PRIOR nt.ntab# = nt.obj#))))
/
GRANT SELECT ON sys.exu9tabi TO SELECT_CATALOG_ROLE;

REM
REM 9.0 tables for cumulative export:
REM
REM Notes: modified, last export was inc, altered or new
REM
CREATE OR REPLACE VIEW exu9tabc AS
        SELECT  t.*
        FROM    sys.exu9tab t, sys.incexp i, sys.incvid v
        WHERE   t.name = i.name(+) AND
                t.ownerid = i.owner#(+) AND
                NVL(i.type#, 2) = 2 AND
                BITAND(t.property, 8192) = 0 AND          /* not inner table */
                (BITAND(t.modified, 1) = 1 OR
                 i.itime > NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) OR
                 t.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid OR
                 /* determine if it has inner tables that have been
                 ** changed since last incremental export */
                 (BITAND(t.property, 4) = 4 AND          /* has inner tables */
                  EXISTS (
                    SELECT  0
                    FROM    sys.obj$ o2, sys.tab$ t2
                    WHERE   o2.obj# = t2.obj# AND
                            BITAND(t2.property, 8192) = 8192 AND
                            (o2.mtime > i.itime OR
                             BITAND(t2.flags, 1) = 1) AND
                            o2.obj# IN (
                                SELECT  nt.ntab#
                                FROM    sys.ntab$ nt
                                START WITH nt.obj# = t.objid
                                CONNECT BY PRIOR nt.ntab# = nt.obj#))))
/
GRANT SELECT ON sys.exu9tabc TO SELECT_CATALOG_ROLE;

REM
REM 8.1 tables for incremental export
REM
REM Notes: modified, altered or new
REM
CREATE OR REPLACE VIEW exu81tabi AS
        SELECT  *
        FROM    sys.exu9tabi
        WHERE   BITAND(trigflag, 31) = trigflag
/
GRANT SELECT ON sys.exu81tabi TO SELECT_CATALOG_ROLE;

REM
REM 8.1 tables for cumulative export
REM
REM Notes: modified, last export was inc, altered or new
REM
CREATE OR REPLACE VIEW exu81tabc AS
        SELECT  *
        FROM    sys.exu9tabc
        WHERE   BITAND(trigflag, 31) = trigflag
/
GRANT SELECT ON sys.exu81tabc TO SELECT_CATALOG_ROLE;

REM
REM 8.0 tables for incremental export
REM
REM Notes: modified, altered or new
REM
CREATE OR REPLACE VIEW exu8tabi AS
        SELECT  *
        FROM    sys.exu81tabi
        WHERE   NOT EXISTS (
                    SELECT  *
                    FROM    sys.col$ c$
                    WHERE   c$.obj# = objid AND
                            c$.type# = 208)
/
GRANT SELECT ON sys.exu8tabi TO SELECT_CATALOG_ROLE;

REM
REM 8.0 tables for cumulative export:
REM
REM Notes: modified, last export was inc, altered or new
REM
CREATE OR REPLACE VIEW exu8tabc AS
        SELECT  *
        FROM    sys.exu81tabc
        WHERE   NOT EXISTS (
                    SELECT  *
                    FROM    sys.col$ c$
                    WHERE   c$.obj# = objid AND
                            c$.type# = 208)
/
GRANT SELECT ON sys.exu8tabc TO SELECT_CATALOG_ROLE;

REM
REM partition description for all non-composite partitioned tables
REM
CREATE OR REPLACE VIEW exu8tbp (
                objid, dobjid, bobjid, ownerid, pname, prowcnt, pblkcnt,
                pavgrlen, pflags, partno, hiboundlen, hiboundval, tsname, tsno,
                fileno, blockno, pctfree$, pctused$, initrans, maxtrans,
                deflog, tsdeflog, blevel, leafcnt, distkey, lblkkey, dblkkey,
                clufac, iflags) AS
        SELECT  o$.obj#, o$.dataobj#, tp$.bo#, o$.owner#, o$.subname,
                NVL(tp$.rowcnt, -1), NVL(tp$.blkcnt, -1), NVL(tp$.avgrln, -1),
                tp$.flags, tp$.part#, tp$.hiboundlen, tp$.hiboundval, ts$.name,
                tp$.ts#, tp$.file#, tp$.block#, MOD(tp$.pctfree$, 100),
                tp$.pctused$, tp$.initrans, tp$.maxtrans,
                DECODE(BITAND(tp$.flags, 4), 4, 1, 0), ts$.dflogging, -1, -1,
                -1, -1, -1, -1, -1
        FROM    sys.obj$ o$, sys.tabpart$ tp$, sys.ts$ ts$
        WHERE   o$.type# = 19 AND
                tp$.obj# = o$.obj# AND
                ts$.ts# = tp$.ts#
/
GRANT SELECT ON sys.exu8tbp TO SELECT_CATALOG_ROLE;

REM
REM partition description for current user's non_composite partitioned tables
REM
CREATE OR REPLACE VIEW exu8tbpu AS
        SELECT  *
        FROM    sys.exu8tbp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8tbpu TO PUBLIC;

REM
REM subpartition description for all composite partitioned tables
REM
CREATE OR REPLACE VIEW exu81tbsp (
                objid, dobjid, pobjid, ownerid, subpartno, subpname, tsname,
                fileno, blockno, tsno, prowcnt, pblkcnt, pavgrlen, blevel,
                leafcnt, distkey, lblkkey, dblkkey, clufac, hiboundlen,
                hiboundval, pflags) AS
        SELECT  o.obj#, o.dataobj#, sp.pobj#, o.owner#, sp.subpart#, o.subname,
                ts.name, sp.file#, sp.block#, sp.ts#, NVL(sp.rowcnt, -1),
                NVL(sp.blkcnt, -1), NVL(sp.avgrln, -1), -1, -1, -1, -1, -1, -1,
                sp.hiboundlen, sp.hiboundval, sp.flags
        FROM    sys.obj$ o, sys.tabsubpart$ sp, sys.ts$ ts
        WHERE   o.type# = 34 AND
                sp.obj# = o.obj# AND
                ts.ts# = sp.ts#
/
GRANT SELECT ON sys.exu81tbsp TO SELECT_CATALOG_ROLE;

REM
REM subpartition description for current user's composite partitioned tables
REM
CREATE OR REPLACE VIEW exu81tbspu AS
        SELECT  *
        FROM    sys.exu81tbsp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81tbspu TO PUBLIC;

REM
REM composite partition description for all composite partitioned tables
REM
REM Notes: blocksize should always be non null
REM
CREATE OR REPLACE VIEW exu9tbcp (
                objid, dobjid, bobjid, ownerid, compname, partno, hiboundlen,
                hiboundval, prowcnt, pblkcnt, pavgrlen, tsname, pctfree$,
                pctused$, initrans, maxtrans, iniexts, extsize, minexts,
                maxexts, extpct, flists, freegrp, pcache, deflog, tsdeflog,
                blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, blocksize,
                hscompress, maxsize, pflags) AS
        SELECT  o.obj#, o.dataobj#, cp.bo#, o.owner#, o.subname, cp.part#,
                cp.hiboundlen, cp.hiboundval, NVL(cp.rowcnt, -1),
                NVL(cp.blkcnt, -1), NVL(cp.avgrln, -1), ts.name,
                MOD(cp.defpctfree, 100), cp.defpctused, cp.definitrans,
                cp.defmaxtrans, NVL(cp.definiexts, 0), NVL(cp.defextsize, 0),
                NVL(cp.defminexts, 0), NVL(cp.defmaxexts, 0),
                NVL(cp.defextpct, -1), NVL(cp.deflists, 0),
                NVL(cp.defgroups, 0),
                DECODE(bitand(cp.defbufpool,3), 1, 'KEEP', 2, 'RECYCLE', NULL),
                cp.deflogging, ts.dflogging, -1, -1, -1, -1, -1, -1,
                NVL(ts.blocksize, 2048), cp.spare2, NVL(cp.defmaxsize, 0),
                cp.flags
        FROM    sys.obj$ o, sys.tabcompart$ cp, sys.ts$ ts
        WHERE   cp.obj# = o.obj# AND
                cp.defts# = ts.ts# (+)
/
GRANT SELECT ON sys.exu9tbcp TO SELECT_CATALOG_ROLE;

REM
REM partition description for current user's composite partitioned tables
REM
CREATE OR REPLACE VIEW exu9tbcpu AS
        SELECT  *
        FROM    sys.exu9tbcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9tbcpu TO PUBLIC;

REM
REM Pre V9.0 composite partition desc. adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81tbcp (
                objid, dobjid, bobjid, ownerid, compname, partno, hiboundlen,
                hiboundval, prowcnt, pblkcnt, pavgrlen, tsname, pctfree$,
                pctused$, initrans, maxtrans, iniexts, extsize, minexts,
                maxexts, extpct, flists, freegrp, pcache, deflog, tsdeflog,
                blevel, leafcnt, distkey, lblkkey, dblkkey, clufac) AS
        SELECT  p.objid, p.dobjid, p.bobjid, p.ownerid, p.compname, p.partno,
                p.hiboundlen, p.hiboundval, p.prowcnt, p.pblkcnt, p.pavgrlen,
                p.tsname, p.pctfree$, p.pctused$, p.initrans, p.maxtrans,
                CEIL(p.iniexts * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                CEIL(p.extsize * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                p.minexts, p.maxexts, p.extpct, p.flists, p.freegrp, p.pcache,
                p.deflog, p.tsdeflog, p.blevel, p.leafcnt, p.distkey,
                p.lblkkey, p.dblkkey, p.clufac
        FROM    sys.exu9tbcp p
/
GRANT SELECT ON sys.exu81tbcp TO SELECT_CATALOG_ROLE;

REM
REM pre V9.0 cur user's comp. part. desc. adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81tbcpu AS
        SELECT  *
        FROM    sys.exu81tbcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81tbcpu TO PUBLIC;

REM
REM 9.2 view for getting template subpartition information
REM

CREATE OR REPLACE VIEW exu92tsp (
                objid, ownerid, spart_position, subpname, tsname, tsno,
                flags, hiboundlen, hiboundval) AS
        SELECT  dsp.bo#, o.owner#, dsp.spart_position, dsp.spart_name, 
                ts.name, dsp.ts#, dsp.flags, dsp.hiboundlen,
                dsp.hiboundval
        FROM    sys.defsubpart$ dsp, sys.obj$ o, sys.ts$ ts
        WHERE   dsp.bo# = o.obj# AND
                dsp.ts# = ts.ts# (+) AND
                (userenv('SCHEMAID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu92tsp TO PUBLIC;

REM
REM 9.2 view for getting template subpartition information for lob columns
REM

CREATE OR REPLACE VIEW exu92tspl (
                objid, ownerid, cname, spart_position, intcol#, lobspname,
                tsname, tsno) AS
        SELECT  dspl.bo#, o.owner#, '"'||c.name||'"', dspl.spart_position,
                dspl.intcol#, dspl.lob_spart_name, ts.name,
                dspl.lob_spart_ts#
        FROM    sys.defsubpartlob$ dspl, sys.obj$ o, sys.ts$ ts, sys.col$ c
        WHERE   dspl.bo# = o.obj# AND
                dspl.lob_spart_ts# = ts.ts# (+) AND
                o.obj# = c.obj# AND
                dspl.intcol# = c.col# AND
                (userenv('SCHEMAID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu92tspl TO PUBLIC;

REM
REM get information about a nested table
REM
REM Note tempflags now deprecated
REM
CREATE OR REPLACE VIEW exu8ntb (
                pobjid, objid, name, dobjid, owner, ownerid, tablespace, tsno,
                fileno, blockno, audit$, comment$, clusterflag, mtime,
                modified, pctfree$, pctused$, initrans, maxtrans, degree,
                instances, cache, tempflags, property, deflog, tsdeflog, roid,
                colprop, expname, rowcnt, blkcnt, avgrlen, tflags, ntcolflgs,
                intcolid, objstatus, coltype)
      AS
        SELECT  nt$.obj#, o$.obj#, o$.name, o$.dataobj#, u$.name, o$.owner#,
                ts$.name, t$.ts#, t$.file#, t$.block#, t$.audit$, c$.comment$,
                NVL(t$.bobj#, 0), o$.mtime,
                DECODE(BITAND(t$.flags, 1), 1, 1, 0), MOD(t$.pctfree$, 100),
                t$.pctused$, t$.initrans, t$.maxtrans, NVL(t$.degree, 1),
                NVL(t$.instances, 1), DECODE(BITAND(t$.flags, 128), 128, 1, 0),
                MOD(TRUNC(o$.flags/2), 2), t$.property,
                DECODE(BITAND(t$.flags, 32), 32, 1, 0), ts$.dflogging, o$.oid$,
                cl$.property,
                DECODE(BITAND(cl$.property, 1), 1, a$.name, cl$.name),
                NVL(t$.rowcnt, -1), NVL(t$.blkcnt, -1), NVL(t$.avgrln, -1),
                t$.flags, NVL(ct$.flags, 0), cl$.intcol#, o$.status, 
                cl$.type#
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.user$ u$,
                sys.com$ c$, sys.ntab$ nt$, sys.col$ cl$, sys.attrcol$ a$,
                sys.coltype$ ct$
        WHERE   t$.obj# = o$.obj# AND
                t$.ts# = ts$.ts# AND
                u$.user# = o$.owner# AND
                o$.obj# = c$.obj#(+) AND
                c$.col#(+) IS NULL AND
                nt$.ntab# = o$.obj# AND
                cl$.obj# = ct$.obj# (+) AND
                cl$.intcol# = ct$.intcol# (+)  AND
                nt$.obj# = cl$.obj# AND
                nt$.intcol# = cl$.intcol# AND
                cl$.obj# = a$.obj# (+) AND
                cl$.intcol# = a$.intcol# (+) AND
                BITAND(cl$.property, 32768) != 32768    /* not unused column */
/
GRANT SELECT ON sys.exu8ntb TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8ntbu AS
        SELECT  *
        FROM    sys.exu8ntb
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8ntbu TO PUBLIC;

REM
REM get tables that were included in an incremental/cumulative export that
REM have inner nested tables
REM
REM use for inc/cum when record = yes
REM
CREATE OR REPLACE VIEW exu8tntic (
                objid, ownerid, tname) AS
        SELECT  o$.obj#, o$.owner#, o$.name
        FROM    sys.obj$ o$, sys.tab$ t$
        WHERE   (o$.owner#, o$.name) IN (
                    SELECT  i$.owner#, i$.name      /* tables in this export */
                    FROM    sys.incexp i$, sys.incvid v$
                    WHERE   i$.expid > v$.expid AND
                            i$.type# = 2) AND
                t$.obj# = o$.obj# AND
                BITAND(t$.property, 4) = 4              /* has nested tables */
/
GRANT SELECT ON sys.exu8tntic TO SELECT_CATALOG_ROLE;

REM
REM use for inc when record = no
REM
CREATE OR REPLACE VIEW exu9tnti (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu9tabi                        /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu9tnti TO SELECT_CATALOG_ROLE;

REM
REM use for cum when record = no
REM
CREATE OR REPLACE VIEW exu9tntc (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu9tabc                        /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu9tntc TO SELECT_CATALOG_ROLE;

REM
REM use for inc when record = no
REM
CREATE OR REPLACE VIEW exu81tnti (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu81tabi                       /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu81tnti TO SELECT_CATALOG_ROLE;

REM
REM use for cum when record = no
REM
CREATE OR REPLACE VIEW exu81tntc (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu81tabc                       /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu81tntc TO SELECT_CATALOG_ROLE;

REM
REM 8.0 use for inc when record = no
REM
CREATE OR REPLACE VIEW exu8tnti (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu8tabi                        /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu8tnti TO SELECT_CATALOG_ROLE;

REM
REM 8.0 use for cum when record = no
REM
CREATE OR REPLACE VIEW exu8tntc (
                objid, ownerid, tname) AS
        SELECT  objid, ownerid, name
        FROM    sys.exu8tabc                        /* tables in this export */
        WHERE   BITAND(property, 4) = 4           /* table has nested tables */
/
GRANT SELECT ON sys.exu8tntc TO SELECT_CATALOG_ROLE;

REM
REM partition description for all non_composite partitioned indexes
REM and index organized tables
REM
CREATE OR REPLACE VIEW exu8ixp (
                objid, dobjid, bobjid, ownerid, pname, prowcnt, pblkcnt,
                pavgrlen, pflags, partno, hiboundlen, hiboundval, tsname, tsno,
                fileno, blockno, pctfree$, pctused$, initrans, maxtrans,
                deflog, tsdeflog, blevel, leafcnt, distkey, lblkkey, dblkkey,
                clufac, iflags) AS
        SELECT  o$.obj#, o$.dataobj#, ip$.bo#, o$.owner#, o$.subname,
                NVL(ip$.rowcnt, -1),
                NVL2((
                    SELECT  i$.bo#
                    FROM    sys.ind$ i$
                    WHERE   i$.type# = 4 AND
                            i$.obj# = ip$.bo#),
                    NVL(ip$.leafcnt, -1), -1),  /* leafcnt (blkcnt) if table */
                NVL((
                    SELECT  tp$.avgrln
                    FROM    sys.tabpart$ tp$              /* avglen if table */
                    WHERE   tp$.part# = ip$.part# AND
                            tp$.bo# = (
                                SELECT  i$.bo#
                                FROM    sys.ind$ i$
                                WHERE   i$.type# = 4 AND        /* iot - top */
                                        i$.obj# = ip$.bo#)), -1),
                NVL2((
                    SELECT  i$.bo#
                    FROM    sys.ind$ i$              /* stats flags if table */
                    WHERE   i$.type# = 4 AND
                            i$.obj# = ip$.bo#),
                    ip$.flags, -1),
                ip$.part#, ip$.hiboundlen, ip$.hiboundval, ts$.name, ip$.ts#,
                ip$.file#, ip$.block#, MOD(ip$.pctfree$, 100), 0, ip$.initrans,
                ip$.maxtrans, DECODE(BITAND(ip$.flags, 4), 4, 1, 0),
                ts$.dflogging, NVL(ip$.blevel, -1), NVL(ip$.leafcnt, -1),
                NVL(ip$.distkey, -1), NVL(ip$.lblkkey, -1),
                NVL(ip$.dblkkey, -1), NVL(ip$.clufac, -1), ip$.flags
        FROM    sys.obj$ o$, sys.indpart$ ip$, sys.ts$ ts$
        WHERE   o$.type# = 20 AND
                ip$.obj# = o$.obj# AND
                ts$.ts# = ip$.ts#
/
GRANT SELECT ON sys.exu8ixp TO SELECT_CATALOG_ROLE;

REM
REM partition description for current user's non_composite partitioned indexes.
REM
CREATE OR REPLACE VIEW exu8ixpu AS
        SELECT  *
        FROM    sys.exu8ixp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8ixpu TO PUBLIC;

REM
REM partition description for all composite partitioned indexes
REM
CREATE OR REPLACE VIEW exu9ixcp (
                objid, dobjid, bobjid, ownerid, compname, partno, hiboundlen,
                hiboundval, prowcnt, pblkcnt, pavgrlen, tsname, pctfree$,
                pctused$, initrans, maxtrans, iniexts, extsize, minexts,
                maxexts, extpct, flists, freegrp, pcache, deflog, tsdeflog,
                blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, blocksize,
                hscompress, maxsize, pflags) AS
        SELECT  o.obj#, o.dataobj#, icp.bo#, o.owner#, o.subname, icp.part#,
                icp.hiboundlen, icp.hiboundval, NVL(icp.rowcnt, -1), -1, -1,
                ts.name, MOD(icp.defpctfree, 100), 0, icp.definitrans,
                icp.defmaxtrans, NVL(icp.definiexts, 0),
                NVL(icp.defextsize, 0), NVL(icp.defminexts, 0),
                NVL(icp.defmaxexts, 0), NVL(icp.defextpct, -1),
                NVL(icp.deflists, 0), NVL(icp.defgroups, 0),
                DECODE(bitand(icp.defbufpool,3), 1, 'KEEP', 2, 'RECYCLE', NULL),
                icp.deflogging, ts.dflogging, NVL(icp.blevel, -1),
                NVL(icp.leafcnt, -1), NVL(icp.distkey, -1),
                NVL(icp.lblkkey, -1), NVL(icp.dblkkey, -1),
                NVL(icp.clufac, -1),
                NVL(ts.blocksize, (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = (NVL((
                                SELECT  i$.ts#
                                FROM    sys.ind$ i$
                                WHERE   i$.obj# = icp.bo# AND
                                        i$.type# != 8 AND
                                        i$.type# != 4 AND
                                        BITAND(i$.flags, 4096) = 0),
                                           0)))),
                0, NVL(icp.defmaxsize, 0), icp.flags
        FROM    sys.obj$ o, sys.indcompart$ icp, sys.ts$ ts
        WHERE   icp.obj# = o.obj# AND
                icp.defts# = ts.ts# (+)
/
GRANT SELECT ON sys.exu9ixcp TO SELECT_CATALOG_ROLE;

REM
REM partition description for current user's composite partitioned indexes.
REM
CREATE OR REPLACE VIEW exu9ixcpu AS
        SELECT  *
        FROM    sys.exu9ixcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9ixcpu TO PUBLIC;

REM
REM pre V9.0 composite partition desc. adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81ixcp (
                objid, dobjid, bobjid, ownerid, compname, partno, hiboundlen,
                hiboundval, prowcnt, pblkcnt, pavgrlen, tsname, pctfree$,
                pctused$, initrans, maxtrans, iniexts, extsize, minexts,
                maxexts, extpct, flists, freegrp, pcache, deflog, tsdeflog,
                blevel, leafcnt, distkey, lblkkey, dblkkey, clufac) AS
        SELECT  p.objid, p.dobjid, p.bobjid, p.ownerid, p.compname, p.partno,
                p.hiboundlen, p.hiboundval, p.prowcnt, p.pblkcnt, p.pavgrlen,
                p.tsname, p.pctfree$, p.pctused$, p.initrans, p.maxtrans,
                CEIL(p.iniexts * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                CEIL(p.extsize * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                p.minexts, p.maxexts, p.extpct, p.flists, p.freegrp, p.pcache,
                p.deflog, p.tsdeflog, p.blevel, p.leafcnt, p.distkey,
                p.lblkkey, p.dblkkey, p.clufac
        FROM    sys.exu9ixcp p
/
GRANT SELECT ON sys.exu81ixcp TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's comp. part. desc. adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81ixcpu AS
        SELECT  *
        FROM    sys.exu81ixcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81ixcpu TO PUBLIC;

REM
REM subpartition description for all composite partitioned indexes
REM
CREATE OR REPLACE VIEW exu81ixsp (
                objid, dobjid, pobjid, ownerid, subpartno, subpname, tsname,
                fileno, blockno, tsno, prowcnt, pblkcnt, pavgrlen, blevel,
                leafcnt, distkey, lblkkey, dblkkey, clufac, hiboundlen,
                hiboundval, pflags) AS
        SELECT  o.obj#, o.dataobj#, isp.pobj#, o.owner#, isp.subpart#,
                o.subname, ts.name, isp.file#, isp.block#, isp.ts#,
                NVL(isp.rowcnt, -1), -1, -1, NVL(isp.blevel, -1),
                NVL(isp.leafcnt, -1), NVL(isp.distkey, -1),
                NVL(isp.lblkkey, -1), NVL(isp.dblkkey, -1),
                NVL(isp.clufac, -1), isp.hiboundlen, isp.hiboundval, isp.flags
        FROM    sys.obj$ o, sys.indsubpart$ isp, sys.ts$ ts
        WHERE   o.type# = 35 AND
                isp.obj# = o.obj# AND
                ts.ts# = isp.ts#
/
GRANT SELECT ON sys.exu81ixsp TO SELECT_CATALOG_ROLE;

REM
REM subpartition description for current user's composite partitioned indexes.
REM
CREATE OR REPLACE VIEW exu81ixspu AS
        SELECT  *
        FROM    sys.exu81ixsp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81ixspu TO PUBLIC;

REM
REM partitioning key columns for all partitioned tables. NOTE: property,
REM function, funclen added in anticipation of support for virtual cols. as
REM partitioning keys and to keep table and index part. views in synch.
REM
CREATE OR REPLACE VIEW exu8pok (
                objid, ownerid, posno, name, property, function, funclen) AS
        SELECT  o$.obj#, o$.owner#, p$.pos#,
                DECODE(BITAND(c$.property, 1), 1, a$.name, c$.name),
                c$.property, c$.default$, c$.deflength
        FROM    sys.obj$ o$, sys.partcol$ p$, sys.col$ c$, sys.attrcol$ a$
        WHERE   o$.obj# = c$.obj# AND
                o$.obj# = p$.obj# AND
                p$.intcol# = c$.intcol# AND
                p$.obj# = a$.obj# (+) AND
                p$.intcol# = a$.intcol# (+)
/
GRANT SELECT ON sys.exu8pok TO SELECT_CATALOG_ROLE;

REM
REM partitioning key columns for current user's partitioned tables
REM
CREATE OR REPLACE VIEW exu8poku AS
        SELECT  *
        FROM    sys.exu8pok
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8poku TO PUBLIC;

REM
REM subpartitioning key columns for all composite partitioned (R+H) tables.
REM NOTE: property, function, funclen added in anticipation of support for
REM function, funclen added in anticipation of support for virtual cols. as
REM partitioning keys and to keep table and index part. views in synch.
REM
CREATE OR REPLACE VIEW exu81spok (
                objid, ownerid, posno, name, property, function, funclen) AS
        SELECT  o.obj#, o.owner#, spc.pos#,
                DECODE(BITAND(c.property, 1), 1, a.name, c.name),
                c.property, c.default$, c.deflength
        FROM    sys.obj$ o, sys.subpartcol$ spc, sys.col$ c, sys.attrcol$ a
        WHERE   o.obj# = c.obj# AND
                o.obj# = spc.obj# AND
                spc.intcol# = c.intcol# AND
                spc.obj# = a.obj# (+) AND
                spc.intcol# = a.intcol# (+)
/
GRANT SELECT ON sys.exu81spok TO SELECT_CATALOG_ROLE;

REM
REM subpartitioning key columns for current user's composite partitioned tables
REM
CREATE OR REPLACE VIEW exu81spoku AS
        SELECT  *
        FROM    sys.exu81spok
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81spoku TO PUBLIC;

REM
REM partitioning key columns for all partitioned indexes
REM
CREATE OR REPLACE VIEW exu8poki (
                objid, ownerid, posno, name, property, function, funclen) AS
        SELECT  o.obj#, o.owner#, p.pos#,
                DECODE(BITAND(c.property, 1), 1, a.name, c.name),
                c.property, c.default$, c.deflength
        FROM    sys.obj$ o, sys.partcol$ p, sys.ind$ i, sys.col$ c,
                sys.attrcol$ a
        WHERE   o.obj# = p.obj# AND
                i.obj# = o.obj# AND
                i.bo# = c.obj# AND
                p.intcol# = c.intcol# AND
                c.obj# = a.obj# (+) AND
                c.intcol# = a.intcol# (+)
/
GRANT SELECT ON sys.exu8poki TO SELECT_CATALOG_ROLE;

REM
REM partitioning key columns for current user's partitioned indexes
REM
CREATE OR REPLACE VIEW exu8pokiu AS
        SELECT  *
        FROM    sys.exu8poki
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8pokiu TO PUBLIC;

REM
REM subpartitioning key columns for all composite partitioned indexes
REM not used in 81
REM
CREATE OR REPLACE VIEW exu81spoki (
                objid, ownerid, posno, name, property, function, funclen) AS
        SELECT  o.obj#, o.owner#, sp.pos#, c.name, c.property, c.default$,
                c.deflength
        FROM    sys.obj$ o, sys.subpartcol$ sp, sys.ind$ i, sys.col$ c
        WHERE   o.obj# = sp.obj# AND
                i.obj# = o.obj# AND
                i.bo# = c.obj# AND
                sp.intcol# = c.intcol#
/
GRANT SELECT ON sys.exu81spoki TO SELECT_CATALOG_ROLE;

REM
REM subpartitioning key columns for current user's composite
REM partitioned indexes
REM
CREATE OR REPLACE VIEW exu81spokiu AS
        SELECT  *
        FROM    sys.exu81spoki
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81spokiu TO PUBLIC;

REM
REM table/index level storage definition for all partitioned tables/indexes
REM description on partitioned object
REM
CREATE OR REPLACE VIEW exu9pds (
                objid, type, ownerid, ptype, subptype, pflag, pcnt, pkcnt,
                pctfree$, pctused$, initrans, maxtrans, iniexts, extsize,
                minexts, maxexts, extpct, flists, freegrp, tsname, deflog,
                pcache, blocksize, hscompress, defsubpcnt, maxsize) AS
        SELECT  o$.obj#, o$.type#, o$.owner#, po$.parttype,
                MOD(po$.spare2, 256), NVL(po$.flags, 0), po$.partcnt,
                po$.partkeycols, MOD(po$.defpctfree, 100), po$.defpctused,
                po$.definitrans, po$.defmaxtrans, po$.deftiniexts,
                po$.defextsize, po$.defminexts, po$.defmaxexts, po$.defextpct,
                po$.deflists, po$.defgroups, ts$.name, po$.deflogging,
                DECODE(bitand(po$.spare1,3), 1, 'KEEP', 2, 'RECYCLE', NULL),
                NVL(ts$.blocksize, 2048),      /* non null for table/indexes */
                (po$.spare2/4294967296),  /* divide by ^x80000000 for byte 4 */
                MOD(TRUNC(po$.spare2/65536), 65536), po$.defmaxsize
        FROM    sys.partobj$ po$, sys.obj$ o$, sys.ts$ ts$
        WHERE   po$.defts# = ts$.ts# (+) AND
                po$.obj# = o$.obj#
/
GRANT SELECT ON sys.exu9pds TO SELECT_CATALOG_ROLE;

REM
REM User's table/index level storage definition partitioned tables/indexes
REM
CREATE OR REPLACE VIEW exu9pdsu AS
        SELECT  *
        FROM    sys.exu9pds
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9pdsu TO PUBLIC;

REM
REM pre V9.0 part. table/index level storage def. adjusted for TS specific
REM blocksizes
REM
CREATE OR REPLACE VIEW exu8pds (
                objid, type, ownerid, ptype, subptype, pflag, pcnt, pkcnt,
                pctfree$, pctused$, initrans, maxtrans, iniexts, extsize,
                minexts, maxexts, extpct, flists, freegrp, tsname, deflog,
                pcache) AS
        SELECT  p.objid, p.type, p.ownerid, p.ptype, p.subptype, p.pflag,
                p.pcnt, p.pkcnt, p.pctfree$, p.pctused$, p.initrans,
                p.maxtrans,
                NVL(CEIL(p.iniexts * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                    NULL),
                NVL(CEIL(p.extsize * (p.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                    NULL),
                p.minexts, p.maxexts, p.extpct, p.flists, p.freegrp, p.tsname,
                p.deflog, p.pcache
        FROM    sys.exu9pds p
/
GRANT SELECT ON sys.exu8pds TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's part. table/index level storage def. adjusted for
REM TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8pdsu AS
        SELECT  *
        FROM    sys.exu8pds
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8pdsu TO PUBLIC;

REM
REM not null constraints on columns
REM
CREATE OR REPLACE VIEW exu8colnn (
                tobjid, intcolid, conname, isnull, enabled, defer) AS
        SELECT  cc$.obj#, cc$.intcol#, con$.name, 1, NVL(cd$.enabled, 0),
                NVL(cd$.defer, 0)
        FROM    sys.con$ con$, sys.cdef$ cd$, sys.ccol$ cc$
        WHERE   cc$.con# = cd$.con# AND
                cd$.con# = con$.con# AND
                cd$.type# IN (7, 11)
/
GRANT SELECT ON sys.exu8colnn TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8col_temp (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                colprop, comment$, dfltlen, enabled, defer, flags, charsetid,
                charsetform, fsprecision, lfprecision, charlen) AS
        SELECT  o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length,
                c$.precision#, c$.scale, c$.type#, NVL(cn.isnull, 0),
                cn.conname, c$.col#, c$.intcol#, c$.segcol#, c$.property,
                com$.comment$, NVL(c$.deflength, 0), cn.enabled, cn.defer,
                NVL(o$.flags, 0), NVL(c$.charsetid, 0), NVL(c$.charsetform, 0),
                c$.scale, c$.precision#, c$.spare3
        FROM    sys.col$ c$, sys.obj$ o$, sys.user$ u$, sys.com$ com$,
                sys.exu8colnn cn
        WHERE   c$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                c$.obj# = com$.obj#(+) AND
                c$.intcol# = com$.col#(+) AND
                c$.obj# = cn.tobjid AND
                c$.intcol# = cn.intcolid
      UNION ALL
        SELECT  o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length,
                c$.precision#, c$.scale, c$.type#, 0, NULL, c$.col#,
                c$.intcol#, c$.segcol#, c$.property, com$.comment$,
                NVL(c$.deflength, 0), 0, 0, NVL(o$.flags, 0),
                NVL(c$.charsetid, 0), NVL(c$.charsetform, 0), c$.scale,
                c$.precision#, c$.spare3
        FROM    sys.col$ c$, sys.obj$ o$, sys.user$ u$, sys.com$ com$
        WHERE   c$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                c$.obj# = com$.obj#(+) AND
                c$.intcol# = com$.col#(+) AND
                BITAND(c$.property, 32768) != 32768 AND /* not unused column */
                NOT EXISTS (
                    SELECT  NULL
                    FROM    sys.exu8colnn cn
                    WHERE   c$.obj# = cn.tobjid AND
                            c$.intcol# = cn.intcolid)
/
GRANT SELECT ON sys.exu8col_temp TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8col (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, charsetid, charsetform, fsprecision,
                lfprecision, charlen, tflags) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, type, isnull, conname, colid, intcolid,
                segcolid, comment$, default$, dfltlen, enabled, defer,
                v$.flags, colprop, '', '', v$.charsetid, v$.charsetform,
                v$.fsprecision, v$.lfprecision, v$.charlen,  NVL(ct$.flags, 0)
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                v$.tobjid = ct$.obj# (+) AND
                (BITAND(v$.colprop, 32) != 32 OR      /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND(v$.colprop, 4194304) = 4194304) /* RLS hidden column */
/
GRANT SELECT ON sys.exu8col TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu8colu AS
        SELECT  *
        FROM    sys.exu8col
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8colu TO PUBLIC;

CREATE OR REPLACE VIEW exu8col_temp_tts_unused_col (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                colprop, comment$, dfltlen, enabled, defer, flags, charsetid,
                charsetform, fsprecision, lfprecision, charlen) AS
        SELECT  o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length,
                c$.precision#, c$.scale, c$.type#, NVL(cn.isnull, 0),
                cn.conname, c$.col#, c$.intcol#, c$.segcol#, c$.property,
                com$.comment$, NVL(c$.deflength, 0), cn.enabled, cn.defer,
                NVL(o$.flags, 0), NVL(c$.charsetid, 0), NVL(c$.charsetform, 0),
                c$.scale, c$.precision#, c$.spare3
        FROM    sys.col$ c$, sys.obj$ o$, sys.user$ u$, sys.com$ com$,
                sys.exu8colnn cn
        WHERE   c$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                c$.obj# = com$.obj#(+) AND
                c$.segcol# = com$.col#(+) AND
                c$.obj# = cn.tobjid AND
                c$.intcol# = cn.intcolid
      UNION ALL
        SELECT  o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length,
                c$.precision#, c$.scale, c$.type#, 0, NULL, c$.col#,
                c$.intcol#, c$.segcol#, c$.property, com$.comment$,
                NVL(c$.deflength, 0), 0, 0, NVL(o$.flags, 0),
                NVL(c$.charsetid, 0), NVL(c$.charsetform, 0), c$.scale,
                c$.precision#, c$.spare3
        FROM    sys.col$ c$, sys.obj$ o$, sys.user$ u$, sys.com$ com$
        WHERE   c$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                c$.obj# = com$.obj#(+) AND
                c$.segcol# = com$.col#(+) AND
                NOT EXISTS (
                    SELECT  NULL
                    FROM    sys.exu8colnn cn
                    WHERE   c$.obj# = cn.tobjid AND
                            c$.intcol# = cn.intcolid)
/
GRANT SELECT ON sys.exu8col_temp_tts_unused_col TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8col_tts_unused_col (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, charsetid, charsetform, fsprecision,
                lfprecision, charlen, tflags) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, type, isnull, conname, colid, intcolid,
                segcolid, comment$, default$, dfltlen, enabled, defer,
                v$.flags, colprop, '', '', v$.charsetid, v$.charsetform,
                v$.fsprecision, v$.lfprecision, v$.charlen,  NVL(ct$.flags, 0)
        FROM    sys.exu8col_temp_tts_unused_col v$, sys.col$ c$,
                sys.coltype$ ct$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                v$.tobjid = ct$.obj# (+)  AND
                (BITAND(v$.colprop,32768) = 32768 OR        /* unused column */
                 BITAND(v$.colprop, 32) != 32 OR      /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND(v$.colprop, 4194304) = 4194304) /* RLS hidden column */
/
GRANT SELECT ON sys.exu8col_tts_unused_col TO SELECT_CATALOG_ROLE;

REM
REM view to access columns in tables containing object oriented columns
REM in normal tables
REM
CREATE OR REPLACE VIEW exu8coo (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, charsetid, charsetform, fsprecision,
                lfprecision, charlen, tflags) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name, v$.charsetid, v$.charsetform, v$.fsprecision,
                v$.lfprecision, v$.charlen, NVL(ct$.flags,0)
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   (BITAND (v$.colprop, 32) != 32 OR     /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND (v$.colprop, 4194304) = 4194304) AND/* RLS hidden col*/
                v$.tobjid = c$.obj# (+) AND
                v$.intcolid = c$.intcol# (+) AND
                v$.tobjid = ct$.obj# (+) AND
                v$.intcolid = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#,13) = 13
/
GRANT SELECT ON sys.exu8coo TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu8coou AS
        SELECT  *
        FROM    sys.exu8coo
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8coou TO PUBLIC;

REM
REM view to access columns in extent tables, extent views and inner nested
REM tables
REM
CREATE OR REPLACE VIEW exu8coe (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, colclass, charsetid, charsetform,
                fsprecision, lfprecision, charlen, tflags) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name,
                DECODE (v$.name, 'SYS_NC_OID$', 1, 'NESTED_TABLE_ID', 2,
                        'SYS_NC_ROWINFO$', 3, 100),
                v$.charsetid, v$.charsetform, v$.fsprecision, v$.lfprecision,
                v$.charlen, NVL(ct$.flags, 0)
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                (BITAND(v$.colprop, 2) = 2 OR                 /* SYS_NC_OID$ */
                 BITAND(v$.colprop, 16) = 16 OR           /* NESTED_TABLE_ID */
                 BITAND(v$.colprop, 512) = 512) AND       /* SYS_NC_ROWINFO$ */
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#, -1) != 10 /* bug 882543: no non-existent types */
/
GRANT SELECT ON sys.exu8coe TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu8coeu AS
        SELECT  *
        FROM    sys.exu8coe
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8coeu TO PUBLIC;

REM
REM view to access columns in extent tables, extent views and inner nested
REM tables (v9.2+ with optional type synonyms)
REM
CREATE OR REPLACE VIEW exu9coe (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, colclass, charsetid, charsetform,
                fsprecision, lfprecision, charlen, tflags, typesyn) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name,
                DECODE (v$.name, 'SYS_NC_OID$', 1, 'NESTED_TABLE_ID', 2,
                        'SYS_NC_ROWINFO$', 3, 100),
                v$.charsetid, v$.charsetform, v$.fsprecision, v$.lfprecision,
                v$.charlen, NVL(ct$.flags, 0), s$.name
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$, sys.obj$ s$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                (BITAND(v$.colprop, 2) = 2 OR                 /* SYS_NC_OID$ */
                 BITAND(v$.colprop, 16) = 16 OR           /* NESTED_TABLE_ID */
                 BITAND(v$.colprop, 512) = 512) AND       /* SYS_NC_ROWINFO$ */
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#, -1) != 10 /* bug 882543: no non-existent types */
                AND ct$.synobj# IS NOT NULL AND /* has type synonym */
                ct$.synobj# = s$.obj#
      UNION ALL
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name,
                DECODE (v$.name, 'SYS_NC_OID$', 1, 'NESTED_TABLE_ID', 2,
                        'SYS_NC_ROWINFO$', 3, 100),
                v$.charsetid, v$.charsetform, v$.fsprecision, v$.lfprecision,
                v$.charlen, NVL(ct$.flags, 0), NULL
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                (BITAND(v$.colprop, 2) = 2 OR                 /* SYS_NC_OID$ */
                 BITAND(v$.colprop, 16) = 16 OR           /* NESTED_TABLE_ID */
                 BITAND(v$.colprop, 512) = 512) AND       /* SYS_NC_ROWINFO$ */
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#, -1) != 10 /* bug 882543: no non-existent types */
                AND ct$.synobj# IS NULL /* does not have type synonym */
/
GRANT SELECT ON sys.exu9coe TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu9coeu AS
        SELECT  *
        FROM    sys.exu9coe
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9coeu TO PUBLIC;

REM
REM Extention of exu9coe to include 'normal' columns that may have 
REM default values.  The corrisponding code in exp only uses that column
REM information when generating default statements for the object table.
REM
CREATE OR REPLACE VIEW exu10coe (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, colclass, charsetid, charsetform,
                fsprecision, lfprecision, charlen, tflags, typesyn) AS
        SELECT  * 
        FROM    sys.exu9coe 
      UNION ALL
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name,
                DECODE (v$.name, 'SYS_NC_OID$', 1, 'NESTED_TABLE_ID', 2,
                        'SYS_NC_ROWINFO$', 3, 100),
                v$.charsetid, v$.charsetform, v$.fsprecision, v$.lfprecision,
                v$.charlen, NVL(ct$.flags, 0), NULL
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                c$.intcol# = ct$.intcol# (+) AND
                (BITAND(v$.colprop, 32)      != 32 OR          /* not hidden */
                 BITAND(v$.colprop, 1048608) = 1048608 OR  /* snapsht hidden */
                 BITAND(v$.colprop, 4194304) = 4194304) AND    /* RLS Hidden */
                c$.obj# = ct$.obj# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#, -1) != 10 /* bug 882543: no non-existent types */
/
GRANT SELECT ON sys.exu10coe TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu10coeu AS
        SELECT  *
        FROM    sys.exu10coe
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10coeu TO PUBLIC;

REM
REM view to access columns in scalar inner nested tables
REM
CREATE OR REPLACE VIEW exu8csn (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, colclass, charsetid, charsetform,
                fsprecision, lfprecision, charlen, tflags) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name,
                DECODE (v$.name, 'NESTED_TABLE_ID', 2, 'COLUMN_VALUE', 3, 100),
                v$.charsetid, v$.charsetform, v$.fsprecision, v$.lfprecision,
                v$.charlen, NVL(ct$.flags, 0)
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   c$.obj# = v$.tobjid AND
                c$.intcol# = v$.intcolid AND
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#, -1) != 10 /* bug 882543: no non-existent types */
/
GRANT SELECT ON sys.exu8csn TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu8csnu AS
        SELECT  *
        FROM    sys.exu8csn
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8csnu TO PUBLIC;

REM
REM 9.0+ version of column views for TYPE SYNONYM support
REM 
REM view to access columns in tables containing object oriented columns
REM in normal tables returning synonym of type if any was used
REM
CREATE OR REPLACE VIEW exu9coo (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, charsetid, charsetform, fsprecision,
                lfprecision, charlen, tflags, typesyn) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name, v$.charsetid, v$.charsetform, v$.fsprecision,
                v$.lfprecision, v$.charlen, NVL(ct$.flags,0), NULL
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   (BITAND (v$.colprop, 32) != 32 OR     /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND (v$.colprop, 4194304) = 4194304) AND/* RLS hidden col*/
                v$.tobjid = c$.obj# (+) AND
                v$.intcolid = c$.intcol# (+) AND
                v$.tobjid = ct$.obj# (+) AND
                v$.intcolid = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#,13) = 13 AND
                ct$.synobj# IS NULL
      UNION ALL
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name, v$.charsetid, v$.charsetform, 
                v$.fsprecision, v$.lfprecision, v$.charlen, NVL(ct$.flags,0),
                so$.name
        FROM    sys.exu8col_temp v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$, sys.obj$ so$
        WHERE   (BITAND (v$.colprop, 32) != 32 OR     /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND (v$.colprop, 4194304) = 4194304) AND/* RLS hidden col*/
                v$.tobjid = c$.obj# (+) AND
                v$.intcolid = c$.intcol# (+) AND
                v$.tobjid = ct$.obj# (+) AND
                v$.intcolid = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#,13) = 13 AND so$.obj# = ct$.synobj#
/
GRANT SELECT ON sys.exu9coo TO SELECT_CATALOG_ROLE;

REM
REM 10.2+ version of column views for TTS mode
REM 
REM view to include unused columns
REM
CREATE OR REPLACE VIEW exu9coo_tts_unused_col (
                tobjid, towner, townerid, tname, name, length, precision,
                scale, type, isnull, conname, colid, intcolid, segcolid,
                comment$, default$, dfltlen, enabled, defer, flags, colprop,
                adtname, adtowner, charsetid, charsetform, fsprecision,
                lfprecision, charlen, tflags, typesyn) AS
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name, v$.charsetid, v$.charsetform, v$.fsprecision,
                v$.lfprecision, v$.charlen, NVL(ct$.flags,0), NULL
        FROM    sys.exu8col_temp_tts_unused_col v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$
        WHERE   ((BITAND(v$.colprop, 32768) = 32768 AND /* unused col */
                  BITAND(v$.colprop, 1) != 1) OR        /* NOT ADT attr column */ 
                 (BITAND(v$.colprop, 32) != 32 OR       /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND (v$.colprop, 4194304) = 4194304)) AND/* RLS hidden col*/
                v$.tobjid = c$.obj# (+) AND
                v$.intcolid = c$.intcol# (+) AND
                v$.tobjid = ct$.obj# (+) AND
                v$.intcolid = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#,13) = 13 AND
                ct$.synobj# IS NULL
      UNION ALL
        SELECT  tobjid, towner, townerid, v$.tname, v$.name, v$.length,
                v$.precision, v$.scale, v$.type, v$.isnull, v$.conname,
                v$.colid, v$.intcolid, v$.segcolid, v$.comment$, default$,
                v$.dfltlen, v$.enabled, v$.defer, v$.flags, v$.colprop,
                o$.name, u$.name, v$.charsetid, v$.charsetform, 
                v$.fsprecision, v$.lfprecision, v$.charlen, NVL(ct$.flags,0),
                so$.name
        FROM    sys.exu8col_temp_tts_unused_col v$, sys.col$ c$, sys.coltype$ ct$,
                sys.obj$ o$, sys.user$ u$, sys.obj$ so$
        WHERE   ((BITAND(v$.colprop, 32768) = 32768 AND /* unused col */
                  BITAND(v$.colprop, 1) != 1) OR        /* NOT ADT attr column */
                (BITAND(v$.colprop, 32) != 32 OR        /* not a hidden column */
                 BITAND(v$.colprop, 1048608)= 1048608 OR/*snapshot hidden col*/
                 BITAND (v$.colprop, 4194304) = 4194304)) AND/* RLS hidden col*/
                v$.tobjid = c$.obj# (+) AND
                v$.intcolid = c$.intcol# (+) AND
                v$.tobjid = ct$.obj# (+) AND
                v$.intcolid = ct$.intcol# (+) AND
                NVL(ct$.toid, HEXTORAW('00')) = o$.oid$ (+) AND
                NVL(o$.owner#, -1) = u$.user# (+) AND
                NVL(o$.type#,13) = 13 AND so$.obj# = ct$.synobj#
/
GRANT SELECT ON sys.exu9coo_tts_unused_col TO SELECT_CATALOG_ROLE;

REM
REM current user's columns
REM
CREATE OR REPLACE VIEW exu9coou AS
        SELECT  *
        FROM    sys.exu9coo
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9coou TO PUBLIC;

REM
REM view to access column comments for extent table, inner nested tables
REM and extent views
REM
CREATE OR REPLACE VIEW exu8cmt (
                userid, objid, colno, colname, cmnt) AS
        SELECT  o$.owner#, cm$.obj#, cm$.col#, c$.name, cm$.comment$
        FROM    sys.com$ cm$, sys.obj$ o$, sys.col$ c$
        WHERE   o$.obj# = cm$.obj# AND
                c$.obj# = cm$.obj# AND
                c$.intcol# = cm$.col#
/
GRANT SELECT ON sys.exu8cmt TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8cmtu AS
        SELECT  *
        FROM    sys.exu8cmt
        WHERE   userid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8cmtu TO PUBLIC;

REM
REM analyze statistics for columns (except for samples)
REM
CREATE OR REPLACE VIEW exu8asc (
                tobjid, pobjid, townerid, colname, intcol, distcount, lowval,
                hival, density, nullcount, avgcln, cflags) AS
        SELECT  c$.obj#, hh$.obj#, o$.owner#, c$.name, hh$.intcol#, 
                hh$.distcnt, 
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1 
                     then hh$.lowval
                     else null
                end,
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then hh$.hival
                     else null
                end,
                hh$.density, hh$.null_cnt,
                hh$.avgcln, hh$.spare2
        FROM    sys.hist_head$ hh$, sys.obj$ o$, sys.obj$ ot$, sys.col$ c$
        WHERE   hh$.obj# = o$.obj# AND
                c$.obj# = ot$.obj# AND
                o$.owner# = ot$.owner# AND
                hh$.intcol# = c$.intcol#
/
GRANT SELECT ON sys.exu8asc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8ascu AS
        SELECT  *
        FROM    sys.exu8asc
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8ascu TO PUBLIC;

REM
REM analyze statistics for columns (except for samples) v10
REM
CREATE OR REPLACE VIEW exu10asc (
                tobjid, pobjid, townerid, colname, intcol, distcount, lowval,
                hival, density, nullcount, avgcln, cflags, property) AS
        SELECT  c$.obj#, hh$.obj#, o$.owner#, REPLACE(c$.name, '''', ''''''),
                hh$.intcol#, hh$.distcnt, 
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then hh$.lowval
                     else null
                end,
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then hh$.hival
                     else null
                end,
                hh$.density, hh$.null_cnt,
                hh$.avgcln, hh$.spare2, c$.property
        FROM    sys.hist_head$ hh$, sys.obj$ o$, sys.obj$ ot$, sys.col$ c$
        WHERE   hh$.obj# = o$.obj# AND
                c$.obj# = ot$.obj# AND
                o$.owner# = ot$.owner# AND
                hh$.intcol# = c$.intcol#
/
GRANT SELECT ON sys.exu10asc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10ascu AS
        SELECT  *
        FROM    sys.exu10asc
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10ascu TO PUBLIC;

REM
REM histogram samples for analyze statistics
REM
CREATE OR REPLACE VIEW exu8hst (
                pobjid, townerid, intcol, bucket, endpthash, endptval) AS
        SELECT  h$.obj#, o$.owner#, h$.intcol#, h$.bucket,
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then h$.endpoint
                     else null
                end,
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then h$.epvalue
                     else null
                end
        FROM    sys.histgrm$ h$, sys.obj$ o$
        WHERE   h$.obj# = o$.obj#
      UNION ALL
        SELECT  h$.obj#, o$.owner#, h$.intcol#, 0, 
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then h$.minimum
                     else null
                end, 
                NULL
        FROM    sys.hist_head$ h$, sys.obj$ o$
        WHERE   h$.obj# = o$.obj# AND
                h$.bucket_cnt = 1
      UNION ALL
        SELECT  h$.obj#, o$.owner#, h$.intcol#, 1, 
                case when SYS_OP_DV_CHECK(o$.name, o$.owner#) = 1
                     then h$.maximum
                     else null
                end, 
                NULL
        FROM    sys.hist_head$ h$, sys.obj$ o$
        WHERE   h$.obj# = o$.obj# AND
                h$.bucket_cnt = 1
/
GRANT SELECT ON sys.exu8hst TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8hstu AS
        SELECT  *
        FROM    sys.exu8hst
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8hstu TO PUBLIC;

REM
REM all columns for index
REM
CREATE OR REPLACE VIEW exu8ico (
                tobjid, towner, townerid, tname, name, btname, colid, colnum,
                property, bobjid, function, funclen) AS
        SELECT  io$.obj#, u$.name, io$.owner#, io$.name,
                DECODE(BITAND(c$.property, 1), 1, a$.name, c$.name), to$.name,
                ic$.pos#,
                DECODE(BITAND(i$.property, 1024), 0, i$.cols, i$.intcols),
                c$.property, ic$.bo#, c$.default$, c$.deflength
        FROM    sys.col$ c$, sys.icol$ ic$, sys.obj$ io$, sys.user$ u$,
                sys.attrcol$ a$, sys.obj$ to$, sys.ind$ i$
        WHERE   c$.obj# = ic$.bo# AND
                ((BITAND(i$.property, 1024) = 1024 AND
                  c$.intcol# = ic$.spare2) OR
                 ((NOT (BITAND(i$.property, 1024) = 1024)) AND
                 c$.intcol# = ic$.intcol#)) AND
                ic$.obj# = io$.obj# AND
                io$.owner# = u$.user# AND
                i$.bo# = to$.obj# AND
                i$.obj# = io$.obj# AND
                c$.obj# = a$.obj# (+) AND
                c$.intcol# = a$.intcol# (+) AND
                (userenv('SCHEMAID') = 0 OR (userenv('SCHEMAID') = io$.owner# AND
				 userenv('SCHEMAID') = to$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu8ico TO PUBLIC;

REM
REM current user's index columns
REM
CREATE OR REPLACE VIEW exu8icou AS
        SELECT  *
        FROM    sys.exu8ico
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8icou TO PUBLIC;

REM
REM FROM tables for bitmap join index
REM
CREATE OR REPLACE VIEW exu9bjf (
                iobjid, tabname, towner, tobjid) AS
        SELECT  io$.obj#, to$.name, u$.name, to$.obj#
        FROM    sys.jijoin$ ji$, sys.obj$ to$, sys.user$ u$, sys.obj$ io$
        WHERE   to$.obj# IN (ji$.tab1obj#, ji$.tab2obj#) AND
                to$.owner# = u$.user# AND
                ji$.obj# = io$.obj# AND
                (userenv('SCHEMAID') IN (0, io$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
        GROUP BY io$.obj#, to$.name, u$.name, to$.obj#
/
GRANT SELECT ON sys.exu9bjf TO PUBLIC;

REM
REM Equijoin list for bitmap join index
REM
CREATE OR REPLACE VIEW exu9bjw (
                iobjid, col1name, t1objid, col2name, t2objid) AS
        SELECT  ji$.obj#, c1$.name, ji$.tab1obj#, c2$.name, ji$.tab2obj#
        FROM    sys.jijoin$ ji$, sys.col$ c1$, sys.col$ c2$, sys.obj$ io$
        WHERE   ji$.tab1col# = c1$.intcol# AND
                ji$.tab1obj# = c1$.obj# AND
                ji$.tab2col# = c2$.intcol# AND
                ji$.tab2obj# = c2$.obj# AND
                ji$.obj# = io$.obj# AND
                (userenv('SCHEMAID') IN (0, io$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9bjw TO PUBLIC;

REM
REM all users' default roles
REM
CREATE OR REPLACE VIEW exu8dfr (
                name, userid, role, roleid) AS
        SELECT  u$.name, u$.user#, u1$.name, u1$.user#
        FROM    sys.user$ u$, sys.user$ u1$, sys.defrole$ d$
        WHERE   u$.user# = d$.user# AND
                u1$.user# = d$.role#
/
GRANT SELECT ON sys.exu8dfr TO SELECT_CATALOG_ROLE;

REM
REM all roles - enumerate all roles
REM
CREATE OR REPLACE VIEW exu8rol (
                role, password) AS
        SELECT  name, password
        FROM    sys.user$
        WHERE   type# = 0 AND
                name NOT IN ('CONNECT', 'RESOURCE', 'DBA', 'PUBLIC',
                             '_NEXT_USER', 'EXP_FULL_DATABASE',
                             'IMP_FULL_DATABASE')
/
GRANT SELECT ON sys.exu8rol TO SELECT_CATALOG_ROLE;

REM
REM all role grants
REM
CREATE OR REPLACE VIEW exu8rlg (
                grantee, granteeid, role, roleid, admin, sequence) AS
        SELECT  u1$.name, u1$.user#, u2$.name, u2$.user#, NVL(g$.option$, 0),
                g$.sequence#
        FROM    sys.user$ u1$, sys.user$ u2$, sys.sysauth$ g$
        WHERE   u1$.user# = g$.grantee# AND
                u2$.user# = g$.privilege# AND
                g$.privilege# > 0 AND
                u1$.name NOT IN ('ORDSYS',  'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                'LBACSYS', 'XDB',   'SI_INFORMTN_SCHEMA',
                                'DIP',  'DBSNMP', 'EXFSYS', 'WMSYS',
                                'ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                                'APPQOSSYS')
/
GRANT SELECT ON sys.exu8rlg TO SELECT_CATALOG_ROLE;

REM
REM all system privs, type is 1 for user, 0 for role
REM
CREATE OR REPLACE VIEW exu8spv (
                grantee, granteeid, priv, wgo, sequence) AS
        SELECT  u1$.name, u1$.user#, m$.name, NVL(a$.option$, 0), a$.sequence#
        FROM    sys.sysauth$ a$, sys.system_privilege_map m$, sys.user$ u1$
        WHERE   a$.grantee# = u1$.user# AND
                a$.privilege# = m$.privilege AND
                BITAND(m$.property, 1) != 1 AND
                u1$.name NOT IN ('CONNECT', 'RESOURCE', 'DBA', '_NEXT_USER',
                                 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                                 'ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                 'LBACSYS', 'XDB', 'SI_INFORMTN_SCHEMA',
                                 'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS',
                                 'ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                                 'APPQOSSYS')
/
GRANT SELECT ON sys.exu8spv TO SELECT_CATALOG_ROLE;

REM
REM all grants
REM
CREATE OR REPLACE VIEW exu8grn (
                objid, grantor, grantorid, grantee, priv, who, wgo, creatorid,
                sequence, isdir, type) AS
        SELECT  t$.obj#, ur$.name, t$.grantor#, ue$.name, m$.name,
                MOD(NVL(t$.option$/2, 0), 2), MOD(NVL(t$.option$, 0), 2),
                o$.owner#, t$.sequence#,
                DECODE ((o$.type#), 23, 1, 0), o$.type#  
        FROM    sys.objauth$ t$, sys.obj$ o$, sys.user$ ur$,
                sys.table_privilege_map m$, sys.user$ ue$
        WHERE   o$.obj# = t$.obj# AND
                t$.privilege# = m$.privilege AND
                t$.col# IS NULL AND
                t$.grantor# = ur$.user# AND
                t$.grantee# = ue$.user# AND
                ue$.name NOT IN ('ORDSYS',  'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                                 'LBACSYS', 'XDB',   'SI_INFORMTN_SCHEMA',
                                 'DIP',   'DBSNMP', 'EXFSYS', 'WMSYS',
                                 'ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                                 'APPQOSSYS')
/
GRANT SELECT ON sys.exu8grn TO SELECT_CATALOG_ROLE;

REM
REM just SYS's grants
REM
CREATE OR REPLACE VIEW exu8grs (
                objid, name) AS
        SELECT  t$.obj#, o$.name
        FROM    sys.objauth$ t$, sys.obj$ o$
        WHERE   o$.obj# = t$.obj# AND
                t$.col# IS NULL AND
                t$.grantor# = 0 AND
                o$.type# NOT IN (
                    SELECT  type#
                    FROM    sys.exppkgobj$)
/
GRANT SELECT ON sys.exu8grs TO SELECT_CATALOG_ROLE;

REM
REM first level grants
REM
CREATE OR REPLACE VIEW exu8grnu AS
        SELECT  *
        FROM    sys.exu8grn
        WHERE   grantorid = userenv('SCHEMAID') AND
                creatorid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8grnu TO PUBLIC;

REM
REM all column grants
REM
CREATE OR REPLACE VIEW exu8cgr (
                objid, grantor, grantorid, grantee, creatorid, cname, priv,
                sequence, wgo) AS
        SELECT  c$.obj#, ur$.name, c$.grantor#, ue$.name, o$.owner#, cl$.name,
                m$.name, c$.sequence#, MOD(NVL(c$.option$, 0), 2)
        FROM    sys.objauth$ c$, sys.obj$ o$, sys.user$ ur$, sys.user$ ue$,
                sys.table_privilege_map m$, sys.col$ cl$
        WHERE   c$.grantor# = ur$.user# AND
                c$.grantee# = ue$.user# AND
                c$.obj# = o$.obj# AND
                c$.privilege# = m$.privilege AND
                c$.obj# = cl$.obj# AND
                c$.col# = cl$.col#
/
GRANT SELECT ON sys.exu8cgr TO SELECT_CATALOG_ROLE;

REM
REM first level grants
REM
CREATE OR REPLACE VIEW exu8cgru AS
        SELECT  *
        FROM    sys.exu8cgr
        WHERE   grantorid = userenv('SCHEMAID') AND
                creatorid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8cgru TO PUBLIC;

REM
REM all indexes. This view is used for TRANSPORTABLE TABLESPACEs,
REM V11.0 and higher
REM
CREATE OR REPLACE VIEW exu11ind_base (
                iobjid, idobjid, iname, iowner, iownerid, ispace, itsno,
                ifileno, iblockno, btname, btobjid, btowner, btownerid,
                btproperty, btclusterflag, property, cluster$, pctfree$,
                initrans, maxtrans, blevel, bitmap, deflog, tsdeflog, degree,
                instances, type, rowcnt, leafcnt, distkey, lblkkey, dblkkey,
                clufac, preccnt, iflags, sysgenconst) AS
        SELECT  i$.obj#, i$.dataobj#, i$.name, ui$.name, i$.owner#, ts$.name,
                ind$.ts#, ind$.file#, ind$.block#, t$.name, t$.obj#, ut$.name,
                t$.owner#, NVL(tb$.property, 0), NVL(tb$.bobj#, 0),
                ind$.property, DECODE(t$.type#, 3, 1, 0), ind$.pctfree$,
                ind$.initrans, ind$.maxtrans, NVL(ind$.blevel, -1),
                DECODE(ind$.type#, 2, 1, 0),
                DECODE(BITAND(ind$.flags, 4), 4, 1, 0), ts$.dflogging,
                NVL(ind$.degree, 1), NVL(ind$.instances, 1), ind$.type#,
                NVL(ind$.rowcnt, -1), NVL(ind$.leafcnt, -1),
                NVL(ind$.distkey, -1), NVL(ind$.lblkkey, -1),
                NVL(ind$.dblkkey, -1), NVL(ind$.clufac, -1),
                NVL(ind$.spare2, 0), ind$.flags,
                DECODE(BITAND(i$.flags, 4), 4, 1, 0)
        FROM    sys.obj$ t$, sys.obj$ i$, sys.ind$ ind$, sys.user$ ui$,
                sys.user$ ut$, sys.ts$ ts$, sys.tab$ tb$
        WHERE   ind$.bo# = t$.obj# AND
                ind$.obj# = i$.obj# AND
                ind$.bo# = tb$.obj# (+) AND
                ts$.ts# = ind$.ts# AND
                i$.owner# = ui$.user# AND
                t$.owner# = ut$.user# AND
                BITAND(ind$.flags, 4096) = 0 AND          /* skip fake index */
                (userenv('SCHEMAID') = 0 OR (userenv('SCHEMAID') = i$.owner# AND
				 userenv('SCHEMAID') = t$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu11ind_base TO PUBLIC;

CREATE OR REPLACE VIEW exu10ind_base (
                iobjid, idobjid, iname, iowner, iownerid, ispace, itsno,
                ifileno, iblockno, btname, btobjid, btowner, btownerid,
                btproperty, btclusterflag, property, cluster$, pctfree$,
                initrans, maxtrans, blevel, bitmap, deflog, tsdeflog, degree,
                instances, type, rowcnt, leafcnt, distkey, lblkkey, dblkkey,
                clufac, preccnt, iflags, sysgenconst) AS
        SELECT iobjid, idobjid, iname, iowner, iownerid, ispace, itsno,
                ifileno, iblockno, btname, btobjid, btowner, btownerid,
                btproperty, btclusterflag, property, cluster$, pctfree$,
                initrans, maxtrans, blevel, bitmap, deflog, tsdeflog, degree,
                instances, type, rowcnt, leafcnt, distkey, lblkkey, dblkkey,
                clufac, preccnt, iflags, sysgenconst
        FROM sys.exu11ind_base e$
        WHERE  BITAND(e$.property, 8208) != 8208       /* skip Fn Ind on MV */
/
GRANT SELECT ON sys.exu10ind_base TO PUBLIC;

REM
REM all indexes. This view is the base view used by V9.0 and higher
REM
CREATE OR REPLACE VIEW exu9ind_base AS
        SELECT  * 
        FROM    sys.exu10ind_base
        WHERE   type != 8 AND                        /* skip LOB index */
                type != 4                            /* skip IOT top */
/
GRANT SELECT ON sys.exu9ind_base TO PUBLIC;

REM 
REM 
REM
CREATE OR REPLACE VIEW exu81ind_base AS
        SELECT  *
        FROM    sys.exu9ind_base
        WHERE   sysgenconst = 0
/
GRANT SELECT ON sys.exu81ind_base TO PUBLIC;


REM
REM exu11ind is defined in the same manner as exu9ind; please
REM refer to that for comments. 
REM
CREATE OR REPLACE VIEW exu11ind AS
        SELECT  *
        FROM    sys.exu11ind_base
        WHERE   NOT EXISTS (
                    SELECT  *
                    FROM    sys.con$ c$, sys.cdef$ cd$
                    WHERE   c$.name = iname AND   /* same name as constraint */
                            c$.owner# = iownerid AND
                            c$.con# = cd$.con# AND
                            NVL(cd$.enabled, 0) = iobjid AND  /* cons enable */
                            (cd$.intcols = 1 AND           /* single column */
                             EXISTS (
                                SELECT  *
                                FROM    sys.ccol$ cc$, sys.col$ co$
                                WHERE   cc$.con# = c$.con# AND
                                        co$.obj# = cc$.obj# AND
                                        co$.intcol# = cc$.intcol# AND
                                        BITAND(co$.property, 2) = 2)))
/
GRANT SELECT ON sys.exu11ind TO PUBLIC;

REM
REM exu9ind is derived from base view to eliminate indexes completely
REM defined by constraint or OIDINDEX declarations.
REM Selects any indices which do NOT correspond to constraints (same name)
REM which are enabled -and- represent an OID INDEX constraint
REM                               (single constr. col is OID).
REM  (allows non-system-defined indices due to constraints,
REM   except when the base table is IOT??).
REM Reference bugs: 686272, 735699
REM
CREATE OR REPLACE VIEW exu9ind AS
        SELECT  *
        FROM    sys.exu9ind_base
        WHERE   NOT EXISTS (
                    SELECT  *
                    FROM    sys.con$ c$, sys.cdef$ cd$
                    WHERE   c$.name = iname AND   /* same name as constraint */
                            c$.owner# = iownerid AND
                            c$.con# = cd$.con# AND
                            NVL(cd$.enabled, 0) = iobjid AND  /* cons enable */
                            (cd$.intcols = 1 AND           /* single column */
                             EXISTS (
                                SELECT  *
                                FROM    sys.ccol$ cc$, sys.col$ co$
                                WHERE   cc$.con# = c$.con# AND
                                        co$.obj# = cc$.obj# AND
                                        co$.intcol# = cc$.intcol# AND
                                        BITAND(co$.property, 2) = 2)))
/
GRANT SELECT ON sys.exu9ind TO PUBLIC;

REM
REM all indexes. This view is used by V8.1 and higher since it retrieves
REM functional and domain indexes which are unknown in V8.0
REM
CREATE OR REPLACE VIEW exu81ind AS
        SELECT  *
        FROM    sys.exu9ind
        WHERE   sysgenconst = 0 AND
                BITAND(property, 1) = 0 OR                     /* not unique */
                NOT EXISTS (
                    SELECT  *
                    FROM    sys.con$ c$, sys.cdef$ cd$
                    WHERE   c$.name = iname AND   /* same name as constraint */
                            c$.owner# = iownerid AND
                            c$.con# = cd$.con# AND
                            NVL(cd$.enabled, 0) = iobjid AND  /* cons enable */
                            ((BITAND(cd$.defer, 8) = 8)))       /* sys gen'd */
/
GRANT SELECT ON sys.exu81ind TO PUBLIC;

REM
REM all indexes for V8.0. This view filters out V8.1 and later index types not
REM supported in V8.0
REM
CREATE OR REPLACE VIEW exu8ind AS
        SELECT  *
        FROM    sys.exu81ind
        WHERE   BITAND(property, 16) != 16 AND      /* skip functional index */
                type != 9                               /* skip domain index */
/
GRANT SELECT ON sys.exu8ind TO SELECT_CATALOG_ROLE;

REM
REM current user indexes for V8.0
REM
CREATE OR REPLACE VIEW exu8indu AS
        SELECT  *
        FROM    sys.exu8ind
/
GRANT SELECT ON sys.exu8indu TO PUBLIC;

REM
REM Additional information required for domain indexes:
REM indextype name & owner, implementation type name & owner, and params
REM (params are spare4 in idx$)
REM "1" connections are for the index itself, "2" connections are for the
REM assoc. indextype, and  "3" for the assoc. implementation type.
REM iversion = domain index version (added in 9.0)
REM iproperty = the properties of domain index
REM gmflags = number (flags) passed to getindexmetadata, setup based on def.
REM           of flags argument in catodci.sql.
REM           Export may set transportable bit but otherwise does not
REM           view the composed value.
REM
CREATE OR REPLACE VIEW exu9doi (
                iobjid, iownerid, iparams, itname, itowner, implname,
                implowner, diversion, iproperty, gmflags)
      AS
        SELECT  ind$.obj#, indo$.owner#, ind$.spare4, o2$.name, u2$.name,
                o3$.name, u3$.name, it$.interface_version#, it$.property, 0
        FROM    sys.ind$ ind$, sys.obj$ indo$, sys.obj$ o2$, sys.obj$ o3$,
                sys.user$ u2$, sys.user$ u3$, sys.indtypes$ it$
        WHERE   ind$.type# = 9 AND                           /* Domain Index */
                ind$.indmethod# = it$.obj#  AND
                ind$.obj# = indo$.obj# AND
                it$.obj# = o2$.obj# AND
                it$.implobj# = o3$.obj# AND
                o2$.owner# = u2$.user# AND
                o3$.owner# = u3$.user# AND
                BITAND(ind$.property, 2) != 2                 /* partitioned */
      UNION ALL         /* Grab domain indexes that have partition info also */
        SELECT  ind$.obj#, indo$.owner#, ind$.spare4, o2$.name, u2$.name,
                o3$.name, u3$.name, it$.interface_version#, it$.property,
                DECODE(BITAND (ind$.property, 512), 512, 64,0)+/*0x200=iot di*/
                DECODE(BITAND(po$.flags, 1), 1, 1, 0) +         /* 1 = local */
                DECODE(po$.parttype, 1, 2, 2, 4, 0)   /* 1 = range, 2 = hash */
        FROM    sys.ind$ ind$, sys.obj$ indo$, sys.obj$ o2$, sys.obj$ o3$,
                sys.user$ u2$, sys.user$ u3$, sys.indtypes$ it$,
                sys.partobj$ po$
        WHERE   ind$.type# = 9 AND
                ind$.indmethod# = it$.obj# AND
                ind$.obj# = indo$.obj# AND
                it$.obj# = o2$.obj# AND
                it$.implobj# = o3$.obj# AND
                o2$.owner# = u2$.user# AND
                o3$.owner# = u3$.user# AND
                BITAND(po$.flags, 8) = 8 AND
                po$.obj# = ind$.obj# AND
                BITAND(ind$.property, 2) = 2                  /* partitioned */
/
GRANT SELECT ON sys.exu9doi TO SELECT_CATALOG_ROLE;

REM
REM Domain index info for current user
REM
CREATE OR REPLACE VIEW exu9doiu AS
        SELECT  *
        FROM    sys.exu9doi
        WHERE   iownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9doiu TO PUBLIC;

REM
REM The 81 view uses the 9.0 view and returns everything but the new
REM interface version
REM
CREATE OR REPLACE VIEW exu81doi AS
        SELECT  *
        FROM    sys.exu9doi
        WHERE   diversion = 1
/
GRANT SELECT ON sys.exu81doi TO SELECT_CATALOG_ROLE;

REM
REM Domain index info for current user
REM
CREATE OR REPLACE VIEW exu81doiu AS
        SELECT  *
        FROM    sys.exu81doi
        WHERE   iownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81doiu TO PUBLIC;

REM
REM V9.0 Get Domain Index secondary objects
REM
REM pi_obj = parent index object
REM c_obj = child secondary object
REM
CREATE OR REPLACE VIEW exu9doso (
                obj#, tablename, ownerid) AS
        SELECT  pi_obj.obj#, c_obj.name, c_obj.owner#
        FROM    sys.obj$ pi_obj, sys.obj$ c_obj, sys.user$ us2,
                sys.secobj$ secobj
        WHERE   pi_obj.obj# = secobj.obj# AND       /* has secondary objects */
                c_obj.obj# = secobj.secobj# AND /*object is secondary object */
                c_obj.owner# = us2.user#  AND /* secondary obj is same owner */
                c_obj.type# = 2 AND             /* Secondary Object is TABLE */
                BITAND(c_obj.flags, 128) != 128 AND
                (userenv('SCHEMAID') = 0 OR
				(userenv('SCHEMAID') = pi_obj.owner# AND
				 userenv('SCHEMAID') = us2.user#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9doso TO PUBLIC;

REM
REM V10.0 Get Domain Index secondary objects (including tablespace)
REM
REM pi_obj = parent index object
REM c_obj = child secondary object
REM
CREATE OR REPLACE VIEW exu10doso (
                obj#, tablename, ownerid, tablespace) AS
        SELECT  pi_obj.obj#, c_obj.name, c_obj.owner#, 
                /* decode below needed for ConText IOTs - copied from */
                /* USER_TABLES in catalog.sql */
                decode(bitand(tab.property, 2151678048), 0, ts.name, null)
        FROM    sys.obj$ pi_obj, sys.obj$ c_obj, sys.user$ us2,
                sys.secobj$ secobj, sys.tab$ tab, sys.ts$ ts
        WHERE   pi_obj.obj# = secobj.obj# AND       /* has secondary objects */
                c_obj.obj# = secobj.secobj# AND /*object is secondary object */
                c_obj.owner# = us2.user#  AND /* secondary obj is same owner */
                c_obj.type# = 2 AND             /* Secondary Object is TABLE */
                BITAND(c_obj.flags, 128) != 128 AND
                secobj.secobj# = tab.obj# AND
                tab.ts# = ts.ts# AND
                (userenv('SCHEMAID') = 0 OR
				(userenv('SCHEMAID') = pi_obj.owner# AND
				 userenv('SCHEMAID') = us2.user#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu10doso TO PUBLIC;

REM
REM Get Domain index Partition Info
REM
CREATE OR REPLACE VIEW exu9eip (
                objid, bobjid, ownerid, pname, partno, parameters) AS
        SELECT  o$.obj#, ip$.bo#, o$.owner#, o$.subname, ip$.part#,
                idpp$.parameters
        FROM    sys.obj$ o$, sys.indpart$ ip$, sys.indpart_param$ idpp$
        WHERE   o$.type# = 20 AND                       /* Partitioned Index */
                ip$.obj# = o$.obj# AND
                idpp$.obj# = o$.obj# AND
                (userenv('SCHEMAID') IN (0, o$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9eip TO PUBLIC;

REM
REM Obtain all context binding info
REM
CREATE OR REPLACE VIEW exu81ctx (
                ctxname, shmname, pkgname, objno) AS
        SELECT  o$.name, c$.schema, c$.package, o$.obj#
        FROM    sys.exu81obj o$, sys.context$ c$
        WHERE   o$.type# = 44 AND                                 /* context */
                o$.obj# = c$.obj#
/
GRANT SELECT ON sys.exu81ctx TO SELECT_CATALOG_ROLE;

REM
REM Obtain all application role binding info
REM
CREATE OR REPLACE VIEW exu81approle (
                role, schema, package) AS
        SELECT  u$.name, r$.schema, r$.package
        FROM    sys.user$ u$, sys.approle$ r$
        WHERE   u$.user# = r$.role#
/
GRANT SELECT ON sys.exu81approle TO SELECT_CATALOG_ROLE;

REM
REM TEST FOR TRUSTED ORACLE
REM
CREATE OR REPLACE VIEW exu816tctx (
                cols) AS
        SELECT  cols
        FROM    sys.tab$ t, sys.obj$ o
        WHERE   t.obj# = o.obj# AND
                o.name = 'CONTEXT$' AND
                o.type# = 2 AND
                o.owner# = 0
/
GRANT SELECT ON sys.exu816tctx TO SELECT_CATALOG_ROLE;

REM
REM CREATE EXPORT VIEW
REM
CREATE OR REPLACE VIEW exu816ctx (
                ctxname, shmname, pkgname, flags) AS
        SELECT  o$.name, c$.schema, c$.package, c$.flags
        FROM    sys.exu81obj o$, sys.context$ c$
        WHERE   o$.type# = 44 AND
                o$.obj# = c$.obj#
/
GRANT SELECT ON sys.exu816ctx TO SELECT_CATALOG_ROLE;

REM
REM dependency order -- only used for ordering operators
REM
CREATE OR REPLACE VIEW exu8ordop (
                dlevel, obj#, d_owner#) AS
        SELECT                                              /*+ no_filtering */
                MAX(level), d1.d_obj#, d1.owner#
        FROM    (
                    SELECT                                      /*+ no_merge */
                            d.d_obj#, d.p_obj#, v.owner#
                    FROM    sys.dependency$ d,
                    (select obj#, owner# from sys.obj$ where type#=33) v
                    WHERE   v.obj# = d.d_obj#) d1
        CONNECT BY PRIOR d1.d_obj# = d1.p_obj#
        GROUP BY d1.d_obj#, d1.owner#
/
GRANT SELECT ON sys.exu8ordop TO PUBLIC;

REM
REM dependency order -- only used for ordering views
REM
CREATE OR REPLACE VIEW exu8ord (
                dlevel, obj#, d_owner#) AS
        SELECT                                              /*+ no_filtering */
                MAX(level), d1.d_obj#, d1.owner#
        FROM    (
                    SELECT                                      /*+ no_merge */
                            d.d_obj#, d.p_obj#, v.owner#
                    FROM    sys.dependency$ d,
                    (select obj#, owner# from sys.obj$ where type#=4) v
                    WHERE   v.obj# = d.d_obj#) d1
        CONNECT BY NOCYCLE PRIOR d1.d_obj# = d1.p_obj#
        GROUP BY d1.d_obj#, d1.owner#
/
GRANT SELECT ON sys.exu8ord TO PUBLIC;

REM
REM current user's dependency order of views
REM
CREATE OR REPLACE VIEW exu8ordu AS
        SELECT  *
        FROM    sys.exu8ord
        WHERE   d_owner# = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8ordu TO PUBLIC;

REM
REM all views
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8vew (
                vobjid, vname, vtext, vowner, vownerid, vaudit, vcomment,
                vcname, vlevel, property, defer, flags, oidlen, oidclause,
                typeowner, typename, vlen, sqlver, underlen, underclause) AS
        SELECT  o$.obj#, o$.name, v$.text, u$.name, o$.owner#, v$.audit$,
                com$.comment$, c$.name, d$.dlevel, v$.property,
                NVL(cd$.defer, 0), NVL(o$.flags, 0), NVL(vt$.oidtextlength, 0),
                vt$.oidtext, vt$.typeowner, vt$.typename, v$.textlength,
                sv$.sql_version, NVL(vt$.undertextlength, 0), vt$.undertext
        FROM    sys.exu81obj o$, sys.view$ v$, sys.user$ u$, sys.cdef$ cd$,
                sys.con$ c$, sys.com$ com$, sys.exu8ord d$,
                sys.typed_view$ vt$, sys.exu816sqv sv$
        WHERE   v$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                o$.obj# = cd$.obj#(+) AND
                cd$.con# = c$.con#(+) AND
                o$.obj# = com$.obj#(+) AND
                com$.col#(+) IS NULL AND
                o$.obj# = d$.obj#(+) AND
                v$.obj# = vt$.obj# (+) AND
                o$.spare1 = sv$.version# (+)
/
GRANT SELECT ON sys.exu8vew TO SELECT_CATALOG_ROLE;

REM
REM views for incremental export: new or last export not valid
REM cannot use union as in exutabi because of long field
REM
CREATE OR REPLACE VIEW exu8vewi AS
        SELECT  vw.*
        FROM    sys.exu8vew vw, sys.incexp i, sys.incvid v
        WHERE   i.name(+) = vw.vname AND
                i.owner#(+) = vw.vownerid AND
                v.expid < NVL(i.expid, 9999) AND
                NVL(i.type#, 4) = 4
/
GRANT SELECT ON sys.exu8vewi TO SELECT_CATALOG_ROLE;

REM
REM views for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu8vewc AS
        SELECT  vw.*
        FROM    sys.exu8vew vw, sys.incexp i, sys.incvid v
        WHERE   vw.vname = i.name(+) AND
                vw.vownerid = i.owner#(+) AND
                NVL(i.type#, 4) = 4 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu8vewc TO SELECT_CATALOG_ROLE;

REM
REM current user's view
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8vewu (
                vobjid, vname, vtext, vowner, vownerid, vaudit, vcomment,
                vcname, vlevel, property, defer, flags, oidlen, oidclause,
                typeowner, typename, vlen, sqlver, underlen, underclause) AS
        SELECT  o$.obj#, o$.name, v$.text, u$.name, o$.owner#, v$.audit$,
                com$.comment$, c$.name, d$.dlevel, v$.property,
                NVL(cd$.defer, 0), NVL(o$.flags, 0), NVL(vt$.oidtextlength, 0),
                vt$.oidtext, vt$.typeowner, vt$.typename, v$.textlength,
                sv$.sql_version, NVL(vt$.undertextlength, 0), vt$.undertext
        FROM    sys.exu81obj o$, sys.view$ v$, sys.user$ u$, sys.cdef$ cd$,
                sys.con$ c$, sys.com$ com$, sys.exu8ordu d$,
                sys.typed_view$ vt$, sys.exu816sqv sv$
        WHERE   v$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                o$.obj# = cd$.obj#(+) AND
                cd$.con# = c$.con#(+) AND
                o$.obj# = com$.obj#(+) AND
                com$.col#(+) IS NULL AND
                o$.obj# = d$.obj#(+) AND
                v$.obj# = vt$.obj#(+) AND
                u$.user# = userenv('SCHEMAID') AND
                o$.spare1 = sv$.version# (+)
/
GRANT SELECT ON sys.exu8vewu TO PUBLIC;

REM
REM get dependency info for views that depend on other views
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vdpt (
                parent, child, powner, cowner) AS
        SELECT  d$.p_obj#, d$.d_obj#, o1$.owner#, o2$.owner#
        FROM    sys.dependency$ d$, sys.obj$ o1$, sys.obj$ o2$, sys.view$ v1$,
                sys.view$ v2$
        WHERE   d$.p_obj# = v1$.obj# AND
                v1$.obj# = o1$.obj# AND
                d$.d_obj# = v2$.obj# AND
                v2$.obj# = o2$.obj#
/
GRANT SELECT ON sys.exu8vdpt TO SELECT_CATALOG_ROLE;

REM
REM get dependency info for views that depend on other views
REM for current user
REM note, that even if user does not have privs, we need to
REM include views of other other users, to get the proper ordering.
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vdptu AS
        SELECT  *
        FROM    sys.exu8vdpt
/
GRANT SELECT ON sys.exu8vdptu TO PUBLIC;

REM
REM get all information about a given view
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vinf (
                vobjid, vname, vtext, vowner, vownerid, vaudit, vcomment,
                vcname, property, defer, flags, oidlen, oidclause, typeowner,
                typename, vlen) AS
        SELECT  o$.obj#, o$.name, v$.text, u$.name, o$.owner#, v$.audit$,
                com$.comment$, c$.name, v$.property, NVL(cd$.defer, 0),
                NVL(o$.flags, 0), NVL(vt$.oidtextlength, 0), vt$.oidtext,
                vt$.typeowner, vt$.typename, v$.textlength
        FROM    sys.obj$ o$, sys.view$ v$, sys.user$ u$, sys.cdef$ cd$,
                sys.con$ c$, sys.com$ com$, sys.typed_view$ vt$
        WHERE   v$.obj# = o$.obj# AND
                o$.owner# = u$.user# AND
                o$.obj# = cd$.obj#(+) AND
                cd$.con# = c$.con#(+) AND
                o$.obj# = com$.obj#(+) AND
                com$.col#(+) IS NULL AND
                v$.obj# = vt$.obj# (+)
/
GRANT SELECT ON sys.exu8vinf TO SELECT_CATALOG_ROLE;

REM
REM views for incremental export: new or last export not valid
REM cannot use union as in exutabi because of long field
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vinfi AS
        SELECT  vw.*
        FROM    sys.exu8vinf vw, sys.incexp i, sys.incvid v
        WHERE   i.name(+) = vw.vname AND
                i.owner#(+) = vw.vownerid AND
                v.expid < NVL(i.expid, 9999) AND
                NVL(i.type#, 4) = 4
/
GRANT SELECT ON sys.exu8vinfi TO SELECT_CATALOG_ROLE;

REM
REM views for cumulative export: new, last export was inc or not valid
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vinfc AS
        SELECT  vw.*
        FROM    sys.exu8vinf vw, sys.incexp i, sys.incvid v
        WHERE   vw.vname = i.name(+) AND
                vw.vownerid = i.owner#(+) AND
                NVL(i.type#, 4) = 4 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu8vinfc TO SELECT_CATALOG_ROLE;

REM
REM current user's view
REM
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vinfu AS
        SELECT  *
        FROM    sys.exu8vinf
        WHERE   vownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8vinfu TO PUBLIC;

REM
REM get all information about views with no dependent views
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vnc AS
        SELECT  *
        FROM    sys.exu8vinf vf$
        WHERE   NOT EXISTS (
                    SELECT  0
                    FROM    sys.exu8vdpt vd$
                    WHERE   vd$.parent = vf$.vobjid)
/
GRANT SELECT ON sys.exu8vnc TO SELECT_CATALOG_ROLE;

REM
REM views without dependent views for incremental export:
REM new or last export not valid
REM cannot use union as in exutabi because of long field
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vnci AS
        SELECT  vw.*
        FROM    sys.exu8vnc vw, sys.incexp i, sys.incvid v
        WHERE   i.name(+) = vw.vname AND
                i.owner#(+) = vw.vownerid AND
                v.expid < NVL(i.expid, 9999) AND
                NVL(i.type#, 4) = 4
/
GRANT SELECT ON sys.exu8vnci TO SELECT_CATALOG_ROLE;

REM
REM views without dependent views for cumulative export:
REM new, last export was inc or not valid
REM
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vncc AS
        SELECT  vw.*
        FROM    sys.exu8vnc vw, sys.incexp i, sys.incvid v
        WHERE   vw.vname = i.name(+) AND
                vw.vownerid = i.owner#(+) AND
                NVL(i.type#, 4) = 4 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu8vncc TO SELECT_CATALOG_ROLE;

REM
REM current user's views without dependent views
REM *** obsolete in 8.1.6 ***
REM
CREATE OR REPLACE VIEW exu8vncu AS
        SELECT  *
        FROM    sys.exu8vinfu vf$
        WHERE   NOT EXISTS (
                    SELECT  0
                    FROM    sys.exu8vdptu vd$
                    WHERE   vd$.parent = vf$.vobjid)
/
GRANT SELECT ON sys.exu8vncu TO PUBLIC;

REM
REM all synonyms (except those for TYPEs)
REM
REM Note: there can be synonyms for non existant objects

CREATE OR REPLACE VIEW exu9syn (
                synnam, synnam2, syntab, tabown, tabnode, public$, synown,
                synownid, tabownid, synobjno, syntime) AS
        SELECT  o$.name, o$.name, s$.name, s$.owner, s$.node,
                DECODE(o$.owner#, 1, 1, 0), uo$.name, o$.owner#, us$.user#,
                s$.obj#, o$.ctime
        FROM    sys.exu81obj o$, sys.syn$ s$, sys.user$ us$, sys.user$ uo$
        WHERE   s$.obj# = o$.obj# AND
                o$.owner# = uo$.user# AND
                s$.owner = us$.name(+) AND
                NVL(s$.owner, 'SYS') NOT IN
                   ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS', 'LBACSYS',
                    'XDB', 'SI_INFORMTN_SCHEMA', 'DIP',  'DBSNMP', 'EXFSYS',
                    'WMSYS','ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                    'APPQOSSYS') AND
                NOT EXISTS (
                    SELECT obj#
                    FROM sys.obj$ ne
                    WHERE ne.name = s$.name AND
                          ne.owner# = us$.user# AND
                          ne.type# = 13 )
/
GRANT SELECT ON sys.exu9syn TO SELECT_CATALOG_ROLE;

REM
REM all PUBLIC TYPE Synonyms 
REM
CREATE OR REPLACE VIEW exu9pts (
                synnam, synnam2, syntab, tabown, tabnode, public$, synown,
                synownid, tabownid, synobjno, syntime) AS
        SELECT  o$.name, o$.name, s$.name, s$.owner, s$.node,
                DECODE(o$.owner#, 1, 1, 0), uo$.name, o$.owner#, us$.user#, 
                s$.obj#, o$.ctime
        FROM    sys.exu81obj o$, sys.syn$ s$, sys.user$ us$, sys.user$ uo$
        WHERE   s$.obj# = o$.obj# AND
                o$.owner# = uo$.user# AND
                s$.owner = us$.name(+) AND
                NVL(s$.owner, 'SYS') NOT IN
                   ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS', 'LBACSYS',
                    'XDB', 'SI_INFORMTN_SCHEMA', 'DIP',  'DBSNMP', 'EXFSYS', 
                    'WMSYS','ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                    'APPQOSSYS') AND
                o$.owner# = 1 AND
                EXISTS (
                    SELECT obj#
                    FROM sys.obj$ e
                    WHERE e.name = s$.name AND
                          e.owner# = us$.user# AND
                          e.type# = 13 )
/
GRANT SELECT ON sys.exu9pts TO PUBLIC;

REM
REM User's TYPE Synonyms (non PUBLIC)
REM
CREATE OR REPLACE VIEW exu9uts (
                synnam, synnam2, syntab, tabown, tabnode, public$, synown,
                synownid, tabownid, synobjno, syntime) AS
        SELECT  o$.name, o$.name, s$.name, s$.owner, s$.node,
                DECODE(o$.owner#, 1, 1, 0), uo$.name, o$.owner#, us$.user#, 
                s$.obj#, o$.ctime
        FROM    sys.exu81obj o$, sys.syn$ s$, sys.user$ us$, sys.user$ uo$
        WHERE   s$.obj# = o$.obj# AND
                o$.owner# = uo$.user# AND
                s$.owner = us$.name(+) AND
                NVL(s$.owner, 'SYS') NOT IN
                   ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS', 'LBACSYS',
                    'XDB', 'SI_INFORMTN_SCHEMA', 'DIP',  'DBSNMP', 'EXFSYS', 
                    'WMSYS','ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                    'APPQOSSYS') AND
                o$.owner# <> 1 AND
                EXISTS (
                    SELECT obj#
                    FROM sys.obj$ e
                    WHERE e.name = s$.name AND
                          e.owner# = us$.user# AND
                          e.type# = 13 )
/
GRANT SELECT ON sys.exu9uts TO SELECT_CATALOG_ROLE;

REM
REM all synonyms (pre 9.2 only)
REM
CREATE OR REPLACE VIEW exu8syn (
                synnam, synnam2, syntab, tabown, tabnode, public$, synown,
                synownid, syntime) AS
        SELECT  o$.name, o$.name, s$.name, s$.owner, s$.node,
                DECODE(o$.owner#, 1, 1, 0), uo$.name, o$.owner#, o$.ctime
        FROM    sys.exu81obj o$, sys.syn$ s$, sys.user$ us$, sys.user$ uo$
        WHERE   s$.obj# = o$.obj# AND
                o$.owner# = uo$.user# AND
                s$.owner = us$.name(+) AND
                NVL(s$.owner, 'SYS') NOT IN
                   ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS', 'LBACSYS',
                    'XDB', 'SI_INFORMTN_SCHEMA', 'DIP', 'DBSNMP', 'EXFSYS', 
                    'WMSYS','ORACLE_OCM', 'ANONYMOUS', 'XS$NULL',
                    'APPQOSSYS')
/
GRANT SELECT ON sys.exu8syn TO SELECT_CATALOG_ROLE;

REM
REM synonyms for incremental export: new or last export not valid
REM
REM obsolete in 9.2
CREATE OR REPLACE VIEW exu8syni AS
        SELECT  s.*
        FROM    sys.exu8syn s, sys.incexp i, sys.incvid v
        WHERE   s.synnam = i.name(+) AND
                s.synownid = i.owner#(+) AND
                NVL(i.type#, 5) = 5 AND
                NVL(i.expid, 9999) > v.expid
/
GRANT SELECT ON sys.exu8syni TO SELECT_CATALOG_ROLE;

REM
REM synonyms for cumulative export: new, last export was inc or not valid
REM
REM obsolete in 9.2
CREATE OR REPLACE VIEW exu8sync AS
        SELECT  s.*
        FROM    sys.exu8syn s, sys.incexp i, sys.incvid v
        WHERE   s.synnam = i.name(+) AND
                s.synownid = i.owner#(+) AND
                NVL(i.type#, 5) = 5 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8sync TO SELECT_CATALOG_ROLE;

REM
REM user's synnonyms (pre 9.2 only)
REM
CREATE OR REPLACE VIEW exu8synu AS
        SELECT  *
        FROM    sys.exu8syn
        WHERE   synownid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8synu TO PUBLIC;

REM
REM user's synonyms (except those for TYPEs)
REM
CREATE OR REPLACE VIEW exu9synu AS
        SELECT  *
        FROM    sys.exu9syn
        WHERE   synownid = userenv('SCHEMAID') 
/
GRANT SELECT ON sys.exu9synu TO PUBLIC;

REM
REM user's synonyms for import (except those for TYPEs)
REM
CREATE OR REPLACE VIEW imp9synu AS
        SELECT  *
        FROM    sys.exu9syn
        WHERE   synownid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.imp9synu TO PUBLIC;

REM
REM user's synonyms (for TYPEs)
REM
CREATE OR REPLACE VIEW exu9utsu AS
        SELECT  *
        FROM    sys.exu9uts
        WHERE   synownid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9utsu TO PUBLIC;

REM
REM clustered tables' columns
REM
CREATE OR REPLACE VIEW exu8cco (
                tname, towner, townerid, cluster$, tcolnam, seq, property) AS
        SELECT  t$.name, u$.name, t$.owner#, c$.name,
                DECODE(BITAND(tc$.property, 1), 1, a$.name, tc$.name),
                cc$.col#, tc$.property
        FROM    sys.obj$ t$, sys.tab$ tab$, sys.obj$ c$, sys.col$ tc$,
                sys.col$ cc$, sys.user$ u$, sys.attrcol$ a$
        WHERE   t$.type# = 2 AND
                t$.obj# = tab$.obj# AND
                tab$.bobj# = cc$.obj# AND
                tab$.obj# = tc$.obj# AND
                tab$.bobj# = c$.obj# AND
                cc$.segcol# = tc$.segcol# AND
                t$.owner# = u$.user# AND
                tc$.obj# = a$.obj# (+) AND
                tc$.intcol# = a$.intcol# (+)
/
GRANT SELECT ON sys.exu8cco TO SELECT_CATALOG_ROLE;

REM
REM current user's clustered tables' columns
REM
CREATE OR REPLACE VIEW exu8ccou AS
        SELECT  *
        FROM    sys.exu8cco
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8ccou TO PUBLIC;

REM
REM all clusters
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8clu (
                objid, dobjid, owner, ownerid, name, tblspace, size$, tsno,
                fileno, blockno, mtime, pctfree$, pctused$, initrans, maxtrans,
                hashkeys, function, avgchn, degree, instances, cache, functxt,
                funclen, single_table, sqlver, tflags) AS
        SELECT  o$.obj#, o$.dataobj#, u$.name, o$.owner#, o$.name, ts$.name,
                NVL(c$.size$, -1), ts$.ts#, c$.file#, c$.block#, o$.mtime,
                MOD(c$.pctfree$, 100), c$.pctused$, c$.initrans, c$.maxtrans,
                NVL(c$.hashkeys, 0), NVL(c$.func, 1), NVL(c$.avgchn, -1),
                NVL(c$.degree, 1), NVL(c$.instances, 1),
                DECODE(BITAND(c$.flags, 8), 8, 1, 0), cd$.condition,
                cd$.condlength, DECODE(BITAND(c$.flags, 65536), 65536, 1, 0),
                sv$.sql_version, c$.flags
        FROM    sys.obj$ o$, sys.clu$ c$, sys.ts$ ts$, sys.user$ u$,
                sys.cdef$ cd$, sys.exu816sqv sv$
        WHERE   o$.obj# = c$.obj# AND
                c$.ts# = ts$.ts# AND
                o$.owner# = u$.user# AND
                cd$.obj#(+) = c$.obj# AND
                o$.spare1 = sv$.version# (+)
/
GRANT SELECT ON sys.exu8clu TO SELECT_CATALOG_ROLE;

REM
REM clusters for incremental export: new or last export invalid
REM altered cluster is now exported because its tables are also exported
REM
CREATE OR REPLACE VIEW exu8clui AS
        SELECT  c.*
        FROM    sys.exu8clu c, sys.incexp i, sys.incvid v
        WHERE   c.name = i.name(+) AND
                c.ownerid = i.owner#(+) AND
                (c.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8clui TO SELECT_CATALOG_ROLE;

REM
REM clusters for cumulative export: last export was inc or new
REM altered cluster is now exported because its tables are also exported
REM
CREATE OR REPLACE VIEW exu8cluc AS
        SELECT  c.*
        FROM    sys.exu8clu c, sys.incexp i, sys.incvid v
        WHERE   c.name = i.name(+) AND
                c.ownerid = i.owner#(+) AND
                NVL(i.type#, 3) = 3 AND
                (i.itime > NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) OR
                 c.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8cluc TO SELECT_CATALOG_ROLE;

REM
REM current user's clusters
REM
CREATE OR REPLACE VIEW exu8cluu AS
        SELECT  *
        FROM    sys.exu8clu
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8cluu TO PUBLIC;

REM
REM all storage parameters
REM
CREATE OR REPLACE VIEW exu9sto (
                ownerid, tsno, fileno, blockno, iniext, sext, minext, maxext,
                pctinc, blocks, lists, groups, extents, pcache, ts_type,
                tsname, isonline, blocksize, hscompress, maxsize) AS
        SELECT  s$.user#, s$.ts#, s$.file#, s$.block#, s$.iniexts, s$.extsize,
                s$.minexts, s$.maxexts, s$.extpct, s$.blocks,
                DECODE(BITAND(s$.spare1, 2097152), 2097152, NVL(s$.lists, 0),
                       DECODE(s$.lists, NULL, 1, 65535, 1, lists)),
                DECODE(BITAND(s$.spare1, 2097152), 2097152, NVL(s$.groups, 0),
                       DECODE(s$.groups, NULL, 1, 65535, 1, groups)), 
                extents,
                DECODE(bitand(s$.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE','DEFAULT'),
                DECODE(BITAND(s$.spare1, 1), 1,
                       DECODE(BITAND(ts$.flags, 3), 0, 0, 1, 1, 2, 2, -1),
                       0, -1, -1),
                ts$.name, DECODE(ts$.online$, 1, 1, 4, 1, 0),
                NVL(ts$.blocksize, 2048), s$.spare1,
                DECODE(BITAND(s$.spare1,4194304), 4194304, s$.bitmapranges, 0)
        FROM    sys.seg$ s$, sys.ts$ ts$
        WHERE   s$.ts# = ts$.ts#(+)
/
GRANT SELECT ON sys.exu9sto TO SELECT_CATALOG_ROLE;

REM
REM storage parameters for current user's segments
REM
CREATE OR REPLACE VIEW exu9stou AS
        SELECT  *
        FROM    sys.exu9sto
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9stou TO PUBLIC;

REM
REM pre V9.0 storage parameter info adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8sto (
                ownerid, tsno, fileno, blockno, iniext, sext, minext, maxext,
                pctinc, blocks, lists, groups, extents, pcache, ts_type,
                tsname, isonline) AS
        SELECT  s.ownerid, s.tsno, s.fileno, s.blockno,
                CEIL(s.iniext * (s.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                CEIL(s.sext * (s.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                s.minext, s.maxext, s.pctinc,
                CEIL(s.blocks * (s.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                s.lists, s.groups, s.extents, s.pcache, s.ts_type, s.tsname,
                s.isonline
        FROM    sys.exu9sto s
/
GRANT SELECT ON sys.exu8sto TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 curr user's storage param info adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8stou AS
        SELECT  *
        FROM    sys.exu8sto
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8stou TO PUBLIC;

REM
REM find out correct size of second extent using uet$
REM
CREATE OR REPLACE VIEW exu9tne (
                tsno, fileno, blockno, length) AS
        SELECT  ts#, segfile#, segblock#, length
        FROM    sys.uet$
        WHERE   ext# = 1
/
GRANT SELECT ON sys.exu9tne TO PUBLIC;

REM
REM pre V9.0 2nd extent info adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8tne (
                tsno, fileno, blockno, length) AS
        SELECT  e.tsno, e.fileno, e.blockno,
                CEIL(e.length * ((
                    SELECT  t1$.blocksize
                    FROM    sys.ts$ t1$
                    WHERE   t1$.ts# = e.tsno) / (
                    SELECT  t0$.blocksize
                    FROM    sys.ts$ t0$
                    WHERE   t0$.ts# = 0)))
        FROM    sys.exu9tne e
/
GRANT SELECT ON sys.exu8tne TO PUBLIC;

REM
REM find out correct size of second extent using x$ktfbue (for bitmapped TS)
REM
CREATE OR REPLACE VIEW exu9tneb (
                tsno, fileno, blockno, length) AS
        SELECT  ktfbuesegtsn, ktfbuesegfno, ktfbuesegbno, ktfbueblks
        FROM    sys.x$ktfbue
        WHERE   ktfbueextno = 1
/
GRANT SELECT ON sys.exu9tneb TO PUBLIC;

REM
REM pre V9.0 2nd extent info adjusted for bitmapped TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8tneb (
                tsno, fileno, blockno, length) AS
        SELECT  e.tsno, e.fileno, e.blockno,
                CEIL(e.length * ((
                    SELECT  t1$.blocksize
                    FROM    sys.ts$ t1$
                    WHERE   t1$.ts# = e.tsno) / (
                    SELECT  t0$.blocksize
                    FROM    sys.ts$ t0$
                    WHERE   t0$.ts# = 0)))
        FROM    sys.exu9tneb e
/
GRANT SELECT ON sys.exu8tneb TO PUBLIC;

REM
REM all tablespaces
REM
CREATE OR REPLACE VIEW exu9tbs (
                id, owner, name, isonline, content, iniext, sext, pctinc,
                minext, maxext, minlen, deflog, ext_mgt, alloc_type, blocksize,
                maxsize)
      AS
        SELECT  ts$.ts#, 'SYSTEM', ts$.name,
                DECODE(ts$.online$, 1, 'ONLINE', 4, 'ONLINE', 'OFFLINE'),
                DECODE(ts$.contents$, 0, 'PERMANENT', 1, 'TEMPORARY'),
                ts$.dflinit, ts$.dflincr, ts$.dflextpct, ts$.dflminext,
                ts$.dflmaxext, NVL(ts$.dflminlen, 0), ts$.dflogging,
                ts$.bitmapped, ts$.flags, ts$.blocksize,
                decode(bitand(ts$.flags, 4096), 4096, ts$.affstrength, 0)
        FROM    sys.ts$ ts$
        WHERE   ts$.online$ IN (1, 2, 4) AND
                ts$.ts# != 0 AND
                bitand(ts$.flags,2048) !=2048
/
GRANT SELECT ON sys.exu9tbs TO SELECT_CATALOG_ROLE;

REM
REM pre V9.0 tablespaces adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81tbs (
                id, owner, name, isonline, content, iniext, sext, pctinc,
                minext, maxext, minlen, deflog, ext_mgt, alloc_type) AS
        SELECT  t.id, t.owner, t.name, t.isonline, t.content,
                CEIL(t.iniext * (t.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                CEIL(t.sext * (t.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                t.pctinc, t.minext, t.maxext,
                CEIL(t.minlen * (t.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                t.deflog,
                CEIL(t.ext_mgt * (t.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                t.alloc_type
        FROM    sys.exu9tbs t
/
GRANT SELECT ON sys.exu81tbs TO SELECT_CATALOG_ROLE;

REM
REM all tablespaces for 8.0
REM
CREATE OR REPLACE VIEW exu8tbs (
                id, owner, name, isonline, content, iniext, sext, pctinc,
                minext, maxext, deflog) AS
        SELECT  tbs$.id, tbs$.owner, tbs$.name, tbs$.isonline, tbs$.content,
                tbs$.iniext, tbs$.sext, tbs$.pctinc, tbs$.minext, tbs$.maxext,
                tbs$.deflog
        FROM    sys.exu81tbs tbs$
        WHERE   tbs$.ext_mgt = 0
/
GRANT SELECT ON sys.exu8tbs TO SELECT_CATALOG_ROLE;

REM
REM tablespace quotas
REM
CREATE OR REPLACE VIEW exu9tsq(
                tsname, tsid, uname, userid, maxblocks, blocksize) AS
        SELECT  t$.name, q$.ts#, u$.name, u$.user#, q$.maxblocks, t$.blocksize
        FROM    sys.ts$ t$, sys.tsq$ q$, sys.user$ u$
        WHERE   q$.user# = u$.user# AND
                q$.ts# = t$.ts# AND
                q$.maxblocks != 0 AND
                t$.online$ IN (1, 2, 4)
/
GRANT SELECT ON sys.exu9tsq TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 tablespace quotas adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu8tsq(
                tsname, tsid, uname, userid, maxblocks) AS
        SELECT  q.tsname, q.tsid, q.uname, q.userid,
                CEIL(q.maxblocks * (q.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0)))
        FROM    sys.exu9tsq q
/
GRANT SELECT ON sys.exu8tsq TO SELECT_CATALOG_ROLE;

REM
REM tablespace names
REM
CREATE OR REPLACE VIEW exu8tsn (
                tsname, tsid, tsflags) AS
        SELECT  t$.name, t$.ts#, t$.flags
        FROM    sys.ts$ t$
/
GRANT SELECT ON sys.exu8tsn TO SELECT_CATALOG_ROLE;

REM
REM 1. files from user mapped tablespaces
REM 2. bitmapped tablespaces (derived from dba_data_files)
REM 3. bitmapped temporary tablespaces (derived from dba_temp_files)
REM
CREATE OR REPLACE VIEW exu9fil(
                fname, fsize, maxextend, inc, tsid, bitmap) AS
        SELECT  v$.name, f$.blocks, f$.maxextend, f$.inc, f$.ts#, 0
        FROM    sys.file$ f$, sys.v$dbfile v$
        WHERE   f$.file# = v$.file# AND
                f$.spare1 IS NULL
      UNION ALL
        SELECT  /* ignore hint, perf problem - ordered use_nl(f$) use_nl(hc) */
                v$.name, DECODE(hc.ktfbhccval, 0, hc.ktfbhcsz, -1),
                DECODE(hc.ktfbhccval, 0, hc.ktfbhcmaxsz, NULL),
                DECODE(hc.ktfbhccval, 0, hc.ktfbhcinc, NULL), f$.ts#,
                ts$.bitmapped
        FROM    sys.v$dbfile v$, sys.file$ f$, sys.x$ktfbhc hc, sys.ts$ ts$
        WHERE   v$.file# = f$.file# AND
                f$.spare1 IS NOT NULL AND
                f$.file# = hc.ktfbhcafno AND
                hc.ktfbhctsn(+) = ts$.ts#
      UNION ALL
        SELECT                                       /*+ ordered use_nl(hc) +*/
                v$.fnnam, DECODE(hc.ktfthccval, 0, hc.ktfthcsz, -1),
                DECODE(hc.ktfthccval, 0, hc.ktfthcmaxsz, NULL),
                DECODE(hc.ktfthccval, 0, hc.ktfthcinc, NULL), ts$.ts#,
                ts$.bitmapped
        FROM    sys.x$kccfn v$, sys.x$ktfthc hc, sys.ts$ ts$
        WHERE   v$.fntyp = 7 AND
                v$.fnnam IS NOT NULL AND
                v$.fnfno = hc.ktfthctfno AND
                hc.ktfthctsn(+) = ts$.ts#
/
GRANT SELECT ON sys.exu9fil TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 file info adjusted for tablespace specific blocksizes
REM
CREATE OR REPLACE VIEW exu81fil(
                fname, fsize, maxextend, inc, tsid, bitmap) AS
        SELECT  f.fname,
                NVL2(f.fsize, DECODE(f.fsize, -1, -1,
                    CEIL(f.fsize * ((
                    SELECT  t1$.blocksize
                    FROM    sys.ts$ t1$
                    WHERE   t1$.ts# = f.tsid) / (
                    SELECT  t0$.blocksize
                    FROM    sys.ts$ t0$
                    WHERE   t0$.ts# = 0)))), NULL),
                NVL2(f.maxextend, CEIL(f.maxextend * ((
                    SELECT  t1$.blocksize
                    FROM    sys.ts$ t1$
                    WHERE   t1$.ts# = f.tsid) / (
                    SELECT  t0$.blocksize
                    FROM    sys.ts$ t0$
                    WHERE   t0$.ts# = 0))), NULL),
                NVL2(f.inc, CEIL(f.inc * ((
                    SELECT  t1$.blocksize
                    FROM    sys.ts$ t1$
                    WHERE   t1$.ts# = f.tsid) / (
                    SELECT  t0$.blocksize
                    FROM    sys.ts$ t0$
                    WHERE t0$.ts# = 0))), NULL),
                f.tsid, f.bitmap
        FROM    sys.exu9fil f
/
GRANT SELECT ON sys.exu81fil TO SELECT_CATALOG_ROLE;

REM
REM all files for 8.0
REM
CREATE OR REPLACE VIEW exu8fil (
                fname, fsize, maxextend, inc, tsid) AS
        SELECT  fname, fsize, maxextend, inc, tsid
        FROM    sys.exu81fil
        WHERE   bitmap = 0
/
GRANT SELECT ON sys.exu8fil TO SELECT_CATALOG_ROLE;

REM
REM all 10.* database links (new columns passwordx and authpwdx in link$)
REM

-- If a user
--   (a) owns the object or
--   (b) is SYS or
--   (c) has EXP_FULL_DATABASE role
-- the user can see all metadata for the object including passwords.
CREATE OR REPLACE VIEW exu10lnk (
                owner, ownerid, name, user$, passwd, host, public$,
                auth_user, auth_passwd, flag, passwdx, auth_passwdx) AS
        SELECT  DECODE(l$.owner#, 1, 'SYSTEM', u$.name), l$.owner#, l$.name,
                l$.userid, l$.password, l$.host, DECODE(l$.owner#, 1, 1, 0),
                l$.authusr, l$.authpwd, l$.flag, l$.passwordx, l$.authpwdx 
        FROM    sys.user$ u$, sys.link$ l$
        WHERE   u$.user# = l$.owner# AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u$.user#, 0) OR 
                 EXISTS ( SELECT role 
                          FROM   session_roles 
                          WHERE  role='EXP_FULL_DATABASE' ))
/
GRANT SELECT ON sys.exu10lnk TO EXP_FULL_DATABASE;

REM
REM 10.* current user's database links'
REM
CREATE OR REPLACE VIEW exu10lnku AS
        SELECT  *
        FROM    sys.exu10lnk
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10lnku TO PUBLIC;

REM 
REM For 9.* the database links dont retrieve anything (1=2)
REM
REM  When they do 10.*(Exp) to 9.*(Imp), dblinks are created on 9.*
REM  They need to recreate them on the 9.* database after import
Rem

CREATE OR REPLACE VIEW exu9lnk (
                owner, ownerid, name, user$, passwd, host, public$,
                auth_user, auth_passwd, flag) AS
        SELECT  owner, ownerid, name, user$, passwd, host, public$,
                auth_user, auth_passwd, flag
        FROM    sys.exu10lnk 
        WHERE 1 = 2;
/
GRANT SELECT ON sys.exu9lnk TO EXP_FULL_DATABASE;

REM
REM current user's database links'
REM
CREATE OR REPLACE VIEW exu9lnku AS
        SELECT  *
        FROM    sys.exu9lnk
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9lnku TO PUBLIC;

REM
REM all database links
REM
CREATE OR REPLACE VIEW exu8lnk (
                owner, ownerid, name, user$, passwd, host, public$) AS
        SELECT  owner, ownerid, name, user$, passwd, host, public$
        FROM    sys.exu9lnk;
/
GRANT SELECT ON sys.exu8lnk TO EXP_FULL_DATABASE;

REM
REM 8.* version
REM
CREATE OR REPLACE VIEW exu8lnku AS
        SELECT  *
        FROM    sys.exu8lnk
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8lnku TO PUBLIC;


REM
REM all rollback segments
REM
CREATE OR REPLACE VIEW exu8rsg (
                owner, name, space$, tsno, fileno , blockno, minext, public$)
      AS
        SELECT  'SYSTEM', r$.name, ts$.name, r$.ts#, r$.file#, r$.block#,
                s$.minexts, DECODE(r$.user#, 1, 1, 0)
        FROM    sys.ts$ ts$, sys.undo$ r$, sys.seg$ s$
        WHERE   r$.status$ != 1 AND
                r$.file# = s$.file# AND
                r$.block# = s$.block# AND
                s$.ts# = ts$.ts# AND
                r$.ts# = s$.ts# AND
                r$.us# != 0 AND
                BITAND(ts$.flags, 16) = 0                 /* undo tablespace */
/
GRANT SELECT ON sys.exu8rsg TO SELECT_CATALOG_ROLE;

REM
REM info on deleted objects EXCEPT snapshots, snapshot logs
REM
CREATE OR REPLACE VIEW exu8del (
                owner, name, type, type#) AS
        SELECT  u$.name, i$.name,
                DECODE(i$.type#, 2, 'TABLE', 3, 'CLUSTER', 4, 'VIEW',
                       5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE', 8,
                       'FUNCTION', 9, 'PACKAGE', 12, 'TRIGGER', 11,
                       'PACKAGE BODY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30,
                       'JAVA RESOURCE', 32, 'INDEXTYPE', 33, 'OPERATOR', 43,
                       'DIMENSION', 56, 'JAVA DATA'), i$.type#
        FROM    sys.incexp i$, sys.user$ u$, sys.obj$ o$
        WHERE   i$.owner# = u$.user# AND
                i$.type# NOT IN (99, 98) AND
                i$.owner# = o$.owner# (+) AND /*"+ 0" for sort-merge outer jn*/
                i$.name = o$.name (+) AND
                i$.type# = o$.type# (+) AND
                o$.owner# IS NULL AND
                o$.linkname IS NULL
/
GRANT SELECT ON sys.exu8del TO SELECT_CATALOG_ROLE;

REM
REM info on sequence number
REM
CREATE OR REPLACE VIEW exu8seq (
                owner, ownerid, name, objid, curval, minval, maxval, incr,
                cache, cycle, order$, audt) AS
        SELECT  u.name, u.user#, o.name, o.obj#, s.highwater, s.minvalue,
                s.maxvalue, s.increment$, s.cache, s.cycle#, s.order$, s.audit$
        FROM    sys.exu81obj o, sys.user$ u, sys.seq$ s
        WHERE   o.obj# = s.obj# AND
                o.owner# = u.user#
/
GRANT SELECT ON sys.exu8seq TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8sequ AS
        SELECT  *
        FROM    sys.exu8seq
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8sequ TO PUBLIC;

REM
REM contraints on table
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8con (
                objid, owner, ownerid, tname, type, cname, cno, condition,
                condlength, enabled, defer, sqlver, iname, idxsysgend) AS
        SELECT  o.obj#, u.name, c.owner#, o.name, cd.type#, c.name, c.con#,
                cd.condition, cd.condlength, NVL(cd.enabled, 0),
                NVL(cd.defer, 0), sv.sql_version, NVL(oi.name, ''),
                DECODE(BITAND(NVL(oi.flags, 0), 4), 4, 1, 0)
        FROM    sys.obj$ o, sys.user$ u, sys.con$ c, sys.cdef$ cd,
                sys.exu816sqv sv, sys.obj$ oi
        WHERE   u.user# = c.owner# AND
                o.obj# = cd.obj# AND
                cd.con# = c.con# AND
                cd.spare1 = sv.version# (+) AND
                cd.enabled = oi.obj# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
/
GRANT SELECT ON sys.exu8con TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8conu AS
        SELECT  *
        FROM    sys.exu8con
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8conu TO PUBLIC;

REM
REM referential constraints
REM *** The reftyp field is trouble - meant to return any REF type associated
REM *** with the constraint, previously it would allow returning multiple rows
REM *** per constraint if there were multiple REFs in the target object (and
REM *** cannot be fixed since there is no correlation between the cdef$/ccol$
REM *** and refcon$ col/intcol numbers).
REM *** For 9.0.2, the reftyp value has been altered to only return the needed
REM *** pkREF type (4) if the target has a sole pkREF (supports older Exports)
REM *** and the new refconstr boolean has been added to support the 9.0.2 code
REM *** indicating a REF constraint (references a sOID or pkOID).
REM
CREATE OR REPLACE VIEW exu8ref (
                objid, owner, ownerid, tname, rowner, rtname, cname, cno, rcno,
                action, enabled, defer, property, robjid, rownerid, reftype,
                refconstr, type) AS
        SELECT  o.obj#, u.name, c.owner#, o.name, ru.name, ro.name, c.name,
                c.con#, cd.rcon#, NVL(cd.refact, 0), NVL(cd.enabled, 0),
                NVL(cd.defer, 0), NVL(t.property, 0), cd.robj#, ro.owner#,
                DECODE((SELECT COUNT (*)
                        FROM   sys.refcon$ rf
                        WHERE  rf.obj# = o.obj# AND
                               BITAND(rf.reftyp, 4) = 4),
                       1, 4, 0),            /* if 1, EXURUID, else not a REF */
                DECODE((SELECT COUNT (*)
                        FROM   sys.ccol$ cc, sys.col$ c
                        WHERE  cc.con# = cd.con# AND
                               c.obj# = cc.obj# AND
                               c.intcol# = cc.intcol# AND
                               BITAND(c.property, 2097152)= 2097152), /* REA */
                       0, 0, 1),                /* if none, FALSE, else TRUE */
                o.type#
        FROM    sys.user$ u, sys.user$ ru, sys.exu81obj o, sys.obj$ ro,
                sys.con$ c, sys.cdef$ cd, sys.tab$ t
        WHERE   u.user# = c.owner# AND
                o.obj# = cd.obj# AND
                ro.obj# = cd.robj# AND
                cd.con# = c.con# AND
                cd.type# = 4 AND
                ru.user# = ro.owner# AND
                o.obj# = t.obj# (+) AND
                u.name NOT IN ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                               'LBACSYS', 'XDB',  'SI_INFORMTN_SCHEMA',
                               'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS','ORACLE_OCM',
                               'ANONYMOUS', 'XS$NULL', 'APPQOSSYS') AND 
                NOT EXISTS (
                    SELECT  name, owner, obj_type
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name  AND
                            ne.obj_type = 2)
/
GRANT SELECT ON sys.exu8ref TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8refu AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8refu TO PUBLIC;

REM
REM referential constraints for incremental and cumulative export
REM for tables just exported, i.expid will be greater than v.expid
REM as v.expid is incremented only at the end of the incremental export
REM but i.expid is incremented when the table is exported.
REM USED ONLY WHEN RECORD = YES
REM
CREATE OR REPLACE VIEW exu8refic AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# = 2)
/
GRANT SELECT ON sys.exu8refic TO SELECT_CATALOG_ROLE;

REM
REM referential constraints for incremental export
REM exutabi will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu9refi AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabi)
/
GRANT SELECT ON sys.exu9refi TO SELECT_CATALOG_ROLE;

REM
REM referential constraints for cumulative export, assuming
REM exutabc will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu9refc AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabc)
/
GRANT SELECT ON sys.exu9refc TO SELECT_CATALOG_ROLE;

REM
REM referential constraints for incremental export
REM exutabi will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu81refi AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabi)
/
GRANT SELECT ON sys.exu81refi TO SELECT_CATALOG_ROLE;

REM
REM referential constraints for cumulative export, assuming
REM exutabc will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu81refc AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabc)
/
GRANT SELECT ON sys.exu81refc TO SELECT_CATALOG_ROLE;

REM
REM 8.0 referential constraints for incremental export
REM exutabi will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu8refi AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabi)
/
GRANT SELECT ON sys.exu8refi TO SELECT_CATALOG_ROLE;

REM
REM 8.0 referential constraints for cumulative export, assuming
REM exutabc will return the correct table name because RECORD = NO
REM
CREATE OR REPLACE VIEW exu8refc AS
        SELECT  *
        FROM    sys.exu8ref
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabc)
/
GRANT SELECT ON sys.exu8refc TO SELECT_CATALOG_ROLE;

REM
REM contraint column list
REM
CREATE OR REPLACE VIEW exu8ccl (
                ownerid, ownername, cno, colname, colno, intcol, property) AS
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(c.property, 1), 1, at.name, c.name),
                cc.col#, cc.intcol#, c.property
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u
        WHERE   o.obj# = cc.obj# AND
                c.obj# = cc.obj# AND
                cc.intcol# = c.intcol# AND
                o.owner# = u.user# AND
                c.obj# = at.obj# (+) AND
                c.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
/
GRANT SELECT ON sys.exu8ccl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8cclu AS
        SELECT  *
        FROM    sys.exu8ccl
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8cclu TO PUBLIC;

CREATE OR REPLACE VIEW exu8cclo (
                ownerid, cno, colname, colno, property) AS
        SELECT  a.ownerid, a.cno, a.colname, a.colno, a.property
        FROM    sys.exu8ccl a, sys.con$ b , sys.cdef$ c
        WHERE   b.owner# = userenv('SCHEMAID') AND
                b.con# = c.con# AND
                c.rcon# = a.cno
/
GRANT SELECT ON sys.exu8cclo TO PUBLIC;

REM
REM 9.0.2 regular, nested table setid, and REF constraint columns/attributes.
REM
REM The only known way to get the col/attr name for the SETID column
REM of a nested table is to locate the column with the same col#, intcol# -1,
REM and segcol# = 0.
REM
REM Inclusion of the exploded PRIMARY KEY col/attr names in the constraint
REM column attribute names for pkREFs requires deriving the actual REF column/
REM attribute name via the comparison of the constraint column intcol(s) with
REM the intcol number(s) list data in coltype$.
REM Comparing against only the first intcol number(s) list datum assures that
REM only 1 row will be retrieved when referencing a compound PRIMARY KEY (which
REM will have multiple constraint columns).
REM
CREATE OR REPLACE VIEW exu9ccl (
                ownerid, ownername, cno, colname, colno, intcol, property) AS
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(c.property, 1), 1, at.name, c.name),
                cc.pos#, c.intcol#, c.property
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                c.obj# = cc.obj# AND
                c.intcol# = cc.intcol# AND
                BITAND(c.property, 2097152) = 0 AND               /* Not REA */
                BITAND(c.property, 1024) = 0 AND                /* Not SETID */
                c.obj# = at.obj# (+) AND
                c.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
 UNION /* Nested Tables - SETID column */
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(c.property, 1), 1, at.name, c.name),
                cc.pos#, c.intcol#, c.property
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u, sys.col$ cn
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                cn.obj# = cc.obj# AND
                cn.intcol# = cc.intcol# AND
                BITAND(cn.property, 1024) = 1024 AND                /* SETID */
                c.obj# = cc.obj# AND
                c.col# = cn.col# AND
                c.intcol# = (cn.intcol# - 1) AND
                c.segcol# = 0 AND
                c.obj# = at.obj# (+) AND
                c.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
 UNION /* REFs - REF attribute columns */
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(rc.property, 1), 1, at.name, rc.name),
                cc.pos#, rc.intcol#, rc.property
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u, sys.coltype$ ct, sys.col$ rc
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                c.obj# = cc.obj# AND
                c.intcol# = cc.intcol# AND
                BITAND(c.property, 2097152) = 2097152 AND             /* REA */
                ct.obj# = cc.obj# AND
                ct.col# = cc.col# AND
                UTL_RAW.CAST_TO_BINARY_INTEGER(SUBSTRB(ct.intcol#s, 1,2), 3) =
                  cc.intcol# AND            /* first list col# = constr col# */
                rc.obj# = cc.obj# AND
                rc.intcol# = ct.intcol# AND
                rc.obj# = at.obj# (+) AND
                rc.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
/
GRANT SELECT ON sys.exu9ccl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9cclu AS
        SELECT  *
        FROM    sys.exu9ccl
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu9cclu TO PUBLIC;

CREATE OR REPLACE VIEW exu9cclo (
                ownerid, cno, colname, colno, property) AS
        SELECT  a.ownerid, a.cno, a.colname, a.colno, a.property
        FROM    sys.exu9ccl a, sys.con$ b , sys.cdef$ c
        WHERE   b.owner# = userenv('SCHEMAID') AND
                b.con# = c.con# AND
                c.rcon# = a.cno
/
GRANT SELECT ON sys.exu9cclo TO PUBLIC;

REM
REM 10i version of ccl* views
REM
REM 9.0.2 regular, nested table setid, and REF constraint columns/attributes.
REM
REM The only known way to get the col/attr name for the SETID column
REM of a nested table is to locate the column with the same col#, intcol# -1,
REM and segcol# = 0.
REM
REM Inclusion of the exploded PRIMARY KEY col/attr names in the constraint
REM column attribute names for pkREFs requires deriving the actual REF column/
REM attribute name via the comparison of the constraint column intcol(s) with
REM the intcol number(s) list data in coltype$.
REM Comparing against only the first intcol number(s) list datum assures that
REM only 1 row will be retrieved when referencing a compound PRIMARY KEY (which
REM will have multiple constraint columns).
REM
CREATE OR REPLACE VIEW exu10ccl (
                ownerid, ownername, cno, colname, colno, intcol, property,
                nolog) AS
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(c.property, 1), 1, at.name, c.name),
                cc.pos#, c.intcol#, c.property,
                DECODE(BITAND(cc.spare1, 1), 1, 1, 0)
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                c.obj# = cc.obj# AND
                c.intcol# = cc.intcol# AND
                BITAND(c.property, 2097152) = 0 AND               /* Not REA */
                BITAND(c.property, 1024) = 0 AND                /* Not SETID */
                c.obj# = at.obj# (+) AND
                c.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
 UNION /* Nested Tables - SETID column */
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(c.property, 1), 1, at.name, c.name),
                cc.pos#, c.intcol#, c.property,
                DECODE(BITAND(cc.spare1, 1), 1, 1, 0)
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u, sys.col$ cn
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                cn.obj# = cc.obj# AND
                cn.intcol# = cc.intcol# AND
                BITAND(cn.property, 1024) = 1024 AND                /* SETID */
                c.obj# = cc.obj# AND
                c.col# = cn.col# AND
                c.intcol# = (cn.intcol# - 1) AND
                c.segcol# = 0 AND
                c.obj# = at.obj# (+) AND
                c.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
 UNION /* REFs - REF attribute columns */
        SELECT  o.owner#, u.name, cc.con#,
                DECODE(BITAND(rc.property, 1), 1, at.name, rc.name),
                cc.pos#, rc.intcol#, rc.property,
                DECODE(BITAND(cc.spare1, 1), 1, 1, 0)
        FROM    sys.obj$ o, sys.col$ c, sys.ccol$ cc, sys.attrcol$ at,
                sys.user$ u, sys.coltype$ ct, sys.col$ rc
        WHERE   o.obj# = cc.obj# AND
                o.owner# = u.user# AND
                c.obj# = cc.obj# AND
                c.intcol# = cc.intcol# AND
                BITAND(c.property, 2097152) = 2097152 AND             /* REA */
                ct.obj# = cc.obj# AND
                ct.col# = cc.col# AND
                UTL_RAW.CAST_TO_BINARY_INTEGER(SUBSTRB(ct.intcol#s, 1,2), 3) =
                  cc.intcol# AND            /* first list col# = constr col# */
                rc.obj# = cc.obj# AND
                rc.intcol# = ct.intcol# AND
                rc.obj# = at.obj# (+) AND
                rc.intcol# = at.intcol# (+) AND
                NOT EXISTS (
                    SELECT  owner, name
                    FROM    sys.noexp$ ne
                    WHERE   ne.owner = u.name AND
                            ne.name = o.name AND
                            ne.obj_type = 2)
/
GRANT SELECT ON sys.exu10ccl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10cclu AS
        SELECT  *
        FROM    sys.exu10ccl
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu10cclu TO PUBLIC;

CREATE OR REPLACE VIEW exu10cclo (
                ownerid, cno, colname, colno, property, nolog) AS
        SELECT  a.ownerid, a.cno, a.colname, a.colno, a.property, a.nolog
        FROM    sys.exu10ccl a, sys.con$ b , sys.cdef$ c
        WHERE   b.owner# = userenv('SCHEMAID') AND
                b.con# = c.con# AND
                c.rcon# = a.cno
/
GRANT SELECT ON sys.exu10cclo TO PUBLIC;

REM
REM triggers on tables and views
REM
REM Notes: Fetch trigger OBJ# for 9.2
REM        actionsize obsolete as of 8.0.4
REM        sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu92tgr (
                ownerid, owner, baseobject, definition, whenclause, action,
                enabled, tproperty, name, basename, basetype, property,
                btowner, btownerid, sys_evts, sqlver, actionsize,
                trig_objno) AS
        SELECT  o.owner#, u.name, t.baseobject, t.definition, t.whenclause,
                t.action#, t.enabled, t.property, o.name,
                DECODE(BITAND(t.property, 24), 0, (
                    SELECT  o2.name
                    FROM    sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj#), ''),
                DECODE(BITAND(t.property, 24), 0, (
                    SELECT  o2.type#
                    FROM    sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj#), 0),
                NVL((
                    SELECT  tb.property
                    FROM    sys.tab$ tb
                    WHERE   t.baseobject = tb.obj#), 0),
                NVL((
                    SELECT  ut.name
                    FROM    sys.user$ ut, sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj# AND
                            o2.owner# = ut.user#), ''),
                NVL((
                    SELECT  ut.user#
                    FROM    sys.user$ ut, sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj# AND
                            o2.owner# = ut.user#), 0),
                t.sys_evts,
                (   SELECT  sv.sql_version
                    FROM    sys.exu816sqv sv
                    WHERE   o.spare1 = sv.version#),
                t.actionsize, t.obj#
        FROM    sys.exu81obj o, sys.trigger$ t, sys.user$ u
        WHERE   o.obj# = t.obj# AND
                u.user# = o.owner#
/
GRANT SELECT ON sys.exu92tgr TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu92tgru AS
        SELECT  *
        FROM    sys.exu92tgr
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu92tgru TO PUBLIC;

REM (for 9.2 so lrgs don't get diffs - obsolete)
REM triggers for incremental and cumulative export for table just
REM exported.  See comment on exu8refic.
REM
CREATE OR REPLACE VIEW exu92tgric AS
        SELECT  *
        FROM    sys.exu92tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# IN (2, 4))
/
GRANT SELECT ON sys.exu92tgric TO SELECT_CATALOG_ROLE;

REM 
REM pre-8.1.6 - filter out enhanced system events
REM actionsize obsolete in 8.0.4
REM
CREATE OR REPLACE VIEW exu92itgr AS
        SELECT  ownerid, owner, baseobject, definition, whenclause, action,
                enabled, tproperty, name, basename, basetype, property,
                btowner, btownerid, actionsize, trig_objno
        FROM    sys.exu92tgr
        WHERE   BITAND(sys_evts, 255) = sys_evts
/
GRANT SELECT ON sys.exu92itgr TO SELECT_CATALOG_ROLE;

REM
REM triggers for incremental export: record = no
REM
CREATE OR REPLACE VIEW exu92tgri AS
        SELECT  *
        FROM    sys.exu92itgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabi)
      UNION ALL
        SELECT  *
        FROM    sys.exu92itgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfi)
/
GRANT SELECT ON sys.exu92tgri TO SELECT_CATALOG_ROLE;

REM
REM triggers for cumulative export: record = no
REM
CREATE OR REPLACE VIEW exu92tgrc AS
        SELECT  *
        FROM    sys.exu92itgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabc)
      UNION ALL
        SELECT  *
        FROM    sys.exu92itgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfc)
/
GRANT SELECT ON sys.exu92tgrc TO SELECT_CATALOG_ROLE;
REM end of 9.2 incremental/cum views


REM
REM triggers on tables and views
REM
REM Notes: Replace previous outer joins with subqueries
REM        actionsize obsolete as of 8.0.4
REM        sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu816tgr (
                ownerid, owner, baseobject, definition, whenclause, action,
                enabled, tproperty, name, basename, basetype, property,
                btowner, btownerid, sys_evts, sqlver, actionsize) AS
        SELECT  o.owner#, u.name, t.baseobject, t.definition, t.whenclause,
                t.action#, t.enabled, t.property, o.name,
                DECODE(BITAND(t.property, 24), 0, (
                    SELECT  o2.name
                    FROM    sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj#), ''),
                DECODE(BITAND(t.property, 24), 0, (
                    SELECT  o2.type#
                    FROM    sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj#), 0),
                NVL((
                    SELECT  tb.property
                    FROM    sys.tab$ tb
                    WHERE   t.baseobject = tb.obj#), 0),
                NVL((
                    SELECT  ut.name
                    FROM    sys.user$ ut, sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj# AND
                            o2.owner# = ut.user#), ''),
                NVL((
                    SELECT  ut.user#
                    FROM    sys.user$ ut, sys.exu81obj o2
                    WHERE   t.baseobject = o2.obj# AND
                            o2.owner# = ut.user#), 0),
                t.sys_evts,
                (   SELECT  sv.sql_version
                    FROM    sys.exu816sqv sv
                    WHERE   o.spare1 = sv.version#),
                t.actionsize
        FROM    sys.exu81obj o, sys.trigger$ t, sys.user$ u
        WHERE   o.obj# = t.obj# AND
                u.user# = o.owner#
/
GRANT SELECT ON sys.exu816tgr TO SELECT_CATALOG_ROLE;

REM
REM pre-8.1.6 - filter out enhanced system events
REM actionsize obsolete in 8.0.4
REM
CREATE OR REPLACE VIEW exu81tgr AS
        SELECT  ownerid, owner, baseobject, definition, whenclause, action,
                enabled, tproperty, name, basename, basetype, property,
                btowner, btownerid, actionsize
        FROM    sys.exu816tgr
        WHERE   BITAND(sys_evts, 255) = sys_evts
/
GRANT SELECT ON sys.exu81tgr TO SELECT_CATALOG_ROLE;

REM
REM pre-8.1 filter out system events, call triggers, Java triggers, etc...
REM         (all but simple table and view triggers)
REM actionsize obsolete in 8.0.4
REM
CREATE OR REPLACE VIEW exu8tgr AS
        SELECT  ownerid, owner, baseobject, definition, whenclause, action,
                enabled, name, basename, basetype, property, btowner,
                btownerid, actionsize
        FROM    sys.exu816tgr
        WHERE   BITAND(tproperty, 127) in (0, 1)
/
GRANT SELECT ON sys.exu8tgr TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu816tgru AS
        SELECT  *
        FROM    sys.exu816tgr
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu816tgru TO PUBLIC;

CREATE OR REPLACE VIEW exu81tgru AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu81tgru TO PUBLIC;

CREATE OR REPLACE VIEW exu8tgru AS
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8tgru TO PUBLIC;

REM
REM triggers for incremental and cumulative export for table just
REM exported.  See comment on exu8refic.
REM
CREATE OR REPLACE VIEW exu816tgric AS
        SELECT  *
        FROM    sys.exu816tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# IN (2, 4))
/
GRANT SELECT ON sys.exu816tgric TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81tgric AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# IN (2, 4))
/
GRANT SELECT ON sys.exu81tgric TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8tgric AS
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# IN (2, 4))
/
GRANT SELECT ON sys.exu8tgric TO SELECT_CATALOG_ROLE;

REM
REM triggers for incremental export: record = no
REM
CREATE OR REPLACE VIEW exu9tgri AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabi)
      UNION ALL
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfi)
/
GRANT SELECT ON sys.exu9tgri TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu816tgri AS
        SELECT  *
        FROM    sys.exu816tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabi)
      UNION ALL
        SELECT  *
        FROM    sys.exu816tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfi)
/
GRANT SELECT ON sys.exu816tgri TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81tgri AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabi)
      UNION ALL
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfi)
/
GRANT SELECT ON sys.exu81tgri TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8tgri AS
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabi)
      UNION ALL
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfi)
/
GRANT SELECT ON sys.exu8tgri TO SELECT_CATALOG_ROLE;

REM
REM triggers for cumulative export: record = no
REM
CREATE OR REPLACE VIEW exu9tgrc AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabc)
      UNION ALL
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfc)
/
GRANT SELECT ON sys.exu9tgrc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu816tgrc AS
        SELECT *
        FROM    sys.exu816tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabc)
      UNION ALL
        SELECT  *
        FROM    sys.exu816tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfc)
/
GRANT SELECT ON sys.exu816tgrc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81tgrc AS
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabc)
      UNION ALL
        SELECT  *
        FROM    sys.exu81tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfc)
/
GRANT SELECT ON sys.exu81tgrc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8tgrc AS
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabc)
      UNION ALL
        SELECT  *
        FROM    sys.exu8tgr
        WHERE   (ownerid, basename) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8vinfc)
/
GRANT SELECT ON sys.exu8tgrc TO SELECT_CATALOG_ROLE;

REM
REM Notes: sqlver obsolete in 9.0
REM
REM 2734632 - use o.stime vs. o.mtime
CREATE OR REPLACE VIEW exu8spr(
                ownerid, uname, id, name, time, typeid, type, audt, sqlver) AS
        SELECT  o.owner#, u.name, o.obj#, o.name,
                TO_CHAR(o.stime, 'YYYY-MM-DD:HH24:MI:SS'), o.type#,
                DECODE(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                       11, 'PACKAGE BODY'),
                p.audit$, sv.sql_version
        FROM    sys.exu81obj o, sys.user$ u, sys.procedure$ p, sys.exu816sqv sv
        WHERE   o.owner# = u.user# AND
                o.type# IN (7, 8, 9, 11) AND
                o.obj# = p.obj# AND
                o.spare1 = sv.version# (+)
/
GRANT SELECT ON sys.exu8spr TO SELECT_CATALOG_ROLE;

REM
REM User's view
REM
CREATE OR REPLACE VIEW exu8spu AS
        SELECT  *
        FROM    sys.exu8spr
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8spu TO PUBLIC;

REM
REM stored procedures for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu8spri AS
        SELECT  s.*
        FROM    sys.exu8spr s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                NVL(i.type#, 7) IN (7, 8, 9, 11) AND
                NVL(i.expid, 9999) > v.expid
/
GRANT SELECT ON sys.exu8spri TO SELECT_CATALOG_ROLE;

REM
REM stored procedures for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu8sprc AS
        SELECT  s.*
        FROM    sys.exu8spr s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                NVL(i.type#, 7) IN (7, 8, 9, 11) AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8sprc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8sps(
                obj#, line, source) AS
        SELECT  obj#, line, source
        FROM    sys.source$
/
GRANT SELECT ON sys.exu8sps TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8spsu(
                obj#, line, source) AS
        SELECT  o.obj#, s.line, s.source
        FROM    sys.source$ s, sys.obj$ o
        WHERE   s.obj# = o.obj# AND
                o.owner# = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8spsu TO PUBLIC;

REM
REM stored java entities
REM
CREATE OR REPLACE VIEW exu81jav(
                ownerid, uname, id, shortname, typeid, type) AS
        SELECT  o.owner#, u.name, o.obj#, o.name, o.type#,
                DECODE(o.type#, 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE')
        FROM    sys.exu81obj o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# IN (28, 29, 30) AND
                (userenv('SCHEMAID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE')) AND
                u.name != 'SYS'
/
GRANT SELECT ON sys.exu81jav TO PUBLIC;

REM
REM Get Java entities for incremental export
REM
CREATE OR REPLACE VIEW exu81javi AS
        SELECT  j.*
        FROM    sys.exu81jav j, sys.incexp i, sys.incvid v
        WHERE   j.shortname = i.name(+) AND
                j.ownerid = i.owner#(+) AND
                NVL(i.type#, 28) IN (28, 29, 30, 31) AND
                v.expid < NVL(i.expid, 9999)
/
GRANT SELECT ON sys.exu81javi TO SELECT_CATALOG_ROLE;

REM
REM Get Java entities for cumulative export
REM
CREATE OR REPLACE VIEW exu81javc AS
        SELECT  j.*
        FROM    sys.exu81jav j, sys.incexp i, sys.incvid v
        WHERE   j.shortname = i.name(+) AND
                j.ownerid = i.owner#(+) AND
                NVL(i.type#, 28) IN (28, 29, 30, 31) AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu81javc TO SELECT_CATALOG_ROLE;

REM
REM check whether java class DbmsJava is installed
REM
CREATE OR REPLACE VIEW exu81javt (objid) AS
        SELECT  obj#
        FROM    sys.obj$
        WHERE   name LIKE '%DbmsJava' AND
                type# = 29 AND
                owner# = 0 AND
                status = 1
/
GRANT SELECT ON sys.exu81javt TO PUBLIC;

REM
REM system auditting options
REM
CREATE OR REPLACE VIEW exu8aud (
                userid, name, action, success, failure) AS
        SELECT  a.user#, u.name, m.name, NVL(a.success, 0), NVL(a.failure, 0)
        FROM    sys.audit$ a, sys.user$ u, sys.stmt_audit_option_map m
        WHERE   a.user# = u.user# AND
                a.option# = m.option# AND
                BITAND(m.property, 1) != 1
/
GRANT SELECT ON sys.exu8aud TO SELECT_CATALOG_ROLE;

REM
REM profiles
REM
CREATE OR REPLACE VIEW exu8prf(
                profile#, name) AS
        SELECT  profile#, name
        FROM    sys.profname$
        WHERE   profile# != 0
/
GRANT SELECT ON sys.exu8prf TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8prr(
                profile#, resource#, resname, type, limit) AS
        SELECT  p.profile#, p.resource#, r.name, p.type#, p.limit#
        FROM    sys.profile$ p, sys.resource_map r
        WHERE   p.resource# != 9 AND
                p.resource# = r.resource# AND
                p.type# = r.type#
/
GRANT SELECT ON sys.exu8prr TO SELECT_CATALOG_ROLE;

REM
REM password verification function
REM
CREATE OR REPLACE VIEW exu8pvf (
                funcid, funcname, line, source) AS
        SELECT  o.obj#, o.name, s.line, s.source
        FROM    sys.obj$ o, sys.source$ s
        WHERE   o.type# = 8 AND
                o.owner# = 0 AND
                o.obj# = s.obj#
/
GRANT SELECT ON sys.exu8pvf TO SELECT_CATALOG_ROLE;

REM
REM password history
REM
CREATE OR REPLACE VIEW exu8phs (
                userid, uname, password, password_date) AS
        SELECT  h.user#, u.name, h.password, 
                to_char(h.password_date,'YYYY-MM-DD HH24:MI:SS')
        FROM    sys.user_history$ h, sys.user$ u
        WHERE   h.user# = u.user#
/
GRANT SELECT ON sys.exu8phs TO EXP_FULL_DATABASE;


REM
REM trusted server links
REM
CREATE OR REPLACE VIEW exu8tsl (
                function, dbname, type) AS
        SELECT  DECODE(tl.dbname, '+*', 'allow_all', '-*', 'deny_all',
                       fdef.function),
                DECODE(tl.dbname, '+*', '', '-*', '', '('''||tl.dbname||''')'),
                DECODE(tl.dbname, '+*', 0, '-*', 0, 1)
        FROM    sys.trusted_list$ tl, (
                    SELECT  DECODE (dbname, '+*', 'deny_server ', '-*',
                                    'allow_server ') function
                    FROM    sys.trusted_list$
                    WHERE   dbname like '%*') fdef
/
GRANT SELECT ON sys.exu8tsl TO SELECT_CATALOG_ROLE;

REM
REM New snapshot views for v11
REM
CREATE OR REPLACE VIEW exu11snap (
                owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                rscn, objflag, flag2, status, sna_type_owner, sna_type_name,
                parent_sowner, parent_vname,
                file_ver, sql_ver, alias_txt, mview_comment, syn_count) AS
        SELECT  s.sowner, u.user#, s.vname, s.tname, s.mview, s.mlink, s.mtime,
                DECODE(s.can_use_log, NULL, 'NO', 'YES'), NVL(s.error#, 0),
                DECODE(s.auto_fast, 'C', 'COMPLETE', 'F', 'FAST', '?', 'FORCE',
                       NULL, 'FORCE', 'N', 'NEVER', 'ERROR'),
                s.query_txt, NVL(s.flag, 0),
                /*
                ** have a flag for each snapshot types: rowid, primary key and
                ** updatable for compatibility purpose
                */
                DECODE(BITAND(NVL(s.flag, 0), 16), 16, 1, 0),
                DECODE(BITAND(NVL(s.flag, 0), 32), 32, 1, 0),
                DECODE(BITAND(NVL(s.flag, 0), 2), 2, 1, 0),
                s.ustrg, s.uslog, s.tables, NVL(s.master_version, 0),
                RAWTOHEX(s.lobmaskvec), s.snapshot, NVL(s.snapid, 0),
                s.instsite, NVL(s.flavor_id, 0),
                s.rscn, s.objflag, s.flag2, s.status, s.sna_type_owner,
                s.sna_type_name, s.parent_sowner, s.parent_vname,
                9, 0, s.alias_txt, c.comment$, s.syn_count
        FROM    sys.snap$ s, sys.user$ u, sys.com$ c, sys.obj$ o, sys.tab$ t
        WHERE   u.name = s.sowner AND 
                o.owner# = u.user# AND 
                o.name = s.vname AND
                o.type# = 2 AND 
                o.obj# = t.obj# AND 
                (bitand(t.property, 67108864) = 67108864) AND
                o.obj# = c.obj#(+) AND c.col#(+) IS NULL
/
GRANT SELECT ON exu11snap TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu11snapu AS
        SELECT  *
        FROM    exu11snap
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT on sys.exu11snapu TO PUBLIC;

REM snapshots for incremental export: modified, altered or new
CREATE OR REPLACE VIEW exu11snapi AS
        SELECT  s.*
        FROM    sys.exu11snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                /*
                ** Since snapshot also creates a view with the same name,
                ** we need to check for both type view(4) and snapshot(99).
                ** Note: there will be duplicate entry in sys.incexp for this
                */
                NVL(i.type#, 99) in (4, 99) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON exu11snapi TO SELECT_CATALOG_ROLE;

REM
REM New snapshot views for v10
REM
CREATE OR REPLACE VIEW exu10snap (
                owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                rscn, objflag, flag2, status, sna_type_owner, sna_type_name,
                parent_sowner, parent_vname,
                file_ver, sql_ver, alias_txt, mview_comment, syn_count) AS
        SELECT  owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                rscn, objflag, flag2, status, sna_type_owner, sna_type_name,
                parent_sowner, parent_vname,
                8, sql_ver, alias_txt, mview_comment, syn_count
        FROM    exu11snap
/
GRANT SELECT ON exu10snap TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10snapu AS
        SELECT  *
        FROM    exu10snap
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT on sys.exu10snapu TO PUBLIC;

REM snapshots for incremental export: modified, altered or new
CREATE OR REPLACE VIEW exu10snapi AS
        SELECT  s.*
        FROM    sys.exu10snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                /*
                ** Since snapshot also creates a view with the same name,
                ** we need to check for both type view(4) and snapshot(99).
                ** Note: there will be duplicate entry in sys.incexp for this
                */
                NVL(i.type#, 99) in (4, 99) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON exu10snapi TO SELECT_CATALOG_ROLE;

REM The cumulative mode is not supported in 10g. So we do not have an exu10snapc
REM view, even though we have the exu9snapc for 9i.

REM
REM New snapshot views for v9
REM
CREATE OR REPLACE VIEW exu9snap (
                owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                rscn, objflag, flag2, status, sna_type_owner, sna_type_name,
                parent_sowner, parent_vname,
                file_ver, sql_ver, alias_txt, mview_comment) AS
        SELECT  owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                rscn, objflag, flag2, status, sna_type_owner, sna_type_name,
                parent_sowner, parent_vname,
                5, sql_ver, alias_txt, mview_comment
        FROM    exu11snap
/
GRANT SELECT ON exu9snap TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9snapu AS
        SELECT  *
        FROM    exu9snap
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT on sys.exu9snapu TO PUBLIC;

REM snapshots for incremental export: modified, altered or new
CREATE OR REPLACE VIEW exu9snapi AS
        SELECT  s.*
        FROM    sys.exu9snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                /*
                ** Since snapshot also creates a view with the same name,
                ** we need to check for both type view(4) and snapshot(99).
                ** Note: there will be duplicate entry in sys.incexp for this
                */
                NVL(i.type#, 99) in (4, 99) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON exu9snapi TO SELECT_CATALOG_ROLE;

REM snapshots for cumulative export: new, last export was inc or not valid
CREATE OR REPLACE VIEW exu9snapc AS
        SELECT  s.*
        FROM    sys.exu9snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                NVL(i.type#, 99) = 99 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON exu9snapc TO SELECT_CATALOG_ROLE;


REM
REM new snapshot views for v81
REM
CREATE OR REPLACE VIEW exu81snap (
                owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                file_ver, sql_ver) AS
        SELECT  owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, instsite, flavor_id,
                3, sql_ver
        FROM    exu9snap
        WHERE   BITAND(NVL(flag, 0), 16) +     /* supported snapshots: rowid */
                BITAND(NVL(flag, 0), 32) +                    /* primary key */
                BITAND(NVL(flag, 0), 256) +                       /* complex */
                BITAND(NVL(flag, 0), 4096) > 0                  /* aggregate */

/
GRANT SELECT ON sys.exu81snap TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81snapu AS
        SELECT  *
        FROM    sys.exu81snap
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81snapu TO PUBLIC;

REM
REM snapshots for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu81snapi AS
        SELECT  s.*
        FROM    sys.exu81snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                /*
                ** Since snapshot also creates a view with the same name,
                ** we need to check for both type view(4) and snapshot(99).
                ** Note: there will be duplicate entry in sys.incexp for this
                */
                NVL(i.type#, 99) in (4, 99) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu81snapi TO SELECT_CATALOG_ROLE;

REM
REM snapshots for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu81snapc AS
        SELECT  s.*
        FROM    sys.exu81snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                NVL(i.type#, 99) = 99 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu81snapc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81srt (
                sowner, sownerid, vname, master_owner, master, tabnum,
                refresh_time, master_flag, master_objnum, loadertime, instsite,
                lastsuccess, fcmaskvec, ejmaskvec,
                refscn, sub_handle, change_view) AS
        SELECT  srt.sowner, u.user#, srt.vname, srt.mowner, srt.master,
                srt.tablenum, srt.snaptime, srt.masflag, srt.masobj#,
                srt.loadertime, srt.instsite, srt.lastsuccess,
                RAWTOHEX(srt.fcmaskvec), RAWTOHEX(srt.ejmaskvec),
                srt.refscn, srt.sub_handle, srt.change_view
        FROM    sys.snap_reftime$ srt, sys.user$ u
        WHERE   u.name = srt.sowner
/
GRANT SELECT ON sys.exu81srt TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81srtu AS
        SELECT  *
        FROM    sys.exu81srt
        WHERE   sownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81srtu TO PUBLIC;

CREATE OR REPLACE VIEW exu81scm (
                sowner, sownerid, vname, tabnum, snacol, mascol, maspos, role,
                instsite, snapos) AS
        SELECT  sc.sowner, u.user#, sc.vname, sc.tabnum, sc.snacol, sc.mascol,
                NVL(sc.maspos, 0), NVL(sc.colrole, 0), instsite, sc.snapos
        FROM    sys.snap_colmap$ sc, sys.user$ u
        WHERE   u.name = sc.sowner
/
GRANT SELECT ON sys.exu81scm TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81scmu AS
        SELECT  *
        FROM    sys.exu81scm
        WHERE   sownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81scmu TO PUBLIC;

REM snapshots
REM
REM NOTE:
REM * In V8.1, flag was changed from UB2 to UB4. Thus when exporting
REM   to V8.0.X, the value of flag must be forced into a UB2
REM * Do not include MAVs or MJVs (KKZFJVS|KKZFAV1|KKZFAGG)
REM * Do not export to V8.0.X if the base table name is not SNAP$_*
REM
CREATE OR REPLACE VIEW exu8snap (
                owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, flag, rowid_snap,
                primkey_snap, update_snap, update_trig, update_log, mastabs,
                masver, lob_vector, snapshot, snapid, file_ver) AS
        SELECT  owner, ownerid, name, table_name, master_view, master_link,
                mtime, can_use_log, error, type, query, MOD(flag, 65536),
                rowid_snap, primkey_snap, update_snap, update_trig, update_log,
                mastabs, masver, lob_vector, snapshot, snapid, 2
        FROM    sys.exu81snap
        WHERE   BITAND(flag, 28672) = 0 AND   /* Do not include MAVs or MJVs */
                instsite = 0 AND          /* Do not include RepAPI snapshots */
                table_name LIKE 'SNAP$_%'
/
GRANT SELECT ON sys.exu8snap TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8snapu AS
        SELECT  *
        FROM    sys.exu8snap
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8snapu TO PUBLIC;

REM
REM snapshots for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu8snapi AS
        SELECT  s.*
        FROM    sys.exu8snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                /*
                ** Since snapshot also creates a view with the same name,
                ** we need to check for both type view(4) and snapshot(99).
                ** Note: there will be duplicate entry in sys.incexp for this
                */
                NVL(i.type#, 99) IN (4, 99) AND
                (s.mtime > i.itime OR NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8snapi TO SELECT_CATALOG_ROLE;

REM
REM snapshots for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu8snapc AS
        SELECT  s.*
        FROM    sys.exu8snap s, sys.incexp i, sys.incvid v
        WHERE   s.name = i.name(+) AND
                s.ownerid = i.owner#(+) AND
                NVL(i.type#, 99) = 99 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8snapc TO SELECT_CATALOG_ROLE;

REM
REM snapshot column mapping for each master table
REM
CREATE OR REPLACE VIEW exu8scm AS
        SELECT  sowner, sownerid, vname, tabnum, snacol, mascol, maspos, role
        FROM    sys.exu81scm
        WHERE   instsite = 0
/
GRANT SELECT ON sys.exu8scm TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8scmu AS
        SELECT  *
        FROM    sys.exu8scm
        WHERE   sownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8scmu TO PUBLIC;

REM
REM snapshot refresh time for each master table used by snapshot
REM
CREATE OR REPLACE VIEW exu8srt AS
        SELECT  sowner, sownerid, vname, master_owner, master, tabnum,
                refresh_time
        FROM    sys.exu81srt
        WHERE   instsite = 0              /* Do not include RepAPI snapshots */
/
GRANT SELECT ON sys.exu8srt TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8srtu AS
        SELECT  *
        FROM    sys.exu8srt
        WHERE   sownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8srtu TO PUBLIC;

REM
REM new snapshot log views for 10iR1
REM
CREATE OR REPLACE VIEW exu10snapl(
                log_owner, log_ownerid, master, log_table, log_trigger, flag,
                youngest, oldest, oldest_pk, mtime, rowid_snapl, primkey_snapl,
                oid_snapl, seq_snapl, inv_snapl, file_ver, temp_log,
                oldest_oid, oldest_new, oldest_seq) AS
        SELECT  m.mowner, u.user#, m.master, m.log, m.trig, NVL(m.flag, 0),
                m.youngest, m.oldest, m.oldest_pk, m.mtime,
                /* have a flag for each snapshot log types: rowid, primary key
                ** for compatibility purpose */
                DECODE(BITAND(NVL(m.flag, 0), 1), 1, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 2), 2, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 512), 512, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 1024), 1024, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 16), 16, 1, 0),
                7, m.temp_log, m.oldest_oid, m.oldest_new, m.oldest_seq
        FROM    sys.mlog$ m, sys.user$ u
        WHERE   m.mowner = u.name
/
GRANT SELECT ON sys.exu10snapl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10snaplu AS
        SELECT  *
        FROM    sys.exu10snapl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10snaplu TO PUBLIC;

REM
REM snapshot logs for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu10snapli AS
        SELECT  s.*
        FROM    sys.exu10snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                /* snapshot log also creates a table with the same name */
                NVL(i.type#, 98) IN (2, 98) AND
                (s.mtime > i.itime OR NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu10snapli TO SELECT_CATALOG_ROLE;

REM
REM snapshot logs for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu10snaplc AS
        SELECT  s.*
        FROM    sys.exu10snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                NVL(i.type#, 98) = 98 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu10snaplc TO SELECT_CATALOG_ROLE;

REM
REM new snapshot log views for v9.0
REM
CREATE OR REPLACE VIEW exu9snapl(
                log_owner, log_ownerid, master, log_table, log_trigger, flag,
                youngest, oldest, oldest_pk, mtime, rowid_snapl, primkey_snapl,
                oid_snapl, seq_snapl, inv_snapl, file_ver, temp_log,
                oldest_oid, oldest_new) AS
        SELECT  m.mowner, u.user#, m.master, m.log, m.trig, NVL(m.flag, 0),
                m.youngest, m.oldest, m.oldest_pk, m.mtime,
                /* have a flag for each snapshot log types: rowid, primary key
                ** for compatibility purpose */
                DECODE(BITAND(NVL(m.flag, 0), 1), 1, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 2), 2, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 512), 512, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 1024), 1024, 1, 0),
                DECODE(BITAND(NVL(m.flag, 0), 16), 16, 1, 0),
                5, m.temp_log, m.oldest_oid, m.oldest_new
        FROM    sys.mlog$ m, sys.user$ u
        WHERE   m.mowner = u.name
/
GRANT SELECT ON sys.exu9snapl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9snaplu AS
        SELECT  *
        FROM    sys.exu9snapl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9snaplu TO PUBLIC;

REM
REM snapshot logs for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu9snapli AS
        SELECT  s.*
        FROM    sys.exu9snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                /* snapshot log also creates a table with the same name */
                NVL(i.type#, 98) IN (2, 98) AND
                (s.mtime > i.itime OR NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu9snapli TO SELECT_CATALOG_ROLE;

REM
REM snapshot logs for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu9snaplc AS
        SELECT  s.*
        FROM    sys.exu9snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                NVL(i.type#, 98) = 98 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu9snaplc TO SELECT_CATALOG_ROLE;

REM
REM new snapshot log views for v8.1
REM select only v8.1 specific bits from mlog$.flag
REM do not export snapshot logs that are only OBJECT ID based.
REM
CREATE OR REPLACE VIEW exu81snapl(
                log_owner, log_ownerid, master, log_table, log_trigger, flag,
                youngest, oldest, oldest_pk, mtime, rowid_snapl, primkey_snapl,
                file_ver, temp_log) AS
        SELECT  log_owner, log_ownerid, master, log_table, log_trigger,
                /* Clear the bits (0x0080) and higher */
                BITAND(flag, 127), youngest, oldest, oldest_pk, mtime,
                rowid_snapl, primkey_snapl, 3, temp_log
        FROM    sys.exu9snapl
        WHERE   rowid_snapl = 1 OR
                primkey_snapl = 1
/
GRANT SELECT ON sys.exu81snapl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81snaplu AS
        SELECT  *
        FROM    sys.exu81snapl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81snaplu TO PUBLIC;

REM
REM snapshot logs for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu81snapli AS
        SELECT  s.*
        FROM    sys.exu81snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                /* snapshot log also creates a table with the same name */
                NVL(i.type#, 98) IN (2, 98) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu81snapli TO SELECT_CATALOG_ROLE;

REM
REM snapshot logs for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu81snaplc AS
        SELECT  s.*
        FROM    sys.exu81snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                NVL(i.type#, 98) = 98 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu81snaplc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81slfc (
                mowner, mownerid, master, colname, oldest, flag) AS
        SELECT  mr.mowner, u.user#, mr.master, mr.colname, mr.oldest,
                NVL(mr.flag, 0)
        FROM    sys.mlog_refcol$ mr, sys.user$ u
        WHERE   u.name = mr.mowner
/
GRANT SELECT ON sys.exu81slfc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81slfcu AS
        SELECT  *
        FROM    sys.exu81slfc
        WHERE   mownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81slfcu TO PUBLIC;

REM
REM snapshot log views for v8.0
REM
CREATE OR REPLACE VIEW exu8snapl (
                log_owner, log_ownerid, master, log_table, log_trigger, flag,
                youngest, oldest, oldest_pk, mtime, rowid_snapl, primkey_snapl,
                file_ver) AS
        SELECT  log_owner, log_ownerid, master, log_table, log_trigger,
                /* Clear bit (0x0040) indicating a temporary log was created */
                DECODE(BITAND(flag, 64), 64, flag - 64, flag), youngest,
                oldest, oldest_pk, mtime, rowid_snapl, primkey_snapl, 2
        FROM    sys.exu81snapl
/
GRANT SELECT ON sys.exu8snapl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8snaplu AS
        SELECT  *
        FROM    sys.exu8snapl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8snaplu TO PUBLIC;

REM
REM snapshot logs for incremental export: modified, altered or new
REM
CREATE OR REPLACE VIEW exu8snapli AS
        SELECT  s.*
        FROM    sys.exu8snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                /* snapshot log also creates a table with the same name */
                NVL(i.type#, 98) IN (2, 98) AND
                (s.mtime > i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8snapli TO SELECT_CATALOG_ROLE;

REM
REM snapshot logs for cumulative export: new, last export was inc or not valid
REM
CREATE OR REPLACE VIEW exu8snaplc AS
        SELECT  s.*
        FROM    sys.exu8snapl s, sys.incexp i, sys.incvid v
        WHERE   s.master = i.name(+) AND
                s.log_ownerid = i.owner#(+) AND
                NVL(i.type#, 98) = 98 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 NVL(i.expid, 9999) > v.expid)
/
GRANT SELECT ON sys.exu8snaplc TO SELECT_CATALOG_ROLE;

REM
REM info on deleted snapshots -- they aren't in obj$
REM
CREATE OR REPLACE VIEW exu8delsnap (
                owner, name, type) AS
        SELECT  u$.name, i$.name, 'SNAPSHOT'
        FROM    sys.incexp i$, sys.user$ u$
        WHERE   i$.owner# = u$.user# AND
                i$.type# = 99 AND
                (u$.name, i$.name) NOT IN (
                    SELECT  s$.sowner, s$.vname
                    FROM    sys.snap$ s$
                    WHERE   s$.instsite = 0)
/
GRANT SELECT ON sys.exu8delsnap TO SELECT_CATALOG_ROLE;

REM
REM info on deleted snapshot logs -- they aren't in obj$
REM
CREATE OR REPLACE VIEW exu8delsnapl (
                owner, name, type) AS
        SELECT  u$.name, i$.name, 'SNAPSHOT LOG'
        FROM    sys.incexp i$, sys.user$ u$
        WHERE   i$.owner# = u$.user# AND
                i$.type# = 98 AND
                (u$.name, i$.name) NOT IN (
                    SELECT  m$.mowner, m$.master
                    FROM    sys.mlog$ m$)
/
GRANT SELECT ON sys.exu8delsnapl TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8slog (
                mowner, mownerid, master, snapid, snaptime) AS
        SELECT  sl.mowner, u.user#, sl.master, NVL(sl.snapid, 0), sl.snaptime
        FROM    sys.slog$ sl, sys.user$ u
        WHERE   u.name = sl.mowner
/
GRANT SELECT ON sys.exu8slog TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8slogu AS
        SELECT  *
        FROM    sys.exu8slog
        WHERE   mownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8slogu TO PUBLIC;

REM
REM in v8.0 primary keys are not logged as filter columns
REM
CREATE OR REPLACE VIEW exu8slfc (
                mowner, mownerid, master, colname, oldest, flag) AS
        SELECT  mowner, mownerid, master, colname, oldest, 0
        FROM    sys.exu81slfc
        WHERE   BITAND(flag, 2) != 2
/
GRANT SELECT ON sys.exu8slfc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8slfcu AS
        SELECT  *
        FROM    sys.exu8slfc
        WHERE   mownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8slfcu TO PUBLIC;

CREATE OR REPLACE VIEW exu8glob (
                global_name) AS
        SELECT  value$
        FROM    sys.props$
        WHERE   name = 'GLOBAL_DB_NAME'
/
GRANT SELECT ON sys.exu8glob TO PUBLIC;

REM
REM info on analyzed objects (obsolete in 8.1)
REM
CREATE OR REPLACE VIEW exu8anal(
                id, rowcnt) AS
        SELECT  obj#, SIGN(NVL(rowcnt, -1))
        FROM    sys.tab$
/
GRANT SELECT ON sys.exu8anal TO PUBLIC;
GRANT SELECT ON sys.exu8anal TO SELECT_CATALOG_ROLE;

REM
REM Indexes for which optimizer statistics cannot be easily imported
REM
CREATE OR REPLACE VIEW exu9nos (
                tobjid, towner)
      AS                             /* Indexes for table must be exportable */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.obj$ io$, sys.ind$ ind$
        WHERE   ind$.bo# = to$.obj# AND
                ind$.obj# = io$.obj# AND
                ind$.blevel != -1 AND
                ind$.type# = 8 AND                              /* LOB index */
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
      UNION ALL                            /* Table cannot have associations */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.association$ a$
        WHERE   to$.obj# = a$.obj# AND
                to$.type# = 2 AND                                   /* Table */
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
      UNION ALL               /* Type used in table cannot have associations */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.obj$ tt$, sys.coltype$ ct$,
                sys.association$ a$
        WHERE   to$.obj# = ct$.obj# AND
                ct$.toid = tt$.oid$ AND
                tt$.obj# = a$.obj# AND
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9nos TO PUBLIC;

REM
REM Indexes for which optimizer statistics cannot be easily imported
REM
CREATE OR REPLACE VIEW exu81nos (
                tobjid, towner)
      AS                             /* Indexes for table must be exportable */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.obj$ io$, sys.ind$ ind$
        WHERE   ind$.bo# = to$.obj# AND
                ind$.obj# = io$.obj# AND
                ind$.blevel != -1 AND
                (BITAND(io$.flags, 4) = 4 OR             /* system generated */
                 ind$.type# = 8) AND                            /* LOB index */
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
      UNION ALL                            /* Table cannot have associations */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.association$ a$
        WHERE   to$.obj# = a$.obj# AND
                to$.type# = 2 AND                                   /* Table */
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
      UNION ALL               /* Type used in table cannot have associations */
        SELECT  to$.obj#, to$.owner#
        FROM    sys.obj$ to$, sys.obj$ tt$, sys.coltype$ ct$,
                sys.association$ a$
        WHERE   to$.obj# = ct$.obj# AND
                ct$.toid = tt$.oid$ AND
                tt$.obj# = a$.obj# AND
                (userenv('SCHEMAID') IN (to$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu81nos TO PUBLIC;

REM
REM Associations
REM
CREATE OR REPLACE VIEW exu81assoc (
                objowner, objowner#, objtype, objname, objcol, statsschema,
                statsname, selectivity, cpu_cost, io_cost, net_cost, 
                maintenancetype) AS
        SELECT  ou$.name, oo$.owner#, a$.property, oo$.name, NVL(c$.name, ''),
                NVL(su$.name, ''), NVL(so$.name, ''),
                NVL(a$.default_selectivity, 0), NVL(a$.default_cpu_cost, 0),
                NVL(a$.default_io_cost, 0), NVL(a$.default_net_cost, 0),
                a$.spare2
        FROM    sys.association$ a$, sys.exu81obj oo$, sys.user$ ou$,
                sys.col$ c$, sys.obj$ so$, sys.user$ su$
        WHERE   a$.obj# = oo$.obj# AND
                oo$.owner# = ou$.user# AND
                a$.intcol# = c$.intcol# (+) AND
                a$.obj# = c$.obj# (+) AND
                a$.statstype# = so$.obj# (+) AND
                so$.owner# = su$.user# (+) AND
                (userenv('SCHEMAID') IN (0, oo$.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu81assoc TO PUBLIC;

REM
REM add a view to determine storage clause for unique constraint
REM need for it to be user level because two different users can have the
REM same index name
REM Fields ipctfree, initr, imaxtr, and ipctthres are only used
REM for iots, not for regular tables.
REM
REM Obsolete with 9.0.2
REM
CREATE OR REPLACE VIEW exu8uscu (
                iobjid, idobjid, iname, itsno, ifileno, iblockno, ibobjid,
                ipctfree, iinitr, imaxtr, ipctthres, tspname, property,
                preccnt, deflog, ipbobjid) AS
        SELECT  o$.obj#, o$.dataobj#, o$.name, i$.ts#, i$.file#, i$.block#,
                i$.bo#, i$.pctfree$, i$.initrans, i$.maxtrans,
                MOD(i$.pctthres$, 256), t$.name, i$.property, i$.spare2,
                DECODE(BITAND(i$.flags, 4), 4, 1, 0), 0
        FROM    sys.obj$ o$, sys.ind$ i$, sys.file$ f$, sys.ts$ t$
        WHERE   o$.obj# = i$.obj# AND
                f$.relfile# = i$.file# AND
                f$.ts# = i$.ts# AND
                f$.ts# = t$.ts#
      UNION ALL
        SELECT  o$.obj#, o$.dataobj#, o$.name, ip$.ts#, ip$.file#, ip$.block#,
                ind$.bo#, ip$.pctfree$, ip$.initrans, ip$.maxtrans,
                MOD(ip$.pctthres$, 256), ts$.name, ind$.property, ip$.spare2,
                DECODE(BITAND(ind$.flags, 4), 4, 1, 0), ip$.bo#
        FROM    sys.obj$ o$, sys.indpart$ ip$, sys.ts$ ts$, sys.ind$ ind$,
                sys.tab$ t$
        WHERE   ip$.obj# = o$.obj# AND
                ts$.ts# = ip$.ts# AND
                ip$.bo# = ind$.obj# AND
                o$.type# = 20 AND                        /* Index partitions */
                ind$.bo# = t$.obj#
                AND BITAND(t$.property, 64) = 0                  /* Non-IOTs */
/
GRANT SELECT ON sys.exu8uscu TO PUBLIC;

REM
REM For iots only: Get top level index's characteristics
REM Expanded in 9.0.2 for use with IOTs in addition to PIOTs
REM  (dataobj only non null for IOTs)
REM
CREATE OR REPLACE VIEW exu81usci (
                ipctthres, ipreccnt, iobjid, tobjid, ovfobjid, ownerid,
                itsno, ifileno, iblockno, ipctfree, iinitr, imaxtr, deflog,
                idobjid) AS
        SELECT  MOD(i$.pctthres$, 256), NVL(i$.spare2, 0), i$.obj#, i$.bo#,
                NVL(t$.bobj#, 0), o$.owner#, i$.ts#, i$.file#, i$.block#,
                i$.pctfree$, i$.initrans, i$.maxtrans,
                DECODE(BITAND(i$.flags, 4), 4, 1, 0), NVL(i$.dataobj#, 0)
        FROM    sys.ind$ i$, sys.obj$ o$, sys.tab$ t$
        WHERE   i$.bo# = t$.obj# AND
                t$.obj# = o$.obj# AND
                i$.type# = 4
/
GRANT SELECT ON sys.exu81usci TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81usciu AS
        SELECT  *
        FROM    sys.exu81usci
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81usciu TO PUBLIC;

REM
REM For iots only: Get top level index's characteristics
REM Expanded in 9.0.2 for use with IOTs in addition to PIOTs
REM Expanded in 10.2.1 for mapping table.
REM  (dataobj only non null for IOTs)
REM
CREATE OR REPLACE VIEW exu10usci (
                ipctthres, ipreccnt, iobjid, tobjid, ovfobjid, ownerid,
                itsno, ifileno, iblockno, ipctfree, iinitr, imaxtr, deflog,
                idobjid, mapobj) AS
        SELECT  MOD(i$.pctthres$, 256), NVL(i$.spare2, 0), i$.obj#, i$.bo#,
                NVL(t$.bobj#, 0), o$.owner#, i$.ts#, i$.file#, i$.block#,
                i$.pctfree$, i$.initrans, i$.maxtrans,
                DECODE(BITAND(i$.flags, 4), 4, 1, 0), NVL(i$.dataobj#, 0),
                t$.pctfree$  /* mapping table obj# for IOTs */
        FROM    sys.ind$ i$, sys.obj$ o$, sys.tab$ t$
        WHERE   i$.bo# = t$.obj# AND
                t$.obj# = o$.obj# AND
                i$.type# = 4
/
GRANT SELECT ON sys.exu10usci TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10usciu AS
        SELECT  *
        FROM    sys.exu10usci
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10usciu TO PUBLIC;

REM
REM referential constraints
REM
CREATE OR REPLACE VIEW exu8rif (
                objid, owner, ownerid, tname, rowner, rtname, cname, cno, rcno,
                action, enabled, robjid, defer, property) AS
        SELECT  o.obj#, u.name, c.owner#, o.name, ru.name, ro.name, c.name,
                c.con#, cd.rcon#, NVL(cd.refact, 0), NVL(cd.enabled, 0),
                cd.robj#, NVL(cd.defer, 0), t.property
        FROM    sys.user$ u, sys.user$ ru, sys.obj$ o, sys.obj$ ro, sys.con$ c,
                sys.cdef$ cd, sys.tab$ t
        WHERE   u.user# = c.owner# AND
                o.obj# = cd.obj# AND
                ro.obj# = cd.robj# AND
                cd.con# = c.con# AND
                cd.type# = 4 AND
                ru.user# = ro.owner# AND
                t.obj# = o.obj#
/
GRANT SELECT ON sys.exu8rif TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8erc (
                resource_name, unit_cost) AS
        SELECT  m.name, c.cost
        FROM    sys.resource_cost$ c, sys.resource_map m
        WHERE   c.resource# = m.resource# AND
                m.type# = 0 AND
                c.resource# IN (2, 4, 7, 8)
/
GRANT SELECT ON sys.exu8erc TO SELECT_CATALOG_ROLE;

REM
REM determine OID index for a table
REM
CREATE OR REPLACE VIEW exu8oid (
                tobjid, intcol, iname, idefer, ownerid, pctfree$, initrans,
                maxtrans, itsno, ifile, iblock, itsname, idobjid) AS
        SELECT  cc$.obj#, cc$.intcol#, co$.name, cd$.defer, co$.owner#,
                i$.pctfree$, i$.initrans, i$.maxtrans, i$.ts#, i$.file#,
                i$.block#, ts$.name, i$.dataobj#
        FROM    sys.ccol$ cc$, sys.con$ co$, sys.cdef$ cd$, sys.obj$ o$,
                sys.ind$ i$, sys.ts$ ts$
        WHERE   cc$.con# = co$.con# AND
                cc$.con# = cd$.con# AND
                cd$.type# = 3 AND
                co$.owner# = o$.owner# AND
                co$.name = o$.name AND
                o$.obj# = i$.obj# AND
                i$.ts# = ts$.ts#
/
GRANT SELECT ON sys.exu8oid TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8oidu AS
        SELECT  *
        FROM    sys.exu8oid
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8oidu TO PUBLIC;

REM
REM determine LOB index and LOB storage for a table
REM
CREATE OR REPLACE VIEW exu9lob (
                tobjid, ownerid, cname, sname, ssgflag, stsname, stsno, sfile,
                sblock, sdobjid, schunking, svpool, sflags, iname, isgflag,
                itsname, itsno, ifile, iblock, idobjid, iinitrans, imaxtrans,
                sproperty, coltype, coltypflg, blocksize, intcolid, opaquetype,
                ifreepool)
      AS
        SELECT  l$.obj#, so$.owner#,
                DECODE(BITAND(c$.property, 1), 0, '"'||c$.name||'"', 1,
                       ac$.name),
                so$.name, so$.flags, sts$.name, sts$.ts#, l$.file#, l$.block#,
                so$.dataobj#, l$.chunk, l$.pctversion$, l$.flags, io$.name,
                io$.flags, its$.name, its$.ts#, i$.file#, i$.block#,
                io$.dataobj#, i$.initrans, i$.maxtrans, l$.property,
                NVL(c$.type#, 0), NVL(ct$.flags, 0), sts$.blocksize,
                c$.intcol#,
                NVL((SELECT opq.type
                     FROM   sys.opqtype$ opq
                     WHERE  c$.type# = 58 AND
                            c$.obj# = opq.obj# AND
                            c$.intcol# = opq.intcol#), -1),
                l$.freepools
        FROM    sys.lob$ l$, sys.obj$ so$, sys.col$ c$, sys.attrcol$ ac$,
                sys.seg$ ss$, sys.ts$ sts$, sys.ind$ i$, sys.obj$ io$,
                sys.ts$ its$, sys.coltype$ ct$
        WHERE   l$.lobj# = so$.obj# AND
                l$.obj# = c$.obj# AND
                l$.intcol# =
                     NVL((SELECT opq.lobcol
                          FROM   sys.opqtype$ opq
                          WHERE  c$.type# = 58 AND                 /* opaque */
                                 c$.obj# = opq.obj# AND
                                 c$.intcol# = opq.intcol# AND
                                 opq.type = 1 AND                /* XMLType */
                                 BITAND(opq.flags, 4) = 4  /* stored as lob */
                         ), c$.intcol#) AND
                c$.obj# = ac$.obj#(+) AND
                c$.intcol# = ac$.intcol#(+) AND
                l$.file# = ss$.file# AND
                l$.block# = ss$.block# AND
                ss$.ts# = sts$.ts# AND
                l$.ind# = i$.obj# AND
                l$.ind# = io$.obj# AND
                i$.ts# = its$.ts# AND
                sts$.ts# = its$.ts# AND
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                BITAND(c$.property, 32768) != 32768 AND /* not unused column */
                BITAND(c$.property, 256) != 256         /* not sys generated */
/
GRANT SELECT ON sys.exu9lob TO SELECT_CATALOG_ROLE;

REM
REM lob indexes for current user
REM
CREATE OR REPLACE VIEW exu9lobu AS
        SELECT  *
        FROM    sys.exu9lob
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9lobu TO PUBLIC;

REM
REM determine LOB index for a deferred storage table
REM
CREATE OR REPLACE VIEW exu112dlob (
                tobjid, ownerid, cname, sname, ssgflag, stsname, stsno, sfile,
                sblock, sdobjid, schunking, svpool, sflags, iname, isgflag,
                itsname, itsno, ifile, iblock, idobjid, iinitrans, imaxtrans,
                sproperty, coltype, coltypflg, blocksize, intcolid, opaquetype,
                ifreepool)
      AS
        SELECT  l$.obj#, so$.owner#,
                DECODE(BITAND(c$.property, 1), 0, '"'||c$.name||'"', 1,
                       ac$.name),
                so$.name, so$.flags, sts$.name, sts$.ts#, l$.file#, l$.block#,
                so$.dataobj#, l$.chunk, l$.pctversion$, l$.flags, io$.name,
                io$.flags, its$.name, its$.ts#, i$.file#, i$.block#,
                io$.dataobj#, i$.initrans, i$.maxtrans, l$.property,
                NVL(c$.type#, 0), NVL(ct$.flags, 0), sts$.blocksize,
                c$.intcol#,
                NVL((SELECT opq.type
                     FROM   sys.opqtype$ opq
                     WHERE  c$.type# = 58 AND
                            c$.obj# = opq.obj# AND
                            c$.intcol# = opq.intcol#), -1),
                l$.freepools
        FROM    sys.lob$ l$, sys.obj$ so$, sys.col$ c$, sys.attrcol$ ac$,
                sys.ts$ sts$, sys.ind$ i$, sys.obj$ io$,
                sys.ts$ its$, sys.coltype$ ct$
        WHERE   l$.lobj# = so$.obj# AND
                l$.obj# = c$.obj# AND
                l$.intcol# =
                     NVL((SELECT opq.lobcol
                          FROM   sys.opqtype$ opq
                          WHERE  c$.type# = 58 AND                 /* opaque */
                                 c$.obj# = opq.obj# AND
                                 c$.intcol# = opq.intcol# AND
                                 opq.type = 1 AND                /* XMLType */
                                 BITAND(opq.flags, 4) = 4  /* stored as lob */
                         ), c$.intcol#) AND
                c$.obj# = ac$.obj#(+) AND
                c$.intcol# = ac$.intcol#(+) AND
                l$.ind# = i$.obj# AND
                l$.ind# = io$.obj# AND
                i$.ts# = its$.ts# AND
                sts$.ts# = its$.ts# AND
                c$.obj# = ct$.obj# (+) AND
                c$.intcol# = ct$.intcol# (+) AND
                BITAND(c$.property, 32768) != 32768 AND /* not unused column */
                BITAND(c$.property, 256) != 256         /* not sys generated */
/
GRANT SELECT ON sys.exu112dlob TO SELECT_CATALOG_ROLE;

REM
REM lob indexes for current user
REM
CREATE OR REPLACE VIEW exu112dlobu AS
        SELECT  *
        FROM    sys.exu112dlob
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu112dlobu TO PUBLIC;

REM
REM pre 9.0 table LOB index/storage adjusted for TS specific blocksizes
REM determine LOB index and LOB storage for a table
REM
CREATE OR REPLACE VIEW exu8lob (
                tobjid, ownerid, cname, sname, ssgflag, stsname, stsno, sfile,
                sblock, sdobjid, schunking, svpool, sflags, iname, isgflag,
                itsname, itsno, ifile, iblock, idobjid, iinitrans, imaxtrans,
                sproperty, coltype, coltypflg) AS
        SELECT  l.tobjid, l.ownerid, l.cname, l.sname, l.ssgflag, l.stsname,
                l.stsno, l.sfile, l.sblock, l.sdobjid,
                CEIL(l.schunking * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.svpool, l.sflags, l.iname, l.isgflag, l.itsname, l.itsno,
                l.ifile, l.iblock, l.idobjid, l.iinitrans, l.imaxtrans,
                l.sproperty, l.coltype, l.coltypflg
        FROM    sys.exu9lob l
/
GRANT SELECT ON sys.exu8lob TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's table LOB index/storage adjusted for TS specific
REM blocksizes
REM
CREATE OR REPLACE VIEW exu8lobu AS
        SELECT  *
        FROM    sys.exu8lob
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8lobu TO PUBLIC;

REM
REM table level attributes definition for LOB columns
REM in partitioned tables
REM
CREATE OR REPLACE VIEW exu9plb (
                tobjid, ownerid, cname, lobname, tsname, sgflags, property,
                chunk, versionp, flags, iniexts, extsize, minexts, maxexts,
                extpct, flists, freegrp, pcache, coltype, coltypflg,
                blocksize, intcolid, opaquetype, maxsize, retention, mintime) AS
        SELECT  o.obj#, o.owner#, 
                DECODE(bitand(c.property,1), 0, '"'||c.name||'"', 1, ac.name),
                lo.name, ts.name, lo.flags,
                plob.defpro, plob.defchunk, plob.defpctver$, plob.defflags,
                NVL(plob.definiexts, 0), NVL(plob.defextsize, 0),
                NVL(plob.defminexts, 0), NVL(plob.defmaxexts, 0),
                NVL(plob.defextpct, -1), NVL(plob.deflists, 0),
                NVL(plob.defgroups, 0),
                DECODE(bitand(plob.defbufpool,3), 1, 'KEEP', 2, 'RECYCLE',
                       'DEFAULT'),
                NVL(c.type#, 0), NVL(ct.flags, 0),
                NVL(ts.blocksize, NVL( 
                        /* should be avail. thru lobcompart, lobfrag if null */
                (SELECT ts2.blocksize
                FROM    sys.ts$ ts2, sys.lobfrag$ lf
                WHERE   l.lobj# = lf.parentobj# AND
                        lf.ts# = ts2.ts# AND rownum < 2),
                (SELECT ts2.blocksize
                FROM    sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
                WHERE   l.lobj# = lcp.lobj# AND 
                        lcp.partobj# = lf.parentobj# AND 
                        lf.ts# = ts2.ts# AND rownum < 2))),
                c.intcol#,
                NVL((SELECT opq.type
                     FROM   sys.opqtype$ opq
                     WHERE  c.type# = 58 AND
                            c.obj# = opq.obj# AND
                            c.intcol# = opq.intcol#), -1),
                NVL(plob.defmaxsize, 0),
                NVL(plob.defretention, 0),
                NVL(plob.defmintime, 0)
        FROM    sys.partlob$ plob, sys.obj$ o, sys.lob$ l, sys.col$ c,
                sys.attrcol$ ac, sys.coltype$ ct, sys.obj$ lo, sys.ts$ ts
        WHERE   o.obj# = c.obj# AND
                l.obj# = c.obj# AND
                l.intcol# =
                     NVL((SELECT opq.lobcol
                          FROM   sys.opqtype$ opq
                          WHERE  c.type# = 58 AND                  /* opaque */
                                 c.obj# = opq.obj# AND
                                 c.intcol# = opq.intcol# AND
                                 opq.type = 1 AND                 /* XMLType */
                                 BITAND(opq.flags, 4) = 4   /* stored as lob */
                         ), c.intcol#) AND
                l.obj# = ac.obj#(+) and
                l.intcol# = ac.intcol#(+) and
                l.lobj# = lo.obj# AND
                l.lobj# = plob.lobj#  AND
                plob.defts# = ts.ts# (+) AND
                c.obj# = ct.obj# (+) AND
                c.intcol# = ct.intcol# (+) AND
                BITAND(c.property, 32768) != 32768 AND  /* not unused column */
                BITAND(c.property, 256) != 256          /* not sys generated */
/
GRANT SELECT ON sys.exu9plb TO SELECT_CATALOG_ROLE;

REM
REM table level default attributes for current
REM user's LOB columns in partitioned tables
REM
CREATE OR REPLACE VIEW exu9plbu AS
        SELECT  *
        FROM    sys.exu9plb
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9plbu TO PUBLIC;

REM
REM pre 9.0 partitioned tables table level attributes definition for LOB
REM columns adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81plb (
                tobjid, ownerid, cname, lobname, tsname, sgflags, property,
                chunk, versionp, flags, iniexts, extsize, minexts, maxexts,
                extpct, flists, freegrp, pcache, coltype, coltypflg) AS
        SELECT  l.tobjid, l.ownerid, l.cname, l.lobname, l.tsname, l.sgflags,
                l.property,
                CEIL(l.chunk * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.versionp, l.flags,
                CEIL(l.iniexts * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                CEIL(l.extsize * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.minexts, l.maxexts, l.extpct, l.flists, l.freegrp, l.pcache,
                l.coltype, l.coltypflg
        FROM    sys.exu9plb l
/
GRANT SELECT ON sys.exu81plb TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's partitioned tables table level attributes definition
REM for LOB columns adjusted for TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81plbu AS
        SELECT  *
        FROM    sys.exu81plb
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81plbu TO PUBLIC;

REM
REM determine attributes of noncomposite partitions of LOB columns
REM
CREATE OR REPLACE VIEW exu9lbp (
                pobjid, tobjid, ownerid, cname, lobpname, tsname, sgflags,
                chunk, versionp, flags, property, tsno, fileno, blockno,
                dobjid, iname, isgflag, itsname, itsno, ifile, iblock,
                idobjid, iinitrans, imaxtrans, coltype, coltypflg, blocksize)
      AS
        SELECT  /*+ NO_INDEX(i_obj1) +*/ 
                po.obj#, o.obj#, o.owner#, 
                DECODE(bitand(c.property,1), 0, '"'||c.name||'"', 1, ac.name),
                lpo.subname,
                ts.name, lpo.flags, lf.chunk, lf.pctversion$, lf.fragflags,
                lf.fragpro, lf.ts#, lf.file#, lf.block#, lpo.dataobj#,
                lipo.name, lipo.flags, its.name, its.ts#, ip.file#, ip.block#,
                lipo.dataobj#, ip.initrans , ip.maxtrans, NVL(c.type#, 0),
                (select NVL(ct.flags, 0) from sys.coltype$ ct
                        where ct.obj# = c.obj# AND ct.intcol# = c.intcol#),
                ts.blocksize
        FROM    sys.indpart$ ip, sys.obj$ o, sys.col$ c, 
                sys.attrcol$ ac, sys.obj$ lpo,
                sys.lob$ l, sys.partobj$ pobj, sys.ts$ ts, sys.obj$ lipo,
                sys.lobfrag$ lf, sys.obj$ po, sys.ts$ its
        WHERE   pobj.obj# = o.obj# AND
                MOD(pobj.spare2, 256) = 0 AND
                o.obj# = c.obj# AND
                c.obj# = l.obj# AND
                l.obj# = ac.obj#(+) AND
                l.intcol# = ac.intcol#(+) AND
                c.intcol# = l.intcol# AND
                l.lobj# = lf.parentobj# AND
                lf.fragobj# = lpo.obj# AND
                lf.tabfragobj# = po.obj# AND
                lf.indfragobj# = lipo.obj# AND
                lf.indfragobj# = ip.obj# AND
                ip.ts# = its.ts# AND
                lf.ts# = ts.ts# AND
                BITAND(c.property, 32768) != 32768 AND  /* not unused column */
                BITAND(c.property, 256) != 256          /* not sys generated */
      UNION ALL                                                      /* PIOT */
        SELECT  /*+ NO_INDEX(i_obj1) +*/ 
                ipt.obj#, o.obj#, o.owner#, 
                DECODE(bitand(c.property,1), 0, '"'||c.name||'"', 1, ac.name),
                lpo.subname,
                ts.name, lpo.flags, lf.chunk, lf.pctversion$, lf.fragflags,
                lf.fragpro, lf.ts#, lf.file#, lf.block#, lpo.dataobj#,
                lipo.name, lipo.flags, its.name, its.ts#, ip.file#, ip.block#,
                lipo.dataobj#, ip.initrans , ip.maxtrans, NVL(c.type#, 0),
                (select NVL(ct.flags, 0) from sys.coltype$ ct
                        where ct.obj# = c.obj# AND ct.intcol# = c.intcol#),
                ts.blocksize
        FROM    sys.indpart$ ipt, sys.indpart$ ip, sys.ind$ i, sys.tabpart$ tp,
                sys.obj$ o, sys.col$ c, sys.attrcol$ ac,
                sys.obj$ lpo, sys.lob$ l,
                sys.partobj$ pobj, sys.ts$ ts, sys.obj$ lipo, sys.lobfrag$ lf,
                sys.ts$ its
        WHERE   i.obj# = ipt.bo# AND
                tp.bo# = i.bo# AND
                tp.part# = ipt.part# AND
                pobj.obj# = o.obj# AND
                MOD(pobj.spare2, 256) = 0 AND
                o.obj# = c.obj# AND
                c.obj# = l.obj# AND
                l.obj# = ac.obj#(+) AND
                l.intcol# = ac.intcol#(+) AND
                c.intcol# = l.intcol# AND
                l.lobj# = lf.parentobj# AND
                lf.fragobj# = lpo.obj# AND
                lf.tabfragobj# = tp.obj#  AND
                lf.indfragobj# = lipo.obj# AND
                lf.indfragobj# = ip.obj# AND
                ip.ts# = its.ts# AND
                lf.ts# = ts.ts# AND
                BITAND(c.property, 32768) != 32768 AND  /* not unused column */
                BITAND(c.property, 256) != 256          /* not sys generated */
/
GRANT SELECT ON sys.exu9lbp TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9lbpu AS
        SELECT  *
        FROM    sys.exu9lbp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9lbpu TO PUBLIC;

REM
REM pre 9.0 attributes of noncomposite partitions of LOB columns
REM
CREATE OR REPLACE VIEW exu81lbp (
                pobjid, ownerid, cname, lobpname, tsname, sgflags, chunk,
                versionp, flags, property, tsno, fileno, blockno, dobjid,
                iname, isgflag, itsname, itsno, ifile, iblock, idobjid,
                iinitrans, imaxtrans, coltype, coltypflg) AS
        SELECT  l.pobjid, l.ownerid, l.cname, l.lobpname, l.tsname, l.sgflags,
                CEIL(l.chunk * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.versionp, l.flags, l.property, l.tsno, l.fileno, l.blockno,
                l.dobjid, l.iname, l.isgflag, l.itsname, l.itsno, l.ifile,
                l.iblock, l.idobjid, l.iinitrans, l.imaxtrans, l.coltype,
                l.coltypflg
        FROM    sys.exu9lbp l
/
GRANT SELECT ON sys.exu81lbp TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's attributes of noncomposite partitions of LOB columns
REM
CREATE OR REPLACE VIEW exu81lbpu AS
        SELECT  *
        FROM    sys.exu81lbp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81lbpu TO PUBLIC;

REM
REM determine LOB attributes for a composite partition
REM
CREATE OR REPLACE VIEW exu9lbcp (
                pobjid, ownerid, cname, lobcpname, tsname, sgflags, chunk,
                versionp, flags, property, iniexts, extsize, minexts, maxexts,
                extpct, flists, fgroups, pcache, coltype, coltypflg, blocksize,
                maxsize, retention, mintime)
      AS
        SELECT  po.obj#, o.owner#, 
                DECODE(bitand(c.property,1), 0, '"'||c.name||'"', 1, ac.name),
                lpo.subname, ts.name,
                lpo.flags, lcp.defchunk, lcp.defpctver$, lcp.defflags,
                lcp.defpro, NVL(lcp.definiexts, 0), NVL(lcp.defextsize, 0),
                NVL(lcp.defminexts, 0), NVL(lcp.defmaxexts, 0),
                NVL(lcp.defextpct, -1), NVL(lcp.deflists, 0),
                NVL(lcp.defgroups, 0),
                DECODE(bitand(lcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE',
                       'DEFAULT'),
                NVL(c.type#, 0), NVL(ct.flags, 0),
                NVL(ts.blocksize, (/*should be avail. thru tabcompart if null*/
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = (NVL((
                                SELECT  tcp$.defts#
                                FROM    sys.tabcompart$ tcp$
                                WHERE   tcp$.obj# = lcp.tabpartobj#),
                                           0)))),
                lcp.defmaxsize, lcp.defretention, lcp.defmintime
        FROM    sys.obj$ o, sys.lob$ l, sys.col$ c, sys.attrcol$ ac,
                sys.obj$ lo, sys.obj$ lpo,
                sys.lobcomppart$ lcp, sys.obj$ po, sys.ts$ ts,
                sys.partobj$ pobj, sys.coltype$ ct
        WHERE   pobj.obj# = o.obj# AND
                MOD(pobj.spare2, 256) != 0 AND
                o.obj# = c.obj# AND
                c.obj# = l.obj# AND
                l.obj# = ac.obj#(+) AND
                l.intcol# = ac.intcol#(+) AND
                l.intcol# = c.intcol# AND
                l.lobj# = lo.obj# AND
                l.lobj# = lcp.lobj# AND
                lcp.tabpartobj# = po.obj# AND
                lcp.partobj# = lpo.obj# AND
                lcp.defts# = ts.ts# (+) AND
                c.obj# = ct.obj# (+) AND
                c.intcol# = ct.intcol# (+) AND
                BITAND(c.property, 32768) != 32768 AND  /* not unused column */
                BITAND(c.property, 256) != 256          /* not sys generated */
/
GRANT SELECT ON sys.exu9lbcp TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9lbcpu AS
        SELECT  *
        FROM    sys.exu9lbcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9lbcpu TO PUBLIC;

REM
REM pre 9.0 LOB attributes for a composite partition adjusted for TS specific
REM blocksizes
REM
CREATE OR REPLACE VIEW exu81lbcp (
                pobjid, ownerid, cname, lobcpname, tsname, sgflags, chunk,
                versionp, flags, property, iniexts, extsize, minexts, maxexts,
                extpct, flists, fgroups, pcache, coltype, coltypflg) AS
        SELECT  l.pobjid, l.ownerid, l.cname, l.lobcpname, l.tsname, l.sgflags,
                CEIL(l.chunk * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.versionp, l.flags, l.property,
                CEIL(l.iniexts * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE t$.ts# = 0))),
                CEIL(l.extsize * (l.blocksize / (
                    SELECT  t$.blocksize
                    FROM    sys.ts$ t$
                    WHERE   t$.ts# = 0))),
                l.minexts, l.maxexts, l.extpct, l.flists, l.fgroups, l.pcache,
                l.coltype, l.coltypflg
        FROM    sys.exu9lbcp l
/
GRANT SELECT ON sys.exu81lbcp TO SELECT_CATALOG_ROLE;

REM
REM pre 9.0 cur user's LOB attributes for a composite partition adjusted for
REM TS specific blocksizes
REM
CREATE OR REPLACE VIEW exu81lbcpu AS
        SELECT  *
        FROM    sys.exu81lbcp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81lbcpu TO PUBLIC;

REM
REM Determine LOB storage for subpartition of LOB columns
REM for 8.1 and later
REM for 9.0 no columns needing pre 9.0 blocksize adjustment
REM
CREATE OR REPLACE VIEW exu81lbsp (
                pobjid, tobjid, ownerid, cname, lobspname, tsname, sgflags,
                tsno, fileno, blockno, dobjid, iname, isgflag, itsname, itsno,
                ifile, iblock, idobjid, iinitrans, imaxtrans, coltype,
                coltypflg, blocksize, flags) AS
        SELECT  /*+ NO_INDEX(i_obj1) +*/
                spo.obj#, o.obj#, o.owner#, 
                DECODE(bitand(c.property,1), 0, '"'||c.name||'"', 1, ac.name),
                lspo.subname,
                ts.name, lspo.flags, ts.ts#, lf.file#, lf.block#,
                lspo.dataobj#, lispo.name, lispo.flags, its.name, its.ts#,
                isp.file#, isp.block#, lispo.dataobj#, isp.initrans,
                isp.maxtrans, NVL(c.type#, 0),
                (select NVL(ct.flags, 0) from sys.coltype$ ct
                        where ct.obj# = c.obj# AND ct.intcol# = c.intcol#),
                ts.blocksize, lf.fragflags
        FROM    sys.lobfrag$ lf, sys.indsubpart$ isp, sys.lobcomppart$ lcp,
                sys.partobj$ pobj, sys.obj$ o, sys.col$ c, 
                sys.attrcol$ ac, sys.lob$ l,
                sys.obj$ spo, sys.obj$ lspo, sys.obj$ lispo, sys.ts$ its,
                sys.ts$ ts
        WHERE   pobj.obj# = o.obj# AND
                MOD(pobj.spare2, 256) != 0 AND
                o.obj# = c.obj# AND
                c.obj# = l.obj# AND
                c.intcol# = l.intcol# AND
                l.obj# = ac.obj#(+) AND
                l.intcol# = ac.intcol#(+) AND 
                l.lobj# = lcp.lobj# AND
                lf.parentobj# = lcp.partobj# AND
                lf.fragobj# = lspo.obj# AND
                lf.tabfragobj# = spo.obj# AND
                lf.indfragobj# = lispo.obj# AND
                lf.indfragobj# = isp.obj# AND
                isp.ts# = its.ts# AND
                lf.ts# = ts.ts# AND
                BITAND(c.property, 32768) != 32768 AND  /* not unused column */
                BITAND(c.property, 256) != 256          /* not sys generated */
/
GRANT SELECT ON sys.exu81lbsp TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81lbspu AS
        SELECT  /*+ NO_INDEX(xx1.o i_obj2) +*/ *
        FROM    sys.exu81lbsp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81lbspu TO PUBLIC;

REM
REM Job Queues
REM Should not export the jobs owns by sys 
REM
CREATE OR REPLACE VIEW exu8jbq (
                job, ownerid, owner, lowner, cowner, next_date, flag,
                interval#, what, nlsenv, env, instance) AS
        SELECT  j$.job, u$.user#, j$.powner, j$.lowner, j$.cowner,
                TO_CHAR(j$.next_date, 'YYYY-MM-DD:HH24:MI:SS'),
                DECODE(j$.flag, 1, 'TRUE', 0, 'FALSE'),
                REPLACE(j$.interval#, '''', ''''''),
                REPLACE(j$.what, '''', ''''''),
                REPLACE(j$.nlsenv, '''', ''''''), j$.env, j$.field1
        FROM    sys.job$ j$, sys.user$ u$
        WHERE   j$.powner = u$.name AND (u$.user# != 0 OR
                SYS_CONTEXT('USERENV','CURRENT_USERID') = 0) AND
                upper(what) <> 'SYS.DBMS_AQADM_SYS.REGISTER_DRIVER();'
/
GRANT SELECT ON sys.exu8jbq TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8jbqu AS
        SELECT  *
        FROM    sys.exu8jbq
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8jbqu TO PUBLIC;

REM
REM Refresh Groups
REM
CREATE OR REPLACE VIEW exu81rgs (
                refgroup, ownerid, owner, instsite) AS
        SELECT  NVL(r$.refgroup, 0), u$.user#, r$.owner, r$.instsite
        FROM    sys.rgroup$ r$, sys.user$ u$
        WHERE   r$.owner = u$.name
/
GRANT SELECT ON sys.exu81rgs TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81rgsu AS
        SELECT  *
        FROM    sys.exu81rgs
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu81rgsu TO PUBLIC;

CREATE OR REPLACE VIEW exu8rgs AS
        SELECT  refgroup, ownerid, owner
        FROM    sys.exu81rgs
        WHERE   instsite = 0              /* Do not include RepAPI refgroups */
/
GRANT SELECT ON sys.exu8rgs TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8rgsu AS
        SELECT  *
        FROM    sys.exu8rgs
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8rgsu TO PUBLIC;

REM
REM Refresh Group Children
REM
CREATE OR REPLACE VIEW exu81rgc (
                owner, ownerid, child, type, refgroup, instsite) AS
        SELECT  rc$.owner, u$.user#, rc$.name, rc$.type#, NVL(rc$.refgroup, 0),
                rc$.instsite
        FROM    sys.rgchild$ rc$, sys.user$ u$
        WHERE   rc$.owner = u$.name
/
GRANT SELECT ON sys.exu81rgc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81rgcu AS
        SELECT  *
        FROM    sys.exu81rgc
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu81rgcu TO PUBLIC;

CREATE OR REPLACE VIEW exu8rgc AS
        SELECT  owner, ownerid, child, type, refgroup
        FROM    sys.exu81rgc
        WHERE   instsite = 0              /* Do not include RepAPI snapshots */
/
GRANT SELECT ON sys.exu8rgc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8rgcu AS
        SELECT  *
        FROM    sys.exu8rgc
        WHERE   userenv('SCHEMAID') = ownerid
/
GRANT SELECT ON sys.exu8rgcu TO PUBLIC;

REM
REM PoSTtables actions
REM
CREATE OR REPLACE VIEW exu8pst (
                owner, ownerid, tname, tobjid, callorder, callarg, objtype,
                usrarg, property) AS
        SELECT  a$.owner, u$.user#, a$.name, o$.obj#, a$.callorder, a$.callarg,
                a$.obj_type, a$.user_arg, t$.property
        FROM    sys.expact$ a$, sys.user$ u$, sys.obj$ o$, sys.tab$ t$
        WHERE   u$.name = a$.owner AND
                o$.owner# = u$.user# AND
                o$.name = a$.name AND
                t$.obj# = o$.obj#
/
GRANT SELECT ON sys.exu8pst TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8pstu AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8pstu TO PUBLIC;

REM
REM PoSTtables actions incremental/cumulative with record = Y
REM
CREATE OR REPLACE VIEW exu8pstic AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# = 2)
/
GRANT SELECT ON sys.exu8pstic TO SELECT_CATALOG_ROLE;

REM
REM PoSTtables actions for incremental export : record = N
REM
CREATE OR REPLACE VIEW exu9psti AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabi)
/
GRANT SELECT ON sys.exu9psti TO SELECT_CATALOG_ROLE;

REM
REM PoSTtables actions for cumulative  export : record = N
REM
CREATE OR REPLACE VIEW exu9pstc AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu9tabc)
/
GRANT SELECT ON sys.exu9pstc TO SELECT_CATALOG_ROLE;

REM
REM 8.1 PoSTtables actions for incremental export : record = N
REM
CREATE OR REPLACE VIEW exu81psti AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabi)
/
GRANT SELECT ON sys.exu81psti TO SELECT_CATALOG_ROLE;

REM
REM PoSTtables actions for cumulative  export : record = N
REM
CREATE OR REPLACE VIEW exu81pstc AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu81tabc)
/
GRANT SELECT ON sys.exu81pstc TO SELECT_CATALOG_ROLE;

REM
REM 8.0 PoSTtables actions for incremental export : record = N
REM
CREATE OR REPLACE VIEW exu8psti AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabi)
/
GRANT SELECT ON sys.exu8psti TO SELECT_CATALOG_ROLE;

REM
REM 8.0 PoSTtables actions for cumulative  export : record = N
REM
CREATE OR REPLACE VIEW exu8pstc AS
        SELECT  *
        FROM    sys.exu8pst
        WHERE   (ownerid, tname) IN (
                    SELECT  ownerid, name
                    FROM    sys.exu8tabc)
/
GRANT SELECT ON sys.exu8pstc TO SELECT_CATALOG_ROLE;

REM
REM Version Control
REM
CREATE OR REPLACE VIEW exu8ver (
                version) AS
        SELECT  TO_NUMBER(value$)
        FROM    sys.props$
        WHERE   name = 'EXPORT_VIEWS_VERSION'
/
GRANT SELECT ON sys.exu8ver TO PUBLIC;

REM
REM Check for Procedural and Replication Options (obsolete in 8.0.4)
REM
CREATE OR REPLACE VIEW exu8cpo (
                parameter, value) AS
        SELECT  parameter, DECODE(value, 'TRUE', 1, 'FALSE', 0, 2)
        FROM    sys.v$option
        WHERE   parameter IN ('procedural', 'replication')
/
GRANT SELECT ON sys.exu8cpo TO PUBLIC;

REM
REM Check for non-exportable objects for all users
REM
CREATE OR REPLACE VIEW exu8nxp (
                ownerid, owner, name, type) AS
        SELECT  u$.user#, n$.owner, n$.name, n$.obj_type
        FROM    sys.noexp$ n$, sys.user$ u$
        WHERE   n$.owner = u$.name
/
GRANT SELECT ON sys.exu8nxp TO SELECT_CATALOG_ROLE;

REM
REM Check for non-exportable objects for current user
REM
CREATE OR REPLACE VIEW exu8nxpu AS
        SELECT  owner, name, type
        FROM    sys.exu8nxp
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8nxpu TO PUBLIC;

REM
REM obtain types of top level columns of a table
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8typt (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, deporder, typeid,
                roottoid) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv, sys.dependency$ d
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                NVL(o.type#, -1) != 10 AND
                t.toid  = t.tvoid AND                    /* Latest type only */
                o.spare1 = sv.version# (+) AND
                c.obj# = d.d_obj# AND
                d.p_obj# = o.obj#
/
GRANT SELECT ON sys.exu8typt TO SELECT_CATALOG_ROLE;

REM
REM obtain types of top level columns of a table (9.2+)
REM  possibly having PUBLIC type synonyms
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu9typt (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, synobjno, colsynobjno ) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, sy.obj#, c.synobj#
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv, sys.obj$ ne, sys.obj$ sy
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                NVL(o.type#, -1) != 10 AND
                t.toid  = t.tvoid AND                    /* Latest type only */
                o.spare1 = sv.version# (+) AND
                ne.obj# = c.synobj#  AND /* non_exist (neg depend) */
                sy.name = ne.name AND
                sy.owner# = 1 AND  /* PUBLIC */
                sy.type# = 5 /* SYNONYM */
/
GRANT SELECT ON sys.exu9typt TO SELECT_CATALOG_ROLE;

REM
REM obtain types of top level columns of a table (9.2+)
REM  possibly having PRIVATE type synonyms
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu9typt2 (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, synobjno, colsynobjno ) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, c.synobj#, c.synobj# 
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                NVL(o.type#, -1) != 10 AND
                t.toid  = t.tvoid AND                    /* Latest type only */
                o.spare1 = sv.version# (+) 
/
GRANT SELECT ON sys.exu9typt2 TO SELECT_CATALOG_ROLE;

REM
REM User's view
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8typtu (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, deporder, typeid,
                roottoid) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00')) 
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv, sys.dependency$ d
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND/* skip system gen'd types */
                t.toid  = t.tvoid AND                    /* Latest type only */
                NVL(o.type#, -1) != 10 AND
                c.obj# = d.d_obj# AND 
                d.p_obj# = o.obj# AND
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+)
/
GRANT SELECT ON sys.exu8typtu TO PUBLIC;

REM
REM User's view (9.2+)
REM
REM obtain types of top level columns of a table (9.2+)
REM  possibly having PUBLIC type synonyms
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu9typtu (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, synobjno, colsynobjno) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, sy.obj#, c.synobj#
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv, sys.obj$ ne, sys.obj$ sy
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND/* skip system gen'd types */
                t.toid  = t.tvoid AND                    /* Latest type only */
                NVL(o.type#, -1) != 10 AND
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+) AND
                ne.obj# = c.synobj#  AND /* non_exist (neg depend) */
                sy.name = ne.name AND
                sy.owner# = 1 AND  /* PUBLIC */
                sy.type# = 5 /* SYNONYM */
/
GRANT SELECT ON sys.exu9typtu TO PUBLIC;

REM
REM User's view (9.2+)
REM
REM obtain types of top level columns of a table (9.2+)
REM  possibly having PRIVATE type synonyms
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu9typtu2 (
                tname, towner, ownerid, toid, mtime, typobjno, tabobjno,
                audit$, sqlver, property,
                typobjstatus, tversion, thashcode, synobjno, colsynobjno) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, c.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, c.synobj#, c.synobj# 
        FROM    sys.coltype$ c, sys.user$ u, sys.obj$ o, sys.type$ t,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   t.toid = c.toid AND
                o.oid$ = c.toid AND
                u.user# = o.owner# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND/* skip system gen'd types */
                t.toid  = t.tvoid AND                    /* Latest type only */
                NVL(o.type#, -1) != 10 AND
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+) 
/
GRANT SELECT ON sys.exu9typtu2 TO PUBLIC;

REM
REM obtain parent types and subtypes, given a type
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8fpt (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, typeid,
                roottoid) AS
                /* Parent types */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                o.spare1 = sv.version# (+) AND
                t.toid = t.tvoid                     /* Only the latest type */
     UNION      /* Subtypes */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime,  'YYYY-MM-DD:HH24:MI:SS'), o.obj#, so.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.obj$ so,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                so.oid$ = t.roottoid AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                o.spare1 = sv.version# (+) AND
                t.toid = t.tvoid                     /* Only the latest type */
/
GRANT SELECT ON sys.exu8fpt TO SELECT_CATALOG_ROLE;

REM
REM User's view
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8fptu (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, typeid,
                roottoid) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+) AND
                t.toid   = t.tvoid                   /* Only the latest type */
     UNION
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime,  'YYYY-MM-DD:HH24:MI:SS'), o.obj#, so.obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.obj$ so,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                so.oid$ = t.roottoid AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                        SELECT  oa.obj#
                        FROM    sys.objauth$ oa
                        WHERE   oa.obj# = o.obj# AND
                                oa.privilege# = 12 AND            /* execute */
                                (oa.grantee# = userenv('SCHEMAID') OR
                                 oa.grantee# = 1)) OR
                /* current user or public role can execute any type */
                EXISTS (
                        SELECT  NULL
                        FROM    sys.sysauth$ sa
                        WHERE   (sa.grantee# = userenv('SCHEMAID') OR
                                 sa.grantee# = 1) AND
                                sa.privilege# = -184 )) AND
                o.spare1 = sv.version# (+)  AND
                t.toid   = t.tvoid                   /* Only the latest type */
/
GRANT SELECT ON sys.exu8fptu TO PUBLIC;

REM
REM obtain type body object number and audit, from type name and schema name
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu8typb (
                tname, towner, townerid, objno, sqlver) AS
        SELECT  o.name, u.name, o.owner#, o.obj#, sv.sql_version
        FROM    sys.obj$ o, sys.user$ u, sys.exu816sqv sv
        WHERE   o.type# = 14 AND
                u.user# = o.owner# AND
                o.spare1 = sv.version# (+)
/
GRANT SELECT ON sys.exu8typb TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8typbu AS
        SELECT  *
        FROM    sys.exu8typb
        WHERE   townerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8typbu TO PUBLIC;

REM
REM obtain info on all types
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu9typ (
                tname, towner, ownerid, toid, mtime, objno, audit$,
                secondaryobj, sqlver, typobjstatus, tversion, thashcode,
                typeid, roottoid) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, tm.audit$,
                DECODE(BITAND(o.flags, 16), 16, 1, 0), sv.sql_version,
                o.status, t.version#, t.hashcode, t.typeid, 
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.type_misc$ tm,
                sys.exu816sqv sv
        WHERE   o.type# = 13 AND
                o.oid$ = t.toid AND
                u.user# = o.owner# AND
                tm.obj# = o.obj# AND
                t.toid  = t.tvoid AND                 /* Only the latest rev */
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                u.name NOT IN ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                               'LBACSYS', 'XDB', 'SI_INFORMTN_SCHEMA',
                               'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS','ORACLE_OCM', 
                               'ANONYMOUS', 'XS$NULL', 'APPQOSSYS') AND
                o.spare1 = sv.version# (+)
/
GRANT SELECT ON sys.exu9typ TO SELECT_CATALOG_ROLE;

REM
REM obtain info on types for current user
REM
CREATE OR REPLACE VIEW exu9typu AS
        SELECT  *
        FROM    sys.exu9typ
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9typu TO PUBLIC;

REM
REM obtain info on all types
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu81typ (
                tname, towner, ownerid, toid, mtime, objno, audit$,
                secondaryobj, sqlver, typobjstatus, tversion, thashcode) AS
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, tm.audit$,
                DECODE(BITAND(o.flags, 16), 16, 1, 0), sv.sql_version,
                o.status, t.version#, t.hashcode
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.type_misc$ tm,
                sys.exu816sqv sv
        WHERE   o.type# = 13 AND
                o.oid$ = t.toid AND
                u.user# = o.owner# AND
                tm.obj# = o.obj# AND
                t.toid  = t.tvoid AND                 /* Only the latest rev */
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                u.name NOT IN ('ORDSYS', 'MDSYS', 'CTXSYS', 'ORDPLUGINS',
                               'LBACSYS', 'XDB',  'SI_INFORMTN_SCHEMA',
                               'DIP', 'DBSNMP', 'EXFSYS', 'WMSYS','ORACLE_OCM',
                               'ANONYMOUS', 'XS$NULL', 'APPQOSSYS') AND
                o.spare1 = sv.version# (+) AND
                BITAND(t.properties, 8) = 0 AND           /* skip NOT FINAL */
                BITAND(t.properties, 8192) = 0             /* skip subtypes */
/
GRANT SELECT ON sys.exu81typ TO SELECT_CATALOG_ROLE;

REM
REM obtain info on types for current user
REM
CREATE OR REPLACE VIEW exu81typu AS
        SELECT  *
        FROM    sys.exu81typ
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81typu TO PUBLIC;

REM
REM V8.0 type view, exu8typ must be subseted from exu81typ in order to filter
REM out types marked 'secondary object'.
REM
CREATE OR REPLACE VIEW exu8typ AS
        SELECT  *
        FROM    sys.exu81typ
        WHERE   secondaryobj = 0
/
GRANT SELECT ON sys.exu8typ TO SELECT_CATALOG_ROLE;

REM
REM obtain info on types for current user
REM
CREATE OR REPLACE VIEW exu8typu AS
        SELECT  *
        FROM    sys.exu8typ
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8typu TO PUBLIC;

REM
REM obtain parent types given a type
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu92fptp (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, deporder,
                typeid, roottoid) AS
                /* Parent types */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                o.spare1 = sv.version# (+) AND
                t.toid = t.tvoid                     /* Only the latest type */
/
GRANT SELECT ON sys.exu92fptp TO SELECT_CATALOG_ROLE;

REM
REM User's view
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu92fptpu (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, deporder,
                typeid, roottoid)
                AS
                /* Parent types */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00'))
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+) AND
                t.toid   = t.tvoid                   /* Only the latest type */
/
GRANT SELECT ON sys.exu92fptpu TO PUBLIC;

REM
REM obtain parent types and subtypes, given a type
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu92fpt (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, deporder,
                typeid, roottoid, tabobjno)
                AS
                /* Parent types */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00')), 0
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                o.spare1 = sv.version# (+) AND
                t.toid = t.tvoid                     /* Only the latest type */
     UNION      /* Subtypes */
        SELECT  sto.name, u.name, sto.owner#, t.toid,
                TO_CHAR(sto.mtime,  'YYYY-MM-DD:HH24:MI:SS'), sto.obj#, 
                d.p_obj#, tm.audit$, sv.sql_version, t.properties,
                sto.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00')), tabobj.obj#
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.obj$ sto,
                /*   o.obj$ is for the type is question */
                /* sto.obj$ is for the Sub Types of o.obj$ */
                sys.type_misc$ tm, sys.exu816sqv sv, sys.dependency$ d,
                sys.obj$ tabobj, sys.dependency$ d2, dependency$ d3
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                sto.type# = 13 AND
                sto.oid$ = t.toid AND
                sto.owner# = u.user# AND
                sto.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                sto.spare1 = sv.version# (+) AND
                t.toid = t.tvoid AND                 /* Only the latest type */
                sto.obj# = d.d_obj# AND
                d.p_obj#  = d2.p_obj# AND /*dependent type related to a table*/
                d2.d_obj# = tabobj.obj# AND 
                tabobj.type# = 2 AND
                sto.obj# = d3.p_obj# AND /* subtype related to same table */
                d3.d_obj# = tabobj.obj#
/
GRANT SELECT ON sys.exu92fpt TO SELECT_CATALOG_ROLE;

REM
REM User's view
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu92fptu (
                tname, towner, ownerid, toid, mtime, objno, dobjno, audit$,
                sqlver, property, typobjstatus, tversion, thashcode, deporder,
                typeid, roottoid, tabobjno)
                AS
                /* Parent types */
        SELECT  o.name, u.name, o.owner#, t.toid,
                TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.obj#, d.d_obj#,
                tm.audit$, sv.sql_version, t.properties,
                o.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00')), 0
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.dependency$ d,
                sys.type_misc$ tm, sys.exu816sqv sv
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                o.oid$ = t.toid AND
                o.owner# = u.user# AND
                o.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                (o.owner# = userenv('SCHEMAID') OR                  /* owned by current user */
                /* current user or public role have execute access to type */
                o.obj# IN (
                    SELECT  oa.obj#
                    FROM    sys.objauth$ oa
                    WHERE   oa.obj# = o.obj# AND
                            oa.privilege# = 12 AND                /* execute */
                            oa.grantee# IN (userenv('SCHEMAID'), 1)) OR
                EXISTS ( /* current user or public role can execute any type */
                    SELECT  NULL
                    FROM    sys.sysauth$ sa
                    WHERE   sa.grantee# IN (userenv('SCHEMAID'), 1) AND
                            sa.privilege# = -184)) AND
                o.spare1 = sv.version# (+) AND
                t.toid   = t.tvoid                   /* Only the latest type */
     UNION      /* Subtypes */
        SELECT  sto.name, u.name, sto.owner#, t.toid,
                TO_CHAR(sto.mtime,  'YYYY-MM-DD:HH24:MI:SS'), sto.obj#, 
                d.p_obj#, tm.audit$, sv.sql_version, t.properties,
                sto.status, t.version#, t.hashcode, d.order#, t.typeid,
                NVL(t.roottoid,HEXTORAW('00')), tabobj.obj#
        FROM    sys.obj$ o, sys.user$ u, sys.type$ t, sys.obj$ sto,
                /*   o.obj$ is for the type is question */
                /* sto.obj$ is for the Sub Types of o.obj$ */
                sys.type_misc$ tm, sys.exu816sqv sv, sys.dependency$ d,
                sys.obj$ tabobj, sys.dependency$ d2, dependency$ d3
        WHERE   o.obj# = d.p_obj# AND
                o.type# = 13 AND
                sto.type# = 13 AND 
                sto.oid$ = t.toid AND
                sto.owner# = u.user# AND
                sto.obj# = tm.obj# AND
                BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
                (sto.owner# = userenv('SCHEMAID') OR                /* owned by current user */
                /* current user or public role have execute access to type */
                sto.obj# IN (
                        SELECT  oa.obj#
                        FROM    sys.objauth$ oa
                        WHERE   oa.obj# = sto.obj# AND
                                oa.privilege# = 12 AND            /* execute */
                                (oa.grantee# = userenv('SCHEMAID') OR
                                 oa.grantee# = 1)) OR
                /* current user or public role can execute any type */
                EXISTS (
                        SELECT  NULL
                        FROM    sys.sysauth$ sa
                        WHERE   (sa.grantee# = userenv('SCHEMAID') OR
                                 sa.grantee# = 1) AND
                                sa.privilege# = -184 )) AND
                sto.spare1 = sv.version# (+) AND
                t.toid = t.tvoid AND                 /* Only the latest type */
                sto.obj# = d.d_obj# AND
                d.p_obj#  = d2.p_obj# AND /*dependent type related to a table*/
                d2.d_obj# = tabobj.obj# AND 
                tabobj.type# = 2 AND
                sto.obj# = d3.p_obj# AND /* subtype related to same table */
                d3.d_obj# = tabobj.obj#
/
GRANT SELECT ON sys.exu92fptu TO PUBLIC;

REM
REM XML/XDB schema based view of TYPEs referenced by a TABLE
REM Return the TYPE info for types that an XDB schema depends on
REM
CREATE OR REPLACE VIEW exu102xtyp (
        typename, typeowner, typownid, typobj#, 
        toid, mtime, typeaudit, 
        property, status, version, hashcode, 
        typeid, roottoid, 
        tabobjno ) 
        AS
        SELECT o.name, u.name, o.owner#, o.obj#, 
               t.toid, TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), tm.audit$, 
               t.properties, o.status, t.version#, t.hashcode,
               NVL(t.typeid,HEXTORAW('00')), NVL(t.roottoid,HEXTORAW('00')), 
               tabo.obj#
        FROM sys.user$ u, sys.obj$ o, sys.type$ t,sys.type_misc$ tm, 
             sys.dependency$ d, sys.exu816sqv sv, sys.obj$ tabo
        WHERE t.toid = o.oid$ AND
              u.user# = o.owner# AND
              o.obj# = tm.obj# AND
              BITAND(t.properties, 2128) = 0 AND /* skip system gen'd types*/
              NVL(o.type#, -1) != 10 AND
              t.toid  = t.tvoid AND                    /* Latest type only */
              o.spare1 = sv.version# (+) AND
              d.p_obj# = o.obj# AND
              tabo.type# = 2 AND /* table */
              d.d_obj# IN /* get XDB schema objs that table depends on */
              (SELECT d.p_obj# 
               FROM SYS.DEPENDENCY$ d, SYS.obj$ o
               WHERE d.d_obj# = tabo.obj# AND  /* dependent object is Table */
                     d.p_obj# = o.obj# AND /* parent object is XDB schema */
                     o.type# = 55) AND 
              o.obj# NOT IN /* ignore TYPEs that we already know about */
              (SELECT typobjno
               FROM sys.exu8typt
               WHERE tabobjno = tabo.obj#)
/
GRANT SELECT ON exu102xtyp to SELECT_CATALOG_ROLE;

REM
REM obtain info on XDB types for current user
REM
CREATE OR REPLACE VIEW exu102xtypu AS
        SELECT  *
        FROM    sys.exu102xtyp
        WHERE   typownid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu102xtypu TO PUBLIC;

REM
REM XMLSchemaTable view
REM Return the schemaoids from sys.opqtype$ for the passed in object#
REM (table).  Return only the items owned by the currently connected user.
REM
REM This view looks for XML schema types both directly in the table and
REM in nested tables at any level.
REM
CREATE OR REPLACE VIEW exu9xmlst (schemaoid, tobjid ) AS
        SELECT RAWTOHEX(opq.schemaoid), o.obj#
        FROM sys.opqtype$ opq, sys.obj$ o
        WHERE (o.obj# = opq.obj# OR 
               opq.obj# IN (    SELECT  nt.ntab#
                                FROM    sys.ntab$ nt
                                START WITH nt.obj# = o.obj#
                                CONNECT BY PRIOR nt.ntab# = nt.obj#)) AND
              opq.type = 1 AND                                   /* XML Type */
              BITAND(opq.flags, 2) = 2                          /* XMLSchema */
/
GRANT SELECT ON sys.exu9xmlst TO PUBLIC;

REM get the opqtype$ flags for xmltype - used to detect binary xml
CREATE OR REPLACE VIEW exu11xml (tobjid, flags ) AS
        SELECT o.obj#, opq.flags
        FROM sys.opqtype$ opq, sys.obj$ o
        WHERE (o.obj# = opq.obj# OR
               opq.obj# IN (    SELECT  nt.ntab#
                                FROM    sys.ntab$ nt
                                START WITH nt.obj# = o.obj#
                                CONNECT BY PRIOR nt.ntab# = nt.obj#)) AND
              opq.type = 1 AND                                   /* XML Type */
              BITAND(opq.flags, 4) = 4                         /* BINARY XML */
/
GRANT SELECT ON sys.exu11xml TO PUBLIC;

CREATE OR REPLACE VIEW exu9xdbuid (xdb_uid) AS
        SELECT r$.schema#
        FROM sys.registry$ r$ 
        WHERE r$.cid = 'XDB'
/
GRANT SELECT ON sys.exu9xdbuid TO PUBLIC;


REM
REM Add directory object IDR_DIR to noexp$ 
REM lrg 2612315
REM

INSERT INTO sys.noexp$ ( owner, name, obj_type ) VALUES
('SYS', 'IDR_DIR', 23)
/

REM
REM obtain all directory aliases
REM
CREATE OR REPLACE VIEW exu8dir (
                dirname, pathname, objno, audit$) AS
        SELECT  o$.name, d$.os_path, o$.obj#,
                substr(d$.audit$, 1, 1)  ||  substr(d$.audit$, 2, 1)   || /* ALTER */
                substr(d$.audit$, 3, 1)  ||  substr(d$.audit$, 4, 1)   || /* AUDIT */
                substr(d$.audit$, 5, 1)  ||  substr(d$.audit$, 6, 1)   || /* COMMENT */
                substr(d$.audit$, 7, 1)  ||  substr(d$.audit$, 8, 1)   || /* DELETE */
                substr(d$.audit$, 9, 1)  ||  substr(d$.audit$, 10, 1)  || /* GRANT */
                substr(d$.audit$, 11, 1) ||  substr(d$.audit$, 12, 1)  || /* INDEX */
                substr(d$.audit$, 13, 1) ||  substr(d$.audit$, 14, 1)  || /* INSERT */
                substr(d$.audit$, 15, 1) ||  substr(d$.audit$, 16, 1)  || /* LOCK */
                substr(d$.audit$, 17, 1) ||  substr(d$.audit$, 18, 1)  || /* RENAME */
                substr(d$.audit$, 19, 1) ||  substr(d$.audit$, 20, 1)  || /* SELECT */
                substr(d$.audit$, 21, 1) ||  substr(d$.audit$, 22, 1)  || /* UPDATE */
                '--'                                                   || /* REFERENCES */
                substr(d$.audit$, 25, 1) ||  substr(d$.audit$, 26, 1)  || /* EXECUTE */
                substr(d$.audit$, 27, 1) ||  substr(d$.audit$, 28, 1)  || /* CREATE */
                substr(d$.audit$, 35, 1) ||  substr(d$.audit$, 36, 1)  || /* READ */
                substr(d$.audit$, 37, 1) ||  substr(d$.audit$, 38, 1)     /* WRITE */
        FROM    sys.exu81obj o$, sys.dir$ d$
        WHERE   o$.type# = 23 AND                       /* directory aliases */
                o$.obj# = d$.obj# AND
        NOT EXISTS (
            SELECT  owner, name
            FROM    sys.noexp$ ne$
            WHERE   ne$.name = o$.name AND
                    ne$.obj_type = 23)
/
GRANT SELECT ON sys.exu8dir TO SELECT_CATALOG_ROLE;

REM
REM obtain all foreign function library names
REM
CREATE OR REPLACE VIEW exu8lib (
                lowner, libname, ownerid, filename, audit$, mtime, objno,
                isstatic, istrusted) AS
        SELECT  u$.name, o$.name, o$.owner#, lb$.filespec, lb$.audit$,
                TO_CHAR(o$.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o$.obj#,
                DECODE(BITAND(lb$.property, 1), 1, 1, 0),
                DECODE(BITAND(lb$.property, 2), 2, 1, 0)
        FROM    sys.exu81obj o$, sys.user$ u$, sys.library$ lb$
        WHERE   o$.type# = 22 AND                            /* library name */
                o$.owner# = u$.user# AND
                o$.obj# = lb$.obj#
/
GRANT SELECT ON sys.exu8lib TO SELECT_CATALOG_ROLE;

REM
REM obtain foreign function library names for user
REM
CREATE OR REPLACE VIEW exu8libu AS
        SELECT  *
        FROM    sys.exu8lib
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8libu TO PUBLIC;

REM
REM SCOPE and WITH ROWID information for REF columns/attributes
REM also returns any SCOPEd object objid and ref'd pkey cno/username if a pkREF
REM
CREATE OR REPLACE VIEW exu8rfs (
                objno, ownerid, property, colname, reftyp, soid, robjid,
                pkeycno, pkeyowner) AS
        SELECT  o$.obj#, o$.owner#, c$.property,
                DECODE(BITAND(c$.property, 1), 1, a$.name, c$.name),
                rf$.reftyp, NVL(rf$.stabid, HEXTORAW('00')),
                NVL2(rf$.stabid, (SELECT  ro$.obj#
                                  FROM    sys.obj$ ro$
                                  WHERE   ro$.oid$ = rf$.stabid),
                     0),
                DECODE(BITAND(rf$.reftyp, 4),
                       4, (SELECT  rcd$.con#
                           FROM    sys.obj$ ro$, sys.cdef$ rcd$
                           WHERE   ro$.oid$ = rf$.stabid AND
                                   rcd$.obj# = ro$.obj# AND
                                   rcd$.type# = 2),
                       0),
                DECODE(BITAND(rf$.reftyp, 4),
                       4, (SELECT  ru$.name
                           FROM    sys.obj$ ro$, sys.user$ ru$
                           WHERE   ro$.oid$ = rf$.stabid AND
                                   ru$.user# = ro$.owner#),
                       '')
        FROM    sys.refcon$ rf$, sys.obj$ o$, sys.col$ c$, sys.attrcol$ a$
        WHERE   rf$.obj# = o$.obj# AND
                rf$.obj# = c$.obj# AND
                rf$.intcol# = c$.intcol# AND
                rf$.obj# = a$.obj# (+) AND
                rf$.intcol# = a$.intcol# (+) AND
                rf$.reftyp != 0 AND
                BITAND(c$.property, 32768) != 32768     /* not unused column */
/
GRANT SELECT ON sys.exu8rfs TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8rfsu AS
        SELECT  *
        FROM    sys.exu8rfs
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8rfsu TO PUBLIC;

REM
REM exu8rfs(u) variation for user-defined REFs - obsoleted in 9.0.2
REM
REM Initial view included the sys.cdef$ table which broke export/import
REM cycle when SCOPE IS syntax was used for table constraints.
REM
CREATE OR REPLACE VIEW exu8orfs (
                objno, ownerid, property, colname, reftyp, soid, robjid, rname)
      AS
        SELECT  o$.obj#, o$.owner#, c$.property,
                DECODE(BITAND(c$.property, 1), 1, a$.name, c$.name),
                rf$.reftyp, rf$.stabid, ro$.obj#, ro$.name
        FROM    sys.refcon$ rf$, sys.obj$ o$, sys.col$ c$, sys.attrcol$ a$,
                sys.obj$ ro$
        WHERE   rf$.obj# = o$.obj# AND
                rf$.obj# = c$.obj# AND
                rf$.intcol# = c$.intcol# AND
                rf$.obj# = a$.obj# (+) AND
                rf$.intcol# = a$.intcol# (+) AND
                rf$.reftyp != 0 AND
                BITAND(c$.property, 32768) != 32768 AND /* not unused column */
                rf$.stabid = ro$.oid$ AND
                (userenv('SCHEMAID') IN (o$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu8orfs TO PUBLIC;

REM
REM obtain parent table info for an inner nested table
REM
CREATE OR REPLACE VIEW exu8pnt (
                pobjno, pname, pownerid, cobjno) AS
        SELECT  nt$.obj#, o$.name, o$.owner#, nt$.ntab#
        FROM    sys.obj$ o$, sys.ntab$ nt$
        WHERE   nt$.obj# = o$.obj#
/
GRANT SELECT ON sys.exu8pnt TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu8pntu AS
        SELECT  *
        FROM    sys.exu8pnt
        WHERE   pownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu8pntu TO PUBLIC;

REM
REM bitmap, functional and domain indexes are included if the base table
REM is included or if the index is defined on a table, and that table
REM references a table that is included in the export.
REM
REM Note that the following 9 views do not handle references to inner
REM nested tables, since references to and from inner nested tables
REM are not currently supported by SQL.  Should SQL allow such references
REM in the future, these views will need to be modified.
REM
REM incremental export for bitmap, functional and domain indices
REM (used only when record = yes)
REM
CREATE OR REPLACE VIEW exu9indic AS
        SELECT  *
        FROM    sys.exu9ind
        WHERE   sysgenconst = 0 AND               /* not sys gen constraints */
                (bitmap = 1 OR                             /* select bitmap, */
                 BITAND(property, 16) = 16 OR                 /* functional, */
                 type = 9) AND                         /* and domain indexes */
                (iownerid, btname) IN ((
                    SELECT  i.owner#, i.name
                    FROM    sys.incexp i, sys.incvid v
                    WHERE   i.expid > v.expid AND
                            i.type# = 2)
                  UNION (
                    SELECT  r.ownerid, r.tname
                    FROM    sys.incexp ii, sys.incvid vv, sys.exu8ref r
                    WHERE              /*refs a table included in the export */
                            r.rtname = ii.name AND
                            r.rownerid = ii.owner# AND
                            ii.expid > vv.expid AND
                            ii.type# = 2))
/
GRANT SELECT ON sys.exu9indic TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81indic AS
        SELECT  *
        FROM    sys.exu9indic
/
GRANT SELECT ON sys.exu81indic TO SELECT_CATALOG_ROLE;

REM
REM incremental export for bitmap indices in 8.0 (used only when record = yes)
REM
CREATE OR REPLACE VIEW exu8indic AS
        SELECT  *
        FROM    sys.exu81indic
        WHERE   BITAND(property, 16) != 16 AND/*Get bitmap but not functional*/
                type != 9                              /* nor domain indexes */
/
GRANT SELECT ON sys.exu8indic TO SELECT_CATALOG_ROLE;

REM
REM incremental export for bitmap, functional and domain indexes
REM note: exutabi will return the correct table name because record = no
REM
CREATE OR REPLACE VIEW exu9indi AS
        SELECT  *
        FROM    sys.exu9ind
        WHERE   sysgenconst = 0 AND                /* not sys gen constraint */
                (bitmap = 1 OR                             /* select bitmap, */
                 BITAND(property, 16) = 16 OR                 /* functional, */
                 type = 9) AND                         /* and domain indexes */
                (iownerid, btname) IN ((
                    SELECT  ownerid, name
                    FROM    sys.exu9tabi)
                  UNION (
                    SELECT  r.ownerid, r.tname
                    FROM    sys.exu9tabi ii, sys.exu8ref r
                    WHERE   r.robjid = ii.objid))   /* table included in inc */
/
GRANT SELECT ON sys.exu9indi TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81indi AS
        SELECT  *
        FROM    sys.exu81ind
        WHERE   sysgenconst = 0 AND                /* not sys gen constraint */
                (bitmap = 1 OR                             /* select bitmap, */
                 BITAND(property, 16) = 16 OR                 /* functional, */
                 type = 9) AND                         /* and domain indexes */
                (iownerid, btname) IN ((
                    SELECT  ownerid, name
                    FROM    sys.exu81tabi)
                  UNION (
                    SELECT  r.ownerid, r.tname
                    FROM    sys.exu9tabi ii, sys.exu8ref r
                    WHERE   r.robjid = ii.objid))   /* table included in inc */
/
GRANT SELECT ON sys.exu81indi TO SELECT_CATALOG_ROLE;

REM
REM incremental export for V8.0 bitmap indexes
REM
CREATE OR REPLACE VIEW exu8indi AS
        SELECT  *
        FROM    sys.exu81indi
        WHERE   BITAND(property, 16) != 16 AND/*Get bitmap but not functional*/
                type != 9                              /* nor domain indexes */
/
GRANT SELECT ON sys.exu8indi TO SELECT_CATALOG_ROLE;

REM
REM cumulative export for bitmap, functional and domain indexes
REM note: assume exutabc will return correct table name because record = no
REM
CREATE OR REPLACE VIEW exu9indc AS
        SELECT  *
        FROM    sys.exu9ind
        WHERE   sysgenconst = 0 AND                /* not sys gen constraint */
                (bitmap = 1 OR                             /* select bitmap, */
                 BITAND(property, 16) = 16 OR                 /* functional, */
                 type = 9) AND                         /* and domain indexes */
                (iownerid, btname) IN ((
                    SELECT  ownerid, name
                    FROM    sys.exu9tabc)
                  UNION (
                    SELECT  r.ownerid, r.tname
                    FROM    sys.exu81tabc cc, sys.exu8ref r
                    WHERE   r.robjid = cc.objid))   /* table included in cum */
/
GRANT SELECT ON sys.exu9indc TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu81indc AS
        SELECT  *
        FROM    sys.exu81ind
        WHERE   sysgenconst = 0 AND                /* not sys gen constraint */
                (bitmap = 1 OR                             /* select bitmap, */
                 BITAND(property, 16) = 16 OR                 /* functional, */
                 type = 9) AND                         /* and domain indexes */
                (iownerid, btname) IN ((
                    SELECT  ownerid, name
                    FROM    sys.exu81tabc)
                  UNION (
                    SELECT  r.ownerid, r.tname
                    FROM    sys.exu81tabc cc, sys.exu8ref r
                    WHERE   r.robjid = cc.objid))   /* table included in cum */
/
GRANT SELECT ON sys.exu81indc TO SELECT_CATALOG_ROLE;

REM
REM cumulative export for V8.0 bitmap indexes
REM
CREATE OR REPLACE VIEW exu8indc AS
        SELECT  *
        FROM    sys.exu81indc
        WHERE   BITAND(property, 16) != 16 AND/*Get bitmap but not functional*/
                type != 9                              /* nor domain indexes */
/
GRANT SELECT ON sys.exu8indc TO SELECT_CATALOG_ROLE;

REM
REM Operators
REM
REM Notes: sqlver obsolete in 9.0
REM
CREATE OR REPLACE VIEW exu81opr (
                name, objid, owner, ownerid, olevel, sqlver) AS
        SELECT  o.name, o.obj#, u.name, o.owner#, d.dlevel, sv.sql_version
        FROM    sys.exu81obj o, sys.user$ u, sys.operator$ op,
                sys.exu8ordop d, sys.exu816sqv sv
        WHERE   o.obj# = op.obj# AND
                o.owner# = u.user# AND
                o.obj# = d.obj#(+) AND
                o.spare1 = sv.version# (+)
/
GRANT SELECT ON sys.exu81opr TO SELECT_CATALOG_ROLE;

REM
REM Get operators for current user
REM
CREATE OR REPLACE VIEW exu81opru AS
        SELECT  *
        FROM    sys.exu81opr
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81opru TO PUBLIC;

REM
REM Get Operators for incremental export.
REM
CREATE OR REPLACE VIEW exu81opri AS
        SELECT  op.*
        FROM    sys.exu81opr op, sys.incexp i, sys.incvid v
        WHERE   op.name = i.name(+) AND
                op.ownerid = i.owner#(+) AND
                NVL(i.type#, 33) = 33 AND
                v.expid < NVL(i.expid, 9999)
/
GRANT SELECT ON sys.exu81opri TO SELECT_CATALOG_ROLE;

REM
REM Get Operators for cumulative export.
REM
CREATE OR REPLACE VIEW exu81oprc AS
        SELECT  op.*
        FROM    sys.exu81opr op, sys.incexp i, sys.incvid v
        WHERE   op.name = i.name(+) AND
                op.ownerid = i.owner#(+) AND
                NVL(i.type#, 33) = 33 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu81oprc TO SELECT_CATALOG_ROLE;

REM
REM Indextypes
REM
CREATE OR REPLACE VIEW exu81ity (
                name, objid, owner, ownerid) AS
        SELECT  o.name, o.obj#, u.name, o.owner#
        FROM    sys.exu81obj o, sys.user$ u, sys.indtypes$ i
        WHERE   o.obj# = i.obj# AND
                o.owner# = u.user#
/
GRANT SELECT ON sys.exu81ity TO SELECT_CATALOG_ROLE;

REM
REM Get Indextypes for current user
REM
CREATE OR REPLACE VIEW exu81ityu AS
        SELECT  *
        FROM    sys.exu81ity
        WHERE   ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu81ityu TO PUBLIC;

REM
REM Get Indextypes for incremental export.
REM
CREATE OR REPLACE VIEW exu81ityi AS
        SELECT  it.*
        FROM    sys.exu81ity it, sys.incexp i, sys.incvid v
        WHERE   it.name = i.name(+) AND
                it.ownerid = i.owner#(+) AND
                NVL(i.type#, 32) = 32 AND
                v.expid < NVL(i.expid, 9999)
/
GRANT SELECT ON sys.exu81ityi TO SELECT_CATALOG_ROLE;

REM
REM Get Indextypes for cumulative export.
REM
CREATE OR REPLACE VIEW exu81ityc AS
        SELECT  it.*
        FROM    sys.exu81ity it, sys.incexp i, sys.incvid v
        WHERE   it.name = i.name(+) AND
                it.ownerid = i.owner#(+) AND
                NVL(i.type#, 32) = 32 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu81ityc TO SELECT_CATALOG_ROLE;

REM
REM Get Row Level Security policies
REM
CREATE OR REPLACE VIEW exu81rls (
                objown, objnam, policy, polown, polsch, polfun, stmts, chkopt,
                enabled, spolicy) AS
        SELECT  u.name, o.name, r.pname, r.pfschma, r.ppname, r.pfname,
                DECODE(BITAND(r.stmt_type, 1), 0, '', 'SELECT,') ||
                DECODE(BITAND(r.stmt_type, 2), 0, '', 'INSERT,') ||
                DECODE(BITAND(r.stmt_type, 4), 0, '', 'UPDATE,') ||
                DECODE(BITAND(r.stmt_type, 8), 0, '', 'DELETE,'),
                r.check_opt, r.enable_flag,
                DECODE(BITAND(r.stmt_type, 16), 0, 0, 1)
        FROM    sys.user$ u, sys.obj$ o, sys.rls$ r
        WHERE   u.user# = o.owner# AND
                r.obj# = o.obj# AND
                (userenv('SCHEMAID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu81rls TO PUBLIC;

REM
REM Add support for PFGAC to get driving context
REM
CREATE OR REPLACE VIEW exu9pct (
                namespace, attribute, objown, objnam) AS
        SELECT  c.ns, c.attr, u.name, o.name
        FROM    sys.rls_ctx$ c, sys.user$ u, sys.obj$ o
        WHERE   c.obj# = o.obj# AND
                u.user# = o.owner# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9pct TO PUBLIC;

REM
REM Add support for PFGAC to get policy groups
REM
CREATE OR REPLACE VIEW exu9pgp (
                polgrp, objown, objnam) AS
        SELECT  g.gname, u.name, o.name
        FROM    sys.rls_grp$ g, sys.user$ u, sys.obj$ o
        WHERE   g.obj# = o.obj# AND
                u.user# = o.owner# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9pgp TO PUBLIC;

REM
REM Add support for PFGAC to get RLS policies
REM
REM Get Row Level Security policies
REM
REM bug 7183899: add support for VPD policies with statement_type of "INDEX"
REM Merging the 7183899 issue in 11g(MAIN) but no need for the KQLDRST_DVT 
REM changes as VPD isn't used by DV in MAIN

CREATE OR REPLACE VIEW exu9rls (
                objown, objnam, polgrp, policy, polown, polsch, polfun, stmt,
                chkopt, enabled, spolicy, poltyp) AS
        SELECT  u.name, o.name, r.gname, r.pname, r.pfschma, r.ppname,
                r.pfname,
                DECODE(BITAND(r.stmt_type, 1), 0, '', 'SELECT,') ||
                DECODE(BITAND(r.stmt_type, 2), 0, '', 'INSERT,') ||
                DECODE(BITAND(r.stmt_type, 4), 0, '', 'UPDATE,') ||
                DECODE(BITAND(r.stmt_type, 8), 0, '', 'DELETE,') ||
                DECODE(BITAND(r.stmt_type, 2048), 0, '', 'INDEX,'),
                r.check_opt, r.enable_flag,
                DECODE(BITAND(r.stmt_type, 16), 0, 0, 1),
                case bitand(r.stmt_type,16)+
                     bitand(r.stmt_type,64)+
                     bitand(r.stmt_type,128)+
                     bitand(r.stmt_type,256)+ 
                     bitand(r.stmt_type,8192)+
                     bitand(r.stmt_type,16384)+
                     bitand(r.stmt_type,32768)
                when 16 then 'DBMS_RLS.STATIC'
                when 64 then 'DBMS_RLS.SHARED_STATIC'
                when 128 then 'DBMS_RLS.CONTEXT_SENSITIVE'
                when 256 then 'DBMS_RLS.SHARED_CONTEXT_SENSITIVE'
                when 8192 then 'DBMS_RLS.XDS1'
                when 16384 then 'DBMS_RLS.XDS2'
                when 32768 then 'DBMS_RLS.XDS3'
                else 'DBMS_RLS.DYNAMIC'
               end
        FROM    sys.user$ u, sys.obj$ o, sys.rls$ r
        WHERE   u.user# = o.owner# AND
                r.obj# = o.obj# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9rls TO PUBLIC;

REM
REM Get all Dimensions
REM
CREATE OR REPLACE VIEW exu8dim (
                ownerid, owner, dimname, dimtext) AS
        SELECT  o.owner#, u.name, o.name, dm.dimtext
        FROM    sys.obj$ o, sys.user$ u, sys.dim$ dm
        WHERE   u.user# = o.owner# AND
                dm.obj# = o.obj# AND
                (userenv('SCHEMAID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu8dim TO PUBLIC;

REM
REM Get Dimensions for this user
REM
CREATE OR REPLACE VIEW exu8dimu AS
        SELECT  *
        FROM    sys.exu8dim
/
GRANT SELECT ON sys.exu8dimu TO PUBLIC;

REM
REM Get Dimensions for incremental export.
REM
CREATE OR REPLACE VIEW exu8dimi AS
        SELECT  dm.*
        FROM    sys.exu8dim dm, sys.incexp i, sys.incvid v
        WHERE   dm.dimname = i.name(+) AND
                dm.ownerid = i.owner#(+) AND
                NVL(i.type#, 43) = 43 AND
                v.expid < NVL(i.expid, 9999)
/
GRANT SELECT ON sys.exu8dimi TO SELECT_CATALOG_ROLE;

REM
REM Get Dimensions for Cumulative export.
REM
CREATE OR REPLACE VIEW exu8dimc AS
        SELECT  dm.*
        FROM    sys.exu8dim dm, sys.incexp i, sys.incvid v
        WHERE   dm.dimname = i.name(+) AND
                dm.ownerid = i.owner#(+) AND
                NVL(i.type#, 43) = 43 AND
                (NVL(i.ctime, TO_DATE('01-01-1900', 'DD-MM-YYYY')) < i.itime OR
                 v.expid < NVL(i.expid, 9999))
/
GRANT SELECT ON sys.exu8dimc TO SELECT_CATALOG_ROLE;

REM
REM All procedural objects. If the user has SELECT_CATALOG_ROLE, can see all
REM objects... otherwise, just his own.
REM
CREATE OR REPLACE VIEW exu81procobj (
                name, objid, owner, ownerid, type#, class, prepost, level#,
                package, pkg_schema) AS
        SELECT  o.name, o.obj#, u.name, o.owner#, o.type#, p.class, p.prepost,
                p.level#, p.package, p.schema
        FROM    sys.exu81obj o, sys.user$ u, sys.exppkgobj$ p
        WHERE   p.type# = o.type# AND
                o.owner# = u.user# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu81procobj TO PUBLIC;

REM
REM All instance class procedural objects: These are objects dependent upon a
REM parent object.
REM
CREATE OR REPLACE VIEW exu81procobjinstance (
                name, objid, owner, ownerid, type#, class, prepost, level#,
                package, pkg_schema, par_name, par_objid, par_property) AS
        SELECT  o.name, o.objid, o.owner, o.ownerid, o.type#, o.class,
                o.prepost, o.level#, o.package, o.pkg_schema, op.name,
                d.p_obj#, t.property
        FROM    sys.exu81procobj o, sys.expdepobj$ d, sys.exu81obj op,
                sys.tab$ t
        WHERE   o.class = 3 AND
                d.d_obj# = o.objid AND
                d.p_obj# = op.obj# AND
                d.p_obj# = t.obj#
/
GRANT SELECT ON sys.exu81procobjinstance TO PUBLIC;

REM
REM Packages providing procedural object support.
REM
CREATE OR REPLACE VIEW exu81objectpkg (
                package, pkg_schema, class, type#, level#) AS
        SELECT  package, schema, class, type#, level#
        FROM    sys.exppkgobj$
/
GRANT SELECT ON sys.exu81objectpkg TO PUBLIC;

REM
REM Packages providing procedural actions
REM
CREATE OR REPLACE VIEW exu81actionpkg (
                package, pkg_schema, class, level#) AS
        SELECT  package, schema, class, level#
        FROM    sys.exppkgact$
/
GRANT SELECT ON sys.exu81actionpkg TO PUBLIC;

REM
REM Objects that have procedural actions associated with them. Users with
REM SELECT_CATALOG_ROLE or can see all objects; otherwise, just their own.
REM Return both class 3 and class 4 for this view.  Class 3 will 
REM ignore namespace and class when issuing callback.
REM
REM This view is used by exu81actionobj view.
REM 
CREATE OR REPLACE VIEW exu9actionobj (
                name, objid, owner, ownerid, property, type#, level#, 
                package, pkg_schema, namespace, class ) AS
        SELECT  o.name, d.obj#, u.name, o.owner#, t.property, o.type#,
                p.level#, p.package, p.schema, o.namespace, p.class
        FROM    sys.exu81obj o, sys.user$ u, sys.exppkgact$ p, sys.tab$ t,
                sys.expdepact$ d
        WHERE   d.obj# = o.obj# AND
                o.owner# = u.user# AND
                d.package = p.package AND
                d.schema = p.schema AND
                ((p.class = 3) OR (p.class = 4)) AND
                d.obj# = t.obj# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9actionobj TO PUBLIC;

REM
REM For 8i view, we only return class = 3.  class 4 catagory added in 
REM 902 timeframe
REM 
CREATE OR REPLACE VIEW exu81actionobj (
                name, objid, owner, ownerid, property, type#, level#, package,
                pkg_schema) AS
        SELECT  oa.name, oa.objid, oa.owner, oa.ownerid, oa.property, 
                oa.type#, oa.level#, oa.package, oa.pkg_schema
        FROM    sys.exu9actionobj oa
        WHERE   oa.class = 3
/

GRANT SELECT ON sys.exu81actionobj TO PUBLIC;


REM
REM Get Collection Storage Compatibility Information
REM
REM v$compatibility is being removed with 10i, make sure this 
REM always returns 8.1.0.0.0
REM
CREATE OR REPLACE VIEW exu81csc (
                release) AS
        SELECT  '8.1.0.0.0'
        FROM    DUAL
/
GRANT SELECT ON sys.exu81csc TO PUBLIC;

REM
REM Enumerate tables in tablespace (for PITR and transportable ts modes)
REM Include tables that are either stored in the tablespace or whose 1st
REM (sub)partition is in the tablespace.  If a table is partitioned, but
REM its first partition is not stored in one of the PITR/TTS tablespaces,
REM it will not be returned through this query.  This will effectively drop
REM the partition when the TTS tablespaces are plugged back in.
REM If a secondary partition's tablespace is not in the TTS list, it will
REM be accounted for by the PL/SQL procedure that determines whether a TTS
REM is consistent.
REM
CREATE OR REPLACE VIEW exu81tts (
                dobjid, name, ownerid, tabno, clusterflag, tsname, hakan)
      AS                                             /* Unpartitioned tables */
        SELECT  NVL(t$.dataobj#, t$.obj#), o$.name, o$.owner#, NVL(t$.tab#, 0),
                NVL(t$.bobj#, 0), ts$.name, t$.spare1
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$
        WHERE   t$.obj# = o$.obj# AND
                t$.ts# = ts$.ts# AND
                BITAND(o$.flags, 128) != 128 AND       /* Recycle bin object */
                BITAND(t$.property, 64+512+8192) = 0    /* Not nested or IOT */
      UNION ALL                                   /* 1st Partition is simple */
        SELECT  t$.obj#, o$.name, o$.owner#, NVL(t$.tab#, 0), NVL(t$.bobj#, 0),
                ts$.name, t$.spare1
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$,
                (SELECT  bo#, 
                         MIN(ts#) KEEP (DENSE_RANK FIRST ORDER BY part#) ts#
                FROM     sys.tabpart$
                GROUP BY bo#) tp1$
        WHERE   t$.obj# = o$.obj# AND
                t$.obj# = tp1$.bo# AND
                tp1$.ts# = ts$.ts# AND
                BITAND(o$.flags, 128) != 128 AND
                BITAND(t$.property, 64+512+8192) = 0
      UNION ALL                           /* 1st Partition is subpartitioned */
        SELECT  t$.obj#, o$.name, o$.owner#, NVL(t$.tab#, 0), NVL(t$.bobj#, 0),
                ts$.name, t$.spare1
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$,
                (SELECT  tcp$.bo#,
                         MIN(tsp$.ts#) KEEP 
                           (DENSE_RANK FIRST ORDER BY 
                             tcp$.part#, tsp$.subpart#) ts#
                FROM     sys.tabcompart$ tcp$, sys.tabsubpart$ tsp$
                WHERE    tcp$.obj# = tsp$.pobj#
                GROUP BY tcp$.bo#) tcp1$
        WHERE   t$.obj# = o$.obj# AND
                t$.obj# = tcp1$.bo# AND
                tcp1$.ts# = ts$.ts# AND
                BITAND(o$.flags, 128) != 128 AND       /* recycle bin object */
                BITAND(t$.property, 64+512+8192) = 0
      UNION ALL                                        /* Unpartitioned IOTs */
        SELECT  i$.dataobj#, o$.name, o$.owner#, NVL(t$.tab#, 0),
                NVL(t$.bobj#, 0), ts$.name, t$.spare1
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.ind$ i$
        WHERE   t$.obj# = o$.obj# AND
                t$.pctused$ = i$.obj# AND /*For IOTs, pctused has index obj# */
                i$.ts# = ts$.ts# AND
                BITAND(o$.flags, 128) != 128 AND       /* recycle bin object */
                BITAND(t$.property, 64+512+8192) = 64
      UNION ALL                                      /* 1st Partition of IOT */
        SELECT  t$.obj#, o$.name, o$.owner#, NVL(t$.tab#, 0), NVL(t$.bobj#, 0),
                ts$.name, t$.spare1
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$,
                (SELECT  bo#, 
                         MIN(ts#) KEEP (DENSE_RANK FIRST ORDER BY part#) ts#
                FROM     sys.indpart$
                GROUP BY bo#) ip1$
        WHERE   t$.obj# = o$.obj# AND
                t$.pctused$ = ip1$.bo# AND
                ip1$.ts# = ts$.ts# AND
                BITAND(o$.flags, 128) != 128 AND       /* recycle bin object */
                BITAND(t$.property, 64+512+8192) = 64
/
GRANT SELECT ON sys.exu81tts TO SELECT_CATALOG_ROLE;

REM Determine icache plsql mode
REM YES or NO, if not present, default to NO
REM
CREATE OR REPLACE VIEW exu8icplsql (
                value) AS
        SELECT  value$
        FROM    sys.props$
        WHERE   name = 'ICACHE_IMP_PLSQL'
/
GRANT SELECT ON sys.exu8icplsql TO PUBLIC;

REM
REM Enumerate tables in tablespace (for logical export of tablespaces)
REM Include tables that are either stored in the tablespace or have a partition
REM stored in the tablespace.  Ignore tables in SYS and cartridge schemas.
REM dobjid and tabno are not used for logical export.
REM Use sys.obj$ directly to make sure secondary objects are included.
REM
CREATE OR REPLACE VIEW exu9ltts (
                dobjid, name, ownerid, tabno, clusterflag, tsname)
      AS                                             /* Unpartitioned tables */
        SELECT  0, o$.name, o$.owner#, 0, NVL(t$.bobj#, 0), ts$.name
        FROM    sys.tab$ t$, sys.exu81obj o$, sys.ts$ ts$
        WHERE   t$.obj# = o$.obj# AND
                t$.ts# = ts$.ts# AND
                o$.owner# != 0 AND
                BITAND(t$.property, 32+64+512+8192) = 0 /* Not nested or IOT */
      UNION ALL                                         /* Simple Partitions */
        SELECT  0, o$.name, o$.owner#, 0, NVL(t$.bobj#, 0), ts$.name
        FROM    sys.tab$ t$, sys.obj$ o$, sys.tabpart$ tp$, sys.ts$ ts$
        WHERE   t$.obj# = o$.obj# AND
                t$.obj# = tp$.bo# AND
                tp$.ts# = ts$.ts# AND
                o$.owner# != 0 AND
                BITAND(t$.property, 32+64+512+8192) = 32
      UNION ALL                                      /* Composite partitions */
        SELECT  0, o$.name, o$.owner#, 0, NVL(t$.bobj#, 0), ts$.name
        FROM    sys.tab$ t$, sys.obj$ o$, sys.tabcompart$ tcp$,
                sys.tabsubpart$ tsp$, sys.ts$ ts$
        WHERE   t$.obj# = o$.obj# AND
                t$.obj# = tcp$.bo# AND
                tcp$.obj# = tsp$.pobj# AND
                tsp$.ts# = ts$.ts# AND
                o$.owner# != 0 AND
                BITAND(t$.property, 32+64+512+8192) = 32
      UNION ALL                                        /* Unpartitioned IOTs */
        SELECT  0, o$.name, o$.owner#, 0, NVL(t$.bobj#, 0), ts$.name
        FROM    sys.tab$ t$, sys.obj$ o$, sys.ts$ ts$, sys.ind$ i$
        WHERE   t$.obj# = o$.obj# AND
                t$.pctused$ = i$.obj# AND /* For IOTs, pctused has index obj#*/
                i$.ts# = ts$.ts# AND
                o$.owner# != 0 AND
                BITAND(t$.property, 32+64+512+8192) = 64
      UNION ALL                                      /* 1st Partition of IOT */
        SELECT  0, o$.name, o$.owner#, 0, NVL(t$.bobj#, 0), ts$.name
        FROM    sys.tab$ t$, sys.obj$ o$, sys.indpart$ ip$, sys.ts$ ts$
        WHERE   t$.obj# = o$.obj# AND
                t$.pctused$ = ip$.bo# AND
                ip$.ts# = ts$.ts# AND
                o$.owner# != 0 AND
                BITAND(t$.property, 32+64+512+8192) = 32+64
/
GRANT SELECT ON sys.exu9ltts TO SELECT_CATALOG_ROLE;

REM
REM Add support to get n-tier authentication information out of the database.
REM
CREATE OR REPLACE VIEW exu9nta (
                client, proxy, flags, role_clause, cred_type, cred_ver,
                cred_minor) AS
        SELECT  u$.name, up$.name, pd$.flags,
                DECODE(pd$.flags,
                       2, 'WITH NO ROLES',
                       4, 'WITH ROLE',
                       8, 'WITH ROLE ALL EXCEPT', ' '),
                DECODE(pd$.credential_type#,
                       1, 'AUTHENTICATED USING CERTIFICATE',
                       2, 'AUTHENTICATED USING DISTINGUISHED NAME',
                       3, 'AUTHENTICATED USING KERBEROS',
                       4, 'AUTHENTICATED USING PASSWORD', ' '),
                DECODE(pd$.credential_version#,
                       1, DECODE(pd$.credential_type#,
                                 1, 'TYPE ''X.509''',
                                 3, 'VERSION ''1.0''', ' '), ' '),
                DECODE(pd$.credential_minor#,
                       1, DECODE(pd$.credential_type#,
                                 1, 'VERSION ''3''', ' '), ' ')
        FROM    sys.user$ u$, sys.user$ up$, sys.proxy_data$ pd$
        WHERE   pd$.client# = u$.user# AND
                pd$.proxy# = up$.user#
/
GRANT SELECT ON sys.exu9nta TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu9ntarole (
                roleid, role, client, proxy) AS
        SELECT  prd$.role#, ur$.name, uc$.name, up$.name
        FROM    sys.user$ ur$, sys.proxy_role_data$ prd$,
                sys.user$ uc$, sys.user$ up$
        WHERE   prd$.role#   = ur$.user# AND
                prd$.client# = uc$.user# AND
                prd$.proxy#  = up$.user#
/
GRANT SELECT ON sys.exu9ntarole TO SELECT_CATALOG_ROLE;

REM
REM 10iR1 modifications for n-tier authentication
REM
CREATE OR REPLACE VIEW exu10nta (
                client, proxy, flags, role_clause, auth) AS
        SELECT  u$.name, up$.name, pd$.flags,
                DECODE(pd$.flags,
                       2, 'WITH NO ROLES',
                       4, 'WITH ROLE',
                       8, 'WITH ROLE ALL EXCEPT', ' '),
                DECODE(pd$.credential_type#,
                       5, 'AUTHENTICATION REQUIRED', ' ')
        FROM    sys.user$ u$, sys.user$ up$, sys.proxy_info$ pd$
        WHERE   pd$.client# = u$.user# AND
                pd$.proxy# = up$.user#
/
GRANT SELECT ON sys.exu10nta TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW exu10ntarole (
                roleid, role, client, proxy) AS
        SELECT  prd$.role#, ur$.name, uc$.name, up$.name
        FROM    sys.user$ ur$, sys.proxy_role_info$ prd$,
                sys.user$ uc$, sys.user$ up$
        WHERE   prd$.role#   = ur$.user# AND
                prd$.client# = uc$.user# AND
                prd$.proxy#  = up$.user#
/
GRANT SELECT ON sys.exu10ntarole TO SELECT_CATALOG_ROLE;

REM
REM Create a view to get the default settings for the persistent switches.
REM
CREATE OR REPLACE VIEW exu9defpswitches (
                compflgs, nlslensem ) AS
        SELECT  a.value, b.value
        FROM    sys.v$parameter a, sys.v$parameter b
        WHERE   a.name = 'plsql_compiler_flags' AND
                b.name = 'nls_length_semantics'
/
GRANT SELECT ON sys.exu9defpswitches TO PUBLIC;

REM
REM Create a view to get the two persistent sql switches for a given objid
REM
CREATE OR REPLACE VIEW exu9objswitch (
                objid, compflgs, nlslensem ) AS
        SELECT  a.obj#, a.value, b.value
        FROM    sys.settings$ a, sys.settings$ b, sys.obj$ o
        WHERE   o.obj#  = a.obj# AND
                a.obj#  = b.obj# AND
                a.param = 'plsql_compiler_flags' AND
                b.param = 'nls_length_semantics' AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9objswitch TO PUBLIC;

REM
REM Create a view to get the default settings for the persistent switches.
REM 10i version for new plsql optimize level
REM
CREATE OR REPLACE VIEW exu10defpswitches (
                compflgs, nlslensem, optlevel ) AS
        SELECT  a.value, b.value, c.value
        FROM    sys.v$parameter a, sys.v$parameter b, sys.v$parameter c
        WHERE   a.name = 'plsql_compiler_flags' AND
                b.name = 'nls_length_semantics' AND
                c.name = 'plsql_optimize_level'
/
GRANT SELECT ON sys.exu10defpswitches TO PUBLIC;

REM
REM Create a view to get the two persistent sql switches for a given objid
REM 10i version for new plsql optimize level
REM
CREATE OR REPLACE VIEW exu10objswitch (
                objid, compflgs, nlslensem, optlevel ) AS
        SELECT  a.obj#, a.value, b.value, c.value
        FROM    sys.settings$ a, sys.settings$ b, sys.settings$ c, sys.obj$ o
        WHERE   o.obj#  = a.obj# AND
                a.obj#  = b.obj# AND
                b.obj#  = c.obj# AND
                a.param = 'plsql_compiler_flags' AND
                b.param = 'nls_length_semantics' AND
                c.param = 'plsql_optimize_level' AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu10objswitch TO PUBLIC;

REM
REM (These 2 views 'a' versions, exist because PLSQL_COMPILER_FLAGS was 
REM  changed twice during 10i.)
REM Create a view to get the default settings for the persistent switches.
REM 10ia version for new plsql code type
REM
CREATE OR REPLACE VIEW exu10adefpswitches (
                nlslensem, optlevel, codetype, warnings ) AS
        SELECT  a.value, b.value, c.value, d.value
        FROM    sys.v$parameter a, sys.v$parameter b, sys.v$parameter c,
                sys.v$parameter d
        WHERE   a.name = 'nls_length_semantics' AND
                b.name = 'plsql_optimize_level' AND
                c.name = 'plsql_code_type'      AND
                d.name = 'plsql_warnings'
/
GRANT SELECT ON sys.exu10adefpswitches TO PUBLIC;

REM
REM Create a view to get the five persistent sql switches for a given objid
REM 10ia version for new plsql code type & plsql debug
REM
CREATE OR REPLACE VIEW exu10aobjswitch (
                objid, nlslensem, optlevel, codetype, debug, warnings ) AS
        /* normal case - no overrides */
        SELECT  a.obj#, a.value, b.value, c.value, d.value, e.value 
        FROM    sys.settings$ a, sys.settings$ b, sys.settings$ c, 
                sys.settings$ d, sys.settings$ e, sys.obj$ o
        WHERE   o.obj#  = a.obj# AND
                a.obj#  = b.obj# AND
                b.obj#  = c.obj# AND
                c.obj#  = d.obj# AND
                d.obj#  = e.obj# AND
                a.param = 'nls_length_semantics'         AND
                b.param = 'plsql_optimize_level'         AND
                c.param = 'plsql_code_type'              AND
                d.param = 'plsql_debug'                  AND
                e.param = 'plsql_warnings'               AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE')) 
/
GRANT SELECT ON sys.exu10aobjswitch TO PUBLIC;

REM
REM Create a view to get the default settings for the persistent switches.
REM 10R2 version for new plsql_ccflags
REM
CREATE OR REPLACE VIEW exu10r2defpswitches (
                nlslensem, optlevel, codetype, warnings, ccflags ) AS
        SELECT  a.value, b.value, c.value, d.value, e.value
        FROM    sys.v$parameter a, sys.v$parameter b, sys.v$parameter c,
                sys.v$parameter d, sys.v$parameter e
        WHERE   a.name = 'nls_length_semantics' AND
                b.name = 'plsql_optimize_level' AND
                c.name = 'plsql_code_type'      AND
                d.name = 'plsql_warnings'       AND
                e.name = 'plsql_ccflags'
/
GRANT SELECT ON sys.exu10r2defpswitches TO PUBLIC;

REM
REM Create a view to get the six persistent sql switches for a given objid
REM 10R2 version for new plsql_ccflags
REM
CREATE OR REPLACE VIEW exu10r2objswitch (
                objid, nlslensem, optlevel, codetype, debug, warnings, 
                ccflags ) AS
        /* normal case - no overrides */
        SELECT  a.obj#, a.value, b.value, c.value, d.value, e.value , 
                f.value
        FROM    sys.settings$ a, sys.settings$ b, sys.settings$ c, 
                sys.settings$ d, sys.settings$ e, sys.settings$ f,
                sys.obj$ o
        WHERE   o.obj#  = a.obj# AND
                a.obj#  = b.obj# AND
                b.obj#  = c.obj# AND
                c.obj#  = d.obj# AND
                d.obj#  = e.obj# AND
                e.obj#  = f.obj# AND
                a.param = 'nls_length_semantics'         AND
                b.param = 'plsql_optimize_level'         AND
                c.param = 'plsql_code_type'              AND
                d.param = 'plsql_debug'                  AND
                e.param = 'plsql_warnings'               AND
                f.param = 'plsql_ccflags'                AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE')) 
/
GRANT SELECT ON sys.exu10r2objswitch TO PUBLIC;
REM

REM
REM Add support for FGA
REM
REM Get fine grained auditing policies
REM
CREATE OR REPLACE VIEW exu9fga (
                objown, objnam, policy, poltxt, polcol, polown, polpkg, polfun,
                enabled) AS
        SELECT  u.name, o.name, f.pname,
                replace(f.ptxt,'''',''''''),
                f.pcol, f.pfschma, f.ppname,
                f.pfname, f.enable_flag
        FROM    sys.user$ u, sys.obj$ o, sys.fga$ f
        WHERE   u.user# = o.owner# AND
                f.obj# = o.obj# AND
                (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9fga TO PUBLIC;

REM
REM Views for 10iR1 (CDC format) snapshot log
REM
CREATE OR REPLACE VIEW exu10mvl (
                ctobj#, log_owner, log_name, log_ownerid, created_time,
                file_version, using_rowid_flag, using_primarykey_flag,
                using_oid_flag, using_sequence_flag, change_set_name,
                source_schema_name, source_table_name, created_scn,
                mvl_flag, captured_values, mvl_temp_log, mvl_v7trigger,
                last_altered, lowest_scn, mvl_oldest_rid, mvl_oldest_pk,
                mvl_oldest_oid, mvl_oldest_new, mvl_oldest_rid_time,
                mvl_oldest_pk_time, mvl_oldest_oid_time,
                mvl_oldest_new_time, mvl_backcompat_view,
                mvl_physmvl, highest_scn, highest_timestamp,
                mvl_oldest_seq, mvl_oldest_seq_time) AS
        SELECT  ct.obj#, ct.change_table_schema, ct.change_table_name, u.user#,
                ct.created, 7, DECODE(BITAND(ct.mvl_flag, 1), 1, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 2), 2, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 512), 512, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 1024), 1024, 1, 0),
                ct.change_set_name, ct.source_schema_name,
                ct.source_table_name, ct.created_scn, ct.mvl_flag,
                ct.captured_values, ct.mvl_temp_log, ct.mvl_v7trigger,
                ct.last_altered, ct.lowest_scn, ct.mvl_oldest_rid,
                ct.mvl_oldest_pk, ct.mvl_oldest_oid, ct.mvl_oldest_new,
                ct.mvl_oldest_rid_time, ct.mvl_oldest_pk_time,
                ct.mvl_oldest_oid_time, ct.mvl_oldest_new_time,
                ct.mvl_backcompat_view, ct.mvl_physmvl, ct.highest_scn,
                ct.highest_timestamp, ct.mvl_oldest_seq, ct.mvl_oldest_seq_time
        FROM    sys.cdc_change_tables$ ct, sys.user$ u
        WHERE   ct.change_table_schema = u.name AND
                ct.mvl_flag IS NOT NULL AND
                BITAND(ct.mvl_flag, 128) = 128 AND
                (userenv('SCHEMAID') IN (0, u.user#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu10mvl TO PUBLIC;

CREATE OR REPLACE VIEW exu10mvlu AS
        SELECT  *
        FROM    sys.exu10mvl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu10mvlu TO PUBLIC;

REM
REM Adding 9.0 (CDC format) snapshot log support JohnG 06JUL00
REM new (CDC format) MV log views for v9.0
REM
CREATE OR REPLACE VIEW exu9mvl (
                ctobj#, log_owner, log_name, log_ownerid, created_time,
                file_version, using_rowid_flag, using_primarykey_flag,
                using_oid_flag, using_sequence_flag, change_set_name,
                source_schema_name, source_table_name, created_scn,
                mvl_flag, captured_values, mvl_temp_log, mvl_v7trigger,
                last_altered, lowest_scn, mvl_oldest_rid, mvl_oldest_pk,
                mvl_oldest_oid, mvl_oldest_new, mvl_oldest_rid_time,
                mvl_oldest_pk_time, mvl_oldest_oid_time,
                mvl_oldest_new_time, mvl_backcompat_view,
                mvl_physmvl, highest_scn, highest_timestamp) AS
        SELECT  ct.obj#, ct.change_table_schema, ct.change_table_name, u.user#,
                ct.created, 5, DECODE(BITAND(ct.mvl_flag, 1), 1, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 2), 2, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 512), 512, 1, 0),
                DECODE(BITAND(ct.mvl_flag, 1024), 1024, 1, 0),
                ct.change_set_name, ct.source_schema_name,
                ct.source_table_name, ct.created_scn, ct.mvl_flag,
                ct.captured_values, ct.mvl_temp_log, ct.mvl_v7trigger,
                ct.last_altered, ct.lowest_scn, ct.mvl_oldest_rid,
                ct.mvl_oldest_pk, ct.mvl_oldest_oid, ct.mvl_oldest_new,
                ct.mvl_oldest_rid_time, ct.mvl_oldest_pk_time,
                ct.mvl_oldest_oid_time, ct.mvl_oldest_new_time,
                ct.mvl_backcompat_view, ct.mvl_physmvl, ct.highest_scn,
                ct.highest_timestamp
        FROM    sys.cdc_change_tables$ ct, sys.user$ u
        WHERE   ct.change_table_schema = u.name AND
                ct.mvl_flag IS NOT NULL AND
                BITAND(ct.mvl_flag, 128) = 128 AND
                (userenv('SCHEMAID') IN (0, u.user#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9mvl TO PUBLIC;

CREATE OR REPLACE VIEW exu9mvlu AS
        SELECT  *
        FROM    sys.exu9mvl
        WHERE   log_ownerid = userenv('SCHEMAID')
/
GRANT SELECT ON sys.exu9mvlu TO PUBLIC;

CREATE OR REPLACE VIEW exu9mvlcdcs AS
        SELECT  s.set_name, s.username, s.created, s.status, s.earliest_scn,
                s.latest_scn, s.description, s.last_purged, s.last_extended,
                s.mvl_invalid, s.handle
        FROM    sys.cdc_subscribers$ s
        WHERE   s.handle IN (
                    SELECT  t.handle
                    FROM    sys.cdc_subscribed_tables$ t
                    WHERE   t.change_table_obj# IN (
                                SELECT  obj#
                                FROM    sys.cdc_change_tables$ ct, sys.user$ u
                                WHERE   (ct.change_table_schema = u.name AND
                                         u.user# = userenv('SCHEMAID')) OR
                                        userenv('SCHEMAID') = 0 OR
                                        EXISTS (
                                            SELECT  role
                                            FROM    sys.session_roles
                                            WHERE   role =
                                                    'SELECT_CATALOG_ROLE')))
/
GRANT SELECT ON sys.exu9mvlcdcs TO PUBLIC;

CREATE OR REPLACE VIEW exu9mvlcdcst AS
        SELECT  handle, view_name, view_status, mv_flag, mv_colvec,
                change_table_obj#
        FROM    sys.cdc_subscribed_tables$
        WHERE   handle IN (
                    SELECT  t.handle
                    FROM    sys.cdc_subscribed_tables$ t
                    WHERE   t.change_table_obj# IN (
                                SELECT  obj#
                                FROM    sys.cdc_change_tables$ ct, sys.user$ u
                                WHERE   (ct.change_table_schema = u.name AND
                                         u.user# = userenv('SCHEMAID')) OR
                                        userenv('SCHEMAID') = 0 OR
                                        EXISTS (
                                            SELECT  role
                                            FROM    sys.session_roles
                                            WHERE   role =
                                                    'SELECT_CATALOG_ROLE')))
/
GRANT SELECT ON sys.exu9mvlcdcst TO PUBLIC;

CREATE OR REPLACE VIEW exu9mvlcdcsc AS
        SELECT  column_name, handle, change_table_obj#
        FROM    sys.cdc_subscribed_columns$
        WHERE   handle IN (
                    SELECT  t.handle
                    FROM    sys.cdc_subscribed_tables$ t
                    WHERE   t.change_table_obj# IN (
                                SELECT  obj#
                                FROM    sys.cdc_change_tables$ ct, sys.user$ u
                                WHERE   (ct.change_table_schema = u.name AND
                                         u.user# = userenv('SCHEMAID')) OR
                                        userenv('SCHEMAID') = 0 OR
                                        EXISTS (
                                            SELECT  role
                                            FROM    sys.session_roles
                                            WHERE   role =
                                                    'SELECT_CATALOG_ROLE')))
/
GRANT SELECT ON sys.exu9mvlcdcsc TO PUBLIC;

CREATE OR REPLACE VIEW exu9mvlcdccc AS
        SELECT  column_name, created, created_scn, change_table_obj#
        FROM    sys.cdc_change_columns$
        WHERE   change_table_obj# IN (
                    SELECT  obj#
                    FROM    sys.cdc_change_tables$ ct, sys.user$ u
                    WHERE   (userenv('SCHEMAID') = u.user# AND
                             ct.change_table_schema = u.name) OR
                            (userenv('SCHEMAID') = 0 AND
                             ct.change_table_schema = u.name) OR
                            EXISTS (
                                SELECT  role
                                FROM    sys.session_roles
                                WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9mvlcdccc TO PUBLIC;

REM
REM Substitutable and 'is type of' inheritance constraints
REM
CREATE OR REPLACE VIEW exu9inhcolcons
        (tobjid, intcolid, cname, typeflags, subtypeflags,
         typeownerid, typeowner, typename)
    AS SELECT
        ct$.obj#, ct$.intcol#,
        DECODE(BITAND(c$.property,1), 0, '"'||c$.name||'"', 1, ac$.name),
        ct$.flags, NVL(sc$.flags,0),
        NVL(so$.owner#,0), NVL(su$.name,' '), NVL(so$.name,' ')
    FROM
        sys.coltype$ ct$, sys.col$ c$, sys.attrcol$ ac$, sys.subcoltype$ sc$,
        sys.obj$ so$, sys.user$ su$, sys.obj$ to$
    WHERE
        bitand (ct$.flags, (512+1024+2048+4096)) != 0 AND
        ct$.obj# = c$.obj# AND
        ct$.intcol# = c$.intcol# AND
        ct$.obj# = ac$.obj# (+) AND
        ct$.intcol# = ac$.intcol# (+) AND
        ct$.obj# = sc$.obj# (+) AND
        ct$.intcol# = sc$.intcol# (+) AND
        bitand(NVL(sc$.flags,1),1+2) != 0 AND
        sc$.toid = so$.oid$ (+) AND
        so$.owner# = su$.user# (+) AND
        ct$.obj# = to$.obj# AND
        (userenv('SCHEMAID') = 0 OR (userenv('SCHEMAID') = to$.owner#) OR
         EXISTS(SELECT * FROM sys.session_roles WHERE role='SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9inhcolcons TO PUBLIC;


REM end of 9.0 (CDC format) MV log support

REM
REM get eXternal TaBle data
REM
CREATE OR REPLACE VIEW exu9xtb (
                objid, default_dir, type, nr_locations, reject_limit, par_type,
                param_clob, position, directory, name) AS
        SELECT  et$.obj#, et$.default_dir, et$.type$, et$.nr_locations,
                et$.reject_limit, et$.par_type, et$.param_clob,
                el$.position, el$.dir, el$.name
        FROM    sys.external_location$ el$, sys.external_tab$ et$, sys.obj$ o$
        WHERE   el$.obj# = et$.obj# AND
                el$.obj# = o$.obj#  AND
                (userenv('SCHEMAID') IN (o$.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exu9xtb TO PUBLIC;

REM
REM Export view to Get Sort Area Size.
REM
CREATE OR REPLACE VIEW exu9gsas (
                value) AS
        SELECT  value
        FROM    sys.v$parameter
        WHERE   name = 'sort_area_size'
/
GRANT SELECT ON sys.exu9gsas TO PUBLIC;

REM
REM NOT NULL column constraints - only used for object tables
REM
CREATE OR REPLACE VIEW exu9otnnull (tobjid, name, conname, defer) AS
  SELECT  tobjid, name, conname, defer
  FROM    sys.exu8col_temp
  WHERE   isnull = 1 AND
          BITAND(colprop, 32) != 32       /* Not hidden (exploded col/attrs) */
/
GRANT SELECT ON sys.exu9otnnull  TO PUBLIC;

REM
REM View to see if a table is compressed (new for 10i).
REM
CREATE OR REPLACE VIEW sys.expcompressedtab
    (SPARE1, TOBJ$) AS
        SELECT s.spare1, t.obj# 
        FROM   sys.tab$ t, sys.seg$ s
        WHERE  t.ts#    = s.ts#
        AND    t.file#  = s.file#
        AND    t.block# = s.block#
        AND    s.type#  = 5
        AND    (bitand(s.spare1,4096) = 4096 OR bitand(s.spare1,2048) = 2048)
/
GRANT SELECT ON sys.expcompressedtab TO PUBLIC;

REM
REM View to see if a partition is compressed (new for 10i).
REM
CREATE OR REPLACE VIEW sys.expcompressedpart
    (SPARE1, TOBJ$) AS
        SELECT s.spare1, t.obj# 
        FROM   sys.tabpart$ t, sys.seg$ s
        WHERE  t.ts#    = s.ts#
        AND    t.file#  = s.file#
        AND    t.block# = s.block#
        AND    s.type#  = 5
        AND    (bitand(s.spare1,4096) = 4096 OR bitand(s.spare1,2048) = 2048)
/
GRANT SELECT ON sys.expcompressedpart TO PUBLIC;

REM
REM View to see if a subpartition is compressed (new for 10i).
REM
CREATE OR REPLACE VIEW sys.expcompressedsub
    (SPARE1, TOBJ$) AS
        SELECT s.spare1, t.obj# 
        FROM   sys.tabsubpart$ t, sys.seg$ s
        WHERE  t.ts#    = s.ts#
        AND    t.file#  = s.file#
        AND    t.block# = s.block#
        AND    s.type#  = 5
        AND    (bitand(s.spare1,4096) = 4096 OR bitand(s.spare1,2048) = 2048)
/
GRANT SELECT ON sys.expcompressedsub TO PUBLIC;

REM 
REM View to see if USER has EXEMPT ACCESS POLICY privilege.
REM
CREATE OR REPLACE VIEW sys.expexempt
    (COUNT) AS
        SELECT  COUNT(*) 
        FROM    sys.sysauth$
        WHERE   (privilege# = 
                        (SELECT privilege
                         FROM   sys.system_privilege_map
                         WHERE  name = 'EXEMPT ACCESS POLICY'))
        AND     grantee# = userenv('SCHEMAID')   /* user directly has priv */
        OR      (grantee# = userenv('SCHEMAID')   /* user has role with priv */
                        AND privilege# > 0  
                        AND privilege# IN 
                                (SELECT u1.privilege# 
                                 FROM sys.sysauth$ u1, sys.sysauth$ u2 
                                 WHERE u1.grantee# = userenv('SCHEMAID')
                                 AND u1.privilege# = u2.grantee# 
                                 AND u2.privilege# = 
                                      (SELECT privilege
                                       FROM   sys.system_privilege_map
                                       WHERE  name = 'EXEMPT ACCESS POLICY')))
/
GRANT SELECT ON sys.expexempt TO PUBLIC;

REM
REM The following four views are used to determine if a partitions's subpartition
REM were created using the table's partition template.  They are referenced by a 
REM PL/SQL function in prvtpexp.

CREATE OR REPLACE VIEW sys.exptabsubpart AS
        SELECT 
              tsp.obj#                                                 OBJNO, 
              tsp.pobj#                                                POBJNO,
              row_number() OVER 
                   (partition by tsp.pobj# order by tsp.subpart#) - 1  SUBPARTNO,
              bhiboundval                                              BHIBOUNDVAL, 
              ts#                                                      TSNO
        FROM sys.tabsubpart$ tsp
/
GRANT SELECT ON sys.exptabsubpart TO PUBLIC;

CREATE OR REPLACE VIEW sys.exptabsubpartdata_view AS
        SELECT 
              sp.bhiboundval       SPBND, 
              dsp.bhiboundval      DSPBND, 
              p.obj#               PONO, 
              sp.tsno              SPTS,
              dsp.ts#              DSPTS, 
              p.defts#             PDEFTS, 
              tpo.defts#           TDEFTS, 
              u.datats#            UDEFTS
        FROM sys.tabcompart$ p, sys.partobj$ tpo, sys.exptabsubpart sp,
             sys.defsubpart$ dsp, sys.obj$ po, sys.obj$ spo, sys.user$ u
        WHERE
             p.bo# = tpo.obj# AND
             p.subpartcnt = MOD(TRUNC(tpo.spare2/65536), 65536) AND
             sp.pobjno = p.obj# AND
             po.obj# = p.obj# AND
             spo.obj# = sp.objno AND
             sp.subpartno = dsp.spart_position AND
             dsp.bo# = p.bo# AND
             u.user# = po.owner# and
             (spo.subname = (po.subname || '_' || dsp.spart_name) OR
                            (po.subname LIKE 'SYS_P%' AND 
                             spo.subname LIKE 'SYS_SUBP%'))
/

GRANT SELECT ON sys.exptabsubpartdata_view TO PUBLIC;

REM
REM We need to see if a subpartition has lob fragments 
REM

CREATE OR REPLACE VIEW exptabsubpartlobfrag AS
        SELECT 
              lf.parentobj#                                         PARENTOBJNO, 
              lf.ts#                                                TSNO, 
              lf.fragobj#                                           FRAGOBJNO, 
              row_number() OVER 
                 (partition by lf.parentobj# order by lf.frag#) - 1 FRAGNO,
              lf.tabfragobj#                                        TABFRAGOBJNO
        FROM sys.lobfrag$ lf
/
GRANT SELECT ON sys.exptabsubpartlobfrag TO PUBLIC;

CREATE OR REPLACE VIEW sys.exptabsubpartlob_view AS
        SELECT 
              tp.obj#            PONO,
              lp.defts#          LPDEFTS, 
              lf.tsno            LFTS, 
              lb.defts#          LCDEFTS,
              dsp.lob_spart_ts#  LSPDEFTS, 
              tsp.ts#            SPTS
        FROM  sys.tabcompart$ tp, sys.lobcomppart$ lp, sys.partlob$ lb, 
              sys.exptabsubpartlobfrag lf, sys.defsubpartlob$ dsp, 
              sys.obj$ lspo, sys.obj$ tpo, sys.tabsubpart$ tsp
        WHERE 
              lp.tabpartobj# = tp.obj# AND
              lp.lobj# = lb.lobj# and
              lf.parentobjno = lp.partobj# AND
              dsp.bo# = tp.bo# and
              dsp.intcol# = lb.intcol# AND
              lspo.obj# = lf.fragobjno AND
              tpo.obj# = tp.obj# AND
              (lspo.subname = tpo.subname || '_' || dsp.lob_spart_name OR
               (tpo.subname LIKE 'SYS_P%' AND lspo.subname LIKE 'SYS_LOB_SUBP%')) AND
              dsp.spart_position = lf.fragno AND 
              tsp.obj# = lf.tabfragobjno
     UNION ALL
        SELECT tp.obj#           PONO, 
               lp.defts#         LPDEFTS, 
               lf.tsno           LFTS, 
               lb.defts#         LCDEFTS,
                                 NULL, 
               tsp.ts#           SPTS
        FROM sys.tabcompart$ tp, sys.lobcomppart$ lp, sys.partlob$ lb, 
             sys.exptabsubpartlobfrag lf, sys.obj$ lspo, sys.obj$ tpo, 
             sys.tabsubpart$ tsp
        WHERE lp.tabpartobj# = tp.obj# AND
              lp.lobj# = lb.lobj# AND
              lf.parentobjno = lp.partobj# AND
              lb.intcol# NOT IN 
                (SELECT distinct dsp.intcol#
                  FROM sys.defsubpartlob$ dsp 
                  WHERE dsp.bo# = tp.bo#) AND
              lspo.obj# = lf.fragobjno AND
              tpo.obj# = tp.obj# AND
              lspo.subname LIKE 'SYS_LOB_SUBP%' AND
              tsp.obj# = lf.tabfragobjno;
/
GRANT SELECT ON sys.exptabsubpartlob_view TO PUBLIC;

CREATE OR REPLACE VIEW sys.expgetenccolnam AS
        SELECT c.name, c.obj# 
        FROM   sys.col$ c, sys.obj$ o
        WHERE  bitand(c.property,67108864) = 67108864 AND /* encrypted column */
               c.obj#  = o.obj#                       AND
               (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.expgetenccolnam TO PUBLIC;

REM
REM View to get MAPPING table info for a NON-partitioned IOT (new for 10.2.2).
REM New for 10.2
REM
CREATE OR REPLACE VIEW sys.expmapiot
          (obj, dobj, ts, fileno, block, initextnt, 
           freelists, 
           groups, 
           pool, 
           tsname, logging, 
           pctfree$, 
           pctused$, 
           initrans, maxtrans ) AS
        SELECT t.obj#, t.dataobj#, t.ts#, t.file#, t.block#, s.iniexts, 
               NVL(s.lists,0),
               NVL(s.groups,0),
               DECODE(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
               ts.name, ts.dflogging, 
               MOD(t.pctfree$, 100), 
               t.pctused$, 
               t.initrans, t.maxtrans
        FROM   sys.tab$ t, sys.seg$ s, sys.ts$ ts, sys.obj$ o
        WHERE  t.ts#    = s.ts#
        AND    t.file#  = s.file#
        AND    t.block# = s.block#
        AND    s.type#  = 5
        AND    ts.ts#   = t.ts#
        AND    t.obj#   = o.obj#
        AND    (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.expmapiot TO PUBLIC;

REM
REM View to get the obj# of the mapping table of a Partitioned IOT.
REM New for 10.2
REM
CREATE OR REPLACE VIEW sys.expgetmapobj
          (mapobj, iotobj) AS
        SELECT  t.pctfree$, t.obj# 
        FROM    sys.tab$ t, sys.obj$ o
        WHERE   t.obj# = o.obj#
        AND     (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.expgetmapobj TO PUBLIC;

REM
REM View to get MAPPING table info for a partitioned IOT (new for 10.2.2).
REM
CREATE OR REPLACE VIEW sys.exppiotmap
          (obj, dobj, ts, fileno, block, 
           initextnt, 
           freelists, groups, 
           pool, 
           bo, partno, tsname, logging, 
           pctfree$, 
           pctused$, initrans, maxtrans,
           blocksize)  AS
        SELECT t.obj#, t.dataobj#, t.ts#, t.file#, t.block#, 
               NVL(po.deftiniexts, 0),
               po.deflists, po.defgroups,
               DECODE(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'), 
               t.bo#, t.part#, ts.name, po.deflogging, 
               MOD(po.defpctfree, 100), 
               po.defpctused, t.initrans, t.maxtrans, 
               NVL(ts.blocksize, 2048)   /* non null for table/indexes */
        FROM   sys.tabpart$ t, sys.partobj$ po, sys.ts$ ts, sys.obj$ o
        WHERE  ts.ts#   = t.ts#
        AND    t.bo#    = po.obj#
        AND    t.bo#    = o.obj#
        AND    (userenv('SCHEMAID') IN (o.owner#, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.exppiotmap TO PUBLIC;

Rem
Rem View to get XSL delimiter string (new for 11).
Rem
CREATE OR REPLACE VIEW sys.expxsldelim
          ( xsldelimiter ) AS
        SELECT SUBSTR(DEFAULT_VAL,2,4)  
        FROM SYS.METAXSLPARAM$ 
        WHERE MODEL = 'ORACLE' AND TRANSFORM = 'PARSE' AND PARAM = 'PRS_DELIM'
/
GRANT SELECT ON sys.expxsldelim TO PUBLIC;
/

REM
REM Add versioning support for export. This will get bumped up as the views
REM evolve. The insert is needed for upgrades from 7.0 or new databases. The
REM update is needed for databases that have older compatibility. These are
REM the releases when the compatibility was bumped:
REM
REM    7.0.* - no compatibility - assume zero
REM    7.1.3 - set to one
REM    7.2.1 - set to two
REM    7.2.3 - set to three
REM    8.0.1 - set to four
REM    8.0.2 - set to five
REM    8.0.3 - set to six
REM    8.0.4 - set to seven
REM    8.1.6 - set to eight
REM
INSERT INTO props$
        SELECT  'EXPORT_VIEWS_VERSION', '8', 'Export views revision #'
        FROM    sys.dual
        WHERE   NOT EXISTS (
                    SELECT  'x'
                    FROM    sys.props$
                    WHERE   name = 'EXPORT_VIEWS_VERSION')
/
UPDATE props$ SET value$ = 8 WHERE name = 'EXPORT_VIEWS_VERSION'
/
COMMIT
/

REM
REM Exclude the system.help table from export
REM but avoid duplicates upon multiple runs of catexp.sql
REM
insert into noexp$
    select 'SYSTEM', 'HELP', 2 from sys.dual
    where not exists (
       select 'x'
       from   sys.noexp$
       where name  = 'HELP' AND
                 owner = 'SYSTEM' )
/
COMMIT
/
