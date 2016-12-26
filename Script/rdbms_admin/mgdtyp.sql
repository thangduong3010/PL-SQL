Rem
Rem $Header: rdbms/admin/mgdtyp.sql /main/5 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdtyp.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdtyp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/21/10 - invoker rights
Rem    hgong       05/20/10 - invoker rights
Rem    hgong       07/12/06 - move internal functions to internal utility 
Rem                           package 
Rem    hgong       03/31/06 - mgd data types 
Rem    hgong       03/31/06 - Created
Rem

CREATE OR REPLACE TYPE MGD_ID_COMPONENT AS OBJECT(
                  name             VARCHAR2(256),
                  value            VARCHAR2(1024)
);                    
/
show errors;

CREATE OR REPLACE TYPE MGD_ID_COMPONENT_VARRAY IS VARRAY (128) OF MGD_ID_COMPONENT;
/
show errors;

prompt .. the MGD_ID type object
CREATE OR REPLACE TYPE MGD_ID AS OBJECT(
   category_id             VARCHAR2(256),
   components              MGD_ID_COMPONENT_VARRAY,
 
  -------------------------
  -- Constructor functions
  -------------------------
  /**
   * Constructs an MGD_ID object based on category id and a list of components.
   * 
   * Param category_id  (IN)  Category ID
   * Param components   (IN)  A list of component name value pairs
   *
   */
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_id   IN VARCHAR2,  
                       components    IN MGD_ID_COMPONENT_VARRAY) 
                          RETURN SELF AS RESULT DETERMINISTIC,
   
  /**
   * Constructs an MGD_ID object based on category id, identifier string and
   * parameter list.
   * 
   * Param category_id    (IN) Category ID
   * Param identifier     (IN) Identifier string in any format of an encoding scheme
   *                           in the specified category.
   *                           For example, for SGTIN-96 encoding, the identifier
   *                           can be in the format of BINARY, PURE_IDENTITY, 
   *                           TAG_ENCODING or LEGACY.
   * Param parameter_list  (IN) A list of ';' separated name value pairs
   *
   */
   CONSTRUCTOR FUNCTION MGD_ID(
                                category_id IN VARCHAR2, 
                                identifier IN VARCHAR2, 
                                parameter_list IN VARCHAR2) 
                                  RETURN SELF AS RESULT DETERMINISTIC,
  
  /**
   * Constructs an MGD_ID object based on category id and a list of components.
   * 
   * Param category_name    (IN)  Category name, such as 'EPC'
   * Param category_version (IN)  Category version. If null, the latest version of for the 
   *                              specified category name will be used.
   * Param components       (IN)  A list of component name value pairs
   *
   */
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_name  IN   VARCHAR2,  
                       category_version  IN   VARCHAR2,  
                       components     IN   MGD_ID_COMPONENT_VARRAY
                       ) RETURN SELF AS RESULT DETERMINISTIC,

  /**
   * Constructs an MGD_ID object based on category id, identifier string and
   * parameter list.
   * 
   * Param category_name    (IN)  Category name, such as 'EPC'
   * Param category_version (IN)  Category version. If null, the latest version of for the 
   *                              specified category name will be used.
   * Param identifier       (IN) Identifier string in any format of an encoding scheme
   *                             in the specified category.
   *                             For example, for SGTIN-96 encoding, the identifier
   *                             can be in the format of BINARY, PURE_IDENTITY, 
   *                             TAG_ENCODING or LEGACY.
   * Param parameter_list    (IN) A list of ';' separated name value pairs
   *
   */
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_name     IN   VARCHAR2,  
                       category_version  IN   VARCHAR2,
                       identifier        IN  VARCHAR2,
                       parameter_list     IN  VARCHAR2) 
                          RETURN SELF AS RESULT DETERMINISTIC,

  -------------------------
  -- MEMBER FUNCTIONS
  -------------------------

  /**
   * Returns the ';' separated component name value pairs of the MGD_ID object.
   *
   */
   MEMBER FUNCTION TO_STRING
                            RETURN VARCHAR2,

  /**
   * Returns the value of the specified component.
   * Param component_name    (IN)  Component name
   *
   */
   MEMBER FUNCTION GET_COMPONENT(component_name VARCHAR2)
                            RETURN VARCHAR2 DETERMINISTIC,

  /**
   * Returns the string representation of the MGD_ID object in the specified format.
   * Param parameter_list    (IN)  A list of additional parameters in the form of ';' 
   *                               separated name value pairs.
   * Param output_format     (IN)  Output format. For example, for SGTIN-96, the output
   *                               format can be 'BINARY', 'PURE_IDENTITY', 'TAG_ENCODING'
   *                               and 'LEGACY'.
   *
   */
   MEMBER FUNCTION FORMAT(parameter_list IN VARCHAR2,
                          output_format  IN VARCHAR2)
                            RETURN VARCHAR2 DETERMINISTIC,

  --------------------------------------------------------------------------------------
  --Convenient STATIC functions to translate between different representations directly 
  --without constructing an MGD_ID object first
  --------------------------------------------------------------------------------------

  /**
   * Converts the identifier in one format to another.
   * Param category_id      (IN)  Category ID
   * Param identifier       (IN)  Identifier string in any format of an encoding scheme
   *                              in the specified category.
   *                              For example, for SGTIN-96 encoding, the identifier
   *                              can be in the format of BINARY, PURE_IDENTITY, 
   *                              TAG_ENCODING or LEGACY.
   * Param parameter_list   (IN)  A list of additional parameters in the form of ';' 
   *                              separated name value pairs.
   * Param output_format    (IN)  Output format. For example, for SGTIN-96, the output
   *                              format can be 'BINARY', 'PURE_IDENTITY', 'TAG_ENCODING'
   *                              and 'LEGACY'.
   * Returns the string representation of the MGD_ID object in the specified format.
   *
   */
  STATIC FUNCTION TRANSLATE(
                            category_id IN VARCHAR2, 
                            identifier IN VARCHAR2, 
                            parameter_list IN VARCHAR2, 
                            output_format IN VARCHAR2)
                              RETURN VARCHAR2 DETERMINISTIC,


  /**
   * Converts the identifier in one format to another.
   * 
   * Param category_name    (IN)  Category name, such as 'EPC'
   * Param category_version (IN)  Category version. If null, the latest version of for the 
   *                              specified category name will be used.
   * Param identifier       (IN)  Identifier string in any format of an encoding scheme
   *                              in the specified category.
   *                              For example, for SGTIN-96 encoding, the identifier
   *                              can be in the format of BINARY, PURE_IDENTITY, 
   *                              TAG_ENCODING or LEGACY.
   * Param parameter_list   (IN)  A list of additional parameters in the form of ';' 
   *                              separated name value pairs.
   * Param output_format    (IN)  Output format. For example, for SGTIN-96, the output
   *                              format can be 'BINARY', 'PURE_IDENTITY', 'TAG_ENCODING'
   *                              and 'LEGACY'.
   * Returns the string representation of the MGD_ID object in the specified format.
   *
   */
  STATIC FUNCTION TRANSLATE(
                            category_name IN VARCHAR2, 
                            category_version IN VARCHAR2, 
                            identifier IN VARCHAR2, 
                            parameter_list IN VARCHAR2, 
                            output_format IN VARCHAR2)
                              RETURN VARCHAR2 DETERMINISTIC

);
/
show errors;


