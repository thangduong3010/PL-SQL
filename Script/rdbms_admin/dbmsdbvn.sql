Rem
Rem $Header: plsql/admin/dbmsdbvn.sql /main/4 2008/11/18 10:35:52 wxli Exp $
Rem
Rem dbmsdbvn.sql
Rem
Rem Copyright (c) 2004, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsdbvn.sql - RDBMS version information
Rem
Rem    DESCRIPTION
Rem      The package dbms_db_version specifies RDBMS version information
Rem      (for example, major version number and release number). They are
Rem      presented as package constants.
Rem    NOTES
Rem      This package is meant for use by the users of PL/SQL conditional
Rem      compilation. This does not forbid other uses but additions/changes
Rem      to this package must be carefully considered.
Rem
Rem      This script should be run as user SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wxli        11/14/08 - add version 11.2
Rem    wxli        09/20/06 - add version 11.1
Rem    mxyang      09/10/04 - rewrite some comments
Rem    mxyang      05/28/04 - mxyang_bug-3644582
Rem    mxyang      04/09/04 - Created


create or replace package dbms_db_version is
  version constant pls_integer := 11; -- RDBMS version number
  release constant pls_integer := 2;  -- RDBMS release number

  /* The following boolean constants follow a naming convention. Each
     constant gives a name for a boolean expression. For example,
     ver_le_9_1  represents version <=  9 and release <= 1
     ver_le_10_2 represents version <= 10 and release <= 2
     ver_le_10   represents version <= 10

     A typical usage of these boolean constants is

         $if dbms_db_version.ver_le_10 $then
           version 10 and ealier code
         $elsif dbms_db_version.ver_le_11 $then
           version 11 code
         $else
           version 12 and later code
         $end

     This code structure will protect any reference to the code
     for version 12. It also prevents the controlling package
     constant dbms_db_version.ver_le_11 from being referenced
     when the program is compiled under version 10. A similar
     observation applies to version 11. This scheme works even
     though the static constant ver_le_11 is not defined in
     version 10 database because conditional compilation protects
     the $elsif from evaluation if the dbms_db_version.ver_le_10 is
     TRUE.
  */

  ver_le_9_1    constant boolean := FALSE;
  ver_le_9_2    constant boolean := FALSE;
  ver_le_9      constant boolean := FALSE;
  ver_le_10_1   constant boolean := FALSE;
  ver_le_10_2   constant boolean := FALSE;
  ver_le_10     constant boolean := FALSE;
  ver_le_11_1   constant boolean := FALSE;
  ver_le_11_2   constant boolean := TRUE;
  ver_le_11     constant boolean := TRUE;

end dbms_db_version;
/

create or replace public synonym dbms_db_version for dbms_db_version
/
grant execute on dbms_db_version to public
/
