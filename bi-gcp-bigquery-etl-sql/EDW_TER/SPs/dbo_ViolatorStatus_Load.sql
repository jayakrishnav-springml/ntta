CREATE PROC [dbo].[ViolatorStatus_Load] AS

UPDATE dbo.ViolatorStatus
	SET 
		  dbo.ViolatorStatus.ViolatorStatusID = B.ViolatorStatusID
		, dbo.ViolatorStatus.HvFlag = B.HvFlag
		, dbo.ViolatorStatus.HvDate = B.HvDate
		, dbo.ViolatorStatus.ViolatorStatusLookupID = B.ViolatorStatusLookupID
		, dbo.ViolatorStatus.HvExemptFlag = B.HvExemptFlag
		, dbo.ViolatorStatus.HvExemptDate = B.HvExemptDate
		, dbo.ViolatorStatus.ViolatorStatusTermLookupID = B.ViolatorStatusTermLookupID
		, dbo.ViolatorStatus.TermFlag = B.TermFlag
		, dbo.ViolatorStatus.TermDate = B.TermDate
		, dbo.ViolatorStatus.ViolatorStatusEligRmdyLookupID = B.ViolatorStatusEligRmdyLookupID
		, dbo.ViolatorStatus.EligRmdyFlag = B.EligRmdyFlag
		, dbo.ViolatorStatus.EligRmdyDate = B.EligRmdyDate
		, dbo.ViolatorStatus.BanFlag = B.BanFlag
		, dbo.ViolatorStatus.BanDate = B.BanDate
		, dbo.ViolatorStatus.BanStartDate = B.BanStartDate
		, dbo.ViolatorStatus.BanCiteWarnFlag = B.BanCiteWarnFlag
		, dbo.ViolatorStatus.BanCiteWarnDate = B.BanCiteWarnDate
		, dbo.ViolatorStatus.BanCiteWarnCount = B.BanCiteWarnCount
		, dbo.ViolatorStatus.BanImpoundFlag = B.BanImpoundFlag
		, dbo.ViolatorStatus.BanImpoundDate = B.BanImpoundDate
		, dbo.ViolatorStatus.VrbFlag = B.VrbFlag
		, dbo.ViolatorStatus.VrbDate = B.VrbDate
		, dbo.ViolatorStatus.ViolatorStatusLetterDeterminationLookupID = B.ViolatorStatusLetterDeterminationLookupID
		, dbo.ViolatorStatus.DeterminationLetterFlag = B.DeterminationLetterFlag
		, dbo.ViolatorStatus.DeterminationLetterDate = B.DeterminationLetterDate
		, dbo.ViolatorStatus.ViolatorStatusLetterBanLookupID = B.ViolatorStatusLetterBanLookupID
		, dbo.ViolatorStatus.BanLetterFlag = B.BanLetterFlag
		, dbo.ViolatorStatus.BanLetterDate = B.BanLetterDate
		, dbo.ViolatorStatus.ViolatorStatusLetterTermLookupID = B.ViolatorStatusLetterTermLookupID
		, dbo.ViolatorStatus.TermLetterFlag = B.TermLetterFlag
		, dbo.ViolatorStatus.TermLetterDate = B.TermLetterDate
		, dbo.ViolatorStatus.HvQAmountDue = B.HvQAmountDue
		, dbo.ViolatorStatus.HvQTollsDue = B.HvQTollsDue
		, dbo.ViolatorStatus.HvQTransactions = B.HvQTransactions
		, dbo.ViolatorStatus.HvQFeesDue = B.HvQFeesDue
		--, dbo.ViolatorStatus.TotalAmountDueInitial = B.TotalAmountDueInitial
		, dbo.ViolatorStatus.TotalAmountDue = B.TotalAmountDue
		, dbo.ViolatorStatus.TotalTollsDue = B.TotalTollsDue
		, dbo.ViolatorStatus.TotalFeesDue = B.TotalFeesDue
		, dbo.ViolatorStatus.TotalCitationCount = B.TotalCitationCount
		--, dbo.ViolatorStatus.TotalTransactionsInitial = B.TotalTransactionsInitial
		, dbo.ViolatorStatus.TotalTransactionsCount = B.TotalTransactionsCount
		, dbo.ViolatorStatus.SettlementAmount = B.SettlementAmount
		, dbo.ViolatorStatus.DownPayment = B.DownPayment
		, dbo.ViolatorStatus.Collections = B.Collections
		, dbo.ViolatorStatus.PaidInFull = B.PaidInFull
		, dbo.ViolatorStatus.DefaultInd = B.DefaultInd
		, dbo.ViolatorStatus.AdminFees = B.AdminFees
		, dbo.ViolatorStatus.CitationFees = B.CitationFees
		, dbo.ViolatorStatus.MonthlyPaymentAmount = B.MonthlyPaymentAmount
		, dbo.ViolatorStatus.BalanceDue = B.BalanceDue
		, dbo.ViolatorStatus.ExcusedAmount = B.ExcusedAmount
		, dbo.ViolatorStatus.CollectableAmount = B.CollectableAmount
		, dbo.ViolatorStatus.BankruptcyInd = B.BankruptcyInd

		, dbo.ViolatorStatus.Ban2ndLetterDate = B.Ban2ndLetterDate
		, dbo.ViolatorStatus.Ban2ndLetterFlag = B.Ban2ndLetterFlag
		, dbo.ViolatorStatus.ViolatorStatusLetterBan2ndLookupID = B.ViolatorStatusLetterBan2ndLookupID
		, dbo.ViolatorStatus.ViolatorStatusLetterVrbLookupID = B.ViolatorStatusLetterVrbLookupID
		, dbo.ViolatorStatus.VrbLetterDate = B.VrbLetterDate
		, dbo.ViolatorStatus.VrbLetterFlag = B.VrbLetterFlag

		, dbo.ViolatorStatus.BanDPSCount = B.BanDPSCount
		, dbo.ViolatorStatus.BanPCPCount = B.BanPCPCount
		, dbo.ViolatorStatus.BanWarnCount = B.BanWarnCount
		, dbo.ViolatorStatus.BanCitationCount = B.BanCitationCount
		, dbo.ViolatorStatus.BanImpoundCount = B.BanImpoundCount
		, dbo.ViolatorStatus.BanNoActionCount = B.BanNoActionCount
		, dbo.ViolatorStatus.BanFennellCount = B.BanFennellCount

		, dbo.ViolatorStatus.LAST_UPDATE_DATE = CASE WHEN B.ViolatorStatus_LAST_UPDATE_DATE < B.ViolatorAmountsSummary_LAST_UPDATE_DATE THEN B.ViolatorStatus_LAST_UPDATE_DATE ELSE B.ViolatorAmountsSummary_LAST_UPDATE_DATE END 
