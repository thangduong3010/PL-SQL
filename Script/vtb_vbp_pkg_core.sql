PACKAGE        VBP_PKG_CORE
AS
    TYPE T_CUR_PROD IS REF CURSOR;
/** NOTE@2014.06.12:
*   - Package core lay giao dich cac the va tinh hop le, chiet khau
**  NOTE@2014.09.08: Bo sung script cap nhat danh dau GD dao - SCAN_NEW_TRANS
**  NOTE@2015.11.13: Bo sung bao cao cho VNPT:
*   - Vi vay su dung truong PROVIDER nhu trong VJA sang VNPT vao VBP_TRAN_INPUT
**/
    K_RESULT_NEW		NUMBER(3) := 0;
    K_RESULT_SUCCESS		NUMBER(3) := 1;
    K_RESULT_INVALID_TRAN_CODE	NUMBER(3) := -1;
    K_RESULT_TRAN_IS_FAIL	NUMBER(3) := -2;
    K_RESULT_IS_REVERSAL	NUMBER(3) := -3;
    K_RESULT_TEXTMESS_EMPTY	NUMBER(3) := -4;
    K_RESULT_TEXTMESS_WRONG	NUMBER(3) := -5;
    K_RESULT_INVALID_CUSTOMER	NUMBER(3) := -6;

    K_PROVIDER_EVN VARCHAR2(10) := 'EVN';
    K_PROVIDER_VJA VARCHAR2(10) := 'VJA';
    K_PROVIDER_VNPT VARCHAR2(10) := 'VNPT';

    K_TRAN_TIME_TRUOC_IN_MINUTE NUMBER := 3; --Quet toi GD cach hien tai 5 phut

PROCEDURE JOB_BILL_REPAYMENT
/** NOTE@2014.09.06: Bo sung cho phep goi xu ly lai VBP_BILL vai lan **/
;

PROCEDURE SCAN_NEW_TRANS;

PROCEDURE PARSE_BILL_FROM_NEW_TRANS;

PROCEDURE BILL_CHANGE_TO_REPAYMENT(
    pId 	     IN NUMBER
    , pUpdateUser    IN VARCHAR2
    , poCount	     OUT NUMBER
/** NOTE@2014.09.06:
*   - Cho phep gan lai Status de quet lai giao dich doi voi cac GD BILL bi FAIL.
**/);

FUNCTION GET_TEXTMESS(
    pTextMess IN VARCHAR2
/** NOTE@2014.07.04: Remove cac ky tu dac biet cua TextMess **/
) RETURN VARCHAR2;

FUNCTION GET_BATCH_ID RETURN NUMBER;

PROCEDURE BILL_GENERATE_NEW_REQUEST_ID(poRequestId OUT NUMBER);

FUNCTION TEXTMESS_GET_CUSTOMER_ID(pTextMess IN VARCHAR2
/** Note@2014.07.11
*   - Lay ra CustomerId truyen vao, F31, bat dau boi ~31[13 ky tu]
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2;


FUNCTION TEXTMESS_GET_KY_CUOC(pTextMess IN VARCHAR2
/** Note@2014.07.11
*   - Lay ra CustomerId truyen vao, F32, bat dau boi ~32[7 ky tu]: ~3103/1012
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2;

FUNCTION TEXTMESS_GET_BILL_ID(pTextMess IN VARCHAR2
/** Note@2014.08.04
*   - Lay ra BillId truyen vao, F35, bat dau boi ~35[BillId]~...
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2;

FUNCTION GET_CFG_VARIABLE_VALUE(pJobName VARCHAR2, pVarName VARCHAR2
/** NOTE@2014.07.14:
*   - Lay ra gia tri Variable cua JOB [pJobName] - bien [pVarName]
*   - Tra ve Null neu ko co gia tri
**/
) RETURN VARCHAR2;


PROCEDURE SET_CFG_VARIABLE_VALUE(pJobName VARCHAR2, pVarName VARCHAR2, pVarValue VARCHAR2
/** NOTE@2014.07.14:
*   - Gan gia tri [pVarValue] cua JOB [pJobName] - bien [pVarName]
**/
);

END;
PACKAGE BODY	    VBP_PKG_CORE
/** NOTE@2014.06.12:
*   - Package core lay giao dich cac the va tinh hop le, chiet khau
**  NOTE@2014.09.08: Bo sung script cap nhat danh dau GD dao - SCAN_NEW_TRANS
**/
AS

