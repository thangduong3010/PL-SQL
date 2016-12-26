Rem
Rem $Header: rule102.sql 25-feb-2008.11:38:00 ayalaman Exp $
Rem
Rem rule102.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rule102.sql - Downgrade script for Rules Manager
Rem
Rem    DESCRIPTION
Rem      Downgrade script for Rules Manager to 10.2
Rem
Rem    NOTES
Rem      Rules Manager was first introduced in 10.2
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/25/08 - downgrade from 11.2
Rem    ayalaman    03/19/07 - unused object
Rem    ayalaman    12/01/06 - fix downgrade issues with java objects
Rem    ayalaman    06/13/06 - drop package created in 11.1 
Rem    ayalaman    06/12/06 - downgrade for aggregate events support 
Rem    ayalaman    02/02/06 - shared primitive rule conditions 
Rem    ayalaman    09/19/05 - ayalaman_exf_contains_oper
Rem    ayalaman    08/19/05 - change notification support 
Rem    ayalaman    08/11/05 - Created
Rem

REM
REM Downgrade of RUL from 11 to 10.2 
REM
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

EXECUTE dbms_registry.downgrading('RUL');

REM
REM Call the downgrade script for next version
REM
@@rule111.sql

REM 
REM Drop Java stored procedure implementations that are 11.1 specific 
REM 

execute sys.dbms_java.dropjava('-schema exfsys rdbms/jlib/ExprFilter.jar');

REM 
REM Drop packages, views and classes that were added in the new release. 
REM 

drop index rlm$evtstprctab; 

drop package exfsys.dbms_rlmgr_irpk; 

REM 
REM Drop force any new types, operators and indextypes;
REM 

drop type exfsys.rlm$collpreds force; 

drop type exfsys.rlm$collevents force; 

drop type exfsys.rlm$collevent force; 

drop type exfsys.rlm$apmultvcl force; 

drop type exfsys.rlm$apvarclst force; 

drop type exfsys.rlm$apnumblst force; 

REM
REM Alter operator and indextype back to their prior release. 
REM

REM
REM Update new columns to values appropriate for the old release
REM
--
--- Change notification events support
--
alter table rlm$dmlevttrigs drop (dbcnfregid);
alter table rlm$dmlevttrigs drop (dbcnfcbkprc);

--
--- Shared primitive rule conditions table support
--
alter table rlm$eventstruct drop (evst_prct); 
alter table rlm$eventstruct drop (evst_prcttls); 

--
--- aggregate events support
--
alter table rlm$primevttypemap drop (collcttab);
alter table rlm$primevttypemap drop (grpbyattrs);

REM
REM Undo any modifications that were made to user objects during the upgrade
REM 

REM
REM Truncate / Drop the new tables
REM 

drop table rlm$collgrpbyspec;


EXECUTE dbms_registry.downgraded('RUL','10.2.0');

ALTER SESSION SET CURRENT_SCHEMA = SYS;

