Rem
Rem $Header: rdbms/admin/dbmsappcont.sql /st_rdbms_11.2.0/1 2011/03/09 09:24:35 sroesch Exp $
Rem
Rem dbmsappcont.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      dbmsappcont.sql - Private package for 11.2.0.3 application continuity support
Rem
Rem    DESCRIPTION
Rem      Provides support for the 11.2.0.3 application continuity support.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sroesch     01/11/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE LIBRARY dbms_app_cont_prvt_lib trusted IS static;
/

CREATE OR REPLACE PACKAGE dbms_app_cont_prvt AS

 ------------
 --  OVERVIEW
 --
 --  This package allows an application to manage transaction monitoring
 --  and replay for select-only transactions.

 ----------------
 --  INSTALLATION
 --
 --  This package should be installed under SYS schema.
 --
 --  SQL> @dbmsappcont
 --

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  PROCEDURE monitor_txn;
  -- Enables the monitoring of transactions in the server

  PROCEDURE begin_replay;
  -- Enables the replay mode in the server. While in replay mode, no transactions can
  -- be either started or committed.

  PROCEDURE end_replay;
  -- Disables the replay mode.

END dbms_app_cont_prvt;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_app_cont_prvt FOR dbms_app_cont_prvt
/
 ---------------------------------
 --
 -- Grant only to DBA role
 --

GRANT EXECUTE ON dbms_app_cont_prvt TO public

/

