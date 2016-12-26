Rem
Rem $Header: rdbms/admin/catpdbms.sql /st_rdbms_11.2.0/8 2013/06/22 10:12:01 davili Exp $
Rem
Rem catpdbms.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpdbms.sql - CATProc DBMS_ package specifications
Rem
Rem    DESCRIPTION
Rem      This script creates package specifications, and standalone procedures
Rem      and functions
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    davili      06/19/13 - Move the packages to support emll
Rem    vgokhale    02/26/13 - XbranchMerge mtiwary_bug-14121009 from main
Rem    arbalakr    01/31/13 - Backport add cpaddm and rtaddm packages
Rem    elu         12/21/12 - move dbmsrepl after dbmsobj
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    pknaggs     01/31/12 - RADM: add dbmsredacta.sql
Rem    skabraha    01/12/12 - move utlrcmp to catpspec
Rem    sroesch     05/18/11 - add dbmsappcont.sql for application continuity
Rem    msusaira    06/09/09 - Add prvtdnfs
Rem    amullick    06/15/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove dbmsam.sql
Rem    mfallen     04/14/09 - add dbmsadr.sql
Rem    mbastawa    03/17/09 - add prvthcrc.sql
Rem    dalpern     03/17/09 - bug 7646876: applying_crossedit... (drop dbmscet)
Rem    amullick    01/22/09 - Archive provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    yurxu       12/04/08 - Disable IAS
Rem    shiyer      03/26/08 - Remove TSM packages
Rem    lbarton     04/15/08 - bug 6969874: move mdapi compare APIs to their own
Rem                           package
Rem    huagli      11/27/07 - add dbmsdst
Rem    ssvemuri    03/27/08 - Archive Manager catalog tables
Rem    rbhatti     02/02/08 - bug 6782472- moved dbmskzxp.sql
Rem    ilistvin    01/31/08 - add prvsawri.plb, prvsawrs.plb
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT package spec
Rem    amitsha     12/27/07 - add dbmscomp for dbms_compression
Rem    achoi       11/13/07 - add DBMS_PARALLEL_EXECUTE
Rem    achoi       11/13/07 - add DBMS_CROSSEDITION_TRIGGER
Rem    adalee      09/20/07 - add dbmscu.sql
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    skabraha    05/25/07 - add dbmsobj
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    skabraha    05/25/07 - add dbmsobj
Rem    ushaft      04/23/07 - add prvssmgu
Rem    hosu        02/27/07 - add prvssmbi, prvssmb and prvsspmi 
Rem    jsamuel     11/29/06 - added dbmskzxp
Rem    pbelknap    01/12/07 - add prvssqlf
Rem    ushaft      01/03/07 - add dbmsmp
Rem    rburns      01/06/07 - final catproc cleanup
Rem    jkundu      01/09/07 - add prvtlmes.plb
Rem    rdongmin    01/09/07 - add dbmssqlt and dbmsdiag 
Rem    ilistvin    11/16/06 - add dbmsspm.sql
Rem    ilistvin    11/15/06 - move dbmsadv to catpspec.sql
Rem    ilistvin    11/09/06 - 
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/02/06 - add dbmsstr
Rem    elu         10/23/06 - add replication package specs
Rem    achoi       08/27/06 - replace dbmsptch with dbmsedu 
Rem    kkunchit    09/05/06 - dbms_lobutil support
Rem    rburns      08/23/06 - more restructuring
Rem    eshirk      07/14/06 - Add private_jdbc package 
Rem    cdilling    08/03/06 - add dbmsadv.sql,dbmsaddm.sql
Rem    rburns      07/26/06 - add more package specs 
Rem    sourghos    06/07/06 - add WLM package specs 
Rem    mjstewar    05/25/06 - IR integration 
Rem    chliang     05/19/06 - add sscr package spec
Rem    dkapoor     06/19/06 - OCM integration 
Rem    kamsubra    05/19/06 - Adding prvtkpps.plb 
Rem    nkarkhan    05/26/06 - Project 19620: Add support for application
Rem                           initiated Fast-Start Failover.
Rem    kneel       06/05/06 - moving execution of prvthdbu to catpdeps.sql 
Rem    kneel       06/04/06 - moving execution of dbmshae.sql to catpdeps.sql 
Rem    kneel       06/03/06 - moving execution of prvthdbu.sql to catpdbms.sql 
Rem    kneel       06/01/06 - add dbmshae.sql 
Rem    jklein      06/07/06 - add sql_toolkit cat script
Rem    kmuthukk    05/18/06 - Add dbms_hprof package 
Rem    rburns      05/24/06 - add dbms_alert 
Rem    rburns      05/19/06 - add queue files 
Rem    bkuchibh    05/17/06 - add dbmshm.sql 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

