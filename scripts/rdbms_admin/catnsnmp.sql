Rem 
Rem NAME
Rem    catnsnmp.sql
Rem  FUNCTION
Rem    Deletes the SNMPAgent role and DBSNMP user
Rem    (Reverses catsnmp.sql)
Rem  NOTES
Rem  MODIFIED
Rem     nachen         02/03/05 - add drop role OEM_ADVISOR 
Rem     dholail        04/12/99 -
Rem
Rem  OWNER
Rem    ebosco
Rem



drop user DBSNMP cascade;

drop role SNMPAGENT;

drop role OEM_MONITOR;

drop role OEM_ADVISOR;








