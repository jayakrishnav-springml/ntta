CREATE PROC [dbo].[HV_ANALYSIS_LOAD] AS

/*
DROP PROCEDURE dbo.HV_ANALYSIS_LOAD

EXEC dbo.HV_ANALYSIS_LOAD
*/

IF OBJECT_ID('dbo.HV_Datail_ANDY') IS NOT NULL DROP TABLE dbo.HV_Datail_ANDY;	

CREATE TABLE dbo.HV_Datail_ANDY WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(HV_Month)) AS --EXPLAIN
WITH CTE AS
(
SELECT 
	CAST((LEFT(CONVERT(VARCHAR(8), DATEADD(MONTH, 1, HV.HvDate) ,112), 6) + '01') AS DATE) AS HV_Month,
	HV.ViolatorID,
	1 AS HV,
	CASE WHEN HV.VidSeq = 1 THEN 1 ELSE 0 END AS NEW_HV,
	CASE WHEN HV.HvQAmountDue = 0 THEN 1 ELSE 0 END AS PAID_IN_FULL,
	CASE 
		WHEN EXISTS (SELECT 1 FROM [dbo].[VIOLATOR_PAYMENTPLAN_XREF] PP WHERE PP.ViolatorID = HV.ViolatorID AND PP.VidSeq = HV.VidSeq AND PP.DeletedFlag = 0)
			THEN 1
		ELSE 0
	END AS Pay_Plan,
	RHV.VidSeq AS Returning_HV
	--CASE WHEN RHV.VidSeq IS NULL THEN 0 ELSE 1 END AS Returning_HV
	-- SELECT COUNT_BIG(1) 
FROM [dbo].[ViolatorStatus] HV
LEFT JOIN [dbo].[ViolatorStatus]  RHV ON RHV.ViolatorID = HV.ViolatorID AND RHV.VidSeq > HV.VidSeq AND HV.VidSeq = 1
)
SELECT ViolatorID,HV_Month,HV,NEW_HV,PAID_IN_FULL,Pay_Plan,MAX(Returning_HV) AS Returning_HV 
FROM CTE
GROUP BY ViolatorID,HV_Month,HV,NEW_HV,PAID_IN_FULL,Pay_Plan	

IF OBJECT_ID('dbo.HV_ANALYSIS_ANDY') IS NOT NULL DROP TABLE dbo.HV_ANALYSIS_ANDY;	

CREATE TABLE dbo.HV_ANALYSIS_ANDY WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(HV_Month)) AS --EXPLAIN

SELECT HV_Month, SUM(HV) AS HV, SUM(NEW_HV) AS NEW_HV, SUM(PAID_IN_FULL) AS PAID_IN_FULL, COUNT(Returning_HV) AS Returning_HV, SUM(Pay_Plan) AS Pay_Plan,
SUM(CASE WHEN Returning_HV = 2 THEN 1 ELSE 0 END) AS Returning_HV_2,
SUM(CASE WHEN Returning_HV = 3 THEN 1 ELSE 0 END) AS Returning_HV_3,
SUM(CASE WHEN Returning_HV = 4 THEN 1 ELSE 0 END) AS Returning_HV_4,
SUM(CASE WHEN Returning_HV = 5 THEN 1 ELSE 0 END) AS Returning_HV_5,
SUM(CASE WHEN Returning_HV > 5 THEN 1 ELSE 0 END) AS Returning_HV_6_more
FROM HV_Datail_ANDY
GROUP BY HV_Month

--USE EDW_TER
--GO
/*
\\nttafs1\Groups\NTTA\For Pat Louthan\HV_Details.csv
*/

/*
SELECT * FROM dbo.HV_Datail_ANDY
ORDER BY ViolatorID, HV_Month

SELECT * FROM dbo.HV_ANALYSIS_ANDY
ORDER BY  HV_Month
*/
/*
SELECT TOP 100 * FROM [dbo].[VIOLATOR_PAYMENTPLAN_XREF] (
    [PaymentPlanID] int NOT NULL, 
    [ViolatorID] bigint NOT NULL, 
    [VidSeq] int NULL, 
    [PaymentPlanViolatorSeq] int NOT NULL, 
    [DeletedFlag] bit NOT NULL, 
    [PaymentPlanStatus] int NULL
*/

