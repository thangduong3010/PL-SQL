Rem
Rem $Header: rdbms/admin/dbmsxuducu.sql /main/1 2010/02/23 23:47:22 badeoti Exp $
Rem
Rem dbmsxuducu.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxuducu.sql - XDB Upgrade/Downgrade Utilities Clean Up
Rem
Rem    DESCRIPTION
Rem      Cleanup XDB up/down utilities
Rem
Rem    NOTES
Rem      Run at the end of xdbdbmig.sql and at end of latest xdboNNN.sql script
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     12/15/09 - clean up private upgrade/downgrade utilities
Rem    badeoti     12/15/09 - Created
Rem

DROP PUBLIC SYNONYM dbms_xdbmig_util;
DROP PACKAGE xdb.dbms_xdbmig_util;

