Rem  Copyright (c) 1996, 2008 by Oracle Corp.  All Rights Reserved.
Rem
Rem   NAME
Rem     pubcook.sql - Wrappers for passing HTTP_COOKIES using
Rem	              the Oracle Web Agent.
Rem   PURPOSE
Rem     
Rem   NOTES
Rem     This package depends on the PL/SQL package OWA_INIT,
Rem     namely, the constants DBMS_SERVER_GMTDIFF and
Rem     DBMS_SERVER_TIMEZONE, because HTTP cookies require
Rem     timestamps to be in GMT.
Rem
Rem   HISTORY
Rem     akatti     09/12/08 -  Fix bug#7626491 httponly default value corrected
Rem     akatti     06/10/08 -  Fix bug#7433906 Add httponly support for cooki
Rem     pkapasi    01/11/01 -  Fix bug#1580414
Rem     mbookman   02/06/96 -  Creation
Rem

create or replace package OWA_COOKIE is

   -- These procedures/functions are merely wrappers around
   -- calls to send an HTTP_COOKIE and to get an HTTP_COOKIE.
   -- One should be familiar with the specification for 
   -- HTTP cookies before attempting to use these subprograms.

   -- The HTTP specification for a COOKIE indicates that it
   -- cookie name/value pairs should not exceed 4k in size.
   type vc_arr is table of varchar2(4096) index by binary_integer;

   -- structure for cookies, as you could have multiple values
   -- associated with a single cookie name.
   type cookie is RECORD
   (
      name     varchar2(4096),
      vals     vc_arr,
      num_vals integer
   );
   -- Initializes the owa_cookie package variables (called by htp.init)
   procedure init;

   -- Calls to the procedure SEND generate an HTTP header line
   -- of the form:
   -- Set-Cookie: <name>=<value> expires=<expires> path=<path> 
   --             domain=<domain> [secure] [HttpOnly]
   -- Only the name and value are required (as per the HTTP_COOKIE spec),
   -- and the default is non-secure.
   -- Calls to SEND must fall in the context of an OWA procedure's
   -- HTTP header output.  For example:

   -- begin
   --    owa_util.mime_header('text/html', FALSE);
   --                -- FALSE indicates not to close the header
   --    owa_cookie.send('ITEM1','SOCKS');
   --    owa_cookie.send('ITEM2','SHOES');
   --    owa_util.http_header_close;
   --
   --    -- Now output the page the user will see.
   --    htp.htmlOpen;
   --    <etc>
   procedure send(name     in varchar2,
                  value    in varchar2,
                  expires  in date     DEFAULT NULL,
                  path     in varchar2 DEFAULT NULL,
                  domain   in varchar2 DEFAULT NULL,
                  secure   in varchar2 DEFAULT NULL,
                  httponly in varchar2 DEFAULT NULL);

   -- GET will return an OWA_COOKIE.COOKIE structure
   -- for the specified cookie name.
   function get(name in varchar2) return cookie;

   -- REMOVE will simply force the expiration of an existing cookie.
   -- This call must come within the context of an HTTP header.
   -- See the definition of SEND above.
   -- REMOVE generates a line which looks like:
   -- Set-Cookie: <name>=<value> expires=01-JAN-1990
   procedure remove(name in varchar2,
                    val  in varchar2,
                    path in varchar2 DEFAULT NULL);

   -- GET_ALL returns an array of name/value pairs of all HTTP_COOKIES
   -- sent from the browser.  The name/value pairs appear in the order
   -- that they were sent from the browser.
   procedure get_all(names    out vc_arr,
                     vals     out vc_arr,
                     num_vals out integer);
end;
/
show errors
