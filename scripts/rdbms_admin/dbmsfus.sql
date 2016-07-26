Rem
Rem $Header: dbmsfus.sql 09-may-2005.18:15:47 mlfeng Exp $
Rem
Rem dbmsfus.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsfus.sql - User Interface for the DB Feature
Rem                    Usage PL/SQL interfaces
Rem
Rem    DESCRIPTION
Rem      Implements the dbms_feature_usage package specification.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      04/26/05 - add report package
Rem    mlfeng      02/04/05 - change grant for package 
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      01/31/03 - Adding test flag, convert to binary flag
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/08/03 - Creating the package to register DB features
Rem    mlfeng      10/30/02 - Created
Rem

--
-- Note: The description of the dbms_feature_usage PL/SQL Package 
-- is located in prvtfus.sql
--


/**************************************************
 * dbms_feature_usage_report Package Specification 
 **************************************************/
CREATE OR REPLACE PACKAGE dbms_feature_usage_report AS 

  /********************************************************************
   * FUNCTIONS
   *   display_text, display_html
   *
   * DESCRIPTION 
   *   Pipelined functions that displays the DB Feature Report in 
   *   either Text or HTML format for the inputted DBID and Version.
   *
   *   For example, to generate a report on the DB Feature Usage 
   *   data for the local database ID and Version, the following 
   *   statements can be used:
   *   
   *     -- display in Text format
   *     select output from table(dbms_feature_usage_report.display_text);
   *
   *     -- display in HTML format
   *     select output from table(dbms_feature_usage_report.display_html);
   *
   * PARAMETERS
   *   l_dbid    - Database ID to display the DB Feature Usage for.
   *               If NULL, then default to the local dbid.
   *   l_version - Version to display the DB Feature Usage for.
   *               If NULL, then default to the current version.
   *   l_options - Report options, currently no options are supported
   ********************************************************************/

  /* Displays the DB Feature Report in Text format */
  FUNCTION display_text(l_dbid    IN NUMBER   DEFAULT NULL,
                        l_version IN VARCHAR2 DEFAULT NULL,
                        l_options IN NUMBER   DEFAULT 0
                       )
  RETURN awrrpt_text_type_table PIPELINED;

  /* Displays the DB Feature Report in HTML format */
  FUNCTION display_html(l_dbid    IN NUMBER   DEFAULT NULL,
                        l_version IN VARCHAR2 DEFAULT NULL,
                        l_options IN NUMBER   DEFAULT 0
                       )
  RETURN awrrpt_html_type_table PIPELINED;

END dbms_feature_usage_report;
/

SHOW ERRORS;

CREATE OR REPLACE PUBLIC SYNONYM dbms_feature_usage_report
  FOR sys.dbms_feature_usage_report
/
GRANT EXECUTE ON dbms_feature_usage_report TO dba
/
