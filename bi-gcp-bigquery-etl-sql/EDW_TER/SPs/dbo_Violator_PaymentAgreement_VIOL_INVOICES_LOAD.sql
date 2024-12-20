CREATE PROC [DBO].[Violator_PaymentAgreement_VIOL_INVOICES_LOAD] AS 

IF OBJECT_ID('dbo.Violator_PaymentAgreement_Current')>0
	DROP TABLE dbo.Violator_PaymentAgreement_Current

CREATE TABLE dbo.Violator_PaymentAgreement_Current WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
	SELECT A.ViolatorID, A.VidSeq, MAX(InstanceNbr) AS InstanceNbr
	FROM dbo.Violator_PaymentAgreement A
	INNER JOIN 	
		(
			SELECT ViolatorID, MAX(VidSeq) AS VidSeq
			FROM dbo.Violator A
--			WHERE A.ViolatorID = 739717108
			GROUP BY ViolatorID
		) B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
	GROUP BY A.ViolatorID, A.VidSeq

--CREATE STATISTICS STATS_Violator_PaymentAgreement_Current_001 ON dbo.Violator_PaymentAgreement_Current (ViolatorID)
--CREATE STATISTICS STATS_Violator_PaymentAgreement_Current_002 ON dbo.Violator_PaymentAgreement_Current (ViolatorID, VidSeq)
--CREATE STATISTICS STATS_Violator_PaymentAgreement_Current_003 ON dbo.Violator_PaymentAgreement_Current (ViolatorID, VidSeq, InstanceNbr)


IF OBJECT_ID('dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds')>0
	DROP TABLE dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds

CREATE TABLE dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
	SELECT A.ViolatorID, A.VidSeq, A.InstanceNbr, A.ViolatorID AS AltViolatorId
	FROM dbo.Violator_PaymentAgreement_Current A
	INNER JOIN dbo.Violator_PaymentAgreement B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	UNION ALL
	SELECT A.ViolatorID, A.VidSeq, A.InstanceNbr, B.ViolatorID2 AS AltViolatorId
	FROM dbo.Violator_PaymentAgreement_Current A
	INNER JOIN dbo.Violator_PaymentAgreement B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	WHERE LEN(ViolatorID2)>1
	UNION ALL
	SELECT A.ViolatorID, A.VidSeq, A.InstanceNbr, B.ViolatorID3 AS AltViolatorId
	FROM dbo.Violator_PaymentAgreement_Current A
	INNER JOIN dbo.Violator_PaymentAgreement B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	WHERE LEN(ViolatorID3)>1
	UNION ALL
	SELECT A.ViolatorID, A.VidSeq, A.InstanceNbr, B.ViolatorID4 AS AltViolatorId
	FROM dbo.Violator_PaymentAgreement_Current A
	INNER JOIN dbo.Violator_PaymentAgreement B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	WHERE LEN(ViolatorID4)>1

CREATE STATISTICS STATS_Violator_PaymentAgreement_Current_with_Other_ViolatorIds_001 ON dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds (AltViolatorId)


IF OBJECT_ID('dbo.Violator_PaymentAgreement_VIOL_INVOICES')>0
	DROP TABLE dbo.Violator_PaymentAgreement_VIOL_INVOICES

CREATE TABLE dbo.Violator_PaymentAgreement_VIOL_INVOICES WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID)) 
AS 
-- EXPLAIN
SELECT B.ViolatorID, B.VidSeq, InstanceNbr, A.VIOLATOR_ID As AltViolatorId, A.VIOL_INVOICE_ID, A.INVOICE_DATE
	, A.INVOICE_AMOUNT, A.INVOICE_AMT_PAID, A.VIOL_INV_BATCH_ID, A.VIOL_INV_STATUS
	, InvDtl.TOLL_DUE_AMOUNT, InvDtl.FINE_AMOUNT, InvDtl.PAID_AMOUNT
	, C.VIOL_INV_STATUS_DESCR, A.STATUS_DATE AS INVOICE_STATUS_DATE
