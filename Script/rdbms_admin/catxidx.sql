Rem
Rem $Header: rdbms/admin/catxidx.sql /st_rdbms_11.2.0/1 2011/02/01 11:15:30 attran Exp $
Rem
Rem catxidx.sql
Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxidx.sql - XMLIndex related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the views, packages, index types, operators and 
Rem     indexes required for supporting the XMLIndex
Rem
Rem    NOTES
Rem      This script should be run as "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    attran      01/31/11 - 11697039 & 11699333
Rem    thbaby      05/11/10 - remove PREDICATE xmlindex related attrs from
Rem                           XMLIndexLoad_t
Rem    bhammers    04/22/10 - support buffer > 32k at export time
Rem    thbaby      03/01/10 - add grppos column to xdb.xdb$xidx_imp_t
Rem    attran      31/01/10 - global temp imp_t
Rem    spetride    05/04/09 - add ODCIIndexUtil{GetTableNames|Cleanup}
Rem    bhammers    10/23/08 - call qmix_xmetadata only if in datapump mode
Rem    bhammers    04/22/08 - renamed col in  XDB.XDB$XIDX_IMP_T
Rem    attran      06/01/08 - 7140541: xmlindex_noop
Rem    attran      04/15/08 - list partitioned XIX
Rem    bhammers    03/11/08 - import/export datapump
Rem    bhammers    11/14/07 - modified table XDB.XDB$XIDX_IMP_T
Rem    hxzhang     11/14/07 - Index Unification Project
Rem    attran      09/24/07 - ODCIStatsUpdPartStatistics
Rem    attran      08/24/07 - table function for single INSERT
Rem    atabar      07/11/07 - Add predicate entries to XDB.XMLIndexLoad_t
Rem    ningzhan    04/12/07 - increase snapshot size in DXPTAB to 20
Rem    attran      06/03/07 - 5925800: Got rid of XMLTM_LIB/XMLTM_FUNCIMPL
Rem    attran      11/01/07 - Bug 5765339 / ExImport
Rem    attran      11/06/06 - Exception handling during upgrade
Rem    attran      08/27/06 - Exchange Partition
Rem    thbaby      08/12/06 - rename pathsdoc column to parameters
Rem    attran      06/30/06 - Bug 5280799 / AMD64
Rem    thbaby      06/16/06 - make stats type also system-managed 
Rem    thbaby      06/13/06 - move drop indextype to up/down scripts
Rem    ataracha    06/07/06 - add support for export/import
Rem    attran      06/05/06 - Sys-Managed Partitioning
Rem    thbaby      05/24/06 - remove obsolete xmlindex operators 
Rem    ataracha    05/16/06 - comment out system-managed part.
Rem    attran      04/30/06 - System Managed Partitioning
Rem    thbaby      04/26/06 - remove 'without column data'
Rem    thbaby      04/25/06 - xmlindex without column data 
Rem    thbaby      12/21/05 - remove repeat interval from dictionary 
Rem    thbaby      12/15/05 - add new xdb$dxptab columns for async idx 
Rem    attran      11/30/05 - XMLIndexLoad_t TableFunction: Remove the LOB
Rem    ataracha    01/05/06 - rm xdb$dxpath, xdb$dxptab-add pathsdoc
Rem    attran      03/08/05 - Execute Privilege to the LOAD func
Rem    sichandr    03/03/05 - pipelined table func implementation 
Rem    attran      03/01/05 - Load into VALUE LOBs
Rem    attran      11/08/04 - STATISTICS
Rem    smukkama    09/27/04 - move xmlidx token plsql stuff from catxdbtm.sql
Rem    attran      10/31/04 - Security: obsolete operators.
Rem    attran      09/17/04 - Security: grant to public
Rem    attran      08/20/04 - Up/Down/grade
Rem    sichandr    08/26/04 - Add isnode function
Rem    athusoo     07/30/04 - Add hastext function 
Rem    athusoo     07/20/04 - use VARCHAR2 for value 
Rem    sichandr    07/18/04 - Load into CLOB
Rem    athusoo     07/08/04 - Add isattr function 
Rem    sichandr    06/18/04 - add pull table function 
Rem    athusoo     06/03/04 - Add support for xmlindex_parent operator 
Rem    sichandr    04/08/04 - add xmlindex_depth 
Rem    athusoo     03/30/04 - Add maxchild function 
Rem    athusoo     03/18/04 - Add pathstr parameter to IndexStart
Rem    athusoo     03/16/04 - Convert to xmlindex_getnodes operator 
Rem    attran      02/17/04 - Created

