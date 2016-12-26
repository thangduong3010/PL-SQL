Rem
Rem $Header: rdbms/admin/catptyps.sql /main/3 2009/02/04 15:36:34 schitti Exp $
Rem
Rem catptyps.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catptyps.sql - CATProc TYPe creation
Rem
Rem    DESCRIPTION
Rem      This script creates types and other objects needed for 
Rem      subsequent scripts
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amullick    01/27/09 - Archive Provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    elu         10/23/06 - add replication types
Rem    rburns      05/07/06 - Public Types 
Rem    rburns      05/07/06 - Created
Rem


-- creates the ANYDATA type used by scripts in catptabs.sql
@@dbmsany.sql

Rem XMLTYPE specs
-- Manageaablity tables depend on XMLTYPE
@@catxml.sql

Rem Manageability/Diagnosability Report Framework
-- tables and views are currently in separate scripts, so create tables here
@@catrept

Rem global plan_table
@@catplan.sql

Rem Replication
@@catreplt.sql

Rem ContentAPI
@@catcapit

Rem ArchiveProvider
@@catapt
