Rem
Rem $Header: rdbms/admin/catupprc.sql /st_rdbms_11.2.0/1 2011/05/18 13:18:26 skabraha Exp $
Rem
Rem catupprc.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catupprc.sql - CATalog UPgrade Post-catPRoC
Rem
Rem    DESCRIPTION
Rem      Final scripts for the RDBMS upgrade
Rem
Rem    NOTES
Rem      Invoked by catupgrd.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    05/16/11 - Backport skabraha_bug-11823179 from main
Rem    rburns      07/11/07 - add patch upgrade
Rem    rburns      06/11/07 - reset packages
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

Rem get the correct script name into the "upgrade_file" variable
COLUMN file_name NEW_VALUE upgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;

Rem Compilation of standard might end up invalidating all object types,
Rem including older versions. This will cause problems if we have data
Rem depending on these versions, as they cannot be revalidated. Older
Rem versions are only used for data conversion, so we only need the 
Rem information in type dictionary tables which are unaffected by
Rem changes to standard. Reset obj$ status of these versions to valid
Rem so we can get to the type dictionary metadata.
Rem We need to make this a trusted C callout so that we can bypass the
Rem security check. Otherwise we run intp 1031 when DV is already linked in.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/
CREATE OR REPLACE PROCEDURE validate_old_typeversions IS
LANGUAGE C
NAME "VALIDATE_OLD_VERSIONS"
LIBRARY UPGRADE_LIB;
/
execute validate_old_typeversions();
commit;
alter system flush shared_pool;
drop procedure validate_old_typeversions;

Rem Run the remainder of the RDBMS upgrade in the "a" scripts
@@a&upgrade_file

Rem Reset the package state of any packages invalidated during RDBMS upgrade
execute DBMS_SESSION.RESET_PACKAGE; 

Rem =====================================================================
Rem RDBMS UPgrade Complete
Rem =====================================================================

SELECT dbms_registry_sys.time_stamp('rdbms_end') as timestamp from dual;



