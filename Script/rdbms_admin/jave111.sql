Rem
Rem $Header: rdbms/admin/jave111.sql /main/1 2009/02/16 15:43:40 cdilling Exp $
Rem
Rem jave111.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      jave111.sql - downgrade catJAVa to 11.1
Rem
Rem    DESCRIPTION
Rem      Downgrade CATJAVA from current release to 11.1
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling      02/06/09 - Created
Rem

Rem Downgrade CATJAVA from 11.2 to 11.1
Rem @@jave112

execute dbms_registry.downgrading('CATJAVA');

Rem Add CATJAVA downgrade actions here

execute dbms_registry.downgraded('CATJAVA','11.1.0');


