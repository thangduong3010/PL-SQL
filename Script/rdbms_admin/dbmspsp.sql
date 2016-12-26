REM  Copyright (c) 1999 by Oracle Corporation
REM    NAME
REM      dbmspsp.sql - PL/SQL package of utility routines for the compilation
REM                    of PL/SQL Server Pages (PSP).
REM
REM    DESCRIPTION
REM      Routines to compile PSP pages.
REM
REM    NOTES
REM      The procedural option is needed to use this package.
REM      This package must be created under SYS.
REM
REM    MODIFIED   (MM/DD/YY)
REM    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
REM    rpang       10/25/99 - Renamed parameter from "remove_old" to "replace"
REM    rpang       08/11/99 - Combined all API in one package
REM    rpang       08/10/99 - Added API for loadpsp
REM    rpang       07/22/99 - Added line number reporting in parse error
REM    rpang       07/21/99 - Fixed include directive semantics
REM    rpang       04/27/99 - created

CREATE OR REPLACE PACKAGE dbms_psp IS

   /*
    * Constants and Types
    */
   -- PSP text content buffer
   TEXT_SIZE CONSTANT PLS_INTEGER := 2000;
   TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

   -- PSP page name and PL/SQL procedure name table
   NAME_SIZE CONSTANT PLS_INTEGER := 256;
   TYPE name_table IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

   -- Page length table
   TYPE length_table IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;

   -- Page compilation error info
   TYPE page_error IS RECORD (
     name      VARCHAR2(256),  -- name of PSP page that causes the error
     line      PLS_INTEGER,    -- line where the error occurs
     position  PLS_INTEGER,    -- position where the error occurs
     text      VARCHAR2(4000)  -- the error message
   );
   TYPE page_errors IS TABLE OF page_error INDEX BY BINARY_INTEGER;

   /**********************************************************************
    * API to specify sources of PSP pages:
    *
    * PSP pages may exist in two different sources.  They may either
    * be stored in a document table or they may be stored temporarily
    * in memory.  When this package is invoked to compile a PSP page into
    * a PL/SQL stored procedure, it tries to locate the specified page
    * from those that has been stored in memory.  If it cannot be found,
    * the package will then look for page from the document table.
    *
    * The package assumes the name of the document table (or view),
    * name of the document name and content columns.  The structure of
    * the document table (or view) looks like this in the caller's schema:
    *
    *   TABLE wwv_document (
    *     ...
    *     name     VARCHAR2(xxx),
    *     content  LONG RAW,
    *     ...);
    *
    * If the name of the table (or view) or the columns are different,
    * use the API set_docuemnt_table() to change it.  This has to
    * be called in every database session as this package does not keep
    * the new settings permenantly.
    *
    * To add PSP pages in memory temporarily, use the API add_in_memory_page()
    * or add_in_memory_pages().  Use clear_in_memory_pages() to remove the
    * pages in memory to free up resources.
    */

   /*------------------------ set_document_table -------------------------
    * NAME
    *   set_docuemnt_table
    * DESCRIPTION
    *   Sets the document table information.  DBMS_PSP locates PSP pages
    *   from the document table as specified.  This API has to be called in
    *   every database session as this package does not keep the new
    *   settings permenantly.
    * PARAMETER
    *   doc_table    - name of document table
    *   name_col     - name of column that specifies the document name
    *   content_col  - name of column that stores the document content
    * RETURNS
    *   None
    */
   PROCEDURE set_document_table(doc_table   IN VARCHAR2 DEFAULT 'wwv_document',
                                name_col    IN VARCHAR2 DEFAULT 'name',
                                content_col IN VARCHAR2 DEFAULT 'content');

   /*------------------------ add_in_memory_page ------------------------
    * NAME
    *   add_in_memory_page
    * DESCRIPTION
    *   Add a PSP page in memory.  DBMS_PSP locates a PSP page from its
    *   memory.  If the page is not found, it looks for the page in the
    *   document table.  The page added will be kept in memory until
    *   clear_in_memory_pages() is called, or the database session ends.
    * NOTE
    *   A page added by this API overrides pages with the same name added
    *   by this API or in the document table.
    * PARAMETER
    *   name    - name of the PSP page
    *   content - content of the page
    * RETURNS
    *   None
    */
   PROCEDURE add_in_memory_page(name     IN VARCHAR2,
                                content  IN text_table);

   /*------------------------ add_in_memory_pages -----------------------
    * NAME
    *   add_in_memory_pages
    * DESCRIPTION
    *   Add multiple PSP pages in memory.  DBMS_PSP locates a PSP page from its
    *   memory.  If the page is not found, it looks for the page in the
    *   document table.  The pages added will be kept in memory until
    *   clear_in_memory_pages() is called, or the database session ends.
    * NOTE
    *   Pages added by this API override pages with the same name added
    *   by this API or in the document table.
    * PARAMETER
    *   names    - names of the PSP pages
    *   contents - contents of the page
    *   lengths  - length of each page as specified by the no. of rows
    *              each page spans in "contents".  The pages are assumed
    *              to appear in the same order in "names", "contents"
    *              (taking into account that a page may span multiple rows)
    *              and "lengths"
    * RETURNS
    *   None
    */
   PROCEDURE add_in_memory_pages(names     IN name_table,
                                 contents  IN text_table,
                                 lengths   IN length_table);

   /*------------------------ clear_in_memory_pages ---------------------
    * NAME
    *   clear_in_memory_pages
    * DESCRIPTION
    *   Clears all PSP pages in memory.
    * PARAMETER
    *   None
    * RETURNS
    *   None
    */
   PROCEDURE clear_in_memory_pages;

   /**********************************************************************
    * API to compile PSP pages:
    *
    * In order to compile a PSP page, the page must have been stored
    * in the document table or added in memory with the API above.
    */

   /*---------------------------- compile_page ---------------------------
    * NAME
    *   compile_page
    * DESCRIPTION
    *   Compiles a PSP page to a PL/SQL stored procedure
    * PARAMETER
    *   name        - name of the page to compile
    *   errors      - errors produced during compilation
    *   replace_old - should the PL/SQL stored procedure be created
    *                 "CREATE OR REPLACE" that replaces the old procedure
    * RETURNS
    *   the name of the PL/SQL stored procedure generated for this PSP page
    */
   FUNCTION compile_page(name        IN  VARCHAR2,
                         errors      OUT page_errors,
                         replace     IN  BOOLEAN     DEFAULT FALSE)
                         RETURN VARCHAR2;

   /*---------------------------- compile_pages --------------------------
    * NAME
    *   compile_pages
    * DESCRIPTION
    *   Compiles multiple PSP pages to PL/SQL stored procedures
    * PARAMETER
    *   names       - names of the pages to compile
    *   errors      - errors produced during compilation
    *   replace     - should the PL/SQL stored procedures be created
    *                 "CREATE OR REPLACE" that replace the old procedures
    * RETURNS
    *   the names of the PL/SQL stored procedures generated for the PSP pages
    */
   FUNCTION compile_pages(names       IN  name_table,
                          errors      OUT page_errors,
                          replace     IN  BOOLEAN     DEFAULT FALSE)
                          RETURN name_table;

   /***********************************************************************
    * Private API:
    *
    * The following API are intended to be used solely by loadpsp utility.
    */

   /*---------------------------- compile_page ----------------------------
    * NAME
    *   compile_page
    * DESCRIPTION
    *   Compile a PSP page to a PL/SQL stored procedure while keeping
    *   the page in memory.
    * PARAMETER
    *   name        - name of the page
    *   content     - content of the page
    *   replace_old - should the PL/SQL stored procedure be created
    *                 "CREATE OR REPLACE" that replaces the old procedure
    *   is_error    - is the message return an error message?
    * RETURNS
    *   a message indicated the page is processed, or an error message if
    *   error occurs.
    */
   FUNCTION compile_page(name        IN  VARCHAR2,
                         content     IN  text_table,
                         replace     IN  PLS_INTEGER,
                         is_error    OUT PLS_INTEGER)
                         RETURN VARCHAR2;

   /*---------------------------- compile_page ----------------------------
    * NAME
    *   compile_page
    * DESCRIPTION
    *   Compile a PSP page to a PL/SQL stored procedure.
    * PARAMETER
    *   name        - name of the page
    *   replace     - should the PL/SQL stored procedure be created
    *                 "CREATE OR REPLACE" that replaces the old procedure
    *   is_error    - is the message return an error message?
    * RETURNS
    *   a message indicated the page is processed, or an error message if
    *   error occurs.
    */
   FUNCTION compile_page(name        IN  VARCHAR2,
                         replace     IN  BOOLEAN,
                         is_error    OUT BOOLEAN)
                         RETURN VARCHAR2;

END;
/

GRANT EXECUTE ON sys.dbms_psp TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dbms_psp FOR sys.dbms_psp;
