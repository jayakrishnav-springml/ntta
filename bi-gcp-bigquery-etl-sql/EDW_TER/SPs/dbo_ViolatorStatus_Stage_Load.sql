CREATE PROC [dbo].[ViolatorStatus_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'dbo.ViolatorStatus', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.ViolatorStatus_Stage')>0
	DROP TABLE dbo.ViolatorStatus_Stage

CREATE TABLE dbo.ViolatorStatus_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 

SELECT  
	  A.ViolatorStatusID
	, A.ViolatorID
	, A.VidSeq
	, HvFlag
	, HvDate
	, ViolatorStatusLookupID
	, HvExemptFlag
	, ISNULL(HvExemptDate,'1/1/1900') AS HvExemptDate
	, ISNULL(ViolatorStatusTermLookupID,-1) AS ViolatorStatusTermLookupID
	, TermFlag
	, ISNULL(TermDate,'1/1/1900') AS TermDate
	, ViolatorStatusEligRmdyLookupID
	, EligRmdyFlag
	, ISNULL(EligRmdyDate,'1/1/1900') AS EligRmdyDate
	, BanFlag
	, ISNULL(BanDate,'1/1/1900') AS BanDate
	, ISNULL(BanStartDate,'1/1/1900') AS BanStartDate
	, BanCiteWarnFlag
	, ISNULL(BanCiteWarnDate,'1/1/1900') AS BanCiteWarnDate
	, BanCiteWarnCount
	, BanImpoundFlag
	, ISNULL(BanImpoundDate,'1/1/1900') AS BanImpoundDate
	, ISNULL(VrbFlag,-1) AS VrbFlag
	, ISNULL(VrbDate,'1/1/1900') AS VrbDate
	, ISNULL(ViolatorStatusLetterDeterminationLookupID,-1) AS ViolatorStatusLetterDeterminationLookupID
	, DeterminationLetterFlag
	, ISNULL(DeterminationLetterDate,'1/1/1900') AS DeterminationLetterDate
	, ISNULL(ViolatorStatusLetterBanLookupID,-1) AS ViolatorStatusLetterBanLookupID
	, BanLetterFlag
	, ISNULL(BanLetterDate,'1/1/1900') AS BanLetterDate
	, ISNULL(ViolatorStatusLetterTermLookupID,-1) AS ViolatorStatusLetterTermLookupID
	, TermLetterFlag
	, ISNULL(TermLetterDate,'1/1/1900') AS TermLetterDate
	, B.HvQAmountDue, B.HvQTollsDue, B.HvQTransactions, B.HvQFeesDue, B.TotalAmountDue--B.TotalAmountDueInitial, 
	, B.TotalTollsDue, B.TotalFeesDue, B.TotalCitationCount, B.TotalTransactionsCount--B.TotalTransactionsInitial, 
	, C.SettlementAmount, C.DownPayment, C.Collections, C.PaidInFull, C.DefaultInd
	, C.AdminFees, C.CitationFees, C.MonthlyPaymentAmount, C.BalanceDue
	, D.ExcusedAmount, D.CollectableAmount, D.BankruptcyInd
	, ISNULL(A.Ban2ndLetterDate,'1/1/1900') AS Ban2ndLetterDate
    , ISNULL(A.Ban2ndLetterFlag,-1)  AS Ban2ndLetterFlag
    , ISNULL(A.ViolatorStatusLetterBan2ndLookupID,-1)  AS ViolatorStatusLetterBan2ndLookupID
    , ISNULL(A.ViolatorStatusLetterVrbLookupID,-1)  AS ViolatorStatusLetterVrbLookupID
	, ISNULL(A.VrbLetterDate,'1/1/1900') AS VrbLetterDate
    , ISNULL(A.VrbLetterFlag,-1)  AS VrbLetterFlag
	, ISNULL(BanDPSCount,0) AS BanDPSCount
	, ISNULL(BanPCPCount,0) AS BanPCPCount
	, ISNULL(BanWarnCount,0) AS BanWarnCount
	, ISNULL(BanCitationCount,0) AS BanCitationCount
	, ISNULL(BanImpoundCount,0) AS BanImpoundCount
	, ISNULL(BanNoActionCount,0) AS BanNoActionCount
	, ISNULL(BanFennellCount,0) AS BanFennellCount
	, A.LAST_UPDATE_TYPE AS  ViolatorStatus_LAST_UPDATE_TYPE, B.LAST_UPDATE_TYPE AS ViolatorAmountsSummary_LAST_UPDATE_TYPE
	, A.LAST_UPDATE_DATE As ViolatorStatus_LAST_UPDATE_DATE, B.LAST_UPDATE_DATE AS ViolatorAmountsSummary_LAST_UPDATE_DATE
FROM LND_TER.dbo.ViolatorStatus A
LEFT JOIN LND_TER.dbo.ViolatorAmountsSummary B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
LEFT JOIN dbo.ViolatorCase_PaymentAgreement_Stage C ON A.ViolatorID = C.ViolatorID AND A.VidSeq = C.VidSeq
LEFT JOIN dbo.ViolatorCase_Bankruptcy_Stage D ON A.ViolatorID = D.ViolatorID AND A.VidSeq = D.VidSeq
LEFT JOIN 
(
	SELECT ViolatorId, VidSeq, SUM(BanDPS) AS BanDPSCount, SUM(BanPCP) AS BanPCPCount, SUM(BanWarn) AS BanWarnCount, SUM(BanCitation) AS BanCitationCount, SUM(BanImpound) AS BanImpoundCount, SUM(BanNoAction) AS BanNoActionCount, SUM(BanFennell) AS BanFennellCount
	FROM 
	(
		SELECT ViolatorId, VidSeq
			, CASE WHEN BanActionLookupId = 1 THEN 1 ELSE 0 END AS 'BanDPS'
			, CASE WHEN BanActionLookupId = 2 THEN 1 ELSE 0 END AS 'BanPCP'
			, CASE WHEN BanActionLookupId = 3 THEN 1 ELSE 0 END AS 'BanWarn'
			, CASE WHEN BanActionLookupId = 4 THEN 1 ELSE 0 END AS 'BanCitation'
			, CASE WHEN BanActionLookupId = 5 THEN 1 ELSE 0 END AS 'BanImpound'
			, CASE WHEN BanActionLookupId = 6 THEN 1 ELSE 0 END AS 'BanNoAction'
			, CASE WHEN BanActionLookupId = 7 THEN 1 ELSE 0 END AS 'BanFennell'
		FROM dbo.Ban
	) A
	GROUP BY ViolatorId, VidSeq
) BanCounts ON A.ViolatorID = BanCounts.ViolatorID AND A.VidSeq = BanCounts.VidSeq

--WHERE 
--	A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
--	OR 
--	B.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
OPTION (LABEL = 'ViolatorStatus_Stage_Load: ViolatorStatus_Stage');

CREATE STATISTICS STATS_ViolatorStatus_Stage_Load_001 ON dbo.ViolatorStatus_Stage (ViolatorID, VidSeq)









