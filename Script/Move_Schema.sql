SET SERVEROUTPUT ON

DECLARE
BEGIN
	-- move table to new tablespace
   FOR tab IN (SELECT * FROM dba_tables WHERE owner = 'BACKEND_DEV')
   LOOP
      DBMS_OUTPUT.put_line ('Table: ' || tab.table_name);

      --EXECUTE IMMEDIATE 'ALTER TABLE ' || tab.table_name || ' MOVE TABLESPACE ALM_DATA';
   END LOOP;

/*
	-- move index to new tablespace
   FOR idx IN (SELECT * FROM dba_indexes WHERE owner = 'BACKEND_DEV')
   LOOP
      DBMS_OUTPUT.put_line ('Index: ' || idx.index_name);
      
      --EXECUTE IMMEDIATE 'ALTER INDEX ' || idx.index_name || ' REBUILD TABLESPACE ALM_DATA';
   END LOOP;
*/
END;
/