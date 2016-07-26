rem 
rem $Header:
rem 
Rem Copyright (c) 1995, 1996 by Oracle Corporation 
Rem
Rem NAME
Rem   catadt.sql
Rem DESCRIPTION
Rem   This SQL script drops all data dictionary views created by CATADT.SQL.
Rem NOTES
Rem   This script must be run while connected as SYS or INTERNAL.
Rem MODIFIED
Rem     jwijaya    04/18/96 -  more views
Rem     jwijaya    11/29/95 -  Creation 
Rem
drop view USER_TYPES
/
drop public synonym USER_TYPES
/
drop view ALL_TYPES
/
drop public synonym ALL_TYPES
/
drop view DBA_TYPES
/
drop public synonym DBA_TYPES
/
drop view USER_COLL_TYPES
/
drop public synonym USER_COLL_TYPES
/
drop view ALL_COLL_TYPES
/
drop public synonym ALL_COLL_TYPES
/
drop view DBA_COLL_TYPES
/
drop public synonym DBA_COLL_TYPES
/
drop view USER_TYPE_ATTRS
/
drop public synonym USER_TYPE_ATTRS
/
drop view ALL_TYPE_ATTRS
/
drop public synonym ALL_TYPE_ATTRS
/
drop view DBA_TYPE_ATTRS
/
drop public synonym DBA_TYPE_ATTRS
/
drop view USER_TYPE_METHODS
/
drop public synonym USER_TYPE_METHODS
/
drop view ALL_TYPE_METHODS
/
drop public synonym ALL_TYPE_METHODS
/
drop view DBA_TYPE_METHODS
/
drop public synonym DBA_TYPE_METHODS
/
drop view USER_METHOD_PARAMS
/
drop public synonym USER_METHOD_PARAMS
/
drop view ALL_METHOD_PARAMS
/
drop public synonym ALL_METHOD_PARAMS
/
drop view DBA_METHOD_PARAMS
/
drop public synonym DBA_METHOD_PARAMS
/
drop view USER_METHOD_RESULTS
/
drop public synonym USER_METHOD_RESULTS
/
drop view ALL_METHOD_RESULTS
/
drop public synonym ALL_METHOD_RESULTS
/
drop view DBA_METHOD_RESULTS
/
drop public synonym DBA_METHOD_RESULTS
/
