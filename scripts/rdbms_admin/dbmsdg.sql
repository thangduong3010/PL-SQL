--
-- $Header: rdbms/admin/dbmsdg.sql /st_rdbms_11.2.0/1 2012/03/13 09:07:05 nkarkhan Exp $
--
-- dbmsdg.sql
--
-- Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      dbmsdg.sql - Package header for dbms_dg
--
--    DESCRIPTION
--      This package is the public interface to the Data Guard callable API.
--
--    NOTES
--      Package body is in $ADE_VIEW_ROOT/rdbms/src/server/drs/prvtdg.sql
--
--    MODIFIED   (MM/DD/YY)
--    nkarkhan    03/06/12 - Backport nkarkhan_bug-13559548 from main
--    svivian     06/05/06 - 
--    nkarkhan    05/24/06 - Project 19620: Add support for application
--                           initiated Fast-Start Failover.
--    nkarkhan    05/24/06 - Created
--


-- DE-HEAD-SQL       <- tell SED where to cut
CREATE OR REPLACE PACKAGE dbms_dg AUTHID CURRENT_USER AS

  --
  -- This function is used by an application to initiate a Fast-Start Failover.
  -- The broker will determine if the configuration is ready to failover
  -- and then signal the Observer to failover.
  --
  -- The caller can pass in a character string to indicate the reason
  -- a Fast-Start Failover has been requested. If a NULL string is passed in
  -- a default string of 'Application Failover Requested' will be sent to the
  -- observer.
  --
  -- RETURNS:
  --   ORA-00000: normal, successful completion
  --   ORA-16646: Fast-Start Failover is disabled
  --   ORA-16666: unable to initiate Fast-Start Failover on a bystander
  --     standby database
  --   ORA-16817: unsynchronized Fast-Start Failover configuration
  --   ORA-16819: Fast-Start Failover observer not started
  --   ORA-16820: Fast-Start Failover observer is no longer observing this
  --     database
  --   ORA-16829: lagging Fast-Start Failover configuration
  --
  FUNCTION initiate_fs_failover(condstr IN VARCHAR2) RETURN BINARY_INTEGER;

pragma TIMESTAMP('2012-01-26:08:55:00');

END dbms_dg;

/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_DG FOR SYS.DBMS_DG;