/*
(
    [ViolatorStatusID] int NOT NULL, 
    [ViolatorID] bigint NOT NULL, 
    [VidSeq] int NOT NULL, 
    [HvFlag] smallint NOT NULL, 
    [HvDate] date NOT NULL, 
    [ViolatorStatusLookupID] int NOT NULL, 
    [HvExemptFlag] smallint NOT NULL, 
    [HvExemptDate] date NOT NULL, 
    [ViolatorStatusTermLookupID] int NOT NULL, 
    [TermFlag] smallint NOT NULL, 
    [TermDate] date NOT NULL, 
    [ViolatorStatusEligRmdyLookupID] int NOT NULL, 
    [EligRmdyFlag] smallint NOT NULL, 
    [EligRmdyDate] date NOT NULL, 
    [BanFlag] smallint NOT NULL, 
    [BanDate] date NOT NULL, 
    [BanStartDate] date NOT NULL, 
    [BanCiteWarnFlag] smallint NOT NULL, 
    [BanCiteWarnDate] date NOT NULL, 
    [BanCiteWarnCount] int NULL, 
    [BanImpoundFlag] smallint NOT NULL, 
    [BanImpoundDate] date NOT NULL, 
    [VrbFlag] smallint NOT NULL, 
    [VrbDate] date NOT NULL, 
    [ViolatorStatusLetterDeterminationLookupID] int NOT NULL, 
    [DeterminationLetterFlag] smallint NOT NULL, 
    [DeterminationLetterDate] date NOT NULL, 
    [ViolatorStatusLetterBanLookupID] int NOT NULL, 
    [BanLetterFlag] smallint NOT NULL, 
    [BanLetterDate] date NOT NULL, 
    [ViolatorStatusLetterTermLookupID] int NOT NULL, 
    [TermLetterFlag] smallint NOT NULL, 
    [TermLetterDate] date NOT NULL, 
    [HvQAmountDue] money NOT NULL, 
    [HvQTollsDue] money NOT NULL, 
    [HvQTransactions] int NULL, 
    [HvQFeesDue] money NOT NULL, 
    [TotalAmountDueInitial] money NULL, 
    [TotalAmountDue] money NOT NULL, 
    [TotalTollsDue] money NULL, 
    [TotalFeesDue] money NULL, 
    [TotalCitationCount] int NOT NULL, 
    [TotalTransactionsInitial] int NULL, 
    [TotalTransactionsCount] int NOT NULL, 
    [SettlementAmount] money NULL, 
    [DownPayment] money NULL, 
    [Collections] money NULL, 
    [PaidInFull] smallint NULL, 
    [DefaultInd] smallint NULL, 
    [AdminFees] money NULL, 
    [CitationFees] money NULL, 
    [MonthlyPaymentAmount] money NULL, 
    [BalanceDue] money NULL, 
    [ExcusedAmount] money NULL, 
    [CollectableAmount] money NULL, 
    [BankruptcyInd] smallint NULL, 
    [HVActive] smallint NULL, 
    [HVRemoved] smallint NULL, 
    [VrbAcknowledged] smallint NULL, 
    [VrbRemoved] smallint NULL, 
    [VrbRemovalQueued] smallint NULL, 
    [BanByProcessServer] smallint NULL, 
    [BanByDPS] smallint NULL, 
    [BanByUSMail1stBan] smallint NULL, 
    [ACCT_ID] bigint NULL, 
    [ACCT_STATUS_CODE] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [HAS_TOLL_TAG_ACCOUNT] smallint NULL, 
    [TollTransactionCount] int NULL, 
    [BALANCE_AMOUNT] money NULL, 
    [PMT_TYPE_CODE] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [REBILL_AMT] decimal(9, 2) NULL, 
    [REBILL_DATE] datetime2(0) NULL, 
    [BAL_LAST_UPDATED] datetime2(0) NULL, 
    [Ban2ndLetterDate] datetime NULL, 
    [Ban2ndLetterFlag] smallint NULL, 
    [ViolatorStatusLetterBan2ndLookupID] int NULL, 
    [ViolatorStatusLetterVrbLookupID] int NULL, 
    [VrbLetterDate] datetime NULL, 
    [VrbLetterFlag] smallint NULL, 
    [BanDPSCount] smallint NULL, 
    [BanPCPCount] smallint NULL, 
    [BanWarnCount] smallint NULL, 
    [BanCitationCount] smallint NULL, 
    [BanImpoundCount] smallint NULL, 
    [BanNoActionCount] smallint NULL, 
    [BanFennellCount] smallint NULL, 
    [INSERT_DATE] datetime2(2) NOT NULL, 
    [LAST_UPDATE_DATE] datetime2(2) NOT NULL, 
    [TAG_DATE_CREATED] date NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([ViolatorID]));
*/
