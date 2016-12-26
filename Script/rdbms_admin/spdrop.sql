Rem
Rem $Header: spdrop.sql 03-may-00.15:57:17 cdialeri Exp $
Rem
Rem spdrop.sql
Rem
Rem  Copyright (c) Oracle Corporation 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      spdrop.sql
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file drop user, tables and package for
Rem	 performance diagnostic tool STATSPACK
Rem
Rem    NOTES
Rem	 Note the script connects INTERNAL and so must be run from
Rem	 an account which is able to connect internal.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    05/03/00 - 1261813
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    08/13/99 - Drops entire STATSPACK environment
Rem    cdialeri    08/13/99 - Created
Rem

--
--  Drop PERFSTAT's tables and indexes

@@spdtab


--
--  Drop PERFSTAT user

@@spdusr

