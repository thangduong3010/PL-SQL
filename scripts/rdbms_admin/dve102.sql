Rem
Rem $Header: dve102.sql 22-may-2008.14:56:16 vigaur Exp $
Rem
Rem dve102.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dve102.sql - Downgrade form 11g to 10gR2
Rem
Rem    DESCRIPTION
Rem      This Script should be run as SYSDBA after Relinking
Rem    the executable with DV turned off.
Rem
Rem    NOTES
Rem   *** PLEASE SEE The document for the exact steps for DV upgrade/downgrade *****
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vigaur      05/22/08 - LRG 3408867
Rem    vigaur      04/16/08 - Call 11.1->11.2 migrate script
Rem    mxu         12/19/06 - 
Rem    rvissapr    12/01/06 - downgrade from 11gR1 to 10gR2
Rem    rvissapr    12/01/06 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

Rem Put Upgrade metadata changes here. Please SET  the current schema correctly
Rem Before putting in any SQL commands


Rem Downgrade Complete

@@dve111.sql

ALTER SESSION SET CURRENT_SCHEMA = SYS;

DROP PROCEDURE SYS.validate_dv;

EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '10.2.0');

