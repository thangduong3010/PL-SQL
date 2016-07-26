Rem
Rem $Header: catexf.sql 08-feb-2007.14:01:25 ayalaman Exp $
Rem
Rem catexf.sql
Rem
Rem Copyright (c) 2002, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catexf.sql - Top level script to load Expression Filter
Rem
Rem    DESCRIPTION
Rem      This script installs the Expression Filter feature in a
Rem      dedicated EXFSYS schema.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/08/07 - fail on ORA error
Rem    ayalaman    10/25/04 - fix the validation procedure
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    11/21/02 - 
Rem    ayalaman    11/19/02 - add indextype definition
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - Created
Rem

WHENEVER SQLERROR EXIT;

REM
REM Create the user with a default and temporary tablespace
REM User will be prompted to enter the password for the user and the 
REM tablespace names
REM 
@@exfsys.sql

REM
REM Running as sysdba : set current schema to EXFSYS
REM
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

WHENEVER SQLERROR CONTINUE;

begin 
  sys.dbms_registry.loading('EXF', 'Oracle Expression Filter',
      'validate_exf','EXFSYS');
end;
/

REM 
REM Create the Java library in EXFSYS schema
REM 
prompt .. loading the Expression Filter Java library

@@initexf.sql

REM
REM Create Trusted 'C' library 
REM
CREATE OR REPLACE LIBRARY EXFTLIB TRUSTED AS STATIC;
/

REM
REM Create required schema objects in the EXFSYS Schema
REM
--- Create Types required for Expression Filter
@@exftyp.sql

--- Create Expression Filter Dictionary
@@exftab.sql

--- Create Public PL/SQL Package specifications
@@exfpbs.sql

--- Create Expression Filter catalog views
@@exfview.sql

REM
REM Create package implementations
REM
prompt .. creating Expression Filter private package in SYS schema
@@exfsppvs.plb

prompt .. installing Expression Filter APIs
@@exfeapvs.plb

prompt .. installing Expression Filter indextype and operators
@@exfimpvs.plb

REM .. installing XPath Expression Filter support
@@exfxppvs.plb

REM 
REM Create Indextype definition 
REM
create indextype EXPFilter
  for
   EVALUATE(VARCHAR2, VARCHAR2),
   EVALUATE(VARCHAR2, sys.ANYDATA),
   EVALUATE(CLOB, VARCHAR2),
   EVALUATE(CLOB, sys.ANYDATA)
using ExpressionIndexMethods;

grant execute on expfilter to public;

REM
REM Associate Statistics Methods
REM
ASSOCIATE STATISTICS WITH FUNCTIONS
  evaluate_vv,
  evaluate_va,
  evaluate_cv,
  evaluate_ca
  USING ExpressionIndexStats;

ASSOCIATE STATISTICS WITH INDEXTYPES EXPFilter
  USING ExpressionIndexStats;

REM 
REM Validate Expression Filter installation
REM
EXECUTE sys.dbms_registry.loaded('EXF');

EXECUTE sys.validate_exf;

ALTER SESSION SET CURRENT_SCHEMA = SYS;
