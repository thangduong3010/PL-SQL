Rem
Rem $Header: utlpitl.sql 15-dec-00.13:23:14 rburns   Exp $
Rem
Rem utlpitl.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      utlpitl.sql - UTiLity to reset Pdml ITL
Rem
Rem    DESCRIPTION
Rem      This script needs to be executed to remove PDML ITL 
Rem      incompatibilities before you issue the 
Rem      ALTER DATABASE RESET COMPATIBILITY statement to lower
Rem      compatibility from 9.0 to 8.1.
Rem
Rem    NOTES
Rem      Must be run AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      12/15/00 - renamed
Rem    dpotapov    06/28/00 - Created
Rem

update tab$ set property = property - bitand( property, 536870912 )
where bitand( property, 536870912 ) > 0;

commit;