declare
  errno number;
begin
  execute immediate
    'disassociate statistics from indextypes XDB.XMLINDEX';
EXCEPTION
  when others then errno := 1;-- ignore all errors !
end;
/
SHOW ERRORS;

declare
  exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$DXPTAB'
  and owner = 'XDB';

  if exist = 0 then
    execute immediate
      'create table xdb.xdb$dxptab (
         idxobj#     number,                            -- object # of XMLIndex
         pathtabobj# number not null,                 -- object # of PATH TABLE
         flags       number,                      -- 0x01 INCLUDED vs EXCLUDED
         rawsize     number,                               -- size of RAW value
         parameters  XMLType,   -- PS: xml to store paths preferences, 
                                --     scheduler job information
         pendtabobj# number,                       -- object # of pending table
         snapshot    raw(20),   -- SCN and flashback timestamp of path table 
                                -- as of last successful sync
           constraint xdb$dxptabpk primary key (idxobj#)) xmltype column parameters store as CLOB';
    execute immediate
      'create unique index xdb.xdb$idxptab on xdb.xdb$dxptab(pathtabobj#)';
  end if;

  select count(*) into exist from DBA_TABLES 
  where table_name = 'XDB$XIDX_IMP_T'
        and owner = 'XDB';

  if exist = 0 then
     execute immediate
      'create global temporary table XDB.XDB$XIDX_IMP_T
                                (index_name VARCHAR2(40), 
                                 schema_name VARCHAR2(40),
                                 id VARCHAR2(40),    
                                 data CLOB,
                                 grppos NUMBER )
       on commit preserve rows';
        -- explanation of the columns:
        -- id:    identifies the type of the entry, 
        --        e.g. PATHS, STRUCT_IDXGRP, STRUCT_SECIDX, etc
        -- data:  the data of the entry, e.g. the parameter clause

     -- These privileges are ok because the table contents
     -- are private and isolated during the session.
     execute immediate
      'grant insert, select, delete on XDB.XDB$XIDX_IMP_T to public';
  end if;
        
  

  select count(*) into exist from DBA_TABLES 
  where table_name = 'XDB$XIDX_PARAM_T'
        and owner = 'XDB';

  if exist = 0 then
    execute immediate
      'create table XDB.XDB$XIDX_PARAM_T
                                (userid number, 
                                 param_name VARCHAR2(30),
                                 paramstr CLOB)';
    execute immediate
      'create unique index xdb.xdb$idxparam on xdb.xdb$xidx_param_t(userid,param_name)';
  end if;
end;
/
SHOW ERRORS;
 
------------------------------------------------------------------- 
-- Create package used by ODCIIndexGetMetadata
-------------------------------------------------------------------
CREATE OR REPLACE PACKAGE XDB.ximetadata_pkg AS 
  FUNCTION getIndexMetadata (idxinfo  IN  sys.ODCIIndexInfo,
                           expver   IN  VARCHAR2,
                           newblock OUT number,
                           idxenv   IN  sys.ODCIEnv) return VARCHAR2;
  FUNCTION getIndexMetadataCallback (idxinfo  IN  sys.ODCIIndexInfo,
                                expver   IN  VARCHAR2,
                                newblock OUT number,
                                idxenv   IN  sys.ODCIEnv) return CLOB;
  FUNCTION utlgettablenames(idxinfo  IN  sys.ODCIIndexInfo) return BOOLEAN;
 
END ximetadata_pkg;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY XDB.ximetadata_pkg AS 
  
iterate   NUMBER := 0;     -- counts the calls
data      CLOB := NULL;    -- buffer storage
offset NUMBER := 1;
done NUMBER := 0;

FUNCTION getIndexMetadata (idxinfo  IN  sys.ODCIIndexInfo,
                           expver   IN  VARCHAR2,
                           newblock OUT number,
                           idxenv   IN  sys.ODCIEnv) return VARCHAR2 IS 

  invalid_input         EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_input, -30980);      
  current_plsql VARCHAR2(32000); 
  pos    NUMBER := 0;
