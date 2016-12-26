Rem
Rem $Header: rdbms/admin/catodci.sql /main/65 2010/02/11 14:14:54 yhu Exp $
Rem
Rem catodci.sql
Rem
Rem Copyright (c) 1997, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catodci.sql - Types and Interfaces for Extensibility
Rem
Rem    DESCRIPTION
Rem      This file contains the defintions of the object types that are used
Rem      as parameter datatypes in extensibility routines.
Rem
Rem    NOTES
Rem      Currently used for extensible indexing/statistics and
Rem      external tables.
Rem      IMPORTANT: Many of these objects are constructed by routines
Rem                 in qxim.c or qxxm.c.  Definitions concerning
Rem                 the number of arguments, and the position of the
Rem                 arguments are in qx.h.  If you modify this file,
Rem                 please be sure to update the dependent definitions
Rem                 for the corresponding object constructors.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yhu         02/03/10 - add UpdateGlobalIndexes in IndexInfoFlags
Rem    spsundar    10/13/06 - remove WITH GRANT OPTION from PUBLIC
Rem    yhu         06/01/06 - system managed domain index statistics 
Rem    yhu         05/02/06 - PMO with system managed domain index 
Rem    spsundar    05/09/06 - add GetMetadata, GetTableName to dbms_odci pkg
Rem    srirkris    02/10/06 - Composite Domain Index- Query 
Rem    spsundar    02/17/06 - add new fields for system managed domain idx
Rem    yhu         12/06/05 - add rename tbale and rename column 
Rem    yhu         02/09/06 - add RenameTopADT for rename ADT column w/ CDI 
Rem    yhu         12/06/05 - add rename table and rename column 
Rem    spsundar    11/16/05 - add new fields/types for composite idx
Rem    yhu         11/21/05 - add ODCI_PMO_ROWIDS$ for update local text index 
Rem    spsundar    08/08/03 - dump ONLINE creation information
Rem    ayoaz       04/21/03 - Add CursorNum to ODCIEnv
Rem    spsundar    04/16/03 - don't dump parallel degree info if degree = 0
Rem    ayoaz       10/08/02 - Add Cardinality to ODCIArgDes
Rem    jstenois    10/16/02 - update comments for ODCIExtTableInfo
Rem    ayoaz       10/03/02 - DBMS_ODCI: add SaveRefCursor, RestoreRefCursor
Rem    ayoaz       09/10/02 - add ODCIQueryInfo to ODCIIndexCtx
Rem    yhu         09/17/02 - add DebugLevel in ODCIEnv
Rem    hsbedi      10/10/02 - Add object number to external table info
Rem    ayoaz       08/26/02 - Add ODCITabFuncInfo and dump function
Rem    rburns      07/03/02 - move ODCI ALTERs to upgrade script
Rem    tchorma     07/23/02 - Support WITH COLUMN CONTEXT clause for operators
Rem    hsbedi      08/12/02 - add metadata table for external tables
Rem    yhu         06/20/02 - add ODCI[.]List for array insert with column data
Rem    yhu         09/19/01 - put some comments on parallel degree.
Rem    tchorma     08/28/01 - Prt Unusbl flg info from ODCIIndexInfoFlagsDump
Rem    yhu         07/16/01 - update ODCIIndexInfo attribute.
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    yhu         03/05/01 - add a procedure for upgrade with secobj$
Rem    abrumm      02/20/01 - modify ODCIExtTableInfo for AccessParm[BC]lob
Rem    ayoaz       01/25/01 - Add ODCITable and ODCIAggregate interfaces.
Rem    spsundar    12/22/00 - fix create library stmt for sqlplus
Rem    nagarwal    01/02/01 - fix ext. optimizer type changes
Rem    nagarwal    12/14/00 - grant odcienvdump to public
Rem    abrumm      01/18/01 - ODCIExtTableInfo: add default directory
Rem    nagarwal    12/01/00 - add stats out argument to ODCIStatsDelete
Rem    nagarwal    11/21/00 - add dbms_odci package 
Rem    abrumm      10/11/00 - change ODCIColInfoList cardinality back to 32
Rem    spsundar    10/19/00 - add new attributes via ALTER TYPE
Rem    tchorma     09/11/00 - Add return code FATAL
Rem    yhu         10/16/00 - add a temp. table for warning support
Rem    spsundar    08/24/00 - update attribute positions 
Rem    abrumm      08/04/00 - ODCIExtTableInfo changes
Rem    tchorma     08/08/00 - Add Update Block Refs Option for Alter Index
Rem    abrumm      06/22/00 - add warning concerning ODCIArgDesc
Rem    ddas        04/28/00 - extensible optimizer enhancements for 8.2
Rem    yhu         06/05/00 - add a temp. table for transportable tablesapce
Rem    nagarwal    04/17/00 - add ODCIEnvDump
Rem    nagarwal    04/11/00 - pass odcienv to ext optimizer interfaces
Rem    abrumm      06/04/00 - external tables: add ODCIEnv param
Rem    abrumm      03/29/00 - external table support
Rem    tchorma     03/09/00 - Update dump routines to reflect iot bit in ODCIIn
Rem    yhu         02/28/00 - support alter table for local domain index
Rem    spsundar    02/14/00 - update definitions for 8.2
Rem    ddas        11/09/98 - enhance ODCIQueryInfoDump to handle QueryBlocking
Rem    rmurthy     11/09/98 - add QueryBlocking
Rem    ddas        10/31/98 - add QuerySortAsc and QuerySortDesc
Rem    rmurthy     06/03/98 - add RegularCall macro
Rem    hdnguyen    05/14/98 - modify to run with sqlplus and svrmgr 
Rem    spsundar    05/08/98 - add constants related to alter options
Rem    rmurthy     04/21/98 - handle case of null in dump routines
Rem    jsriniva    04/14/98 - catodci clean-up
Rem    jsriniva    04/14/98 - Print options in ODCIStatsOptionsDump
Rem    ddas        04/13/98 - add pragma for ODCIConst
Rem    jsriniva    04/12/98 - Dump Table Name in ODCIIndexInfoDump
Rem    alsrivas    04/10/98 - adding constant for index interface version
Rem    rmurthy     04/05/98 - indexinfo - remove table name and schema
Rem    jsriniva    04/04/98 - ODCI Types/Interfaces Clean-up
Rem    nagarwal    03/25/98 - Grant privs on ODCIStatsOptions
Rem    ddas        02/04/98 - add ODCI types for extensible optimizer
Rem    nagarwal    03/09/98 - Change ODCIStatsOptions
Rem    rmurthy     01/27/98 - odciindexctx: add flag
Rem    nagarwal    02/02/98 - Add ODCI types for analyze and optimizer
Rem    rmurthy     12/02/97 - remove odcioperbnds, add icoltype, modify odciope
Rem    rmurthy     10/28/97 - add drop odciindexctx
Rem    rmurthy     10/07/97 - add type ODCIIndexCtx
Rem    rmurthy     09/16/97 - change ridlist to varray type, again!
Rem    rmurthy     08/29/97 - change ridlist to a table type from varray
Rem    rmurthy     08/06/97 - add ODCIRidList as OUT parameter from fetch
Rem    alsrivas    07/22/97 - removing creation of varray of rids from here
Rem    rmurthy     07/03/97 - change ODCIColName to varchar2
Rem                           make rowid and ctx as OUT parameters of
Rem                           of fetch() and start()
Rem    alsrivas    06/25/97 - adding new types
Rem    rmurthy     06/18/97 - grant execute on odcitypes with grant option
Rem    rmurthy     06/06/97 - change varchar->varchar2, also change valarg to
Rem                           varchar2(4000)
Rem    rmurthy     05/19/97 - Add flags parameter for ODCIOperBounds
Rem    rmurthy     04/29/97 - Creates types and interfaces for extensibility
Rem    rmurthy     04/29/97 - Created
Rem
REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS
REM  ***************************************
 
DROP TABLE ODCI_SECOBJ$;
DROP TABLE ODCI_WARNINGS$;

--/************************************************************************/
--/*  ODCI Types: Common to both Extensible Indexing/Optimizer            */
--/************************************************************************/

--
-- Used by ODCIStats{Collect|Delete} 
--
--/*************************************************************/
--/*     TYPE ODCIColInfo:                                     */
--/* TableSchema           -- schema name                      */
--/* TableName             -- table name                       */
--/* ColName               -- column name                      */
--/* ColTypeName           -- column type                      */
--/* ColTypeSchema         -- column type schema               */
--/* TablePartition        -- table partition name             */
--/* Flags                 -- info about the columns           */
--/* OrderByPosition       -- position of col in order by list */
--/* TablePartitionIden    -- base table partition identifier  */
--/* TablePartitionTotal   -- total no. of partitions in table */
--/*************************************************************/

CREATE OR REPLACE TYPE ODCIColInfo AS object 
(
  TableSchema          VARCHAR2(30),
  TableName            VARCHAR2(30),
  ColName              VARCHAR2(4000),
  ColTypeName          VARCHAR2(30),
  ColTypeSchema        VARCHAR2(30),
  TablePartition       VARCHAR2(30),
  ColInfoFlags         NUMBER,
  OrderByPosition      NUMBER,
  TablePartitionIden   NUMBER,
  TablePartitionTotal  NUMBER
);
/

--
-- For migration purposes, ODCIColInfoList varray size cannot change.
-- ODCIColInfoList2 is used for external table support.
--
CREATE OR REPLACE TYPE ODCIColInfoList
  AS VARRAY(32) of ODCIColInfo; 
/

