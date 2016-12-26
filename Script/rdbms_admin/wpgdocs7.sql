Rem
Rem $Header: wpgdoc7.sql 29-nov-99.12:58:10 rdecker Exp $
Rem
Rem wpgdoc7.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem     wpgdoc7.sql - PL/SQL Gateway Document upload/download package Spec
Rem
Rem    NOTES
Rem	This file is used to implement document upload and download
Rem     features in the PL/SQL Gateway. This version is to be used
Rem     for Oracle 7.x databases. This version does not support
Rem     the BLOB and BFILE interfaces.
Rem
Rem    **IMPORTANT**
Rem     When making changes to this file, please remember to update
Rem     the main version of this file (wpgdocs.sql) as well.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     ehlee      12/29/00 - handle 7.x databases
Rem     rdecker    08/07/00 - fix comments
Rem     kmuthukk   01/20/99 - remove BLOB/BFILE interfaces for v7 version
Rem     kmuthukk   01/20/99 - update name/comments above.
Rem     rdecker    11/29/99 - add BFILE comments
Rem     rdecker    11/18/99 - add bfile download support
Rem     rdecker    11/16/99 - blob download support
Rem     rdecker    10/13/99 - fix parts table
Rem     rdecker    10/11/99 - USE document TABLE env variable
Rem     rdecker    09/22/99 - phase 2 blob upload support
Rem     rdecker    09/14/99 - Created
Rem

Rem Creating WPG_DOCLOAD package...
CREATE OR replace PACKAGE wpg_docload
AS

-- 
-- Public types and global variables
--
TYPE parts_table IS TABLE OF VARCHAR2(256) INDEX BY binary_integer;

-- The NAME column in your document table must be the same as the
-- value of name_col_len.
name_col_len CONSTANT pls_integer := 64;

-- The MIME_TYPE column in your document table must be the same as 
-- the value of mimet_col_len.
mimet_col_len CONSTANT pls_integer := 48;

-- The name length of your document table must be less than 
-- max_doctable_name_len.
max_doctable_name_len CONSTANT pls_integer := 256;

--
-- Public file upload/download procedures and functions
--

--
-- PROCEDURE:
--   download_file
-- DESCRIPTION:
--   This should be called from within a document download procedure
--   to signal the PL/SQL Gateway that p_filename is to be downloaded
--   from the document table to the client's browser.
--   Normally, a document will be downloaded to the browser unless the
--   browser sends an 'If-Modified-Since' header to the gateway indicating
--   that it has the requested document in its cache.  In that case,
--   the gateway will determine if the browser's cached copy is up to date,
--   and if it is, it will send a 304 message to the browser indicating
--   that the browser should display the cached copy.  However, because
--   a document URL and a document do not necessarily have a one-to-one
--   relationship in the PL/SQL Web Gateway, in some cases it may be 
--   undesirable to have the cached copy of a document displayed.  In those
--   cases, the p_bcaching parameter should be set to FALSE to indicate to 
--   the gateway to ignore the 'If-Modified-Since' header, and download the
--   document.
-- PARAMS:
--   p_filename   IN: file to download from the document table.
--   p_bcaching   IN: browser caching enabled?
--
PROCEDURE download_file(p_filename IN VARCHAR2, 
			p_bcaching IN BOOLEAN DEFAULT true);

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
--   p_doc_info      OUT: encoded document information
-- 
PROCEDURE get_download_file(p_doc_info OUT VARCHAR2);
  

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
FUNCTION is_file_download 
  RETURN  BOOLEAN;
  
--
-- PROCEDURE:
--   get_content_length
-- DESCRIPTION:
--   Return the length of a lob to be downloaded.  This is only called
--   when the user hasn't already specified a predetermined content-length.
--   Because this is a v7 implementation, this will always return null.
-- PARAMS: 
--   none.
-- RETURN:
--   lob length
--
FUNCTION get_content_length
  RETURN pls_integer;

END wpg_docload;
/
show errors;




