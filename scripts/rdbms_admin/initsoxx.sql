Rem
Rem $Header: initsoxx.sql 21-aug-2003.16:24:10 ayoaz Exp $
Rem
Rem initsoxx.sql
Rem
Rem Copyright (c) 1999, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      initsoxx.sql - loads sql, objects, extensibility and xml related java
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      script must be run as SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayoaz       08/21/03 - change to pl/sql block
Rem    rshaikh     11/01/99 - script to load ODCI and CartridgeServices jars
Rem    rshaikh     11/01/99 - Created
Rem

begin
  sys.dbms_java.loadjava('-f -r rdbms/jlib/CartridgeServices.jar');
  sys.dbms_java.loadjava('-v -s -g public rdbms/jlib/CartridgeServices.jar');
  sys.dbms_java.loadjava('-f -r rdbms/jlib/ODCI.jar');
  sys.dbms_java.loadjava('-v -s -g public rdbms/jlib/ODCI.jar');
end;
/ 

