REM Copyright (c) 1999, 2012, Oracle and/or its affiliates. 
REM All rights reserved. 
REM
REM  NAME
REM    utltcp.sql - PL/SQL Package for TCP/IP communication
REM                 (Package Specification of UTL_TCP)
REM
REM  DESCRIPTION
REM    Routines to perform TCP/IP communication.
REM
REM  NOTES
REM    The procedural option is needed to use this package.
REM    This package must be created under SYS.
REM
REM  MODIFIED (MM/DD/YY)
REM  apfwkr    02/16/12 - Backport anighosh_bug-13589644 from main
REM  rpang     10/08/09 - Added SSL/TLS support
REM  rpang     09/27/06 - Added network_access_denied exception
REM  rpang     08/28/06 - Changed package to invoker rights
REM  rpang     11/10/05 - Use unistr for CRLF constant
REM  sylin     12/05/02 - 2351330: Add NCAHR support
REM  gviswana  05/25/01 - CREATE OR REPLACE SYNONYM
REM  rpang     02/15/01 - 1503844: added time-out support
REM  rpang     02/16/01 - Added partial_multibyte_char exception
REM  rpang     12/21/00 - Added charset to open_connection in sample codes
REM  rpang     08/17/00 - Fixed typo
REM  rpang     08/01/00 - Made definition of CRLF constant portable
REM  rpang     07/27/00 - Clarify the portable behavior of available()
REM  rpang     07/25/00 - Fixed sample code
REM  rpang     07/02/00 - Changed error numbers of the exceptions
REM  rpang     06/30/00 - Clarify on the return value of available()
REM  rpang     06/30/00 - local_host and local_port params are ignored IN
REM                       open_connection
REM  rpang     05/15/00 - Removed private buffers
REM  jmuller   10/07/99 - Fix bug 708690: TAB -> blank
REM  rpang     08/11/99 - Added constants for error codes
REM  rpang     07/28/99 - Added BAD_ARGUMENT exception
REM  rpang     05/14/99 - Created

