Rem
Rem $Header: rdbms/admin/catpexec.sql /st_rdbms_11.2.0/2 2013/01/08 11:37:49 jerrede Exp $
Rem
Rem catpexec.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catpexec.sql - CATProc EXECute pl/sql blocks
Rem
Rem    DESCRIPTION
Rem      This script runs after all package and type bodies have been loaded
Rem      and created objects using the packages and types.
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     11/27/12 - Fix lrg 8543643 Dependency Issue with execocm.sql
Rem    jstraub     03/10/11 - add catapex.sql
Rem    rburns      01/06/07 - final catproc cleanup
Rem    ilistvin    11/10/06 - move execsqlt.sql to execsvrm.sql
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/13/06 - add execstr.sql (Streams)
Rem    elu         10/23/06 - add replication files
Rem    arogers     10/23/06 - 5572026 - call execsvr.sql
Rem    rburns      08/23/06 - more restructuring
Rem    rburns      08/13/06 - more restructuring
Rem    jsoule      07/18/06 - add bsln job creation 
Rem    dkapoor     05/23/06 - OCM integration 
Rem    nlewis      06/06/06 - secure configuration changes 
Rem    kneel       06/01/06 - add exechae.sql 
Rem    pbelknap    05/26/06 - add execsqlt 
Rem    rburns      05/19/06 - add queue files 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

Rem Manageability/Diagnosability Report Framework
@@execrept

Rem Component Registry initialization
@@execcr.sql

Rem Heterogeneous Services:  Gateways and external procedures
@@caths.sql

Rem emon based failure detection queues
@@catemini.sql

Rem AQ grants and queue creations
@@execaq.sql

Rem Server Manageablity
@@execsvrm.sql

Rem HA Events (FAN alerts)
@@exechae.sql

Rem Secure configuration settings
@@execsec.sql

Rem BSLN automatic stats maintenance job
@@execbsln.sql

Rem grants for datapump import export
@@catdph.sql

Rem oracle_loader and oracle_datapump for external tables
@@dbmspump.sql

Rem OLAP Services
@@olappl.sql

Rem Replication
@@execrep.sql

--CATCTL -R
--CATCTL -M
Rem Streams
@@execstr.sql

Rem Kernel Service Workgroup Services
@@execsvr.sql

Rem Stats
@@execstat.sql

Rem SNMP catalog objects  
Rem must be after dbmsdrs, catsvrm.sql, catalrt.sql
@@catsnmp.sql

Rem
Rem describe utility (used by mod_plsql)
Rem
@@wpiutil.sql

Rem
Rem embedded plsql gateway/owa packages
Rem
@@owainst.sql

Rem Load OJDM internal package
PROMPT OJDM internal code 
@@prvtdmj.plb

Rem DataPump import/export callout registrations
@@catapex.sql

Rem OCM integration
@@execocm.sql

