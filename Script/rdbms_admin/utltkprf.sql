rem 
rem $Header: utltkprf.sql,v 1.2 1993/03/22 13:12:51 DRADY Exp $ 
rem 
Rem NAME
REM    UTLTKPRF.SQL
Rem FUNCTION
Rem   Grant public access to all views used by TKPROF with verbose=y option.
Rem NOTES
Rem   This file must be run while logged-in as SYS.
Rem   Catalog.sql must have been run before this file is run.
Rem
Rem
Rem MODIFIED
Rem     drady      03/22/93 -  merge changes from branch 1.1 
Rem     drady      01/21/93 -  Creation 
Rem     drady      01/13/92 -  Creation
Rem
Rem
set echo on;
drop roles  tkprofer;
create role tkprofer;
Rem
Rem Dynamic views that TKPROF needs to dereference wait events.
grant select on v_$datafile   to tkprofer;
grant select on v_$latchname  to tkprofer;
grant select on v_$log        to tkprofer;
grant select on v_$logfile    to tkprofer;
grant select on v_$thread     to tkprofer;
Rem
Rem View extent_to_object is defined in catio.sql
grant select on extent_to_object  to tkprofer;
Rem
Rem  let's grant this role to dba with admin option
grant tkprofer to dba with admin option;
Rem
set echo off;

