Rem Copyright (c) 2000, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxidx.sql - DBMS XMLIndex index support routines 
Rem
Rem    DESCRIPTION
Rem      Defines the XMLIndex index creation routines using the extensibility
Rem    mechanism 
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sipatel     05/02/11 - Backport sipatel_xmlindex_proc_replication from
Rem                           main
Rem                         - #(11067798)-change supplemental logging pragma
Rem    sipatel     04/28/11 - Backport sipatel_bug-12360609 from main
Rem                         - #(12360609)-add pending_row_count out param for
Rem                           process_pending
Rem    sipatel     01/04/11 - #(11686104)-add process_pending
Rem    thbaby      06/02/10 - revoke 'with grant option' from public
Rem    attran      03/08/10 - 9398943: default NULL schema for SyncIndex
Rem                           NumberIndex, DateIndex
Rem    badeoti     03/19/09 - cleanup for 11.2 packages: remove noderef-related
Rem                           procs/funcs NodeRefGetRef, NodeRefGetValue, NodeRefGetParentRef,
Rem                           NodeRefGetName, NodeRefGetNamespace
Rem    ajadams     11/07/08 - add with_commit to supplemental_log pragma
Rem    bhammers    08/25/08 - add getparameter
Rem    thbaby      06/24/08 - revoke grant privilege on stragg
Rem    hxzhang     04/15/08 - add dropParameter
Rem    hxzhang     11/14/07 - Index Unification Project
Rem    atabar      11/09/07 - add reindex parameter to SyncIndex
Rem    attran      10/01/07 - Partitioning + SyncIndex
Rem    thbaby      10/24/07 - add column name to
Rem                           createnumberindex/createdateindex
Rem    thbaby      06/21/07 - documentation for SyncIndex
Rem    preilly     04/23/07 - Fix bug 6003399 - gather_table_stats in logical
Rem                           standby
Rem    thbaby      02/15/07 - implement stragg as an internal aggregate
Rem    thbaby      02/14/07 - return aggregated length in stragg terminate
Rem    thbaby      02/08/07 - add stragg user defined operator
Rem    thbaby      01/30/07 - remove NodeRefGetPosPath, NodeRefGetNamePath
Rem    attran      01/16/07 - bug-5736555: export_clob
Rem    qiwang      12/14/06 - add Logmnr PLSQL pragam for dbms_xmlindex
Rem    thbaby      11/28/06 - new CreateNumberIndex that accepts xmltype name
Rem    thbaby      11/02/06 - move dbms_xmlindex package body out
Rem    thbaby      08/14/06 - rename *_xml_indexes column paths to parameters
Rem    thbaby      07/27/06 - add dbms_xmlindex.NodeRefGetRef 
Rem    attran      08/01/06 - add gather_table/delete_stats
Rem    ataracha    06/08/06 - add export support
Rem    rmurthy     04/28/05 - add dbms_xnid for node id operations 
Rem    attran      01/04/06 - ALTER SESSION privilege -> C routines
Rem    attran      02/04/05 - bug4148624: SQLInjection
Rem    sichandr    11/22/04 - remove set echo statements 
Rem    sichandr    08/11/04 - utility package for XMLIndex 
Rem    mkrishna    09/06/01 - remove existsnode/extract
Rem    mkrishna    06/29/00 - Created
Rem


/*-----------------------------------------------------------------------*/
/*  LIBRARY                                                              */
/*-----------------------------------------------------------------------*/
create or replace library XDB.XMLIndex_lib trusted as static;
/
show errors;

CREATE OR REPLACE PACKAGE xdb.dbms_xmlindex AUTHID CURRENT_USER AS