FROM dbo.VIOLATORSTATUS_STAGE B
WHERE 
	dbo.ViolatorStatus.ViolatorId = B.ViolatorId AND dbo.ViolatorStatus.VidSeq = B.VidSeq
	--AND 
	--(ViolatorStatus_LAST_UPDATE_TYPE = 'U' OR ViolatorAmountsSummary_LAST_UPDATE_TYPE = 'U')


INSERT INTO DBO.ViolatorStatus
	(
		  ViolatorStatusID, ViolatorID, VidSeq, HvFlag, HvDate, ViolatorStatusLookupID
		, HvExemptFlag, HvExemptDate, ViolatorStatusTermLookupID, TermFlag, TermDate
		, ViolatorStatusEligRmdyLookupID, EligRmdyFlag, EligRmdyDate, BanFlag, BanDate
		, BanStartDate, BanCiteWarnFlag, BanCiteWarnDate, BanCiteWarnCount, BanImpoundFlag
		, BanImpoundDate, VrbFlag, VrbDate, ViolatorStatusLetterDeterminationLookupID, DeterminationLetterFlag
		, DeterminationLetterDate, ViolatorStatusLetterBanLookupID, BanLetterFlag, BanLetterDate
		, ViolatorStatusLetterTermLookupID, TermLetterFlag, TermLetterDate
		, HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDue--TotalAmountDueInitial, 
		, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsCount --TotalTransactionsInitial, 
		, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd
		, AdminFees, CitationFees, MonthlyPaymentAmount, BalanceDue
		, ExcusedAmount, CollectableAmount, BankruptcyInd
		, Ban2ndLetterDate, Ban2ndLetterFlag, ViolatorStatusLetterBan2ndLookupID
		, ViolatorStatusLetterVrbLookupID, VrbLetterDate, VrbLetterFlag
		, BanDPSCount, BanPCPCount, BanWarnCount, BanCitationCount, BanImpoundCount, BanNoActionCount, BanFennellCount
		, PMT_TYPE_CODE, acct_status_code
		, INSERT_DATE, LAST_UPDATE_DATE
		)
