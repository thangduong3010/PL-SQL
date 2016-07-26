Rem
Rem $Header: rmaqhp.sql 01-may-2001.11:38:47 nbhatt Exp $
Rem
Rem rmaqhp.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      rmaqhp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nbhatt         05/01/01 - remove echo
Rem    rbhyrava       03/30/01 - Merged rbhyrava_http_prop_jms
Rem    rbhyrava       02/12/01 - Created
Rem

call sys.dbms_java.dropjava('-s rdbms/jlib/aqprop.jar');
