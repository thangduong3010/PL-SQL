Rem
Rem $Header: rdbms/admin/catpend.sql /st_rdbms_11.2.0/1 2012/11/21 00:22:54 pknaggs Exp $
Rem
Rem catpend.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catpend.sql - CATProc END
Rem
Rem    DESCRIPTION
Rem      This script runs the final actions for catproc.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It is run with catctl.pl as a  single process phase.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pknaggs     10/30/12 - lrg #7262630: parallel upgrade troubles.
Rem    pyoun       01/16/09 - bug 7653375 add random salt confounder
Rem    shiyer      03/26/08 - Remove TSMSYS schema
Rem    dsemler     02/07/08 - Add APPQOSSYS schema to schema list
Rem    achoi       02/01/08 - add DIP, ORACLE_OCM
Rem    rburns      01/19/07 - add package reset
Rem    rburns      08/28/06 - move sql_bind_capture
Rem    mzait       06/15/06 - add TSMSYS to the registry
Rem    rburns      05/22/06 - add timestamp 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

------------------------------------------------------------------------------

Rem
Rem [g]v$sql_bind_capture
Rem   must be create here since it has a dependency with AnyData type
-- should be included in some other script
-- causes hang in catpdeps.sql
Rem
create or replace view v_$sql_bind_capture as select * from o$sql_bind_capture;
create or replace public synonym v$sql_bind_capture for v_$sql_bind_capture;
grant select on v_$sql_bind_capture to select_catalog_role;

create or replace view gv_$sql_bind_capture as select * from go$sql_bind_capture;
create or replace public synonym gv$sql_bind_capture for gv_$sql_bind_capture;
grant select on gv_$sql_bind_capture to select_catalog_role;

Rem Reset the package state of any packages used during catproc.sql
execute DBMS_SESSION.RESET_PACKAGE; 

Rem
Rem add random salt confounder for bug 7653375
Rem
insert into props$
    (select 'NO_USERID_VERIFIER_SALT', RAWTOHEX(sys.DBMS_CRYPTO.RANDOMBYTES (16)),
NULL from dual
     where 'NO_USERID_VERIFIER_SALT' NOT IN (select name from props$));

Rem lrg #7262630: parallel upgrade troubles:
Rem Moved the following code block, which puts the default FULL
Rem Data Redaction values into the RADM_FPTM_LOB$ table from 
Rem   $SRCHOME/rdbms/src/server/security/dbmasking/prvtredacta.sql
Rem to here ($SRCHOME/rdbms/admin/catpend.sql).

DECLARE
  blobval BLOB;
  clobval CLOB;
  nclobval NCLOB;
  fpval    NUMBER;
BEGIN
  DBMS_LOB.CREATETEMPORARY(blobval,TRUE);
  DBMS_LOB.CREATETEMPORARY(clobval,TRUE);
  DBMS_LOB.CREATETEMPORARY(nclobval,TRUE);

  DBMS_LOB.WRITE(blobval, 10, 1, UTL_RAW.CAST_TO_RAW('[redacted]'));
  DBMS_LOB.WRITE(clobval, 10, 1, '[redacted]');
  DBMS_LOB.WRITE(nclobval, 10, 1, N'[redacted]');

  select fpver into fpval from sys.radm_fptm_lob$;

  if fpval = 0 then
    update sys.radm_fptm_lob$
    set blobcol=blobval,
        clobcol=clobval,
        nclobcol=nclobval,
        fpver=1
    where fpver=0;

    commit;
  end if;

  DBMS_LOB.FREETEMPORARY(blobval);
  DBMS_LOB.FREETEMPORARY(clobval);
  DBMS_LOB.FREETEMPORARY(nclobval);
EXCEPTION
  when too_many_rows then
    delete from sys.radm_fptm_lob$
    where fpver < 2;

    insert into sys.radm_fptm_lob$
    values (blobval,
            clobval,
            nclobval,
            1);
    commit;

    DBMS_LOB.FREETEMPORARY(blobval);
    DBMS_LOB.FREETEMPORARY(clobval);
    DBMS_LOB.FREETEMPORARY(nclobval);
  when no_data_found then
    insert into sys.radm_fptm_lob$
    values (blobval,
            clobval,
            nclobval,
            1);
    commit;
    DBMS_LOB.FREETEMPORARY(blobval);
    DBMS_LOB.FREETEMPORARY(clobval);
    DBMS_LOB.FREETEMPORARY(nclobval);
END;
/

SET SERVEROUTPUT ON

Rem Indicate CATPROC load complete and check validity
BEGIN
   dbms_registry.update_schema_list('CATPROC',
     dbms_registry.schema_list_t('SYSTEM', 'OUTLN', 'DBSNMP', 'DIP',
                                 'ORACLE_OCM', 'APPQOSSYS'));
   dbms_registry.loaded('CATPROC');
   dbms_registry_sys.validate_catproc;
   dbms_registry_sys.validate_catalog;
END;
/

SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;  

SET SERVEROUTPUT OFF


