
Rem
Rem $Header: catbsln.sql 19-may-2006.10:51:26 jsoule Exp $
Rem
Rem catbsln.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbsln.sql - Baseline schema creation.
Rem
Rem    DESCRIPTION
Rem      Creates the EM baseline feature schema components
Rem
Rem    NOTES
Rem      Called by catsnmp.sql during database creation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      05/02/06 - created
Rem

Rem Create object types for bsln.
@@catbslny.sql

Rem Create tables for bsln.
@@catbslnt.sql

Rem Create the BSLN package definition.
@@dbmsbsln.sql

Rem Create the BSLN_INTERNAL package definition, package body.
Rem Create the BSLN package body.
@@prvtblid.plb
@@prvtblib.plb
@@prvtbsln.plb

Rem Seed the tables.
@@catbslnd.sql

Rem Create views for bsln.
@@catbslnv.sql