CREATE OR REPLACE TYPE ODCIColInfoList2
  AS VARRAY(1000) of ODCIColInfo; 
/

CREATE OR REPLACE TYPE ODCIColValList 
  AS VARRAY(32) OF SYS.ANYDATA;
/

CREATE OR REPLACE TYPE ODCIColArrayValList
  AS VARRAY(32767) OF ODCIColValList;
/


--
-- Instances of this object type will be passed into operator invocations
-- when WITH COLUMN CONTEXT is specified in the operator's definition.
--
CREATE OR REPLACE TYPE ODCIFuncCallInfo AS Object
(
  ColInfo           ODCIColInfo
);
/

--
-- Used by ODCIIndex{Create|Alter|Truncate|Drop|Start|Insert|Delete|Update}
--         ODCIStats(Collect|Delete|IndexCost}
--
--/*****************************************************************/
--/*     TYPE ODCIIndexInfo:                                       */
--/*    IndexSchema      -- index schema name                      */
--/*    IndexName        -- index name                             */
--/*    IndexCols        -- indexed columns                        */
--/*    IndexPartition   -- index partition name                   */
--/*    IndexInfoFlags   -- index information flags                */
--/*                        (see ODCIConst for bit informatio)     */
--/*    IndexParaDegree  -- index' parallel degree                 */
--/*                        (used in index creation and rebuild)   */
--/*    IndexPartitionIden -- index partition identifier           */
--/*    IndexPartitionTotal -- total no. of partitions in index    */
--/*****************************************************************/

CREATE OR REPLACE TYPE ODCIIndexInfo AS object
(
  IndexSchema         VARCHAR2(30),
  IndexName           VARCHAR2(30),
  IndexCols           ODCIColInfoList,
  IndexPartition      VARCHAR2(30),
  IndexInfoFlags      NUMBER,
  IndexParaDegree     NUMBER,
  IndexPartitionIden  NUMBER,
  IndexPartitionTotal NUMBER
);
/

--
-- Used by ODCIIndex{MergePartition|SplitPartition|UpdPartMetadata}
--
--/*****************************************************************/
--/*     TYPE ODCIPartInfo:                                        */
--/*    TablePartition     -- table partition name                 */
--/*    IndexPartition     -- index partition name                 */
--/*    IndexPartitionIden -- Index partition identifier           */
--/*    PartOp             -- partition operation - add/drop       */
--/*****************************************************************/

CREATE OR REPLACE TYPE ODCIPartInfo AS object
(
  TablePartition      VARCHAR2(30),  
  IndexPartition      VARCHAR2(30),
  IndexPartitionIden  NUMBER,
  PartOp              NUMBER
);
/

CREATE OR REPLACE TYPE ODCIPartInfoList AS VARRAY(64000) OF ODCIPartInfo;
/


--
-- Predicate info containing user-defined operator or function
-- Used by ODCIIndexStart, ODCIStats{Selectivity|IndexCost}
--
--/*****************************************************************/
--/*     TYPE ODCIPredInfo:                                        */
--/*   ObjectSchema       -- Object schema name                    */
--/*   ObjectName         -- Func/Package/Type name                */
--/*   MethodName         -- set only for Pkg/Type                 */
--/*   Flags              -- predicate flags                       */
--/*                      -- (SEE ODCIConst for bit definitions)   */
--/*****************************************************************/

CREATE OR REPLACE TYPE ODCIPredInfo AS object  
(
  ObjectSchema    VARCHAR2(30),
  ObjectName      VARCHAR2(30),
  MethodName      VARCHAR2(30),
  Flags           NUMBER
                              
);
/

--
-- Used by ODCIIndex{Fetch|Insert|Delete|Update}
-- MX_UROWID_S Z= 3800(Max UROWID)*4/3(URWOIDR2Char ovhd)= 5066.67 < 5072
-- Use a large size to simulate unbounded varrays
--
--
CREATE OR REPLACE TYPE ODCIRidList
 AS VARRAY(32767) OF VARCHAR2(5072);
/

CREATE OR REPLACE TYPE ODCINumberList
 AS VARRAY(32767) OF NUMBER;
/

CREATE OR REPLACE TYPE ODCIVarchar2List
 AS VARRAY(32767) OF VARCHAR2(4000);
/

CREATE OR REPLACE TYPE ODCIDateList
 AS VARRAY(32767) OF Date;
/

CREATE OR REPLACE TYPE ODCIBfileList
 AS VARRAY(32767) OF BFILE;
/

CREATE OR REPLACE TYPE ODCIRawList
 AS VARRAY(32767) OF Raw(2000);
/

CREATE OR REPLACE TYPE ODCIObject AS object 
(
  ObjectSchema VARCHAR2(30),
  ObjectName   VARCHAR2(30)
);
/

CREATE OR REPLACE TYPE ODCIObjectList AS VARRAY(32) of ODCIObject; 
/

--
-- Used to pass info about FILTER BY  columns to 
-- ODCIIndexStart, ODCIIndexCost and ODCIIndexSelectivity
--
-- /*******************************************************/
-- /* TYPE ODCIFilterInfo:                                */
-- /* ColInfo     -- information about FILTER BY columns  */
-- /* Flags       -- see ODCIConst.ODCIPredInfo.Flags     */
-- /* Strt        -- start value                          */
-- /* Stop        -- stop value                           */
-- /*******************************************************/

CREATE OR REPLACE TYPE ODCIFilterInfo AS OBJECT
(
  ColInfo     SYS.ODCIColInfo,
  Flags       NUMBER,
  Strt        SYS.ANYDATA,
  Stop        SYS.ANYDATA
);
/

CREATE OR REPLACE TYPE ODCIFilterInfoList 
  AS VARRAY(32000) OF ODCIFilterInfo;
/


--
-- Used to pass info about ORDER BY  columns to 
-- ODCIIndexStart, ODCIIndexCost and ODCIIndexSelectivity
--
-- /*******************************************************/
-- /* TYPE ODCIOrderByInfo:                               */
-- /* ExprType       -- denotes COLUMN or Ancillary Op    */
-- /* ObjectSchema   -- Schema of the ancillary op/table  */
-- /* TableName      -- Table name for column             */ 
-- /* ExprName       -- Column or Anc Op  name            */
-- /* SortOrder      -- ASC or DESC sort                  */
-- /*******************************************************/

CREATE OR REPLACE TYPE ODCIOrderByInfo AS OBJECT
(
  ExprType          NUMBER,
  ObjectSchema      VARCHAR2(30),
  TableName         VARCHAR2(30),
  ExprName          VARCHAR2(30),
  SortOrder         NUMBER
);
/  

CREATE OR REPLACE TYPE ODCIOrderByInfoList
  AS VARRAY(32) OF ODCIOrderByInfo;
/


--
-- Used by ODCIIndexStart, ODCIStatsIndexCost
--
--/*********************************************************/
--/*     TYPE ODCICompQueryInfo:                           */
--/* PredInfo       -- info about FILTER BY columns        */
--/* ObyInfo       -- info about ORDER BY columns/anc op   */
--/*********************************************************/

CREATE OR REPLACE TYPE ODCICompQueryInfo AS OBJECT
(
  PredInfo    ODCIFilterInfoList,
  ObyInfo     ODCIOrderByInfoList
);
/
 

--
-- Used by ODCIIndexStart, ODCIStatsIndexCost
--
--/*********************************************************/
--/*     TYPE ODCIQueryInfo:                               */
--/* Flags              -- (SEE ODCIConst for definitions) */
--/* AncOps             -- Ancillary Operators Referenced  */
--/* CompInfo           -- composite domain idx info       */
--/*********************************************************/

CREATE OR REPLACE TYPE ODCIQueryInfo AS object   
(
  Flags           NUMBER,
  AncOps          ODCIObjectList,
  CompInfo        ODCICompQueryInfo
);
/

--
-- Used by Function with index context
--
--/*********************************************************/
--/*     TYPE ODCIIndexCtx:                                */
--/*   IndexInfo          -- Index Information             */
--/*   Rid                -- Row Identifier                */
--/*   QueryInfo          -- Query Information             */
--/*********************************************************/

CREATE OR REPLACE TYPE ODCIIndexCtx AS object
(
  IndexInfo ODCIIndexInfo,
  Rid VARCHAR2(5072),
  QueryInfo ODCIQueryInfo
);
/

--/************************************************************************/
--/*  ODCI Types used by Exensible Optimizer (in addition to above)       */
--/************************************************************************/

-- Function (standalone or package) or method info
-- Used by ODCIStatsFunctionCost
--
--/****************************************************************/
--/*     TYPE ODCIFuncInfo:                                       */
--/*   ObjectSchema      -- Object schema name                    */
--/*   ObjectName        -- Function/Pkg/Type name                */
--/*   MethodName        -- set only for Pkg/Type                 */
--/*   Flags             -- function bounds flag                  */
--/*                     -- (SEE ODCIConst for definitions)       */
--/****************************************************************/

CREATE OR REPLACE TYPE ODCIFuncInfo AS object
(
  ObjectSchema    VARCHAR2(30),
  ObjectName      VARCHAR2(30),
  MethodName      VARCHAR2(30),
  Flags           NUMBER
);
/



-- Cost structure for user-defined cost functions
-- Used by ODCIStats{FunctionCost|IndexCost}
--
--/**************************************************************/
--/*     TYPE ODCICost:                                         */
--/*   CPUcost              -- CPU cost                         */
--/*   IOcost               -- I/O cost                         */
--/*   NetworkCost          -- network cost                     */
--/*   IndexCostInfo        -- domain index info for plan table */
--/**************************************************************/

