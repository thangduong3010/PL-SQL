Rem
Rem
Rem prvtrepl.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      prvtrepl.sql - PRVT REPlication
Rem
Rem    DESCRIPTION
Rem      Loads replication (MV, Multi-Master and IAS) package bodies.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yurxu       12/04/08 - Disable IAS
Rem    juyuan      02/12/07 - add prvtbsat
Rem    elu         11/02/06 - Created
Rem

Rem ------------------------------------------------------------------------
Rem Snapshot (MV) package bodies
Rem ------------------------------------------------------------------------

@@dbmsdefr.sql
@@prvtgen.plb
@@prvthobg.plb
@@prvtbobg.plb
@@prvtbog2.plb
@@prvtbog3.plb
@@prvtbint.plb
@@prvtbipk.plb
@@prvtbtop.plb
@@prvtbout.plb
@@prvtbdcl.plb
@@prvtbsqu.plb
@@prvtbcut.plb
@@prvtbsna.plb
@@prvtbunt.plb
@@prvtdrep.plb
@@prvtofsn.plb
@@prvtbdmn.plb
@@prvtbfut.plb
@@prvtbfla.plb
@@prvtboft.plb
@@prvtsnap.plb

Rem The following has been added to straighten out a dependency problem
alter package sys.dbms_snapshot compile body
/

Rem The following synonyms make the grant execute on dbms_repcat_% which
Rem exist in master site, but not in snapshot site succesful in
Rem dbms_repcat_admin.grant_admin_%_schema.
/*
create synonym dbms_repcat for dbms_repcat_sna
/
create synonym dbms_internal_repcat for dbms_repcat_sna
/
create synonym dbms_repcat_rpc for dbms_repcat_sna
/
create synonym dbms_repcat_utl2 for dbms_repcat_sna
/
create synonym dbms_rectifier_diff for dbms_repcat_sna
/
create synonym dbmsobjgwrapper for dbms_repcat_sna
/
create synonym dbms_repcat_rgt for dbms_repcat_sna
/
create synonym dbms_offline_og for dbms_repcat_sna
/
*/
Rem ------------------------------------------------------------------------
Rem Multi-Master package bodies
Rem ------------------------------------------------------------------------


@@prvtbath.plb
@@prvtbsat.plb
@@prvtbcnf.plb
@@prvtbowp.plb
@@prvtbrep.plb
@@prvtbmig.plb
@@prvtbirp.plb
@@prvtbrpc.plb
@@prvtbrut.plb
@@prvtbut2.plb
@@prvtbut3.plb
@@prvtbut4.plb
@@prvtbrmg.plb
@@prvtbfma.plb
@@prvtbrrq.plb
@@prvtbadd.plb
@@prvtbutl.plb
@@prvtbsut.plb
@@prvtbmas.plb
@@prvtbval.plb
Rem end of replication packages

Rem Deferred RPC packages
Rem@@prvtdfrd.plb
show errors;
@@prvtdfri.plb
show errors;
@@prvtarpp.plb
show errors;
@@prvtdefr.plb
show errors;
@@prvtrctf.plb
@@prvtofln.plb

Rem refresh group templates
@@prvtbrgt.plb
@@prvtbrnt.plb

Rem ------------------------------------------------------------------------
Rem IAS package bodies
Rem ------------------------------------------------------------------------

Rem @@prvtbiat.plb
Rem @@prvtbiau.plb
Rem @@prvtbiai.plb
