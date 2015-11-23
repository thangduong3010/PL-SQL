-- user-defined type practice
set serveroutput on

declare
	-- Simple type declaration
    TYPE BonusCompensation
    IS RECORD ( CashPayment NUMBER(6),
    			CompanyCar BOOLEAN,
                VacationWeeks NUMBER(2));
                
    -- Extended type declaration
    TYPE EmpRecord
    IS RECORD ( ssn employee.ssn%TYPE,
    			lname employee.lname%TYPE,
                dname department.dname%TYPE,
                BonusPayment BonusCompensation);
    
    TYPE ManagerRecord
    IS RECORD ( ssn employee.ssn%TYPE,
    			lname employee.lname%TYPE,
    			BonusPayment BonusCompensation);
                
    -- declare variable
    BestEmp EmpRecord;
    BestManager ManagerRecord;
                
begin
	-- initialise employee
    select essn, lname, dname
    into BestEmp.ssn,
    	 BestEmp.lname,
         BestEmp.dname
    from employee, department, works_on
    where EMPLOYEE.DNO = DEPARTMENT.DNUMBER
    and EMPLOYEE.SSN = WORKS_ON.ESSN
    and hours = (select max(hours) from works_on)
    and rownum <= 1;
    
    BestEmp.BonusPayment.CashPayment := '50000';
    BestEmp.BonusPayment.CompanyCar := TRUE;
    BestEmp.BonusPayment.VacationWeeks := 1;
    
    -- print output
    DBMS_OUTPUT.PUT_LINE('-----------------------Best Employee Award---------------------');
    DBMS_OUTPUT.PUT_LINE('Name: ' || BestEmp.lname);
    DBMS_OUTPUT.PUT_LINE('Department: ' || BestEmp.dname);
    DBMS_OUTPUT.PUT_LINE('Bonus payment: ' || BestEmp.BonusPayment.CashPayment || '$');
    
    if BestEmp.BonusPayment.CompanyCar = TRUE then
    DBMS_OUTPUT.PUT_LINE('Company car also provided');
    else
    DBMS_OUTPUT.PUT_LINE('No car');
    end if;
    
    if BestEmp.BonusPayment.VacationWeeks > 0 then
    DBMS_OUTPUT.PUT_LINE('Extra vacation weeks: ' || BestEmp.BonusPayment.VacationWeeks);
    end if;

	-- initialise manager
    select ssn, lname
    into BestManager.ssn, BestManager.lname
    from employee, department, works_on
    where employee.ssn = department.mgrssn
    and hours = (select max(hours) from works_on)
    and rownum <= 1;
    
    BestManager.BonusPayment.CashPayment := 20000;
    BestManager.BonusPayment.CompanyCar := FALSE;
    BestManager.BonusPayment.VacationWeeks := 2;
    
    -- print output
    DBMS_OUTPUT.PUT_LINE('--------------------Best Manager Award-----------------');
    DBMS_OUTPUT.PUT_LINE('SSN: ' || BestManager.ssn);
    DBMS_OUTPUT.PUT_LINE('Name: ' || BestManager.lname);
    DBMS_OUTPUT.PUT_LINE('Bonus Payment: ' || BestManager.BonusPayment.CashPayment);
    
    if BestManager.BonusPayment.CompanyCar = TRUE then
    DBMS_OUTPUT.PUT_LINE('Company car also provided');
    else
    DBMS_OUTPUT.PUT_LINE('No car.');
    end if;
    
    if BestManager.BonusPayment.VacationWeeks > 0 then
    DBMS_OUTPUT.PUT_LINE('Extra vacation week: ' || BestManager.BonusPayment.VacationWeeks);
    end if;
    

end;
