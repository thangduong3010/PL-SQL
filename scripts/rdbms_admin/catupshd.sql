Rem
Rem $Header: rdbms/admin/catupshd.sql /st_rdbms_11.2.0/2 2012/06/26 11:49:09 jerrede Exp $
Rem
Rem catupshd.sql
Rem
Rem Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catupshd.sql - CATalog UPgrade SHutDown
Rem
Rem    DESCRIPTION
Rem      This script is the final step in upgrades that that do not 
Rem      run utlmmig.sql.  It updates logminer metadata in the redo
Rem      stream (when needed) and shuts down the database.
Rem
Rem    NOTES
Rem      Invoked from catupend.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     06/21/12 - Backport jerrede_bug-13719893 from main
Rem    apfwkr      03/02/12 - Backport dvoss_bug-13719292 from main
Rem    rburns      07/12/07 - final upgrade shutdown
Rem    rburns      07/12/07 - Created
Rem


Rem =====================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =====================================================================

@@utllmup

Rem =====================================================================
Rem Record UPGRADE complete
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem =====================================================================

EXECUTE dbms_session.reset_package;

BEGIN
   dbms_registry_sys.record_action('UPGRADE',NULL,'Upgraded from ' || 
       dbms_registry.prev_version('CATPROC'));
END;
/

Rem =====================================================================
Rem Run component status as the last output
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem Note:  ACTIONS_END must stay here to get the correct upgrade time.
Rem =====================================================================

SELECT dbms_registry_sys.time_stamp('ACTIONS_END') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.time_stamp('UPGRD_END') AS timestamp FROM DUAL;
@@utlusts TEXT
commit;

shutdown immediate;

