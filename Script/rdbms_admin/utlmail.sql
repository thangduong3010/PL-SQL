REM
REM $Header: plsql/admin/utlmail.sql /main/6 2009/01/06 14:20:27 traney Exp $
REM
REM utlmail.sql
REM
REM Copyright (c) 2002, 2008, Oracle and/or its affiliates.
REM All rights reserved. 
REM
REM    NAME
REM      utlmail.sql - PL/SQL Package for sending email messages (UTL_MAIL)
REM
REM    DESCRIPTION
REM      
REM
REM    NOTES
REM      PL/SQL package to send email messages.
REM    This package by default is not granted to anyone. Users
REM    who want to send email should contact their DBA
REM    to obtain the necessary execute privilege for this package.
REM
REM    MODIFIED   (MM/DD/YY)
REM    traney      12/29/08 - add reply-to
REM    rpang       05/04/06 - Made invoker rights routine
REM    lvbcheng    02/21/05 - 2801081
REM    lvbcheng    12/11/03 - Remove grant of UTL_MAIL to public 
REM    lvbcheng    02/25/03 - define priority levels
REM    eehrsam     10/07/02 - eehrsam_utl_mail_new_pkg
REM    eehrsam     05/01/02 - Created
REM

CREATE OR REPLACE PACKAGE utl_mail AUTHID CURRENT_USER AS

  -------------
  --  CONSTANTS
  --
  invalid_argument EXCEPTION;
  invalid_priority EXCEPTION;
  invalid_argument_errcode CONSTANT PLS_INTEGER:= -29261;
  PRAGMA EXCEPTION_INIT(invalid_argument, -29261);
  PRAGMA EXCEPTION_INIT(INVALID_PRIORITY, -44101);
  /*----------------------------------------------------------------
  **
  ** SEND - send an email message
  **
  ** This procedure packages and delivers an email message to the 
  ** SMTP server specified by the following configuration parameters:
  **
  **   SMTP_SERVER=my_server.my_company.com
  **   SMTP_DOMAIN=my_company.com
  **
  ** SEND PROCEDURE
  ** IN
  **   sender       - sender address
  **   recipients   - address(es) of 1 or more recipients, comma delimited
  **   cc           - CC (carbon copy) recipient(s)), 1 or more addresses,
  **                    comma delimited, default=NULL
  **   bcc          - BCC (blind carbon copy) recipient(s), 1 or more 
  **                    addresses, comma delimited, default=NULL
  **   subject      - subject string, default=NULL
  **   message      - message text, default=NULL
  **   mime_type    - mime type, default='text/plain'
  **   priority     - message priority, default=3, valid values are [1..5]
  **
  ** SEND_ATTACH_VARCHAR2 PROCEDURE
  ** IN
  **   sender       - sender address
  **   recipients   - address(es) of 1 or more recipients, comma delimited
  **   cc           - CC (carbon copy) recipient(s)), 1 or more addresses,
  **                    comma delimited, default=NULL
  **   bcc          - BCC (blind carbon copy) recipient(s), 1 or more 
  **                    addresses, comma delimited, default=NULL
  **   subject      - subject string, default=NULL
  **   message      - message text, default=NULL
  **   mime_type    - mime type, default='text/plain'
  **   priority     - message priority, default=3, valid values are [1..5]
  **   att_txt_inline - boolean specifying whether the attachment is viewable 
  **                    inline with the message body text, default=TRUE
  **   attachment   - attachment text data
  **   att_mime_type- attachment mime_type, default='text/plain'
  **   att_filename - filename to be offered as a default upon saving the
  **                    attachment to disk
  **
  ** SEND_ATTACH_RAW PROCEDURE
  ** IN
  **   sender       - sender address
  **   recipients   - address(es) of 1 or more recipients, comma delimited
  **   cc           - CC (carbon copy) recipient(s)), 1 or more addresses,
  **                    comma delimited, default=NULL
  **   bcc          - BCC (blind carbon copy) recipient(s), 1 or more 
  **                    addresses, comma delimited, default=NULL
  **   subject      - subject string, default=NULL
  **   message      - message text, default=NULL
  **   mime_type    - mime type, default='text/plain'
  **   priority     - message priority, default=3, valid values are [1..5]
  **   att_raw_inline - boolean specifying whether the attachment is viewable 
  **                    inline with the message body text, default=TRUE
  **   attachment   - attachment RAW data
  **   att_mime_type- attachment mime_type, default='application/octet'
  **   att_filename - filename to be offered as a default upon saving the
  **                    attachment to disk
  **
  */

  PROCEDURE send(sender         IN VARCHAR2 CHARACTER SET ANY_CS,
                 recipients     IN VARCHAR2 CHARACTER SET ANY_CS,
                 cc             IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 bcc            IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 subject        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 message        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 mime_type      IN VARCHAR2 CHARACTER SET ANY_CS 
                                   DEFAULT 'text/plain; charset=us-ascii',
                 priority       IN PLS_INTEGER DEFAULT 3,
                 replyto        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL);

  PROCEDURE send_attach_varchar2(
                 sender         IN VARCHAR2 CHARACTER SET ANY_CS,
                 recipients     IN VARCHAR2 CHARACTER SET ANY_CS,
                 cc             IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 bcc            IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 subject        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 message        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 mime_type      IN VARCHAR2 CHARACTER SET ANY_CS 
                                   DEFAULT 'text/plain; charset=us-ascii',
                 priority       IN PLS_INTEGER DEFAULT 3,
                 attachment     IN VARCHAR2 CHARACTER SET ANY_CS,
                 att_inline     IN BOOLEAN  DEFAULT TRUE,
                 att_mime_type  IN VARCHAR2 CHARACTER SET ANY_CS 
                                   DEFAULT 'text/plain; charset=us-ascii',
                 att_filename   IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 replyto        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL);

  PROCEDURE send_attach_raw(
                 sender         IN VARCHAR2 CHARACTER SET ANY_CS,
                 recipients     IN VARCHAR2 CHARACTER SET ANY_CS,
                 cc             IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 bcc            IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 subject        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 message        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 mime_type      IN VARCHAR2 CHARACTER SET ANY_CS 
                                   DEFAULT 'text/plain; charset=us-ascii',
                 priority       IN PLS_INTEGER DEFAULT 3,
                 attachment     IN RAW,
                 att_inline     IN BOOLEAN  DEFAULT TRUE,
                 att_mime_type  IN VARCHAR2 CHARACTER SET ANY_CS 
                                   DEFAULT 'application/octet',
                 att_filename   IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL,
                 replyto        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL);

END;
/

CREATE OR REPLACE PUBLIC SYNONYM utl_mail FOR sys.utl_mail;

