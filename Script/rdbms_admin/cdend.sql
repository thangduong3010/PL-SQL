Rem
Rem $Header: cdend.sql 08-aug-2006.16:53:24 cdilling Exp $
Rem
Rem cdend.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdend.sql - Catalog END 
Rem
Rem    DESCRIPTION
Rem      Create views and objects that can be created near the end.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    08/02/06 - clean up
Rem    ushaft      05/22/06 - add dbmsaddm
Rem    gssmith     06/03/06 - Move SQL Access Advisor scripts 
Rem    rburns      05/22/06 - add timestamp 
Rem    cdilling    05/04/06 - Created
Rem

Rem Indicate load complete

BEGIN
   dbms_registry.loaded('CATALOG');
END;
/

SELECT dbms_registry.time_stamp('CATALOG') AS timestamp FROM DUAL;
