Rem
Rem $Header: rdbms/admin/jave102.sql /main/3 2009/02/16 15:43:40 cdilling Exp $
Rem
Rem jave101.sql
Rem
Rem Copyright (c) 2004, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      jave102.sql - downgrade catJAVa to 10.2
Rem
Rem    DESCRIPTION
Rem      Downgrade CATJAVA from current release to 10.2
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling      02/06/09 - invoke jave111.sql
Rem    qialiu        11/30/06 - drop ojms packages
Rem    cdilling      11/09/05 - Created
Rem

Rem Downgrade from current release to 11g
@@jave111

execute dbms_registry.downgrading('CATJAVA');

Rem Add CATJAVA downgrade actions here

Rem downgrade and remove XQuery jar files/packages.
drop package sys.dbms_xqueryint;

Rem drop OJMS jar files
execute sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
execute sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');


execute dbms_registry.downgraded('CATJAVA','10.2.0');


