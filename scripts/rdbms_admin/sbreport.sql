Rem
Rem sbreport.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sbreport.sql
Rem
Rem    DESCRIPTION
Rem      This script calls sbrepins.sql to produce standby statspack report
Rem
Rem    NOTES
Rem      Must run as the standby statspack owner, stdbyperf
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      02/15/07 - fix bug
Rem    wlohwass    12/04/06 - Created, based on spreport.sql


@@sbrepins

