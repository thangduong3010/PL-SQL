Rem
Rem catrepv.sql
Rem
Rem Copyright (c) 2005, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catrepv.sql - XML Reporting framework View definitions
Rem
Rem    DESCRIPTION
Rem      This file contains the view definitions for the xml reporting framework
Rem      catalog
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    08/02/06 - add report and component ids to views
Rem    pbelknap    07/25/05 - Created
Rem

--------------------------------------------------------------------------------
--                            public view definitions                         --
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW REPORT_COMPONENTS
  AS SELECT c.id component_id, c.name component_name, 
            c.description component_description, 
            r.id report_id, r.name report_name, 
            r.description report_description, 
            f.name schema_filename,
            f.data schema_data
     FROM   wri$_rept_components c,
            wri$_rept_reports r,
            wri$_rept_files f
     WHERE  c.id = r.component_id AND 
            r.schema_id = f.id (+)
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_COMPONENTS FOR REPORT_COMPONENTS
/

GRANT SELECT ON REPORT_COMPONENTS TO PUBLIC
/

CREATE OR REPLACE VIEW REPORT_FILES
  AS SELECT c.id component_id,
            c.name component_name,
            f.name filename, data
     FROM   wri$_rept_components c,
            wri$_rept_files f
     WHERE  c.id (+) = f.component_id
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_FILES FOR REPORT_FILES
/

GRANT SELECT ON REPORT_FILES TO PUBLIC
/

CREATE OR REPLACE VIEW REPORT_FORMATS
  AS SELECT c.id component_id,
            c.name component_name,
            r.id report_id, 
            r.name report_name,
            fo.name format_name,
            fo.description description,
            DECODE(fo.type, 1, 'XSLT',
                            2, 'Text',
                            3, 'Custom') type,
            f.name xslt_filename,
            f.data xslt_data,
            fo.text_linesize
     FROM   wri$_rept_components c,
            wri$_rept_reports    r,
            wri$_rept_files      f,
            wri$_rept_formats    fo
     WHERE  c.id = r.component_id AND
            r.id = fo.report_id AND
            fo.stylesheet_id = f.id(+)
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_FORMATS FOR REPORT_FORMATS
/

GRANT SELECT ON REPORT_FORMATS TO PUBLIC
/

--------------------------------------------------------------------------------
--                         underscore view definitions                        --
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW "_REPORT_COMPONENT_OBJECTS"
AS SELECT c.id component_id, c.name component_name, c.object component_object
   FROM   wri$_rept_components c
/

CREATE OR REPLACE PUBLIC SYNONYM "_REPORT_COMPONENT_OBJECTS" 
FOR "_REPORT_COMPONENT_OBJECTS"
/

GRANT SELECT ON "_REPORT_COMPONENT_OBJECTS" TO PUBLIC
/

CREATE OR REPLACE VIEW "_REPORT_FORMATS"
AS SELECT c.id component_id, c.name component_name, 
          r.id report_id, r.name report_name, 
          fo.name format_name, fo.type, fo.content_type, fo.text_linesize,
          f.name xslt_filename
   FROM   wri$_rept_components c, wri$_rept_reports r, 
          wri$_rept_files f, wri$_rept_formats fo
   WHERE  c.id = r.component_id AND 
          fo.report_id = r.id  AND 
          fo.stylesheet_id = f.id (+);

CREATE OR REPLACE PUBLIC SYNONYM "_REPORT_FORMATS" FOR "_REPORT_FORMATS"
/

GRANT SELECT ON "_REPORT_FORMATS" TO PUBLIC
/