CREATE OR REPLACE TYPE ODCICost AS object
(
  CPUcost         NUMBER,
  IOcost          NUMBER,
  NetworkCost     NUMBER,
  IndexCostInfo   VARCHAR2(255)
);
/

-- Argument descriptor for user-defined operators, functions, and methods
--/*************************************************************/
--/*     TYPE ODCIArgDesc:                                     */
--/* ArgType             -- argument type:                     */     
--/*                     -- (SEE ODCIConst for definitions)    */
--/* TableName           -- table name if column or attribute  */
--/* TableSchema         -- schema containing the table        */
--/* ColName             -- column/attribute name (e.g., a.b.c)*/
--/* TablePartitionLower -- lower partition bound for table    */
--/* TablePartitionUpper -- upper partition bound for table    */
--/* Cardinality         -- number of rows for ref cursor args */
--/*************************************************************/

CREATE OR REPLACE TYPE ODCIArgDesc AS object
(
  ArgType              NUMBER,
  TableName            VARCHAR2(30),
  TableSchema          VARCHAR2(30),
  ColName              VARCHAR2(4000),
  TablePartitionLower  VARCHAR2(30),
  TablePartitionUpper  VARCHAR2(30),
  Cardinality          NUMBER
);
/

--
-- Metadata for parameters of user-defined operators, functions, and methods
-- Used byODCIStats{Selectivity|FunctionCost|IndexCost}
--
CREATE OR REPLACE TYPE ODCIArgDescList    
  AS VARRAY(32767) of ODCIArgDesc; 
/


--
-- Used by ODCIStatsCollect
--
--/************************************************************/
--/*     TYPE ODCIStatsOptions:                               */
--/* Sample               -- sample size in analyze           */
--/* Options              -- (SEE ODCIConst for definitions)  */
--/* Flags                -- (SEE ODCIConst for definitions)  */
--/************************************************************/

CREATE OR REPLACE TYPE ODCIStatsOptions AS object 
(
  Sample          NUMBER,
  Options         NUMBER,
  Flags           NUMBER
);
/

--
-- Used by all the ODCIIndex/ODCIStats calls
--
--/************************************************************/
--/*      Type ODCIEnv:                                       */
--/* EnvFlags             -- environment info flags           */
--/*                         (See ODCIConst for definitions)  */ 
--/* CallProperty         -- call property flags              */
--/*                         (See ODCIConst for definitions)  */
--/* DebugLevel           -- used if DebuggingOn is set in    */
--/*                         EnvFlags                         */  
--/* CursorNum            -- cursor number (internal use)     */
--/************************************************************/

CREATE OR REPLACE TYPE ODCIEnv AS object
(
  EnvFlags     NUMBER,
  CallProperty NUMBER,
  DebugLevel   NUMBER,
  CursorNum    NUMBER
);
/


-- Table function stats type

CREATE OR REPLACE TYPE ODCITabFuncStats AS OBJECT
(
  num_rows NUMBER
);
/

--/************************************************************/
--/*      Type ODCIExtTableInfo:                              */
--/* TableSchema -- schema name                               */
--/* TableName   -- table name                                */
--/* RefCols     -- referenced (projected by server) columns  */
--/* AccessParmClob  -- access parameters as CLOB (from DDL)  */
--/* AccessParmBlob  -- access parameters as BLOB (from DDL)  */
--/* Locations   -- locations clause (from DDL)               */
--/* Directories -- directories corresponding to Locations    */
--/* DefaultDirectory --  name of default directory object    */
--/* DriverType  -- Driver Type name (from DDL)               */
--/* OpCode      -- ODCIConst.FetchOp, ODCIConst.PopulateOp   */
--/* AgentNum    -- slave number (0 for QC, Shadow;           */
--/*                  1...N for slave                         */
--/* GranuleSize -- suggested granule size                    */
--/* Flag          -- flag bits (sampling type, AccessParm    */
--/*                  discriminator, etc.).                   */
--/* SamplePercent -- sampling percentage                     */
--/* MaxDoP        -- max degree of parallelism allowed       */
--/* SharedBuf     -- shared buffer (read only by slave)      */
--/* MTableName    -- metadata table name                     */
--/* MTableSchema  -- metadata schema name                    */
--/* TableObjNo    -- object num for table (used for ROWIDs)  */
--/***********************************************************/
CREATE OR REPLACE TYPE ODCIExtTableInfo AS object
(
  TableSchema      VARCHAR2(30), 
  TableName        VARCHAR2(30),
  RefCols          ODCIColInfoList2,
  AccessParmClob   CLOB,
  AccessParmBlob   BLOB,
  Locations        ODCIArgDescList,
  Directories      ODCIArgDescList,
  DefaultDirectory VARCHAR2(30),
  DriverType       VARCHAR2(30),
  OpCode           NUMBER,
  AgentNum         NUMBER,
  GranuleSize      NUMBER,
  Flag             NUMBER,
  SamplePercent    NUMBER,
  MaxDoP           NUMBER,
  SharedBuf        RAW(2000),
  MTableName       VARCHAR2(30),
  MTableSchema     VARCHAR2(30),
  TableObjNo       NUMBER
);
/

--
-- Used by ODCIExtTableQCInfo for returning the granules per
-- input location vector.
--
CREATE OR REPLACE TYPE ODCIGranuleList
  AS VARRAY(65535) of NUMBER;
/

--/************************************************************/
--/*      Type ODCIExtTableQCInfo:                            */
--/* NumGranules  -- actual number of granules.               */
--/* NumLocations -- actual number of locations.              */
--/* GranuleInfo  -- list of size NumLocations where each     */
--/*                 entry gives the number of granules for   */
--/*                 the corresponding location.              */
--/* IntraSourceConcurrency -- boolean: ODCIConst.True,       */
--/*                                    ODCIConst.False       */
--/* MaxDoP                 -- max degree of parallelism that */
--/*                           the agent can support          */
--/* SharedBuf              -- QC agent defined shared buffer */
--/***********************************************************/

CREATE OR REPLACE TYPE ODCIExtTableQCInfo AS object
(
  NumGranules            NUMBER,
  NumLocations           NUMBER,
  GranuleInfo            ODCIGranuleList,
  IntraSourceConcurrency NUMBER,
  MaxDoP                 NUMBER,
  SharedBuf              RAW(2000)
);
/

--/*********************************************/
--/*  ODCITable2 interface types               */
--/*********************************************/

CREATE OR REPLACE TYPE ODCINumberList AS VARRAY(32767) of NUMBER
/

CREATE OR REPLACE TYPE ODCITabFuncInfo AS OBJECT
(
  Attrs      ODCINumberList,  -- referenced attribute positions
  RetType    AnyType          -- table function's return type
)
/

GRANT EXECUTE ON ODCIIndexInfo TO PUBLIC;
GRANT EXECUTE ON ODCIPredInfo TO PUBLIC;
GRANT EXECUTE ON ODCIRidList TO PUBLIC;
GRANT EXECUTE ON ODCINumberList TO PUBLIC;
GRANT EXECUTE ON ODCIVarchar2List TO PUBLIC;
GRANT EXECUTE ON ODCIDateList TO PUBLIC;
GRANT EXECUTE ON ODCIBfileList TO PUBLIC;
GRANT EXECUTE ON ODCIRawList TO PUBLIC;
GRANT EXECUTE ON ODCIIndexCtx TO PUBLIC;
GRANT EXECUTE ON ODCICost TO PUBLIC;
GRANT EXECUTE ON ODCIArgDesc TO PUBLIC;
GRANT EXECUTE ON ODCIArgDescList TO PUBLIC;
GRANT EXECUTE ON ODCIFuncInfo TO PUBLIC;
GRANT EXECUTE ON ODCIStatsOptions TO PUBLIC;
GRANT EXECUTE ON ODCIColInfo TO PUBLIC;
GRANT EXECUTE ON ODCIFuncCallInfo TO PUBLIC;
GRANT EXECUTE ON ODCIColInfoList TO PUBLIC;
GRANT EXECUTE ON ODCIColInfoList2 TO PUBLIC;
GRANT EXECUTE ON ODCIObject TO PUBLIC;
GRANT EXECUTE ON ODCIObjectList TO PUBLIC;
GRANT EXECUTE ON ODCIQueryInfo TO PUBLIC;
GRANT EXECUTE ON ODCIEnv TO PUBLIC;
GRANT EXECUTE ON ODCIPartInfo TO PUBLIC;
GRANT EXECUTE ON ODCIExtTableInfo   TO PUBLIC;
GRANT EXECUTE ON ODCIExtTableQCInfo TO PUBLIC;
GRANT EXECUTE ON ODCIGranuleList    TO PUBLIC;
GRANT EXECUTE ON ODCINumberList TO PUBLIC;
GRANT EXECUTE ON ODCITabFuncInfo TO PUBLIC;
GRANT EXECUTE ON ODCITabFuncStats TO PUBLIC;
GRANT EXECUTE ON ODCIColValList TO PUBLIC;
GRANT EXECUTE ON ODCIColArrayValList TO PUBLIC;
GRANT EXECUTE ON ODCIPartInfoList TO PUBLIC;

