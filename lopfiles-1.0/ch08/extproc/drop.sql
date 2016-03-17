REM $Id: drop.sql,v 1.1 2001/11/30 23:26:32 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 8

REM Drop, in reverse dependency order, database objects created by this
REM chapter's build.sql script

PROMPT Dropping function lp...
DROP FUNCTION lp;

PROMPT Dropping library lplib...
DROP LIBRARY lplib;

