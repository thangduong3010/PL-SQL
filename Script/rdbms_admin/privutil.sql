Rem
Rem
Rem Copyright (c) 1995, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      privutil.sql - package of various OWA utility procedures
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
Rem     klrice     05/21/12 - addressing bug #9774695
Rem     pkapasi    06/25/07 - Fix bug#6013207
Rem     pkapasi    11/03/06 - Bump up owa version for next release
Rem     pkapasi    10/12/06 - Increment version number
Rem     mmuppago   04/27/06 - bumping up ship version 
Rem     akatti     15/07/05 - Bump up version
Rem     akatti     11/07/05 - Bug fix 4711884 validate before writing http headers
Rem     mmuppago   10/03/05 -  Bump up the version for  bug fix 4608020
Rem     aarat      07/12/05 -  Bug fix 4457390 
Rem     ehlee      04/25/05 -  Change version to release version
Rem     akatti     01/19/05 -  Mixed case vars in get_cgi_env (bug#3188606) 
Rem     ehlee      09/02/04 -  Bump up version
Rem     dnonkin    09/01/04 -  Bump up version
Rem     pkapasi    11/27/03 -  Fix bug#3284896 and bump up version number
Rem     pkapasi    05/29/03 -  Fix bug#2980038 and bump up version number
Rem     ehlee      03/03/03 -  Fix get_procedure to handle flex (bug#2807392)
Rem     ehlee      11/01/02 -  Bump up version
Rem     ehlee      10/31/02 -  Bump up version
Rem     pkapasi    10/09/02 -  Bump up version
Rem     pkapasi    08/06/02 -  Bump up version
Rem     ihonda     06/10/02 -  Fix bug#1892633 and bump up version
Rem     ehlee      12/03/01 -  Bump up version
Rem     ehlee      12/03/01 -  Workaround for bug#2129672
Rem     ehlee      11/12/01 -  Add skwong's mime_header charset fix
Rem     ehlee      10/30/01 -  Fix bug#2087553
Rem     ehlee      10/17/01 -  Move version number to here
Rem     pkapasi    09/28/01 -  Merge fix for bug#1785301
Rem     pkapasi    08/21/01 -  Fix bug#1930471
Rem     ehlee      08/16/01 -  Fix issues with column name overflow for describe
Rem     skwong     07/20/01 -  Enable NCHAR support using ANY_CS
Rem     skwong     06/15/01 -  Get NewLine character in portable manner
Rem     ehlee      08/08/01 -  Fix who_called_me function to parse correctly
Rem     ehlee      09/15/00 -  Fix bug#1401472 (add version number)
Rem     pkapasi    09/07/00 -  Fix bug#1399906 (dynamic cursor not freed)
Rem     pkapasi    09/02/00 -  Merge in fix from OAS code line(bug#960427)
Rem     ehlee      08/30/00 -  Fix not set charset if not there (bug#1375531) 
Rem     pkapasi    07/03/00 -  Change PLSQL Cartridge to PL/SQL Web ToolKit
Rem     ehlee      06/28/00 -  Fix bug where charset arg is ignored #1340072
Rem     ehlee      05/08/00 -  Fix bug where charset is set for non-text types 
Rem     ehlee      01/14/00 -  Add default charset support
Rem     rdasarat   11/03/98 -  Fix 755477
Rem     rdasarat   10/27/98 -  Fix 718865
Rem     rdasarat   10/26/98 -  Fix 735061
Rem     rdasarat   07/23/98 -  Fix 704045
Rem     rdasarat   07/23/98 -  Fix 704077
Rem     rdasarat   06/18/98 -  Fix 665515
Rem     rdasarat   03/12/98 -  Fix 591932
Rem     rdasarat   12/02/97 -  Fix 591932
Rem     rdasarat   10/17/97 -  Add ccharset to mime_header
Rem     rdasarat   09/11/97 -  Fix 514444 - Parse column list properly
Rem     rdasarat   07/09/97 -  Implement COMMON schema; optimize code
Rem     mpal       05/13/97 -  Fix bug# 481120 to support multibyte characters 
Rem     mpal       03/18/97 -  Fix bug# 466514 
Rem     mpal       11/12/96 -  Fix bug# 412612 change default nrow_max to 500
Rem     mpal       11/12/96 -  Fix bug# 409849
Rem     rpang      07/03/96 -  Added get_procedure
Rem     mpal       06/24/96 -  Add new utilities for 2.1
Rem     mbookman   03/04/96 -  get_cgi_env and print_cgi_env now use 
Rem                            owa.num_cgi_vars (314403)
Rem     mbookman   01/24/96 -  Add "bclose_header" field to HTTP header calls
Rem     mbookman   01/24/96 -  Remove HTTP_HEADER_OPEN
Rem     mbookman   01/12/96 -  Add REDIRECT_URL and STATUS_LINE
Rem     mbookman   12/13/95 -  Add HTTP_HEADER_OPEN, HTTP_HEADER_CLOSE
Rem     mbookman   08/08/95 -  tablePrint now re-sizes narrow empty tables
Rem     mbookman   07/09/95 -  Creation

REM Creating OWA_UTIL package body...
create or replace package body OWA_UTIL is

   owa_version CONSTANT varchar2(64) := '10.1.2.0.9';

   table_border char(1);

   /* datatypes for procedure calendarprint */
   type dateArray is table of date index by binary_integer;
   type vcArray   is table of varchar2(2000) index by binary_integer;
   type ncArray   is table of nvarchar2(2000) index by binary_integer;
   type object_names_owners is table of number index by varchar2(500);
   checked_synonyms object_names_owners;

   /*  NL_CHAR can be computed from a Unicode string in a portable manner. */
   NL_CHAR constant varchar2(10) := owa_cx.nl_char;
   /* Constant is set here instead of owachars to avoid invalid objects */
   CR_CHAR constant varchar2(10) := chr(13);

   colTblSz binary_integer;
   colTbl   dbms_utility.uncl_array;

     /************************************************************************/
    /* Function to validate strings that gets set in HTTP header,cookie etc */
   /************************************************************************/
   function validate_arg(
       param in varchar2
   ) return varchar2 is
       valid_param varchar2(32767);
   begin
       if (param is NULL)
       then
           return param;
       end if;

       valid_param := param;
       if instr(valid_param,(NL_CHAR)) > 0
       then
          valid_param := substr(valid_param,1,instr(valid_param,(NL_CHAR)) - 1);
       end if;
       if instr(valid_param,(CR_CHAR)) > 0
       then
          valid_param := substr(valid_param,1,instr(valid_param,(CR_CHAR)) - 1);
       end if;

       return valid_param;
   end;

     /*********************************************************************/
    /* Function to check if the given object is a table in user's schema */
   /*********************************************************************/
   function is_table(
      item_owner in varchar2,
      item_name in varchar2
   ) return boolean is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      found       number;
   begin
      found := 0;
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'begin
             select 1
               into :found
               from all_tables
              where table_name = upper(:item_name)
                and owner      = upper(:item_owner);
          exception
             when others then
                :found := 0;
          end;', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':item_owner', item_owner);
      dbms_sql.bind_variable(stmt_cursor, ':item_name', item_name);
      dbms_sql.bind_variable(stmt_cursor, ':found', found);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':found', found);
      dbms_sql.close_cursor(stmt_cursor);
      return(found <> 0);
   end is_table;

     /********************************************************************/
    /* Function to check if the given object is a view in user's schema */
   /********************************************************************/
   function is_view(
      item_owner in varchar2,
      item_name in varchar2
   ) return boolean is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      found       number;
   begin
      found := 0;
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'begin
             select 1
               into :found
               from all_views
              where view_name = upper(:item_name)
                and owner     = upper(:item_owner);
          exception
             when others then
                :found := 0;
          end;', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':item_owner', item_owner);
      dbms_sql.bind_variable(stmt_cursor, ':item_name', item_name);
      dbms_sql.bind_variable(stmt_cursor, ':found', found);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':found', found);
      dbms_sql.close_cursor(stmt_cursor);
      return(found <> 0);
   end is_view;

     /**************************************/
    /* Function to get synonym definition */
   /**************************************/
   function get_synonym_defn(
      csynonym  in varchar2,
      cschema   in varchar2,
      o_name    out all_synonyms.table_name%type,
      o_owner   out all_synonyms.table_owner%type,
      o_db_link out all_synonyms.db_link%type
   ) return boolean is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      name        all_synonyms.table_name%type;
      owner       all_synonyms.table_owner%type;
      db_link     all_synonyms.db_link%type;
   begin
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'begin
             select table_name, table_owner, db_link
               into :name, :owner, :db_link
               from all_synonyms
              where synonym_name = upper(:csynonym)
                and        owner = upper(:cschema);
          exception
             when others then
                :name := NULL;
                :owner := NULL;
                :db_link := NULL;
          end;', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':csynonym', csynonym);
      dbms_sql.bind_variable(stmt_cursor, ':cschema', cschema);
      dbms_sql.bind_variable(stmt_cursor, ':name', name, 2000);
      dbms_sql.bind_variable(stmt_cursor, ':owner', owner, 2000);
      dbms_sql.bind_variable(stmt_cursor, ':db_link', db_link, 2000);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':name', name);
      dbms_sql.variable_value(stmt_cursor, ':owner', owner);
      dbms_sql.variable_value(stmt_cursor, ':db_link', db_link);
      dbms_sql.close_cursor(stmt_cursor);
      o_name := name;
      o_owner := owner;
      o_db_link := db_link;
      return(name is NOT NULL or owner is NOT NULL or db_link is NOT NULL);
   exception
      when others then
          if dbms_sql.is_open(stmt_cursor) then
              dbms_sql.close_cursor(stmt_cursor);
          end if;

          raise;
   end get_synonym_defn;

     /************************************/
    /* Procedure to resolve object name */
   /************************************/
   procedure name_resolve(
      cname in varchar2,
      o_procowner out varchar2,
      o_procname out varchar2
   ) is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      procownerl  constant number := 255;
      procowner   varchar2(255);
      procnamel   constant number := 255;
      procname    varchar2(255);
   begin
      stmt_cursor := dbms_sql.open_cursor;
      /* resolve name and compose the real package.procedure */
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'declare
             part1         varchar2(255);
             part2         varchar2(255);
             dblink        varchar2(255);
             part1_type    number;
             object_number number;
          begin
             dbms_utility.name_resolve(:cname, 1,
                :procowner, part1, part2, dblink, part1_type, object_number);
             if part1_type in (7, 8)
             then
                :procname := part2;
             else
                if (part2 is null)
                then
                   :procname := part1;
                else
                   :procname := part1 || ''.'' || part2;
                end if;
             end if;
          exception
             when others then
                :procowner := NULL;
                :procname := NULL;
          end;', dbms_sql.v7
      );
      dbms_sql.bind_variable(stmt_cursor, ':cname', cname);
      dbms_sql.bind_variable(stmt_cursor, ':procowner', procowner, procownerl);
      dbms_sql.bind_variable(stmt_cursor, ':procname', procname, procnamel);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':procowner', procowner);
      dbms_sql.variable_value(stmt_cursor, ':procname', procname);
      dbms_sql.close_cursor(stmt_cursor);
      o_procowner := procowner;
      o_procname  := procname;
   end name_resolve;

     /***********************************************************************/
    /* Function to open cursor for all_source to get definition of proc/fn */
   /***********************************************************************/
   function open_source_cursor(
      o in varchar2,    -- procowner
      n in varchar2     -- procname
   ) return number is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      nm          varchar2(255);
      line        all_source.line%type;
      text        all_source.text%type;
   begin
      rc := instr(n, '.');
      if (rc > 0)
      then
         nm := substr(n, 1, (rc - 1));
      else
         nm := n;
      end if;
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'select line, text
            from all_source
           where name  = upper(:n)
             and owner = upper(:o)
           order by type, line', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':o', o);
      dbms_sql.bind_variable(stmt_cursor, ':n', nm);
      dbms_sql.define_column(stmt_cursor, 1, line);
      dbms_sql.define_column(stmt_cursor, 2, text, 2000);
      rc := dbms_sql.execute(stmt_cursor);
      return(stmt_cursor);
   end open_source_cursor;

     /************************************************************************/
    /* Function to fetch cursor for all_source to get definition of proc/fn */
   /************************************************************************/
   function fetch_source_cursor(
      stmt_cursor in number,
      line        out number,
      text        out varchar2
   ) return number is
   begin
      if (stmt_cursor >= 0 and dbms_sql.fetch_rows(stmt_cursor) > 0)
      then
         dbms_sql.column_value(stmt_cursor, 1, line);
         dbms_sql.column_value(stmt_cursor, 2, text);
         return(0);
      else
         return(-1);
      end if;
   end fetch_source_cursor;

     /*******************************************/
    /* Function to close cursor for all_source */
   /*******************************************/
   procedure close_source_cursor(stmt_cursor in out number) is
   begin
      dbms_sql.close_cursor(stmt_cursor);
   end close_source_cursor;

     /******************************************************************/
    /* Procedure to link back to the PL/SQL source for your procedure */
   /******************************************************************/
   procedure showsource(cname in varchar2) is
      procname  varchar2(255);
      procowner varchar2(255);

      stmt_cursor number;       -- stmt cursor

      line1s integer := 0;
      line   all_source.line%type;
      text   all_source.text%type;
   begin

      name_resolve(cname, procowner, procname);

      htp.header(1,'Source code for ' || procname);
      htp.preOpen;

      stmt_cursor := open_source_cursor(procowner, procname);
      while (fetch_source_cursor(stmt_cursor, line, text) >= 0)
      loop
         if (line = 1)
         then
            line1s := line1s + 1;
            if (line1s = 2)
            then
               htp.print;
            end if;
         end if;
         htp.prints(translate(text,NL_CHAR,' '));
      end loop;
      close_source_cursor(stmt_cursor);

      htp.preClose;
      signature;
   end;

     /**************************************************/
    /* Procedures for printing out an OWA "signature" */
   /**************************************************/
   procedure signature is
   begin
      htp.line;
      htp.p('This page was produced by the ');
      htp.p(htf.bold('PL/SQL Web ToolKit')||' on '||
            to_char(sysdate,'Month DD, YYYY HH12:MI PM')||htf.nl);
   end;
 
   procedure signature(cname in varchar2 character set any_cs) is
   begin
      signature;
      htp.anchor(owa_util.get_owa_service_path||
                 'owa_util.showsource?cname='||cname,
                 'View PL/SQL source code');
   end;

      /******************************************************/
     /* Procedure for printing a page generated by htp/htf */
    /* in SQL*Plus or SQL*DBA                             */ 
   /******************************************************/
   procedure showpage is
   begin
      htp.showpage;
   end;

     /**************************************************************/
    /* Procedure/function for accessing CGI environment variables */
   /**************************************************************/
   function get_cgi_env(param_name in varchar2) return varchar2 is
      upper_param_name varchar2(2000) := upper(param_name);
   begin
      for i in 1..owa.num_cgi_vars
      loop
         if (upper(owa.cgi_var_name(i)) = upper_param_name)
           then return(owa.cgi_var_val(i));
         end if;
      end loop;

      return NULL;
   end;
 
   procedure print_cgi_env is
   begin
      for i in 1..owa.num_cgi_vars
      loop
         htp.print(owa.cgi_var_name(i)||' = '||owa.cgi_var_val(i)||htf.nl);
      end loop;
   end;

   function get_owa_service_path return varchar2 is
      script_name varchar2(2000) := get_cgi_env('SCRIPT_NAME');
   begin
      if (substr(script_name,-1) = '/')
      then
         return script_name;
      else
         return script_name||'/';
      end if;
   end;

   procedure mime_header(ccontent_type in varchar2 DEFAULT 'text/html',
                         bclose_header in boolean  DEFAULT TRUE,
                         ccharset      in varchar2 DEFAULT 'MaGiC_KeY')
   is
      charset varchar2(40) := null;
      l_ccontent_type varchar2(32767);
      l_ccharset      varchar2(32767);
   begin
      -- Validate parameters
      l_ccontent_type := validate_arg(ccontent_type);

      l_ccharset := validate_arg(ccharset);

      -- Check if ccharset is passed in
      if (l_ccharset = 'MaGiC_KeY')
      then
         -- Check the ccontent_type is of type 'text'
         if (upper(l_ccontent_type) like 'TEXT%')
         then
            charset := owa_util.get_cgi_env('REQUEST_IANA_CHARSET');
            if (charset is null)
            then
               htp.prn('Content-type: '||l_ccontent_type||NL_CHAR);  
            else
               htp.prn('Content-type: '||l_ccontent_type
                  ||'; charset='||charset||NL_CHAR);
            end if;
         else
            htp.prn('Content-type: '||l_ccontent_type||NL_CHAR);
         end if;
         htp.setHTTPCharset(charset, owa_util.get_cgi_env('REQUEST_CHARSET'));
      else
         -- Just output what was passed in without check for type 'text'
         if (l_ccharset is null) then
            htp.prn('Content-type: '||l_ccontent_type||NL_CHAR);
            htp.setHTTPCharset(l_ccharset, owa_util.get_cgi_env('REQUEST_CHARSET'));
         else
            htp.prn('Content-type: '||l_ccontent_type
               ||'; charset='||l_ccharset||NL_CHAR);
            htp.setHTTPCharset(l_ccharset);
         end if;
      end if;

      if (bclose_header)
         then http_header_close;
      end if;
   end;

   procedure redirect_url(curl          in varchar2 character set any_cs,
                          bclose_header in boolean  DEFAULT TRUE)
      is
      l_url varchar2(32767);
   begin
     
      l_url := validate_arg(curl); 
      
      htp.prn('Location: '||l_url||NL_CHAR);

      if (bclose_header)
         then http_header_close;
      end if;
   end;

   procedure status_line(nstatus       in integer,
                         creason       in varchar2 character set any_cs DEFAULT NULL,
                         bclose_header in boolean  DEFAULT TRUE)
      is
      l_creason varchar2(32767);
   begin
      -- validate parameter
      l_creason := validate_arg(creason);

      htp.prn('Status: '||nstatus||' '||l_creason||NL_CHAR);

      if (bclose_header)
         then http_header_close;
      end if;
   end;

   procedure http_header_close is
   begin
      htp.prn(NL_CHAR);
   end;

     /**********************************************/
    /* A couple of handy routines used internally */
   /**********************************************/
   function get_next_col(
      col_list in  varchar2 character set any_cs,
      inDB     in  boolean,
      loc_in   in  integer,
      loc_out  out number,
      isExpr   out boolean
   ) return varchar2 character set col_list%charset is
      ix          number;
      len         number := length(col_list);
      parenCnt    number;
      inQuote     boolean;
      nxt_ch      varchar2(1) character set col_list%charset;
   begin
      if (inDB)
      then
         if (loc_in = 1)
         then
            colTbl.delete;
            dbms_utility.comma_to_table(col_list, colTblSz, colTbl);
         end if;
         if (loc_in <= colTblSz)
         then
            if (loc_in < colTblSz)
            then
               loc_out := loc_in;
            else
               loc_out := -1;
            end if;
            isExpr := (instr(colTbl(loc_in), '(') > 0);
            return(colTbl(loc_in));
         end if;
         loc_out := -1;
         isExpr := false;
         return(NULL);
      end if;

      isExpr := false;
      parenCnt := 0;
      inQuote := false;
      ix := loc_in;
      while (ix <= len)
      loop
         nxt_ch := substr(col_list, ix, 1);
         if (nxt_ch = ',')
         then
            if (parenCnt = 0 and (not inQuote))
            then
               exit;
            end if;
         elsif (nxt_ch = '(')
         then
            isExpr := true;
            if (not inQuote)
            then
               parenCnt := parenCnt + 1;
            end if;
         elsif (nxt_ch = ')')
         then
            isExpr := true;
            if (not inQuote)
            then
               parenCnt := parenCnt - 1;
            end if;
         elsif (nxt_ch = '''')
         then
            isExpr := true;
            inQuote := (not inQuote);
         end if;
         ix := ix + 1;
      end loop;
      if (ix > len)
      then
         loc_out := -1;
         return(ltrim(rtrim(substr(col_list, loc_in))));
      else
         loc_out := ix;
         return(ltrim(rtrim(substr(col_list, loc_in, ix - loc_in))));
      end if;
   end get_next_col;

   /* NCHAR version of comma_to_ident_arr */
   procedure comma_to_ident_arr(list    in varchar2 character set any_cs, 
                                arr    out ident_narr,
                                lenarr out num_arr,
                                arrlen out integer) is
      tok_counter number;
      tok_loc_out number;
      isExpr      boolean;
   begin
      if (list is null)
      then
         arrlen := 0;
         return;
      end if;
      tok_counter := 0;
      tok_loc_out := 0;
      while (tok_loc_out >= 0) loop
         tok_counter := tok_counter + 1;
         arr(tok_counter) :=
            substr(get_next_col(list, FALSE,
                                (tok_loc_out + 1), tok_loc_out, isExpr),
                   1, 30);
         lenarr(tok_counter) := length (arr(tok_counter)); 
      end loop;
      arrlen := tok_counter;
   end;

   procedure comma_to_ident_arr(list    in varchar2 character set any_cs,
                                arr    out ident_arr,
                                lenarr    out num_arr,
                                arrlen out integer) is
      tok_counter number;
      tok_loc_out number;
      isExpr      boolean;
   begin
      if (list is null)
      then
         arrlen := 0;
         return;
      end if;
      tok_counter := 0;
      tok_loc_out := 0;
      while (tok_loc_out >= 0) loop
         tok_counter := tok_counter + 1;
         arr(tok_counter) :=
            substr(get_next_col(list, FALSE,
                                (tok_loc_out + 1), tok_loc_out, isExpr),
                                1, 30);
         lenarr(tok_counter) := lengthb (arr(tok_counter));
      end loop;
      arrlen := tok_counter;
   end;

   function align(cdata        in     varchar2,
                  ncolumn_size in     integer,
                  calign       in     varchar2 DEFAULT 'LEFT') return varchar2
    is
      lalign     integer;
      align_type char(1);
   begin
      align_type := upper(substr(calign,1,1));
      if (align_type = 'L')
      then
         lalign := 1 + nvl(lengthb(cdata),0);
      else
         if (align_type = 'R')
         then
            lalign := ncolumn_size+1;
         else /* align_type = 'C' */
            lalign := 1 + ceil((ncolumn_size - nvl(lengthb(cdata),0))/2)
                        + nvl(lengthb(cdata),0);
         end if;
      end if;

      return (rpad(lpad(nvl(cdata,' '), lalign), ncolumn_size+2)||table_border);
   end;

     /******************************************************************/
    /* Procedures and functions for building HTML and non-HTML tables */
   /******************************************************************/
   /* This is just a function prototype */
   procedure resolve_synonym(csynonym in varchar2,
                             cschema  in varchar2,
                             resolved_name    out varchar2,
                             resolved_owner   out varchar2,
                             resolved_db_link out varchar2);

   procedure resolve_table(
      cobject          in varchar2,
      cschema          in varchar2,
      resolved_name    out varchar2,
      resolved_owner   out varchar2,
      resolved_db_link out varchar2
   ) is
      stmt_cursor number;       -- stmt cursor
      rc          number;       -- return code
      al          constant number := 255;
      a           varchar2(255);
      bl          constant number := 255;
      b           varchar2(255);
      cl          constant number := 255;
      c           varchar2(255);
      dblinkl     constant number := 255;
      dblink      varchar2(255);
      next_pos    binary_integer;
   
      item_name varchar2(255);
      item_owner varchar2(255); 
   
      dummy char(1);
   begin
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'begin
             dbms_utility.name_tokenize(:cobject,
                :a, :b, :c, :dblink, :next_pos);
          end;', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':cobject', cobject);
      dbms_sql.bind_variable(stmt_cursor, ':a', a, al);
      dbms_sql.bind_variable(stmt_cursor, ':b', b, bl);
      dbms_sql.bind_variable(stmt_cursor, ':c', c, cl);
      dbms_sql.bind_variable(stmt_cursor, ':dblink', dblink, dblinkl);
      dbms_sql.bind_variable(stmt_cursor, ':next_pos', next_pos);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':a', a);
      dbms_sql.variable_value(stmt_cursor, ':b', b);
      dbms_sql.variable_value(stmt_cursor, ':c', c);
      dbms_sql.variable_value(stmt_cursor, ':dblink', dblink);
      dbms_sql.variable_value(stmt_cursor, ':next_pos', next_pos);
      dbms_sql.close_cursor(stmt_cursor);
   
      if (c is not null)
      then
         /* For a table, we should see AT MOST owner.table */
         /* If c has a value, we've got owner.table.column */
         /* or owner.package.procedure                     */
         raise_application_error(-20000,
            'Value '||cobject||' passed to resolve_table is invalid');
      end if;
   
      if (b is not null) 
      then              
         item_owner := a;
         item_name := b;
      else
         item_owner := cschema;
         item_name := a;
      end if;
   
      if (is_table(item_owner, item_name) or is_view(item_owner, item_name))
      then 
         resolved_name    := item_name;
         resolved_owner   := item_owner;
         resolved_db_link := dblink;
      else
         resolve_synonym(item_name, item_owner,
                         resolved_name, resolved_owner, resolved_db_link);
      end if;
   end;

   procedure resolve_synonym(csynonym in varchar2,
                             cschema  in varchar2,
                             resolved_name    out varchar2,
                             resolved_owner   out varchar2,
                             resolved_db_link out varchar2) is
      name    varchar2(255);
      owner   varchar2(255);
      db_link varchar2(128);
      is_also_syn number;
   begin
      if ( (get_synonym_defn(csynonym, cschema, name, owner, db_link)
             or get_synonym_defn(csynonym, 'PUBLIC', name, owner, db_link))
             and  not checked_synonyms.exists(name||'.'||owner))
      then
         checked_synonyms(name||'.'||owner):= 1;
         if (db_link is null)
         then
            resolve_table(name, owner,
                          resolved_name, resolved_owner, resolved_db_link);
         else
            raise_application_error(-20002,
               'Cannot resolve remote object ' || csynonym);
         end if;
      else
         raise_application_error(-20001, 'Cannot resolve object ' || csynonym);
      end if;
   end;
   
   /* DESCRIBE_COLS returns the column_names and datatypes as */
   /* arrays for passing to calc_col_sizes                    */
   procedure describe_cols(
                           ctable       in varchar2,
                           ccolumns     in varchar2,
                           col_names   out ident_arr,
                           col_dtypes  out ident_arr,
                           nnum_cols   out integer
                          )
    is
     col_cursor    integer;
     col_name      varchar2(255);
     col_charset   varchar(40);
     col_dtype     varchar2(9);
     col_counter   number;
     new_row       boolean;
     col_num       number;
   
     col_loc_out   number;
     next_col      varchar2(255);
     col_decode    varchar2(2000);
     col_in_clause varchar2(2000);
   
     table_resolved   varchar2(255);
     owner_resolved   varchar2(255);
     db_link_resolved varchar2(255);
   
     ignore     integer;
     isExpr     boolean;
   begin
      /* There's no dynamic describe unfortunately. */
      /* We will need to parse out the owner, etc. */
      checked_synonyms.delete;
      resolve_table(ctable,USER, 
                    table_resolved,owner_resolved,db_link_resolved);
   
      col_counter := 0;
      if (ccolumns = '*')
      then
         col_cursor := dbms_sql.open_cursor;
         sys.dbms_sys_sql.parse_as_user(col_cursor,
                      'select column_name, data_type, character_set_name '||
                           'from all_tab_columns '||
                           'where table_name = :table_name '||
                           '  and owner = :owner_resolved '||
                           'order by column_id',
                        dbms_sql.v7);

         dbms_sql.bind_variable(col_cursor, ':table_name', upper(table_resolved));
         dbms_sql.bind_variable(col_cursor, ':owner_resolved', upper(owner_resolved));
         dbms_sql.define_column(col_cursor, 1, col_name, 255);
         dbms_sql.define_column(col_cursor, 2, col_dtype, 9);
         dbms_sql.define_column(col_cursor, 3, col_charset, 40);

         ignore := dbms_sql.execute(col_cursor);

         loop
            if (dbms_sql.fetch_rows(col_cursor) > 0)
            then
               dbms_sql.column_value(col_cursor, 3, col_charset);
               dbms_sql.column_value(col_cursor, 2, col_dtype);
               dbms_sql.column_value(col_cursor, 1, col_name);

               col_counter := col_counter + 1;
               if ((col_dtype = 'VARCHAR2') or (col_dtype = 'CHAR')) and 
                  (col_charset = 'NCHAR_CS')
               then
                   col_dtypes(col_counter) := 'N' || col_dtype;
               else 
                   col_dtypes(col_counter) := col_dtype;
               end if;
               col_names(col_counter) := col_name;
            else
               exit;
            end if;
         end loop;
         dbms_sql.close_cursor(col_cursor);
      else
         col_decode := '';
         col_in_clause := '';
         col_loc_out := 0;
         while (col_loc_out >= 0) loop
            next_col := upper(get_next_col(ccolumns, FALSE, (col_loc_out + 1), col_loc_out, isExpr));
            col_counter := col_counter + 1;
            col_names(col_counter) := next_col;
            if (not isExpr)
            then
               col_decode := col_decode || ',''' || next_col
                                        || ''',' || col_counter;
               col_in_clause := col_in_clause || '''' || next_col || ''',';
            end if;
         end loop;
         if (col_in_clause is null)
         then
            for i in 1..col_counter
            loop
               col_dtypes(i) := 'VARCHAR2';
            end loop;
         else
            -- remove trailing ',' from col_in_clause
            col_in_clause := substr(col_in_clause, 1, length(col_in_clause)-1);
   
            col_cursor := dbms_sql.open_cursor;
            sys.dbms_sys_sql.parse_as_user(col_cursor,
                       'select column_name, data_type, character_set_name, '||
                           'decode(column_name'||col_decode||') '||
                           'from all_tab_columns '||
                           'where table_name = :table_name  '||
                           '  and owner = :owner_resolved '||
                           '  and column_name in ('||col_in_clause||') '||
                           'order by 3',
                        dbms_sql.v7);
 
            dbms_sql.bind_variable(col_cursor, ':table_name', owner_resolved);
      
            dbms_sql.bind_variable(col_cursor, ':owner_resolved', upper(owner_resolved));

            dbms_sql.define_column(col_cursor, 1, col_name, 255);
            dbms_sql.define_column(col_cursor, 2, col_dtype, 9);
            dbms_sql.define_column(col_cursor, 3, col_charset, 40);
            dbms_sql.define_column(col_cursor, 4, col_num, 9);

            ignore := dbms_sql.execute(col_cursor);

            new_row := (dbms_sql.fetch_rows(col_cursor) > 0);
            for i in 1..col_counter
            loop
               if (new_row) AND (i = col_num)
               then
                  dbms_sql.column_value(col_cursor, 2, col_dtype);
                  dbms_sql.column_value(col_cursor, 3, col_charset);
                  if ((col_dtype = 'VARCHAR2') or (col_dtype = 'CHAR')) and
                    (col_charset = 'NCHAR_CS')
                  then
                    col_dtypes(i) := 'N' || col_dtype;
                  else
                      col_dtypes(i) := col_dtype;
                  end if;
                  new_row := (dbms_sql.fetch_rows(col_cursor) > 0);
               else
                  col_dtypes(i) := 'VARCHAR2';
               end if;
            end loop;
            dbms_sql.close_cursor(col_cursor);
         end if;
      end if;

      nnum_cols := col_counter;

   end;
 
   procedure eliminate_longs(
      col_names   in out ident_arr,
      col_aliases in out ident_arr,
      col_dtypes  in out ident_arr,
      num_cols    in out integer,
      num_aliases in out integer
   ) is
      col_dtype     varchar2(2000);
   begin

      for i in 1..num_cols
      loop
         col_dtype := col_dtypes(i);
         if (col_dtype = 'LONG' OR col_dtype = 'LONG RAW')
         then
            num_cols := num_cols - 1;

            if (i < num_aliases)
            then
               num_aliases := num_aliases - 1;
            end if;

            for j in i..num_cols
            loop
               col_dtypes(j) := col_dtypes(j + 1);
               col_names(j) := col_names(j + 1);

               if (j <= num_aliases)
               then
                  col_aliases(j) := col_aliases(j + 1);
               end if;
            end loop;

            /* To be totally clean, let's null the last values */
            col_names(num_cols+1) := NULL;
            col_dtypes(num_cols+1) := NULL;
            col_aliases(num_aliases+1) := NULL;

            /* Since there is only one LONG allowed in a table, exit */
            exit;
         end if;
      end loop;

   end;

   /* CALC_COL_SIZES will calculate the necessary column sizes   */
   /* for a table.  If an ntable_type = HTML_TABLE, then it      */
   /* merely builds an array of NULLs, one entry for each column */
   /* This is necessary for calls to print_headings.             */
   /* For PRE_TABLEs, CALC_COL_SIZES must scan the table up to   */
   /* the nrow_max-th to determine the widest values.  If        */
   /* nrow_max is NULL, then the entire table is scanned.        */
   procedure calc_col_sizes(ctable      in     varchar2,
                            ntable_type in     integer,
                            ccolumns    in     varchar2,
                            col_names   in     ident_arr,
                            col_dtypes  in     ident_arr,
                            nnum_cols   in     integer,
                            col_aliases_len in num_arr,
                            num_aliases in     integer DEFAULT 0,
                            cclauses    in     varchar2 DEFAULT NULL,
                            nrow_min    in     integer DEFAULT NULL,
                            nrow_max    in     integer DEFAULT NULL,
                            col_sizes   in out num_arr,
                            table_empty    out boolean) is
     crsr     integer;
     ignore   integer;
 
     col_counter integer;
     col_dtype   varchar2(2000);
 
     vc_var     varchar2(2000);
     number_var number;
     date_var   date;
     long_var   varchar2(32767);
     raw_var    raw(255);
 
     col_size integer;
 
     row_count number;
   begin
      if ntable_type = HTML_TABLE
      then
         for i in 1..nnum_cols
         loop
            col_sizes(i) := NULL;
         end loop;
      else
         crsr := dbms_sql.open_cursor;
         sys.dbms_sys_sql.parse_as_user(crsr,
                        'select '||ccolumns||' from '||ctable||' '||cclauses,
                        dbms_sql.v7);

         for col_counter in 1..nnum_cols
         loop
            if (col_counter <= num_aliases)
            then
               col_sizes(col_counter):= nvl(col_aliases_len(col_counter),0);
            else
               col_sizes(col_counter):= nvl(lengthb(col_names(col_counter)),0);
            end if;

            col_dtype := col_dtypes(col_counter);
            if (col_dtype = 'VARCHAR2' OR col_dtype = 'CHAR')
            then
               dbms_sql.define_column(crsr, col_counter, vc_var, 2000);
            else if (col_dtype = 'NUMBER')
                 then
                    dbms_sql.define_column(crsr,
                                           col_counter, number_var);
                 else if (col_dtype = 'DATE')
                      then
                         dbms_sql.define_column(crsr,
                                                col_counter, date_var);
                      else if (col_dtype = 'LONG')
                           then
                              dbms_sql.define_column(crsr, col_counter,
                                                     long_var, 32767);
                           else if (col_dtype = 'RAW')
                                then
                                   dbms_sql.define_column_raw(crsr, col_counter,
                                                              raw_var, 255);
                                end if;
                           end if;
                      end if;
                 end if;
            end if;
         end loop;

         ignore := dbms_sql.execute(crsr);

         row_count := 0;
         if (nrow_min is NOT NULL)
         then
            while (row_count < nrow_min - 1)
            loop
               if (dbms_sql.fetch_rows(crsr) > 0)
                  then row_count := row_count+1;
                  else exit;
               end if;
            end loop;
         end if;

         while (nrow_max is NULL) or (row_count < nrow_max)
         loop

            if dbms_sql.fetch_rows(crsr) > 0
            then
               row_count := row_count+1;

               for col_counter in 1..nnum_cols
               loop
                  col_dtype := col_dtypes(col_counter);
                  if (col_dtype = 'VARCHAR2' OR col_dtype = 'CHAR')
                  then
                     dbms_sql.column_value(crsr, col_counter, vc_var);
                     col_size := nvl(lengthb(vc_var),0);
                  else if (col_dtype = 'NUMBER')
                       then
                          dbms_sql.column_value(crsr, col_counter,
                                                number_var);
                          col_size := nvl(lengthb(number_var),0);
                       else if (col_dtype = 'DATE')
                            then
                               dbms_sql.column_value(crsr, col_counter,
                                                     date_var);
                               col_size := nvl(lengthb(date_var),0);
                            else if (col_dtype = 'LONG')
                                 then
                                    dbms_sql.column_value(crsr, col_counter,
                                                          long_var);
                                    col_size := nvl(lengthb(long_var),0);
                                 else if (col_dtype = 'RAW')
                                      then
                                         dbms_sql.column_value_raw(crsr,
                                                          col_counter,
                                                          raw_var);
                                         col_size := nvl(lengthb(raw_var),0);
                                      else
                                         col_size := length('Not Printable');
                                      end if;
                                 end if;
                            end if;
                       end if;
                  end if;

                  if (col_size > col_sizes(col_counter))
                  then
                     col_sizes(col_counter) := col_size;
                  end if;
   
               end loop;

            else
               if row_count = 0
               then
                  table_empty := true;
               else
                  table_empty := false;
               end if;
               exit;
            end if;
         end loop;

         dbms_sql.close_cursor(crsr);
      end if; 
   end;

   /* PRINT_HEADINGS will print the column headings for a table. */
   /* If ccol_aliases is populated, it will use them, else it    */
   /* will use ccol_names.                                       */
   /* skwong:
   **    need to add support for NCHAR in ident_arr.
   */
   procedure print_headings(
                         ccol_aliases in     ident_narr,
                         num_aliases  in     integer,
                         ccol_names   in     ident_arr,
                         ccol_sizes   in     num_arr,
                         nnum_cols    in     integer,
                         ntable_width in out integer,
                         ntable_type  in     integer
                        ) is
  row_string varchar2(32000);
  begin
   tableHeaderRowOpen(row_string, ntable_width, ntable_type);

   for i in 1..nnum_cols
   loop
      if (i <= num_aliases)
      then
         tableHeader(ccol_aliases(i), ccol_sizes(i), 'CENTER',
                     row_string, ntable_width, ntable_type);
      else
         tableHeader(ccol_names(i), ccol_sizes(i), 'CENTER',
                     row_string, ntable_width, ntable_type);
      end if;
   end loop;

   tableHeaderRowClose(row_string, ntable_width, ntable_type);
   end;

   procedure print_headings(
                            ccol_aliases in     ident_arr,
                            num_aliases  in     integer,
                            ccol_names   in     ident_arr,
                            ccol_sizes   in     num_arr,
                            nnum_cols    in     integer,
                            ntable_width in out integer,
                            ntable_type  in     integer
                           ) is
     row_string varchar2(32000);
   begin
      tableHeaderRowOpen(row_string, ntable_width, ntable_type);

      for i in 1..nnum_cols
      loop
         if (i <= num_aliases)
         then
            tableHeader(ccol_aliases(i), ccol_sizes(i), 'CENTER',
                        row_string, ntable_width, ntable_type);
         else
            tableHeader(ccol_names(i), ccol_sizes(i), 'CENTER',
                        row_string, ntable_width, ntable_type);
         end if;
      end loop;

      tableHeaderRowClose(row_string, ntable_width, ntable_type);
   end;

   /* PRINT_ROWS will print the requested rows (nrow_min, nrow_max, */
   /* cclauses) and columns (ccolumns) from the table (ctable)      */
   /* in the specified format (ntable_type).                        */
   /* DESCRIBE_COLS (or a functional equivalent) must be called     */
   /* before calling PRINT_ROWS to populate col_dtypes, col_sizes.  */
   /* PRINT_ROWS returns TRUE if there are more rows (beyond        */
   /* nrow_max) to print.  False otherwise.                         */
   function print_rows(
                       ctable       in varchar2,
                       ntable_type  in integer DEFAULT HTML_TABLE,
                       ccolumns     in varchar2 DEFAULT '*',
                       cclauses     in varchar2 DEFAULT NULL,
                       col_dtypes   in ident_arr,
                       col_sizes    in num_arr,
                       nnum_cols    in integer,
                       ntable_width in integer,
                       nrow_min     in integer DEFAULT 0,
                       nrow_max     in integer DEFAULT NULL
                      ) return boolean
    is
     table_cursor integer;
  
     col_counter integer;
     col_dtype   varchar2(2000);
  
     vc_var     varchar2(2000);
     nc_var     nvarchar2(2000);
     number_var number;
     date_var   date;
     long_var   varchar2(32767);
     raw_var    raw(255);
  
     ignore     integer;
  
     row_string varchar2(32000);

     row_count number;
     more_rows boolean := TRUE;
   begin
      table_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(table_cursor,
                     'select '||ccolumns||' from '||ctable||' '||cclauses,
                     dbms_sql.v7);

      for col_counter in 1..nnum_cols
      loop
         col_dtype := col_dtypes(col_counter);
         if (col_dtype = 'VARCHAR2' OR col_dtype = 'CHAR') then
            dbms_sql.define_column(table_cursor, col_counter, vc_var, 2000);
         elsif (col_dtype = 'NVARCHAR2' OR col_dtype = 'NCHAR') then
            dbms_sql.define_column(table_cursor, col_counter, nc_var, 2000);
         elsif (col_dtype = 'NUMBER') then
            dbms_sql.define_column(table_cursor, col_counter, number_var);
         elsif (col_dtype = 'DATE') then
            dbms_sql.define_column(table_cursor, col_counter, date_var);
         elsif (col_dtype = 'LONG') then
            dbms_sql.define_column(table_cursor, col_counter, long_var, 32767); /* Kelly: not sure over 2000 is valid */
         elsif (col_dtype = 'RAW') then
            dbms_sql.define_column_raw(table_cursor, col_counter, raw_var, 32767);
         end if;
      end loop;

      ignore := dbms_sql.execute(table_cursor);
   
      row_count := 0;
      if (nrow_min is NOT NULL)
      then
         while (row_count < nrow_min - 1)
         loop
            if (dbms_sql.fetch_rows(table_cursor) > 0)
               then row_count := row_count+1;
               else exit;
            end if;
         end loop;
      end if;

      while (nrow_max is NULL) or (row_count < nrow_max)
      loop
   
         if dbms_sql.fetch_rows(table_cursor) > 0
         then
            row_count := row_count+1;
   
            tableRowOpen(row_string, ntable_type);
   
            for col_counter in 1..nnum_cols
            loop
               col_dtype := col_dtypes(col_counter);
               if (col_dtype = 'VARCHAR2' OR col_dtype = 'CHAR') then
                  dbms_sql.column_value(table_cursor, col_counter, vc_var);
                  tableData(vc_var, col_sizes(col_counter), 'LEFT', row_string, ntable_type);
               elsif  (col_dtype = 'NVARCHAR2' OR col_dtype = 'NCHAR') then
                  dbms_sql.column_value(table_cursor, col_counter, nc_var);
                  tableData(nc_var, col_sizes(col_counter), 'LEFT', row_string, ntable_type);
               elsif (col_dtype = 'NUMBER') then
                  dbms_sql.column_value(table_cursor, col_counter,number_var);
                  tableData(number_var, col_sizes(col_counter), 'LEFT', row_string, ntable_type);
               elsif (col_dtype = 'DATE') then
                  dbms_sql.column_value(table_cursor, col_counter, date_var);
                  tableData(to_nchar(date_var), col_sizes(col_counter), 'LEFT', row_string, ntable_type);
               elsif (col_dtype = 'LONG') then
                  dbms_sql.column_value(table_cursor, col_counter,long_var);
                  tableData(long_var, col_sizes(col_counter),'LEFT', row_string, ntable_type);
               elsif (col_dtype = 'RAW') then
                  dbms_sql.column_value_raw(table_cursor, col_counter, raw_var);
                  tableData(raw_var, col_sizes(col_counter), 'LEFT', row_string, ntable_type);
               else 
		  tableData('Not Printable', col_sizes(col_counter),'LEFT', row_string, ntable_type);
               end if;
                  
            end loop;
      
            tableRowClose(row_string, ntable_type); 
         else
            more_rows := FALSE;
            exit;
         end if;
      end loop;

      if (row_count < nrow_min)
      then
         tableRowOpen(row_string, ntable_type);
         tableNoData('LEFT', row_string, nnum_cols, ntable_width, ntable_type);
         tableRowClose(row_string, ntable_type); 
      else
         if (more_rows)
            then more_rows := dbms_sql.fetch_rows(table_cursor) > 0;
         end if;
      end if;

      dbms_sql.close_cursor(table_cursor);

      return more_rows;
   end;

   procedure show_query_columns(ctable in varchar2) is
      ignore           integer;
      cols_cursor      integer;
      table_resolved   varchar2(255);
      owner_resolved   varchar2(255);
      db_link_resolved varchar2(255);
      col_name         varchar2(2000);
   begin
      /* There's no dynamic describe unfortunately. */
      /* We will need to parse out the owner, etc. */
      checked_synonyms.delete;
      resolve_table(ctable,USER,
                    table_resolved,owner_resolved,db_link_resolved);

      htp.formHidden('ctable', ctable);
      htp.formHidden('COLS', 'DUMMY');

      cols_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(cols_cursor,
             'select column_name from all_tab_columns where table_name = upper(:t)
                 and owner = upper(:o)',
             dbms_sql.v7);
      dbms_sql.bind_variable(cols_cursor, ':t', table_resolved);
      dbms_sql.bind_variable(cols_cursor, ':o', owner_resolved);
      dbms_sql.define_column(cols_cursor, 1, col_name, 2000);
      ignore := dbms_sql.execute(cols_cursor);
      loop
         if (dbms_sql.fetch_rows(cols_cursor) > 0)
         then
            dbms_sql.column_value(cols_cursor, 1, col_name);
            htp.formCheckbox('COLS', col_name);
            htp.print(col_name);
            htp.nl;
         else
            exit;
         end if;
      end loop;
      dbms_sql.close_cursor(cols_cursor);
      htp.formSubmit(NULL,'Execute Query');
   end;

   function tablePrint(ctable       in varchar2,
                       cattributes  in varchar2 DEFAULT NULL,
                       ntable_type  in integer  DEFAULT HTML_TABLE,
                       ccolumns     in varchar2 DEFAULT '*',
                       cclauses     in varchar2 DEFAULT NULL,
                       ccol_aliases in varchar2 character set any_cs DEFAULT NULL,
                       nrow_min     in number DEFAULT 0,
                       nrow_max     in number DEFAULT 500) return boolean
    is
     col_names   ident_arr;
     col_aliases ident_arr;
     col_aliases_nchar ident_narr;
     col_aliases_len num_arr; 
     num_aliases integer;
     col_dtypes  ident_arr;
     col_sizes   num_arr;

     nnum_cols    integer;
     ntable_width integer;

     no_data_len integer;
     inc_len     integer;
     amt_left    integer;

     table_empty boolean;
     more_rows   boolean;
     nchar_path  boolean;
   begin

      if (ccol_aliases is not null) then
        if (isnchar(ccol_aliases)) then
          nchar_path := TRUE;
          comma_to_ident_arr(ccol_aliases, col_aliases_nchar, col_aliases_len, num_aliases);
        else
          nchar_path := FALSE;
          comma_to_ident_arr(to_char(ccol_aliases), col_aliases, col_aliases_len, num_aliases);
        end if;
      else
        num_aliases := 0;
      end if;

      describe_cols(ctable, ccolumns, col_names, col_dtypes, nnum_cols);
    
      calc_col_sizes(ctable, ntable_type, ccolumns, col_names, col_dtypes,
               nnum_cols, col_aliases_len, num_aliases, cclauses,
               nrow_min, nrow_max, col_sizes, table_empty);

      if (table_empty)
      then
         ntable_width := 1;
         for i in 1..nnum_cols
         loop
            ntable_width := ntable_width + col_sizes(i) + 3;
         end loop;

         no_data_len := length('  No Data Found  ');

         if (ntable_width < no_data_len)
         then
            amt_left := no_data_len - ntable_width;
            inc_len := ceil(amt_left/nnum_cols);

            for i in 1..nnum_cols
            loop
               if amt_left > inc_len 
               then
                  col_sizes(i) := col_sizes(i) + inc_len;
                  amt_left := amt_left - inc_len;
               else
                  col_sizes(i) := col_sizes(i) + amt_left;
                  amt_left := 0;
               end if;
            end loop;
         end if;
      end if;

      tableOpen(cattributes, ntable_type);
      if (nchar_path)  then
        print_headings(col_aliases_nchar, num_aliases, col_names, col_sizes,
                     nnum_cols, ntable_width, ntable_type);
      else 
        print_headings(col_aliases, num_aliases, col_names, col_sizes,
             nnum_cols, ntable_width, ntable_type);
      end if;

      more_rows := print_rows(ctable, ntable_type, ccolumns, cclauses,
                              col_dtypes, col_sizes, nnum_cols, ntable_width,
                              nrow_min, nrow_max);

      tableClose(ntable_width, ntable_type); 
   
      return(more_rows);
   end;

   procedure tableOpen(cattributes in varchar2 DEFAULT NULL,
                       ntable_type in integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableOpen(NULL, NULL, NULL, NULL, cattributes);
      else
         if (cattributes is not null)
         then
            table_border := '|';
         else
            table_border := ' ';
         end if;
         htp.print('<PRE>');
      end if;
   end;
 
   procedure tableCaption(ccaption    in varchar2 character set any_cs,
                          calign      in varchar2 DEFAULT 'CENTER',
                          ntable_type in integer  DEFAULT HTML_TABLE) is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableCaption(ccaption, calign);
      else
         htp.print(ccaption);
      end if;
   end;

   procedure tableHeaderRowOpen(crowstring  in out varchar2,
                                ntable_type in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowOpen;
      else
         crowstring := table_border;
      end if;
   end;
 
   procedure tableHeaderRowOpen(crowstring   in out varchar2,
                                ntable_width    out integer,
                                ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowOpen;
      else
         ntable_width := 1;
         crowstring := table_border;
      end if;
   end;
 
   procedure tableHeader(ccolumn_name in     varchar2 character set any_cs,
                         ncolumn_size in     integer,
                         calign       in     varchar2 DEFAULT 'CENTER',
                         crowstring   in out varchar2,
                         ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableHeader(ccolumn_name);
      else
         crowstring := crowstring||align(ccolumn_name,ncolumn_size,calign);
      end if;
   end;

   procedure tableHeader(ccolumn_name in     varchar2 character set any_cs,
                         ncolumn_size in     integer,
                         calign       in     varchar2 DEFAULT 'CENTER',
                         crowstring   in out varchar2,
                         ntable_width in out integer,
                         ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableHeader(ccolumn_name);
      else
         ntable_width := ntable_width+ncolumn_size+3;
         crowstring := crowstring||align(ccolumn_name,ncolumn_size,calign);
      end if;
   end;

   procedure tableHeaderRowClose(crowstring  in out varchar2,
                                 ntable_type in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowClose;
      else
         htp.print(crowstring);
      end if;
   end;

   procedure tableHeaderRowClose(crowstring   in out varchar2,
                                 ntable_width in     integer,
                                 ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowClose;
      else
         if (table_border = '|')
         then
            htp.print(rpad('-',ntable_width,'-'));
            htp.print(crowstring);
            htp.print(rpad('-',ntable_width,'-'));
         else
            htp.print(' ');
            htp.print(crowstring);
            htp.print(' ');
         end if;
      end if;
   end;

   procedure tableRowOpen(crowstring  in out varchar2,
                          ntable_type in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowOpen;
      else
         crowstring := table_border;
      end if;
   end;

   procedure tableData(cdata        in     varchar2 character set any_cs,
                       ncolumn_size in     integer,
                       calign       in     varchar2 DEFAULT 'LEFT',
                       crowstring   in out varchar2,
                       ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableData(cdata, calign);
      else
         crowstring := crowstring||align(translate(cdata,NL_CHAR,' '),
                                                   ncolumn_size, calign);
      end if;
   end;
 
   procedure tableNoData(calign       in     varchar2 DEFAULT 'LEFT',
                         crowstring   in out varchar2,
                         nnum_cols    in     integer,
                         ntable_width in     integer,
                         ntable_type  in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableData('No data found', ccolspan=>nnum_cols);
      else
         crowstring := crowstring||align('No data found',ntable_width-4,calign);
      end if;
   end;
 
   procedure tableRowClose(crowstring  in out varchar2,
                           ntable_type in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableRowClose;
      else
         htp.print(crowstring);
      end if;
   end;

   procedure tableClose(ntable_type in     integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableClose;
      else
         htp.print('</PRE>');
      end if;
   end;

   procedure tableClose(ntable_width in integer,
                        ntable_type  in integer DEFAULT HTML_TABLE)
    is
   begin
      if (ntable_type = HTML_TABLE)
      then
         htp.tableClose;
      else
         if (table_border = '|')
         then
            htp.print(rpad('-',ntable_width,'-'));
         else
            htp.print(' ');
         end if;

         htp.print('</PRE>');
      end if;
   end;

     /******************************************************************/
    /* Procedures and functions for new utilities for 2.1             */
   /******************************************************************/

     /******************************************************************/
    /* Function macro for if then else -- ite                         */
   /******************************************************************/

        function ite( tf in boolean, yes in varchar2, no in varchar2 ) 
                return varchar2
         is
        begin
        if ( tf ) then
        return yes;
        else
        return no;
        end if;
        end ite;

     /******************************************************************/
    /* Internal procedures for new utilities                          */
   /******************************************************************/

        procedure bv( c in integer, n in varchar2, 
                      v in varchar2 character set any_cs )
         is
        begin
        if ( n is NOT NULL ) then
        dbms_sql.bind_variable( c, n, v );
        end if;
        end bv;


        function tochar( d in number, f in varchar2 ) return varchar2
         is
        begin
        return nvl(ltrim(to_char(d,f)), '(null)');
        end tochar;



        procedure format_cell(
           columnValue in varchar2 character set any_cs, 
           format_numbers in varchar2
        ) is
        begin
           htp.p(htf.format_cell(columnValue, format_numbers));
        end format_cell;

        function bind_outputs( p_theCursor in integer, 
                               colCnt in number, 
                               rec_tab in dbms_sql.desc_tab2 ) return number
        is
            columnValue        varchar2(1);
            ncolumnValue       nvarchar2(1);
            status            integer;
        begin
            for i in 1 .. colCnt loop
            begin
              if (rec_tab(i).col_charsetform = 2) or (rec_tab(i).col_type = 12)
              then
                 dbms_sql.define_column( p_theCursor, i, ncolumnValue,2000);
              else
                 dbms_sql.define_column( p_theCursor, i, columnValue, 2000 );
              end if;
                exception
                    when others then
                        if ( sqlcode = -1007 ) then
                            exit;
                        else
                            raise;
                        end if;
                end;
            end loop;
            status := dbms_sql.execute(p_theCursor);
            return colCnt;
        end bind_outputs;
        
        function path_to_me return varchar2
        is
                o       varchar2(50);
                n       varchar2(50);
                l       number;
                t       varchar2(50);
        begin
                who_called_me( o, n, l, t );
        
                return owa_util.get_cgi_env( 'SCRIPT_NAME' ) || '/' || n;
        end path_to_me;
        
        
     /******************************************************************/
    /* Procedure to get owner and name of the PL/SQL procedure        */
   /******************************************************************/

        procedure who_called_me( owner      out varchar2,
                                 name       out varchar2,
                                 lineno     out number,
                                 caller_t   out varchar2 )
        as
            call_stack  varchar2(4096) default dbms_utility.format_call_stack;
            n           number;
            found_stack BOOLEAN default FALSE;
            line        varchar2(255);
            t           varchar2(255);            
            cnt         number := 0;
        begin
        --
            loop
                n := instr( call_stack, NL_CHAR );
                exit when ( cnt = 3 or n is NULL or n = 0 );
        --
                line := ltrim(substr( call_stack, 1, n-1 ));
                call_stack := substr( call_stack, n+1 );
        --
                if ( NOT found_stack ) then
                    if ( line like '%handle%number%name%' ) then
                        found_stack := TRUE;
                    end if;
                else
                    cnt := cnt + 1;
                    -- cnt = 1 is ME
                    -- cnt = 2 is MY Caller
                    -- cnt = 3 is Their Caller
                    if ( cnt = 3 ) then
                        -- Fix 718865
                        --lineno := to_number(substr( line, 13, 6 ));
                        --line   := substr( line, 21 );
                        n := instr(line, ' ');
                        if (n > 0)
                        then
                            t := ltrim(substr(line, n));
                            n := instr(t, ' ');
                        end if;
                        if (n > 0)
                        then
                           lineno := to_number(substr(t, 1, n - 1));
                           line := ltrim(substr(t, n));
                        else
                            lineno := 0;
                        end if;
                        if ( line like 'pr%' ) then
                            n := length( 'procedure ' );
                        elsif ( line like 'fun%' ) then
                            n := length( 'function ' );
                        elsif ( line like 'package body%' ) then
                            n := length( 'package body ' );
                        elsif ( line like 'pack%' ) then
                            n := length( 'package ' );
	                else
	                    n := length( 'anonymous block ' );
                        end if;
	                caller_t := ltrim(rtrim(upper(substr( line, 1, n-1 ))));
                        line := substr( line, n );
                        n := instr( line, '.' );
                        owner := ltrim(rtrim(substr( line, 1, n-1 )));
                        name  := ltrim(rtrim(substr( line, n+1 )));
                    end if;
                end if;
            end loop;
        end;
        
        
     /******************************************************************/
    /* Function to initialize the shared dynamic SQL                  */
   /******************************************************************/

        function bind_variables
        (   theQuery in varchar2,
            bv1Name  in varchar2 default NULL, 
            bv1Value in varchar2 character set any_cs default NULL,
            bv2Name  in varchar2 default NULL,
            bv2Value in varchar2 character set any_cs default NULL,
            bv3Name  in varchar2 default NULL,
            bv3Value in varchar2 character set any_cs default NULL,
            bv4Name  in varchar2 default NULL,
            bv4Value in varchar2 character set any_cs default NULL,
            bv5Name  in varchar2 default NULL,
            bv5Value in varchar2 character set any_cs default NULL,
            bv6Name  in varchar2 default NULL,
            bv6Value in varchar2 character set any_cs default NULL,
            bv7Name  in varchar2 default NULL,
            bv7Value in varchar2 character set any_cs default NULL,
            bv8Name  in varchar2 default NULL,
            bv8Value in varchar2 character set any_cs default NULL,
            bv9Name  in varchar2 default NULL,
            bv9Value in varchar2 character set any_cs default NULL, 
            bv10Name  in varchar2 default NULL,
            bv10Value in varchar2 character set any_cs default NULL,
            bv11Name  in varchar2 default NULL,
            bv11Value in varchar2 character set any_cs default NULL,
            bv12Name  in varchar2 default NULL,
            bv12Value in varchar2 character set any_cs default NULL,
            bv13Name  in varchar2 default NULL,
            bv13Value in varchar2 character set any_cs default NULL,
            bv14Name  in varchar2 default NULL,
            bv14Value in varchar2 character set any_cs default NULL,
            bv15Name  in varchar2 default NULL,
            bv15Value in varchar2 character set any_cs default NULL,
            bv16Name  in varchar2 default NULL,
            bv16Value in varchar2 character set any_cs default NULL,
            bv17Name  in varchar2 default NULL,
            bv17Value in varchar2 character set any_cs default NULL,
            bv18Name  in varchar2 default NULL,
            bv18Value in varchar2 character set any_cs default NULL,
            bv19Name  in varchar2 default NULL,
            bv19Value in varchar2 character set any_cs default NULL,
            bv20Name  in varchar2 default NULL,
            bv20Value in varchar2 character set any_cs default NULL,
            bv21Name  in varchar2 default NULL,
            bv21Value in varchar2 character set any_cs default NULL,
            bv22Name  in varchar2 default NULL,
            bv22Value in varchar2 character set any_cs default NULL,
            bv23Name  in varchar2 default NULL,
            bv23Value in varchar2 character set any_cs default NULL,
            bv24Name  in varchar2 default NULL,
            bv24Value in varchar2 character set any_cs default NULL,
            bv25Name  in varchar2 default NULL,
            bv25Value in varchar2 character set any_cs default NULL )
        return integer
        is
            theCursor    integer;
        begin
            if ( upper( substr( ltrim( theQuery ), 1, 6 ) ) <> 'SELECT' ) then
                raise INVALID_QUERY;
            end if;
        --
            theCursor := dbms_sql.open_cursor;
            sys.dbms_sys_sql.parse_as_user( theCursor, theQuery, dbms_sql.native );
        --
            bv( theCursor, bv1Name, bv1Value );
            bv( theCursor, bv2Name, bv2Value );
            bv( theCursor, bv3Name, bv3Value );
            bv( theCursor, bv4Name, bv4Value );
            bv( theCursor, bv5Name, bv5Value );
            bv( theCursor, bv6Name, bv6Value );
            bv( theCursor, bv7Name, bv7Value );
            bv( theCursor, bv8Name, bv8Value );
            bv( theCursor, bv9Name, bv9Value );
            bv( theCursor, bv10name, bv10Value );
            bv( theCursor, bv11name, bv11Value );
            bv( theCursor, bv12name, bv12Value );
            bv( theCursor, bv13name, bv13Value );
            bv( theCursor, bv14name, bv14Value );
            bv( theCursor, bv15name, bv15Value );
            bv( theCursor, bv16name, bv16Value );
            bv( theCursor, bv17name, bv17Value );
            bv( theCursor, bv18name, bv18Value );
            bv( theCursor, bv19name, bv19Value );
            bv( theCursor, bv20name, bv20Value );
            bv( theCursor, bv21name, bv21Value );
            bv( theCursor, bv22name, bv22Value );
            bv( theCursor, bv23name, bv23Value );
            bv( theCursor, bv24name, bv24Value );
            bv( theCursor, bv25name, bv25Value );
        --
            return theCursor;
        end bind_variables;
        
        
     /******************************************************************/
    /* Procedure to print cells from a table                          */
   /******************************************************************/
        
        function cellsprint_fn( p_theCursor         in integer, 
                                p_max_rows          in number   default 100,
                                p_format_numbers    in varchar2 default NULL,
                                p_skip_rec          in number   default 0,
                                p_reccnt           out number)
        return boolean is
            columnValue varchar2(2000);
            ncolumnValue nvarchar2(2000);
            colCnt      number default 0;
            tmpcursor   number default p_theCursor;
            recIx       number default 0;
            recCnt      number default 0;
            rec_tab     dbms_sql.desc_tab2;
        begin
        --
            dbms_sql.describe_columns2(p_theCursor, colCnt, rec_tab);
            colCnt := bind_outputs(p_theCursor, colcnt, rec_tab);
        --
            while (recCnt < p_max_rows)
            loop
                exit when (dbms_sql.fetch_rows(p_theCursor) <= 0);
                recIx := recIx + 1;
                if (recIx > p_skip_rec)
                then
                    recCnt := recCnt + 1;
                    htp.tableRowOpen;
                    for i in 1..colCnt
                    loop
                       if (rec_tab(i).col_charsetform= 2) or
                          (rec_tab(i).col_type = 12)
                       then
                        dbms_sql.column_value(p_theCursor, i, ncolumnValue);
                        format_cell(ncolumnValue, p_format_numbers);
                       else
                        dbms_sql.column_value(p_theCursor, i, columnValue);
                        format_cell(columnValue, p_format_numbers);
                       end if;
                    end loop;
                    htp.tableRowClose;
                end if;
            end loop;
            dbms_sql.close_cursor(tmpCursor);
            p_reccnt := recCnt;
            return(recCnt >= p_max_rows);
        exception
            when others then
                if dbms_sql.is_open(p_theCursor) then
                    dbms_sql.close_cursor(tmpCursor);
                end if;
                raise;
        end cellsprint_fn;
        
        procedure cellsprint(p_colCnt         in integer, 
                             p_resultTbl      in vc_arr,
                             p_format_numbers in varchar2 default NULL)
        is
            recMax number;
            colRec number;
        begin
            if (p_colCnt < 1)
            then
               return;
            end if;
            recMax := p_resultTbl.count / p_colCnt;
            colRec := 0;
            for recIx in 1..recMax
            loop
               htp.tableRowOpen;
               for i in 1..p_colCnt
               loop
                  colRec := colRec + 1;
                  format_cell(p_resultTbl(colRec), p_format_numbers);
               end loop;
               htp.tableRowClose;
            end loop;
        end cellsprint;

        procedure cellsprint(p_colCnt         in integer,
                             p_resultTbl      in nc_arr,
                             p_format_numbers in varchar2 default NULL)
        is
            recMax number;
            colRec number;
        begin
            if (p_colCnt < 1)
            then
               return;
            end if;
            recMax := p_resultTbl.count / p_colCnt;
            colRec := 0;
            for recIx in 1..recMax
            loop
               htp.tableRowOpen;
               for i in 1..p_colCnt
               loop
                  colRec := colRec + 1;
                  format_cell(p_resultTbl(colRec), p_format_numbers);
               end loop;
               htp.tableRowClose;
            end loop;
        end cellsprint;
        
        procedure cellsprint( p_theQuery          in varchar2,
                              p_max_rows          in number default 100,
                              p_format_numbers    in varchar2 default NULL )
        is
            l_theCursor    integer default bind_variables(p_theQuery);
            l_more_data    boolean;
            reccnt         number;
        begin
            l_more_data := cellsprint_fn(
                                l_theCursor, p_max_rows,  p_format_numbers, 
                                0, reccnt);
        end;
            
        procedure cellsprint( p_theCursor         in integer, 
                              p_max_rows          in number  default 100,
                              p_format_numbers    in varchar2 default NULL )
        is
            l_more_data    boolean;
            reccnt         number;
        begin
            l_more_data := cellsprint_fn(
                                p_theCursor, p_max_rows,  p_format_numbers, 
                                0, reccnt);
        end;

        procedure cellsprint( p_theQuery          in varchar2,
                              p_max_rows          in number default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_skip_rec          in number default 0,
                              p_more_data        out boolean )
        is
            l_theCursor    integer default bind_variables(p_theQuery);
            reccnt         number;
        begin
            p_more_data := cellsprint_fn(
                                l_theCursor, p_max_rows,  p_format_numbers, 
                                p_skip_rec, reccnt);
        end cellsprint;
        
        procedure cellsprint( p_theCursor         in integer, 
                              p_max_rows          in number   default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_skip_rec          in number   default 0,
                              p_more_data        out boolean)
        is
            reccnt         number;
        begin
            p_more_data := cellsprint_fn(
                                p_theCursor, p_max_rows,  p_format_numbers, 
                                p_skip_rec, reccnt);
        end cellsprint;
        
        procedure cellsprint( p_theQuery          in varchar2,
                              p_max_rows          in number default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_reccnt           out number )
        is
            l_theCursor    integer default bind_variables(p_theQuery);
            l_more_data    boolean;
        begin
            l_more_data := cellsprint_fn(
                                l_theCursor, p_max_rows,  p_format_numbers, 
                                0, p_reccnt);
        end;
            
        procedure cellsprint( p_theCursor         in integer, 
                              p_max_rows          in number  default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_reccnt           out number )
        is
            l_more_data    boolean;
        begin
            l_more_data := cellsprint_fn(
                                p_theCursor, p_max_rows,  p_format_numbers, 
                                0, p_reccnt);
        end;

        procedure cellsprint( p_theQuery          in varchar2,
                              p_max_rows          in number default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_skip_rec          in number default 0,
                              p_more_data        out boolean,
                              p_reccnt           out number )
        is
            l_theCursor    integer default bind_variables(p_theQuery);
        begin
            p_more_data := cellsprint_fn(
                                l_theCursor, p_max_rows,  p_format_numbers, 
                                p_skip_rec, p_reccnt);
        end cellsprint;
        
        procedure cellsprint( p_theCursor         in integer, 
                              p_max_rows          in number   default 100,
                              p_format_numbers    in varchar2 default NULL,
                              p_skip_rec          in number   default 0,
                              p_more_data        out boolean,
                              p_reccnt           out number )
        is
        begin
            p_more_data := cellsprint_fn(
                                p_theCursor, p_max_rows,  p_format_numbers, 
                                p_skip_rec, p_reccnt);
        end cellsprint;
        
     /******************************************************************/
    /* Procedure to print a list from a query                         */
   /******************************************************************/

        procedure listprint( p_theCursor in integer,
                             p_cname     in varchar2,
                             p_nsize     in number,
                             p_multiple  in boolean default FALSE )
        is
            colCnt       number;
            value        varchar2(2000);
            visible      varchar2(2000);
            nc_visible   nvarchar2(2000);
            nc_value     nvarchar2(2000);
            selected     varchar2(2000);
            rec_tab      dbms_sql.desc_tab2;
            status       integer;
            csform       number;
        begin
            dbms_sql.describe_columns2(p_theCursor, colCnt, rec_tab);
            if (rec_tab(1).col_charsetform = 2 or
                rec_tab(2).col_charsetform = 2)
            then
                dbms_sql.define_column(p_theCursor, 1, nc_value, 2000);
                dbms_sql.define_column(p_theCursor, 2, nc_visible, 2000);
                csform := 2;
            else
                dbms_sql.define_column(p_theCursor, 1, value, 2000);
                dbms_sql.define_column(p_theCursor, 2, visible, 2000);
                csform := 1;
            end if;
            dbms_sql.define_column(p_theCursor, 3, selected, 2000);

            status := dbms_sql.execute(p_theCursor);

            htp.formSelectOpen( cname => p_cname,
                   nsize => p_nsize,
                   cattributes => ite( p_multiple,'multiple',NULL));
            loop
                exit when ( dbms_sql.fetch_rows(p_theCursor) <= 0 );
                if (csform = 2)
                then
                  dbms_sql.column_value( p_theCursor, 1, nc_value );
                  dbms_sql.column_value( p_theCursor, 2, nc_visible );
                  dbms_sql.column_value( p_theCursor, 3, selected );
                  htp.formSelectOption( cvalue => nc_visible,
                     cselected => ite( selected IS NULL, NULL, 'SELECT'),
                     cattributes => 'value="' || nc_value || '"' ); 
                else
                  dbms_sql.column_value( p_theCursor, 1, value );
                  dbms_sql.column_value( p_theCursor, 2, visible );
                  dbms_sql.column_value( p_theCursor, 3, selected );
                  htp.formSelectOption( cvalue => visible,
                    cselected => ite( selected IS NULL, NULL, 'SELECT'),
                    cattributes => 'value="' || value || '"' );
                end if;
            end loop;
            htp.formSelectClose;
        end listprint;
        
        procedure listprint( p_theQuery  in varchar2,
                             p_cname     in varchar2,
                             p_nsize     in number,
                             p_multiple  in boolean default FALSE )
        is
            theCursor    integer default bind_variables( p_theQuery );
        begin
            listprint( theCursor, p_cname, p_nsize, p_multiple );
        end listprint;
        
     /******************************************************************/
    /* Procedure to choose a date using HTML forms                    */
   /******************************************************************/

        procedure choose_date( p_name in varchar2, p_date in date default sysdate)
        is
                l_day           number default to_number(to_char(p_date,'DD'));
                l_mon           number default to_number(to_char(p_date,'MM'));
                l_year          number default to_number(to_char(p_date,'YYYY'));
        begin
            htp.formSelectOpen( cname => p_name, nsize => 1 );
                for i in 1 .. 31 loop
                htp.formSelectOption( cvalue => i, 
	                              cselected => ite( i=l_day, 'SELECTED', NULL ),
                                      cattributes => 'value="' || 
                                                                                        ltrim(to_char(i,'00')) || '"' );
                end loop;
                htp.formSelectClose;
                htp.p( '-' );
            htp.formSelectOpen( cname => p_name, nsize => 1 );
                for i in 1 .. 12 loop
                htp.formSelectOption( cvalue => to_nchar( to_date( i, 'MM' ), N'MON' ),
	                              cselected => ite( i=l_mon, 'SELECTED', NULL ),
                                      cattributes => 'value="' || 
                                                                                        ltrim(to_char(i,'00')) || '"' );
                end loop;
                htp.formSelectClose;
                htp.p( '-' );
            htp.formSelectOpen( cname => p_name, nsize => 1 );
                for i in l_year-5 .. l_year+5 loop
                htp.formSelectOption( cvalue => i,
	                              cselected => ite( i=l_year, 'SELECTED', NULL ),
                                      cattributes => 'value="' || 
                                                                                        ltrim(to_char(i,'0000')) || '"' );
                end loop;
                htp.formSelectClose;
        end;
        
        function todate( p_dateArray in dateType ) return date
        is
        begin
                return to_date( p_dateArray(1) || '-' || p_dateArray(2) || '-' ||
                                                p_dateArray(3), 'DD-MM-YYYY' );
        exception
                when no_data_found then
                        return NULL;
                when others then
                        return last_day( to_date( p_dateArray(2) || '-' || p_dateArray(3), 
                                                                        'MM-YYYY' ) );
        end todate;
        

     /******************************************************************/
    /* Procedure to print calender in HTML formats                    */
   /******************************************************************/

     /******************************************************************/
    /* Internal procedures                                            */
   /******************************************************************/


        function is_weekend( d in date ) return boolean
        is
        begin
                if (  to_char(d,'DY','NLS_DATE_LANGUAGE=AMERICAN') in ( 'SAT', 'SUN' ) ) then
                        return true;
                else
                        return false;
                end if;
        end is_weekend;
        

        procedure show_internal( p_mf_only in varchar2,
                                                         p_start in date,
                                                         p_dates in dateArray,
                                                         p_text  in vcArray,
                                                         p_link  in vcArray,
                                                         p_cnt   in number,
                                                         p_ntext in ncArray,
                                                         p_nlink in ncArray,
                                                         nchar_path boolean)
        as
                l_start date default trunc(p_start,'month');
                l_magic_date date default to_date('12111111','ddmmyyyy' );
                l_cnt        number default 0;
                l_width          varchar2(25) default 'width="15%"';
                l_loop_start             number default 0;
                l_loop_stop      number default 6;
                l_mf_only        boolean default upper(p_mf_only) = 'Y';
        begin
                if ( l_mf_only ) then
                        l_width := 'width="20%"';
                        l_loop_start := 1;
                        l_loop_stop := 5;
                end if;
        
                htp.tableOpen( cborder=>'border', cattributes=>'width="100%"' );
                htp.tableCaption( to_nchar( l_start, N'Month YYYY' ) );
        
                for i in l_loop_start .. l_loop_stop loop
                    htp.tableHeader( cvalue => to_nchar( l_magic_date+i, N'Day' ), cattributes => l_width );
                end loop;
                htp.tableRowOpen;
                loop
                        exit when to_nchar( l_magic_date, N'DY' ) = to_nchar(l_start, N'DY');
                        if ( not l_mf_only or not is_weekend(l_magic_date) ) then
                                htp.tableData( htf.br );
                        end if;
                        l_magic_date := l_magic_date+1;
                end loop;
        
                loop
                        exit when ( to_nchar( p_start, N'MON') <> to_nchar( l_start, N'MON') );
        
                        if ( not l_mf_only or not is_weekend(l_start) ) then
                                htp.p( '<td valign="TOP" '  || l_width || '>' );
                                htp.p( htf.italic(htf.bold(to_nchar(l_start,N'DD'))) || htf.br );
                        end if;
                
                        while(l_cnt < p_cnt AND to_nchar(l_start) = to_nchar(p_dates(l_cnt)) )
                        loop
                                if ( not l_mf_only or not is_weekend(l_start) ) then
                                        htp.p( '&#187;' );
                                        if (nchar_path) then
                                           if ( p_nlink(l_cnt) is NULL ) then
                                              htp.p( p_ntext(l_cnt) );
                                           else
                                              htp.anchor( p_nlink(l_cnt), p_ntext(l_cnt) );
                                           end if;
                                        else
                                           if ( p_link(l_cnt) is NULL ) then
                                              htp.p( p_text(l_cnt) );
                                           else
                                              htp.anchor( p_link(l_cnt), p_text(l_cnt) );
                                           end if;
                                        end if;
                                        htp.br;
                                end if;
                                l_cnt := l_cnt+1;
                        end loop;
                        if ( not l_mf_only or not is_weekend( l_start ) ) then
                                htp.p( '</td>' );
                        end if;
        
                        if ( to_char(l_start,'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SAT' ) then
                                htp.tableRowClose;
                                if ( l_start <> last_day(l_start) ) then
                                        htp.tableRowOpen;
                                end if;
                        end if;
                        l_start := l_start+1;
                end loop;
                if ( to_char(l_start ,'DY','NLS_DATE_LANGUAGE=AMERICAN') <> 'SUN' ) then
                        loop
                                if ( not l_mf_only or not is_weekend( l_start ) ) then
                                        htp.tableData( htf.br );
                                end if;
                                exit when ( to_char(l_start,'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SAT' );
                                l_start := l_start+1;
                        end loop;
                        htp.tableRowClose;
                end if;
                htp.tableClose;
        
        end show_internal;
        
        
     /******************************************************************/
    /* Procedure calendarprint                                       */
   /******************************************************************/

    procedure calendarprint( p_query in varchar2, p_mf_only in varchar2 default 'N' )
    is
        l_cursor integer default owa_util.bind_variables( p_query );
    begin
        calendarprint( l_cursor, p_mf_only );
        dbms_sql.close_cursor(l_cursor);
    exception
       when others then
            if dbms_sql.is_open(l_cursor) then
               dbms_sql.close_cursor(l_cursor);
            end if;
            raise;
    end calendarprint;
        
        
        procedure calendarprint( p_cursor in integer, p_mf_only in varchar2 default 'N' )
        is
                l_dates         dateArray;
                l_text          vcArray;
                l_ntext         ncArray;
                l_link          vcArray;
                l_nlink         ncArray;
                l_cnt           number;
                l_yyyymon       varchar2(7) default NULL;
                l_curr_date     date;
                csform          number;
                rec_tab         dbms_sql.desc_tab2;
                l_colcnt        number;
        begin
                l_dates(0) := NULL;
                l_text(0)  := NULL;
                l_link(0)  := NULL;
                l_ntext(0) := NULL;
                l_nlink(0) := NULL;
                l_colcnt:= 3;

                dbms_sql.describe_columns2(p_cursor, l_colcnt, rec_tab);
                dbms_sql.define_column( p_cursor, 1, l_dates(0) );                
                if (rec_tab(2).col_charsetform = 2) 
                then
                   csform := 2;
                   dbms_sql.define_column( p_cursor, 2, l_ntext(0), 2000 );
                   dbms_sql.define_column( p_cursor, 3, l_nlink(0), 2000 );
                else
                   dbms_sql.define_column( p_cursor, 2, l_text(0), 2000 );
                   dbms_sql.define_column( p_cursor, 3, l_link(0), 2000 );
                   csform := 1;
                end if; 
                l_cnt := dbms_sql.execute( p_cursor );
                l_cnt := 0;

                loop
                        exit when ( dbms_sql.fetch_rows( p_cursor ) <= 0 );
                        dbms_sql.column_value( p_cursor, 1, l_curr_date );
                        if (l_yyyymon is null)
                        then
                           l_yyyymon := to_char(l_curr_date, 'YYYYMON', 'NLS_DATE_LANGUAGE = AMERICAN');
                        end if;
        
                        if (to_char(l_curr_date, 'YYYYMON', 'NLS_DATE_LANGUAGE = AMERICAN') <> l_yyyymon)
                        then
                           show_internal( p_mf_only, l_dates(0), l_dates, 
                                l_text, l_link, l_cnt, l_ntext, l_nlink,
                                (csform = 2) );
                           l_cnt := 0;
                           l_yyyymon := to_char(l_curr_date, 'YYYYMON', 'NLS_DATE_LANGUAGE = AMERICAN');
                        end if;
                        l_dates(l_cnt) := l_curr_date;
                        if (csform = 2) then
                           dbms_sql.column_value( p_cursor, 2, l_ntext(l_cnt) );
                           dbms_sql.column_value( p_cursor, 3, l_nlink(l_cnt) );
                        else
                           dbms_sql.column_value( p_cursor, 2, l_text(l_cnt) );
                           dbms_sql.column_value( p_cursor, 3, l_link(l_cnt) );
                        end if;
                        l_cnt := l_cnt+1;
                end loop;
        
                if (l_cnt > 0)
                then
                  show_internal(p_mf_only, l_dates(0), l_dates, l_text, 
                                l_link, l_cnt, l_ntext, l_nlink, (csform = 2));
                end if;
        end calendarprint;
        
     /**********************************************************************/
    /* Function to obtain the procedure being invoked by the PL/SQL Agent */
   /**********************************************************************/
   function get_procedure return varchar2 is
      path_info  varchar2(255);
      procname   varchar2(255);
      procowner  varchar2(255);
   begin
      /* get PATH_INFO without the first '/' */
      path_info := get_cgi_env('PATH_INFO');
      --if (path_info like '/%') then
      --need to check if this is a flexible parameter so that we can take out
      if (substr(path_info, 1, 2) = '/!')
      then
         path_info := substr(path_info, 3);
      else
        if (substr(path_info, 1, 1) = '/')
        then
           path_info := substr(path_info, 2);
        end if;
      end if;

      /* resolve name and compose the real package.procedure */
      name_resolve(path_info, procowner, procname);
      return(procname);
   end;

     /**********************************************************************/
    /* Function to obtain the version number                              */
   /**********************************************************************/
   function get_version return varchar2 is
   begin
      return(owa_version);
   end;

     /**********************************************************************/
    /* Procedure to print the version number                              */
   /**********************************************************************/
   procedure print_version is
   begin
      htp.print('Current OWA toolkit version is '||owa_version);
   end;
end;
/
Show errors
