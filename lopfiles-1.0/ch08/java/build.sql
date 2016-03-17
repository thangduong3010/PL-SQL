REM $Id: build.sql,v 1.1 2001/11/30 23:25:42 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 8

REM Build, in dependency order, any database objects used in this chapter

ACCEPT system_password PROMPT 'Password of SYSTEM account : ' HIDE
ACCEPT username PROMPT 'Your regular Oracle username: '
ACCEPT password PROMPT 'Your Oracle password: ' HIDE

PROMPT Attempting to load the Java program.  Note that I am skipping the
PROMPT compile step because many people won't have a "javac" available
PROMPT at the command line.  You can just load the java source and have
PROMPT Oracle compile it for you...
HOST loadjava -user &&username/&&password -oci8 -resolve myURL.java

DISCONNECT
PROMPT Connecting as SYSTEM and granting privileges for this user...
CONNECT SYSTEM/&&system_password
@@login
@@grant_java_privs.sql

DISCONNECT
PROMPT Connecting as you and creating PL/SQL procedure that will call Java program...
CONNECT &&username/&&password
@@login
@@myurl_getbytes.sql

