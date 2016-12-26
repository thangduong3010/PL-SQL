Rem
Rem $Header: rdbms/admin/dbmsxdbschmig.sql /st_rdbms_11.2.0/2 2012/07/30 17:22:47 bhammers Exp $
Rem
Rem dbmsxdbschmig.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxdbschmig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem     this package defines structures to migrate an xml schema from a user
Rem     'a' to a user 'b' without moving the data.
Rem     For now this is an undocumented package. It was requested to enable 
Rem     editioning 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    06/14/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PACKAGE sys.xdb_migrateschema IS

-- Procedures to move an xml schema from user A to user B
-- see impl for comments
PROCEDURE moveSchemas;

end xdb_migrateschema;
/
show errors;


BEGIN
 execute immediate ('DROP TABLE xdb$moveSchemaTab');
 EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
 execute immediate ('CREATE TABLE xdb$moveSchemaTab (schema_url VARCHAR2(4000), 
                                schemaOwnerFrom VARCHAR2(100),
                                schemaOwnerTo VARCHAR2(100),
                                schema CLOB,
  CONSTRAINT xdb$moveSchemaTabC1 UNIQUE (schema_url, schemaOwnerFrom))
');
 EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

show errors;

