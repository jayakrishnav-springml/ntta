CREATE PROC [dbo].[ViolatorStatus_Mart_Load] AS

	
IF OBJECT_ID('dbo.ViolatorStatus_Mart_Stage')>0
	DROP TABLE dbo.ViolatorStatus_Mart_Stage

CREATE TABLE dbo.ViolatorStatus_Mart_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
SELECT 
	   CONVERT(Date,Convert(varchar(10), GETDATE(),101)) as ReportDate, ViolatorID, VidSeq
	 , HvFlag, HvExemptFlag, TermFlag, EligRmdyFlag, BanFlag, BanCiteWarnFlag
--	 , BanCiteWarnCount
	 , BanImpoundFlag, VrbFlag, DeterminationLetterFlag, BanLetterFlag, TermLetterFlag
--	 , HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDueInitial, TotalAmountDue, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsInitial
--	 , TotalTransactionsCount, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd, AdminFees, CitationFees, MonthlyPaymentAmount, BalanceDue, ExcusedAmount, CollectableAmount
	 , BankruptcyInd
	 , HVActive, HVRemoved, VrbAcknowledged, VrbRemoved
	 , VrbRemovalQueued, BanByProcessServer, BanByDPS, BanByUSMail1stBan
FROM dbo.ViolatorStatus
OPTION (LABEL = 'ViolatorStatus_Mart_Stage_Load: ViolatorStatus_Mart_Stage');

CREATE STATISTICS STATS_ViolatorStatus_Mart_Stage_Load_001 ON dbo.ViolatorStatus_Mart_Stage (ReportDate, ViolatorID, VidSeq)

IF (SELECT COUNT(*) FROM dbo.ViolatorStatus_Mart WHERE ReportDate = CONVERT(Date,Convert(varchar(10), GETDATE(),101)) ) >0
	DELETE FROM dbo.ViolatorStatus_Mart WHERE ReportDate = CONVERT(Date,Convert(varchar(10), GETDATE(),101))

INSERT INTO dbo.ViolatorStatus_Mart (ReportDate, ViolatorID, VidSeq
	 , HvFlag, HvExemptFlag, TermFlag, EligRmdyFlag, BanFlag, BanCiteWarnFlag
--	 , BanCiteWarnCount
	 , BanImpoundFlag, VrbFlag, DeterminationLetterFlag, BanLetterFlag, TermLetterFlag
--	 , HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDueInitial, TotalAmountDue, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsInitial
--	 , TotalTransactionsCount, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd, AdminFees, CitationFees, MonthlyPaymentAmount, BalanceDue, ExcusedAmount, CollectableAmount
--	 , BankruptcyInd
	 , HVActive, HVRemoved, VrbAcknowledged, VrbRemoved
	 , VrbRemovalQueued, BanByProcessServer, BanByDPS, BanByUSMail1stBan)
SELECT ReportDate, ViolatorID, VidSeq
	 , HvFlag, HvExemptFlag, TermFlag, EligRmdyFlag, BanFlag, BanCiteWarnFlag
--	 , BanCiteWarnCount
	 , BanImpoundFlag, VrbFlag, DeterminationLetterFlag, BanLetterFlag, TermLetterFlag
--	 , HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDueInitial, TotalAmountDue, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsInitial
--	 , TotalTransactionsCount, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd, AdminFees, CitationFees, MonthlyPaymentAmount, BalanceDue, ExcusedAmount, CollectableAmount
--	 , BankruptcyInd
	 , HVActive, HVRemoved, VrbAcknowledged, VrbRemoved
	 , VrbRemovalQueued, BanByProcessServer, BanByDPS, BanByUSMail1stBan
FROM dbo.ViolatorStatus_Mart_Stage



IF OBJECT_ID('dbo.ViolatorStatus_Mart_Incr_Stage')>0
	DROP TABLE dbo.ViolatorStatus_Mart_Incr_Stage

CREATE TABLE dbo.ViolatorStatus_Mart_Incr_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 

