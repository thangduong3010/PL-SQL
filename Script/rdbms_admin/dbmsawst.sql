Rem
Rem $Header: dbmsawst.sql 28-apr-2008.17:22:14 ckearney Exp $
Rem
Rem dbmsawst.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsawst.sql - AW statistics package definition
Rem
Rem    DESCRIPTION
Rem      Gathers statistics for AWs, DIMENSIONS & CUBES
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ckearney    04/28/08 - add clear
Rem    ckearney    10/12/06 - add mapping to xsanalyze callout
Rem    ckearney    06/05/06 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_aw_stats AUTHID CURRENT_USER AS

  --
  -- ERROR NUMBERS
  --
  -- Note : DBMS_OUTPUT, DBMS_DESCRIBE and DBMS_AW (maybe others) use
  -- the application error numbers -20001 to -20005 for there own purposes 
  --

  aw_error NUMBER := -20001;

  --
  -- PUBLIC INTERFACE
  --

  PROCEDURE analyze(inName IN VARCHAR2);
  PROCEDURE clear(inName IN VARCHAR2);
END dbms_aw_stats;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_aw_stats FOR sys.dbms_aw_stats
/
GRANT EXECUTE ON dbms_aw_stats TO PUBLIC
/
