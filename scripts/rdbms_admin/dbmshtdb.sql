Rem
Rem $Header: dbmshtdb.sql 08-sep-2005.00:07:20 mxu Exp $
Rem
Rem dbmshtdb.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmshtdb.sql - DBMS HTmlDB system resource package
Rem
Rem    DESCRIPTION
Rem    This package can be used to verify htmldb system state
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mxu         09/08/05 - mxu_xe_htmldb_auth
Rem    lvbcheng    08/26/05 - Add locked account exception 
Rem    mxu         08/25/05 - Add exceptions for account status checking 
Rem    lvbcheng    08/19/05 - Add internal error 
Rem    lvbcheng    08/17/05 - HTMLDB_SYSTEM
Rem    mxu         08/10/05 - Change return type 
Rem    lvbcheng    08/03/05 - Created
Rem

create or replace package sys.htmldb_system authid current_user is

  /*********************************/
  /* return values for verify_user */
  /*********************************/

  valid_user CONSTANT PLS_INTEGER := 0;
  invalid_user CONSTANT PLS_INTEGER := 1;
  null_input CONSTANT PLS_INTEGER := -1;

  /******************************/
  /* exceptions for verify_user */
  /******************************/

  invalid_caller exception; /* this exception is raised if the user
                               is not allowed to call this package
                             */
  internal_error exception; /* this exception is raised only in unusual
                               situations (i.e., out of memory, database
                               down) */
  account_locked exception; /* this exception is raised if the account
                               is locked */
  password_expired exception; /* this exception is raised if the password
                                 has expired */
  /* 
  package_lockout exception; /o this exception is raised after invalid
                                user has been returned too many times
                                in the same session o/
   */

  /***********************/
  /* exception constants */
  /***********************/

  invalid_caller_errcode     CONSTANT PLS_INTEGER:= -32058;
  internal_error_errcode     CONSTANT PLS_INTEGER:= -600;
  account_locked_errcode     CONSTANT PLS_INTEGER:= -28000;
  password_expired_errcode   CONSTANT PLS_INTEGER:= -28001;

  PRAGMA EXCEPTION_INIT(invalid_caller,     -32058);
  PRAGMA EXCEPTION_INIT(internal_error,     -600);
  PRAGMA EXCEPTION_INIT(account_locked,     -28000);
  PRAGMA EXCEPTION_INIT(password_expired,   -28001);

  function verify_user(username IN varchar2 character set any_cs,
                       password IN varchar2 character set any_cs) 
    return PLS_INTEGER;
  /* 
    DESCRIPTION:
    Verify that the username and password pair is valid.

    PARAMETERS:
    username (IN) - username to be validated. Blank padded
                    usernames are not valid. Thus, 'SCOTT  '
                    is not equal to 'SCOTT'.
    password (IN) - password to be validated. Blank padded
                    usernames are not valid. Thus, 'TIGER  '
                    is not equal to 'TIGER'.

    USAGE NOTES:
    This package can only be called by the user HTMLDB_USER.
    Any other caller will be rejected.

    SECURITY:

    TBD
 
  */
end htmldb_system;
/
create or replace public synonym htmldb_system for htmldb_system;
