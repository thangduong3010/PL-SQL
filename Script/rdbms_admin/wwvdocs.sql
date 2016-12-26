Rem
Rem $Header: wwvdocs.sql 29-nov-99.12:58:10 rdecker Exp $
Rem
Rem wwvdocs.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem     wwvdocs.sql - PL/SQL Gateway Document upload/download package spec
Rem                   for backward webdb 2.x compatibility     
Rem
Rem    NOTES
Rem	This file is used to implement document upload and download
Rem     features in the PL/SQL gateway for webdb listener and
Rem     application backward compatibility.  
Rem     This package acts as a wrapper around the plsql web gateway
Rem     wpg_docload package.  
Rem     wwv_docload is portable between Oracle 7 and Oracle 8.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     rdecker    01/14/00 - Created
Rem

CREATE OR replace PACKAGE wwv_docload
AS

--
-- PROCEDURE:
--   download_file
-- DESCRIPTION:
--   This should be called from within a document download procedure
--   to signal the PL/SQL Gateway that p_filename is to be downloaded
--   from the document table to the client's browser.
-- PARAMS:
--   p_filename    IN: name of the file in the document table to download  
PROCEDURE download_file(p_filename IN VARCHAR2);

--
-- Private file upload/download procedures and functions
--
-- **WARNING**
-- The following procedures are used internally by the
-- PL/SQL Gateway.  Do not call them from your PL/SQL code.
--

--
-- PROCEDURE:
--   get_download_file
-- DESCRIPTION:
--   Get the name and mime_type of the file to be downloaded
-- PARAMS:
--   p_filename      OUT: file to download
--   p_mimetype      OUT: mime type of the file to download
-- 
PROCEDURE get_download_file(p_filename OUT VARCHAR2, 
			    p_mimetype OUT VARCHAR2);

--
-- FUNCTION:
--   is_file_download
-- DESCRIPTION:
--   Is there a file to download?
-- PARAMS:
--   none
-- RETURN:
--   TRUE if there is a pending file download, FALSE otherwise.
--
FUNCTION is_file_download RETURN BOOLEAN;

-- 
-- Public parts_table type
--
TYPE parts_table IS TABLE OF VARCHAR2(256) INDEX BY binary_integer;

END wwv_docload;
/
show errors;

GRANT execute ON wwv_docload TO PUBLIC;
