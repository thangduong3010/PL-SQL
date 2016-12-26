Rem Copyright (c) 1995, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem   NAME
Rem     privcook.sql - Wrappers for passing HTTP_COOKIES using
Rem	               the Oracle Web Agent.
Rem   PURPOSE
Rem     
Rem   NOTES
Rem
Rem   HISTORY
Rem     akatti     10/06/08 -  Fix bug#7433906 Add httponly support for cookie
Rem     akatti     11/10/05 -  Fix bug#4722130 validate args of send
Rem     ehlee      10/16/01 -  Fix parsing problem for cookie (bug#1819121)
Rem     pkapasi    09/24/01 -  Fix bug#1423101
Rem     pkapasi    01/11/01 -  Fix bug#1580414
Rem     ehlee      10/11/00 -  Fix NLS bug in remove (bug#1455428)
Rem     rdasarat   01/21/98 -  Fix 607222
Rem     mpal       07/09/97 -  Implementing CUSTOM scheme
Rem     mpal       10/25/96 -  Fix bug #414830
Rem     mpal       10/03/96 -  Fix bug #355403
Rem     mbookman   02/06/96 -  Creation
Rem

create or replace package body OWA_COOKIE is

   cookie_names vc_arr;
   cookie_vals  vc_arr;
   cookie_num_vals integer;

   cookies_parsed boolean;

   /*  NL_CHAR can be computed from a Unicode string in a portable manner. */
   NL_CHAR constant varchar2(10) := owa_cx.nl_char;
   /* Constant is set here instead of owachars to avoid invalid objects */
   CR_CHAR constant varchar2(10) := chr(13);

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

   procedure init is
   begin
      cookies_parsed := FALSE;
   end init;

   function IFNOTNULL(val1 in varchar2,
                      val2 in varchar2) return varchar2 is
   begin
      if (val1 is not null)
      then
         return val2;
      else
         return NULL;
      end if;
   end;

   procedure http_cookie2array(names    out vc_arr,
                               vals     out vc_arr,
                               num_vals out integer) is
      http_cookie varchar2(32767);

      start_loc  integer;
      end_loc    integer;
      equal_sign integer;

      val_counter integer;
   begin
      http_cookie := owa_util.get_cgi_env('HTTP_COOKIE');

      val_counter := 0;

      /* If the last character is a ';', trim it out */
      if (substr(http_cookie, -1) = ';')
      then
         http_cookie := substr(http_cookie, 1, length(http_cookie)-1);
      end if;

      if (http_cookie is not NULL)
      then
         start_loc := 1;
         end_loc := instr(http_cookie, ';', start_loc);
         while (end_loc != 0)
         loop
            val_counter := val_counter+1;
            equal_sign := instr(http_cookie, '=', start_loc);

            -- If the equal sign is beyond this cookie, set the value to null
            if (equal_sign = 0 or equal_sign > end_loc)
            then
               names(val_counter) := ltrim(substr(http_cookie, start_loc,
                                                  end_loc - start_loc));
               vals(val_counter) := null;
            else
               names(val_counter) := ltrim(substr(http_cookie, start_loc,
                                                  equal_sign-start_loc));
               vals(val_counter) := substr(http_cookie, equal_sign+1,
                                           end_loc - equal_sign - 1);
            end if;

            start_loc := end_loc + 1;
            end_loc := instr(http_cookie, ';', start_loc);
         end loop;
   
         val_counter := val_counter + 1;
         equal_sign := instr(http_cookie, '=', start_loc);

         -- If there is no equal sign in last cookie, set the value to null
         if (equal_sign = 0)
         then
            names(val_counter) := ltrim(substr(http_cookie, start_loc));
            vals(val_counter) := null;
         else
            names(val_counter) := ltrim(substr(http_cookie, start_loc,
                                               equal_sign-start_loc));
            vals(val_counter) := substr(http_cookie, equal_sign+1);
         end if;

      end if;

      num_vals := val_counter;
   end;

   procedure send(name     in varchar2,
                  value    in varchar2,
                  expires  in date     DEFAULT NULL,
                  path     in varchar2 DEFAULT NULL,
                  domain   in varchar2 DEFAULT NULL,
                  secure   in varchar2 DEFAULT NULL,
                  httponly in varchar2 DEFAULT NULL) is
      expires_gmt date;
      l_name      varchar2(32767);
      l_value     varchar2(32767);
      l_path      varchar2(32767);
      l_domain    varchar2(32767);
      l_secure    varchar2(32767);
      l_httponly  varchar2(32767);
   begin
      -- Validate parameters
      l_name := validate_arg(name);
      l_value := validate_arg(value);
      l_path := validate_arg(path);
      l_domain := validate_arg(domain);
      l_secure := validate_arg(secure);
      l_httponly := validate_arg(httponly);

      if (OWA_CUSTOM.DBMS_SERVER_GMTDIFF is not NULL)
      then
         expires_gmt := expires-(OWA_CUSTOM.DBMS_SERVER_GMTDIFF/24);
      else
         expires_gmt := new_time(expires,OWA_CUSTOM.DBMS_SERVER_TIMEZONE,'GMT');
      end if;

      -- When setting the cookie expiration header
      -- we need to set the nls date language to AMERICAN
      -- since the cookie line needs to be in English.
      -- If the NLS_LANGUAGE of the database is other than
      -- English, the expires tag is not understood by the browser.
      htp.print('Set-Cookie: '||l_name||'='||l_value||';'||
                 IFNOTNULL(expires_gmt, ' expires='||
                    rtrim(to_char(expires_gmt,'Dy',
                        'NLS_DATE_LANGUAGE = American'))||
                    to_char
                    (
                        expires_gmt,
                        ', DD-Mon-YYYY HH24:MI:SS',
                        'NLS_DATE_LANGUAGE = American'
                    )||' GMT;')||
                 IFNOTNULL(l_path,     ' path='||l_path||';')||
                 IFNOTNULL(l_domain,   ' domain='||l_domain||';')||
                 IFNOTNULL(l_secure,   ' secure;')||
                 IFNOTNULL(l_httponly, ' HttpOnly'));
   end;

   function make_cookie(name in varchar2 DEFAULT NULL) return cookie is
      choc_chip cookie;
   begin
      choc_chip.num_vals := 0;
      choc_chip.name := name;
      
      return choc_chip;
   end;

   function get(name in varchar2) return cookie is
      choc_chip cookie;
   begin
      if (NOT cookies_parsed)
      then
         http_cookie2array(cookie_names, cookie_vals, cookie_num_vals);
         cookies_parsed := TRUE;
      end if;

      choc_chip := make_cookie(name);

      /* This is not the most efficient thing to do. */
      /* should probably have cookie2array sort */
      /* then we could do binary search here.   */
      for i in 1..cookie_num_vals
      loop
         if (cookie_names(i) = name)
         then
            choc_chip.num_vals := choc_chip.num_vals + 1;
            choc_chip.vals(choc_chip.num_vals) := cookie_vals(i);
         end if;
      end loop;

      return choc_chip;
   end;

   procedure remove(name in varchar2,
                    val  in varchar2,
                    path in varchar2 DEFAULT NULL) is
   begin
      send(name, val, to_date('01-01-1990','DD-MM-YYYY'));
   end;

   procedure get_all(names    out vc_arr,
                     vals     out vc_arr,
                     num_vals out integer) is
   begin
      if (NOT cookies_parsed)
      then
         http_cookie2array(cookie_names, cookie_vals, cookie_num_vals);
         cookies_parsed := TRUE;
      end if;
      names := cookie_names;
      vals := cookie_vals;
      num_vals := cookie_num_vals;
   end;

begin
   cookies_parsed := FALSE;
end;
/
show errors
