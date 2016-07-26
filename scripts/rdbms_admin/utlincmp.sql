Rem
Rem $Header: utlincmp.sql 15-mar-2002.14:58:17 yuli Exp $
Rem
Rem utlincmp.sql
Rem
Rem Copyright (c) 1998, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlincmp.sql - UTiLity script to check for INCoMPatible 
Rem                      objects in the database before a downgrade
Rem
Rem    DESCRIPTION
Rem      This script used to contain a set of quieries that identify database
Rem      objects that are incompatible with previous releases. This script
Rem      has been obsoleted since Oracle 10i. Starting from Oracle 10i, 
Rem      ALTER DATABASE RESET COMPATIBILITY command has been removed hence 
Rem      the compatibility setting of the database is irreversible. Please
Rem      refer to "Oracle 10i Database Migration" book for more details.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuli        03/15/02 - 10i irreversible compatibility
Rem    jdavison    04/19/02 - Allow KUPC types with UDC.
Rem    yzhu        02/04/02 - Compatibility for code point semantics/nchar
Rem                           for object.
Rem    amanikut    01/29/02 - user defined constructor incompat check
Rem    ayoaz       01/28/02 - add incompat check for type synonyms
Rem    tbgraves    01/14/02 - remove 8i incompatibilities for 9.2.0 release
Rem    tbgraves    12/21/01 - new comment format
Rem    weiwang     12/11/01 - print out incompatible rules engine objects
Rem    clei        12/06/01 - Instructions to remove 9.2 Synonym policies
Rem    smuthuli    12/07/01 - locally managed SYSTEM Tablespace
Rem    bemeng      12/06/01 - compatibility check for LOBs in bitmap segments
Rem    slawande    11/26/01 - Instructions for removing 9.2 union all mvs..
Rem    attran      11/21/01 - List PIOT
Rem    alakshmi    11/09/01 - 9.2 Streams objects
Rem    dpotapov    11/14/01 - Heap segment block compression.
Rem    mkrishna    11/16/01 - add compat for xmltype schema based storage
Rem    sichandr    11/20/01 - compatibility for varray table store
Rem    weiwang     11/05/01 - add rules engine feature
Rem    sbasu       11/05/01 - Range/List, default partition and subpartition
Rem                           template compatibility
Rem    twtong      10/23/01 - instructions of removing 9.2 MV
Rem    vmarwah     10/09/01 - LOB Retention compatibility
Rem    rburns      09/03/01 - add 9iRel2 framework
Rem    jgalanes    05/04/01 - add support logic for 9.0 features.
Rem    rburns      05/02/01 - fix nchar and nft queries
Rem    rburns      04/20/01 - add more queries
Rem    rburns      04/19/01 - fix NCHAR queries
Rem    rburns      04/11/01 - add NCHAR query
Rem    rburns      03/27/01 - update for 9i compatibility types
Rem    abrumm      01/09/01 - check for external tables
Rem    abrumm      01/08/01 - check for directores with write privilege
Rem    yhu         10/17/00 - add support for warning table
Rem    gtarora     12/05/00 - non-final and subtype columns compatibility
Rem    jdavison    07/25/00 - Add checking for opaque types.
Rem    dpotapov    06/28/00 - PDML ITL.
Rem    spsundar    06/22/00 - allow odci_secobj$ temp table
Rem    jdavison    05/02/00 - Ignore DBMS_SQL in urowid argument check
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     08/11/99 - bug 897520: match statements with mig manual
Rem    rshaikh     12/28/98 - add more compat checks
Rem    rshaikh     11/17/98 - add all incompatibility checks here
Rem    kmuthiah    10/15/98 - compatibility query for udrefs and sgrefs with rc
Rem    smuralid    07/13/98 - Created

