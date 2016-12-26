Rem
Rem $Header: mgdsys.sql 05-feb-2007.11:22:03 hgong Exp $
Rem
Rem mgdsys.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      mgdsys.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Create mgdsys schema and grant appropriate priviledges
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       02/05/07 - grant permissions for 
Rem                           javax.management.MBeanServerPermission
Rem                           and javax.management.MBeanPermission to MGDSYS
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       05/22/06 - grant java logging permission 
Rem    hgong       05/15/06 - clean up script 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create system user 
Rem    hgong       03/31/06 - Created
Rem

prompt .. Creating MGDSYS schema

create user MGDSYS identified by MGDSYS;

prompt .. Granting permissions to MGDSYS 

GRANT RESOURCE TO MGDSYS;

call dbms_java.grant_permission('MGDSYS', 'SYS:java.net.SocketPermission','*', 'connect, resolve');
call dbms_java.grant_permission('MGDSYS', 'SYS:java.util.PropertyPermission', '*', 'read,write' );
call dbms_java.grant_permission('MGDSYS', 'SYS:java.io.FilePermission', 'rdbms/jlib/mgd_idcode.jar', 'read' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:java.util.logging.LoggingPermission', 'control', '' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:javax.management.MBeanServerPermission', 'createMBeanServer', '' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:javax.management.MBeanPermission', 'oracle.jdbc.driver.OracleLog#-[com.oracle.jdbc:type=diagnosability]', 'registerMBean' );
