COLUMN :eoscr_name NEW_VALUE eoscr_file NOPRINT
VARIABLE eoscr_name VARCHAR2(50)

Rem Reload the schema registration/compilation module
@@prvtxsch.plb

Rem reload various views to be created on xdb data
@@catxdbv

Rem reload dbmsxdbt package
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

DECLARE
  ct           integer;
BEGIN
  select count(*) into ct from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  IF ct = 0 THEN
    :eoscr_name := '@catxdbeo.sql';
  ELSE
    :eoscr_name := '@nothing.sql';

    select count(*) into ct from DBA_OBJECTS 
    where owner = 'XDB' and object_name = 'FUNCSTATS' and object_type = 'TYPE';
    
    IF ct > 0 THEN
      execute immediate 'ALTER TYPE XDB.FUNCSTATS COMPILE BODY';

      select count(*) into ct from DBA_OBJECTS where status = 'INVALID' and 
      owner = 'XDB' and object_name = 'FUNCSTATS' and object_type = 'TYPE';
  
      IF ct = 0 THEN
        dbms_output.put_line('re-associating statistics');
        select count(*) into ct from DBA_ASSOCIATIONS 
        where object_owner = 'XDB' and object_name = 'XDBHI_IDXTYP';
     
        IF ct = 0 THEN
           execute immediate 'associate statistics with indextypes 
                              xdb.xdbhi_idxtyp using xdb.funcstats';
           dbms_output.put_line('xdbhi_idxtyp ...');
        END IF;
    
        select count(*) into ct from DBA_ASSOCIATIONS 
        where object_owner = 'XDB' and object_name = 'XDB_FUNCIMPL';
        
        IF ct = 0 THEN
           execute immediate 'associate statistics with packages xdb.xdb_funcimpl
                              using xdb.funcstats';
           dbms_output.put_line('xdb_funcimpl ...');
        END IF;
  
      END IF;
    END IF;
  END IF;
END;
/

Rem Reload repository view extensible optimizer
SELECT :eoscr_name FROM DUAL;
@&eoscr_file
