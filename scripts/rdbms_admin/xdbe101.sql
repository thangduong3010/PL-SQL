Rem
Rem $Header: xdbe101.sql 11-nov-2007.12:57:25 rburns Exp $
Rem
Rem xdbe101.sql
Rem
Rem Copyright (c) 2004, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbe101.sql - downgrade to the 10.1 release
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      11/11/07 - downgrade XS from later releases
Rem    rburns      11/05/07 - 11.1 xdb downgrade
Rem    pthornto    10/09/06 - add call to zxse102.sql for XS downgrade
Rem    mrafiq      06/19/06 - call xdbuuc4 instead of xdbuuc 
Rem    spannala    09/27/04 - calling xdbeall.sql 
Rem    spannala    08/23/04 - factoring 10.1 downgrade out into another file 
Rem    thbaby      07/28/04 - update sequence model in the resource too 
Rem    abagrawa    06/28/04 - Fix downgrade_resource_schema 
Rem    spannala    05/11/04 - set the status correctly at the end
Rem    spannala    05/10/04 - remove http2-listener 
Rem    thbaby      04/26/04 - Merge transaction thbaby_https
Rem    thbaby      04/21/04 - Created
Rem

Rem ================================================================
Rem BEGIN XS downgrade to 10.1.0 
Rem ================================================================

-- no xse101.sql script, so invoke xse102.sql downgrade XS
@@xse102.sql

Rem ================================================================
Rem END XS downgrade to 10.1.0 
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade to 10.1
Rem ================================================================

call dbms_registry.downgrading('XDB');

-- Load utility functions
@@xdbuuc4.sql

-- call common downgrade
@@xdbeall.sql

-- downgrade user data
@@xdbeu101.sql

-- downgrade schema
@@xdbes101.sql

-- downgrade objects
@@xdbeo101.sql

-- remove utility functions
@@xdbuud.sql

execute dbms_registry.downgraded('XDB', '10.1.0');

Rem ================================================================
Rem END XDB downgrade to 10.1
Rem ================================================================
