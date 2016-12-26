Rem
Rem $Header: xdbeall.sql 05-oct-2004.18:43:05 spannala Exp $
Rem
Rem xdbeall.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbeall.sql - common downgrade actions before every downgrade
Rem
Rem    DESCRIPTION
Rem      There are some actions which need to be done before every downgrade,
Rem      just like every actions before upgrade. These actions are done by
Rem      xdbdbmig.sql in upgrade and xdbeall.sql in downgrade.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    10/05/04 - spannala_bug-3897563
Rem    spannala    09/27/04 - Created
Rem

-- drop the functional index on resource table. Fix for LRG#1739351
disassociate statistics from indextypes xdb.xdbhi_idxtyp force;
disassociate statistics from packages xdb.xdb_funcimpl force;
drop index xdb.xdbhi_idx;
