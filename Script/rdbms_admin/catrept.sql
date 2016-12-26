Rem
Rem catrept.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catrept.sql - CATalog script server manageability REPorT framework
Rem
Rem    DESCRIPTION
Rem      Creates the base tables and types for the server manageability
Rem      report framework.  See catrepv for view defs.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bkhaladk    11/02/09 - Add xmltype for column in wri$_rept_files
Rem    rdongmin    08/15/07 - add xml report for plan diff
Rem    bdagevil    03/25/07 - add report object for SQL monitor
Rem    veeve       03/14/07 - add wri$_rept_dbreplay
Rem    kyagoub     10/05/06 - add wri$_rept_xplan
Rem    pbelknap    07/24/06 - add sqltune report object 
Rem    kyagoub     07/08/06 - add xml report for sqlpi advisor 
Rem    pbelknap    07/15/05 - Created
Rem

--------------------------------------------------------------------------------
--                              type definitions                              --
--------------------------------------------------------------------------------
CREATE OR REPLACE TYPE wri$_rept_abstract_t 
AUTHID CURRENT_USER
AS OBJECT
(
  dummy_param number,

  ----------------------------------- get_report -------------------------------
  -- NAME: 
  --     get_report
  --
  -- DESCRIPTION:
  --     All components should implement the get_report method to allow the 
  --     framework to fetch their reports.  It should accept the report 
  --     reference specifying the report they need to build, 
  --     and return the report in XML.
  --
  -- PARAMETERS:
  --     report_reference (IN) - the string identifying the report to be built.
  --                             Can be parsed by a call to 
  --                             parse_report_reference.
  --
  -- RETURN:
  --     Report built, in XML
  ------------------------------------------------------------------------------
  member function get_report(report_reference IN VARCHAR2) return xmltype,

  ------------------------------- custom_format --------------------------------
  -- NAME: 
  --     custom_format
  --
  -- DESCRIPTION:
  --     In addition to the formatting reports via XSLT or HTML-to-Text, 
  --     components can have their own custom formats.  They just need to
  --     override this function.  One component can have any number of custom
  --     formats by implementing logic around the 'format_name' argument here.
  --
  -- PARAMETERS:
  --     report_name (IN) - report name corresponding to report
  --     format_name (IN) - format name to generate
  --     report      (IN) - report to transform
  --
  -- RETURN:
  --     Transformed report, as CLOB
  ------------------------------------------------------------------------------
  member function custom_format(report_name IN VARCHAR2,
                                format_name IN VARCHAR2, 
                                report      IN XMLTYPE) return clob 
) 
not final
not instantiable
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_abstract_t FOR wri$_rept_abstract_t
/

GRANT EXECUTE ON wri$_rept_abstract_t TO PUBLIC
/

--------------------------------------------------------------------------------
--                             sequence definitions                           --
--------------------------------------------------------------------------------
------------------------------ WRI$_REPT_COMP_ID_SEQ ---------------------------
-- NAME:
--     WRI$_REPT_COMP_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_COMPONENTS
--------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_comp_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

------------------------------ WRI$_REPT_REPT_ID_SEQ ---------------------------
-- NAME:
--     WRI$_REPT_REPT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_REPORTS
--------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_rept_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

------------------------------ WRI$_REPT_FILE_ID_SEQ ---------------------------
-- NAME:
--     WRI$_REPT_FILE_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_FILES
--------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_file_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

----------------------------- WRI$_REPT_FORMAT_ID_SEQ --------------------------
-- NAME:
--     WRI$_REPT_FORMAT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_FORMATS
--------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_format_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

