Rem
Rem $Header: catreplt.sql 23-oct-2006.14:29:47 elu      Exp $
Rem
Rem catreplt.sql
Rem
Rem Copyright (c) 2006, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      catreplt.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    elu         10/23/06 - Created
Rem

CREATE TYPE system.repcat$_object_null_vector AS OBJECT
(
  -- type owner, name, hashcode for the type represented by null_vector
  type_owner      VARCHAR2(30),
  type_name       VARCHAR2(30),
  type_hashcode   RAW(17),
  -- null_vector for a particular object instance
  -- ROBJ REVISIT: should only contain the null image, and not version#
  null_vector     RAW(2000)
)
/

Rem ==========================================================================
Rem TYPES
Rem ==========================================================================

-- Define a type which will be used to perfom bitors of raw columns
CREATE OR REPLACE TYPE MVAggRawBitOr_typ AS OBJECT (
 current_bitvec        RAW(255),
 current_bitvec_len    NUMBER,
 
 STATIC FUNCTION odciaggregateinitialize(sctx OUT MVAggRawBitOr_typ)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregateiterate(self    IN OUT MVAggRawBitOr_typ,
                                      bitvec  IN     RAW)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregateterminate(self    IN OUT MVAggRawBitOr_typ,
                                        bitvec  OUT    RAW,
                                        flags   IN     NUMBER)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregatemerge(self     IN OUT MVAggRawBitOr_typ,
                                    agg_obj  IN     MVAggRawBitOr_typ)
    RETURN NUMBER
);
/

CREATE OR REPLACE FUNCTION MVAggRawBitOr(bitvec RAW) RETURN RAW
PARALLEL_ENABLE
AGGREGATE USING MVAggRawBitOr_typ;
/

GRANT EXECUTE ON MVAggRawBitOr TO PUBLIC;
/
