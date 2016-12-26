REM Copyright (c) 1999, 2006, Oracle. All rights reserved.  
REM
REM  NAME
REM    utlinad.sql - PL/SQL Package for Internet address
REM                  (Package Specification of UTL_INADDR)
REM
REM  DESCRIPTION
REM    Routines to perform Internet address resolution.
REM
REM  NOTES
REM    The procedural option is needed to use this package.
REM    This package must be created under SYS.
REM
REM  MODIFIED (MM/DD/YY)
REM  rpang     09/27/06 - Added network_access_denied exception
REM  rpang     08/28/06 - Changed package to invoker rights
REM  gviswana  05/25/01 - CREATE OR REPLACE SYNONYM
REM  rpang     03/08/01 - Changed error code
REM  rpang     02/27/01 - Added reverse-DNS lookup functionality
REM  rpang     08/11/99 - Added constants for error codes
REM  rpang     05/14/99 - Created

CREATE OR REPLACE PACKAGE utl_inaddr AUTHID CURRENT_USER AS

 /*******************************************************************
  * OVERVIEW
  *
  * This package allows a PL/SQL program to retrieve host name and
  * IP address information of local or remote host.  The functionality
  * provided by this package does not cover the full functionality of
  * Domain Name Resolution (also known as DNS).
  *
  * USES
  *
  * Call get_host_name() to retrieve the name of a local or remote host.
  * Call get_host_address() to retrieve the IP address of a local or remote
  * host.
  *
  * EXAMPLES
  *   Retrieve local host name and IP address.
  *
  * BEGIN
  *   dbms_output.put_line(utl_inaddr.get_host_name);  -- get local host name
  *   dbms_output.put_line(utl_inaddr.get_host_address);  -- get local IP addr
  * END;
  */

  /*
   * Exceptions
   */
  unknown_host             EXCEPTION;  -- Unknown host
  network_access_denied    EXCEPTION;  -- Network access denied
  unknown_host_errcode           CONSTANT PLS_INTEGER := -29257;
  network_access_denied_errcode  CONSTANT PLS_INTEGER := -24247;
  PRAGMA EXCEPTION_INIT(unknown_host,          -29257);
  PRAGMA EXCEPTION_INIT(network_access_denied, -24247);

  /**
   * Retrieves the name of the local or remote host given its IP address.
   *
   * PARAMETERS
   *   ip    the IP address of the host to determine its host name.
   *         If ip is not NULL, the official name of the host with its
   *         domain name will be returned.  If this is null, the name of
   *         the local host will be returned and the name will not contain
   *         the domain to which the local host belongs.
   * RETURN
   *   The name of the local or remote host of the specified IP address.
   * EXCEPTIONS
   *   unknown_host  - the specified IP address is not known.
   */
  FUNCTION get_host_name(ip IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /**
   * Retrieves the IP address of the specified host.
   *
   * PARAMETERS
   *   host  the host to determine its IP address.  If this is null,
   *         the IP address of the local host will be returned.
   * RETURN
   *   The IP address of the specified host, or that of the local host
   * if host is NULL.
   * EXCEPTIONS
   *   unknown_host  - the specified host is not known.
   */
  FUNCTION get_host_address (host IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END;
/

GRANT EXECUTE ON sys.utl_inaddr TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_inaddr FOR sys.utl_inaddr;