ALTER TYPE MGD_ID REPLACE AUTHID CURRENT_USER AS OBJECT(
   category_id             VARCHAR2(256),
   components              MGD_ID_COMPONENT_VARRAY,
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_id   IN VARCHAR2,
                       components    IN MGD_ID_COMPONENT_VARRAY)
                          RETURN SELF AS RESULT DETERMINISTIC,
   CONSTRUCTOR FUNCTION MGD_ID(
                                category_id IN VARCHAR2,
                                identifier IN VARCHAR2,
                                parameter_list IN VARCHAR2)
                                  RETURN SELF AS RESULT DETERMINISTIC,
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_name  IN   VARCHAR2,
                       category_version  IN   VARCHAR2,
                       components     IN   MGD_ID_COMPONENT_VARRAY
                       ) RETURN SELF AS RESULT DETERMINISTIC,
   CONSTRUCTOR FUNCTION MGD_ID(
                       category_name     IN   VARCHAR2,
                       category_version  IN   VARCHAR2,
                       identifier        IN  VARCHAR2,
                       parameter_list     IN  VARCHAR2)
                          RETURN SELF AS RESULT DETERMINISTIC,
   MEMBER FUNCTION TO_STRING
                            RETURN VARCHAR2,
   MEMBER FUNCTION GET_COMPONENT(component_name VARCHAR2)
                            RETURN VARCHAR2 DETERMINISTIC,
   MEMBER FUNCTION FORMAT(parameter_list IN VARCHAR2,
                          output_format  IN VARCHAR2)
                            RETURN VARCHAR2 DETERMINISTIC,
   STATIC FUNCTION TRANSLATE(
                             category_id IN VARCHAR2,
                             identifier IN VARCHAR2,
                             parameter_list IN VARCHAR2,
                             output_format IN VARCHAR2)
                               RETURN VARCHAR2 DETERMINISTIC,
   STATIC FUNCTION TRANSLATE(
                             category_name IN VARCHAR2,
                             category_version IN VARCHAR2,
                             identifier IN VARCHAR2,
                             parameter_list IN VARCHAR2,
                             output_format IN VARCHAR2)
                               RETURN VARCHAR2 DETERMINISTIC
);
/
show errors;

----------------------
-- MGD INTERNAL TYPES
----------------------
create or replace TYPE MGD$CLOBS AS TABLE of CLOB;
/
show errors;

