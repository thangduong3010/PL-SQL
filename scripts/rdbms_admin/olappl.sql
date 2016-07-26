rem 
rem $Header: oraolap/admin/olappl.sql /main/6 2008/07/23 13:42:07 cchiappa Exp $ 
rem 
Rem Copyright (c) 2004, 2008, Oracle. All rights reserved.  
Rem    NAME
Rem      olappl.sql
Rem    DESCRIPTION
Rem      Install OLAP-related PL/SQL packages
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected AS SYSDBA.
Rem    MODIFIED   (MM/DD/YY)
Rem     cchiappa   06/04/08 - Add dbmscbl and prvtcbl
Rem     ckearney   06/05/06 - add dbmsawst.sql & prvtawst.plb 
Rem     cchiappa   01/18/05 - Run olaptf.plb 
Rem     cchiappa   01/11/05 - Move DBMS_AW_XML to catawxml 
Rem     cchiappa   12/13/04 - Add dbmsawx, unwrap dbmsaw.sql 
Rem     cchiappa   04/06/04 - created
Rem

@@dbmsaw.sql
@@prvtaw.plb
@@olaptf.plb
@@dbmsawex.sql
@@prvtawex.plb
@@dbmsawst.sql
@@prvtawst.plb
@@dbmscbl.sql
@@prvtcbl.plb
