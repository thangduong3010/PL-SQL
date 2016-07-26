REM Copyright (c) 1999, 2009, Oracle and/or its affiliates. 
REM All rights reserved. 
REM
REM  NAME
REM    utlsmtp.sql - PL/SQL Package for Simple Mail Transfer Protocol (SMTP)
REM                  communication (Package Specification of UTL_SMTP)
REM
REM  DESCRIPTION
REM    Routines to perform SMTP communication.
REM
REM  NOTES
REM    The procedural option is needed to use this package.
REM    This package must be created under SYS.
REM
REM  MODIFIED (MM/DD/YY)
REM  rpang     10/09/09 - Added SSL/TLS and authentication support
REM  rpang     01/13/09 - 7661524: add close_connection API
REM  rpang     05/04/06 - Made invoker rights routine
REM  sylin     12/06/02 - 2351330: Add NCAHR support
REM  rpang     06/07/01 - 1354818: fixed sample code
REM  gviswana  05/25/01 - CREATE OR REPLACE SYNONYM
REM  rpang     03/05/01 - Changed exception message codes
REM  rpang     02/27/01 - Added transfer time-out support
REM  rpang     03/27/00 - 1239254: added write_raw_data
REM  jmuller   10/07/99 - Fix bug 708690: TAB -> blank
REM  rpang     08/12/99 - Added exception codes
REM  rpang     08/12/99 - Fixed comments
REM  rpang     07/27/99 - Added INVALID_OPERATION exception
REM  rpang     07/23/99 - Modified datatype of port number to PLS_INTEGER
REM  rpang     05/19/99 - Created