----------------------------------------------------------------------------
-- PROCEDURE - CreateNumberIndex
--     Creates an index for number values in the XMLIndex. The index
--     is created on the VALUE column of the XMLIndex path table on the
--     expression TO_BINARY_DOUBLE(VALUE).
-- PARAMETERS -    
--  xml_index_schema
--     Schema of the XMLIndex: default is current user schema
--  xml_index_name
--     Name of the XMLIndex
--  num_index_name: default is system-generated
--     Name of the number index to create
--  num_index_clause
--     Storage clause for the number index. This would simply be appended
--     to the CREATE INDEX statement.
--  xmltypename
--     Xml type name corresponding to the number - one of the following:
--     float
--     double
--     decimal
--     integer
--     nonPositiveInteger
--     negativeInteger
--     long
--     int
--     short
--     byte
--     nonNegativeInteger
--     unsignedLong
--     unsignedInt
--     unsignedShort
--     unsignedByte
--     positiveInteger
--  column_name
--     Name of the path table column on which to create the number index. 
----------------------------------------------------------------------------
PROCEDURE CreateNumberIndex(xml_index_schema IN VARCHAR2 := USER,
                            xml_index_name   IN VARCHAR2,
                            num_index_name   IN VARCHAR2 := NULL,
                            num_index_clause IN VARCHAR2 := NULL,
                            xmltypename      IN VARCHAR2 := NULL,
                            column_name      IN VARCHAR2 := NULL);
PRAGMA SUPPLEMENTAL_LOG_DATA(CreateNumberIndex, AUTO_WITH_COMMIT);

----------------------------------------------------------------------------
-- PROCEDURE - CreateDateIndex
--     Creates an index for date values in the XMLIndex. The user specifies
--     the XML type name (date, dateTime etc.) and the index is created
--     on SYS_XMLCONV(VALUE) which would always return a TIMESTAMP datatype.
-- PARAMETERS -    
--  xml_index_schema
--     Schema of the XMLIndex: default is current user schema
--  xml_index_name
--     Name of the XMLIndex
--  date_index_name: default is system generated
--     Name of the date index to be created
--  xmltypename
--     XML type name - one of the following
--         dateTime
--         time
--         date
--         gDay
--         gMonth
--         gYear
--         gYearMonth
--         gMonthDay
--  date_index_clause
--     Storage clause for the date index. This would simply be appended
--     to the CREATE INDEX statement.
--  column_name
--     Name of the path table column on which to create the date index. 
----------------------------------------------------------------------------
PROCEDURE CreateDateIndex(xml_index_schema  IN VARCHAR2 := USER,
                          xml_index_name    IN VARCHAR2,
                          date_index_name   IN VARCHAR2 := NULL,
                          xmltypename       IN VARCHAR2 := NULL,
                          date_index_clause IN VARCHAR2 := NULL,
                          column_name       IN VARCHAR2 := NULL);
PRAGMA SUPPLEMENTAL_LOG_DATA(CreateDateIndex, AUTO_WITH_COMMIT);
   
----------------------------------------------------------------------------
--    PROCEDURE SyncIndex(xml_index_schema IN VARCHAR2,
--                        xml_index_name   IN VARCHAR2,
--                        partition_name   IN VARCHAR2,
--			  reindex          IN BOOLEAN);

--    This procedure synchronizes an asynchronously maintained xmlindex. 
--    It applies to the xmlindex changes that are logged in the pending 
--    table, and brings the path table up-to-date with the base xmltype 
--    column. 
--    
--    PARAMETERS
--    (a) xml_index_schema - Name of the owner of the XMLIndex.
--    (b) xml_index_name   - Name of the XMLIndex.
--    (c) partition_name   - Optional name of the partition to be synced.
--    (d) reindex          - If true drops and recreates secondary indexes 
--				on path table. Default is false.
----------------------------------------------------------------------------
PROCEDURE SyncIndex(xml_index_schema IN VARCHAR2 default USER,
                    xml_index_name   IN VARCHAR2,
                    partition_name   IN VARCHAR2 default NULL,
		    reindex          IN BOOLEAN  default FALSE);
PRAGMA SUPPLEMENTAL_LOG_DATA(SyncIndex, AUTO_WITH_COMMIT);

PROCEDURE gather_table_stats(ownname          IN VARCHAR2,
                             tabname          IN VARCHAR2,
                             partname         IN VARCHAR2 default NULL,
                             estimate_percent IN NUMBER default 0,
                             block_sample     IN NUMBER default 0,
                             granularity      IN VARCHAR2 default 'AUTO');
PRAGMA SUPPLEMENTAL_LOG_DATA(gather_table_stats, MANUAL);

PROCEDURE delete_table_stats(ownname       IN VARCHAR2,
                             tabname       IN VARCHAR2,
                             partname      IN VARCHAR2 default NULL,
                             cascade_parts IN NUMBER default 1);
