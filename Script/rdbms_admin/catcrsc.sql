Rem
Rem $Header: rdbms/admin/catcrsc.sql /main/11 2008/09/09 16:25:36 cdilling Exp $
Rem
Rem catcrsc.sql
Rem
Rem Copyright (c) 2003, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      catcrsc.sql - CATalog Component Registry Server Components
Rem
Rem    DESCRIPTION
Rem      This script contains constants used to identify SERVER
Rem      components and the associated upgrade/downgrade/patch/reload 
Rem      scripts.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    08/21/08 - move ultrasearch to rdbms/admin
Rem    cdilling    01/26/07 - set DV option to OLS
Rem    cdilling    12/06/06 - add Data Vault
Rem    rburns      09/16/06 - fixup APEX
Rem    rburns      05/30/06 - add apex 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      07/19/04 - move ODM path 
Rem    rburns      03/17/04 - change catjava files
Rem    rburns      02/23/04 - add EM, EXF 
Rem    rburns      11/06/03 - change AMD path 
Rem    rburns      09/24/03 - add options check 
Rem    rburns      05/21/03 - fix Ultra Search
Rem    rburns      05/06/03 - rburns_bug-2586935
Rem    rburns      03/07/03 - Created
Rem
CREATE OR REPLACE PACKAGE dbms_registry_server IS

nothing_script CONSTANT VARCHAR2(50) := '?/rdbms/admin/nothing.sql';

-- Path names
JAVAVM_path   CONSTANT VARCHAR2(50) := '?/javavm/install/';
CATJAVA_path  CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
XML_path      CONSTANT VARCHAR2(50) := '?/xdk/admin/';
XDB_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
RAC_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
OLS_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
EXF_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
OWM_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
ORDIM_path    CONSTANT VARCHAR2(50) := '?/ord/im/admin/';
SDO_path      CONSTANT VARCHAR2(50) := '?/md/admin/';
CONTEXT_path  CONSTANT VARCHAR2(50) := '?/ctx/admin/';
ODM_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
WK_path       CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
MGW_path      CONSTANT VARCHAR2(50) := '?/mgw/admin/';
AMD_path      CONSTANT VARCHAR2(50) := '?/olap/admin/';
APS_path      CONSTANT VARCHAR2(50) := '?/olap/admin/';
XOQ_path      CONSTANT VARCHAR2(50) := '?/olap/admin/';
EM_path       CONSTANT VARCHAR2(50) := '?/sysman/admin/emdrep/sql/';
RUL_path      CONSTANT VARCHAR2(50) := '?/rdbms/admin/';
APEX_path     CONSTANT VARCHAR2(50) := '?/apex/';
DV_path       CONSTANT VARCHAR2(50) := '?/rdbms/admin/';

-- prefixes
JAVAVM_prefix   CONSTANT VARCHAR2(3) := 'jvm';
CATJAVA_prefix  CONSTANT VARCHAR2(3) := 'jav';
XML_prefix      CONSTANT VARCHAR2(3) := 'xml';
XDB_prefix      CONSTANT VARCHAR2(3) := 'xdb';
RAC_prefix      CONSTANT VARCHAR2(3) := NULL;
OLS_prefix      CONSTANT VARCHAR2(3) := 'ols';
EXF_prefix      CONSTANT VARCHAR2(3) := 'exf';
OWM_prefix      CONSTANT VARCHAR2(3) := 'owm';
ORDIM_prefix    CONSTANT VARCHAR2(3) := 'im';
SDO_prefix      CONSTANT VARCHAR2(3) := 'sdo';
CONTEXT_prefix  CONSTANT VARCHAR2(3) := 'ctx';
ODM_prefix      CONSTANT VARCHAR2(3) := 'odm';
WK_prefix       CONSTANT VARCHAR2(3) := 'wk';
MGW_prefix      CONSTANT VARCHAR2(3) := 'mgw';
AMD_prefix      CONSTANT VARCHAR2(3) := 'amd';
APS_prefix      CONSTANT VARCHAR2(3) := 'aps';
XOQ_prefix      CONSTANT VARCHAR2(3) := 'xoq';
EM_prefix       CONSTANT VARCHAR2(3) := 'em';
RUL_prefix      CONSTANT VARCHAR2(3) := 'rul';
APEX_prefix     CONSTANT VARCHAR2(3) := 'apx';
DV_prefix       CONSTANT VARCHAR2(3) := 'dv';

-- required option names

JAVAVM_option   CONSTANT VARCHAR2(30) := 'Java';
CATJAVA_option  CONSTANT VARCHAR2(30) := NULL;
XML_option      CONSTANT VARCHAR2(30) := NULL;
XDB_option      CONSTANT VARCHAR2(30) := NULL;
RAC_option      CONSTANT VARCHAR2(30) := NULL;
OLS_option      CONSTANT VARCHAR2(30) := 'Oracle Label Security';
EXF_option      CONSTANT VARCHAR2(30) := NULL;
OWM_option      CONSTANT VARCHAR2(30) := NULL;
ORDIM_option    CONSTANT VARCHAR2(30) := NULL;
SDO_option      CONSTANT VARCHAR2(30) := 'Spatial';
CONTEXT_option  CONSTANT VARCHAR2(30) := NULL;
ODM_option      CONSTANT VARCHAR2(30) := 'Data Mining';
WK_option       CONSTANT VARCHAR2(30) := NULL;
MGW_option      CONSTANT VARCHAR2(30) := NULL;
AMD_option      CONSTANT VARCHAR2(30) := 'OLAP';
APS_option      CONSTANT VARCHAR2(30) := 'OLAP';
XOQ_option      CONSTANT VARCHAR2(30) := 'OLAP';
EM_option       CONSTANT VARCHAR2(30) := NULL;
RUL_option      CONSTANT VARCHAR2(30) := NULL;
APEX_option     CONSTANT VARCHAR2(30) := NULL;
DV_option       CONSTANT VARCHAR2(30) := 'Oracle Label Security';

TYPE component_table IS TABLE OF VARCHAR2(30);
component component_table;

END dbms_registry_server;
/
