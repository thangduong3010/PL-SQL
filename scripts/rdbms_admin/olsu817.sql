Rem
Rem $Header: olsu817.sql 08-feb-2003.13:39:34 srtata Exp $
Rem
Rem olsu817.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      olsu817.sql - OLS Upgrade from Oracle 8.1.7
Rem
Rem    DESCRIPTION
Rem      Upgrade OLS installed in Oracle 8.1.7 to OLS 9.0.0.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem      Immediately after this script you must run $ORACLE_HOME/admin/utlrp
Rem      as SYSDBA to validate invalid OLS objects. Then you must shutdown
Rem      and restart the database instance. 
Rem
Rem      Do not shutdown and restart the instance before running utlrp.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      02/08/03 - remove aud$ changes
Rem    srtata      10/24/02 - move scripts that reload packages to olsdbmig.sql
Rem    shwong      01/14/02 - grant execute on dbms_registry to lbacsys.
Rem    rburns      10/31/01 - add dbms_registry call
Rem    gmurphy     05/03/01 - modify aud$
Rem    gmurphy     04/24/01 - ugrade lbac_bin_label type
Rem    gmurphy     04/13/01 - alter lbac_label for 64 bit ports
Rem    gmurphy     04/12/01 - remove utlirp
Rem    vpesati     04/11/01 - remove spooling
Rem    gmurphy     04/08/01 - add spool file
Rem    gmurphy     04/06/01 - change for SYSDBA upgrade
Rem    gmurphy     03/07/01 - Merged gmurphy_clean_scripts
Rem    gmurphy     03/06/01 - Created
Rem

analyze table system.AUD$ estimate statistics;

-------------------------------------------------------------------------
-- Drop and recreate lbac_bin_label due to changed type spec

-- Drop columns from tables using the type
ALTER TABLE LBACSYS.lbac$lab DROP COLUMN blabel;

-- Drop type.
DROP TYPE LBACSYS.lbac_bin_label;

-- Recreate specification for the type
CREATE OR REPLACE TYPE LBACSYS.lbac_bin_label OID '6619848A7F9C2205E034000077904948'
AS OPAQUE VARYING(*)
USING LIBRARY LBACSYS.lbac$type_libt
(
--  The LBAC_BIN_LABEL type contains the binary label, as well as a label
--  size and an identifier for the associated policy.  The interpretation
--  of the label is made by each policy package.  As for the LBAC_LABEL
--  type, the RAW binary value is used for standard comparisons.
--
--  The type methods include functions to extract portions of the label, 
--  functions to manipulate the bits within the label, and functions to 
--  test the bit settings.
--
-- Constructor  
  STATIC FUNCTION new_lbac_bin_label (policy_id IN PLS_INTEGER,
                                      bin_size IN PLS_INTEGER)
  RETURN LBAC_BIN_LABEL,
  PRAGMA RESTRICT_REFERENCES(new_lbac_bin_label, RNDS, WNDS, RNPS, WNPS),
--
-- Equality tests for lookup in lbac$lab
  MEMBER FUNCTION eq_sql (SELF IN lbac_bin_label,
                          comp_label IN lbac_bin_label)
  RETURN PLS_INTEGER DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),
--
  MEMBER FUNCTION eq (SELF IN lbac_bin_label,
                       comp_label IN lbac_bin_label)
  RETURN BOOLEAN DETERMINISTIC,
  PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS),
--
-- Size of binary_label portion 
  MEMBER FUNCTION bin_size (SELF IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(bin_size, RNDS, WNDS, RNPS, WNPS),
--
-- Procedures and Functions to store values into the binary label
--
  MEMBER FUNCTION set_raw (SELF      IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            raw_label IN RAW)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_raw, RNDS, WNDS, RNPS, WNPS),
--
  MEMBER FUNCTION set_int (SELF IN OUT NOCOPY lbac_bin_label, 
                            position  IN PLS_INTEGER,
                            byte_len  IN PLS_INTEGER,
                            int_label IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(set_int, RNDS, WNDS, RNPS, WNPS),
--
--
-- Functions to test the contents on the binary label
--
-- Functions to extract the contents of the binary label
--
  MEMBER FUNCTION  to_raw (SELF     IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN RAW,
  PRAGMA RESTRICT_REFERENCES(to_raw, RNDS, WNDS, RNPS, WNPS),
--
  MEMBER FUNCTION to_int (SELF     IN lbac_bin_label, 
                           position IN PLS_INTEGER,
                           byte_len IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(to_int, RNDS, WNDS, RNPS, WNPS),
--
  MEMBER FUNCTION policy_id (SELF   IN lbac_bin_label)
  RETURN PLS_INTEGER,
  PRAGMA RESTRICT_REFERENCES(policy_id, RNDS, WNDS, RNPS, WNPS)
)
/
show errors

-- Add columns to tables using the type
ALTER TABLE LBACSYS.lbac$lab ADD blabel LBACSYS.lbac_bin_label;

-------------------------------------------------------------------------
-- Alter lbac_label type for 64 bit porting.
ALTER TYPE LBACSYS.lbac_label REPLACE
AS OPAQUE VARYING(3889)
USING LIBRARY LBACSYS.lbac$label_libt
(
--  The LBAC_LABEL type contains a 4 byte numeric representation of a binary
--  label.  It provides an index into the LBAC$LAB table to locate the
--  corresponding binary label.
--
-- The MAP member function returns the binary label in numberform for
-- standard Oracle comparisons.  
--
-- BUG 1718582 requires the lbac_label size to be less than 3890 on
-- 64 bit platforms. Due to other overheads in opaque type lbac_label
-- size of 3890 works out to be 3897 on Solaris 32 bit platform
--
-- The code in kkbo.c is checking if the size > slal4d(3900) and this
-- results in a different behavior on 64 bit platforms. With 8 byte
-- alignment slal4d(3900) works out to 3896 resulting in column being
-- stored in a LOB thus causing this bug. Using 3889 works on HP 64 bit
-- platform
--
-- Constructor
   STATIC FUNCTION new_lbac_label(num IN PLS_INTEGER)
   RETURN lbac_label,
   PRAGMA RESTRICT_REFERENCES(new_lbac_label, RNDS, WNDS, RNPS, WNPS),
--
-- Map method
   MAP MEMBER FUNCTION lbac_label_map
   RETURN PLS_INTEGER DETERMINISTIC,
--
-- For lookup in lbac$lab
   MEMBER FUNCTION eq_sql (SELF IN lbac_label,
                           comp_label IN lbac_label)
   RETURN PLS_INTEGER,
   PRAGMA RESTRICT_REFERENCES(eq_sql, RNDS, WNDS, RNPS, WNPS),
--
   MEMBER FUNCTION eq (SELF IN lbac_label,
                       comp_label IN lbac_label)
   RETURN BOOLEAN,
   PRAGMA RESTRICT_REFERENCES(eq, RNDS, WNDS, RNPS, WNPS),
--
-- Converts label to integer tag
   MEMBER FUNCTION to_tag(SELF IN lbac_label)
   RETURN PLS_INTEGER DETERMINISTIC,
   PRAGMA RESTRICT_REFERENCES(to_tag, RNDS, WNDS, RNPS, WNPS)
)
/
show errors;
-------------------------------------------------------------------------

-- Call 901 upgrade script.

@@olsu901.sql

