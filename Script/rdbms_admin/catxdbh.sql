Rem
Rem $Header: catxdbh.sql 06-oct-2006.09:59:54 lbarton Exp $
Rem
Rem catxdbh.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbh.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     10/06/06 - bug 5371722: restore _kolfuseslf to prior value
Rem    spetride    08/28/06 - support access xdbconfig.xml.11.0
Rem    mrafiq      04/07/06 - cleaning up 
Rem    abagrawa    03/20/06 - Remove set echo on 
Rem    abagrawa    03/11/06 - Contains dbms_metadata_hack 
Rem    abagrawa    03/11/06 - Contains dbms_metadata_hack 
Rem    abagrawa    03/11/06 - Created
Rem

--
-- Register XML schemas for SXML docs
-- When XDK is created by catproc.sql, this code can go into
--  dbms_metadata_util.  For now we keep it here.
--
create or replace package dbms_metadata_hack authid definer as
  procedure cre_dir;
  procedure drop_dir;
  function  get_bfile(filename varchar2) return BFILE;
  procedure load_xsd(filename varchar2,
                     gentypes1 boolean := FALSE);
  procedure deleteSchema(name varchar2);

  -- above procedures assume directory is rdbms/xml/schema
  -- following procedures are needed for rdbms/xml access
  procedure cre_xml_dir;
  procedure drop_xml_dir;
  function  get_xml_bfile(filename varchar2) return BFILE;
  function  get_xml_dirname return VARCHAR2;
  
end dbms_metadata_hack;
/
show errors

create or replace type dirnamesmh as varray(2) of varchar2(2000);
/

create or replace package body dbms_metadata_hack as
--------------------------------------------------------------------
-- PACKAGE STATE
--
kolfuseslf           VARCHAR2(4000) := 'FALSE';
XML_DIR              CONSTANT BINARY_INTEGER := 1;
SCHEMA_DIR           CONSTANT BINARY_INTEGER := 2;

RDBMS_DIR  CONSTANT DIRNAMESMH := DIRNAMESMH(NULL, 'schema'); 
LOGIC_DIR  CONSTANT DIRNAMESMH := DIRNAMESMH('XMLDIR', 'XSDDIR'); 
-- XSDDIR: schema directory name
-- XMLDIR: xml doc directory name 

-- Constants defined in rdbms/include/splatform3.h
PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;
PLATFORM_OPENVMS      CONSTANT BINARY_INTEGER := 15;

---------------------------------------------------------------------
-- GET_DIR_INT: Helper function. Return the platform-
--  specific pathname for the rdbms/xml/`subdir` directory.
-- RETURNS:
--                      - directory containing XML data/schemas

  FUNCTION get_dir_int(subdir BINARY_INTEGER) RETURN VARCHAR2 IS
    -- local variables
    pfid        NUMBER;
    root        VARCHAR2(2000);
    oraroot     VARCHAR2(2000);
BEGIN
  -- get the platform id
  SELECT platform_id INTO pfid FROM v$database;

  IF pfid = PLATFORM_OPENVMS THEN
    -- ORA_ROOT is a VMS logical name
    IF (subdir = XML_DIR) THEN
      oraroot := 'ORA_ROOT:[RDBMS.XML]';
    ELSE
       oraroot := 'ORA_ROOT:[RDBMS.XML.' || RDBMS_DIR(subdir) || ']'; 
    END IF;
    RETURN oraroot;
  ELSE
    -- Get ORACLE_HOME
    DBMS_SYSTEM.GET_ENV('ORACLE_HOME', root);
    -- Return platform-specific string
    IF pfid = PLATFORM_WINDOWS32 OR pfid = PLATFORM_WINDOWS64
    THEN
      IF (subdir = XML_DIR) THEN
        oraroot := root || '\rdbms\xml';
      ELSE
        oraroot := root || '\rdbms\xml\' || RDBMS_DIR(subdir);
      END IF;
      RETURN oraroot;
    ELSE
      IF (subdir = XML_DIR) THEN
        oraroot := root || '/rdbms/xml';
      ELSE
        oraroot := root || '/rdbms/xml/' || RDBMS_DIR(subdir);
      END IF; 
      RETURN oraroot;
    END IF;
  END IF;
