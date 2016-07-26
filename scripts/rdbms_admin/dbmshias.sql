Rem
Rem $Header: dbmshias.sql 24-may-2001.14:53:21 gviswana Exp $
Rem
Rem dbmshias.sql
Rem
Rem  Copyright (c) Oracle Corporation 1900, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmshias.sql - Headers (specifications) for IAS packages. They can
Rem                     be executed by users who have the execute_catalog_role
Rem                     privileges
Rem
Rem    DESCRIPTION
Rem      This is the header file for the following iAS packages : 
Rem
Rem      dbms_ias_configure - routines to set/clear the backend database, and
Rem                           to configure the cache as allowing/prohibiting
Rem                           updateable MVs. 
Rem      dbms_ias_session   - routines to set/clear redirection to the backend
Rem                           database for the session. 
Rem      dbms_ias_query     - routines for checking if a backend database name 
Rem                           has been configured for the cache instance, 
Rem                           whether updateable MVs are allowed, and whether 
Rem                           redirection is enabled for the session. 
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    jingliu     06/09/00 - grant dbms_ias_session to PUBLIC 
Rem    liwong      05/02/00 - Remove manipulating updatable routines
Rem    vvishwan    01/00/00 - Created
Rem

Rem ==========================================================================
Rem HEADERS
Rem ==========================================================================

CREATE OR REPLACE PACKAGE dbms_ias_configure IS

  --- -------------------------------------------------------------------------
  --- Set the back end database for the middle tier and record this name
  --- in the database. If dblink is NULL, then any back end 
  --- database entry will be deleted (this will have the same effect as calling
  --- remove_back_end_db).  If dblink is not NULL, the dblink should be the 
  --- global name of the back end database. This routine does a commit upon 
  --- successful execution.  If the dblink is the global name of the middle 
  --- tier database, an exception is raised.  A database by default has no 
  --- back end database.  A database needs a back end database to function as 
  --- a middle tier and redirect SQL statements.    

  PROCEDURE set_back_end_db(dblink   IN VARCHAR2);

  --- -------------------------------------------------------------------------
  --- Set the back end database to NULL.
  --- This converts the middle tier to an ordinary database.  This routine 
  --- does a commit upon successful execution.

  PROCEDURE remove_back_end_db;

END dbms_ias_configure;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_ias_configure FOR sys.dbms_ias_configure
/

GRANT EXECUTE ON dbms_ias_configure TO execute_catalog_role
/

--- ---------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_ias_session IS

  --- -------------------------------------------------------------------------
  --- Turns on redirection for the session. This session state permits SQL and 
  --- PL/SQL redirection in a middle tier  database that has a back end 
  --- database. A session by default has redirection turned on.

  PROCEDURE set_redirection;     

  --- -------------------------------------------------------------------------
  --- Turn off redirection in the session.  This session state prevents SQL 
  --- and PL/SQL redirection in a middle tier database that has a back end 
  --- database.
 
  PROCEDURE clear_redirection;

END dbms_ias_session;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_ias_session FOR sys.dbms_ias_session
/

GRANT EXECUTE ON dbms_ias_session TO PUBLIC
/

--- ---------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_ias_query IS

  --- -------------------------------------------------------------------------
  --- Return TRUE if the session state indicates redirection is turned on. If 
  --- the middle tier does not have a backend database, then the routine 
  --- returns FALSE, irrespective of the session state

  FUNCTION test_redirection RETURN BOOLEAN;

  --- -------------------------------------------------------------------------
  --- If the local database is a middle tier, return the name of the back end 
  --- database.  Return NULL if there is none. An error will be raised if the 
  --- back end dblink is invalid

  FUNCTION get_back_end_db RETURN VARCHAR2;

END dbms_ias_query;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_ias_query FOR sys.dbms_ias_query
/

GRANT EXECUTE ON dbms_ias_query TO PUBLIC
/