PROCEDURE JOB_BILL_REPAYMENT
/** NOTE@2014.09.06: Bo sung cho phep goi xu ly lai VBP_BILL vai lan **/
AS
    voCount NUMBER := 0; vStt NUMBER := 0; vSuccess NUMBER := 0;
BEGIN

UPDATE VBP_BILL b
SET B.STATUS = 4 -- FAIL_NO_RETRY
    , B.UPDATEDATE = SYSDATE
WHERE b.Status = 5 AND b.ResultCode NOT IN (0, 1, 2)
    AND b.RequestRetry >= 1 AND b.CreateDate < TO_DATE(SYSDATE); --b.RequestDate < SYSDATE - 2;
voCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('VBP-JOB: Danh dau BILL FAIL: ' || voCount || '! ');
COMMIT;

FOR I IN (
    select b.Id, b.SourceId, b.SourceName, b.CustomerId, b.MaHoaDon, b.KyCuoc
	, b.Amount, b.TranDate, b.ResultCode, b.ResultMsg, b.RequestId
	, b.RequestRetry, b.RequestType, b.TransferDate, b.CreateDate, b.UpdateDate, b.Status
    from VBP_BILL b --Note@2014.11.07: Bo 9-Pending ra, (0, 1, 2, 9, 4)
    WHERE b.Status NOT IN (0, 1, 2, 4) AND b.RequestType = 1 -- Chi cho hoa don thanh toan
	AND b.CreateDate >= TO_DATE(SYSDATE) AND b.ResultCode NOT IN (0, 1, 2) -- Ko thanh cong???
	AND (b.Status NOT IN (9) OR b.ResultCode NOT IN (1001, 1025)) --AND b.RequestRetry < 5
	AND b.CreateDate < TO_DATE(SYSDATE+1)-1/24/2
    order by b.Id desc --RequestDate >= SYSDATE - 1
    -- 4: Fail, danh dau ko goi la VPG, 5: Fail nhung van cho goi lai VPG.
    -- 9: Pending.
) LOOP
    vStt := vStt + 1;
    VBP_PKG_CORE.BILL_CHANGE_TO_REPAYMENT(I.ID, 'VBP-JOB', voCount);
    IF voCount > 0 THEN vSuccess := vSuccess + 1; END IF;
END LOOP;

DBMS_OUTPUT.PUT_LINE('VBP-JOB: Repayment BILL: ' || vSuccess || '/' || vStt || ' (succ/all)! ');
IF vStt > 0 THEN
    INSERT INTO VBP_LOG(App, Id, LogDate, LogStr)
    VALUES('VBP-JOB-REPAYMENT', 0, SYSDATE, '' || vSuccess || '/' || vStt || ' (succ/all)! ');
    COMMIT;
END IF;

END;

PROCEDURE SCAN_NEW_TRANS
AS
    vTranId NUMBER := 0;
    vNewTranId NUMBER := 0;
    K_SCAN_JOB_NAME VARCHAR2(30) := 'SCAN_NEW_TRANS';
    K_SCAN_VAR_NAME VARCHAR2(30) := 'TRAN_ID';
    vCount NUMBER := 0;
    vBatchID NUMBER := 0;
