Rem
Rem $Header: rdbms/admin/catpprvt.sql /st_rdbms_11.2.0/7 2013/04/18 23:05:40 vgokhale Exp $
Rem
Rem catpprvt.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catpprvt.sql - CATProc PRVT_ package and type bodies
Rem
Rem    DESCRIPTION
Rem      This script loads the package and type bodies for the objects
Rem      created in catpdbms.sql and catptabs.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vgokhale    03/21/13 - Add prvtscnc
Rem    arbalakr    02/01/13 - Add cpaddm and rtaddm packages
Rem    rrungta     02/07/13 - Backport rrungta_bug-10637191 from
Rem    yujwang     08/08/12 - fix lrg 7156708 by moving prvtwrr.plb to
Rem                           catpdeps.sql
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    pknaggs     01/31/12 - RADM: add prvtredacta.plb
Rem    sroesch     05/18/11 - Add prvtappcont.sql for application continuity
Rem    msusaira    06/09/09 - Add prvtdnfs.plb
Rem    amullick    06/16/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove prvtam.plb
Rem    mfallen     06/15/09 - add prvtadr.plb
Rem    mbastawa    03/13/09 - add prvtcrc.plb
Rem    amullick    01/22/09 - Archive Provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    yurxu       12/04/08 - Disable IAS
Rem    sipatel      09/29/08 - bug 7414934. call catxtbix from catqm
Rem    shiyer      03/26/08 - Remove TSM packages
Rem    sjanardh    07/01/08 - Remove prvtaqiu.lb
Rem    msakayed    04/16/08 - add KUPU$UTILITIES package
Rem    lbarton     04/15/08 - bug 6969874: move mdapi compare APIs to their own
Rem                           package
Rem    huagli      11/27/07 - add prvtdst
Rem    ssvemuri    03/27/08 - Archive manager prvt file
Rem    amitsha     03/17/08 - change prvtcmp to prvtcmpr
Rem    rbhatti     02/01/08 - bug 6782472- moved prvtkzxp.plb
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT package
Rem    amitsha     12/27/07 - add prvtcmp for dbms_compression
Rem    sylin       11/27/07 - add prvtutil.plb from catpdeps.sql
Rem    achoi       11/13/07 - add DBMS_PARALLEL_EXECUTE
Rem    ilistvin    10/24/07 - add prvtawri.plb
Rem    adalee      09/25/07 - add prvtkcl - misc cache util package
Rem    ilistvin    09/14/07 - add prvtawrs.plb
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    ushaft      04/23/07 - add prvtsmgu
Rem    hosu        02/27/07 - add prvtsmb, prvtsmbi and prvtspmi
Rem    jnarasin    11/24/06 - Add prvtkzxp.plb
Rem    pbelknap    01/12/07 - add prvtsqlf
Rem    ushaft      01/04/07 - 
Rem    rburns      01/05/07 - final cleanup
Rem    jkundu      11/30/06 - new pkg prvtlmes and prvtlmeb
Rem    ilistvin    11/09/06 - 
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/03/06 - add catpstr.sql
Rem    elu         10/23/06 - add replication package bodies
Rem    achoi       08/27/06 - replace prvtptch.plb with prvtedu.plb 
Rem    kkunchit    07/28/06 - dbms_lobutil support 
Rem    mziauddi    09/18/06 - move prvtxpln to catpwork (after catsvrm.sql)
Rem    rburns      08/23/06 - more restructuring
Rem    eshirk      07/14/06 - Add private_jdbc package 
Rem    rburns      07/26/06 - add more package bodies 
Rem    jawilson    07/13/06 - 
Rem    samepate    06/18/06 - remove prvtjob.plb
Rem    sourghos    06/07/06 - add WLM package body 
Rem    mjstewar    05/25/06 - IR integration 
Rem    chliang     05/19/06 - add sscr package body
Rem    kamsubra    05/19/06 - Adding prvtkppb.plb 
Rem    schakkap    06/01/06 - fix dependency of dbms_pitr on dbms_plugts 
Rem    nkarkhan    05/26/06 - Project 19620: Add support for application
Rem                           initiated Fast-Start Failover.
Rem    kneel       06/03/06 - moving execution of prvtbdbu.sql to catpprvt.sql 
Rem    kneel       06/01/06 - add prvtkjhn.sql 
Rem    jklein      06/07/06 - 
Rem    kmuthukk    05/18/06 - Add dbms_hprof package 
Rem    rburns      05/24/06 - add dbms_alert 
Rem    rburns      05/19/06 - add queue files 
Rem    rburns      05/18/06 - add more prvt files 
Rem    bkuchibh    05/17/06 - add prvthm.plb 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