BEGIN 
  
  IF (done = 1) THEN
     iterate  := 0; -- reset
     done := 0;     -- reset
     RETURN '';
  END IF;
  
  newblock := 1; -- todo

  IF (sys.dbms_datapump.datapump_job) THEN 

    IF (iterate = 0) THEN -- first call: get data from c callback once
      data := getIndexMetadataCallback (idxinfo, expver, newblock, idxenv);
      IF (length(data) <= 30000) THEN 
        done := 1;          -- short metadata can be returned in one shot
        RETURN data;    
      END IF;
    END IF;

    -- we have long metadata 
    -- find the second occurence of 'insert into XDB.XDB'
    pos := dbms_lob.instr(data, 'insert into', offset, 2);

    IF (pos = 0) THEN -- not found
       current_plsql := DBMS_LOB.SUBSTR(data, 30000, offset); -- the rest
       done := 1;
    ELSE
       current_plsql:= DBMS_LOB.SUBSTR(data, pos - offset -1, offset);
      offset := pos;
    END IF;
 
    iterate := iterate + 1; 
    return current_plsql;       
                                   
  END IF; 
  raise invalid_input;
  
  return '';
END getIndexMetadata; 


 function getIndexMetadataCallback (idxinfo  IN  sys.ODCIIndexInfo,
                                    expver   IN  VARCHAR2,
                                    newblock OUT number,
                                    idxenv   IN  sys.ODCIEnv)
         return CLOB
  is language C name "QMIX_XMETADATA" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       expver,  expver   INDICATOR,
       newblock,newblock INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCILobLocator);

 FUNCTION utlgettablenames(idxinfo  IN  sys.ODCIIndexInfo) return BOOLEAN
 is language C name "QMIX_TABLEUTILS" library  XDB.XMLINDEX_LIB
      with context
      parameters (
        context,
        idxinfo, idxinfo  INDICATOR struct,
        RETURN            INDICATOR sb4,
        return);
 
END ximetadata_pkg; 
/  
SHOW ERRORS;


create or replace public synonym ximetadata_pkg for XDB.ximetadata_pkg;
/  
SHOW ERRORS;

/*-----------------------------------------------------------------------*/
/*  TYPE IMPLEMENTATION                                                  */
/*-----------------------------------------------------------------------*/
create or replace type xdb.XMLIndexMethods
  OID '10000000000000000000000000020118'
  authid current_user as object