SELECT 
	  CONVERT(Date,Convert(varchar(10), GETDATE(),101)) AS ReportDate
	, ISNULL(Today.ViolatorID, Yesterday.ViolatorID) AS ViolatorID
	, ISNULL(Today.VidSeq, Yesterday.VidSeq) AS VidSeq
	--, Yesterday.TermFlag AS Y_TermFlag
	--, Today.TermFlag AS T_TermFlag
	, CASE WHEN (Yesterday.TermFlag IS NULL OR Yesterday.TermFlag = 0) AND Today.TermFlag = 1 THEN 1 ELSE 0 END AS TermAddedFlag
	, CASE WHEN Yesterday.TermFlag = 1 AND (Today.TermFlag = 0 OR Today.TermFlag IS NULL) THEN 1 ELSE 0 END AS TermRemovedFlag
	--, Yesterday.HVActive AS Y_HVActive
	--, Today.HVActive AS T_HVActive
	, CASE WHEN (Yesterday.HVActive IS NULL OR Yesterday.HVActive = 0) AND Today.HVActive = 1 THEN 1 ELSE 0 END AS HVActiveAdded
	, CASE WHEN Yesterday.HVActive = 1 AND (Today.HVActive = 0 OR Today.HVActive IS NULL) THEN 1 ELSE 0 END AS HVActiveRemoved
	--, Yesterday.VrbFlag AS Y_VrbFlag
	--, Today.VrbFlag AS T_VrbFlag
	, CASE WHEN (Yesterday.VrbFlag IS NULL OR Yesterday.VrbFlag = 0) AND Today.VrbFlag = 1 THEN 1 ELSE 0 END AS VrbFlagAdded
	, CASE WHEN Yesterday.VrbFlag = 1 AND (Today.VrbFlag = 0 OR Today.VrbFlag IS NULL) THEN 1 ELSE 0 END AS VrbFlagRemoved
FROM 
(
	SELECT ReportDate, ViolatorID, VidSeq, TermFlag, HVActive, VrbFlag
	FROM dbo.ViolatorStatus_Mart
	WHERE ReportDate = CONVERT(Date,Convert(varchar(10), GETDATE(),101))
) Today
FULL OUTER JOIN 
(
	SELECT ReportDate, ViolatorID, VidSeq, TermFlag, HVActive, VrbFlag
	FROM dbo.ViolatorStatus_Mart
	WHERE ReportDate = CONVERT(Date,Convert(varchar(10), DATEADD(d,-1,GETDATE()),101))
) Yesterday
ON Today.ViolatorID = Yesterday.ViolatorID AND Today.VidSeq = Yesterday.VidSeq 

CREATE STATISTICS STATS_ViolatorStatus_Mart_Incr_Stage_Load_001 ON dbo.ViolatorStatus_Mart_Incr_Stage (ReportDate, ViolatorID, VidSeq)


UPDATE dbo.ViolatorStatus_Mart
SET 
	  dbo.ViolatorStatus_Mart.TermAddedFlag = B.TermAddedFlag
	, dbo.ViolatorStatus_Mart.TermRemovedFlag = B.TermRemovedFlag
	, dbo.ViolatorStatus_Mart.HVActiveAdded = B.HVActiveAdded
	, dbo.ViolatorStatus_Mart.HVActiveRemoved = B.HVActiveRemoved
	, dbo.ViolatorStatus_Mart.VrbFlagAdded = B.VrbFlagAdded
	, dbo.ViolatorStatus_Mart.VrbFlagRemoved = B.VrbFlagRemoved
FROM dbo.ViolatorStatus_Mart_Incr_Stage B
WHERE dbo.ViolatorStatus_Mart.ReportDate = B.ReportDate AND dbo.ViolatorStatus_Mart.ViolatorID = B.ViolatorID AND dbo.ViolatorStatus_Mart.VidSeq = B.VidSeq


	--UPDATE ViolatorStatus_Mart
	--SET TermAddedFlag = 0, TermRemovedFlag = 0, HVActiveAdded=0, HVActiveRemoved=0, VrbFlagAdded=0,VrbFlagRemoved=0
	--WHERE ReportDate = '9/25/2015'





