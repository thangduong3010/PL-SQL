Rem
Rem $Header: rdbms/admin/mgdus.sql /main/2 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdms.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdus.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/20/10 - invoker rights
Rem    hgong       06/29/06 - move raise_java_exception to internal utility 
Rem                           package 
Rem    hgong       06/01/06 - rename MGD_ID_UTL to DBMS_MGD_ID_UTL 
Rem    hgong       05/23/06 - add logging utility 
Rem    hgong       05/16/06 - map java exception to rdbms error code 
Rem    hgong       05/16/06 - rename mgd_id_meta to mgd_id_utl 
Rem    hgong       04/05/06 - mgd metadata api 
Rem    hgong       04/05/06 - Created
Rem

CREATE OR REPLACE PACKAGE DBMS_MGD_ID_UTL AUTHID CURRENT_USER AS

  ---------------------------
  --CONSTANTS
  ---------------------------
  --predelivered category ids and names
  EPC_ENCODING_CATEGORY_ID      CONSTANT BINARY_INTEGER :=1;
  EPC_ENCODING_CATEGORY_NAME    CONSTANT VARCHAR2(32)   :='EPC';

  --Logging levels
  LOGGING_LEVEL_OFF       CONSTANT INTEGER := 0;
  LOGGING_LEVEL_SEVERE    CONSTANT INTEGER := 1;
  LOGGING_LEVEL_WARNING   CONSTANT INTEGER := 2;
  LOGGING_LEVEL_INFO      CONSTANT INTEGER := 3;
  LOGGING_LEVEL_FINE      CONSTANT INTEGER := 4;
  LOGGING_LEVEL_FINER     CONSTANT INTEGER := 5;
  LOGGING_LEVEL_FINEST    CONSTANT INTEGER := 6;
  LOGGING_LEVEL_ALL       CONSTANT INTEGER := 7;

  ----------------------------
  --JAVA EXCEPTIONS
  ----------------------------
  TDTJavaException EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTJavaException, -55200); 

  TDTCategoryNotFound    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTCategoryNotFound, -55201); 

  TDTSchemeNotFound    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTSchemeNotFound, -55202); 

  TDTLevelNotFound    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTLevelNotFound, -55203); 

  TDTOptionNotFound    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTOptionNotFound, -55204); 

  TDTFieldValidationException    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTFieldValidationException, -55205); 

  TDTUndefinedField    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTUndefinedField, -55206); 

  TDTRuleEvaluationFailed    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTRuleEvaluationFailed, -55207); 

  TDTTooManyMatchingLevels    EXCEPTION;
  PRAGMA EXCEPTION_INIT(TDTTooManyMatchingLevels, -55208); 

  ----------------------------------
  --LOGGING UTILITY
  ----------------------------------
  
  /**
   *Get the logging level for tracing mgd
   *
   *Returns Integer repesenting current trace level.
   */
   FUNCTION get_plsql_logging_level RETURN INTEGER;
   PRAGMA restrict_references(get_plsql_logging_level, WNDS);
    
  /**
   *Set the logging level for tracing mgd
   *
   *Param level (IN) Set trace level
   *
   *Returns Integer repesenting current trace level.
   */  
   PROCEDURE set_plsql_logging_level(level INTEGER);
   PRAGMA restrict_references(set_plsql_logging_level, WNDS);

  /**
   * Gets java logging level
   */
  FUNCTION get_java_logging_level RETURN INTEGER;

  /**
   * Sets java logging level
   * Param loggingLevel (IN) Java logging level, which can take the following
   *                         values in descending order of severiry
   *                             LOGGING_LEVEL_SEVERE
   *                             LOGGING_LEVEL_WARNING
   *                             LOGGING_LEVEL_INFO
   *                             LOGGING_LEVEL_FINE
   *                             LOGGING_LEVEL_FINEST
   *                             LOGGING_LEVEL_OFF      ->turn off java logging
   */
  PROCEDURE set_java_logging_level(level INTEGER);

  ----------------------------------
  --PROXY UTILITY
  ----------------------------------
  /**
   * Sets the host and port of the proxy server for internet access. 
   * This function must be called if the database server accesses the
   * internet via a proxy server. Internet access is necessary because 
   * some rules need to look up the ons table to get the company prefix index.
   *
   * Param proxyHost (IN) proxy server host
   * Param proxyPort (IN) proxy port
   *
   */
  PROCEDURE set_proxy(proxyHost IN VARCHAR2, proxyPort IN VARCHAR2);
  /**
   * Unset the host and port of the proxy server
   *
   */
  PROCEDURE remove_proxy;

  ----------------------------------
  --METADATA UTILITY
  ----------------------------------

  /**
   * Returns the category id for the input category name and category version. 
   * If category version is null, then the id of latest version of the 
   * specified category will be returned.
   * 
   * Param category_name    (IN)  Category name, such as 'EPC'
   * Param category_version (IN)  Category version
   *
   */
  FUNCTION get_category_id(
                           category_name     IN   VARCHAR2,  
                           category_version  IN   VARCHAR2
                          ) RETURN VARCHAR2;
  
  /**
   * Refreshes the metadata information on the java stack for the specified 
   * category.
   *
   * If category version is null, then the id of latest version of the 
   * specified category will be returned.
   * 
   * Param category_id    (IN)  Category ID
   *
   */
  PROCEDURE refresh_category(category_id VARCHAR2);

  
  /**
   * Creates a new category, or a new version of a category.
   *
   * Param category_name    (IN) Category name, such as 'EPC'
   * Param category_version (IN) Category version
   * Param agency           (IN) The organization that owns the category.
   *                             For example, EPCGlobal owns category 'EPC'.
   * Param URI              (IN) URI that provides additional information about
   *                             the category
   *
   */
  FUNCTION create_category(category_name VARCHAR2, 
                           category_version VARCHAR2, 
                           agency VARCHAR2, 
                           URI VARCHAR2) RETURN VARCHAR2;

  /**
   * Removes a category. If version is null, all versions for this category 
   * will be removed.
   *
   * Param category_name    (IN) Category name, such as 'EPC'
   * Param category_version (IN) Category version
   *
   */
  PROCEDURE remove_category(category_name VARCHAR2, category_version VARCHAR2);

  /**
   * Removes a category including all the related tdt xml
   *
   * Param category_id    (IN) Category id
   *
   */
  PROCEDURE remove_category(category_id VARCHAR2);

  /**
   * Adds a tag data translation scheme to an existing category.
   *
   * Param category_id    (IN) Category id
   * Param tdt_xml        (IN) Tag data translation xml
   *
   */
  PROCEDURE add_scheme(category_id VARCHAR2, tdt_xml CLOB);

  /**
   * Removes a tag data translation scheme from a category.
   *
   * Param category_id    (IN) Category id
   * Param scheme_name    (IN) Scheme name
   *
   */
  PROCEDURE remove_scheme(category_id VARCHAR2, scheme_name VARCHAR2);

  /**
   * Returns Oracle tag data translation schema
   *
   */
  FUNCTION get_validator RETURN CLOB;

  /**
   * Validates the input tag data translation xml against the Oracle tag 
   * tag data translation schema
   *
   * Param xmlScheme    (IN) Tag data translation xml
   *
   */
  FUNCTION validate_scheme(xmlScheme IN CLOB) RETURN VARCHAR2;

  /**
   * Converts EPCGlobal tag data translation xml to Oracle tag data 
   * translation xml.
   *
   * Param xmlScheme    (IN) EPCGlobal tag data translation xml
   * Return                  Oracle tag data translation xml
   *
   */
  FUNCTION epc_to_oracle_scheme(xmlScheme IN CLOB) RETURN CLOB;

  /**
   * Returns a list of ';' separated scheme names for the specified category.
   *
   * Param category_id    (IN) Category id
   *
   */
  FUNCTION get_scheme_names(category_id IN VARCHAR2) 
           RETURN VARCHAR2;

  /**
   * Returns the Oracle tag data translation xml for the specified scheme.
   *
   * Param category_id    (IN) Category id
   * Param scheme_name    (IN) Scheme name, such as SGTIN-96, SSCC-64, etc.
   *
   */
  FUNCTION get_tdt_xml(category_id IN VARCHAR2,scheme_name IN VARCHAR2) 
           RETURN CLOB;

  /**
   * Returns a list of ';' separated encodings, i.e. formats, for the 
   * specified scheme.
   *
   * Param category_id    (IN) Category id
   * Param scheme_name    (IN) Scheme name, such as SGTIN-96, SSCC-64, etc.
   *
   */
  FUNCTION get_encodings(category_id IN VARCHAR2, scheme_name IN VARCHAR2) RETURN VARCHAR2;

  /**
   * Returns all relevant separated component names, separated by ';', for the 
   * specified scheme.
   *
   * Param category_id    (IN) Category id
   * Param scheme_name    (IN) Scheme name, such as SGTIN-96, SSCC-64, etc.
   *
   */
  FUNCTION get_components(category_id IN VARCHAR2, scheme_name IN VARCHAR2) RETURN VARCHAR2;

END DBMS_MGD_ID_UTL;

/
SHOW ERRORS;
/
