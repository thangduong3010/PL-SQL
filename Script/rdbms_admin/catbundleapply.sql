Rem
Rem $Header: rdbms/admin/catbundleapply.sql /st_rdbms_11.2.0/1 2013/04/08 09:59:24 surman Exp $
Rem
Rem catbundleapply.sql
Rem
Rem Copyright (c) 2013, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catbundleapply.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      03/19/13 - 16094163: Creation
Rem    surman      03/19/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catbundleapply.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

Rem Call catbundle.sql to apply the Patch Set Update (PSU)
Rem

COLUMN    :bundle_name  NEW_VALUE bundle_file NOPRINT;
VARIABLE   bundle_name  VARCHAR2(50)

declare

  nNumCells   NUMBER := 0;

begin

   nNumCells := sys.dbms_registry.num_of_exadata_cells();
   IF (nNumCells > 0) THEN
      :bundle_name := 'catbundle_exa.sql'; -- Exadata PSU
   ELSE
      :bundle_name := 'catbundle_psu.sql'; -- Normal PSU
   END IF;

end;
/

SELECT :bundle_name FROM DUAL;
@@&bundle_file

