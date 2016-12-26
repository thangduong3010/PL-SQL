Rem
Rem $Header: catcmprm.sql 27-jun-2006.12:03:10 cdilling Exp $
Rem
Rem catcmprm.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catcmprm.sql - CATproc CoMPonenet Removal 
Rem
Rem    DESCRIPTION
Rem      Invoke the component removal script for input component ID
Rem
Rem    INPUT
Rem       This expects the following input:
Rem       component ID (JAVAVM, OWM, CONTEXT, etc)
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    06/07/06 - Created
Rem

SET SERVEROUTPUT ON;
SET VERIFY OFF;

DEFINE comp_id = &1 -- component id
DEFINE removal_file = 'nothing.sql'      

Rem Setup component script filename variable
COLUMN removal_name NEW_VALUE removal_file NOPRINT;
SELECT dbms_registry_sys.removal_script('&comp_id')
   AS removal_name FROM DUAL;

SET SERVEROUTPUT OFF 
@&removal_file

