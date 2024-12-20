CREATE PROC [dbo].[Violator_Bankruptcy_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'dbo.Violator', @LAST_UPDATE_DATE OUTPUT

	 
IF OBJECT_ID('dbo.Violator_Bankruptcy_Stage')>0
	DROP TABLE dbo.Violator_Bankruptcy_Stage


CREATE TABLE dbo.Violator_Bankruptcy_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
SELECT 
      [Violator ID] As ViolatorID, [SeqNbr] AS VidSeq, [BankruptcyInstanceNbr]
	, [Last Name] As LastName, [First Name] AS FirstName
	, [Last Name2] AS LastName2, [First Name2] As FirstName2, [License Plate] AS LicensePlate
	, [Case Number] As CaseNumber, ISNULL([Date Notified],'1/1/1900') As DateNotified
	, ISNULL([Filing Date],'1/1/1900') As FilingDate, ISNULL([Conversion Date],'1/1/1900') AS ConversionDate
	, [Excused Amount] AS ExcusedAmount, [Collectable Amount] As CollectableAmount
	, [Phone Number] AS PhoneNumber, ISNULL([Discharge / Dismissed],'(Null)') AS DischargeDismissed, ISNULL([Discharge / Dismissed Date],'1/1/1900') AS Discharge_Dismissed_Date
	, ISNULL([Assets],-1) As Assets, ISNULL([Collection Accounts],-1) As CollectionAccounts, [Law Firm] AS LawFirm
	, [Attorney Name] As AttorneyName, ISNULL([Claim Filled],-1) AS ClaimFilled
	, [Comments], ISNULL([Filing Status],'(Null)') AS FilingStatus
	, InsertDateTime AS InsertDate, InsertByUser, LastUpdateDateTime As LastUpdateDate, LastUpdateByUser
	, [LAST_UPDATE_TYPE]
	, [LAST_UPDATE_DATE]
 FROM LND_TER.dbo.Bankruptcy V
  WHERE V.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
  OPTION (LABEL = 'Violator_BankruptcyStage_LOAD: Violator_BankruptcyStage');

CREATE STATISTICS STATS_Violator_Bankruptcy_Stage_LOAD_001 ON dbo.Violator_Bankruptcy_Stage (DischargeDismissed)
CREATE STATISTICS STATS_Violator_Bankruptcy_Stage_LOAD_002 ON dbo.Violator_Bankruptcy_Stage (FilingStatus)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_FilingStatus NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_FilingStatusId int = ISNULL((SELECT TOP 1 FilingStatusId FROM DBO.DIM_FilingStatus ORDER BY FilingStatusId DESC),0);

INSERT INTO DBO.DIM_FilingStatus (FilingStatusId, FilingStatus, INSERT_DATETIME)
SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_FilingStatusId, A.FilingStatus, GETDATE() AS INSERT_DATETIME
FROM 
(
	SELECT DISTINCT FilingStatus
	FROM dbo.Violator_Bankruptcy_Stage
) A
LEFT JOIN DBO.DIM_FilingStatus B
	ON A.FilingStatus = B.FilingStatus 
WHERE 
	B.FilingStatus IS NULL
OPTION (LABEL = 'Violator_BankruptcyStage_LOAD: INSERT INTO DBO.DIM_FilingStatus');

UPDATE STATISTICS [dbo].DIM_FilingStatus WITH FULLSCAN

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_FilingStatus NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_DischargeDismissedId int = ISNULL((SELECT TOP 1 DischargeDismissedId FROM DBO.DIM_DischargeDismissed ORDER BY DischargeDismissedId DESC),0);
-- getfields 'DIM_DischargeDismissed'
INSERT INTO dbo.DIM_DischargeDismissed ( DischargeDismissedId, DischargeDismissed, INSERT_DATETIME)
SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_DischargeDismissedId, A.DischargeDismissed, GETDATE() AS INSERT_DATETIME
FROM 
(
	SELECT DISTINCT DischargeDismissed
	FROM dbo.Violator_Bankruptcy_Stage
) A
LEFT JOIN DBO.DIM_DischargeDismissed B
	ON A.DischargeDismissed = B.DischargeDismissed 
WHERE 
	B.DischargeDismissed IS NULL
OPTION (LABEL = 'Violator_BankruptcyStage_LOAD: INSERT INTO DBO.DIM_DischargeDismissed');

UPDATE STATISTICS [dbo].DIM_DischargeDismissed WITH FULLSCAN


/*
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	ViolatorCase_Bankruptcy_Stage
	This stage section is for loading Bankruptcy Metrics into the higher level of Violator Case
	Only the latest Instance for a Payment Agreement should be summed into the Violator Case Level
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
*/

IF OBJECT_ID('dbo.ViolatorCase_Bankruptcy_Stage')>0
	DROP TABLE dbo.ViolatorCase_Bankruptcy_Stage

CREATE TABLE dbo.ViolatorCase_Bankruptcy_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 

SELECT 
	  A.ViolatorId, A.VidSeq
	, ExcusedAmount, CollectableAmount
	, 1 AS BankruptcyInd
FROM dbo.Violator_Bankruptcy_Stage A
INNER JOIN 
	(
		SELECT ViolatorId, VidSeq, MAX(BankruptcyInstanceNbr) AS BankruptcyInstanceNbr
		FROM dbo.Violator_Bankruptcy_Stage
		GROUP BY ViolatorId, VidSeq
	) B
	ON A.ViolatorId = B.ViolatorId AND A.VidSeq = B.VidSeq AND A.BankruptcyInstanceNbr = B.BankruptcyInstanceNbr
	
CREATE STATISTICS STATS_ViolatorCase_Bankruptcy_Stage_Load_001 ON dbo.ViolatorCase_Bankruptcy_Stage (ViolatorID, VidSeq)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- FINAL STAGE
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


--getfields 'Violator_Bankruptcy_Stage'

IF OBJECT_ID('dbo.Violator_Bankruptcy_Final_Stage')>0
	DROP TABLE dbo.Violator_Bankruptcy_Final_Stage


CREATE TABLE dbo.Violator_Bankruptcy_Final_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
	SELECT 
		  ViolatorID, VidSeq, BankruptcyInstanceNbr
		, LastName, FirstName, LastName2, FirstName2
		, LicensePlate, CaseNumber, DateNotified, FilingDate
		, ConversionDate, ExcusedAmount, CollectableAmount
		, PhoneNumber, b.DischargeDismissedId, Discharge_Dismissed_Date
		, Assets, CollectionAccounts, LawFirm
		, AttorneyName, ClaimFilled, Comments
		, C.FilingStatusId
		, InsertDate, InsertByUser, LastUpdateDate, LastUpdateByUser
		, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	-- select COUNT(*)
	FROM dbo.Violator_Bankruptcy_Stage A
	INNER JOIN dbo.DIM_DischargeDismissed B  ON A.DischargeDismissed = B.DischargeDismissed
	INNER JOIN dbo.DIM_FilingStatus C  ON A.FilingStatus = C.FilingStatus

CREATE STATISTICS STATS_Violator_Bankruptcy_Final_Stage_LOAD_001 ON dbo.Violator_Bankruptcy_Final_Stage (ViolatorID, VidSeq,BankruptcyInstanceNbr)



