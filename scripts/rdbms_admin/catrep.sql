Rem 
rem $Header: catrep.sql 23-oct-2006.14:20:08 elu Exp $ 
rem 
Rem  Copyright (c) 1991, 2000 by Oracle Corporation 
Rem    NAME
Rem      catrep.sql
Rem    DESCRIPTION
Rem	 Run all sql scripts for replication option
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL
Rem    MODIFIED   (MM/DD/YY)
Rem     elu        10/23/06  - 
Rem     lkaplan    11/14/00  - Remove utlraw load
Rem     liwong     08/09/00  - Remove workaround
Rem     liwong     07/27/00  - Workaround for installing AnyData
Rem     celsbern   05/05/97 -  removed call to catrsc.sql script.
Rem     celsbern   03/28/00  - fixed to use catias.sql driver file.
Rem     celsbern   03/27/00  - adde ias_template info.
Rem     celsbern   03/10/97 -  Removed server side repapi drivers.
Rem     cchu       01/06/97 -  add catrsc.sql
Rem     hasun      12/23/96 -  add server repAPI
Rem     celsbern   11/06/96 -  separated snapshot and master functionality.
Rem     liwong     10/24/96 -  load dbmshrep.sql before loading prvthdcl.plb
Rem     liwong     10/05/96 -  Added prvthowp.plb
Rem     celsbern   10/03/96 -  added prvtsath.sql to replication
Rem     celsbern   10/03/96 -  added prvthval.plb
Rem     celsbern   10/02/96 -  Removed prvtrepc.sql added new split up files
Rem     sjain      09/06/96 -  AQ conversion
Rem     ldoo       08/22/96 -  Add dbmsrpch and prvtrpch.plb
Rem     jstamos    05/10/96 -  put catrepc.sql after utlraw
Rem     ldoo       05/09/96 -  New security model
Rem     sjain      01/09/96 -  Remove catrepad include
Rem     boki       07/10/95 -  add offline instantiaton
Rem     dsternbe   03/24/95 -  merge changes from branch 1.2.720.4
Rem     dsternbe   03/02/95 -  add catrepad.sql
Rem     boki       02/10/95 -  add table comparison feature packages
Rem     adowning   12/23/94 -  merge changes from branch 1.2.720.1
Rem     adowning   12/21/94 -  merge changes from branch 1.1.710.4
Rem     adowning   11/22/94 -  add comment
Rem     dsdaniel   11/01/94 -  utlraw changes merged froward
Rem     dsdaniel   10/13/94 -  merge changes from branch 1.1.710.2&3
Rem     dsdaniel   09/30/94 -  utl_raw changes - backed out must redo when 
Rem                            utl_raw changes are merged forward.
Rem     dsdaniel   09/30/94 -  utl_raw changes
Rem     jstamos    07/25/94 -  reorder entries because of package dependencies
Rem     adowning   03/29/94 -  merge changes from branch 1.1.710.1
Rem     adowning   02/04/94 -  Branch_for_patch
Rem     adowning   02/04/94 -  Creation



Rem Tables for deferred RPC
@@catdefrt  

Rem Views and tables for the replication catalog
@@catrepc.sql

Rem IAS views
@@catiasc.sql

