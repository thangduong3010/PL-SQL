Rem
Rem $Header: catxdbeo.sql 20-may-2003.00:27:34 njalali Exp $
Rem
Rem catxdbeo.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxdbeo.sql - XDB repository views extensible optimizer
Rem
Rem    DESCRIPTION
Rem      This script creates statistics type and schema
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    njalali     05/20/03 - njalali_all_xml_schemas2
Rem    fge         05/19/03 - support repository views extensible optimizer
Rem    fge         05/19/03 - Created
Rem

/* disassociate statistics type */
disassociate statistics from indextypes xdb.xdbhi_idxtyp;
disassociate statistics from packages xdb.xdb_funcimpl;

/* drop statistics type */
drop type xdb.funcstats;

/* --------------------------------------------------------------------------*/
/* create statistics type                                                    */
/* --------------------------------------------------------------------------*/
create or replace type xdb.funcstats
OID '0000000000000000000000000002015E'
authid definer as object
(
  -- user-defined function cost and selectivity functions
  j number,

  static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) 
    return number,

  -- function to collect index statistics
  static function ODCIStatsCollect(ia sys.ODCIIndexInfo,
                                   options sys.ODCIStatsOptions,
                                   statistics OUT RAW,
                                   env sys.ODCIEnv)
  return number
  is language C
  name "STATSCOLL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    options,
    options INDICATOR STRUCT,
    statistics,
    statistics INDICATOR,
    statistics LENGTH,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- funtion to delete index statistics
  static function ODCIStatsDelete(ia sys.ODCIIndexInfo,
                                  statistics OUT RAW,
                                  env sys.ODCIEnv)
  return number
  is language C
  name "STATSDEL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    statistics,
    statistics INDICATOR,
    statistics LENGTH,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- index cost
  static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo,
                                     sel number,
                                     cost OUT sys.ODCICost,
                                     qi sys.ODCIQueryInfo,
                                     pred sys.ODCIPredInfo,
                                     args sys.ODCIArgDescList,
                                     strt number,
                                     stop number,
                                     depth number,
                                     valarg varchar2,
                                     env sys.ODCIenv)
  return number
  is language C
  name "STATSINDCOST_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    cost,
    cost INDICATOR STRUCT,
    qi,
    qi INDICATOR STRUCT,
    pred,
    pred INDICATOR STRUCT,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    depth,
    depth INDICATOR,
    valarg,
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo,
                                     sel number,
                                     cost OUT sys.ODCICost,
                                     qi sys.ODCIQueryInfo,
                                     pred sys.ODCIPredInfo,
                                     args sys.ODCIArgDescList,
                                     strt number,
                                     stop number,
                                     valarg varchar2,
                                     env sys.ODCIenv)
  return number
  is language C
  name "STATSINDCOST1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    ia,
    ia INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    cost,
    cost INDICATOR STRUCT,
    qi,
    qi INDICATOR STRUCT,
    pred,
    pred INDICATOR STRUCT,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    valarg,
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  -- function cost

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args sys.ODCIArgDescList,
                                        colval xmltype,
                                        depth number,
                                        valarg varchar2,
                                        env  sys.ODCIEnv)
  return number
  is language C
  name "STATSFUNCCOST_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    func,
    func INDICATOR STRUCT,
    cost,
    cost INDICATOR STRUCT,
    args,
    args INDICATOR,
    colval, 
    colval INDICATOR,
    depth,
    depth INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args sys.ODCIArgDescList,
                                        colval xmltype,
                                        valarg varchar2,
                                        env  sys.ODCIEnv)
  return number
  is language C
  name "STATSFUNCCOST1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    func,
    func INDICATOR STRUCT,
    cost,
    cost INDICATOR STRUCT,
    args,
    args INDICATOR,
    colval, 
    colval INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

   static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
                                        sel OUT number,
                                        args sys.ODCIArgDescList,
                                        strt number,
                                        stop number,
                                        colval xmltype,
                                        depth number,
                                        valarg varchar2,
                                       env sys.ODCIenv)
  return number
  is language C
  name "STATSSEL_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    pred,
    pred INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    colval, 
    colval INDICATOR,
    depth,
    depth INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber),

 -- selectivity for under_path_func1
  static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
                                       sel OUT number,
                                       args sys.ODCIArgDescList,
                                       strt number,
                                       stop number,
                                       colval xmltype,
                                       valarg varchar2,
                                       env sys.ODCIenv)
  return number
  is language C
  name "STATSSEL1_XDBHI"
  library XDB.RESOURCE_VIEW_LIB
  with context
  parameters (
    context,
    pred,
    pred INDICATOR STRUCT,
    sel,
    sel INDICATOR,
    args,
    args INDICATOR,
    strt,
    strt INDICATOR,
    stop,
    stop INDICATOR,
    colval, 
    colval INDICATOR,
    valarg, 
    valarg INDICATOR,
    env,
    env INDICATOR STRUCT,
    return OCINumber)
);
/

show errors;

/* --------------------------------------------------------------------------*/
/* create statistics type bodies                                             */
/* --------------------------------------------------------------------------*/
create or replace type body xdb.funcstats is
   static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList)
       return number is
   begin
       ifclist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCISTATS2'));
       return ODCIConst.Success;
   end ODCIGetInterfaces;

end;
/
show errors;

grant execute on xdb.funcstats to public;

associate statistics with indextypes xdb.xdbhi_idxtyp using xdb.funcstats;
associate statistics with packages xdb.xdb_funcimpl using xdb.funcstats;

/* --------------------------------------------------------------------------*/
/* register statistics schema
/* --------------------------------------------------------------------------*/
declare
  STATSXSD VARCHAR2(4000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        xmlns:st="http://xmlns.oracle.com/xdb/stats.xsd"
        targetNamespace="http://xmlns.oracle.com/xdb/stats.xsd"
        elementFormDefault="qualified">
   <simpleType name="OIDType"> <restriction base="hexBinary"> <maxLength value="32"/> </restriction> </simpleType>
   <element name="ContainerStats" xdb:defaultTable="XDB$STATS" xdb:columnProps="constraint stats_pk PRIMARY KEY(xmldata.RESOID)">
     <complexType>
       <sequence>
         <element name="TotalRows" type="double"/>
         <element name="TotalContainers" type="double"/>
         <element name="FanOut" type="integer"/>
         <element name="ImmediateContainers" type="integer"/>
         <element name="LastAnalyzedDate" type="dateTime"/>
       </sequence>
       <attribute name="ResOid" type="st:OIDType" xdb:SQLName="RESOID"/>
     </complexType>
   </element>
</schema>';

  STATSURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/stats.xsd';
  n integer;
begin
  select count(*) into n from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  if (n = 0) then
    xdb.dbms_xmlschema.registerSchema(STATSURL, STATSXSD, FALSE, TRUE,
                                      FALSE, TRUE, FALSE, 'XDB');
  end if;
end;
/
