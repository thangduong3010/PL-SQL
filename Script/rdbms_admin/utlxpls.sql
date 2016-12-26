Rem
Rem $Header: utlxpls.sql 26-feb-2002.19:49:37 bdagevil Exp $
Rem
Rem utlxpls.sql
Rem
Rem Copyright (c) 1998, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlxpls.sql - UTiLity eXPLain Serial plans
Rem
Rem    DESCRIPTION
Rem      script utility to display the explain plan of the last explain plan
Rem	 command. Do not display information related to Parallel Query
Rem
Rem    NOTES
Rem      Assume that the PLAN_TABLE table has been created. The script 
Rem	 utlxplan.sql should be used to create that table
Rem
Rem      With SQL*plus, it is recomended to set linesize and pagesize before
Rem      running this script. For example:
Rem	    set linesize 100
Rem	    set pagesize 0
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bdagevil    02/26/02 - cast arguments
Rem    bdagevil    01/23/02 - rewrite with new dbms_xplan package
Rem    bdagevil    04/05/01 - include CPU cost
Rem    bdagevil    02/27/01 - increase Name column
Rem    jihuang     06/14/00 - change order by to order siblings by.
Rem    jihuang     05/10/00 - include plan info for recursive SQL in LE row source
Rem    bdagevil    01/05/00 - add order-by to make it deterministic
Rem    kquinn      06/28/99 - 901272: Add missing semicolon                    
Rem    bdagevil    05/07/98 - Explain plan script for serial plans             
Rem    bdagevil    05/07/98 - Created
Rem

set markup html preformat on

Rem
Rem Use the display table function from the dbms_xplan package to display the last
Rem explain plan. Force serial option for backward compatibility
Rem
select plan_table_output from table(dbms_xplan.display('plan_table',null,'serial'));


