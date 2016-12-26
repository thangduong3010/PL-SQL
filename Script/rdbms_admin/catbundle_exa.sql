Rem
Rem $Header: rdbms/admin/catbundle_exa.sql /st_rdbms_11.2.0/1 2013/04/08 09:59:24 surman Exp $
Rem
Rem catbundle_exa.sql
Rem
Rem Copyright (c) 2013, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catbundle_exa.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     11/06/12 - Add Exadata Bundle support
Rem    jerrede     11/06/12 - Created

Rem Call catbundle.sql to apply the Patch Set Update for exadata
Rem
@@catbundle.sql EXA apply


