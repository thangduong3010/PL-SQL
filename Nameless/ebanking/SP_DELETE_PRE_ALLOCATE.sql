CREATE OR REPLACE PROCEDURE DEMOEBANKING.SP_DELETE_PRE_ALLOCATE(d_sid number, delete_result out varchar)
is
begin
 UPDATE XP_PREPARE_ALLOCATE SET STATUS = 'E' WHERE SID = d_sid;
 delete_result := 'sucess';
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN delete_result:= 'rollback';
 ROLLBACK;
end SP_DELETE_PRE_ALLOCATE;
/