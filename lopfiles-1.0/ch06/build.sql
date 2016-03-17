REM $Id: build.sql,v 1.1 2001/11/30 23:10:53 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 6

REM Build, in dependency order, any database objects used in this chapter

PROMPT Creating genfetch procedure...
@@genfetch.pro