GRANT EXECUTE ON ODCIFilterInfo TO PUBLIC;
GRANT EXECUTE ON ODCIFilterInfoList TO PUBLIC;
GRANT EXECUTE ON ODCIOrderByInfo TO PUBLIC;
GRANT EXECUTE ON ODCIOrderByInfoList TO PUBLIC;
GRANT EXECUTE ON ODCICompQueryInfo TO PUBLIC;
--
--/*********************************************/
--/*  Constant Definitions                     */
--/*********************************************/
CREATE OR REPLACE PACKAGE ODCIConst IS

     pragma restrict_references(ODCIConst, WNDS, RNDS, WNPS, RNPS);

  -- Constants for Return Status
     Success          CONSTANT INTEGER  :=  0;
     Error            CONSTANT INTEGER  :=  1;
     Warning          CONSTANT INTEGER  :=  2;
     ErrContinue      CONSTANT INTEGER  :=  3;
     Fatal            CONSTANT INTEGER  :=  4;

  -- Constants for ODCIPredInfo.Flags
     PredExactMatch   CONSTANT INTEGER  :=  1;
     PredPrefixMatch  CONSTANT INTEGER  :=  2;
     PredIncludeStart CONSTANT INTEGER  :=  4;
     PredIncludeStop  CONSTANT INTEGER  :=  8;
     PredObjectFunc   CONSTANT INTEGER  := 16;
     PredObjectPkg    CONSTANT INTEGER  := 32;
     PredObjectType   CONSTANT INTEGER  := 64;
     PredMultiTable   CONSTANT INTEGER  := 128;
     PredNotEqual     CONSTANT INTEGER  := 256;
  
  -- Constants for ODCIQueryInfo.Flags
     QueryFirstRows   CONSTANT INTEGER  :=  1;
     QueryAllRows     CONSTANT INTEGER  :=  2;
     QuerySortAsc     CONSTANT INTEGER  :=  4;
     QuerySortDesc    CONSTANT INTEGER  :=  8;
     QueryBlocking    CONSTANT INTEGER  := 16;

  -- Constants for ScnFlg(Func /w Index Context)
     CleanupCall      CONSTANT INTEGER  :=  1;
     RegularCall      CONSTANT INTEGER  :=  2;

  -- Constants for ODCIFuncInfo.Flags
     ObjectFunc       CONSTANT INTEGER  :=  1;
     ObjectPkg        CONSTANT INTEGER  :=  2;
     ObjectType       CONSTANT INTEGER  :=  4;

  -- Constants for ODCIArgDesc.ArgType
     ArgOther         CONSTANT INTEGER  :=  1;
     ArgCol           CONSTANT INTEGER  :=  2;
     ArgLit           CONSTANT INTEGER  :=  3;
     ArgAttr          CONSTANT INTEGER  :=  4;
     ArgNull          CONSTANT INTEGER  :=  5;
     ArgCursor        CONSTANT INTEGER  :=  6;

  -- Constants for ODCIStatsOptions.Options
     PercentOption    CONSTANT INTEGER  :=  1;
     RowOption        CONSTANT INTEGER  :=  2;

  -- Constants for ODCIStatsOptions.Flags
     EstimateStats    CONSTANT INTEGER  :=  1;
     ComputeStats     CONSTANT INTEGER  :=  2;
     Validate         CONSTANT INTEGER  :=  4;

  -- Constants for ODCIIndexAlter parameter alter_option
     AlterIndexNone           CONSTANT INTEGER  :=  0;
     AlterIndexRename         CONSTANT INTEGER  :=  1;
     AlterIndexRebuild        CONSTANT INTEGER  :=  2;
     AlterIndexRebuildOnline  CONSTANT INTEGER  :=  3;
     AlterIndexModifyCol      CONSTANT INTEGER  :=  4;
     AlterIndexUpdBlockRefs   CONSTANT INTEGER  :=  5;
     AlterIndexRenameCol      CONSTANT INTEGER  :=  6;
     AlterIndexRenameTab      CONSTANT INTEGER  :=  7;
     AlterIndexMigrate        CONSTANT INTEGER  :=  8;

  -- Constants for ODCIIndexInfo.IndexInfoFlags
     Local                    CONSTANT INTEGER  := 1;
     RangePartn               CONSTANT INTEGER  := 2;
     HashPartn                CONSTANT INTEGER  := 4;
     Online                   CONSTANT INTEGER  := 8;
     Parallel                 CONSTANT INTEGER  := 16;
     Unusable                 CONSTANT INTEGER  := 32;
     IndexOnIOT               CONSTANT INTEGER  := 64;
     TransTblspc              CONSTANT INTEGER  := 128;
     FunctionIdx              CONSTANT INTEGER  := 256;
     ListPartn                CONSTANT INTEGER  := 512;
     UpdateGlobalIndexes      CONSTANT INTEGER  := 1024;
 
  -- Constants for ODCIIndexInfo.IndexParaDegree 
     DefaultDegree            CONSTANT INTEGER  := 32767;

  -- Constants for ODCIEnv.Envflags
     DebuggingOn              CONSTANT INTEGER  :=  1;
     NoData                   CONSTANT INTEGER  :=  2;

  -- Constants for ODCIEnv.CallProperty
     None                     CONSTANT INTEGER  := 0;
     FirstCall                CONSTANT INTEGER  := 1;
     IntermediateCall         CONSTANT INTEGER  := 2;
     FinalCall                CONSTANT INTEGER  := 3;
     RebuildIndex             CONSTANT INTEGER  := 4;
     RebuildPMO               CONSTANT INTEGER  := 5;
     StatsGlobal              CONSTANT INTEGER  := 6;
     StatsGlobalAndPartition  CONSTANT INTEGER  := 7;
     StatsPartition           CONSTANT INTEGER  := 8;
  
  -- NOTE: the following ODCIExtTable related definitions should
  --       not be documented (internal use only).
  -- Constants for ODCIExtTableInfo.OpCode
     FetchOp                  CONSTANT INTEGER  := 1;
     PopulateOp               CONSTANT INTEGER  := 2;

  -- Constants for ODCIExtTableInfo.Flag
     Sample                    CONSTANT INTEGER  := 1;
     SampleBlock               CONSTANT INTEGER  := 2;

  -- Constants for ODCIExtTableQCInfo.IntraSourceConcurrency (OUT) argument
     True                     CONSTANT INTEGER  := 1;
     False                    CONSTANT INTEGER  := 0;

  -- Constants (bit definitions) for 'flag' (IN) argument to ODCIExtTableOpen
     QueryCoordinator         CONSTANT INTEGER  :=    1;
     Shadow                   CONSTANT INTEGER  :=    2;
     Slave                    CONSTANT INTEGER  :=    4;

  -- Constants (bit definitons) for ODCIExtTableFetch 'flag' OUT argument
     FetchEOS                 CONSTANT INTEGER  := 1;

  -- Constants (bit definitions) for ODCIColInfo.Flags
     CompFilterByCol          CONSTANT INTEGER  :=    1;
     CompOrderByCol           CONSTANT INTEGER  :=    2;
     CompOrderDscCol          CONSTANT INTEGER  :=    4;
     CompUpdatedCol           CONSTANT INTEGER  :=    8;
     CompRenamedCol           CONSTANT INTEGER  :=    16;
     CompRenamedTopADT        CONSTANT INTEGER  :=    32;    

  -- Constants for ODCIOrderByInfo.ExprType
     ColumnExpr               CONSTANT INTEGER  :=    1;
     AncOpExpr                CONSTANT INTEGER  :=    2;

  -- Constants for ODCIOrderByInfo.SortOrder
     SortAsc                  CONSTANT INTEGER  :=    1;
     SortDesc                 CONSTANT INTEGER  :=    2;
     NullsFirst               CONSTANT INTEGER  :=    4;
     

  -- Constants for ODCIPartInfo.PartOpt
     AddPartition             CONSTANT INTEGER  :=    1;
     DropPartition            CONSTANT INTEGER  :=    2;

END ODCIConst;
/

-- create synonyms and grant privileges
CREATE OR REPLACE PUBLIC SYNONYM ODCIConst FOR SYS.ODCIConst;
GRANT EXECUTE ON ODCIConst TO PUBLIC
/

--/************************************************************************/
--/*   this temporary table ODCI_SECOBJ$ is used for importing            */
--/*   transportable tablespace                                           */
--/* IdxSchema    --   domain index schema                                */
--/* IdxName      --   domain index name                                  */
--/* SecObjSchema --   secondary object schema                            */
--/* SecObjName   --   secondary object name (only for top-level table)   */
--/************************************************************************/
CREATE GLOBAL TEMPORARY TABLE SYS.ODCI_SECOBJ$ (
   IdxSchema     VARCHAR2(30),
   IdxName       VARCHAR2(30),
   SecObjSchema  VARCHAR2(30),
   SecObjName    VARCHAR2(30)
   ) ON COMMIT PRESERVE ROWS  ;
GRANT select, insert ON SYS.ODCI_SECOBJ$ TO PUBLIC;

--/************************************************************************/
--/*   this temporary table ODCI_WARNINGS$ is used for propagating        */
--/*   suitable warnings to the end user                                  */
--/* c1           --   the line number of warning                         */
--/* c2           --   the warning text string                            */
--/************************************************************************/

CREATE GLOBAL TEMPORARY TABLE SYS.ODCI_WARNINGS$ (
   c1            NUMBER,
   c2            VARCHAR2(2000) 
   ) ON COMMIT PRESERVE ROWS  ;
GRANT select, insert ON SYS.ODCI_WARNINGS$ TO PUBLIC;

--/************************************************************************/
--/*   this temporary table ODCI_PMO_ROWIDS$ is used for local text       */
--/*   index maintainence during alter table partition maintainence       */
--/*   operations (PMO)                                                   */
--/************************************************************************/

