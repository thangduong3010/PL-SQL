Rem
Rem $Header: rmaqjms.sql 30-may-00.17:34:52 bnainani Exp $
Rem
Rem rmaqjms.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      rmaqjms.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bnainani    05/30/00 - Script to remove jms classes during downgrade
Rem    bnainani    05/30/00 - Created
Rem
call sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
call sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');


