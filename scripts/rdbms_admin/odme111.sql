Rem
Rem $Header: rdbms/admin/odme111.sql /main/1 2009/02/06 14:26:04 xbarr Exp $
Rem
Rem odme111.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      odme111.sql - Data Mining 11.2 downgrade script
Rem
Rem    DESCRIPTION
Rem      This script to be run as part of rdbms downgrade from 11.2 
Rem      to 11.1 release
Rem
Rem    NOTES
Rem      This script must be run as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr       02/04/09 - Created
Rem
Rem
ALTER SESSION SET CURRENT_SCHEMA = "SYS";

exec sys.dbms_registry.downgrading('ODM');

update sys.registry$ set vproc='NULL' where cid='ODM' and cname='Oracle Data Mining';

exec sys.dbms_registry.downgraded('ODM','11.1.0');
/

commit;


