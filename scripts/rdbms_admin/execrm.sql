Rem
Rem $Header: rdbms/admin/execrm.sql /main/4 2009/04/02 08:04:04 suelee Exp $
Rem
Rem execrm.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      execrm.sql - EXECute Resource Manager packages
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    suelee      03/18/09 - Map dataload function to etl_group
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    aksshah     07/03/08 - Add default mapping for dataload functions
Rem    aksshah     03/01/08 - Add default mapping for backup/copy operations
Rem    rburns      05/31/06 - Resource Manager packages 
Rem    rburns      05/31/06 - Created
Rem


-- install mandatory and system managed (but non-mandatory) objects.
execute dbms_rmin.install;

-- set initial consumer group for SYS and SYSTEM to be SYS_GROUP
execute dbms_resource_manager.create_pending_area;
execute dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SYSTEM', 'SYS_GROUP');
execute dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SYS', 'SYS_GROUP');

-- set initial consumer group for 'BACKUP' FUNCTION
DECLARE
  mapping_exists NUMBER := 0;
BEGIN
  SELECT count(*) INTO mapping_exists
  FROM resource_group_mapping$
  WHERE attribute = dbms_resource_manager.oracle_function
  AND value = 'BACKUP';

  IF mapping_exists = 0 THEN
    dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_function, 'BACKUP', 'BATCH_GROUP');
  END IF;
END;
/

-- set initial consumer group for 'COPY' FUNCTION
DECLARE
  mapping_exists NUMBER := 0;
BEGIN
  SELECT count(*) INTO mapping_exists
  FROM resource_group_mapping$
  WHERE attribute = dbms_resource_manager.oracle_function
  AND value = 'COPY';

  IF mapping_exists = 0 THEN
    dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_function, 'COPY', 'BATCH_GROUP');
  END IF;
END;
/

-- set initial consumer group for 'DATALOAD' FUNCTION
DECLARE
  mapping_exists NUMBER := 0;
BEGIN
  SELECT count(*) INTO mapping_exists
  FROM resource_group_mapping$
  WHERE attribute = dbms_resource_manager.oracle_function
  AND value = 'DATALOAD';

  IF mapping_exists = 0 THEN
    dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_function, 'DATALOAD', 'ETL_GROUP');
  END IF;
END;
/

execute dbms_resource_manager.submit_pending_area;

-- grant system privilege to IMP_FULL_DATABASE and EXP_FULL_DATABASE
execute dbms_resource_manager_privs.grant_system_privilege('IMP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);
execute dbms_resource_manager_privs.grant_system_privilege('EXP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);



