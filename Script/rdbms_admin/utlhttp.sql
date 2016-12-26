REM
REM utlhttp.sql
REM
REM Copyright (c) 1996, 2008, Oracle. All rights reserved.  
REM
REM    NAME
REM      utlhttp.sql - HTTP requests from stored programs
REM
REM    DESCRIPTION
REM     Package contains functions and procedures to make HTTP requests from
REM     stored programs.
REM
REM    NOTES
REM     None
REM
REM    MODIFIED   (MM/DD/YY)
REM    rpang       02/01/08 - Misc Amazon S3 enhancements
REM    rpang       09/27/06 - Added network_access_denied exception
REM    rpang       05/04/06 - Made invoker rights routine
REM    sursrini    07/23/03 - 2467239: Support Expect 100 Continue
REM    sylin       12/06/02 - 2351330: Add NCAHR support
REM    sursrini    10/23/02 - 2528866: Added support for authentication in URL
REM    rpang       07/23/01 - 1840818: explain unsupported character set cond'n
REM    rpang       06/06/01 - 1777438: noted new exceptions from begin_request
REM    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
REM    rpang       04/02/01 - Updated example
REM    rpang       02/20/01 - Added set_transfer_timeout for request
REM    rpang       02/16/01 - Added partial_multibyte_char exception
REM    rpang       02/12/01 - Moved get_response to response API category
REM    rpang       02/12/01 - Set default value for set_cookie_support to TRUE
REM    rpang       01/16/01 - Changed resolution of timeout to seconds
REM    rpang       01/08/01 - Modified persistent connection descriptor
REM    rpang       12/06/00 - Added set_cookie_support for request
REM    rpang       11/27/00 - Modified session-default API
REM    rpang       10/20/00 - Added SSL information to connecton record
REM    rpang       10/05/00 - Noted that method field is also updated on redir
REM    rpang       09/01/00 - Added function get_body_charset
REM    rpang       08/17/00 - Fixed comments
REM    rpang       07/26/00 - Added configuration API
REM    rpang       07/21/00 - Added charset API
REM    rpang       05/23/00 - Added new API
REM    jmuller     10/07/99 - Fix bug 708690: TAB -> blank
REM    rpang       09/03/99 - Should set wallet before making request
REM    rpang       08/04/99 - Extended API to support HTTPS
REM    jmuller     05/28/99 - Fix bug 708690: TAB -> blank
REM    rdecker     08/20/98 - add proxy param to request calls
REM    jmuller     08/21/98 - Fix bug 500845: add documentation on proxies
REM    gclossma    04/25/97 - raw => number for ptr_t
REM    gclossma    01/30/97 - fix documentation
REM    gclossma    01/28/97 - add fetch_more_data
REM    gclossma    12/11/96 - add grant to public
REM    gclossma    12/10/96 - for 7.3.3
REM    gclossma    08/28/96 - utl_SQurL => utl_http
REM    gclossma    08/19/96 - SQurL http callouts
REM    gclossma    08/19/96 - Created

