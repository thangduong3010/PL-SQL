rem
Rem $Header: catdip.sql 27-mar-2006.14:03:11 lburgess Exp $
Rem
Rem catdip.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catdip.sql - Creates a DIP account for provisioning event processing.
Rem
Rem    DESCRIPTION
Rem      Creates a generic user account DIP for processing events propagated
Rem      by DIP. This account would be used by all applications using
Rem      the DIP provisioning service when connecting to the database.
Rem
Rem    NOTES
Rem      Called from catproc.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lburgess    03/27/06 - use lowercase for password 
Rem    srtata      01/22/03 - srtata_bug-2629661
Rem    srtata      12/17/02 - Created
Rem

create user DIP identified by dip password expire account lock;

grant create session to DIP;