CREATE GLOBAL TEMPORARY TABLE SYS.ODCI_PMO_ROWIDS$ (
   old_rowid     VARCHAR2(18),
   new_rowid     VARCHAR2(18)
   ) ON COMMIT PRESERVE ROWS  ;
GRANT select ON SYS.ODCI_PMO_ROWIDS$ TO PUBLIC;

--/*********************************************/
--/*  Supplementary routines                   */
--/*********************************************/
CREATE OR REPLACE PROCEDURE ODCIIndexInfoFlagsDump(op NUMBER) IS
BEGIN
  IF (bitand(op, ODCIConst.Local) = ODCIConst.Local) THEN
    
    IF (bitand(op, ODCIConst.RangePartn) = ODCIConst.RangePartn) THEN
      dbms_output.put_line('IndexInfoFlags : Local Range Partitioned');
    END IF;
  
    IF (bitand(op, ODCIConst.HashPartn) = ODCIConst.HashPartn) THEN
      dbms_output.put_line('IndexInfoFlags : Local Hash Partitioned');
    END IF;

    IF (bitand(op, ODCIConst.ListPartn) = ODCIConst.ListPartn) THEN
      dbms_output.put_line('IndexInfoFlags : Local List Partitioned');
    END IF;

    IF (bitand(op, ODCIConst.UpdateGlobalIndexes) = 
         ODCIConst.UpdateGlobalIndexes) THEN
      dbms_output.put_line('IndexInfoFlags : Update Global Indexes');
    END IF;    
  END IF;
  
  IF (bitand(op, ODCIConst.IndexOnIOT) = ODCIConst.IndexOnIOT) THEN
    dbms_output.put_line('IndexInfoFlags : Index on Index-organized Table');
  END IF;

  IF (bitand(op, ODCIConst.Unusable) = ODCIConst.Unusable) THEN
    dbms_output.put_line('IndexInfoFlags : Unusable');
  END IF;

  IF (bitand(op, ODCIConst.FunctionIdx) = ODCIConst.FunctionIdx) THEN
    dbms_output.put_line('IndexInfoFlags : Function based domain index');
  END IF;

  IF (bitand(op, ODCIConst.Online) = ODCIConst.Online) THEN
    dbms_output.put_line('IndexInfoFlags : Online Index Creation');
  END IF;

  IF (bitand(op, ODCIConst.Parallel) = ODCIConst.Parallel) THEN
    dbms_output.put_line('IndexInfoFlags : Parallel Index Creation');
  END IF;

END;
/  

CREATE OR REPLACE PROCEDURE ODCIColInfoFlagsDump(op NUMBER) IS
BEGIN
   IF (bitand(op, ODCIConst.CompFilterByCol) = ODCIConst.CompFilterByCol) THEN
     dbms_output.put_line('ColInfoFlags : Filter By Column');
   END IF;

   IF (bitand(op, ODCIConst.CompOrderByCol) = ODCIConst.CompOrderByCol) THEN
     IF (bitand(op, ODCIConst.CompOrderDscCol) = ODCIConst.CompOrderDscCol)
          THEN
       dbms_output.put_line('ColInfoFlags : Order By Desc Column');
     ELSE
       dbms_output.put_line('ColInfoFlags : Order By Asc Column');  
     END IF;
   END IF;

   IF (bitand(op, ODCIConst.CompUpdatedCol)=ODCIConst.CompUpdatedCol) THEN
     dbms_output.put_line('ColInfoFlags : Updated Column');
   END IF;

   IF (bitand(op, ODCIConst.CompRenamedCol) = ODCIConst.CompRenamedCol) THEN 
     dbms_output.put_line('ColInfoFlags : Renamed Column');
   END IF;

   IF (bitand(op,ODCIConst.CompRenamedTopADT)=ODCIConst.CompRenamedTopADT) THEN
     dbms_output.put_line('ColInfoFlags : Renamed Top ADT');
   END IF;

END;
/


CREATE OR REPLACE PROCEDURE ODCIIndexInfoDump(ia ODCIIndexInfo) IS 
  col NUMBER;
BEGIN
  if ia is null then
   dbms_output.put_line('ODCIIndexInfo is null');
   return;
  end if;

  dbms_output.put_line('ODCIIndexInfo');
  dbms_output.put_line('Index owner : ' || ia.IndexSchema); 
  dbms_output.put_line('Index name : ' || ia.IndexName);
  if (ia.IndexPartition IS NOT NULL) then
    dbms_output.put_line('Index partition name : ' || ia.IndexPartition);
  end if;
  if (ia.IndexInfoFlags != 0) then
    ODCIIndexInfoFlagsDump(ia.IndexInfoFlags);
  end if;

  if (bitand(ia.IndexInfoFlags, ODCIConst.Parallel) = ODCIConst.Parallel) then
    if (ia.IndexParaDegree < ODCIConst.DefaultDegree and 
        ia.IndexParaDegree > 0) then
      dbms_output.put_line('Parallel degree : ' || ia.IndexParaDegree);
    elsif ( ia.IndexParaDegree = ODCIConst.DefaultDegree) then
      dbms_output.put_line('Parallel degree : DEFAULT');
    end if;
  end if;

  -- use first index column's table name as table name for index
  -- (ok since all index columns  belong to same table)
  dbms_output.put_line('Table owner : ' || ia.IndexCols(1).TableSchema);
  dbms_output.put_line('Table name : ' || ia.IndexCols(1).TableName);
  if (ia.IndexCols(1).TablePartition IS NOT NULL) then
    dbms_output.put_line('Table partition name : ' || 
                          ia.IndexCols(1).TablePartition);
  end if;

  FOR col IN ia.IndexCols.FIRST..ia.IndexCols.LAST LOOP
     dbms_output.put_line('Indexed column : '|| 
                          ia.IndexCols(col).ColName);
     dbms_output.put_line('Indexed column type :'||
                          ia.IndexCols(col).ColTypeName);
     dbms_output.put_line('Indexed column type schema:'||
                          ia.IndexCols(col).ColTypeSchema);
     if (ia.IndexCols(col).ColInfoFlags != 0) then
       ODCIColInfoFlagsDump(ia.IndexCols(col).ColInfoFlags);
     end if;
     if (ia.IndexCols(col).OrderByPosition > 0) then
      dbms_output.put_line('Indexed column position in order by: '||
                           ia.IndexCols(col).OrderByPosition);
     end if;
  END LOOP;

  if (ia.IndexPartitionIden != 0) then
    dbms_output.put_line('Index partition identifier : ' || 
                            ia.IndexPartitionIden );
  end if;

  if (ia.IndexPartitionTotal > 1) then
    dbms_output.put_line('Index partition total : ' ||
                           ia.IndexPartitionTotal);
  end if;
END;
/

CREATE OR REPLACE PROCEDURE ODCIPredInfoDump(op ODCIPredInfo) IS   
BEGIN
  if op is null then
   dbms_output.put_line('ODCIPredInfo is null');
   return;
  end if;

  dbms_output.put_line('ODCIPredInfo');
  dbms_output.put_line('Object owner : ' ||op.ObjectSchema);
  dbms_output.put_line('Object name : '  ||op.ObjectName);
  dbms_output.put_line('Method name : '  ||op.MethodName);
  dbms_output.put_line('Predicate bounds flag :');

  IF (bitand(op.Flags, ODCIConst.PredExactMatch) 
      = ODCIConst.PredExactMatch)
  THEN
    dbms_output.put_line('     Exact Match');
  END IF;

  IF (bitand(op.Flags, ODCIConst.PredPrefixMatch) 
      = ODCIConst.PredPrefixMatch)
  THEN
    dbms_output.put_line('     Prefix Match');
  END IF;

  IF (bitand(op.Flags, ODCIConst.PredIncludeStart) 
      = ODCIConst.PredIncludeStart)
  THEN
    dbms_output.put_line('     Include Start Key');
  END IF;

  IF (bitand(op.Flags, ODCIConst.PredIncludeStop) 
      = ODCIConst.PredIncludeStop)
  THEN
    dbms_output.put_line('     Include Stop Key');
  END IF;

  IF (bitand(op.Flags, ODCIConst.PredMultiTable)
      = ODCIConst.PredMultiTable)
  THEN
    dbms_output.put_line('     Multiple Tables');
  END IF;

END;
/


CREATE OR REPLACE PROCEDURE ODCIColInfoDump(ci ODCIColInfo) IS 
  col NUMBER;
BEGIN
  if ci is null then
   dbms_output.put_line('ODCIColInfo is null');
   return;
  end if;

  dbms_output.put_line('ODCIColInfo');
  dbms_output.put_line('Table owner : ' || ci.TableSchema);
  dbms_output.put_line('Table name : ' || ci.TableName);
  if (ci.TablePartition is not null) then
    dbms_output.put_line('Table partition name : ' || ci.TablePartition);
  end if;

  dbms_output.put_line('Column name: '|| ci.ColName);
  dbms_output.put_line('Column type :'|| ci.ColTypeName);
  dbms_output.put_line('Column type schema:'|| ci.ColTypeSchema);

  if (ci.ColInfoFlags != 0) then
       ODCIColInfoFlagsDump(ci.ColInfoFlags);
  end if;

  if (ci.OrderByPosition > 0) then
    dbms_output.put_line('Indexed column position in order by: '||
                           ci.OrderByPosition);
  end if;

  if (ci.TablePartitionTotal > 1) then
    dbms_output.put_line(' Total number of table partitions : ' || 
             ci.TablePartitionTotal);
  end if;
END;
/


