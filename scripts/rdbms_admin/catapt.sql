Rem
Rem $Header: rdbms/admin/catapt.sql /main/3 2009/07/01 21:38:43 kkunchit Exp $
Rem
Rem catapt.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catapt.sql - Archive Provider types
Rem
Rem    DESCRIPTION
Rem      creates public types for dbms_archive_provider
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amullick    02/27/09 - fix bug8291480 - remove unnecessary types
Rem    amullick    01/27/09 - Created
Rem

create or replace type dbms_dbfs_hs_item_t
    authid definer
as object (
    storename  varchar2(32),
    storeowner varchar2(32),
    path        varchar2(1024),
    contentfilename   varchar2(1024)
);
/
show errors;

create or replace public synonym dbms_dbfs_hs_item_t
    for sys.dbms_dbfs_hs_item_t;

create or replace type dbms_dbfs_hs_litems_t
    as table of dbms_dbfs_hs_item_t;
/
show errors;

create or replace public synonym dbms_dbfs_hs_litems_t
    for sys.dbms_dbfs_hs_litems_t;