Rem PL/SQL packages
@@prvtfile.plb
@@prvtrawb.plb
@@prvttcp.plb
@@prvtinad.plb
@@prvtsmtp.plb
@@prvthttp.plb
@@prvturl.plb
@@prvtenc.plb
@@prvtgdk.plb
@@prvtlob.plb
@@prvtlobu.plb

@@prvtcomp.plb
@@prvti18n.plb
@@prvtlms2.plb
@@prvtnla.plb

@@prvttrns.plb
@@prvtsess.plb
@@prvtrwid.plb
@@prvtpclx.plb
@@prvterlg.plb
@@prvtapin.plb
@@prvtsyer.plb
@@prvtlock.plb
@@prvtpipe.plb
@@prvtalrt.plb
@@prvtdesc.plb
@@prvtpexp.plb
@@prvtzexp.plb
@@prvtstts.plb
@@prvtddl.plb
@@prvtpp.plb
@@prvtscrp.plb
@@prvtkppb.plb

Rem package body for dbms_utility
@@prvtutil.plb 

Rem PL/SQL Server Pages package
@@prvtpsp.plb
@@prvttran.plb

Rem package for XA PL/SQL APIs
@@prvtxa.plb

Rem AnyType creation
@@prvtany.plb

Rem Rules engine
@@prvtread.plb

Rem Probe packages
@@prvtpb.plb

Rem PL/SQL trace packages
@@prvtpbt.plb

Rem dbmsdfrd is replaced by dbmsdefr for the replication option
@@prvtxpsw.plb

Rem pl/sql package for COLLs (UTL_COLL)
@@prvtcoll.plb

Rem pl/sql package for distributed trust administration (trusted list admin)
@@prvttrst.plb

Rem Row Level Security package
@@prvtrlsa.plb

Rem Database Link Encoding
@@prvtlink.plb

Rem Script for Extensibility types
@@prvtodci.plb

Rem Data/Index Repair Package
@@prvtrpr.plb

Rem Obfuscation (encryption) toolkist
@@prvtobtk.plb

Rem User authentication for HTML DB
@@prvthtdb.plb

Rem XMLTYPE bodies
@@prvtxmlt.plb
@@prvturi.plb
@@prvtxml.plb

Rem UTL_XML: PL/SQL wrapper around CORE LPX facility: C-based XML/XSL parsing
@@prvtcxml.plb

Rem Manageability/Diagnosability Report Framework
@@prvtrep.plb
@@prvtrept.plb
@@prvtrepr.plb

REM Script for Fine Grained Auditing
@@prvtfga.plb

REM Script for DBMS_AUDIT_MGMT
@@prvtamgt.plb

Rem Type Utility 
@@prvttypu.plb

Rem Multi-language debug support
@@prvtjdwp.plb
@@prvtjdmp.plb

Rem package for Resumable and ora_space_error_info attribute function
@@prvtres.plb

Rem Component registry package bodies
@@prvtcr.plb

Rem package for transaction layer internal functions
@@prvttxin.plb

Rem SQLJ Object Type support
@@prvtsjty.plb

Rem Data Guard recovery framework support (dbms_drs & dbms_dg)
@@prvtdrs.plb
@@prvtdg.plb

Rem Frequent Itemset package
@@prvtfi.plb

Rem File Mapping package
@@prvtmap.plb

Rem DBVerify
@@prvtdbv.plb

Rem Trace Conversion
@@prvttcv.plb

Rem profiler package
@@prvtpbp.plb

Rem dbms_hprof package
@@prvthpro.plb

Rem trace package
@@prvtbdbu.plb

Rem dbms_service package
@@prvtsrv.plb

Rem DBMS_LDAP package 
@@catldap.sql

