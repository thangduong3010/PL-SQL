Rem
Rem $Header: rdbms/admin/olsu101.sql /main/6 2009/03/26 12:19:05 srtata Exp $
Rem
Rem olsu101.sql
Rem
Rem Copyright (c) 2004, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      olsu101.sql - upgrade from 10.1 to 10.2
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      02/13/09 - call olsu111.sql
Rem    cchui       06/22/04 - grant new privileges 
Rem    cchui       05/11/04 - Clean up all the SETs 
Rem    srtata      03/26/04 - srtata_bug-3440113 
Rem    srtata      02/12/04 - Created
Rem

-- Grant new privileges
GRANT SELECT ON GV_$SESSION TO LBACSYS;
GRANT SELECT ON V_$INSTANCE TO LBACSYS;
GRANT SELECT ON GV_$INSTANCE TO LBACSYS;

@@olsu111.sql

