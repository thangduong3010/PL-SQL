rem
rem $Header: rdbms/admin/dbmsgen.sql /st_rdbms_11.2.0/1 2013/06/27 15:11:01 jovillag Exp $ 
rem
Rem  Copyright (c) 1993, 1996, 1997, 1998 by Oracle Corporation 
Rem    NAME
Rem     dbmsgen.sql - Replication code generators.
Rem          
Rem    DESCRIPTION
Rem     Routines to generate shadow tables, triggers, and packages for
Rem     table replication.
Rem     Routines to generate wrappers for replication of standalone procedure
Rem     invocations, and packaged procedure invocations.
Rem     Routines which support generated replication code.  
Rem    
Rem    RETURNS
Rem     None
Rem     
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem      This package is installed by sys (connect internal).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     jovillag   05/28/13  - 16681267: Remove execute grant from
Rem                            dbms_reputil and dbms_reputil2 
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     rvenkate   01/30/01  - add bit() that returns number
Rem     liwong     11/22/00  - enhance bit
Rem     avaradar   12/20/98  - add gowner to ensure_normal_status              
Rem     liwong     05/04/98  - remove version in make_internal_pkg
Rem     liwong     02/11/98  - remove set_from_remote                          
Rem     liwong     12/17/97  - internal packages                               
Rem     jstamos    05/14/97 -  bug 493190: replace choose3 with get_final
Rem     jstamos    05/13/97 -  bug 433036: add more pure functions
Rem     sbalaram   04/27/97 -  add nchar procedures for append site and seq
Rem     jstamos    11/20/96 -  nchar support
Rem     jstamos    09/16/96 -  send on update/delete
Rem     jstamos    08/08/96 -  add LOBs to dbms_reputil2
Rem     ldoo       05/08/96 -  Add support for exp/imp replication triggers
Rem     jstamos    05/07/96 -  minimize update communication
Rem     ldoo       05/09/96 -  New security model
Rem     ldoo       02/13/96 -  Add a new parameter to rep_begin
Rem     ldoo       01/17/96 -  Replace replication_is_on with ugaknt
Rem     hasun      08/17/95 -  Add better quiesce check for all sync objects
Rem     hasun      06/01/95 -  merge changes from branch 1.4.720.3
Rem     hasun      04/20/95 -  Move package spec of dbms_defergen to prvtgen.sq
Rem     hasun      03/13/95 -  Fix checkin problems from last revision
Rem     ldoo       01/24/95 -  Modify trigger generator for Object Groups
Rem     jstamos    12/23/94 -  merge all changes from 7.2
Rem     jstamos    11/11/94 -  merge changes from branch 1.1.710.7
Rem     adowning   10/13/94 -  merge rev 1.1.710.4
Rem     adowning   09/21/94 -  improved comments
Rem     ldoo       08/18/94 -  Changed to use columns in the column group
Rem                            instead of parameter columns in the if
Rem                            ignore_discard_flag then section of user funcs.
Rem     adowning   08/10/94 -  Move dbms_maint_gen to prvt from dbms
Rem     ldoo       07/19/94 -  Took out FLOAT as a valid column datatype.
Rem     ldoo       06/23/94 -  Added automatic conflict resolution.
Rem     ldoo       05/09/94 -  Changed the generated trigger by replacing
Rem                            dbms_defer arg calls with dbms_reputil arg
Rem                            calls.  Hence reduce size and enhance speed.
Rem                            Added arg call procedures in dbms_reputil pkg.
Rem     ldoo       03/02/94 -  The argument$.type for ROWID is 69 not 11.
Rem                         -  Default for generate_wrapper_package.procedure_
Rem                            prefix should be NULL.
Rem                         -  Proper error message for attempt to wrap func.
Rem     ldoo       02/25/94 -  Fixed plsql parser bug workaround.
Rem                         -  Do not validate generate_trigger.package_name.
Rem     ldoo       02/18/94 -  Skip LONG and LONG RAW columns in row/col repl.
Rem                         -  Fixed hanging is_dest_node_provided function.
Rem     ldoo       02/17/94 -  Workaround plsql parser bug by adding () to
Rem                            every ten AND clauses in the generated package.
Rem     ldoo       01/21/94 -  Fixed to support mixed-case object names.
Rem     ldoo       01/18/94 -  Added 2 more in parameters to 
Rem                              generate_wrapper_package.
Rem                            Use array parsing.
Rem                            Removed commit statement.
Rem                            Replaced some functions with shared ones.
Rem     ldoo       12/17/93 -  Fixed bug about having extra ');' for
Rem                              column-level replication.
Rem                            Fixed bug about not preserving user-assigned
Rem                              package_name and trigger_name.  
Rem                            Uppercased 'p', '$rp', 't' and '$rt'.
Rem                            Validated IN parameter values.
Rem                            Defaulted USER if output_table is not prefixed
Rem                              with schema name.
Rem                            Double quoted column names in generated trigger.
Rem                            Modified already_exists() to use dba views. 
Rem                            Loop until generated package/trigger name is
Rem                              unique.
Rem     ldoo       10/18/93 -  Eliminated IN OUT parameters.  Supports Remote-
Rem                            Only, Synchronous, and Mixed Replications. 
Rem     dsdaniel   09/01/93 -  split into multiple packages, merged in dbmsrepu
Rem     ldoo       08/25/93 -  Coded to the 8/20 version of spec.
Rem     bsouder    08/13/93 -  minor beautification, corrected dbms_snapshot
Rem                            call
Rem     celsbern   08/13/93 -  added comments
Rem     ldoo	   08/13/93 -  Creation to RDBMS spec.

