Rem DEPENDENCIES
Rem it might be a good idea to move all the dbms* before the prvt*. Here
Rem is the list of dependencies that i have realized exist
Rem prvtxdbz.plb depends on prvtxdb.plb (prvtxdbz invokes dbms_xdbutil_int)
Rem prvtxdb.plb depends on dbmsxdbt (calls some function from that pkg)
Rem dbmsxdbt depends on dbmsxdbz  (call dbms_xdbz.get_username)

Rem reload xmltype
@@dbmsxmlt.sql
@@prvtxmlt.plb

Rem Ensure that all XDB$RESOURCE dependencies are validated
Rem before any packages that depend on it are compiled below
desc XDB.XDB$RESOURCE_T;

Rem Reload the schema registration/compilation module
@@dbmsxsch.sql

Rem Reload the security module
@@dbmsxdbz.sql
@@prvtxdz0.plb

@@dbmsxres.sql

Rem reload definition for various xdb utilities
@@dbmsxdb.sql
Rem Create the DBMS_XDB_ADMIN package 
@@dbmsxdba.sql
@@prvtxdb0.plb

Rem reload Path Index
@@catxdbpi.sql

Rem Reload implementation of XDB Utilities
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem Resource View
@@prvtxdr0.plb
@@catxdbr.sql 

Rem Resource view implementaion
@@prvtxdbr.plb

Rem before update trigger for document link processing
@@prvtxdbdl.plb


@@prvtxdb.plb

Rem Reload the dbms_csx_admin package body
@@prvtxdba.plb

Rem Reload implementation of XDB Security modules
@@prvtxdbz.plb

Rem XDB Path Index Implementation
@@prvtxdbp.plb 

@@dbmsxmlu.sql
@@dbmsxmls.sql
@@dbmsxmld.sql
@@dbmsxmlp.sql
@@dbmsxslp.sql
@@prvtxmlstreams.plb
@@prvtxmld.plb
@@prvtxmlp.plb
@@prvtxslp.plb

Rem Implementation of DBMS_XDBResource 
@@prvtxres.plb

@@prvtxsch.plb

Rem reload the Versioning Package 
@@catxdbvr.sql

Rem reload Path View
@@catxdbpv

Rem reload helper package for xml index
@@dbmsxidx
Rem reload dbms_xmlindex package body
@@prvtxidx.plb

Rem reload xmlindex packages
@@catxidx
@@catxtbix

Rem Setup XDB Digest Authentication
@@xdbinstd.sql

Rem reload various views to be created on xdb data
Rem This needs to be done after 9.2.0.2 migration
Rem @@catxdbv

Rem reload embedded PL/SQL gateway package
@@dbmsepg.sql
@@prvtepg.plb

Rem Create the DBMS_XEVENT package
@@dbmsxev
@@prvtxev.plb

Rem create the dbms_xmltranslations package
@@dbmsxtr
@@prvtxtr.plb

Rem create the DBMS_XDBREPOS package
@@dbmsxdbrepos
@@prvtxdbrepos.plb