CREATE OR REPLACE PACKAGE utl_http AUTHID CURRENT_USER IS
   
  /******************************************************************
  
  The UTL_HTTP package makes Hypertext Transfer Protocol (HTTP) callouts
  from SQL and PL/SQL.  It can be used to access data on the Internet over
  the HTTP protocol.

  The package contains a set of API that enables users to write PL/SQL
  programs that communicate with Web (HTTP) servers.  It also contains a
  function that can be used in SQL queries.  Besides the HTTP protocol, it
  also supports the HTTP protocol over the Secured Socket Layer protocol (SSL),
  also known as HTTPS, directly or via a HTTP proxy.  Other Internet-related
  data-access protocols (such as the File Transfer Protocol (FTP) or
  the Gopher protocol) are also supported via a HTTP proxy server that
  supports those protocols.

  When the package fetches data from a Web site using the HTTPS protocol,
  it requires an Oracle wallet to be set up properly by Oracle Wallet Manager.
  Non-HTTPS fetches do not require an Oracle wallet.

  The API is divided into a number of categories.  The session API manipulates
  configurations pertaining to the package within a database user session.
  The request API begins a new HTTP request, manipulates its attributes,
  and sends information to the Web server.  The response API returns the
  attributes of the response and receives information the response data
  from the Web server.  The cookies API manipulates the HTTP cookies maintained
  by the package within the database user session.  The persistent connection
  API manipulates the persistent connections maintained by the package.  There
  are also two simple functions that allow users to fetch a Web page by
  a single function call.

  The following is an example that illustrate the use of the session,
  request, and response API to pretend to be the Netscape brower to fetch
  a Web page.

  SET serveroutput ON SIZE 40000
  
  DECLARE
    req   utl_http.req;
    resp  utl_http.resp;
    value VARCHAR2(1024);
  BEGIN

    utl_http.set_proxy('proxy.it.my-company.com', 'my-company.com');

    req := utl_http.begin_request('http://www-hr.corp.my-company.com');
    utl_http.set_header(req, 'User-Agent', 'Mozilla/4.0');
    resp := utl_http.get_response(req);
    LOOP
      utl_http.read_line(resp, value, TRUE);
      dbms_output.put_line(value);
    END LOOP;
    utl_http.end_response(resp);
  EXCEPTION
    WHEN utl_http.end_of_body THEN
      utl_http.end_response(resp);
  END;

  The following is another example that illustrates how to use the simple
  API to fetch a Web page in SQL (only the first 2000 bytes will be returned).
  
  SVRMGR> select utl_http.request('http://www.oracle.com/')
       2  from dual;
  UTL_HTTP.REQUEST('HTTP://WWW.ORACLE.COM/')
  ----------------------------------------------------------
  <html>
  <head><title>Oracle Corporation Home Page</title>
  <!--changed Jan. 16, 19
  1 row selected.

  Here is another example that illustrates how to use the other simple API
  to fetch the complete Web page:

  set serveroutput on

  declare
    x   utl_http.html_pieces;
    len pls_integer;
  begin
    x := utl_http.request_pieces('http://www.oracle.com/', 100);
    dbms_output.put_line(x.count || ' pieces were retrieved.');
    dbms_output.put_line('with total length ');
    len := 0;
    for i in 1..x.count loop
      len := len + length(x(i));
    end loop;
    dbms_output.put_line(len);
  end;

  Here is the output:

  Statement processed.
  4 pieces were retrieved.
  with total length
  7687

  ***********************************************************************/

  -- The HTTP protocol versions that can be used in the function begin_request
  HTTP_VERSION_1_0  CONSTANT VARCHAR2(64) := 'HTTP/1.0'; -- HTTP 1.0
  HTTP_VERSION_1_1  CONSTANT VARCHAR2(64) := 'HTTP/1.1'; -- HTTP 1.1

  -- The default TCP/IP port numbers that a HTTP server listens
  DEFAULT_HTTP_PORT  CONSTANT PLS_INTEGER := 80; -- HTTP server or proxy server
  DEFAULT_HTTPS_PORT CONSTANT PLS_INTEGER := 443; -- HTTPS server

  -- HTTP status codes of a HTTP response as defined in HTTP 1.1
  HTTP_CONTINUE                   CONSTANT PLS_INTEGER := 100;
  HTTP_SWITCHING_PROTOCOLS        CONSTANT PLS_INTEGER := 101;
  HTTP_OK                         CONSTANT PLS_INTEGER := 200;
  HTTP_CREATED                    CONSTANT PLS_INTEGER := 201;
  HTTP_ACCEPTED                   CONSTANT PLS_INTEGER := 202;
  HTTP_NON_AUTHORITATIVE_INFO     CONSTANT PLS_INTEGER := 203;
  HTTP_NO_CONTENT                 CONSTANT PLS_INTEGER := 204;
  HTTP_RESET_CONTENT              CONSTANT PLS_INTEGER := 205;
  HTTP_PARTIAL_CONTENT            CONSTANT PLS_INTEGER := 206;
  HTTP_MULTIPLE_CHOICES           CONSTANT PLS_INTEGER := 300;
  HTTP_MOVED_PERMANENTLY          CONSTANT PLS_INTEGER := 301;
  HTTP_FOUND                      CONSTANT PLS_INTEGER := 302;
  HTTP_SEE_OTHER                  CONSTANT PLS_INTEGER := 303;
  HTTP_NOT_MODIFIED               CONSTANT PLS_INTEGER := 304;
  HTTP_USE_PROXY                  CONSTANT PLS_INTEGER := 305;
  HTTP_TEMPORARY_REDIRECT         CONSTANT PLS_INTEGER := 307;
  HTTP_BAD_REQUEST                CONSTANT PLS_INTEGER := 400;
  HTTP_UNAUTHORIZED               CONSTANT PLS_INTEGER := 401;
  HTTP_PAYMENT_REQUIRED           CONSTANT PLS_INTEGER := 402;
  HTTP_FORBIDDEN                  CONSTANT PLS_INTEGER := 403;
  HTTP_NOT_FOUND                  CONSTANT PLS_INTEGER := 404;
  HTTP_NOT_ACCEPTABLE             CONSTANT PLS_INTEGER := 406;
  HTTP_PROXY_AUTH_REQUIRED        CONSTANT PLS_INTEGER := 407;
  HTTP_REQUEST_TIME_OUT           CONSTANT PLS_INTEGER := 408;
  HTTP_CONFLICT                   CONSTANT PLS_INTEGER := 409;
  HTTP_GONE                       CONSTANT PLS_INTEGER := 410;
  HTTP_LENGTH_REQUIRED            CONSTANT PLS_INTEGER := 411;
  HTTP_PRECONDITION_FAILED        CONSTANT PLS_INTEGER := 412;
  HTTP_REQUEST_ENTITY_TOO_LARGE   CONSTANT PLS_INTEGER := 413;
  HTTP_REQUEST_URI_TOO_LARGE      CONSTANT PLS_INTEGER := 414;
  HTTP_UNSUPPORTED_MEDIA_TYPE     CONSTANT PLS_INTEGER := 415;
  HTTP_REQ_RANGE_NOT_SATISFIABLE  CONSTANT PLS_INTEGER := 416;
  HTTP_EXPECTATION_FAILED         CONSTANT PLS_INTEGER := 417;
  HTTP_NOT_IMPLEMENTED            CONSTANT PLS_INTEGER := 501;
  HTTP_BAD_GATEWAY                CONSTANT PLS_INTEGER := 502;
  HTTP_SERVICE_UNAVAILABLE        CONSTANT PLS_INTEGER := 503;
  HTTP_GATEWAY_TIME_OUT           CONSTANT PLS_INTEGER := 504;
  HTTP_VERSION_NOT_SUPPORTED      CONSTANT PLS_INTEGER := 505;
  
  -- Exceptions
  --
  -- NOTES:
  --   The partial_multibyte_char and transfer_timeout exceptions are
  -- duplicates of the same exceptions as defined in the UTL_TCP package.
  -- They are defined in this package so that the use of this package does not
  -- require the knowledge of the UTL_TCP package.  As those exceptions
  -- are duplicates, an exception handle which catches the
  -- partial_multibyte_char and transfer_timeout exceptions in this
  -- package also catches those exceptions in the UTL_TCP package.
  --
  init_failed            EXCEPTION;  -- The UTL_HTTP pkg initialization failed
  request_failed         EXCEPTION;  -- The HTTP request failed
  bad_argument           EXCEPTION;  -- A bad argument was passed to an API
  bad_url                EXCEPTION;  -- The URL is bad
  protocol_error         EXCEPTION;  -- A HTTP protocol error occurred
  unknown_scheme         EXCEPTION;  -- The scheme of the URL is unknown
  header_not_found       EXCEPTION;  -- The HTTP header is not found
  end_of_body            EXCEPTION;  -- The end of response body is reached
  illegal_call           EXCEPTION;  -- The API call is illegal at this stage
  http_client_error      EXCEPTION;  -- A 4xx response code is returned
  http_server_error      EXCEPTION;  -- A 5xx response code is returned
  too_many_requests      EXCEPTION;  -- Too many open requests or responses
  partial_multibyte_char EXCEPTION;  -- A partial multi-byte character found
  transfer_timeout       EXCEPTION;  -- Transfer time-out occurred
  network_access_denied  EXCEPTION;  -- Network access denied

  PRAGMA EXCEPTION_INIT(init_failed,           -29272);
  PRAGMA EXCEPTION_INIT(request_failed,        -29273);
  PRAGMA EXCEPTION_INIT(bad_argument,          -29261);
  PRAGMA EXCEPTION_INIT(bad_url,               -29262);
  PRAGMA EXCEPTION_INIT(protocol_error,        -29263);
  PRAGMA EXCEPTION_INIT(unknown_scheme,        -29264);
  PRAGMA EXCEPTION_INIT(header_not_found,      -29265);
  PRAGMA EXCEPTION_INIT(end_of_body,           -29266);
  PRAGMA EXCEPTION_INIT(illegal_call,          -29267);
  PRAGMA EXCEPTION_INIT(http_client_error,     -29268);
  PRAGMA EXCEPTION_INIT(http_server_error,     -29269);
  PRAGMA EXCEPTION_INIT(too_many_requests,     -29270);
  PRAGMA EXCEPTION_INIT(partial_multibyte_char,-29275);
  PRAGMA EXCEPTION_INIT(transfer_timeout,      -29276);
  PRAGMA EXCEPTION_INIT(network_access_denied, -24247);

  -- VARCHAR2 table for returning HTML from request_pieces
  TYPE html_pieces IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  
  -- A PL/SQL record type that represents a HTTP request
  TYPE req IS RECORD (
    url                    VARCHAR2(32767 byte), -- Requested URL
    method                 VARCHAR2(64),    -- Requested method
    http_version           VARCHAR2(64),    -- Requested HTTP version
    private_hndl           PLS_INTEGER      -- For internal use only
  );

  -- A PL/SQL record type that represents a HTTP response
  TYPE resp IS RECORD (
    status_code            PLS_INTEGER,     -- Response status code
    reason_phrase          VARCHAR2(256),   -- Response reason phrase
    http_version           VARCHAR2(64),    -- Response HTTP version
    private_hndl           PLS_INTEGER      -- For internal use only
  );
  /* Note:
   * - the "private_xxxx" field(s) in the req and resp record types are for
   *   internal use only and users should not try to modify them.
   * - the HTTP information returned in the req and resp from the API
   *   begin_request and get_response are for read only.  Changing the
   *   field values in the records has no effect to request or reesponse
   *   when making calls to the API in this package.
   */

  -- A PL/SQL record type that represents a HTTP cookie
  TYPE cookie IS RECORD (
    name     VARCHAR2(256),   -- Cookie name
    value    VARCHAR2(1024),  -- Cookie value
    domain   VARCHAR2(256),   -- Domain for which the cookie applies
    expire   TIMESTAMP WITH TIME ZONE,  -- When should the cookie expire ?
    path     VARCHAR2(1024),  -- Virtual path for which the cookie applies
    secure   BOOLEAN,         -- Should the cookie be transferred by HTTPS only
    version  PLS_INTEGER,     -- Cookie specification version
    comment  VARCHAR2(1024)   -- Comments about this cookie
  );
  -- A PL/SQL table of cookies
  TYPE cookie_table IS TABLE OF cookie INDEX BY BINARY_INTEGER;

  -- A PL/SQL record type that represents the host name(s) and TCP/IP port
  -- number(s) of a HTTP persistent connection that is maintained in
  -- the current database session.
  --
  -- For a direct HTTP persistent connection to a Web server, the host and
  -- port fields contain the host name and TCP/IP port number of the Web
  -- server.  The proxy_host and proxy_port fields are not set.  For a HTTP
  -- persistent connection that was previously used to connect to a Web
  -- server via a proxy, the proxy_host and proxy_port fields contains
  -- the host name and TCP/IP port number of the proxy server.  The host
  -- and port fields are not set, which indicates that the persistent
  -- connection, while connected to a proxy server, is not bound to any
  -- particular target Web server.  As a matter of fact, a HTTP persistent
  -- connection to a proxy server can be used to access any target Web server
  -- to be accessed via the proxy.
  --
  -- The ssl field indicates if Secured Socket Layer (SSL) is being used in a
  -- HTTP persistent connection or not. Note that a HTTPS request is a HTTP
  -- request made over SSL.  For a HTTPS (SSL) persistent connection connected
  -- via a proxy, the host and port fields contain the host name and TCP/IP
  -- port number of the target HTTPS Web server and the fields will always be
  -- set.  As a matter of fact, a HTTPS persistent connection to a HTTPS
  -- Web server via a proxy server can only be reused to make another request
  -- to the same target Web server.
  --
  TYPE connection IS RECORD (
    host       VARCHAR2(256), -- The host this persistent conn. is connected to
    port       PLS_INTEGER,   -- The port this persistent conn. is connected to
    proxy_host VARCHAR2(256), -- The proxy host this persistent conn. is
                              -- connected to
    proxy_port PLS_INTEGER,   -- The proxy port this persistent conn. is
                              -- connected to
    ssl        BOOLEAN        -- Is this a SSL connection?
  );
  -- A PL/SQL table of persistent connections
  TYPE connection_table IS TABLE OF connection INDEX BY BINARY_INTEGER;

  -- A PL/SQL type that represents the key to a request context. A request
  -- context is a context that holds a wallet and a cookie for private use 
  -- in making a HTTP request.
  SUBTYPE request_context_key is PLS_INTEGER;

  /*-------------------------- Session API ------------------------------*/
  /* The following set of API manipulate the configuration and default
   * behavior of this package when executing HTTP requests within a database
   * user session. When a request is created, it inherits the default settings
   * of the HTTP cookie support, follow-redirect, body character set,
   * persistent-connection support, and transfer time-out of the current
   * session. Those settings may be changed later by calling the request API.
   * When a response is created for a request, it inherits those settings from 
   * the request. Only the body character set may be changed later by calling
   * the response API.
   */
  
  /**
   * Sets the proxy to be used for requests of the HTTP or other protocols,
   * excluding those for hosts which belong to the domain specified in
   * no_proxy_domains. proxy may include an optional TCP/IP port number
   * at which the proxy server listens at. If the port is not specified for the
   * proxy, port 80 is assumed.
   *
   * no_proxy_domains is a list of domains or hosts for which HTTP requests
   * should be sent directly to the destination HTTP server instead of going
   * through a proxy server. Optionally, a port number may be specified for
   * each domain or host. If the port number is specified, the no-proxy
   * restriction is only applied to the request at that port of the particular
   * domain or host. . When no_proxy_domains is
   * NULL and proxy is set, all requests go through the proxy. When proxy
   * is not set, UTL_HTTP sends the requests to the target Web servers
   * directly.
   *
   * PARAMETERS
   *   proxy             The proxy host and port number. The syntax is
   *                     "[http://]host[:port][/]".  For example,
   *                     "www-proxy.my-company.com:80".
   *   no_proxy_domains  The list of no-proxy domains or hosts.  The syntax is
   *                     a list of host or domains, with optional port numbers
   *                     separated by a comma, a semi-colon, or a space.
   *                     Example: "corp.my-company.com, eng.my-company.com:80"
   * RETURN
   *   None
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   When a database session starts, it will assume the proxy settings
   *   in the environment variables "http_proxy" and "no_proxy" if they are
   *   set when the database server instance is started. Proxy settings set
   *   by this procedure overrides the initial settings.
   *
   *  The general format would be 
   *                [http://][<user>[:<password>]@]<host>[:<port>].
   *  Suppose the proxy parameter has username and password, then 
   *  begin_request will do the authentication also on the proxy.  
   */
  PROCEDURE set_proxy(proxy            IN VARCHAR2,
                      no_proxy_domains IN VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_proxy, wnds, rnds, trust);

  /**
   * Retrieves the current proxy settings
   *
   * PARAMETERS
   *   proxy              The proxy host and port number.
   *   no_proxy_domains   The list of no-proxy domains or hosts.
   * RETURN
   *   None
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_proxy(proxy            OUT NOCOPY VARCHAR2,
                      no_proxy_domains OUT NOCOPY VARCHAR2);
  PRAGMA restrict_references(get_proxy, wnds, rnds, trust);

  /**
   * Sets whether future HTTP requests should support the HTTP cookies or not,
   * and the maximum numbers of cookies to be maintained in the current
   * database user session.
   *
   * If the cookie support is enabled for a HTTP request, all cookies that
   * are saved in the current session and are applicable to the request will
   * be returned to the Web server in the request in accordance to the HTTP
   * cookies specification RFC 2109 and to the draft proposal by Netscape
   * Communications Corporation. Cookies that are set in the response to
   * the request will be saved in the current session for return to the Web
   * server in the subsequent requests if the cookie support is enabled
   * for those requests. If the cookie support is disabled for a HTTP request,
   * no cookies will be returned to the Web server in the request and the
   * cookies set in the response to the request will not be saved in the
   * current session, although the "Set-Cookie" HTTP headers can still be
   * retrieved from the response.
   *
   * The cookie support is enabled for all HTTP requests by default in a
   * database user session. The default maximum numbers of cookies saved in
   * the current session totally and per-site are 300 and 20 respectively.
   * Use this procedure to change the default settings. The default setting
   * of the cookie support (enabled vs. disabled) affects only the future
   * requests and has no effect on the existing ones.
   *
   * Once a request is created, the cookie support setting may be changed
   * by using the other set_cookie_support procedure that operates
   * on a request.
   *
   * PARAMETERS
   *   enable        Sets whether future HTTP requests should support HTTP
   *                 cookies or not. TRUE to enable the support, FALSE to
   *                 disable it.
   *   max_cookies   Sets the maximum total number of cookies that will be
   *                 maintained in the current session.
   *   max_cookies_per_site  Sets the maximum number of cookies per each Web
   *                         site that will be maintained in the current
   *                         session.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   If the maximum total number of cookies and the maximum number of cookies
   *   per each Web site are lowered when this procedure is called, the
   *   oldest cookies will be purged first to reduce the number of cookies
   *   to satisfy those new maximum limits.
   *
   *   Note that the HTTP cookies saved in the current session will last for
   *   the duration of the database session only and there is no persistent
   *   storage for the cookies. An example is given in the package
   *   documentation to illustrate how to use get_cookies and add_cookies
   *   to retrieve, save, and restore the cookies.
   *
   *   Note that setting the default setting of the cookie support to disabled
   *   with this procedure does not cause the cookies saved in the current
   *   session to be cleared.
   */
  PROCEDURE set_cookie_support(enable               IN BOOLEAN,
                               max_cookies          IN PLS_INTEGER DEFAULT 300,
                               max_cookies_per_site IN PLS_INTEGER DEFAULT 20);
  PRAGMA restrict_references(set_cookie_support, wnds, rnds, trust);

  /**
   * Retrieves the current cookie support settings.
   *
   * PARAMETERS
   *   enable        Whether all future HTTP requests will support the HTTP
   *                 cookies or not?
   *   max_cookies   The maximum total number of cookies that will be
   *                 maintained in the current session.
   *   max_cookies_per_site  The maximum number of cookies per each Web site
   *                         that will be maintained in the current session.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_cookie_support(enable               OUT BOOLEAN,
                               max_cookies          OUT PLS_INTEGER,
                               max_cookies_per_site OUT PLS_INTEGER);
  PRAGMA restrict_references(get_cookie_support, wnds, rnds, trust);

  /**
   * Sets the maximum number of times the UTL_HTTP package should follow HTTP
   * redirect instruction in the HTTP responses to all future HTTP requests
   * in the function get_response.
   *
   * If max_redirects is set to a positive number, get_response will
   * automatically follow the redirected URL for the HTTP response status code
   * 301, 302, and 307 for the HTTP HEAD and GET methods, and 303 for all HTTP
   * methods, and retry the HTTP request (the request method will be changed
   * to HTTP GET for the status code 303) at the new location. It keeps
   * following the redirection until the final, non-redirect location is
   * reached, or an error occurs, or the maximum number of redirections has
   * been reached (to prevent an infinite loop). The url and method fields in
   * the req record will be updated to the last redirected URL and the method
   * used to access the URL. Set the maximum number of redirects to zero to
   * disable automatic redirection.
   *
   * The maximum number of redirection is 3 by default in a database user
   * session. Use this procedure to change the default settings. The default
   * value affects only the future requests and has no effect on the
   * existing ones.
   *
   * Once a request is created, the maximum number of redirection may be
   * changed by using the other set_follow_redirect procedure that operates
   * on a request.
   *
   * PARAMETERS
   *   max_redirects  The maximum number of redirections. Set to zero to
   *                  disable redirection.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_follow_redirect(max_redirects IN PLS_INTEGER DEFAULT 3);
  PRAGMA restrict_references(set_follow_redirect, wnds, rnds, trust);

  /**
   *  Retrieves the follow-redirect setting in the current session.
   *
   * PARAMETERS
   *   max_redirects  The maximum number of redirection for all future HTTP
   *                  requests.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_follow_redirect(max_redirects  OUT PLS_INTEGER);
  PRAGMA restrict_references(get_follow_redirect, wnds, rnds, trust);

  /**
   * Sets the default character set of the body of all future HTTP requests
   * when the media type is "text" but the character set is not specified in
   * the "Content-Type" header. Per the HTTP protocol standard specification,
   * if the media type of a request or a response is "text" but the character
   * set information is missing in the "Content-Type" header, the character
   * set of the request or response body should default to "ISO-8859-1".
   * Sets the default character set to override the default character set
   * "ISO-8859-1". Note that a response created for a request inherits the
   * default body character set of the request instead of that of the current
   * session.
   *
   * The default body character set is "ISO-8859-1" in a database user session.
   * Use this procedure to change the default settings. The default body
   * character set setting affects only the future requests and has not
   * effect on the existing ones.
   *
   * Once a request is created, the body character set may be changed by
   * using the other set_body_charset procedure that operates on a request.
   *
   * PARAMETERS
   *   charset   The default character set of the request body.
   *             The character set can be in Oracle or Internet Assigned
   *             Numbers Authority (IANA) naming convention. If charset is
   *             NULL, the database character set is assumed.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_body_charset(charset IN VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_body_charset, wnds, rnds, trust);

  /**
   * Retrieves the default character set of the body of all future HTTP
   * requests.
   *
   * PARAMETERS
   *   charset   The default character set of the body of all future HTTP
   *             requests.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_body_charset(charset OUT NOCOPY VARCHAR2);
  PRAGMA restrict_references(get_body_charset, wnds, rnds, trust);

  /* The following function, which returns the same default body character set
   * as the procedure "get_body_charset" does, is for use by the UTL_URL
   * package only. It is not intended to be used by Oracle users as a public
   * API.
   */
  FUNCTION get_body_charset RETURN VARCHAR2;
  PRAGMA restrict_references(get_body_charset, wnds, rnds, trust);

  /**
   * Sets whether future HTTP requests should support the HTTP 1.1 persistent-
   * connection or not, and the maximum numbers of persistent connections
   * to be maintained in the current database user session.
   *
   * If the persistent-connection support is enabled for a HTTP request,
   * the package will keep the network connections to a Web server or the
   * proxy server open in the package after the request is completed properly
   * for a subsequent request to the same server to reuse per HTTP 1.1
   * protocol specification. With the persistent connection support,
   * subsequent HTTP requests may be completed faster because the network
   * connection latency is avoided. If the persistent-connection support
   * is disabled for a request, the package will always send the HTTP header
   * "Connection: close" automatically in the HTTP request and close the
   * network connection when the request is completed. This setting has no
   * effect on HTTP requests that follows HTTP 1.0 protocol, for which the
   * network connections will always be closed after the requests are
   * completed.
   *
   * When a request is being made, the package always attempts to reuse an
   * existing persistent connection to the target Web server (or proxy server)
   * if one is available. If none is available, a new network connection will
   * be initiated. The persistent-connection support setting for a request
   * affects only whether the network connection should be closed after a
   * request completes.
   *
   * The persistent-connection support is disabled for all HTTP requests by
   * default in a database user session. The default maximum numbers of
   * persistent connections saved in the current session is zero. Use this
   * procedure to change the default settings. The default setting
   * of the persistent-connection support (enabled vs. disabled) affects only
   * the future requests and has no effect on the existing ones.
   *
   * Once a request is created, the persistent-connection support setting
   * may be changed by using the other set_persistent_conn_support procedure
   * that operates on a request.
   *
   * Users should note that while the use of persistent connections in UTL_HTTP
   * may reduce the time it takes to fetch multiple Web pages from the same
   * server, it consumes precious system resources (network connections) in
   * the database server. Excessive use of persistent connections may
   * reduce the scalability of the database server when too many network
   * connections are kept open in the database server. Therefore, users should
   * exert discretion when using persistent connection. Network connections
   * should be kept open only if they will be used immediately by subsequent
   * requests and should be closed immediately when they are no longer needed.
   * Also, users are advised to set the default persistent connection support
   * support as disabled in the session, and to enable persistent connection in
   * individual HTTP requests as shown in the following code example:
   *
   *   DECLARE
   *     TYPE vc2_table IS TABLE OF VARCHAR2(256) INDEX BY binary_integer;
   *     paths vc2_table;
   *
   *     PROCEDURE fetch_pages(paths IN vc2_table) AS
   *       url_prefix VARCHAR2(256) := 'http://www.my-company.com/';
   *       req   utl_http.req;
   *       resp  utl_http.resp;
   *       data  VARCHAR2(1024);
   *     BEGIN
   *       FOR i IN 1..paths.count LOOP
   *         req := utl_http.begin_request(url_prefix || paths(i));
   *
   *         -- Use persistent connection except for the last request
   *         IF (i < paths.count) THEN
   *           utl_http.set_persistent_conn_support(req, TRUE);
   *         END IF;
   *     
   *         resp := utl_http.get_response(req);
   *     
   *         BEGIN
   *           LOOP
   *             utl_http.read_text(resp, data);
   *             -- do something with the data
   *           END LOOP;
   *         EXCEPTION
   *           WHEN utl_http.end_of_body THEN
   *             NULL;
   *         END;
   *         utl_http.end_response(resp);
   *       END LOOP;
   *     END;
   *
   *   BEGIN
   *     utl_http.set_persistent_conn_support(FALSE, 1);
   *     paths(1) := '...';
   *     paths(2) := '...';
   *     ...   
   *     fetch_pages(paths);
   *   END;
   *
   * PARAMETERS
   *   enable    Set enable to TRUE to enable persistent connection support.
   *             FALSE otherwise.
   *   max_conns Sets the maximum number of persistent connections that will
   *             be maintained in the current session.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   The default value of the maximum number of persistent connections
   * in a database session is zero.  To truly enable persistent connections,
   * the user must also set the maximum number of persistent connections to
   * a positive value or no connections will be kept persistent.
   */
  PROCEDURE set_persistent_conn_support(enable    IN BOOLEAN,
                                        max_conns IN PLS_INTEGER DEFAULT 0);
  PRAGMA restrict_references(set_persistent_conn_support, wnds, rnds, trust);

  /**
   * Checks if the persistent connection support is enabled or not, and
   * retrieves the maximum number of persistent connections maintained
   * in the current session.
   *
   * PARAMETERS
   *   enable    TRUE if persistent connection support is enabled.
   *             FALSE otherwise.
   *   max_conns The maximum number of persistent connections that will be
   *             maintained in the current session.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_persistent_conn_support(enable    OUT BOOLEAN,
                                        max_conns OUT PLS_INTEGER);
  PRAGMA restrict_references(get_persistent_conn_support, wnds, rnds, trust);

  /**
   * Sets whether get_response should raise an exception when the Web server
   * returns a status code that indicates an error (namely, a status code in
   * the 4xx or 5xx ranges). For example, when the requested URL is not found
   * in the destination Web server, a 404 (document not found) response status
   * code is returned.  In general, a 4xx or 5xx response is considered an
   * error response.  If response error check is set, get_response will raise
   * the HTTP_CLIENT_ERROR or HTTP_SERVER_ERROR exception if the status code
   * indicates an error. Otherwise, get_response will not raise the exception
   * if the status codes indicates an error. Response error check is turned off
   * by default.
   *
   * PARAMETERS
   *   enable         Set to TRUE to check for response error. FALSE otherwise.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_response_error_check(enable IN BOOLEAN DEFAULT FALSE);
  PRAGMA restrict_references(set_response_error_check, wnds, rnds, trust);

  /**
   * Checks if response error check is set or not.
   *
   * PARAMETERS
   *   enable         TRUE if response error check is set. FALSE otherwise.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_response_error_check(enable OUT BOOLEAN);
  PRAGMA restrict_references(get_response_error_check, wnds, rnds, trust);

  /**
   * Sets the UTL_HTTP package to raise a detailed exception. By default,
   * the UTL_HTTP package raises the exception request_failed when a HTTP
   * request fails. The user may use get_detailed_sqlcode and
   * get_detailed_sqlerrm to obtained the more detailed information of the
   * actual error. Use set_detailed_excp_support to ask the UTL_HTTP package
   * to raise a detailed exception directly instead.
   *
   * PARAMETERS
   *   enable    Sets to TRUE to ask the UTL_HTTP package to raise a detailed
   *             exception directly. FALSE otherwise.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_detailed_excp_support(enable IN BOOLEAN DEFAULT FALSE);
  PRAGMA restrict_references(set_detailed_excp_support, wnds, rnds, trust);

  /**
   * Checks if the UTL_HTTP package will raise a detailed exception or not.
   *
   * PARAMETERS
   *   enable    TRUE if the UTL_HTTP package will raise a detailed exception.
   *             FALSE otherwise.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_detailed_excp_support(enable OUT BOOLEAN);
  PRAGMA restrict_references(get_detailed_excp_support, wnds, rnds, trust);

  /**
   * Sets the Oracle wallet to be used for all HTTP requests over Secured
   * Socket Layer (SSL), namely HTTPS. When the UTL_HTTP package communicates
   * with a HTTP server over SSL, the HTTP server presents its digital
   * certificate, which is signed by a certificate authority, to the UTL_HTTP
   * package for identification purpose. The Oracle wallet contains the list
   * of certificate authorities which are trusted by the user of the UTL_HTTP
   * package. An Oracle wallet is required in order to make a HTTPS request
   * successfully.
   *
   * PARAMETERS
   *   path      The directory path that contains the Oracle wallet.
   *             The format is "file:<directory-path>".
   *   password  The password needed to open the wallet. There may a second
   *             copy of a wallet in a wallet directory that may be opened
   *             without a password. That second copy of the wallet is for
   *             read only. If password is NULL, the UTL_HTTP package will
   *             open the second, read-only copy of the wallet instead.
   *             See the documentation on Oracle wallets for details.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_wallet(path     IN VARCHAR2,
                       password IN VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_wallet, wnds, rnds, trust);

  /**
   * Sets the default time-out value for all future HTTP requests that the
   * UTL_HTTP package should attempt reading the HTTP response from the
   * Web server or proxy server. This time-out value may be used to avoid the
   * PL/SQL programs from being blocked by busy Web servers or heavy network
   * traffic while retrieving Web pages from the Web servers. The default
   * value of the time-out is 60 seconds.
   *
   * PARAMETERS
   *   timeout   The network transfer time-out value (in seconds).
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_transfer_timeout(timeout IN PLS_INTEGER DEFAULT 60);
  PRAGMA restrict_references(set_transfer_timeout, wnds, rnds, trust);

  /**
   * Retrieves the default time-out value for all future HTTP requests.
   *
   * PARAMETERS
   *   timeout   The network transfer time-out value (in seconds).
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_transfer_timeout(timeout OUT PLS_INTEGER);
  PRAGMA restrict_references(get_transfer_timeout, wnds, rnds, trust);

  /**
   * Creates a request context. A request context is a context that holds
   * a wallet and a cookie for private use in making a HTTP request.
   * This allows the HTTP request to use a wallet and a cookie table
   * that will not be shared with other applications making HTTP requests
   * in the same database session.
   *
   * PARAMETERS
   *   wallet_path  The directory path that contains the Oracle wallet.
   *             The format is "file:<directory-path>".
   *   wallet_password  The password needed to open the wallet. There may a
   *             second copy of a wallet in a wallet directory that may be
   *             opened without a password. That second copy of the wallet is
   *             for read only. If password is NULL, the UTL_HTTP package will
   *             open the second, read-only copy of the wallet instead.
   *             See the documentation on Oracle wallets for details.
   *   enable_cookies  Sets whether HTTP requests using this request context
   *             should support HTTP cookies or not. TRUE to enable the
   *             support, FALSE to disable it.
   *   max_cookies  Sets the maximum total number of cookies that will be
   *             maintained in this request context.
   *   max_cookies_per_site  Sets the maximum number of cookies per each Web
   *             site that will be maintained in this request context.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  FUNCTION create_request_context(
             wallet_path          IN VARCHAR2 DEFAULT NULL,
             wallet_password      IN VARCHAR2 DEFAULT NULL,
             enable_cookies       IN BOOLEAN DEFAULT TRUE,
             max_cookies          IN PLS_INTEGER DEFAULT 300,
             max_cookies_per_site IN PLS_INTEGER DEFAULT 20)
             RETURN request_context_key;
  PRAGMA restrict_references(create_request_context, wnds, rnds, trust);

  /**
   * Destroys a request context. A request cannot be destroyed when it is
   * in use by a HTTP request or response.
   *
   * PARAMETERS
   *   request_context  The request context to destroy
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE destroy_request_context(request_context IN OUT request_context_key);
  PRAGMA restrict_references(destroy_request_context, wnds, rnds, trust);

  /*-------------------------- Request API ------------------------------*/
  /* The following set of API begin a HTTP request, manipulate its
   * attributes, and send the request information to the Web server.
   * When a request is created, it inherits the default settings of the HTTP
   * cookie support, follow-redirect, body character set, persistent-connection
   * support, and transfer time-out of the current session.  Those settings
   * may be changed by calling the request API.
   */

  /**
   * Begins a new HTTP request. When the function returns, the UTL_HTTP
   * package has established the network connection to the target Web server,
   * or the proxy server if a proxy server is to be used, and has sent the
   * HTTP request line. The PL/SQL program should continue the request by
   * calling some other API to complete the request.
   *
   * PARAMETERS
   *   url           The URL of the HTTP request.
   *   method        The method to be performed on the resource identified by
   *                 the URL.
   *   http_version  The HTTP protocol version to use to send the request.
   *                 The format of the protocol version is
   *                 "HTTP/major-version.minor-version", where major-version
   *                 and minor-version are positive number. If this parameter
   *                 is set to NULL, the UTL_HTTP package will use the latest
   *                 HTTP protocol version that it supports to send the
   *                 request. The latest version that the package supports is
   *                 1.1 and it may be upgraded to a later version when one
   *                 becomes available. The parameter is set to NULL by
   *                 default.
   *  request_context  The request context that holds the private wallet and
   *                 the cookie table to use in this HTTP request. If this
   *                 parameter is NULL, the wallet and cookie table shared in
   *                 the current database session will be used instead.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *
   *   bad_argument      when some of the arguments passed are not valid.
   *   bad_url           when the URL is not valid.
   *   unknown_scheme    when the request scheme is not known.
   *   too_many_requests when there are too many open requests.
   *   http_client_error when the HTTP proxy returns 4xx response for a HTTPS
   *                     request via the proxy
   *   http_server_error when the HTTP proxy returns 5xx response for a HTTPS
   *                     request via the proxy
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   *   The URL passed as an argument to this function will not be examined
   * for illegal characters per the URL specification RFC 2396, like spaces
   * for example. The caller should escape those characters with the UTL_URL
   * package. See the comments of the package for the list of legal
   * characters in URLs. Note that URLs should consist of US-ASCII
   * characters only. The use of non-US-ASCII characters in an URL is
   * generally unsafe.
   *   
   * URL may contain username and password to authenticate the request to the 
   * server. The general format would be
   *          <scheme>://[<user>[:<password>]@]<host>[:<port>]/[...].
   *   An Oracle wallet must be set before accessing Web servers over the HTTPS
   * protocol. See the set_wallet procedure on how to set up an Oracle wallet.
   *   To connect to the remote Web server directly, or indirectly through
   * a HTTP proxy, the UTL_HTTP must have the "connect" ACL privilege to the
   * remote Web server host or the proxy host respectively.
   *   To use the client-certificate credentials in a wallet to authenticate
   * with the remote Web server over SSL, the UTL_HTTP must have the
   * "use-client-certificates" privilege on the wallet.
   */
  FUNCTION begin_request(url             IN VARCHAR2,
                         method          IN VARCHAR2 DEFAULT 'GET',
                         http_version    IN VARCHAR2 DEFAULT NULL,
                         request_context IN request_context_key DEFAULT NULL)
                         RETURN req;
  PRAGMA restrict_references(begin_request, wnds, rnds, trust);

  /**
   * Sets a HTTP request property. 
   *
   * PARAMETERS
   *   r             The HTTP request
   *   name          The name of the HTTP request property. The property name
   *                 is case-sensitive.
   *   value         The value of the HTTP request property
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network and runtime exceptions.
   */
  PROCEDURE set_property(r       IN OUT NOCOPY req,
                         name    IN            VARCHAR2,
                         value   IN            VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_property, wnds, rnds, trust);

  /**
   * Sets a HTTP request header. The request header is sent to the Web server
   * as soon as it is set.
   *
   * PARAMETERS
   *   r             The HTTP request
   *   name          The name of the HTTP request header
   *   value         The value of the HTTP request header
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   illegal_call      when the request body is already sent
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   *   Note that multiple HTTP headers with the same name are allowed per
   * the HTTP protocol standard.  Therefore, setting a header does not
   * replace a prior header with the same name.
   *   If the request is made using HTTP 1.1 protocol, the UTL_HTTP package
   * sets the "Host" header automatically for the user.
   *   When the user sets the "Content-Type" header with this procedure,
   * the UTL_HTTP package looks for the character set information in the
   * header value. If the character set information is present, it is set as
   * the character set of the request body. It can be overridden later by
   * using the set_body_charset procedure.
   *   When the user sets the "Transfer-Encoding" header with the value
   * "chunked", the UTL_HTTP automatically encodes the request body written
   * by the write_text, write_line, and write_raw procedures.
   */
  PROCEDURE set_header(r       IN OUT NOCOPY req,
                       name    IN            VARCHAR2,
                       value   IN            VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_header, wnds, rnds, trust);

  /**
   * Sets the HTTP authentication information in the HTTP request header
   * needed for the request to be authorized by the Web server.
   *
   * PARAMETERS
   *   r             The HTTP request
   *   username      The username for the HTTP authentication
   *   password      The password for the HTTP authentication
   *   scheme        The HTTP authentication scheme. Either 'Basic' for
   *                 the HTTP basic or 'AWS' for Amazon S3 authentication
   *                 scheme. Default is 'Basic'.
   *   for_proxy     Is the HTTP authentication information for the access to
   *                 the HTTP proxy server instead of the Web server? Default
   *                 is FALSE.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   illegal_call      when the request body is already sent
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   *     The supported authentication schemes are HTTP basic and Amazon S3
   *   authentication schemes.
   *     For Amazon S3 authentication:
   *   - All headers used to compute the authentication header - Content-MD5,
   *     Content-Type, Date, and all X-Amz-* headers - must be set via the
   *     set_header procedure before set_authentication is called to compute
   *     and set the authentication header.
   *   - When an endpoint other than "s3.amazonaws.com" is used, the user
   *     should specify the correct endpoint to compute the authentication
   *     header by setting the request property "aws-endpoint" using the
   *     set_property procedure first. Alternatively, the user may specify
   *     the CanonicalizedResource string through the request property
   *     "aws-canonicalized-resource" irrespective of the endpoint to compute
   *     the authentication header.
   */
  PROCEDURE set_authentication(r        IN OUT NOCOPY req,
                               username IN            VARCHAR2,
                               password IN            VARCHAR2 DEFAULT NULL,
                               scheme   IN            VARCHAR2 DEFAULT 'Basic',
                               for_proxy IN           BOOLEAN  DEFAULT FALSE);
  PRAGMA restrict_references(set_authentication, wnds, rnds, trust);

  /**
   * Sets the HTTP authentication information in the HTTP request header
   * needed for the request to be authorized by the Web server using the
   * username and password credential stored in the Oracle wallet.
   *
   * PARAMETERS
   *   r             The HTTP request
   *   alias         The alias to identify and retrieve the username and
   *                 password credential stored in the Oracle wallet
   *   scheme        The HTTP authentication scheme. Either 'Basic' for
   *                 the HTTP basic or 'AWS' for Amazon S3 authentication
   *                 scheme. Default is 'Basic'.
   *   for_proxy     Is the HTTP authentication information for the access to
   *                 the HTTP proxy server instead of the Web server? Default
   *                 is FALSE.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   illegal_call      when the request body is already sent
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   *     To use the password credentials in a wallet, the UTL_HTTP must have
   *   the "use-passwords" privilege on the wallet.
   *     The supported authentication schemes are HTTP basic and Amazon S3
   *   authentication schemes.
   *     For Amazon S3 authentication:
   *   - All headers used to compute the authentication header - Content-MD5,
   *     Content-Type, Date, and all X-Amz-* headers - must be set via the
   *     set_header procedure before set_authentication is called to compute
   *     and set the authentication header.
   *   - When an endpoint other than "s3.amazonaws.com" is used, the user
   *     should specify the correct endpoint to compute the authentication
   *     header by setting the request property "aws-endpoint" using the
   *     set_property procedure first. Alternatively, the user may specify
   *     the CanonicalizedResource string through the request property
   *     "aws-canonicalized-resource" irrespective of the endpoint to compute
   *     the authentication header.
   */
  PROCEDURE set_authentication_from_wallet(r       IN OUT NOCOPY req,
                                           alias   IN VARCHAR2,
                                           scheme  IN VARCHAR2 DEFAULT 'Basic',
                                           for_proxy IN BOOLEAN DEFAULT FALSE);
  PRAGMA restrict_references(set_authentication_from_wallet,
                             wnds, rnds, trust);

  /**
   * Enables (or disables) the support for the HTTP cookies in this request.
   *
   * If the cookie support is enabled for a HTTP request, all cookies that
   * are saved in the current session and are applicable to the request will
   * be returned to the Web server in the request in accordance to the HTTP
   * cookies specification RFC 2109 and to the draft proposal by Netscape
   * Communications Corporation. Cookies that are set in the response to
   * the request will be saved in the current session for return to the Web
   * server in the subsequent requests if the cookie support is enabled
   * for those requests. If the cookie support is disabled for a HTTP request,
   * no cookies will be returned to the Web server in the request and the
   * cookies set in the response to the request will not be saved in the
   * current session, although the "Set-Cookie" HTTP headers can still be
   * retrieved from the response.
   *
   * Use this procedure to change the cookie support setting a request inherits
   * from the session's default setting.
   *
   * PARAMETERS
   *   r             The HTTP request
   *   enable        Set enable to TRUE to enable the HTTP cookie support.
   *                 FALSE otherwise.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   Note that the HTTP cookies saved in the current session will last for
   *   the duration of the database session only and there is no persistent
   *   storage for the cookies. An example is given in the package
   *   documentation to illustrate how to use get_cookies and add_cookies
   *   to retrieve, save, and restore the cookies.
   */
  PROCEDURE set_cookie_support(r        IN OUT NOCOPY req,
                               enable   IN            BOOLEAN DEFAULT TRUE);
  PRAGMA restrict_references(set_cookie_support, wnds, rnds, trust);
  
  /**
   * Sets the maximum number of times the UTL_HTTP package should follow HTTP
   * redirect instruction in the HTTP response to this request in the
   * function get_response.
   *
   * If max_redirects is set to a positive number, get_response will
   * automatically follow the redirected URL for the HTTP response status code
   * 301, 302, and 307 for the HTTP HEAD and GET methods, and 303 for all HTTP
   * methods, and retry the HTTP request (the request method will be changed
   * to HTTP GET for the status code 303) at the new location. It keeps
   * following the redirection until the final, non-redirect location is
   * reached, or an error occurs, or the maximum number of redirections has
   * been reached (to prevent an infinite loop). The url and method fields in
   * the req record will be updated to the last redirected URL and the method
   * used to access the URL. Set the maximum number of redirects to zero to
   * disable automatic redirection.
   *
   * Use this procedure to change the maximum number of redirections a request
   * inherits from the session's default setting.
   *
   * PARAMETERS
   *   r             The HTTP request
   *   max_redirects The maximum number of redirections.  Set to zero to
   *                 disable redirection.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous runtime exceptions.
   * NOTES
   *   set_follow_redirect must be called before get_response for any
   *   redirection to take effect.
   */
  PROCEDURE set_follow_redirect(r             IN OUT NOCOPY req,
                                max_redirects IN     PLS_INTEGER DEFAULT 3);
  PRAGMA restrict_references(set_follow_redirect, wnds, rnds, trust);

  /**
   * Sets the character set of the request body when the media type is "text"
   * but the character set is not specified in the "Content-Type" header.
   * Per the HTTP protocol standard specification, if the media type of a
   * request or a response is "text" but the character set information is
   * missing in the "Content-Type" header, the character set of the request
   * or response body should default to "ISO-8859-1".
   *
   * Use this procedure to change the default body character set a request
   * inherits from the session's default setting.
   *
   * PARAMETERS
   *   r         The HTTP request
   *   charset   The default character set of the request body.
   *             The character set can be in Oracle or Internet Assigned
   *             Numbers Authority (IANA) naming convention. If charset is
   *             NULL, the database character set is assumed.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_body_charset(r       IN OUT NOCOPY req,
                             charset IN            VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_body_charset, wnds, rnds, trust);

  /**
   * Enables (or disables) the support for the HTTP 1.1 persistent-connection
   * in this request.
   *
   * If the persistent-connection support is enabled for a HTTP request,
   * the package will keep the network connections to a Web server or the
   * proxy server open in the package after the request is completed properly
   * for a subsequent request to the same server to reuse per HTTP 1.1
   * protocol specification. With the persistent connection support,
   * subsequent HTTP requests may be completed faster because the network
   * connection latency is avoided. If the persistent-connection support
   * is disabled for a request, the package will always send the HTTP header
   * "Connection: close" automatically in the HTTP request and close the
   * network connection when the request is completed. This setting has no
   * effect on HTTP requests that follows HTTP 1.0 protocol, for which the
   * network connections will always be closed after the requests are
   * completed.
   *
   * When a request is being made, the package always attempts to reuse an
   * existing persistent connection to the target Web server (or proxy server)
   * if one is available. If none is available, a new network connection will
   * be initiated. The persistent-connection support setting for a request
   * affects only whether the network connection should be closed after a
   * request completes.
   *
   * Use this procedure to change the persistent-connection support setting a
   * request inherits from the session's default setting.
   *
   * Users should note that while the use of persistent connections in UTL_HTTP
   * may reduce the time it takes to fetch multiple Web pages from the same
   * server, it consumes precious system resources (network connections) in
   * the database server. Also, excessive use of persistent connections may
   * reduce the scalability of the database server when too many network
   * connections are kept open in the database server. Therefore, users should
   * exert discretion when using persistent connection. Network connections
   * should be kept open only if they will be used immediately by subsequent
   * requests and should be closed immediately when they are no longer needed.
   * Also, users are advised to set the default persistent connection support
   * support as disabled in the session, and to enable persistent connection in
   * individual HTTP requests as shown in the following code example:
   *
   *   DECLARE
   *     TYPE vc2_table IS TABLE OF VARCHAR2(256) INDEX BY binary_integer;
   *     paths vc2_table;
   *
   *     PROCEDURE fetch_pages(paths IN vc2_table) AS
   *       url_prefix VARCHAR2(256) := 'http://www.my-company.com/';
   *       req   utl_http.req;
   *       resp  utl_http.resp;
   *       data  VARCHAR2(1024);
   *     BEGIN
   *       FOR i IN 1..paths.count LOOP
   *         req := utl_http.begin_request(url_prefix || paths(i));
   *
   *         -- Use persistent connection except for the last request
   *         IF (i < paths.count) THEN
   *           utl_http.set_persistent_conn_support(req, pcn);
   *         END IF;
   *     
   *         resp := utl_http.get_response(req);
   *     
   *         BEGIN
   *           LOOP
   *             utl_http.read_text(resp, data);
   *             -- do something with the data
   *           END LOOP;
   *         EXCEPTION
   *           WHEN utl_http.end_of_body THEN
   *             NULL;
   *         END;
   *         utl_http.end_response(resp);
   *       END LOOP;
   *     END;
   *
   *   BEGIN
   *     utl_http.set_persistent_conn_support(FALSE, 1);
   *     paths(1) := '...';
   *     paths(2) := '...';
   *     ...   
   *     fetch_pages(paths);
   *   END;
   *
   * PARAMETERS
   *   r             The HTTP request
   *   enable        TRUE to keep the network connection persistent.
   *                 FALSE otherwise.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   illegal_call      when the request body is already sent
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   The default value of the maximum number of persistent connections
   * in a database session is zero.  To truly enable persistent connections,
   * the user must also set the maximum number of persistent connections to
   * a positive value or no connections will be kept persistent.
   */
  PROCEDURE set_persistent_conn_support(r      IN OUT NOCOPY req,
                                        enable IN     BOOLEAN DEFAULT FALSE);
  PRAGMA restrict_references(set_persistent_conn_support, wnds, rnds, trust);

  /**
   * Sets the time-out value that the UTL_HTTP package should attempt reading
   * the HTTP response of this HTTP request from the Web server or proxy
   * server. This time-out value may be used to avoid the PL/SQL programs
   * from being blocked by busy Web servers or heavy network traffic while
   * retrieving Web pages from the Web servers. The default value of the
   * time-out is 60 seconds.
   *
   * PARAMETERS
   *   timeout   The network transfer time-out value (in seconds).
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_transfer_timeout(r       IN OUT NOCOPY req,
                                 timeout IN PLS_INTEGER DEFAULT 60);
  PRAGMA restrict_references(set_transfer_timeout, wnds, rnds, trust);

  /**
   * Writes some text data in the HTTP request body. As soon as some data is
   * sent as the HTTP request body, the HTTP request headers section is
   * completed. Text data is automatically converted from the database
   * character set to the request body character set.
   *
   * PARAMETERS
   *   r         The HTTP request
   *   data      The text data to send in the HTTP request body
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   A HTTP client must always let the remote Web server to know the length
   * of the request body it is sending. If the amount of data is known
   * beforehand, the user can set the "Content-Length" header in the request,
   * where the length of the content is measured in bytes instead of
   * characters. If the length of the request body is not know beforehand,
   * the user can choose to send the request body using the HTTP 1.1 chunked
   * transfer-encoding format. The request body will be sent in chunks where
   * the length of each chunk is sent before the chunk is sent. The UTL_HTTP
   * package performs chunked transfer-encoding on the request body
   * transparently when the "Transfer-Encoding: chunked" header is set.
   * Note that some HTTP-1.1-based Web servers or CGI programs do not support
   * or accept the request body encoding in the HTTP 1.1 chunked
   * transfer-encoding format. See the set_header procedure for details.
   *   If the user sends the "Content-Length" header, the user should note
   * that the length specify in the header should be the byte-length of the
   * textual request body after it is converted from the database character
   * set to the request body character set. When either one of the two
   * character sets is a multi-byte character set, the precise byte-length of
   * the request body in the request body character set may not be known
   * beforehand. In that case, the user may perform the character set
   * conversion explicitly, determine the byte-length of the results, send
   * the "Content-Length" header, and the results using the write_raw
   * procedure to avoid the automatic character set conversion.
   * Or if the remove Web server or CGI programs allows, the user may send
   * the request body using the HTTP 1.1 chunked transfer-encoding format
   * where the UTL_HTTP will handle the length of the chunks transparently.
   */
  PROCEDURE write_text(r    IN OUT NOCOPY req,
                       data IN            VARCHAR2 CHARACTER SET ANY_CS);
  PRAGMA restrict_references(write_text, wnds, rnds, trust);

  /**
   * Writes a text line in the HTTP request body and ends the line with
   * new-line characters (CRLF as defined in UTL_TCP). As soon as some data
   * is sent as the HTTP request body, the HTTP request headers section is
   * completed. Text data is automatically converted from the database
   * character set to the request body character set.
   *
   * PARAMETERS
   *   r         The HTTP request
   *   data      The text line to send in the HTTP request body
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   A HTTP client must always let the remote Web server to know the length
   * of the request body it is sending. If the amount of data is known
   * beforehand, the user can set the "Content-Length" header in the request,
   * where the length of the content is measured in bytes instead of
   * characters. If the length of the request body is not know beforehand,
   * the user can choose to send the request body using the HTTP 1.1 chunked
   * transfer-encoding format. The request body will be sent in chunks where
   * the length of each chunk is sent before the chunk is sent. The UTL_HTTP
   * package performs chunked transfer-encoding on the request body
   * transparently when the "Transfer-Encoding: chunked" header is set.
   * Note that some HTTP-1.1-based Web servers or CGI programs do not support
   * or accept the request body encoding in the HTTP 1.1 chunked
   * transfer-encoding format. See the set_header procedure for details.
   *   If the user sends the "Content-Length" header, the user should note
   * that the length specify in the header should be the byte-length of the
   * textual request body after it is converted from the database character
   * set to the request body character set. When either one of the two
   * character sets is a multi-byte character set, the precise byte-length of
   * the request body in the request body character set may not be known
   * beforehand. In that case, the user may perform the character set
   * conversion explicitly, determine the byte-length of the results, send
   * the "Content-Length" header, and the results using the write_raw
   * procedure to avoid the automatic character set conversion.
   * Or if the remove Web server or CGI programs allows, the user may send
   * the request body using the HTTP 1.1 chunked transfer-encoding format
   * where the UTL_HTTP will handle the length of the chunks transparently.
   */
  PROCEDURE write_line(r    IN OUT NOCOPY req,
                       data IN            VARCHAR2 CHARACTER SET ANY_CS);
  PRAGMA restrict_references(write_line, wnds, rnds, trust);

  /**
   * Writes some binary data in the HTTP request body. As soon as some data is
   * sent as the HTTP request body, the HTTP request headers section is
   * completed.
   *
   * PARAMETERS
   *   r         The HTTP request
   *   data      The binary data to send in the HTTP request body
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   A HTTP client must always let the remote Web server to know the length
   * of the request body it is sending. If the amount of data is known
   * beforehand, the user can set the "Content-Length" header in the request,
   * where the length of the content is measured in bytes instead of
   * characters. If the length of the request body is not know beforehand,
   * the user can choose to send the request body using the HTTP 1.1 chunked
   * transfer-encoding format. The request body will be sent in chunks where
   * the length of each chunk is sent before the chunk is sent. The UTL_HTTP
   * package performs chunked transfer-encoding on the request body
   * transparently when the "Transfer-Encoding: chunked" header is set.
   * Note that some HTTP-1.1-based Web servers or CGI programs do not support
   * or accept the request body encoding in the HTTP 1.1 chunked
   * transfer-encoding format. See the set_header procedure for details.
   */
  PROCEDURE write_raw(r    IN OUT NOCOPY req,
                      data IN            RAW);
  PRAGMA restrict_references(write_raw, wnds, rnds, trust);

  /**
   * Ends the HTTP request. In the not-so-normal situation when a PL/SQL
   * program wants to terminates the HTTP request without completing the
   * request and waiting for the response, the program can call this procedure
   * to terminate the request. Otherwise, the program should go through the
   * normal sequence of beginning a request, getting the response, and
   * closing the response. The network connection will always be closed and
   * will not be reused.
   *
   * PARAMETERS
   *   r            The HTTP request
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE end_request(r IN OUT NOCOPY req);
  PRAGMA restrict_references(end_request, wnds, rnds, trust);

  /*-------------------------- Response API ------------------------------*/
  /* The following set of API manipulate a HTTP response obtained from
   * get_response and to receive the response information from the Web server.
   * When a response is created for a request, it inherits settings of the
   * HTTP cookie support, follow-redirect, body character set, persistent-
   * connection support, and transfer time-out from the request. Only the body
   * character set may be changed by calling the response API.
   */

  /**
   * Reads the HTTP response. When this procedure returns, the status line
   * and the HTTP response headers have been read and processed. The status
   * code, reason phrase and the HTTP protocol version are stored in the
   * response record. This function completes the HTTP headers section.
   *
   * PARAMETERS
   *   r                     The HTTP request
   *   return_info_response  Return 100 informational response or not. TRUE
   *                         means get_response should return 100 informational 
   *                         response when it is received from the HTTP server.
   *                         The request will not be ended if a 100 response is 
   *                         returned. FALSE means the API should ignore any 100 
   *                         informational response received from the HTTP server 
   *                         and should return the following non-100 response 
   *                         instead. The default is FALSE. 
   *                         See notes below for details.
   *                   
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   When response error check is enabled:
   *     http_client_error   when the response code is in 400 range
   *     http_server_error   when the response code is in 500 range
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   - The request will be ended when this functions returns regardless of
   *     whether an exception is raised or not.  There is no need to end
   *     the request with end_request.
   *   - If URL redirection occurs, the url and method fields in the req
   *     record will be updated to the last redirected URL and the method used
   *     to access the URL. 
   *     
   * Notes on 100 Continue:
   * In certain situations (initiated by the HTTP client or not), the HTTP
   * server may return a 1xx informational response. The user who does not
   * expect such a response may indicate to get_response to ignore the response
   * and proceed to receive the regular response. In the case when the user
   * expects such a response, he can indicate to get_response to return the
   * response. For example, when a user is issuing a HTTP POST request with a
   * large request body, the user may want to check with the HTTP server to
   * ensure that the server will accept the request before sending the data.
   * To do so, the user will send the additional "Expect: 100-continue" request
   * header, check for "100 Continue" response from the server before
   * proceeding to send the request body. Then, the user will get the regular
   * HTTP response as he normally does. The following code example illustrates
   * this:
   * DECLARE
   *  data  VARCHAR2(1024) := '...';
   *  req   utl_http.req;
   *  resp  utl_http.resp;
   * BEGIN
   *
   *  req := utl_http.begin_request('http://www.acme.com/receiver', 'POST');
   * utl_http.set_header(req, 'Content-Length', length(data));
   *  -- Ask HTTP server to return "100 Continue" response
   *  utl_http.set_header(req, 'Expect', '100-continue');
   *  resp := utl_http.get_response(req, TRUE);
   *
   *  -- Check for and dispose "100 Continue" response
   *  IF (resp.status_code <> 100) THEN
   *    utl_http.end_response(resp);
   *    raise_application_error(20000, 'Request rejected');
   *  END IF;
   *  utl_http.end_response(resp);
   *
   *  -- Now, send the request body
   *  utl_http.write_text(req, data);

   *  -- Get the regular response
   *  resp := utl_http.get_response(req);
   *  utl_http.read_text(resp, data);
   *
   *  utl_http.end_response(resp);
   *
   * END;
   *
   */
  FUNCTION get_response(r                    IN OUT NOCOPY req, 
                        return_info_response BOOLEAN DEFAULT FALSE) 
                        RETURN resp;
  PRAGMA restrict_references(get_response, wnds, rnds, trust);

  /**
   * Returns the number of HTTP response headers returned in the response.
   *
   * PARAMETERS
   *   r         The HTTP response
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   If the response body returned by the remote Web server is encoded
   * in chunked transfer encoding format, the trailer headers that are returned
   * at the end of the response body will be added to the response and
   * the response header count will be updated. Users can retrieve the
   * additional headers after the end of the response body is reached and
   * before they end the response.
   */
  FUNCTION get_header_count(r IN OUT NOCOPY resp) RETURN PLS_INTEGER;
  PRAGMA restrict_references(get_header_count, wnds, rnds, trust);

  /**
   * Returns the n-th HTTP response header name and value returned in the
   * response.
   *
   * PARAMETERS
   *   r         The HTTP response
   *   n         The n-th header to return
   *   name      The name of the HTTP respone header
   *   value     The value of the HTTP response header
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   header_not_found  when the n-th header is not found.
   *   - plus miscellaneous runtime exceptions.
   * NOTES
   *   If the response body returned by the remote Web server is encoded
   * in chunked transfer encoding format, the trailer headers that are returned
   * at the end of the response body will be added to the response and
   * the response header count will be updated. Users can retrieve the
   * additional headers after the end of the response body is reached and
   * before they end the response.
   */
  PROCEDURE get_header(r     IN OUT NOCOPY resp,
                       n     IN            PLS_INTEGER,
                       name  OUT NOCOPY    VARCHAR2,
                       value OUT NOCOPY    VARCHAR2);
  PRAGMA restrict_references(get_header, wnds, rnds, trust);

  /**
   * Returns the HTTP response header value returned in the response given
   * the name of the header.
   *
   * PARAMETERS
   *   r         The HTTP response
   *   name      The name of the HTTP response header
   *   value     The value of the HTTP response header
   *   n         The nth occurrence of HTTP response header by the specified
   *             name to return. Default is 1.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   header_not_found  when the n-th header is not found.
   *   - plus miscellaneous runtime exceptions.
   * NOTES
   *   If the response body returned by the remote Web server is encoded
   * in chunked transfer encoding format, the trailer headers that are returned
   * at the end of the response body will be added to the response and
   * the response header count will be updated. Users can retrieve the
   * additional headers after the end of the response body is reached and
   * before they end the response.
   */
  PROCEDURE get_header_by_name(r     IN OUT NOCOPY resp,
                               name  IN            VARCHAR2,
                               value OUT NOCOPY    VARCHAR2,
                               n     IN            PLS_INTEGER DEFAULT 1);
  PRAGMA restrict_references(get_header_by_name, wnds, rnds, trust);

  /**
   * Retrieves the HTTP authentication information needed for the request to be
   * accepted by the Web server as indicated in the HTTP response header.
   *
   * PARAMETERS
   *   r         The HTTP response
   *   scheme    The scheme for the required HTTP authentication
   *   realm     The realm for the required HTTP authentication.
   *   for_proxy Returns the HTTP authentication information required for the
   *             access to the HTTP proxy server instead of the Web server?
   *             Default is FALSE.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_authentication(r         IN OUT NOCOPY resp,
                               scheme    OUT NOCOPY    VARCHAR2,
                               realm     OUT NOCOPY    VARCHAR2,
                               for_proxy IN            BOOLEAN  DEFAULT FALSE);
  PRAGMA restrict_references(get_authentication, wnds, rnds, trust);

  /**
   * Sets the character set of the response body when the media type is "text"
   * but the character set is not specified in the "Content-Type" header.
   * Per the HTTP protocol standard specification, if the media type of a
   * request or a response is "text" but the character set information is
   * missing in the "Content-Type" header, the character set of the request
   * or response body should default to "ISO-8859-1".
   *
   * Use this procedure to change the default body character set a response
   * inherits from the request.
   *
   * PARAMETERS
   *   r         The HTTP response
   *   charset   The default character set of the response body. The character
   *             set can be in Oracle or Internet Assigned Numbers Authority
   *             (IANA) naming convention. If charset is NULL, the database
   *             character set is assumed.
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE set_body_charset(r       IN OUT NOCOPY resp,
                             charset IN            VARCHAR2 DEFAULT NULL);
  PRAGMA restrict_references(set_body_charset, wnds, rnds, trust);

  /**
   * Reads the HTTP response body in text form and returns the output in the
   * caller-supplied buffer. The end_of_body exception will be raised if the
   * end of the HTTP response body is reached.  Text data is automatically
   * converted from the response body character set to the database character
   * set.
   *
   * PARAMETERS
   *   r         The HTTP response
   *   data      The HTTP response body in text form
   *   len       The maximum number of characters of data to read. If len is
   *             NULL, this procedure will read as much input as possible to
   *             fill the buffer allocated in data. The actual amount of data
   *             returned may be less than that specified if not so much data
   *             is available before the end of the HTTP response body is
   *             reached or the transfer_timeout amount of time has elapsed.
   *             The default is NULL.
   *
   * EXCEPTIONS
   *   end_of_body       when no data can be returned because the end of
   *                     response body is reached.
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   transfer_timeout  no data is read and a read time-out occurred.
   *   partial_multibyte_char - no data is read and a partial multi-byte
   *                     character is found at the end of the response body.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   The UTL_HTTP package supports HTTP 1.1 chunked transfer-encoding.
   * When the response body is returned in chunked transfer-encoding format
   * as indicated in the response header, the package automatically decodes
   * the chunks and return the response body in "dechunked" format.
   *   If transfer time-out is set in the request of this response, this
   * procedure will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this procedure will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   *   If a partial multi-byte character is found at the end of response body,
   * this function will stop reading and return all the complete multi-byte
   * characters read successfully.  If no complete character is read
   * successfully, the partial_multibyte_char exception will be raised.
   * The exception can be handled and the bytes of that partial multi-byte
   * character can be read as binary by the read_raw procedure.  If a partial
   * multi-byte character is seen in the middle of the response body because
   * the remaining bytes of the character have not arrived and read time-out
   * occurs, the transfer_timeout exception will be raised instead.
   * The exception can be handled and the read operation can be retried
   * at a later time.
   *   When the "Content-Type" response header specifies the character set
   * of the response body and the character set is unknown to or unsupported by
   * Oracle, the "ORA-01482: unsupported character set" exception will be
   * raised if the user tries to read the response body as text. The user
   * may either read the response body as binary using the read_raw procedure,
   * or set the character set of the response body explicitly using the
   * set_body_charset procedure and read the response body as text again.
   */
  PROCEDURE read_text(r    IN OUT NOCOPY resp,
                      data OUT NOCOPY    VARCHAR2 CHARACTER SET ANY_CS,
                      len  IN            PLS_INTEGER DEFAULT NULL);
  PRAGMA restrict_references(read_text, wnds, rnds, trust);

  /**
   * Reads the HTTP response body in text form until the end of line is
   * reached and returns the output in the caller-supplied buffer. The end of
   * line is as defined in the function read_line of UTL_TCP. The end_of_body
   * exception will be raised if the end of the HTTP response body is reached.
   * Text data is automatically converted from the response body character set
   * to the database character set.
   *
   * PARAMETERS
   *   r            The HTTP response
   *   data         The HTTP response body in text form
   *   remove_crlf  Remove the newline characters?
   *
   * EXCEPTIONS
   *   end_of_body       when no data can be returned because the end of
   *                     response body is reached.
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   transfer_timeout  no data is read and a read time-out occurred.
   *   partial_multibyte_char - no data is read and a partial multi-byte
   *                     character is found at the end of the response body.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   The UTL_HTTP package supports HTTP 1.1 chunked transfer-encoding.
   * When the response body is returned in chunked transfer-encoding format
   * as indicated in the response header, the package automatically decodes
   * the chunks and return the response body in "dechunked" format.
   *   If transfer time-out is set in the request of this response, this
   * procedure will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this procedure will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   *   If a partial multi-byte character is found at the end of response body,
   * this function will stop reading and return all the complete multi-byte
   * characters read successfully.  If no complete character is read
   * successfully, the partial_multibyte_char exception will be raised.
   * The exception can be handled and the bytes of that partial multi-byte
   * character can be read as binary by the read_raw procedure.  If a partial
   * multi-byte character is seen in the middle of the response body because
   * the remaining bytes of the character have not arrived and read time-out
   * occurs, the transfer_timeout exception will be raised instead.
   * The exception can be handled and the read operation can be retried
   * at a later time.
   *   When the "Content-Type" response header specifies the character set
   * of the response body and the character set is unknown to or unsupported by
   * Oracle, the "ORA-01482: unsupported character set" exception will be
   * raised if the user tries to read the response body as text. The user
   * may either read the response body as binary using the read_raw procedure,
   * or set the character set of the response body explicitly using the
   * set_body_charset procedure and read the response body as text again.
   */
  PROCEDURE read_line(r           IN OUT NOCOPY resp,
                      data        OUT NOCOPY    VARCHAR2 CHARACTER SET ANY_CS,
                      remove_crlf IN            BOOLEAN DEFAULT FALSE);
  PRAGMA restrict_references(read_line, wnds, rnds, trust);

  /**
   * Reads the HTTP response body in binary form and returns the output in
   * the caller-supplied buffer. The end_of_body exception will be raised if
   * the end of the HTTP response body is reached.
   *
   * PARAMETERS
   *   r            The HTTP response
   *   data         The HTTP response body in binary form
   *   len          The maximum number of bytes of data to read. If len is
   *                NULL, this procedure will read as much input as possible to
   *                fill the buffer allocated in data. The actual amount of
   *                data returned may be less than that specified if not so
   *                much data is available before the end of the HTTP response
   *                body is reached or the transfer_timeout amount of time has
   *                elapsed. The default is NULL.
   *
   * EXCEPTIONS
   *   end_of_body       when no data can be returned because the end of
   *                     response body is reached.
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   transfer_timeout  no data is read and a read time-out occurred.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   The UTL_HTTP package supports HTTP 1.1 chunked transfer-encoding.
   * When the response body is returned in chunked transfer-encoding format
   * as indicated in the response header, the package automatically decodes
   * the chunks and return the response body in "dechunked" format.
   *   If transfer time-out is set in the request of this response, this
   * procedure will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this procedure will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   */
  PROCEDURE read_raw(r    IN OUT NOCOPY resp,
                     data OUT NOCOPY    RAW,
                     len  IN            PLS_INTEGER DEFAULT NULL);
  PRAGMA restrict_references(read_raw, wnds, rnds, trust);

  /**
   * Ends the HTTP response. This completes the HTTP request and response.
   * Unless HTTP 1.1 persistent connection is used in this request, the
   * network connection will also be closed.
   *
   * PARAMETERS
   *   r            The HTTP response
   *
   * EXCEPTIONS
   *
   * When detailed-exception is disabled:
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *   bad_argument      when some of the arguments passed are not valid.
   *   - plus miscellaneous network or runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE end_response(r IN OUT NOCOPY resp);
  PRAGMA restrict_references(end_response, wnds, rnds, trust);

  /*----------------------- Cookies Management API ------------------------*/
  /* The following set of API manipulate the HTTP cookies maintained by the
   * database user session.
   */

  /**
   * Returns the number of cookies maintained either in a request context or 
   * in the UTL_HTTP package's session state.
   *
   * PARAMETERS
   *   request_context  The request context to return the cookie count for.
   *              If NULL, the cookie count maintained in the UTL_HTTP
   *              package's session state will be returned instead.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  FUNCTION get_cookie_count(request_context IN request_context_key DEFAULT NULL)
           RETURN PLS_INTEGER;
  PRAGMA restrict_references(get_cookie_count, wnds, rnds, trust);

  /**
   * Returns all the cookies maintained either in a request context or 
   * in the UTL_HTTP package's session state.
   *
   * PARAMETERS
   *   cookies    The cookies returned.
   *   request_context  The request context to return the cookies for. If NULL,
   *              the cookies maintained in the UTL_HTTP package's session
   *              state will be returned instead.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  PROCEDURE get_cookies(cookies         IN OUT NOCOPY cookie_table,
                        request_context IN request_context_key DEFAULT NULL);
  PRAGMA restrict_references(get_cookies, wnds, rnds, trust);
  
  /**
   * Add the cookies either to a request context or to the UTL_HTTP package's
   * session state.
   *
   * PARAMETERS
   *   cookies    The cookies to be added.
   *   request_context  The request context to add the cookies. If NULL,
   *              the cookies will be added to the UTL_HTTP package's
   *              session state instead.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   The cookies that the package currently maintains will be not cleared
   *   before the new cookies are added.
   */  
  PROCEDURE add_cookies(cookies         IN cookie_table,
                        request_context IN request_context_key DEFAULT NULL);
  PRAGMA restrict_references(add_cookies, wnds, rnds, trust);
  
  /**
   * Clears all the cookies maintained either in a request context or 
   * in the UTL_HTTP package's session state.
   *
   * PARAMETERS
   *   request_context  The request context to clear the cookies. If NULL,
   *              the cookies maintained in the UTL_HTTP package's
   *              session state will be cleared instead.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */  
  PROCEDURE clear_cookies(request_context IN request_context_key DEFAULT NULL);
  PRAGMA restrict_references(clear_cookies, wnds, rnds, trust);

  /*---------------- Persistent Connection Management API -----------------*/
  /* The following set of API manipulate the HTTP persistent connections
   * maintained by the database user session.
   */
  
  /**
   * Returns the number of network connections currently kept persistent by
   * the UTL_HTTP package to the Web servers.
   *
   * PARAMETERS
   *   None.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   Connections to the same Web server at different TCP/IP ports are
   *   counted individually. The host names of the Web servers are identified
   *   as specified in the URL of the original HTTP requests. Therefore,
   *   fully-qualified host names with domain names will be counted differently
   *   from the host names without domain names.
   */
  FUNCTION get_persistent_conn_count RETURN PLS_INTEGER;
  PRAGMA restrict_references(get_persistent_conn_count, wnds, rnds, trust);

  /**
   * Returns all the network connections currently kept persistent by the
   * UTL_HTTP package to the Web servers.
   *
   * PARAMETERS
   *   connections  The network connections currently kept persistent
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   Connections to the same Web server at different TCP/IP ports are
   *   counted individually. The host names of the Web servers are identified
   *   as specified in the URL of the original HTTP requests. Therefore,
   *   fully-qualified host names with domain names will be counted differently
   *   from the host names without domain names.
   */
  PROCEDURE get_persistent_conns(connections IN OUT NOCOPY connection_table);
  PRAGMA restrict_references(get_persistent_conns, wnds, rnds, trust);
  
  /**
   * Closes a HTTP persistent connection maintained by the UTL_HTTP package
   * in the current database session.
   *
   * PARAMETERS
   *   conn      The HTTP persistent connection to close.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   Connections to the same Web server at different TCP/IP ports are
   *   counted individually. The host names of the Web servers are identified
   *   as specified in the URL of the original HTTP requests. Therefore,
   *   fully-qualified host names with domain names will be counted differently
   *   from the host names without domain names.
   */
  PROCEDURE close_persistent_conn(conn IN connection);
  PRAGMA restrict_references(close_persistent_conn, wnds, rnds, trust);

  /**
   * Closes a group of HTTP persistent connections maintained by
   * the UTL_HTTP package in the current database session. This procedure
   * uses a pattern-match approach to decide which persistent connections
   * to close.
   *
   * To close a group of HTTP persistent connection that share a common
   * property (for example, all connections to a particular host, or all
   * SSL connections), set the particular parameter(s) and leave the rest
   * parameters NULL. If a particular parameter set to NULL when this procedure
   * is called, that parameter will not be used to decide which connections
   * to close (namely, the caller does not care that value).
   *
   * For example, the following call to the procedure closes all persistent
   * connections (SSL or non) to foobar
   *
   *   utl_http.close_persistent_conns(host => 'foobar');,
   * 
   * And the following call to the procedure closes all persistent connections
   * (SSL or non) via the proxy www-proxy at TCP/IP port 80
   *
   *   utl_http.close_persistent_conns(proxy_host => 'foobar',
   *                                   proxy_port => 80);
   *
   * And the following call to the procedure closes all persistent connections
   *
   *   utl_http.close_persistent_conns;
   * 
   * PARAMETERS
   *   host       The host for which persistent connections are to be closed.
   *   port       The port number for which persistent connections are to be
   *              closed.
   *   proxy_host The proxy host for which persistent connections are to be
   *              closed.
   *   proxy_host The proxy port for which persistent connections are to be
   *              closed.
   *   ssl        Close persistent SSL connection or non.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   Connections to the same Web server at different TCP/IP ports are
   *   counted individually. The host names of the Web servers are identified
   *   as specified in the URL of the original HTTP requests. Therefore,
   *   fully-qualified host names with domain names will be counted differently
   *   from the host names without domain names.
   *
   *   Note that the use of a NULL value in a parameter when this procedure
   *   is called means that the caller does not care its value when the package
   *   decides which persistent connection to close. In the event that you
   *   want a NULL value in a parameter to match only a NULL value of the
   *   parameter of a persistent connection (which is when you want to close
   *   a specific persistent connection), you should use the
   *   close_persistent_conn procedure that closes a specific persistent
   *   connection.
   */
  PROCEDURE close_persistent_conns(host       IN VARCHAR2    DEFAULT NULL,
                                   port       IN PLS_INTEGER DEFAULT NULL,
                                   proxy_host IN VARCHAR2    DEFAULT NULL,
                                   proxy_port IN PLS_INTEGER DEFAULT NULL,
                                   ssl        IN BOOLEAN     DEFAULT NULL);
  PRAGMA restrict_references(close_persistent_conns, wnds, rnds, trust);

  /*--------------------- Last Detailed Exception API ---------------------*/
  /* This set of API return the last detailed exception when detailed exception
   * is disabled.
   */
  
  /**
   * Retrieves the detailed SQLCODE of the last exception raised.
   *
   * PARAMETERS
   *   None.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  FUNCTION get_detailed_sqlcode RETURN PLS_INTEGER;
  PRAGMA restrict_references(get_detailed_sqlcode, wnds, rnds, trust);

  /**
   * Retrieves the detailed SQLERRM of the last exception raised.
   *
   * PARAMETERS
   *   None.
   *
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   * NOTES
   *   None.
   */
  FUNCTION get_detailed_sqlerrm RETURN VARCHAR2;
  PRAGMA restrict_references(get_detailed_sqlerrm, wnds, rnds, trust);
  
  /*------------------------- Simple Fetch API ----------------------------*/
  /**
   * Fetches a Web page.  This function returns the first 2000 bytes
   * of the page at most.
   *
   * PARAMETERS
   *   url             The URL of the Web page
   *   proxy           The proxy host and port number.  See set_proxy for the
   *                   format of the proxy string.  If proxy is NULL, the
   *                   proxy session of the current session will be used.
   *   wallet_path     The path of the Oracle wallet. The format is
   *                   'file:/<wallet-directory-path>'.  If wallet_path
   *                   is NULL, the wallet set for the current session will
   *                   be used.
   *   wallet_password The password needed to open the wallet. There may a
   *                   second copy of a wallet in a wallet directory that
   *                   may be opened without a password. That second copy of
   *                   the wallet is for read only. If password is NULL, the
   *                   UTL_HTTP package will open the second, read-only copy
   *                   of the wallet instead.  See the documentation on Oracle
   *                   wallets for details. If a password
   *                   is required to open the wallet, it must be given
   *                   explicitly.  This function will NOT use the password
   *                   set previously with set_wallet.
   *
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *
   *   bad_argument      when some of the arguments passed are not valid.
   *   bad_url           when the URL is not valid.
   *   unknown_scheme    when the request scheme is not known.
   *   too_many_requests when there are too many open requests.
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   * - The URL passed as an argument to this function will not be examined
   *   for illegal characters per the URL specification RFC 2396, like spaces
   *   for example. The caller should escape those characters with the UTL_URL
   *   package. See the comments of the package for the list of legal
   *   characters in URLs. Note that URLs should consist of US-ASCII
   *   characters only. The use of non-US-ASCII characters in an URL is
   *   generally unsafe.
   *   URL may contain username and password to authenticate the request to 
   *   the server. The general format would be
   *          <scheme>://[<user>[:<password>]@]<host>[:<port>]/[...].
   * - Please see the documentation of the function set_wallet on the use of
   *   an Oracle wallet, which is required for accessing HTTPS Web servers.
   * - Unless response error check is turned on, this function does not raise
   *   an exception when a 4xx or 5xx response is received from the Web server.
   *   Instead, it returns the formatted error message from the Web server:
   *   "<HTML>
   *   <HEAD>
   *   <TITLE>Error Message</TITLE>
   *   </HEAD>
   *   <BODY>
   *   <H1>Fatal Error 500</H1>
   *   Can't Access Document:  http://home.nothing.comm.
   *   <P>
   *   <B>Reason:</B> Can't locate remote host:  home.nothing.comm.
   *   <P>
   *
   *   <P><HR>
   *   <ADDRESS><A HREF="http://www.w3.org">
   *    CERN-HTTPD3.0A</A></ADDRESS>
   *   </BODY>
   *   </HTML>"
   */
  FUNCTION request(url             IN VARCHAR2,
                   proxy           in VARCHAR2 DEFAULT NULL,
                   wallet_path     IN VARCHAR2 DEFAULT NULL,
                   wallet_password IN VARCHAR2 DEFAULT NULL)
                   RETURN VARCHAR2;
  PRAGMA restrict_references (request, wnds, rnds, wnps, rnps, trust);

  /**
   * Fetches a Web page.  The page is returned in a PL/SQL-table of
   * VARCHAR2(2000) pieces.
   *
   * The elements of the PLSQL-table returned by request_pieces are
   * successive pieces of the data obtained from the HTTP request to that
   * URL.  Here is a typical URL:
   *            http://www.oracle.com
   * So a call to request_pieces could look like the example below. Note the
   * use of the plsql-table method COUNT to discover the number of pieces
   * returned, which may be zero or more:
   *
   * declare
   *   pieces utl_http.html_pieces;
   * begin
   *   pieces := utl_http.request_pieces('http://www.oracle.com/');
   *   for i in 1 .. pieces.count loop
   *     .... -- process each piece
   *   end loop;
   * end;
   *
   * PARAMETERS
   *   url             The URL of the Web page
   *   max_pieces      The maximum number of VARCHAR2 pieces to retrieve
   *   proxy           The proxy host and port number.  See set_proxy for the
   *                   format of the proxy string.  If proxy is NULL, the
   *                   proxy session of the current session will be used.
   *   wallet_path     The path of the Oracle wallet. The format is
   *                   'file:/<wallet-directory-path>'.  If wallet_path
   *                   is NULL, the wallet set for the current session will
   *                   be used.
   *   wallet_password The password needed to open the wallet. There may a
   *                   second copy of a wallet in a wallet directory that
   *                   may be opened without a password. That second copy of
   *                   the wallet is for read only. If password is NULL, the
   *                   UTL_HTTP package will open the second, read-only copy
   *                   of the wallet instead.  See the documentation on Oracle
   *                   wallets for details. If a password
   *                   is required to open the wallet, it must be given
   *                   explicitly.  This function will NOT use the password
   *                   set previously with set_wallet.
   *
   *   request_failed    the request fails to execute
   *                     (use get_detailed_sqlcode and get_detailed_sqlerrm to
   *                      get the detailed error message)
   *
   * When detailed-exception is enabled:
   *
   *   bad_argument      when some of the arguments passed are not valid.
   *   bad_url           when the URL is not valid.
   *   unknown_scheme    when the request scheme is not known.
   *   too_many_requests when there are too many open requests.
   *   - plus miscellaneous network and runtime exceptions.
   * NOTES
   * - The URL passed as an argument to this function will not be examined
   *   for illegal characters per the URL specification RFC 2396, like spaces
   *   for example. The caller should escape those characters with the UTL_URL
   *   package. See the comments of the package for the list of legal
   *   characters in URLs. Note that URLs should consist of US-ASCII
   *   characters only. The use of non-US-ASCII characters in an URL is
   *   generally unsafe.
   *   URL may contain username and password to authenticate the request to 
   *   the server. The general format would be
   *          <scheme>://[<user>[:<password>]@]<host>[:<port>]/[...].
   * - Each entry of the PL/SQL table (the "pieces") returned by this function
   *   may not be filled to their fullest capacity.  The function may
   *   start filling the data in the next "piece" before the previous "piece"
   *   is totally full.
   * - Please see the documentation of the function set_wallet on the use of
   *   an Oracle wallet, which is required for accessing HTTPS Web servers.
   * - Unless response error check is turned on, this function does not raise
   *   an exception when a 4xx or 5xx response is received from the Web server
   *   Instead, it returns the formatted error message from the Web server:
   *   "<HTML>
   *   <HEAD>
   *   <TITLE>Error Message</TITLE>
   *   </HEAD>
   *   <BODY>
   *   <H1>Fatal Error 500</H1>
   *   Can't Access Document:  http://home.nothing.comm.
   *   <P>
   *   <B>Reason:</B> Can't locate remote host:  home.nothing.comm.
   *   <P>
   *
   *   <P><HR>
   *   <ADDRESS><A HREF="http://www.w3.org">
   *    CERN-HTTPD3.0A</A></ADDRESS>
   *   </BODY>
   *   </HTML>"
   */
  FUNCTION request_pieces(url             IN VARCHAR2,
                          max_pieces      IN NATURAL  DEFAULT 32767,
                          proxy           in VARCHAR2 DEFAULT NULL,
                          wallet_path     IN VARCHAR2 DEFAULT NULL,
                          wallet_password IN VARCHAR2 DEFAULT NULL)
                          RETURN html_pieces;
  PRAGMA restrict_references (request_pieces, wnds, rnds, wnps, rnps, trust);

END utl_http;
/

GRANT EXECUTE ON utl_http TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_http FOR sys.utl_http;
