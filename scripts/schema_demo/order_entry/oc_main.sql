rem
Rem $Header: oc_main.sql 29-aug-2002.11:45:07 hyeh Exp $  
rem
rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
rem
rem Owner  : ahunold
rem
rem NAME
rem   oc_main.sql - create OC (Online Catalog) subschema in
rem                 OE (Order Entry) Common Schema
rem
rem DESCRIPTON
rem   Calls all other OC creation scripts
rem
rem MODIFIED   (MM/DD/YY)
rem   hyeh      08/29/02 - hyeh_mv_comschema_to_rdbms
rem   ahunold   01/29/01 - oc_comnt.sql added
rem   ahunold   01/09/01 - checkin ADE

ALTER SESSION SET NLS_LANGUAGE=American;

prompt ...creating subschema OC in OE

REM =======================================================
REM create oc subschema (online catalog)
REM =======================================================

@@oc_cre
@@oc_popul
@@oc_comnt