Rem shared pool
@@prvtpool.plb

Rem Lightweight user sessions (a.k.a eXtensible Security Sessions)
@@prvtkzxs.plb

Rem Security Class - eXtensible Security
@@prvtkzxc.plb

Rem Client Result Cache
@@prvtcrc.plb

Rem Result_Cache
@@prvtrc.plb

Rem AQ package bodies
@@prvtaq.plb
@@prvtaqdi.plb
@@prvtaqxe.plb
@@prvtaqis.plb
@@prvtaqim.plb
@@prvtaqad.plb
@@prvtaq8x.plb
@@prvtaqin.plb
@@prvtaqal.plb
@@prvtaqjm.plb
@@prvtaqmi.plb
@@prvtaqme.plb
@@prvtaqem.plb 

@@prvtaqip.plb
@@prvtaqds.plb

Rem Health Monitor
@@prvthm.plb

Rem WLM package body
@@prvtwlm.plb
@@prvtsqtk.plb


Rem High Availabilty Events (FAN alerts)
@@prvtkjhn.plb

Rem Intelligent Repair
@@prvtir.plb

Rem dbms_session_state package (sscr)
@@prvtssb.plb

Rem dbms_transform internal packages
@@prvttxfm.plb

-- Load DBMS RESOURCE MANAGER interface packages
@@prvtrmin.plb
@@prvtrmad.plb
@@prvtrmpr.plb
@@prvtrmpe.plb
@@prvtrmge.plb
@@prvtrmpa.plb

/* Load Scheduler packages */
/* dbmssch.sql is needed for the views so it is loaded earlier */
@@prvtjob.plb
@@prvtbsch.plb
@@prvtesch.plb

Rem Stored outline package 
@@prvtol.plb

REM package bodys for Redo LogMiner
REM Make sure these are always called after dbmstrig.sql has been installed
-- dependent on prvtlrm.sql
@@prvtlm.plb
@@prvtlmcb.plb
@@prvtlmrb.plb
@@prvtlms.plb
@@prvtlmeb.plb

-- KUPU$UTILITIES package body
@@prvtbpu.plb
-- KUPU$UTILITIES_INT package body
@@prvtbpui.plb
-- DBMS_METADATA package body: Dependent on dbmsxml.sql
@@prvtmeta.plb
-- DBMS_METADATA_INT package body: Dependent on prvtpbui
@@prvtmeti.plb
-- DBMS_METADATA_UTIL package body: dependent on prvthpdi
@@prvtmetu.plb
-- DBMS_METADATA_BUILD package body
@@prvtmetb.plb
-- DBMS_METADATA_DPBUILD package body
@@prvtmetd.plb
-- DBMS_METADATA_DIFF package body
@@prvtmet2.plb
-- DBMS_DATAPUMP public package body
@@prvtdp.plb
-- KUPC$QUEUE invoker's private package body
@@prvtbpc.plb
-- KUPC$QUEUE_INT definer's private package body
@@prvtbpci.plb
-- KUPW$WORKER private package body
@@prvtbpw.plb
-- KUPM$MCP private package body: Dependent on prvtbpui
@@prvtbpm.plb
-- KUPF$FILE_INT private package body
@@prvtbpfi.plb
-- KUPF$FILE private package body
@@prvtbpf.plb
-- KUPP$PROC private package body
@@prvtbpp.plb
-- KUPD$DATA invoker's private package body
@@prvtbpd.plb
-- KUPD$DATA_INT private package body
@@prvtbpdi.plb
-- KUPV$FT private package body
@@prvtbpv.plb
-- KUPV$FT_INT private package body
@@prvtbpvi.plb

Rem TDE utility
@@prvtdpcr.plb

-- transportable tablespace packages
@@prvtplts.plb

Rem dbms_pitr package body
@@prvtpitr.plb

Rem rules engin imp/exp and upgrade/downgrade packages
@@prvtreie.plb
@@prvtrwee.plb

Rem Index Rebuild Views and Body
@@prvtidxu.plb

Rem UTL_RECOMP body
@@prvtrcmp.plb

Rem Change Notification
@@prvtchnf.plb

Rem dbms_edition
@@prvtedu.plb

