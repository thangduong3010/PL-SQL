Rem
Rem $Header: rdbms/demo/schema/order_entry/coe_xml.sql /st_rdbms_11.2.0/1 2012/03/28 22:32:42 bhammers Exp $
Rem
Rem coe_xml.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      coe_xml.sql - Create XML DB data for user OE
Rem
Rem    DESCRIPTION
Rem      Create XML DB data for user OE
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/27/12 - Backport bhammers_mdrakebugs from main
Rem    cbauwens    02/24/05 - drop 2 more xdb objects after xml schema creation
Rem    cbauwens    08/04/04 - drop xdb packages after xml schema creation 
Rem    cbauwens    03/16/04 - enhanced xml shema 
Rem    cbauwens    12/23/03 - 
Rem    cbauwens    10/28/03 - set nls_numeric_characters 
Rem    ahunold     02/13/03 - typo: REFERENCE_IS_UNQIUE
Rem    ahunold     10/12/02 - revoke ANY DIRECTORY privilege when done
Rem    ahunold     10/07/02 - Created
Rem

PROMPT 
PROMPT specify password for OE as parameter 1:
DEFINE pass_oe  = &1
PROMPT
PROMPT PROMPT password for SYS as parameter 2:
DEFINE pass_sys = &2
PROMPT


--
-- CONNECT as SYS. Add roles AND privileges to OE.
--
CONNECT sys/&pass_sys AS SYSDBA;


GRANT xdbadmin TO oe;
GRANT create any directory TO oe; 
GRANT drop any directory TO oe;
GRANT alter session TO oe;

-- Create stored objects
   @?/demo/schema/order_entry/xdbSupport


-- Create directory object, instantiated by createUser.sql.sbs
 @?/demo/schema/order_entry/createUser



CONNECT oe/&pass_oe;

--
-- set . and , as decimal point and thousand separator for the session
-- as the unit prices are hard coded, which might cause NLS issues
--
ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';

-- Create folders and load
 @?/demo/schema/order_entry/xdb03usg


--
-- CONNECT as SYS. Revoke "ANY" privs
--

CONNECT sys/&pass_sys AS SYSDBA;  

REVOKE create any directory FROM oe;
REVOKE drop any directory FROM oe;
REVOKE alter session FROM oe;
   
DROP PACKAGE xdb.coe_configuration;
DROP PACKAGE xdb.coe_namespaces;
DROP PACKAGE xdb.coe_dom_helper;
DROP PACKAGE xdb.coe_utilities;
DROP PACKAGE xdb.coe_tools;
DROP TRIGGER xdb.no_dml_operations_allowed;
DROP VIEW    xdb.database_summary;


CONNECT oe/&&pass_oe;

