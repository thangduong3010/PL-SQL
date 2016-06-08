CREATE OR REPLACE FUNCTION DEMOEBANKING.CHECKALLOCATEFINISH 
(
  RULEID IN NUMBER 
) RETURN NUMBER 
IS
 v_row_count Number;
 v_Y_count Number;
BEGIN
  select count(1) into v_row_count from XP_RULE_MAPPING xpt where xpt.RULE_ID = RULEID and xpt.ALLOCATE_TYPE='M';
  select count(1) into v_Y_count from XP_RULE_MAPPING xpt where xpt.RULE_ID = RULEID and xpt.ALLOCATE_TYPE='M' and xpt.ALLOCATE_STATUS='Y';
  if (v_row_count = v_Y_count)
      then
      dbms_output.put_line('Finished');
      return 1;
  else  
       dbms_output.put_line('Allocating');
       return 0;
  end if;
  EXCEPTION
    WHEN OTHERS
      THEN
      RETURN 0;
  RETURN 0;
END CHECKALLOCATEFINISH;
/