CREATE OR REPLACE PACKAGE utl_smtp AUTHID CURRENT_USER AS

 /*******************************************************************
  * OVERVIEW
  *
  * This package provides SMTP client-side access functionality in PL/SQL.
  * With this package, a PL/SQL program can send electronic mails via SMTP.
  * This package does not allow the PL/SQL program to receive e-mails via
  * SMTP.  The user of this package should be familiar with the SMTP protocol
  * as defined in RFC 821 and RFC 1869.
  *
  * This package is meant to provide an API to SMTP protocol directly.  Users
  * may find it useful to define additional helper routines to encapsulate
  * the interaction with a SMTP server.
  *
  * USES
  *
  * A SMTP connection is initiated by a call to open_connection, which
  * returns a SMTP connection.  After a connection is established, the
  * following calls are required to send a mail:
  *
  *   helo()       - identify the domain of the sender
  *   mail()       - start a mail, specify the sender
  *   rcpt()       - specify the recipient
  *   open_data()  - start the mail body
  *   write_data() - write the mail body (multiple calls allowed)
  *   close_data() - close the mail body and send the mail
  *
  * The SMTP connection is closed by calling quit().
  *
  * A note on API style and raising PL/SQL exception:
  *
  * Most of the API has a function form and a procedure form.  The function
  * form returns the reply message after the command is sent, in the form
  * of "XXX <an optional reply message>", where XXX is the reply code.
  * The procedure form of the same API calls the function form of the API,
  * checks the reply code and raises transient_error or permanent_error
  * exception if the reply code is in 400 or 500 range.  The function form
  * of the API does not raise either of the 2 exceptions.
  * 
  * All API may raise invalid_operation exception if it is called in either
  * of the situations:
  *
  *   1. calling API other than write_data(), write_raw_data() or close_data()
  *      after open_data(0 is called, or
  *   2. calling write_data(), write_raw_data() or close_data() without
  *      first calling open_data()
  *
  * EXAMPLES
  *   Retrieve the home page from http://www.acme.com/
  *
  *   DECLARE
  *     c utl_smtp.connection;
  *
  *     PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) AS
  *     BEGIN
  *       utl_smtp.write_data(c, name || ': ' || header || utl_tcp.CRLF);
  *     END;
  *
  *   BEGIN
  *     c := utl_smtp.open_connection('smtp-server.acme.com');
  *     utl_smtp.helo(c, 'foo.com');
  *     utl_smtp.mail(c, 'sender@foo.com');
  *     utl_smtp.rcpt(c, 'recipient@foo.com');
  *     utl_smtp.open_data(c);
  *     send_header('From',    '"Sender" <sender@foo.com>');
  *     send_header('To',      '"Recipient" <recipient@foo.com>');
  *     send_header('Subject', 'Hello');
  *     utl_smtp.write_data(c, utl_tcp.CRLF || 'Hello, world!');
  *     utl_smtp.close_data(c);
  *     utl_smtp.quit(c);
  *   EXCEPTION
  *     WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
  *       BEGIN
  *         utl_smtp.quit(c);
  *       EXCEPTION       
  *         WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
  *           NULL; -- When the SMTP server is down or unavailable, we don't
  *                 -- have a connection to the server. The quit call will
  *                 -- raise an exception that we can ignore.
  *       END;
  *       raise_application_error(-20000,
  *         'Failed to send mail due to the following error: ' || sqlerrm);
  *   END;
  */

  /*
   * SMTP connection type
   */
  TYPE connection IS RECORD (
    host             VARCHAR2(255),       -- Host name of SMTP server
    port             PLS_INTEGER,         -- Port number of SMTP server
    tx_timeout       PLS_INTEGER,         -- Transfer time-out (in seconds)
    private_tcp_con  utl_tcp.connection,  -- For internal use only
    private_state    PLS_INTEGER          -- For internal use only
  );

  /*
   * SMTP reply structure
   */
  TYPE reply IS RECORD (
    code     PLS_INTEGER,                 -- 3-digit reply code
    text     VARCHAR2(508)                -- reply text
  );
  -- multiple reply lines
  TYPE replies IS TABLE OF reply INDEX BY BINARY_INTEGER;

  /*
   * Exceptions
   */
  invalid_operation   EXCEPTION;  -- Operation is invalid
  transient_error     EXCEPTION;  -- Transient server error in 400 range
  permanent_error     EXCEPTION;  -- Permanent server error in 500 range
  unsupported_scheme  EXCEPTION;  -- Unsupported authentication scheme
  no_supported_scheme EXCEPTION;  -- No supported authentication scheme
  invalid_operation_errcode   CONSTANT PLS_INTEGER:= -29277;
  transient_error_errcode     CONSTANT PLS_INTEGER:= -29278;
  permanent_error_errcode     CONSTANT PLS_INTEGER:= -29279;
  unsupported_scheme_errcode  CONSTANT PLS_INTEGER:= -24249;
  no_supported_scheme_errcode CONSTANT PLS_INTEGER:= -24250;
  PRAGMA EXCEPTION_INIT(invalid_operation,   -29277);
  PRAGMA EXCEPTION_INIT(transient_error,     -29278);
  PRAGMA EXCEPTION_INIT(permanent_error,     -29279);
  PRAGMA EXCEPTION_INIT(unsupported_scheme,  -24249);
  PRAGMA EXCEPTION_INIT(no_supported_scheme, -24250);

  /*
   * SMTP authentication schemes for use with the AUTH API. 
   *
   * UTL_SMTP may support additional authentication schemes in the future and
   * these strings will change accordingly.
   */

  /* The list of all authentication schemes that UTL_SMTP supports, in the
   * order of their relative security strength. This list contains some
   * schemes in which cleartext passwords are sent over SMTP. They should be
   * used only in SMTP connections that are secured by Secure Scoket Layer /
   * Transport Layer Security (SSL/TLS).
   */
  ALL_SCHEMES CONSTANT VARCHAR2(80) := 'CRAM-MD5 PLAIN LOGIN';

  /* The list of authentication schemes that UTL_SMTP supports and in which
   * no cleartext passwords are sent over SMTP. They may be used in SMTP
   * connections that are not secured by SSL/TLS. Note that these schemes
   * may still be weak when used in an insecure SMTP connection.
   */
  NON_CLEARTEXT_PASSWORD_SCHEMES CONSTANT VARCHAR2(80) := 'CRAM-MD5';

  /**
   * Opens a SMTP connection to a SMTP server.  When connection is made
   * succesfully, the SMTP host name and port number will be stored in
   * the connection.
   *
   * Communication with the SMTP server may be secured using Secure Socket
   * Layer / Transport Layer Security (SSL/TLS). To start SSL/TLS in the
   * connection, the user must specify an Oracle wallet when opening the
   * connection. The wallet must contain the trusted certificate of the 
   * certificate authority who signs the remote server's certificate for
   * UTL_SMTP to validate the remote server's certificate.
   *
   * There are two ways SSL/TLS may be started in SMTP. In the first way,
   * SSL/TLS is started before any SMTP communication. To connect to a SMTP
   * server port configured this way (port 465 by convention), set
   * secure_connection_before_smtp to TRUE.
   *
   * In the second way, initial SMTP handshake is done in an insecure
   * connection and SSL/TLS is started by the STARTTLS command. To connect to
   * a SMTP server port configured this way (port 25 or 587 by convention),
   * set secure_connection_before_smtp to FALSE and call the STARTTLS
   * function/procedure. See STARTTLS for details.
   *
   * UTL_SMTP supports client authentication over SSL/TLS using the client
   * certificate in the wallet. The client certificate will be sent to the
   * remote server if it is present in the wallet and if the caller has the
   * "use-client-certificates" ACL privilege on the wallet.
   *
   * For more information on Oracle wallets, see Oracle Wallet Manager
   * documentation.
   *
   * PARAMETERS
   *   host   SMTP host name to connect to
   *   port   port number of the SMTP server to connect to
   *   c      SMTP connection (OUT)
   *   tx_timeout  a time in seconds this package should wait before
   *          giving up in a read or write operation in this
   *          connection. In read operations, this package will give
   *          up if no data is available for reading immediately.
   *          In write operations, this package will give if the
   *          output buffer is full and no data be sent in the
   *          network without being blocked.  0 indicates not to wait
   *          at all.  NULL indicates to wait forever.
   *   wallet_path  the directory path that contains the Oracle wallet for
   *          SSL/TLS. The format is "file:<directory-path>".
   *   wallet_password  the password to open the wallet. When the wallet is
   *          auto-login enabled, the password may be set to NULL.
   *   secure_connection_before_smtp  if TRUE, secure the connection with
   *          SSL/TLS before SMTP communication, else not.
   * RETURN
   *   SMTP connection when connection is established, or
   *   the SMTP reply (welcome) message
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   * NOTES
   *   Time-out on write operations is not supported in the current release
   * of this package.
   */
  FUNCTION open_connection(host            IN  VARCHAR2,
                           port            IN  PLS_INTEGER DEFAULT 25,
                           c               OUT connection,
                           tx_timeout      IN  PLS_INTEGER DEFAULT NULL,
                           wallet_path     IN  VARCHAR2 DEFAULT NULL,
                           wallet_password IN  VARCHAR2 DEFAULT NULL,
                           secure_connection_before_smtp IN BOOLEAN
                                                         DEFAULT FALSE)
                           RETURN reply;
  FUNCTION open_connection(host            IN  VARCHAR2,
                           port            IN  PLS_INTEGER DEFAULT 25,
                           tx_timeout      IN  PLS_INTEGER DEFAULT NULL,
                           wallet_path     IN  VARCHAR2 DEFAULT NULL,
                           wallet_password IN  VARCHAR2 DEFAULT NULL,
                           secure_connection_before_smtp IN BOOLEAN
                                                         DEFAULT FALSE)
                           RETURN connection;

  /**
   * Sends a generic SMTP command and retrieves a single reply line.  If
   * multiple reply lines are returned from the SMTP server, the last reply
   * line is returned.
   *
   * PARAMETERS
   *   c     SMTP connection
   *   cmd   SMTP command
   *   arg   optional argument to the SMTP command
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION command(c    IN OUT NOCOPY connection,
                   cmd  IN            VARCHAR2,
                   arg  IN            VARCHAR2 DEFAULT NULL)
                   RETURN reply;
  PROCEDURE command(c     IN OUT NOCOPY connection,
                    cmd   IN            VARCHAR2,
                    arg   IN            VARCHAR2 DEFAULT NULL);

  /**
   * Sends a generic SMTP command and retrieves multiple reply lines.
   *
   * PARAMETERS
   *   c     SMTP connection
   *   cmd   SMTP command
   *   arg   optional argument to the SMTP command
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   invalid_operation - invalid operation
   */
  FUNCTION command_replies(c     IN OUT NOCOPY connection,
                           cmd   IN            VARCHAR2,
                           arg   IN            VARCHAR2 DEFAULT NULL)
                           RETURN replies;

  /**
   * Sends HELO command.
   *
   * PARAMETERS
   *   c        SMTP connection
   *   domain   domain of the sender
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION helo(c       IN OUT NOCOPY connection,
                domain  IN            VARCHAR2) RETURN reply;
  PROCEDURE helo(c       IN OUT NOCOPY connection,
                 domain  IN            VARCHAR2);

  /**
   * Sends EHLO command.
   *
   * PARAMETERS
   *   c        SMTP connection
   *   domain   domain of the sender
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION ehlo(c       IN OUT NOCOPY connection,
                domain  IN            VARCHAR2) RETURN replies;
  PROCEDURE ehlo(c       IN OUT NOCOPY connection,
                 domain  IN            VARCHAR2);

  /**
   * Sends STARTTLS command to secure the SMTP connection using SSL/TLS.
   * SSL/TLS requires an Oracle wallet which should be specified when the
   * connection was opened by the open_connection function.
   *
   * PARAMETERS
   *   c        SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION starttls(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE starttls(c IN OUT NOCOPY connection);

  /**
   * Sends AUTH command to authenticate to the SMTP server. The UTL_SMTP
   * package will go through the user's choices of authentication schemes, 
   * skip any that is not supported by the SMTP server and use the first one
   * supported. To determine the schemes the SMTP server supports from its
   * EHLO reply, the user must call the EHLO function/procedure first.
   * Otherwise, UTL_SMTP will use the first scheme in the list.
   *
   * PARAMETERS
   *   c           SMTP connection
   *   username    the username
   *   password    the password
   *   schemes     the list of space-separated authentication schemes to use
   *               in the preferred order. See the ALL_SCHEMES and
   *               NON_CLEARTEXT_PASSWORD_SCHEMES constants for suggestions.
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   *   bad_argument      - no supported authentication scheme found
   * NOTES
   *   Currently only PLAIN, LOGIN and CRAM-MD5 authentication schemes are
   * supported by UTL_SMTP.
   *   Since the SMTP server may change the authentication schemes it supports
   * after the SMTP connection is secured by SSL/TLS after the STARTTLS command
   * (for example, adding PLAIN and LOGIN), the caller should call the EHLO
   * function/procedure again for UTL_SMTP to update the list after the
   * STARTTLS function/procedure is called.
   */
  FUNCTION auth(c        IN OUT NOCOPY connection,
                username IN            VARCHAR2,
                password IN            VARCHAR2,
                schemes  IN            VARCHAR2
                                       DEFAULT NON_CLEARTEXT_PASSWORD_SCHEMES)
                RETURN reply;
  PROCEDURE auth(c        IN OUT NOCOPY connection,
                 username IN            VARCHAR2,
                 password IN            VARCHAR2,
                 schemes  IN            VARCHAR2
                                        DEFAULT NON_CLEARTEXT_PASSWORD_SCHEMES);
  /**
   * Sends MAIL command.
   *
   * PARAMETERS
   *   c           SMTP connection
   *   sender      the sender
   *   parameters  the optional parameters to MAIL command
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION mail(c          IN OUT NOCOPY connection,
                sender     IN            VARCHAR2,
                parameters IN            VARCHAR2 DEFAULT NULL) RETURN reply;
  PROCEDURE mail(c          IN OUT NOCOPY connection,
                 sender     IN            VARCHAR2,
                 parameters IN            VARCHAR2 DEFAULT NULL);

  /**
   * Sends RCPT command.
   *
   * PARAMETERS
   *   c           SMTP connection
   *   recipient   the recipient
   *   parameters  the optional parameters to RCPT command
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION rcpt(c          IN OUT NOCOPY connection,
                recipient  IN            VARCHAR2,
                parameters IN            VARCHAR2 DEFAULT NULL) RETURN reply;
  PROCEDURE rcpt(c          IN OUT NOCOPY connection,
                 recipient  IN            VARCHAR2,
                 parameters IN            VARCHAR2 DEFAULT NULL);

  /**
   * Sends DATA command.  The data will be closed by the sequence
   * <CR><LF>.<CR><LF>
   *
   * PARAMETERS
   *   c     SMTP connection
   *   body  the data body
   * RETURN
   *   the SMTP reply after the sequence <CR><LF>.<CR><LF> is sent
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION data(c     IN OUT NOCOPY connection,
                body  IN            VARCHAR2 CHARACTER SET ANY_CS)
                RETURN reply;
  PROCEDURE data(c     IN OUT NOCOPY connection,
                 body  IN            VARCHAR2 CHARACTER SET ANY_CS);

  /**
   * Sends DATA command.  This call opens the data session that the
   * caller make subsequent write_data() calls to write large piece of
   * data, following by close_data() to close the data session.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION open_data(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE open_data(c IN OUT NOCOPY connection);

  /**
   * Sends data.  This call must be preceeded by the call open_data().
   *
   * PARAMETERS
   *   c      SMTP connection
   *   data   the data body
   * RETURN
   *   None
   * EXCEPTIONS
   *   invalid_operation - invalid operation
   */
  PROCEDURE write_data(c     IN OUT NOCOPY connection,
                       data  IN            VARCHAR2 CHARACTER SET ANY_CS);
  PROCEDURE write_raw_data(c     IN OUT NOCOPY connection,
                           data  IN            RAW);

  /**
   * Sends DATA command.  This call opens the data session that the
   * caller make subsequent write_data() calls to write large piece of
   * data, following by close_data() to close the data session.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION close_data(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE close_data(c IN OUT NOCOPY connection);

  /**
   * Sends RSET command.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION rset(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE rset(c IN OUT NOCOPY connection);

  /**
   * Sends VRFY command.
   *
   * PARAMETERS
   *   c           SMTP connection
   *   recipient   the reccipient to verify
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   invalid_operation - invalid operation
   */
  FUNCTION vrfy(c          IN OUT NOCOPY connection,
                recipient  IN            VARCHAR2) RETURN reply;

  /**
   * Sends HELP command.
   *
   * PARAMETERS
   *   c         SMTP connection
   *   command   the command to get help message
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   invalid_operation - invalid operation
   */
  FUNCTION help(c        IN OUT NOCOPY connection,
                command  IN            VARCHAR2 DEFAULT NULL) RETURN replies;

  /**
   * Sends NOOP command.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION noop(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE noop(c IN OUT NOCOPY connection);

  /**
   * Sends QUIT command and closes the SMTP connection.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   the SMTP reply
   * EXCEPTIONS
   *   transient_error   - transient server error
   *   permanent_error   - permanent server error
   *   invalid_operation - invalid operation
   */
  FUNCTION quit(c IN OUT NOCOPY connection) RETURN reply;
  PROCEDURE quit(c IN OUT NOCOPY connection);

  /**
   * Closes the SMTP connection. It will cause the current SMTP operation to
   * be aborted. Use this procedure only to abort an email in the middle of
   * the data session. To end the SMTP connection properly, use the quit() API
   * instead.
   *
   * PARAMETERS
   *   c   SMTP connection
   * RETURN
   *   None
   * EXCEPTIONS
   *   None
   */
  PROCEDURE close_connection(c IN OUT NOCOPY connection);

END;
/

GRANT EXECUTE ON sys.utl_smtp TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_smtp FOR sys.utl_smtp;
