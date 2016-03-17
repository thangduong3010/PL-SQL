REM $Id: drop.sql,v 1.1 2001/11/30 23:10:54 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 6

REM Drop, in reverse dependency order, database objects created by this 
REM chapter's build.sql script

PROMPT Dropping procedure genfetch...
DROP PROCEDURE genfetch.pro;
