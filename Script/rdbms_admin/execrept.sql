Rem
Rem $Header: execrept.sql 23-mar-2006.11:53:43 pbelknap Exp $
Rem
Rem execrept.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execrept.sql - EXECute common REPorTing framework functions after
Rem                     package load
Rem
Rem    DESCRIPTION
Rem      This script is run after our packages have been loaded to initialize
Rem      the framework repository
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    03/23/06 - Created
Rem

exec prvt_report_tags.register_common_tags(TRUE);
exec prvt_report_registry.register_clients;


