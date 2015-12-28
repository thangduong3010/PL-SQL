create or replace procedure loopproc (inval number)
is
	tmpvar number;
    tmpvar2 number;
    total number;
begin
	tmpvar := 0;
    tmpvar2 := 0;
    total := 0;
    
    for lcv in 1..inval
    loop
    	total := 2 * total + 1 - tmpvar2;
        tmpvar2 := tmpvar;
        tmpvar := total;
    end loop;
    dbms_output.put_line('Total is: ' || total);
end loopproc;