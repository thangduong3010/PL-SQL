Rem
Rem $Header: rdbms/admin/dbmscoll.sql /st_rdbms_11.2.0/1 2011/06/15 01:33:38 atomar Exp $
Rem
Rem dbmscoll.sql
Rem
Rem Copyright (c) 2002, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscoll.sql - Registration for the collect as user defined agg.
Rem
Rem    DESCRIPTION
Rem      This file contains the registration for the collect aggregate.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    atomar      06/13/11 - Backport atomar_bug-11906197 from main
Rem    skabraha    12/22/09 - revoke existing grant for COLLECT
Rem    skabraha    07/23/08 - remove with grant option for COLLECT
Rem    ayoaz       01/04/07 - remove execute priv on SYS_NT_COLLECT_IMP
Rem    mmorsi      03/12/03 - Enable parallel collect
Rem    mmorsi      10/18/02 - mmorsi_coll1
Rem    ayoaz       10/10/02 - modifications
Rem    mmorsi      10/04/02 - Create COLLECT as an User Defined Aggregate
Rem    mmorsi      10/04/02 - Created
Rem

create or replace library collection_lib trusted as static
/

-- create Nested Table Collect implementation
-- Magdi:ToDo from where do we get the value of the OID

create or replace type SYS_NT_COLLECT_IMP OID '00000000000000000000000000550101'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT SYS_NT_COLLECT_IMP,
                                          optp IN RAW, opnp IN RAW) 
   return pls_integer
   is language c name "CollectInitialize" library collection_lib with context
   parameters(context, sctx,sctx INDICATOR STRUCT,sctx DURATION OCIDuration,
              optp OCIRaw, opnp OCIRaw, return INT),

  member function ODCIAggregateIterate(
      self IN OUT NOCOPY SYS_NT_COLLECT_IMP, obj IN AnyData) 
      return pls_integer
      is language c name "CollectIterate" library collection_lib with context parameters
    (context, self, self INDICATOR STRUCT, self DURATION OCIDuration,
        obj, obj INDICATOR sb2, return INT),

  member function ODCIAggregateTerminate(
    self IN OUT NOCOPY SYS_NT_COLLECT_IMP, returnValue OUT sys.AnyDataSet,
    flags IN number) return pls_integer
    is language c name "CollectTerminate" library collection_lib with context
   parameters (context, self, self INDICATOR STRUCT, returnValue,
               returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
               flags, flags INDICATOR sb2, return INT),

  member function ODCIAggregateMerge(self IN OUT NOCOPY SYS_NT_COLLECT_IMP,
                  valueB IN SYS_NT_COLLECT_IMP) return pls_integer
     is language c name "CollectMerge" library collection_lib with context
    parameters (context, self, self INDICATOR STRUCT, self DURATION OCIDuration,
                 valueB, valueB INDICATOR STRUCT, return INT)

);
/
show errors;

-- make sure there is no public execute priv on type

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE on SYS_NT_COLLECT_IMP from PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1927 THEN
      RAISE;
    END IF;
END;
/

create or replace function SYS_NT_COLLECT(obj IN AnyData) 
return sys.AnyDataSet 
aggregate using SYS_NT_COLLECT_IMP;
/

create or replace public synonym SYS_NT_COLLECT for SYS_NT_COLLECT;


-- revoke existing executes for SYS_NT_COLLECT and COLLECT. This
-- is done as old grants are inherited by recreated procedures.
BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE on SYS_NT_COLLECT from PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;   
    ELSE RAISE;
    END IF;
END;
/

grant execute on SYS_NT_COLLECT to public;

create or replace public synonym COLLECT for SYS_NT_COLLECT;

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE on COLLECT from PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;   
    ELSE RAISE;
    END IF;
END;
/

grant execute on COLLECT to public;

