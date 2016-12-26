Rem
Rem $Header: utlxplp.sql 23-jan-2002.08:55:23 bdagevil Exp $
Rem
Rem utlxplp.sql
Rem
Rem Copyright (c) 1998, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlxplp.sql - UTiLity eXPLain Parallel plans
Rem
Rem    DESCRIPTION
Rem      script utility to display the explain plan of the last explain plan
Rem	 command. Display also Parallel Query information if the plan happens to
Rem      run parallel
Rem
Rem    NOTES
Rem      Assume that the table PLAN_TABLE has been created. The script 
Rem      utlxplan.sql should be used to create that table
Rem
Rem      With SQL*plus, it is recomended to set linesize and pagesize before
Rem      running this script. For example:
Rem	    set linesize 130
Rem	    set pagesize 0
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bdagevil    01/23/02 - rewrite with new dbms_xplan package
Rem    bdagevil    04/05/01 - include CPU cost
Rem    bdagevil    02/27/01 - increase Name column
Rem    jihuang     06/14/00 - change order by to order siblings by.
Rem    jihuang     05/10/00 - include plan info for recursive SQL in LE row source
Rem    bdagevil    01/05/00 - make deterministic with order-by
Rem    bdagevil    05/07/98 - Explain plan script for parallel plans           
Rem    bdagevil    05/07/98 - Created
Rem

set markup html preformat on

Rem
Rem Use the display table function from the dbms_xplan package to display the last
Rem explain plan. Use default mode which will display only relevant information
Rem
select * from table(dbms_xplan.display());
