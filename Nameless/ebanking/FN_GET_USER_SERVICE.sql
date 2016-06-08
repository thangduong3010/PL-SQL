CREATE OR REPLACE FUNCTION DEMOEBANKING.FN_GET_USER_SERVICE(puserid IN varchar2, pservice in number)
RETURN VARCHAR2 AS
    l_char  varchar2(1 byte);
BEGIN
    Select nvl(substr(USER_SERVICE,pservice+1,1),'N') into l_char From USER_LOGIN
    Where USR_USER_NAME = puserid;
    RETURN l_char;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END FN_GET_USER_SERVICE;
/