CREATE OR REPLACE PACKAGE dbms_reputil AS

  ------------
  --  OVERVIEW
  --
  --  This package is referenced only by the generated code.

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --

  FUNCTION from_remote
    RETURN BOOLEAN;
  -- in internal packages, we don't want to call PL/SQL to set from_remote,
  -- hence, convert from_remote to a function.
  -- clients are not supposed to assign values to this variable.

  FUNCTION global_name
    RETURN VARCHAR2;

  PROCEDURE set_global_name(gdbname  IN VARCHAR2);
  -- in internal packages, we don't want to call PL/SQL to set from_remote,
  -- hence, convert from_remote to a function.
  -- clients are not supposed to assign values to this variable.
  -- If they do, use set_from_remote(flag) instead.

  PROCEDURE replication_on;
  -- Turn on replication.

  PROCEDURE replication_off;
  -- Turn off replication.

  FUNCTION replication_is_on
    RETURN BOOLEAN;
  -- If false, do not forward/defer the update.

  --
  -- Common procedures and functions shared by Repcat, deferred RPC, etc.
  --
  PROCEDURE canonicalize(name       IN  VARCHAR2,
                         canon_name OUT VARCHAR2,
                         canon_len  IN  NUMBER);
  -- Canonicalize the string passed in as parameter name, determine the
  -- longest prefix that fits in canon_len bytes, and return the result in 
  -- canon_name.  Canonicalization is defined as follows.  If name is NULL,
  -- canon_name becomes NULL.  If name begins and ends with a double quote,
  -- remove both.  Otherwise, convert name to upper case with NLS_UPPER.

  --
  -- Automatic conflict resolution logic.
  --
  PROCEDURE recursion_on;
  -- Keep track of the number of recursion.  

  PROCEDURE recursion_off;
  -- The number of recursion is initialized to zero.

  PROCEDURE rep_begin(site_name IN VARCHAR2 default NULL);
  -- Initialization at the beginning of each rep_delete, rep_insert, and 
  -- rep_update.  It accepts the origin site name and assigns it to the
  -- session variable, ugakos, if ugakos has not been initialized.

  PROCEDURE rep_end;
  -- Clean up at the end of each rep_delete, rep_insert, and rep_update,
  -- including freeing up the memory that has been allocated to the session
  -- variable, ugakos.  

  FUNCTION get_constraint_name(errmsg IN VARCHAR2)
    RETURN VARCHAR2;
  -- Return the name of the uniqueness contraint in the ORA error message. 

  FUNCTION minimum(new                 IN  NUMBER,
                   cur                 IN  NUMBER,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new > cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION minimum(new                 IN  VARCHAR2,
                   cur                 IN  VARCHAR2,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new > cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION minimum(new                 IN  DATE,
                   cur                 IN  DATE,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new > cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION maximum(new                 IN  NUMBER,
                   cur                 IN  NUMBER,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new < cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION maximum(new                 IN  VARCHAR2,
                   cur                 IN  VARCHAR2,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new < cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION maximum(new                 IN  DATE,
                   cur                 IN  DATE,
                   ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- If new < cur, then ignore_discard_flag is TRUE; otherwise it is FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION average(new                 IN OUT NUMBER,
                   cur                 IN     NUMBER,
                   ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;
  -- Output new as the average of new + old.
  -- Ignore_discard_flag is always FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION additive(old                 IN     NUMBER,
                    new                 IN OUT NUMBER,
                    cur                 IN     NUMBER,
                    ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;
  -- Output new as cur + (new - old).  Ignore_discard_flag is always FALSE.
  -- Return FALSE if any input parameter is null; otherwise return TRUE.

  FUNCTION discard(ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- Ignore_discard_flag is always TRUE.
  -- Always return TRUE.

  FUNCTION overwrite(ignore_discard_flag OUT BOOLEAN)
    RETURN BOOLEAN;
  -- Ignore_discard_flag is always FALSE.
  -- Always return TRUE.

  FUNCTION append_site_name(new                 IN OUT VARCHAR2,
                            str                 IN     VARCHAR2,
                            max_len             IN     NUMBER,
                            ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;

  FUNCTION append_site_name_nc(new                 IN OUT NVARCHAR2,
                               str                 IN     VARCHAR2,
                               max_len             IN     NUMBER,
                               ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;
  -- Output new with str appended to it. Ignore_discard_flag is always FALSE.
  -- Return FALSE if any input parameter is null or the length of str plus one
  -- is greater than max_len; otherwise return TRUE.

  FUNCTION append_sequence(new                 IN OUT VARCHAR2,
                           max_len             IN     NUMBER,
                           ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;

  FUNCTION append_sequence_nc(new                 IN OUT NVARCHAR2,
                              max_len             IN     NUMBER,
                              ignore_discard_flag OUT    BOOLEAN)
    RETURN BOOLEAN;
  -- Output new with a sequence generated number appended to it.
  -- Ignore_discard_flag is always FALSE.  
  -- Return FALSE if any input parameter is null or the length of the generated
  -- number is greater than max_len; otherwise return TRUE.

  PROCEDURE enter_statistics(sname             IN VARCHAR2,
                             oname             IN VARCHAR2,
                             conflict_type     IN VARCHAR2,
                             reference_name    IN VARCHAR2,
                             method_name       IN VARCHAR2,
                             function_name     IN VARCHAR2,
                             priority_group    IN VARCHAR2,
                             primary_key_value IN VARCHAR2,
                             resolved_date     IN DATE default SYSDATE);
  -- Record that the given conflict has been resolved with the given
  -- resolution.
  -- Input parameters:
  --  sname The name of the schema containing the table to be replicated.
  --  oname The name of the table being replicated.
  --  conflict_type The type of conflict.  Valid values are: `UPDATE',
  --    `UNIQUENESS', and `DELETE'.
  --  reference_name If the conflict type is 'DELETE', enter the replicated
  --    table name here.  If the conflict type is `UPDATE', enter the column
  --    group name here.  If the conflict type is `UNIQUE CONSTRAINT', enter
  --    the unique constraint name here.
  --  method_name The conflict resolution method.
  --  function_name If the method is 'USER FUNCTION', enter the user
  --    resolution function name here.
  --  priority_group If the method is `PRIORITY GROUP', enter the name of
  --    priority group used for resolving the conflict.
  --  primary_key_value The primary key value for the row whose conflict is
  --    being resolved.  
  --  resolved_date The date at which the conflict is resolved.  

  PROCEDURE ensure_normal_status(canon_gname IN VARCHAR2,
                                 canon_gowner IN VARCHAR2 default 'PUBLIC');
  --- Raise exception quiesced_num (-23311) if the status of the object group
  --- is not normal.

  PROCEDURE raw_to_varchar2(r      IN  RAW,
                            offset IN  BINARY_INTEGER,
                            v      OUT VARCHAR2);
  -- Select the "offset" bit in each byte of r, map a 0 to 'N' and a 1 to 'Y',
  -- and put the result in v.  Offset is 1-based and must be between 1 and 8,
  -- inclusive.

  PROCEDURE make_internal_pkg(canon_sname IN VARCHAR2,
                              canon_oname IN VARCHAR2);
  -- Routine that ensures that repcat$_repobject.flag is correct for the given
  -- table with respect to internal pkgs.

  FUNCTION import_rep_trigger_string(arg IN VARCHAR2)
    RETURN VARCHAR2;
  -- Routine in sys.expact$ that generates a PL/SQL string that calls
  -- sync_up_rep.

  PROCEDURE sync_up_rep(canon_sname IN VARCHAR2,
                        canon_oname IN VARCHAR2);
  -- Routine that ensures that sys.tab$.trigflag is correct for the given
  -- table.

END dbms_reputil;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_reputil FOR dbms_reputil
/

CREATE OR REPLACE PACKAGE dbms_reputil2 AS

  ------------
  --  OVERVIEW
  --
  --  This package is referenced only by the generated code
  --  and needs higher purity than the code in dbms_reputil.

  FUNCTION bit(flag       IN RAW,
               byte       IN NUMBER,
               bit_offset IN NUMBER) RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(bit, WNPS, RNDS, WNDS);
  -- Test a bit in a byte in a raw.  Byte and bit_offset are 1-based.

  FUNCTION bit(flag       IN RAW,
               bit_offset IN NUMBER) RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(bit, WNPS, RNDS, WNDS);
  -- Test a bit in a raw. Bit_offset is 1-based.

  -- same 2 functions above but returns number for use in SQL
  -- changed args ordering in order to override. SQL cannot choose between
  -- return boolean and return number
  FUNCTION bit(byte       IN NUMBER,
               bit_offset IN NUMBER, 
               flag       IN RAW) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(bit, WNPS, RNDS, WNDS);
  -- Test a bit in a byte in a raw.  Byte and bit_offset are 1-based.

  FUNCTION bit(bit_offset IN NUMBER, 
               flag       IN RAW) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(bit, WNPS, RNDS, WNDS);
  -- Test a bit in a raw. Bit_offset is 1-based.

  PROCEDURE bis(flag       IN OUT RAW,
                bit_offset IN     NUMBER);
  PRAGMA RESTRICT_REFERENCES(bis, WNPS, RNDS, WNDS);
  -- Set a bit in a one-byte raw.  Bit_offset is 1-based.

  PROCEDURE bic(flag       IN OUT RAW,
                bit_offset IN     NUMBER);
  PRAGMA RESTRICT_REFERENCES(bic, WNPS, RNDS, WNDS);
  -- Clear a bit in a one-byte raw.  Bit_offset is 1-based.

  FUNCTION choose_number(old  IN NUMBER,
                         new  IN NUMBER,
                         flag IN VARCHAR2,
                         byte IN NUMBER) RETURN NUMBER;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_number, WNPS, RNDS, WNDS);

  FUNCTION choose_date(old  IN DATE,
                       new  IN DATE,
                       flag IN VARCHAR2,
                       byte IN NUMBER) RETURN DATE;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_date, WNPS, RNDS, WNDS);

  FUNCTION choose_varchar2(old  IN VARCHAR2,
                           new  IN VARCHAR2,
                           flag IN VARCHAR2,
                           byte IN NUMBER) RETURN VARCHAR2;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_varchar2, WNPS, RNDS, WNDS);

  FUNCTION choose_nvarchar2(old  IN NVARCHAR2,
                            new  IN NVARCHAR2,
                            flag IN VARCHAR2,
                            byte IN NUMBER) RETURN NVARCHAR2;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_nvarchar2, WNPS, RNDS, WNDS);

  FUNCTION choose_char(old  IN CHAR,
                       new  IN CHAR,
                       flag IN VARCHAR2,
                       byte IN NUMBER) RETURN CHAR;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_char, WNPS, RNDS, WNDS);

  FUNCTION choose_nchar(old  IN NCHAR,
                        new  IN NCHAR,
                        flag IN VARCHAR2,
                        byte IN NUMBER) RETURN NCHAR;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_nchar, WNPS, RNDS, WNDS);

  FUNCTION choose_rowid(old  IN ROWID,
                        new  IN ROWID,
                        flag IN VARCHAR2,
                        byte IN NUMBER) RETURN ROWID;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_rowid, WNPS, RNDS, WNDS);

  FUNCTION choose_raw(old  IN RAW,
                      new  IN RAW,
                      flag IN VARCHAR2,
                      byte IN NUMBER) RETURN RAW;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_raw, WNPS, RNDS, WNDS);

  FUNCTION choose_blob(old  IN BLOB,
                       new  IN BLOB,
                       flag IN VARCHAR2,
                       byte IN NUMBER) RETURN BLOB;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_blob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION choose_clob(old  IN CLOB,
                       new  IN CLOB,
                       flag IN VARCHAR2,
                       byte IN NUMBER) RETURN CLOB;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_clob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION choose_nclob(old  IN NCLOB,
                        new  IN NCLOB,
                        flag IN VARCHAR2,
                        byte IN NUMBER) RETURN NCLOB;
  -- If flag is null or substr(flag,byte,1) = 'Y' then return new
  -- else return old.
  PRAGMA RESTRICT_REFERENCES(choose_nclob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_varchar2_equals_new(column_changed$_varchar2 IN VARCHAR2,
                                   offset                   IN NUMBER,
                                   old                      IN VARCHAR2
                                                               CHARACTER SET
                                                               ANY_CS,
                                   new                      IN VARCHAR2
                                                               CHARACTER SET
                                                               old%CHARSET)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_varchar2_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_char_equals_new(column_changed$_varchar2 IN VARCHAR2,
                               offset                   IN NUMBER,
                               old                      IN CHAR CHARACTER SET
                                                           ANY_CS,
                               new                      IN CHAR CHARACTER SET
                                                           old%CHARSET)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_char_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_rowid_equals_new(column_changed$_varchar2 IN VARCHAR2,
                                offset                IN NUMBER,
                                old                   IN ROWID,
                                new                   IN ROWID)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_rowid_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_date_equals_new(column_changed$_varchar2 IN VARCHAR2,
                               offset                   IN NUMBER,
                               old                      IN DATE,
                               new                      IN DATE)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_date_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_raw_equals_new(column_changed$_varchar2 IN VARCHAR2,
                              offset                   IN NUMBER,
                              old                      IN RAW,
                              new                      IN RAW)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_raw_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_number_equals_new(column_changed$_varchar2 IN VARCHAR2,
                                 offset                   IN NUMBER,
                                 old                      IN NUMBER,
                                 new                      IN NUMBER)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_number_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_clob_equals_new(column_changed$_varchar2 IN VARCHAR2,
                               offset                   IN NUMBER,
                               old                      IN CLOB CHARACTER SET
                                                           ANY_CS,
                               new                      IN CLOB CHARACTER SET
                                                           old%CHARSET)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_clob_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_blob_equals_new(column_changed$_varchar2 IN VARCHAR2,
                               offset                   IN NUMBER,
                               old                      IN BLOB,
                               new                      IN BLOB)
    RETURN VARCHAR2;
  -- If old and new are identical then return 'Y' else return 'N.'
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_blob_equals_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_varchar2_eq_new(column_changed$_varchar2 IN VARCHAR2,
                               offset                   IN NUMBER,
                               old                      IN VARCHAR2
                                                           CHARACTER SET
                                                           ANY_CS,
                               new                      IN VARCHAR2
                                                           CHARACTER SET
                                                           old%CHARSET)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_varchar2_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_char_eq_new(column_changed$_varchar2 IN VARCHAR2,
                           offset                   IN NUMBER,
                           old                      IN CHAR CHARACTER SET
                                                       ANY_CS,
                           new                      IN CHAR CHARACTER SET
                                                       old%CHARSET)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_char_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_date_eq_new(column_changed$_varchar2 IN VARCHAR2,
                           offset                   IN NUMBER,
                           old                      IN DATE,
                           new                      IN DATE)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_date_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_rowid_eq_new(column_changed$_varchar2 IN VARCHAR2,
                            offset                   IN NUMBER,
                            old                      IN ROWID,
                            new                      IN ROWID)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_rowid_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_raw_eq_new(column_changed$_varchar2 IN VARCHAR2,
                          offset                   IN NUMBER,
                          old                      IN RAW,
                          new                      IN RAW)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_raw_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_number_eq_new(column_changed$_varchar2 IN VARCHAR2,
                             offset                   IN NUMBER,
                             old                      IN NUMBER,
                             new                      IN NUMBER)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_number_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_clob_eq_new(column_changed$_varchar2 IN VARCHAR2,
                           offset                   IN NUMBER,
                           old                      IN CLOB CHARACTER SET
                                                       ANY_CS,
                           new                      IN CLOB CHARACTER SET
                                                       old%CHARSET)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_clob_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_blob_eq_new(column_changed$_varchar2 IN VARCHAR2,
                           offset                   IN NUMBER,
                           old                      IN BLOB,
                           new                      IN BLOB)
    RETURN BOOLEAN;
  -- If old and new are identical then return true else return false.
  -- Use column_changed$_varchar2 if not null.
  -- Otherwise use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_blob_eq_new, RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_varchar2_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                       offset                IN NUMBER,
                                       old                   IN VARCHAR2
                                                                CHARACTER SET
                                                                ANY_CS,
                                       current               IN VARCHAR2
                                                                CHARACTER SET
                                                                old%CHARSET)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_varchar2_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_char_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                   offset                IN NUMBER,
                                   old                   IN CHAR CHARACTER SET
                                                            ANY_CS,
                                   current               IN CHAR CHARACTER SET
                                                            old%CHARSET)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_char_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_raw_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                  offset                IN NUMBER,
                                  old                   IN RAW,
                                  current               IN RAW)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_raw_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_rowid_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                    offset                IN NUMBER,
                                    old                   IN ROWID,
                                    current               IN ROWID)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_rowid_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_date_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                   offset                IN NUMBER,
                                   old                   IN DATE,
                                   current               IN DATE)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_date_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_number_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                     offset                IN NUMBER,
                                     old                   IN NUMBER,
                                     current               IN NUMBER)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_number_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_blob_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                   offset                IN NUMBER,
                                   old                   IN BLOB,
                                   current               IN BLOB)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_blob_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_clob_equals_current(column_sent$_varchar2 IN VARCHAR2,
                                   offset                IN NUMBER,
                                   old                   IN CLOB CHARACTER SET
                                                            ANY_CS,
                                   current               IN CLOB CHARACTER SET
                                                            old%CHARSET)
    RETURN VARCHAR2;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_clob_equals_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_varchar2_eq_current(column_sent$_varchar2 IN VARCHAR2,
                                   offset                IN NUMBER,
                                   old                   IN VARCHAR2
                                                            CHARACTER SET
                                                            ANY_CS,
                                   current               IN VARCHAR2
                                                            CHARACTER SET
                                                            old%CHARSET)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_varchar2_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_char_eq_current(column_sent$_varchar2 IN VARCHAR2,
                               offset                IN NUMBER,
                               old                   IN CHAR CHARACTER SET
                                                        ANY_CS,
                               current               IN CHAR CHARACTER SET
                                                        old%CHARSET)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_char_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_raw_eq_current(column_sent$_varchar2 IN VARCHAR2,
                              offset                IN NUMBER,
                              old                   IN RAW,
                              current               IN RAW)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_raw_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_rowid_eq_current(column_sent$_varchar2 IN VARCHAR2,
                                offset                IN NUMBER,
                                old                   IN ROWID,
                                current               IN ROWID)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_rowid_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_date_eq_current(column_sent$_varchar2 IN VARCHAR2,
                               offset                IN NUMBER,
                               old                   IN DATE,
                               current               IN DATE)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_date_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_number_eq_current(column_sent$_varchar2 IN VARCHAR2,
                                 offset                IN NUMBER,
                                 old                   IN NUMBER,
                                 current               IN NUMBER)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_number_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_clob_eq_current(column_sent$_varchar2 IN VARCHAR2,
                               offset                IN NUMBER,
                               old                   IN CLOB CHARACTER SET
                                                        ANY_CS,
                               current               IN CLOB CHARACTER SET
                                                        old%CHARSET)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_clob_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION old_blob_eq_current(column_sent$_varchar2 IN VARCHAR2,
                               offset                IN NUMBER,
                               old                   IN BLOB,
                               current               IN BLOB)
    RETURN BOOLEAN;
  -- If column_sent$_varchar2 is NULL, return 'Y.'
  -- If old and current are identical then return 'Y' else return 'N.'
  -- Use equality and null checks.
  PRAGMA RESTRICT_REFERENCES(old_blob_eq_current,
                             RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_varchar2(column_changed$_varchar2 IN VARCHAR2,
                              offset                   IN NUMBER, 
                              current                  IN VARCHAR2 CHARACTER
                                                          SET ANY_CS,
                              old                      IN VARCHAR2
                                                          CHARACTER SET
                                                          "CURRENT"%CHARSET,
                              new                      IN VARCHAR2
                                                          CHARACTER SET
                                                          "CURRENT"%CHARSET)
    RETURN VARCHAR2 CHARACTER SET "CURRENT"%CHARSET;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_varchar2, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_char(column_changed$_varchar2 IN VARCHAR2,
                          offset                   IN NUMBER, 
                          current                  IN CHAR CHARACTER SET
                                                      ANY_CS,
                          old                      IN CHAR CHARACTER SET
                                                      "CURRENT"%CHARSET,
                          new                      IN CHAR CHARACTER SET
                                                      "CURRENT"%CHARSET)
    RETURN CHAR CHARACTER SET "CURRENT"%CHARSET;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_char, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_rowid(column_changed$_varchar2 IN VARCHAR2,
                           offset                   IN NUMBER, 
                           current                  IN ROWID,
                           old                      IN ROWID,
                           new                      IN ROWID)
    RETURN ROWID;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_rowid, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_date(column_changed$_varchar2 IN VARCHAR2,
                          offset                   IN NUMBER, 
                          current                  IN DATE,
                          old                      IN DATE,
                          new                      IN DATE)
    RETURN DATE;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_date, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_raw(column_changed$_varchar2 IN VARCHAR2,
                         offset                   IN NUMBER, 
                         current                  IN RAW,
                         old                      IN RAW,
                         new                      IN RAW)
    RETURN RAW;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_raw, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_number(column_changed$_varchar2 IN VARCHAR2,
                            offset                   IN NUMBER,
                            current                  IN NUMBER,
                            old                      IN NUMBER,
                            new                      IN NUMBER)
    RETURN NUMBER;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_number, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_lob(column_changed$_char     IN CHAR,
                         current                  IN CLOB CHARACTER SET
                                                     ANY_CS,
                         new                      IN CLOB CHARACTER SET 
                                                     "CURRENT"%CHARSET)
    RETURN CLOB CHARACTER SET "CURRENT"%CHARSET;
  -- column_changed$_char is non NULL
  -- returns new if and only if column_changed$_char is 'Y'
  PRAGMA RESTRICT_REFERENCES(get_final_lob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_lob(column_changed$_char     IN CHAR,
                         current                  IN BLOB,
                         new                      IN BLOB)
    RETURN BLOB;
  -- column_changed$_char is non NULL
  -- returns new if and only if column_changed$_char is 'Y'
  PRAGMA RESTRICT_REFERENCES(get_final_lob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_clob(column_changed$_varchar2 IN VARCHAR2,
                          offset                   IN NUMBER, 
                          current                  IN CLOB CHARACTER SET
                                                      ANY_CS,
                          old                      IN CLOB CHARACTER SET
                                                      "CURRENT"%CHARSET,
                          new                      IN CLOB CHARACTER SET 
                                                      "CURRENT"%CHARSET)
    RETURN CLOB CHARACTER SET "CURRENT"%CHARSET;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_clob, RNPS, WNPS, RNDS, WNDS);

  FUNCTION get_final_blob(column_changed$_varchar2 IN VARCHAR2,
                          offset                   IN NUMBER, 
                          current                  IN BLOB,
                          old                      IN BLOB,
                          new                      IN BLOB)
    RETURN BLOB;
  -- If old and new are identical, then return current else return new.
  -- Use column_changed$_varchar2 if non-null.
  PRAGMA RESTRICT_REFERENCES(get_final_blob, RNPS, WNPS, RNDS, WNDS);

END dbms_reputil2;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_reputil2 FOR dbms_reputil2
/

