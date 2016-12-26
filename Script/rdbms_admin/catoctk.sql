Rem
Rem $Header: catoctk.sql 15-apr-97.07:26:29 rwessman Exp $
Rem
Rem catoctk.sql
Rem
Rem  Copyright (c) Oracle Corporation 1997. All Rights Reserved.
Rem
Rem    NAME
Rem      catoctk.sql - CATalog - Oracle Cryptographic ToolKit
Rem
Rem    DESCRIPTION
Rem      Contains scripts needed to use the PL/SQL Cryptographic Toolkit
Rem      Interface
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rwessman    04/15/97 - Added actual SQL.
Rem    rwessman    04/14/97 - Cryptographic toolkit catalog
Rem    rwessman    04/14/97 - Created
Rem
Rem Cryptographic toolkit package declaration
Rem
@@dbmsoctk.sql
Rem
Rem Cryptographic toolkit package body
Rem
@@prvtoctk.plb
Rem
Rem Random number generator
Rem
@@dbmsrand.sql