CREATE OR REPLACE PROCEDURE ODCIAnyDataDump(ad IN SYS.AnyData)
IS
 BEGIN
  IF ad IS NOT NULL THEN
    CASE ad.gettypeName
      WHEN 'SYS.BINARY_DOUBLE' THEN
        dbms_output.put_line(ad.AccessBDouble());
      WHEN 'SYS.BINARY_FLOAT' THEN
        dbms_output.put_line(ad.AccessBFloat());
      WHEN 'SYS.CHAR' THEN
        dbms_output.put_line(ad.AccessChar());
      WHEN 'SYS.DATE' THEN
        dbms_output.put_line(ad.AccessDate());
      WHEN 'SYS.INTERVALYM' THEN
        dbms_output.put_line(ad.AccessIntervalYM());
      WHEN 'SYS.INTERVALDS' THEN
        dbms_output.put_line(ad.AccessIntervalDS());
      WHEN 'SYS.NCHAR' THEN
        dbms_output.put_line(ad.AccessNChar());
      WHEN 'SYS.NUMBER' THEN
        dbms_output.put_line(ad.AccessNumber());
      WHEN 'SYS.TIMESTAMP' THEN
        dbms_output.put_line(ad.AccessTimeStamp());
      WHEN 'SYS.TIMESTAMPLTZ' THEN
        dbms_output.put_line(ad.AccessTimeStampLTZ());
      WHEN 'SYS.TIMESTAMPTZ' THEN
        dbms_output.put_line(ad.AccessTimeStampTZ());
      WHEN 'SYS.NVARCHAR2' THEN
        dbms_output.put_line(ad.AccessNVarchar2());
      WHEN 'SYS.VARCHAR' THEN
        dbms_output.put_line(ad.AccessVarchar());
      WHEN 'SYS.VARCHAR2' THEN
        dbms_output.put_line(ad.AccessVarchar2());
      WHEN 'SYS.RAW' THEN
        dbms_output.put_line('Raw Datatype');
      ELSE 
        dbms_output.put_line('NOT a Scalar Type in AnyData');
    END CASE;  
  END IF;
 END;
/


CREATE OR REPLACE PROCEDURE ODCIQueryInfoDump(qi ODCIQueryInfo) IS 
BEGIN
  if qi is null then
   dbms_output.put_line('ODCIQueryInfo is null');
   return;
  end if;

  dbms_output.put_line('ODCIQueryInfo');
  dbms_output.put_line('Flags :');

  IF (bitand(qi.Flags, ODCIConst.QueryFirstRows) > 0)
  THEN
    dbms_output.put_line('     First Rows');
  END IF;

  IF (bitand(qi.Flags, ODCIConst.QueryAllRows) > 0) 
  THEN
    dbms_output.put_line('     All Rows');
  END IF;

  IF (bitand(qi.Flags, ODCIConst.QuerySortAsc) > 0)
  THEN
    dbms_output.put_line('     Sort Ascending');
  END IF;

  IF (bitand(qi.Flags, ODCIConst.QuerySortDesc) > 0)
  THEN
    dbms_output.put_line('     Sort Descending');
  END IF;

  IF (bitand(qi.Flags, ODCIConst.QueryBlocking) > 0)
  THEN
    dbms_output.put_line('     Blocking Operations');
  END IF;

  IF qi.AncOps IS NOT NULL AND qi.AncOps.COUNT > 0 THEN
    dbms_output.put_line('Ancillary Operators  ');
    FOR i IN qi.AncOps.FIRST..qi.AncOps.LAST LOOP
       dbms_output.put_line('   Name : '|| 
                            qi.AncOps(i).ObjectName);
       dbms_output.put_line('   Schema :'||
                            qi.AncOps(i).ObjectSchema);
    END LOOP;
  END IF;


  IF qi.CompInfo IS NOT NULL AND qi.CompInfo.PredInfo IS NOT NULL THEN
    dbms_output.put_line('Pushed Down Predicates');
    FOR i IN qi.CompInfo.PredInfo.FIRST..qi.CompInfo.PredInfo.LAST LOOP
       ODCIColInfoDump(qi.CompInfo.PredInfo(i).ColInfo);
       dbms_output.put_line('   Flags: '|| 
                            qi.CompInfo.PredInfo(i).Flags);
       IF qi.CompInfo.PredInfo(i).strt IS NOT NULL THEN
         dbms_output.put_line('   Start: ');
         ODCIAnyDataDump(qi.CompInfo.PredInfo(i).strt);
       END IF;
       IF qi.CompInfo.PredInfo(i).stop IS NOT NULL THEN
         dbms_output.put_line('   Stop: ');
         ODCIAnyDataDump(qi.CompInfo.PredInfo(i).stop);
       END IF;

    END LOOP;
  END IF;

  IF qi.CompInfo IS NOT NULL AND qi.CompInfo.ObyInfo IS NOT NULL THEN
    dbms_output.put_line('Order By Clause');

    FOR i IN qi.CompInfo.ObyInfo.FIRST..qi.CompInfo.ObyInfo.LAST LOOP
       dbms_output.put_line('   ExprType: '|| 
                            qi.CompInfo.ObyInfo(i).ExprType);
       dbms_output.put_line('   Schema : '|| 
                            qi.CompInfo.ObyInfo(i).ObjectSchema);
       dbms_output.put_line('   TableName : '|| 
                            qi.CompInfo.ObyInfo(i).TableName);
       dbms_output.put_line('   ColumnName : '|| 
                            qi.CompInfo.ObyInfo(i).ExprName);
       dbms_output.put_line('   SortOrder : '|| 
                            qi.CompInfo.ObyInfo(i).SortOrder);
    END LOOP;
  END IF;
END;
/


CREATE OR REPLACE PROCEDURE ODCIStatsOptionsDump(so ODCIStatsOptions) IS 
BEGIN
  if so is null then
   dbms_output.put_line('ODCIStatsOptions is null');
   return;
  end if;

  dbms_output.put_line('ODCIStatsOptions');
  IF (so.Flags = ODCIConst.ComputeStats)
  THEN
    dbms_output.put_line('     Compute Stats');
  END IF;
  IF (so.Flags = ODCIConst.EstimateStats)
  THEN
    dbms_output.put_line('     Estimate Stats');
    IF (so.Options = ODCIConst.PercentOption)
    THEN
      dbms_output.put_line('     Sample ' || so.Sample || ' Percent');
    ELSE
          dbms_output.put_line('     Sample ' || so.Sample || ' Rows');
    END IF;
  END IF;
  IF (so.Flags = ODCIConst.Validate)
  THEN
    dbms_output.put_line('     Validate');
  END IF;

END;
/

CREATE OR REPLACE PROCEDURE ODCIEnvDump(env ODCIEnv) IS 
BEGIN
  if  env is null then 
    dbms_output.put_line('ODCIEnv is null ');
    return;
  end if;

  dbms_output.put_line('ODCIEnv');
  IF (bitand( env.EnvFlags, ODCIConst.DebuggingOn) 
      = ODCIConst.DebuggingOn)
  THEN
    dbms_output.put_line('      Debugging is ON');
    dbms_output.put_line('      DebugLevel is ' || env.DebugLevel);
  END IF;

  IF (bitand( env.EnvFlags, ODCIConst.NoData) 
      = ODCIConst.NoData)
  THEN
    dbms_output.put_line('      No Data for Index or Index Partition');
  END IF;

  IF (env.CallProperty = ODCIConst.None)
  THEN 
    dbms_output.put_line('      CallProperty is None ');
  ELSIF (env.CallProperty = ODCIConst.FirstCall)
  THEN 
    dbms_output.put_line('      CallProperty is First Call ');
  ELSIF (env.CallProperty = ODCIConst.IntermediateCall)
  THEN 
     dbms_output.put_line('      CallProperty is Intermediate Call ');
  ELSIF (env.CallProperty = ODCIConst.FinalCall)
  THEN 
    dbms_output.put_line('      CallProperty is Final Call ');
  ELSIF (env.CallProperty = ODCIConst.RebuildIndex) 
  THEN
    dbms_output.put_line('      CallProperty is Rebuild Index ');
  ELSIF (env.CallProperty = ODCIConst.RebuildPMO) 
  THEN
    dbms_output.put_line('      CallProperty is Rebuild PMO ');
  ELSIF (env.CallProperty = ODCIConst.StatsGlobal)
  THEN 
    dbms_output.put_line('      CallProperty is StatsGlobal ');
  ELSIF (env.CallProperty = ODCIConst.StatsGlobalAndPartition)
  THEN 
    dbms_output.put_line('      CallProperty is StatsGlobalAndPartition ');
  ELSIF (env.CallProperty = ODCIConst.StatsPartition)
  THEN 
    dbms_output.put_line('      CallProperty is StatsPartition ');
  END IF;
END;
/

CREATE OR REPLACE PROCEDURE ODCIIndexAlterOptionDump(op NUMBER) IS
BEGIN
    dbms_output.put('Alter Option :');
    IF (op = ODCIConst.AlterIndexNone)
    THEN
       dbms_output.put_line(' None');
    END IF;
    IF (op = ODCIConst.AlterIndexRename)
    THEN
       dbms_output.put_line(' Rename');
    END IF;
    IF (op = ODCIConst.AlterIndexRebuild)
    THEN
       dbms_output.put_line(' Rebuild');
    END IF;
    IF (op = ODCIConst.AlterIndexRebuildOnline)
    THEN
       dbms_output.put_line(' Rebuild Online');
    END IF;
    IF (op = ODCIConst.AlterIndexModifyCol)
    THEN
        dbms_output.put_line(' Modify Column');
    END IF;
    IF (op = ODCIConst.AlterIndexUpdBlockRefs)
    THEN
        dbms_output.put_line(' Update Block References');
    END IF;
    IF (op = ODCIConst.AlterIndexRenameCol)
    THEN
        dbms_output.put_line(' Rename Column ');
    END IF;
    IF (op = ODCIConst.AlterIndexRenameTab)
    THEN
        dbms_output.put_line(' Rename Table ');
    END IF;
    IF (op = ODCIConst.AlterIndexMigrate)
    THEN
        dbms_output.put_line(' Migrate Index ');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ODCIIndexCallPropertyDump(op NUMBER) IS
