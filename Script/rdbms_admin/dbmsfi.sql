Rem
Rem $Header: dbmsfi.sql 25-sep-2003.22:41:40 weili Exp $
Rem
Rem dbmsfi.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsfi.sql - DBMS Frequent Itemset package Declaration
Rem
Rem    DESCRIPTION
Rem      Declaration for the frequent itemset package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    weili       09/25/03 - support NULL cursor 
Rem    weili       12/26/02 - create synonym for dbms_frequent_itemset
Rem    jihuang     12/20/02 - support any item type
Rem    weili       11/20/02 - weili_dbms_frequent_itemset
Rem    weili       11/07/02 - Created
Rem
/* the following object will be used by table functions
 * supporting anonymous item type 
 */
create or replace library ora_fi_lib trusted as static
/

CREATE OR REPLACE TYPE ora_fi_Imp_t AS OBJECT
(
  dummy NUMBER,

  STATIC FUNCTION ODCITableDescribe(typ OUT SYS.AnyType, cur SYS_REFCURSOR)
    RETURN PLS_INTEGER
  IS
  LANGUAGE C
  LIBRARY ora_fi_lib
  NAME "ODCITableDescribe"
  WITH CONTEXT
  PARAMETERS (
    CONTEXT,
    typ,
    typ INDICATOR,
    cur,
    cur TDO,
    RETURN INT
  )
);
/

CREATE or REPLACE PACKAGE dbms_frequent_itemset AUTHID CURRENT_USER AS

FUNCTION fi_transactional(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN SYS.AnyDataSet pipelined parallel_enable using ora_fi_Imp_t;
 
FUNCTION fi_horizontal(
  tranx_cursor          IN  SYS_REFCURSOR,
  support_threshold     IN  NUMBER,
  itemset_length_min    IN  NUMBER,
  itemset_length_max    IN  NUMBER,
  including_items       IN  SYS_REFCURSOR DEFAULT NULL,
  excluding_items       IN  SYS_REFCURSOR DEFAULT NULL)
RETURN SYS.AnyDataSet pipelined parallel_enable using ora_fi_Imp_t;


END;
/

CREATE or REPLACE PUBLIC SYNONYM dbms_frequent_itemset for sys.dbms_frequent_itemset
/

GRANT EXECUTE on dbms_frequent_itemset TO PUBLIC
/

GRANT EXECUTE on ora_fi_Imp_t TO PUBLIC
/