BEGIN
    -- 001: Lay ra TranId de Search
    vTranId := NVL(TO_NUMBER(GET_CFG_VARIABLE_VALUE(K_SCAN_JOB_NAME, K_SCAN_VAR_NAME)),0);
    IF vTranId <= 0 THEN
	SELECT MAX(i.TranId) INTO vTranId
	FROM VBP_TRAN_INPUT i;
    END IF;

    -- 002: Lay ra NewTranId
    SELECT NVL(MAX(Id),0) INTO vNewTranId
    FROM TLG@PRO_TWO t
    WHERE t.ID >= vTranId AND t.Time < SYSDATE - K_TRAN_TIME_TRUOC_IN_MINUTE * 1/24/60; --10 phut ;

    IF vNewTranId < vTranId THEN vNewTranId := vTranId; END IF;

    vBatchID := TO_NUMBER(TO_CHAR(SYSDATE, 'DDHH24MISS'));

    -- 003: Tim kiem du lieu giao dich moi
    INSERT INTO VBP_TRAN_INPUT i(Id, TranId, TranTime, Amount, Currency
	, ApprovalCode, InvoiceNum, RespCode, RevRequestId, TextMess
	, AmountOrig, CurrencyOrig, Pan, Account, AmountVND, Type
	, TranCode, TermId, TermFiId, MerchantId, MerchantName
	, TermOwner, TermLocation, PosCondition, AuthFiId, TermClass, DeclineReason
	, PaymentBranch, BatchId, Provider, CreateDate)
    SELECT SEQ_VBP_TRAN_INPUT.nextval Id
	, t.*, NVL(rt.BranchPart, m.BranchPart) PaymentBranch, vBatchID BatchId
	, m.Provider, SYSDATE CreateDate
    FROM (
	select t.Id TranId, t.Time TranTime, t.Amount, t.Currency, t.ApprovalCode, t.InvoiceNum
	    , t.RespCode, t.RevRequestId, VBP_PKG_CORE.GET_TEXTMESS(t.TextMess) TextMess, t.AmountOrig, t.CurrencyOrig
	    , t.Pan, t.FromAcct Account, t.AmountAcct AmountVND, t.Type, t.TranCode, t.TermName TermId
	    , t.TermFiiD, t.TermRetailerName MerchantId, t.TermRetailerName MerchantName
	    , t.TermOwner, t.TermLocation, t.PosCondition, t.AuthFiId, t.TermClass, t.DeclineReason --, 0 BatchId, SYSDATE
	from tla@PRO_TWO t
	where t.id > vTranId - 1000 AND t.id <=vNewTranId
	UNION
	select t.Id TranId, t.Time TranTime, t.Amount, t.Currency, t.ApprovalCode, t.InvoiceNum
	    , t.RespCode, t.RevRequestId, VBP_PKG_CORE.GET_TEXTMESS(t.TextMess) TextMess, t.AmountOrig, t.CurrencyOrig
	    , t.Pan, t.FromAcct Account, t.AmountAcct AmountVND, t.Type, t.TranCode, t.TermName TermId
	    , t.TermFiiD, t.TermRetailerName MerchantId, t.TermRetailerName MerchantName
	    , t.TermOwner, t.TermLocation, t.PosCondition, t.AuthFiId, t.TermClass, t.DeclineReason --, 0 BatchId, SYSDATE
	from tlg@PRO_TWO t
	where t.id > vTranId - 1000 AND t.id <=vNewTranId
    ) t
	left join VBP_MERCHANT m on t.MerchantId = m.MerchantId
	left join VBP_TERMINAL rt on t.TermId = rt.Tid	--A4M.TReferenceTerminal rt on t.TermId = RT.IDENT and 1 = rt.Branch
	left join VBP_TRAN_INPUT i on t.TranId = i.TranId
    where i.TranId IS NULL -- t.TextMess is not null and t.Textmess like '%~31%~32%'
	AND (m.MerchantId IS NOT NULL OR rt.Tid IS NOT NULL)
    ;

    vCount := sql%rowcount;
    DBMS_OUTPUT.PUT_LINE('New: ' || vCount || ' - MaxTranId: ' || vNewTranId);
    COMMIT;
    -- Update GD Dao
    FOR x IN (
	SELECT i.TranId, i.RevRequestId, i.TranTime
	FROM VBP_TRAN_INPUT i
	WHERE i.TranId > vTranId - 1000
	    AND NVL(i.Type,0) = 420
    ) LOOP
	-- Cap nhat giao dich dao nguoc lai
	UPDATE VBP_TRAN_INPUT r
	SET r.RevRequestId = X.TranId, r.UpdateDate = SYSDATe
	    , r.DeclineReason = 'VBP: Update Reversal: ' || TO_CHAR(x.TranTime, 'MM-YY HH24:MI:SS')
	WHERE r.TranId = x.RevRequestId AND NVL(r.RevRequestId,0) = 0;
	COMMIT;
    END LOOP;

    SET_CFG_VARIABLE_VALUE(K_SCAN_JOB_NAME, K_SCAN_VAR_NAME, vNewTranId);
    COMMIT;
END;

PROCEDURE PARSE_BILL_FROM_NEW_TRANS
AS
    vCount NUMBER := 0;
BEGIN

