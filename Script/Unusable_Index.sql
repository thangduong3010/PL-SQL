SET SERVEROUTPUT ON;

DECLARE
   CURSOR usr_idxs
   IS
      SELECT index_name
        FROM user_indexes
       WHERE table_name = 'CUSTOMER' AND uniqueness != 'UNIQUE';

   cur_idx   USER_INDEXES.INDEX_NAME%TYPE;
   v_sql     VARCHAR2 (1024);
   t1        INTEGER;
   t2        INTEGER;
BEGIN
   t1 := DBMS_UTILITY.GET_TIME;

   OPEN usr_idxs;

   LOOP
      FETCH usr_idxs INTO cur_idx;

      EXIT WHEN usr_idxs%NOTFOUND;

      --dbms_output.put_line(cur_idx);

      v_sql := 'ALTER INDEX ' || cur_idx || ' UNUSABLE';

      EXECUTE IMMEDIATE v_sql;
   END LOOP;

   CLOSE usr_idxs;

   t2 := DBMS_UTILITY.GET_TIME;
   DBMS_OUTPUT.put_line ('Time: ' || TO_CHAR ( (t2 - t1)));
END;