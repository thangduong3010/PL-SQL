Rem
Rem $Header: rdbms/admin/catnojav.sql /main/6 2009/02/20 03:15:05 ssonawan Exp $
Rem
Rem catnojav.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnojav.sql - CATalog NO JAVa classes for RDBMS
Rem
Rem    DESCRIPTION
Rem      This script removes the RDBMS Java classes and system 
Rem      triggers created by the CATJAVA.SQL script.
Rem
Rem    NOTES
Rem      Must be run AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssonawan    02/13/09 - Bug 6736417: Don't drop appctx package
Rem    rgmani      04/04/08 - Drop Scheduler java code
Rem    gssmith     02/12/07 - Remove Summary Advisor java
Rem    kmuthiah    02/23/05 - rm 'dropjava xquery.jar' 
Rem    mkrishna    11/16/04 - remove XQuery jar files 
Rem    rburns      07/16/02 - rburns_bug-2415848_main
Rem    rburns      06/13/02 - Created
Rem

Rem =====================================================================
Rem Check CATJAVA and JAVAVM status; conditionally abort the script
Rem =====================================================================

WHENEVER SQLERROR EXIT;

BEGIN
   IF dbms_registry.status('CATJAVA') IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,
           'CATJAVA has not been loaded into the database.');   
   END IF;
   IF dbms_registry.is_loaded('JAVAVM') != 1 THEN
      RAISE_APPLICATION_ERROR(-20000,
           'JServer is not operational in the database; ' ||
           'JServer is required to remove CATJAVA from the database.');   
   END IF;
END;
/

WHENEVER SQLERROR CONTINUE;

EXECUTE dbms_registry.removing('CATJAVA');

Rem =====================================================================
Rem Change Data Capture (initcdc.sql)
Rem =====================================================================

@@rmcdc.sql

Rem =====================================================================
Rem SQLJTYPE (initsjty.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/sqljtype.jar');

Rem =====================================================================
Rem AQ JMS (initjms.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');

Rem =====================================================================
Rem ODCI and Cartridge Services (initsoxx.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/CartridgeServices.jar');
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/ODCI.jar');

Rem =====================================================================
Rem Scheduler Java Code (initscfw.sql)
Rem =====================================================================

DROP JAVA SOURCE "schedFileWatcherJava";
DROP JAVA SOURCE "dbFWTrace";
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/schagent.jar');

Rem =====================================================================
Rem Set CATJAVA status
Rem =====================================================================

EXECUTE dbms_registry.removed('CATJAVA');

Rem *********************************************************************
/*
 END CATNOJAV.SQL */
Rem *********************************************************************