UPDATE VBP_TRAN_INPUT i
SET i.ResultCode = K_RESULT_INVALID_TRAN_CODE
WHERE i.ResultCode = K_RESULT_NEW AND i.TranCode NOT IN (110, 111, 113);
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:NoTranCode: ' || vCount);
COMMIT;

UPDATE VBP_TRAN_INPUT i
SET i.ResultCode = K_RESULT_TRAN_IS_FAIL
WHERE i.ResultCode = K_RESULT_NEW AND i.RespCode <> 1;
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:RespCode Fail: ' || vCount);
COMMIT;

-- COMMIT: Xu ly cac truong hop khac
UPDATE VBP_TRAN_INPUT t
SET t.ResultCode = K_RESULT_IS_REVERSAL
WHERE t.ResultCode = K_RESULT_NEW AND (t.Type IN (420) OR NVL(T.REVREQUESTID,0) > 0);
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:Reversal: ' || vCount);
COMMIT;

-- COMMIT
UPDATE VBP_TRAN_INPUT i
SET i.ResultCode = K_RESULT_TEXTMESS_EMPTY
WHERE i.ResultCode = K_RESULT_NEW AND ( I.TEXTMESS IS NULL OR NVL(LENGTH(I.TextMess),0) = 0 )
    AND I.PROVIDER = K_PROVIDER_EVN;
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:TextMess Empty: ' || vCount);
COMMIT;

-- COMMIT
UPDATE VBP_TRAN_INPUT i
SET i.ResultCode = K_RESULT_TEXTMESS_WRONG
WHERE i.ResultCode = K_RESULT_NEW AND I.TEXTMESS IS NOT NULL
    AND I.TextMess Not like '%~31%~32%'
    AND I.PROVIDER = K_PROVIDER_EVN;
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:TextMess Wrong: ' || vCount);
COMMIT;

-- COMMIT: Truong hop CustomerId is null
UPDATE VBP_TRAN_INPUT t
SET T.ResultCode = K_RESULT_INVALID_CUSTOMER
WHERE t.ResultCode = K_RESULT_NEW AND t.TranCode IN (110, 111, 113) AND NVL(t.Amount,0) > 0
    AND t.PROVIDER = K_PROVIDER_EVN
    AND NVL(LENGTH(VBP_PKG_CORE.TEXTMESS_GET_CUSTOMER_ID(t.TextMess)),0) = 0;
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:Customer Empty: ' || vCount);
COMMIT;

-- COMMIT: Xu ly cac truong hop con lai
INSERT INTO VBP_BILL(ID, CreateDate, RequestDate, RequestId
    , SOURCEID, SOURCENAME, CustomerId, MaHoaDon, KyCuoc, Amount, TermLocation
    , TranDate, PaymentBranch, PointServiceCode, RequestType, TerminalType)
SELECT SEQ_VBP_BILL.nextval Id, SYSDATE CreateDate, NULL RequestDate, SEQ_VBP_BILL_REQUEST_ID.nextval RequestId
    , t.TranId SourceId, 'TWO' SourceName, t.CustomerId, t.MaHoaDon, t.KyCuoc
    , NVL(Decode(t.Currency, 704, t.Amount, AmountVND),0) Amount
    , NVL(t.TermLocation, t.TermOwner) TermLocation
    , t.TranTime TranDate, t.PaymentBranch
    , '211701' PointServiceCode --POS: tuong ung voi TermClass = 2 (POS)
    , 1 RequestType -- RequestType.PAYMENT
    , case when t.TermClass = 2 then 'P' when t.TermClass = 1 then 'A' else 'P' end TerminalType
FROM (
    SELECT t.TranId, t.Currency, t.Amount, t.AmountVND, t.TermLocation, t.TermOwner, t.TranTime, t.PaymentBranch
	, t.TermClass, t.TranCode, t.Type
	, VBP_PKG_CORE.TEXTMESS_GET_CUSTOMER_ID(t.TextMess) CustomerId
	, VBP_PKG_CORE.TEXTMESS_GET_KY_CUOC(t.TextMess) KyCuoc
	, SUBSTR(VBP_PKG_CORE.TEXTMESS_GET_BILL_ID(t.TextMess), 1, 30) MaHoaDon
	, t.RevRequestId
    FROM VBP_TRAN_INPUT t
    WHERE t.Provider = K_PROVIDER_EVN AND t.ResultCode = K_RESULT_NEW AND t.TranCode IN (110, 111, 113) AND NVL(t.Amount,0) > 0
	AND t.Type Not IN (420) AND NVL(t.RevRequestId,0) = 0
) t
    LEFT JOIN VBP_BILL b on t.TranId = B.SOURCEID and 'TWO' = b.SourceName