-- EXPLAIN
SELECT 
		  A.ViolatorStatusID, A.ViolatorID, A.VidSeq, A.HvFlag, A.HvDate, A.ViolatorStatusLookupID
		, A.HvExemptFlag, A.HvExemptDate, A.ViolatorStatusTermLookupID, A.TermFlag, A.TermDate
		, A.ViolatorStatusEligRmdyLookupID, A.EligRmdyFlag, A.EligRmdyDate, A.BanFlag, A.BanDate
		, A.BanStartDate, A.BanCiteWarnFlag, A.BanCiteWarnDate, A.BanCiteWarnCount, A.BanImpoundFlag
		, A.BanImpoundDate, A.VrbFlag, A.VrbDate, A.ViolatorStatusLetterDeterminationLookupID, A.DeterminationLetterFlag
		, A.DeterminationLetterDate, A.ViolatorStatusLetterBanLookupID, A.BanLetterFlag, A.BanLetterDate
		, A.ViolatorStatusLetterTermLookupID, A.TermLetterFlag, A.TermLetterDate
		, A.HvQAmountDue, A.HvQTollsDue, A.HvQTransactions, A.HvQFeesDue, A.TotalAmountDue  --A.TotalAmountDueInitial, 
		, A.TotalTollsDue, A.TotalFeesDue, A.TotalCitationCount, A.TotalTransactionsCount	--A.TotalTransactionsInitial, 
		, A.SettlementAmount, A.DownPayment, A.Collections, A.PaidInFull, A.DefaultInd
		, A.AdminFees, A.CitationFees, A.MonthlyPaymentAmount, A.BalanceDue
		, A.ExcusedAmount, A.CollectableAmount, A.BankruptcyInd

		, A.Ban2ndLetterDate, A.Ban2ndLetterFlag, A.ViolatorStatusLetterBan2ndLookupID
		, A.ViolatorStatusLetterVrbLookupID, A.VrbLetterDate, A.VrbLetterFlag
		, A.BanDPSCount, A.BanPCPCount, A.BanWarnCount, A.BanCitationCount, A.BanImpoundCount, A.BanNoActionCount, A.BanFennellCount
		, '-1' AS PMT_TYPE_CODE, '-1' AS acct_status_code
		, INSERT_DATE = CASE WHEN A.ViolatorStatus_LAST_UPDATE_DATE < A.ViolatorAmountsSummary_LAST_UPDATE_DATE THEN A.ViolatorStatus_LAST_UPDATE_DATE ELSE A.ViolatorAmountsSummary_LAST_UPDATE_DATE END 
		, LAST_UPDATE_DATE = CASE WHEN A.ViolatorStatus_LAST_UPDATE_DATE < A.ViolatorAmountsSummary_LAST_UPDATE_DATE THEN A.ViolatorStatus_LAST_UPDATE_DATE ELSE A.ViolatorAmountsSummary_LAST_UPDATE_DATE END 
FROM dbo.VIOLATORSTATUS_STAGE A
LEFT JOIN dbo.ViolatorStatus B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
WHERE 
	B.ViolatorID IS NULL AND B.VidSeq IS NULL
	--AND 
	--(ViolatorStatus_LAST_UPDATE_TYPE = 'I' OR ViolatorAmountsSummary_LAST_UPDATE_TYPE = 'I')

	
IF OBJECT_ID('dbo.ViolatorStatus_Event_Stage')>0
	DROP TABLE dbo.ViolatorStatus_Event_Stage

CREATE TABLE dbo.ViolatorStatus_Event_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
	SELECT ViolatorID, VidSeq, SUM(HVActive) AS HVActive, SUM(HVRemoved) AS HVRemoved
		, SUM(VrbAcknowledged) AS VrbAcknowledged
		, SUM(VrbRemoved) AS VrbRemoved, SUM(VrbRemovalQueued) AS VrbRemovalQueued
		, SUM(BanByProcessServer) AS BanByProcessServer, SUM(BanByDPS) AS BanByDPS
		, SUM(BanByUSMail1stBan) AS BanByUSMail1stBan
	FROM dbo.VW_Violator_EVENT
	GROUP BY ViolatorID, VidSeq

CREATE STATISTICS STATS_ViolatorStatus_Event_Stage_Load_001 ON dbo.ViolatorStatus_Event_Stage (ViolatorID, VidSeq)


UPDATE dbo.ViolatorStatus
	SET 
	  dbo.ViolatorStatus.HVActive = B.HVActive
	, dbo.ViolatorStatus.HVRemoved = B.HVRemoved
	, dbo.ViolatorStatus.VrbAcknowledged = B.VrbAcknowledged
	, dbo.ViolatorStatus.VrbRemoved = B.VrbRemoved
	, dbo.ViolatorStatus.VrbRemovalQueued = B.VrbRemovalQueued
	, dbo.ViolatorStatus.BanByProcessServer = B.BanByProcessServer
	, dbo.ViolatorStatus.BanByDPS = B.BanByDPS
	, dbo.ViolatorStatus.BanByUSMail1stBan = B.BanByUSMail1stBan
FROM dbo.ViolatorStatus_Event_Stage B
WHERE 
	dbo.ViolatorStatus.ViolatorId = B.ViolatorId AND dbo.ViolatorStatus.VidSeq = B.VidSeq




