rem
rem Header: oe_views.sql 09-jan-01
rem
rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
rem
rem Owner  : ahunold
rem
rem NAME
rem   oe_views.sql - OE Common Schema
rem
rem DESCRIPTON
rem   Create all views
rem
rem MODIFIED   (MM/DD/YY)
rem   hyeh      08/29/02 - hyeh_mv_comschema_to_rdbms
rem   ahunold   01/09/01 - checkin ADE

CREATE OR REPLACE VIEW products
AS
SELECT i.product_id
,      d.language_id
,      CASE WHEN d.language_id IS NOT NULL
            THEN d.translated_name
            ELSE TRANSLATE(i.product_name USING NCHAR_CS)
       END    AS product_name
,      i.category_id
,      CASE WHEN d.language_id IS NOT NULL
            THEN d.translated_description
            ELSE TRANSLATE(i.product_description USING NCHAR_CS)
       END    AS product_description
,      i.weight_class
,      i.warranty_period
,      i.supplier_id
,      i.product_status
,      i.list_price
,      i.min_price
,      i.catalog_url
FROM   product_information  i
,      product_descriptions d
WHERE  d.product_id  (+) = i.product_id
AND    d.language_id (+) = sys_context('USERENV','LANG');

REM =======================================================
REM Create some inventory views
REM =======================================================

CREATE OR REPLACE VIEW sydney_inventory
AS
SELECT p.product_id
,      p.product_name
,      i.quantity_on_hand
FROM   inventories i
,      warehouses  w
,      products    p  
WHERE  p.product_id = i.product_id
AND    i.warehouse_id = w.warehouse_id
AND    w.warehouse_name = 'Sydney';

CREATE OR REPLACE VIEW bombay_inventory
AS
SELECT p.product_id
,      p.product_name
,      i.quantity_on_hand
FROM   inventories i
,      warehouses  w
,      products    p   
WHERE  p.product_id = i.product_id
AND    i.warehouse_id = w.warehouse_id
AND    w.warehouse_name = 'Bombay';

CREATE OR REPLACE VIEW toronto_inventory
AS
SELECT p.product_id
,      p.product_name
,      i.quantity_on_hand
FROM   inventories i
,      warehouses  w
,      products    p
WHERE  p.product_id = i.product_id
AND    i.warehouse_id = w.warehouse_id
AND    w.warehouse_name = 'Toronto';

REM =======================================================
REM Create product_prices view of product_information
REM columns to show view with a GROUP BY clause.
REM =======================================================

CREATE OR REPLACE VIEW product_prices
AS
SELECT category_id
,      COUNT(*)        as "#_OF_PRODUCTS"
,      MIN(list_price) as low_price
,      MAX(list_price) as high_price
FROM   product_information
GROUP BY category_id;
