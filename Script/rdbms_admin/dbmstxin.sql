Rem
Rem $Header: dbmstxin.sql 19-mar-2003.16:35:01 wyang Exp $
Rem
Rem dbmstxin.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmstxin.sql - transaction layer package for internal use 
Rem
Rem    DESCRIPTION
Rem      Transaction layer package for internal use 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wyang       03/19/03 - grant execute on dbms_fbt to public
Rem    wyang       02/11/03 - bug 2795827
Rem    vakrishn    10/29/02 - vakrishn_fbt_main
Rem    wyang       10/08/02 - Created
Rem

-- Create type FLASHBACKTBLIST outside DBMS_FBT package to fix bug 2795827. 
-- It seems that jdbc has some problem with array type defined in package.
CREATE OR REPLACE TYPE flashbacktblist AS VARRAY(100) of VARCHAR2(30)
/

GRANT EXECUTE ON flashbacktblist TO public
/

CREATE OR REPLACE PACKAGE dbms_fbt AUTHID CURRENT_USER IS

  -- PUBLIC TYPES

  TYPE TMPTBCURTYPE IS REF CURSOR;
 
  -- PUBLIC PROCEDURES AND FUNCTIONS
  
  PROCEDURE fbt_analyze(table_name         IN  VARCHAR2,
                        flashback_scn      IN  NUMBER,
                        tmptbcur           OUT TMPTBCURTYPE);
  PROCEDURE fbt_analyze(table_name         IN  VARCHAR2,
                        flashback_time     IN  TIMESTAMP,
                        tmptbcur           OUT TMPTBCURTYPE);
  PROCEDURE fbt_execute(table_names        IN  FLASHBACKTBLIST,
                        flashback_scn      IN  NUMBER);
  PROCEDURE fbt_execute(table_names        IN  FLASHBACKTBLIST,
                        flashback_time     IN  TIMESTAMP);
  PROCEDURE fbt_discard;
  
END; 
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_fbt FOR sys.dbms_fbt
/

GRANT EXECUTE ON dbms_fbt TO public 
/

CREATE OR REPLACE LIBRARY dbms_fbt_lib TRUSTED AS STATIC
/
