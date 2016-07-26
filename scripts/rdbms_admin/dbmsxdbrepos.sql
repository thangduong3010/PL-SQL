Rem
Rem $Header: rdbms/admin/dbmsxdbrepos.sql /main/2 2009/04/06 20:28:12 badeoti Exp $
Rem
Rem dbmsxdbrepos.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxdbrepos.sql - XDB Modular Repository
Rem
Rem    DESCRIPTION
Rem
Rem      This file contains functions for creating new
Rem      repositories. A repository is a self-contained
Rem      unit that manages path based acccess to content.
Rem      Repositories can be customized to support
Rem      ACLs, versioning, event handlers etc.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     03/20/09 - clean up 11.2 packages: remove public synonym for
Rem                           dbms_xdbrepos
Rem    sichandr    08/11/08 - Repository level operations
Rem    sichandr    08/11/08 - Created
Rem

CREATE OR REPLACE PACKAGE xdb.dbms_xdbrepos AUTHID CURRENT_USER IS

  ---------------------------------------------
  --  OVERVIEW
  --
  --  This package provides procedures to
  --  (*) create a self-contained repository
  --  (*) delete a previously registered repository
  --  (*) alter a previously created repository
  --
  ---------------------------------------------

------------
-- CONSTANTS
--
------------
ACL_SECURITY        CONSTANT NUMBER := 1;
EVENTS              CONSTANT NUMBER := 2;
VERSIONING          CONSTANT NUMBER := 4;
CONFIG_FILE         CONSTANT NUMBER := 8;
DOCUMENT_LINKS      CONSTANT NUMBER := 16;
NFS_LOCKS           CONSTANT NUMBER := 32;

FULL_FEATURED       CONSTANT NUMBER := 63;

-------------
-- DEBUG MODE
--
-------------
DEBUG_MODE          NUMBER := 0;

---------------------------------------------
-- FUNCTION - CreateRepository
--     Creates a self-contained repository
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
--  reposOptions
--     Repository configuration options
---------------------------------------------
PROCEDURE CreateRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2,
                  reposOptions IN PLS_INTEGER);

---------------------------------------------
-- FUNCTION - DropRepository
--     Drops repository and contents
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
---------------------------------------------
PROCEDURE DropRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2);

---------------------------------------------
-- FUNCTION - SetCurrentRepository
--     Sets current repository for all subsequent resource
--     operations
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
---------------------------------------------
PROCEDURE SetCurrentRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2);

---------------------------------------------
-- FUNCTION - MountRepository
--     Mounts specified repository at a given path in
--     source repository
-- PARAMETERS -
--  parentReposOwner
--     Owner of destination repository (database user)
--  parentReposName
--     Name of destination repository (same restrictions as table names)
--  parentMntPath
--     Path in the destination repository where mounting should occur
--  mountedReposOwner
--     Owner of source repository (database user)
--  mountedReposName
--     Name of source repository (same restrictions as table names)
--  mountedPath
--     Path in the source repository to mount
---------------------------------------------
PROCEDURE MountRepository(parentReposOwner IN VARCHAR2,
                  parentReposName IN VARCHAR2,
                  parentMntPath IN VARCHAR2,
                  mountedReposOwner IN VARCHAR2,
                  mountedReposName IN VARCHAR2,
                  mountedPath IN VARCHAR2  );

---------------------------------------------
-- FUNCTION - UnMountRepository
--     Unmounts repository from specified path
-- PARAMETERS -
--  parentReposOwner
--     Owner of destination repository (database user)
--  parentReposName
--     Name of destination repository (same restrictions as table names)
--  mountPath
--     Mount path in the destination repository to be removed
---------------------------------------------
PROCEDURE UnMountRepository(parentReposOwner IN VARCHAR2,
                  parentReposName IN VARCHAR2,
                  mountPath IN VARCHAR2  );

PROCEDURE Install_Repos(schema IN VARCHAR2, tables IN
                        XDB$STRING_LIST_T);
PROCEDURE Drop_Repos(schema IN VARCHAR2, tables IN
                     XDB$STRING_LIST_T);
end dbms_xdbrepos;
/

GRANT EXECUTE ON xdb.dbms_xdbrepos TO PUBLIC;