BEGIN
    IF (op IS NOT NULL AND op != ODCIConst.None ) THEN
      dbms_output.put('Call : ');
      IF (op = ODCIConst.FirstCall) THEN
        dbms_output.put_line('First Call');
      ELSIF (op = ODCIConst.IntermediateCall) THEN
        dbms_output.put_line('Intermediate Call');
      ELSIF (op = ODCIConst.FinalCall) THEN
        dbms_output.put_line('Final Call');
      ELSIF (op = ODCIConst.RebuildIndex) THEN
        dbms_output.put_line('Rebuild Index');
      ELSIF (op = ODCIConst.RebuildPMO) THEN
        dbms_output.put_line('Rebuild PMO');
      ELSIF (op = ODCIConst.StatsGlobal) THEN
        dbms_output.put_line('StatsGlobal');
      ELSIF (op = ODCIConst.StatsGlobalAndPartition) THEN
        dbms_output.put_line('StatsGlobalAndPartition');
      ELSIF (op = ODCIConst.StatsPartition) THEN 
        dbms_output.put_line('StatsPartition');
      END IF;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ODCIPartInfoDump(pinfo IN SYS.ODCIPartInfo) IS
BEGIN
  dbms_output.put_line('ODCIPartInfo :');
  dbms_output.put_line('Table partition name : ' || pinfo.TablePartition);
  dbms_output.put_line('Index partition name : ' || pinfo.IndexPartition);
  dbms_output.put_line('Index partition iden : ' || pinfo.IndexPartitionIden);

  IF (pinfo.PartOp = ODCIConst.AddPartition) THEN
    dbms_output.put_line('Add Partition');
  ELSIF (pinfo.PartOp = ODCIConst.DropPartition) THEN
    dbms_output.put_line('Drop Partition');  
  END IF;
END;
/

CREATE OR REPLACE PROCEDURE ODCIPartInfoListDump(plist IN SYS.ODCIPartInfoList)
IS
 col NUMBER; 
BEGIN
 dbms_output.put_line('ODCIPartInfoList :');
 FOR col IN plist.FIRST..plist.LAST LOOP
  dbms_output.put_line('ODCIPartInfo (' || col || ') :');
  ODCIPartInfoDump(plist(col));
 END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE ODCITabFuncInfoDump(ti IN ODCITabFuncInfo)
IS
  prec PLS_INTEGER;
  scale PLS_INTEGER;
  len PLS_INTEGER;
  csid PLS_INTEGER;
  csfrm PLS_INTEGER;
  cnt PLS_INTEGER;
  tc PLS_INTEGER;
  schema_name VARCHAR2(30);
  type_name VARCHAR2(30);
  version VARCHAR2(30);
BEGIN
  dbms_output.put_line('Dump of ODCITabFuncInfo (ti)');
  IF (ti IS NULL) THEN
    dbms_output.put_line('ti IS NULL');
  ELSE
    IF (ti.Attrs IS NULL) THEN
      dbms_output.put_line('ti.Attrs IS NULL');
    ELSE
      dbms_output.put('ti.Attrs = { ');
      FOR i IN 1..ti.Attrs.count LOOP
        IF (i>1) THEN
          dbms_output.put(' , ');
        END IF;
        dbms_output.put(ti.Attrs(i));
      END LOOP;
      dbms_output.put_line(' } ');
    END IF;

    IF (ti.RetType IS NULL) THEN
      dbms_output.put_line('ti.RetType IS NULL');
    ELSE
      tc:=ti.RetType.GetInfo(prec,scale,len,csid,csfrm,schema_name,
                             type_name,version,cnt);
      dbms_output.put_line('ti.RetType = ' || schema_name ||
                           '.' || type_name);
    END IF;
  END IF;
END;
/

GRANT EXECUTE ON ODCIIndexInfoFlagsDump TO PUBLIC;
GRANT EXECUTE ON ODCIIndexInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIPredInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIQueryInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIColInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIStatsOptionsDump TO PUBLIC;
GRANT EXECUTE ON ODCIIndexAlterOptionDump TO PUBLIC;
GRANT EXECUTE ON ODCIIndexCallPropertyDump TO PUBLIC;
GRANT EXECUTE ON ODCIEnvDump TO PUBLIC;
GRANT EXECUTE ON ODCITabFuncInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIAnyDataDump TO PUBLIC;
GRANT EXECUTE ON ODCIPartInfoDump TO PUBLIC;
GRANT EXECUTE ON ODCIPartInfoListDump TO PUBLIC;

-- following data structure is used to pass information about an object 
CREATE OR REPLACE TYPE ODCISecObj AS OBJECT 
(
  pobjschema    varchar2(30), -- domain index' schema
  pobjname      varchar2(30), -- domain index' name
  objschema     varchar2(30), -- its secondary object's schema 
  objname       varchar2(30)  -- its secondary object's name
);
/

-- List of object records 
CREATE OR REPLACE TYPE ODCISecObjTable IS TABLE OF ODCISecObj;
/

GRANT EXECUTE ON ODCISecObj TO PUBLIC;
GRANT EXECUTE ON ODCISecObjTable TO PUBLIC;

-- /**************************************************/
-- /************** create library ********************/
-- /**************************************************/
create or replace library odci_extopt_lib trusted as static;
/

-- /****************************************************/
-- /*****   D B M S _ O D C I    P A C K A G E   *******/
-- /****************************************************/
CREATE OR REPLACE PACKAGE DBMS_ODCI AS 
-- Overview 
-- This is a generic package that can be used by all the extensibility 
-- projects. This package is owned by SYS and is granted to PUBLIC

-- This function is used to help users estimate the number of CPU cycles 
-- that have been used in a certain time interval.
  FUNCTION estimate_cpu_units(elapsed_time IN NUMBER) 
    RETURN NUMBER;

-- This procedure is used to maintain secobj$ during upgrade  
  PROCEDURE upgrade_secobj(objlist ODCISecObjTable);

  PROCEDURE SaveRefCursor(rc IN SYS_REFCURSOR, curnum OUT NUMBER)
  IS LANGUAGE C
  LIBRARY odci_extopt_lib
  NAME "SaveRefCursor"
  WITH CONTEXT
  PARAMETERS
  (
    CONTEXT,
    rc,
    curnum OCINumber,
    curnum INDICATOR
  );

  PROCEDURE RestoreRefCursor(rc OUT SYS_REFCURSOR, curnum IN NUMBER)
  IS LANGUAGE C
  LIBRARY odci_extopt_lib
  NAME "RestoreRefCursor"
  WITH CONTEXT
  PARAMETERS
  (
    CONTEXT,
    rc,
    curnum OCINumber,
    curnum INDICATOR
  );

  PROCEDURE GetMetadata(ia IN SYS.ODCIIndexInfo, exp_version IN VARCHAR2,
     idx_version IN NUMBER default 1, stmt_string OUT VARCHAR2, 
     new_block OUT NUMBER);

  PROCEDURE GetTableNames(ia IN SYS.ODCIIndexInfo, read_only IN NUMBER,
    exp_version IN VARCHAR2, idx_version IN NUMBER, stmt_string OUT VARCHAR2,
    gtn_context OUT NUMBER, status OUT NUMBER);

  PROCEDURE Cleanup(ia IN SYS.ODCIIndexInfo, gtn_context IN NUMBER);

END DBMS_ODCI;
/
create or replace public synonym dbms_odci for sys.dbms_odci
/
GRANT execute on dbms_odci to public
/

