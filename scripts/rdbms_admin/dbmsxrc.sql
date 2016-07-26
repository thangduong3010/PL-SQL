Rem
Rem $Header: rdbms/admin/dbmsxrc.sql /main/3 2009/04/06 20:28:14 badeoti Exp $
Rem
Rem dbmsxrc.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxrc.sql -  Package DBMS_ResConfig
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     03/21/09 - dbms_resconfig.patchRepRCList moved to
Rem                           dbms_xdbutil_int
Rem    thbaby      09/21/07 - add API to patch repository resconfig list
Rem    thoang      02/25/04 - Created
Rem


CREATE OR REPLACE PACKAGE xdb.dbms_resconfig AUTHID CURRENT_USER IS 
   
------------
-- CONSTANTS
--
------------
DELETE_RESOURCE        CONSTANT NUMBER := 1;
DELETE_RECURSIVE       CONSTANT NUMBER := 2;
APPEND_RESOURCE        CONSTANT NUMBER := 1;
APPEND_RECURSIVE       CONSTANT NUMBER := 2;

---------------------------------------------
-- FUNCTION - getResConfig
--     Returns the resource configuration at the specified position of the
--     target resource's configuration list.
-- PARAMETERS -
--  respath
--     Absolute path in the Hierarchy of the resource 
--  pos  
--     position of element to return. Position must be >= 0 and < the length of
--     the resource's configuration list.
-- RETURNS -
--     Returns contents of resource configuration.
---------------------------------------------
FUNCTION getResConfig(respath IN VARCHAR2, pos IN PLS_INTEGER)
  RETURN sys.XMLType;

