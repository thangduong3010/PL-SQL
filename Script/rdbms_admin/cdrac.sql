Rem
Rem $Header: rdbms/admin/cdrac.sql /main/2 2009/10/09 15:38:04 achoi Exp $
Rem
Rem cdrac.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdrac.sql - Catalog DRAC.bsq views
Rem
Rem    DESCRIPTION
Rem      service objects
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in drac.bsq. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       09/22/09 - edition as a service attribute
Rem    cdilling    05/04/06 - Created
Rem


Rem Add workgroup services views
create or replace view DBA_SERVICES
as select SERVICE_ID, NAME, NAME_HASH, NETWORK_NAME,
          CREATION_DATE, CREATION_DATE_HASH,
          FAILOVER_METHOD, FAILOVER_TYPE, FAILOVER_RETRIES, FAILOVER_DELAY,
          MIN_CARDINALITY, MAX_CARDINALITY,
          decode(GOAL, 0, 'NONE', 1, 'SERVICE_TIME', 2, 'THROUGHPUT', NULL)
            GOAL,
          decode(bitand(FLAGS, 2), 2, 'Y', 'N') DTP,
          decode(bitand(FLAGS, 1), 1, 'YES', 0, 'NO') ENABLED,
          decode(bitand(NVL(FLAGS,0), 4), 4, 'YES',
                                   0, 'NO', 'NO') AQ_HA_NOTIFICATIONS,
          decode(bitand(NVL(FLAGS,0), 8), 8, 'LONG', 0, 'SHORT', 'SHORT') CLB_GOAL,
          EDITION
   from service$
where DELETION_DATE is null
/

comment on column DBA_SERVICES.SERVICE_ID is
'The unique ID for this service'
/

comment on column DBA_SERVICES.NAME is
'The short name for the service'
/

comment on column DBA_SERVICES.NAME_HASH is
'The hash of the short name for the service'
/

comment on column DBA_SERVICES.NETWORK_NAME is
'The network name used to connect to the service'
/

comment on column DBA_SERVICES.CREATION_DATE is
'The date the service was created'
/

comment on column DBA_SERVICES.CREATION_DATE_HASH is
'The hash of the creation date'
/

comment on column DBA_SERVICES.FAILOVER_METHOD is
'The failover method (BASIC or NONE) for the service'
/

comment on column DBA_SERVICES.FAILOVER_TYPE is
'The failover type (SESSION or SELECT) for the service'
/

comment on column DBA_SERVICES.FAILOVER_RETRIES is
'The number of retries when failing over the service'
/

comment on column DBA_SERVICES.FAILOVER_DELAY is
'The delay between retries when failing over the service'
/

comment on column DBA_SERVICES.MIN_CARDINALITY is
'The minimum cardinality of this service to be maintained by director'
/

comment on column DBA_SERVICES.MAX_CARDINALITY is
'The maximum cardinality of this service to be allowed by director'
/

comment on column DBA_SERVICES.ENABLED is
'Indicates whether or not this service will be started/maintained by director'
/

comment on column DBA_SERVICES.AQ_HA_NOTIFICATIONS is
'Indicates whether AQ notifications are sent for HA events'
/

comment on column DBA_SERVICES.GOAL is
'The service workload management goal'
/

comment on column DBA_SERVICES.DTP is
'DTP flag for services'
/

comment on column DBA_SERVICES.CLB_GOAL is
'Connection load balancing goal for services'
/

comment on column DBA_SERVICES.EDITION is
'Initial session edition for services'
/

create or replace public synonym DBA_SERVICES
     for DBA_SERVICES
/
grant select on DBA_SERVICES to select_catalog_role
/


create or replace view ALL_SERVICES
as select * from dba_services
/
create or replace public synonym ALL_SERVICES
     for ALL_SERVICES
/
grant select on ALL_SERVICES to select_catalog_role
/

commit;
