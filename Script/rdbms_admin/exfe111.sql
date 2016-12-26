Rem
Rem $Header: rdbms/admin/exfe111.sql /main/3 2009/01/08 11:05:08 ayalaman Exp $
Rem
Rem exfe111.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      exfe111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    11/01/08 - compiled sparse downgrade
Rem    ayalaman    03/19/08 - downgrade status
Rem    ayalaman    02/25/08 - downgrade to 11.1
Rem    ayalaman    02/25/08 - Created
Rem

REM
REM Downgrade of EXF from 11.2 to 11.1
REM
EXECUTE dbms_registry.downgrading('EXF');

-- Do not drop the types used for compiled sparse support -- 
exec sys.exf$dbms_expfil_syspack.downgrade_compiled_sparse; 

REM
REM Call the downgrade script for next version (none)
REM

EXECUTE dbms_registry.downgraded('EXF','11.1.0');

