variable b_result number
set autoprint on

begin
	select HR.EMPLOYEES.SALARY
    into :b_result
    from HR.EMPLOYEES
    where EMPLOYEE_ID = 144;
end;

--print b_result