--------------------------------------------------------------------------------
--                              table definitions                             --
--------------------------------------------------------------------------------
-----------------------------  wri$_rept_components ----------------------------
-- NAME:
--     wri$_rept_components
--
-- DESCRIPTION: 
--     This table stores the metadata we have about report components.
--
-- PRIMARY KEY:
--     The primary key is id.     
--
--------------------------------------------------------------------------------
CREATE TABLE wri$_rept_components
(
  id          NUMBER               NOT NULL,
  name        VARCHAR2(30)         NOT NULL,
  description VARCHAR2(256),
  object      wri$_rept_abstract_t NOT NULL,
  constraint  wri$_rept_components_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_rept_components_idx_01
on wri$_rept_components(name)
tablespace SYSAUX
/

------------------------------ wri$_rept_reports -------------------------------
-- NAME:
--     wri$_rept_reports
--
-- DESCRIPTION: 
--     This table stores the metadata we have about reports.  It keeps the 
--     object which has a member function to fetch a report as well as the
--     report name and description.  A component can have multiple reports.
--
-- PRIMARY KEY:
--     The primary key is id
--
-- FOREIGN KEY:
--     COMPONENT_ID references wri$_rept_components.id
--     SCHEMA_ID references wri$_xmlr_files.id, for an XML schema.  can be NULL
--------------------------------------------------------------------------------
CREATE TABLE wri$_rept_reports
(
  id             NUMBER               NOT NULL,
  component_id   NUMBER               NOT NULL,
  name           VARCHAR2(30)         NOT NULL,
  description    VARCHAR2(256),
  schema_id      NUMBER,
  constraint wri$_rept_reports_pk primary key(id)
  using INDEX tablespace SYSAUX  
)
tablespace SYSAUX
/

create unique index wri$_rept_reports_idx_01
on wri$_rept_reports(component_id, name)
tablespace SYSAUX
/

---------------------------------- wri$_rept_files -----------------------------
-- NAME:
--     wri$_rept_files
--
-- DESCRIPTION: 
--     This table stores the files managed by the framework.  Files are in a
--     many-to-one relationship with components.
--
--     FIXME should files be stored as CLOBs?
--
-- PRIMARY KEY:
--     The primary key is id    
--
-- FOREIGN KEY:
--     COMPONENT_ID references WRI$_REPT_COMPONENT(id)
--------------------------------------------------------------------------------
CREATE TABLE wri$_rept_files
(
  id           NUMBER         NOT NULL,                 /* unique id for file */
  component_id NUMBER,                            /* null for framework files */
  name         VARCHAR2(500)  NOT NULL,        /* file name, without the path */
  data         XMLTYPE,
  constraint wri$_rept_files_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
XMLTYPE column data STORE AS CLOB
/

create unique index wri$_rept_files_idx_01 
on wri$_rept_files(component_id, name)
tablespace sysaux
/


-------------------------------- wri$_rept_formats -----------------------------
-- NAME:
--     wri$_rept_formats
--
-- DESCRIPTION: 
--     This table stores the list of output formats for a report.  Formats are 
--     in a many-to-one relationship with reports.
--
-- PRIMARY KEY:
--     The primary key is id
--
-- FOREIGN KEY:
--     REPORT_ID references WRI$_REPT_REPORTS(id)
--     STYLESHEET_ID references WRI$_REPT_FILES(id) and can be null when there
--     is no stylesheet (custom transformations only)
--------------------------------------------------------------------------------
CREATE TABLE wri$_rept_formats
(
  id              NUMBER       NOT NULL,
  report_id       NUMBER       NOT NULL,
  name            VARCHAR2(30) NOT NULL,
  description     VARCHAR2(256),
  type            NUMBER,                        /* 1: XSLT 2: Text 3: Custom */
  content_type    NUMBER,                 /* 1: xml 2: html 3: text 4: binary */
  stylesheet_id   NUMBER,
  text_linesize   NUMBER,
  constraint wri$_rept_formats_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_rept_formats_idx_01
on wri$_rept_formats(report_id, name)
tablespace SYSAUX
/

--------------------------------------------------------------------------------
--                         client sub-type definitions                        --
--------------------------------------------------------------------------------

--
-- Sqlpi advisor report subtype
--
CREATE TYPE wri$_rept_sqlpi AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype,
  overriding member function custom_format(report_name IN VARCHAR2,
                                           format_name IN VARCHAR2,
                                           report      IN XMLTYPE)
    return clob
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlpi FOR wri$_rept_sqlpi
/
GRANT EXECUTE ON wri$_rept_sqlpi TO PUBLIC
/

--
-- Sql Tuning Advisor report object
--
CREATE TYPE wri$_rept_sqlt AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlt FOR wri$_rept_sqlt
/

GRANT EXECUTE ON wri$_rept_sqlt TO PUBLIC
/

--
-- Explan plan report object
--
CREATE TYPE wri$_rept_xplan AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_xplan FOR wri$_rept_xplan
/

GRANT EXECUTE ON wri$_rept_xplan TO PUBLIC
/

--
-- DB Replay report subtype
--
CREATE TYPE wri$_rept_dbreplay AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_dbreplay FOR wri$_rept_dbreplay
/
GRANT EXECUTE ON wri$_rept_dbreplay TO PUBLIC
/

--
-- SQL Monitor report object
--
CREATE TYPE wri$_rept_sqlmonitor AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlmonitor FOR wri$_rept_sqlmonitor
/

GRANT EXECUTE ON wri$_rept_sqlmonitor TO PUBLIC
/

--
-- Sql Plan Diff report object
--
CREATE TYPE wri$_rept_plan_diff AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_plan_diff FOR wri$_rept_plan_diff
/

GRANT EXECUTE ON wri$_rept_plan_diff TO PUBLIC
/
