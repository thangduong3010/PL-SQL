rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubutil.sql - package of various OWA utility procedures
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_util    - Utitility procedures/functions for use
Rem                       with the Oracle Web Agent
Rem
Rem    NOTES
Rem      The Oracle Web Agent is needed to use these facilities.
Rem      The package owa is needed to use these facilities.
Rem      The packages htp and htf are needed to use these facilities.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     ehlee      10/12/01 -  Move version string out of this spec
Rem     pkapasi    09/21/01 -  Version 3.0.0.0.7
Rem     ehlee      07/11/01 -  Version 3.0.0.0.6
Rem     pkapasi    06/15/01 -  Version 3.0.0.0.5
Rem     ehlee      02/21/01 -  Version 3.0.0.0.4
Rem     ehlee      01/24/01 -  Version 3.0.0.0.3
Rem     ehlee      01/23/01 -  Version 3.0.0.0.2 string correction
Rem     ehlee      12/29/00 -  Version 3.0.0.0.2
Rem     ehlee      10/09/00 -  Version 3.0.0.0.1
Rem     ehlee      09/15/00 -  Fix bug#1401472 (add version number)
Rem     ehlee      06/28/00 -  Increase vc_arr varchar2 size from 2000 to 32000
Rem     ehlee      01/14/00 -  Add default charset support
Rem     rdasarat   10/26/98 -  Fix 735061
Rem     rdasarat   12/02/97 -  Fix 591932
Rem     rdasarat   10/17/97 -  Add ccharset to mime_header
Rem     rdasarat   07/09/97 -  Implement COMMON schema; optimize code
Rem     mpal       11/12/96 -  Fix bug#412612 change default for nrow_max to 500
Rem     rpang      01/27/97 -  Restored PRAGMA RESTRICT_REFERENCES (bug#439474)
Rem     rpang      06/29/96 -  Added IP_ADDRESS type, get_procedure
Rem     mpal	   06/24/96 -  Add new utilities for 2.1
Rem     mbookman   03/04/96 -  Assert purity of get_cgi_env
Rem     mbookman   01/24/96 -  Add "bclose_header" field to HTTP header calls
Rem     mbookman   01/24/96 -  Remove HTTP_HEADER_OPEN
Rem     mbookman   01/12/96 -  Add REDIRECT_URL and STATUS_LINE
Rem     mbookman   12/13/95 -  Add HTTP_HEADER_OPEN, HTTP_HEADER_CLOSE
Rem     mbookman   07/09/95 -  Creation

REM Creating OWA_UTIL package...
create or replace package OWA_UTIL is

   type ident_arr is table of varchar2(30) index by binary_integer;
   type num_arr is table of number index by binary_integer;
   type ip_address is table of integer index by binary_integer;

   type vc_arr is table of varchar2(32000) index by binary_integer;

   -- Functions/Procedures
   procedure name_resolve(
      cname in varchar2,
      o_procowner out varchar2,
      o_procname out varchar2
   );

     /******************************************************************/
    /* Procedure to link back to the PL/SQL source for your procedure */
   /******************************************************************/
    /* SHOWSOURCE can take as an argument a procedure, function,     */
    /*   package, package.procedure or package.function.             */
    /* SHOWSOURCE prints the source for the specified stored PL/SQL. */
    /* If package.procedure or package.function are passed, it will  */
    /* print the entire package.                                     */
   procedure showsource(cname in varchar2);

     /**************************************************/
    /* Procedures for printing out an OWA "signature" */
   /**************************************************/
    /* SIGNATURE prints an HTML line followed by a line like:               */
    /*   This page was produced by the Oracle Web Agent on 09/07/95 09:39   */
   procedure signature;

    /* SIGNATURE (cname) prints an HTML line followed by 2 lines like:      */
    /*   This page was produced by the Oracle Web Agent on August 9, 1995
         9:39 AM                                                            */
    /*   View PL/SQL source code (hypertext-link)                           */
    /* SIGNATURE can take as an argument a procedure, function, or package, */
    /*   but not package.procedure or package.function.  See SHOWSOURCE.    */
   procedure signature(cname in varchar2);

      /******************************************************/
     /* Procedure for printing a page generated by htp/htf */
    /* in SQL*Plus or SQL*DBA                             */
   /******************************************************/
    /* SHOWPAGE can be called to print out the results, */
    /* in SQL*Plus or SQL*DBA, of an htp/htf generated  */
    /* page. This is done using dbms_output, and thus   */
    /* is limited to 255 characters per line and an     */
    /* overall buffer size of 1,000,000 bytes.          */
   procedure showpage;

     /**************************************************************/
    /* Procedure/function for accessing CGI environment variables */
   /**************************************************************/
   /* GET_CGI_ENV will return the value of the requested CGI     */
   /* environment variable, or NULL if that value is not set.    */
   function  get_cgi_env(param_name in varchar2) return varchar2;

   /* PRINT_CGI_ENV will print all of the CGI environment        */
   /* variables which OWA has made available to PL/SQL.          */
   procedure print_cgi_env;

   /* MIME_HEADER will output "Content-type: <ccontent_type>\n\n" */
   /* This allows changing the default MIME header which the Web  */
   /* Agent returns.  This MUST be come before any htp.print or   */
   /* htp.prn calls in order to signal the Web Agent not to use   */
   /* the default.                                                */
   procedure mime_header(ccontent_type in varchar2 DEFAULT 'text/html',
                         bclose_header in boolean  DEFAULT TRUE,
			 ccharset      in varchar2 DEFAULT 'MaGiC_KeY');

   /* REDIRECT_URL will output "Location: <curl>\n\n"               */
   /* This allows the PL/SQL program to tell the HTTP server to     */
   /* visit the specified URL instead of returning output from the  */
   /* current URL.  By "visit" it is meant that if the specified    */
   /* URL is an HTML page, then it will be returned, but if the URL */
   /* specifies another CGI program, or call to the Web Agent, then */
   /* the Web Server will make that call.                           */
   /* The call to REDIRECT_URL MUST be come before any htp calls in */
   /* order to signal the HTTP server to do the redirect.           */
   /* This functionality is only available with OWA 1.0.2 or above. */
   procedure redirect_url(curl          in varchar2,
                          bclose_header in boolean  DEFAULT TRUE);
 
   /* STATUS_LINE will output "Status: <nstatus> <creason>\n\n"     */
   /* This allows the PL/SQL program to tell the HTTP server to     */
   /* return a standard HTTP status code to the client.             */
   /* The call to STATUS_LINE MUST be come before any htp calls in  */
   /* order to signal the HTTP server to return the status as part  */
   /* of the HTTP header instead of as "content data".              */
   /* This functionality is only available with OWA 1.5 or above.   */
   procedure status_line(nstatus in integer,
			 creason in varchar2 DEFAULT NULL,
                         bclose_header in boolean  DEFAULT TRUE);

   /* HTTP_HEADER_CLOSE should be called after calls to either       */
   /* MIME_HEADER, REDIRECT_URL, or STATUS_LINE, where bclose_header */
   /* is set to FALSE.  HTTP_HEADER_CLOSE will close the HTTP header */
   procedure http_header_close;

   /* GET_OWA_SERVICE_PATH returns the name of the currently           */
   /* with its full virtual path, plus the currently active service    */
   /*  For example, a call to get_owa_service_path could return:       */
   /*     /ows-bin/myservice/owa/                                      */
   function get_owa_service_path return varchar2;

     /******************************************************************/
    /* Procedures and functions for building HTML and non-HTML tables */
   /******************************************************************/

   /* TABLE_TYPE constants */
   HTML_TABLE constant integer := 1;
   PRE_TABLE  constant integer := 2;

   procedure show_query_columns(ctable in varchar2);

   /* TABLEPRINT will print out an entire Oracle table either as   */
   /* an HTML table, or as a "pre-formatted" table.  The table     */
   /* alignment follows the HTML 3.0 current standards for default */
   /* alignment - column headings are CENTERED while table data is */
   /* LEFT justified.                                              */
   /*                                                              */
   /* TABLEPRINT takes the following parameters:                   */
   /*                                                              */
   /* ctable       - the table, view, or synonym name              */
   /* cattributes  - allows you to pass any of the attributes that */
   /*                can be passed to the HTML <TABLE> tag.        */
   /* ntable_type  - HTML_TABLE or PRE_TABLE                       */
   /* ccolumns     - a comma-delimited list of columns from ctable */
   /* cclauses     - any SQL "where" or "order by clauses",        */
   /*  for example : "where deptno = 10"                           */
   /*                "where deptno = 10 order by ename"            */
   /*                "order by deptno"                             */
   /* ccol_aliases - a comma-delimited list of column headings     */
   /* nrow_min     - the first row, of those fetched, to print     */
   /* nrow_max     - the last row, of those fetched, to print      */
   /*                                                              */
   /* Note that RAW COLUMNS are supported, however LONG RAW        */
   /*  are not.  References to LONG RAW columns will print the     */
   /*  result 'Not Printable'.                                     */
   function tablePrint(ctable       in varchar2,
                       cattributes  in varchar2 DEFAULT NULL,
                       ntable_type  in integer  DEFAULT HTML_TABLE,
                       ccolumns     in varchar2 DEFAULT '*',
                       cclauses     in varchar2 DEFAULT NULL,
                       ccol_aliases in varchar2 DEFAULT NULL,
                       nrow_min     in number DEFAULT 0,
                       nrow_max     in number DEFAULT 500) return boolean;

   /* Lower-level routines for printing out the table */
   procedure comma_to_ident_arr(list    in varchar2,
                                arr    out ident_arr,
                                arrlen out integer);

   procedure tableOpen(cattributes in varchar2 DEFAULT NULL,
                       ntable_type in integer DEFAULT HTML_TABLE);

   procedure tableCaption(ccaption    in varchar2,
                          calign      in varchar2 DEFAULT 'CENTER',
                          ntable_type in integer  DEFAULT HTML_TABLE);

   procedure tableHeaderRowOpen(crowstring  in out varchar2,
                                ntable_type in     integer DEFAULT HTML_TABLE);

   procedure tableHeaderRowOpen(crowstring   in out varchar2,
                                ntable_width    out integer,
                                ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableHeader(ccolumn_name in     varchar2,
                         ncolumn_size in     integer,
                         calign       in     varchar2 DEFAULT 'CENTER',
                         crowstring   in out varchar2,
                         ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableHeader(ccolumn_name in     varchar2,
                         ncolumn_size in     integer,
                         calign       in     varchar2 DEFAULT 'CENTER',
                         crowstring   in out varchar2,
                         ntable_width in out integer,
                         ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableHeaderRowClose(crowstring  in out varchar2,
                                 ntable_type in     integer DEFAULT HTML_TABLE);

   procedure tableHeaderRowClose(crowstring   in out varchar2,
                                 ntable_width in     integer,
                                 ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableRowOpen(crowstring  in out varchar2,
                          ntable_type in     integer DEFAULT HTML_TABLE);

   procedure tableData(cdata        in     varchar2,
                       ncolumn_size in     integer,
                       calign       in     varchar2 DEFAULT 'LEFT',
                       crowstring   in out varchar2,
                       ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableNoData(calign       in     varchar2 DEFAULT 'LEFT',
                         crowstring   in out varchar2,
                         nnum_cols    in     integer,
                         ntable_width in     integer,
                         ntable_type  in     integer DEFAULT HTML_TABLE);

   procedure tableRowClose(crowstring  in out varchar2,
                           ntable_type in     integer DEFAULT HTML_TABLE);

   procedure tableClose(ntable_type in     integer DEFAULT HTML_TABLE);

   procedure tableClose(ntable_width in integer,
                        ntable_type  in integer DEFAULT HTML_TABLE);


   procedure resolve_table(cobject in varchar2,
                           cschema in varchar2,
                           resolved_name    out varchar2,
                           resolved_owner   out varchar2,
                           resolved_db_link out varchar2);

   /* DESCRIBE_COLS returns the column_names and datatypes as */
   /* arrays for passing to calc_col_sizes                    */
   procedure describe_cols(
                           ctable       in varchar2,
                           ccolumns     in varchar2,
                           col_names   out ident_arr,
                           col_dtypes  out ident_arr,
                           nnum_cols   out integer);

   
     /**********************************************************************/
    /* Function to obtain the procedure being invoked by the PL/SQL Agent */
   /**********************************************************************/
   function get_procedure return varchar2;

   PRAGMA RESTRICT_REFERENCES(get_cgi_env, WNDS, WNPS, RNDS);


     /******************************************************************/
    /* Procedures and functions for new utilities for 2.1             */
   /******************************************************************/

   	/* Exception raised when a query fails to be parsed of when a 	*/
   	/* non SELECT statement is passed down						 	*/
    INVALID_QUERY    exception;


	/* Utility routine used to figure out who called you.  Can be 	*/
	/* used in standard footer routine.  							*/
    procedure who_called_me( owner      out varchar2,
                              name       out varchar2,
                              lineno     out number,
                              caller_t   out varchar2 );


	/* Ite = Macro for If then Else									*/
	/* only for internal usage. Not exposed 						*/
    function ite( tf in boolean, yes in varchar2, no in varchar2 )
     return varchar2;
 
	/* shorthand for owa_util.get_cgi_env( 'SCRIPT_NAME' );			*/
	/* only for internal usage. Not exposed 						*/
    function path_to_me return varchar2;

	/* This prepares a sql query and binds  variables to it   		*/
    function bind_variables
     ( theQuery in varchar2,
       bv1Name  in varchar2 default NULL, bv1Value in varchar2 default NULL,
       bv2Name  in varchar2 default NULL, bv2Value in varchar2 default NULL,
       bv3Name  in varchar2 default NULL, bv3Value in varchar2 default NULL,
       bv4Name  in varchar2 default NULL, bv4Value in varchar2 default NULL,
       bv5Name  in varchar2 default NULL, bv5Value in varchar2 default NULL,
       bv6Name  in varchar2 default NULL, bv6Value in varchar2 default NULL,
       bv7Name  in varchar2 default NULL, bv7Value in varchar2 default NULL,
       bv8Name  in varchar2 default NULL, bv8Value in varchar2 default NULL,
       bv9Name  in varchar2 default NULL, bv9Value in varchar2 default NULL,
       bv10Name  in varchar2 default NULL, bv10Value in varchar2 default NULL,
       bv11Name  in varchar2 default NULL, bv11Value in varchar2 default NULL,
       bv12Name  in varchar2 default NULL, bv12Value in varchar2 default NULL,
       bv13Name  in varchar2 default NULL, bv13Value in varchar2 default NULL,
       bv14Name  in varchar2 default NULL, bv14Value in varchar2 default NULL,
       bv15Name  in varchar2 default NULL, bv15Value in varchar2 default NULL,
       bv16Name  in varchar2 default NULL, bv16Value in varchar2 default NULL,
       bv17Name  in varchar2 default NULL, bv17Value in varchar2 default NULL,
       bv18Name  in varchar2 default NULL, bv18Value in varchar2 default NULL,
       bv19Name  in varchar2 default NULL, bv19Value in varchar2 default NULL,
       bv20Name  in varchar2 default NULL, bv20Value in varchar2 default NULL,
       bv21Name  in varchar2 default NULL, bv21Value in varchar2 default NULL,
       bv22Name  in varchar2 default NULL, bv22Value in varchar2 default NULL,
       bv23Name  in varchar2 default NULL, bv23Value in varchar2 default NULL,
       bv24Name  in varchar2 default NULL, bv24Value in varchar2 default NULL,
       bv25Name  in varchar2 default NULL, bv25Value in varchar2 default NULL )
     return integer;
 
 
 	/* Many forms of cellsprint.  First parm is always a query or	    */
	/* an open cursor (from owa_util.bind_variables above).	 	    */
	/* use max_rows to limit the number of rows displayed (default 100) */
	/* set p_format_numbers to any NON-NULL value to have any field	    */ 
	/* that is an oracle number right justified with commas and rounded */ 
	/* off to 2 decimal places (if it has decimals)			    */
 
     procedure cellsprint( p_colCnt         in integer,
                           p_resultTbl      in vc_arr,
                           p_format_numbers in varchar2 default NULL);
 
     procedure cellsprint( p_theQuery                in varchar2,
                                 p_max_rows          in number default 100,
                                 p_format_numbers    in varchar2 default NULL );
     
     procedure cellsprint( p_theCursor               in integer, 
                                 p_max_rows          in number  default 100,
                                 p_format_numbers    in varchar2 default NULL );

	/* More involved cellsprint allows you to slice and dice a 	    */
	/* result set.  Can be used to page up and down thru queries.  In   */	
	/* addition to the above you can tell it what row to start printing */
	/* at (eg: skip the first 25 records and then print the next 25     */
	/* records) and it will tell you. if there are more rows to print.  */
	/* You would save the offset within the query in a hidden field to  */ 
	/* paginate.							    */
     procedure cellsprint( p_theQuery                in varchar2,
                                 p_max_rows          in number default 100,
                                 p_format_numbers    in varchar2 default NULL,
                                 p_skip_rec          in number default 0,
                                 p_more_data        out boolean );
     
     procedure cellsprint( p_theCursor               in integer, 
                                 p_max_rows          in number  default 100,
                                 p_format_numbers    in varchar2 default NULL, 
                                 p_skip_rec          in number default 0,
                                 p_more_data        out boolean );
 
     procedure cellsprint( p_theQuery                in varchar2,
                                 p_max_rows          in number default 100,
                                 p_format_numbers    in varchar2 default NULL,
                                 p_reccnt           out number );
     
     procedure cellsprint( p_theCursor               in integer, 
                                 p_max_rows          in number  default 100,
                                 p_format_numbers    in varchar2 default NULL,
                                 p_reccnt           out number );

     procedure cellsprint( p_theQuery                in varchar2,
                                 p_max_rows          in number default 100,
                                 p_format_numbers    in varchar2 default NULL,
                                 p_skip_rec          in number default 0,
                                 p_more_data        out boolean,
                                 p_reccnt           out number );
     
     procedure cellsprint( p_theCursor               in integer, 
                                 p_max_rows          in number  default 100,
                                 p_format_numbers    in varchar2 default NULL, 
                                 p_skip_rec          in number default 0,
                                 p_more_data        out boolean,
                                 p_reccnt           out number );
 
 	/* Create a multi select list, a drop down list or a single select 	*/
	/* list.															*/	
 	/* You send it a query that selects out in ORDER:					*/
 	/* COLUMN 1 - What your procedure will get back						*/
 	/* COLUMN 2 - What your user will see in the list box				*/
 	/* COLUMN 3 - a null or non-null field.  If the field is non-null,	*/ 
	/*            	the current row will be flagged as SELECTED in the	*/ 
	/*				list box											*/
 
 
     procedure listprint( p_theCursor in integer,
                                p_cname     in varchar2,
                                p_nsize     in number,
                                p_multiple     in boolean default FALSE );
 
     procedure listprint( p_theQuery  in varchar2,
                                p_cname     in varchar2,
                                p_nsize     in number,
                                p_multiple     in boolean default FALSE );
 

	/* procedure for displaying a Date field in html and allowing 	*/
	/* the user to pick an arbritrary date.  This procedure uses 	*/
	/* 3 html input fields to get the DAY, MONTH, and YEAR fields. 	*/
	/* The procedure you write that recieves the input should have	*/ 
	/* an input variable of type owa_util.datetype.					*/

	type dateType is table of varchar2(10) index by binary_integer;
	procedure choose_date( p_name in varchar2, p_date in date default sysdate);
	function todate( p_dateArray in dateType ) return date;

	empty_date	owa_util.datetype;

	/* routines to print calendars in html format 			*/
	procedure calendarprint( p_query  in varchar2, 
								p_mf_only in varchar2 default 'N' );
	procedure calendarprint( p_cursor in integer,  
								p_mf_only in varchar2 default 'N' );

     /**********************************************************************/
    /* Function to obtain the version number                              */
   /**********************************************************************/
   function get_version return varchar2;
   PRAGMA RESTRICT_REFERENCES(get_version, WNDS, WNPS, RNDS);

     /**********************************************************************/
    /* Procedure to print the version number                              */
   /**********************************************************************/
   procedure print_version;
end;
/
show errors