--/*********************************************/
--/*  ODCIIndex Interface  for version 8.1     */
--/*********************************************/
-- CREATE interface ODCIIndex AS
-- (
--   FUNCTION ODCIGetInterfaces(ifclist OUT ODCIObjectList)  
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexCreate(ia ODCIIndexInfo, 
--                                   parms VARCHAR2)
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexAlter(ia ODCIIndexInfo,  
--                                  parms IN OUT VARCHAR2,
--                                  alter_option NUMBER) 
--     RETURN NUMBER, 
--
--   STATIC FUNCTION ODCIIndexTruncate(ia ODCIIndexInfo) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDrop(ia ODCIIndexInfo)     
--     RETURN NUMBER, 
--
--
--   STATIC FUNCTION ODCIIndexStart(sctx IN OUT <impltype>, 
--                                  ia ODCIIndexInfo, 
--                                  op ODCIPredInfo, 
--                                  qi ODCIQueryInfo,       
--                                  strt <op_return_type>, 
--                                  stop <op_return_type>,
--                                  <valargs>)  
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIIndexFetch(nrows NUMBER,           
--                                  rids OUT ODCIRidList)
--     RETURN NUMBER,                     
--
--   MEMBER FUNCTION ODCIIndexClose RETURN NUMBER,          
--
--
--   STATIC FUNCTION ODCIIndexInsert(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   newval <icoltype>) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDelete(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   old <icoltype>) 
--     RETURN NUMBER,     
--
--   STATIC FUNCTION ODCIIndexUpdate(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   old <icoltype>, 
--                                   new <icoltype>) 
--     RETURN NUMBER,
--
-------------------------------------------------------------
--   DML interface for For WITHOUT COLUMN DATA 
-------------------------------------------------------------
--   STATIC FUNCTION ODCIIndexInsert(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList)
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDelete(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList), 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexUpdate(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList), 
--     RETURN NUMBER,
--
-- ); 
--
--/**********************************************************/
--/*  Function with index context                           */
--/*    - index-based functional implementation             */
--/*    - functional implementation for ancillary operators */
--/**********************************************************/
-- FUNCTION funcname(<list of function args>,
--                         ia ODCIIndexCtx,
--                         sctx IN OUT <imp_type>,
--                         scnflg NUMBER) RETURN <ret_type>
--                           -- (SEE ODCIConst for definition) 
--
--
-- CREATE interface ODCIStats AS 
-- ( 
--
--   STATIC FUNCTION ODCIGetInterfaces(ifclist OUT ODCIObjectList)  
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIStatsCollect(col ODCIColInfo, 
--                                    options ODCIStatsOptions, 
--                                    statistics OUT RAW, env ODCIEnv) 
--     return NUMBER, 
--
--   STATIC FUNCTION ODCIStatsCollect(ia ODCIIndexInfo, 
--                                    options ODCIStatsOptions, 
--                                    statistics OUT RAW, env ODCIEnv) 
--     return NUMBER, 
--
--   STATIC FUNCTION ODCIStatsDelete(col ODCIColInfo, 
--                                   statistics OUT RAW, env ODCIEnv)
--     return NUMBER, 
-- 
--   STATIC FUNCTION ODCIStatsDelete(ia ODCIIndexInfo, 
--                                   statistics OUT RAW, env ODCIEnv) 
--     return NUMBER, 
--
--   STATIC FUNCTION ODCIStatsSelectivity(pred ODCIPredInfo, sel OUT NUMBER, 
--                                        args ODCIArgDescList, 
--                                        start <function_return_type>, 
--                                        stop <function_return_type>, 
--                                        <list of function arguments>, 
--                                        env ODCIEnv) 
--     return NUMBER, 
-- 
--   STATIC FUNCTION ODCIStatsFunctionCost(func ODCIFuncInfo, 
--                                         cost OUT ODCICost, 
--                                         args ODCIArgDescList, 
--                                         <list of function arguments>,
--                                         env ODCIEnv) 
--     return NUMBER, 
-- 
--   STATIC FUNCTION ODCIStatsIndexCost(ia ODCIIndexInfo, sel NUMBER, 
--                                      cost OUT ODCICost, qi ODCIQueryInfo, 
--                                      pred ODCIPredInfo, 
--                                      args ODCIArgDescList, 
--                                      start <operator_return_type>, 
--                                      stop  <operator_return_type>, 
--                                      <list of operator value arguments>, 
--                                      env ODCIEnv) 
--     return NUMBER, 
-- );
--

--/*****************************************************************/
--/*  ODCIIndex Interface  for version 8.2                         */
--/*    (if both local range and hash partitioning are supported)  */
--/*****************************************************************/
-- CREATE interface ODCIIndex AS
-- (
--   STATIC FUNCTION ODCIGetInterfaces(ifclist OUT ODCIObjectList)  
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexCreate(ia ODCIIndexInfo, 
--                                   parms VARCHAR2,
--                                   env ODCIEnv)
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexAlter(ia ODCIIndexInfo,  
--                                  parms IN OUT VARCHAR2,
--                                  alter_option NUMBER,
--                                  env ODCIEnv) 
--     RETURN NUMBER, 
--
--   STATIC FUNCTION ODCIIndexTruncate(ia ODCIIndexInfo,
--                                     env ODCIEnv) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDrop(ia ODCIIndexInfo,
--                                 env ODCIEnv)     
--     RETURN NUMBER, 
--
--   STATIC FUNCTION ODCIIndexCoalescePartition(ia ODCIIndexInfo,
--                                            env ODCIEnv)
--
--   STATIC FUNCTION ODCIIndexExchangePartition(ia ODCIIndexInfo,
--                                              ia1 ODCIIndexInfo,
--                                              env ODCIEnv)
--
--   STATIC FUNCTION ODCIIndexMergePartition(ia ODCIIndexInfo,
--                                           part_name1 ODCIPartInfo,
--                                           part_name2 ODCIPartInfo,
--                                           parms VARCHAR2,
--                                           env ODCIEnv) 
--
--   STATIC FUNCTION ODCIIndexSplitPartition(ia ODCIIndexInfo,
--                                           part_name1 ODCIPartInfo,
--                                           part_name2 ODCIPartInfo,
--                                           parms VARCHAR2,
--                                           env ODCIEnv)
--
--           
--   STATIC FUNCTION ODCIIndexStart(sctx IN OUT <impltype>,
--                                  ia ODCIIndexInfo, 
--                                  op ODCIPredInfo, 
--                                  qi ODCIQueryInfo,       
--                                  strt <op_return_type>, 
--                                  stop <op_return_type>,
--                                  <valargs>,
--                                  env ODCIEnv)  
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIIndexFetch(nrows NUMBER,           
--                                  rids OUT ODCIRidList,
--                                  env ODCIEnv)
--     RETURN NUMBER,                     
--
--   MEMBER FUNCTION ODCIIndexClose (env ODCIEnv)
--     RETURN NUMBER,          
--
--
--   STATIC FUNCTION ODCIIndexInsert(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   newval <icoltype>,
--                                   env ODCIEnv) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDelete(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   old <icoltype>,
--                                   env ODCIEnv) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexUpdate(ia ODCIIndexInfo,      
--                                   rid VARCHAR2, 
--                                   old <icoltype>, 
--                                   new <icoltype>,
--                                   env ODCIEnv) 
--     RETURN NUMBER,
--  
----------------------------------------------------------------------
--   Interface to be used for System Managed Local Domain Indexes
----------------------------------------------------------------------
--   STATIC FUNCTION ODCIIndexUpdPartMetadata(ia ODCIIndexInfo, 
--                                            palist ODCIPartInfoList,
--                                            env ODCIEnv)
--
-------------------------------------------------------------
--   DML interface for For WITHOUT COLUMN DATA 
-------------------------------------------------------------
--   STATIC FUNCTION ODCIIndexInsert(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList,
--                                   env ODCIEnv)
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexDelete(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList,
--                                   env ODCIEnv) 
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIIndexUpdate(ia ODCIIndexInfo, 
--                                   ridlist ODCIRidList,
--                                   env ODCIEnv)
--     RETURN NUMBER,
--
-- );
-- ); 

--/*****************************************************************/
--/*  ODCIExtTable Interface                                       */
--/*****************************************************************/
-- CREATE interface ODCIExtTable AS
-- (
--   STATIC FUNCTION ODCIGetInterfaces(ifclist OUT ODCIObjectList)  
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCIExtTableOpen(self  IN OUT <impl-type>,
--                                    xti   IN      ODCIExtTableInfo,
--                                    xri       OUT ODCIExtTableQCInfo,
--                                    pcl       OUT ODCIColInfoList2,
--                                    flag  IN  OUT NUMBER,
--                                    env   IN      ODCIEnv)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     NUMBER,
--                                     cnverr IN OUT NUMBER,
--                                     flag   IN OUT NUMBER,
--                                     env    IN     ODCIEnv)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIExtTablePopulate(flag  IN OUT NUMBER,
--                                        env   IN     ODCIEnv)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIExtTableClose(flag  IN OUT NUMBER,
--                                     env   IN     ODCIEnv)
--     RETURN NUMBER
-- );

--/*****************************************************************/
--/*  ODCITable Interface                                          */
--/*****************************************************************/
--
-- CREATE interface ODCITable AS
-- (
--
--   /* Only need if return type is AnyDataSet */
--   STATIC FUNCTION ODCITableDescribe(typ OUT SYS.AnyType,
--                                     [<input-args>,...])
--     RETURN NUMBER,
--
--   /* Optional: used to set up shared context,         *
--    *           and get additional table function info */
--   STATIC FUNCTION ODCITablePrepare(sctx OUT <imp-type>,
--                                    inf IN ODCITabFuncInfo,
--                                    [<input-args>,...])
--     RETURN NUMBER,
--
--   STATIC FUNCTION ODCITableStart(sctx IN OUT <impl-type>, 
--                                  [<input-args>,...])
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCITableFetch(self IN OUT <impl-type>, 
--                                  nrows IN number, 
--                                  outSet OUT <output-type>) 
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCITableClose(self IN <impl-type>) 
--     RETURN NUMBER
--
-- );

--/*****************************************************************/
--/*  ODCIAggregate Interface                                      */
--/*****************************************************************/
--
-- CREATE interface ODCIAggregate AS
-- (
--   STATIC FUNCTION ODCIAggregateInitialize(sctx IN OUT <impl-type>)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIAggregateIterate(self IN OUT <impl-type>,
--                                        arg IN <input-type>)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIAggregateTerminate(self IN <impl-type>,
--                                          result OUT <output-type>,
--                                          flags IN NUMBER)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIAggregateMerge(self IN OUT <impl-type>,
--                                      sctx2 IN <impl-type>)
--     RETURN NUMBER,
--
--   /* Optional methods */
--
--   MEMBER FUNCTION ODCIAggregateWrapContext(self IN OUT <impl-type>)
--     RETURN NUMBER,
--
--   MEMBER FUNCTION ODCIAggregateDelete(self IN OUT <impl-type>,
--                                       arg IN <input-type>)
--     RETURN NUMBER
--
-- );

