Rem
Rem $Header: dbmstypu.sql 15-feb-2002.18:46:03 skabraha Exp $
Rem
Rem dbmstypu.sql
Rem
Rem Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmstypu.sql - Type Utility
Rem
Rem    DESCRIPTION
Rem      Provides routines to compile all types and reset type version
Rem      during downgrade.
Rem
Rem    NOTES
Rem     This package must be executed by the DBA only.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    02/15/02 - add delete_constructor_keyword
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    thoang      06/27/00 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_type_utility AS 

  --
  PROCEDURE Upgrade_All_Tables;
  PROCEDURE Upgrade_All_Tables (ownername IN VARCHAR2);

  --
  PROCEDURE Compile_All_Types; 
  PROCEDURE Compile_All_Types (ownername IN VARCHAR2); 

  --
  PROCEDURE Reset_All_Types;
  PROCEDURE Reset_All_Types (ownername IN VARCHAR2);

  --
  PROCEDURE Delete_Constructor_Keyword;

END dbms_type_utility;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_TYPE_UTILITY FOR DBMS_TYPE_UTILITY;

