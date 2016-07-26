Rem
Rem $Header: catrmno.sql 07-may-2002.12:18:03 asundqui Exp $
Rem
Rem catrmgrno.sql
Rem
Rem Copyright (c) 1998, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catrmgrno.sql - CATalog script for NO db Resource ManaGeR
Rem
Rem    DESCRIPTION
Rem      does the downgrade for DBMS Resource Manager
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    asundqui    05/07/02 - consumer group mapping interface
Rem    rshaikh     03/10/99 - remove delete from sysauth
Rem    akalra      12/04/98 - use uninstall procedure
Rem    akalra      11/20/98 - drop built-in objects
Rem    akalra      06/01/98 - Use new view, table names                        
Rem    akalra      04/17/98 - Created
Rem

Rem Remove db Resource Manager huilt-in groups and plans (if created during
Rem installation in the future).  It is assumed that all user-created plans
Rem and groups have been dropped.

Rem The following drops system generated, non-mandatory objects - SYSTEM_PLAN,
Rem SYS_GROUP, and LOW_GROUP, and mandatory objects - OTHER_GROUPS, and
Rem DEFAULT_CONSUMER_GROUP

execute dbms_rmin.uninstall;

Rem drop the packages and synonyms

drop PUBLIC SYNONYM dbms_resource_manager
/
drop PUBLIC SYNONYM dbms_rmin
/
drop PUBLIC SYNONYM dbms_resource_manager_privs
/
drop PUBLIC SYNONYM dbms_rmgr_plan_export
/
drop PUBLIC SYNONYM dbms_rmgr_pact_export
/
drop PUBLIC SYNONYM dbms_rmgr_group_export
/
drop PACKAGE dbms_resource_manager
/
drop PACKAGE dbms_rmin
/
drop PACKAGE dbms_resource_manager_privs
/
drop PACKAGE dbms_prvtrmie
/
drop PACKAGE dbms_rmgr_plan_export
/
drop PACKAGE dbms_rmgr_pact_export
/
drop PACKAGE dbms_rmgr_group_export
/

Rem drop the library for trusted callouts

drop LIBRARY dbms_rmgr_lib
/

Rem drop the views and synonyms

drop PUBLIC SYNONYM DBA_RSRC_PLANS
/
drop view DBA_RSRC_PLANS
/
drop PUBLIC SYNONYM DBA_RSRC_CONSUMER_GROUPS
/
drop view DBA_RSRC_CONSUMER_GROUPS
/
drop PUBLIC SYNONYM DBA_RSRC_PLAN_DIRECTIVES
/
drop view DBA_RSRC_PLAN_DIRECTIVES
/
drop PUBLIC SYNONYM DBA_RSRC_CONSUMER_GROUP_PRIVS
/
drop view DBA_RSRC_CONSUMER_GROUP_PRIVS
/
drop PUBLIC SYNONYM USER_RSRC_CONSUMER_GROUP_PRIVS
/
drop view USER_RSRC_CONSUMER_GROUP_PRIVS
/
drop PUBLIC SYNONYM DBA_RSRC_MANAGER_SYSTEM_PRIVS
/
drop view DBA_RSRC_MANAGER_SYSTEM_PRIVS
/
drop PUBLIC SYNONYM USER_RSRC_MANAGER_SYSTEM_PRIVS
/
drop view USER_RSRC_MANAGER_SYSTEM_PRIVS
/
drop PUBLIC SYNONYM DBA_RSRC_GROUP_MAPPINGS
/
drop view DBA_RSRC_GROUP_MAPPINGS
/
drop PUBLIC SYNONYM DBA_RSRC_MAPPING_PRIORITY
/
drop view DBA_RSRC_MAPPING_PRIORITY
/