---------------------------------------------
-- PROCEDURE - addResConfig
--      Inserts the resource configuration specified by rcpath at the given position in the target resource's configuration list.  
-- 
-- PARAMETERS: 
--     respath	- absolute path of the target resource.
--     rcpath	- absolute path of the resource configuration to be inserted. An exception is raised if rcpath already exists in the target's configuration list.
--     pos 	- index at which the new configuration is to be inserted. If this parameter is not specified then the new configuration is appended to the end of the list. An exception is raised if the index is out of range (i.e., pos < 0 or pos > the size of the target resource's configuration list).

---------------------------------------------

PROCEDURE addResConfig(respath IN VARCHAR2, rcpath IN VARCHAR2,
                       pos IN PLS_INTEGER := NULL);

---------------------------------------------
-- FUNCTION getResConfigPaths
--    Returns a list of resource configuration paths defined in the target resource's configuration list. 
--

-- PARAMETERS:
--    respath	- absolute path of the target resource.
---------------------------------------------
Function getResConfigPaths(respath IN VARCHAR2) return XDB$STRING_LIST_T;

---------------------------------------------
-- PROCEDURE appendResConfig
-- Appends the resource configuration specified by rcpath to the target resource's configuration list if it is not already included in the list. 

-- PARAMETERS
--   respath	- absolute path of the target resource.
--   rcpath	- absolute path of the resource configuration to be appended at the end of the target's configuration list. If rcpath already exists in the list then nothing is appended. 
--   appendOption - either APPEND_RESOURCE or APPEND_RECURSIVE. If APPEND_RESOURCE is specified then only the target resource is affected. If APPEND_RECURSIVE is specified then the target resource and all its descendents will be affected.
---------------------------------------------
Procedure appendResConfig(respath IN VARCHAR2, rcpath IN VARCHAR2, appendOption IN PLS_INTEGER);

---------------------------------------------
-- PROCEDURE deleteResConfig
-- Removes the configuration at the given position in the target resource's configuration list. 
-- PARAMETERS
--   respath	- absolute path of the target resource.
--   pos 	- the index of the configuration to be removed. An exception is raised if the index is out of range (i.e., pos < 0 or pos >= the size of the target resource's configuration list.
---------------------------------------------
Procedure deleteResConfig(respath IN VARCHAR2, pos IN PLS_INTEGER);

---------------------------------------------
-- PROCEDURE deleteResConfig 
-- Removes the configuration specified by rcpath from the target resource's configuration list. Shifts any subsequent elements to the left. Users must have write-config privilege on all affected resources to execute this.

-- PARAMETERS
--   respath	- absolute path of the target resource.
--   rcpath	- absolute path of the resource configuration to be deleted if found in list.
--   deleteOption - either DELETE_RESOURCE or DELETE_RECURSIVE. If DELETE_RESOURCE is specified then only the configuration list of the target resource is affected. If DELETE_RECURSIVE is specified then the configuration list of the target resource and all its descendents will be affected.

---------------------------------------------
Procedure deleteResConfig(respath IN VARCHAR2, rcpath IN VARCHAR2, 
deleteOption IN PLS_INTEGER);

---------------------------------------------
-- FUNCTION getListeners
-- Returns the list of listeners applicable for a given resource. The value returned by this function is an XML document containing the <event-listeners> element of the XDBResconfig.xsd schema. It contains all the listeners applicable to the target resource, including repository-level listeners. From the returned XML document users can use the EXTRACT operator to retrieve the listeners defined for a specific event. Users must have the required access privilege on all resource configurations referenced by the repository and the target resource; otherwise, an error is returned.

-- PARAMETERS
-- path - absolute path of the target resource.
---------------------------------------------
function getListeners(path IN VARCHAR2) return SYS.XMLType; 

---------------------------------------------
-- FUNCTION getRepositoryResConfig
	
-- Description:
-- Returns the resource configuration at the specified position of the repository's configuration list.  Users must have the required read privilege on the requested resource configuration; otherwise, an error is returned.
-- Parameters: 
--     pos 	- index of element to return. An exception is raised if the index is out of range (i.e., pos < 0 or pos >= the size of the repository's configuration list).
---------------------------------------------
	Function getRepositoryResConfig(pos IN PLS_INTEGER) return SYS.XMLType;

---------------------------------------------
-- FUNCTION getRepositoryResConfigPaths

--	Description:
--         Returns a list of resource configuration paths defined for the repository. Users must be able to access all the referenced resource configurations; otherwise, an error is returned.
---------------------------------------------
	Function getRepositoryResConfigPaths return XDB$STRING_LIST_T;
        
---------------------------------------------
-- PROCEDURE addRepositoryResConfig
	        
-- Description:
-- Inserts the resource configuration specified by rcpath at the given position of the repository's configuration list.  Shifts the element currently at that position (if any) and any subsequent elements to the right. An error is raised if the document referenced by rcpath is not based on XDBResConfig.xsd schema. Users must have XDBADMIN role and read privilege on the resource configuration to be inserted; otherwise, an error is returned.
-- Parameters: 
--     rcpath	- absolute path of the resource configuration to be inserted. An exception is raised if rcpath already exists in the repository's configuration list.
--     pos 	- index at which the new configuration is to be inserted. If this parameter is not specified then the new configuration is appended to the end of the list. An exception is raised if the index is out of range (i.e., pos < 0 or pos > the size of the repository's configuration list).
---------------------------------------------
Procedure addRepositoryResConfig(rcpath IN VARCHAR2, pos IN PLS_INTEGER := NULL);

---------------------------------------------
-- PROCEDURE deleteRepositoryResConfig

-- 	Description:
--        Removes the configuration at the given position in the repository's configuration list. Shifts any subsequent elements to the left.  Users must have XDBADMIN role to execute this. 
--       This statement is treated as if it is a DDL statement. This means the system will implicitly commit before and after this statement.
-- Parameters: 
--      pos 	- the index of the configuration to be removed. An exception is raised if the index is out of range (i.e., pos < 0 or pos >= the size of the repository's configuration list).
---------------------------------------------
	Procedure deleteRepositoryResConfig(pos IN PLS_INTEGER);

end dbms_resconfig;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_resconfig FOR xdb.dbms_resconfig
/
GRANT EXECUTE ON xdb.dbms_resconfig TO PUBLIC
/
show errors;
