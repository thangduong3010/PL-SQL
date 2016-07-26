Rem
Rem $Header: utlrp.sql 24-jul-2003.10:06:51 gviswana Exp $ 
Rem
Rem utlrp.sql
Rem
Rem Copyright (c) 1998, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlrp.sql - Recompile invalid objects
Rem
Rem    DESCRIPTION
Rem     This script recompiles invalid objects in the database.
Rem
Rem     When run as one of the last steps during upgrade or downgrade,
Rem     this script will validate all remaining invalid objects. It will
Rem     also run a component validation procedure for each component in
Rem     the database. See the README notes for your current release and
Rem     the Oracle Database Upgrade book for more information about
Rem     using utlrp.sql   
Rem
Rem     Although invalid objects are automatically re-validated when used,
Rem     it is useful to run this script after an upgrade or downgrade and
Rem     after applying a patch. This minimizes latencies caused by
Rem     on-demand recompilation. Oracle strongly recommends running this
Rem     script after upgrades, downgrades and patches.
Rem
Rem   NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    gviswana    06/26/03 - Switch default to parallel if appropriate
Rem    gviswana    06/12/03 - Switch default back to serial
Rem    gviswana    05/20/03 - 2814808: Automatic parallelism tuning
Rem    rburns      04/28/03 - timestamps and serveroutput for diagnostics
Rem    gviswana    04/13/03 - utlrcmp.sql load -> catproc
Rem    gviswana    06/25/02 - Add documentation
Rem    gviswana    11/12/01 - Use utl_recomp.recomp_serial
Rem    rdecker     11/09/01 - ADD ALTER library support FOR bug 1952368
Rem    rburns      11/12/01 - validate all components after compiles
Rem    rburns      11/06/01 - fix invalid CATPROC call
Rem    rburns      09/29/01 - use 9.2.0
Rem    rburns      09/20/01 - add check for CATPROC valid
Rem    rburns      07/06/01 - get version from instance view
Rem    rburns      05/09/01 - fix for use with 8.1.x
Rem    arithikr    04/17/01 - 1703753: recompile object type# 29,32,33
Rem    skabraha    09/25/00 - validate is now a keyword
Rem    kosinski    06/14/00 - Persistent parameters
Rem    skabraha    06/05/00 - validate tables also
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     09/22/99 - quote name for recompile
Rem    ncramesh    08/04/98 - change for sqlplus
Rem    usundara    06/03/98 - merge from 8.0.5
Rem    usundara    04/29/98 - creation (split from utlirp.sql).
Rem                           Mark Ramacher (mramache) was the original
Rem                           author of this script.
Rem

Rem ===========================================================================
Rem BEGIN utlrp.sql
Rem ===========================================================================

@@utlprp.sql 0

Rem ===========================================================================
Rem END utlrp.sql
Rem ===========================================================================
