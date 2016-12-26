Rem
Rem $Header: xdbSupport.sql 23-sep-2004.13:45:33 cbauwens Exp $
Rem
Rem xdbSupport.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbSupport.sql - Setup scripts for xml db env
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - Created 

         


-- Prepare environment
@?/demo/schema/order_entry/xdbConfiguration
@?/demo/schema/order_entry/xdbUtilities




