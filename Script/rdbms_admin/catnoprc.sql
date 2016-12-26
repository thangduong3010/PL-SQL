rem 
rem $Header: catnoprc.sql,v 1.1 1992/10/20 14:43:36 GLUMPKIN Stab $ noprctrg.sql 
rem 
Rem Copyright (c) 1990 by Oracle Corporation
Rem NAME
REM    CATNOPRC.SQL
Rem  FUNCTION
Rem    Drop the stored procedure and trigger catalog views, created by
Rem    prctrg.sql.
Rem  NOTES
Rem    Must be run while connected to SYS.
Rem    Be sure to keep this file synchronized with catalog.sql and prctrg.sql
Rem  MODIFIED
Rem     glumpkin   10/20/92 -  Renamed from NOPRCTRG.SQL 
Rem     rkooi      01/18/92 -  add synonym 
Rem     rkooi      01/18/92 -  add object_size views 
Rem     rkooi      10/20/91 -  add public_dependency 
Rem     rkooi      05/22/91 -         get rid of _object in some catalog names 
Rem     rkooi      05/22/91 - change *_references to *_dependencies cat
Rem     rkooi      05/05/91 - add ALL_TRIGGERS 
Rem     rkooi      04/01/91 - add new catalogs for diana, pcode, etc. 
Rem     rkooi      03/12/91 - Creation
Rem

drop view USER_ERRORS
/
drop public synonym USER_ERRORS
/
drop view ALL_ERRORS
/
drop public synonym ALL_ERRORS
/
drop view DBA_ERRORS
/
drop view USER_SOURCE
/
drop public synonym USER_SOURCE
/
drop view ALL_SOURCE
/
drop public synonym ALL_SOURCE
/
drop view DBA_SOURCE
/
drop view USER_TRIGGERS
/
drop public synonym USER_TRIGGERS
/
drop view ALL_TRIGGERS
/
drop public synonym ALL_TRIGGERS
/
drop view DBA_TRIGGERS
/
drop view USER_DEPENDENCIES
/
drop public synonym USER_DEPENDENCIES
/
drop view ALL_DEPENDENCIES
/
drop public synonym ALL_DEPENDENCIES
/
drop view DBA_DEPENDENCIES
/
drop view PUBLIC_DEPENDENCY
/
drop public synonym PUBLIC_DEPENDENCY
/
drop view CODE_PIECES
/
drop view CODE_SIZE
/
drop view PARSED_PIECES
/
drop view PARSED_SIZE
/
drop view SOURCE_SIZE
/
drop view ERROR_SIZE
/
drop view DBA_OBJECT_SIZE
/
drop view USER_OBJECT_SIZE
/
drop public synonym USER_OBJECT_SIZE
/
