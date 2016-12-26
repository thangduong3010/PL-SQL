Rem
Rem $Header: rdbms/admin/dbmsmet2.sql /main/2 2009/08/19 13:47:31 lbarton Exp $
Rem
Rem dbmsmet2.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsmet2.sql - Package header for DBMS_METADATA_DIFF
Rem       (moved from dbmsmeta.sql)
Rem
Rem    DESCRIPTION
Rem      This file contains the interface to the Metadata API
Rem      comparison interface.
Rem
Rem      USE OF THIS PACKAGE REQUIRES A LICENSE TO THE ORACLE ENTERPRISE
Rem      MANAGER CHANGE MANAGEMENT OPTION.
Rem
Rem    PUBLIC FUNCTIONS / PROCEDURES
Rem     OPENC           - Establish context for comparing 2 (S)XML docs. 
Rem     ADD_DOCUMENT    - Specify an SXML document to be compared
Rem     FETCH_CLOB      - Fetch SXML diff document.
Rem     CLOSE           - Cleanup context established by OPENC.
Rem       (the browsing interface)
Rem     COMPARE_ALTER   - returns a set of ALTER statements for making 
Rem                       object 1 like object 2.
Rem     COMPARE_ALTER_XML
Rem                     - returns an ALTER_XML document
Rem     COMPARE_SXML    - returns a SXML difference document
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     08/14/09 - remove outdated comment
Rem    lbarton     04/14/08 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_metadata_diff AUTHID CURRENT_USER AS 
---------------------------------------------------------------------
-- Overview
-- This pkg implements the comparison interface of the Data Pump Metadata API.
--
--      USE OF THIS PACKAGE REQUIRES A LICENSE TO THE ORACLE ENTERPRISE
--      MANAGER CHANGE MANAGEMENT OPTION.
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS with execute access granted to PUBLIC.
-- It runs with invokers rights, i.e., with the security profile of
-- the caller.  It calls DBMS_METADATA_INT to perform privileged
-- functions.

---------------------------
-- PROCEDURES AND FUNCTIONS
--
-- OPENC: 
--        This function establishes a 'compare' context and specifies the 
--        object type for comparing to (S)XML documents.
-- PARAMETERS:
--      object_type  - Identifies the type of objects to be compared; i.e.,
--              TABLE, INDEX, etc. 
-- RETURNS:
--      A handle to be used in subsequent calls to ADD_DOCUMENT,
--      COMPARE_SXML, etc
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION openc (
                object_type     IN  VARCHAR2)
        RETURN NUMBER;

-- ADD_DOCUMENT : Specifies an (S)XML document (as XMLTYPE) to be compared.
-- PARAMETERS:
--      handle          - Context handle from previous OPENC call.
--      document        - document (xmltype) to be compared
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  PROCEDURE add_document (
               handle          IN  NUMBER,
               document        IN  sys.XMLType);

-- ADD_DOCUMENT : Specifies an (S)XML document (as clob) to be compared.
-- PARAMETERS:connect
--      handle          - Context handle from previous OPENC call.
--      document        - document (clob) to be compared
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  PROCEDURE add_document (
                handle          IN  NUMBER,
                document        IN  CLOB);

-- PROCEDURE FETCH_CLOB: Return SXML diff document.
-- PARAMETERS:	handle- (IN) Context handle from previous OPENC call.
--              xmldoc - (IN OUT) previously allocated CLOB to hold the
--                       returned diff document.
--		diffs  - (OUT) flag (1 == diffs found; 0==no diffs found)

  FUNCTION fetch_clob (
		handle	IN NUMBER)
         RETURN CLOB;

  PROCEDURE fetch_clob (
		handle	IN NUMBER,
		xmldoc	IN OUT NOCOPY CLOB);

  PROCEDURE fetch_clob (
		handle	IN NUMBER,
		xmldoc	IN OUT NOCOPY CLOB,
                diffs   OUT BOOLEAN);

-- CLOSE:       Cleanup all context associated with handle.
-- PARAMETERS:  handle  - Context handle from previous OPENC call.

  PROCEDURE CLOSE (handle IN NUMBER);

-- COMPARE_SXML:
--        The functions compares the metadata for two objects and returns
--        an sxml difference document.
-- RETURNS:     
--        CLOB containing sxml difference document.
-- PARAMETERS:  
--        object_type   - type of object to be retrieved and compared
--        name1         - first object to be compared
--        name2         - second object to be compared
--        schema1       - schema of the first obj to be compared
--        schema2       - schema of the second obj to be compared
--        network_link1 - name of a database link where the first obj
--                        resides.
--        network_link2 - name of a database link where the second obj
--                        resides.
-- EXCEPTIONS:  Throws an exception if COMPARE failed.

  FUNCTION compare_sxml (
                object_type     IN VARCHAR2,
                name1           IN VARCHAR2,
                name2           IN VARCHAR2,
                schema1         IN VARCHAR2 DEFAULT NULL,
                schema2         IN VARCHAR2 DEFAULT NULL,
                network_link1   IN VARCHAR2 DEFAULT NULL,
                network_link2   IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;

-- COMPARE_ALTER:
--        This function compares the metadata for two objects and returns a
--        set of ALTER statements for making object 1 like object2.
-- RETURNS:     
--        CLOB containing alter statements for making object 1 like object 2
-- PARAMETERS:  
--        object_type   - type of object to be retrieved and compared
--        name1         - first object to be compared
--        name2         - second object to be compared
--        schema1       - schema of the first obj to be compared
--        schema2       - schema of the second obj to be compared
--        network_link1 - name of a database link where the first obj
--                        resides.
--        network_link2 - name of a database link where the second obj
--                        resides.
-- EXCEPTIONS:  Throws an exception if COMPARE failed.

  FUNCTION compare_alter (
                object_type     IN VARCHAR2,
                name1           IN VARCHAR2,
                name2           IN VARCHAR2,
                schema1         IN VARCHAR2 DEFAULT NULL,
                schema2         IN VARCHAR2 DEFAULT NULL,
                network_link1   IN VARCHAR2 DEFAULT NULL,
                network_link2   IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;

-- COMPARE_ALTER_XML:
--        This function compares the metadata for two objects and returns
--        an ALTER_XML document.
-- RETURNS:     
--        CLOB containing sxml difference document.
-- PARAMETERS:
--        object_type   - type of object to be retrieved and compared
--        name1         - first object to be compared
--        name2         - second object to be compared
--        schema1       - schema of the first obj to be compared
--        schema2       - schema of the second obj to be compared
--        network_link1 - name of a database link where the first obj
--                        resides.
--        network_link2 - name of a database link where the second obj
--                        resides.
-- EXCEPTIONS:  Throws an exception if COMPARE failed.

  FUNCTION compare_alter_xml (
                object_type     IN VARCHAR2,
                name1           IN VARCHAR2,
                name2           IN VARCHAR2,
                schema1         IN VARCHAR2 DEFAULT NULL,
                schema2         IN VARCHAR2 DEFAULT NULL,
                network_link1   IN VARCHAR2 DEFAULT NULL,
                network_link2   IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;
END DBMS_METADATA_DIFF;
/
GRANT EXECUTE ON sys.dbms_metadata_diff TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_metadata_diff FOR sys.dbms_metadata_diff;




