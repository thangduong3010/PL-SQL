Rem
Rem $Header: rdbms/admin/sbrepsql.sql /main/1 2009/09/24 11:15:01 shsong Exp $
Rem
Rem sbrepsql.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      sbrepsql.sql - StandBy statspack REPort SQL
Rem
Rem    DESCRIPTION
Rem      This script calls sprsqins.sql to produce
Rem      the standard standby Statspack SQL report.
Rem
Rem    NOTES
Rem      Usually run as the STDBYPERF user
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      09/15/09 - Created
Rem

@@sbrsqins

--
-- End of file



