Rem
Rem dbmsrep.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrep.sql - DBMS_REPORT package spec
Rem
Rem    DESCRIPTION
Rem      This file serves as the package specification for the DBMS_REPORT
Rem      package, a framework for helping server components build XML from
Rem      within the kernel.
Rem
Rem      Implementation of this package is in svrman/report/prvtrep.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    06/16/09 - remove urls
Rem    shjoshi     03/26/09 - Add setup_report_env and restore_report_env
Rem    bdagevil    11/12/08 - register common em xslt
Rem    pbelknap    07/13/06 - allow clearing of single component only 
Rem    kyagoub     07/08/06 - switch arguments of store_file 
Rem    pbelknap    04/24/06 - add drop shared directory 
Rem    pbelknap    02/08/05 - Created
Rem

-------------------------------------------------------------------------------
--                     DBMS_REPORT FUNCTION DESCRIPTIONS                     --
-------------------------------------------------------------------------------
--  Component Mapping Service functions
----------------------------------------
--  register_component: register a new component with callback to framework
--  register_report:    register a new report (view of component data), same
--                      callback as passed to register_component
--
--  get_report:         fetch a report from a framework component
--
---------------------------------------------------
--  Transformation and Validation Engine functions
---------------------------------------------------
--  create_shared_directory: setup the directory object before storing files
--  drop_shared_directory:   drop the directory object after storing files
--  store_file:              keep a file in the reporting framework
--  register_XXX_format:     create an XSLT, text, or custom output format
--  format_report:           transform an XML document to a registered format 
--  validate_report:         apply an XML schema to XML data, check for 
--                           validity
--
---------------------------------------------------
--  General Utility functions
---------------------------------------------------
--  build_report_reference_xxx: build a report_ref string helper
--  parse_report_reference:     parse a report_ref string passed to the report
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_report AUTHID CURRENT_USER IS

  --=========================================================================--
  --                           GLOBAL CONSTANTS                              --
  --=========================================================================--

  -- Content type constants (used by servlet, stored in wri$_rept_formats)
  CONTENT_TYPE_XML      CONSTANT        NUMBER := 1;  
  CONTENT_TYPE_HTML     CONSTANT        NUMBER := 2;
  CONTENT_TYPE_TEXT     CONSTANT        NUMBER := 3;
  CONTENT_TYPE_BINARY   CONSTANT        NUMBER := 4;

  -- Directory name that clients use passing for their files
  SHARED_DIRECTORY_OBJECT       CONSTANT VARCHAR2(64) := 'ORAREP_DIR';

  --=========================================================================--
  --                                 TYPES                                   --
  --=========================================================================--
  TYPE ref_string_idspec IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32767);

  -- record for storing canonical values of certain parameters we wish to
  -- set before any report is generated. These parameters influence the way
  -- data is formatted in the reports and the canonical values will ensure
  -- consistent formatting irrespective of other umbrella parameter changes
  -- We set the following parameters:
  -- NLS_NUMERIC_CHARACTERS - to control how numbers are formatted (decimal 
  --                          and group separator characters)
  -- NLS_DATE_FORMAT        - to control date format
  -- NLS_TIMESTAMP_FORMAT, NLS_TIMESTAMP_TZ_FORMAT - to control timestamp format
  TYPE format_param_value IS RECORD (
    param_num           NUMBER,
    param_value         VARCHAR2(32767)
  );

  TYPE format_param_values IS TABLE OF format_param_value;

  --=========================================================================--
  --                    COMPONENT MAPPING SERVICE FUNCTIONS                  --
  --=========================================================================--

  ------------------------------ register_component ---------------------------
  -- NAME: 
  --     register_component
  --
  -- DESCRIPTION:
  --     This procedure registers a new component with the XML reporting 
  --     framework.  It should be called at database startup from within the
  --     dbms_report_registry package.
  --
  -- PARAMETERS:
  --     component_name   (IN) - name of the component to register
  --                             (converted to lower case)
  --     component_desc   (IN) - description of the component to register
  --     component_object (IN) - object to store for this component, used for
  --                             requesting reports     
  --
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE register_component(
    component_name   IN VARCHAR2,
    component_desc   IN VARCHAR2,
    component_object IN wri$_rept_abstract_t);

  -------------------------------- register_report ----------------------------
  -- NAME: 
  --     register_report
  --
  -- DESCRIPTION:
  --     This procedure registers a report with the framework.  One components
  --     can have multiple reports but must have at least 1.  Having multiple
  --     reports is the best way for components to generate XML documents that
  --     link to each other through the <report_ref> mechanism.
  --
  -- PARAMETERS:
  --     component_name (IN)   - name of the component to register
  --     report_name    (IN)   - name of the report to register
  --                             (converted to lower case)
  --     report_desc    (IN)   - description of the report to register
  --     schema_id      (IN)   - file id of schema for this report, can be NULL
  --                             (returned from store_file)
  --
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE register_report(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    report_desc      IN VARCHAR2,
    schema_id        IN NUMBER);

  ------------- build_report_reference - vararg and structure versions --------
  -- NAME: 
  --     build_report_reference _varg/_struct - vararg and structure versions
  --
  -- DESCRIPTION:
  --     This function builds a report ref string given the necessary inputs.
  --     The report_id is given as a variable-argument list of name/value pairs,
  --     or as an instance of the ref_string_idspec type.
  --
  --     For example, to generate the reference for the string
  --     /orarep/cname/rname?foo=1AMPbar=2
  --     (substituting AMP for the ampersand in the ref string)
  --     call this function as
  --   
  --     build_report_reference_varg('cname','rname','foo','1','bar','2'); 
  --
  --     or as
  --
  --     build_report_reference_struct('cname','rname',params) where params
  --     has been initialized to hold 'foo' and 'bar'.
  --
  --     Parameter names and values are case-sensitive
  --
  -- NOTES:
  --     build_report_reference_vararg cannot be called from SQL due to a known
  --     limitation in the PL/SQL vararg implementation.  Clients can, however,
  --     create a PL/SQL non-vararg wrapper around it and call that in SQL if 
  --     they have the need.
  --
  --     The framework reserves some parameter names for internal use.  See
  --     dbms_report.get_report.
  --
  -- PARAMETERS:
  --     component_name (IN)   - name of the component for ref string
  --     report_name    (IN)   - name of the report for ref string
  --     id_param_val   (IN)   - list of parameter names and values for
  --                             the report_id portion of the string
  --
  -- RETURN:
  --     report reference string, as VARCHAR2
  -----------------------------------------------------------------------------
  FUNCTION build_report_reference_varg(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    id_param_val     ...)
  RETURN VARCHAR2;

  FUNCTION build_report_reference_struct(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    id_param_val     IN ref_string_idspec)
  RETURN VARCHAR2;

  ----------------------------- parse_report_reference ------------------------
  -- NAME: 
  --     parse_report_reference
  --
  -- DESCRIPTION:
  --     This function parses a report reference to reveal its constituent 
  --     parts.  Each one is returned as an OUT parameter, converted to lower 
  --     case.  Parameter names and values are case-sensitive.
  --
  -- PARAMETERS:
  --     report_reference (IN)   - report ref string to parse
  --     component_name   (OUT)  - name of the component for ref string
  --     report_name      (OUT)  - name of the report for ref string
  --     id_param_val     (OUT)  - parameter names and values for ref string
  --
  -- RETURN:
  --     report reference string, as VARCHAR2
  -----------------------------------------------------------------------------
  PROCEDURE parse_report_reference(
    report_reference IN  VARCHAR2,
    component_name   OUT VARCHAR2,
    report_name      OUT VARCHAR2,
    id_param_val     OUT ref_string_idspec);

  ----------------------------------- get_report ------------------------------
  -- NAME: 
  --     get_report
  --
  -- DESCRIPTION:
  --     This procedure fetches a report from its component.
  --
  -- PARAMETERS:
  --     report_reference (IN) - report_ref string to use for fetching this
  --                             report, of the form
  --                             /orarep/component/report_name?<PARAMS>.
  --
  --                             Components can build a report reference by 
  --                             calling build_report_reference, or parse one
  --                             by calling parse_report_reference.
  --  
  --                             The following parameter names are reserved and
  --                             interpreted by this function.  They will be
  --                             removed from the reference string before 
  --                             dispatching the get_report call, and applied
  --                             to the XML returned by the component.  Add
  --                             them to your ref strings to get the related
  --                             functionality.
  --
  --                               + format: maps to format name.  When 
  --                                 specified, we will apply the format before
  --                                 returning the report
  --                               + validate: y/n according to whether 
  --                                 framework should validate the xml report.
  --
  -- RETURN:
  --     report
  --
  -- NOTES:
  --     See build_report_reference comments for sample ref strings.
  -----------------------------------------------------------------------------
  FUNCTION get_report(report_reference IN VARCHAR2)
  RETURN CLOB;

  --=========================================================================--
  --                  TRANSFORMATION AND VALIDATION FUNCTIONS                --
  --=========================================================================--
  
  --------------------------- create_shared_directory -------------------------
  -- NAME: 
  --     create_shared_directory
  --
  -- DESCRIPTION:
  --     This procedure changes the location of the directory object used for
  --     loading files into the framework. See SHARED_DIRECTORY_OBJECT constant
  --     above.  This function should be called once per directory whenever 
  --     store_file will be used with the SHARED_DIRECTORY_OBJECT.
  --
  -- PARAMETERS:
  --     dirname  (IN) - directory name, under 'ORACLE_HOME/rdbms/xml/orarep/'.
  --                     Pass NULL for the parent 'orarep' directory holding 
  --                     the common schemas, xslts
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE create_shared_directory(dirname IN VARCHAR2);

  ---------------------------- drop_shared_directory --------------------------
  -- NAME: 
  --     drop_shared_directory
  --
  -- DESCRIPTION:
  --     This procedure drops the directory object used by the framework to
  --     find xslts and schemas on disk and load them into the database.  See
  --     the SHARED_DIRECTORY_OBJECT constant.  This function should be called
  --     whenever clients are done reading from the directory.
  --
  -- PARAMETERS:
  --     None.
  --
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE drop_shared_directory;

  ----------------------------------- store_file ------------------------------
  -- NAME: 
  --     store_file
  --
  -- DESCRIPTION:
  --     This function stores a file in the framework.  It should be called by
  --     the dbms_report_registry package during database creation.  File names
  --     are unique by component.
  --
  -- PARAMETERS:
  --     component_name (IN) - name of component that this file belongs to
  --                           NULL for framework-level data
  --     filename       (IN) - name of file on disk.
  --     directory      (IN) - directory object corresponding to file location,
  --                           defaults to CLIENT_DIRNAME which is shared by 
  --                           all report clients
  --
  -- RETURN:
  --     File ID generated by framework
  -----------------------------------------------------------------------------
  FUNCTION store_file(
    component_name IN VARCHAR2,
    filename       IN VARCHAR2,
    directory      IN VARCHAR2 := SHARED_DIRECTORY_OBJECT)
  RETURN NUMBER;

  ------------------------------ register_xslt_format -------------------------
  -- NAME: 
  --     register_xslt_format
  --
  -- DESCRIPTION:
  --     This function registers a format mapping for a report via XSLT.  Prior
  --     to calling this function the XSLT should have been stored in XDB by
  --     calling STORE_FILE.  After a format has been registered it can be
  --     used by calling format_report.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component that this format 
  --                                belongs to
  --     report_name         (IN) - name of report that this format belongs to
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     format_content_type (IN) - content type of format output, one of
  --                                 + CONTENT_TYPE_TEXT: plain text
  --                                 + CONTENT_TYPE_XML: xml
  --                                 + CONTENT_TYPE_HTML: html
  --                                 + CONTENT_TYPE_BINARY: other
  --     stylesheet_id       (IN) - File ID for the XSLT 
  --                                (returned by store_file)
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_xslt_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    format_content_type IN NUMBER := CONTENT_TYPE_HTML,
    stylesheet_id       IN NUMBER);

  ------------------------------ register_text_format -------------------------
  -- NAME: 
  --     register_text_format
  --
  -- DESCRIPTION:
  --     This function registers a format mapping for a text report.  Text 
  --     reports are created by first transforming an XML document to HTML
  --     using an XSLT provided by the component, and then turning the HTML to
  --     formatted text using the framework's own internal engine.  Prior
  --     to calling this function the XSLT should have been stored in XDB by
  --     calling STORE_FILE.  After a format has been registered it can be
  --     used by calling format_report.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component for this format
  --     report_name         (IN) - name of report for this format
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     html_stylesheet_id  (IN) - file id to the stylesheet that transforms
  --                                from XML to HTML (returned by store_file)
  --     text_max_linesize   (IN) - maximum linesize for text report
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_text_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    html_stylesheet_id  IN NUMBER,
    text_max_linesize   IN NUMBER := 80);

  ----------------------------- register_custom_format ------------------------
  -- NAME: 
  --     register_custom_format
  --
  -- DESCRIPTION:
  --     This function registers a custom format for an XML document. It allows
  --     components to format their document for viewing manually,by performing
  --     any kind of programmatic manipulation of the XML tree and outputting
  --     CLOB.
  --
  --     To apply custom formats, the framework will call the custom_format()
  --     member function in the object type for the component.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component for this format
  --     report_name         (IN) - name of report for this format
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     format_content_type (IN) - content type of format output, one of
  --                                 + CONTENT_TYPE_TEXT: plain text
  --                                 + CONTENT_TYPE_XML: xml
  --                                 + CONTENT_TYPE_HTML: html
  --                                 + CONTENT_TYPE_BINARY: other
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_custom_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    format_content_type IN NUMBER);

  --------------------------------- format_report -----------------------------
  -- NAME: 
  --     format_report
  --
  -- DESCRIPTION:
  --     This function transforms an XML document into another format, as
  --     declared through one of the register_xxx_format calls above.
  --
  -- PARAMETERS:
  --     report              (IN) - document to format
  --     format_name         (IN) - format name to apply
  --
  -----------------------------------------------------------------------------
  FUNCTION format_report(
    report      IN XMLTYPE,
    format_name IN VARCHAR2)
  RETURN CLOB;

  ------------------------------- validate_report -----------------------------
  -- NAME: 
  --     validate_report
  --
  -- DESCRIPTION:
  --     This procedure applies the XML schema registered with the framework
  --     corresponding to the report specified to verify that it was built
  --     correctly.
  --
  -- PARAMETERS:
  --     report  (IN) - report to validate
  --
  -- RETURN:
  --     None
  --
  -- ERRORS:
  --     Raises error 31011 if document is not valid
  -----------------------------------------------------------------------------
  PROCEDURE validate_report(report IN XMLTYPE);

  --=========================================================================--
  --                       UNDOCUMENTED  FUNCTIONS                           --
  --                       ** INTERNAL USE ONLY **                           --
  --=========================================================================--
  PROCEDURE clear_framework(component_name IN VARCHAR2 := NULL);

  FUNCTION build_generic_tag(tag_name   IN VARCHAR2,
                             tag_inputs ...)
  RETURN XMLTYPE;

  FUNCTION get_report(report_reference IN  VARCHAR2,
                      content_type     OUT NUMBER)
  RETURN CLOB;

  FUNCTION format_report(report              IN  XMLTYPE,
                         format_name         IN  VARCHAR2,
                         format_content_type OUT NUMBER)
  RETURN CLOB;

  FUNCTION transform_html_to_text(document     IN XMLTYPE,
                                  max_linesize IN POSITIVE)
  RETURN CLOB;

  ------------------------------- setup_report_env ----------------------------
  -- NAME: 
  --     setup_report_env
  --
  -- DESCRIPTION:
  --     This function sets canonical values for a few session parameters and
  --     also returns their original values as a record type. 
  --
  -- PARAMETERS:
  --
  -- RETURN:
  --     record containing original values of parameters
  ----------------------------------------------------------------------------- 
  FUNCTION setup_report_env(
   orig_env IN OUT NOCOPY format_param_values)
  RETURN BOOLEAN;

  ----------------------------- restore_report_env ----------------------------
  -- NAME: 
  --     restore_report_env
  --
  -- DESCRIPTION:
  --     This procedure reverts back the values of some session parameters based
  --     on the input value.
  --
  -- PARAMETERS:
  --      orig_env   (IN)   names and values of session parameters
  --
  -- RETURN:
  --     void
  ----------------------------------------------------------------------------- 
  PROCEDURE restore_report_env(
    orig_env IN format_param_values);

end;
/
show errors
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_REPORT FOR DBMS_REPORT
/

GRANT EXECUTE ON DBMS_REPORT TO PUBLIC
/

CREATE OR REPLACE LIBRARY DBMS_REPORT_LIB trusted as static
/
