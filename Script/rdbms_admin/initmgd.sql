Rem
Rem $Header: rdbms/admin/initmgd.sql /main/3 2010/06/09 08:08:44 hgong Exp $
Rem
Rem initmgd.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      initmgd.sql - load mgd java components
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       06/12/06 - Created
Rem

call sys.dbms_java.loadjava('-resolve -force -synonym -schema MGDSYS -grant PUBLIC rdbms/jlib/mgd_idcode.jar');

