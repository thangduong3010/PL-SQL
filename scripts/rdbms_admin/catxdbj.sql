Rem
Rem $Header: catxdbj.sql 16-sep-2003.15:01:17 mjaeger Exp $
Rem
Rem catxdbj.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.
Rem
Rem    NAME
Rem      catxdbj.sql - Registration of XDB java dom/jndi/bean api jar files
Rem
Rem    DESCRIPTION
Rem      This script install the xdb java api IN the sys schema
Rem
Rem    NOTES
Rem      java api are loaded IN the sys schema WITH PUBLIC ACCESS.
Rem      Needs to run as SYS.
Rem
Rem MODIFIED (MM/DD/YY)
Rem mjaeger   09/16/03 - bug 3015638: move XSU source from rdbms vob to xdk vob
Rem sichandr  11/07/02 - remove shiphome workaround
Rem vnimani   04/24/02 - xsu should be picked up from OH/lib
Rem vnimani   03/18/02 - dont load xmlgen -- deprecated
Rem gviswana  01/29/02 - CREATE OR REPLACE SYNONYM
Rem sichandr  01/26/02 - temporary workaround for shiphome
Rem bkhaladk  01/14/02 - add xsu loading in catxdbj.
Rem spannala  12/13/01 - removing connect
Rem bkhaladk  09/20/01 - Created
Rem

-- bug 3015638:
-- Move source code and support files from rdbms vob to xdk vob.
-- The xsu12.jar file used to get loaded here,
-- and has now been moved to initxml.sql in the xdk vob.

-- As part of bug 3015638, we are also commenting out
-- the loading of the following XDB bits here.
-- Because XSU (now part of XDK) depends on the XMLType,
-- the servlet.jar and xdb.jar files must get loaded
-- before xsu12.jar, and xsu12.jar is now in initxml.sql.
-- Hence these loads have been moved there,
-- and they don't need to be here at all.
-- You can't have the XDB component without the XML component (aka XDK)
-- in any case (because XDB depends on XDK's parser),
-- so there's no harm in loading this bit of XDB along with XDK.

-- At some point in the future, if we separate out just the XMLType,
-- then that's the only bit that needs to get loaded with XDK,
-- and it would probably be more appropriate to load
-- servlet.jar and xdb.jar here, rather than in initxml.sql.

-- call sys.dbms_java.loadjava('-s -g public -f -r rdbms/jlib/servlet.jar');
-- call sys.dbms_java.loadjava('-s -g public -f -r rdbms/jlib/xdb.jar');