Rem PL/SQL packages
@@utlinad
@@utlsmtp
@@utlurl
@@utlenc
@@utlgdk

@@utlcomp
@@utli18n
@@utllms
Rem PL/SQL warning settings
@@dbmsplsw.sql
Rem PL/SQL linear algebra support
@@utlnla

@@dbmstrns
@@dbmsrwid
@@dbmspclx
@@dbmserlg
@@dbmsasrt
@@dbmsspu

 
Rem pl/sql packages used for rdbms functionality
@@dbmsapin
@@dbmssyer
@@dbmspipe
@@dbmsalrt

@@dbmsdesc
@@dbmspexp
@@dbmsjob
@@dbmsstat
@@dbmsstts
@@dbmsddl
@@dbmsedu

@@dbmspp

@@prvthddl.plb
@@prvthjob.plb
@@prvthsye.plb

@@prvtzhlp.plb

Rem Index Rebuild
@@dbmsidxu
@@prvthidx.plb

Rem PL/SQL Server Pages package
@@dbmspsp
@@dbmstran

Rem package for XA PL/SQL APIs
@@dbmsxa.sql

Rem Transformations
@@dbmstxfm.sql

Rem Rules engine
@@dbmsread.sql
@@prvtreut.plb

Rem Probe packages
@@dbmspb.sql

Rem PL/SQL trace packages
@@dbmspbt.sql

Rem Transportabel tablespaces
@@dbmsplts

Rem dbms_pitr package spec
@@dbmspitr

Rem pl/sql package for REFs (UTL_REF)
@@utlrefld.sql

Rem pl/sql package for COLLs (UTL_COLL)
@@utlcoll.plb

Rem pl/sql package for distributed trust administration (trusted list admin)
@@dbmstrst

Rem Row Level Security package 
@@dbmsrlsa

Rem Database Link Encoding
@@dbmslink.sql

Rem Data/Index Repair Package
@@dbmsrpr.sql

Rem Obfuscation (encryption) toolkist
@@dbmsobtk.sql

Rem User authentication for HTML DB
@@dbmshtdb.sql

REM package specs for Redo LogMiner
@@dbmslm.sql
@@dbmslmd.sql
@@prvtlmes.plb

Rem UTL_XML: PL/SQL wrapper around CORE LPX facility: C-based XML/XSL parsing
@@utlcxml.sql

Rem Manageability/Diagnosability Report Framework
@@dbmsrep

Rem Script for Fine Grained Auditing
@@dbmsfga.sql

Rem Script for DBMS_AUDIT_MGMT
@@dbmsamgt.sql

Rem Type Utility 
@@dbmstypu.sql

Rem package for Resumable and ora_space_error_info attribute function
@@dbmsres.sql

Rem package for transaction layer internal functions
@@dbmstxin.sql

Rem SQLJ Object Type support
@@dbmssjty.sql

Rem Data Guard recovery framework support (dbms_drs & dbms_dg)
@@dbmsdrs.sql
@@dbmsdg.sql

Rem Packages for Summary Management and Materialized Views
@@dbmssum
@@dbmshord

Rem iAS packages
Rem @@dbmshias

Rem File Transfer
@@dbmsxfr.sql

Rem File Mapping package
@@dbmsmap.sql

Rem Frequent Itemset package
@@dbmsfi.sql

Rem DBVerify
@@dbmsdbv.sql

Rem Trace Conversion
@@dbmstcv.sql

Rem Collect UDA
@@dbmscoll.sql

REM change data capture packages
@@dbmscdcu.sql
@@dbmscdcp.sql
@@dbmscdcs.sql

Rem profiler package
@@dbmspbp

Rem dbms_hprof package
@@dbmshpro

Rem dbms_service package
@@dbmssrv

Rem Change Notification
@@dbmschnf

Rem
Rem Load explain plan package
Rem
@@dbmsxpln.sql

Rem OWB Match package
@@utlmatch.sql

Rem DBMS_DB_VERSION package
@@dbmsdbvn.sql

Rem dbms_shared_pool
@@dbmspool

Rem Result_Cache
@@dbmsrcad.sql

Rem Client Result Cache
@@prvthcrc.plb

Rem dbms_connection_pool
@@prvtkpps.plb

Rem from catqueue.sql
@@dbmsaq.plb
@@dbmsaqad.sql
@@dbmsaq8x.plb
@@dbmsaqem.plb
@@prvtaqxi.plb

Rem Server-generated alert header files
@@dbmsslrt

Rem dbms_monitor package
@@dbmsmntr

Rem Health Monitor
@@dbmshm.sql
@@catsqltk.sql

Rem Intelligent Repair
@@dbmsir.sql

Rem dbms_session_state package (sscr)
@@prvtsss.plb

