Rem
Rem pbunload.sql
Rem
Rem  Copyright (c) Oracle Corporation 1997. All Rights Reserved.
Rem
Rem    NAME
Rem      pbunload.sql - Probe unloader (deinstaller)
Rem
Rem    DESCRIPTION
Rem      Deinstalls the Probe server-side packages.  Server-side debugging
Rem      will no longer be possible on this server.
Rem
Rem    NOTES
Rem      * Must be executed as SYS.
Rem      * Do not deinstall Probe while a debugging session is active.
Rem        (Doing so may hang the debugging session.)
Rem      * To reinstall Probe, use pbload.sql
Rem

-- Drop the packages
drop package PBREAK;
drop package PBSDE;
drop package PBRPH;
drop package PBUTL;
drop package DBMS_DEBUG;

-- Drop the synonyms
drop public synonym DBMS_DEBUG;
drop public synonym PBSDE;
drop public synonym PBRPH;
