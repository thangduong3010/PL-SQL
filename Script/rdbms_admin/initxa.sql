variable jvmrmaction varchar2(30)
execute :jvmrmaction := 'FULL_REMOVAL';
@@jvmrmxa

-- --------------------------------
-- Create the Package
-- --------------------------------

create or replace package JAVA_XA authid current_user as
-- create or replace package JAVA_XA as

   function xa_start (xid_bytes IN RAW, timeout IN NUMBER, 
                      flag IN NUMBER, status OUT NUMBER) 
   return RAW;

   function xa_start_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW,
                          timeout IN NUMBER, flag IN NUMBER)
   return number;

   function xa_end (xid_bytes IN RAW, flag IN NUMBER) 
   return number;

   function xa_end_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW,
                        flag IN NUMBER) 
   return number;

   function xa_commit (xid_bytes IN RAW, commit IN NUMBER, stateout OUT NUMBER)
   return number;

   function xa_commit_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW, 
                           commit IN NUMBER)
   return number;

   function xa_rollback (xid_bytes IN RAW, stateout OUT NUMBER) 
   return number;

   function xa_rollback_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number;

   function xa_forget (xid_bytes IN RAW, stateout OUT NUMBER) 
   return number;

   function xa_forget_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number;

   function xa_prepare (xid_bytes IN RAW, stateout OUT NUMBER) 
   return number;       

   function xa_prepare_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number;       

   function xa_doTwophase (isFinal IN NUMBER, inBytes IN long RAW) 
   return number;

   function xa_thinTwophase (inBytes IN long RAW) 
   return number;

   pragma restrict_references(default, RNPS, WNPS, RNDS, WNDS, trust);

end;
/

REM -------------------------
REM Create the body
REM -------------------------

create or replace package body JAVA_XA as

   function xa_start (xid_bytes IN RAW, timeout IN NUMBER, flag IN NUMBER, status OUT NUMBER) 
   return RAW as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.start(byte[], int, int, int []) return byte []';


   function xa_start_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW,
                          timeout IN NUMBER, flag IN NUMBER)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.start(int, byte[], byte[],int, int) return int';

   function xa_end (xid_bytes IN RAW, flag IN NUMBER) 
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.end (byte[], int) 
                        return int';

   function xa_end_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW,
                        flag IN NUMBER) 
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.end (int, byte[], byte[], int) 
                        return int';


   function xa_commit (xid_bytes IN RAW, commit IN NUMBER, stateout OUT NUMBER)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.commit (byte[], int, int[]) return int';

   function xa_commit_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW, 
                           commit IN NUMBER)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.commit (int, byte[], byte[], int) return int';


   function xa_rollback (xid_bytes IN RAW, stateout OUT NUMBER) 
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.rollback (byte[], int[]) return int';

   function xa_rollback_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.rollback (int, byte[], byte[]) return int';


   function xa_forget ( xid_bytes IN RAW, stateout OUT NUMBER) 
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.forget (byte[], int[] ) return int';

   function xa_forget_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.forget (int, byte[], byte[]) return int';

   function xa_prepare (xid_bytes IN RAW, stateout OUT NUMBER) 
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.prepare (byte[], int[]) return int';

   function xa_prepare_new (formatId IN NUMBER, gtrid IN RAW, bqual  IN RAW)
   return number as language java
   name 'oracle.jdbc.xa.server.OracleWrapXAResource.prepare(int, byte[], byte[]) return int';

   function xa_doTwophase (isFinal IN NUMBER, inBytes IN LONG RAW)
     return number as language java name 
   'oracle.jdbc.xa.server.OracleWrapXAResource.doTwoPhase (int, byte[]) 
    return int';

    function xa_thinTwophase (inBytes IN LONG RAW)
     return number as language java name 
   'oracle.jdbc.xa.server.OracleWrapXAResource.stepThinTwophase (byte[]) 
    return int';

end;
/

create public synonym JAVA_XA for JAVA_XA;
grant execute on JAVA_XA to public ;

