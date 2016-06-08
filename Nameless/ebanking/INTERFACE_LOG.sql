CREATE OR REPLACE PROCEDURE DEMOEBANKING.INTERFACE_LOG(pmodule in varchar2, pseq in number, perr in varchar2) is
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
    insert into INTERFACE_ERR_MESSAGE(MODULE, SEQ, ERROR_MESSAGE)
    values(pmodule, pseq, perr);
    Commit;
exception
    when others then
        Rollback;
end;
/