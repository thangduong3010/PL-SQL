Rem
Rem $Header: rdbms/admin/xdbinstd.sql /main/3 2009/04/06 20:28:12 badeoti Exp $
Rem
Rem xdbinstd.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbinstd.sql - Execute all XDB Digest Authentication Setup here
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     03/19/09 - dbms_xdb_admin.createnoncekey moved to dbms_xdbz
Rem    petam       01/19/05 - create table to store nonce key 
Rem    petam       01/19/05 - Created
Rem

CREATE TABLE XDB.XDB$NONCEKEY(nonceKey CHAR(32));

--need to comment this out when the Digest project goes in
exec dbms_xdbz.CreateNonceKey()