CREATE OR REPLACE PACKAGE utl_tcp AUTHID CURRENT_USER AS

 /*******************************************************************
  * OVERVIEW
  *
  * This package provides TCP/IP client-side access functionality in PL/SQL.
  * With this package, a PL/SQL program can communicate with external TCP/IP
  * services and retrieve data.  The API only allows connections to be
  * initiated by the PL/SQL program.  It does not allow the PL/SQL program
  * to accept connections initiated from outside of the program.
  *
  * USES
  *
  * A TCP/IP connection is initiated by a call to open_connection, which
  * returns a TCP/IP connection.  Text and binary data can be sent or
  * received on the connection.  It is also possible to look ahead at the
  * data before it is actually read.  The connection is terminated by
  * a call to close_connection.
  *
  * EXAMPLES
  *   Retrieve the home page from http://www.acme.com/
  *
  *   DECLARE
  *     c   utl_tcp.connection;  -- TCP/IP connection to the Web server
  *     len PLS_INTEGER;
  *   BEGIN
  *     -- open connection
  *     c := utl_tcp.open_connection(remote_host => 'www.acme.com',
  *                                  remote_port => 80,
  *                                  charset     => 'US7ASCII');
  *
  *     len := utl_tcp.write_line(c, 'GET / HTTP/1.0');    -- send HTTP request
  *     len := utl_tcp.write_line(c);
  *     BEGIN
  *       LOOP
  *         dbms_output.put_line(utl_tcp.get_line(c, TRUE));  -- read result
  *       END LOOP;
  *     EXCEPTION
  *       WHEN utl_tcp.end_of_input THEN
  *         NULL; -- end of input
  *     END;
  *     utl_tcp.close_connection(c);
  *   END;
  */

  /*
   * TCP connection type
   */
  TYPE connection IS RECORD (
    remote_host   VARCHAR2(255),   -- Remote host name
    remote_port   PLS_INTEGER,     -- Remote port number
    local_host    VARCHAR2(255),   -- Local host name
    local_port    PLS_INTEGER,     -- Local port number
    charset       VARCHAR2(30),    -- Character set for on-the-wire comm.
    newline       VARCHAR2(2),     -- Newline character sequence
    tx_timeout    PLS_INTEGER,     -- Transfer time-out value (in seconds)
    private_sd    PLS_INTEGER      -- For internal use only
  );

  /*
   * Carriage-return line-feed character sequence.
   */
  CRLF CONSTANT VARCHAR2(2 CHAR) := unistr('\000D\000A');

  /*
   * Exceptions
   */
  buffer_too_small       EXCEPTION;  -- Buffer is too small for I/O
  end_of_input           EXCEPTION;  -- End of input from the connection
  network_error          EXCEPTION;  -- Network error
  bad_argument           EXCEPTION;  -- Bad argument passed in API call
  partial_multibyte_char EXCEPTION;  -- A partial multi-byte character found
  transfer_timeout       EXCEPTION;  -- Transfer time-out occurred
  network_access_denied  EXCEPTION;  -- Network access denied
  buffer_too_small_errcode       CONSTANT PLS_INTEGER:= -29258;
  end_of_input_errcode           CONSTANT PLS_INTEGER:= -29259;
  network_error_errcode          CONSTANT PLS_INTEGER:= -29260;
  bad_argument_errcode           CONSTANT PLS_INTEGER:= -29261;
  partial_multibyte_char_errcode CONSTANT PLS_INTEGER:= -29275;
  transfer_timeout_errcode       CONSTANT PLS_INTEGER:= -29276;
  network_access_denied_errcode  CONSTANT PLS_INTEGER:= -24247;
  PRAGMA EXCEPTION_INIT(buffer_too_small,      -29258);
  PRAGMA EXCEPTION_INIT(end_of_input,          -29259);
  PRAGMA EXCEPTION_INIT(network_error,         -29260);
  PRAGMA EXCEPTION_INIT(bad_argument,          -29261);
  PRAGMA EXCEPTION_INIT(partial_multibyte_char,-29275);
  PRAGMA EXCEPTION_INIT(transfer_timeout,      -29276);
  PRAGMA EXCEPTION_INIT(network_access_denied, -24247);

  /**
   * Opens a connection to a TCP/IP service.  When connection is made
   * succesfully, the remote host name and remote port number will be stored in
   * the connection.  If local_host, local_port or charset is specified,
   * it will be stored in the connection as well.
   *
   * Communication with the remote service may be secured using Secure Socket
   * Layer / Transport Layer Security (SSL/TLS). To start SSL/TLS in the
   * connection, the user must specify an Oracle wallet when opening the
   * connection and call the SECURE_CONNECTION procedure. The wallet must
   * contain the trusted certificate of the certificate authority who signs
   * the remote server's certificate for UTL_TCP to validate the remote
   * server's certificate.
   *
   * UTL_TCP supports client authentication over SSL/TLS using the client
   * certificate in the wallet. The client certificate will be sent to the
   * remote server if it is present in the wallet and if the caller has the
   * "use-client-certificates" ACL privilege on the wallet.
   *
   * For more information on Oracle wallets, see Oracle Wallet Manager
   * documentation.
   *
   * PARAMETERS
   *   remote_host     remote host name to connect to
   *   remote_port     remote port number to connect to
   *   local_host      local host name to connect from
   *   local_port      local port number to connect from
   *   in_buffer_size  input buffer size
   *   out_buffer_size output buffer size
   *   charset         character set for on-the-wire communication
   *   newline         newline character sequence
   *   tx_timeout      a time in seconds this package should wait before
   *                   giving up in a read or write operation in this
   *                   connection. In read operations, this package will give
   *                   up if no data is available for reading immediately.
   *                   In write operations, this package will give if the
   *                   output buffer is full and no data be sent in the
   *                   network without being blocked.  0 indicates not to wait
   *                   at all.  NULL indicates to wait forever.
   *   wallet_path     the directory path that contains the Oracle wallet for
   *                   SSL/TLS. The format is "file:<directory-path>".
   *   wallet_password the password to open the wallet. When the wallet is
   *                   auto-login enabled, the password may be set to NULL.
   * RETURN
   *   a connection to the destinated TCP/IP service.
   * EXCEPTIONS
   *   network_error  - network error
   * NOTES
   *   In the current release of this package, the parameters local_host and
   * local_port are ignored when open_connection makes a TCP/IP connection.
   * It does not attempt to use the specified local host and port number
   * when the connection is made.  The local_host and local_port fields
   * will not be set in the connection record returned by this function.
   *   Time-out on write operations is not supported in the current release
   * of this package.
   */
  FUNCTION open_connection(remote_host     IN VARCHAR2,
                           remote_port     IN PLS_INTEGER,
                           local_host      IN VARCHAR2    DEFAULT NULL,
                           local_port      IN PLS_INTEGER DEFAULT NULL,
                           in_buffer_size  IN PLS_INTEGER DEFAULT NULL,
                           out_buffer_size IN PLS_INTEGER DEFAULT NULL,
                           charset         IN VARCHAR2    DEFAULT NULL,
                           newline         IN VARCHAR2    DEFAULT CRLF,
                           tx_timeout      IN PLS_INTEGER DEFAULT NULL,
                           wallet_path     IN VARCHAR2    DEFAULT NULL,
                           wallet_password IN VARCHAR2    DEFAULT NULL)
                           RETURN connection;

  /**
   * Secure a TCP/IP connection using Secure Socket Layer / Transport Layer
   * Security (SSL/TLS). SSL/TLS requires an Oracle wallet which must be
   * specified when the connection was opened by the OPEN_CONNECTION function.
   *
   * PARAMETERS
   *   c                TCP/IP connection
   * RETURN
   *   None
   * EXCEPTIONS
   *   SSL/TLS errors - error occurred in SSL/TLS communication
   * NOTES
   *   See the OPEN_CONNECTION function.
   */
  PROCEDURE secure_connection(c IN OUT NOCOPY connection);

  /**
   * Determines the number of bytes available for reading from a TCP/IP
   * connection.  It is the number of bytes that can be read immediately
   * without blocking.
   *
   * PARAMETERS
   *   c          TCP/IP connection
   *   timemout   a time in seconds to wait before giving up and reporting
   *              no data available.  0 indicates not to wait at all.  NULL
   *              indicates to wait forever.
   * RETURN
   *   The number of bytes available for reading without blocking.
   * EXCEPTIONS
   *   network_error  - network error
   * NOTES
   *   The number of bytes available for reading returned by this function
   * may be a conservative estimate in some situations.  It may be less than
   * what is actually available for reading.  On some platforms, this function
   * may only be able to return just 1 to indicate the fact that some data is
   * available for reading.  Users who are concerned with the portability of
   * their applications should assume that this function returns a positive
   * value when data is available for reading, and zero when no data is
   * available.  This is an example that illustrates how to use this function
   * in a portable manner:
   *
   *    DECLARE
   *      c     utl_tcp.connection;
   *      data  VARCHAR2(256);
   *      len   PLS_INTEGER;
   *    BEGIN
   *      c := utl_tcp.open_connection(...);
   *      LOOP
   *        IF (utl_tcp.available(c) > 0) THEN
   *          len := utl_tcp.read_text(c, data, 256);
   *        ELSE
   *          -- do some other things
   *          ...
   *        END IF;
   *      END LOOP;
   *    END;
   */
  FUNCTION available(c       IN OUT NOCOPY connection,
                     timeout IN            PLS_INTEGER DEFAULT 0)
                     RETURN PLS_INTEGER;

  /*----------------------- Binary Input/Output API -----------------------*/

  /**
   * Reads binary data from a TCP/IP connection.  This function does not
   * return until the specified number of bytes have been read, or the end
   * of input has been reached.
   *
   * PARAMETERS
   *   c      TCP/IP connection
   *   data   the data read (OUT)
   *   len    the max number of bytes to read
   *   peek   should this call be peek-only (i.e. keep the data read
   *          in the input buffer to be read again later)?
   * RETURN
   *   The number of bytes read.  The actual number of bytes read may be
   * less than specified because the end of input has been reached.
   * EXCEPTIONS
   *   value_error    - the buffer "data" is not big enough to hold the
   *                    requested amount of data.
   *   end_of_input   - no data is read and the end of input is reached
   *   transfer_timeout - no data is read and a read time-out occurred
   *   network_error  - network error
   * NOTES
   *   If transfer time-out is set when the connection is opened, this
   * function will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this function will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   */
  FUNCTION read_raw(c    IN OUT NOCOPY connection,
                    data IN OUT NOCOPY RAW,
                    len  IN            PLS_INTEGER DEFAULT 1,
                    peek IN            BOOLEAN     DEFAULT FALSE)
                    RETURN PLS_INTEGER;

  /**
   * Writes binary data to a TCP/IP connection.  This function does not
   * return until the specified number of bytes have been written.
   *
   * PARAMETERS
   *   c      TCP/IP connection
   *   data   the data to be written
   *   len    the number of bytes to write.  When len is NULL, the
   *          whole length of data is written.  The actual amount of
   *          data written may be less because of network condition
   * RETURN
   *   The actual number of bytes written to the connection.
   * EXCEPTIONS
   *   network_error  - network error
   */
  FUNCTION write_raw(c    IN OUT NOCOPY connection,
                     data IN            RAW,
                     len  IN            PLS_INTEGER DEFAULT NULL)
                     RETURN PLS_INTEGER;

  /*------------------------- Text Input/Output API ----------------------*/

  /**
   * Reads text data from a TCP/IP connection.  This function does not
   * return until the specified number of characters have been read, or the end
   * of input has been reached.
   *
   * PARAMETERS
   *   c      TCP/IP connection
   *   data   the data read (OUT)
   *   len    the max number of characters to read
   *   peek   should this call be peek-only (i.e. keep the data read
   *          in the input buffer to be read again later)?
   * RETURN
   *   The number of characters read.  The actual umber of characters read
   * may be less than specified because the end of input has been reached.
   * EXCEPTIONS
   *   value_error    - the buffer "data" is not big enough to hold the
   *                    requested amount of data.
   *   end_of_input   - no data is read and the end of input is reached
   *   transfer_timeout - no data is read and a read time-out occurred
   *   partial_multibyte_char - no data is read and a partial multi-byte
   *                    character is found at the end of input
   *   network_error  - network error
   * NOTES
   *   If transfer time-out is set when the connection is opened, this
   * function will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this function will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   *   Text messages will be converted from the on-the-wire character set,
   * specified when the connection was opened, to the database character set
   * before they are returned to the caller.
   *   Note that unless it is explicitly overridden as in terms of characters,
   * the size of a VARCHAR2 buffer is normally specified in terms of bytes,
   * while the parameter len refers to the max. number of characters to be
   * read.  When the database character set is multi-byte where a single
   * character may consist of more than 1 byte, user should make sure that
   * the buffer is big enough to hold the max. number of characters.  In
   * general, the size of the VARCHAR2 buffer should equal to the number
   * of characters to read multiplied by the max. number of bytes of a
   * character of the database character set.
   *   If a partial multi-byte character is found at the end of input,
   * this function will stop reading and return all the complete multi-byte
   * characters read successfully.  If no complete character is read
   * successfully, the partial_multibyte_char exception will be raised.
   * The exception can be handled and the bytes of that partial multi-byte
   * character can be read as binary by the read_raw function.  If a partial
   * multi-byte character is seen in the middle of the input because the
   * remaining bytes of the character have not arrived and read time-out
   * occurs, the transfer_timeout exception will be raised instead.
   * The exception can be handled and the read operation can be retried
   * at a later time.
   */
  FUNCTION read_text(c    IN OUT NOCOPY connection,
                     data IN OUT NOCOPY VARCHAR2 CHARACTER SET ANY_CS,
                     len  IN            PLS_INTEGER DEFAULT 1,
                     peek IN            BOOLEAN     DEFAULT FALSE)
                     RETURN PLS_INTEGER;

  /**
   * Writes text data to a TCP/IP connection.  This function does not
   * return until the specified number of characters have been written.
   *
   * PARAMETERS
   *   c      TCP/IP connection
   *   data   the data to be written
   *   len    the number of characters to write.   When len is NULL,
   *          the whole length of data is written.  The amount of
   *          data returned may be less because of network condition
   * RETURN
   *   The number of characters of data written to the connection.
   * EXCEPTIONS
   *   network_error  - network error
   * NOTES
   *   Text messages will be converted from the database character set
   * to the on-the-wire character set, specified when the connection was
   * opened, before they are transmitted on the wire.
   */
  FUNCTION write_text(c    IN OUT NOCOPY connection,
                      data IN            VARCHAR2 CHARACTER SET ANY_CS,
                      len  IN            PLS_INTEGER DEFAULT NULL)
                      RETURN PLS_INTEGER;

  /*------------------- Line-oriented Input/Output API ----------------------*/

  /**
   * Reads a text line from a TCP/IP connection.  A line is terminated by
   * a line-feed, a carriage-return or a carriage-return followed by a
   * line-feed.  The function does not return until the end of line or the
   * end of input is reached.
   *
   * PARAMETERS
   *   c           TCP/IP connection
   *   data        the data read (OUT)
   *   remove_crlf remove the trailing new-line character(s) or not
   *   peek        should this call be peek-only (i.e. keep the data read
   *               in the input buffer to be read again later)?
   * RETURN
   *   The number of characters read.
   * EXCEPTIONS
   *   value_error    - the buffer "data" is not big enough to hold the
   *                    requested amount of data.
   *   end_of_input   - no data is read and the end of input is reached
   *   transfer_timeout - no data is read and a read time-out occurred
   *   partial_multibyte_char - no data is read and a partial multi-byte
   *                    character is found at the end of input
   *   network_error  - network error
   * NOTES
   *   If transfer time-out is set when the connection is opened, this
   * function will wait for each data packet to be ready to read until
   * time-out occurs.  If it occurs, this function will stop reading and
   * return all the data read successfully.  If no data is read successfully,
   * the transfer_timeout exception will be raised.  The exception can be
   * handled and the read operation can be retried at a later time.
   *   Text messages will be converted from the on-the-wire character set,
   * specified when the connection was opened, to the database character set
   * before they are returned to the caller.
   *   Note that unless it is explicitly overridden as in terms of characters,
   * the size of a VARCHAR2 buffer is normally specified in terms of bytes,
   * while the parameter len refers to the max. number of characters to be
   * read.  When the database character set is multi-byte where a single
   * character may consist of more than 1 byte, user should make sure that
   * the buffer is big enough to hold the max. number of characters.  In
   * general, the size of the VARCHAR2 buffer should equal to the number
   * of characters to read multiplied by the max. number of bytes of a
   * character of the database character set.
   *   If a partial multi-byte character is found at the end of input,
   * this function will stop reading and return all the complete multi-byte
   * characters read successfully.  If no complete character is read
   * successfully, the partial_multibyte_char exception will be raised.
   * The exception can be handled and the bytes of that partial multi-byte
   * character can be read as binary by the read_raw function.  If a partial
   * multi-byte character is seen in the middle of the input because the
   * remaining bytes of the character have not arrived and read time-out
   * occurs, the transfer_timeout exception will be raised instead.
   * The exception can be handled and the read operation can be retried
   * at a later time.
   */
  FUNCTION read_line(c           IN OUT NOCOPY connection,
                     data        IN OUT NOCOPY VARCHAR2 CHARACTER SET ANY_CS,
                     remove_crlf IN            BOOLEAN DEFAULT FALSE,
                     peek        IN            BOOLEAN DEFAULT FALSE)
                     RETURN PLS_INTEGER;

  /**
   * Writes a text line to a TCP/IP connection.  The line is terminated
   * with the new-line character sequence sepecified when this connection
   * is opened.
   *
   * PARAMETERS
   *   c     TCP/IP connection
   *   data  the data to be written
   * RETURN
   *   Then number of characters of data written to the connection.
   * EXCEPTIONS
   *   network_error  - network error
   * NOTES
   *   Text messages will be converted from the database character set
   * to the on-the-wire character set, specified when the connection was
   * opened, before they are transmitted on the wire.
   */
  FUNCTION write_line(c    IN OUT NOCOPY connection,
                      data IN            VARCHAR2  CHARACTER SET ANY_CS
                                           DEFAULT NULL)
                      RETURN PLS_INTEGER;

  /*----------------- Convenient functions for Input API ------------------*/

  /**
   * A convenient form of the read functions, which return the data read
   * instead of the amount of data read.
   *
   * PARAMETERS
   *   c            TCP/IP connection
   *   len          the max number of bytes or characters to read
   *   removle_crlf remove the trailing new-line character(s) or not
   *   peek         should this call be peek-only (i.e. keep the data read
   *                in the input buffer to be read again later)?
   * RETURN
   *   The data (or line) read.
   * EXCEPTIONS
   *   end_of_input   - no data is read and the end of input is reached
   *   partial_multibyte_char - no data is read and a partial multi-byte
   *                    character is found at the end of input
   *   transfer_timeout - no data is read and a read time-out occurred
   *   network_error  - network error
   * NOTES
   *   For all get_XXX API, see the corresponding read_XXX API for the
   * read time-out issue.
   *   For get_text and get_line, see the corresponding read_XXX API for
   * character set conversion, buffer size, and multi-byte character issues.
   */
  FUNCTION get_raw(c    IN OUT NOCOPY connection,
                   len  IN            PLS_INTEGER DEFAULT 1,
                   peek IN            BOOLEAN     DEFAULT FALSE)
                   RETURN RAW;
  FUNCTION get_text(c    IN OUT NOCOPY connection,
                    len  IN            PLS_INTEGER DEFAULT 1,
                    peek IN            BOOLEAN     DEFAULT FALSE)
                    RETURN VARCHAR2;
  FUNCTION get_line(c           IN OUT NOCOPY connection,
                    remove_crlf IN            BOOLEAN DEFAULT false,
                    peek        IN            BOOLEAN DEFAULT FALSE)
                    RETURN VARCHAR2;
  FUNCTION get_text_nchar(c    IN OUT NOCOPY connection,
                          len  IN            PLS_INTEGER DEFAULT 1,
                          peek IN            BOOLEAN     DEFAULT FALSE)
                          RETURN NVARCHAR2;
  FUNCTION get_line_nchar(c           IN OUT NOCOPY connection,
                          remove_crlf IN            BOOLEAN DEFAULT false,
                          peek        IN            BOOLEAN DEFAULT FALSE)
                          RETURN NVARCHAR2;

  /**
   * Transmits all the output data in the output queue to the connection
   * immediately.
   *
   * PARAMETERS
   *   c   TCP/IP connection
   * RETURN
   *   None.
   * EXCEPTIONS
   *   network_error  - network error
   */
  PROCEDURE flush(c IN OUT NOCOPY connection);

  /**
   * Closes a TCP/IP connection.  After the connection is closed, all the
   * in the connection will be set to NULL.
   *
   * PARAMETERS
   *   c    TCP/IP connection
   * RETURN
   *   None.
   * EXCEPTIONS
   *   network_error  - network error
   */
  PROCEDURE close_connection(c IN OUT NOCOPY connection);

  /**
   * Closes all open TCP/IP connections.
   *
   * PARAMETERS
   *   None
   * RETURN
   *   None
   * EXCEPTIONS
   *   None
   */
  PROCEDURE close_all_connections;

END;
/

GRANT EXECUTE ON sys.utl_tcp TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_tcp FOR sys.utl_tcp;
