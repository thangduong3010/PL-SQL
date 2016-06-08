CREATE OR REPLACE FUNCTION DEMOEBANKING.CURRENT_APPDATE(pBranch IN varchar2)
RETURN DATE AS
    l_date  DATE;
BEGIN
    Select trunc(sysdate) into l_date From DUAL;
    RETURN l_date;
EXCEPTION
    WHEN OTHERS THEN
        RETURN trunc(sysdate);
END CURRENT_APPDATE;
/