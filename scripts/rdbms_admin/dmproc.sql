Rem 
Rem $Header: dmproc.sql 14-mar-2006.15:35:36 mmcracke Exp $
Rem
Rem dmproc.sql
Rem 
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dmproc.sql - Data Mining Procedures in various packages.
Rem
Rem    DESCRIPTION
Rem      This script installs the Data Mining internal packages for various
Rem      mining algorithms.
Rem
Rem    NOTES
Rem      This script should be run as ODMSYS. The routines provided in these
Rem      packages are also run as ODMSYS, since they are only called by the
Rem      ODM API presently, and not directly by the user.
Rem
Rem       MODIFIED (MM/DD/YY)
Rem       mmcracke 03/10/06 - Moved code to prvtodm.sql
Rem       mmcracke 03/28/05 - Update synonyms from DMSYS to SYS
Rem       pstengar 10/20/04 - remove "grant execute to public" calls 
Rem       xbarr    08/03/04 - remove setting of echo & feedback 
Rem       amozes   07/08/04 - remove old packages 
Rem       fcay     06/30/04 - Use dbmsdm.sql 
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       xbarr    06/22/04   - merge dmproc with prvtdmtf & dmpproc
Rem       cbhagwat 06/17/04   - code reorg 3
Rem       cbhagwat 06/14/04   - code reorg 2
Rem       cbhagwat 06/08/04   - code reorg
Rem       xbarr    06/04/04   - relocate prvjdmh/b due to dependancy on other DM packages 
Rem       mmcracke 05/20/04   - Remove dmsec and prvdmsec
Rem       xbarr    03/16/04   - add prvjdmh/prvjdmb 
Rem       dmukhin  11/25/03   - move dmqg before dmmu
Rem       dmukhin  09/16/03   - remove prvtdmxf
Rem       mmcracke 07/30/03   - Add dmarb92 compile
Rem       dmukhin  07/29/03   - add dmqgh/dmqgb
Rem       fcay     06/23/03   - Update copyright notice
Rem       xbarr    06/16/03   - clean up unused packages 
Rem       dmukhin  05/04/03   - change the order of xform packages
Rem       gtang    04/17/03   - switch sequence to avoid compilation error
Rem       gtang    04/15/03   - 
Rem       gtang    04/10/03   - add packages for model exp/imp
Rem       pstengar 12/30/02   - Added dbmsdm.sql as part of DBMS_DM load
Rem       cbhagwat 12/19/02   - integrating contents of dmpproc here
Rem       pkuntala 12/11/02   - changing odm_nmf_model to dm_nmf_model
Rem       mmcracke 11/15/02   - move dmsec, prvdmsec after dmmuh because of dependencies
Rem       pkuntala 10/01/02   - adding nmf files
Rem       jyarmus  09/17/02   - add package for svm
Rem       xbarr    07/16/02   - comment out unused packages(dmmon, dmerrh, dmerrb)
Rem       mmcracke 06/26/02   - Modify create public synonyms statements.
Rem       mmcracke 06/19/02   - Fix circular definition problem.
Rem       mmcracke 06/14/02   - Take package synonyms from dmsyssch.sql.
Rem       dmukhin  06/13/02   - change the order of packages
Rem       mmcracke 04/30/02   - add DM_SEC and DM_SEC_SYS packages.
Rem       xbarr    03/27/02   - update Copyright 
Rem       xbarr    01/14/02   - use plb instead of sql 
Rem       dmukhin  10/16/01   - add dmnbah, dmnbab
Rem       mmcracke 10/12/01   - add dmkm
Rem       mmcampos 10/11/01   - eliminate dmclb, dmclh
Rem       mmcampos 10/08/01   - add dmcuh dmcub
Rem       bmilenov 10/08/01   - add dmoc package
Rem       dmukhin  09/21/01   - add dmsuperh, dmsuperb
Rem       pstengar 09/20/01   - Added call to dmmon.sql..
Rem       xbarr    09/18/01   - comment out dmnbctb/h due to errors
Rem       xbarr    09/18/01   - change plb to sql in dmproc
Rem       ramkrish 09/12/01   - uncomment dmnbctb/h due to errors
Rem       pkuntala 09/05/01   - Adding AI packages and model util packages.
Rem       xbarr    09/06/01   - add dmerr
Rem       dmukhin  09/05/01   - add mu and mt packages
Rem       ramkrish 09/04/01   - comment out dmnbctb
Rem       ramkrish 08/28/01   - Add external procedures
Rem       ramkrish 08/27/2001 - Creation for new env
Rem
Rem
Rem set feedback off
Rem set echo off

Rem Load ODM Specific packages
Rem --------------------------

Rem Model Util Package, qgen
PROMPT Model Util Package, qgen
@@prvtdmmi.plb

Rem DBMS_DATA_MINING_TRANSFORM (open source)
PROMPT Mining Transform (open source)
@@dbmsdmxf.sql


Rem header
@@dbmsdm.sql
Rem DBMS_DM supplement code
PROMPT Meta Code package (adaptor,sys,sec,exp code,superh/b)
@@prvtdmsu.plb

Rem Adaptive Bayesian Networks
PROMPT Adaptive Bayesian Networks 
@@prvtdmab.plb

Rem Association Rules
PROMPT Association Rules 
@@prvtdmar.plb

Rem Attribute Importance (prvtdmal)

Rem O-Cluster
PROMPT  O-Cluster 
@@prvtdmoc.plb

Rem NB,AI and NMF apply
PROMPT Naive Bayes, attribute importance , NMF Apply
@@prvtdmal.plb

Rem  Trusted Code (KM,SVM,NMF) 
PROMPT KM,SVM,NMF Trusted code
@@prvtdmtf.plb

Rem dbms_data_mining_internal & dbms_data_mining body 
PROMPT DBMS DM Internal, DBMS DM
@@prvtdm.plb

--         PACKAGE SYNONYMS
CREATE OR REPLACE PUBLIC SYNONYM odm_ABN_model FOR sys.odm_ABN_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_attribute_importance_model FOR sys.odm_attribute_importance_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_association_rule_model FOR sys.odm_association_rule_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_clustering_util FOR sys.odm_clustering_util
/
CREATE OR REPLACE PUBLIC SYNONYM odm_model_util FOR sys.odm_model_util
/
CREATE OR REPLACE PUBLIC SYNONYM odm_naive_bayes_model FOR sys.odm_naive_bayes_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_oc_clustering_model FOR sys.odm_oc_clustering_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_util FOR sys.odm_util
/
GRANT EXECUTE ON odm_util TO PUBLIC
/
