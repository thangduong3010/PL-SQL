Rem
Rem $Header: wwvdocb.sql 19-nov-99.18:00:14 rdecker Exp $
Rem
Rem wwvdocb.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem     wwvdocb.sql - PL/SQL Gateway Document upload/download package body
Rem                   for backward webdb 2.x compatibility     
Rem
Rem    NOTES
Rem	This file is used to implement document upload and download
Rem     features in the PL/SQL gateway for webdb 2.x listener and
Rem     application backward compatibility.  
Rem     This package acts as a wrapper around the plsql web gateway
Rem     wpg_docload package.  
Rem     wwv_docload is portable between Oracle 7 and Oracle 8.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     rdecker    02/14/00 - Fixed 2.x compatibility
Rem     rdecker    01/14/00 - Created
Rem
  
CREATE OR replace PACKAGE BODY wwv_docload
AS 
  
--
-- PROCEDURE:
--   download_file
-- DESCRIPTION:
--   Set the name of the file to be downloaded in the wpg_docload package
-- PARAMS:
--   p_filename     IN: name of the file to be downloaded
--
PROCEDURE download_file(p_filename IN VARCHAR2)
IS
BEGIN
   wpg_docload.download_file(p_filename);
END download_file;

--
-- PROCEDURE:
--   get_download_file
-- DESCRIPTION:
--   This procedure is used internally by the listener to retrieve the 
--   name of the file to download.  The name is retrieved by calling the
--   wpg_docload package to retrieve the filename.
-- PARAMS:
--   p_filename          OUT: name of the file to download
--   p_mimetype          OUT: mime type of the file to download
--
PROCEDURE get_download_file(p_filename OUT VARCHAR2, p_mimetype OUT VARCHAR2)
IS
BEGIN 
   wpg_docload.get_download_file(p_filename);
   SELECT mime_type 
     INTO p_mimetype 
     FROM wwv_document
     WHERE name = p_filename;
EXCEPTION
   WHEN OTHERS THEN
     p_filename := NULL;
     p_mimetype := NULL;
END;

--
-- PROCEDURE:
--   is_file_download
-- DESCRIPTION:
--   This function is used internally by the listener to determine if
--   the application is requesting that a file be downloaded.
-- PARAMS:
--   none
FUNCTION is_file_download 
  RETURN BOOLEAN
IS
BEGIN
   RETURN wpg_docload.is_file_download;
END is_file_download;

END wwv_docload;
/
show errors
