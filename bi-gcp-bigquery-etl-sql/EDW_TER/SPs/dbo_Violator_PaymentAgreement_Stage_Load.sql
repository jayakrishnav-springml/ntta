CREATE PROC [dbo].[Violator_PaymentAgreement_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'dbo.Violator_PaymentAgreement', @LAST_UPDATE_DATE OUTPUT
		 
IF OBJECT_ID('Violator_PaymentAgreement_Stage')>0
	DROP TABLE dbo.Violator_PaymentAgreement_Stage

CREATE TABLE dbo.Violator_PaymentAgreement_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 

	SELECT 
	  [Violator ID] as ViolatorId 
	, [SeqNbr] AS VidSeq
	, [PaymentPlanInstanceNbr] As InstanceNbr
	, [Last Name] as LastName
	, [First Name] as FirstName
	, [Phone Number] as PhoneNumber
	, [License Plate] As LicensePlate
	, ISNULL([State],-1) AS [State]
	, ISNULL([Agent ID],-1) as AgentID
	, ISNULL([Indicator],'(Null)') AS PaymentAgreement_Source
	, [Settlement Amount] as SettlementAmount
	, [Down Payment] as DownPayment
	, ISNULL([Due Date],'1/1/1900') as DueDate
	, ISNULL([Agreement Type],'(Null)') as AgreementType
	, ISNULL([Todays Date],'1/1/1900') as TodaysDate
	, [Collections] as Collections
	, [Remaining Balance Due] as RemainingBalanceDue
	, ISNULL([Payment Plan Due Date],'1/1/1900') as PaymentPlanDueDate
	, [Check Number] as CheckNumber
	, CASE WHEN [Paid in Full] = 'YES' THEN 1 WHEN [Paid in Full] = 'NO' THEN 0 ELSE -1 END  as PaidInFull
	, CASE WHEN [Default] = 'YES' THEN 1 WHEN [Default] = 'NO' THEN 0 ELSE -1 END  as DefaultInd
	, [Spanish Only] as SpanishOnly
	, [Amnesty Account] as AmnestyAccount
	, [Tolltag_Acct_Id]
	, [AdminFees]
	, [CitationFees]
	, [Monthly Payment Amount] AS [MonthlyPaymentAmount]
	, ISNULL(DefaultDate,'1/1/1900') AS DefaultDate
	, ISNULL(MaintenanceAgency,'(Null)') AS MaintenanceAgency
	, ViolatorID2
	, ViolatorID3
	, ViolatorID4
	, BalanceDue
	, NTTA_Collections
	, EnforcementTool.EnforcementTool AS ENFORCEMENT_TOOL_CODE 
	, EnforcementTool.EnforcementToolDate AS ENFORCEMENT_TOOL_DATE
    , [ContactSource] --varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    , [PaymentPlanStatus] --varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
	, InsertDateTime as InsertDate
	, InsertByUser
	, LastUpdateDateTime as LastUpdateDate
	, LastUpdateByUser
	, [LAST_UPDATE_TYPE]
	, [LAST_UPDATE_DATE]

	FROM LND_TER.dbo.PaymentAgreement V
	LEFT JOIN 
	(
		SELECT A.ViolatorID, A.VidSeq
			, CASE 
				WHEN Vrb.VrbFlag = 1 THEN 'VRB'
				WHEN Ban.BanFlag = 1 THEN 'BAN'
				ELSE 'HV'
			  END As EnforcementTool
			, CASE 
				WHEN Vrb.VrbFlag = 1 THEN Vrb.VrbDAte
				WHEN Ban.BanFlag = 1 THEN Ban.BanDAte
				ELSE A.HVDate
			  END As EnforcementToolDate
		FROM ViolatorStatus A
		INNER JOIN Violator B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
		LEFT JOIN 
		(
			SELECT A.ViolatorID, A.VidSeq, A.VrbFlag
			, Case when A.VrbDAte = '1/1/1900' THEN C.SentDate ELSE A.VrbDAte END AS VrbDAte
			FROM ViolatorStatus A
			INNER JOIN Violator B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
			LEFT JOIN 
			(
				SELECT ViolatorID, VidSeq, MAX(SentDate) AS SentDate 
				FROM VRB 
				GROUP BY ViolatorID, VidSeq
			) C ON A.ViolatorID = C.ViolatorID AND A.VidSeq = C.VidSeq
			where A.VrbFlag = 1 
		) Vrb ON A.ViolatorID = Vrb.ViolatorID AND A.VidSeq = Vrb.VidSeq
		LEFT JOIN 
		(
			SELECT A.ViolatorID, A.VidSeq, A.BanFlag, A.BanDAte
			FROM ViolatorStatus A
			INNER JOIN Violator B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
			where A.BanFlag = 1 
		) Ban ON A.ViolatorID = Ban.ViolatorID AND A.VidSeq = Ban.VidSeq
	) EnforcementTool ON V.[Violator ID] = EnforcementTool.ViolatorID AND V.SeqNbr = EnforcementTool.VidSeq
	WHERE 
		V.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
		AND 
		LAST_UPDATE_TYPE IN ('I','U')
	OPTION (LABEL = 'Violator_PaymentAgreementStage_LOAD: Violator_PaymentAgreementStage');

	CREATE STATISTICS STATS_Violator_PaymentAgreement_Stage_LOAD_001 ON dbo.Violator_PaymentAgreement_Stage (AgreementType)
	CREATE STATISTICS STATS_Violator_PaymentAgreement_Stage_LOAD_002 ON dbo.Violator_PaymentAgreement_Stage (AgentID)
	CREATE STATISTICS STATS_Violator_PaymentAgreement_Stage_LOAD_003 ON dbo.Violator_PaymentAgreement_Stage (PaymentAgreement_Source)


	






-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_AgreementType NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_AgreementTypeId int = ISNULL((SELECT TOP 1 AgreementTypeId FROM DBO.DIM_AgreementType ORDER BY AgreementTypeId DESC),0);

INSERT INTO DBO.DIM_AgreementType (AgreementTypeId, AgreementType, INSERT_DATETIME)
SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_AgreementTypeId, A.AgreementType, GETDATE() AS INSERT_DATETIME
FROM 
(
	SELECT DISTINCT AgreementType
	FROM dbo.Violator_PaymentAgreement_Stage
) A
LEFT JOIN DBO.DIM_AgreementType B
	ON A.AgreementType = B.AgreementType 
WHERE 
	B.AgreementType IS NULL
OPTION (LABEL = 'Violator_PaymentAgreementStage_LOAD: INSERT INTO DBO.DIM_AgreementType');

UPDATE STATISTICS [dbo].DIM_AgreementType WITH FULLSCAN


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_Agent NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_AgentId int = ISNULL((SELECT TOP 1 AgentId FROM DBO.DIM_Agent ORDER BY AgentId DESC),0);

INSERT INTO dbo.DIM_Agent ( AgentId, Agent, INSERT_DATETIME)
SELECT DISTINCT A.AgentId, RIGHT('000' + convert(varchar(100),A.AgentId),3), GETDATE()
FROM dbo.Violator_PaymentAgreement_Stage A
LEFT JOIN DBO.DIM_Agent B
	ON A.AgentId = B.AgentId
WHERE 
	B.Agentid IS NULL
OPTION (LABEL = 'Violator_PaymentAgreementStage_LOAD: INSERT INTO DBO.DIM_Agent');

UPDATE STATISTICS [dbo].DIM_Agent WITH FULLSCAN

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_MaintenanceAgency NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_MaintenanceAgencyId int = ISNULL((SELECT TOP 1 MaintenanceAgencyId FROM DBO.DIM_MaintenanceAgency ORDER BY MaintenanceAgencyId DESC),0);


INSERT INTO dbo.DIM_MaintenanceAgency ( MaintenanceAgencyId, MaintenanceAgency, INSERT_DATETIME)
SELECT  ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_MaintenanceAgencyId, A.MaintenanceAgency, GETDATE()
FROM 
	(
		SELECT DISTINCT MaintenanceAgency
		FROM dbo.Violator_PaymentAgreement_Stage
	) A
LEFT JOIN DBO.DIM_MaintenanceAgency B
	ON A.MaintenanceAgency = B.MaintenanceAgency
WHERE 
	B.MaintenanceAgency IS NULL
GROUP BY A.MaintenanceAgency
OPTION (LABEL = 'Violator_PaymentAgreementStage_LOAD: INSERT INTO DBO.DIM_MaintenanceAgency');

UPDATE STATISTICS [dbo].DIM_MaintenanceAgency WITH FULLSCAN


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_PaymentAgreement_Source NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_PaymentAgreement_SourceId int = ISNULL((SELECT TOP 1 PaymentAgreement_SourceId FROM DBO.DIM_PaymentAgreement_Source ORDER BY PaymentAgreement_SourceId DESC),0);

INSERT INTO dbo.DIM_PaymentAgreement_Source ( PaymentAgreement_SourceId, PaymentAgreement_Source, INSERT_DATETIME)
SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_PaymentAgreement_SourceId, A.PaymentAgreement_Source, GETDATE() AS INSERT_DATETIME
FROM 
(
	SELECT DISTINCT PaymentAgreement_Source
	FROM dbo.Violator_PaymentAgreement_Stage
) A
LEFT JOIN DBO.DIM_PaymentAgreement_Source B
	ON A.PaymentAgreement_Source = B.PaymentAgreement_Source 
WHERE 
	B.PaymentAgreement_Source IS NULL
OPTION (LABEL = 'Violator_PaymentAgreementStage_LOAD: INSERT INTO DBO.DIM_PaymentAgreement_Source');

UPDATE STATISTICS [dbo].DIM_PaymentAgreement_Source WITH FULLSCAN

/*
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	ViolatorCase_PaymentAgreement_Stage
	This stage section is for loading Payment Metrics into the higher level of Violator Case
	Only the latest Instance for a Payment Agreement should be summed into the Violator Case Level
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
*/

IF OBJECT_ID('dbo.ViolatorCase_PaymentAgreement_Stage')>0
	DROP TABLE dbo.ViolatorCase_PaymentAgreement_Stage

CREATE TABLE dbo.ViolatorCase_PaymentAgreement_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 

SELECT 
	A.ViolatorId, A.VidSeq
 , SettlementAmount, DownPayment
 , Collections
 , PaidInFull
 , DefaultInd
 , AdminFees, CitationFees
 , MonthlyPaymentAmount
 , BalanceDue
FROM dbo.Violator_PaymentAgreement_Stage A
INNER JOIN 
	(
		SELECT ViolatorId, VidSeq, MAX(InstanceNbr) AS InstanceNbr
		FROM dbo.Violator_PaymentAgreement_Stage
		GROUP BY ViolatorId, VidSeq
	) B
	ON A.ViolatorId = B.ViolatorId AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	
CREATE STATISTICS STATS_ViolatorCase_PaymentAgreement_Stage_Load_001 ON dbo.ViolatorCase_PaymentAgreement_Stage (ViolatorID, VidSeq)


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- FINAL 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
IF OBJECT_ID('dbo.Violator_PaymentAgreement_Final_Stage')>0
	DROP TABLE dbo.Violator_PaymentAgreement_Final_Stage


CREATE TABLE dbo.Violator_PaymentAgreement_Final_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
	SELECT 
		  ViolatorId, 
		  VidSeq, 
		  InstanceNbr,
		  LastName, 
		  FirstName, 
		  PhoneNumber,
		  LicensePlate, 
		  State,
		  B.AgentID, 
		  C.PaymentAgreement_SourceId,
		  SettlementAmount, 
		  DownPayment, 
		  DueDate,
		  D.AgreementTypeId,
		  TodaysDate, 
		  Collections, 
		  RemainingBalanceDue,
		  PaymentPlanDueDate,
		  CheckNumber, 
		  PaidInFull,
		  DefaultInd,
		  SpanishOnly, 
		  AmnestyAccount,
		  Tolltag_Acct_Id, 
		  AdminFees, 
		  CitationFees,
		  MonthlyPaymentAmount,
		  LAST_UPDATE_TYPE, 
		  LAST_UPDATE_DATE,
		  InsertDate,
		  InsertByUser,
		  LastUpdateDate,
		  LastUpdateByUser,
		  DefaultDate,
		  E.MaintenanceAgencyID,
		  ViolatorID2,
		  ViolatorID3,
		  ViolatorID4,
		  BalanceDue,
		  NTTA_Collections,
		  ENFORCEMENT_TOOL_CODE,
		  ENFORCEMENT_TOOL_DATE
		, [ContactSource] --varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
		, [PaymentPlanStatus] --varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
	FROM dbo.Violator_PaymentAgreement_Stage A
	INNER JOIN dbo.Dim_Agent B  ON A.AgentID = B.AgentID
	INNER JOIN dbo.DIM_PaymentAgreement_Source C  ON A.PaymentAgreement_Source = C.PaymentAgreement_Source
	INNER JOIN dbo.Dim_AgreementType D  ON A.AgreementType = D.AgreementType
	INNER JOIN dbo.Dim_MaintenanceAgency E  ON A.MaintenanceAgency = E.MaintenanceAgency

CREATE STATISTICS STATS_Violator_PaymentAgreement_Final_Stage_LOAD_001 ON dbo.Violator_PaymentAgreement_Final_Stage (ViolatorID, VidSeq,InstanceNbr)



