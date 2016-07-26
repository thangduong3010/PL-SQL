Rem $Header: bi_views.sql 07-may-2003.10:15:44 ahunold Exp $
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      bi_views.sql - Views and synonyms for schema BI
Rem
Rem    DESCRIPTION
Rem      tbd
Rem
Rem    MODIFIED     (MM/DD/YY)
Rem      ahunold     05/07/03 - no COMPANY_ID
Rem      ahunold     09/18/02 - ahunold_sep17_02
Rem      ahunold     09/17/02 - created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

PROMPT
PROMPT specify password for BI as parameter 1:
DEFINE bi_pass             = &1
PROMPT

CONNECT bi/&bi_pass;

CREATE SYNONYM channels		FOR sh.channels;
CREATE SYNONYM countries	FOR sh.countries;
CREATE SYNONYM times		FOR sh.times;
CREATE SYNONYM costs		FOR sh.costs;
CREATE SYNONYM customers	FOR sh.customers;
CREATE SYNONYM products		FOR sh.products;
CREATE SYNONYM promotions	FOR sh.promotions;
CREATE SYNONYM sales		FOR sh.sales;

COMMIT;