PRAGMA SUPPLEMENTAL_LOG_DATA(delete_table_stats, UNSUPPORTED_WITH_COMMIT);

PROCEDURE registerparameter(paramname       IN VARCHAR2,
                            paramstr        IN CLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(registerparameter, UNSUPPORTED_WITH_COMMIT);

PROCEDURE modifyparameter(paramname       IN VARCHAR2,
                          paramstr        IN CLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(modifyparameter, UNSUPPORTED_WITH_COMMIT);

PROCEDURE dropparameter(paramname       IN VARCHAR2);
PRAGMA SUPPLEMENTAL_LOG_DATA(dropparameter, UNSUPPORTED_WITH_COMMIT);

FUNCTION getparameter(paramname IN VARCHAR2) RETURN VARCHAR2;

----------------------------------------------------------------------------
--    PROCEDURE PROCESS_PENDING(xml_index_schema  IN  VARCHAR2,
--                              xml_index_name    IN  VARCHAR2,
--                              pending_row_count OUT BINARY_INTEGER);

--    This procedure executes DMLs required to complete a NONBLOCKING
--    alter index add_group/add_column operation. 
--    
--    PARAMETERS
--    (a) xml_index_schema - Name of the owner of the XMLIndex.
--    (b) xml_index_name   - Name of the XMLIndex.
--    (c) pending_row_count - RETURNs number of rows that still have 
--                            to be processed/indexed.
----------------------------------------------------------------------------
PROCEDURE process_pending(xml_index_schema  IN   VARCHAR2,
                          xml_index_name    IN   VARCHAR2,
                          pending_row_count OUT  BINARY_INTEGER);
PRAGMA SUPPLEMENTAL_LOG_DATA(process_pending, AUTO_WITH_COMMIT);

end dbms_xmlindex;
/
show errors;

grant execute on xdb.dbms_xmlindex to public;
create or replace public synonym dbms_xmlindex for xdb.dbms_xmlindex;

create or replace type string_agg_type 
-- OID '00000000000000000000000000020101'
as object
(
   key      raw(8),

   static function
        ODCIAggregateInitialize(sctx IN OUT string_agg_type, outopn IN RAW,
                                inpopn IN RAW)
        return pls_integer

        as language c
        library xmltype_lib
        name "STRAGG_INITIALIZE"
        with context
        parameters (
          context,
          sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
          outopn OCIRaw, inpopn OCIRaw, 
          return int
        ),

   member function
        ODCIAggregateIterate(self IN OUT string_agg_type ,
                             value IN varchar2 )
        return pls_integer

        as language c
        library xmltype_lib
        name "STRAGG_ITERATE"
        with context
        parameters (
          context,
          self, self INDICATOR STRUCT, self DURATION OCIDuration,
          value, value INDICATOR, value LENGTH,
          return int
        ),

   member function
        ODCIAggregateTerminate(self IN string_agg_type,
                               returnValue OUT  varchar2,
                               flags IN number)
        return pls_integer

        as language c
        library xmltype_lib
        name "STRAGG_TERMINATE"
        with context
        parameters (
          context,
          self, self INDICATOR STRUCT, 
          returnValue, returnValue INDICATOR, returnValue LENGTH,
          flags, flags INDICATOR,
          return int
        ),

   member function
        ODCIAggregateMerge(self IN OUT string_agg_type,
                           ctx2 IN string_agg_type)
        return pls_integer

        as language c
        library xmltype_lib
        name "STRAGG_MERGE"
        with context
        parameters (
          context,
          self, self INDICATOR STRUCT, self DURATION OCIDuration,
          ctx2, ctx2 INDICATOR STRUCT,
          return int
        )
);
/

show errors;
/

/* stragg cannot be parallel-enabled unless order by is supported in 
 * parallel mode for user defined aggregates
 */
CREATE or replace
FUNCTION stragg(input varchar2 )
RETURN varchar2
AGGREGATE USING string_agg_type;
/

GRANT EXECUTE on stragg to PUBLIC;
REVOKE EXECUTE on stragg from PUBLIC;
GRANT EXECUTE on stragg to PUBLIC;
