Rem
Rem $Header: wpgdocb.sql 19-nov-99.18:00:14 rdecker Exp $
Rem
Rem wpgdocb.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem     wpgdocb.sql - PL/SQL Gateway Document upload/download package Body
Rem
Rem    NOTES
Rem     This file is used to implement document upload and download
Rem     features in the PL/SQL Gateway.
Rem    **IMPORTANT**
Rem     When making changes to this file, please remember to update
Rem     the v7 version of this file (wpgdocb7.sql) as well.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     ehlee      08/31/04 - Increase filename length to 256 (bug#3840547)
Rem     pkapasi    11/06/01 - Fix latch contention (bug#2086519). Detabify
Rem     ehlee      02/08/01 - Fix NLS download problem (bug#1584353)
Rem     ehlee      12/29/00 - Handle 8.0.x databases
Rem     gcook      12/08/00 - Fixed cache file download bug (bug#1493770)
Rem     ehlee      09/06/00 - Fix last-modified date (bug#1398250) 
Rem     ehlee      08/31/00 - Fix for freeing temporary blobs (bug#1377860)
Rem     kmuthukk   04/19/00 - schema qualify dbms_sys_sql calls since
Rem                           this package may be installed in OWA_PUBLIC.
Rem     rdecker    02/14/00 - fix for handling old listeners
Rem     kmuthukk   01/20/99 - update name/comments above.
Rem     rdecker    11/19/99 - fix null blob download bug
Rem     rdecker    11/18/99 - add bfile download support
Rem     rdecker    11/16/99 - add blob download support
Rem     rdecker    10/13/99 - fix parts table
Rem     rdecker    10/11/99 - enable/disable browser caching
Rem     rdecker    09/30/99 - http 1.1 browser caching support
Rem     rdecker    09/22/99 - phase 2 blob upload support
Rem     rdecker    09/14/99 - Created
Rem

CREATE OR replace PACKAGE BODY wpg_docload
AS 
 
  --
  -- Private types and global variables                       
  --
  -- Warning: If you change the constraint values of any of the
  -- following global variables, be sure to make the corresponding
  -- change in pgdocs.sql
  v_filename VARCHAR2(256);
  v_bcaching BOOLEAN;
  v_blob     blob;
  v_bfile    bfile;


  --
  -- PROCEDURE:
  --   download_file
  -- DESCRIPTION:
  --   Set the name of the file to be downloaded
  -- PARAMS:
  --   p_filename     IN: name of the file to be downloaded
  --   p_bcaching     IN: browser caching enabled?
  --
  PROCEDURE download_file(p_filename IN VARCHAR2, p_bcaching IN BOOLEAN)
  IS 
  BEGIN 
     v_blob := NULL;
     v_bfile := NULL;
     v_filename := p_filename;
     v_bcaching := p_bcaching;
  END download_file;
  
  --
  -- PROCEDURE:
  --   download_file
  -- DESCRIPTION:
  --   Set the blob to be downloaded
  -- PARAMS:
  --   p_filename     IN: the blob to be downloaded
  -- NOTES: Because downloading BLOBs is more of a "self-service" operation,
  --        automatic browser caching is not a feature, like it is for
  --        document table downloads, therefore, no p_bcaching parameter.
  --
  PROCEDURE download_file(p_blob IN OUT blob)
  IS 
     e_invalid_lobloc EXCEPTION;
     PRAGMA EXCEPTION_INIT(e_invalid_lobloc, -22275);
  BEGIN 
     IF (p_blob IS NULL)
     THEN
       RAISE e_invalid_lobloc;
     END IF;

     v_blob := p_blob;
     v_bfile := NULL;
     v_filename := NULL;
     v_bcaching := NULL;
  END download_file;
  
  --
  -- PROCEDURE:
  --   download_file
  -- DESCRIPTION:
  --   Set the bfile to be downloaded
  -- PARAMS:
  --   p_filename     IN: the bfile to be downloaded
  -- NOTES: Because downloading BFILEs is more of a "self-service" operation,
  --        automatic browser caching is not a feature, like it is for
  --        document table downloads, therefore, no p_bcaching parameter.
  --
  PROCEDURE download_file(p_bfile IN OUT bfile)
  IS 
     dir_alias VARCHAR2(30) := NULL;
     fname VARCHAR2(2000) := NULL;
     len pls_integer;
  BEGIN 
     dbms_lob.fileopen(p_bfile);
     v_bfile := p_bfile;
     v_blob := NULL;
     v_filename := NULL;
     v_bcaching := NULL;
  EXCEPTION
     WHEN OTHERS
     THEN
       v_bfile := NULL;
       v_blob := NULL;
       v_filename := NULL;
       v_bcaching := NULL;
       RAISE;
  END download_file;

  --
  -- FUNCTION:
  --   encode_parameter
  -- DESCRIPTION:
  --   Endcode the given parameters to be decoded by the gateway
  -- PARAMS:
  --   p_encode_param           IN: parameter to encode
  -- RETURN:
  --   encoded parameter string
  FUNCTION encode_parameter(p_encode_param IN VARCHAR2)
               RETURN VARCHAR2
  IS
     param_size pls_integer;
  BEGIN
     param_size := LENGTHB(p_encode_param);
     IF (param_size IS NULL) THEN
      param_size := 0;
     END IF;
     RETURN param_size||'X'||p_encode_param||'X';

  END encode_parameter;
  
  --
  -- PROCEDURE:
  --   get_content_length
  -- DESCRIPTION:
  --   Return the length of a lob to be downloaded
  -- PARAMS: 
  --   none.
  -- RETURN:
  --   lob length
  --
  FUNCTION get_content_length
    RETURN pls_integer
  IS 
  BEGIN
     IF (v_blob IS NOT NULL)
     THEN
        RETURN dbms_lob.getlength(v_blob);
     ELSIF (v_bfile IS NOT NULL)
        THEN
           RETURN dbms_lob.getlength(v_bfile);
        ELSE 
           RETURN NULL;
        END IF;
     END;
  
  --
  -- PROCEDURE:
  --   get_download_blob
  -- DESCRIPTION:
  --   Return a BLOB to be downloaded to a browser.
  -- PARAMS: 
  --   p_blob   OUT: The blob to be downloaded
  --
  PROCEDURE get_download_blob(p_blob OUT blob)
  IS 
  BEGIN
     p_blob := v_blob;
     v_blob := NULL;
  END;
  
    --
  -- PROCEDURE:
  --   get_download_bfile
  -- DESCRIPTION:
  --   Return a BFILE to be downloaded to a browser.
  -- PARAMS: 
  --   p_blob   OUT: The bfile to be downloaded
  --
  PROCEDURE get_download_bfile(p_bfile OUT bfile)
  IS 
  BEGIN
     p_bfile := v_bfile;
     v_bfile := NULL;
  END;

  --
  -- PROCEDURE:
  --   get_download_file
  -- DESCRIPTION:
  --   Get the name,mimetype,etc. of the file to be downloaded.
  --   For BLOB downloads, p_doc_info is just set to 'B'.
  -- PARAMS:
  --   p_doc_info  OUT: encoded string containing:
  --                    filename, last_updated,mime_type,content_type,
  --                    dad_charset and doc_size for document table docs.
  --                    For BLOB downloads, it is set to 'B'.
  --
  PROCEDURE get_download_file(p_doc_info OUT VARCHAR2)
  IS 
    e_missing_column EXCEPTION;
    PRAGMA exception_init(e_missing_column, -904);
    cursor_handle INTEGER;
    retval INTEGER;
    sql_stmt VARCHAR2(1024);
    new_cols VARCHAR2(60);
    old_cols VARCHAR2(25);
    last_updated DATE; 
    mime_type VARCHAR2(48);
    content_type VARCHAR2(128);
    dad_charset VARCHAR2(256);
    doc_size NUMBER;
    mod_date DATE;
    mod_since VARCHAR2(256);
    pos pls_integer;
    lpos pls_integer;
    mod_len pls_integer;
    last_updated_str VARCHAR2(128);
    p_doctable VARCHAR2(316);
    
  BEGIN 
    -- If we are being called by an old listener, just return the filename
    IF (owa_util.get_cgi_env('GATEWAY_IVERSION') IS NULL)
    THEN
       p_doc_info := v_filename;
       RETURN;
    END IF;

    -- For blob downloads, all we need to do is set p_doc_info to 'B'
    IF (v_blob IS NOT NULL)
    THEN
       p_doc_info := 'B';
       RETURN;
    -- For bfile downloads, p_doc_info is set to 'F'
    ELSIF (v_bfile IS NOT NULL)
    THEN
       p_doc_info := 'F';
       RETURN;
    END IF;
    
    new_cols := 'LAST_UPDATED,MIME_TYPE,CONTENT_TYPE,DAD_CHARSET,DOC_SIZE';
    old_cols := 'MIME_TYPE,DOC_SIZE';

    cursor_handle := sys.dbms_sys_sql.open_cursor;
    
    p_doctable := owa_util.get_cgi_env('DOCUMENT_TABLE');
    IF (p_doctable IS NULL) THEN
       p_doctable := 'wwv_document';
    END IF;
    
    sql_stmt := 'select '||new_cols||' from '||p_doctable||
      ' where NAME=:docname';
    sys.dbms_sys_sql.parse_as_user(cursor_handle, sql_stmt, dbms_sql.v7);

    sys.dbms_sys_sql.define_column(cursor_handle, 1, last_updated);
    sys.dbms_sys_sql.define_column(cursor_handle, 2, mime_type, 48);
    sys.dbms_sys_sql.define_column(cursor_handle, 3, content_type, 128);
    sys.dbms_sys_sql.define_column(cursor_handle, 4, dad_charset, 256);
    sys.dbms_sys_sql.define_column(cursor_handle, 5, doc_size);
    sys.dbms_sys_sql.bind_variable(cursor_handle, ':docname', v_filename);

    retval := sys.dbms_sys_sql.execute_and_fetch(cursor_handle,TRUE);

    sys.dbms_sys_sql.column_value(cursor_handle, 1, last_updated);
    sys.dbms_sys_sql.column_value(cursor_handle, 2, mime_type);
    sys.dbms_sys_sql.column_value(cursor_handle, 3, content_type);
    sys.dbms_sys_sql.column_value(cursor_handle, 4, dad_charset);
    sys.dbms_sys_sql.column_value(cursor_handle, 5, doc_size);
    
    sys.dbms_sys_sql.close_cursor(cursor_handle);
    
    -- Determine if document has been modified
    mod_since := owa_util.get_cgi_env('HTTP_IF_MODIFIED_SINCE');
    
    IF (mod_since IS NOT NULL AND v_bcaching = true) THEN 
       pos := instr(mod_since, ';');
       IF (pos > 0) THEN 
          lpos := instr(substr(mod_since,pos), 'length=');
          IF (lpos > 0) THEN 
            mod_len := substr(mod_since,lpos+pos+6);
          END IF; 
          mod_since := substr(mod_since,1,pos-1);
       END IF;

       BEGIN
          mod_date := to_date(mod_since, 'Dy, DD Mon YYYY HH24:MI:SS "GMT"');
       EXCEPTION 
          WHEN OTHERS THEN 
          BEGIN 
             mod_date := to_date(mod_since, 'Day, DD-Mon-YY HH24:MI:SS "GMT"');
          EXCEPTION
             WHEN OTHERS THEN 
             BEGIN
                mod_date := to_date(mod_since, 'Day Mon DD HH24:MI:SS YYYY');
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;
          END;
       END;
  
       IF (mod_date = last_updated) THEN
         IF (mod_len IS NULL OR mod_len = doc_size) THEN
            last_updated_str := 'NOT_MODIFIED';
         ELSE
            last_updated_str := to_char(last_updated,
                'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
                'NLS_DATE_LANGUAGE = American');
         END IF;
       ELSE
         last_updated_str := to_char(last_updated,
            'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
            'NLS_DATE_LANGUAGE = American');
       END IF;
    ELSE 
       IF (v_bcaching = TRUE) THEN
         last_updated_str := to_char(last_updated,
             'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
             'NLS_DATE_LANGUAGE = American');
       ELSE
         last_updated_str := NULL;
       END IF;
    END IF;
    

    -- Set the doc_info string
    p_doc_info := encode_parameter(v_filename);
    p_doc_info := p_doc_info||encode_parameter(last_updated_str);
    p_doc_info := p_doc_info||encode_parameter(mime_type);
    p_doc_info := p_doc_info||encode_parameter(content_type);
    p_doc_info := p_doc_info||encode_parameter(dad_charset);
    p_doc_info := p_doc_info||encode_parameter(doc_size);
    
    -- Clear the filename
    v_filename := NULL;

  EXCEPTION
     -- looks like we have an old style document table
     WHEN e_missing_column THEN
       last_updated := NULL;
       content_type := NULL;
       dad_charset := NULL;

       sql_stmt := 'select '||old_cols||' from '||p_doctable||
           ' where NAME=:docname';
       sys.dbms_sys_sql.parse_as_user(cursor_handle, sql_stmt, dbms_sql.v7);

       sys.dbms_sys_sql.define_column(cursor_handle, 1, mime_type, 48);
       sys.dbms_sys_sql.define_column(cursor_handle, 2, doc_size);
       sys.dbms_sys_sql.bind_variable(cursor_handle, ':docname', v_filename);

       retval := sys.dbms_sys_sql.execute_and_fetch(cursor_handle,TRUE);
       sys.dbms_sys_sql.column_value(cursor_handle, 1, mime_type);
       sys.dbms_sys_sql.column_value(cursor_handle, 2, doc_size);
    
       sys.dbms_sys_sql.close_cursor(cursor_handle);
       
       -- Set the doc_info string
       p_doc_info := encode_parameter(v_filename);
       p_doc_info := p_doc_info||encode_parameter(last_updated);
       p_doc_info := p_doc_info||encode_parameter(mime_type);
       p_doc_info := p_doc_info||encode_parameter(content_type);
       p_doc_info := p_doc_info||encode_parameter(dad_charset);
       p_doc_info := p_doc_info||encode_parameter(doc_size);
    
       -- Clear the filename
       v_filename := NULL;

     WHEN OTHERS THEN
      v_filename := NULL;
      p_doc_info := NULL;
      sys.dbms_sys_sql.close_cursor(cursor_handle);

  END get_download_file;

  --
  -- FUNCTION:
  --   is_file_download
  -- DESCRIPTION:
  --   Is there a file to download?
  -- PARAMS:
  --   none.
  -- RETURNS:
  --   TRUE if there is a pending file download, FALSE otherwise.
  --
  FUNCTION is_file_download 
    RETURN  BOOLEAN 
  IS 
  BEGIN 
     RETURN v_filename IS NOT NULL OR v_blob IS NOT NULL OR
       v_bfile IS NOT NULL;
  END is_file_download;

END wpg_docload;
/

show errors