Rem OCM Integration
@@prvtocm.sql

Rem Logical Standby package bodies
@@prvtlsby.plb
@@prvtlsib.plb
@@prvtlssb.plb

Rem Summary Advisor
@@prvtsmv.plb
@@prvtsma.plb

Rem iAS packages
Rem @@prvtbias.plb  

Rem File Transfer
Rem dependent on prvtsnap
@@prvtbxfr.plb

Rem Load package body of online redefinition
Rem dependent on snapshot_lib
@@prvtbord.plb

Rem PRIVATE_JDBC package
@@prvtjdbb.plb

Rem Create the DBMS_SERVER_ALERT package
@@prvtslrt.plb

Rem Create DBMS_SERVER_ALERT_EXPORT package
@@prvtslxp.plb

Rem Create dbms_auto_task package
@@prvtatsk.plb

Rem Create dbms_monitor package
@@prvtmntr.plb

Rem Create prvt_smgutil package
@@prvtsmgu.plb

Rem Advisory framework (DBMS_ADVISOR API)
@@prvtdadv.plb

Rem Create prvt_advisor package
@@prvtadv.plb

Rem dbms_swrf_report_internal
@@prvtawr.plb

Rem dbms_swrf_internal
@@prvtawri.plb

Rem dbms_awr_report_layout
@@prvtawrs.plb

Rem dbms_ash_internal
@@prvtash.plb

Rem prvt_sqlxxx_infra
@@prvtsqlf.plb

Rem dbms_sqltune and dbms_sqltune_internal packages
@@prvtsqli.plb
@@prvtsqlt.plb

Rem Create the DB Feature Usage Package
@@prvtfus.plb

Rem dbms_management_packs package body
@@prvtmp.plb

REM hdm pkg
@@prvthdm.plb
@@prvtaddm.plb
@@prvtrtaddm.plb
@@prvt_awr_data_cp.plb
@@prvtcpaddm.plb

Rem package body for the manageability undo advisor
@@prvtuadv.plb

Rem Create dbms_sqltune_util0 and dbms_sqltune_util1 package bodies
Rem for sqltune and sqlpi advisors
@@prvtsqlu.plb

Rem Create prvt_sqlpa and dbms_sqlpa packages for SPA advisor
@@prvtspai.plb
@@prvtspa.plb

Rem Create dbms_rat_mask package for RAT masking
@@prvtratmask.plb

Rem Optimizer Plan Management (DBMS_OPM) package body
@@prvtspmi.plb
@@prvtspm.plb
@@prvtsmbi.plb
@@prvtsmb.plb

Rem create feature usage packages
@@prvtfus.plb

Rem Register the Features and High Water Marks
@@catfusrg

Rem SQL Access Advisor workload package
@@prvtwrk.plb

Rem Access Advisor and TUNE Mview packages
@@prvtsmaa.plb

Rem Replication
@@prvtrepl.sql

Rem Streams PL/SQL packages
@@catpstr.sql

Rem Explain Plan
@@prvtxpln.plb

Rem DBMS_STATS
@@prvtstat.plb
@@prvtstai.plb

Rem Create the private portion of the SQL Diag package
@@prvtsqld.plb

Rem dbms_space
@@prvtspcu.plb

Rem Data Mining
@@prvtodm.plb

Rem Misc Cache Utilities
@@prvtkcl.plb

Rem Utilties for Daylight Saving Patching of TIMESTAMP WITH TIMEZONE data
@@prvtdst.plb

Rem dbms_compression
@@prvtcmpr.plb

Rem DBMS_PARALLEL_EXECUTE package body
@@prvtpexei.plb
@@prvtpexe.plb

Rem ContentAPI
@@prvtcapi.plb
@@prvtfuse.plb
@@prvtfspi.plb

Rem DBMS_DBFS_HS
@@prvtpspi.plb

Rem dnfs package
@@prvtdnfs.plb

Rem ADR package
@@prvtadr.plb

Rem Data Redaction (Real Time Application-controlled Data Masking, RADM)
@@prvtredacta.plb

Rem Application continuity
@@prvtappcont.plb

Rem dbms_log package
@@prvtlog.plb

Rem dbms_scn package
@@prvtscnc.plb

