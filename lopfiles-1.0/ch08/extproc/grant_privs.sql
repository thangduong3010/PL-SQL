REM $Id: grant_privs.sql,v 1.1 2001/11/30 23:26:32 bill Exp $
REM From "Learning Oracle PL/SQL" page 300

REM Simple illustration of how to grant CREATE LIBRARY privilege.  Must be
REM run as SYSTEM or other privileged user.

GRANT CREATE LIBRARY TO &&username;