Rem OCM 
@@dbmsocm.sql

Rem WLM package
@@dbmswlm

Rem dbms_lobutil package
@@dbmslobu

Rem Manageability Advisor
@@dbmsmp
@@dbmsaddm

Rem dbms_transform internal packages
@@prvttxfs.plb

Rem Load DBMS RESOURCE MANAGER interface packages
@@dbmsrmin.plb
@@dbmsrmad.sql
@@dbmsrmpr.sql
@@dbmsrmpe.plb
@@dbmsrmge.plb
@@dbmsrmpa.plb
@@prvtrmie.plb

Rem dbms_scheduler package
@@prvthjob.plb
@@prvthesh.plb

Rem Stored outline package 
@@dbmsol.sql

-- Metadata API public package header and type defs
@@dbmsmeta.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types
@@dbmsmetb.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types used by Data Pump
@@dbmsmetd.sql

-- Metadata API public package header for compare APIs
@@dbmsmet2.sql

-- DBMS_DATAPUMP public package header and type definitions
@@dbmsdp.sql 

-- KUPP$PROC private package header
@@prvthpp.plb

-- KUPD$DATA invoker's private package header
@@prvthpd.plb

-- KUPD$DATA_INT private package header
@@prvthpdi.plb

-- KUPV$FT_INT private package header
@@prvthpvi.plb

Rem Declaration of TDE_LIBRARY packages
@@prvtdtde.plb

Rem Summary Management
@@prvtsum.plb

Rem PRIVATE_JDBC package
@@prvtjdbs.plb

Rem Create DBMS_SERVER_ALERT_EXPORT package
@@dbmsslxp

Rem create prvt_smgutil package
@@prvssmgu.plb

Rem Create AWR package
@@dbmsawr

Rem common report types
@@prvsrept.plb

Rem prvt_hdm and prvt_rtaddm and prvt_cpaddm
@@prvshdm.plb
@@prvsrtaddm.plb
@@prvs_awr_data_cp.plb
@@prvscpaddm.plb

Rem create prvt_advisor package
@@prvsadv.plb

Rem dbms_swrf_report_internal
@@prvsawr.plb

Rem dbms_swrf_report_internal
@@prvsawri.plb

Rem dbms_awr_report_layout
@@prvsawrs.plb

Rem dbms_ash_internal
@@prvsash.plb

Rem Create dbms_sqltune_utilx package specifications
Rem for sqltune and sqlpi advisors
@@dbmssqlu

Rem Create prvt_sqlxxx_infra package specifications
@@prvssqlf.plb

Rem Create DBMS_WORKLOAD_ package 
@@dbmswrr

Rem Create the DB Feature Usage Report Package
@@dbmsfus

Rem Create the DB Feature Usage Package
@@prvsfus.plb

Rem packages for manageability undo advisor
Rem has dependencies on dbms_output and dbms_sql
@@dbmsuadv.sql

Rem
Rem SQL Plan Management (DBMS_SPM) package spec
@@dbmsspm.sql
@@prvsspmi.plb
@@prvssmb.plb
@@prvssmbi.plb

Rem Streams
@@dbmsstr.sql

Rem DBMS_STATS
@@prvtstas.plb

Rem SQL Tuning Package specification
@@dbmssqlt.sql

Rem Create dbms_sqlpa packages for SQLPA advisor
Rem prvt_sqlpa is created in depssvrm.sql
@@dbmsspa.sql

Rem Create dbms_rat_mask package for RAT masking
@@dbmsratmask.sql

Rem SQL Diag Package specification
-- dependent on sql_binds
@@dbmsdiag.sql

Rem
Rem Replication
Rem
@@dbmsrepl.sql

Rem
Rem Set XS System Paramaters
--@@dbmskzxp.sql

-- misc cache utilities
@@dbmscu.sql

Rem Utilties for Daylight Saving Patching of TIMESTAMP WITH TIMEZONE data
@@dbmsdst.sql

Rem dbms_compression package
@@dbmscomp

Rem DBMS_PARALLEL_EXECUTE package spec
@@dbmspexe.sql
@@prvthpexei.plb

Rem ContentAPI
@@dbmscapi
@@dbmsfuse
@@dbmsfspi

Rem ArchiveProvider
@@dbmspspi

Rem dNFS package
@@dbmsdnfs

Rem ADR package
@@dbmsadr

Rem Data Redaction (Real Time Application-controlled Data Masking, RADM)
@@dbmsredacta.sql

Rem Application continuity
@@dbmsappcont.sql

Rem
Rem DBMS_SCN package for SCNCompatibility project
Rem
@@dbmsscnc.sql




Rem *********************************************************************
Rem END catpdbms.sql
Rem *********************************************************************
