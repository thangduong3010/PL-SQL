Rem
Rem $Header: exfe102.sql 25-feb-2008.11:38:00 ayalaman Exp $
Rem
Rem exfe102.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfe102.sql - Downgrade script for Expression Filter
Rem
Rem    DESCRIPTION
Rem      Downgrade script for Expression Filter to 10.2
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/25/08 - downgrade from 11.2
Rem    ayalaman    06/13/06 - fix downgrade script 
Rem    ayalaman    09/19/05 - ayalaman_exf_contains_oper
Rem    ayalaman    08/11/05 - Created
Rem

REM
REM Downgrade of EXF from 11 to 10.2
REM
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

EXECUTE dbms_registry.downgrading('EXF');

REM
REM Call the downgrade script for next version 
REM
@@exfe111.sql

REM 
REM Drop packages, views and classes that were added in the new release. 
REM 

--
--- Drop the view for text predicate errors
--
drop public synonym user_expfil_text_index_errors;

drop view user_expfil_text_index_errors;

drop function exf$text2exprid; 

REM 
REM Drop force any new types, operators and indextypes;
REM 

--
--- Support for CONTAINS operator in stored expressions
--
drop type exf$text; 

REM
REM Alter operator and indextype back to their prior release. 
REM

REM
REM Update new columns to values appropriate for the old release
REM

REM
REM Undo any modifications that were made to user objects during the upgrade
REM 

REM
REM Truncate / Drop the new tables
REM 

--
--- Support for CONTAINS operator in stored expressions 
--
-- delete the spatial operator from indexed list ---
delete from exf$validioper where operstr = 'CONTAINS';

-- drop the column attr
alter table exf$attrlist drop column attrtxtprf; 


EXECUTE dbms_registry.downgraded('EXF','10.2.0');

ALTER SESSION SET CURRENT_SCHEMA = SYS;