(
  -- cursor set by IndexStart and used in IndexFetch
  scanctx RAW(8),

  -- DCLs
  static function ODCIGetInterfaces (ilist OUT sys.ODCIObjectList)
         return NUMBER,

  -- DDLs
  static function ODCIIndexCreate   (idxinfo  sys.ODCIIndexInfo,
                                     idxparms VARCHAR2,
                                     idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_CREATE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       idxparms,idxparms INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexDrop     (idxinfo sys.ODCIIndexInfo,
                                     idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DROP" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexAlter    (idxinfo          sys.ODCIIndexInfo, 
                                     idxparms  IN OUT VARCHAR2,
                                     opt              NUMBER,
                                     idxenv           sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_ALTER" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       idxparms,idxparms INDICATOR,
       opt,     opt      INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexTruncate (idxinfo sys.ODCIIndexInfo,
                                     idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_TRUNC" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  --- DMLs ---
  static function ODCIIndexInsert (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   doc     sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_INSERT" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       doc,     doc     INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexDelete (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   doc     sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DELETE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       doc,     doc     INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexUpdate (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   olddoc  sys.xmltype,
                                   newdoc  sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_UPDATE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       olddoc,  olddoc  INDICATOR,
       newdoc,  newdoc  INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  --- Query ---
  static function ODCIIndexStart (ictx    IN OUT XMLIndexMethods,
                                  idxinfo        sys.ODCIIndexInfo,
                                  opi            sys.ODCIPredInfo, 
                                  oqi            sys.ODCIQueryInfo,
                                  strt           NUMBER,
                                  stop           NUMBER,
                                  pathstr        varchar2,
                                  idxenv         sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_START" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       ictx,    ictx    INDICATOR struct,
       idxinfo, idxinfo INDICATOR struct,
       opi,     opi     INDICATOR struct,
       oqi,     oqi     INDICATOR struct,
       strt,    strt    INDICATOR, 
       stop,    stop    INDICATOR,
       pathstr, pathstr LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  member function ODCIIndexFetch (nrows      NUMBER,
                                  rids   OUT sys.ODCIRidList,
                                  idxenv     sys.ODCIEnv)
         return  NUMBER
  is language C name "QMIX_FETCH" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       self,     self INDICATOR struct,
       nrows,   nrows INDICATOR,
       rids,     rids INDICATOR,
       idxenv, idxenv INDICATOR struct,
       return OCINumber),

  member function ODCIIndexClose (idxenv sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_CLOSE" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       self,     self INDICATOR struct,
       idxenv, idxenv INDICATOR struct,
       return OCINumber),

  static function ODCIIndexExchangePartition (idxPinfo sys.ODCIIndexInfo,
                                              idxTinfo sys.ODCIIndexInfo, 
                                              idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_EXCHANGE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxPinfo, idxPinfo INDICATOR struct,
       idxTinfo, idxTinfo INDICATOR struct,
       idxenv,   idxenv   INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexUpdPartMetadata(ixdxinfo sys.ODCIIndexInfo,
                                           palist   sys.ODCIPartInfoList,
                                           idxenv   sys.ODCIEnv)
         return NUMBER,
--  is language C name "QMIX_UPD_P_METADATA" library XDB.XMLINDEX_LIB
--     with context
--     parameters (
--       context,
--       idxinfo, idxinfo INDICATOR struct,
--       idxenv,  idxenv  INDICATOR struct,
--       RETURN OCINumber),


--- MOVE / TRANSPORTABLE TBS / IM/EXPORT ---
  static function ODCIIndexGetMetadata(idxinfo  IN  sys.ODCIIndexInfo,
                                       expver   IN  VARCHAR2,
                                       newblock OUT number,
                                       idxenv   IN  sys.ODCIEnv)
         return VARCHAR2,

  static FUNCTION ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, 
                                      read_only IN PLS_INTEGER, 
                                      version IN varchar2, 
                                      context OUT PLS_INTEGER)
  RETURN BOOLEAN,

  static PROCEDURE ODCIIndexUtilCleanup (context  IN PLS_INTEGER)

);
/
show errors;

create or replace type body xdb.XMLIndexMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;

  static function ODCIIndexUpdPartMetadata(ixdxinfo sys.ODCIIndexInfo,
                                           palist   sys.ODCIPartInfoList,
                                           idxenv   sys.ODCIEnv)
         return NUMBER
  is
  BEGIN
   RETURN ODCICONST.SUCCESS;
  END;

  static function ODCIIndexGetMetadata(idxinfo  IN  sys.ODCIIndexInfo,
                                       expver   IN  VARCHAR2,
                                       newblock OUT number,
                                       idxenv   IN  sys.ODCIEnv)
         return VARCHAR2
  is
  begin
    return XDB.ximetadata_pkg.getIndexMetadata(idxinfo, expver, newblock, idxenv);
  end ODCIIndexGetMetadata; 

  -- path table and secondary indexes on it are already exported in schema-mode
  -- this routine should only expose them for Transportable Tablespaces,
  -- via DataPump
  static function ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, 
                                             read_only IN PLS_INTEGER, 
                                             version IN varchar2, 
                                             context OUT PLS_INTEGER)
         return BOOLEAN
  is
  begin
    return XDB.ximetadata_pkg.utlgettablenames(ia);
  end ODCIIndexUtilGetTableNames;

  static procedure ODCIIndexUtilCleanup (context  PLS_INTEGER)
  is
  begin
    -- dummy routine
    return;
  end ODCIIndexUtilCleanup;

end;
/
show errors;

create or replace type xdb.XMLIdxStatsMethods
  OID '20000000000000000000000000023456'
  authid current_user as object
(
  -- user-defined function cost and selectivity functions
  cost number,

  -- DCLs
  static function ODCIGetInterfaces (ilist OUT sys.ODCIObjectList)
         return NUMBER,

  --- STATISTICs ---
  static function ODCIStatsCollect(colinfo   sys.ODCIColInfo,
                                   options   sys.ODCIStatsOptions,
                                   stats OUT RAW,
                                   idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_COL_STATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       colinfo, colinfo INDICATOR struct,
       options, options INDICATOR struct,
       stats,   stats   INDICATOR, stats LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  static function ODCIStatsCollect(idxinfo   sys.ODCIIndexInfo,
                                   options   sys.ODCIStatsOptions,
                                   stats OUT RAW,
                                   idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_IDX_STATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       options, options INDICATOR struct,
       stats,   stats   INDICATOR, stats LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  static function ODCIStatsDelete(colinfo   sys.ODCIColInfo,
                                  statistics OUT RAW,
                                  idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DEL_COLSTATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       colinfo,    colinfo    INDICATOR struct,
       statistics, statistics INDICATOR, statistics LENGTH,
       idxenv,     idxenv     INDICATOR struct,
       return OCINumber),

  static function ODCIStatsDelete(idxinfo   sys.ODCIIndexInfo,
                                  statistics OUT RAW,
                                  idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DEL_IDXSTATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       idxinfo,    idxinfo    INDICATOR struct,
       statistics, statistics INDICATOR, statistics LENGTH,
       idxenv,     idxenv     INDICATOR struct,
       return OCINumber),

  static function ODCIStatsSelectivity(predinfo sys.ODCIPredInfo,
                                       sel  OUT number,
                                       args     sys.ODCIArgDescList,
                                       strt     number,
                                       stop     number,
                                       expr     VARCHAR2,
                                       datai    VARCHAR2,
                                       idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_SELECTIVITY" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       predinfo,predinfo INDICATOR struct,
       sel,     sel      INDICATOR,
       args,    args     INDICATOR,
       strt,    strt     INDICATOR, 
       stop,    stop     INDICATOR,
       expr,    expr     INDICATOR,
       datai,   datai    INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       return OCINumber),

  static function ODCIStatsFunctionCost(funcinfo sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args     sys.ODCIArgDescList,
                                        expr     VARCHAR2,
                                        datai    VARCHAR2,
                                        idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_FUN_COST" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       funcinfo,funcinfo INDICATOR struct,
       cost,    cost     INDICATOR struct,
       args,    args     INDICATOR,
       expr,    expr     INDICATOR,
       datai,   datai    INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       return OCINumber),

  static function ODCIStatsIndexCost(idxinfo  sys.ODCIIndexInfo,
                                     sel      number,
                                     cost OUT sys.ODCICost,
                                     qi       sys.ODCIQueryInfo,
                                     pred     sys.ODCIPredInfo,
                                     args     sys.ODCIArgDescList,
                                     strt     number,
                                     stop     number,
                                     datai    varchar2,
                                     idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_IDX_COST" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       sel,     sel     INDICATOR,
       cost,    cost    INDICATOR struct,
       qi,      qi      INDICATOR struct,
       pred,    pred    INDICATOR struct,
       args,    args    INDICATOR,
       strt,    strt    INDICATOR, 
       stop,    stop    INDICATOR,
       datai,   datai   INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  static function ODCIStatsUpdPartStatistics(idxinfo sys.ODCIIndexInfo,
                                             palist  sys.ODCIPartInfoList,
                                             idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_UPD_PARTSTATS" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       palist,  palist  INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber)
);
/
show errors;

create or replace type body xdb.XMLIdxStatsMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCISTATS2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;
end;
/
show errors;


/*------------------------------------------------------------------------*/
/*  TABLE FUNCTIONs                                                       */
/*  - XMLIndexLoad to parallellize the source cursor.                     */
/*------------------------------------------------------------------------*/
drop function XDB.XMLIndexInsFunc;
drop function XDB.XMLIndexLoadFunc;
drop type XDB.XMLIndexLoad_Imp_t force;
drop type XDB.XMLIndexTab_t;
drop type XDB.XMLIndexLoad_t force;
create or replace type XDB.XMLIndexLoad_t as object
(
  RID    VARCHAR2(18),
  PID    RAW(8),
  OK     RAW(1000),
  LOC    RAW(2000),
  VALUE  VARCHAR2(4000)
)
/

create or replace type XDB.XMLIndexTab_t as TABLE of XDB.XMLIndexLoad_t
/

create or replace type XDB.XMLIndexLoad_Imp_t
  authid current_user as object
(
  key RAW(8),

  static function ODCITableStart(sctx IN OUT XDB.XMLIndexLoad_Imp_t)
         return PLS_INTEGER
    is language C name "QMIX_INSSTART" library XDB.XMLINDEX_LIB
    with context
    parameters (
      context,
      sctx,        sctx        INDICATOR STRUCT,
      return INT
    ),

  static function ODCITableStart(sctx IN OUT XDB.XMLIndexLoad_Imp_t,
                                 load_cursor SYS_REFCURSOR,
                                 flags IN Number)
         return PLS_INTEGER
    is language C name "QMIX_LOADSTART" library XDB.XMLINDEX_LIB
    with context
    parameters (
      context,
      sctx,        sctx        INDICATOR STRUCT,
      load_cursor, load_cursor INDICATOR,
      flags,
      return INT
    ),

  member function ODCITableFetch(self IN OUT XDB.XMLIndexLoad_Imp_t,
                                 nrows    IN Number,
                                 xmlrws  OUT XDB.XMLIndexTab_t)
         return PLS_INTEGER
    as language C name "QMIX_LOADFETCH" library XDB.XMLINDEX_LIB
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      nrows,
      xmlrws OCIColl, xmlrws INDICATOR sb2, xmlrws DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XDB.XMLIndexLoad_Imp_t)
         return PLS_INTEGER
    as language C name "QMIX_LOADCLOSE" library XDB.XMLINDEX_LIB
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      return INT
    )
);
/
show errors;

create or replace function XDB.XMLIndexLoadFunc(p IN SYS_REFCURSOR,
                                                flags NUMBER)
       return XDB.XMLIndexTab_t
authid current_user
parallel_enable (partition p by ANY)
pipelined using XDB.XMLIndexLoad_Imp_t;
/
show errors;
grant execute on XDB.XMLIndexLoadFunc to public;

create or replace function XDB.XMLIndexInsFunc
       return XDB.XMLIndexTab_t
authid current_user
pipelined using XDB.XMLIndexLoad_Imp_t;
/
show errors;
grant execute on XDB.XMLIndexInsFunc to public;

/*------------------------------------------------------------------------*/
/*  INDEXTYPE                                                             */
/*------------------------------------------------------------------------*/
create or replace package XDB.XMLIndex_FUNCIMPL authid current_user is
  function xmlindex_noop(res sys.xmltype,
                         pathstr varchar2, 
                         ia sys.odciindexctx,
                         sctx IN OUT XDB.XMLIndexMethods,
                         sflg number)
  return number;
end XMLIndex_FUNCIMPL;
/
show errors;
create or replace package body XDB.XMLIndex_FUNCIMPL as
  function xmlindex_noop(res sys.xmltype,
                         pathstr varchar2, 
                         ia sys.odciindexctx,
                         sctx IN OUT XDB.XMLIndexMethods,
                         sflg number)
  return number is
  begin
   return 0;
  end;
end;
/
show errors;

create or replace operator XDB.xmlindex_noop binding
  (sys.xmltype, varchar2) return number with index context, 
    scan context XDB.XMLIndexMethods
    without column data using XDB.XMLIndex_FUNCIMPL.xmlindex_noop;
show errors;
grant execute on XDB.xmlindex_noop to public;

create or replace indextype XDB.XMLIndex for
  XDB.xmlindex_noop(sys.xmltype, varchar2)
  using XDB.XMLIndexMethods
  with local partition
  with system managed storage tables;
--  without column data;
--  with array dml (sys.xmltype, varray_xmltype)
show errors;

grant execute on XDB.XMLIndex to public;

associate statistics with indextypes XDB.XMLIndex using XDB.XMLIdxStatsMethods
with system managed storage tables;

/************ Path suffix table function *********************/
-- create trusted library
CREATE OR REPLACE LIBRARY XDB.XMLTM_LIB TRUSTED AS STATIC;
/
show errors

