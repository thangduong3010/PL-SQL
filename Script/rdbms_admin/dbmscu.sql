Rem
Rem $Header: rdbms/admin/dbmscu.sql /main/3 2008/11/29 22:12:23 adalee Exp $
Rem
Rem dbmscu.sql
Rem
Rem Copyright (c) 2007, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscu.sql - Misc cache layer PL/SQL functions
Rem
Rem    DESCRIPTION
Rem      Declaration of misc cache layer PL/SQL functions
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    adalee      11/11/08 - add object_downconvert
Rem    adalee      07/03/08 - add grab_index parameter
Rem    adalee      06/20/08 - add dissolve functions
Rem    adalee      09/27/07 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_cacheutil AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************

--*****************************************************************************
-- Package Public Types
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE     grab_affinity
--
-- Description:  try to grab object affinity in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE grab_affinity( schema     IN varchar2,
                         obj        IN varchar2,
                         partition  IN varchar2 := null,
                         grab_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     grab_readmostly
--
-- Description:  try to grab object readmostly in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE grab_readmostly( schema     IN varchar2,
                           obj        IN varchar2,
                           partition  IN varchar2 := null,
                           grab_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     dissolve_affinity
--
-- Description:  try to dissolve object affinity in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE dissolve_affinity( schema         IN varchar2,
                             obj            IN varchar2,
                             partition      IN varchar2 := null,
                             dissolve_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     dissolve_readmostly
--
-- Description:  try to dissolve object readmostly in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE dissolve_readmostly( schema         IN varchar2,
                               obj            IN varchar2,
                               partition      IN varchar2 := null,
                               dissolve_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     list_readmostly
--
-- Description:  list objects have readmostly property set
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE list_readmostly;

-------------------------------------------------------------------------------
--
-- PROCEDURE     object_downconvert
--
-- Description:  try to downconvert object locks to shared mode in RAC
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE object_downconvert( schema            IN varchar2,
                              obj               IN varchar2,
                              partition         IN varchar2 := null,
                              downconvert_index IN boolean := TRUE);


END;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_cacheutil FOR sys.dbms_cacheutil
/

GRANT EXECUTE ON dbms_cacheutil TO dba
/
