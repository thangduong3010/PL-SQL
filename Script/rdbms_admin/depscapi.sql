Rem
Rem $Header: rdbms/admin/depscapi.sql /main/2 2009/07/01 21:38:41 kkunchit Exp $
Rem
Rem depscapi.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      depscapi.sql - DBFS content/property views
Rem
Rem    DESCRIPTION
Rem      DBFS content/property views
Rem
Rem    NOTES
Rem      Definition of "dbfs_content" and "dbfs_content_properties"
Rem      based on table functions in "dbms_dbfs_content".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkunchit    01/15/09 - Created
Rem



/* ---------------------- content and property views ----------------------- */

create or replace view dbfs_content
    as
    select * from table(dbms_dbfs_content.listAllContent);

create or replace public synonym dbfs_content
    for sys.dbfs_content;

grant select on dbfs_content
    to dbfs_role;


create or replace view dbfs_content_properties
    as
    select * from table(dbms_dbfs_content.listAllProperties);

create or replace public synonym dbfs_content_properties
    for sys.dbfs_content_properties;

grant select on dbfs_content_properties
    to dbfs_role;