WHERE t.CustomerId IS NOT NULL -- AND t.KyCuoc Is NOT NULL
    AND B.ID IS NULL
;
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:New Bill(s): ' || vCount);
COMMIT;

UPDATE VBP_TRAN_INPUT t
SET t.ResultCode = K_RESULT_SUCCESS
WHERE T.Provider = K_PROVIDER_EVN AND t.ResultCode = K_RESULT_NEW
    AND t.TranId = (
	SELECT SourceId FROM VBP_BILL b WHERE b.SourceName = 'TWO'
	AND b.SourceId = TranId
);
vCount := sql%rowcount;
DBMS_OUTPUT.PUT_LINE('NewTrans:Update New Tran''s status: ' || vCount);
COMMIT;

END;

PROCEDURE BILL_CHANGE_TO_REPAYMENT(
    pId 	     IN NUMBER
    , pUpdateUser    IN VARCHAR2
    , poCount	     OUT NUMBER
/** NOTE@2014.09.06:
*   - Cho phep gan lai Status de quet lai giao dich doi voi cac GD BILL bi FAIL.
**/) AS
    vBill VBP_BILL%ROWTYPE; voRequestId NUMBER := 0;
BEGIN
    poCount := 0;
    SAVEPOINT svPoint;

    SELECT b.* INTO vBill
    FROM VBP_BILL b WHERE b.Id = pId;

    IF vBill.Status NOT IN (0, 1, 2) AND vBill.ResultCode Not IN (0, 1, 2) THEN
	VBP_PKG_CORE.BILL_GENERATE_NEW_REQUEST_ID(voRequestId);

	UPDATE VBP_BILL x
	SET x.Status = K_RESULT_NEW, x.ResultCode = K_RESULT_NEW--, x.RequestRetry = x.RequestRetry + 1 -- Trong Code da ++, nen ko su dung trong day
	    , x.UpdateDate = SYSDATE, x.RequestId = voRequestId
	WHERE x.Id = pId AND x.Status NOT IN (1,2) AND x.ResultCode NOT IN (1,2) -- Chua phai gach no thanh cong
	;
	poCount := sql%rowcount;
    END IF;

    INSERT INTO VBP_LOG(App, Id, LogDate, LogStr)
    VALUES('VBP-REPAYMENT', vBill.ID, SYSDATE,
	    'UpdateUser: '	|| pUpdateUser	 ||
	    ' | OK: '		|| poCount	 ||
	    ' | RequestId: '	|| vBill.RequestId   ||
	    ' | Status: '	|| vBill.Status      ||
	    ' | ResultCode: '	|| vBill.ResultCode  ||
	    ' | TelcoBillId: '	|| vBill.TelcoBillId ||
	    ' | TelcoAmount: '	|| vBill.TelcoBillAmount ||
	    ' | TelcoKyCuoc: '	|| vBill.TelcoKyCuoc ||
	    ' | UpdateDate: '	|| TO_CHAR(vBill.UpdateDate, 'MM-YY HH24:MI:SS'));
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE;
    WHEN OTHERS THEN ROLLBACK TO svPoint; RAISE;
END;


FUNCTION GET_TEXTMESS(
    pTextMess IN VARCHAR2
/** NOTE@2014.07.04: Remove cac ky tu dac biet cua TextMess **/
) RETURN VARCHAR2
AS
    vReturnText VARCHAR2(4000);
BEGIN
    vReturnText := REPLACE(pTextMess, CHR(0), '');
    vReturnText := REPLACE(vReturnText, CHR(24), '~');
    vReturnText := REPLACE(vReturnText, CHR(8), '~');
    vReturnText := REPLACE(vReturnText, CHR(16), '~');
    vReturnText := REPLACE(vReturnText, CHR(18), '~');
    vReturnText := REPLACE(vReturnText, CHR(21), '~');
    vReturnText := REPLACE(vReturnText, CHR(24), '~'); --
    RETURN vReturnText;
END;

FUNCTION GET_BATCH_ID RETURN NUMBER
AS
BEGIN
RETURN SEQ_VBP_BATCH_ID.nextval;
END;