FROM EDW_RITE.dbo.VIOL_INVOICES A
INNER JOIN (SELECT DISTINCT AltViolatorId, ViolatorID, VidSeq, InstanceNbr FROM  dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds) B ON A.VIOLATOR_ID = B.AltViolatorId
INNER JOIN 
	(
		SELECT AAA.VIOLATOR_ID, AAA.VIOL_INVOICE_ID
			, SUM(AAA.TOLL_DUE_AMOUNT) AS TOLL_DUE_AMOUNT
			, SUM(FINE_AMOUNT) AS FINE_AMOUNT
			, SUM(PAID_AMOUNT) AS PAID_AMOUNT
		FROM 
		(
			SELECT VI.VIOLATOR_ID, AA.VIOL_INVOICE_ID
				, SUM(AA.TOLL_DUE_AMOUNT) AS TOLL_DUE_AMOUNT, SUM(AA.FINE_AMOUNT) AS FINE_AMOUNT 
				, CASE WHEN AA.VIOL_STATUS IN ('C1','T','K','O','P') THEN SUM(AA.TOLL_DUE_AMOUNT) + SUM(AA.FINE_AMOUNT) ELSE 0 END AS PAID_AMOUNT
			FROM EDW_RITE.dbo.VIOL_INVOICE_VIOL AA 
			INNER JOIN EDW_RITE.dbo.VIOL_INVOICES VI ON VI.VIOL_INVOICE_ID = AA.VIOL_INVOICE_ID
			INNER JOIN (SELECT DISTINCT AltViolatorId FROM  dbo.Violator_PaymentAgreement_Current_with_Other_ViolatorIds) BB ON VI.VIOLATOR_ID = BB.AltViolatorId
			GROUP BY VI.VIOLATOR_ID, AA.VIOL_INVOICE_ID, AA.VIOL_STATUS
		) AAA
		GROUP BY AAA.VIOLATOR_ID, AAA.VIOL_INVOICE_ID

	) InvDtl ON A.VIOLATOR_ID = InvDtl.VIOLATOR_ID AND A.VIOL_INVOICE_ID = InvDtl.VIOL_INVOICE_ID
INNER JOIN LND_LG_VPS.VP_OWNER.VIOL_INV_STATUS C ON A.VIOL_INV_STATUS = C.VIOL_INV_STATUS

CREATE STATISTICS STATS_Violator_PaymentAgreement_VIOL_INVOICES_001 ON dbo.Violator_PaymentAgreement_VIOL_INVOICES (VIOL_INVOICE_ID)





IF OBJECT_ID('dbo.Violator_PaymentAgreement_VIOL_INVOICE_CA_ACCT_ID')>0
	DROP TABLE dbo.Violator_PaymentAgreement_VIOL_INVOICE_CA_ACCT_ID

CREATE TABLE dbo.Violator_PaymentAgreement_VIOL_INVOICE_CA_ACCT_ID WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VIOL_INVOICE_ID)) 
AS 
-- EXPLAIN
SELECT A.VIOL_INVOICE_ID, MAX(A.CA_ACCT_ID) AS CA_ACCT_ID
FROM edw_rite.dbo.CA_ACCT_INV_XREF A
INNER JOIN dbo.Violator_PaymentAgreement_VIOL_INVOICES B  ON A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
--WHERE VIOL_INVOICE_ID = 82914774
GROUP BY A.VIOL_INVOICE_ID



--GO

--SELECT TOP 100 * FROM EDW_RITE.dbo.VIOL_INVOICE_VIOL

--SELECT * FROM VIOL_STATUS

-- SELECT * FROM LND_LG_VPS.[VP_OWNER].CA_ACCT_INV_XREF


--SELECT TOP 100 * FROM  EDW_RITE.dbo.VIOL_INVOICES 
--SELECT * FROM Violator_PaymentAgreement_VIOL_INVOICES WHERE INVOICE_AMT_PAID <> PAID_AMOUNT
