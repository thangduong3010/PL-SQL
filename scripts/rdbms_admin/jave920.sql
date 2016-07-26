Rem
Rem $Header: jave920.sql 17-may-2004.13:03:38 rburns Exp $
Rem
Rem jave920.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      jave920.sql - Downgrade catJAVa to 9.2
Rem
Rem    DESCRIPTION
Rem      Downgrade the current release to 9.2
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/09/04 - Created
Rem

Rem downgrade the current release to 10.1
@@jave101

Rem BEGIN drop Java classes for new 10.1.0 features 

execute dbms_registry.downgrading('CATJAVA');

--    Drop AQJMS
execute sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
execute sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');

--    Drop CDC classes
execute sys.dbms_java.dropjava('-s rdbms/jlib/CDC.jar');

--    Drop XSU classes
execute sys.dbms_java.dropjava('-s rdbms/jlib/xdb.jar');

execute  dbms_registry.downgraded('CATJAVA','9.2.0');
