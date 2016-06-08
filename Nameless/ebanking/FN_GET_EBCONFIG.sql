CREATE OR REPLACE FUNCTION DEMOEBANKING.FN_GET_ebconfig(pcname in varchar2, pcmod in varchar2, pcrec out EB_CONFIG%ROWTYPE)
RETURN number AS
BEGIN
    select * into pcrec from EB_CONFIG
    where CONFIG_NAME = pcname and CONFIG_MODULE = pcmod;
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END FN_GET_ebconfig;
/