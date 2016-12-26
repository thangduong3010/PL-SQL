Rem
Rem $Header: rdbms/admin/xdbe112.sql /st_rdbms_11.2.0/8 2011/07/31 10:32:40 juding Exp $
Rem
Rem xdbe112.sql
Rem
Rem Copyright (c) 2010, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbe112.sql - XDB downgrade to 11.2.0
Rem
Rem    DESCRIPTION
Rem      This script performs the downgrade actions to downgrade the
Rem      current release to 11.2.0.  It is invoked by cmpdbdwg.sql and
Rem      xdbe111.sql
Rem
Rem    NOTES
Rem      In 11.2.0.x, performs patch downgrades
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srirkris    07/11/11 - Backport srirkris_bug-12680386 from main
Rem    hxzhang     07/14/11 - split into xdbeu112, xdbes112, xdbeo112
Rem    juding      06/09/11 - bug 12622803: check previous_version
Rem    spetride    06/14/11 - Backport spetride_bug-12562859 from
Rem                           st_rdbms_11.2.0
Rem    spetride    05/11/11 - further downgrade for XDB Repository exp/imp
Rem    juding      04/08/11 - Backport juding_bug11071061u from main
Rem    juding      02/09/11 - Backport juding_bug-11070995 from main
Rem    spetride    02/07/11 - downgrade for XDB Repository export/import
Rem    badeoti     08/21/10 - add schema changes during patch upgrade/downgrade
Rem    badeoti     03/09/10 - XDB downgrade to 11.2.0
Rem    badeoti     03/09/10 - Created
Rem

Rem ================================================================
Rem BEGIN XDB downgrade to 12.1.0
Rem ================================================================

-- @@xdbe121.sql

Rem ================================================================
Rem END XDB downgrade to 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XS downgrade to 11.2.0
Rem ================================================================

--@@xse112.sql

Rem ================================================================
Rem END XS downgrade to 11.2.0 
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade to 11.2.0
Rem ================================================================
      
EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

Rem Downgrade XDB User data
@@xdbeu112.sql

Rem Downgrade XDB Schemas
@@xdbes112.sql

Rem Downgrade XDB objects
@@xdbeo112.sql


Rem ================================================================
Rem END XDB downgrade to 11.2.0
Rem ================================================================

EXECUTE dbms_registry.downgraded('XDB','11.2.0');
