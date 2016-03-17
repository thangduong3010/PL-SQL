REM $Id: drop.sql,v 1.1 2001/11/30 23:25:42 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 8

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping PL/SQL procedure myurl_getbytes...
DROP PROCEDURE myurl_getbytes;

PROMPT Dropping Java program (class) myURL...
REM DROP JAVA CLASS "myURL";

PROMPT Dropping corresponding Java source from database...
DROP JAVA SOURCE "myURL";

PROMPT Dropping some utility programs and tables that Java leaves lying
PROMPT around...
DROP PACKAGE loadlobs;
DROP TABLE CREATE$JAVA$LOB$TABLE;
DROP TABLE JAVA$CLASS$MD5$TABLE;
REM DROP TABLE JAVA$OPTIONS;