END;


  FUNCTION get_schema_dir RETURN VARCHAR2 IS
    oraroot VARCHAR2(2000);
BEGIN
  oraroot := get_dir_int(SCHEMA_DIR);
  RETURN oraroot;
END;


  procedure drop_dir_int(subdir BINARY_INTEGER) is
    stmt                VARCHAR2(2000);
BEGIN
  stmt := 'DROP DIRECTORY ' || LOGIC_DIR(subdir);
  EXECUTE IMMEDIATE stmt;

  -- alter session: disable use of symbolic links
  -- (restore the variable to its prior value)
  stmt := 'ALTER SESSION SET "_kolfuseslf" = ' || kolfuseslf;
  EXECUTE IMMEDIATE stmt;

END;

  procedure cre_dir_int(subdir BINARY_INTEGER) is
    -- local variables
    kolfuseslf_cnt      NUMBER := 0;
    dirpath             VARCHAR2(2000);
    stmt                VARCHAR2(2000);
BEGIN
  -- alter session: enable use of symbolic links
  -- first get the current value of _kolfuseslf (default FALSE)
  stmt := 'SELECT COUNT(*) FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
  EXECUTE IMMEDIATE stmt INTO kolfuseslf_cnt;
  IF kolfuseslf_cnt != 0 THEN
    stmt := 'SELECT VALUE FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
    EXECUTE IMMEDIATE stmt INTO kolfuseslf;
  END IF;
  stmt := 'ALTER SESSION SET "_kolfuseslf" = TRUE';
  EXECUTE IMMEDIATE stmt;

  -- get directory path
  dirpath := get_dir_int(subdir);

  -- create a directory object
  stmt := 'CREATE OR REPLACE DIRECTORY ' || LOGIC_DIR(subdir) || 
          ' AS ''' || dirpath || '''';
  EXECUTE IMMEDIATE stmt;

  EXCEPTION WHEN OTHERS THEN
    BEGIN
    drop_dir_int(subdir);
    RAISE;
    END;
END;



  procedure cre_dir is
BEGIN
   cre_dir_int(SCHEMA_DIR);
END;


  procedure drop_dir is
BEGIN
   drop_dir_int(SCHEMA_DIR);
END;


  function get_bfile(filename varchar2) return BFILE is
  begin
    return BFILENAME(LOGIC_DIR(SCHEMA_DIR), filename);
  end;
 

  procedure load_xsd(filename varchar2,
         gentypes1 boolean := FALSE) is
  ssfile              BFILE;
begin
  ssfile := BFILENAME(LOGIC_DIR(SCHEMA_DIR), filename);
  dbms_xmlschema.registerSchema(filename, ssfile,TRUE,gentypes1,FALSE, FALSE);
  EXCEPTION WHEN OTHERS THEN
    BEGIN
    ROLLBACK;
    drop_dir;
    RAISE;
    END;
end;
  procedure deleteSchema(name varchar2) is
  err_num NUMBER;
begin
  dbms_xmlschema.deleteSchema(name, dbms_xmlschema.DELETE_CASCADE_FORCE);
  EXCEPTION WHEN OTHERS THEN
    BEGIN
    -- suppress expected exception
    -- ORA-31000: Resource '<name>' is not an XDB schema document
    err_num := SQLCODE;
    IF err_num != -31000 THEN
      RAISE;
    END IF;
    END;
end;


---------------------------------------------------------------------
-- GET_XML_DIR: Helper function. Return the platform-
--  specific pathname for the rdbms/xml directory.
-- RETURNS:
--                      - directory containing XML docs

  FUNCTION get_xml_dir RETURN VARCHAR2 IS
    oraroot VARCHAR2(2000);
BEGIN
  oraroot := get_dir_int(XML_DIR);
  RETURN oraroot;
END;


  procedure drop_xml_dir is
BEGIN
  drop_dir_int(XML_DIR);
END;


  procedure cre_xml_dir is
BEGIN
   cre_dir_int(XML_DIR);
END;

  function get_xml_bfile(filename varchar2) return BFILE is
  begin
    return BFILENAME(LOGIC_DIR(XML_DIR), filename);
  end;

  function  get_xml_dirname return VARCHAR2 is
  begin
    return LOGIC_DIR(XML_DIR);
  end;

end dbms_metadata_hack;
/
show errors
