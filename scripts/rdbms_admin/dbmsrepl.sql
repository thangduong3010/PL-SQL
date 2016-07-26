Rem
Rem $Header: rdbms/admin/dbmsrepl.sql /main/2 2008/12/25 17:24:23 yurxu Exp $
Rem
Rem dbmsrepl.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrepl.sql - DBMS REPLication package headers.
Rem
Rem    DESCRIPTION
Rem      Load Replication (MV, Multi-Master, and IAS) package headers.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yurxu       12/04/08 - Disable IAS
Rem    elu         11/02/06 - Created
Rem

Rem --------------------------------------------------------------------------
Rem Snapshot (MV) package headers
Rem --------------------------------------------------------------------------

@@prvthdcl.plb
@@prvtrpch.plb
@@prvthipk.plb
@@prvthint.plb
@@prvthitr.plb
@@prvthtop.plb
@@dbmsgen
@@prvthgen.plb
@@dbmsdefr.sql
@@prvthout.plb
@@prvthutl.plb
Rem@@prvthdfd.plb
@@prvthdfi.plb
@@prvtharp.plb
@@prvthdfr.plb
@@prvthsqu.plb
@@prvthcut.plb
@@dbmshsna
@@prvtsnps.plb


Rem The following synonym makes it look like the dbms_repcat package
Rem is installed even though it is not.
create public synonym dbms_repcat for dbms_repcat_sna
/
Rem Another synomym to hide missing package.  This synonym makes 
Rem the dbms_repcat_rgt package look like it is installed even 
Rem though it is not. None of the dbms_repcat_rgt procedures 
Rem are available at a snapshot site. 
create public synonym dbms_repcat_rgt for dbms_repcat_sna
/
@@prvthsut.plb
@@prvthunt.plb
@@prvthdmn.plb
@@prvthfla.plb
@@prvthfut.plb
@@dbmsofsn
@@prvthoft.plb

Rem --------------------------------------------------------------------------
Rem Multi-Master package headers
Rem --------------------------------------------------------------------------

Rem The following install the replication PL/SQL packages.
Rem The dbmshrep.sql file must be first, followed by prvthdcl.plb.  
Rem Anything else can follow
@@dbmshrep.sql
@@prvthirp.plb
@@prvtsath.plb
@@prvthath.plb
@@prvthcnf.plb
@@prvthmas.plb
@@prvthrpc.plb
@@prvthrut.plb
@@prvthut2.plb
@@prvthut3.plb
@@prvthut4.plb
@@prvthval.plb
@@prvthowp.plb
@@prvthfma.plb
@@prvthrrq.plb
@@prvthadd.plb
@@prvthofl.plb
@@prvthmig.plb
show errors;
@@dbmshrmg.sql

@@dbmsrctf
@@dbmsofln

Rem refresh group templates
@@dbmsrgt
@@prvthrgt.plb
@@dbmsrint

Rem --------------------------------------------------------------------------
Rem IAS package headers
Rem --------------------------------------------------------------------------

-- IAS package specifications
Rem @@dbmsiast
Rem @@prvthiai.plb
Rem @@prvthiau.plb
