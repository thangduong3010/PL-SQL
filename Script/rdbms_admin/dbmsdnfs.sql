Rem
Rem $Header: rdbms/admin/dbmsdnfs.sql /st_rdbms_11.2.0/1 2010/08/03 13:43:47 msusaira Exp $
Rem
Rem dbmsdnfs.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsdnfs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    msusaira    07/23/10 - Backport msusaira_bug-9893598 from main
Rem    msusaira    07/13/10 - make dbms_dnfs a fixed package
Rem    msusaira    06/03/09 - dNFS utility procedure
Rem    msusaira    06/03/09 - Created
Rem

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

create or replace package dbms_dnfs AUTHID CURRENT_USER AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package


  -- Renames files in the dNFS test database to the new name. The new file
  -- points to the original file for reads.
  -- 
  -- srcfile - source data file name in the control file
  -- destfile - destination file
  --
  PROCEDURE clonedb_renamefile (srcfile  IN varchar2,
                                destfile  IN varchar2
                                );

-------------------------------------------------------------------------------

pragma TIMESTAMP('2010-07-08:12:00:00');

-------------------------------------------------------------------------------


end;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_dnfs FOR sys.dbms_dnfs
/
GRANT EXECUTE ON dbms_dnfs TO dba
/

show errors;
