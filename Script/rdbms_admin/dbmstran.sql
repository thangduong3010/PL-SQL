Rem
Rem $Header: rdbms/admin/dbmstran.sql /main/12 2009/06/02 10:34:17 liaguo Exp $
Rem
Rem dbmstrans.sql
Rem
Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmstrans.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Transactions Package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    liaguo      05/28/09 - rename disassociate_fba
Rem    liaguo      06/02/08 - Add Flashback Archive package
Rem    liaguo      03/17/08 - add fda plsql temporarily
Rem    vakrishn    10/25/06 - move the insert for GMT as creation value
Rem                           from dbmstran.sql to dtxnspc.bsq
Rem    mabhatta    09/06/06 - moving v$flashback_txn_* views to cdfixed
Rem    mabhatta    08/15/06 - added v$flashback_txn_* views
Rem    mabhatta    04/15/06 - added transaction backout to dbms_flashback 
Rem    vakrishn    01/19/06 - (lrg 1960912 - checked in as part of lrg 1960928)
Rem                            add Flashback Timezone in props$ 
Rem    akalra      12/30/02 - provide time-scn mapping functions
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    akalra      01/17/01 - grant execute priv. only to dba.
Rem    ssvemuri    09/21/00 - ICDs to trusted callouts.
Rem    amganesh    09/15/00 - diffs fix.
Rem    amganesh    09/15/00 - 
Rem    amganesh    09/12/00 - Created
Rem
create or replace package dbms_flashback AUTHID CURRENT_USER as

 ----------------
 -- OVERVIEW
 -- Procedures for enabling and disabling dbms_flashback.
 --
 ---------------------------
 -- PROCEDURES AND FUNCTIONS

procedure enable_at_time(query_time in TIMESTAMP);
procedure enable_at_system_change_number(query_scn in NUMBER);
procedure disable;
function  get_system_change_number return NUMBER;

-- Transaction backout constants
nocascade        constant binary_integer := 1;
nocascade_force  constant binary_integer := 2;
nonconflict_only constant binary_integer := 3;
cascade          constant binary_integer := 4;

-- Transaction backout interfaces
procedure transaction_backout(numtxns number, 
                              xids    xid_array,
                              options binary_integer default nocascade,
                              scnhint number         default 0);
procedure transaction_backout(numtxns  number, 
                              xids     xid_array,
                              options  binary_integer default nocascade,
                              timehint timestamp);
procedure transaction_backout(numTxns number,
                              names   txname_array,
                              options binary_integer default nocascade,
                              scnhint number         default 0);
procedure transaction_backout(numTxns  number,
                              names    txname_array,
                              options  binary_integer default nocascade,
                              timehint timestamp);

end;
/
create or replace public synonym dbms_flashback for sys.dbms_flashback
/
grant execute on dbms_flashback to dba
/
CREATE OR REPLACE LIBRARY dbms_tran_lib trusted as static
/

create or replace function timestamp_to_scn(query_time IN TIMESTAMP)
return NUMBER
IS EXTERNAL
NAME "ktfexttoscn"
WITH CONTEXT
PARAMETERS(context,
           query_time OCIDATETIME,
           RETURN)
LIBRARY DBMS_TRAN_LIB;
/

create or replace function scn_to_timestamp(query_scn IN NUMBER)
return TIMESTAMP
IS EXTERNAL
NAME "ktfexscntot"
WITH CONTEXT
PARAMETERS(context,
           query_scn OCINUMBER,
           RETURN)
LIBRARY DBMS_TRAN_LIB;
/

create or replace public synonym timestamp_to_scn for sys.timestamp_to_scn
/
create or replace public synonym scn_to_timestamp for sys.scn_to_timestamp
/
grant execute on timestamp_to_scn to PUBLIC
/
grant execute on scn_to_timestamp to PUBLIC
/

-----------------------------------------------------------------------
-- DBMS_FLASHBACK_ARCHIVE
-----------------------------------------------------------------------
create or replace package dbms_flashback_archive AUTHID CURRENT_USER as

-- FDA Disassociation  
procedure disassociate_fba(owner_name VARCHAR2, table_name VARCHAR2);
procedure reassociate_fba(owner_name VARCHAR2, table_name VARCHAR2);

end;
/

create or replace public synonym dbms_flashback_archive for sys.dbms_flashback_archive
/

grant execute on dbms_flashback_archive to dba
/

CREATE OR REPLACE LIBRARY dbms_fda_lib trusted as static
/