PROCEDURE BILL_GENERATE_NEW_REQUEST_ID(poRequestId OUT NUMBER)
AS
BEGIN
SELECT SEQ_VBP_BILL_REQUEST_ID.nextval into poRequestId From DUAL;
END;

FUNCTION TEXTMESS_GET_CUSTOMER_ID(pTextMess IN VARCHAR2
/** Note@2014.07.11
*   - Lay ra CustomerId truyen vao, F31, bat dau boi ~31[13 ky tu]
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2
AS
    vCustomerId VARCHAR2(100);
    vPos NUMBER;
BEGIN
    vCustomerId := NULL;
    IF pTextMess IS NOT NULL THEN
	vPos := INSTR(pTextMess, '~31');
	IF vPos > 0 THEN
	    vCustomerId := SUBSTR(pTextMess, vPos + 3, 13);
	END IF;
    END IF;
    RETURN vCustomerId;
END;

FUNCTION TEXTMESS_GET_KY_CUOC(pTextMess IN VARCHAR2
/** Note@2014.07.11
*   - Lay ra CustomerId truyen vao, F32, bat dau boi ~32[7 ky tu]: ~3103/1012
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2
AS
    vCustomerId VARCHAR2(100);
    vPos NUMBER;
BEGIN
    vCustomerId := NULL;
    IF pTextMess IS NOT NULL THEN
	vPos := INSTR(pTextMess, '~32');
	IF vPos > 0 THEN
	    vCustomerId := SUBSTR(pTextMess, vPos + 3, 7);
	END IF;
    END IF;
    RETURN vCustomerId;
END;

FUNCTION TEXTMESS_GET_BILL_ID(pTextMess IN VARCHAR2
/** Note@2014.08.04
*   - Lay ra BillId truyen vao, F35, bat dau boi ~35[BillId]~...
*   - Boi vi ham GET_TEXTMESS da thay the cac ki tu dac biet thanh ~
**/
) RETURN VARCHAR2
AS
    vBillId VARCHAR2(100);
    vPos NUMBER;
    vPosEnd NUMBER;
BEGIN
    vBillId := NULL;
    IF pTextMess IS NOT NULL THEN
	vPos := INSTR(pTextMess, '~35');
	IF vPos > 0 THEN
	    vPosEnd := INSTR(pTextMess, '~', vPos + 1);
	    DBMS_OUTPUT.PUT_LINE('vPos: ' || vPos);
	    DBMS_OUTPUT.PUT_LINE('vPosEnd: ' || vPosEnd);
	    IF NVL(vPosEnd,0) <= 0 THEN vPosEnd := LENGTH(pTextMess) + 1; END IF;
	    vBillId := SUBSTR(pTextMess, vPos + 3, vPosEnd - 1 - (vPos + 3) + 1);
	END IF;
    END IF;
    RETURN vBillId;
END;


FUNCTION GET_CFG_VARIABLE_VALUE(pJobName VARCHAR2, pVarName VARCHAR2
/** NOTE@2014.07.14:
*   - Lay ra gia tri Variable cua JOB [pJobName] - bien [pVarName]
*   - Tra ve Null neu ko co gia tri
**/
) RETURN VARCHAR2
AS vVarValue VARCHAR2(1000);
BEGIN
    vVarValue := NULL;

    SELECT TO_NUMBER(v.VarValue) INTO vVarValue
    FROM VBP_VARIABLE v
    WHERE v.JobName = pJobName AND v.VarName = pVarName;
    RETURN vVarValue;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN vVarValue;
    WHEN OTHERS THEN RAISE;
END;

PROCEDURE SET_CFG_VARIABLE_VALUE(pJobName VARCHAR2, pVarName VARCHAR2, pVarValue VARCHAR2
/** NOTE@2014.07.14:
*   - Gan gia tri [pVarValue] cua JOB [pJobName] - bien [pVarName]
**/
) AS --vCount NUMBER := 0;
BEGIN
INSERT INTO VBP_VARIABLE(JobName, VarName, VarValue, UpdateDate)
VALUES (pJobName, pVarName, pVarValue, SYSDATE);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
	UPDATE VBP_VARIABLE v
	SET v.VarValue = pVarValue, v.UpdateDate = SYSDATE
	WHERE v.JobName = pJobName AND v.VarName = pVarName;
    WHEN OTHERS THEN RAISE;
END;

END;