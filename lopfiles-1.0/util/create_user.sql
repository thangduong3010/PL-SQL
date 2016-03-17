REM $Id: create_user.sql,v 1.1 2001/11/30 23:41:39 bill Exp $
REM For "Learning Oracle PL/SQL"

REM Create a user to hold the LOP objects.  You don't have to run this script;
REM instead, you can just build the objects in your own schema.

DISCONNECT
ACCEPT system_password CHAR PROMPT 'Enter password of SYSTEM account: ' HIDE
ACCEPT new_username CHAR PROMPT 'Enter user name of new Oracle user: '
ACCEPT new_password CHAR PROMPT 'Enter password for this new Oracle user: ' HIDE
ACCEPT default_tablespace -
   CHAR PROMPT 'Name of default tablespace (default USERS): ' DEFAULT USERS
ACCEPT temporary_tablespace -
   CHAR PROMPT 'Name of temporary tablespace (default TEMP): ' DEFAULT TEMP

CONNECT SYSTEM/&&system_password
@@login

PROMPT Creating user...
CREATE USER &&new_username IDENTIFIED BY &&new_password;

PROMPT Assigning user's default tablespace...
ALTER USER &&new_username
   DEFAULT TABLESPACE &&default_tablespace;

PROMPT Assigning user's temporary tablespace...
ALTER USER &&new_username
   TEMPORARY TABLESPACE &&temporary_tablespace;

PROMPT Granting user unlimited quota on default tablespace...
ALTER USER &&new_username
   QUOTA UNLIMITED ON &&default_tablespace;

PROMPT Granting various developer privileges to user...
GRANT CREATE SESSION,
   CREATE TABLE,
   CREATE TYPE,
   CREATE PROCEDURE,
   CREATE TRIGGER,
   CREATE SEQUENCE,
   CREATE LIBRARY
TO &&new_username;

DISCONNECT

