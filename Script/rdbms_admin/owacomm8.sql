Rem  Copyright (c) 1995, 2004, Oracle.  All Rights Reserved.
Rem
Rem   NAME
Rem     owacomm8.sql - PL/SQL Gateway package installation
Rem   PURPOSE
Rem     Install the PL/SQL packages needed to run the PL/SQL
Rem     gateway for 8.0.x databases.
Rem   NOTES
Rem     This script installs the PL/SQL gateway toolkit 
Rem     packages (such as HTP/HTP/OWA_UTIL, WPG_DOCLOAD etc.)
Rem     it should be called BY a driver script such AS owaload.sql
Rem   IMPORTANT
Rem     Please keep this file as generic as possible. This file must be 
Rem     able to run in both SQLPLUS and SVRMGRL
Rem   history
Rem     dnonkin    08/31/04 -  removed call to owadins.sql
Rem     skwong     08/24/01 -  Replace Oracle8 versions of *ht.sql and *util.sql
Rem     pkapasi    06/17/01 -  Add support for EBCDIC databases(bug#1778693)
Rem     ehlee      03/14/01 -  split off FROM owacomm.sql
Rem


@@owachars.sql
@@pubcust.sql
@@pubht8.sql
@@pubutil8.sql
@@pubsec.sql
@@pubowa.sql
@@pubtext.sql
@@pubpat.sql
@@pubimg.sql
@@pubcook.sql
@@puboolk.sql
@@pubcach8.sql
@@pubmat.sql
@@wpgdocs8.sql

@@privcust.sql
@@privht8.sql
@@privowa.sql
@@privutil8.sql
@@privtext.sql
@@privpat.sql
@@privimg.sql
@@privcook.sql
@@privoolk.sql
@@privsec.sql
@@privcac8.sql
@@privmat.sql
@@wpgdocb8.sql

grant all on OWA_CUSTOM to public;
grant all on OWA to public;
grant all on HTF to public;
grant all on HTP to public;
grant all on OWA_COOKIE to public;
grant all on OWA_IMAGE to public;
grant all on OWA_OPT_LOCK to public;
grant all on OWA_PATTERN to public;
grant all on OWA_SEC to public;
grant all on OWA_TEXT to public;
grant all on OWA_UTIL to public;
grant all on OWA_CACHE to public;
grant all on OWA_MATCH to public;
grant execute on WPG_DOCLOAD to public;

REM CREATE PUBLIC owa synonyms
@@owacsyn    


